import SpriteKit

// MARK: - Particle Effect Protocol (NFR-5: extensible architecture)

protocol ParticleEffect {
    /// Called once when the scene is presented. Add nodes to `scene`.
    func setup(in scene: SKScene)

    /// Called every frame. `deltaTime` is seconds since last frame.
    func update(currentTime: TimeInterval, deltaTime: TimeInterval)
}
