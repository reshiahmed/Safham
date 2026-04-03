import Foundation
import SwiftData

@MainActor
final class SettingsRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func loadSettings() -> AppSettings {
        let descriptor = FetchDescriptor<AppSettingsEntity>()
        let entity = (try? modelContext.fetch(descriptor))?.first(where: { $0.profileID == "default" })

        guard let entity else {
            return .default
        }

        return entity.model
    }

    func save(_ settings: AppSettings) {
        let descriptor = FetchDescriptor<AppSettingsEntity>()
        let existing = (try? modelContext.fetch(descriptor))?.first(where: { $0.profileID == "default" })

        if let existing {
            existing.apply(settings: settings)
        } else {
            modelContext.insert(AppSettingsEntity(settings: settings))
        }

        try? modelContext.save()
    }
}
