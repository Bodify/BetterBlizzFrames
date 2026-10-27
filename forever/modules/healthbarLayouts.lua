local function RetailOn(unit)
    return BBF.RetailTexturesOn and BBF.RetailTexturesOn(unit) or false
end

local MEDIA = "Interface\\AddOns\\BetterBlizzFrames\\media\\"
local TARGET_MASK = "UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health-Mask"
local PLAYER_MASK = "UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Mask"
local PORTRAIT_OFF_MASK = "interface/hud/uipartyframeportraitoffhealthmask"
local FRAME_MASK = MEDIA .. "masks\\frameMask.png"
local PLAYER_ART = MEDIA .. "foreverTextures\\Player-PortraitOn"
local RETAIL_TEX = MEDIA .. "retailTextures\\"
local RETAIL_RAISE = { reduced = 7.5, big = 12 }

local targetLayouts = {
    classic = {
        point = { "TOPLEFT", "LEFT", 26, -1 }, width = 120, height = 9, glowOffset = -7, texts = false,
    },
    classicBig = {
        point = { "TOPLEFT", "LEFT", 26, 19 }, width = 120, height = 29, glowOffset = -7, texts = false, big = true,
        mask = { texture = FRAME_MASK, fit = true },
    },
    classicBigNoHD = {
        point = { "TOPLEFT", "LEFT", 26, 19 }, width = 120, height = 29, glowOffset = -7, texts = false, big = true,
        mask = { texture = FRAME_MASK, fit = true },
    },
    noPortrait = {
        point = { "TOPLEFT", "LEFT", 23, 10 }, width = 126, height = 20, glowOffset = -10, texts = false,
        mask = { texture = PORTRAIT_OFF_MASK, x = -35, y = 5, width = 193, height = 30 },
    },
    noPortraitBig = {
        point = { "TOPLEFT", "LEFT", 23, 10 }, width = 126, height = 31, glowOffset = -10, texts = false, big = true, hideMana = true,
        mask = { atlas = PLAYER_MASK, x = -2, y = 19, width = 130.5, height = 70 },
    },
    defaultMinus = {
        point = { "TOPLEFT", "LEFT", 21, 9 }, width = 126, height = 20, glowOffset = -7,
        mask = { atlas = TARGET_MASK, atlasSize = true, x = -1, y = 6 },
    },
    defaultBig = {
        point = { "TOPLEFT", "LEFT", 21, 24 }, width = 126, height = 32.5, glowOffset = -7, big = true, keepArt = false, manaMaskWidth = 258.5,
        mask = { atlas = PLAYER_MASK, x = -2, y = 22, width = 129.5, height = 78 },
        texts = {
            HealthBarText = { "CENTER", 1, -1.5 },
            LeftText = { "LEFT", 3, -1.5 },
            RightText = { "RIGHT", -5, -1.5 },
            DeadText = { "CENTER", 0, -1 },
            UnconsciousText = { "CENTER", 0, -1 },
        },
    },
    defaultBigInside = {
        point = { "TOPLEFT", "LEFT", 21, 24 }, width = 126, height = 32.5, glowOffset = -7, big = true, keepArt = false, manaMaskWidth = 258.5,
        mask = { atlas = PLAYER_MASK, x = -2, y = 22, width = 129.5, height = 78 },
        texts = {
            HealthBarText = { "CENTER", 1, -10 },
            LeftText = { "LEFT", 3, -10 },
            RightText = { "RIGHT", -5, -10 },
            DeadText = { "CENTER", 0, -9 },
            UnconsciousText = { "CENTER", 0, -9 },
        },
    },
    defaultBigReduced = {
        point = { "TOPLEFT", "LEFT", 21, 16 }, width = 126, height = 25, glowOffset = -7, big = true, keepArt = false, reduced = true, manaMaskWidth = 258.5,
        mask = { atlas = PLAYER_MASK, x = -2, y = 17.5, width = 129.5, height = 60 },
        texts = {
            HealthBarText = { "CENTER", 1, -1 },
            LeftText = { "LEFT", 3, -1 },
            RightText = { "RIGHT", -5, -1 },
            DeadText = { "CENTER", 0, -1 },
            UnconsciousText = { "CENTER", 0, -1 },
        },
    },
    defaultBigInsideReduced = {
        point = { "TOPLEFT", "LEFT", 21, 16 }, width = 126, height = 25, glowOffset = -7, big = true, keepArt = false, reduced = true, manaMaskWidth = 258.5,
        mask = { atlas = PLAYER_MASK, x = -2, y = 17.5, width = 129.5, height = 60 },
        texts = {
            HealthBarText = { "CENTER", 1, -6.5 },
            LeftText = { "LEFT", 3, -6.5 },
            RightText = { "RIGHT", -5, -6.5 },
            DeadText = { "CENTER", 0, -6 },
            UnconsciousText = { "CENTER", 0, -6 },
        },
    },
}

local function StretchedTargetMask(height)
    return { atlas = TARGET_MASK, x = -1, y = height * 0.3, width = 128, height = height * 1.6 }
end

local function RetailBigTexts(y)
    return {
        HealthBarText = { "CENTER", 0, y },
        LeftText = { "LEFT", 2, y },
        RightText = { "RIGHT", -5, y },
        DeadText = { "CENTER", 0, y },
        UnconsciousText = { "CENTER", 0, y },
    }
end

local RETAIL_TEXTS = {
    HealthBarText = { "CENTER", 1, -0.5 },
    LeftText = { "LEFT", 3, -0.5 },
    RightText = { "RIGHT", -5, -0.5 },
    DeadText = { "CENTER", 0, -0.5 },
    UnconsciousText = { "CENTER", 0, -0.5 },
}

local retailLayouts = {
    retail = {
        point = { "TOPLEFT", "LEFT", 23, 10 }, width = 126, height = 20, glowOffset = -7, texts = RETAIL_TEXTS,
        mask = { atlas = TARGET_MASK, atlasSize = true, x = -1, y = 6 },
    },
    retailMinus = {
        point = { "TOPLEFT", "LEFT", 23, 11 }, width = 125, height = 12, glowOffset = -7, texts = RETAIL_TEXTS,
        mask = StretchedTargetMask(12),
    },
    retailNoMana = {
        point = { "TOPLEFT", "LEFT", 23, 10 }, width = 126, height = 31, glowOffset = -7, hideMana = true, noMana = true, texts = RETAIL_TEXTS,
        mask = StretchedTargetMask(31),
    },
}

for mode, raise in pairs(RETAIL_RAISE) do
    local suffix = mode == "reduced" and "Reduced" or ""
    local height = 20 + raise
    for _, inside in ipairs({ false, true }) do
        retailLayouts["retailBig" .. (inside and "Inside" or "") .. suffix] = {
            point = { "TOPLEFT", "LEFT", 23, 10 + raise }, width = 126, height = height, glowOffset = -7,
            big = true, keepArt = false, reduced = mode == "reduced" or nil, raise = raise,
            mask = StretchedTargetMask(height),
            texts = RetailBigTexts(inside and -6 or 0),
        }
    end
end

local bigClassicArt = {
    ["Interface\\TargetingFrame\\UI-TargetingFrame"] = MEDIA .. "classicTextures\\UI-TargetingFrame-Retail.png",
    ["Interface\\TargetingFrame\\UI-FocusFrame-Large"] = MEDIA .. "classicTextures\\UI-TargetingFrame-NoLevel-Retail.png",
    ["Interface\\TargetingFrame\\UI-TargetingFrame-Elite"] = MEDIA .. "classicTextures\\UI-TargetingFrame-Elite-Retail.png",
    ["Interface\\TargetingFrame\\UI-TargetingFrame-Rare"] = MEDIA .. "classicTextures\\UI-TargetingFrame-Rare-Retail.png",
    ["Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite"] = MEDIA .. "classicTextures\\UI-TargetingFrame-Rare-Elite-Retail.png",
    [MEDIA .. "classicTextures\\UI-TargetingFrame-Elite-NoLevel.png"] = MEDIA .. "classicTextures\\UI-TargetingFrame-Elite-NoLevel-Retail.png",
    [MEDIA .. "classicTextures\\UI-TargetingFrame-Rare-NoLevel.png"] = MEDIA .. "classicTextures\\UI-TargetingFrame-Rare-NoLevel-Retail.png",
    [MEDIA .. "classicTextures\\UI-TargetingFrame-Rare-Elite-NoLevel.png"] = MEDIA .. "classicTextures\\UI-TargetingFrame-Rare-Elite-NoLevel-Retail.png",
}

local bigClassicNoManaArt = {
    ["Interface\\TargetingFrame\\UI-TargetingFrame"] = MEDIA .. "classicTextures\\UI-TargetingFrame-Retail-NoMana.png",
    ["Interface\\TargetingFrame\\UI-FocusFrame-Large"] = MEDIA .. "classicTextures\\UI-TargetingFrame-NoLevel-Retail-NoMana.png",
    ["Interface\\TargetingFrame\\UI-TargetingFrame-Elite"] = MEDIA .. "classicTextures\\NoManas\\UI-TargetingFrame-Elite-Big-NoMana.png",
    ["Interface\\TargetingFrame\\UI-TargetingFrame-Rare"] = MEDIA .. "classicTextures\\NoManas\\UI-TargetingFrame-Rare-Big-NoMana.png",
    ["Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite"] = MEDIA .. "classicTextures\\NoManas\\UI-TargetingFrame-Rare-Elite-Big-NoMana.png",
    [MEDIA .. "classicTextures\\UI-TargetingFrame-Elite-NoLevel.png"] = MEDIA .. "classicTextures\\NoManas\\UI-TargetingFrame-Elite-NoLevel-Big-NoMana.png",
    [MEDIA .. "classicTextures\\UI-TargetingFrame-Rare-NoLevel.png"] = MEDIA .. "classicTextures\\NoManas\\UI-TargetingFrame-Rare-NoLevel-Big-NoMana.png",
    [MEDIA .. "classicTextures\\UI-TargetingFrame-Rare-Elite-NoLevel.png"] = MEDIA .. "classicTextures\\NoManas\\UI-TargetingFrame-Rare-Elite-NoLevel-Big-NoMana.png",
}

local classicNoManaArt = {
    ["Interface\\TargetingFrame\\UI-TargetingFrame"] = MEDIA .. "classicTextures\\NoManas\\UI-TargetingFrame-NoMana.png",
    ["Interface\\TargetingFrame\\UI-FocusFrame-Large"] = MEDIA .. "classicTextures\\NoManas\\UI-TargetingFrame-NoLevel-NoMana.png",
    ["Interface\\TargetingFrame\\UI-TargetingFrame-Elite"] = MEDIA .. "classicTextures\\NoManas\\UI-TargetingFrame-Elite-NoMana.png",
    ["Interface\\TargetingFrame\\UI-TargetingFrame-Rare"] = MEDIA .. "classicTextures\\NoManas\\UI-TargetingFrame-Rare-NoMana.png",
    ["Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite"] = MEDIA .. "classicTextures\\NoManas\\UI-TargetingFrame-Rare-Elite-NoMana.png",
    [MEDIA .. "classicTextures\\UI-TargetingFrame-Elite-NoLevel.png"] = MEDIA .. "classicTextures\\NoManas\\UI-TargetingFrame-Elite-NoLevel-NoMana.png",
    [MEDIA .. "classicTextures\\UI-TargetingFrame-Rare-NoLevel.png"] = MEDIA .. "classicTextures\\NoManas\\UI-TargetingFrame-Rare-NoLevel-NoMana.png",
    [MEDIA .. "classicTextures\\UI-TargetingFrame-Rare-Elite-NoLevel.png"] = MEDIA .. "classicTextures\\NoManas\\UI-TargetingFrame-Rare-Elite-NoLevel-NoMana.png",
}

local function IsTargetFrame(frame)
    return frame == TargetFrame or frame == FocusFrame
end

function BBF.BigHealthbarOn(frame)
    local db = BetterBlizzFramesDB
    if not BBF.BigHealthbarsOn() or BBF.IsMiniFrame(frame) then return false end
    if frame == TargetFrame then return db.bigHealthbarTarget and true or false end
    if frame == FocusFrame then return db.bigHealthbarFocus and true or false end
    if frame == PlayerFrame then return BBF.BigPlayerHealthbar() and true or false end
    return false
end

function BBF.BigHealthbarExtraLarge(key)
    return BetterBlizzFramesDB["bigHealthbarExtraLarge" .. key] and true or false
end

local function FrameExtraLargeKey(frame)
    if frame == TargetFrame then return "Target" end
    if frame == FocusFrame then return "Focus" end
    if frame == PlayerFrame then return "Player" end
end

local function MinusAsNormal(unit)
    local db = BetterBlizzFramesDB
    if db.classicFrames then return true end
    return (db.noPortraitModes or db.noPortraitPixelBorder) and BBF.HasNoPortrait(unit) or false
end

local function IsMinus(frame)
    return UnitExists(frame.unit) and UnitClassification(frame.unit) == "minus" and not MinusAsNormal(frame.unit)
end

local function NormalMinusHealthArt(frame)
    if not UnitExists(frame.unit) or UnitClassification(frame.unit) ~= "minus" or not MinusAsNormal(frame.unit) then return end
    local container = frame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer
    container.HealthBar.HealthBarTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health", TextureKitConstants.UseAtlasSize)
    container.TempMaxHealthLoss.TempMaxHealthLossTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-TempHPLoss", TextureKitConstants.UseAtlasSize)
end

local function HideTargetMana(frame)
    local db = BetterBlizzFramesDB
    if frame == TargetFrame then return db.hideUnitFrameTargetMana and true or false end
    if frame == FocusFrame then return db.hideUnitFrameFocusMana and true or false end
    return false
end

-- Hide Target/Focus Mana on the portrait frame: NoMana art, health grown down over the mana slot.
-- The stock target mask is 1.6x its bar with the opening 0.1875 down from its top, so growing it 1.6px per bar px
-- and raising it by that 0.1875 keeps the opening's top in place and moves its bottom down with the bar.
local MANA_SPAN = 11
local MASK_PER_PX = 1.6
local MASK_TOP = 0.1875
-- Without Big Healthbar: same as the PlayerFrame (bar 3 higher and 38 tall, player mask 60 at 11).
local plainNoManaLayout = {
    point = { "TOPLEFT", "LEFT", 20, 12 }, width = 127, height = 38, glowOffset = -7, hideMana = true, noMana = true,
    mask = { atlas = "UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Mask", x = -2, y = 11, width = 130, height = 60 },
}
local noManaLayouts = {}

local function NoManaLayout(layout)
    if noManaLayouts[layout] then return noManaLayouts[layout] end
    local copy = {}
    for k, v in pairs(layout) do copy[k] = v end
    local mask = {}
    for k, v in pairs(layout.mask) do mask[k] = v end
    copy.height = layout.height + MANA_SPAN
    mask.height = mask.height + MANA_SPAN * MASK_PER_PX
    mask.y = mask.y + MANA_SPAN * MASK_PER_PX * MASK_TOP
    if layout.reduced then
        mask.height, mask.y = 84, 24
    else
        mask.height, mask.y = 105, 30
    end
    copy.mask = mask
    copy.hideMana = true
    copy.noMana = true
    noManaLayouts[layout] = copy
    return copy
end

local CLASSIC_MANA_SPAN = 12
local CLASSIC_BIG_MANA_SPAN = 11
local classicNoManaLayouts = {}

local function ClassicNoManaLayout(layout)
    if classicNoManaLayouts[layout] then return classicNoManaLayouts[layout] end
    local copy = {}
    for k, v in pairs(layout) do copy[k] = v end
    copy.height = layout.height + (layout.big and CLASSIC_BIG_MANA_SPAN or CLASSIC_MANA_SPAN)
    copy.hideMana = true
    copy.noMana = true
    classicNoManaLayouts[layout] = copy
    return copy
end

local retailNoManaLayouts = {}

local function RetailNoManaLayout(layout)
    if retailNoManaLayouts[layout] then return retailNoManaLayouts[layout] end
    local copy = {}
    for k, v in pairs(layout) do copy[k] = v end
    copy.height = layout.height + MANA_SPAN
    copy.mask = StretchedTargetMask(copy.height)
    copy.hideMana = true
    copy.noMana = true
    retailNoManaLayouts[layout] = copy
    return copy
end

local function TargetStyle(frame)
    local db = BetterBlizzFramesDB
    if db.classicFrames then
        return "classic"
    end
    if (db.noPortraitModes or db.noPortraitPixelBorder) and BBF.HasNoPortrait(frame.unit) then
        return db.noPortraitPixelBorder and "pixel" or "noPortrait"
    end
    if RetailOn(frame.unit) then
        return "retail"
    end
    return "default"
end

local function RetailLayout(frame, minus, big)
    if big then
        local reduced = not BBF.BigHealthbarExtraLarge(FrameExtraLargeKey(frame)) and "Reduced" or ""
        local inside = BetterBlizzFramesDB.biggerHealthbarsNameInside and "Inside" or ""
        local layout = retailLayouts["retailBig" .. inside .. reduced]
        return HideTargetMana(frame) and RetailNoManaLayout(layout) or layout
    end
    if minus then return retailLayouts.retailMinus end
    return HideTargetMana(frame) and retailLayouts.retailNoMana or retailLayouts.retail
end

function BBF.GetHealthbarLayout(frame)
    if not IsTargetFrame(frame) then return end
    local style = TargetStyle(frame)
    if style == "pixel" then
        return BBF.PixelBorderMirrorLayout(frame)
    end
    local minus = IsMinus(frame)
    local big = BBF.BigHealthbarOn(frame) and not minus
    if style == "retail" then
        return RetailLayout(frame, minus, big)
    end
    if big then
        if style == "classic" then
            local layout = BBF.ClassicHDTexturesActive() and targetLayouts.classicBig or targetLayouts.classicBigNoHD
            return HideTargetMana(frame) and ClassicNoManaLayout(layout) or layout
        end
        if style == "default" then
            local reduced = not BBF.BigHealthbarExtraLarge(FrameExtraLargeKey(frame)) and "Reduced" or ""
            local inside = BetterBlizzFramesDB.biggerHealthbarsNameInside and "Inside" or ""
            local layout = targetLayouts["defaultBig" .. inside .. reduced]
            return HideTargetMana(frame) and NoManaLayout(layout) or layout
        end
        return targetLayouts[style .. "Big"]
    end
    if style == "default" then
        if HideTargetMana(frame) and not minus then
            return plainNoManaLayout
        end
        return BBF.BigHealthbarOn(frame) and targetLayouts.defaultMinus or nil
    end
    if style == "classic" and HideTargetMana(frame) then
        return ClassicNoManaLayout(targetLayouts.classic)
    end
    return targetLayouts[style]
end

function BBF.TargetNameBorderRemoved(frame)
    if not BetterBlizzFramesDB.removeNameBorder or not IsTargetFrame(frame) then return false end
    return TargetStyle(frame) == "default" and not BBF.BigHealthbarOn(frame) and not IsMinus(frame)
end

function BBF.BigHealthbarReduced(frame)
    local db = BetterBlizzFramesDB
    local key = FrameExtraLargeKey(frame)
    if not key or BBF.BigHealthbarExtraLarge(key) or not BBF.BigHealthbarOn(frame) then return false end
    if frame == PlayerFrame then
        return not (db.classicFrames or BBF.HasNoPortrait("player"))
    end
    local layout = BBF.GetHealthbarLayout(frame)
    return layout and layout.reduced or false
end

function BBF.IsBigHealthbarActive(frame)
    local mirror = BBF.GetHealthbarMirror(frame)
    return mirror and mirror.layout and mirror.layout.big or false
end

function BBF.ClassicBigTargetTexture(frame, path)
    if BBF.IsBigHealthbarActive(frame) then
        local art = BBF.GetHealthbarMirror(frame).layout.noMana and bigClassicNoManaArt or bigClassicArt
        return art[path] or path
    end
    local mirror = BBF.GetHealthbarMirror(frame)
    if mirror and mirror.layout and mirror.layout.noMana then
        return classicNoManaArt[path] or path
    end
    return path
end

local function SetManaHidden(frame, hidden)
    local manaBar = frame.TargetFrameContent.TargetFrameContentMain.ManaBar
    if hidden then
        manaBar.bbfBigHidden = true
        manaBar:SetAlpha(0)
        if manaBar.LeftText then manaBar.LeftText:SetAlpha(0) end
        if manaBar.RightText then manaBar.RightText:SetAlpha(0) end
        if manaBar.ManaBarText then manaBar.ManaBarText:SetAlpha(0) end
        return
    end
    if not manaBar.bbfBigHidden then return end
    manaBar.bbfBigHidden = nil
    manaBar:SetAlpha(1)
    if manaBar.LeftText then manaBar.LeftText:SetAlpha(1) end
    if manaBar.RightText then manaBar.RightText:SetAlpha(1) end
    if manaBar.ManaBarText then manaBar.ManaBarText:SetAlpha(1) end
    if BBF.UpdateNoPortraitManaVisibility then
        BBF.UpdateNoPortraitManaVisibility()
    end
end

local function SetManaMaskWidth(frame, width)
    local mask = frame.TargetFrameContent.TargetFrameContentMain.ManaBar.ManaBarMask
    if not mask then return end
    if width then
        mask.bbfBaseWidth = mask.bbfBaseWidth or mask:GetWidth()
        mask:SetWidth(width)
    elseif mask.bbfBaseWidth then
        mask:SetWidth(mask.bbfBaseWidth)
        mask.bbfBaseWidth = nil
    end
end

local function KeepNameBackgroundHidden(reputationColor)
    if reputationColor.bbfBigHidden and not reputationColor.bbfKeepHidden and reputationColor:GetAlpha() ~= 0 then
        reputationColor.bbfKeepHidden = true
        reputationColor:SetAlpha(0)
        reputationColor.bbfKeepHidden = nil
    end
end

local function SetNameBackgroundHidden(frame, hidden)
    local reputationColor = frame.TargetFrameContent.TargetFrameContentMain.ReputationColor
    if not reputationColor then return end
    if hidden then
        reputationColor.bbfBigHidden = true
        if not reputationColor.bbfHideHooked then
            reputationColor.bbfHideHooked = true
            for _, method in ipairs({ "SetAlpha", "Show", "SetShown", "SetAtlas", "SetTexture", "SetVertexColor", "SetDesaturated" }) do
                hooksecurefunc(reputationColor, method, KeepNameBackgroundHidden)
            end
        end
        KeepNameBackgroundHidden(reputationColor)
    elseif reputationColor.bbfBigHidden then
        reputationColor.bbfBigHidden = nil
        reputationColor:SetAlpha(1)
    end
end

local function DefaultBigActive(frame)
    local mirror = BBF.GetHealthbarMirror(frame)
    return mirror and mirror.layout and mirror.layout.big and mirror.layout.keepArt == false
end

local function TargetPlayerArt(frame)
    local mirror = BBF.GetHealthbarMirror(frame)
    local noMana = mirror and mirror.layout and mirror.layout.noMana and "-NoMana" or ""
    if DefaultBigActive(frame) then
        local suffix = mirror.layout.reduced and "-Reduced" or ""
        return PLAYER_ART .. "-BigHealthbar" .. suffix .. noMana .. ".png", PLAYER_ART .. "-InCombat-BigHealthbar" .. suffix .. ".png", false, PLAYER_ART .. "-Status-Classic" .. suffix .. ".png"
    end
    if TargetStyle(frame) == "default" and not IsMinus(frame) then
        if BetterBlizzFramesDB.removeNameBorder then
            return PLAYER_ART .. "-NoNameBg" .. noMana .. ".png", PLAYER_ART .. "-InCombat-NoNameBg.png", true, PLAYER_ART .. "-Status-Classic-NoNameBg.png"
        end
        return PLAYER_ART .. noMana .. ".png", PLAYER_ART .. "-InCombat.png", false, PLAYER_ART .. "-Status-Classic.png"
    end
end

local CLASSIC_GLOW_PAD = 5

local function ClearClassicGlow(flash)
    if not flash.bbfClassicGlow then return end
    flash.bbfClassicGlow = nil
    flash:SetBlendMode("BLEND")
end

local NAME_BG_SPLIT = 270 / 300

local function SyncNameBgExtension(rep)
    local ext = rep.bbfNameBgExt
    if not ext then return end
    ext:SetVertexColor(rep:GetVertexColor())
    ext:SetDesaturated(rep:IsDesaturated())
    ext:SetAlpha(rep:GetAlpha())
    ext:SetShown(rep.bbfNameBgBig and rep:IsShown() or false)
end

local function SetRetailBigNameBackground(frame, on)
    local rep = frame.TargetFrameContent.TargetFrameContentMain.ReputationColor
    if not rep then return end
    if on then
        local ext = rep.bbfNameBgExt
        if not ext then
            ext = rep:GetParent():CreateTexture(nil, "BACKGROUND")
            ext:SetPoint("TOPLEFT", rep, "TOPRIGHT")
            ext:SetPoint("BOTTOMLEFT", rep, "BOTTOMRIGHT")
            ext:SetWidth(15)
            rep.bbfNameBgExt = ext
            local function sync() SyncNameBgExtension(rep) end
            for _, method in ipairs({ "SetVertexColor", "SetDesaturated", "SetAlpha", "Show", "Hide", "SetShown" }) do
                hooksecurefunc(rep, method, sync)
            end
        end
        rep.bbfNameBgBig = true
        rep:SetTexture(BBF.RetailFile("Target-NameBg-Reduced"))
        rep:SetTexCoord(0, NAME_BG_SPLIT, 0, 1)
        ext:SetTexture(BBF.RetailFile("Target-NameBg-Reduced"))
        ext:SetTexCoord(NAME_BG_SPLIT, 1, 0, 1)
    elseif rep.bbfNameBgBig then
        rep.bbfNameBgBig = nil
        BBF.SetRetailArt(rep, "Target-PortraitOn-Type")
    end
    SyncNameBgExtension(rep)
end

local function RetailArtName(layout)
    if not layout then return end
    local noMana = layout.noMana and "-NoMana" or ""
    if layout.big and layout.keepArt == false then
        local suffix = "-BigHealthbar" .. (layout.reduced and "-Reduced" or "") .. noMana
        return "Target" .. suffix, "Target-InCombat" .. suffix
    end
    if layout.noMana then
        return "Target" .. noMana, "Target-InCombat" .. noMana
    end
end

local slotLayouts = {}

local function RetailSlotLayout(frame, base)
    local tex = frame.TargetFrameContainer.FrameTexture
    local point, width, height = BBF.RetailSlotPoint(tex, "health")
    if not point then return base end
    local _, _, art = BBF.RetailSlotInfo(tex)
    slotLayouts[frame] = slotLayouts[frame] or {}
    local key = tostring(base) .. art
    local layout = slotLayouts[frame][key]
    if not layout then
        layout = {}
        for k, v in pairs(base) do layout[k] = v end
        layout.relativeTo = tex
        layout.mask = { retailSlot = true }
        slotLayouts[frame][key] = layout
    end
    layout.point, layout.width, layout.height = point, width, height
    return layout
end

local function SetRetailTargetArt(frame, layout)
    local container = frame.TargetFrameContainer
    local frameTexture, flash, portrait = container.FrameTexture, container.Flash, container.Portrait
    if frameTexture.bbfArtChanging then return end
    frameTexture.bbfArtChanging = true
    if frameTexture.bbfPlayerArt then
        frameTexture.bbfPlayerArt = nil
        frameTexture:ClearAllPoints()
        frameTexture:SetPoint("CENTER", container, "CENTER")
        portrait:SetSize(58, 58)
        portrait:ClearAllPoints()
        portrait:SetPoint("TOPRIGHT", container, "TOPRIGHT", -26, -19)
    end
    ClearClassicGlow(flash)
    flash:ClearAllPoints()
    flash:SetPoint("CENTER", container, "CENTER", 0, 2)
    if not layout then
        local mirror = BBF.GetHealthbarMirror(frame)
        layout = mirror and mirror.layout
    end
    local art, flashArt = RetailArtName(layout)
    if art then
        frameTexture.bbfBigArt = true
        frameTexture:SetTexture(RETAIL_TEX .. art .. ".png")
        frameTexture:SetTexCoord(0, 1, 0, 1)
        frameTexture:SetSize(192, 67)
        flash:SetTexture(RETAIL_TEX .. flashArt .. ".png")
        flash:SetTexCoord(0, 1, 0, 1)
        flash:SetSize(188, 67)
    elseif frameTexture.bbfBigArt or not frameTexture.bbfRetailArt then
        frameTexture.bbfBigArt = nil
        local classification = UnitExists(frame.unit) and UnitClassification(frame.unit)
        if classification == "minus" then
            frameTexture:SetAtlas("UI-HUD-UnitFrame-Target-MinusMob-PortraitOn", TextureKitConstants.UseAtlasSize)
            flash:SetAtlas("UI-HUD-UnitFrame-Target-MinusMob-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize)
        else
            if classification == "rare" or classification == "rareelite" then
                frameTexture:SetAtlas("UI-HUD-UnitFrame-Target-Rare-PortraitOn", TextureKitConstants.UseAtlasSize)
            else
                frameTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn", TextureKitConstants.UseAtlasSize)
            end
            flash:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize)
        end
    end
    frameTexture.bbfArtChanging = false
end

local function UpdateRetailTargetDecor(frame, layout)
    SetNameBackgroundHidden(frame, layout and layout.big and not layout.reduced)
    SetRetailBigNameBackground(frame, layout and layout.big and layout.reduced and RetailArtName(layout) and true or false)
    local raise = layout and layout.raise or 0
    BBF.ShiftRegionY(frame.TargetFrameContent.TargetFrameContentMain.ReputationColor, raise)
end

local function SetTargetPlayerArt(frame)
    if TargetStyle(frame) == "retail" then
        SetRetailTargetArt(frame)
        return
    end
    local container = frame.TargetFrameContainer
    local frameTexture, flash, portrait = container.FrameTexture, container.Flash, container.Portrait
    if frameTexture.bbfArtChanging then return end
    frameTexture.bbfArtChanging = true
    local art, flashArt, noBorder, glowArt = TargetPlayerArt(frame)
    local mirror = BBF.GetHealthbarMirror(frame)
    local db = BetterBlizzFramesDB
    local nameBgTexture = db[frame.unit .. "NameBgRetail"] or db[frame.unit .. "NameBgClassic"]
    SetNameBackgroundHidden(frame, (noBorder and nameBgTexture) or (mirror and mirror.layout and mirror.layout.big))
    if art then
        frameTexture.bbfPlayerArt = true
        frameTexture:SetTexture(art)
        frameTexture:SetTexCoord(1, 0, 0, 1)
        frameTexture:SetSize(198, 71)
        frameTexture:ClearAllPoints()
        frameTexture:SetPoint("CENTER", container, "CENTER", 0.5, 2)
        flash:ClearAllPoints()
        if db.classicCombatGlow then
            flash.bbfClassicGlow = true
            flash:SetTexture(glowArt)
            flash:SetBlendMode("ADD")
            flash:SetPoint("TOPLEFT", frameTexture, "TOPLEFT", -CLASSIC_GLOW_PAD, CLASSIC_GLOW_PAD)
            flash:SetPoint("BOTTOMRIGHT", frameTexture, "BOTTOMRIGHT", CLASSIC_GLOW_PAD, -CLASSIC_GLOW_PAD)
        else
            ClearClassicGlow(flash)
            flash:SetTexture(flashArt)
            flash:SetAllPoints(frameTexture)
        end
        flash:SetTexCoord(1, 0, 0, 1)
        portrait:SetSize(60, 60)
        portrait:ClearAllPoints()
        portrait:SetPoint("TOPRIGHT", container, "TOPRIGHT", -24, -16.5)
    elseif frameTexture.bbfPlayerArt then
        frameTexture.bbfPlayerArt = nil
        ClearClassicGlow(flash)
        local classification = UnitExists(frame.unit) and UnitClassification(frame.unit)
        if classification == "minus" then
            frameTexture:SetAtlas("UI-HUD-UnitFrame-Target-MinusMob-PortraitOn", TextureKitConstants.UseAtlasSize)
            flash:SetAtlas("UI-HUD-UnitFrame-Target-MinusMob-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize)
        else
            if classification == "rare" or classification == "rareelite" then
                frameTexture:SetAtlas("UI-HUD-UnitFrame-Target-Rare-PortraitOn", TextureKitConstants.UseAtlasSize)
            else
                frameTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn", TextureKitConstants.UseAtlasSize)
            end
            flash:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize)
        end
        frameTexture:ClearAllPoints()
        frameTexture:SetPoint("CENTER", container, "CENTER")
        flash:ClearAllPoints()
        flash:SetPoint("CENTER", container, "CENTER", 0, 2)
        portrait:SetSize(58, 58)
        portrait:ClearAllPoints()
        portrait:SetPoint("TOPRIGHT", container, "TOPRIGHT", -26, -19)
    end
    frameTexture.bbfArtChanging = false
end

local function UpdateRetailMirror(frame)
    local base = BBF.GetHealthbarLayout(frame)
    SetRetailTargetArt(frame, base)
    local layout = RetailSlotLayout(frame, base)
    layout.texts = BBF.TextAreaAnchors(frame) or base.texts
    BBF.EnableHealthbarMirror(frame, layout)
    SetManaHidden(frame, layout.hideMana)
    UpdateRetailTargetDecor(frame, layout)
    BBF.UpdateTargetHealthMask(frame)
    BBF.ApplyTextArea(frame)
end

function BBF.UpdateHealthbarMirror(frame)
    if not IsTargetFrame(frame) then return end
    if BBF.IsMiniFrame(frame) then
        BBF.DisableHealthbarMirror(frame)
        return
    end
    NormalMinusHealthArt(frame)
    if TargetStyle(frame) == "retail" then
        UpdateRetailMirror(frame)
    else
        local layout = BBF.GetHealthbarLayout(frame)
        if layout then
            BBF.EnableHealthbarMirror(frame, layout)
        else
            BBF.DisableHealthbarMirror(frame)
        end
        SetManaHidden(frame, layout and layout.hideMana)
        SetManaMaskWidth(frame, layout and layout.manaMaskWidth)
        SetTargetPlayerArt(frame)
    end
    if BetterBlizzFramesDB.addUnitFrameBgTexture and BBF.AddBackgroundTextureToUnitFrames then
        BBF.AddBackgroundTextureToUnitFrames(frame)
    end
end

local artHooked = {}
local function HookArt(frame)
    if artHooked[frame] then return end
    artHooked[frame] = true
    local container = frame.TargetFrameContainer
    local function Reapply() SetTargetPlayerArt(frame) end
    hooksecurefunc(container.FrameTexture, "SetAtlas", Reapply)
    hooksecurefunc(container.Flash, "SetAtlas", Reapply)
end

function BBF.UpdateTargetPlayerArt(frame)
    HookArt(frame)
    SetTargetPlayerArt(frame)
end

local hooked = {}
local function HookFrame(frame)
    if hooked[frame] then return end
    hooked[frame] = true
    hooksecurefunc(frame, "CheckClassification", BBF.UpdateHealthbarMirror)
    HookArt(frame)
end

function BBF.HealthbarMirrors()
    for _, frame in ipairs({ TargetFrame, FocusFrame }) do
        if BBF.IsMiniFrame(frame) then
            BBF.DisableHealthbarMirror(frame)
        elseif TargetStyle(frame) ~= "default" or BBF.BigHealthbarOn(frame) or HideTargetMana(frame) or BBF.GetHealthbarMirror(frame) then
            HookFrame(frame)
        end
        if hooked[frame] then
            BBF.UpdateHealthbarMirror(frame)
        end
    end
end

function BBF.UpdateBigHealthbars()
    local db = BetterBlizzFramesDB
    if InCombatLockdown() then
        BBF.RunAfterCombat(BBF.UpdateBigHealthbars)
        return
    end
    BBF.HealthbarMirrors()
    if not (db.bigHealthbarTarget or db.bigHealthbarFocus) then return end
    if db.classicFrames or db.noPortraitModes or db.noPortraitPixelBorder then
        BBF.ShowPopup("BBF_CONFIRM_RELOAD")
    end
end

function BBF.UpdateTargetManaHidden()
    if InCombatLockdown() then
        BBF.RunAfterCombat(BBF.UpdateTargetManaHidden)
        return
    end
    BBF.HealthbarMirrors()
    for _, frame in ipairs({ TargetFrame, FocusFrame }) do
        local classic = frame.ClassicFrame
        if classic and classic.OnCheckClassification and TargetStyle(frame) == "classic" then
            classic.OnCheckClassification(frame)
        end
    end
end
