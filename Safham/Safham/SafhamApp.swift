//
//  SafhamApp.swift
//  Safham
//

import SwiftUI
import SwiftData

@main
struct SafhamApp: App {

    @StateObject private var settings = AppSettings.shared
    // @AppStorage here ensures live re-render on theme toggle
    @AppStorage("isDarkTheme") private var isDarkTheme = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Surah.self,
            Word.self,
            Ayah.self,
            UserStats.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    RootTabView()
                        .environmentObject(settings)
                } else {
                    OnboardingView()
                        .environmentObject(settings)
                }
            }
            .modelContainer(sharedModelContainer)
            .preferredColorScheme(isDarkTheme ? .dark : .light)
            .task {
                DataService.shared.populateInitialData(
                    modelContext: sharedModelContainer.mainContext
                )
            }
        }
    }
}
