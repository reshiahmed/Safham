//
//  AppSettings.swift
//  Safham
//

import SwiftUI
import Combine

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("selectedReciter") var selectedReciter: String = "Mishary Rashid Alafasy"
    @AppStorage("showTashkeel") var showTashkeel: Bool = true
    @AppStorage("showTransliteration") var showTransliteration: Bool = true
    @AppStorage("hideFunctionWords") var hideFunctionWords: Bool = false
    @AppStorage("defaultBrowseMode") var defaultBrowseMode: String = "surah"
    @AppStorage("dailyCardLimit") var dailyCardLimit: Int = 20
    @AppStorage("reminderEnabled") var reminderEnabled: Bool = false
    @AppStorage("reminderHour") var reminderHour: Int = 5
    @AppStorage("reminderMinute") var reminderMinute: Int = 0
    @AppStorage("isDarkTheme") var isDarkTheme: Bool = true
    @AppStorage("audioSlowMode") var audioSlowMode: Bool = false
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    let reciters: [String] = [
        "Mishary Rashid Alafasy",
        "Abdul Rahman Al-Sudais",
        "Maher Al-Muaiqly",
        "Saad Al-Ghamdi",
        "Mahmoud Khalil Al-Husary",
        "Hani Ar-Rifai",
        "Yusuf Islam",
        "Abdullah Basfar",
        "Nasser Al-Qatami"
    ]

    var colorScheme: ColorScheme {
        isDarkTheme ? .dark : .light
    }
}
