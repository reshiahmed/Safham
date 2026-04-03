import XCTest
@testable import Safham

final class SM2SchedulerTests: XCTestCase {
    func testFiveCorrectAnswersReachMastered() {
        let scheduler = SM2Scheduler()
        var progress = WordProgress.fresh(now: Date())

        for _ in 0..<5 {
            progress = scheduler.applyReview(to: progress, correct: true, on: Date())
        }

        XCTAssertEqual(progress.correctCount, 5)
        XCTAssertEqual(progress.masteryLevel, .mastered)
        XCTAssertGreaterThanOrEqual(progress.intervalDays, 14)
    }

    func testIncorrectDemotesAndResetsInterval() {
        let scheduler = SM2Scheduler()
        var progress = WordProgress.fresh(now: Date())

        for _ in 0..<4 {
            progress = scheduler.applyReview(to: progress, correct: true, on: Date())
        }

        XCTAssertEqual(progress.masteryLevel, .familiar)

        progress = scheduler.applyReview(to: progress, correct: false, on: Date())

        XCTAssertEqual(progress.intervalDays, 1)
        XCTAssertEqual(progress.masteryLevel, .learning)
        XCTAssertEqual(progress.lastWasCorrect, false)
    }

    func testEaseFactorNeverDropsBelowFloor() {
        let scheduler = SM2Scheduler()
        var progress = WordProgress.fresh(now: Date())

        for _ in 0..<20 {
            progress = scheduler.applyReview(to: progress, correct: false, on: Date())
        }

        XCTAssertEqual(progress.easeFactor, 1.3)
    }
}
