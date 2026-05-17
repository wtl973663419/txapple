import SwiftUI

struct PostRow: View {
    let post: Post
    var onLike: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Author row
            HStack(spacing: 10) {
                // Avatar
                Image(systemName: post.avatar)
                    .font(.title3)
                    .foregroundColor(.appPrimary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.appPrimaryLight))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(post.author)
                            .font(.subheadline.bold())
                            .foregroundColor(.appTextPrimary)

                        if post.isVip {
                            Image(systemName: "crown.fill")
                                .font(.caption2)
                                .foregroundColor(.vipGold)
                        }
                    }

                    Text(post.time)
                        .font(.caption)
                        .foregroundColor(.appTextHint)
                }

                Spacer()

                // Category chip
                Text(post.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(backgroundColor(for: post.category)))
                    .foregroundColor(textColor(for: post.category))
            }

            // Title
            Text(post.title)
                .font(.headline)
                .foregroundColor(.appTextPrimary)
                .lineLimit(2)

            // Content preview
            Text(post.content)
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .lineLimit(3)
                .lineSpacing(4)

            // Bottom action bar
            HStack(spacing: 20) {
                // Likes
                Button {
                    onLike()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.thumbsup")
                            .font(.caption)
                        Text("\(post.likes)")
                            .font(.caption)
                    }
                    .foregroundColor(.appTextSecondary)
                }
                .buttonStyle(.plain)

                // Comments
                HStack(spacing: 4) {
                    Image(systemName: "text.bubble")
                        .font(.caption)
                    Text("\(post.comments)")
                        .font(.caption)
                }
                .foregroundColor(.appTextSecondary)

                Spacer()

                // Share button
                Button {
                    // Share action
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        )
    }

    private func backgroundColor(for category: String) -> Color {
        switch category {
        case "技术分析": return Color.appChipBlue
        case "基本面": return Color.appChipGreen
        case "量化策略": return Color.vipDiamond.opacity(0.12)
        case "复盘笔记": return Color.vipGold.opacity(0.15)
        case "新手交流": return Color.appBackgroundSecondary
        default: return Color.appChipBlue
        }
    }

    private func textColor(for category: String) -> Color {
        switch category {
        case "技术分析": return .appPrimary
        case "基本面": return Color(hex: "#2E7D32")
        case "量化策略": return .vipDiamond
        case "复盘笔记": return Color(hex: "#E65100")
        case "新手交流": return .appTextSecondary
        default: return .appPrimary
        }
    }
}

#Preview {
    PostRow(post: CommunityViewModel.mockPosts()[0])
        .padding()
        .background(Color.appBackground)
}
