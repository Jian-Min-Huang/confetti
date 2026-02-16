#!/usr/bin/env swift
import AppKit
import CoreGraphics

// Generate emoji icon at specified size
func generateEmojiImage(emoji: String, size: CGFloat) -> NSImage? {
    let fontSize = size * 0.75
    let font = NSFont.systemFont(ofSize: fontSize)

    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.black
    ]

    let attributedString = NSAttributedString(string: emoji, attributes: attributes)
    let stringSize = attributedString.size()

    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    // Center the emoji
    let x = (size - stringSize.width) / 2
    let y = (size - stringSize.height) / 2
    attributedString.draw(at: NSPoint(x: x, y: y))

    image.unlockFocus()
    return image
}

// Save image as PNG
func savePNG(image: NSImage, path: String) -> Bool {
    guard let tiffData = image.tiffRepresentation,
          let bitmapImage = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
        return false
    }

    do {
        try pngData.write(to: URL(fileURLWithPath: path))
        return true
    } catch {
        print("Error saving PNG: \(error)")
        return false
    }
}

// Main
let emoji = "🎆"
let sizes: [CGFloat] = [16, 32, 64, 128, 256, 512, 1024]

// Create iconset directory
let iconsetPath = "AppIcon.iconset"
let fileManager = FileManager.default

try? fileManager.removeItem(atPath: iconsetPath)
try? fileManager.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

print("Generating icon images...")

for size in sizes {
    guard let image = generateEmojiImage(emoji: emoji, size: size) else {
        print("Failed to generate image at size \(size)")
        continue
    }

    // Standard resolution
    let filename1x = "\(iconsetPath)/icon_\(Int(size))x\(Int(size)).png"
    if savePNG(image: image, path: filename1x) {
        print("✓ Generated \(filename1x)")
    }

    // Retina resolution (@2x)
    if size <= 512 {
        guard let image2x = generateEmojiImage(emoji: emoji, size: size * 2) else {
            continue
        }
        let filename2x = "\(iconsetPath)/icon_\(Int(size))x\(Int(size))@2x.png"
        if savePNG(image: image2x, path: filename2x) {
            print("✓ Generated \(filename2x)")
        }
    }
}

print("\nConverting to .icns format...")
let task = Process()
task.launchPath = "/usr/bin/iconutil"
task.arguments = ["-c", "icns", iconsetPath]

do {
    try task.run()
    task.waitUntilExit()

    if task.terminationStatus == 0 {
        print("✓ AppIcon.icns created successfully!")

        // Clean up iconset directory
        try? fileManager.removeItem(atPath: iconsetPath)
        print("✓ Cleaned up temporary files")
    } else {
        print("✗ Failed to create .icns file")
    }
} catch {
    print("✗ Error running iconutil: \(error)")
}
