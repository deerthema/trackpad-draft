import SwiftUI

struct DraftView: View {
    @StateObject private var engine: CanvasEngine
    @State private var keyMonitor: Any?
    @State private var isShiftPressed = false

    @MainActor
    init(engine: CanvasEngine? = nil) {
        _engine = StateObject(wrappedValue: engine ?? CanvasEngine())
    }

    private var crosshair: Path {
        Path { path in
            for sign in [-1.0, 1.0] {
                path.move(to: CGPoint(x: 14 + sign * 6, y: 14))
                path.addLine(to: CGPoint(x: 14 + sign * 13, y: 14))
                path.move(to: CGPoint(x: 14, y: 14 + sign * 6))
                path.addLine(to: CGPoint(x: 14, y: 14 + sign * 13))
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background color for the translucent paper feel
            Color.white.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            // The drawing canvas
            Canvas { context, size in
                context.translateBy(x: engine.offset.width, y: engine.offset.height)
                
                for stroke in engine.strokes {
                    var path = Path()
                    guard let first = stroke.points.first else { continue }
                    path.move(to: first)
                    for point in stroke.points.dropFirst() {
                        path.addLine(to: point)
                    }
                    context.stroke(path, with: .color(stroke.color), style: StrokeStyle(lineWidth: stroke.lineWidth, lineCap: .round, lineJoin: .round))
                }
                
                // Draw current stroke
                if let active = engine.currentStroke, let first = active.points.first {
                    var path = Path()
                    path.move(to: first)
                    for point in active.points.dropFirst() {
                        path.addLine(to: point)
                    }
                    context.stroke(path, with: .color(active.color), style: StrokeStyle(lineWidth: active.lineWidth, lineCap: .round, lineJoin: .round))
                }
            }
            
            // The Touch Input overlay
            TouchCanvasView(engine: engine)
                .edgesIgnoringSafeArea(.all)
                
            // A persistent crosshair: faint at the last location, solid while touching.
            if !engine.isMouseVisible {
                GeometryReader { geometry in
                    ZStack {
                        if engine.currentMode == .eraser {
                            Circle()
                                .stroke(Color.black.opacity(0.6), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                                .frame(width: engine.eraserRadius * 2, height: engine.eraserRadius * 2)
                        }
                        if engine.isPositioning {
                            Circle()
                                .stroke(Color.blue, lineWidth: 2)
                                .frame(width: 18, height: 18)
                        }
                        crosshair.stroke(Color.white, lineWidth: 3)
                        .overlay { crosshair.stroke(Color.black, lineWidth: 1) }
                        .frame(width: 28, height: 28)
                        Circle()
                            .fill(engine.penColor.color)
                            .frame(width: 4, height: 4)
                            .overlay(Circle().strokeBorder(Color.white, lineWidth: 1))
                    }
                    .opacity(engine.isTouchActive ? 1 : 0.5)
                    .position(engine.virtualCursorPosition ?? CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
                }
                .allowsHitTesting(false)
            }

            // Opaque controls stay readable in both appearances and while drawing.
            GeometryReader { geometry in
                HStack(alignment: .top) {
                    Spacer()
                    DrawingToolbar(engine: engine, isShiftPressed: isShiftPressed)
                        .frame(width: 168, height: min(376, max(100, geometry.size.height - 24)))
                        .allowsHitTesting(engine.isMouseVisible)
                }
                .padding(12)
            }

            Button(action: { DraftWindowManager.shared.hideWindow() }) {
                EmptyView()
            }
            .keyboardShortcut(.escape, modifiers: [])
            .opacity(0)
        }
        .onAppear {
            isShiftPressed = NSEvent.modifierFlags.contains(.shift)
            keyMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
                if event.type == .flagsChanged {
                    isShiftPressed = event.modifierFlags.contains(.shift)
                    engine.updateTouchModifiers(positioning: event.modifierFlags.contains(.option),
                                                straightLine: isShiftPressed)
                    return event
                }
                guard event.window?.title == "Draft" else { return event }
                if event.modifierFlags.contains(.command) {
                    // Cmd+Z: undo
                    if event.keyCode == 6 { // Z key
                        engine.undo()
                        return nil
                    }
                } else {
                    switch event.keyCode {
                    case 18: // 1
                        engine.currentMode = .pen
                        return nil
                    case 19: // 2
                        engine.currentMode = .eraser
                        return nil
                    default:
                        break
                    }
                }
                return event
            }
        }
        .onDisappear {
            if let m = keyMonitor {
                NSEvent.removeMonitor(m)
                keyMonitor = nil
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .draftWindowDidShow)) { notification in
            isShiftPressed = NSEvent.modifierFlags.contains(.shift)
            engine.updateTouchModifiers(positioning: NSEvent.modifierFlags.contains(.option),
                                        straightLine: isShiftPressed)
            if let info = notification.object as? [String: Bool], let isFirstTime = info["isFirstTime"], isFirstTime {
                // Start in mouse mode when window opens for the first time
                engine.isMouseVisible = true
            } else {
                engine.isMouseVisible = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .draftWindowDidHide)) { _ in
            isShiftPressed = false
            engine.cancelTouch()
            // Reset to mouse mode so state is consistent next time the window shows
            engine.isMouseVisible = true
        }
    }
}
