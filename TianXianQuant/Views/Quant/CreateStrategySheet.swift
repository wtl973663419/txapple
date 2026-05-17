import SwiftUI

// MARK: - Create Strategy Sheet

struct CreateStrategySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var name = ""
    @State private var description = ""

    let onCreated: (String, String) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // VIP notice
                vipNotice

                // Name field
                VStack(alignment: .leading, spacing: 6) {
                    Text("策略名称")
                        .font(.subheadline.bold())
                        .foregroundColor(.appTextPrimary)
                    TextField("输入策略名称", text: $name)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.appBackgroundInput)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.appDivider, lineWidth: 1)
                        )
                }

                // Description field
                VStack(alignment: .leading, spacing: 6) {
                    Text("策略描述")
                        .font(.subheadline.bold())
                        .foregroundColor(.appTextPrimary)
                    TextEditor(text: $description)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.appBackgroundInput)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.appDivider, lineWidth: 1)
                        )
                        .scrollContentBackground(.hidden)
                }

                Spacer()

                // Create button
                Button {
                    guard canCreate else { return }
                    onCreated(name.trimmingCharacters(in: .whitespaces), description.trimmingCharacters(in: .whitespaces))
                    dismiss()
                } label: {
                    Text(canCreate && appState.isVip ? "创建策略" : "创建策略")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill((canCreate && appState.isVip) ? Color.appPrimary : Color.gray.opacity(0.5))
                        )
                }
                .disabled(!canCreate || !appState.isVip)
            }
            .padding(20)
            .navigationTitle("创建自定义策略")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - VIP Notice

    private var vipNotice: some View {
        HStack(spacing: 10) {
            Image(systemName: "crown.fill")
                .font(.title3)
                .foregroundColor(.vipGold)
            VStack(alignment: .leading, spacing: 2) {
                Text("创建自定义策略需VIP会员")
                    .font(.subheadline.bold())
                    .foregroundColor(.appTextPrimary)
                Text("VIP会员可创建无限个自定义策略并进行回测")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.vipGold.opacity(0.1))
        )
    }
}
