import PhotosUI
import SwiftUI
import UIKit

struct PhotoUploadCard: View {
    var photos: [InspectionPhoto]
    @Binding var selectedItems: [PhotosPickerItem]
    var cameraAvailable: Bool
    var onCamera: () -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 112), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Photo evidence")
                        .font(.headline)
                    Text("\(photos.count) photos attached")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            HStack {
                PhotosPicker(selection: $selectedItems, maxSelectionCount: 12, matching: .images) {
                    Label("Upload", systemImage: "photo.on.rectangle.angled")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button(action: onCamera) {
                    Label("Camera", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!cameraAvailable)
            }

            if photos.isEmpty {
                EmptyStateView(
                    systemImage: "photo.badge.plus",
                    title: "No photos yet",
                    message: "Add room photos before running a visual AI scan."
                )
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(photos) { photo in
                        photoThumbnail(photo)
                    }
                }
            }
        }
        .psiCard()
    }

    @ViewBuilder
    private func photoThumbnail(_ photo: InspectionPhoto) -> some View {
        if let data = photo.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(height: 118)
                .clipShape(RoundedRectangle(cornerRadius: PSITheme.radius, style: .continuous))
                .overlay(alignment: .bottomLeading) {
                    if !photo.caption.isEmpty {
                        Text(photo.caption)
                            .font(.caption2.weight(.semibold))
                            .padding(6)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: PSITheme.compactRadius))
                            .padding(6)
                    }
                }
        } else {
            RoundedRectangle(cornerRadius: PSITheme.radius)
                .fill(PSITheme.subtlePanel)
                .frame(height: 118)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
        }
    }
}
