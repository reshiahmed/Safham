import SwiftUI

struct ReviewSessionView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var queue: [VocabWord]
    @State private var index = 0
    @State private var showBack = false
    @State private var summary: SessionSummary?

    init(queue: [VocabWord]) {
        _queue = State(initialValue: queue)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let summary {
                    SessionSummaryView(summary: summary) {
                        dismiss()
                    }
                } else if queue.isEmpty {
                    emptyState
                } else {
                    sessionBody
                }
            }
            .navigationTitle("Review")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var sessionBody: some View {
        let word = queue[index]

        return VStack(spacing: 24) {
            Text("Card \(index + 1) of \(queue.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 20) {
                Text(viewModel.displayArabic(for: word))
                    .font(.system(size: 44, weight: .medium, design: .default))
                    .multilineTextAlignment(.center)

                Button {
                    viewModel.audioService.playWord(
                        key: word.key,
                        reciter: viewModel.settings.reciter,
                        slowMode: viewModel.settings.audioSlowMode
                    )
                } label: {
                    Label("Play Audio", systemImage: "speaker.wave.2.fill")
                }
                .buttonStyle(.bordered)

                if showBack {
                    VStack(spacing: 10) {
                        if viewModel.settings.showTransliteration {
                            Text(word.transliteration)
                                .font(.headline)
                        }
                        Text(word.meaning)
                            .font(.title3)
                        if let reference = word.ayahRefs.first {
                            Text("Surah \(reference.surah), Ayah \(reference.ayah)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))

            if !showBack {
                Button("Show Answer") { showBack = true }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#C9A84C"))
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                HStack(spacing: 12) {
                    Button("Incorrect") {
                        handleAnswer(correct: false)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button("Correct") {
                        handleAnswer(correct: true)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .font(.headline)
            }

            Spacer()
        }
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("No cards due right now")
                .font(.title3.weight(.semibold))
            Text("Add more content or come back after your next interval.")
                .foregroundStyle(.secondary)
            Button("Close") { dismiss() }
        }
    }

    private func handleAnswer(correct: Bool) {
        guard index < queue.count else { return }
        let currentWord = queue[index]
        let updated = viewModel.applyAnswer(for: currentWord, correct: correct)
        queue[index] = updated
        showBack = false

        if index + 1 >= queue.count {
            summary = viewModel.finishSession()
        } else {
            index += 1
        }
    }
}
