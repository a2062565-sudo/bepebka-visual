import SwiftUI

// MARK: - Preview

struct EnvironmentScenePreview: View {
    let settings: EnvironmentSettings

    private var lightingOffset: Double {
        let lighting = settings.lightingEnabled ? (settings.lighting - 1) * 0.55 : 0
        let exposure = settings.exposureEnabled ? settings.exposure : 0
        return lighting + exposure
    }

    var body: some View {
        EnvironmentCanvasView(settings: settings)
            .saturation(settings.saturationEnabled ? settings.saturation : 1)
            .contrast(settings.contrastEnabled ? settings.contrast : 1)
            .hueRotation(.degrees(settings.hueEnabled ? settings.hue * 180 : 0))
            .brightness(lightingOffset)
    }
}

// MARK: - Canvas

private struct EnvironmentCanvasView: View {
    let settings: EnvironmentSettings

    private var accent: Color {
        Color(hex: settings.ambientGlowHex)
    }

    var body: some View {
        Canvas(opaque: false, rendersAsynchronously: true) { context, size in
            render(context: &context, size: size)
        }
    }

    private func render(context: inout GraphicsContext, size: CGSize) {
        if settings.motionBlurEnabled && settings.motionBlur > 0.01 {
            let offsets: [Double] = [-2.6, -1.5, 1.5, 2.6]
            for offset in offsets {
                var ghost = context
                ghost.translateBy(x: CGFloat(offset * settings.motionBlur * 9), y: 0)
                ghost.opacity = 0.06 + settings.motionBlur * 0.08
                ghost.blendMode = .plusLighter
                ghost.addFilter(.blur(radius: max(0.5, CGFloat(settings.motionBlur * 4))))
                drawScene(context: &ghost, size: size)
            }
        }

        if settings.bloomEnabled && settings.bloom > 0.01 {
            var bloomContext = context
            bloomContext.addFilter(.blur(radius: 6 + CGFloat(settings.bloom * 22)))
            bloomContext.blendMode = .plusLighter
            bloomContext.opacity = 0.35 + settings.bloom * 0.45
            drawScene(context: &bloomContext, size: size)
        }

        drawScene(context: &context, size: size)
        drawPostProcessing(context: &context, size: size)
    }

    private func drawScene(context: inout GraphicsContext, size: CGSize) {
        if settings.dofEnabled && settings.depthOfField > 0.01 {
            var background = context
            background.addFilter(.blur(radius: 1 + CGFloat(settings.depthOfField * 7)))
            drawBackground(context: &background, size: size)
        } else {
            drawBackground(context: &context, size: size)
        }
        drawForeground(context: &context, size: size)
    }

    // MARK: Background

    private func drawBackground(context: inout GraphicsContext, size: CGSize) {
        let horizon = size.height * 0.57
        let rect = CGRect(origin: .zero, size: size)

        context.fill(
            Path(rect),
            with: .linearGradient(
                Gradient(colors: [Color(hex: "#0A1423"), Color(hex: "#05080F"), Color(hex: "#020307")]),
                startPoint: CGPoint(x: size.width * 0.2, y: 0),
                endPoint: CGPoint(x: size.width * 0.8, y: size.height)
            )
        )

        var horizonGlow = context
        horizonGlow.addFilter(.blur(radius: size.height * 0.09))
        horizonGlow.fill(
            Path(ellipseIn: CGRect(
                x: -size.width * 0.2,
                y: horizon - size.height * 0.2,
                width: size.width * 1.4,
                height: size.height * 0.45
            )),
            with: .radialGradient(
                Gradient(colors: [accent.opacity(0.28), accent.opacity(0.08), .clear]),
                center: CGPoint(x: size.width * 0.58, y: horizon),
                startRadius: 0,
                endRadius: size.width * 0.6
            )
        )

        for index in 0..<78 {
            let x = CGFloat(seededRandom(index, 401)) * size.width
            let y = CGFloat(seededRandom(index, 403)) * (horizon - 14)
            let radius = CGFloat(0.4 + seededRandom(index, 407) * 1.2)
            let alpha = 0.12 + seededRandom(index, 409) * 0.4
            context.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: radius, height: radius)),
                with: .color((index.isMultiple(of: 9) ? accent : .white).opacity(alpha))
            )
        }

        context.fill(
            Path(CGRect(x: 0, y: horizon, width: size.width, height: size.height - horizon)),
            with: .linearGradient(
                Gradient(colors: [Color(hex: "#06090F"), Color(hex: "#010203")]),
                startPoint: CGPoint(x: 0, y: horizon),
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )

        var skylineX: CGFloat = -size.width * 0.02
        var index = 0
        while skylineX < size.width + 8 {
            let buildingWidth = size.width * CGFloat(0.015 + seededRandom(index, 411) * 0.045)
            let buildingHeight = size.height * CGFloat(0.012 + seededRandom(index, 413) * 0.13)
            let building = CGRect(
                x: skylineX,
                y: horizon - buildingHeight,
                width: buildingWidth,
                height: buildingHeight
            )
            context.fill(
                Path(roundedRect: building, cornerRadius: 0.8),
                with: .color(Color.black.opacity(0.62))
            )
            context.stroke(
                Path(roundedRect: building, cornerRadius: 0.8),
                with: .color(accent.opacity(0.04)),
                lineWidth: 0.5
            )

            if seededRandom(index, 417) > 0.52 {
                let lightSize = max(0.7, buildingWidth * 0.1)
                let light = CGRect(
                    x: building.minX + buildingWidth * CGFloat(0.2 + seededRandom(index, 419) * 0.55),
                    y: building.minY + buildingHeight * CGFloat(0.15 + seededRandom(index, 421) * 0.6),
                    width: lightSize,
                    height: lightSize
                )
                context.fill(
                    Path(light),
                    with: .color(accent.opacity(0.25 + seededRandom(index, 423) * 0.4))
                )
            }

            skylineX += buildingWidth + size.width * 0.0035
            index += 1
        }

        context.stroke(
            Path { path in
                path.move(to: CGPoint(x: 0, y: horizon))
                path.addLine(to: CGPoint(x: size.width, y: horizon))
            },
            with: .color(accent.opacity(0.22)),
            lineWidth: 0.7
        )

        let vanishingPoint = CGPoint(x: size.width * 0.54, y: horizon)
        for ray in -9...9 {
            let bottomX = vanishingPoint.x + CGFloat(ray) * size.width * 0.11
            var path = Path()
            path.move(to: vanishingPoint)
            path.addLine(to: CGPoint(x: bottomX, y: size.height))
            context.stroke(
                path,
                with: .color(accent.opacity(0.055)),
                lineWidth: 0.6
            )
        }

        for row in 1...13 {
            let progress = pow(Double(row) / 13.0, 1.75)
            let y = horizon + CGFloat(progress) * (size.height - horizon)
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(
                path,
                with: .color(accent.opacity(0.03 + progress * 0.06)),
                lineWidth: 0.55
            )
        }

        for index in 0..<34 {
            let x = CGFloat(seededRandom(index, 431)) * size.width
            let y = horizon + CGFloat(seededRandom(index, 433)) * (size.height - horizon)
            let radius = CGFloat(0.5 + seededRandom(index, 439) * 1.7)
            context.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: radius, height: radius)),
                with: .color(accent.opacity(0.12 + seededRandom(index, 443) * 0.28))
            )
        }

        context.fill(
            Path(rect),
            with: .linearGradient(
                Gradient(colors: [.clear, .clear, Color.black.opacity(0.42)]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )
    }

    // MARK: Foreground

    private func drawForeground(context: inout GraphicsContext, size: CGSize) {
        let horizon = size.height * 0.57
        let mainHeight = size.height * 0.52
        let mainWidth = max(34, size.width * 0.105)
        let mainRect = CGRect(
            x: size.width * 0.44 - mainWidth / 2,
            y: horizon - mainHeight * 0.72,
            width: mainWidth,
            height: mainHeight
        )

        var floorGlow = context
        floorGlow.addFilter(.blur(radius: mainWidth * 0.5))
        floorGlow.fill(
            Path(ellipseIn: CGRect(
                x: mainRect.midX - mainWidth * 1.2,
                y: mainRect.maxY - mainWidth * 0.4,
                width: mainWidth * 2.4,
                height: mainWidth * 0.7
            )),
            with: .radialGradient(
                Gradient(colors: [accent.opacity(0.22), .clear]),
                center: CGPoint(x: mainRect.midX, y: mainRect.maxY),
                startRadius: 0,
                endRadius: mainWidth * 1.2
            )
        )

        drawOperative(context: &context, rect: mainRect, accent: accent, opacity: 0.96)
        drawTargetBox(
            context: &context,
            rect: mainRect.insetBy(dx: -mainWidth * 0.4, dy: -10),
            accent: accent,
            opacity: 0.85,
            health: 0.82,
            armor: 0.64
        )

        let secondaryHeight = size.height * 0.32
        let secondaryWidth = max(22, size.width * 0.066)
        let secondaryRect = CGRect(
            x: size.width * 0.73 - secondaryWidth / 2,
            y: horizon - secondaryHeight * 0.62,
            width: secondaryWidth,
            height: secondaryHeight
        )

        drawOperative(context: &context, rect: secondaryRect, accent: accent, opacity: 0.66)
        drawTargetBox(
            context: &context,
            rect: secondaryRect.insetBy(dx: -secondaryWidth * 0.5, dy: -6),
            accent: accent,
            opacity: 0.58,
            health: 0.48,
            armor: 0.32
        )

        let center = CGPoint(x: size.width * 0.58, y: size.height * 0.43)
        let crossSize = max(9, size.width * 0.022)
        var crosshair = Path()
        crosshair.move(to: CGPoint(x: center.x - crossSize, y: center.y))
        crosshair.addLine(to: CGPoint(x: center.x - crossSize * 0.34, y: center.y))
        crosshair.move(to: CGPoint(x: center.x + crossSize * 0.34, y: center.y))
        crosshair.addLine(to: CGPoint(x: center.x + crossSize, y: center.y))
        crosshair.move(to: CGPoint(x: center.x, y: center.y - crossSize))
        crosshair.addLine(to: CGPoint(x: center.x, y: center.y - crossSize * 0.34))
        crosshair.move(to: CGPoint(x: center.x, y: center.y + crossSize * 0.34))
        crosshair.addLine(to: CGPoint(x: center.x, y: center.y + crossSize))
        context.stroke(
            crosshair,
            with: .color(.white.opacity(0.5)),
            style: StrokeStyle(lineWidth: 1, lineCap: .round)
        )
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - 1, y: center.y - 1, width: 2, height: 2)),
            with: .color(.white.opacity(0.65))
        )
    }

    private func drawOperative(
        context: inout GraphicsContext,
        rect: CGRect,
        accent: Color,
        opacity: Double
    ) {
        let path = OperativeBodyShape().path(in: rect)

        var glowContext = context
        glowContext.opacity = opacity
        glowContext.addFilter(.blur(radius: rect.width * 0.5))
        glowContext.fill(path, with: .color(accent.opacity(0.24)))

        var bodyContext = context
        bodyContext.opacity = opacity
        bodyContext.fill(
            path,
            with: .linearGradient(
                Gradient(colors: [Color(hex: "#2B3240"), Color(hex: "#11151C"), Color(hex: "#06080C")]),
                startPoint: CGPoint(x: rect.minX, y: rect.minY),
                endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
            )
        )
        bodyContext.stroke(
            path,
            with: .linearGradient(
                Gradient(colors: [accent.opacity(0.8), accent.opacity(0.16)]),
                startPoint: CGPoint(x: rect.minX, y: rect.minY),
                endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
            ),
            lineWidth: 0.9
        )
    }

    private func drawTargetBox(
        context: inout GraphicsContext,
        rect: CGRect,
        accent: Color,
        opacity: Double,
        health: Double,
        armor: Double
    ) {
        let path = CornerBracketShape(length: min(rect.width, rect.height) * 0.26).path(in: rect)
        var boxContext = context
        boxContext.opacity = opacity
        boxContext.stroke(path, with: .color(accent.opacity(0.85)), lineWidth: 1)

        var nameTick = Path()
        nameTick.move(to: CGPoint(x: rect.minX, y: rect.minY - 7))
        nameTick.addLine(to: CGPoint(x: rect.minX + rect.width * 0.42, y: rect.minY - 7))
        boxContext.stroke(nameTick, with: .color(accent.opacity(0.45)), lineWidth: 1)

        let healthBar = CGRect(x: rect.minX, y: rect.minY - 4, width: rect.width * health, height: 2)
        boxContext.fill(Path(healthBar), with: .color(Color(hex: "#4ADE80").opacity(0.7)))

        let armorBar = CGRect(x: rect.minX, y: rect.minY - 1.5, width: rect.width * armor, height: 1.2)
        boxContext.fill(Path(armorBar), with: .color(accent.opacity(0.55)))
    }

    // MARK: Post processing

    private func drawPostProcessing(context: inout GraphicsContext, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        let unit = min(size.width, size.height)

        if settings.ambientGlowEnabled && settings.ambientGlow > 0.01 {
            var glowContext = context
            glowContext.blendMode = .plusLighter
            glowContext.addFilter(.blur(radius: unit * 0.09))
            glowContext.fill(
                Path(ellipseIn: CGRect(
                    x: size.width * 0.12,
                    y: size.height * 0.25,
                    width: size.width * 0.8,
                    height: size.height * 0.6
                )),
                with: .radialGradient(
                    Gradient(colors: [accent.opacity(0.22 + settings.ambientGlow * 0.22), .clear]),
                    center: CGPoint(x: size.width * 0.48, y: size.height * 0.56),
                    startRadius: 0,
                    endRadius: size.width * 0.5
                )
            )
        }

        if settings.fogEnabled && settings.fogDensity > 0.01 {
            let fogColor = Color(hex: settings.fogHex)
            let density = clamp(settings.fogDensity, 0, 1)

            var fogBank = context
            fogBank.addFilter(.blur(radius: size.height * 0.055))
            fogBank.fill(
                Path(ellipseIn: CGRect(
                    x: -size.width * 0.15,
                    y: size.height * 0.46,
                    width: size.width * 1.3,
                    height: size.height * 0.3
                )),
                with: .radialGradient(
                    Gradient(colors: [fogColor.opacity(0.05 + density * 0.4), .clear]),
                    center: CGPoint(x: size.width * 0.5, y: size.height * 0.6),
                    startRadius: 0,
                    endRadius: size.width * 0.65
                )
            )

            context.fill(
                Path(rect),
                with: .linearGradient(
                    Gradient(colors: [.clear, fogColor.opacity(density * 0.15), fogColor.opacity(density * 0.34)]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: 0, y: size.height)
                )
            )
        }

        if settings.tintEnabled && settings.tintStrength > 0.001 {
            var tintContext = context
            tintContext.blendMode = .color
            tintContext.fill(
                Path(rect),
                with: .color(Color(hex: settings.tintHex).opacity(min(0.65, settings.tintStrength * 1.6)))
            )
        }

        if settings.vignetteEnabled && settings.vignette > 0.001 {
            context.fill(
                Path(rect),
                with: .radialGradient(
                    Gradient(colors: [.clear, .clear, Color.black.opacity(min(0.82, settings.vignette))]),
                    center: CGPoint(x: size.width * 0.5, y: size.height * 0.52),
                    startRadius: unit * 0.22,
                    endRadius: max(size.width, size.height) * 0.74
                )
            )
        }
    }
}
