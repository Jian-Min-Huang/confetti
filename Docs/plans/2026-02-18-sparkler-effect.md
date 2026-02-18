# Sparkler Effect Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a sparkler (仙女棒) effect that continuously emits spark particles from screen center in all directions using SKEmitterNode.

**Architecture:** SKEmitterNode-based (same pattern as SnowEffect). One emitter per emoji texture, positioned at screen center, emitting 360°. Lifecycle: continuous emission → stop at duration-0.5s → fade out.

**Tech Stack:** Swift, SpriteKit (SKEmitterNode), existing ParticleEffect protocol

---

### Task 1: Add `sparkler` to EffectStyle enum

**Files:**
- Modify: `Sources/Config.swift:72-79`

**Step 1: Add enum case**

In `EffectStyle` enum (line 72-79), add `sparkler` after `snow`:

```swift
enum EffectStyle: String {
    case confetti
    case fallingLeaves = "falling-leaves"
    case fireworks
    case meteorShower = "meteor-shower"
    case bubbles
    case snow
    case sparkler
}
```

**Step 2: Build to verify**

Run: `swift build 2>&1 | head -20`
Expected: Build FAILS — exhaustive switch in `ParticleScene.createEffect()` missing `.sparkler` case. This is expected and will be fixed in Task 3.

---

### Task 2: Create SparklerEffect

**Files:**
- Create: `Sources/Effects/SparklerEffect.swift`

**Step 1: Write SparklerEffect implementation**

Create `Sources/Effects/SparklerEffect.swift` with full implementation following SnowEffect pattern:

```swift
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
```

---

### Task 3: Wire up factory and build

**Files:**
- Modify: `Sources/ParticleScene.swift:42-49`

**Step 1: Add factory case**

In `ParticleScene.createEffect()` switch (line 42-49), add sparkler case after snow:

```swift
case .sparkler:    return SparklerEffect(config: config, sceneSize: sceneSize)
```

**Step 2: Build to verify**

Run: `swift build -c release`
Expected: BUILD SUCCEEDED

**Step 3: Manual smoke test**

Run: `swift run Confetti --style sparkler --duration 5`
Expected: Sparks emit from screen center in all directions, fade out at end.

**Step 4: Commit**

```bash
git add Sources/Effects/SparklerEffect.swift Sources/Config.swift Sources/ParticleScene.swift
git commit -m "feat: add sparkler effect using SKEmitterNode particle system"
```

---

### Task 4: Add sparkler preset

**Files:**
- Modify: `Sources/Config.swift:6-68`

**Step 1: Add preset case**

In `Preset` enum (line 6), add `case sparkler` after `bubbles`.

In `apply(to:)` switch (line 15-67), add:

```swift
case .sparkler:
    config.style = .sparkler
    config.emojis = ["✨", "🌟", "💫"]
    config.density = .high
    config.speed = 1.0
    config.easing = .linear
    config.duration = 5.0
```

**Step 2: Build and test**

Run: `swift build -c release && swift run Confetti --preset sparkler`
Expected: BUILD SUCCEEDED. Sparkler runs with ✨🌟💫 emojis.

**Step 3: Commit**

```bash
git add Sources/Config.swift
git commit -m "feat: add sparkler preset with star emoji defaults"
```

---

### Task 5: Update README and CLAUDE.md

**Files:**
- Modify: `README.md`
- Modify: `CLAUDE.md`

**Step 1: Add sparkler demo to README.md**

After the bubbles section (line 49), add:

```markdown
```bash
open Confetti.app --args --preset sparkler
```

![sparkler](./images/sparkler.gif)
```

Update the note at the bottom to mention sparkler alongside snow:

> **Note:** The `snow` and `sparkler` presets use SpriteKit's built-in `SKEmitterNode` particle system. The `--easing` parameter has no effect on them.

**Step 2: Update CLAUDE.md**

In the `--style` row of the Configuration System table, add `sparkler` to the list of styles.

**Step 3: Commit**

```bash
git add README.md CLAUDE.md
git commit -m "docs: add sparkler effect to README and CLAUDE.md"
```
