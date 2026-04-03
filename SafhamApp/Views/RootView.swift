import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = AppViewModel()

    var body: some View {
        Group {
            if viewModel.hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(viewModel)
            } else {
                OnboardingView()
                    .environmentObject(viewModel)
            }
        }
        .task {
            await viewModel.bootstrapIfNeeded(modelContext: modelContext)
        }
        .preferredColorScheme(viewModel.settings.theme == .dark ? .dark : .light)
    }
}

private struct MainTabView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            ContentBrowserView()
                .tabItem {
                    Label("Content", systemImage: "book.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Color(hex: "#C9A84C"))
    }
}
