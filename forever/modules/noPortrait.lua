local noPortraitUnitKeys = {
    player = "noPortraitPlayer",
    target = "noPortraitTarget",
    focus = "noPortraitFocus",
    pet = "noPortraitPet",
    party = "noPortraitParty",
}

local noPortraitEliteAtlas = {
    elite = "nameplates-icon-elite-gold",
    worldboss = "nameplates-icon-elite-gold",
    rareelite = "nameplates-icon-elite-silver",
    rare = "nameplates-icon-elite-silver",
}

local function SetBossDragonAtlas(texture, classification)
    texture:SetAtlas(noPortraitEliteAtlas[classification] or "nameplates-icon-elite-gold")
end

local function SetManaTextParent(text, parent)
    if BetterBlizzFramesDB.hideAllManabarText then
        text.bbfOriginalParent = parent
        parent = BBF.hiddenFrame
    end
    text:SetParent(parent)
end

function BBF.HasNoPortrait(unit)
    local db = BetterBlizzFramesDB
    if not db.noPortraitModes and not db.noPortraitPixelBorder then return false end
    if type(unit) == "string" and unit:find("^party") then unit = "party" end
    local key = noPortraitUnitKeys[unit]
    return not key or db[key] ~= false
end

function BBF.NoPortraitOnUnitFrames()
    return BBF.HasNoPortrait("player") or BBF.HasNoPortrait("target") or BBF.HasNoPortrait("focus") or BBF.HasNoPortrait("pet")
end

local function NoPortraitBigToT(frame)
    local db = BetterBlizzFramesDB
    if not (BBF.BigHealthbarsOn() and db.bigHealthbarToT) or db.classicFrames then return false end
    return BBF.HasNoPortrait(frame == FocusFrame and "focus" or "target")
end

local function NoPortraitBigParty()
    local db = BetterBlizzFramesDB
    return BBF.BigHealthbarsOn() and db.bigHealthbarParty and BBF.HasNoPortrait("party")
        and not db.classicFrames and true or false
end

local function HideTotMana(frame)
    local db = BetterBlizzFramesDB
    if db.hideUnitFrameTotMana or NoPortraitBigToT(frame) then return true end
    if frame == FocusFrame then return db.hideUnitFrameFocusMana end
    return db.hideUnitFrameTargetMana
end

local function NoPortraitBigPet()
    local db = BetterBlizzFramesDB
    return BBF.BigHealthbarsOn() and db.bigHealthbarPet and BBF.HasNoPortrait("pet")
        and not db.classicFrames and not db.noPortraitPixelBorder and true or false
end

local function HidePetMana()
    local db = BetterBlizzFramesDB
    return db.hideUnitFramePetMana or db.hideUnitFramePlayerMana or NoPortraitBigPet()
end

local function SetXYPoint(frame, xOffset, yOffset)
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
    frame:SetPoint(point, relativeTo, relativePoint, xOffset or xOfs, yOffset or yOfs)
end

local function PlaceNoPortraitPetHealth()
    if BetterBlizzFramesDB.noPortraitPixelBorder then return end
    if InCombatLockdown() then
        BBF.RunAfterCombat(PlaceNoPortraitPetHealth)
        return
    end
    local big = NoPortraitBigPet()
    PetFrameHealthBar:SetSize(65, big and 23 or 16)
    PetFrameHealthBar:ClearAllPoints()
    PetFrameHealthBar:SetPoint("TOPRIGHT", -19, -10)
    if big then
        PetFrameHealthBarMask:SetTexture("interface/hud/uipartyframeportraitoffhealthmask")
        PetFrameHealthBarMask:SetSize(98, 36)
        SetXYPoint(PetFrameHealthBarMask, -17, 6.5)
    else
        PetFrameHealthBarMask:SetAtlas("Cast_Standard_BarMask")
        PetFrameHealthBarMask:SetSize(70, 15)
        SetXYPoint(PetFrameHealthBarMask, -7, 1)
    end
end

local totHpDefaultMask = "UI-HUD-UnitFrame-Party-PortraitOn-Bar-Health-Mask"
local totManaDefaultMask = "UI-HUD-UnitFrame-Party-PortraitOn-Bar-Mana-Mask"
local totArtDefaultTex = "UI-HUD-UnitFrame-TargetofTarget-PortraitOn"
local totArtNoManaTex = "Interface\\AddOns\\BetterBlizzFrames\\media\\foreverTextures\\TargetofTarget-PortraitOn-NoMana.png"
local totArtReducedTex = "Interface\\AddOns\\BetterBlizzFrames\\media\\foreverTextures\\TargetofTarget-PortraitOn-BigHealthbar-Reduced"
local totArtBigTex = "Interface\\AddOns\\BetterBlizzFrames\\media\\foreverTextures\\TargetofTarget-PortraitOn-BigHealthbar"
local totArtNameUnderTex = "Interface\\AddOns\\BetterBlizzFrames\\media\\foreverTextures\\TargetofTarget-PortraitOn-NameBelow-Lower.png"
local totArtNameUnderNoManaTex = "Interface\\AddOns\\BetterBlizzFrames\\media\\foreverTextures\\TargetofTarget-PortraitOn-NameBelow-Lower-NoMana.png"
local totArtNoBorderTex = "Interface\\AddOns\\BetterBlizzFrames\\media\\foreverTextures\\TargetofTarget-PortraitOn-NoNameBg.png"
local totArtNoBorderNoManaTex = "Interface\\AddOns\\BetterBlizzFrames\\media\\foreverTextures\\TargetofTarget-PortraitOn-NoNameBg-NoMana.png"
local totFlashNoBorderTex = "Interface\\AddOns\\BetterBlizzFrames\\media\\foreverTextures\\TargetofTarget-PortraitOn-InCombat-NoNameBg.png"
local bigArtTex = { reduced = totArtReducedTex, big = totArtBigTex }
local bigHealthHeight = { reduced = 13, big = 23 }
local bigHealthMask = { reduced = { 29, 8 }, big = { 55, 16 } }
local TOT_MANA_SPAN = 8 -- mana bar height + gap; a no-mana health bar grows down by this

-- Stretched target health mask for ToT/Pet health bars that are taller than the stock mask covers.
function BBF.SetStretchedTotHealthMask(healthBar, mask, height, maskHeight, maskY, maskWidth, maskX)
    maskHeight = maskHeight or height * 2.6 - 5
    mask:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health-Mask")
    mask:SetSize(maskWidth or 73, maskHeight)
    mask:ClearAllPoints()
    mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", maskX or -1, maskY or (maskHeight - height) / 2)
end

-- Hide ToT Mana: health grows 9 and ends at -12.5; the plain (no Big Healthbar) mask is hand-tuned.
local TOT_NOMANA_GROW = 9
local TOT_NOMANA_BOTTOM = -12.5
function BBF.SetTotNoManaMask(healthBar, mode)
    local height = healthBar:GetHeight()
    if not height or issecretvalue(height) then return end
    if mode == "big" then
        BBF.SetStretchedTotHealthMask(healthBar, healthBar.HealthBarMask, height, 77)
    elseif mode then
        BBF.SetStretchedTotHealthMask(healthBar, healthBar.HealthBarMask, height)
    else
        BBF.SetStretchedTotHealthMask(healthBar, healthBar.HealthBarMask, height, 43, 12)
    end
end

local function NoManaArtNoBorder()
    if (BBF.RetailTexturesOn and BBF.RetailTexturesOn()) then return false end
    local db = BetterBlizzFramesDB
    return db.removeNameBorder or BBF.BigHealthbarsOn()
end

local function ApplyTotArtTexture(tex, hideMana, bigMode, noBorderTex, noBorderNoManaTex)
    if tex.bbfChangingTex then return end
    tex.bbfChangingTex = true
    if bigMode then
        tex:SetTexture(bigArtTex[bigMode] .. (hideMana and "-NoMana" or "") .. ".png")
        tex:SetTexCoord(0, 1, 0, 1)
    elseif hideMana then
        tex:SetTexture(NoManaArtNoBorder() and noBorderNoManaTex or totArtNoManaTex)
        tex:SetTexCoord(0, 1, 0, 1)
    elseif (BetterBlizzFramesDB.removeNameBorder and not (BBF.RetailTexturesOn and BBF.RetailTexturesOn())) then
        tex:SetTexture(noBorderTex)
        tex:SetTexCoord(0, 1, 0, 1)
    else
        tex:SetAtlas(totArtDefaultTex, true)
    end
    tex.bbfChangingTex = nil
end

local function SetNoBorderFlash(flash, art, on, atlas, relativeTo, x, y)
    if on then
        flash:SetTexture(totFlashNoBorderTex)
        flash:SetTexCoord(0, 1, 0, 1)
        flash:SetSize(120, 49)
        flash:ClearAllPoints()
        flash:SetPoint("TOPLEFT", art, "TOPLEFT")
        flash.bbfNoBorderFlash = true
    elseif flash.bbfNoBorderFlash then
        flash.bbfNoBorderFlash = nil
        flash:SetAtlas(atlas, TextureKitConstants.UseAtlasSize)
        flash:ClearAllPoints()
        flash:SetPoint("TOPLEFT", relativeTo, "TOPLEFT", x, y)
    end
end

function BBF.UpdatePetFrameTexture()
    local db = BetterBlizzFramesDB
    if db.classicFrames then return end
    if not PetFrameTexture then return end
    if BBF.HasNoPortrait("pet") then return end
    local bigMode = BBF.PetBigMode()
    ApplyTotArtTexture(PetFrameTexture, db.hideUnitFramePetMana, bigMode, totArtNoBorderTex, totArtNoBorderNoManaTex)
    if PetFrameFlash then
        SetNoBorderFlash(PetFrameFlash, PetFrameTexture, not bigMode and ((BetterBlizzFramesDB.removeNameBorder and not (BBF.RetailTexturesOn and BBF.RetailTexturesOn())) or (db.hideUnitFramePetMana and NoManaArtNoBorder())),
            "UI-HUD-UnitFrame-TargetofTarget-PortraitOn-InCombat", PetFrame, 0, 0)
    end
    if not PetFrameTexture.bbfHookedTex then
        PetFrameTexture.bbfHookedTex = true
        hooksecurefunc(PetFrameTexture, "SetAtlas", function()
            BBF.UpdatePetFrameTexture()
        end)
    end
end

local function TotNameUnderOn(unit)
    local db = BetterBlizzFramesDB
    return db[unit == "target" and "targetToTNameUnder" or "focusToTNameUnder"] and not db.classicFrames and not BBF.HasNoPortrait(unit) and true or false
end
BBF.ClassicToTActive = TotNameUnderOn

function BBF.ClassicToTNoMana(unit)
    local db = BetterBlizzFramesDB
    return TotNameUnderOn(unit) and (db.hideUnitFrameTotMana or (BBF.BigHealthbarsOn() and db.bigHealthbarToT)) and true or false
end

local function PlaceClassicToTArt(totFrame, tex, on)
    if not on and not totFrame.bbfClassicToT then return end
    if InCombatLockdown() then return end
    tex:ClearAllPoints()
    tex:SetPoint("CENTER", totFrame, "CENTER", 0, on and -5 or 0)
    if totFrame.Portrait then
        totFrame.Portrait:ClearAllPoints()
        totFrame.Portrait:SetPoint("TOPLEFT", totFrame, "TOPLEFT", 5, on and -10 or -5)
    end
    totFrame.bbfClassicToT = on or nil
end

local function PlaceDefaultToTPortrait(totFrame, classicOn)
    if InCombatLockdown() or not totFrame.Portrait or not totFrame.Name then return end
    if not classicOn then
        totFrame.Portrait:ClearAllPoints()
        totFrame.Portrait:SetPoint("TOPLEFT", totFrame, "TOPLEFT", 5, -4)
    end
    totFrame.Name:ClearAllPoints()
    totFrame.Name:SetPoint("TOPLEFT", totFrame.Portrait, "TOPRIGHT", 2, classicOn and -1 or -2)
end

local function UpdateOneTotTexture(frame, unit)
    local totFrame = frame and frame.totFrame
    local tex = totFrame and totFrame.FrameTexture
    if not tex then return end
    if BBF.HasNoPortrait(unit) then return end
    if TotNameUnderOn(unit) then
        if not tex.bbfChangingTex then
            tex.bbfChangingTex = true
            tex:SetTexture(BBF.ClassicToTNoMana(unit) and totArtNameUnderNoManaTex or totArtNameUnderTex)
            tex:SetTexCoord(0, 1, 0, 1)
            tex.bbfChangingTex = nil
        end
    else
        ApplyTotArtTexture(tex, BetterBlizzFramesDB.hideUnitFrameTotMana, BBF.TotBigMode(unit), totArtNoBorderTex, totArtNoBorderNoManaTex)
    end
    PlaceClassicToTArt(totFrame, tex, TotNameUnderOn(unit))
    PlaceDefaultToTPortrait(totFrame, TotNameUnderOn(unit))
    if not tex.bbfHookedTex then
        tex.bbfHookedTex = true
        hooksecurefunc(tex, "SetAtlas", function()
            BBF.UpdateTotFrameTexture()
        end)
    end
end

local function SetTotManaAlpha(totFrame, alpha)
    local manaBar = totFrame.ManaBar
    manaBar:SetAlpha(alpha)
    for _, key in ipairs({ "TextString", "LeftText", "RightText" }) do
        if manaBar[key] then manaBar[key]:SetAlpha(alpha) end
    end
end

function BBF.RaiseNameAboveBar(frame, bar, raise)
    local name = frame and frame.bbfName
    if not name then return end
    if raise then
        if not frame.bbfNameHolder then
            frame.bbfNameHolder = CreateFrame("Frame", nil, frame)
            frame.bbfNameHolder:SetAllPoints(frame)
        end
        frame.bbfNameHolder:SetFrameLevel(bar:GetFrameLevel() + 5)
        frame.bbfNameOrigParent = frame.bbfNameOrigParent or name:GetParent()
        name:SetParent(frame.bbfNameHolder)
    elseif frame.bbfNameOrigParent then
        name:SetParent(frame.bbfNameOrigParent)
    end
end

function BBF.TotBigMode(unit)
    local db = BetterBlizzFramesDB
    if not (BBF.BigHealthbarsOn() and db.bigHealthbarToT)
        or db.classicFrames or BBF.HasNoPortrait(unit) then
        return nil
    end
    return not db.bigHealthbarExtraLargeToT and "reduced" or "big"
end

function BBF.TotReducedActive(unit)
    return BBF.TotBigMode(unit) == "reduced"
end

local function UpdateOneTotReduced(frame, unit)
    local totFrame = frame and frame.totFrame
    if not totFrame or not totFrame.HealthBar or not totFrame.ManaBar then return end
    if BetterBlizzFramesDB.noPortraitPixelBorder and BBF.HasNoPortrait(unit) then
        totFrame.bbfReducedTot = nil
        if BBF.ApplyPixelBorderLayout then
            BBF.ApplyPixelBorderLayout(totFrame)
        end
        return
    end
    local mode = BBF.TotBigMode(unit)
    local db = BetterBlizzFramesDB
    local healthBar, manaBar = totFrame.HealthBar, totFrame.ManaBar
    local classicNoMana = BBF.ClassicToTNoMana(unit)
    if (BBF.RetailTexturesOn and BBF.RetailTexturesOn(unit)) then
        if InCombatLockdown() then return end
        local hideMana = db.hideUnitFrameTotMana or classicNoMana
        SetTotManaAlpha(totFrame, hideMana and 0 or 1)
        totFrame.bbfTotManaHidden = hideMana or nil
        BBF.FitRetailBars(totFrame.FrameTexture, healthBar, healthBar.HealthBarMask, not hideMana and manaBar, manaBar.ManaBarMask)
        BBF.RaiseNameAboveBar(totFrame, healthBar, (mode or classicNoMana) and true or false)
        totFrame.bbfReducedTot = true
        totFrame.bbfClassicNoMana = nil
        BBF.ApplyTextArea(totFrame)
        BBF.PlaceTotStatusTexts()
        return
    end
    if classicNoMana or totFrame.bbfClassicNoMana then
        if InCombatLockdown() then return end
        if classicNoMana then
            healthBar:ClearAllPoints()
            healthBar:SetSize(70, 18)
            healthBar:SetPoint("BOTTOMRIGHT", totFrame, "RIGHT", -5, -12)
            SetTotManaAlpha(totFrame, 0)
            BBF.RaiseNameAboveBar(totFrame, healthBar, true)
            totFrame.bbfClassicNoMana = true
            totFrame.bbfReducedTot = not db.hideUnitFrameTotMana or nil
            BBF.UpdateTotTextureMasks()
            return
        end
        totFrame.bbfClassicNoMana = nil
        if not db.hideUnitFrameTotMana then
            SetTotManaAlpha(totFrame, 1)
        end
    end
    if (db.classicFrames or BBF.HasNoPortrait(unit)) and not totFrame.bbfReducedTot then return end
    if InCombatLockdown() then return end
    local hideMana = db.hideUnitFrameTotMana and not db.classicFrames and not BBF.HasNoPortrait(unit)
    local manaMask = manaBar.ManaBarMask
    local ownManaMask = manaMask
    local height = mode and bigHealthHeight[mode] or 10
    healthBar:ClearAllPoints()
    manaBar:ClearAllPoints()
    if hideMana then
        -- the no-mana art has one box down to the old mana bottom
        healthBar:SetSize(70, height + TOT_NOMANA_GROW)
        healthBar:SetPoint("BOTTOMRIGHT", totFrame, "RIGHT", -5, TOT_NOMANA_BOTTOM)
        manaBar:SetSize(77, 7)
        manaBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", -4, -1)
        SetTotManaAlpha(totFrame, 0)
        totFrame.bbfTotManaHidden = true
        if not BBF.UnitFrameTextureOnFor("tot") then
            BBF.SetTotNoManaMask(healthBar, mode)
        end
        BBF.RaiseNameAboveBar(totFrame, healthBar, mode and true or false)
        totFrame.bbfReducedTot = true
        BBF.UpdateTotTextureMasks()
        return
    end
    if totFrame.bbfTotManaHidden then
        totFrame.bbfTotManaHidden = nil
        SetTotManaAlpha(totFrame, 1)
    end
    if mode then
        healthBar:SetSize(70, height)
        healthBar:SetPoint("BOTTOMRIGHT", totFrame, "RIGHT", -5, -4)
        manaBar:SetSize(77, 7)
        manaBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", -4, -1)
        if ownManaMask then
            manaMask:SetSize(125.5, 16)
            manaMask:ClearAllPoints()
            manaMask:SetPoint("TOPLEFT", manaBar, "TOPLEFT", -24, 4)
        end
        BBF.RaiseNameAboveBar(totFrame, healthBar, true)
        totFrame.bbfReducedTot = true
    else
        healthBar:SetSize(70, 11)
        healthBar:SetPoint("BOTTOMRIGHT", totFrame, "RIGHT", -5, -4)
        manaBar:SetSize(76, 7)
        manaBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", -3, -1)
        if ownManaMask then
            manaMask:SetAtlas(totManaDefaultMask)
            manaMask:SetSize(126, 16)
            manaMask:ClearAllPoints()
            manaMask:SetPoint("TOPLEFT", manaBar, "TOPLEFT", -25, 4)
        end
        local mask = healthBar.HealthBarMask
        mask:SetAtlas(totHpDefaultMask, true)
        mask:ClearAllPoints()
        mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -28, 3)
        BBF.RaiseNameAboveBar(totFrame, healthBar, false)
        totFrame.bbfReducedTot = nil
    end
    BBF.UpdateTotTextureMasks()
end

local partyArtDefaultAtlas = "UI-HUD-UnitFrame-Party-PortraitOn"
local partyArtHDAtlas = "UI-HUD-UnitFrame-CharacterFrameOnParty-PortraitOn"

local function PartyHDArtOn()
    local db = BetterBlizzFramesDB
    return not (db.classicFrames or BBF.HasNoPortrait("party"))
end

function BBF.PartyBigMode()
    local db = BetterBlizzFramesDB
    if not (BBF.BigHealthbarsOn() and db.bigHealthbarParty) or db.classicFrames
        or BBF.HasNoPortrait("party") then
        return nil
    end
    return not db.bigHealthbarExtraLargeParty and "reduced" or "big"
end

function BBF.PartyReducedActive()
    return BBF.PartyBigMode() == "reduced"
end

local function PartyNameY()
    return (LOCALE_zhCN or LOCALE_zhTW) and -6 or -7
end

local function PartyBarTextY()
    return LOCALE_koKR and 1 or LOCALE_zhCN and 2 or 0
end

local function PlacePartyName(frame, x, y, width, justify)
    justify = justify or "CENTER"
    local box = BBF.NameAreaBox and BBF.NameAreaBox(frame)
    for _, name in ipairs({ frame.Name, frame.bbfName }) do
        name:ClearAllPoints()
        if box then
            name:SetPoint("TOPLEFT", box, "TOPLEFT")
            name:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT")
        else
            name:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
            name:SetWidth(width)
        end
        if name:GetJustifyH() ~= justify then
            name:SetJustifyH(justify)
            local text = name:GetText()
            name:SetText("")
            name:SetText(text)
        end
    end
end

local function PlacePartyHealthTexts(frame, y, manaY, centerX)
    if BBF.ApplyTextArea and BBF.ApplyTextArea(frame) then return end
    centerX = centerX or 0
    local container = frame.HealthBarContainer
    y = y + PartyBarTextY()
    manaY = (manaY or 0) + PartyBarTextY()
    if container.CenterText then
        container.CenterText:ClearAllPoints()
        container.CenterText:SetPoint("CENTER", container, "CENTER", centerX, y)
    end
    local manaBar = frame.ManaBar
    if manaBar and manaBar.CenterText then
        manaBar.CenterText:ClearAllPoints()
        manaBar.CenterText:SetPoint("CENTER", manaBar, "CENTER", 0.5 + centerX, manaY)
    end
    if manaBar and manaBar.LeftText then
        manaBar.LeftText:ClearAllPoints()
        manaBar.LeftText:SetPoint("LEFT", manaBar, "LEFT", 4, manaY)
    end
    if container.LeftText then
        container.LeftText:ClearAllPoints()
        container.LeftText:SetPoint("LEFT", container, "LEFT", 0, y)
    end
    frame.bbfPartyHealthTextY = y
end

local function RaisePartyName(frame, raise)
    BBF.RaiseNameAboveBar(frame, frame.HealthBarContainer, raise)
end

local function PlacePartyLeaderIcon(frame, big)
    local overlay = frame.PartyMemberOverlay
    local icon = overlay and overlay.LeaderIcon
    if not icon then return end
    icon:ClearAllPoints()
    icon:SetPoint("BOTTOM", overlay, "TOP", big and -52 or -10, big and -14 or -6)
end

local PARTY_DEFAULT_MASK = "UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Mask"
local PARTY_DEFAULT_MANA_MASK = "UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health-Mask"

local function PlaceRetailPartyBars(frame)
    local container, manaBar = frame.HealthBarContainer, frame.ManaBar
    local bars = BBF.PartyBars(frame)
    if not BBF.FitRetailBars(frame.Texture, container, container.HealthBarMask, not frame.bbfPartyNoMana and manaBar, manaBar.ManaBarMask, bars) then return end
    bars:SetAllPoints(container.HealthBar, container)
end

local function PlacePartyManaBar(frame, bars, manaBar, mask)
    bars:SetSize(manaBar, 78, 10)
    bars:SetPoint(manaBar, "TOPLEFT", frame, "TOPLEFT", 42, -30)
    if mask then
        mask:SetAtlas(PARTY_DEFAULT_MANA_MASK)
        mask:SetSize(74, 12)
        mask:ClearAllPoints()
        mask:SetPoint("TOPLEFT", manaBar, "TOPLEFT", 2, 1)
    end
end

local function PlacePartyDefaultMana(frame)
    if (BBF.RetailTexturesOn and BBF.RetailTexturesOn("party")) then
        PlaceRetailPartyBars(frame)
        return
    end
    local healthMask = frame.HealthBarContainer and frame.HealthBarContainer.HealthBarMask
    if healthMask then
        healthMask:SetAtlas(PARTY_DEFAULT_MASK)
        healthMask:SetSize(73.5, BBF.UnitFrameTextureOnFor("party") and 23 or 22.5)
        healthMask:ClearAllPoints()
        healthMask:SetPoint("TOPLEFT", frame.HealthBarContainer, "TOPLEFT", -2, 6)
    end
    local manaBar = frame.ManaBar
    local bars = BBF.PartyBars(frame)
    bars:ClearAllPoints(manaBar)
    PlacePartyManaBar(frame, bars, manaBar, manaBar.ManaBarMask)
end

local function PinRightText(text, bar, x, y)
    text:ClearAllPoints()
    text:SetPoint("RIGHT", bar, "RIGHT", x, y)
    text:SetPoint("LEFT", bar, "LEFT", -20, y)
    text:SetJustifyH("RIGHT")
end

local function PlacePartyRightTexts(frame, healthX, manaX, manaY)
    if BBF.ApplyTextArea and BBF.ApplyTextArea(frame) then return end
    local container, manaBar = frame.HealthBarContainer, frame.ManaBar
    local y = PartyBarTextY()
    if container.RightText then
        PinRightText(container.RightText, container, healthX, frame.bbfPartyHealthTextY or y)
    end
    if manaBar.RightText then
        PinRightText(manaBar.RightText, manaBar, manaX, y + (manaY or 0))
    end
end

local function PartyManaHidden()
    local db = BetterBlizzFramesDB
    return db.hideDefaultPartyFramesMana and not (db.classicFrames or BBF.HasNoPortrait("party")) and true or false
end

local function SetPartyNoBorderFlash(frame, on)
    if not frame.Flash then return end
    local hd = PartyHDArtOn()
    SetNoBorderFlash(frame.Flash, frame.Texture, on, hd and partyArtHDAtlas .. "-InCombat" or "ui-hud-unitframe-party-portraiton-incombat", frame, 1, -1)
    if hd and not on then
        frame.Flash:SetAtlas(partyArtHDAtlas .. "-InCombat", TextureKitConstants.UseAtlasSize)
    end
    local status = frame.PartyMemberOverlay and frame.PartyMemberOverlay.Status
    if status and hd then
        status:SetAtlas(partyArtHDAtlas .. "-Status", TextureKitConstants.UseAtlasSize)
    end
end

local function SetPartyPlainArt(frame)
    local db = BetterBlizzFramesDB
    if (BetterBlizzFramesDB.removeNameBorder and not (BBF.RetailTexturesOn and BBF.RetailTexturesOn())) and not (db.classicFrames or BBF.HasNoPortrait("party")) then
        frame.Texture:SetTexture(totArtNoBorderTex)
        frame.Texture:SetSize(120, 49)
        frame.bbfPartyNoBorder = true
    else
        frame.Texture:SetAtlas(PartyHDArtOn() and partyArtHDAtlas or partyArtDefaultAtlas, true)
        frame.bbfPartyNoBorder = nil
    end
    SetPartyNoBorderFlash(frame, frame.bbfPartyNoBorder)
end

local function SetPartyManaShown(frame, shown)
    local manaBar = frame.ManaBar
    local alpha = shown and 1 or 0
    manaBar:SetAlpha(alpha)
    for _, key in ipairs({ "TextString", "LeftText", "RightText" }) do
        if manaBar[key] then manaBar[key]:SetAlpha(alpha) end
    end
end

local function UpdateOnePartyReduced(frame)
    if BetterBlizzFramesDB.classicFrames then return end
    if not frame or not frame.HealthBarContainer or not frame.ManaBar then return end
    if frame.state ~= "player" or not frame.Texture:IsShown() then return end
    local mode = BBF.PartyBigMode()
    local hideMana = PartyManaHidden()
    if not mode and not hideMana and not frame.bbfBigParty and not frame.bbfPartyNoMana then
        if (BetterBlizzFramesDB.removeNameBorder and not (BBF.RetailTexturesOn and BBF.RetailTexturesOn())) or frame.bbfPartyNoBorder or PartyHDArtOn() then
            SetPartyPlainArt(frame)
        end
        return
    end
    SetPartyNoBorderFlash(frame, false)
    local container, manaBar = frame.HealthBarContainer, frame.ManaBar
    local healthBar, healthMask, manaMask = container.HealthBar, container.HealthBarMask, manaBar.ManaBarMask
    local bars = BBF.PartyBars(frame)
    bars:ClearAllPoints(container)
    bars:ClearAllPoints(manaBar)
    healthMask:ClearAllPoints()
    manaMask:ClearAllPoints()
    if hideMana or frame.bbfPartyNoMana then
        SetPartyManaShown(frame, not hideMana)
    end
    frame.bbfPartyNoMana = hideMana or nil
    if mode then
        local height = bigHealthHeight[mode]
        frame.Texture:SetTexture(bigArtTex[mode] .. (hideMana and "-NoMana" or "") .. ".png")
        frame.Texture:SetSize(120, 49)
        bars:SetPoint(container, "TOPLEFT", frame, "TOPLEFT", 46, -30.5 + height)
        if hideMana then
            -- the no-mana art has one box down to the old mana bottom
            height = height + TOT_MANA_SPAN
            BBF.SetStretchedTotHealthMask(container, healthMask, height)
        else
            healthMask:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health-Mask")
            healthMask:SetSize(73, bigHealthMask[mode][1])
            healthMask:SetPoint("TOPLEFT", container, "TOPLEFT", -1, bigHealthMask[mode][2])
        end
        bars:SetSize(container, 70, height)
        bars:SetHeight(healthBar, height)
        PlacePartyManaBar(frame, bars, manaBar, manaMask)
        frame.bbfReducedParty = mode == "reduced" or nil
        local inside = mode == "big" and BetterBlizzFramesDB.biggerHealthbarsNameInside
        if mode == "reduced" then
            frame.bbfPartyNameWidth = 70
            PlacePartyName(frame, 46, PartyNameY() + 3, 70)
        elseif inside then
            frame.bbfPartyNameWidth = 66
            PlacePartyName(frame, 48, -8, 66, "CENTER")
        else
            frame.bbfPartyNameWidth = 73
            PlacePartyName(frame, 44, PartyNameY() + 14, 73, "CENTER")
        end
        RaisePartyName(frame, true)
        PlacePartyLeaderIcon(frame, true)
        PlacePartyHealthTexts(frame, inside and -5 or 0, nil, 1)
        PlacePartyRightTexts(frame, -1, -5)
        frame.bbfBigParty = true
    else
        bars:SetPoint(container, "TOPLEFT", frame, "TOPLEFT", 47, -20)
        if hideMana then
            -- same art and tuning as Hide ToT Mana
            local noBorder = (BetterBlizzFramesDB.removeNameBorder and not (BBF.RetailTexturesOn and BBF.RetailTexturesOn()))
            frame.Texture:SetTexture(noBorder and totArtNoBorderNoManaTex or totArtNoManaTex)
            frame.Texture:SetSize(120, 49)
            SetPartyNoBorderFlash(frame, noBorder)
            PlacePartyDefaultMana(frame)
            bars:ClearAllPoints(container)
            bars:SetPoint(container, "TOPLEFT", frame, "TOPLEFT", 46, -20)
            bars:SetSize(container, 71, 19)
            bars:SetSize(healthBar, 71, 19)
            BBF.SetStretchedTotHealthMask(container, healthMask, 19, 43, 12, 74.5, -2.5)
        else
            SetPartyPlainArt(frame)
            bars:SetSize(container, 70, 11)
            bars:SetHeight(healthBar, 11)
            PlacePartyDefaultMana(frame)
        end
        frame.bbfReducedParty = nil
        frame.bbfPartyNameWidth = nil
        PlacePartyName(frame, 48, PartyNameY() - 0.5, (frame.bbfNameBaseWidth or 55) + 12)
        RaisePartyName(frame, false)
        PlacePartyLeaderIcon(frame, false)
        PlacePartyHealthTexts(frame, -0.5, -0.5)
        PlacePartyRightTexts(frame, -1, -4, -0.5)
        frame.bbfBigParty = nil
    end
    if (BBF.RetailTexturesOn and BBF.RetailTexturesOn("party")) then
        PlaceRetailPartyBars(frame)
    end
end

local PARTY_ROLE = { size = 18, x = 1, y = 1 }

local function DefaultPartyRoleLook()
    local db = BetterBlizzFramesDB
    return not (db.classicFrames or BBF.HasNoPortrait("party"))
end

local function PlaceMicroRoleIcon(frame)
    local proxy = frame.bbfMicroRole
    if not proxy then return end
    local default = DefaultPartyRoleLook()
    local size = default and PARTY_ROLE.size or 15
    proxy.roleIcon:SetSize(size, size)
    proxy.roleIcon:ClearAllPoints()
    proxy.roleIcon:SetPoint("CENTER", frame.PartyMemberOverlay.RoleIcon, "CENTER", default and PARTY_ROLE.x or 0, default and PARTY_ROLE.y or 0)
end

local function PlacePartyRoleIcon(frame)
    PlaceMicroRoleIcon(frame)
    if not DefaultPartyRoleLook() then return end
    if frame.state ~= "player" then return end
    if not frame.bbfBigParty and not frame.bbfPartyNoMana and frame.HealthBarContainer and frame.ManaBar then
        PlacePartyName(frame, 48, PartyNameY() - 0.5, (frame.bbfNameBaseWidth or 55) + 12)
        PlacePartyHealthTexts(frame, -0.5, -0.5)
        local bars = BBF.PartyBars(frame)
        bars:SetHeight(frame.HealthBarContainer, 11)
        bars:SetHeight(frame.HealthBarContainer.HealthBar, 11)
        PlacePartyDefaultMana(frame)
        PlacePartyRightTexts(frame, -1, -4, -0.5)
    end
    if frame.Portrait then
        frame.Portrait:ClearAllPoints()
        frame.Portrait:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -6)
    end
    local overlay = frame.PartyMemberOverlay
    local roleIcon = overlay and overlay.RoleIcon
    if not roleIcon then return end
    roleIcon:ClearAllPoints()
    roleIcon:SetPoint("TOPRIGHT", overlay, "TOPRIGHT", -112, -20)
end

local microRoleOptions = {
    displayRoleIcon = true,
    textureMap = {
        TANK = "groupfinder-icon-role-micro-tank",
        HEALER = "groupfinder-icon-role-micro-heal",
        DAMAGER = "groupfinder-icon-role-micro-dps",
    },
}

local function UseMicroRoleIcons()
    local db = BetterBlizzFramesDB
    return not db.classicFrames or db.classicFramesHDTextures
end

local function UpdateMicroRoleIcon(frame)
    local proxy = frame.bbfMicroRole
    if not proxy then return end
    proxy.unit = frame:GetUnit()
    UnitFrameUtil.UpdateUnitFrameRoleIcon(proxy)
    proxy.roleIcon:SetAlpha(BetterBlizzFramesDB.hidePartyRoles and 0 or 1)
end

local function SetupMicroRoleIcon(frame)
    if frame.bbfMicroRole then
        UpdateMicroRoleIcon(frame)
        return
    end
    local overlay = frame.PartyMemberOverlay
    local roleIcon = overlay and overlay.RoleIcon
    if not roleIcon or not frame.UpdateAssignedRoles then return end
    local icon = overlay:CreateTexture(nil, "OVERLAY")
    icon:Hide()
    frame.bbfMicroRole = { roleIcon = icon, optionTable = microRoleOptions }
    PlaceMicroRoleIcon(frame)
    roleIcon:SetAlpha(0)
    hooksecurefunc(frame, "UpdateAssignedRoles", UpdateMicroRoleIcon)
    UpdateMicroRoleIcon(frame)
end

function BBF.UpdatePartyRoleIcons()
    if not PartyFrame then return end
    local useMicro = UseMicroRoleIcons() and UnitFrameUtil and UnitFrameUtil.UpdateUnitFrameRoleIcon
    for i = 1, 4 do
        local frame = PartyFrame["MemberFrame" .. i]
        if frame then
            if not frame.bbfRoleIconHooked and frame.ToPlayerArt then
                frame.bbfRoleIconHooked = true
                BBF.HookPartyArt(frame, PlacePartyRoleIcon)
            end
            PlacePartyRoleIcon(frame)
            if useMicro then
                SetupMicroRoleIcon(frame)
            end
        end
    end
end

function BBF.UpdatePartyReduced()
    if not PartyFrame then return end
    for i = 1, 4 do
        local frame = PartyFrame["MemberFrame" .. i]
        if frame then
            if not frame.bbfReducedPartyHooked and frame.ToPlayerArt then
                frame.bbfReducedPartyHooked = true
                BBF.HookPartyArt(frame, UpdateOnePartyReduced)
            end
            UpdateOnePartyReduced(frame)
            PlacePartyRoleIcon(frame)
        end
    end
end

function BBF.ToTNameUnder()
    if BetterBlizzFramesDB.classicFrames then return end
    UpdateOneTotTexture(TargetFrame, "target")
    UpdateOneTotTexture(FocusFrame, "focus")
    if BBF.UpdateDefaultTotFrameMana then
        BBF.UpdateDefaultTotFrameMana()
    end
    if BBF.ApplyNameLayouts then
        BBF.ApplyNameLayouts()
    end
end

function BBF.UpdateTotFrameTexture()
    BBF.PlaceTotStatusTexts()
    if BetterBlizzFramesDB.classicFrames then return end
    UpdateOneTotTexture(TargetFrame, "target")
    UpdateOneTotTexture(FocusFrame, "focus")
    UpdateOneTotReduced(TargetFrame, "target")
    UpdateOneTotReduced(FocusFrame, "focus")
    BBF.UpdatePartyReduced()
    if BBF.ApplyTextArea then
        BBF.ApplyTextArea(TargetFrame.totFrame)
        BBF.ApplyTextArea(FocusFrame.totFrame)
        BBF.PlaceTotStatusTexts()
    end
end

-- ToT hide-mana layout lives in UpdateOneTotReduced so it can follow the Big Healthbar modes.
function BBF.UpdateDefaultTotFrameMana()
    if BetterBlizzFramesDB.classicFrames then
        BBF.UpdateClassicHiddenMana()
        return
    end
    BBF.UpdateTotFrameTexture()
end

local function SetDefaultPetManaShown(shown)
    local db = BetterBlizzFramesDB
    PetFrameManaBar:SetAlpha(shown and 1 or 0)
    if shown and db.hidePetText then return end
    local alpha = shown and 1 or 0
    PetFrameManaBar.TextString:SetAlpha(alpha)
    PetFrameManaBar.LeftText:SetAlpha(alpha)
    PetFrameManaBar.RightText:SetAlpha(alpha)
end

local PET_HEALTH_POINT = { "BOTTOMLEFT", "PetPortrait", "RIGHT", 2, -3.5 }

function BBF.UpdateDefaultPetFrameMana()
    local db = BetterBlizzFramesDB
    if db.classicFrames then
        BBF.UpdateClassicHiddenMana()
        return
    end
    if not PetFrameHealthBar or not PetFrameManaBar or not PetFrameHealthBarMask then return end
    if BBF.HasNoPortrait("pet") then return end
    if InCombatLockdown() then return end

    local p = PET_HEALTH_POINT
    if db.hideUnitFramePetMana then
        -- the no-mana art has one box down to the old mana bottom
        SetDefaultPetManaShown(false)
        PetFrameHealthBar:ClearAllPoints()
        if BBF.PetBigMode() == "reduced" then
            PetFrameHealthBar:SetSize(70, 19.5)
            PetFrameHealthBar:SetPoint(p[1], p[2], p[3], 2, -12)
            PetFrameHealthBarMask:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health-Mask")
            PetFrameHealthBarMask:SetSize(74, 48)
            PetFrameHealthBarMask:ClearAllPoints()
            PetFrameHealthBarMask:SetPoint("TOPLEFT", PetFrameHealthBar, "TOPLEFT", -0.5, 14)
        elseif BBF.PetBigMode() == "big" then
            PetFrameHealthBar:SetSize(71, 31)
            PetFrameHealthBar:SetPoint(p[1], p[2], p[3], 2, -13)
            PetFrameHealthBarMask:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health-Mask")
            PetFrameHealthBarMask:SetSize(73.5, 73)
            PetFrameHealthBarMask:ClearAllPoints()
            PetFrameHealthBarMask:SetPoint("TOPLEFT", PetFrameHealthBar, "TOPLEFT", -0.5, 21)
        else
            PetFrameHealthBar:SetSize(70, 20)
            PetFrameHealthBar:SetPoint(p[1], p[2], p[3], 3, -14)
            BBF.SetStretchedTotHealthMask(PetFrameHealthBar, PetFrameHealthBarMask, 20, 43.5, 12)
        end
        PetFrame.bbfBigPetHealthbar = true
        BBF.PlacePetHealthTexts()
    elseif PetFrame.bbfBigPetHealthbar then
        SetDefaultPetManaShown(true)
        PetFrameHealthBar:SetSize(70, 10)
        PetFrameHealthBar:ClearAllPoints()
        PetFrameHealthBar:SetPoint(p[1], p[2], p[3], p[4], p[5])
        PetFrameHealthBarMask:SetAtlas(totHpDefaultMask, true)
        PetFrameHealthBarMask:ClearAllPoints()
        PetFrameHealthBarMask:SetPoint("TOPLEFT", PetFrameHealthBar, "TOPLEFT", -29, 3)
        PetFrame.bbfBigPetHealthbar = nil
        BBF.UpdateDefaultPetBars()
    end

    BBF.UpdatePetFrameTexture()
    if (BBF.RetailTexturesOn and BBF.RetailTexturesOn("pet")) then
        BBF.FitRetailBars(PetFrameTexture, PetFrameHealthBar, PetFrameHealthBarMask, not db.hideUnitFramePetMana and PetFrameManaBar, PetFrameManaBarMask)
        BBF.ApplyTextArea(PetFrame)
    end
end

local class = UnitClassBase("player")

local function NoPortraitArt(name)
    local db = BetterBlizzFramesDB
    if db and db.noPortraitForeverBorders and not db.noPortraitPixelBorder then
        return "Interface\\AddOns\\BetterBlizzFrames\\media\\foreverTextures\\PortraitOff-" .. name .. ".png"
    end
    return "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Player-PortraitOff-" .. name .. ".png"
end
BBF.NoPortraitArt = NoPortraitArt

local CLASSIC_GLOW_PAD = 5

local function NoPortraitGlowFile(path)
    if type(path) ~= "string" or not path:find("PortraitOff%-") then return end
    local file = path:gsub("%-Unified", ""):gsub("%.png$", "-Status-Classic.png")
    return file
end

local function ApplyNoPortraitGlow(tex)
    local file = BetterBlizzFramesDB.classicCombatGlow and NoPortraitGlowFile(tex.bbfGlowSource)
    if not file and not tex.bbfClassicGlow then return end
    tex.bbfGlowApplying = true
    local anchor = tex.bbfGlowAnchor
    if file then
        tex.bbfClassicGlow = true
        tex:SetTexture(file)
        tex:SetBlendMode("ADD")
        if anchor then
            tex:ClearAllPoints()
            tex:SetPoint("TOPLEFT", anchor, "TOPLEFT", -CLASSIC_GLOW_PAD, CLASSIC_GLOW_PAD)
            tex:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", CLASSIC_GLOW_PAD, -CLASSIC_GLOW_PAD)
        end
    else
        tex.bbfClassicGlow = nil
        tex:SetTexture(tex.bbfGlowSource)
        tex:SetBlendMode(tex.bbfGlowBlend)
        if anchor then
            tex:ClearAllPoints()
            tex:SetAllPoints(anchor)
        end
    end
    tex.bbfGlowApplying = nil
end

local noPortraitGlowTextures = {}

local function HookNoPortraitGlow(tex)
    if not tex or tex.bbfGlowHooked then return end
    tex.bbfGlowHooked = true
    tex.bbfGlowBlend = tex:GetBlendMode()
    noPortraitGlowTextures[#noPortraitGlowTextures + 1] = tex
    hooksecurefunc(tex, "SetTexture", function(self, path)
        if self.bbfGlowApplying then return end
        self.bbfGlowSource = path
        ApplyNoPortraitGlow(self)
    end)
    hooksecurefunc(tex, "SetAllPoints", function(self, relativeTo)
        if self.bbfGlowApplying then return end
        self.bbfGlowAnchor = relativeTo or self:GetParent()
        ApplyNoPortraitGlow(self)
    end)
    hooksecurefunc(tex, "SetAtlas", function(self)
        if self.bbfGlowApplying then return end
        self.bbfGlowSource = nil
        if self.bbfClassicGlow then
            self.bbfClassicGlow = nil
            self.bbfGlowApplying = true
            self:SetBlendMode(self.bbfGlowBlend)
            self.bbfGlowApplying = nil
        end
    end)
    hooksecurefunc(tex, "SetBlendMode", function(self, mode)
        if self.bbfGlowApplying then return end
        self.bbfGlowBlend = mode
        ApplyNoPortraitGlow(self)
    end)
end

function BBF.UpdateNoPortraitClassicGlow()
    for _, tex in ipairs(noPortraitGlowTextures) do
        ApplyNoPortraitGlow(tex)
    end
end

local playerDefaultTex = NoPortraitArt("Large")
local playerAltTex = NoPortraitArt("Large-Alt")
local targetDefaultTex = NoPortraitArt("Large")
local focusDefaultTex = NoPortraitArt("Large")
local partyDefaultTex = NoPortraitArt("Large")
local petDefaultTex = NoPortraitArt("Large")
local totTargetDefaultTex = NoPortraitArt("Large")
local totFocusDefaultTex = NoPortraitArt("Large")

local playerFlashTex = NoPortraitArt("Large")
local targetFlashTex = NoPortraitArt("Large")
local focusFlashTex = NoPortraitArt("Large")
local petFlashTex = NoPortraitArt("Large")

local playerFlashNoLvl = NoPortraitArt("Large")
local targetFlashNoLvl = NoPortraitArt("Large")
local focusFlashNoLvl = NoPortraitArt("Large")
local petFlashNoLvl = NoPortraitArt("Large")

local minusTex = NoPortraitArt("Minus")
local unifiedTex = NoPortraitArt("Large-Unified")
BBF.UpdateResourcePositionNoPortrait = function()end -- filled in later but due to all the mess could potentially get called when nil

local function UpdateTextureVariables()
    local db = BetterBlizzFramesDB

    if db.noPortraitPixelBorder then
        playerDefaultTex = nil
        playerAltTex = nil
        targetDefaultTex = nil
        focusDefaultTex = nil
        partyDefaultTex = nil
        petDefaultTex = nil
        totTargetDefaultTex = nil
        totFocusDefaultTex = nil
        playerFlashTex = nil
        targetFlashTex = nil
        focusFlashTex = nil
        petFlashTex = nil
        playerFlashNoLvl = nil
        targetFlashNoLvl = nil
        focusFlashNoLvl = nil
        petFlashNoLvl = nil
        minusTex = nil
        return
    end
    minusTex = NoPortraitArt("Minus")
    unifiedTex = NoPortraitArt("Large-Unified")
    if BBF.BigPlayerHealthbar() then
        playerDefaultTex = unifiedTex
        playerAltTex = db.hideUnitFramePlayerSecondResource and unifiedTex or NoPortraitArt("Large-Alt-Unified")
    elseif db.hideUnitFramePlayerMana and db.hideUnitFramePlayerSecondResource then
        playerAltTex = NoPortraitArt("Minus")
        playerDefaultTex = NoPortraitArt("Minus")
    elseif db.hideUnitFramePlayerSecondResource then
        playerAltTex = NoPortraitArt("Large")
        playerDefaultTex = NoPortraitArt("Large")
    elseif db.hideUnitFramePlayerMana then
        local altBarShown = PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture:IsShown()
        if altBarShown then
            playerAltTex = NoPortraitArt("Large")
            playerDefaultTex = NoPortraitArt("Large")
        else
            playerAltTex = NoPortraitArt("Minus")
            playerDefaultTex = NoPortraitArt("Minus")
        end
    else
        playerAltTex = NoPortraitArt("Large-Alt")
        playerDefaultTex = NoPortraitArt("Large")
    end

    if db.hideUnitFrameTargetMana then
        targetDefaultTex = NoPortraitArt("Minus")
    else
        targetDefaultTex = NoPortraitArt("Large")
    end

    if db.hideUnitFrameFocusMana then
        focusDefaultTex = NoPortraitArt("Minus")
    else
        focusDefaultTex = NoPortraitArt("Large")
    end

    if NoPortraitBigPet() then
        petDefaultTex = unifiedTex
    elseif HidePetMana() then
        petDefaultTex = NoPortraitArt("Minus")
    else
        petDefaultTex = NoPortraitArt("Large")
    end

    if NoPortraitBigToT(TargetFrame) then
        totTargetDefaultTex = unifiedTex
    elseif HideTotMana(TargetFrame) then
        totTargetDefaultTex = NoPortraitArt("Minus")
    else
        totTargetDefaultTex = NoPortraitArt("Large")
    end

    if NoPortraitBigToT(FocusFrame) then
        totFocusDefaultTex = unifiedTex
    elseif HideTotMana(FocusFrame) then
        totFocusDefaultTex = NoPortraitArt("Minus")
    else
        totFocusDefaultTex = NoPortraitArt("Large")
    end

    if NoPortraitBigParty() then
        partyDefaultTex = unifiedTex
    elseif db.hideDefaultPartyFramesMana then
        partyDefaultTex = NoPortraitArt("Minus")
    else
        partyDefaultTex = NoPortraitArt("Large")
    end

    -- Set flash textures to match the corresponding default textures
    playerFlashTex = playerDefaultTex
    playerFlashNoLvl = playerDefaultTex
    targetFlashTex = targetDefaultTex
    targetFlashNoLvl = targetDefaultTex
    focusFlashTex = focusDefaultTex
    focusFlashNoLvl = focusDefaultTex
    petFlashTex = petDefaultTex
    petFlashNoLvl = petDefaultTex
end

local ART_INSET_X = 67 / 256
local ART_INSET_TOP = 5 / 64

local function ArtBottomInset(path)
    if path:find("Minus", 1, true) then return 36 / 64 end
    if path:find("Alt", 1, true) then return 5 / 64 end
    return 20 / 64
end

local function FitArtBackground(art)
    local bg = art.bbfArtBackground
    local path = art.bbfArtPathFn and art.bbfArtPathFn() or art.bbfArtPath
    if not bg or not path then return end
    local w, h = art:GetSize()
    local out = art.bbfArtOutset or 0
    bg:ClearAllPoints()
    bg:SetPoint("TOPLEFT", art, "TOPLEFT", w * ART_INSET_X - out, -h * ART_INSET_TOP + out)
    bg:SetPoint("BOTTOMRIGHT", art, "BOTTOMRIGHT", -w * ART_INSET_X + out, h * ArtBottomInset(path) - out - (art.bbfArtGrowDown or 0))
end

local function RoundToPixel(region)
    if not region or region.bbfPixelRounded or not region.SetRoundLayoutToNearestPixel or InCombatLockdown() then return end
    region.bbfPixelRounded = true
    region:SetRoundLayoutToNearestPixel(true)
end

local function BindArtBackground(bg, art, path, outset, growDown)
    art.bbfArtBackground = bg
    art.bbfArtOutset = outset
    art.bbfArtGrowDown = growDown
    if type(path) == "function" then
        art.bbfArtPathFn = path
    elseif type(path) == "string" then
        art.bbfArtPath = path
    end
    if not art.bbfArtHooked then
        art.bbfArtHooked = true
        hooksecurefunc(art, "SetTexture", function(self, texture)
            self.bbfArtPath = type(texture) == "string" and texture or nil
            FitArtBackground(self)
        end)
        hooksecurefunc(art, "SetSize", FitArtBackground)
    end
    FitArtBackground(art)
end

local ExtraMaskedRegions = {
    "OverAbsorbGlow",
    "OverHealAbsorbGlow",
    "MyHealAbsorb",
    "MyHealAbsorbLeftShadow",
    "MyHealAbsorbRightShadow",
}

local function ShareBarMask(region, maskTexture)
    if not region or not maskTexture or not region.AddMaskTexture then return end
    if region.bbfSharedMask == maskTexture then return end
    if region.bbfSharedMask then
        region:RemoveMaskTexture(region.bbfSharedMask)
    end
    region:AddMaskTexture(maskTexture)
    region.bbfSharedMask = maskTexture
end

local function MatchNameFont(levelText, name)
    local _, nameSize = name:GetFont()
    local font, _, flags = levelText:GetFont()
    if font and nameSize then
        levelText:SetFont(font, nameSize, flags)
    end
end

local function SyncLevelToName(frame, levelText)
    local name = frame.bbfName
    if not name then return end
    MatchNameFont(levelText, name)
    if not name.bbfLevelFontHooked then
        name.bbfLevelFontHooked = true
        hooksecurefunc(name, "SetFont", function()
            MatchNameFont(levelText, name)
        end)
    end
end

function BBF.ApplyNoPortraitBigPlayerMask()
    local hpContainer = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
    local mask = hpContainer.HealthBarMask
    mask:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Mask")
    mask:ClearAllPoints()
    mask:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", -2, 19)
    mask:SetSize(128.5, 70)
end

function BBF.ApplyNoPortraitPlayerMask()
    if BBF.BigPlayerHealthbar() then
        BBF.ApplyNoPortraitBigPlayerMask()
        return
    end
    local hpContainer = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
    local mask = hpContainer.HealthBarMask
    mask:SetTexture("interface/hud/uipartyframeportraitoffhealthmask")
    mask:ClearAllPoints()
    mask:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", -33, 9)
    mask:SetSize(190, 36)
end

local function LevelTextArea(frame)
    local area = frame.bbfTextArea
    if area and area:IsShown() and BBF.TextAreaActive and BBF.TextAreaActive(frame) then
        return area
    end
end

function BBF.AnchorNoPortraitTargetLevel(frame)
    if not frame or not frame.noPortraitMode then return end
    local levelText = frame.TargetFrameContent.TargetFrameContentMain.LevelText
    local area = LevelTextArea(frame)
    levelText:ClearAllPoints()
    if area then
        levelText:SetPoint("BOTTOMLEFT", area, "TOPLEFT", 0, 2)
    else
        levelText:SetPoint("RIGHT", frame, "RIGHT", -196, 17)
    end
    SyncLevelToName(frame, levelText)
end

function BBF.AnchorNoPortraitPlayerLevel()
    if not PlayerFrame.noPortraitMode then return end
    local area = LevelTextArea(PlayerFrame)
    PlayerLevelText:ClearAllPoints()
    if area then
        PlayerLevelText:SetPoint("BOTTOMRIGHT", area, "TOPRIGHT", 0, 2)
    else
        PlayerLevelText:SetPoint("LEFT", PlayerFrame, "LEFT", 194, 17)
    end
    SyncLevelToName(PlayerFrame, PlayerLevelText)
end

function BBF.AnchorNoPortraitGroupIcons(frame)
    if not frame or not frame.noPortraitMode then return end
    local player = frame == PlayerFrame
    local context = player and frame.PlayerFrameContent.PlayerFrameContentContextual or frame.TargetFrameContent.TargetFrameContentContextual
    local area = LevelTextArea(frame)
    for _, icon in ipairs({ context.LeaderIcon, context.GuideIcon }) do
        icon:ClearAllPoints()
        if area then
            if player then
                icon:SetPoint("BOTTOMLEFT", area, "TOPLEFT", 0, BetterBlizzFramesDB.noPortraitPixelBorder and 0 or -1)
            else
                icon:SetPoint("BOTTOMRIGHT", area, "TOPRIGHT", 0, BetterBlizzFramesDB.noPortraitPixelBorder and 0 or -1)
            end
        elseif player then
            icon:SetPoint("TOPLEFT", 86, icon == context.GuideIcon and -22 or -25)
        else
            icon:SetPoint("TOPRIGHT", -86, icon == context.GuideIcon and -24.5 or -25.5)
        end
    end
end

local function AuraOffsetKey(frame)
    return frame == FocusFrame and "noPortraitAuraFocus" or "noPortraitAuraTarget"
end

function BBF.ApplyNoPortraitAuraOffset(frame)
    if not frame or not frame.bbfAuraOffsetHooked then return end
    local db = BetterBlizzFramesDB
    if db.playerAuraFiltering then return end
    local container = frame:GetAuraContainer()
    if not container then return end
    if InCombatLockdown() and container:IsProtected() then
        BBF.RunAfterCombat(function() BBF.ApplyNoPortraitAuraOffset(frame) end)
        return
    end
    local key = AuraOffsetKey(frame)
    local baseX, baseY = 1.5, 2.5
    if db.noPortraitPixelBorder then
        baseX, baseY = -2, 0
    end
    local dx = baseX + (tonumber(db[key .. "XPos"]) or 0)
    local dy = baseY + (tonumber(db[key .. "YPos"]) or 0)
    local art = frame.TargetFrameContainer.FrameTexture
    container:ClearAllPoints()
    if container:IsFlowLayoutMirroredVertically() then
        local offsetY = -6 + dy
        if frame.threatNumericIndicator and frame.threatNumericIndicator:IsShown() then
            offsetY = offsetY + frame.threatNumericIndicator:GetHeight()
        end
        container:SetPoint("BOTTOMLEFT", art, "TOPLEFT", 5 + dx, offsetY)
    else
        container:SetPoint("TOPLEFT", art, "BOTTOMLEFT", 5 + dx, 9 + dy)
    end
end

local function HookNoPortraitAuras(frame)
    if BetterBlizzFramesDB.noPortraitSkipAuraAdjust then return end
    if frame.bbfAuraOffsetHooked or not frame.GetAuraContainer or not frame.AnchorAuraContainer then return end
    frame.bbfAuraOffsetHooked = true
    hooksecurefunc(frame, "AnchorAuraContainer", BBF.ApplyNoPortraitAuraOffset)
    BBF.ApplyNoPortraitAuraOffset(frame)
end

local levelAreaHooked
local function HookLevelToTextArea()
    if levelAreaHooked or not BBF.ApplyTextArea then return end
    levelAreaHooked = true
    hooksecurefunc(BBF, "ApplyTextArea", function(frame)
        if frame == PlayerFrame then
            BBF.AnchorNoPortraitPlayerLevel()
            BBF.AnchorNoPortraitGroupIcons(frame)
        elseif frame == TargetFrame or frame == FocusFrame then
            BBF.AnchorNoPortraitTargetLevel(frame)
            BBF.AnchorNoPortraitGroupIcons(frame)
        end
    end)
end

local MASK_TEXTURE = "Interface\\AddOns\\BetterBlizzFrames\\media\\masks\\pixelMask.png"
local maskFilterSupported

local function ApplyMaskTexture(maskTexture)
    if maskFilterSupported ~= false then
        if pcall(maskTexture.SetTexture, maskTexture, MASK_TEXTURE,
            "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST") then
            maskFilterSupported = true
            return
        end
        maskFilterSupported = false
    end

    maskTexture:SetTexture(MASK_TEXTURE, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
end

local function PlaceSquareMask(maskTexture, region)
    if not maskTexture or not region then return end

    ApplyMaskTexture(maskTexture)
    maskTexture:SetTexCoord(0, 1, 0, 1)
    maskTexture:ClearAllPoints()
    maskTexture:SetPoint("TOPLEFT", region, "TOPLEFT", 0, 0)
    maskTexture:SetPoint("BOTTOMRIGHT", region, "BOTTOMRIGHT", 0, 0)
end

local function SetBarMask(bar, maskTexture, pixelBorderMode)
    if not bar or not maskTexture or not pixelBorderMode then return end

    local function Place(mask)
        PlaceSquareMask(mask, bar.BBFPositionFrame or bar)
    end

    Place(maskTexture)

    bar.bbfBarMask = maskTexture
    for _, key in ipairs(ExtraMaskedRegions) do
        ShareBarMask(bar[key], maskTexture)
    end
    local absorbBar = bar.TotalAbsorbBar
    if absorbBar then
        ShareBarMask(absorbBar, maskTexture)
        ShareBarMask(absorbBar.TiledFillOverlay, maskTexture)
    end

    if class == "EVOKER" and not maskTexture.bbfTexHook then
        maskTexture.bbfTexHook = true
        hooksecurefunc(maskTexture, "SetAtlas", function(self)
            if self.changing then return end
            self.changing = true
            Place(self)
            self.changing = false
        end)
    end
end

BBF.NoPortraitSetBarMask = SetBarMask

function BBF.UpdatePlayerPixelBorderSize()
    if not BetterBlizzFramesDB.noPortraitPixelBorder then return end
    if not BBF.HasNoPortrait("player") then return end
    BBF.ApplyPixelBorderLayout(PlayerFrame)
end

function BBF.NoPortraitManaTextOffsets()
    local db = BetterBlizzFramesDB
    local thickOutline = db.changeUnitFrameValueFont and db.unitFrameValueFontOutline == "THICKOUTLINE"
    local defaultFont = not db.changeUnitFrameValueFont
    local manaTextYOffset = thickOutline and -5.5 or defaultFont and -5 or -4.5
    if db.noPortraitPixelBorder then
        manaTextYOffset = manaTextYOffset - (thickOutline and 1 or 2)
        if defaultFont then
            manaTextYOffset = manaTextYOffset + 0.5
        end
    end
    return db.changeUnitFrameValueFont and 68 or 67, manaTextYOffset + (db.tempManaYOffset or 0)
end

function BBF.UpdateNoPortraitText(frame, frameType)
    local db = BetterBlizzFramesDB
    BBF.HideMiniFrameBarArt(frame)
    if frameType == "pet" then
        if not BBF.HasNoPortrait("pet") then return end
    elseif frameType ~= "party" then
        if not (frame and frame.noPortraitMode) then return end
    end
    local thickOutline = db.changeUnitFrameValueFont and db.unitFrameValueFontOutline == "THICKOUTLINE"
    local hpTextYOffset = thickOutline and 9.5 or 10.5
    local leftTextXOffset, manaTextYOffset = BBF.NoPortraitManaTextOffsets()
    local pixel = db.noPortraitPixelBorder

    hpTextYOffset = hpTextYOffset + (BetterBlizzFramesDB.tempHpYOffset or 0)

    if frameType == "target" or frameType == "focus" then
        local content = frame.TargetFrameContent
        local contentMain = content.TargetFrameContentMain
        local hpContainer = contentMain.HealthBarsContainer
        local manaBar = contentMain.ManaBar
        local healthTextParent = frame.BBFHealthTextFrame or frame
        local manaTextParent = frame.BBFManaTextFrame or frame

        if BBF.IsBigHealthbarActive(frame) then
            hpTextYOffset = hpTextYOffset - 6
        end

        hpContainer.LeftText:SetParent(healthTextParent)
        hpContainer.LeftText:ClearAllPoints()
        hpContainer.LeftText:SetPoint("LEFT", frame.noPortraitMode.Texture, "LEFT", leftTextXOffset, hpTextYOffset)
        hpContainer.RightText:SetParent(healthTextParent)
        hpContainer.RightText:ClearAllPoints()
        hpContainer.RightText:SetPoint("RIGHT", frame.noPortraitMode.Texture, "RIGHT", -67, hpTextYOffset)
        hpContainer.HealthBarText:SetParent(healthTextParent)
        hpContainer.HealthBarText:ClearAllPoints()
        hpContainer.HealthBarText:SetPoint("CENTER", frame.noPortraitMode.Texture, "CENTER", 2, hpTextYOffset)
        hpContainer.DeadText:SetParent(healthTextParent)
        hpContainer.DeadText:ClearAllPoints()
        hpContainer.DeadText:SetPoint("CENTER", frame.noPortraitMode.Texture, "CENTER", -1, hpTextYOffset)
        hpContainer.UnconsciousText:SetParent(healthTextParent)
        hpContainer.UnconsciousText:ClearAllPoints()
        hpContainer.UnconsciousText:SetPoint("CENTER", frame.noPortraitMode.Texture, "CENTER", -1, hpTextYOffset)

        SetManaTextParent(manaBar.LeftText, manaTextParent)
        manaBar.LeftText:ClearAllPoints()
        manaBar.LeftText:SetPoint("LEFT", frame.noPortraitMode.Texture, "LEFT", leftTextXOffset, manaTextYOffset)
        SetManaTextParent(manaBar.RightText, manaTextParent)
        manaBar.RightText:ClearAllPoints()
        manaBar.RightText:SetPoint("RIGHT", frame.noPortraitMode.Texture, "RIGHT", -67, manaTextYOffset)
        SetManaTextParent(manaBar.ManaBarText, manaTextParent)
        manaBar.ManaBarText:ClearAllPoints()
        manaBar.ManaBarText:SetPoint("CENTER", frame.noPortraitMode.Texture, "CENTER", 2, manaTextYOffset)

    elseif frameType == "player" then
        local content = frame.PlayerFrameContent
        local contentMain = content.PlayerFrameContentMain
        local hpContainer = contentMain.HealthBarsContainer
        local manaBar = contentMain.ManaBarArea.ManaBar
        local healthTextParent = frame.BBFHealthTextFrame or frame
        local manaTextParent = frame.BBFManaTextFrame or frame

        if BBF.BigPlayerHealthbar() then
            hpTextYOffset = hpTextYOffset - 6
        end

        hpContainer.LeftText:SetParent(healthTextParent)
        hpContainer.LeftText:ClearAllPoints()
        hpContainer.LeftText:SetPoint("LEFT", frame.noPortraitMode.Texture, "LEFT", leftTextXOffset, hpTextYOffset)
        hpContainer.RightText:SetParent(healthTextParent)
        hpContainer.RightText:ClearAllPoints()
        hpContainer.RightText:SetPoint("RIGHT", frame.noPortraitMode.Texture, "RIGHT", -67, hpTextYOffset)
        hpContainer.HealthBarText:SetParent(healthTextParent)
        hpContainer.HealthBarText:ClearAllPoints()
        hpContainer.HealthBarText:SetPoint("CENTER", frame.noPortraitMode.Texture, "CENTER", 2, hpTextYOffset)

        SetManaTextParent(manaBar.LeftText, manaTextParent)
        manaBar.LeftText:ClearAllPoints()
        manaBar.LeftText:SetPoint("LEFT", frame.noPortraitMode.Texture, "LEFT", leftTextXOffset, manaTextYOffset)
        SetManaTextParent(manaBar.RightText, manaTextParent)
        manaBar.RightText:ClearAllPoints()
        manaBar.RightText:SetPoint("RIGHT", frame.noPortraitMode.Texture, "RIGHT", -67, manaTextYOffset)
        SetManaTextParent(manaBar.ManaBarText, manaTextParent)
        manaBar.ManaBarText:ClearAllPoints()
        manaBar.ManaBarText:SetPoint("CENTER", frame.noPortraitMode.Texture, "CENTER", 2, manaTextYOffset)

    elseif frameType == "pet" then
        local petHpTextYOffset = db.noPortraitPixelBorder and -17.5 or (db.changeUnitFrameValueFont and db.unitFrameValueFontOutline and -19) or -18
        if NoPortraitBigPet() then
            petHpTextYOffset = petHpTextYOffset - 3.5
        end
        local petManaTextYOffset = db.noPortraitPixelBorder and -30 or (db.changeUnitFrameValueFont and db.unitFrameValueFontOutline and -29) or -28
        local centerTextXOffset = db.noPortraitPixelBorder and 70 or 71.5

        PetFrameHealthBarText:ClearAllPoints()
        PetFrameHealthBarText:SetPoint("CENTER", PetFrame, "TOPLEFT", centerTextXOffset, petHpTextYOffset)
        PetFrameHealthBarTextLeft:ClearAllPoints()
        PetFrameHealthBarTextLeft:SetPoint("LEFT", PetFrame, "TOPLEFT", 38, petHpTextYOffset)
        PetFrameHealthBarTextRight:ClearAllPoints()
        PetFrameHealthBarTextRight:SetPoint("RIGHT", PetFrame, "TOPLEFT", 100, petHpTextYOffset)
        PetFrameManaBarText:ClearAllPoints()
        PetFrameManaBarText:SetPoint("CENTER", PetFrame, "TOPLEFT", centerTextXOffset, petManaTextYOffset)
        PetFrameManaBarTextLeft:ClearAllPoints()
        PetFrameManaBarTextLeft:SetPoint("LEFT", PetFrame, "TOPLEFT", 38, petManaTextYOffset)
        PetFrameManaBarTextRight:ClearAllPoints()
        PetFrameManaBarTextRight:SetPoint("RIGHT", PetFrame, "TOPLEFT", 100, petManaTextYOffset)

    elseif frameType == "tot" then
        local totFrame = frame.totFrame
        local textParent = totFrame.BBFTextFrame or totFrame

        totFrame.HealthBar.DeadText:SetParent(textParent)
        totFrame.HealthBar.UnconsciousText:SetParent(textParent)
        totFrame.bbfCenterDeadText = true
        BBF.PlaceTotDeadText(totFrame)

    elseif frameType == "party" then
        for partyFrame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
            local hpContainer = partyFrame.HealthBarContainer
            local manaBar = partyFrame.ManaBar

            local manaYOffset = db.noPortraitPixelBorder and -9 or (db.changeUnitFrameValueFont and db.unitFrameValueFontOutline and -5.5) or -4.5
            local bigPixel = NoPortraitBigParty() and db.noPortraitPixelBorder
            local hpY = NoPortraitBigParty() and (db.noPortraitPixelBorder and -8.5 or -5.5) or 0

            hpContainer.CenterText:ClearAllPoints()
            hpContainer.CenterText:SetPoint("CENTER", partyFrame.Texture, "CENTER", 2, 10 + hpY)
            hpContainer.LeftText:ClearAllPoints()
            hpContainer.LeftText:SetPoint("LEFT", partyFrame.Texture, "LEFT", bigPixel and 58 or 57, 10.5 + hpY)
            hpContainer.RightText:ClearAllPoints()
            hpContainer.RightText:SetPoint("RIGHT", partyFrame.Texture, "RIGHT", bigPixel and -53 or -57, 10.5 + hpY)
            manaBar.TextString:ClearAllPoints()
            manaBar.TextString:SetPoint("CENTER", partyFrame.Texture, "CENTER", 2, manaYOffset)
            manaBar.LeftText:ClearAllPoints()
            manaBar.LeftText:SetPoint("LEFT", partyFrame.Texture, "LEFT", 57, manaYOffset)
            manaBar.RightText:ClearAllPoints()
            manaBar.RightText:SetPoint("RIGHT", partyFrame.Texture, "RIGHT", -57, manaYOffset)
        end
    end
end

local function MakeNoPortraitMode(frame)
    local db = BetterBlizzFramesDB
    local hideLvl = db.hideLevelText
    local alwaysHideLvl = hideLvl and db.hideLevelTextAlways
    local hideDragon = db.hideRareDragonTexture

    local ClassResourceFrames = {
        ROGUE      = RogueComboPointBarFrame or BBF.ComboPointBar,
        DRUID      = DruidComboPointBarFrame or BBF.ComboPointBar,
        WARLOCK    = WarlockPowerFrame,
        MAGE       = MageArcaneChargesFrame,
        MONK       = MonkHarmonyBarFrame,
        EVOKER     = EssencePlayerFrame,
        PALADIN    = PaladinPowerBarFrame,
        DEATHKNIGHT = RuneFrame,
    }
    local classFrame = ClassResourceFrames[class]

    if frame == TargetFrame or frame == FocusFrame then
        -- Frame
        local content = frame.TargetFrameContent
        local frameContainer = frame.TargetFrameContainer
        local contentMain = content.TargetFrameContentMain
        local contentContext = content.TargetFrameContentContextual

        -- Status
        local hpContainer = contentMain.HealthBarsContainer
        local manaBar = contentMain.ManaBar

        contentMain.ReputationColor:SetParent(BBF.hiddenFrame)

        frameContainer:SetAlpha(0)
        --frameContainer:SetParent(BBF.hiddenFrame)
        manaBar.ManaBarMask:SetTexture("interface/hud/uipartyframeportraitoffmanamask")
        if not db.noPortraitPixelBorder then
            BBF.RunAfterCombat(function()
                manaBar:SetWidth(137)
                manaBar:ClearAllPoints()
                manaBar:SetPoint("TOPRIGHT", frameContainer, "LEFT", 155, -11)
            end)
        end

        frame.noPortraitMode = CreateFrame("Frame")
        frame.noPortraitMode:SetParent(frame)
        frame.noPortraitMode:SetFrameStrata("HIGH")
        frame.noPortraitMode:SetAllPoints(frame)
        if frame == TargetFrame then
            BBF.RaiseCombosAboveTargetArt()
        end
        frame.noPortraitMode.Texture = frame.noPortraitMode:CreateTexture(nil, "OVERLAY")
        frame.noPortraitMode.Texture:SetParent(frame.noPortraitMode)
        RoundToPixel(frame.noPortraitMode.Texture)
        frame.noPortraitMode.Texture:SetSize(254, 46)
        frame.noPortraitMode.Texture:SetTexCoord(1, 0, 0, 1)
        frame.noPortraitMode.Texture:SetPoint("TOPLEFT", -42, -38)
        HookNoPortraitGlow(frameContainer.Flash)

        frame.bbfName:SetParent(frame.noPortraitMode)

        frame.noPortraitMode.Background = frame:CreateTexture(nil, "BACKGROUND")
        frame.noPortraitMode.Background:SetColorTexture(0,0,0,0.45)
        BindArtBackground(frame.noPortraitMode.Background, frame.noPortraitMode.Texture, nil, 0.5)
        frame.noPortraitMode.BgMask = frame.noPortraitMode:CreateMaskTexture()
        frame.noPortraitMode.BgMask:SetAllPoints(frame.noPortraitMode.Background)
        frame.noPortraitMode.BgMask:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\masks\\frameMask.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        frame.noPortraitMode.Background:AddMaskTexture(frame.noPortraitMode.BgMask)

        local function GetFrameColor()
            local r,g,b = frameContainer.FrameTexture:GetVertexColor()
            frame.noPortraitMode.Texture:SetVertexColor(r,g,b)
        end
        GetFrameColor()
        hooksecurefunc(frameContainer.FrameTexture, "SetVertexColor", GetFrameColor)

        BBF.UpdateNoPortraitText(frame, frame.unit)
        --AdjustFramePoint(hpContainer.HealthBar.OverAbsorbGlow, -7)
        hpContainer.HealthBar.OverAbsorbGlow:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPRIGHT", -10, 0)

        local pixelBorderMode = db.noPortraitPixelBorder

        contentContext:SetParent(frame.noPortraitMode)
        contentContext.HighLevelTexture:ClearAllPoints()
        contentContext.HighLevelTexture:SetPoint("CENTER", frame, "RIGHT", -91, 17)
        contentContext.PetBattleIcon:ClearAllPoints()
        contentContext.PetBattleIcon:SetPoint("CENTER", frame, "BOTTOMRIGHT", -35, 25)
        contentContext.PrestigePortrait:SetScale(0.85)
        contentContext.PrestigeBadge:SetScale(0.85)
        contentContext.PrestigePortrait:ClearAllPoints()
        contentContext.PrestigePortrait:SetPoint("TOPRIGHT", 5, -17)
        BBF.AnchorNoPortraitGroupIcons(frame)
        contentContext.QuestIcon:ClearAllPoints()
        contentContext.QuestIcon:SetPoint("TOPRIGHT", -65, pixelBorderMode and -40 or -45)
        contentContext.BossIcon:ClearAllPoints()
        contentContext.BossIcon:SetPoint("TOPRIGHT", -65, pixelBorderMode and -40 or -45)
        contentContext.PetBattleIcon:SetSize(20,20)
        contentContext.PetBattleIcon:ClearAllPoints()
        contentContext.PetBattleIcon:SetPoint("TOPRIGHT", -65, pixelBorderMode and -41 or -47)
        contentContext.RaidTargetIcon:ClearAllPoints()
        contentContext.RaidTargetIcon:SetPoint("TOPRIGHT", pixelBorderMode and -63 or -56, pixelBorderMode and -40 or -42)
        if pixelBorderMode then
            contentContext.RaidTargetIcon:SetSize(20,20)
        end
        if contentContext.PvpBackgroundCircle then
            contentContext.PvpBackgroundCircle:ClearAllPoints()
            contentContext.PvpBackgroundCircle:SetPoint("TOP", contentContext, "TOPRIGHT", -92, -54)
            contentContext.PvpBackgroundCircle:SetSize(30, 30)
        end
        if contentContext.PvpBackgroundIcon then
            contentContext.PvpBackgroundIcon:SetScale(0.9)
            contentContext.PvpBackgroundIcon:ClearAllPoints()
            contentContext.PvpBackgroundIcon:SetPoint("TOP", contentContext, "TOPRIGHT", -86, -49)
        end

        --AdjustFramePoint(frameContainer.Portrait, nil, -4)
        frameContainer.Portrait:SetPoint("TOPRIGHT", frameContainer, "TOPRIGHT", -26, -19)

        contentMain.LevelText:SetParent(frame.noPortraitMode)
        contentMain.LevelText:ClearAllPoints()
        HookLevelToTextArea()
        HookNoPortraitAuras(frame)
        BBF.AnchorNoPortraitTargetLevel(frame)
        contentMain.ReputationColor:SetParent(BBF.hiddenFrame)

        frameContainer.Flash:SetDrawLayer("BACKGROUND")
        frameContainer.Flash:SetParent((db.hideCombatGlow or db.noPortraitPixelBorder) and BBF.hiddenFrame or frame)
        frameContainer.Portrait:SetSize(62,62)
        frameContainer.Portrait:ClearAllPoints()
        frameContainer.Portrait:SetPoint("TOPRIGHT", -23, -22)
        frameContainer.PortraitMask:SetSize(61,61)
        frameContainer.PortraitMask:ClearAllPoints()
        frameContainer.PortraitMask:SetPoint("CENTER", frameContainer.Portrait, "CENTER", 0, 0)
        frameContainer.BossPortraitFrameTexture:SetParent(db.hideRareDragonTexture and BBF.hiddenFrame or frame.noPortraitMode)
        SetBossDragonAtlas(frameContainer.BossPortraitFrameTexture, frame.unit and UnitClassification(frame.unit))
        frameContainer.BossPortraitFrameTexture:SetSize(15, 15)
        frameContainer.BossPortraitFrameTexture:ClearAllPoints()
        frameContainer.BossPortraitFrameTexture:SetPoint("CENTER", hpContainer, "TOPRIGHT", -3.5, -1)
        frameContainer.BossPortraitFrameTexture:SetDrawLayer("OVERLAY", 7)


        -- frameContainer.PlayerPortrait:SetSize(62, 62)
        -- frameContainer.PlayerPortrait:ClearAllPoints()
        -- frameContainer.PlayerPortrait:SetPoint("TOPLEFT", 25, -22)
        -- frameContainer.PlayerPortraitMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        -- frameContainer.PlayerPortraitMask:ClearAllPoints()
        -- frameContainer.PlayerPortraitMask:SetPoint("CENTER", frameContainer.PlayerPortrait, "CENTER", 0, 0)



        --------- these might need updates / different method
        local totFrame = frame.totFrame
        local totHpBar = totFrame.HealthBar
        local totManaBar = totFrame.ManaBar
        totFrame:SetFrameStrata("DIALOG")
        totHpBar:SetStatusBarColor(0, 1, 0)
        if not db.noPortraitPixelBorder then
            totHpBar:ClearAllPoints()
            totHpBar:SetSize(65, NoPortraitBigToT(frame) and 23 or 16)
            totHpBar:SetPoint("TOPRIGHT", -19, -10)
            totManaBar:ClearAllPoints()
            totManaBar:SetSize(72, 8)
            totManaBar:SetPoint("TOPRIGHT", -15, -25)
        end
        totHpBar:SetFrameLevel(1)
        totManaBar:SetFrameLevel(1)
        totFrame.Portrait:SetParent(BBF.hiddenFrame)

        totFrame.Background = totFrame.HealthBar:CreateTexture(nil, "BACKGROUND")
        totFrame.Background:SetColorTexture(0,0,0,0.45)
        BindArtBackground(totFrame.Background, totFrame.FrameTexture, function()
            return (frame == TargetFrame) and totTargetDefaultTex or totFocusDefaultTex
        end, nil, 1)
        totFrame.FrameTexture:SetSize(130, 33)
        local totTexture = (frame == TargetFrame) and totTargetDefaultTex or totFocusDefaultTex
        totFrame.FrameTexture:SetTexture(totTexture)
        totFrame.FrameTexture:SetTexCoord(0, 1, 0, 1)
        totFrame.FrameTexture:ClearAllPoints()
        totFrame.FrameTexture:SetPoint("TOPLEFT", 3, -9)

        if not db.noPortraitPixelBorder then
            totHpBar.HealthBarMask:SetTexture("interface/hud/uipartyframeportraitoffhealthmask")
            if NoPortraitBigToT(frame) then
                totHpBar.HealthBarMask:SetSize(98, 36)
                SetXYPoint(totHpBar.HealthBarMask, -17, 6.5)
            else
                totHpBar.HealthBarMask:SetSize(98, 22)
                SetXYPoint(totHpBar.HealthBarMask, -17, 3.5)
            end

            totManaBar.ManaBarMask:SetSize(96, 16)
            totManaBar.ManaBarMask:SetTexture("interface/hud/uipartyframeportraitoffmanamask")
            SetXYPoint(totManaBar.ManaBarMask, -13, 4)
        end

        if not totFrame.BBFTextFrame then
            totFrame.BBFTextFrame = CreateFrame("Frame", nil, totFrame)
            totFrame.BBFTextFrame:SetAllPoints(totFrame)
        end

        totFrame.HealthBar.DeadText:SetParent(totFrame.BBFTextFrame)
        totFrame.HealthBar.UnconsciousText:SetParent(totFrame.BBFTextFrame)
        if BBF.PlaceTotStatusTexts then
            BBF.PlaceTotStatusTexts()
        end

        if db.noPortraitPixelBorder then
            totFrame.FrameTexture:SetAlpha(0)
            totFrame.Background:SetAlpha(0)

            BBF.WatchPixelBorderScale(totFrame)
            BBF.ApplyPixelBorderLayout(totFrame)

            local maxBorderLevel = 0
            if totHpBar.BBFPixelBorder then
                maxBorderLevel = math.max(maxBorderLevel, totHpBar.BBFPixelBorder:GetFrameLevel())
            end
            if totManaBar.BBFPixelBorder then
                maxBorderLevel = math.max(maxBorderLevel, totManaBar.BBFPixelBorder:GetFrameLevel())
            end
            if totFrame.BBFTextFrame and maxBorderLevel > 0 then
                totFrame.BBFTextFrame:SetFrameLevel(maxBorderLevel + 1)
            end
        else

            if totFrame.BBFTextFrame then
                local maxBarLevel = math.max(totFrame:GetFrameLevel(), totHpBar:GetFrameLevel(), totManaBar:GetFrameLevel())
                totFrame.BBFTextFrame:SetFrameLevel(maxBarLevel + 10)
            end

            totFrame.FrameTexture:SetAlpha(1)
            totFrame.Background:SetAlpha(1)

            if totHpBar.pixelBorderBackground then
                totHpBar.pixelBorderBackground:SetAlpha(0)
            end
            if totManaBar.pixelBorderBackground then
                totManaBar.pixelBorderBackground:SetAlpha(0)
            end
        end

        if not totFrame.FrameTexture.noPortraitMode then
            totFrame.FrameTexture.noPortraitMode = true
            hooksecurefunc(totFrame.FrameTexture, "SetTexture", function(self)
                if self.changing then return end
                self.changing = true
                local totTexture = (frame == TargetFrame) and totTargetDefaultTex or totFocusDefaultTex
                totFrame.FrameTexture:SetTexture(totTexture)
                totFrame.FrameTexture:SetTexCoord(0, 1, 0, 1)
                self.changing = false
            end)
        end
        totFrame.Portrait:SetSize(37, 37)
        totFrame.Portrait:ClearAllPoints()
        totFrame.Portrait:SetPoint("TOPLEFT", 4, -5)
        BBF.UpdateNoPortraitText(frame, "tot")

        frameContainer.Flash:SetParent((db.hideCombatGlow or db.noPortraitPixelBorder) and BBF.hiddenFrame or frame.noPortraitMode)

        local hideToTDebuffs = (frame == TargetFrame and db.hideTargetToTDebuffs) or (frame == FocusFrame and db.hideFocusToTDebuffs)
        if not hideToTDebuffs then
            local debuffFrameName = totFrame:GetName().."Debuff"
            for i = 1, 4 do
                local debuffFrame = _G[debuffFrameName..i]
                debuffFrame:ClearAllPoints()
                if i == 1 then
                    debuffFrame:SetPoint("TOPLEFT", totFrame, "TOPRIGHT", -18, -9)
                elseif i == 2 then
                    debuffFrame:SetPoint("TOPLEFT", totFrame, "TOPRIGHT", -5, -9)
                elseif i== 3 then
                    debuffFrame:SetPoint("TOPLEFT", totFrame, "TOPRIGHT", -18, -22)
                elseif  i==4  then
                    debuffFrame:SetPoint("TOPLEFT", totFrame, "TOPRIGHT", -5, -22)
                end
            end
        end

        local function FrameAdjustments(container)
            container.FrameTexture:ClearAllPoints()
            container.FrameTexture:SetPoint("TOPLEFT", 20.5, -18)
            container.Flash:SetTexture((frame == TargetFrame) and targetFlashTex or focusFlashTex)
            container.Flash:SetTexCoord(1, 0, 0, 1)
            container.Flash:ClearAllPoints()
            container.Flash:SetAllPoints(frame.noPortraitMode.Texture)
            container.Flash:SetDrawLayer("OVERLAY", 1)
            contentMain.LevelText:SetAlpha(1)
            hpContainer.HealthBarMask:SetHeight(30)
        end

        hooksecurefunc(frame, "CheckClassification", function(self)
            local classification = UnitClassification(self.unit)
            BBF.AnchorNoPortraitTargetLevel(self)

            -- Frame
            local content = self.TargetFrameContent
            local frameContainer = frameContainer
            local contentMain = content.TargetFrameContentMain
            -- Status
            local hpContainer = contentMain.HealthBarsContainer
            local manaBar = contentMain.ManaBar

            frameContainer.FrameTexture:SetAlpha(0)

            if db.noPortraitPixelBorder then
                BBF.ApplyPixelBorderLayout(frame)
            else
                hpContainer.HealthBarMask:SetTexture("interface/hud/uipartyframeportraitoffhealthmask")
                SetXYPoint(hpContainer.HealthBarMask, -35, 5)
                hpContainer.HealthBarMask:SetSize(193, 30)

                manaBar.ManaBarMask:SetSize(190, 28)
                manaBar.ManaBarMask:SetTexture("interface/hud/uipartyframeportraitoffmanamask")
                SetXYPoint(manaBar.ManaBarMask, -26, 8)
                BBF.RunAfterCombat(function()
                    manaBar:SetHeight(10.5)
                end)
            end

            frame.noPortraitMode.Texture:ClearAllPoints()
            frame.noPortraitMode.Texture:SetPoint("TOPLEFT", -42, -38)

            local hideMana = (frame == TargetFrame and db.hideUnitFrameTargetMana) or (frame == FocusFrame and db.hideUnitFrameFocusMana)

            FrameAdjustments(frameContainer)

            SetBossDragonAtlas(frameContainer.BossPortraitFrameTexture, classification)
            frameContainer.BossPortraitFrameTexture:SetSize(15, 15)
            frameContainer.BossPortraitFrameTexture:ClearAllPoints()
            frameContainer.BossPortraitFrameTexture:SetPoint("CENTER", hpContainer, "TOPRIGHT", -3.5, -1)
            frameContainer.BossPortraitFrameTexture:SetDrawLayer("OVERLAY", 7)

            local textureToUse
            if BBF.IsBigHealthbarActive(frame) then
                textureToUse = unifiedTex
            elseif hideMana then
                textureToUse = minusTex
            else
                textureToUse = (frame == TargetFrame) and targetDefaultTex or focusDefaultTex
            end

            frame.noPortraitMode.Texture:SetTexture(textureToUse)
        end)

        hooksecurefunc(frame, "CheckFaction", function(self)
            if (self.showPVP) then
                local factionGroup = UnitFactionGroup(self.unit)
                if (factionGroup == "Alliance") then
                    contentContext.PvpIcon:ClearAllPoints()
                    contentContext.PvpIcon:SetPoint("TOPRIGHT", -4, -24)
                elseif (factionGroup == "Horde") then
                    contentContext.PvpIcon:ClearAllPoints()
                    contentContext.PvpIcon:SetPoint("TOPRIGHT", 3, -22)
                end
                contentContext.PrestigePortrait:ClearAllPoints()
                contentContext.PrestigePortrait:SetPoint("TOPRIGHT", -48, -40)
            end
        end)
        contentContext.PvpIcon:SetParent(BBF.hiddenFrame)

        if db.noPortraitModesDesaturated or db.classColorFrameTexture then
            frame.noPortraitMode.Texture:SetDesaturated(true)
            totFrame.FrameTexture:SetDesaturated(true)
        end

        if db.noPortraitPixelBorder then
            frame.noPortraitMode.Texture:SetAlpha(0)
            frame.noPortraitMode.Background:SetAlpha(0)

            BBF.WatchPixelBorderScale(frame)
            BBF.ApplyPixelBorderLayout(frame)
            BBF.UpdateNoPortraitText(frame, frame.unit)

            if not frame.BBFHealthTextFrame then
                frame.BBFHealthTextFrame = CreateFrame("Frame", nil, BBF.HealthBar(frame))
                frame.BBFHealthTextFrame:SetAllPoints(frame)
                frame.BBFHealthTextFrame:SetFrameStrata("HIGH")
            end

            if not frame.BBFManaTextFrame then
                frame.BBFManaTextFrame = CreateFrame("Frame", nil, manaBar)
                frame.BBFManaTextFrame:SetAllPoints(frame)
                frame.BBFManaTextFrame:SetFrameStrata("HIGH")
            end

            if BBF.HealthBar(frame).BBFPixelBorder and frame.BBFHealthTextFrame then
                frame.BBFHealthTextFrame:SetFrameLevel(BBF.HealthBar(frame).BBFPixelBorder:GetFrameLevel() + 1)
            end

            if manaBar.BBFPixelBorder and frame.BBFManaTextFrame then
                frame.BBFManaTextFrame:SetFrameLevel(manaBar.BBFPixelBorder:GetFrameLevel() + 1)
            end
        else

            if not frame.BBFHealthTextFrame then
                frame.BBFHealthTextFrame = CreateFrame("Frame", nil, BBF.HealthBar(frame))
                frame.BBFHealthTextFrame:SetAllPoints(frame)
                frame.BBFHealthTextFrame:SetFrameStrata("HIGH")
            end

            if not frame.BBFManaTextFrame then
                frame.BBFManaTextFrame = CreateFrame("Frame", nil, manaBar)
                frame.BBFManaTextFrame:SetAllPoints(frame)
                frame.BBFManaTextFrame:SetFrameStrata("HIGH")
            end

            if frame.BBFHealthTextFrame then
                frame.BBFHealthTextFrame:SetFrameLevel(BBF.HealthBar(frame):GetFrameLevel() + 10)
            end

            if frame.BBFManaTextFrame then
                frame.BBFManaTextFrame:SetFrameLevel(manaBar:GetFrameLevel() + 10)
            end

            frame.noPortraitMode.Texture:SetAlpha(1)
            frame.noPortraitMode.Background:SetAlpha(1)

            if BBF.HealthBar(frame).pixelBorderBackground then
                BBF.HealthBar(frame).pixelBorderBackground:SetAlpha(0)
            end
            if manaBar.pixelBorderBackground then
                manaBar.pixelBorderBackground:SetAlpha(0)
            end
        end

    elseif frame == PlayerFrame then
        local hideLvl, alwaysHideLvl = BBF.PlayerLevelHideFlags()
        -- PlayerFrame
        -- Frame
        local content = frame.PlayerFrameContent
        local frameContainer = frame.PlayerFrameContainer
        local contentMain = content.PlayerFrameContentMain
        local contentContext = content.PlayerFrameContentContextual
        -- Status
        local hpContainer = contentMain.HealthBarsContainer
        local manaBar = contentMain.ManaBarArea.ManaBar

        --contentMain.ReputationColor:SetParent(BBF.hiddenFrame) fix

        frame.noPortraitMode = CreateFrame("Frame")
        frame.noPortraitMode:SetParent(frame)
        frame.noPortraitMode:SetFrameStrata("HIGH")
        frame.noPortraitMode:SetAllPoints(frame)
        frame.noPortraitMode.Texture = frame.noPortraitMode:CreateTexture(nil, "OVERLAY")
        RoundToPixel(frame.noPortraitMode.Texture)
        RoundToPixel(contentMain.StatusTexture)
        HookNoPortraitGlow(frameContainer.FrameFlash)
        HookNoPortraitGlow(contentMain.StatusTexture)
        frame.noPortraitMode.bbfVehicleTexture =frame.noPortraitMode:CreateTexture(nil, "OVERLAY", nil, 7)
        frame.noPortraitMode.bbfVehicleTexture:SetSize(18, 18)
        frame.noPortraitMode.bbfVehicleTexture:ClearAllPoints()
        frame.noPortraitMode.bbfVehicleTexture:SetPoint("TOPLEFT", 76, -47)
        frame.noPortraitMode.bbfVehicleTexture:Hide()
        frame.noPortraitMode.bbfVehicleTexture:SetAtlas("Taxi_Frame_Gray")
        --contentContext.GroupIndicator:SetAlpha(0)

        if class == "PRIEST" then
            hooksecurefunc(ClassPowerBar, "Setup", function()
                if frame.bbfClassPowerBarHidden then return end
                if frame.classPowerBar then
                    frame.classPowerBar:SetAlpha(0)
                    frame.bbfClassPowerBarHidden = true
                end
            end)
        end

        if db.noPortraitPixelBorder then
            BBF.WatchPixelBorderScale(frame)
            BBF.ApplyPixelBorderLayout(frame)

            if not frame.BBFHealthTextFrame then
                frame.BBFHealthTextFrame = CreateFrame("Frame", nil, hpContainer.HealthBar)
                frame.BBFHealthTextFrame:SetAllPoints(frame)
                frame.BBFHealthTextFrame:SetFrameStrata("HIGH")
            end

            if not frame.BBFManaTextFrame then
                frame.BBFManaTextFrame = CreateFrame("Frame", nil, manaBar)
                frame.BBFManaTextFrame:SetAllPoints(frame)
                frame.BBFManaTextFrame:SetFrameStrata("HIGH")
            end

            if hpContainer.HealthBar.BBFPixelBorder and frame.BBFHealthTextFrame then
                frame.BBFHealthTextFrame:SetFrameLevel(hpContainer.HealthBar.BBFPixelBorder:GetFrameLevel() + 1)
            end

            if manaBar.BBFPixelBorder and frame.BBFManaTextFrame then
                frame.BBFManaTextFrame:SetFrameLevel(manaBar.BBFPixelBorder:GetFrameLevel() + 1)
            end
        else

            if not frame.BBFHealthTextFrame then
                frame.BBFHealthTextFrame = CreateFrame("Frame", nil, hpContainer.HealthBar)
                frame.BBFHealthTextFrame:SetAllPoints(frame)
                frame.BBFHealthTextFrame:SetFrameStrata("HIGH")
            end

            if not frame.BBFManaTextFrame then
                frame.BBFManaTextFrame = CreateFrame("Frame", nil, manaBar)
                frame.BBFManaTextFrame:SetAllPoints(frame)
                frame.BBFManaTextFrame:SetFrameStrata("HIGH")
            end

            if frame.BBFHealthTextFrame then
                frame.BBFHealthTextFrame:SetFrameLevel(hpContainer.HealthBar:GetFrameLevel() + 10)
            end

            if frame.BBFManaTextFrame then
                frame.BBFManaTextFrame:SetFrameLevel(manaBar:GetFrameLevel() + 10)
            end
        end

        --frame.bbfVehicleTexture:SetParent(frame.noPortraitMode)
        --frameContainer:SetAlpha(0)
        frameContainer:SetParent(BBF.hiddenFrame)

        manaBar.FullPowerFrame:SetParent(frame.noPortraitMode)

        contentMain.HitIndicator.HitText:ClearAllPoints()
        contentMain.HitIndicator.HitText:SetPoint("CENTER", frameContainer.PlayerPortrait)
        contentMain.HitIndicator.HitText:SetScale(0.85)
        contentMain.HitIndicator:SetParent(BBF.hiddenFrame)--PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual)

        contentContext:SetParent(frame.noPortraitMode)
        frame.bbfName:SetParent(frame.noPortraitMode)

        if contentMain.PvpBackgroundCircle then
            contentMain.PvpBackgroundCircle:SetParent(frame.noPortraitMode)
            contentMain.PvpBackgroundCircle:SetDrawLayer("OVERLAY", 5)
            contentMain.PvpBackgroundCircle:ClearAllPoints()
            contentMain.PvpBackgroundCircle:SetPoint("TOP", contentMain, "TOPLEFT", 92, -54)
            contentMain.PvpBackgroundCircle:SetSize(30, 30)
        end
        if contentMain.PvpBackgroundIcon then
            contentMain.PvpBackgroundIcon:SetParent(frame.noPortraitMode)
            contentMain.PvpBackgroundIcon:SetDrawLayer("OVERLAY", 6)
            contentMain.PvpBackgroundIcon:SetScale(0.9)
            contentMain.PvpBackgroundIcon:ClearAllPoints()
            contentMain.PvpBackgroundIcon:SetPoint("TOP", contentMain, "TOPLEFT", 85, -50)
        end

        contentContext.AttackIcon:ClearAllPoints()
        contentContext.AttackIcon:SetPoint("CENTER", -40, 0)
        contentContext.AttackIcon:SetSize(14, 15)
        contentContext.AttackIcon:SetDrawLayer("OVERLAY", 7)
        contentContext.AttackIcon:SetAtlas("questlog-questtypeicon-pvp")
        contentContext.PVPIcon:ClearAllPoints()
        contentContext.PVPIcon:SetPoint("TOPLEFT", 139, -81)
        contentContext.PVPIcon:SetScale(0.5)
        --contentContext.AttackIcon:SetParent(BBF.hiddenFrame)
        contentContext.PlayerPortraitCornerIcon:SetAtlas(nil)
        contentContext.PrestigePortrait:ClearAllPoints()
        contentContext.PrestigePortrait:SetPoint("TOPLEFT", 50, -41)
        contentContext.PrestigePortrait:SetScale(0.85)
        contentContext.PrestigeBadge:SetScale(0.85)
        HookLevelToTextArea()
        BBF.AnchorNoPortraitGroupIcons(frame)
        contentContext.RoleIcon:SetSize(13, 13)
        contentContext.RoleIcon:ClearAllPoints()
        contentContext.RoleIcon:SetPoint("TOPLEFT", 81, -36)
        contentContext.PlayerRestLoop:ClearAllPoints()
        contentContext.PlayerRestLoop:SetPoint("TOPRIGHT", -80, -51)
        contentContext.PlayerRestLoop:SetScale(0.5)


        --AdjustFramePoint(contentContext.GroupIndicator, nil, -3)

        frameContainer.PlayerPortrait:SetSize(62, 62)
        frameContainer.PlayerPortraitMask:SetSize(62, 62)
        frameContainer.PlayerPortraitMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        frameContainer.PlayerPortraitMask:ClearAllPoints()
        frameContainer.PlayerPortraitMask:SetPoint("CENTER", frameContainer.PlayerPortrait, "CENTER", 0, 0)

        frame.noPortraitMode.Background = frame:CreateTexture(nil, "BACKGROUND")
        frame.noPortraitMode.Background:SetColorTexture(0,0,0,0.45)
        BindArtBackground(frame.noPortraitMode.Background, frame.noPortraitMode.Texture, nil, 0.5)
        frame.noPortraitMode.BgMask = frame.noPortraitMode:CreateMaskTexture()
        frame.noPortraitMode.BgMask:SetAllPoints(frame.noPortraitMode.Background)
        frame.noPortraitMode.BgMask:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\masks\\frameMask.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        frame.noPortraitMode.Background:AddMaskTexture(frame.noPortraitMode.BgMask)

        C_Timer.After(1, function()
            local bd = BigDebuffsplayerUnitFrame
            local oa = C_AddOns.IsAddOnLoaded("OmniAuras")
            if bd then
                if bd.mask then
                    bd.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                elseif bd.icon then
                    bd.mask = bd:CreateMaskTexture()
                    bd.mask:SetAllPoints(bd.icon)
                    bd.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                    bd.icon:AddMaskTexture(bd.mask)
                end
            end
            if oa then
                for _, child in ipairs({PlayerFrame.PlayerFrameContainer:GetChildren()}) do
                    if child:IsObjectType("Button") then
                        local mask = child.mask
                        if mask and mask.SetTexture then
                            mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                            break
                        end
                    end
                end
            end
        end)

        --AdjustFramePoint(hpContainer.HealthBar.OverAbsorbGlow,-3)
        hpContainer.HealthBar.OverAbsorbGlow:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPRIGHT", -7, 0)

        if BBF.LegacyCombosOn() and BBF.LegacyComboFrame then
            BBF.LegacyComboFrame:SetParent(TargetFrame)
            BBF.LegacyComboFrame:SetFrameStrata("HIGH")
            BBF.UpdateLegacyComboPosition()
        end

        local function UpdateLevelDetails()
            PlayerLevelText:SetParent(frame.noPortraitMode)
            PlayerLevelText:SetDrawLayer("OVERLAY", 7)
            PlayerLevelText:Show()
            HookLevelToTextArea()
            BBF.AnchorNoPortraitPlayerLevel()
        end

        local function UpdateLevel()
            if not db.playerEliteFrame then
                if alwaysHideLvl then
                    PlayerLevelText:SetParent(BBF.hiddenFrame)
                    PlayerLevelText:ClearAllPoints()
                    PlayerLevelText:SetPoint("LEFT", 194, 17)
                elseif hideLvl then
                    if UnitLevel("player") == GetMaxLevelForPlayerExpansion() then
                        PlayerLevelText:SetParent(BBF.hiddenFrame)
                        PlayerLevelText:ClearAllPoints()
                        PlayerLevelText:SetPoint("LEFT", 194, 17)
                    else
                        UpdateLevelDetails()
                    end
                else
                    UpdateLevelDetails()
                end
            else
                -- When playerEliteFrame is enabled, handle level text based on mode
                local mode = BetterBlizzFramesDB.playerEliteFrameMode
                if mode > 3 then
                    -- Always hide level text for mode > 3 (using UI-FocusFrame-Large texture)
                    PlayerLevelText:SetParent(BBF.hiddenFrame)
                elseif alwaysHideLvl or (hideLvl and UnitLevel("player") == GetMaxLevelForPlayerExpansion()) then
                    -- Hide level text based on hideLvl settings for mode <= 3
                    PlayerLevelText:SetParent(BBF.hiddenFrame)
                else
                    -- Show level text for other cases
                    UpdateLevelDetails()
                end
            end
        end
        hooksecurefunc("PlayerFrame_UpdateLevel", function()
            UpdateLevel()
        end)
        UpdateLevel()

        hooksecurefunc("PlayerFrame_UpdateRolesAssigned", function()
            contentContext.RoleIcon:ClearAllPoints()
            contentContext.RoleIcon:SetPoint("TOPLEFT", 81, -36)
            PlayerLevelText:SetShown(not UnitHasVehiclePlayerFrameUI("player"))
        end)

        if not db.hidePvpTimerText then
            hooksecurefunc("PlayerFrame_UpdatePvPStatus", function()
                contentContext.PvpTimerText:ClearAllPoints()
                contentContext.PvpTimerText:SetPoint("BOTTOMLEFT", 8, 8)
            end)
        end

        local function GetFrameColor()
            local r, g, b = frameContainer.FrameTexture:GetVertexColor()
            frame.noPortraitMode.Texture:SetVertexColor(r, g, b)

            if not db.skipFrameColorCombo then
                -- Warlock: Soul Shards
                local soulShards = _G.WarlockPowerFrame
                if soulShards and class == "WARLOCK" then
                    for _, v in pairs({ soulShards:GetChildren() }) do
                        if v.Background then
                            v.Background:SetVertexColor(
                                math.max(r - 0.35, 0),
                                math.max(g - 0.35, 0),
                                math.max(b - 0.35, 0)
                            )
                        end
                    end
                end

                if PaladinPowerBarFrame and class == "PALADIN" then
                    if PaladinPowerBarFrame.Background then
                        PaladinPowerBarFrame.Background:SetDesaturated(true)
                        PaladinPowerBarFrame.Background:SetVertexColor(
                            math.max(r - 0.05, 0),
                            math.max(g - 0.05, 0),
                            math.max(b - 0.05, 0)
                        )
                    end
                    if PaladinPowerBarFrame.ActiveTexture then
                        PaladinPowerBarFrame.ActiveTexture:SetDesaturated(true)
                        PaladinPowerBarFrame.ActiveTexture:SetVertexColor(
                            math.max(r - 0.05, 0),
                            math.max(g - 0.05, 0),
                            math.max(b - 0.05, 0)
                        )
                    end
                end

                -- Monk: Chi points
                local monkChiPoints = _G.MonkHarmonyBarFrame
                if monkChiPoints then
                    local r, g, b = frameContainer.FrameTexture:GetVertexColor()

                    local function ColorMonkChi(tex, mul)
                        if not tex then return end
                        tex:SetVertexColor(
                            math.min(math.max(r * mul, 0), 1),
                            math.min(math.max(g * mul, 0), 1),
                            math.min(math.max(b * mul, 0), 1)
                        )
                    end

                    for _, v in pairs({ monkChiPoints:GetChildren() }) do
                        if v.Chi_BG then
                            ColorMonkChi(v.Chi_BG, 1.1)
                        end
                        if v.Chi_BG_Active then
                            ColorMonkChi(v.Chi_BG_Active, 0.85)
                        end
                    end
                end

                -- Evoker: Essence charges
                local evokerEssencePoints = _G.EssencePlayerFrame
                if evokerEssencePoints and class == "EVOKER" then
                    local function ColorEssence(tex, mul)
                        if not tex then return end
                        tex:SetVertexColor(
                            math.min(math.max(r * mul, 0), 1),
                            math.min(math.max(g * mul, 0), 1),
                            math.min(math.max(b * mul, 0), 1)
                        )
                    end

                    for _, v in pairs({ evokerEssencePoints:GetChildren() }) do
                        if v.EssenceFillDone and v.EssenceFillDone.CircBG then
                            ColorEssence(v.EssenceFillDone.CircBG, 1.05)
                        end
                        if v.EssenceFilling and v.EssenceFilling.EssenceBG then
                            ColorEssence(v.EssenceFilling.EssenceBG, 1.0)
                        end
                        if v.EssenceEmpty and v.EssenceEmpty.EssenceBG then
                            ColorEssence(v.EssenceEmpty.EssenceBG, 0.7)
                        end
                        if v.EssenceFillDone and v.EssenceFillDone.CircBGActive then
                            ColorEssence(v.EssenceFillDone.CircBGActive, 0.9)
                        end
                        if v.EssenceDepleting and v.EssenceDepleting.EssenceBG then
                            ColorEssence(v.EssenceDepleting.EssenceBG, 0.9)
                        end
                        if v.EssenceDepleting and v.EssenceDepleting.CircBGActive then
                            ColorEssence(v.EssenceDepleting.CircBGActive, 0.9)
                        end
                        if v.EssenceFillDone and v.EssenceFillDone.RimGlow then
                            ColorEssence(v.EssenceFillDone.RimGlow, 1.2)
                        end
                        if v.EssenceDepleting and v.EssenceDepleting.RimGlow then
                            ColorEssence(v.EssenceDepleting.RimGlow, 1.1)
                        end
                    end
                end

                if class == "DRUID" then
                    local function updateComboPointTextures()
                        local druidComboPoints = _G.DruidComboPointBarFrame or BBF.ComboPointBar
                        if not druidComboPoints then return end

                        local r, g, b = frameContainer.FrameTexture:GetVertexColor()

                        local function ColorDruidCP(tex, mul)
                            if not tex then return end
                            tex:SetVertexColor(
                                math.min(math.max(r * mul, 0), 1),
                                math.min(math.max(g * mul, 0), 1),
                                math.min(math.max(b * mul, 0), 1)
                            )
                        end

                        for _, v in pairs({ druidComboPoints:GetChildren() }) do
                            if v.BG_Inactive then
                                ColorDruidCP(v.BG_Inactive, 1.1)
                            end
                            if v.BG_Active then
                                ColorDruidCP(v.BG_Active, 1.03)
                            end
                        end
                    end

                    if GetShapeshiftFormID() == 1 or BBF.ComboPointBar then
                        -- Already in Cat Form, run immediately
                        updateComboPointTextures()
                    else
                        -- Not in Cat Form, wait for it
                        if not BBF.CatFormWatcher then
                            local f = CreateFrame("Frame")
                            f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
                            f:SetScript("OnEvent", function(self)
                                if GetShapeshiftFormID() == 1 then
                                    updateComboPointTextures()
                                    self:UnregisterAllEvents()
                                    self:SetScript("OnEvent", nil)
                                end
                            end)
                            BBF.CatFormWatcher = f
                        end
                    end
                end
            end
        end

        GetFrameColor()
        hooksecurefunc(frameContainer.FrameTexture, "SetVertexColor", GetFrameColor)

        local DEFAULT_X, DEFAULT_Y = 29, 28.5
        local DEFAULT_POINT, DEFAULT_RELATIVE_POINT = "TOP", "BOTTOM"

        local CLASS_RESOURCE_TYPES = {
            ROGUE = Enum.PowerType.ComboPoints,
            MONK  = Enum.PowerType.Chi,
        }

        local resourceFramePositions = {
            EVOKER = {
                x = 29, y = 32, scale = 1.05, point = "TOP", relativePoint = "BOTTOM",
                specs = {
                    -- Augmentation Evoker
                    [1473] = { x = 29, y = 22, scale = 1.05 },
                },
            },
            WARRIOR = { x = 28, y = 30 },
            ROGUE = {
                x = 48, y = 38, scale = 0.85,
                resourceByMax = {
                    [5] = { x = 33.5, y = 37, scale = 0.95 },
                    [6] = { x = 47,   y = 40,},
                    [7] = { x = 61,   y = 43.5, scale = 0.75},
                },
            },
            MAGE = { x = 33, y = 34, scale = 0.95 },
            PALADIN = { x = 31.5, y = 31, scale = 0.91 },
            DEATHKNIGHT = { x = 38, y = 36, scale = 0.90 },
            WARLOCK = { x = 32, y = 32.5, scale = 0.9 },
            DRUID = {
                x = 35, y = 34, scale = 0.90,
            },
            MONK = {
                x = 29.5, y = 31, scale = 0.96,
                resourceByMax = {
                    [5] = { x = 32, y = 32, scale = 1 },
                    [6] = { x = 34, y = 34, scale = 0.92 },
                },
            },
        }

        local function GetPlayerClassAndSpecPosition(maxResource)
            local specIndex = BBF.GetSpecialization()
            local specID = specIndex and BBF.GetSpecializationInfo(specIndex)
            local cfg = resourceFramePositions[class]

            local point = DEFAULT_POINT
            local relativePoint = DEFAULT_RELATIVE_POINT
            local x = DEFAULT_X
            local y = DEFAULT_Y
            local scale = 1

            if cfg then
                point = cfg.point or point
                relativePoint = cfg.relativePoint or relativePoint
                x = cfg.x or x
                y = cfg.y or y
                scale = cfg.scale or scale

                -- Spec-specific overrides
                if cfg.specs and specID and cfg.specs[specID] then
                    local s = cfg.specs[specID]
                    point = s.point or point
                    relativePoint = s.relativePoint or relativePoint
                    x = s.x or x
                    y = s.y or y
                    scale = s.scale or scale
                end

                -- Max-resource-specific overrides (Rogue combo points, Monk chi, etc.)
                if maxResource and cfg.resourceByMax and cfg.resourceByMax[maxResource] then
                    local r = cfg.resourceByMax[maxResource]
                    point = r.point or point
                    relativePoint = r.relativePoint or relativePoint
                    x = r.x or x
                    y = r.y or y
                    scale = r.scale or scale
                end
            end

            if playerDefaultTex == NoPortraitArt("Minus") then
                y = y + 15
            end

            return point, relativePoint, x, y, scale
        end

        local classConflicts = {
            ROGUE       = db.moveResourceToTargetRogue,
            DRUID       = db.moveResourceToTargetDruid,
            WARLOCK     = db.moveResourceToTargetWarlock,
            MAGE        = db.moveResourceToTargetMage,
            PALADIN     = db.moveResourceToTargetPaladin,
        }

        local function ResourceMovedElsewhere()
            return db["moveResource" .. class] or (db.moveResourceToTarget and classConflicts[class])
        end

        local function GetResourceOffsets()
            local maxResource
            local powerType = CLASS_RESOURCE_TYPES[class]
            if powerType then
                maxResource = UnitPowerMax("player", powerType)
            end

            local point, relativePoint, xOffset, yOffset, scale = GetPlayerClassAndSpecPosition(maxResource)
            if PlayerFrame.state == "vehicle" and not BBF.BigPlayerHealthbar() then
                xOffset = xOffset + 2
            end
            return point, relativePoint, xOffset, yOffset, scale
        end

        local classFrameLayoutX, classFrameLayoutY = 0, 0

        local function PinClassFrame()
            if not classFrame or ResourceMovedElsewhere() then return end
            if classFrame:IsProtected() or classFrame:GetParent() ~= PlayerBottomManagedFrameContainer then return end

            local point, relativePoint, xOffset, yOffset = GetResourceOffsets()
            local childScale = classFrame:GetScale()
            classFrame.bbfPinning = true
            classFrame:ClearAllPoints()
            classFrame:SetPoint(point, PlayerFrame, relativePoint, xOffset / childScale + classFrameLayoutX, (yOffset + (BBF.classResourceNudgeY or 0)) / childScale + classFrameLayoutY)
            classFrame.bbfPinning = false
        end

        if classFrame then
            hooksecurefunc(classFrame, "SetPoint", function(self, point, relativeTo, relativePoint, x, y)
                if self.bbfPinning or self.bbfNudging or point ~= "TOP" then return end
                if type(relativeTo) == "number" then
                    classFrameLayoutX, classFrameLayoutY = relativeTo, relativePoint or 0
                elseif relativeTo == nil or relativeTo == PlayerBottomManagedFrameContainer then
                    classFrameLayoutX, classFrameLayoutY = x or 0, y or 0
                else
                    return
                end
                PinClassFrame()
            end)
        end

        local resourceUpdatePending
        local function UpdateResourcePosition()
            if db.moveResourceToTarget and classConflicts[class] then
                return
            end

            if not InCombatLockdown() then
                local point, relativePoint, xOffset, yOffset, scale = GetResourceOffsets()
                if not db["moveResource" .. class] then
                    PlayerBottomManagedFrameContainer:ClearAllPoints()
                    PlayerBottomManagedFrameContainer:SetPoint(point, PlayerFrame, relativePoint, xOffset, yOffset)
                end
                PlayerBottomManagedFrameContainer:SetScale(scale)
                PlayerBottomManagedFrameContainer:SetFrameStrata("HIGH")
            elseif not resourceUpdatePending then
                resourceUpdatePending = true
                BBF.RunAfterCombat(function()
                    resourceUpdatePending = nil
                    UpdateResourcePosition()
                end)
            end
            PinClassFrame()
        end

        BBF.UpdateResourcePositionNoPortrait = UpdateResourcePosition
        BBF.PinClassFrameNoPortrait = PinClassFrame

        local vehicleWatcher = CreateFrame("Frame")
        vehicleWatcher:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
        vehicleWatcher:SetScript("OnEvent", function()
            UpdateResourcePosition()
        end)

        -- Watcher for classes whose layout depends on max resource (Rogue combos, Monk chi, etc.)
        if CLASS_RESOURCE_TYPES[class] then
            local watcher = CreateFrame("Frame")
            watcher:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
            watcher:RegisterEvent("TRAIT_CONFIG_UPDATED")
            watcher:RegisterEvent("UNIT_MAXPOWER")
            watcher:SetScript("OnEvent", function(self, event, unit)
                if event == "UNIT_MAXPOWER" and unit ~= "player" then
                    return
                end
                UpdateResourcePosition()
            end)
        end

        local function PlayerEliteFrame()
            local playerElite = frame.noPortraitMode.Texture
            local mode = BetterBlizzFramesDB.playerEliteFrameMode
            local hideLvl, alwaysHideLvl = BBF.PlayerLevelHideFlags()

            -- Set Elite style according to value
            if mode == 1 then -- Rare (Silver)
                playerElite:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
                playerElite:SetDesaturated(true)
            elseif mode == 2 then -- Boss (Silver Winged)
                playerElite:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite")
                playerElite:SetDesaturated(true)
            elseif mode == 3 then -- Boss (Gold Winged)
                playerElite:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
                playerElite:SetDesaturated(false)
            elseif mode > 3 then -- For modes > 3, always use UI-FocusFrame-Large regardless of hideLvl
                playerElite:SetTexture("Interface\\TargetingFrame\\UI-FocusFrame-Large")
                playerElite:SetDesaturated(false)
            else
                frame.noPortraitMode.Texture:SetTexture(playerDefaultTex)
                frameContainer.FrameFlash:SetTexture(playerFlashTex)
                frameContainer.FrameFlash:SetTexCoord(0, 1, 0, 1)
                contentMain.StatusTexture:SetTexture(playerFlashTex)
            -- elseif mode == 4 then -- Only 3 available for classic
            --     db.playerEliteFrameMode = 3
            --     playerElite:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
            --     playerElite:SetDesaturated(false)
            end
        end

        local function ToggleNoLevelFrame(noLvl)
            if noLvl then
                frame.noPortraitMode.Texture:SetTexture(playerDefaultTex)
                frameContainer.FrameFlash:SetTexture(playerFlashNoLvl)
                frameContainer.FrameFlash:SetTexCoord(0, 1, 0, 1)
                contentMain.StatusTexture:SetTexture(playerFlashTex)
            else
                frame.noPortraitMode.Texture:SetTexture(playerDefaultTex)
                frameContainer.FrameFlash:SetTexture(playerFlashTex)
                frameContainer.FrameFlash:SetTexCoord(0, 1, 0, 1)
                contentMain.StatusTexture:SetTexture(playerFlashTex)
            end
        end

        local function PlaceHealthBar()
            if db.noPortraitPixelBorder then
                BBF.ApplyPixelBorderLayout(frame)
                return
            end
            if frame.state == "vehicle" then return end
            BBF.RunAfterCombat(function()
                if frame.state == "vehicle" then return end
                hpContainer:ClearAllPoints()
                hpContainer:SetPoint("TOPLEFT", 85, -40)
                hpContainer.HealthBar:ClearAllPoints()
                hpContainer.HealthBar:SetPoint("TOPLEFT", hpContainer, "TOPLEFT", 0, 0)
                if not BBF.BigPlayerHealthbar() then
                    hpContainer:SetHeight(20)
                    hpContainer.HealthBar:SetHeight(20)
                end
            end)
        end
        if PlayerFrame_UpdateHealthBarVisuals then
            hooksecurefunc("PlayerFrame_UpdateHealthBarVisuals", PlaceHealthBar)
        end
        if BBF.UpdateBigPlayerHealthbar then
            hooksecurefunc(BBF, "UpdateBigPlayerHealthbar", PlaceHealthBar)
        end
        if db.noPortraitPixelBorder and PlayerFrame_UpdateManaBarVisuals then
            hooksecurefunc("PlayerFrame_UpdateManaBarVisuals", PlaceHealthBar)
        end

        local function ToPlayerArt()
            UpdateResourcePosition()
            PlaceHealthBar()

            if db.noPortraitPixelBorder then
                frame.noPortraitMode.Texture:SetAlpha(0)
                frame.noPortraitMode.Background:SetAlpha(0)
                if hpContainer.HealthBar.pixelBorderBackground then
                    hpContainer.HealthBar.pixelBorderBackground:SetAlpha(1)
                end
                if manaBar.pixelBorderBackground then
                    manaBar.pixelBorderBackground:SetAlpha(1)
                end
            else
                BBF.ApplyNoPortraitPlayerMask()

                BBF.RunAfterCombat(function()
                    manaBar:SetSize(127, 11)
                    manaBar:ClearAllPoints()
                    manaBar:SetPoint("TOPLEFT", 83, -60)
                end)
                manaBar.ManaBarMask:SetTexture("interface/hud/uipartyframeportraitoffmanamask")
                manaBar.ManaBarMask:SetSize(194, 24.5)
                manaBar.ManaBarMask:SetPoint("TOPLEFT", manaBar, "TOPLEFT", -34, 7)

                frame.noPortraitMode.Texture:SetAlpha(1)
                frame.noPortraitMode.Background:SetAlpha(1)
                if hpContainer.HealthBar.pixelBorderBackground then
                    hpContainer.HealthBar.pixelBorderBackground:SetAlpha(0)
                end
                if manaBar.pixelBorderBackground then
                    manaBar.pixelBorderBackground:SetAlpha(0)
                end
            end

            frame.noPortraitMode.Texture:Hide()

            frame.noPortraitMode.bbfVehicleTexture:Hide()

            frameContainer.FrameTexture:ClearAllPoints()
            frameContainer.FrameTexture:SetPoint("TOPLEFT", -19, 7)
            frameContainer.FrameTexture:SetAlpha(0)

            contentContext.RoleIcon:ClearAllPoints()
            contentContext.RoleIcon:SetPoint("TOPLEFT", 81, -36)

            --contentContext.GroupIndicator:ClearAllPoints()
            --contentContext.GroupIndicator:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -21, -33.5)
            contentContext.GroupIndicator:SetScale(0.88)
            PlayerFrameGroupIndicatorText:ClearAllPoints()
            PlayerFrameGroupIndicatorText:SetPoint("BOTTOM", frame.bbfName, "TOP", 0, 0)

            frame.noPortraitMode.Texture:SetSize(254, 46)
            if db.playerEliteFrame then
                PlayerEliteFrame()
                frameContainer.FrameFlash:SetTexture(playerFlashTex)
                frameContainer.FrameFlash:SetTexCoord(0, 1, 0, 1)
                contentMain.StatusTexture:SetTexture(playerFlashTex)
                -- Handle level text for playerEliteFrame
                local mode = BetterBlizzFramesDB.playerEliteFrameMode
                if mode > 3 and (alwaysHideLvl or (hideLvl and UnitLevel("player") == GetMaxLevelForPlayerExpansion())) then
                    -- Ensure level text is hidden when using UI-FocusFrame-Large
                    PlayerLevelText:SetParent(BBF.hiddenFrame)
                end
            else
                if alwaysHideLvl then
                    ToggleNoLevelFrame(true)
                elseif hideLvl then
                    if UnitLevel("player") == GetMaxLevelForPlayerExpansion() then
                        ToggleNoLevelFrame(true)
                    else
                        ToggleNoLevelFrame(false)
                    end
                else
                    ToggleNoLevelFrame(false)
                end
            end
            frame.noPortraitMode.Texture:SetTexCoord(0, 1, 0, 1)
            frame.noPortraitMode.Texture:ClearAllPoints()
            frame.noPortraitMode.Texture:SetPoint("TOPLEFT", 20, -38)
            frame.noPortraitMode.Texture:SetDrawLayer("BORDER")

            frameContainer.AlternatePowerFrameTexture:ClearAllPoints()
            frameContainer.AlternatePowerFrameTexture:SetPoint("TOPLEFT", -9, -8)
            frameContainer.AlternatePowerFrameTexture:SetAlpha(0)

            frameContainer.FrameFlash:SetParent((db.hideCombatGlow or db.noPortraitPixelBorder) and BBF.hiddenFrame or frame.noPortraitMode)
            frameContainer.FrameFlash:SetSize(255, 45)
            --frameContainer.FrameFlash:SetTexture(flashTex)
            --frameContainer.FrameFlash:SetTexCoord(0.9453125, 0, 0, 0.181640625)
            frameContainer.FrameFlash:ClearAllPoints()
            frameContainer.FrameFlash:SetAllPoints(frame.noPortraitMode.Texture)
            frameContainer.FrameFlash:SetDrawLayer("BORDER", 4)

            contentMain.StatusTexture:SetTexCoord(0, 1, 0, 1)
            contentMain.StatusTexture:ClearAllPoints()
            contentMain.StatusTexture:SetAllPoints(frame.noPortraitMode.Texture)
            contentMain.StatusTexture:SetParent(db.noPortraitPixelBorder and BBF.hiddenFrame or frame.noPortraitMode)
            contentMain.StatusTexture:SetDrawLayer("BORDER", 4)
            contentMain.StatusTexture:SetBlendMode("ADD")

            BBF.UpdateNoPortraitText(frame, "player")

            frameContainer.PlayerPortrait:ClearAllPoints()
            frameContainer.PlayerPortrait:SetPoint("TOPLEFT", 26, -23)
            frame.noPortraitMode.Texture:Show()

            local altbar = PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture:IsShown()
            frame.noPortraitMode.Texture:SetTexture(altbar and playerAltTex or playerDefaultTex)
        end

        hooksecurefunc("PlayerFrame_ToPlayerArt", function()
            ToPlayerArt()
        end)
        ToPlayerArt()

        local function ToVehicleArt()
            frameContainer.VehicleFrameTexture:ClearAllPoints()
            frameContainer.VehicleFrameTexture:SetPoint("TOPLEFT", 23, -20)
            frameContainer.VehicleFrameTexture:SetAlpha(0)

            frame.noPortraitMode.bbfVehicleTexture:Show()

            frame.noPortraitMode.Texture:SetSize(247, 45)
            frame.noPortraitMode.Texture:SetTexture(playerDefaultTex)
            frame.noPortraitMode.Texture:ClearAllPoints()
            frame.noPortraitMode.Texture:SetPoint("TOPLEFT", 26.5, -39)
            frame.noPortraitMode.Texture:SetTexCoord(0, 1, 0, 1)

            hpContainer.HealthBarMask:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", -34, 5)
            hpContainer.HealthBarMask:SetSize(185, 34)

            --hpContainer.HealthBarMask:SetSize(120, 32)

            frameContainer.FrameFlash:SetParent(frame)
            frameContainer.FrameFlash:SetSize(255, 45)
            frameContainer.FrameFlash:SetTexture(playerFlashTex)
            frameContainer.FrameFlash:SetTexCoord(0, 1, 0, 1)
            frameContainer.FrameFlash:ClearAllPoints()
            frameContainer.FrameFlash:SetAllPoints(frame.noPortraitMode.Texture)
            frameContainer.FrameFlash:SetDrawLayer("BACKGROUND")

            contentContext.RoleIcon:ClearAllPoints()
            contentContext.RoleIcon:SetPoint("TOPLEFT", 81, -36)

            contentMain.StatusTexture:SetTexture(playerFlashTex)
            contentMain.StatusTexture:SetTexCoord(0, 1, 0, 1)
            contentMain.StatusTexture:ClearAllPoints()
            contentMain.StatusTexture:SetAllPoints(frame.noPortraitMode.Texture)
            contentMain.StatusTexture:SetDrawLayer("BACKGROUND")


            -- hpContainer.LeftText:SetParent(frame.noPortraitMode)
            -- hpContainer.LeftText:ClearAllPoints()
            -- hpContainer.LeftText:SetPoint("LEFT", frame.noPortraitMode.Texture, "LEFT", 101, 3)
            -- hpContainer.RightText:SetParent(frame.noPortraitMode)
            -- hpContainer.RightText:ClearAllPoints()
            -- hpContainer.RightText:SetPoint("RIGHT", frame.noPortraitMode.Texture, "RIGHT", -38, 3)
            -- hpContainer.HealthBarText:SetParent(frame.noPortraitMode)
            -- hpContainer.HealthBarText:ClearAllPoints()
            -- hpContainer.HealthBarText:SetPoint("CENTER", frame.noPortraitMode.Texture, "CENTER", 34, 3)

            -- manaBar.LeftText:SetParent(frame.noPortraitMode)
            -- manaBar.LeftText:ClearAllPoints()
            -- manaBar.LeftText:SetPoint("LEFT", frame.noPortraitMode.Texture, "LEFT", 101, -9)
            -- manaBar.RightText:SetParent(frame.noPortraitMode)
            -- manaBar.RightText:ClearAllPoints()
            -- manaBar.RightText:SetPoint("RIGHT", frame.noPortraitMode.Texture, "RIGHT", -7, -9)
            -- manaBar.ManaBarText:SetParent(frame.noPortraitMode)
            -- manaBar.ManaBarText:ClearAllPoints()
            -- manaBar.ManaBarText:SetPoint("CENTER", frame.noPortraitMode.Texture, "CENTER", 52, -9)

            frameContainer.PlayerPortrait:ClearAllPoints()
            frameContainer.PlayerPortrait:SetPoint("TOPLEFT", 23, -17)
        end

        hooksecurefunc("PlayerFrame_ToVehicleArt", function(self)
            ToVehicleArt()
            UpdateResourcePosition()
        end)

        hooksecurefunc(TotemFrame, "Update", function(self)
            for child in self.totemPool:EnumerateActive() do
                child.Border:SetSize(39, 39)
                child.Border:SetTexture("Interface\\CharacterFrame\\TotemBorder")
                child.Border:ClearAllPoints()
                child.Border:SetPoint("CENTER")
            end
        end)

        TotemFrame:SetScale(0.85)
        hooksecurefunc(TotemFrame, "SetPoint", function(self)
            if self.changing then return end
            if classFrame and classFrame:IsShown() then return end
            self.changing = true
            local a, b, c, d, e = self:GetPoint()
            self:ClearAllPoints()
            self:SetPoint(a, b, c, d, e - 5)
            self.changing = false
        end)

        if db.noPortraitModesDesaturated or db.classColorFrameTexture then
            frame.noPortraitMode.Texture:SetDesaturated(true)
        end

    elseif frame == PetFrame then
        PetFrame:SetSize(120, 49)
        PetPortrait:ClearAllPoints()
        PetPortrait:SetPoint("TOPLEFT", 7, -6)
        PetPortrait:SetAlpha(0)

        PetFrameTexture:SetSize(130, 33)
        PetFrameTexture:SetTexture(petDefaultTex)
        hooksecurefunc(PetFrameTexture, "SetTexture", function(self)
            if self.changing then return end
            self.changing = true
            self:SetTexture(petDefaultTex)
            self.changing = false
        end)
        PetFrameTexture:ClearAllPoints()
        PetFrameTexture:SetPoint("TOPLEFT", 3, -9)

        PetFrameFlash:SetSize(130, 33)
        PetFrameFlash:SetTexture(petDefaultTex)
        PetFrameFlash:SetPoint("TOPLEFT", 3, -9)
        PetFrameFlash:SetTexCoord(0, 1, 0, 1)
        PetFrameFlash:SetParent(frame.noPortraitMode)
        PetFrameFlash:SetDrawLayer("BORDER", 4)

        BBF.ShowHealthGreen(PetFrameHealthBar)
        PlaceNoPortraitPetHealth()
        PetFrameHealthBar:SetFrameLevel(1)


        PetFrameManaBar:SetFrameLevel(1)
        PetFrame.Background = PetFrameHealthBar:CreateTexture(nil, "BACKGROUND")
        PetFrame.Background:SetColorTexture(0,0,0,0.45)
        BindArtBackground(PetFrame.Background, PetFrameTexture, function() return petDefaultTex end)

        if not db.noPortraitPixelBorder then
            PetFrameManaBar:SetSize(71, 8)
            PetFrameManaBar:ClearAllPoints()
            PetFrameManaBar:SetPoint("TOPRIGHT", -17, -25)

            PetFrameManaBarMask:SetTexture("interface/hud/uipartyframeportraitoffmanamask")
            PetFrameManaBarMask:SetSize(98, 17)
            SetXYPoint(PetFrameManaBarMask, -14, 4)
        end

        if not PetFrame.BBFTextFrame then
            PetFrame.BBFTextFrame = CreateFrame("Frame", nil, PetFrame)
            PetFrame.BBFTextFrame:SetAllPoints(PetFrame)
        end

        PetFrameHealthBarText:SetParent(PetFrame.BBFTextFrame)
        PetFrameHealthBarTextLeft:SetParent(PetFrame.BBFTextFrame)
        PetFrameHealthBarTextRight:SetParent(PetFrame.BBFTextFrame)
        PetFrameManaBarText:SetParent(PetFrame.BBFTextFrame)
        PetFrameManaBarTextLeft:SetParent(PetFrame.BBFTextFrame)
        PetFrameManaBarTextRight:SetParent(PetFrame.BBFTextFrame)

        BBF.UpdateNoPortraitText(PetFrame, "pet")
        PetFrameOverAbsorbGlow:SetParent(PetFrame)
        PetFrameOverAbsorbGlow:SetDrawLayer("ARTWORK", 7)

        PetAttackModeTexture:SetParent(BBF.hiddenFrame)

        if PetFrameHappiness then
            PetFrameHappiness:ClearAllPoints()
            if db.noPortraitPixelBorder then
                PetFrameHappiness:SetSize(22, 21)
                PetFrameHappiness:SetPoint("RIGHT", PetFrame, "LEFT", 35, 5)
            else
                PetFrameHappiness:SetPoint("RIGHT", PetFrame, "LEFT", 34, 2)
            end
        end

        PetHitIndicator:ClearAllPoints()
        PetHitIndicator:SetPoint("CENTER", PetFrame, "TOPLEFT", 28, -27)
        PetHitIndicator:SetParent(BBF.hiddenFrame)

        if db.noPortraitPixelBorder then
            PetFrameTexture:SetAlpha(0)
            PetFrame.Background:SetAlpha(0)

            BBF.WatchPixelBorderScale(PetFrame)
            BBF.ApplyPixelBorderLayout(PetFrame)

            local maxBorderLevel = 0
            if PetFrameHealthBar.BBFPixelBorder then
                maxBorderLevel = math.max(maxBorderLevel, PetFrameHealthBar.BBFPixelBorder:GetFrameLevel())
            end
            if PetFrameManaBar.BBFPixelBorder then
                maxBorderLevel = math.max(maxBorderLevel, PetFrameManaBar.BBFPixelBorder:GetFrameLevel())
            end
            if PetFrame.BBFTextFrame and maxBorderLevel > 0 then
                PetFrame.BBFTextFrame:SetFrameLevel(maxBorderLevel + 1)
            end
        else
            PetFrameTexture:SetAlpha(1)
            PetFrame.Background:SetAlpha(1)

            if PetFrameHealthBar.pixelBorderBackground then
                PetFrameHealthBar.pixelBorderBackground:SetAlpha(0)
            end
            if PetFrameManaBar.pixelBorderBackground then
                PetFrameManaBar.pixelBorderBackground:SetAlpha(0)
            end
        end

        if db.noPortraitModesDesaturated then
            PetFrameTexture:SetDesaturated(true)
        end
    end
end

local fancyManas = {
    ["INSANITY"] = true,
    ["MAELSTROM"] = true,
    ["FURY"] = true,
    ["LUNAR_POWER"] = true,
    ["SOUL_FRAGMENTS"] = true, -- alt mana, powerName (as opposed to powerType)
}

local function AdjustAlternateBars()
    if not BBF.HasNoPortrait("player") then return end
    local db = BetterBlizzFramesDB
    local function SetupAltStyleBar(bar, centerText, leftText, rightText)
        if not bar then return end

        -- Check if only mana is hidden but not the alt bar itself
        local shouldMoveUp = db.hideUnitFramePlayerMana and not db.hideUnitFramePlayerSecondResource and not BBF.BigPlayerHealthbar()
        local yOffset = shouldMoveUp and 11 or 0

        if db.noPortraitPixelBorder then
            BBF.RunAfterCombat(function()
                local point, _, barRect = BBF.PixelBorderAltRect()
                bar:SetSize(barRect.w, barRect.h)
                bar:ClearAllPoints()
                bar:SetPoint(point, PlayerFrame, point, barRect.x, barRect.y)
            end)

            local point, rect = BBF.PixelBorderAltRect()
            BBF.PlacePixelBorderBox(bar, PlayerFrame, point, rect)

            if bar.PowerBarMask and bar.BBFPositionFrame then
                PlaceSquareMask(bar.PowerBarMask, bar.BBFPositionFrame)
            end
        else
            BBF.RunAfterCombat(function()
                bar:SetSize(126, 9)
                bar:ClearAllPoints()
                bar:SetPoint("BOTTOMLEFT", 86, 19.2 + yOffset)
            end)

            if bar.PowerBarMask then
                bar.PowerBarMask:ClearAllPoints()
                bar.PowerBarMask:SetPoint("TOPLEFT", bar, "TOPLEFT", -2, 3)
            end
        end

        if not bar.s then
            bar.s = CreateFrame("Frame", nil, bar)
            bar.s:SetFrameStrata("HIGH")
            bar.s:SetAllPoints(bar)
        end

        -- Set frame level above pixel borders if they exist
        if db.noPortraitPixelBorder and bar.BBFPixelBorder then
            bar.s:SetFrameLevel(bar.BBFPixelBorder:GetFrameLevel() + 1)
        else
            bar.s:SetFrameLevel(bar:GetFrameLevel() + 10)
        end

        if centerText then
            centerText:SetParent(bar.s)
            centerText:ClearAllPoints()
            centerText:SetPoint("CENTER", bar.s, "CENTER", 0, -0.5)
            centerText:Show()
        end

        if leftText then
            leftText:SetParent(bar.s)
            leftText:ClearAllPoints()
            leftText:SetPoint("LEFT", bar.s, "LEFT", 0, -0.5)
            leftText:Show()
        end

        if rightText then
            rightText:SetParent(bar.s)
            rightText:ClearAllPoints()
            rightText:SetPoint("RIGHT", bar.s, "RIGHT", -4, -0.5)
            rightText:Show()
        end

        if BBF.UnitFrameTextureOn("mana") then
            if not bar.bbfAltHooked then
                bar.bbfAltHooked = true
                local color = PowerBarColor[bar.powerType]
                if not color then
                    color = bar.powerName == ("SOUL_FRAGMENTS" and { r = 0.11, g = 0.34, b = 0.71 }) or
                    PowerBarColor["MANA"]
                end

                bar.keepFancyManas = BetterBlizzFramesDB.changeUnitFrameManaBarTextureKeepFancy
                bar.bbfPowerToken = bar.powerToken or bar.powerName

                local r, g, b = color.r, color.g, color.b

                if bar.powerName == "SOUL_FRAGMENTS" then
                    hooksecurefunc(bar, "EvaluateUnit", function(self)
                        if bar.keepFancyManas and fancyManas[bar.bbfPowerToken] then return end
                        if self.inVoidMetamorphosis then
                            r, g, b = 0.35, 0.25, 0.73
                        else
                            r, g, b = 0.11, 0.34, 0.71
                        end

                        -- Check for custom power colors if enabled
                        if BetterBlizzFramesDB.customHealthbarColors and BetterBlizzFramesDB.customPowerColors and BetterBlizzFramesDB.customColorsUnitFrames then
                            local powerToken = self.powerToken or self.powerName
                            if powerToken and BBF.GetCustomPowerColor then
                                local customR, customG, customB = BBF.GetCustomPowerColor(powerToken)
                                if customR then
                                    r, g, b = customR, customG, customB
                                end
                            end
                        end

                        self:SetStatusBarTexture(BBF.manaTexture)
                        self:SetStatusBarColor(r, g, b)
                    end)
                else
                    hooksecurefunc(bar, "EvaluateUnit", function(self)
                        if bar.keepFancyManas and fancyManas[bar.bbfPowerToken] then return end

                        -- Check for custom power colors if enabled
                        if BetterBlizzFramesDB.customHealthbarColors and BetterBlizzFramesDB.customPowerColors and BetterBlizzFramesDB.customColorsUnitFrames then
                            local powerToken = self.powerToken or self.powerName
                            if powerToken and BBF.GetCustomPowerColor then
                                local customR, customG, customB = BBF.GetCustomPowerColor(powerToken)
                                if customR then
                                    r, g, b = customR, customG, customB
                                end
                            end
                        end

                        self:SetStatusBarTexture(BBF.manaTexture)
                        self:SetStatusBarColor(r, g, b)
                    end)
                end
            end
        end
    end

    SetupAltStyleBar(
        AlternatePowerBar,
        AlternatePowerBarText,
        AlternatePowerBar.LeftText,
        AlternatePowerBar.RightText
    )

    if class == "MONK" and MonkStaggerBar then
        SetupAltStyleBar(
            MonkStaggerBar,
            MonkStaggerBarText,
            MonkStaggerBar.LeftText,
            MonkStaggerBar.RightText
        )
    end

    if class == "EVOKER" and EvokerEbonMightBar then
        SetupAltStyleBar(
            EvokerEbonMightBar,
            EvokerEbonMightBarText,
            EvokerEbonMightBar.LeftText,
            EvokerEbonMightBar.RightText
        )
    end

    if class == "DEMONHUNTER" and DemonHunterSoulFragmentsBar then
        SetupAltStyleBar(
            DemonHunterSoulFragmentsBar,
            DemonHunterSoulFragmentsBar.TextString,
            DemonHunterSoulFragmentsBar.LeftText,
            DemonHunterSoulFragmentsBar.RightText
        )
    end

    local noPortraitModeColorTargets = {
        AlternatePowerBar.Border,
        AlternatePowerBar.LeftBorder,
        AlternatePowerBar.RightBorder,
    }

    local function GetFrameColor()
        local r, g, b = PlayerFrame.PlayerFrameContainer.FrameTexture:GetVertexColor()
        for _, frame in pairs(noPortraitModeColorTargets) do
            if frame then
                frame:SetVertexColor(r, g, b)
            end
        end
    end

    GetFrameColor()
    hooksecurefunc(PlayerFrame.PlayerFrameContainer.FrameTexture, "SetVertexColor", GetFrameColor)
end

function BBF.ApplyPixelBorderAltBar()
    local point, rect, barRect = BBF.PixelBorderAltRect()
    if not point then return end
    for _, bar in ipairs({ AlternatePowerBar, MonkStaggerBar, EvokerEbonMightBar, DemonHunterSoulFragmentsBar }) do
        if bar and bar.bbfPixelAltBox then
            BBF.PlacePixelBorderBox(bar, PlayerFrame, point, rect)
            BBF.RunAfterCombat(function()
                bar:SetSize(barRect.w, barRect.h)
                bar:ClearAllPoints()
                bar:SetPoint(point, PlayerFrame, point, barRect.x, barRect.y)
            end)
            if bar.PowerBarMask then
                PlaceSquareMask(bar.PowerBarMask, bar.bbfPixelAltBox)
            end
        end
    end
end

local function MakeClassicPartyFrame()
    BBF.partyNoPortraitApplied = true
    for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
        local overlay = frame.PartyMemberOverlay
        local hpContainer = frame.HealthBarContainer
        local manaBar = frame.ManaBar
        local auras = frame.AuraFrameContainer

        overlay:SetFrameStrata("MEDIUM")
        overlay:SetFrameLevel(750)
        frame.Texture:SetSize(152, 34)
        frame.Texture:SetTexture(partyDefaultTex)
        frame.Texture:SetTexCoord(0, 1, 0, 1)
        frame.Texture:ClearAllPoints()
        frame.Texture:SetPoint("TOPLEFT", 4, -11)
        frame.Texture:SetDrawLayer("ARTWORK", 7)
        frame.Texture:SetParent(hpContainer)

        frame.Portrait:SetAlpha(0)
        frame.Portrait:SetParent(BBF.hiddenFrame)

        frame.Flash:SetSize(152, 34)
        frame.Flash:SetTexture(partyDefaultTex)
        frame.Flash:SetTexCoord(0, 1, 0, 1)
        frame.Flash:ClearAllPoints()
        frame.Flash:SetAllPoints(frame.Texture)

        overlay.Status:SetTexture(partyDefaultTex)
        overlay.Status:SetTexCoord(0, 1, 0, 1)
        overlay.Status:ClearAllPoints()
        overlay.Status:SetAllPoints(frame.Texture)
        overlay.Status:SetDrawLayer("BORDER", 4)
        overlay.Disconnect:SetSize(25, 25)
        overlay.Disconnect:ClearAllPoints()
        overlay.Disconnect:SetPoint("LEFT", overlay, "LEFT", 32, 13)


        overlay.LeaderIcon:SetSize(14,14)
        --AdjustFramePoint(overlay.LeaderIcon, nil, -6)
        overlay.LeaderIcon:ClearAllPoints()
        overlay.LeaderIcon:SetPoint("BOTTOM", overlay, "TOP", -12.5, -13)
        overlay.GuideIcon:ClearAllPoints()
        overlay.GuideIcon:SetPoint("BOTTOM", overlay, "TOP", -12.5, -13)
        overlay.RoleIcon:SetSize(9, 9)
        overlay.RoleIcon:ClearAllPoints()
        overlay.RoleIcon:SetPoint("BOTTOMLEFT", 38.5, 35.5)
        overlay.PVPIcon:SetParent(BBF.hiddenFrame)

        frame.Background = frame:CreateTexture(nil, "BACKGROUND")
        frame.Background:SetColorTexture(0,0,0,0.45)
        BindArtBackground(frame.Background, frame.Texture, partyDefaultTex)
        frame.BgMask = frame:CreateMaskTexture()
        frame.BgMask:SetAllPoints(frame.Background)
        frame.BgMask:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\masks\\frameMask.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        frame.Background:AddMaskTexture(frame.BgMask)



        frame.bbfName:ClearAllPoints()
        frame.bbfName:SetPoint("BOTTOM", frame.Texture, "TOP", 0, (BetterBlizzFramesDB.noPortraitPixelBorder and NoPortraitBigParty()) and -2 or 0)
        frame.bbfName:SetWidth(76)
        frame.bbfName:SetScale(0.85)
        frame.bbfName:SetJustifyH("CENTER")

        -- Create text wrapper frame for proper layering above pixel borders
        if not frame.BBFTextFrame then
            frame.BBFTextFrame = CreateFrame("Frame", nil, frame)
            frame.BBFTextFrame:SetAllPoints(frame)
            frame.BBFTextFrame:SetFrameStrata("MEDIUM")
            frame.BBFTextFrame:SetFrameLevel(600)
        end

        hpContainer.LeftText:SetParent(frame.BBFTextFrame)
        hpContainer.LeftText:SetScale(0.72)
        hpContainer.RightText:SetParent(frame.BBFTextFrame)
        hpContainer.RightText:SetScale(0.72)
        hpContainer.CenterText:SetParent(frame.BBFTextFrame)
        hpContainer.CenterText:SetScale(0.72)
        manaBar.TextString:SetParent(frame.BBFTextFrame)
        manaBar.TextString:SetScale(0.72)
        manaBar.LeftText:SetParent(frame.BBFTextFrame)
        manaBar.LeftText:SetScale(0.72)
        manaBar.RightText:SetParent(frame.BBFTextFrame)
        manaBar.RightText:SetScale(0.72)


        local db = BetterBlizzFramesDB
        if db.noPortraitPixelBorder then
            frame.Texture:SetAlpha(0)
            frame.Background:SetAlpha(0)

            BBF.WatchPixelBorderScale(frame)
            BBF.ApplyPixelBorderLayout(frame)

            overlay.Status:SetParent(BBF.hiddenFrame)
            frame.Flash:SetParent(BBF.hiddenFrame)
            -- local function ColorBorder(bar, r, g, b, a)
            --     if not bar or not bar.BBFBlackBorder then return end
            --     for _, edge in ipairs(bar.BBFBlackBorder) do
            --         edge:SetColorTexture(r, g, b, a or 1)
            --     end
            -- end
            -- hooksecurefunc(overlay.Status, "SetVertexColor", function(_, r, g, b, a)
            --     if not (r and g and b) then
            --         return
            --     end

            --     if r == g and g == b then
            --         r, g, b = 0, 0, 0
            --     end

            --     ColorBorder(hpContainer.HealthBar, r, g, b, a)
            --     ColorBorder(manaBar, r, g, b, a)
            -- end)

            local maxBorderLevel = 0
            if hpContainer.HealthBar.BBFPixelBorder then
                maxBorderLevel = math.max(maxBorderLevel, hpContainer.HealthBar.BBFPixelBorder:GetFrameLevel())
            end
            if manaBar.BBFPixelBorder then
                maxBorderLevel = math.max(maxBorderLevel, manaBar.BBFPixelBorder:GetFrameLevel())
            end
            if frame.BBFTextFrame and maxBorderLevel > 0 then
                frame.BBFTextFrame:SetFrameLevel(maxBorderLevel + 1)
            end
        else
            frame.Texture:SetAlpha(1)
            frame.Background:SetAlpha(1)

            if hpContainer.HealthBar.pixelBorderBackground then
                hpContainer.HealthBar.pixelBorderBackground:SetAlpha(0)
            end
            if manaBar.pixelBorderBackground then
                manaBar.pixelBorderBackground:SetAlpha(0)
            end
        end

        local function hbAdjust()
            frame.bbfName:ClearAllPoints()
            frame.bbfName:SetPoint("BOTTOM", frame.Texture, "TOP", 0, (db.noPortraitPixelBorder and NoPortraitBigParty()) and -2 or 0)
            frame.bbfName:SetWidth(76)
            local bars = BBF.PartyBars(frame)

            if db.noPortraitPixelBorder then
                BBF.ApplyPixelBorderLayout(frame)

                auras:ClearAllPoints()
                auras:SetScale(1.1)
                auras:SetPoint("TOPLEFT", manaBar, "BOTTOMLEFT", 0, -3)

            else
                bars:ClearAllPoints(hpContainer)
                if NoPortraitBigParty() then
                    bars:SetPoint(hpContainer, "TOPLEFT", frame, "TOPLEFT", 43, -13)
                    bars:SetSize(hpContainer, 73, 22)
                else
                    bars:SetPoint(hpContainer, "TOPLEFT", frame, "TOPLEFT", 45, -20)
                    bars:SetSize(hpContainer, 70, 10)
                end
                bars:ClearAllPoints(hpContainer.HealthBar)
                if NoPortraitBigParty() then
                    bars:SetPoint(hpContainer.HealthBar, "TOPLEFT", hpContainer, "TOPLEFT", 0, 0)
                    bars:SetSize(hpContainer.HealthBar, 73, 22)
                else
                    bars:SetPoint(hpContainer.HealthBar, "TOPLEFT", hpContainer, "TOPLEFT", -2, 7)
                    bars:SetSize(hpContainer.HealthBar, 74, 14)
                end
                bars:ClearAllPoints(manaBar)
                bars:SetPoint(manaBar, "TOPLEFT", hpContainer, "TOPLEFT", -5, -7)
                bars:SetSize(manaBar, 81, 10)

                hpContainer.HealthBarMask:ClearAllPoints()
                if NoPortraitBigParty() then
                    hpContainer.HealthBarMask:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Mask")
                    hpContainer.HealthBarMask:SetSize(80.5, 58)
                    hpContainer.HealthBarMask:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", -2, 16)
                else
                    hpContainer.HealthBarMask:SetAtlas("UI-HUD-UnitFrame-Party-PortraitOn-Bar-Health-Mask")
                    hpContainer.HealthBarMask:SetSize(137, 24)
                    hpContainer.HealthBarMask:SetPoint("TOPLEFT", hpContainer, "TOPLEFT", -33, 11)
                end

                manaBar.ManaBarMask:SetTexture("interface/hud/uipartyframeportraitoffmanamask")
                manaBar.ManaBarMask:SetSize(114, 16)
                manaBar.ManaBarMask:ClearAllPoints()
                manaBar.ManaBarMask:SetPoint("TOPLEFT", frame, "TOPLEFT", 23, -24)
            end

            overlay.LeaderIcon:ClearAllPoints()
            overlay.LeaderIcon:SetPoint("BOTTOM", overlay, "TOP", -12.5, -13)
            overlay.GuideIcon:ClearAllPoints()
            overlay.GuideIcon:SetPoint("BOTTOM", overlay, "TOP", -12.5, -13)
            overlay.RoleIcon:ClearAllPoints()
            overlay.RoleIcon:SetPoint("BOTTOMLEFT", 38.5, 35.5)

            BBF.UpdateNoPortraitText(nil, "party")
        end

        hbAdjust()


        BBF.HookPartyArt(frame, function(self)
            self.Texture:SetTexture(partyDefaultTex)

            hbAdjust()


            --AdjustFramePoint(frame.HealthBarContainer.HealthBarMask, nil, -3)
            --hpContainer.HealthBarMask:SetPoint("TOPLEFT", frame.HealthBarContainer.HealthBar, "TOPLEFT", -29, 0)

            BBF.UpdateNoPortraitText(nil, "party")

            frame.Flash:SetTexture(partyDefaultTex)
            frame.Flash:SetTexCoord(0, 1, 0, 1)
            frame.Flash:ClearAllPoints()
            frame.Flash:SetAllPoints(frame.Texture)

            overlay.Status:SetTexture(partyDefaultTex)
            overlay.Status:SetTexCoord(0, 1, 0, 1)
            overlay.Status:ClearAllPoints()
            overlay.Status:SetAllPoints(frame.Texture)
        end)
    end

end


local function UpdatePartyFrameManaVisibility()
    local db = BetterBlizzFramesDB
    -- PartyFrames
    if PartyFrame and PartyFrame.PartyMemberFramePool then
        for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
            local manaBar = frame.ManaBar
            if manaBar then
                if db.hideDefaultPartyFramesMana or NoPortraitBigParty() then
                    manaBar:SetAlpha(0)
                    if manaBar.TextString then
                        manaBar.TextString:SetAlpha(0)
                    end
                    if manaBar.LeftText then
                        manaBar.LeftText:SetAlpha(0)
                    end
                    if manaBar.RightText then
                        manaBar.RightText:SetAlpha(0)
                    end
                    if manaBar.BBFPixelBorder then
                        manaBar.BBFPixelBorder:Hide()
                    end
                    if manaBar.pixelBorderBackground then
                        manaBar.pixelBorderBackground:SetAlpha(0)
                    end
                else
                    manaBar:SetAlpha(1)
                    if manaBar.TextString then
                        manaBar.TextString:SetAlpha(1)
                    end
                    if manaBar.LeftText then
                        manaBar.LeftText:SetAlpha(1)
                    end
                    if manaBar.RightText then
                        manaBar.RightText:SetAlpha(1)
                    end
                    if db.noPortraitPixelBorder and manaBar.BBFPixelBorder then
                        manaBar.BBFPixelBorder:Show()
                    end
                    if db.noPortraitPixelBorder and manaBar.pixelBorderBackground then
                        manaBar.pixelBorderBackground:SetAlpha(1)
                    end
                end
                if not db.noPortraitPixelBorder then
                    if frame.Texture then
                        frame.Texture:SetTexture(partyDefaultTex)
                    end
                    if frame.Flash then
                        frame.Flash:SetTexture(partyDefaultTex)
                    end
                    if frame.PartyMemberOverlay and frame.PartyMemberOverlay.Status then
                        frame.PartyMemberOverlay.Status:SetTexture(partyDefaultTex)
                    end
                end
            end
        end
    end
end

function BBF.UpdateNoPortraitManaVisibility()
    local db = BetterBlizzFramesDB
    BBF.UpdateDefaultPetFrameMana()
    BBF.UpdateDefaultTotFrameMana()
    local classPowerBar = PlayerFrame.classPowerBar
    if classPowerBar and classPowerBar.FillOverlay then
        classPowerBar.FillOverlay:SetAlpha((db.hideUnitFramePlayerMana or BBF.BigPlayerHealthbar()) and 0 or 1)
    end
    if db.classicFrames then
        if db.hideUnitFramePlayerSecondResource then
            if AlternatePowerBar then
                AlternatePowerBar:SetAlpha(0)
            end
            if MonkStaggerBar then
                MonkStaggerBar:SetAlpha(0)
            end
            if EvokerEbonMightBar then
                EvokerEbonMightBar:SetAlpha(0)
            end
            if DemonHunterSoulFragmentsBar then
                DemonHunterSoulFragmentsBar:SetAlpha(0)
            end
            BBF.changedSecondResourceAlpha = true
        else
            if BBF.changedSecondResourceAlpha then
                if AlternatePowerBar then
                    AlternatePowerBar:SetAlpha(1)
                end
                if MonkStaggerBar then
                    MonkStaggerBar:SetAlpha(1)
                end
                if EvokerEbonMightBar then
                    EvokerEbonMightBar:SetAlpha(1)
                end
                if DemonHunterSoulFragmentsBar then
                    DemonHunterSoulFragmentsBar:SetAlpha(1)
                end
            end
            BBF.changedSecondResourceAlpha = nil
        end

        local manaBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar
        local manaAlpha = db.hideUnitFramePlayerMana and 0 or 1
        manaBar:GetParent():SetAlpha(manaAlpha)
        manaBar.LeftText:SetAlpha(manaAlpha)
        manaBar.RightText:SetAlpha(manaAlpha)
        manaBar.ManaBarText:SetAlpha(manaAlpha)
        return
    end
    if not db.noPortraitModes then return end
    UpdateTextureVariables()

    local noPortraitPlayer = BBF.HasNoPortrait("player")
    local noPortraitTarget = BBF.HasNoPortrait("target")
    local noPortraitFocus = BBF.HasNoPortrait("focus")
    local noPortraitPet = BBF.HasNoPortrait("pet")
    local hidePlayerMana = db.hideUnitFramePlayerMana

    -- Hide PlayerFrame Mana
    if noPortraitPlayer then
        local manaBarArea = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea
        if manaBarArea then
            manaBarArea:SetAlpha((hidePlayerMana or BBF.BigPlayerHealthbar()) and 0 or 1)
        end
    end

    -- Hide PetFrame Mana
    local hidePetMana = HidePetMana()
    if noPortraitPet then
        PlaceNoPortraitPetHealth()
        BBF.UpdateNoPortraitText(PetFrame, "pet")
        if BBF.ApplyTextArea then
            BBF.ApplyTextArea(PetFrame)
        end
        local petMana = PetFrameManaBar
        if petMana then
            petMana:SetAlpha(hidePetMana and 0 or 1)
            if hidePetMana then
                petMana.TextString:SetAlpha(0)
                petMana.LeftText:SetAlpha(0)
                petMana.RightText:SetAlpha(0)
            elseif not db.hidePetText then
                petMana.TextString:SetAlpha(1)
                petMana.LeftText:SetAlpha(1)
                petMana.RightText:SetAlpha(1)
            end
        end
        if not db.noPortraitPixelBorder and PetFrameTexture then
            PetFrameTexture:SetTexture(petDefaultTex)
            PetFrameFlash:SetTexture(petDefaultTex)
        end
    end

    -- Hide PlayerFrame Second Resource (AlternatePowerBar)
    if noPortraitPlayer then
        if db.hideUnitFramePlayerSecondResource then
            if AlternatePowerBar then
                AlternatePowerBar:SetAlpha(0)
                if AlternatePowerBar.BBFPixelBorder then
                    AlternatePowerBar.BBFPixelBorder:Hide()
                end
                if AlternatePowerBar.pixelBorderBackground then
                    AlternatePowerBar.pixelBorderBackground:SetAlpha(0)
                end
            end
            if MonkStaggerBar then
                MonkStaggerBar:SetAlpha(0)
                if MonkStaggerBar.BBFPixelBorder then
                    MonkStaggerBar.BBFPixelBorder:Hide()
                end
                if MonkStaggerBar.pixelBorderBackground then
                    MonkStaggerBar.pixelBorderBackground:SetAlpha(0)
                end
            end
            if EvokerEbonMightBar then
                EvokerEbonMightBar:SetAlpha(0)
                if EvokerEbonMightBar.BBFPixelBorder then
                    EvokerEbonMightBar.BBFPixelBorder:Hide()
                end
                if EvokerEbonMightBar.pixelBorderBackground then
                    EvokerEbonMightBar.pixelBorderBackground:SetAlpha(0)
                end
            end
            if DemonHunterSoulFragmentsBar then
                DemonHunterSoulFragmentsBar:SetAlpha(0)
                if DemonHunterSoulFragmentsBar.BBFPixelBorder then
                    DemonHunterSoulFragmentsBar.BBFPixelBorder:Hide()
                end
                if DemonHunterSoulFragmentsBar.pixelBorderBackground then
                    DemonHunterSoulFragmentsBar.pixelBorderBackground:SetAlpha(0)
                end
            end
        else
            if AlternatePowerBar then
                AlternatePowerBar:SetAlpha(1)
                if AlternatePowerBar.BBFPixelBorder then
                    AlternatePowerBar.BBFPixelBorder:Show()
                end
                if AlternatePowerBar.pixelBorderBackground then
                    AlternatePowerBar.pixelBorderBackground:SetAlpha(1)
                end
            end
            if MonkStaggerBar then
                MonkStaggerBar:SetAlpha(1)
                if MonkStaggerBar.BBFPixelBorder then
                    MonkStaggerBar.BBFPixelBorder:Show()
                end
                if MonkStaggerBar.pixelBorderBackground then
                    MonkStaggerBar.pixelBorderBackground:SetAlpha(1)
                end
            end
            if EvokerEbonMightBar then
                EvokerEbonMightBar:SetAlpha(1)
                if EvokerEbonMightBar.BBFPixelBorder then
                    EvokerEbonMightBar.BBFPixelBorder:Show()
                end
                if EvokerEbonMightBar.pixelBorderBackground then
                    EvokerEbonMightBar.pixelBorderBackground:SetAlpha(1)
                end
            end
            if DemonHunterSoulFragmentsBar then
                DemonHunterSoulFragmentsBar:SetAlpha(1)
                if DemonHunterSoulFragmentsBar.BBFPixelBorder then
                    DemonHunterSoulFragmentsBar.BBFPixelBorder:Show()
                end
                if DemonHunterSoulFragmentsBar.pixelBorderBackground then
                    DemonHunterSoulFragmentsBar.pixelBorderBackground:SetAlpha(1)
                end
            end
        end
    end

    -- Hide TargetFrame Mana
    if noPortraitTarget and TargetFrame and TargetFrame.TargetFrameContent then
        local manaBar = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar
        if manaBar then
            manaBar:SetAlpha((db.hideUnitFrameTargetMana or manaBar.bbfBigHidden) and 0 or 1)
        end
        if TargetFrame.totFrame and TargetFrame.totFrame.ManaBar then
            TargetFrame.totFrame.ManaBar:SetAlpha(HideTotMana(TargetFrame) and 0 or 1)
        end
    end

    -- Hide FocusFrame Mana
    if noPortraitFocus then
        local manaBar = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar
        if manaBar then
            manaBar:SetAlpha((db.hideUnitFrameFocusMana or manaBar.bbfBigHidden) and 0 or 1)
        end
        if FocusFrame.totFrame and FocusFrame.totFrame.ManaBar then
            FocusFrame.totFrame.ManaBar:SetAlpha(HideTotMana(FocusFrame) and 0 or 1)
        end
    end

    -- PlayerFrame
    if PlayerFrame.noPortraitMode and PlayerFrame.noPortraitMode.Texture then
        local altbar = PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture:IsShown()
        PlayerFrame.noPortraitMode.Texture:SetTexture(altbar and playerAltTex or playerDefaultTex)
    end

    -- TargetFrame
    if TargetFrame.noPortraitMode and TargetFrame.noPortraitMode.Texture then
        local hideMana = db.hideUnitFrameTargetMana
        local textureToUse

        if BBF.IsBigHealthbarActive(TargetFrame) then
            textureToUse = unifiedTex
        elseif hideMana then
            textureToUse = minusTex
        else
            textureToUse = targetDefaultTex
        end

        TargetFrame.noPortraitMode.Texture:SetTexture(textureToUse)
    end
    if noPortraitTarget and TargetFrame.totFrame and TargetFrame.totFrame.FrameTexture then
        TargetFrame.totFrame.FrameTexture:SetTexture(totTargetDefaultTex)
    end

    -- FocusFrame
    if FocusFrame.noPortraitMode and FocusFrame.noPortraitMode.Texture then
        local hideMana = db.hideUnitFrameFocusMana
        local textureToUse

        if BBF.IsBigHealthbarActive(FocusFrame) then
            textureToUse = unifiedTex
        elseif hideMana then
            textureToUse = minusTex
        else
            textureToUse = focusDefaultTex
        end

        FocusFrame.noPortraitMode.Texture:SetTexture(textureToUse)
    end
    if noPortraitFocus and FocusFrame.totFrame and FocusFrame.totFrame.FrameTexture then
        FocusFrame.totFrame.FrameTexture:SetTexture(totFocusDefaultTex)
    end

    if BBF.HasNoPortrait("party") then
        UpdatePartyFrameManaVisibility()
    end

    AdjustAlternateBars()
    BBF.UpdateResourcePositionNoPortrait()
end

local function FixSelectionHighlight(frames)
    for _, frame in pairs(frames) do
        if frame.Selection and frame.Selection.TopLeftCorner and not frame.Selection.bbfRepositioned then
            local xOffsetLeft = (frame == PartyFrame) and 43 or 0
            local xOffsetRight = (frame == PartyFrame) and -3 or 0
            local yOffsetBottom = (frame == PartyFrame) and 20 or 0
            local yOffsetTop = (frame ~= PartyFrame and frame ~= PetFrame) and 6 or 0
            frame.Selection.TopLeftCorner:ClearAllPoints()
            frame.Selection.TopLeftCorner:SetPoint("TOPLEFT", (frame.healthBar or frame.HealthBar or frame.healthbar or PartyFrame), "TOPLEFT", -16 + xOffsetLeft, 15 + yOffsetTop)
            frame.Selection.TopRightCorner:ClearAllPoints()
            frame.Selection.TopRightCorner:SetPoint("TOPRIGHT", (frame.healthBar or frame.HealthBar or frame.healthbar or PartyFrame), "TOPRIGHT", 15 + xOffsetRight, 15 + yOffsetTop)
            frame.Selection.BottomLeftCorner:ClearAllPoints()
            frame.Selection.BottomLeftCorner:SetPoint("BOTTOMLEFT", (frame.healthBar or frame.HealthBar or frame.healthbar or PartyFrame), "BOTTOMLEFT", -16 + xOffsetLeft, -25 + yOffsetBottom)
            frame.Selection.BottomRightCorner:ClearAllPoints()
            frame.Selection.BottomRightCorner:SetPoint("BOTTOMRIGHT", (frame.healthBar or frame.HealthBar or frame.healthbar or PartyFrame), "BOTTOMRIGHT", 15 + xOffsetRight, -25 + yOffsetBottom)
            frame.Selection.MouseOverHighlight:ClearAllPoints()
            frame.Selection.MouseOverHighlight:SetPoint("TOPLEFT", frame.Selection.TopLeftCorner, "TOPLEFT", 8, -8)
            frame.Selection.MouseOverHighlight:SetPoint("BOTTOMRIGHT", frame.Selection.BottomRightCorner, "BOTTOMRIGHT", -8, 8)
            if frame.Selection.HorizontalLabel then
                frame.Selection.HorizontalLabel:ClearAllPoints()
                frame.Selection.HorizontalLabel:SetPoint("CENTER", frame.Selection.MouseOverHighlight, "CENTER", 0, 0)
            end
            frame.Selection.bbfRepositioned = true

            hooksecurefunc(frame.Selection.TopLeftCorner, "SetPoint", function(self)
                if self.changing then return end
                self.changing = true
                self:ClearAllPoints()
                self:SetPoint("TOPLEFT", (frame.healthBar or frame.HealthBar or frame.healthbar or PartyFrame), "TOPLEFT", -16 + xOffsetLeft, 15 + yOffsetTop)
                self.changing = false
            end)

            hooksecurefunc(frame.Selection.TopRightCorner, "SetPoint", function(self)
                if self.changing then return end
                self.changing = true
                self:ClearAllPoints()
                self:SetPoint("TOPRIGHT", (frame.healthBar or frame.HealthBar or frame.healthbar or PartyFrame), "TOPRIGHT", 15 + xOffsetRight, 15 + yOffsetTop)
                self.changing = false
            end)

            hooksecurefunc(frame.Selection.BottomLeftCorner, "SetPoint", function(self)
                if self.changing then return end
                self.changing = true
                self:ClearAllPoints()
                self:SetPoint("BOTTOMLEFT", (frame.healthBar or frame.HealthBar or frame.healthbar or PartyFrame), "BOTTOMLEFT", -16 + xOffsetLeft, -25 + yOffsetBottom)
                self.changing = false
            end)

            hooksecurefunc(frame.Selection.BottomRightCorner, "SetPoint", function(self)
                if self.changing then return end
                self.changing = true
                self:ClearAllPoints()
                self:SetPoint("BOTTOMRIGHT", (frame.healthBar or frame.HealthBar or frame.healthbar or PartyFrame), "BOTTOMRIGHT", 15 + xOffsetRight, -25 + yOffsetBottom)
                self.changing = false
            end)

            hooksecurefunc(frame.Selection.MouseOverHighlight, "SetPoint", function(self)
                if self.changing then return end
                self.changing = true
                self:ClearAllPoints()
                self:SetPoint("TOPLEFT", frame.Selection.TopLeftCorner, "TOPLEFT", 8, -8)
                self:SetPoint("BOTTOMRIGHT", frame.Selection.BottomRightCorner, "BOTTOMRIGHT", -8, 8)
                self.changing = false
            end)
        end

    end
end

function BBF.noPortraitModes()
    local db = BetterBlizzFramesDB
    if not db.noPortraitModes and not db.noPortraitPixelBorder then return end

    UpdateTextureVariables()
    if BBF.HasNoPortrait("target") then
        MakeNoPortraitMode(TargetFrame)
    end
    if BBF.HasNoPortrait("focus") then
        MakeNoPortraitMode(FocusFrame)
    end
    if BBF.HasNoPortrait("player") then
        MakeNoPortraitMode(PlayerFrame)
    end
    if BBF.HasNoPortrait("pet") then
        MakeNoPortraitMode(PetFrame)
    end

    local noPortraitParty = BBF.HasNoPortrait("party")
    if noPortraitParty then
        MakeClassicPartyFrame()
    end

    AdjustAlternateBars()

    local noPortraitPlayer = BBF.HasNoPortrait("player")
    local noPortraitTarget = BBF.HasNoPortrait("target")
    local noPortraitFocus = BBF.HasNoPortrait("focus")
    local noPortraitPet = BBF.HasNoPortrait("pet")

    if noPortraitPlayer then
        C_Timer.After(0.5,function()
            for _, child in ipairs({ PlayerFrame.PlayerFrameContent.PlayerFrameContentMain:GetRegions() }) do
                if child:IsObjectType("Texture") then
                    local atlas = child:GetAtlas()
                    if atlas == "UI-HUD-UnitFrame-Target-PortraitOn-Type" then
                        child:SetParent(BBF.hiddenFrame)
                    end
                end
            end
        end)

        PlayerFrame:SetHitRectInsets(66, 12, 21, 18)

        local txt = PlayerFrameGroupIndicatorText
        local wt_p = PlayerFrameGroupIndicatorText:GetParent()
        local regions = {wt_p:GetRegions()}
        for _, region in ipairs(regions) do
            if region ~= txt then
                region:Hide()
            end
        end
    end

    if noPortraitTarget then
        TargetFrame:SetHitRectInsets(5, 70, 21, 18)
        TargetFrameToT:SetHitRectInsets(25, 12, -6, 8)
    end
    if noPortraitFocus then
        FocusFrameToT:SetHitRectInsets(25, 12, -6, 8)
    end
    if noPortraitPet then
        PetFrame:SetHitRectInsets(25, 12, -6, 8)
    end

    local selectionFrames = {}
    if noPortraitParty then
        for i = 1, 4 do
            local partyMemberFrame = PartyFrame["MemberFrame"..i]
            partyMemberFrame:SetHitRectInsets(29, -8, -6, 8)
        end
        table.insert(selectionFrames, PartyFrame)
    end
    if noPortraitPlayer then
        table.insert(selectionFrames, PlayerFrame)
    end
    if noPortraitPet then
        table.insert(selectionFrames, PetFrame)
    end
    if noPortraitTarget then
        table.insert(selectionFrames, TargetFrame)
        table.insert(selectionFrames, TargetFrameToT)
    end
    if noPortraitFocus then
        table.insert(selectionFrames, FocusFrame)
        table.insert(selectionFrames, FocusFrameToT)
    end

    hooksecurefunc(EditModeManagerFrame, "EnterEditMode", function()
        if InCombatLockdown() then return end
        FixSelectionHighlight(selectionFrames)
    end)

    hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function()
        if InCombatLockdown() then return end
        FixSelectionHighlight(selectionFrames)
    end)

    C_Timer.After(0.5, function()
        BBF.UpdateNoPortraitManaVisibility()
    end)
end