import SwiftUI

struct SkinArtworkView: View {
    let skin: SkinEntry
    let weapon: WeaponEntry
    var showsBackdrop: Bool = true
    var compact: Bool = false

    var body: some View {
        Canvas(opaque: false, rendersAsynchronously: true) { context, size in
            let frame = CGRect(
                x: size.width * 0.06,
                y: size.height * 0.14,
                width: size.width * 0.88,
                height: size.height * 0.72
            )
            let center = CGPoint(x: size.width * 0.54, y: size.height * 0.52)

            if showsBackdrop {
                drawBackdrop(context: &context, size: size, center: center)
            }

            let path = WeaponSilhouette(category: weapon.category).path(in: frame)

            var glow = context
            glow.addFilter(.blur(radius: compact ? 5 : 13))
            glow.opacity = 0.7
            glow.fill(path, with: .color(skin.accent.opacity(0.5)))

            var art = context
            art.clip(to: path)
            art.fill(
                Path(frame),
                with: .linearGradient(
                    Gradient(colors: [skin.primary, skin.secondary]),
                    startPoint: CGPoint(x: frame.minX, y: frame.minY),
                    endPoint: CGPoint(x: frame.maxX, y: frame.maxY)
                )
            )

            drawPattern(context: &art, in: frame, skin: skin)

            var shine = Path()
            shine.move(to: CGPoint(x: frame.minX, y: frame.minY + frame.height * 0.32))
            shine.addLine(to: CGPoint(x: frame.maxX, y: frame.minY + frame.height * 0.12))
            art.stroke(
                shine,
                with: .color(.white.opacity(compact ? 0.12 : 0.2)),
                style: StrokeStyle(lineWidth: compact ? 1.5 : 2.4, lineCap: .round)
            )

            context.stroke(
                path,
                with: .color(skin.accent.opacity(compact ? 0.25 : 0.42)),
                style: StrokeStyle(lineWidth: compact ? 0.6 : 0.9, lineCap: .round)
            )

            if !compact {
                drawFloatingSparks(context: &context, size: size)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Backdrop

    private func drawBackdrop(context: inout GraphicsContext, size: CGSize, center: CGPoint) {
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                Gradient(colors: [Color(hex: "#12151D"), Color(hex: "#050609")]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: size.width, y: size.height)
            )
        )

        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - size.width * 0.5,
                y: center.y - size.height * 0.65,
                width: size.width,
                height: size.height * 1.3
            )),
            with: .radialGradient(
                Gradient(colors: [skin.primary.opacity(compact ? 0.16 : 0.23), .clear]),
                center: center,
                startRadius: 0,
                endRadius: max(size.width, size.height) * 0.62
            )
        )

        if !compact {
            var grid = Path()
            let spacing: CGFloat = 34
            var x = spacing
            while x < size.width {
                grid.move(to: CGPoint(x: x, y: 0))
                grid.addLine(to: CGPoint(x: x, y: size.height))
                x += spacing
            }
            var y = spacing
            while y < size.height {
                grid.move(to: CGPoint(x: 0, y: y))
                grid.addLine(to: CGPoint(x: size.width, y: y))
                y += spacing
            }
            context.stroke(grid, with: .color(.white.opacity(0.035)), lineWidth: 0.5)
        }

        var ring = Path()
        ring.addEllipse(in: CGRect(
            x: center.x - size.height * 0.46,
            y: center.y - size.height * 0.38,
            width: size.height * 0.92,
            height: size.height * 0.76
        ))
        context.stroke(ring, with: .color(skin.accent.opacity(0.08)), lineWidth: 0.7)
    }

    private func drawFloatingSparks(context: inout GraphicsContext, size: CGSize) {
        for index in 0..<18 {
            let x = CGFloat(seededRandom(index, 31)) * size.width
            let y = CGFloat(seededRandom(index, 47)) * size.height
            let radius = CGFloat(0.5 + seededRandom(index, 59) * 1.6)
            let color = index.isMultiple(of: 3) ? skin.accent : .white
            context.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: radius, height: radius)),
                with: .color(color.opacity(0.18 + seededRandom(index, 67) * 0.35))
            )
        }
    }

    // MARK: - Patterns

    private func drawPattern(context: inout GraphicsContext, in rect: CGRect, skin: SkinEntry) {
        let width = rect.width
        let height = rect.height

        switch skin.pattern {
        case .fade:
            context.fill(
                Path(rect),
                with: .linearGradient(
                    Gradient(colors: [.clear, skin.accent.opacity(0.22)]),
                    startPoint: CGPoint(x: rect.midX, y: rect.minY),
                    endPoint: CGPoint(x: rect.midX, y: rect.maxY)
                )
            )

        case .carbon:
            var lines = Path()
            var offset = -height
            while offset < width + height {
                lines.move(to: CGPoint(x: rect.minX + offset, y: rect.minY))
                lines.addLine(to: CGPoint(x: rect.minX + offset + height, y: rect.maxY))
                lines.move(to: CGPoint(x: rect.minX + offset, y: rect.maxY))
                lines.addLine(to: CGPoint(x: rect.minX + offset + height, y: rect.minY))
                offset += 7
            }
            context.stroke(lines, with: .color(.white.opacity(0.07)), lineWidth: 0.7)

        case .stripes:
            var offset = -height
            let band = max(5, width * 0.028)
            while offset < width + height {
                var stripe = Path()
                stripe.move(to: CGPoint(x: rect.minX + offset, y: rect.minY))
                stripe.addLine(to: CGPoint(x: rect.minX + offset + height, y: rect.maxY))
                stripe.addLine(to: CGPoint(x: rect.minX + offset + height + band, y: rect.maxY))
                stripe.addLine(to: CGPoint(x: rect.minX + offset + band, y: rect.minY))
                stripe.closeSubpath()
                context.fill(stripe, with: .color(skin.accent.opacity(0.18)))
                offset += band * 2.3
            }

        case .geometric:
            for index in 0..<13 {
                let x = rect.minX + CGFloat(seededRandom(index, 71)) * width
                let y = rect.minY + CGFloat(seededRandom(index, 73)) * height
                let size = CGFloat(10 + seededRandom(index, 79) * width * 0.11)
                var triangle = Path()
                triangle.move(to: CGPoint(x: x, y: y))
                triangle.addLine(to: CGPoint(x: x + size, y: y))
                triangle.addLine(to: CGPoint(x: x + size * 0.45, y: y + size))
                triangle.closeSubpath()
                context.fill(
                    triangle,
                    with: .color((index.isMultiple(of: 2) ? skin.accent : .white).opacity(0.1))
                )
            }

        case .camo:
            for index in 0..<16 {
                let x = rect.minX + CGFloat(seededRandom(index, 83)) * width
                let y = rect.minY + CGFloat(seededRandom(index, 89)) * height
                let w = CGFloat(12 + seededRandom(index, 97) * width * 0.14)
                let h = CGFloat(6 + seededRandom(index, 101) * height * 0.2)
                let color: Color = index.isMultiple(of: 3) ? skin.accent : (index.isMultiple(of: 2) ? skin.secondary : .white)
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: w, height: h)),
                    with: .color(color.opacity(0.14))
                )
            }

        case .liquid:
            for index in 0..<4 {
                let baseline = rect.minY + height * CGFloat(0.22 + Double(index) * 0.19)
                var wave = Path()
                wave.move(to: CGPoint(x: rect.minX, y: baseline))
                for step in 0...40 {
                    let t = Double(step) / 40.0
                    let x = rect.minX + width * CGFloat(t)
                    let y = baseline + CGFloat(sin(t * .pi * 2.4 + Double(index))) * height * 0.07
                    wave.addLine(to: CGPoint(x: x, y: y))
                }
                context.stroke(
                    wave,
                    with: .color((index.isMultiple(of: 2) ? skin.accent : .white).opacity(0.16)),
                    style: StrokeStyle(lineWidth: 1.6, lineCap: .round)
                )
            }

        case .marble:
            for index in 0..<5 {
                var vein = Path()
                vein.move(to: CGPoint(x: rect.minX, y: rect.minY + height * CGFloat(seededRandom(index, 103))))
                vein.addCurve(
                    to: CGPoint(x: rect.maxX, y: rect.minY + height * CGFloat(seededRandom(index, 107))),
                    control1: CGPoint(
                        x: rect.minX + width * 0.35,
                        y: rect.minY + height * CGFloat(seededRandom(index, 109))
                    ),
                    control2: CGPoint(
                        x: rect.minX + width * 0.65,
                        y: rect.minY + height * CGFloat(seededRandom(index, 113))
                    )
                )
                context.stroke(
                    vein,
                    with: .color((index.isMultiple(of: 2) ? .white : skin.accent).opacity(0.16)),
                    style: StrokeStyle(lineWidth: index.isMultiple(of: 2) ? 1.4 : 2.2, lineCap: .round)
                )
            }

        case .blossom:
            for index in 0..<10 {
                let x = rect.minX + CGFloat(seededRandom(index, 127)) * width
                let y = rect.minY + CGFloat(seededRandom(index, 131)) * height
                let radius = CGFloat(2.2 + seededRandom(index, 137) * 4.2)
                for petal in 0..<5 {
                    let angle = Double(petal) / 5.0 * .pi * 2
                    let px = x + CGFloat(cos(angle)) * radius
                    let py = y + CGFloat(sin(angle)) * radius
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: px - radius * 0.6,
                            y: py - radius * 0.6,
                            width: radius * 1.2,
                            height: radius * 1.2
                        )),
                        with: .color(skin.accent.opacity(0.2))
                    )
                }
            }

        case .glow:
            context.fill(
                Path(rect),
                with: .radialGradient(
                    Gradient(colors: [.white.opacity(0.33), skin.accent.opacity(0.16), .clear]),
                    center: CGPoint(x: rect.midX, y: rect.midY),
                    startRadius: 0,
                    endRadius: max(width, height) * 0.55
                )
            )
            var beam = Path()
            beam.move(to: CGPoint(x: rect.minX, y: rect.midY))
            beam.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            context.stroke(beam, with: .color(.white.opacity(0.22)), lineWidth: 1.2)

        case .cosmic:
            context.fill(
                Path(rect),
                with: .radialGradient(
                    Gradient(colors: [skin.accent.opacity(0.22), .clear]),
                    center: CGPoint(x: rect.midX, y: rect.minY + height * 0.4),
                    startRadius: 0,
                    endRadius: max(width, height) * 0.45
                )
            )
            for index in 0..<34 {
                let x = rect.minX + CGFloat(seededRandom(index, 139)) * width
                let y = rect.minY + CGFloat(seededRandom(index, 149)) * height
                let radius = CGFloat(0.5 + seededRandom(index, 151) * 1.8)
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: radius, height: radius)),
                    with: .color((index.isMultiple(of: 4) ? skin.accent : .white).opacity(0.55))
                )
            }
            for index in 0..<4 {
                let x = rect.minX + CGFloat(seededRandom(index, 157)) * width
                let y = rect.minY + CGFloat(seededRandom(index, 163)) * height
                let radius = CGFloat(8 + seededRandom(index, 167) * 18)
                context.fill(
                    Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)),
                    with: .radialGradient(
                        Gradient(colors: [(index.isMultiple(of: 2) ? skin.accent : skin.primary).opacity(0.18), .clear]),
                        center: CGPoint(x: x, y: y),
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            }
        }
    }
}
