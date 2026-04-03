import SwiftUI

struct SessionSummaryView: View {
    let summary: SessionSummary
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Session Complete")
                .font(.largeTitle.weight(.bold))

            VStack(spacing: 12) {
                summaryItem(title: "Words Reviewed", value: "\(summary.reviewedCount)")
                summaryItem(title: "Mastery Change", value: masteryText)
                summaryItem(title: "Current Streak", value: "\(summary.streak) days")
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Button("Done", action: onDone)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: "#C9A84C"))
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }

    private var masteryText: String {
        if summary.masteredDelta > 0 {
            return "+\(summary.masteredDelta)"
        }
        return "\(summary.masteredDelta)"
    }

    private func summaryItem(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}
