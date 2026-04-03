import Foundation
import SwiftData

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var isBootstrapped = false
    @Published var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.onboardingComplete)
    @Published var settings: AppSettings = .default
    @Published var browseMode: BrowseMode = .surah
    @Published private(set) var surahs: [Surah] = []
    @Published private(set) var juzList: [Juz] = []
    @Published private(set) var selectedContent: [ContentSelection] = []
    @Published private(set) var extractedWords: [VocabWord] = []
    @Published private(set) var dueWords: [VocabWord] = []
    @Published private(set) var streak: Int = UserDefaults.standard.integer(forKey: Keys.streakCount)
    @Published private(set) var lastSessionSummary: SessionSummary?

    let audioService = AudioService()

    private let seedLoader: SeedDataLoader
    private let vocabularyService: VocabularyService
    private let reviewEngine: ReviewEngine
    private let reminderService: ReminderService

    private var progressRepository: ProgressRepository?
    private var settingsRepository: SettingsRepository?
    private var progressMap: [String: WordProgress] = [:]
    private var records: [VocabularyRecord] = []
    private var reviewEvents: [ReviewEvent] = []

    init(
        seedLoader: SeedDataLoader = SeedDataLoader(),
        vocabularyService: VocabularyService = VocabularyService(),
        reviewEngine: ReviewEngine = ReviewEngine(),
        reminderService: ReminderService = ReminderService()
    ) {
        self.seedLoader = seedLoader
        self.vocabularyService = vocabularyService
        self.reviewEngine = reviewEngine
        self.reminderService = reminderService
    }

    func bootstrapIfNeeded(modelContext: ModelContext) async {
        guard !isBootstrapped else { return }

        progressRepository = ProgressRepository(modelContext: modelContext)
        settingsRepository = SettingsRepository(modelContext: modelContext)

        settings = settingsRepository?.loadSettings() ?? .default
        browseMode = settings.defaultBrowseMode
        let payload = seedLoader.load()

        surahs = payload.surahs
        juzList = payload.juz
        records = payload.records
        progressMap = progressRepository?.loadProgressMap() ?? [:]
        selectedContent = loadSelections()
        applyHydratedProgress()
        recalculateDashboard()

        isBootstrapped = true
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: Keys.onboardingComplete)
    }

    func setBrowseMode(_ mode: BrowseMode) {
        browseMode = mode
        mutateSettings { value in
            value.defaultBrowseMode = mode
        }
    }

    func addSelection(_ selection: ContentSelection) {
        guard !selectedContent.contains(where: { $0.id == selection.id }) else { return }
        selectedContent.append(selection)
        persistSelections()
        recalculateDashboard()
    }

    func removeSelection(_ selection: ContentSelection) {
        selectedContent.removeAll(where: { $0.id == selection.id })
        persistSelections()
        recalculateDashboard()
    }

    func words(for selection: ContentSelection) -> [VocabWord] {
        vocabularyService.extractWords(
            from: selection,
            records: hydratedRecords(),
            hideFunctionWords: settings.hideFunctionWords
        )
    }

    func beginSessionQueue() -> [VocabWord] {
        reviewEvents = []
        dueWords
    }

    func applyAnswer(for word: VocabWord, correct: Bool) -> VocabWord {
        let result = reviewEngine.applyAnswer(to: word, correct: correct)
        reviewEvents.append(result.event)
        progressMap[word.key] = result.updated.progress
        progressRepository?.upsertProgress(for: word.key, progress: result.updated.progress)
        applyHydratedProgress()
        recalculateDashboard()
        return result.updated
    }

    func finishSession() -> SessionSummary {
        if !reviewEvents.isEmpty {
            streak = nextStreakValue(for: Date())
            UserDefaults.standard.set(streak, forKey: Keys.streakCount)
            UserDefaults.standard.set(Date(), forKey: Keys.lastSessionDate)
        }

        let summary = reviewEngine.summary(from: reviewEvents, streak: streak)
        lastSessionSummary = summary
        reviewEvents = []
        recalculateDashboard()
        return summary
    }

    func demoteToLearning(_ word: VocabWord) {
        var updated = word.progress
        updated.masteryLevel = .learning
        updated.intervalDays = 1
        updated.lastWasCorrect = false
        updated.nextReviewDate = Date()

        progressMap[word.key] = updated
        progressRepository?.upsertProgress(for: word.key, progress: updated)
        applyHydratedProgress()
        recalculateDashboard()
    }

    func mutateSettings(_ update: (inout AppSettings) -> Void) {
        var copy = settings
        update(&copy)
        settings = copy
        settingsRepository?.save(copy)
        recalculateDashboard()
    }

    func progressBreakdown(for selection: ContentSelection? = nil) -> ProgressBreakdown {
        let words = selection.map { self.words(for: $0) } ?? extractedWords
        var learning = 0
        var familiar = 0
        var mastered = 0

        words.forEach { word in
            switch word.progress.masteryLevel {
            case .learning:
                learning += 1
            case .familiar:
                familiar += 1
            case .mastered:
                mastered += 1
            }
        }

        return ProgressBreakdown(learning: learning, familiar: familiar, mastered: mastered)
    }

    func totalMasteredWords() -> Int {
        progressBreakdown().mastered
    }

    func estimatedDaysToMastery() -> Int {
        let breakdown = progressBreakdown()
        let remaining = breakdown.learning + breakdown.familiar
        let dailyCapacity = max(1, settings.dailyCardLimit)
        return max(1, Int(ceil(Double(remaining) / Double(dailyCapacity))))
    }

    func estimatedMinutesToday() -> Int {
        reviewEngine.estimatedMinutes(for: dueWords.count)
    }

    func displayArabic(for word: VocabWord) -> String {
        guard !settings.showTashkeel else { return word.arabic }
        return word.arabic.removingArabicDiacritics()
    }

    private func applyHydratedProgress() {
        records = records.map { record in
            var updatedWord = record.word
            if let progress = progressMap[record.word.key] {
                updatedWord.progress = progress
            }
            return VocabularyRecord(word: updatedWord, surahIDs: record.surahIDs, juzIDs: record.juzIDs)
        }
    }

    private func hydratedRecords() -> [VocabularyRecord] {
        records
    }

    private func recalculateDashboard() {
        extractedWords = vocabularyService.extractWords(
            from: selectedContent,
            records: hydratedRecords(),
            hideFunctionWords: settings.hideFunctionWords
        )

        dueWords = reviewEngine.dueWords(
            from: extractedWords,
            now: Date(),
            limit: settings.dailyCardLimit
        )

        Task {
            await reminderService.syncReminder(
                settings: settings,
                dueCount: dueWords.count,
                estimatedMinutes: estimatedMinutesToday()
            )
        }
    }

    private func persistSelections() {
        let encoded = selectedContent.map(\.id)
        UserDefaults.standard.set(encoded, forKey: Keys.selectedContent)
    }

    private func loadSelections() -> [ContentSelection] {
        guard let encoded = UserDefaults.standard.array(forKey: Keys.selectedContent) as? [String] else {
            return []
        }

        return encoded.compactMap { token in
            let components = token.split(separator: "-")
            guard let prefix = components.first else { return nil }

            switch prefix {
            case "surah":
                guard components.count == 2, let number = Int(String(components[1])) else { return nil }
                return .surah(number)
            case "juz":
                guard components.count == 2, let number = Int(String(components[1])) else { return nil }
                return .juz(number)
            case "ayah":
                guard components.count == 4,
                      let surah = Int(String(components[1])),
                      let start = Int(String(components[2])),
                      let end = Int(String(components[3])) else {
                    return nil
                }
                return .ayahRange(surah: surah, start: start, end: end)
            default:
                return nil
            }
        }
    }

    private func nextStreakValue(for date: Date) -> Int {
        guard let lastDate = UserDefaults.standard.object(forKey: Keys.lastSessionDate) as? Date else {
            return 1
        }

        if Calendar.current.isDate(lastDate, inSameDayAs: date) {
            return max(1, streak)
        }

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        if Calendar.current.isDate(lastDate, inSameDayAs: yesterday) {
            return max(1, streak + 1)
        }

        return 1
    }
}

private enum Keys {
    static let onboardingComplete = "safham.onboarding.complete"
    static let selectedContent = "safham.selected-content"
    static let streakCount = "safham.streak"
    static let lastSessionDate = "safham.last-session-date"
}

private extension String {
    func removingArabicDiacritics() -> String {
        replacingOccurrences(
            of: "[\\u{0610}-\\u{061A}\\u{064B}-\\u{065F}\\u{0670}\\u{06D6}-\\u{06ED}]",
            with: "",
            options: .regularExpression
        )
    }
}
