import Foundation
import SwiftData

@Model
final class DetectedIssue {
    @Attribute(.unique) var id: UUID
    var roomAreaId: UUID
    var photoId: UUID?
    var title: String
    var issueDescription: String
    var category: String
    var severity: String
    var confidence: Double
    var suggestedAction: String
    var userApproved: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        roomAreaId: UUID,
        photoId: UUID? = nil,
        title: String,
        description: String,
        category: String,
        severity: String,
        confidence: Double,
        suggestedAction: String,
        userApproved: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.roomAreaId = roomAreaId
        self.photoId = photoId
        self.title = title
        self.issueDescription = description
        self.category = category
        self.severity = severity
        self.confidence = confidence
        self.suggestedAction = suggestedAction
        self.userApproved = userApproved
        self.createdAt = createdAt
    }

    var severityValue: IssueSeverity {
        IssueSeverity(rawValue: severity) ?? .medium
    }

    var categoryLabel: String {
        IssueCategory(rawValue: category)?.displayName ?? category
    }
}
