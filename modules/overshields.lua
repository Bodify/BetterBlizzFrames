----------------------------------------------------
---- Overshields is a fork by Casper Storm of the abandoned DerangementShieldMeters addon by Derangement
---- with a tweak from me, Bodify, to get rid of a minor bug
----------------------------------------------------
local ABSORB_GLOW_ALPHA = 0.6;
local ABSORB_GLOW_OFFSET = -5;
local UNITFRAME_OVERSHIELD_HOOKED = false
local COMPACT_UNITFRAME_OVERSHIELD_HOOKED = false

local function getAbsorbOverlay(frame)
    if frame == PlayerFrame then
        return frame.PlayerFrameContent.PlayerFrameContentMain.HealthBarArea.HealthBar.TotalAbsorbBar.TiledFillOverlay
    elseif frame == TargetFrame or frame == FocusFrame then
        return frame.TargetFrameContent.TargetFrameContentMain.HealthBar.TotalAbsorbBar.TiledFillOverlay
    end
end

local function BBF_UnitFrame_Update(frame)
    local absorbBar = frame.totalAbsorbBar;
    if not absorbBar or absorbBar:IsForbidden() then
        return
    end

    local absorbOverlay = getAbsorbOverlay(frame)
    if not absorbOverlay or absorbOverlay:IsForbidden() then
        return
    end

    local healthBar = frame.healthbar;
    if not healthBar or healthBar:IsForbidden() then
        return
    end

    absorbOverlay:SetParent(healthBar);
    absorbOverlay:ClearAllPoints(); -- we'll be attaching the overlay on heal prediction update.

    local absorbGlow = frame.overAbsorbGlow;
    if absorbGlow and not absorbGlow:IsForbidden() then
        absorbGlow:ClearAllPoints();
        absorbGlow:SetPoint("TOPLEFT", absorbOverlay, "TOPLEFT", ABSORB_GLOW_OFFSET, 0);
        absorbGlow:SetPoint("BOTTOMLEFT", absorbOverlay, "BOTTOMLEFT", ABSORB_GLOW_OFFSET, 0);
        absorbGlow:SetAlpha(ABSORB_GLOW_ALPHA);
    end
end

local function BBF_UnitFrameHealPredictionBars_Update(frame)
    local absorbBar = frame.totalAbsorbBar;
    if not absorbBar or absorbBar:IsForbidden() then
        return
    end

    local absorbOverlay = getAbsorbOverlay(frame)
    if not absorbOverlay or absorbOverlay:IsForbidden() then
        return
    end

    local healthBar = frame.healthbar;
    if not healthBar or healthBar:IsForbidden() then
        return
    end

    local _, maxHealth = healthBar:GetMinMaxValues();
    if maxHealth <= 0 then
        return
    end

    local totalAbsorb = UnitGetTotalAbsorbs(frame.unit) or 0;
    if totalAbsorb > maxHealth then
        totalAbsorb = maxHealth;
    end

    if totalAbsorb > 0 then -- show overlay when there's a positive absorb amount
        if absorbBar:IsShown() then -- If absorb bar is shown, attach absorb overlay to it; otherwise, attach to health bar.
            absorbOverlay:SetPoint("TOPRIGHT", absorbBar, "TOPRIGHT", 0, 0);
            absorbOverlay:SetPoint("BOTTOMRIGHT", absorbBar, "BOTTOMRIGHT", 0, 0);
        else
            absorbOverlay:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", 0, 0);
            absorbOverlay:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0);
        end

        local totalWidth, totalHeight = healthBar:GetSize();
        local barSize = totalAbsorb / maxHealth * totalWidth;

        absorbOverlay:SetWidth(barSize);
        --absorbOverlay:SetTexCoord(0, barSize / absorbOverlay.tileSize, 0, totalHeight / absorbOverlay.tileSize);
        absorbOverlay:Show();

        -- frame.overAbsorbGlow:Show();	--uncomment this if you want to ALWAYS show the glow to the left of the shield overlay
    else
        absorbOverlay:Hide();
    end
end

local function BBF_CompactUnitFrame_UpdateAll(frame)
    if frame.unit and frame.unit:find("nameplate") then return end
    local absorbBar = frame.totalAbsorb;
    if not absorbBar or absorbBar:IsForbidden() then
        return
    end

    local absorbOverlay = frame.totalAbsorbOverlay;
    if not absorbOverlay or absorbOverlay:IsForbidden() then
        return
    end

    local healthBar = frame.healthBar;
    if not healthBar or healthBar:IsForbidden() then
        return
    end

    absorbOverlay:SetParent(healthBar);
    absorbOverlay:ClearAllPoints(); -- we'll be attaching the overlay on heal prediction update.

    local absorbGlow = frame.overAbsorbGlow;
    if absorbGlow and not absorbGlow:IsForbidden() then
        absorbGlow:ClearAllPoints();
        absorbGlow:SetPoint("TOPLEFT", absorbOverlay, "TOPLEFT", ABSORB_GLOW_OFFSET, 0);
        absorbGlow:SetPoint("BOTTOMLEFT", absorbOverlay, "BOTTOMLEFT", ABSORB_GLOW_OFFSET, 0);
        absorbGlow:SetAlpha(ABSORB_GLOW_ALPHA);
    end
end

local function BBF_CompactUnitFrame_UpdateHealPrediction(frame)
    if frame.unit and frame.unit:find("nameplate") then return end
    local absorbBar = frame.totalAbsorb;
    if not absorbBar or absorbBar:IsForbidden() then
        return
    end

    local absorbOverlay = frame.totalAbsorbOverlay;
    if not absorbOverlay or absorbOverlay:IsForbidden() then
        return
    end

    local healthBar = frame.healthBar;
    if not healthBar or healthBar:IsForbidden() then
        return
    end

    local _, maxHealth = healthBar:GetMinMaxValues();
    if maxHealth <= 0 then
        return
    end

    local totalAbsorb = UnitGetTotalAbsorbs(frame.displayedUnit) or 0;
    if totalAbsorb > maxHealth then
        totalAbsorb = maxHealth;
    end

    if totalAbsorb > 0 then -- show overlay when there's a positive absorb amount
        if absorbBar:IsShown() then -- If absorb bar is shown, attach absorb overlay to it; otherwise, attach to health bar.
            absorbOverlay:SetPoint("TOPRIGHT", absorbBar, "TOPRIGHT", 0, 0);
            absorbOverlay:SetPoint("BOTTOMRIGHT", absorbBar, "BOTTOMRIGHT", 0, 0);
        else
            absorbOverlay:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", 0, 0);
            absorbOverlay:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0);
        end

        local totalWidth, totalHeight = healthBar:GetSize();
        local barSize = totalAbsorb / maxHealth * totalWidth;

        absorbOverlay:SetWidth(barSize);
        absorbOverlay:SetTexCoord(0, barSize / absorbOverlay.tileSize, 0, totalHeight / absorbOverlay.tileSize);
        absorbOverlay:Show();

        -- frame.overAbsorbGlow:Show();	--uncomment this if you want to ALWAYS show the glow to the left of the shield overlay
    end
end

local function OnTargetChanged(self, event)
    BBF_UnitFrameHealPredictionBars_Update(TargetFrame)
    BBF_UnitFrameHealPredictionBars_Update(FocusFrame)
    --self:UnregisterEvent(event)
end

function BBF.HookOverShields()
    if BetterBlizzFramesDB.overShields then
        BBF.HookOverShieldCompactUnitFrames()
        BBF.HookOverShieldUnitFrames()
    end
end

function BBF.HookOverShieldCompactUnitFrames()
    if not BetterBlizzFramesDB.overShieldsCompactUnitFrames or COMPACT_UNITFRAME_OVERSHIELD_HOOKED then
        return
    end

    hooksecurefunc("CompactUnitFrame_UpdateAll", BBF_CompactUnitFrame_UpdateAll)
    hooksecurefunc("CompactUnitFrame_UpdateHealPrediction", BBF_CompactUnitFrame_UpdateHealPrediction)

    COMPACT_UNITFRAME_OVERSHIELD_HOOKED = true
end

function BBF.HookOverShieldUnitFrames()
    if not BetterBlizzFramesDB.overShieldsUnitFrames or UNITFRAME_OVERSHIELD_HOOKED then
        return
    end


    hooksecurefunc("UnitFrame_Update", BBF_UnitFrame_Update)
    hooksecurefunc("UnitFrameHealPredictionBars_Update", BBF_UnitFrameHealPredictionBars_Update)

    C_Timer.After(3, function()
        BBF_UnitFrameHealPredictionBars_Update(PlayerFrame)
        BBF_UnitFrameHealPredictionBars_Update(TargetFrame)
        BBF_UnitFrameHealPredictionBars_Update(FocusFrame)
    end)


    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    eventFrame:SetScript("OnEvent", OnTargetChanged)

    UNITFRAME_OVERSHIELD_HOOKED = true
end