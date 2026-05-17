import SwiftUI

// MARK: - App Color Theme (Material Design 3 equivalents from Android)

extension Color {
    static let appPrimary = Color(hex: "#1A73E8")
    static let appPrimaryDark = Color(hex: "#1557B0")
    static let appPrimaryLight = Color(hex: "#E8F0FE")
    static let appAccent = Color(hex: "#FF6B35")

    static let appBackground = Color(hex: "#F5F7FA")
    static let appBackgroundLight = Color(hex: "#F8FAFC")
    static let appBackgroundSecondary = Color(hex: "#F3F4F6")
    static let appBackgroundInput = Color(hex: "#F9FAFB")

    static let appTextPrimary = Color(hex: "#1A1A2E")
    static let appTextSecondary = Color(hex: "#6B7280")
    static let appTextHint = Color(hex: "#9CA3AF")

    static let appStockUp = Color(hex: "#C0392B")
    static let appStockDown = Color(hex: "#27AE60")

    static let appDivider = Color(hex: "#E5E7EB")
    static let appWarning = Color(hex: "#FF6B35")

    // VIP colors
    static let vipSilver = Color(hex: "#78909C")
    static let vipGold = Color(hex: "#FFB800")
    static let vipDiamond = Color(hex: "#9B59B6")
    static let vipCrown = Color(hex: "#E91E63")

    static let appChipGreen = Color(hex: "#E8F5E9")
    static let appChipRed = Color(hex: "#FFEBEE")
    static let appChipBlue = Color(hex: "#E3F2FD")

    // MARK: - Hex initializer

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Shared ViewModifiers

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
            )
    }
}

struct ChipStyle: ViewModifier {
    var color: Color = .appChipBlue

    func body(content: Content) -> some View {
        content
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(color))
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }

    func chipStyle(color: Color = .appChipBlue) -> some View {
        modifier(ChipStyle(color: color))
    }

    func stockColor(_ isUp: Bool) -> some View {
        self.foregroundColor(isUp ? .appStockUp : .appStockDown)
    }
}

// MARK: - Double Formatting

extension Double {
    var priceString: String {
        String(format: "%.2f", self)
    }

    var percentString: String {
        String(format: "%+.2f%%", self)
    }

    var volumeString: String {
        if self >= 1_0000_0000 {
            return String(format: "%.2f亿", self / 1_0000_0000)
        } else if self >= 1_0000 {
            return String(format: "%.2f万", self / 1_0000)
        }
        return String(format: "%.0f", self)
    }

    var amountYiString: String {
        String(format: "%.2f亿", self / 1_0000_0000)
    }
}

extension Int64 {
    var volumeString: String {
        Double(self).volumeString
    }
}
