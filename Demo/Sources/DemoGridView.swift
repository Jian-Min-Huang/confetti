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
        let cols = 2
        let rows = 4

        let totalWidth = bounds.width - padding * CGFloat(cols + 1)
        let panelWidth = totalWidth / CGFloat(cols)
        let rowHeight = (bounds.height - padding * CGFloat(rows + 1)) / CGFloat(rows)

        // 2 columns × 4 rows grid
        for row in 0..<rows {
            for col in 0..<cols {
                let index = row * cols + col
                guard index < panels.count else { continue }
                let x = padding + CGFloat(col) * (panelWidth + padding)
                let y = bounds.height - padding - CGFloat(row + 1) * (rowHeight + padding) + padding
                let frame = NSRect(x: x, y: y, width: panelWidth, height: rowHeight)
                layoutPanel(at: index, frame: frame, labelHeight: labelHeight)
            }
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
