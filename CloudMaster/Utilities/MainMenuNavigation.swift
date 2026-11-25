import Combine
import Foundation

/// Identity of the home navigation stack. Replacing it returns the app to the main menu.
final class MainMenuNavigation: ObservableObject {
    @Published private(set) var resetID = UUID()

    func returnToMainMenu() {
        resetID = UUID()
    }
}
