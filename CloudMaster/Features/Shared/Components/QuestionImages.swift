import SwiftUI

struct QuestionImages: View {
    let images: [ImageInfo]
    @Binding var currentImageIndex: Int
    @Binding var isFullscreenImageShown: Bool
    @Binding var selectedImageIndex: Int

    var body: some View {
        if !images.isEmpty {
            TabView(selection: $currentImageIndex) {
                ForEach(images.indices, id: \.self) { index in
                    let imageInfo = images[index]
                    if let image = loadImage(from: imageInfo.path) {
                        Image(uiImage: image)
                            .resizable()
                            .cornerRadius(2)
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .tag(index)
                            .onTapGesture {
                                selectedImageIndex = index
                                isFullscreenImageShown = true
                            }
                    } else if let url = imageInfo.url, let urlImage = loadImage(from: url) {
                        Image(uiImage: urlImage)
                            .resizable()
                            .cornerRadius(2)
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .tag(index)
                            .onTapGesture {
                                selectedImageIndex = index
                                isFullscreenImageShown = true
                            }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 300)
        }
    }

    private func loadImage(from imagePath: String) -> UIImage? {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageURL = documentsURL.appendingPathComponent(imagePath)
        return UIImage(contentsOfFile: imageURL.path)
    }
}


struct FullscreenImageView: View {
    let images: [ImageInfo]
    @Binding var selectedImageIndex: Int
    @Binding var isShown: Bool

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            if let imageInfo = images[safe: selectedImageIndex],
               let uiImage = loadImage(from: imageInfo.path) ?? loadImage(from: imageInfo.url) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                self.scale = self.lastScale * value
                            }
                            .onEnded { _ in
                                self.lastScale = self.scale
                            }
                    )
                    .onTapGesture {
                        isShown = false
                    }
            }
        }
    }

    private func loadImage(from imagePath: String?) -> UIImage? {
        guard let imagePath = imagePath else { return nil }
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageURL = documentsURL.appendingPathComponent(imagePath)
        return UIImage(contentsOfFile: imageURL.path)
    }
}

// extension to safely access array elements to avoid out-of-bounds 
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
