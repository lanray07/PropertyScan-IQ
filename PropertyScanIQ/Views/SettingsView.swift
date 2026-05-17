import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    @Query private var properties: [Property]
    @Query private var inspections: [Inspection]
    @Query private var rooms: [RoomArea]
    @Query private var photos: [InspectionPhoto]
    @Query private var issues: [DetectedIssue]
    @Query private var reports: [Report]
    @Query private var subscriptionStates: [SubscriptionState]

    @AppStorage("businessName") private var businessName = ""
    @AppStorage("businessEmail") private var businessEmail = ""
    @AppStorage("reportFooter") private var reportFooter = "Generated with PropertyScan IQ"
    @AppStorage("companyLogoData") private var companyLogoData = Data()

    @State private var showingDeleteAlert = false
    @State private var exportURL: URL?
    @State private var selectedLogoItem: PhotosPickerItem?

    var body: some View {
        List {
            Section("Subscription") {
                HStack {
                    Label(subscriptionManager.planLabel, systemImage: "creditcard")
                    Spacer()
                    if subscriptionManager.canUseProFeatures {
                        Text("Active")
                            .foregroundStyle(.green)
                    } else {
                        Text("Free")
                            .foregroundStyle(.secondary)
                    }
                }
                NavigationLink(value: AppRoute.paywall) {
                    Label("Manage subscription", systemImage: "arrow.up.circle")
                }
            }

            Section("Business profile") {
                TextField("Business name", text: $businessName)
                TextField("Business email", text: $businessEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }

            Section("Report branding") {
                TextField("Report footer", text: $reportFooter, axis: .vertical)
                PhotosPicker(selection: $selectedLogoItem, matching: .images) {
                    Label(companyLogoData.isEmpty ? "Add company logo" : "Replace company logo", systemImage: "photo.badge.plus")
                }
                .disabled(!subscriptionManager.canUseProFeatures)

                if !companyLogoData.isEmpty, let image = UIImage(data: companyLogoData) {
                    HStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: PSITheme.radius))
                        Button("Remove logo", role: .destructive) {
                            companyLogoData = Data()
                        }
                    }
                }

                Label(subscriptionManager.canUseProFeatures ? "Custom logo enabled for PDF export" : "Custom logo requires Pro", systemImage: subscriptionManager.canUseProFeatures ? "checkmark.seal" : "lock")
                    .foregroundStyle(subscriptionManager.canUseProFeatures ? .green : .secondary)
                Label(subscriptionManager.canUseProFeatures ? "White-label branding available" : "White-label branding requires Business", systemImage: "paintpalette")
                    .foregroundStyle(.secondary)
            }

            Section("Legal and disclosure") {
                Link("Privacy policy", destination: URL(string: "https://your-backend-url.com/privacy")!)
                Link("Terms of use", destination: URL(string: "https://your-backend-url.com/terms")!)
                DisclosureGroup("AI disclaimer") {
                    Text(ReportContentBuilder.safetyDisclaimer)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 6)
                }
            }

            Section("Data") {
                Button {
                    exportURL = exportAllReports()
                } label: {
                    Label("Export all reports", systemImage: "square.and.arrow.up")
                }

                if let exportURL {
                    ShareLink(item: exportURL) {
                        Label("Share exported report index", systemImage: "doc.on.doc")
                    }
                }

                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete all data", systemImage: "trash")
                }
            }

            Section("Developer") {
                LabeledContent("Mock AI mode", value: "Enabled")
                LabeledContent("Mock subscription mode", value: subscriptionManager.mockModeEnabled ? "Enabled" : "Disabled")
                Text("Remote AI endpoint placeholder: POST https://your-backend-url.com/property-scan")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .alert("Delete all local data?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteAllData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes local properties, inspections, rooms, photos, issues, reports, and subscription state records.")
        }
        .onChange(of: selectedLogoItem) { _, newItem in
            guard subscriptionManager.canUseProFeatures else { return }
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        companyLogoData = data
                    }
                }
            }
        }
    }

    private func exportAllReports() -> URL? {
        let lines = reports.map { report in
            let inspection = inspections.first { $0.id == report.inspectionId }
            let property = inspection.flatMap { inspection in
                properties.first { $0.id == inspection.propertyId }
            }
            return """
            Report: \(report.title)
            Property: \(property?.name ?? "Unknown")
            Created: \(report.createdAt.shortReportDate)
            Summary: \(report.summary)
            PDF: \(report.pdfLocalURL ?? "Not exported")
            """
        }
        .joined(separator: "\n\n")

        let text = lines.isEmpty ? "No reports exported." : lines
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = directory.appendingPathComponent("PropertyScanIQ-Report-Index.txt")

        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    private func deleteAllData() {
        photos.forEach(modelContext.delete)
        issues.forEach(modelContext.delete)
        reports.forEach(modelContext.delete)
        rooms.forEach(modelContext.delete)
        inspections.forEach(modelContext.delete)
        properties.forEach(modelContext.delete)
        subscriptionStates.forEach(modelContext.delete)
        try? modelContext.save()
    }
}
