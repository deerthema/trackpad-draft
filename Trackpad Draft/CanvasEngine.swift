import Foundation
import Combine
import CoreGraphics
import SwiftUI

enum DrawingMode {
    case pen
    case eraser
}

struct Stroke: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color = .black
    var lineWidth: CGFloat = 2.0
}

@MainActor
class CanvasEngine: ObservableObject {
    @Published var strokes: [Stroke] = []
    @Published var currentStroke: Stroke?
    @Published var offset: CGSize = .zero
    @Published var virtualCursorPosition: CGPoint?
    @Published private(set) var isStraightStroke = false
    
    @Published var currentMode: DrawingMode = .pen
    @Published var isMouseVisible: Bool = true
    
    @Published var penLineWidth: CGFloat = 2.0
    @Published var eraserRadius: CGFloat = 10.0
    @Published var penColor: PenColor {
        didSet { defaults.set(penColor.rawValue, forKey: SettingsKeys.penColor) }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        penColor = defaults.string(forKey: SettingsKeys.penColor)
            .flatMap(PenColor.init(rawValue:)) ?? .black
    }
    
    // Undo history: each element is a snapshot of `strokes` before a change
    private var undoStack: [[Stroke]] = []
    
    // Convert absolute trackpad coords to window coords
    // trackpad size roughly 14x8 cm, let's assume normalized 0...1 relative input
    
    // MARK: - Drawing & Erasing
    
    func beginStroke(at point: CGPoint, straightLine: Bool = false) {
        isStraightStroke = currentMode == .pen && straightLine
        if currentMode == .eraser {
            // Save snapshot before erasing begins
            undoStack.append(strokes)
            eraseStrokes(at: point)
        } else {
            // Capture ink at the start so changing the pen never recolors existing strokes.
            currentStroke = Stroke(points: [point], color: penColor.color, lineWidth: penLineWidth)
        }
    }
    
    func addPointToStroke(_ point: CGPoint) {
        if currentMode == .eraser {
            eraseStrokes(at: point)
        } else {
            if isStraightStroke, let start = currentStroke?.points.first {
                currentStroke?.points = [start, point]
            } else {
                currentStroke?.points.append(point)
            }
        }
    }
    
    private func eraseStrokes(at point: CGPoint) {
        let threshold: CGFloat = eraserRadius
        
        strokes.removeAll { stroke in
            guard let first = stroke.points.first else { return false }
            if hypot(first.x - point.x, first.y - point.y) < threshold { return true }
            // Test segments as well as endpoints, including the middle of straight lines.
            return zip(stroke.points, stroke.points.dropFirst()).contains { start, end in
                let dx = end.x - start.x
                let dy = end.y - start.y
                let lengthSquared = dx * dx + dy * dy
                guard lengthSquared > 0 else { return false }
                let t = max(0, min(1, ((point.x - start.x) * dx + (point.y - start.y) * dy) / lengthSquared))
                return hypot(point.x - (start.x + t * dx), point.y - (start.y + t * dy)) < threshold
            }
        }
    }
    
    func endStroke() {
        if let stroke = currentStroke {
            // Save snapshot before committing a new stroke
            undoStack.append(strokes)
            strokes.append(stroke)
        }
        currentStroke = nil
        isStraightStroke = false
    }
    
    func cancelStroke() {
        currentStroke = nil
        isStraightStroke = false
    }
    
    func clearAll() {
        guard !strokes.isEmpty else { return }
        undoStack.append(strokes)
        strokes.removeAll()
    }
    
    // MARK: - Undo
    
    func undo() {
        guard let previous = undoStack.popLast() else { return }
        cancelStroke()
        strokes = previous
    }
    
    var canUndo: Bool { !undoStack.isEmpty }
    
    func toggleMouseVisibility(in window: NSWindow?) {
        isMouseVisible.toggle()
        if isMouseVisible {
            DraftWindowManager.shared.unlockCursor()
        } else {
            // Warp cursor back to window center before locking
            if let win = window, let screenHeight = NSScreen.main?.frame.height {
                CGWarpMouseCursorPosition(CGPoint(x: win.frame.midX, y: screenHeight - win.frame.midY))
            }
            DraftWindowManager.shared.lockCursor()
        }
    }
}
