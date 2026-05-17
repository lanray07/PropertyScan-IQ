import Foundation
import SwiftData

enum SampleData {
    @MainActor
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Property>()
        guard let existing = try? context.fetch(descriptor), existing.isEmpty else { return }

        let property = Property(
            name: "Riverside Flat",
            address: "24 Riverside Walk, Bristol",
            propertyType: PropertyType.flat.rawValue,
            clientName: "Avery Lettings",
            notes: "Two-bedroom rental property with recent tenancy changeover."
        )

        let inspection = Inspection(
            propertyId: property.id,
            inspectionType: InspectionType.moveOut.rawValue,
            status: InspectionStatus.review.rawValue,
            summary: "Visual review highlights possible damp staining in the bathroom and wear to kitchen flooring."
        )

        let kitchen = RoomArea(
            inspectionId: inspection.id,
            name: RoomTemplate.kitchen.displayName,
            condition: RoomCondition.fair.rawValue,
            notes: "Light surface wear around the sink area."
        )

        let bathroom = RoomArea(
            inspectionId: inspection.id,
            name: RoomTemplate.bathroom.displayName,
            condition: RoomCondition.poor.rawValue,
            notes: "Possible staining around ceiling edge."
        )

        let dampIssue = DetectedIssue(
            roomAreaId: bathroom.id,
            title: "Possible damp staining",
            description: "Visible dark marks near the bathroom ceiling edge may indicate moisture staining. This is a visual suggestion only.",
            category: IssueCategory.dampMould.rawValue,
            severity: IssueSeverity.high.rawValue,
            confidence: 0.74,
            suggestedAction: "Review ventilation and request a qualified damp inspection if staining persists.",
            userApproved: true
        )

        let flooringIssue = DetectedIssue(
            roomAreaId: kitchen.id,
            title: "Visible flooring wear",
            description: "Flooring shows signs of general wear near a high-use area.",
            category: IssueCategory.flooring.rawValue,
            severity: IssueSeverity.medium.rawValue,
            confidence: 0.68,
            suggestedAction: "Record condition for tenancy evidence and consider repair during next maintenance window.",
            userApproved: true
        )

        let report = Report(
            inspectionId: inspection.id,
            title: "Riverside Flat Move-out Report",
            summary: inspection.summary
        )

        context.insert(property)
        context.insert(inspection)
        context.insert(kitchen)
        context.insert(bathroom)
        context.insert(dampIssue)
        context.insert(flooringIssue)
        context.insert(report)
        try? context.save()
    }
}
