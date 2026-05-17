import SwiftUI

struct FriendRow: View {
    let friend: Friend

    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            Image(systemName: friend.avatar)
                .font(.title3)
                .foregroundColor(.appPrimary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.appPrimaryLight))

            // Name and signature
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(friend.name)
                        .font(.subheadline.bold())
                        .foregroundColor(.appTextPrimary)

                    if friend.isVip {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(.vipGold)
                    }
                }

                Text(friend.signature)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Message button
            Image(systemName: "message")
                .font(.caption)
                .foregroundColor(.appPrimary)
                .padding(8)
                .background(Circle().fill(Color.appPrimaryLight))
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    VStack {
        FriendRow(friend: Friend(
            id: "f1",
            name: "量化猎手",
            avatar: "person.circle.fill",
            isVip: true,
            signature: "量化交易，数据为王"
        ))
        FriendRow(friend: Friend(
            id: "f2",
            name: "短线高手",
            avatar: "person.circle.fill",
            isVip: false,
            signature: "快进快出，知行合一"
        ))
    }
    .padding()
}
