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
        print("PASS: per-stroke ink, in-progress changes, eraser/clear/draw undo, all six saved colors, invalid preference fallback")
    }
}
