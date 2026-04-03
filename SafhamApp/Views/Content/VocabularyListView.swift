import SwiftUI

struct VocabularyListView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    let selection: ContentSelection

    var body: some View {
        let words = viewModel.words(for: selection)
        let breakdown = viewModel.progressBreakdown(for: selection)

        List {
            Section {
                HStack {
                    statItem(title: "Learning", value: breakdown.learning, color: .red)
                    statItem(title: "Familiar", value: breakdown.familiar, color: .yellow)
                    statItem(title: "Mastered", value: breakdown.mastered, color: .green)
                }
            }

            Section("Vocabulary (\(words.count))") {
                ForEach(words) { word in
                    NavigationLink(destination: WordDetailView(word: word)) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(viewModel.displayArabic(for: word))
                                    .font(.title3.weight(.medium))
                                Spacer()
                                MasteryBadge(level: word.progress.masteryLevel)
                            }
                            if viewModel.settings.showTransliteration {
                                Text(word.transliteration)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Text(word.meaning)
                                .font(.subheadline)
                            Text("Frequency: \(word.frequency)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle(selection.label)
        .listStyle(.insetGrouped)
    }

    private func statItem(title: String, value: Int, color: Color) -> some View {
        VStack {
            Text("\(value)")
                .font(.headline)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
