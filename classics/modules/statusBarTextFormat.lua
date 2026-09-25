
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
            local member = _G["PartyMemberFrame"..i]
            if member then
                local hpBar = member.healthbar
                local manaBar = member.ManaBar
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
local centeredBars
local centeredBarsApplying = false

local function AddCenteredBar(list, bar)
    if not bar then return end
    local center = bar.TextString
    local right = bar.RightText
    if not center or not right then return end
    list[#list + 1] = { bar = bar, center = center, right = right, left = bar.LeftText }
end

local function AddCenteredUnitFrame(list, frame)
    if not frame then return end
    AddCenteredBar(list, frame.healthbar or frame.HealthBar)
    AddCenteredBar(list, frame.manabar or frame.ManaBar or frame.PowerBar)
end

local function GetCenteredBars()
    if centeredBars then return centeredBars end

    local list = {}
    AddCenteredUnitFrame(list, PlayerFrame)
    AddCenteredBar(list, PlayerFrameAlternateManaBar)
    AddCenteredUnitFrame(list, PetFrame)
    AddCenteredUnitFrame(list, TargetFrame)
    AddCenteredUnitFrame(list, FocusFrame)
    AddCenteredUnitFrame(list, TargetFrameToT)
    AddCenteredUnitFrame(list, FocusFrameToT)

    for i = 1, 4 do
        AddCenteredUnitFrame(list, _G["PartyMemberFrame" .. i])
    end

    centeredBars = list
    return centeredBars
end

local function ApplyCenteredBarPoint(entry)
    centeredBarsApplying = true
    entry.right:ClearAllPoints()
    entry.right:SetPoint("CENTER", entry.center, "CENTER", 0, 0)
    entry.right:SetJustifyH("CENTER")
    entry.right:SetJustifyV("MIDDLE")
    centeredBarsApplying = false
end

local function HideCenteredBarPercent(entry)
    if not entry.left then return end
    centeredBarsApplying = true
    entry.left:SetAlpha(0)
    centeredBarsApplying = false
    entry.left:Hide()
end

local function SaveCenteredBarState(entry)
    if entry.savedPoints then return end
    local points = {}
    for i = 1, entry.right:GetNumPoints() do
        points[i] = { entry.right:GetPoint(i) }
    end
    entry.savedPoints = points
    entry.savedJustifyH = entry.right:GetJustifyH()
    entry.savedJustifyV = entry.right:GetJustifyV()
    entry.savedLeftAlpha = entry.left and entry.left:GetAlpha() or nil
end

local function RestoreCenteredBarState(entry)
    if not entry.savedPoints then return end
    centeredBarsApplying = true
    entry.right:ClearAllPoints()
    for i = 1, #entry.savedPoints do
        entry.right:SetPoint(unpack(entry.savedPoints[i], 1, 5))
    end
    if entry.savedJustifyH then entry.right:SetJustifyH(entry.savedJustifyH) end
    if entry.savedJustifyV then entry.right:SetJustifyV(entry.savedJustifyV) end
    if entry.left then entry.left:SetAlpha(entry.savedLeftAlpha or 1) end
    centeredBarsApplying = false
    entry.savedPoints = nil
    entry.savedJustifyH = nil
    entry.savedJustifyV = nil
    entry.savedLeftAlpha = nil
end

local function HookCenteredBar(entry)
    if entry.hooked then return end
    entry.hooked = true
    hooksecurefunc(entry.right, "SetPoint", function()
        if centeredBarsApplying then return end
        if not BetterBlizzFramesDB.centerCurrentValueOnBars then return end
        ApplyCenteredBarPoint(entry)
    end)
    if entry.left then
        hooksecurefunc(entry.left, "SetAlpha", function(_, alpha)
            if centeredBarsApplying then return end
            if not BetterBlizzFramesDB.centerCurrentValueOnBars then return end
            if alpha ~= 0 then HideCenteredBarPercent(entry) end
        end)
    end
end

local function UpdateCenteredBarCVars(enabled)
    local db = BetterBlizzFramesDB
    if enabled then
        if db.centerCurrentValuePrevStatusTextDisplay == nil then
            db.centerCurrentValuePrevStatusTextDisplay = C_CVar.GetCVar("statusTextDisplay") or "NONE"
        end
        if C_CVar.GetCVar("statusText") ~= "1" then
            C_CVar.SetCVar("statusText", "1")
        end
        if C_CVar.GetCVar("statusTextDisplay") ~= "BOTH" then
            C_CVar.SetCVar("statusTextDisplay", "BOTH")
        end
    else
        local previous = db.centerCurrentValuePrevStatusTextDisplay
        if previous then
            if C_CVar.GetCVar("statusTextDisplay") ~= previous then
                C_CVar.SetCVar("statusTextDisplay", previous)
            end
            db.centerCurrentValuePrevStatusTextDisplay = nil
        end
    end
end

function BBF.RefreshCenteredBarText()
    if C_CVar.GetCVar("statusText") ~= "1" then return end
    C_CVar.SetCVar("statusText", "0")
    C_CVar.SetCVar("statusText", "1")
end

function BBF.CenterCurrentValueOnBars()
    local enabled = BetterBlizzFramesDB.centerCurrentValueOnBars
    if not enabled and not BBF.centeredBarsApplied then
        UpdateCenteredBarCVars(false)
        return
    end
    BBF.centeredBarsApplied = enabled and true or nil

    UpdateCenteredBarCVars(enabled)

    for _, entry in ipairs(GetCenteredBars()) do
        if enabled then
            SaveCenteredBarState(entry)
            HideCenteredBarPercent(entry)
            ApplyCenteredBarPoint(entry)
            HookCenteredBar(entry)
        else
            RestoreCenteredBarState(entry)
        end
    end
end
