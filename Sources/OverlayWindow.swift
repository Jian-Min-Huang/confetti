import AppKit

// MARK: - Transparent Click-Through Overlay Window (FR-3, FR-4)

class OverlayWindow: NSWindow {

    init(for screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        self.isOpaque = false                              // Transparent
        self.backgroundColor = .clear                      // Clear background
        self.hasShadow = false                             // No shadow
        self.level = .screenSaver                          // FR-3: Above all windows
        self.ignoresMouseEvents = true                     // FR-4: Click-through
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isReleasedWhenClosed = false
    }

    // Allow the window to become key for keyboard events (FR-19: Esc)
    override var canBecomeKey: Bool { true }
}
