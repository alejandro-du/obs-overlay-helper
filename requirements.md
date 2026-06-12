# OBS Overlay Helper — Requirements

## 1. Purpose

OBS Overlay Helper is a lightweight macOS utility that displays a non-interactive, semi-transparent placeholder rectangle on screen whenever the user triggers a keyboard shortcut. The placeholder represents the position and size of the "talking head" camera overlay as it will appear in the final OBS recording. This lets the user know, at a glance, which region of the screen will be obscured by their face cam — without needing to switch to OBS or consult the recorded output.

---

## 2. Background and motivation

The user records screen-capture videos in OBS. A "talking head" camera feed is composited as an overlay in the OBS scene. OBS is configured with keyboard shortcuts to snap this overlay to each of the four screen corners. Because OBS operates on the recorded output rather than the live screen, the user has no visual feedback about where the talking head will land while they are working in other applications. The goal is to mirror each OBS shortcut in this app so that a matching placeholder appears on screen in real time.

---

## 3. Functional requirements

### 3.1 Global shortcut listener

- The app must register one global keyboard shortcut for each overlay position.
- Shortcuts must fire even when the app is not in the foreground and when any other application (including OBS) is the active window.
- The app must support at least five positions by default: top-left, top-right, bottom-left, bottom-right, and fullscreen.
- The user must be able to configure which key combination maps to which position.
- Shortcuts must be identical to the ones the user already has assigned in OBS, so a single key press drives both applications simultaneously.

### 3.2 Overlay window

- When a shortcut is triggered, the app must display a floating, borderless rectangle on screen in the configured position.
- The overlay window must sit above all other application windows at all times (always-on-top behaviour). This includes full-screen applications and presentations (e.g., Keynote slideshows).
- The overlay must be fully click-through: mouse clicks, scrolls, and drags must pass through it to whatever is underneath. The user must never need to dismiss or interact with the overlay directly.
- The overlay must not appear in Mission Control, Exposé, or the app switcher (Cmd+Tab).
- The overlay must not capture focus or change the active application.

### 3.3 Overlay appearance

- The rectangle must have a clearly visible but unobtrusive style: a coloured border with a semi-transparent fill.
- The default appearance is a dashed or solid coloured border (e.g. green) and a fill at low opacity (e.g. 15–25%).
- The overlay may optionally display a short text label inside the rectangle (e.g. "Cam — top left") to confirm which position is active.
- All visual properties (border colour, fill colour, fill opacity, border width, border style, corner radius, label visibility, label text) must be configurable.

### 3.4 Position and size

- The overlay position must match the position of the talking head in OBS exactly. To achieve this, the user must be able to configure the pixel coordinates (x, y) and dimensions (width, height) for each of the four corners independently. Fullscreen naturally bounds to the screen dimensions.
- By default the app must offer reasonable presets assuming the talking head occupies one of four corners of the primary display at a typical size (e.g. 320×180 px for a 1920×1080 canvas).

### 3.5 Hide and transition logic

- A dedicated shortcut must hide the overlay immediately, bypassing any delays or animations.
- Pressing a position shortcut while the overlay is already at that exact position and visible must do nothing (no toggle behaviour).
- Pressing a different position shortcut while the overlay is visible must move it instantly to the new position without any delay or fade-in animation.
- If the overlay is hidden, pressing a position shortcut triggers a configurable delay, followed by a configurable fade-in animation.

### 3.6 Animations & Timing

- The app must support a global configurable delay (in milliseconds). When transitioning from a hidden state, the overlay waits for this delay before appearing.
- The app must support a global configurable fade-in duration (in milliseconds). When appearing, the overlay smoothly transitions its opacity to the final state.
- Hide commands and position-to-position jumps completely skip these timers.

### 3.7 Multiple overlays (optional, future)

- The app should be designed so that more than four overlay presets can be supported in the future (e.g. for scenes with two picture-in-picture zones).
- In the initial version a maximum of four simultaneous overlay rectangles may be displayed at once if the user has multiple active, but the primary use case is one at a time.

---

## 4. Configuration

### 4.1 Configuration surface

- All settings must be accessible from the menu bar icon.
- A settings panel (native macOS preferences window) must allow the user to configure all options without editing a config file.
- Settings must persist across app launches.

### 4.2 Configurable items

| Setting | Description | Default |
|---|---|---|
| Shortcut — fullscreen | Key combination to show full-screen overlay | (user defined) |
| Shortcut — top-left | Key combination to show overlay at top-left | (user defined) |
| Shortcut — top-right | Key combination to show overlay at top-right | (user defined) |
| Shortcut — bottom-left | Key combination to show overlay at bottom-left | (user defined) |
| Shortcut — bottom-right | Key combination to show overlay at bottom-right | (user defined) |
| Hide overlay shortcut | Instantly hide without delay or fade | (user defined) |
| Overlay x, y per position | Pixel offset from the target corner | Corner-aligned |
| Overlay width, height | Dimensions of the rectangle in points | 320 × 180 |
| Border colour | Any colour via system colour picker | Green |
| Fill colour | Any colour via system colour picker | Same as border |
| Fill opacity | 0–100% | 20% |
| Border width | 1–10 pt | 3 pt |
| Border style | Solid / dashed / dotted | Dashed |
| Corner radius | 0–500 pt | 0 pt |
| Delay | Delay before showing overlay from hidden | 0 ms |
| Fade-in duration | Animation duration for appearing overlay | 0 ms |
| Show label | Display position name inside the rectangle | Off |
| Label text (per position) | Custom text per overlay position | "Cam — [position]" |
| Target display | Which display to place overlays on (if multi-monitor) | Primary display |
| Launch at login | Start app automatically on login | Off |

---

## 5. Menu bar presence

- The app must run as a menu bar utility with no Dock icon by default.
- The menu bar icon should be simple and monochrome (system icon or a custom template image that respects Dark Mode).
- The menu bar menu must include: a "Hide Overlay" item, the five position shortcuts, a separator, Settings…, and Quit.
- An option to show a Dock icon must be available in Settings for users who prefer it.

---

## 6. Display and multi-monitor support

- The user must be able to choose which display the overlay appears on.
- When the option "follow cursor" is enabled, the overlay appears on whatever display the mouse cursor was last on when the shortcut fired.
- Overlay coordinates must be expressed relative to the chosen display's coordinate space, not the global display space.
- The app must handle display configuration changes (connecting or disconnecting a monitor) gracefully: if the target display is no longer available, fall back to the primary display.

---

## 7. Non-functional requirements

### 7.1 Performance

- The app must have negligible CPU and memory footprint when idle (menu bar only, no overlay visible).
- Overlay logic must respond within 50 ms of the shortcut being registered by the system.

### 7.2 Compatibility

- macOS 13 Ventura or later.
- Support for Apple Silicon (arm64) and Intel (x86_64) as a universal binary.
- Must not require disabling System Integrity Protection (SIP).

### 7.3 Permissions

- The app requires Accessibility permission (to register global keyboard shortcuts).
- The app must prompt the user clearly if the required permissions are not granted and guide them to System Settings > Privacy & Security > Accessibility.
- No network access is required. The app must not make any outbound network calls.

### 7.4 Reliability

- Shortcut registration must survive the system sleep/wake cycle and display sleep without requiring the app to be relaunched.
- The overlay window must survive Spaces switching and full-screen app transitions — it must remain visible (if active) when the user switches Spaces.

---

## 8. Technology stack (recommended)

The following stack is recommended for a minimal, native macOS implementation:

- **Swift + SwiftUI** for the settings panel and menu bar extra
- **AppKit (NSWindow, NSPanel)** for the overlay window, using `NSPanel` with `NSWindowStyleMask.nonactivatingPanel`, a `collectionBehavior` of `.canJoinAllSpaces` and `.stationary`, and a window level of `CGWindowLevelForKey(.maximumWindow)` to achieve absolute always-on-top, click-through behaviour even over full-screen apps.
- **KeyboardShortcuts** swift package for global shortcut detection
- **UserDefaults** or a plist for persisting settings

An alternative approach using an Electron or Tauri wrapper is possible but adds unnecessary overhead for what is essentially a small system utility.

---

## 9. Out of scope (v1)

The following items are explicitly excluded from the first version:

- Any two-way communication with OBS (no OBS WebSocket integration; the app simply listens for the same key presses).
- Overlays that automatically detect or read OBS scene layouts.
- Overlays with any interactive controls (resize handles, drag-to-reposition).
- Recording or streaming functionality of any kind.
- Support for Windows or Linux.
