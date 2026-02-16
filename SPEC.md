# Confetti.app — Design Specification

## 1. Introduction

Confetti.app is a macOS command-line native application that displays particle animations as a full-screen transparent overlay. Triggered via Hooks, it provides visual feedback when an AI Agent completes a task.

## 2. Requirements

### 2.1 Functional Requirements

| ID    | Requirement                                                          |
| ----- | -------------------------------------------------------------------- |
| FR-1  | Launch via `open Confetti.app` with no additional configuration      |
| FR-2  | No Dock icon, no menu bar                                            |
| FR-3  | Display a full-screen transparent overlay above all windows          |
| FR-4  | Overlay must be click-through; all mouse events pass to underlying windows |
| FR-5  | Multi-monitor support, each screen plays its own animation           |
| FR-6  | Use multiple Emojis as animation particles, default: `🎉⚽❤️`       |
| FR-7  | Support multiple effect styles: `confetti`, `falling-leaves`, `fireworks` |
| FR-8  | Accept `--style <name>` parameter to select effect style             |
| FR-9  | Accept `--emojis <list>` parameter to customize particle Emojis      |
| FR-10 | Accept `--density <level>` parameter to control particle density (low/medium/high) |
| FR-11 | Accept `--speed <multiplier>` parameter to adjust animation speed    |
| FR-12 | Accept `--duration <seconds>` parameter to control effect play time  |
| FR-13 | `--style` defaults to `confetti`                                     |
| FR-14 | `--emojis` defaults to `🎉⚽❤️`                                      |
| FR-15 | `--density` defaults to `medium`                                     |
| FR-16 | `--speed` defaults to `1.0`                                          |
| FR-17 | `--duration` defaults to `5` seconds                                 |
| FR-18 | Automatically terminate after the animation ends                     |
| FR-19 | Support pressing `Esc` to end the animation early                    |

#### 2.1.1 Effect Style Definitions

| Style            | Motion                                                                                                                                              |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `confetti`       | Particles launch from the bottom-left toward the upper-right and from the bottom-right toward the upper-left, randomly reaching 70–90% screen height, then begin swaying side-to-side and rotating, simulating confetti paper drifting down |
| `falling-leaves` | Particles fall in batches from random positions at the top of the screen; each leaf sways side-to-side in a sine wave while continuously rotating, with slight random horizontal drift simulating wind, mimicking autumn leaves falling |
| `fireworks`      | Particles launch upward from the bottom of the screen, randomly reaching 70–90% screen height before bursting outward in all directions, simulating fireworks. Each screen has 3–5 random fireworks with random spacing between them to avoid overlap |

### 2.2 Non-Functional Requirements

| ID    | Requirement                                        |
| ----- | -------------------------------------------------- |
| NFR-1 | Zero external dependencies                         |
| NFR-2 | GPU-accelerated rendering for smooth animation     |
| NFR-3 | Self-contained binary — no image resource files needed |
| NFR-4 | Build entirely from the command line (no Xcode project required) |
| NFR-5 | Architecture designed for continuous effect expansion |
