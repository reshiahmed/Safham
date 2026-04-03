import Foundation

enum Reciter: String, CaseIterable, Codable, Identifiable {
    case alafasy
    case sudais
    case muaiqly
    case ghamdi
    case husary
    case rifai
    case yusufIslam
    case basfar
    case qatami

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .alafasy:
            return "Mishary Rashid Alafasy"
        case .sudais:
            return "Abdul Rahman Al-Sudais"
        case .muaiqly:
            return "Maher Al-Muaiqly"
        case .ghamdi:
            return "Saad Al-Ghamdi"
        case .husary:
            return "Mahmoud Khalil Al-Husary"
        case .rifai:
            return "Hani Ar-Rifai"
        case .yusufIslam:
            return "Yusuf Islam"
        case .basfar:
            return "Abdullah Basfar"
        case .qatami:
            return "Nasser Al-Qatami"
        }
    }

    var folderName: String {
        rawValue
    }
}

enum ThemePreference: String, CaseIterable, Codable, Identifiable {
    case dark
    case light

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }
}

struct ReminderSettings: Hashable, Codable {
    var enabled: Bool
    var hour: Int
    var minute: Int

    static let `default` = ReminderSettings(enabled: false, hour: 5, minute: 30)
}

struct AppSettings: Hashable, Codable {
    var reciter: Reciter
    var showTashkeel: Bool
    var showTransliteration: Bool
    var hideFunctionWords: Bool
    var defaultBrowseMode: BrowseMode
    var dailyCardLimit: Int
    var reminder: ReminderSettings
    var theme: ThemePreference
    var audioSlowMode: Bool

    static let `default` = AppSettings(
        reciter: .alafasy,
        showTashkeel: true,
        showTransliteration: true,
        hideFunctionWords: false,
        defaultBrowseMode: .surah,
        dailyCardLimit: 20,
        reminder: .default,
        theme: .dark,
        audioSlowMode: false
    )
}
