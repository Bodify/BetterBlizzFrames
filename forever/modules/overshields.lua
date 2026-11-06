local ABSORB_GLOW_ALPHA  = 0.6
local ABSORB_GLOW_OFFSET = -5

local UNITFRAME_OVERSHIELD_HOOKED = false
local COMPACT_UNITFRAME_OVERSHIELD_HOOKED = false
local PRD_OVERSHIELD_HOOKED = false
local classicBars

local function ClassicStyleBar(frame)
    if classicBars then return classicBars[frame] end
    local absorbBar = BBF.ClassicStyleAddon() and frame.totalAbsorbBar
    local parent = absorbBar and absorbBar:GetParent()
    return parent ~= frame.healthbar and parent or nil
end

local function AnchorOvershieldBar(overshieldBar, healthBar)
    if healthBar.bbfMirror then
        overshieldBar:ClearAllPoints()
        overshieldBar:SetAllPoints(healthBar)
        overshieldBar.bbfAnchoredToBox = true
        return
    end
    local box = BetterBlizzFramesDB and BetterBlizzFramesDB.noPortraitPixelBorder
        and healthBar.BBFPositionFrame or nil

    overshieldBar:ClearAllPoints()
    overshieldBar:SetAllPoints(box or healthBar)

    overshieldBar.bbfAnchoredToBox = box and true or false
end

function BBF.UpdatePlayerOvershieldAnchor()
    local overshieldBar = PlayerFrame.healthbar.bbfOvershieldBar
    if not overshieldBar then return end
    AnchorOvershieldBar(overshieldBar, PlayerFrame.healthbar)
end

local function CreateOvershieldBar(healthBar, higherLayer)
    local overshieldBar = CreateFrame("StatusBar", nil, healthBar)
    AnchorOvershieldBar(overshieldBar, healthBar)
    overshieldBar:SetReverseFill(true)
    overshieldBar:SetStatusBarTexture("Interface\\RaidFrame\\Shield-Overlay")
    local smoothOverlay = healthBar.bbfSmoothOverlay
    if smoothOverlay then
        overshieldBar:SetFrameLevel(smoothOverlay:GetFrameLevel() + 1)
    else
        overshieldBar:SetFrameLevel(healthBar:GetFrameLevel())
    end
    healthBar.bbfOvershieldBar = overshieldBar
    overshieldBar:SetStatusBarColor(1, 1, 1, 0.8)

    local barTex = overshieldBar:GetStatusBarTexture()
    barTex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", "REPEAT", "REPEAT")
    barTex:SetHorizTile(true)
    barTex:SetVertTile(true)
    if higherLayer then
        barTex:SetDrawLayer("ARTWORK", 1)
    else
        barTex:SetDrawLayer("ARTWORK", -3)
    end

    local glow = overshieldBar:CreateTexture(nil, "OVERLAY")
    glow:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
    glow:SetBlendMode("ADD")
    glow:SetWidth(13)
    overshieldBar.bbfGlow = glow

    return overshieldBar
end

local function AdjustAbsorbGlow(absorbGlow, anchorBar, clamped)
    absorbGlow:SetAlpha(0)
    absorbGlow.bbfOvershieldAnchored = true
    local glow = anchorBar.bbfGlow
    if not glow.bbfAnchored then
        local barTex = anchorBar:GetStatusBarTexture()
        glow:SetPoint("TOPLEFT", barTex, "TOPLEFT", ABSORB_GLOW_OFFSET, 1)
        glow:SetPoint("BOTTOMLEFT", barTex, "BOTTOMLEFT", ABSORB_GLOW_OFFSET, -1)
        glow.bbfAnchored = true
    end
    glow:SetAlphaFromBoolean(clamped, BetterBlizzFramesDB.hideAllAbsorbGlow and 0 or ABSORB_GLOW_ALPHA, 0)
end

local function BBF_UnitFrameHealPredictionBars_Update(frame)
    local mirror = BBF.GetHealthbarMirror and BBF.GetHealthbarMirror(frame)
    local classicBar = ClassicStyleBar(frame)
    local healthBar = classicBar or (mirror and mirror.bar) or frame.healthbar
    if not healthBar or healthBar:IsForbidden() then return end

    local absorbGlow = mirror and mirror.glows.OverAbsorbGlow or frame.overAbsorbGlow
    if not absorbGlow or absorbGlow:IsForbidden() then return end

    if not frame.healPredictionCalc then
        frame.healPredictionCalc = CreateUnitHealPredictionCalculator()
        frame.healPredictionCalc:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth)
    end
    if not healthBar.bbfOvershieldBar then
        CreateOvershieldBar(healthBar, true)
        if classicBar then
            healthBar.bbfOvershieldBar:SetFrameLevel(healthBar:GetFrameLevel() + 1)
        end
    end

    local overshieldBar = healthBar.bbfOvershieldBar
    frame.bbfOvershieldBar = overshieldBar
    local unit = frame.unit

    local mask = not classicBar and BBF.HealthBarMask and BBF.HealthBarMask(frame) or nil
    if mask and not mask:IsShown() then
        mask = nil
    end
    if mask ~= overshieldBar.bbfMask then
        local barTex = overshieldBar:GetStatusBarTexture()
        if overshieldBar.bbfMask then
            barTex:RemoveMaskTexture(overshieldBar.bbfMask)
            overshieldBar.bbfGlow:RemoveMaskTexture(overshieldBar.bbfMask)
        end
        if mask then
            barTex:AddMaskTexture(mask)
            overshieldBar.bbfGlow:AddMaskTexture(mask)
        end
        overshieldBar.bbfMask = mask
    end

    if not overshieldBar.bbfAnchoredToBox and healthBar.BBFPositionFrame then
        AnchorOvershieldBar(overshieldBar, healthBar)
    end

    UnitGetDetailedHealPrediction(unit, nil, frame.healPredictionCalc)
    local _, clamped = frame.healPredictionCalc:GetDamageAbsorbs()
    local totalAbsorbs = UnitGetTotalAbsorbs(unit) or 0
    local _, maxVal = (classicBar and frame.healthbar or healthBar):GetMinMaxValues()
    local absorbBar = mirror and mirror.TotalAbsorbBar or frame.totalAbsorbBar
    local blizzAbsorbOverlay = absorbBar.TiledFillOverlay

    overshieldBar:SetMinMaxValues(0, maxVal)
    overshieldBar:SetValue(totalAbsorbs)
    overshieldBar:SetAlphaFromBoolean(clamped, 1, 0)
    blizzAbsorbOverlay:SetAlphaFromBoolean(clamped, 0, 1)
    AdjustAbsorbGlow(absorbGlow, overshieldBar, clamped)
end

local function BBF_CompactUnitFrame_UpdateHealPrediction(frame)
    if not frame.unit then return end
    local unit = frame.displayedUnit or frame.unit
    if frame.namePlateFrame or unit:find("nameplate") then return end
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
    prdEvents:RegisterEvent("PLAYER_REGEN_DISABLED")

    totalAbsorbOverlay:SetTexture("Interface\\RaidFrame\\Shield-Overlay", "REPEAT", "REPEAT")
    totalAbsorbOverlay:SetHorizTile(true)
    totalAbsorbOverlay:SetVertTile(true)
    totalAbsorbOverlay:SetVertexColor(1, 1, 1, 0.7)
    absorbGlow:SetDrawLayer("ARTWORK", 2)

    frame.bbfOvershieldBar = CreateOvershieldBar(healthBar, true)
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

    if C_AddOns.IsAddOnLoaded("ClassicFrames") and CfPlayerFrame then
        classicBars = {
            [PlayerFrame] = CfPlayerFrame.HealthBar,
            [TargetFrame] = CfTargetFrame.HealthBar,
            [FocusFrame] = CfFocusFrame.HealthBar,
        }
    end

    hooksecurefunc("UnitFrameHealPredictionBars_Update", function(frame)
        if BBF.ClassicStyleAddon() and frame ~= PlayerFrame and frame ~= TargetFrame and frame ~= FocusFrame then return end
        BBF_UnitFrameHealPredictionBars_Update(frame)
    end)

    C_Timer.After(3, function()
        BBF_UnitFrameHealPredictionBars_Update(PlayerFrame)
        BBF_UnitFrameHealPredictionBars_Update(TargetFrame)
        BBF_UnitFrameHealPredictionBars_Update(FocusFrame)
    end)

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