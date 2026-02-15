import AppKit
import SpriteKit

// MARK: - Entry Point (FR-1, FR-2)

let config = Config.parse()

let app = NSApplication.shared
app.setActivationPolicy(.accessory)  // FR-2: No Dock icon, no menu bar

let delegate = AppDelegate(config: config)
app.delegate = delegate
app.run()
