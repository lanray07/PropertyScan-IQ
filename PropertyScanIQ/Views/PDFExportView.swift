import SwiftData
import SwiftUI
import UIKit

struct PDFExportView: View {
    @Bindable var report: Report

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @AppStorage("companyLogoData") private var companyLogoData = Data()
    @Query private var properties: [Property]
    @Query private var inspections: [Inspection]
    @Query(sort: \RoomArea.name) private var rooms: [RoomArea]
    @Query(sort: \InspectionPhoto.createdAt, order: .reverse) private var photos: [InspectionPhoto]
    @Query(sort: \DetectedIssue.createdAt, order: .reverse) private var issues: [DetectedIssue]

    @StateObject private var viewModel = ReportViewModel()
    @State private var copied = false
    @State private var includeBranding = true

    private var inspection: Inspection? {
        inspections.first { $0.id == report.inspectionId }
    }

    private var property: Property? {
        guard let inspection else { return nil }
        return properties.first { $0.id == inspection.propertyId }
    }

    private var reportRooms: [RoomArea] {
        guard let inspection else { return [] }
        return rooms.filter { $0.inspectionId == inspection.id }
    }

    private var roomIDs: Set<UUID> {
        Set(reportRooms.map(\.id))
    }

    private var reportPhotos: [InspectionPhoto] {
        photos.filter { roomIDs.contains($0.roomAreaId) }
    }

    private var reportIssues: [DetectedIssue] {
        issues.filter { roomIDs.contains($0.roomAreaId) }
    }

    private var content: ReportContent? {
        guard let property, let inspection else { return nil }
        return ReportContentBuilder.build(
            reportTitle: report.title,
            property: property,
            inspection: inspection,
            rooms: reportRooms,
            photos: reportPhotos,
            issues: reportIssues
        )
    }

    private var pdfURL: URL? {
        viewModel.generatedPDFURL ?? report.pdfURL
    }

    var body: some View {
        Group {
            if let content {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        exportControls(content: content)
                        ReportPreviewView(content: content, includeBranding: includeBranding)
                    }
                    .padding()
                }
            } else {
                EmptyStateView(systemImage: "doc.badge.gearshape", title: "Report unavailable", message: "The linked inspection or property could not be found.")
                    .padding()
            }
        }
        .navigationTitle("PDF Export")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func exportControls(content: ReportContent) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Export options")
                        .font(.headline)
                    Text(pdfURL == nil ? "Generate a PDF before sharing." : "PDF ready to share.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Toggle("Custom logo and branding", isOn: $includeBranding)
                .disabled(!subscriptionManager.canUseProFeatures)
            if !subscriptionManager.canUseProFeatures {
                NavigationLink(value: AppRoute.paywall) {
                    Label("Unlock custom branding with Pro", systemImage: "lock")
                }
                .buttonStyle(.bordered)
            }

            Button {
                viewModel.exportPDF(
                    report: report,
                    content: content,
                    includeBranding: includeBranding && subscriptionManager.canUseProFeatures,
                    logoData: includeBranding && subscriptionManager.canUseProFeatures && !companyLogoData.isEmpty ? companyLogoData : nil,
                    context: modelContext
                )
            } label: {
                Label("Export PDF", systemImage: "doc.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            if let pdfURL {
                ShareLink(item: pdfURL) {
                    Label("Share PDF", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            Button {
                UIPasteboard.general.string = plainText(content: content)
                copied = true
            } label: {
                Label(copied ? "Copied report text" : "Copy report text", systemImage: "doc.on.doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            if let error = viewModel.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle")
                    .font(.subheadline)
                    .foregroundStyle(.red)
            }
        }
        .psiCard()
    }

    private func plainText(content: ReportContent) -> String {
        let findings = content.priorityIssues.map {
            "\($0.severityValue.displayName): \($0.title) - \($0.suggestedAction)"
        }.joined(separator: "\n")

        return """
        \(content.title)
        \(content.property.name)
        \(content.property.address)

        \(content.inspection.summary)

        Findings:
        \(findings)

        \(ReportContentBuilder.safetyDisclaimer)
        """
    }
}
