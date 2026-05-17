import SwiftUI

/// Full-screen login/register screen shown when the user is not authenticated.
/// Uses a blue background with a white card containing login fields.
struct SplashView: View {
    @Environment(AppState.self) private var appState

    @State private var username = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Blue background
            Color(hex: "#1A73E8")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 80)

                    // App icon
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .padding(.bottom, 16)

                    // Title
                    Text("天线量化")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    // Subtitle
                    Text("TianXianQuant")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 4)

                    Spacer()
                        .frame(height: 40)

                    // White login card
                    VStack(spacing: 16) {
                        // Username field
                        HStack(spacing: 10) {
                            Image(systemName: "person.fill")
                                .foregroundColor(.appTextHint)
                                .frame(width: 20)
                            TextField("请输入用户名", text: $username)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .textContentType(.username)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.appBackgroundInput)
                        )

                        // Password field
                        HStack(spacing: 10) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.appTextHint)
                                .frame(width: 20)
                            SecureField("请输入密码", text: $password)
                                .textContentType(.password)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.appBackgroundInput)
                        )

                        // Login button
                        Button {
                            performLogin()
                        } label: {
                            ZStack {
                                if isLoggingIn {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("登录")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.appPrimary)
                            )
                        }
                        .disabled(isLoggingIn || !isFormValid)

                        // Divider
                        HStack(spacing: 12) {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.appDivider)
                            Text("或")
                                .font(.caption)
                                .foregroundColor(.appTextHint)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.appDivider)
                        }

                        // Hint text
                        Text("首次登录自动注册")
                            .font(.caption)
                            .foregroundColor(.appTextHint)

                        // Error message
                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .transition(.opacity)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
                    )
                    .padding(.horizontal, 28)

                    Spacer()
                        .frame(height: 40)
                }
                .frame(minHeight: UIScreen.main.bounds.height)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: errorMessage)
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        username.trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty &&
            password.isNotEmpty
    }

    // MARK: - Actions

    private func performLogin() {
        guard isFormValid else {
            errorMessage = "请输入用户名和密码"
            return
        }

        errorMessage = nil
        isLoggingIn = true

        Task {
            let success = await appState.login(
                username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )

            await MainActor.run {
                isLoggingIn = false
                if !success {
                    errorMessage = "登录失败，请检查用户名和密码"
                }
                // On success, MainTabView appears automatically
                // because appState.isAuthenticated becomes true
            }
        }
    }
}

#Preview {
    SplashView()
        .environment(AppState())
}
