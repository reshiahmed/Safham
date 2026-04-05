//
//  SM2Algorithm.swift
//  Safham
//
//  Implements the SM-2 spaced repetition algorithm.
//  Reference: https://www.supermemo.com/en/blog/application-of-a-computer-to-improve-the-results-obtained-in-working-with-the-SuperMemo-method
//

import Foundation
import SwiftData

struct SM2Result {
    let nextInterval: Int       // days until next review
    let newEaseFactor: Double   // updated ease factor
    let newMasteryLevel: Int    // 0=Learning, 1=Familiar, 2=Mastered
    let newConsecutiveCorrect: Int
    let newReviewCount: Int
}

enum SM2Algorithm {

    /// Apply one review cycle to a word.
    /// - Parameters:
    ///   - correct: Whether the user answered correctly.
    ///   - word: The current state of the Word model.
    /// - Returns: An SM2Result containing all fields to write back to the model.
    static func apply(correct: Bool, word: Word) -> SM2Result {
        let consecutiveCorrect = word.consecutiveCorrect
        let easeFactor = word.easeFactor
        let interval = word.interval
        let reviewCount = word.reviewCount

        var newInterval: Int
        var newEaseFactor: Double
        let newConsecutiveCorrect: Int

        if correct {
            newConsecutiveCorrect = consecutiveCorrect + 1
            switch consecutiveCorrect {
            case 0:
                newInterval = 1
            case 1:
                newInterval = 6
            default:
                newInterval = max(1, Int(ceil(Double(interval) * easeFactor)))
            }
            // EF' = EF + 0.1 for a correct response (simplified — full SM-2 grades 0-5)
            newEaseFactor = max(1.3, easeFactor + 0.1)
        } else {
            newConsecutiveCorrect = 0
            newInterval = 1
            // Penalty for incorrect
            newEaseFactor = max(1.3, easeFactor - 0.2)
        }

        let newReviewCount = reviewCount + 1

        // Mastery thresholds (per PRD)
        let masteryLevel: Int
        if newConsecutiveCorrect >= 5 && newInterval >= 14 {
            masteryLevel = 2  // Mastered: correct 5+ times, interval ≥ 14 days
        } else if newConsecutiveCorrect >= 3 {
            masteryLevel = 1  // Familiar: correct 3+ times
        } else {
            masteryLevel = 0  // Learning
        }

        return SM2Result(
            nextInterval: newInterval,
            newEaseFactor: newEaseFactor,
            newMasteryLevel: masteryLevel,
            newConsecutiveCorrect: newConsecutiveCorrect,
            newReviewCount: newReviewCount
        )
    }

    /// Apply the SM2Result back to a Word object and schedule its next review date.
    @MainActor
    static func commit(result: SM2Result, to word: Word) {
        word.interval = result.nextInterval
        word.easeFactor = result.newEaseFactor
        word.masteryLevel = result.newMasteryLevel
        word.consecutiveCorrect = result.newConsecutiveCorrect
        word.reviewCount = result.newReviewCount
        word.nextReviewDate = Calendar.current.date(
            byAdding: .day,
            value: result.nextInterval,
            to: Date()
        ) ?? Date()
    }
}
