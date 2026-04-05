//
//  VocabularyListView.swift
//  Safham
//
//  Shows all vocabulary words for a specific surah with mastery indicators.
//

import SwiftUI
import SwiftData

struct VocabularyListView: View {
    let surah: Surah
    @ObservedObject var settings = AppSettings.shared
    @Environment(\.modelContext) private var modelContext
    @State private var reviewSession: [Word]? = nil
    @State private var showReview = false

    private var displayWords: [Word] {
        var words = surah.words
        if settings.hideFunctionWords {
            words = words.filter { !$0.isFunctionWord }
        }
        return words.sorted { $0.frequency > $1.frequency }
    }

    private var dueWords: [Word] {
        displayWords.filter { $0.nextReviewDate <= Date() }
    }

    var body: some View {
        Group {
            if surah.isAdded {
                addedContent
            } else {
                emptyState
            }
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle(surah.nameEnglish)
        .navigationBarTitleDisplayMode(.large)
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text(surah.nameArabic)
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(Color(hex: "C9A84C"))
            }
        }
        .fullScreenCover(isPresented: $showReview) {
            if let words = reviewSession {
                FlashcardReviewView(words: words, surahName: surah.nameEnglish)
            }
        }
    }

    // MARK: - Content when surah is added

    private var addedContent: some View {
        VStack(spacing: 0) {
            // Stats bar
            HStack(spacing: 24) {
                MiniStatView(label: "Total", value: "\(displayWords.count)", color: .white)
                MiniStatView(label: "Learning",
                             value: "\(displayWords.filter { $0.masteryLevel == 0 }.count)",
                             color: .red)
                MiniStatView(label: "Familiar",
                             value: "\(displayWords.filter { $0.masteryLevel == 1 }.count)",
                             color: .yellow)
                MiniStatView(label: "Mastered",
                             value: "\(displayWords.filter { $0.masteryLevel == 2 }.count)",
                             color: .green)
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.4))

            // Review button
            if !dueWords.isEmpty {
                Button(action: startReview) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("\(dueWords.count) words due — Review Now")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "C9A84C"))
                    .foregroundColor(.black)
                }
            }

            if displayWords.isEmpty {
                noVocabPlaceholder
            } else {
                wordList
            }
        }
    }

    private var wordList: some View {
        List {
            ForEach(displayWords) { word in
                NavigationLink(destination: WordDetailView(word: word)) {
                    VocabularyWordRow(word: word, showTransliteration: settings.showTransliteration,
                                     showTashkeel: settings.showTashkeel)
                }
                .listRowBackground(Color(.systemGray6).opacity(0.2))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var noVocabPlaceholder: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "text.book.closed")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No vocabulary data yet for this surah.")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("More surahs are being added in upcoming updates.")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    // MARK: - Not-yet-added state

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "plus.circle")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "C9A84C"))
            Text("Add this surah to start learning its vocabulary.")
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Add \(surah.nameEnglish)") {
                DataService.shared.addSurah(surah, modelContext: modelContext)
            }
            .font(.headline)
            .padding(.horizontal, 40)
            .padding(.vertical, 14)
            .background(Color(hex: "C9A84C"))
            .foregroundColor(.black)
            .cornerRadius(16)
            Spacer()
        }
    }

    // MARK: - Actions

    private func startReview() {
        let limit = settings.dailyCardLimit
        reviewSession = Array(dueWords.prefix(limit))
        showReview = true
    }
}

// MARK: - Subviews

struct VocabularyWordRow: View {
    let word: Word
    let showTransliteration: Bool
    let showTashkeel: Bool

    private var displayArabic: String {
        showTashkeel ? word.arabic : word.arabic.removingDiacritics()
    }

    var body: some View {
        HStack(spacing: 12) {
            // Mastery indicator
            Circle()
                .fill(masteryColor(word.masteryLevel))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(word.meaning)
                    .font(.subheadline)
                    .foregroundColor(.white)
                if showTransliteration {
                    Text(word.transliteration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(displayArabic)
                    .font(.system(size: 20, design: .serif))
                    .foregroundColor(Color(hex: "C9A84C"))
                if let root = word.root {
                    Text(root)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func masteryColor(_ level: Int) -> Color {
        switch level {
        case 0: return .red
        case 1: return .yellow
        default: return .green
        }
    }
}

struct MiniStatView: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.headline).foregroundColor(color)
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
    }
}

// MARK: - String extension for tashkeel removal

extension String {
    func removingDiacritics() -> String {
        // Remove Arabic diacritics (harakat) U+0610–U+061A and U+064B–U+065F
        return self.unicodeScalars.filter { scalar in
            let v = scalar.value
            return !((v >= 0x0610 && v <= 0x061A) || (v >= 0x064B && v <= 0x065F))
        }.reduce("") { $0 + String($1) }
    }
}

#Preview {
    NavigationStack {
        VocabularyListView(surah: Surah(number: 1, nameArabic: "الفاتحة", nameEnglish: "Al-Faatiha", ayahCount: 7))
    }
}
