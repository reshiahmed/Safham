import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Audio") {
                    Picker("Reciter", selection: settingBinding(\.reciter)) {
                        ForEach(Reciter.allCases) { reciter in
                            Text(reciter.displayName).tag(reciter)
                        }
                    }

                    Toggle("Audio slow mode (70%)", isOn: settingBinding(\.audioSlowMode))
                }

                Section("Reading") {
                    Toggle("Show tashkeel", isOn: settingBinding(\.showTashkeel))
                    Toggle("Show transliteration", isOn: settingBinding(\.showTransliteration))
                    Toggle("Hide function words", isOn: settingBinding(\.hideFunctionWords))
                }

                Section("Study") {
                    Picker("Default browse mode", selection: settingBinding(\.defaultBrowseMode)) {
                        ForEach(BrowseMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }

                    Picker("Daily card limit", selection: settingBinding(\.dailyCardLimit)) {
                        Text("10").tag(10)
                        Text("20").tag(20)
                        Text("30").tag(30)
                    }
                }

                Section("Reminder") {
                    Toggle("Enable daily reminder", isOn: reminderEnabledBinding)

                    if viewModel.settings.reminder.enabled {
                        Picker("Hour", selection: reminderHourBinding) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(String(format: "%02d", hour)).tag(hour)
                            }
                        }
                        Picker("Minute", selection: reminderMinuteBinding) {
                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                Text(String(format: "%02d", minute)).tag(minute)
                            }
                        }
                    }
                }

                Section("Appearance") {
                    Picker("Theme", selection: settingBinding(\.theme)) {
                        ForEach(ThemePreference.allCases) { theme in
                            Text(theme.title).tag(theme)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func settingBinding<Value>(_ keyPath: WritableKeyPath<AppSettings, Value>) -> Binding<Value> {
        Binding(
            get: { viewModel.settings[keyPath: keyPath] },
            set: { newValue in
                viewModel.mutateSettings { settings in
                    settings[keyPath: keyPath] = newValue
                }
            }
        )
    }

    private var reminderEnabledBinding: Binding<Bool> {
        Binding(
            get: { viewModel.settings.reminder.enabled },
            set: { newValue in
                viewModel.mutateSettings { settings in
                    settings.reminder.enabled = newValue
                }
            }
        )
    }

    private var reminderHourBinding: Binding<Int> {
        Binding(
            get: { viewModel.settings.reminder.hour },
            set: { newValue in
                viewModel.mutateSettings { settings in
                    settings.reminder.hour = newValue
                }
            }
        )
    }

    private var reminderMinuteBinding: Binding<Int> {
        Binding(
            get: { viewModel.settings.reminder.minute },
            set: { newValue in
                viewModel.mutateSettings { settings in
                    settings.reminder.minute = newValue
                }
            }
        )
    }
}
