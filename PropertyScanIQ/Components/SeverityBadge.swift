import SwiftUI

struct SeverityBadge: View {
    var severity: IssueSeverity

    var body: some View {
        Text(severity.displayName)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .foregroundStyle(.white)
            .background(PSITheme.severityColor(severity), in: Capsule())
            .accessibilityLabel("Severity \(severity.displayName)")
    }
}

struct ConditionBadge: View {
    var condition: RoomCondition

    var body: some View {
        Text(condition.displayName)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .foregroundStyle(.white)
            .background(PSITheme.conditionColor(condition), in: Capsule())
    }
}
