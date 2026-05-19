import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var subscriptionManager = SubscriptionManager(mockModeEnabled: RootView.mockSubscriptionModeEnabled)

    private let aiService: any AIService = MockAIService()

    private static var mockSubscriptionModeEnabled: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                AppShellView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(subscriptionManager)
        .environment(\.aiService, aiService)
        .task {
            SampleData.seedIfNeeded(context: modelContext)
        }
    }
}

private struct AppShellView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
                    .navigationDestination(for: AppRoute.self) { route in
                        RouteDestinationView(route: route)
                    }
            }
            .tabItem {
                Label("Dashboard", systemImage: "square.grid.2x2")
            }

            NavigationStack {
                SavedReportsView()
                    .navigationDestination(for: AppRoute.self) { route in
                        RouteDestinationView(route: route)
                    }
            }
            .tabItem {
                Label("Reports", systemImage: "doc.richtext")
            }

            NavigationStack {
                SettingsView()
                    .navigationDestination(for: AppRoute.self) { route in
                        RouteDestinationView(route: route)
                    }
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .tint(PSITheme.accent)
    }
}

private struct RouteDestinationView: View {
    var route: AppRoute

    @Query private var properties: [Property]
    @Query private var inspections: [Inspection]
    @Query private var rooms: [RoomArea]
    @Query private var reports: [Report]

    var body: some View {
        switch route {
        case .inspectionBuilder:
            InspectionBuilderView()
        case .property(let id):
            if let property = properties.first(where: { $0.id == id }) {
                PropertyProfileView(property: property)
            } else {
                MissingContentView(title: "Property not found")
            }
        case .roomScan(let inspectionID, let roomID):
            if let inspection = inspections.first(where: { $0.id == inspectionID }),
               let room = rooms.first(where: { $0.id == roomID }) {
                RoomScanView(inspection: inspection, roomArea: room)
            } else {
                MissingContentView(title: "Room not found")
            }
        case .reportGenerator(let inspectionID):
            if let inspection = inspections.first(where: { $0.id == inspectionID }),
               let property = properties.first(where: { $0.id == inspection.propertyId }) {
                ReportGeneratorView(property: property, inspection: inspection)
            } else {
                MissingContentView(title: "Inspection not found")
            }
        case .pdfExport(let reportID):
            if let report = reports.first(where: { $0.id == reportID }) {
                PDFExportView(report: report)
            } else {
                MissingContentView(title: "Report not found")
            }
        case .paywall:
            PaywallView()
        }
    }
}

private struct MissingContentView: View {
    var title: String

    var body: some View {
        EmptyStateView(
            systemImage: "exclamationmark.magnifyingglass",
            title: title,
            message: "The selected record may have been deleted or moved."
        )
        .padding()
        .navigationTitle(title)
    }
}
