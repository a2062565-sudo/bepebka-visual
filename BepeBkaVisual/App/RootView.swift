import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: ClientStore
    @Environment(\.scenePhase) private var scenePhase

    @State private var selection: AppCategory = .visuals
    @State private var guiOpen = true

    var body: some View {
        ZStack {
            AmbientBackground()

            if guiOpen {
                ClientShellView(selection: $selection) {
                    withAnimation(.easeInOut(duration: 0.28)) {
                        guiOpen = false
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.985)))
            } else {
                MenuClosedView(
                    onOpen: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            guiOpen = true
                        }
                    },
                    onOpenSettings: {
                        selection = .settings
                        withAnimation(.easeOut(duration: 0.3)) {
                            guiOpen = true
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 1.015)))
            }
        }
        .preferredColorScheme(.dark)
        .tint(store.accentColor)
        .overlay(alignment: .top) {
            if let toast = store.toast {
                ToastView(message: toast, tint: store.accentColor)
                    .frame(maxWidth: 470)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(50)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active {
                store.saveNow()
            }
        }
    }
}

struct MenuClosedView: View {
    @EnvironmentObject private var store: ClientStore

    let onOpen: () -> Void
    let onOpenSettings: () -> Void

    private var activeName: String {
        store.activeConfiguration?.name ?? store.t("Unsaved setup", "Свободная настройка")
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: 30)

                    hero
                        .padding(.bottom, 26)

                    GlassCard(padding: 16, cornerRadius: 22) {
                        VStack(spacing: 12) {
                            statusRow
                            Rectangle()
                                .fill(Color.white.opacity(0.055))
                                .frame(height: 0.7)
                            quickActions
                        }
                    }
                    .frame(maxWidth: 460)

                    HStack(spacing: 10) {
                        Button {
                            store.hapticSuccess()
                            onOpen()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "square.grid.2x2.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                Text(store.t("Reopen Click GUI", "Открыть Click GUI"))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PremiumButtonStyle(variant: .primary))

                        Button {
                            store.hapticTap()
                            onOpenSettings()
                        } label: {
                            HStack(spacing: 7) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                Text(store.t("Settings", "Настройки"))
                            }
                        }
                        .buttonStyle(PremiumButtonStyle(variant: .secondary))
                    }
                    .frame(maxWidth: 460)
                    .padding(.top, 14)

                    Text(store.t(
                        "All changes are stored locally on this device. BepeBka Visual runs in an interactive demonstration mode and does not connect to Standoff 2 without an official developer-authorized SDK.",
                        "Все изменения хранятся локально на этом устройстве. BepeBka Visual работает в интерактивном демо-режиме и не подключается к Standoff 2 без официального SDK, разрешённого разработчиками."
                    ))
                    .font(.system(size: 10.5))
                    .foregroundStyle(DSColor.textTertiary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .frame(maxWidth: 390)
                    .padding(.top, 24)

                    Spacer(minLength: 30)

                    HStack(spacing: 8) {
                        BVLogoMark(size: 18, showSparkle: false)
                            .opacity(0.5)
                        Text("\(AppInfo.name) v\(AppInfo.version)")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(DSColor.textTertiary)
                        Text("·")
                            .foregroundStyle(DSColor.textTertiary)
                        Text("iOS / iPadOS")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(DSColor.textTertiary)
                    }
                }
                .padding(.horizontal, 22)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height)
            }
        }
    }

    private var hero: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [store.accentColor.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 12)

                BVLogoMark(size: 86)
            }

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Text("BepeBka")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .tracking(-0.6)
                        .foregroundStyle(DSColor.textPrimary)

                    Text("VISUAL")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .tracking(1.7)
                        .foregroundStyle(store.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background {
                            Capsule().fill(store.accentColor.opacity(0.11))
                        }
                        .overlay {
                            Capsule().stroke(store.accentColor.opacity(0.25), lineWidth: 0.7)
                        }
                }

                Text(store.t("CLICK GUI MINIMIZED", "CLICK GUI СВЁРНУТ"))
                    .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                    .tracking(2.2)
                    .foregroundStyle(DSColor.textTertiary)

                Text(store.t(
                    "Your visual setup is still running in the background.",
                    "Ваша визуальная конфигурация продолжает работать в фоне."
                ))
                .font(.system(size: 12.5))
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 2)
            }
        }
    }

    private var statusRow: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(store.accentColor.opacity(0.12))
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(store.accentColor.opacity(0.22), lineWidth: 0.7)
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(store.accentColor)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 3) {
                Text(store.t("ACTIVE CONFIGURATION", "АКТИВНАЯ КОНФИГУРАЦИЯ"))
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .tracking(1.1)
                    .foregroundStyle(DSColor.textTertiary)
                Text(activeName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            HStack(spacing: 6) {
                StatusDot(color: DSColor.warning, size: 4)
                Text(store.t("DEMO", "ДЕМО"))
                    .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                    .tracking(0.8)
                    .foregroundStyle(DSColor.textSecondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background {
                Capsule().fill(Color.white.opacity(0.04))
            }
            .overlay {
                Capsule().stroke(Color.white.opacity(0.07), lineWidth: 0.6)
            }
        }
    }

    private var quickActions: some View {
        HStack(spacing: 8) {
            statItem(
                icon: "slider.horizontal.3",
                title: store.t("Accent", "Акцент"),
                value: store.settings.ui.accentHex.uppercased(),
                tint: store.accentColor
            )
            statItem(
                icon: "square.stack.3d.up",
                title: store.t("Profiles", "Профили"),
                value: "\(store.customConfigurations.count)",
                tint: DSColor.textSecondary
            )
            statItem(
                icon: "iphone",
                title: store.t("Storage", "Хранение"),
                value: store.t("Local", "Локально"),
                tint: DSColor.textSecondary
            )
        }
    }

    private func statItem(icon: String, title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(tint)

            Text(title)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(DSColor.textTertiary)

            Text(value)
                .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.028))
        }
    }
}
