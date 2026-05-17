import SwiftUI

/// A small badge displaying a crown icon and "VIP" text in gold.
/// Intended to be shown next to usernames or on profile cards.
struct VIPBadge: View {
    let size: VIPBadgeSize

    enum VIPBadgeSize {
        case small
        case medium

        var fontSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 8
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: return 2
            case .medium: return 4
            }
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "crown.fill")
                .font(.system(size: size.iconSize))
            Text("VIP")
                .font(.system(size: size.fontSize, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(
            Capsule()
                .fill(Color(hex: "#FFB800"))
        )
    }
}

/// Convenience modifier to show a VIP badge conditionally.
extension View {
    func vipBadge(isVip: Bool, size: VIPBadge.VIPBadgeSize = .small) -> some View {
        HStack(spacing: 4) {
            self
            if isVip {
                VIPBadge(size: size)
            }
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        Text("普通用户")
            .vipBadge(isVip: false, size: .small)

        Text("VIP用户")
            .vipBadge(isVip: true, size: .small)

        VStack(spacing: 8) {
            Text("用户名")
                .font(.title3)
                .vipBadge(isVip: true, size: .medium)
        }
    }
    .padding()
}
