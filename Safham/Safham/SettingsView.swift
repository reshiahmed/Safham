//
//  SettingsView.swift
//  Safham
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @State private var reminderTime: Date = {
        var components = DateComponents()
        components.hour = AppSettings.shared.reminderHour
        components.minute = AppSettings.shared.reminderMinute
        return Calendar.current.date(from: components) ?? Date()
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                List {
                    reciterSection
                    displaySection
                    sessionSection
                    reminderSection
                    themeSection
                    aboutSection
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - Reciter

    private var reciterSection: some View {
        Section {
            Picker("Reciter", selection: $settings.selectedReciter) {
                ForEach(settings.reciters, id: \.self) { reciter in
                    Text(reciter).tag(reciter)
                }
            }
            .pickerStyle(.navigationLink)
            .foregroundColor(.white)

            Toggle("Audio slow mode (70% speed)", isOn: $settings.audioSlowMode)
                .tint(Color(hex: "C9A84C"))
        } header: {
            sectionHeader("Audio")
        }
    }

    // MARK: - Display

    private var displaySection: some View {
        Section {
            Toggle("Show Tashkeel (diacritics)", isOn: $settings.showTashkeel)
                .tint(Color(hex: "C9A84C"))
            Toggle("Show Transliteration", isOn: $settings.showTransliteration)
                .tint(Color(hex: "C9A84C"))
            Toggle("Hide function words (و, في, من…)", isOn: $settings.hideFunctionWords)
                .tint(Color(hex: "C9A84C"))
        } header: {
            sectionHeader("Display")
        }
    }

    // MARK: - Session

    private var sessionSection: some View {
        Section {
            Picker("Daily card limit", selection: $settings.dailyCardLimit) {
                Text("10 cards").tag(10)
                Text("20 cards").tag(20)
                Text("30 cards").tag(30)
            }
            .foregroundColor(.white)
        } header: {
            sectionHeader("Review Session")
        }
    }

    // MARK: - Reminder

    private var reminderSection: some View {
        Section {
            Toggle("Daily reminder", isOn: $settings.reminderEnabled)
                .tint(Color(hex: "C9A84C"))
                .onChange(of: settings.reminderEnabled) { _, enabled in
                    if enabled {
                        NotificationService.shared.requestPermission { granted in
                            if !granted { settings.reminderEnabled = false }
                            else { scheduleReminder() }
                        }
                    } else {
                        NotificationService.shared.cancelDailyReminder()
                    }
                }

            if settings.reminderEnabled {
                DatePicker("Reminder time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .onChange(of: reminderTime) { _, newTime in
                        let c = Calendar.current.dateComponents([.hour, .minute], from: newTime)
                        settings.reminderHour = c.hour ?? 5
                        settings.reminderMinute = c.minute ?? 0
                        scheduleReminder()
                    }
            }
        } header: {
            sectionHeader("Notifications")
        } footer: {
            Text("Suggested: 15 minutes before Fajr. We will never send a notification without your permission.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Theme

    private var themeSection: some View {
        Section {
            Toggle("OLED Dark Theme", isOn: $settings.isDarkTheme)
                .tint(Color(hex: "C9A84C"))
        } header: {
            sectionHeader("Appearance")
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundColor(.secondary)
            }

            NavigationLink(destination: ReciterCreditsView()) {
                Text("Reciter Credits")
            }

            Link("Rate on App Store", destination: URL(string: "https://apps.apple.com")!)
                .foregroundColor(Color(hex: "C9A84C"))

            Link("Privacy Policy", destination: URL(string: "https://safham.app/privacy")!)
                .foregroundColor(.secondary)
        } header: {
            sectionHeader("About")
        } footer: {
            Text("سأفهم — I will understand.\nBuilt with care for the ummah.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption.bold())
            .foregroundColor(Color(hex: "C9A84C"))
            .textCase(nil)
    }

    private func scheduleReminder() {
        NotificationService.shared.scheduleDailyReminder(
            hour: settings.reminderHour,
            minute: settings.reminderMinute,
            dueCount: 0
        )
    }
}

// MARK: - Reciter credits

struct ReciterCreditsView: View {
    private let credits: [(String, String)] = [
        ("Mishary Rashid Alafasy", "Kuwait — Murattal"),
        ("Abdul Rahman Al-Sudais", "Saudi Arabia — Imam Al-Haram"),
        ("Maher Al-Muaiqly", "Saudi Arabia — Murattal"),
        ("Saad Al-Ghamdi", "Saudi Arabia — Murattal"),
        ("Mahmoud Khalil Al-Husary", "Egypt — Murattal (slow)"),
        ("Hani Ar-Rifai", "Saudi Arabia — Murattal"),
        ("Yusuf Islam", "United Kingdom — Murattal"),
        ("Abdullah Basfar", "Saudi Arabia — Murattal"),
        ("Nasser Al-Qatami", "Saudi Arabia — Murattal")
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            List {
                ForEach(credits, id: \.0) { name, description in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name).font(.subheadline.bold()).foregroundColor(.white)
                        Text(description).font(.caption).foregroundColor(.secondary)
                    }
                    .listRowBackground(Color(.systemGray6).opacity(0.3))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Reciter Credits")
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SettingsView()
}
