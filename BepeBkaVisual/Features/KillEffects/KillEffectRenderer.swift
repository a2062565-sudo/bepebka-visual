import SwiftUI

// MARK: - Effect stage

struct KillEffectStage: View {
    @EnvironmentObject private var store: ClientStore

    let settings: KillEffectSettings
    let startDate: Date

    private var accent: Color { Color(hex: settings.colorHex) }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let unit = min(size.width, size.height)
            let center = CGPoint(x: size.width / 2, y: size.height * 0.52)

            ZStack {
                ParticleStageBackdrop(accent: accent, showsGrid: true)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [accent.opacity(0.16), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: unit * 0.5
                        )
                    )
                    .frame(width: unit, height: unit)
                    .position(center)
                    .blur(radius: 20)

                OperativeBodyShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#242A35").opacity(0.8),
                                Color(hex: "#080A0D").opacity(0.9)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: unit * 0.18, height: unit * 0.46)
                    .position(center)
                    .opacity(settings.enabled ? 0.68 : 0.3)
                    .blur(radius: 0.4)

                OperativeBodyShape()
                    .stroke(accent.opacity(0.2), lineWidth: 0.8)
                    .frame(width: unit * 0.18, height: unit * 0.46)
                    .position(center)
                    .opacity(settings.enabled ? 0.8 : 0.2)

                if settings.enabled {
                    KillEffectRenderer(settings: settings, startDate: startDate)
                } else {
                    DisabledPreviewOverlay(
                        title: store.t("KILL EFFECTS DISABLED", "ЭФФЕКТЫ ОТКЛЮЧЕНЫ"),
                        icon: "bolt.slash.fill",
                        tint: accent
                    )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

// MARK: - Renderer

struct KillEffectRenderer: View {
    @EnvironmentObject private var store: ClientStore

    let settings: KillEffectSettings
    let startDate: Date

    var body: some View {
        TimelineView(.animation(minimumInterval: store.refreshInterval, paused: store.animationsPaused)) { timeline in
            Canvas(opaque: false, rendersAsynchronously: true) { context, size in
                let elapsed = max(0, timeline.date.timeIntervalSince(startDate))
                let animationLength = max(0.35, settings.duration / max(0.25, settings.speed))
                let cycle = animationLength + 0.75
                let localTime = elapsed.truncatingRemainder(dividingBy: cycle)
                let progress = clamp(localTime / animationLength, 0, 1)
                draw(
                    context: &context,
                    size: size,
                    progress: progress,
                    time: elapsed
                )
            }
        }
        .allowsHitTesting(false)
    }

    private var accent: Color { Color(hex: settings.colorHex) }
    private var secondary: Color { Color(hex: settings.secondaryHex) }

    private var hasGlowPass: Bool {
        switch settings.kind {
        case .pixelExplosion, .glitch, .digitalDissolve, .crystalExplosion:
            return false
        default:
            return true
        }
    }

    private func draw(
        context: inout GraphicsContext,
        size: CGSize,
        progress: Double,
        time: Double
    ) {
        let unit = min(size.width, size.height)
        let center = CGPoint(x: size.width / 2, y: size.height * 0.52)

        var effectContext = context

        if settings.shake {
            let envelope = 1 - progress
            let shakeX = sin(time * 86) * unit * 0.012 * envelope * settings.intensity
            let shakeY = cos(time * 71) * unit * 0.007 * envelope * settings.intensity
            effectContext.translateBy(x: shakeX, y: shakeY)
        }

        let zoom = CGFloat(clamp(settings.size, 0.45, 2.0))
        if abs(zoom - 1) > 0.001 {
            effectContext.translateBy(x: center.x, y: center.y)
            effectContext.scaleBy(x: zoom, y: zoom)
            effectContext.translateBy(x: -center.x, y: -center.y)
        }

        if hasGlowPass {
            var glow = effectContext
            glow.addFilter(.blur(radius: max(3, unit * 0.018)))
            glow.blendMode = .plusLighter
            glow.opacity = 0.72
            drawEffect(
                context: &glow,
                size: size,
                center: center,
                unit: unit,
                progress: progress,
                time: time
            )
        }

        drawEffect(
            context: &effectContext,
            size: size,
            center: center,
            unit: unit,
            progress: progress,
            time: time
        )

        if settings.screenFlash {
            let flash = max(0, 1 - progress / 0.16)
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(Color.white.opacity(flash * 0.2 * settings.intensity))
            )
        }
    }

    private func drawEffect(
        context: inout GraphicsContext,
        size: CGSize,
        center: CGPoint,
        unit: CGFloat,
        progress: Double,
        time: Double
    ) {
        switch settings.kind {
        case .lightning:
            drawLightning(context: &context, center: center, unit: unit, progress: progress, time: time)
        case .electricExplosion:
            drawElectricExplosion(context: &context, center: center, unit: unit, progress: progress, time: time)
        case .neonRing:
            drawNeonRing(context: &context, center: center, unit: unit, progress: progress, time: time)
        case .pixelExplosion:
            drawPixelExplosion(context: &context, center: center, unit: unit, progress: progress, time: time)
        case .galaxy:
            drawGalaxy(context: &context, center: center, unit: unit, progress: progress, time: time)
        case .fire:
            drawFire(context: &context, center: center, unit: unit, progress: progress, time: time)
        case .ice:
            drawIce(context: &context, center: center, unit: unit, progress: progress, time: time)
        case .purpleEnergy:
            drawPurpleEnergy(context: &context, center: center, unit: unit, progress: progress, time: time)
        case .glitch:
            drawGlitch(context: &context, center: center, unit: unit, progress: progress, time: time)
        case .digitalDissolve:
            drawDigitalDissolve(context: &context, center: center, unit: unit, progress: progress, time: time)
        case .crystalExplosion:
            drawCrystalExplosion(context: &context, center: center, unit: unit, progress: progress, time: time)
        case .rainbowBurst:
            drawRainbowBurst(context: &context, center: center, unit: unit, progress: progress, time: time)
        }
    }

    // MARK: Lightning

    private func drawLightning(
        context: inout GraphicsContext,
        center: CGPoint,
        unit: CGFloat,
        progress: Double,
        time: Double
    ) {
        let fade = max(0, 1 - pow(progress, 1.35))
        let flash = max(0, 1 - progress / 0.16)
        let frameSeed = Int(time * 24)
        let consistentSeed = Int(floor(time / 0.08)) * 7

        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - unit * 0.3,
                y: center.y - unit * 0.3,
                width: unit * 0.6,
                height: unit * 0.6
            )),
            with: .radialGradient(
                Gradient(colors: [accent.opacity(0.28 * flash), .clear]),
                center: center,
                startRadius: 0,
                endRadius: unit * 0.3
            )
        )

        func boltPath(seedOffset: Int) -> Path {
            let startX = center.x + (seededRandom(seedOffset, 3) - 0.5) * unit * 0.42
            let steps = 17
            var path = Path()
            path.move(to: CGPoint(x: startX, y: -unit * 0.08))

            for step in 1...steps {
                let t = CGFloat(step) / CGFloat(steps)
                let jitter = (seededRandom(frameSeed + step, seedOffset + 4) - 0.5) * unit * 0.17 * CGFloat(1 - t * 0.45)
                let x = startX + (center.x - startX) * t + jitter
                let y = -unit * 0.08 + (center.y + unit * 0.08) * t
                path.addLine(to: CGPoint(x: x, y: y))
            }
            return path
        }

        for branch in 0..<3 {
            let path = boltPath(seedOffset: consistentSeed + branch * 13)
            context.stroke(
                path,
                with: .color(branch == 1 ? secondary.opacity(0.22 * fade) : accent.opacity(0.36 * fade)),
                style: StrokeStyle(lineWidth: branch == 1 ? unit * 0.016 : unit * 0.009, lineCap: .round)
            )
        }

        let mainBolt = boltPath(seedOffset: consistentSeed)
        context.stroke(
            mainBolt,
            with: .color(accent.opacity(0.7 * fade)),
            style: StrokeStyle(lineWidth: unit * 0.022, lineCap: .round, lineJoin: .round)
        )
        context.stroke(
            mainBolt,
            with: .color(Color.white.opacity(0.92 * fade)),
            style: StrokeStyle(lineWidth: unit * 0.005, lineCap: .round, lineJoin: .round)
        )

        var branches = Path()
        for branch in 0..<5 {
            let startT = 0.24 + CGFloat(branch) * 0.12
            let start = CGPoint(
                x: center.x + (seededRandom(frameSeed + branch, 20) - 0.5) * unit * 0.18,
                y: -unit * 0.08 + (center.y + unit * 0.08) * startT
            )
            let direction: CGFloat = branch.isMultiple(of: 2) ? 1 : -1
            branches.move(to: start)
            branches.addLine(to: CGPoint(
                x: start.x + direction * unit * (0.04 + seededRandom(branch, 21) * 0.1),
                y: start.y + unit * (0.035 + seededRandom(branch, 22) * 0.08)
            ))
        }
        context.stroke(
            branches,
            with: .color(accent.opacity(0.45 * fade)),
            style: StrokeStyle(lineWidth: unit * 0.004, lineCap: .round)
        )

        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - unit * 0.025 * (0.6 + flash),
                y: center.y - unit * 0.025 * (0.6 + flash),
                width: unit * 0.05 * (0.6 + flash),
                height: unit * 0.05 * (0.6 + flash)
            )),
            with: .color(Color.white.opacity(0.85 * max(fade, flash)))
        )
    }

    // MARK: Electric Explosion

    private func drawElectricExplosion(
        context: inout GraphicsContext,
        center: CGPoint,
        unit: CGFloat,
        progress: Double,
        time: Double
    ) {
        let fade = 1 - progress
        let flash = max(0, 1 - progress / 0.2)
        let q = easeOutCubic(progress)
        let count = Int(70 * settings.intensity) + 24

        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - unit * 0.2,
                y: center.y - unit * 0.2,
                width: unit * 0.4,
                height: unit * 0.4
            )),
            with: .radialGradient(
                Gradient(colors: [Color.white.opacity(0.8 * flash), accent.opacity(0.35 * fade), .clear]),
                center: center,
                startRadius: 0,
                endRadius: unit * 0.2
            )
        )

        context.stroke(
            Path(ellipseIn: CGRect(
                x: center.x - unit * 0.26 * q,
                y: center.y - unit * 0.18 * q,
                width: unit * 0.52 * q,
                height: unit * 0.36 * q
            )),
            with: .color(accent.opacity(0.28 * fade)),
            lineWidth: unit * 0.004
        )

        for index in 0..<count {
            let angle = seededRandom(index, 31) * .pi * 2
            let inner = unit * (0.025 + seededRandom(index, 32) * 0.11) * q
            let length = unit * (0.035 + seededRandom(index, 33) * 0.13) * (0.4 + q)
            let start = CGPoint(
                x: center.x + cos(angle) * inner,
                y: center.y + sin(angle) * inner
            )
            let end = CGPoint(
                x: center.x + cos(angle + 0.2) * (inner + length),
                y: center.y + sin(angle + 0.2) * (inner + length)
            )
            var path = Path()
            path.move(to: start)
            path.addLine(to: end)

            let color = index.isMultiple(of: 3) ? secondary : accent
            context.stroke(
                path,
                with: .color(color.opacity((0.28 + seededRandom(index, 34) * 0.55) * fade)),
                style: StrokeStyle(
                    lineWidth: unit * (0.002 + seededRandom(index, 35) * 0.004),
                    lineCap: .round
                )
            )
        }

        for arc in 0..<4 {
            let angle = seededRandom(arc, 40) * .pi * 2 + progress * 2
            var path = Path()
            for step in 0...5 {
                let radius = unit * (0.08 + CGFloat(step) * 0.028 + q * 0.12)
                let jitter = (seededRandom(arc, step + 41) - 0.5) * 0.3
                path.addLine(to: CGPoint(
                    x: center.x + cos(angle + jitter) * radius,
                    y: center.y + sin(angle + jitter) * radius
                ))
            }
            context.stroke(
                path,
                with: .color(secondary.opacity(0.22 * fade)),
                lineWidth: unit * 0.003
            )
        }
        _ = time
    }

    // MARK: Neon Ring

    private func drawNeonRing(
        context: inout GraphicsContext,
        center: CGPoint,
        unit: CGFloat,
        progress: Double,
        time: Double
    ) {
        let fade = 1 - progress

        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - unit * 0.14,
                y: center.y - unit * 0.09,
                width: unit * 0.28,
                height: unit * 0.18
            )),
            with: .radialGradient(
                Gradient(colors: [accent.opacity(0.42 * fade), .clear]),
                center: center,
                startRadius: 0,
                endRadius: unit * 0.14
            )
        )

        for ring in 0..<4 {
            let delay = Double(ring) * 0.085
            let local = clamp((progress - delay) / 0.72, 0, 1)
            guard local > 0, local < 1 else { continue }

            let radius = unit * (0.04 + 0.42 * easeOutCubic(local))
            let alpha = fade * (1 - local) * (ring == 0 ? 1 : 0.55)
            let color = ring.isMultiple(of: 2) ? accent : secondary

            context.stroke(
                Path(ellipseIn: CGRect(
                    x: center.x - radius,
                    y: center.y - radius * 0.62,
                    width: radius * 2,
                    height: radius * 1.24
                )),
                with: .color(color.opacity(alpha)),
                style: StrokeStyle(
                    lineWidth: max(0.5, unit * 0.012 * (1 - local)),
                    lineCap: .round
                )
            )
        }

        let tickCount = 30
        for tick in 0..<tickCount {
            let angle = Double(tick) / Double(tickCount) * .pi * 2 + time * 0.4
            let radius = unit * (0.12 + 0.32 * easeOutCubic(progress))
            let length = unit * 0.02 * (1 - progress)
            let color = tick.isMultiple(of: 3) ? secondary : accent
            var path = Path()
            path.move(to: CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius))
            path.addLine(to: CGPoint(x: center.x + cos(angle) * (radius + length), y: center.y + sin(angle) * (radius + length)))
            context.stroke(path, with: .color(color.opacity(0.65 * fade)), lineWidth: unit * 0.0025)
        }

        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - unit * 0.012,
                y: center.y - unit * 0.012,
                width: unit * 0.024,
                height: unit * 0.024
            )),
            with: .color(Color.white.opacity(0.9 * fade))
        )
    }

    // MARK: Pixel Explosion

    private func drawPixelExplosion(
        context: inout GraphicsContext,
        center: CGPoint,
        unit: CGFloat,
        progress: Double,
        time: Double
    ) {
        let q = easeOutCubic(progress)
        let fade = 1 - progress
        let count = Int(130 * settings.intensity) + 36

        let flash = max(0, 1 - progress / 0.14)
        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - unit * 0.14,
                y: center.y - unit * 0.14,
                width: unit * 0.28,
                height: unit * 0.28
            )),
            with: .radialGradient(
                Gradient(colors: [Color.white.opacity(0.72 * flash), accent.opacity(0.25 * fade), .clear]),
                center: center,
                startRadius: 0,
                endRadius: unit * 0.14
            )
        )

        for index in 0..<count {
            let angle = seededRandom(index, 51) * .pi * 2
            let speed = 0.13 + seededRandom(index, 52) * 0.5
            let spread = unit * 0.06
            let start = CGPoint(
                x: center.x + (seededRandom(index, 56) - 0.5) * spread,
                y: center.y + (seededRandom(index, 57) - 0.5) * spread * 1.5
            )
            let distance = unit * speed * q
            let gravity = unit * 0.2 * q * q
            var local = context
            local.translateBy(
                x: start.x + cos(angle) * distance,
                y: start.y + sin(angle) * distance + gravity
            )
            local.rotate(by: .radians(angle + q * 2))

            let side = unit * (0.004 + seededRandom(index, 53) * 0.008) * (0.65 + (1 - q) * 0.55)
            let rect = CGRect(x: -side / 2, y: -side / 2, width: side, height: side)
            let colorIndex = index % 4
            let color: Color = colorIndex == 0 ? .white : (colorIndex == 1 ? secondary : accent)
            local.fill(
                Path(rect),
                with: .color(color.opacity((0.35 + seededRandom(index, 54) * 0.6) * fade))
            )
        }

        for index in 0..<12 {
            let y = center.y + (seededRandom(index, 61) - 0.5) * unit * 0.4
            let width = unit * (0.08 + seededRandom(index, 62) * 0.3) * q
            var path = Path()
            path.move(to: CGPoint(x: center.x - width / 2, y: y))
            path.addLine(to: CGPoint(x: center.x + width / 2, y: y))
            context.stroke(
                path,
                with: .color((index.isMultiple(of: 2) ? accent : secondary).opacity(0.13 * fade)),
                lineWidth: 0.8
            )
        }
        _ = time
    }

    // MARK: Galaxy

    private func drawGalaxy(
        context: inout GraphicsContext,
        center: CGPoint,
        unit: CGFloat,
        progress: Double,
        time: Double
    ) {
        let q = easeOutCubic(progress)
        let fade = 1 - progress
        let coreRadius = unit * (0.035 + 0.08 * q)

        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - coreRadius * 2.6,
                y: center.y - coreRadius * 2.6,
                width: coreRadius * 5.2,
                height: coreRadius * 5.2
            )),
            with: .radialGradient(
                Gradient(colors: [
                    Color.white.opacity(0.9 * fade),
                    accent.opacity(0.55 * fade),
                    secondary.opacity(0.16 * fade),
                    .clear
                ]),
                center: center,
                startRadius: 0,
                endRadius: coreRadius * 2.6
            )
        )

        let particleCount = Int(190 * settings.intensity) + 60
        for index in 0..<particleCount {
            let seed = seededRandom(index, 71)
            let radiusBase = pow(seed, 0.54)
            let radius = unit * (0.02 + 0.4 * radiusBase) * (0.3 + q * 0.82)
            let angle = seed * .pi * 6 + progress * 3.4 + radiusBase * 3.5
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius * 0.48

            let dotRadius = unit * (0.0018 + seededRandom(index, 72) * 0.0038) * (1 - progress * 0.45)
            let colorIndex = index % 5
            let color: Color = colorIndex == 0 ? .white : (colorIndex < 3 ? accent : secondary)
            context.fill(
                Path(ellipseIn: CGRect(
                    x: x - dotRadius,
                    y: y - dotRadius,
                    width: dotRadius * 2,
                    height: dotRadius * 2
                )),
                with: .color(color.opacity((0.25 + seededRandom(index, 73) * 0.7) * fade))
            )
        }

        for ring in 0..<3 {
            let radius = unit * (0.16 + Double(ring) * 0.1) * (0.4 + q)
            context.stroke(
                Path(ellipseIn: CGRect(
                    x: center.x - radius,
                    y: center.y - radius * 0.42,
                    width: radius * 2,
                    height: radius * 0.84
                )),
                with: .color((ring == 1 ? secondary : accent).opacity(0.08 * fade)),
                lineWidth: unit * 0.006
            )
        }
        _ = time
    }

    // MARK: Fire

    private func drawFire(
        context: inout GraphicsContext,
        center: CGPoint,
        unit: CGFloat,
        progress: Double,
        time: Double
    ) {
        let q = easeOutCubic(progress)
        let fade = 1 - progress
        let fadeF = CGFloat(fade)
        let rise = unit * 0.1 * q

        let fireballCenters: [(CGPoint, CGFloat)] = [
            (CGPoint(x: center.x, y: center.y - rise), unit * (0.18 + 0.16 * q)),
            (CGPoint(x: center.x - unit * 0.06, y: center.y - unit * 0.03 - rise), unit * (0.12 + 0.11 * q)),
            (CGPoint(x: center.x + unit * 0.07, y: center.y + unit * 0.01 - rise), unit * (0.13 + 0.1 * q)),
            (CGPoint(x: center.x, y: center.y + unit * 0.08), unit * (0.1 + 0.08 * q))
        ]

        for (index, entry) in fireballCenters.enumerated() {
            let (point, radius) = entry
            let alpha = (index == 0 ? 0.6 : 0.32) * fadeF
            context.fill(
                Path(ellipseIn: CGRect(
                    x: point.x - radius,
                    y: point.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )),
                with: .radialGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.55 * alpha),
                        secondary.opacity(0.55 * alpha),
                        accent.opacity(0.3 * alpha),
                        .clear
                    ]),
                    center: point,
                    startRadius: 0,
                    endRadius: radius
                )
            )
        }

        let emberCount = Int(80 * settings.intensity) + 24
        for index in 0..<emberCount {
            let seed = seededRandom(index, 81)
            let startX = center.x + (seededRandom(index, 82) - 0.5) * unit * 0.22
            let startY = center.y + (seededRandom(index, 83) - 0.4) * unit * 0.12
            let travel = unit * (0.18 + seed * 0.42) * q
            let sway = sin(time * 2 + seed * 12) * unit * 0.03 * q
            let x = startX + sway
            let y = startY - travel
            let radius = unit * (0.002 + seededRandom(index, 84) * 0.004) * (1 - progress * 0.6)
            let color: Color = index % 3 == 0 ? .white : (index % 3 == 1 ? secondary : accent)

            context.fill(
                Path(ellipseIn: CGRect(
                    x: x - radius,
                    y: y - radius * 1.8,
                    width: radius * 2,
                    height: radius * 3.4
                )),
                with: .color(color.opacity((0.3 + seededRandom(index, 85) * 0.6) * fade))
            )
        }
    }

    // MARK: Ice

    private func drawIce(
        context: inout GraphicsContext,
        center: CGPoint,
        unit: CGFloat,
        progress: Double,
        time: Double
    ) {
        let q = easeOutCubic(progress)
        let fade = 1 - progress
        let flash = max(0, 1 - progress / 0.18)

        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - unit * 0.17,
                y: center.y - unit * 0.17,
                width: unit * 0.34,
                height: unit * 0.34
            )),
            with: .radialGradient(
                Gradient(colors: [
                    Color.white.opacity(0.7 * flash),
                    secondary.opacity(0.35 * fade),
                    accent.opacity(0.18 * fade),
                    .clear
                ]),
                center: center,
                startRadius: 0,
                endRadius: unit * 0.17
            )
        )

        for crack in 0..<20 {
            let angle = seededRandom(crack, 91) * .pi * 2
            let length = unit * (0.08 + seededRandom(crack, 92) * 0.35) * q
            var path = Path()
            path.move(to: center)
            let mid = CGPoint(
                x: center.x + cos(angle + 0.1) * length * 0.55,
                y: center.y + sin(angle + 0.1) * length * 0.55
            )
            path.addLine(to: mid)
            path.addLine(to: CGPoint(
                x: center.x + cos(angle) * length,
                y: center.y + sin(angle) * length
            ))
            context.stroke(
                path,
                with: .color((crack % 3 == 0 ? Color.white : accent).opacity(0.32 * fade)),
                lineWidth: unit * 0.0018
            )
        }

        for shard in 0..<30 {
            let angle = seededRandom(shard, 93) * .pi * 2
            let distance = unit * (0.05 + seededRandom(shard, 94) * 0.34) * q
            let size = unit * (0.018 + seededRandom(shard, 95) * 0.028) * (1 - progress * 0.5)
            var local = context
            local.translateBy(
                x: center.x + cos(angle) * distance,
                y: center.y + sin(angle) * distance
            )
            local.rotate(by: .radians(angle + progress * 2))

            var shardPath = Path()
            shardPath.move(to: CGPoint(x: -size * 0.6, y: size * 1.6))
            shardPath.addLine(to: CGPoint(x: size * 0.7, y: size * 1.4))
            shardPath.addLine(to: CGPoint(x: 0, y: -size * 2.2))
            shardPath.closeSubpath()

            local.fill(
                shardPath,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.5 * fade),
                        secondary.opacity(0.35 * fade),
                        accent.opacity(0.22 * fade)
                    ]),
                    startPoint: CGPoint(x: 0, y: -size * 2),
                    endPoint: CGPoint(x: 0, y: size)
                )
            )
            local.stroke(
                shardPath,
                with: .color(Color.white.opacity(0.25 * fade)),
                lineWidth: 0.6
            )
        }

        for dust in 0..<36 {
            let angle = seededRandom(dust, 96) * .pi * 2
            let distance = unit * (0.04 + seededRandom(dust, 97) * 0.32) * q
            let radius = unit * (0.0015 + seededRandom(dust, 98) * 0.003)
            let point = CGPoint(
                x: center.x + cos(angle) * distance,
                y: center.y + sin(angle) * distance
            )
            context.fill(
                Path(ellipseIn: CGRect(
                    x: point.x - radius,
                    y: point.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )),
                with: .color(Color.white.opacity(0.4 * fade))
            )
        }
        _ = time
    }

    // MARK: Purple Energy

    private func drawPurpleEnergy(
        context: inout GraphicsContext,
        center: CGPoint,
        unit: CGFloat,
        progress: Double,
        time: Double
    ) {
        let q = easeOutCubic(progress)
        let fade = 1 - progress

        let beamWidth = unit * 0.09 * (1 - q * 0.6)
        let beamRect = CGRect(
            x: center.x - beamWidth / 2,
            y: center.y - unit * 0.34,
            width: beamWidth,
            height: unit * 0.68
        )
        context.fill(
            Path(roundedRect: beamRect, cornerRadius: beamWidth / 2),
            with: .linearGradient(
                Gradient(colors: [
                    .clear,
                    accent.opacity(0.2 * fade),
                    Color.white.opacity(0.55 * fade),
                    secondary.opacity(0.2 * fade),
                    .clear
                ]),
                startPoint: CGPoint(x: beamRect.midX, y: beamRect.minY),
                endPoint: CGPoint(x: beamRect.midX, y: beamRect.maxY)
            )
        )

        let ringCount = 4
        for ring in 0..<ringCount {
            let local = clamp((progress - Double(ring) * 0.06) / 0.7, 0, 1)
            guard local > 0, local < 1 else { continue }
            let radius = unit * (0.06 + 0.28 * local)
            context.stroke(
                Path(ellipseIn: CGRect(
                    x: center.x - radius,
                    y: center.y - radius * 0.4,
                    width: radius * 2,
                    height: radius * 0.8
                )),
                with: .color(accent.opacity((1 - local) * 0.5 * fade)),
                lineWidth: unit * 0.006 * (1 - local)
            )
        }

        let orbCount = Int(86 * settings.intensity) + 24
        for index in 0..<orbCount {
            let seed = seededRandom(index, 101)
            let angle = seed * .pi * 2 + time * 1.2
            let radius = unit * (0.04 + seededRandom(index, 102) * 0.16) * (1 - q * 0.25)
            let vertical = (seededRandom(index, 103) - 0.5) * unit * 0.52 * (1 - q * 0.35)
            let x = center.x + cos(angle) * radius
            let y = center.y + vertical - q * unit * 0.06
            let dot = unit * (0.002 + seededRandom(index, 104) * 0.004) * (1 - progress * 0.5)
            let color = index % 4 == 0 ? Color.white : (index % 2 == 0 ? secondary : accent)

            context.fill(
                Path(ellipseIn: CGRect(x: x - dot, y: y - dot, width: dot * 2, height: dot * 2)),
                with: .color(color.opacity((0.3 + seededRandom(index, 105) * 0.6) * fade))
            )
        }

        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - unit * 0.055,
                y: center.y - unit * 0.055,
                width: unit * 0.11,
                height: unit * 0.11
            )),
            with: .radialGradient(
                Gradient(colors: [Color.white.opacity(0.9 * fade), accent.opacity(0.4 * fade), .clear]),
                center: center,
                startRadius: 0,
                endRadius: unit * 0.055
            )
        )
    }

    // MARK: Glitch

    private func drawGlitch(
        context: inout GraphicsContext,
        center: CGPoint,
        unit: CGFloat,
        progress: Double,
        time: Double
    ) {
        let fade = 1 - progress
        let flicker = 0.5 + 0.5 * abs(sin(time * 42))
        let bodyRect = CGRect(
            x: center.x - unit * 0.09,
            y: center.y - unit * 0.23,
            width: unit * 0.18,
            height: unit * 0.46
        )
        let bodyPath = OperativeBodyShape().path(in: bodyRect)
        let frame = Int(time * 30)

        var cyanBody = context
        cyanBody.translateBy(x: unit * 0.014 * flicker, y: 0)
        cyanBody.fill(bodyPath, with: .color(Color(hex: "#22D3EE").opacity(0.32 * fade)))

        var pinkBody = context
        pinkBody.translateBy(x: -unit * 0.014 * flicker, y: 0)
        pinkBody.fill(bodyPath, with: .color(Color(hex: "#F472B6").opacity(0.3 * fade)))

        context.fill(bodyPath, with: .color(accent.opacity(0.22 * fade)))

        var clipped = context
        clipped.clip(to: bodyPath)

        let sliceCount = 22
        for slice in 0..<sliceCount {
            let y = bodyRect.minY + bodyRect.height * CGFloat(slice) / CGFloat(sliceCount)
            let offset = (seededRandom(frame + slice, 111) - 0.5) * unit * 0.14 * (0.4 + progress)
            let height = bodyRect.height / CGFloat(sliceCount) * (0.35 + seededRandom(slice, 112) * 0.6)
            let colorIndex = slice % 4
            let color: Color = colorIndex == 0
                ? Color.white
                : (colorIndex == 1 ? Color(hex: "#22D3EE") : (colorIndex == 2 ? Color(hex: "#F472B6") : accent))

            clipped.fill(
                Path(CGRect(
                    x: bodyRect.minX - unit * 0.03 + offset,
                    y: y,
                    width: bodyRect.width + unit * 0.06,
                    height: height
                )),
                with: .color(color.opacity((0.16 + seededRandom(slice, 113) * 0.48) * fade * flicker))
            )
        }

        for line in 0..<16 {
            let y = center.y + (seededRandom(line, 114) - 0.5) * unit * 0.62
            let width = unit * (0.05 + seededRandom(line, 115) * 0.4)
            let x = center.x + (seededRandom(frame + line, 116) - 0.5) * unit * 0.26
            var path = Path()
            path.move(to: CGPoint(x: x - width / 2, y: y))
            path.addLine(to: CGPoint(x: x + width / 2, y: y))
            context.stroke(
                path,
                with: .color((line % 2 == 0 ? Color.white : accent).opacity(0.12 * fade * flicker)),
                lineWidth: 0.7
            )
        }

        context.stroke(
            bodyPath,
            with: .color(accent.opacity(0.45 * fade * flicker)),
            lineWidth: 0.8
        )
    }

    // MARK: Digital Dissolve

    private func drawDigitalDissolve(
        context: inout GraphicsContext,
        center: CGPoint,
        unit: CGFloat,
        progress: Double,
        time: Double
    ) {
        let fade = 1 - progress
        let bodyRect = CGRect(
            x: center.x - unit * 0.09,
            y: center.y - unit * 0.23,
            width: unit * 0.18,
            height: unit * 0.46
        )
        let bodyPath = OperativeBodyShape().path(in: bodyRect)
        let columns = 16
        let rows = 30
        let cellWidth = bodyRect.width / CGFloat(columns)
        let cellHeight = bodyRect.height / CGFloat(rows)
        let flicker = 0.75 + 0.25 * abs(sin(time * 18))

        for row in 0..<rows {
            for column in 0..<columns {
                let cellX = bodyRect.minX + CGFloat(column) * cellWidth
                let cellY = bodyRect.minY + CGFloat(row) * cellHeight
                let centerPoint = CGPoint(x: cellX + cellWidth / 2, y: cellY + cellHeight / 2)
                guard bodyPath.contains(centerPoint) else { continue }

                let seed = seededRandom(row * columns + column, 121)
                guard seed > progress else { continue }

                let drift = unit * 0.07 * progress * (0.4 + seed)
                let sway = sin(time * 2 + seed * 8) * unit * 0.008 * progress
                let colorIndex = (row + column) % 7
                let color: Color = colorIndex == 0
                    ? Color.white
                    : (colorIndex == 1 ? secondary : accent)

                let rect = CGRect(
                    x: cellX + cellWidth * 0.12 + sway,
                    y: cellY - drift + cellHeight * 0.12,
                    width: cellWidth * 0.76,
                    height: cellHeight * 0.76
                )

                context.fill(
                    Path(rect),
                    with: .color(color.opacity((0.12 + (1 - progress) * 0.55) * flicker))
                )
            }
        }

        let scanY = bodyRect.minY + bodyRect.height * (time.truncatingRemainder(dividingBy: 1.4) / 1.4)
        var scanLine = Path()
        scanLine.move(to: CGPoint(x: bodyRect.minX - unit * 0.03, y: scanY))
        scanLine.addLine(to: CGPoint(x: bodyRect.maxX + unit * 0.03, y: scanY))
        context.stroke(
            scanLine,
            with: .color(Color.white.opacity(0.35 * fade)),
            lineWidth: unit * 0.003
        )
        context.stroke(
            bodyPath,
            with: .color(accent.opacity(0.24 * fade)),
            lineWidth: 0.8
        )
    }

    // MARK: Crystal Explosion

    private func drawCrystalExplosion(
        context: inout GraphicsContext,
        center: CGPoint,
        unit: CGFloat,
        progress: Double,
        time: Double
    ) {
        let q = easeOutCubic(progress)
        let fade = 1 - progress
        let flash = max(0, 1 - progress / 0.18)

        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - unit * 0.18,
                y: center.y - unit * 0.18,
                width: unit * 0.36,
                height: unit * 0.36
            )),
            with: .radialGradient(
                Gradient(colors: [Color.white.opacity(0.75 * flash), accent.opacity(0.32 * fade), .clear]),
                center: center,
                startRadius: 0,
                endRadius: unit * 0.18
            )
        )

        let shardCount = Int(26 * settings.intensity) + 10
        for index in 0..<shardCount {
            let angle = seededRandom(index, 131) * .pi * 2
            let distance = unit * (0.05 + seededRandom(index, 132) * 0.36) * q
            let size = unit * (0.02 + seededRandom(index, 133) * 0.04) * (1 - progress * 0.45)
            var local = context
            local.translateBy(
                x: center.x + cos(angle) * distance,
                y: center.y + sin(angle) * distance
            )
            local.rotate(by: .radians(angle + progress * 1.5 + seededRandom(index, 134) * 2))

            var shard = Path()
            let sides = 4 + (index % 2)
            for vertex in 0..<sides {
                let vertexAngle = Double(vertex) / Double(sides) * .pi * 2
                let jitter = 0.7 + seededRandom(index * 7 + vertex, 135) * 0.5
                let point = CGPoint(
                    x: cos(vertexAngle) * size * jitter,
                    y: sin(vertexAngle) * size * jitter * 1.4
                )
                if vertex == 0 {
                    shard.move(to: point)
                } else {
                    shard.addLine(to: point)
                }
            }
            shard.closeSubpath()

            local.fill(
                shard,
                with: .linearGradient(
                    Gradient(colors: [
                        accent.opacity(0.75 * fade),
                        secondary.opacity(0.35 * fade),
                        Color.white.opacity(0.3 * fade)
                    ]),
                    startPoint: CGPoint(x: -size, y: -size),
                    endPoint: CGPoint(x: size, y: size)
                )
            )
            local.stroke(
                shard,
                with: .color(Color.white.opacity(0.35 * fade)),
                lineWidth: 0.6
            )

            var facet = Path()
            facet.move(to: CGPoint(x: 0, y: -size * 1.25))
            facet.addLine(to: CGPoint(x: size * 0.6, y: size * 0.7))
            local.stroke(
                facet,
                with: .color(Color.white.opacity(0.22 * fade)),
                lineWidth: 0.5
            )
        }

        for ray in 0..<14 {
            let angle = Double(ray) / 14 * .pi * 2 + time * 0.15
            var path = Path()
            path.move(to: center)
            path.addLine(to: CGPoint(
                x: center.x + cos(angle) * unit * 0.4 * q,
                y: center.y + sin(angle) * unit * 0.4 * q
            ))
            context.stroke(
                path,
                with: .color(accent.opacity(0.09 * fade)),
                lineWidth: unit * 0.002
            )
        }
    }

    // MARK: Rainbow Burst

    private func drawRainbowBurst(
        context: inout GraphicsContext,
        center: CGPoint,
        unit: CGFloat,
        progress: Double,
        time: Double
    ) {
        let q = easeOutCubic(progress)
        let fade = 1 - progress
        let flash = max(0, 1 - progress / 0.15)
        var rainbow = context
        rainbow.blendMode = .plusLighter

        rainbow.fill(
            Path(ellipseIn: CGRect(
                x: center.x - unit * 0.16,
                y: center.y - unit * 0.16,
                width: unit * 0.32,
                height: unit * 0.32
            )),
            with: .radialGradient(
                Gradient(colors: [Color.white.opacity(0.8 * flash), .clear]),
                center: center,
                startRadius: 0,
                endRadius: unit * 0.16
            )
        )

        let rayCount = 22
        for ray in 0..<rayCount {
            let angle = Double(ray) / Double(rayCount) * .pi * 2 + time * 0.25
            let innerRadius = unit * 0.03
            let outerRadius = unit * (0.1 + 0.45 * q) * (0.85 + seededRandom(ray, 141) * 0.3)
            let halfWidth = 0.11 / Double(rayCount) * .pi * 2 * 2.4
            let hue = Double(ray) / Double(rayCount)

            var path = Path()
            path.move(to: CGPoint(
                x: center.x + cos(angle - halfWidth) * innerRadius,
                y: center.y + sin(angle - halfWidth) * innerRadius
            ))
            path.addLine(to: CGPoint(
                x: center.x + cos(angle - halfWidth * 0.45) * outerRadius,
                y: center.y + sin(angle - halfWidth * 0.45) * outerRadius
            ))
            path.addLine(to: CGPoint(
                x: center.x + cos(angle + halfWidth * 0.45) * outerRadius,
                y: center.y + sin(angle + halfWidth * 0.45) * outerRadius
            ))
            path.addLine(to: CGPoint(
                x: center.x + cos(angle + halfWidth) * innerRadius,
                y: center.y + sin(angle + halfWidth) * innerRadius
            ))
            path.closeSubpath()

            let color = Color(hue: hue, saturation: 0.8, brightness: 1)
            rainbow.fill(path, with: .color(color.opacity(0.22 * fade)))
        }

        for ring in 0..<3 {
            let radius = unit * (0.08 + Double(ring) * 0.075 + q * 0.24)
            rainbow.stroke(
                Path(ellipseIn: CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )),
                with: .color(Color.white.opacity((0.18 - Double(ring) * 0.04) * fade)),
                lineWidth: unit * 0.0025
            )
        }

        rainbow.fill(
            Path(ellipseIn: CGRect(
                x: center.x - unit * 0.02,
                y: center.y - unit * 0.02,
                width: unit * 0.04,
                height: unit * 0.04
            )),
            with: .color(Color.white.opacity(0.9 * fade))
        )
    }
}
