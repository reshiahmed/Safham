//
//  SessionSummaryView.swift
//  Safham
//
//  End-of-session summary: score, mastery level-ups, streak.
//

import SwiftUI
import SwiftData

struct SessionSummaryView: View {
    let results: [SessionResult]
    let surahName: String
    let onDone: () -> Void

    @Query private var stats: [UserStats]

    private var correctCount: Int { results.filter { $0.wasCorrect }.count }
    private var incorrectCount: Int { results.filter { !$0.wasCorrect }.count }
    private var levelUps: [SessionResult] { results.filter { $0.leveledUp } }
    private var accuracy: Double {
        results.isEmpty ? 0 : Double(correctCount) / Double(results.count)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    header
                    scoreCard
                    if !levelUps.isEmpty { levelUpSection }
                    streakSection
                    doneButton
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 24)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: accuracy >= 0.8 ? "star.fill" : accuracy >= 0.5 ? "checkmark.circle.fill" : "arrow.clockwise.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(Color(hex: "C9A84C"))
                .symbolEffect(.bounce, options: .speed(0.5))

            Text("Session Complete")
                .font(.title.bold())
                .foregroundColor(.white)

            Text(surahName)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var scoreCard: some View {
        HStack(spacing: 0) {
            ScoreItem(value: "\(results.count)", label: "Reviewed", color: .white)
            Divider().background(Color(.systemGray4)).frame(height: 40)
            ScoreItem(value: "\(correctCount)", label: "Correct", color: .green)
            Divider().background(Color(.systemGray4)).frame(height: 40)
            ScoreItem(value: "\(incorrectCount)", label: "Again", color: .red)
            Divider().background(Color(.systemGray4)).frame(height: 40)
            ScoreItem(value: "\(Int(accuracy * 100))%", label: "Accuracy", color: Color(hex: "C9A84C"))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }

    private var levelUpSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Level-ups")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(levelUps, id: \.word.arabic) { result in
                HStack {
                    Text(result.word.arabic)
                        .font(.system(size: 18, design: .serif))
                        .foregroundColor(Color(hex: "C9A84C"))
                    Text("→ \(result.word.meaning)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    masteryBadge(result.newMastery)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }

    private var streakSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(stats.first?.dailyStreak ?? 1) day streak")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Keep it up — review again tomorrow.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
    }

    private var doneButton: some View {
        Button(action: onDone) {
            Text("Done")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "C9A84C"))
                .foregroundColor(.black)
                .cornerRadius(16)
        }
    }

    // MARK: - Helpers

    private func masteryBadge(_ level: Int) -> some View {
        let (label, color): (String, Color) = {
            switch level {
            case 1: return ("Familiar", .yellow)
            case 2: return ("Mastered", .green)
            default: return ("Learning", .red)
            }
        }()
        return Text(label)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

struct ScoreItem: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.bold()).foregroundColor(color)
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SessionSummaryView(results: [], surahName: "Al-Faatiha", onDone: {})
}
