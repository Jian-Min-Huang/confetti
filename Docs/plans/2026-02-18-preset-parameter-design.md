# Design: `--preset` Parameter

## Summary

Add a `--preset` CLI parameter that applies a named set of predefined configuration values. Presets act as a base that can be partially overridden by other parameters.

## Usage

```bash
open Confetti.app --args --preset cherry
open Confetti.app --args --preset cherry --density high  # override density
```

## Preset Definitions

| Preset | Style | Emojis | Density | Speed | Easing | Duration |
|--------|-------|--------|---------|-------|--------|----------|
| confetti | confetti | 🎉🎁🍬 | medium | 5.0 | linear | 2.5 |
| cherry | falling-leaves | 🌸 | low | 1.5 | linear | 5.0 |
| maple | falling-leaves | 🍂🍁 | low | 1.5 | linear | 5.0 |
| snow | falling-leaves | ❄️☃️ | low | 1.5 | linear | 5.0 |
| fireworks | fireworks | ⭐🌟💫💥✨🔸🔹 | high | 1.0 | ease-out | 5.0 |
| meteor | meteor-shower | ⭐ | low | 2.0 | ease-in | 5.0 |
| bubbles | bubbles | 🫧 | low | 1.0 | linear | 5.0 |

## Implementation

### New: `Preset` enum in Config.swift

Each case maps to a preset name. An `apply(to:)` method sets all config fields.

### Modified: `Config.parse()`

Two-pass parsing:
1. Scan for `--preset`, apply preset values if found
2. Parse all other parameters, overriding preset values

### Files Changed

- `Sources/Config.swift` — add `Preset` enum, modify `Config.parse()`
- `README.md` — update usage examples

### Out of Scope

- No changes to Effect implementations
- No external config files or JSON presets
- No changes to existing parameter defaults
