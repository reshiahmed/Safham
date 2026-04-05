//
//  FlashcardReviewView.swift
//  Safham
//
//  Full-screen flashcard review session with swipe gestures and SM-2.
//

import SwiftUI
import SwiftData

struct FlashcardReviewView: View {
    let words: [Word]
    let surahName: String

    @ObservedObject var settings = AppSettings.shared
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allStats: [UserStats]

    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var dragOffset: CGSize = .zero
    @State private var sessionResults: [SessionResult] = []
    @State private var showSummary = false

    private var currentWord: Word? {
        guard currentIndex < words.count else { return nil }
        return words[currentIndex]
    }

    private var progress: Double {
        words.isEmpty ? 0 : Double(currentIndex) / Double(words.count)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if showSummary {
                SessionSummaryView(
                    results: sessionResults,
                    surahName: surahName,
                    onDone: {
                        updateStreak()
                        dismiss()
                    }
                )
                .transition(.opacity)
            } else {
                mainContent
            }
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut, value: showSummary)
    }

    // MARK: - Main content

    private var mainContent: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                Spacer()
                Text("\(currentIndex + 1) / \(words.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                // placeholder to balance layout
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray5))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "C9A84C"))
                        .frame(width: geo.size.width * progress)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer()

            if let word = currentWord {
                flashcard(for: word)
                    .gesture(
                        DragGesture()
                            .onChanged { dragOffset = $0.translation }
                            .onEnded { value in
                                handleSwipe(translation: value.translation, word: word)
                            }
                    )
                    .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (0, 1, 0))
                    .onTapGesture { withAnimation(.spring()) { isFlipped.toggle() } }
                    .offset(x: dragOffset.width * 0.5)
                    .animation(.interactiveSpring(), value: dragOffset)
            }

            Spacer()

            // Action hint
            if !isFlipped {
                Text("Tap to reveal • Swipe to answer")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            } else {
                answerButtons(for: currentWord!)
                    .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Flashcard

    private func flashcard(for word: Word) -> some View {
        ZStack {
            // Front face
            if !isFlipped {
                frontFace(word: word)
            } else {
                // Back face — mirrored to appear correct after 3D flip
                backFace(word: word)
                    .rotation3DEffect(.degrees(180), axis: (0, 1, 0))
            }
        }
        .frame(width: 340, height: 420)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(.systemGray6))
                .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 8)
        )
        .overlay(
            // Swipe direction tint
            RoundedRectangle(cornerRadius: 28)
                .fill(swipeTint)
                .animation(.easeOut(duration: 0.15), value: dragOffset.width)
        )
    }

    private func frontFace(word: Word) -> some View {
        VStack(spacing: 16) {
            // Mastery badge
            masteryBadge(word.masteryLevel)

            Spacer()

            Text(word.arabic)
                .font(.system(size: 68, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)

            if let root = word.root {
                Text("Root: \(root)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Audio placeholder
            Button(action: { /* AVFoundation audio – v1.1 */ }) {
                HStack(spacing: 6) {
                    Image(systemName: "speaker.wave.2.fill")
                    Text(settings.selectedReciter.components(separatedBy: " ").first ?? "")
                }
                .font(.caption)
                .foregroundColor(Color(hex: "C9A84C"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: "C9A84C").opacity(0.15))
                .cornerRadius(20)
            }
        }
        .padding(28)
    }

    private func backFace(word: Word) -> some View {
        VStack(spacing: 12) {
            // Arabic (smaller on back)
            Text(word.arabic)
                .font(.system(size: 36, weight: .semibold, design: .serif))
                .foregroundColor(Color(hex: "C9A84C"))

            Divider().background(Color(.systemGray4))

            // Transliteration
            if settings.showTransliteration {
                Text(word.transliteration)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .italic()
            }

            // Meaning
            Text(word.meaning)
                .font(.title2.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            // Surah context
            if let surah = word.surahs.first {
                Divider().background(Color(.systemGray4))
                VStack(spacing: 4) {
                    Text("From \(surah.nameEnglish)")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    if !word.isFunctionWord {
                        Text("Appears \(word.frequency)× in this selection")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(28)
    }

    // MARK: - Answer buttons

    private func answerButtons(for word: Word) -> some View {
        HStack(spacing: 24) {
            // Wrong
            Button(action: { recordAnswer(correct: false, word: word) }) {
                VStack(spacing: 4) {
                    Image(systemName: "xmark")
                        .font(.title2.bold())
                    Text("Again")
                        .font(.caption.bold())
                }
                .frame(width: 100, height: 60)
                .foregroundColor(.red)
                .background(Color.red.opacity(0.15))
                .cornerRadius(16)
            }

            // Correct
            Button(action: { recordAnswer(correct: true, word: word) }) {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.title2.bold())
                    Text("Got it")
                        .font(.caption.bold())
                }
                .frame(width: 100, height: 60)
                .foregroundColor(.green)
                .background(Color.green.opacity(0.15))
                .cornerRadius(16)
            }
        }
    }

    // MARK: - Swipe handling

    private var swipeTint: Color {
        if dragOffset.width > 40 {
            return Color.green.opacity(min(0.25, dragOffset.width / 200))
        } else if dragOffset.width < -40 {
            return Color.red.opacity(min(0.25, -dragOffset.width / 200))
        }
        return Color.clear
    }

    private func handleSwipe(translation: CGSize, word: Word) {
        dragOffset = .zero
        guard isFlipped else {
            // First flip the card if not revealed
            withAnimation(.spring()) { isFlipped = true }
            return
        }
        if translation.width > 80 {
            recordAnswer(correct: true, word: word)
        } else if translation.width < -80 {
            recordAnswer(correct: false, word: word)
        }
    }

    // MARK: - SM-2 + progression

    private func recordAnswer(correct: Bool, word: Word) {
        let previousMastery = word.masteryLevel
        let result = SM2Algorithm.apply(correct: correct, word: word)
        SM2Algorithm.commit(result: result, to: word)

        sessionResults.append(SessionResult(
            word: word,
            wasCorrect: correct,
            previousMastery: previousMastery,
            newMastery: result.newMasteryLevel
        ))

        try? modelContext.save()
        advanceCard()
    }

    private func advanceCard() {
        withAnimation(.spring()) {
            isFlipped = false
            dragOffset = .zero
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if currentIndex + 1 >= words.count {
                withAnimation { showSummary = true }
            } else {
                currentIndex += 1
            }
        }
    }

    // MARK: - Streak

    private func updateStreak() {
        if let stats = allStats.first {
            DataService.shared.updateStreak(stats: stats)
            try? modelContext.save()
        }
    }

    // MARK: - Mastery badge

    private func masteryBadge(_ level: Int) -> some View {
        let (label, color): (String, Color) = {
            switch level {
            case 0: return ("Learning", .red)
            case 1: return ("Familiar", .yellow)
            default: return ("Mastered", .green)
            }
        }()
        return Text(label)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

// MARK: - Data model for session

struct SessionResult {
    let word: Word
    let wasCorrect: Bool
    let previousMastery: Int
    let newMastery: Int

    var leveledUp: Bool { newMastery > previousMastery }
}

#Preview {
    FlashcardReviewView(
        words: [],
        surahName: "Al-Faatiha"
    )
}
