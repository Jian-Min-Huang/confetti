import SpriteKit

// MARK: - Fireworks Effect
// 3–5 rockets per screen launch from the bottom, rise to 70–90 % height,
// then explode radially. Rockets are staggered with random intervals.

final class FireworksEffect: ParticleEffect {

    // MARK: - Models

    private struct Rocket {
        let node: SKSpriteNode
        var vy: CGFloat
        let targetHeight: CGFloat
        let launchTime: TimeInterval
        let startX: CGFloat
        var isLaunched: Bool = false
        var hasExploded: Bool = false
    }

    private struct Spark {
        let node: SKSpriteNode
        var vx: CGFloat
        var vy: CGFloat
        let birthTime: TimeInterval
        let lifetime: TimeInterval
    }

    // MARK: - State

    private let config: Config
    private let sceneSize: CGSize
    private var rockets: [Rocket] = []
    private var sparks: [Spark] = []
    private var startTime: TimeInterval = 0
    private var started = false

    init(config: Config, sceneSize: CGSize) {
        self.config = config
        self.sceneSize = sceneSize
    }

    // MARK: - Setup

    func setup(in scene: SKScene) {
        let rocketCount = Int.random(in: 3...5)
        let rocketTexture = EmojiTexture.create(emoji: config.emojis[0], size: 32)

        // Stagger launches over first 60 % of duration
        let launchWindow = config.duration * 0.6
        // Spread X positions evenly with jitter to avoid overlap
        let segmentWidth = sceneSize.width / CGFloat(rocketCount + 1)

        for i in 0..<rocketCount {
            let node = SKSpriteNode(texture: rocketTexture)
            node.setScale(CGFloat.random(in: 0.8...1.1))
            node.alpha = 0

            let baseX = segmentWidth * CGFloat(i + 1)
            let startX = baseX + CGFloat.random(in: -segmentWidth * 0.25 ... segmentWidth * 0.25)
            node.position = CGPoint(x: startX, y: -20)

            let targetH = CGFloat.random(in: 0.7...0.9) * sceneSize.height

            let rocket = Rocket(
                node: node,
                vy: CGFloat.random(in: 700...1000),
                targetHeight: targetH,
                launchTime: Double(i) / Double(rocketCount) * launchWindow
                    + Double.random(in: 0...launchWindow * 0.15),
                startX: startX
            )

            scene.addChild(node)
            rockets.append(rocket)
        }
    }

    // MARK: - Update

    func update(currentTime: TimeInterval, deltaTime dt: TimeInterval) {
        if !started { startTime = currentTime; started = true }
        let elapsed = currentTime - startTime
        let speed = CGFloat(config.speed)
        let adt = CGFloat(dt) * speed

        // --- Rockets ---
        for i in rockets.indices {
            if rockets[i].hasExploded { continue }

            // Launch check
            if !rockets[i].isLaunched {
                guard elapsed >= rockets[i].launchTime else { continue }
                rockets[i].isLaunched = true
                rockets[i].node.alpha = 1
            }

            // Rise
            rockets[i].node.position.y += rockets[i].vy * adt

            // Slight deceleration
            rockets[i].vy -= 100 * adt

            // Explode when reaching target height
            if rockets[i].node.position.y >= rockets[i].targetHeight {
                explode(rocket: rockets[i], at: currentTime, in: rockets[i].node.scene!)
                rockets[i].hasExploded = true
                rockets[i].node.removeFromParent()
            }
        }

        // --- Sparks ---
        let gravity: CGFloat = 300
        for i in sparks.indices.reversed() {
            let age = CGFloat(currentTime - sparks[i].birthTime) * speed
            let lifetime = CGFloat(sparks[i].lifetime)

            sparks[i].vy -= gravity * adt
            sparks[i].node.position.x += sparks[i].vx * adt
            sparks[i].node.position.y += sparks[i].vy * adt

            // Decelerate horizontally (air drag)
            sparks[i].vx *= (1.0 - 1.5 * adt)

            // Fade based on age
            let lifeRatio = age / lifetime
            sparks[i].node.alpha = max(0, 1 - lifeRatio)

            // Remove dead sparks
            if lifeRatio >= 1.0 || sparks[i].node.position.y < -80 {
                sparks[i].node.removeFromParent()
                sparks.remove(at: i)
            }
        }

        // Global fade near end
        let fadeStart = config.duration - 0.5
        if elapsed > fadeStart {
            let progress = CGFloat((elapsed - fadeStart) / 0.5)
            let alpha = max(CGFloat(0), 1 - progress)
            for r in rockets where !r.hasExploded { r.node.alpha = min(r.node.alpha, alpha) }
            for s in sparks { s.node.alpha = min(s.node.alpha, alpha) }
        }
    }

    // MARK: - Explosion

    private func explode(rocket: Rocket, at time: TimeInterval, in scene: SKScene) {
        let sparkCount = config.density.particleCount / 3
        let textures = config.emojis.map { EmojiTexture.create(emoji: $0, size: 28) }
        let center = rocket.node.position

        for j in 0..<sparkCount {
            let texture = textures[j % textures.count]
            let node = SKSpriteNode(texture: texture)
            node.setScale(CGFloat.random(in: 0.6...1.0))
            node.position = center
            node.zRotation = CGFloat.random(in: 0 ... .pi * 2)

            let angle = CGFloat.random(in: 0 ... .pi * 2)
            let speed = CGFloat.random(in: 200...550)

            let spark = Spark(
                node: node,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed,
                birthTime: time,
                lifetime: Double.random(in: 1.0...2.5)
            )

            scene.addChild(node)
            sparks.append(spark)
        }
    }
}
