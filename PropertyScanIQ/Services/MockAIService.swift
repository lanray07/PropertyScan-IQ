import Foundation

struct MockAIService: AIService {
    private let promptPolicy = """
    You are PropertyScan IQ, an AI assistant for visual property inspection reports. Review the user's room notes and image description. Identify visible, non-diagnostic property issues only. Do not claim certainty. Do not provide regulated engineering, electrical, gas, legal, or structural certification advice. Use cautious language such as 'possible', 'visible sign of', and 'recommend professional inspection' where appropriate. Return structured findings with severity, category, explanation, and suggested next action.
    """

    func scanPropertyPhoto(_ request: PropertyScanRequest) async throws -> PropertyScanResult {
        try await Task.sleep(nanoseconds: 650_000_000)

        let roomName = request.room.lowercased()
        let notes = request.userNotes.lowercased()
        let issue: DetectedIssueDraft

        if roomName.contains("bath") || notes.contains("damp") || notes.contains("mould") {
            issue = DetectedIssueDraft(
                title: "Possible moisture staining",
                description: "Visible marks may indicate damp or mould staining. This is a visual suggestion and should be verified before relying on the report.",
                category: IssueCategory.dampMould.rawValue,
                severity: IssueSeverity.high.rawValue,
                confidence: 0.76,
                suggestedAction: "Check ventilation, photograph close-ups, and recommend inspection by a qualified damp specialist if persistent."
            )
        } else if roomName.contains("roof") || roomName.contains("exterior") {
            issue = DetectedIssueDraft(
                title: "Possible roofline or gutter concern",
                description: "The image may show a visible roofline or gutter irregularity. AI cannot confirm structural condition.",
                category: IssueCategory.roofGutterVisibleConcern.rawValue,
                severity: IssueSeverity.medium.rawValue,
                confidence: 0.63,
                suggestedAction: "Record the location and recommend a contractor or surveyor review if water ingress or loose fittings are suspected."
            )
        } else if notes.contains("crack") {
            issue = DetectedIssueDraft(
                title: "Visible crack noted",
                description: "A visible crack is referenced in the notes. Severity depends on size, movement, and location, which AI cannot certify.",
                category: IssueCategory.cracks.rawValue,
                severity: IssueSeverity.medium.rawValue,
                confidence: 0.70,
                suggestedAction: "Measure and monitor the crack; recommend professional inspection if widening, stepped, or near structural elements."
            )
        } else {
            issue = DetectedIssueDraft(
                title: "General visible wear",
                description: "The room appears to have possible general wear or cosmetic marking that may be useful to include in the inspection evidence.",
                category: IssueCategory.generalWear.rawValue,
                severity: IssueSeverity.low.rawValue,
                confidence: 0.58,
                suggestedAction: "Keep photo evidence, add location notes, and verify whether repair or cleaning is needed."
            )
        }

        return PropertyScanResult(
            issues: [issue],
            summary: "Mock AI scan completed using cautious visual-only property inspection logic. Policy: \(promptPolicy.prefix(90))..."
        )
    }

    func generateInspectionSummary(property: Property, inspection: Inspection, rooms: [RoomArea], issues: [DetectedIssue]) async throws -> String {
        try await Task.sleep(nanoseconds: 350_000_000)
        let urgentCount = issues.filter { $0.severityValue == .urgent }.count
        let highCount = issues.filter { $0.severityValue == .high }.count
        return "\(property.name) was reviewed as a \(inspection.inspectionTypeLabel.lowercased()). \(rooms.count) rooms or areas were included. \(issues.count) visible findings were recorded, including \(urgentCount) urgent and \(highCount) high-priority items. All AI findings require user review and qualified professional follow-up where appropriate."
    }

    func generateRecommendedActions(issues: [DetectedIssue]) async throws -> [String] {
        let sorted = issues.sorted { $0.severityValue > $1.severityValue }
        let actions = sorted.prefix(8).map { "\($0.severityValue.displayName): \($0.suggestedAction)" }
        return actions.isEmpty ? ["No approved issues yet. Continue adding room evidence and review AI findings."] : actions
    }

    func generatePDFReportText(content: ReportContent) async throws -> String {
        """
        \(content.title)
        Generated \(content.generatedAt.shortReportDate)

        Property: \(content.property.name)
        Address: \(content.property.address)
        Inspection: \(content.inspection.inspectionTypeLabel)

        Summary:
        \(content.inspection.summary)

        Disclaimer:
        \(ReportContentBuilder.safetyDisclaimer)
        """
    }
}
