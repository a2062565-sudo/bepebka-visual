import SwiftUI

struct ParticlesView: View {
    @EnvironmentObject private var store: ClientStore

    private var settings: ParticleSettings { store.settings.particles }
    private var accent: Color { Color(hex: settings.colorHex) }
    private var secondary: Color { Color(hex: settings.secondaryHex) }

    private var fullConfig: ParticleRenderConfig {
        ParticleRenderConfig(settings: settings, density: store.previewDensity, cap: 190)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ModuleHeader(
                category: .particles,
                subtitleEN: "A living atmosphere built from lightweight procedural particles. Ten distinct moods, tuned in real time.",
                subtitleRU: "Живая атмосфера из лёгких процедурных частиц. Десять настроений с настройкой в реальном времени."
            )

            preview

            SettingsPanel(
                title: store.t("Effect library", "Библиотека эффектов"),
                icon: "sparkles"
            ) {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 100), spacing: 8)],
                    spacing: 8
                ) {
                    ForEach(ParticleKind.allCases) { kind in
                        particleTypeCard(kind)
                    }
                }
                .padding(9)
                .premiumRowBackground()
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 330), spacing: 16, alignment: .top)],
                alignment: .leading,
                spacing: 18
            ) {
                SettingsPanel(title: store.t("Behaviour", "Поведение"), icon: "wind") {
                    SettingToggleRow(
                        icon: "sparkles",
                        title: store.t("Enable Particles", "Включить частицы"),
                        subtitle: store.t("Master switch for the atmospheric layer.", "Главный переключатель атмосферного слоя."),
                        isOn: $store.settings.particles.enabled
                    )

                    SettingSegmentedRow(
                        icon: "arrow.up.and.down.and.arrow.left.and.right",
                        title: store.t("Direction", "Направление"),
                        options: ParticleDirection.allCases,
                        selection: $store.settings.particles.direction,
                        label: { store.t($0.titleEN, $0.titleRU) }
                    )

                    SettingToggleRow(
                        icon: "sun.max.fill",
                        title: store.t("Soft Glow", "Мягкое свечение"),
                        subtitle: store.t("Add a diffused light bloom around particles.", "Добавить рассеянное свечение вокруг частиц."),
                        isOn: $store.settings.particles.glow
                    )

                    SettingToggleRow(
                        icon: "scribble.variable",
                        title: store.t("Motion Trails", "Следы движения"),
                        subtitle: store.t("Draw a subtle motion wake behind each particle.", "Рисовать лёгкий след за каждой частицей."),
                        isOn: $store.settings.particles.trail
                    )
                }

                SettingsPanel(title: store.t("Motion & density", "Движение и плотность"), icon: "waveform.path") {
                    SettingSliderRow(
                        icon: "circle.grid.3x3.fill",
                        title: store.t("Particle Count", "Количество частиц"),
                        value: $store.settings.particles.count,
                        range: 10...180,
                        step: 1,
                        valueFormatter: { "\(Int($0)) pcs" }
                    )

                    SettingSliderRow(
                        icon: "speedometer",
                        title: store.t("Speed", "Скорость"),
                        value: $store.settings.particles.speed,
                        range: 0.2...2.5,
                        step: 0.01,
                        valueFormatter: { String(format: "×%.2f", $0) }
                    )

                    SettingSliderRow(
                        icon: "arrow.up.left.and.arrow.down.right",
                        title: store.t("Size", "Размер"),
                        value: $store.settings.particles.size,
                        range: 0.4...2.2,
                        step: 0.01,
                        valueFormatter: { String(format: "×%.2f", $0) }
                    )

                    SettingSliderRow(
                        icon: "circle.lefthalf.filled",
                        title: store.t("Opacity", "Прозрачность"),
                        value: $store.settings.particles.opacity,
                        range: 0.25...1,
                        step: 0.01,
                        valueFormatter: { "\(Int($0 * 100))%" }
                    )
                }

                SettingsPanel(title: store.t("Palette", "Палитра"), icon: "paintpalette.fill") {
                    SettingColorRow(
                        icon: "drop.fill",
                        title: store.t("Primary Color", "Основной цвет"),
                        hex: $store.settings.particles.colorHex,
                        palette: AccentPalette.colors
                    )

                    SettingColorRow(
                        icon: "drop.halffull",
                        title: store.t("Secondary Color", "Дополнительный цвет"),
                        hex: $store.settings.particles.secondaryHex,
                        palette: AccentPalette.colors
                    )

                    HStack(spacing: 11) {
                        SettingGlyph(icon: "arrow.left.arrow.right", tint: store.accentColor)
                        Text(store.t("Swap palette colors", "Поменять цвета местами"))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(DSColor.textSecondary)
                        Spacer(minLength: 8)
                        Button {
                            store.hapticTap()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                let primary = store.settings.particles.colorHex
                                store.settings.particles.colorHex = store.settings.particles.secondaryHex
                                store.settings.particles.secondaryHex = primary
                            }
                        } label: {
                            Text(store.t("Swap", "Поменять"))
                        }
                        .buttonStyle(PremiumButtonStyle(variant: .ghost))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .premiumRowBackground()
                }

                SettingsPanel(title: store.t("Atmosphere presets", "Пресеты атмосферы"), icon: "wand.and.stars") {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 132), spacing: 8)],
                        spacing: 8
                    ) {
                        ForEach(ParticleAtmospherePreset.all) { preset in
                            atmospherePreset(preset)
                        }
                    }
                    .padding(9)
                    .premiumRowBackground()
                }
            }

            InfoBanner(
                icon: "leaf.fill",
                title: store.t("A local atmospheric layer", "Локальный атмосферный слой"),
                message: store.t(
                    "Particles are rendered by this app only. They are a cosmetic preview and do not alter game files or network data.",
                    "Частицы отрисовываются только этим приложением. Это косметический превью, который не изменяет файлы игры или сетевые данные."
                ),
                tint: Color(hex: "#4ADE80")
            )
        }
        .animation(.easeInOut(duration: 0.2), value: settings)
    }

    private func particlesTopBar(showsCaption: Bool) -> some View {
        HStack(alignment: .top) {
            HStack(spacing: 7) {
                PreviewTag(
                    text: store.t(settings.kind.titleEN, settings.kind.titleRU).uppercased(),
                    tint: accent
                )

                if showsCaption {
                    PreviewTag(
                        text: settings.kind == .snow
                            ? store.t("SOFT ATMOSPHERE", "МЯГКАЯ АТМОСФЕРА")
                            : store.t("ANIMATED LAYER", "АНИМИРОВАННЫЙ СЛОЙ"),
                        tint: .white.opacity(0.55)
                    )
                }
            }

            Spacer(minLength: 8)

            particlesToggleButton
        }
    }

    private var particlesToggleButton: some View {
        Button {
            store.hapticTap()
            withAnimation(.easeInOut(duration: 0.2)) {
                store.settings.particles.enabled.toggle()
            }
        } label: {
            HStack(spacing: 7) {
                Text(settings.enabled ? store.t("ON", "ВКЛ") : store.t("OFF", "ВЫКЛ"))
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(0.7)
                    .foregroundStyle(settings.enabled ? DSColor.textPrimary : DSColor.textTertiary)
                ToggleVisual(isOn: settings.enabled, tint: accent)
            }
            .padding(.leading, 9)
            .padding(.trailing, 3)
            .padding(.vertical, 3)
            .background {
                Capsule().fill(Color.black.opacity(0.38))
            }
            .overlay {
                Capsule().stroke(Color.white.opacity(0.08), lineWidth: 0.6)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(store.t("Toggle particles", "Переключить частицы"))
        .accessibilityValue(settings.enabled ? store.t("On", "Включено") : store.t("Off", "Выключено"))
    }

    private func particlesBottomBar(showsHint: Bool) -> some View {
        HStack(spacing: 7) {
            statPill(icon: "circle.grid.3x3.fill", value: "\(fullConfig.count) \(store.t("particles", "частиц"))")
            statPill(icon: "speedometer", value: String(format: "×%.2f", settings.speed))
            statPill(icon: "arrow.up.left.and.arrow.down.right", value: String(format: "×%.2f", settings.size))

            Spacer(minLength: 0)

            if showsHint {
                PreviewTag(
                    text: store.t("TAP A TYPE BELOW TO PREVIEW", "ВЫБЕРИТЕ ЭФФЕКТ НИЖЕ"),
                    icon: "hand.tap.fill",
                    tint: .white.opacity(0.38)
                )
            }
        }
    }

    private var preview: some View {
        ZStack {
            ParticleStageBackdrop(accent: accent, showsGrid: true)

            ParticleFieldView(config: fullConfig, paused: !settings.enabled)
                .opacity(settings.enabled ? 1 : 0.18)

            if !settings.enabled {
                DisabledPreviewOverlay(
                    title: store.t("PARTICLES DISABLED", "ЧАСТИЦЫ ОТКЛЮЧЕНЫ"),
                    icon: "sparkles",
                    tint: accent
                )
            }

            VStack {
                ViewThatFits(in: .horizontal) {
                    particlesTopBar(showsCaption: true)
                    particlesTopBar(showsCaption: false)
                }

                Spacer()

                ViewThatFits(in: .horizontal) {
                    particlesBottomBar(showsHint: true)
                    particlesBottomBar(showsHint: false)
                }
            }
            .padding(12)
        }
        .frame(height: 344)
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
        .shadow(color: .black.opacity(0.38), radius: 28, y: 16)
    }

    private func statPill(icon: String, value: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(accent.opacity(0.8))
            Text(value)
                .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background {
            Capsule().fill(Color.black.opacity(0.32))
        }
        .overlay {
            Capsule().stroke(Color.white.opacity(0.06), lineWidth: 0.5)
        }
    }

    private func particleTypeCard(_ kind: ParticleKind) -> some View {
        let selected = settings.kind == kind
        let config = ParticleRenderConfig.thumbnail(
            kind: kind,
            settings: settings,
            density: store.previewDensity
        )

        return Button {
            store.hapticSelect()
            withAnimation(.easeOut(duration: 0.22)) {
                store.settings.particles.kind = kind
            }
        } label: {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [Color(hex: "#171B25"), Color(hex: "#07080C")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: settings.colorHex).opacity(0.18), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 70
                        )
                    )
                    .frame(width: 120, height: 120)
                    .offset(x: 32, y: 12)

                ParticleFieldView(
                    config: config,
                    minimumInterval: 1.0 / 24.0,
                    compact: true
                )

                LinearGradient(
                    colors: [.clear, .black.opacity(0.82)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                HStack(spacing: 5) {
                    Image(systemName: kind.icon)
                        .font(.system(size: 8.5, weight: .semibold))
                        .foregroundStyle(selected ? accent : .white.opacity(0.45))

                    Text(store.t(kind.titleEN, kind.titleRU))
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundStyle(selected ? .white : .white.opacity(0.65))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .padding(8)

                if selected {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark")
                                .font(.system(size: 7.5, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(4)
                                .background {
                                    Circle().fill(accent)
                                }
                                .padding(7)
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: 93)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        selected ? accent.opacity(0.7) : Color.white.opacity(0.055),
                        lineWidth: selected ? 1.1 : 0.6
                    )
            }
        }
        .buttonStyle(.plain)
    }

    private func atmospherePreset(_ preset: ParticleAtmospherePreset) -> some View {
        Button {
            store.hapticSuccess()
            withAnimation(.easeInOut(duration: 0.24)) {
                store.settings.particles.kind = preset.kind
                store.settings.particles.colorHex = preset.primaryHex
                store.settings.particles.secondaryHex = preset.secondaryHex
                store.settings.particles.direction = preset.direction
                store.settings.particles.speed = preset.speed
                store.settings.particles.count = preset.count
                store.settings.particles.glow = true
                store.settings.particles.enabled = true
            }
            store.showToast(store.t("Atmosphere applied", "Атмосфера применена"), icon: "wand.and.stars")
        } label: {
            HStack(spacing: 7) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: preset.primaryHex), Color(hex: preset.secondaryHex)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: preset.kind.icon)
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.55))
                }
                .frame(width: 22, height: 22)

                VStack(alignment: .leading, spacing: 1) {
                    Text(store.t(preset.nameEN, preset.nameRU))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(DSColor.textPrimary)
                        .lineLimit(1)
                    Text(store.t(preset.subtitleEN, preset.subtitleRU))
                        .font(.system(size: 8.5))
                        .foregroundStyle(DSColor.textTertiary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.03))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 0.6)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct ParticleAtmospherePreset: Identifiable {
    let id: String
    let kind: ParticleKind
    let nameEN: String
    let nameRU: String
    let subtitleEN: String
    let subtitleRU: String
    let primaryHex: String
    let secondaryHex: String
    let direction: ParticleDirection
    let speed: Double
    let count: Double

    static let all: [ParticleAtmospherePreset] = [
        ParticleAtmospherePreset(
            id: "frostfall",
            kind: .snow,
            nameEN: "Frostfall",
            nameRU: "Снегопад",
            subtitleEN: "Quiet winter drift",
            subtitleRU: "Тихий зимний дрейф",
            primaryHex: "#DBEAFE",
            secondaryHex: "#BAE6FD",
            direction: .down,
            speed: 0.55,
            count: 95
        ),
        ParticleAtmospherePreset(
            id: "sakura-breeze",
            kind: .sakura,
            nameEN: "Sakura Breeze",
            nameRU: "Ветер сакуры",
            subtitleEN: "Soft pink petals",
            subtitleRU: "Мягкие розовые лепестки",
            primaryHex: "#F9A8D4",
            secondaryHex: "#FBCFE8",
            direction: .down,
            speed: 0.8,
            count: 70
        ),
        ParticleAtmospherePreset(
            id: "firefly-night",
            kind: .fireflies,
            nameEN: "Firefly Night",
            nameRU: "Ночь светлячков",
            subtitleEN: "Warm orbiting lights",
            subtitleRU: "Тёплые кружащие огни",
            primaryHex: "#A3E635",
            secondaryHex: "#FDE68A",
            direction: .swirl,
            speed: 0.5,
            count: 60
        ),
        ParticleAtmospherePreset(
            id: "cosmic-drift",
            kind: .cosmicDust,
            nameEN: "Cosmic Drift",
            nameRU: "Космический дрейф",
            subtitleEN: "Distant stardust",
            subtitleRU: "Далёкая звёздная пыль",
            primaryHex: "#C4B5FD",
            secondaryHex: "#67E8F9",
            direction: .up,
            speed: 0.45,
            count: 110
        )
    ]
}
