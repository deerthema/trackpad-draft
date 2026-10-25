import SwiftUI

struct DrawingToolbar: View {
    @ObservedObject var engine: CanvasEngine
    var isShiftPressed: Bool

    private var straightLineActive: Bool {
        engine.currentMode == .pen && (isShiftPressed || engine.isStraightStroke)
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 10) {
                VStack(spacing: 4) {
                    toolButton(.pen, title: L10n.pen, symbol: "pencil", shortcut: "1")
                    toolButton(.eraser, title: L10n.eraser, symbol: "eraser", shortcut: "2")
                }

                Divider()

                PenColorPicker(selection: $engine.penColor)

                VStack(spacing: 4) {
                    HStack {
                        Text(engine.currentMode == .pen ? L10n.strokeWidth : L10n.eraserSize)
                        Spacer()
                        Text(engine.currentMode == .pen
                             ? String(format: "%g pt", Double(engine.penLineWidth))
                             : String(format: "%g pt", Double(engine.eraserRadius * 2)))
                            .monospacedDigit()
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.primary)

                    if engine.currentMode == .pen {
                        Slider(value: $engine.penLineWidth, in: 1...8, step: 0.5)
                            .accessibilityLabel(L10n.strokeWidth)
                    } else {
                        Slider(value: $engine.eraserRadius, in: 5...40, step: 1)
                            .accessibilityLabel(L10n.eraserSize)
                    }
                }
                .controlSize(.small)
                .padding(.horizontal, 4)

                HStack(spacing: 6) {
                    Image(systemName: "shift")
                        .font(.system(size: 12, weight: .semibold))
                    Text(L10n.straightLine)
                        .font(.system(size: 11, weight: .medium))
                    Spacer(minLength: 0)
                    if straightLineActive {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                    }
                }
                .padding(.horizontal, 8)
                .frame(height: 28)
                .foregroundStyle(straightLineActive ? Color.white : Color.primary)
                .background(straightLineActive ? Color.blue : Color(nsColor: .controlBackgroundColor),
                            in: RoundedRectangle(cornerRadius: 7))
                .help(L10n.straightLineHelp)
                .accessibilityLabel(L10n.straightLineHelp)

                Divider()

                VStack(spacing: 4) {
                    Button { engine.undo() } label: {
                        actionLabel(L10n.undo, symbol: "arrow.uturn.backward", shortcut: "⌘Z")
                            .foregroundStyle(engine.canUndo ? Color.primary : Color.secondary)
                    }
                    .disabled(!engine.canUndo)
                    .keyboardShortcut("z", modifiers: .command)
                    .help(L10n.undoStroke)

                    Button {
                        engine.clearAll()
                        engine.offset = .zero
                    } label: {
                        actionLabel(L10n.clear, symbol: "trash", shortcut: "⌫")
                            .foregroundStyle(Color(nsColor: .systemRed))
                    }
                    .keyboardShortcut(.delete, modifiers: [])
                    .help(L10n.clearCanvas)
                }
                .buttonStyle(.plain)

                Text(engine.isMouseVisible ? L10n.clickToDraw : L10n.clickToEdit)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.18), lineWidth: 1)
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.20), radius: 10, x: 0, y: 3)
    }

    private func toolButton(_ mode: DrawingMode, title: String, symbol: String, shortcut: String) -> some View {
        let selected = engine.currentMode == mode
        return Button { engine.currentMode = mode } label: {
            actionLabel(title, symbol: symbol, shortcut: shortcut)
                .foregroundStyle(selected ? Color.white : Color.primary)
                .background(selected ? Color.blue : Color.clear, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
        .help(mode == .pen ? L10n.switchToPen : L10n.switchToEraser)
    }

    private func actionLabel(_ title: String, symbol: String, shortcut: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 18)
            Text(title)
                .font(.system(size: 12, weight: .semibold))
            Spacer(minLength: 0)
            Text(shortcut)
                .font(.system(size: 10, weight: .medium, design: .rounded))
        }
        .padding(.horizontal, 8)
        .frame(height: 32)
        .contentShape(Rectangle())
    }
}
