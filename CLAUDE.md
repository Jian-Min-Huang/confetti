# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Confetti is a macOS native command-line app that displays full-screen particle animations as transparent overlays. Built with Swift and SpriteKit, it provides GPU-accelerated particle effects for visual feedback when AI agents complete tasks.

## Build & Run Commands

```bash
# Build in release mode (optimized)
swift build -c release

# Build in debug mode
swift build

# Run directly with Swift
swift run Confetti --style fireworks

# Run the built app
open .build/release/Confetti.app --args --style confetti --density high

# Clean build artifacts
swift package clean
```

**Platform Requirements:**

- macOS 13.0+ (specified in Package.swift)
- Swift 5.9+
- No external dependencies or Xcode project required

## Architecture

### Core Components Flow

```plain
main.swift
  ↓ parses CLI args
Config.parse()
  ↓ creates
AppDelegate
  ↓ for each screen, creates
OverlayWindow + ParticleScene
  ↓ factory method creates
ParticleEffect (ConfettiEffect | FireworksEffect | FallingLeavesEffect | MeteorShowerEffect | BubblesEffect)
```

### Key Design Patterns

- Protocol-Based Effect System
  - All effects implement `ParticleEffect` protocol with `setup()` and `update()` methods
  - `ParticleScene.createEffect()` acts as factory, mapping `EffectStyle` enum to concrete implementations
  - Add new effects by: creating effect class → adding enum case → updating factory switch

- Multi-Screen Architecture
  - `AppDelegate` creates one `OverlayWindow` + `ParticleScene` per `NSScreen`
  - Each scene runs its own effect instance independently
  - All windows use `.screenSaver` level to appear above everything

- Click-Through Overlay
  - `OverlayWindow` sets `ignoresMouseEvents = true` for click-through (FR-4)
  - Window uses `.borderless` style and `level = .screenSaver` to float above all apps (FR-3)
  - App uses `.accessory` activation policy to hide from Dock/menu bar (FR-2)

### Effect Implementation Structure

Each `ParticleEffect` should follow this pattern (see [ConfettiEffect.swift](Sources/Effects/ConfettiEffect.swift) as reference):

```swift
final class YourEffect: ParticleEffect {
    private struct Particle {
        let node: SKSpriteNode
        // physics/animation state
    }

    private let config: Config
    private let sceneSize: CGSize
    private var particles: [Particle] = []

    func setup(in scene: SKScene) {
        // Create particle nodes using EmojiTexture.create()
        // Add them to scene with scene.addChild()
        // Respect config.density.particleCount
    }

    func update(currentTime: TimeInterval, deltaTime dt: TimeInterval) {
        // Apply easing-based speed curve:
        // let progress = min(1.0, CGFloat(elapsed) / CGFloat(config.duration))
        // let speedCurve = config.easing.speedMultiplier(at: progress)
        // let adt = CGFloat(dt) * CGFloat(config.speed) * speedCurve
        // Update particle physics/positions
        // Handle fade-out near config.duration
    }
}
```

**Critical Implementation Details:**

- Use `config.density.particleCount` for particle count (low: 50, medium: 100, high: 200)
- Apply easing-based speed curve:
  ```swift
  let progress = min(1.0, CGFloat(elapsed) / CGFloat(config.duration))
  let speedCurve = config.easing.speedMultiplier(at: progress)
  let adt = CGFloat(dt) * CGFloat(config.speed) * speedCurve
  ```
- Create emoji textures with `EmojiTexture.create(emoji: String)`
- Fade particles near end: `if elapsed > config.duration - 0.5 { ... }`
- Set initial `node.alpha = 0` to prevent flash, reveal on spawn

## Configuration System

Command-line parameters (defined in [Config.swift](Sources/Config.swift)):

| Parameter    | Type             | Default    | Notes                                  |
| ------------ | ---------------- | ---------- | -------------------------------------- |
| `--style`    | `EffectStyle`    | `confetti` | confetti, falling-leaves, fireworks, meteor-shower, bubbles |
| `--emojis`   | String of emojis | `🎉🎊✨`   | Parsed into array of single chars      |
| `--density`  | `Density`        | `high`     | Maps to particleCount: 50/100/200      |
| `--speed`    | Double           | `1.0`      | Animation speed multiplier             |
| `--easing`   | `EasingType`     | `ease-out` | linear, ease-in, ease-out, ease-in-out |
| `--duration` | Double           | `5.0`      | Auto-terminate after duration + 0.5s   |

Internal hard-coded parameters (not exposed as CLI arguments):

| Property         | Type   | Default | Notes                                                         |
| ---------------- | ------ | ------- | ------------------------------------------------------------- |
| `easingExponent` | Double | `3.0`   | Easing curve order: 2=quadratic, 3=cubic, higher=more extreme |

## Important Implementation Notes

### Startup Flash Fix (Bug #1 - RESOLVED)

Windows start with `alphaValue = 0` and fade in after 0.05s delay to prevent initial white flash:

```swift
// AppDelegate.swift:30-38
window.alphaValue = 0
window.orderFrontRegardless()
DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
    window.alphaValue = 1
}
```

### Physics Parameter Tuning

**Confetti Effect** (Bug #2 fixed - arc flattened):

- Launch gravity: 100 (was 400)
- Target height: 50%-95% screen (was 70%-90%)
- Velocity boost: 1.30-1.50x (was 0.95-1.05x)
- Horizontal velocity: 100-1000 (was 500-900)

These create a flatter arc trajectory as specified in [BUG_zh.md](BUG_zh.md).

### Easing Functions (FR-8, FR-13, FR-19)

Easing functions control the animation speed curve over time, making particle motion feel more natural. The implementation uses **speed multipliers** derived from the first derivative of standard easing curves.

**Mathematical Implementation** ([Config.swift](Sources/Config.swift):23-38):

```swift
func speedMultiplier(at progress: CGFloat) -> CGFloat {
    let t = min(max(progress, 0), 1)  // clamp to [0,1]
    switch self {
    case .linear:
        return 1.0                     // constant speed
    case .easeIn:
        return 2.0 * t                 // f(t)=t²  → f'(t)=2t
    case .easeOut:
        return 2.0 * (1.0 - t)         // f(t)=2t−t² → f'(t)=2(1−t)
    case .easeInOut:
        return 6.0 * t * (1.0 - t)     // f(t)=3t²−2t³ → f'(t)=6t(1−t)
    }
}
```

**Usage in Effects** (see [ConfettiEffect.swift](Sources/Effects/ConfettiEffect.swift):98-101):

```swift
let progress = min(1.0, CGFloat(elapsed) / CGFloat(config.duration))
let speedCurve = config.easing.speedMultiplier(at: progress)
let adt = CGFloat(dt) * CGFloat(config.speed) * speedCurve
```

**Key Properties:**

- All curves integrate to 1.0 over [0,1], preserving total animation distance
- `ease-out` (default) creates natural deceleration, ideal for settling effects
- `ease-in-out` creates smooth acceleration/deceleration, used in both rocket launch and spark explosion phases in fireworks effect

### Auto-Termination

App terminates via two mechanisms:

1. **Duration-based:** `DispatchQueue.main.asyncAfter(config.duration + 0.5)` in AppDelegate
2. **User-triggered:** Esc key (keyCode 53) monitored in AppDelegate

### Emoji Rendering

- `EmojiTexture.create()` renders emoji strings to SKTexture using Core Text
- Textures are cached per unique emoji
- Particle nodes use random scale (typically 0.7...1.3) for variety

## Code References

All code includes functional requirement (FR-_) and non-functional requirement (NFR-_) comments matching [SPEC_zh.md](SPEC_zh.md). Use these to understand the purpose of each section.

## Adding New Effects

1. Create `Sources/Effects/YourEffect.swift` implementing `ParticleEffect`
2. Add case to `EffectStyle` enum in [Config.swift](Sources/Config.swift)
3. Add factory case in `ParticleScene.createEffect()` in [ParticleScene.swift](Sources/ParticleScene.swift)
4. Update README.md with effect description

Reference existing effects as templates - they demonstrate proper config integration, multi-phase particle behavior, and fade-out handling.
