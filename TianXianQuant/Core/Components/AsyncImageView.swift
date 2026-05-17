import SwiftUI

/// Reusable view that loads and displays a remote image from a URL.
/// Shows a ProgressView while loading, the loaded image on success,
/// and a placeholder SF Symbol on failure.
struct AsyncImageView: View {
    let url: URL?

    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var loadFailed = false

    private static let cache = URLCache(
        memoryCapacity: 50 * 1024 * 1024, // 50 MB
        diskCapacity: 200 * 1024 * 1024,  // 200 MB
        directory: nil
    )

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if loadFailed {
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.appTextHint)
                    .padding(8)
            } else {
                ProgressView()
                    .tint(.appTextHint)
            }
        }
        .task {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let url else {
            loadFailed = true
            isLoading = false
            return
        }

        // Check cache first
        let request = URLRequest(url: url)
        if let cachedResponse = Self.cache.cachedResponse(for: request),
           let cachedImage = UIImage(data: cachedResponse.data) {
            await MainActor.run {
                self.image = cachedImage
                self.isLoading = false
            }
            return
        }

        // Fetch from network
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let fetchedImage = UIImage(data: data) else {
                await setFailed()
                return
            }

            // Cache the response
            let cachedResponse = CachedURLResponse(
                response: response,
                data: data,
                storagePolicy: .allowed
            )
            Self.cache.storeCachedResponse(cachedResponse, for: request)

            await MainActor.run {
                self.image = fetchedImage
                self.isLoading = false
            }
        } catch {
            await setFailed()
        }
    }

    @MainActor
    private func setFailed() {
        loadFailed = true
        isLoading = false
    }
}

#Preview {
    VStack(spacing: 20) {
        AsyncImageView(url: nil)
            .frame(width: 80, height: 80)
            .clipShape(Circle())

        AsyncImageView(url: URL(string: "https://example.com/invalid.png"))
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
