import SwiftUI

struct OverlayView: View {
    @ObservedObject var state = AppState.shared

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: state.cornerRadius)
                .fill(Color(hex: state.fillColorHex))
                .opacity(state.fillOpacity)

            RoundedRectangle(cornerRadius: state.cornerRadius)
                .strokeBorder(
                    Color(hex: state.borderColorHex),
                    style: StrokeStyle(
                        lineWidth: CGFloat(state.borderWidth),
                        dash: dashArray
                    )
                )

            if state.showLabel, let pos = state.currentPosition {
                Text(labelText(for: pos))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(6)
            }
        }
    }

    var dashArray: [CGFloat] {
        switch state.borderStyle {
        case 1: return [10, 5] // Dashed
        case 2: return [CGFloat(state.borderWidth), CGFloat(state.borderWidth * 2)] // Dotted
        default: return [] // Solid
        }
    }

    func labelText(for position: OverlayPosition) -> String {
        switch position {
        case .fullscreen: return state.labelText_fullscreen
        case .topLeft: return state.labelText_topLeft
        case .topRight: return state.labelText_topRight
        case .bottomLeft: return state.labelText_bottomLeft
        case .bottomRight: return state.labelText_bottomRight
        }
    }
}

// Helper for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 255, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// We need a helper to safely convert Color to Hex String for saving
extension Color {
    func toHex() -> String {
        let nsColor = NSColor(self).usingColorSpace(.sRGB) ?? NSColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        nsColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    }
}
