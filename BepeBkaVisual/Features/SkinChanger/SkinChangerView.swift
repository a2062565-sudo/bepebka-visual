import SwiftUI

struct SkinChangerView: View {
    @EnvironmentObject private var store: ClientStore

    @State private var selectedCategory: WeaponCategory = .rifles
    @State private var selectedWeaponID = "ak47"
    @State private var previewSkinID: String? = "ak47-galaxy-nomad"
    @State private var search = ""
    @State private var rarityFilter: SkinRarity?
    @State private var isPulsing = false

    // MARK: - Derived

    private var selectedWeapon: WeaponEntry {
        if let weapon = SkinCatalog.weapon(withID: selectedWeaponID),
           weapon.category == selectedCategory {
            return weapon
        }
        return SkinCatalog.weapons(in: selectedCategory).first ?? SkinCatalog.weapons[0]
    }

    private var selectedSkin: SkinEntry? {
        let skins = SkinCatalog.skins(for: selectedWeapon)
        if let previewSkinID, let match = skins.first(where: { $0.id == previewSkinID }) {
            return match
        }
        if let applied = SkinCatalog.appliedSkin(for: selectedWeapon, settings: store.settings.skinChanger) {
            return applied
        }
        return skins.first
    }

    private var isApplied: Bool {
        guard let selectedSkin else { return false }
        return store.settings.skinChanger.appliedSkins[selectedWeapon.id] == selectedSkin.id
    }

    private var appliedCount: Int {
        store.settings.skinChanger.appliedSkins.count
    }

    private var isSearching: Bool {
        !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var gallerySkins: [SkinEntry] {
        if isSearching {
            return SkinCatalog.searchSkins(query: search, rarity: rarityFilter)
        }
        return SkinCatalog.skins(for: selectedWeapon).filter { skin in
            rarityFilter == nil || skin.rarity == rarityFilter
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ModuleHeader(
                category: .skinChanger,
                subtitleEN: "A private cosmetic atelier. Browse the arsenal, preview original finishes, and keep a local loadout record.",
                subtitleRU: "Частное косметическое ателье. Просматривайте арсенал, примеряйте авторские отделки и храните локальный список экипировки."
            )

            if let skin = selectedSkin {
                preview(skin: skin)
                actionBar(skin: skin)
            }

            categoryPicker

            HStack(spacing: 8) {
                BVSearchField(
                    text: $search,
                    placeholder: store.t("Search skins, weapons, collections", "Поиск скинов, оружия, коллекций")
                )

                HStack(spacing: 6) {
                    StatusDot(color: store.accentColor, size: 4)
                    Text("\(appliedCount)/\(SkinCatalog.weapons.count)")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(DSColor.textSecondary)
                }
                .padding(.horizontal, 10)
                .frame(height: 40)
                .premiumRowBackground(cornerRadius: 11)
                .fixedSize()
            }

            rarityPicker
            weaponStrip
            gallery
            infoBanner
        }
        .animation(.easeInOut(duration: 0.22), value: store.settings.skinChanger)
        .animation(.easeInOut(duration: 0.2), value: selectedCategory)
        .animation(.easeInOut(duration: 0.2), value: selectedWeaponID)
        .animation(.easeInOut(duration: 0.2), value: rarityFilter)
        .onChange(of: selectedCategory) { _, newValue in
            guard SkinCatalog.weapon(withID: selectedWeaponID)?.category != newValue else { return }
            guard let first = SkinCatalog.weapons(in: newValue).first else { return }
            selectedWeaponID = first.id
            previewSkinID = SkinCatalog.skins(for: first).first?.id
        }
    }

    // MARK: - Preview

    private func preview(skin: SkinEntry) -> some View {
        ZStack {
            SkinArtworkView(skin: skin, weapon: selectedWeapon)
                .scaleEffect(isPulsing ? 1.045 : 1)
                .animation(.spring(response: 0.32, dampingFraction: 0.62), value: isPulsing)

            VStack {
                previewTopBar(skin: skin)

                Spacer()

                HStack(alignment: .bottom, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.t(skin.nameEN, skin.nameRU))
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color.white.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        HStack(spacing: 7) {
                            Text(store.t(selectedWeapon.descriptorEN, selectedWeapon.descriptorRU))
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .tracking(0.7)
                                .foregroundStyle(DSColor.textTertiary)

                            Circle()
                                .fill(Color.white.opacity(0.18))
                                .frame(width: 2.5, height: 2.5)

                            Text(store.t(skin.collectionEN, skin.collectionRU))
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .tracking(0.5)
                                .foregroundStyle(skin.rarity.color.opacity(0.85))
                                .lineLimit(1)
                        }
                    }

                    Spacer(minLength: 8)

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(selectedWeapon.name)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.66))
                        HStack(spacing: 4) {
                            ForEach(Array(skinPalette(skin).enumerated()), id: \.offset) { _, hex in
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 12, height: 12)
                                    .overlay {
                                        Circle().stroke(Color.white.opacity(0.18), lineWidth: 0.6)
                                    }
                            }
                        }
                    }
                }
            }
            .padding(14)
        }
        .frame(height: 326)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.16), Color.white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        }
        .shadow(color: .black.opacity(0.38), radius: 28, y: 16)
    }

    private func previewTopBar(skin: SkinEntry) -> some View {
        ViewThatFits(in: .horizontal) {
            previewTopBarContent(skin: skin, showsPattern: true, statusStyle: .detailed)
            previewTopBarContent(skin: skin, showsPattern: true, statusStyle: .compact)
            previewTopBarContent(skin: skin, showsPattern: true, statusStyle: .iconOnly)
            previewTopBarContent(skin: skin, showsPattern: false, statusStyle: .compact)
        }
    }

    private func previewTopBarContent(
        skin: SkinEntry,
        showsPattern: Bool,
        statusStyle: SkinPreviewStatusStyle
    ) -> some View {
        HStack(alignment: .top, spacing: 8) {
            HStack(spacing: 7) {
                PreviewTag(
                    text: store.t(selectedWeapon.name, selectedWeapon.name).uppercased(),
                    tint: skin.accent
                )
                PreviewTag(
                    text: store.t(skin.rarity.titleEN, skin.rarity.titleRU).uppercased(),
                    tint: skin.rarity.color
                )
                if showsPattern {
                    PreviewTag(
                        text: patternTitle(skin.pattern).uppercased(),
                        tint: .white.opacity(0.45)
                    )
                }
            }

            Spacer(minLength: 8)

            previewStatusTag(skin: skin, style: statusStyle)
        }
    }

    @ViewBuilder
    private func previewStatusTag(skin: SkinEntry, style: SkinPreviewStatusStyle) -> some View {
        let applied = store.settings.skinChanger.appliedSkins[selectedWeapon.id] == skin.id
        let icon = applied ? "checkmark.seal.fill" : "eye.fill"
        let tint = applied ? DSColor.success : Color.white.opacity(0.42)
        let accessibilityText = applied
            ? store.t("Applied locally", "Применено локально")
            : store.t("Cosmetic preview", "Косметическое превью")

        switch style {
        case .detailed:
            PreviewTag(
                text: applied
                    ? store.t("APPLIED LOCALLY", "ПРИМЕНЕНО ЛОКАЛЬНО")
                    : store.t("COSMETIC PREVIEW", "КОСМЕТИЧЕСКОЕ ПРЕВЬЮ"),
                icon: icon,
                tint: tint
            )
        case .compact:
            PreviewTag(
                text: applied ? store.t("LOCAL", "ЛОКАЛЬНО") : store.t("PREVIEW", "ПРЕВЬЮ"),
                icon: icon,
                tint: tint
            )
        case .iconOnly:
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 24)
                .background {
                    Capsule().fill(Color.black.opacity(0.34))
                }
                .overlay {
                    Capsule().stroke(Color.white.opacity(0.09), lineWidth: 0.6)
                }
                .accessibilityElement()
                .accessibilityLabel(Text(accessibilityText))
        }
    }

    private func actionBar(skin: SkinEntry) -> some View {
        ViewThatFits(in: .horizontal) {
            wideActionBar(skin: skin)
            compactActionBar(skin: skin)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .premiumRowBackground()
    }

    private func wideActionBar(skin: SkinEntry) -> some View {
        HStack(spacing: 8) {
            SettingGlyph(icon: "paintbrush.pointed.fill", tint: skin.rarity.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(store.t("Local loadout", "Локальная экипировка"))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DSColor.textPrimary)
                Text(store.t("Preview and apply are visual-only inside this app.", "Превью и применение работают только визуально внутри приложения."))
                    .font(.system(size: 9.5))
                    .foregroundStyle(DSColor.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 6)

            previewButton(expanded: false)
            applyButton(skin: skin, expanded: false)

            if isApplied {
                removeSkinButton
            }
        }
    }

    private func compactActionBar(skin: SkinEntry) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 9) {
                SettingGlyph(icon: "paintbrush.pointed.fill", tint: skin.rarity.color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(store.t("Local loadout", "Локальная экипировка"))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(DSColor.textPrimary)
                    Text(store.t("Preview and apply are visual-only inside this app.", "Превью и применение работают только визуально внутри приложения."))
                        .font(.system(size: 9.5))
                        .foregroundStyle(DSColor.textTertiary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 210, alignment: .leading)
                }

                Spacer(minLength: 6)
            }

            HStack(spacing: 8) {
                previewButton(expanded: true)
                applyButton(skin: skin, expanded: true)

                if isApplied {
                    removeSkinButton
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func previewButton(expanded: Bool) -> some View {
        Button {
            pulsePreview()
        } label: {
            actionButtonLabel(
                icon: "eye.fill",
                title: store.t("Preview", "Превью"),
                expanded: expanded
            )
        }
        .buttonStyle(PremiumButtonStyle(variant: .secondary))
    }

    private func applyButton(skin: SkinEntry, expanded: Bool) -> some View {
        Button {
            apply(skin: skin)
        } label: {
            actionButtonLabel(
                icon: isApplied ? "checkmark.seal.fill" : "checkmark",
                title: applyButtonTitle(expanded: expanded),
                expanded: expanded
            )
        }
        .buttonStyle(PremiumButtonStyle(variant: isApplied ? .secondary : .primary))
    }

    private func applyButtonTitle(expanded: Bool) -> String {
        guard isApplied else {
            return store.t("Apply", "Применить")
        }
        return expanded
            ? store.t("Reapply", "Применить снова")
            : store.t("Reapply", "Повторить")
    }

    private func actionButtonLabel(icon: String, title: String, expanded: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
            Text(title)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: expanded ? CGFloat.infinity : nil)
    }

    private var removeSkinButton: some View {
        Button {
            removeSkin()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 11, weight: .bold))
        }
        .buttonStyle(PremiumButtonStyle(variant: .ghost))
        .accessibilityLabel(store.t("Remove applied skin", "Убрать скин"))
    }

    // MARK: - Pickers

    private var categoryPicker: some View {
        SettingsPanel(title: store.t("Weapon category", "Категория оружия"), icon: "square.grid.2x2.fill") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(WeaponCategory.allCases) { category in
                        FilterChip(
                            title: store.t(category.titleEN, category.titleRU),
                            icon: category.icon,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.vertical, 1)
            }
            .padding(9)
            .premiumRowBackground()
        }
    }

    private var rarityPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                FilterChip(
                    title: store.t("All rarities", "Все редкости"),
                    icon: "circle.grid.3x3.fill",
                    isSelected: rarityFilter == nil
                ) {
                    rarityFilter = nil
                }

                ForEach(SkinRarity.allCases) { rarity in
                    FilterChip(
                        title: store.t(rarity.titleEN, rarity.titleRU),
                        tint: rarity.color,
                        isSelected: rarityFilter == rarity
                    ) {
                        rarityFilter = rarityFilter == rarity ? nil : rarity
                    }
                }
            }
            .padding(.vertical, 1)
        }
    }

    private var weaponStrip: some View {
        SettingsPanel(title: store.t("Arsenal", "Арсенал"), icon: "scope") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SkinCatalog.weapons(in: selectedCategory)) { weapon in
                        weaponCard(weapon)
                    }
                }
                .padding(.vertical, 1)
            }
            .padding(9)
            .premiumRowBackground()
        }
    }

    private func weaponCard(_ weapon: WeaponEntry) -> some View {
        let selected = selectedWeapon.id == weapon.id
        let appliedSkin = SkinCatalog.appliedSkin(for: weapon, settings: store.settings.skinChanger)

        return Button {
            store.hapticSelect()
            withAnimation(.easeOut(duration: 0.2)) {
                selectedWeaponID = weapon.id
                previewSkinID = appliedSkin?.id ?? SkinCatalog.skins(for: weapon).first?.id
            }
        } label: {
            HStack(spacing: 9) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(selected ? store.accentColor.opacity(0.16) : Color.white.opacity(0.035))
                    Image(systemName: weapon.icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(selected ? store.accentColor : DSColor.textTertiary)
                }
                .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(weapon.name)
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(selected ? DSColor.textPrimary : DSColor.textSecondary)
                        .lineLimit(1)

                    Text(
                        appliedSkin == nil
                            ? store.t(weapon.descriptorEN, weapon.descriptorRU)
                            : store.t(appliedSkin?.nameEN ?? "", appliedSkin?.nameRU ?? "")
                    )
                    .font(.system(size: 9))
                    .foregroundStyle(appliedSkin == nil ? DSColor.textTertiary : DSColor.success.opacity(0.85))
                    .lineLimit(1)
                }

                Spacer(minLength: 0)

                if appliedSkin != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(DSColor.success)
                }
            }
            .padding(9)
            .frame(width: 178, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(selected ? store.accentColor.opacity(0.08) : Color.white.opacity(0.028))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .stroke(
                        selected ? store.accentColor.opacity(0.4) : Color.white.opacity(0.05),
                        lineWidth: selected ? 1 : 0.6
                    )
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Gallery

    private var gallery: some View {
        SettingsPanel(
            title: isSearching
                ? store.t("Search results", "Результаты поиска")
                : store.t("Skin gallery", "Галерея скинов"),
            icon: "paintbrush.pointed.fill",
            subtitle: gallerySubtitle
        ) {
            if gallerySkins.isEmpty {
                EmptyState(
                    icon: "magnifyingglass",
                    title: store.t("Nothing found", "Ничего не найдено"),
                    message: store.t(
                        "Try a different name, category, or rarity filter.",
                        "Попробуйте другое название, категорию или фильтр редкости."
                    ),
                    actionTitle: store.t("Reset filters", "Сбросить фильтры"),
                    action: {
                        store.hapticTap()
                        search = ""
                        rarityFilter = nil
                        selectedCategory = .rifles
                        selectedWeaponID = "ak47"
                        previewSkinID = "ak47-galaxy-nomad"
                    }
                )
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 146), spacing: 9)],
                    spacing: 9
                ) {
                    ForEach(gallerySkins) { skin in
                        skinCard(skin)
                    }
                }
            }
        }
    }

    private var gallerySubtitle: String {
        if isSearching {
            return "\(gallerySkins.count) \(store.t("finishes across the arsenal", "отделок по всему арсеналу"))"
        }
        let weapon = selectedWeapon
        let applied = SkinCatalog.appliedSkin(for: weapon, settings: store.settings.skinChanger)
        let appliedText = applied.map { store.t(" · applied: \($0.nameEN)", " · применён: \($0.nameRU)") } ?? ""
        return "\(SkinCatalog.skins(for: weapon).count) \(store.t("local finishes", "локальных отделок"))\(appliedText)"
    }

    private func skinCard(_ skin: SkinEntry) -> some View {
        let weapon = SkinCatalog.weapon(withID: skin.weaponID) ?? selectedWeapon
        let isSelected = selectedSkin?.id == skin.id
        let applied = store.settings.skinChanger.appliedSkins[weapon.id] == skin.id

        return Button {
            store.hapticSelect()
            withAnimation(.easeOut(duration: 0.2)) {
                if selectedCategory != weapon.category {
                    selectedCategory = weapon.category
                }
                selectedWeaponID = weapon.id
                previewSkinID = skin.id
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    SkinArtworkView(skin: skin, weapon: weapon, compact: true)
                        .frame(height: 88)

                    if applied {
                        Image(systemName: "checkmark")
                            .font(.system(size: 7.5, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background { Circle().fill(DSColor.success) }
                            .padding(7)
                    } else if isSelected {
                        Circle()
                            .fill(skin.accent)
                            .frame(width: 6, height: 6)
                            .padding(9)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(store.t(skin.nameEN, skin.nameRU))
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundStyle(DSColor.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(skin.rarity.color)
                            .frame(width: 4, height: 4)
                        Text(store.t(skin.rarity.titleEN, skin.rarity.titleRU))
                            .font(.system(size: 8.5, weight: .medium))
                            .foregroundStyle(skin.rarity.color)
                            .lineLimit(1)

                        Spacer(minLength: 2)

                        Text(isSearching ? weapon.name : store.t(skin.collectionEN, skin.collectionRU))
                            .font(.system(size: 8))
                            .foregroundStyle(DSColor.textTertiary)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 8)
            }
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.03))
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isSelected ? skin.accent.opacity(0.65) : Color.white.opacity(0.055),
                        lineWidth: isSelected ? 1 : 0.6
                    )
            }
        }
        .buttonStyle(.plain)
    }

    private var infoBanner: some View {
        InfoBanner(
            icon: "lock.shield.fill",
            title: store.t("Local cosmetic library", "Локальная косметическая библиотека"),
            message: store.t(
                "Skin previews are original procedural artwork drawn by this app. Applying a finish only updates your local loadout record — no game inventory, files, or server data are accessed.",
                "Превью скинов — авторская процедурная графика, отрисованная этим приложением. Применение меняет только локальную запись экипировки: инвентарь игры, файлы и серверные данные не затрагиваются."
            ),
            tint: Color(hex: "#A78BFA")
        )
    }

    // MARK: - Actions

    private func pulsePreview() {
        store.hapticTap()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
            isPulsing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isPulsing = false
            }
        }
    }

    private func apply(skin: SkinEntry) {
        store.hapticSuccess()
        withAnimation(.easeInOut(duration: 0.22)) {
            store.settings.skinChanger.appliedSkins[selectedWeapon.id] = skin.id
        }
        store.showToast(
            store.t("Skin applied locally", "Скин применён локально"),
            icon: "checkmark.seal.fill"
        )
    }

    private func removeSkin() {
        store.hapticTap()
        withAnimation(.easeInOut(duration: 0.22)) {
            store.settings.skinChanger.appliedSkins.removeValue(forKey: selectedWeapon.id)
        }
        store.showToast(
            store.t("Local skin removed", "Локальный скин убран"),
            icon: "arrow.uturn.backward"
        )
    }

    // MARK: - Helpers

    private func skinPalette(_ skin: SkinEntry) -> [String] {
        [skin.primaryHex, skin.secondaryHex, skin.accentHex]
    }

    private func patternTitle(_ pattern: SkinPattern) -> String {
        switch pattern {
        case .carbon: return store.t("Carbon", "Карбон")
        case .fade: return store.t("Fade", "Градиент")
        case .stripes: return store.t("Stripes", "Полосы")
        case .geometric: return store.t("Geometric", "Геометрия")
        case .camo: return store.t("Camo", "Камуфляж")
        case .liquid: return store.t("Liquid", "Жидкость")
        case .marble: return store.t("Marble", "Мрамор")
        case .blossom: return store.t("Blossom", "Цветение")
        case .glow: return store.t("Glow", "Свечение")
        case .cosmic: return store.t("Cosmic", "Космос")
        }
    }
}

private enum SkinPreviewStatusStyle {
    case detailed
    case compact
    case iconOnly
}
