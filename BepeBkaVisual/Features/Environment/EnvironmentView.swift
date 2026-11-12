import SwiftUI

struct EnvironmentView: View {
    @EnvironmentObject private var store: ClientStore

    private var settings: EnvironmentSettings { store.settings.environment }

    private var activeCount: Int {
        [
            settings.lightingEnabled,
            settings.saturationEnabled,
            settings.contrastEnabled,
            settings.exposureEnabled,
            settings.hueEnabled,
            settings.tintEnabled,
            settings.fogEnabled,
            settings.bloomEnabled,
            settings.ambientGlowEnabled,
            settings.motionBlurEnabled,
            settings.dofEnabled,
            settings.vignetteEnabled
        ]
        .filter { $0 }
        .count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ModuleHeader(
                category: .environment,
                subtitleEN: "A cinematic color and lens laboratory. Twelve independent post-processing layers, tuned live on a procedural arena.",
                subtitleRU: "Кинематографическая лаборатория цвета и оптики. Двенадцать независимых слоёв постобработки с живой настройкой на процедурной арене."
            )

            preview

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 336), spacing: 16, alignment: .top)],
                alignment: .leading,
                spacing: 18
            ) {
                SettingsPanel(title: store.t("Light", "Свет"), icon: "sun.max.fill") {
                    SettingToggleRow(
                        icon: "sun.max.fill",
                        title: store.t("Lighting", "Освещение"),
                        subtitle: store.t("Global scene luminance for the local preview.", "Общая яркость сцены в локальном превью."),
                        isOn: $store.settings.environment.lightingEnabled
                    )
                    SettingSliderRow(
                        icon: "sun.max.fill",
                        title: store.t("Light Level", "Уровень света"),
                        value: $store.settings.environment.lighting,
                        range: 0.4...1.6,
                        step: 0.01,
                        disabled: !settings.lightingEnabled,
                        valueFormatter: { "\(Int($0 * 100))%" }
                    )

                    SettingToggleRow(
                        icon: "plus.circle.fill",
                        title: store.t("Exposure", "Экспозиция"),
                        subtitle: store.t("Lift or lower the overall exposure.", "Повысить или понизить общую экспозицию."),
                        isOn: $store.settings.environment.exposureEnabled
                    )
                    SettingSliderRow(
                        icon: "plus.circle.fill",
                        title: store.t("Exposure Level", "Значение экспозиции"),
                        value: $store.settings.environment.exposure,
                        range: -0.45...0.45,
                        step: 0.01,
                        disabled: !settings.exposureEnabled,
                        valueFormatter: { String(format: "%+.0f%%", $0 * 100) }
                    )

                    SettingToggleRow(
                        icon: "circle.lefthalf.filled",
                        title: store.t("Saturation", "Насыщенность"),
                        subtitle: store.t("Push colors or fade toward monochrome.", "Усилить цвета или увести сцену к монохрому."),
                        isOn: $store.settings.environment.saturationEnabled
                    )
                    SettingSliderRow(
                        icon: "circle.lefthalf.filled",
                        title: store.t("Saturation Level", "Уровень насыщенности"),
                        value: $store.settings.environment.saturation,
                        range: 0...2,
                        step: 0.01,
                        disabled: !settings.saturationEnabled,
                        valueFormatter: { String(format: "×%.2f", $0) }
                    )
                }

                SettingsPanel(title: store.t("Color grading", "Цветокоррекция"), icon: "camera.filters") {
                    SettingToggleRow(
                        icon: "circle.righthalf.filled",
                        title: store.t("Contrast", "Контраст"),
                        subtitle: store.t("Separate shadows and highlights.", "Разделить тени и светлые участки."),
                        isOn: $store.settings.environment.contrastEnabled
                    )
                    SettingSliderRow(
                        icon: "circle.righthalf.filled",
                        title: store.t("Contrast Level", "Уровень контраста"),
                        value: $store.settings.environment.contrast,
                        range: 0.5...1.8,
                        step: 0.01,
                        disabled: !settings.contrastEnabled,
                        valueFormatter: { String(format: "×%.2f", $0) }
                    )

                    SettingToggleRow(
                        icon: "paintpalette.fill",
                        title: store.t("Hue Shift", "Сдвиг оттенка"),
                        subtitle: store.t("Rotate every color in the scene.", "Повернуть все цвета сцены."),
                        isOn: $store.settings.environment.hueEnabled
                    )
                    SettingSliderRow(
                        icon: "paintpalette.fill",
                        title: store.t("Hue Rotation", "Поворот оттенка"),
                        value: $store.settings.environment.hue,
                        range: -1...1,
                        step: 0.01,
                        disabled: !settings.hueEnabled,
                        valueFormatter: { "\(Int($0 * 180))°" }
                    )

                    SettingToggleRow(
                        icon: "eyedropper.halffull",
                        title: store.t("Ambient Tint", "Цветовой оттенок"),
                        subtitle: store.t("Wash the world in a chosen color.", "Залить мир выбранным цветом."),
                        isOn: $store.settings.environment.tintEnabled
                    )

                    SettingColorRow(
                        icon: "paintbrush.fill",
                        title: store.t("Tint Color", "Цвет оттенка"),
                        hex: $store.settings.environment.tintHex,
                        palette: AccentPalette.colors
                    )

                    SettingSliderRow(
                        icon: "eyedropper.halffull",
                        title: store.t("Tint Strength", "Сила оттенка"),
                        value: $store.settings.environment.tintStrength,
                        range: 0...0.5,
                        step: 0.01,
                        disabled: !settings.tintEnabled,
                        valueFormatter: { "\(Int($0 * 100))%" }
                    )
                }

                SettingsPanel(title: store.t("Atmosphere", "Атмосфера"), icon: "cloud.fog.fill") {
                    SettingToggleRow(
                        icon: "cloud.fog.fill",
                        title: store.t("Fog", "Туман"),
                        subtitle: store.t("Density haze across the arena.", "Плотная дымка по арене."),
                        isOn: $store.settings.environment.fogEnabled
                    )
                    SettingSliderRow(
                        icon: "cloud.fog.fill",
                        title: store.t("Fog Density", "Плотность тумана"),
                        value: $store.settings.environment.fogDensity,
                        range: 0...0.9,
                        step: 0.01,
                        disabled: !settings.fogEnabled,
                        valueFormatter: { "\(Int($0 * 100))%" }
                    )
                    SettingColorRow(
                        icon: "cloud.fill",
                        title: store.t("Fog Color", "Цвет тумана"),
                        hex: $store.settings.environment.fogHex,
                        palette: ["#8E9BB8", "#CBD5E1", "#7C3AED", "#22D3EE", "#F9A8D4", "#FDE68A"]
                    )

                    SettingToggleRow(
                        icon: "circle.dotted.circle.fill",
                        title: store.t("Ambient Glow", "Ambient-свечение"),
                        subtitle: store.t("Add a soft environmental light bloom.", "Добавить мягкое свечение окружения."),
                        isOn: $store.settings.environment.ambientGlowEnabled
                    )
                    SettingSliderRow(
                        icon: "circle.dotted.circle.fill",
                        title: store.t("Glow Strength", "Сила свечения"),
                        value: $store.settings.environment.ambientGlow,
                        range: 0...1,
                        step: 0.01,
                        disabled: !settings.ambientGlowEnabled,
                        valueFormatter: { "\(Int($0 * 100))%" }
                    )
                    SettingColorRow(
                        icon: "light.max",
                        title: store.t("Glow Color", "Цвет свечения"),
                        hex: $store.settings.environment.ambientGlowHex,
                        palette: AccentPalette.colors
                    )
                }

                SettingsPanel(title: store.t("Lens & post", "Оптика и постобработка"), icon: "camera.aperture") {
                    SettingToggleRow(
                        icon: "sun.max.trianglebadge.exclamationmark.fill",
                        title: store.t("Bloom", "Bloom"),
                        subtitle: store.t("Bleed bright light into a soft halo.", "Растянуть яркий свет в мягкий ореол."),
                        isOn: $store.settings.environment.bloomEnabled
                    )
                    SettingSliderRow(
                        icon: "sun.max.trianglebadge.exclamationmark.fill",
                        title: store.t("Bloom Intensity", "Интенсивность Bloom"),
                        value: $store.settings.environment.bloom,
                        range: 0...1,
                        step: 0.01,
                        disabled: !settings.bloomEnabled,
                        valueFormatter: { "\(Int($0 * 100))%" }
                    )

                    SettingToggleRow(
                        icon: "wind",
                        title: store.t("Motion Blur", "Размытие движения"),
                        subtitle: store.t("Add cinematic directional ghosting.", "Добавить кинематографичный шлейф движения."),
                        isOn: $store.settings.environment.motionBlurEnabled
                    )
                    SettingSliderRow(
                        icon: "wind",
                        title: store.t("Blur Amount", "Сила размытия"),
                        value: $store.settings.environment.motionBlur,
                        range: 0...1,
                        step: 0.01,
                        disabled: !settings.motionBlurEnabled,
                        valueFormatter: { "\(Int($0 * 100))%" }
                    )

                    SettingToggleRow(
                        icon: "camera.aperture",
                        title: store.t("Depth of Field", "Глубина резкости"),
                        subtitle: store.t("Soften the background while the target stays sharp.", "Смягчить фон, сохраняя цель резкой."),
                        isOn: $store.settings.environment.dofEnabled
                    )
                    SettingSliderRow(
                        icon: "camera.aperture",
                        title: store.t("Focus Falloff", "Сила расфокуса"),
                        value: $store.settings.environment.depthOfField,
                        range: 0...1,
                        step: 0.01,
                        disabled: !settings.dofEnabled,
                        valueFormatter: { "\(Int($0 * 100))%" }
                    )

                    SettingToggleRow(
                        icon: "circle.circle.fill",
                        title: store.t("Vignette", "Виньетка"),
                        subtitle: store.t("Darken the corners for a cinematic frame.", "Затемнить углы для кинематографичного кадра."),
                        isOn: $store.settings.environment.vignetteEnabled
                    )
                    SettingSliderRow(
                        icon: "circle.circle.fill",
                        title: store.t("Vignette Strength", "Сила виньетки"),
                        value: $store.settings.environment.vignette,
                        range: 0...0.8,
                        step: 0.01,
                        disabled: !settings.vignetteEnabled,
                        valueFormatter: { "\(Int($0 * 100))%" }
                    )
                }
            }

            InfoBanner(
                icon: "camera.filters",
                title: store.t("Local post-processing", "Локальная постобработка"),
                message: store.t(
                    "Environment layers are applied to the in-app preview only. They never attach to the game renderer, modify shaders, or touch Standoff 2 files.",
                    "Слои окружения применяются только к превью внутри приложения. Они не подключаются к рендереру игры, не меняют шейдеры и не затрагивают файлы Standoff 2."
                ),
                tint: Color(hex: "#FBBF24")
            )
        }
        .animation(.easeInOut(duration: 0.2), value: settings)
    }

    // MARK: - Preview

    private var preview: some View {
        ZStack {
            EnvironmentScenePreview(settings: settings)

            VStack {
                ViewThatFits(in: .horizontal) {
                    environmentTopBar(showsTint: true, compactReset: false)
                    environmentTopBar(showsTint: false, compactReset: true)
                    environmentTopBar(showsTint: false, compactReset: false)
                }

                Spacer()

                ViewThatFits(in: .horizontal) {
                    environmentBottomBar(showsLive: true, compactStats: false)
                    environmentBottomBar(showsLive: false, compactStats: false)
                    environmentBottomBar(showsLive: false, compactStats: true)
                }
            }
            .padding(13)
        }
        .frame(height: 366)
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

    private func environmentTopBar(showsTint: Bool, compactReset: Bool) -> some View {
        HStack(alignment: .top, spacing: 8) {
            HStack(spacing: 7) {
                PreviewTag(
                    text: store.t("POST-PROCESSING", "ПОСТОБРАБОТКА"),
                    tint: store.accentColor
                )
                PreviewTag(
                    text: "\(activeCount)/12 \(store.t("LAYERS", "СЛОЁВ"))",
                    icon: "square.stack.3d.up.fill",
                    tint: .white.opacity(0.52)
                )
                if showsTint && settings.tintEnabled {
                    PreviewTag(
                        text: store.t("TINTED", "С ОТТЕНКОМ"),
                        icon: "eyedropper.halffull",
                        tint: Color(hex: settings.tintHex)
                    )
                }
            }

            Spacer(minLength: 6)

            if compactReset {
                environmentResetIconButton
            } else {
                environmentResetTextButton
            }
        }
    }

    private var environmentResetTextButton: some View {
        Button {
            resetEnvironment()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 10, weight: .bold))
                Text(store.t("Reset FX", "Сбросить FX"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .buttonStyle(PremiumButtonStyle(variant: .secondary))
    }

    private var environmentResetIconButton: some View {
        Button {
            resetEnvironment()
        } label: {
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 10, weight: .bold))
        }
        .buttonStyle(PremiumButtonStyle(variant: .secondary))
        .accessibilityLabel(store.t("Reset environment effects", "Сбросить эффекты окружения"))
    }

    private func environmentBottomBar(showsLive: Bool, compactStats: Bool) -> some View {
        HStack(spacing: 7) {
            statPill(icon: "sun.max.fill", text: "BLOOM \(effectPercent(settings.bloomEnabled, settings.bloom))")
            statPill(icon: "cloud.fog.fill", text: "FOG \(effectPercent(settings.fogEnabled, settings.fogDensity))")
            statPill(icon: "camera.aperture", text: "DOF \(effectPercent(settings.dofEnabled, settings.depthOfField))")

            if !compactStats {
                statPill(icon: "camera.filters", text: "\(activeCount) \(store.t("ACTIVE", "АКТИВНО"))")
            }

            Spacer(minLength: 0)

            if showsLive {
                PreviewTag(
                    text: store.t("LIVE SCENE", "ЖИВАЯ СЦЕНА"),
                    icon: "play.fill",
                    tint: .white.opacity(0.38)
                )
            }
        }
    }

    private func statPill(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(store.accentColor.opacity(0.85))
            Text(text)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.56))
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background {
            Capsule().fill(Color.black.opacity(0.36))
        }
        .overlay {
            Capsule().stroke(Color.white.opacity(0.06), lineWidth: 0.5)
        }
        .fixedSize()
    }

    private func effectPercent(_ enabled: Bool, _ value: Double) -> String {
        enabled ? "\(Int(value * 100))%" : store.t("OFF", "ВЫКЛ")
    }

    private func resetEnvironment() {
        store.hapticSuccess()
        withAnimation(.easeInOut(duration: 0.25)) {
            store.settings.environment = EnvironmentSettings()
        }
        store.showToast(
            store.t("Environment effects reset", "Эффекты окружения сброшены"),
            icon: "camera.filters"
        )
    }
}
