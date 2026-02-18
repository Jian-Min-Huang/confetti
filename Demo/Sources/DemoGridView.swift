import AppKit
import SpriteKit

class DemoGridView: NSView {
    private let presets: [DemoPreset]
    private var panels: [(container: NSView, skView: SKView, label: NSTextField, config: Config)] = []
    private var lastLayoutSize: CGSize = .zero

    init(presets: [DemoPreset]) {
        self.presets = presets
        super.init(frame: .zero)
        setupPanels()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func setupPanels() {
        for preset in presets {
            let container = NSView()
            container.wantsLayer = true
            container.layer?.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.18, alpha: 1.0).cgColor
            container.layer?.cornerRadius = 8
            container.layer?.masksToBounds = true

            let skView = SKView()
            skView.allowsTransparency = false

            let label = NSTextField(labelWithString: preset.title)
            label.font = NSFont.systemFont(ofSize: 13, weight: .medium)
            label.textColor = .white
            label.alignment = .center
            label.backgroundColor = .clear

            container.addSubview(skView)
            container.addSubview(label)
            addSubview(container)

            panels.append((container: container, skView: skView, label: label, config: preset.config))
        }
    }

    override func layout() {
        super.layout()

        let bounds = self.bounds
        guard bounds.width > 0 && bounds.height > 0 else { return }

        let padding: CGFloat = 12
        let labelHeight: CGFloat = 28
        let topCount = 4
        let bottomCount = 3

        let totalWidth = bounds.width - padding * CGFloat(topCount + 1)
        let panelWidth = totalWidth / CGFloat(topCount)
        let rowHeight = (bounds.height - padding * 3) / 2.0

        // Top row: 4 panels
        for i in 0..<topCount {
            let x = padding + CGFloat(i) * (panelWidth + padding)
            let y = bounds.height - padding - rowHeight
            let frame = NSRect(x: x, y: y, width: panelWidth, height: rowHeight)
            layoutPanel(at: i, frame: frame, labelHeight: labelHeight)
        }

        // Bottom row: 3 panels centered
        let bottomTotalWidth = CGFloat(bottomCount) * panelWidth + CGFloat(bottomCount - 1) * padding
        let bottomStartX = (bounds.width - bottomTotalWidth) / 2.0
        for i in 0..<bottomCount {
            let x = bottomStartX + CGFloat(i) * (panelWidth + padding)
            let y = padding
            let frame = NSRect(x: x, y: y, width: panelWidth, height: rowHeight)
            layoutPanel(at: topCount + i, frame: frame, labelHeight: labelHeight)
        }

        // Re-present scenes if size changed significantly
        let sizeChanged = abs(bounds.width - lastLayoutSize.width) > 1 || abs(bounds.height - lastLayoutSize.height) > 1
        if sizeChanged {
            lastLayoutSize = bounds.size
            presentScenes()
        }
    }

    private func layoutPanel(at index: Int, frame: NSRect, labelHeight: CGFloat) {
        guard index < panels.count else { return }
        let panel = panels[index]

        panel.container.frame = frame

        let skFrame = NSRect(x: 0, y: labelHeight, width: frame.width, height: frame.height - labelHeight)
        panel.skView.frame = skFrame

        let labelFrame = NSRect(x: 0, y: 0, width: frame.width, height: labelHeight)
        panel.label.frame = labelFrame
    }

    private func presentScenes() {
        for panel in panels {
            let sceneSize = panel.skView.bounds.size
            guard sceneSize.width > 0 && sceneSize.height > 0 else { continue }

            let scene = ParticleScene(size: sceneSize, config: panel.config)
            scene.scaleMode = .resizeFill
            panel.skView.presentScene(scene)
        }
    }
}
