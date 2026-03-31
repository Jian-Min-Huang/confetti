import AppKit
import SpriteKit

// MARK: - App Delegate (FR-5, FR-18, FR-19)

class AppDelegate: NSObject, NSApplicationDelegate {

    let config: Config
    private var windows: [NSWindow] = []

    init(config: Config) {
        self.config = config
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // FR-5: Create overlay window for each screen
        var pendingScenes = NSScreen.screens.count
        for screen in NSScreen.screens {
            let window = OverlayWindow(for: screen)

            let skView = SKView(frame: NSRect(origin: .zero, size: screen.frame.size))
            skView.allowsTransparency = true
            skView.wantsLayer = true
            window.contentView = skView

            let scene = ParticleScene(size: screen.frame.size, config: config)
            scene.scaleMode = .resizeFill

            // Reveal windows only after all scenes complete their first render (Bug #1)
            scene.onFirstFrameRendered = { [weak self] in
                pendingScenes -= 1
                if pendingScenes == 0 {
                    self?.windows.forEach { $0.alphaValue = 1 }
                }
            }

            skView.presentScene(scene)

            window.alphaValue = 0          // Start hidden to avoid initial flash
            window.orderFrontRegardless()
            windows.append(window)
        }

        // Activate to receive keyboard events
        NSApp.activate(ignoringOtherApps: true)

        // FR-19: Esc key to quit
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 {  // Esc
                NSApp.terminate(nil)
                return nil
            }
            return event
        }

        // FR-18: Auto-terminate after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + config.duration + 0.5) {
            NSApp.terminate(nil)
        }
    }
}
