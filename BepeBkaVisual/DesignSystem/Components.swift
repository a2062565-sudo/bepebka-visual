import SwiftUI

// MARK: - Glass card

struct GlassCard<Content: View>: View {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = DesignConstants.cornerRadius
    var showsBorder: Bool = true
    @ViewBuilder var content: Content

    init(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = DesignConstants.cornerRadius,
        showsBorder: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.showsBorder = showsBorder
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.045), Color.white.opacity(0.012)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                if showsBorder {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.14), Color.white.opacity(0.035)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                }
            }
            .shadow(color: .black.opacity(0.28), radius: 22, y: 12)
    }
}

// MARK: - Module header

struct ModuleHeader: View {
    @EnvironmentObject private var store: ClientStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let category: AppCategory
    let subtitleEN: String
    let subtitleRU: String

    private var compact: Bool { horizontalSizeClass == .compact }

    var body: some View {
        HStack(alignment: .center, spacing: compact ? 14 : 20) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 9) {
                    Text("MODULE \(category.index)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .tracking(1.6)
                        .foregroundStyle(store.accentColor)

                    Capsule()
                        .fill(Color.white.opacity(0.16))
                        .frame(width: 18, height: 1)

                    Text(store.t("LOCAL PREVIEW", "ЛОКАЛЬНЫЙ ПРЕВЬЮ"))
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .tracking(1.1)
                        .foregroundStyle(DSColor.textTertiary)
                }

                Text(store.t(category.titleEN, category.titleRU))
                    .font(.system(size: compact ? 27 : 33, weight: .bold, design: .rounded))
                    .tracking(-0.8)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color.white.opacity(0.72)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(store.t(subtitleEN, subtitleRU))
                    .font(.system(size: compact ? 12 : 13, weight: .regular))
                    .foregroundStyle(DSColor.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 610, alignment: .leading)
            }

            Spacer(minLength: 4)

            ZStack {
                RoundedRectangle(cornerRadius: compact ? 16 : 19, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                store.accentColor.opacity(0.22),
                                store.accentColor.opacity(0.045)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: compact ? 16 : 19, style: .continuous)
                    .stroke(store.accentColor.opacity(0.3), lineWidth: 0.8)

                Image(systemName: category.icon)
                    .font(.system(size: compact ? 20 : 24, weight: .medium))
                    .foregroundStyle(store.accentColor)
                    .shadow(color: store.accentColor.opacity(0.5), radius: 8)
            }
            .frame(width: compact ? 48 : 62, height: compact ? 48 : 62)
            .shadow(color: store.accentColor.opacity(0.18), radius: 20)
        }
        .padding(.bottom, 2)
    }
}

// MARK: - Settings panel

struct SettingsPanel<Content: View>: View {
    let title: String
    var icon: String? = nil
    var subtitle: String? = nil
    var spacing: CGFloat = 8
    @ViewBuilder var content: Content

    init(
        title: String,
        icon: String? = nil,
        subtitle: String? = nil,
        spacing: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.subtitle = subtitle
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(DSColor.textTertiary)
                }
                Text(title)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .tracking(1.4)
                    .foregroundStyle(DSColor.textTertiary)
                    .textCase(.uppercase)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 4)

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 11.5))
                    .foregroundStyle(DSColor.textTertiary)
                    .padding(.horizontal, 4)
                    .padding(.top, -4)
            }

            VStack(spacing: spacing) {
                content
            }
        }
    }
}

// MARK: - Row styling

extension View {
    func premiumRowBackground(cornerRadius: CGFloat = 14) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.032))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.055), lineWidth: 0.7)
            )
    }
}

struct SettingGlyph: View {
    var icon: String
    var tint: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(tint.opacity(0.12))
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .stroke(tint.opacity(0.2), lineWidth: 0.7)
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(tint)
        }
        .frame(width: 30, height: 30)
    }
}

// MARK: - Badges

struct BVBadge: View {
    var text: String
    var tint: Color = Color.white
    var icon: String? = nil
    var filled: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 8, weight: .bold))
            }
            Text(text)
                .font(.system(size: 9.5, weight: .semibold))
                .tracking(0.5)
        }
        .foregroundStyle(filled ? (tint.isLight ? Color.black.opacity(0.82) : .white) : tint)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background {
            Capsule()
                .fill(filled ? tint : tint.opacity(0.11))
        }
        .overlay {
            Capsule()
                .stroke(tint.opacity(filled ? 0 : 0.22), lineWidth: 0.7)
        }
        .fixedSize()
    }
}

struct StatusDot: View {
    var color: Color
    var size: CGFloat = 6

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .shadow(color: color.opacity(0.9), radius: size)
            .overlay {
                Circle()
                    .stroke(color.opacity(0.35), lineWidth: 2)
                    .scaleEffect(2.1)
            }
    }
}

// MARK: - Buttons

enum PremiumButtonVariant {
    case primary
    case secondary
    case ghost
    case danger
}

struct PremiumButtonStyle: ButtonStyle {
    @EnvironmentObject private var store: ClientStore

    var variant: PremiumButtonVariant = .primary
    var tint: Color?

    func makeBody(configuration: Configuration) -> some View {
        let accent = tint ?? store.accentColor
        configuration.label
            .font(.system(size: 12.5, weight: .semibold, design: .rounded))
            .foregroundStyle(foregroundColor(accent: accent))
            .padding(.horizontal, 14)
            .frame(minHeight: 38)
            .background {
                background(accent: accent)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(borderColor(accent: accent), lineWidth: 0.8)
            }
            .shadow(
                color: variant == .primary ? accent.opacity(0.24) : .clear,
                radius: 14,
                y: 6
            )
            .scaleEffect(configuration.isPressed ? 0.965 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }

    private func foregroundColor(accent: Color) -> Color {
        switch variant {
        case .primary:
            return accent.isLight ? Color.black.opacity(0.88) : .white
        case .secondary:
            return DSColor.textPrimary
        case .ghost:
            return accent
        case .danger:
            return .white
        }
    }

    @ViewBuilder
    private func background(accent: Color) -> some View {
        switch variant {
        case .primary:
            LinearGradient(
                colors: [accent, accent.opacity(0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            LinearGradient(
                colors: [Color.white.opacity(0.085), Color.white.opacity(0.045)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .ghost:
            Color.white.opacity(0.028)
        case .danger:
            LinearGradient(
                colors: [Color(hex: "#FB7185"), Color(hex: "#E11D48")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func borderColor(accent: Color) -> Color {
        switch variant {
        case .primary: return Color.white.opacity(0.2)
        case .secondary: return Color.white.opacity(0.11)
        case .ghost: return accent.opacity(0.24)
        case .danger: return Color.white.opacity(0.18)
        }
    }
}

struct IconGlassButton: View {
    @EnvironmentObject private var store: ClientStore

    let icon: String
    var tint: Color?
    var size: CGFloat = 38
    var action: () -> Void

    var body: some View {
        Button {
            store.hapticTap()
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(tint ?? DSColor.textSecondary)
                .frame(width: size, height: size)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.055))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 0.8)
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Info banner

struct InfoBanner: View {
    let icon: String
    let title: String
    let message: String
    var tint: Color = DSColor.warning

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(tint.opacity(0.13))
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(tint)
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DSColor.textPrimary)
                Text(message)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(DSColor.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(13)
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(tint.opacity(0.045))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(tint.opacity(0.16), lineWidth: 0.8)
        }
    }
}

// MARK: - Tags

struct PreviewTag: View {
    var text: String
    var icon: String? = nil
    var tint: Color = .white

    var body: some View {
        HStack(spacing: 5) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 8, weight: .bold))
            } else {
                Circle()
                    .fill(tint)
                    .frame(width: 4, height: 4)
                    .shadow(color: tint, radius: 3)
            }
            Text(text)
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .tracking(1.0)
        }
        .foregroundStyle(tint.opacity(0.92))
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background {
            Capsule()
                .fill(Color.black.opacity(0.34))
        }
        .overlay {
            Capsule()
                .stroke(Color.white.opacity(0.09), lineWidth: 0.6)
        }
        .fixedSize()
    }
}

struct ValuePill: View {
    let text: String
    var tint: Color = DSColor.textSecondary

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold, design: .monospaced))
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Color.white.opacity(0.055))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 0.6)
            }
            .fixedSize()
    }
}

// MARK: - Search

struct BVSearchField: View {
    @EnvironmentObject private var store: ClientStore
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DSColor.textTertiary)

            TextField(placeholder, text: $text)
                .font(.system(size: 12.5))
                .foregroundStyle(DSColor.textPrimary)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !text.isEmpty {
                Button {
                    store.hapticTap()
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(DSColor.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(Color.white.opacity(0.045))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .stroke(Color.white.opacity(0.07), lineWidth: 0.7)
        }
    }
}

// MARK: - Chips

struct FilterChip: View {
    @EnvironmentObject private var store: ClientStore
    let title: String
    var icon: String? = nil
    var tint: Color?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            store.hapticSelect()
            withAnimation(.easeOut(duration: 0.2)) {
                action()
            }
        } label: {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 10, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 11.5, weight: .semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(
                isSelected
                    ? ((tint ?? store.accentColor).isLight ? Color.black.opacity(0.85) : .white)
                    : DSColor.textSecondary
            )
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background {
                Capsule()
                    .fill(isSelected ? (tint ?? store.accentColor) : Color.white.opacity(0.045))
            }
            .overlay {
                Capsule()
                    .stroke(
                        isSelected
                            ? Color.white.opacity(0.16)
                            : Color.white.opacity(0.075),
                        lineWidth: 0.7
                    )
            }
            .fixedSize()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty state

struct EmptyState: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.035))
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 0.7)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(DSColor.textTertiary)
            }
            .frame(width: 54, height: 54)

            VStack(spacing: 5) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DSColor.textPrimary)
                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(DSColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(PremiumButtonStyle(variant: .secondary))
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
        .premiumRowBackground(cornerRadius: 16)
    }
}

// MARK: - Toast

struct ToastView: View {
    let message: ToastMessage
    var tint: Color = Color(hex: "#4ADE80")

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: message.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)

            Text(message.title)
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundStyle(DSColor.textPrimary)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        }
        .overlay {
            Capsule()
                .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
        }
        .shadow(color: .black.opacity(0.45), radius: 20, y: 10)
        .padding(.horizontal, 18)
    }
}

// MARK: - Stats

struct BVStatTile: View {
    let icon: String
    let label: String
    let value: String
    var tint: Color = DSColor.textPrimary

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(tint)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(DSColor.textTertiary)
                Text(value)
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.035))
        }
    }
}
