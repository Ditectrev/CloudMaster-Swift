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
        VStack {
            if !questionLoader.questions.isEmpty {
                let questions = Array(questionLoader.questions)
                let totalQuestions = questions.count

                // Progress Header
                HStack {
                    Spacer()
                    Text("\(currentQuestionIndex + 1) of \(totalQuestions)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.top)

                let question = questions[currentQuestionIndex]

                TrainingQuestion(
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
                           } else {
                               Spacer()
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
                       }  else {
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
        .navigationBarBackButtonHidden(false)
        .onAppear {
            startTime = Date()
        }
        .onDisappear {
            saveUserTrainingData()
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
        // Update the time spent
        if let startTime = startTime {
            userTrainingData.timeSpent += Date().timeIntervalSince(startTime)
        }

        // Update correct and wrong answers
        let correctChoices = Set(question.choices.filter { $0.correct }.map { $0.id })
        let userCorrectChoices = selectedChoices.intersection(correctChoices)

        userTrainingData.correctAnswers += userCorrectChoices.count
        userTrainingData.wrongAnswers += selectedChoices.subtracting(correctChoices).count

        // Update question stats
        userTrainingData.updateStats(for: question.id, correctChoices: correctChoices, selectedChoices: selectedChoices)
    }

    func loadUserTrainingData(for course: Course) {
        // Load the user training data for the specific course
        if let data = UserDefaults.standard.data(forKey: course.shortName) {
            if let decodedData = try? JSONDecoder().decode(UserTrainingData.self, from: data) {
                userTrainingData = decodedData
            }
        }
    }

    func saveUserTrainingData() {
        // Save the user training data for the specific course
        if let data = try? JSONEncoder().encode(userTrainingData) {
            UserDefaults.standard.set(data, forKey: course.shortName)
        }
    }
}

struct TrainingQuestion: View {
    let question: Question
    let selectedChoices: Set<UUID>
    let isMultipleResponse: Bool
    let isResultShown: Bool
    let onChoiceSelected: (UUID) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(question.question)
                    .font(.system(size: adjustedFontSize(for: question.question), weight: .bold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(nil)
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
                    TrainingChoice(
                        choice: choice,
                        isSelected: selectedChoices.contains(choice.id),
                        isResultShown: isResultShown,
                        onChoiceSelected: onChoiceSelected
                    )
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
        _ = UIScreen.main.bounds.width - 32
        let fontSize = max(min(text.count / 80, 24), 14)
        return CGFloat(fontSize)
    }
}

struct TrainingChoice: View {
    let choice: Choice
    let isSelected: Bool
    let isResultShown: Bool
    let onChoiceSelected: (UUID) -> Void

    var body: some View {
        Button(action: {
            onChoiceSelected(choice.id)
        }) {
            Text(choice.text)
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
        }
        .background(getChoiceBackgroundColor())
        .foregroundColor(getChoiceTextColor())
        .cornerRadius(10)
        .padding(.horizontal)
        .disabled(isResultShown)
        
        Divider()
    }

    private func getChoiceBackgroundColor() -> Color {
        if isResultShown {
            if choice.correct {
                return Color.correct
            } else if isSelected {
                return Color.wrong
            }
        } else if isSelected {
            return Color.gray.opacity(0.3)
        }
        return Color.clear
    }

    private func getChoiceTextColor() -> Color {
        if isResultShown && choice.correct {
            return .white
        } else {
            return .primary
        }
    }
}
