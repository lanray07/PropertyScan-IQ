import Foundation
import SwiftData

@MainActor
final class ReportViewModel: ObservableObject {
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var summary = ""
    @Published var generatedPDFURL: URL?
    @Published var savedReport: Report?

    func generateSummary(
        property: Property,
        inspection: Inspection,
        rooms: [RoomArea],
        issues: [DetectedIssue],
        aiService: any AIService
    ) async {
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            summary = try await aiService.generateInspectionSummary(
                property: property,
                inspection: inspection,
                rooms: rooms,
                issues: issues
            )
            inspection.summary = summary
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveReport(inspection: Inspection, property: Property, context: ModelContext) {
        let report = Report(
            inspectionId: inspection.id,
            title: "\(property.name) \(inspection.inspectionTypeLabel)",
            summary: inspection.summary
        )
        context.insert(report)
        inspection.status = InspectionStatus.completed.rawValue

        do {
            try context.save()
            savedReport = report
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func exportPDF(report: Report, content: ReportContent, includeBranding: Bool, logoData: Data? = nil, context: ModelContext) {
        do {
            let url = try PDFReportGenerator().generatePDF(content: content, includeBranding: includeBranding, logoData: logoData)
            report.pdfLocalURL = url.path
            generatedPDFURL = url
            try context.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
