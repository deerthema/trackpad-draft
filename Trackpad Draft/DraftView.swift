import SwiftUI

struct DraftView: View {
    @StateObject private var engine = CanvasEngine()
    @State private var keyMonitor: Any?
    @State private var isShiftPressed = false
    
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
                
            // Virtual Cursor
            if !engine.isMouseVisible, let vPos = engine.virtualCursorPosition {
                ZStack {
                    if engine.currentMode == .eraser {
                        // Eraser: dashed ring showing erase radius
                        Circle()
                            .stroke(Color.secondary.opacity(0.5), style: SwiftUI.StrokeStyle(lineWidth: 1, dash: [3, 3]))
                            .frame(width: engine.eraserRadius * 2, height: engine.eraserRadius * 2)
                    } else {
                        // Pen: tiny solid dot with subtle halo
                        Circle()
                            .fill(engine.penColor.color.opacity(0.15))
                            .frame(width: 12, height: 12)
                    }
                    Circle()
                        .fill((engine.currentMode == .pen ? engine.penColor.color : Color.primary).opacity(0.6))
                        .frame(width: 4, height: 4)
                }
                .position(vPos)
                .allowsHitTesting(false)
            }
            
            // Opaque controls stay readable in both appearances and while drawing.
            GeometryReader { geometry in
                HStack(alignment: .top) {
                    Spacer()
                    DrawingToolbar(engine: engine, isShiftPressed: isShiftPressed)
                        .frame(width: 168, height: min(340, max(100, geometry.size.height - 24)))
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
            if let info = notification.object as? [String: Bool], let isFirstTime = info["isFirstTime"], isFirstTime {
                // Start in mouse mode when window opens for the first time
                engine.isMouseVisible = true
            } else {
                engine.isMouseVisible = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .draftWindowDidHide)) { _ in
            isShiftPressed = false
            engine.cancelStroke()
            // Reset to mouse mode so state is consistent next time the window shows
            engine.isMouseVisible = true
        }
    }
}
