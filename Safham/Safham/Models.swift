//
//  Models.swift
//  Safham
//
//  Created by Antigravity on 3.04.2026.
//

import Foundation
import SwiftData

@Model
final class Surah {
    @Attribute(.unique) var number: Int
    var nameArabic: String
    var nameEnglish: String
    var ayahCount: Int
    var isAdded: Bool = false
    
    @Relationship(deleteRule: .nullify, inverse: \Word.surahs)
    var words: [Word] = []
    
    init(number: Int, nameArabic: String, nameEnglish: String, ayahCount: Int) {
        self.number = number
        self.nameArabic = nameArabic
        self.nameEnglish = nameEnglish
        self.ayahCount = ayahCount
    }
}

@Model
final class Word {
    var arabic: String
    var transliteration: String
    var meaning: String
    var root: String?
    var frequency: Int
    var masteryLevel: Int = 0 // 0=Learning, 1=Familiar, 2=Mastered
    var nextReviewDate: Date = Date()
    var reviewCount: Int = 0
    var easeFactor: Double = 2.5 // SM-2 default
    var interval: Int = 0 // interval in days
    var consecutiveCorrect: Int = 0 // consecutive correct answers (SM-2 repetitions)
    var isFunctionWord: Bool = false // grammatical function word (و, في, من, etc.)

    @Relationship(deleteRule: .nullify)
    var surahs: [Surah] = []
    
    init(arabic: String, transliteration: String, meaning: String, root: String? = nil, frequency: Int = 0) {
        self.arabic = arabic
        self.transliteration = transliteration
        self.meaning = meaning
        self.root = root
        self.frequency = frequency
    }
}

@Model
final class UserStats {
    var dailyStreak: Int = 0
    var lastReviewDate: Date?
    var totalWordsMastered: Int = 0
    var dailyGoal: Int = 20
    
    init() {}
}

@Model
final class Ayah {
    var surahNumber: Int
    var ayahNumber: Int
    var text: String
    
    @Relationship(deleteRule: .nullify)
    var words: [Word] = []
    
    init(surahNumber: Int, ayahNumber: Int, text: String) {
        self.surahNumber = surahNumber
        self.ayahNumber = ayahNumber
        self.text = text
    }
}
