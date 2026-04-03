import Foundation

struct VocabularyService {
    func extractWords(
        from selections: [ContentSelection],
        records: [VocabularyRecord],
        hideFunctionWords: Bool
    ) -> [VocabWord] {
        guard !selections.isEmpty else { return [] }

        let words = selections
            .flatMap { extractWords(from: $0, records: records, hideFunctionWords: hideFunctionWords) }

        return merge(words: words)
    }

    func extractWords(
        from selection: ContentSelection,
        records: [VocabularyRecord],
        hideFunctionWords: Bool
    ) -> [VocabWord] {
        let matched = records.filter { record in
            matches(selection: selection, record: record)
        }

        let filtered = hideFunctionWords ? matched.filter { !$0.word.isFunctionWord } : matched
        return filtered.map(\.word).sorted(by: { $0.frequency > $1.frequency })
    }

    private func matches(selection: ContentSelection, record: VocabularyRecord) -> Bool {
        switch selection {
        case let .surah(number):
            return record.surahIDs.contains(number)
        case let .juz(number):
            return record.juzIDs.contains(number)
        case let .ayahRange(surah, start, end):
            return record.word.ayahRefs.contains(where: { reference in
                reference.surah == surah && (start...end).contains(reference.ayah)
            })
        }
    }

    private func merge(words: [VocabWord]) -> [VocabWord] {
        var merged: [String: VocabWord] = [:]

        for word in words {
            if var existing = merged[word.key] {
                existing.frequency += word.frequency
                existing.ayahRefs = Array(Set(existing.ayahRefs + word.ayahRefs)).sorted {
                    if $0.surah == $1.surah {
                        return $0.ayah < $1.ayah
                    }
                    return $0.surah < $1.surah
                }
                merged[word.key] = existing
            } else {
                merged[word.key] = word
            }
        }

        return merged.values.sorted(by: { lhs, rhs in
            if lhs.frequency == rhs.frequency {
                return lhs.arabic < rhs.arabic
            }
            return lhs.frequency > rhs.frequency
        })
    }
}
