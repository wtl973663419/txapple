import SwiftUI

struct FriendRequestView: View {
    var viewModel: TeatimeViewModel

    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.friendRequests.filter { $0.status == "pending" }) { request in
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        // Avatar
                        Image(systemName: request.userAvatar)
                            .font(.title3)
                            .foregroundColor(.appPrimary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.appPrimaryLight))

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text(request.userName)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.appTextPrimary)

                                if request.isVip {
                                    Image(systemName: "crown.fill")
                                        .font(.caption2)
                                        .foregroundColor(.vipGold)
                                }
                            }

                            Text(request.verifyMessage)
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                                .lineLimit(2)

                            Text(request.requestTime)
                                .font(.caption2)
                                .foregroundColor(.appTextHint)
                        }

                        Spacer()

                        // Accept / reject buttons
                        HStack(spacing: 8) {
                            Button {
                                viewModel.rejectFriendRequest(id: request.id)
                            } label: {
                                Text("拒绝")
                                    .font(.caption.bold())
                                    .foregroundColor(.appTextSecondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.appDivider, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)

                            Button {
                                viewModel.acceptFriendRequest(id: request.id)
                            } label: {
                                Text("接受")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.appPrimary)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 12)

                    if request.id != viewModel.friendRequests.filter({ $0.status == "pending" }).last?.id {
                        Divider()
                            .foregroundColor(.appDivider)
                    }
                }
            }
        }
    }
}

#Preview {
    FriendRequestView(viewModel: TeatimeViewModel())
}
