import AppKit

let app = NSApplication.shared
app.setActivationPolicy(.regular)

let delegate = DemoAppDelegate()
app.delegate = delegate
app.run()
