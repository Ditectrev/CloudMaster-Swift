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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(question.question)
                    .font(.system(size: adjustedFontSize(for: question.question), weight: .bold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)

                QuestionImages(images: question.images,
                               currentImageIndex: $currentImageIndex,
                               isFullscreenImageShown: $isFullscreenImageShown,
                               selectedImageIndex: $selectedImageIndex)
                    .onAppear {
                        currentImageIndex = 0 // Reset image index when question changes
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
            .padding()
        }
        .overlay(
            Group {
                if isFullscreenImageShown {
                    FullscreenImageView(images: question.images, selectedImageIndex: $selectedImageIndex, isShown: $isFullscreenImageShown)
                }
            }
        )
    }

    private func adjustedFontSize(for text: String) -> CGFloat {
        let maxWidth = UIScreen.main.bounds.width - 32
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
        .foregroundColor(.white)
        
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
