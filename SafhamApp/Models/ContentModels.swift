import Foundation

enum BrowseMode: String, CaseIterable, Codable, Identifiable {
    case surah
    case juz

    var id: String { rawValue }

    var title: String {
        switch self {
        case .surah:
            return "Surah"
        case .juz:
            return "Juz"
        }
    }
}

struct Surah: Identifiable, Hashable, Codable {
    let id: Int
    let englishName: String
    let arabicName: String
    let ayahCount: Int
    let juzNumbers: [Int]
}

struct Juz: Identifiable, Hashable, Codable {
    let id: Int
    let name: String
    let surahIDs: [Int]
}

enum ContentSelection: Hashable, Identifiable {
    case surah(Int)
    case juz(Int)
    case ayahRange(surah: Int, start: Int, end: Int)

    var id: String {
        switch self {
        case let .surah(number):
            return "surah-\(number)"
        case let .juz(number):
            return "juz-\(number)"
        case let .ayahRange(surah, start, end):
            return "ayah-\(surah)-\(start)-\(end)"
        }
    }

    var label: String {
        switch self {
        case let .surah(number):
            return "Surah \(number)"
        case let .juz(number):
            return "Juz \(number)"
        case let .ayahRange(surah, start, end):
            return "Surah \(surah), Ayah \(start)-\(end)"
        }
    }
}
