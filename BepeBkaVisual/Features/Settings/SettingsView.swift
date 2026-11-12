import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: ClientStore

    @State private var showResetAlert = false

    private var settings: UISettings { store.settings.ui }

    private var effectiveFPS: Int {
        store.settings.ui.reduceLoad ? 30 : store.settings.ui.refreshRate.rawValue
    }

    private var activeConfigurationName: String {
        store.activeConfiguration?.name ?? store.t("Unsaved setup", "Свободная настройка")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ModuleHeader(
                category: .settings,
                subtitleEN: "Language, theme, accent, motion, and performance. Every preference is stored locally and applied instantly.",
                subtitleRU: "Язык, тема, акцент, анимации и производительность. Каждая настройка хранится локально и применяется мгновенно."
            )

            interfacePreview

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 330), spacing: 16, alignment: .top)],
                alignment: .leading,
                spacing: 18
            ) {
                SettingsPanel(
                    title: store.t("Interface & language", "Интерфейс и язык"),
                    icon: "globe"
                ) {
                    SettingSegmentedRow(
                        icon: "character.bubble.fill",
                        title: store.t("Interface Language", "Язык интерфейса"),
                        subtitle: store.t(
                            "All labels, descriptions, and notifications update instantly.",
                            "Все подписи, описания и уведомления обновляются мгновенно."
                        ),
                        options: AppLanguage.allCases,
                        selection: $store.settings.ui.language,
                        label: { $0.title }
                    )

                    SettingToggleRow(
                        icon: "hand.tap.fill",
                        title: store.t("Haptic Feedback", "Тактильная отдача"),
                        subtitle: store.t(
                            "Subtle vibrations for toggles, selections, and confirmed actions.",
                            "Мягкая вибрация для переключателей, выбора и подтверждённых действий."
                        ),
                        isOn: $store.settings.ui.hapticsEnabled
                    )

                    HStack(spacing: 11) {
                        SettingGlyph(icon: "info.circle.fill", tint: DSColor.textTertiary)
                        Text(store.t(
                            "Language is stored per device and is preserved when you apply a configuration.",
                            "Язык хранится на устройстве и сохраняется при применении конфигурации."
                        ))
                        .font(.system(size: 10.5))
                        .foregroundStyle(DSColor.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .premiumRowBackground()
                }

                SettingsPanel(
                    title: store.t("Theme & accent", "Тема и акцент"),
                    icon: "paintpalette.fill"
                ) {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 116), spacing: 8)],
                        spacing: 8
                    ) {
                        ForEach(AppTheme.allCases) { theme in
                            themeTile(theme)
                        }
                    }
                    .padding(.bottom, 2)

                    SettingColorRow(
                        icon: "paintbrush.fill",
                        title: store.t("Accent Color", "Акцентный цвет"),
                        subtitle: store.t(
                            "Buttons, glows, indicators, and live previews follow this color.",
                            "Кнопки, свечение, индикаторы и живые превью используют этот цвет."
                        ),
                        hex: $store.settings.ui.accentHex,
                        palette: AccentPalette.colors
                    )

                    HStack(spacing: 8) {
                        Circle()
                            .fill(store.accentColor)
                            .frame(width: 9, height: 9)
                            .shadow(color: store.accentColor, radius: 5)

                        Text(store.t("Custom colors are supported by the picker.", "Свои цвета поддерживаются через палитру."))
                            .font(.system(size: 10))
                            .foregroundStyle(DSColor.textTertiary)

                        Spacer(minLength: 4)

                        Text(store.settings.ui.accentHex.uppercased())
                            .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                            .foregroundStyle(DSColor.textTertiary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                }

                SettingsPanel(
                    title: store.t("Performance", "Производительность"),
                    icon: "speedometer"
                ) {
                    SettingToggleRow(
                        icon: "waveform.path",
                        title: store.t("Interface Animations", "Анимации интерфейса"),
                        subtitle: store.t(
                            "Ambient motion, transitions, and animated previews inside the Click GUI.",
                            "Фоновое движение, переходы и анимированные превью внутри Click GUI."
                        ),
                        isOn: $store.settings.ui.animationsEnabled
                    )

                    SettingSegmentedRow(
                        icon: "gauge.with.dots.needle.67percent",
                        title: store.t("Visual Refresh Rate", "Частота обновления"),
                        subtitle: store.settings.ui.reduceLoad
                            ? store.t(
                                "Locked to 30 FPS while Reduce Device Load is enabled.",
                                "Ограничено 30 FPS, пока включено снижение нагрузки."
                            )
                            : store.t(
                                "Target frame rate for particle, sky, and effect previews.",
                                "Целевая частота кадров для превью частиц, неба и эффектов."
                            ),
                        options: RefreshRate.allCases,
                        selection: $store.settings.ui.refreshRate,
                        label: { $0.title }
                    )
                    .disabled(store.settings.ui.reduceLoad)
                    .opacity(store.settings.ui.reduceLoad ? 0.45 : 1)

                    SettingToggleRow(
                        icon: "leaf.fill",
                        title: store.t("Reduce Device Load", "Снизить нагрузку"),
                        subtitle: store.t(
                            "Caps animation at 30 FPS and lowers particle density to protect battery life.",
                            "Ограничивает анимацию 30 FPS и уменьшает плотность частиц для экономии батареи."
                        ),
                        isOn: $store.settings.ui.reduceLoad
                    )

                    HStack(spacing: 8) {
                        perfStat(
                            icon: "speedometer",
                            label: store.t("TARGET", "ЦЕЛЬ"),
                            value: "\(effectiveFPS) FPS",
                            tint: store.accentColor
                        )
                        perfStat(
                            icon: "circle.grid.3x3.fill",
                            label: store.t("PARTICLES", "ЧАСТИЦЫ"),
                            value: store.settings.ui.reduceLoad ? "55%" : "100%",
                            tint: DSColor.textSecondary
                        )
                        perfStat(
                            icon: "waveform",
                            label: store.t("MOTION", "ДВИЖЕНИЕ"),
                            value: settings.animationsEnabled ? store.t("ON", "ВКЛ") : store.t("OFF", "ВЫКЛ"),
                            tint: settings.animationsEnabled ? DSColor.success : DSColor.warning
                        )
                    }
                }

                SettingsPanel(
                    title: store.t("Client & storage", "Клиент и хранение"),
                    icon: "internaldrive.fill"
                ) {
                    VStack(spacing: 0) {
                        infoRow(
                            icon: "app.badge.fill",
                            label: store.t("Version", "Версия"),
                            value: "\(AppInfo.version) · \(AppInfo.build)"
                        )
                        BVThinDivider()
                        infoRow(
                            icon: "iphone.gen3",
                            label: store.t("Platform", "Платформа"),
                            value: "iOS / iPadOS"
                        )
                        BVThinDivider()
                        infoRow(
                            icon: "externaldrive.fill",
                            label: store.t("Storage", "Хранилище"),
                            value: store.t("UserDefaults · JSON", "UserDefaults · JSON")
                        )
                        BVThinDivider()
                        infoRow(
                            icon: "square.stack.3d.up.fill",
                            label: store.t("Custom profiles", "Свои профили"),
                            value: "\(store.customConfigurations.count)"
                        )
                        BVThinDivider()
                        infoRow(
                            icon: "bolt.fill",
                            label: store.t("Active configuration", "Активная конфигурация"),
                            value: activeConfigurationName,
                            tint: store.accentColor
                        )
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 3)
                    .premiumRowBackground()

                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 140), spacing: 8)],
                        spacing: 8
                    ) {
                        Button {
                            saveNow()
                        } label: {
                            HStack(spacing: 7) {
                                Image(systemName: "checkmark.icloud.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                Text(store.t("Save now", "Сохранить сейчас"))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Spacer(minLength: 0)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PremiumButtonStyle(variant: .secondary))

                        Button {
                            store.hapticTap()
                            showResetAlert = true
                        } label: {
                            HStack(spacing: 7) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 11, weight: .semibold))
                                Text(store.t("Reset settings", "Сбросить настройки"))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Spacer(minLength: 0)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PremiumButtonStyle(variant: .danger))
                    }

                    Text(store.t(
                        "Preferences save automatically after each change. Custom configurations are kept when settings are reset.",
                        "Настройки сохраняются автоматически после каждого изменения. При сбросе пользовательские конфигурации сохраняются."
                    ))
                    .font(.system(size: 10))
                    .foregroundStyle(DSColor.textTertiary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
                }
            }

            InfoBanner(
                icon: "shield.lefthalf.filled",
                title: store.t("Local demonstration client", "Локальный демонстрационный клиент"),
                message: store.t(
                    "BepeBka Visual does not inject into Standoff 2, read game memory, or modify game files. An official developer-authorized SDK is required for any real integration, so every module remains an interactive local preview.",
                    "BepeBka Visual не внедряется в Standoff 2, не читает память игры и не изменяет её файлы. Для реальной интеграции нужен официальный SDK от разработчиков, поэтому все модули остаются интерактивным локальным превью."
                ),
                tint: store.accentColor
            )
        }
        .alert(
            store.t("Reset all settings?", "Сбросить все настройки?"),
            isPresented: $showResetAlert
        ) {
            Button(store.t("Cancel", "Отмена"), role: .cancel) {}
            Button(store.t("Reset settings", "Сбросить настройки"), role: .destructive) {
                resetSettings()
            }
        } message: {
            Text(store.t(
                "Language, theme, accent, motion, performance, and every module setting return to demo defaults. Custom configurations stay on this device.",
                "Язык, тема, акцент, анимации, производительность и настройки всех модулей вернутся к стандартным. Пользовательские конфигурации останутся на устройстве."
            ))
        }
    }

    // MARK: - Live preview

    private var interfacePreview: some View {
        ZStack {
            LinearGradient(
                colors: store.theme.previewColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [store.accentColor.opacity(0.26), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 130
                    )
                )
                .frame(width: 260, height: 260)
                .blur(radius: 20)
                .offset(x: 120, y: -70)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 9) {
                    BVLogoMark(size: 28, showSparkle: false)

                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 5) {
                            Text(AppInfo.shortName)
                                .font(.system(size: 12.5, weight: .bold, design: .rounded))
                                .foregroundStyle(DSColor.textPrimary)

                            Text("VISUAL")
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                                .tracking(1)
                                .foregroundStyle(store.accentColor)
                        }

                        Text(store.t("LIVE INTERFACE PREVIEW", "ЖИВОЕ ПРЕВЬЮ ИНТЕРФЕЙСА"))
                            .font(.system(size: 7.5, weight: .medium, design: .monospaced))
                            .tracking(1.1)
                            .foregroundStyle(DSColor.textTertiary)
                    }

                    Spacer(minLength: 6)

                    BVBadge(
                        text: store.settings.ui.language.shortCode,
                        icon: "globe",
                        tint: store.accentColor
                    )
                }

                HStack(spacing: 7) {
                    previewMetric(
                        icon: "circle.lefthalf.filled",
                        text: themeName(store.theme)
                    )
                    previewMetric(
                        icon: "speedometer",
                        text: "\(effectiveFPS) FPS"
                    )
                    previewMetric(
                        icon: "waveform",
                        text: settings.animationsEnabled
                            ? store.t("MOTION", "ДВИЖЕНИЕ")
                            : store.t("STATIC", "СТАТИКА")
                    )

                    Spacer(minLength: 0)
                }

                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.t("Accent, theme, and language apply instantly", "Акцент, тема и язык применяются сразу"))
                            .font(.system(size: 10.5, weight: .medium))
                            .foregroundStyle(DSColor.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Text(store.t("Every preference is saved on this device.", "Каждая настройка сохраняется на этом устройстве."))
                            .font(.system(size: 9))
                            .foregroundStyle(DSColor.textTertiary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 4)

                    ToggleVisual(isOn: settings.animationsEnabled, tint: store.accentColor)
                        .scaleEffect(0.9)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 9)
                .background {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 0.7)
                }
            }
            .padding(14)
        }
        .frame(height: 184)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [store.accentColor.opacity(0.38), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.9
                )
        }
        .shadow(color: .black.opacity(0.32), radius: 24, y: 14)
    }

    private func previewMetric(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(store.accentColor.opacity(0.85))

            Text(text)
                .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                .foregroundStyle(DSColor.textSecondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background {
            Capsule().fill(Color.black.opacity(0.26))
        }
        .overlay {
            Capsule().stroke(Color.white.opacity(0.06), lineWidth: 0.6)
        }
    }

    // MARK: - Theme tile

    private func themeTile(_ theme: AppTheme) -> some View {
        let selected = store.settings.ui.theme == theme

        return Button {
            store.hapticSelect()
            withAnimation(.easeInOut(duration: 0.25)) {
                store.settings.ui.theme = theme
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    LinearGradient(
                        colors: theme.previewColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [store.accentColor.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 48
                            )
                        )
                        .frame(width: 90, height: 90)
                        .offset(x: 44, y: -28)

                    HStack {
                        Text("Aa")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.86))

                        Spacer(minLength: 0)

                        if selected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(store.accentColor)
                        }
                    }
                    .padding(9)
                }
                .frame(height: 48)

                HStack(spacing: 5) {
                    Circle()
                        .fill(selected ? store.accentColor : Color.white.opacity(0.25))
                        .frame(width: 4, height: 4)

                    Text(themeName(theme))
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundStyle(selected ? DSColor.textPrimary : DSColor.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.2))
            }
            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .stroke(
                        selected ? store.accentColor.opacity(0.7) : Color.white.opacity(0.06),
                        lineWidth: selected ? 1.1 : 0.7
                    )
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Small components

    private func perfStat(icon: String, label: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 8.5, weight: .medium))
                    .foregroundStyle(tint)
                Text(label)
                    .font(.system(size: 7.5, weight: .semibold, design: .monospaced))
                    .tracking(0.6)
                    .foregroundStyle(DSColor.textTertiary)
            }

            Text(value)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.03))
        }
    }

    private func infoRow(
        icon: String,
        label: String,
        value: String,
        tint: Color = DSColor.textPrimary
    ) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(DSColor.textTertiary)
                .frame(width: 15)

            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(DSColor.textSecondary)

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 9)
    }

    // MARK: - Helpers

    private func themeName(_ theme: AppTheme) -> String {
        store.t(theme.titleEN, theme.titleRU)
    }

    private func saveNow() {
        store.hapticSuccess()
        store.saveNow()
        store.showToast(
            store.t("All data saved locally", "Все данные сохранены локально"),
            icon: "checkmark.icloud.fill"
        )
    }

    private func resetSettings() {
        store.hapticSuccess()
        withAnimation(.easeInOut(duration: 0.28)) {
            store.resetSettings()
        }
        store.showToast(
            store.t("Settings reset to defaults", "Настройки сброшены к стандартным"),
            icon: "arrow.counterclockwise"
        )
    }
}
