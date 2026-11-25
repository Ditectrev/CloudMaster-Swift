import Foundation

/// Typefaces used by the Ditectrev blog, shop, and exams sites.
/// Headings and buttons are Philosopher. Body text is Lora.
enum BrandFont {
    static let headingFamily = "Philosopher"
    static let bodyFamily = "Lora"

    static let resourceFiles = [
        "Philosopher-Regular.ttf",
        "Philosopher-Bold.ttf",
        "Lora-Variable.ttf",
    ]

    static func family(for role: Role) -> String {
        switch role {
        case .heading, .button:
            return headingFamily
        case .body:
            return bodyFamily
        }
    }

    enum Role {
        case heading
        case button
        case body
    }
}
