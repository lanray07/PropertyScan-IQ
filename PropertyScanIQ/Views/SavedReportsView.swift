import SwiftData
import SwiftUI

private enum ReportDateFilter: String, CaseIterable, Identifiable {
    case all
    case last30
    case last90

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: "All"
        case .last30: "30 days"
        case .last90: "90 days"
        }
    }

    var cutoff: Date? {
        switch self {
        case .all:
            nil
        case .last30:
            Calendar.current.date(byAdding: .day, value: -30, to: Date())
        case .last90:
            Calendar.current.date(byAdding: .day, value: -90, to: Date())
        }
    }
}

struct SavedReportsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Report.createdAt, order: .reverse) private var reports: [Report]
    @Query private var inspections: [Inspection]
    @Query private var properties: [Property]
    @Query private var rooms: [RoomArea]
    @Query private var issues: [DetectedIssue]

    @State private var searchText = ""
    @State private var severityFilter: IssueSeverity?
    @State private var dateFilter: ReportDateFilter = .all

    private var filteredReports: [Report] {
        reports.filter { report in
            let propertyName = property(for: report)?.name ?? ""
            let matchesSearch = searchText.isEmpty ||
                report.title.localizedCaseInsensitiveContains(searchText) ||
                propertyName.localizedCaseInsensitiveContains(searchText)

            let matchesDate: Bool
            if let cutoff = dateFilter.cutoff {
                matchesDate = report.createdAt >= cutoff
            } else {
                matchesDate = true
            }

            let matchesSeverity: Bool
            if let severityFilter {
                matchesSeverity = issuesForReport(report).contains { $0.severityValue == severityFilter }
            } else {
                matchesSeverity = true
            }

            return matchesSearch && matchesDate && matchesSeverity
        }
    }

    var body: some View {
        List {
            Section {
                Picker("Date", selection: $dateFilter) {
                    ForEach(ReportDateFilter.allCases) { filter in
                        Text(filter.displayName).tag(filter)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Severity", selection: $severityFilter) {
                    Text("Any").tag(Optional<IssueSeverity>.none)
                    ForEach(IssueSeverity.allCases) { severity in
                        Text(severity.displayName).tag(Optional(severity))
                    }
                }
            }

            Section("Reports") {
                if filteredReports.isEmpty {
                    EmptyStateView(systemImage: "doc.text.magnifyingglass", title: "No matching reports", message: "Try changing the search, date, or severity filter.")
                        .listRowInsets(EdgeInsets())
                } else {
                    ForEach(filteredReports) { report in
                        reportRow(report)
                    }
                }
            }
        }
        .navigationTitle("Saved Reports")
        .searchable(text: $searchText, prompt: "Search by property or report")
    }

    private func reportRow(_ report: Report) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink(value: AppRoute.pdfExport(report.id)) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(report.title)
                        .font(.headline)
                    Text("\(property(for: report)?.name ?? "Unknown property") - \(report.createdAt.shortReportDate)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if !report.summary.isEmpty {
                        Text(report.summary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }

            HStack {
                severityStrip(for: report)
                Spacer()
                Button {
                    duplicateInspection(from: report)
                } label: {
                    Label("Duplicate", systemImage: "plus.square.on.square")
                }
                .buttonStyle(.bordered)
                .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }

    private func severityStrip(for report: Report) -> some View {
        HStack(spacing: 5) {
            ForEach(IssueSeverity.allCases.reversed(), id: \.self) { severity in
                let count = issuesForReport(report).filter { $0.severityValue == severity }.count
                if count > 0 {
                    Text("\(severity.displayName) \(count)")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .foregroundStyle(.white)
                        .background(PSITheme.severityColor(severity), in: Capsule())
                }
            }
        }
    }

    private func inspection(for report: Report) -> Inspection? {
        inspections.first { $0.id == report.inspectionId }
    }

    private func property(for report: Report) -> Property? {
        guard let inspection = inspection(for: report) else { return nil }
        return properties.first { $0.id == inspection.propertyId }
    }

    private func issuesForReport(_ report: Report) -> [DetectedIssue] {
        guard let inspection = inspection(for: report) else { return [] }
        let reportRoomIDs = Set(rooms.filter { $0.inspectionId == inspection.id }.map(\.id))
        return issues.filter { reportRoomIDs.contains($0.roomAreaId) }
    }

    private func duplicateInspection(from report: Report) {
        guard let original = inspection(for: report) else { return }
        let copy = Inspection(
            propertyId: original.propertyId,
            inspectionType: original.inspectionType,
            status: InspectionStatus.draft.rawValue,
            summary: ""
        )
        modelContext.insert(copy)

        for room in rooms.filter({ $0.inspectionId == original.id }) {
            modelContext.insert(
                RoomArea(
                    inspectionId: copy.id,
                    name: room.name,
                    condition: RoomCondition.good.rawValue,
                    notes: ""
                )
            )
        }

        try? modelContext.save()
    }
}
