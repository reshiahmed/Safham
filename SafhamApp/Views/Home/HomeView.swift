import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var presentSession = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    dashboardCards
                    todayCard
                    recentContent
                }
                .padding()
            }
            .navigationTitle("Safham")
            .sheet(isPresented: $presentSession) {
                ReviewSessionView(queue: viewModel.beginSessionQueue())
                    .environmentObject(viewModel)
            }
        }
    }

    private var dashboardCards: some View {
        HStack(spacing: 12) {
            StatCard(title: "Streak", value: "\(viewModel.streak)", footnote: "Days")
            StatCard(title: "Mastered", value: "\(viewModel.totalMasteredWords())", footnote: "Words")
        }
    }

    private var todayCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Session")
                .font(.headline)

            Text("\(viewModel.dueWords.count) words due today")
                .font(.title3.weight(.semibold))

            Text("Estimated time: ~\(viewModel.estimatedMinutesToday()) min")
                .foregroundStyle(.secondary)

            Button(action: { presentSession = true }) {
                Text(viewModel.dueWords.isEmpty ? "No Cards Due Yet" : "Start Review")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#C9A84C"))
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.dueWords.isEmpty)
            .opacity(viewModel.dueWords.isEmpty ? 0.6 : 1.0)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var recentContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recently Added")
                .font(.headline)

            if viewModel.selectedContent.isEmpty {
                Text("Add a Surah or Juz from the Content tab to start building your vocabulary list.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.selectedContent, id: \.id) { selection in
                    NavigationLink(destination: VocabularyListView(selection: selection)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selection.label)
                                    .font(.headline)
                                let breakdown = viewModel.progressBreakdown(for: selection)
                                Text("\(breakdown.mastered)/\(max(1, breakdown.total)) mastered")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            ProgressRing(
                                value: breakdown.total == 0 ? 0 : Double(breakdown.mastered) / Double(breakdown.total)
                            )
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let footnote: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text(footnote)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct ProgressRing: View {
    let value: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.25), lineWidth: 8)
            Circle()
                .trim(from: 0, to: min(max(value, 0), 1))
                .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 44, height: 44)
    }
}
