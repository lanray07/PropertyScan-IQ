import SwiftUI

struct InspectionCard: View {
    var inspection: Inspection
    var propertyName: String
    var issueCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(inspection.inspectionTypeLabel)
                        .font(.headline)
                    Text(propertyName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(inspection.statusLabel)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(PSITheme.subtlePanel, in: Capsule())
            }

            HStack {
                Label(inspection.date.shortReportDate, systemImage: "calendar")
                Spacer()
                Label("\(issueCount) findings", systemImage: "exclamationmark.triangle")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .psiCard()
    }
}
