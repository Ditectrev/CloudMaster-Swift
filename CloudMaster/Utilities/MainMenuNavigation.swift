import Combine
import Foundation

/// Identity of the home navigation stack. Replacing it returns the app to the course list.
final class MainMenuNavigation: ObservableObject {
    /// The exam result screen and the home screen have to share one object.
    /// The result view sits several links deep, and a separate environment default
    /// never reaches the id that resets this stack.
    static let shared = MainMenuNavigation()

    @Published private(set) var resetID = UUID()

    func returnToMainMenu() {
        resetID = UUID()
    }

    static func returnToMainMenuFromExamResult() {
        shared.returnToMainMenu()
    }
}
