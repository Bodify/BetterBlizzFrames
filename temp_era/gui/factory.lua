local L = BBF.L

local function ShouldFireCallback()
    return not BetterBlizzFramesDB.wasOnLoadingScreen and BetterBlizzFrames.guiLoaded
end

---------------------------------------------------------------------------
-- Slider
---------------------------------------------------------------------------
local function FormatValue(value)
    return value % 1 == 0 and tostring(math.floor(value)) or string.format("%.2f", value)
end

local function ExtendRange(slider, value, min, max, positional)
    if value >= min and value <= max then return end
    if positional then
        slider:SetMinMaxValues(math.min(value - 30, min), math.max(value + 30, max))
    else
        slider:SetMinMaxValues(math.max(value - 2, 0.1), math.max(value + 2, max))
    end
end

function BBF.Slider(parent, key, label, min, max, step, callback)
    local positional = key:match("XPos$") or key:match("YPos$")

    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider.Text:SetFontObject(GameFontHighlightSmall)
    slider.Text:SetTextColor(1, 0.81, 0, 1)
    slider.Low:Hide()
    slider.High:Hide()

    -- Metadata for reset
    slider.bbfKey = key
    slider.bbfDefault = BBF.defaultSettings and BBF.defaultSettings[key]
    slider.bbfMinDefault = min
    slider.bbfMaxDefault = max

    local function UpdateText(value)
        slider.Text:SetText(label .. ": " .. FormatValue(value))
    end

    -- OnValueChanged — DB write + callback
    slider:SetScript("OnValueChanged", function(self, value)
        if BetterBlizzFramesDB.wasOnLoadingScreen then return end
        BetterBlizzFramesDB[key] = value
        UpdateText(value)
        if callback and ShouldFireCallback() then callback(value) end
    end)

    -- Init
    local function Init()
        if not BBF.variablesLoaded then
            C_Timer.After(0.1, Init)
            return
        end
        local val = tonumber(BetterBlizzFramesDB[key])
        if val then
            ExtendRange(slider, val, min, max, positional)
            slider:SetValue(val)
            UpdateText(val)
        end
    end
    
    Init()

    -- Mousewheel
    slider:SetScript("OnMouseWheel", function(self, delta)
        if IsShiftKeyDown() then
            self:SetValue(self:GetValue() + delta * step)
        end
    end)

    -- Right-click editbox
    local editBox = CreateFrame("EditBox", nil, slider, "InputBoxTemplate")
    editBox:SetAutoFocus(false)
    editBox:SetSize(50, 20)
    editBox:SetPoint("CENTER")
    editBox:SetFrameStrata("DIALOG")
    editBox:SetFontObject(GameFontHighlightSmall)
    editBox:Hide()

    editBox:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then
            if not positional and val <= 0 then val = 0.1 end
            slider:SetMinMaxValues(min, max)
            ExtendRange(slider, val, min, max, positional)
            slider:SetValue(val)
        end
        self:Hide()
    end)

    editBox:SetScript("OnEscapePressed", function(self) self:Hide() end)

    slider:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            editBox:SetText(FormatValue(self:GetValue()))
            editBox:Show()
            editBox:SetFocus()
        end
    end)

    return slider
end

---------------------------------------------------------------------------
-- Checkbox
---------------------------------------------------------------------------
function BBF.Checkbox(parent, key, label, callback)
    local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    cb.Text:SetText(label)
    cb.bbfKey = key
    cb.bbfDefault = BBF.defaultSettings and BBF.defaultSettings[key]

    local function InitAndApply(value)
        if not BetterBlizzFramesDB.hasCheckedUi then
            C_Timer.After(0.1, function() InitAndApply(value) end)
            return
        end
        BetterBlizzFramesDB[key] = value
        cb:SetChecked(value)

        if callback and ShouldFireCallback() then
            callback(key, value)
        end
    end

    InitAndApply(BetterBlizzFramesDB[key])
    cb:HookScript("OnClick", function() InitAndApply(cb:GetChecked()) end)

    return cb
end

---------------------------------------------------------------------------
-- Tooltip
---------------------------------------------------------------------------
function BBF.Tooltip(widget, title, mainText, subText, anchor, cvarName, category)
    widget.tooltipTitle = title
    widget.tooltipMainText = mainText
    widget.tooltipSubText = subText
    widget.tooltipCVarName = cvarName

    widget:SetScript("OnEnter", function(self)
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self, anchor or "ANCHOR_RIGHT")

        if mainText then
            GameTooltip:AddLine(title)
            GameTooltip:AddLine(mainText, 1, 1, 1, true)
            if subText then
                GameTooltip:AddLine("____________________________", 0.8, 0.8, 0.8, true)
                GameTooltip:AddLine(subText, 0.8, 0.8, 0.8, true)
            end
            if cvarName then
                GameTooltip:AddDoubleLine(L["Tooltip_Changes_CVar"], cvarName, 0.2, 1, 0.6, 0.2, 1, 0.6)
            end
            if category then
                GameTooltip:AddLine("")
                GameTooltip:AddLine("|A:shop-games-magnifyingglass:17:17|a " .. L["Tooltip_Setting_Located_In"] .. category .. L["Tooltip_Section"], 0.4, 0.8, 1, true)
            end
        else
            GameTooltip:SetText(title)
        end
        GameTooltip:Show()
    end)

    widget:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

---------------------------------------------------------------------------
-- BorderedFrame
---------------------------------------------------------------------------
function BBF.BorderedFrame(parent, width, height)
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    f:SetBackdrop({
        bgFile = "Interface\\FriendsFrame\\UI-Toast-Background",
        edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
        tile = true, tileEdge = true, tileSize = 10, edgeSize = 10,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
    })
    f:SetBackdropColor(1, 1, 1, 0.4)
    f:SetFrameLevel(1)
    f:SetSize(width, height)
    return f
end
