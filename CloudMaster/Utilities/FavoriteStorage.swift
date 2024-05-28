import Foundation

class FavoritesStorage {
    static let shared = FavoritesStorage()
    
    private let storageKey = "favorites"
    
    private init() {}
    
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
}
