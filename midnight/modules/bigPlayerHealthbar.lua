local GROW_DOWN = 12
local MASK_BASE_HEIGHT = 34

local function GetResourceBars()
    return {
        PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea,
        InsanityBarFrame,
        AlternatePowerBar,
        MonkStaggerBar,
        DemonHunterSoulFragmentsBar,
        EvokerEbonMightBar,
    }
end

local resourceHooks = {}

local function GetHealthBits()
    local contentMain = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain
    local hpContainer = contentMain.HealthBarsContainer
    return hpContainer, hpContainer.HealthBar, hpContainer.HealthBarMask
end

local function IsEnabled()
    return BetterBlizzFramesDB.bigPlayerHealthbar and BetterBlizzFramesDB.noPortraitModes
end

local function HideResourceBars()
    for _, bar in pairs(GetResourceBars()) do
        if bar then
            bar:SetAlpha(0)
            if not resourceHooks[bar] then
                resourceHooks[bar] = true
                bar:HookScript("OnShow", function(self)
                    if IsEnabled() then
                        self:SetAlpha(0)
                    end
                end)
            end
        end
    end
end

local function ShowResourceBars()
    for _, bar in pairs(GetResourceBars()) do
        if bar then
            bar:SetAlpha(1)
        end
    end
end

local function GrowBar()
    local _, healthBar, mask = GetHealthBits()
    if not healthBar or not mask then
        return
    end

    healthBar.bbfBigBarOrigHeight = healthBar.bbfBigBarOrigHeight or healthBar:GetHeight()

    healthBar:SetHeight(healthBar.bbfBigBarOrigHeight + GROW_DOWN)
    mask:SetHeight(MASK_BASE_HEIGHT + GROW_DOWN)
end

local function RestoreBar()
    local _, healthBar, mask = GetHealthBits()
    if not healthBar or not mask then
        return
    end

    if healthBar.bbfBigBarOrigHeight then
        healthBar:SetHeight(healthBar.bbfBigBarOrigHeight)
    end
    mask:SetHeight(MASK_BASE_HEIGHT)
end

local function RefreshText()
    if PlayerFrame.noPortraitMode and BBF.UpdateNoPortraitText then
        BBF.UpdateNoPortraitText(PlayerFrame, "player")
    end
end

local function Apply()
    if not IsEnabled() then
        return
    end
    if InCombatLockdown() then
        BBF.RunAfterCombat(Apply)
        return
    end
    HideResourceBars()
    GrowBar()
    RefreshText()
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
        BBF.UpdateNoPortraitManaVisibility()
        Apply()
        return
    end

    if InCombatLockdown() then
        BBF.RunAfterCombat(BBF.UpdateBigPlayerHealthbar)
        return
    end
    RestoreBar()
    ShowResourceBars()
    if BetterBlizzFramesDB.noPortraitModes then
        BBF.UpdateNoPortraitManaVisibility()
        RefreshText()
    end
end
