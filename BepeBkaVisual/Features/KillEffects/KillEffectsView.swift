import SwiftUI

struct KillEffectsView: View {
    @EnvironmentObject private var store: ClientStore

    @State private var startDate = Date()

    private var settings: KillEffectSettings { store.settings.killEffects }
    private var accent: Color { Color(hex: settings.colorHex) }
    private var secondary: Color { Color(hex: settings.secondaryHex) }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ModuleHeader(
                category: .killEffects,
                subtitleEN: "A signature finish for every elimination. Twelve procedural bursts rendered live, shaped to your palette.",
                subtitleRU: "Фирменное завершение каждого устранения. Двенадцать процедурных вспышек в реальном времени, под вашу палитру."
            )

            preview

            SettingsPanel(title: store.t("Effect library", "Библиотека эффектов"), icon: "bolt.fill") {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 106), spacing: 8)],
                    spacing: 8
                ) {
                    ForEach(KillEffectKind.allCases) { kind in
                        effectCard(kind)
                    }
                }
                .padding(9)
                .premiumRowBackground()
            }

            SettingsPanel(title: store.t("Curated combinations", "Готовые комбинации"), icon: "wand.and.stars") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 9) {
                        ForEach(KillEffectCombo.all) { combo in
                            comboCard(combo)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .padding(9)
                .premiumRowBackground()
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 330), spacing: 16, alignment: .top)],
                alignment: .leading,
                spacing: 18
            ) {
                SettingsPanel(title: store.t("Behaviour", "Поведение"), icon: "bolt.badge.clock.fill") {
                    SettingToggleRow(
                        icon: "bolt.fill",
                        title: store.t("Enable Kill Effects", "Включить эффекты убийства"),
                        subtitle: store.t("Master switch for elimination bursts.", "Главный переключатель эффектов устранения."),
                        isOn: $store.settings.killEffects.enabled
                    )

                    SettingToggleRow(
                        icon: "sun.max.fill",
                        title: store.t("Screen Flash", "Вспышка экрана"),
                        subtitle: store.t("A short white flash at the start of the burst.", "Короткая белая вспышка в начале эффекта."),
                        isOn: $store.settings.killEffects.screenFlash
                    )

                    SettingToggleRow(
                        icon: "waveform.path",
                        title: store.t("Camera Shake", "Тряска камеры"),
                        subtitle: store.t("Adds a controlled shake to the preview.", "Добавляет контролируемую тряску в превью."),
                        isOn: $store.settings.killEffects.shake
                    )
                }

                SettingsPanel(title: store.t("Dynamics", "Динамика"), icon: "speedometer") {
                    SettingSliderRow(
                        icon: "flame.fill",
                        title: store.t("Intensity", "Интенсивность"),
                        value: $store.settings.killEffects.intensity,
                        range: 0.15...1,
                        step: 0.01,
                        valueFormatter: { "\(Int($0 * 100))%" }
                    )

                    SettingSliderRow(
                        icon: "timer",
                        title: store.t("Duration", "Длительность"),
                        value: $store.settings.killEffects.duration,
                        range: 0.5...3,
                        step: 0.01,
                        valueFormatter: { String(format: "%.2f s", $0) }
                    )

                    SettingSliderRow(
                        icon: "arrow.up.left.and.arrow.down.right",
                        title: store.t("Effect Size", "Размер эффекта"),
                        value: $store.settings.killEffects.size,
                        range: 0.5...1.9,
                        step: 0.01,
                        valueFormatter: { String(format: "×%.2f", $0) }
                    )

                    SettingSliderRow(
                        icon: "speedometer",
                        title: store.t("Playback Speed", "Скорость проигрывания"),
                        value: $store.settings.killEffects.speed,
                        range: 0.35...2.2,
                        step: 0.01,
                        valueFormatter: { String(format: "×%.2f", $0) }
                    )
                }

                SettingsPanel(title: store.t("Palette", "Палитра"), icon: "paintpalette.fill") {
                    SettingColorRow(
                        icon: "drop.fill",
                        title: store.t("Primary Color", "Основной цвет"),
                        hex: $store.settings.killEffects.colorHex,
                        palette: AccentPalette.colors
                    )

                    SettingColorRow(
                        icon: "drop.halffull",
                        title: store.t("Secondary Color", "Дополнительный цвет"),
                        hex: $store.settings.killEffects.secondaryHex,
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
                                let primary = store.settings.killEffects.colorHex
                                store.settings.killEffects.colorHex = store.settings.killEffects.secondaryHex
                                store.settings.killEffects.secondaryHex = primary
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

                SettingsPanel(title: store.t("Live readout", "Живые показатели"), icon: "gauge.with.dots.needle.67percent") {
                    effectReadout
                }
            }

            InfoBanner(
                icon: "bolt.slash.fill",
                title: store.t("Cosmetic laboratory only", "Только косметическая лаборатория"),
                message: store.t(
                    "Kill effects are drawn inside this preview window. The app never reads the game process, scores eliminations, or injects an overlay into Standoff 2.",
                    "Эффекты убийства отрисовываются внутри окна превью. Приложение не читает игровой процесс, не определяет устранения и не внедряет оверлей в Standoff 2."
                ),
                tint: Color(hex: "#FB7185")
            )
        }
        .animation(.easeInOut(duration: 0.2), value: settings)
        .onChange(of: settings.kind) { _, _ in
            startDate = Date()
        }
    }

    // MARK: - Preview

    private var preview: some View {
        ZStack {
            KillEffectStage(settings: settings, startDate: startDate)

            VStack {
                ViewThatFits(in: .horizontal) {
                    killTopBar(showsProcedure: true, compactReplay: false)
                    killTopBar(showsProcedure: false, compactReplay: false)
                    killTopBar(showsProcedure: false, compactReplay: true)
                }

                Spacer()

                ViewThatFits(in: .horizontal) {
                    killBottomBar(showsLive: true)
                    killBottomBar(showsLive: false)
                }
            }
            .padding(13)
        }
        .frame(height: 356)
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

    private func killTopBar(showsProcedure: Bool, compactReplay: Bool) -> some View {
        HStack(alignment: .top, spacing: 8) {
            HStack(spacing: 7) {
                PreviewTag(
                    text: store.t(settings.kind.titleEN, settings.kind.titleRU).uppercased(),
                    tint: accent
                )

                if showsProcedure {
                    PreviewTag(
                        text: store.t("PROCEDURAL", "ПРОЦЕДУРНЫЙ"),
                        tint: .white.opacity(0.55)
                    )
                }
            }

            Spacer(minLength: 8)

            if compactReplay {
                replayIconButton
            } else {
                replayTextButton
            }
        }
    }

    private var replayTextButton: some View {
        Button {
            replayEffect()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 10, weight: .bold))
                Text(store.t("Replay", "Повторить"))
            }
        }
        .buttonStyle(PremiumButtonStyle(variant: .secondary))
    }

    private var replayIconButton: some View {
        Button {
            replayEffect()
        } label: {
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 10, weight: .bold))
        }
        .buttonStyle(PremiumButtonStyle(variant: .secondary))
        .accessibilityLabel(store.t("Replay effect", "Повторить эффект"))
    }

    private func replayEffect() {
        store.hapticSuccess()
        startDate = Date()
    }

    private func killBottomBar(showsLive: Bool) -> some View {
        HStack(spacing: 7) {
            statPill(icon: "flame.fill", text: "\(Int(settings.intensity * 100))%")
            statPill(icon: "timer", text: String(format: "%.2fs", settings.duration))
            statPill(icon: "speedometer", text: String(format: "×%.2f", settings.speed))
            statPill(icon: "arrow.up.left.and.arrow.down.right", text: String(format: "×%.2f", settings.size))

            Spacer(minLength: 0)

            if showsLive {
                PreviewTag(
                    text: store.t("LIVE PREVIEW", "ЖИВОЕ ПРЕВЬЮ"),
                    icon: "play.fill",
                    tint: .white.opacity(0.4)
                )
            }
        }
    }

    private func statPill(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(accent.opacity(0.8))
            Text(text)
                .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background {
            Capsule().fill(Color.black.opacity(0.34))
        }
        .overlay {
            Capsule().stroke(Color.white.opacity(0.06), lineWidth: 0.5)
        }
    }

    // MARK: - Library

    private func effectCard(_ kind: KillEffectKind) -> some View {
        let selected = settings.kind == kind

        return Button {
            store.hapticSelect()
            withAnimation(.easeOut(duration: 0.22)) {
                store.settings.killEffects.kind = kind
            }
        } label: {
            ZStack(alignment: .bottomLeading) {
                KillEffectCardArtwork(kind: kind, accent: accent, secondary: secondary)

                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                HStack(spacing: 5) {
                    Image(systemName: kind.icon)
                        .font(.system(size: 8.5, weight: .semibold))
                        .foregroundStyle(selected ? accent : .white.opacity(0.45))

                    Text(store.t(kind.titleEN, kind.titleRU))
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundStyle(selected ? .white : .white.opacity(0.66))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
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
                                .background { Circle().fill(accent) }
                                .padding(7)
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: 94)
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

    private func comboCard(_ combo: KillEffectCombo) -> some View {
        Button {
            store.hapticSuccess()
            withAnimation(.easeInOut(duration: 0.24)) {
                store.settings.killEffects.kind = combo.kind
                store.settings.killEffects.colorHex = combo.primaryHex
                store.settings.killEffects.secondaryHex = combo.secondaryHex
                store.settings.killEffects.intensity = combo.intensity
                store.settings.killEffects.duration = combo.duration
                store.settings.killEffects.size = combo.size
                store.settings.killEffects.speed = combo.speed
                store.settings.killEffects.screenFlash = true
                store.settings.killEffects.enabled = true
            }
            startDate = Date()
            store.showToast(store.t("Effect applied", "Эффект применён"), icon: combo.kind.icon)
        } label: {
            HStack(spacing: 9) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: combo.primaryHex), Color(hex: combo.secondaryHex)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: combo.kind.icon)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.black.opacity(0.58))
                }
                .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 1) {
                    Text(store.t(combo.nameEN, combo.nameRU))
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundStyle(DSColor.textPrimary)
                        .lineLimit(1)
                    Text(store.t(combo.subtitleEN, combo.subtitleRU))
                        .font(.system(size: 8.5))
                        .foregroundStyle(DSColor.textTertiary)
                        .lineLimit(1)
                }
            }
            .padding(8)
            .frame(width: 158, alignment: .leading)
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

    private var effectReadout: some View {
        VStack(spacing: 8) {
            readoutRow(
                label: store.t("Selected effect", "Выбранный эффект"),
                value: store.t(settings.kind.titleEN, settings.kind.titleRU)
            )
            readoutRow(
                label: store.t("Cycle length", "Длина цикла"),
                value: String(format: "%.2f s", settings.duration / max(0.25, settings.speed))
            )
            readoutRow(
                label: store.t("Burst radius", "Радиус вспышки"),
                value: String(format: "%.0f%%", settings.size * 100)
            )
            readoutRow(
                label: store.t("Status", "Статус"),
                value: settings.enabled ? store.t("Enabled", "Включено") : store.t("Disabled", "Выключено"),
                tint: settings.enabled ? DSColor.success : DSColor.textTertiary
            )
        }
        .padding(12)
        .premiumRowBackground()
    }

    private func readoutRow(label: String, value: String, tint: Color = DSColor.textPrimary) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(DSColor.textTertiary)
            Spacer(minLength: 8)
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(tint)
                .lineLimit(1)
        }
    }
}

// MARK: - Static gallery artwork

private struct KillEffectCardArtwork: View {
    let kind: KillEffectKind
    let accent: Color
    let secondary: Color

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#171B25"), Color(hex: "#07080C")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [accent.opacity(0.26), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 62
                    )
                )
                .frame(width: 130, height: 130)
                .offset(x: 26, y: -14)

            Circle()
                .stroke(secondary.opacity(0.2), lineWidth: 0.8)
                .frame(width: 58, height: 58)
                .offset(x: -28, y: 15)

            Circle()
                .stroke(accent.opacity(0.16), lineWidth: 0.6)
                .frame(width: 82, height: 82)
                .offset(x: 18, y: -8)

            Image(systemName: kind.icon)
                .font(.system(size: 25, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [accent, secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: accent.opacity(0.65), radius: 10)
                .offset(x: 4, y: -6)
        }
    }
}

// MARK: - Curated combinations

private struct KillEffectCombo: Identifiable {
    let id: String
    let kind: KillEffectKind
    let nameEN: String
    let nameRU: String
    let subtitleEN: String
    let subtitleRU: String
    let primaryHex: String
    let secondaryHex: String
    let intensity: Double
    let duration: Double
    let size: Double
    let speed: Double

    static let all: [KillEffectCombo] = [
        KillEffectCombo(
            id: "voltage",
            kind: .electricExplosion,
            nameEN: "Voltage",
            nameRU: "Напряжение",
            subtitleEN: "Cyan electric burst",
            subtitleRU: "Голубой электрический взрыв",
            primaryHex: "#22D3EE",
            secondaryHex: "#A5F3FC",
            intensity: 0.92,
            duration: 1.05,
            size: 1.1,
            speed: 1.35
        ),
        KillEffectCombo(
            id: "supernova",
            kind: .rainbowBurst,
            nameEN: "Supernova",
            nameRU: "Сверхновая",
            subtitleEN: "Prismatic shockwave",
            subtitleRU: "Призматическая ударная волна",
            primaryHex: "#F472B6",
            secondaryHex: "#A78BFA",
            intensity: 1.0,
            duration: 1.7,
            size: 1.35,
            speed: 0.85
        ),
        KillEffectCombo(
            id: "frostbite",
            kind: .crystalExplosion,
            nameEN: "Frostbite",
            nameRU: "Обморожение",
            subtitleEN: "Shattering ice shards",
            subtitleRU: "Осколки ломающегося льда",
            primaryHex: "#BAE6FD",
            secondaryHex: "#38BDF8",
            intensity: 0.78,
            duration: 1.3,
            size: 1.0,
            speed: 0.95
        ),
        KillEffectCombo(
            id: "glitchwave",
            kind: .glitch,
            nameEN: "Glitchwave",
            nameRU: "Глитчвейв",
            subtitleEN: "Corrupted signal",
            subtitleRU: "Повреждённый сигнал",
            primaryHex: "#A3E635",
            secondaryHex: "#F0ABFC",
            intensity: 0.86,
            duration: 0.95,
            size: 1.05,
            speed: 1.6
        ),
        KillEffectCombo(
            id: "void-ritual",
            kind: .purpleEnergy,
            nameEN: "Void Ritual",
            nameRU: "Ритуал пустоты",
            subtitleEN: "Orbiting violet energy",
            subtitleRU: "Орбитальная фиолетовая энергия",
            primaryHex: "#A855F7",
            secondaryHex: "#E879F9",
            intensity: 0.95,
            duration: 1.45,
            size: 1.15,
            speed: 0.9
        )
    ]
}
