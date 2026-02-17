import SpriteKit

// MARK: - Meteor Shower Effect
// Meteors streak from upper-right toward lower-left at 30°–60° angles,
// each with a ghost trail of fading tail nodes.

final class MeteorShowerEffect: ParticleEffect {

    // MARK: - Models

    private struct Meteor {
        let headNode: SKSpriteNode
        let tailNodes: [SKSpriteNode]
        let vx: CGFloat
        let vy: CGFloat
        let spawnTime: TimeInterval
        let lifetime: TimeInterval
        var isSpawned: Bool = false
        var age: TimeInterval = 0
        // Ring buffer of recent head positions for tail tracking
        var history: [CGPoint]
        var historyIndex: Int = 0
    }

    // MARK: - Constants

    private let tailCount = 4
    private let historySize = 20 // frames of position history to sample from

    // MARK: - State

    private let config: Config
    private let sceneSize: CGSize
    private var meteors: [Meteor] = []
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
        // Meteors use 60% of duration as max lifetime, spawn in the first 40%
        let maxLifetime = config.duration * 0.6
        let minLifetime = maxLifetime * 0.5
        let spawnWindow = config.duration - maxLifetime

        for i in 0..<count {
            let texture = textures[i % textures.count]

            // Head node
            let headNode = SKSpriteNode(texture: texture)
            headNode.setScale(CGFloat.random(in: 0.7...1.3))
            headNode.alpha = 0

            // Spawn from right side or top of screen
            let startX = sceneSize.width + CGFloat.random(in: 20...100)
            let startY = sceneSize.height * CGFloat.random(in: 0.6...1.0) + CGFloat.random(in: 0...80)
            headNode.position = CGPoint(x: startX, y: startY)

            // Angle: 15°–35° below horizontal (shallow diagonal toward lower-left)
            let angle = CGFloat.random(in: 15...35) * .pi / 180
            let speed = CGFloat.random(in: 800...1500)
            let vx = -cos(angle) * speed
            let vy = -sin(angle) * speed

            // Rotate head to face travel direction
            headNode.zRotation = atan2(vy, vx)

            scene.addChild(headNode)

            // Tail nodes (decreasing scale and alpha)
            var tailNodes: [SKSpriteNode] = []
            for t in 0..<tailCount {
                let tailNode = SKSpriteNode(texture: texture)
                let fraction = CGFloat(t + 1) / CGFloat(tailCount + 1)
                tailNode.setScale(headNode.xScale * (1.0 - fraction * 0.6))
                tailNode.alpha = 0
                tailNode.zRotation = headNode.zRotation
                tailNode.position = headNode.position
                scene.addChild(tailNode)
                tailNodes.append(tailNode)
            }

            let initialHistory = Array(repeating: headNode.position, count: historySize)

            let meteor = Meteor(
                headNode: headNode,
                tailNodes: tailNodes,
                vx: vx,
                vy: vy,
                spawnTime: Double.random(in: 0...spawnWindow),
                lifetime: Double.random(in: minLifetime...maxLifetime),
                history: initialHistory
            )

            meteors.append(meteor)
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

        for i in meteors.indices {
            // Spawn check
            if !meteors[i].isSpawned {
                guard elapsed >= meteors[i].spawnTime else { continue }
                meteors[i].isSpawned = true
                meteors[i].headNode.alpha = 1
                for t in 0..<tailCount {
                    let fraction = CGFloat(t + 1) / CGFloat(tailCount + 1)
                    meteors[i].tailNodes[t].alpha = 0.6 * (1.0 - fraction)
                }
            }

            // Advance age
            meteors[i].age += Double(adt)
            let age = meteors[i].age
            let lifetime = meteors[i].lifetime

            // Move head
            meteors[i].headNode.position.x += meteors[i].vx * adt
            meteors[i].headNode.position.y += meteors[i].vy * adt

            // Record position in ring buffer
            meteors[i].historyIndex = (meteors[i].historyIndex + 1) % historySize
            meteors[i].history[meteors[i].historyIndex] = meteors[i].headNode.position

            // Update tail nodes — each samples a progressively older position
            for t in 0..<tailCount {
                let delay = (t + 1) * (historySize / (tailCount + 1))
                let idx = (meteors[i].historyIndex - delay + historySize * 2) % historySize
                meteors[i].tailNodes[t].position = meteors[i].history[idx]
            }

            // Fade based on individual lifetime (start fading at 30%)
            let lifeProgress = CGFloat(age / lifetime)
            if lifeProgress > 0.3 {
                let fadeAmount = (lifeProgress - 0.3) / 0.7
                meteors[i].headNode.alpha = max(0, CGFloat(1.0) - fadeAmount)
                for t in 0..<tailCount {
                    let fraction = CGFloat(t + 1) / CGFloat(tailCount + 1)
                    let baseTailAlpha = 0.6 * (1.0 - fraction)
                    meteors[i].tailNodes[t].alpha = max(0, baseTailAlpha * (1.0 - fadeAmount))
                }
            }

            // Hide if fully expired or off screen
            if lifeProgress >= 1.0 || meteors[i].headNode.position.x < -100 || meteors[i].headNode.position.y < -100 {
                meteors[i].headNode.alpha = 0
                for tailNode in meteors[i].tailNodes {
                    tailNode.alpha = 0
                }
            }
        }

        // Global fade near end of duration
        let fadeStart = config.duration - 0.5
        if elapsed > fadeStart {
            let fadeProgress = CGFloat((elapsed - fadeStart) / 0.5)
            let alpha = max(CGFloat(0), 1 - fadeProgress)
            for meteor in meteors {
                meteor.headNode.alpha = min(meteor.headNode.alpha, alpha)
                for tailNode in meteor.tailNodes {
                    tailNode.alpha = min(tailNode.alpha, alpha)
                }
            }
        }
    }
}
