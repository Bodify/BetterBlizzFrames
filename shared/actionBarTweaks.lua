local buttonGroups = {
    { "ActionButton", 12 },
    { "MultiBarBottomLeftButton", 12 },
    { "MultiBarBottomRightButton", 12 },
    { "MultiBarRightButton", 12 },
    { "MultiBarLeftButton", 12 },
    { "MultiBar5Button", 12 },
    { "MultiBar6Button", 12 },
    { "MultiBar7Button", 12 },
    { "PetActionButton", 10 },
    { "StanceButton", 10 },
    { "PossessButton", 2 },
    { "OverrideActionBarButton", 6 },
    { "ExtraActionButton", 1 },
}

local dominosGroups = {
    { "DominosActionButton", 168 },
    { "DominosPetActionButton", 12 },
    { "DominosStanceButton", 12 },
    { "MultiBarLeftActionButton", 12 },
    { "MultiBarBottomLeftActionButton", 12 },
    { "MultiBarBottomRightActionButton", 12 },
    { "MultiBarRightActionButton", 12 },
    { "MultiBar5ActionButton", 12 },
    { "MultiBar6ActionButton", 12 },
    { "MultiBar7ActionButton", 12 },
}

local function ForEachButton(func)
    for _, group in ipairs(buttonGroups) do
        for i = 1, group[2] do
            local button = _G[group[1] .. i]
            if button then func(button) end
        end
    end
    if C_AddOns.IsAddOnLoaded("Dominos") then
        for _, group in ipairs(dominosGroups) do
            for i = 1, group[2] do
                local button = _G[group[1] .. i]
                if button then func(button) end
            end
        end
    end
end

local rangeOn, rangeHooked, rangeIconMode, rangeDesat
local rangeOverlays = {}
local rangeButtons = {}

local function GetActionInRange(action)
    if C_ActionBar and C_ActionBar.IsActionInRange then
        return C_ActionBar.IsActionInRange(action)
    elseif IsActionInRange then
        return IsActionInRange(action)
    end
end

local function SetOverlayColor(overlay)
    local c = BetterBlizzFramesDB.actionBarRangeOverlayColor or { 1, 0, 0, 0.35 }
    overlay:SetVertexColor(c[1], c[2], c[3], c[4] or 0.35)
end

local function GetRangeOverlay(button)
    local overlay = button.bbfRangeOverlay
    if overlay then return overlay end
    local icon = button.icon or button.Icon
    if not icon then return end

    overlay = button:CreateTexture(nil, "ARTWORK", nil, -1)
    overlay:SetAllPoints(icon)
    overlay:SetColorTexture(1, 1, 1, 1)
    SetOverlayColor(overlay)
    if icon.GetNumMaskTextures then
        for i = 1, icon:GetNumMaskTextures() do
            local mask = icon:GetMaskTexture(i)
            if mask then overlay:AddMaskTexture(mask) end
        end
    end
    overlay:Hide()
    button.bbfRangeOverlay = overlay
    rangeOverlays[#rangeOverlays + 1] = overlay
    return overlay
end

local function UpdateIconTint(button)
    local tint = rangeOn and (rangeIconMode or rangeDesat) and button.bbfOutOfRange or false
    if not tint and not button.bbfRangeTinted then return end
    local icon = button.icon or button.Icon
    if not icon then return end
    button.bbfRangeTinting = true
    if tint then
        if rangeIconMode then
            local c = BetterBlizzFramesDB.actionBarRangeIconColor or { 0.59, 0.24, 0.22, 1 }
            icon:SetVertexColor(c[1], c[2], c[3], c[4] or 1)
        else
            icon:SetVertexColor(button.bbfIconR or 1, button.bbfIconG or 1, button.bbfIconB or 1, button.bbfIconA or 1)
        end
        icon:SetDesaturated(rangeDesat or button.bbfIconDesat or false)
    else
        icon:SetVertexColor(button.bbfIconR or 1, button.bbfIconG or 1, button.bbfIconB or 1, button.bbfIconA or 1)
        icon:SetDesaturated(button.bbfIconDesat or false)
    end
    button.bbfRangeTinted = tint
    button.bbfRangeTinting = nil
end

local function HookIcon(button)
    if button.bbfRangeIconHooked then return end
    local icon = button.icon or button.Icon
    if not icon then return end
    button.bbfRangeIconHooked = true
    button.bbfIconR, button.bbfIconG, button.bbfIconB, button.bbfIconA = icon:GetVertexColor()
    button.bbfIconDesat = icon.IsDesaturated and icon:IsDesaturated() or false
    hooksecurefunc(icon, "SetVertexColor", function(_, r, g, b, a)
        if button.bbfRangeTinting then return end
        button.bbfIconR, button.bbfIconG, button.bbfIconB, button.bbfIconA = r, g, b, a
        if button.bbfRangeTinted then UpdateIconTint(button) end
    end)
    hooksecurefunc(icon, "SetDesaturated", function(_, desaturated)
        if button.bbfRangeTinting then return end
        button.bbfIconDesat = desaturated and true or false
        if button.bbfRangeTinted then UpdateIconTint(button) end
    end)
end

local function ApplyRange(button, outOfRange)
    if not button.bbfRangeTracked then
        button.bbfRangeTracked = true
        rangeButtons[#rangeButtons + 1] = button
    end
    button.bbfOutOfRange = outOfRange
    local overlay = button.bbfRangeOverlay
    if not rangeIconMode then
        overlay = GetRangeOverlay(button)
    end
    if overlay then
        SetOverlayColor(overlay)
        overlay:SetShown(rangeOn and outOfRange and not rangeIconMode or false)
    end
    if rangeIconMode or rangeDesat then
        HookIcon(button)
    end
    UpdateIconTint(button)
end

local function SyncActionRange(button)
    if not rangeOn or type(button.action) ~= "number" then return end
    ApplyRange(button, GetActionInRange(button.action) == false)
end

local function OnRangeIndicator(button, checksRange, inRange)
    if not rangeOn then return end
    ApplyRange(button, checksRange and not inRange and true or false)
end

function BBF.ActionBarRangeColor()
    local db = BetterBlizzFramesDB
    rangeOn = db.actionBarRangeColor and true or false
    rangeIconMode = not db.actionBarRangeUseOverlay
    rangeDesat = db.actionBarRangeDesaturate and true or false

    if rangeOn and not rangeHooked and ActionButton_UpdateRangeIndicator then
        rangeHooked = true
        hooksecurefunc("ActionButton_UpdateRangeIndicator", OnRangeIndicator)
        if EventRegistry and EventRegistry.RegisterCallback then
            EventRegistry:RegisterCallback("ActionButton.OnActionChanged", function(_, button)
                SyncActionRange(button)
            end, BBF)
        end
    end

    for _, overlay in ipairs(rangeOverlays) do
        SetOverlayColor(overlay)
        if not rangeOn then overlay:Hide() end
    end

    for _, button in ipairs(rangeButtons) do
        if rangeOn then
            ApplyRange(button, button.bbfOutOfRange)
        else
            UpdateIconTint(button)
        end
    end

    if rangeOn then
        ForEachButton(SyncActionRange)
    end
end

local cdTextOn, cdTextHooked, cdTextPending, cdFormatter, combatFrame
local cdTextButtons = {}

local function CanFormatCooldowns()
    return C_StringUtil and C_StringUtil.CreateNumericRuleFormatter and BBF.GetTimerFormatter and true or false
end
BBF.CanFormatCooldownText = CanFormatCooldowns

local function ShowCountdownNumbers()
    local getCVarBool = C_CVar and C_CVar.GetCVarBool or GetCVarBool
    return getCVarBool and getCVarBool("countdownForCooldowns") and true or false
end

local function GetCountdownText(cooldown)
    if cooldown.GetCountdownFontString then
        return cooldown:GetCountdownFontString()
    end
    local region = cooldown:GetRegions()
    if region and region.GetObjectType and region:GetObjectType() == "FontString" then
        return region
    end
end

local function SyncCountdownFont(button)
    local source = GetCountdownText(button.cooldown)
    local target = GetCountdownText(button.bbfCDText)
    if not source or not target then return end
    local font, size, flags = source:GetFont()
    if font then
        target:SetFont(font, size, flags)
    end
    target:SetScale(source:GetScale())
end

local function MirrorCooldown(button)
    local text = button.bbfCDText
    if not text then return end
    local action = button.action
    if not cdTextOn or type(action) ~= "number" then
        text:Clear()
        return
    end
    if C_ActionBar and C_ActionBar.GetActionCooldownDuration and C_ActionBar.GetActionCooldown and text.SetCooldownFromDurationObject then
        local info = C_ActionBar.GetActionCooldown(action)
        if info and info.isActive and not info.isOnGCD then
            text:SetCooldownFromDurationObject(C_ActionBar.GetActionCooldownDuration(action))
        else
            text:Clear()
        end
    elseif GetActionCooldown then
        local start, duration, enable, modRate = GetActionCooldown(action)
        if start and duration and duration > 1.5 and enable ~= 0 and enable ~= false then
            text:SetCooldown(start, duration, modRate or 1)
        else
            text:Clear()
        end
    end
end

local function EnsureCooldownText(button)
    if button.bbfCDText then return button.bbfCDText end
    local source = button.cooldown
    if not source or type(button.action) ~= "number" then return end
    local text = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    text:SetAllPoints(source)
    text:SetDrawSwipe(false)
    text:SetDrawEdge(false)
    text:SetDrawBling(false)
    text:SetFrameLevel(button:GetFrameLevel() + 1)
    button.bbfCDText = text
    cdTextButtons[#cdTextButtons + 1] = button
    return text
end

local function StyleButton(button)
    if not button.bbfCDText and InCombatLockdown() then
        cdTextPending = true
        return
    end
    local text = EnsureCooldownText(button)
    if not text then return end
    text:SetCountdownFormatter(cdFormatter)
    text:SetHideCountdownNumbers(not ShowCountdownNumbers())
    button.cooldown:SetHideCountdownNumbers(true)
    SyncCountdownFont(button)
    text:Show()
    MirrorCooldown(button)
end

local function UnstyleButton(button)
    local text = button.bbfCDText
    text:Clear()
    text:Hide()
    button.cooldown:SetHideCountdownNumbers(not ShowCountdownNumbers())
end

local function HookCooldownText()
    if cdTextHooked then return end
    cdTextHooked = true
    if ActionButton_UpdateCooldown then
        hooksecurefunc("ActionButton_UpdateCooldown", function(button)
            if cdTextOn then MirrorCooldown(button) end
        end)
    end
    if ActionButton_UpdateCooldownNumberHidden then
        hooksecurefunc("ActionButton_UpdateCooldownNumberHidden", function(button)
            if not cdTextOn or not button.bbfCDText then return end
            button.cooldown:SetHideCountdownNumbers(true)
            button.bbfCDText:SetHideCountdownNumbers(not ShowCountdownNumbers())
        end)
    end
end

function BBF.ActionBarCooldownTextColor()
    local db = BetterBlizzFramesDB
    local enabled = db.actionBarCDTextColor and CanFormatCooldowns()
    if not enabled and not cdTextOn then return end
    cdTextOn = enabled

    if not enabled then
        for _, button in ipairs(cdTextButtons) do
            UnstyleButton(button)
        end
        if combatFrame then combatFrame:UnregisterAllEvents() end
        return
    end

    HookCooldownText()
    cdFormatter = BBF.GetTimerFormatter(
        db.actionBarCDTextLowColor or { 1, 0.1, 0.1, 1 },
        db.actionBarCDTextLowThreshold or 6,
        db.actionBarCDTextMilliseconds,
        false,
        db.actionBarCDTextBaseColor or { 1, 1, 0.1, 1 },
        db.actionBarCDTextHighThreshold or 30,
        db.actionBarCDTextHighColor or { 1, 1, 1, 1 }
    )
    cdTextPending = nil
    ForEachButton(StyleButton)

    if cdTextPending then
        if not combatFrame then
            combatFrame = CreateFrame("Frame")
            combatFrame:SetScript("OnEvent", function(self)
                self:UnregisterAllEvents()
                BBF.ActionBarCooldownTextColor()
            end)
        end
        combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    elseif combatFrame then
        combatFrame:UnregisterAllEvents()
    end
end

local cdFontOn

local function ApplyCooldownFont(button)
    local cooldown = button.cooldown or button.Cooldown
    local text = cooldown and GetCountdownText(cooldown)
    if not text then return end
    local orig = text.bbfOrigFont
    if not orig then
        if not cdFontOn then return end
        local font, size, flags = text:GetFont()
        if not font then return end
        orig = { font, size, flags }
        text.bbfOrigFont = orig
    end
    if cdFontOn then
        local db = BetterBlizzFramesDB
        local LSM = LibStub("LibSharedMedia-3.0")
        local font = db.actionBarCDFont and LSM:Fetch(LSM.MediaType.FONT, db.actionBarCDFont) or orig[1]
        local size = tonumber(db.actionBarCDFontSize) or orig[2]
        local flags = db.actionBarCDFontOutline
        if flags == nil then flags = orig[3] end
        text:SetFont(font, size, flags)
    else
        text:SetFont(orig[1], orig[2], orig[3])
    end
end

function BBF.ActionBarCooldownFont()
    local enabled = BetterBlizzFramesDB.changeActionBarCDFont and true or false
    if not enabled and not cdFontOn then return end
    cdFontOn = enabled
    ForEachButton(ApplyCooldownFont)
    if cdTextOn then
        BBF.ActionBarCooldownTextColor()
    end
end
