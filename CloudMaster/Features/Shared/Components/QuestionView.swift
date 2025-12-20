import Foundation
import SwiftUI

struct QuestionView: View {
    enum Mode {
        case training
        case exam
        case bookmarked
    }

    let mode: Mode
    let question: Question
    let selectedChoices: Set<UUID>?
    let isMultipleResponse: Bool
    let isResultShown: Bool?
    let onChoiceSelected: (UUID) -> Void
    
    @State private var currentImageIndex = 0
    @State private var isFullscreenImageShown = false
    @State private var selectedImageIndex = 0
    @State private var shuffledQuestion: Question?

    var body: some View {
        let displayQuestion = shuffledQuestion ?? question

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(displayQuestion.question)
                    .font(.system(size: adjustedFontSize(for: displayQuestion.question), weight: .bold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)

                QuestionImages(images: displayQuestion.images,
                               currentImageIndex: $currentImageIndex,
                               isFullscreenImageShown: $isFullscreenImageShown,
                               selectedImageIndex: $selectedImageIndex)
                    .onAppear {
                        currentImageIndex = 0 // Reset image index when question changes
                    }
                
                if isMultipleResponse {
                    VStack {
                        Text("Multiple response - Pick \(displayQuestion.responseCount)")
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

                ForEach(displayQuestion.choices) { choice in
                    if mode == .training {
                        TrainingChoice(
                            choice: choice,
                            isSelected: selectedChoices?.contains(choice.id) == true,
                            isResultShown: isResultShown ?? false,
                            onChoiceSelected: onChoiceSelected
                        )
                    } else if mode == .exam {
                        ExamChoice(
                            choice: choice,
                            isSelected: selectedChoices?.contains(choice.id) == true,
                            onChoiceSelected: onChoiceSelected
                        )
                    } else if mode == .bookmarked {
                        BookmarkedChoice(
                            choice: choice,
                            isSelected: selectedChoices?.contains(choice.id) == true
                        )
                    }
                }
            }
            .onAppear {
                shuffleCurrentQuestionChoices()
            }
            .onChange(of: question.id) { _ in
                shuffleCurrentQuestionChoices()
            }
            .padding()
        }
        .overlay(
            Group {
                if isFullscreenImageShown {
                    FullscreenImageView(images: displayQuestion.images, selectedImageIndex: $selectedImageIndex, isShown: $isFullscreenImageShown)
                }
            }
        )
    }

    private func shuffleCurrentQuestionChoices() -> Void {
        let result = getShuffledChoices(choices: question.choices, images: question.images, mode: mode)

        shuffledQuestion = Question(
            id: question.id,
            question: question.question,
            choices: result.choices,
            multipleResponse: question.multipleResponse,
            responseCount: question.responseCount,
            images: result.images
        )
    }
    
    private func getShuffledChoices(choices: [Choice], images: [ImageInfo], mode: Mode) -> (choices: [Choice], images: [ImageInfo]) {

        if(mode == .bookmarked) {
            return (choices, images); // Do not shuffle bookmarked choices
        }

        // No image available or one image available which does not belong to the choices
        if (images.count == 0 || images.count == 1) {
            var shuffledChoices = choices;
            shuffledChoices.shuffle();

            return (shuffledChoices, images);
        }

        let paired = zip(choices, images).map { ($0, $1) }
        var shuffledPairs = paired
        shuffledPairs.shuffle()

        // Separate back into choices and images
        let shuffledChoices = shuffledPairs.map { $0.0 }
        let shuffledImages = shuffledPairs.map { $0.1 }

        return (shuffledChoices, shuffledImages)
    }
    
    private func _debug(question: Question) {
        print(question)
    }

    private func adjustedFontSize(for text: String) -> CGFloat {
        let baseFontSize: CGFloat = 20
        let minFontSize: CGFloat = 14

        let lengthFactor = CGFloat(text.count) / 100.0
        let scaledFontSize = max(baseFontSize - lengthFactor, minFontSize)

        return scaledFontSize
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

struct ExamChoice: View {
    let choice: Choice
    let isSelected: Bool
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
        .background(isSelected ? Color.gray.opacity(0.3) : Color.clear)
        .cornerRadius(10)
        .padding(.horizontal)
        
        Divider()
    }
}

struct BookmarkedChoice: View {
    let choice: Choice
    let isSelected: Bool

    var body: some View {
        Text(choice.text)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
            .background(choice.correct ? Color.correct : (isSelected ? Color.wrong : Color.gray.opacity(0.3)))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
        
        Divider()
    }
}
