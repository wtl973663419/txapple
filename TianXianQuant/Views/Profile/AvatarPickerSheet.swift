import SwiftUI

struct AvatarPickerSheet: View {
    let selectedIndex: Int
    var onSelect: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    private let symbols: [(name: String, color: Color)] = [
        ("person.circle.fill", Color.appPrimary),
        ("face.smiling", Color(hex: "#FF6B35")),
        ("star.circle.fill", Color.vipGold),
        ("heart.circle.fill", Color.appStockDown),
        ("bolt.circle.fill", Color.vipDiamond),
        ("flame.circle.fill", Color.appStockUp),
        ("leaf.circle.fill", Color(hex: "#00BCD4")),
        ("moon.circle.fill", Color.vipCrown)
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("选择头像")
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                    .padding(.top, 16)

                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<symbols.count, id: \.self) { index in
                        let item = symbols[index]
                        Button {
                            onSelect(index)
                            dismiss()
                        } label: {
                            Image(systemName: item.name)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(item.color)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color.appPrimaryLight.opacity(0.6))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(
                                            selectedIndex == index ? item.color : Color.clear,
                                            lineWidth: 3
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)

                Text("点击选择头像")
                    .font(.caption)
                    .foregroundColor(.appTextHint)
                    .padding(.top, 8)

                Spacer()
            }
            .background(Color.appBackground)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.appPrimary)
                }
            }
        }
    }
}

#Preview {
    AvatarPickerSheet(selectedIndex: 0) { _ in }
}
