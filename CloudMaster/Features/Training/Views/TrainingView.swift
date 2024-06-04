import SwiftUI

struct TrainingView: View {
    @State private var currentQuestionIndex = 0
    @State private var selectedChoices: Set<UUID> = []
    @State private var showResult = false
    @State private var userTrainingData = UserTrainingStore.shared.trainingData
    @State private var startTime: Date?
    @Environment(\.presentationMode) var presentationMode

    let course: Course
    @ObservedObject var questionLoader: QuestionLoader

    init(course: Course, questionLoader: QuestionLoader) {
        self.course = course
        self._questionLoader = ObservedObject(wrappedValue: questionLoader)
        loadUserTrainingData(for: course)
    }

    var body: some View {
        ZStack {
            VStack {
                QuestionNavbar(currentQuestionIndex: currentQuestionIndex, totalQuestions: questionLoader.questions.count)
                
                if !questionLoader.questions.isEmpty {
                    let questions = Array(questionLoader.questions)
                    let totalQuestions = questions.count
                    
                    let question = questions[currentQuestionIndex]
                    
                    QuestionView(
                        mode: .training,
                        question: question,
                        selectedChoices: selectedChoices,
                        isMultipleResponse: question.multipleResponse,
                        isResultShown: showResult,
                        onChoiceSelected: { choiceID in
                            handleChoiceSelection(choiceID, question)
                        }
                    )
                    
                    HStack(spacing: 20) {
                        if !showResult {
                            if currentQuestionIndex > 0 {
                                Button(action: {
                                    currentQuestionIndex = max(currentQuestionIndex - 1, 0)
                                    selectedChoices.removeAll()
                                    showResult = false
                                    startTime = Date()
                                }) {
                                    Text("Previous")
                                        .padding(10)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.customSecondary)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            
                            Button(action: {
                                showResult = true
                                updateUserTrainingData(for: question)
                            }) {
                                Text("Show Result")
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.customPrimary)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        } else {
                            Button(action: {
                                currentQuestionIndex = (currentQuestionIndex + 1) % totalQuestions
                                selectedChoices.removeAll()
                                showResult = false
                                startTime = Date()
                            }) {
                                Text("Next Question")
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.customSecondary)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.top)
                } else {
                    Text("No Questions available! Please download course")
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .onAppear {
                startTime = Date()
            }
            .onDisappear {
                saveUserTrainingData()
            }
        }
    }

    func handleChoiceSelection(_ choiceID: UUID, _ question: Question) {
        if question.multipleResponse {
            if selectedChoices.contains(choiceID) {
                selectedChoices.remove(choiceID)
            } else {
                selectedChoices.insert(choiceID)
            }
        } else {
            selectedChoices = [choiceID]
        }
    }

    func updateUserTrainingData(for question: Question) {
        if let startTime = startTime {
            userTrainingData.timeSpent += Date().timeIntervalSince(startTime)
        }

        let correctChoices = Set(question.choices.filter { $0.correct }.map { $0.id })
        let userCorrectChoices = selectedChoices.intersection(correctChoices)

        userTrainingData.correctAnswers += userCorrectChoices.count
        userTrainingData.wrongAnswers += selectedChoices.subtracting(correctChoices).count

        userTrainingData.updateStats(for: question.id, correctChoices: correctChoices, selectedChoices: selectedChoices)
    }

    func loadUserTrainingData(for course: Course) {
        if let data = UserDefaults.standard.data(forKey: course.shortName) {
            if let decodedData = try? JSONDecoder().decode(UserTrainingData.self, from: data) {
                userTrainingData = decodedData
            }
        }
    }

    func saveUserTrainingData() {
        if let data = try? JSONEncoder().encode(userTrainingData) {
            UserDefaults.standard.set(data, forKey: course.shortName)
        }
    }
}
