local ABSORB_GLOW_ALPHA  = 0.6
local ABSORB_GLOW_OFFSET = -5

local UNITFRAME_OVERSHIELD_HOOKED = false
local COMPACT_UNITFRAME_OVERSHIELD_HOOKED = false
local PRD_OVERSHIELD_HOOKED = false

local function CreateOvershieldBar(healthBar, classicOffset, prd)
    local overshieldBar = CreateFrame("StatusBar", nil, healthBar)
    if classicOffset then
        overshieldBar:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 0, -10)
        overshieldBar:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0)
    else
        overshieldBar:SetAllPoints(healthBar)
    end
    overshieldBar:SetReverseFill(true)
    overshieldBar:SetStatusBarTexture("Interface\\RaidFrame\\Shield-Overlay")
    overshieldBar:SetFrameLevel(healthBar:GetFrameLevel())
    overshieldBar:SetStatusBarColor(1, 1, 1, 0.8)

    local barTex = overshieldBar:GetStatusBarTexture()
    barTex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", "REPEAT", "REPEAT")
    barTex:SetHorizTile(true)
    barTex:SetVertTile(true)
    if not prd then
        barTex:SetDrawLayer("ARTWORK", -3)
    else
        barTex:SetDrawLayer("ARTWORK", 1)
    end

    return overshieldBar
end

local function AdjustAbsorbGlow(absorbGlow, anchorBar, clamped)
    local barTex = anchorBar:GetStatusBarTexture()
    absorbGlow:ClearAllPoints()
    absorbGlow:SetPoint("TOPLEFT", barTex, "TOPLEFT", ABSORB_GLOW_OFFSET, 1)
    absorbGlow:SetPoint("BOTTOMLEFT", barTex, "BOTTOMLEFT", ABSORB_GLOW_OFFSET, -1)
    absorbGlow:SetAlphaFromBoolean(clamped, ABSORB_GLOW_ALPHA, 0)
    absorbGlow:SetWidth(13)
end

local function BBF_UnitFrameHealPredictionBars_Update(frame, classicOffset)
    local healthBar = frame.healthbar
    if not healthBar or healthBar:IsForbidden() then return end

    local absorbGlow = frame.overAbsorbGlow
    if not absorbGlow or absorbGlow:IsForbidden() then return end

    if not frame.bbfOvershieldBar then
        frame.bbfOvershieldBar = CreateOvershieldBar(healthBar, classicOffset)
        frame.healPredictionCalc = CreateUnitHealPredictionCalculator()
        frame.healPredictionCalc:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth)
    end

    local overshieldBar = frame.bbfOvershieldBar
    local unit = frame.unit

    UnitGetDetailedHealPrediction(unit, nil, frame.healPredictionCalc)
    local _, clamped = frame.healPredictionCalc:GetDamageAbsorbs()
    local totalAbsorbs = UnitGetTotalAbsorbs(unit) or 0
    local _, maxVal = healthBar:GetMinMaxValues()
    local blizzAbsorbOverlay = frame.totalAbsorbBar.TiledFillOverlay

    overshieldBar:SetMinMaxValues(0, maxVal)
    overshieldBar:SetValue(totalAbsorbs)
    overshieldBar:SetAlphaFromBoolean(clamped, 1, 0)
    blizzAbsorbOverlay:SetAlphaFromBoolean(clamped, 0, 1)
    AdjustAbsorbGlow(absorbGlow, overshieldBar, clamped)
end

local function BBF_CompactUnitFrame_UpdateHealPrediction(frame)
    if not frame.unit then return end
    local unit = frame.displayedUnit or frame.unit
    if unit:find("nameplate") then return end
    if frame:IsForbidden() then return end

    local absorbGlow = frame.overAbsorbGlow
    if not absorbGlow or absorbGlow:IsForbidden() then return end

    local healthBar = frame.healthBar
    if not healthBar or healthBar:IsForbidden() then return end

    if not frame.bbfOvershieldBar then
        frame.bbfOvershieldBar = CreateOvershieldBar(healthBar)
        frame.healPredictionCalc = CreateUnitHealPredictionCalculator()
        frame.healPredictionCalc:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth)
        absorbGlow:SetDrawLayer("ARTWORK", -2)
    end

    local overshieldBar = frame.bbfOvershieldBar

    UnitGetDetailedHealPrediction(unit, nil, frame.healPredictionCalc)
    local _, clamped = frame.healPredictionCalc:GetDamageAbsorbs()
    local totalAbsorbs = UnitGetTotalAbsorbs(unit) or 0
    local _, maxVal = healthBar:GetMinMaxValues()

    overshieldBar:SetMinMaxValues(0, maxVal)
    overshieldBar:SetValue(totalAbsorbs)
    overshieldBar:SetAlphaFromBoolean(clamped, 1, 0)
    AdjustAbsorbGlow(absorbGlow, overshieldBar, clamped)
end

local function BBF_UpdatePersonalResourceFrame()
    local frame = PersonalResourceDisplayFrame
    local healthBar = frame.HealthBarsContainer.healthBar
    local absorbGlow = healthBar.overAbsorbGlow
    if not absorbGlow or absorbGlow:IsForbidden() then return end
    if not healthBar or healthBar:IsForbidden() then return end

    local overshieldBar = frame.bbfOvershieldBar
    UnitGetDetailedHealPrediction("player", nil, frame.healPredictionCalc)
    local _, clamped = frame.healPredictionCalc:GetDamageAbsorbs()
    local totalAbsorbs = UnitGetTotalAbsorbs("player") or 0
    local _, maxVal = healthBar:GetMinMaxValues()
    local totalAbsorbOverlay = healthBar.totalAbsorbOverlay

    overshieldBar:SetMinMaxValues(0, maxVal)
    overshieldBar:SetValue(totalAbsorbs)
    overshieldBar:SetAlphaFromBoolean(clamped, 1, 0)
    totalAbsorbOverlay:SetAlphaFromBoolean(clamped, 0, 1)
    AdjustAbsorbGlow(absorbGlow, overshieldBar, clamped)
end

function BBF.HookOverShields()
    if BetterBlizzFramesDB.overShields then
        BBF.HookOverShieldCompactUnitFrames()
        BBF.HookOverShieldUnitFrames()
        BBF.HookOverShieldPersonalResourceDisplay()
    end
end

function BBF.HookOverShieldPersonalResourceDisplay()
    if PRD_OVERSHIELD_HOOKED or not C_CVar.GetCVarBool("nameplateShowSelf") then return end
    if not BetterBlizzFramesDB.overShieldsCompactUnitFrames
       and not BetterBlizzFramesDB.overShieldsUnitFrames then
        return
    end

    local frame = PersonalResourceDisplayFrame
    local healthBar = frame.HealthBarsContainer.healthBar
    local totalAbsorbOverlay = healthBar.totalAbsorbOverlay
    local absorbGlow = healthBar.overAbsorbGlow

    if frame.bbOvershields then return end

    local prdEvents = CreateFrame("Frame")
    prdEvents:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
    prdEvents:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", "player")
    prdEvents:RegisterUnitEvent("UNIT_HEALTH", "player")
    prdEvents:RegisterUnitEvent("UNIT_MAXHEALTH", "player")

    totalAbsorbOverlay:SetTexture("Interface\\RaidFrame\\Shield-Overlay", "REPEAT", "REPEAT")
    totalAbsorbOverlay:SetHorizTile(true)
    totalAbsorbOverlay:SetVertTile(true)
    totalAbsorbOverlay:SetVertexColor(1, 1, 1, 0.7)
    absorbGlow:SetDrawLayer("ARTWORK", 2)

    frame.bbfOvershieldBar = CreateOvershieldBar(healthBar, nil, true)
    frame.healPredictionCalc = CreateUnitHealPredictionCalculator()
    frame.healPredictionCalc:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth)

    prdEvents:SetScript("OnEvent", BBF_UpdatePersonalResourceFrame)
    BBF_UpdatePersonalResourceFrame()

    frame.bbOvershields = true
    PRD_OVERSHIELD_HOOKED = true
end

function BBF.HookOverShieldCompactUnitFrames()
    if not BetterBlizzFramesDB.overShieldsCompactUnitFrames or COMPACT_UNITFRAME_OVERSHIELD_HOOKED then
        return
    end

    hooksecurefunc("CompactUnitFrame_UpdateHealPrediction", BBF_CompactUnitFrame_UpdateHealPrediction)

    COMPACT_UNITFRAME_OVERSHIELD_HOOKED = true
end

function BBF.HookOverShieldUnitFrames()
    if not BetterBlizzFramesDB.overShieldsUnitFrames or UNITFRAME_OVERSHIELD_HOOKED then
        return
    end

    local classicFramesEnabled = C_AddOns.IsAddOnLoaded("ClassicFrames")

    if not classicFramesEnabled then
        local classicOffset = BetterBlizzFramesDB.classicFrames
        hooksecurefunc("UnitFrameHealPredictionBars_Update", function(frame)
            BBF_UnitFrameHealPredictionBars_Update(frame, classicOffset)
        end)

        C_Timer.After(3, function()
            BBF_UnitFrameHealPredictionBars_Update(PlayerFrame, classicOffset)
            BBF_UnitFrameHealPredictionBars_Update(TargetFrame, classicOffset)
            BBF_UnitFrameHealPredictionBars_Update(FocusFrame, classicOffset)
        end)
    else
        local classicFrames = {
            [PlayerFrame] = CfPlayerFrame,
            [TargetFrame] = CfTargetFrame,
            [FocusFrame] = CfFocusFrame
        }
        hooksecurefunc("UnitFrameHealPredictionBars_Update", function(frame)
            local classicFrame = classicFrames[frame]
            if classicFrame then
                BBF_UnitFrameHealPredictionBars_Update(classicFrame)
            end
        end)

        C_Timer.After(3, function()
            BBF_UnitFrameHealPredictionBars_Update(CfPlayerFrame)
            BBF_UnitFrameHealPredictionBars_Update(CfTargetFrame)
            BBF_UnitFrameHealPredictionBars_Update(CfFocusFrame)
        end)

    end


    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    eventFrame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_TARGET_CHANGED" then
            BBF_UnitFrameHealPredictionBars_Update(TargetFrame)
            self:UnregisterEvent("PLAYER_TARGET_CHANGED")
        elseif event == "PLAYER_FOCUS_CHANGED" then
            BBF_UnitFrameHealPredictionBars_Update(FocusFrame)
            self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
        end
    end)

    UNITFRAME_OVERSHIELD_HOOKED = true
end