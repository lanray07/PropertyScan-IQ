import Foundation

struct ReportContent {
    var title: String
    var property: Property
    var inspection: Inspection
    var rooms: [RoomArea]
    var issues: [DetectedIssue]
    var photosByRoom: [UUID: [InspectionPhoto]]
    var generatedAt: Date
    var clientNotes: String

    var severityBreakdown: [(IssueSeverity, Int)] {
        IssueSeverity.allCases.map { severity in
            (severity, issues.filter { $0.severityValue == severity }.count)
        }
    }

    var priorityIssues: [DetectedIssue] {
        issues.sorted { lhs, rhs in
            if lhs.severityValue == rhs.severityValue {
                return lhs.confidence > rhs.confidence
            }
            return lhs.severityValue > rhs.severityValue
        }
    }
}

enum ReportContentBuilder {
    static func build(
        reportTitle: String? = nil,
        property: Property,
        inspection: Inspection,
        rooms: [RoomArea],
        photos: [InspectionPhoto],
        issues: [DetectedIssue],
        approvedOnly: Bool = true
    ) -> ReportContent {
        let reportIssues = approvedOnly ? issues.filter(\.userApproved) : issues
        let finalIssues = reportIssues.isEmpty ? issues : reportIssues
        let title = reportTitle ?? "\(property.name) Inspection Report"

        return ReportContent(
            title: title,
            property: property,
            inspection: inspection,
            rooms: rooms.sorted { $0.name < $1.name },
            issues: finalIssues,
            photosByRoom: Dictionary(grouping: photos, by: \.roomAreaId),
            generatedAt: Date(),
            clientNotes: property.notes
        )
    }

    static let safetyDisclaimer = """
    PropertyScan IQ provides visual suggestions only. This report is not a certified property survey, legal advice, electrical certification, gas safety certification, or structural engineering advice. AI findings must be reviewed by the user before relying on them. Urgent safety concerns should be checked by qualified professionals.
    """
}
