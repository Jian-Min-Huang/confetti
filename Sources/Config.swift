import Foundation

// MARK: - Effect Style (FR-7, FR-8, FR-13)

enum EffectStyle: String {
    case confetti
    case fallingLeaves = "falling-leaves"
    case fireworks
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

// MARK: - Config (FR-8 ~ FR-17)

struct Config {
    var style: EffectStyle = .confetti       // FR-13
    var emojis: [String] = ["🎉", "⚽", "❤️"] // FR-14
    var density: Density = .medium            // FR-15
    var speed: Double = 1.0                   // FR-16
    var duration: Double = 5.0                // FR-17

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
