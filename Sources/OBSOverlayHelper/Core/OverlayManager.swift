import AppKit
import SwiftUI
import Combine

class OverlayManager {
    static let shared = OverlayManager()
    private var panel: NSPanel?
    private var cancellables = Set<AnyCancellable>()

    private var delayWorkItem: DispatchWorkItem?

    func setup() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )

        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.alphaValue = 0.0 // Start invisible

        let contentView = NSHostingView(rootView: OverlayView())
        panel.contentView = contentView

        self.panel = panel

        // Observe State Changes
        AppState.shared.$isVisible.sink { [weak self] visible in
            let state = AppState.shared
            
            // Cancel any pending show operations
            self?.delayWorkItem?.cancel()
            self?.delayWorkItem = nil
            
            if visible {
                let delay = state.skipNextFade ? 0 : state.delayMs / 1000.0
                
                if delay > 0 {
                    self?.panel?.alphaValue = 0.0 // Ensure it's fully invisible during delay
                    let workItem = DispatchWorkItem { [weak self] in
                        self?.showPanel()
                        self?.delayWorkItem = nil
                    }
                    self?.delayWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
                } else {
                    self?.showPanel()
                }
            } else {
                self?.panel?.orderOut(nil)
                self?.panel?.alphaValue = 0.0 // Keep invisible
            }
        }.store(in: &cancellables)

        AppState.shared.$currentPosition.sink { [weak self] _ in
            // Only update frame if visible, otherwise handled during showPanel
            if AppState.shared.isVisible && self?.delayWorkItem == nil {
               self?.updateFrame()
            }
        }.store(in: &cancellables)
        
        // Observe configuration changes that affect frame
        let state = AppState.shared
        state.objectWillChange
            .throttle(for: 0.1, scheduler: RunLoop.main, latest: true)
            .sink { [weak self] _ in
                // Defer to next runloop so values are updated
                DispatchQueue.main.async {
                    if AppState.shared.isVisible && self?.delayWorkItem == nil {
                        self?.updateFrame()
                    }
                }
            }
            .store(in: &cancellables)

        // Observe screen changes to update position if monitors change
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification).sink { [weak self] _ in
            self?.updateFrame()
        }.store(in: &cancellables)
    }

    private func showPanel() {
        self.updateFrame()
        let state = AppState.shared
        let duration = state.fadeInDurationMs / 1000.0
        
        if duration > 0 && !state.skipNextFade {
            self.panel?.alphaValue = 0.0
            self.panel?.orderFront(nil)
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = duration
                self.panel?.animator().alphaValue = 1.0
            }, completionHandler: nil)
        } else {
            self.panel?.alphaValue = 1.0
            self.panel?.orderFront(nil)
        }
    }

    func updateFrame() {
        guard let panel = panel, let pos = AppState.shared.currentPosition else { return }

        let state = AppState.shared
        
        var targetScreen = NSScreen.screens.first
        if !state.targetDisplayName.isEmpty {
            if let matchedScreen = NSScreen.screens.first(where: { $0.localizedName == state.targetDisplayName }) {
                targetScreen = matchedScreen
            }
        }
        guard let screen = targetScreen else { return }
        
        var w = state.overlayWidth
        var h = state.overlayHeight

        var x: CGFloat = 0
        var y: CGFloat = 0

        // AppKit coordinates: (0,0) is bottom-left of the main screen
        let screenRect = screen.frame

        switch pos {
        case .fullscreen:
            w = Double(screenRect.width)
            h = Double(screenRect.height)
            x = screenRect.minX
            y = screenRect.minY
        case .topLeft:
            x = screenRect.minX + CGFloat(state.offsetX_topLeft)
            y = screenRect.maxY - CGFloat(h) - CGFloat(state.offsetY_topLeft)
        case .topRight:
            x = screenRect.maxX - CGFloat(w) - CGFloat(state.offsetX_topRight)
            y = screenRect.maxY - CGFloat(h) - CGFloat(state.offsetY_topRight)
        case .bottomLeft:
            x = screenRect.minX + CGFloat(state.offsetX_bottomLeft)
            y = screenRect.minY + CGFloat(state.offsetY_bottomLeft)
        case .bottomRight:
            x = screenRect.maxX - CGFloat(w) - CGFloat(state.offsetX_bottomRight)
            y = screenRect.minY + CGFloat(state.offsetY_bottomRight)
        }

        let newRect = NSRect(x: x, y: y, width: w, height: h)
        panel.setFrame(newRect, display: true)
    }
}
