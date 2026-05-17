import Foundation
import SwiftData

@Model
final class Report {
    @Attribute(.unique) var id: UUID
    var inspectionId: UUID
    var title: String
    var summary: String
    var pdfLocalURL: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        inspectionId: UUID,
        title: String,
        summary: String = "",
        pdfLocalURL: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.title = title
        self.summary = summary
        self.pdfLocalURL = pdfLocalURL
        self.createdAt = createdAt
    }

    var pdfURL: URL? {
        guard let pdfLocalURL else { return nil }
        return URL(fileURLWithPath: pdfLocalURL)
    }
}
