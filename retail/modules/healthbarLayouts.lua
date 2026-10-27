local MEDIA = "Interface\\AddOns\\BetterBlizzFrames\\media\\"
local TARGET_MASK = "UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health-Mask"
local PORTRAIT_OFF_MASK = "interface/hud/uipartyframeportraitoffhealthmask"
local FRAME_MASK = MEDIA .. "masks\\frameMask.png"
local RETAIL_TEX = MEDIA .. "retailTextures\\"
local BIG_RAISE = { reduced = 7.5, big = 12 }
local MANA_SPAN = 11

local TARGET_MINUS_MASK = "UI-HUD-UnitFrame-Target-MinusMob-PortraitOn-Bar-Health-Mask"

local targetLayouts = {
    classic = {
        point = { "TOPLEFT", "LEFT", 26, -1 }, width = 120, height = 9, glowOffset = -7, texts = false,
    },
    classicBig = {
        point = { "TOPLEFT", "LEFT", 26, 19 }, width = 120, height = 29, glowOffset = -7, texts = false, big = true,
        mask = { texture = FRAME_MASK, fit = true },
    },
    noPortrait = {
        point = { "TOPLEFT", "LEFT", 23, 10 }, width = 126, height = 20, glowOffset = -10, texts = false,
        mask = { texture = PORTRAIT_OFF_MASK, x = -35, y = 5, width = 193, height = 30 },
    },
    noPortraitBig = {
        point = { "TOPLEFT", "LEFT", 23, 10 }, width = 126, height = 31, glowOffset = -10, texts = false, big = true, hideMana = true,
        mask = { texture = PORTRAIT_OFF_MASK, x = -35, y = 8, width = 193, height = 48 },
    },
    defaultMinus = {
        point = { "TOPLEFT", "LEFT", 23, 11 }, width = 126, height = 20, glowOffset = -7,
        mask = { atlas = TARGET_MINUS_MASK, atlasSize = true, x = -1, y = 2 },
    },
}

local function StretchedTargetMask(height)
    return { atlas = TARGET_MASK, x = -1, y = height * 0.3, width = 128, height = height * 1.6 }
end

local function BigTexts(y)
    return {
        HealthBarText = { "CENTER", 0, y },
        LeftText = { "LEFT", 2, y },
        RightText = { "RIGHT", -5, y },
        DeadText = { "CENTER", 0, y },
        UnconsciousText = { "CENTER", 0, y },
    }
end

for mode, raise in pairs(BIG_RAISE) do
    local suffix = mode == "reduced" and "Reduced" or ""
    local height = 20 + raise
    for _, inside in ipairs({ false, true }) do
        targetLayouts["defaultBig" .. (inside and "Inside" or "") .. suffix] = {
            point = { "TOPLEFT", "LEFT", 23, 10 + raise }, width = 126, height = height, glowOffset = -7,
            big = true, keepArt = false, reduced = mode == "reduced" or nil, raise = raise,
            mask = StretchedTargetMask(height),
            texts = BigTexts(inside and -6 or 0),
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

local plainNoManaLayout = {
    point = { "TOPLEFT", "LEFT", 23, 10 }, width = 126, height = 20 + MANA_SPAN, glowOffset = -7, hideMana = true, noMana = true,
    mask = StretchedTargetMask(20 + MANA_SPAN),
}
local noManaLayouts = {}

local function NoManaLayout(layout)
    if noManaLayouts[layout] then return noManaLayouts[layout] end
    local copy = {}
    for k, v in pairs(layout) do copy[k] = v end
    copy.height = layout.height + MANA_SPAN
    if layout.big and not layout.reduced then
        local p = layout.point
        copy.point = { p[1], p[2], p[3] - 1, p[4] + 0.5 }
        copy.height = copy.height + 1
        copy.maskAdjust = { left = -1, right = 0.5, top = -0.5, bottom = -0.5 }
    end
    copy.mask = StretchedTargetMask(copy.height)
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

local function TargetStyle(frame)
    local db = BetterBlizzFramesDB
    if db.classicFrames then
        return "classic"
    end
    if (db.noPortraitModes or db.noPortraitPixelBorder) and BBF.HasNoPortrait(frame.unit) then
        return db.noPortraitPixelBorder and "pixel" or "noPortrait"
    end
    return "default"
end

function BBF.GetHealthbarLayout(frame)
    if not IsTargetFrame(frame) then return end
    local style = TargetStyle(frame)
    if style == "pixel" then
        return BBF.PixelBorderMirrorLayout(frame)
    end
    local minus = IsMinus(frame)
    local big = BBF.BigHealthbarOn(frame) and not minus
    if big then
        if style == "default" then
            local reduced = not BBF.BigHealthbarExtraLarge(FrameExtraLargeKey(frame)) and "Reduced" or ""
            local inside = BetterBlizzFramesDB.biggerHealthbarsNameInside and "Inside" or ""
            local layout = targetLayouts["defaultBig" .. inside .. reduced]
            return HideTargetMana(frame) and NoManaLayout(layout) or layout
        end
        if style == "classic" then
            return HideTargetMana(frame) and ClassicNoManaLayout(targetLayouts.classicBig) or targetLayouts.classicBig
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

function BBF.ShiftRegionY(region, shift)
    if not region or region:GetNumPoints() == 0 then return end
    shift = shift or 0
    if not region.bbfShiftHooked then
        region.bbfShiftHooked = true
        hooksecurefunc(region, "SetPoint", function(self)
            if self.bbfShifting or not self.bbfShiftY then return end
            local wanted = self.bbfShiftY
            self.bbfShiftY = nil
            BBF.ShiftRegionY(self, wanted)
        end)
    end
    local old = region.bbfShiftY or 0
    if old == shift then return end
    local point, rel, relPoint, x, y = region:GetPoint(1)
    region.bbfShifting = true
    region:SetPoint(point, rel, relPoint, x, y - old + shift)
    region.bbfShifting = nil
    region.bbfShiftY = shift ~= 0 and shift or nil
end

local function SetNameBackgroundHidden(frame, hidden)
    local reputationColor = frame.TargetFrameContent.TargetFrameContentMain.ReputationColor
    if not reputationColor then return end
    if hidden then
        reputationColor.bbfBigHidden = true
        reputationColor:SetAlpha(0)
    elseif reputationColor.bbfBigHidden then
        reputationColor.bbfBigHidden = nil
        reputationColor:SetAlpha(1)
    end
end

local NAME_BG_ATLAS = "UI-HUD-UnitFrame-Target-PortraitOn-Type"
local NAME_BG_SPLIT = 270 / 300

function BBF.SetAtlasFresh(tex, atlas, flip, width, height)
    local info = C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas)
    if not info or not info.file then
        tex:SetAtlas(atlas, not width)
        if flip then tex:SetTexCoord(1, 0, 0, 1) end
        if width then tex:SetSize(width, height) end
        return
    end
    tex:SetTexture(info.file)
    if flip then
        tex:SetTexCoord(info.rightTexCoord, info.leftTexCoord, info.topTexCoord, info.bottomTexCoord)
    else
        tex:SetTexCoord(info.leftTexCoord, info.rightTexCoord, info.topTexCoord, info.bottomTexCoord)
    end
    tex:SetSize(width or info.width, height or info.height)
end

local function SyncNameBgExtension(rep)
    local ext = rep.bbfNameBgExt
    if not ext then return end
    ext:SetVertexColor(rep:GetVertexColor())
    ext:SetDesaturated(rep:IsDesaturated())
    ext:SetAlpha(rep:GetAlpha())
    ext:SetShown(rep.bbfNameBgBig and rep:IsShown() or false)
end

local function SetBigNameBackground(frame, on)
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
        rep:SetTexture(RETAIL_TEX .. "Target-NameBg-Reduced.png")
        rep:SetTexCoord(0, NAME_BG_SPLIT, 0, 1)
        ext:SetTexture(RETAIL_TEX .. "Target-NameBg-Reduced.png")
        ext:SetTexCoord(NAME_BG_SPLIT, 1, 0, 1)
    elseif rep.bbfNameBgBig then
        rep.bbfNameBgBig = nil
        BBF.SetAtlasFresh(rep, NAME_BG_ATLAS)
    end
    SyncNameBgExtension(rep)
end

local function ArtName(frame, layout)
    if not layout or TargetStyle(frame) ~= "default" then return end
    local noMana = layout.noMana and "-NoMana" or ""
    local shadow = BetterBlizzFramesDB.hideUnitFrameShadow and "-NoShadow" or ""
    if layout.big and layout.keepArt == false then
        local suffix = "-BigHealthbar" .. (layout.reduced and "-Reduced" or "") .. noMana
        return "Target" .. shadow .. suffix, "Target-InCombat" .. suffix
    end
    if layout.noMana then
        return "Target" .. shadow .. noMana, "Target-InCombat" .. noMana
    end
end

local function TargetArt(frame)
    local mirror = BBF.GetHealthbarMirror(frame)
    local art, flash = ArtName(frame, mirror and mirror.layout)
    if art then
        return RETAIL_TEX .. art .. ".png", RETAIL_TEX .. flash .. ".png"
    end
end

local grownLayouts = {}

local function GrownLayout(frame, layout)
    local art = ArtName(frame, layout)
    if not art or not BBF.HasFrameMask(art, "health") then return layout end
    grownLayouts[layout] = grownLayouts[layout] or {}
    local cached = grownLayouts[layout][art]
    if cached then return cached end
    local grow = BBF.FrameMaskGrow(art, "health")
    local copy = {}
    for k, v in pairs(layout) do copy[k] = v end
    copy.width = layout.width + grow
    copy.mask = { artMask = art, adjust = layout.maskAdjust }
    if type(layout.texts) == "table" then
        copy.texts = {}
        for key, spec in pairs(layout.texts) do
            local shift = (key == "RightText" and -grow) or (key == "LeftText" and 0) or -grow / 2
            copy.texts[key] = { spec[1], spec[2] + shift, spec[3] }
        end
    end
    grownLayouts[layout][art] = copy
    return copy
end

local function SetDefaultBigArt(frame)
    local container = frame.TargetFrameContainer
    local frameTexture, flash = container.FrameTexture, container.Flash
    if frameTexture.bbfBigArtChanging then return end
    frameTexture.bbfBigArtChanging = true
    local art, flashArt = TargetArt(frame)
    if art then
        frameTexture.bbfBigArt = true
        frameTexture:SetTexture(art)
        frameTexture:SetTexCoord(0, 1, 0, 1)
        if flash then
            flash:SetTexture(flashArt)
            flash:SetTexCoord(0, 1, 0, 1)
        end
    elseif frameTexture.bbfBigArt then
        frameTexture.bbfBigArt = nil
        local classification = UnitExists(frame.unit) and UnitClassification(frame.unit)
        if classification == "minus" then
            frameTexture:SetAtlas("UI-HUD-UnitFrame-Target-MinusMob-PortraitOn", TextureKitConstants.UseAtlasSize)
            if flash then flash:SetAtlas("UI-HUD-UnitFrame-Target-MinusMob-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize) end
        else
            if classification == "rare" or classification == "rareelite" then
                frameTexture:SetAtlas("UI-HUD-UnitFrame-Target-Rare-PortraitOn", TextureKitConstants.UseAtlasSize)
            else
                frameTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn", TextureKitConstants.UseAtlasSize)
            end
            if flash then flash:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize) end
        end
    end
    frameTexture.bbfBigArtChanging = false
end

function BBF.UpdateHealthbarMirror(frame)
    if not IsTargetFrame(frame) then return end
    if BBF.IsMiniFrame(frame) then
        BBF.DisableHealthbarMirror(frame)
        return
    end
    NormalMinusHealthArt(frame)
    local layout = BBF.GetHealthbarLayout(frame)
    if layout then
        layout = GrownLayout(frame, layout)
        BBF.EnableHealthbarMirror(frame, layout)
    else
        BBF.DisableHealthbarMirror(frame)
    end
    SetManaHidden(frame, layout and layout.hideMana)
    SetNameBackgroundHidden(frame, layout and layout.big and not layout.reduced)
    SetBigNameBackground(frame, layout and layout.big and layout.reduced and ArtName(frame, layout) and true or false)
    local raise = layout and layout.raise or 0
    local contextual = frame.TargetFrameContent.TargetFrameContentContextual
    BBF.ShiftRegionY(frame.TargetFrameContent.TargetFrameContentMain.ReputationColor, raise)
    BBF.ShiftRegionY(contextual and contextual.LeaderIcon, raise)
    BBF.ShiftRegionY(contextual and contextual.GuideIcon, raise)
    SetDefaultBigArt(frame)
    BBF.ApplyTextArea(frame)
    if BetterBlizzFramesDB.addUnitFrameBgTexture and BBF.AddBackgroundTextureToUnitFrames then
        BBF.AddBackgroundTextureToUnitFrames(frame)
    end
end

function BBF.UpdateTargetPlayerArt(frame)
    SetDefaultBigArt(frame)
end

local hooked = {}
local function HookFrame(frame)
    if hooked[frame] then return end
    hooked[frame] = true
    hooksecurefunc(frame, "CheckClassification", BBF.UpdateHealthbarMirror)
    local container = frame.TargetFrameContainer
    local function Reapply() SetDefaultBigArt(frame) end
    hooksecurefunc(container.FrameTexture, "SetAtlas", Reapply)
    if container.Flash then
        hooksecurefunc(container.Flash, "SetAtlas", Reapply)
    end
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
