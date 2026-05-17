import SwiftUI

struct PostDetailView: View {
    let post: Post
    var viewModel: CommunityViewModel

    @State private var commentText: String = ""
    @FocusState private var isCommentFocused: Bool

    var detailPost: Post {
        viewModel.posts.first { $0.id == post.id } ?? post
    }

    var body: some View {
        VStack(spacing: 0) {
            // Scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text(detailPost.title)
                        .font(.title3.bold())
                        .foregroundColor(.appTextPrimary)
                        .padding(.top, 8)

                    // Author info
                    HStack(spacing: 10) {
                        Image(systemName: detailPost.avatar)
                            .font(.title3)
                            .foregroundColor(.appPrimary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.appPrimaryLight))

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(detailPost.author)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.appTextPrimary)

                                if detailPost.isVip {
                                    Image(systemName: "crown.fill")
                                        .font(.caption2)
                                        .foregroundColor(.vipGold)
                                }
                            }
                            Text(detailPost.time)
                                .font(.caption)
                                .foregroundColor(.appTextHint)
                        }

                        Spacer()

                        Text(detailPost.category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.appChipBlue))
                            .foregroundColor(.appPrimary)
                    }

                    Divider().foregroundColor(.appDivider)

                    // Full content
                    Text(detailPost.content)
                        .font(.body)
                        .foregroundColor(.appTextPrimary)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)

                    Divider().foregroundColor(.appDivider)

                    // Action bar
                    HStack(spacing: 24) {
                        Button {
                            viewModel.likePost(id: detailPost.id)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "hand.thumbsup")
                                    .font(.subheadline)
                                Text("点赞 \(detailPost.likes)")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.appTextSecondary)
                        }
                        .buttonStyle(.plain)

                        HStack(spacing: 6) {
                            Image(systemName: "text.bubble")
                                .font(.subheadline)
                            Text("评论 \(detailPost.comments)")
                                .font(.subheadline)
                        }
                        .foregroundColor(.appTextSecondary)

                        Spacer()
                    }

                    // Comments section header
                    if !detailPost.commentList.isEmpty {
                        HStack {
                            Text("全部评论 (\(detailPost.commentList.count))")
                                .font(.headline)
                                .foregroundColor(.appTextPrimary)
                            Spacer()
                        }
                        .padding(.top, 8)

                        // Comment list
                        ForEach(detailPost.commentList) { comment in
                            CommentRow(
                                comment: comment,
                                onLike: {
                                    viewModel.likeComment(postId: detailPost.id, commentId: comment.id)
                                }
                            )
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "text.bubble")
                                .font(.title2)
                                .foregroundColor(.appTextHint)
                            Text("暂无评论，来说两句吧")
                                .font(.subheadline)
                                .foregroundColor(.appTextHint)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 80)
            }

            // Bottom comment input bar
            VStack(spacing: 0) {
                Divider().foregroundColor(.appDivider)

                HStack(spacing: 12) {
                    TextField("写下你的评论...", text: $commentText, axis: .vertical)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.appBackgroundInput)
                        )
                        .focused($isCommentFocused)
                        .lineLimit(1...4)

                    Button {
                        let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            viewModel.addComment(postId: detailPost.id, content: trimmed)
                            commentText = ""
                            isCommentFocused = false
                        }
                    } label: {
                        Text("发送")
                            .font(.subheadline.bold())
                            .foregroundColor(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .appTextHint : .appPrimary)
                    }
                    .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)
            }
        }
        .background(Color.appBackground)
    }
}

#Preview {
    NavigationStack {
        PostDetailView(
            post: CommunityViewModel.mockPosts()[0],
            viewModel: CommunityViewModel()
        )
    }
}
