import AppKit
import Foundation

func createHeadroomIcon() {
    let size = CGSize(width: 1024, height: 1024)
    let image = NSImage(size: size)

    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        print("Failed to get graphics context")
        return
    }

    // Anti-aliasing
    ctx.setAllowsAntialiasing(true)
    ctx.setShouldAntialias(true)

    // 1. Transparent background
    ctx.clear(CGRect(origin: .zero, size: size))

    // 2. macOS Icon Squircle Dimensions (approx 824x824 centered with 185pt corner radius)
    let squircleRect = CGRect(x: 100, y: 100, width: 824, height: 824)
    let squirclePath = NSBezierPath(roundedRect: squircleRect, xRadius: 185, yRadius: 185)

    // Drop Shadow for squircle
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -18), blur: 32, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.6))

    // Fill Squircle Base with Deep Obsidian Titanium Gradient
    let baseGradient = NSGradient(
        colors: [
            NSColor(red: 0.12, green: 0.14, blue: 0.20, alpha: 1.0),
            NSColor(red: 0.05, green: 0.06, blue: 0.09, alpha: 1.0)
        ]
    )
    baseGradient?.draw(in: squirclePath, angle: -45)
    ctx.restoreGState()

    // 3. Inner Squircle Border (Laser Bevel)
    ctx.saveGState()
    squirclePath.addClip()

    // Subtle Radial Aurora Glow in the upper center
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let glowColors = [
        NSColor(red: 0.38, green: 0.42, blue: 0.98, alpha: 0.45).cgColor, // Neon Indigo
        NSColor(red: 0.00, green: 0.85, blue: 0.95, alpha: 0.20).cgColor, // Neon Cyan
        NSColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 0.0).cgColor
    ] as CFArray
    if let radial = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: [0.0, 0.45, 1.0]) {
        ctx.drawRadialGradient(radial, startCenter: CGPoint(x: 512, y: 550), startRadius: 20, endCenter: CGPoint(x: 512, y: 550), endRadius: 400, options: .drawsAfterEndLocation)
    }

    // Outer Bevel Stroke
    let strokePath = NSBezierPath(roundedRect: squircleRect.insetBy(dx: 2, dy: 2), xRadius: 183, yRadius: 183)
    NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.18).setStroke()
    strokePath.lineWidth = 3
    strokePath.stroke()

    // 4. Central Aperture & Storage Vacuum Vault Motif
    let center = CGPoint(x: 512, y: 512)

    // Outer Concentric Measurement Ring
    ctx.setStrokeColor(CGColor(red: 0.0, green: 0.85, blue: 0.95, alpha: 0.35))
    ctx.setLineWidth(4)
    ctx.strokeEllipse(in: CGRect(x: center.x - 240, y: center.y - 240, width: 480, height: 480))

    // Dashed Outer Forensic Ring
    ctx.setStrokeColor(CGColor(red: 0.38, green: 0.42, blue: 0.98, alpha: 0.5))
    ctx.setLineWidth(3)
    let lengths: [CGFloat] = [12, 10, 6, 10]
    ctx.setLineDash(phase: 0, lengths: lengths)
    ctx.strokeEllipse(in: CGRect(x: center.x - 210, y: center.y - 210, width: 420, height: 420))
    ctx.setLineDash(phase: 0, lengths: [])

    // Solid Neon Energy Ring
    ctx.saveGState()
    ctx.setShadow(offset: .zero, blur: 24, color: CGColor(red: 0.0, green: 0.85, blue: 0.95, alpha: 0.8))
    ctx.setStrokeColor(CGColor(red: 0.0, green: 0.85, blue: 0.95, alpha: 0.95))
    ctx.setLineWidth(8)
    ctx.strokeEllipse(in: CGRect(x: center.x - 170, y: center.y - 170, width: 340, height: 340))
    ctx.restoreGState()

    // 5. Stylized Aperture Geometric Blades
    for i in 0..<6 {
        ctx.saveGState()
        let angle = CGFloat(i) * (.pi / 3.0)
        ctx.translateBy(x: center.x, y: center.y)
        ctx.rotate(by: angle)

        let bladePath = CGMutablePath()
        bladePath.move(to: CGPoint(x: -30, y: 60))
        bladePath.addLine(to: CGPoint(x: 70, y: 140))
        bladePath.addLine(to: CGPoint(x: 90, y: 130))
        bladePath.addLine(to: CGPoint(x: 10, y: 50))
        bladePath.closeSubpath()

        ctx.setFillColor(CGColor(red: 0.38, green: 0.42, blue: 0.98, alpha: 0.75))
        ctx.setStrokeColor(CGColor(red: 0.6, green: 0.35, blue: 0.98, alpha: 0.8))
        ctx.setLineWidth(2)
        ctx.addPath(bladePath)
        ctx.drawPath(using: .fillStroke)

        ctx.restoreGState()
    }

    // 6. Center Glowing Vault Core (Hexagon with Core Glow)
    let hexRadius: CGFloat = 85
    let hexPath = CGMutablePath()
    for i in 0..<6 {
        let a = CGFloat(i) * (.pi / 3.0) - (.pi / 6.0)
        let pt = CGPoint(x: center.x + hexRadius * cos(a), y: center.y + hexRadius * sin(a))
        if i == 0 {
            hexPath.move(to: pt)
        } else {
            hexPath.addLine(to: pt)
        }
    }
    hexPath.closeSubpath()

    // Glow for hexagon core
    ctx.saveGState()
    ctx.setShadow(offset: .zero, blur: 28, color: CGColor(red: 0.0, green: 0.86, blue: 0.52, alpha: 0.9))
    ctx.setFillColor(CGColor(red: 0.07, green: 0.09, blue: 0.14, alpha: 0.95))
    ctx.addPath(hexPath)
    ctx.drawPath(using: .fill)
    ctx.restoreGState()

    // Hexagon border
    ctx.saveGState()
    ctx.setStrokeColor(CGColor(red: 0.0, green: 0.86, blue: 0.52, alpha: 0.95))
    ctx.setLineWidth(5)
    ctx.addPath(hexPath)
    ctx.strokePath()
    ctx.restoreGState()

    // Inner Expansion Chevron (Representing Headroom / Expansion)
    let chevronPath = CGMutablePath()
    chevronPath.move(to: CGPoint(x: center.x - 38, y: center.y - 12))
    chevronPath.addLine(to: CGPoint(x: center.x, y: center.y + 28))
    chevronPath.addLine(to: CGPoint(x: center.x + 38, y: center.y - 12))

    ctx.saveGState()
    ctx.setShadow(offset: .zero, blur: 14, color: CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9))
    ctx.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95))
    ctx.setLineWidth(7)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.addPath(chevronPath)
    ctx.strokePath()
    ctx.restoreGState()

    // 7. Glass Specular Sheen (Curved highlight across upper squircle)
    let sheenPath = CGMutablePath()
    sheenPath.move(to: CGPoint(x: 100, y: 650))
    sheenPath.addCurve(to: CGPoint(x: 924, y: 750), control1: CGPoint(x: 350, y: 600), control2: CGPoint(x: 650, y: 700))
    sheenPath.addLine(to: CGPoint(x: 924, y: 924))
    sheenPath.addLine(to: CGPoint(x: 100, y: 924))
    sheenPath.closeSubpath()

    ctx.saveGState()
    ctx.addPath(sheenPath)
    ctx.clip()
    let sheenGradient = NSGradient(
        colors: [
            NSColor(white: 1.0, alpha: 0.12),
            NSColor(white: 1.0, alpha: 0.0)
        ]
    )
    sheenGradient?.draw(in: squircleRect, angle: 90)
    ctx.restoreGState()

    ctx.restoreGState() // End clip of squircle
    image.unlockFocus()

    // Save PNG representation
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("Failed to export PNG data")
        return
    }

    let outURL = URL(fileURLWithPath: "Resources/AppIcon.png")
    do {
        try pngData.write(to: outURL)
        print("✅ High-resolution 1024x1024 app icon saved to: \(outURL.path)")
    } catch {
        print("Error saving PNG: \(error)")
    }
}

createHeadroomIcon()
