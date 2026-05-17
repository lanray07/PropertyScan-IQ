import SwiftUI
import UIKit

struct ReportPreviewView: View {
    var content: ReportContent
    var includeBranding: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text(includeBranding ? "PropertyScan IQ" : "PropertyScan IQ Basic Report")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(PSITheme.accent)
                Text(content.title)
                    .font(.title.bold())
                Text("Generated \(content.generatedAt.shortReportDate)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            reportSection("Property overview") {
                Label(content.property.name, systemImage: "building.2")
                Label(content.property.address, systemImage: "mappin.and.ellipse")
                Label(content.property.propertyTypeLabel, systemImage: "house")
                Label(content.property.clientName.isEmpty ? "Client not specified" : content.property.clientName, systemImage: "person")
            }

            reportSection("Inspection summary") {
                Text(content.inspection.summary.isEmpty ? "No generated summary yet." : content.inspection.summary)
                    .font(.subheadline)
            }

            reportSection("Severity breakdown") {
                HStack {
                    ForEach(content.severityBreakdown, id: \.0) { severity, count in
                        VStack(spacing: 4) {
                            SeverityBadge(severity: severity)
                            Text("\(count)")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }

            reportSection("Room-by-room findings") {
                ForEach(content.rooms) { room in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(room.name)
                                .font(.headline)
                            Spacer()
                            ConditionBadge(condition: RoomCondition(rawValue: room.condition) ?? .good)
                        }

                        if !room.notes.isEmpty {
                            Text(room.notes)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        let roomIssues = content.issues.filter { $0.roomAreaId == room.id }
                        if roomIssues.isEmpty {
                            Text("No approved findings for this area.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(roomIssues) { issue in
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text(issue.title)
                                            .font(.subheadline.weight(.semibold))
                                        Spacer()
                                        SeverityBadge(severity: issue.severityValue)
                                    }
                                    Text(issue.issueDescription)
                                        .font(.caption)
                                    Text("Action: \(issue.suggestedAction)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(10)
                                .background(PSITheme.subtlePanel, in: RoundedRectangle(cornerRadius: PSITheme.radius))
                            }
                        }

                        if let photos = content.photosByRoom[room.id], !photos.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(photos) { photo in
                                        thumbnail(photo)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }

            reportSection("Recommended next actions") {
                if content.priorityIssues.isEmpty {
                    Text("No maintenance priority list is available yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(content.priorityIssues.prefix(10)) { issue in
                        Label(issue.suggestedAction, systemImage: "checklist.checked")
                            .font(.subheadline)
                    }
                }
            }

            reportSection("Client notes") {
                Text(content.clientNotes.isEmpty ? "No client notes added." : content.clientNotes)
                    .font(.subheadline)
                    .foregroundStyle(content.clientNotes.isEmpty ? .secondary : .primary)
            }

            reportSection("AI disclaimer") {
                Text(ReportContentBuilder.safetyDisclaimer)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            reportSection("Inspector/user signature") {
                RoundedRectangle(cornerRadius: 2)
                    .frame(height: 1)
                    .foregroundStyle(.secondary)
                    .padding(.top, 32)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground), in: RoundedRectangle(cornerRadius: PSITheme.radius))
    }

    private func reportSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            content()
        }
    }

    @ViewBuilder
    private func thumbnail(_ photo: InspectionPhoto) -> some View {
        if let data = photo.imageData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 132, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: PSITheme.radius))
        }
    }
}
