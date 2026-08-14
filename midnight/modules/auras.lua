local L = BBF.L

local AURA_START_X = 5
local AURA_START_Y = 9
local AURA_MIRRORED_START_Y = -6

local PLAYER_AURA_ICON = 30
local PLAYER_AURA_H_WIDTH, PLAYER_AURA_H_HEIGHT = 30, 40
local PLAYER_AURA_V_WIDTH, PLAYER_AURA_V_HEIGHT = 60, 30

local COLLAPSE_BUTTON_EXTENT = 15

local BASE_LARGE_SIZE = 21
local BASE_SMALL_SIZE = 17

local MAX_BUFFS_PER_GROUP = 32
local MAX_DEBUFFS_PER_GROUP = 16

local BORDER_ATLAS = "Adventures-Spell-Border"
local PIXEL_BORDER_ATLAS = "communities-create-avatar-border-hover"

local BORDER_INSET = 2
local PIXEL_BORDER_INSET = 0.5
local PLAYER_BUFF_BORDER_INSET = 2.5

local GLOW_OUTSET = 1.5

local DISPEL_BORDER_INSET_RATIO = (40 / 30 - 1) / 2
local DEFAULT_DISPEL_BORDER_ATLAS = "ui-debuff-border-default-noicon"

local LEGACY_BORDER_TEXTURE = [[Interface\Buttons\UI-Debuff-Overlays]]
local LEGACY_BORDER_LEFT, LEGACY_BORDER_RIGHT = 0.296875, 0.5703125
local LEGACY_BORDER_TOP, LEGACY_BORDER_BOTTOM = 0, 0.515625

local GLOW_ATLAS = "newplayertutorial-drag-slotgreen"
local PURGE_GLOW_ATLAS = "newplayertutorial-drag-slotblue"

local STEALABLE_TEXTURE = [[Interface\TargetingFrame\UI-TargetingFrame-Stealable]]
local STEALABLE_INSET_RATIO = (24 / 21 - 1) / 2

local SORT_METHODS = {
    default     = { AuraContainerSortMethod.Default,            AuraContainerSortDirection.Normal },
    expiration  = { AuraContainerSortMethod.Expiration,         AuraContainerSortDirection.Normal },
    firstending = { AuraContainerSortMethod.ExpirationOnly,     AuraContainerSortDirection.Normal },
    lastending  = { AuraContainerSortMethod.ExpirationOnly,     AuraContainerSortDirection.Reverse },
    name        = { AuraContainerSortMethod.NameOnly,           AuraContainerSortDirection.Normal },
    stable      = { AuraContainerSortMethod.AuraInstanceIDOnly, AuraContainerSortDirection.Normal },
}

local AURA_GROUPS = {
    { key = "Important",         tier = "important" },
    { key = "BigDef",            tier = "bigdef" },
    { key = "ExtDef",            tier = "extdef" },
    { key = "CC",                tier = "cc" },
    { key = "WhitelistPandemic", tier = "whitelistpandemic" },
    { key = "WhitelistMine",     tier = "whitelistmine" },
    { key = "Whitelist",         tier = "whitelist" },
    { key = "Mine",              tier = "mine" },
    { key = "Others",            tier = "others" },
}

local WHITELIST_TIERS = {
    whitelist = true, whitelistmine = true, whitelistpandemic = true,
}

local WHITELIST_MINE_TIERS = { whitelistmine = true, whitelistpandemic = true }

local HIGHLIGHT_TIERS = { important = true, bigdef = true, extdef = true, cc = true }

local HELPFUL_HIGHLIGHT_TIERS = { important = true, bigdef = true, extdef = true }
local HARMFUL_HIGHLIGHT_TIERS = { cc = true }

local function HighlightTierActive(tier, harmful, importantFirst)
    if not HIGHLIGHT_TIERS[tier] then return false end
    if not importantFirst then return false end
    if harmful then return HARMFUL_HIGHLIGHT_TIERS[tier] or false end
    return HELPFUL_HIGHLIGHT_TIERS[tier] or false
end

local PANDEMIC_TIERS = {
    mine = true, whitelistmine = true, whitelistpandemic = true,
}

local S = {}
BBF.auraSettings = S

local function SortFor(host)
    return host.isPlayer and S.playerSort or S.sort
end

local auraFilteringOn
local testMode = false
local editModeActive = false
local widthPreview = false

local function TestModeActive()
    return testMode or widthPreview
end

local function EditModeSettingChecked(settingName, checkButtonName)
    local manager = EditModeManagerFrame
    if not manager then return false end

    local setting = Enum.EditModeAccountSetting and Enum.EditModeAccountSetting[settingName]
    if setting and manager.HasAccountSettings and manager:HasAccountSettings() then
        return manager:GetAccountSettingValueBool(setting)
    end

    local settings = manager.AccountSettings
    local checkButton = settings and settings.settingsCheckButtons
        and settings.settingsCheckButtons[checkButtonName]
    if checkButton and checkButton.IsControlChecked then
        return checkButton:IsControlChecked() and true or false
    end

    return false
end

local function EditModePreviewsHost(host)
    if not editModeActive then return false end
    if host.isPlayer then
        return EditModeSettingChecked("ShowBuffsAndDebuffs", "BuffsAndDebuffs")
    end
    return EditModeSettingChecked("ShowTargetAndFocus", "TargetAndFocus")
end

local function PreviewIsActive(host)
    if TestModeActive() then return true end
    if not host then return editModeActive end
    return EditModePreviewsHost(host)
end

local targetCastBarXPos, targetCastBarYPos = 0, 0
local focusCastBarXPos, focusCastBarYPos = 0, 0
local targetStaticCastbar, targetDetachCastbar
local focusStaticCastbar, focusDetachCastbar
local targetToTCastbarAdjustment, focusToTCastbarAdjustment
local targetToTAdjustmentOffsetY, focusToTAdjustmentOffsetY
local buffsOnTopReverseCastbarMovement

local function GetColor(key, r, g, b, a)
    local c = BetterBlizzFramesDB[key]
    if type(c) == "table" and c[1] then
        return c[1], c[2] or 0, c[3] or 0, c[4] or 1
    end
    return r, g, b, a
end

function BBF.ApplyAuraTooltipSpellID(allowOff)
    local want = BetterBlizzFramesDB.auraTooltipSpellID and "1" or "0"
    if want == "0" and not allowOff then return end
    if C_CVar.GetCVar("tooltipShowAuraSpellIDs") ~= want then
        C_CVar.SetCVar("tooltipShowAuraSpellIDs", want)
    end
end

function BBF.UpdateUserAuraSettings()
    local db = BetterBlizzFramesDB

    auraFilteringOn = db.playerAuraFiltering
    BBF.ApplyAuraTooltipSpellID()

    S.scale = db.targetAndFocusAuraScale or 1
    S.sameSize = db.sameSizeAuras
    S.largeSize = BASE_LARGE_SIZE
    S.smallSize = S.sameSize and BASE_LARGE_SIZE or (BASE_SMALL_SIZE * (db.targetAndFocusSmallAuraScale or 1))
    S.highlightScale = db.auraHighlightScale or 1.3
    S.highlightSize = BASE_LARGE_SIZE * S.highlightScale

    S.cell = math.max(S.largeSize, S.smallSize)
    S.rowWidth = db.auraWidthSpace or 141
    S.separateRowWidth = db.auraWidthSpaceSeparate and true or false
    S.rowWidthFocus = db.auraWidthSpaceFocus or S.rowWidth
    S.hGap = db.targetAndFocusHorizontalGap or 4
    S.vGap = db.targetAndFocusVerticalGap or 4
    S.typeGap = db.auraTypeGap or 4
    S.offsetX = db.targetAndFocusAuraOffsetX or 0
    S.offsetY = db.targetAndFocusAuraOffsetY or 0
    S.importantFirst = db.importantAurasFirst ~= false

    S.importantColor = { GetColor("auraImportantGlowColor", 1, 0.5, 0, 1) }
    S.defensiveColor = { GetColor("auraDefensiveGlowColor", 1, 0.662, 0.945, 1) }
    S.ccColor = { GetColor("auraCCGlowColor", 1, 0.874, 0, 1) }

    S.stackScale = db.auraStackSize or 1
    S.showCdText = db.showAuraCdText
    S.playerDurations = CVarCallbackRegistry:GetCVarValueBool("buffDurations")
    S.playerDurationOnIcon = db.playerAuraDurationOnIcon and true or false
    S.cdTextScale = db.auraCdTextSize or 0.55
    S.cdTextOnlyMine = db.auraCdTextOnlyMine
    S.hideLongTimers = db.auraHideLongDurationText and true or false
    S.hideTooltips = db.hideUnitframeAuraTooltips
    S.increaseStrata = db.increaseAuraStrata
    S.removeDebuffBorder = db.removeDebuffColorBorder
    S.pixelBorder = ((db.noPortraitModes and db.noPortraitPixelBorder) or db.pixelBorderAuras) and true or false
    S.darkBorder = (db.darkModeUi and db.darkModeUiAura) and true or false
    S.legacyBorder = db.auraLegacyBorder and true or false
    if S.pixelBorder then
        S.darkColor = 0
    elseif S.darkBorder then
        S.darkColor = db.darkModeColor or 1
    else
        S.darkColor = 1
    end
    S.purgeGlowAlways = db.displayDispelGlowAlways
    S.purgeColor = { GetColor("purgeTextureColorRGB", 0, 0.92, 1, 0.85) }
    S.recolorPurge = db.changePurgeTextureColor
    S.pandemicColor = { GetColor("auraPandemicGlowColor", 1, 0, 0, 1) }
    S.timerColor = db.auraTimerColor
    S.timerBaseColor = { GetColor("auraTimerBaseColor", 1, 0.82, 0, 1) }
    S.timerLowColor = { GetColor("auraTimerLowColor", 1, 0.1, 0.1, 1) }
    S.expiryThreshold = db.auraTimerLowThreshold or 6
    S.playerCooldown = db.addCooldownFramePlayerAuras

    local sortKey = db.auraSortMethod or "blizzard"
    if sortKey == "blizzard" then sortKey = "default" end
    S.sort = SORT_METHODS[sortKey] or SORT_METHODS.default

    local playerSortKey = db.playerAuraSortMethod or "blizzard"
    if playerSortKey == "blizzard" then playerSortKey = "stable" end
    S.playerSort = SORT_METHODS[playerSortKey] or SORT_METHODS.stable

    S.target = {
        buffs = db.targetBuffEnable,
        debuffs = db.targetdeBuffEnable,
        buffOnlyMine = db.targetBuffFilterOnlyMe,
        debuffOnlyMine = db.targetdeBuffFilterOnlyMe,
        buffPurgeable = db.targetBuffFilterPurgeable,
        buffShort = db.targetBuffFilterLessMinite,
        debuffShort = db.targetdeBuffFilterLessMinite,
        buffWhitelist = db.targetBuffFilterWatchList,
        debuffWhitelist = db.targetdeBuffFilterWatchList,
        buffBlacklist = db.targetBuffFilterBlacklist,
        debuffBlacklist = db.targetdeBuffFilterBlacklist,

        extras = db.targetAuraGlows,
        importantGlow = db.targetImportantAuraGlow,
        defensiveGlow = db.targetAuraDefensiveGlow,
        ccGlow = db.targetAuraCCGlow,
        purgeGlow = db.targetBuffPurgeGlow,
        pandemicGlow = db.targetdeBuffPandemicGlow,
    }
    S.focus = {
        buffs = db.focusBuffEnable,
        debuffs = db.focusdeBuffEnable,
        buffOnlyMine = db.focusBuffFilterOnlyMe,
        debuffOnlyMine = db.focusdeBuffFilterOnlyMe,
        buffPurgeable = db.focusBuffFilterPurgeable,
        buffShort = db.focusBuffFilterLessMinite,
        debuffShort = db.focusdeBuffFilterLessMinite,
        buffWhitelist = db.focusBuffFilterWatchList,
        debuffWhitelist = db.focusdeBuffFilterWatchList,
        buffBlacklist = db.focusBuffFilterBlacklist,
        debuffBlacklist = db.focusdeBuffFilterBlacklist,

        extras = db.focusAuraGlows,
        importantGlow = db.focusImportantAuraGlow,
        defensiveGlow = db.focusAuraDefensiveGlow,
        ccGlow = db.focusAuraCCGlow,
        purgeGlow = db.focusBuffPurgeGlow,
        pandemicGlow = db.focusdeBuffPandemicGlow,
    }

    S.player = {
        buffs = db.PlayerAuraFrameBuffEnable,
        debuffs = db.PlayerAuraFramedeBuffEnable,
        buffWhitelist = db.PlayerAuraFrameBuffFilterWatchList,
        debuffWhitelist = db.PlayerAuraFramedeBuffFilterWatchList,
        buffBlacklist = db.playerBuffFilterBlacklist,
        debuffBlacklist = db.playerdeBuffFilterBlacklist,
        buffShort = db.PlayerAuraFrameBuffFilterLessMinite,
        debuffShort = db.PlayerAuraFramedeBuffFilterLessMinite,

        extras = db.playerAuraGlows,
        importantGlow = db.playerAuraImportantGlow,
        defensiveGlow = db.playerAuraDefensiveGlow,
        ccGlow = db.playerAuraCCGlow,
        purgeGlow = db.showPurgeTextureOnSelf,
    }

    S.buffsCollapsed = db.playerBuffsCollapsed

    S.playerSpacingX = (db.playerAuraSpacingX or 0) -5
    S.playerSpacingY = db.playerAuraSpacingY or 0
    S.showFilteredIcon = db.showHiddenAurasIcon
    S.filteredDirection = db.hiddenIconDirection or "BOTTOM"
    S.playerAurasOn = db.playerAuraFiltering and db.enablePlayerBuffFiltering
    S.clickthroughPlayerAuras = db.clickthroughPlayerAuras

    targetStaticCastbar = db.targetStaticCastbar
    targetDetachCastbar = db.targetDetachCastbar
    focusStaticCastbar = db.focusStaticCastbar
    focusDetachCastbar = db.focusDetachCastbar
    targetCastBarXPos = db.targetCastBarXPos or 0
    targetCastBarYPos = db.targetCastBarYPos or 0
    focusCastBarXPos = db.focusCastBarXPos or 0
    focusCastBarYPos = db.focusCastBarYPos or 0
    targetToTCastbarAdjustment = db.targetToTCastbarAdjustment
    focusToTCastbarAdjustment = db.focusToTCastbarAdjustment
    targetToTAdjustmentOffsetY = db.targetToTAdjustmentOffsetY or 0
    focusToTAdjustmentOffsetY = db.focusToTAdjustmentOffsetY or 0
    buffsOnTopReverseCastbarMovement = db.buffsOnTopReverseCastbarMovement
end

local neverSecretCache = {}

local function IsNeverSecret(spellID)
    local cached = neverSecretCache[spellID]
    if cached == nil then
        if C_Secrets and C_Secrets.GetSpellAuraSecrecy then
            cached = C_Secrets.GetSpellAuraSecrecy(spellID) == Enum.SecrecyLevel.NeverSecret
        else
            cached = false
        end
        neverSecretCache[spellID] = cached
    end
    return cached
end

function BBF.CanFilterBySpellID(unit, isHelpful)
    if not unit or not UnitExists(unit) then return false end
    local assist = UnitCanAssist("player", unit) and true or false
    if isHelpful then
        return assist
    end
    return not assist
end

function BBF.PartitionSpellList(list)
    local all, neverSecret = {}, {}
    local anyAll, anyNeverSecret = false, false

    if type(list) == "table" then
        for key, entry in pairs(list) do
            local spellID = tonumber(key)
            if spellID and entry then
                all[spellID] = true
                anyAll = true
                if IsNeverSecret(spellID) then
                    neverSecret[spellID] = true
                    anyNeverSecret = true
                end
            end
        end
    end

    return all, neverSecret, anyAll, anyNeverSecret
end

local listCache = {
    blacklist = { all = {}, ns = {}, mine = {}, mineNS = {} },
    whitelist = { all = {}, ns = {}, plain = {}, plainNS = {}, mine = {}, mineNS = {} },
}

local mergeCache = setmetatable({}, { __mode = "k" })

local function MergeSpellSets(a, b)
    if not a then return b end
    if not b then return a end

    local byB = mergeCache[a]
    if not byB then
        byB = setmetatable({}, { __mode = "k" })
        mergeCache[a] = byB
    end

    local merged = byB[b]
    if not merged then
        merged = {}
        for id in pairs(a) do merged[id] = true end
        for id in pairs(b) do merged[id] = true end
        byB[b] = merged
    end
    return merged
end

local function FlaggedSubset(list, flag)
    local flagged, any = {}, false
    for key, entry in pairs(list or {}) do
        local spellID = tonumber(key)
        if spellID and type(entry) == "table" and entry[flag] then
            flagged[spellID] = true
            any = true
        end
    end
    return flagged, any
end

local function SplitByFlag(set, flagged)
    local yes, no = {}, {}
    for id in pairs(set) do
        if flagged[id] then yes[id] = true else no[id] = true end
    end
    return yes, no
end

local function ListSignature(list, parts)
    if type(list) ~= "table" then return end
    for key, entry in pairs(list) do
        local flags = ""
        if type(entry) == "table" then
            flags = (entry.showMine and "m" or "") .. (entry.onlyMine and "o" or "")
                .. (entry.pandemic and "p" or "")
        elseif not entry then
            flags = "-"
        end
        parts[#parts + 1] = tostring(key) .. flags
    end
end

local function SpellListsSignature()
    local parts = {}
    for _, list in ipairs({
        BetterBlizzFramesDB.auraBlacklist, BetterBlizzFramesDB.auraWhitelist,
    }) do
        ListSignature(list, parts)
        parts[#parts + 1] = "\n"
    end
    return table.concat(parts, ",")
end

local function RefreshSpellLists()
    local signature = SpellListsSignature()
    if listCache.signature == signature then return end
    listCache.signature = signature

    wipe(mergeCache)

    local bl, blNS, blAny = BBF.PartitionSpellList(BetterBlizzFramesDB.auraBlacklist)
    local wl, wlNS, wlAny = BBF.PartitionSpellList(BetterBlizzFramesDB.auraWhitelist)

    local showMine, hasShowMine = FlaggedSubset(BetterBlizzFramesDB.auraBlacklist, "showMine")
    local blShowMine, blMine = SplitByFlag(bl, showMine)
    local blShowMineNS, blMineNS = SplitByFlag(blNS, showMine)

    local onlyMine, hasOnlyMine = FlaggedSubset(BetterBlizzFramesDB.auraWhitelist, "onlyMine")
    local wlMine, wlPlain = SplitByFlag(wl, onlyMine)
    local wlMineNS, wlPlainNS = SplitByFlag(wlNS, onlyMine)

    local pandemic, hasPandemic = FlaggedSubset(BetterBlizzFramesDB.auraWhitelist, "pandemic")
    local wlPandemic, wlMineRest = SplitByFlag(wl, pandemic)
    local wlPandemicNS, wlMineRestNS = SplitByFlag(wlNS, pandemic)

    listCache.blacklist = {
        all = bl, ns = blNS, any = blAny,
        mine = blMine, mineNS = blMineNS,
        showMine = blShowMine, showMineNS = blShowMineNS,
    }
    listCache.whitelist = {
        all = wl, ns = wlNS, any = wlAny,
        plain = wlPlain, plainNS = wlPlainNS,
        mine = wlMine, mineNS = wlMineNS,
        pandemic = wlPandemic, pandemicNS = wlPandemicNS,
        mineRest = wlMineRest, mineRestNS = wlMineRestNS,
        anyOnlyMine = hasOnlyMine,
        anyPandemic = hasPandemic,
    }
    listCache.hasShowMine = hasShowMine
end


local DURATION_MINUTES_FROM = 1 + (1.5 * 60)

local function GetPlayerDurationColor(remaining)
    return remaining >= DURATION_MINUTES_FROM and NORMAL_FONT_COLOR or HIGHLIGHT_FONT_COLOR
end

local playerDurationCurve

local function GetPlayerDurationCurve()
    if not playerDurationCurve then
        playerDurationCurve = C_CurveUtil.CreateColorCurve()
        playerDurationCurve:SetType(Enum.LuaCurveType.Step)
        playerDurationCurve:AddPoint(0, HIGHLIGHT_FONT_COLOR)
        playerDurationCurve:AddPoint(DURATION_MINUTES_FROM, NORMAL_FONT_COLOR)
    end
    return playerDurationCurve
end

local function ApplyGlowGeometry(texture, anchor, size)
    local inset = math.max(6, size * 0.45) + GLOW_OUTSET
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT", anchor, "TOPLEFT", -inset, inset)
    texture:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", inset, -inset)
end

local function GetPurgeMode(style)
    if style.purgeGlow then return "glow" end
    if style.isPlayer then return nil end
    return "default"
end

local function ApplyPurgeGeometry(texture, anchor, size, mode)
    if mode == "glow" then
        ApplyGlowGeometry(texture, anchor, size)
        return
    end
    local inset = size * STEALABLE_INSET_RATIO
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT", anchor, "TOPLEFT", -inset, inset)
    texture:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", inset, -inset)
end

local function ApplyPurgeArt(texture, mode, recolor)
    texture:SetBlendMode(mode == "default" and "ADD" or "BLEND")
    texture:SetDesaturated(mode == "glow" and recolor and true or false)
end

local function ApplyBorderArt(texture, pixelBorder)
    if pixelBorder then
        texture:SetAtlas(PIXEL_BORDER_ATLAS)
        texture:SetDesaturated(true)
    else
        texture:SetAtlas(BORDER_ATLAS)
        texture:SetDesaturated(false)
    end
end

local function ApplyBorderGeometry(texture, anchor, pixelBorder, borderInset)
    local inset = pixelBorder and PIXEL_BORDER_INSET or (borderInset or BORDER_INSET)
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT", anchor, "TOPLEFT", -inset, inset)
    texture:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", inset, -inset)
end

local function DispelBorderUsesOwnArt(style)
    return (style.pixelBorder or style.legacyBorder) and true or false
end

local function GetDispelBorderStyle(style)
    local styles = Enum.CustomAuraButtonDispelTypeTextureStyle
    if DispelBorderUsesOwnArt(style) then
        return styles.PreserveAsset
    end
    return style.showDispelType and styles.BorderWithIcon or styles.Border
end

local function ApplyDispelBorderArt(texture, style)
    if style.pixelBorder then
        ApplyBorderArt(texture, true)
    elseif style.legacyBorder then
        texture:SetDesaturated(false)
        texture:SetTexture(LEGACY_BORDER_TEXTURE)
        texture:SetTexCoord(LEGACY_BORDER_LEFT, LEGACY_BORDER_RIGHT, LEGACY_BORDER_TOP, LEGACY_BORDER_BOTTOM)
    else
        texture:SetDesaturated(false)
        texture:SetAtlas(DEFAULT_DISPEL_BORDER_ATLAS, TextureKitConstants.IgnoreAtlasSize)
    end
end

local function ApplyDispelBorderGeometry(texture, anchor, style)
    if style.pixelBorder then
        ApplyBorderGeometry(texture, anchor, true)
        return
    end

    local inset = (style.legacyBorder and 1
        or (style.iconSize or style.size or PLAYER_AURA_ICON) * DISPEL_BORDER_INSET_RATIO)
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT", anchor, "TOPLEFT", -inset, inset)
    texture:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", inset, -inset)
end

local DISPEL_TYPE_KEYS = { "None", "Magic", "Curse", "Disease", "Poison", "Bleed" }

local function UniformDispelMap(value)
    local map = {}
    for _, key in ipairs(DISPEL_TYPE_KEYS) do map[key] = value end
    return map
end

local function ApplyDispelRegistrations(button, style)
    local borderStyle = (button.bbfDispel and not style.removeDebuffBorder and not style.glow)
        and GetDispelBorderStyle(style) or nil
    local ownBorderOn = (button.bbfBorder and style.drawBorder) and true or false
    -- With the dispel colors removed debuffs reuse the same border the buffs draw.
    local ownBorderHarmful = (ownBorderOn and style.removeDebuffBorder) and true or false
    local purgeMode = button.bbfPurgeGlow and GetPurgeMode(style) or nil

    local pc = style.recolorPurge and style.purgeColor or nil
    local signature = string.format("%s|%s|%s|%s|%s|%s|%s",
        tostring(borderStyle), tostring(ownBorderOn), tostring(purgeMode),
        tostring(style.purgeGlowAlways),
        pc and string.format("%.3f,%.3f,%.3f,%.3f", pc[1], pc[2], pc[3], pc[4] or 1) or "false",
        tostring(style.darkColor), tostring(ownBorderHarmful))
    if button.bbfDispelSignature == signature then return end
    button.bbfDispelSignature = signature

    button:ClearDispelTypeTextures()

    if button.bbfBorder then
        if ownBorderOn then
            local c = style.darkColor or 1
            button:AddDispelTypeTexture(button.bbfBorder, {
                style = Enum.CustomAuraButtonDispelTypeTextureStyle.CustomAsset,
                showWhenHarmful = ownBorderHarmful,
                showWhenHelpful = true,
                showWithoutDispelType = true,
                customDispelAssetMap = UniformDispelMap({
                    asset = style.pixelBorder and PIXEL_BORDER_ATLAS or BORDER_ATLAS,
                }),
                customDispelColorMap = UniformDispelMap(CreateColor(c, c, c, 1)),
            })
        else
            button.bbfBorder:Hide()
        end
    end

    if button.bbfDispel then
        if borderStyle then
            button:AddDispelTypeTexture(button.bbfDispel, {
                style = borderStyle,
                showWhenHarmful = true,
                showWhenHelpful = false,
                showWithoutDispelType = true,
            })
        else
            button.bbfDispel:Hide()
        end
    end

    if button.bbfPurgeGlow then
        if purgeMode then
            ApplyPurgeArt(button.bbfPurgeGlow, purgeMode, style.recolorPurge)

            local asset = { asset = purgeMode == "glow" and PURGE_GLOW_ATLAS or STEALABLE_TEXTURE }

            local stealableFilter
            if not style.purgeGlowAlways then
                stealableFilter = Enum.CustomAuraButtonDispelTypeStealableFilter.Stealable
            end

            local colorMap
            -- The dispel color map only carries RGB, so the picked alpha goes on the texture.
            local purgeAlpha = 1
            if style.recolorPurge then
                local c = style.purgeColor
                purgeAlpha = c[4] or 1
                colorMap = UniformDispelMap(CreateColor(c[1], c[2], c[3], purgeAlpha))
            end
            button.bbfPurgeGlow:SetAlpha(purgeAlpha)

            button:AddDispelTypeTexture(button.bbfPurgeGlow, {
                style = Enum.CustomAuraButtonDispelTypeTextureStyle.CustomAsset,
                showWhenHarmful = false,
                showWhenHelpful = true,
                showWithoutDispelType = false,
                stealableFilter = stealableFilter,
                customDispelAssetMap = UniformDispelMap(asset),
                customDispelColorMap = colorMap,
            })
        else
            button.bbfPurgeGlow:Hide()
        end
    end
end

local function ApplyPandemicRegistration(button, style)
    local pandemic = button.bbfPandemicGlow
    if not pandemic then return end

    if style.pandemicGlow then
        local c = style.pandemicColor
        if c then
            pandemic:SetVertexColor(c[1], c[2], c[3], c[4] or 1)
        end
        pandemic:SetAlpha(1)
        if not button.bbfPandemicRegistered then
            button.bbfPandemicRegistered = true
            button:AddPandemicRegion(pandemic)
        end
    elseif button.bbfPandemicRegistered then
        pandemic:SetAlpha(0)
    end
end

local function ApplyDurationFont(timer, style)
    local base = timer.bbfBaseFont
    if not base then return end
    timer:SetFont(base[1], base[2], style.durationOutline and "OUTLINE" or base[3])
end

local ApplyCountdownFormatter
do
    local HIDE_LONG_TIMER_FROM = 60
    local longTimerFormatter

    local function GetLongTimerFormatter()
        if not longTimerFormatter then
            longTimerFormatter = C_StringUtil.CreateNumericRuleFormatter()
            longTimerFormatter:SetBreakpoints({
                {
                    threshold = 0,
                    format = "%d",
                    step = 1,
                    rounding = Enum.NumericRuleFormatRounding.Up,
                },
                { threshold = HIDE_LONG_TIMER_FROM, format = " " },
            })
        end
        return longTimerFormatter
    end

    function ApplyCountdownFormatter(cooldown, style)
        if not cooldown or not cooldown.SetCountdownFormatter then return end

        local hide = style.hideLongTimers and true or false
        if cooldown.bbfHideLongTimers == hide then return end
        cooldown.bbfHideLongTimers = hide

        cooldown:SetCountdownFormatter(hide and GetLongTimerFormatter() or nil)
    end
end

local function ApplyMutableStyle(button, style)
    local size = style.size
    local iconAnchor = button.bbfIcon or button

    if style.isPlayer then
        button:SetSize(style.buttonWidth, style.buttonHeight)
        if button.bbfIcon then
            button.bbfIcon:ClearAllPoints()
            button.bbfIcon:SetSize(PLAYER_AURA_ICON, PLAYER_AURA_ICON)
            button.bbfIcon:SetPoint(style.iconPoint, button, style.iconPoint)
        end
        if button.bbfTimer then
            button.bbfTimer:ClearAllPoints()
            button.bbfTimer:SetPoint(style.durationPoint, iconAnchor, style.durationRelativePoint,
                0, style.durationYOffset or 0)
            button.bbfTimer:SetShown(style.showTimerText)
            ApplyDurationFont(button.bbfTimer, style)
        end
        if button.bbfCount then
            button.bbfCount:ClearAllPoints()
            button.bbfCount:SetPoint("BOTTOMRIGHT", iconAnchor, "BOTTOMRIGHT", -2, 2)
        end
    else
        button:SetSize(size, size)
    end

    if not style.isPlayer then
        ApplyCountdownFormatter(button.bbfCooldown, style)

        if button.bbfTimer then
            button.bbfTimer:SetScale(style.cdTextScale or 0.55)
            if style.timerColor then
                local c = style.timerBaseColor
                button.bbfTimer:SetTextColor(c[1], c[2], c[3], c[4] or 1)
            end
        end
    end

    if button.bbfCount then
        button.bbfCount:SetScale(style.stackScale or 1)
    end

    if button.bbfGlow then
        ApplyGlowGeometry(button.bbfGlow, iconAnchor, size)
        local color = style.glowColor
        if color then
            button.bbfGlow:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
        end
        button.bbfGlow:SetShown(style.glow and true or false)
    end

    if button.bbfPurgeGlow then
        ApplyPurgeGeometry(button.bbfPurgeGlow, iconAnchor, size, GetPurgeMode(style))
    end

    if button.bbfPandemicGlow then
        ApplyGlowGeometry(button.bbfPandemicGlow, iconAnchor, size)
        ApplyPandemicRegistration(button, style)
    end

    if button.bbfBorder then
        ApplyBorderGeometry(button.bbfBorder, iconAnchor, style.pixelBorder, style.borderInset)
    end
    if button.bbfDispel then
        ApplyDispelBorderGeometry(button.bbfDispel, iconAnchor, style)
    end
    ApplyDispelRegistrations(button, style)

    if button.bbfIcon then
        if style.cropIcon then
            button.bbfIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        else
            button.bbfIcon:SetTexCoord(0, 1, 0, 1)
        end
    end

    if style.clickthrough then
        button:SetCancelAuraButtons(nil)
    else
        button:SetCancelAuraButtons("RightButtonUp")
    end

    button:SetHideTooltipInCombat(style.hideTooltips and true or false)

    if not InCombatLockdown() then
        button:SetMouseMotionEnabled(not style.hideTooltips)
    end
end

local function InitAuraButton(button, style)
    local icon = button:CreateTexture(nil, "BACKGROUND")
    if style.isPlayer then
        icon:SetSize(PLAYER_AURA_ICON, PLAYER_AURA_ICON)
    else
        icon:SetAllPoints(button)
    end
    button.bbfIcon = icon
    button:SetIcon(icon)

    if not style.isPlayer or style.playerCooldown then
        local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
        cooldown:SetAllPoints(icon)
        cooldown:SetReverse(true)
        cooldown:SetDrawEdge(true)
        cooldown:SetDrawBling(false)
        cooldown:SetUsingParentLevel(true)
        cooldown:SetHideCountdownNumbers(style.isPlayer or not style.showTimerText)
        button.bbfCooldown = cooldown
        button:SetDurationCooldown(cooldown)
    end

    local overlay = CreateFrame("Frame", nil, button)
    overlay:SetAllPoints(button)
    overlay:SetFrameLevel((button.bbfCooldown and button.bbfCooldown:GetFrameLevel() or button:GetFrameLevel()) + 1)
    button.bbfOverlay = overlay

    local count = overlay:CreateFontString(nil, "OVERLAY",
        style.isPlayer and "NumberFontNormal" or "NumberFontNormalSmall")
    count:SetJustifyH("RIGHT")
    if not style.isPlayer then
        count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, 0)
    end
    button.bbfCount = count
    button:SetApplicationCount(count)

    local ownBorder = overlay:CreateTexture(nil, "OVERLAY", nil, 5)
    ApplyBorderArt(ownBorder, style.pixelBorder)
    ownBorder:Hide()
    button.bbfBorder = ownBorder

    if not style.removeDebuffBorder then
        local dispel = overlay:CreateTexture(nil, "OVERLAY", nil, 6)
        ApplyDispelBorderArt(dispel, style)
        ApplyDispelBorderGeometry(dispel, icon, style)
        dispel:Hide()
        button.bbfDispel = dispel
    end

    local purge = overlay:CreateTexture(nil, "OVERLAY", nil, 6)
    purge:Hide()
    button.bbfPurgeGlow = purge

    if PANDEMIC_TIERS[style.tier] and not HIGHLIGHT_TIERS[style.tier] and not style.isPlayer then
        local pandemic = overlay:CreateTexture(nil, "OVERLAY", nil, 7)
        pandemic:SetAtlas(GLOW_ATLAS)
        pandemic:SetDesaturated(true)
        pandemic:Hide()
        button.bbfPandemicGlow = pandemic
    end

    if style.isPlayer then
        local symbol = overlay:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
        symbol:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
        button.bbfSymbol = symbol
        button:SetDispelTypeText(symbol, {
            showWhenHarmful = true,
            showWhenHelpful = false,
            showWithoutDispelType = false,
        })
    end

    if HIGHLIGHT_TIERS[style.tier] then
        local glow = overlay:CreateTexture(nil, "OVERLAY", nil, 7)
        glow:SetAtlas(GLOW_ATLAS)
        glow:SetDesaturated(true)
        button.bbfGlow = glow
    end

    if style.isPlayer then
        local timer = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        button.bbfTimer = timer
        timer.bbfBaseFont = { timer:GetFont() }
        button:SetDurationText(timer, {
            textColor = {
                curve = GetPlayerDurationCurve(),
                property = Enum.DurationTextBindingProperty.RemainingDuration,
            },
        })
    elseif style.showTimerText then
        button.bbfTimer = button.bbfCooldown and button.bbfCooldown:GetCountdownFontString()
    end

    button:SetTooltipAnchorPoint("ANCHOR_BOTTOMLEFT", 0, 0)

    ApplyMutableStyle(button, style)
end

local F = AuraUtil.AuraFilters

local function BuildFilterString(harmful, tier, cfg)
    local parts = {}

    if harmful then
        parts[#parts + 1] = F.Harmful
        parts[#parts + 1] = F.IncludeNameplateOnly
    else
        parts[#parts + 1] = F.Helpful
    end

    local leadingOn = cfg.importantFirst
    local helpfulLead = leadingOn and not harmful
    local harmfulLead = leadingOn and harmful

    local function AddNormalNegations()
        if helpfulLead then
            parts[#parts + 1] = "!" .. F.Important
            parts[#parts + 1] = "!" .. F.BigDefensive
            parts[#parts + 1] = "!" .. F.ExternalDefensive
        elseif harmfulLead then
            parts[#parts + 1] = "!" .. F.CrowdControl
        end
    end

    if tier == "important" then
        parts[#parts + 1] = F.Important
        parts[#parts + 1] = "!" .. F.BigDefensive
        parts[#parts + 1] = "!" .. F.ExternalDefensive
    elseif tier == "bigdef" then
        parts[#parts + 1] = F.BigDefensive
    elseif tier == "extdef" then
        parts[#parts + 1] = "!" .. F.BigDefensive
        parts[#parts + 1] = F.ExternalDefensive
    elseif tier == "cc" then
        parts[#parts + 1] = F.CrowdControl
    else
        AddNormalNegations()
    end

    if tier == "whitelist" then
        parts[#parts + 1] = "!" .. F.Player
    elseif WHITELIST_MINE_TIERS[tier] then
        parts[#parts + 1] = F.Player
    elseif tier == "mine" then
        parts[#parts + 1] = F.Player
    elseif tier == "others" then
        if cfg.mergeNormal then
            if cfg.onlyMine then
                parts[#parts + 1] = F.Player
            end
        else
            parts[#parts + 1] = "!" .. F.Player
        end
    elseif cfg.onlyMine and tier ~= "cc" then
        parts[#parts + 1] = F.Player
    end

    if cfg.purgeable and not harmful then
        parts[#parts + 1] = F.RaidPlayerDispellable
    end

    return AuraUtil.CreateFilterString(unpack(parts))
end

local function BuildCandidateFilters(harmful, tier, cfg, canFilterIDs)
    local filters = {}
    local blockAll = false

    local blacklist = listCache.blacklist
    local whitelist = listCache.whitelist

    if cfg.blacklist and blacklist.any then
        local set
        if tier == "mine" then
            set = canFilterIDs and blacklist.mine or blacklist.mineNS
        else
            set = canFilterIDs and blacklist.all or blacklist.ns
        end
        if next(set) then
            filters.excludeSpellIDs = set
        end
    end

    local whitelistLive = (cfg.whitelist or cfg.collapsed) and true or false

    if whitelistLive and WHITELIST_TIERS[tier] then
        local set
        if whitelist.any then
            if tier == "whitelistpandemic" then
                set = canFilterIDs and whitelist.pandemic or whitelist.pandemicNS
            elseif tier == "whitelistmine" then
                if cfg.splitPandemic then
                    set = canFilterIDs and whitelist.mineRest or whitelist.mineRestNS
                else
                    set = canFilterIDs and whitelist.all or whitelist.ns
                end
            else
                set = canFilterIDs and whitelist.plain or whitelist.plainNS
            end
        end
        if set and next(set) then
            filters.includeSpellIDs = set
        else
            blockAll = true
        end
    elseif whitelistLive and whitelist.any
        and (cfg.otherFiltersOn or (cfg.collapsed and not HIGHLIGHT_TIERS[tier])) then
        local set = canFilterIDs and whitelist.all or whitelist.ns
        if next(set) then
            filters.excludeSpellIDs = MergeSpellSets(filters.excludeSpellIDs, set)
        end
    end

    if tier == "others" then
        local set = canFilterIDs and whitelist.mine or whitelist.mineNS
        if next(set) then
            filters.excludeSpellIDs = MergeSpellSets(filters.excludeSpellIDs, set)
        end
    end

    if cfg.short then
        filters.maxDuration = 60
    end

    return filters, blockAll
end


local function GetHostSizes(host)
    if host.isPlayer then
        local base = PLAYER_AURA_ICON
        local horizontal = host.isHorizontal ~= false
        local width, height = PLAYER_AURA_H_WIDTH, PLAYER_AURA_H_HEIGHT
        if not horizontal then
            width, height = PLAYER_AURA_V_WIDTH, PLAYER_AURA_V_HEIGHT
        end
        if S.playerDurationOnIcon then
            width, height = base, base
        end
        return {
            large = base, small = base, highlight = base,
            cell = width, cellHeight = height,
            isPlayer = true, isHorizontal = horizontal,
        }
    end
    return { large = S.largeSize, small = S.smallSize, highlight = S.highlightSize, cell = S.cell }
end

local function GetTierSize(tier, sizes)
    if HIGHLIGHT_TIERS[tier] then return sizes.highlight end
    if tier == "mine" then return sizes.large end
    return sizes.small
end

local function GetTierCell(tier, sizes)
    if sizes.isPlayer then
        return sizes.cell, sizes.cellHeight
    end
    local size = GetTierSize(tier, sizes)
    return size, size
end

local function RowWidth(host)
    local width = S.rowWidth
    if S.separateRowWidth and (host.settingsKey or host.key) == "focus" then
        width = S.rowWidthFocus or width
    end
    return width
end

local function GetMaxLineSize(host, sizes, primarySpacing)
    if host.isPlayer then
        local perRow = math.max(host.perRow or 1, 1)
        return perRow * PLAYER_AURA_ICON + (perRow - 1) * primarySpacing
    end
    return RowWidth(host)
end

local function GetTierGlow(tier, cfg)
    if tier == "important" then return cfg.importantGlow, S.importantColor end
    if tier == "bigdef" or tier == "extdef" then return cfg.defensiveGlow, S.defensiveColor end
    if tier == "cc" then return cfg.ccGlow, S.ccColor end
    return false, nil
end

local function GetPlayerButtonAnchors(sizes, cfg)
    local iconPoint
    if sizes.isHorizontal then
        iconPoint = cfg.addIconsToTop and "BOTTOM" or "TOP"
    else
        iconPoint = cfg.addIconsToRight and "LEFT" or "RIGHT"
    end

    if S.playerDurationOnIcon then
        return iconPoint, "BOTTOM", "BOTTOM", false
    end

    if sizes.isHorizontal then
        local under = not cfg.addIconsToTop
        return iconPoint, iconPoint, under and "BOTTOM" or "TOP", under
    end
    return iconPoint, iconPoint, cfg.addIconsToRight and "RIGHT" or "LEFT", false
end

local function GetDurationYOffset(isPlayer, cfg, durationUnderIcon)
    if not isPlayer then return 0 end

    local offset = 0
    if S.pixelBorder then
        offset = durationUnderIcon and -1 or 0
    elseif (not cfg.harmful or S.removeDebuffBorder) and S.darkBorder then
        offset = -1
    end

    if cfg.harmful then
        offset = offset - 1
    end

    return offset
end

local function BuildStyle(tier, sizes, isPlayer, cfg, into)
    local glow, glowColor = GetTierGlow(tier, cfg)
    local size = GetTierSize(tier, sizes)

    local pandemicGlow
    if isPlayer or HIGHLIGHT_TIERS[tier] then
        pandemicGlow = false
    elseif tier == "whitelistpandemic" then
        pandemicGlow = true
    else
        pandemicGlow = (PANDEMIC_TIERS[tier] and cfg.pandemicGlow) and true or false
    end

    local iconPoint, durationPoint, durationRelativePoint, durationUnderIcon
    local buttonWidth, buttonHeight
    local showTimerText, legacyBorder, clickthrough
    if isPlayer then
        iconPoint, durationPoint, durationRelativePoint, durationUnderIcon = GetPlayerButtonAnchors(sizes, cfg)
        buttonWidth, buttonHeight = sizes.cell, sizes.cellHeight
        showTimerText = S.playerDurations and true or false
        legacyBorder = S.legacyBorder
        clickthrough = S.clickthroughPlayerAuras and true or false
    else
        showTimerText = (S.showCdText
            and (not S.cdTextOnlyMine or tier == "mine" or WHITELIST_MINE_TIERS[tier]
                or HIGHLIGHT_TIERS[tier])) and true or false
        legacyBorder = true
        clickthrough = true
    end

    local t = into or {}
    t.tier = tier
    t.size = size
    t.iconSize = isPlayer and PLAYER_AURA_ICON or size
    t.buttonWidth = buttonWidth
    t.buttonHeight = buttonHeight
    t.iconPoint = iconPoint
    t.durationPoint = durationPoint
    t.durationRelativePoint = durationRelativePoint
    t.durationOutline = (isPlayer and S.playerDurationOnIcon) and true or false
    t.durationYOffset = GetDurationYOffset(isPlayer, cfg, durationUnderIcon)
    t.stackScale = S.stackScale
    t.showTimerText = showTimerText
    t.hideLongTimers = (not isPlayer and S.hideLongTimers) and true or false
    t.isPlayer = isPlayer
    t.playerCooldown = S.playerCooldown
    t.cdTextScale = S.cdTextScale
    t.hideTooltips = S.hideTooltips
    t.clickthrough = clickthrough
    t.removeDebuffBorder = S.removeDebuffBorder
    t.pixelBorder = S.pixelBorder
    t.borderInset = (isPlayer and (not cfg.harmful or t.removeDebuffBorder))
        and PLAYER_BUFF_BORDER_INSET or BORDER_INSET
    t.legacyBorder = legacyBorder
    t.showDispelType = cfg.showDispelType
    t.drawBorder = (S.pixelBorder or S.darkBorder) and true or false
    t.cropIcon = (S.pixelBorder or S.darkBorder) and true or false
    t.darkColor = S.darkColor
    t.purgeGlow = cfg.purgeGlow
    t.purgeGlowAlways = S.purgeGlowAlways
    t.purgeColor = S.purgeColor
    t.recolorPurge = S.recolorPurge
    t.pandemicGlow = pandemicGlow
    t.pandemicColor = S.pandemicColor
    t.timerColor = S.timerColor
    t.timerBaseColor = S.timerBaseColor
    t.glow = glow
    t.glowColor = glowColor
    return t
end

local styleScratch = {}

local function GetFrameConfig(host, harmful)
    local f = S[host.settingsKey or host.key]
    local cfg

    if harmful then
        cfg = {
            enabled = f.debuffs,
            onlyMine = f.debuffOnlyMine,
            short = f.debuffShort,
            whitelist = f.debuffWhitelist,
            blacklist = f.debuffBlacklist,
            maxCount = MAX_DEBUFFS_PER_GROUP,
        }
    else
        cfg = {
            enabled = f.buffs,
            onlyMine = f.buffOnlyMine,
            purgeable = f.buffPurgeable,
            short = f.buffShort,
            whitelist = f.buffWhitelist,
            blacklist = f.buffBlacklist,
            maxCount = MAX_BUFFS_PER_GROUP,
        }
    end

    cfg.harmful = harmful and true or false

    cfg.addIconsToRight = host.addIconsToRight
    cfg.addIconsToTop = host.addIconsToTop
    cfg.showDispelType = host.showDispelType and true or false

    local extras = f.extras and true or false
    cfg.importantFirst = S.importantFirst
    cfg.importantGlow = (extras and S.importantFirst and f.importantGlow) and true or false
    cfg.defensiveGlow = (extras and S.importantFirst and f.defensiveGlow) and true or false
    cfg.ccGlow = (extras and S.importantFirst and f.ccGlow) and true or false
    cfg.purgeGlow = extras and f.purgeGlow
    cfg.collapsed = (not harmful) and host.key == "playerBuffs" and S.buffsCollapsed
        and true or false
    if cfg.collapsed then
        cfg.importantFirst = true
    end
    cfg.pandemicGlow = (extras and not host.isPlayer and f.pandemicGlow) and true or false
    cfg.splitPandemic = (not cfg.pandemicGlow) and (not host.isPlayer)
        and listCache.whitelist.anyPandemic and true or false

    return cfg
end

BBF.auraHosts = {}

local function AddContainerGroups(host, container)
    local sizes = GetHostSizes(host)
    local cfg = GetFrameConfig(host, container.bbfHarmful)
    local sort = SortFor(host)

    for _, def in ipairs(AURA_GROUPS) do
        local style = BuildStyle(def.tier, sizes, host.isPlayer, cfg)
        container.bbfStyles[def.key] = style

        container:AddAuraGroup(def.key, BuildFilterString(container.bbfHarmful, def.tier, cfg), {
            maxFrameCount = 0,
            sortMethod = sort[1],
            sortDirection = sort[2],
            layout = { elementSpacing = S.hGap, lineSpacing = S.vGap },
            initializeFrame = function(button)
                InitAuraButton(button, container.bbfStyles[def.key])
            end,
        })
    end
end

local function CreateTypeContainer(host, harmful, parent)
    local container = CreateFrame("AuraContainer", nil, parent, "CustomAuraContainerTemplate")
    container:SetSize(1, 1)
    container:SetUnit(host.unit)

    container:SetFlowLayoutAxis(AnchorUtil.FlowLayoutAxis.Horizontal)
    container:SetFlowLayoutAnchorPoint("TOPLEFT")
    container:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Right, AnchorUtil.FlowDirection.Down)
    container:SetFlowLayoutPadding(0, 0, 0, 0)

    container.bbfHarmful = harmful
    container.bbfStyles = {}
    container.bbfBaseStrata = container:GetFrameStrata()

    return container
end

local function NeedsMineSplit(cfg)
    if not S.sameSize then return true end
    if S.showCdText and S.cdTextOnlyMine then return true end
    if cfg.blacklist and listCache.hasShowMine then return true end
    if listCache.whitelist.anyOnlyMine then return true end
    if cfg.pandemicGlow then return true end
    return false
end

local function GetAppliedRecord(container, key)
    local applied = container.bbfApplied
    if not applied then
        applied = {}
        container.bbfApplied = applied
    end

    local record = applied[key]
    if not record then
        record = {}
        applied[key] = record
    end
    return record
end

local function CandidateFilterSignature(filters)
    return string.format("%s/%s/%s",
        tostring(filters.includeSpellIDs), tostring(filters.excludeSpellIDs),
        tostring(filters.maxDuration))
end

local function ApplyGroupCandidateFilters(container, key, filters)
    local record = GetAppliedRecord(container, key)
    local signature = CandidateFilterSignature(filters)
    if record.filters == signature then return end
    record.filters = signature
    container:SetAuraGroupCandidateFilters(key, filters)
end

local function ApplyGroupSortMethod(container, key, method, direction)
    local record = GetAppliedRecord(container, key)
    local signature = method * 16 + direction
    if record.sort == signature then return end
    record.sort = signature
    container:SetAuraGroupSortMethod(key, method, direction)
end

local layoutScratch = {}

local function ApplyGroupLayout(container, key,
        elementSpacing, lineSpacing, elementWidth, elementHeight, layoutIndex, groupLineSpacing)
    local record = GetAppliedRecord(container, key)
    local signature = string.format("%s/%s/%s/%s/%s/%s",
        tostring(elementSpacing), tostring(lineSpacing),
        tostring(elementWidth), tostring(elementHeight),
        tostring(layoutIndex), tostring(groupLineSpacing))
    if record.layout == signature then return end
    record.layout = signature

    layoutScratch.elementSpacing = elementSpacing
    layoutScratch.lineSpacing = lineSpacing
    layoutScratch.elementWidth = elementWidth
    layoutScratch.elementHeight = elementHeight
    layoutScratch.layoutIndex = layoutIndex
    layoutScratch.groupLineSpacing = groupLineSpacing
    container:SetAuraGroupLayout(key, layoutScratch)
end

local SPACER_KEY = "Spacer"

local function SpacerExtent()
    return S.typeGap + 2
end

local function SpacerFilterString(harmful)
    if harmful then
        return AuraUtil.CreateFilterString(F.Harmful, F.IncludeNameplateOnly)
    end
    return AuraUtil.CreateFilterString(F.Helpful)
end

local function DisableSpacerMouse(container)
    local button = container and container.bbfSpacerButton
    if not button or container.bbfSpacerMouseOff or InCombatLockdown() then return end
    container.bbfSpacerMouseOff = true
    button:EnableMouse(false)
end

local function CreateSpacerContainer(host, parent)
    local container = CreateTypeContainer(host, true, parent)
    container:SetAlpha(0)
    return container
end

local function AddSpacerGroup(container)
    container:AddAuraGroup(SPACER_KEY, SpacerFilterString(true), {
        maxFrameCount = 0,
        layout = { elementWidth = 1, elementHeight = SpacerExtent() },
        initializeFrame = function(button)
            button:SetSize(1, 1)
            button:SetCancelAuraButtons(nil)
            button:SetHideTooltipInCombat(true)
            container.bbfSpacerButton = button
            DisableSpacerMouse(container)
        end,
    })
end

local function ConfigureSpacer(host, harmful)
    local spacer = host.spacer
    if not spacer then return end

    spacer.bbfHarmful = harmful
    local record = GetAppliedRecord(spacer, SPACER_KEY)

    local filter = SpacerFilterString(harmful)
    if record.filterString ~= filter then
        record.filterString = filter
        spacer:SetAuraGroupFilterString(SPACER_KEY, filter)
    end

    local count = (GetFrameConfig(host, harmful).enabled and not PreviewIsActive(host))
        and 1 or 0
    if record.count ~= count then
        record.count = count
        spacer:SetAuraGroupMaxFrameCount(SPACER_KEY, count)
    end

    ApplyGroupLayout(spacer, SPACER_KEY, nil, nil, 1, SpacerExtent(), nil, nil)
    spacer:SetScale(host.scale or S.scale)
end

local function ConfigureContainer(host, container, harmful)
    container.bbfHarmful = harmful

    if not UnitExists(host.unit) then return end

    local defs = AURA_GROUPS
    local cfg = GetFrameConfig(host, harmful)
    cfg.mergeNormal = not NeedsMineSplit(cfg)

    cfg.otherFiltersOn = (cfg.onlyMine or cfg.short or cfg.purgeable)
        and true or false

    local canFilterIDs = BBF.CanFilterBySpellID(host.unit, not harmful)
    local sort = SortFor(host)

    for index, def in ipairs(defs) do
        local filters, blockAll = BuildCandidateFilters(harmful, def.tier, cfg, canFilterIDs)

        container:SetAuraGroupFilterString(def.key, BuildFilterString(harmful, def.tier, cfg))
        ApplyGroupCandidateFilters(container, def.key, filters)
        ApplyGroupSortMethod(container, def.key, sort[1], sort[2])

        local count = 0
        if cfg.enabled and not blockAll and not PreviewIsActive(host) then
            local whitelistLive = (cfg.whitelist or cfg.collapsed) and true or false

            if def.tier == "whitelistpandemic" then
                count = (whitelistLive and cfg.splitPandemic) and (cfg.maxCount or 32) or 0
            elseif WHITELIST_TIERS[def.tier] then
                count = whitelistLive and (cfg.maxCount or 32) or 0
            elseif HIGHLIGHT_TIERS[def.tier] then
                count = HighlightTierActive(def.tier, harmful, cfg.importantFirst)
                    and (cfg.maxCount or 32) or 0
            elseif cfg.collapsed then
                count = 0
            elseif def.tier == "mine" and cfg.mergeNormal then
                count = 0
            elseif def.tier == "others" and cfg.onlyMine and not cfg.mergeNormal then
                count = 0
            elseif cfg.whitelist and not cfg.otherFiltersOn then
                count = 0
            else
                count = cfg.maxCount or 32
            end
        end

        container:SetAuraGroupMaxFrameCount(def.key, count)
    end

    local sizes = GetHostSizes(host)
    local hGap, vGap = host.hGap or S.hGap, host.vGap or S.vGap

    local primaryGap, crossGap = hGap, vGap
    if host.isPlayer and sizes.isHorizontal == false then
        primaryGap, crossGap = vGap, hGap
    end

    for index, def in ipairs(defs) do
        local cell, cellHeight = GetTierCell(def.tier, sizes)

        ApplyGroupLayout(container, def.key,
            primaryGap, crossGap, cell, cellHeight, index, crossGap)
    end

    if host.itemEnchantments then
        local record = GetAppliedRecord(container, "$itemEnchantments")
        local signature = string.format("%s/%s/%s/%s",
            primaryGap, crossGap, sizes.cell, sizes.cellHeight)
        if record.layout ~= signature then
            record.layout = signature
            container:SetItemEnchantmentLayout({
                placement = CustomAuraContainerItemEnchantmentPlacement.BeforeAuraGroups,
                elementSpacing = primaryGap,
                lineSpacing = crossGap,
                elementWidth = sizes.cell,
                elementHeight = sizes.cellHeight,
            })
        end
    end

    container:SetScale(host.scale or S.scale)
    container:SetFlowLayoutMaximumLineSize(GetMaxLineSize(host, sizes, primaryGap))
    container:SetFrameStrata(container.bbfBaseStrata)
    if S.increaseStrata then
        container:SetFrameLevel(9999)
    end
end

local function IsTopBlockHarmful(host)
    if host.isPlayer then
        return host.blockTop == host.debuffs
    end
    local reaction = UnitExists(host.unit) and UnitReaction("player", host.unit)
    return not reaction or reaction <= 4
end

local function SameStyleValue(a, b)
    if a == b then return true end
    if type(a) ~= "table" or type(b) ~= "table" then return false end
    if #a ~= #b then return false end
    for i = 1, #a do
        if a[i] ~= b[i] then return false end
    end
    return true
end

local function ReplaceStyleInPlace(style, fresh)
    local changed = false

    for key in pairs(style) do
        if fresh[key] == nil then changed = true break end
    end
    if not changed then
        for key, value in pairs(fresh) do
            if not SameStyleValue(style[key], value) then changed = true break end
        end
    end
    if not changed then return false end

    for key in pairs(style) do style[key] = nil end
    for key, value in pairs(fresh) do style[key] = value end
    return true
end

local function RefreshEnchantStyle(host, container)
    local style = host.enchantStyle or {}
    local fresh = {}
    for key, value in pairs(container.bbfStyles.Others) do fresh[key] = value end
    fresh.removeDebuffBorder = true

    if ReplaceStyleInPlace(style, fresh) then
        container.bbfStylesChanged = true
    end
    return style
end

function BBF.ApplyAuraGroupConfig(host)
    if not host.blockTop then return end

    local topHarmful = IsTopBlockHarmful(host)
    local sizes = GetHostSizes(host)

    local function Configure(container, harmful)
        local cfg = GetFrameConfig(host, harmful)
        for _, def in ipairs(AURA_GROUPS) do
            local style = container.bbfStyles[def.key]
            if style then
                local fresh = BuildStyle(def.tier, sizes, host.isPlayer, cfg, styleScratch)
                if ReplaceStyleInPlace(style, fresh) then
                    container.bbfStylesChanged = true
                end
            end
        end
        if host.enchantStyle then
            RefreshEnchantStyle(host, container)
        end
        ConfigureContainer(host, container, harmful)
    end

    Configure(host.blockTop, topHarmful)
    if host.blockBottom ~= host.blockTop then
        Configure(host.blockBottom, not topHarmful)
    end
    ConfigureSpacer(host, topHarmful)
end

BBF.AURA_ANCHOR_TEMPLATE = "DisableUntrustedLayoutScriptsTemplate"

local function AnchorToContainer(frame, container, point, relPoint, x, y)
    frame:ClearAllPoints()
    frame:SetPoint(point, container, relPoint, x, y)
end

local function ApplyFlowAnchor(container, point, growth)
    if not container then return end
    container:SetFlowLayoutAnchorPoint(point)
    container:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Right, growth)
end

local function ContainerScale(host)
    local scale = host.scale or S.scale or 1
    return scale > 0 and scale or 1
end

function BBF.AnchorAuraContainer(host)
    if host.isPlayer or not host.blockTop then return end

    local frame = host.frame
    local buffsOnTop = frame.buffsOnTop == true
    local frameContainer = frame.TargetFrameContainer
    local anchorTo = (frameContainer and frameContainer.FrameTexture) or frame

    local point, relPoint, startY, growth
    if buffsOnTop then
        point, relPoint = "BOTTOMLEFT", "TOPLEFT"
        startY = AURA_MIRRORED_START_Y + S.offsetY
        growth = AnchorUtil.FlowDirection.Up
    else
        point, relPoint = "TOPLEFT", "BOTTOMLEFT"
        startY = AURA_START_Y + S.offsetY
        growth = AnchorUtil.FlowDirection.Down
    end

    ApplyFlowAnchor(host.spacer, point, growth)
    ApplyFlowAnchor(host.blockTop, point, growth)
    ApplyFlowAnchor(host.blockBottom, point, growth)

    local scale = ContainerScale(host)
    local startX = (AURA_START_X + S.offsetX) / scale
    startY = startY / scale

    local lift = SpacerExtent()
    host.spacer:ClearAllPoints()
    host.spacer:SetPoint(point, anchorTo, relPoint,
        startX, startY + (buffsOnTop and -lift or lift))
    AnchorToContainer(host.blockTop, host.spacer, point, relPoint, 0, 0)

    local gapY = buffsOnTop and S.typeGap or -S.typeGap
    AnchorToContainer(host.blockBottom, host.blockTop, point, relPoint, 0, gapY)
end

local function UpdateAllAurasIn(container)
    container:UpdateAllAuras()
end

local function ForEachContainer(host, fn)
    if host.spacer then fn(host.spacer) end
    if host.blockTop then fn(host.blockTop) end
    if host.blockBottom and host.blockBottom ~= host.blockTop then fn(host.blockBottom) end
    if host.filtered then fn(host.filtered) end
end

local restyleQueued = false

local function AurasAreSecret()
    return C_Secrets and C_Secrets.ShouldAurasBeSecret and C_Secrets.ShouldAurasBeSecret()
end

function BBF.RestyleAuraButtons(force)
    if AurasAreSecret() then
        restyleQueued = true
        return
    end
    restyleQueued = false

    for _, host in pairs(BBF.auraHosts) do
        ForEachContainer(host, function(container)
            if not force and not container.bbfStylesChanged then return end
            container.bbfStylesChanged = false

            for key, style in pairs(container.bbfStyles) do
                for i = 1, container:GetAuraGroupFrameCount(key) do
                    local button = container:GetAuraGroupFrame(key, i)
                    if button and button.bbfIcon then
                        ApplyMutableStyle(button, style)
                    end
                end
            end

            if container == host.blockTop then
                for _, button in ipairs(host.enchantButtons or {}) do
                    if button.bbfIcon then
                        ApplyMutableStyle(button, host.enchantStyle)
                    end
                end
            end
        end)
    end
end

local function SuppressBlizzardAuras(frame)
    local container = frame.GetAuraContainer and frame:GetAuraContainer()
    if not container then return end

    container:SetMaxBuffs(0)
    container:SetMaxDebuffs(0)
    container:SetEnabled(false)
end

local blizzardAurasSuppressed = false

local function SuppressAllBlizzardAuras()
    if blizzardAurasSuppressed then return end
    blizzardAurasSuppressed = true

    for _, frame in ipairs({ TargetFrame, FocusFrame }) do
        SuppressBlizzardAuras(frame)
        hooksecurefunc(frame, "ConfigureAuraContainer", SuppressBlizzardAuras)
        frame:GetAuraContainer():SetUnit("none")
    end
end

local CB = {
    anchoring = {},
    hooked = false,
    keys = { "target", "focus" },
    owned = {},
    layoutAspect = Enum.ForbiddenAspect and Enum.ForbiddenAspect.UntrustedLayoutScriptExecution,

    -- Aura settings on
    blockX = 18,
    blockY = -5,
    blockMirrorY = 15,
    staticX = 43,
    staticY = -5.5,

    -- Aura settings off
    defaultX = 17,
    defaultY = -8,
    defaultStaticX = 42,
    defaultStaticY = -3.5,
    defaultToTX = 42,
    defaultToTY = -46,
    defaultAuraX = 17,
    defaultAuraY = -8,
    defaultToTUncheckedX = 25,
    defaultToTUncheckedY = 8.5,
}

function CB.GetFrames(key)
    if key == "target" then
        return TargetFrame, TargetFrameSpellBar
    elseif key == "focus" then
        return FocusFrame, FocusFrameSpellBar
    end
end

function CB.Settings(key)
    if key == "target" then
        return targetStaticCastbar, targetDetachCastbar,
            targetCastBarXPos, targetCastBarYPos,
            targetToTCastbarAdjustment, targetToTAdjustmentOffsetY
    end
    return focusStaticCastbar, focusDetachCastbar,
        focusCastBarXPos, focusCastBarYPos,
        focusToTCastbarAdjustment, focusToTAdjustmentOffsetY
end

function CB.ApplyPoint(spellbar, point, relTo, relPoint, x, y)
    if spellbar.ClearPointsOffset then
        spellbar:ClearPointsOffset()
    end
    spellbar:ClearAllPoints()
    spellbar:SetPoint(point, relTo, relPoint, x, y)
end

function CB.TryPoint(key, spellbar, point, relTo, relPoint, x, y)
    CB.anchoring[key] = true
    local ok = pcall(CB.ApplyPoint, spellbar, point, relTo, relPoint, x, y)
    CB.anchoring[key] = nil
    return ok
end

function CB.BlizzBase(frame)
    local baseX = frame.smallSize and 38 or 43
    local baseY = frame.smallSize and 3 or 5
    if frame.haveToT then
        baseY = frame.smallSize and -48 or -46
    end
    return baseX, baseY
end

function CB.SetOwnPoint(key, spellbar, point, relTo, relPoint, x, y)
    CB.owned[key] = true

    if CB.TryPoint(key, spellbar, point, relTo, relPoint, x, y) then
        return true
    end

    local frame = CB.GetFrames(key)
    if frame then
        local baseX, baseY = CB.BlizzBase(frame)
        CB.TryPoint(key, spellbar, "TOPLEFT", frame, "BOTTOMLEFT", baseX, baseY)
    end
    return false
end

function CB.Release(key, frame, spellbar)
    if not CB.owned[key] then return end
    CB.owned[key] = nil

    local baseX, baseY = CB.BlizzBase(frame)
    CB.TryPoint(key, spellbar, "TOPLEFT", frame, "BOTTOMLEFT", baseX, baseY)
end

function CB.CanAnchorToContainer(spellbar, block)
    local aspect = CB.layoutAspect
    if not block then return false end
    if not (aspect and block.HasAnyForbiddenAspects) then return true end
    if not block:HasAnyForbiddenAspects(aspect) then return true end
    return spellbar:HasAnyForbiddenAspects(aspect) and true or false
end

function CB.SeedContainerAnchor(host)
    local spellbar, block = host.spellbar, host.blockBottom
    if not spellbar or not block then return end

    host.spellbarOnBlock = CB.SetOwnPoint(host.key, spellbar,
        "TOPLEFT", block, "BOTTOMLEFT", CB.blockX, CB.blockY)
end

function CB.Anchor(key)
    if CB.anchoring[key] then return end
    if BetterBlizzFramesDB.disableCastbarMovement then return end

    local frame, spellbar = CB.GetFrames(key)
    if not frame or not spellbar then return end

    local staticBar, detachBar, xPos, yPos, totAdjust, totOffsetY = CB.Settings(key)

    local host = BBF.auraHosts and BBF.auraHosts[key]
    local block = host and host.blockBottom

    if spellbar.bbfHiddenCastbar then
        spellbar:SetClampedToScreen(false)
        CB.SetOwnPoint(key, spellbar, "TOPLEFT", frame, "BOTTOMLEFT", 0, 9000)
        return
    end

    if detachBar then
        CB.SetOwnPoint(key, spellbar, "CENTER", UIParent, "CENTER", xPos, yPos)
        return
    end

    if staticBar then
        local baseX = block and CB.staticX or CB.defaultStaticX
        local baseY = block and CB.staticY or CB.defaultStaticY
        CB.SetOwnPoint(key, spellbar, "TOPLEFT", frame, "BOTTOMLEFT", baseX + xPos, baseY + yPos)
        return
    end

    local mirrored = frame.buffsOnTop == true

    if block and CB.CanAnchorToContainer(spellbar, block) then
        if mirrored and not buffsOnTopReverseCastbarMovement then
            local baseX = frame.smallSize and 38 or 43
            local baseY = frame.smallSize and 3 or 5
            if frame.haveToT and totAdjust then
                baseY = (frame.smallSize and -48 or -46) + totOffsetY
            end
            CB.SetOwnPoint(key, spellbar, "TOPLEFT", frame, "BOTTOMLEFT", baseX + xPos, baseY + yPos)
            return
        end

        if mirrored then
            CB.SetOwnPoint(key, spellbar, "BOTTOMLEFT", block, "TOPLEFT", CB.blockX + xPos, CB.blockMirrorY + yPos)
        else
            CB.SetOwnPoint(key, spellbar, "TOPLEFT", block, "BOTTOMLEFT", CB.blockX + xPos, CB.blockY + yPos)
        end
        return
    end

    CB.Release(key, frame, spellbar)

    if not spellbar.SetPointsOffset then return end

    local _, relTo = spellbar:GetPoint()
    local onBlizzContainer = frame.GetAuraContainer and relTo == frame:GetAuraContainer()

    local baseX, baseY
    if onBlizzContainer then
        baseX, baseY = CB.defaultAuraX, CB.defaultAuraY
    elseif frame.haveToT and totAdjust then
        baseX, baseY = CB.defaultToTX, CB.defaultToTY + totOffsetY
    elseif frame.haveToT then
        baseX, baseY = CB.defaultX + CB.defaultToTUncheckedX, CB.defaultY + CB.defaultToTUncheckedY
    else
        baseX, baseY = CB.defaultX, CB.defaultY
    end

    spellbar:SetPointsOffset(xPos + baseX, yPos + baseY)
end

BBF.AnchorCastbar = CB.Anchor

local function AnchorSpellbar(host)
    if not host or not host.spellbar then return end
    CB.Anchor(host.key)
end

function BBF.HookCastbarAnchoring()
    if CB.hooked then return end

    for _, key in ipairs(CB.keys) do
        local frame, spellbar = CB.GetFrames(key)
        if not frame or not spellbar then return end
    end

    CB.hooked = true

    for _, key in ipairs(CB.keys) do
        local _, spellbar = CB.GetFrames(key)
        hooksecurefunc(spellbar, "SetPoint", function()
            if CB.anchoring[key] then return end
            CB.Anchor(key)
        end)
    end

    local driver = CreateFrame("Frame")
    driver:RegisterEvent("PLAYER_TARGET_CHANGED")
    driver:RegisterEvent("PLAYER_FOCUS_CHANGED")
    driver:SetScript("OnEvent", function(_, event)
        CB.Anchor(event == "PLAYER_FOCUS_CHANGED" and "focus" or "target")
    end)

    BBF.CastbarAdjustCaller()
end

function BBF.CastbarAdjustCaller(key)
    BBF.UpdateUserAuraSettings()
    if key then
        CB.Anchor(key)
        return
    end
    for _, k in ipairs(CB.keys) do
        CB.Anchor(k)
    end
end

local function RefreshHost(host)
    if host.isPlayer then
        BBF.AnchorPlayerAuraContainer(host)
        BBF.ApplyAuraGroupConfig(host)
        BBF.RefreshFilteredAuras(host)
        return
    end

    BBF.ApplyAuraGroupConfig(host)
    BBF.AnchorAuraContainer(host)
    AnchorSpellbar(host)
end

local function DoRefreshAllAuraFrames()
    BBF.UpdateUserAuraSettings()
    RefreshSpellLists()

    for _, host in pairs(BBF.auraHosts) do
        RefreshHost(host)
    end

    BBF.RestyleAuraButtons()
    BBF.RefreshAuraTestMode()
end

local refreshScheduled = false

function BBF.RefreshAllAuraFrames()
    if refreshScheduled then return end
    refreshScheduled = true

    C_Timer.After(0, function()
        refreshScheduled = false
        DoRefreshAllAuraFrames()
    end)
end

function BBF.SetupMasqueSupport()
end

local BuffFrame = BuffFrame
local DebuffFrame = DebuffFrame

local function GetEditModeAuraLayout(hostFrame)
    local c = hostFrame.AuraContainer
    return {
        isHorizontal = not c or c.isHorizontal ~= false,
        addIconsToRight = c and c.addIconsToRight == true,
        addIconsToTop = c and c.addIconsToTop == true,
        iconStride = (c and c.iconStride) or 8,
        iconScale = (c and c.iconScale) or 1,
        iconPadding = (c and c.iconPadding) or 5,
        showDispelType = c and c.showDispelType == true,
    }
end

local function GetPlayerAnchorPoint(layout)
    if layout.addIconsToTop then
        return layout.addIconsToRight and "BOTTOMLEFT" or "BOTTOMRIGHT"
    end
    return layout.addIconsToRight and "TOPLEFT" or "TOPRIGHT"
end

local function GetPlayerContainerOffset(host, layout)
    local button = host.frame.CollapseAndExpandButton
    if not button then return 0, 0 end

    if layout.isHorizontal then
        local width = button:GetWidth() or COLLAPSE_BUTTON_EXTENT
        return layout.addIconsToRight and width or -width, 0
    end

    local height = button:GetHeight() or COLLAPSE_BUTTON_EXTENT
    return 0, layout.addIconsToTop and height or -height
end

local function ReadPlayerEditModeLayout(host)
    local layout = GetEditModeAuraLayout(host.frame)

    host.scale = layout.iconScale
    host.hGap = layout.iconPadding + S.playerSpacingX
    host.vGap = layout.iconPadding + S.playerSpacingY
    host.perRow = layout.iconStride
    host.isHorizontal = layout.isHorizontal
    host.addIconsToRight = layout.addIconsToRight
    host.addIconsToTop = layout.addIconsToTop
    host.showDispelType = layout.showDispelType

    return layout
end

function BBF.AnchorPlayerAuraContainer(host)
    local layout = ReadPlayerEditModeLayout(host)

    local container = host.buffs or host.debuffs
    if not container then return end

    local point = GetPlayerAnchorPoint(layout)

    container:SetFlowLayoutAxis(layout.isHorizontal
        and AnchorUtil.FlowLayoutAxis.Horizontal
        or AnchorUtil.FlowLayoutAxis.Vertical)
    container:SetFlowLayoutAnchorPoint(point)
    container:SetFlowLayoutGrowthDirection(
        layout.addIconsToRight and AnchorUtil.FlowDirection.Right or AnchorUtil.FlowDirection.Left,
        layout.addIconsToTop and AnchorUtil.FlowDirection.Up or AnchorUtil.FlowDirection.Down)

    local offsetX, offsetY = GetPlayerContainerOffset(host, layout)
    container:ClearAllPoints()
    container:SetPoint(point, host.frame, point, offsetX, offsetY)

    if host.buffs then
        BBF.RefreshBuffCollapseButton(layout)
    end
end

do

local COLLAPSE_ARROW_ATLAS = "bag-arrow"
local COLLAPSE_ARROW_WIDTH, COLLAPSE_ARROW_HEIGHT = 10, 16

local ROTATION_RIGHT, ROTATION_LEFT = 0, math.pi
local ROTATION_UP, ROTATION_DOWN = math.pi / 2, 3 * math.pi / 2

local function BuffsAreCollapsed()
    return BetterBlizzFramesDB.playerBuffsCollapsed and true or false
end

local function GetCollapseRotation(layout, expanded)
    local forward, back
    if layout.isHorizontal then
        forward = layout.addIconsToRight and ROTATION_RIGHT or ROTATION_LEFT
        back = layout.addIconsToRight and ROTATION_LEFT or ROTATION_RIGHT
    else
        forward = layout.addIconsToTop and ROTATION_UP or ROTATION_DOWN
        back = layout.addIconsToTop and ROTATION_DOWN or ROTATION_UP
    end
    return expanded and forward or back
end

function BBF.CreateBuffCollapseButton()
    if BBF.buffCollapseButton then return BBF.buffCollapseButton end

    local button = CreateFrame("Button", "BBFBuffCollapseButton", BuffFrame)
    BBF.buffCollapseButton = button
    button:RegisterForClicks("LeftButtonUp")

    local function Arrow(setter, alpha, blend)
        local texture = button:CreateTexture(nil, "ARTWORK")
        setter(button, texture)
        texture:SetAtlas(COLLAPSE_ARROW_ATLAS)
        texture:SetSize(COLLAPSE_ARROW_WIDTH, COLLAPSE_ARROW_HEIGHT)
        texture:ClearAllPoints()
        texture:SetPoint("CENTER")
        if alpha then texture:SetAlpha(alpha) end
        if blend then texture:SetBlendMode(blend) end
        return texture
    end

    button.bbfArrows = {
        Arrow(button.SetNormalTexture),
        Arrow(button.SetPushedTexture),
        Arrow(button.SetHighlightTexture, 0.4, "ADD"),
    }

    button:SetScript("OnClick", function()
        BetterBlizzFramesDB.playerBuffsCollapsed = not BuffsAreCollapsed()
        BBF.RefreshAllAuraFrames()
    end)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames")
        GameTooltip:AddLine(L["Tooltip_Buff_Collapse_Button"], 1, 1, 1, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    if BBF.DarkModeBuffCollapseButton then
        BBF.DarkModeBuffCollapseButton()
    end

    return button
end

function BBF.RefreshBuffCollapseButton(layout)
    local button = BBF.buffCollapseButton
    if not button then return end

    button:SetShown(S.player.buffs and true or false)

    local point = GetPlayerAnchorPoint(layout)
    button:ClearAllPoints()
    button:SetPoint(point, BuffFrame, point)
    button:SetScale(layout.iconScale or 1)

    if layout.isHorizontal then
        button:SetSize(COLLAPSE_BUTTON_EXTENT, 2 * COLLAPSE_BUTTON_EXTENT)
    else
        button:SetSize(2 * COLLAPSE_BUTTON_EXTENT, COLLAPSE_BUTTON_EXTENT)
    end

    local rotation = GetCollapseRotation(layout, not BuffsAreCollapsed())
    for _, arrow in ipairs(button.bbfArrows) do
        arrow:SetRotation(rotation)
    end
end

end

local FILTERED_GROUPS = {
    { key = "Filtered", onlyOthers = false },
    { key = "FilteredOthers", onlyOthers = true },
}

local FILTERED_FLOW = {
    BOTTOM = { vertical = true,  horizontal = "Right", growth = "Down",
               anchor = "TOPLEFT",    relative = "BOTTOMLEFT", x = 0,  y = -1 },
    TOP    = { vertical = true,  horizontal = "Right", growth = "Up",
               anchor = "BOTTOMLEFT", relative = "TOPLEFT",    x = 0,  y = 1 },
    RIGHT  = { vertical = false, horizontal = "Right", growth = "Down",
               anchor = "TOPLEFT",    relative = "TOPRIGHT",   x = 1,  y = 0 },
    LEFT   = { vertical = false, horizontal = "Left",  growth = "Down",
               anchor = "TOPRIGHT",   relative = "TOPLEFT",    x = -1, y = 0 },
}

local FILTERED_ICON_GAP = 5

local filteredPinned = false

local function SetFilteredAurasShown(shown)
    local host = BBF.auraHosts.playerBuffs
    if not host or not host.filtered then return end
    host.filtered:SetShown(shown and S.showFilteredIcon and true or false)
end

local function AnchorToggleIcon()
    local icon = BBF.toggleAuraIcon
    if not icon then return end

    icon:ClearAllPoints()

    local saved = BetterBlizzFramesDB.toggleIconPosition
    if saved then
        icon:SetPoint(saved[1], UIParent, saved[3], saved[4], saved[5])
        return
    end

    local collapse = BuffFrame.CollapseAndExpandButton
    if collapse then
        if BuffFrame.AuraContainer and BuffFrame.AuraContainer.addIconsToRight then
            icon:SetPoint("RIGHT", collapse, "LEFT", 0, 0)
        else
            icon:SetPoint("LEFT", collapse, "RIGHT", 0, 0)
        end
    else
        icon:SetPoint("TOPLEFT", BuffFrame, "TOPRIGHT", 0, -6)
    end
end

BBF.UpdateHiddenAuraButtonPos = AnchorToggleIcon

local DIRECTION_CYCLE = { BOTTOM = "LEFT", LEFT = "TOP", TOP = "RIGHT", RIGHT = "BOTTOM" }

local function CreateToggleIcon()
    if BBF.toggleAuraIcon then return BBF.toggleAuraIcon end

    local icon = CreateFrame("Button", "ToggleHiddenAurasButton", BuffFrame)
    BBF.toggleAuraIcon = icon
    icon:SetSize(PLAYER_AURA_ICON, PLAYER_AURA_ICON)
    icon:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    local texture = icon:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints()
    texture:SetTexture(BetterBlizzFramesDB.auraToggleIconTexture or 134430)
    icon.Icon, icon.icon = texture, texture

    icon:SetScript("OnClick", function(_, button)
        if IsAltKeyDown() and button == "LeftButton" then
            local db = BetterBlizzFramesDB
            db.hiddenIconDirection = DIRECTION_CYCLE[db.hiddenIconDirection or "BOTTOM"] or "BOTTOM"
            BBF.RefreshAllAuraFrames()
            print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: "
                .. L["Filtered_Buffs_Direction_Set"] .. " " .. db.hiddenIconDirection)
        elseif IsShiftKeyDown() then
            BetterBlizzFramesDB.toggleIconPosition = nil
            AnchorToggleIcon()
        else
            filteredPinned = not filteredPinned
            SetFilteredAurasShown(filteredPinned)
        end
    end)

    icon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0)
        GameTooltip:AddLine("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames")
        GameTooltip:AddLine(L["Tooltip_Filtered_Buffs_Icon"], 1, 1, 1, true)
        GameTooltip:Show()
    end)

    icon:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    icon:SetMovable(true)
    icon:EnableMouse(true)
    icon:RegisterForDrag("LeftButton")
    icon:SetScript("OnDragStart", function(self)
        if IsControlKeyDown() then
            self:StartMoving()
        end
    end)
    icon:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        BetterBlizzFramesDB.toggleIconPosition = { point, nil, relativePoint, x, y }
    end)

    return icon
end

local function GetFilteredFlow()
    return FILTERED_FLOW[S.filteredDirection] or FILTERED_FLOW.BOTTOM
end

local function AnchorFilteredContainer(host)
    local icon, container = BBF.toggleAuraIcon, host.filtered
    if not icon or not container then return end

    local flow, gap = GetFilteredFlow(), FILTERED_ICON_GAP

    container:SetFlowLayoutAxis(flow.vertical
        and AnchorUtil.FlowLayoutAxis.Vertical
        or AnchorUtil.FlowLayoutAxis.Horizontal)
    container:SetFlowLayoutAnchorPoint(flow.anchor)
    container:SetFlowLayoutGrowthDirection(
        AnchorUtil.FlowDirection[flow.horizontal], AnchorUtil.FlowDirection[flow.growth])

    container:ClearAllPoints()
    container:SetPoint(flow.anchor, icon, flow.relative, gap * flow.x, gap * flow.y)
    BBF.AC = container
end

local function BuildFilteredStyle(sizes, cfg)
    local style = BuildStyle("others", sizes, true, cfg)
    style.showTimerText = false
    style.buttonWidth, style.buttonHeight = PLAYER_AURA_ICON, PLAYER_AURA_ICON
    style.iconPoint = "CENTER"
    return style
end

local function ConfigureFilteredContainer(host)
    local container = host.filtered
    if not container then return end

    local sizes = GetHostSizes(host)
    local cfg = GetFrameConfig(host, false)

    if ReplaceStyleInPlace(host.filteredStyle, BuildFilteredStyle(sizes, cfg)) then
        container.bbfStylesChanged = true
    end

    local canFilterIDs = BBF.CanFilterBySpellID(host.unit, true)
    local blacklist = listCache.blacklist
    local cell, cellHeight = PLAYER_AURA_ICON, PLAYER_AURA_ICON
    local gap = FILTERED_ICON_GAP

    for index, def in ipairs(FILTERED_GROUPS) do
        local parts = { F.Helpful }
        if def.onlyOthers then parts[#parts + 1] = "!" .. F.Player end
        container:SetAuraGroupFilterString(def.key, AuraUtil.CreateFilterString(unpack(parts)))

        local set
        if def.onlyOthers then
            set = canFilterIDs and blacklist.showMine or blacklist.showMineNS
        else
            set = canFilterIDs and blacklist.mine or blacklist.mineNS
        end

        local usable = next(set) ~= nil
        local sort = SortFor(host)
        ApplyGroupCandidateFilters(container, def.key,
            usable and { includeSpellIDs = set } or {})
        ApplyGroupSortMethod(container, def.key, sort[1], sort[2])
        container:SetAuraGroupMaxFrameCount(def.key,
            (usable and cfg.blacklist and S.showFilteredIcon and not PreviewIsActive(host))
                and (cfg.maxCount or 32) or 0)

        ApplyGroupLayout(container, def.key,
            gap, gap, cell, cellHeight, index, nil)
    end

    container:SetScale(host.scale or S.scale)
    container:SetFlowLayoutMaximumLineSize(GetMaxLineSize(host, sizes, gap))
    container:SetFrameStrata(S.increaseStrata and "FULLSCREEN" or container.bbfBaseStrata)
end

function BBF.RefreshFilteredAuras(host)
    host = host or BBF.auraHosts.playerBuffs
    if not host or not host.filtered then return end

    if BBF.toggleAuraIcon then
        BBF.toggleAuraIcon:SetShown(S.showFilteredIcon and true or false)
        BBF.toggleAuraIcon:SetScale(host.scale or 1)
        AnchorToggleIcon()
    end

    ConfigureFilteredContainer(host)
    AnchorFilteredContainer(host)
    SetFilteredAurasShown(filteredPinned)
end

local function CreateFilteredAuras(host)
    CreateToggleIcon()

    local container = CreateTypeContainer(host, false, host.frame)
    host.filtered = container
    host.filteredStyle = BuildFilteredStyle(GetHostSizes(host), GetFrameConfig(host, false))

    AnchorFilteredContainer(host)

    local sort = SortFor(host)

    for _, def in ipairs(FILTERED_GROUPS) do
        container:AddAuraGroup(def.key, F.Helpful, {
            maxFrameCount = 0,
            sortMethod = sort[1],
            sortDirection = sort[2],
            initializeFrame = function(button)
                InitAuraButton(button, host.filteredStyle)
            end,
        })
    end

    container:Hide()
    BBF.RefreshFilteredAuras(host)
end

BBF.filterOverride = false
function BBF.ToggleFilterOverride()
    filteredPinned = not filteredPinned
    BBF.filterOverride = filteredPinned
    SetFilteredAurasShown(filteredPinned)
end

local function DisableDefaultPlayerAuras(hostFrame)
    hostFrame:UnregisterAllEvents()
    hostFrame:SetScript("OnUpdate", nil)

    if hostFrame.AuraContainer then
        hostFrame.AuraContainer:Hide()
    end

    for _, auraFrame in ipairs(hostFrame.auraFrames or {}) do
        if not auraFrame.isAuraAnchor then
            auraFrame:SetScript("OnUpdate", nil)
            auraFrame:Hide()
        end
    end

    if hostFrame == BuffFrame then
        if CVarCallbackRegistry then
            CVarCallbackRegistry:UnregisterCallback("consolidateBuffs", BuffFrame)
            CVarCallbackRegistry:UnregisterCallback("collapseExpandBuffs", BuffFrame)
        end

        local function HideConsolidation()
            if BuffFrame.ConsolidatedBuffs then BuffFrame.ConsolidatedBuffs:Hide() end
            if BuffFrame.CollapseAndExpandButton then BuffFrame.CollapseAndExpandButton:Hide() end
        end
        HideConsolidation()
        hooksecurefunc(BuffFrame, "RefreshConsolidationFrameVisibility", HideConsolidation)
    end
end

function BBF.RefreshPlayerAuraFrames()
    for _, key in ipairs({ "playerBuffs", "playerDebuffs" }) do
        local host = BBF.auraHosts[key]
        if host then
            BBF.AnchorPlayerAuraContainer(host)
            BBF.ApplyAuraGroupConfig(host)
        end
    end
end

local testHosts = {}
BBF.auraTestPreviews = testHosts

local FALLBACK_ICON = 134400

local TEST_AURAS = {
    helpful = {
        { tier = "important", spellID = 190319,   duration = 8 },   -- Combustion
        { tier = "bigdef",    spellID = 871,   duration = 12 },  -- Shield Wall
        { tier = "extdef",    spellID = 33206, duration = 8 },   -- Pain Suppression
        { tier = "mine",      spellID = 17,    duration = 15, count = 2 }, -- PW: Shield
        { tier = "mine",      spellID = 139,   duration = 15 },  -- Renew
        { tier = "mine",      spellID = 774,   duration = 15, pandemic = true },  -- Rejuvenation
        { tier = "mine",      spellID = 8936,  duration = 12 },  -- Regrowth
        { tier = "mine",      spellID = 33763, duration = 15, count = 3, pandemic = true }, -- Lifebloom
        { tier = "mine",      spellID = 61295, duration = 18 },  -- Riptide
        { tier = "others",    spellID = 1459,  duration = 0, dispel = "Magic" }, -- Arcane Intellect
        { tier = "others",    spellID = 21562, duration = 0 },   -- PW: Fortitude
        { tier = "others",    spellID = 1126,  duration = 0 },   -- Mark of the Wild
        { tier = "others",    spellID = 6673,  duration = 0 },   -- Battle Shout
        { tier = "others",    spellID = 1044,  duration = 8, dispel = "Magic" }, -- Blessing of Freedom
        { tier = "others",    spellID = 465,   duration = 0 },   -- Devotion Aura
        { tier = "others",    spellID = 32182, duration = 40 },  -- Heroism
        { tier = "others",    spellID = 2645,  duration = 0 },   -- Ghost Wolf
    },
    harmful = {
        { tier = "cc",        spellID = 118,    duration = 8, dispel = "Magic" },  -- Polymorph
        { tier = "mine",      spellID = 5782,   duration = 6, dispel = "Magic" },  -- Fear
        { tier = "mine",      spellID = 589,    duration = 16, dispel = "Magic", pandemic = true }, -- Shadow Word: Pain
        { tier = "mine",      spellID = 980,    duration = 18, dispel = "Curse", count = 3, pandemic = true }, -- Agony
        { tier = "mine",      spellID = 172,    duration = 14, dispel = "Magic" }, -- Corruption
        { tier = "mine",      spellID = 348,    duration = 18, dispel = "Magic" }, -- Immolate
        { tier = "mine",      spellID = 1079,   duration = 24, count = 5 }, -- Rip
        { tier = "mine",      spellID = 155722, duration = 15 }, -- Rake
        { tier = "others",    spellID = 8921,   duration = 16, dispel = "Magic" }, -- Moonfire
        { tier = "others",    spellID = 703,    duration = 18 }, -- Garrote
        { tier = "others",    spellID = 1943,   duration = 24 }, -- Rupture
        { tier = "others",    spellID = 15407,  duration = 6, dispel = "Magic" }, -- Mind Flay
        { tier = "others",    spellID = 30108,  duration = 16, dispel = "Magic" }, -- Unstable Affliction
        { tier = "others",    spellID = 12294,  duration = 10 }, -- Mortal Strike
        { tier = "others",    spellID = 8680,   duration = 12, dispel = "Poison" }, -- Instant Poison
        { tier = "others",    spellID = 6770,  duration = 8 }, -- Sap
    },
}

local TIER_ORDER = {}
for index, def in ipairs(AURA_GROUPS) do
    TIER_ORDER[def.tier] = index
end

local previewIconGeneration = 1
local spellDataRequested = false

local function RequestTestAuraSpellData()
    if spellDataRequested then return end
    if not C_Spell or not C_Spell.RequestLoadSpellData then return end
    spellDataRequested = true

    local wanted = {}
    for _, list in pairs(TEST_AURAS) do
        for _, entry in ipairs(list) do
            if not C_Spell.IsSpellDataCached(entry.spellID) then
                wanted[entry.spellID] = true
                C_Spell.RequestLoadSpellData(entry.spellID)
            end
        end
    end

    if not next(wanted) then return end

    local listener = CreateFrame("Frame")
    listener:RegisterEvent("SPELL_DATA_LOAD_RESULT")
    listener:SetScript("OnEvent", function(_, _, spellID, success)
        if not (success and wanted[spellID]) then return end
        wanted[spellID] = nil
        previewIconGeneration = previewIconGeneration + 1
        if PreviewIsActive() then
            BBF.RefreshAuraTestMode()
        end
        if not next(wanted) then
            listener:UnregisterAllEvents()
        end
    end)
end

local function ActiveTier(tier, harmful)
    if HIGHLIGHT_TIERS[tier] and not HighlightTierActive(tier, harmful, S.importantFirst) then
        return "others"
    end
    return tier
end

local function SortedTestAuras(harmful)
    local list = {}
    for _, entry in ipairs(TEST_AURAS[harmful and "harmful" or "helpful"]) do
        list[#list + 1] = entry
    end
    table.sort(list, function(a, b)
        local ta = TIER_ORDER[ActiveTier(a.tier, harmful)] or 99
        local tb = TIER_ORDER[ActiveTier(b.tier, harmful)] or 99
        if ta ~= tb then return ta < tb end
        return a.spellID < b.spellID
    end)
    return list
end

local EDIT_MODE_TIERS = {
    helpful = { "important", "bigdef", "extdef" },
    harmful = { "cc" },
}

local EDIT_MODE_DISPELS = { "Magic", "Curse", "Disease", "Poison", "Bleed" }

local function GetExampleIcon(texture)
    local icon = texture:GetTexture()
    if icon == nil then return FALLBACK_ICON end
    if issecretvalue(icon) then return nil end
    return icon
end

local function BuildEditModeEntries(host, harmful)
    local frames = host.frame and host.frame.auraFrames
    if not frames then return nil end

    local icons, count = {}, 0
    for _, auraFrame in ipairs(frames) do
        if not auraFrame.isAuraAnchor and auraFrame.isExample and auraFrame.Icon then
            local icon = GetExampleIcon(auraFrame.Icon)
            if not icon then return nil end
            count = count + 1
            icons[count] = icon
        end
    end
    if count == 0 then return nil end

    local signature = table.concat(icons, ",")
    if host.editModeIconSignature == signature then
        return host.editModeEntries
    end
    host.editModeIconSignature = signature

    local tiers = EDIT_MODE_TIERS[harmful and "harmful" or "helpful"]
    local entries = {}
    for index = 1, count do
        entries[index] = {
            tier = tiers[index] or "others",
            icon = icons[index],
            duration = (index % 5 == 0) and 0 or (index * 20),
            count = (index % 4 == 0) and index or nil,
            dispel = harmful and EDIT_MODE_DISPELS[((index - 1) % #EDIT_MODE_DISPELS) + 1]
                or ((index % 4 == 2) and "Magic" or nil),
        }
    end

    host.editModeEntries = entries
    return entries
end

local function GetPreviewEntries(host, harmful)
    if editModeActive and host.isPlayer then
        local entries = BuildEditModeEntries(host, harmful)
        if entries then return entries end
    end
    return SortedTestAuras(harmful)
end

local function CreateTestButton(parent)
    local button = CreateFrame("Frame", nil, parent)

    button.bbfIcon = button:CreateTexture(nil, "BACKGROUND")

    local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetReverse(true)
    cooldown:SetDrawEdge(true)
    cooldown:SetDrawBling(false)
    button.bbfCooldown = cooldown

    local overlay = CreateFrame("Frame", nil, button)
    overlay:SetAllPoints(button)
    overlay:SetFrameLevel(button:GetFrameLevel() + 2)

    button.bbfCount = overlay:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    button.bbfCount:SetJustifyH("RIGHT")
    button.bbfTimer = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.bbfTimer.bbfBaseFont = { button.bbfTimer:GetFont() }
    button.bbfBorder = overlay:CreateTexture(nil, "OVERLAY", nil, 5)
    button.bbfDispel = overlay:CreateTexture(nil, "OVERLAY", nil, 6)
    button.bbfPurgeGlow = overlay:CreateTexture(nil, "OVERLAY", nil, 6)
    button.bbfPandemicGlow = overlay:CreateTexture(nil, "OVERLAY", nil, 7)
    button.bbfGlow = overlay:CreateTexture(nil, "OVERLAY", nil, 7)

    return button
end

local function StyleTestButton(button, entry, tier, style, sizes, harmful)
    local size = GetTierSize(tier, sizes)
    local icon = button.bbfIcon
    local width, height = size, size

    icon:ClearAllPoints()
    if style.isPlayer then
        width, height = style.buttonWidth, style.buttonHeight
        button:SetSize(width, height)
        icon:SetSize(PLAYER_AURA_ICON, PLAYER_AURA_ICON)
        icon:SetPoint(style.iconPoint, button, style.iconPoint)
    else
        button:SetSize(width, height)
        icon:SetAllPoints(button)
    end

    icon:SetTexture(entry.icon or C_Spell.GetSpellTexture(entry.spellID) or FALLBACK_ICON)
    if style.cropIcon then
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    else
        icon:SetTexCoord(0, 1, 0, 1)
    end

    local cooldown = button.bbfCooldown
    local wantsCooldown = not style.isPlayer or style.playerCooldown
    if wantsCooldown and entry.duration > 0 then
        cooldown:SetAllPoints(icon)
        cooldown:SetHideCountdownNumbers(style.isPlayer or not style.showTimerText)
        local elapsed = GetTime() % entry.duration
        cooldown:SetCooldown(GetTime() - elapsed, entry.duration)
        cooldown:Show()
    else
        cooldown:Clear()
        cooldown:Hide()
    end

    if style.isPlayer then
        local timer = button.bbfTimer
        timer:ClearAllPoints()
        timer:SetPoint(style.durationPoint, icon, style.durationRelativePoint,
            0, style.durationYOffset or 0)
        ApplyDurationFont(timer, style)
        if style.showTimerText and entry.duration > 0 then
            timer:SetFormattedText(
                SecondsToTimeAbbrev(entry.duration, DURATION_MINUTES_FROM / 60))
            local color = GetPlayerDurationColor(entry.duration)
            timer:SetTextColor(color:GetRGBA())
            timer:Show()
        else
            timer:Hide()
        end
    else
        local timer = cooldown:GetCountdownFontString()
        if timer then
            timer:SetScale(style.cdTextScale or 0.55)
            if style.timerColor then
                local c = style.timerBaseColor
                timer:SetTextColor(c[1], c[2], c[3], c[4] or 1)
            end
        end
        ApplyCountdownFormatter(cooldown, style)
    end

    local count = button.bbfCount
    count:ClearAllPoints()
    if style.isPlayer then
        count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -2, 2)
    else
        count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, 0)
    end
    count:SetScale(style.stackScale or 1)
    count:SetText((entry.count and entry.count > 1) and entry.count or "")

    local border = button.bbfBorder
    ApplyBorderArt(border, style.pixelBorder)
    ApplyBorderGeometry(border, icon, style.pixelBorder, style.borderInset)
    local c = style.darkColor or 1
    border:SetVertexColor(c, c, c)
    border:SetShown(style.drawBorder and (not harmful or style.removeDebuffBorder))

    local dispel = button.bbfDispel
    if harmful and not style.removeDebuffBorder and not (HIGHLIGHT_TIERS[tier] and style.glow) then
        ApplyDispelBorderGeometry(dispel, icon, style)
        if DispelBorderUsesOwnArt(style) then
            ApplyDispelBorderArt(dispel, style)
            AuraUtil.SetAuraBorderColor(dispel, entry.dispel)
        else
            dispel:SetDesaturated(false)
            AuraUtil.SetAuraBorderAtlas(dispel, entry.dispel, style.showDispelType)
            dispel:SetVertexColor(1, 1, 1, 1)
        end
        dispel:Show()
    else
        dispel:Hide()
    end

    local purge = button.bbfPurgeGlow
    local purgeMode = GetPurgeMode(style)
    local purgeable = entry.dispel and (style.purgeGlowAlways or entry.dispel == "Magic")
    if purgeMode and not harmful and purgeable then
        ApplyPurgeArt(purge, purgeMode, style.recolorPurge)
        if purgeMode == "glow" then
            purge:SetAtlas(PURGE_GLOW_ATLAS)
        else
            purge:SetTexture(STEALABLE_TEXTURE)
        end
        ApplyPurgeGeometry(purge, icon, size, purgeMode)
        if style.recolorPurge then
            local p = style.purgeColor
            purge:SetVertexColor(p[1], p[2], p[3], p[4] or 1)
        else
            purge:SetVertexColor(1, 1, 1, 1)
        end
        purge:Show()
    else
        purge:Hide()
    end

    local pandemic = button.bbfPandemicGlow
    if style.pandemicGlow and entry.pandemic then
        pandemic:SetAtlas(GLOW_ATLAS)
        pandemic:SetDesaturated(true)
        ApplyGlowGeometry(pandemic, icon, size)
        local p = style.pandemicColor
        if p then pandemic:SetVertexColor(p[1], p[2], p[3], p[4] or 1) end
        pandemic:Show()
    else
        pandemic:Hide()
    end

    local glow = button.bbfGlow
    if HIGHLIGHT_TIERS[tier] and style.glow then
        glow:SetAtlas(GLOW_ATLAS)
        glow:SetDesaturated(true)
        ApplyGlowGeometry(glow, icon, size)
        local g = style.glowColor
        if g then glow:SetVertexColor(g[1], g[2], g[3], g[4] or 1) end
        glow:Show()
    else
        glow:Hide()
    end

    return width, height
end

local function LayoutTestButtons(preview, entries, host, harmful, cursorCross)
    local sizes = GetHostSizes(host)
    local cfg = GetFrameConfig(host, harmful)
    local hGap = host.hGap or S.hGap
    local vGap = host.vGap or S.vGap

    local vertical = preview.bbfVertical
    local primaryGap = vertical and vGap or hGap
    local crossGap = vertical and hGap or vGap
    local maxLine = GetMaxLineSize(host, sizes, primaryGap)

    local point, dx, dy = preview.bbfPoint, preview.bbfDX, preview.bbfDY
    local linePrimary, lineCross = 0, 0

    local styles, styleMoved = {}, {}
    for _, entry in ipairs(entries) do
        local tier = ActiveTier(entry.tier, harmful)
        local styleKey = (harmful and "H" or "B") .. tier
        if not styles[styleKey] then
            local fresh = BuildStyle(tier, sizes, host.isPlayer, cfg)
            local style = preview.bbfStyles[styleKey]
            if style then
                styleMoved[styleKey] = ReplaceStyleInPlace(style, fresh)
            else
                style = fresh
                preview.bbfStyles[styleKey] = style
                styleMoved[styleKey] = true
            end
            styles[styleKey] = style
        end
    end

    for _, entry in ipairs(entries) do
        local tier = ActiveTier(entry.tier, harmful)
        local styleKey = (harmful and "H" or "B") .. tier
        local style = styles[styleKey]
        local styleChanged = styleMoved[styleKey]

        preview.bbfCount = preview.bbfCount + 1
        local button = preview.bbfButtons[preview.bbfCount]
        if not button then
            button = CreateTestButton(preview)
            preview.bbfButtons[preview.bbfCount] = button
        end
        button:Show()

        local w, h = button.bbfWidth, button.bbfHeight
        if styleChanged or button.bbfEntry ~= entry or button.bbfTier ~= tier or not w
            or button.bbfIconGeneration ~= previewIconGeneration then
            button.bbfEntry = entry
            button.bbfTier = tier
            button.bbfIconGeneration = previewIconGeneration
            w, h = StyleTestButton(button, entry, tier, style, sizes, harmful)
            button.bbfWidth, button.bbfHeight = w, h
        end

        local primarySize = vertical and h or w
        local crossSize = vertical and w or h

        if linePrimary > 0 and linePrimary + primarySize > maxLine then
            cursorCross = cursorCross + lineCross + crossGap
            linePrimary, lineCross = 0, 0
        end

        button:ClearAllPoints()
        if vertical then
            button:SetPoint(point, preview, point, dx * cursorCross, dy * linePrimary)
        else
            button:SetPoint(point, preview, point, dx * linePrimary, dy * cursorCross)
        end

        linePrimary = linePrimary + primarySize + primaryGap
        lineCross = math.max(lineCross, crossSize)
    end

    if linePrimary > 0 then
        cursorCross = cursorCross + lineCross
    end
    return cursorCross
end

local function PreviewParent(host)
    local container = host.blockTop or host.buffs or host.debuffs
    return (container and container:GetParent()) or host.frame or UIParent
end

local function EnsurePreview(host)
    local preview = testHosts[host.key]
    if preview then
        preview:SetParent(PreviewParent(host))
        return preview
    end

    preview = CreateFrame("Frame", nil, PreviewParent(host))
    preview:SetSize(1, 1)
    preview.bbfButtons = {}
    preview.bbfStyles = {}
    preview.bbfBaseStrata = preview:GetFrameStrata()

    local space = preview:CreateTexture(nil, "BACKGROUND")
    space:SetColorTexture(0, 1, 0, 0.4)
    preview.bbfSpace = space

    testHosts[host.key] = preview
    return preview
end

local function AnchorPreview(host, preview)
    if host.isPlayer then
        local layout = GetEditModeAuraLayout(host.frame)
        local point = GetPlayerAnchorPoint(layout)
        preview.bbfPoint = point
        preview.bbfDX = layout.addIconsToRight and 1 or -1
        preview.bbfDY = layout.addIconsToTop and 1 or -1
        preview.bbfVertical = not layout.isHorizontal
        preview:ClearAllPoints()
        preview:SetPoint(point, host.frame, point, GetPlayerContainerOffset(host, layout))
        preview:SetScale(layout.iconScale or 1)
        return
    end

    local frame = host.frame
    local buffsOnTop = frame.buffsOnTop == true
    local frameContainer = frame.TargetFrameContainer
    local anchorTo = (frameContainer and frameContainer.FrameTexture) or frame

    local point, relPoint, startY
    if buffsOnTop then
        point, relPoint = "BOTTOMLEFT", "TOPLEFT"
        startY = AURA_MIRRORED_START_Y + S.offsetY
        preview.bbfDY = 1
    else
        point, relPoint = "TOPLEFT", "BOTTOMLEFT"
        startY = AURA_START_Y + S.offsetY
        preview.bbfDY = -1
    end
    preview.bbfPoint = point
    preview.bbfDX = 1
    preview.bbfVertical = false

    local scale = ContainerScale(host)
    preview:ClearAllPoints()
    preview:SetPoint(point, anchorTo, relPoint,
        (AURA_START_X + S.offsetX) / scale, startY / scale)
    preview:SetScale(scale)
end

local function ShouldPreviewHost(host)
    if TestModeActive() then
        return host.isPlayer or (UnitExists(host.unit) and true or false)
    end
    return EditModePreviewsHost(host)
end

local function RefreshTestHost(host)
    if not ShouldPreviewHost(host) then
        local existing = testHosts[host.key]
        if existing then existing:Hide() end
        return
    end

    local preview = EnsurePreview(host)
    AnchorPreview(host, preview)
    preview:SetFrameStrata(preview.bbfBaseStrata or "MEDIUM")

    preview.bbfCount = 0

    local harmfulFirst
    if host.isPlayer then
        harmfulFirst = host.debuffs ~= nil
    else
        harmfulFirst = IsTopBlockHarmful(host)
    end

    local cursorCross = 0
    if host.isPlayer then
        cursorCross = LayoutTestButtons(preview, GetPreviewEntries(host, harmfulFirst), host, harmfulFirst, cursorCross)
    else
        cursorCross = LayoutTestButtons(preview, GetPreviewEntries(host, harmfulFirst), host, harmfulFirst, cursorCross)
        cursorCross = LayoutTestButtons(preview, GetPreviewEntries(host, not harmfulFirst), host, not harmfulFirst,
            cursorCross + S.typeGap)
    end

    for i = preview.bbfCount + 1, #preview.bbfButtons do
        preview.bbfButtons[i]:Hide()
    end

    local space = preview.bbfSpace
    if TestModeActive() and not host.isPlayer then
        local sizes = GetHostSizes(host)
        local vertical = preview.bbfVertical
        local primaryGap = vertical and (host.vGap or S.vGap) or (host.hGap or S.hGap)
        local line = GetMaxLineSize(host, sizes, primaryGap)
        space:ClearAllPoints()
        space:SetPoint(preview.bbfPoint, preview, preview.bbfPoint, 0, 0)
        if vertical then
            space:SetSize(math.max(cursorCross, 1), line)
        else
            space:SetSize(line, math.max(cursorCross, 1))
        end
        space:Show()
    else
        space:Hide()
    end

    preview:Show()
end

local function HideTestPreviews()
    for _, preview in pairs(testHosts) do
        preview:Hide()
    end
end

function BBF.RefreshAuraTestMode()
    if not PreviewIsActive() then
        HideTestPreviews()
        return
    end
    RequestTestAuraSpellData()
    for _, host in pairs(BBF.auraHosts) do
        RefreshTestHost(host)
    end
end

local widthPreviewTimer

local function StopWidthPreview()
    if widthPreviewTimer then
        widthPreviewTimer:Cancel()
        widthPreviewTimer = nil
    end
    widthPreview = false
end

function BBF.SetAuraTestMode(enabled)
    testMode = enabled and true or false
    StopWidthPreview()
    BBF.RefreshAllAuraFrames()
end

function BBF.IsAuraTestMode()
    return testMode
end

local WIDTH_PREVIEW_SECONDS = 2

function BBF.PreviewAuraRowWidth()
    if testMode then return end

    widthPreview = true
    if widthPreviewTimer then widthPreviewTimer:Cancel() end
    widthPreviewTimer = C_Timer.NewTimer(WIDTH_PREVIEW_SECONDS, function()
        widthPreviewTimer = nil
        widthPreview = false
        BBF.RefreshAllAuraFrames()
    end)

    BBF.RefreshAllAuraFrames()
end

local editModeSettingsHooked = false

local function HookEditModeSettings()
    if editModeSettingsHooked then return end

    local settings = EditModeManagerFrame and EditModeManagerFrame.AccountSettings
    if not settings then return end
    editModeSettingsHooked = true

    local function OnEditModeSettingRefreshed()
        if not editModeActive then return end
        BBF.RefreshAllAuraFrames()
    end

    if settings.RefreshBuffsAndDebuffs then
        hooksecurefunc(settings, "RefreshBuffsAndDebuffs", OnEditModeSettingRefreshed)
    end
    if settings.RefreshTargetAndFocus then
        hooksecurefunc(settings, "RefreshTargetAndFocus", OnEditModeSettingRefreshed)
    end
end

EventRegistry:RegisterCallback("EditMode.Enter", function()
    editModeActive = true
    HookEditModeSettings()
    BBF.RefreshAllAuraFrames()
end)

EventRegistry:RegisterCallback("EditMode.Exit", function()
    editModeActive = false
    for _, host in pairs(BBF.auraHosts) do
        host.editModeIconSignature, host.editModeEntries = nil, nil
    end
    BBF.RefreshAllAuraFrames()
end)

local playerBuffsHooked
local hooked = false

local function CreateHost(key, frame, unit, spellbar)
    local host = {
        key = key,
        frame = frame,
        unit = unit,
        spellbar = spellbar,
        styles = {},
    }
    BBF.auraHosts[key] = host

    local parent = frame.TargetFrameContent.TargetFrameContentContextual
    host.spacer = CreateSpacerContainer(host, parent)
    host.blockTop = CreateTypeContainer(host, true, parent)
    host.blockBottom = CreateTypeContainer(host, false, parent)
    host.lastContainer = host.blockBottom

    BBF.AnchorAuraContainer(host)
    CB.SeedContainerAnchor(host)

    AddSpacerGroup(host.spacer)
    AddContainerGroups(host, host.blockTop)
    AddContainerGroups(host, host.blockBottom)

    RefreshHost(host)
    host.spacer:UpdateAllAuras()
    host.blockTop:UpdateAllAuras()
    host.blockBottom:UpdateAllAuras()

    return host
end

local function CreatePlayerHost(key, hostFrame, harmful)
    local host = {
        key = key,
        settingsKey = "player",
        isPlayer = true,
        frame = hostFrame,
        unit = "player",
        styles = {},
    }
    BBF.auraHosts[key] = host

    ReadPlayerEditModeLayout(host)

    if harmful then
        host.debuffs = CreateTypeContainer(host, true, hostFrame)
        host.blockTop, host.blockBottom = host.debuffs, host.debuffs
        AddContainerGroups(host, host.debuffs)
    else
        host.buffs = CreateTypeContainer(host, false, hostFrame)
        host.blockTop, host.blockBottom = host.buffs, host.buffs
        AddContainerGroups(host, host.buffs)

        host.itemEnchantments = true
        host.enchantButtons = {}
        host.enchantStyle = RefreshEnchantStyle(host, host.buffs)

        for _, slot in ipairs({
            AuraContainerItemEnchantmentSlot.MainHand,
            AuraContainerItemEnchantmentSlot.OffHand,
            AuraContainerItemEnchantmentSlot.Ranged,
        }) do
            local button = host.buffs:AddItemEnchantment(slot, {
                hidePermanent = true,
                initializeFrame = function(button)
                    InitAuraButton(button, host.enchantStyle)
                end,
            })
            host.enchantButtons[#host.enchantButtons + 1] = button
        end

        CreateFilteredAuras(host)

        BBF.CreateBuffCollapseButton()
    end

    DisableDefaultPlayerAuras(hostFrame)

    BBF.AnchorPlayerAuraContainer(host)
    BBF.ApplyAuraGroupConfig(host)

    local container = host.buffs or host.debuffs
    container:UpdateAllAuras()

    hooksecurefunc(hostFrame, "UpdateGridLayout", function()
        local layout = GetEditModeAuraLayout(hostFrame)
        local signature = string.format("%s|%s|%s|%s|%s|%s|%s",
            tostring(layout.isHorizontal), tostring(layout.addIconsToRight),
            tostring(layout.addIconsToTop), tostring(layout.iconStride),
            tostring(layout.iconScale), tostring(layout.iconPadding),
            tostring(layout.showDispelType))
        if host.editModeSignature == signature then return end
        host.editModeSignature = signature

        BBF.AnchorPlayerAuraContainer(host)
        BBF.ApplyAuraGroupConfig(host)
        BBF.RestyleAuraButtons()
    end)

    return host
end

function BBF.HookPlayerAndTargetAuras()
    BBF.UpdateUserAuraSettings()
    BBF.HookCastbarAnchoring()

    if auraFilteringOn and not hooked then
        hooked = true

        RefreshSpellLists()
        SuppressAllBlizzardAuras()

        CreateHost("target", TargetFrame, "target", TargetFrameSpellBar)
        CreateHost("focus", FocusFrame, "focus", FocusFrameSpellBar)

        local driver = CreateFrame("Frame")
        driver:RegisterEvent("PLAYER_TARGET_CHANGED")
        driver:RegisterEvent("PLAYER_FOCUS_CHANGED")
        driver:RegisterUnitEvent("UNIT_FACTION", "target", "focus")
        driver:RegisterEvent("PLAYER_REGEN_ENABLED")
        driver:SetScript("OnEvent", function(_, event, unit)
            if event == "PLAYER_REGEN_ENABLED" then
                if restyleQueued then
                    BBF.RestyleAuraButtons()
                end
                for _, h in pairs(BBF.auraHosts) do
                    DisableSpacerMouse(h.spacer)
                end
                return
            end

            local host
            if event == "PLAYER_TARGET_CHANGED" then
                host = BBF.auraHosts.target
            elseif event == "PLAYER_FOCUS_CHANGED" then
                host = BBF.auraHosts.focus
            else
                host = BBF.auraHosts[unit]
            end

            if host then
                RefreshHost(host)
                ForEachContainer(host, UpdateAllAurasIn)
                if PreviewIsActive() then BBF.RefreshAuraTestMode() end
            end
        end)

        hooksecurefunc(TargetFrame, "UpdateAuras", function()
            local host = BBF.auraHosts.target
            BBF.AnchorAuraContainer(host)
            AnchorSpellbar(host)
        end)
        hooksecurefunc(FocusFrame, "UpdateAuras", function()
            local host = BBF.auraHosts.focus
            BBF.AnchorAuraContainer(host)
            AnchorSpellbar(host)
        end)
    end

    if S.playerAurasOn and not playerBuffsHooked then
        playerBuffsHooked = true

        CreatePlayerHost("playerBuffs", BuffFrame, false)
        CreatePlayerHost("playerDebuffs", DebuffFrame, true)

        CVarCallbackRegistry:RegisterCallback("buffDurations", function()
            BBF.UpdateUserAuraSettings()
            BBF.RefreshPlayerAuraFrames()
            BBF.RestyleAuraButtons()
        end, BBF)

        if BBF.BuffFrameHidden then
            BuffFrame:Show()
            BBF.BuffFrameHidden = nil
        end
        if BBF.DebuffFrameHidden then
            DebuffFrame:Show()
            BBF.DebuffFrameHidden = nil
        end
    end
end
