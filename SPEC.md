# Confetti.app — Design Specification

## 1. Introduction

Confetti.app is a macOS native command-line application that displays full-screen particle animations as transparent overlays. Triggered via Hooks, it provides visual feedback effects when AI Agents complete tasks.

## 2. Requirements

### 2.1 Functional Requirements

| ID    | Requirement                                                                      |
| ----- | -------------------------------------------------------------------------------- |
| FR-1  | Launch via `open Confetti.app` with no additional configuration required         |
| FR-2  | No Dock icon, no menu bar                                                        |
| FR-3  | Display full-screen transparent overlay above all windows                        |
| FR-4  | Overlay must be click-through, passing all mouse events to underlying windows    |
| FR-5  | Support multiple screens, each screen plays its own animation independently      |
| FR-6  | Use multiple emojis as animation particles, default `🎉🎊✨`                     |
| FR-7  | Support multiple effect styles: `confetti`, `falling-leaves`, `fireworks`        |
| FR-8  | Support multiple easing functions: `linear`, `ease-in`, `ease-out`, `ease-in-out` |
| FR-9  | Accept `--style <name>` parameter to select effect style                         |
| FR-10 | Accept `--emojis <list>` parameter to customize particle emojis                  |
| FR-11 | Accept `--density <level>` parameter to control particle density (low/medium/high) |
| FR-12 | Accept `--speed <multiplier>` parameter to adjust animation speed                |
| FR-13 | Accept `--easing <type>` parameter to control animation speed curve              |
| FR-14 | Accept `--duration <seconds>` parameter to control effect playback duration      |
| FR-15 | `--style` defaults to `confetti`                                                 |
| FR-16 | `--emojis` defaults to `🎉🎊✨`                                                   |
| FR-17 | `--density` defaults to `medium`                                                 |
| FR-18 | `--speed` defaults to `1.0`                                                      |
| FR-19 | `--easing` defaults to `ease-out`                                                |
| FR-20 | `--duration` defaults to `5` seconds                                             |
| FR-21 | Auto-terminate after animation ends                                              |
| FR-22 | Support pressing `Esc` to end animation early                                    |

#### 2.1.1 Effect Style Definitions

| Style            | Motion                                                                                                                                                                                                           |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `confetti`       | Particles launch from the bottom-left toward the upper-right and from the bottom-right toward the upper-left. After reaching a random height of 70–90% of the screen, they begin swaying side-to-side and rotating, simulating paper confetti drifting down |
| `falling-leaves` | Particles fall in batches from random positions along the top of the screen. Each leaf sways left and right in a sine wave while continuously rotating, with slight random horizontal drift to simulate wind, mimicking autumn leaves falling |
| `fireworks`      | Particles launch upward from the bottom of the screen and burst outward in all directions after reaching a random height of 70–90% of the screen, simulating fireworks. Each screen has 3–5 random fireworks with random intervals between them to avoid overlap |

### 2.2 Non-Functional Requirements

| ID    | Requirement                                              |
| ----- | -------------------------------------------------------- |
| NFR-1 | Zero external dependencies                               |
| NFR-2 | GPU-accelerated rendering for smooth animations          |
| NFR-3 | Self-contained binary — no image asset files required    |
| NFR-4 | Build entirely from command line (no Xcode project needed) |
| NFR-5 | Architecture designed for continuous effect expansion     |
