//
//  OnboardingView.swift
//  Safham
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @ObservedObject var settings = AppSettings.shared
    @Environment(\.modelContext) private var modelContext
    @State private var page = 0
    @State private var selectedSurah: Surah?
    @State private var reminderEnabled = false
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 5, minute: 0)) ?? Date()

    @Query(sort: \Surah.number) private var surahs: [Surah]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $page) {
                pageOne.tag(0)
                pageTwo.tag(1)
                pageThree.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: page)

            VStack {
                Spacer()
                pageIndicator
                    .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Page 1: What it does

    private var pageOne: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("سأفهم")
                .font(.system(size: 72, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "C9A84C"))

            VStack(spacing: 12) {
                Text("I Will Understand")
                    .font(.title.bold())
                    .foregroundColor(.white)

                Text("Learn the words you recite every day.\nBuild Quranic vocabulary through spaced repetition — one surah at a time.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(alignment: .leading, spacing: 16) {
                OnboardingFeatureRow(icon: "book.fill", color: Color(hex: "C9A84C"),
                                     title: "Vocabulary from your surahs",
                                     subtitle: "Add what you memorize, learn its meaning")
                OnboardingFeatureRow(icon: "rectangle.stack.fill", color: .green,
                                     title: "Spaced repetition flashcards",
                                     subtitle: "SM-2 algorithm keeps what you learn, fresh")
                OnboardingFeatureRow(icon: "chart.bar.fill", color: .blue,
                                     title: "Three-tier mastery tracking",
                                     subtitle: "Learning → Familiar → Mastered")
            }
            .padding(.horizontal, 32)

            Spacer()

            nextButton(label: "Get Started") { page = 1 }
        }
    }

    // MARK: - Page 2: Pick first content

    private var pageTwo: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("Start with a Surah")
                    .font(.title.bold())
                    .foregroundColor(.white)
                Text("Pick one you're memorizing or reciting regularly.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.top, 60)
            .padding(.bottom, 20)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(popularSurahs, id: \.self) { number in
                        if let surah = surahs.first(where: { $0.number == number }) {
                            SurahPickerRow(surah: surah, isSelected: selectedSurah?.number == number) {
                                selectedSurah = surah
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            VStack(spacing: 12) {
                nextButton(label: selectedSurah != nil ? "Add \(selectedSurah!.nameEnglish)" : "Skip for Now") {
                    if let surah = selectedSurah {
                        DataService.shared.addSurah(surah, modelContext: modelContext)
                    }
                    page = 2
                }
                Button("Browse all surahs later") { page = 2 }
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 80)
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Page 3: Reminder

    private var pageThree: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "C9A84C"))

            VStack(spacing: 12) {
                Text("Daily Reminder")
                    .font(.title.bold())
                    .foregroundColor(.white)
                Text("A small nudge keeps the streak alive.\nWe'll never show a notification without your permission.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Toggle("Enable daily reminder", isOn: $reminderEnabled)
                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "C9A84C")))
                .padding(.horizontal, 32)

            if reminderEnabled {
                DatePicker("Reminder time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .frame(height: 120)
                    .clipped()
            }

            Spacer()

            nextButton(label: "Let's Begin") {
                if reminderEnabled {
                    let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                    settings.reminderEnabled = true
                    settings.reminderHour = components.hour ?? 5
                    settings.reminderMinute = components.minute ?? 0
                    NotificationService.shared.requestPermission { granted in
                        if granted {
                            NotificationService.shared.scheduleDailyReminder(
                                hour: settings.reminderHour,
                                minute: settings.reminderMinute,
                                dueCount: 0
                            )
                        }
                    }
                }
                settings.hasCompletedOnboarding = true
            }
        }
    }

    // MARK: - Helpers

    private var popularSurahs: [Int] {
        [1, 36, 55, 67, 78, 96, 97, 103, 108, 109, 110, 112, 113, 114]
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(i == page ? Color(hex: "C9A84C") : Color.white.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }

    private func nextButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "C9A84C"))
                .foregroundColor(.black)
                .cornerRadius(16)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Supporting views

struct OnboardingFeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold()).foregroundColor(.white)
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}

struct SurahPickerRow: View {
    let surah: Surah
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text("\(surah.number)")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                    .frame(width: 28)

                Text(surah.nameEnglish)
                    .font(.body)
                    .foregroundColor(.white)

                Spacer()

                Text(surah.nameArabic)
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(Color(hex: "C9A84C"))

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "C9A84C"))
                        .padding(.leading, 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color(hex: "C9A84C").opacity(0.15) : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

#Preview {
    OnboardingView()
}
