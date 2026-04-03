import Foundation

struct AyahReference: Hashable, Codable {
    let surah: Int
    let ayah: Int
}

enum MasteryLevel: Int, CaseIterable, Codable, Identifiable {
    case learning = 0
    case familiar = 1
    case mastered = 2

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .learning:
            return "Learning"
        case .familiar:
            return "Familiar"
        case .mastered:
            return "Mastered"
        }
    }
}

struct WordProgress: Hashable, Codable {
    var masteryLevel: MasteryLevel
    var nextReviewDate: Date
    var reviewCount: Int
    var correctCount: Int
    var easeFactor: Double
    var intervalDays: Int
    var correctStreak: Int
    var lastWasCorrect: Bool

    static func fresh(now: Date = Date()) -> WordProgress {
        WordProgress(
            masteryLevel: .learning,
            nextReviewDate: now,
            reviewCount: 0,
            correctCount: 0,
            easeFactor: 2.5,
            intervalDays: 0,
            correctStreak: 0,
            lastWasCorrect: false
        )
    }
}

struct VocabWord: Identifiable, Hashable, Codable {
    let key: String
    let arabic: String
    let transliteration: String
    let meaning: String
    let root: String?
    var frequency: Int
    var ayahRefs: [AyahReference]
    let isFunctionWord: Bool
    var progress: WordProgress

    var id: String { key }
}

struct VocabularyRecord: Identifiable, Hashable {
    let word: VocabWord
    let surahIDs: Set<Int>
    let juzIDs: Set<Int>

    var id: String { word.id }
}

struct SessionSummary: Hashable {
    let reviewedCount: Int
    let masteredDelta: Int
    let streak: Int
    let reviewedAt: Date
}

struct ProgressBreakdown: Hashable {
    let learning: Int
    let familiar: Int
    let mastered: Int

    var total: Int { learning + familiar + mastered }
}
