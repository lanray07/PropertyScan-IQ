import SwiftData
import SwiftUI

struct DashboardView: View {
    @Query(sort: \Property.createdAt, order: .reverse) private var properties: [Property]
    @Query(sort: \Inspection.createdAt, order: .reverse) private var inspections: [Inspection]
    @Query(sort: \Report.createdAt, order: .reverse) private var reports: [Report]
    @Query(sort: \DetectedIssue.createdAt, order: .reverse) private var issues: [DetectedIssue]

    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingPropertyEditor = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                statsGrid

                NavigationLink(value: AppRoute.inspectionBuilder) {
                    Label("New Inspection", systemImage: "plus.viewfinder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                subscriptionCard
                recentProperties
                recentReports
            }
            .padding()
        }
        .navigationTitle("PropertyScan IQ")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingPropertyEditor = true
                } label: {
                    Image(systemName: "building.badge.plus")
                }
                .accessibilityLabel("Add property")
            }
        }
        .sheet(isPresented: $showingPropertyEditor) {
            NavigationStack {
                PropertyEditorView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Inspection command center")
                .font(.title2.bold())
            Text("Create properties, scan rooms, approve findings, and export client-ready reports.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var statsGrid: some View {
        let stats = viewModel.stats(inspections: inspections, issues: issues, reports: reports)
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            statTile("Inspections", value: stats.totalInspections, symbol: "doc.text.magnifyingglass")
            statTile("Open issues", value: stats.openIssues, symbol: "exclamationmark.triangle")
            statTile("Urgent", value: stats.urgentIssues, symbol: "flame")
            statTile("Reports", value: stats.reportsGenerated, symbol: "doc.richtext")
        }
    }

    private func statTile(_ title: String, value: Int, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(PSITheme.accent)
            Text("\(value)")
                .font(.title.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .psiCard()
    }

    private var subscriptionCard: some View {
        HStack(spacing: 12) {
            Image(systemName: subscriptionManager.canUseProFeatures ? "checkmark.seal.fill" : "lock.open")
                .font(.title2)
                .foregroundStyle(PSITheme.accent)
            VStack(alignment: .leading, spacing: 4) {
                Text("Subscription status")
                    .font(.headline)
                Text(subscriptionManager.canUseProFeatures ? subscriptionManager.planLabel : "Free plan active")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            NavigationLink(value: AppRoute.paywall) {
                Text(subscriptionManager.canUseProFeatures ? "Manage" : "Upgrade")
            }
            .buttonStyle(.bordered)
        }
        .psiCard()
    }

    private var recentProperties: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Properties")
                .font(.headline)
            if properties.isEmpty {
                EmptyStateView(systemImage: "building.2", title: "No properties", message: "Add your first property to begin an inspection.")
            } else {
                ForEach(properties.prefix(4)) { property in
                    NavigationLink(value: AppRoute.property(property.id)) {
                        PropertyCard(
                            property: property,
                            inspectionCount: inspections.filter { $0.propertyId == property.id }.count
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var recentReports: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Reports")
                .font(.headline)
            if reports.isEmpty {
                EmptyStateView(systemImage: "doc.text", title: "No reports", message: "Generate a report after reviewing room findings.")
            } else {
                ForEach(reports.prefix(3)) { report in
                    NavigationLink(value: AppRoute.pdfExport(report.id)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(report.title)
                                .font(.headline)
                            Text(report.createdAt.shortReportDate)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(report.summary.isEmpty ? "Summary pending" : report.summary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        .psiCard()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
