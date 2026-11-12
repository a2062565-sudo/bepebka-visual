import Foundation

enum Persistence {
    private static let settingsKey = "bepebka.visual.settings.v1"
    private static let configurationsKey = "bepebka.visual.configurations.v1"
    private static let activeConfigurationKey = "bepebka.visual.activeConfiguration.v1"

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    static func loadSettings() -> ClientSettings? {
        guard let data = UserDefaults.standard.data(forKey: settingsKey) else { return nil }
        return try? decoder.decode(ClientSettings.self, from: data)
    }

    static func saveSettings(_ settings: ClientSettings) {
        guard let data = try? encoder.encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: settingsKey)
    }

    static func loadConfigurations() -> [ClientConfiguration]? {
        guard let data = UserDefaults.standard.data(forKey: configurationsKey) else { return nil }
        return try? decoder.decode([ClientConfiguration].self, from: data)
    }

    static func saveConfigurations(_ configurations: [ClientConfiguration]) {
        guard let data = try? encoder.encode(configurations) else { return }
        UserDefaults.standard.set(data, forKey: configurationsKey)
    }

    static func loadActiveConfigurationID() -> UUID? {
        guard let value = UserDefaults.standard.string(forKey: activeConfigurationKey) else { return nil }
        return UUID(uuidString: value)
    }

    static func saveActiveConfigurationID(_ id: UUID?) {
        if let id {
            UserDefaults.standard.set(id.uuidString, forKey: activeConfigurationKey)
        } else {
            UserDefaults.standard.removeObject(forKey: activeConfigurationKey)
        }
    }

    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: settingsKey)
        UserDefaults.standard.removeObject(forKey: configurationsKey)
        UserDefaults.standard.removeObject(forKey: activeConfigurationKey)
    }

    static func encodeExport(_ configuration: ClientConfiguration) -> String? {
        guard let data = try? encoder.encode(configuration) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func decodeImport(_ text: String) -> ClientConfiguration? {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = cleaned.data(using: .utf8) else { return nil }

        if let configuration = try? decoder.decode(ClientConfiguration.self, from: data) {
            return configuration
        }

        if let settings = try? decoder.decode(ClientSettings.self, from: data) {
            return ClientConfiguration(name: "Imported", settings: settings)
        }

        return nil
    }
}
