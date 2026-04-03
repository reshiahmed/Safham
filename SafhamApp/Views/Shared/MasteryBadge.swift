import SwiftUI

struct MasteryBadge: View {
    let level: MasteryLevel

    var body: some View {
        Text(level.title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .foregroundStyle(.white)
            .background(color)
            .clipShape(Capsule())
    }

    private var color: Color {
        switch level {
        case .learning:
            return .red
        case .familiar:
            return .yellow
        case .mastered:
            return .green
        }
    }
}
