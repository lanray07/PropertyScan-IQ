import SwiftUI

struct PropertyCard: View {
    var property: Property
    var inspectionCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(systemName: "building.2.crop.circle")
                    .font(.title2)
                    .foregroundStyle(PSITheme.accent)
                VStack(alignment: .leading, spacing: 3) {
                    Text(property.name)
                        .font(.headline)
                    Text(property.address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
            }

            HStack {
                Label(property.propertyTypeLabel, systemImage: "house")
                Spacer()
                Label("\(inspectionCount)", systemImage: "doc.text.magnifyingglass")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .psiCard()
    }
}
