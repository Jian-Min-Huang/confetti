# Confetti

A macOS native command-line app that displays full-screen particle animations as transparent overlays. Perfect for providing visual feedback when AI agents complete tasks through hooks.

## Features

- 🎯 **Zero Configuration** — Just `open Confetti.app` to launch
- 🪟 **Transparent Overlay** — Displays above all windows, click-through enabled
- 🖥️ **Multi-Screen Support** — Each screen plays its own animation
- 🎨 **Multiple Effect Styles** — `confetti`, `falling-leaves`, `fireworks`
- 🎭 **Customizable Particles** — Use any emoji as particles (default: 🎉⚽❤️)
- ⚙️ **Flexible Parameters** — Control density, speed, duration, and more
- ⌨️ **Quick Exit** — Press `Esc` to stop anytime
- 🚀 **GPU Accelerated** — Smooth rendering with SpriteKit
- 📦 **Self-Contained Binary** — No external dependencies or assets

## Installation

```bash
# Clone the repository
git clone https://github.com/jianminhuang/confetti.git
cd confetti

# Build the app
swift build -c release

# Copy to Applications (optional)
cp -r .build/release/Confetti.app /Applications/
```

## Usage

### Basic Usage

```bash
# Launch with default confetti effect
open Confetti.app

# Or specify a custom effect
open Confetti.app --args --style falling-leaves
```

### Parameters

| Parameter    | Description                | Default     | Options                                   |
| ------------ | -------------------------- | ----------- | ----------------------------------------- |
| `--style`    | Effect style               | `confetti`  | `confetti`, `falling-leaves`, `fireworks` |
| `--emojis`   | Particle emojis            | `🎉⚽❤️`    | Any emoji string                          |
| `--density`  | Particle density           | `medium`    | `low`, `medium`, `high`                   |
| `--speed`    | Animation speed multiplier | `1.0`       | Any positive number                       |
| `--duration` | Effect duration in seconds | `5`         | Any positive number                       |

### Examples

```bash
# Falling leaves with custom emojis
open Confetti.app --args --style falling-leaves --emojis 🍂🍁🌿 --duration 8

# High-density confetti celebration
open Confetti.app --args --style confetti --density high --emojis 🎉🎊✨

# Slow-motion fireworks
open Confetti.app --args --style fireworks --speed 0.5 --duration 10
```

## Effect Styles

### Confetti

Particles shoot from bottom-left to top-right and bottom-right to top-left, reaching 70-90% screen height before swaying and rotating down like paper confetti.

### Falling Leaves

Particles spawn from the top in batches, each swaying sinusoidally while rotating and drifting with subtle wind simulation — like autumn leaves falling.

### Fireworks

Particles launch from the bottom, rising to 70-90% screen height before exploding outward. Each screen displays 3-5 fireworks with randomized timing and positions to avoid overlap.

## Hook Integration

Confetti.app is designed to work seamlessly with AI agent hooks. Add to your agent's success hook:

```bash
# Example hook configuration
on_success: "open /Applications/Confetti.app --args --style confetti --emojis 🎉✨🎊"
```

## Architecture

- **Zero Dependencies** — Pure Swift, no external frameworks
- **GPU Accelerated** — Built on SpriteKit for smooth 60fps rendering
- **Extensible Design** — Easy to add new effect styles
- **Command-Line Build** — No Xcode project required

## Development

```bash
# Build in debug mode
swift build

# Run directly
swift run Confetti --style fireworks

# Clean build artifacts
swift package clean
```

## Requirements

- macOS 12.0+
- Swift 5.9+

## License

MIT License - See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Feel free to:

- Add new effect styles
- Improve existing animations
- Report bugs or suggest features

---

Made with ❤️ for making celebrations more fun
