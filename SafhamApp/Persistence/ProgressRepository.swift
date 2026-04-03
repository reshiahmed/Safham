import Foundation
import SwiftData

@MainActor
final class ProgressRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func loadProgressMap() -> [String: WordProgress] {
        let descriptor = FetchDescriptor<WordProgressEntity>()
        guard let entities = try? modelContext.fetch(descriptor) else {
            return [:]
        }

        return Dictionary(uniqueKeysWithValues: entities.map { ($0.key, $0.model) })
    }

    func upsertProgress(for key: String, progress: WordProgress) {
        let descriptor = FetchDescriptor<WordProgressEntity>()
        let existing = (try? modelContext.fetch(descriptor))?.first(where: { $0.key == key })

        if let existing {
            existing.apply(progress: progress)
        } else {
            modelContext.insert(WordProgressEntity(key: key, progress: progress))
        }

        try? modelContext.save()
    }
}
