function BBF.KeyDoublePress()
    if not BetterBlizzFramesDB.enableKeyDoublePress or BBF.hookedKeyDoublePress then return end

    local barPrefixes = {
        "ActionButton",
        "MultiBarBottomLeftButton",
        "MultiBarBottomRightButton",
        "MultiBarRightButton",
        "MultiBarLeftButton",
        "MultiBar5Button",
        "MultiBar6Button",
    }

    local buttonNames = {}
    for _, prefix in ipairs(barPrefixes) do
        for i = 1, 12 do
            buttonNames[#buttonNames + 1] = prefix .. i
        end
    end

    local bindingMap = {
        ActionButton = "ACTIONBUTTON",
        MultiBarBottomLeftButton = "MULTIACTIONBAR1BUTTON",
        MultiBarBottomRightButton = "MULTIACTIONBAR2BUTTON",
        MultiBarRightButton = "MULTIACTIONBAR3BUTTON",
        MultiBarLeftButton = "MULTIACTIONBAR4BUTTON",
        MultiBar5Button = "MULTIACTIONBAR5BUTTON",
        MultiBar6Button = "MULTIACTIONBAR6BUTTON",
    }

    local function WalmartAHK(buttonName)
        local btn = _G[buttonName]
        if not btn then return end

        local prefix, id = buttonName:match("^(.-)(%d+)$")
        local bindingPrefix = bindingMap[prefix]
        if not bindingPrefix or not id then return end

        local clickButton = bindingPrefix .. id
        local key1, key2 = GetBindingKey(clickButton)

        for _, key in pairs({key1, key2}) do
            if key then
                local wahkName = "WAHK_" .. key .. "_" .. buttonName
                local wahk = _G[wahkName] or CreateFrame("Button", wahkName, nil, "SecureActionButtonTemplate")

                wahk:RegisterForClicks("AnyDown", "AnyUp")
                wahk:SetAttribute("type", "click")
                wahk:SetAttribute("pressAndHoldAction", "1")
                wahk:SetAttribute("typerelease", "click")
                wahk:SetAttribute("clickbutton", btn)

                SetOverrideBindingClick(wahk, true, key, wahkName)

                wahk:SetScript("OnMouseDown", function()
                    btn:SetButtonState("PUSHED")
                end)
                wahk:SetScript("OnMouseUp", function()
                    btn:SetButtonState("NORMAL")
                end)
            end
        end
    end

    for _, name in ipairs(buttonNames) do
        WalmartAHK(name)
    end

    BBF.hookedKeyDoublePress = true
end