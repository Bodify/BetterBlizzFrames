
local function FormatText(value)
    if value >= 1000000 then
        return string.format("%.1f M", value / 1000000)
    elseif value >= 100000 then
        return string.format("%d K", value / 1000)
    elseif value >= 1000 then
        return string.format("%d K", value / 1000)
    else
        return tostring(value)
    end
end

local function UpdateNumericText(bar, centerText)
    local value = bar:GetValue()
    local _, maxValue = bar:GetMinMaxValues()
    local formattedValue = FormatText(value)
    local formattedMaxValue = FormatText(maxValue)
    centerText:SetText(string.format("%s / %s", formattedValue, formattedMaxValue))
end

local function UpdateSingleText(bar, fontObj)
    local value = bar:GetValue()
    fontObj:SetText(FormatText(value))
end

function BBF.HookStatusBarText()
    if BBF.statusBarTextHookBBF then return end
    if not BetterBlizzFramesDB.formatStatusBarText then return end

    local statusTextSetting = C_CVar.GetCVar("statusTextDisplay")
    local singleDisplay = BetterBlizzFramesDB.singleValueStatusBarText

    local bars = {
        {PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar,
         PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBarText,
         PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.RightText},

        {PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar,
         PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.ManaBarText,
         PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.RightText},

        {TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar,
         TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBarText,
         TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.RightText},

        {TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar,
         TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.ManaBarText,
         TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText},

        {FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar,
         FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBarText,
         FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.RightText},

        {FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar,
         FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.ManaBarText,
         FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText}
    }

    for _, bar in ipairs(bars) do
        local hpBar, centerText, rightText = bar[1], bar[2], bar[3]

        if singleDisplay and statusTextSetting == "NUMERIC" then
            -- Apply single value display to center text
            hooksecurefunc(hpBar, "UpdateTextStringWithValues", function()
                UpdateSingleText(hpBar, centerText)
            end)
        elseif statusTextSetting == "BOTH" then
            -- Apply to right text only
            hooksecurefunc(hpBar, "UpdateTextStringWithValues", function()
                UpdateSingleText(hpBar, rightText)
            end)

        elseif statusTextSetting == "NUMERIC" then
            -- Display both current and max values on the center text
            hooksecurefunc(hpBar, "UpdateTextStringWithValues", function()
                UpdateNumericText(hpBar, centerText)
            end)
        end
    end
    BBF.statusBarTextHookBBF = true
end
