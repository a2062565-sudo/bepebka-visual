import Foundation

struct ClientConfiguration: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var settings: ClientSettings
    var isBuiltIn: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        settings: ClientSettings,
        isBuiltIn: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.settings = settings
        self.isBuiltIn = isBuiltIn
        self.createdAt = createdAt
    }

    var accentHex: String { settings.ui.accentHex }

    var descriptionEN: String {
        let visual = settings.sky.preset.titleEN
        let effect = settings.killEffects.kind.titleEN
        let particles = settings.particles.enabled ? settings.particles.kind.titleEN : "No particles"
        return "\(visual) · \(particles) · \(effect)"
    }

    var descriptionRU: String {
        let visual = settings.sky.preset.titleRU
        let effect = settings.killEffects.kind.titleRU
        let particles = settings.particles.enabled ? settings.particles.kind.titleRU : "Без частиц"
        return "\(visual) · \(particles) · \(effect)"
    }
}

enum BuiltInConfigurations {
    private static func make(
        id: String,
        name: String,
        configure: (inout ClientSettings) -> Void
    ) -> ClientConfiguration {
        var settings = ClientSettings()
        configure(&settings)
        let uuid = UUID(uuidString: id) ?? UUID()
        return ClientConfiguration(
            id: uuid,
            name: name,
            settings: settings,
            isBuiltIn: true,
            createdAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }

    static let all: [ClientConfiguration] = [
        make(id: "00000000-0000-4000-8000-000000000001", name: "Minimal") { settings in
            settings.ui.accentHex = "#E2E8F0"
            settings.ui.theme = .graphite
            settings.ui.refreshRate = .fps120

            settings.visuals.enabled = true
            settings.visuals.showBoxes = false
            settings.visuals.showSkeleton = false
            settings.visuals.showHealthBars = true
            settings.visuals.showNames = true
            settings.visuals.showWeapons = false
            settings.visuals.showDistance = true
            settings.visuals.showRadar = false
            settings.visuals.showHitMarkers = false
            settings.visuals.showWorldGlow = false
            settings.visuals.highlightStyle = .outline
            settings.visuals.boxThickness = 1.0
            settings.visuals.accentHex = "#E2E8F0"

            settings.targetHUD.style = .minimal
            settings.targetHUD.scale = 0.92
            settings.targetHUD.opacity = 0.94
            settings.targetHUD.borderHex = "#E2E8F0"
            settings.targetHUD.accentHex = "#E2E8F0"
            settings.targetHUD.placement = .center
            settings.targetHUD.animation = .fade
            settings.targetHUD.showArmor = false
            settings.targetHUD.showLevel = false
            settings.targetHUD.showAvatar = false

            settings.particles.enabled = false
            settings.particles.kind = .glowingDust
            settings.particles.count = 40
            settings.particles.colorHex = "#E2E8F0"

            settings.killEffects.kind = .digitalDissolve
            settings.killEffects.colorHex = "#E2E8F0"
            settings.killEffects.secondaryHex = "#94A3B8"
            settings.killEffects.intensity = 0.55
            settings.killEffects.screenFlash = false
            settings.killEffects.shake = false

            settings.sky.preset = .pureBlack
            settings.sky.intensity = 0.35
            settings.sky.brightness = 0.0

            settings.environment.saturationEnabled = false
            settings.environment.contrastEnabled = false
            settings.environment.bloomEnabled = false
            settings.environment.ambientGlowEnabled = false
            settings.environment.fogEnabled = false
            settings.environment.dofEnabled = false
            settings.environment.vignetteEnabled = true
            settings.environment.vignette = 0.25

            settings.crosshair.preset = .dot
            settings.crosshair.size = 0
            settings.crosshair.gap = 0
            settings.crosshair.dot = true
            settings.crosshair.outline = false
            settings.crosshair.glow = false
            settings.crosshair.colorHex = "#F8FAFC"
            settings.crosshair.thickness = 3.2
        },

        make(id: "00000000-0000-4000-8000-000000000002", name: "Galaxy") { settings in
            settings.ui.accentHex = "#A855F7"
            settings.ui.theme = .midnight
            settings.ui.refreshRate = .fps60

            settings.visuals.accentHex = "#C084FC"
            settings.visuals.highlightStyle = .glow
            settings.visuals.glowStrength = 0.9
            settings.visuals.boxThickness = 1.5

            settings.targetHUD.style = .glass
            settings.targetHUD.borderHex = "#C084FC"
            settings.targetHUD.accentHex = "#A855F7"
            settings.targetHUD.animation = .spring
            settings.targetHUD.placement = .belowCrosshair
            settings.targetHUD.scale = 1.0

            settings.particles.enabled = true
            settings.particles.kind = .stars
            settings.particles.count = 115
            settings.particles.speed = 0.65
            settings.particles.size = 1.2
            settings.particles.opacity = 0.9
            settings.particles.colorHex = "#C4B5FD"
            settings.particles.secondaryHex = "#F0ABFC"
            settings.particles.direction = .up
            settings.particles.glow = true
            settings.particles.trail = true

            settings.killEffects.kind = .galaxy
            settings.killEffects.colorHex = "#C084FC"
            settings.killEffects.secondaryHex = "#67E8F9"
            settings.killEffects.intensity = 0.95
            settings.killEffects.duration = 1.6

            settings.sky.preset = .galaxy
            settings.sky.intensity = 1.0
            settings.sky.speed = 0.7
            settings.sky.brightness = 0.04

            settings.environment.bloom = 0.7
            settings.environment.ambientGlow = 0.55
            settings.environment.ambientGlowHex = "#A855F7"
            settings.environment.saturation = 1.18
            settings.environment.contrast = 1.08
            settings.environment.fogDensity = 0.16
            settings.environment.vignette = 0.4

            settings.crosshair.colorHex = "#C4B5FD"
            settings.crosshair.glow = true
            settings.crosshair.size = 16
            settings.crosshair.gap = 6
            settings.crosshair.dot = true
        },

        make(id: "00000000-0000-4000-8000-000000000003", name: "Dark") { settings in
            settings.ui.accentHex = "#94A3B8"
            settings.ui.theme = .obsidian

            settings.visuals.accentHex = "#CBD5E1"
            settings.visuals.highlightStyle = .outline
            settings.visuals.showSkeleton = false
            settings.visuals.showRadar = false
            settings.visuals.showWorldGlow = false
            settings.visuals.boxThickness = 1.2
            settings.visuals.glowStrength = 0.2

            settings.targetHUD.style = .outline
            settings.targetHUD.borderHex = "#94A3B8"
            settings.targetHUD.accentHex = "#E2E8F0"
            settings.targetHUD.animation = .fade
            settings.targetHUD.opacity = 0.92
            settings.targetHUD.showAvatar = false

            settings.particles.enabled = false
            settings.particles.kind = .glowingDust
            settings.particles.count = 36
            settings.particles.colorHex = "#94A3B8"

            settings.killEffects.kind = .digitalDissolve
            settings.killEffects.colorHex = "#94A3B8"
            settings.killEffects.secondaryHex = "#E2E8F0"
            settings.killEffects.intensity = 0.6
            settings.killEffects.screenFlash = false

            settings.sky.preset = .pureBlack
            settings.sky.intensity = 0.2

            settings.environment.lighting = 0.88
            settings.environment.saturation = 0.82
            settings.environment.bloomEnabled = false
            settings.environment.ambientGlowEnabled = false
            settings.environment.fogEnabled = false
            settings.environment.vignette = 0.55

            settings.crosshair.colorHex = "#E2E8F0"
            settings.crosshair.preset = .cross
            settings.crosshair.size = 14
            settings.crosshair.gap = 7
            settings.crosshair.thickness = 1.5
            settings.crosshair.dot = false
            settings.crosshair.glow = false
        },

        make(id: "00000000-0000-4000-8000-000000000004", name: "Neon") { settings in
            settings.ui.accentHex = "#22D3EE"
            settings.ui.theme = .carbon
            settings.ui.refreshRate = .fps120

            settings.visuals.accentHex = "#22D3EE"
            settings.visuals.highlightStyle = .filled
            settings.visuals.glowStrength = 0.95
            settings.visuals.showWorldGlow = true
            settings.visuals.boxThickness = 2.0

            settings.targetHUD.style = .neon
            settings.targetHUD.borderHex = "#22D3EE"
            settings.targetHUD.accentHex = "#F0ABFC"
            settings.targetHUD.animation = .scale
            settings.targetHUD.placement = .belowCrosshair
            settings.targetHUD.scale = 1.04

            settings.particles.enabled = true
            settings.particles.kind = .neon
            settings.particles.count = 95
            settings.particles.speed = 1.35
            settings.particles.size = 0.9
            settings.particles.colorHex = "#22D3EE"
            settings.particles.secondaryHex = "#F0ABFC"
            settings.particles.direction = .swirl
            settings.particles.glow = true
            settings.particles.trail = true

            settings.killEffects.kind = .neonRing
            settings.killEffects.colorHex = "#22D3EE"
            settings.killEffects.secondaryHex = "#F0ABFC"
            settings.killEffects.intensity = 1.0
            settings.killEffects.speed = 1.4

            settings.sky.preset = .cosmicStorm
            settings.sky.intensity = 0.95
            settings.sky.speed = 1.3

            settings.environment.saturation = 1.35
            settings.environment.contrast = 1.16
            settings.environment.bloom = 0.8
            settings.environment.ambientGlow = 0.6
            settings.environment.ambientGlowHex = "#22D3EE"
            settings.environment.tintEnabled = true
            settings.environment.tintHex = "#22D3EE"
            settings.environment.tintStrength = 0.1

            settings.crosshair.preset = .neon
            settings.crosshair.colorHex = "#22D3EE"
            settings.crosshair.size = 17
            settings.crosshair.gap = 4
            settings.crosshair.thickness = 2.4
            settings.crosshair.dot = true
            settings.crosshair.glow = true
            settings.crosshair.dynamic = true
        },

        make(id: "00000000-0000-4000-8000-000000000005", name: "Purple") { settings in
            settings.ui.accentHex = "#A855F7"
            settings.ui.theme = .midnight

            settings.visuals.accentHex = "#A855F7"
            settings.visuals.glowStrength = 0.82
            settings.visuals.highlightStyle = .glow

            settings.targetHUD.style = .glass
            settings.targetHUD.borderHex = "#A855F7"
            settings.targetHUD.accentHex = "#E879F9"
            settings.targetHUD.animation = .spring
            settings.targetHUD.placement = .belowCrosshair

            settings.particles.enabled = true
            settings.particles.kind = .fireflies
            settings.particles.count = 70
            settings.particles.speed = 0.55
            settings.particles.size = 1.5
            settings.particles.opacity = 0.82
            settings.particles.colorHex = "#C084FC"
            settings.particles.secondaryHex = "#F0ABFC"
            settings.particles.direction = .swirl
            settings.particles.glow = true

            settings.killEffects.kind = .purpleEnergy
            settings.killEffects.colorHex = "#A855F7"
            settings.killEffects.secondaryHex = "#E879F9"
            settings.killEffects.intensity = 0.9
            settings.killEffects.duration = 1.4

            settings.sky.preset = .purpleUniverse
            settings.sky.intensity = 1.0
            settings.sky.speed = 0.8

            settings.environment.bloom = 0.62
            settings.environment.ambientGlow = 0.5
            settings.environment.ambientGlowHex = "#A855F7"
            settings.environment.vignette = 0.46
            settings.environment.fogDensity = 0.3
            settings.environment.fogHex = "#7C3AED"

            settings.crosshair.colorHex = "#E879F9"
            settings.crosshair.size = 15
            settings.crosshair.gap = 5
            settings.crosshair.dot = true
            settings.crosshair.glow = true
        }
    ]
}
