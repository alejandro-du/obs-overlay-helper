import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @ObservedObject var state = AppState.shared

    var body: some View {
        TabView {
            shortcutsTab
                .tabItem { Label("Shortcuts", systemImage: "keyboard") }
            appearanceTab
                .tabItem { Label("Appearance", systemImage: "paintpalette") }
            layoutTab
                .tabItem { Label("Layout", systemImage: "uiwindow.split.2x1") }
        }
        .padding(20)
        .frame(width: 500, height: 450)
    }

    var shortcutsTab: some View {
        Form {
            Section {
                KeyboardShortcuts.Recorder("Fullscreen", name: .positionFullscreen)
                KeyboardShortcuts.Recorder("Top Left", name: .positionTopLeft)
                KeyboardShortcuts.Recorder("Top Right", name: .positionTopRight)
                KeyboardShortcuts.Recorder("Bottom Left", name: .positionBottomLeft)
                KeyboardShortcuts.Recorder("Bottom Right", name: .positionBottomRight)
            } header: { Text("Positions") }

            Section {
                KeyboardShortcuts.Recorder("Hide Overlay", name: .hideOverlay)
            } header: { Text("Hide Shortcut") }
        }
        .padding()
    }

    var appearanceTab: some View {
        Form {
            Section {
                ColorPicker("Border Color", selection: Binding(get: { Color(hex: state.borderColorHex) }, set: { state.borderColorHex = $0.toHex() }))
                ColorPicker("Fill Color", selection: Binding(get: { Color(hex: state.fillColorHex) }, set: { state.fillColorHex = $0.toHex() }))

                Slider(value: $state.fillOpacity, in: 0...1) {
                    Text("Fill Opacity")
                }
            } header: { Text("Colors") }

            Section {
                Stepper(value: $state.borderWidth, in: 1...10) {
                    Text("Border Width: \(Int(state.borderWidth)) pt")
                }

                Picker("Border Style", selection: $state.borderStyle) {
                    Text("Solid").tag(0)
                    Text("Dashed").tag(1)
                    Text("Dotted").tag(2)
                }
                
                Slider(value: $state.cornerRadius, in: 0...500) {
                    Text("Corner Radius: \(Int(state.cornerRadius)) pt")
                }
            } header: { Text("Border") }

            Section {
                Toggle("Show Label", isOn: $state.showLabel)
            } header: { Text("Labels") }
            
            Section {
                Slider(value: $state.delayMs, in: 0...5000) {
                    Text("Delay: \(Int(state.delayMs)) ms")
                }
                Slider(value: $state.fadeInDurationMs, in: 0...2000) {
                    Text("Fade-in Duration: \(Int(state.fadeInDurationMs)) ms")
                }
            } header: { Text("Animation") }
        }
        .padding()
    }

    var layoutTab: some View {
        Form {
            Section {
                Picker("Target Display", selection: $state.targetDisplayName) {
                    Text("Default (Primary)").tag("")
                    ForEach(NSScreen.screens, id: \.localizedName) { screen in
                        Text(screen.localizedName).tag(screen.localizedName)
                    }
                }
            } header: { Text("Display") }

            Section {
                HStack {
                    Text("Width:")
                    TextField("Width", value: $state.overlayWidth, format: .number)
                        .frame(width: 80)
                    Text("Height:")
                    TextField("Height", value: $state.overlayHeight, format: .number)
                        .frame(width: 80)
                }
            } header: { Text("Base Size") }

            Section {
                HStack {
                    Text("X:")
                    TextField("X", value: $state.offsetX_topLeft, format: .number).frame(width: 60)
                    Text("Y:")
                    TextField("Y", value: $state.offsetY_topLeft, format: .number).frame(width: 60)
                }
            } header: { Text("Offset: Top Left") }

            Section {
                HStack {
                    Text("X:")
                    TextField("X", value: $state.offsetX_topRight, format: .number).frame(width: 60)
                    Text("Y:")
                    TextField("Y", value: $state.offsetY_topRight, format: .number).frame(width: 60)
                }
            } header: { Text("Offset: Top Right") }

            Section {
                HStack {
                    Text("X:")
                    TextField("X", value: $state.offsetX_bottomLeft, format: .number).frame(width: 60)
                    Text("Y:")
                    TextField("Y", value: $state.offsetY_bottomLeft, format: .number).frame(width: 60)
                }
            } header: { Text("Offset: Bottom Left") }

            Section {
                HStack {
                    Text("X:")
                    TextField("X", value: $state.offsetX_bottomRight, format: .number).frame(width: 60)
                    Text("Y:")
                    TextField("Y", value: $state.offsetY_bottomRight, format: .number).frame(width: 60)
                }
            } header: { Text("Offset: Bottom Right") }
        }
        .padding()
        .frame(height: 550) // Adjust height to prevent scrolling with new section
    }
}
