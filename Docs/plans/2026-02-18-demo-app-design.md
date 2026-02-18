# Demo App Design

**Date:** 2026-02-18

## Goal

Build a macOS native demo app that displays 7 panels in a single window, each running a different preset effect simultaneously with infinite looping.

## Technology

- AppKit + SpriteKit (consistent with main codebase)
- Standalone Swift Package in `Demo/` directory
- Copies Effect source files from main project

## Directory Structure

```
Demo/
├── Package.swift
└── Sources/
    ├── main.swift
    ├── DemoAppDelegate.swift
    ├── DemoConfig.swift
    ├── Effects/ (copied from main project)
    │   ├── ParticleEffect.swift
    │   ├── ConfettiEffect.swift
    │   ├── FallingLeavesEffect.swift
    │   ├── FireworksEffect.swift
    │   ├── MeteorShowerEffect.swift
    │   ├── BubblesEffect.swift
    │   └── SnowEffect.swift
    ├── EmojiTexture.swift
    └── ParticleScene.swift (modified for looping)
```

## Window Layout

```
┌──────────────────────────────────────────────────────┐
│                    Confetti Demo                     │
├─────────────┬─────────────┬─────────────┬────────────┤
│             │             │             │            │
│  Confetti   │   Cherry    │   Maple     │   Snow     │
│             │             │             │            │
├─────────────┼─────────────┼─────────────┴────────────┤
│             │             │             │
│  Fireworks  │   Meteor    │  Bubbles    │
│             │             │             │
└─────────────┴─────────────┴─────────────┘
     Top row: 4 panels     Bottom row: 3 panels (centered)
     Each panel has a title label below the effect area
```

## 7 Presets (from Config.swift)

| # | Panel Title | Preset   | Style         | Emojis           |
|---|-------------|----------|---------------|------------------|
| 1 | Confetti    | confetti | confetti      | 🎉🎁🍬          |
| 2 | Cherry      | cherry   | falling-leaves| 🌸               |
| 3 | Maple       | maple    | falling-leaves| 🍂🍁             |
| 4 | Snow        | snow     | snow          | ❄️☃️             |
| 5 | Fireworks   | fireworks| fireworks     | ⭐🌟💫💥✨🔸🔹  |
| 6 | Meteor      | meteor   | meteor-shower | ⭐               |
| 7 | Bubbles     | bubbles  | bubbles       | 🫧               |

## Key Design Decisions

1. **Looping**: ParticleScene modified to reset and re-setup effect when duration ends, instead of terminating
2. **Panel background**: Dark color (#1a1a2e) to make particles visible
3. **Window size**: ~1200x800, resizable with proportional panel scaling
4. **Title labels**: Preset name displayed below each SKView panel
5. **No auto-terminate**: Window stays open until user closes it (Cmd+Q or window close button)
