import SwiftUI

@main
struct TianXianQuantApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoading {
                    LaunchScreenView()
                        .task {
                            await appState.verifyAuth()
                        }
                } else if appState.isAuthenticated {
                    MainTabView()
                        .environment(appState)
                } else {
                    SplashView()
                        .environment(appState)
                }
            }
        }
    }
}

/// Shown while verifying auth on launch
struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Color(hex: "#1A73E8")
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                Text("天线量化")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                Text("TianXianQuant")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                ProgressView()
                    .tint(.white)
                    .padding(.top, 20)
            }
        }
    }
}
