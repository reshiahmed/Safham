# Safham - سأفهم - Quranic Vocabulary Builder

Safham is an offline-first iOS app that helps users memorize and understand Quranic Arabic vocabulary through:
- Surah/Juz based content selection
- Pre-extracted vocabulary lists
- Spaced repetition reviews (SM-2)
- Mastery tracking (Learning -> Familiar -> Mastered)
- Reciter-aware word audio hooks
- Daily reminder scheduling

## What is implemented in this v1 codebase

- Full SwiftUI app scaffold aligned to the PRD screens:
1. Onboarding
2. Home dashboard
3. Content browser (Surah/Juz)
4. Vocabulary list
5. Flashcard review session
6. Session summary
7. Word detail
8. Settings

- Core domain + services:
- `SM2Scheduler` for review intervals and mastery progression
- `VocabularyService` for extraction/filtering/merging
- `ReviewEngine` for due queue and session summary
- `ReminderService` (UNUserNotificationCenter)
- `AudioService` (AVAudioPlayer for bundled assets)

- Persistence:
- SwiftData entities for word progress and app settings
- Repository layer for loading/saving progress/settings

- Seed dataset:
- Bundled JSON seed file at `SafhamApp/Resources/Seed/safham_seed.json`
- Includes real sample vocabulary and references for selected surahs
- App auto-fills missing surahs/juz to support full browser navigation (1..114, 1..30)

- Unit tests:
- SM-2 scheduling behavior
- Vocabulary extraction + function-word filtering

## Project structure

```text
Safham/
|- SafhamApp/
|  |- App/
|  |- Models/
|  |- Persistence/
|  |- Services/
|  |- ViewModels/
|  |- Views/
|  `- Resources/Seed/
|- SafhamAppTests/
`- project.yml
```

## Build and run (XcodeGen)

1. Install XcodeGen on macOS.
2. Generate the Xcode project:
```bash
xcodegen generate
```
3. Open `Safham.xcodeproj` in Xcode.
4. Select the `Safham` scheme and run on iOS 16+ simulator/device.

## Notes for production readiness

- Audio files are expected under `Resources/Audio/<reciter>/<word-key>.mp3` (not bundled yet).
- Seed vocabulary is intentionally small for this initial implementation; replace with the full precomputed Quran dataset for launch.
- Ayah-range selection UI is not yet exposed in the content browser, though the domain model and extractor support it.
