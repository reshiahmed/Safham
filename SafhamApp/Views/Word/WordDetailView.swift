import SwiftUI

struct WordDetailView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var word: VocabWord

    init(word: VocabWord) {
        _word = State(initialValue: word)
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(viewModel.displayArabic(for: word))
                            .font(.largeTitle.weight(.medium))
                        Spacer()
                        MasteryBadge(level: word.progress.masteryLevel)
                    }

                    if viewModel.settings.showTransliteration {
                        Text(word.transliteration)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }

                    Text(word.meaning)
                        .font(.title3)

                    if let root = word.root, !root.isEmpty {
                        Text("Root: \(root)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }

            Section("Audio") {
                Button {
                    viewModel.audioService.playWord(
                        key: word.key,
                        reciter: viewModel.settings.reciter,
                        slowMode: viewModel.settings.audioSlowMode
                    )
                } label: {
                    Label("Play with \(viewModel.settings.reciter.displayName)", systemImage: "speaker.wave.2.fill")
                }
            }

            Section("Ayah References") {
                ForEach(Array(word.ayahRefs.enumerated()), id: \.offset) { _, ref in
                    Text("Surah \(ref.surah), Ayah \(ref.ayah)")
                }
            }

            Section("Review Data") {
                statRow(label: "Frequency", value: "\(word.frequency)")
                statRow(label: "Reviews", value: "\(word.progress.reviewCount)")
                statRow(label: "Correct Answers", value: "\(word.progress.correctCount)")
                statRow(label: "Ease Factor", value: String(format: "%.2f", word.progress.easeFactor))
                statRow(label: "Next Review", value: word.progress.nextReviewDate.formatted(date: .abbreviated, time: .omitted))
            }

            Section {
                Button(role: .destructive) {
                    viewModel.demoteToLearning(word)
                    var updated = word
                    updated.progress.masteryLevel = .learning
                    updated.progress.nextReviewDate = Date()
                    updated.progress.lastWasCorrect = false
                    word = updated
                } label: {
                    Text("Demote to Learning")
                }
            }
        }
        .navigationTitle("Word Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
}
