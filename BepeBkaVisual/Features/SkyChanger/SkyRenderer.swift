import SwiftUI

// MARK: - Animated stage

struct SkyStageView: View {
    @EnvironmentObject private var store: ClientStore

    let preset: SkyPreset
    let intensity: Double
    let speed: Double
    let brightness: Double
    let temperature: Double

    var body: some View {
        Group {
            if preset.isAnimated && !store.animationsPaused {
                TimelineView(.animation(minimumInterval: store.refreshInterval)) { timeline in
                    SkyCanvasView(
                        preset: preset,
                        intensity: intensity,
                        speed: speed,
                        brightness: brightness,
                        temperature: temperature,
                        time: timeline.date.timeIntervalSinceReferenceDate
                    )
                }
            } else {
                SkyCanvasView(
                    preset: preset,
                    intensity: intensity,
                    speed: speed,
                    brightness: brightness,
                    temperature: temperature,
                    time: 3.2
                )
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Static artwork

struct SkyArtworkView: View {
    let preset: SkyPreset
    var intensity: Double = 0.85
    var brightness: Double = 0
    var temperature: Double = 0
    var time: Double = 2.4

    var body: some View {
        SkyCanvasView(
            preset: preset,
            intensity: intensity,
            speed: 1,
            brightness: brightness,
            temperature: temperature,
            time: time
        )
        .allowsHitTesting(false)
    }
}

// MARK: - Canvas renderer

struct SkyCanvasView: View {
    let preset: SkyPreset
    let intensity: Double
    let speed: Double
    let brightness: Double
    let temperature: Double
    let time: Double

    var body: some View {
        Canvas(opaque: false, rendersAsynchronously: true) { context, size in
            let t = time * max(0.1, speed)
            drawBase(context: &context, size: size, time: t)

            switch preset {
            case .pureBlack, .pureWhite, .bloodRed, .deepBlue, .purple,
                 .sunset, .darkOrange, .pinkSky, .emerald:
                drawStaticPreset(context: &context, size: size, time: t)
            case .space:
                drawSpace(context: &context, size: size, time: t)
            case .blackHole:
                drawBlackHole(context: &context, size: size, time: t)
            case .galaxy:
                drawGalaxy(context: &context, size: size, time: t)
            case .nightSky:
                drawNightSky(context: &context, size: size, time: t)
            case .aurora:
                drawAurora(context: &context, size: size, time: t)
            case .nebula:
                drawNebula(context: &context, size: size, time: t)
            case .stars:
                drawStarsPreset(context: &context, size: size, time: t)
            case .cosmicStorm:
                drawCosmicStorm(context: &context, size: size, time: t)
            case .solarEclipse:
                drawSolarEclipse(context: &context, size: size, time: t)
            case .purpleUniverse:
                drawPurpleUniverse(context: &context, size: size, time: t)
            }

            drawAdjustments(context: &context, size: size)
        }
    }

    private var glow: Double {
        clamp(intensity, 0, 1)
    }

    private var accentColors: [Color] {
        preset.accentColors
    }

    private var accent: Color {
        preset.accentColors.first ?? .white
    }

    private var secondary: Color {
        preset.accentColors.count > 1 ? preset.accentColors[1] : accent
    }

    // MARK: Base

    private func drawBase(context: inout GraphicsContext, size: CGSize, time: Double) {
        let colors = preset.colors
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                Gradient(colors: colors),
                startPoint: CGPoint(x: size.width * 0.18, y: 0),
                endPoint: CGPoint(x: size.width * 0.82, y: size.height)
            )
        )

        if let last = colors.last {
            context.fill(
                Path(ellipseIn: CGRect(
                    x: -size.width * 0.3,
                    y: size.height * 0.5,
                    width: size.width * 1.6,
                    height: size.height * 0.9
                )),
                with: .radialGradient(
                    Gradient(colors: [last.opacity(0.22 + glow * 0.12), .clear]),
                    center: CGPoint(x: size.width * 0.5, y: size.height * 0.88),
                    startRadius: 0,
                    endRadius: size.width * 0.8
                )
            )
        }

        if preset != .pureWhite {
            drawStars(
                context: &context,
                size: size,
                count: Int(24 + 60 * glow),
                time: time,
                drift: 0.0008,
                twinkle: 0.8,
                opacity: 0.28
            )
        }
    }

    // MARK: Static presets

    private func drawStaticPreset(context: inout GraphicsContext, size: CGSize, time: Double) {
        switch preset {
        case .sunset, .darkOrange, .pinkSky:
            let sun = CGPoint(x: size.width * 0.52, y: size.height * 0.64)
            let radius = min(size.width, size.height) * 0.15
            var sunContext = context
            sunContext.addFilter(.blur(radius: radius * 0.35))
            sunContext.fill(
                Path(ellipseIn: CGRect(
                    x: sun.x - radius * 1.7,
                    y: sun.y - radius * 1.7,
                    width: radius * 3.4,
                    height: radius * 3.4
                )),
                with: .radialGradient(
                    Gradient(colors: [accent.opacity(0.7), secondary.opacity(0.18), .clear]),
                    center: sun,
                    startRadius: 0,
                    endRadius: radius * 1.7
                )
            )
            context.fill(
                Path(ellipseIn: CGRect(x: sun.x - radius, y: sun.y - radius, width: radius * 2, height: radius * 2)),
                with: .radialGradient(
                    Gradient(colors: [Color.white.opacity(0.85), accent.opacity(0.4)]),
                    center: sun,
                    startRadius: 0,
                    endRadius: radius
                )
            )

        case .bloodRed:
            drawHorizonGlow(
                context: &context,
                size: size,
                color: Color(hex: "#FF3B4E"),
                opacity: 0.28,
                height: 0.35
            )

        case .deepBlue, .purple, .emerald:
            drawHorizonGlow(
                context: &context,
                size: size,
                color: accent,
                opacity: 0.2 + glow * 0.1,
                height: 0.45
            )

        case .pureWhite:
            context.fill(
                Path(ellipseIn: CGRect(
                    x: -size.width * 0.2,
                    y: -size.height * 0.4,
                    width: size.width * 1.4,
                    height: size.height * 1.4
                )),
                with: .radialGradient(
                    Gradient(colors: [Color(hex: "#DDEBFF").opacity(0.5), .clear]),
                    center: CGPoint(x: size.width * 0.28, y: size.height * 0.18),
                    startRadius: 0,
                    endRadius: size.width * 0.7
                )
            )

        default:
            break
        }
    }

    private func drawHorizonGlow(
        context: inout GraphicsContext,
        size: CGSize,
        color: Color,
        opacity: Double,
        height: Double
    ) {
        context.fill(
            Path(ellipseIn: CGRect(
                x: -size.width * 0.2,
                y: size.height * (1 - height),
                width: size.width * 1.4,
                height: size.height * height * 1.6
            )),
            with: .radialGradient(
                Gradient(colors: [color.opacity(opacity), .clear]),
                center: CGPoint(x: size.width * 0.5, y: size.height * 0.92),
                startRadius: 0,
                endRadius: size.width * 0.7
            )
        )
    }

    // MARK: Space

    private func drawSpace(context: inout GraphicsContext, size: CGSize, time: Double) {
        drawNebulaClouds(
            context: &context,
            size: size,
            time: time,
            colors: [Color(hex: "#3B5BDB"), Color(hex: "#7048E8"), Color(hex: "#C084FC")],
            count: 5
        )
        drawStars(
            context: &context,
            size: size,
            count: Int(110 + 130 * glow),
            time: time,
            drift: 0.004,
            twinkle: 1.2,
            opacity: 0.8
        )
        drawShootingStar(context: &context, size: size, time: time, offset: 0.2, color: .white)
    }

    // MARK: Black hole

    private func drawBlackHole(context: inout GraphicsContext, size: CGSize, time: Double) {
        drawStars(
            context: &context,
            size: size,
            count: Int(80 + 90 * glow),
            time: time * 0.5,
            drift: 0.0006,
            twinkle: 0.6,
            opacity: 0.5
        )

        let center = CGPoint(x: size.width * 0.5, y: size.height * 0.52)
        let unit = min(size.width, size.height)
        let radius = unit * 0.17

        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - unit * 0.46,
                y: center.y - unit * 0.46,
                width: unit * 0.92,
                height: unit * 0.92
            )),
            with: .radialGradient(
                Gradient(colors: [Color(hex: "#7C3AED").opacity(0.2 * glow), .clear]),
                center: center,
                startRadius: radius * 0.6,
                endRadius: unit * 0.46
            )
        )

        var disk = context
        disk.translateBy(x: center.x, y: center.y)
        disk.rotate(by: .degrees(-18))
        disk.translateBy(x: -center.x, y: -center.y)

        for ring in 0..<4 {
            let ringRadius = radius * CGFloat(1.18 + Double(ring) * 0.2)
            let rect = CGRect(
                x: center.x - ringRadius * 1.65,
                y: center.y - ringRadius * 0.62,
                width: ringRadius * 3.3,
                height: ringRadius * 1.24
            )
            var ringContext = disk
            ringContext.addFilter(.blur(radius: max(2, unit * 0.008)))
            let colors = [accent.opacity(0.15 + Double(3 - ring) * 0.12), Color(hex: "#FBBF24").opacity(0.08), .clear]
            ringContext.stroke(
                Path(ellipseIn: rect),
                with: .linearGradient(
                    Gradient(colors: colors),
                    startPoint: CGPoint(x: rect.minX, y: rect.midY),
                    endPoint: CGPoint(x: rect.maxX, y: rect.midY)
                ),
                style: StrokeStyle(
                    lineWidth: unit * 0.014,
                    lineCap: .round,
                    dash: [unit * 0.035, unit * 0.02],
                    dashPhase: CGFloat(time * (0.6 + Double(ring) * 0.24))
                )
            )
        }

        for index in 0..<46 {
            let orbit = radius * CGFloat(1.35 + seededRandom(index, 211) * 0.95)
            let angle = seededRandom(index, 223) * .pi * 2 + time * (0.22 + seededRandom(index, 227) * 0.2)
            let x = center.x + CGFloat(cos(angle)) * orbit * 1.45
            let y = center.y + CGFloat(sin(angle)) * orbit * 0.55
            let dot = CGFloat(0.6 + seededRandom(index, 229) * 1.7)
            context.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: dot, height: dot)),
                with: .color((index.isMultiple(of: 3) ? Color(hex: "#FBBF24") : accent).opacity(0.6))
            )
        }

        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )),
            with: .radialGradient(
                Gradient(colors: [Color.black, Color(hex: "#020105")]),
                center: center,
                startRadius: 0,
                endRadius: radius
            )
        )

        context.stroke(
            Path(ellipseIn: CGRect(
                x: center.x - radius * 1.03,
                y: center.y - radius * 1.03,
                width: radius * 2.06,
                height: radius * 2.06
            )),
            with: .color(accent.opacity(0.7)),
            lineWidth: max(1, unit * 0.006)
        )
    }

    // MARK: Galaxy

    private func drawGalaxy(context: inout GraphicsContext, size: CGSize, time: Double) {
        drawNebulaClouds(
            context: &context,
            size: size,
            time: time,
            colors: [Color(hex: "#4C1D95"), Color(hex: "#7C3AED"), Color(hex: "#DB2777"), Color(hex: "#2563EB")],
            count: 6
        )

        let center = CGPoint(x: size.width * 0.52, y: size.height * 0.5)
        let unit = min(size.width, size.height)
        let rotation = time * 0.045

        var galaxyContext = context
        galaxyContext.addFilter(.blur(radius: unit * 0.006))
        galaxyContext.blendMode = .plusLighter

        for arm in 0..<3 {
            for index in 0..<72 {
                let progress = Double(index) / 72.0
                let angle = progress * .pi * 3.6 + Double(arm) * (.pi * 2 / 3) + rotation
                let radius = CGFloat(progress) * unit * 0.42
                let x = center.x + CGFloat(cos(angle)) * radius
                let y = center.y + CGFloat(sin(angle)) * radius * 0.54
                let dot = CGFloat(0.4 + (1 - progress) * 2.1 + seededRandom(index + arm * 100, 233) * 1.4)
                let color = index.isMultiple(of: 4) ? accent : (index.isMultiple(of: 3) ? secondary : Color.white)
                galaxyContext.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: dot, height: dot)),
                    with: .color(color.opacity(0.2 + (1 - progress) * 0.5))
                )
            }
        }

        for index in 0..<90 {
            let x = CGFloat(seededRandom(index, 239)) * size.width
            let y = CGFloat(seededRandom(index, 241)) * size.height
            let dot = CGFloat(0.5 + seededRandom(index, 251) * 1.3)
            let alpha = 0.25 + 0.55 * (0.5 + 0.5 * sin(time * 1.1 + seededRandom(index, 257) * 6))
            context.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: dot, height: dot)),
                with: .color(.white.opacity(alpha))
            )
        }

        var core = context
        core.addFilter(.blur(radius: unit * 0.05))
        core.fill(
            Path(ellipseIn: CGRect(
                x: center.x - unit * 0.12,
                y: center.y - unit * 0.08,
                width: unit * 0.24,
                height: unit * 0.16
            )),
            with: .radialGradient(
                Gradient(colors: [Color.white.opacity(0.75), accent.opacity(0.5), .clear]),
                center: center,
                startRadius: 0,
                endRadius: unit * 0.12
            )
        )
    }

    // MARK: Night sky

    private func drawNightSky(context: inout GraphicsContext, size: CGSize, time: Double) {
        drawHorizonGlow(
            context: &context,
            size: size,
            color: Color(hex: "#3B82F6"),
            opacity: 0.16,
            height: 0.32
        )
        drawStars(
            context: &context,
            size: size,
            count: Int(100 + 110 * glow),
            time: time,
            drift: 0.0012,
            twinkle: 1.4,
            opacity: 0.85
        )

        let moon = CGPoint(x: size.width * 0.73, y: size.height * 0.26)
        let radius = min(size.width, size.height) * 0.075
        context.fill(
            Path(ellipseIn: CGRect(
                x: moon.x - radius * 2.4,
                y: moon.y - radius * 2.4,
                width: radius * 4.8,
                height: radius * 4.8
            )),
            with: .radialGradient(
                Gradient(colors: [Color.white.opacity(0.22 * glow), .clear]),
                center: moon,
                startRadius: 0,
                endRadius: radius * 2.4
            )
        )
        context.fill(
            Path(ellipseIn: CGRect(x: moon.x - radius, y: moon.y - radius, width: radius * 2, height: radius * 2)),
            with: .color(Color(hex: "#E2E8F0").opacity(0.86))
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: moon.x - radius * 0.75,
                y: moon.y - radius * 1.15,
                width: radius * 1.8,
                height: radius * 1.8
            )),
            with: .color(Color(hex: "#08152F").opacity(0.92))
        )
        drawShootingStar(context: &context, size: size, time: time, offset: 0.45, color: Color(hex: "#BFDBFE"))
    }

    // MARK: Aurora

    private func drawAurora(context: inout GraphicsContext, size: CGSize, time: Double) {
        drawStars(
            context: &context,
            size: size,
            count: Int(70 + 80 * glow),
            time: time * 0.6,
            drift: 0.0005,
            twinkle: 1.0,
            opacity: 0.65
        )

        let colors = [Color(hex: "#34D399"), Color(hex: "#22D3EE"), Color(hex: "#A78BFA")]

        for band in 0..<4 {
            var path = Path()
            let baseY = size.height * CGFloat(0.34 + Double(band) * 0.06)
            path.move(to: CGPoint(x: -size.width * 0.1, y: baseY))
            for step in 0...52 {
                let progress = Double(step) / 52.0
                let x = -size.width * 0.1 + size.width * 1.2 * CGFloat(progress)
                let y = baseY
                    + CGFloat(sin(progress * .pi * 2.2 + time * 0.22 + Double(band) * 1.1)) * size.height * 0.06
                    + CGFloat(sin(progress * .pi * 5.1 - time * 0.14)) * size.height * 0.02
                path.addLine(to: CGPoint(x: x, y: y))
            }

            var ribbon = context
            ribbon.addFilter(.blur(radius: size.height * 0.045))
            ribbon.blendMode = .plusLighter
            ribbon.stroke(
                path,
                with: .linearGradient(
                    Gradient(colors: [colors[band % colors.count].opacity(0.08), colors[band % colors.count].opacity(0.34 * (0.4 + glow)), .clear]),
                    startPoint: CGPoint(x: 0, y: baseY),
                    endPoint: CGPoint(x: size.width, y: baseY)
                ),
                style: StrokeStyle(lineWidth: size.height * CGFloat(0.09 + Double(band) * 0.012), lineCap: .round)
            )
        }

        drawHorizonGlow(
            context: &context,
            size: size,
            color: Color(hex: "#0F766E"),
            opacity: 0.2,
            height: 0.36
        )
    }

    // MARK: Nebula

    private func drawNebula(context: inout GraphicsContext, size: CGSize, time: Double) {
        drawNebulaClouds(
            context: &context,
            size: size,
            time: time,
            colors: [Color(hex: "#F472B6"), Color(hex: "#38BDF8"), Color(hex: "#C084FC"), Color(hex: "#8B5CF6")],
            count: 8
        )
        drawStars(
            context: &context,
            size: size,
            count: Int(120 + 130 * glow),
            time: time,
            drift: 0.002,
            twinkle: 1.1,
            opacity: 0.85
        )

        let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        var core = context
        core.addFilter(.blur(radius: min(size.width, size.height) * 0.08))
        core.fill(
            Path(ellipseIn: CGRect(
                x: center.x - size.width * 0.18,
                y: center.y - size.height * 0.14,
                width: size.width * 0.36,
                height: size.height * 0.28
            )),
            with: .color(accent.opacity(0.22 * glow))
        )
    }

    // MARK: Stars

    private func drawStarsPreset(context: inout GraphicsContext, size: CGSize, time: Double) {
        drawNebulaClouds(
            context: &context,
            size: size,
            time: time,
            colors: [Color(hex: "#1E3A8A"), Color(hex: "#312E81"), Color(hex: "#475569")],
            count: 4
        )
        drawStars(
            context: &context,
            size: size,
            count: Int(170 + 160 * glow),
            time: time,
            drift: 0.0016,
            twinkle: 1.9,
            opacity: 0.95
        )
        drawConstellation(context: &context, size: size)
        drawShootingStar(context: &context, size: size, time: time, offset: 0.1, color: .white)
    }

    // MARK: Cosmic storm

    private func drawCosmicStorm(context: inout GraphicsContext, size: CGSize, time: Double) {
        drawNebulaClouds(
            context: &context,
            size: size,
            time: time * 1.4,
            colors: [Color(hex: "#7C3AED"), Color(hex: "#4C1D95"), Color(hex: "#DB2777")],
            count: 7
        )

        let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        let unit = min(size.width, size.height)

        for index in 0..<5 {
            var path = Path()
            let radius = unit * CGFloat(0.16 + Double(index) * 0.08)
            for step in 0...40 {
                let progress = Double(step) / 40.0
                let angle = progress * .pi * 2 + time * (0.15 + Double(index) * 0.02)
                let wobble = CGFloat(1 + sin(angle * 3 + time * 0.4) * 0.08)
                let x = center.x + CGFloat(cos(angle)) * radius * wobble * 1.3
                let y = center.y + CGFloat(sin(angle)) * radius * wobble * 0.6
                if step == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }

            var ring = context
            ring.addFilter(.blur(radius: unit * 0.01))
            ring.blendMode = .plusLighter
            ring.stroke(
                path,
                with: .linearGradient(
                    Gradient(colors: [accent.opacity(0.5), secondary.opacity(0.3), .clear]),
                    startPoint: CGPoint(x: 0, y: center.y),
                    endPoint: CGPoint(x: size.width, y: center.y)
                ),
                style: StrokeStyle(lineWidth: unit * 0.008, lineCap: .round, dash: [unit * 0.04, unit * 0.018])
            )
        }

        for bolt in 0..<3 {
            let seed = Int(floor(time * 2.2)) * 17 + bolt * 43
            let startX = CGFloat(seededRandom(seed, 263)) * size.width
            let endX = startX + (CGFloat(seededRandom(seed, 269)) - 0.5) * size.width * 0.5
            var path = Path()
            path.move(to: CGPoint(x: startX, y: size.height * 0.1))
            for step in 1...10 {
                let progress = CGFloat(step) / 10.0
                let x = startX + (endX - startX) * progress + CGFloat(seededRandom(seed + step, 271) - 0.5) * 24
                let y = size.height * 0.1 + size.height * 0.62 * progress
                path.addLine(to: CGPoint(x: x, y: y))
            }
            var boltContext = context
            boltContext.addFilter(.blur(radius: 4))
            boltContext.blendMode = .plusLighter
            boltContext.stroke(path, with: .color(accent.opacity(0.55)), lineWidth: 2.4)
            context.stroke(path, with: .color(.white.opacity(0.75)), lineWidth: 1.1)
        }

        drawStars(
            context: &context,
            size: size,
            count: Int(60 + 70 * glow),
            time: time,
            drift: 0.006,
            twinkle: 0.8,
            opacity: 0.55
        )
    }

    // MARK: Solar eclipse

    private func drawSolarEclipse(context: inout GraphicsContext, size: CGSize, time: Double) {
        drawStars(
            context: &context,
            size: size,
            count: Int(60 + 80 * glow),
            time: time * 0.4,
            drift: 0.0004,
            twinkle: 0.8,
            opacity: 0.55
        )

        let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        let unit = min(size.width, size.height)
        let radius = unit * 0.18

        var corona = context
        corona.addFilter(.blur(radius: unit * 0.035))
        corona.blendMode = .plusLighter
        corona.fill(
            Path(ellipseIn: CGRect(
                x: center.x - radius * 2.1,
                y: center.y - radius * 2.1,
                width: radius * 4.2,
                height: radius * 4.2
            )),
            with: .radialGradient(
                Gradient(colors: [Color(hex: "#FDE68A").opacity(0.35 * glow), Color(hex: "#FB923C").opacity(0.16), .clear]),
                center: center,
                startRadius: radius * 0.7,
                endRadius: radius * 2.1
            )
        )

        for ray in 0..<36 {
            let angle = Double(ray) / 36.0 * .pi * 2 + time * 0.03
            let inner = radius * CGFloat(1.06 + 0.02 * sin(time * 1.4 + Double(ray)))
            let outer = radius * CGFloat(1.22 + seededRandom(ray, 277) * 0.22)
            var path = Path()
            path.move(to: CGPoint(
                x: center.x + CGFloat(cos(angle)) * inner,
                y: center.y + CGFloat(sin(angle)) * inner
            ))
            path.addLine(to: CGPoint(
                x: center.x + CGFloat(cos(angle)) * outer,
                y: center.y + CGFloat(sin(angle)) * outer
            ))
            context.stroke(
                path,
                with: .color((ray.isMultiple(of: 3) ? Color(hex: "#FDE68A") : Color(hex: "#C4B5FD")).opacity(0.45)),
                style: StrokeStyle(lineWidth: 1.3, lineCap: .round)
            )
        }

        context.fill(
            Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
            with: .radialGradient(
                Gradient(colors: [Color(hex: "#05030A"), Color.black]),
                center: center,
                startRadius: 0,
                endRadius: radius
            )
        )

        context.stroke(
            Path(ellipseIn: CGRect(
                x: center.x - radius * 1.015,
                y: center.y - radius * 1.015,
                width: radius * 2.03,
                height: radius * 2.03
            )),
            with: .color(Color(hex: "#FEF3C7").opacity(0.85)),
            lineWidth: max(1, unit * 0.005)
        )
    }

    // MARK: Purple universe

    private func drawPurpleUniverse(context: inout GraphicsContext, size: CGSize, time: Double) {
        drawNebulaClouds(
            context: &context,
            size: size,
            time: time,
            colors: [Color(hex: "#7C3AED"), Color(hex: "#C026D3"), Color(hex: "#4C1D95")],
            count: 7
        )

        let center = CGPoint(x: size.width * 0.5, y: size.height * 0.48)
        let unit = min(size.width, size.height)

        var core = context
        core.addFilter(.blur(radius: unit * 0.06))
        core.fill(
            Path(ellipseIn: CGRect(
                x: center.x - unit * 0.15,
                y: center.y - unit * 0.15,
                width: unit * 0.3,
                height: unit * 0.3
            )),
            with: .radialGradient(
                Gradient(colors: [Color(hex: "#F0ABFC").opacity(0.55), accent.opacity(0.32), .clear]),
                center: center,
                startRadius: 0,
                endRadius: unit * 0.15
            )
        )

        for ring in 0..<4 {
            var contextRing = context
            contextRing.translateBy(x: center.x, y: center.y)
            contextRing.rotate(by: .degrees(-12 + Double(ring) * 7 + time * 0.8))
            contextRing.translateBy(x: -center.x, y: -center.y)
            let radius = unit * CGFloat(0.2 + Double(ring) * 0.07)
            contextRing.stroke(
                Path(ellipseIn: CGRect(
                    x: center.x - radius * 1.4,
                    y: center.y - radius * 0.7,
                    width: radius * 2.8,
                    height: radius * 1.4
                )),
                with: .color((ring.isMultiple(of: 2) ? accent : secondary).opacity(0.12)),
                style: StrokeStyle(lineWidth: 0.8, dash: [6, 9], dashPhase: CGFloat(time * 1.5))
            )
        }

        for index in 0..<32 {
            let orbit = unit * (0.24 + seededRandom(index, 281) * 0.28)
            let angle = seededRandom(index, 283) * .pi * 2 + time * (0.1 + seededRandom(index, 293) * 0.14)
            let x = center.x + CGFloat(cos(angle)) * orbit
            let y = center.y + CGFloat(sin(angle)) * orbit * 0.5
            let dot = CGFloat(0.8 + seededRandom(index, 307) * 1.8)
            context.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: dot, height: dot)),
                with: .color((index.isMultiple(of: 3) ? Color(hex: "#F0ABFC") : Color.white).opacity(0.55))
            )
        }

        drawStars(
            context: &context,
            size: size,
            count: Int(90 + 100 * glow),
            time: time,
            drift: 0.0018,
            twinkle: 1.2,
            opacity: 0.7
        )
    }

    // MARK: Shared art

    private func drawStars(
        context: inout GraphicsContext,
        size: CGSize,
        count: Int,
        time: Double,
        drift: Double,
        twinkle: Double,
        opacity: Double
    ) {
        for index in 0..<max(0, count) {
            let baseX = seededRandom(index, 3)
            let baseY = seededRandom(index, 5)
            let horizontal = (baseX + time * drift).truncatingRemainder(dividingBy: 1)
            let x = CGFloat(horizontal) * size.width
            let y = CGFloat(baseY) * size.height
            let radius = CGFloat(0.45 + seededRandom(index, 11) * 1.35)
            let phase = seededRandom(index, 13) * .pi * 2
            let flicker = 0.55 + 0.45 * sin(time * twinkle + phase)
            let alpha = opacity * (0.4 + 0.6 * flicker) * (0.45 + seededRandom(index, 17) * 0.55)
            let color = index.isMultiple(of: 7) ? accent : (index.isMultiple(of: 5) ? secondary : Color.white)
            context.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: radius, height: radius)),
                with: .color(color.opacity(max(0.08, alpha)))
            )

            if radius > 1.5 && index.isMultiple(of: 4) {
                var sparkle = Path()
                sparkle.move(to: CGPoint(x: x - radius * 1.6, y: y))
                sparkle.addLine(to: CGPoint(x: x + radius * 1.6, y: y))
                sparkle.move(to: CGPoint(x: x, y: y - radius * 1.6))
                sparkle.addLine(to: CGPoint(x: x, y: y + radius * 1.6))
                context.stroke(
                    sparkle,
                    with: .color(color.opacity(alpha * 0.5)),
                    style: StrokeStyle(lineWidth: 0.5, lineCap: .round)
                )
            }
        }
    }

    private func drawNebulaClouds(
        context: inout GraphicsContext,
        size: CGSize,
        time: Double,
        colors: [Color],
        count: Int
    ) {
        var cloudContext = context
        cloudContext.addFilter(.blur(radius: min(size.width, size.height) * 0.06))
        cloudContext.blendMode = .plusLighter

        for index in 0..<count {
            let x = CGFloat(seededRandom(index, 19)) * size.width
            let y = CGFloat(seededRandom(index, 23)) * size.height
            let radius = min(size.width, size.height) * CGFloat(0.12 + seededRandom(index, 29) * 0.28)
            let driftX = CGFloat(sin(time * 0.08 + seededRandom(index, 31) * 6)) * size.width * 0.02
            let driftY = CGFloat(cos(time * 0.06 + seededRandom(index, 37) * 6)) * size.height * 0.018
            let color = colors[index % colors.count]
            cloudContext.fill(
                Path(ellipseIn: CGRect(
                    x: x - radius + driftX,
                    y: y - radius * 0.7 + driftY,
                    width: radius * 2,
                    height: radius * 1.4
                )),
                with: .radialGradient(
                    Gradient(colors: [color.opacity(0.12 + 0.16 * glow), .clear]),
                    center: CGPoint(x: x + driftX, y: y + driftY),
                    startRadius: 0,
                    endRadius: radius
                )
            )
        }
    }

    private func drawShootingStar(
        context: inout GraphicsContext,
        size: CGSize,
        time: Double,
        offset: Double,
        color: Color
    ) {
        let cycle = 7.5
        let phase = time.truncatingRemainder(dividingBy: cycle) / cycle
        guard phase < 0.14 else { return }

        let progress = phase / 0.14
        let startX = size.width * CGFloat(0.1 + offset * 0.35)
        let startY = size.height * 0.12
        let x = startX + size.width * CGFloat(progress) * 0.52
        let y = startY + size.height * CGFloat(progress) * 0.34
        let length = size.width * 0.1

        var path = Path()
        path.move(to: CGPoint(x: x, y: y))
        path.addLine(to: CGPoint(x: x - length, y: y - length * 0.65))
        let fade = 1 - progress

        var trail = context
        trail.addFilter(.blur(radius: 2))
        trail.stroke(path, with: .color(color.opacity(0.7 * fade)), style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
        context.fill(
            Path(ellipseIn: CGRect(x: x - 1.5, y: y - 1.5, width: 3, height: 3)),
            with: .color(.white.opacity(0.9 * fade))
        )
    }

    private func drawConstellation(context: inout GraphicsContext, size: CGSize) {
        var points: [CGPoint] = []
        for index in 0..<7 {
            points.append(CGPoint(
                x: size.width * CGFloat(0.14 + seededRandom(index, 311) * 0.7),
                y: size.height * CGFloat(0.12 + seededRandom(index, 313) * 0.55)
            ))
        }
        var path = Path()
        guard let first = points.first else { return }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        context.stroke(path, with: .color(.white.opacity(0.09)), style: StrokeStyle(lineWidth: 0.6, lineCap: .round))
        for point in points {
            context.fill(
                Path(ellipseIn: CGRect(x: point.x - 1.2, y: point.y - 1.2, width: 2.4, height: 2.4)),
                with: .color(.white.opacity(0.5))
            )
        }
    }

    private func drawAdjustments(context: inout GraphicsContext, size: CGSize) {
        if brightness > 0.001 {
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(.white.opacity(min(0.42, brightness * 0.8)))
            )
        } else if brightness < -0.001 {
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(.black.opacity(min(0.65, -brightness * 0.95)))
            )
        }

        if temperature > 0.001 {
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(Color(hex: "#FF9D5C").opacity(min(0.28, temperature * 0.25)))
            )
        } else if temperature < -0.001 {
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(Color(hex: "#5CA8FF").opacity(min(0.28, -temperature * 0.25)))
            )
        }
    }
}
