import SwiftUI

struct CrosshairView: View {
    @EnvironmentObject private var store: ClientStore

    private var settings: CrosshairSettings { store.settings.crosshair }
    private var color: Color { Color(hex: settings.colorHex) }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ModuleHeader(
                category: .crosshair,
                subtitleEN: "A crisp aiming reference with live geometry. Build a clean static reticle or a breathing dynamic one.",
                subtitleRU: "Чёткий прицел с живой геометрией. Соберите чистую статичную марку или «дышащий» динамический прицел."
            )

            preview

            SettingsPanel(title: store.t("Preset library", "Библиотека пресетов"), icon: "scope") {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 104), spacing: 8)],
                    spacing: 8
                ) {
                    ForEach(CrosshairPreset.allCases) { preset in
                        presetCard(CrosshairPresetProfile.profile(for: preset))
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
                SettingsPanel(title: store.t("Geometry", "Геометрия"), icon: "ruler.fill") {
                    SettingToggleRow(
                        icon: "scope",
                        title: store.t("Enable Crosshair", "Включить прицел"),
                        subtitle: store.t("Master switch for the aiming overlay.", "Главный переключатель прицельной марки."),
                        isOn: $store.settings.crosshair.enabled
                    )

                    SettingSliderRow(
                        icon: "arrow.up.left.and.arrow.down.right",
                        title: store.t("Line Length", "Длина линий"),
                        value: $store.settings.crosshair.size,
                        range: 0...44,
                        step: 1,
                        valueFormatter: { "\(Int($0)) pt" }
                    )

                    SettingSliderRow(
                        icon: "lineweight",
                        title: store.t("Thickness", "Толщина"),
                        value: $store.settings.crosshair.thickness,
                        range: 1...6,
                        step: 0.1,
                        valueFormatter: { String(format: "%.1f pt", $0) }
                    )

                    SettingSliderRow(
                        icon: "arrow.left.and.right",
                        title: store.t("Center Gap", "Центральный зазор"),
                        value: $store.settings.crosshair.gap,
                        range: 0...18,
                        step: 1,
                        valueFormatter: { "\(Int($0)) pt" }
                    )

                    SettingSliderRow(
                        icon: "circle.lefthalf.filled",
                        title: store.t("Opacity", "Прозрачность"),
                        value: $store.settings.crosshair.opacity,
                        range: 0.15...1,
                        step: 0.01,
                        valueFormatter: { "\(Int($0 * 100))%" }
                    )
                }

                SettingsPanel(title: store.t("Behaviour", "Поведение"), icon: "scope") {
                    SettingSegmentedRow(
                        icon: "arrow.left.and.right.circle.fill",
                        title: store.t("Reticle Mode", "Режим прицела"),
                        subtitle: store.t(
                            "Dynamic adds a live spreading pulse to the preview.",
                            "Динамический добавляет живой импульс разброса в превью."
                        ),
                        options: [false, true],
                        selection: $store.settings.crosshair.dynamic,
                        label: { dynamic in
                            dynamic
                                ? store.t("Dynamic", "Динамический")
                                : store.t("Static", "Статический")
                        }
                    )

                    SettingToggleRow(
                        icon: "circle.fill",
                        title: store.t("Center Dot", "Центральная точка"),
                        subtitle: store.t("Draw a precise dot in the middle.", "Рисовать точку в центре."),
                        isOn: $store.settings.crosshair.dot
                    )

                    SettingToggleRow(
                        icon: "square.on.square.dashed",
                        title: store.t("Dark Outline", "Тёмный контур"),
                        subtitle: store.t("Improve readability on bright surfaces.", "Улучшить читаемость на светлых поверхностях."),
                        isOn: $store.settings.crosshair.outline
                    )

                    SettingToggleRow(
                        icon: "sun.max.fill",
                        title: store.t("Soft Glow", "Мягкое свечение"),
                        subtitle: store.t("Add a subtle luminous halo.", "Добавить лёгкий светящийся ореол."),
                        isOn: $store.settings.crosshair.glow
                    )
                }

                SettingsPanel(title: store.t("Color & maintenance", "Цвет и обслуживание"), icon: "paintpalette.fill") {
                    SettingColorRow(
                        icon: "paintbrush.fill",
                        title: store.t("Crosshair Color", "Цвет прицела"),
                        hex: $store.settings.crosshair.colorHex,
                        palette: ["#7CF2A1", "#22D3EE", "#F9A8D4", "#FCA5A5", "#FDE68A", "#E2E8F0", "#A78BFA"]
                    )

                    HStack(spacing: 11) {
                        SettingGlyph(icon: "scope", tint: color)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(store.t("Classic reticle", "Классический прицел"))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(DSColor.textPrimary)
                            Text(store.t("Restore the balanced green crosshair.", "Вернуть сбалансированный зелёный прицел."))
                                .font(.system(size: 10))
                                .foregroundStyle(DSColor.textTertiary)
                        }
                        Spacer(minLength: 8)
                        Button {
                            applyPreset(.classic)
                        } label: {
                            Text(store.t("Restore", "Вернуть"))
                        }
                        .buttonStyle(PremiumButtonStyle(variant: .ghost))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .premiumRowBackground()

                    crosshairReadout
                }
            }

            InfoBanner(
                icon: "scope",
                title: store.t("Local aiming laboratory", "Локальная лаборатория прицела"),
                message: store.t(
                    "The crosshair is drawn by this preview interface only. It is not injected into Standoff 2 and does not interact with aim or input systems.",
                    "Прицел рисуется только интерфейсом превью. Он не внедряется в Standoff 2 и не взаимодействует с системами прицеливания или ввода."
                ),
                tint: Color(hex: "#4ADE80")
            )
        }
        .animation(.easeInOut(duration: 0.2), value: settings)
    }

    // MARK: - Preview

    private func crosshairTopBar(showsMode: Bool, showsGlow: Bool, compactReset: Bool) -> some View {
        HStack(alignment: .top, spacing: 8) {
            HStack(spacing: 7) {
                PreviewTag(
                    text: store.t(settings.preset.titleEN, settings.preset.titleRU).uppercased(),
                    tint: color
                )

                if showsMode {
                    PreviewTag(
                        text: settings.dynamic
                            ? store.t("DYNAMIC SPREAD", "ДИНАМИЧЕСКИЙ РАЗБРОС")
                            : store.t("STATIC RETICLE", "СТАТИЧЕСКИЙ ПРИЦЕЛ"),
                        tint: .white.opacity(0.5)
                    )
                }

                if showsGlow && settings.glow {
                    PreviewTag(
                        text: store.t("GLOW", "СВЕЧЕНИЕ"),
                        icon: "sun.max.fill",
                        tint: color.opacity(0.9)
                    )
                }
            }

            Spacer(minLength: 6)

            if compactReset {
                resetPreviewIconButton
            } else {
                resetPreviewTextButton
            }
        }
    }

    private var resetPreviewTextButton: some View {
        Button {
            applyPreset(.classic)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 10, weight: .bold))
                Text(store.t("Reset", "Сброс"))
            }
        }
        .buttonStyle(PremiumButtonStyle(variant: .secondary))
    }

    private var resetPreviewIconButton: some View {
        Button {
            applyPreset(.classic)
        } label: {
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 10, weight: .bold))
        }
        .buttonStyle(PremiumButtonStyle(variant: .secondary))
        .accessibilityLabel(store.t("Reset crosshair", "Сбросить прицел"))
    }

    private var preview: some View {
        ZStack {
            CrosshairRangeBackdrop(accent: store.accentColor)
                .opacity(settings.enabled ? 1 : 0.5)

            CrosshairStageView(settings: settings)

            if !settings.enabled {
                DisabledPreviewOverlay(
                    title: store.t("CROSSHAIR DISABLED", "ПРИЦЕЛ ОТКЛЮЧЁН"),
                    icon: "scope",
                    tint: color
                )
            }

            VStack {
                ViewThatFits(in: .horizontal) {
                    crosshairTopBar(showsMode: true, showsGlow: true, compactReset: false)
                    crosshairTopBar(showsMode: true, showsGlow: false, compactReset: true)
                    crosshairTopBar(showsMode: false, showsGlow: false, compactReset: false)
                    crosshairTopBar(showsMode: false, showsGlow: false, compactReset: true)
                }

                Spacer()

                HStack(spacing: 7) {
                    statPill(icon: "arrow.up.left.and.arrow.down.right", text: "\(Int(settings.size)) pt")
                    statPill(icon: "lineweight", text: String(format: "%.1f pt", settings.thickness))
                    statPill(icon: "arrow.left.and.right", text: "\(Int(settings.gap)) pt")
                    statPill(icon: "circle.lefthalf.filled", text: "\(Int(settings.opacity * 100))%")

                    Spacer(minLength: 0)
                }
            }
            .padding(13)
        }
        .frame(height: 380)
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

    private func statPill(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(color.opacity(0.85))
            Text(text)
                .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background {
            Capsule().fill(Color.black.opacity(0.36))
        }
        .overlay {
            Capsule().stroke(Color.white.opacity(0.07), lineWidth: 0.5)
        }
        .fixedSize()
    }

    // MARK: - Presets

    private func presetCard(_ profile: CrosshairPresetProfile) -> some View {
        let selected = isPresetActive(profile)
        let tint = Color(hex: profile.colorHex)

        return Button {
            applyPreset(profile.preset)
        } label: {
            VStack(spacing: 0) {
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "#161C26"), Color(hex: "#06080C")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [tint.opacity(0.14), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 46
                            )
                        )
                        .frame(width: 100, height: 100)

                    CrosshairCanvasView(
                        settings: profile.settingsPreview,
                        spread: 0,
                        scale: 0.55
                    )
                }
                .frame(height: 78)

                HStack(spacing: 5) {
                    Text(store.t(profile.preset.titleEN, profile.preset.titleRU))
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundStyle(selected ? .white : .white.opacity(0.65))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer(minLength: 0)

                    if selected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 7.5, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(3.5)
                            .background { Circle().fill(tint) }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 7)
                .background(Color.black.opacity(0.24))
            }
            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .stroke(
                        selected ? tint.opacity(0.7) : Color.white.opacity(0.055),
                        lineWidth: selected ? 1.1 : 0.6
                    )
            }
        }
        .buttonStyle(.plain)
    }

    private var crosshairReadout: some View {
        VStack(spacing: 8) {
            readoutRow(
                label: store.t("Preset", "Пресет"),
                value: store.t(settings.preset.titleEN, settings.preset.titleRU)
            )
            readoutRow(
                label: store.t("Mode", "Режим"),
                value: settings.dynamic ? store.t("Dynamic", "Динамический") : store.t("Static", "Статический")
            )
            readoutRow(
                label: store.t("Total width", "Общая ширина"),
                value: "\((Int(settings.size) * 2 + Int(settings.gap) * 2)) pt"
            )
            readoutRow(
                label: store.t("Status", "Статус"),
                value: settings.enabled ? store.t("Enabled", "Включено") : store.t("Disabled", "Выключено"),
                tint: settings.enabled ? DSColor.success : DSColor.warning
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

    // MARK: - Actions

    private func applyPreset(_ preset: CrosshairPreset) {
        let profile = CrosshairPresetProfile.profile(for: preset)
        store.hapticSuccess()
        withAnimation(.easeInOut(duration: 0.22)) {
            store.settings.crosshair = profile.settingsPreview
        }
        store.showToast(
            store.t("\(store.t(preset.titleEN, preset.titleRU)) reticle applied", "Прицел «\(store.t(preset.titleEN, preset.titleRU))» применён"),
            icon: "scope"
        )
    }

    private func isPresetActive(_ profile: CrosshairPresetProfile) -> Bool {
        let current = store.settings.crosshair
        return current.enabled
            && current.preset == profile.preset
            && abs(current.size - profile.size) < 0.05
            && abs(current.thickness - profile.thickness) < 0.05
            && abs(current.gap - profile.gap) < 0.05
            && current.dot == profile.dot
            && current.dynamic == profile.dynamic
            && current.outline == profile.outline
            && current.glow == profile.glow
            && current.colorHex.caseInsensitiveCompare(profile.colorHex) == .orderedSame
    }
}
