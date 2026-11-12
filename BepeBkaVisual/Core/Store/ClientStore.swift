import SwiftUI

final class ClientStore: ObservableObject {
    @Published var settings: ClientSettings {
        didSet { settingsDidChange() }
    }

    @Published private(set) var customConfigurations: [ClientConfiguration] = []
    @Published private(set) var activeConfigurationID: UUID?
    @Published private(set) var hasUnsavedChanges = false
    @Published var toast: ToastMessage?

    let builtInConfigurations: [ClientConfiguration] = BuiltInConfigurations.all

    private var isReady = false
    private var isApplyingConfiguration = false
    private var saveWorkItem: DispatchWorkItem?
    private var toastWorkItem: DispatchWorkItem?

    init() {
        settings = Persistence.loadSettings() ?? ClientSettings.standard
        customConfigurations = Persistence.loadConfigurations() ?? []
        activeConfigurationID = Persistence.loadActiveConfigurationID()
        isReady = true
        hasUnsavedChanges = false
    }

    // MARK: - Language

    func t(_ english: String, _ russian: String) -> String {
        settings.ui.language == .russian ? russian : english
    }

    // MARK: - Derived appearance

    var accentColor: Color {
        Color(hex: settings.ui.accentHex)
    }

    var theme: AppTheme {
        settings.ui.theme
    }

    var allConfigurations: [ClientConfiguration] {
        builtInConfigurations + customConfigurations.sorted { $0.createdAt < $1.createdAt }
    }

    var activeConfiguration: ClientConfiguration? {
        guard let activeConfigurationID else { return nil }
        return allConfigurations.first { $0.id == activeConfigurationID }
    }

    var activeConfigurationIsBuiltIn: Bool {
        activeConfiguration?.isBuiltIn ?? false
    }

    var refreshInterval: Double {
        if settings.ui.reduceLoad {
            return 1.0 / 30.0
        }
        return settings.ui.refreshRate.interval
    }

    var animationsPaused: Bool {
        !settings.ui.animationsEnabled
    }

    var previewDensity: Double {
        settings.ui.reduceLoad ? 0.55 : 1.0
    }

    // MARK: - Haptics

    func hapticTap() {
        guard settings.ui.hapticsEnabled else { return }
        Haptics.tap()
    }

    func hapticSelect() {
        guard settings.ui.hapticsEnabled else { return }
        Haptics.select()
    }

    func hapticSuccess() {
        guard settings.ui.hapticsEnabled else { return }
        Haptics.success()
    }

    // MARK: - Accent

    func setAccent(_ hex: String) {
        guard settings.ui.accentHex != hex else { return }
        hapticSelect()
        withAnimation(.easeInOut(duration: 0.25)) {
            settings.ui.accentHex = hex
        }
    }

    // MARK: - Configuration lifecycle

    func apply(_ configuration: ClientConfiguration) {
        isApplyingConfiguration = true
        var applied = configuration.settings
        // Language and performance preferences belong to the device, not the preset.
        applied.ui.language = settings.ui.language
        applied.ui.hapticsEnabled = settings.ui.hapticsEnabled
        applied.ui.reduceLoad = settings.ui.reduceLoad
        settings = applied

        activeConfigurationID = configuration.id
        hasUnsavedChanges = false
        isApplyingConfiguration = false

        Persistence.saveActiveConfigurationID(configuration.id)
        saveNow()
    }

    func createConfiguration(named name: String?) {
        let fallback = t("My Config", "Мой конфиг")
        let base = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = makeUniqueName(base.isEmpty ? fallback : base)
        let configuration = ClientConfiguration(name: finalName, settings: settings)
        customConfigurations.append(configuration)
        activeConfigurationID = configuration.id
        hasUnsavedChanges = false
        persistCustomConfigurations()
        Persistence.saveActiveConfigurationID(configuration.id)
        saveNow()
    }

    @discardableResult
    func updateActiveConfiguration() -> Bool {
        guard let activeConfigurationID,
              let index = customConfigurations.firstIndex(where: { $0.id == activeConfigurationID }) else {
            return false
        }

        customConfigurations[index].settings = settings
        hasUnsavedChanges = false
        persistCustomConfigurations()
        saveNow()
        return true
    }

    @discardableResult
    func saveCurrentAsNew(named name: String?) -> ClientConfiguration {
        let fallback = t("My Config", "Мой конфиг")
        let base = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = makeUniqueName(base.isEmpty ? fallback : base)
        let configuration = ClientConfiguration(name: finalName, settings: settings)
        customConfigurations.append(configuration)
        activeConfigurationID = configuration.id
        hasUnsavedChanges = false
        persistCustomConfigurations()
        Persistence.saveActiveConfigurationID(configuration.id)
        saveNow()
        return configuration
    }

    func renameConfiguration(_ configuration: ClientConfiguration, to newName: String) {
        guard !configuration.isBuiltIn,
              let index = customConfigurations.firstIndex(where: { $0.id == configuration.id }) else {
            return
        }
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        customConfigurations[index].name = trimmed
        persistCustomConfigurations()
    }

    @discardableResult
    func duplicateConfiguration(_ configuration: ClientConfiguration) -> ClientConfiguration {
        let copy = ClientConfiguration(
            name: makeUniqueName("\(configuration.name) \(t("Copy", "Копия"))"),
            settings: configuration.settings
        )
        customConfigurations.append(copy)
        persistCustomConfigurations()
        return copy
    }

    func deleteConfiguration(_ configuration: ClientConfiguration) {
        guard !configuration.isBuiltIn else { return }
        customConfigurations.removeAll { $0.id == configuration.id }
        if activeConfigurationID == configuration.id {
            activeConfigurationID = nil
            Persistence.saveActiveConfigurationID(nil)
        }
        persistCustomConfigurations()
    }

    func resetSettings() {
        isApplyingConfiguration = true
        settings = ClientSettings.standard
        activeConfigurationID = nil
        hasUnsavedChanges = false
        isApplyingConfiguration = false
        Persistence.saveActiveConfigurationID(nil)
        saveNow()
    }

    // MARK: - Import / export

    func exportString(for configuration: ClientConfiguration) -> String {
        Persistence.encodeExport(configuration) ?? "{}"
    }

    func exportCurrentSettings(named name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let configuration = ClientConfiguration(
            name: trimmed.isEmpty ? "BepeBka Visual" : trimmed,
            settings: settings
        )
        return exportString(for: configuration)
    }

    @discardableResult
    func importConfiguration(from text: String) -> ClientConfiguration? {
        guard var configuration = Persistence.decodeImport(text) else { return nil }
        configuration.id = UUID()
        configuration.isBuiltIn = false
        configuration.createdAt = Date()
        configuration.name = makeUniqueName(configuration.name.isEmpty ? "Imported" : configuration.name)
        customConfigurations.append(configuration)
        persistCustomConfigurations()
        return configuration
    }

    // MARK: - Toast

    func showToast(_ title: String, icon: String = "checkmark.circle.fill") {
        let message = ToastMessage(title: title, icon: icon)
        toastWorkItem?.cancel()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            toast = message
        }

        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard self.toast?.id == message.id else { return }
            withAnimation(.easeOut(duration: 0.22)) {
                self.toast = nil
            }
        }
        toastWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4, execute: work)
    }

    // MARK: - Saving

    func saveNow() {
        saveWorkItem?.cancel()
        Persistence.saveSettings(settings)
        Persistence.saveConfigurations(customConfigurations)
        Persistence.saveActiveConfigurationID(activeConfigurationID)
    }

    // MARK: - Private

    private func settingsDidChange() {
        guard isReady, !isApplyingConfiguration else { return }
        hasUnsavedChanges = true
        scheduleSave()
    }

    private func scheduleSave() {
        saveWorkItem?.cancel()
        let settingsSnapshot = settings
        let customSnapshot = customConfigurations
        let activeSnapshot = activeConfigurationID

        let work = DispatchWorkItem {
            Persistence.saveSettings(settingsSnapshot)
            Persistence.saveConfigurations(customSnapshot)
            Persistence.saveActiveConfigurationID(activeSnapshot)
        }
        saveWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: work)
    }

    private func persistCustomConfigurations() {
        Persistence.saveConfigurations(customConfigurations)
    }

    private func makeUniqueName(_ base: String) -> String {
        let existing = Set(allConfigurations.map { $0.name.lowercased() })
        guard existing.contains(base.lowercased()) else { return base }

        var counter = 2
        while existing.contains("\(base) \(counter)".lowercased()) {
            counter += 1
        }
        return "\(base) \(counter)"
    }
}
