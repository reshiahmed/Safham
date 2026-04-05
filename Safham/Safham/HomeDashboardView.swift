//
//  HomeDashboardView.swift
//  Safham
//

import SwiftUI
import SwiftData

// MARK: - Root Tab Container

struct RootTabView: View {
    @ObservedObject var settings = AppSettings.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeDashboardView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            ContentBrowserView()
                .tabItem {
                    Label("Browse", systemImage: "books.vertical.fill")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(Color(hex: "C9A84C"))
        .preferredColorScheme(settings.colorScheme)
    }
}

// MARK: - Home Dashboard

struct HomeDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var settings = AppSettings.shared

    @Query private var stats: [UserStats]
    @Query private var words: [Word]
    @Query(filter: #Predicate<Surah> { $0.isAdded }, sort: \Surah.number)
    private var addedSurahs: [Surah]

    @State private var showReview = false
    @State private var dueWordsForSession: [Word] = []

    private var userStats: UserStats? { stats.first }

    private var dueWords: [Word] {
        words.filter { $0.nextReviewDate <= Date() }
    }

    private var totalMastered: Int {
        words.filter { $0.masteryLevel == 2 }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                masteryRingsSection
                todaySessionCard
                progressSection
            }
            .padding(.vertical, 20)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showReview) {
            FlashcardReviewView(words: dueWordsForSession, surahName: "Daily Review")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("سأفهم")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(.white)
            }
            Spacer()
            HStack(spacing: 12) {
                // Streak badge
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").foregroundColor(.orange)
                    Text("\(userStats?.dailyStreak ?? 0)")
                        .font(.headline).foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)

                // Mastered count
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundColor(Color(hex: "C9A84C"))
                    Text("\(totalMastered)")
                        .font(.headline).foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Mastery rings

    private var masteryRingsSection: some View {
        HStack(spacing: 32) {
            MasteryRingView(
                level: "Learning",
                count: words.filter { $0.masteryLevel == 0 }.count,
                color: .red, total: words.count
            )
            MasteryRingView(
                level: "Familiar",
                count: words.filter { $0.masteryLevel == 1 }.count,
                color: .yellow, total: words.count
            )
            MasteryRingView(
                level: "Mastered",
                count: words.filter { $0.masteryLevel == 2 }.count,
                color: .green, total: words.count
            )
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(24)
        .padding(.horizontal)
    }

    // MARK: - Today's session

    private var todaySessionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Session")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)

            if dueWords.isEmpty {
                allDoneCard
            } else {
                Button(action: startDailyReview) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Review")
                                .font(.title3.bold())
                            Text("\(dueWords.count) words due · ~\(max(2, dueWords.count * 2 / 60 + 1)) min")
                                .font(.subheadline)
                                .opacity(0.85)
                        }
                        Spacer()
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 44))
                            .symbolRenderingMode(.hierarchical)
                    }
                    .padding(24)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "C9A84C"), Color(hex: "A68A3E")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(24)
                    .shadow(color: Color(hex: "C9A84C").opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
            }
        }
    }

    private var allDoneCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title)
                .foregroundColor(.green)
            VStack(alignment: .leading, spacing: 4) {
                Text("All caught up!")
                    .font(.headline).foregroundColor(.white)
                Text("No words due right now. Come back later.")
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(20)
        .background(Color.green.opacity(0.1))
        .cornerRadius(20)
        .padding(.horizontal)
    }

    // MARK: - Progress per surah

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Surahs")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                NavigationLink(destination: ContentBrowserView()) {
                    Text("Browse")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "C9A84C"))
                }
            }
            .padding(.horizontal)

            if addedSurahs.isEmpty {
                emptySurahsPlaceholder
            } else {
                ForEach(addedSurahs) { surah in
                    NavigationLink(destination: VocabularyListView(surah: surah)) {
                        SurahProgressCard(surah: surah)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
            }
        }
    }

    private var emptySurahsPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle")
                .font(.system(size: 36))
                .foregroundColor(Color(hex: "C9A84C"))
            Text("Add a surah to start learning its vocabulary.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            NavigationLink(destination: ContentBrowserView()) {
                Text("Browse Surahs")
                    .font(.subheadline.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color(hex: "C9A84C"))
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(20)
        .padding(.horizontal)
    }

    // MARK: - Actions

    private func startDailyReview() {
        let limit = settings.dailyCardLimit
        dueWordsForSession = Array(dueWords.shuffled().prefix(limit))
        showReview = true
    }

    // MARK: - Helpers

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<5:  return "Night review"
        case 5..<12: return "Good morning"
        case 12..<18: return "Good afternoon"
        default:     return "Good evening"
        }
    }
}

// MARK: - Mastery ring

struct MasteryRingView: View {
    let level: String
    let count: Int
    let color: Color
    let total: Int

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: total > 0 ? CGFloat(count) / CGFloat(total) : 0)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.6), value: count)
                Text("\(count)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(width: 64, height: 64)
            Text(level)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Surah progress card

struct SurahProgressCard: View {
    let surah: Surah

    private var wordCount: Int { surah.words.count }
    private var masteredCount: Int { surah.words.filter { $0.masteryLevel == 2 }.count }
    private var dueCount: Int { surah.words.filter { $0.nextReviewDate <= Date() }.count }
    private var progress: Double {
        wordCount > 0 ? Double(masteredCount) / Double(wordCount) : 0
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(surah.nameEnglish)
                    .font(.headline)
                    .foregroundColor(.white)
                HStack(spacing: 6) {
                    Text("\(wordCount) words")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if dueCount > 0 {
                        Text("·")
                            .foregroundColor(.secondary)
                        Text("\(dueCount) due")
                            .font(.caption.bold())
                            .foregroundColor(Color(hex: "C9A84C"))
                    }
                }
            }
            Spacer()
            Text(surah.nameArabic)
                .font(.system(size: 14, design: .serif))
                .foregroundColor(Color(hex: "C9A84C"))
                .lineLimit(1)
            // Mini progress ring
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(Color(hex: "C9A84C"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 36, height: 36)
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - Color hex extension (shared)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255,
                  blue: Double(b)/255, opacity: Double(a)/255)
    }
}

#Preview {
    RootTabView()
}
