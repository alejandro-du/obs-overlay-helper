import SwiftUI
import AppKit
import KeyboardShortcuts

class SettingsWindowManager {
    static let shared = SettingsWindowManager()
    var window: NSWindow?

    func showWindow() {
        if let window = window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "OBS Helper Settings"
        window.contentView = NSHostingView(rootView: SettingsView())
        window.isReleasedWhenClosed = false
        self.window = window

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct OBSOverlayHelperApp: App {
    @StateObject var state = AppState.shared

    init() {
        checkAccessibility(prompt: false)
        OverlayManager.shared.setup()

        KeyboardShortcuts.onKeyDown(for: .hideOverlay) { AppState.shared.hide() }
        KeyboardShortcuts.onKeyDown(for: .hideOverlayAlternate) { AppState.shared.hide() }
        KeyboardShortcuts.onKeyDown(for: .positionFullscreen) { AppState.shared.moveTo(position: .fullscreen) }
        KeyboardShortcuts.onKeyDown(for: .positionTopLeft) { AppState.shared.moveTo(position: .topLeft) }
        KeyboardShortcuts.onKeyDown(for: .positionTopRight) { AppState.shared.moveTo(position: .topRight) }
        KeyboardShortcuts.onKeyDown(for: .positionBottomLeft) { AppState.shared.moveTo(position: .bottomLeft) }
        KeyboardShortcuts.onKeyDown(for: .positionBottomRight) { AppState.shared.moveTo(position: .bottomRight) }
    }

    var body: some Scene {
        MenuBarExtra("OBS Helper", systemImage: "rectangle.dashed") {
            Button("Hide Overlay") {
                state.hide()
            }
            .keyboardShortcut("h", modifiers: [.command, .shift])

            Divider()

            Button("Fullscreen") { state.moveTo(position: .fullscreen) }
            Button("Top Left") { state.moveTo(position: .topLeft) }
            Button("Top Right") { state.moveTo(position: .topRight) }
            Button("Bottom Left") { state.moveTo(position: .bottomLeft) }
            Button("Bottom Right") { state.moveTo(position: .bottomRight) }

            Divider()

            Button("Settings...") {
                SettingsWindowManager.shared.showWindow()
            }
            
            Button("Permissions Check...") {
                checkAccessibility(prompt: true)
            }

            Divider()

            Button("Quit OBS Helper") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }

    func checkAccessibility(prompt: Bool) {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        
        if !trusted && prompt {
            let alert = NSAlert()
            alert.messageText = "Accessibility Access Required"
            alert.informativeText = "OBS Overlay Helper needs Accessibility access to detect global keyboard shortcuts. Please enable it in System Settings > Privacy & Security > Accessibility."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Cancel")
            
            // Force activate the app to show the alert
            NSApp.activate(ignoringOtherApps: true)
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
}
