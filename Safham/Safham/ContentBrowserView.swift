//
//  ContentBrowserView.swift
//  Safham
//
//  Surah / Juz browser with search, add/remove, and vocabulary navigation.
//

import SwiftUI
import SwiftData

struct ContentBrowserView: View {
    @ObservedObject var settings = AppSettings.shared
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Surah.number) private var surahs: [Surah]

    @State private var browseMode: BrowseMode = .surah
    @State private var searchText = ""
    @State private var selectedJuz: Int? = nil

    enum BrowseMode: String, CaseIterable {
        case surah = "Surah"
        case juz   = "Juz"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode picker
                Picker("Browse", selection: $browseMode) {
                    ForEach(BrowseMode.allCases, id: \.self) { Text($0.rawValue) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                if browseMode == .surah {
                    surahList
                } else {
                    juzList
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Browse Content")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: browseMode == .surah ? "Search surahs…" : "Search juz…")
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - Surah list

    private var surahList: some View {
        List {
            ForEach(filteredSurahs) { surah in
                NavigationLink(destination: VocabularyListView(surah: surah)) {
                    SurahBrowserRow(surah: surah) {
                        DataService.shared.addSurah(surah, modelContext: modelContext)
                    } onRemove: {
                        DataService.shared.removeSurah(surah, modelContext: modelContext)
                    }
                }
                .listRowBackground(Color(.systemGray6).opacity(0.3))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Juz list

    private var juzList: some View {
        List {
            ForEach(filteredJuz) { juz in
                Section {
                    ForEach(juz.surahNumbers, id: \.self) { number in
                        if let surah = surahs.first(where: { $0.number == number }) {
                            NavigationLink(destination: VocabularyListView(surah: surah)) {
                                SurahBrowserRow(surah: surah) {
                                    DataService.shared.addSurah(surah, modelContext: modelContext)
                                } onRemove: {
                                    DataService.shared.removeSurah(surah, modelContext: modelContext)
                                }
                            }
                            .listRowBackground(Color(.systemGray6).opacity(0.3))
                        }
                    }
                } header: {
                    Text(juz.name)
                        .font(.caption.bold())
                        .foregroundColor(Color(hex: "C9A84C"))
                        .textCase(nil)
                }
            }
        }
        .listStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Filtering

    private var filteredSurahs: [Surah] {
        if searchText.isEmpty { return surahs }
        return surahs.filter {
            $0.nameEnglish.localizedCaseInsensitiveContains(searchText) ||
            $0.nameArabic.contains(searchText) ||
            "\($0.number)".contains(searchText)
        }
    }

    private var filteredJuz: [JuzInfo] {
        if searchText.isEmpty { return JuzData.allJuz }
        return JuzData.allJuz.filter { juz in
            juz.name.localizedCaseInsensitiveContains(searchText) ||
            juz.surahNumbers.contains(where: { n in
                surahs.first(where: { $0.number == n })?
                    .nameEnglish
                    .localizedCaseInsensitiveContains(searchText) ?? false
            })
        }
    }
}

// MARK: - Row

struct SurahBrowserRow: View {
    let surah: Surah
    let onAdd: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Surah number badge
            Text("\(surah.number)")
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .frame(width: 32, alignment: .trailing)

            VStack(alignment: .leading, spacing: 2) {
                Text(surah.nameEnglish)
                    .font(.body)
                    .foregroundColor(.white)
                Text("\(surah.ayahCount) ayahs • Juz \(JuzData.juz(forSurah: surah.number))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(surah.nameArabic)
                .font(.system(size: 15, design: .serif))
                .foregroundColor(Color(hex: "C9A84C"))
                .lineLimit(1)

            // Add / Added button
            if surah.isAdded {
                Button(action: onRemove) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: onAdd) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(Color(hex: "C9A84C"))
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentBrowserView()
}
