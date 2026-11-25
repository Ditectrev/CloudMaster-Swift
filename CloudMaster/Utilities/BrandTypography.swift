import SwiftUI

extension Font {
    static func brandHeading(_ style: Font.TextStyle) -> Font {
        customBrand(BrandFont.headingFamily, style: style)
    }

    static func brandBody(_ style: Font.TextStyle) -> Font {
        customBrand(BrandFont.bodyFamily, style: style)
    }

    static func brandHeading(size: CGFloat, relativeTo style: Font.TextStyle = .title) -> Font {
        .custom(BrandFont.headingFamily, size: size, relativeTo: style)
    }

    static func brandBody(size: CGFloat, weight: Font.Weight = .regular, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom(BrandFont.bodyFamily, size: size, relativeTo: style).weight(weight)
    }

    private static func customBrand(_ family: String, style: Font.TextStyle) -> Font {
        .custom(family, size: pointSize(for: style), relativeTo: style)
    }

    private static func pointSize(for style: Font.TextStyle) -> CGFloat {
        switch style {
        case .largeTitle:
            return 34
        case .title:
            return 28
        case .title2:
            return 22
        case .title3:
            return 20
        case .headline, .body:
            return 17
        case .callout:
            return 16
        case .subheadline:
            return 15
        case .footnote:
            return 13
        case .caption:
            return 12
        case .caption2:
            return 11
        @unknown default:
            return 17
        }
    }
}
