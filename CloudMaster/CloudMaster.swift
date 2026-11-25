import SwiftUI
import UIKit

@main
struct CloudMaster: App {
   
    @State private var favorites: Set<Course>
    @State private var isFirstStart: Bool = UserDefaults.standard.bool(forKey: "isFirstStart")

    init() {
        favorites = FavoritesStorage.shared.loadFavorites()
        configureNavigationTitleFont()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if isFirstStart {
                    HomeView(favorites: $favorites)
                } else {
                    IntroView(favorites: $favorites, isAppConfigured: $isFirstStart)
                }
            }
            .font(.brandBody(.body))
        }
    }

    private func configureNavigationTitleFont() {
        let heading = UIFont(name: BrandFont.headingFamily, size: 17) ?? .systemFont(ofSize: 17)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.titleTextAttributes = [.font: heading]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
