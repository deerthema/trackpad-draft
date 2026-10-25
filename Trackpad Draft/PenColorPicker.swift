import SwiftUI

struct PenColorPicker: View {
    @Binding var selection: PenColor
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            HStack(spacing: 4) {
                Circle()
                    .fill(selection.color)
                    .frame(width: 16, height: 16)
                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 38, height: 28)
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
