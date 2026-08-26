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

local function SetDefaultFrameTexture(atlas)
    if BetterBlizzFramesDB.symmetricPlayerFrame or BetterBlizzFramesDB.hideUnitFrameShadow then return end
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
    if BetterBlizzFramesDB.noPortraitPixelBorder then
        BBF.UpdatePlayerPixelBorderSize()
        return
    end
    if not BetterBlizzFramesDB.noPortraitModes then
        SetDefaultManaShown(false)
        SetDefaultFrameTexture("plunderstorm-UI-HUD-UnitFrame-Player-PortraitOn-2x")
        if BetterBlizzFramesDB.symmetricPlayerFrame then
            local width, containerHeight, barHeight = BBF.GetMirrorPlayerHealthbarSize()
            SetContainerPoint(hpContainer, 77)
            hpContainer:SetSize(width, containerHeight)
            healthBar:SetSize(width, barHeight)
            BBF.SetMirrorPlayerHealthbarMask()
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
    if BetterBlizzFramesDB.noPortraitPixelBorder then
        BBF.UpdatePlayerPixelBorderSize()
        return
    end
    if not BetterBlizzFramesDB.noPortraitModes then
        SetDefaultManaShown(true)
        SetDefaultFrameTexture("UI-HUD-UnitFrame-Player-PortraitOn")
        if BetterBlizzFramesDB.symmetricPlayerFrame then
            local width, containerHeight, barHeight = BBF.GetMirrorPlayerHealthbarSize()
            SetContainerPoint(hpContainer, 85)
            hpContainer:SetSize(width, containerHeight)
            healthBar:SetSize(width, barHeight)
            BBF.SetMirrorPlayerHealthbarMask()
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
    if not BetterBlizzFramesDB.noPortraitModes or BetterBlizzFramesDB.noPortraitPixelBorder then return end
    local _, healthBar, mask = GetHealthBits()
    mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -33, 11)
end
local function VehicleMaskOffset()
    if not BetterBlizzFramesDB.noPortraitModes or BetterBlizzFramesDB.noPortraitPixelBorder then return end
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
    if BetterBlizzFramesDB.noPortraitModes then
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
    if BetterBlizzFramesDB.noPortraitModes then
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
    if BetterBlizzFramesDB.noPortraitModes then
        BBF.UpdateNoPortraitText(PlayerFrame, "player")
    end
end
