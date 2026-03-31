import SpriteKit

// MARK: - Particle Scene (NFR-2: GPU-accelerated via SpriteKit)

class ParticleScene: SKScene {

    private let config: Config
    private var effect: ParticleEffect?
    private var lastUpdateTime: TimeInterval = 0
    private var firstUpdate = true
    private var renderedFrameCount = 0
    var onReadyToShow: (() -> Void)?

    init(size: CGSize, config: Config) {
        self.config = config
        super.init(size: size)
        self.backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        effect = Self.createEffect(style: config.style, config: config, sceneSize: size)
        effect?.setup(in: self)
    }

    override func update(_ currentTime: TimeInterval) {
        if firstUpdate {
            lastUpdateTime = currentTime
            firstUpdate = false
            return
        }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        // Clamp dt to avoid huge jumps on first frame or lag spikes
        let clampedDt = min(dt, 1.0 / 30.0)
        effect?.update(currentTime: currentTime, deltaTime: clampedDt)
    }

    override func didFinishUpdate() {
        // Wait until 3 frames have been processed so the GPU has fully rendered
        // at least 2 frames before revealing the window (Bug #1: avoid initial flash)
        if let callback = onReadyToShow {
            renderedFrameCount += 1
            if renderedFrameCount >= 3 {
                callback()
                onReadyToShow = nil
            }
        }
    }

    // MARK: - Factory (NFR-5)

    private static func createEffect(style: EffectStyle, config: Config, sceneSize: CGSize) -> ParticleEffect {
        switch style {
        case .confetti:      return ConfettiEffect(config: config, sceneSize: sceneSize)
        case .fireworks:     return FireworksEffect(config: config, sceneSize: sceneSize)
        case .fallingLeaves: return FallingLeavesEffect(config: config, sceneSize: sceneSize)
        case .meteorShower:  return MeteorShowerEffect(config: config, sceneSize: sceneSize)
        case .bubbles:       return BubblesEffect(config: config, sceneSize: sceneSize)
        case .snow:          return SnowEffect(config: config, sceneSize: sceneSize)
        case .sparkler:      return SparklerEffect(config: config, sceneSize: sceneSize)
        }
    }
}
