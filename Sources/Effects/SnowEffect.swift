import SpriteKit

// MARK: - Snow Effect (SKEmitterNode-based)
// Uses SpriteKit's built-in particle system to simulate snowfall.
// Each emoji gets its own SKEmitterNode with shared physics parameters.

final class SnowEffect: ParticleEffect {

    private let config: Config
    private let sceneSize: CGSize
    private var emitters: [SKEmitterNode] = []
    private var startTime: TimeInterval = 0
    private var started = false
    private var stoppedEmitting = false

    init(config: Config, sceneSize: CGSize) {
        self.config = config
        self.sceneSize = sceneSize
    }

    // MARK: - Setup

    func setup(in scene: SKScene) {
        let textures = config.emojis.map { EmojiTexture.create(emoji: $0, size: 36) }
        let totalRate = CGFloat(config.density.particleCount) / CGFloat(config.duration * 0.8)
        let ratePerEmitter = totalRate / CGFloat(textures.count)

        // Particle lifetime: enough to fall from top to bottom
        let baseSpeed: CGFloat = 80 * CGFloat(config.speed)
        let lifetime = sceneSize.height / baseSpeed + 2.0

        for texture in textures {
            let emitter = SKEmitterNode()

            // Texture
            emitter.particleTexture = texture
            emitter.particleColorBlendFactor = 0
            emitter.particleBlendMode = .alpha

            // Emission
            emitter.particleBirthRate = ratePerEmitter
            emitter.particleLifetime = lifetime
            emitter.particleLifetimeRange = lifetime * 0.3

            // Position: top of screen, spread across width
            emitter.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height + 20)
            emitter.particlePositionRange = CGVector(dx: sceneSize.width, dy: 0)

            // Speed: falling downward
            emitter.emissionAngle = -.pi / 2  // downward
            emitter.emissionAngleRange = 0.3  // slight spread
            emitter.particleSpeed = baseSpeed
            emitter.particleSpeedRange = baseSpeed * 0.4

            // Wind: gentle horizontal drift
            emitter.xAcceleration = CGFloat.random(in: -15...15)
            emitter.yAcceleration = -5

            // Scale: random sizes for depth
            emitter.particleScale = 0.6
            emitter.particleScaleRange = 0.4

            // Rotation: slow tumble
            emitter.particleRotationSpeed = CGFloat.random(in: -0.5...0.5)
            emitter.particleRotationRange = .pi * 2

            // Alpha
            emitter.particleAlpha = 0.9
            emitter.particleAlphaRange = 0.2
            emitter.particleAlphaSpeed = -0.05

            scene.addChild(emitter)
            emitters.append(emitter)
        }
    }

    // MARK: - Update

    func update(currentTime: TimeInterval, deltaTime dt: TimeInterval) {
        if !started { startTime = currentTime; started = true }
        let elapsed = currentTime - startTime

        // Stop emitting before duration ends so particles can finish falling
        if !stoppedEmitting && elapsed > config.duration - 0.5 {
            stoppedEmitting = true
            for emitter in emitters {
                emitter.particleBirthRate = 0
            }
        }

        // Fade out near end
        let fadeStart = config.duration - 0.5
        if elapsed > fadeStart {
            let fadeProgress = CGFloat((elapsed - fadeStart) / 0.5)
            let alpha = max(0, 1 - fadeProgress)
            for emitter in emitters {
                emitter.alpha = alpha
            }
        }
    }
}
