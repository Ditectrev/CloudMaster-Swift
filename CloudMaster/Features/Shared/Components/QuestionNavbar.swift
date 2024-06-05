import SwiftUI
struct QuestionNavbar: View {
    @Environment(\.presentationMode) var presentationMode
    let currentQuestionIndex: Int
    let totalQuestions: Int
    let question: Question
    
    @Binding var isBookmarked: Bool

    var body: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text("\(currentQuestionIndex + 1) of \(totalQuestions)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                if isBookmarked {
                    FavoritesStorage.shared.removeBookmarkByQuestionText(question.question)
                    isBookmarked = false
                } else {
                    let newBookmark = Bookmark(id: UUID(), question: question, answer: question.choices)
                    FavoritesStorage.shared.addBookmark(newBookmark)
                    isBookmarked = true
                }
            }) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}
