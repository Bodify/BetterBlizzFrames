
local function FormatText(value)
    if value >= 1000000000 then
        return string.format("%.2f B", value / 1000000000)
    elseif value >= 1000000 then
        return string.format("%.1f M", value / 1000000)
    elseif value >= 100000 then
        return string.format("%d K", value / 1000)
    else
        return tostring(value)
    end
end

local function UpdateNumericText(bar, centerText)
    if not centerText then return end
    local value = bar:GetValue()
    local _, maxValue = bar:GetMinMaxValues()
    local formattedValue = FormatText(value)
    local formattedMaxValue = FormatText(maxValue)
    if formattedValue == "0" then
        centerText:SetText("")
        return
    end
    centerText:SetText(string.format("%s / %s", formattedValue, formattedMaxValue))
end

local function UpdateSingleText(bar, fontObj)
    if not fontObj then return end
    local value = bar:GetValue()
    if value == 0 then
        fontObj:SetText("")
        return
    end
    fontObj:SetText(FormatText(value))
end

function BBF.HookStatusBarText()
    if BBF.statusBarTextHookBBF then return end
    if not BetterBlizzFramesDB.formatStatusBarText then return end

    local statusTextSetting = C_CVar.GetCVar("statusTextDisplay")
    local singleDisplay = BetterBlizzFramesDB.singleValueStatusBarText

    local pMain = PlayerFrame
    local tMain = TargetFrame
    local fMain = FocusFrame

    local bars = {}

    local function AddBar(bar, centerText, rightText)
        table.insert(bars, {
            bar = bar,
            centerText = centerText,
            rightText = rightText
        })
    end

    -- Player and pet frames
    AddBar(pMain.healthbar,
           pMain.healthbar.TextString,
           pMain.healthbar.RightText)

    AddBar(pMain.ManaBar,
           pMain.ManaBar.TextString,
           pMain.ManaBar.RightText)

    if PlayerFrameAlternateManaBar then
        AddBar(PlayerFrameAlternateManaBar,
            PlayerFrameAlternateManaBar.TextString,
            PlayerFrameAlternateManaBar.TextString)
    end

    AddBar(PetFrame.healthbar,
           PetFrame.healthbar.TextString,
           PetFrame.healthbar.RightText)

    AddBar(PetFrame.manabar,
           PetFrame.manabar.TextString,
           PetFrame.manabar.RightText)

    -- Target and focus frames
    AddBar(tMain.healthbar,
           tMain.healthbar.TextString,
           tMain.healthbar.RightText)

    AddBar(tMain.PowerBar,
           tMain.PowerBar.TextString,
           tMain.PowerBar.RightText)

    AddBar(fMain.healthbar,
           fMain.healthbar.TextString,
           fMain.healthbar.RightText)

    AddBar(fMain.manabar,
           fMain.manabar.TextString,
           fMain.manabar.RightText)

    -- Default party frames (non-raid-style)
    if not GetCVarBool("useCompactPartyFrames") then
        for i = 1, 4 do
            local member = (PartyFrame and PartyFrame["MemberFrame"..i]) or _G["PartyMemberFrame"..i]
            if member then
                local hpBar = member.HealthBar or member.healthbar
                local manaBar = member.ManaBar or member.manabar
                if hpBar and hpBar.TextString and hpBar.RightText then
                    AddBar(hpBar, hpBar.TextString, hpBar.RightText)
                end
                if manaBar and manaBar.TextString and manaBar.RightText then
                    AddBar(manaBar, manaBar.TextString, manaBar.RightText)
                end
            end
        end
    end

    -- Hook logic
    for _, info in ipairs(bars) do
        local bar, centerText, rightText = info.bar, info.centerText, info.rightText

        if singleDisplay and statusTextSetting == "NUMERIC" then
            hooksecurefunc(bar, "UpdateTextStringWithValues", function()
                UpdateSingleText(bar, centerText)
            end)
            UpdateSingleText(bar, centerText)
        elseif statusTextSetting == "BOTH" then
            hooksecurefunc(bar, "UpdateTextStringWithValues", function()
                UpdateSingleText(bar, rightText)
            end)
            UpdateSingleText(bar, rightText)
        elseif statusTextSetting == "NUMERIC" then
            hooksecurefunc(bar, "UpdateTextStringWithValues", function()
                UpdateNumericText(bar, centerText)
            end)
            UpdateNumericText(bar, centerText)
        elseif statusTextSetting == "NONE" then
            hooksecurefunc(bar, "UpdateTextStringWithValues", function()
                UpdateNumericText(bar, centerText)
            end)
            UpdateNumericText(bar, centerText)
        end
    end

    BBF.statusBarTextHookBBF = true
end

-------------------------------------------------
-- Party frame HP/Mana text (% left, value right)
-- Text must live on/above PartyMemberOverlay:
-- anything parented to the member frame itself
-- renders underneath that overlay child frame.
-------------------------------------------------

local function GetDefaultPartyMemberFrame(i)
    if PartyFrame then
        local member = PartyFrame["MemberFrame"..i]
        if member then return member end
        if PartyFrame.PartyMemberFramePool then
            local index = 0
            for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
                index = index + 1
                if index == i then
                    return frame
                end
            end
        end
    end
    return _G["PartyMemberFrame"..i]
end

local function IsDefaultPartyFrameVisible()
    for i = 1, 4 do
        local member = GetDefaultPartyMemberFrame(i)
        if member and member:IsShown() then
            return true
        end
    end
    return false
end

local function GetPartyUnit(i, member)
    if member and member.unit and member.unit ~= "" then
        return member.unit
    end
    return "party"..i
end

local function GetBarPair(member)
    return member.HealthBar or member.healthbar or _G[(member:GetName() or "").."HealthBar"],
           member.ManaBar or member.manabar or _G[(member:GetName() or "").."ManaBar"]
end

local function HideNativeStatusText(bar)
    if not bar then return end
    for _, key in ipairs({
        "TextString", "LeftText", "RightText", "CenterText", "ManaBarText",
        "DFTextString", "DFLeftText", "DFRightText",
        "DFHealthBarText", "DFHealthBarTextLeft", "DFHealthBarTextRight",
        "DFManaBarText", "DFManaBarTextLeft", "DFManaBarTextRight",
    }) do
        local fs = bar[key]
        if fs then
            fs:SetText("")
            fs:Hide()
        end
    end
end

local function GetPartyStatusFont(isMana)
    local db = BetterBlizzFramesDB
    local font = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
    local size = isMana and 9 or 10
    local outline = "OUTLINE"

    if db.changePartyFrameFont then
        local LSM = BBF.LSM or (LibStub and LibStub("LibSharedMedia-3.0", true))
        if LSM and db.partyFrameFont then
            font = LSM:Fetch(LSM.MediaType.FONT, db.partyFrameFont) or font
        end
        size = tonumber(db.partyFrameStatusFontSize) or size
        if isMana then
            size = math.max(8, size - 1)
        end
        outline = db.partyFrameFontOutline or outline
    elseif db.changeUnitFrameValueFont then
        local LSM = BBF.LSM or (LibStub and LibStub("LibSharedMedia-3.0", true))
        if LSM and db.unitFrameValueFont then
            font = LSM:Fetch(LSM.MediaType.FONT, db.unitFrameValueFont) or font
        end
        size = tonumber(db.unitFrameValueFontSize) or size
        if isMana then
            size = math.max(8, size - 1)
        end
        outline = db.unitFrameValueFontOutline or outline
    end

    return font, size, outline
end

local function GetTextParent(member, bar)
    -- PartyMemberOverlay draws above the member frame; text on the member
    -- itself is hidden behind it. Prefer a high-level holder on the overlay.
    local overlay = member and member.PartyMemberOverlay
    local anchorParent = overlay or member or bar
    if not member.bbfStatusTextFrame then
        local holder = CreateFrame("Frame", nil, anchorParent)
        holder:SetAllPoints(anchorParent)
        holder:SetFrameLevel((anchorParent:GetFrameLevel() or 0) + 25)
        member.bbfStatusTextFrame = holder
    end
    return member.bbfStatusTextFrame
end

local function EnsureBarTexts(member, bar, isMana)
    if not member or not bar then return end
    local textParent = GetTextParent(member, bar)

    if not bar.bbfPartyLeftText then
        local left = textParent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
        left:SetDrawLayer("OVERLAY", 7)
        left:SetJustifyH("LEFT")
        bar.bbfPartyLeftText = left
    end
    if not bar.bbfPartyRightText then
        local right = textParent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
        right:SetDrawLayer("OVERLAY", 7)
        right:SetJustifyH("RIGHT")
        bar.bbfPartyRightText = right
    end

    local font, size, outline = GetPartyStatusFont(isMana)
    bar.bbfPartyLeftText:SetFont(font, size, outline)
    bar.bbfPartyRightText:SetFont(font, size, outline)

    local yOff = 0.5
    bar.bbfPartyLeftText:ClearAllPoints()
    bar.bbfPartyLeftText:SetPoint("LEFT", bar, "LEFT", 2, yOff)
    bar.bbfPartyRightText:ClearAllPoints()
    bar.bbfPartyRightText:SetPoint("RIGHT", bar, "RIGHT", -2, yOff)
    bar.bbfPartyLeftText:SetAlpha(1)
    bar.bbfPartyRightText:SetAlpha(1)

    if BetterBlizzFramesDB.unitFrameValueFontColor and BetterBlizzFramesDB.unitFrameValueFontColorRGB then
        local c = BetterBlizzFramesDB.unitFrameValueFontColorRGB
        bar.bbfPartyLeftText:SetTextColor(c[1], c[2], c[3], c[4] or 1)
        bar.bbfPartyRightText:SetTextColor(c[1], c[2], c[3], c[4] or 1)
    else
        bar.bbfPartyLeftText:SetTextColor(1, 1, 1, 1)
        bar.bbfPartyRightText:SetTextColor(1, 1, 1, 1)
    end
end

local function SetBarTextVisible(bar, visible)
    if not bar then return end
    if bar.bbfPartyLeftText then
        if visible then
            bar.bbfPartyLeftText:Show()
        else
            bar.bbfPartyLeftText:SetText("")
            bar.bbfPartyLeftText:Hide()
        end
    end
    if bar.bbfPartyRightText then
        if visible then
            bar.bbfPartyRightText:Show()
        else
            bar.bbfPartyRightText:SetText("")
            bar.bbfPartyRightText:Hide()
        end
    end
end

local function UpdateHealthText(bar, unit)
    if not bar or not bar.bbfPartyLeftText then return end
    if not unit or not UnitExists(unit) then
        bar.bbfPartyLeftText:SetText("")
        bar.bbfPartyRightText:SetText("")
        return
    end

    HideNativeStatusText(bar)

    local cur = UnitHealth(unit)
    local max = UnitHealthMax(unit)
    if UnitIsDeadOrGhost(unit) then
        bar.bbfPartyLeftText:SetText("0%")
        bar.bbfPartyRightText:SetText("0")
        bar.bbfPartyLeftText:Show()
        bar.bbfPartyRightText:Show()
        return
    end
    if not max or max <= 0 then
        bar.bbfPartyLeftText:SetText("")
        bar.bbfPartyRightText:SetText("")
        return
    end

    local pct = math.floor((cur / max) * 100 + 0.5)
    bar.bbfPartyLeftText:SetText(pct .. "%")
    bar.bbfPartyRightText:SetText(FormatText(cur))
    bar.bbfPartyLeftText:Show()
    bar.bbfPartyRightText:Show()
end

local function UpdatePowerText(bar, unit)
    if not bar or not bar.bbfPartyLeftText then return end
    if not unit or not UnitExists(unit) then
        bar.bbfPartyLeftText:SetText("")
        bar.bbfPartyRightText:SetText("")
        return
    end

    HideNativeStatusText(bar)

    if UnitIsDeadOrGhost(unit) then
        bar.bbfPartyLeftText:SetText("")
        bar.bbfPartyRightText:SetText("")
        return
    end

    local powerType = UnitPowerType(unit)
    local cur = UnitPower(unit, powerType)
    local max = UnitPowerMax(unit, powerType)
    if not max or max <= 0 then
        bar.bbfPartyLeftText:SetText("")
        bar.bbfPartyRightText:SetText("")
        return
    end

    local pct = math.floor((cur / max) * 100 + 0.5)
    bar.bbfPartyLeftText:SetText(pct .. "%")
    bar.bbfPartyRightText:SetText(FormatText(cur))
    bar.bbfPartyLeftText:Show()
    bar.bbfPartyRightText:Show()
end

local function HookBarUpdates(member, bar, isMana)
    if not bar or bar.bbfPartyTextHooked then return end
    bar.bbfPartyTextHooked = true
    bar:HookScript("OnValueChanged", function()
        if not BetterBlizzFramesDB.partyFrameStatusText then return end
        if not IsDefaultPartyFrameVisible() then return end
        local unit = member.unit
        if not unit or unit == "" then return end
        if isMana then
            UpdatePowerText(bar, unit)
        else
            UpdateHealthText(bar, unit)
        end
    end)
end

local function UpdatePartyMemberStatusText(i)
    local member = GetDefaultPartyMemberFrame(i)
    if not member then return end

    local hpBar, manaBar = GetBarPair(member)
    local unit = GetPartyUnit(i, member)
    local enabled = BetterBlizzFramesDB.partyFrameStatusText and IsDefaultPartyFrameVisible()

    if not enabled then
        SetBarTextVisible(hpBar, false)
        SetBarTextVisible(manaBar, false)
        return
    end

    if not member:IsShown() then
        SetBarTextVisible(hpBar, false)
        SetBarTextVisible(manaBar, false)
        return
    end

    EnsureBarTexts(member, hpBar, false)
    EnsureBarTexts(member, manaBar, true)
    HookBarUpdates(member, hpBar, false)
    HookBarUpdates(member, manaBar, true)
    SetBarTextVisible(hpBar, true)
    SetBarTextVisible(manaBar, true)
    UpdateHealthText(hpBar, unit)
    UpdatePowerText(manaBar, unit)
end

function BBF.UpdatePartyFrameStatusText()
    for i = 1, 4 do
        UpdatePartyMemberStatusText(i)
    end
end

function BBF.PartyFrameStatusText()
    if BBF.partyFrameStatusTextHooked then
        BBF.UpdatePartyFrameStatusText()
        return
    end

    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("UNIT_HEALTH")
    eventFrame:RegisterEvent("UNIT_MAXHEALTH")
    eventFrame:RegisterEvent("UNIT_POWER_UPDATE")
    eventFrame:RegisterEvent("UNIT_MAXPOWER")
    eventFrame:RegisterEvent("UNIT_DISPLAYPOWER")
    eventFrame:RegisterEvent("UNIT_CONNECTION")
    eventFrame:SetScript("OnEvent", function(_, event, unit)
        if not BetterBlizzFramesDB.partyFrameStatusText then return end

        if event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" then
            BBF.UpdatePartyFrameStatusText()
            return
        end

        if not unit or not tostring(unit):match("^party%d$") then return end
        local index = tonumber(tostring(unit):match("%d+"))
        if index then
            UpdatePartyMemberStatusText(index)
        end
    end)

    BBF.partyFrameStatusTextHooked = true
    BBF.UpdatePartyFrameStatusText()
end
