import SwiftUI

struct ClientShellView: View {
    @EnvironmentObject private var store: ClientStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Binding var selection: AppCategory
    let onClose: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let useSidebar = geometry.size.width >= 720
            let compactHeader = geometry.size.width < 560
            let showHeaderStatus = geometry.size.width >= 360

            VStack(spacing: 0) {
                ShellHeader(
                    selection: $selection,
                    compact: compactHeader,
                    showsStatus: showHeaderStatus,
                    onClose: onClose
                )

                if useSidebar {
                    HStack(spacing: 0) {
                        ShellSidebar(selection: $selection)
                            .frame(width: 232)

                        Rectangle()
                            .fill(Color.white.opacity(0.055))
                            .frame(width: 0.7)

                        moduleArea(compact: false)
                    }
                } else {
                    CompactCategoryRail(selection: $selection)
                    moduleArea(compact: true)
                }
            }
        }
    }

    private func moduleArea(compact: Bool) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                moduleContent
                ShellFooter()
            }
            .padding(.horizontal, compact ? 15 : 22)
            .padding(.top, compact ? 16 : 22)
            .padding(.bottom, 30)
            .frame(maxWidth: DesignConstants.contentMaxWidth, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .id(selection)
        .scrollDismissesKeyboard(.interactively)
    }

    @ViewBuilder
    private var moduleContent: some View {
        switch selection {
        case .visuals:
            VisualsView()
        case .targetHUD:
            TargetHUDView()
        case .particles:
            ParticlesView()
        case .killEffects:
            KillEffectsView()
        case .skinChanger:
            SkinChangerView()
        case .skyChanger:
            SkyChangerView()
        case .environment:
            EnvironmentView()
        case .crosshair:
            CrosshairView()
        case .configs:
            ConfigsView()
        case .settings:
            SettingsView()
        }
    }
}

// MARK: - Header

private struct ShellHeader: View {
    @EnvironmentObject private var store: ClientStore
    @Binding var selection: AppCategory
    let compact: Bool
    let showsStatus: Bool
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            BVLogoMark(size: compact ? 34 : 38)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 7) {
                    Text(AppInfo.shortName)
                        .font(.system(size: compact ? 14 : 15, weight: .bold, design: .rounded))
                        .foregroundStyle(DSColor.textPrimary)
                        .lineLimit(1)

                    Text("VISUAL")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .tracking(1.2)
                        .foregroundStyle(store.accentColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2.5)
                        .background {
                            Capsule().fill(store.accentColor.opacity(0.12))
                        }
                        .overlay {
                            Capsule().stroke(store.accentColor.opacity(0.22), lineWidth: 0.5)
                        }

                    if !compact {
                        Text("v\(AppInfo.version)")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(DSColor.textTertiary)
                    }
                }

                if !compact {
                    Text(store.t("PREMIUM VISUAL LABORATORY", "ПРЕМИАЛЬНАЯ ВИЗУАЛЬНАЯ ЛАБОРАТОРИЯ"))
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .tracking(0.9)
                        .foregroundStyle(DSColor.textTertiary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 4)

            if showsStatus {
                HStack(spacing: 7) {
                    StatusDot(color: DSColor.warning, size: 5)
                    Text(compact ? store.t("DEMO", "ДЕМО") : store.t("DEMO MODE", "ДЕМО-РЕЖИМ"))
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .tracking(0.6)
                        .foregroundStyle(DSColor.textSecondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background {
                    Capsule().fill(Color.white.opacity(0.035))
                }
                .overlay {
                    Capsule().stroke(Color.white.opacity(0.07), lineWidth: 0.6)
                }
                .fixedSize()
            }

            HStack(spacing: 6) {
                IconGlassButton(icon: "gearshape.fill", size: compact ? 34 : 38) {
                    withAnimation(.easeOut(duration: 0.22)) {
                        selection = .settings
                    }
                }

                Button {
                    store.hapticTap()
                    onClose()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DSColor.textSecondary)
                        .frame(width: compact ? 34 : 38, height: compact ? 34 : 38)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.035))
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.065), lineWidth: 0.7)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, compact ? 14 : 20)
        .frame(height: compact ? 58 : 68)
        .background {
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                LinearGradient(
                    colors: [Color.white.opacity(0.03), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 0.7)
        }
    }
}

// MARK: - Sidebar

private struct SidebarGroup: Identifiable {
    let id: String
    let title: String
    let items: [AppCategory]
}

private struct ShellSidebar: View {
    @EnvironmentObject private var store: ClientStore
    @Binding var selection: AppCategory

    private var groups: [SidebarGroup] {
        let order: [String] = ["APPEARANCE", "WORLD", "SYSTEM"]
        return order.map { key in
            let items = AppCategory.allCases.filter { $0.groupEN == key }
            let title = store.t(key, items.first?.groupRU ?? key)
            return SidebarGroup(id: key, title: title, items: items)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(store.t("WORKSPACE", "РАБОЧАЯ ОБЛАСТЬ"))
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .tracking(1.4)
                            .foregroundStyle(DSColor.textTertiary)
                        Spacer()
                        Text("\(AppCategory.allCases.count)")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(DSColor.textTertiary)
                    }
                    .padding(.horizontal, 4)

                    ForEach(groups) { group in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(group.title)
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                                .tracking(1.2)
                                .foregroundStyle(DSColor.textTertiary.opacity(0.7))
                                .padding(.horizontal, 12)
                                .padding(.bottom, 3)

                            ForEach(group.items) { category in
                                SidebarRow(
                                    category: category,
                                    isSelected: selection == category
                                ) {
                                    store.hapticSelect()
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        selection = category
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 18)
                .padding(.bottom, 20)
            }

            SidebarFooter()
                .padding(.horizontal, 12)
                .padding(.bottom, 14)
        }
        .background {
            LinearGradient(
                colors: [Color.white.opacity(0.018), Color.black.opacity(0.18)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

private struct SidebarRow: View {
    @EnvironmentObject private var store: ClientStore
    let category: AppCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: category.icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? store.accentColor : DSColor.textTertiary)
                    .frame(width: 18)

                Text(store.t(category.titleEN, category.titleRU))
                    .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? DSColor.textPrimary : DSColor.textSecondary)
                    .lineLimit(1)

                Spacer(minLength: 4)

                if isSelected {
                    Circle()
                        .fill(store.accentColor)
                        .frame(width: 4, height: 4)
                        .shadow(color: store.accentColor, radius: 4)
                } else {
                    Text(category.index)
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundStyle(DSColor.textTertiary.opacity(0.45))
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 36)
            .background {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(isSelected ? store.accentColor.opacity(0.1) : Color.clear)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(isSelected ? store.accentColor.opacity(0.18) : .clear, lineWidth: 0.7)
            }
            .overlay(alignment: .leading) {
                if isSelected {
                    Capsule()
                        .fill(store.accentColor)
                        .frame(width: 2, height: 15)
                        .offset(x: -0.5)
                        .shadow(color: store.accentColor.opacity(0.8), radius: 4)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct SidebarFooter: View {
    @EnvironmentObject private var store: ClientStore

    private var activeName: String {
        store.activeConfiguration?.name
            ?? store.t("Unsaved setup", "Свободная настройка")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 7) {
                StatusDot(color: DSColor.success, size: 4)
                Text(store.t("ACTIVE CONFIG", "АКТИВНЫЙ КОНФИГ"))
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .tracking(1.0)
                    .foregroundStyle(DSColor.textTertiary)
                Spacer(minLength: 0)
            }

            Text(activeName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(1)

            HStack(spacing: 6) {
                ForEach(Array(AccentPalette.colors.prefix(6)), id: \.self) { color in
                    Button {
                        store.setAccent(color)
                    } label: {
                        Circle()
                            .fill(Color(hex: color))
                            .frame(width: 14, height: 14)
                            .overlay {
                                Circle()
                                    .stroke(Color.white.opacity(0.16), lineWidth: 0.6)
                            }
                            .overlay {
                                if color.caseInsensitiveCompare(store.settings.ui.accentHex) == .orderedSame {
                                    Circle()
                                        .stroke(Color.white.opacity(0.9), lineWidth: 1)
                                        .padding(-2.5)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 0)

                Text(store.t("LOCAL", "ЛОКАЛЬНО"))
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(DSColor.textTertiary)
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Color.white.opacity(0.03))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 0.7)
        }
    }
}

// MARK: - Compact navigation

private struct CompactCategoryRail: View {
    @EnvironmentObject private var store: ClientStore
    @Binding var selection: AppCategory

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(AppCategory.allCases) { category in
                        let selected = category == selection

                        Button {
                            store.hapticSelect()
                            withAnimation(.easeOut(duration: 0.2)) {
                                selection = category
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 10, weight: .semibold))
                                Text(store.t(category.titleEN, category.titleRU))
                                    .font(.system(size: 11, weight: .semibold))
                                    .lineLimit(1)
                            }
                            .foregroundStyle(
                                selected
                                    ? (store.accentColor.isLight ? Color.black.opacity(0.85) : .white)
                                    : DSColor.textSecondary
                            )
                            .padding(.horizontal, 11)
                            .frame(height: 32)
                            .background {
                                Capsule()
                                    .fill(selected ? store.accentColor : Color.white.opacity(0.04))
                            }
                            .overlay {
                                Capsule()
                                    .stroke(
                                        selected ? Color.white.opacity(0.16) : Color.white.opacity(0.06),
                                        lineWidth: 0.7
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                        .id(category.id)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 9)
            }
            .onAppear {
                proxy.scrollTo(selection.id, anchor: .center)
            }
            .onChange(of: selection) { _, newValue in
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo(newValue.id, anchor: .center)
                }
            }
        }
        .background {
            Rectangle().fill(.ultraThinMaterial)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.white.opacity(0.055))
                .frame(height: 0.7)
        }
    }
}

// MARK: - Shell footer

private struct ShellFooter: View {
    @EnvironmentObject private var store: ClientStore

    var body: some View {
        HStack(spacing: 10) {
            BVLogoMark(size: 22, showSparkle: false)
                .opacity(0.65)

            Text("\(AppInfo.name) · v\(AppInfo.version)")
                .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                .foregroundStyle(DSColor.textTertiary)

            Spacer(minLength: 8)

            Text(store.t("LOCAL VISUAL PREVIEW · NO GAME INTEGRATION", "ЛОКАЛЬНЫЙ ПРЕВЬЮ · БЕЗ ИНТЕГРАЦИИ С ИГРОЙ"))
                .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                .tracking(0.4)
                .foregroundStyle(DSColor.textTertiary.opacity(0.65))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.top, 8)
        .padding(.horizontal, 4)
    }
}
