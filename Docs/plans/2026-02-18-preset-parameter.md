# Preset Parameter Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a `--preset` CLI parameter that applies named configuration presets, with override support.

**Architecture:** Add `Preset` enum to Config.swift with an `apply(to:)` method. Modify `Config.parse()` to use two-pass parsing: first apply preset, then parse remaining args as overrides.

**Tech Stack:** Swift, ArgumentParser-free CLI parsing (manual `CommandLine.arguments`)

---

### Task 1: Add Preset enum and modify Config.parse()

**Files:**
- Modify: `Sources/Config.swift:6` (insert Preset enum before EffectStyle)
- Modify: `Sources/Config.swift:107-149` (update Config.parse())

**Step 1: Add Preset enum after imports, before EffectStyle**

Insert this code at `Sources/Config.swift:4` (between the import and EffectStyle):

```swift
// MARK: - Preset

enum Preset: String {
    case confetti
    case cherry
    case maple
    case snow
    case fireworks
    case meteor
    case bubbles

    func apply(to config: inout Config) {
        switch self {
        case .confetti:
            config.style = .confetti
            config.emojis = ["🎉", "🎁", "🍬"]
            config.density = .medium
            config.speed = 5.0
            config.easing = .linear
            config.duration = 2.5
        case .cherry:
            config.style = .fallingLeaves
            config.emojis = ["🌸"]
            config.density = .low
            config.speed = 1.5
            config.easing = .linear
            config.duration = 5.0
        case .maple:
            config.style = .fallingLeaves
            config.emojis = ["🍂", "🍁"]
            config.density = .low
            config.speed = 1.5
            config.easing = .linear
            config.duration = 5.0
        case .snow:
            config.style = .fallingLeaves
            config.emojis = ["❄️", "☃️"]
            config.density = .low
            config.speed = 1.5
            config.easing = .linear
            config.duration = 5.0
        case .fireworks:
            config.style = .fireworks
            config.emojis = ["⭐", "🌟", "💫", "💥", "✨", "🔸", "🔹"]
            config.density = .high
            config.speed = 1.0
            config.easing = .easeOut
            config.duration = 5.0
        case .meteor:
            config.style = .meteorShower
            config.emojis = ["⭐"]
            config.density = .low
            config.speed = 2.0
            config.easing = .easeIn
            config.duration = 5.0
        case .bubbles:
            config.style = .bubbles
            config.emojis = ["🫧"]
            config.density = .low
            config.speed = 1.0
            config.easing = .linear
            config.duration = 5.0
        }
    }
}
```

**Step 2: Modify Config.parse() for two-pass parsing**

Replace the `Config.parse()` method body. The key change: scan for `--preset` first and apply it, then run the existing parameter parsing loop which will override preset values.

```swift
static func parse() -> Config {
    var config = Config()
    let args = CommandLine.arguments

    // Pass 1: Apply preset if specified
    for j in 1..<args.count {
        if args[j] == "--preset", j + 1 < args.count,
           let preset = Preset(rawValue: args[j + 1]) {
            preset.apply(to: &config)
            break
        }
    }

    // Pass 2: Parse individual parameters (overrides preset values)
    var i = 1
    while i < args.count {
        switch args[i] {
        case "--preset":
            i += 2  // skip, already handled
        case "--style":
            // ... (existing cases unchanged)
```

**Step 3: Build and verify**

Run: `swift build -c release`
Expected: BUILD SUCCEEDED

**Step 4: Manual smoke test**

Run: `swift run Confetti --preset cherry`
Expected: Falling leaves with 🌸 emoji

Run: `swift run Confetti --preset cherry --density high`
Expected: Falling leaves with 🌸 emoji, denser particles

**Step 5: Commit**

```bash
git add Sources/Config.swift
git commit -m "feat: add --preset parameter for named configuration presets"
```

---

### Task 2: Update README.md

**Files:**
- Modify: `README.md`

**Step 1: Add preset usage section to README**

Add a "Presets" section after the CLAUDE.md link, before the Demo section. Show the short preset commands alongside (or replacing) the verbose commands.

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add preset usage examples to README"
```
