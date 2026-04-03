import XCTest
@testable import Safham

final class VocabularyServiceTests: XCTestCase {
    func testExtractBySurahAndHideFunctionWords() {
        let service = VocabularyService()
        let records = sampleRecords()

        let allWords = service.extractWords(from: .surah(67), records: records, hideFunctionWords: false)
        let noFunctionWords = service.extractWords(from: .surah(67), records: records, hideFunctionWords: true)

        XCTAssertEqual(allWords.count, 2)
        XCTAssertEqual(noFunctionWords.count, 1)
        XCTAssertEqual(noFunctionWords.first?.key, "word-main")
    }

    func testExtractAcrossSelectionsMergesDuplicates() {
        let service = VocabularyService()
        let records = sampleRecords()

        let words = service.extractWords(
            from: [.surah(67), .juz(29)],
            records: records,
            hideFunctionWords: false
        )

        let merged = words.first(where: { $0.key == "word-main" })
        XCTAssertNotNil(merged)
        XCTAssertEqual(merged?.frequency, 4)
    }

    private func sampleRecords() -> [VocabularyRecord] {
        let baseWord = VocabWord(
            key: "word-main",
            arabic: "الْمُلْكُ",
            transliteration: "al-mulk",
            meaning: "dominion",
            root: "م-ل-ك",
            frequency: 2,
            ayahRefs: [AyahReference(surah: 67, ayah: 1)],
            isFunctionWord: false,
            progress: .fresh()
        )

        let functionWord = VocabWord(
            key: "word-function",
            arabic: "مِن",
            transliteration: "min",
            meaning: "from",
            root: nil,
            frequency: 1,
            ayahRefs: [AyahReference(surah: 67, ayah: 3)],
            isFunctionWord: true,
            progress: .fresh()
        )

        let duplicateInJuz = VocabWord(
            key: "word-main",
            arabic: "الْمُلْكُ",
            transliteration: "al-mulk",
            meaning: "dominion",
            root: "م-ل-ك",
            frequency: 2,
            ayahRefs: [AyahReference(surah: 67, ayah: 3)],
            isFunctionWord: false,
            progress: .fresh()
        )

        return [
            VocabularyRecord(word: baseWord, surahIDs: [67], juzIDs: [29]),
            VocabularyRecord(word: functionWord, surahIDs: [67], juzIDs: [29]),
            VocabularyRecord(word: duplicateInJuz, surahIDs: [68], juzIDs: [29])
        ]
    }
}
