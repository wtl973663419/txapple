import SwiftUI

struct CreatePostSheet: View {
    var viewModel: CommunityViewModel

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedCategory: String = "技术分析"
    @Environment(\.dismiss) private var dismiss

    private let categories = ["技术分析", "基本面", "量化策略", "复盘笔记", "新手交流"]

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Category picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("分类")
                            .font(.subheadline.bold())
                            .foregroundColor(.appTextPrimary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(categories, id: \.self) { category in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedCategory = category
                                        }
                                    } label: {
                                        Text(category)
                                            .font(.subheadline)
                                            .fontWeight(selectedCategory == category ? .semibold : .regular)
                                            .foregroundColor(selectedCategory == category ? .white : .appTextSecondary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(selectedCategory == category ? Color.appPrimary : Color.appBackgroundSecondary)
                                            )
                                    }
                                }
                            }
                        }
                    }

                    // Title field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("标题")
                            .font(.subheadline.bold())
                            .foregroundColor(.appTextPrimary)

                        TextField("请输入帖子标题", text: $title)
                            .font(.body)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.appDivider, lineWidth: 1)
                            )
                    }

                    // Content editor
                    VStack(alignment: .leading, spacing: 8) {
                        Text("内容")
                            .font(.subheadline.bold())
                            .foregroundColor(.appTextPrimary)

                        ZStack(alignment: .topLeading) {
                            if content.isEmpty {
                                Text("分享你的投资心得、分析或问题...")
                                    .font(.body)
                                    .foregroundColor(.appTextHint)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 8)
                            }
                            TextEditor(text: $content)
                                .font(.body)
                                .frame(minHeight: 200)
                                .padding(4)
                                .scrollContentBackground(.hidden)
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.appDivider, lineWidth: 1)
                        )
                    }

                    // Tips
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle")
                            .font(.caption)
                        Text("文明发言，理性讨论。违规内容将被删除。")
                            .font(.caption)
                    }
                    .foregroundColor(.appTextHint)
                    .padding(.top, 8)
                }
                .padding(16)
            }
            .background(Color.appBackground)
            .navigationTitle("发表帖子")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.appTextSecondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
                        viewModel.addPost(title: trimmedTitle, content: trimmedContent, category: selectedCategory)
                        dismiss()
                    } label: {
                        Text("发布")
                            .font(.headline)
                            .foregroundColor(isFormValid ? .appPrimary : .appTextHint)
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
}

#Preview {
    CreatePostSheet(viewModel: CommunityViewModel())
}
