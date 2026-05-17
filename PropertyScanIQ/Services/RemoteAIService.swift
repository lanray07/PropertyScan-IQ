import Foundation

struct RemoteAIService: AIService {
    var endpoint: URL = URL(string: "https://your-backend-url.com/property-scan")!
    var session: URLSession = .shared

    func scanPropertyPhoto(_ request: PropertyScanRequest) async throws -> PropertyScanResult {
        guard endpoint.host != "your-backend-url.com" else {
            throw AIServiceError.backendNotConfigured
        }

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw AIServiceError.invalidResponse
        }

        return try JSONDecoder().decode(PropertyScanResult.self, from: data)
    }

    func generateInspectionSummary(property: Property, inspection: Inspection, rooms: [RoomArea], issues: [DetectedIssue]) async throws -> String {
        "Remote summary generation should be implemented on the backend. Current inspection includes \(rooms.count) rooms and \(issues.count) findings."
    }

    func generateRecommendedActions(issues: [DetectedIssue]) async throws -> [String] {
        issues.sorted { $0.severityValue > $1.severityValue }.map(\.suggestedAction)
    }

    func generatePDFReportText(content: ReportContent) async throws -> String {
        "Remote PDF report text generation should be implemented on the backend for \(content.title)."
    }
}
