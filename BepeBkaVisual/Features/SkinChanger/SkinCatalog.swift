import SwiftUI

// MARK: - Catalog models

struct WeaponEntry: Identifiable, Hashable {
    let id: String
    let name: String
    let category: WeaponCategory
    let icon: String
    let descriptorEN: String
    let descriptorRU: String
}

struct SkinEntry: Identifiable, Hashable {
    let id: String
    let weaponID: String
    let nameEN: String
    let nameRU: String
    let rarity: SkinRarity
    let pattern: SkinPattern
    let primaryHex: String
    let secondaryHex: String
    let accentHex: String
    let collectionEN: String
    let collectionRU: String

    var primary: Color { Color(hex: primaryHex) }
    var secondary: Color { Color(hex: secondaryHex) }
    var accent: Color { Color(hex: accentHex) }
}

// MARK: - Catalog

enum SkinCatalog {
    static let weapons: [WeaponEntry] = [
        WeaponEntry(id: "glock", name: "Glock-18", category: .pistols, icon: "handgun.fill", descriptorEN: "Light pistol", descriptorRU: "Лёгкий пистолет"),
        WeaponEntry(id: "usp", name: "USP-S", category: .pistols, icon: "handgun.fill", descriptorEN: "Silenced pistol", descriptorRU: "Пистолет с глушителем"),
        WeaponEntry(id: "deagle", name: "Desert Eagle", category: .pistols, icon: "handgun.fill", descriptorEN: "Heavy pistol", descriptorRU: "Тяжёлый пистолет"),
        WeaponEntry(id: "ak47", name: "AK-47", category: .rifles, icon: "scope", descriptorEN: "Assault rifle", descriptorRU: "Автомат"),
        WeaponEntry(id: "m4a4", name: "M4A4", category: .rifles, icon: "scope", descriptorEN: "Assault rifle", descriptorRU: "Автомат"),
        WeaponEntry(id: "famas", name: "FAMAS", category: .rifles, icon: "scope", descriptorEN: "Bullpup rifle", descriptorRU: "Винтовка булл-пап"),
        WeaponEntry(id: "awp", name: "AWP", category: .snipers, icon: "target", descriptorEN: "Bolt-action sniper", descriptorRU: "Снайперская винтовка"),
        WeaponEntry(id: "ssg08", name: "SSG 08", category: .snipers, icon: "target", descriptorEN: "Light sniper", descriptorRU: "Лёгкая снайперка"),
        WeaponEntry(id: "mp9", name: "MP9", category: .smgs, icon: "bolt.horizontal.fill", descriptorEN: "Compact SMG", descriptorRU: "Компактный ПП"),
        WeaponEntry(id: "p90", name: "P90", category: .smgs, icon: "bolt.horizontal.fill", descriptorEN: "Bullpup SMG", descriptorRU: "ПП булл-пап"),
        WeaponEntry(id: "mag7", name: "MAG-7", category: .shotguns, icon: "burst.fill", descriptorEN: "Compact shotgun", descriptorRU: "Компактный дробовик"),
        WeaponEntry(id: "nova", name: "Nova", category: .shotguns, icon: "burst.fill", descriptorEN: "Pump shotgun", descriptorRU: "Помповый дробовик"),
        WeaponEntry(id: "karambit", name: "Karambit", category: .knives, icon: "triangle.fill", descriptorEN: "Curved blade", descriptorRU: "Изогнутый клинок"),
        WeaponEntry(id: "butterfly", name: "Butterfly", category: .knives, icon: "triangle.fill", descriptorEN: "Folding blade", descriptorRU: "Складной клинок"),
        WeaponEntry(id: "sport", name: "Sport Gloves", category: .gloves, icon: "hand.raised.fill", descriptorEN: "Performance gloves", descriptorRU: "Спортивные перчатки"),
        WeaponEntry(id: "specialist", name: "Specialist", category: .gloves, icon: "hand.raised.fill", descriptorEN: "Tactical gloves", descriptorRU: "Тактические перчатки")
    ]

    static let skins: [SkinEntry] = [
        // Pistols
        skin("glock-neon-wraith", "glock", "Neon Wraith", "Неоновый призрак", .epic, .stripes, "#22D3EE", "#0E7490", "#A5F3FC", "Chromatic Lab", "Хроматическая лаборатория"),
        skin("glock-carbon-pulse", "glock", "Carbon Pulse", "Карбоновый пульс", .rare, .carbon, "#64748B", "#111827", "#94A3B8", "Night Ops", "Ночные операции"),
        skin("glock-blossom", "glock", "Blossom Atelier", "Ателье цветов", .legendary, .blossom, "#F9A8D4", "#BE185D", "#FBCFE8", "Sakura Series", "Серия Sakura"),

        skin("usp-white-protocol", "usp", "White Protocol", "Белый протокол", .epic, .fade, "#F8FAFC", "#94A3B8", "#E2E8F0", "Monochrome", "Монохром"),
        skin("usp-violet-hush", "usp", "Violet Hush", "Фиолетовая тишина", .rare, .liquid, "#A78BFA", "#312E81", "#DDD6FE", "Astral Series", "Серия Astral"),
        skin("usp-solar-ember", "usp", "Solar Ember", "Солнечный уголь", .mythic, .glow, "#FB923C", "#7C2D12", "#FDE68A", "Helios", "Гелиос"),

        skin("deagle-golden-verdict", "deagle", "Golden Verdict", "Золотой вердикт", .legendary, .geometric, "#FBBF24", "#78350F", "#FEF3C7", "Royal Arsenal", "Королевский арсенал"),
        skin("deagle-crimson-circuit", "deagle", "Crimson Circuit", "Багровая цепь", .epic, .carbon, "#FB7185", "#4C0519", "#FDA4AF", "Night Ops", "Ночные операции"),
        skin("deagle-obsidian", "deagle", "Obsidian Glass", "Обсидиановое стекло", .rare, .marble, "#CBD5E1", "#0F172A", "#F1F5F9", "Monochrome", "Монохром"),

        // Rifles
        skin("ak47-galaxy-nomad", "ak47", "Galaxy Nomad", "Галактический кочевник", .mythic, .cosmic, "#C4B5FD", "#1E1B4B", "#F0ABFC", "Astral Series", "Серия Astral"),
        skin("ak47-blood-orbit", "ak47", "Blood Orbit", "Кровавая орбита", .legendary, .liquid, "#F43F5E", "#450A0A", "#FDA4AF", "Crimson Series", "Серия Crimson"),
        skin("ak47-patina-strike", "ak47", "Patina Strike", "Патинный удар", .rare, .camo, "#84CC16", "#3F6212", "#D9F99D", "Field Tested", "Полевые испытания"),

        skin("m4a4-aurora-grid", "m4a4", "Aurora Grid", "Сетка авроры", .legendary, .geometric, "#34D399", "#0F766E", "#22D3EE", "Polar Lab", "Полярная лаборатория"),
        skin("m4a4-midnight-silk", "m4a4", "Midnight Silk", "Полночный шёлк", .epic, .fade, "#6366F1", "#0B1026", "#A5B4FC", "Night Ops", "Ночные операции"),
        skin("m4a4-mint-fragment", "m4a4", "Mint Fragment", "Мятный фрагмент", .rare, .stripes, "#6EE7B7", "#065F46", "#A7F3D0", "Chromatic Lab", "Хроматическая лаборатория"),

        skin("famas-signal-flare", "famas", "Signal Flare", "Сигнальная вспышка", .epic, .stripes, "#FB923C", "#9A3412", "#FDE68A", "Helios", "Гелиос"),
        skin("famas-frost-byte", "famas", "Frost Byte", "Морозный байт", .rare, .carbon, "#93C5FD", "#1E3A8A", "#DBEAFE", "Polar Lab", "Полярная лаборатория"),
        skin("famas-toxic-bloom", "famas", "Toxic Bloom", "Токсичный цвет", .legendary, .blossom, "#A3E635", "#365314", "#ECFCCB", "Wild Growth", "Дикий рост"),

        // Snipers
        skin("awp-event-horizon", "awp", "Event Horizon", "Горизонт событий", .mythic, .cosmic, "#A78BFA", "#0B0618", "#E879F9", "Astral Series", "Серия Astral"),
        skin("awp-solar-eclipse", "awp", "Solar Eclipse", "Солнечное затмение", .mythic, .glow, "#FBBF24", "#111827", "#FDE68A", "Helios", "Гелиос"),
        skin("awp-arctic-veil", "awp", "Arctic Veil", "Арктическая вуаль", .legendary, .marble, "#BAE6FD", "#0C4A6E", "#F0F9FF", "Polar Lab", "Полярная лаборатория"),

        skin("ssg08-neon-tracer", "ssg08", "Neon Tracer", "Неоновый трассер", .epic, .stripes, "#22D3EE", "#0E7490", "#CFFAFE", "Chromatic Lab", "Хроматическая лаборатория"),
        skin("ssg08-cinder", "ssg08", "Cinder", "Тлеющий пепел", .rare, .camo, "#F97316", "#431407", "#FDBA74", "Wild Growth", "Дикий рост"),
        skin("ssg08-lunar-dust", "ssg08", "Lunar Dust", "Лунная пыль", .epic, .cosmic, "#E2E8F0", "#475569", "#F8FAFC", "Astral Series", "Серия Astral"),

        // SMGs
        skin("mp9-bubblegum-riot", "mp9", "Bubblegum Riot", "Баблгамный бунт", .legendary, .geometric, "#F9A8D4", "#BE185D", "#FBCFE8", "Sugar Rush", "Сахарный раш"),
        skin("mp9-hologram", "mp9", "Hologram", "Голограмма", .epic, .fade, "#67E8F9", "#6366F1", "#CFFAFE", "Chromatic Lab", "Хроматическая лаборатория"),
        skin("mp9-stealth-weave", "mp9", "Stealth Weave", "Скрытое плетение", .rare, .carbon, "#94A3B8", "#1E293B", "#CBD5E1", "Night Ops", "Ночные операции"),

        skin("p90-cyber-tide", "p90", "Cyber Tide", "Киберволна", .epic, .liquid, "#2DD4BF", "#0F766E", "#99F6E4", "Chromatic Lab", "Хроматическая лаборатория"),
        skin("p90-voidwalker", "p90", "Voidwalker", "Странник пустоты", .legendary, .cosmic, "#8B5CF6", "#1E1B4B", "#DDD6FE", "Astral Series", "Серия Astral"),
        skin("p90-sandstorm", "p90", "Sandstorm", "Песчаная буря", .rare, .camo, "#D6A15A", "#451A03", "#FDE68A", "Field Tested", "Полевые испытания"),

        // Shotguns
        skin("mag7-tiger-coil", "mag7", "Tiger Coil", "Тигриная спираль", .epic, .stripes, "#F59E0B", "#431407", "#FDE68A", "Wild Growth", "Дикий рост"),
        skin("mag7-deep-reef", "mag7", "Deep Reef", "Глубокий риф", .rare, .liquid, "#22D3EE", "#083344", "#A5F3FC", "Tide Series", "Серия Tide"),
        skin("mag7-ember-shell", "mag7", "Ember Shell", "Тлеющий патрон", .legendary, .fade, "#FB7185", "#7C2D12", "#FDE68A", "Helios", "Гелиос"),

        skin("nova-graphite-bloom", "nova", "Graphite Bloom", "Графитовый цвет", .rare, .blossom, "#CBD5E1", "#334155", "#F1F5F9", "Monochrome", "Монохром"),
        skin("nova-jungle-signal", "nova", "Jungle Signal", "Сигнал джунглей", .epic, .camo, "#4ADE80", "#14532D", "#BBF7D0", "Wild Growth", "Дикий рост"),
        skin("nova-royal-pulse", "nova", "Royal Pulse", "Королевский пульс", .legendary, .glow, "#A855F7", "#3B0764", "#F0ABFC", "Royal Arsenal", "Королевский арсенал"),

        // Knives
        skin("karambit-void-fang", "karambit", "Void Fang", "Клык пустоты", .mythic, .glow, "#A855F7", "#1E1B4B", "#E879F9", "Astral Series", "Серия Astral"),
        skin("karambit-damascus-dawn", "karambit", "Damascus Dawn", "Дамасский рассвет", .legendary, .marble, "#FCD34D", "#78350F", "#FEF3C7", "Royal Arsenal", "Королевский арсенал"),
        skin("karambit-cyan-edge", "karambit", "Cyan Edge", "Голубая кромка", .epic, .fade, "#22D3EE", "#0E7490", "#CFFAFE", "Polar Lab", "Полярная лаборатория"),

        skin("butterfly-prism-fold", "butterfly", "Prism Fold", "Призматический изгиб", .mythic, .fade, "#F472B6", "#22D3EE", "#FDF2F8", "Chromatic Lab", "Хроматическая лаборатория"),
        skin("butterfly-obsidian-wing", "butterfly", "Obsidian Wing", "Обсидиановое крыло", .legendary, .carbon, "#64748B", "#020617", "#CBD5E1", "Night Ops", "Ночные операции"),
        skin("butterfly-solaris", "butterfly", "Solaris", "Солярис", .epic, .glow, "#FBBF24", "#78350F", "#FEF9C3", "Helios", "Гелиос"),

        // Gloves
        skin("sport-violet-grip", "sport", "Violet Grip", "Фиолетовый хват", .epic, .geometric, "#8B5CF6", "#312E81", "#DDD6FE", "Astral Series", "Серия Astral"),
        skin("sport-carbon-knit", "sport", "Carbon Knit", "Карбоновая вязка", .rare, .carbon, "#475569", "#0F172A", "#94A3B8", "Night Ops", "Ночные операции"),
        skin("sport-cloud-nine", "sport", "Cloud Nine", "Девятое облако", .legendary, .marble, "#E2E8F0", "#7DD3FC", "#F8FAFC", "Polar Lab", "Полярная лаборатория"),

        skin("specialist-neon-palm", "specialist", "Neon Palm", "Неоновая ладонь", .epic, .stripes, "#22D3EE", "#6D28D9", "#CFFAFE", "Chromatic Lab", "Хроматическая лаборатория"),
        skin("specialist-desert-ops", "specialist", "Desert Ops", "Пустынные операции", .rare, .camo, "#D6A15A", "#451A03", "#FDE68A", "Field Tested", "Полевые испытания"),
        skin("specialist-frost-guard", "specialist", "Frost Guard", "Морозный страж", .legendary, .fade, "#BFDBFE", "#1E3A8A", "#F0F9FF", "Polar Lab", "Полярная лаборатория")
    ]

    // MARK: Queries

    static func weapons(in category: WeaponCategory) -> [WeaponEntry] {
        weapons.filter { $0.category == category }
    }

    static func weapon(withID id: String) -> WeaponEntry? {
        weapons.first { $0.id == id }
    }

    static func skin(withID id: String) -> SkinEntry? {
        skins.first { $0.id == id }
    }

    static func skins(for weapon: WeaponEntry) -> [SkinEntry] {
        skins.filter { $0.weaponID == weapon.id }
    }

    static func appliedSkin(for weapon: WeaponEntry, settings: SkinChangerSettings) -> SkinEntry? {
        guard let id = settings.appliedSkins[weapon.id] else { return nil }
        return skin(withID: id)
    }

    static func searchSkins(query: String, rarity: SkinRarity?) -> [SkinEntry] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return skins.filter { skin in
            if let rarity, skin.rarity != rarity { return false }
            guard !trimmed.isEmpty else { return false }

            let weaponName = weapon(withID: skin.weaponID)?.name.lowercased() ?? ""
            return skin.nameEN.lowercased().contains(trimmed)
                || skin.nameRU.lowercased().contains(trimmed)
                || weaponName.contains(trimmed)
                || skin.collectionEN.lowercased().contains(trimmed)
                || skin.collectionRU.lowercased().contains(trimmed)
        }
    }

    // MARK: Private

    private static func skin(
        _ id: String,
        _ weaponID: String,
        _ nameEN: String,
        _ nameRU: String,
        _ rarity: SkinRarity,
        _ pattern: SkinPattern,
        _ primaryHex: String,
        _ secondaryHex: String,
        _ accentHex: String,
        _ collectionEN: String,
        _ collectionRU: String
    ) -> SkinEntry {
        SkinEntry(
            id: id,
            weaponID: weaponID,
            nameEN: nameEN,
            nameRU: nameRU,
            rarity: rarity,
            pattern: pattern,
            primaryHex: primaryHex,
            secondaryHex: secondaryHex,
            accentHex: accentHex,
            collectionEN: collectionEN,
            collectionRU: collectionRU
        )
    }
}

// MARK: - Weapon silhouette

struct WeaponSilhouette: Shape {
    let category: WeaponCategory

    func path(in rect: CGRect) -> Path {
        var path = Path()

        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
        }

        func box(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ radius: CGFloat) -> Path {
            Path(
                roundedRect: CGRect(
                    x: rect.minX + rect.width * x,
                    y: rect.minY + rect.height * y,
                    width: rect.width * w,
                    height: rect.height * h
                ),
                cornerRadius: min(rect.width, rect.height) * radius
            )
        }

        func polygon(_ points: [CGPoint]) -> Path {
            var poly = Path()
            guard let first = points.first else { return poly }
            poly.move(to: first)
            for point in points.dropFirst() {
                poly.addLine(to: point)
            }
            poly.closeSubpath()
            return poly
        }

        switch category {
        case .pistols:
            path.addPath(box(0.12, 0.22, 0.62, 0.22, 0.018))
            path.addPath(box(0.74, 0.26, 0.12, 0.13, 0.014))
            path.addPath(polygon([
                point(0.27, 0.41), point(0.47, 0.41), point(0.44, 0.78),
                point(0.32, 0.86), point(0.23, 0.52)
            ]))
            path.addPath(box(0.19, 0.82, 0.15, 0.055, 0.02))
            path.addPath(box(0.44, 0.21, 0.06, 0.05, 0.012))
            path.addPath(box(0.13, 0.34, 0.30, 0.035, 0.008))

        case .rifles:
            path.addPath(polygon([
                point(0.02, 0.34), point(0.19, 0.30), point(0.25, 0.37),
                point(0.23, 0.52), point(0.06, 0.56)
            ]))
            path.addPath(box(0.22, 0.31, 0.31, 0.20, 0.018))
            path.addPath(box(0.51, 0.345, 0.30, 0.11, 0.014))
            path.addPath(box(0.78, 0.385, 0.19, 0.044, 0.01))
            path.addPath(polygon([
                point(0.37, 0.48), point(0.49, 0.48), point(0.47, 0.78),
                point(0.33, 0.73)
            ]))
            path.addPath(polygon([
                point(0.26, 0.49), point(0.34, 0.49), point(0.32, 0.69),
                point(0.24, 0.66)
            ]))
            path.addPath(box(0.43, 0.245, 0.11, 0.075, 0.012))
            path.addPath(box(0.585, 0.30, 0.13, 0.035, 0.008))

        case .snipers:
            path.addPath(polygon([
                point(0.01, 0.35), point(0.18, 0.31), point(0.25, 0.38),
                point(0.22, 0.54), point(0.05, 0.58)
            ]))
            path.addPath(box(0.21, 0.34, 0.28, 0.18, 0.016))
            path.addPath(box(0.47, 0.37, 0.39, 0.065, 0.012))
            path.addPath(box(0.85, 0.385, 0.13, 0.032, 0.008))
            path.addPath(box(0.40, 0.19, 0.24, 0.09, 0.035))
            path.addPath(box(0.455, 0.275, 0.06, 0.07, 0.01))
            path.addPath(polygon([
                point(0.34, 0.50), point(0.44, 0.50), point(0.42, 0.76),
                point(0.31, 0.72)
            ]))
            path.addPath(polygon([
                point(0.25, 0.51), point(0.32, 0.51), point(0.30, 0.69),
                point(0.23, 0.66)
            ]))
            path.addPath(box(0.47, 0.47, 0.06, 0.035, 0.01))

        case .smgs:
            path.addPath(box(0.02, 0.37, 0.19, 0.07, 0.012))
            path.addPath(box(0.17, 0.30, 0.44, 0.22, 0.022))
            path.addPath(box(0.59, 0.36, 0.26, 0.055, 0.012))
            path.addPath(box(0.39, 0.49, 0.095, 0.30, 0.02))
            path.addPath(polygon([
                point(0.27, 0.50), point(0.35, 0.50), point(0.33, 0.69),
                point(0.25, 0.66)
            ]))
            path.addPath(box(0.20, 0.30, 0.10, 0.055, 0.012))
            path.addPath(box(0.63, 0.30, 0.07, 0.045, 0.01))

        case .shotguns:
            path.addPath(polygon([
                point(0.01, 0.36), point(0.22, 0.32), point(0.28, 0.39),
                point(0.25, 0.55), point(0.04, 0.58)
            ]))
            path.addPath(box(0.23, 0.34, 0.22, 0.17, 0.016))
            path.addPath(box(0.43, 0.355, 0.54, 0.06, 0.012))
            path.addPath(box(0.53, 0.415, 0.18, 0.095, 0.025))
            path.addPath(polygon([
                point(0.29, 0.50), point(0.37, 0.50), point(0.35, 0.69),
                point(0.27, 0.66)
            ]))
            path.addPath(box(0.28, 0.30, 0.08, 0.045, 0.01))

        case .knives:
            var blade = Path()
            blade.move(to: point(0.10, 0.63))
            blade.addCurve(
                to: point(0.58, 0.26),
                control1: point(0.22, 0.48),
                control2: point(0.40, 0.27)
            )
            blade.addCurve(
                to: point(0.64, 0.43),
                control1: point(0.67, 0.25),
                control2: point(0.69, 0.34)
            )
            blade.addCurve(
                to: point(0.24, 0.69),
                control1: point(0.52, 0.59),
                control2: point(0.35, 0.69)
            )
            blade.closeSubpath()
            path.addPath(blade)

            var handle = Path()
            handle.move(to: point(0.58, 0.49))
            handle.addLine(to: point(0.86, 0.35))
            handle.addLine(to: point(0.94, 0.46))
            handle.addLine(to: point(0.68, 0.63))
            handle.closeSubpath()
            path.addPath(handle)

        case .gloves:
            path.addPath(box(0.24, 0.38, 0.44, 0.38, 0.10))
            path.addPath(box(0.25, 0.17, 0.09, 0.31, 0.045))
            path.addPath(box(0.355, 0.10, 0.09, 0.37, 0.045))
            path.addPath(box(0.46, 0.12, 0.09, 0.35, 0.045))
            path.addPath(box(0.565, 0.18, 0.09, 0.28, 0.045))
            path.addPath(polygon([
                point(0.25, 0.44), point(0.18, 0.50), point(0.12, 0.62),
                point(0.17, 0.69), point(0.28, 0.62), point(0.30, 0.51)
            ]))
            path.addPath(box(0.27, 0.69, 0.36, 0.13, 0.04))
        }

        return path
    }
}
