import Foundation

struct DashboardStats {
    var totalInspections: Int
    var openIssues: Int
    var urgentIssues: Int
    var reportsGenerated: Int
}

@MainActor
final class DashboardViewModel: ObservableObject {
    func stats(inspections: [Inspection], issues: [DetectedIssue], reports: [Report]) -> DashboardStats {
        DashboardStats(
            totalInspections: inspections.count,
            openIssues: issues.filter { !$0.userApproved || $0.severityValue >= .medium }.count,
            urgentIssues: issues.filter { $0.severityValue == .urgent }.count,
            reportsGenerated: reports.count
        )
    }
}
