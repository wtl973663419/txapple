import SwiftUI

/// Main tab bar with five tabs for the core app sections.
/// Each tab uses its own NavigationStack for independent navigation.
struct MainTabView: View {
    @Environment(AppState.self) private var appState

    @State private var selectedTab = 0
    // Unread count for the Teatime/Chat tab (placeholder — update from real data)
    @State private var unreadCount = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: 选股
            NavigationStack {
                StockSelectView()
            }
            .tabItem {
                VStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("选股")
                }
            }
            .tag(0)

            // Tab 2: 量化
            NavigationStack {
                QuantView()
            }
            .tabItem {
                VStack {
                    Image(systemName: "function")
                    Text("量化")
                }
            }
            .tag(1)

            // Tab 3: 社区
            NavigationStack {
                CommunityView()
            }
            .tabItem {
                VStack {
                    Image(systemName: "person.3.fill")
                    Text("社区")
                }
            }
            .tag(2)

            // Tab 4: 茶歇 (with unread badge)
            NavigationStack {
                TeatimeView()
            }
            .tabItem {
                VStack {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("茶歇")
                }
            }
            .badge(unreadCount > 0 ? unreadCount : 0)
            .tag(3)

            // Tab 5: 我的
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                VStack {
                    Image(systemName: "person.circle.fill")
                    Text("我的")
                }
            }
            .tag(4)
        }
        .tint(.appPrimary)
        .onAppear {
            // Style unselected tab items
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            UITabBar.appearance().unselectedItemTintColor = UIColor(Color.appTextSecondary)
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
