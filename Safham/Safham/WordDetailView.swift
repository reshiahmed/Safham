//
//  WordDetailView.swift
//  Safham
//
//  Full word detail: Arabic, transliteration, meaning, root, mastery, ayah refs.
//

import SwiftUI
import SwiftData

struct WordDetailView: View {
    let word: Word
    @ObservedObject var settings = AppSettings.shared
    @Environment(\.modelContext) private var modelContext

    private var displayArabic: String {
        settings.showTashkeel ? word.arabic : word.arabic.removingDiacritics()
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 28) {
                    arabicCard
                    detailsCard
                    surahRefsCard
                    masteryCard
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle(word.meaning)
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                masteryBadge(word.masteryLevel)
            }
        }
    }

    // MARK: - Arabic card

    private var arabicCard: some View {
        VStack(spacing: 16) {
            Text(displayArabic)
                .font(.system(size: 72, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.4)
                .padding(.horizontal)

            if settings.showTransliteration {
                Text(word.transliteration)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .italic()
            }

            // Audio button (placeholder — actual audio in v1.1)
            Button(action: { }) {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill")
                    Text(settings.selectedReciter)
                        .lineLimit(1)
                }
                .font(.subheadline)
                .foregroundColor(Color(hex: "C9A84C"))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(hex: "C9A84C").opacity(0.15))
                .cornerRadius(24)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.systemGray6))
        .cornerRadius(24)
    }

    // MARK: - Details card

    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRow(label: "Meaning", value: word.meaning)
            Divider().background(Color(.systemGray5))
            if let root = word.root {
                detailRow(label: "Root", value: root)
                Divider().background(Color(.systemGray5))
            }
            detailRow(label: "Frequency", value: "\(word.frequency)× in this surah")
            Divider().background(Color(.systemGray5))
            detailRow(label: "Reviews", value: "\(word.reviewCount) total")
        }
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Surah references

    private var surahRefsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Appears In")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(word.surahs, id: \.number) { surah in
                HStack {
                    Image(systemName: "book.fill")
                        .foregroundColor(Color(hex: "C9A84C"))
                        .font(.caption)
                    Text(surah.nameEnglish)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Spacer()
                    Text(surah.nameArabic)
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(Color(hex: "C9A84C"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray5))
                .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    // MARK: - Mastery card

    private var masteryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mastery")
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 12) {
                ForEach(0..<3) { level in
                    masteryTile(level: level, isActive: word.masteryLevel == level)
                }
            }

            if word.masteryLevel > 0 {
                Button(action: demoteToLearning) {
                    Label("Reset to Learning", systemImage: "arrow.counterclockwise")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                }
            }

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                    .font(.caption)
                Text("Next review: \(formattedDate(word.nextReviewDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private func masteryTile(level: Int, isActive: Bool) -> some View {
        let (label, color): (String, Color) = {
            switch level {
            case 0: return ("Learning", .red)
            case 1: return ("Familiar", .yellow)
            default: return ("Mastered", .green)
            }
        }()
        return VStack(spacing: 4) {
            Circle()
                .fill(isActive ? color : Color(.systemGray5))
                .frame(width: 12, height: 12)
            Text(label)
                .font(.caption2)
                .foregroundColor(isActive ? color : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(isActive ? color.opacity(0.1) : Color(.systemGray5))
        .cornerRadius(10)
    }

    // MARK: - Actions

    private func demoteToLearning() {
        word.masteryLevel = 0
        word.consecutiveCorrect = 0
        word.interval = 0
        word.nextReviewDate = Date()
        try? modelContext.save()
    }

    // MARK: - Helpers

    private func formattedDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInTomorrow(date) { return "Tomorrow" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

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

#Preview {
    NavigationStack {
        WordDetailView(word: Word(arabic: "يَعْلَمُ", transliteration: "yaʿlamu",
                                  meaning: "He knows", root: "ع-ل-م", frequency: 3))
    }
}
