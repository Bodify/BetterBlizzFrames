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

local strataOrder = {
    BACKGROUND = 1,
    LOW = 2,
    MEDIUM = 3,
    HIGH = 4,
    DIALOG = 5,
    FULLSCREEN = 6,
    FULLSCREEN_DIALOG = 7,
    TOOLTIP = 8,
}

local function TargetArtTop()
    local topStrata, topLevel = TargetFrame:GetFrameStrata(), TargetFrame:GetFrameLevel()
    local function Check(art)
        if not art then return end
        local strata, level = art:GetFrameStrata(), art:GetFrameLevel()
        if strataOrder[strata] > strataOrder[topStrata] or (strata == topStrata and level > topLevel) then
            topStrata, topLevel = strata, level
        end
    end
    Check(TargetFrame.ClassicFrame)
    Check(TargetFrame.noPortraitMode)
    return topStrata, topLevel
end

function BBF.RaiseAboveTargetArt(frame, minStrata, levelBump)
    if not frame or not TargetFrame then return end
    local topStrata, topLevel = TargetArtTop()
    local strata = topStrata
    if minStrata and strataOrder[minStrata] > strataOrder[topStrata] then
        strata = minStrata
    end
    if frame.SetFixedFrameStrata then
        frame:SetFixedFrameStrata(false)
        frame:SetFixedFrameLevel(false)
    end
    frame:SetFrameStrata(strata)
    if strata == topStrata then
        frame:SetFrameLevel(math.min(topLevel + (levelBump or 20), 9998))
    end
    if frame.SetFixedFrameStrata then
        frame:SetFixedFrameStrata(true)
        frame:SetFixedFrameLevel(true)
    end
end

function BBF.ReleaseTargetArtLayer(frame)
    if frame and frame.SetFixedFrameStrata then
        frame:SetFixedFrameStrata(false)
        frame:SetFixedFrameLevel(false)
    end
end

function BBF.RaiseCombosAboveTargetArt()
    local legacyCombo = BBF.LegacyComboFrame
    if legacyCombo and legacyCombo:GetParent() == TargetFrame then
        BBF.RaiseAboveTargetArt(legacyCombo, "HIGH")
    end
    if BBF.RaiseBlizzardComboRing then
        BBF.RaiseBlizzardComboRing()
    end
    if BBF.ApplyComboPointTargetLayout then
        BBF.ApplyComboPointTargetLayout()
    end
    if BBF.RaiseMovedResourceAboveTargetArt then
        BBF.RaiseMovedResourceAboveTargetArt()
    end
end

do
    local formatters = {}

    local function ColorHex(c)
        local function byte(v)
            return math.floor(math.max(0, math.min(1, v or 1)) * 255 + 0.5)
        end
        return string.format("%02x%02x%02x", byte(c[1]), byte(c[2]), byte(c[3]))
    end

    local function Breakpoint(threshold, format, step, div)
        return {
            threshold = threshold,
            format = format,
            step = not div and step or nil,
            rounding = Enum.NumericRuleFormatRounding.Up,
            components = div and { { div = div, step = step, rounding = Enum.NumericRuleFormatRounding.Up } } or nil,
        }
    end

    function BBF.GetTimerFormatter(lowColor, lowThreshold, milliseconds, hideLong)
        lowThreshold = math.min(math.max(lowThreshold or 0, 0), 59)
        local key = (lowColor and ColorHex(lowColor) or "-") .. ":" .. lowThreshold .. ":" .. (milliseconds and 1 or 0) .. ":" .. (hideLong and 1 or 0)
        local formatter = formatters[key]
        if formatter then return formatter, key end

        local breakpoints = {}
        if lowThreshold > 0 then
            local format = milliseconds and "%.1f" or "%d"
            if lowColor then
                format = "|cff" .. ColorHex(lowColor) .. format .. "|r"
            end
            breakpoints[#breakpoints + 1] = Breakpoint(0, format, milliseconds and 0.1 or 1)
        end
        breakpoints[#breakpoints + 1] = Breakpoint(lowThreshold, "%d", 1)
        if hideLong then
            breakpoints[#breakpoints + 1] = { threshold = 60, format = " " }
        else
            breakpoints[#breakpoints + 1] = Breakpoint(60, "%dm", 1, 60)
            breakpoints[#breakpoints + 1] = Breakpoint(3600, "%dh", 1, 3600)
            breakpoints[#breakpoints + 1] = Breakpoint(86400, "%dd", 1, 86400)
        end

        formatter = C_StringUtil.CreateNumericRuleFormatter()
        formatter:SetBreakpoints(breakpoints)
        formatters[key] = formatter
        return formatter, key
    end
end
