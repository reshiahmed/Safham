//
//  DataService.swift
//  Safham
//

import Foundation
import SwiftData

// MARK: - Codable helpers for JSON decoding

struct SurahMetadata: Codable {
    let number: Int
    let nameArabic: String
    let nameEnglish: String
    let ayahCount: Int
}

struct VocabWordJSON: Codable {
    let arabic: String
    let transliteration: String
    let meaning: String
    let root: String?
    let frequency: Int
    let ayahRefs: [Int]
    let isFunctionWord: Bool
}

struct SurahVocabularyJSON: Codable {
    let surahNumber: Int
    let words: [VocabWordJSON]
}

// MARK: - DataService

class DataService {
    static let shared = DataService()

    // Cached vocabulary index keyed by surah number
    private var vocabularyIndex: [Int: [VocabWordJSON]] = [:]

    // MARK: Bootstrap

    @MainActor
    func populateInitialData(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Surah>()
        if let count = try? modelContext.fetchCount(descriptor), count > 0 {
            return
        }

        loadSurahs(into: modelContext)
        loadUserStats(into: modelContext)

        do {
            try modelContext.save()
            print("✅ Initial data populated")
        } catch {
            print("❌ Error saving initial data: \(error)")
        }
    }

    @MainActor
    private func loadSurahs(into modelContext: ModelContext) {
        guard let url = Bundle.main.url(forResource: "surahs", withExtension: "json") else {
            print("❌ surahs.json not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let metadata = try JSONDecoder().decode([SurahMetadata].self, from: data)
            for m in metadata {
                let surah = Surah(number: m.number, nameArabic: m.nameArabic,
                                  nameEnglish: m.nameEnglish, ayahCount: m.ayahCount)
                modelContext.insert(surah)
            }
        } catch {
            print("❌ Error loading surahs.json: \(error)")
        }
    }

    @MainActor
    private func loadUserStats(into modelContext: ModelContext) {
        modelContext.insert(UserStats())
    }

    // MARK: Vocabulary

    /// Load the vocabulary JSON once and cache it.
    private func loadVocabularyIndex() {
        guard vocabularyIndex.isEmpty else { return }
        guard let url = Bundle.main.url(forResource: "vocabulary", withExtension: "json") else {
            print("❌ vocabulary.json not found")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let surahs = try JSONDecoder().decode([SurahVocabularyJSON].self, from: data)
            for entry in surahs {
                vocabularyIndex[entry.surahNumber] = entry.words
            }
        } catch {
            print("❌ Error loading vocabulary.json: \(error)")
        }
    }

    /// Add a surah to the user's collection — inserts its vocabulary words into SwiftData.
    @MainActor
    func addSurah(_ surah: Surah, modelContext: ModelContext) {
        guard !surah.isAdded else { return }
        loadVocabularyIndex()

        let vocabWords = vocabularyIndex[surah.number] ?? []

        // Deduplicate: skip any arabic word already linked to this surah
        let existingArabic = Set(surah.words.map { $0.arabic })

        for vw in vocabWords {
            guard !existingArabic.contains(vw.arabic) else { continue }

            // Check if this word already exists globally (shared across surahs)
            let arabic = vw.arabic
            let fetchDescriptor = FetchDescriptor<Word>(
                predicate: #Predicate { $0.arabic == arabic }
            )
            if let existing = try? modelContext.fetch(fetchDescriptor).first {
                if !existing.surahs.contains(where: { $0.number == surah.number }) {
                    existing.surahs.append(surah)
                    surah.words.append(existing)
                }
            } else {
                let word = Word(
                    arabic: vw.arabic,
                    transliteration: vw.transliteration,
                    meaning: vw.meaning,
                    root: vw.root,
                    frequency: vw.frequency
                )
                word.isFunctionWord = vw.isFunctionWord
                word.surahs = [surah]
                modelContext.insert(word)
                surah.words.append(word)
            }
        }

        surah.isAdded = true

        do {
            try modelContext.save()
        } catch {
            print("❌ Error saving surah: \(error)")
        }
    }

    /// Remove a surah from the user's collection (words that belong only to this surah are deleted).
    @MainActor
    func removeSurah(_ surah: Surah, modelContext: ModelContext) {
        for word in surah.words {
            if word.surahs.count <= 1 {
                modelContext.delete(word)
            }
        }
        surah.isAdded = false
        surah.words = []
        try? modelContext.save()
    }

    // MARK: Streak

    /// Call after completing a review session to update the daily streak.
    @MainActor
    func updateStreak(stats: UserStats) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let last = stats.lastReviewDate {
            let lastDay = calendar.startOfDay(for: last)
            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                stats.dailyStreak += 1
            } else if diff > 1 {
                stats.dailyStreak = 1
            }
            // diff == 0 means reviewed again today → no change
        } else {
            stats.dailyStreak = 1
        }

        stats.lastReviewDate = Date()
    }
}
