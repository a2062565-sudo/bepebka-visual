import SwiftUI

struct VisualsView: View {
    @EnvironmentObject private var store: ClientStore

    private var visuals: VisualSettings { store.settings.visuals }

    private var enabledCount: Int {
        [
            visuals.showBoxes,
            visuals.showSkeleton,
            visuals.showHealthBars,
            visuals.showNames,
            visuals.showWeapons,
            visuals.showDistance,
            visuals.showRadar,
            visuals.showHitMarkers,
            visuals.showWorldGlow,
            visuals.showFPS,
            visuals.showTeamColors
        ].filter { $0 }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ModuleHeader(
                category: .visuals,
                subtitleEN: "A clean target overlay system with precise, readable information. Every element can be tuned independently.",
                subtitleRU: "Аккуратная система отображения целей с точной и читаемой информацией. Каждый элемент настраивается отдельно."
            )

            preview

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 330), spacing: 16, alignment: .top)],
                alignment: .leading,
                spacing: 18
            ) {
                SettingsPanel(
                    title: store.t("Elements", "Элементы"),
                    icon: "square.grid.2x2"
                ) {
                    SettingToggleRow(
                        icon: "eye.fill",
                        title: store.t("Enable Visuals", "Включить визуалы"),
                        subtitle: store.t("Master switch for all target overlays.", "Главный переключатель всех оверлеев."),
                        isOn: $store.settings.visuals.enabled
                    )

                    Group {
                        toggle(
                            "rectangle.dashed",
                            store.t("Bounding Boxes", "Рамки"),
                            store.t("Precise corner brackets around targets.", "Точные угловые рамки вокруг целей."),
                            $store.settings.visuals.showBoxes
                        )
                        toggle(
                            "figure.stand",
                            store.t("Skeleton", "Скелет"),
                            store.t("Minimal joint lines for fast target reading.", "Минималистичные линии суставов."),
                            $store.settings.visuals.showSkeleton
                        )
                        toggle(
                            "heart.fill",
                            store.t("Health Bars", "Полоски здоровья"),
                            store.t("Compact vertical health indicator.", "Компактный вертикальный индикатор здоровья."),
                            $store.settings.visuals.showHealthBars
                        )
                        toggle(
                            "textformat",
                            store.t("Name Tags", "Никнеймы"),
                            store.t("Player nickname above the target.", "Ник игрока над целью."),
                            $store.settings.visuals.showNames
                        )
                        toggle(
                            "scope",
                            store.t("Weapon Info", "Оружие"),
                            store.t("Equipped weapon label below the target.", "Название оружия под целью."),
                            $store.settings.visuals.showWeapons
                        )
                        toggle(
                            "ruler",
                            store.t("Distance", "Дистанция"),
                            store.t("Distance readout in metres.", "Показатель дистанции в метрах."),
                            $store.settings.visuals.showDistance
                        )
                        toggle(
                            "dot.radiowaves.left.and.right",
                            store.t("Radar", "Радар"),
                            store.t("Compact local radar visualisation.", "Компактная визуализация радара."),
                            $store.settings.visuals.showRadar
                        )
                        toggle(
                            "burst.fill",
                            store.t("Hit Markers", "Хит-маркеры"),
                            store.t("Minimal hit confirmation marker.", "Минимальный маркер попадания."),
                            $store.settings.visuals.showHitMarkers
                        )
                        toggle(
                            "sun.max.fill",
                            store.t("World Glow", "Свечение мира"),
                            store.t("Soft atmospheric light around the scene.", "Мягкий атмосферный свет в сцене."),
                            $store.settings.visuals.showWorldGlow
                        )
                        toggle(
                            "text.rectangle.fill",
                            store.t("FPS Overlay", "Счётчик FPS"),
                            store.t("Display the visual refresh rate.", "Показывать частоту обновления."),
                            $store.settings.visuals.showFPS
                        )
                        toggle(
                            "person.2.fill",
                            store.t("Team Colors", "Цвета команды"),
                            store.t("Use a secondary tint for allied silhouettes.", "Вторичный цвет для союзников."),
                            $store.settings.visuals.showTeamColors
                        )
                    }
                }

                VStack(spacing: 18) {
                    SettingsPanel(
                        title: store.t("Appearance", "Внешний вид"),
                        icon: "paintpalette.fill"
                    ) {
                        SettingSegmentedRow(
                            icon: "circle.hexagongrid.fill",
                            title: store.t("Highlight Style", "Стиль подсветки"),
                            subtitle: store.t("How silhouettes react to your accent.", "Как силуэты реагируют на акцент."),
                            options: HighlightStyle.allCases,
                            selection: $store.settings.visuals.highlightStyle,
                            label: { store.t($0.titleEN, $0.titleRU) }
                        )

                        SettingSliderRow(
                            icon: "lineweight",
                            title: store.t("Box Thickness", "Толщина рамки"),
                            value: $store.settings.visuals.boxThickness,
                            range: 0.5...4,
                            step: 0.1,
                            valueFormatter: { String(format: "%.1f px", $0) }
                        )

                        SettingSliderRow(
                            icon: "sun.max.fill",
                            title: store.t("Glow Strength", "Сила свечения"),
                            value: $store.settings.visuals.glowStrength,
                            range: 0...1,
                            step: 0.01,
                            valueFormatter: { "\(Int($0 * 100))%" }
                        )

                        SettingSliderRow(
                            icon: "textformat.alpha",
                            title: store.t("Info Opacity", "Прозрачность текста"),
                            value: $store.settings.visuals.infoOpacity,
                            range: 0.3...1,
                            step: 0.01,
                            valueFormatter: { "\(Int($0 * 100))%" }
                        )

                        SettingColorRow(
                            icon: "paintbrush.fill",
                            title: store.t("Overlay Accent", "Акцент оверлея"),
                            subtitle: store.t("Independent from the interface accent.", "Независимо от акцента интерфейса."),
                            hex: $store.settings.visuals.accentHex,
                            palette: AccentPalette.colors
                        )
                    }

                    GlassCard(padding: 0, cornerRadius: 18) {
                        HStack(spacing: 11) {
                            SettingGlyph(icon: "arrow.counterclockwise", tint: store.accentColor)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(store.t("Reset visuals", "Сбросить визуалы"))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(DSColor.textPrimary)
                                Text(store.t("Restore every overlay to its default state.", "Вернуть все оверлеи к стандартным значениям."))
                                    .font(.system(size: 10.5))
                                    .foregroundStyle(DSColor.textTertiary)
                            }

                            Spacer(minLength: 8)

                            Button {
                                store.hapticTap()
                                withAnimation(.easeInOut(duration: 0.22)) {
                                    let accent = store.settings.visuals.accentHex
                                    store.settings.visuals = VisualSettings()
                                    store.settings.visuals.accentHex = accent
                                }
                                store.showToast(store.t("Visuals reset", "Визуалы сброшены"), icon: "arrow.counterclockwise.circle.fill")
                            } label: {
                                Text(store.t("Reset", "Сброс"))
                            }
                            .buttonStyle(PremiumButtonStyle(variant: .ghost))
                        }
                        .padding(12)
                    }
                }
            }

            InfoBanner(
                icon: "info.circle.fill",
                title: store.t("Local visual preview", "Локальный визуальный превью"),
                message: store.t(
                    "This arena is a synthetic demonstration. Target data is generated locally and no game process, memory, or server data is accessed.",
                    "Эта арена — синтетическая демонстрация. Данные целей генерируются локально, доступ к процессу игры, памяти или серверу отсутствует."
                ),
                tint: store.accentColor
            )
        }
        .animation(.easeInOut(duration: 0.22), value: visuals)
    }

    private var preview: some View {
        VisualsArenaPreview(visuals: visuals, enabledCount: enabledCount)
            .aspectRatio(16 / 9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.16), Color.white.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            }
            .overlay(alignment: .topLeading) {
                HStack(spacing: 7) {
                    PreviewTag(
                        text: store.t("LIVE PREVIEW", "ЖИВОЙ ПРЕВЬЮ"),
                        tint: Color(hex: "#4ADE80")
                    )
                    PreviewTag(text: "\(enabledCount)/11", tint: .white.opacity(0.7))
                }
                .padding(12)
            }
            .overlay(alignment: .bottomTrailing) {
                PreviewTag(
                    text: store.t("TAP-FREE SIMULATION", "СИМУЛЯЦИЯ"),
                    icon: "sparkles"
                )
                .padding(12)
            }
            .shadow(color: .black.opacity(0.35), radius: 28, y: 16)
    }

    private func toggle(
        _ icon: String,
        _ title: String,
        _ subtitle: String,
        _ binding: Binding<Bool>
    ) -> some View {
        SettingToggleRow(
            icon: icon,
            title: title,
            subtitle: subtitle,
            isOn: binding
        )
    }
}

// MARK: - Arena preview

struct VisualsArenaPreview: View {
    @EnvironmentObject private var store: ClientStore
    let visuals: VisualSettings
    let enabledCount: Int

    private var accent: Color { Color(hex: visuals.accentHex) }
    private var allyAccent: Color { visuals.showTeamColors ? Color(hex: "#22D3EE") : accent.opacity(0.7) }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size

            ZStack {
                ArenaBackdrop(accent: accent, worldGlow: visuals.showWorldGlow)

                if visuals.enabled {
                    ArenaOperative(
                        name: "NOVA",
                        weapon: "AK-47",
                        distance: 24,
                        health: 0.78,
                        armor: 0.64,
                        accent: allyAccent,
                        settings: visuals,
                        glowStrength: visuals.showTeamColors ? 0.4 : visuals.glowStrength
                    )
                    .frame(width: size.width * 0.095, height: size.height * 0.44)
                    .position(x: size.width * 0.69, y: size.height * 0.55)
                    .opacity(0.82)

                    ArenaOperative(
                        name: "BEPEBKA",
                        weapon: "M4A4",
                        distance: 18,
                        health: 0.92,
                        armor: 0.85,
                        accent: accent,
                        settings: visuals,
                        glowStrength: visuals.glowStrength
                    )
                    .frame(width: size.width * 0.12, height: size.height * 0.55)
                    .position(x: size.width * 0.39, y: size.height * 0.6)

                    if visuals.showRadar {
                        RadarWidget(accent: accent)
                            .frame(width: min(size.width * 0.15, 86), height: min(size.width * 0.15, 86))
                            .position(x: size.width * 0.09, y: size.height * 0.78)
                            .opacity(0.9)
                    }

                    if visuals.showHitMarkers {
                        HitMarker(accent: accent)
                            .frame(width: 22, height: 22)
                            .position(x: size.width * 0.51, y: size.height * 0.48)
                            .opacity(0.8)
                    }

                    if visuals.showFPS {
                        HStack(spacing: 5) {
                            Image(systemName: "speedometer")
                                .font(.system(size: 8, weight: .semibold))
                            Text("\(store.settings.ui.refreshRate.rawValue) FPS")
                                .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                        }
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background {
                            Capsule().fill(Color.black.opacity(0.38))
                        }
                        .position(x: size.width - 62, y: size.height * 0.17)
                    }
                } else {
                    DisabledPreviewOverlay(
                        title: store.t("VISUALS DISABLED", "ВИЗУАЛЫ ОТКЛЮЧЕНЫ"),
                        icon: "eye.slash.fill",
                        tint: accent
                    )
                }
            }
            .frame(width: size.width, height: size.height)
        }
        .background(Color.black)
    }
}

private struct ArenaBackdrop: View {
    let accent: Color
    let worldGlow: Bool

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let horizon = size.height * 0.55

            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#0A1321"),
                        Color(hex: "#070B13"),
                        Color(hex: "#030407")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [accent.opacity(0.36), accent.opacity(0.08), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: size.width * 0.24
                        )
                    )
                    .frame(width: size.width * 0.48, height: size.width * 0.48)
                    .position(x: size.width * 0.74, y: size.height * 0.2)
                    .blur(radius: 24)

                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 4, height: 4)
                    .blur(radius: 1)
                    .position(x: size.width * 0.74, y: size.height * 0.2)
                    .shadow(color: accent.opacity(0.9), radius: 12)

                Skyline()
                    .frame(height: size.height * 0.22)
                    .position(x: size.width / 2, y: horizon - size.height * 0.08)
                    .opacity(0.85)

                PerspectiveGrid(accent: accent)
                    .frame(height: size.height - horizon)
                    .position(x: size.width / 2, y: horizon + (size.height - horizon) / 2)

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.35), Color.black.opacity(0.72)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                LinearGradient(
                    colors: [Color.black.opacity(0.35), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: size.height * 0.25)
                .frame(maxHeight: .infinity, alignment: .top)

                if worldGlow {
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [accent.opacity(0.22), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: size.width * 0.42
                            )
                        )
                        .frame(width: size.width * 0.8, height: size.height * 0.35)
                        .position(x: size.width * 0.47, y: size.height * 0.82)
                        .blendMode(.screen)
                }

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color.white.opacity(0.07), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 0.7)
                    .position(x: size.width / 2, y: horizon)
                    .blur(radius: 1)
            }
            .clipped()
        }
    }
}

private struct Skyline: View {
    var body: some View {
        Canvas { context, size in
            let baseY = size.height
            var index = 0
            var x: CGFloat = 0

            while x < size.width {
                let width = size.width * CGFloat(0.018 + seededRandom(index, 2) * 0.042)
                let height = size.height * CGFloat(0.18 + seededRandom(index, 3) * 0.72)
                let rect = CGRect(x: x, y: baseY - height, width: width, height: height)
                let shade = 0.035 + seededRandom(index, 4) * 0.04

                context.fill(
                    Path(roundedRect: rect, cornerRadius: 1),
                    with: .color(Color.black.opacity(shade + 0.55))
                )

                if seededRandom(index, 5) > 0.55 {
                    let lightX = x + width * CGFloat(0.25 + seededRandom(index, 6) * 0.5)
                    let lightY = baseY - height * CGFloat(0.35 + seededRandom(index, 7) * 0.45)
                    context.fill(
                        Path(ellipseIn: CGRect(x: lightX, y: lightY, width: 1.3, height: 1.3)),
                        with: .color(Color(hex: "#93C5FD").opacity(0.3))
                    )
                }

                x += width + size.width * 0.004
                index += 1
            }
        }
    }
}

private struct PerspectiveGrid: View {
    let accent: Color

    var body: some View {
        Canvas { context, size in
            let horizon: CGFloat = 0
            let vanishingX = size.width / 2
            var lines = Path()

            for index in -12...12 {
                lines.move(to: CGPoint(x: vanishingX, y: horizon))
                lines.addLine(
                    to: CGPoint(
                        x: vanishingX + CGFloat(index) * size.width * 0.105,
                        y: size.height
                    )
                )
            }

            for index in 1...11 {
                let t = CGFloat(index) / 11
                let y = horizon + pow(t, 1.9) * size.height
                lines.move(to: CGPoint(x: 0, y: y))
                lines.addLine(to: CGPoint(x: size.width, y: y))
            }

            context.stroke(lines, with: .color(accent.opacity(0.17)), lineWidth: 0.6)

            var highlight = Path()
            highlight.move(to: CGPoint(x: vanishingX, y: horizon))
            highlight.addLine(to: CGPoint(x: vanishingX + size.width * 0.11, y: size.height))
            highlight.move(to: CGPoint(x: vanishingX, y: horizon))
            highlight.addLine(to: CGPoint(x: vanishingX - size.width * 0.11, y: size.height))
            context.stroke(highlight, with: .color(accent.opacity(0.2)), lineWidth: 0.9)
        }
    }
}

private struct HitMarker: View {
    let accent: Color

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let gap: CGFloat = 3.5
            let length: CGFloat = 6
            var path = Path()

            for angle in stride(from: 0.0, to: 360.0, by: 90) {
                let radians = angle * .pi / 180
                let start = CGPoint(
                    x: center.x + CGFloat(cos(radians)) * gap,
                    y: center.y + CGFloat(sin(radians)) * gap
                )
                let end = CGPoint(
                    x: center.x + CGFloat(cos(radians)) * (gap + length),
                    y: center.y + CGFloat(sin(radians)) * (gap + length)
                )
                path.move(to: start)
                path.addLine(to: end)
            }

            context.stroke(path, with: .color(accent), lineWidth: 1.5)
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - 1, y: center.y - 1, width: 2, height: 2)),
                with: .color(.white)
            )
        }
    }
}

private struct RadarWidget: View {
    @EnvironmentObject private var store: ClientStore
    let accent: Color

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.36))

                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.7)

                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 0.6)
                    .padding(size * 0.2)

                Circle()
                    .stroke(accent.opacity(0.22), lineWidth: 0.6)
                    .padding(size * 0.38)

                Rectangle()
                    .fill(Color.white.opacity(0.055))
                    .frame(width: 0.6)
                Rectangle()
                    .fill(Color.white.opacity(0.055))
                    .frame(height: 0.6)

                TimelineView(.animation(minimumInterval: store.refreshInterval, paused: store.animationsPaused)) { timeline in
                    let seconds = timeline.date.timeIntervalSinceReferenceDate
                    let angle = (seconds.truncatingRemainder(dividingBy: 4)) / 4 * 360

                    Circle()
                        .fill(
                            AngularGradient(
                                gradient: Gradient(colors: [.clear, accent.opacity(0.35), .clear]),
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(72)
                            )
                        )
                        .rotationEffect(.degrees(angle))
                        .padding(1)
                }
                .clipShape(Circle())

                ForEach(0..<4, id: \.self) { index in
                    let positions: [(CGFloat, CGFloat)] = [(0.62, 0.34), (0.34, 0.58), (0.67, 0.7), (0.44, 0.28)]
                    Circle()
                        .fill(index == 0 ? accent : Color.white.opacity(0.42))
                        .frame(width: index == 0 ? 3.5 : 2.5, height: index == 0 ? 3.5 : 2.5)
                        .shadow(color: index == 0 ? accent.opacity(0.8) : .clear, radius: 4)
                        .position(
                            x: size * positions[index].0,
                            y: size * positions[index].1
                        )
                }
            }
            .overlay(alignment: .bottomLeading) {
                Text(store.t("RADAR", "РАДАР"))
                    .font(.system(size: 6, weight: .semibold, design: .monospaced))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.35))
                    .padding(6)
            }
        }
    }
}

// MARK: - Operative

struct OperativeBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        path.addEllipse(in: CGRect(x: w * 0.39, y: h * 0.035, width: w * 0.22, height: h * 0.135))

        let neck = CGRect(x: w * 0.45, y: h * 0.14, width: w * 0.10, height: h * 0.075)
        path.addRoundedRect(in: neck, cornerSize: CGSize(width: w * 0.03, height: w * 0.03))

        var torso = Path()
        torso.move(to: CGPoint(x: w * 0.33, y: h * 0.20))
        torso.addQuadCurve(
            to: CGPoint(x: w * 0.67, y: h * 0.20),
            control: CGPoint(x: w * 0.5, y: h * 0.16)
        )
        torso.addLine(to: CGPoint(x: w * 0.63, y: h * 0.49))
        torso.addQuadCurve(
            to: CGPoint(x: w * 0.37, y: h * 0.49),
            control: CGPoint(x: w * 0.5, y: h * 0.52)
        )
        torso.closeSubpath()
        path.addPath(torso)

        var leftArm = Path()
        leftArm.move(to: CGPoint(x: w * 0.34, y: h * 0.21))
        leftArm.addLine(to: CGPoint(x: w * 0.24, y: h * 0.46))
        leftArm.addLine(to: CGPoint(x: w * 0.16, y: h * 0.44))
        leftArm.addLine(to: CGPoint(x: w * 0.28, y: h * 0.20))
        leftArm.closeSubpath()
        path.addPath(leftArm)

        var rightArm = Path()
        rightArm.move(to: CGPoint(x: w * 0.66, y: h * 0.21))
        rightArm.addLine(to: CGPoint(x: w * 0.75, y: h * 0.45))
        rightArm.addLine(to: CGPoint(x: w * 0.83, y: h * 0.42))
        rightArm.addLine(to: CGPoint(x: w * 0.72, y: h * 0.19))
        rightArm.closeSubpath()
        path.addPath(rightArm)

        var leftLeg = Path()
        leftLeg.move(to: CGPoint(x: w * 0.37, y: h * 0.48))
        leftLeg.addLine(to: CGPoint(x: w * 0.29, y: h * 0.92))
        leftLeg.addLine(to: CGPoint(x: w * 0.20, y: h * 0.93))
        leftLeg.addLine(to: CGPoint(x: w * 0.23, y: h * 0.96))
        leftLeg.addLine(to: CGPoint(x: w * 0.44, y: h * 0.96))
        leftLeg.addLine(to: CGPoint(x: w * 0.47, y: h * 0.52))
        leftLeg.closeSubpath()
        path.addPath(leftLeg)

        var rightLeg = Path()
        rightLeg.move(to: CGPoint(x: w * 0.53, y: h * 0.52))
        rightLeg.addLine(to: CGPoint(x: w * 0.56, y: h * 0.96))
        rightLeg.addLine(to: CGPoint(x: w * 0.77, y: h * 0.96))
        rightLeg.addLine(to: CGPoint(x: w * 0.80, y: h * 0.93))
        rightLeg.addLine(to: CGPoint(x: w * 0.71, y: h * 0.92))
        rightLeg.addLine(to: CGPoint(x: w * 0.63, y: h * 0.48))
        rightLeg.closeSubpath()
        path.addPath(rightLeg)

        return path
    }
}

private struct ArenaOperative: View {
    @EnvironmentObject private var store: ClientStore

    let name: String
    let weapon: String
    let distance: Int
    let health: Double
    let armor: Double
    let accent: Color
    let settings: VisualSettings
    let glowStrength: Double

    private var boxGlow: Color {
        accent.opacity(settings.highlightStyle == .glow ? 0.65 * glowStrength : 0)
    }

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height

            ZStack {
                OperativeBodyShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#343A48"),
                                Color(hex: "#171B24"),
                                Color(hex: "#0A0C10")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                OperativeBodyShape()
                    .fill(accent.opacity(settings.highlightStyle == .filled ? 0.26 : 0.04))

                OperativeBodyShape()
                    .stroke(accent.opacity(settings.highlightStyle == .outline ? 0.36 : 0.58), lineWidth: 0.8)

                if settings.highlightStyle == .glow {
                    OperativeBodyShape()
                        .stroke(accent.opacity(0.5 * glowStrength), lineWidth: 1.4)
                        .blur(radius: 3.5)
                }

                if settings.showSkeleton {
                    SkeletonOverlay(accent: accent)
                        .opacity(0.9)
                }

                if settings.showBoxes {
                    CornerBracketShape(length: max(8, w * 0.16), lineWidth: CGFloat(settings.boxThickness))
                        .stroke(accent.opacity(0.9), style: StrokeStyle(lineWidth: CGFloat(settings.boxThickness), lineCap: .square))
                        .shadow(color: boxGlow, radius: 7)
                        .padding(-6)
                }
            }
            .overlay(alignment: .leading) {
                if settings.showHealthBars {
                    GeometryReader { barGeometry in
                        let barHeight = barGeometry.size.height * 0.66

                        ZStack(alignment: .bottom) {
                            Capsule()
                                .fill(Color.black.opacity(0.4))
                            Capsule()
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.6)
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [accent, accent.opacity(0.55)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: max(2, barHeight * CGFloat(health)))
                                .shadow(color: accent.opacity(0.5), radius: 4)
                        }
                        .frame(width: 3)
                        .frame(height: barHeight)
                        .position(x: 2, y: barGeometry.size.height / 2)
                    }
                    .padding(.leading, -8)
                }
            }
            .overlay(alignment: .top) {
                if settings.showNames {
                    HStack(spacing: 4) {
                        Text(name)
                            .font(.system(size: max(6, w * 0.085), weight: .bold, design: .monospaced))
                            .foregroundStyle(.white.opacity(settings.infoOpacity))
                        if settings.showDistance {
                            Text("\(distance)m")
                                .font(.system(size: max(5, w * 0.072), weight: .medium, design: .monospaced))
                                .foregroundStyle(accent.opacity(settings.infoOpacity))
                        }
                    }
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2.5)
                    .background {
                        Capsule().fill(Color.black.opacity(0.5))
                    }
                    .overlay {
                        Capsule().stroke(accent.opacity(0.26), lineWidth: 0.6)
                    }
                    .offset(y: -12)
                    .fixedSize()
                }
            }
            .overlay(alignment: .bottom) {
                if settings.showWeapons {
                    HStack(spacing: 3) {
                        Image(systemName: "scope")
                            .font(.system(size: max(5, w * 0.07), weight: .semibold))
                        Text(weapon)
                            .font(.system(size: max(5.5, w * 0.078), weight: .semibold, design: .monospaced))
                    }
                    .foregroundStyle(.white.opacity(settings.infoOpacity * 0.8))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2.5)
                    .background {
                        Capsule().fill(Color.black.opacity(0.44))
                    }
                    .offset(y: 13)
                    .fixedSize()
                }
            }
            .frame(width: w, height: h)
        }
    }
}

private struct SkeletonOverlay: View {
    let accent: Color

    var body: some View {
        Canvas { context, size in
            let points: [CGPoint] = [
                CGPoint(x: 0.50, y: 0.11),
                CGPoint(x: 0.50, y: 0.21),
                CGPoint(x: 0.36, y: 0.25),
                CGPoint(x: 0.64, y: 0.25),
                CGPoint(x: 0.26, y: 0.40),
                CGPoint(x: 0.74, y: 0.40),
                CGPoint(x: 0.50, y: 0.50),
                CGPoint(x: 0.42, y: 0.72),
                CGPoint(x: 0.58, y: 0.72),
                CGPoint(x: 0.36, y: 0.93),
                CGPoint(x: 0.64, y: 0.93)
            ].map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }

            let bones: [(Int, Int)] = [
                (0, 1), (1, 2), (1, 3), (2, 4), (3, 5),
                (2, 6), (3, 6), (6, 7), (6, 8), (7, 9), (8, 10)
            ]

            var path = Path()
            for bone in bones {
                path.move(to: points[bone.0])
                path.addLine(to: points[bone.1])
            }

            context.stroke(path, with: .color(accent.opacity(0.72)), lineWidth: max(0.8, size.width * 0.008))

            for point in points {
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: point.x - size.width * 0.009,
                        y: point.y - size.width * 0.009,
                        width: size.width * 0.018,
                        height: size.width * 0.018
                    )),
                    with: .color(accent.opacity(0.9))
                )
            }
        }
    }
}
