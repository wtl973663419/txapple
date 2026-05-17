import SwiftUI

/// A semi-transparent overlay with a ProgressView and optional message text.
/// Used to block user interaction during network operations.
struct LoadingOverlay: View {
    let message: String?

    init(message: String? = nil) {
        self.message = message
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)

                if let message, !message.isEmpty {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.7))
            )
        }
    }
}

/// A modifier to conditionally show a loading overlay.
extension View {
    func loadingOverlay(isLoading: Bool, message: String? = nil) -> some View {
        self.overlay {
            if isLoading {
                LoadingOverlay(message: message)
            }
        }
    }
}

#Preview {
    Text("Background content")
        .font(.title)
        .loadingOverlay(isLoading: true, message: "正在加载数据...")
}
