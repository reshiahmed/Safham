//
//  JuzData.swift
//  Safham
//
//  Surah-to-Juz mapping and Juz metadata.
//  Each surah is assigned its primary (dominant) juz.
//

import Foundation

struct JuzInfo: Identifiable {
    let id: Int            // Juz number 1–30
    let name: String       // "Juz 1", "Juz 'Amma", etc.
    let surahNumbers: [Int]
}

enum JuzData {

    /// Map from surah number (1–114) to its primary juz (1–30).
    static let surahToJuz: [Int: Int] = {
        var map: [Int: Int] = [:]
        for juz in allJuz {
            for surah in juz.surahNumbers {
                map[surah] = juz.id
            }
        }
        return map
    }()

    static let allJuz: [JuzInfo] = [
        JuzInfo(id: 1,  name: "Juz 1",            surahNumbers: [1, 2]),
        JuzInfo(id: 2,  name: "Juz 2",            surahNumbers: [2]),
        JuzInfo(id: 3,  name: "Juz 3",            surahNumbers: [2, 3]),
        JuzInfo(id: 4,  name: "Juz 4",            surahNumbers: [3, 4]),
        JuzInfo(id: 5,  name: "Juz 5",            surahNumbers: [4, 5]),
        JuzInfo(id: 6,  name: "Juz 6",            surahNumbers: [4, 5, 6]),
        JuzInfo(id: 7,  name: "Juz 7",            surahNumbers: [5, 6, 7]),
        JuzInfo(id: 8,  name: "Juz 8",            surahNumbers: [6, 7, 8, 9]),
        JuzInfo(id: 9,  name: "Juz 9",            surahNumbers: [7, 8, 9]),
        JuzInfo(id: 10, name: "Juz 10",           surahNumbers: [8, 9, 10, 11]),
        JuzInfo(id: 11, name: "Juz 11",           surahNumbers: [9, 10, 11, 12]),
        JuzInfo(id: 12, name: "Juz 12",           surahNumbers: [11, 12]),
        JuzInfo(id: 13, name: "Juz 13",           surahNumbers: [12, 13, 14]),
        JuzInfo(id: 14, name: "Juz 14",           surahNumbers: [15, 16, 17]),
        JuzInfo(id: 15, name: "Juz 15",           surahNumbers: [17, 18]),
        JuzInfo(id: 16, name: "Juz 16",           surahNumbers: [18, 19, 20]),
        JuzInfo(id: 17, name: "Juz 17",           surahNumbers: [21, 22]),
        JuzInfo(id: 18, name: "Juz 18",           surahNumbers: [23, 24, 25]),
        JuzInfo(id: 19, name: "Juz 19",           surahNumbers: [25, 26, 27]),
        JuzInfo(id: 20, name: "Juz 20",           surahNumbers: [27, 28, 29]),
        JuzInfo(id: 21, name: "Juz 21",           surahNumbers: [29, 30, 31, 32, 33]),
        JuzInfo(id: 22, name: "Juz 22",           surahNumbers: [33, 34, 35, 36]),
        JuzInfo(id: 23, name: "Juz 23",           surahNumbers: [36, 37, 38, 39]),
        JuzInfo(id: 24, name: "Juz 24",           surahNumbers: [39, 40, 41]),
        JuzInfo(id: 25, name: "Juz 25",           surahNumbers: [41, 42, 43, 44, 45]),
        JuzInfo(id: 26, name: "Juz 26",           surahNumbers: [46, 47, 48, 49, 50, 51]),
        JuzInfo(id: 27, name: "Juz 27",           surahNumbers: [51, 52, 53, 54, 55, 56, 57]),
        JuzInfo(id: 28, name: "Juz 28",           surahNumbers: [58, 59, 60, 61, 62, 63, 64, 65, 66]),
        JuzInfo(id: 29, name: "Juz 29",           surahNumbers: [67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77]),
        JuzInfo(id: 30, name: "Juz 'Amma (30)",   surahNumbers: Array(78...114))
    ]

    static func juz(forSurah number: Int) -> Int {
        // Return the primary juz for a surah
        surahToJuz[number] ?? 1
    }

    static func surahs(inJuz juzNumber: Int) -> [Int] {
        allJuz.first(where: { $0.id == juzNumber })?.surahNumbers ?? []
    }
}
