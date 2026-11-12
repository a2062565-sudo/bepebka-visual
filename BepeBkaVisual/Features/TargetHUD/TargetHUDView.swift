import SwiftUI

struct TargetHUDView: View {
    @EnvironmentObject private var store: ClientStore

    @State private var target = DemoTarget.samples[0]
    @State private var targetVisible = false
    @State private var didAppear = false

    private var settings: TargetHUDSettings { store.settings.targetHUD }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ModuleHeader(
                category: .targetHUD,
                subtitleEN: "An elegant target card that appears exactly where your eyes already are. Composed for instant reading.",
                subtitleRU: "Элегантная карточка цели, появляющаяся там, где уже находится ваш взгляд. Создана для мгновенного считывания."
            )

            previewPanel

            SettingsPanel(title: store.t("Style presets", "Пресеты стиля"), icon: "wand.and.stars") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(HUDPreset.all) { preset in
                            presetCard(preset)
                        }
                    }
                    .padding(.vertical, 1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .premiumRowBackground()
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 330), spacing: 16, alignment: .top)],
                alignment: .leading,
                spacing: 18
            ) {
                SettingsPanel(title: store.t("Display", "Отображение"), icon: "scope") {
                    SettingToggleRow(
                        icon: "scope",
                        title: store.t("Enable Target HUD", "Включить Target HUD"),
                        subtitle: store.t("Show the card when a target is acquired.", "Показывать карточку при обнаружении цели."),
                        isOn: $store.settings.targetHUD.enabled
                    )

                    SettingSegmentedRow(
                        icon: "rectangle.3.group",
                        title: store.t("Placement", "Положение"),
                        options: HUDPlacement.allCases,
                        selection: $store.settings.targetHUD.placement,
                        label: { store.t($0.titleEN, $0.titleRU) }
                    )

                    SettingSegmentedRow(
                        icon: "sparkles",
                        title: store.t("Appearance Animation", "Анимация появления"),
                        options: HUDAnimationStyle.allCases,
                        selection: Binding(
                            get: { store.settings.targetHUD.animation },
                            set: { store.settings.targetHUD.animation = $0 }
                        ),
                        label: { store.t($0.titleEN, $0.titleRU) }
                    )

                    SettingSliderRow(
                        icon: "arrow.up.left.and.arrow.down.right",
                        title: store.t("Window Scale", "Размер окна"),
                        value: $store.settings.targetHUD.scale,
                        range: 0.75...1.35,
                        step: 0.01,
                        valueFormatter: { "\(Int($0 * 100))%" }
                    )

                    SettingSliderRow(
                        icon: "circle.lefthalf.filled",
                        title: store.t("Opacity", "Прозрачность"),
                        value: $store.settings.targetHUD.opacity,
                        range: 0.35...1,
                        step: 0.01,
                        valueFormatter: { "\(Int($0 * 100))%" }
                    )
                }

                SettingsPanel(title: store.t("Information", "Информация"), icon: "list.bullet.rectangle") {
                    SettingToggleRow(
                        icon: "heart.fill",
                        title: store.t("Health", "Здоровье"),
                        subtitle: store.t("Current health and numeric readout.", "Текущее здоровье и числовое значение."),
                        isOn: $store.settings.targetHUD.showHealth
                    )
                    SettingToggleRow(
                        icon: "shield.lefthalf.filled",
                        title: store.t("Armor", "Броня"),
                        subtitle: store.t("Armor level below the health bar.", "Уровень брони под полоской здоровья."),
                        isOn: $store.settings.targetHUD.showArmor
                    )
                    SettingToggleRow(
                        icon: "scope",
                        title: store.t("Weapon", "Оружие"),
                        subtitle: store.t("Weapon icon and display name.", "Иконка и название оружия."),
                        isOn: $store.settings.targetHUD.showWeapon
                    )
                    SettingToggleRow(
                        icon: "number",
                        title: store.t("Level", "Уровень"),
                        subtitle: store.t("Compact player level badge.", "Компактный значок уровня игрока."),
                        isOn: $store.settings.targetHUD.showLevel
                    )
                    SettingToggleRow(
                        icon: "person.crop.circle.fill",
                        title: store.t("Avatar", "Аватар"),
                        subtitle: store.t("Monogram avatar with accent gradient.", "Аватар-монограмма с акцентным градиентом."),
                        isOn: $store.settings.targetHUD.showAvatar
                    )
                    SettingToggleRow(
                        icon: "dot.radiowaves.left.and.right",
                        title: store.t("Status", "Статус"),
                        subtitle: store.t("Target visibility indicator.", "Индикатор видимости цели."),
                        isOn: $store.settings.targetHUD.showStatus
                    )
                }

                SettingsPanel(title: store.t("Surface", "Оформление"), icon: "circle.hexagongrid.fill") {
                    HUDStyleGrid(selection: $store.settings.targetHUD.style)
                        .padding(10)
                        .premiumRowBackground()
                }

                SettingsPanel(title: store.t("Colors", "Цвета"), icon: "paintpalette.fill") {
                    SettingColorRow(
                        icon: "rectangle.dashed",
                        title: store.t("Border Color", "Цвет рамки"),
                        hex: $store.settings.targetHUD.borderHex,
                        palette: AccentPalette.colors
                    )
                    SettingColorRow(
                        icon: "textformat",
                        title: store.t("Text Color", "Цвет текста"),
                        hex: $store.settings.targetHUD.textHex,
                        palette: ["#FFFFFF", "#F8FAFC", "#E2E8F0", "#FDE68A", "#A7F3D0", "#FBCFE8"]
                    )
                    SettingColorRow(
                        icon: "heart.fill",
                        title: store.t("Accent Color", "Акцентный цвет"),
                        hex: $store.settings.targetHUD.accentHex,
                        palette: AccentPalette.colors
                    )
                }
            }

            InfoBanner(
                icon: "lock.shield.fill",
                title: store.t("Interactive HUD laboratory", "Интерактивная лаборатория HUD"),
                message: store.t(
                    "The target is a local demonstration object. No opponent data is read, and the HUD is never injected into a game overlay.",
                    "Цель — локальный демонстрационный объект. Данные противников не считываются, HUD не внедряется в игровой оверлей."
                ),
                tint: Color(hex: "#38BDF8")
            )
        }
        .animation(.easeInOut(duration: 0.22), value: settings)
        .onAppear {
            guard !didAppear else { return }
            didAppear = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                target = DemoTarget.random()
                withAnimation(store.settings.targetHUD.animation.animation) {
                    targetVisible = true
                }
            }
        }
    }

    private var previewPanel: some View {
        TargetHUDDemo(
            target: target,
            settings: settings,
            isVisible: targetVisible,
            onRetarget: simulateTarget
        )
        .frame(maxWidth: .infinity)
        .frame(height: 326)
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
        .overlay(alignment: .top) {
            ViewThatFits(in: .horizontal) {
                targetTopBar(showsLiveBadge: true, compactAction: false)
                targetTopBar(showsLiveBadge: false, compactAction: false)
                targetTopBar(showsLiveBadge: false, compactAction: true)
            }
            .padding(12)
        }
        .overlay(alignment: .bottom) {
            HStack(spacing: 6) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 8, weight: .medium))
                Text(store.t("TAP THE SCENE TO ACQUIRE A NEW TARGET", "НАЖМИТЕ НА СЦЕНУ, ЧТОБЫ СМЕНИТЬ ЦЕЛЬ"))
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .tracking(0.7)
            }
            .foregroundStyle(.white.opacity(0.3))
            .padding(.bottom, 10)
        }
        .shadow(color: .black.opacity(0.38), radius: 28, y: 16)
    }

    private func targetTopBar(showsLiveBadge: Bool, compactAction: Bool) -> some View {
        HStack(alignment: .top, spacing: 8) {
            HStack(spacing: 7) {
                PreviewTag(
                    text: store.t("TARGET LOCK", "ЦЕЛЬ ЗАХВАЧЕНА"),
                    tint: Color(hex: "#4ADE80")
                )

                if showsLiveBadge {
                    PreviewTag(
                        text: store.t("LIVE HUD", "LIVE HUD"),
                        tint: .white.opacity(0.65)
                    )
                }
            }

            Spacer(minLength: 6)

            if compactAction {
                simulateIconButton
            } else {
                simulateTextButton
            }
        }
    }

    private var simulateTextButton: some View {
        Button {
            simulateTarget()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "scope")
                    .font(.system(size: 10, weight: .semibold))
                Text(store.t("Simulate", "Симулировать"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .buttonStyle(PremiumButtonStyle(variant: .secondary))
    }

    private var simulateIconButton: some View {
        Button {
            simulateTarget()
        } label: {
            Image(systemName: "scope")
                .font(.system(size: 11, weight: .semibold))
        }
        .buttonStyle(PremiumButtonStyle(variant: .secondary))
        .accessibilityLabel(store.t("Simulate target", "Симулировать цель"))
    }

    private func simulateTarget() {
        store.hapticSelect()
        withAnimation(.easeOut(duration: 0.12)) {
            targetVisible = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            target = DemoTarget.random()
            withAnimation(store.settings.targetHUD.animation.animation) {
                targetVisible = true
            }
        }
    }

    private func presetCard(_ preset: HUDPreset) -> some View {
        Button {
            store.hapticSuccess()
            withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                var updated = store.settings.targetHUD
                updated.style = preset.style
                updated.borderHex = preset.borderHex
                updated.accentHex = preset.accentHex
                updated.textHex = preset.textHex
                updated.placement = preset.placement
                updated.animation = preset.animation
                updated.scale = preset.scale
                updated.showAvatar = preset.showAvatar
                updated.showArmor = preset.showArmor
                updated.showLevel = preset.showLevel
                updated.showStatus = preset.showStatus
                updated.opacity = 0.97
                store.settings.targetHUD = updated
            }
            store.showToast(store.t("Preset applied", "Пресет применён"), icon: "wand.and.stars")
        } label: {
            VStack(alignment: .leading, spacing: 9) {
                HUDMiniCard(
                    style: preset.style,
                    borderHex: preset.borderHex,
                    accentHex: preset.accentHex,
                    textHex: preset.textHex
                )
                .frame(height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(store.t(preset.nameEN, preset.nameRU))
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(DSColor.textPrimary)
                        .lineLimit(1)
                    Text(store.t(preset.descriptionEN, preset.descriptionRU))
                        .font(.system(size: 9))
                        .foregroundStyle(DSColor.textTertiary)
                        .lineLimit(1)
                }
            }
            .padding(10)
            .frame(width: 156, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Color.white.opacity(0.03))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 0.7)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Demo scene

struct DemoTarget: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let health: Double
    let armor: Double
    let level: Int
    let weapon: String

    var initials: String {
        String(name.prefix(2))
    }

    static let samples: [DemoTarget] = [
        DemoTarget(name: "BEPEBKA", health: 0.88, armor: 0.76, level: 42, weapon: "AK-47"),
        DemoTarget(name: "NOVA", health: 0.62, armor: 0.54, level: 31, weapon: "M4A4"),
        DemoTarget(name: "V1P3R", health: 0.41, armor: 0.28, level: 27, weapon: "AWP")
    ]

    static func random() -> DemoTarget {
        let names = ["NOVA", "V1P3R", "MORPH", "KIRA", "AXIOM", "SABLE", "ZERO", "LUNA"]
        let weapons = ["AK-47", "M4A4", "AWP", "MP9", "USP-S", "MAG-7"]
        return DemoTarget(
            name: names.randomElement() ?? "NOVA",
            health: Double.random(in: 0.28...1.0),
            armor: Double.random(in: 0.1...0.98),
            level: Int.random(in: 12...75),
            weapon: weapons.randomElement() ?? "AK-47"
        )
    }
}

private struct TargetHUDDemo: View {
    @EnvironmentObject private var store: ClientStore

    let target: DemoTarget
    let settings: TargetHUDSettings
    let isVisible: Bool
    let onRetarget: () -> Void

    private var accent: Color { Color(hex: settings.accentHex) }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let crosshair = CGPoint(x: size.width / 2, y: size.height * 0.41)
            let cardWidth = min(260, max(196, size.width * 0.54))

            ZStack {
                HUDSceneBackdrop(accent: accent)

                CrosshairMark(accent: .white.opacity(0.7))
                    .frame(width: 38, height: 38)
                    .position(crosshair)
                    .opacity(0.7)

                if !settings.enabled {
                    DisabledPreviewOverlay(
                        title: store.t("TARGET HUD DISABLED", "TARGET HUD ОТКЛЮЧЁН"),
                        icon: "scope",
                        tint: accent
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                } else if isVisible {
                    TargetHUDCard(target: target, settings: settings)
                        .frame(width: cardWidth)
                        .scaleEffect(CGFloat(settings.scale))
                        .position(position(for: settings.placement, size: size, crosshair: crosshair, cardWidth: cardWidth))
                        .opacity(settings.opacity)
                        .transition(settings.animation.anyTransition)
                }

                VStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Text(store.t("CURRENT TARGET", "ТЕКУЩАЯ ЦЕЛЬ"))
                            .font(.system(size: 7.5, weight: .semibold, design: .monospaced))
                            .tracking(1)
                            .foregroundStyle(.white.opacity(0.3))
                        Circle().fill(Color.white.opacity(0.15)).frame(width: 2, height: 2)
                        Text(target.name)
                            .font(.system(size: 7.5, weight: .semibold, design: .monospaced))
                            .tracking(0.8)
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    .padding(.bottom, 28)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onRetarget()
            }
            .animation(.easeInOut(duration: 0.24), value: settings.enabled)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: settings.placement)
        }
        .background(Color.black)
    }

    private func position(
        for placement: HUDPlacement,
        size: CGSize,
        crosshair: CGPoint,
        cardWidth: CGFloat
    ) -> CGPoint {
        let verticalOffset: CGFloat = 72
        switch placement {
        case .belowCrosshair:
            return CGPoint(x: crosshair.x, y: crosshair.y + verticalOffset)
        case .aboveCrosshair:
            return CGPoint(x: crosshair.x, y: crosshair.y - verticalOffset)
        case .center:
            return CGPoint(x: size.width / 2, y: size.height * 0.56)
        case .bottomLeft:
            return CGPoint(
                x: max(cardWidth * CGFloat(settings.scale) / 2 + 12, size.width * 0.27),
                y: size.height * 0.78
            )
        case .bottomRight:
            return CGPoint(
                x: min(size.width - cardWidth * CGFloat(settings.scale) / 2 - 12, size.width * 0.73),
                y: size.height * 0.78
            )
        }
    }
}

private struct HUDSceneBackdrop: View {
    let accent: Color

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size

            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#0B111D"), Color(hex: "#060910"), Color(hex: "#020306")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [accent.opacity(0.24), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: size.width * 0.4
                        )
                    )
                    .frame(width: size.width * 0.9, height: size.width * 0.9)
                    .position(x: size.width * 0.2, y: size.height * 0.12)
                    .blur(radius: 40)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#38BDF8").opacity(0.1), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: size.width * 0.32
                        )
                    )
                    .frame(width: size.width * 0.75, height: size.width * 0.75)
                    .position(x: size.width * 0.85, y: size.height * 0.8)
                    .blur(radius: 30)

                OperativeBodyShape()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#202632").opacity(0.8), Color(hex: "#080A0E").opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size.height * 0.19, height: size.height * 0.48)
                    .position(x: size.width * 0.5, y: size.height * 0.51)
                    .blur(radius: 1.2)
                    .opacity(0.7)

                HUDGrid()
                    .opacity(0.16)

                VStack {
                    Spacer()
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: size.height * 0.4)
                }

                LinearGradient(
                    colors: [Color.black.opacity(0.35), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: size.height * 0.3)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .clipped()
        }
    }
}

private struct HUDGrid: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            let spacing: CGFloat = 34

            var x: CGFloat = -size.height
            while x < size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x + size.height, y: size.height))
                x += spacing
            }

            var y: CGFloat = 0
            while y < size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += spacing
            }

            context.stroke(path, with: .color(.white.opacity(0.08)), lineWidth: 0.5)
        }
    }
}

private struct CrosshairMark: View {
    let accent: Color

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let gap: CGFloat = 5
            let length: CGFloat = 8
            var path = Path()

            path.move(to: CGPoint(x: center.x, y: center.y - gap))
            path.addLine(to: CGPoint(x: center.x, y: center.y - gap - length))
            path.move(to: CGPoint(x: center.x, y: center.y + gap))
            path.addLine(to: CGPoint(x: center.x, y: center.y + gap + length))
            path.move(to: CGPoint(x: center.x - gap, y: center.y))
            path.addLine(to: CGPoint(x: center.x - gap - length, y: center.y))
            path.move(to: CGPoint(x: center.x + gap, y: center.y))
            path.addLine(to: CGPoint(x: center.x + gap + length, y: center.y))

            context.stroke(path, with: .color(accent), lineWidth: 1.1)
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - 1, y: center.y - 1, width: 2, height: 2)),
                with: .color(.white.opacity(0.8))
            )
        }
    }
}

// MARK: - HUD card

private struct HUDCardShape: Shape {
    let tactical: Bool

    func path(in rect: CGRect) -> Path {
        if tactical {
            return ChamferedRectangle(cut: 13).path(in: rect)
        }
        return RoundedRectangle(cornerRadius: 15, style: .continuous).path(in: rect)
    }
}

struct TargetHUDCard: View {
    @EnvironmentObject private var store: ClientStore

    let target: DemoTarget
    let settings: TargetHUDSettings

    private var accent: Color { Color(hex: settings.accentHex) }
    private var border: Color { Color(hex: settings.borderHex) }
    private var textColor: Color { Color(hex: settings.textHex) }
    private var shape: HUDCardShape { HUDCardShape(tactical: settings.style == .tactical) }

    var body: some View {
        HStack(spacing: 10) {
            if settings.showAvatar {
                avatar
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(target.name)
                        .font(.system(
                            size: 12.5,
                            weight: .bold,
                            design: settings.style == .tactical ? .monospaced : .rounded
                        ))
                        .foregroundStyle(textColor)
                        .lineLimit(1)

                    if settings.showStatus {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(Color(hex: "#4ADE80"))
                                .frame(width: 3, height: 3)
                            Text(store.t("VISIBLE", "ВИДИМ"))
                                .font(.system(size: 6.5, weight: .bold, design: .monospaced))
                                .tracking(0.5)
                                .foregroundStyle(accent.opacity(0.9))
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1.5)
                        .background {
                            Capsule().fill(accent.opacity(0.12))
                        }
                    }

                    Spacer(minLength: 0)

                    if settings.showLevel && !settings.showAvatar {
                        levelBadge
                    }
                }

                if settings.showHealth {
                    HStack(spacing: 6) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.08))
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [accent, accent.opacity(0.55)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: max(4, geometry.size.width * CGFloat(target.health)))
                                    .shadow(color: accent.opacity(0.4), radius: 4)
                            }
                        }
                        .frame(height: 4.5)

                        Text("\(Int(target.health * 100))")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundStyle(textColor.opacity(0.8))
                            .frame(width: 18, alignment: .trailing)
                    }
                }

                HStack(spacing: 10) {
                    if settings.showArmor {
                        HStack(spacing: 3) {
                            Image(systemName: "shield.lefthalf.filled")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundStyle(accent)
                            Text("\(Int(target.armor * 100))")
                                .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                                .foregroundStyle(textColor.opacity(0.72))
                        }
                    }

                    if settings.showWeapon {
                        HStack(spacing: 3) {
                            Image(systemName: "scope")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundStyle(accent.opacity(0.8))
                            Text(target.weapon)
                                .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                                .foregroundStyle(textColor.opacity(0.72))
                        }
                    }

                    Spacer(minLength: 0)

                    if settings.showLevel && settings.showAvatar {
                        Text("LV \(target.level)")
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundStyle(accent.opacity(0.7))
                    }
                }
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 10)
        .background {
            cardBackground
                .clipShape(shape)
        }
        .overlay {
            shape
                .stroke(
                    border.opacity(settings.style == .minimal ? 0.4 : 0.75),
                    lineWidth: settings.style == .neon ? 1.1 : 0.8
                )
        }
        .overlay(alignment: .topLeading) {
            if settings.style == .tactical {
                Rectangle()
                    .fill(accent.opacity(0.8))
                    .frame(width: 22, height: 1.5)
                    .padding(.leading, 12)
            }
        }
        .shadow(color: settings.style == .neon ? accent.opacity(0.35) : .black.opacity(0.48), radius: 16, y: 8)
    }

    @ViewBuilder
    private var cardBackground: some View {
        switch settings.style {
        case .glass:
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                LinearGradient(
                    colors: [Color.black.opacity(0.55), Color.black.opacity(0.28)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadialGradient(
                    colors: [accent.opacity(0.16), .clear],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 130
                )
            }
        case .neon:
            ZStack {
                Color(hex: "#05060A").opacity(0.9)
                LinearGradient(
                    colors: [accent.opacity(0.14), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        case .minimal:
            Color.black.opacity(0.54)
        case .tactical:
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#0D1410"), Color(hex: "#050807")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                LinearGradient(
                    colors: [Color(hex: "#A3E635").opacity(0.06), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        case .outline:
            Color.black.opacity(0.28)
        }
    }

    private var avatar: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [accent.opacity(0.9), accent.opacity(0.38)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Circle()
                    .stroke(Color.white.opacity(0.24), lineWidth: 0.7)
                Text(target.initials)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(accent.isLight ? Color.black.opacity(0.8) : .white)
            }
            .frame(width: 34, height: 34)

            if settings.showLevel {
                levelBadge
                    .offset(x: 3, y: 3)
            }
        }
    }

    private var levelBadge: some View {
        Text("\(target.level)")
            .font(.system(size: 7, weight: .bold, design: .monospaced))
            .foregroundStyle(accent.isLight ? Color.black.opacity(0.8) : .white)
            .padding(.horizontal, 4)
            .padding(.vertical, 1.5)
            .background {
                Capsule().fill(accent)
            }
            .overlay {
                Capsule().stroke(Color.white.opacity(0.18), lineWidth: 0.4)
            }
    }
}

// MARK: - Style grid and mini preview

private struct HUDStyleGrid: View {
    @EnvironmentObject private var store: ClientStore
    @Binding var selection: HUDStyle

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 82), spacing: 7)],
            spacing: 7
        ) {
            ForEach(HUDStyle.allCases) { style in
                Button {
                    store.hapticSelect()
                    withAnimation(.easeOut(duration: 0.2)) {
                        selection = style
                    }
                } label: {
                    VStack(spacing: 6) {
                        HUDMiniCard(
                            style: style,
                            borderHex: store.settings.targetHUD.borderHex,
                            accentHex: store.settings.targetHUD.accentHex,
                            textHex: store.settings.targetHUD.textHex
                        )
                        .frame(height: 34)
                        .padding(.horizontal, 4)

                        Text(store.t(style.titleEN, style.titleRU))
                            .font(.system(size: 9.5, weight: .medium))
                            .foregroundStyle(
                                selection == style ? store.accentColor : DSColor.textSecondary
                            )
                            .lineLimit(1)
                    }
                    .padding(.vertical, 7)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(selection == style ? store.accentColor.opacity(0.08) : Color.white.opacity(0.024))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(
                                selection == style ? store.accentColor.opacity(0.38) : Color.white.opacity(0.045),
                                lineWidth: selection == style ? 1 : 0.6
                            )
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct HUDMiniCard: View {
    let style: HUDStyle
    let borderHex: String
    let accentHex: String
    let textHex: String

    private var accent: Color { Color(hex: accentHex) }
    private var border: Color { Color(hex: borderHex) }

    var body: some View {
        let shape = HUDCardShape(tactical: style == .tactical)

        HStack(spacing: 5) {
            Circle()
                .fill(accent.opacity(0.35))
                .frame(width: 13, height: 13)
                .overlay {
                    Circle().stroke(accent.opacity(0.5), lineWidth: 0.5)
                }

            VStack(alignment: .leading, spacing: 3) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color(hex: textHex).opacity(0.55))
                    .frame(width: 28, height: 2.5)
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(accent.opacity(0.9))
                    .frame(width: 40, height: 2.5)
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(accent.opacity(0.28))
                    .frame(width: 20, height: 2)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            miniBackground
                .clipShape(shape)
        }
        .overlay {
            shape.stroke(border.opacity(0.5), lineWidth: 0.6)
        }
    }

    @ViewBuilder
    private var miniBackground: some View {
        switch style {
        case .glass:
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Color.black.opacity(0.35)
            }
        case .neon:
            ZStack {
                Color(hex: "#05060A").opacity(0.9)
                accent.opacity(0.08)
            }
        case .minimal:
            Color.black.opacity(0.35)
        case .tactical:
            Color(hex: "#0A100D")
        case .outline:
            Color.black.opacity(0.18)
        }
    }
}

// MARK: - Presets

private struct HUDPreset: Identifiable {
    let id: String
    let nameEN: String
    let nameRU: String
    let descriptionEN: String
    let descriptionRU: String
    let style: HUDStyle
    let borderHex: String
    let accentHex: String
    let textHex: String
    let placement: HUDPlacement
    let animation: HUDAnimationStyle
    let scale: Double
    let showAvatar: Bool
    let showArmor: Bool
    let showLevel: Bool
    let showStatus: Bool

    static let all: [HUDPreset] = [
        HUDPreset(
            id: "violet-glass",
            nameEN: "Violet Glass",
            nameRU: "Фиолетовое стекло",
            descriptionEN: "Soft translucent card",
            descriptionRU: "Мягкая полупрозрачная карточка",
            style: .glass,
            borderHex: "#8B5CF6",
            accentHex: "#A855F7",
            textHex: "#FFFFFF",
            placement: .belowCrosshair,
            animation: .spring,
            scale: 1.0,
            showAvatar: true,
            showArmor: true,
            showLevel: true,
            showStatus: true
        ),
        HUDPreset(
            id: "cyan-neon",
            nameEN: "Cyan Neon",
            nameRU: "Циановый неон",
            descriptionEN: "High-contrast luminous edge",
            descriptionRU: "Контрастная светящаяся рамка",
            style: .neon,
            borderHex: "#22D3EE",
            accentHex: "#22D3EE",
            textHex: "#F8FAFC",
            placement: .belowCrosshair,
            animation: .scale,
            scale: 1.02,
            showAvatar: true,
            showArmor: true,
            showLevel: true,
            showStatus: true
        ),
        HUDPreset(
            id: "ivory-minimal",
            nameEN: "Ivory Minimal",
            nameRU: "Минимал Ivory",
            descriptionEN: "Quiet, essential information",
            descriptionRU: "Тихая, только важная информация",
            style: .minimal,
            borderHex: "#E2E8F0",
            accentHex: "#E2E8F0",
            textHex: "#F8FAFC",
            placement: .center,
            animation: .fade,
            scale: 0.88,
            showAvatar: false,
            showArmor: false,
            showLevel: false,
            showStatus: false
        ),
        HUDPreset(
            id: "crimson-tactical",
            nameEN: "Crimson Tactical",
            nameRU: "Багровая тактика",
            descriptionEN: "Angular field-readout style",
            descriptionRU: "Угловой тактический стиль",
            style: .tactical,
            borderHex: "#FB7185",
            accentHex: "#F43F5E",
            textHex: "#FFF1F2",
            placement: .bottomLeft,
            animation: .slide,
            scale: 0.96,
            showAvatar: false,
            showArmor: true,
            showLevel: true,
            showStatus: true
        )
    ]
}
