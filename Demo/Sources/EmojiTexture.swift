import AppKit
import SpriteKit

// MARK: - Emoji → SKTexture (FR-6, NFR-3: self-contained, no image assets)

enum EmojiTexture {

    private static var cache: [String: SKTexture] = [:]

    /// Render an emoji character into an SKTexture at the given font size.
    static func create(emoji: String, size: CGFloat = 36) -> SKTexture {
        let key = "\(emoji)_\(size)"
        if let cached = cache[key] { return cached }

        let font = NSFont.systemFont(ofSize: size)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let attrString = NSAttributedString(string: emoji, attributes: attributes)
        let textSize = attrString.size()

        let image = NSImage(size: textSize)
        image.lockFocus()
        attrString.draw(at: .zero)
        image.unlockFocus()

        let texture = SKTexture(image: image)
        cache[key] = texture
        return texture
    }
}
