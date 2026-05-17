import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ProfileViewModel()
    @State private var showAvatarPicker = false
    @State private var showChangePassword = false
    @State private var showLogoutConfirm = false
    @State private var bioText: String = ""
    @State private var showSaveSuccess = false
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Avatar section
                    VStack(spacing: 12) {
                        Button {
                            showAvatarPicker = true
                        } label: {
                            avatarImage(for: appState.avatarIndex)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .foregroundColor(avatarColor(for: appState.avatarIndex))
                                .background(
                                    Circle()
                                        .fill(Color.appPrimaryLight)
                                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                                )
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Circle().fill(Color.appPrimary))
                                        .offset(x: 30, y: 30)
                                )
                        }
                        .buttonStyle(.plain)

                        // Username
                        Text(appState.username ?? "用户")
                            .font(.title2.bold())
                            .foregroundColor(.appTextPrimary)

                        // VIP badge
                        if appState.isVip {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.caption)
                                    .foregroundColor(.vipGold)
                                Text("VIP会员")
                                    .font(.caption.bold())
                                    .foregroundColor(.vipGold)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(.vipGold.opacity(0.12))
                            )
                        } else {
                            NavigationLink(destination: VipView()) {
                                Text("开通VIP")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(Color.vipGold))
                            }
                        }
                    }
                    .padding(.top, 16)

                    // Bio section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("个人简介")
                            .font(.subheadline.bold())
                            .foregroundColor(.appTextPrimary)

                        ZStack(alignment: .topLeading) {
                            if bioText.isEmpty {
                                Text("介绍一下自己，让更多人认识你...")
                                    .font(.body)
                                    .foregroundColor(.appTextHint)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 10)
                            }
                            TextEditor(text: $bioText)
                                .font(.body)
                                .frame(minHeight: 100)
                                .padding(4)
                                .scrollContentBackground(.hidden)
                                .onChange(of: appState.bio) { _, newValue in
                                    if bioText.isEmpty {
                                        bioText = newValue
                                    }
                                }
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.appDivider, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 16)

                    // Save button
                    Button {
                        saveProfile()
                    } label: {
                        HStack {
                            if viewModel.loginState == .loading {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.8)
                            }
                            Text("保存修改")
                                .font(.subheadline.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(bioText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.appTextHint : Color.appPrimary)
                        )
                    }
                    .disabled(viewModel.loginState == .loading || bioText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.horizontal, 16)

                    // Divider section
                    VStack(spacing: 0) {
                        Divider().foregroundColor(.appDivider)
                            .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 8)

                    // Change password
                    Button {
                        showChangePassword = true
                    } label: {
                        HStack {
                            Image(systemName: "lock.rotation")
                                .font(.subheadline)
                                .foregroundColor(.appTextPrimary)
                            Text("修改密码")
                                .font(.subheadline)
                                .foregroundColor(.appTextPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.bold())
                                .foregroundColor(.appTextHint)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)

                    Divider().foregroundColor(.appDivider)
                        .padding(.horizontal, 16)

                    // Logout
                    Button {
                        showLogoutConfirm = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.subheadline)
                                .foregroundColor(.appStockUp)
                            Text("退出登录")
                                .font(.subheadline)
                                .foregroundColor(.appStockUp)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)

                    // App version
                    Text("天线量化 v\(APIConfig.appVersion)")
                        .font(.caption)
                        .foregroundColor(.appTextHint)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                }
            }
            .background(Color.appBackground)
            .navigationTitle("个人中心")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAvatarPicker) {
                AvatarPickerSheet(selectedIndex: appState.avatarIndex) { index in
                    appState.avatarIndex = index
                }
            }
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordSheet(viewModel: viewModel, username: appState.username ?? "")
            }
            .alert("退出登录", isPresented: $showLogoutConfirm) {
                Button("取消", role: .cancel) {}
                Button("确认退出", role: .destructive) {
                    appState.logout()
                }
            } message: {
                Text("退出后需要重新登录才能使用APP")
            }
            .alert("保存成功", isPresented: $showSaveSuccess) {
                Button("好的", role: .cancel) {
                    viewModel.resetState()
                }
            } message: {
                Text("个人资料已更新")
            }
            .alert("保存失败", isPresented: $showError) {
                Button("好的", role: .cancel) {
                    viewModel.resetState()
                }
            } message: {
                Text(viewModel.errorMessage.isEmpty ? "未知错误" : viewModel.errorMessage)
            }
            .onAppear {
                bioText = appState.bio
            }
            .onChange(of: viewModel.loginState) { _, newState in
                if case .success = newState {
                    showSaveSuccess = true
                } else if case .error = newState {
                    showError = true
                }
            }
        }
    }

    private func saveProfile() {
        let trimmed = bioText.trimmingCharacters(in: .whitespacesAndNewlines)
        appState.bio = trimmed
        UserDefaultsManager.shared.bio = trimmed

        Task {
            await viewModel.updateProfile(
                username: appState.username ?? "",
                avatarIndex: appState.avatarIndex,
                bio: trimmed
            )
        }
    }

    private func avatarImage(for index: Int) -> Image {
        let symbols = [
            "person.circle.fill",
            "face.smiling",
            "star.circle.fill",
            "heart.circle.fill",
            "bolt.circle.fill",
            "flame.circle.fill",
            "leaf.circle.fill",
            "moon.circle.fill"
        ]
        let safeIndex = min(max(index, 0), symbols.count - 1)
        return Image(systemName: symbols[safeIndex])
    }

    private func avatarColor(for index: Int) -> Color {
        let colors: [Color] = [
            .appPrimary,
            Color(hex: "#FF6B35"),
            .vipGold,
            .appStockDown,
            .vipDiamond,
            .appStockUp,
            Color(hex: "#00BCD4"),
            .vipCrown
        ]
        let safeIndex = min(max(index, 0), colors.count - 1)
        return colors[safeIndex]
    }
}

#Preview {
    ProfileView()
        .environment(AppState())
}
