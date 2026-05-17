import SwiftData
import SwiftUI

struct IssueCard: View {
    @Bindable var issue: DetectedIssue

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    TextField("Issue title", text: $issue.title)
                        .font(.headline)
                    Text(issue.categoryLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                SeverityBadge(severity: issue.severityValue)
            }

            TextEditor(text: $issue.issueDescription)
                .font(.subheadline)
                .frame(minHeight: 74)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(PSITheme.subtlePanel, in: RoundedRectangle(cornerRadius: PSITheme.compactRadius))

            Picker("Severity", selection: $issue.severity) {
                ForEach(IssueSeverity.allCases) { severity in
                    Text(severity.displayName).tag(severity.rawValue)
                }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 6) {
                Text("Suggested next action")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                TextField("Suggested action", text: $issue.suggestedAction, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Label("\(Int(issue.confidence * 100))% confidence", systemImage: "gauge.with.dots.needle.67percent")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Toggle("Approved", isOn: $issue.userApproved)
                    .toggleStyle(.switch)
                    .font(.subheadline.weight(.semibold))
            }

            if issue.category == IssueCategory.electricalVisibleConcern.rawValue ||
                issue.category == IssueCategory.safetyHazard.rawValue ||
                issue.category == IssueCategory.roofGutterVisibleConcern.rawValue ||
                issue.severity == IssueSeverity.urgent.rawValue {
                Label("Qualified professional review recommended.", systemImage: "checkmark.seal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .psiCard()
    }
}
