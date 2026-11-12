import SwiftUI
import UIKit

struct ConfigsView: View {
    @EnvironmentObject private var store: ClientStore

    @State private var showSaveSheet = false
    @State private var showImportSheet = false
    @State private var renameTarget: ClientConfiguration?
    @State private var exportPayload: ConfigurationExportPayload?
    @State private var deleteTarget: ClientConfiguration?
    @State private var showDeleteAlert = false

    private var customConfigurations: [ClientConfiguration] {
        store.customConfigurations.sorted { $0.createdAt > $1.createdAt }
    }

    private var suggestedName: String {
        guard let active = store.activeConfiguration else {
            return store.t("My Config", "Мой конфиг")
        }
        return store.t("\(active.name) Copy", "\(active.name) — копия")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ModuleHeader(
                category: .configs,
                subtitleEN: "Save entire visual setups, switch between profiles in a single tap, and move your presets as portable JSON.",
                subtitleRU: "Сохраняйте целые визуальные сборки, переключайте профили одним нажатием и переносите пресеты в виде JSON."
            )

            activeOverview

            SettingsPanel(
                title: store.t("Built-in configurations", "Встроенные конфигурации"),
                icon: "square.stack.3d.up.fill",
                subtitle: store.t(
                    "Read-only starting points. Apply one, then save your own edited copy.",
                    "Готовые пресеты только для чтения. Примените пресет и сохраните собственную копию."
                )
            ) {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 250), spacing: 10, alignment: .top)],
                    alignment: .leading,
                    spacing: 10
                ) {
                    ForEach(store.builtInConfigurations) { configuration in
                        configurationCard(configuration)
                    }
                }
            }

            SettingsPanel(
                title: store.t("My configurations", "Мои конфигурации"),
                icon: "person.crop.rectangle.stack.fill",
                subtitle: store.t(
                    "Custom profiles are stored locally and can be renamed, duplicated, exported, or deleted.",
                    "Пользовательские профили хранятся локально: их можно переименовать, дублировать, экспортировать и удалять."
                )
            ) {
                if customConfigurations.isEmpty {
                    EmptyState(
                        icon: "square.stack.3d.up",
                        title: store.t("No custom profiles yet", "Пользовательских профилей пока нет"),
                        message: store.t(
                            "Tune any module, then save the current setup as your first configuration.",
                            "Настройте любой модуль и сохраните текущую сборку как первую конфигурацию."
                        ),
                        actionTitle: store.t("Save current setup", "Сохранить текущую сборку")
                    ) {
                        showSaveSheet = true
                    }
                } else {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 250), spacing: 10, alignment: .top)],
                        alignment: .leading,
                        spacing: 10
                    ) {
                        ForEach(customConfigurations) { configuration in
                            configurationCard(configuration)
                        }
                    }
                }
            }

            InfoBanner(
                icon: "lock.doc.fill",
                title: store.t("Portable and private", "Портативно и приватно"),
                message: store.t(
                    "Configurations contain only BepeBka Visual settings. They never touch Standoff 2 files, memory, account data, or network traffic.",
                    "Конфигурации содержат только настройки BepeBka Visual. Они не затрагивают файлы, память, аккаунт или сетевой трафик Standoff 2."
                ),
                tint: store.accentColor
            )
        }
        .sheet(isPresented: $showSaveSheet) {
            ConfigurationNameSheet(
                title: store.t("Save configuration", "Сохранить конфигурацию"),
                subtitle: store.t(
                    "The current setup becomes a new profile in My configurations.",
                    "Текущая сборка станет новым профилем в разделе «Мои конфигурации»."
                ),
                initialName: suggestedName,
                actionTitle: store.t("Save profile", "Сохранить профиль"),
                onCommit: { name in
                    let configuration = store.saveCurrentAsNew(named: name)
                    store.hapticSuccess()
                    store.showToast(
                        store.t("Saved “\(configuration.name)”", "Сохранено: «\(configuration.name)»"),
                        icon: "square.stack.3d.up.fill"
                    )
                }
            )
        }
        .sheet(item: $renameTarget) { configuration in
            ConfigurationNameSheet(
                title: store.t("Rename configuration", "Переименовать конфигурацию"),
                subtitle: store.t(
                    "Choose a clear name for this local profile.",
                    "Выберите понятное имя для этого локального профиля."
                ),
                initialName: configuration.name,
                actionTitle: store.t("Rename", "Переименовать"),
                onCommit: { name in
                    store.renameConfiguration(configuration, to: name)
                    store.hapticSuccess()
                    store.showToast(
                        store.t("Renamed to “\(name)”", "Новое имя: «\(name)»"),
                        icon: "pencil"
                    )
                }
            )
        }
        .sheet(isPresented: $showImportSheet) {
            ConfigurationImportSheet()
        }
        .sheet(item: $exportPayload) { payload in
            ConfigurationExportSheet(title: payload.title, payload: payload.text)
        }
        .alert(
            store.t("Delete configuration?", "Удалить конфигурацию?"),
            isPresented: $showDeleteAlert,
            presenting: deleteTarget
        ) { configuration in
            Button(store.t("Delete", "Удалить"), role: .destructive) {
                delete(configuration)
            }
            Button(store.t("Cancel", "Отмена"), role: .cancel) {}
        } message: { configuration in
            Text(store.t(
                "“\(configuration.name)” will be removed from this device. This cannot be undone.",
                "«\(configuration.name)» будет удалён с этого устройства. Отменить действие нельзя."
            ))
        }
    }

    // MARK: - Overview

    private var activeOverview: some View {
        GlassCard(padding: 16, cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(store.accentColor.opacity(0.12))
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .stroke(store.accentColor.opacity(0.24), lineWidth: 0.7)
                        Image(systemName: activeIcon)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(store.accentColor)
                    }
                    .frame(width: 46, height: 46)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 7) {
                            Text(store.t("ACTIVE CONFIGURATION", "АКТИВНАЯ КОНФИГУРАЦИЯ"))
                                .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                                .tracking(1.2)
                                .foregroundStyle(DSColor.textTertiary)

                            if store.activeConfigurationIsBuiltIn {
                                BVBadge(text: store.t("BUILT-IN", "ВСТРОЕННЫЙ"), tint: store.accentColor)
                            }
                        }

                        Text(activeName)
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                            .foregroundStyle(DSColor.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)

                        Text(activeDescription)
                            .font(.system(size: 11.5))
                            .foregroundStyle(DSColor.textSecondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 6)
                }

                HStack(spacing: 7) {
                    HStack(spacing: 5) {
                        StatusDot(color: store.hasUnsavedChanges ? DSColor.warning : DSColor.success, size: 4)
                        Text(store.hasUnsavedChanges ? store.t("UNSAVED CHANGES", "НЕСОХРАНЁННЫЕ ИЗМЕНЕНИЯ") : store.t("UP TO DATE", "АКТУАЛЬНО"))
                            .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                            .tracking(0.5)
                            .foregroundStyle(DSColor.textSecondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background {
                        Capsule().fill(Color.black.opacity(0.2))
                    }
                    .overlay {
                        Capsule().stroke(Color.white.opacity(0.06), lineWidth: 0.6)
                    }

                    HStack(spacing: 5) {
                        Image(systemName: "internaldrive.fill")
                            .font(.system(size: 8, weight: .medium))
                        Text(store.t("SAVED ON DEVICE", "ХРАНИТСЯ НА УСТРОЙСТВЕ"))
                            .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                            .tracking(0.5)
                    }
                    .foregroundStyle(DSColor.textTertiary)

                    Spacer(minLength: 0)
                }

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 142), spacing: 8)],
                    spacing: 8
                ) {
                    if store.activeConfiguration != nil && !store.activeConfigurationIsBuiltIn {
                        overviewAction(
                            icon: "square.and.arrow.down.fill",
                            title: store.t("Save changes", "Сохранить изменения"),
                            variant: .primary
                        ) {
                            saveActiveChanges()
                        }
                    }

                    overviewAction(
                        icon: "plus.circle.fill",
                        title: store.t("Save as new", "Сохранить как новый"),
                        variant: store.activeConfigurationIsBuiltIn || store.activeConfiguration == nil ? .primary : .secondary
                    ) {
                        showSaveSheet = true
                    }

                    overviewAction(
                        icon: "square.and.arrow.down",
                        title: store.t("Import", "Импорт"),
                        variant: .secondary
                    ) {
                        showImportSheet = true
                    }

                    overviewAction(
                        icon: "square.and.arrow.up",
                        title: store.t("Export", "Экспорт"),
                        variant: .secondary
                    ) {
                        exportCurrentSettings()
                    }
                }
            }
        }
    }

    private func overviewAction(
        icon: String,
        title: String,
        variant: PremiumButtonVariant,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            store.hapticTap()
            action()
        } label: {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PremiumButtonStyle(variant: variant))
    }

    // MARK: - Configuration card

    private func configurationCard(_ configuration: ClientConfiguration) -> some View {
        let active = store.activeConfigurationID == configuration.id
        let accent = Color(hex: configuration.accentHex)

        return VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: configuration.settings.ui.theme.previewColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [accent.opacity(0.34), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 76
                        )
                    )
                    .frame(width: 150, height: 150)
                    .blur(radius: 8)
                    .offset(x: 92, y: -44)

                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 6) {
                        BVBadge(
                            text: configuration.isBuiltIn
                                ? store.t("BUILT-IN", "ВСТРОЕННЫЙ")
                                : store.t("CUSTOM", "СВОЙ"),
                            tint: accent.opacity(0.9)
                        )

                        if active {
                            BVBadge(
                                text: store.t("ACTIVE", "АКТИВЕН"),
                                tint: DSColor.success,
                                icon: "checkmark",
                                filled: true
                            )
                        }

                        Spacer(minLength: 0)
                    }

                    Spacer(minLength: 8)

                    Text(configuration.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(cardSubtitle(configuration))
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.42))
                        .lineLimit(1)
                }
                .padding(12)
            }
            .frame(height: 104)

            VStack(alignment: .leading, spacing: 10) {
                Text(store.t(configuration.descriptionEN, configuration.descriptionRU))
                    .font(.system(size: 10.5))
                    .foregroundStyle(DSColor.textSecondary)
                    .lineLimit(2)
                    .frame(height: 30, alignment: .topLeading)

                HStack(spacing: 8) {
                    Button {
                        apply(configuration)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: active ? "checkmark.circle.fill" : "bolt.fill")
                                .font(.system(size: 10, weight: .semibold))
                            Text(active ? store.t("Reapply", "Применить снова") : store.t("Apply", "Применить"))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PremiumButtonStyle(variant: active ? .secondary : .primary, tint: accent))

                    configurationMenu(configuration)
                }
            }
            .padding(11)
        }
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(active ? 0.045 : 0.028))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(active ? accent.opacity(0.58) : Color.white.opacity(0.06), lineWidth: active ? 1.1 : 0.7)
        }
        .shadow(color: .black.opacity(0.2), radius: 12, y: 7)
    }

    private func configurationMenu(_ configuration: ClientConfiguration) -> some View {
        Menu {
            if !configuration.isBuiltIn {
                Button {
                    renameTarget = configuration
                } label: {
                    Label(store.t("Rename", "Переименовать"), systemImage: "pencil")
                }
            }

            Button {
                duplicate(configuration)
            } label: {
                Label(store.t("Duplicate", "Дублировать"), systemImage: "doc.on.doc")
            }

            Button {
                export(configuration)
            } label: {
                Label(store.t("Export", "Экспортировать"), systemImage: "square.and.arrow.up")
            }

            if !configuration.isBuiltIn {
                Divider()

                Button(role: .destructive) {
                    deleteTarget = configuration
                    showDeleteAlert = true
                } label: {
                    Label(store.t("Delete", "Удалить"), systemImage: "trash")
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(DSColor.textSecondary)
                .frame(width: 34, height: 34)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(0.045))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.white.opacity(0.07), lineWidth: 0.7)
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private var activeName: String {
        store.activeConfiguration?.name ?? store.t("Unsaved setup", "Свободная настройка")
    }

    private var activeIcon: String {
        if store.activeConfiguration == nil { return "pencil.and.outline" }
        return store.activeConfigurationIsBuiltIn ? "square.stack.3d.up.fill" : "person.crop.rectangle.fill"
    }

    private var activeDescription: String {
        guard let configuration = store.activeConfiguration else {
            return store.t(
                "The current look is live but not stored as a named profile. Save it to switch back later.",
                "Текущий вид активен, но не сохранён как именованный профиль. Сохраните его, чтобы вернуться позже."
            )
        }
        return store.t(configuration.descriptionEN, configuration.descriptionRU)
    }

    private func cardSubtitle(_ configuration: ClientConfiguration) -> String {
        if configuration.isBuiltIn {
            return store.t("STARTER PROFILE", "СТАРТОВЫЙ ПРОФИЛЬ")
        }
        let date = configuration.createdAt.formatted(date: .abbreviated, time: .omitted)
        return store.t("CREATED \(date.uppercased())", "СОЗДАН \(date.uppercased())")
    }

    private func saveActiveChanges() {
        guard store.updateActiveConfiguration() else {
            showSaveSheet = true
            return
        }
        store.hapticSuccess()
        store.showToast(
            store.t("Changes saved to “\(activeName)”", "Изменения сохранены в «\(activeName)»"),
            icon: "checkmark.circle.fill"
        )
    }

    private func apply(_ configuration: ClientConfiguration) {
        store.hapticSuccess()
        withAnimation(.easeInOut(duration: 0.24)) {
            store.apply(configuration)
        }
        store.showToast(
            store.t("Applied “\(configuration.name)”", "Применено: «\(configuration.name)»"),
            icon: "bolt.fill"
        )
    }

    private func duplicate(_ configuration: ClientConfiguration) {
        store.hapticSuccess()
        let copy = store.duplicateConfiguration(configuration)
        store.showToast(
            store.t("Created “\(copy.name)”", "Создано: «\(copy.name)»"),
            icon: "doc.on.doc.fill"
        )
    }

    private func export(_ configuration: ClientConfiguration) {
        store.hapticTap()
        exportPayload = ConfigurationExportPayload(
            title: configuration.name,
            text: store.exportString(for: configuration)
        )
    }

    private func exportCurrentSettings() {
        store.hapticTap()
        let name = store.activeConfiguration?.name ?? store.t("Current setup", "Текущая сборка")
        exportPayload = ConfigurationExportPayload(
            title: name,
            text: store.exportCurrentSettings(named: name)
        )
    }

    private func delete(_ configuration: ClientConfiguration) {
        let name = configuration.name
        store.hapticSuccess()
        withAnimation(.easeInOut(duration: 0.22)) {
            store.deleteConfiguration(configuration)
        }
        store.showToast(
            store.t("Deleted “\(name)”", "Удалено: «\(name)»"),
            icon: "trash.fill"
        )
    }
}

// MARK: - Export payload

private struct ConfigurationExportPayload: Identifiable {
    let id = UUID()
    let title: String
    let text: String
}

// MARK: - Name sheet

private struct ConfigurationNameSheet: View {
    @EnvironmentObject private var store: ClientStore
    @Environment(\.dismiss) private var dismiss

    let title: String
    let subtitle: String
    let initialName: String
    let actionTitle: String
    let onCommit: (String) -> Void

    @State private var name: String
    @FocusState private var nameFocused: Bool

    init(
        title: String,
        subtitle: String,
        initialName: String,
        actionTitle: String,
        onCommit: @escaping (String) -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.initialName = initialName
        self.actionTitle = actionTitle
        self.onCommit = onCommit
        _name = State(initialValue: initialName)
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ConfigurationSheetHeader(title: title, subtitle: subtitle)

            TextField(store.t("Configuration name", "Название конфигурации"), text: $name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(DSColor.textPrimary)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .focused($nameFocused)
                .submitLabel(.done)
                .onSubmit(commit)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.045))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            nameFocused ? store.accentColor.opacity(0.55) : Color.white.opacity(0.08),
                            lineWidth: nameFocused ? 1 : 0.7
                        )
                }

            HStack(spacing: 8) {
                Button(store.t("Cancel", "Отмена")) {
                    dismiss()
                }
                .buttonStyle(PremiumButtonStyle(variant: .ghost))

                Spacer(minLength: 0)

                Button(actionTitle) {
                    commit()
                }
                .buttonStyle(PremiumButtonStyle(variant: .primary))
                .disabled(trimmedName.isEmpty)
                .opacity(trimmedName.isEmpty ? 0.45 : 1)
            }
        }
        .padding(18)
        .background {
            LinearGradient(
                colors: [Color(hex: "#121318"), Color(hex: "#08090C")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .presentationDetents([.height(250)])
        .presentationDragIndicator(.visible)
        .presentationBackground(.ultraThinMaterial)
        .preferredColorScheme(.dark)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                nameFocused = true
            }
        }
    }

    private func commit() {
        guard !trimmedName.isEmpty else { return }
        store.hapticSuccess()
        onCommit(trimmedName)
        dismiss()
    }
}

// MARK: - Import sheet

private struct ConfigurationImportSheet: View {
    @EnvironmentObject private var store: ClientStore
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var errorMessage: String?
    @FocusState private var editorFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ConfigurationSheetHeader(
                title: store.t("Import configuration", "Импорт конфигурации"),
                subtitle: store.t(
                    "Paste a JSON export from BepeBka Visual. The imported profile is added to My configurations.",
                    "Вставьте JSON-экспорт BepeBka Visual. Импортированный профиль появится в разделе «Мои конфигурации»."
                )
            )

            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .font(.system(size: 10.5, design: .monospaced))
                    .foregroundStyle(DSColor.textSecondary)
                    .scrollContentBackground(.hidden)
                    .focused($editorFocused)
                    .padding(8)

                if text.isEmpty {
                    Text(store.t("Paste JSON here…", "Вставьте JSON сюда…"))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(DSColor.textTertiary)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
            }
            .frame(minHeight: 170)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.black.opacity(0.25))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        errorMessage == nil ? Color.white.opacity(0.08) : DSColor.danger.opacity(0.6),
                        lineWidth: 0.8
                    )
            }

            if let errorMessage {
                HStack(spacing: 7) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10, weight: .semibold))
                    Text(errorMessage)
                        .font(.system(size: 10.5))
                }
                .foregroundStyle(DSColor.danger)
            }

            HStack(spacing: 8) {
                Button {
                    pasteFromClipboard()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.clipboard.fill")
                            .font(.system(size: 10, weight: .semibold))
                        Text(store.t("Paste", "Вставить"))
                    }
                }
                .buttonStyle(PremiumButtonStyle(variant: .secondary))

                Spacer(minLength: 0)

                Button(store.t("Cancel", "Отмена")) {
                    dismiss()
                }
                .buttonStyle(PremiumButtonStyle(variant: .ghost))

                Button {
                    importConfiguration()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(.system(size: 10, weight: .semibold))
                        Text(store.t("Import", "Импортировать"))
                    }
                }
                .buttonStyle(PremiumButtonStyle(variant: .primary))
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
            }
        }
        .padding(18)
        .background {
            LinearGradient(
                colors: [Color(hex: "#121318"), Color(hex: "#08090C")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.ultraThinMaterial)
        .preferredColorScheme(.dark)
    }

    private func pasteFromClipboard() {
        guard let clipboard = UIPasteboard.general.string,
              !clipboard.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = store.t("Clipboard is empty.", "Буфер обмена пуст.")
            return
        }
        store.hapticTap()
        text = clipboard
        errorMessage = nil
    }

    private func importConfiguration() {
        guard let configuration = store.importConfiguration(from: text) else {
            errorMessage = store.t(
                "This text is not a valid BepeBka Visual configuration.",
                "Этот текст не является корректной конфигурацией BepeBka Visual."
            )
            return
        }

        store.hapticSuccess()
        store.showToast(
            store.t("Imported “\(configuration.name)”", "Импортировано: «\(configuration.name)»"),
            icon: "square.and.arrow.down.fill"
        )
        dismiss()
    }
}

// MARK: - Export sheet

private struct ConfigurationExportSheet: View {
    @EnvironmentObject private var store: ClientStore
    @Environment(\.dismiss) private var dismiss

    let title: String
    let payload: String

    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ConfigurationSheetHeader(
                title: store.t("Export “\(title)”", "Экспорт «\(title)»"),
                subtitle: store.t(
                    "Copy the JSON or send it to another device. Import it later to restore the exact setup.",
                    "Скопируйте JSON или отправьте его на другое устройство. Импортируйте позже, чтобы восстановить сборку."
                )
            )

            ScrollView {
                Text(payload)
                    .font(.system(size: 9.5, design: .monospaced))
                    .foregroundStyle(DSColor.textSecondary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }
            .frame(minHeight: 170)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.black.opacity(0.25))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.8)
            }

            HStack(spacing: 8) {
                Button {
                    copyPayload()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc.fill")
                            .font(.system(size: 10, weight: .semibold))
                        Text(copied ? store.t("Copied", "Скопировано") : store.t("Copy JSON", "Копировать JSON"))
                    }
                }
                .buttonStyle(PremiumButtonStyle(variant: copied ? .ghost : .primary))

                ShareLink(item: payload) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 10, weight: .semibold))
                        Text(store.t("Share", "Поделиться"))
                    }
                }
                .buttonStyle(PremiumButtonStyle(variant: .secondary))

                Spacer(minLength: 0)

                Button(store.t("Done", "Готово")) {
                    dismiss()
                }
                .buttonStyle(PremiumButtonStyle(variant: .ghost))
            }

            Text(store.t("\(payload.count) characters · local JSON only", "\(payload.count) символов · только локальный JSON"))
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(DSColor.textTertiary)
        }
        .padding(18)
        .background {
            LinearGradient(
                colors: [Color(hex: "#121318"), Color(hex: "#08090C")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.ultraThinMaterial)
        .preferredColorScheme(.dark)
    }

    private func copyPayload() {
        UIPasteboard.general.string = payload
        store.hapticSuccess()
        withAnimation(.easeOut(duration: 0.2)) {
            copied = true
        }
        store.showToast(
            store.t("Configuration copied", "Конфигурация скопирована"),
            icon: "doc.on.doc.fill"
        )
    }
}

// MARK: - Sheet header

private struct ConfigurationSheetHeader: View {
    @EnvironmentObject private var store: ClientStore
    @Environment(\.dismiss) private var dismiss

    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(2)

                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(DSColor.textTertiary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(DSColor.textSecondary)
                    .frame(width: 30, height: 30)
                    .background {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(Color.white.opacity(0.055))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .stroke(Color.white.opacity(0.07), lineWidth: 0.7)
                    }
            }
            .buttonStyle(.plain)
        }
    }
}
