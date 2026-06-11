# OBS Overlay Helper

A lightweight macOS menu-bar utility that displays a non-interactive, semi-transparent placeholder rectangle on your screen whenever you trigger a keyboard shortcut.

## Why does this exist?
When recording screen-capture videos using OBS, you might have a "talking head" camera feed composited as an overlay. Because OBS operates on the recorded output rather than the live screen, you have no visual feedback about where your camera feed will land while you are working in other applications.

**OBS Overlay Helper** mirrors your OBS shortcuts so that a matching placeholder appears on your screen in real time. This lets you know exactly which region of your screen is obscured by your face cam, without ever needing to switch back to OBS.

## Features

* **Global Keyboard Shortcuts**: Map your existing OBS scene-switching shortcuts to trigger the overlay instantly from any app.
* **5 Configurable Positions**: Support for Top-Left, Top-Right, Bottom-Left, Bottom-Right, and a Fullscreen view.
* **Completely Unobtrusive**: The overlay is fully click-through. Mouse clicks, scrolls, and drags pass right through it. It never steals window focus.
* **Highly Customizable Appearance**: Configure border color, fill color, opacity, border width, border style (solid, dashed, dotted), and corner radius.
* **Precision Layout**: Set exact Width and Height dimensions, and fine-tune the X/Y pixel offsets so it aligns perfectly with your OBS layout.
* **Animations & Timing**: Optionally configure a global appearance delay and a fade-in duration.
* **Menu Bar Only**: Runs silently in the background with no Dock icon.

## Installation / Building from Source

This app is built as a Swift Package with a custom shell script that packages it into a native macOS `.app` bundle.

### Prerequisites
* macOS 13.0 (Ventura) or later
* Swift toolchain (comes with Xcode or Xcode Command Line Tools)

### Build Instructions
1. Clone this repository.
2. Open your terminal and navigate to the project directory.
3. Make the build script executable and run it:
   ```bash
   chmod +x build.sh
   ./build.sh
   ```
4. The script will compile the code and generate an `OBSOverlayHelper.app` file in the same directory.
5. Move `OBSOverlayHelper.app` to your `/Applications` folder, and double-click to run it!

## Permissions (Important!)

Because this app listens for global keyboard shortcuts even when it is not the active window, macOS requires you to grant it **Accessibility** permissions.

1. Launch the app.
2. Click the app's icon in the macOS menu bar.
3. Click **Permissions Check...**
4. Follow the prompt to open **System Settings > Privacy & Security > Accessibility**.
5. Enable the toggle next to **OBS Helper**.

## Usage

1. Click the `OBS Helper` icon (a dashed rectangle) in your macOS menu bar.
2. Click **Settings...** to open the preferences window.
3. Under the **Shortcuts** tab, bind your keys to match your OBS shortcuts.
4. Under the **Layout** tab, adjust the dimensions and offsets.
5. Under the **Appearance** tab, style the overlay to your liking and configure any desired delays or fade effects.

## Dependencies

* [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) by Sindre Sorhus (Handles global hotkey registration securely and natively).

## License

Licensed under the [Apache License, Version 2.0](LICENSE).
