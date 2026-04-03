# Safham — سأفهم — Quranic Vocabulary Builder

> *Safham (سأفهم) — Arabic for "I will understand." A personal promise, not just an app name.*

A native iOS app that helps Muslims understand the Arabic words they're reciting in the Quran through intelligent vocabulary extraction, spaced repetition flashcards, and audio pronunciation from world-renowned reciters.

## Overview

This repository contains the product specification, design documentation, and development artifacts for Safham v1.0.

## Project Structure

```
safham/
├── docs/
│   └── PRD.md              # Product Requirements Document
├── README.md               # This file
└── .gitignore              # Git ignore rules
```

## Key Features (v1.0)

- **Surah/Juz Selection** — Choose what you're memorizing
- **Vocabulary Extraction** — Automatic extraction of key words from selected content
- **Spaced Repetition** — SM-2 algorithm for optimal learning
- **Mastery Tracking** — Three-tier system: Learning → Familiar → Mastered
- **Audio Pronunciation** — 9 world-renowned reciters, fully offline
- **Progress Dashboard** — Track mastery per surah/juz
- **Configurable Settings** — Reciter, tashkeel, transliteration, reminder times, and more

## Tech Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Minimum iOS**: iOS 16
- **Persistence**: SwiftData
- **Audio**: AVFoundation
- **Notifications**: UNUserNotificationCenter

## Monetization

**One-time purchase: $7.99** — No subscriptions, no ads, fully offline.

Future IAPs include root word analysis and grammar notes (v1.1+).

## Roadmap

| Milestone | Timeline | Deliverable |
|-----------|----------|------------|
| M0 — PRD Final | Week 1 | ✅ Complete |
| M1 — Data Layer | Week 2–3 | Quran JSON + audio, SwiftData schema |
| M2 — Core UI | Week 4–5 | Home, browser, vocabulary screens |
| M3 — Flashcard Engine | Week 6–7 | Review session, spaced repetition |
| M4 — Settings + Polish | Week 8 | All settings, onboarding, notifications |
| M5 — TestFlight | Week 9 | Beta testing |
| M6 — App Store Launch | Week 10–11 | Public release |

## Community (v2.0)

Planned features for v2.0 include hifz groups, community leaderboards, shared vocabulary lists, and community memory notes via Supabase backend.

## License

TBD

## Contact

**Author**: Ahmed  
**Status**: Draft PRD (In Development)  
**Last Updated**: April 2026
