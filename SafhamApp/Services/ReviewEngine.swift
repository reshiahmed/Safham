import Foundation

struct ReviewEvent {
    let wordKey: String
    let previousMastery: MasteryLevel
    let updatedMastery: MasteryLevel
}

struct ReviewEngine {
    private let scheduler: SM2Scheduler

    init(scheduler: SM2Scheduler = SM2Scheduler()) {
        self.scheduler = scheduler
    }

    func dueWords(from words: [VocabWord], now: Date = Date(), limit: Int) -> [VocabWord] {
        words
            .filter { $0.progress.nextReviewDate <= now }
            .sorted {
                if $0.progress.nextReviewDate == $1.progress.nextReviewDate {
                    return $0.progress.masteryLevel.rawValue < $1.progress.masteryLevel.rawValue
                }
                return $0.progress.nextReviewDate < $1.progress.nextReviewDate
            }
            .prefix(limit)
            .map { $0 }
    }

    func applyAnswer(to word: VocabWord, correct: Bool, reviewedAt: Date = Date()) -> (updated: VocabWord, event: ReviewEvent) {
        var updatedWord = word
        let previous = word.progress.masteryLevel
        updatedWord.progress = scheduler.applyReview(to: word.progress, correct: correct, on: reviewedAt)

        let event = ReviewEvent(
            wordKey: word.key,
            previousMastery: previous,
            updatedMastery: updatedWord.progress.masteryLevel
        )
        return (updatedWord, event)
    }

    func summary(from events: [ReviewEvent], streak: Int, reviewedAt: Date = Date()) -> SessionSummary {
        let masteredBefore = events.filter { $0.previousMastery == .mastered }.count
        let masteredAfter = events.filter { $0.updatedMastery == .mastered }.count

        return SessionSummary(
            reviewedCount: events.count,
            masteredDelta: masteredAfter - masteredBefore,
            streak: streak,
            reviewedAt: reviewedAt
        )
    }

    func estimatedMinutes(for cardCount: Int) -> Int {
        max(1, Int((Double(cardCount) * 0.45).rounded(.up)))
    }
}
