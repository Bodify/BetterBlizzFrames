-- Big Healthbar (No Portrait & Classic Frames): the PlayerFrame health bar takes over the mana slot.
-- Also owns the portrait frame's Hide PlayerFrame Mana layout (NoMana art, health grown into the mana slot).

-- Blizzard's player-bars heights: health 19, mana 10, 1px gap.
-- Camelot 70425: health container 15 with a 20 tall bar sitting 3px above it.
local function RetailOn(unit)
    return BBF.RetailTexturesOn and BBF.RetailTexturesOn(unit) or false
end

local function SymmetricOn()
    return BBF.SymmetricPlayerOn and BBF.SymmetricPlayerOn() or false
end

local HEALTHBAR_HEIGHT = 19
local CAMELOT_CONTAINER_HEIGHT = 15
local CAMELOT_BAR_HEIGHT = 20
local MANABAR_HEIGHT = 10
local BAR_GAP = 1
local HEALTHBAR_HEIGHT_GROWN = HEALTHBAR_HEIGHT + BAR_GAP + MANABAR_HEIGHT -- 30
local FOREVER_TEX = "Interface\\AddOns\\BetterBlizzFrames\\media\\foreverTextures\\"
local RETAIL_TEX = "Interface\\AddOns\\BetterBlizzFrames\\media\\retailTextures\\"
local BLIZZ_TEX = "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\"
-- Reduce Health Height: art top border sits 8px lower, so the bar loses 8px at the top.
local REDUCED_HEIGHT = 8
-- Retail Textures: the big bar grows up into the name area instead.
local RETAIL_RAISE = { reduced = 8, big = 12 }

local function ReducedSuffix()
    return BBF.BigHealthbarReduced(PlayerFrame) and "-Reduced" or ""
end

-- Hide PlayerFrame Mana on the portrait frame: the mana slot merges into the health box.
local MANA_SPAN = MANABAR_HEIGHT + BAR_GAP

function BBF.PlayerManaHiddenArt()
    local db = BetterBlizzFramesDB
    return db.hideUnitFramePlayerMana and not db.classicFrames
        and not BBF.HasNoPortrait("player") and true or false
end

function BBF.PlayerNameBorderRemoved()
    local db = BetterBlizzFramesDB
    return db.removeNameBorder and not db.classicFrames and not BBF.HasNoPortrait("player")
        and not BBF.BigPlayerHealthbar() and not RetailOn("player") and true or false
end

local function RetailMode()
    return RetailOn("player")
end

local function CustomPlayerArt()
    return BBF.BigPlayerHealthbar() or BBF.PlayerManaHiddenArt() or BBF.PlayerNameBorderRemoved()
end

local function NoManaSuffix()
    return BBF.PlayerManaHiddenArt() and "-NoMana" or ""
end

local function RetailArtSuffix()
    local suffix = ""
    if BBF.BigPlayerHealthbar() then
        suffix = "-BigHealthbar" .. (BBF.BigHealthbarReduced(PlayerFrame) and "-Reduced" or "")
    end
    return suffix .. NoManaSuffix()
end

function BBF.PlayerBigRaise()
    if not RetailMode() or not BBF.BigPlayerHealthbar() then return 0 end
    return BBF.BigHealthbarReduced(PlayerFrame) and RETAIL_RAISE.reduced or RETAIL_RAISE.big
end

local function MirrorArtName()
    local suffix = RetailArtSuffix()
    if suffix == "" then return end
    return "Target" .. suffix
end

function BBF.MirrorPlayerTargetArt(flash)
    if flash then
        return RETAIL_TEX .. "Target-InCombat" .. RetailArtSuffix() .. ".png"
    end
    local name = MirrorArtName()
    return name and RETAIL_TEX .. name .. ".png"
end

function BBF.SetMirrorPlayerFrameTexture()
    if not SymmetricOn() then return end
    local frameTexture = PlayerFrame.PlayerFrameContainer.FrameTexture
    if frameTexture.bbfMirrorChanging then return end
    frameTexture.bbfMirrorChanging = true
    local art = BBF.MirrorPlayerTargetArt()
    if art then
        frameTexture:SetTexture(art)
        frameTexture:SetTexCoord(1, 0, 0, 1)
    else
        BBF.SetRetailArt(frameTexture, "Target-PortraitOn", true)
    end
    frameTexture:SetSize(192, 67)
    frameTexture.bbfMirrorChanging = false
end

function BBF.SetMirrorPlayerAltFrameTexture()
    if not SymmetricOn() then return end
    local db = BetterBlizzFramesDB
    local container = PlayerFrame.PlayerFrameContainer
    local altTex = container.AlternatePowerFrameTexture
    local art = BBF.MirrorPlayerTargetArt()
    altTex:ClearAllPoints()
    if art and not db.hideUnitFramePlayerSecondResource and BBF.BigPlayerHealthbar() then
        altTex:SetTexture(RETAIL_TEX .. MirrorArtName() .. "-Alt.png")
        altTex:SetTexCoord(0, 1, 0, 1)
        altTex:SetAllPoints(container.FrameTexture)
        return
    end
    if db.hideUnitFramePlayerSecondResource then
        if art then
            altTex:SetTexture(art)
            altTex:SetTexCoord(1, 0, 0, 1)
        else
            BBF.SetRetailArt(altTex, "Target-PortraitOn", true)
        end
        altTex:SetAllPoints(container.FrameTexture)
        return
    end
    altTex:SetTexture(BLIZZ_TEX .. "UI-HUD-UnitFrame-Target-PortraitOn-Alt" .. (art and "-NoMana" or "") .. ".png")
    altTex:SetTexCoord(0, 1, 0, 1)
    altTex:SetSize(192, 67)
    altTex:SetPoint("CENTER", 0, -0.5)
end

local function SetContainerPoint(hpContainer, xOffset, yOffset)
    local point, relativeTo, relativePoint, x, y = hpContainer:GetPoint()
    hpContainer:SetPoint(point, relativeTo, relativePoint, xOffset or x, yOffset or y)
end

local function GetHealthBits()
    local hpContainer = PlayerFrame_GetHealthBarContainer()
    return hpContainer, hpContainer.HealthBar, hpContainer.HealthBarMask
end

local function IsEnabled()
    return BBF.BigPlayerHealthbar()
end

local function SetHealthTextOffset(hpContainer, y)
    hpContainer.HealthBarText:SetPoint("CENTER", hpContainer, "CENTER", 0, y)
    hpContainer.LeftText:SetPoint("LEFT", hpContainer, "LEFT", 2, y)
    hpContainer.RightText:SetPoint("RIGHT", hpContainer, "RIGHT", -2, y)
end

local function SetDefaultManaShown(shown)
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea:SetAlpha(shown and 1 or 0)
end

function BBF.GetPlayerFrameArtTexture()
    if BBF.BigPlayerHealthbar() then
        return FOREVER_TEX .. "Player-PortraitOn-BigHealthbar" .. ReducedSuffix() .. NoManaSuffix() .. ".png"
    end
    if BBF.PlayerNameBorderRemoved() then
        return FOREVER_TEX .. "Player-PortraitOn-NoNameBg" .. NoManaSuffix() .. ".png"
    end
    return FOREVER_TEX .. "Player-PortraitOn-NoMana.png"
end

local function SetDefaultFrameTexture(atlas)
    if SymmetricOn() then return end
    if CustomPlayerArt() then
        PlayerFrame.PlayerFrameContainer.FrameTexture:SetTexture(BBF.GetPlayerFrameArtTexture())
        return
    end
    PlayerFrame.PlayerFrameContainer.FrameTexture:SetAtlas(atlas)
end

function BBF.UpdatePlayerAltFrameArt()
    local db = BetterBlizzFramesDB
    if db.classicFrames or SymmetricOn() then return end
    local big = BBF.BigPlayerHealthbar()
    local noMana = BBF.PlayerManaHiddenArt()
    local altTex = PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture
    if not big and not noMana and not (BBF.PlayerNameBorderRemoved() and db.hideUnitFramePlayerSecondResource) then
        if altTex.bbfBigArt then
            altTex.bbfBigArt = nil
            altTex:SetAtlas(db.hideUnitFramePlayerSecondResource and "UI-HUD-UnitFrame-Player-PortraitOn" or "UI-HUD-UnitFrame-Player-PortraitOn-ClassResource")
        end
        return
    end
    altTex.bbfBigArt = true
    if db.hideUnitFramePlayerSecondResource then
        altTex:SetTexture(BBF.GetPlayerFrameArtTexture())
    elseif big then
        altTex:SetTexture(FOREVER_TEX .. "Player-PortraitOn-ClassResource-BigHealthbar" .. ReducedSuffix() .. NoManaSuffix() .. ".png")
    else
        altTex:SetTexture(FOREVER_TEX .. "Player-PortraitOn-ClassResource-NoMana.png")
    end
end

local function ClassicCombatGlowOn()
    return BetterBlizzFramesDB.classicCombatGlow and PlayerFrame.state == "player"
        and not RetailMode() and not SymmetricOn()
end

-- Classic Style Combat Glow: one outline per frame silhouette, the ClassResource art shares the default one.
-- The glow canvas is the 198x71 frame art plus room for the fade on every side.
local CLASSIC_GLOW_PAD = 5
local CLASSIC_GLOW_WIDTH = 198 + CLASSIC_GLOW_PAD * 2
local CLASSIC_GLOW_HEIGHT = 71 + CLASSIC_GLOW_PAD * 2
local function ClassicCombatGlowFile()
    local suffix = ""
    if BBF.BigPlayerHealthbar() then
        suffix = ReducedSuffix()
    elseif BBF.PlayerNameBorderRemoved() and not (PlayerFrame_GetAlternatePowerBar() and not BetterBlizzFramesDB.hideUnitFramePlayerSecondResource) then
        suffix = "-NoNameBg"
    end
    return FOREVER_TEX .. "Player-PortraitOn-Status-Classic" .. suffix .. ".png"
end

function BBF.ClassicStealthGlowOn()
    return not BetterBlizzFramesDB.classicFrames and not BBF.HasNoPortrait("player") and not RetailMode() and not SymmetricOn()
end

function BBF.SetClassicStealthGlow(tex)
    tex:SetTexture(ClassicCombatGlowFile())
    tex:SetTexCoord(0, 1, 0, 1)
    tex:SetSize(CLASSIC_GLOW_WIDTH, CLASSIC_GLOW_HEIGHT)
    tex:ClearAllPoints()
    tex:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContainer, "TOPLEFT", 17 - CLASSIC_GLOW_PAD, -14 + CLASSIC_GLOW_PAD)
    tex:SetBlendMode("ADD")
end

-- Rest/combat glow: the stock line sits on the name divider, which crosses the big health bar.
local function UpdatePlayerStatusTexture()
    local db = BetterBlizzFramesDB
    local status = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture
    if db.classicFrames then return end
    if BBF.HasNoPortrait("player") or UNIT_FRAME_SHOW_HEALTH_ONLY then return end
    if ClassicCombatGlowOn() then
        status.bbfClassicGlow = true
        status:SetTexture(ClassicCombatGlowFile())
        status:SetTexCoord(0, 1, 0, 1)
        status:SetSize(CLASSIC_GLOW_WIDTH, CLASSIC_GLOW_HEIGHT)
        status:ClearAllPoints()
        status:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContainer, "TOPLEFT", 17 - CLASSIC_GLOW_PAD, -14 + CLASSIC_GLOW_PAD)
        status:SetBlendMode("ADD")
        return
    elseif status.bbfClassicGlow then
        status.bbfClassicGlow = nil
        status:SetBlendMode("BLEND")
        status:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Status", TextureKitConstants.UseAtlasSize)
    end
    if PlayerFrame.state ~= "player" then return end
    if SymmetricOn() then
        BBF.PlaceSymmetricStatus()
        return
    end
    if RetailMode() then
        status:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContainer, "TOPLEFT", 18, -14)
        if BBF.BigPlayerHealthbar() then
            status.bbfBigStatus = true
            status:SetTexture(RETAIL_TEX .. "Player-Status-BigHealthbar" .. (BBF.BigHealthbarReduced(PlayerFrame) and "-Reduced" or "") .. ".png")
            status:SetTexCoord(0, 1, 0, 1)
            status:SetSize(196, 71)
        elseif status.bbfBigStatus then
            status.bbfBigStatus = nil
            status:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Status", TextureKitConstants.UseAtlasSize)
        end
        return
    end
    if BBF.BigPlayerHealthbar() then
        status.bbfBigStatus = true
        status:SetTexture(FOREVER_TEX .. "Player-PortraitOn-Status-BigHealthbar" .. ReducedSuffix() .. ".png")
        status:SetTexCoord(0, 1, 0, 1)
        status:SetSize(198, 71)
    elseif status.bbfBigStatus then
        status.bbfBigStatus = nil
        status:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Status", TextureKitConstants.UseAtlasSize)
    end
end

function BBF.UpdatePlayerFrameFlash()
    if not BBF.hookedPlayerFrameFlash then
        BBF.hookedPlayerFrameFlash = true
        hooksecurefunc("PlayerFrame_ToPlayerArt", BBF.UpdatePlayerFrameFlash)
        if PlayerFrame_UpdateFlashTextureVisuals then
            hooksecurefunc("PlayerFrame_UpdateFlashTextureVisuals", BBF.UpdatePlayerFrameFlash)
        end
        if PlayerFrame_UpdateStatusTextureVisuals then
            hooksecurefunc("PlayerFrame_UpdateStatusTextureVisuals", UpdatePlayerStatusTexture)
        end
    end
    UpdatePlayerStatusTexture()
    local db = BetterBlizzFramesDB
    local container = PlayerFrame.PlayerFrameContainer
    local flash = container.FrameFlash
    if db.classicFrames then return end
    if BBF.HasNoPortrait("player") or UNIT_FRAME_SHOW_HEALTH_ONLY then return end
    if ClassicCombatGlowOn() then
        flash.bbfClassicGlow = true
        flash:SetTexture(ClassicCombatGlowFile())
        flash:SetTexCoord(0, 1, 0, 1)
        flash:SetSize(CLASSIC_GLOW_WIDTH, CLASSIC_GLOW_HEIGHT)
        flash:ClearAllPoints()
        flash:SetPoint("TOPLEFT", container, "TOPLEFT", 17 - CLASSIC_GLOW_PAD, -14 + CLASSIC_GLOW_PAD)
        flash:SetBlendMode("ADD")
        return
    elseif flash.bbfClassicGlow then
        flash.bbfClassicGlow = nil
        flash:SetBlendMode("BLEND")
        flash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize)
        flash:ClearAllPoints()
        flash:SetPoint("CENTER", container, "CENTER", 0, 0)
    end
    if PlayerFrame.state ~= "player" or SymmetricOn() then return end
    if RetailMode() then
        local showAlt = PlayerFrame_GetAlternatePowerBar() and not db.hideUnitFramePlayerSecondResource
        if showAlt then
            flash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-ClassResource-InCombat", TextureKitConstants.UseAtlasSize)
            flash:SetPoint("CENTER", container, "CENTER", -2, 0.5)
        else
            flash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize)
            flash:SetPoint("CENTER", container, "CENTER", -1.5, 1)
        end
        local suffix = RetailArtSuffix()
        if suffix ~= "" then
            flash:SetTexture(RETAIL_TEX .. "Player-" .. (showAlt and "ClassResource-InCombat" or "InCombat") .. suffix .. ".png")
            flash:SetTexCoord(0, 1, 0, 1)
        end
        return
    end
    if BBF.BigPlayerHealthbar() then
        -- The glow has nothing below the old name divider, so one file covers the ClassResource frame too.
        flash:SetTexture(FOREVER_TEX .. "Player-PortraitOn-InCombat-BigHealthbar" .. ReducedSuffix() .. ".png")
        flash:SetTexCoord(0, 1, 0, 1)
        flash:SetSize(198, 71)
        flash:SetPoint("CENTER", container, "CENTER", 0, 0)
        return
    end
    local showAltBar = PlayerFrame_GetAlternatePowerBar() and not db.hideUnitFramePlayerSecondResource
    if showAltBar then
        flash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-ClassResource-InCombat", TextureKitConstants.UseAtlasSize)
        flash:SetPoint("CENTER", container, "CENTER", 0, 0)
    elseif BBF.PlayerNameBorderRemoved() then
        flash:SetTexture(FOREVER_TEX .. "Player-PortraitOn-InCombat-NoNameBg.png")
        flash:SetTexCoord(0, 1, 0, 1)
        flash:SetSize(198, 71)
        flash:SetPoint("CENTER", container, "CENTER", 0, 0)
    else
        flash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize)
        flash:SetPoint("CENTER", container, "CENTER", 0, 0)
    end
end

function BBF.UpdateClassicCombatGlow()
    BBF.UpdatePlayerFrameFlash()
    BBF.UpdateTargetPlayerArt(TargetFrame)
    if FocusFrame then
        BBF.UpdateTargetPlayerArt(FocusFrame)
    end
    BBF.UpdateNoPortraitClassicGlow()
end

local function ShiftGroupIcons(raise)
    local contextual = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual
    BBF.ShiftRegionY(contextual and contextual.RoleIcon, raise)
end

local function PlayerArtTexture()
    local container = PlayerFrame.PlayerFrameContainer
    if container.AlternatePowerFrameTexture:IsShown() then
        return container.AlternatePowerFrameTexture
    end
    return container.FrameTexture
end

local function SetRetailPortraitMask(retail)
    local container = PlayerFrame.PlayerFrameContainer
    local mask = container.PlayerPortraitMask
    if retail and not SymmetricOn() then
        mask.bbfRetailMask = true
        mask:SetTexture(BBF.RetailBaseFile("Player-PortraitMask"), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:ClearAllPoints()
        mask:SetAllPoints(container.FrameTexture)
    elseif mask.bbfRetailMask and not SymmetricOn() then
        mask.bbfRetailMask = nil
        mask:SetAtlas("UI-HUD-UnitFrame-Player-Portrait-Mask")
        mask:ClearAllPoints()
        mask:SetPoint("TOPLEFT", container, "TOPLEFT", 24, -19)
        mask:SetSize(60, 60)
    end
end

local function RetailBarLayout()
    local hpContainer, healthBar, mask = GetHealthBits()
    SetDefaultManaShown(not BBF.PlayerManaHiddenArt())
    SetDefaultFrameTexture("UI-HUD-UnitFrame-Player-PortraitOn")
    BBF.UpdatePlayerAltFrameArt()
    BBF.SetMirrorPlayerFrameTexture()
    BBF.SetMirrorPlayerAltFrameTexture()
    BBF.UpdatePlayerFrameFlash()
    SetRetailPortraitMask(true)
    local tex = PlayerArtTexture()
    local manaBar = PlayerFrame_GetManaBar()
    if not BBF.FitRetailBars(tex, hpContainer, mask, manaBar, manaBar.ManaBarMask) then return end
    healthBar:ClearAllPoints()
    healthBar:SetAllPoints(hpContainer)
    local altBar = PlayerFrame_GetAlternatePowerBar()
    if altBar and BBF.FitRetailSlot(altBar, tex, "power") then
        BBF.MaskRetailSlot(altBar.PowerBarMask, tex, "power")
    end
    local raise = BBF.PlayerBigRaise()
    ShiftGroupIcons(raise)
    if not BBF.ApplyTextArea(PlayerFrame) then
        SetHealthTextOffset(hpContainer, BetterBlizzFramesDB.biggerHealthbarsNameInside and -6 or 0)
    end
end

local function GrowBar()
    local hpContainer, healthBar, mask = GetHealthBits()
    if BetterBlizzFramesDB.classicFrames then
        local hideMana = BetterBlizzFramesDB.hideUnitFramePlayerMana
        local height = hideMana and 39 or 29
        SetContainerPoint(hpContainer, nil, -34)
        hpContainer:SetSize(120, height)
        healthBar:SetSize(120, height)
        healthBar:ClearAllPoints()
        healthBar:SetPoint("TOPLEFT", hpContainer, "TOPLEFT", 0, 3)
        BBF.MaskClassicPlayerHealth()
        BBF.UpdatePlayerOvershieldAnchor()
        BBF.SizeClassicPlayerMana()
        return
    end
    if RetailMode() then
        if PlayerFrame.state == "vehicle" then
            SetRetailPortraitMask(false)
        else
            RetailBarLayout()
        end
        return
    end
    hpContainer:SetHeight(HEALTHBAR_HEIGHT_GROWN)
    healthBar:SetHeight(HEALTHBAR_HEIGHT_GROWN)
    if not BBF.HasNoPortrait("player") then
        SetDefaultManaShown(not BBF.PlayerManaHiddenArt())
        SetDefaultFrameTexture("UI-HUD-UnitFrame-Player-PortraitOn")
        BBF.UpdatePlayerAltFrameArt()
        BBF.UpdatePlayerFrameFlash()
        local reduced = BBF.BigHealthbarReduced(PlayerFrame) and REDUCED_HEIGHT or 0
        local noMana = BBF.PlayerManaHiddenArt() and MANA_SPAN or 0
        healthBar:ClearAllPoints()
        healthBar:SetPoint("TOPLEFT", hpContainer, "TOPLEFT", 0, 17.5 - reduced)
        healthBar:SetHeight(HEALTHBAR_HEIGHT_GROWN + 2 - reduced + noMana)
        mask:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Mask", true)
        local maskY, maskHeight = 23, 78
        if reduced > 0 then
            maskY, maskHeight = 18, 60
            if noMana > 0 then maskY, maskHeight = 24, 83 end
        elseif noMana > 0 then
            maskY, maskHeight = 31, 105
        end
        mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -2, maskY)
        mask:SetSize(129, maskHeight)
        if BetterBlizzFramesDB.biggerHealthbarsNameInside then
            SetHealthTextOffset(hpContainer, (reduced > 0 and 6 or 7) - noMana / 2)
        else
            SetHealthTextOffset(hpContainer, 15.5 - reduced / 2 - noMana / 2)
        end
        return
    end
    if PlayerFrame.state == "vehicle" then
        mask:SetSize(184, 46)
    else
        BBF.ApplyNoPortraitBigPlayerMask()
    end
end

local function RestoreBar()
    local hpContainer, healthBar, mask = GetHealthBits()
    if BetterBlizzFramesDB.classicFrames then
        SetContainerPoint(hpContainer, nil, -44)
        hpContainer:SetSize(124, CAMELOT_CONTAINER_HEIGHT)
        healthBar:SetWidth(124)
        BBF.SquishClassicPlayerHealth()
        BBF.UpdatePlayerOvershieldAnchor()
        BBF.SizeClassicPlayerMana()
        return
    end
    if RetailMode() then
        if PlayerFrame.state == "vehicle" then
            SetRetailPortraitMask(false)
        else
            RetailBarLayout()
        end
        return
    end
    local noPortrait = BBF.HasNoPortrait("player")
    hpContainer:SetHeight(noPortrait and HEALTHBAR_HEIGHT or CAMELOT_CONTAINER_HEIGHT)
    healthBar:SetHeight(noPortrait and HEALTHBAR_HEIGHT or CAMELOT_BAR_HEIGHT)
    if BetterBlizzFramesDB.noPortraitPixelBorder and BBF.HasNoPortrait("player") then
        BBF.UpdatePlayerPixelBorderSize()
        return
    end
    if not BBF.HasNoPortrait("player") then
        SetDefaultManaShown(not BBF.PlayerManaHiddenArt())
        SetDefaultFrameTexture("UI-HUD-UnitFrame-Player-PortraitOn")
        BBF.UpdatePlayerAltFrameArt()
        BBF.UpdatePlayerFrameFlash()
        healthBar:ClearAllPoints()
        mask:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Mask", true)
        if BBF.PlayerManaHiddenArt() then
            healthBar:SetPoint("TOPLEFT", hpContainer, "TOPLEFT", 0, 6)
            healthBar:SetHeight(38)
            SetHealthTextOffset(hpContainer, -MANA_SPAN / 2)
            mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -2, 11)
            mask:SetHeight(60)
            return
        end
        healthBar:SetPoint("TOPLEFT", hpContainer, "TOPLEFT", 0, 3)
        SetHealthTextOffset(hpContainer, 0)
        mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -2, 6)
        mask:SetSize(128, 33)
        return
    end
    BBF.ApplyNoPortraitPlayerMask()
end
local function PlayerMaskOffset()
    if not BBF.HasNoPortrait("player") or BetterBlizzFramesDB.noPortraitPixelBorder then return end
    if PlayerFrame.state == "vehicle" then
        local _, healthBar, mask = GetHealthBits()
        mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -30, 10)
        return
    end
    BBF.ApplyNoPortraitBigPlayerMask()
end
local function VehicleMaskOffset()
    if not BBF.HasNoPortrait("player") or BetterBlizzFramesDB.noPortraitPixelBorder then return end
    local _, healthBar, mask = GetHealthBits()
    mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -34, 10)
end
local function UpdateClassicArt()
    if not BetterBlizzFramesDB.classicFrames then return end
    BBF.PlayerReputationColor()
    if UnitHasVehiclePlayerFrameUI("player") then return end
    BBF.UpdateClassicPlayerArt()
    BBF.SetCenteredNamesCaller()
end
local function Apply()
    if not IsEnabled() then
        if (BBF.PlayerManaHiddenArt() or RetailMode()) and PlayerFrame.state ~= "vehicle" then
            if InCombatLockdown() then
                BBF.RunAfterCombat(Apply)
                return
            end
            RestoreBar()
        end
        return
    end
    if InCombatLockdown() then
        BBF.RunAfterCombat(Apply)
        return
    end
    UpdateClassicArt()
    BBF.UpdateNoPortraitManaVisibility()
    GrowBar()
    PlayerMaskOffset()
    if BBF.HasNoPortrait("player") then
        BBF.UpdateNoPortraitText(PlayerFrame, "player")
    end
end

local vehicleExitListener
function BBF.UnregisterPlayerFrameArtEvents()
    if UnitInVehicle("player") then
        PlayerFrame:UnregisterEvent("UNIT_ENTERED_VEHICLE")
        PlayerFrame:UnregisterEvent("UNIT_EXITING_VEHICLE")
        if not vehicleExitListener then
            vehicleExitListener = CreateFrame("Frame")
            vehicleExitListener:SetScript("OnEvent", function(self)
                self:UnregisterAllEvents()
                BBF.UnregisterPlayerFrameArtEvents()
            end)
        end
        vehicleExitListener:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
        return
    end
    if vehicleExitListener then
        vehicleExitListener:UnregisterAllEvents()
    end
    PlayerFrame:UnregisterEvent("UNIT_ENTERED_VEHICLE")
    PlayerFrame:UnregisterEvent("UNIT_EXITING_VEHICLE")
    PlayerFrame:UnregisterEvent("UNIT_EXITED_VEHICLE")
    if AlternatePowerBar then
        AlternatePowerBar:UnregisterEvent("UNIT_DISPLAYPOWER")
    end
end

local hooked = false
local function EnsureHooks()
    if hooked then
        return
    end
    hooked = true
    hooksecurefunc(BBF, "noPortraitModes", function()
        if BBF.BigPlayerHealthbar() then
            C_Timer.After(0, Apply)
        end
    end)
    hooksecurefunc("PlayerFrame_ToPlayerArt", Apply)
    hooksecurefunc("PlayerFrame_ToVehicleArt", function()
        Apply()
        VehicleMaskOffset()
    end)
    if PlayerFrame_UpdateHealthBarVisuals then
        hooksecurefunc("PlayerFrame_UpdateHealthBarVisuals", function()
            if RetailMode() then Apply() end
        end)
    end
    if PlayerFrame_UpdateManaBarVisuals then
        hooksecurefunc("PlayerFrame_UpdateManaBarVisuals", function()
            if RetailMode() then Apply() end
        end)
    end
    local container = PlayerFrame.PlayerFrameContainer
    hooksecurefunc(container.FrameTexture, "SetAtlas", function()
        BBF.SetMirrorPlayerFrameTexture()
    end)
    hooksecurefunc(container.AlternatePowerFrameTexture, "SetAtlas", function()
        BBF.SetMirrorPlayerAltFrameTexture()
    end)
    hooksecurefunc(container.FrameTexture, "SetAtlas", function(_, atlas)
        if atlas ~= "UI-HUD-UnitFrame-Player-PortraitOn" or not CustomPlayerArt() then return end
        if BetterBlizzFramesDB.classicFrames or BBF.HasNoPortrait("player") then return end
        SetDefaultFrameTexture(atlas)
    end)
    hooksecurefunc(container.AlternatePowerFrameTexture, "SetAtlas", function(_, atlas)
        if atlas ~= "UI-HUD-UnitFrame-Player-PortraitOn-ClassResource" or not CustomPlayerArt() then return end
        if BBF.HasNoPortrait("player") then return end
        BBF.UpdatePlayerAltFrameArt()
    end)
    if BBF.HasNoPortrait("player") then
        BBF.UnregisterPlayerFrameArtEvents()
    end
end

local function RefreshHealthbarTexture()
    if not BBF.customTexturesReady then return end
    if not BetterBlizzFramesDB.classicFrames then return end
    if not BBF.UnitFrameTextureOn("health") then return end
    BBF.UpdateCustomTextures()
end

function BBF.UpdateBigPlayerHealthbar()
    BBF.PlayerReputationColor()
    BBF.UpdatePlayerManaHeight()
    if IsEnabled() then
        EnsureHooks()
        Apply()
        RefreshHealthbarTexture()
        return
    end

    if InCombatLockdown() then
        BBF.RunAfterCombat(BBF.UpdateBigPlayerHealthbar)
        return
    end
    if CustomPlayerArt() or RetailMode() then
        EnsureHooks()
    end
    RestoreBar()

    BBF.UpdateNoPortraitManaVisibility()
    UpdateClassicArt()
    RefreshHealthbarTexture()
    if BBF.HasNoPortrait("player") then
        BBF.UpdateNoPortraitText(PlayerFrame, "player")
    end
end
