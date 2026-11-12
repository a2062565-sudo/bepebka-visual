import SwiftUI
import UIKit

// MARK: - App metadata

enum AppInfo {
    static let name = "BepeBka Visual"
    static let shortName = "BepeBka"
    static let version = "1.0.0"
    static let build = "1042"
    static let tagline = "VISUAL CLIENT"
}

enum DesignConstants {
    static let cornerRadius: CGFloat = 22
    static let innerRadius: CGFloat = 15
    static let moduleGutter: CGFloat = 18
    static let controlHeight: CGFloat = 44
    static let contentMaxWidth: CGFloat = 1180
}

enum DSColor {
    static let textPrimary = Color.white.opacity(0.94)
    static let textSecondary = Color.white.opacity(0.56)
    static let textTertiary = Color.white.opacity(0.36)
    static let stroke = Color.white.opacity(0.09)
    static let strokeStrong = Color.white.opacity(0.15)
    static let rowFill = Color.white.opacity(0.035)
    static let rowFillStrong = Color.white.opacity(0.055)
    static let cardFill = Color.white.opacity(0.025)
    static let danger = Color(hex: "#FB7185")
    static let success = Color(hex: "#4ADE80")
    static let warning = Color(hex: "#FBBF24")
}

// MARK: - Color from HEX

extension Color {
    init(hex: String) {
        let cleaned = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "0x", with: "")

        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let red: UInt64
        let green: UInt64
        let blue: UInt64
        let alpha: UInt64

        switch cleaned.count {
        case 3:
            let r = (value >> 8) & 0xF
            let g = (value >> 4) & 0xF
            let b = value & 0xF
            red = r * 17
            green = g * 17
            blue = b * 17
            alpha = 255
        case 6:
            red = (value >> 16) & 0xFF
            green = (value >> 8) & 0xFF
            blue = value & 0xFF
            alpha = 255
        case 8:
            alpha = (value >> 24) & 0xFF
            red = (value >> 16) & 0xFF
            green = (value >> 8) & 0xFF
            blue = value & 0xFF
        default:
            red = 255
            green = 255
            blue = 255
            alpha = 255
        }

        self.init(
            .sRGB,
            red: Double(red) / 255.0,
            green: Double(green) / 255.0,
            blue: Double(blue) / 255.0,
            opacity: Double(alpha) / 255.0
        )
    }

    var isLight: Bool {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return false }
        let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return luminance > 0.66
    }

    var hexString: String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return "#8B5CF6"
        }

        let r = Int((min(max(red, 0), 1) * 255).rounded())
        let g = Int((min(max(green, 0), 1) * 255).rounded())
        let b = Int((min(max(blue, 0), 1) * 255).rounded())
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

enum AccentPalette {
    static let colors: [String] = [
        "#8B5CF6",
        "#A855F7",
        "#D946EF",
        "#F43F5E",
        "#FB923C",
        "#FBBF24",
        "#4ADE80",
        "#2DD4BF",
        "#22D3EE",
        "#3B82F6",
        "#E2E8F0"
    ]
}

// MARK: - Haptics

enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func select() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}

// MARK: - Math helpers

func clamp(_ value: Double, _ lower: Double, _ upper: Double) -> Double {
    min(max(value, lower), upper)
}

func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
    a + (b - a) * clamp(t, 0, 1)
}

func easeOutCubic(_ t: Double) -> Double {
    let x = clamp(t, 0, 1)
    return 1 - pow(1 - x, 3)
}

func easeInOutSine(_ t: Double) -> Double {
    let x = clamp(t, 0, 1)
    return -(cos(.pi * x) - 1) / 2
}

/// Stable pseudo-random value in `0...1` for procedural previews.
func seededRandom(_ index: Int, _ salt: Int) -> Double {
    var x = UInt64(bitPattern: Int64(index)) &+ 0x9E3779B97F4A7C15
    x = x &+ UInt64(bitPattern: Int64(salt)) &* 0xBF58476D1CE4E5B9
    x ^= x >> 30
    x = x &* 0xBF58476D1CE4E5B9
    x ^= x >> 27
    x = x &* 0x94D049BB133111EB
    x ^= x >> 31
    return Double(x % 1_000_003) / 1_000_003.0
}

func hashString(_ string: String) -> UInt64 {
    var hash: UInt64 = 0xCBF29CE484222325
    for byte in string.utf8 {
        hash ^= UInt64(byte)
        hash = hash &* 0x100000001B3
    }
    return hash
}

// MARK: - Shared shapes

struct ChamferedRectangle: Shape {
    var cut: CGFloat = 12
    var corners: [Bool] = [true, true, true, true]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let tl = corners.indices.contains(0) && corners[0] ? cut : 0
        let tr = corners.indices.contains(1) && corners[1] ? cut : 0
        let br = corners.indices.contains(2) && corners[2] ? cut : 0
        let bl = corners.indices.contains(3) && corners[3] ? cut : 0

        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        if tr > 0 { path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + tr)) }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        if br > 0 { path.addLine(to: CGPoint(x: rect.maxX - br, y: rect.maxY)) }
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        if bl > 0 { path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - bl)) }
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        if tl > 0 { path.addLine(to: CGPoint(x: rect.minX + tl, y: rect.minY)) }
        path.closeSubpath()
        return path
    }
}

struct CornerBracketShape: Shape {
    var length: CGFloat = 12
    var lineWidth: CGFloat = 1.5

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let l = min(length, min(rect.width, rect.height) * 0.3)

        path.move(to: CGPoint(x: rect.minX, y: rect.minY + l))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + l, y: rect.minY))

        path.move(to: CGPoint(x: rect.maxX - l, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + l))

        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - l))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - l, y: rect.maxY))

        path.move(to: CGPoint(x: rect.minX + l, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - l))

        return path
    }
}

struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.minY + h * 0.28),
            control1: CGPoint(x: rect.midX - w * 0.52, y: rect.minY + h * 0.66),
            control2: CGPoint(x: rect.minX, y: rect.minY + h * 0.47)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY + h * 0.23),
            control1: CGPoint(x: rect.minX, y: rect.minY),
            control2: CGPoint(x: rect.midX - w * 0.25, y: rect.minY)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + h * 0.28),
            control1: CGPoint(x: rect.midX + w * 0.25, y: rect.minY),
            control2: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX, y: rect.minY + h * 0.47),
            control2: CGPoint(x: rect.midX + w * 0.52, y: rect.minY + h * 0.66)
        )
        path.closeSubpath()
        return path
    }
}

struct StarShape: Shape {
    var points: Int = 4
    var innerRatio: CGFloat = 0.24

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * innerRatio
        let total = max(points, 3) * 2

        for index in 0..<total {
            let angle = (Double(index) / Double(total)) * .pi * 2 - .pi / 2
            let radius = index.isMultiple(of: 2) ? outer : inner
            let point = CGPoint(
                x: center.x + CGFloat(Foundation.cos(angle)) * radius,
                y: center.y + CGFloat(Foundation.sin(angle)) * radius
            )
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Binding helper

extension Binding where Value == String {
    func asColor() -> Binding<Color> {
        Binding<Color>(
            get: { Color(hex: wrappedValue) },
            set: { wrappedValue = $0.hexString }
        )
    }
}
