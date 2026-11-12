import SwiftUI

// MARK: - Premium toggle

struct ToggleVisual: View {
    var isOn: Bool
    var tint: Color

    var body: some View {
        ZStack {
            Capsule()
                .fill(Color.white.opacity(0.09))
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [tint, tint.opacity(0.72)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(isOn ? 1 : 0)
            Capsule()
                .stroke(Color.white.opacity(isOn ? 0.18 : 0.07), lineWidth: 0.7)

            HStack(spacing: 0) {
                if isOn { Spacer(minLength: 0) }
                Circle()
                    .fill(isOn ? (tint.isLight ? Color.black.opacity(0.82) : .white) : Color.white.opacity(0.72))
                    .frame(width: 17, height: 17)
                    .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
                if !isOn { Spacer(minLength: 0) }
            }
            .padding(3)
        }
        .frame(width: 40, height: 23)
        .animation(.spring(response: 0.28, dampingFraction: 0.78), value: isOn)
    }
}

struct SettingToggleRow: View {
    @EnvironmentObject private var store: ClientStore

    let icon: String
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool
    var tint: Color? = nil
    var disabled: Bool = false

    private var accent: Color { tint ?? store.accentColor }

    var body: some View {
        HStack(spacing: 11) {
            SettingGlyph(icon: icon, tint: accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(DSColor.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 10.5))
                        .foregroundStyle(DSColor.textTertiary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 8)

            ToggleVisual(isOn: isOn, tint: accent)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(minHeight: 54)
        .contentShape(Rectangle())
        .premiumRowBackground()
        .opacity(disabled ? 0.4 : 1)
        .onTapGesture {
            guard !disabled else { return }
            store.hapticTap()
            withAnimation(.easeOut(duration: 0.18)) {
                isOn.toggle()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

// MARK: - Slider

struct SettingSliderRow: View {
    @EnvironmentObject private var store: ClientStore

    let icon: String
    let title: String
    var subtitle: String? = nil
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 0.01
    var tint: Color? = nil
    var disabled: Bool = false
    var valueFormatter: ((Double) -> String)? = nil

    private var accent: Color { tint ?? store.accentColor }

    private var valueText: String {
        if let valueFormatter {
            return valueFormatter(value)
        }
        if step >= 1 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.2f", value)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 11) {
                SettingGlyph(icon: icon, tint: accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundStyle(DSColor.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 10.5))
                            .foregroundStyle(DSColor.textTertiary)
                            .lineLimit(2)
                    }
                }

                Spacer(minLength: 8)
                ValuePill(text: valueText, tint: accent)
            }

            Slider(value: $value, in: range, step: step)
                .tint(accent)
                .frame(height: 18)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .premiumRowBackground()
        .opacity(disabled ? 0.4 : 1)
        .disabled(disabled)
    }
}

// MARK: - Segmented control

struct PremiumSegmented<Option: Hashable>: View {
    @EnvironmentObject private var store: ClientStore

    let options: [Option]
    @Binding var selection: Option
    let label: (Option) -> String
    var tint: Color? = nil

    private var accent: Color { tint ?? store.accentColor }

    var body: some View {
        HStack(spacing: 3) {
            ForEach(options, id: \.self) { option in
                let selected = option == selection

                Button {
                    store.hapticSelect()
                    withAnimation(.easeOut(duration: 0.2)) {
                        selection = option
                    }
                } label: {
                    Text(label(option))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(
                            selected
                                ? (accent.isLight ? Color.black.opacity(0.82) : Color.white)
                                : DSColor.textSecondary
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background {
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(selected ? accent : Color.clear)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.22))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.055), lineWidth: 0.7)
        }
    }
}

struct SettingSegmentedRow<Option: Hashable>: View {
    @EnvironmentObject private var store: ClientStore

    let icon: String
    let title: String
    var subtitle: String? = nil
    let options: [Option]
    @Binding var selection: Option
    let label: (Option) -> String
    var tint: Color? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 11) {
                SettingGlyph(icon: icon, tint: tint ?? store.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundStyle(DSColor.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 10.5))
                            .foregroundStyle(DSColor.textTertiary)
                    }
                }
                Spacer(minLength: 0)
            }

            PremiumSegmented(
                options: options,
                selection: $selection,
                label: label,
                tint: tint
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .premiumRowBackground()
    }
}

// MARK: - Color

struct SettingColorRow: View {
    @EnvironmentObject private var store: ClientStore

    let icon: String
    let title: String
    var subtitle: String? = nil
    @Binding var hex: String
    var palette: [String] = []
    var tint: Color? = nil

    private var accent: Color { tint ?? store.accentColor }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 11) {
                SettingGlyph(icon: icon, tint: accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundStyle(DSColor.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 10.5))
                            .foregroundStyle(DSColor.textTertiary)
                    }
                }

                Spacer(minLength: 8)

                Text(hex.uppercased())
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(DSColor.textTertiary)

                ColorPicker("", selection: $hex.asColor(), supportsOpacity: false)
                    .labelsHidden()
                    .frame(width: 26, height: 26)
            }

            if !palette.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(palette, id: \.self) { colorHex in
                            let selected = colorHex.caseInsensitiveCompare(hex) == .orderedSame

                            Button {
                                store.hapticSelect()
                                withAnimation(.easeOut(duration: 0.2)) {
                                    hex = colorHex
                                }
                            } label: {
                                Circle()
                                    .fill(Color(hex: colorHex))
                                    .frame(width: 19, height: 19)
                                    .overlay {
                                        Circle()
                                            .stroke(Color.white.opacity(0.18), lineWidth: 0.7)
                                    }
                                    .overlay {
                                        if selected {
                                            Circle()
                                                .stroke(Color.white.opacity(0.9), lineWidth: 1.4)
                                                .padding(-3)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 1)
                    .padding(.vertical, 3)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .premiumRowBackground()
    }
}

// MARK: - Picker field

struct SettingPickerField<Option: Hashable>: View {
    @EnvironmentObject private var store: ClientStore

    let icon: String
    let title: String
    var subtitle: String? = nil
    let options: [Option]
    @Binding var selection: Option
    let label: (Option) -> String
    var tint: Color? = nil

    var body: some View {
        HStack(spacing: 11) {
            SettingGlyph(icon: icon, tint: tint ?? store.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(DSColor.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 10.5))
                        .foregroundStyle(DSColor.textTertiary)
                }
            }

            Spacer(minLength: 8)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        store.hapticSelect()
                        selection = option
                    } label: {
                        if option == selection {
                            Label(label(option), systemImage: "checkmark")
                        } else {
                            Text(label(option))
                        }
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Text(label(selection))
                        .font(.system(size: 11, weight: .semibold))
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 8, weight: .bold))
                }
                .foregroundStyle(tint ?? store.accentColor)
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.white.opacity(0.07), lineWidth: 0.6)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(minHeight: 54)
        .premiumRowBackground()
    }
}

// MARK: - Divider

struct BVThinDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.055))
            .frame(height: 0.7)
            .padding(.vertical, 2)
    }
}

// MARK: - Selectable tile

struct SelectableMiniCard: View {
    var title: String
    var subtitle: String? = nil
    var icon: String? = nil
    var isSelected: Bool
    var tint: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(isSelected ? tint : DSColor.textSecondary)
                    }
                    Spacer(minLength: 0)
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(tint)
                    }
                }

                Text(title)
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 9.5))
                        .foregroundStyle(DSColor.textTertiary)
                        .lineLimit(1)
                }
            }
            .padding(11)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? tint.opacity(0.1) : Color.white.opacity(0.032))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isSelected ? tint.opacity(0.42) : Color.white.opacity(0.055),
                        lineWidth: isSelected ? 1 : 0.7
                    )
            }
        }
        .buttonStyle(.plain)
    }
}
