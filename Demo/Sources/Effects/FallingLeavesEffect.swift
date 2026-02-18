import SpriteKit

// MARK: - Falling Leaves Effect
// Particles drift down from the top of the screen with gentle swaying and rotation,
// simulating leaves falling in autumn.

final class FallingLeavesEffect: ParticleEffect {

    // MARK: - Particle model

    private struct Leaf {
        let node: SKSpriteNode
        let swayAmplitude: CGFloat
        let swayFrequency: CGFloat
        let swayPhase: CGFloat
        let rotationSpeed: CGFloat
        let fallSpeed: CGFloat
        let spawnTime: TimeInterval
        var centerX: CGFloat
        var isSpawned: Bool = false
        var elapsed: TimeInterval = 0
    }

    // MARK: - State

    private let config: Config
    private let sceneSize: CGSize
    private var leaves: [Leaf] = []
    private var startTime: TimeInterval = 0
    private var started = false

    init(config: Config, sceneSize: CGSize) {
        self.config = config
        self.sceneSize = sceneSize
    }

    // MARK: - Setup

    func setup(in scene: SKScene) {
        let textures = config.emojis.map { EmojiTexture.create(emoji: $0, size: 40) }
        let count = config.density.particleCount
        let spawnWindow = config.duration * 0.5

        for i in 0..<count {
            let texture = textures[i % textures.count]
            let node = SKSpriteNode(texture: texture)
            node.setScale(CGFloat.random(in: 0.7...1.3))
            node.alpha = 0

            let startX = CGFloat.random(in: 0...sceneSize.width)
            let startY = sceneSize.height + CGFloat.random(in: 20...80)
            node.position = CGPoint(x: startX, y: startY)

            let leaf = Leaf(
                node: node,
                swayAmplitude: CGFloat.random(in: 60...160),
                swayFrequency: CGFloat.random(in: 1...3),
                swayPhase: CGFloat.random(in: 0 ... .pi * 2),
                rotationSpeed: CGFloat.random(in: -2...2),
                fallSpeed: CGFloat.random(in: 80...200),
                spawnTime: Double.random(in: 0...spawnWindow),
                centerX: startX
            )

            scene.addChild(node)
            leaves.append(leaf)
        }
    }

    // MARK: - Update

    func update(currentTime: TimeInterval, deltaTime dt: TimeInterval) {
        if !started { startTime = currentTime; started = true }
        let elapsed = currentTime - startTime
        let speed = CGFloat(config.speed)

        // FR-8: easing-based speed curve
        let progress = min(1.0, CGFloat(elapsed) / CGFloat(config.duration))
        let speedCurve = config.easing.speedMultiplier(at: progress, exponent: CGFloat(config.easingExponent))
        let adt = CGFloat(dt) * speed * speedCurve

        for i in leaves.indices {
            if !leaves[i].isSpawned {
                guard elapsed >= leaves[i].spawnTime else { continue }
                leaves[i].isSpawned = true
                leaves[i].node.alpha = 1
            }

            leaves[i].elapsed += Double(adt)
            let t = CGFloat(leaves[i].elapsed)

            // Sinusoidal sway
            let swayOffset = leaves[i].swayAmplitude
                * sin(t * leaves[i].swayFrequency + leaves[i].swayPhase)
            leaves[i].node.position.x = leaves[i].centerX + swayOffset

            // Gentle drift of center to simulate wind
            leaves[i].centerX += CGFloat.random(in: -0.3...0.3) * speed

            // Fall
            leaves[i].node.position.y -= leaves[i].fallSpeed * adt

            // Rotation
            leaves[i].node.zRotation += leaves[i].rotationSpeed * adt

            // Fade out near end
            let fadeStart = config.duration - 0.5
            if elapsed > fadeStart {
                let progress = CGFloat((elapsed - fadeStart) / 0.5)
                leaves[i].node.alpha = max(0, 1 - progress)
            }

            // Hide below screen
            if leaves[i].node.position.y < -80 {
                leaves[i].node.alpha = 0
            }
        }
    }
}
