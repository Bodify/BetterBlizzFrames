-- Big Healthbar (No Portrait): the PlayerFrame health bar takes over the mana slot.

local HEALTHBAR_HEIGHT = 20
local HEALTHBAR_HEIGHT_GROWN = 30
local MASK_HEIGHT = 34
local MASK_HEIGHT_GROWN = 48

local function GetHealthBits()
    local hpContainer = PlayerFrame_GetHealthBarContainer()
    return hpContainer, hpContainer.HealthBar, hpContainer.HealthBarMask
end

local function IsEnabled()
    return BetterBlizzFramesDB.bigPlayerHealthbar and BetterBlizzFramesDB.noPortraitModes
end

local function GrowBar()
    local _, healthBar, mask = GetHealthBits()
    if not healthBar or not mask then
        return
    end
    healthBar:SetHeight(HEALTHBAR_HEIGHT_GROWN)
    mask:SetHeight(MASK_HEIGHT_GROWN)
end

local function RestoreBar()
    local _, healthBar, mask = GetHealthBits()
    if not healthBar or not mask then
        return
    end

    healthBar:SetHeight(HEALTHBAR_HEIGHT)
    mask:SetHeight(MASK_HEIGHT)
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
    BBF.UpdateNoPortraitText(PlayerFrame, "player")
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
