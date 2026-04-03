import SwiftUI

struct ContentBrowserView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var query = ""

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Browse", selection: browseModeBinding) {
                    ForEach(BrowseMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])

                List {
                    switch viewModel.browseMode {
                    case .surah:
                        ForEach(filteredSurahs) { surah in
                            let selection = ContentSelection.surah(surah.id)
                            ContentRow(
                                title: "Surah \(surah.id) · \(surah.englishName)",
                                subtitle: surah.arabicName,
                                isAdded: isSelectionAdded(selection),
                                onToggle: { toggle(selection) },
                                destination: VocabularyListView(selection: selection)
                            )
                        }
                    case .juz:
                        ForEach(filteredJuz) { juz in
                            let selection = ContentSelection.juz(juz.id)
                            ContentRow(
                                title: "Juz \(juz.id)",
                                subtitle: juz.name,
                                isAdded: isSelectionAdded(selection),
                                onToggle: { toggle(selection) },
                                destination: VocabularyListView(selection: selection)
                            )
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Add Content")
            .searchable(text: $query, prompt: "Find Surah or Juz")
        }
    }

    private var browseModeBinding: Binding<BrowseMode> {
        Binding(
            get: { viewModel.browseMode },
            set: { viewModel.setBrowseMode($0) }
        )
    }

    private var filteredSurahs: [Surah] {
        guard !query.isEmpty else { return viewModel.surahs }
        return viewModel.surahs.filter { surah in
            let token = query.lowercased()
            return surah.englishName.lowercased().contains(token) ||
                surah.arabicName.contains(token) ||
                "\(surah.id)".contains(token)
        }
    }

    private var filteredJuz: [Juz] {
        guard !query.isEmpty else { return viewModel.juzList }
        return viewModel.juzList.filter { juz in
            let token = query.lowercased()
            return juz.name.lowercased().contains(token) || "\(juz.id)".contains(token)
        }
    }

    private func isSelectionAdded(_ selection: ContentSelection) -> Bool {
        viewModel.selectedContent.contains(where: { $0.id == selection.id })
    }

    private func toggle(_ selection: ContentSelection) {
        if isSelectionAdded(selection) {
            viewModel.removeSelection(selection)
        } else {
            viewModel.addSelection(selection)
        }
    }
}

private struct ContentRow<Destination: View>: View {
    let title: String
    let subtitle: String
    let isAdded: Bool
    let onToggle: () -> Void
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: onToggle) {
                    Text(isAdded ? "Added" : "Add")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(isAdded ? Color.green.opacity(0.2) : Color(hex: "#C9A84C").opacity(0.2))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
