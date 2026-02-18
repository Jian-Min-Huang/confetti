import SpriteKit

// MARK: - Sparkler Effect (SKEmitterNode-based)
// Emits spark particles from screen center in all directions,
// simulating a handheld sparkler burning.

final class SparklerEffect: ParticleEffect {

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

        let baseSpeed: CGFloat = 200 * CGFloat(config.speed)

        for texture in textures {
            let emitter = SKEmitterNode()

            // Texture
            emitter.particleTexture = texture
            emitter.particleColorBlendFactor = 0
            emitter.particleBlendMode = .alpha

            // Emission
            emitter.particleBirthRate = ratePerEmitter
            emitter.particleLifetime = 1.0
            emitter.particleLifetimeRange = 0.5

            // Position: screen center, all sparks from single point
            emitter.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
            emitter.particlePositionRange = CGVector(dx: 0, dy: 0)

            // Speed: omnidirectional burst
            emitter.emissionAngle = 0
            emitter.emissionAngleRange = .pi * 2
            emitter.particleSpeed = baseSpeed
            emitter.particleSpeedRange = baseSpeed * 0.6

            // Gravity: light downward pull for natural droop
            emitter.xAcceleration = 0
            emitter.yAcceleration = -40

            // Scale: random sizes
            emitter.particleScale = 0.5
            emitter.particleScaleRange = 0.3

            // Rotation
            emitter.particleRotationSpeed = CGFloat.random(in: -1.0...1.0)
            emitter.particleRotationRange = .pi * 2

            // Alpha: fade out over lifetime
            emitter.particleAlpha = 1.0
            emitter.particleAlphaRange = 0.1
            emitter.particleAlphaSpeed = -1.0

            scene.addChild(emitter)
            emitters.append(emitter)
        }
    }

    // MARK: - Update

    func update(currentTime: TimeInterval, deltaTime dt: TimeInterval) {
        if !started { startTime = currentTime; started = true }
        let elapsed = currentTime - startTime

        // Stop emitting before duration ends so particles can finish fading
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
