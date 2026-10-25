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
        let aiming = CanvasEngine(defaults: defaults)
        aiming.isMouseVisible = false
        aiming.beginTouch(at: .zero, positioning: true, straightLine: false)
        aiming.moveTouch(to: CGPoint(x: 50, y: 50))
        precondition(aiming.currentStroke == nil && aiming.strokes.isEmpty,
                     "Option positioning must never put down ink")
        aiming.updateTouchModifiers(positioning: false, straightLine: true)
        precondition(aiming.currentStroke?.points == [CGPoint(x: 50, y: 50)],
                     "Releasing Option must start immediately at the latest crosshair")
        aiming.moveTouch(to: CGPoint(x: 75, y: 100))
        aiming.moveTouch(to: CGPoint(x: 150, y: 50))
        aiming.endTouch()
        precondition(aiming.strokes[0].points == [CGPoint(x: 50, y: 50), CGPoint(x: 150, y: 50)],
                     "Option positioning and Shift lines must compose")
        precondition(!aiming.isTouchActive)

        aiming.beginTouch(at: .zero, positioning: true, straightLine: false)
        aiming.endTouch()
        aiming.updateTouchModifiers(positioning: false, straightLine: false)
        precondition(aiming.currentStroke == nil && aiming.strokes.count == 1,
                     "Releasing Option after lifting must not create a ghost stroke")

        aiming.currentMode = .eraser
        aiming.beginTouch(at: CGPoint(x: 100, y: 50), positioning: true, straightLine: false)
        precondition(aiming.strokes.count == 1, "Positioning must not erase")
        aiming.updateTouchModifiers(positioning: false, straightLine: false)
        aiming.endTouch()
        precondition(aiming.strokes.isEmpty, "Releasing Option must activate the eraser at the crosshair")
        aiming.undo()
        precondition(aiming.strokes.count == 1)

        aiming.currentMode = .pen
        aiming.beginTouch(at: .zero, positioning: false, straightLine: false)
        aiming.moveTouch(to: CGPoint(x: 10, y: 10))
        aiming.updateTouchModifiers(positioning: true, straightLine: false)
        aiming.moveTouch(to: CGPoint(x: 200, y: 200))
        aiming.updateTouchModifiers(positioning: false, straightLine: false)
        aiming.moveTouch(to: CGPoint(x: 210, y: 210))
        aiming.endTouch()
        precondition(aiming.strokes.count == 3)
        precondition(aiming.strokes[1].points == [.zero, CGPoint(x: 10, y: 10)])
        precondition(aiming.strokes[2].points == [CGPoint(x: 200, y: 200), CGPoint(x: 210, y: 210)],
                     "Repositioning mid-touch must not draw a bridge between strokes")
        print("PASS: colors, straight lines, undo/erasing, Option positioning, exact release anchor, modifier combinations and no ghost strokes")
    }
}
