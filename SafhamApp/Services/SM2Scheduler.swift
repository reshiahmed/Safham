import Foundation

struct SM2Scheduler {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func applyReview(to progress: WordProgress, correct: Bool, on reviewedAt: Date = Date()) -> WordProgress {
        var updated = progress
        updated.reviewCount += 1
        updated.lastWasCorrect = correct

        if correct {
            updated.correctCount += 1
            updated.correctStreak += 1
            updated.easeFactor = min(3.2, updated.easeFactor + 0.05)
            updated.intervalDays = nextIntervalAfterCorrect(correctCount: updated.correctCount, previousInterval: updated.intervalDays, easeFactor: updated.easeFactor)
        } else {
            updated.correctStreak = 0
            updated.intervalDays = 1
            updated.easeFactor = max(1.3, updated.easeFactor - 0.2)
        }

        updated.masteryLevel = Self.masteryLevel(for: updated)
        updated.nextReviewDate = calendar.date(byAdding: .day, value: max(1, updated.intervalDays), to: reviewedAt) ?? reviewedAt

        return updated
    }

    static func masteryLevel(for progress: WordProgress) -> MasteryLevel {
        if !progress.lastWasCorrect || progress.correctCount < 3 {
            return .learning
        }

        if progress.correctCount >= 5 && progress.intervalDays >= 14 {
            return .mastered
        }

        return .familiar
    }

    private func nextIntervalAfterCorrect(correctCount: Int, previousInterval: Int, easeFactor: Double) -> Int {
        switch correctCount {
        case 1:
            return 1
        case 2:
            return 3
        case 3:
            return 7
        case 4:
            return 14
        case 5:
            return 30
        default:
            let base = max(1, previousInterval)
            return max(1, Int((Double(base) * easeFactor).rounded()))
        }
    }
}
