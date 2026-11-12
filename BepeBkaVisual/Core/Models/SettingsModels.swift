import Foundation

// MARK: - Root settings

struct ClientSettings: Codable, Equatable {
    var visuals = VisualSettings()
    var targetHUD = TargetHUDSettings()
    var particles = ParticleSettings()
    var killEffects = KillEffectSettings()
    var skinChanger = SkinChangerSettings()
    var sky = SkySettings()
    var environment = EnvironmentSettings()
    var crosshair = CrosshairSettings()
    var ui = UISettings()

    static var standard: ClientSettings { ClientSettings() }
}

// MARK: - Visuals

struct VisualSettings: Codable, Equatable {
    var enabled = true
    var showBoxes = true
    var highlightStyle: HighlightStyle = .glow
    var showSkeleton = true
    var showHealthBars = true
    var showNames = true
    var showWeapons = true
    var showDistance = true
    var showTeamColors = false
    var showRadar = true
    var showHitMarkers = true
    var showWorldGlow = true
    var showFPS = false
    var boxThickness = 1.7
    var glowStrength = 0.65
    var infoOpacity = 0.96
    var accentHex = "#8B5CF6"
}

// MARK: - Target HUD

struct TargetHUDSettings: Codable, Equatable {
    var enabled = true
    var scale = 1.0
    var opacity = 0.97
    var borderHex = "#8B5CF6"
    var textHex = "#FFFFFF"
    var accentHex = "#8B5CF6"
    var placement: HUDPlacement = .belowCrosshair
    var animation: HUDAnimationStyle = .spring
    var style: HUDStyle = .glass
    var showHealth = true
    var showArmor = true
    var showWeapon = true
    var showLevel = true
    var showAvatar = true
    var showStatus = true
}

// MARK: - Particles

struct ParticleSettings: Codable, Equatable {
    var enabled = true
    var kind: ParticleKind = .snow
    var count = 80.0
    var speed = 1.0
    var size = 1.0
    var opacity = 0.85
    var colorHex = "#BFDBFE"
    var secondaryHex = "#F0ABFC"
    var direction: ParticleDirection = .down
    var glow = true
    var trail = false
}

// MARK: - Kill Effects

struct KillEffectSettings: Codable, Equatable {
    var enabled = true
    var kind: KillEffectKind = .electricExplosion
    var intensity = 0.8
    var duration = 1.25
    var colorHex = "#8B5CF6"
    var secondaryHex = "#22D3EE"
    var size = 1.0
    var speed = 1.0
    var screenFlash = true
    var shake = true
}

// MARK: - Skins

struct SkinChangerSettings: Codable, Equatable {
    var appliedSkins: [String: String] = [:]
}

// MARK: - Sky

struct SkySettings: Codable, Equatable {
    var enabled = true
    var preset: SkyPreset = .galaxy
    var intensity = 0.9
    var speed = 1.0
    var brightness = 0.0
    var temperature = 0.0
}

// MARK: - Environment

struct EnvironmentSettings: Codable, Equatable {
    var lightingEnabled = true
    var lighting = 1.0

    var saturationEnabled = true
    var saturation = 1.1

    var contrastEnabled = true
    var contrast = 1.05

    var exposureEnabled = true
    var exposure = 0.0

    var hueEnabled = false
    var hue = 0.0

    var tintEnabled = false
    var tintHex = "#8B5CF6"
    var tintStrength = 0.12

    var fogEnabled = true
    var fogDensity = 0.22
    var fogHex = "#8E9BB8"

    var bloomEnabled = true
    var bloom = 0.45

    var ambientGlowEnabled = true
    var ambientGlow = 0.35
    var ambientGlowHex = "#8B5CF6"

    var motionBlurEnabled = false
    var motionBlur = 0.25

    var dofEnabled = true
    var depthOfField = 0.35

    var vignetteEnabled = true
    var vignette = 0.4
}

// MARK: - Crosshair

struct CrosshairSettings: Codable, Equatable {
    var enabled = true
    var preset: CrosshairPreset = .classic
    var size = 18.0
    var thickness = 2.0
    var opacity = 1.0
    var colorHex = "#7CF2A1"
    var gap = 5.0
    var dot = true
    var dynamic = false
    var outline = true
    var glow = true
}

// MARK: - Interface preferences

struct UISettings: Codable, Equatable {
    var language: AppLanguage = .english
    var accentHex = "#8B5CF6"
    var theme: AppTheme = .graphite
    var animationsEnabled = true
    var refreshRate: RefreshRate = .fps60
    var reduceLoad = false
    var hapticsEnabled = true
}

// MARK: - Toast

struct ToastMessage: Identifiable, Equatable {
    let id: UUID
    let title: String
    let icon: String

    init(id: UUID = UUID(), title: String, icon: String) {
        self.id = id
        self.title = title
        self.icon = icon
    }
}
