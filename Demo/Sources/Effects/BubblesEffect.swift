import SpriteKit

// MARK: - Bubbles Effect
// Bubbles rise from the bottom of the screen with a gentle sine-wave sway,
// simulating an aquarium-like atmosphere. Each bubble pops (scale up + fade)
// when it reaches the upper portion of the screen.

final class BubblesEffect: ParticleEffect {

    // MARK: - Particle model

    private struct Particle {
        let node: SKSpriteNode
        let baseX: CGFloat
        let vy: CGFloat
        let sineAmplitude: CGFloat
        let sineFrequency: CGFloat
        let sinePhase: CGFloat
        let spawnTime: TimeInterval
        var age: TimeInterval = 0
        var isSpawned: Bool = false
        var isPopping: Bool = false
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
        let spawnWindow = config.duration * 0.4

        for i in 0..<count {
            let texture = textures[i % textures.count]
            let node = SKSpriteNode(texture: texture)
            let scale = CGFloat.random(in: 0.5...1.4)
            node.setScale(scale)
            node.alpha = 0

            let startX = CGFloat.random(in: 0...sceneSize.width)
            let startY = CGFloat.random(in: -60 ... -10)
            node.position = CGPoint(x: startX, y: startY)

            // Larger bubbles rise slower, smaller ones faster
            let vy = CGFloat.random(in: 350...600) * (1.3 - scale * 0.3)

            let p = Particle(
                node: node,
                baseX: startX,
                vy: vy,
                sineAmplitude: CGFloat.random(in: 20...60),
                sineFrequency: CGFloat.random(in: 0.5...1.5),
                sinePhase: CGFloat.random(in: 0...(2 * .pi)),
                spawnTime: Double.random(in: 0...spawnWindow)
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

        // Easing-based speed curve
        let progress = min(1.0, CGFloat(elapsed) / CGFloat(config.duration))
        let speedCurve = config.easing.speedMultiplier(at: progress, exponent: CGFloat(config.easingExponent))
        let adt = CGFloat(dt) * speed * speedCurve

        let popThreshold = sceneSize.height * 0.95
        let popDuration: CGFloat = 0.15

        for i in particles.indices {
            // Spawn check
            if !particles[i].isSpawned {
                guard elapsed >= particles[i].spawnTime else { continue }
                particles[i].isSpawned = true
                particles[i].node.alpha = 1
            }

            // Skip dead bubbles
            guard !particles[i].isPopping else { continue }

            // Advance age
            particles[i].age += Double(adt)
            let age = CGFloat(particles[i].age)

            // Rise
            particles[i].node.position.y += particles[i].vy * adt

            // Sine-wave horizontal sway
            let sway = sin(age * particles[i].sineFrequency * 2 * .pi + particles[i].sinePhase)
            particles[i].node.position.x = particles[i].baseX + sway * particles[i].sineAmplitude

            // Slight tilt following sway direction
            let tilt = sway * 0.1
            particles[i].node.zRotation = tilt

            // Pop when reaching upper screen
            if particles[i].node.position.y > popThreshold {
                particles[i].isPopping = true
                let node = particles[i].node
                let scaleUp = SKAction.scale(to: node.xScale * 1.8, duration: TimeInterval(popDuration))
                let fadeOut = SKAction.fadeAlpha(to: 0, duration: TimeInterval(popDuration))
                let pop = SKAction.group([scaleUp, fadeOut])
                pop.timingMode = .easeOut
                node.run(pop)
            }
        }

        // Global fade near end of duration
        let fadeStart = config.duration - 0.5
        if elapsed > fadeStart {
            let fadeProgress = CGFloat((elapsed - fadeStart) / 0.5)
            let alpha = max(CGFloat(0), 1 - fadeProgress)
            for particle in particles {
                if !particle.isPopping {
                    particle.node.alpha = min(particle.node.alpha, alpha)
                }
            }
        }
    }
}
