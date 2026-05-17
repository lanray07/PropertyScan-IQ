import Foundation
import SwiftData
import UIKit

@MainActor
final class RoomScanViewModel: ObservableObject {
    @Published var isScanning = false
    @Published var errorMessage: String?
    @Published var lastSummary: String?

    func addPhoto(image: UIImage, roomArea: RoomArea, context: ModelContext) {
        let data = image.jpegData(compressionQuality: 0.82)
        let photo = InspectionPhoto(roomAreaId: roomArea.id, imageData: data)
        context.insert(photo)
        try? context.save()
    }

    func addPhoto(data: Data, roomArea: RoomArea, context: ModelContext) {
        let photo = InspectionPhoto(roomAreaId: roomArea.id, imageData: data)
        context.insert(photo)
        try? context.save()
    }

    func scan(
        property: Property?,
        inspection: Inspection,
        roomArea: RoomArea,
        photos: [InspectionPhoto],
        context: ModelContext,
        aiService: any AIService
    ) async {
        errorMessage = nil
        lastSummary = nil

        guard !photos.isEmpty else {
            errorMessage = "Add at least one photo before running an AI scan."
            return
        }

        isScanning = true
        defer { isScanning = false }

        do {
            for photo in photos {
                let request = PropertyScanRequest(
                    inspectionType: inspection.inspectionTypeLabel,
                    propertyType: property?.propertyTypeLabel ?? "Property",
                    room: roomArea.name,
                    userNotes: roomArea.notes,
                    imageData: photo.imageData
                )
                let result = try await aiService.scanPropertyPhoto(request)
                lastSummary = result.summary
                for draft in result.issues {
                    let issue = draft.makeIssue(roomAreaId: roomArea.id, photoId: photo.id)
                    context.insert(issue)
                }
            }
            inspection.status = InspectionStatus.review.rawValue
            try context.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
