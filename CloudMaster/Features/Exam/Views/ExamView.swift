import SwiftUI

struct ExamView: View {
    let course: Course
    @ObservedObject var questionLoader: QuestionLoader
    
    @State private var currentQuestionIndex = 0
    @State private var selectedChoices: [UUID: Set<UUID>] = [:]
    @State private var timeRemaining: Int
    @State private var showSummary = false
    @State private var startTime: Date = Date()
    @State private var lastExamData: UserExamData? = nil

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

                    ExamQuestion(
                        question: questions[currentQuestionIndex],
                        selectedChoices: selectedChoices[questions[currentQuestionIndex].id] ?? [],
                        isMultipleResponse: questions[currentQuestionIndex].multipleResponse,
                        onChoiceSelected: { choiceId in
                            if questions[currentQuestionIndex].multipleResponse {
                                if selectedChoices[questions[currentQuestionIndex].id]?.contains(choiceId) == true {
                                    selectedChoices[questions[currentQuestionIndex].id]?.remove(choiceId)
                                } else {
                                    selectedChoices[questions[currentQuestionIndex].id, default: []].insert(choiceId)
                                }
                            } else {
                                selectedChoices[questions[currentQuestionIndex].id] = [choiceId]
                            }
                        }
                    )

                    Button(action: {
                        if currentQuestionIndex < questions.count - 1 {
                            currentQuestionIndex += 1
                        } else {
                            storeExamData(questions: questions)
                            showSummary = true
                        }
                    }) {
                        Text(currentQuestionIndex < questions.count - 1 ? "Next Question" : "Show Exam Result")
                            .padding()
                            .background(Color.customSecondary)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                    Spacer()

                    HStack {
                        Image(systemName: "timer")
                        Text(timeFormatted(timeRemaining))
                            .font(.headline)
                    }
                    .padding()
                } else {
                    Text("Loading questions...")
                }
            } else {
                Text("Loading questions...")
            }
        }
        .onAppear(perform: startTimer)
        .onDisappear {
            if !showSummary {
                endExamIfNeeded()
            }
        }
        .sheet(isPresented: $showSummary) {
            if let examData = lastExamData {
                ExamSummaryView(exam: examData)
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
                showSummary = true
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
    }

    private func endExamIfNeeded() {
        if timeRemaining > 0 {
            timeRemaining = 0 // End the exam immediately
            storeExamData(questions: Array(questionLoader.questions.prefix(questionCount)))
            showSummary = true
        }
    }

    func timeFormatted(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ExamQuestion: View {
    let question: Question
    let selectedChoices: Set<UUID>?
    let isMultipleResponse: Bool
    let onChoiceSelected: (UUID) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(question.question)
                    .font(.system(size: adjustedFontSize(for: question.question), weight: .bold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(nil) // Allow text to wrap as needed
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                
                if let imagePath = question.imagePath,
                   let image = loadImage(from: imagePath) {
                    Image(uiImage: image)
                        .resizable()
                        .cornerRadius(2)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                }

                if isMultipleResponse {
                    VStack {
                        Text("Multiple response - Pick \(question.responseCount)")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .opacity(0.7)
                            .padding(.vertical, 5)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                ForEach(question.choices) { choice in
                    ExamChoice(choice: choice, isSelected: selectedChoices?.contains(choice.id) == true, onChoiceSelected: onChoiceSelected)
                }
            }
            .padding()
        }
    }

    private func loadImage(from imagePath: String) -> UIImage? {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageURL = documentsURL.appendingPathComponent(imagePath)
        return UIImage(contentsOfFile: imageURL.path)
    }

    private func adjustedFontSize(for text: String) -> CGFloat {
        _ = UIScreen.main.bounds.width - 32 // Adjust for desired padding
        let fontSize = max(min(text.count / 80, 24), 14) // Simplified dynamic font sizing
        return CGFloat(fontSize)
    }
}

struct ExamChoice: View {
    let choice: Choice
    let isSelected: Bool
    let onChoiceSelected: (UUID) -> Void

    var body: some View {
        Text(choice.text)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .background(isSelected ? Color.blue.opacity(0.3) : Color.clear)
            .cornerRadius(10)
            .onTapGesture {
                onChoiceSelected(choice.id)
            }
            .multilineTextAlignment(.center)
        Divider()
    }
}
