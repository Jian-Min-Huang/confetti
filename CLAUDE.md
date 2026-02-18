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
        // let speedCurve = config.easing.speedMultiplier(at: progress, exponent: CGFloat(config.easingExponent))
        // let adt = CGFloat(dt) * CGFloat(config.speed) * speedCurve
        // Update particle physics/positions
        // Handle fade-out near config.duration
    }
}
```

**Critical Implementation Details:**

- Use `config.density.particleCount` for particle count (low: 100, medium: 200, high: 300)
- Apply easing-based speed curve:
  ```swift
  let progress = min(1.0, CGFloat(elapsed) / CGFloat(config.duration))
  let speedCurve = config.easing.speedMultiplier(at: progress, exponent: CGFloat(config.easingExponent))
  let adt = CGFloat(dt) * CGFloat(config.speed) * speedCurve
  ```
- Create emoji textures with `EmojiTexture.create(emoji: String)`
- Fade particles near end: `if elapsed > config.duration - 0.5 { ... }`
- Set initial `node.alpha = 0` to prevent flash, reveal on spawn

## Configuration System

Command-line parameters (defined in [Config.swift](Sources/Config.swift)):

| Parameter    | Type             | Default    | Notes                                  |
| ------------ | ---------------- | ---------- | -------------------------------------- |
| `--preset`   | `Preset`         | (none)     | Named presets; other params override   |
| `--style`    | `EffectStyle`    | `confetti` | confetti, falling-leaves, fireworks, meteor-shower, bubbles |
| `--emojis`   | String of emojis | `🎉🎊✨`   | Parsed into array of single chars      |
| `--density`  | `Density`        | `medium`   | Maps to particleCount: 100/200/300     |
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
- Target height: 30%-60% screen (was 70%-90%)
- Velocity boost: 1.20-1.30x (was 0.95-1.05x)
- Horizontal velocity: 30-300 (was 500-900)

These create a flatter arc trajectory as specified in [BUG_zh.md](BUG_zh.md).

### Easing Functions (FR-8, FR-13, FR-19)

Easing functions control the animation speed curve over time, making particle motion feel more natural. The implementation provides two methods with a configurable exponent parameter.

**Two Methods** ([Config.swift](Sources/Config.swift)):

1. `position(at:exponent:)` — Maps linear progress to eased position (used by FireworksEffect for rocket interpolation)
2. `speedMultiplier(at:exponent:)` — First derivative of `position()`, returns speed multiplier (used by most effects)

**Mathematical Implementation** (generalized with exponent `n`, default `n=2`):

```swift
// position(at:exponent:) — eased position in [0,1]
case .easeIn:    pow(t, n)                           // Slow start
case .easeOut:   1.0 - pow(1.0 - t, n)               // Fast start
case .easeInOut: t < 0.5 ? pow(2,n-1)·t^n : 1-pow(2,n-1)·(1-t)^n

// speedMultiplier(at:exponent:) — first derivative
case .easeIn:    n * pow(t, n - 1)                    // f(t)=tⁿ → f'(t)=n·t^(n−1)
case .easeOut:   n * pow(1.0 - t, n - 1)              // f(t)=1−(1−t)ⁿ → f'(t)=n·(1−t)^(n−1)
case .easeInOut: n·2^(n−1)·t^(n−1) or (1−t)^(n−1)    // Piecewise at t=0.5
```

**Usage in Effects** (see [ConfettiEffect.swift](Sources/Effects/ConfettiEffect.swift):76-78):

```swift
let progress = min(1.0, CGFloat(elapsed) / CGFloat(config.duration))
let speedCurve = config.easing.speedMultiplier(at: progress, exponent: CGFloat(config.easingExponent))
let adt = CGFloat(dt) * CGFloat(config.speed) * speedCurve
```

**Key Properties:**

- All curves integrate to 1.0 over [0,1], preserving total animation distance
- Exponent `n` controls curve intensity: 2=quadratic, 3=cubic (default `easingExponent`), higher=more extreme
- `ease-out` (default) creates natural deceleration, ideal for settling effects
- FireworksEffect uses `position()` for rockets (direct interpolation) and `speedMultiplier()` for sparks

### Auto-Termination

App terminates via two mechanisms:

1. **Duration-based:** `DispatchQueue.main.asyncAfter(config.duration + 0.5)` in AppDelegate
2. **User-triggered:** Esc key (keyCode 53) monitored in AppDelegate

### Emoji Rendering

- `EmojiTexture.create(emoji:size:)` renders emoji strings to SKTexture (default size: 36pt)
- Textures are cached by `"{emoji}_{size}"` key — effects may use custom sizes (e.g., 28pt sparks, 32pt rockets, 40pt leaves)
- Particle nodes use random scale (typically 0.7...1.3) for variety

## Code References

All code includes functional requirement (FR-_) and non-functional requirement (NFR-_) comments matching [SPEC_zh.md](SPEC_zh.md). Use these to understand the purpose of each section.

## Adding New Effects

1. Create `Sources/Effects/YourEffect.swift` implementing `ParticleEffect`
2. Add case to `EffectStyle` enum in [Config.swift](Sources/Config.swift)
3. Add factory case in `ParticleScene.createEffect()` in [ParticleScene.swift](Sources/ParticleScene.swift)
4. Update README.md with effect description

Reference existing effects as templates - they demonstrate proper config integration, multi-phase particle behavior, and fade-out handling.
