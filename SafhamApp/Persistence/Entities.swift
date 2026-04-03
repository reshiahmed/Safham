import Foundation
import SwiftData

@Model
final class WordProgressEntity {
    @Attribute(.unique) var key: String
    var masteryRawValue: Int
    var nextReviewDate: Date
    var reviewCount: Int
    var correctCount: Int
    var easeFactor: Double
    var intervalDays: Int
    var correctStreak: Int
    var lastWasCorrect: Bool

    init(key: String, progress: WordProgress) {
        self.key = key
        masteryRawValue = progress.masteryLevel.rawValue
        nextReviewDate = progress.nextReviewDate
        reviewCount = progress.reviewCount
        correctCount = progress.correctCount
        easeFactor = progress.easeFactor
        intervalDays = progress.intervalDays
        correctStreak = progress.correctStreak
        lastWasCorrect = progress.lastWasCorrect
    }

    func apply(progress: WordProgress) {
        masteryRawValue = progress.masteryLevel.rawValue
        nextReviewDate = progress.nextReviewDate
        reviewCount = progress.reviewCount
        correctCount = progress.correctCount
        easeFactor = progress.easeFactor
        intervalDays = progress.intervalDays
        correctStreak = progress.correctStreak
        lastWasCorrect = progress.lastWasCorrect
    }

    var model: WordProgress {
        WordProgress(
            masteryLevel: MasteryLevel(rawValue: masteryRawValue) ?? .learning,
            nextReviewDate: nextReviewDate,
            reviewCount: reviewCount,
            correctCount: correctCount,
            easeFactor: easeFactor,
            intervalDays: intervalDays,
            correctStreak: correctStreak,
            lastWasCorrect: lastWasCorrect
        )
    }
}

@Model
final class AppSettingsEntity {
    @Attribute(.unique) var profileID: String
    var reciterRawValue: String
    var showTashkeel: Bool
    var showTransliteration: Bool
    var hideFunctionWords: Bool
    var defaultBrowseModeRawValue: String
    var dailyCardLimit: Int
    var reminderEnabled: Bool
    var reminderHour: Int
    var reminderMinute: Int
    var themeRawValue: String
    var audioSlowMode: Bool

    init(profileID: String = "default", settings: AppSettings) {
        self.profileID = profileID
        reciterRawValue = settings.reciter.rawValue
        showTashkeel = settings.showTashkeel
        showTransliteration = settings.showTransliteration
        hideFunctionWords = settings.hideFunctionWords
        defaultBrowseModeRawValue = settings.defaultBrowseMode.rawValue
        dailyCardLimit = settings.dailyCardLimit
        reminderEnabled = settings.reminder.enabled
        reminderHour = settings.reminder.hour
        reminderMinute = settings.reminder.minute
        themeRawValue = settings.theme.rawValue
        audioSlowMode = settings.audioSlowMode
    }

    func apply(settings: AppSettings) {
        reciterRawValue = settings.reciter.rawValue
        showTashkeel = settings.showTashkeel
        showTransliteration = settings.showTransliteration
        hideFunctionWords = settings.hideFunctionWords
        defaultBrowseModeRawValue = settings.defaultBrowseMode.rawValue
        dailyCardLimit = settings.dailyCardLimit
        reminderEnabled = settings.reminder.enabled
        reminderHour = settings.reminder.hour
        reminderMinute = settings.reminder.minute
        themeRawValue = settings.theme.rawValue
        audioSlowMode = settings.audioSlowMode
    }

    var model: AppSettings {
        AppSettings(
            reciter: Reciter(rawValue: reciterRawValue) ?? .alafasy,
            showTashkeel: showTashkeel,
            showTransliteration: showTransliteration,
            hideFunctionWords: hideFunctionWords,
            defaultBrowseMode: BrowseMode(rawValue: defaultBrowseModeRawValue) ?? .surah,
            dailyCardLimit: dailyCardLimit,
            reminder: ReminderSettings(enabled: reminderEnabled, hour: reminderHour, minute: reminderMinute),
            theme: ThemePreference(rawValue: themeRawValue) ?? .dark,
            audioSlowMode: audioSlowMode
        )
    }
}
