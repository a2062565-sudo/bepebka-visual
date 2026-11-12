import SwiftUI

// MARK: - Categories

enum AppCategory: String, CaseIterable, Identifiable, Hashable {
    case visuals
    case targetHUD
    case particles
    case killEffects
    case skinChanger
    case skyChanger
    case environment
    case crosshair
    case configs
    case settings

    var id: String { rawValue }

    var titleEN: String {
        switch self {
        case .visuals: return "Visuals"
        case .targetHUD: return "Target HUD"
        case .particles: return "Particles"
        case .killEffects: return "Kill Effects"
        case .skinChanger: return "Skin Changer"
        case .skyChanger: return "Sky Changer"
        case .environment: return "Environment"
        case .crosshair: return "Crosshair"
        case .configs: return "Configs"
        case .settings: return "Settings"
        }
    }

    var titleRU: String {
        switch self {
        case .visuals: return "Визуалы"
        case .targetHUD: return "Target HUD"
        case .particles: return "Частицы"
        case .killEffects: return "Эффекты убийства"
        case .skinChanger: return "Скины"
        case .skyChanger: return "Небо"
        case .environment: return "Окружение"
        case .crosshair: return "Прицел"
        case .configs: return "Конфиги"
        case .settings: return "Настройки"
        }
    }

    var icon: String {
        switch self {
        case .visuals: return "eye.fill"
        case .targetHUD: return "scope"
        case .particles: return "sparkles"
        case .killEffects: return "bolt.fill"
        case .skinChanger: return "paintbrush.pointed.fill"
        case .skyChanger: return "cloud.moon.fill"
        case .environment: return "camera.filters"
        case .crosshair: return "plus"
        case .configs: return "square.stack.3d.up.fill"
        case .settings: return "slider.horizontal.3"
        }
    }

    var index: String {
        let position = (Self.allCases.firstIndex(of: self) ?? 0) + 1
        return String(format: "%02d", position)
    }

    var groupEN: String {
        switch self {
        case .visuals, .targetHUD, .particles, .killEffects: return "APPEARANCE"
        case .skinChanger, .skyChanger, .environment: return "WORLD"
        case .crosshair, .configs, .settings: return "SYSTEM"
        }
    }

    var groupRU: String {
        switch self {
        case .visuals, .targetHUD, .particles, .killEffects: return "ВНЕШНИЙ ВИД"
        case .skinChanger, .skyChanger, .environment: return "МИР"
        case .crosshair, .configs, .settings: return "СИСТЕМА"
        }
    }
}

// MARK: - Target HUD

enum HUDPlacement: String, CaseIterable, Codable, Identifiable, Hashable {
    case belowCrosshair
    case aboveCrosshair
    case center
    case bottomLeft
    case bottomRight

    var id: String { rawValue }

    var titleEN: String {
        switch self {
        case .belowCrosshair: return "Below"
        case .aboveCrosshair: return "Above"
        case .center: return "Center"
        case .bottomLeft: return "Left"
        case .bottomRight: return "Right"
        }
    }

    var titleRU: String {
        switch self {
        case .belowCrosshair: return "Снизу"
        case .aboveCrosshair: return "Сверху"
        case .center: return "Центр"
        case .bottomLeft: return "Слева"
        case .bottomRight: return "Справа"
        }
    }
}

enum HUDAnimationStyle: String, CaseIterable, Codable, Identifiable, Hashable {
    case fade
    case scale
    case slide
    case spring

    var id: String { rawValue }

    var titleEN: String {
        switch self {
        case .fade: return "Fade"
        case .scale: return "Scale"
        case .slide: return "Slide"
        case .spring: return "Spring"
        }
    }

    var titleRU: String {
        switch self {
        case .fade: return "Затухание"
        case .scale: return "Масштаб"
        case .slide: return "Сдвиг"
        case .spring: return "Пружина"
        }
    }

    var anyTransition: AnyTransition {
        switch self {
        case .fade: return .opacity
        case .scale: return .scale(scale: 0.86).combined(with: .opacity)
        case .slide: return .move(edge: .bottom).combined(with: .opacity)
        case .spring: return .scale(scale: 0.92).combined(with: .opacity)
        }
    }

    var animation: Animation {
        switch self {
        case .fade: return .easeOut(duration: 0.28)
        case .scale: return .easeOut(duration: 0.32)
        case .slide: return .easeOut(duration: 0.34)
        case .spring: return .spring(response: 0.42, dampingFraction: 0.7)
        }
    }
}

enum HUDStyle: String, CaseIterable, Codable, Identifiable, Hashable {
    case glass
    case neon
    case minimal
    case tactical
    case outline

    var id: String { rawValue }

    var titleEN: String {
        switch self {
        case .glass: return "Glass"
        case .neon: return "Neon"
        case .minimal: return "Minimal"
        case .tactical: return "Tactical"
        case .outline: return "Outline"
        }
    }

    var titleRU: String {
        switch self {
        case .glass: return "Стекло"
        case .neon: return "Неон"
        case .minimal: return "Минимал"
        case .tactical: return "Тактика"
        case .outline: return "Контур"
        }
    }
}

// MARK: - Visuals

enum HighlightStyle: String, CaseIterable, Codable, Identifiable, Hashable {
    case outline
    case glow
    case filled

    var id: String { rawValue }

    var titleEN: String {
        switch self {
        case .outline: return "Outline"
        case .glow: return "Glow"
        case .filled: return "Filled"
        }
    }

    var titleRU: String {
        switch self {
        case .outline: return "Контур"
        case .glow: return "Свечение"
        case .filled: return "Заливка"
        }
    }
}

// MARK: - Particles

enum ParticleKind: String, CaseIterable, Codable, Identifiable, Hashable {
    case snow
    case stars
    case sakura
    case hearts
    case fireflies
    case bubbles
    case glowingDust
    case neon
    case cosmicDust
    case leaves

    var id: String { rawValue }

    var titleEN: String {
        switch self {
        case .snow: return "Snow"
        case .stars: return "Stars"
        case .sakura: return "Sakura"
        case .hearts: return "Hearts"
        case .fireflies: return "Fireflies"
        case .bubbles: return "Bubbles"
        case .glowingDust: return "Glowing Dust"
        case .neon: return "Neon"
        case .cosmicDust: return "Cosmic Dust"
        case .leaves: return "Falling Leaves"
        }
    }

    var titleRU: String {
        switch self {
        case .snow: return "Снег"
        case .stars: return "Звёзды"
        case .sakura: return "Сакура"
        case .hearts: return "Сердечки"
        case .fireflies: return "Светлячки"
        case .bubbles: return "Пузыри"
        case .glowingDust: return "Светящаяся пыль"
        case .neon: return "Неон"
        case .cosmicDust: return "Космическая пыль"
        case .leaves: return "Листья"
        }
    }

    var icon: String {
        switch self {
        case .snow: return "snowflake"
        case .stars: return "star.fill"
        case .sakura: return "leaf.fill"
        case .hearts: return "heart.fill"
        case .fireflies: return "sparkle"
        case .bubbles: return "circle.dotted"
        case .glowingDust: return "sparkles"
        case .neon: return "bolt.horizontal.fill"
        case .cosmicDust: return "circle.grid.cross"
        case .leaves: return "leaf.fill"
        }
    }
}

enum ParticleDirection: String, CaseIterable, Codable, Identifiable, Hashable {
    case down
    case up
    case left
    case right
    case swirl

    var id: String { rawValue }

    var titleEN: String {
        switch self {
        case .down: return "Down"
        case .up: return "Up"
        case .left: return "Left"
        case .right: return "Right"
        case .swirl: return "Swirl"
        }
    }

    var titleRU: String {
        switch self {
        case .down: return "Вниз"
        case .up: return "Вверх"
        case .left: return "Влево"
        case .right: return "Вправо"
        case .swirl: return "Вихрь"
        }
    }

    var icon: String {
        switch self {
        case .down: return "arrow.down"
        case .up: return "arrow.up"
        case .left: return "arrow.left"
        case .right: return "arrow.right"
        case .swirl: return "tornado"
        }
    }
}

// MARK: - Kill Effects

enum KillEffectKind: String, CaseIterable, Codable, Identifiable, Hashable {
    case lightning
    case electricExplosion
    case neonRing
    case pixelExplosion
    case galaxy
    case fire
    case ice
    case purpleEnergy
    case glitch
    case digitalDissolve
    case crystalExplosion
    case rainbowBurst

    var id: String { rawValue }

    var titleEN: String {
        switch self {
        case .lightning: return "Lightning"
        case .electricExplosion: return "Electric Explosion"
        case .neonRing: return "Neon Ring"
        case .pixelExplosion: return "Pixel Explosion"
        case .galaxy: return "Galaxy"
        case .fire: return "Fire"
        case .ice: return "Ice"
        case .purpleEnergy: return "Purple Energy"
        case .glitch: return "Glitch"
        case .digitalDissolve: return "Digital Dissolve"
        case .crystalExplosion: return "Crystal Explosion"
        case .rainbowBurst: return "Rainbow Burst"
        }
    }

    var titleRU: String {
        switch self {
        case .lightning: return "Молния"
        case .electricExplosion: return "Электро-взрыв"
        case .neonRing: return "Неоновое кольцо"
        case .pixelExplosion: return "Пиксельный взрыв"
        case .galaxy: return "Галактика"
        case .fire: return "Огонь"
        case .ice: return "Лёд"
        case .purpleEnergy: return "Фиолетовая энергия"
        case .glitch: return "Глитч"
        case .digitalDissolve: return "Цифровое растворение"
        case .crystalExplosion: return "Кристальный взрыв"
        case .rainbowBurst: return "Радужный взрыв"
        }
    }

    var icon: String {
        switch self {
        case .lightning: return "bolt.fill"
        case .electricExplosion: return "bolt.circle.fill"
        case .neonRing: return "circle.circle.fill"
        case .pixelExplosion: return "square.grid.3x3.fill"
        case .galaxy: return "circle.hexagongrid.fill"
        case .fire: return "flame.fill"
        case .ice: return "snowflake"
        case .purpleEnergy: return "atom"
        case .glitch: return "waveform.path.ecg"
        case .digitalDissolve: return "square.dashed"
        case .crystalExplosion: return "diamond.fill"
        case .rainbowBurst: return "rainbow"
        }
    }
}

// MARK: - Sky

enum SkyPreset: String, CaseIterable, Codable, Identifiable, Hashable {
    case pureBlack
    case pureWhite
    case bloodRed
    case deepBlue
    case purple
    case sunset
    case darkOrange
    case pinkSky
    case emerald
    case space
    case blackHole
    case galaxy
    case nightSky
    case aurora
    case nebula
    case stars
    case cosmicStorm
    case solarEclipse
    case purpleUniverse

    var id: String { rawValue }

    var isAnimated: Bool {
        switch self {
        case .pureBlack, .pureWhite, .bloodRed, .deepBlue, .purple,
             .sunset, .darkOrange, .pinkSky, .emerald:
            return false
        default:
            return true
        }
    }

    var titleEN: String {
        switch self {
        case .pureBlack: return "Pure Black"
        case .pureWhite: return "Pure White"
        case .bloodRed: return "Blood Red"
        case .deepBlue: return "Deep Blue"
        case .purple: return "Purple"
        case .sunset: return "Sunset"
        case .darkOrange: return "Dark Orange"
        case .pinkSky: return "Pink Sky"
        case .emerald: return "Emerald"
        case .space: return "Space"
        case .blackHole: return "Black Hole"
        case .galaxy: return "Galaxy"
        case .nightSky: return "Night Sky"
        case .aurora: return "Aurora"
        case .nebula: return "Nebula"
        case .stars: return "Stars"
        case .cosmicStorm: return "Cosmic Storm"
        case .solarEclipse: return "Solar Eclipse"
        case .purpleUniverse: return "Purple Universe"
        }
    }

    var titleRU: String {
        switch self {
        case .pureBlack: return "Чистый чёрный"
        case .pureWhite: return "Чистый белый"
        case .bloodRed: return "Кроваво-красный"
        case .deepBlue: return "Глубокий синий"
        case .purple: return "Фиолетовый"
        case .sunset: return "Закат"
        case .darkOrange: return "Тёмно-оранжевый"
        case .pinkSky: return "Розовое небо"
        case .emerald: return "Изумруд"
        case .space: return "Космос"
        case .blackHole: return "Чёрная дыра"
        case .galaxy: return "Галактика"
        case .nightSky: return "Ночное небо"
        case .aurora: return "Полярное сияние"
        case .nebula: return "Туманность"
        case .stars: return "Звёзды"
        case .cosmicStorm: return "Космическая буря"
        case .solarEclipse: return "Солнечное затмение"
        case .purpleUniverse: return "Фиолетовая вселенная"
        }
    }

    var colors: [Color] {
        switch self {
        case .pureBlack:
            return [Color(hex: "#000000"), Color(hex: "#060609")]
        case .pureWhite:
            return [Color(hex: "#F8FAFC"), Color(hex: "#FFFFFF")]
        case .bloodRed:
            return [Color(hex: "#1A0205"), Color(hex: "#5C0712"), Color(hex: "#C31327")]
        case .deepBlue:
            return [Color(hex: "#020617"), Color(hex: "#071B3F"), Color(hex: "#10458C")]
        case .purple:
            return [Color(hex: "#12021F"), Color(hex: "#351055"), Color(hex: "#7C3AED")]
        case .sunset:
            return [Color(hex: "#251023"), Color(hex: "#7C2847"), Color(hex: "#EC6A5C"), Color(hex: "#FFC98A")]
        case .darkOrange:
            return [Color(hex: "#150804"), Color(hex: "#4A1905"), Color(hex: "#B33A0B")]
        case .pinkSky:
            return [Color(hex: "#2A0A1C"), Color(hex: "#8F3763"), Color(hex: "#F19BC4"), Color(hex: "#FFE3EF")]
        case .emerald:
            return [Color(hex: "#010F0A"), Color(hex: "#064534"), Color(hex: "#0F9F74")]
        case .space:
            return [Color(hex: "#01030B"), Color(hex: "#060A22"), Color(hex: "#162B63")]
        case .blackHole:
            return [Color(hex: "#000000"), Color(hex: "#06030E"), Color(hex: "#271247")]
        case .galaxy:
            return [Color(hex: "#020109"), Color(hex: "#100827"), Color(hex: "#31175C")]
        case .nightSky:
            return [Color(hex: "#020617"), Color(hex: "#08152F"), Color(hex: "#17346B")]
        case .aurora:
            return [Color(hex: "#010B0D"), Color(hex: "#042422"), Color(hex: "#0B3348")]
        case .nebula:
            return [Color(hex: "#080311"), Color(hex: "#2A1547"), Color(hex: "#4D1C8C")]
        case .stars:
            return [Color(hex: "#01030A"), Color(hex: "#050D22"), Color(hex: "#0C1730")]
        case .cosmicStorm:
            return [Color(hex: "#080411"), Color(hex: "#22104A"), Color(hex: "#4B1D89")]
        case .solarEclipse:
            return [Color(hex: "#010001"), Color(hex: "#0A040D"), Color(hex: "#1A0C28")]
        case .purpleUniverse:
            return [Color(hex: "#06010D"), Color(hex: "#230843"), Color(hex: "#5B21B6")]
        }
    }

    var accentColors: [Color] {
        switch self {
        case .pureBlack: return [Color.white.opacity(0.7)]
        case .pureWhite: return [Color(hex: "#64748B")]
        case .bloodRed: return [Color(hex: "#FF5A6E"), Color(hex: "#FFB3BC")]
        case .deepBlue: return [Color(hex: "#60A5FA"), Color(hex: "#BFDBFE")]
        case .purple: return [Color(hex: "#C084FC"), Color(hex: "#F0ABFC")]
        case .sunset: return [Color(hex: "#FCD34D"), Color(hex: "#FB7185")]
        case .darkOrange: return [Color(hex: "#FB923C"), Color(hex: "#FDE68A")]
        case .pinkSky: return [Color(hex: "#F9A8D4"), Color(hex: "#FBCFE8")]
        case .emerald: return [Color(hex: "#34D399"), Color(hex: "#A7F3D0")]
        case .space: return [Color(hex: "#A5B4FC"), Color(hex: "#F0ABFC")]
        case .blackHole: return [Color(hex: "#C084FC"), Color(hex: "#FBBF24")]
        case .galaxy: return [Color(hex: "#C4B5FD"), Color(hex: "#F0ABFC"), Color(hex: "#67E8F9")]
        case .nightSky: return [Color(hex: "#BFDBFE"), Color(hex: "#FDE68A")]
        case .aurora: return [Color(hex: "#34D399"), Color(hex: "#22D3EE"), Color(hex: "#A78BFA")]
        case .nebula: return [Color(hex: "#F472B6"), Color(hex: "#38BDF8"), Color(hex: "#C084FC")]
        case .stars: return [Color(hex: "#E0E7FF"), Color(hex: "#93C5FD")]
        case .cosmicStorm: return [Color(hex: "#A78BFA"), Color(hex: "#22D3EE")]
        case .solarEclipse: return [Color(hex: "#FDE68A"), Color(hex: "#C084FC")]
        case .purpleUniverse: return [Color(hex: "#E879F9"), Color(hex: "#A78BFA")]
        }
    }
}

// MARK: - Skins

enum WeaponCategory: String, CaseIterable, Codable, Identifiable, Hashable {
    case pistols
    case rifles
    case snipers
    case smgs
    case shotguns
    case knives
    case gloves

    var id: String { rawValue }

    var titleEN: String {
        switch self {
        case .pistols: return "Pistols"
        case .rifles: return "Rifles"
        case .snipers: return "Snipers"
        case .smgs: return "SMGs"
        case .shotguns: return "Shotguns"
        case .knives: return "Knives"
        case .gloves: return "Gloves"
        }
    }

    var titleRU: String {
        switch self {
        case .pistols: return "Пистолеты"
        case .rifles: return "Винтовки"
        case .snipers: return "Снайперки"
        case .smgs: return "ПП"
        case .shotguns: return "Дробовики"
        case .knives: return "Ножи"
        case .gloves: return "Перчатки"
        }
    }

    var icon: String {
        switch self {
        case .pistols: return "handgun.fill"
        case .rifles: return "scope"
        case .snipers: return "target"
        case .smgs: return "bolt.horizontal.fill"
        case .shotguns: return "burst.fill"
        case .knives: return "triangle.fill"
        case .gloves: return "hand.raised.fill"
        }
    }
}

enum SkinRarity: String, CaseIterable, Codable, Identifiable, Hashable {
    case common
    case rare
    case epic
    case legendary
    case mythic

    var id: String { rawValue }

    var titleEN: String {
        switch self {
        case .common: return "Common"
        case .rare: return "Rare"
        case .epic: return "Epic"
        case .legendary: return "Legendary"
        case .mythic: return "Mythic"
        }
    }

    var titleRU: String {
        switch self {
        case .common: return "Обычный"
        case .rare: return "Редкий"
        case .epic: return "Эпический"
        case .legendary: return "Легендарный"
        case .mythic: return "Мифический"
        }
    }

    var color: Color {
        switch self {
        case .common: return Color(hex: "#9CA3AF")
        case .rare: return Color(hex: "#38BDF8")
        case .epic: return Color(hex: "#A78BFA")
        case .legendary: return Color(hex: "#FBBF24")
        case .mythic: return Color(hex: "#FB7185")
        }
    }

    var sortIndex: Int {
        switch self {
        case .common: return 0
        case .rare: return 1
        case .epic: return 2
        case .legendary: return 3
        case .mythic: return 4
        }
    }
}

enum SkinPattern: String, Codable, Hashable {
    case carbon
    case fade
    case stripes
    case geometric
    case camo
    case liquid
    case marble
    case blossom
    case glow
    case cosmic
}

// MARK: - Crosshair

enum CrosshairPreset: String, CaseIterable, Codable, Identifiable, Hashable {
    case classic
    case dot
    case cross
    case neon
    case minimal
    case sniper

    var id: String { rawValue }

    var titleEN: String {
        switch self {
        case .classic: return "Classic"
        case .dot: return "Dot"
        case .cross: return "Cross"
        case .neon: return "Neon"
        case .minimal: return "Minimal"
        case .sniper: return "Sniper"
        }
    }

    var titleRU: String {
        switch self {
        case .classic: return "Классика"
        case .dot: return "Точка"
        case .cross: return "Крест"
        case .neon: return "Неон"
        case .minimal: return "Минимал"
        case .sniper: return "Снайпер"
        }
    }

    var previewColor: Color {
        switch self {
        case .classic: return Color(hex: "#A7F3D0")
        case .dot: return Color(hex: "#E5E7EB")
        case .cross: return Color(hex: "#F9A8D4")
        case .neon: return Color(hex: "#22D3EE")
        case .minimal: return Color(hex: "#FFFFFF")
        case .sniper: return Color(hex: "#FCA5A5")
        }
    }
}

// MARK: - Client preferences

enum AppLanguage: String, CaseIterable, Codable, Identifiable, Hashable {
    case english
    case russian

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        }
    }

    var shortCode: String {
        switch self {
        case .english: return "EN"
        case .russian: return "RU"
        }
    }
}

enum AppTheme: String, CaseIterable, Codable, Identifiable, Hashable {
    case graphite
    case midnight
    case obsidian
    case carbon

    var id: String { rawValue }

    var titleEN: String {
        switch self {
        case .graphite: return "Graphite"
        case .midnight: return "Midnight"
        case .obsidian: return "Obsidian"
        case .carbon: return "Carbon"
        }
    }

    var titleRU: String {
        switch self {
        case .graphite: return "Графит"
        case .midnight: return "Полночь"
        case .obsidian: return "Обсидиан"
        case .carbon: return "Карбон"
        }
    }

    var previewColors: [Color] {
        switch self {
        case .graphite:
            return [Color(hex: "#17181C"), Color(hex: "#08090B")]
        case .midnight:
            return [Color(hex: "#0B1222"), Color(hex: "#03060E")]
        case .obsidian:
            return [Color(hex: "#0E0E10"), Color(hex: "#000000")]
        case .carbon:
            return [Color(hex: "#1B1B1F"), Color(hex: "#0A0A0C")]
        }
    }

    var backgroundColors: [Color] {
        switch self {
        case .graphite:
            return [Color(hex: "#121317"), Color(hex: "#08090B"), Color(hex: "#050506")]
        case .midnight:
            return [Color(hex: "#09101E"), Color(hex: "#050912"), Color(hex: "#020307")]
        case .obsidian:
            return [Color(hex: "#0B0B0D"), Color(hex: "#040405"), Color(hex: "#000000")]
        case .carbon:
            return [Color(hex: "#161619"), Color(hex: "#0B0B0D"), Color(hex: "#060607")]
        }
    }
}

enum RefreshRate: Int, CaseIterable, Codable, Identifiable, Hashable {
    case fps30 = 30
    case fps60 = 60
    case fps120 = 120

    var id: Int { rawValue }

    var title: String { "\(rawValue) FPS" }
    var interval: Double { 1.0 / Double(rawValue) }
}
