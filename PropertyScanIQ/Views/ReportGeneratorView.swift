import SwiftData
import SwiftUI

struct ReportGeneratorView: View {
    var property: Property
    var inspection: Inspection

    @Environment(\.modelContext) private var modelContext
    @Environment(\.aiService) private var aiService
    @Query(sort: \RoomArea.name) private var allRooms: [RoomArea]
    @Query(sort: \InspectionPhoto.createdAt, order: .reverse) private var allPhotos: [InspectionPhoto]
    @Query(sort: \DetectedIssue.createdAt, order: .reverse) private var allIssues: [DetectedIssue]
    @Query(sort: \Report.createdAt, order: .reverse) private var reports: [Report]

    @StateObject private var viewModel = ReportViewModel()

    private var rooms: [RoomArea] {
        allRooms.filter { $0.inspectionId == inspection.id }
    }

    private var roomIDs: Set<UUID> {
        Set(rooms.map(\.id))
    }

    private var photos: [InspectionPhoto] {
        allPhotos.filter { roomIDs.contains($0.roomAreaId) }
    }

    private var issues: [DetectedIssue] {
        allIssues.filter { roomIDs.contains($0.roomAreaId) }
    }

    private var existingReport: Report? {
        reports.first { $0.inspectionId == inspection.id }
    }

    private var content: ReportContent {
        ReportContentBuilder.build(
            reportTitle: existingReport?.title,
            property: property,
            inspection: inspection,
            rooms: rooms,
            photos: photos,
            issues: issues
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                summaryControls

                ReportPreviewView(content: content, includeBranding: true)

                if let error = viewModel.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }

                if let report = viewModel.savedReport ?? existingReport {
                    NavigationLink(value: AppRoute.pdfExport(report.id)) {
                        Label("Open PDF export", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .padding()
        }
        .navigationTitle("Report Generator")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summaryControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(property.name)
                        .font(.headline)
                    Text("\(rooms.count) rooms, \(issues.count) findings")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Button {
                Task {
                    await viewModel.generateSummary(
                        property: property,
                        inspection: inspection,
                        rooms: rooms,
                        issues: issues,
                        aiService: aiService
                    )
                    try? modelContext.save()
                }
            } label: {
                if viewModel.isGenerating {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Label("Generate inspection summary", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isGenerating)

            Button {
                viewModel.saveReport(inspection: inspection, property: property, context: modelContext)
            } label: {
                Label(existingReport == nil ? "Save report locally" : "Save another report", systemImage: "tray.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .psiCard()
    }
}
