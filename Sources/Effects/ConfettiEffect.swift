import SpriteKit

// MARK: - Confetti Effect
// Particles launch from bottom-left toward upper-right AND bottom-right toward upper-left,
// reach 70–90 % screen height, then sway and rotate while falling like paper confetti.

final class ConfettiEffect: ParticleEffect {

    // MARK: - Particle model

    private struct Particle {
        let node: SKSpriteNode
        var vx: CGFloat
        var vy: CGFloat
        let targetHeight: CGFloat
        var phase: Phase
        // Sway parameters (used in falling phase)
        let centerX: CGFloat = 0     // set when transitioning
        let swayAmplitude: CGFloat
        let swayFrequency: CGFloat
        let swayPhase: CGFloat
        let rotationSpeed: CGFloat
        let fallSpeed: CGFloat
        let spawnTime: TimeInterval
        var isSpawned: Bool
        var fallElapsed: TimeInterval = 0
        var savedCenterX: CGFloat = 0

        enum Phase { case launching, falling }
    }

    // MARK: - State

    private let config: Config
    private let sceneSize: CGSize
    private var particles: [Particle] = []
    private var startTime: TimeInterval = 0
    private var started = false

    init(config: Config, sceneSize: CGSize) {
        self.config = config
        self.sceneSize = sceneSize
    }

    // MARK: - Setup

    func setup(in scene: SKScene) {
        let textures = config.emojis.map { EmojiTexture.create(emoji: $0) }
        let count = config.density.particleCount
        let spawnWindow = min(1.0, config.duration * 0.3)

        for i in 0..<count {
            let texture = textures[i % textures.count]
            let node = SKSpriteNode(texture: texture)
            node.setScale(CGFloat.random(in: 0.7...1.3))
            node.alpha = 0  // hidden until spawn

            let fromLeft = (i % 2 == 0)
            let startX: CGFloat = fromLeft ? -20 : sceneSize.width + 20
            let startY: CGFloat = CGFloat.random(in: -10...30)
            node.position = CGPoint(x: startX, y: startY)

            let targetH = CGFloat.random(in: 0.5...0.95) * sceneSize.height
            let gravity: CGFloat = 100
            let vyNeeded = sqrt(2 * gravity * targetH)
            let vy = vyNeeded * CGFloat.random(in: 1.30...1.50)
            let vx: CGFloat = fromLeft
                ? CGFloat.random(in: 100...1000)
                : CGFloat.random(in: -1000 ... -100)

            let p = Particle(
                node: node,
                vx: vx,
                vy: vy,
                targetHeight: targetH,
                phase: .launching,
                swayAmplitude: CGFloat.random(in: 50...130),
                swayFrequency: CGFloat.random(in: 2...5),
                swayPhase: CGFloat.random(in: 0 ... .pi * 2),
                rotationSpeed: CGFloat.random(in: -4...4),
                fallSpeed: CGFloat.random(in: 120...280),
                spawnTime: Double.random(in: 0...spawnWindow),
                isSpawned: false
            )

            scene.addChild(node)
            particles.append(p)
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
        let adt = CGFloat(dt) * speed * speedCurve   // adjusted delta time
        let gravity: CGFloat = 100

        for i in particles.indices {
            // Spawn check
            if !particles[i].isSpawned {
                guard elapsed >= particles[i].spawnTime else { continue }
                particles[i].isSpawned = true
                particles[i].node.alpha = 1
            }

            switch particles[i].phase {
            case .launching:
                particles[i].vy -= gravity * adt
                particles[i].node.position.x += particles[i].vx * adt
                particles[i].node.position.y += particles[i].vy * adt

                if particles[i].vy <= 0 || particles[i].node.position.y >= particles[i].targetHeight {
                    particles[i].phase = .falling
                    particles[i].savedCenterX = particles[i].node.position.x
                    particles[i].vy = 0
                    particles[i].fallElapsed = 0
                }

            case .falling:
                particles[i].fallElapsed += Double(adt)
                let t = CGFloat(particles[i].fallElapsed)

                // Sinusoidal sway around center X
                let swayOffset = particles[i].swayAmplitude
                    * sin(t * particles[i].swayFrequency + particles[i].swayPhase)
                particles[i].node.position.x = particles[i].savedCenterX + swayOffset

                // Gentle gravity for falling
                particles[i].vy -= 180 * adt
                particles[i].vy = max(particles[i].vy, -particles[i].fallSpeed)
                particles[i].node.position.y += particles[i].vy * adt

                // Rotation
                particles[i].node.zRotation += particles[i].rotationSpeed * adt
            }

            // Fade out near end
            let fadeStart = config.duration - 0.5
            if elapsed > fadeStart {
                let progress = CGFloat((elapsed - fadeStart) / 0.5)
                particles[i].node.alpha = max(0, 1 - progress)
            }

            // Hide if below screen
            if particles[i].node.position.y < -80 {
                particles[i].node.alpha = 0
            }
        }
    }
}
