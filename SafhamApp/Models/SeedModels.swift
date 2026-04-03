import Foundation

struct SeedPayload: Decodable {
    let surahs: [Surah]
    let juz: [Juz]
    let vocabulary: [SeedWord]
}

struct SeedWord: Decodable {
    let key: String
    let arabic: String
    let transliteration: String
    let meaning: String
    let root: String?
    let frequency: Int
    let isFunctionWord: Bool
    let ayahRefs: [AyahReference]
    let surahIDs: [Int]
    let juzIDs: [Int]
}
