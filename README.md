# Confetti

- [CLAUDE.md](CLAUDE.md)

## Demo

Use `--preset` to quickly launch a preconfigured effect:

```bash
open Confetti.app --args --preset confetti
```

![confetti](./images/confetti.gif)

```bash
open Confetti.app --args --preset cherry
```

![flower](./images/cherry.gif)

```bash
open Confetti.app --args --preset maple
```

![maple](./images/maple.gif)

```bash
open Confetti.app --args --preset snow
```

![snow](./images/snow.gif)

```bash
open Confetti.app --args --preset fireworks
```

![fireworks](./images/fireworks.gif)

```bash
open Confetti.app --args --preset meteor
```

![meteor](./images/meteor.gif)

```bash
open Confetti.app --args --preset bubbles
```

![bubbles](./images/bubbles.gif)

Presets can be overridden with individual parameters:

```bash
open Confetti.app --args --preset cherry --density high --speed 3.0
```

> **Note:** The `snow` preset uses SpriteKit's built-in `SKEmitterNode` particle system. The `--easing` parameter has no effect on it. The `--density`, `--speed`, and `--duration` parameters still work but interact differently — see [CLAUDE.md](CLAUDE.md) for details.
