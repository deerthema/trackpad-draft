import SwiftUI

struct PenColorPicker: View {
    @Binding var selection: PenColor
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(selection.color)
                    .frame(width: 18, height: 18)
                    .overlay(Circle().strokeBorder(Color.primary.opacity(0.25), lineWidth: 1))
                Text(L10n.ink)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.primary)
                Spacer(minLength: 0)
                Text(selection.localizedName)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 4)
            .frame(height: 32)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(L10n.penColor)
        .accessibilityLabel(L10n.penColor)
        .accessibilityValue(selection.localizedName)
        .popover(isPresented: $isPresented, arrowEdge: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                Text(L10n.penColor)
                    .font(.headline)
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(32)), count: 3), spacing: 8) {
                    ForEach(PenColor.allCases) { ink in
                        Button {
                            selection = ink
                            isPresented = false
                        } label: {
                            Circle()
                                .fill(ink.color)
                                .frame(width: 26, height: 26)
                                .overlay(Circle().strokeBorder(Color.primary.opacity(0.25), lineWidth: 1))
                                .overlay {
                                    if selection == ink {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .help(ink.localizedName)
                        .accessibilityLabel(ink.localizedName)
                        .accessibilityAddTraits(selection == ink ? [.isSelected] : [])
                    }
                }
            }
            .padding(14)
        }
    }
}
