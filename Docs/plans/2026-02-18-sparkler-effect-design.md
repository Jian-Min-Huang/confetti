# Sparkler Effect Design

## Overview

A sparkler (仙女棒) effect that continuously emits spark particles from the center of the screen in all directions, simulating a handheld sparkler burning. Uses SKEmitterNode for automatic particle lifecycle management.

## Approach

SKEmitterNode-based (same pattern as SnowEffect). One emitter per emoji texture, all positioned at screen center.

**Trade-off:** No easing support (SKEmitterNode limitation), but simpler code and automatic particle recycling.

## SKEmitterNode Parameters

| Property | Value | Notes |
|---|---|---|
| `position` | Screen center | Fixed emission origin |
| `particlePositionRange` | (0, 0) | All sparks from single point |
| `emissionAngle` | 0 | Combined with 2π range = omnidirectional |
| `emissionAngleRange` | 2π | Full 360° emission |
| `particleSpeed` | ~200 × speed | Spark ejection velocity |
| `particleSpeedRange` | ~120 × speed | Randomized for depth |
| `particleLifetime` | ~1.0s | Short-lived sparks |
| `particleLifetimeRange` | ~0.5s | Variation |
| `particleAlpha` | 1.0 | Fades via `particleAlphaSpeed` |
| `particleAlphaSpeed` | -1.0 | Sparks fade over lifetime |
| `particleScale` | 0.5, range 0.3 | Random sizes |
| `yAcceleration` | -40 | Light gravity for natural droop |

## Lifecycle

1. **Continuous emission** from frame 0, birth rate derived from `config.density`
2. **Stop emission** at `duration - 0.5s` (`particleBirthRate = 0`)
3. **Fade out** last 0.5s via emitter alpha

## Default Emoji

✨🌟💫 (one emitter per emoji, birth rate split evenly)

## Config Parameter Mapping

| Config Parameter | SKEmitterNode Mapping |
|---|---|
| `density` | `particleBirthRate` |
| `speed` | `particleSpeed` multiplier |
| `emojis` | One emitter per emoji |
| `duration` | Stop emission + fade out |
| `easing` | Not applicable (SKEmitterNode limitation) |

## Files to Change

1. **New:** `Sources/Effects/SparklerEffect.swift` — effect implementation
2. **Edit:** `Sources/Config.swift` — add `EffectStyle.sparkler` case
3. **Edit:** `Sources/ParticleScene.swift` — add factory case in `createEffect()`
