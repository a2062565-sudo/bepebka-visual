import SwiftUI

// MARK: - Preset profile

struct CrosshairPresetProfile {
    let preset: CrosshairPreset
    let size: Double
    let thickness: Double
    let gap: Double
    let dot: Bool
    let dynamic: Bool
    let outline: Bool
    let glow: Bool
    let colorHex: String

    static func profile(for preset: CrosshairPreset) -> CrosshairPresetProfile {
        switch preset {
        case .classic:
            return CrosshairPresetProfile(
                preset: .classic,
                size: 18, thickness: 2, gap: 5,
                dot: true, dynamic: false, outline: true, glow: false,
                colorHex: "#7CF2A1"
            )
        case .dot:
            return CrosshairPresetProfile(
                preset: .dot,
                size: 0, thickness: 3.2, gap: 0,
                dot: true, dynamic: false, outline: false, glow: false,
                colorHex: "#E5E7EB"
            )
        case .cross:
            return CrosshairPresetProfile(
                preset: .cross,
                size: 15, thickness: 1.6, gap: 6,
                dot: false, dynamic: false, outline: true, glow: false,
                colorHex: "#F9A8D4"
            )
        case .neon:
            return CrosshairPresetProfile(
                preset: .neon,
                size: 17, thickness: 2.4, gap: 4,
                dot: true, dynamic: true, outline: false, glow: true,
                colorHex: "#22D3EE"
            )
        case .minimal:
            return CrosshairPresetProfile(
                preset: .minimal,
                size: 10, thickness: 1.2, gap: 3,
                dot: false, dynamic: false, outline: false, glow: false,
                colorHex: "#FFFFFF"
            )
        case .sniper:
            return CrosshairPresetProfile(
                preset: .sniper,
                size: 28, thickness: 1.3, gap: 12,
                dot: true, dynamic: false, outline: true, glow: false,
                colorHex: "#FCA5A5"
            )
        }
    }

    var settingsPreview: CrosshairSettings {
        var settings = CrosshairSettings()
        settings.preset = preset
        settings.size = size
        settings.thickness = thickness
        settings.gap = gap
        settings.dot = dot
        settings.dynamic = dynamic
        settings.outline = outline
        settings.glow = glow
        settings.colorHex = colorHex
        settings.opacity = 1
        settings.enabled = true
        return settings
    }
}

// MARK: - Crosshair canvas

struct CrosshairCanvasView: View {
    let settings: CrosshairSettings
    var spread: CGFloat = 0
    var scale: CGFloat = 1

    private var color: Color { Color(hex: settings.colorHex) }

    var body: some View {
        Canvas { context, size in
            guard settings.enabled else { return }

            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let armLength = CGFloat(settings.size) * scale
            let gap = CGFloat(max(0, settings.gap)) * scale + spread * scale
            let thickness = max(1, CGFloat(settings.thickness) * scale)
            let opacity = clamp(settings.opacity, 0.05, 1)
            let dotRadius = max(0.8, thickness * 0.72)

            var arms = Path()
            if armLength > 0.5 {
                arms.move(to: CGPoint(x: center.x, y: center.y - gap - armLength))
                arms.addLine(to: CGPoint(x: center.x, y: center.y - gap))
                arms.move(to: CGPoint(x: center.x, y: center.y + gap))
                arms.addLine(to: CGPoint(x: center.x, y: center.y + gap + armLength))
                arms.move(to: CGPoint(x: center.x - gap - armLength, y: center.y))
                arms.addLine(to: CGPoint(x: center.x - gap, y: center.y))
                arms.move(to: CGPoint(x: center.x + gap, y: center.y))
                arms.addLine(to: CGPoint(x: center.x + gap + armLength, y: center.y))
            }

            var dot = Path()
            if settings.dot {
                dot.addEllipse(in: CGRect(
                    x: center.x - dotRadius,
                    y: center.y - dotRadius,
                    width: dotRadius * 2,
                    height: dotRadius * 2
                ))
            }

            let style = StrokeStyle(lineWidth: thickness, lineCap: .square)

            if settings.glow {
                var glowContext = context
                glowContext.addFilter(.blur(radius: thickness * 2.4))
                glowContext.blendMode = .plusLighter
                glowContext.opacity = 0.85
                glowContext.stroke(arms, with: .color(color.opacity(opacity)), style: style)
                glowContext.fill(dot, with: .color(color.opacity(opacity)))
            }

            if settings.outline {
                var outlineContext = context
                outlineContext.stroke(
                    arms,
                    with: .color(Color.black.opacity(0.62 * opacity)),
                    style: StrokeStyle(lineWidth: thickness + 2, lineCap: .square)
                )
                if settings.dot {
                    outlineContext.fill(
                        Path(ellipseIn: CGRect(
                            x: center.x - dotRadius - 1,
                            y: center.y - dotRadius - 1,
                            width: (dotRadius + 1) * 2,
                            height: (dotRadius + 1) * 2
                        )),
                        with: .color(Color.black.opacity(0.55 * opacity))
                    )
                }
            }

            context.stroke(arms, with: .color(color.opacity(opacity)), style: style)
            context.fill(dot, with: .color(color.opacity(opacity)))
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Animated stage

struct CrosshairStageView: View {
    @EnvironmentObject private var store: ClientStore

    let settings: CrosshairSettings
    var scale: CGFloat = 1.55

    var body: some View {
        Group {
            if settings.enabled && settings.dynamic && !store.animationsPaused {
                TimelineView(.animation(minimumInterval: store.refreshInterval)) { timeline in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    let pulse = (0.5 + 0.5 * sin(time * 4.1)) * 4.4
                    CrosshairCanvasView(
                        settings: settings,
                        spread: CGFloat(pulse),
                        scale: scale
                    )
                }
            } else {
                CrosshairCanvasView(settings: settings, spread: 0, scale: scale)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Range backdrop

struct CrosshairRangeBackdrop: View {
    let accent: Color

    var body: some View {
        Canvas(opaque: false, rendersAsynchronously: true) { context, size in
            let horizon = size.height * 0.63
            let rect = CGRect(origin: .zero, size: size)

            context.fill(
                Path(rect),
                with: .linearGradient(
                    Gradient(colors: [Color(hex: "#0D1520"), Color(hex: "#070B11"), Color(hex: "#030407")]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: size.width, y: size.height)
                )
            )

            var glow = context
            glow.addFilter(.blur(radius: size.width * 0.07))
            glow.fill(
                Path(ellipseIn: CGRect(
                    x: -size.width * 0.1,
                    y: -size.height * 0.2,
                    width: size.width * 0.7,
                    height: size.height * 0.7
                )),
                with: .radialGradient(
                    Gradient(colors: [accent.opacity(0.2), .clear]),
                    center: CGPoint(x: size.width * 0.25, y: size.height * 0.14),
                    startRadius: 0,
                    endRadius: size.width * 0.4
                )
            )

            for index in 0..<8 {
                let x = size.width * CGFloat(0.16 + Double(index) * 0.1)
                var panel = Path()
                panel.move(to: CGPoint(x: x, y: 0))
                panel.addLine(to: CGPoint(x: x, y: horizon))
                context.stroke(panel, with: .color(.white.opacity(0.035)), lineWidth: 0.7)
            }

            for index in 0..<4 {
                let y = size.height * CGFloat(0.12 + Double(index) * 0.13)
                var beam = Path()
                beam.move(to: CGPoint(x: 0, y: y))
                beam.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(beam, with: .color(.white.opacity(0.028)), lineWidth: 0.8)
            }

            drawTargetBoard(
                context: &context,
                center: CGPoint(x: size.width * 0.5, y: size.height * 0.46),
                radius: min(size.width, size.height) * 0.2,
                accent: accent,
                opacity: 0.28
            )
            drawTargetBoard(
                context: &context,
                center: CGPoint(x: size.width * 0.17, y: size.height * 0.5),
                radius: min(size.width, size.height) * 0.1,
                accent: accent,
                opacity: 0.2
            )
            drawTargetBoard(
                context: &context,
                center: CGPoint(x: size.width * 0.83, y: size.height * 0.52),
                radius: min(size.width, size.height) * 0.085,
                accent: accent,
                opacity: 0.16
            )

            context.fill(
                Path(CGRect(x: 0, y: horizon, width: size.width, height: size.height - horizon)),
                with: .linearGradient(
                    Gradient(colors: [Color(hex: "#080B11"), Color(hex: "#010203")]),
                    startPoint: CGPoint(x: 0, y: horizon),
                    endPoint: CGPoint(x: 0, y: size.height)
                )
            )

            let vanishing = CGPoint(x: size.width * 0.5, y: horizon)
            for ray in -7...7 {
                let bottomX = vanishing.x + CGFloat(ray) * size.width * 0.13
                var path = Path()
                path.move(to: vanishing)
                path.addLine(to: CGPoint(x: bottomX, y: size.height))
                context.stroke(path, with: .color(accent.opacity(0.06)), lineWidth: 0.6)
            }

            for row in 1...8 {
                let progress = pow(Double(row) / 8.0, 1.7)
                let y = horizon + CGFloat(progress) * (size.height - horizon)
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(accent.opacity(0.02 + progress * 0.04)), lineWidth: 0.5)
            }

            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: 0, y: horizon))
                    path.addLine(to: CGPoint(x: size.width, y: horizon))
                },
                with: .color(accent.opacity(0.2)),
                lineWidth: 0.7
            )

            context.fill(
                Path(rect),
                with: .radialGradient(
                    Gradient(colors: [.clear, .clear, Color.black.opacity(0.62)]),
                    center: CGPoint(x: size.width * 0.5, y: size.height * 0.5),
                    startRadius: min(size.width, size.height) * 0.25,
                    endRadius: max(size.width, size.height) * 0.78
                )
            )
        }
    }

    private func drawTargetBoard(
        context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat,
        accent: Color,
        opacity: Double
    ) {
        var board = context
        board.opacity = opacity

        board.fill(
            Path(ellipseIn: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )),
            with: .radialGradient(
                Gradient(colors: [Color(hex: "#1B2230").opacity(0.8), Color(hex: "#090C12").opacity(0.9)]),
                center: center,
                startRadius: 0,
                endRadius: radius
            )
        )

        for ring in 1...4 {
            let ringRadius = radius * CGFloat(ring) / 4.0
            board.stroke(
                Path(ellipseIn: CGRect(
                    x: center.x - ringRadius,
                    y: center.y - ringRadius,
                    width: ringRadius * 2,
                    height: ringRadius * 2
                )),
                with: .color((ring.isMultiple(of: 2) ? accent : .white).opacity(0.12)),
                lineWidth: 0.7
            )
        }

        board.stroke(
            Path(ellipseIn: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )),
            with: .color(.white.opacity(0.08)),
            lineWidth: 0.8
        )

        board.fill(
            Path(ellipseIn: CGRect(
                x: center.x - radius * 0.05,
                y: center.y - radius * 0.05,
                width: radius * 0.1,
                height: radius * 0.1
            )),
            with: .color(accent.opacity(0.7))
        )
    }
}
