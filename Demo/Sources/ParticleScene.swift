import SpriteKit

class ParticleScene: SKScene {
    private let config: Config
    private var effect: ParticleEffect?
    private var lastUpdateTime: TimeInterval = 0
    private var firstUpdate = true
    private var loopStartTime: TimeInterval = 0

    init(size: CGSize, config: Config) {
        self.config = config
        super.init(size: size)
        self.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.18, alpha: 1.0)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) { resetEffect() }

    override func update(_ currentTime: TimeInterval) {
        if firstUpdate {
            lastUpdateTime = currentTime
            loopStartTime = currentTime
            firstUpdate = false
            return
        }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        let clampedDt = min(dt, 1.0 / 30.0)
        effect?.update(currentTime: currentTime, deltaTime: clampedDt)

        if currentTime - loopStartTime > config.duration + 0.5 {
            loopStartTime = currentTime
            resetEffect()
        }
    }

    private func resetEffect() {
        removeAllChildren()
        effect = Self.createEffect(style: config.style, config: config, sceneSize: size)
        effect?.setup(in: self)
    }

    private static func createEffect(style: EffectStyle, config: Config, sceneSize: CGSize) -> ParticleEffect {
        switch style {
        case .confetti:      return ConfettiEffect(config: config, sceneSize: sceneSize)
        case .fireworks:     return FireworksEffect(config: config, sceneSize: sceneSize)
        case .fallingLeaves: return FallingLeavesEffect(config: config, sceneSize: sceneSize)
        case .meteorShower:  return MeteorShowerEffect(config: config, sceneSize: sceneSize)
        case .bubbles:       return BubblesEffect(config: config, sceneSize: sceneSize)
        case .snow:          return SnowEffect(config: config, sceneSize: sceneSize)
        }
    }
}
