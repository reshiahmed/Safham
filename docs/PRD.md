# Product Requirements Document
# Safham — سأفهم — Quranic Vocabulary Builder

**Version:** 1.1  
**Status:** Draft  
**Author:** Ahmed  
**Last Updated:** April 2026

> *Safham (سأفهم) — Arabic for "I will understand." A personal promise, not just an app name.*

---

## 1. Overview

### 1.1 Problem Statement

Millions of Muslims worldwide memorize the Quran (hifz) or read it daily without understanding the Arabic words they're reciting. Existing Arabic learning apps (Duolingo, Rosetta Stone) teach conversational Arabic — not Quranic Arabic. Dedicated Quran apps focus on recitation and tajweed — not vocabulary retention. There is no focused, well-designed tool that bridges these two: extracting vocabulary from the specific ayahs a user is memorizing and building mastery over time.

### 1.2 Solution

A native iOS app where users input the surahs or ayahs they are currently memorizing, and the app automatically extracts the key vocabulary, teaches each word in context using spaced repetition, tracks mastery per word, and provides audio pronunciation from multiple world-renowned reciters. The goal is for the user to one day recite and *understand* simultaneously.

### 1.3 Target Users

- **Primary**: Muslims actively doing hifz (Quran memorization), aged 13–40
- **Secondary**: Muslims who want to understand their daily Salah and Quran recitation
- **Tertiary**: Arabic language learners specifically focused on Classical/Quranic Arabic

### 1.4 Business Model

- **One-time purchase**: $7.99 (App Store)
- No subscription, no ads — this builds trust with the target audience
- Future: optional $2.99 IAP for expanded root-word analysis and grammar notes

---

## 2. Goals & Success Metrics

### 2.1 Launch Goals (Month 1–3)
| Metric | Target |
|---|---|
| Downloads | 1,000+ |
| Revenue | $7,990+ |
| Day-7 Retention | ≥ 40% |
| Day-30 Retention | ≥ 20% |
| App Store Rating | ≥ 4.5 ⭐ |

### 2.2 North Star Metric
**Words mastered per user per week** — this is the core value delivery. Everything in the product should serve this number.

---

## 3. Scope

### 3.1 In Scope (v1.0)
- Surah/ayah selection and vocabulary extraction
- Juz filter alongside surah browser
- Flashcard system with spaced repetition (SM-2 algorithm)
- Three-tier mastery tracking per word (Learning → Familiar → Mastered)
- Audio pronunciation per word — multiple reciters selectable in Settings
- English translation + transliteration per word
- Tashkeel (diacritics) toggle in Settings
- Progress dashboard per surah/juz
- Daily review session (card limit configurable in Settings)
- Daily reminder notification (configurable in Settings)

### 3.2 Out of Scope (v1.0)
- Full grammar / i'rab analysis
- Root word breakdown → v1.1
- Community / group features → v2.0
- Android version
- Web version
- Teacher/student mode

---

## 4. User Stories

**As a user memorizing Surah Al-Mulk,**
I want to select that surah and see all the key vocabulary extracted from it,
so that I can learn the meaning of words I'm reciting daily.

**As a user with 10 minutes before Fajr,**
I want to open the app and immediately start a review session,
so that I don't have to configure anything — just learn.

**As a user who has reviewed a word 5 times,**
I want it marked as Mastered and shown less frequently,
so that my sessions stay focused on what I actually need to practice.

**As a user who organizes memorization by juz,**
I want to browse and add vocabulary by juz number,
so that the app matches how I think about my hifz.

**As a user improving my Arabic script reading,**
I want to toggle transliteration off in Settings,
so that I can challenge myself without the romanized crutch.

**As a user who prefers a specific reciter,**
I want to choose my preferred reciter in Settings and hear every word in their voice,
so that my audio experience stays familiar and consistent.

---

## 5. Feature Specifications

### 5.1 Surah / Juz Selection & Vocabulary Extraction

**User Flow:**
1. User taps "Add Content" on home screen
2. Toggles between **Surah** and **Juz** browser at top
3. Selects a surah, a full juz, or a specific ayah range within a surah
4. App displays extracted vocabulary — Arabic word, transliteration, English meaning, frequency in selection

**Requirements:**
- All 114 surahs and all 30 juz available at launch, stored locally (no internet required)
- Vocabulary pre-extracted and bundled — no runtime API dependency
- Words ranked by frequency; most common appear first
- Function words (و، في، من، etc.) included but tagged and hideable via Settings
- Each word links back to the ayah(s) it appears in

**Data Model per Word:**
```
{
  arabic: "يَعْلَمُ",
  transliteration: "ya'lamu",
  meaning: "He knows",
  root: "ع-ل-م",
  frequency: 3,
  ayahRefs: [{ surah: 67, ayah: 7 }, ...],
  masteryLevel: 0–2,        // 0=Learning, 1=Familiar, 2=Mastered
  nextReviewDate: Date,
  reviewCount: Int,
  easeFactor: Float          // SM-2
}
```

### 5.2 Flashcard Review System

**Card (front → back):**
- Front: Arabic word in large Amiri / KFGQPC Naskh font
- Back: Transliteration (if enabled) + English meaning + example ayah in context

**Interaction:**
- Swipe right = Correct
- Swipe left = Incorrect
- Tap audio icon = hear pronunciation in selected reciter's voice
- Tap ayah snippet = expand to full ayah view

**Spaced Repetition (SM-2 Algorithm):**
- New words: reviewed same day → day 1 → 3 → 7 → 14 → 30
- Correct: interval × ease factor (default 2.5)
- Incorrect: interval reset to 1, ease factor − 0.2 (floor 1.3)
- Daily session only surfaces cards due today

**Session:**
- Card limit configurable in Settings (10 / 20 / 30, default 20)
- Ends with summary: words reviewed, mastery level changes, streak
- Option to keep going after limit

### 5.3 Mastery System

| Level | Label | Color | Criteria |
|---|---|---|---|
| 0 | Learning | 🔴 Red | Seen < 3× or last answered wrong |
| 1 | Familiar | 🟡 Yellow | Correct 3+ times, interval < 14 days |
| 2 | Mastered | 🟢 Green | Correct 5+ times, interval ≥ 14 days |

- Mastered words resurface monthly — forgetting is still a risk
- User can manually demote any word to Learning from Word Detail screen

### 5.4 Audio Pronunciation

Users select one reciter as their global default in Settings. All word-level audio uses that reciter consistently throughout the app.

| Reciter | Style | Why Include |
|---|---|---|
| Mishary Rashid Alafasy | Murattal | Most beloved globally, warm and clear |
| Abdul Rahman Al-Sudais | Murattal | Imam of Masjid Al-Haram, iconic voice |
| Maher Al-Muaiqly | Murattal | Modern, crisp, widely used in apps |
| Saad Al-Ghamdi | Murattal | Popular in hifz circles, steady pace |
| Mahmoud Khalil Al-Husary | Murattal (slow) | Ideal for beginners, extremely clear |
| Hani Ar-Rifai | Murattal | Calm, meditative quality |
| Yusuf Islam (Cat Stevens) | Murattal | Unique tone, appeals to Western Muslims |
| Abdullah Basfar | Murattal | Clear Tajweed, popular in Gulf region |
| Nasser Al-Qatami | Murattal | Beautiful melodic delivery |

- All audio bundled locally — fully offline, no streaming
- Slow-mode (70% speed) toggle per word, independent of reciter choice
- Speaker icon available on every screen that displays Arabic text
- All reciters used under open/permissive licensing — credits listed in Settings > About

### 5.5 Settings Screen

Every previously open question is resolved here. Defaults work for 90% of users — Settings are powerful but unobtrusive.

| Setting | Options | Default |
|---|---|---|
| Reciter | 9 reciters | Mishary Rashid Alafasy |
| Tashkeel (diacritics) | On / Off | On |
| Transliteration | On / Off | On |
| Hide function words | On / Off | Off |
| Default browse mode | Surah / Juz | Surah |
| Daily session card limit | 10 / 20 / 30 | 20 |
| Daily reminder | On / Off + time picker | Off |
| Theme | Dark (OLED) / Light | Dark |
| Audio slow mode | On / Off | Off |

### 5.6 Progress Dashboard

**Per Surah / Juz View:**
- Total vocabulary words
- % Learning / Familiar / Mastered (ring chart)
- Estimated days to full mastery at current pace
- Words due for review today

**Home Screen:**
- Daily streak counter
- Total words mastered across all content
- Today's session card (due count + estimated minutes)
- Recently added surahs/juz with progress rings

### 5.7 Daily Reminder Notification

- Configurable time in Settings
- Suggested first-run prompt: offer to set 15 min before Fajr based on location (opt-in)
- Message: "X words due today. ~Y minutes."
- Fully opt-in, never shown without explicit user action in Settings

---

## 6. Community Features (v2.0)

Community is on the roadmap. Deferred to keep v1 lean and focused.

### Planned for v2.0
- **Hifz Groups**: Join or create a group (mosque circle, class, friends). See each other's mastery progress at word level.
- **Weekly Leaderboard**: Most words mastered this week within your group.
- **Shared Vocab Lists**: Group admin pushes a specific surah/juz to all members.
- **Community Memory Notes**: User-submitted tips per word (e.g. "think of علم as 'knowledge flag'"). Upvoted by the community.
- **Backend**: Supabase for accounts, groups, community content. iCloud sync for solo users who skip groups.

### Community Design Principles
- No social feed, no comments section, no DMs
- Progress sharing is opt-in and word-level only
- Teacher/admin roles are simple — no complex permissions in v2
- Community notes are flaggable and moderated

---

## 7. Design Direction

### 7.1 Aesthetic
- **Theme**: OLED dark mode primary, optional light mode
- **Feel**: Calm, focused, sacred — not gamified, not childish
- **Typography**: Amiri or KFGQPC Naskh for Arabic text; SF Pro for all UI elements
- **Palette**: Deep blacks, warm gold (#C9A84C), muted green for mastered state
- Transitions are subtle and intentional — no bouncy gamification animations

### 7.2 Design Principles
- Arabic text is always large and prominent — never a secondary element
- One primary action per screen
- Sessions feel like a ritual, not a productivity task
- Settings are powerful but the defaults should just work

### 7.3 Screens (MVP)
1. Onboarding — 3 screens: what it does, pick first content, set reminder
2. Home / Dashboard
3. Content Browser (Surah / Juz toggle)
4. Vocabulary List (per surah or juz)
5. Flashcard Review Session
6. Session Summary
7. Word Detail (full context, ayah reference, audio)
8. Settings

---

## 8. Technical Architecture

### 8.1 Stack
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Minimum iOS**: iOS 16
- **Persistence**: SwiftData (local, no account required for v1)
- **Audio**: AVFoundation
- **Notifications**: UNUserNotificationCenter

### 8.2 Data
- All Quran text, vocabulary data, and audio bundled in the app binary
- Fully offline — no internet connection ever required for v1
- User progress (mastery, review dates, ease factors) stored in SwiftData

### 8.3 Quran Data Source
- quran.com API or Al-Quran Cloud API used to build the bundled JSON dataset at dev time
- No runtime API calls for Quran content

### 8.4 v2 Backend (Community)
- Supabase for user accounts, groups, community notes
- iCloud sync as the lightweight alternative for non-community users

---

## 9. Monetization

### 9.1 Pricing
- **One-time purchase: $7.99**
- No freemium tier, no paywalls mid-session, no subscriptions

### 9.2 Future IAPs (v1.1+)
| Feature | Price |
|---|---|
| Root Word Analysis Pack | $2.99 one-time |
| Grammar Notes per Ayah | $2.99 one-time |
| Additional Reciter Packs | $1.99 one-time |

### 9.3 Revenue Projections (Conservative)
| Month | Downloads | Revenue |
|---|---|---|
| 1 | 150 | $1,199 |
| 2 | 300 | $2,397 |
| 3 | 500 | $3,995 |
| 6 | 1,500 | $11,985 cumulative |

---

## 10. Go-To-Market

### 10.1 Channels
- **Reddit**: r/islam, r/LearnArabic, r/Quran, r/HifzProgress — genuine posts showing the product
- **X / Twitter**: #Quran #Hifz #LearnArabic — build in public, document the journey
- **Islamic forums**: MuslimMatters, SeekersGuidance community boards
- **Mosques & Islamic schools**: Direct outreach, offer group promo codes

### 10.2 Positioning
> "Finally understand what you're reciting."

Not an Arabic course. Not a Quran reader. The bridge between memorization and meaning.

### 10.3 App Store Optimization
- **Primary keyword**: Quran vocabulary
- **Secondary**: Quranic Arabic, Quran memorization, hifz helper, learn Arabic Quran, safham
- **Screenshots**: Flashcard in action, mastery progress ring, reciter selector, ayah in context

---

## 11. Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Audio licensing issues | Medium | Use open-license recitation datasets; credit all reciters in Settings > About |
| App Store rejection | Low | Follow Apple guidelines strictly; no controversial content |
| Low organic discovery | Medium | Reddit + X community strategy before App Store submission |
| Scope creep | High | v1 is locked to this PRD — everything else goes to the backlog |

---

## 12. Milestones

| Milestone | Target | Deliverable |
|---|---|---|
| M0 — PRD Final | Week 1 | This document |
| M1 — Data Layer | Week 2–3 | Quran JSON + audio bundled, SwiftData schema, SM-2 algorithm |
| M2 — Core UI | Week 4–5 | Home, Surah/Juz browser, Vocabulary list screens |
| M3 — Flashcard Engine | Week 6–7 | Full review session with swipe, audio, mastery tracking |
| M4 — Settings + Polish | Week 8 | All settings functional, onboarding flow, notifications |
| M5 — TestFlight | Week 9 | 10–20 beta testers from Muslim hifz groups on Reddit/WhatsApp |
| M6 — App Store Launch | Week 10–11 | Submitted, approved, live |

---

*v1.0 scope is locked. Community features (v2.0) and root word analysis (v1.1) are explicitly deferred.*
