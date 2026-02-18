import AppKit
import SpriteKit

class DemoAppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let rect = NSRect(x: 0, y: 0, width: 1200, height: 800)
        window = NSWindow(contentRect: rect, styleMask: [.titled, .closable, .resizable, .miniaturizable], backing: .buffered, defer: false)
        window.title = "Confetti Demo"
        window.center()
        window.minSize = NSSize(width: 800, height: 540)

        let container = DemoGridView(presets: DemoPreset.all)
        container.translatesAutoresizingMaskIntoConstraints = false
        window.contentView?.addSubview(container)

        if let contentView = window.contentView {
            contentView.wantsLayer = true
            contentView.layer?.backgroundColor = NSColor(red: 0.08, green: 0.08, blue: 0.14, alpha: 1.0).cgColor
            NSLayoutConstraint.activate([
                container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                container.topAnchor.constraint(equalTo: contentView.topAnchor),
                container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}
