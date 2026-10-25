import Foundation
import SwiftUI

@main
struct CanvasEngineColorTests {
    @MainActor
    static func main() {
        let suite = "TrackpadDraft.ColorTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let engine = CanvasEngine(defaults: defaults)
        precondition(engine.penColor == .black, "New users should start with black ink")

        engine.penColor = .red
        engine.penLineWidth = 4
        engine.beginStroke(at: .zero)
        engine.penColor = .blue
        engine.addPointToStroke(CGPoint(x: 20, y: 20))
        engine.endStroke()
        precondition(engine.strokes[0].color == PenColor.red.color,
                     "Changing ink must not recolor a stroke already in progress")
        precondition(engine.strokes[0].lineWidth == 4)

        engine.beginStroke(at: CGPoint(x: 100, y: 100))
        engine.addPointToStroke(CGPoint(x: 120, y: 120))
        engine.endStroke()
        precondition(engine.strokes.map(\.color) == [PenColor.red.color, PenColor.blue.color],
                     "Old and new strokes must retain different colors")

        engine.currentMode = .eraser
        engine.beginStroke(at: .zero)
        engine.endStroke()
        precondition(engine.strokes.map(\.color) == [PenColor.blue.color])
        engine.undo()
        precondition(engine.strokes.map(\.color) == [PenColor.red.color, PenColor.blue.color],
                     "Undoing erasure must restore the original ink")
        engine.clearAll()
        engine.undo()
        precondition(engine.strokes.map(\.color) == [PenColor.red.color, PenColor.blue.color])
        engine.undo()
        precondition(engine.strokes.map(\.color) == [PenColor.red.color])
        precondition(engine.penColor == .blue, "Undo must not change the selected pen color")

        for ink in PenColor.allCases {
            engine.penColor = ink
            let restored = CanvasEngine(defaults: defaults)
            precondition(restored.penColor == ink, "Color choice must survive engine recreation")
            restored.beginStroke(at: .zero)
            restored.endStroke()
            precondition(restored.strokes[0].color == ink.color)
        }

        defaults.set("unknown-color", forKey: SettingsKeys.penColor)
        precondition(CanvasEngine(defaults: defaults).penColor == .black,
                     "Unknown saved colors must fall back safely")

        let lines = CanvasEngine(defaults: defaults)
        lines.penColor = .purple
        lines.penLineWidth = 3
        lines.beginStroke(at: .zero, straightLine: true)
        lines.addPointToStroke(CGPoint(x: 25, y: 40))
        lines.addPointToStroke(CGPoint(x: 100, y: 0))
        precondition(lines.currentStroke?.points == [.zero, CGPoint(x: 100, y: 0)],
                     "Shift drawing must preview only the anchor and current endpoint")
        precondition(lines.isStraightStroke)
        lines.endStroke()
        precondition(!lines.isStraightStroke)
        precondition(lines.strokes[0].color == PenColor.purple.color && lines.strokes[0].lineWidth == 3)

        lines.currentMode = .eraser
        lines.beginStroke(at: CGPoint(x: 50, y: 30), straightLine: true)
        lines.endStroke()
        precondition(lines.strokes.count == 1, "Eraser must not remove a distant line")
        precondition(!lines.isStraightStroke, "Shift must not change eraser behavior")
        lines.beginStroke(at: CGPoint(x: 50, y: 0))
        lines.endStroke()
        precondition(lines.strokes.isEmpty, "The middle of a two-endpoint line must be erasable")
        lines.undo()
        precondition(lines.strokes[0].points == [.zero, CGPoint(x: 100, y: 0)])

        lines.currentMode = .pen
        lines.beginStroke(at: .zero)
        lines.addPointToStroke(CGPoint(x: 20, y: 30))
        lines.addPointToStroke(CGPoint(x: 40, y: 0))
        precondition(lines.currentStroke?.points.count == 3, "Ordinary drawing must remain freehand")
        lines.cancelStroke()
        lines.beginStroke(at: .zero, straightLine: true)
        lines.cancelStroke()
        precondition(!lines.isStraightStroke && lines.currentStroke == nil)
        precondition(lines.strokes.count == 1, "Cancelled lines must not be committed")

        lines.beginStroke(at: CGPoint(x: 200, y: 200), straightLine: true)
        lines.addPointToStroke(CGPoint(x: 200, y: 200))
        lines.endStroke()
        lines.currentMode = .eraser
        lines.beginStroke(at: CGPoint(x: 200, y: 200))
        lines.endStroke()
        precondition(lines.strokes.count == 1, "Zero-length strokes must erase without invalid geometry")
        print("PASS: pen colors and persistence; straight-line previews, ink, cancellation, freehand reset, segment erasing and undo")
    }
}
