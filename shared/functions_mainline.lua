-- Mana feedback fix
local function ResolveOverlayTexture(overlay)
    if not overlay then return nil end
    if overlay.SetAtlas then return overlay end
    if overlay.Fill and overlay.Fill.SetAtlas then return overlay.Fill end
    return nil
end

local function SyncBarTexture(overlay, src)
    local texture = ResolveOverlayTexture(overlay)
    if not texture then return end
    if texture.bbfTexture then
        texture:SetTexture(texture.bbfTexture)
        return
    end
    local atlas = src:GetAtlas()
    if atlas then
        texture:SetAtlas(atlas, false)
    else
        local file = src:GetTexture()
        if file then
            texture:SetTexture(file)
        end
    end
end

local function SyncFeedbackTexture(bar)
    local src = bar:GetStatusBarTexture()
    if not src then return end
    SyncBarTexture(bar.FeedbackFrame and bar.FeedbackFrame.BarTexture, src)
    SyncBarTexture(bar.ManaCostPredictionBar, src)
end

local function HookFeedback(bar)
    if not bar or bar.bbfFeedbackHooked then return end
    if not bar.FeedbackFrame and not ResolveOverlayTexture(bar.ManaCostPredictionBar) then return end
    bar.bbfFeedbackHooked = true
    hooksecurefunc(bar, "SetStatusBarTexture", SyncFeedbackTexture)
    if bar.FeedbackFrame then
        hooksecurefunc(bar.FeedbackFrame, "Initialize", function()
            SyncFeedbackTexture(bar)
        end)
    end
    SyncFeedbackTexture(bar)
end

function BBF.FixFeedbackTextures()
    local db = BetterBlizzFramesDB
    if not db.tweakExtraBarTextures then return end
    if not db.hideManaFeedback then
        HookFeedback(PlayerFrame and PlayerFrame.manabar)
    end

    if not db.hidePersonalManaFX and not db.hideManaFeedback then
        HookFeedback(PersonalResourceDisplayFrame and PersonalResourceDisplayFrame.PowerBar)
    end
end

-- Heal prediction fix
local function SyncHealPrediction(bar, myBar, otherBar)
    local src = bar:GetStatusBarTexture()
    if not src then return end
    SyncBarTexture(myBar, src)
    SyncBarTexture(otherBar, src)
end

local function HookHealPrediction(bar, myBar, otherBar)
    if not bar or bar.bbfHealPredictionHooked then return end
    if not ResolveOverlayTexture(myBar) and not ResolveOverlayTexture(otherBar) then return end
    bar.bbfHealPredictionHooked = true
    hooksecurefunc(bar, "SetStatusBarTexture", function()
        SyncHealPrediction(bar, myBar, otherBar)
    end)
    SyncHealPrediction(bar, myBar, otherBar)
end

function BBF.FixHealPredictionTextures()
    if not BetterBlizzFramesDB.tweakExtraBarTextures then return end
    local prd = PersonalResourceDisplayFrame
    local prdHealth = prd and prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar
    if prdHealth then
        HookHealPrediction(prdHealth, prdHealth.myHealPrediction, prdHealth.otherHealPrediction)
    end

    local frames = { PlayerFrame, TargetFrame, FocusFrame }
    for i = 1, #frames do
        local frame = frames[i]
        local healthbar = frame and frame.healthbar
        if healthbar then
            HookHealPrediction(healthbar, frame.myHealPredictionBar, frame.otherHealPredictionBar)
        end
    end
end
