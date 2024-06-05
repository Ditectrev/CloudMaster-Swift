import SwiftUI

struct BookmarksView: View {
    @State private var bookmarks: [Bookmark] = []
    
    var body: some View {
        NavigationView {
            
            if bookmarks.isEmpty {
                VStack {
                    Image(systemName: "bookmark")
                        .resizable()
                        .frame(width: 80, height: 100)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                    Text("No questions saved")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(bookmarks) { bookmark in
                        NavigationLink(destination: QuestionDetailView(question: bookmark.question, bookmarks: $bookmarks)) {
                            VStack(alignment: .leading) {
                                Text(bookmark.question.question.prefix(40) + "...")
                                    .font(.headline)
                                    .lineLimit(2)
                                    .padding(.vertical,5)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Bookmarks")
        .onAppear {
            bookmarks = FavoritesStorage.shared.loadBookmarks()
        }
    }
}

struct QuestionDetailView: View {
    let question: Question
    @Binding var bookmarks: [Bookmark]
    @State private var isBookmarked: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        QuestionView(
            mode: .bookmarked,
            question: question,
            selectedChoices: nil,
            isMultipleResponse: question.multipleResponse,
            isResultShown: true,
            onChoiceSelected: { _ in }
        )
        .navigationTitle("Question")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: bookmarkButton)
        .onAppear {
            isBookmarked = FavoritesStorage.shared.isBookmarked(question)
        }
    }

    private var bookmarkButton: some View {
        Button(action: {
            toggleBookmark()
        }) {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")

        }
    }

    private func toggleBookmark() {
        if isBookmarked {
            FavoritesStorage.shared.removeBookmarkByQuestionText(question.question)
            bookmarks = FavoritesStorage.shared.loadBookmarks()
            presentationMode.wrappedValue.dismiss()
        } else {
            let newBookmark = Bookmark(id: UUID(), question: question, answer: question.choices)
            FavoritesStorage.shared.addBookmark(newBookmark)
            bookmarks = FavoritesStorage.shared.loadBookmarks()
        }
        isBookmarked.toggle()
    }
}
