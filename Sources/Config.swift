import Foundation
import CoreGraphics

// MARK: - Effect Style (FR-7)

enum EffectStyle: String {
    case confetti
    case fallingLeaves = "falling-leaves"
    case fireworks
}

// MARK: - Easing Type (FR-8)

enum EasingType: String {
    case linear
    case easeIn = "ease-in"
    case easeOut = "ease-out"
    case easeInOut = "ease-in-out"

    /// Returns the eased position for the given progress (0–1).
    /// Maps linear progress to curved progress using generalized easing with exponent `n`.
    ///
    /// - Parameter progress: linear progress in [0, 1]
    /// - Parameter n: easing exponent (2 = quadratic, 3 = cubic, higher = more extreme)
    /// - Returns: eased position in [0, 1]
    func position(at progress: CGFloat, exponent n: CGFloat = 2.0) -> CGFloat {
        let t = min(max(progress, 0), 1)
        switch self {
        case .linear:
            return t
        case .easeIn:
            // Slow start, fast end
            return pow(t, n)
        case .easeOut:
            // Fast start, slow end
            return 1.0 - pow(1.0 - t, n)
        case .easeInOut:
            // Slow start and end, fast middle (piecewise composition)
            if t < 0.5 {
                return pow(2.0, n - 1) * pow(t, n)
            } else {
                return 1.0 - pow(2.0, n - 1) * pow(1.0 - t, n)
            }
        }
    }

    /// Returns a speed multiplier for the given progress (0–1).
    /// This is the first derivative of `position(at:exponent:)`.
    /// The integral over [0,1] is always 1.0, preserving total animation distance.
    ///
    /// - Parameter progress: animation progress in [0, 1]
    /// - Parameter n: easing exponent (2 = quadratic, 3 = cubic, higher = more extreme)
    func speedMultiplier(at progress: CGFloat, exponent n: CGFloat = 2.0) -> CGFloat {
        let t = min(max(progress, 0), 1)
        switch self {
        case .linear:
            return 1.0
        case .easeIn:
            // f(t) = tⁿ  →  f'(t) = n·t^(n−1)
            return n * pow(t, n - 1)
        case .easeOut:
            // f(t) = 1−(1−t)ⁿ  →  f'(t) = n·(1−t)^(n−1)
            return n * pow(1.0 - t, n - 1)
        case .easeInOut:
            // Piecewise: ease-in for t<0.5, ease-out for t≥0.5
            // f'(t) = n·2^(n−1)·t^(n−1)       for t < 0.5
            // f'(t) = n·2^(n−1)·(1−t)^(n−1)   for t ≥ 0.5
            let scale = n * pow(2.0, n - 1)
            if t < 0.5 {
                return scale * pow(t, n - 1)
            } else {
                return scale * pow(1.0 - t, n - 1)
            }
        }
    }
}

// MARK: - Density (FR-10, FR-15)

enum Density: String {
    case low
    case medium
    case high

    var particleCount: Int {
        switch self {
        case .low:    return 50
        case .medium: return 100
        case .high:   return 200
        }
    }
}

// MARK: - Config (FR-9 ~ FR-20)

struct Config {
    var style: EffectStyle = .confetti       // FR-15
    var emojis: [String] = ["🎉", "⚽", "❤️"] // FR-16
    var density: Density = .medium            // FR-17
    var speed: Double = 1.0                   // FR-18
    var easing: EasingType = .easeOut         // FR-19
    var easingExponent: Double = 3.0          // Easing curve order: 2=quadratic, 3=cubic, higher=more extreme
    var duration: Double = 5.0                // FR-20

    static func parse() -> Config {
        var config = Config()
        let args = CommandLine.arguments
        var i = 1
        while i < args.count {
            switch args[i] {
            case "--style":
                if i + 1 < args.count {
                    config.style = EffectStyle(rawValue: args[i + 1]) ?? .confetti
                    i += 2
                } else { i += 1 }
            case "--emojis":
                if i + 1 < args.count {
                    let parsed = Array(args[i + 1]).map { String($0) }
                    if !parsed.isEmpty { config.emojis = parsed }
                    i += 2
                } else { i += 1 }
            case "--density":
                if i + 1 < args.count {
                    config.density = Density(rawValue: args[i + 1]) ?? .medium
                    i += 2
                } else { i += 1 }
            case "--speed":
                if i + 1 < args.count {
                    config.speed = max(0.1, Double(args[i + 1]) ?? 1.0)
                    i += 2
                } else { i += 1 }
            case "--easing":  // FR-13
                if i + 1 < args.count {
                    config.easing = EasingType(rawValue: args[i + 1]) ?? .easeOut
                    i += 2
                } else { i += 1 }
            case "--duration":
                if i + 1 < args.count {
                    config.duration = max(1.0, Double(args[i + 1]) ?? 5.0)
                    i += 2
                } else { i += 1 }
            default:
                i += 1
            }
        }
        return config
    }
}
