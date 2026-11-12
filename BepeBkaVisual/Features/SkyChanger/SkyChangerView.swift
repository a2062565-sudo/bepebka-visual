import SwiftUI

struct SkyChangerView: View {
    @EnvironmentObject private var store: ClientStore

    @State private var selectedPreset: SkyPreset = .galaxy
    @State private var galleryShowsAnimated = true

    private var settings: SkySettings { store.settings.sky }

    private var isApplied: Bool {
        settings.enabled && settings.preset == selectedPreset
    }

    private var galleryPresets: [SkyPreset] {
        SkyPreset.allCases.filter { $0.isAnimated == galleryShowsAnimated }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ModuleHeader(
                category: .skyChanger,
                subtitleEN: "Turn the arena into a different world. Nine clean static skies and ten living animated atmospheres.",
                subtitleRU: "Превратите арену в другой мир. Девять чистых статичных небес и десять живых анимированных атмосфер."
            )

            preview

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 330), spacing: 16, alignment: .top)],
                alignment: .leading,
                spacing: 18
            ) {
                SettingsPanel(title: store.t("Preset gallery", "Галерея пресетов"), icon: "cloud.moon.fill") {
                    PremiumSegmented(
                        options: [false, true],
                        selection: $galleryShowsAnimated,
                        label: { animated in
                            animated
                                ? "\(store.t("Animated", "Анимированные")) · 10"
                                : "\(store.t("Static", "Статичные")) · 9"
                        }
                    )

                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 134), spacing: 8)],
                        spacing: 8
                    ) {
                        ForEach(galleryPresets) { preset in
                            presetCard(preset)
                        }
                    }
                    .padding(.top, 2)
                }

                SettingsPanel(title: store.t("Atmosphere tuning", "Настройка атмосферы"), icon: "slider.horizontal.3") {
                    SettingToggleRow(
                        icon: "cloud.moon.fill",
                        title: store.t("Enable Sky Changer", "Включить смену неба"),
                        subtitle: store.t("Master switch for the custom sky layer.", "Главный переключатель слоя неба."),
                        isOn: $store.settings.sky.enabled
                    )

                    SettingSliderRow(
                        icon: "sparkles",
                        title: store.t("Intensity", "Интенсивность"),
                        subtitle: store.t("Glow, star density, and nebula volume.", "Свечение, плотность звёзд и объём туманности."),
                        value: $store.settings.sky.intensity,
                        range: 0.1...1,
                        step: 0.01,
                        valueFormatter: { "\(Int($0 * 100))%" }
                    )

                    SettingSliderRow(
                        icon: "speedometer",
                        title: store.t("Animation Speed", "Скорость анимации"),
                        subtitle: selectedPreset.isAnimated
                            ? store.t("Affects the selected animated preset.", "Влияет на выбранный анимированный пресет.")
                            : store.t("Available for animated presets only.", "Доступно только для анимированных пресетов."),
                        value: $store.settings.sky.speed,
                        range: 0.2...2.5,
                        step: 0.01,
                        disabled: !selectedPreset.isAnimated,
                        valueFormatter: { String(format: "×%.2f", $0) }
                    )

                    SettingSliderRow(
                        icon: "sun.max.fill",
                        title: store.t("Brightness", "Яркость"),
                        value: $store.settings.sky.brightness,
                        range: -0.35...0.35,
                        step: 0.01,
                        valueFormatter: { String(format: "%+.0f%%", $0 * 100) }
                    )

                    SettingSliderRow(
                        icon: "thermometer.medium",
                        title: store.t("Color Temperature", "Цветовая температура"),
                        subtitle: store.t("Negative cools the scene, positive warms it.", "Отрицательное значение охлаждает сцену, положительное — согревает."),
                        value: $store.settings.sky.temperature,
                        range: -1...1,
                        step: 0.01,
                        valueFormatter: temperatureLabel
                    )
                }

                SettingsPanel(title: store.t("Applied sky", "Активное небо"), icon: "checkmark.seal.fill") {
                    appliedReadout

                    Button {
                        applySelected()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isApplied ? "checkmark.seal.fill" : "paintbrush.pointed.fill")
                                .font(.system(size: 12, weight: .semibold))
                            Text(
                                isApplied
                                    ? store.t("Sky already applied", "Небо уже применено")
                                    : store.t("Apply \(presetName(selectedPreset))", "Применить: \(presetName(selectedPreset))")
                            )
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PremiumButtonStyle(variant: isApplied ? .secondary : .primary))

                    HStack(spacing: 11) {
                        SettingGlyph(icon: "info.circle.fill", tint: DSColor.textTertiary)
                        Text(store.t(
                            "Pick any card to preview it. Apply commits the sky to your local client setup.",
                            "Выберите карточку для превью. Применение сохраняет небо в локальной настройке клиента."
                        ))
                        .font(.system(size: 10.5))
                        .foregroundStyle(DSColor.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .premiumRowBackground()
                }
            }

            InfoBanner(
                icon: "cloud.moon.fill",
                title: store.t("A private skybox", "Приватный скайбокс"),
                message: store.t(
                    "Sky presets are drawn procedurally inside BepeBka Visual. They do not modify Standoff 2 maps, files, or network traffic.",
                    "Пресеты неба рисуются процедурно внутри BepeBka Visual. Они не изменяют карты, файлы или сетевой трафик Standoff 2."
                ),
                tint: Color(hex: "#38BDF8")
            )
        }
        .animation(.easeInOut(duration: 0.22), value: settings)
        .onAppear {
            selectedPreset = settings.preset
            galleryShowsAnimated = settings.preset.isAnimated
        }
        .onChange(of: settings.preset) { _, preset in
            if selectedPreset != preset {
                selectedPreset = preset
                galleryShowsAnimated = preset.isAnimated
            }
        }
        .onChange(of: galleryShowsAnimated) { _, showsAnimated in
            guard selectedPreset.isAnimated != showsAnimated else { return }
            if let first = SkyPreset.allCases.first(where: { $0.isAnimated == showsAnimated }) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedPreset = first
                }
            }
        }
    }

    // MARK: - Preview

    private func skyTopBar(showsState: Bool, compactApply: Bool) -> some View {
        HStack(alignment: .top, spacing: 8) {
            HStack(spacing: 7) {
                PreviewTag(
                    text: presetName(selectedPreset).uppercased(),
                    tint: selectedPreset.accentColors.first ?? .white
                )

                if showsState {
                    skyStateTag
                }
            }

            Spacer(minLength: 4)

            if compactApply {
                skyApplyIconButton
            } else {
                skyApplyTextButton
            }
        }
    }

    @ViewBuilder
    private var skyStateTag: some View {
        if !settings.enabled {
            PreviewTag(
                text: store.t("DISABLED", "ОТКЛЮЧЕНО"),
                icon: "pause.fill",
                tint: DSColor.warning
            )
        } else if isApplied {
            PreviewTag(
                text: store.t("APPLIED", "ПРИМЕНЕНО"),
                icon: "checkmark.seal.fill",
                tint: DSColor.success
            )
        } else {
            PreviewTag(
                text: selectedPreset.isAnimated
                    ? store.t("ANIMATED", "АНИМИРОВАННОЕ")
                    : store.t("STATIC", "СТАТИЧНОЕ"),
                tint: .white.opacity(0.5)
            )
        }
    }

    private var skyApplyTextButton: some View {
        Button {
            applySelected()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                Text(isApplied ? store.t("Applied", "Применено") : store.t("Apply Sky", "Применить небо"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .buttonStyle(PremiumButtonStyle(variant: isApplied ? .secondary : .primary))
    }

    private var skyApplyIconButton: some View {
        Button {
            applySelected()
        } label: {
            Image(systemName: isApplied ? "checkmark.seal.fill" : "checkmark")
                .font(.system(size: 11, weight: .bold))
        }
        .buttonStyle(PremiumButtonStyle(variant: isApplied ? .secondary : .primary))
        .accessibilityLabel(isApplied ? store.t("Applied", "Применено") : store.t("Apply Sky", "Применить небо"))
    }

    private var preview: some View {
        ZStack {
            SkyStageView(
                preset: selectedPreset,
                intensity: settings.intensity,
                speed: settings.speed,
                brightness: settings.brightness,
                temperature: settings.temperature
            )
            .opacity(settings.enabled ? 1 : 0.5)

            VStack {
                ViewThatFits(in: .horizontal) {
                    skyTopBar(showsState: true, compactApply: false)
                    skyTopBar(showsState: true, compactApply: true)
                    skyTopBar(showsState: false, compactApply: false)
                    skyTopBar(showsState: false, compactApply: true)
                }

                Spacer()

                HStack(spacing: 7) {
                    statPill(icon: "sparkles", text: "\(Int(settings.intensity * 100))%")
                    statPill(icon: "speedometer", text: String(format: "×%.2f", settings.speed))
                    statPill(icon: "sun.max.fill", text: String(format: "%+.0f%%", settings.brightness * 100))
                    statPill(icon: "thermometer.medium", text: temperatureShort(settings.temperature))

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
                .foregroundStyle((selectedPreset.accentColors.first ?? .white).opacity(0.85))
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
    }

    // MARK: - Gallery card

    private func presetCard(_ preset: SkyPreset) -> some View {
        let selected = selectedPreset == preset
        let applied = settings.enabled && settings.preset == preset
        let tint = preset.accentColors.first ?? .white

        return Button {
            store.hapticSelect()
            withAnimation(.easeInOut(duration: 0.24)) {
                selectedPreset = preset
            }
        } label: {
            ZStack(alignment: .bottomLeading) {
                SkyArtworkView(
                    preset: preset,
                    intensity: settings.intensity,
                    brightness: settings.brightness,
                    temperature: settings.temperature,
                    time: Double(SkyPreset.allCases.firstIndex(of: preset) ?? 0) * 0.7 + 1.4
                )
                .frame(height: 100)

                LinearGradient(
                    colors: [.clear, .black.opacity(0.82)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                HStack(spacing: 5) {
                    if preset.isAnimated {
                        Image(systemName: "play.fill")
                            .font(.system(size: 7))
                            .foregroundStyle(tint.opacity(0.8))
                    }
                    Text(presetName(preset))
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundStyle(selected ? .white : .white.opacity(0.7))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .padding(8)

                if selected {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: applied ? "checkmark.seal.fill" : "eye.fill")
                                .font(.system(size: 7.5, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(4)
                                .background { Circle().fill(applied ? DSColor.success : tint) }
                                .padding(7)
                        }
                        Spacer()
                    }
                } else if applied {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(3.5)
                                .background { Circle().fill(DSColor.success) }
                                .padding(7)
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .stroke(
                        selected ? tint.opacity(0.8) : Color.white.opacity(0.055),
                        lineWidth: selected ? 1.2 : 0.6
                    )
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Applied readout

    private var appliedReadout: some View {
        VStack(spacing: 8) {
            readoutRow(
                label: store.t("Selected", "Выбрано"),
                value: presetName(selectedPreset),
                tint: selectedPreset.accentColors.first ?? .white
            )
            readoutRow(
                label: store.t("Active in client", "Активно в клиенте"),
                value: presetName(settings.preset),
                tint: settings.enabled ? DSColor.success : DSColor.textTertiary
            )
            readoutRow(
                label: store.t("Layer type", "Тип слоя"),
                value: selectedPreset.isAnimated ? store.t("Animated", "Анимированное") : store.t("Static", "Статичное")
            )
            readoutRow(
                label: store.t("Master switch", "Главный переключатель"),
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

    private func applySelected() {
        store.hapticSuccess()
        withAnimation(.easeInOut(duration: 0.25)) {
            store.settings.sky.preset = selectedPreset
            store.settings.sky.enabled = true
        }
        store.showToast(
            store.t("\(presetName(selectedPreset)) sky applied", "Небо «\(presetName(selectedPreset))» применено"),
            icon: "cloud.moon.fill"
        )
    }

    // MARK: - Labels

    private func presetName(_ preset: SkyPreset) -> String {
        store.t(preset.titleEN, preset.titleRU)
    }

    private func temperatureShort(_ value: Double) -> String {
        if abs(value) < 0.02 {
            return store.t("NEUTRAL", "НЕЙТРАЛЬНО")
        }
        if value > 0 {
            return "\(store.t("WARM", "ТЕПЛО")) \(Int(value * 100))%"
        }
        return "\(store.t("COOL", "ХОЛОДНО")) \(Int(-value * 100))%"
    }

    private func temperatureLabel(_ value: Double) -> String {
        if abs(value) < 0.02 {
            return store.t("Neutral", "Нейтрально")
        }
        return String(format: "%+.0f%%", value * 100)
    }
}
