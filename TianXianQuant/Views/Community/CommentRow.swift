import SwiftUI

struct CommentRow: View {
    let comment: Comment
    var onLike: () -> Void = {}

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Avatar
            Image(systemName: comment.authorAvatar.isEmpty ? "person.circle.fill" : comment.authorAvatar)
                .font(.callout)
                .foregroundColor(.appPrimary)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Color.appPrimaryLight))

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(comment.author)
                        .font(.subheadline.bold())
                        .foregroundColor(.appTextPrimary)
                    Text(comment.time)
                        .font(.caption)
                        .foregroundColor(.appTextHint)
                    Spacer()

                    // Like button
                    Button {
                        onLike()
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: comment.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .font(.caption2)
                            if comment.likes > 0 {
                                Text("\(comment.likes)")
                                    .font(.caption2)
                            }
                        }
                        .foregroundColor(comment.isLiked ? .appPrimary : .appTextHint)
                    }
                    .buttonStyle(.plain)
                }

                Text(comment.content)
                    .font(.subheadline)
                    .foregroundColor(.appTextPrimary)
                    .lineSpacing(3)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.appBackgroundInput)
        )
    }
}

#Preview {
    VStack {
        CommentRow(comment: Comment(
            id: "c1",
            postId: "p1",
            author: "量化猎手",
            authorAvatar: "person.circle.fill",
            content: "学习了！MACD金叉确实是个好信号，但也要注意大环境。",
            time: "1小时前",
            likes: 23,
            isLiked: false
        ))
    }
    .padding()
    .background(Color.appBackground)
}
