import SwiftUI

struct TrainingView: View {
    @State private var currentQuestionIndex = 0
    @State private var selectedChoices: Set<UUID> = []
    @State private var showResult = false
    @State private var userTrainingData = UserTrainingStore.shared.trainingData
    @State private var startTime: Date?
    @State private var isBookmarked: Bool = false
    @Environment(\.presentationMode) var presentationMode

    let course: Course
    @StateObject private var questionLoader: QuestionLoader

    init(course: Course) {
        self.course = course
        _questionLoader = StateObject(wrappedValue: QuestionLoader(filename: course.shortName + ".json", intelligentLearning: false))
    }

    var body: some View {
        ZStack {
            VStack {
                if !questionLoader.questions.isEmpty {
                    let questions = Array(questionLoader.questions)
                    let totalQuestions = questions.count
                    let question = questions[currentQuestionIndex]

                    QuestionNavbar(
                        currentQuestionIndex: currentQuestionIndex,
                        totalQuestions: questionLoader.questions.count,
                        question: question,
                        isBookmarked: $isBookmarked
                    )
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
                    .navigationBarItems(trailing: bookmarkButton)
                    .onAppear {
                        updateBookmarkState()
                    }

                    HStack(spacing: 20) {
                        if !showResult {
                            if currentQuestionIndex > 0 {
                                Button(action: {
                                    showPreviousQuestion()
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
                                showNextQuestion()
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
                updateBookmarkState() // Ensure bookmark state is updated when the view appears
            }
            .onDisappear {
                saveUserTrainingData()
            }
        }
    }

    private var bookmarkButton: some View {
        Button(action: {
            toggleBookmark()
        }) {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                .foregroundColor(isBookmarked ? .red : .blue)
        }
    }

    private func showNextQuestion() {
        if currentQuestionIndex < questionLoader.questions.count - 1 {
            currentQuestionIndex += 1
            selectedChoices.removeAll()
            showResult = false
            startTime = Date()
            updateBookmarkState() // Update the bookmark state for the next question
        }
    }

    private func showPreviousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            selectedChoices.removeAll()
            showResult = false
            startTime = Date()
            updateBookmarkState() // Update the bookmark state for the previous question
        }
    }

    private func updateBookmarkState() {
        let currentQuestion = questionLoader.questions[currentQuestionIndex]
        isBookmarked = FavoritesStorage.shared.isBookmarked(currentQuestion)
    }

    private func toggleBookmark() {
        let currentQuestion = questionLoader.questions[currentQuestionIndex]
        if isBookmarked {
            FavoritesStorage.shared.removeBookmarkByQuestionText(currentQuestion.question)
        } else {
            let newBookmark = Bookmark(id: UUID(), question: currentQuestion, answer: currentQuestion.choices)
            FavoritesStorage.shared.addBookmark(newBookmark)
        }
        isBookmarked.toggle()
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
