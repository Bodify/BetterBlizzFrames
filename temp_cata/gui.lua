BetterBlizzFrames = nil
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")
--local anchorPoints = {"CENTER", "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}
local anchorPoints = {"CENTER", "TOP", "LEFT", "RIGHT", "BOTTOM"}
local anchorPoints2 = {"TOP", "LEFT", "RIGHT", "BOTTOM"}
local pixelsBetweenBoxes = 6
local pixelsOnFirstBox = -1
local sliderUnderBoxX = 12
local sliderUnderBoxY = -10
local sliderUnderBox = "12, -10"

local LibDeflate = LibStub("LibDeflate")
local LibSerialize = LibStub("LibSerialize")

BBF.partyPointerTargetIconReplacement = "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-QuestPoiImportant-QuestBang.tga"
BBF.squareGreenGlow = "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\newplayertutorial-drag-slotgreen.tga"
BBF.squareBlueGlow = "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\newplayertutorial-drag-slotblue.tga"
BBF.PandemicIcon = "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\ElementalStorm-Boss-Air.tga"
BBF.ImportantIcon = "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-QuestPoiImportant-QuestBang.tga"
BBF.OwnAuraIcon = "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon.tga"
BBF.EnlargedIcon = "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-Minimap-Zoom-In.tga"
BBF.CompactIcon = "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-Minimap-Zoom-Out.tga"


-- local function ExportProfile(profileTable, dataType)
--     -- Include a dataType in the table being serialized
--     local exportTable = {
--         dataType = dataType,
--         data = profileTable
--     }
--     local serialized = LibSerialize:Serialize(exportTable)
--     local compressed = LibDeflate:CompressDeflate(serialized)
--     local encoded = LibDeflate:EncodeForPrint(compressed)
--     return "!BBFCata" .. encoded .. "!BBFCata"
-- end

-- local function ImportProfile(encodedString, expectedDataType)
--     if encodedString:sub(1, 8) == "!BBFCata" and encodedString:sub(-8) == "!BBFCata" then
--         encodedString = encodedString:sub(9, -9) -- Remove both prefix and suffix
--     else
--         return nil, "Invalid format: Prefix or suffix not found."
--     end

--     local compressed = LibDeflate:DecodeForPrint(encodedString)
--     local serialized, decompressMsg = LibDeflate:DecompressDeflate(compressed)
--     if not serialized then
--         return nil, "Error decompressing: " .. tostring(decompressMsg)
--     end

--     local success, importTable = LibSerialize:Deserialize(serialized)
--     if not success or importTable.dataType ~= expectedDataType then
--         return nil, "Error deserializing or data type mismatch"
--     end

--     return importTable.data, nil
-- end

local function ExportProfile(profileTable, dataType)
    -- Include a dataType in the table being serialized
    local exportTable = {
        dataType = dataType,
        data = profileTable
    }
    local serialized = LibSerialize:Serialize(exportTable)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForPrint(compressed)
    return "!BBF" .. encoded .. "!BBF"
end

local function ImportProfile(encodedString, expectedDataType)
    if encodedString:sub(1, 4) == "!BBF" and encodedString:sub(-4) == "!BBF" then
        encodedString = encodedString:sub(5, -5) -- Remove both prefix and suffix
    else
        return nil, "Invalid format: Prefix or suffix not found."
    end

    local compressed = LibDeflate:DecodeForPrint(encodedString)
    local serialized, decompressMsg = LibDeflate:DecompressDeflate(compressed)
    if not serialized then
        return nil, "Error decompressing: " .. tostring(decompressMsg)
    end

    local success, importTable = LibSerialize:Deserialize(serialized)
    if not success or importTable.dataType ~= expectedDataType then
        return nil, "Error deserializing or data type mismatch"
    end

    if importTable.dataType == "fullProfile" then
        if importTable.data[expectedDataType] then
            return importTable.data[expectedDataType], nil
        else
            return importTable.data, nil
        end
    elseif importTable.dataType ~= expectedDataType then
        return nil, "Data type mismatch"
    end

    return importTable.data, nil
end


local function deepMergeTables(destination, source)
    for k, v in pairs(source) do
        if type(v) == "table" then
            if not destination[k] then
                destination[k] = {}
            end
            deepMergeTables(destination[k], v) -- Recursive merge for nested tables
        else
            destination[k] = v
        end
    end
end

StaticPopupDialogs["BBF_CONFIRM_RELOAD"] = {
    text = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: \n\nThis requires a reload. Reload now?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        BetterBlizzFramesDB.reopenOptions = true
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["BBF_TOT_MESSAGE"] = {
    text = "The default Blizzard code to \"wrap auras\" around the target of target frame is stupid.\n\nThe \"Target of Target\" frames have been moved slightly to make more space for auras.\nYou can change this at any time.\n\nDo you want to keep this? (pick yes)",
    button1 = "Yes",
    button2 = "No",
    OnCancel = function()
        BetterBlizzFramesDB.targetToTXPos = 0
        BBF.targetToTXPos:SetValue(0)
        BetterBlizzFramesDB.focusToTXPos = 0
        BBF.focusToTXPos:SetValue(0)
        BetterBlizzFramesDB.targetToTYPos = 0
        BBF.targetToTYPos:SetValue(0)
        BetterBlizzFramesDB.focusToTYPos = 0
        BBF.focusToTYPos:SetValue(0)
        BBF.MoveToTFrames()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["BBF_CONFIRM_NAHJ_PROFILE"] = {
    text = "This action will modify all settings to Nahj's profile and reload the UI.\n\nYour existing blacklists and whitelists will be retained, with Nahj's additional entries.\n\nAre you sure you want to continue?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        BBF.NahjProfile()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["BBF_CONFIRM_MAGNUSZ_PROFILE"] = {
    text = "This action will modify all settings to Magnusz's profile and reload the UI.\n\nYour existing blacklists and whitelists will be retained, with Magnusz's additional entries.\n\nAre you sure you want to continue?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        BBF.MagnuszProfile()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}
------------------------------------------------------------
-- GUI Creation Functions
------------------------------------------------------------

local function GenerateTextureString(texturePath, sizeX, sizeY, left, right, top, bottom, originalWidth, originalHeight)
    if left and right and top and bottom and originalWidth and originalHeight then
        -- If texture coordinates are provided
        local texCoordString = "|T"..texturePath..":"..sizeX..":"..sizeY..":0:0:"..originalWidth..":"..originalHeight..":"..(left*originalWidth)..":"..(right*originalWidth)..":"..(top*originalHeight)..":"..(bottom*originalHeight).."|t"
        return texCoordString
    else
        -- If no texture coordinates are provided
        local texCoordString = "|T"..texturePath..":"..sizeX..":"..sizeY.."|t"
        return texCoordString
    end
end

local function CheckAndToggleCheckboxes(frame, alpha)
    for i = 1, frame:GetNumChildren() do
        local child = select(i, frame:GetChildren())
        if child and (child:GetObjectType() == "CheckButton" or child:GetObjectType() == "Slider" or child:GetObjectType() == "Button") then
            if frame:GetChecked() then
                child:Enable()
                child:SetAlpha(1)
            else
                child:Disable()
                child:SetAlpha(alpha or 0.5)
            end
        end

        -- Check if the child has children and if it's a CheckButton or Slider
        for j = 1, child:GetNumChildren() do
            local childOfChild = select(j, child:GetChildren())
            if childOfChild and (childOfChild:GetObjectType() == "CheckButton" or childOfChild:GetObjectType() == "Slider" or childOfChild:GetObjectType() == "Button") then
                if child.GetChecked and child:GetChecked() and frame.GetChecked and frame:GetChecked() then
                    childOfChild:Enable()
                    childOfChild:SetAlpha(1)
                else
                    childOfChild:Disable()
                    childOfChild:SetAlpha(0.5)
                end
            end
        end
    end
end

local function DisableElement(element)
    element:Disable()
    element:SetAlpha(0.5)
end

local function EnableElement(element)
    element:Enable()
    element:SetAlpha(1)
end

local function CreateBorderBox(anchor)
    local contentFrame = anchor:GetParent()
    local texture = contentFrame:CreateTexture(nil, "BACKGROUND")
    texture:SetAtlas("UI-Frame-Neutral-PortraitWiderDisable")
    texture:SetDesaturated(true)
    texture:SetRotation(math.rad(90))
    texture:SetSize(295, 163)
    texture:SetPoint("CENTER", anchor, "CENTER", 0, -95)
    return texture
end

--[[
-- dark grey with dark bg
border:SetBackdrop({
    bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
    edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
    tile = true,
    tileEdge = true,
    tileSize = 12,
    edgeSize = 12,
    insets = { left = 5, right = 5, top = 9, bottom = 9 },
})

]]

--[[
-- clean dark fancy
border:SetBackdrop({
    bgFile = "Interface\\FriendsFrame\\UI-Toast-Background",
    edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
    tile = true,
    tileEdge = true,
    tileSize = 12,
    edgeSize = 12,
    insets = { left = 5, right = 5, top = 5, bottom = 5 },
})

]]

-- Function to update the icon texture
local function UpdateIconTexture(editBox, textureFrame)
    local iconID = tonumber(editBox:GetText())
    if iconID then
        textureFrame:SetTexture(iconID)
    end
end

local function CreateIconChangeWindow()
    local window = CreateFrame("Frame", "IconChangeWindow", UIParent, "BasicFrameTemplateWithInset")
    window:SetSize(300, 180)  -- Adjust size as needed
    window:SetPoint("CENTER")
    window:SetFrameStrata("HIGH")

    -- Make the frame movable
    window:SetMovable(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)
    window:Hide()

    -- Edit box
    local editBox = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
    editBox:SetSize(150, 20)
    editBox:SetPoint("CENTER", window, "CENTER", 20, 10)

    -- Text above the icon
    local text = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("BOTTOM", editBox, "TOP", -10, 15)
    text:SetText("Enter New Icon ID")

    -- Icon texture frame
    local textureFrame = window:CreateTexture(nil, "ARTWORK")
    textureFrame:SetSize(50, 50)  -- Enlarged icon
    textureFrame:SetPoint("RIGHT", editBox, "LEFT", -10, 0)
    textureFrame:SetTexture(BetterBlizzFramesDB.auraToggleIconTexture)

    -- Text for finding icon IDs
    local findIconText = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    findIconText:SetPoint("CENTER", window, "CENTER", 0, -40)
    findIconText:SetText("Find Icon IDs @ wowhead.com/icons")

    -- OK button
    local okButton = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
    okButton:SetSize(60, 20)
    okButton:SetPoint("BOTTOM", window, "BOTTOM", 30, 10)
    okButton:SetText("OK")
    okButton:SetScript("OnClick", function()
        local newIconID = tonumber(editBox:GetText())
        if newIconID then
            BetterBlizzFramesDB.auraToggleIconTexture = newIconID
            if ToggleHiddenAurasButton then
                ToggleHiddenAurasButton.Icon:SetTexture(newIconID)
            end
        end
        window:Hide()
    end)

    local resetButton = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
    resetButton:SetSize(60, 20)
    resetButton:SetPoint("BOTTOM", window, "BOTTOM", -30, 10)
    resetButton:SetText("Default")
    resetButton:SetScript("OnClick", function()
        BetterBlizzFramesDB.auraToggleIconTexture = 134430
        if ToggleHiddenAurasButton then
            ToggleHiddenAurasButton.Icon:SetTexture(134430)
        end
        textureFrame:SetTexture(134430)
        editBox:SetText(134430)
    end)

    editBox:SetScript("OnTextChanged", function()
        UpdateIconTexture(editBox, textureFrame)
    end)

    editBox:SetScript("OnEnterPressed", function()
        local newIconID = tonumber(editBox:GetText())
        if newIconID then
            BetterBlizzFramesDB.auraToggleIconTexture = newIconID
            if ToggleHiddenAurasButton then
                ToggleHiddenAurasButton.Icon:SetTexture(newIconID)
            end
        end
        window:Hide()
    end)

    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        window:Hide()
    end)

    window.editBox = editBox
    return window
end



local function CreateBorderedFrame(point, width, height, xPos, yPos, parent)
    local border = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    border:SetBackdrop({
        bgFile = "Interface\\FriendsFrame\\UI-Toast-Background",
        edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
        tile = true,
        tileEdge = true,
        tileSize = 10,
        edgeSize = 10,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
    })
    border:SetBackdropColor(1, 1, 1, 0.4)
    border:SetFrameLevel(1)
    border:SetSize(width, height)
    border:SetPoint("CENTER", point, "CENTER", xPos, yPos)

    return border
end

local function CreateSlider(parent, label, minValue, maxValue, stepValue, element, axis, sliderWidth)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetOrientation('HORIZONTAL')
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(stepValue)
    slider:SetObeyStepOnDrag(true)

    slider.Text:SetFontObject(GameFontHighlightSmall)
    slider.Text:SetTextColor(1, 0.81, 0, 1)

    slider.Low:SetText(" ")
    slider.High:SetText(" ")

    if sliderWidth then
        slider:SetWidth(sliderWidth)
    end

    local function UpdateSliderRange(newValue, minValue, maxValue)
        newValue = tonumber(newValue) -- Convert newValue to a number

        if (axis == "X" or axis == "Y") and (newValue < minValue or newValue > maxValue) then
            -- For X or Y axis: extend the range by ±30
            local newMinValue = math.min(newValue - 30, minValue)
            local newMaxValue = math.max(newValue + 30, maxValue)
            slider:SetMinMaxValues(newMinValue, newMaxValue)
        elseif newValue < minValue or newValue > maxValue then
            -- For other sliders: adjust the range, ensuring it never goes below a specified minimum (e.g., 0)
            local nonAxisRangeExtension = 2
            local newMinValue = math.max(newValue - nonAxisRangeExtension, 0.1)  -- Prevent going below 0.1
            local newMaxValue = math.max(newValue + nonAxisRangeExtension, maxValue)
            slider:SetMinMaxValues(newMinValue, newMaxValue)
        end
    end

    local function SetSliderValue()
        if BBF.variablesLoaded then
            local initialValue = tonumber(BetterBlizzFramesDB[element]) -- Convert to number

            if initialValue then
                local currentMin, currentMax = slider:GetMinMaxValues() -- Fetch the latest min and max values

                -- Check if the initial value is outside the current range and update range if necessary
                UpdateSliderRange(initialValue, currentMin, currentMax)

                slider:SetValue(initialValue) -- Set the initial value
                local textValue = initialValue % 1 == 0 and tostring(math.floor(initialValue)) or string.format("%.2f", initialValue)
                slider.Text:SetText(label .. ": " .. textValue)
            end
        else
            C_Timer.After(0.1, SetSliderValue)
        end
    end

    SetSliderValue()

    if parent:GetObjectType() == "CheckButton" and parent:GetChecked() == false then
        slider:Disable()
        slider:SetAlpha(0.5)
    else
        if parent:GetObjectType() == "CheckButton" and parent:IsEnabled() then
            slider:Enable()
            slider:SetAlpha(1)
        elseif parent:GetObjectType() ~= "CheckButton" then
            slider:Enable()
            slider:SetAlpha(1)
        end
    end

    -- Create Input Box on Right Click
    local editBox = CreateFrame("EditBox", nil, slider, "InputBoxTemplate")
    editBox:SetAutoFocus(false)
    editBox:SetWidth(50) -- Set the width of the EditBox
    editBox:SetHeight(20) -- Set the height of the EditBox
    editBox:SetMultiLine(false)
    editBox:SetPoint("CENTER", slider, "CENTER", 0, 0) -- Position it to the right of the slider
    editBox:SetFrameStrata("DIALOG") -- Ensure it appears above other UI elements
    editBox:Hide()
    editBox:SetFontObject(GameFontHighlightSmall)

    -- Function to handle the entered value and update the slider
    local function HandleEditBoxInput()
        local inputValue = tonumber(editBox:GetText())
        if inputValue then
            -- Check if it's a non-axis slider and inputValue is <= 0
            if (axis ~= "X" and axis ~= "Y") and inputValue <= 0 then
                inputValue = 0.1  -- Set to minimum allowed value for non-axis sliders
            end

            local currentMin, currentMax = slider:GetMinMaxValues()
            if inputValue < currentMin or inputValue > currentMax then
                UpdateSliderRange(inputValue, currentMin, currentMax)
            end

            slider:SetValue(inputValue)
            BetterBlizzFramesDB[element] = inputValue
        end
        editBox:Hide()
    end


    editBox:SetScript("OnEnterPressed", HandleEditBoxInput)

    slider:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            editBox:Show()
            editBox:SetFocus()
        end
    end)

    local initialValue = tonumber(BetterBlizzFramesDB[element])
    local textValue = initialValue % 1 == 0 and tostring(math.floor(initialValue)) or string.format("%.2f", initialValue)
    slider.Text:SetText(label .. ": " .. textValue)
    slider:SetValue(initialValue)

    slider:SetScript("OnMouseWheel", function(slider, delta)
        if IsShiftKeyDown() then
            local currentVal = slider:GetValue()
            if delta > 0 then
                slider:SetValue(currentVal + stepValue)
            else
                slider:SetValue(currentVal - stepValue)
            end
        end
    end)

    slider:SetScript("OnValueChanged", function(self, value)
        if not BetterBlizzFramesDB.wasOnLoadingScreen then
            local textValue = value % 1 == 0 and tostring(math.floor(value)) or string.format("%.2f", value)
            self.Text:SetText(label .. ": " .. textValue)
            --if not BBF.checkCombatAndWarn() then
                -- Update the X or Y position based on the axis
                if axis == "X" then
                    BetterBlizzFramesDB[element .. "XPos"] = value
                elseif axis == "Y" then
                    BetterBlizzFramesDB[element .. "YPos"] = value
                elseif axis == "Alpha" then
                    BetterBlizzFramesDB[element .. "Alpha"] = value
                elseif axis == "Height" then
                    BetterBlizzFramesDB[element .. "Height"] = value
                end

                if not axis then
                    BetterBlizzFramesDB[element .. "Scale"] = value
                end

                local xPos = BetterBlizzFramesDB[element .. "XPos"] or 0
                local yPos = BetterBlizzFramesDB[element .. "YPos"] or 0
                local anchorPoint = BetterBlizzFramesDB[element .. "Anchor"] or "CENTER"

                --If no frames are present still adjust values
                if element == "targetToTXPos" then
                    BetterBlizzFramesDB.targetToTXPos = value
                    if not BBF.checkCombatAndWarn() then
                        BBF.MoveToTFrames()
                    end
                elseif element == "targetToTYPos" then
                    BetterBlizzFramesDB.targetToTYPos = value
                    if not BBF.checkCombatAndWarn() then
                        BBF.MoveToTFrames()
                    end
                elseif element == "targetToTScale" then
                    BetterBlizzFramesDB.targetToTScale = value
                    if not BBF.checkCombatAndWarn() then
                        BBF.MoveToTFrames()
                    end
                elseif element == "focusToTScale" then
                    BetterBlizzFramesDB.focusToTScale = value
                    if not BBF.checkCombatAndWarn() then
                        BBF.MoveToTFrames()
                    end
                elseif element == "focusToTXPos" then
                    BetterBlizzFramesDB.focusToTXPos = value
                    if not BBF.checkCombatAndWarn() then
                        BBF.MoveToTFrames()
                    end
                elseif element == "focusToTYPos" then
                    BetterBlizzFramesDB.focusToTYPos = value
                    if not BBF.checkCombatAndWarn() then
                        BBF.MoveToTFrames()
                    end
                elseif element == "darkModeColor" then
                    BetterBlizzFramesDB.darkModeColor = value
                    if not BBF.checkCombatAndWarn() then
                        BBF.DarkmodeFrames()
                    end
                elseif element == "lossOfControlScale" then
                    BetterBlizzFramesDB.lossOfControlScale = value
                    --BBF.ToggleLossOfControlTestMode()
                    --BBF.ChangeLossOfControlScale()
                elseif element == "targetAndFocusAuraOffsetX" then
                    BetterBlizzFramesDB.targetAndFocusAuraOffsetX = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "targetAndFocusAuraOffsetY" then
                    BetterBlizzFramesDB.targetAndFocusAuraOffsetY = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "targetAndFocusAuraScale" then
                    BetterBlizzFramesDB.targetAndFocusAuraScale = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "targetAndFocusHorizontalGap" then
                    BetterBlizzFramesDB.targetAndFocusHorizontalGap = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "targetAndFocusVerticalGap" then
                    BetterBlizzFramesDB.targetAndFocusVerticalGap = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "targetAndFocusAurasPerRow" then
                    BetterBlizzFramesDB.targetAndFocusAurasPerRow = value
                    BBF.RefreshAllAuraFrames()
                    --
                elseif element == "castBarInterruptHighlighterStartTime" then
                    BetterBlizzFramesDB.castBarInterruptHighlighterStartTime = value
                    BBF.CastbarRecolorWidgets()
                elseif element == "castBarInterruptHighlighterEndTime" then
                    BetterBlizzFramesDB.castBarInterruptHighlighterEndTime = value
                    BBF.CastbarRecolorWidgets()
                elseif element == "combatIndicatorScale" then
                    BetterBlizzFramesDB.combatIndicatorScale = value
                    BBF.CombatIndicatorCaller()
                elseif element == "combatIndicatorXPos" then
                    BetterBlizzFramesDB.combatIndicatorXPos = value
                    BBF.CombatIndicatorCaller()
                elseif element == "combatIndicatorYPos" then
                    BetterBlizzFramesDB.combatIndicatorYPos = value
                    BBF.CombatIndicatorCaller()
                elseif element == "absorbIndicatorScale" then
                    BetterBlizzFramesDB.absorbIndicatorScale = value
                    BBF.AbsorbCaller()
                elseif element == "playerAbsorbXPos" then
                    BetterBlizzFramesDB.playerAbsorbXPos = value
                    BBF.AbsorbCaller()
                elseif element == "playerAbsorbYPos" then
                    BetterBlizzFramesDB.playerAbsorbYPos = value
                    BBF.AbsorbCaller()
                elseif element == "targetAbsorbXPos" then
                    BetterBlizzFramesDB.targetAbsorbXPos = value
                    BBF.AbsorbCaller()
                elseif element == "targetAbsorbYPos" then
                    BetterBlizzFramesDB.targetAbsorbYPos = value
                    BBF.AbsorbCaller()
                elseif element == "partyCastBarScale" then
                    BetterBlizzFramesDB.partyCastBarScale = value
                    BBF.UpdateCastbars()
                elseif element == "partyCastBarXPos" then
                    BetterBlizzFramesDB.partyCastBarXPos = value
                    BBF.UpdateCastbars()
                elseif element == "partyCastBarYPos" then
                    BetterBlizzFramesDB.partyCastBarYPos = value
                    BBF.UpdateCastbars()
                elseif element == "partyCastbarIconXPos" then
                    BetterBlizzFramesDB.partyCastbarIconXPos = value
                    BBF.UpdateCastbars()
                elseif element == "partyCastbarIconYPos" then
                    BetterBlizzFramesDB.partyCastbarIconYPos = value
                    BBF.UpdateCastbars()
                elseif element == "partyCastBarWidth" then
                    BetterBlizzFramesDB.partyCastBarWidth = value
                    BBF.UpdateCastbars()
                elseif element == "partyCastBarHeight" then
                    BetterBlizzFramesDB.partyCastBarHeight = value
                    BBF.UpdateCastbars()
                elseif element == "partyCastBarIconScale" then
                    BetterBlizzFramesDB.partyCastBarIconScale = value
                    BBF.UpdateCastbars()
                elseif element == "targetCastBarScale" then
                    BetterBlizzFramesDB.targetCastBarScale = value
                    BBF.ChangeCastbarSizes()
                elseif element == "targetCastBarXPos" then
                    BetterBlizzFramesDB.targetCastBarXPos = value
                    BBF.CastbarAdjustCaller()
                elseif element == "targetCastBarYPos" then
                    BetterBlizzFramesDB.targetCastBarYPos = value
                    BBF.CastbarAdjustCaller()
                elseif element == "targetCastBarWidth" then
                    BetterBlizzFramesDB.targetCastBarWidth = value
                    BBF.ChangeCastbarSizes()
                elseif element == "targetCastBarHeight" then
                    BetterBlizzFramesDB.targetCastBarHeight = value
                    BBF.ChangeCastbarSizes()
                elseif element == "targetCastBarIconScale" then
                    BetterBlizzFramesDB.targetCastBarIconScale = value
                    BBF.ChangeCastbarSizes()
                elseif element == "targetCastbarIconXPos" then
                    BetterBlizzFramesDB.targetCastbarIconXPos = value
                    BBF.ChangeCastbarSizes()
                elseif element == "targetCastbarIconYPos" then
                    BetterBlizzFramesDB.targetCastbarIconYPos = value
                    BBF.ChangeCastbarSizes()
                elseif element == "focusCastBarScale" then
                    BetterBlizzFramesDB.focusCastBarScale = value
                    BBF.ChangeCastbarSizes()
                elseif element == "focusCastBarXPos" then
                    BetterBlizzFramesDB.focusCastBarXPos = value
                    BBF.CastbarAdjustCaller()
                elseif element == "focusCastBarYPos" then
                    BetterBlizzFramesDB.focusCastBarYPos = value
                    BBF.CastbarAdjustCaller()
                elseif element == "focusCastBarWidth" then
                    BetterBlizzFramesDB.focusCastBarWidth = value
                    BBF.ChangeCastbarSizes()
                elseif element == "focusCastBarHeight" then
                    BetterBlizzFramesDB.focusCastBarHeight = value
                    BBF.ChangeCastbarSizes()
                elseif element == "focusCastBarIconScale" then
                    BetterBlizzFramesDB.focusCastBarIconScale = value
                    BBF.ChangeCastbarSizes()
                elseif element == "playerCastBarScale" then
                    BetterBlizzFramesDB.playerCastBarScale = value
                    BBF.ChangeCastbarSizes()
                elseif element == "focusCastbarIconXPos" then
                    BetterBlizzFramesDB.focusCastbarIconXPos = value
                    BBF.ChangeCastbarSizes()
                elseif element == "focusCastbarIconYPos" then
                    BetterBlizzFramesDB.focusCastbarIconYPos = value
                    BBF.ChangeCastbarSizes()
                elseif element == "playerCastBarIconScale" then
                    BetterBlizzFramesDB.playerCastBarIconScale = value
                    BBF.ChangeCastbarSizes()
                elseif element == "playerCastBarXPos" then
                    BetterBlizzFramesDB.playerCastBarXPos = value
                    BBF.ChangeCastbarSizes()
                elseif element == "playerCastBarYPos" then
                    BetterBlizzFramesDB.playerCastBarYPos = value
                    BBF.ChangeCastbarSizes()
                elseif element == "playerCastBarWidth" then
                    BetterBlizzFramesDB.playerCastBarWidth = value
                    BBF.ChangeCastbarSizes()
                elseif element == "playerCastBarHeight" then
                    BetterBlizzFramesDB.playerCastBarHeight = value
                    BBF.ChangeCastbarSizes()
                elseif element == "maxTargetBuffs" then
                    BetterBlizzFramesDB.maxTargetBuffs = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "maxTargetDebuffs" then
                    BetterBlizzFramesDB.maxTargetDebuffs = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "maxBuffFrameBuffs" then
                    BetterBlizzFramesDB.maxBuffFrameBuffs = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "maxBuffFrameDebuffs" then
                    BetterBlizzFramesDB.maxBuffFrameDebuffs = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "petCastBarScale" then
                    BetterBlizzFramesDB.petCastBarScale = value
                    BBF.UpdatePetCastbar()
                elseif element == "petCastBarXPos" then
                    BetterBlizzFramesDB.petCastBarXPos = value
                    BBF.UpdatePetCastbar()
                elseif element == "petCastBarYPos" then
                    BetterBlizzFramesDB.petCastBarYPos = value
                    BBF.UpdatePetCastbar()
                elseif element == "petCastBarWidth" then
                    BetterBlizzFramesDB.petCastBarWidth = value
                    BBF.UpdatePetCastbar()
                elseif element == "petCastBarHeight" then
                    BetterBlizzFramesDB.petCastBarHeight = value
                    BBF.UpdatePetCastbar()
                elseif element == "petCastBarIconScale" then
                    BetterBlizzFramesDB.petCastBarIconScale = value
                    BBF.UpdatePetCastbar()
                elseif element == "playerAuraMaxBuffsPerRow" then
                    BetterBlizzFramesDB.playerAuraMaxBuffsPerRow = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "playerAuraSpacingX" then
                    BetterBlizzFramesDB.playerAuraSpacingX = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "playerAuraBuffScale" then
                    BetterBlizzFramesDB.playerAuraBuffScale = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "playerAuraSpacingY" then
                    BetterBlizzFramesDB.playerAuraSpacingY = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "playerAuraXOffset" then
                    BetterBlizzFramesDB.playerAuraXOffset = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "playerAuraYOffset" then
                    BetterBlizzFramesDB.playerAuraYOffset = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "auraTypeGap" then
                    BetterBlizzFramesDB.auraTypeGap = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "auraStackSize" then
                    BetterBlizzFramesDB.auraStackSize = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "targetAndFocusSmallAuraScale" then
                    BetterBlizzFramesDB.targetAndFocusSmallAuraScale = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "enlargedAuraSize" then
                    BetterBlizzFramesDB.enlargedAuraSize = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "purgeableAuraSize" then
                    BetterBlizzFramesDB.purgeableAuraSize = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "compactedAuraSize" then
                    BetterBlizzFramesDB.compactedAuraSize = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "racialIndicatorScale" then
                    BetterBlizzFramesDB.racialIndicatorScale = value
                    BBF.RacialIndicatorCaller()
                elseif element == "racialIndicatorXPos" then
                    BetterBlizzFramesDB.racialIndicatorXPos = value
                    BBF.RacialIndicatorCaller()
                elseif element == "racialIndicatorYPos" then
                    BetterBlizzFramesDB.racialIndicatorYPos = value
                    BBF.RacialIndicatorCaller()
                elseif element == "targetToTAdjustmentOffsetY" then
                    BetterBlizzFramesDB.targetToTAdjustmentOffsetY = value
                    BBF.CastbarAdjustCaller()
                elseif element == "focusToTAdjustmentOffsetY" then
                    BetterBlizzFramesDB.focusToTAdjustmentOffsetY = value
                    BBF.CastbarAdjustCaller()
                elseif element == "playerFrameScale" then
                    BetterBlizzFramesDB.playerFrameScale = value
                    BBF.ScaleUnitFrames()
                elseif element == "targetFrameScale" then
                    BetterBlizzFramesDB.targetFrameScale = value
                    BBF.ScaleUnitFrames()
                elseif element == "focusFrameScale" then
                    BetterBlizzFramesDB.focusFrameScale = value
                    BBF.ScaleUnitFrames()
                elseif element == "castBarInterruptIconScale" then
                    BetterBlizzFramesDB.castBarInterruptIconScale = value
                    BBF.UpdateInterruptIconSettings()
                elseif element == "castBarInterruptIconXPos" then
                    BetterBlizzFramesDB.castBarInterruptIconXPos = value
                    BBF.UpdateInterruptIconSettings()
                elseif element == "castBarInterruptIconYPos" then
                    BetterBlizzFramesDB.castBarInterruptIconYPos = value
                    BBF.UpdateInterruptIconSettings()

                    --end
                end
            end
    end)
    return slider
end

local function CreateTooltip(widget, tooltipText, anchor)
    widget:SetScript("OnEnter", function(self)
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
        end

        if anchor then
            GameTooltip:SetOwner(self, anchor)
        else
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        end
        GameTooltip:SetText(tooltipText)

        GameTooltip:Show()
    end)

    widget:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

local function CreateTooltipTwo(widget, title, mainText, subText, anchor, cvarName)
    widget:SetScript("OnEnter", function(self)
        -- Clear the tooltip before showing new information
        GameTooltip:ClearLines()
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
        end
        if anchor then
            GameTooltip:SetOwner(self, anchor)
        else
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        end
        -- Set the bold title
        GameTooltip:AddLine(title)
        --GameTooltip:AddLine(" ") -- Adding an empty line as a separator
        -- Set the main text
        GameTooltip:AddLine(mainText, 1, 1, 1, true) -- true for wrap text
        -- Set the subtext
        if subText then
            GameTooltip:AddLine("____________________________", 0.8, 0.8, 0.8, true)
            GameTooltip:AddLine(subText, 0.8, 0.80, 0.80, true)
        end
        -- Add CVar information if provided
        if cvarName then
            --GameTooltip:AddLine(" ")
            --GameTooltip:AddLine("Default Value: " .. cvarName, 0.5, 0.5, 0.5) -- grey color for subtext
            GameTooltip:AddDoubleLine("Changes CVar:", cvarName, 0.2, 1, 0.6, 0.2, 1, 0.6)
        end
        GameTooltip:Show()
    end)
    widget:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

local function notWorking(element, re)
    --element:Disable()
    local hasOnClick = pcall(function() return element:GetScript("OnClick") end)
    if hasOnClick then
        element:SetScript("OnClick", function() end)
    end
    element:SetScript("OnMouseDown", function() end)
    element:SetScript("OnMouseUp", function() end)
    element:SetAlpha(0.4)
    if element.Text then
        element.Text:SetTextColor(1,0,0)
    end
    CreateTooltipTwo(element, "Not Working", "Currently not working and disabled for cata. May or may not be removed TBD.", "A lot of other features might also not work 100% in this Beta version. Keep an eye out for errors.")

    if re then
        C_Timer.After(4, function()
            notWorking(element)
        end)
    end
end

local function CreateImportExportUI(parent, title, dataTable, posX, posY, tableName)
    -- Frame to hold all import/export elements
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetSize(210, 65) -- Adjust size as needed
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", posX, posY)
    
    -- Setting the backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground", -- More subtle background
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Sleeker border
        tile = false, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.7) -- Semi-transparent black

    -- Title
    local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    titleText:SetPoint("BOTTOM", frame, "TOP", 0, 0)
    titleText:SetText(title)

    -- Export EditBox
    local exportBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    exportBox:SetSize(100, 20)
    exportBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -15, -10)
    exportBox:SetAutoFocus(false)
    CreateTooltipTwo(exportBox, "Ctrl+C to copy and share")

    -- Import EditBox
    local importBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    importBox:SetSize(100, 20)
    importBox:SetPoint("TOP", exportBox, "BOTTOM", 0, -5)
    importBox:SetAutoFocus(false)

    -- Export Button
    local exportBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    exportBtn:SetPoint("RIGHT", exportBox, "LEFT", -10, 0)
    exportBtn:SetSize(73, 20)
    exportBtn:SetText("Export")
    exportBtn:SetNormalFontObject("GameFontNormal")
    exportBtn:SetHighlightFontObject("GameFontHighlight")
    CreateTooltipTwo(exportBtn, "Export Data", "Create an export string to share your data.")

    -- Import Button
    local importBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    importBtn:SetPoint("RIGHT", importBox, "LEFT", -10, 0)
    --importBtn:SetSize(title ~= "Full Profile" and 52 or 73, 20)
    importBtn:SetSize(73, 20)
    importBtn:SetText("Import")
    importBtn:SetNormalFontObject("GameFontNormal")
    importBtn:SetHighlightFontObject("GameFontHighlight")
    CreateTooltipTwo(importBtn, "Import Data", "Import an export string.\nWill remove any current data (optional setting coming in non-beta)")

    -- Keep Old Checkbox
    -- if title ~= "Full Profile" then
    --     local keepOldCheckbox = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
    --     keepOldCheckbox:SetPoint("RIGHT", importBtn, "LEFT", 3, -1)
    --     keepOldCheckbox:SetChecked(true)
    --     CreateTooltipTwo(keepOldCheckbox, "Keep Old Data (BETA)", "(BETA) Not expected to work currently. Import new data while keeping your old one. Uncheck to remove current data.")
    -- end

    -- Button scripts
    exportBtn:SetScript("OnClick", function()
        local exportString = ExportProfile(dataTable, tableName)
        exportBox:SetText(exportString)
        exportBox:SetFocus()
        exportBox:HighlightText()
    end)


    importBtn:SetScript("OnClick", function()
        local importString = importBox:GetText()
        local profileData, errorMessage = ImportProfile(importString, tableName)
        if errorMessage then
            print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rFrames: Error importing " .. title .. ":", errorMessage)
        else
            if keepOldCheckbox and keepOldCheckbox:GetChecked() then
                -- Perform a deep merge if "Keep Old" is checked
                deepMergeTables(dataTable, profileData)
            else
                -- Replace existing data with imported data
                --for k in pairs(dataTable) do dataTable[k] = nil end -- Clear current table
                for k, v in pairs(profileData) do
                    dataTable[k] = v -- Populate with new data
                end
            end
            print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rFrames: " .. title .. " imported successfully. While still BETA this requires a reload to load in new lists.")
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    return frame
end

local function CreateAnchorDropdown(name, parent, defaultText, settingKey, toggleFunc, point)
    -- Create the dropdown frame using the library's creation function
    local dropdown = LibDD:Create_UIDropDownMenu(name, parent)
    LibDD:UIDropDownMenu_SetWidth(dropdown, 125)

    -- Function to get the display text based on the setting value
    local function getDisplayTextForSetting(settingValue)
        if name == "combatIndicatorDropdown" or name == "playerAbsorbAnchorDropdown" then
            if settingValue == "LEFT" then
                return "INNER"
            elseif settingValue == "RIGHT" then
                return "OUTER"
            end
        end
        return settingValue
    end

    -- Set the initial dropdown text
    LibDD:UIDropDownMenu_SetText(dropdown, getDisplayTextForSetting(BetterBlizzFramesDB[settingKey]) or defaultText)

    local anchorPointsToUse = anchorPoints
    if name == "combatIndicatorDropdown" or name == "playerAbsorbAnchorDropdown" then
        anchorPointsToUse = anchorPoints2
    end

    -- Initialize the dropdown using the library's initialize function
    LibDD:UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = LibDD:UIDropDownMenu_CreateInfo()
        for _, anchor in ipairs(anchorPointsToUse) do
            local displayText = anchor

            -- Customize display text for specific dropdowns
            if name == "combatIndicatorDropdown" or name == "playerAbsorbAnchorDropdown" then
                if anchor == "LEFT" then
                    displayText = "INNER"
                elseif anchor == "RIGHT" then
                    displayText = "OUTER"
                end
            end

            info.text = displayText
            info.arg1 = anchor
            info.func = function(self, arg1)
                if BetterBlizzFramesDB[settingKey] ~= arg1 then
                    BetterBlizzFramesDB[settingKey] = arg1
                    LibDD:UIDropDownMenu_SetText(dropdown, getDisplayTextForSetting(arg1))
                    toggleFunc(arg1)
                    BBF.MoveToTFrames()
                end
            end
            info.checked = (BetterBlizzFramesDB[settingKey] == anchor)
            LibDD:UIDropDownMenu_AddButton(info)
        end
    end)

    -- Position the dropdown
    dropdown:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    -- Create and set up the label
    local dropdownText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownText:SetPoint("BOTTOM", dropdown, "TOP", 0, 3)
    dropdownText:SetText(point.label)

    -- Enable or disable the dropdown based on the parent's check state
    if parent:GetObjectType() == "CheckButton" and parent:GetChecked() == false then
        LibDD:UIDropDownMenu_DisableDropDown(dropdown)
    else
        LibDD:UIDropDownMenu_EnableDropDown(dropdown)
    end

    return dropdown
end

local function CreateCheckbox(option, label, parent, cvarName, extraFunc)
    local checkBox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    checkBox.Text:SetText(label)
    checkBox.text = checkBox.Text
    checkBox:SetHitRectInsets(0, 0, 0, 0)
    checkBox.Text:SetFont("Fonts\\FRIZQT__.TTF", 11)
    local a,b,c,d,e = checkBox.Text:GetPoint()
    checkBox.Text:SetPoint(a,b,c,d-4,e-1)
    checkBox:SetSize(24,24)

    local function UpdateOption(value)
        if option == 'friendlyFrameClickthrough' and BBF.checkCombatAndWarn() then
            return
        end

        local function SetChecked()
            if BetterBlizzFramesDB.hasCheckedUi then
                BetterBlizzFramesDB[option] = value
                checkBox:SetChecked(value)
            else
                C_Timer.After(0.1, function()
                    SetChecked()
                end)
            end
        end
        SetChecked()

        local grandparent = parent:GetParent()

        if parent:GetObjectType() == "CheckButton" and (parent:GetChecked() == false or (grandparent:GetObjectType() == "CheckButton" and grandparent:GetChecked() == false)) then
            checkBox:Disable()
            checkBox:SetAlpha(0.5)
        else
            checkBox:Enable()
            checkBox:SetAlpha(1)
        end

        if extraFunc and not BetterBlizzFramesDB.wasOnLoadingScreen then
            extraFunc(option, value)
        end


        if not BetterBlizzFramesDB.wasOnLoadingScreen and BetterBlizzFramesDB.playerAuraFiltering then
            BBF.UpdateUserAuraSettings()
            BBF.RefreshAllAuraFrames()
        end
        --print("Checkbox option '" .. option .. "' changed to:", value)
    end

    UpdateOption(BetterBlizzFramesDB[option])

    checkBox:HookScript("OnClick", function(_, _, _)
        UpdateOption(checkBox:GetChecked())
    end)

    return checkBox
end

local function CreateList(subPanel, listName, listData, refreshFunc, extraBoxes, colorText, width, pos)
    -- Create the scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, subPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(width or 322, 270)
    if not pos then
        scrollFrame:SetPoint("TOPLEFT", 10, -10)
    else
        scrollFrame:SetPoint("TOPLEFT", -48, -10)
    end

    -- Create the content frame
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(width or 322, 270)
    scrollFrame:SetScrollChild(contentFrame)

    local textLines = {}
    local selectedLineIndex = nil

    -- Function to update the background colors of the entries
    local function updateBackgroundColors()
        for i, button in ipairs(textLines) do
            local bg = button.bgImg
            if i % 2 == 0 then
                bg:SetColorTexture(0.3, 0.3, 0.3, 0.1)  -- Dark color for even lines
            else
                bg:SetColorTexture(0.3, 0.3, 0.3, 0.3)  -- Light color for odd lines
            end
        end
    end

    local function deleteEntry(dataEntry)
        if not dataEntry then return end
        for i, entry in ipairs(listData) do
            if entry == dataEntry then
                table.remove(listData, i)
                break
            end
        end
        contentFrame.refreshList()
        BBF.RefreshAllAuraFrames()
    end

    local function createTextLineButton(npc, index, extraBoxes)
        local button = CreateFrame("Frame", nil, contentFrame)
        button:SetSize((width and width - 12) or (322 - 12), 20)
        button:SetPoint("TOPLEFT", 10, -(index - 1) * 20)
        button.npcData = npc

        local bg = button:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        button.bgImg = bg  -- Store the background texture for later color updates

        local iconTexture = button:CreateTexture(nil, "OVERLAY")
        iconTexture:SetSize(20, 20)  -- Same height as the button
        iconTexture:SetPoint("LEFT", button, "LEFT", 0, 0)

        -- Set the icon image
        if npc.id then
            iconTexture:SetTexture(GetSpellTexture(npc.id))
        elseif npc.name then
            iconTexture:SetTexture(GetSpellTexture(npc.name))
        end

        local displayText = npc.id and npc.id or ""

        if npc.name and npc.name ~= "" then
            displayText = npc.name .. (displayText ~= "" and " - " or "") .. displayText
        end
        if npc.comment and npc.comment ~= "" then
            displayText = npc.comment .. (displayText ~= "" and " - " or "") .. displayText
        end

        local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", button, "LEFT", 25, 0)
        text:SetText(displayText)
        if pos then
            text:SetWidth(225)
            text:SetWordWrap(false)
            text:SetJustifyH("LEFT")
        end

        -- Initialize the text color and background color for this entry from npc table or with default values
        local entryColors = npc.entryColors or {}
        npc.entryColors = entryColors  -- Save the colors back to the npc data

        if not entryColors.text then
            entryColors.text = { r = 0, g = 1, b = 0 } -- Default to green color
        end

        -- Function to set the text color
        local function SetTextColor(r, g, b, a)
            r = r or 1
            b = b or 0
            g = g or 0.8196
            a = 1
            if colorText then
                if npc.flags and npc.flags.important then
                    text:SetTextColor(r, g, b, a)
                else
                    text:SetTextColor(1, 1, 0, a)  -- Keeping alpha consistent
                end
            else
                text:SetTextColor(1, 1, 0, a)  -- Keeping alpha consistent
            end
        end

        -- Set initial text and background colors from entryColors
        SetTextColor(entryColors.text.r, entryColors.text.g, entryColors.text.b, 1)

        local deleteButton = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
        deleteButton:SetSize(20, 20)
        deleteButton:SetPoint("RIGHT", button, "RIGHT", 4, 0)
        deleteButton:SetText("X")

        deleteButton:SetScript("OnClick", function()
            if IsShiftKeyDown() then
                deleteEntry(button.npcData)
            else
                selectedLineIndex = button.npcData
                StaticPopup_Show("BBF_DELETE_NPC_CONFIRM_" .. listName)
            end
        end)

        if extraBoxes then
            -- Ensure the npc.flags table exists
            if not npc.flags then
                npc.flags = { important = false, pandemic = false, enlarged = false }
            end

            -- Create Checkbox P (Pandemic)
            local checkBoxP = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
            checkBoxP:SetSize(24, 24)
            checkBoxP:SetPoint("RIGHT", deleteButton, "LEFT", 4, 0) -- Positioned first, to the left of deleteButton

            -- Create a texture for the checkbox
            checkBoxP.texture = checkBoxP:CreateTexture(nil, "ARTWORK", nil, 1)
            checkBoxP.texture:SetTexture(BBF.squareGreenGlow)
            checkBoxP.texture:SetDesaturated(true)
            checkBoxP.texture:SetVertexColor(1, 0, 0)
            checkBoxP.texture:SetSize(46, 46)
            checkBoxP.texture:SetPoint("CENTER", checkBoxP, "CENTER", -0.5, 0)
            CreateTooltipTwo(checkBoxP, "Pandemic Glow |T"..BBF.PandemicIcon..":22:22:0:0|t", "Check for a red glow when the aura has less than 5 sec remaining.", "Also check which frame(s) you want this on down below in settings.", "ANCHOR_TOPRIGHT")

            -- Handler for the P checkbox
            checkBoxP:SetScript("OnClick", function(self)
                npc.flags.pandemic = self:GetChecked() -- Save the state in the npc flags
            end)
            checkBoxP:HookScript("OnClick", BBF.RefreshAllAuraFrames)

            -- Initialize state from npc flags
            if npc.flags.pandemic then
                checkBoxP:SetChecked(true)
            end

            -- Create Checkbox I (Important)
            local checkBoxI = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
            checkBoxI:SetSize(24, 24)
            checkBoxI:SetPoint("RIGHT", checkBoxP, "LEFT", 4, 0) -- Positioned next to checkBoxP

            -- Create a texture for the checkbox
            checkBoxI.texture = checkBoxI:CreateTexture(nil, "ARTWORK", nil, 1)
            checkBoxI.texture:SetTexture(BBF.squareGreenGlow)
            checkBoxI.texture:SetSize(46, 46)
            checkBoxI.texture:SetDesaturated(true)
            checkBoxI.texture:SetPoint("CENTER", checkBoxI, "CENTER", -0.5, 0)
            CreateTooltipTwo(checkBoxI, "Important Glow |T"..BBF.ImportantIcon..":22:22:0:0|t", "Check for a glow on the aura to highlight it.\n|cff32f795Right-click to change color.|r", "Also check which frame(s) you want this on down below in settings.", "ANCHOR_TOPRIGHT")

            -- Handler for the I checkbox
            checkBoxI:SetScript("OnClick", function(self)
                npc.flags.important = self:GetChecked() -- Save the state in the npc flags
            end)
            local function SetImportantBoxColor(r, g, b, a)
                if npc.flags and npc.flags.important then
                    checkBoxI.texture:SetVertexColor(r, g, b, a)
                else
                    checkBoxI.texture:SetVertexColor(0,1,0,1)
                end
            end
            checkBoxI:HookScript("OnClick", function()
                BBF.RefreshAllAuraFrames()
                SetTextColor(entryColors.text.r, entryColors.text.g, entryColors.text.b, 1)
                SetImportantBoxColor(entryColors.text.r, entryColors.text.g, entryColors.text.b, entryColors.text.a)
            end)

            -- Initialize state from npc flags
            if npc.flags.important then
                checkBoxI:SetChecked(true)
            end

            SetImportantBoxColor(entryColors.text.r, entryColors.text.g, entryColors.text.b, entryColors.text.a)

            -- Function to open the color picker
            local function OpenColorPicker()
                local colorData = entryColors.text or {}
                local r, g, b = colorData.r or 1, colorData.g or 1, colorData.b or 1
                local a = colorData.a or 1 -- Default alpha to 1 if not present

                local function updateColors()
                    entryColors.text.r, entryColors.text.g, entryColors.text.b, entryColors.text.a = r, g, b, a
                    SetTextColor(r, g, b, a)  -- Update text color
                    SetImportantBoxColor(r, g, b, a)  -- Update other elements as needed
                    BBF.RefreshAllAuraFrames()  -- Refresh frames or elements that depend on these colors
                end

                local function swatchFunc()
                    r, g, b = ColorPickerFrame:GetColorRGB()
                    updateColors()  -- Update colors based on the new selection
                end

                local function opacityFunc()
                    a = ColorPickerFrame:GetColorAlpha()
                    updateColors()  -- Update colors including the alpha value
                end

                local function cancelFunc(previousValues)
                    -- Revert to previous values if the selection is cancelled
                    if previousValues then
                        r, g, b, a = previousValues.r, previousValues.g, previousValues.b, previousValues.a
                        updateColors()  -- Reapply the previous colors
                    end
                end

                -- Store the initial values before showing the color picker
                ColorPickerFrame.previousValues = { r = r, g = g, b = b, a = a }

                -- Setup and show the color picker with the necessary callbacks and initial values
                ColorPickerFrame:SetupColorPickerAndShow({
                    r = r, g = g, b = b, opacity = a, hasOpacity = true,
                    swatchFunc = swatchFunc, opacityFunc = opacityFunc, cancelFunc = cancelFunc
                })
            end

            checkBoxI:HookScript("OnMouseDown", function(self, button)
                if button == "RightButton" then
                    OpenColorPicker()
                end
            end)

            -- Create Checkbox C (Compacted)
            local checkBoxC = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
            checkBoxC:SetSize(24, 24)
            checkBoxC:SetPoint("RIGHT", checkBoxI, "LEFT", 3, 0)
            CreateTooltipTwo(checkBoxC, "Compacted Aura |T"..BBF.CompactIcon..":22:22:0:0|t", "Check to make the aura smaller.", "Also check which frame(s) you want this on down below in settings.", "ANCHOR_TOPRIGHT")

            -- Initialize state from npc flags
            if npc.flags.compacted then
                checkBoxC:SetChecked(true)
            end

            -- Create Checkbox E (Enlarged)
            local checkBoxE = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
            checkBoxE:SetSize(24, 24)
            checkBoxE:SetPoint("RIGHT", checkBoxC, "LEFT", 3, 0)
            CreateTooltipTwo(checkBoxE, "Enlarged Aura |T"..BBF.EnlargedIcon..":22:22:0:0|t", "Check to make the aura bigger.", "Also check which frame(s) you want this on down below in settings.", "ANCHOR_TOPRIGHT")

            -- Handler for the C checkbox
            checkBoxC:SetScript("OnClick", function(self)
                npc.flags.compacted = self:GetChecked()
                checkBoxE:SetChecked(false)
                npc.flags.enlarged = false
                BBF.RefreshAllAuraFrames()
            end)

            -- Handler for the E checkbox
            checkBoxE:SetScript("OnClick", function(self)
                npc.flags.enlarged = self:GetChecked()
                checkBoxC:SetChecked(false)
                npc.flags.compacted = false
                BBF.RefreshAllAuraFrames()
            end)

            -- Initialize state from npc flags
            if npc.flags.enlarged then
                checkBoxE:SetChecked(true)
            end

            -- Create Checkbox Only Mine
            local checkBoxOnlyMine = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
            checkBoxOnlyMine:SetSize(24, 24)
            checkBoxOnlyMine:SetPoint("RIGHT", checkBoxE, "LEFT", 3, 0)
            CreateTooltipTwo(checkBoxOnlyMine, "Only My Aura |T"..BBF.OwnAuraIcon..":22:22:0:0|t", "Only show my aura.", nil, "ANCHOR_TOPRIGHT")

            -- Handler for the E checkbox
            checkBoxOnlyMine:SetScript("OnClick", function(self)
                npc.flags.onlyMine = self:GetChecked()
            end)
            checkBoxOnlyMine:HookScript("OnClick", BBF.RefreshAllAuraFrames)

            -- Initialize state from npc flags
            if npc.flags.onlyMine then
                checkBoxOnlyMine:SetChecked(true)
            end
        end

        if listName == "auraBlacklist" then
            -- Create Checkbox Only Mine
            local checkBoxShowMine = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
            checkBoxShowMine:SetSize(24, 24)
            checkBoxShowMine:SetPoint("RIGHT", deleteButton, "LEFT", 3, 0)
            CreateTooltipTwo(checkBoxShowMine, "Show mine |T"..BBF.OwnAuraIcon..":22:22:0:0|t", "Disregard the blacklist and show aura if it is mine.", nil, "ANCHOR_TOPRIGHT")

            -- Handler for the E checkbox
            checkBoxShowMine:SetScript("OnClick", function(self)
                npc.showMine = self:GetChecked()
            end)
            checkBoxShowMine:HookScript("OnClick", BBF.RefreshAllAuraFrames)

            -- Initialize state from npc flags
            if npc.showMine then
                checkBoxShowMine:SetChecked(true)
            end

            text:SetWidth(196)
            text:SetWordWrap(false)
            text:SetJustifyH("LEFT")
        end

        button.deleteButton = deleteButton
        table.insert(textLines, button)
        updateBackgroundColors()  -- Update background colors after adding a new entry

        if npc.id then
            button:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:SetSpellByID(npc.id)
                GameTooltip:AddLine("Spell ID: " .. npc.id, 1, 1, 1)
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
        end
    end


    -- Create and initialize textLine buttons with or without color pickers
    -- for i, npc in ipairs(listData) do
    --     createTextLineButton(npc, i, extraBoxes)
    -- end

    -- Create static popup dialogs for duplicate and delete confirmations
    StaticPopupDialogs["BBF_DUPLICATE_NPC_CONFIRM_" .. listName] = {
        text = "This name or spellID is already in the list. Do you want to remove it from the list?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            deleteEntry(selectedLineIndex)  -- Delete the entry when "Yes" is clicked
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    StaticPopupDialogs["BBF_DELETE_NPC_CONFIRM_" .. listName] = {
        text = "Are you sure you want to delete this entry?\nHold shift to delete without this prompt",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            deleteEntry(selectedLineIndex)  -- Delete the entry when "Yes" is clicked
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    local editBox = CreateFrame("EditBox", nil, subPanel, "InputBoxTemplate")
    editBox:SetSize((width and width - 62) or (322 - 62), 19)
    editBox:SetPoint("TOP", scrollFrame, "BOTTOM", -15, -5)
    editBox:SetAutoFocus(false)
    CreateTooltipTwo(editBox, "Filter auras by spell id and/or spell name", "You can click auras to add to lists.\n\nShift+Alt + Left-Click to Whitelist.\n\nShift+Alt + Right-Click to Blacklist.\nCtrl+Alt Right-click to Blacklist with \"Show Mine\" tag", nil, "ANCHOR_TOP")

    local function updateNamesInListData()
        for _, entry in ipairs(listData) do
            if entry.id and (not entry.name or entry.name == "") then
                local spellName = GetSpellInfo(entry.id)
                if spellName then
                    entry.name = spellName  -- Update the name field with the fetched spell name
                end
            end
        end
    end

    local function getSortedNpcList()
        updateNamesInListData()  -- Ensure names are updated before sorting

        local sortableNpcList = {}
        for _, entry in ipairs(listData) do
            table.insert(sortableNpcList, entry)  -- Directly use entry, no need to separate into npcId and npcData
        end

        table.sort(sortableNpcList, function(a, b)
            local nameA = a.name and a.name:lower()
            local nameB = b.name and b.name:lower()
            return nameA < nameB
        end)

        return sortableNpcList
    end

    local sortedListData = getSortedNpcList()
    for i, npc in ipairs(sortedListData) do
        createTextLineButton(npc, i, extraBoxes)
    end

    local function refreshList()
        -- Clear existing buttons
        for _, button in ipairs(textLines) do
            button:Hide()
        end
        wipe(textLines)

        -- Fetch sorted list and recreate UI elements
        local sortedListData = getSortedNpcList()
        for i, npc in ipairs(sortedListData) do
            local button = createTextLineButton(npc, i, extraBoxes)
            table.insert(textLines, button)
        end

        updateBackgroundColors()
        -- Update the content frame size if necessary
        contentFrame:SetHeight(#textLines * 20)
    end
    contentFrame.refreshList = refreshList

    local function addOrUpdateEntry(inputText, addShowMineTag)
        selectedLineIndex = nil
        local name, comment = strsplit("/", inputText, 2)
        name = strtrim(name or "")
        comment = strtrim(comment or "")
        local id = tonumber(name)

        -- Check if there's a numeric ID within the name and clear the name if found
        if id then
            local spellName, _, _ = GetSpellInfo(id)
            name = spellName or ""
        end

        -- Remove unwanted characters from name and comment individually
        name = gsub(name, "[%/%(%)%[%]]", "")
        comment = gsub(comment, "[%/%(%)%[%]]", "")

        if (name ~= "" or id) then
            local isDuplicate = false

            for i, npc in ipairs(listData) do
                if (id and npc.id == id) or (not id and npc.name and strlower(npc.name) == strlower(name)) then
                    isDuplicate = true
                    selectedLineIndex = npc
                    break
                end
            end

            if isDuplicate then
                StaticPopup_Show("BBF_DUPLICATE_NPC_CONFIRM_" .. listName)
            else
                -- Initialize the flags table for the new entry
                local newEntry = { name = name, id = id, comment = comment, flags = { important = false, pandemic = false } }
                if addShowMineTag and listName == "auraBlacklist" then
                    newEntry = { name = name, id = id, comment = comment, flags = { important = false, pandemic = false }, showMine = true }
                end
                table.insert(listData, newEntry)
                createTextLineButton(newEntry, #textLines + 1, extraBoxes)
                refreshList()
                refreshFunc()
            end
        end
        BBF.RefreshAllAuraFrames()

        editBox:SetText("") -- Clear the EditBox
    end

    BBF[listName] = addOrUpdateEntry

    editBox:SetScript("OnEnterPressed", function(self)
        addOrUpdateEntry(self:GetText())
    end)

    local addButton = CreateFrame("Button", nil, subPanel, "UIPanelButtonTemplate")
    addButton:SetSize(60, 24)
    addButton:SetText("Add")
    addButton:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
    addButton:SetScript("OnClick", function()
        addOrUpdateEntry(editBox:GetText())
    end)
    return scrollFrame
end

local function CreateTitle(parent)
    local mainGuiAnchor = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor:SetPoint("TOPLEFT", 15, -15)
    mainGuiAnchor:SetText(" ")
    local addonNameText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    addonNameText:SetPoint("TOPLEFT", mainGuiAnchor, "TOPLEFT", -20, 47)
    addonNameText:SetText("BetterBlizzFrames")
    local addonNameIcon = parent:CreateTexture(nil, "ARTWORK")
    addonNameIcon:SetAtlas("gmchat-icon-blizz")
    addonNameIcon:SetSize(22, 22)
    addonNameIcon:SetPoint("LEFT", addonNameText, "RIGHT", -2, -1)
    local verNumber = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    verNumber:SetPoint("LEFT", addonNameText, "RIGHT", 25, 0)
    verNumber:SetText("v" .. BBF.VersionNumber)
end

------------------------------------------------------------
-- GUI Panels
------------------------------------------------------------
local function guiGeneralTab()
    ----------------------
    -- Main panel:
    ----------------------
    local mainGuiAnchor = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor:SetPoint("TOPLEFT", 15, -15)
    mainGuiAnchor:SetText(" ")

    local bgImg = BetterBlizzFrames:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", BetterBlizzFrames, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local alpha = BetterBlizzFrames:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    alpha:SetPoint("CENTER", 0, 0)
    alpha:SetText("BETA")
    alpha:SetFont("Fonts\\FRIZQT__.TTF", 156)
    alpha:SetScale(1.4)
    alpha:SetAlpha(0.1)

    local alpha2 = BetterBlizzFrames:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    alpha2:SetPoint("BOTTOM", SettingsPanel, "TOP", 0, 0)
    alpha2:SetText("BetterBlizzFrames Cata is still in Beta. Please report bugs.")
    alpha2:SetFont("Fonts\\FRIZQT__.TTF", 20, "THINOUTLINE")
    alpha2:Hide()
    BetterBlizzFrames:HookScript("OnShow",function()
        alpha2:Show()
    end)
    BetterBlizzFrames:HookScript("OnHide",function()
        alpha2:Hide()
    end)

    -- local addonNameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    -- addonNameText:SetPoint("TOPLEFT", mainGuiAnchor, "TOPLEFT", -20, 47)
    -- addonNameText:SetText("BetterBlizzFrames")
    -- local addonNameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    -- addonNameIcon:SetAtlas("gmchat-icon-blizz")
    -- addonNameIcon:SetSize(22, 22)
    -- addonNameIcon:SetPoint("LEFT", addonNameText, "RIGHT", -2, -1)
    -- local verNumber = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- verNumber:SetPoint("LEFT", addonNameText, "RIGHT", 25, 0)
    -- verNumber:SetText("v" .. BBF.VersionNumber)
    CreateTitle(BetterBlizzFrames)

    ----------------------
    -- General:
    ----------------------
    -- "General:" text
    local settingsText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, 30)
    settingsText:SetText("General settings")
    local generalSettingsIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    generalSettingsIcon:SetAtlas("optionsicon-brown")
    generalSettingsIcon:SetSize(22, 22)
    generalSettingsIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)






    local hideArenaFrames = CreateCheckbox("hideArenaFrames", "Hide Arena Frames", BetterBlizzFrames, nil, BBF.HideArenaFrames)
    hideArenaFrames:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    hideArenaFrames:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    CreateTooltip(hideArenaFrames, "Hide the standard Blizzard Arena Frames.\nThis uses the same code as the addon\n\"Arena Anti-Malware\", also made by me.")
    notWorking(hideArenaFrames, true)

    local hideBossFrames = CreateCheckbox("hideBossFrames", "Hide Boss Frames", BetterBlizzFrames, nil, BBF.HideArenaFrames)
    hideBossFrames:SetPoint("TOPLEFT", hideArenaFrames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideBossFrames, "Hide the Blizzard Boss Frames that are underneath the minimap.")
    notWorking(hideBossFrames, true)

    local hideBossFramesParty = CreateCheckbox("hideBossFramesParty", "Party", BetterBlizzFrames, nil, BBF.HideArenaFrames)
    hideBossFramesParty:SetPoint("LEFT", hideBossFrames.text, "RIGHT", 0, 0)
    CreateTooltip(hideBossFramesParty, "Hide Boss Frames in Party", "ANCHOR_LEFT")

    local hideBossFramesRaid = CreateCheckbox("hideBossFramesRaid", "Raid", BetterBlizzFrames, nil, BBF.HideArenaFrames)
    hideBossFramesRaid:SetPoint("LEFT", hideBossFramesParty.text, "RIGHT", 0, 0)
    CreateTooltip(hideBossFramesRaid, "Hide Boss Frames in Raid", "ANCHOR_LEFT")

    hideBossFrames:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzFramesDB.overShieldsCompact = true
            BetterBlizzFramesDB.hideBossFramesParty = true
            hideBossFramesParty:SetAlpha(1)
            hideBossFramesParty:Enable()
            hideBossFramesParty:SetChecked(true)
            hideBossFramesRaid:SetAlpha(1)
            hideBossFramesRaid:Enable()
            hideBossFramesRaid:SetChecked(true)
        else
            BetterBlizzFramesDB.overShieldsCompact = false
            BetterBlizzFramesDB.hideBossFramesParty = false
            hideBossFramesParty:SetAlpha(0)
            hideBossFramesParty:Disable()
            hideBossFramesParty:SetChecked(false)
            hideBossFramesRaid:SetAlpha(0)
            hideBossFramesRaid:Disable()
            hideBossFramesRaid:SetChecked(false)
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    if not BetterBlizzFramesDB.hideBossFrames then
        hideBossFramesParty:SetAlpha(0)
        hideBossFramesParty:Disable()
        hideBossFramesRaid:SetAlpha(0)
        hideBossFramesRaid:Disable()
    end

    local playerFrameOCD = CreateCheckbox("playerFrameOCD", "OCD Tweaks", BetterBlizzFrames, nil, BBF.FixStupidBlizzPTRShit)
    playerFrameOCD:SetPoint("TOPLEFT", hideBossFrames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(playerFrameOCD, "OCD Tweaks", "Fixes some of Blizzards laziness with the UI.\n\nFixes Actionbar layout & centers it properly.\nFixes hotkey text being shortened for no reason.\nAdds minor zoom on actionbar icons so the double border effect gets removed.\n\n|cff32f795Right-click to toggle icon zoom on/off.|r")
    playerFrameOCD:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" and BetterBlizzFramesDB.playerFrameOCD then
            BetterBlizzFramesDB.playerFrameOCDZoom = not BetterBlizzFramesDB.playerFrameOCDZoom
            BBF.ActionBarIconZoom()
        end
    end)

    local playerFrameOCDTextureBypass = CreateCheckbox("playerFrameOCDTextureBypass", "OCD: Skip Bars", BetterBlizzFrames, nil, BBF.HideFrames)
    playerFrameOCDTextureBypass:SetPoint("LEFT", playerFrameOCD.text, "RIGHT", 0, 0)
    CreateTooltip(playerFrameOCDTextureBypass, "If healthbars & manabars look weird enable this to skip\nadjusting them and only fix portraits + Name Background")
    notWorking(playerFrameOCDTextureBypass, true)

    playerFrameOCD:HookScript("OnClick", function(self)
        if self:GetChecked() then
            playerFrameOCDTextureBypass:Enable()
            playerFrameOCDTextureBypass:SetAlpha(1)
        else
            BetterBlizzFramesDB.playerFrameOCDTextureBypass = false
            playerFrameOCDTextureBypass:SetChecked(false)
            playerFrameOCDTextureBypass:Disable()
            playerFrameOCDTextureBypass:SetAlpha(0)
        end
    end)

    if not BetterBlizzFramesDB.playerFrameOCD then
        playerFrameOCDTextureBypass:Disable()
        playerFrameOCDTextureBypass:SetAlpha(0)
    end

    local hideLossOfControlFrameBg = CreateCheckbox("hideLossOfControlFrameBg", "Hide CC Background", BetterBlizzFrames, nil, BBF.HideFrames)
    hideLossOfControlFrameBg:SetPoint("TOPLEFT", playerFrameOCD, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideLossOfControlFrameBg, "Hide the dark background on the LossOfControl frame (displaying CC on you)")
    hideLossOfControlFrameBg:HookScript("OnClick", function()
        BBF.ToggleLossOfControlTestMode()
    end)
    notWorking(hideLossOfControlFrameBg, true)

    local hideLossOfControlFrameLines = CreateCheckbox("hideLossOfControlFrameLines", "Hide CC Red-lines", BetterBlizzFrames, nil, BBF.HideFrames)
    hideLossOfControlFrameLines:SetPoint("TOPLEFT", hideLossOfControlFrameBg, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideLossOfControlFrameLines, "Hide the red lines on top and bottom of the LossOfControl frame (displaying CC on you)")
    hideLossOfControlFrameLines:HookScript("OnClick", function()
        BBF.ToggleLossOfControlTestMode()
    end)
    notWorking(hideLossOfControlFrameLines, true)

    local lossOfControlScale = CreateSlider(BetterBlizzFrames, "CC Scale", 0.4, 1.4, 0.01, "lossOfControlScale", nil, 90)
    lossOfControlScale:SetPoint("LEFT", hideLossOfControlFrameBg.text, "RIGHT", 3, -16)
    CreateTooltipTwo(lossOfControlScale, "Loss of Control Scale", "Adjust the scale of the LossOfControlFrame\n(displaying cc on you center screen)")
    notWorking(lossOfControlScale, true)

    local darkModeUi = CreateCheckbox("darkModeUi", "Dark Mode", BetterBlizzFrames)
    darkModeUi:SetPoint("TOPLEFT", hideLossOfControlFrameLines, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeUi:HookScript("OnClick", function(self)
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeUi, "Simple dark mode for: UnitFrames, Actionbars & Aura Icons.\n\nIf you want a more advanced & thorough dark mode\nI recommend the addon FrameColor instead of this setting.")

    local darkModeActionBars = CreateCheckbox("darkModeActionBars", "ActionBars", darkModeUi)
    darkModeActionBars:SetPoint("TOPLEFT", darkModeUi, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeActionBars:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeActionBars, "Dark borders for action bars.")

    local darkModeMinimap = CreateCheckbox("darkModeMinimap", "Minimap", darkModeUi)
    darkModeMinimap:SetPoint("TOPLEFT", darkModeActionBars, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeMinimap:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeMinimap, "Dark mode for Minimap")

    local darkModeCastbars = CreateCheckbox("darkModeCastbars", "Castbars", darkModeUi)
    darkModeCastbars:SetPoint("LEFT", darkModeUi.Text, "RIGHT", 5, 0)
    darkModeCastbars:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeCastbars, "Dark borders for castbars.")

    local darkModeUiAura = CreateCheckbox("darkModeUiAura", "Auras", darkModeUi)
    darkModeUiAura:SetPoint("TOPLEFT", darkModeCastbars, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeUiAura:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeUiAura, "Dark borders for Player, Target and Focus aura icons")

    -- local darkModeNameplateResource = CreateCheckbox("darkModeNameplateResource", "Nameplate Resource", darkModeUi)
    -- darkModeNameplateResource:SetPoint("TOPLEFT", darkModeUiAura, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- darkModeNameplateResource:HookScript("OnClick", function()
    --     BBF.DarkmodeFrames(true)
    -- end)
    -- CreateTooltip(darkModeNameplateResource, "Dark mode for nameplate resource (Combopoints etc)\n\n(If you are using this same feature in BBP\nthat one will be prioritized)")

    local darkModeColor = CreateSlider(darkModeUi, "Darkness", 0, 1, 0.01, "darkModeColor", nil, 90)
    darkModeColor:SetPoint("LEFT", darkModeUiAura.text, "RIGHT", 3, -1)
    CreateTooltip(darkModeColor, "Dark mode value.\n\nYou can right-click sliders to enter a specific value.")

    darkModeUi:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(darkModeUi, 0)
    end)
    if not BetterBlizzFramesDB.darkModeUi then
        CheckAndToggleCheckboxes(darkModeUi, 0)
    end










    local playerFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playerFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -155)
    playerFrameText:SetText("Player Frame")
    local playerFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    playerFrameIcon:SetAtlas("groupfinder-icon-friend")
    playerFrameIcon:SetSize(28, 28)
    playerFrameIcon:SetPoint("RIGHT", playerFrameText, "LEFT", -3, 0)

    local playerFrameScale = CreateSlider(BetterBlizzFrames, "Size", 0.7, 1.4, 0.01, "playerFrameScale", nil, 120)
    playerFrameScale:SetPoint("TOP", playerFrameText, "BOTTOM", 23, -13)
    CreateTooltipTwo(playerFrameScale, "PlayerFrame Size", "Change the size of the PlayerFrame", "Right-click to input specific value")

    local playerFrameClickthrough = CreateCheckbox("playerFrameClickthrough", "Clickthrough", BetterBlizzFrames, nil, BBF.ClickthroughFrames)
    playerFrameClickthrough:SetPoint("TOPLEFT", playerFrameText, "BOTTOMLEFT", -4, -26)
    CreateTooltip(playerFrameClickthrough, "Makes the PlayerFrame clickthrough.\nYou can still hold shift to left/right click it\nwhile out of combat for trade/inspect etc.\n\nNOTE: You will NOT be able to click the frame\nat all during combat with this setting on.")

    local playerReputationColor = CreateCheckbox("playerReputationColor", "Add Name Bg", BetterBlizzFrames, nil, BBF.PlayerReputationColor)
    playerReputationColor:SetPoint("TOPLEFT", playerFrameClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(playerReputationColor, "Add name background color behind name like on Target & Focus.|A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a\nCan be class colored as well.")

    local playerReputationClassColor = CreateCheckbox("playerReputationClassColor", "Class color", BetterBlizzFrames, nil, BBF.PlayerReputationColor)
    playerReputationClassColor:SetPoint("LEFT", playerReputationColor.text, "RIGHT", 5, 0)
    CreateTooltip(playerReputationClassColor, "Class color the Player reputation texture.")
    playerReputationColor:HookScript("OnClick", function(self)
        if self:GetChecked() then
            playerReputationClassColor:Enable()
            playerReputationClassColor:SetAlpha(1)
        else
            playerReputationClassColor:Disable()
            playerReputationClassColor:SetAlpha(0)
        end
    end)
    if not BetterBlizzFramesDB.playerReputationColor then
        playerReputationClassColor:SetAlpha(0)
        playerReputationClassColor:Disable()
    end

    local hidePlayerName = CreateCheckbox("hidePlayerName", "Hide Name", BetterBlizzFrames)
    hidePlayerName:SetPoint("TOPLEFT", playerReputationColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hidePlayerName:HookScript("OnClick", function(self)
        BBF.UpdateUserTargetSettings()
        if self:GetChecked() then
            PlayerFrame.cleanName:SetAlpha(0)
        else
            if UnitExists("player") then
                PlayerFrame.cleanName:SetText(GetUnitName("player"))
            end
            PlayerFrame.cleanName:SetAlpha(1)
        end
    end)

    -- local hidePlayerPower = CreateCheckbox("hidePlayerPower", "Hide Resource/Power", BetterBlizzFrames, nil, BBF.HideFrames)
    -- hidePlayerPower:SetPoint("TOPLEFT", hidePlayerName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltip(hidePlayerPower, "Hide Resource/Power under PlayerFrame. Rogue combopoints, Warlock shards etc.")
    -- notWorking(hidePlayerPower, true)

    local hidePlayerRestAnimation = CreateCheckbox("hidePlayerRestAnimation", "Hide \"Zzz\" Rest Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerRestAnimation:SetPoint("TOPLEFT", hidePlayerName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerRestAnimation, "Hide the \"Zzz\" animation on PlayerFrame while rested.")

    local hidePlayerRestGlow = CreateCheckbox("hidePlayerRestGlow", "Hide Rest Glow", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerRestGlow:SetPoint("TOPLEFT", hidePlayerRestAnimation, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerRestGlow, "Hide the flashing yellow rest glow animation around PlayerFrame while rested.|A:UI-HUD-UnitFrame-Player-PortraitOn-Status:30:80|a")

    local hideMultiGroupFrame = CreateCheckbox("hideMultiGroupFrame", "Hide MultiGroup Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hideMultiGroupFrame:SetPoint("TOPLEFT", hidePlayerRestGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideMultiGroupFrame, "Hide multigroup icon on PlayerFrame.|A:UI-HUD-UnitFrame-Player-PortraitOn-CornerEmbellishment:22:22|a\n")

    local hideCombatIcon = CreateCheckbox("hideCombatIcon", "Hide Combat Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hideCombatIcon:SetPoint("TOPLEFT", hideMultiGroupFrame, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    local textureStringWithCoords = GenerateTextureString(130936, 32, 32, 0.5, 1, 0, 0.484375, 256, 256)
    CreateTooltip(hideCombatIcon, "Hide combat icon in the bottom left corner of the PlayerFrame.\n" .. textureStringWithCoords)

    local hideGroupIndicator = CreateCheckbox("hideGroupIndicator", "Hide Group Indicator", BetterBlizzFrames, nil, BBF.HideFrames)
    hideGroupIndicator:SetPoint("TOPLEFT", hideCombatIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideGroupIndicator, "Hide the group indicator on top of PlayerFrame\nwhile you are in a group.")

    local hidePlayerLeaderIcon = CreateCheckbox("hidePlayerLeaderIcon", "Hide Leader Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerLeaderIcon:SetPoint("TOPLEFT", hideGroupIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    local leaderIcon = GenerateTextureString(132062, 32, 32)
    CreateTooltip(hidePlayerLeaderIcon, "Hide the party leader icon from PlayerFrame."..leaderIcon)

    -- local hidePlayerGuideIcon = CreateCheckbox("hidePlayerGuideIcon", "Hide Guide Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    -- hidePlayerGuideIcon:SetPoint("LEFT", hidePlayerLeaderIcon.text, "RIGHT", 0, 0)
    -- CreateTooltip(hidePlayerGuideIcon, "Hide the guide icon from PlayerFrame.|A:UI-HUD-UnitFrame-Player-Group-GuideIcon:22:22|a")
    -- notWorking(hidePlayerGuideIcon, true)

    local hidePlayerRoleIcon = CreateCheckbox("hidePlayerRoleIcon", "Hide Role Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerRoleIcon:SetPoint("TOPLEFT", hidePlayerLeaderIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerRoleIcon, "Hide the role icon from PlayerFrame|A:roleicon-tiny-dps:22:22|a")
    notWorking(hidePlayerRoleIcon, true)

    local hidePvpTimerText = CreateCheckbox("hidePvpTimerText", "Hide PvP Timer", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePvpTimerText:SetPoint("TOPLEFT", hidePlayerRoleIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePvpTimerText, "Hide the PvP timer text under the Prestige Badge.\nI don't even know what it is a timer for.\nMy best guess is for when you're no longer PvP tagged.")





    local petFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    petFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, -455)
    petFrameText:SetText("Pet Frame")
    local petFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    petFrameIcon:SetAtlas("newplayerchat-chaticon-newcomer")
    petFrameIcon:SetSize(21, 21)
    petFrameIcon:SetPoint("RIGHT", petFrameText, "LEFT", -2, 0)

    local petCastbar = CreateCheckbox("petCastbar", "Pet Castbar", BetterBlizzFrames, nil, BBF.UpdatePetCastbar)
    petCastbar:SetPoint("TOPLEFT", petFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltip(petCastbar, "Show pet castbar.\n\nMore settings in the \"Castbars\" tab")

    local colorPetAfterOwner = CreateCheckbox("colorPetAfterOwner", "Class Color Pet", BetterBlizzFrames)
    colorPetAfterOwner:SetPoint("TOPLEFT", petCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    colorPetAfterOwner:HookScript("OnClick", function (self)
        BBF.UpdateFrames()
    end)
    CreateTooltipTwo(colorPetAfterOwner, "Class Color Pet", "Color pet healthbar after player class")

    local hidePetText = CreateCheckbox("hidePetText", "Hide Pet Statusbar Text", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePetText:SetPoint("TOPLEFT", colorPetAfterOwner, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hidePetText, "Hide Pet Statusbar Text", "Hide the health and mana text on PetFrame.")

    local partyFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    partyFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -430)
    partyFrameText:SetText("Party Frame")
    local partyFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    partyFrameIcon:SetAtlas("groupfinder-icon-friend")
    partyFrameIcon:SetSize(25, 25)
    partyFrameIcon:SetPoint("RIGHT", partyFrameText, "LEFT", -4, -1)
    local partyFrameIcon2 = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    partyFrameIcon2:SetAtlas("groupfinder-icon-friend")
    partyFrameIcon2:SetSize(20, 20)
    partyFrameIcon2:SetPoint("RIGHT", partyFrameText, "LEFT", 0, 4)

    local showPartyCastbar = CreateCheckbox("showPartyCastbar", "Party Castbars", BetterBlizzFrames, nil, BBF.UpdateCastbars)
    showPartyCastbar:SetPoint("TOPLEFT", partyFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    showPartyCastbar:HookScript("OnClick", function(self)
        --BBF.AbsorbCaller()
    end)
    CreateTooltip(showPartyCastbar, "Show party members castbar on party frames.\n\nMore settings in the \"Castbars\" tab.")

--[=[
    local sortGroup = CreateCheckbox("sortGroup", "Sort Group", BetterBlizzFrames, nil, BBF.SortGroup)
    sortGroup:SetPoint("TOPLEFT", showPartyCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(sortGroup, "Always sort the group members in chronological order from top to bottom. ")

    local sortGroupPlayerTop = CreateCheckbox("sortGroupPlayerTop", "Player on Top", BetterBlizzFrames, nil, BBF.SortGroup)
    sortGroupPlayerTop:SetPoint("LEFT", sortGroup.text, "RIGHT", 0, 0)

    local sortGroupPlayerBottom = CreateCheckbox("sortGroupPlayerBottom", "Player on Bottom", BetterBlizzFrames, nil, BBF.SortGroup)
    sortGroupPlayerBottom:SetPoint("LEFT", sortGroupPlayerTop.text, "RIGHT", 0, 0)

    sortGroupPlayerTop:HookScript("OnClick", function(self)
        if self:GetChecked() then
            sortGroupPlayerBottom:SetChecked(false)
            BetterBlizzFramesDB.sortGroupPlayerBottom = false
        end
    end)

    sortGroupPlayerBottom:HookScript("OnClick", function(self)
        if self:GetChecked() then
            sortGroupPlayerTop:SetChecked(false)
            BetterBlizzFramesDB.sortGroupPlayerTop = false
        end
    end)

    sortGroup:HookScript("OnClick", function(self)
        if self:GetChecked() then
            sortGroupPlayerTop:Enable()
            sortGroupPlayerTop:SetAlpha(1)
            sortGroupPlayerBottom:Enable()
            sortGroupPlayerBottom:SetAlpha(1)
        else
            sortGroupPlayerTop:Disable()
            sortGroupPlayerTop:SetAlpha(0)
            sortGroupPlayerBottom:Disable()
            sortGroupPlayerBottom:SetAlpha(0)
        end
    end)
    if not BetterBlizzFramesDB.sortGroup then
        sortGroupPlayerTop:SetAlpha(0)
        sortGroupPlayerBottom:SetAlpha(0)
    end

]=]


    local hidePartyFramesInArena = CreateCheckbox("hidePartyFramesInArena", "Hide Party in Arena (GEX)", BetterBlizzFrames, nil, BBF.HidePartyInArena)
    hidePartyFramesInArena:SetPoint("TOPLEFT", showPartyCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePartyFramesInArena, "Hide Party Frames in Arena. Made with GladiusEx Party Frames in mind.") 
    notWorking(hidePartyFramesInArena, true)

    local hidePartyNames = CreateCheckbox("hidePartyNames", "Hide Names", BetterBlizzFrames)
    hidePartyNames:SetPoint("TOPLEFT", hidePartyFramesInArena, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hidePartyNames:HookScript("OnClick", function(self)
        BBF.UpdateUserTargetSettings()
        if self:GetChecked() then
            for i = 1, 5 do
                local frame = _G["CompactRaidFrame"..i] or _G["CompactPartyFrameMember"..i]
                if frame and frame.cleanName then
                    frame.cleanName:SetAlpha(0)
                end
            end
        else
            for i = 1, 5 do
                local frame = _G["CompactPartyFrameMember"..i] or _G["CompactRaidFrame"..i]
                if frame then
                    local unit = frame.displayedUnit
            
                    if frame.cleanName and unit then
                        frame.cleanName:SetAlpha(1)
                        frame.cleanName:SetText(GetUnitName(unit))
                    end
        
                end
            end
        end
    end)

    local hidePartyAggroHighlight = CreateCheckbox("hidePartyAggroHighlight", "Hide Aggro Highlight", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePartyAggroHighlight:SetPoint("LEFT", hidePartyNames.text, "RIGHT", 0, 0)
    CreateTooltip(hidePartyAggroHighlight, "Hide the Aggro Highlight border around each party frame.")

    local hidePartyRoles = CreateCheckbox("hidePartyRoles", "Hide Role Icons", BetterBlizzFrames)
    hidePartyRoles:SetPoint("TOPLEFT", hidePartyNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hidePartyRoles:HookScript("OnClick", function(self)
        BBF.UpdateUserTargetSettings()
        if self:GetChecked() then
            for i = 1, 5 do
                local roleIcon = _G["CompactPartyFrameMember"..i.."RoleIcon"]
                local roleIconRaid = _G["CompactRaidFrame"..i.."RoleIcon"]
                if roleIcon then
                    roleIcon:SetAlpha(0)
                end
                if roleIconRaid then
                    roleIconRaid:SetAlpha(0)
                end
            end
        else
            for i = 1, 5 do
                local roleIcon = _G["CompactPartyFrameMember"..i.."RoleIcon"]
                local roleIconRaid = _G["CompactRaidFrame"..i.."RoleIcon"]
                if roleIcon then
                    roleIcon:SetAlpha(1)
                end
                if roleIconRaid then
                    roleIconRaid:SetAlpha(1)
                end
            end
        end
    end)
    CreateTooltip(hidePartyRoles, "Hide the role icons from party frame|A:roleicon-tiny-dps:22:22|a|A:spec-role-dps:22:22|a")

    local hidePartyFrameTitle = CreateCheckbox("hidePartyFrameTitle", "Hide CompactPartyFrame Title", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePartyFrameTitle:SetPoint("TOPLEFT", hidePartyRoles, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePartyFrameTitle, "Hide the \"Party\" text above \"Raid-Style\" Party Frames.")

    local hideRaidFrameManager = CreateCheckbox("hideRaidFrameManager", "Hide RaidFrameManager", BetterBlizzFrames, nil, BBF.HideFrames)
    hideRaidFrameManager:SetPoint("TOPLEFT", hidePartyFrameTitle, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideRaidFrameManager, "Hide the CompactRaidFrameManager. Can still be shown with mouseover.")











    local targetFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 250, -155)
    targetFrameText:SetText("Target Frame")
    local targetFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    targetFrameIcon:SetAtlas("groupfinder-icon-friend")
    targetFrameIcon:SetSize(28, 28)
    targetFrameIcon:SetPoint("RIGHT", targetFrameText, "LEFT", -3, 0)
    targetFrameIcon:SetDesaturated(1)
    targetFrameIcon:SetVertexColor(1, 0, 0)

    local targetFrameScale = CreateSlider(BetterBlizzFrames, "Size", 0.7, 1.4, 0.01, "targetFrameScale", nil, 120)
    targetFrameScale:SetPoint("TOP", targetFrameText, "BOTTOM", 23, -13)
    CreateTooltipTwo(targetFrameScale, "TargetFrame Size", "Change the size of the TargetFrame", "Right-click to input specific value")

    local targetFrameClickthrough = CreateCheckbox("targetFrameClickthrough", "Clickthrough", BetterBlizzFrames, nil, BBF.ClickthroughFrames)
    targetFrameClickthrough:SetPoint("TOPLEFT", targetFrameText, "BOTTOMLEFT", -4, -26)
    CreateTooltip(targetFrameClickthrough, "Makes the TargetFrame clickthrough.\nYou can still hold shift to left/right click it\nwhile out of combat for trade/inspect etc.\n\nNOTE: You will NOT be able to click the frame\nat all during combat with this setting on.")

    local hideTargetName = CreateCheckbox("hideTargetName", "Hide Name", BetterBlizzFrames, nil, BBF.UpdateNameSettings)
    hideTargetName:SetPoint("TOPLEFT", targetFrameClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetName, "Hide the name of the target\n\nWill still show arena names if enabled.")
    hideTargetName:HookScript("OnClick", function(self)
        BBF.UpdateUserTargetSettings()
        if self:GetChecked() then
            TargetFrame.cleanName:SetAlpha(0)
        else
            if UnitExists("target") then
                TargetFrame.cleanName:SetText(GetUnitName("target"))
            end
            TargetFrame.cleanName:SetAlpha(1)
        end
    end)


    local hideTargetLeaderIcon = CreateCheckbox("hideTargetLeaderIcon", "Hide Leader Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hideTargetLeaderIcon:SetPoint("TOPLEFT", hideTargetName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetLeaderIcon, "Hide the party leader icon from Target.|A:UI-HUD-UnitFrame-Player-Group-LeaderIcon:22:22|a")

    local classColorTargetReputationTexture = CreateCheckbox("classColorTargetReputationTexture", "Class Color Name Bg", BetterBlizzFrames)
    classColorTargetReputationTexture:SetPoint("TOPLEFT", hideTargetLeaderIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classColorTargetReputationTexture, "Class Color Name Background", "Class color the background of target name on the TargetFrame. |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")
    classColorTargetReputationTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBF.ClassColorReputation(TargetFrameNameBackground, "target")
        else
            BBF.ResetClassColorReputation(TargetFrameNameBackground, "target")
        end
    end)

    local hideTargetReputationColor = CreateCheckbox("hideTargetReputationColor", "Hide Name Background", BetterBlizzFrames, nil, BBF.HideFrames)
    hideTargetReputationColor:SetPoint("TOPLEFT", classColorTargetReputationTexture, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetReputationColor, "Hide the color behind Target name. |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")






    local targetToTFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetToTFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 250, -295)
    targetToTFrameText:SetText("Target of Target")
    local targetToTFrameIcon = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    targetToTFrameIcon:SetAtlas("groupfinder-icon-friend")
    targetToTFrameIcon:SetSize(28, 28)
    targetToTFrameIcon:SetPoint("RIGHT", targetToTFrameText, "LEFT", -3, 0)
    targetToTFrameIcon:SetDesaturated(1)
    targetToTFrameIcon:SetVertexColor(1, 0, 0)
    local targetToTFrameIcon2 = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    targetToTFrameIcon2:SetAtlas("TargetCrosshairs")
    targetToTFrameIcon2:SetSize(28, 28)
    targetToTFrameIcon2:SetPoint("TOPLEFT", targetToTFrameIcon, "TOPLEFT", 11, -13)

    local hideTargetToT = CreateCheckbox("hideTargetToT", "Hide Frame", BetterBlizzFrames, nil, BBF.HideFrames)
    hideTargetToT:SetPoint("TOPLEFT", targetToTFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)

    local hideTargetToTName = CreateCheckbox("hideTargetToTName", "Hide Name", BetterBlizzFrames)
    hideTargetToTName:SetPoint("LEFT", hideTargetToT.Text, "RIGHT", 0, 0)
    hideTargetToTName:HookScript("OnClick", function(self)
        if self:GetChecked() then
            TargetFrame.totFrame.cleanName:SetAlpha(0)
        else
            TargetFrame.totFrame.cleanName:SetAlpha(1)
            TargetFrame.totFrame.cleanName:SetText(GetUnitName("targettarget"))
        end
    end)

    local hideTargetToTDebuffs = CreateCheckbox("hideTargetToTDebuffs", "Hide ToT Debuffs", BetterBlizzFrames, nil, BBF.HideFrames)
    hideTargetToTDebuffs:SetPoint("TOPLEFT", hideTargetToT, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetToTDebuffs, "Hide the 4 small debuff icons to the right of ToT frame.")

    local targetToTScale = CreateSlider(BetterBlizzFrames, "Size", 0.6, 2.5, 0.01, "targetToTScale", nil, 120)
    targetToTScale:SetPoint("TOPLEFT", targetToTFrameText, "BOTTOMLEFT", 0, -55)
    CreateTooltip(targetToTScale, "Target of target size.\n\nYou can right-click sliders to enter a specific value.")

    BBF.targetToTXPos = CreateSlider(BetterBlizzFrames, "x offset", -100, 100, 1, "targetToTXPos", "X", 120)
    BBF.targetToTXPos:SetPoint("TOP", targetToTScale, "BOTTOM", 0, -15)
    CreateTooltip(BBF.targetToTXPos, "Target of target x offset.\n\nYou can right-click sliders to enter a specific value.")

    BBF.targetToTYPos = CreateSlider(BetterBlizzFrames, "y offset", -100, 100, 1, "targetToTYPos", "Y", 120)
    BBF.targetToTYPos:SetPoint("TOP", BBF.targetToTXPos, "BOTTOM", 0, -15)
    CreateTooltip(BBF.targetToTYPos, "Target of target y offset.\n\nYou can right-click sliders to enter a specific value.")




    local chatFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    chatFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 250, -455)
    chatFrameText:SetText("Chat Frame")
    local chatFrameIcon = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    chatFrameIcon:SetAtlas("transmog-icon-chat")
    chatFrameIcon:SetSize(18, 16)
    chatFrameIcon:SetPoint("RIGHT", chatFrameText, "LEFT", -3, 0)

    local hideChatButtons = CreateCheckbox("hideChatButtons", "Hide Chat Buttons", BetterBlizzFrames, nil, BBF.HideFrames)
    hideChatButtons:SetPoint("TOPLEFT", chatFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltip(hideChatButtons, "Hide the chat buttons. Can still be shown with mouseover.")

    local chatFrameFilters = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    chatFrameFilters:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 250, -495)
    chatFrameFilters:SetText("Filters")

    local filterGladiusSpam = CreateCheckbox("filterGladiusSpam", "Gladius Spam", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterGladiusSpam:SetPoint("TOPLEFT", hideChatButtons, "BOTTOMLEFT", 0, -10)
    CreateTooltip(filterGladiusSpam, "Filter out Gladius \"LOW HEALTH\" spam from chat.")

    local filterNpcArenaSpam = CreateCheckbox("filterNpcArenaSpam", "PvP Npc Talk", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterNpcArenaSpam:SetPoint("LEFT", filterGladiusSpam.text, "RIGHT", 0, 0)
    CreateTooltip(filterNpcArenaSpam, "Filter out npc chat messages like \"Get in there and fight, stop hiding!\"\nfrom chat during arena.")

    local filterTalentSpam = CreateCheckbox("filterTalentSpam", "Talent Spam", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterTalentSpam:SetPoint("TOPLEFT", filterGladiusSpam, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(filterTalentSpam, "Filter out \"You have learned/unlearned\" spam from chat.\nEspecially annoying during respec.")

    local filterEmoteSpam = CreateCheckbox("filterEmoteSpam", "Emote Spam", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterEmoteSpam:SetPoint("TOPLEFT", filterTalentSpam, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(filterEmoteSpam, "Filter out \"yells at his/her team members.\" and\n\"makes some strange gestures.\" from chat.")

    local filterSystemMessages = CreateCheckbox("filterSystemMessages", "System Msg", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterSystemMessages:SetPoint("TOPLEFT", filterNpcArenaSpam, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(filterSystemMessages, "Filter out a few excessive system messages. Some examples:\n\"You have joined the queue for Arena Skirmish\"\n\"Your group has been disbanded.\"\n\"You have been awarded x currency\"\n\"You are in both a party and an instance group.\"\n\nFull lists in modules\\chatFrame.lua")

    local filterMiscInfo = CreateCheckbox("filterMiscInfo", "Misc Info", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterMiscInfo:SetPoint("TOPLEFT", filterSystemMessages, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(filterMiscInfo, "Filter out \"Your equipped items suffer a durability loss\" message.")

    local arenaNamesText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arenaNamesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, -70)
    arenaNamesText:SetText("Arena Names")
    CreateTooltip(arenaNamesText, "Change player names into spec/arena id instead during arena", "ANCHOR_LEFT")
    local arenaNamesIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    arenaNamesIcon:SetAtlas("questbonusobjective")
    arenaNamesIcon:SetSize(24, 24)
    arenaNamesIcon:SetPoint("RIGHT", arenaNamesText, "LEFT", -3, 0)

    local targetAndFocusArenaNames = CreateCheckbox("targetAndFocusArenaNames", "Target & Focus", BetterBlizzFrames)
    targetAndFocusArenaNames:SetPoint("TOPLEFT", arenaNamesText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltipTwo(targetAndFocusArenaNames, "Arena Names","Change Target & Focus name to arena ID and/or spec name during arena", "Will enable a fake name. Because of this other addons like HealthBarColor's name stuff will not work properly.", "ANCHOR_LEFT")

    local partyArenaNames = CreateCheckbox("partyArenaNames", "Party", BetterBlizzFrames)
    partyArenaNames:SetPoint("LEFT", targetAndFocusArenaNames.text, "RIGHT", 0, 0)
    CreateTooltipTwo(partyArenaNames, "Arena Names", "Change party frame names to party ID and/or spec name during arena","Will enable a fake name. Because of this other addons like HealthBarColor's name stuff will not work properly.", "ANCHOR_LEFT")

    local showSpecName = CreateCheckbox("showSpecName", "Show Spec Name", BetterBlizzFrames)
    showSpecName:SetPoint("TOPLEFT", targetAndFocusArenaNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showSpecName, "Show spec name instead of name\n\nIf both spec name and arena id is selected\nit will display as for instance \"Fury 3\"")

    local shortArenaSpecName = CreateCheckbox("shortArenaSpecName", "Short", BetterBlizzFrames)
    shortArenaSpecName:SetPoint("LEFT", showSpecName.Text, "RIGHT", 0, 0)
    CreateTooltip(shortArenaSpecName, "Enable to use abbreviated specialization names.\nFor instance, \"Assassination\" will be displayed as \"Assa\".", "ANCHOR_LEFT")

    local showArenaID = CreateCheckbox("showArenaID", "Show Arena/Party ID", BetterBlizzFrames)
    showArenaID:SetPoint("TOPLEFT", showSpecName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showArenaID, "Show arena/party id instead of name\n\nIf both spec name and arena id is selected\nit will display as for instance \"Fury 3\"")

    local function ToggleDependentCheckboxes()
        local enable = targetAndFocusArenaNames:GetChecked() or partyArenaNames:GetChecked()

        if enable then
            EnableElement(showSpecName)
            EnableElement(shortArenaSpecName)
            EnableElement(showArenaID)
        else
            DisableElement(showSpecName)
            DisableElement(shortArenaSpecName)
            DisableElement(showArenaID)
        end
    end
    -- Initial setup to ensure correct state upon UI load/reload
    ToggleDependentCheckboxes()
    -- Hook into the OnClick event of targetAndFocusArenaNames
    targetAndFocusArenaNames:HookScript("OnClick", ToggleDependentCheckboxes)
    -- Hook into the OnClick event of partyArenaNames
    partyArenaNames:HookScript("OnClick", ToggleDependentCheckboxes)

    local focusFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    focusFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, -155)
    focusFrameText:SetText("Focus Frame")
    local focusFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    focusFrameIcon:SetAtlas("groupfinder-icon-friend")
    focusFrameIcon:SetSize(28, 28)
    focusFrameIcon:SetPoint("RIGHT", focusFrameText, "LEFT", -3, 0)
    focusFrameIcon:SetDesaturated(1)
    focusFrameIcon:SetVertexColor(0, 1, 0)

    local focusFrameScale = CreateSlider(BetterBlizzFrames, "Size", 0.7, 1.4, 0.01, "focusFrameScale", nil, 120)
    focusFrameScale:SetPoint("TOP", focusFrameText, "BOTTOM", 23, -13)
    CreateTooltipTwo(focusFrameScale, "FocusFrame Size", "Change the size of the FocusFrame", "Right-click to input specific value")

    local focusFrameClickthrough = CreateCheckbox("focusFrameClickthrough", "Clickthrough", BetterBlizzFrames, nil, BBF.ClickthroughFrames)
    focusFrameClickthrough:SetPoint("TOPLEFT", focusFrameText, "BOTTOMLEFT", -4, -26)
    CreateTooltip(focusFrameClickthrough, "Makes the FocusFrame clickthrough.\nYou can still hold shift to left/right click it\nwhile out of combat for trade/inspect etc.\n\nNOTE: You will NOT be able to click the frame\nat all during combat with this setting on.")

    local hideFocusName = CreateCheckbox("hideFocusName", "Hide Name", BetterBlizzFrames, nil, BBF.UpdateNameSettings)
    hideFocusName:SetPoint("TOPLEFT", focusFrameClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideFocusName, "Hide the name of the focus\n\nWill still show arena names if enabled.")
    hideFocusName:HookScript("OnClick", function(self)
        BBF.UpdateUserTargetSettings()
        if self:GetChecked() then
            FocusFrame.cleanName:SetAlpha(0)
        else
            if UnitExists("focus") then
                FocusFrame.cleanName:SetText(GetUnitName("focus"))
            end
            FocusFrame.cleanName:SetAlpha(1)
        end
    end)

    local hideFocusLeaderIcon = CreateCheckbox("hideFocusLeaderIcon", "Hide Leader Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hideFocusLeaderIcon:SetPoint("TOPLEFT", hideFocusName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideFocusLeaderIcon, "Hide the party leader icon from Focus.|A:UI-HUD-UnitFrame-Player-Group-LeaderIcon:22:22|a")

    local classColorFocusReputationTexture = CreateCheckbox("classColorFocusReputationTexture", "Class Color Name Bg", BetterBlizzFrames)
    classColorFocusReputationTexture:SetPoint("TOPLEFT", hideFocusLeaderIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classColorFocusReputationTexture, "Class Color Name Background", "Class color the background of focus name on the FocusFrame. |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")
    classColorFocusReputationTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBF.ClassColorReputation(TargetFrameNameBackground, "target")
        else
            BBF.ResetClassColorReputation(TargetFrameNameBackground, "target")
        end
    end)

    local hideFocusReputationColor = CreateCheckbox("hideFocusReputationColor", "Hide Name Background", BetterBlizzFrames, nil, BBF.HideFrames)
    hideFocusReputationColor:SetPoint("TOPLEFT", classColorFocusReputationTexture, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideFocusReputationColor, "Hide the color behind Focus name. |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")







    local focusToTFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    focusToTFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, -300)
    focusToTFrameText:SetText("Focus ToT")
    local focusToTFrameIcon = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    focusToTFrameIcon:SetAtlas("groupfinder-icon-friend")
    focusToTFrameIcon:SetSize(28, 28)
    focusToTFrameIcon:SetPoint("RIGHT", focusToTFrameText, "LEFT", -3, 0)
    focusToTFrameIcon:SetDesaturated(1)
    focusToTFrameIcon:SetVertexColor(0, 1, 0)
    local focusToTFrameIcon2 = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    focusToTFrameIcon2:SetAtlas("TargetCrosshairs")
    focusToTFrameIcon2:SetSize(28, 28)
    focusToTFrameIcon2:SetPoint("TOPLEFT", focusToTFrameIcon, "TOPLEFT", 11, -13)

    local hideFocusToT = CreateCheckbox("hideFocusToT", "Hide Frame", BetterBlizzFrames, nil, BBF.HideFrames)
    hideFocusToT:SetPoint("TOPLEFT", focusToTFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)

    local hideFocusToTName = CreateCheckbox("hideFocusToTName", "Hide Name", BetterBlizzFrames)
    hideFocusToTName:SetPoint("LEFT", hideFocusToT.Text, "RIGHT", 0, 0)
    hideFocusToTName:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBF.HookUnitFrameName()
            FocusFrame.totFrame.cleanName:SetAlpha(0)
        else
            FocusFrame.totFrame.cleanName:SetAlpha(1)
            FocusFrame.totFrame.cleanName:SetText(GetUnitName("focustarget"))
        end
    end)

    local hideFocusToTDebuffs = CreateCheckbox("hideFocusToTDebuffs", "Hide FocusToT Debuffs", BetterBlizzFrames, nil, BBF.HideFrames)
    hideFocusToTDebuffs:SetPoint("TOPLEFT", hideFocusToT, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideFocusToTDebuffs, "Hide the 4 small debuff icons to the right of ToT frame.")

    local focusToTScale = CreateSlider(BetterBlizzFrames, "Size", 0.6, 2.5, 0.01, "focusToTScale", nil, 120)
    focusToTScale:SetPoint("TOPLEFT", focusToTFrameText, "BOTTOMLEFT", 0, -55)
    CreateTooltip(focusToTScale, "Focus target of target size.\n\nYou can right-click sliders to enter a specific value.")

    BBF.focusToTXPos = CreateSlider(BetterBlizzFrames, "x offset", -100, 100, 1, "focusToTXPos", "X", 120)
    BBF.focusToTXPos:SetPoint("TOP", focusToTScale, "BOTTOM", 0, -15)
    CreateTooltip(BBF.focusToTXPos, "Focus target of target x offset.\n\nYou can right-click sliders to enter a specific value.")

    BBF.focusToTYPos = CreateSlider(BetterBlizzFrames, "y offset", -100, 100, 1, "focusToTYPos", "Y", 120)
    BBF.focusToTYPos:SetPoint("TOP", BBF.focusToTXPos, "BOTTOM", 0, -15)
    CreateTooltip(BBF.focusToTYPos, "Focus target of target y offset.\n\nYou can right-click sliders to enter a specific value.")





    local allFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    allFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 250, 30)
    allFrameText:SetText("All Frames")
    local allFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    allFrameIcon:SetAtlas("groupfinder-icon-friend")
    allFrameIcon:SetSize(25, 25)
    allFrameIcon:SetPoint("RIGHT", allFrameText, "LEFT", -4, -1)
    local allFrameIcon2 = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    allFrameIcon2:SetAtlas("groupfinder-icon-friend")
    allFrameIcon2:SetSize(20, 20)
    allFrameIcon2:SetPoint("RIGHT", allFrameText, "LEFT", 0, 4)
    allFrameIcon2:SetDesaturated(1)
    allFrameIcon2:SetVertexColor(0, 1, 0)
    local allFrameIcon3 = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    allFrameIcon3:SetAtlas("groupfinder-icon-friend")
    allFrameIcon3:SetSize(20, 20)
    allFrameIcon3:SetPoint("RIGHT", allFrameText, "LEFT", -12, 4)
    allFrameIcon3:SetDesaturated(1)
    allFrameIcon3:SetVertexColor(1, 0, 0)

    local classColorFrames = CreateCheckbox("classColorFrames", "Class Color Frames", BetterBlizzFrames)
    classColorFrames:SetPoint("TOPLEFT", allFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)

    local classColorFramesSkipPlayer = CreateCheckbox("classColorFramesSkipPlayer", "Skip Self", BetterBlizzFrames)
    classColorFramesSkipPlayer:SetPoint("LEFT", classColorFrames.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(classColorFramesSkipPlayer, "Skip Self", "Skip PlayerFrame healthbar coloring and leave it default green.")
    classColorFramesSkipPlayer:HookScript("OnClick", function(self)
        if self:GetChecked() then
            PlayerFrameHealthBar:SetStatusBarColor(0,1,0)
        else
            BBF.updateFrameColorToggleVer(PlayerFrameHealthBar, "player")
        end
    end)

    classColorFrames:HookScript("OnClick", function (self)
        local function UpdateCVar()
            if not InCombatLockdown() then
                if BetterBlizzFramesDB.classColorFrames then
                    SetCVar("raidFramesDisplayClassColor", 1)
                end
            else
                C_Timer.After(1, function()
                    UpdateCVar()
                end)
            end
        end
        UpdateCVar()
        BBF.UpdateFrames()
        if self:GetChecked() then
            classColorFramesSkipPlayer:Show()
        else
            classColorFramesSkipPlayer:Hide()
        end
    end)
    CreateTooltipTwo(classColorFrames, "Class Color Healthbars", "Class color Player, Target, Focus & Party frames.", "If you want a more I recommend the addon HealthBarColor instead of this setting.")

    if not BetterBlizzFramesDB.classColorFrames then
        classColorFramesSkipPlayer:Hide()
    end

    local biggerHealthbars = CreateCheckbox("biggerHealthbars", "Bigger Healthbars", BetterBlizzFrames, nil, BBF.HookBiggerHealthbars)
    biggerHealthbars:SetPoint("TOPLEFT", classColorFrames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(biggerHealthbars, "Bigger Healthbars","Increases the height of healthbars on Player, Target & Focus Frames.")

    local biggerHealthbarsNameInside = CreateCheckbox("biggerHealthbarsNameInside", "Name", biggerHealthbars)
    biggerHealthbarsNameInside:SetPoint("LEFT", biggerHealthbars.text, "RIGHT", 0, 0)
    CreateTooltipTwo(biggerHealthbarsNameInside, "Bigger Healthbars: Name Inside","Put the name inside of the healthbar instead of on top.")
    biggerHealthbarsNameInside:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    biggerHealthbars:HookScript("OnClick", function()
        CheckAndToggleCheckboxes(biggerHealthbars)
    end)


    local classColorTargetNames = CreateCheckbox("classColorTargetNames", "Class Color Names", BetterBlizzFrames)
    classColorTargetNames:SetPoint("TOPLEFT", biggerHealthbars, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classColorTargetNames, "Class Color Names","Class color Player, Target & Focus Names.", "Will enable a fake name. Because of this other addons like HealthBarColor's name stuff will not work properly.")
    classColorTargetNames:HookScript("OnClick", function()
        BBF.UpdateAllNames()
    end)

    local classColorLevelText = CreateCheckbox("classColorLevelText", "Level", classColorTargetNames)
    classColorLevelText:SetPoint("LEFT", classColorTargetNames.text, "RIGHT", 0, 0)
    CreateTooltip(classColorLevelText, "Also class color the level text.")
    classColorLevelText:HookScript("OnClick", function()
        BBF.HookLevelText()
    end)

    classColorTargetNames:HookScript("OnClick", function(self)
        if self:GetChecked() then
            classColorLevelText:Enable()
            classColorLevelText:SetAlpha(1)
            if TargetFrame and TargetFrame.cleanName then BBF.updateTextForUnit(TargetFrame.cleanName, TargetFrame) end
            if PlayerFrame and PlayerFrame.cleanName then BBF.updateTextForUnit(PlayerFrame.cleanName, PlayerFrame) end
            if FocusFrame and FocusFrame.cleanName then BBF.updateTextForUnit(FocusFrame.cleanName, FocusFrame) end
            if TargetFrame.totFrame and TargetFrame.totFrame.Name then BBF.updateTextForUnit(TargetFrame.totFrame.Name, TargetFrameToT) end
            if FocusFrame.totFrame and FocusFrame.totFrame.Name then BBF.updateTextForUnit(FocusFrame.totFrame.Name, FocusFrameToT) end
        else
            classColorLevelText:Disable()
            classColorLevelText:SetAlpha(0)
            if TargetFrame and TargetFrame.cleanName then TargetFrame.cleanName:SetTextColor(1, 0.81960791349411, 0) end
            if PlayerFrame and PlayerFrame.cleanName then PlayerFrame.cleanName:SetTextColor(1, 0.81960791349411, 0) end
            if FocusFrame and FocusFrame.cleanName then FocusFrame.cleanName:SetTextColor(1, 0.81960791349411, 0) end
            if TargetFrame.totFrame and TargetFrame.totFrame.Name then TargetFrame.totFrame.Name:SetTextColor(1, 0.81960791349411, 0) end
            if FocusFrame.totFrame and FocusFrame.totFrame.Name then FocusFrame.totFrame.Name:SetTextColor(1, 0.81960791349411, 0) end
        end
    end)
    if not BetterBlizzFramesDB.classColorTargetNames then
        classColorLevelText:SetAlpha(0)
    end

    -- local centerNames = CreateCheckbox("centerNames", "Center Name", BetterBlizzFrames)
    -- centerNames:SetPoint("TOPLEFT", classColorTargetNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltipTwo(centerNames, "Center Names", "Center the name on Player, Target & Focus frames.", "Will enable a fake name. Because of this other addons like HealthBarColor's name stuff will not work properly.")
    -- centerNames:HookScript("OnClick", function()
    --     StaticPopup_Show("BBF_CONFIRM_RELOAD")
    -- end)

    local removeRealmNames = CreateCheckbox("removeRealmNames", "Hide Realm Name", BetterBlizzFrames)
    removeRealmNames:SetPoint("TOPLEFT", classColorTargetNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    removeRealmNames:HookScript("OnClick", function()
        BBF.UpdateAllNames()
    end)
    CreateTooltipTwo(removeRealmNames, "Hide Realm Indicator", "Hide realm name and different realm indicator \"(*)\" from Target, Focus & Party frames.", "Will enable a fake name. Because of this other addons like HealthBarColor's name stuff will not work properly.")

    local hidePrestigeBadge = CreateCheckbox("hidePrestigeBadge", "Hide Prestige Badge", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePrestigeBadge:SetPoint("TOPLEFT", removeRealmNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePrestigeBadge, "Hide the Prestige/Honor level icon from Player, Target & Focus frames. |A:honorsystem-portrait-alliance:40:42|a |A:honorsystem-portrait-horde:40:42|a |A:honorsystem-portrait-neutral:40:42|a")

    local hideCombatGlow = CreateCheckbox("hideCombatGlow", "Hide Combat Glow", BetterBlizzFrames, nil, BBF.HideFrames)
    hideCombatGlow:SetPoint("TOPLEFT", hidePrestigeBadge, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideCombatGlow, "Hide the red combat around Player, Target & Focus.|A:UI-HUD-UnitFrame-Player-PortraitOn-InCombat:30:80|a")

    local hideLevelText = CreateCheckbox("hideLevelText", "Hide Level 85 Text", BetterBlizzFrames, nil, BBF.HideFrames)
    hideLevelText:SetPoint("TOPLEFT", hideCombatGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideLevelText, "Hide the level text for Player, Target & Focus frames if they are level 85")

    local hideLevelTextAlways = CreateCheckbox("hideLevelTextAlways", "Always", BetterBlizzFrames, nil, BBF.HideFrames)
    hideLevelTextAlways:SetPoint("LEFT", hideLevelText.Text, "RIGHT", 0, 0)
    CreateTooltip(hideLevelTextAlways, "Always hide the level text.")

    hideLevelText:HookScript("OnClick", function(self)
        if self:GetChecked() then
            hideLevelTextAlways:Enable()
            hideLevelTextAlways:Show()
        else
            hideLevelTextAlways:Disable()
            hideLevelTextAlways:Hide()
        end
    end)

    if not BetterBlizzFramesDB.hideLevelText then
        hideLevelTextAlways:Hide()
        hideLevelTextAlways:Disable()
    end

    local hidePvpIcon = CreateCheckbox("hidePvpIcon", "Hide PvP Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePvpIcon:SetPoint("TOPLEFT", hideLevelText, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePvpIcon, "Hide PvP Icon on Player, Target & Focus|A:UI-HUD-UnitFrame-Player-PVP-FFAIcon:44:28|a")

    local classPortraits = CreateCheckbox("classPortraits", "Class Portraits", BetterBlizzFrames)
    classPortraits:SetPoint("TOPLEFT", hidePvpIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classPortraits, "Show class portraits instead of player portraits. |A:groupfinder-icon-class-paladin:18:18|a")

    local classPortraitsIgnoreSelf = CreateCheckbox("classPortraitsIgnoreSelf", "Ignore Self", classPortraits)
    classPortraitsIgnoreSelf:SetPoint("LEFT", classPortraits.text, "RIGHT", 0, 0)
    CreateTooltipTwo(classPortraitsIgnoreSelf, "Class Portraits: Ignore Self","Ignore player portrait.")
    classPortraitsIgnoreSelf:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    classPortraits:HookScript("OnClick", function(self)
        if self:GetChecked() then
            EnableElement(classPortraitsIgnoreSelf)
        end
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local extraFeaturesText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    extraFeaturesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, 30)
    extraFeaturesText:SetText("Extra Features")
    local extraFeaturesIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    extraFeaturesIcon:SetAtlas("Campaign-QuestLog-LoreBook")
    extraFeaturesIcon:SetSize(24, 24)
    extraFeaturesIcon:SetPoint("RIGHT", extraFeaturesText, "LEFT", -3, 0)

    local combatIndicator = CreateCheckbox("combatIndicator", "Combat Indicator", BetterBlizzFrames)
    combatIndicator:SetPoint("TOPLEFT", extraFeaturesText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    combatIndicator:HookScript("OnClick", function()
        BBF.CombatIndicatorCaller()
    end)
    CreateTooltip(combatIndicator, "Show combat status on Player, Target and Focus Frame.\nSword icon for combat, Sap icon for no combat.\nMore settings in \"Advanced Settings\"")

    local absorbIndicator = CreateCheckbox("absorbIndicator", "Absorb Indicator", BetterBlizzFrames, nil, BBF.AbsorbCaller)
    absorbIndicator:SetPoint("TOPLEFT", combatIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    absorbIndicator:HookScript("OnClick", function()
        BBF.AbsorbCaller()
    end)
    CreateTooltip(absorbIndicator, "Show absorb amount on Player, Target and Focus Frame\nMore settings in \"Advanced Settings\"")
    --notWorking(absorbIndicator, true)

    local racialIndicator = CreateCheckbox("racialIndicator", "PvP Racial Indicator", BetterBlizzFrames, nil, BBF.RacialIndicatorCaller)
    racialIndicator:SetPoint("TOPLEFT", absorbIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    racialIndicator:HookScript("OnClick", function()
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicator, "Show important PvP racial icons on Target/Focus Frame")

    local overShields = CreateCheckbox("overShields", "Overshields", BetterBlizzFrames)
    overShields:SetPoint("TOPLEFT", racialIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(overShields, "Show shield amount on UnitFrames", "ANCHOR_LEFT")

    -- local overShieldsUnitFrames = CreateCheckbox("overShieldsUnitFrames", "A", BetterBlizzFrames)
    -- overShieldsUnitFrames:SetPoint("LEFT", overShields.text, "RIGHT", 0, 0)
    -- CreateTooltip(overShieldsUnitFrames, "Show Overshields on UnitFrames (Player, Target, Focus)", "ANCHOR_LEFT")
    -- overShieldsUnitFrames:HookScript("OnClick", function(self)
    --     BBF.HookOverShields()
    --     StaticPopup_Show("BBF_CONFIRM_RELOAD")
    -- end)

    -- local overShieldsCompactUnitFrames = CreateCheckbox("overShieldsCompactUnitFrames", "B", BetterBlizzFrames)
    -- overShieldsCompactUnitFrames:SetPoint("LEFT", overShieldsUnitFrames.text, "RIGHT", 0, 0)
    -- CreateTooltip(overShieldsCompactUnitFrames, "Show Overshields on Compact UnitFrames (Party, Raid)", "ANCHOR_LEFT")
    -- overShieldsCompactUnitFrames:HookScript("OnClick", function(self)
    --     BBF.HookOverShields()
    --     StaticPopup_Show("BBF_CONFIRM_RELOAD")
    -- end)

    overShields:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzFramesDB.overShieldsCompact = true
            BetterBlizzFramesDB.overShieldsUnitFrames = true
            BBF.HookOverShields()
            -- overShieldsUnitFrames:SetAlpha(1)
            -- overShieldsUnitFrames:Enable()
            -- overShieldsUnitFrames:SetChecked(true)
            -- overShieldsCompactUnitFrames:SetAlpha(1)
            -- overShieldsCompactUnitFrames:Enable()
            -- overShieldsCompactUnitFrames:SetChecked(true)
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        else
            BetterBlizzFramesDB.overShieldsCompact = false
            BetterBlizzFramesDB.overShieldsUnitFrames = false
            -- overShieldsUnitFrames:SetAlpha(0)
            -- overShieldsUnitFrames:Disable()
            -- overShieldsUnitFrames:SetChecked(false)
            -- overShieldsCompactUnitFrames:SetAlpha(0)
            -- overShieldsCompactUnitFrames:Disable()
            -- overShieldsCompactUnitFrames:SetChecked(false)
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    -- if BetterBlizzFramesDB.overShields then
    --     overShieldsUnitFrames:SetAlpha(1)
    --     overShieldsUnitFrames:Enable()
    --     overShieldsCompactUnitFrames:SetAlpha(1)
    --     overShieldsCompactUnitFrames:Enable()
    -- else
    --     overShieldsUnitFrames:SetAlpha(0)
    --     overShieldsUnitFrames:Disable()
    --     overShieldsCompactUnitFrames:SetAlpha(0)
    --     overShieldsCompactUnitFrames:Disable()
    -- end

    ----------------------
    -- Reload etc
    ----------------------
    local reloadUiButton = CreateFrame("Button", nil, BetterBlizzFrames, "UIPanelButtonTemplate")
    reloadUiButton:SetText("Reload UI")
    reloadUiButton:SetWidth(85)
    reloadUiButton:SetPoint("TOP", BetterBlizzFrames, "BOTTOMRIGHT", -140, -9)
    reloadUiButton:SetScript("OnClick", function()
        BetterBlizzFramesDB.reopenOptions = true
        ReloadUI()
    end)

    local nahjProfileButton = CreateFrame("Button", nil, BetterBlizzFrames, "UIPanelButtonTemplate")
    nahjProfileButton:SetText("Nahj Profile")
    nahjProfileButton:SetWidth(100)
    nahjProfileButton:Hide()
    nahjProfileButton:SetPoint("RIGHT", reloadUiButton, "LEFT", -50, 0)
    -- nahjProfileButton:SetScript("OnClick", function()
    --     StaticPopup_Show("BBF_CONFIRM_NAHJ_PROFILE")
    -- end)
    -- CreateTooltipTwo(nahjProfileButton, "Nahj Profile", "Enable all of Nahj's profile settings.", "www.twitch.tv/nahj", "ANCHOR_TOP")

    -- local magnuszProfileButton = CreateFrame("Button", nil, BetterBlizzFrames, "UIPanelButtonTemplate")
    -- magnuszProfileButton:SetText("Magnusz Profile")
    -- magnuszProfileButton:SetWidth(120)
    -- magnuszProfileButton:SetPoint("RIGHT", nahjProfileButton, "LEFT", -5, 0)
    -- magnuszProfileButton:SetScript("OnClick", function()
    --     StaticPopup_Show("BBF_CONFIRM_MAGNUSZ_PROFILE")
    -- end)
    -- CreateTooltipTwo(magnuszProfileButton, "Magnusz Profile", "Enable all of Magnusz's profile settings.", "www.twitch.tv/magnusz", "ANCHOR_TOP")

    local resetBBFButton = CreateFrame("Button", nil, BetterBlizzFrames, "UIPanelButtonTemplate")
    resetBBFButton:SetText("Reset BetterBlizzFrames")
    resetBBFButton:SetWidth(165)
    resetBBFButton:SetPoint("RIGHT", nahjProfileButton, "LEFT", -180, 0)
    resetBBFButton:SetScript("OnClick", function()
        StaticPopup_Show("CONFIRM_RESET_BETTERBLIZZFRAMESDB")
    end)
    CreateTooltip(resetBBFButton, "Reset ALL BetterBlizzFrames settings.")


    local alphaWarn = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    alphaWarn:SetPoint("LEFT", resetBBFButton, "RIGHT", 5, 0)
    alphaWarn:SetText("BETA (Expect things to be buggy, use BugGrabber)")
end

local function guiCastbars()

    ----------------------
    -- Advanced settings
    ----------------------
    local firstLineX = 53
    local firstLineY = -65
    local secondLineX = 222
    local secondLineY = -360
    local thirdLineX = 391
    local thirdLineY = -655
    local fourthLineX = 560

    local BetterBlizzFramesCastbars = CreateFrame("Frame")
    BetterBlizzFramesCastbars.name = "Castbars"
    BetterBlizzFramesCastbars.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(BetterBlizzFramesCastbars)
    local castbarsSubCategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, BetterBlizzFramesCastbars, BetterBlizzFramesCastbars.name, BetterBlizzFramesCastbars.name)
    castbarsSubCategory.ID = BetterBlizzFramesCastbars.name;
    CreateTitle(BetterBlizzFramesCastbars)

    local bgImg = BetterBlizzFramesCastbars:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", BetterBlizzFramesCastbars, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)





    local scrollFrame = CreateFrame("ScrollFrame", nil, BetterBlizzFramesCastbars, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(700, 612)
    scrollFrame:SetPoint("CENTER", BetterBlizzFramesCastbars, "CENTER", -20, 3)

    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(680, 520)
    scrollFrame:SetScrollChild(contentFrame)

    local mainGuiAnchor2 = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor2:SetPoint("TOPLEFT", 55, 20)
    mainGuiAnchor2:SetText(" ")

   ----------------------
    -- Party Castbars
    ----------------------
    local anchorSubPartyCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPartyCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, firstLineY+30)
    anchorSubPartyCastbar:SetText("Party Castbars")

    local partyCastbarBorder = CreateBorderedFrame(anchorSubPartyCastbar, 157, 386, 0, -175, contentFrame)

    local partyCastbars = contentFrame:CreateTexture(nil, "ARTWORK")
    partyCastbars:SetAtlas("ui-castingbar-filling-channel")
    partyCastbars:SetSize(110, 13)
    partyCastbars:SetPoint("BOTTOM", anchorSubPartyCastbar, "TOP", -1, 10)

    local partyCastBarScale = CreateSlider(contentFrame, "Size", 0.5, 1.9, 0.01, "partyCastBarScale")
    partyCastBarScale:SetPoint("TOP", anchorSubPartyCastbar, "BOTTOM", 0, -15)

    local partyCastBarXPos = CreateSlider(contentFrame, "x offset", -200, 200, 1, "partyCastBarXPos", "X")
    partyCastBarXPos:SetPoint("TOP", partyCastBarScale, "BOTTOM", 0, -15)

    local partyCastBarYPos = CreateSlider(contentFrame, "y offset", -200, 200, 1, "partyCastBarYPos", "Y")
    partyCastBarYPos:SetPoint("TOP", partyCastBarXPos, "BOTTOM", 0, -15)

    local partyCastBarWidth = CreateSlider(contentFrame, "Width", 20, 200, 1, "partyCastBarWidth")
    partyCastBarWidth:SetPoint("TOP", partyCastBarYPos, "BOTTOM", 0, -15)

    local partyCastBarHeight = CreateSlider(contentFrame, "Height", 5, 30, 1, "partyCastBarHeight")
    partyCastBarHeight:SetPoint("TOP", partyCastBarWidth, "BOTTOM", 0, -15)

    local partyCastBarIconScale = CreateSlider(contentFrame, "Icon Size", 0.4, 2, 0.01, "partyCastBarIconScale")
    partyCastBarIconScale:SetPoint("TOP", partyCastBarHeight, "BOTTOM", 0, -15)

    local partyCastbarIconXPos = CreateSlider(contentFrame, "Icon x offset", -50, 50, 1, "partyCastbarIconXPos")
    partyCastbarIconXPos:SetPoint("TOP", partyCastBarIconScale, "BOTTOM", 0, -15)

    local partyCastbarIconYPos = CreateSlider(contentFrame, "Icon y offset", -50, 50, 1, "partyCastbarIconYPos")
    partyCastbarIconYPos:SetPoint("TOP", partyCastbarIconXPos, "BOTTOM", 0, -15)

    local partyCastBarTestMode = CreateCheckbox("partyCastBarTestMode", "Test", contentFrame, nil, BBF.partyCastBarTestMode)
    partyCastBarTestMode:SetPoint("TOPLEFT", partyCastbarIconYPos, "BOTTOMLEFT", 10, -4)
    CreateTooltip(partyCastBarTestMode, "Need to be in party to test")

    local partyCastBarTimer = CreateCheckbox("partyCastBarTimer", "Timer", contentFrame, nil, BBF.partyCastBarTestMode)
    partyCastBarTimer:SetPoint("LEFT", partyCastBarTestMode.Text, "RIGHT", 10, 0)
    CreateTooltip(partyCastBarTimer, "Show cast timer next to the castbar.")

    local partyCastbarSelf = CreateCheckbox("partyCastbarSelf", "Self", contentFrame, nil, BBF.partyCastBarTestMode)
    partyCastbarSelf:SetPoint("TOPLEFT", partyCastBarTimer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(partyCastbarSelf, "Show castbar on party frame belonging to yourself as well.")

    local showPartyCastBarIcon = CreateCheckbox("showPartyCastBarIcon", "Icon", contentFrame, nil, BBF.partyCastBarTestMode)
    showPartyCastBarIcon:SetPoint("TOPLEFT", partyCastBarTestMode, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local partyCastbarShowText = CreateCheckbox("partyCastbarShowText", "Text", contentFrame, nil, BBF.partyCastBarTestMode)
    partyCastbarShowText:SetPoint("TOPLEFT", showPartyCastBarIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(partyCastbarShowText, "Show Castbar Text", "Show castbar text with spellname")

    local partyCastbarShowBorder = CreateCheckbox("partyCastbarShowBorder", "Border", contentFrame, nil, BBF.partyCastBarTestMode)
    partyCastbarShowBorder:SetPoint("TOPLEFT", partyCastbarSelf, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(partyCastbarShowBorder, "Show Castbar Borders", "Show castbar borders")

    local resetPartyCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetPartyCastbar:SetText("Reset")
    resetPartyCastbar:SetWidth(70)
    resetPartyCastbar:SetPoint("TOP", partyCastbarBorder, "BOTTOM", 0, -2)
    resetPartyCastbar:SetScript("OnClick", function()
        partyCastBarScale:SetValue(1)
        partyCastBarIconScale:SetValue(1)
        partyCastBarXPos:SetValue(0)
        partyCastBarYPos:SetValue(0)
        partyCastbarIconXPos:SetValue(0)
        partyCastbarIconYPos:SetValue(0)
        partyCastBarWidth:SetValue(100)
        partyCastBarHeight:SetValue(12)
        partyCastBarTimer:SetChecked(true)
        BetterBlizzFramesDB.partyCastBarTimer = true
        BBF.CastBarTimerCaller()
    end)


   ----------------------
    -- Target Castbar
    ----------------------
    local anchorSubTargetCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTargetCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, firstLineY+30)
    anchorSubTargetCastbar:SetText("Target Castbar")

    local targetCastbarBorder = CreateBorderedFrame(anchorSubTargetCastbar, 157, 386, 0, -175, contentFrame)

    local targetCastBar = contentFrame:CreateTexture(nil, "ARTWORK")
    targetCastBar:SetAtlas("ui-castingbar-tier1-empower-2x")
    targetCastBar:SetSize(110, 13)
    targetCastBar:SetPoint("BOTTOM", anchorSubTargetCastbar, "TOP", -1, 10)

    local targetCastBarScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "targetCastBarScale")
    targetCastBarScale:SetPoint("TOP", anchorSubTargetCastbar, "BOTTOM", 0, -15)

    local targetCastBarXPos = CreateSlider(contentFrame, "x offset", -130, 130, 1, "targetCastBarXPos", "X")
    targetCastBarXPos:SetPoint("TOP", targetCastBarScale, "BOTTOM", 0, -15)

    local targetCastBarYPos = CreateSlider(contentFrame, "y offset", -130, 130, 1, "targetCastBarYPos", "Y")
    targetCastBarYPos:SetPoint("TOP", targetCastBarXPos, "BOTTOM", 0, -15)

    local targetCastBarWidth = CreateSlider(contentFrame, "Width", 60, 220, 1, "targetCastBarWidth")
    targetCastBarWidth:SetPoint("TOP", targetCastBarYPos, "BOTTOM", 0, -15)

    local targetCastBarHeight = CreateSlider(contentFrame, "Height", 5, 30, 1, "targetCastBarHeight")
    targetCastBarHeight:SetPoint("TOP", targetCastBarWidth, "BOTTOM", 0, -15)

    local targetCastBarIconScale = CreateSlider(contentFrame, "Icon Size", 0.4, 2, 0.01, "targetCastBarIconScale")
    targetCastBarIconScale:SetPoint("TOP", targetCastBarHeight, "BOTTOM", 0, -15)

    local targetCastbarIconXPos = CreateSlider(contentFrame, "Icon x offset", -160, 160, 1, "targetCastbarIconXPos", "X")
    targetCastbarIconXPos:SetPoint("TOP", targetCastBarIconScale, "BOTTOM", 0, -15)

    local targetCastbarIconYPos = CreateSlider(contentFrame, "Icon y offset", -160, 160, 1, "targetCastbarIconYPos", "Y")
    targetCastbarIconYPos:SetPoint("TOP", targetCastbarIconXPos, "BOTTOM", 0, -15)

    local targetStaticCastbar = CreateCheckbox("targetStaticCastbar", "Static", contentFrame)
    targetStaticCastbar:SetPoint("TOPLEFT", targetCastbarIconYPos, "BOTTOMLEFT", 10, -4)
    CreateTooltip(targetStaticCastbar, "Lock the castbar in place on its frame.\nNo longer moves depending on aura amount.")

    local targetCastBarTimer = CreateCheckbox("targetCastBarTimer", "Timer", contentFrame, nil, BBF.CastBarTimerCaller)
    targetCastBarTimer:SetPoint("LEFT", targetStaticCastbar.Text, "RIGHT", 10, 0)
    CreateTooltip(targetCastBarTimer, "Show cast timer next to the castbar.")

    local targetToTCastbarAdjustment = CreateCheckbox("targetToTCastbarAdjustment", "ToT Offset", contentFrame)
    targetToTCastbarAdjustment:SetPoint("TOPLEFT", targetStaticCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(targetToTCastbarAdjustment, "ToT Offset", "Pushes the castbar down below the ToT frame. Assumes default location. Uncheck this if you have moved tot elsewhere and not need this.")

    local targetToTAdjustmentOffsetY = CreateSlider(targetToTCastbarAdjustment, "extra", -20, 50, 1, "targetToTAdjustmentOffsetY", "Y", 55)
    targetToTAdjustmentOffsetY:SetPoint("LEFT", targetToTCastbarAdjustment.text, "RIGHT", 2, -5)
    CreateTooltip(targetToTAdjustmentOffsetY, "Extra finetuning for ToT Y offset\n(Right click any slider to input value)")

    targetToTCastbarAdjustment:HookScript("OnClick", function(self)
        if self:GetChecked() then
            targetToTAdjustmentOffsetY:Enable()
            targetToTAdjustmentOffsetY:SetAlpha(1)
        else
            targetToTAdjustmentOffsetY:Disable()
            targetToTAdjustmentOffsetY:SetAlpha(0.5)
        end
    end)

    if BetterBlizzFramesDB.targetDetachCastbar then
        BetterBlizzFramesDB.targetDetachCastbar = false
    end
    local targetDetachCastbar = CreateCheckbox("targetDetachCastbar", "Detach from frame", contentFrame)
    targetDetachCastbar:SetPoint("TOPLEFT", targetToTCastbarAdjustment, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    targetDetachCastbar:HookScript("OnClick", function(self)
        if self:GetChecked() then
            targetCastBarXPos:SetMinMaxValues(-900, 900)
            targetCastBarXPos:SetValue(0)
            targetCastBarYPos:SetMinMaxValues(-900, 900)
            targetCastBarYPos:SetValue(0)
            targetToTCastbarAdjustment:Disable()
            targetToTCastbarAdjustment:SetAlpha(0.5)
            targetToTAdjustmentOffsetY:Disable()
            targetToTAdjustmentOffsetY:SetAlpha(0.5)
            targetStaticCastbar:SetChecked(false)
            BetterBlizzFramesDB.targetStaticCastbar = false
        else
            targetCastBarXPos:SetMinMaxValues(-130, 130)
            targetCastBarXPos:SetValue(0)
            targetToTCastbarAdjustment:Enable()
            targetToTCastbarAdjustment:SetAlpha(1)
            targetToTAdjustmentOffsetY:Enable()
            targetToTAdjustmentOffsetY:SetAlpha(1)
        end
    end)
    CreateTooltip(targetDetachCastbar, "Detach castbar from frame and enable wider xy positioning.\nRight-click a slider to enter a specific number.")
    notWorking(targetDetachCastbar, true)

    if BetterBlizzFramesDB.targetDetachCastbar then
        targetCastBarXPos:SetMinMaxValues(-900, 900)
        targetCastBarXPos:SetValue(0)
        targetCastBarYPos:SetMinMaxValues(-900, 900)
        targetCastBarYPos:SetValue(0)
        targetToTCastbarAdjustment:Disable()
        targetToTCastbarAdjustment:SetAlpha(0.5)
        targetToTAdjustmentOffsetY:Disable()
        targetToTAdjustmentOffsetY:SetAlpha(0.5)
        targetStaticCastbar:SetChecked(false)
        BetterBlizzFramesDB.targetStaticCastbar = false
    end
    targetStaticCastbar:HookScript("OnClick", function(self)
        if self:GetChecked() then
            targetToTCastbarAdjustment:Disable()
            targetToTCastbarAdjustment:SetAlpha(0.5)
            targetToTAdjustmentOffsetY:Disable()
            targetToTAdjustmentOffsetY:SetAlpha(0.5)
            targetDetachCastbar:SetChecked(false)
            BetterBlizzFramesDB.targetDetachCastbar = false
        else
            targetToTCastbarAdjustment:Enable()
            targetToTCastbarAdjustment:SetAlpha(1)
            targetToTAdjustmentOffsetY:Enable()
            targetToTAdjustmentOffsetY:SetAlpha(1)
        end
    end)
    if BetterBlizzFramesDB.targetStaticCastbar then
        targetToTCastbarAdjustment:Disable()
        targetToTCastbarAdjustment:SetAlpha(0.5)
        targetToTAdjustmentOffsetY:Disable()
        targetToTAdjustmentOffsetY:SetAlpha(0.5)
        targetDetachCastbar:SetChecked(false)
        BetterBlizzFramesDB.targetDetachCastbar = false
    end

    local targetCastBarShowText = CreateCheckbox("targetCastBarShowText", "Text", contentFrame, nil, BBF.ChangeCastbarSizes)
    targetCastBarShowText:SetPoint("TOPLEFT", targetDetachCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(targetCastBarShowText, "Show Castbar Text", "Show castbar text with spellname")

    local targetCastBarShowBorder = CreateCheckbox("targetCastBarShowBorder", "Border", contentFrame, nil, BBF.ChangeCastbarSizes)
    targetCastBarShowBorder:SetPoint("LEFT", targetCastBarShowText.text, "RIGHT", 5, 0)
    CreateTooltipTwo(targetCastBarShowBorder, "Show Castbar Border", "Show castbar borders. If unchecked it will still show uninterruptible border.")

    local resetTargetCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetTargetCastbar:SetText("Reset")
    resetTargetCastbar:SetWidth(70)
    resetTargetCastbar:SetPoint("TOP", targetCastbarBorder, "BOTTOM", 0, -2)
    resetTargetCastbar:SetScript("OnClick", function()
        targetCastBarScale:SetValue(1)
        targetCastBarIconScale:SetValue(1)
        targetCastBarXPos:SetValue(0)
        targetCastBarYPos:SetValue(0)
        targetCastbarIconXPos:SetValue(0)
        targetCastbarIconYPos:SetValue(0)
        targetCastBarWidth:SetValue(150)
        targetCastBarHeight:SetValue(10)
        targetCastBarTimer:SetChecked(false)
        BetterBlizzFramesDB.targetCastBarTimer = false
        targetStaticCastbar:SetChecked(false)
        BetterBlizzFramesDB.targetStaticCastbar = false
        targetDetachCastbar:SetChecked(false)
        BetterBlizzFramesDB.targetDetachCastbar = false
        targetCastBarShowText:SetChecked(true)
        BetterBlizzFramesDB.targetCastBarShowText = true
        targetCastBarShowBorder:SetChecked(true)
        BetterBlizzFramesDB.targetCastBarShowBorder = true
        targetToTCastbarAdjustment:Enable()
        targetToTCastbarAdjustment:SetAlpha(1)
        targetToTCastbarAdjustment:SetChecked(true)
        targetToTAdjustmentOffsetY:Enable()
        targetToTAdjustmentOffsetY:SetValue(0)
        BetterBlizzFramesDB.targetToTCastbarAdjustment = true
        BBF.CastBarTimerCaller()
    end)


    ----------------------
    -- Pet Castbars
    ----------------------
    local anchorSubPetCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPetCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, secondLineY - 90)
    anchorSubPetCastbar:SetText("Pet Castbar")

    local petCastbarBorder = CreateBorderedFrame(anchorSubPetCastbar, 157, 320, 0, -142, contentFrame)

    local petCastbars = contentFrame:CreateTexture(nil, "ARTWORK")
    petCastbars:SetAtlas("ui-castingbar-filling-channel")
    petCastbars:SetDesaturated(true)
    petCastbars:SetVertexColor(1, 0.25, 0.98)
    petCastbars:SetSize(110, 13)
    petCastbars:SetPoint("BOTTOM", anchorSubPetCastbar, "TOP", -1, 10)

    local petCastBarScale = CreateSlider(contentFrame, "Size", 0.5, 1.9, 0.01, "petCastBarScale")
    petCastBarScale:SetPoint("TOP", anchorSubPetCastbar, "BOTTOM", 0, -15)

    local petCastBarXPos = CreateSlider(contentFrame, "x offset", -200, 200, 1, "petCastBarXPos", "X")
    petCastBarXPos:SetPoint("TOP", petCastBarScale, "BOTTOM", 0, -15)

    local petCastBarYPos = CreateSlider(contentFrame, "y offset", -200, 200, 1, "petCastBarYPos", "Y")
    petCastBarYPos:SetPoint("TOP", petCastBarXPos, "BOTTOM", 0, -15)

    local petCastBarWidth = CreateSlider(contentFrame, "Width", 20, 200, 1, "petCastBarWidth")
    petCastBarWidth:SetPoint("TOP", petCastBarYPos, "BOTTOM", 0, -15)

    local petCastBarHeight = CreateSlider(contentFrame, "Height", 5, 30, 1, "petCastBarHeight")
    petCastBarHeight:SetPoint("TOP", petCastBarWidth, "BOTTOM", 0, -15)

    local petCastBarIconScale = CreateSlider(contentFrame, "Icon Size", 0.4, 2, 0.01, "petCastBarIconScale")
    petCastBarIconScale:SetPoint("TOP", petCastBarHeight, "BOTTOM", 0, -15)

    local petCastBarTestMode = CreateCheckbox("petCastBarTestMode", "Test", contentFrame, nil, BBF.petCastBarTestMode)
    petCastBarTestMode:SetPoint("TOPLEFT", petCastBarIconScale, "BOTTOMLEFT", 10, -4)
    CreateTooltip(petCastBarTestMode, "Need pet to test.")

    local petCastBarTimer = CreateCheckbox("petCastBarTimer", "Timer", contentFrame, nil, BBF.petCastBarTestMode)
    petCastBarTimer:SetPoint("LEFT", petCastBarTestMode.Text, "RIGHT", 10, 0)
    CreateTooltip(petCastBarTimer, "Show cast timer next to the castbar.")

    local showPetCastBarIcon = CreateCheckbox("showPetCastBarIcon", "Icon", contentFrame, nil, BBF.petCastBarTestMode)
    showPetCastBarIcon:SetPoint("TOPLEFT", petCastBarTestMode, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local petDetachCastbar = CreateCheckbox("petDetachCastbar", "Detach from frame", contentFrame, nil, BBF.petCastBarTestMode)
    petDetachCastbar:SetPoint("TOPLEFT", showPetCastBarIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    petDetachCastbar:HookScript("OnClick", function(self)
        if self:GetChecked() then
            petCastBarXPos:SetMinMaxValues(-900, 900)
            petCastBarXPos:SetValue(0)
            petCastBarYPos:SetMinMaxValues(-900, 900)
            petCastBarYPos:SetValue(0)
        else
            petCastBarXPos:SetMinMaxValues(-130, 130)
            petCastBarXPos:SetValue(0)
        end
        BBF.petCastBarTestMode()
    end)
    CreateTooltip(petDetachCastbar, "Detach castbar from frame and enable wider xy positioning.\nRight-click a slider to enter a specific number.")

    local petCastBarShowText = CreateCheckbox("petCastBarShowText", "Text", contentFrame, nil, BBF.partyCastBarTestMode)
    petCastBarShowText:SetPoint("TOPLEFT", petDetachCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(petCastBarShowText, "Show Castbar Text", "Show castbar text with spellname")

    local petCastBarShowBorder = CreateCheckbox("petCastBarShowBorder", "Border", contentFrame, nil, BBF.partyCastBarTestMode)
    petCastBarShowBorder:SetPoint("TOPLEFT", petCastBarTimer, "BOTTOMLEFT", 0, -32)
    CreateTooltipTwo(petCastBarShowBorder, "Show Castbar Border", "Show castbar borders. If unchecked it will still show uninterruptible border.")

    if BetterBlizzFramesDB.petDetachCastbar then
        petCastBarXPos:SetMinMaxValues(-900, 900)
        petCastBarXPos:SetValue(0)
        petCastBarYPos:SetMinMaxValues(-900, 900)
        petCastBarYPos:SetValue(0)
    end

    local resetpetCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetpetCastbar:SetText("Reset")
    resetpetCastbar:SetWidth(70)
    resetpetCastbar:SetPoint("TOP", petCastbarBorder, "BOTTOM", 0, -2)
    resetpetCastbar:SetScript("OnClick", function()
        petCastBarScale:SetValue(1)
        petCastBarIconScale:SetValue(1)
        petCastBarXPos:SetValue(0)
        petCastBarYPos:SetValue(0)
        petCastBarWidth:SetValue(100)
        petCastBarHeight:SetValue(12)
        petCastBarTimer:SetChecked(true)
        petCastBarShowText:SetChecked(true)
        petCastBarShowBorder:SetChecked(true)
        petDetachCastbar:SetChecked(false)
        BetterBlizzFramesDB.petCastBarShowText = true
        BetterBlizzFramesDB.petCastBarShowBorder = true
        BetterBlizzFramesDB.petDetachCastbar = false
        BetterBlizzFramesDB.petCastBarTimer = true
        BBF.CastBarTimerCaller()
    end)

   ----------------------
    -- Focus Castbar
    ----------------------
    local anchorSubFocusCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubFocusCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, firstLineY+30)
    anchorSubFocusCastbar:SetText("Focus Castbar")

    local focusCastbarBorder = CreateBorderedFrame(anchorSubFocusCastbar, 157, 386, 0, -175, contentFrame)

    local focusCastBar = contentFrame:CreateTexture(nil, "ARTWORK")
    focusCastBar:SetAtlas("ui-castingbar-full-applyingcrafting")
    focusCastBar:SetSize(110, 16)
    focusCastBar:SetPoint("BOTTOM", anchorSubFocusCastbar, "TOP", -1, 8.5)

    local focusCastBarScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "focusCastBarScale")
    focusCastBarScale:SetPoint("TOP", anchorSubFocusCastbar, "BOTTOM", 0, -15)

    local focusCastBarXPos = CreateSlider(contentFrame, "x offset", -130, 130, 1, "focusCastBarXPos", "X")
    focusCastBarXPos:SetPoint("TOP", focusCastBarScale, "BOTTOM", 0, -15)

    local focusCastBarYPos = CreateSlider(contentFrame, "y offset", -130, 130, 1, "focusCastBarYPos", "Y")
    focusCastBarYPos:SetPoint("TOP", focusCastBarXPos, "BOTTOM", 0, -15)

    local focusCastBarWidth = CreateSlider(contentFrame, "Width", 60, 220, 1, "focusCastBarWidth")
    focusCastBarWidth:SetPoint("TOP", focusCastBarYPos, "BOTTOM", 0, -15)

    local focusCastBarHeight = CreateSlider(contentFrame, "Height", 5, 30, 1, "focusCastBarHeight")
    focusCastBarHeight:SetPoint("TOP", focusCastBarWidth, "BOTTOM", 0, -15)

    local focusCastBarIconScale = CreateSlider(contentFrame, "Icon Size", 0.4, 2, 0.01, "focusCastBarIconScale")
    focusCastBarIconScale:SetPoint("TOP", focusCastBarHeight, "BOTTOM", 0, -15)

    local focusCastbarIconXPos = CreateSlider(contentFrame, "Icon x offset", -160, 160, 1, "focusCastbarIconXPos", "X")
    focusCastbarIconXPos:SetPoint("TOP", focusCastBarIconScale, "BOTTOM", 0, -15)

    local focusCastbarIconYPos = CreateSlider(contentFrame, "Icon y offset", -160, 160, 1, "focusCastbarIconYPos", "Y")
    focusCastbarIconYPos:SetPoint("TOP", focusCastbarIconXPos, "BOTTOM", 0, -15)

    local focusStaticCastbar = CreateCheckbox("focusStaticCastbar", "Static", contentFrame)
    focusStaticCastbar:SetPoint("TOPLEFT", focusCastbarIconYPos, "BOTTOMLEFT", 10, -4)
    CreateTooltip(focusStaticCastbar, "Lock the castbar in place on its frame.\nNo longer moves depending on aura amount.")

    local focusCastBarTimer = CreateCheckbox("focusCastBarTimer", "Timer", contentFrame, nil, BBF.CastBarTimerCaller)
    focusCastBarTimer:SetPoint("LEFT", focusStaticCastbar.Text, "RIGHT", 10, 0)
    CreateTooltip(focusCastBarTimer, "Show cast timer next to the castbar.")

    local focusToTCastbarAdjustment = CreateCheckbox("focusToTCastbarAdjustment", "ToT Offset", contentFrame)
    focusToTCastbarAdjustment:SetPoint("TOPLEFT", focusStaticCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(focusToTCastbarAdjustment, "ToT Offset", "Pushes the castbar down below the focus ToT frame. Assumes default location. Uncheck this if you have moved tot elsewhere and not need this.")

    local focusToTAdjustmentOffsetY = CreateSlider(focusToTCastbarAdjustment, "extra", -20, 50, 1, "focusToTAdjustmentOffsetY", "Y", 55)
    focusToTAdjustmentOffsetY:SetPoint("LEFT", focusToTCastbarAdjustment.text, "RIGHT", 2, -5)
    CreateTooltip(focusToTAdjustmentOffsetY, "Extra finetuning for ToT Y offset\n(Right click any slider to input value)")

    focusToTCastbarAdjustment:HookScript("OnClick", function(self)
        if self:GetChecked() then
            focusToTAdjustmentOffsetY:Enable()
            focusToTAdjustmentOffsetY:SetAlpha(1)
        else
            focusToTAdjustmentOffsetY:Disable()
            focusToTAdjustmentOffsetY:SetAlpha(0.5)
        end
    end)

    if BetterBlizzFramesDB.focusDetachCastbar then
        BetterBlizzFramesDB.focusDetachCastbar = false
    end
    local focusDetachCastbar = CreateCheckbox("focusDetachCastbar", "Detach from frame", contentFrame)
    focusDetachCastbar:SetPoint("TOPLEFT", focusToTCastbarAdjustment, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    focusDetachCastbar:HookScript("OnClick", function(self)
        if self:GetChecked() then
            focusCastBarXPos:SetMinMaxValues(-900, 900)
            focusCastBarXPos:SetValue(0)
            focusCastBarYPos:SetMinMaxValues(-900, 900)
            focusCastBarYPos:SetValue(0)
            focusToTCastbarAdjustment:Disable()
            focusToTCastbarAdjustment:SetAlpha(0.5)
            focusToTAdjustmentOffsetY:Disable()
            focusToTAdjustmentOffsetY:SetAlpha(0.5)
            focusStaticCastbar:SetChecked(false)
            BetterBlizzFramesDB.focusStaticCastbar = false
        else
            focusCastBarXPos:SetMinMaxValues(-130, 130)
            focusCastBarXPos:SetValue(0)
            focusToTCastbarAdjustment:Enable()
            focusToTCastbarAdjustment:SetAlpha(1)
            focusToTAdjustmentOffsetY:Enable()
            focusToTAdjustmentOffsetY:SetAlpha(1)
        end
    end)
    CreateTooltip(focusDetachCastbar, "Detach castbar from frame and enable wider xy positioning.\nRight-click a slider to enter a specific number.")
    notWorking(focusDetachCastbar, true)

    if BetterBlizzFramesDB.focusDetachCastbar then
        focusCastBarXPos:SetMinMaxValues(-900, 900)
        focusCastBarXPos:SetValue(0)
        focusCastBarYPos:SetMinMaxValues(-900, 900)
        focusCastBarYPos:SetValue(0)
        focusToTCastbarAdjustment:Disable()
        focusToTCastbarAdjustment:SetAlpha(0.5)
        focusToTAdjustmentOffsetY:Disable()
        focusToTAdjustmentOffsetY:SetAlpha(0.5)
        focusStaticCastbar:SetChecked(false)
        BetterBlizzFramesDB.focusStaticCastbar = false
    end
    focusStaticCastbar:HookScript("OnClick", function(self)
        if self:GetChecked() then
            focusToTCastbarAdjustment:Disable()
            focusToTCastbarAdjustment:SetAlpha(0.5)
            focusToTAdjustmentOffsetY:Disable()
            focusToTAdjustmentOffsetY:SetAlpha(0.5)
            focusDetachCastbar:SetChecked(false)
        else
            focusToTCastbarAdjustment:Enable()
            focusToTCastbarAdjustment:SetAlpha(1)
            focusToTAdjustmentOffsetY:Enable()
            focusToTAdjustmentOffsetY:SetAlpha(1)
        end
    end)
    if BetterBlizzFramesDB.focusStaticCastbar then
        focusToTCastbarAdjustment:Disable()
        focusToTCastbarAdjustment:SetAlpha(0.5)
        focusToTAdjustmentOffsetY:Disable()
        focusToTAdjustmentOffsetY:SetAlpha(0.5)
        focusDetachCastbar:SetChecked(false)
        BetterBlizzFramesDB.focusDetachCastbar = false
    end

    local focusCastBarShowText = CreateCheckbox("focusCastBarShowText", "Text", contentFrame, nil, BBF.ChangeCastbarSizes)
    focusCastBarShowText:SetPoint("TOPLEFT", focusDetachCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(focusCastBarShowText, "Show Castbar Text", "Show castbar text with spellname")

    local focusCastBarShowBorder = CreateCheckbox("focusCastBarShowBorder", "Border", contentFrame, nil, BBF.ChangeCastbarSizes)
    focusCastBarShowBorder:SetPoint("LEFT", focusCastBarShowText.text, "RIGHT", 5, 0)
    CreateTooltipTwo(focusCastBarShowBorder, "Show Castbar Border", "Show castbar borders. If unchecked it will still show uninterruptible border.")

    local resetFocusCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetFocusCastbar:SetText("Reset")
    resetFocusCastbar:SetWidth(70)
    resetFocusCastbar:SetPoint("TOP", focusCastbarBorder, "BOTTOM", 0, -2)
    resetFocusCastbar:SetScript("OnClick", function()
        focusCastBarScale:SetValue(1)
        focusCastBarIconScale:SetValue(1)
        focusCastBarXPos:SetValue(0)
        focusCastBarYPos:SetValue(0)
        focusCastbarIconXPos:SetValue(0)
        focusCastbarIconYPos:SetValue(0)
        focusCastBarWidth:SetValue(150)
        focusCastBarHeight:SetValue(10)
        focusCastBarTimer:SetChecked(false)
        BetterBlizzFramesDB.focusCastBarTimer = false
        focusStaticCastbar:SetChecked(false)
        BetterBlizzFramesDB.focusStaticCastbar = false
        focusDetachCastbar:SetChecked(false)
        BetterBlizzFramesDB.focusDetachCastbar = false
        focusCastBarShowText:SetChecked(true)
        BetterBlizzFramesDB.focusCastBarShowText = true
        focusCastBarShowBorder:SetChecked(true)
        BetterBlizzFramesDB.focusCastBarShowBorder = true
        focusToTCastbarAdjustment:Enable()
        focusToTCastbarAdjustment:SetAlpha(1)
        focusToTCastbarAdjustment:SetChecked(true)
        focusToTAdjustmentOffsetY:Enable()
        focusToTAdjustmentOffsetY:SetValue(0)
        BetterBlizzFramesDB.focusToTCastbarAdjustment = true
        BBF.CastBarTimerCaller()
    end)


   ----------------------
    -- Player Castbar
    ----------------------
    local anchorSubPlayerCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPlayerCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, firstLineY+30)
    anchorSubPlayerCastbar:SetText("Player Castbar")

    local playerCastbarBorder = CreateBorderedFrame(anchorSubPlayerCastbar, 157, 386, 0, -175, contentFrame)

    local playerCastBar = contentFrame:CreateTexture(nil, "ARTWORK")
    playerCastBar:SetAtlas("ui-castingbar-filling-standard")
    playerCastBar:SetSize(110, 13)
    playerCastBar:SetPoint("BOTTOM", anchorSubPlayerCastbar, "TOP", -1, 10)


    local playerCastBarScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "playerCastBarScale")
    playerCastBarScale:SetPoint("TOP", anchorSubPlayerCastbar, "BOTTOM", 0, -15)

    local playerCastBarXPos = CreateSlider(contentFrame, "x offset", -200, 200, 1, "playerCastBarXPos", "X")
    playerCastBarXPos:SetPoint("TOP", playerCastBarScale, "BOTTOM", 0, -15)

    local playerCastBarYPos = CreateSlider(contentFrame, "y offset", -200, 200, 1, "playerCastBarYPos", "Y")
    playerCastBarYPos:SetPoint("TOP", playerCastBarXPos, "BOTTOM", 0, -15)

    local playerCastBarIconScale = CreateSlider(contentFrame, "Icon Size", 0.4, 2, 0.01, "playerCastBarIconScale")
    playerCastBarIconScale:SetPoint("TOP", playerCastBarYPos, "BOTTOM", 0, -15)

    local playerCastBarWidth = CreateSlider(contentFrame, "Width", 60, 230, 1, "playerCastBarWidth")
    --playerCastBarWidth:SetPoint("TOP", playerCastBarYPos, "BOTTOM", 0, -15)
    playerCastBarWidth:SetPoint("TOP", playerCastBarIconScale, "BOTTOM", 0, -15)

    local playerCastBarHeight = CreateSlider(contentFrame, "Height", 5, 30, 1, "playerCastBarHeight")
    playerCastBarHeight:SetPoint("TOP", playerCastBarWidth, "BOTTOM", 0, -15)

    local playerCastBarShowIcon = CreateCheckbox("playerCastBarShowIcon", "Icon", contentFrame, nil, BBF.ShowPlayerCastBarIcon)
    playerCastBarShowIcon:SetPoint("TOPLEFT", playerCastBarHeight, "BOTTOMLEFT", 10, -4)
    CreateTooltip(playerCastBarShowIcon, "Show spell icon to the left of the castbar\nlike on every other castbar in the game")

    local playerCastBarTimer = CreateCheckbox("playerCastBarTimer", "Timer", contentFrame, nil, BBF.CastBarTimerCaller)
    playerCastBarTimer:SetPoint("LEFT", playerCastBarShowIcon.Text, "RIGHT", 10, 0)
    CreateTooltip(playerCastBarTimer, "Show cast timer next to the castbar.")

    local playerCastBarTimerCentered = CreateCheckbox("playerCastBarTimerCentered", "Centered Timer", contentFrame, nil, BBF.CastBarTimerCaller)
    --playerStaticCastbar:SetPoint("TOPLEFT", playerCastBarIconScale, "BOTTOMLEFT", 10, -4)
    playerCastBarTimerCentered:SetPoint("TOPLEFT", playerCastBarShowIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(playerCastBarTimerCentered, "Center the timer in the middle of the castbar")

    local playerCastBarShowText = CreateCheckbox("playerCastBarShowText", "Text", contentFrame, nil, BBF.ChangeCastbarSizes)
    playerCastBarShowText:SetPoint("TOPLEFT", playerCastBarTimerCentered, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(playerCastBarShowText, "Show Castbar Text", "Show castbar text with spellname")

    local playerCastBarShowBorder = CreateCheckbox("playerCastBarShowBorder", "Border", contentFrame, nil, BBF.ChangeCastbarSizes)
    playerCastBarShowBorder:SetPoint("TOPLEFT", playerCastBarTimer, "BOTTOMLEFT", 0, -13)
    CreateTooltipTwo(playerCastBarShowBorder, "Show Castbar Border", "Show castbar borders. If unchecked it will still show uninterruptible border.")

    local resetPlayerCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetPlayerCastbar:SetText("Reset")
    resetPlayerCastbar:SetWidth(70)
    resetPlayerCastbar:SetPoint("TOP", playerCastbarBorder, "BOTTOM", 0, -2)
    resetPlayerCastbar:SetScript("OnClick", function()
        playerCastBarScale:SetValue(1)
        playerCastBarIconScale:SetValue(1)
        playerCastBarXPos:SetValue(0)
        playerCastBarYPos:SetValue(0)
        playerCastBarWidth:SetValue(195)
        playerCastBarHeight:SetValue(13)
        playerCastBarShowIcon:SetChecked(false)
        playerCastBarTimer:SetChecked(false)
        playerCastBarTimerCentered:SetChecked(false)
        playerCastBarShowText:SetChecked(true)
        playerCastBarShowBorder:SetChecked(true)
        BetterBlizzFramesDB.playerCastBarShowText = true
        BetterBlizzFramesDB.playerCastBarShowBorder = true
        BetterBlizzFramesDB.playerCastBarShowIcon = false
        BetterBlizzFramesDB.playerCastBarTimer = false
        BetterBlizzFramesDB.playerStaticCastbar = false
        BetterBlizzFramesDB.playerCastBarTimerCentered = false
        --CastingBarFrame.showShield = false
        BBF.CastBarTimerCaller()
        BBF.ShowPlayerCastBarIcon()
    end)

    local function UpdateColorSquare(icon, r, g, b, a)
        if r and g and b and a then
            icon:SetVertexColor(r, g, b, a)
        else
            icon:SetVertexColor(r, g, b)
        end
    end

    local function OpenColorPicker(colorType, icon)
        -- Ensure originalColorData has four elements, defaulting alpha (a) to 1 if not present
        local originalColorData = BetterBlizzFramesDB[colorType] or {1, 1, 1, 1}
        if #originalColorData == 3 then
            table.insert(originalColorData, 1) -- Add default alpha value if not present
        end
        local r, g, b, a = unpack(originalColorData)

        local function updateColors()
            UpdateColorSquare(icon, r, g, b, a)
            --ColorPickerFrame.Content.ColorSwatchCurrent:SetAlpha(a)
        end

        local function swatchFunc()
            r, g, b = ColorPickerFrame:GetColorRGB()
            BetterBlizzFramesDB[colorType] = {r, g, b, a}
            updateColors()
        end

        local function opacityFunc()
            a = ColorPickerFrame:GetColorAlpha()
            BetterBlizzFramesDB[colorType] = {r, g, b, a}
            updateColors()
        end

        local function cancelFunc()
            r, g, b, a = unpack(originalColorData)
            BetterBlizzFramesDB[colorType] = {r, g, b, a}
            updateColors()
        end

        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b, opacity = a, hasOpacity = true,
            swatchFunc = swatchFunc, opacityFunc = opacityFunc, cancelFunc = cancelFunc
        })
    end

    local castBarInterruptHighlighterText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    castBarInterruptHighlighterText:SetPoint("LEFT", contentFrame, "TOPRIGHT", -235, -465)
    castBarInterruptHighlighterText:SetText("Castbar Edge Highlight settings")

    local castBarInterruptHighlighter = CreateCheckbox("castBarInterruptHighlighter", "Castbar Edge Highlight", contentFrame, nil, BBF.CastbarRecolorWidgets)
    castBarInterruptHighlighter:SetPoint("TOPLEFT", castBarInterruptHighlighterText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltip(castBarInterruptHighlighter, "Color the start and end of the castbar differently.\nSet the percentile of cast to color down below.")

    local targetCastbarEdgeHighlight = CreateCheckbox("targetCastbarEdgeHighlight", "Target", castBarInterruptHighlighter, nil, BBF.CastbarRecolorWidgets)
    targetCastbarEdgeHighlight:SetPoint("TOPLEFT", castBarInterruptHighlighter, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(targetCastbarEdgeHighlight, "Enable for TargetFrame Castbar")

    local focusCastbarEdgeHighlight = CreateCheckbox("focusCastbarEdgeHighlight", "Focus", castBarInterruptHighlighter, nil, BBF.CastbarRecolorWidgets)
    focusCastbarEdgeHighlight:SetPoint("LEFT", targetCastbarEdgeHighlight.text, "RIGHT", 0, 0)
    CreateTooltip(focusCastbarEdgeHighlight, "Enable for FocusFrame Castbar")

    local castBarInterruptHighlighterColorDontInterrupt = CreateCheckbox("castBarInterruptHighlighterColorDontInterrupt", "Re-color between portion", castBarInterruptHighlighter, nil, BBF.CastbarRecolorWidgets)
    castBarInterruptHighlighterColorDontInterrupt:SetPoint("TOPLEFT", targetCastbarEdgeHighlight, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(castBarInterruptHighlighterColorDontInterrupt,"Re-color the middle part of the castbar between the percentages")

    local castBarInterruptHighlighterDontInterruptRGB = CreateFrame("Button", nil, castBarInterruptHighlighterColorDontInterrupt, "UIPanelButtonTemplate")
    castBarInterruptHighlighterDontInterruptRGB:SetText("Color")
    castBarInterruptHighlighterDontInterruptRGB:SetPoint("LEFT", castBarInterruptHighlighterColorDontInterrupt.text, "RIGHT", 2, 0)
    castBarInterruptHighlighterDontInterruptRGB:SetSize(50, 20)
    CreateTooltip(castBarInterruptHighlighterDontInterruptRGB, "Castbar color inbetween the start and finish")
    local castBarInterruptHighlighterDontInterruptRGBIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    castBarInterruptHighlighterDontInterruptRGBIcon:SetAtlas("newplayertutorial-icon-key")
    castBarInterruptHighlighterDontInterruptRGBIcon:SetSize(18, 17)
    castBarInterruptHighlighterDontInterruptRGBIcon:SetPoint("LEFT", castBarInterruptHighlighterDontInterruptRGB, "RIGHT", 0, -1)
    UpdateColorSquare(castBarInterruptHighlighterDontInterruptRGBIcon, unpack(BetterBlizzFramesDB["castBarInterruptHighlighterDontInterruptRGB"] or {1, 1, 1}))
    castBarInterruptHighlighterDontInterruptRGB:SetScript("OnClick", function()
        OpenColorPicker("castBarInterruptHighlighterDontInterruptRGB", castBarInterruptHighlighterDontInterruptRGBIcon)
    end)

    local castBarInterruptHighlighterStartTime = CreateSlider(castBarInterruptHighlighter, "Start Seconds", 0, 2, 0.01, "castBarInterruptHighlighterStartTime", "Height")
    castBarInterruptHighlighterStartTime:SetPoint("TOPLEFT", castBarInterruptHighlighterColorDontInterrupt, "BOTTOMLEFT", 10, -6)
    CreateTooltip(castBarInterruptHighlighterStartTime, "How many seconds of the start of the cast you want to color the castbar.")

    local castBarInterruptHighlighterEndTime = CreateSlider(castBarInterruptHighlighter, "End Seconds", 0, 2, 0.01, "castBarInterruptHighlighterEndTime", "Height")
    castBarInterruptHighlighterEndTime:SetPoint("TOPLEFT", castBarInterruptHighlighterStartTime, "BOTTOMLEFT", 0, -10)
    CreateTooltip(castBarInterruptHighlighterEndTime, "How many seconds of the end of the cast you want to color the castbar.")

    local castBarInterruptHighlighterInterruptRGB = CreateFrame("Button", nil, castBarInterruptHighlighter, "UIPanelButtonTemplate")
    castBarInterruptHighlighterInterruptRGB:SetText("Color")
    castBarInterruptHighlighterInterruptRGB:SetPoint("LEFT", castBarInterruptHighlighterEndTime, "RIGHT", 0, 15)
    castBarInterruptHighlighterInterruptRGB:SetSize(50, 20)
    CreateTooltip(castBarInterruptHighlighterInterruptRGB, "Castbar edge color")
    local castBarInterruptHighlighterInterruptRGBIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    castBarInterruptHighlighterInterruptRGBIcon:SetAtlas("newplayertutorial-icon-key")
    castBarInterruptHighlighterInterruptRGBIcon:SetSize(18, 17)
    castBarInterruptHighlighterInterruptRGBIcon:SetPoint("LEFT", castBarInterruptHighlighterInterruptRGB, "RIGHT", 0, -1)
    UpdateColorSquare(castBarInterruptHighlighterInterruptRGBIcon, unpack(BetterBlizzFramesDB["castBarInterruptHighlighterInterruptRGB"] or {1, 1, 1}))
    castBarInterruptHighlighterInterruptRGB:SetScript("OnClick", function()
        OpenColorPicker("castBarInterruptHighlighterInterruptRGB", castBarInterruptHighlighterInterruptRGBIcon)
    end)

    castBarInterruptHighlighter:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(castBarInterruptHighlighter)
        if self:GetChecked() then
            if BetterBlizzFramesDB.castBarInterruptHighlighterColorDontInterrupt then
                castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(1)
            end
            castBarInterruptHighlighterInterruptRGBIcon:SetAlpha(1)
        else
            castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(0)
            castBarInterruptHighlighterInterruptRGBIcon:SetAlpha(0)
        end
    end)

    castBarInterruptHighlighterColorDontInterrupt:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(castBarInterruptHighlighter)
        if self:GetChecked() then
            castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(1)
        else
            castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(0)
        end
    end)



    local castBarRecolorInterrupt = CreateCheckbox("castBarRecolorInterrupt", "Interrupt CD color", contentFrame, nil, BBF.CastbarRecolorWidgets)
    castBarRecolorInterrupt:SetPoint("LEFT", contentFrame, "TOPRIGHT", -435, -465)
    CreateTooltip(castBarRecolorInterrupt, "Checks if you have interrupt ready\nand colors Target & Focus castbar thereafter.")

    local castBarInterruptIconEnabled = CreateCheckbox("castBarInterruptIconEnabled", "Interrupt CD Icon", contentFrame, nil, BBF.UpdateInterruptIconSettings)
    castBarInterruptIconEnabled:SetPoint("BOTTOMLEFT", castBarRecolorInterrupt, "TOPLEFT", 0, -pixelsBetweenBoxes)
    CreateTooltipTwo(castBarInterruptIconEnabled, "Interrupt CD Icon", "Shows your interrupt CD next to the enemy castbars.\nMore settings in Advanced Settings", "Needs a few tweaks still for pet class interrupts etc.")

    local castBarNoInterruptColor = CreateFrame("Button", nil, castBarRecolorInterrupt, "UIPanelButtonTemplate")
    castBarNoInterruptColor:SetText("Interrupt on CD")
    castBarNoInterruptColor:SetPoint("TOPLEFT", castBarRecolorInterrupt, "BOTTOMRIGHT", -35, 3)
    castBarNoInterruptColor:SetSize(139, 20)
    CreateTooltip(castBarNoInterruptColor, "Castbar color when interrupt is on CD")
    local castBarNoInterruptColorIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    castBarNoInterruptColorIcon:SetAtlas("newplayertutorial-icon-key")
    castBarNoInterruptColorIcon:SetSize(18, 17)
    castBarNoInterruptColorIcon:SetPoint("LEFT", castBarNoInterruptColor, "RIGHT", 0, -1)
    UpdateColorSquare(castBarNoInterruptColorIcon, unpack(BetterBlizzFramesDB["castBarNoInterruptColor"] or {1, 1, 1}))
    castBarNoInterruptColor:SetScript("OnClick", function()
        OpenColorPicker("castBarNoInterruptColor", castBarNoInterruptColorIcon)
    end)

    local castBarDelayedInterruptColor = CreateFrame("Button", nil, castBarRecolorInterrupt, "UIPanelButtonTemplate")
    castBarDelayedInterruptColor:SetText("Interrupt CD soon")
    castBarDelayedInterruptColor:SetPoint("TOPLEFT", castBarNoInterruptColor, "BOTTOMLEFT", 0, -5)
    castBarDelayedInterruptColor:SetSize(139, 20)
    CreateTooltip(castBarDelayedInterruptColor, "Castbar color when interrupt is on CD but\nwill be ready before the cast ends")
    local castBarDelayedInterruptColorIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    castBarDelayedInterruptColorIcon:SetAtlas("newplayertutorial-icon-key")
    castBarDelayedInterruptColorIcon:SetSize(18, 17)
    castBarDelayedInterruptColorIcon:SetPoint("LEFT", castBarDelayedInterruptColor, "RIGHT", 0, -1)
    UpdateColorSquare(castBarDelayedInterruptColorIcon, unpack(BetterBlizzFramesDB["castBarDelayedInterruptColor"] or {1, 1, 1}))
    castBarDelayedInterruptColor:SetScript("OnClick", function()
        OpenColorPicker("castBarDelayedInterruptColor", castBarDelayedInterruptColorIcon)
    end)


    local buffsOnTopReverseCastbarMovement = CreateCheckbox("buffsOnTopReverseCastbarMovement", "Buffs on Top: Reverse Castbar Movement", contentFrame, nil, BBF.CastbarAdjustCaller)
    buffsOnTopReverseCastbarMovement:SetPoint("LEFT", contentFrame, "TOPRIGHT", -470, -555)
    CreateTooltipTwo(buffsOnTopReverseCastbarMovement, "Reverse Castbar Movement", "Changes the castbar movement to follow the top row of auras on Target/Focus Frame when \"Buffs on Top\" is activated. Similar to how it works by default without \"Buffs on Top\" enabled except it's in reverse and moves upwards.")
    --notWorking(buffsOnTopReverseCastbarMovement, true)

    -- local normalCastbarForEmpoweredCasts = CreateCheckbox("normalCastbarForEmpoweredCasts", "Normal Evoker Empowered Castbar", contentFrame, nil, BBF.HookCastbarsForEvoker)
    -- normalCastbarForEmpoweredCasts:SetPoint("TOPLEFT", buffsOnTopReverseCastbarMovement, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltip(normalCastbarForEmpoweredCasts, "Change Evoker empowered castbars to look like normal ones. (Easier to see if you can interrupt)")
    -- notWorking(normalCastbarForEmpoweredCasts, true)
end

local function guiPositionAndScale()

    ----------------------
    -- Advanced settings
    ----------------------
    local firstLineX = 53
    local firstLineY = -65
    local secondLineX = 222
    local secondLineY = -360
    local thirdLineX = 391
    local thirdLineY = -655
    local fourthLineX = 560

    local BetterBlizzFramesSubPanel = CreateFrame("Frame")
    BetterBlizzFramesSubPanel.name = "Advanced Settings"
    BetterBlizzFramesSubPanel.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(BetterBlizzFramesSubPanel)
    local advancedSubCategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, BetterBlizzFramesSubPanel, BetterBlizzFramesSubPanel.name, BetterBlizzFramesSubPanel.name)
    advancedSubCategory.ID = BetterBlizzFramesSubPanel.name;
    CreateTitle(BetterBlizzFramesSubPanel)

    local bgImg = BetterBlizzFramesSubPanel:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", BetterBlizzFramesSubPanel, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)





    local scrollFrame = CreateFrame("ScrollFrame", nil, BetterBlizzFramesSubPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(700, 612)
    scrollFrame:SetPoint("CENTER", BetterBlizzFramesSubPanel, "CENTER", -20, 3)

    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(680, 520)
    scrollFrame:SetScrollChild(contentFrame)

    local mainGuiAnchor2 = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor2:SetPoint("TOPLEFT", 55, 20)
    mainGuiAnchor2:SetText(" ")

 --[[
    ----------------------
    -- Focus Target
    ----------------------
    local anchorFocusTarget = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorFocusTarget:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, firstLineY)
    anchorFocusTarget:SetText("Focus ToT")

    CreateBorderBox(anchorFocusTarget)

    local focusTargetFrameIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    focusTargetFrameIcon:SetAtlas("greencross")
    focusTargetFrameIcon:SetSize(32, 32)
    focusTargetFrameIcon:SetPoint("BOTTOM", anchorFocusTarget, "TOP", 0, 0)
    focusTargetFrameIcon:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875)

    local focusToTScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.1, "focusToTScale")
    focusToTScale:SetPoint("TOP", anchorFocusTarget, "BOTTOM", 0, -15)

    local focusToTXPos = CreateSlider(contentFrame, "x offset", -100, 100, 1, "focusToTXPos", "X")
    focusToTXPos:SetPoint("TOP", focusToTScale, "BOTTOM", 0, -15)

    local focusToTYPos = CreateSlider(contentFrame, "y offset", -100, 100, 1, "focusToTYPos", "Y")
    focusToTYPos:SetPoint("TOP", focusToTXPos, "BOTTOM", 0, -15)

    local focusToTDropdown = CreateAnchorDropdown(
        "focusToTDropdown",
        contentFrame,
        "Select Anchor Point",
        "focusToTAnchor",
        function(arg1) 
            BBF.MoveToTFrames()
        end,
        { anchorFrame = focusToTYPos, x = -16, y = -35, label = "Anchor" }
    )

    local combatIndicatorEnemyOnly = CreateCheckbox("combatIndicatorEnemyOnly", "Enemies only", contentFrame)
    combatIndicatorEnemyOnly:SetPoint("TOPLEFT", focusToTDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)
 
 ]]
 


 --[[
    ----------------------
    -- Pet Frame
    ----------------------
    local anchorPetFrame = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorPetFrame:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, firstLineY)
    anchorPetFrame:SetText("Pet Frame")

    CreateBorderBox(anchorPetFrame)

    local partyFrameIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    partyFrameIcon:SetAtlas("greencross")
    partyFrameIcon:SetSize(32, 32)
    partyFrameIcon:SetPoint("BOTTOM", anchorPetFrame, "TOP", 0, 0)
    partyFrameIcon:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875)

    local petFrameScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.1, "petFrameScale")
    petFrameScale:SetPoint("TOP", anchorPetFrame, "BOTTOM", 0, -15)

    local petFrameXPos = CreateSlider(contentFrame, "x offset", -100, 100, 1, "petFrameXPos", "X")
    petFrameXPos:SetPoint("TOP", petFrameScale, "BOTTOM", 0, -15)

    local petFrameYPos = CreateSlider(contentFrame, "y offset", -100, 100, 1, "petFrameYPos", "Y")
    petFrameYPos:SetPoint("TOP", petFrameXPos, "BOTTOM", 0, -15)

    local petFrameDropdown = CreateAnchorDropdown(
        "petFrameDropdown",
        contentFrame,
        "Select Anchor Point",
        "petFrameAnchor",
        function(arg1) 
            BBF.MoveToTFrames()
        end,
        { anchorFrame = petFrameYPos, x = -16, y = -35, label = "Anchor" }
    )
 
 ]]
 



   ----------------------
    -- Absorb Indicator
    ----------------------
    local anchorSubAbsorb = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubAbsorb:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX - 120, firstLineY)
    anchorSubAbsorb:SetText("Absorb Indicator")

    --CreateBorderBox(anchorSubAbsorb)
    CreateBorderedFrame(anchorSubAbsorb, 200, 293, 0, -98, BetterBlizzFramesSubPanel)

    local absorbIndicator = contentFrame:CreateTexture(nil, "ARTWORK")
    absorbIndicator:SetAtlas("ParagonReputation_Glow")
    absorbIndicator:SetSize(56, 56)
    absorbIndicator:SetPoint("BOTTOM", anchorSubAbsorb, "TOP", -1, -10)
    CreateTooltip(absorbIndicator, "Show absorb amount on target/focus frame. Enable on the General page.")

    local absorbIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "absorbIndicatorScale")
    absorbIndicatorScale:SetPoint("TOP", anchorSubAbsorb, "BOTTOM", 0, -15)

    local absorbIndicatorXPos = CreateSlider(contentFrame, "x offset", -100, 100, 1, "playerAbsorbXPos", "X")
    absorbIndicatorXPos:SetPoint("TOP", absorbIndicatorScale, "BOTTOM", 0, -15)

    local absorbIndicatorYPos = CreateSlider(contentFrame, "y offset", -100, 100, 1, "playerAbsorbYPos", "Y")
    absorbIndicatorYPos:SetPoint("TOP", absorbIndicatorXPos, "BOTTOM", 0, -15)

    local playerAbsorbAnchorDropdown = CreateAnchorDropdown(
        "playerAbsorbAnchorDropdown",
        contentFrame,
        "Select Anchor Point",
        "playerAbsorbAnchor",
        function(arg1)
        BBF.AbsorbCaller()
    end,
        { anchorFrame = absorbIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    local absorbIndicatorTestMode = CreateCheckbox("absorbIndicatorTestMode", "Test", contentFrame, nil, BBF.AbsorbCaller)
    absorbIndicatorTestMode:SetPoint("TOPLEFT", playerAbsorbAnchorDropdown, "BOTTOMLEFT", 10, pixelsBetweenBoxes)

    local absorbIndicatorFlipIconText = CreateCheckbox("absorbIndicatorFlipIconText", "Flip Icon & Text", contentFrame, nil, BBF.AbsorbCaller)
    absorbIndicatorFlipIconText:SetPoint("LEFT", absorbIndicatorTestMode.text, "RIGHT", 5, 0)




--[[
    local absorbIndicatorEnemyOnly = CreateCheckbox("absorbIndicatorEnemyOnly", "Enemy only", contentFrame)
    absorbIndicatorEnemyOnly:SetPoint("TOPLEFT", absorbIndicatorTestMode, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local absorbIndicatorOnPlayersOnly = CreateCheckbox("absorbIndicatorOnPlayersOnly", "Players only", contentFrame)
    absorbIndicatorOnPlayersOnly:SetPoint("TOPLEFT", absorbIndicatorEnemyOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

]]


    --
    local playerAbsorbAmount = CreateCheckbox("playerAbsorbAmount", "Player", contentFrame, nil, BBF.AbsorbCaller)
    playerAbsorbAmount:SetPoint("TOPLEFT", absorbIndicatorTestMode, "BOTTOMLEFT", -5, -14)
    CreateTooltip(playerAbsorbAmount, "Show absorb indicator on PlayerFrame")

    local playerAbsorbIcon = CreateCheckbox("playerAbsorbIcon", "Icon", contentFrame, nil, BBF.AbsorbCaller)
    playerAbsorbIcon:SetPoint("TOPLEFT", playerAbsorbAmount, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(playerAbsorbIcon, "Show icon of the largest absorb spell")

    local targetAbsorbAmount = CreateCheckbox("targetAbsorbAmount", "Target", contentFrame, nil, BBF.AbsorbCaller)
    targetAbsorbAmount:SetPoint("LEFT", playerAbsorbAmount.Text, "RIGHT", 5, 0)
    CreateTooltip(targetAbsorbAmount, "Show absorb indicator on TargetFrame")

    local targetAbsorbIcon = CreateCheckbox("targetAbsorbIcon", "Icon", contentFrame, nil, BBF.AbsorbCaller)
    targetAbsorbIcon:SetPoint("TOPLEFT", targetAbsorbAmount, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetAbsorbIcon, "Show icon of the largest absorb spell")

    local focusAbsorbAmount = CreateCheckbox("focusAbsorbAmount", "Focus", contentFrame, nil, BBF.AbsorbCaller)
    focusAbsorbAmount:SetPoint("LEFT", targetAbsorbAmount.Text, "RIGHT", 5, 0)
    CreateTooltip(focusAbsorbAmount, "Show absorb indicator on FocusFrame")

    local focusAbsorbIcon = CreateCheckbox("focusAbsorbIcon", "Icon", contentFrame, nil, BBF.AbsorbCaller)
    focusAbsorbIcon:SetPoint("TOPLEFT", focusAbsorbAmount, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusAbsorbIcon, "Show icon of the largest absorb spell")










    --------------------------
    -- Combat indicator
    ----------------------
    local anchorSubOutOfCombat = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubOutOfCombat:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX-70, firstLineY)
    anchorSubOutOfCombat:SetText("Combat Indicator")

    --CreateBorderBox(anchorSubOutOfCombat)
    CreateBorderedFrame(anchorSubOutOfCombat, 200, 293, 0, -98, BetterBlizzFramesSubPanel)

    local combatIconSub = contentFrame:CreateTexture(nil, "ARTWORK")
    combatIconSub:SetTexture("Interface\\Icons\\ABILITY_DUALWIELD")
    combatIconSub:SetSize(34, 34)
    combatIconSub:SetPoint("BOTTOM", anchorSubOutOfCombat, "TOP", 0, 1)
    CreateTooltip(combatIconSub, "Show combat status on target/focus frame. Enable on the General page.")

    local combatIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "combatIndicatorScale")
    combatIndicatorScale:SetPoint("TOP", anchorSubOutOfCombat, "BOTTOM", 0, -15)

    local combatIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "combatIndicatorXPos", "X")
    combatIndicatorXPos:SetPoint("TOP", combatIndicatorScale, "BOTTOM", 0, -15)

    local combatIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "combatIndicatorYPos", "Y")
    combatIndicatorYPos:SetPoint("TOP", combatIndicatorXPos, "BOTTOM", 0, -15)

    local combatIndicatorDropdown = CreateAnchorDropdown(
        "combatIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "combatIndicatorAnchor",
        function(arg1) 
            BBF.CombatIndicatorCaller()
        end,
        { anchorFrame = combatIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    local combatIndicatorArenaOnly = CreateCheckbox("combatIndicatorArenaOnly", "Arena only", contentFrame)
    combatIndicatorArenaOnly:SetPoint("TOPLEFT", combatIndicatorDropdown, "BOTTOMLEFT", 5, pixelsBetweenBoxes)
    combatIndicatorArenaOnly:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)
    CreateTooltip(combatIndicatorArenaOnly, "Only show Combat Indicator during arena")

    local combatIndicatorShowSap = CreateCheckbox("combatIndicatorShowSap", "No combat", contentFrame)
    combatIndicatorShowSap:SetPoint("TOPLEFT", combatIndicatorArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    combatIndicatorShowSap:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)
    CreateTooltip(combatIndicatorShowSap, "Show sap icon when not in combat")

    local combatIndicatorAssumePalaCombat = CreateCheckbox("combatIndicatorAssumePalaCombat", "Assume Pala Combat", contentFrame)
    combatIndicatorAssumePalaCombat:SetPoint("TOPLEFT", combatIndicatorShowSap, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(combatIndicatorAssumePalaCombat, "Assume Paladin Combat", "This setting makes it so if paladins have the \"Guardian of Ancient Kings\" pet up it assumes they are in combat.", "The API for combat status doesnt work and returns false even though they are in combat with this pet up. This is a very crude workaround that might not always be accurate.")

    local combatIndicatorShowSwords = CreateCheckbox("combatIndicatorShowSwords", "In combat", contentFrame)
    combatIndicatorShowSwords:SetPoint("LEFT", combatIndicatorShowSap.Text, "RIGHT", 5, 0)
    combatIndicatorShowSwords:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)
    CreateTooltip(combatIndicatorShowSwords, "Show swords icon when in combat")

    local combatIndicatorPlayersOnly = CreateCheckbox("combatIndicatorPlayersOnly", "Players only", contentFrame)
    combatIndicatorPlayersOnly:SetPoint("LEFT", combatIndicatorArenaOnly.Text, "RIGHT", 5, 0)
    combatIndicatorPlayersOnly:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)
    CreateTooltip(combatIndicatorPlayersOnly, "Only show on players and not npcs")

    local playerCombatIndicator = CreateCheckbox("playerCombatIndicator", "Player", contentFrame)
    playerCombatIndicator:SetPoint("TOPLEFT", combatIndicatorShowSap, "BOTTOMLEFT", -5, -17)
    playerCombatIndicator:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)

    local targetCombatIndicator = CreateCheckbox("targetCombatIndicator", "Target", contentFrame)
    targetCombatIndicator:SetPoint("LEFT", playerCombatIndicator.Text, "RIGHT", 5, 0)
    targetCombatIndicator:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)

    local focusCombatIndicator = CreateCheckbox("focusCombatIndicator", "Focus", contentFrame)
    focusCombatIndicator:SetPoint("LEFT", targetCombatIndicator.Text, "RIGHT", 5, 0)
    focusCombatIndicator:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)


    --------------------------
    -- Racial indicator
    ----------------------
    local anchorSubracialIndicator = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubracialIndicator:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX-70, secondLineY - 15)
    anchorSubracialIndicator:SetText("PvP Racial Indicator")

    --CreateBorderBox(anchorSubracialIndicator)
    CreateBorderedFrame(anchorSubracialIndicator, 200, 293, 0, -98, BetterBlizzFramesSubPanel)

    local racialIndicatorIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    racialIndicatorIcon:SetTexture("Interface\\Icons\\ability_ambush")
    racialIndicatorIcon:SetSize(34, 34)
    racialIndicatorIcon:SetPoint("BOTTOM", anchorSubracialIndicator, "TOP", 0, 1)
    CreateTooltip(racialIndicatorIcon, "Show racial icon on target/focus. Enable on the General page.")

    local racialIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "racialIndicatorScale")
    racialIndicatorScale:SetPoint("TOP", anchorSubracialIndicator, "BOTTOM", 0, -15)

    local racialIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "racialIndicatorXPos", "X")
    racialIndicatorXPos:SetPoint("TOP", racialIndicatorScale, "BOTTOM", 0, -15)

    local racialIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "racialIndicatorYPos", "Y")
    racialIndicatorYPos:SetPoint("TOP", racialIndicatorXPos, "BOTTOM", 0, -15)

    local racialIndicatorOrc = CreateCheckbox("racialIndicatorOrc", "Orc", contentFrame)
    racialIndicatorOrc:SetPoint("TOPLEFT", racialIndicatorYPos, "BOTTOMLEFT", 5, -5)
    racialIndicatorOrc:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorOrc, "Show for Orc")

    local racialIndicatorHuman = CreateCheckbox("racialIndicatorHuman", "Human", contentFrame)
    racialIndicatorHuman:SetPoint("TOPLEFT", racialIndicatorOrc, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    racialIndicatorHuman:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorHuman, "Show for Human")

    local racialIndicatorNelf = CreateCheckbox("racialIndicatorNelf", "Night Elf", contentFrame)
    racialIndicatorNelf:SetPoint("LEFT", racialIndicatorOrc.Text, "RIGHT", 25, 0)
    racialIndicatorNelf:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorNelf, "Show for Night Elf")

    local racialIndicatorUndead = CreateCheckbox("racialIndicatorUndead", "Undead", contentFrame)
    racialIndicatorUndead:SetPoint("TOPLEFT", racialIndicatorNelf, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    racialIndicatorUndead:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorUndead, "Show for Undead")

    local targetRacialIndicator = CreateCheckbox("targetRacialIndicator", "Target", contentFrame)
    targetRacialIndicator:SetPoint("TOPLEFT", racialIndicatorHuman, "BOTTOMLEFT", 0, -10)
    targetRacialIndicator:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(targetRacialIndicator, "Show on TargetFrame")

    local focusRacialIndicator = CreateCheckbox("focusRacialIndicator", "Focus", contentFrame)
    focusRacialIndicator:SetPoint("LEFT", targetRacialIndicator.Text, "RIGHT", 12, 0)
    focusRacialIndicator:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(focusRacialIndicator, "Show on FocusFrame")

   ----------------------
    -- Castbar Interrupt Icon
    ----------------------
    local anchorSubInterruptIcon = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubInterruptIcon:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX - 120, secondLineY-15)
    anchorSubInterruptIcon:SetText("Interrupt Icon")

    --CreateBorderBox(anchorSubInterruptIcon)
    CreateBorderedFrame(anchorSubInterruptIcon, 200, 293, 0, -98, BetterBlizzFramesSubPanel)

    local castBarInterruptIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    castBarInterruptIcon:SetTexture("Interface\\Icons\\ability_kick")
    castBarInterruptIcon:SetSize(34, 34)
    castBarInterruptIcon:SetPoint("BOTTOM", anchorSubInterruptIcon, "TOP", 0, 0)
    CreateTooltip(castBarInterruptIcon, "Show interrupt icon next to castbar")

    local castBarInterruptIconScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "castBarInterruptIconScale")
    castBarInterruptIconScale:SetPoint("TOP", anchorSubInterruptIcon, "BOTTOM", 0, -15)

    local castBarInterruptIconXPos = CreateSlider(contentFrame, "x offset", -100, 100, 1, "castBarInterruptIconXPos", "X")
    castBarInterruptIconXPos:SetPoint("TOP", castBarInterruptIconScale, "BOTTOM", 0, -15)

    local castBarInterruptIconYPos = CreateSlider(contentFrame, "y offset", -100, 100, 1, "castBarInterruptIconYPos", "Y")
    castBarInterruptIconYPos:SetPoint("TOP", castBarInterruptIconXPos, "BOTTOM", 0, -15)

    local castBarInterruptIconAnchorDropdown = CreateAnchorDropdown(
        "castBarInterruptIconAnchorDropdown",
        contentFrame,
        "Select Anchor Point",
        "castBarInterruptIconAnchor",
        function(arg1)
        BBF.UpdateInterruptIconSettings()
    end,
        { anchorFrame = castBarInterruptIconYPos, x = -16, y = -35, label = "Anchor" }
    )

    local castBarInterruptIconTarget = CreateCheckbox("castBarInterruptIconTarget", "Target", contentFrame, nil, BBF.UpdateInterruptIconSettings)
    castBarInterruptIconTarget:SetPoint("TOPLEFT", castBarInterruptIconAnchorDropdown, "BOTTOMLEFT", 24, pixelsBetweenBoxes)
    CreateTooltipTwo(castBarInterruptIconTarget, "Show on Target")

    local castBarInterruptIconFocus = CreateCheckbox("castBarInterruptIconFocus", "Focus", contentFrame, nil, BBF.UpdateInterruptIconSettings)
    castBarInterruptIconFocus:SetPoint("LEFT", castBarInterruptIconTarget.text, "RIGHT", 5, 0)
    CreateTooltipTwo(castBarInterruptIconFocus, "Show on Focus")

    local castBarInterruptIconShowActiveOnly = CreateCheckbox("castBarInterruptIconShowActiveOnly", "Only show icon if available", contentFrame, nil, BBF.UpdateInterruptIconSettings)
    castBarInterruptIconShowActiveOnly:SetPoint("TOPLEFT", castBarInterruptIconTarget, "BOTTOMLEFT", -28, pixelsBetweenBoxes)
    CreateTooltipTwo(castBarInterruptIconShowActiveOnly, "Only show icon if available", "Hides the icon if interrupt is on cooldown")

    local interruptIconBorder = CreateCheckbox("interruptIconBorder", "Border Status Color", contentFrame, nil, BBF.UpdateInterruptIconSettings)
    interruptIconBorder:SetPoint("TOPLEFT", castBarInterruptIconShowActiveOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(interruptIconBorder, "Border Status Color", "Colors the border on the icon after interrupt status.\nBy default red if on cooldown, purple if will be ready before cast ends and green if ready.")




    local reloadUiButton2 = CreateFrame("Button", nil, BetterBlizzFramesSubPanel, "UIPanelButtonTemplate")
    reloadUiButton2:SetText("Reload UI")
    reloadUiButton2:SetWidth(85)
    reloadUiButton2:SetPoint("TOP", BetterBlizzFramesSubPanel, "BOTTOMRIGHT", -140, -9)
    reloadUiButton2:SetScript("OnClick", function()
        BetterBlizzFramesDB.reopenOptions = true
        ReloadUI()
    end)



end

local function guiFrameAuras()
    ----------------------
    -- Frame Auras
    ----------------------
    local guiFrameAuras = CreateFrame("Frame")
    guiFrameAuras.name = "Buffs & Debuffs"
    guiFrameAuras.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(guiFrameAuras)
    local aurasSubCategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, guiFrameAuras, guiFrameAuras.name, guiFrameAuras.name)
    aurasSubCategory.ID = guiFrameAuras.name;
    BBF.aurasSubCategory = aurasSubCategory.ID
    CreateTitle(guiFrameAuras)

    local bgImg = guiFrameAuras:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiFrameAuras, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local scrollFrame = CreateFrame("ScrollFrame", nil, guiFrameAuras, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(700, 612)
    scrollFrame:SetPoint("CENTER", guiFrameAuras, "CENTER", -20, 3)

    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(680, 520)
    scrollFrame:SetScrollChild(contentFrame)

    local auraWhitelistFrame = CreateFrame("Frame", nil, contentFrame)
    auraWhitelistFrame:SetSize(322, 390)
    auraWhitelistFrame:SetPoint("TOPLEFT", 346, -15)

    local auraBlacklistFrame = CreateFrame("Frame", nil, contentFrame)
    auraBlacklistFrame:SetSize(322, 390)
    auraBlacklistFrame:SetPoint("TOPLEFT", 6, -15)

    local whitelist = CreateList(auraBlacklistFrame, "auraBlacklist", BetterBlizzFramesDB.auraBlacklist, BBF.RefreshAllAuraFrames, nil, nil, 265)

    local blacklistText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    blacklistText:SetPoint("BOTTOM", auraBlacklistFrame, "TOP", -20, -5)
    blacklistText:SetText("Blacklist")

    local blacklist = CreateList(auraWhitelistFrame, "auraWhitelist", BetterBlizzFramesDB.auraWhitelist, BBF.RefreshAllAuraFrames, true, true, 379, true)

    local whitelistText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whitelistText:SetPoint("BOTTOM", auraWhitelistFrame, "TOP", -60, -5)
    whitelistText:SetText("Whitelist")

    local onlyMeTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    onlyMeTexture:SetTexture(BBF.OwnAuraIcon)
    onlyMeTexture:SetPoint("RIGHT", whitelist, "TOPRIGHT", 296, 9)
    onlyMeTexture:SetSize(18,20)
    CreateTooltip(onlyMeTexture, "Only My Aura Checkboxes")

    local enlargeAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    enlargeAuraTexture:SetTexture(BBF.EnlargedIcon)
    enlargeAuraTexture:SetPoint("LEFT", onlyMeTexture, "RIGHT", 4, 0)
    enlargeAuraTexture:SetSize(18,18)
    CreateTooltip(enlargeAuraTexture, "Enlarged Aura Checkboxes")

    local compactAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    compactAuraTexture:SetTexture(BBF.CompactIcon)
    compactAuraTexture:SetPoint("LEFT", enlargeAuraTexture, "RIGHT", 3, 0)
    compactAuraTexture:SetSize(18,18)
    CreateTooltip(compactAuraTexture, "Compact Aura Checkboxes")

    local importantAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    importantAuraTexture:SetTexture(BBF.ImportantIcon)
    importantAuraTexture:SetPoint("LEFT", compactAuraTexture, "RIGHT", 2, 0)
    importantAuraTexture:SetSize(17,18)
    importantAuraTexture:SetDesaturated(true)
    importantAuraTexture:SetVertexColor(0,1,0)
    CreateTooltip(importantAuraTexture, "Important Aura Checkboxes")

    local pandemicAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    pandemicAuraTexture:SetTexture(BBF.PandemicIcon)
    pandemicAuraTexture:SetPoint("LEFT", importantAuraTexture, "RIGHT", -1, 1)
    pandemicAuraTexture:SetSize(26,26)
    pandemicAuraTexture:SetDesaturated(true)
    pandemicAuraTexture:SetVertexColor(1,0,0)
    CreateTooltip(pandemicAuraTexture, "Pandemic Aura Checkboxes")






    local playerAuraFiltering = CreateCheckbox("playerAuraFiltering", "Enable Aura Settings", contentFrame)
    CreateTooltip(playerAuraFiltering, "This feature is still a bit beta.\nIf you are noticing anything weird or having performance issues please let me know.")
    playerAuraFiltering:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 50, 190)
    playerAuraFiltering:HookScript("OnClick", function (self)
        if self:GetChecked() then
            BBF.HookPlayerAndTargetAuras()
            if BetterBlizzFramesDB.targetToTXPos == 0 then
                StaticPopup_Show("BBF_TOT_MESSAGE")
                BetterBlizzFramesDB.targetToTXPos = 42
                BBF.targetToTXPos:SetValue(42)
                BetterBlizzFramesDB.targetToTYPos = -10
                BBF.targetToTYPos:SetValue(-10)

                BetterBlizzFramesDB.focusToTXPos = 42
                BBF.focusToTXPos:SetValue(42)
                BetterBlizzFramesDB.focusToTYPos = -10
                BBF.focusToTYPos:SetValue(-10)
                BBF.MoveToTFrames()
                BBF.UpdateFilteredBuffsIcon()
            end
        else
            if BetterBlizzFramesDB.targetToTXPos == 42 then
                DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: Aura Settings Off. Target of Target Frame changed back to its default position.")
                BetterBlizzFramesDB.targetToTXPos = 0
                BBF.targetToTXPos:SetValue(0)
                BetterBlizzFramesDB.targetToTYPos = 0
                BBF.targetToTYPos:SetValue(0)

                BetterBlizzFramesDB.focusToTXPos = 0
                BBF.focusToTXPos:SetValue(0)
                BetterBlizzFramesDB.focusToTYPos = 0
                BBF.focusToTYPos:SetValue(0)
                BBF.MoveToTFrames()
            end
        end
    end)

    local enableMasque = CreateCheckbox("enableMasque", "Add Masque Support", contentFrame)
    enableMasque:SetPoint("LEFT", playerAuraFiltering.Text, "RIGHT", 5, 0)
    CreateTooltipTwo(enableMasque, "Add Masque Support", "Enable to add Masque support on all auras.\n(Does not require Aura Settings to be enabled)")
    enableMasque:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local printAuraSpellIds = CreateCheckbox("printAuraSpellIds", "Print Spell ID", playerAuraFiltering)
    printAuraSpellIds:SetPoint("LEFT", enableMasque.Text, "RIGHT", 5, 0)
    CreateTooltip(printAuraSpellIds, "Show aura spell id in chat when mousing over the aura.\n\nUsecase: Find spell ID to filter by ID, some spells have identical names.")
    notWorking(printAuraSpellIds, true)

    -- local tipText = playerAuraFiltering:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- tipText:SetPoint("LEFT", printAuraSpellIds.Text, "RIGHT", 5, 0)
    -- tipText:SetText("Tip")

    --------------------------
    -- Target Frame
    --------------------------
    -- Target Buffs
    local targetBuffEnable = CreateCheckbox("targetBuffEnable", "Show BUFFS", playerAuraFiltering)
    targetBuffEnable:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 64, 140)
    targetBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(targetBuffEnable)
    end)

    local bigEnemyBorderText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bigEnemyBorderText:SetPoint("LEFT", targetBuffEnable, "CENTER", 35, 25)
    bigEnemyBorderText:SetText("Target Frame")
    local targetFrameIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    targetFrameIcon:SetAtlas("groupfinder-icon-friend")
    targetFrameIcon:SetSize(28, 28)
    targetFrameIcon:SetPoint("RIGHT", bigEnemyBorderText, "LEFT", -3, 0)
    targetFrameIcon:SetDesaturated(1)
    targetFrameIcon:SetVertexColor(1, 0, 0)

    local targetAuraBorder = CreateBorderedFrame(targetBuffEnable, 185, 400, 65, -186, contentFrame)

    local targetBuffFilterWatchList = CreateCheckbox("targetBuffFilterWatchList", "Whitelist", targetBuffEnable)
    CreateTooltipTwo(targetBuffFilterWatchList, "Whitelist", "Only show whitelisted auras.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)")
    targetBuffFilterWatchList:SetPoint("TOPLEFT", targetBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local targetBuffFilterBlacklist = CreateCheckbox("targetBuffFilterBlacklist", "Blacklist", targetBuffEnable)
    targetBuffFilterBlacklist:SetPoint("TOPLEFT", targetBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetBuffFilterBlacklist, "Filter out blacklisted auras.")

    local targetBuffFilterLessMinite = CreateCheckbox("targetBuffFilterLessMinite", "Under one min", targetBuffEnable)
    targetBuffFilterLessMinite:SetPoint("TOPLEFT", targetBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetBuffFilterLessMinite, "Only show buffs that are 60sec or shorter.")

    local targetBuffFilterOnlyMe = CreateCheckbox("targetBuffFilterOnlyMe", "Only mine", targetBuffEnable)
    targetBuffFilterOnlyMe:SetPoint("TOPLEFT", targetBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetBuffFilterOnlyMe, "If the target is friendly only show your own buffs on them")

    local targetBuffFilterPurgeable = CreateCheckbox("targetBuffFilterPurgeable", "Purgeable", targetBuffEnable)
    targetBuffFilterPurgeable:SetPoint("TOPLEFT", targetBuffFilterOnlyMe, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local targetBuffFilterMount = CreateCheckbox("targetBuffFilterMount", "Mount", targetBuffEnable)
    targetBuffFilterMount:SetPoint("TOPLEFT", targetBuffFilterPurgeable, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(targetBuffFilterMount, "Mount", "Show all mounts.\n(Needs testing, please report if you see a mount that is not displayed by this filter)")


--[[targetBuffPurgeGlow
    local otherNpBuffBlueBorder = CreateCheckbox("otherNpBuffBlueBorder", "Blue border on buffs", targetBuffEnable)
    otherNpBuffBlueBorder:SetPoint("TOPLEFT", targetBuffFilterOnlyMe, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local otherNpBuffEmphasisedBorder = CreateCheckbox("otherNpBuffEmphasisedBorder", "Red glow on whitelisted buffs", targetBuffEnable)
    otherNpBuffEmphasisedBorder:SetPoint("TOPLEFT", otherNpBuffBlueBorder, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

]]


    -- Target Debuffs
    local targetdeBuffEnable = CreateCheckbox("targetdeBuffEnable", "Show DEBUFFS", playerAuraFiltering)
    targetdeBuffEnable:SetPoint("TOPLEFT", targetBuffFilterMount, "BOTTOMLEFT", -15, 0)
    targetdeBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(targetdeBuffEnable)
    end)

    local targetdeBuffFilterBlizzard = CreateCheckbox("targetdeBuffFilterBlizzard", "Blizzard Default Filter", targetdeBuffEnable)
    targetdeBuffFilterBlizzard:SetPoint("TOPLEFT", targetdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    notWorking(targetdeBuffFilterBlizzard, true)

    local targetdeBuffFilterWatchList = CreateCheckbox("targetdeBuffFilterWatchList", "Whitelist", targetdeBuffEnable)
    CreateTooltipTwo(targetdeBuffFilterWatchList, "Whitelist", "Only show whitelisted auras.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)")
    targetdeBuffFilterWatchList:SetPoint("TOPLEFT", targetdeBuffFilterBlizzard, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local targetdeBuffFilterBlacklist = CreateCheckbox("targetdeBuffFilterBlacklist", "Blacklist", targetdeBuffEnable)
    targetdeBuffFilterBlacklist:SetPoint("TOPLEFT", targetdeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetdeBuffFilterBlacklist, "Filter out blacklisted auras.")

    local targetdeBuffFilterLessMinite = CreateCheckbox("targetdeBuffFilterLessMinite", "Under one min", targetdeBuffEnable)
    targetdeBuffFilterLessMinite:SetPoint("TOPLEFT", targetdeBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetdeBuffFilterLessMinite, "Only show debuffs that are 60sec or shorter.")

    local targetdeBuffFilterOnlyMe = CreateCheckbox("targetdeBuffFilterOnlyMe", "Only mine", targetdeBuffEnable)
    targetdeBuffFilterOnlyMe:SetPoint("TOPLEFT", targetdeBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local targetAuraGlows = CreateCheckbox("targetAuraGlows", "Extra Aura Settings", playerAuraFiltering)
    targetAuraGlows:SetPoint("TOPLEFT", targetdeBuffFilterOnlyMe, "BOTTOMLEFT", -15, 0)
    targetAuraGlows:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(targetAuraGlows)
    end)

    local targetEnlargeAura = CreateCheckbox("targetEnlargeAura", "Enlarge Aura", targetAuraGlows)
    targetEnlargeAura:SetPoint("TOPLEFT", targetAuraGlows, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(targetEnlargeAura, "Enlarge checked whitelisted auras.")

    local targetEnlargeAuraEnemy = CreateCheckbox("targetEnlargeAuraEnemy", "", targetAuraGlows, nil, BBF.UpdateUserAuraSettings)
    targetEnlargeAuraEnemy:SetPoint("LEFT", targetEnlargeAura.Text, "RIGHT", 0, 0)
    CreateTooltip(targetEnlargeAuraEnemy, "Enable on Enemy")
    targetEnlargeAuraEnemy:SetSize(22,22)

    targetEnlargeAuraEnemy.texture = targetEnlargeAuraEnemy:CreateTexture(nil, "ARTWORK", nil, 1)
    targetEnlargeAuraEnemy.texture:SetTexture(BBF.squareGreenGlow)
    targetEnlargeAuraEnemy.texture:SetSize(46, 46)
    targetEnlargeAuraEnemy.texture:SetDesaturated(true)
    targetEnlargeAuraEnemy.texture:SetVertexColor(1,0,0)
    targetEnlargeAuraEnemy.texture:SetPoint("CENTER", targetEnlargeAuraEnemy, "CENTER", -0.5, 0)

    local targetEnlargeAuraFriendly = CreateCheckbox("targetEnlargeAuraFriendly", "", targetAuraGlows, nil, BBF.UpdateUserAuraSettings)
    targetEnlargeAuraFriendly:SetPoint("LEFT", targetEnlargeAuraEnemy, "RIGHT", 0, 0)
    CreateTooltip(targetEnlargeAuraFriendly, "Enable on Friendly")
    targetEnlargeAuraFriendly:SetSize(22,22)

    targetEnlargeAuraFriendly.texture = targetEnlargeAuraFriendly:CreateTexture(nil, "ARTWORK", nil, 1)
    targetEnlargeAuraFriendly.texture:SetTexture(BBF.squareGreenGlow)
    targetEnlargeAuraFriendly.texture:SetSize(46, 46)
    --targetEnlargeAuraFriendly.texture:SetDesaturated(true)
    targetEnlargeAuraFriendly.texture:SetPoint("CENTER", targetEnlargeAuraFriendly, "CENTER", -0.5, 0)


    local targetCompactAura = CreateCheckbox("targetCompactAura", "Compact Aura", targetAuraGlows)
    targetCompactAura:SetPoint("TOPLEFT", targetEnlargeAura, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetCompactAura, "Decrease the size of checked whitelisted auras.")

    local targetdeBuffPandemicGlow = CreateCheckbox("targetdeBuffPandemicGlow", "Pandemic Glow", targetAuraGlows)
    targetdeBuffPandemicGlow:SetPoint("TOPLEFT", targetCompactAura, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetdeBuffPandemicGlow, "Red glow on whitelisted auras with less than 5 seconds left.")

    local targetBuffPurgeGlow = CreateCheckbox("targetBuffPurgeGlow", "Purge Glow", targetAuraGlows)
    targetBuffPurgeGlow:SetPoint("TOPLEFT", targetdeBuffPandemicGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetBuffPurgeGlow, "Bright blue glow on all dispellable/purgeable buffs.\n\nReplaces the standard yellow glow.")

    local targetImportantAuraGlow = CreateCheckbox("targetImportantAuraGlow", "Important Glow", targetAuraGlows)
    targetImportantAuraGlow:SetPoint("TOPLEFT", targetBuffPurgeGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetImportantAuraGlow, "Green glow on whitelisted auras marked as important")



    --------------------------
    -- Focus Frame
    --------------------------
    -- Focus Buffs
    local focusBuffEnable = CreateCheckbox("focusBuffEnable", "Show BUFFS", playerAuraFiltering)
    focusBuffEnable:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 285, 140)
    focusBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(focusBuffEnable)
    end)

    local friendlyFramesText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    friendlyFramesText:SetPoint("LEFT", focusBuffEnable, "CENTER", 35, 25)
    friendlyFramesText:SetText("Focus Frame")
    local focusFrameIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    focusFrameIcon:SetAtlas("groupfinder-icon-friend")
    focusFrameIcon:SetSize(28, 28)
    focusFrameIcon:SetPoint("RIGHT", friendlyFramesText, "LEFT", -3, 0)
    focusFrameIcon:SetDesaturated(1)
    focusFrameIcon:SetVertexColor(0, 1, 0)

    CreateBorderedFrame(focusBuffEnable, 185, 400, 65, -186, contentFrame)

    local focusBuffFilterWatchList = CreateCheckbox("focusBuffFilterWatchList", "Whitelist", focusBuffEnable)
    CreateTooltipTwo(focusBuffFilterWatchList, "Whitelist", "Only show whitelisted auras.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)")
    focusBuffFilterWatchList:SetPoint("TOPLEFT", focusBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local focusBuffFilterBlacklist = CreateCheckbox("focusBuffFilterBlacklist", "Blacklist", focusBuffEnable)
    focusBuffFilterBlacklist:SetPoint("TOPLEFT", focusBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusBuffFilterBlacklist, "Filter out blacklisted auras.")

    local focusBuffFilterLessMinite = CreateCheckbox("focusBuffFilterLessMinite", "Under one min", focusBuffEnable)
    focusBuffFilterLessMinite:SetPoint("TOPLEFT", focusBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusBuffFilterLessMinite, "Only show buffs that are 60sec or shorter.")

    local focusBuffFilterOnlyMe = CreateCheckbox("focusBuffFilterOnlyMe", "Only mine", focusBuffEnable)
    focusBuffFilterOnlyMe:SetPoint("TOPLEFT", focusBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusBuffFilterOnlyMe, "If the unit is friendly show your buffs")

    local focusBuffFilterPurgeable = CreateCheckbox("focusBuffFilterPurgeable", "Purgeable", focusBuffEnable)
    focusBuffFilterPurgeable:SetPoint("TOPLEFT", focusBuffFilterOnlyMe, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local focusBuffFilterMount = CreateCheckbox("focusBuffFilterMount", "Mount", focusBuffEnable)
    focusBuffFilterMount:SetPoint("TOPLEFT", focusBuffFilterPurgeable, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(focusBuffFilterMount, "Mount", "Show all mounts.\n(Needs testing, please report if you see a mount that is not displayed by this filter)")

    -- Focus Debuffs
    local focusdeBuffEnable = CreateCheckbox("focusdeBuffEnable", "Show DEBUFFS", playerAuraFiltering)
    focusdeBuffEnable:SetPoint("TOPLEFT", focusBuffFilterMount, "BOTTOMLEFT", -15, 0)
    focusdeBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(focusdeBuffEnable)
    end)

    local focusdeBuffFilterBlizzard = CreateCheckbox("focusdeBuffFilterBlizzard", "Blizzard Default Filter", focusdeBuffEnable)
    focusdeBuffFilterBlizzard:SetPoint("TOPLEFT", focusdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    notWorking(focusdeBuffFilterBlizzard, true)

    local focusdeBuffFilterWatchList = CreateCheckbox("focusdeBuffFilterWatchList", "Whitelist", focusdeBuffEnable)
    focusdeBuffFilterWatchList:SetPoint("TOPLEFT", focusdeBuffFilterBlizzard, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(focusdeBuffFilterWatchList, "Whitelist", "Only show whitelisted auras.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)")

    local focusdeBuffFilterBlacklist = CreateCheckbox("focusdeBuffFilterBlacklist", "Blacklist", focusdeBuffEnable)
    focusdeBuffFilterBlacklist:SetPoint("TOPLEFT", focusdeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusdeBuffFilterBlacklist, "Filter out blacklisted auras.")

    local focusdeBuffFilterLessMinite = CreateCheckbox("focusdeBuffFilterLessMinite", "Under one min", focusdeBuffEnable)
    focusdeBuffFilterLessMinite:SetPoint("TOPLEFT", focusdeBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusdeBuffFilterLessMinite, "Only show debuffs that are 60sec or shorter.")

    local focusdeBuffFilterOnlyMe = CreateCheckbox("focusdeBuffFilterOnlyMe", "Only mine", focusdeBuffEnable)
    focusdeBuffFilterOnlyMe:SetPoint("TOPLEFT", focusdeBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local focusAuraGlows = CreateCheckbox("focusAuraGlows", "Extra Aura Settings", playerAuraFiltering)
    focusAuraGlows:SetPoint("TOPLEFT", focusdeBuffFilterOnlyMe, "BOTTOMLEFT", -15, 0)
    focusAuraGlows:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(focusAuraGlows)
    end)

    local focusEnlargeAura = CreateCheckbox("focusEnlargeAura", "Enlarge Aura", focusAuraGlows)
    focusEnlargeAura:SetPoint("TOPLEFT", focusAuraGlows, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(focusEnlargeAura, "Enlarge checked whitelisted auras.")

    local focusEnlargeAuraEnemy = CreateCheckbox("focusEnlargeAuraEnemy", "", focusAuraGlows, nil, BBF.UpdateUserAuraSettings)
    focusEnlargeAuraEnemy:SetPoint("LEFT", focusEnlargeAura.Text, "RIGHT", 0, 0)
    CreateTooltip(focusEnlargeAuraEnemy, "Enable on Enemy")
    focusEnlargeAuraEnemy:SetSize(22,22)

    focusEnlargeAuraEnemy.texture = focusEnlargeAuraEnemy:CreateTexture(nil, "ARTWORK", nil, 1)
    focusEnlargeAuraEnemy.texture:SetTexture(BBF.squareGreenGlow)
    focusEnlargeAuraEnemy.texture:SetSize(46, 46)
    focusEnlargeAuraEnemy.texture:SetDesaturated(true)
    focusEnlargeAuraEnemy.texture:SetVertexColor(1,0,0)
    focusEnlargeAuraEnemy.texture:SetPoint("CENTER", focusEnlargeAuraEnemy, "CENTER", -0.5, 0)

    local focusEnlargeAuraFriendly = CreateCheckbox("focusEnlargeAuraFriendly", "", focusAuraGlows, nil, BBF.UpdateUserAuraSettings)
    focusEnlargeAuraFriendly:SetPoint("LEFT", focusEnlargeAuraEnemy, "RIGHT", 0, 0)
    CreateTooltip(focusEnlargeAuraFriendly, "Enable on Friendly")
    focusEnlargeAuraFriendly:SetSize(22,22)

    focusEnlargeAuraFriendly.texture = focusEnlargeAuraFriendly:CreateTexture(nil, "ARTWORK", nil, 1)
    focusEnlargeAuraFriendly.texture:SetTexture(BBF.squareGreenGlow)
    focusEnlargeAuraFriendly.texture:SetSize(46, 46)
    --focusEnlargeAuraFriendly.texture:SetDesaturated(true)
    focusEnlargeAuraFriendly.texture:SetPoint("CENTER", focusEnlargeAuraFriendly, "CENTER", -0.5, 0)

    local focusCompactAura = CreateCheckbox("focusCompactAura", "Compact Aura", focusAuraGlows)
    focusCompactAura:SetPoint("TOPLEFT", focusEnlargeAura, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusCompactAura, "Decrease the size of checked whitelisted auras.")

    local focusdeBuffPandemicGlow = CreateCheckbox("focusdeBuffPandemicGlow", "Pandemic Glow", focusAuraGlows)
    focusdeBuffPandemicGlow:SetPoint("TOPLEFT", focusCompactAura, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusdeBuffPandemicGlow, "Red glow on whitelisted auras with less than 5 seconds left.")

    local focusBuffPurgeGlow = CreateCheckbox("focusBuffPurgeGlow", "Purge Glow", focusAuraGlows)
    focusBuffPurgeGlow:SetPoint("TOPLEFT", focusdeBuffPandemicGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusBuffPurgeGlow, "Bright blue glow on all dispellable/purgeable buffs.\n\nReplaces the standard yellow glow.")

    local focusImportantAuraGlow = CreateCheckbox("focusImportantAuraGlow", "Important Glow", focusAuraGlows)
    focusImportantAuraGlow:SetPoint("TOPLEFT", focusBuffPurgeGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusImportantAuraGlow, "Green glow on auras marked as important in whitelist")

    --------------------------
    -- Player Auras
    --------------------------
    -- Player Auras

    local enablePlayerBuffFiltering = CreateCheckbox("enablePlayerBuffFiltering", "Enable Buff Filtering", playerAuraFiltering)
    enablePlayerBuffFiltering:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 503, 140)
    enablePlayerBuffFiltering:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(enablePlayerBuffFiltering)
    end)

    local PlayerAuraFrameBuffEnable = CreateCheckbox("PlayerAuraFrameBuffEnable", "Show BUFFS", enablePlayerBuffFiltering)
    PlayerAuraFrameBuffEnable:SetPoint("TOPLEFT", enablePlayerBuffFiltering, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    PlayerAuraFrameBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(PlayerAuraFrameBuffEnable)
    end)

    local personalBarText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    personalBarText:SetPoint("LEFT", enablePlayerBuffFiltering, "CENTER", 35, 25)
    personalBarText:SetText("Player Auras")
    local personalBarIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    personalBarIcon:SetAtlas("groupfinder-icon-friend")
    personalBarIcon:SetSize(28, 28)
    personalBarIcon:SetPoint("RIGHT", personalBarText, "LEFT", -3, 0)

    local PlayerAuraBorder = CreateBorderedFrame(enablePlayerBuffFiltering, 185, 400, 65, -186, contentFrame)

    local PlayerAuraFrameBuffFilterWatchList = CreateCheckbox("PlayerAuraFrameBuffFilterWatchList", "Whitelist", PlayerAuraFrameBuffEnable)
    CreateTooltipTwo(PlayerAuraFrameBuffFilterWatchList, "Whitelist", "Only show whitelisted auras.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)")
    PlayerAuraFrameBuffFilterWatchList:SetPoint("TOPLEFT", PlayerAuraFrameBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local playerBuffFilterBlacklist = CreateCheckbox("playerBuffFilterBlacklist", "Blacklist", PlayerAuraFrameBuffEnable)
    playerBuffFilterBlacklist:SetPoint("TOPLEFT", PlayerAuraFrameBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(playerBuffFilterBlacklist, "Filter out blacklisted auras.")

    local PlayerAuraFrameBuffFilterLessMinite = CreateCheckbox("PlayerAuraFrameBuffFilterLessMinite", "Under one min", PlayerAuraFrameBuffEnable)
    PlayerAuraFrameBuffFilterLessMinite:SetPoint("TOPLEFT", playerBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(PlayerAuraFrameBuffFilterLessMinite, "Only show buffs that are 60sec or shorter.")

    local showHiddenAurasIcon = CreateCheckbox("showHiddenAurasIcon", "Filtered Buffs Icon", PlayerAuraFrameBuffEnable)
    showHiddenAurasIcon:SetPoint("TOPLEFT", PlayerAuraFrameBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showHiddenAurasIcon, "Show an icon next to the buff frame displaying\nthe amount of auras filtered out.\nClick icon to show which auras are filtered.")

    -- Create a button next to the checkbox
    local changeIconButton = CreateFrame("Button", "ChangeIconButton", showHiddenAurasIcon, "UIPanelButtonTemplate")
    changeIconButton:SetPoint("RIGHT", showHiddenAurasIcon, "LEFT", 0, 0)
    changeIconButton:SetSize(37, 20)  -- Adjust size as needed
    changeIconButton:SetText("Icon")
    local iconChangeWindow

    changeIconButton:SetScript("OnClick", function()
        if not iconChangeWindow then
            iconChangeWindow = CreateIconChangeWindow()
        end
        iconChangeWindow:Show()
    end)

    showHiddenAurasIcon:HookScript("OnClick", function(self)
        if self:GetChecked() then
            changeIconButton:SetAlpha(1)
            changeIconButton:Enable()
        else
            changeIconButton:SetAlpha(0)
            changeIconButton:Disable()
        end
    end)

    if not BetterBlizzFramesDB.showHiddenAurasIcon then
        changeIconButton:SetAlpha(0)
        changeIconButton:Disable()
    end

    local playerBuffFilterMount = CreateCheckbox("playerBuffFilterMount", "Mount", PlayerAuraFrameBuffEnable)
    playerBuffFilterMount:SetPoint("TOPLEFT", showHiddenAurasIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(playerBuffFilterMount, "Mount", "Show all mounts.\n(Needs testing, please report if you see a mount that is not displayed by this filter)")

    -- Personal Bar Debuffs
    local enablePlayerDebuffFiltering = CreateCheckbox("enablePlayerDebuffFiltering", "Enable Debuff Filtering", playerAuraFiltering)
    enablePlayerDebuffFiltering:SetPoint("TOPLEFT", playerBuffFilterMount, "BOTTOMLEFT", -30, 0)
    enablePlayerDebuffFiltering:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(enablePlayerDebuffFiltering)
    end)
    CreateTooltip(enablePlayerDebuffFiltering, "Enables Debuff Filtering.\nThis boy is a bit too heavy to run for my liking so I've turned it off by default.\nUntil I manage to optimize it use at your own risk.\n(It's probably fine, I'm just too cautious)")
    --notWorking(enablePlayerDebuffFiltering, true)

    local PlayerAuraFramedeBuffEnable = CreateCheckbox("PlayerAuraFramedeBuffEnable", "Show DEBUFFS", enablePlayerDebuffFiltering)
    PlayerAuraFramedeBuffEnable:SetPoint("TOPLEFT", enablePlayerDebuffFiltering, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    PlayerAuraFramedeBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(PlayerAuraFramedeBuffEnable)
    end)

    local PlayerAuraFramedeBuffFilterWatchList = CreateCheckbox("PlayerAuraFramedeBuffFilterWatchList", "Whitelist", PlayerAuraFramedeBuffEnable)
    CreateTooltipTwo(PlayerAuraFramedeBuffFilterWatchList, "Whitelist", "Only show whitelisted auras.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)")
    PlayerAuraFramedeBuffFilterWatchList:SetPoint("TOPLEFT", PlayerAuraFramedeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local playerdeBuffFilterBlacklist = CreateCheckbox("playerdeBuffFilterBlacklist", "Blacklist", PlayerAuraFramedeBuffEnable)
    playerdeBuffFilterBlacklist:SetPoint("TOPLEFT", PlayerAuraFramedeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(playerdeBuffFilterBlacklist, "Filter out blacklisted auras.")

    local PlayerAuraFramedeBuffFilterLessMinite = CreateCheckbox("PlayerAuraFramedeBuffFilterLessMinite", "Under one min", PlayerAuraFramedeBuffEnable)
    PlayerAuraFramedeBuffFilterLessMinite:SetPoint("TOPLEFT", playerdeBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(PlayerAuraFramedeBuffFilterLessMinite, "Only show debuffs that are 60sec or shorter.")

--[=[
    local debuffDotChecker = CreateCheckbox("debuffDotChecker", "DoT Indicator", PlayerAuraFramedeBuffEnable)
    debuffDotChecker:SetPoint("TOPLEFT", PlayerAuraFramedeBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(debuffDotChecker, "Adds an icon next to the player\ndebuffs if one of them is a DoT.")

]=]



    local playerAuraGlows = CreateCheckbox("playerAuraGlows", "Extra Aura Settings", playerAuraFiltering)
    playerAuraGlows:SetPoint("TOPLEFT", PlayerAuraFramedeBuffFilterLessMinite, "BOTTOMLEFT", -30, -20)
    playerAuraGlows:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(playerAuraGlows)
    end)
    --playerAuraGlows:Disable()
    --playerAuraGlows:SetAlpha(0.5)

--[=[
    local playerAuraPandemicGlow = CreateCheckbox("playerAuraPandemicGlow", "Pandemic Glow", playerAuraGlows)
    playerAuraPandemicGlow:SetPoint("TOPLEFT", playerAuraGlows, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(playerAuraPandemicGlow, "Red glow on whitelisted auras with less than 5 seconds left.")

]=]


    local playerAuraImportantGlow = CreateCheckbox("playerAuraImportantGlow", "Important Glow", playerAuraGlows)
    playerAuraImportantGlow:SetPoint("TOPLEFT", playerAuraGlows, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(playerAuraImportantGlow, "Green glow on auras marked as important in whitelist")

    local addCooldownFramePlayerBuffs = CreateCheckbox("addCooldownFramePlayerBuffs", "Buff Cooldown", playerAuraGlows)
    addCooldownFramePlayerBuffs:SetPoint("TOPLEFT", playerAuraImportantGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(addCooldownFramePlayerBuffs, "Buff Cooldown", "Add a cooldown spiral to player buffs similar to other aura icons.")

    local addCooldownFramePlayerDebuffs = CreateCheckbox("addCooldownFramePlayerDebuffs", "Debuff Cooldown", playerAuraGlows)
    addCooldownFramePlayerDebuffs:SetPoint("TOPLEFT", addCooldownFramePlayerBuffs, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(addCooldownFramePlayerDebuffs, "Debuff Cooldown", "Add a cooldown spiral to player debuffs similar to other aura icons.")

    local hideDefaultPlayerAuraDuration = CreateCheckbox("hideDefaultPlayerAuraDuration", "Hide Duration Text", playerAuraGlows)
    hideDefaultPlayerAuraDuration:SetPoint("TOPLEFT", addCooldownFramePlayerDebuffs, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideDefaultPlayerAuraDuration, "Hide Duration Text", "Hide the default duration text if Buff Cooldown or Debuff Cooldown is on.")

    local hideDefaultPlayerAuraCdText = CreateCheckbox("hideDefaultPlayerAuraCdText", "Hide CD Duration Text", playerAuraGlows)
    hideDefaultPlayerAuraCdText:SetPoint("TOPLEFT", hideDefaultPlayerAuraDuration, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideDefaultPlayerAuraCdText, "Hide CD Duration Text", "Hide the cd text on the new cooldown frame from Buff & Debuff Cooldown.", "This setting will get overwritten by OmniCC unless you make a rule for it.")


    local personalAuraSettings = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    personalAuraSettings:SetPoint("TOP", PlayerAuraBorder, "BOTTOM", 0, -5)
    personalAuraSettings:SetText("Player Aura Settings:")



    local targetAndFocusAuraSettings = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetAndFocusAuraSettings:SetPoint("TOP", targetAuraBorder, "BOTTOMRIGHT", 20, -5)
    targetAndFocusAuraSettings:SetText("Target & Focus Aura Settings:")

    --------------------------
    -- Frame settings
    --------------------------






    local targetAndFocusAuraScale = CreateSlider(playerAuraFiltering, "All Aura size", 0.7, 2, 0.01, "targetAndFocusAuraScale")
    targetAndFocusAuraScale:SetPoint("TOP", targetAndFocusAuraSettings, "BOTTOM", 0, -20)
    CreateTooltip(targetAndFocusAuraScale, "Adjusts the size of ALL auras")

    local targetAndFocusSmallAuraScale = CreateSlider(playerAuraFiltering, "Small Aura size", 0.7, 2, 0.01, "targetAndFocusSmallAuraScale")
    targetAndFocusSmallAuraScale:SetPoint("TOP", targetAndFocusAuraScale, "BOTTOM", 0, -20)
    CreateTooltip(targetAndFocusSmallAuraScale, "Adjusts the size of small auras / auras that are not yours.")

    local sameSizeAuras = CreateCheckbox("sameSizeAuras", "Same Size", playerAuraFiltering)
    sameSizeAuras:SetPoint("LEFT", targetAndFocusSmallAuraScale, "RIGHT", 3, 0)
    CreateTooltipTwo(sameSizeAuras, "Same Size", "Enable same sized auras.\n\nBy default your own auras are a little bigger than others. This makes them same size.")
    sameSizeAuras:HookScript("OnClick", function(self)
        if self:GetChecked() then
            DisableElement(targetAndFocusSmallAuraScale)
        else
            EnableElement(targetAndFocusSmallAuraScale)
        end
    end)
    if BetterBlizzFramesDB.sameSizeAuras then
        DisableElement(targetAndFocusSmallAuraScale)
    end

    local customPurgeSize = CreateCheckbox("customPurgeSize", "On", playerAuraGlows)

    local purgeableAuraSize = CreateSlider(customPurgeSize, "Purgeable Aura Scale", 0.7, 2, 0.01, "purgeableAuraSize")
    purgeableAuraSize:SetPoint("TOP", targetAndFocusSmallAuraScale, "BOTTOM", 0, -20)
    CreateTooltip(purgeableAuraSize, "Adjusts the size of small auras / auras that are not yours.")

    customPurgeSize:SetPoint("LEFT", purgeableAuraSize, "RIGHT", 5, 0)
    CreateTooltip(customPurgeSize, "Custom aura size for all purgeable auras")
    customPurgeSize:HookScript("OnClick", function(self)
        if self:GetChecked() then
            EnableElement(purgeableAuraSize)
        else
            DisableElement(purgeableAuraSize)
        end
    end)

    local enlargedAuraSize = CreateSlider(playerAuraFiltering, "Enlarged Aura Scale", 1, 2, 0.01, "enlargedAuraSize")
    enlargedAuraSize:SetPoint("TOP", purgeableAuraSize, "BOTTOM", 0, -20)
    CreateTooltip(enlargedAuraSize, "The scale of how much bigger you want enlarged auras to be")

    local compactedAuraSize = CreateSlider(playerAuraFiltering, "Compacted Aura Scale", 0.3, 1.5, 0.01, "compactedAuraSize")
    compactedAuraSize:SetPoint("TOP", enlargedAuraSize, "BOTTOM", 0, -20)
    CreateTooltip(compactedAuraSize, "The scale of how much smaller you want compacted auras to be")

    local targetAndFocusAurasPerRow = CreateSlider(playerAuraFiltering, "Max auras per row", 1, 12, 1, "targetAndFocusAurasPerRow")
    targetAndFocusAurasPerRow:SetPoint("TOPLEFT", compactedAuraSize, "BOTTOMLEFT", 0, -17)

    local targetAndFocusAuraOffsetX = CreateSlider(playerAuraFiltering, "x offset", -50, 50, 1, "targetAndFocusAuraOffsetX", "X")
    targetAndFocusAuraOffsetX:SetPoint("TOPLEFT", targetAndFocusAurasPerRow, "BOTTOMLEFT", 0, -17)

    local targetAndFocusAuraOffsetY = CreateSlider(playerAuraFiltering, "y offset", -50, 50, 1, "targetAndFocusAuraOffsetY", "Y")
    targetAndFocusAuraOffsetY:SetPoint("TOPLEFT", targetAndFocusAuraOffsetX, "BOTTOMLEFT", 0, -17)

    local targetAndFocusHorizontalGap = CreateSlider(playerAuraFiltering, "Horizontal gap", 0, 18, 0.5, "targetAndFocusHorizontalGap", "X")
    targetAndFocusHorizontalGap:SetPoint("TOPLEFT", targetAndFocusAuraOffsetY, "BOTTOMLEFT", 0, -17)

    local targetAndFocusVerticalGap = CreateSlider(playerAuraFiltering, "Vertical gap", 0, 18, 0.5, "targetAndFocusVerticalGap", "Y")
    targetAndFocusVerticalGap:SetPoint("TOPLEFT", targetAndFocusHorizontalGap, "BOTTOMLEFT", 0, -17)

    local auraTypeGap = CreateSlider(playerAuraFiltering, "Aura Type Gap", 0, 30, 1, "auraTypeGap", "Y")
    auraTypeGap:SetPoint("TOPLEFT", targetAndFocusVerticalGap, "BOTTOMLEFT", 0, -17)
    CreateTooltip(auraTypeGap, "The gap size between buffs & debuffs")

    local auraStackSize = CreateSlider(playerAuraFiltering, "Aura Stack Size", 0.4, 2, 0.01, "auraStackSize")
    auraStackSize:SetPoint("TOPLEFT", auraTypeGap, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(auraStackSize, "Aura Stack Size", "Size of the stack number on auras.")

--[=[
    local maxTargetBuffs = CreateSlider(playerAuraFiltering, "Max Buffs", 1, 32, 1, "maxTargetBuffs")
    maxTargetBuffs:SetPoint("TOPLEFT", targetAndFocusVerticalGap, "BOTTOMLEFT", 0, -17)
    maxTargetBuffs:Disable()
    maxTargetBuffs:SetAlpha(0.5)

    local maxTargetDebuffs = CreateSlider(playerAuraFiltering, "Max Debuffs", 1, 32, 1, "maxTargetDebuffs")
    maxTargetDebuffs:SetPoint("TOPLEFT", maxTargetBuffs, "BOTTOMLEFT", 0, -17)
    maxTargetDebuffs:Disable()
    maxTargetDebuffs:SetAlpha(0.5)

]=]



    local playerAuraBuffScale = CreateSlider(contentFrame, "Aura Size", 0.5, 2, 0.01, "playerAuraBuffScale")
    playerAuraBuffScale:SetPoint("TOP", PlayerAuraBorder, "BOTTOM", 0, -35)

    local playerAuraXOffset = CreateSlider(contentFrame, "PlayerAura x offset", -200, 100, 1, "playerAuraXOffset", "X")
    playerAuraXOffset:SetPoint("TOP", playerAuraBuffScale, "BOTTOM", 0, -15)

    local playerAuraYOffset = CreateSlider(contentFrame, "PlayerAura y offset", -200, 12, 1, "playerAuraYOffset", "Y")
    playerAuraYOffset:SetPoint("TOP", playerAuraXOffset, "BOTTOM", 0, -15)

    local playerAuraSpacingX = CreateSlider(playerAuraFiltering, "Horizontal Padding", -2, 10, 1, "playerAuraSpacingX", "X")
    playerAuraSpacingX:SetPoint("TOP", playerAuraYOffset, "BOTTOM", 0, -15)
    CreateTooltip(playerAuraSpacingX, "Horizontal padding for aura icons.\nAllows you to set gap to 0 (Blizz limit is 5 in EditMode).", "ANCHOR_LEFT")

    local playerAuraSpacingY = CreateSlider(playerAuraFiltering, "Vertical Padding", -10, 10, 1, "playerAuraSpacingY", "Y")
    playerAuraSpacingY:SetPoint("TOP", playerAuraSpacingX, "BOTTOM", 0, -15)

    local maxPlayerAurasPerRow = CreateSlider(playerAuraFiltering, "Max Auras Per Row", 1, 20, 1, "maxPlayerAurasPerRow")
    maxPlayerAurasPerRow:SetPoint("TOP", playerAuraSpacingY, "BOTTOM", 0, -15)

    local moreAuraSettings = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    moreAuraSettings:SetPoint("TOP", PlayerAuraBorder, "BOTTOM", -100, -215)
    moreAuraSettings:SetText("More Aura Settings:")

    local displayDispelGlowAlways = CreateCheckbox("displayDispelGlowAlways", "Always show purge texture", playerAuraFiltering)
    displayDispelGlowAlways:SetPoint("TOPLEFT", moreAuraSettings, "BOTTOMLEFT", -10, -3)
    CreateTooltip(displayDispelGlowAlways, "Always display the purge/steal texture on auras\nregardless if you have a dispel/purge/steal ability or not.")

    local onlyPandemicAuraMine = CreateCheckbox("onlyPandemicAuraMine", "Only Pandemic Mine", playerAuraFiltering)
    onlyPandemicAuraMine:SetPoint("TOPLEFT", displayDispelGlowAlways, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(onlyPandemicAuraMine, "Only show the red pandemic aura glow on my own auras", "ANCHOR_LEFT")

    local changePurgeTextureColor = CreateCheckbox("changePurgeTextureColor", "Change Purge Texture Color", playerAuraFiltering)
    changePurgeTextureColor:SetPoint("TOPLEFT", onlyPandemicAuraMine, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(changePurgeTextureColor, "Change Purge Texture Color")

    local increaseAuraStrata = CreateCheckbox("increaseAuraStrata", "Increase Aura Frame Strata", playerAuraFiltering)
    increaseAuraStrata:SetPoint("TOPLEFT", changePurgeTextureColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(increaseAuraStrata, "Increase Aura Frame Strata", "Inrease the strata of auras in order to make them appear above the Target & ToT Frames so they are not covered.")

    local function OpenColorPicker(colorData)
        -- Make a copy of the colorData array to avoid modifying the original table
        local r, g, b, a = unpack(colorData)
        
        local function updateColors()
            -- Update the original colorData array with the new values
            colorData[1], colorData[2], colorData[3], colorData[4] = r, g, b, a
            BBF.RefreshAllAuraFrames()
        end
    
        local function swatchFunc()
            r, g, b, a = ColorPickerFrame:GetColorRGB()
            updateColors()
        end
    
        local function opacityFunc()
            a = ColorPickerFrame:GetColorAlpha()
            updateColors()
        end
    
        local function cancelFunc(previousValues)
            if previousValues then
                r, g, b, a = previousValues.r, previousValues.g, previousValues.b, previousValues.a
                updateColors()
            end
        end
    
        -- Store the initial values before showing the color picker
        ColorPickerFrame.previousValues = { r = r, g = g, b = b, a = a }
    
        -- Setup and show the color picker with the necessary callbacks and initial values
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b, opacity = a, hasOpacity = true,
            swatchFunc = swatchFunc,
            opacityFunc = opacityFunc,
            cancelFunc = cancelFunc
        })
    end

    local dispelGlowButton = CreateFrame("Button", nil, playerAuraFiltering, "UIPanelButtonTemplate")
    dispelGlowButton:SetText("Color")
    dispelGlowButton:SetPoint("LEFT", changePurgeTextureColor.text, "RIGHT", -1, 0)
    dispelGlowButton:SetSize(43, 18)
    dispelGlowButton:SetScript("OnClick", function()
        OpenColorPicker(BetterBlizzFramesDB.purgeTextureColorRGB)
    end)
    CreateTooltip(dispelGlowButton, "Dispel/Purge Glow Color.")

    local sortingSettings = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sortingSettings:SetPoint("TOPLEFT", increaseAuraStrata, "BOTTOMLEFT", 10, -4)
    sortingSettings:SetText("Sorting:")

    local customImportantAuraSorting = CreateCheckbox("customImportantAuraSorting", "Sort Important Auras", playerAuraFiltering)
    customImportantAuraSorting:SetPoint("TOPLEFT", increaseAuraStrata, "BOTTOMLEFT", 0, -20)
    CreateTooltip(customImportantAuraSorting, "Show Important Auras first in the list\n\n(Remember to enable Important Auras on\nTarget/Focus Frame and check checkbox in whitelist)")

    local customLargeSmallAuraSorting = CreateCheckbox("customLargeSmallAuraSorting", "Sort Enlarged & Compact Auras", playerAuraFiltering)
    customLargeSmallAuraSorting:SetPoint("TOPLEFT", customImportantAuraSorting, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(customLargeSmallAuraSorting, "Show Enlarged Auras first in the list and Compact Auras last.\n\n(Remember to enable Enlarged Auras on\nTarget/Focus Frame and check checkbox in whitelist)")

    local allowLargeAuraFirst = CreateCheckbox("allowLargeAuraFirst", "Sort Enlarged before Important", playerAuraFiltering)
    allowLargeAuraFirst:SetPoint("TOPLEFT", customLargeSmallAuraSorting, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(allowLargeAuraFirst, "If there are both Enlarged and Important auras\nthen show the Enlarged ones first.")

    local purgeableBuffSorting = CreateCheckbox("purgeableBuffSorting", "Sort Purgeable Auras", playerAuraFiltering)
    purgeableBuffSorting:SetPoint("TOPLEFT", allowLargeAuraFirst, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(purgeableBuffSorting, "Sort Purgeable Auras", "Sort purgeable auras before normal auras.\nEnlarged and Important auras will still be prioritized over Purgeable ones unless \"Sort Purgeable before Enlarged/Important\" is checked.")

    local purgeableBuffSortingFirst = CreateCheckbox("purgeableBuffSortingFirst", "Sort Purgeable before Enlarged/Important", purgeableBuffSorting)
    purgeableBuffSortingFirst:SetPoint("TOPLEFT", purgeableBuffSorting, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(purgeableBuffSortingFirst, "Sort Purgeable before Enlarged/Important", "Sort Purgeable before Enlarged and Important auras.")
    purgeableBuffSorting:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(purgeableBuffSorting)
    end)

    -- local customPandemicAuraSorting = CreateCheckbox("customPandemicAuraSorting", "Sort Pandemic Auras before all", playerAuraFiltering)
    -- customPandemicAuraSorting:SetPoint("TOPLEFT", allowLargeAuraFirst, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltip(customPandemicAuraSorting, "Sort Pandemic Auras before all other auras during their pandemic window.")




    playerAuraFiltering:HookScript("OnClick", function (self)
        if self:GetChecked() then
            --asd
        else
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end

        CheckAndToggleCheckboxes(playerAuraFiltering)
    end)

    local betaHighlightIcon = playerAuraFiltering:CreateTexture(nil, "BACKGROUND")
    betaHighlightIcon:SetAtlas("CharacterCreate-NewLabel")
    betaHighlightIcon:SetSize(42, 34)
    betaHighlightIcon:SetPoint("RIGHT", playerAuraFiltering, "LEFT", 8, 0)



    local reloadUiButton = CreateFrame("Button", nil, guiFrameAuras, "UIPanelButtonTemplate")
    reloadUiButton:SetText("Reload UI")
    reloadUiButton:SetWidth(85)
    reloadUiButton:SetPoint("TOP", guiFrameAuras, "BOTTOMRIGHT", -140, -9)
    reloadUiButton:SetScript("OnClick", function()
        BetterBlizzFramesDB.reopenOptions = true
        ReloadUI()
    end)
end

local function guiMisc()
    local guiMisc = CreateFrame("Frame")
    guiMisc.name = "Misc"--"|A:GarrMission_CurrencyIcon-Material:19:19|a Misc"
    guiMisc.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(guiMisc)
    local guiMiscSubcategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, guiMisc, guiMisc.name, guiMisc.name)
    guiMiscSubcategory.ID = guiMisc.name;
    CreateTitle(guiMisc)

    local bgImg = guiMisc:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiMisc, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local settingsText = guiMisc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsText:SetPoint("TOPLEFT", guiMisc, "TOPLEFT", 20, -10)
    settingsText:SetText("Misc settings")
    local miscSettingsIcon = guiMisc:CreateTexture(nil, "ARTWORK")
    miscSettingsIcon:SetAtlas("optionsicon-brown")
    miscSettingsIcon:SetSize(22, 22)
    miscSettingsIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)

    local hideUiErrorFrame = CreateCheckbox("hideUiErrorFrame", "Hide UI Error Frame", guiMisc, nil, BBF.HideFrames)
    hideUiErrorFrame:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltipTwo(hideUiErrorFrame, "Hide UI Error Frame", "Hides the UI Error Frame (The red text displaying \"Not enough mana\" etc)")

    local hideMinimap = CreateCheckbox("hideMinimap", "Hide Minimap", guiMisc, nil, BBF.MinimapHider)
    hideMinimap:SetPoint("TOPLEFT", hideUiErrorFrame, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local hideMinimapButtons = CreateCheckbox("hideMinimapButtons", "Hide Minimap Buttons (still shows on mouseover)", guiMisc, nil, BBF.HideFrames)
    hideMinimapButtons:SetPoint("TOPLEFT", hideMinimap, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hideMinimapButtons:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local hideMinimapAuto = CreateCheckbox("hideMinimapAuto", "Hide Minimap during Arena", guiMisc)
    hideMinimapAuto:SetPoint("TOPLEFT", hideMinimapButtons, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideMinimapAuto, "Automatically hide Minimap during arena games.")
    hideMinimapAuto:HookScript("OnClick", function()
        BBF.MinimapHider()
    end)

    local hideMinimapAutoQueueEye = CreateCheckbox("hideMinimapAutoQueueEye", "Hide Queue Status Eye during Arena", guiMisc)
    hideMinimapAutoQueueEye:SetPoint("TOPLEFT", hideMinimapAuto, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideMinimapAutoQueueEye, "Automatically hide Queue Status Eye during arena games.")
    hideMinimapAutoQueueEye:HookScript("OnClick", function()
        BBF.MinimapHider()
    end)
    notWorking(hideMinimapAutoQueueEye, true)

    local hideObjectiveTracker = CreateCheckbox("hideObjectiveTracker", "Hide Objective Tracker during Arena", guiMisc)
    hideObjectiveTracker:SetPoint("TOPLEFT", hideMinimapAutoQueueEye, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideObjectiveTracker, "Automatically hide Objective Tracker during arena games.")
    hideObjectiveTracker:HookScript("OnClick", function()
        BBF.MinimapHider()
    end)

    local hideActionBarHotKey = CreateCheckbox("hideActionBarHotKey", "Hide ActionBar Keybinds", guiMisc, nil, BBF.HideFrames)
    hideActionBarHotKey:SetPoint("TOPLEFT", hideObjectiveTracker, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideActionBarHotKey, "Hides the keybind on default actionbars (I highly recommend getting Bartender though, doesnt bug like default does)")

    local hideActionBarMacroName = CreateCheckbox("hideActionBarMacroName", "Hide ActionBar Macro Name", guiMisc, nil, BBF.HideFrames)
    hideActionBarMacroName:SetPoint("TOPLEFT", hideActionBarHotKey, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideActionBarMacroName, "Hides the macro name on default actionbars (I highly recommend getting Bartender though, doesnt bug like default does)")

    local hideStanceBar = CreateCheckbox("hideStanceBar", "Hide StanceBar (ActionBar)", guiMisc, nil, BBF.HideFrames)
    hideStanceBar:SetPoint("TOPLEFT", hideActionBarMacroName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local stealthIndicatorPlayer = CreateCheckbox("stealthIndicatorPlayer", "Stealth Indicator (Temporary?)", guiMisc, nil, BBF.StealthIndicator)
    stealthIndicatorPlayer:SetPoint("TOPLEFT", hideStanceBar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    stealthIndicatorPlayer:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    CreateTooltip(stealthIndicatorPlayer, "Add a blue border texture around the\nplayer frame during stealth abilities")
    notWorking(stealthIndicatorPlayer, true)

    local useMiniFocusFrame = CreateCheckbox("useMiniFocusFrame", "Enable Mini-FocusFrame", guiMisc, nil, BBF.MiniFocusFrame)
    useMiniFocusFrame:SetPoint("TOPLEFT", stealthIndicatorPlayer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(useMiniFocusFrame, "Removes healthbar and manabar from the FocusFrame\nand just leaves Portrait and name.\n\nMove castbar and/or disable auras to your liking.")
    notWorking(useMiniFocusFrame, true)

    local moveResourceToTarget = CreateCheckbox("moveResourceToTarget", "Move Resource to TargetFrame", guiMisc)
    moveResourceToTarget:SetPoint("TOPLEFT", useMiniFocusFrame, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTarget, "Move resource (Combo points, Warlock shards etc) to the TargetFrame.")
    notWorking(moveResourceToTarget, true)

    local moveResourceToTargetDruid = CreateCheckbox("moveResourceToTargetDruid", "Druid: Combo Points", moveResourceToTarget)
    moveResourceToTargetDruid:SetPoint("TOPLEFT", moveResourceToTargetRogue, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetDruid, "Move Druid Combo Points to TargetFrame.")
    moveResourceToTargetDruid:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetMonk = CreateCheckbox("moveResourceToTargetMonk", "Monk: Chi Points", moveResourceToTarget)
    moveResourceToTargetMonk:SetPoint("TOPLEFT", moveResourceToTargetDruid, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetMonk, "Move Monk Chi Points to TargetFrame.")
    moveResourceToTargetMonk:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetWarlock = CreateCheckbox("moveResourceToTargetWarlock", "Warlock: Shards", moveResourceToTarget)
    moveResourceToTargetWarlock:SetPoint("TOPLEFT", moveResourceToTargetMonk, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetWarlock, "Move Warlock Shards to TargetFrame.")
    moveResourceToTargetWarlock:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetEvoker = CreateCheckbox("moveResourceToTargetEvoker", "Evoker: Essence", moveResourceToTarget)
    moveResourceToTargetEvoker:SetPoint("TOPLEFT", moveResourceToTargetWarlock, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetEvoker, "Move Evoker Essence to TargetFrame.")
    moveResourceToTargetEvoker:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetMage = CreateCheckbox("moveResourceToTargetMage", "Mage: Arcane Charges", moveResourceToTarget)
    moveResourceToTargetMage:SetPoint("TOPLEFT", moveResourceToTargetEvoker, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetMage, "Move Mage Arcane Charges to TargetFrame.")
    moveResourceToTargetMage:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    moveResourceToTarget:HookScript("OnClick", function()
        CheckAndToggleCheckboxes(moveResourceToTarget)
    end)
end

local function guiChatFrame()

    local guiChatFrame = CreateFrame("Frame")
    guiChatFrame.name = "ChatFrame"
    guiChatFrame.parent = BetterBlizzFrames.name
    InterfaceOptions_AddCategory(guiChatFrame)

    local bgImg = guiChatFrame:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiChatFrame, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local playerAuraGlows = CreateCheckbox("playerAuraGlows", "Extra Aura Glow", guiChatFrame)
    playerAuraGlows:SetPoint("TOPLEFT", debuffDotChecker, "BOTTOMLEFT", -15, -22)
end

local function guiImportAndExport()
    local guiImportAndExport = CreateFrame("Frame")
    guiImportAndExport.name = "Import & Export"--"|A:GarrMission_CurrencyIcon-Material:19:19|a Misc"
    guiImportAndExport.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(guiImportAndExport)
    local guiImportSubcategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, guiImportAndExport, guiImportAndExport.name, guiImportAndExport.name)
    guiImportSubcategory.ID = guiImportAndExport.name;
    CreateTitle(guiImportAndExport)

    local bgImg = guiImportAndExport:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiImportAndExport, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local text = guiImportAndExport:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    text:SetText("BETA")
    text:SetPoint("TOP", guiImportAndExport, "TOPRIGHT", -220, 0)

    local text2 = guiImportAndExport:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text2:SetText("Please backup your settings just in case.\nWTF\\Account\\ACCOUNT_NAME\\SavedVariables\n\nWhile this is beta any export codes\nwill be temporary until non-beta.")
    text2:SetPoint("TOP", text, "BOTTOM", 0, 0)

    local fullProfile = CreateImportExportUI(guiImportAndExport, "Full Profile", BetterBlizzFramesDB, 20, -20, "fullProfile")

    local auraWhitelist = CreateImportExportUI(fullProfile, "Aura Whitelist", BetterBlizzFramesDB.auraWhitelist, 0, -100, "auraWhitelist")
    local auraBlacklist = CreateImportExportUI(auraWhitelist, "Aura Blacklist", BetterBlizzFramesDB.auraBlacklist, 210, 0, "auraBlacklist")
end

local function guiSupport()
    local guiSupport = CreateFrame("Frame")
    guiSupport.name = "|A:GarrisonTroops-Health:10:10|a Support & Code"
    guiSupport.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(guiSupport)
    local guiSupportSubCategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, guiSupport, guiSupport.name, guiSupport.name)
    guiSupportSubCategory.ID = guiSupport.name;
    CreateTitle(guiSupport)

    local bgImg = guiSupport:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiSupport, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local discordLinkEditBox = CreateFrame("EditBox", nil, guiSupport, "InputBoxTemplate")
    discordLinkEditBox:SetPoint("TOPLEFT", guiSupport, "TOPLEFT", 25, -45)
    discordLinkEditBox:SetSize(180, 20)
    discordLinkEditBox:SetAutoFocus(false)
    discordLinkEditBox:SetFontObject("ChatFontSmall")
    discordLinkEditBox:SetText("https://discord.gg/cjqVaEMm25")
    discordLinkEditBox:SetCursorPosition(0) -- Places cursor at start of the text
    discordLinkEditBox:ClearFocus() -- Removes focus from the EditBox
    discordLinkEditBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus() -- Allows user to press escape to unfocus the EditBox
    end)

    -- Make the EditBox text selectable and readonly
    discordLinkEditBox:SetScript("OnTextChanged", function(self)
        self:SetText("https://discord.gg/cjqVaEMm25")
    end)
    --discordLinkEditBox:HighlightText() -- Highlights the text for easy copying
    discordLinkEditBox:SetScript("OnCursorChanged", function() end) -- Prevents cursor changes
    discordLinkEditBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end) -- Re-highlights text when focused
    discordLinkEditBox:SetScript("OnMouseUp", function(self)
        if not self:IsMouseOver() then
            self:ClearFocus()
        end
    end)

    local discordText = guiSupport:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    discordText:SetPoint("BOTTOM", discordLinkEditBox, "TOP", 18, 8)
    discordText:SetText("Join the Discord for info\nand help with BBP/BBF")

    local joinDiscord = guiSupport:CreateTexture(nil, "ARTWORK")
    joinDiscord:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\logos\\discord.tga")
    joinDiscord:SetSize(52, 52)
    joinDiscord:SetPoint("RIGHT", discordText, "LEFT", 0, 1)

    local supportText = guiSupport:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    supportText:SetPoint("TOP", guiSupport, "TOP", 0, -90)
    supportText:SetText("If you wish to support me and my projects\nit would be greatly appreciated |A:GarrisonTroops-Health:10:10|a")

    local boxOne = CreateFrame("EditBox", nil, guiSupport, "InputBoxTemplate")
    boxOne:SetPoint("LEFT", discordLinkEditBox, "RIGHT", 50, 0)
    boxOne:SetSize(180, 20)
    boxOne:SetAutoFocus(false)
    boxOne:SetFontObject("ChatFontSmall")
    boxOne:SetText("https://patreon.com/bodifydev")
    boxOne:SetCursorPosition(0) -- Places cursor at start of the text
    boxOne:ClearFocus() -- Removes focus from the EditBox
    boxOne:SetScript("OnEscapePressed", function(self)
        self:ClearFocus() -- Allows user to press escape to unfocus the EditBox
    end)

    -- Make the EditBox text selectable and readonly
    boxOne:SetScript("OnTextChanged", function(self)
        self:SetText("https://patreon.com/bodifydev")
    end)
    --boxOne:HighlightText() -- Highlights the text for easy copying
    boxOne:SetScript("OnCursorChanged", function() end) -- Prevents cursor changes
    boxOne:SetScript("OnEditFocusGained", function(self) self:HighlightText() end) -- Re-highlights text when focused
    boxOne:SetScript("OnMouseUp", function(self)
        if not self:IsMouseOver() then
            self:ClearFocus()
        end
    end)

    local boxOneTex = guiSupport:CreateTexture(nil, "ARTWORK")
    boxOneTex:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\logos\\patreon.tga")
    boxOneTex:SetSize(58, 58)
    boxOneTex:SetPoint("BOTTOMLEFT", boxOne, "TOPLEFT", 3, -2)

    local patText = guiSupport:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    patText:SetPoint("LEFT", boxOneTex, "RIGHT", 14, -1)
    patText:SetText("Patreon")

    local boxTwo = CreateFrame("EditBox", nil, guiSupport, "InputBoxTemplate")
    boxTwo:SetPoint("LEFT", boxOne, "RIGHT", 35, 0)
    boxTwo:SetSize(180, 20)
    boxTwo:SetAutoFocus(false)
    boxTwo:SetFontObject("ChatFontSmall")
    boxTwo:SetText("https://paypal.me/bodifydev")
    boxTwo:SetCursorPosition(0) -- Places cursor at start of the text
    boxTwo:ClearFocus() -- Removes focus from the EditBox
    boxTwo:SetScript("OnEscapePressed", function(self)
        self:ClearFocus() -- Allows user to press escape to unfocus the EditBox
    end)

    -- Make the EditBox text selectable and readonly
    boxTwo:SetScript("OnTextChanged", function(self)
        self:SetText("https://paypal.me/bodifydev")
    end)
    --boxTwo:HighlightText() -- Highlights the text for easy copying
    boxTwo:SetScript("OnCursorChanged", function() end) -- Prevents cursor changes
    boxTwo:SetScript("OnEditFocusGained", function(self) self:HighlightText() end) -- Re-highlights text when focused
    boxTwo:SetScript("OnMouseUp", function(self)
        if not self:IsMouseOver() then
            self:ClearFocus()
        end
    end)

    local boxTwoTex = guiSupport:CreateTexture(nil, "ARTWORK")
    boxTwoTex:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\logos\\paypal.tga")
    boxTwoTex:SetSize(58, 58)
    boxTwoTex:SetPoint("BOTTOMLEFT", boxTwo, "TOPLEFT", 3, -2)

    local palText = guiSupport:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    palText:SetPoint("LEFT", boxTwoTex, "RIGHT", 14, -1)
    palText:SetText("Paypal")







    -- Implementing the code editor inside the guiSupport frame
    local FAIAP = BBF.indent

    -- Define your color table for syntax highlighting
    local colorTable = {
        [FAIAP.tokens.TOKEN_SPECIAL] = "|c00F1D710",
        [FAIAP.tokens.TOKEN_KEYWORD] = "|c00BD6CCC",
        [FAIAP.tokens.TOKEN_COMMENT_SHORT] = "|c00999999",
        [FAIAP.tokens.TOKEN_COMMENT_LONG] = "|c00999999",
        [FAIAP.tokens.TOKEN_STRING] = "|c00E2A085",
        [FAIAP.tokens.TOKEN_NUMBER] = "|c00B1FF87",
        [FAIAP.tokens.TOKEN_ASSIGNMENT] = "|c0055ff88",
        [FAIAP.tokens.TOKEN_WOW_API] = "|c00ff8000",
        [FAIAP.tokens.TOKEN_WOW_EVENTS] = "|c004ec9b0",
        [0] = "|r",  -- Reset color
    }

    -- Add a scroll frame for the code editor
    local scrollFrame = CreateFrame("ScrollFrame", nil, guiSupport, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOP", guiSupport, "TOP", -10, -170)
    scrollFrame:SetSize(620, 370)  -- Fixed size for the entire editor box

    -- Label for the custom code box
    local customCodeText = guiSupport:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    customCodeText:SetPoint("BOTTOM", scrollFrame, "TOP", 0, 5)
    customCodeText:SetText("Enter Custom Lua Code (Executes at Login)")

    -- Create the code editor
    local codeEditBox = CreateFrame("EditBox", nil, scrollFrame)
    codeEditBox:SetMultiLine(true)
    codeEditBox:SetFontObject("ChatFontSmall")
    codeEditBox:SetSize(600, 370)  -- Smaller than the scroll frame to allow scrolling
    codeEditBox:SetAutoFocus(false)
    codeEditBox:SetCursorPosition(0)
    codeEditBox:SetText(BetterBlizzFramesDB.customCode or "")
    codeEditBox:ClearFocus()

    -- Attach the EditBox to the scroll frame
    scrollFrame:SetScrollChild(codeEditBox)

    -- Add a static custom background to the scroll frame
    local bg = scrollFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(0, 0, 0, 0.6)  -- Semi-transparent black background
    bg:SetAllPoints(scrollFrame)  -- Apply the background to the entire scroll frame

    -- Add a static custom border around the scroll frame
    local border = CreateFrame("Frame", nil, scrollFrame, BackdropTemplateMixin and "BackdropTemplate")
    border:SetPoint("TOPLEFT", scrollFrame, -2, 2)
    border:SetPoint("BOTTOMRIGHT", scrollFrame, 2, -2)
    border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
    })
    border:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)  -- Light gray border

    -- Optional: Set padding or insets if needed
    codeEditBox:SetTextInsets(6, 10, 4, 10)

    -- Track changes to detect unsaved edits
    local unsavedChanges = false
    codeEditBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            -- Compare current text with saved code
            local currentText = self:GetText()
            if currentText ~= BetterBlizzFramesDB.customCode then
                unsavedChanges = true
            else
                unsavedChanges = false
            end
        end
    end)

    -- Enable syntax highlighting and indentation with FAIAP
    FAIAP.enable(codeEditBox, colorTable, 4)  -- Assuming a tab width of 4

    local customCodeSaved = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: Custom code has been saved."

    -- Create Save Button
    local saveButton = CreateFrame("Button", nil, guiSupport, "UIPanelButtonTemplate")
    saveButton:SetSize(120, 30)
    saveButton:SetPoint("TOP", scrollFrame, "BOTTOM", 0, -10)
    saveButton:SetText("Save")
    saveButton:SetScript("OnClick", function()
        BetterBlizzFramesDB.customCode = codeEditBox:GetText()
        unsavedChanges = false
        print(customCodeSaved)
    end)

    -- Flag to prevent double triggering of the prompt
    local promptShown = false

    -- Function to show the save prompt if needed
    local function showSavePrompt()
        if unsavedChanges and not promptShown then
            promptShown = true
            StaticPopup_Show("UNSAVED_CHANGES_PROMPT")
        end
    end

    -- Prevent the EditBox from clearing focus with ESC if there are unsaved changes
    codeEditBox:SetScript("OnEscapePressed", function(self)
        if unsavedChanges then
            showSavePrompt()
        else
            self:ClearFocus()
        end
    end)

    StaticPopupDialogs["UNSAVED_CHANGES_PROMPT"] = {
        text = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames \n\nYou have unsaved changes to the custom code.\n\nDo you want to save them?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            BetterBlizzFramesDB.customCode = codeEditBox:GetText()
            unsavedChanges = false
            codeEditBox:ClearFocus()
            print(customCodeSaved)
            if BetterBlizzFramesDB.reopenOptions then
                ReloadUI()
            end
        end,
        OnCancel = function()
            unsavedChanges = false
            codeEditBox:ClearFocus()
            BetterBlizzFramesDB.reopenOptions = false
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    local reloadUiButton = CreateFrame("Button", nil, guiSupport, "UIPanelButtonTemplate")
    reloadUiButton:SetText("Reload UI")
    reloadUiButton:SetWidth(85)
    reloadUiButton:SetPoint("TOP", guiSupport, "BOTTOMRIGHT", -140, -9)
    reloadUiButton:SetScript("OnClick", function()
        if unsavedChanges then
            showSavePrompt()
            BetterBlizzFramesDB.reopenOptions = true
            return
        end
        BetterBlizzFramesDB.reopenOptions = true
        ReloadUI()
    end)
end
------------------------------------------------------------
-- GUI Setup
------------------------------------------------------------
function BBF.InitializeOptions()
    if not BetterBlizzFrames then
        BetterBlizzFrames = CreateFrame("Frame")
        BetterBlizzFrames.name = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames"
        --InterfaceOptions_AddCategory(BetterBlizzFrames)
        BBF.category = Settings.RegisterCanvasLayoutCategory(BetterBlizzFrames, BetterBlizzFrames.name, BetterBlizzFrames.name)
        BBF.category.ID = BetterBlizzFrames.name
        Settings.RegisterAddOnCategory(BBF.category)

        guiGeneralTab()
        guiPositionAndScale()
        guiFrameAuras()
        guiCastbars()
        guiImportAndExport()
        guiMisc()
        --guiChatFrame()
        guiSupport()
    end
end