import Foundation
import SwiftUI

struct PropertyScanRequest: Encodable {
    var inspectionType: String
    var propertyType: String
    var room: String
    var userNotes: String
    var imageData: Data?

    enum CodingKeys: String, CodingKey {
        case inspectionType
        case propertyType
        case room
        case userNotes
        case imageBase64
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inspectionType, forKey: .inspectionType)
        try container.encode(propertyType, forKey: .propertyType)
        try container.encode(room, forKey: .room)
        try container.encode(userNotes, forKey: .userNotes)
        try container.encode(imageData?.base64EncodedString() ?? "", forKey: .imageBase64)
    }
}

struct DetectedIssueDraft: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var description: String
    var category: String
    var severity: String
    var confidence: Double
    var suggestedAction: String

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case category
        case severity
        case confidence
        case suggestedAction
    }

    func makeIssue(roomAreaId: UUID, photoId: UUID?) -> DetectedIssue {
        DetectedIssue(
            roomAreaId: roomAreaId,
            photoId: photoId,
            title: title,
            description: description,
            category: category,
            severity: severity,
            confidence: confidence,
            suggestedAction: suggestedAction
        )
    }
}

struct PropertyScanResult: Decodable {
    var issues: [DetectedIssueDraft]
    var summary: String
}

protocol AIService {
    func scanPropertyPhoto(_ request: PropertyScanRequest) async throws -> PropertyScanResult
    func generateInspectionSummary(property: Property, inspection: Inspection, rooms: [RoomArea], issues: [DetectedIssue]) async throws -> String
    func generateRecommendedActions(issues: [DetectedIssue]) async throws -> [String]
    func generatePDFReportText(content: ReportContent) async throws -> String
}

enum AIServiceError: LocalizedError {
    case invalidResponse
    case backendNotConfigured

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "The AI response could not be read."
        case .backendNotConfigured: "Remote AI is not configured. Mock AI mode is enabled by default."
        }
    }
}

private struct AIServiceKey: EnvironmentKey {
    static let defaultValue: any AIService = MockAIService()
}

extension EnvironmentValues {
    var aiService: any AIService {
        get { self[AIServiceKey.self] }
        set { self[AIServiceKey.self] = newValue }
    }
}
