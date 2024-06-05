import Foundation

struct Bookmark: Identifiable, Codable {
    let id: UUID
    let question: Question
    let answer: [Choice]
}

class FavoritesStorage {
    static let shared = FavoritesStorage()
    
    private let storageKey = "favorites"
    private let bookmarksKey = "bookmarks"
    
    
    private init() {}
    
    /**
     Course favorites Section
     */
    
    func saveFavorites(_ favorites: Set<Course>) {
        if let encoded = try? JSONEncoder().encode(Array(favorites)) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
    }
    
    func loadFavorites() -> Set<Course> {
        if let favoritesData = UserDefaults.standard.data(forKey: storageKey),
           let decodedFavorites = try? JSONDecoder().decode([Course].self, from: favoritesData) {
            return Set(decodedFavorites)
        }
        return []
    }
    
    /**
     Bookmark Section
     */

    func saveBookmarks(_ bookmarks: [Bookmark]) {
        if let encoded = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(encoded, forKey: bookmarksKey)
        } else {
            UserDefaults.standard.removeObject(forKey: bookmarksKey)
        }
    }

    func loadBookmarks() -> [Bookmark] {
        if let bookmarksData = UserDefaults.standard.data(forKey: bookmarksKey),
           let decodedBookmarks = try? JSONDecoder().decode([Bookmark].self, from: bookmarksData) {
            return decodedBookmarks
        }
        return []
    }

    func addBookmark(_ bookmark: Bookmark) {
        var bookmarks = loadBookmarks()
        guard !bookmarks.contains(where: { $0.question.question == bookmark.question.question }) else {
            return
        }
        bookmarks.append(bookmark)
        saveBookmarks(bookmarks)
    }

    func removeBookmark(_ bookmark: Bookmark) {
        var bookmarks = loadBookmarks()
        if let index = bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
            bookmarks.remove(at: index)
            saveBookmarks(bookmarks)
        }
    }

    
    /**
     This function using currently the question text for comparison, which is not perfect. As the question id is changed, this is currently the way to go.
     */
    func removeBookmarkByQuestionText(_ questionText: String) {
        var bookmarks = loadBookmarks()
        if let index = bookmarks.firstIndex(where: { $0.question.question == questionText }) {
            bookmarks.remove(at: index)
            saveBookmarks(bookmarks)
        }
    }

    func isBookmarked(_ question: Question) -> Bool {
        return loadBookmarks().contains { $0.question.question == question.question }
    }
}
