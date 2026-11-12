import SwiftUI

// MARK: - Render configuration

struct ParticleRenderConfig {
    var kind: ParticleKind
    var count: Int
    var speed: Double
    var size: Double
    var opacity: Double
    var color: Color
    var secondaryColor: Color
    var direction: ParticleDirection
    var glow: Bool
    var trail: Bool

    init(settings: ParticleSettings, density: Double = 1, cap: Int = 180) {
        kind = settings.kind
        let scaledCount = Int((settings.count * density).rounded())
        count = max(1, min(cap, scaledCount))
        speed = settings.speed
        size = settings.size
        opacity = settings.opacity
        color = Color(hex: settings.colorHex)
        secondaryColor = Color(hex: settings.secondaryHex)
        direction = settings.direction
        glow = settings.glow
        trail = settings.trail
    }

    static func thumbnail(kind: ParticleKind, settings: ParticleSettings, density: Double) -> ParticleRenderConfig {
        var copy = settings
        copy.kind = kind
        copy.count = 22
        copy.speed = max(0.35, settings.speed * 0.8)
        copy.size = max(0.65, settings.size)
        copy.opacity = max(0.7, settings.opacity)
        copy.glow = true
        return ParticleRenderConfig(settings: copy, density: density, cap: 22)
    }
}

// MARK: - Particle field

struct ParticleFieldView: View {
    @EnvironmentObject private var store: ClientStore

    let config: ParticleRenderConfig
    var paused: Bool = false
    var minimumInterval: Double? = nil
    var compact: Bool = false

    private var interval: Double {
        minimumInterval ?? store.refreshInterval
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: interval, paused: paused || store.animationsPaused)) { timeline in
            Canvas(opaque: false, rendersAsynchronously: true) { context, size in
                render(context: &context, size: size, time: timeline.date.timeIntervalSinceReferenceDate)
            }
        }
        .allowsHitTesting(false)
    }

    private func render(context: inout GraphicsContext, size: CGSize, time: Double) {
        guard size.width > 2, size.height > 2, config.count > 0 else { return }

        let effectiveTime = time * max(0.1, config.speed)

        if config.glow {
            var glowContext = context
            glowContext.addFilter(.blur(radius: compact ? 4 : 7))
            glowContext.blendMode = .plusLighter
            drawParticles(
                context: &glowContext,
                size: size,
                time: effectiveTime,
                halo: true
            )
        }

        drawParticles(
            context: &context,
            size: size,
            time: effectiveTime,
            halo: false
        )
    }

    private func drawParticles(
        context: inout GraphicsContext,
        size: CGSize,
        time: Double,
        halo: Bool
    ) {
        let count = max(1, config.count)
        let scale = max(0.44, min(1.35, min(size.width, size.height) / 300.0))

        for index in 0..<count {
            let state = particleState(index: index, time: time, size: size)
            let radius = particleBaseSize(config.kind) * CGFloat(config.size) * scale * state.sizeVariance
            let isSecondary = seededRandom(index, 9) > 0.68
            let baseColor = isSecondary ? config.secondaryColor : config.color
            let alpha = state.alpha * config.opacity

            guard alpha > 0.01 else { continue }

            if halo {
                let haloRadius = radius * (config.kind == .fireflies ? 3.2 : 2.0)
                let haloOpacity = min(0.55, alpha * 0.42)
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: state.point.x - haloRadius,
                        y: state.point.y - haloRadius,
                        width: haloRadius * 2,
                        height: haloRadius * 2
                    )),
                    with: .color(baseColor.opacity(haloOpacity))
                )
                continue
            }

            if config.trail {
                drawTrail(
                    context: &context,
                    index: index,
                    time: time,
                    size: size,
                    color: baseColor,
                    radius: radius,
                    alpha: alpha
                )
            }

            drawParticle(
                context: &context,
                index: index,
                point: state.point,
                angle: state.angle,
                radius: radius,
                color: baseColor,
                alpha: alpha
            )
        }
    }

    private func particleState(index: Int, time: Double, size: CGSize) -> ParticleState {
        let p1 = seededRandom(index, 1)
        let p2 = seededRandom(index, 2)
        let p3 = seededRandom(index, 3)
        let p4 = seededRandom(index, 4)
        let p5 = seededRandom(index, 5)

        let width = Double(size.width)
        let height = Double(size.height)

        var point = CGPoint.zero
        var angle = p4 * .pi * 2
        var alpha = 0.38 + p5 * 0.62
        let motion = 0.012 + p3 * 0.035

        switch config.direction {
        case .swirl:
            let radius = min(width, height) * (0.08 + p2 * 0.46)
            let orbit = p1 * .pi * 2 + time * (0.18 + p3 * 0.3)
            let wobble = 1 + sin(time * 0.7 + p4 * .pi * 2) * 0.11
            point = CGPoint(
                x: CGFloat(width / 2 + cos(orbit) * radius * wobble),
                y: CGFloat(height / 2 + sin(orbit) * radius * wobble)
            )
            angle = orbit + .pi / 2

        case .down, .up:
            let travel = (p2 + time * motion).truncatingRemainder(dividingBy: 1)
            let baseY = config.direction == .down ? travel : 1 - travel
            let sway = sin(time * 0.9 + p1 * .pi * 2) * (width * 0.018 + p4 * 10)
            point = CGPoint(
                x: CGFloat(p1 * width + sway),
                y: CGFloat(baseY * height)
            )
            angle += time * (0.2 + p4 * 0.6)

        case .left, .right:
            let travel = (p2 + time * motion).truncatingRemainder(dividingBy: 1)
            let baseX = config.direction == .right ? travel : 1 - travel
            let sway = sin(time * 0.8 + p1 * .pi * 2) * 7
            point = CGPoint(
                x: CGFloat(baseX * width),
                y: CGFloat(p2 * height + sway)
            )
            angle += time * (0.2 + p4 * 0.5)
        }

//        if halo {
//            alpha *= 0.72
//        }

        if config.direction == .swirl {
            let distance = hypot(point.x - size.width / 2, point.y - size.height / 2)
            let maxDistance = min(size.width, size.height) * 0.55
            if distance > maxDistance {
                alpha *= max(0, 1 - Double(distance - maxDistance) / 30)
            }
        } else {
            let marginX = min(Double(point.x), width - Double(point.x))
            let marginY = min(Double(point.y), height - Double(point.y))
            let fade = min(1, max(0, min(marginX, marginY) / 18.0))
            alpha *= 0.25 + 0.75 * fade
        }

        return ParticleState(
            point: point,
            angle: angle,
            alpha: clamp(alpha, 0, 1),
            sizeVariance: CGFloat(0.55 + p5 * 0.95)
        )
    }

    private func drawTrail(
        context: inout GraphicsContext,
        index: Int,
        time: Double,
        size: CGSize,
        color: Color,
        radius: CGFloat,
        alpha: Double
    ) {
        guard config.kind != .bubbles, config.kind != .hearts else { return }

        let previous = particleState(index: index, time: time - 0.11, size: size)
        let current = particleState(index: index, time: time, size: size)
        var path = Path()
        path.move(to: previous.point)
        path.addLine(to: current.point)

        context.stroke(
            path,
            with: .color(color.opacity(alpha * 0.22)),
            style: StrokeStyle(
                lineWidth: max(0.5, radius * 0.65),
                lineCap: .round
            )
        )
    }

    private func drawParticle(
        context: inout GraphicsContext,
        index: Int,
        point: CGPoint,
        angle: Double,
        radius: CGFloat,
        color: Color,
        alpha: Double
    ) {
        let finalColor = color.opacity(alpha)
        let rect = CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2)

        switch config.kind {
        case .snow:
            var local = context
            local.translateBy(x: point.x, y: point.y)
            local.rotate(by: .radians(angle * 0.4))
            local.fill(Path(ellipseIn: rect), with: .color(finalColor))

            if radius > 2.3 {
                var spokes = Path()
                for index in 0..<3 {
                    let spokeAngle = Double(index) * .pi / 3
                    spokes.move(to: CGPoint(
                        x: CGFloat(cos(spokeAngle)) * radius * 0.5,
                        y: CGFloat(sin(spokeAngle)) * radius * 0.5
                    ))
                    spokes.addLine(to: CGPoint(
                        x: CGFloat(cos(spokeAngle)) * radius * 1.55,
                        y: CGFloat(sin(spokeAngle)) * radius * 1.55
                    ))
                }
                local.stroke(
                    spokes,
                    with: .color(Color.white.opacity(alpha * 0.28)),
                    lineWidth: max(0.4, radius * 0.12)
                )
            }

        case .stars:
            var local = context
            local.translateBy(x: point.x, y: point.y)
            local.rotate(by: .radians(angle))
            let starRect = CGRect(x: -radius * 1.3, y: -radius * 1.3, width: radius * 2.6, height: radius * 2.6)
            local.fill(StarShape(points: 4, innerRatio: 0.23).path(in: starRect), with: .color(finalColor))
            local.fill(
                Path(ellipseIn: CGRect(x: -radius * 0.25, y: -radius * 0.25, width: radius * 0.5, height: radius * 0.5)),
                with: .color(Color.white.opacity(alpha * 0.7))
            )

        case .sakura:
            var local = context
            local.translateBy(x: point.x, y: point.y)
            local.rotate(by: .radians(angle))
            let petal = Path(ellipseIn: CGRect(
                x: -radius * 0.55,
                y: -radius * 1.25,
                width: radius * 1.1,
                height: radius * 2.5
            ))
            local.fill(petal, with: .color(finalColor))
            local.fill(
                Path(ellipseIn: CGRect(x: -radius * 0.18, y: -radius * 0.15, width: radius * 0.36, height: radius * 0.6)),
                with: .color(Color.white.opacity(alpha * 0.22))
            )

        case .hearts:
            var local = context
            local.translateBy(x: point.x, y: point.y)
            local.rotate(by: .radians(angle * 0.35))
            let heartRect = CGRect(
                x: -radius * 1.2,
                y: -radius * 0.95,
                width: radius * 2.4,
                height: radius * 2.1
            )
            local.fill(HeartShape().path(in: heartRect), with: .color(finalColor))

        case .fireflies:
            context.fill(
                Path(ellipseIn: CGRect(
                    x: point.x - radius * 0.5,
                    y: point.y - radius * 0.5,
                    width: radius,
                    height: radius
                )),
                with: .color(Color.white.opacity(alpha * 0.65))
            )
            context.fill(Path(ellipseIn: rect), with: .color(finalColor))

        case .bubbles:
            let bubbleRect = CGRect(
                x: point.x - radius,
                y: point.y - radius,
                width: radius * 2,
                height: radius * 2
            )
            context.fill(Path(ellipseIn: bubbleRect), with: .color(color.opacity(alpha * 0.07)))
            context.stroke(
                Path(ellipseIn: bubbleRect),
                with: .color(finalColor),
                lineWidth: max(0.45, radius * 0.13)
            )
            context.stroke(
                Path { path in
                    path.addArc(
                        center: point,
                        radius: radius * 0.7,
                        startAngle: .degrees(205),
                        endAngle: .degrees(255),
                        clockwise: false
                    )
                },
                with: .color(Color.white.opacity(alpha * 0.4)),
                lineWidth: max(0.4, radius * 0.1)
            )

        case .glowingDust:
            context.fill(
                Path(ellipseIn: CGRect(
                    x: point.x - radius * 1.25,
                    y: point.y - radius * 1.25,
                    width: radius * 2.5,
                    height: radius * 2.5
                )),
                with: .color(color.opacity(alpha * 0.14))
            )
            context.fill(Path(ellipseIn: rect), with: .color(finalColor))

        case .neon:
            var local = context
            local.translateBy(x: point.x, y: point.y)
            local.rotate(by: .radians(angle))
            let length = radius * 3.4

            let line = Path(
                roundedRect: CGRect(
                    x: -length / 2,
                    y: -radius * 0.18,
                    width: length,
                    height: radius * 0.36
                ),
                cornerRadius: radius * 0.18
            )
            local.fill(line, with: .color(finalColor))
            local.fill(
                Path(ellipseIn: CGRect(
                    x: length / 2 - radius * 0.3,
                    y: -radius * 0.35,
                    width: radius * 0.7,
                    height: radius * 0.7
                )),
                with: .color(Color.white.opacity(alpha * 0.65))
            )

        case .cosmicDust:
            context.fill(
                Path(ellipseIn: CGRect(
                    x: point.x - radius * 2,
                    y: point.y - radius * 2,
                    width: radius * 4,
                    height: radius * 4
                )),
                with: .color(color.opacity(alpha * 0.09))
            )
            context.fill(Path(ellipseIn: rect), with: .color(finalColor))

            if seededRandom(index, 12) > 0.75 {
                context.stroke(
                    Path(ellipseIn: CGRect(
                        x: point.x - radius * 2.2,
                        y: point.y - radius * 2.2,
                        width: radius * 4.4,
                        height: radius * 4.4
                    )),
                    with: .color(finalColor.opacity(0.28)),
                    lineWidth: max(0.35, radius * 0.08)
                )
            }

        case .leaves:
            var local = context
            local.translateBy(x: point.x, y: point.y)
            local.rotate(by: .radians(angle))

            var leaf = Path()
            leaf.move(to: CGPoint(x: 0, y: -radius * 1.35))
            leaf.addQuadCurve(
                to: CGPoint(x: 0, y: radius * 1.35),
                control: CGPoint(x: radius * 1.5, y: 0)
            )
            leaf.addQuadCurve(
                to: CGPoint(x: 0, y: -radius * 1.35),
                control: CGPoint(x: -radius * 1.5, y: 0)
            )
            local.fill(leaf, with: .color(finalColor))

            var vein = Path()
            vein.move(to: CGPoint(x: 0, y: -radius * 1.1))
            vein.addLine(to: CGPoint(x: 0, y: radius * 1.1))
            local.stroke(
                vein,
                with: .color(Color.white.opacity(alpha * 0.18)),
                lineWidth: max(0.35, radius * 0.09)
            )
        }
    }

    private func particleBaseSize(_ kind: ParticleKind) -> CGFloat {
        switch kind {
        case .snow: return 2.7
        case .stars: return 3.3
        case .sakura: return 4.6
        case .hearts: return 5.4
        case .fireflies: return 2.4
        case .bubbles: return 5.0
        case .glowingDust: return 1.8
        case .neon: return 2.8
        case .cosmicDust: return 2.0
        case .leaves: return 5.2
        }
    }
}

private struct ParticleState {
    let point: CGPoint
    let angle: Double
    let alpha: Double
    let sizeVariance: CGFloat
}

// MARK: - Stage backdrop

struct ParticleStageBackdrop: View {
    let accent: Color
    var showsGrid: Bool = false

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size

            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#10131B"),
                        Color(hex: "#080A0F"),
                        Color(hex: "#030406")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [accent.opacity(0.22), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: size.width * 0.45
                        )
                    )
                    .frame(width: size.width * 0.9, height: size.width * 0.9)
                    .position(x: size.width * 0.5, y: size.height * 1.0)
                    .blur(radius: 32)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#38BDF8").opacity(0.1), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: size.width * 0.3
                        )
                    )
                    .frame(width: size.width * 0.7, height: size.width * 0.7)
                    .position(x: size.width * 0.82, y: size.height * 0.16)
                    .blur(radius: 30)

                if showsGrid {
                    Canvas { context, canvasSize in
                        var path = Path()
                        let spacing: CGFloat = 44
                        var x: CGFloat = 0
                        while x <= canvasSize.width {
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: canvasSize.height))
                            x += spacing
                        }
                        var y: CGFloat = 0
                        while y <= canvasSize.height {
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: canvasSize.width, y: y))
                            y += spacing
                        }
                        context.stroke(path, with: .color(.white.opacity(0.035)), lineWidth: 0.5)
                    }
                }

                LinearGradient(
                    colors: [Color.black.opacity(0.35), .clear, Color.black.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
}
