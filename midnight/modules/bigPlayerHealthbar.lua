-- Big Healthbar (No Portrait): the PlayerFrame health bar takes over the mana slot.

-- Blizzard's player-bars heights: health 19, mana 10, 1px gap.
-- Mask is noPortrait's portrait-off mask (uipartyframeportraitoffhealthmask, 190x34);
local HEALTHBAR_HEIGHT = 19
local MANABAR_HEIGHT = 10
local BAR_GAP = 1
local HEALTHBAR_HEIGHT_GROWN = HEALTHBAR_HEIGHT + BAR_GAP + MANABAR_HEIGHT -- 30
local MASK_HEIGHT = 34
local MASK_HEIGHT_GROWN = 50

local function GetHealthBits()
    local hpContainer = PlayerFrame_GetHealthBarContainer()
    return hpContainer, hpContainer.HealthBar, hpContainer.HealthBarMask
end

local function IsEnabled()
    return BetterBlizzFramesDB.bigPlayerHealthbar and BetterBlizzFramesDB.noPortraitModes
end

function BBF.GetBigPlayerHealthbarGrowth()
    return 0--IsEnabled() and (HEALTHBAR_HEIGHT_GROWN - HEALTHBAR_HEIGHT) or 0
end

local function GrowBar()
    local hpContainer, healthBar, mask = GetHealthBits()
    hpContainer:SetHeight(HEALTHBAR_HEIGHT_GROWN)
    healthBar:SetHeight(HEALTHBAR_HEIGHT_GROWN)
    mask:SetHeight(MASK_HEIGHT_GROWN)
end

local function RestoreBar()
    local hpContainer, healthBar, mask = GetHealthBits()
    hpContainer:SetHeight(HEALTHBAR_HEIGHT)
    healthBar:SetHeight(HEALTHBAR_HEIGHT)
    mask:SetHeight(MASK_HEIGHT)
end
local function PlayerMaskOffset()
    local _, healthBar, mask = GetHealthBits()
    mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -33, 11)
end
local function VehicleMaskOffset()
    local _, healthBar, mask = GetHealthBits()
    mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -34, 10)
end
local function Apply()
    if not IsEnabled() then
        return
    end
    if InCombatLockdown() then
        BBF.RunAfterCombat(Apply)
        return
    end
    BBF.UpdateNoPortraitManaVisibility()
    GrowBar()
    PlayerMaskOffset()
    BBF.UpdateNoPortraitText(PlayerFrame, "player")
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
    BBF.UnregisterPlayerFrameArtEvents()
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
    if BetterBlizzFramesDB.noPortraitModes then
        BBF.UpdateNoPortraitText(PlayerFrame, "player")
    end
end
