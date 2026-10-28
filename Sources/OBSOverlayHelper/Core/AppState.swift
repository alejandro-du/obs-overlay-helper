import SwiftUI
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let positionFullscreen = Self("positionFullscreen")
    static let hideOverlay = Self("hideOverlay")
    static let hideOverlayAlternate = Self("hideOverlayAlternate")
    static let positionTopLeft = Self("positionTopLeft")
    static let positionTopRight = Self("positionTopRight")
    static let positionBottomLeft = Self("positionBottomLeft")
    static let positionBottomRight = Self("positionBottomRight")
}

enum OverlayPosition: String, CaseIterable, Identifiable {
    case fullscreen = "Fullscreen"
    case topLeft = "Top Left"
    case topRight = "Top Right"
    case bottomLeft = "Bottom Left"
    case bottomRight = "Bottom Right"
    var id: String { rawValue }
}

class AppState: ObservableObject {
    static let shared = AppState()

    @AppStorage("overlayWidth") var overlayWidth: Double = 320 { didSet { objectWillChange.send() } }
    @AppStorage("overlayHeight") var overlayHeight: Double = 180 { didSet { objectWillChange.send() } }

    // Offsets
    @AppStorage("offsetX_topLeft") var offsetX_topLeft: Double = 0 { didSet { objectWillChange.send() } }
    @AppStorage("offsetY_topLeft") var offsetY_topLeft: Double = 0 { didSet { objectWillChange.send() } }
    
    @AppStorage("offsetX_topRight") var offsetX_topRight: Double = 0 { didSet { objectWillChange.send() } }
    @AppStorage("offsetY_topRight") var offsetY_topRight: Double = 0 { didSet { objectWillChange.send() } }
    
    @AppStorage("offsetX_bottomLeft") var offsetX_bottomLeft: Double = 0 { didSet { objectWillChange.send() } }
    @AppStorage("offsetY_bottomLeft") var offsetY_bottomLeft: Double = 0 { didSet { objectWillChange.send() } }
    
    @AppStorage("offsetX_bottomRight") var offsetX_bottomRight: Double = 0 { didSet { objectWillChange.send() } }
    @AppStorage("offsetY_bottomRight") var offsetY_bottomRight: Double = 0 { didSet { objectWillChange.send() } }

    // Appearance
    @AppStorage("borderColorHex") var borderColorHex: String = "#00FF00"
    @AppStorage("fillColorHex") var fillColorHex: String = "#00FF00"
    @AppStorage("fillOpacity") var fillOpacity: Double = 0.2 { didSet { objectWillChange.send() } }
    @AppStorage("fadeInDurationMs") var fadeInDurationMs: Double = 0.0 { didSet { objectWillChange.send() } }
    @AppStorage("delayMs") var delayMs: Double = 0.0 { didSet { objectWillChange.send() } }
    @AppStorage("borderWidth") var borderWidth: Double = 3.0 { didSet { objectWillChange.send() } }
    @AppStorage("borderStyle") var borderStyle: Int = 1 { didSet { objectWillChange.send() } } // 0: Solid, 1: Dashed, 2: Dotted
    @AppStorage("showLabel") var showLabel: Bool = true { didSet { objectWillChange.send() } }
    @AppStorage("cornerRadius") var cornerRadius: Double = 0.0 { didSet { objectWillChange.send() } } // Added corner radius
    @AppStorage("targetDisplayName") var targetDisplayName: String = "" { didSet { objectWillChange.send() } } // Added display target
    
    // Labels
    @AppStorage("labelText_fullscreen") var labelText_fullscreen: String = "Cam — Fullscreen" { didSet { objectWillChange.send() } }
    @AppStorage("labelText_topLeft") var labelText_topLeft: String = "Cam — Top Left" { didSet { objectWillChange.send() } }
    @AppStorage("labelText_topRight") var labelText_topRight: String = "Cam — Top Right" { didSet { objectWillChange.send() } }
    @AppStorage("labelText_bottomLeft") var labelText_bottomLeft: String = "Cam — Bottom Left" { didSet { objectWillChange.send() } }
    @AppStorage("labelText_bottomRight") var labelText_bottomRight: String = "Cam — Bottom Right" { didSet { objectWillChange.send() } }

    // Runtime state (Not persisted)
    @Published var isVisible: Bool = false
    @Published var currentPosition: OverlayPosition? = nil
    var skipNextFade: Bool = false // Tracks if the next appearance should skip the fade

    func hide() {
        skipNextFade = true
        isVisible = false
    }

    func moveTo(position: OverlayPosition) {
        if currentPosition == position && isVisible {
            // Already at this position and visible. Do nothing.
            return
        } else {
            // Always fade and delay when moving to a new position, 
            // even if already visible (since we want it to hide and wait)
            skipNextFade = false
            currentPosition = position
            
            if isVisible {
                // If it's already visible, temporarily hide it to trigger the flow again
                isVisible = false
                // Use a tiny delay to allow the Combine sink to process the "hide" 
                // before we trigger the "show" with the delay.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.isVisible = true
                }
            } else {
                isVisible = true
            }
        }
    }
}
