import SwiftUI
import AppKit

public enum Theme {
    // Serious Engineering Obsidian Palette
    public static let bgDeepSpace = Color(red: 0.05, green: 0.06, blue: 0.08)
    public static let bgCard = Color(red: 0.09, green: 0.10, blue: 0.14).opacity(0.92)
    public static let bgCardHover = Color(red: 0.13, green: 0.15, blue: 0.21)
    public static let bgSurface = Color(red: 0.07, green: 0.08, blue: 0.11)

    // Precision Neon Accents (Serious, High-Tech, Crisp)
    public static let neonPurple = Color(red: 0.60, green: 0.35, blue: 0.98) // #9959FA
    public static let neonIndigo = Color(red: 0.38, green: 0.42, blue: 0.98) // #616BFA
    public static let neonCyan = Color(red: 0.00, green: 0.85, blue: 0.95)   // #00D9F2 (High-precision cyan)
    public static let neonEmerald = Color(red: 0.00, green: 0.86, blue: 0.52) // #00DB84 (Verified safety)
    public static let neonAmber = Color(red: 1.00, green: 0.70, blue: 0.00)  // #FFB300 (Caution/Stale)
    public static let neonRose = Color(red: 1.00, green: 0.22, blue: 0.38)   // #FF3860 (Purge)

    // Linear Laser Gradients
    public static let auroraGradient = LinearGradient(
        colors: [neonPurple, neonIndigo, neonCyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let emeraldGradient = LinearGradient(
        colors: [Color(red: 0.1, green: 0.9, blue: 0.6), neonEmerald],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let amberGradient = LinearGradient(
        colors: [Color(red: 1.0, green: 0.8, blue: 0.2), neonAmber],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let glassBorder = LinearGradient(
        colors: [
            Color.white.opacity(0.20),
            Color.white.opacity(0.04),
            neonCyan.opacity(0.12)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Precise Technical Typography Constants
    public static let fontMetricHero = Font.system(size: 26, weight: .bold, design: .monospaced)
    public static let fontMetricCard = Font.system(size: 19, weight: .bold, design: .monospaced)
    public static let fontMonoData = Font.system(size: 13, weight: .medium, design: .monospaced)
    public static let fontMonoPath = Font.system(size: 11, weight: .regular, design: .monospaced)
}

// Precision Glass Card Modifier
struct BlingCardModifier: ViewModifier {
    var glowColor: Color = Theme.neonIndigo
    var cornerRadius: CGFloat = 12
    var isHovered: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isHovered ? Theme.bgCardHover : Theme.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                isHovered ?
                                LinearGradient(colors: [glowColor.opacity(0.7), Color.white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                Theme.glassBorder,
                                lineWidth: isHovered ? 1.5 : 1
                            )
                    )
                    .shadow(color: isHovered ? glowColor.opacity(0.25) : Color.black.opacity(0.5), radius: isHovered ? 12 : 6, x: 0, y: isHovered ? 4 : 2)
            )
    }
}

extension View {
    public func blingCard(glowColor: Color = Theme.neonIndigo, cornerRadius: CGFloat = 12, isHovered: Bool = false) -> some View {
        self.modifier(BlingCardModifier(glowColor: glowColor, cornerRadius: cornerRadius, isHovered: isHovered))
    }
}
