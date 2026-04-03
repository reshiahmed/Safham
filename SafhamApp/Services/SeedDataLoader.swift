import Foundation

final class SeedDataLoader {
    private let decoder = JSONDecoder()

    func load() -> (surahs: [Surah], juz: [Juz], records: [VocabularyRecord]) {
        let payload = loadPayload() ?? SeedPayload(surahs: [], juz: [], vocabulary: [])

        let surahs = mergedSurahs(from: payload.surahs)
        let juz = mergedJuz(from: payload.juz)
        let records = payload.vocabulary.map { seedWord in
            let word = VocabWord(
                key: seedWord.key,
                arabic: seedWord.arabic,
                transliteration: seedWord.transliteration,
                meaning: seedWord.meaning,
                root: seedWord.root,
                frequency: seedWord.frequency,
                ayahRefs: seedWord.ayahRefs,
                isFunctionWord: seedWord.isFunctionWord,
                progress: .fresh()
            )

            return VocabularyRecord(
                word: word,
                surahIDs: Set(seedWord.surahIDs),
                juzIDs: Set(seedWord.juzIDs)
            )
        }

        return (surahs: surahs, juz: juz, records: records)
    }

    private func loadPayload() -> SeedPayload? {
        guard let url = Bundle.main.url(forResource: "safham_seed", withExtension: "json", subdirectory: "Seed"),
              let data = try? Data(contentsOf: url),
              let payload = try? decoder.decode(SeedPayload.self, from: data)
        else {
            return nil
        }

        return payload
    }

    private func mergedSurahs(from source: [Surah]) -> [Surah] {
        var byID = Dictionary(uniqueKeysWithValues: defaultSurahs().map { ($0.id, $0) })
        source.forEach { byID[$0.id] = $0 }
        return byID.values.sorted(by: { $0.id < $1.id })
    }

    private func mergedJuz(from source: [Juz]) -> [Juz] {
        var byID = Dictionary(uniqueKeysWithValues: defaultJuz().map { ($0.id, $0) })
        source.forEach { byID[$0.id] = $0 }
        return byID.values.sorted(by: { $0.id < $1.id })
    }

    private func defaultSurahs() -> [Surah] {
        var surahs = (1...114).map { number in
            Surah(
                id: number,
                englishName: "Surah \(number)",
                arabicName: "سورة \(number)",
                ayahCount: 0,
                juzNumbers: []
            )
        }

        let known: [Surah] = [
            Surah(id: 1, englishName: "Al-Fatihah", arabicName: "الفاتحة", ayahCount: 7, juzNumbers: [1]),
            Surah(id: 67, englishName: "Al-Mulk", arabicName: "الملك", ayahCount: 30, juzNumbers: [29]),
            Surah(id: 112, englishName: "Al-Ikhlas", arabicName: "الإخلاص", ayahCount: 4, juzNumbers: [30]),
            Surah(id: 113, englishName: "Al-Falaq", arabicName: "الفلق", ayahCount: 5, juzNumbers: [30]),
            Surah(id: 114, englishName: "An-Nas", arabicName: "الناس", ayahCount: 6, juzNumbers: [30])
        ]

        known.forEach { surah in
            if let index = surahs.firstIndex(where: { $0.id == surah.id }) {
                surahs[index] = surah
            }
        }

        return surahs
    }

    private func defaultJuz() -> [Juz] {
        (1...30).map { number in
            Juz(id: number, name: "Juz \(number)", surahIDs: [])
        }
    }
}
