import SwiftUI

struct ExamView: View {
    let course: Course
    @ObservedObject var questionLoader: QuestionLoader
    
    @State private var currentQuestionIndex = 0
    @State private var selectedChoices: [UUID: Set<UUID>] = [:]
    @State private var timeRemaining: Int
    @State private var examFinished = false
    @State private var startTime: Date = Date()
    @State private var lastExamData: UserExamData? = nil
    @State private var navigateToSummary = false

    let questionCount: Int
    let timeLimit: Int
    let mode: String

    init(questionCount: Int, timeLimit: Int, course: Course, mode: String) {
        self.course = course
        self._questionLoader = ObservedObject(wrappedValue: QuestionLoader(filename: course.shortName + ".json"))
        self.questionCount = questionCount
        self.timeLimit = timeLimit
        _timeRemaining = State(initialValue: timeLimit)
        self.mode = mode
    }

    var body: some View {
        VStack {
            VStack {
                if !questionLoader.questions.isEmpty {
                    let questions = Array(questionLoader.questions.prefix(questionCount))
                    if currentQuestionIndex < questions.count {
                        HStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("\(currentQuestionIndex + 1) of \(questionCount)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        let question = questions[currentQuestionIndex]
                        
                        QuestionView(
                            mode: .exam,
                            question: question,
                            selectedChoices: selectedChoices[question.id] ?? [],
                            isMultipleResponse: question.multipleResponse,
                            isResultShown: false, // Exam mode does not show result immediately
                            onChoiceSelected: { choiceId in
                                if question.multipleResponse {
                                    if selectedChoices[question.id]?.contains(choiceId) == true {
                                        selectedChoices[question.id]?.remove(choiceId)
                                    } else {
                                        selectedChoices[question.id, default: []].insert(choiceId)
                                    }
                                } else {
                                    selectedChoices[question.id] = [choiceId]
                                }
                            }
                        )
                        .id(question.id)
                        
                        Button(action: {
                            if currentQuestionIndex < questions.count - 1 {
                                currentQuestionIndex += 1
                            } else {
                                storeExamData(questions: questions)
                                navigateToSummary = true
                            }
                        }) {
                            Text(currentQuestionIndex < questions.count - 1 ? "Next Question" : "Show Exam Result")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.customSecondary)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        if let examData = lastExamData {
                            NavigationLink(destination: ExamSummaryView(exam: examData, afterExam: true), isActive: $navigateToSummary) {
                                EmptyView()
                            }
                        }
                    }

                    Spacer()

                    HStack {
                        Image(systemName: "timer")
                        Text(timeFormatted(timeRemaining))
                            .font(.headline)
                    }
                    .padding()
                } else {
                    Text("No Questions available! Please download course")
                }
            }
        }
        .onAppear(perform: startTimer)
        .onDisappear {
            if !examFinished {
                endExamIfNeeded()
            }
        }
    }

    func startTimer() {
        startTime = Date()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                storeExamData(questions: Array(questionLoader.questions.prefix(questionCount)))
                navigateToSummary = true
            }
        }
    }

    func storeExamData(questions: [Question]) {
        let endTime = Date()
        let timeSpent = Int(endTime.timeIntervalSince(startTime))
        let totalQuestions = questions.count
        var correctAnswers = 0
        
        var examQuestions: [ExamQuestionData] = []
        
        for question in questions {
            let selected = selectedChoices[question.id] ?? []
            let correctChoices = question.choices.filter { $0.correct }
            let isCorrect = correctChoices.allSatisfy { selected.contains($0.id) } &&
            selected.allSatisfy { selectedID in correctChoices.contains { $0.id == selectedID } }

            if isCorrect {
                correctAnswers += 1
            }
            let choices = question.choices.map { choice in
                ExamChoiceData(id: choice.id, text: choice.text, isCorrect: choice.correct)
            }
            let examQuestion = ExamQuestionData(question: question.question, choices: choices, selectedChoices: Array(selected))
            examQuestions.append(examQuestion)
        }
        
        let correctPercentage = Double(correctAnswers) / Double(totalQuestions) * 100
        let isPassed = correctPercentage >= 70 // Assuming 70% is the passing mark
        
        let examData = UserExamData(courseName: course.fullName, shortName: course.shortName, dateTime: Date(), questions: examQuestions, timeSpent: timeSpent, isPassed: isPassed, mode: mode)
        
        UserExamDataStore.shared.saveExamData(examData)
        lastExamData = examData
        examFinished = true
    }

    private func endExamIfNeeded() {
        if timeRemaining > 0 {
            timeRemaining = 0 // End the exam immediately
            storeExamData(questions: Array(questionLoader.questions.prefix(questionCount)))
            navigateToSummary = true
        }
    }

    func timeFormatted(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
