-- Big Healthbar (No Portrait & Classic Frames): the PlayerFrame health bar takes over the mana slot.

-- Blizzard's player-bars heights: health 19, mana 10, 1px gap.
-- Mask is noPortrait's portrait-off mask (uipartyframeportraitoffhealthmask, 190x34);
local HEALTHBAR_HEIGHT = 19
local MANABAR_HEIGHT = 10
local BAR_GAP = 1
local HEALTHBAR_HEIGHT_GROWN = HEALTHBAR_HEIGHT + BAR_GAP + MANABAR_HEIGHT -- 30
local MASK_HEIGHT = 34
local MASK_HEIGHT_GROWN = 50

local function SetContainerPoint(hpContainer, xOffset, yOffset)
    local point, relativeTo, relativePoint, x, y = hpContainer:GetPoint()
    hpContainer:SetPoint(point, relativeTo, relativePoint, xOffset or x, yOffset or y)
end

local function GetHealthBits()
    local hpContainer = PlayerFrame_GetHealthBarContainer()
    return hpContainer, hpContainer.HealthBar, hpContainer.HealthBarMask
end

local function IsEnabled()
    return BetterBlizzFramesDB.bigPlayerHealthbar
end

local function SetDefaultManaShown(shown)
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea:SetAlpha(shown and 1 or 0)
end

function BBF.GetNoShadowPlayerFrameTexture()
    return "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Player-PortraitOn-NoShadow" .. (BetterBlizzFramesDB.bigPlayerHealthbar and "-NoMana" or "")
end

local function SetDefaultFrameTexture(atlas)
    if BetterBlizzFramesDB.symmetricPlayerFrame then return end
    if BetterBlizzFramesDB.hideUnitFrameShadow then
        PlayerFrame.PlayerFrameContainer.FrameTexture:SetTexture(BBF.GetNoShadowPlayerFrameTexture())
        return
    end
    PlayerFrame.PlayerFrameContainer.FrameTexture:SetAtlas(atlas)
end

function BBF.GetMirrorPlayerHealthbarSize()
    if BetterBlizzFramesDB.bigPlayerHealthbar then
        return 134, 31, 31
    end
    return 126, 20.5, 20
end

function BBF.SetMirrorPlayerHealthbarMask()
    local _, healthBar, mask = GetHealthBits()
    if BetterBlizzFramesDB.bigPlayerHealthbar then
        mask:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\hpMaskBigHpMirror.tga")
        mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -54.5, 0)
        mask:SetSize(254, 32)
        return
    end
    mask:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UIUnitFrameTargetHealthMask2x-Flipped")
    mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -2, 6)
    mask:SetSize(129, 32)
end

function BBF.SetMirrorPlayerFrameTexture()
    if not BetterBlizzFramesDB.symmetricPlayerFrame then return end
    if BetterBlizzFramesDB.classicFrames then return end
    if BBF.HasNoPortrait("player") then return end
    local frameTexture = PlayerFrame.PlayerFrameContainer.FrameTexture
    if frameTexture.changing then return end
    frameTexture.changing = true
    if BetterBlizzFramesDB.bigPlayerHealthbar then
        if BetterBlizzFramesDB.hideUnitFrameShadow then
            frameTexture:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Target-PortraitOn-NoShadow-NoMana")
        else
            frameTexture:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Target-PortraitOn-NoMana")
        end
    elseif BetterBlizzFramesDB.hideUnitFrameShadow then
        frameTexture:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Target-PortraitOn-NoShadow")
    else
        frameTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn")
    end
    frameTexture:SetSize(192, 67)
    frameTexture:SetTexCoord(1, 0, 0, 1)
    frameTexture.changing = false
end

function BBF.SetMirrorPlayerAltFrameTexture()
    local db = BetterBlizzFramesDB
    if not db.symmetricPlayerFrame then return end
    if db.classicFrames then return end
    if BBF.HasNoPortrait("player") then return end
    local altTex = PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture
    local path = "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Target-PortraitOn" .. (db.hideUnitFrameShadow and "-NoShadow" or "")
    local noMana = db.bigPlayerHealthbar and "-NoMana" or ""
    altTex:ClearAllPoints()
    if db.hideUnitFramePlayerSecondResource then
        if db.bigPlayerHealthbar or db.hideUnitFrameShadow then
            altTex:SetTexture(path .. noMana)
        else
            altTex:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn")
        end
        altTex:SetTexCoord(1, 0, 0, 1)
        altTex:SetAllPoints(PlayerFrame.PlayerFrameContainer.FrameTexture)
        return
    end
    altTex:SetTexture(path .. "-Alt" .. noMana)
    altTex:SetTexCoord(0, 1, 0, 1)
    altTex:SetSize(192, 67)
    altTex:SetPoint("CENTER", 0, -0.5)
end

function BBF.UpdateNoShadowPlayerAltFrameTexture()
    local db = BetterBlizzFramesDB
    if not db.hideUnitFrameShadow or db.symmetricPlayerFrame or db.classicFrames then return end
    local path = "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Player-PortraitOn-"
    local altTex = PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture
    if db.hideUnitFramePlayerSecondResource then
        altTex:SetTexture(BBF.GetNoShadowPlayerFrameTexture())
    elseif db.bigPlayerHealthbar then
        altTex:SetTexture(path .. "ClassResource-NoShadow-NoMana")
    else
        altTex:SetTexture(path .. "ClassResource-NoShadow")
    end
end

function BBF.UpdatePlayerFrameFlash()
    if not BBF.hookedPlayerFrameFlash then
        BBF.hookedPlayerFrameFlash = true
        hooksecurefunc("PlayerFrame_ToPlayerArt", BBF.UpdatePlayerFrameFlash)
    end
    local db = BetterBlizzFramesDB
    local container = PlayerFrame.PlayerFrameContainer
    local flash = container.FrameFlash
    if db.symmetricPlayerFrame or db.classicFrames then return end
    if BBF.HasNoPortrait("player") or UNIT_FRAME_SHOW_HEALTH_ONLY then return end
    if PlayerFrame.state ~= "player" then return end
    local showAltBar = PlayerFrame_GetAlternatePowerBar() and not db.hideUnitFramePlayerSecondResource
    if showAltBar then
        flash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-ClassResource-InCombat", TextureKitConstants.UseAtlasSize)
        flash:SetPoint("CENTER", container, "CENTER", -2, 0.5)
    else
        flash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize)
        flash:SetPoint("CENTER", container, "CENTER", -1.5, 1)
    end
    if not db.bigPlayerHealthbar then return end
    flash:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Player-PortraitOn-" .. (showAltBar and "ClassResource-InCombat-NoMana" or "InCombat-NoMana"))
    flash:SetTexCoord(0, 1, 0, 1)
    if not showAltBar then
        flash:SetSize(197, 71)
        flash:SetPoint("CENTER", container, "CENTER", 0, 0)
    end
end

local function GrowBar()
    local hpContainer, healthBar, mask = GetHealthBits()
    if BetterBlizzFramesDB.classicFrames then
        local hideMana = BetterBlizzFramesDB.hideUnitFramePlayerMana
        local height = hideMana and 39 or 29
        SetContainerPoint(hpContainer, nil, -31)
        hpContainer:SetSize(122, height)
        healthBar:SetSize(122, height)
        mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -2, hideMana and 11 or 7)
        mask:SetSize(126, hideMana and 63 or 44)
        mask:Show()
        BBF.UpdatePlayerOvershieldAnchor()
        return
    end
    hpContainer:SetHeight(HEALTHBAR_HEIGHT_GROWN)
    healthBar:SetHeight(HEALTHBAR_HEIGHT_GROWN)
    if BetterBlizzFramesDB.noPortraitPixelBorder and BBF.HasNoPortrait("player") then
        BBF.UpdatePlayerPixelBorderSize()
        return
    end
    if not BBF.HasNoPortrait("player") then
        SetDefaultManaShown(false)
        SetDefaultFrameTexture("plunderstorm-UI-HUD-UnitFrame-Player-PortraitOn-2x")
        BBF.UpdateNoShadowPlayerAltFrameTexture()
        BBF.UpdatePlayerFrameFlash()
        if BetterBlizzFramesDB.symmetricPlayerFrame then
            local width, containerHeight, barHeight = BBF.GetMirrorPlayerHealthbarSize()
            SetContainerPoint(hpContainer, 77)
            hpContainer:SetSize(width, containerHeight)
            healthBar:SetSize(width, barHeight)
            BBF.SetMirrorPlayerHealthbarMask()
            BBF.SetMirrorPlayerFrameTexture()
            BBF.SetMirrorPlayerAltFrameTexture()
        else
            mask:SetAtlas("plunderstorm-UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Mask-2x")
            mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -2, 0)
            mask:SetSize(128, 32)
        end
        return
    end
    mask:SetHeight(MASK_HEIGHT_GROWN)
end

local function RestoreBar()
    local hpContainer, healthBar, mask = GetHealthBits()
    if BetterBlizzFramesDB.classicFrames then
        SetContainerPoint(hpContainer, nil, -40)
        hpContainer:SetSize(124, 20)
        healthBar:SetSize(124, 20)
        mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -2, -6)
        mask:SetSize(126, 17)
        mask:Show()
        BBF.UpdatePlayerOvershieldAnchor()
        return
    end
    hpContainer:SetHeight(HEALTHBAR_HEIGHT)
    healthBar:SetHeight(HEALTHBAR_HEIGHT)
    if BetterBlizzFramesDB.noPortraitPixelBorder and BBF.HasNoPortrait("player") then
        BBF.UpdatePlayerPixelBorderSize()
        return
    end
    if not BBF.HasNoPortrait("player") then
        SetDefaultManaShown(true)
        SetDefaultFrameTexture("UI-HUD-UnitFrame-Player-PortraitOn")
        BBF.UpdateNoShadowPlayerAltFrameTexture()
        BBF.UpdatePlayerFrameFlash()
        if BetterBlizzFramesDB.symmetricPlayerFrame then
            local width, containerHeight, barHeight = BBF.GetMirrorPlayerHealthbarSize()
            SetContainerPoint(hpContainer, 85)
            hpContainer:SetSize(width, containerHeight)
            healthBar:SetSize(width, barHeight)
            BBF.SetMirrorPlayerHealthbarMask()
            BBF.SetMirrorPlayerFrameTexture()
            BBF.SetMirrorPlayerAltFrameTexture()
            return
        end
        mask:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Mask", true)
        mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -2, 6)
        mask:SetHeight(31)
        return
    end
    mask:SetHeight(MASK_HEIGHT)
end
local function PlayerMaskOffset()
    if not BBF.HasNoPortrait("player") or BetterBlizzFramesDB.noPortraitPixelBorder then return end
    local _, healthBar, mask = GetHealthBits()
    mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -33, 11)
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
        if BetterBlizzFramesDB.bigPlayerHealthbar then
            C_Timer.After(0, Apply)
        end
    end)
    hooksecurefunc("PlayerFrame_ToPlayerArt", Apply)
    hooksecurefunc("PlayerFrame_ToVehicleArt", function()
        Apply()
        VehicleMaskOffset()
    end)
    if BBF.HasNoPortrait("player") then
        BBF.UnregisterPlayerFrameArtEvents()
    end
end

function BBF.UpdateBigPlayerHealthbar()
    if IsEnabled() then
        EnsureHooks()
        Apply()
        return
    end

    if InCombatLockdown() then
        BBF.RunAfterCombat(BBF.UpdateBigPlayerHealthbar)
        return
    end
    RestoreBar()

    BBF.UpdateNoPortraitManaVisibility()
    UpdateClassicArt()
    if BBF.HasNoPortrait("player") then
        BBF.UpdateNoPortraitText(PlayerFrame, "player")
    end
end
