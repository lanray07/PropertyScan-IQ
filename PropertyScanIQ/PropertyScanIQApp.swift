import SwiftData
import SwiftUI

@main
struct PropertyScanIQApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Property.self,
            Inspection.self,
            RoomArea.self,
            InspectionPhoto.self,
            DetectedIssue.self,
            Report.self,
            SubscriptionState.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
