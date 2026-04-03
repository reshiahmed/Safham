import SwiftData
import SwiftUI

@main
struct SafhamApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [WordProgressEntity.self, AppSettingsEntity.self])
    }
}
