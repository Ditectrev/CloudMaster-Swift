import SwiftUI

@main
struct CloudMaster: App {
   
    @State private var favorites: Set<Course>
    @State private var isFirstStart: Bool = UserDefaults.standard.bool(forKey: "isFirstStart")

    init() {
        favorites = FavoritesStorage.shared.loadFavorites()
    }

    var body: some Scene {
        WindowGroup {
            if isFirstStart {
                HomeView(favorites: $favorites)
            } else {
                IntroView(favorites: $favorites, isAppConfigured: $isFirstStart)
                    .onAppear {
                        UserDefaults.standard.set(true, forKey: "isFirstStart")
                    }
            }
        }
    }
}
