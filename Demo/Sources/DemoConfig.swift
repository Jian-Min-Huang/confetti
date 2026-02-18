import Foundation
import CoreGraphics

// MARK: - Effect Style

enum EffectStyle: String {
    case confetti
    case fallingLeaves = "falling-leaves"
    case fireworks
    case meteorShower = "meteor-shower"
    case bubbles
    case snow
}

// MARK: - Easing Type

enum EasingType: String {
    case linear
    case easeIn = "ease-in"
    case easeOut = "ease-out"
    case easeInOut = "ease-in-out"

    func position(at progress: CGFloat, exponent n: CGFloat = 2.0) -> CGFloat {
        let t = min(max(progress, 0), 1)
        switch self {
        case .linear:
            return t
        case .easeIn:
            return pow(t, n)
        case .easeOut:
            return 1.0 - pow(1.0 - t, n)
        case .easeInOut:
            if t < 0.5 {
                return pow(2.0, n - 1) * pow(t, n)
            } else {
                return 1.0 - pow(2.0, n - 1) * pow(1.0 - t, n)
            }
        }
    }

    func speedMultiplier(at progress: CGFloat, exponent n: CGFloat = 2.0) -> CGFloat {
        let t = min(max(progress, 0), 1)
        switch self {
        case .linear:
            return 1.0
        case .easeIn:
            return n * pow(t, n - 1)
        case .easeOut:
            return n * pow(1.0 - t, n - 1)
        case .easeInOut:
            let scale = n * pow(2.0, n - 1)
            if t < 0.5 {
                return scale * pow(t, n - 1)
            } else {
                return scale * pow(1.0 - t, n - 1)
            }
        }
    }
}

// MARK: - Density

enum Density: String {
    case low
    case medium
    case high

    var particleCount: Int {
        switch self {
        case .low:    return 100
        case .medium: return 200
        case .high:   return 300
        }
    }
}

// MARK: - Config

struct Config {
    var style: EffectStyle = .confetti
    var emojis: [String] = ["🎉", "🎊", "✨"]
    var density: Density = .medium
    var speed: Double = 1.0
    var easing: EasingType = .easeOut
    var easingExponent: Double = 3.0
    var duration: Double = 5.0
}

// MARK: - Demo Preset

struct DemoPreset {
    let title: String
    let config: Config

    static let all: [DemoPreset] = [
        DemoPreset(title: "Confetti", config: Config(
            style: .confetti,
            emojis: ["🎉", "🎁", "🍬"],
            density: .medium,
            speed: 5.0,
            easing: .linear,
            duration: 2.5
        )),
        DemoPreset(title: "Cherry", config: Config(
            style: .fallingLeaves,
            emojis: ["🌸"],
            density: .low,
            speed: 1.5,
            easing: .linear,
            duration: 5.0
        )),
        DemoPreset(title: "Maple", config: Config(
            style: .fallingLeaves,
            emojis: ["🍂", "🍁"],
            density: .low,
            speed: 1.5,
            easing: .linear,
            duration: 5.0
        )),
        DemoPreset(title: "Snow", config: Config(
            style: .snow,
            emojis: ["❄️", "☃️"],
            density: .high,
            speed: 2.5,
            easing: .linear,
            duration: 5.0
        )),
        DemoPreset(title: "Fireworks", config: Config(
            style: .fireworks,
            emojis: ["⭐", "🌟", "💫", "💥", "✨", "🔸", "🔹"],
            density: .high,
            speed: 1.0,
            easing: .easeOut,
            duration: 5.0
        )),
        DemoPreset(title: "Meteor", config: Config(
            style: .meteorShower,
            emojis: ["⭐"],
            density: .low,
            speed: 2.0,
            easing: .linear,
            duration: 5.0
        )),
        DemoPreset(title: "Bubbles", config: Config(
            style: .bubbles,
            emojis: ["🫧"],
            density: .low,
            speed: 1.0,
            easing: .linear,
            duration: 5.0
        )),
    ]
}
