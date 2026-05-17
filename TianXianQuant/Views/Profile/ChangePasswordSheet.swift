import SwiftUI

struct ChangePasswordSheet: View {
    var viewModel: ProfileViewModel
    let username: String

    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccess = false
    @State private var showError = false

    private var isFormValid: Bool {
        !oldPassword.isEmpty &&
        !newPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Info card
                VStack(spacing: 4) {
                    Text("当前账号")
                        .font(.caption)
                        .foregroundColor(.appTextHint)
                    Text(username)
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                }
                .padding(.top, 12)

                // Old password
                VStack(alignment: .leading, spacing: 8) {
                    Text("原密码")
                        .font(.subheadline.bold())
                        .foregroundColor(.appTextPrimary)

                    SecureField("请输入原密码", text: $oldPassword)
                        .font(.body)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.appDivider, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 16)

                // New password
                VStack(alignment: .leading, spacing: 8) {
                    Text("新密码")
                        .font(.subheadline.bold())
                        .foregroundColor(.appTextPrimary)

                    SecureField("请输入新密码(至少6位)", text: $newPassword)
                        .font(.body)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.appDivider, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 16)

                // Confirm password
                VStack(alignment: .leading, spacing: 8) {
                    Text("确认新密码")
                        .font(.subheadline.bold())
                        .foregroundColor(.appTextPrimary)

                    SecureField("请再次输入新密码", text: $confirmPassword)
                        .font(.body)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    (!confirmPassword.isEmpty && confirmPassword != newPassword)
                                        ? Color.appStockUp : Color.appDivider,
                                    lineWidth: 1
                                )
                        )

                    if !confirmPassword.isEmpty && confirmPassword != newPassword {
                        Text("两次输入的密码不一致")
                            .font(.caption)
                            .foregroundColor(.appStockUp)
                    }
                }
                .padding(.horizontal, 16)

                // Submit button
                Button {
                    submitChange()
                } label: {
                    HStack {
                        if viewModel.loginState == .loading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        }
                        Text("确认修改")
                            .font(.subheadline.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isFormValid ? Color.appPrimary : Color.appTextHint)
                    )
                }
                .disabled(!isFormValid || viewModel.loginState == .loading)
                .padding(.horizontal, 16)

                // Password tips
                Text("密码长度至少6位，建议包含字母和数字")
                    .font(.caption)
                    .foregroundColor(.appTextHint)

                Spacer()
            }
            .background(Color.appBackground)
            .navigationTitle("修改密码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.appTextSecondary)
                }
            }
            .alert("修改成功", isPresented: $showSuccess) {
                Button("好的") {
                    viewModel.resetState()
                    dismiss()
                }
            } message: {
                Text("密码已更新，请妥善保管")
            }
            .alert("修改失败", isPresented: $showError) {
                Button("好的") {
                    viewModel.resetState()
                }
            } message: {
                Text(viewModel.errorMessage.isEmpty ? "未知错误" : viewModel.errorMessage)
            }
            .onChange(of: viewModel.loginState) { _, newState in
                if case .success = newState {
                    showSuccess = true
                } else if case .error = newState {
                    showError = true
                }
            }
        }
    }

    private func submitChange() {
        Task {
            await viewModel.changePassword(
                username: username,
                oldPassword: oldPassword,
                newPassword: newPassword
            )
        }
    }
}

#Preview {
    ChangePasswordSheet(
        viewModel: ProfileViewModel(),
        username: "测试用户"
    )
}
