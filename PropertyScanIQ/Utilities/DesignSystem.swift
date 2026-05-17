import SwiftUI

enum PSITheme {
    static let radius: CGFloat = 8
    static let compactRadius: CGFloat = 6
    static let pagePadding: CGFloat = 16

    static let accent = Color(red: 0.05, green: 0.56, blue: 0.65)
    static let secondaryAccent = Color(red: 0.10, green: 0.42, blue: 0.36)
    static let charcoal = Color(red: 0.10, green: 0.11, blue: 0.13)
    static let panel = Color(uiColor: .secondarySystemBackground)
    static let subtlePanel = Color(uiColor: .tertiarySystemBackground)

    static func severityColor(_ severity: IssueSeverity) -> Color {
        switch severity {
        case .low: Color(red: 0.12, green: 0.48, blue: 0.36)
        case .medium: Color(red: 0.68, green: 0.45, blue: 0.08)
        case .high: Color(red: 0.78, green: 0.24, blue: 0.11)
        case .urgent: Color(red: 0.70, green: 0.06, blue: 0.16)
        }
    }

    static func conditionColor(_ condition: RoomCondition) -> Color {
        switch condition {
        case .excellent: Color(red: 0.11, green: 0.50, blue: 0.36)
        case .good: accent
        case .fair: Color(red: 0.67, green: 0.47, blue: 0.12)
        case .poor: Color(red: 0.78, green: 0.30, blue: 0.12)
        case .urgent: Color(red: 0.70, green: 0.06, blue: 0.16)
        }
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(PSITheme.panel, in: RoundedRectangle(cornerRadius: PSITheme.radius, style: .continuous))
    }
}

extension View {
    func psiCard() -> some View {
        modifier(CardModifier())
    }
}

extension Date {
    var shortReportDate: String {
        formatted(.dateTime.day().month(.abbreviated).year())
    }
}
