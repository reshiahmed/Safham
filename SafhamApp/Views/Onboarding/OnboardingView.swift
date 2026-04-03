import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var page = 0
    @State private var enableReminder = false
    @State private var reminderHour = 5
    @State private var reminderMinute = 30
    @State private var autoAddSurahMulk = true

    var body: some View {
        VStack(spacing: 24) {
            TabView(selection: $page) {
                OnboardingCard(
                    title: "Understand What You Recite",
                    subtitle: "Safham turns your current hifz portions into reviewable Quranic vocabulary."
                )
                .tag(0)

                OnboardingCard(
                    title: "Learn by Surah or Juz",
                    subtitle: "Choose content exactly how you memorize, then review words using spaced repetition."
                )
                .tag(1)

                setupPage
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button(action: primaryAction) {
                Text(page == 2 ? "Start Safham" : "Continue")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#C9A84C"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 24)
        .background(
            LinearGradient(
                colors: [Color.black, Color(red: 0.07, green: 0.11, blue: 0.11)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    private var setupPage: some View {
        VStack(spacing: 20) {
            OnboardingCard(
                title: "Set Your First Ritual",
                subtitle: "Defaults are pre-tuned, but you can start with Al-Mulk and a daily reminder."
            )

            VStack(alignment: .leading, spacing: 16) {
                Toggle("Add Surah Al-Mulk now", isOn: $autoAddSurahMulk)
                Toggle("Enable daily reminder", isOn: $enableReminder)

                if enableReminder {
                    HStack {
                        Picker("Hour", selection: $reminderHour) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(String(format: "%02d", hour)).tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)

                        Picker("Minute", selection: $reminderMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                Text(String(format: "%02d", minute)).tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .frame(height: 120)
                }
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 24)
        }
    }

    private func primaryAction() {
        if page < 2 {
            withAnimation {
                page += 1
            }
            return
        }

        if autoAddSurahMulk {
            viewModel.addSelection(.surah(67))
        }

        viewModel.mutateSettings { settings in
            settings.reminder.enabled = enableReminder
            settings.reminder.hour = reminderHour
            settings.reminder.minute = reminderMinute
        }

        viewModel.completeOnboarding()
    }
}

private struct OnboardingCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(title)
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)

            Text(subtitle)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.85))
                .padding(.horizontal, 24)
            Spacer()
        }
    }
}
