BetterBlizzFrames = nil
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")
local L = BBF.L
--local anchorPoints = {"CENTER", "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}
local anchorPoints = {"CENTER", "TOP", "LEFT", "RIGHT", "BOTTOM"}
local anchorPoints2 = {"TOP", "LEFT", "RIGHT", "BOTTOM"}
local pixelsBetweenBoxes = 6
local pixelsOnFirstBox = -1
local sliderUnderBoxX = 12
local sliderUnderBoxY = -10
local sliderUnderBox = "12, -10"
local titleText = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: \n\n"

-- Font configuration for localization support
-- Custom fonts (arialn.TTF, Expressway_Free.ttf) support Latin alphabet only
-- For non-Latin languages, use WoW's default font from GameFontNormal (supports all locales)
local locale = GetLocale()

-- Check if custom fonts support the current locale (Latin-based languages only)
local useCustomFonts = (locale == "enUS" or locale == "enGB" or
                         locale == "deDE" or locale == "esES" or locale == "esMX" or
                         locale == "frFR" or locale == "itIT" or locale == "ptBR")

local fontSmall, fontMedium, fontLarge

if useCustomFonts then
    -- Use custom addon fonts for Latin-based languages
    fontSmall = "Interface\\AddOns\\BetterBlizzFrames\\media\\arialn.TTF"
    fontMedium = "Interface\\AddOns\\BetterBlizzFrames\\media\\arialn.TTF"
    fontLarge = "Interface\\AddOns\\BetterBlizzFrames\\media\\Expressway_Free.ttf"
else
    -- Get game's default font path which already supports the current locale
    local gameFont = GameFontNormal:GetFont()
    fontSmall = gameFont
    fontMedium = gameFont
    fontLarge = gameFont
end

local playerClass = select(2, UnitClass("player"))
local playerClassResourceScale = "classResource" .. playerClass .. "Scale"

BBF.squareGreenGlow = "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\newplayertutorial-drag-slotgreen.tga"

local checkBoxList = {}
local sliderList = {}

local function UpdateColorSquare(icon, r, g, b, a)
    if r and g and b then
        icon:SetColorTexture(r, g, b, a)
    end
end

local function OpenColorOptions(entryColors, func)
    local colorData = entryColors or {0, 1, 0, 1}
    local r, g, b = colorData[1] or 1, colorData[2] or 1, colorData[3] or 1
    local a = colorData[4] or 1

    local function updateColors(newR, newG, newB, newA)
        entryColors[1] = newR
        entryColors[2] = newG
        entryColors[3] = newB
        entryColors[4] = newA or 1

        if func then
            func()
        end
    end

    local function swatchFunc()
        r, g, b = ColorPickerFrame:GetColorRGB()
        updateColors(r, g, b, a)
    end

    local function opacityFunc()
        a = ColorPickerFrame:GetColorAlpha()
        updateColors(r, g, b, a)
    end

    local function cancelFunc(previousValues)
        if previousValues then
            r, g, b, a = previousValues.r, previousValues.g, previousValues.b, previousValues.a
            updateColors(r, g, b, a)
        end
    end

    ColorPickerFrame.previousValues = { r = r, g = g, b = b, a = a }

    ColorPickerFrame:SetupColorPickerAndShow({
        r = r, g = g, b = b, opacity = a, hasOpacity = true,
        swatchFunc = swatchFunc, opacityFunc = opacityFunc, cancelFunc = cancelFunc
    })
end







local LSM = LibStub("LibSharedMedia-3.0")


local function CreateFontDropdown(name, parentFrame, defaultText, settingKey, toggleFunc, point, dropdownWidth, maxVisibleItems, labelPos)
    maxVisibleItems = maxVisibleItems or 25  -- Default to 25 visible items if not provided

    -- Create container for label and dropdown
    local container = CreateFrame("Frame", nil, parentFrame)
    container:SetSize(dropdownWidth or 155, 50)

    -- Create and position label
    local label

    -- Create the dropdown button with the new dropdown template
    local dropdown = CreateFrame("DropdownButton", nil, parentFrame, "WowStyle1DropdownTemplate")
    dropdown:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 0, 0)
    dropdown:SetWidth(dropdownWidth or 155)
    dropdown:SetDefaultText(BetterBlizzFramesDB[settingKey] or defaultText)
    dropdown.Background:SetVertexColor(0.9,0.9,0.9)
    dropdown.Arrow:SetVertexColor(0.9,0.9,0.9)

    if labelPos == "TOP" then
        label = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("BOTTOM", dropdown, "TOP", 0, 3)
        label:SetText(L["Font"])
    else
        label = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall2")
        label:SetPoint("LEFT", container, "LEFT", -50, -12)
        label:SetText(L["Font"])
        label:SetFont(fontSmall, 13)
    end

    -- Custom font display for the selected font
    -- dropdown.customFontText = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- dropdown.customFontText:SetPoint("LEFT", dropdown, "LEFT", 8, 0)
    -- dropdown.customFontText:SetText(BetterBlizzFramesDB[settingKey] or defaultText)
    -- dropdown.customFontText:SetTextColor(1,1,1)
    -- local initialFont = LSM:Fetch(LSM.MediaType.FONT, BetterBlizzFramesDB[settingKey] or "")
    -- if initialFont then
    --     dropdown.customFontText:SetFont(initialFont, 12)
    -- end

    -- Initialize a unique font pool for this dropdown
    dropdown.fontPool = {}

    -- Fetch and sort fonts
    C_Timer.After(1, function()
        local fonts = LSM:HashTable(LSM.MediaType.FONT)
        local sortedFonts = {}
        for fontName in pairs(fonts) do
            table.insert(sortedFonts, fontName)
        end
        table.sort(sortedFonts)

        -- Define the generator function for the dropdown menu
        local function GeneratorFunction(owner, rootDescription)
            local itemHeight = 20  -- Each item's height
            local maxScrollExtent = maxVisibleItems * itemHeight
            rootDescription:SetScrollMode(maxScrollExtent)

            for index, fontName in ipairs(sortedFonts) do
                local fontPath = fonts[fontName]

                -- Create each item as a button with the custom font
                local button = rootDescription:CreateButton("                                                  ", function()
                    BetterBlizzFramesDB[settingKey] = fontName
                    -- dropdown.customFontText:SetText(fontName)
                    -- dropdown.customFontText:SetFont(fontPath, 12)
                    dropdown:SetDefaultText(BetterBlizzFramesDB[settingKey] or defaultText)
                    toggleFunc(fontPath)
                end)

                -- Use the pooled font string for each button
                button:AddInitializer(function(button)
                    local fontDisplay = dropdown.fontPool[index]
                    if not fontDisplay then
                        fontDisplay = dropdown:CreateFontString(nil, "BACKGROUND")
                        dropdown.fontPool[index] = fontDisplay
                    end

                    -- Attach the font display to the button and set the font
                    fontDisplay:SetParent(button)
                    fontDisplay:SetPoint("LEFT", button, "LEFT", 5, 0)
                    fontDisplay:SetFont(fontPath, 12)
                    fontDisplay:SetText(fontName)
                    fontDisplay:Show()
                end)
            end
        end

        -- Hide any unused font strings when the menu is closed
        hooksecurefunc(dropdown, "OnMenuClosed", function()
            for _, fontDisplay in pairs(dropdown.fontPool) do
                fontDisplay:Hide()
            end
        end)

        -- Set up the dropdown menu with the generator function
        dropdown:SetupMenu(GeneratorFunction)
    end)

    -- Position the container on the specified anchor point
    container:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    return dropdown, container
end

local function CreateTextureDropdown(name, parentFrame, labelText, settingKey, toggleFunc, point, dropdownWidth, maxVisibleItems)
    maxVisibleItems = maxVisibleItems or 25  -- Default to 25 visible items if not provided

    -- Create container for label and dropdown
    local container = CreateFrame("Frame", nil, parentFrame)
    container:SetSize(dropdownWidth or 155, 50)

    -- -- Create and position label
    -- local label = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- label:SetPoint("BOTTOMLEFT", container, "TOPLEFT", 0, 2)
    -- label:SetText(labelText)

    -- Create the dropdown button with the new dropdown template
    local dropdown = CreateFrame("DropdownButton", nil, parentFrame, "WowStyle1DropdownTemplate")
    dropdown:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 0, 0)
    dropdown:SetWidth(dropdownWidth or 155)
    dropdown:SetDefaultText(BetterBlizzFramesDB[settingKey] or L["Select_Texture"])
    dropdown.Background:SetVertexColor(0.9,0.9,0.9)
    dropdown.Arrow:SetVertexColor(0.9,0.9,0.9)

    -- Initialize a unique texture pool for this dropdown
    dropdown.texturePool = {}

    -- Fetch and sort textures
    C_Timer.After(1, function()
        local textures = LSM:HashTable(LSM.MediaType.STATUSBAR)
        local sortedTextures = {}
        for textureName in pairs(textures) do
            table.insert(sortedTextures, textureName)
        end
        table.sort(sortedTextures)

        -- Get class colors table
        local classColors = RAID_CLASS_COLORS
        local classKeys = {}
        for class in pairs(classColors) do
            table.insert(classKeys, class)
        end

        -- Define the generator function for the dropdown menu
        local function GeneratorFunction(owner, rootDescription)
            local itemHeight = 20  -- Each item's height
            local maxScrollExtent = maxVisibleItems * itemHeight
            rootDescription:SetScrollMode(maxScrollExtent)

            for index, textureName in ipairs(sortedTextures) do
                local texturePath = textures[textureName]

                -- Create each item as a button with the background texture
                local button = rootDescription:CreateButton(textureName, function()
                    BetterBlizzFramesDB[settingKey] = textureName
                    dropdown:SetDefaultText(textureName)
                    toggleFunc(texturePath)
                end)

                -- Use the pooled texture for the background on each button
                button:AddInitializer(function(button)
                    local textureBackground = dropdown.texturePool[index]
                    if not textureBackground then
                        textureBackground = dropdown:CreateTexture(nil, "BACKGROUND")
                        dropdown.texturePool[index] = textureBackground
                    end

                    -- Attach the background to the button and set the texture
                    textureBackground:SetParent(button)
                    textureBackground:SetAllPoints(button)
                    textureBackground:SetTexture(texturePath)

                    -- Pick a random class color and apply it
                    local randomClass = classKeys[math.random(#classKeys)]
                    local color = classColors[randomClass]
                    textureBackground:SetVertexColor(color.r, color.g, color.b)

                    textureBackground:Show()
                end)
            end
        end

        hooksecurefunc(dropdown, "OnMenuClosed", function()
            for _, texture in pairs(dropdown.texturePool) do
                texture:Hide()
            end
        end)

        dropdown:SetupMenu(GeneratorFunction)
    end)

    container:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    return dropdown, container
end

local function CreateSimpleDropdown(name, parentFrame, labelText, settingKey, optionsTable, toggleFunc, point, dropdownWidth)
    dropdownWidth = dropdownWidth or 155  -- Default dropdown width if not provided

    -- Create container for label and dropdown
    local container = CreateFrame("Frame", nil, parentFrame)
    container:SetSize(dropdownWidth, 50)

    -- Function to get localized text
    local function GetLocalizedText(text)
        if text == "" then return "NONE" end
        return L[text] or text
    end

    -- Create the dropdown button with the new dropdown template
    local dropdown = CreateFrame("DropdownButton", nil, parentFrame, "WowStyle1DropdownTemplate")
    dropdown:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 0, 0)
    dropdown:SetWidth(dropdownWidth)
    dropdown:SetDefaultText(GetLocalizedText(BetterBlizzFramesDB[settingKey]) or (L["Select"].." "..labelText))
    dropdown.Background:SetVertexColor(0.9, 0.9, 0.9)
    dropdown.Arrow:SetVertexColor(0.9, 0.9, 0.9)

    -- Create and position label
    local label = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall2")
    label:SetPoint("LEFT", container, "LEFT", -50, -12)
    label:SetText(labelText)
    label:SetFont(fontSmall, 13)
    dropdown.LabelText = label

    -- Define the generator function for the dropdown menu
    local function GeneratorFunction(owner, rootDescription)
        local itemHeight = 20  -- Each item's height
        local maxScrollExtent = math.min(#optionsTable, 25) * itemHeight
        rootDescription:SetScrollMode(maxScrollExtent)

        for _, option in ipairs(optionsTable) do
            local displayText = GetLocalizedText(option)
            -- Create each item as a button
            local button = rootDescription:CreateButton(displayText, function()
                BetterBlizzFramesDB[settingKey] = tonumber(option) or option
                dropdown:SetDefaultText(displayText)
                if toggleFunc then
                    toggleFunc(option)
                end
            end)

            -- Add the text initializer for the button
            button:AddInitializer(function(button)
                --button.Text:SetText(displayText) -- 11.1 error
            end)
        end
    end

    -- Reset dropdown contents when closed
    hooksecurefunc(dropdown, "OnMenuClosed", function()
        dropdown:SetDefaultText(GetLocalizedText(BetterBlizzFramesDB[settingKey]) or (L["Select"].." "..labelText))
    end)

    dropdown:SetupMenu(GeneratorFunction)
    container:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    return dropdown, container
end

local function CreateColorBox(parent, colorVar, labelText, callback)
    local function OpenColorPicker(colorType, icon)
        -- Initialize color with default RGBA if not present
        BetterBlizzFramesDB[colorType] = BetterBlizzFramesDB[colorType] or {1, 1, 1, 1}
        local r, g, b, a = unpack(BetterBlizzFramesDB[colorType])
        if not a then a = 1 end

        local function updateColors()
            BetterBlizzFramesDB[colorType] = {r, g, b, a}
            if icon then
                UpdateColorSquare(icon, r, g, b, a)
                BBF.CastbarRecolorWidgets() --temp
            end
            ColorPickerFrame.Content.ColorSwatchCurrent:SetAlpha(a)
            if callback then
                callback()
            end
        end

        local function swatchFunc()
            r, g, b = ColorPickerFrame:GetColorRGB()
            a = ColorPickerFrame:GetColorAlpha()
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

        -- Setup and show the color picker
        ColorPickerFrame.previousValues = {r, g, b, a}
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b, opacity = a,
            hasOpacity = true,
            swatchFunc = swatchFunc,
            opacityFunc = opacityFunc,
            cancelFunc = cancelFunc,
            previousValues = {r, g, b, a},
        })
    end

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(55, 20)

    -- Border Frame (slightly larger to act as a border)
    local borderFrame = CreateFrame("Frame", nil, frame)
    borderFrame:SetSize(15, 15)
    borderFrame:SetPoint("LEFT", frame, "LEFT", 4, 0)

    local border = borderFrame:CreateTexture(nil, "OVERLAY", nil, 5)
    border:SetAtlas("talents-node-square-gray")
    border:SetAllPoints()

    -- Create the color texture within the border frame
    local colorTexture = borderFrame:CreateTexture(nil, "OVERLAY")
    colorTexture:SetSize(12, 12)
    colorTexture:SetPoint("CENTER", borderFrame, "CENTER", 0, 0)
    colorTexture:SetColorTexture(unpack(BetterBlizzFramesDB[colorVar] or {1, 1, 1}))

    -- Label text for the color box
    local text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    text:SetText(labelText)
    text:SetPoint("LEFT", borderFrame, "RIGHT", 3, 0)
    frame.text = text

    -- Make the frame clickable and open a color picker on click
    frame:EnableMouse(true)
    frame:SetScript("OnMouseDown", function(self, button)
        if frame:GetAlpha() == 1 then
            if button == "LeftButton" then
                OpenColorPicker(colorVar, colorTexture)
            elseif button == "RightButton" and IsShiftKeyDown() then
                local defaultColor = BBF.defaultSettings[colorVar]
                if defaultColor then
                    BetterBlizzFramesDB[colorVar] = {unpack(defaultColor)}
                    colorTexture:SetColorTexture(unpack(defaultColor))
                    if callback then
                        callback()
                    end
                end
            end
        end
    end)

    local grandparent = parent:GetParent()

    if parent:GetObjectType() == "CheckButton" and (parent:GetChecked() == false or (grandparent:GetObjectType() == "CheckButton" and grandparent:GetChecked() == false)) then
        frame:SetAlpha(0.5)
    else
        frame:SetAlpha(1)
    end

    return frame
end














StaticPopupDialogs["BBF_KICK_POPUP_SOUND_ID"] = {
    text = "Enter a custom Sound ID (leave empty or 0 to use dropdown):",
    button1 = "OK",
    button2 = "Cancel",
    hasEditBox = true,
    OnShow = function(self)
        local fileID = BetterBlizzFramesDB.kickPopupSoundFileID
        if fileID and fileID ~= 0 then
            self.editBox:SetText(tostring(fileID))
        else
            self.editBox:SetText("")
        end
        self.editBox:HighlightText()
    end,
    OnAccept = function(self)
        local text = self.editBox:GetText():trim()
        local id = tonumber(text)
        if not id or id == 0 then
            BetterBlizzFramesDB.kickPopupSoundFileID = nil
            if BBF.kickPopupSoundNameDropdown then
                LibDD:UIDropDownMenu_SetText(BBF.kickPopupSoundNameDropdown, BetterBlizzFramesDB.kickPopupSoundName or "Lossa Countered")
            end
        else
            BetterBlizzFramesDB.kickPopupSoundFileID = id
            if BBF.kickPopupSoundNameDropdown then
                LibDD:UIDropDownMenu_SetText(BBF.kickPopupSoundNameDropdown, "ID: " .. id)
            end
            local channel = BetterBlizzFramesDB.kickPopupSoundChannel or "Master"
            PlaySound(id, channel)
        end
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent()
        StaticPopupDialogs["BBF_KICK_POPUP_SOUND_ID"].OnAccept(parent)
        parent:Hide()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["BBF_CONFIRM_RELOAD"] = {
    text = titleText..L["Popup_Reload_Required"],
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function()
        BetterBlizzFramesDB.reopenOptions = true
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
}

StaticPopupDialogs["BBF_TOT_MESSAGE"] = {
    text = titleText..L["Popup_Tot_Message_Text_Midnight"],
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end,
    OnCancel = function()
        BetterBlizzFramesDB.targetToTXPos = 0
        BBF.targetToTXPos:SetValue(0)
        BetterBlizzFramesDB.focusToTXPos = 0
        BBF.focusToTXPos:SetValue(0)
        BBF.MoveToTFrames()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end,
    timeout = 0,
    whileDead = true,
}

StaticPopupDialogs["BBF_CONFIRM_PROFILE"] = {
    text = "",
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function(self)
        if self.data and self.data.func then
            self.data.func()
        end
    end,
    timeout = 0,
    whileDead = true,
}

StaticPopupDialogs["BBF_CONFIRM_PVP_WHITELIST"] = {
    text = titleText..L["Popup_PVP_Whitelist_Midnight"],
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function()
        local importString = "!BBFnQ1FSXr1DE2D8UElrxVetGmusWZDIEHiLtqPNJQao7S76FLw7elVoBiOwD5T7(2Dh8SZSm)y9TMC0MuQevkrjkfvrqhKFueuKOQb6PqnqsOrPbsqu26R6sc6sGyXDLRLlbzku(dk(((9nZB2NJND89x278((99EF)1NV)yMi)DPkqSjp65KJFpxjBkDsf6loszIfvjtz1I27KQRrmlrlST)w1cij7tTsvdtBIU92gnVHMH53mIuej71LTr0xe4GQvqzlenTgTHmyVUgX2wJ4FtPb75)QRUw)1DDx3G9CLU7EBW)ijh)p)1bMQUSK5Sm0CSHdKAs1vTR7YlUUl34bi3XH(yK6Byt1OMvnMaiTGskIPPk1eO3JkGEKtGwzPHxI7UxJQxsvVKsAthlsbo1bDJ84g4uo2R(Ia3ZoIPAfdZcQenqOQr9UyWI(I17T0LQa8cxWOjRdSSVnOBtnHZKtm84MsrIBzL4L6gtPrTSWlLrrLmK8MQfvZtxSlgWCIh8k97Tv4dEWRWoqD4aj2i)YTT9pboGt2RAnvDqHAtPf8UhWk87HKKC73txO8LupVkv3gVgdzysxGIeiR3Km1U4nUFtyBnQWPwYJ6EtM4QposChzCmRPwduABq3YwvpVT1IkBx9XLJS3Nc5(w3GEEIPoXw1q)UvgWHG6FD8C3SPLrE)DYxZ7Dxb2LL2LbSf5gRSHPULNGdpleNW27CmGJd3RHrfLTOQxWQL7pqPCSZVk0ppDztdDdqLzuL7sC(vj4Rg5d(uGSzgZWjFz8I)TiMviEucRfY1jYE3dQd6CE6GKG1LyIBusRYKkeFFlG6aCeJCSDIIusR8u9ce98(uFSDUqQt8OhepWLUrQDzQPLTHzfL(1iLUwxbGozPCVcqBJ)AUIn3Ri4rjTKmmRxMQMusb0tzSYuLTarp3TYiMg208OWWzDjzcrje9d3hdnbVmJtPvzXSSyPpCFbiVXt9PmriPUT6F)WKsQ5bOlkhccxwW0eBhFgZFoTbgxdAyagjPLfXrZMBk3XNfWHi197XoeuOsrjw2G3IDzvFbQ73ZLPb75)9V8fipa3Nz)7)eZn3Csj2(Uq3bFKOTysSl3k)mGy5ixylyu8MmZHg9rq0oUn8cBHFoF4N)xuy6Tt0zN9m3CFHeA5)(Ob6MBDmYX((YX(xEugebyMqtTAPY2liUhOro6n)SOeFtmZWAv6JyAxETke9ck9RA6JUDZpBa(un(ag07OgUETIiCOe24dclc4DpaW809QwSOdKeIzp5c)7EGqyuk3XMV35Xe8oJ(PNbwCNznulueeNwQGa6KB7DVu)meZ39sCTcimdsbfakn2OBTQgIRkh7NnccJUPQGtVl8ikZChPF2iIoExCB417g5lEXTfKx2TUbmhskndJcAow2T8Ecekh93JGDhoTrLCaPUbxTqQ(9gYXUWx1nkjNrfvxKfLHuRKRLmbmihtPt(LUfeP0PC026MH6VrITJjD1wkzMakCqhuiCNK26wqre)kVnUNk8WZR82bIH9iCpzx)2hjiTvUtWT4neteHlih)xvebrgMOrRzOr1fYVETcbq6JDeCNwJ7X9yhjOdt5Ym93iGLg3n0vyyiHrRnrkxwUJFm6FCyM9eWw9bUHNhWre7OdJ4eJcfpmb6lLsJmPFnhhD4q89J)rOoT6kgcu6utLwHe(rVTGDOTNBROmVCVfHF26diXwX6w2juV14wJZb9GhgchVWdJEYBauuG0NFCpwEHhw4giDxOwF67NQR0VrEhlLXO8SKWsIXohDi8QEN(6IHcdhyjYiX)v8DAjYEehzWE(LYYRNruS35G93InaPo6jzWDkUf0YoZ35Ga4ltJ934BYp3kwHle8bDTH(WSxyRjUZFPR8xxjlvLxmc80GCTw6pcTE3WOKsuoctgnXeFafbWx8x)vyi5uiDIs6Yyz6Cl9RlMAUT1ThrKr4Nclg5vpnE4lFaiFau5kuYwnvl1CQAnlehijmFVd(tybg9cx4YqEuOq76w2enFT0j7OdxT0mMMFpbTeWiyN7aDS6fCSeamGNgYb226278fN9kios)JdGH9ULZafTBYR)fwqWJkYfFgKSEjvQcEFdsyPeyY6fFMqo6iV1n5kRQuLC1Dnuty4FgWYHPOEQPzNjONusHA7YCR1tnDqw35IVo2QZfNHBJLZzHO23EAtv7145r)VT8LR452)vyOWBwZwTcb7MA(zDrceuarFVnl0jb(ta5jtvOkntOU9mEvfK47uLjVWcAAkJslQjwghSQyq6K7gX6YuXyCiM3WpZstyzGc5yNgtdwDzB0rttTyDeMldunTdxfcRlIqSeSNQzy9XGrgda9BwFHW9lPUSupRhOmvknh)yMEwFyOeXVo0XdXN6pScca6GW57Jh37gDFFUB8G9C5LTmVA9o1J9yhKz2ARef34XmDOwLnADgCGo5y)5FnkEO3VIV9TLCaud1zoi6dbvqcvFInApoxA7EqXOG1mfUXBwVSHwDH6BBHmUMPsmfcfBokPkMd3Z8o1rcrbgn2mOH8wa8c0GVrvNjjgRLfsa5TYpUYM(NBSyDAd7HS0k(CxxmEpJJraxS8(qbR4Zd7s8BZYqo9g8a4HKfQXMs0x8UPrELJvy1O6CekjpDck0HVFTBfwDt3WetHP(pCVQwaISvt3)PUCixTy76(erPGFkyFI(72iICNPmPGXek9scR6eGwzPBehhXHHoiGAqfqRGNh2vW6(XRqp8RG19hemt3VfquUuoMMgtWbK6(TcBB)r3fE5tAMNGZyWPzAhyLabYA3diRDeGQzFPk3(GqJu01WJ2J)4)dIysWprKcM2PzH3SkUKJEUxGz4tAHqw8v7JusZVZKZ9cbCxImk2Hu1BwCSc8HG8TaWiUBhqxR1ajgmn2Ga8hKMOZKc8kOMJd5BWm4ncUjq54R5PziFEZMzb9edRhwYJ4XrLo2Aoafte5lE8fkOjw(tIXZ9vJmpiLwn9LL)KaQ2qZhKBiU)QiQ59(FGe17cG2HfKJFM(Wfxf)EDM(eqYJSNtZWBnn0ZbWD8tzpHvzrhpXpm78vVUnx1cnS3vb4swAM2fd(GFke8fxhlZwit5i4uhPnhucqqyU)x2G1Ei8xM5Vr6wrPuxy1)x70(0ZBdoF8ARaAc5SI804CvZ5oaiUo7Pxxa276SXAS00AgKXzNddAzXN7w9pdA2)PD5La54NFdUbJibmihDU3erKCRZAIM5HGNly1LMjX8TdjeSdr(vFgtrc)9AphOmcNCq1OfDyylYrBSw8kU8(0nb))cqLiLGMKmj2))W5gzwoY2Fjm8zuqeR7omy)IB3(lfsK()(BaSn9WimLj0zBA)jBdRiiksDvlBZXU2pPMHFviDvtqFe7p9pH5Bsz4GyAPi8(IWfc5wC808aRgIJPbEUCStIfqFsOR08gLa34M4cWkIN8LMa3JVdFXlnraorRgHaMHnVjOpGIoc56w9qbGMgB2ddmSVm6gtuaQ1S1vyaeklDECEsnK5kMZh0KJoEj0RYTJMrGcb8o9JxkKGePupaElgel1rSG)upGi(ZB8GOMFi1IuL0g5n8vtWcHT3ZC9Z3b(6fbsYCYSE1qM2qJFUWtdzdJM)SOeoi00avyqRyP8)RRCLRxmVF(Zkh5z)EOOXkqSP6aFCihr8tDb8oZhnn8ZWiUDSzQd3xoOXIH9Q6NXv77nadU0KylmtZF9cSQU4QMjNU1hJ94SOpA(XrOWMD6zpEqhYmFP5RZ)sc68y7gNL6SBkNLkl)DM8eyl5E17ExHefTD0nz2KGIhs23lTiufYI)2GaUs8Xe8(8aE(IFmrmWFsmrZHHkElqzdp3xB0Easw0l(lyWjuBsfdZQLnSu9Nr2f)fbfGTRVmWqUrX5b53H0U(YTwiF)EqCYBsmJZ1wOX73ty(7RCwCdKNxklS5VjW6L0lXfVvoBy(uF4ZlAaHFkAavXQhnhqtTsvl)chvVlrSQpbL6QRCEVeK0G2IYQxRpnh9wxUmWSCS)WxJjfzmC0Y5ycC3lTIHUAEL0QM59lreiR5flXooAw289iQGxLJ3eD9X)2XrdrGJCOxhLjVcv4bPh61dY5E3sio0OK6OOmOrv)2Z3TuyQ05wPxn0ReRHuSg6SWP6xcD08y18tNeAUMTAteMb75SpXt8AWDyWE(Jp0dDqCxBI08wjof(U3A8iEs7PEQG8Ep3(rn0YNFn3J5yAlu09(dviw16Cx7Qh4aVMRrJvdV)KnCt0wFnUI6QKJ0dMxT6n4MsY9Lj18L(Y0Y9ulmdZEX3UvJDWjEVhmGCo1)ISS3PhK0rP3MJLbEEi7CSVX)ng4NudNz2yQvw8(nbosmekotNcGkyVszZMh2q1csJx)841F7CTB9ZVqIUTBhjzIf74VTBh8WAdj9h47W1wyAU357IxvVouDX3AzmhqSCSNBPOPAz9vbQld6fpTrLko6cLJ8ClnSJ7zUkMHiPL74Nk7wmbBVFMRgcM(RIDimlZQbLNLSqTMVVtynbyN4tItiFFzifPLCAwKa84WmY9YEBSDmai(QeaEhoJ(QKtJYH5bccH92gFcMkHvZVArvOW1bmHs)8FL8JpHaQN0zrqe3VFanxCHgIv7HeilLgFNp7lLrH6CXiCVoGHBJ9oC(2Uh6T1zyY7SJYqzG)IrD4ap0i5PvWeMPOK8GXK3Q(VbFBVnEiUA83KjOSxNM92SWOdLm2nFx5NEdIG9N6smuLmvvnvTXojyvANKwYp3iqstgs8g4aENDevOlyt3VgbJw)IYaQtS17gpGBSFtQ(KQlS5bKQTE3H4J11rzD73fldauarbyJiAybqJ6yvEba8)WZH5c8(AtAzidqMCK38NJipcP54(8V5ppK7Z94MOklPcQYYJEKMKfFGxaFYr6Qyqk7b84ND2Dvmmpelm790mtAVQZBoeWsHCPNQbdiVVkSVDhqZbQVTqjvB98obwE)7f18V)9Yu8n6QvxkPB4qz5VYgOeHMF(r4kHjmNcNRxJ167MDzb)YiNFs0pRFdtBV5uNYKYhqgSyi7B0VXfZY(4A8FlC3FZx9hSyiQPoXYVM1fLG9nua1U5b2aRfMS8tpdZWafk6)nZWLRF6zcJX)Zc4r2CilzkB44fpfYuwa2KB76rKLQRWF0TELe0VQTnviMSvyta)joc(AcNHL8fLxX8Vh5HddB9c)pSegoMefVQgwaGjqJCSPUJSyhLMKsgSHhWvktDhbGyfpHc6ruJdRLqzHeL4e7HHhCcg0F09nKA(Y5mm1B1G)sCC3pkkOnXCOzvH5sz7uGNN64pEiYPuUJNvSzOChVHFsTeV8ZZ8w4ZY0nQ2BxF5NpmT3F87Ya6H)ckXXalo05hOejA(U)7VpgkZM1PUEIJsTm0QTOOmiJ7e)GchREv60eW8SLYQ2unvl7)Vd!BBF"
        local profileData, errorMessage = BBF.OldImportProfile(importString, "auraWhitelist")
        if errorMessage then
            BBF.Print(L["Print_Error_Importing_Whitelist"] .. " " .. tostring(errorMessage))
            return
        end
        BBF.DeepMergeTables(BetterBlizzFramesDB.auraWhitelist, profileData)
        if BBF.auraWhitelistRefresh then
            BBF.auraWhitelistRefresh()
        end
        BBF.RefreshAllAuraFrames()
        Settings.OpenToCategory(BBF.category:GetID(), BBF.aurasSubCategory)
    end,
    timeout = 0,
    whileDead = true,
}

StaticPopupDialogs["BBF_CONFIRM_PVP_BLACKLIST"] = {
    text = titleText..L["Popup_PVP_Blacklist_Midnight"],
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function()
        local importString = "!BBF11xcCsr5zE70901mQGkYvlhXsnFs2KqmMSgtWymZndmdmoZaeDxnwt31mt5uDvDQURzO5dJlKvZHBo2OzZQBmURzZL5NMOHiRAoeeJMSX1ErmIhOYGiO4ioaciQW3)NJQ6Eq)sYVFp60V175ZX)NJ33uZ52ywRIwFNK1Lo1TFJFQZ2jlrB0ZkN9MBPqbBVm2MngguO4AlmO)iD64zFv1FVF3ZfTdKYjYpTUSdk47z56Sk7SMRW2Q4G2bPnU3LYDfOLtSXU99lAUe7IJ4hmu5AVQ0gJ3G8RJ3a6HPSCNHTY4uSKPF)MTg4xOO0Mg1204X3MoCgyqUn1UUnZTb0Yjw7kSDDnB1ol)13DpYxF39GXVLvMXUqHQ77M1(U53Z47hKXMBZ9Q9W9IEi)P3tXaRI2d4KXSDV(dl447XtGh)XKjWJ)yOrNwJyjAB7zITaZwkzxGAsQ747lBQ3X3hnzgT4ANZ2ROLRztdA5xybMTyfuCqUH796LgU3RVCI91T1Q8dWm2AaQ5CpvxTYUgO0SUz8HoEdyUWWGaNmwE8So5Cxa3gqXosJHUUfSljRNJOR5JG1C5te)P6x7jq)fqqtBYpiVFGLl301KrA6AYGbAMTpGtG18ky2uqOTR5sOn)Cwb2YI7M1f3n)(U4QSJ)cDiD5l0bnyd6yUcRHL5170Y5Y)Y70s5e3E32fcZN31XgCx3OWKDJy6MkTXo1oyNDOt)0g7w)t7Ud6eAfofY6NJodPT)vy5kRLD2P(DDg)D7Cj6FAjr)PAp3JkNJN7rrxnRoTWbnwfT7vmGpRnB2kxEBp7aErVQ7GNXGYCgod4fnQDaoeFV0gROGSMwrbscPfVmw5le6cgOSMnBxahBLWO3Lol6kEIDYFv5pDYFvW02AyaZr(fcTjET6NZ9XNwZ5(kN472K)Qkz2QJCiySZlv7PlTsp910E6RH)0S5)0JEzYF6rVmIvTt)bcSGWmox7msCY471V0KVx)utwHdKN0fwZwJWm8g)1Lln5VUCmfBeRf)rILhR)EVj5i7M4JSeh8pXTfuCMVCFNS97hKJ7L)0FN0l)P)oA)PH8(y3Uu(Iq6QjFVVuOTW0K6WFhH76WFh0SPVIaR85Xo4YYJdgstZWG9NB3wUfPDB5wkNy0wdSTxfjySchVSSGJXRQt6xft6r7zqRSys3sU(cSur9t(BP7wFlmoNDdUe)N5kcCkuCGqRGS0Mqt(5YB5Hd3cd6KN)ONrxdpdwd7dQngaFtV2ESMeUbB9VxAWw)7PDZEYd1t9JJmZEYdnK8ax3KfTKGI(OxBii3NRT5YDkynGio3(6fX52xF5eb9myy)97kt5VJVWH9D8rNFgRWkOplVSMDcPp)amr6WEyBxSjKo1tFRYEZtFR0Ey32UOjUK2W2XgTtbh0EQdt8cIQuqXblofkyNbA8u9C1vBpQQhOm82B0pxFyBXrfhE4FKmcp8pIgHk6aAb9VRtFboHYHUHyDbus9vBd6h66uyWjOpn1o(bsFTJFaPpPvhYUsXslWSrxRmdz2L)izLbnX(fzyqlN4EAlqw8U2YMZgTLrAJ20irCk2bGrV3WI2U6oBQDO7l7G2xMwLrQLHDkKXMu2lSw)hkR1)bw4n57ML0P5jIlB7lkdZ2(IqKK4Vh0g6KLzq)YXZg7NxRKQdlxmf6AqlxlVvM24HurThIAWmBPqrBSTLvSgaliG7e7JYkDP6kLSK2l0bB2iggL13yJdOl1baR9YDwLdVs7XA4HzMWu7v3q3l2qVhYEGDriZkIH1v7x4CLt1Vq5eBULvM3VaMcTIj4qPnEmDc(y8kacnflAtCwkMasC)PzvRGq83qBuHIqvGn2K9S0DOFwEPt(z5PoPtlW21m458GL0ODyJRVK0MRVeyXBhBufDS4f(fEcYc)cpbAQ767NfCvGXKN6NOOnduAW7aBh20EcTXb8iSSZCAtKDMtB0QdNU2MDz7fn3s9BVtzN53ENq2tukucmJfI1gEbFBzIDbFBwjvwlOGAyi(w03ZUauyj23n((Jin77pcnt61jNnPedCCdO7tPtEo)rzMCo)rmtAeFoSpcLR6zyYpEtYp)XBcNH96x0MTIb1DcWGeB5zKnIT8mK9gy3FOC(WMeP)FeSlYcegFpDB87HTXn3MRTvoA7OBRsYSmZ1lmKzUEUpcWVxietrZfA7Mh7yGj4kvr8Re7hDAhKXHvtGn(r09Z219Z2rxm1UcidzWCxyHQ3wtE4VR0QddWHBgnkJtbSNnOVGHX41u2QxRF2Yi2M6lmWJMQTpGNtK(MAN9S5PlOW0rlEqrbSDM2yhoYxVdhWs0qMmUw5I1rL8W3OoYq)sFl3hS6IiWtRh0pnoOhTzBBSCH9Sbgq5tQ7KSKf(jzr6yDYmpWeXZ1NpNmApFosXwVJ4G9ClAM6va4cIXLzSELdy9ehWmBkOubWOItxacmxE)rSdOMYtXN)FtMIp))gDkaM9vcmxKk)gkuWk0va1oC9CJaL3Ie7uehrJJaUFRCzD4rDuD2nkn7o9MCHobbcBxHbKKmV23ZVqw775xqnQr6eL2Rj2lskmqgWtuhWtK4GRAa7YAEdfYnzDhrAY6oseeJ6MCwzBBYzb)YcjnFLmNae8B46Kj4nCDKUCWkKZxoHPUUkbTKZ5XugRhJmpdZchhU3jBRJeuNx(Vt67Rx7BIDE6hxF3JVRAzV2HNKU0MeT(RAPTymcZBewrJXu(jISXu(jmmdFXIVLj(NkoyjtGhOu9B71PoceOQVz7I2zIy7sD3)bzl(U)d0U3cTcGnnOKlJtEIfanP(LEE83U0Zd8Ylkm7arSdg)I1iRIFXAWcNDYI31jwgE2VOzjsblAwuxt4sSi3XG6LIb(UPn2VQED)q963TNs56ZXVGdVNvZf)B5FcuiP0ty2SWOsZ((cJ9ybY3nwaRBpe8RyQMfJm0DNrqVCj)qPnxYpKgBsPt)qAZUAfSh(MvbUBosbDbB7H05UX8LDEJ5t4jG(OGmweYxsLx9pY64DKhzDG1zXIMqZoTYmOSHL24F9Rld()6xNo26Aqhlgjkz9lMTj1oVxzJFN3lmn3JTnRVt49QztIGgOypVtlplanJpStnNxv(Q58QqlbWk6Tkz9(QJimbVkjepTEkgIDm(4Oha6ITTK24X)YY06X)Yy)(YXoAxHUIGMXHlkF(HlsEX4KfI0Wwf(MgUD5BA42XATRaNCwm7DMIHQluh9xltOJ(RjXeXxusPk(NC6hUHeZOnQCKckllBXU9LL5MB1YrSvyCRku2BLGYoJUjJE0Aa8nfNqVv7LCUY5ZLCUG3dURbLBDBBfZwN8V9)roC)B)FW8UHaYbtmm5aIolb23w3GmD26gqd6imZqLmxOFqb7cd6lBjRvC8fusSI8valChBak3CemDn7sasNCYIPCqlZ(qBLreJxUtqXqzp6qpGmwh6bWyr8IaMg0ediUfyo6u7wfc3necVDGGPWG59Dud9B(HLFBZpmTsGKt(bHJgD57uqb3ojr)nOrk3sTThs(MT9qyoDgWToRmLI8fIDQf6plMrmpVTxMBlOO)BkaJT4rKxegTxETYgXlVwIrnpyocIS9xZCRN5BaLefz7L4Whq462PV(ixjFdvhXBaDeRTBRSSkasg6gzy3GaRwDdW6HoIsL6(DcNyD)oivYS(9KNzFt9ZEszr9ZEsCK3HTvEsIPvsQwSJLq2ebLmW3tggKq0QMW3k7wxJUBDnXEBA)tLH0(NswyduShS)xPnUfX5mqrVoNMzn1zmBiO4cm70Ncwe7EffVaENFl)fzsUL)sflnIyhOX6)nEqPtnEq68zXozgINOTcWkSUeFshR43rQJSjPhpYMi(li75roAwDtmYkE0dkaT0Zio9xKSIwaBPyuxJo6RjE034njJ(gVj6qRj43b0Srr9W3lREmKAh)fjib74VWcIWFmlwnxZWWJVhoGBPKDAJVPQD4BE7upr6q5TUQ9jYy8VHm5g)BG28bJSHhFW0i8hzv2A)2VlX5H9Lhw3FEyA)PvaF6)V7pgFpDo89UDY2gC03ngc8v(RKF6k)v0IaaUWsL8keDbuPKDaiOjMON01PmfxxmtXyFt5Bh7BsCtlXIu4rEaf4xL1ZAB7cf1qTDHmBCw)W(4HUUtv7Xtf94g7HCzXSkT1Bv9LCRaR3OQ2PUGIhpNvY7(392KZ87EB4aLWAKL1P2UOZn5UfyrGczKo8Hw0SWMTIzO1pJmLA9ZG(EX(d7d1nlgI8aXhlYEdFC(3bft5fAfcCuQKXxt3e(AX6rg9jK5XOpbTb2Uxwama2aG3MqXCtwbEQ7OgN0FwwqN0FgnCURq8WZShp)rmBdq7ae6qpE7MLvR)A5DhqWuOf4SHNyzVgVvkQt8wjXR3MJRNTvbs6kxEkWuP(5VKmF(5Ve(9zvXWQn0kzUCyyhhUUrbW4vv28xLyZNHI6WvJHvqy8HOXd8Vln8b(3jU4L5fWrzGxao26c8aIFbGItKUPvuVqrrb1kyIDX4Rikfxjk0uMCGCutjkF4Aj(W0Vxtjllitrr)HXH0j9HOj9uBdESB7nafjRibh(CX9qY(G7HWW1rioqGlDr(RLA0Nrp1GdxLVvMPywsyebLJ7fGYysGA0yyMqoMbL8HnxE7IHYSjP(djPZ)tFPWDN(vrWwGNUdioOS5xugUn)I02xd5aWX(lrTPInkJlsCHeu6GTBY4h5OFR0exHGCl)sPj3YVenbSZw957cfDadqOL77VY238PLr(nFAwnrGFotY6k1NueVSlujw7g3IEgCl0zWz8E6(UCG3)a6mXD(ItL5oFXPgjhuZk)0ImZk)00b4ITClvCqkMYQ4d(YmdzZXq8aECmepGhbAyfWRIcZVX53g5ZCho5nB0Ynh0ujqMafhgD6l(p2trbyIXF5Ni)6FbW53x75OZwGKdgEC0nQ3sahckXIePlK2zaJDElhPBgvI8dOCKvapemCyUclXSF93Le8876eyJkC8hkCCjW42Koy8Bd6vx6kPjOYGzSxvGzV)7SWazuhC0(zeUMuR7nKJL19gKYG2ZqqZJevBYpiimFrX5Ev26(0t(7dN8LfgVt45L)0j880(imoKrm7gYEFuXP5PF1C7aLuiaqYei8kgx603dS62bcJ6fFAInTl(0K4tZ6uBZAv21BoBE3WKCxVvxCqT0qztiXlOsgVaf4qYhHmbwIuDQdSdzzEGDqkXlqX9Qjl46CjDd8)ZtjF7)NNIKlAFapBA8wi4in7fGO42SRFQ0MD9tPZH2jvHWwb4SAl0rcvAIHMHOAzOzqWVS6hQwbFNyL(UoOmfURdsYN9KXkW1UOjhRNkaVFIXKg9eJHtRoHNPwSg1(0iV8H3QyF(dVvWV1wGFOxwZEgYHy8a()VHatgumctdUhc8pXqjrRvni3OI96gb2Rnlim7SYoFYvl6raL8uKcgQFyrseTpFEkUXditXnEaAoefA1QmyEJkGPB8bPJokm0v19gBADYVUP1roRfqwtRWTMAh66FhJr7XnYUq3QFGju0bhg4MC4xrAYHFfwKci)iGLLwa5NVLNAqj1yVM0QXETy(0RSSmYxzz6aak1hagIoUWMyKCxsJsUlIrqYdf648ovIqTXMwVUewpfMuhiow1sOM8hvSlMNYVZPVmVSu8TkwQklJBw3b38bOw0yGC(jMx6WPFzN4n1fWB(Aey8bTYxWpRSdELBwxhBgNFljeUIJpghucR8uFT7KhFqjUGvOjvGybwMxgFWPIp9OcOeqP2i5lGzeILk5LYQ)SYsz1FwWkqC5zRSkQj)X015Xit29oyiTsX8a(WwPvg7qpU3X641kfsAshdNJtOtrGf(DKS3akwrnqbJeInaelZ1x)1(uSA6RLfnBa8zwazNDEl5ejTXbVB5Rp4DtdHyttD)KuHjsMh5TejZJ8wuJ6f8DfGR282sCqqQz1xSUEVyW0SvOj5nunkq54TVOqkoEEwI2MeR)KLoC9NCmcSXoOOZASds8CPR5p(r4MakzDWdihlkwsHDzE88wJcHAnSj7GbiwbRGQ2K)jI5hqjpFTT5dNkgR)Gxb9ZFWRaqlzlTaHoWkZtM5(rLjZC)OOVND1zoS3rC4OJqPjNsGEIxqCAeuYLxkT6MusoA2oJLimn35R918jrUQ7REY4tH2fEulOCafBvnKNaaehGOXgvwMJnkL6PWcdg6uzjMy)s(qbLrFBBLTuf7tjN2Ws)oTHJWM3xaBbK(16oLFTKvHtHcOXPTq)rIZIyxqVf8SlHieTLe8ehoQ7Y2BwITlafeOJXIenkGcrTf6xeQSLnXKh(3l)YH)9L5aUNpEDN3wGau73EzCtafnbAzTPWKtAKkme14w8YYX2UvSR6Nt97SwDwvl4tEn(p90jL)0tNeltrNryqGQuk1vFMYVE1NjnnqxgYq2XH9iUAMX2skTptf3NpJomptTuflaH3(1S4M4E(NLT875FMcMh0GxGsBflkUDjAeGs4bwA(8beu2HTnxke3yRDWHr3Wi8R1DI3p3EqHOBhOHULm58kOPdDJs39QBCcZ8E9J14MAdtwMMByYuO9a6lif4P5ERMXEjL15LOi)g6F1aSEfwNdihVGIvydWuvGQ(VgV)rvY6Fu4yDX6JZKrfTWRBFY4UU9rXs59bQZ7Q2jFxogfvsSwlRmpL5inS37pHiBS)emlcfwlkF(DBxKyfsB8reL9GsQABLD4fQ)k5AVatHBx2fovDx4uX53HyoldjweGItjkchaOHcxXqKzafZDoAUteNVXUum87cy4hfiRi7Va)CKtj1vRu7gGYgacD7pmy(DOrMLWhlhFxNcP66EHiROjQ5hZRxqlNOVg)yTI)BAJ3wpMFB6yEkKJ9fhelFa22jo0uj(VL2K4)MhsxRqStizsdwdCgsImunlzpIgVLShAvpOtGl8HrIY)Kvd4tggW3mmnxyqXYNOnT2hvQYbq5d0C9zb4vEegprpuQxrY2bO47VCcNpbIosvtn)Ej7NGs5gGZyLFvvaKX(09099hzEk7GaUkl4KS1tESayvgt9revgt9rapzB(bqzwOiI(mLv5rm9V9fcFy6jZG2IJ(gxNOIeu20HH5xsglZVeTH2soI1llyQOYFkcz)4UAWACP2Sc)vaEZg88Gmi8ToOu6uVZptgW35Nrq)T73NYJwfymg3RYeDV061ggdOTZyp2mMLYKnRJsb6K)4rSC5QQk1ZjwUaL2lwIDiMFWdCxsVqGzNd9jtBCUkkPZD9K1jy3hEu55fPM5Xu1mpgHb1f66yasbQO3(uab77pf7wN31Rs0uAyMAJoUdizKSkSghrIMcOK50kjQnYptEMFeLj4i1tbqeBMk6PSAnuTfneEBztKUr425qMTR66Q9tPcnFQYj2Anj4J75SiEAbkMPnM24jvWzpjaNDpTSsmbLiWiNy3N8JJFFmoNmCYBIx1P2Yg1HEJXr2QzXSkOLNqQr6zqa(xKk(DIJ1GsBmDhwCq2GtddmaR6wDSylAKP3Ydh13jpvnS7N6)dX)0Bjs5EZ2Ue)tmE8TOrEFlBiEkL6UKXl1DXSMX1Grfq(13TKZLUxh7LIy1ecK5IWM8P)SsV(P)SKBsKIYCAcSW57xrpN)kL1mqxGS1wnMibkhOmEpmvluKy)aa1SXt81pxziw)ClNiaqSlwuCrRUK)zbYqsk6xttN0lGeGrJiHz8rJRkJh)uPTumcoKB9n5d8ZbvgIXoS0QXoCKYX6mKqRbkv5uaflRBM32oDXcpO02gfEMcCzm2OFFrz5QM)jXZjqbZdN7HEcZKXxtDQp)JGIH7Y5(8LFcrdWltH850QgxwxyDLo1U1qcUBoKqmoxtAKhzqB3CrXN6jtln6jthlRnlzZduQFPeUe1VW7EwzBQhqHK8aNjXkR7qCa(f(MRv5BUw0dNbH9nGKcOsaJwwvh8IKZuJlWmVAoaQf91uFiGpn(6IJqGwMcVq1b1NwlUsGGsBSgTsCwdvjoZSxy0qmx3kHkSvG92QGuThgRF7slx)2PTLUd944Jomz7JkCor7391I0O7JQvq2lwy7w(TApy3YrXb7MZrKNKNxCEp)fjjm)dlkzaTmhQGOYFAEXXfoXJ(VWnbuSQ7LIcjPiQnfwPXZPs1phjvpRwd9gWkWb6q7SeS1NHkrs3WcrfKXL(osJV03HkNt2kpfe3kbx)qsMoaLwXl33TOf2dz40CPzWn6f0H8fOHCknaXUmCwj1ajWTzts8dbLox5uXhXASikbHWQy(ixPxGYXVGKeWUpgHvWKspa)JjNIW6MCkOJs3tMqxb9vhsv9YrBe2WQBYIVjGgNsKr1OdokfDWPevonnKjtGDCS(x0)a39GshaTbMKQREK0Po00f(ZdnDAdHYdFCCO6IAjpqzoImhZCe0OzuvHS0bzYFf(aujmv)gAOJEJNkkStXsjgxHEWCf4Gj)CICo49RinLnLPknp5uz558QOsNwzJmFzCfA(0VcoF6ewvwyckVHR1AIzhxTbn(MP20fmbzjE33bXQkM58eBLGIdN2j7Yvq6K6coB5hVGZUmhcdao094nKAS(rvPOrjRHFc(dF57q(Wx(oyZvodtvMYerTCfVTUaEB6ZAIpToMu0KGs5eBqruOcWRmVREo8Uu5tz7kjk3H15K2ydFEPd3WNNuw37GbvvlPTgVKoOEGFWPZR3jgqNKZqzgNbBcfaGD8MNzNvejtBCB7vgLBBVL5Y4MlCpxc5QT3a6((Vt8fcuA13cv4wscSy4fI8JI5AtaZv5)l6pL8sEhbbXLaEK7PlOhqDWfMOeolqPTLWC5OkXY2lOKGN8P(5Ys6P(5u5fWyOO)ED1Sv5ZQzR0uTrkSnohFI4sMw50stt1gahT)qCSjiqysf7njTOBMu24aCCNFmzeVZpgv2tXLoQXvk(HbkLGFkT0tejzYZqhTZGuHdDa8VtX1RHIfP03Ozh)u)RYqEQ)vwnvCjggcVqZzXvls9B))l1gqG0wlRCqlOfu)8enlo1aAzUcKSYOOLQQeSmEJ)z5S(nGVV7RfVbahQGsSrRbGUpjoXGsCNlqM9tx5oiDftVbZMcDl6mS6nCt(q3c0cCZVP8H38BwMZlvwNc5dj57UdJsaVrMKkFmbbygcG9Z)ZuCWjGA3ypQ1P9SDwnmhJgAFcMPIJs5cfFMbLTjszYvxfnee4pqSW23FHs7((lS87xIuMG9ZZBksBpVPWB(WFJaRHgYMYFCRwdlGqmEaj3zGY42P4pqb3qRYZupTwFUp9pI(zBBxjTXHbci01EXYpV2lMQuiBVcvf8T6oPNvo8pPNLmx4WH3GCiv4mEgLZGQlXtlUmB7kWpRJMAR78tQmNFsm2l3rQSLMkLrW9n1XUgjSOJDn0wr1yLQoD24K81vwGxhSaBMJgglw4if5FQdO6gpWztfDOR1aH2vfrkJwwNCg3cfVZ5Se7rmxIt)9B7zUe)53Jh(hjnl9sqysB0TecrqPtrXqwGVpX1qOMZhXYM8mvXho8pn4r5ZNLE6jQkMQBsxVkSE9QWA935RWrn9oFfsRs1Hl10v6nt424ODh2xPJtbDstD0mzNukcl2KJbHsbUNASJOb58iSNQPERZr2pERZHuoB5nqiPZxYnb)bh8dkn4GFqUIub)5iu5R7KtN5f1zEXy1mNXxq(IZ4lqfpIQnjU4rQF7Rw0aS6Yj6UhlnJ4gBxcIhOsirOQqZVQkCl1g18WUr4k190QDb21SO6c81flqGIFS3aYRVkfs6tk1XfO0zQeQFZ5d1sb2dryYA2oJtLId1iHSJakM(lJQdq3jCfaE9DRmy7MTYdefS2sjEFcaZZ8FLBcOCkA0Bzq3qEq2Z6t3Z6l2RSvziD6QmiDlXPTPBBhV(P7zuC42UZZtftopsdNaxD)6mA)ygTrPMNQA(ERkERBLWBD6r15vdzV6WytO1)3ZvGbimNmHRKcicxE4UdxPsW2LW7bk5DSaq1wLXnEnTkoEnQtMrxwzIHwgDRn0KQEBkgOBJWanvgY187X3AiwUr57QFgCT0acoeIsssLKCNA9k(N1)zOlng5cqvjPk1gKsfbumcZEHa94QGTxkmvzflsuD7eHek5SfTXGshOY9hO9m2LGD)iv)3VCfaaLSqcBgfkqUmhF7Y2LNUX4rNkRLzZFowaE7phvs59vvOlRLRTQAFsAWAI0t4oX1MXU(8IoODber3o7WedBnDQhssnoOW9ug8oy5Kn)hvTF9OS9RgQaRVnxlhnXHJRSjJVBUnzc87ZQi7hrC47mEsnCNpjfUZPYy4ItWlv3UIwYFVuJVGsr1NW52x4aWdcrsD7INUGYciu2PaJC)UvvjS788LMSZZNAs705IuufliQUmR7eLzlOyXYmj9fbq2ugaqPY0BvqoEc6aRF7Bt263gzQiABpAzSyhOUNIGDAJd(vK(5GFfwXCFL4tv2CSorRX7A0WzqMDMABEaewGnmqxjEg1Dk6e9uOT1PvjGkykbDVrZPhGlQfq4klxCcUjNa18MX21AEz70VtfqhLbe6(xigismMuJtGYcxCOaIpxSDlumqly3BlLkCLcnCwrxltTPI7nxAOTTCmCyvzYHHYKBVDQSOTkgXT8G6nm7b)Qe3cDTHiuWuHyegzTm1R)jeJjV(NG2D6j0HS9Xw2Y5WHJmDITEws8M36zrt8jK7PHCGg8cukSQTzr(c0YjwlvEgXWAgtIebOLte0RDU86n(Y4hwN8d)W6OWF(EQA1enk3PdqzPAQgyL9S4kGn5DjrGf0YC2nO7oaD4rHrkeqj2Hw647GIz5PTuytIVwlYjSO7yiPehbLs4pCm3MVVz5vr5BqVzQ3qJuj9gDQjv4gVdEaf1Zb(Ku605Ca27G2(AU8VORq69l6kOiXXEwlXBpcW2w0KVSfs11P3trwEUfssd2a1KPK8lPEO8LiVyNw1hbTG9FjwZDQb3Utk56tNlQqg8lGx0lSKmKOiS()eNtkqOneO2LVgEsQx0QezOVSUH8LXjz7zkz2swXlJeB9CuobYUA0SOrlkYEPnQvuiaQGrQWi8EDxbwLuyujERlroqFRlHywrp3B8D8X4(LCLbkXSwfx)LfopxvNZb08PDGA5c)1FekR)fffgpVOW45zw9sb5OGLxLi(KLRIcOXrX4(tjkPVFkHDZoDnV9Q4MakLCdj7fY9mfn)a3c14dqL16PTqFp)ag2DVuKJHhWltXhUmGp872b5OpLtpzuuyb3pblyQqYQOdvU5mtKt4QSKs64aFCDL9X5c)Da7OmfMCORvpnUwPGJZmKReCPOGgTD1UX2FtEFFaarbJFdqJ9sZQxjY7xf0U)6iESf74XrZ44Iy25i1WpOuJwAFuzuA5DCqt)Osc1bL0njHSLsjHCL7CYcLMCUh5gVgPwCafnEMDybxfSK6ydw5nPQKfc0ulRBYo6PJt0PtQDPEQSl4PY(wMhDDjXYgU8gzaAmfn5yhkU(s2MCjYaT8XD3CAYNUcxzihEevpNKQ65KIns(EJ9EITEUk)(5w(4Y6Etu8Sj1E3GCVXaLgYg8gWfm7ZJQCmUMuy4kYKRHpKmKn8HQMbpwLaVpmPpGSpmPpqmSY9PbWAFVdRFaMId90afyrz2MB0XKaYdkRMRqbOifYEl3btaFHpm5vjnj5vrYUz077aBoH)9rRr(9rRH0YhhVoUOjYwD9s(SYfyduMHMofXqjfxrLYO6fLRQiOSU7QUlsr3U4uNH43bOewilh347Q4u)2JjUk(ThJCLaNGdvs8031kiDQJDrYhESlQmFXQOqjXmhKVpwIvNup4ILg9GlMMalZZ1gUXq22IltQuVICf7bL8ZKZwAtwX3uVuVLcq9T(m8LKf(z66Nhhx8hNO8hM)vqlNOVw8cIUeVNGyMhuAv5uDDBDHcthOuYYZKjmOGc8ECncAJtrq70R(jkOIHMAhqCThuUNRQW4QREjDbGY1pIR4BEJajUyazQ)WjjBO)WjrcyPt8nKsHdu4gaLzBsiwx41KqUSzGsZgwBhFV1A2gUrR1fqTTlb0gucIlfDEUqz5LZ5)jKLZ5)jyTeWMi(Fyc1b4camU5xDPxwxQ3vM7PExc49tZDGMsFdoL(tRDx3qUciwSpbWZSdSJaoR(voS(FpCyHf4CKwBBY9gg0YC2z8QuQJwsaFtDiX8oOusaO6YrayO5lCVQvP9wl51aFGz2f8n1ALSvNFhdVaeYdHmUoW)im780ctj3pwg(C)yYCvixwY6TYk1Zl3VsqPc7YzaO3WSnFIiAlEc5USbkznNylJDfJt3MFGMSu5zrau0Uz3EU8urgMv8vhqphi0UkWm18zKigdk1Rewm6zGGscAE6w0f7I6Nlqqf(5ciFZSOB1PK640gN6NtMyN6NJnfsXbIcq1sWhRz534OAvzF0BIorVk5evJPX(nXNLEzWefZsjaQiyNXfkwQxB1Ys61wnPGblDU28I1GhfKefxws6fdz6AzTXUfJTQEJRGUuF(csV95PxNHtlgPD1q8o2CKU6yZPmN2fmiCogn)qurY)3itklDszHZlkrlYT7VOFo5bcypY1Qeunzvvs0KXlQNLV4KO4EqWwelVYgJcDy)NjTzThEWUl5ssbkfGiXaCrtohjYAFMA8qNjjF1aheoPc9NFBbusGKd0sPtE5)tI2Ol)FcyVHDbOEuqu(rKWpdkuM0qFHEXzvnXipSy1BKhgQP6W3NpPsN6jKhEcqPIk1nCL0DWVyK71V4PORXtHwg7J)BVPynduw8JJU2eUu5PnUib3dOKvh(wqhN5akHjJusFejoMcH5ymeMQpJwif1G)gPrkwRJryTonUr8d6XhImxln5KLeFdACw4)1YLbeuSv0QTRuqkPtSV)gUPGs9w0vzzy7k5fPU6LDrqRO766MNmcx38OWXLpaY2agvfGljNJGQauIDRI614uJ9SspaknWsncAk3U6OW4CIsIjaTSCtYYQrdhC(s(URFoCsiaHkiDyqiFCC4o6IK()OlcNKuzPvv8dQFAC(raHaIcJ7WtXZIxxnR12rZu(Qy)xgXoQO1s6ibsf0YCWVO7VpF32HxNu6lJZz1EuEI9aEIr5IlIeUR8U4Ci5Qxakg)U89GlH28T8XytcRmOS(EQASC8MyLLSt5nAauAxzcXKOrx52fAC)IPsqzEeZw5R3HF)mIDPgcQFg6P6miRPsk0MqPnSBj7ZGsbunmWZSOVjvt7YA8hOHF8hComJJpxhSaRSRRVUFvJ7)Meucx6wjmNJpahrpmeDt(FN6yIvmqlZH2tY3fT4BilxedSn(6Fc5wc9exhV217ug1JvEbLUn5UqakBwniGUmcKd)s9o6l1jVX2pnz(V9tJ0xrfPpa1hQxaYTi22bfhGTdGzYZ1rCO4M0)PWjmP)tYWg(j6QmWfNfZgvBlYnweu1(rqXc9r1GoBDfqGKRbnOKbn(EizLP4cate2(gPFYqOuFYGhr1iDOlLUyx0QSchzQNtdH9Z9fq)CgTKzqFB26pNcyk38zJHDN8cNLmNVWzr3ONm29hQLk)ZkPAau6UNqxVYMSkKrtLyY5iXvhui9N4e4HDlYdfdOL56D1LV59hxmhmwJQ2BnKAVZQNC0fxkGVOGa8gFWPZvc7Tu8AgJpn5BgFA4BMBLnMMakVmom8GM9d88hqExNQzNckzqJ9LytQr4nzsQRUiPBNU2TtNweNj)36tf17JkJl(XFOGa9i7WeiF1XZ5PGwN3NVCCqxNywYsLwKzbfZH1iJN6u44KtHNzLLrdWQqU(CJVTe0B3aRqA6C4iaHcujNXkIB1Ibox7s)dc30s)dyawA6KNTCpEaLpjDYeHNA8zQd7mPL5zZ)T)f5wrdkAmFBTLRdFI3r8YfuWyT08aKewvr3RHpRaWh0Y8BEro7SovDhB6ugiqJ22R9eLKQckz7Ilbx20vunNWtMBwYSlOL5BgUK9S4QyMntiRenXXJNoELuJ7nRQtOxMRPvT6KUTYnKf0LKo1llVqrGsceng6oIwCdDZ5aGhnLVp1oKOwbkA7mBRemfNXpVtgZfdqyoz5)nnI0Abtm(uJzFsnMkdmgKb2y7fgYYkWIuVYiLsTBjrpGskqOxAlo54DhkPwXy)Awq3)uIbev7jOM7ob2C3s8baDxTEiYfXoo(S1zYSPzsA(GC27uoiN9oLckDyNHzRKnAjB67rngShymyZXwJIERTQ9bLY3eug0H(ozecnWv5p8gguwpByqAUfxG1vxxcPExfq37EzcWes5(eVndgpKgEGh6drHqcw9kqbLN(P6QxyPaTckJX1z(4ZDIAd6LclR6tEVCfal5Z63OHN93CRXAd2JI8CpNz1MIxr0JmtTl8rLpzHpkj5PVQe2XL4IAiF8paTD)PK)McKE85u5VTFTD7)deFCASxnc37nf93gv2ghs3ghI(2pj3UvRPrz1SBXDZU9qfSdxUI2w9J5(zPRHZIGYeTgAqDTS(zPBCZkEJl12KIuduogK2k2hE8oQUPEuYnAoowuQ6T7lktQghtBWXOD9Pwfatn1vmgZA)Q3MOu6REBL57bC)UwI3oDsoKtP1KQAPAezmqPeEkxEN(1IZk1ruKmhHqYm3vmOvro(h(uzX8rHJI(z5cgb)BxcpXoFn4RNpf81z((4XDRAzTvxTAOcQLz5TCCJQzbUEPswJKpbqlhxAxM9ANzqph6PAJNCD2Q4DyNTIUyzE82JuRjPtAipbvGsFV(2ifhXB67lYjZS4VsYTFwOXVQKc(1LGXdkPil2bv6bzRsT0w)S4sxde665YHFM2udlM2yBAuS2wnSaFMmH0LtooAS14ERQIs6Ha7SpECxTrrpYXsm(UWsxTLl2rppDNL2qs)(SZ2quUus(k6nL5vgUmNmc61NGcMFvzY9zLOgbkXLphHl9mvU0ZmMlTUjlHpd04Wv)6Ag7E9JWbe11jhNRM40RB8cAF)cFykImCTYPrhpDDtshJjDMXU98MINqGY59WBaFFyBnYeGXFwHO8NjiktloaSWniPUVetLPEu5XBbukp5uEzOAGpiNySQUjzQJRzSANFSEtz)X3gfXL4lTMg7OAhw8KauwDAvpIpo56toftTHVRWaUb6nj94k4SEgYbsxj)sVTMXK3U8Xf62vq5rYpiDTNIuQCGY9IDG8(x0I3a01ItGWu)LXA3bbTbgtDD57QDtbvWPW1Usbxklh86B)QI89tX5fgmh0UOJjjizpsurZWj4xkbiE9CpIEtqj9CTN1NxnxM)adm)ESc0Oumx5j7cu2yu)f1lpx13ROKNSuPaGk1Gbff4QV69jNZhvD(KUuAZQLIKfix9f3RzhRC(quMD7O26Ll(dOSkfar1PsglJEEIsNACTI0gNWTmfjznKf2QVa(Jk5whuWzEPHuTDqVdd859VCC5u4xoopmujVss8XaFQu(iBt4maLSh5KFqUGaIYJ2DQrn6oxnFn1SOBaMtCAo32JOF7Ju5jKO6QQTo9LkRU(jqD6JTkZkXSXN)259cqlF85FBL5DHrPG01vJ8YWakj9lL3c3lzkHgYAFEd9IP(g0ftDQsibyEUOlolatRpZGZ7lskiixMQ3K5oabIq)E(pmn5pahb2yB8TjVnO(wSlx7IuOsl6P4P6q2U28DdW3Bi7sujwipkVZtthW8Uk6ytFwrMi69KZrVinZ5rOAfH8jfqgZkjE2yu9ThA0Vv1Oh6POTnZtN4vLNefqPZv4)ya9kdJ5A3qLmurWHsjDQ3rUJkGIUjYV3kXMR2huEmGaLkuartWYHnH4hEZVUeivqjTNpaFAVA9ACSA6ACKKB2b0OhCak6btHUhUCXCwLSr9MZv2wHHX1Ezwa0k(p0F)E5hMuqqNLI7SKkuZKZMcqazyIeZ8nxSwIA1UORvpeUwAsrMORF7pRKGYNLwh0ZfyvzN0y8wLoCCyrn)0Ro()CKWSIE8x)iVHai6JqVvaZ84UkBdvkWHGsx)zX3GAqimrSX5QknLBs3VUj6H9B6Cq24qzECxd76MKu8aGgR5ET6njETuL1DgV3hMJgSdgPKNw1fEcRUh90oqxIepRcfcR61jzQt7bKusmnCYYV(Nz5B7)8xULBOMmbGs6vUazmFLlGyNP4YRWn8PsaHsAeZQ(XKIEbu6jaRQ6SnXVsapdk1bGrTqE9XByc3w9DiwLaL4pQ8cH2Dy(OeWymx9bjCUo0nSLua7e59rYniphmGs1oPvqF0vSEqFbBF6VLCSLMENUMzdf9Zr3qrxkhOG60hFn2aQY)xP)p2)lA25SCiyJnmQYOwG5sSxzyH5dFu94h36fxAEdBVk(UuuBnsccbfsq8lAD)HUvEpCtTzvcBZRNXzceMaUu0dK2pvM2GIHC2q(lVJDgjqj0n0MEuxRC)8m(xK4EbkgQyWzvUHnP03AJuC8L6X2PabGMY0voQw7JkpV1QDZA7Usfxu1vp7TEC5NFRhNuKsV0DCjZcxIlQvvHXdk5Ge0Y07FjvFuMvQ)6Apr1MYjoo9cvGbEGqnrB3Qwy(36Mzbi)aZvmOFoPYAOICQxFxHJQ2hCtI5VhKEiPMrdvQaN29YIZpjO41wwUVqGYrdJkwOIvlTDb6l26fqPb9072NRjdbvD)rxvNK7vE0SaLA0eHZSWqnuk)sfO1V8RtkkZLVe0CXgUL3xJA8YPcCCs7Ahk07NEMIRsjZRCrQO0f9(ikTWipftDh3Gmq3XnGMLo(Pi54EUV5j(F4EfWe)H7LsjavMO(E0(YzL2Wum5dkDiQ2xMqTeu3KLcNbuQjnmI1q2EtWtH0gfKl5iOCPUM41LkZguArYtC)(5K5bLK6fRW43QLC9VDHKY3zX)TniLseO0FRd(e(JjxRjqPRhjvIE5IlcgJM)gYh083GCfKWv6iEsOp8m14(Jupj4hc5Q9KaToWAvaHrAJ38)s6L38)Q6ajjsljSKNNjqjlO(buC4XzVN(OkAK5QKfFMRIvHw5YV0P1a5jqUPEP)b5O6LO7yZPt1W(G0dxZedS01C5YC4AUCILVsKc4oKqddl6Yg3U1hP8Dtps5Zu4QYOCv0Jd)Plr93XRQhHIu)MJjZHFZXyNbh0hQ1Qu7XgVRY09Uxe)a15sqNwAobdrn)wrraOu4v57vvLinBCH6BE6fMJVvAS4q3dcWusgHUj9D((MwEz(YatX8WKlVSaoN5YA6k3I0QRCl09bmOuCg8xl9)ri0BP82B2kmWIbatfp2)V!BBF"
        local profileData, errorMessage = BBF.OldImportProfile(importString, "auraBlacklist")
        if errorMessage then
            BBF.Print(L["Print_Error_Importing_Blacklist"] .. " " .. tostring(errorMessage))
            return
        end
        BBF.DeepMergeTables(BetterBlizzFramesDB.auraBlacklist, profileData)
        if BBF.auraBlacklistRefresh then
            BBF.auraBlacklistRefresh()
        end
        BBF.RefreshAllAuraFrames()
        Settings.OpenToCategory(BBF.category:GetID(), BBF.aurasSubCategory)
    end,
    timeout = 0,
    whileDead = true,
}

local AURA_RESET_EXTRA_KEYS = {
    "auraSortMethod",
    "playerAuraSortMethod",
    "auraImportantGlowColor",
    "auraWhitelistImportantGlowColor",
    "auraEnlargedGlowColor",
    "auraDefensiveGlowColor",
    "auraCCGlowColor",
    "auraPandemicGlowColor",
    "purgeTextureColorRGB",
    "auraTimerBaseColor",
    "auraToggleIconTexture",
    "toggleIconPosition",
    "hiddenIconDirection",
    "playerBuffsCollapsed",
}

local AURA_RESET_PRESERVED_KEYS = {
    playerAuraFiltering = true,
}

function BBF.ResetAuraSettings()
    local category = BBF.aurasSubCategory
    local db = BetterBlizzFramesDB

    for _, data in ipairs(checkBoxList) do
        local dbKey = data.checkbox.dbKey
        if data.checkbox.searchCategory == category and dbKey and not AURA_RESET_PRESERVED_KEYS[dbKey] then
            db[dbKey] = nil
        end
    end

    for _, data in ipairs(sliderList) do
        if data.slider.searchCategory == category and data.element and not AURA_RESET_PRESERVED_KEYS[data.element] then
            db[data.element] = nil
        end
    end

    for _, key in ipairs(AURA_RESET_EXTRA_KEYS) do
        if not AURA_RESET_PRESERVED_KEYS[key] then
            db[key] = nil
        end
    end

    db.reopenOptions = true
    ReloadUI()
end

StaticPopupDialogs["BBF_CONFIRM_RESET_AURA_SETTINGS"] = {
    text = titleText..L["Popup_Confirm_Reset_Aura_Settings"],
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function()
        BBF.ResetAuraSettings()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

------------------------------------------------------------
-- GUI Creation Functions
------------------------------------------------------------
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

local function FormatClassName(classTag)
    local classMap = {
        DEATHKNIGHT = L["Class_Death_Knight"],
        DEMONHUNTER = L["Class_Demon_Hunter"],
        DRUID = L["Class_Druid"],
        EVOKER = L["Class_Evoker"],
        HUNTER = L["Class_Hunter"],
        MAGE = L["Class_Mage"],
        MONK = L["Class_Monk"],
        PALADIN = L["Class_Paladin"],
        PRIEST = L["Class_Priest"],
        ROGUE = L["Class_Rogue"],
        SHAMAN = L["Class_Shaman"],
        WARLOCK = L["Class_Warlock"],
        WARRIOR = L["Class_Warrior"],
    }

    return classMap[classTag] or (classTag:sub(1, 1):upper() .. classTag:sub(2):lower())
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
    text:SetText(L["Enter_New_Icon_ID"])

    -- Icon texture frame
    local textureFrame = window:CreateTexture(nil, "ARTWORK")
    textureFrame:SetSize(50, 50)  -- Enlarged icon
    textureFrame:SetPoint("RIGHT", editBox, "LEFT", -10, 0)
    textureFrame:SetTexture(BetterBlizzFramesDB.auraToggleIconTexture)

    -- Text for finding icon IDs
    local findIconText = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    findIconText:SetPoint("CENTER", window, "CENTER", 0, -40)
    findIconText:SetText(L["Find_Icon_IDs"])

    -- OK button
    local okButton = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
    okButton:SetSize(60, 20)
    okButton:SetPoint("BOTTOM", window, "BOTTOM", 30, 10)
    okButton:SetText(L["Yes"])
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
    resetButton:SetText(L["Default"])
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
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetOrientation('HORIZONTAL')
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(stepValue)
    slider:SetObeyStepOnDrag(true)

    slider.Text:SetFontObject(GameFontHighlightSmall)
    slider.Text:SetTextColor(1, 0.81, 0, 1)
    slider.Text:SetFont(fontSmall, 11)

    slider.Low:SetText(" ")
    slider.High:SetText(" ")

    local category
    if parent.name then
        category = parent.name
    elseif parent:GetParent() and parent:GetParent().name then
        category = parent:GetParent().name
    elseif parent:GetParent() and parent:GetParent():GetParent() and parent:GetParent():GetParent().name then
        category = parent:GetParent():GetParent().name
    end

    if category == "Better|cff00c0ffBlizz|rFrames |A:gmchat-icon-blizz:16:16|a" then
        category = L["Search_Name_General"]
    end

    slider.searchCategory = category

    table.insert(sliderList, {
        slider = slider,
        label = label,
        element = element
    })

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
            local initialValue = tonumber(BetterBlizzFramesDB[element]) or 1 -- Convert to number

            if initialValue then
                local currentMin, currentMax = slider:GetMinMaxValues() -- Fetch the latest min and max values

                -- Check if the initial value is outside the current range and update range if necessary
                UpdateSliderRange(initialValue, currentMin, currentMax)

                slider:SetValue(initialValue) -- Set the initial value
                local textValue = initialValue % 1 == 0 and tostring(math.floor(initialValue)) or string.format("%.2f", initialValue)
                slider.Text:SetText(label ~= "" and (label .. ": " .. textValue) or textValue)
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
            if slider.integerOnly then
                inputValue = math.max(1, math.floor(inputValue))
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
            self.Text:SetText(label ~= "" and (label .. ": " .. textValue) or textValue)
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
                    if not string.match(element, "Scale$") then
                        BetterBlizzFramesDB[element .. "Scale"] = value
                    else
                        BetterBlizzFramesDB[element] = value
                    end
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
                elseif element == "partyFrameRangeAlpha" then
                    BetterBlizzFramesDB.partyFrameRangeAlpha = value
                    BBF.HookAndUpdatePartyFrameRangeAlpha(true)
                elseif element == "darkModeColor" then
                    BetterBlizzFramesDB.darkModeColor = value
                    if not BBF.checkCombatAndWarn() then
                        BBF.DarkmodeFrames()
                    end
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
                elseif element == "selfAuraPurgeGlowAlpha" then
                    BetterBlizzFramesDB.selfAuraPurgeGlowAlpha = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "auraWidthSpace" or element == "auraWidthSpaceFocus" then
                    BetterBlizzFramesDB[element] = value
                    BBF.RefreshAllAuraFrames()
                    BBF.PreviewAuraRowWidth()
                    --
                elseif element == "combatIndicatorScale" then
                    BetterBlizzFramesDB.combatIndicatorScale = value
                    BBF.CombatIndicatorCaller()
                elseif element == "combatIndicatorXPos" then
                    BetterBlizzFramesDB.combatIndicatorXPos = value
                    BBF.CombatIndicatorCaller()
                elseif element == "combatIndicatorYPos" then
                    BetterBlizzFramesDB.combatIndicatorYPos = value
                    BBF.CombatIndicatorCaller()
                elseif element == "healerIndicatorScale" then
                    BetterBlizzFramesDB.healerIndicatorScale = value
                    BBF.HealerIndicatorCaller()
                elseif element == "healerIndicatorXPos" then
                    BetterBlizzFramesDB.healerIndicatorXPos = value
                    BBF.HealerIndicatorCaller()
                elseif element == "healerIndicatorYPos" then
                    BetterBlizzFramesDB.healerIndicatorYPos = value
                    BBF.HealerIndicatorCaller()
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
                    BBF.CastbarAdjustCaller("target")
                elseif element == "targetCastBarYPos" then
                    BetterBlizzFramesDB.targetCastBarYPos = value
                    BBF.CastbarAdjustCaller("target")
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
                    BBF.CastbarAdjustCaller("focus")
                elseif element == "focusCastBarYPos" then
                    BetterBlizzFramesDB.focusCastBarYPos = value
                    BBF.CastbarAdjustCaller("focus")
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
                elseif element == "playerCastbarIconXPos" then
                    BetterBlizzFramesDB.playerCastbarIconXPos = value
                    BBF.ChangeCastbarSizes()
                elseif element == "playerCastbarIconYPos" then
                    BetterBlizzFramesDB.playerCastbarIconYPos = value
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
                elseif element == "playerAuraSpacingY" then
                    BetterBlizzFramesDB.playerAuraSpacingY = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "auraTypeGap" then
                    BetterBlizzFramesDB.auraTypeGap = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "auraStackSize" then
                    BetterBlizzFramesDB.auraStackSize = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "auraCdTextSize" then
                    BetterBlizzFramesDB.auraCdTextSize = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "auraHighlightScale" then
                    BetterBlizzFramesDB.auraHighlightScale = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "auraTimerLowThreshold" then
                    BetterBlizzFramesDB.auraTimerLowThreshold = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "targetAndFocusSmallAuraScale" then
                    BetterBlizzFramesDB.targetAndFocusSmallAuraScale = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "enlargedAuraSize" then
                    BetterBlizzFramesDB.enlargedAuraSize = value
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
                    BBF.CastbarAdjustCaller("target")
                elseif element == "focusToTAdjustmentOffsetY" then
                    BetterBlizzFramesDB.focusToTAdjustmentOffsetY = value
                    BBF.CastbarAdjustCaller("focus")
                elseif element == "castBarInterruptIconScale" then
                    BetterBlizzFramesDB.castBarInterruptIconScale = value
                    BBF.UpdateInterruptIconSettings()
                elseif element == "castBarInterruptIconXPos" then
                    BetterBlizzFramesDB.castBarInterruptIconXPos = value
                    BBF.UpdateInterruptIconSettings()
                elseif element == "castBarInterruptIconYPos" then
                    BetterBlizzFramesDB.castBarInterruptIconYPos = value
                    BBF.UpdateInterruptIconSettings()
                elseif element == "kickPopupScale" then
                    BetterBlizzFramesDB.kickPopupScale = value
                    BBF.UpdateKickPopupSettings()
                elseif element == "kickPopupIconScale" then
                    BetterBlizzFramesDB.kickPopupIconScale = value
                    BBF.UpdateKickPopupSettings()
                elseif element == "kickPopupXPos" then
                    BetterBlizzFramesDB.kickPopupXPos = value
                    BBF.UpdateKickPopupSettings()
                elseif element == "kickPopupYPos" then
                    BetterBlizzFramesDB.kickPopupYPos = value
                    BBF.UpdateKickPopupSettings()
                elseif element == "uiWidgetPowerBarScale" then
                    BetterBlizzFramesDB.uiWidgetPowerBarScale = value
                    BBF.ResizeUIWidgetPowerBarFrame()
                elseif element == "actionBarCDNumberScale" then
                    BetterBlizzFramesDB.actionBarCDNumberScale = value
                    BBF.ActionBarCDNumberSize()
                elseif element == playerClassResourceScale then
                    BetterBlizzFramesDB[playerClassResourceScale] = value
                    BBF.UpdateClassComboPoints()
                    --end
                elseif element == "legacyComboScale" or element == "legacyComboXPos" or element == "legacyComboYPos" then
                    BetterBlizzFramesDB[element] = value
                    if BBF.UpdateLegacyComboPosition then
                        BBF.UpdateLegacyComboPosition()
                    end
                elseif element == "castBarTargetTextOutsideXPos" or element == "castBarTargetTextOutsideYPos"
                    or element == "castBarTargetTextOutsideSize" then
                    BetterBlizzFramesDB[element] = value
                    BBF.CastbarTargetTextCaller()
                end
            end
        end)

    return slider
end

local function CreateTooltip(widget, tooltipText, anchor)
    widget.tooltipTitle = tooltipText
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

local function CreateTooltipTwo(widget, title, mainText, subText, anchor, cvarName, cpuUsage, category)
    widget.tooltipTitle = title
    widget.tooltipMainText = mainText
    widget.tooltipSubText = subText
    widget.tooltipCVarName = cvarName
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

        if title == L["Format_Numbers"] then
            local tooltipText = "\n\n18800 K |A:glueannouncementpopup-arrow:20:20|a 18.8 M\n|cff32f795" .. L["Right_Click_Show_Extra_Decimal"] .. "|r"
            if BetterBlizzFramesDB.formatStatusBarTextExtraDecimals then
                tooltipText = "\n\n18800 K |A:glueannouncementpopup-arrow:20:20|a 18.80 M\n|cff32f795" .. L["Right_Click_Show_Extra_Decimal"] .. "|r|A:ParagonReputation_Checkmark:15:15|a"
            end
            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        end

        if title == L["Tooltip_Class_Color_Healthbars_Title"] then
            local green = "|cff32f795"
            local babyBlue = "|cff7fc6ff"
            local reset = "|r"
            local check = " |A:ParagonReputation_Checkmark:15:15|a"

            local tooltipText = "\n"
            tooltipText = tooltipText .. green .. L["Tooltip_Class_Color_Keep_Player"] .. reset
            if BetterBlizzFramesDB.classColorFramesSkipPlayer then
                tooltipText = tooltipText .. check
            end

            tooltipText = tooltipText .. "\n\n" .. babyBlue .. L["Tooltip_Class_Color_Keep_Friendly"] .. reset
            if BetterBlizzFramesDB.classColorFramesSkipFriendly then
                tooltipText = tooltipText .. check
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        end

        if title == L["Custom_Colors"] then
            local yellow = "|cffffff00"
            local green = "|cff32f795"
            local babyBlue = "|cff7fc6ff"
            local reset = "|r"
            local check = " |A:ParagonReputation_Checkmark:15:15|a"

            local tooltipText = "\n" .. yellow .. L["Right_Click_To_Open_Options"] .. reset
            tooltipText = tooltipText .. "\n\n" .. green .. L["Tooltip_Class_Color_Keep_Player"] .. reset
            if BetterBlizzFramesDB.classColorFramesSkipPlayer then
                tooltipText = tooltipText .. check
            end

            tooltipText = tooltipText .. "\n\n" .. babyBlue .. L["Tooltip_Class_Color_Keep_Friendly"] .. reset
            if BetterBlizzFramesDB.classColorFramesSkipFriendly then
                tooltipText = tooltipText .. check
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        end

        if title == L["Hide_Dispel_Overlay"] then
            local green = "|cff32f795"
            local babyBlue = "|cff7fc6ff"
            local reset = "|r"
            local check = " |A:ParagonReputation_Checkmark:15:15|a"

            local tooltipText = "\n"
            tooltipText = tooltipText .. green .. L["Right_Click_Keep_Dispel_Border"] .. " |A:RaidFrame-DispelHighlight:15:30|a" .. reset
            if BetterBlizzFramesDB.hidePartyDispelOverlayKeepBorder then
                tooltipText = tooltipText .. check
            end

            tooltipText = tooltipText .. "\n\n" .. babyBlue .. L["Shift_Right_Click_Keep_Dispel_Gradient"] .. " |A:_RaidFrame-Dispel-Highlight-Horizontal:15:30|a" .. reset
            if BetterBlizzFramesDB.hidePartyDispelOverlayKeepGradient then
                tooltipText = tooltipText .. check
            end

            local orange = "|cffffaa00"
            tooltipText = tooltipText .. "\n\n" .. orange .. L["Ctrl_Right_Click_Hide_Dispel_Icons"] .. " |A:RaidFrame-Icon-DebuffCurse:15:15|a" .. reset
            if BetterBlizzFramesDB.hidePartyDispelOverlayHideIcons then
                tooltipText = tooltipText .. check
            end

            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        end

        if title == L["Show_Elite_Texture"] then
            local tooltipText = L["Tooltip_Elite_Texture_Dark_Mode"]
            if BetterBlizzFramesDB.playerEliteFrameDarkmode then
                tooltipText = L["Tooltip_Elite_Texture_Dark_Mode_Check"] .. "|A:ParagonReputation_Checkmark:15:15|a"
            end
            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        end

        if title == L["Tooltip_Pixel_Border_RaidFrames_Title"] then
            local green = "|cff32f795"
            local reset = "|r"
            local activeSize = BetterBlizzFramesDB.raidFramePixelBorderSize and "1.5px" or "1px"
            local tooltipText = "\n" .. green .. "Right-click to toggle between 1px and 1.5px. Active: " .. activeSize .. reset
            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        end

        if title == L["Change_Party_Frame_Alpha"] then
            local green = "|cff32f795"
            local reset = "|r"
            local check = ""
            if BetterBlizzFramesDB.partyFrameRangeAlphaSolidBackground then
                check = " |A:ParagonReputation_Checkmark:15:15|a"
            end
            local tooltipText = "\n" .. green .. L["Tooltip_Party_Frame_Range_Alpha_Solid_Bg"] .. reset .. check
            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        end

        if title == L["Tooltip_Dark_Mode_Auras"] then
            local green = "|cff32f795"
            local reset = "|r"
            local check = ""
            if BetterBlizzFramesDB.removeDebuffColorBorder then
                check = " |A:ParagonReputation_Checkmark:15:15|a"
            end
            local tooltipText = "\n" .. green .. L["Tooltip_Remove_Debuff_Color_Border_Toggle"] .. reset .. check
            GameTooltip:AddLine(tooltipText, 1, 1, 1, true)
        end

        -- Set the subtext
        if subText then
            GameTooltip:AddLine("____________________________", 0.8, 0.8, 0.8, true)
            GameTooltip:AddLine(subText, 0.8, 0.80, 0.80, true)
        end
        -- Add CVar information if provided
        if cvarName then
            --GameTooltip:AddLine(" ")
            --GameTooltip:AddLine("Default Value: " .. cvarName, 0.5, 0.5, 0.5) -- grey color for subtext
            GameTooltip:AddDoubleLine(L["Tooltip_Changes_CVar"], cvarName, 0.2, 1, 0.6, 0.2, 1, 0.6)
        end
        if cpuUsage then
            local star = "|A:UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare-Star:16:16|a"
            local noStar = "|A:UI-HUD-UnitFrame-Target-PortraitOn-Boss-IconRing:16:16|a"

            -- Create star string based on cpuUsage (0-5)
            local starString = ""
            for i = 1, 5 do
                if i <= cpuUsage then
                    starString = starString .. star
                else
                    starString = starString .. noStar
                end
            end
            GameTooltip:AddDoubleLine(" ", " ")
            GameTooltip:AddDoubleLine(L["CPU_Usage"], starString, 0.2, 1, 0.6, 0.2, 1, 0.6)
        end

        if category then
            GameTooltip:AddLine("")
            GameTooltip:AddLine("|A:shop-games-magnifyingglass:17:17|a " .. L["Tooltip_Setting_Located_In"]..category..L["Tooltip_Section"], 0.4, 0.8, 1, true)
        end
        GameTooltip:Show()
    end)
    widget:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

local CLASS_COLORS = {
    ROGUE = "|cfffff569",
    WARRIOR = "|cffc79c6e",
    MAGE = "|cff40c7eb",
    DRUID = "|cffff7d0a",
    HUNTER = "|cffabd473",
    PRIEST = "|cffffffff",
    WARLOCK = "|cff8787ed",
    SHAMAN = "|cff0070de",
    PALADIN = "|cfff58cba",
    DEATHKNIGHT = "|cffc41f3b",
    MONK = "|cff00ff96",
    DEMONHUNTER = "|cffa330c9",
    EVOKER = "|cff33937f",
    STARTER = "|cff32cd32",
    BLITZ = "|cffff8000",
    MYTHIC = "|cff7dd1c2",
}

local CLASS_ICONS = {
    ROGUE = "groupfinder-icon-class-rogue",
    WARRIOR = "groupfinder-icon-class-warrior",
    MAGE = "groupfinder-icon-class-mage",
    DRUID = "groupfinder-icon-class-druid",
    HUNTER = "groupfinder-icon-class-hunter",
    PRIEST = "groupfinder-icon-class-priest",
    WARLOCK = "groupfinder-icon-class-warlock",
    SHAMAN = "groupfinder-icon-class-shaman",
    PALADIN = "groupfinder-icon-class-paladin",
    DEATHKNIGHT = "groupfinder-icon-class-deathknight",
    MONK = "groupfinder-icon-class-monk",
    DEMONHUNTER = "groupfinder-icon-class-demonhunter",
    EVOKER = "groupfinder-icon-class-evoker",
    STARTER = "newplayerchat-chaticon-newcomer",
    BLITZ = "questlog-questtypeicon-pvp",
    MYTHIC = "worldquest-icon-dungeon",
}

local function ShowProfileConfirmation(profileName, class, profileFunction, additionalNote)
    local noteText = additionalNote or ""
    local color = CLASS_COLORS[class] or "|cffffffff"
    local icon = CLASS_ICONS[class] or "groupfinder-icon-role-leader"
    local profileText = string.format("|A:%s:16:16|a %s%s|r", icon, color, profileName..L["Profile_Label"])
    local confirmationText = titleText .. string.format(L["Profile_Confirmation_Text"], profileText, noteText)

    StaticPopupDialogs["BBF_CONFIRM_PROFILE"].text = confirmationText
    StaticPopup_Show("BBF_CONFIRM_PROFILE", nil, nil, { func = profileFunction })
end

local function CreateClassButton(parent, class, name, twitchName, onClickFunc)
    local bbfParent = parent == BetterBlizzFrames
    local coreProfile = class == "STARTER" or name == "Bodify"
    local btnWidth, btnHeight = bbfParent and 104 or (coreProfile and 150 or 114), bbfParent and 22 or 30
    local button = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    button:SetSize(btnWidth, btnHeight)

    local dontIncludeProfileText = (bbfParent or not coreProfile) and "" or L["Profile_Label"]
    local color = CLASS_COLORS[class] or "|cffffffff"
    local icon = CLASS_ICONS[class] or "groupfinder-icon-role-leader"

    if name == "Bodify" then
        icon = "gmchat-icon-blizz"
    end

    button:SetText(string.format("|A:%s:16:16|a %s%s|r", icon, color, (name..dontIncludeProfileText)))
    button:SetNormalFontObject("GameFontNormal")
    button:SetHighlightFontObject("GameFontHighlight")
    local a,b,c = button.Text:GetFont()
    button.Text:SetFont(a,b,"OUTLINE")
    local a,b,c,d,e = button.Text:GetPoint()
    if not bbfParent then
        button.Text:SetPoint("LEFT",b,"LEFT",10,e-0.6)
    end
    local ttAnchor = "ANCHOR_TOP"

    button:SetScript("OnClick", function()
        if onClickFunc then
            onClickFunc()
        end
    end)

    if class == "STARTER" then
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name..L["Profile_Label"]), L["Profile_Starter_Desc"], nil, ttAnchor)
    elseif class == "BLITZ" then
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name..L["Profile_Label"]), L["Profile_Blitz_Desc"], nil, ttAnchor)
    elseif class == "MYTHIC" then
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name..L["Profile_Label"]), L["Profile_Mythic_Desc"], nil, ttAnchor)
    elseif name == "Bodify" then
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name..L["Profile_Label"]), L["Profile_Bodify_Desc"], nil, ttAnchor)
    else
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name..L["Profile_Label"]), string.format(L["Profile_Streamer_Desc"], name), string.format("www.twitch.tv/%s", twitchName), ttAnchor)
    end

    return button
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
    CreateTooltipTwo(exportBox, L["Tooltip_Ctrl_C_Copy"])

    -- Import EditBox
    local importBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    importBox:SetSize(100, 20)
    importBox:SetPoint("TOP", exportBox, "BOTTOM", 0, -5)
    importBox:SetAutoFocus(false)

    -- Export Button
    local exportBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    exportBtn:SetPoint("RIGHT", exportBox, "LEFT", -10, 0)
    exportBtn:SetSize(73, 20)
    exportBtn:SetText(L["Export"])
    exportBtn:SetNormalFontObject("GameFontNormal")
    exportBtn:SetHighlightFontObject("GameFontHighlight")
    CreateTooltipTwo(exportBtn, L["Tooltip_Export_Data"], L["Tooltip_Export_Data_Desc"])

    -- Import Button
    local importBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    importBtn:SetPoint("RIGHT", importBox, "LEFT", -10, 0)
    importBtn:SetSize(title ~= "Full Profile" and 52 or 73, 20)
    importBtn:SetText(L["Import"])
    importBtn:SetNormalFontObject("GameFontNormal")
    importBtn:SetHighlightFontObject("GameFontHighlight")
    CreateTooltipTwo(importBtn, L["Tooltip_Import_Data"], L["Tooltip_Import_Data_Desc"])

    -- Keep Old Checkbox
    local keepOldCheckbox
    if title ~= "Full Profile" then
        keepOldCheckbox = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
        keepOldCheckbox:SetPoint("RIGHT", importBtn, "LEFT", 3, -1)
        keepOldCheckbox:SetChecked(true)
        CreateTooltipTwo(keepOldCheckbox, L["Tooltip_Keep_Old_Data"], L["Tooltip_Keep_Old_Data_Desc"])
    end

    -- Button scripts
    exportBtn:SetScript("OnClick", function()
        local exportString = BBF.ExportProfile(dataTable, tableName)
        exportBox:SetText(exportString)
        exportBox:SetFocus()
        exportBox:HighlightText()
    end)

    local wipeButton = exportBox:CreateTexture(nil, "OVERLAY")
    wipeButton:SetSize(14,14)
    wipeButton:SetPoint("CENTER", exportBox, "TOPRIGHT", 8,6)
    wipeButton:SetAtlas("transmog-icon-remove")
    wipeButton:Hide()

    wipeButton:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" and IsShiftKeyDown() and IsAltKeyDown() then
            if title == "Full Profile" then
                BetterBlizzFramesDB = nil
            else
                BetterBlizzFramesDB[tableName] = nil
            end
            ReloadUI()
        end
    end)

    local function HideWipeButton()
        if not wipeButton:IsMouseOver() then
            wipeButton:Hide()
        end
    end

    frame:HookScript("OnEnter", function()
        wipeButton:Show()
        C_Timer.After(4, HideWipeButton)
    end)
    CreateTooltipTwo(wipeButton, L["Tooltip_Delete_Data_Title"]..title, L["Tooltip_Delete_Data_Desc"].." "..title)

    wipeButton:HookScript("OnEnter", function()
        wipeButton:Show()
    end)

    wipeButton:HookScript("OnLeave", function()
        C_Timer.After(0.5, HideWipeButton)
    end)


    importBtn:SetScript("OnClick", function()
        local importString = importBox:GetText()
        local profileData, errorMessage = BBF.OldImportProfile(importString, tableName)
        if errorMessage then
            BBF.Print(L["Print_Error_Importing"] .. title .. ": " .. tostring(errorMessage))
        else
            if not profileData then
                BBF.Print(L["Print_Error_Importing_Generic"])
                return
            end
            if keepOldCheckbox and keepOldCheckbox:GetChecked() then
                -- Perform a deep merge if "Keep Old" is checked
                BBF.DeepMergeTables(dataTable, profileData)
            else
                -- Replace existing data with imported data
                for k in pairs(dataTable) do dataTable[k] = nil end -- Clear current table
                for k, v in pairs(profileData) do
                    dataTable[k] = v -- Populate with new data
                end
            end
            BBF.Print(string.format(L["Print_Imported_Successfully"], title))
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
                return L["Anchor_INNER"]
            elseif settingValue == "RIGHT" then
                return L["Anchor_OUTER"]
            end
        end
        if settingValue == "TOP" then
            return L["Anchor_TOP"]
        elseif settingValue == "BOTTOM" then
            return L["Anchor_BOTTOM"]
        elseif settingValue == "CENTER" then
            return L["Anchor_CENTER"]
        elseif settingValue == "LEFT" then
            return L["Anchor_LEFT"]
        elseif settingValue == "RIGHT" then
            return L["Anchor_RIGHT"]
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
            if anchor == "TOP" then
                displayText = L["Anchor_TOP"]
            elseif anchor == "BOTTOM" then
                displayText = L["Anchor_BOTTOM"]
            elseif anchor == "CENTER" then
                displayText = L["Anchor_CENTER"]
            elseif anchor == "LEFT" then
                if name == "combatIndicatorDropdown" or name == "playerAbsorbAnchorDropdown" then
                    displayText = L["Anchor_INNER"]
                else
                    displayText = L["Anchor_LEFT"]
                end
            elseif anchor == "RIGHT" then
                if name == "combatIndicatorDropdown" or name == "playerAbsorbAnchorDropdown" then
                    displayText = L["Anchor_OUTER"]
                else
                    displayText = L["Anchor_RIGHT"]
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
    checkBox:SetSize(23,23)
    checkBox.Text:SetFont(fontSmall, 12)

    local category
    if parent.name then
        category = parent.name
    elseif parent:GetParent() and parent:GetParent().name then
        category = parent:GetParent().name
    elseif parent:GetParent() and parent:GetParent():GetParent() and parent:GetParent():GetParent().name then
        category = parent:GetParent():GetParent().name
    end

    if category == "Better|cff00c0ffBlizz|rFrames |A:gmchat-icon-blizz:16:16|a" then
        category = L["Search_Name_General"]
    end

    checkBox.searchCategory = category
    checkBox.dbKey = option

    table.insert(checkBoxList, {checkbox = checkBox, label = label})

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

        if extraFunc and not BetterBlizzFramesDB.wasOnLoadingScreen and BetterBlizzFrames.guiLoaded then
            extraFunc(option, value)
        end

        if not BetterBlizzFramesDB.wasOnLoadingScreen then
            BBF.UpdateUserTargetSettings()
        end

        if not BetterBlizzFramesDB.wasOnLoadingScreen and BetterBlizzFramesDB.playerAuraFiltering then
            BBF.RefreshAllAuraFrames()
        end
        --BBF.Print("Checkbox option '" .. option .. "' changed to:", value)
    end

    UpdateOption(BetterBlizzFramesDB[option])

    checkBox:HookScript("OnClick", function(_, _, _)
        UpdateOption(checkBox:GetChecked())
    end)

    return checkBox
end




function BBF.GetListSearchFilter(listName)
    return BBF[listName .. "SearchFilter"] or ""
end

function BBF.SetListSearchFilter(listName, text)
    BBF[listName .. "SearchFilter"] = text or ""
end

local function deleteEntry(listName, key)
    if not key then return end

    local entry = BetterBlizzFramesDB[listName][key]

    if not entry then
        if key == "example aura :3 (delete me)" then
            entry = BetterBlizzFramesDB[listName]["example"]
            key = "example"
        end
    end

    if entry then
        if entry.id then
            local spellName, _, icon = BBF.TWWGetSpellInfo(entry.id)
            if spellName and icon then
                local iconString = "|T" .. icon .. ":16:16:0:0|t"
                BBF.Print(string.format(L["Print_Removed_From_List"], iconString .. " " .. spellName .. " (" .. entry.id .. ")"))
            elseif entry.name then
                BBF.Print(string.format(L["Print_Removed_From_List"], entry.name .. " (" .. entry.id .. ")"))
            else
                BBF.Print(string.format(L["Print_Removed_ID_Not_Found"], entry.id))
            end
        else
            BBF.Print(string.format(L["Print_Removed_From_List"], entry.name))
        end

        BetterBlizzFramesDB[listName][key] = nil
    end

    BBF.SetListSearchFilter(listName, "")

    if SettingsPanel:IsShown() then
        if BBF[listName.."Refresh"] then
            BBF[listName.."Refresh"]()
        end
    else
        BBF[listName.."DelayedUpdate"] = BBF[listName.."Refresh"]
    end

    BBF.RefreshAllAuraFrames()
end

local lists = { "auraBlacklist", "auraWhitelist" }

for _, listName in ipairs(lists) do
    -- Create static popup dialogs for duplicate confirmations
    StaticPopupDialogs["BBF_DUPLICATE_NPC_CONFIRM_" .. listName] = {
        text = L["Dialog_Duplicate_Entry"],
        button1 = L["Yes"],
        button2 = L["No"],
        OnAccept = function()
            local key = BBF[listName .. "EntryToDelete"]
            BBF[listName .. "EntryToDelete"] = nil
            deleteEntry(listName, key)
        end,
        timeout = 0,
        whileDead = true,
    }

    -- Create static popup dialogs for delete confirmations
    StaticPopupDialogs["BBF_DELETE_NPC_CONFIRM_" .. listName] = {
        text = L["Dialog_Confirm_Delete"],
        button1 = L["Yes"],
        button2 = L["No"],
        OnAccept = function()
            local key = BBF[listName .. "EntryToDelete"]
            BBF[listName .. "EntryToDelete"] = nil
            deleteEntry(listName, key)
        end,
        timeout = 0,
        whileDead = true,
    }
end

StaticPopupDialogs["BBF_DUPLICATE_UPDATE_OR_DELETE"] = {
    text = L["Dialog_Duplicate_Blacklist"],
    button1 = L["Update_And_Always_Hide"],
    button2 = L["Delete_From_Blacklist"],
    OnAccept = function()
        BBF["auraBlacklist"](BBF.auraBlacklistEntryToDelete, "auraBlacklist", nil, true)
    end,
    OnCancel = function()
        deleteEntry("auraBlacklist", BBF.auraBlacklistEntryToDelete)
    end,
    timeout = 0,
    whileDead = true,
}


local function addOrUpdateEntry(inputText, listName, addShowMineTag, skipRefresh, color)
    local name, comment = strsplit("/", inputText, 2)
    name = strtrim(name or "")
    comment = comment and strtrim(comment) or nil
    local id = tonumber(name)
    local printMsg
    local spellName
    local icon
    local iconString
    local _

    if not id then
        if name ~= "" then
            BBF.Print(L["Print_Spell_ID_Only_Midnight"])
        end
        local editBox = listName and BBF[listName.."EditBox"]
        if editBox then
            editBox:SetText("")
        end
        return
    end

    -- Check if there's a numeric ID within the name and clear the name if found
    if id then
        spellName, _, icon = BBF.TWWGetSpellInfo(id)
        name = spellName or ""

        if not spellName then
            BBF.Print(string.format(L["Print_No_Spell_Found"], id))
            return
        end

        if icon then
            iconString = "|T" .. icon .. ":16:16:0:0|t"
        else
            iconString = ""
        end

        -- Check if the spell is being added to blacklist or whitelist
        if listName == "auraBlacklist" then
            printMsg = iconString .. " " .. spellName .. " (" .. id .. ")" .. L["Print_Added_To_Blacklist_With_Icon"]
        elseif listName == "auraWhitelist" then
            printMsg = iconString .. " " .. spellName .. " (" .. id .. ")" .. L["Print_Added_To_Whitelist_With_Icon"]
        end
    end

    if (name ~= "" or id) then
        local key = id or string.lower(name)  -- Use id if available, otherwise use name
        local isDuplicate = false

        -- Directly check if the key already exists in the list
        if BetterBlizzFramesDB[listName][key] then
            if listName == "auraBlacklist" then
                local hasShowMineTag = BetterBlizzFramesDB[listName][key].showMine
                if addShowMineTag and not hasShowMineTag then
                    -- do nothing, adds tag
                elseif not addShowMineTag and hasShowMineTag then
                    -- do nothing, removes tag
                else
                    isDuplicate = true
                    BBF[listName .. "EntryToDelete"] = key
                    if addShowMineTag then
                        BBF.DuplicateWithTag = true
                    end
                end
            elseif listName == "auraWhitelist" then
                isDuplicate = true
                BBF[listName .. "EntryToDelete"] = key
            end
        end

        if isDuplicate then
            if BBF.DuplicateWithTag then
                StaticPopup_Show("BBF_DUPLICATE_UPDATE_OR_DELETE")
                BBF.DuplicateWithTag = nil
            else
                StaticPopup_Show("BBF_DUPLICATE_NPC_CONFIRM_" .. listName)
            end
        else
            -- Initialize the new entry with appropriate structure
            local newEntry = {
                name = name,
                id = id,
                comment = comment or nil,
            }

            if listName == "auraWhitelist" then
                newEntry = {name = name, id = id, comment = comment or nil, color = {0,1,0,1}}
            end

            -- if color then
            --     --newEntry.color = {1,0.501960813999176,0,1} -- offensive
            --     --newEntry.color = {1,0.6627451181411743,0.9450981020927429,1} -- defensive
            --     newEntry.color = {0,1,1,1} -- mobility
            --     --newEntry.color = {0,1,0,1} --muy importante
            --     newEntry.important = true
            --     newEntry.enlarged = true
            -- end

            -- If adding to auraBlacklist and addShowMineTag is true, set showMine to true
            if addShowMineTag and listName == "auraBlacklist" then
                newEntry.showMine = true
                if id then
                    printMsg = iconString .. " " .. spellName .. " (" .. id .. ")" .. L["Print_Added_To_Blacklist_With_Tag"]
                end
            end

            -- Add the new entry to the list using key
            BetterBlizzFramesDB[listName][key] = newEntry

            BBF.SetListSearchFilter(listName, "")

            if not skipRefresh then
                if BBF[listName.."Refresh"] then
                    BBF[listName.."Refresh"]()
                end
            else
                if SettingsPanel:IsShown() then
                    if BBF[listName.."Refresh"] then
                        BBF[listName.."Refresh"]()
                    end
                else
                    BBF[listName.."DelayedUpdate"] = BBF[listName.."Refresh"]
                end
            end

            if printMsg then
                BBF.Print(printMsg)
            end

        end
    end

    BBF.RefreshAllAuraFrames()
    if BBF[listName.."EditBox"] then
        BBF[listName.."EditBox"]:SetText("")  -- Clear the EditBox
    end
end
BBF["auraBlacklist"] = addOrUpdateEntry
BBF["auraWhitelist"] = addOrUpdateEntry







function BBF.TintGlowSwatch(texture, colorKey, r, g, b)
    if not texture then return end
    local c = BetterBlizzFramesDB[colorKey]
    if type(c) == "table" and c[1] then
        texture:SetVertexColor(c[1], c[2] or 0, c[3] or 0)
    else
        texture:SetVertexColor(r, g, b)
    end
end

function BBF.UpdateEnlargedGlowSwatch(button)
    local swatch = button.checkBoxEnlarged and button.checkBoxEnlarged.swatch
    if not swatch then return end

    local data = button.npcData
    local show = (data and data.enlarged and data.important) and true or false
    swatch:SetShown(show)
    if show then
        BBF.TintGlowSwatch(swatch, "auraEnlargedGlowColor", 1, 0.5, 0)
    end
end

function BBF.RefreshAuraGlowSwatches()
    for _, button in ipairs(BBF.auraWhitelistTextLines or {}) do
        if button.checkBoxImportant then
            BBF.TintGlowSwatch(button.checkBoxImportant.swatch, "auraWhitelistImportantGlowColor", 0, 1, 0)
        end
        BBF.UpdateEnlargedGlowSwatch(button)
        if button.checkBoxPandemic then
            BBF.TintGlowSwatch(button.checkBoxPandemic.swatch, "auraPandemicGlowColor", 1, 0, 0)
        end
    end
    if BBF.auraImportantHeaderIcon then
        BBF.TintGlowSwatch(BBF.auraImportantHeaderIcon, "auraWhitelistImportantGlowColor", 0, 1, 0)
    end
end

function BBF.OpenAuraGlowColor(colorKey, dr, dg, db)
    local color = BetterBlizzFramesDB[colorKey]
    if type(color) ~= "table" then
        color = { dr, dg, db, 1 }
        BetterBlizzFramesDB[colorKey] = color
    end

    local r, g, b = color[1] or dr, color[2] or dg, color[3] or db
    local a = color[4] or 1

    local function Apply()
        color[1], color[2], color[3], color[4] = r, g, b, a
        BBF.RefreshAuraGlowSwatches()
        BBF.RefreshAllAuraFrames()
    end

    ColorPickerFrame.previousValues = { r = r, g = g, b = b, a = a }
    ColorPickerFrame:SetupColorPickerAndShow({
        r = r, g = g, b = b, opacity = a, hasOpacity = true,
        swatchFunc = function()
            r, g, b = ColorPickerFrame:GetColorRGB()
            Apply()
        end,
        opacityFunc = function()
            a = ColorPickerFrame:GetColorAlpha()
            Apply()
        end,
        cancelFunc = function(previousValues)
            if not previousValues then return end
            r, g, b, a = previousValues.r, previousValues.g, previousValues.b, previousValues.a
            Apply()
        end,
    })
end

local function CreateList(subPanel, listName, listData, refreshFunc, extraBoxes, width, pos)
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
    BBF[listName.."TextLines"] = textLines
    BBF[listName.."ExtraBoxes"] = extraBoxes
    local framePool = {}
    BBF[listName.."EntryToDelete"] = nil
    BBF.SetListSearchFilter(listName, "")

    local function GetList()
        local live = BetterBlizzFramesDB and BetterBlizzFramesDB[listName]
        if type(live) == "table" and live ~= listData then
            listData = live
        end
        return listData or {}
    end

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

    local function createOrUpdateTextLineButton(npc, index, extraBoxes)
        local button

        -- Reuse frame from the pool if available
        if framePool[index] then
            button = framePool[index]
            button:Show()
        else
            -- Create a new frame if pool is exhausted
            button = CreateFrame("Frame", nil, contentFrame)
            button:SetSize((width and width - 12) or (322 - 12), 20)
            button:SetPoint("TOPLEFT", 10, -(index - 1) * 20)

            -- Background
            local bg = button:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            button.bgImg = bg  -- Store the background texture for later updates

            -- Icon
            local iconTexture = button:CreateTexture(nil, "OVERLAY")
            iconTexture:SetSize(20, 20)  -- Same height as the button
            iconTexture:SetPoint("LEFT", button, "LEFT", 0, 0)
            button.iconTexture = iconTexture

            -- Text
            local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("LEFT", button, "LEFT", 25, 0)
            button.text = text
            text:SetFont(fontSmall, 13)

            -- Delete Button
            local deleteButton = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
            deleteButton:SetSize(20, 20)
            deleteButton:SetPoint("RIGHT", button, "RIGHT", 4, 0)
            deleteButton:SetText("X")
            deleteButton:SetScript("OnClick", function()
                local npc = button.npcData
                local key = npc and (npc.id or (type(npc.name) == "string" and npc.name ~= "" and npc.name:lower()))
                if not key then return end
                if IsShiftKeyDown() then
                    deleteEntry(listName, key)
                else
                    BBF[listName .. "EntryToDelete"] = key
                    StaticPopup_Show("BBF_DELETE_NPC_CONFIRM_" .. listName)
                end
            end)
            button.deleteButton = deleteButton

            -- Save button to the pool
            framePool[index] = button
        end

        -- Update button's content
        button.npcData = npc
        local displayText
        if npc.id then
            displayText = string.format("%s (%d)", (npc.name or C_Spell.GetSpellName(npc.id) or "Name Missing"), npc.id)  -- Display as "Name (id)"
        else
            displayText = npc.name  -- Display just the name if there's no id
        end
        button.text:SetText(displayText)
        button.text:SetTextColor(1, 1, 0, 1)
        button.iconTexture:SetTexture(C_Spell.GetSpellTexture(npc.id or npc.name))

        if extraBoxes then
            if not button.checkBoxPandemic then
                local checkBoxPandemic = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxPandemic:SetSize(24, 24)
                checkBoxPandemic:SetPoint("RIGHT", button.deleteButton, "LEFT", 0, 0)
                checkBoxPandemic:SetScript("OnClick", function(self)
                    if not button.npcData then return end
                    button.npcData.pandemic = self:GetChecked() and true or nil
                    BBF.RefreshAllAuraFrames()
                end)
                local swatch = checkBoxPandemic:CreateTexture(nil, "ARTWORK", nil, 1)
                swatch:SetAtlas("newplayertutorial-drag-slotgreen")
                swatch:SetDesaturated(true)
                swatch:SetSize(27, 27)
                swatch:SetPoint("CENTER", checkBoxPandemic, "CENTER", -0.5, 0.5)
                checkBoxPandemic.swatch = swatch
                button.checkBoxPandemic = checkBoxPandemic
                CreateTooltipTwo(checkBoxPandemic, L["Pandemic_Glow_Icon"],
                    L["Tooltip_Pandemic_Glow_Entry"], nil, "ANCHOR_TOPRIGHT")
            end
            if not button.checkBoxImportant then
                local checkBoxImportant = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxImportant:SetSize(24, 24)
                checkBoxImportant:SetPoint("RIGHT", button.checkBoxPandemic, "LEFT", 0, 0)
                checkBoxImportant:SetScript("OnClick", function(self)
                    if not button.npcData then return end
                    local checked = self:GetChecked() and true or nil
                    button.npcData.important = checked
                    if checked then
                        button.npcData.pandemic = nil
                        button.checkBoxPandemic:SetChecked(false)
                        DisableElement(button.checkBoxPandemic)
                    elseif not button.npcData.enlarged then
                        EnableElement(button.checkBoxPandemic)
                    end
                    BBF.UpdateEnlargedGlowSwatch(button)
                    BBF.RefreshAllAuraFrames()
                end)
                local swatch = checkBoxImportant:CreateTexture(nil, "ARTWORK", nil, 1)
                swatch:SetAtlas("newplayertutorial-drag-slotgreen")
                swatch:SetDesaturated(true)
                swatch:SetSize(27, 27)
                swatch:SetPoint("CENTER", checkBoxImportant, "CENTER", -0.5, 0.5)
                checkBoxImportant.swatch = swatch
                checkBoxImportant:HookScript("OnMouseDown", function(_, mouseButton)
                    if mouseButton == "RightButton" then
                        BBF.OpenAuraGlowColor("auraWhitelistImportantGlowColor", 0, 1, 0)
                    end
                end)
                button.checkBoxImportant = checkBoxImportant
                CreateTooltipTwo(checkBoxImportant, L["Important_Glow_Icon"],
                    L["Tooltip_Important_Glow_Entry"], nil, "ANCHOR_TOPRIGHT")
            end
            if not button.checkBoxEnlarged then
                local checkBoxEnlarged = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxEnlarged:SetSize(24, 24)
                checkBoxEnlarged:SetPoint("RIGHT", button.checkBoxImportant, "LEFT", 0, 0)
                checkBoxEnlarged:SetScript("OnClick", function(self)
                    if not button.npcData then return end
                    local checked = self:GetChecked() and true or nil
                    button.npcData.enlarged = checked
                    if checked then
                        button.npcData.pandemic = nil
                        button.checkBoxPandemic:SetChecked(false)
                        DisableElement(button.checkBoxPandemic)
                    elseif not button.npcData.important then
                        EnableElement(button.checkBoxPandemic)
                    end
                    BBF.UpdateEnlargedGlowSwatch(button)
                    BBF.RefreshAllAuraFrames()
                end)
                local swatch = checkBoxEnlarged:CreateTexture(nil, "ARTWORK", nil, 1)
                swatch:SetAtlas("newplayertutorial-drag-slotgreen")
                swatch:SetDesaturated(true)
                swatch:SetSize(27, 27)
                swatch:SetPoint("CENTER", checkBoxEnlarged, "CENTER", -0.5, 0.5)
                checkBoxEnlarged.swatch = swatch
                checkBoxEnlarged:HookScript("OnMouseDown", function(_, mouseButton)
                    if mouseButton == "RightButton" then
                        BBF.OpenAuraGlowColor("auraEnlargedGlowColor", 1, 0.5, 0)
                    end
                end)
                button.checkBoxEnlarged = checkBoxEnlarged
                CreateTooltipTwo(checkBoxEnlarged, L["Enlarged_Aura_Icon"],
                    L["Tooltip_Enlarged_Aura_Entry"], nil, "ANCHOR_TOPRIGHT")
            end
            if not button.checkBoxOnlyMine then
                local checkBoxOnlyMine = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxOnlyMine:SetSize(24, 24)
                checkBoxOnlyMine:SetPoint("RIGHT", button.checkBoxEnlarged, "LEFT", 0, 0)
                checkBoxOnlyMine:SetScript("OnClick", function(self)
                    if not button.npcData then return end
                    button.npcData.onlyMine = self:GetChecked() and true or nil
                    BBF.RefreshAllAuraFrames()
                end)
                button.checkBoxOnlyMine = checkBoxOnlyMine
                CreateTooltipTwo(checkBoxOnlyMine, L["Only_My_Aura_Icon"], L["Tooltip_Only_My_Aura"], nil, "ANCHOR_TOPRIGHT")

                button.text:SetWidth((width or 322) - 161)
                button.text:SetWordWrap(false)
                button.text:SetJustifyH("LEFT")
            end
            button.checkBoxOnlyMine:SetChecked(button.npcData.onlyMine)

            BBF.TintGlowSwatch(button.checkBoxImportant.swatch, "auraWhitelistImportantGlowColor", 0, 1, 0)
            button.checkBoxImportant:SetChecked(button.npcData.important)

            BBF.UpdateEnlargedGlowSwatch(button)
            button.checkBoxEnlarged:SetChecked(button.npcData.enlarged)

            BBF.TintGlowSwatch(button.checkBoxPandemic.swatch, "auraPandemicGlowColor", 1, 0, 0)
            button.checkBoxPandemic:SetChecked(button.npcData.pandemic)

            if button.npcData.important or button.npcData.enlarged then
                DisableElement(button.checkBoxPandemic)
            else
                EnableElement(button.checkBoxPandemic)
            end
        end

        if listName == "auraBlacklist" then
            if not button.checkBoxShowMine then
                -- Create Checkbox Only Mine if not already created
                local checkBoxShowMine = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxShowMine:SetSize(24, 24)
                checkBoxShowMine:SetPoint("RIGHT", button.deleteButton, "LEFT", 0, 0)
                CreateTooltipTwo(checkBoxShowMine, L["Show_Mine_Icon"] .. " |A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:22:22|a", L["Tooltip_Show_Mine"], nil, "ANCHOR_TOPRIGHT")

                -- Handler for the show mine checkbox
                checkBoxShowMine:SetScript("OnClick", function(self)
                    if not button.npcData then return end
                    button.npcData.showMine = self:GetChecked() and true or nil
                    BBF.RefreshAllAuraFrames()
                end)

                button.text:SetWidth((width or 322) - 89)
                button.text:SetWordWrap(false)
                button.text:SetJustifyH("LEFT")

                -- Save the reference to the button
                button.checkBoxShowMine = checkBoxShowMine
            end
            button.checkBoxShowMine:SetChecked(button.npcData.showMine)
        end

        if not button.idTip then
            button:SetScript("OnEnter", function(self)
                if not button.npcData.id then return end
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:SetSpellByID(button.npcData.id)
                GameTooltip:AddLine(L["Tooltip_Spell_ID"] .. button.npcData.id, 1, 1, 1)
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
            button.idTip = true
        end

        return button
    end
    BBF["UpdateTextLine"..listName] = createOrUpdateTextLineButton

    local editBox = CreateFrame("EditBox", nil, subPanel, "InputBoxTemplate")
    editBox:SetSize((width and width - 62) or (322 - 62), 19)
    editBox:SetPoint("TOP", scrollFrame, "BOTTOM", -15, -5)
    editBox:SetAutoFocus(false)
    BBF[listName.."EditBox"] = editBox
    if listName == "auraBlacklist" then
        CreateTooltipTwo(editBox, L["Add_Blacklist_Aura"], L["Tooltip_Add_Blacklist_Aura"], nil, "ANCHOR_TOP")
    else
        CreateTooltipTwo(editBox, L["Add_Whitelist_Aura"], L["Tooltip_Add_Whitelist_Aura"], nil, "ANCHOR_TOP")
    end

    local function cleanUpEntry(entry)
        -- Iterate through each field in the entry
        for key, value in pairs(entry) do
            if value == false then
                entry[key] = nil
            end
        end
    end

    local function GetEntryName(entry)
        local name = entry.name
        if type(name) == "string" and name ~= "" then return name end
        if entry.id then
            local resolved = BBF.TWWGetSpellInfo(entry.id) or C_Spell.GetSpellName(entry.id)
            if resolved and resolved ~= "" then
                entry.name = resolved
                return resolved
            end
        end
        return nil
    end

    local function getSortedNpcList()
        local sortableNpcList = {}

        -- Iterate over the structure using pairs to access all entries
        local filter = BBF.GetListSearchFilter(listName)
        local safeFilter = filter:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
        for key, entry in pairs(GetList()) do
            if type(entry) == "table" then
                cleanUpEntry(entry)
                local name = GetEntryName(entry)
                if filter == "" or (name and name:lower():match(safeFilter)) or (entry.id and tostring(entry.id):match(safeFilter)) then
                    table.insert(sortableNpcList, entry)
                end
            end
        end

        -- Sort the list alphabetically by the 'name' field, and then by 'id' if the names are the same
        table.sort(sortableNpcList, function(a, b)
            local nameA = GetEntryName(a)
            local nameB = GetEntryName(b)
            if (nameA ~= nil) ~= (nameB ~= nil) then
                return nameA ~= nil
            end
            if nameA and nameB then
                nameA, nameB = nameA:lower(), nameB:lower()
                if nameA ~= nameB then
                    return nameA < nameB
                end
            end

            -- If names are the same, compare by id (sort low to high)
            local idA = tonumber(a.id) or math.huge
            local idB = tonumber(b.id) or math.huge
            return idA < idB
        end)

        return sortableNpcList
    end

    local function releaseRowsFrom(firstIndex)
        for i = firstIndex, #framePool do
            local button = framePool[i]
            if button then
                button.npcData = nil
                button:Hide()
            end
        end
    end

    local function clampScroll()
        local maxScroll = math.max(0, contentFrame:GetHeight() - scrollFrame:GetHeight())
        if scrollFrame:GetVerticalScroll() > maxScroll then
            scrollFrame:SetVerticalScroll(maxScroll)
        end
    end

    -- Function to update the list with batching logic
    local refreshGeneration = 0
    local function refreshList()
        local sortedListData = getSortedNpcList()
        local totalEntries = #sortedListData
        local batchSize = 35  -- Number of entries to process per frame
        local currentIndex = 1

        refreshGeneration = refreshGeneration + 1
        local generation = refreshGeneration
        wipe(textLines)

        local function processNextBatch()
            if generation ~= refreshGeneration then return end

            local lastIndex = math.min(currentIndex + batchSize - 1, totalEntries)
            for i = currentIndex, lastIndex do
                local npc = sortedListData[i]
                local button = createOrUpdateTextLineButton(npc, i, extraBoxes)
                textLines[i] = button
            end

            releaseRowsFrom(lastIndex + 1)

            -- Update the content frame height
            contentFrame:SetHeight(totalEntries * 20)
            updateBackgroundColors()
            clampScroll()

            -- Continue processing if there are more entries
            currentIndex = lastIndex + 1
            if currentIndex <= totalEntries then
                C_Timer.After(0.04, processNextBatch)  -- Defer to the next frame
            end
        end
        -- Start processing in the first frame
        processNextBatch()
    end

    contentFrame.refreshList = refreshList
    refreshList()
    --BBF[listName.."DelayedUpdate"] = refreshList
    BBF[listName.."Refresh"] = refreshList
    --BBF.auraWhitelist & BBF.auraBlacklist

    editBox:SetScript("OnEnterPressed", function(self)
        addOrUpdateEntry(self:GetText(), listName)
    end)

        -- Function to search and filter the list
        local function searchList(searchText)
            local text = searchText:lower()
            if BBF.GetListSearchFilter(listName) ~= text then
                BBF.SetListSearchFilter(listName, text)
                scrollFrame:SetVerticalScroll(0)
            end
            refreshList()
        end

        -- Update the list as the user types
        editBox:SetScript("OnTextChanged", function(self, userInput)
            if userInput then
                searchList(self:GetText())
            end
        end, true)

    local addButton = CreateFrame("Button", nil, subPanel, "UIPanelButtonTemplate")
    addButton:SetSize(60, 24)
    addButton:SetText(L["Add"])
    addButton:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
    addButton:SetScript("OnClick", function()
        addOrUpdateEntry(editBox:GetText(), listName)
    end)
    scrollFrame:HookScript("OnShow", function()
        if BBF.auraWhitelistDelayedUpdate then
            BBF.auraWhitelistDelayedUpdate()
            BBF.auraWhitelistDelayedUpdate = nil
        end
        if BBF.auraBlacklistDelayedUpdate then
            BBF.auraBlacklistDelayedUpdate()
            BBF.auraBlacklistDelayedUpdate = nil
        end
    end)
    return scrollFrame
end

SettingsPanel:HookScript("OnShow", function()
    if BBF.auraWhitelistDelayedUpdate then
        BBF.auraWhitelistDelayedUpdate()
        BBF.auraWhitelistDelayedUpdate = nil
    end
    if BBF.auraBlacklistDelayedUpdate then
        BBF.auraBlacklistDelayedUpdate()
        BBF.auraBlacklistDelayedUpdate = nil
    end
end)

local function CreateCDManagerList(parent)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    local width, height = 450, 510
    scrollFrame:SetSize(width, height)
    scrollFrame:SetPoint("TOPLEFT", 185, -14)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(width, height)
    scrollFrame:SetScrollChild(content)

    local spellText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    spellText:SetPoint("BOTTOMLEFT", scrollFrame, "TOPLEFT", 10, 3)
    spellText:SetText(L["Spell"])

    local priorityText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    priorityText:SetPoint("BOTTOMLEFT", scrollFrame, "TOP", 95, 3)
    priorityText:SetText(L["Priority"])

    local blacklistIcon = parent:CreateTexture(nil, "OVERLAY")
    blacklistIcon:SetAtlas("lootroll-toast-icon-pass-up")
    blacklistIcon:SetPoint("BOTTOM", scrollFrame, "TOPRIGHT", -29, 1)
    blacklistIcon:SetSize(22, 22)
    CreateTooltip(blacklistIcon, L["Tooltip_Hide_Spell_Icon"] .. " |A:lootroll-toast-icon-pass-up:22:22|a")

    local framePool = {}

    local function refreshList()
        local baseSpells = {}
        local blacklist = BetterBlizzFramesDB.cdManagerBlacklist or {}
        local priorityList = BetterBlizzFramesDB.cdManagerPriorityList or {}

        for _, id in ipairs(BBF.cooldownManagerSpells or {}) do
            baseSpells[id] = true
        end

        local fullList = {}
        for _, id in ipairs(BBF.cooldownManagerSpells or {}) do table.insert(fullList, id) end
        for idStr, _ in pairs(blacklist) do
            local id = tonumber(idStr)
            if id and not baseSpells[id] then
                table.insert(fullList, id)
            end
        end
        for idStr, _ in pairs(priorityList) do
            local id = tonumber(idStr)
            if id and not baseSpells[id] then
                table.insert(fullList, id)
            end
        end

        for i, button in ipairs(framePool) do button:Hide() end

        for i, spellID in ipairs(fullList) do
            local info = C_Spell.GetSpellInfo(spellID)
            if info then
                local name = info.name
                local icon = info.iconID or info.originalIconID
                local isCustom = not baseSpells[spellID]

                local button = framePool[i]
                if not button then
                    button = CreateFrame("Frame", nil, content)
                    button:SetSize(width - 12, 20)
                    button:SetPoint("TOPLEFT", 10, -(i - 1) * 20)

                    local bg = button:CreateTexture(nil, "BACKGROUND")
                    bg:SetAllPoints()
                    button.bg = bg

                    local iconTex = button:CreateTexture(nil, "ARTWORK")
                    iconTex:SetSize(20, 20)
                    iconTex:SetPoint("LEFT")
                    button.iconTex = iconTex

                    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    label:SetPoint("LEFT", iconTex, "RIGHT", 5, 0)
                    button.label = label

                    local checkbox = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                    checkbox:SetSize(24, 24)
                    checkbox:SetPoint("RIGHT", button, "RIGHT", -15, 0)
                    CreateTooltipTwo(checkbox, L["Hide_Spell_Icon"] .. " |A:lootroll-toast-icon-pass-up:22:22|a", L["Tooltip_Hide_Spell_Icon_CD"], nil, "ANCHOR_TOPRIGHT")
                    button.checkbox = checkbox

                    local slider = CreateFrame("Slider", nil, button, "OptionsSliderTemplate")
                    slider:SetSize(80, 16)
                    slider:SetPoint("RIGHT", checkbox, "LEFT", -20, 0)
                    slider:SetMinMaxValues(0, 20)
                    slider:SetValueStep(1)
                    slider:SetObeyStepOnDrag(true)
                    slider.Low:SetText("")
                    slider.High:SetText("")
                    CreateTooltipTwo(slider, L["Priority_Value"], L["Tooltip_Priority"], nil, "ANCHOR_TOPRIGHT")
                    button.slider = slider

                    local text = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    text:SetPoint("RIGHT", slider, "LEFT", -5, 0)
                    button.sliderText = text

                    local del = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
                    del:SetSize(18, 18)
                    del:SetText("X")
                    del:SetPoint("RIGHT", button, "RIGHT", 0, 0)
                    button.del = del
                    CreateTooltipTwo(del, L["Delete"], L["Tooltip_Delete"])

                    framePool[i] = button
                end

                button.iconTex:SetTexture(icon)
                button.label:SetText(name .. " (" .. spellID .. ")")

                local isBlacklisted = BetterBlizzFramesDB.cdManagerBlacklist[spellID]
                local priority = BetterBlizzFramesDB.cdManagerPriorityList[spellID]

                button.checkbox:SetChecked(isBlacklisted or false)
                if isBlacklisted then
                    button.slider:Disable()
                    button.slider:SetAlpha(0.3)
                else
                    button.slider:Enable()
                    button.slider:SetAlpha(1)
                end

                local value = priority or 0
                button.slider:SetValue(value)
                button.sliderText:SetText(value)
                if value == 0 then
                    button.slider:SetAlpha(0.3)
                else
                    button.slider:SetAlpha(1)
                end

                button.checkbox:SetScript("OnClick", function(self)
                    if self:GetChecked() then
                        BetterBlizzFramesDB.cdManagerBlacklist[spellID] = true
                        BetterBlizzFramesDB.cdManagerPriorityList[spellID] = nil
                    else
                        BetterBlizzFramesDB.cdManagerBlacklist[spellID] = false
                    end
                    refreshList()
                    BBF.ResetCooldownManagerIcons()
                    BBF.RefreshCooldownManagerIcons()
                end)

                button.slider:SetScript("OnValueChanged", function(self, value)
                    local v = math.floor(value + 0.5)
                    self:SetValue(v)
                    button.sliderText:SetText(v)

                    if v == 0 then
                        BetterBlizzFramesDB.cdManagerPriorityList[spellID] = nil
                        self:SetAlpha(0.3)
                    else
                        BetterBlizzFramesDB.cdManagerPriorityList[spellID] = v
                        self:SetAlpha(1)
                    end

                    BBF.RefreshCooldownManagerIcons()
                end)

                if isCustom then
                    button.del:SetScript("OnClick", function()
                        BetterBlizzFramesDB.cdManagerBlacklist[spellID] = nil
                        BetterBlizzFramesDB.cdManagerPriorityList[spellID] = nil
                        refreshList()
                        BBF.RefreshCooldownManagerIcons()
                    end)
                    button.del:Show()
                else
                    button.del:Hide()
                end

                button.bg:SetColorTexture(0.2, 0.2, 0.2, i % 2 == 0 and 0.1 or 0.3)
                button:Show()
            end
        end

        local input = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
        input:SetSize(width-50, 20)
        input:SetPoint("TOPLEFT", scrollFrame, "BOTTOMLEFT", 15, -8)
        input:SetAutoFocus(false)
        CreateTooltipTwo(input, L["Enter_Spell_ID"], L["Tooltip_Enter_Spell"], L["Tooltip_Enter_Spell_Note"], "ANCHOR_TOP")

        function BBF.AddCDManagerSpellEntry(inputText, refreshList)
            if not inputText or inputText == "" then return end

            local id = tonumber(inputText)
            local info = C_Spell.GetSpellInfo(id or inputText)

            if info and info.spellID then
                local spellID = info.spellID
                if not BetterBlizzFramesDB.cdManagerPriorityList[spellID] and not BetterBlizzFramesDB.cdManagerBlacklist[spellID] then
                    BetterBlizzFramesDB.cdManagerBlacklist[spellID] = false
                    refreshList()
                    BBF.RefreshCooldownManagerIcons()
                end
            elseif not id then -- if it's not a number and didn't resolve to a spell, treat it as a raw name
                if not BetterBlizzFramesDB.cdManagerPriorityList[inputText] and not BetterBlizzFramesDB.cdManagerBlacklist[inputText] then
                    BetterBlizzFramesDB.cdManagerBlacklist[inputText] = false
                    refreshList()
                    BBF.RefreshCooldownManagerIcons()
                end
            else
                BBF.Print(string.format(L["Print_Invalid_Spell_ID"], inputText))
            end
        end

        input:SetScript("OnEnterPressed", function(self)
            BBF.AddCDManagerSpellEntry(self:GetText(), refreshList)
            self:SetText("")
        end)

        local add = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        add:SetSize(50, 22)
        add:SetText(L["Add"])
        add:SetPoint("LEFT", input, "RIGHT", 6, 0)

        add:SetScript("OnClick", function()
            BBF.AddCDManagerSpellEntry(input:GetText(), refreshList)
            input:SetText("")
        end)

        content:SetHeight(#fullList * 22)
    end

    scrollFrame:HookScript("OnShow", function()
        if BBF.cdManagerNeedsUpdate then
            refreshList()
        end
    end)

    scrollFrame.Refresh = refreshList
    BBF.RefreshCdManagerList = refreshList
    BBF.cdManagerScrollFrame = scrollFrame

    refreshList()
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
    verNumber:SetText(BBF.VersionNumber)
end

local function CreateSearchFrame()
    local searchFrame = CreateFrame("Frame", "BBFSearchFrame", UIParent)
    searchFrame:SetSize(680, 610)
    searchFrame:SetPoint("CENTER", UIParent, "CENTER")
    searchFrame:SetFrameStrata("HIGH")
    searchFrame:Hide()

    local wipText = searchFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    wipText:SetPoint("BOTTOM", searchFrame, "BOTTOM", -10, 10)
    wipText:SetText(L["Search_WIP"])

    CreateTitle(searchFrame)

    local bgImg = searchFrame:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", searchFrame, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0, 0, 0)

    local settingsText = searchFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    settingsText:SetPoint("TOPLEFT", searchFrame, "TOPLEFT", 20, 0)
    settingsText:SetText(L["Search_Results"])

    -- Icon next to the title
    local searchIcon = searchFrame:CreateTexture(nil, "ARTWORK")
    searchIcon:SetAtlas("communities-icon-searchmagnifyingglass")
    searchIcon:SetSize(28, 28)
    searchIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)

    -- Reference the existing SettingsPanel.SearchBox to copy properties
    local referenceBox = SettingsPanel.SearchBox

    -- Create the search input field on top of SettingsPanel.SearchBox
    local searchBox = CreateFrame("EditBox", nil, SettingsPanel, "InputBoxTemplate")
    searchBox:SetSize(referenceBox:GetWidth() + 1, referenceBox:GetHeight() + 1)
    searchBox:SetPoint("CENTER", referenceBox, "CENTER")
    searchBox:SetFrameStrata("HIGH")
    searchBox:SetAutoFocus(false)
    searchBox.Left:Hide()
    searchBox.Right:Hide()
    searchBox.Middle:Hide()
    searchBox:SetFontObject(referenceBox:GetFontObject())
    searchBox:SetTextInsets(16, 8, 0, 0)
    searchBox:Hide()
    searchBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    CreateTooltipTwo(searchBox, L["Search"] .. " |A:shop-games-magnifyingglass:17:17|a", L["Tooltip_Search_Desc"], nil, "TOP")

    local resultsList = CreateFrame("Frame", nil, searchFrame)
    resultsList:SetSize(640, 500)
    resultsList:SetPoint("TOP", settingsText, "BOTTOM", 0, -10)

    local checkboxPool = {}
    local sliderPool = {}

    local function SearchElements(query)
        for _, child in ipairs({resultsList:GetChildren()}) do
            child:Hide()
        end

        if query == "" then
            return
        end

        -- Convert the query into lowercase and split it into individual words
        query = string.lower(query)
        local queryWords = { strsplit(" ", query) }

        local checkboxCount = 0
        local sliderCount = 0
        local yOffsetCheckbox = -20  -- Starting position for the first checkbox
        local yOffsetSlider = -20    -- Starting position for the first slider

        -- Helper function to check if all query words are in the label
        local function matchesQuery(label)
            label = string.lower(label)
            for _, queryWord in ipairs(queryWords) do
                if not string.find(label, queryWord) then
                    return false
                end
            end
            return true
        end

        local function applyRightClickScript(searchCheckbox, originalCheckbox)
            local originalScript = originalCheckbox:GetScript("OnMouseDown")
            if originalScript then
                searchCheckbox:SetScript("OnMouseDown", function(self, button)
                    if button == "RightButton" then
                        originalScript(originalCheckbox, button)
                    end
                end)
            end
        end

        -- Search through checkboxes
        for _, data in ipairs(checkBoxList) do
            if checkboxCount >= 20 then break end

            -- Prepare the label and tooltip text
            local label = string.lower(data.label or "")
            local tooltipTitle = string.lower(data.checkbox.tooltipTitle or "")
            local tooltipMainText = string.lower(data.checkbox.tooltipMainText or "")
            local tooltipSubText = string.lower(data.checkbox.tooltipSubText or "")
            local tooltipCVarName = string.lower(data.checkbox.tooltipCVarName or "")

            -- Check if all query words are found in any of the searchable fields
            if matchesQuery(label) or matchesQuery(tooltipTitle) or matchesQuery(tooltipMainText) or matchesQuery(tooltipSubText) or matchesQuery(tooltipCVarName) then
                checkboxCount = checkboxCount + 1

                -- Re-use or create a new checkbox from the pool
                local resultCheckBox = checkboxPool[checkboxCount]
                if not resultCheckBox then
                    resultCheckBox = CreateFrame("CheckButton", nil, resultsList, "InterfaceOptionsCheckButtonTemplate")
                    resultCheckBox:SetSize(23, 23)
                    resultCheckBox.Text:SetFont(fontSmall, 12)
                    checkboxPool[checkboxCount] = resultCheckBox
                end

                -- Update checkbox properties and position
                resultCheckBox:ClearAllPoints()
                resultCheckBox:SetPoint("TOPLEFT", searchIcon, "TOPLEFT", 27, yOffsetCheckbox)
                resultCheckBox.Text:SetText(data.label)
                if not data.label or data.label == "" then
                    resultCheckBox.Text:SetText(data.checkbox.tooltipTitle)
                end
                resultCheckBox:SetChecked(data.checkbox:GetChecked())

                -- Link the result checkbox to the main checkbox
                resultCheckBox:SetScript("OnClick", function()
                    data.checkbox:Click()
                end)

                applyRightClickScript(resultCheckBox, data.checkbox)

                -- Reapply tooltip
                if data.checkbox.tooltipMainText then
                    CreateTooltipTwo(resultCheckBox, data.checkbox.tooltipTitle, data.checkbox.tooltipMainText, data.checkbox.tooltipSubText, nil, data.checkbox.tooltipCVarName, nil, data.checkbox.searchCategory)
                elseif data.checkbox.tooltipTitle then
                    CreateTooltipTwo(resultCheckBox, data.checkbox.tooltipTitle, nil, nil, nil, nil, nil, data.checkbox.searchCategory)
                else
                    CreateTooltipTwo(resultCheckBox, L["No_data_yet_WIP"], nil, nil, nil, nil, nil, data.checkbox.searchCategory)
                end

                resultCheckBox:Show()

                -- Move down for the next checkbox
                yOffsetCheckbox = yOffsetCheckbox - 24
            end
        end

        -- Search through sliders
        for _, data in ipairs(sliderList) do
            if sliderCount >= 13 then break end

            -- Prepare the label and tooltip text
            local label = string.lower(data.label or "")
            local tooltipTitle = string.lower(data.slider.tooltipTitle or "")
            local tooltipMainText = string.lower(data.slider.tooltipMainText or "")
            local tooltipSubText = string.lower(data.slider.tooltipSubText or "")
            local tooltipCVarName = string.lower(data.slider.tooltipCVarName or "")

            -- Check if all query words are found in any of the searchable fields
            if matchesQuery(label) or matchesQuery(tooltipTitle) or matchesQuery(tooltipMainText) or matchesQuery(tooltipSubText) or matchesQuery(tooltipCVarName) then
                sliderCount = sliderCount + 1

                -- Re-use or create a new slider from the slider pool
                local resultSlider = sliderPool[sliderCount]
                if not resultSlider then
                    resultSlider = CreateFrame("Slider", nil, resultsList, "OptionsSliderTemplate")
                    resultSlider:SetOrientation('HORIZONTAL')
                    resultSlider:SetValueStep(data.slider:GetValueStep())
                    resultSlider:SetObeyStepOnDrag(true)
                    resultSlider.Text = resultSlider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    resultSlider.Text:SetTextColor(1, 0.81, 0, 1)
                    resultSlider.Text:SetFont(fontSmall, 11)
                    resultSlider.Text:SetPoint("TOP", resultSlider, "BOTTOM", 0, -1)
                    resultSlider.Low:SetText(" ")
                    resultSlider.High:SetText(" ")
                    sliderPool[sliderCount] = resultSlider
                end

                -- Format the slider text value
                local function formatSliderValue(value)
                    return value % 1 == 0 and tostring(math.floor(value)) or string.format("%.2f", value)
                end

                -- Update slider properties and position
                resultSlider:ClearAllPoints()
                resultSlider:SetPoint("TOPLEFT", searchIcon, "TOPLEFT", 277, yOffsetSlider)
                resultSlider:SetScript("OnValueChanged", nil)
                resultSlider:SetMinMaxValues(data.slider:GetMinMaxValues())
                resultSlider:SetValue(data.slider:GetValue())
                resultSlider.Text:SetText(data.label .. ": " .. formatSliderValue(data.slider:GetValue()))

                resultSlider:SetScript("OnValueChanged", function(self, value)
                    data.slider:SetValue(value) -- Trigger the original slider's script
                    resultSlider.Text:SetText(data.label .. ": " .. formatSliderValue(value))
                end)

                -- Tooltip setup for sliders
                if data.slider.tooltipMainText then
                    CreateTooltipTwo(resultSlider, data.slider.tooltipTitle, data.slider.tooltipMainText, data.slider.tooltipSubText, nil, data.slider.tooltipCVarName, nil, data.slider.searchCategory)
                elseif data.slider.tooltipTitle then
                    CreateTooltipTwo(resultSlider, data.slider.tooltipTitle, nil, nil, nil, nil, nil, data.slider.searchCategory)
                else
                    CreateTooltipTwo(resultSlider, L["No_data_yet_WIP"], nil, nil, nil, nil, nil, data.slider.searchCategory)
                end

                -- Show the slider and prepare for the next slider
                resultSlider:Show()
                yOffsetSlider = yOffsetSlider - 42
            end
        end
    end

    searchBox:SetScript("OnTextChanged", function(self)
        local query = self:GetText()
        if #query > 0 then
            SettingsPanelSearchIcon:SetVertexColor(1, 1, 1)
            SettingsPanel.SearchBox.Instructions:SetAlpha(0)
            searchFrame:Show()
            if SettingsPanel.currentLayout and SettingsPanel.currentLayout.frame then
                SettingsPanel.currentLayout.frame:Hide()
            end
        else
            SettingsPanelSearchIcon:SetVertexColor(0.6, 0.6, 0.6)
            SettingsPanel.SearchBox.Instructions:SetAlpha(1)
            searchFrame:Hide()
            if SettingsPanel.currentLayout and SettingsPanel.currentLayout.frame then
                SettingsPanel.currentLayout.frame:Show()
            end
        end
        if #query >= 1 then
            SearchElements(query)
        else
            SearchElements("")
        end

        if not searchBox.hookedSettings then
            SettingsPanel:HookScript("OnHide", function()
                SettingsPanelSearchIcon:SetVertexColor(0.6, 0.6, 0.6)
                SettingsPanel.SearchBox.Instructions:SetAlpha(1)
                searchFrame:Hide()
                searchBox:Hide()
                if SettingsPanel.currentLayout and SettingsPanel.currentLayout.frame then
                    searchBox:SetText("")
                    SettingsPanel.currentLayout.frame:Show()
                end
            end)
            searchBox.hookedSettings = true
        end
    end)

    hooksecurefunc(SettingsPanel, "DisplayLayout", function()
        if SettingsPanel.currentLayout.frame and SettingsPanel.currentLayout.frame.name == "Better|cff00c0ffBlizz|rFrames |A:gmchat-icon-blizz:16:16|a" or
        (SettingsPanel.currentLayout.frame and SettingsPanel.currentLayout.frame.parent == "Better|cff00c0ffBlizz|rFrames |A:gmchat-icon-blizz:16:16|a") then
            SettingsPanel.SearchBox.Instructions:SetText(L["Search_In_BBF"])
            searchBox:Show()
            searchBox:SetText("")
            searchFrame:Hide()
            searchFrame:ClearAllPoints()
            searchFrame:SetPoint("TOPLEFT", SettingsPanel.currentLayout.frame, "TOPLEFT")
            searchFrame:SetPoint("BOTTOMRIGHT", SettingsPanel.currentLayout.frame, "BOTTOMRIGHT")
            if not SettingsPanel.currentLayout.frame:IsShown() then
                SettingsPanel.currentLayout.frame:Show()
            end
        else
            if SettingsPanel.SearchBox.Instructions:GetText() == L["Search_In_BBF"] then
                SettingsPanel.SearchBox.Instructions:SetText(L["Search"])
            end
            searchBox:Hide()
            searchFrame:Hide()
        end
    end)
end

------------------------------------------------------------
-- GUI Panels
------------------------------------------------------------
local function guiProfiles()
    local parent = SettingsPanel
    local frame = CreateFrame("Frame", nil, BetterBlizzFrames, "SettingsFrameTemplate")
    frame.titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.titleText:SetPoint("TOP", frame, "TOP", 1, -4)
    frame.titleText:SetText("|A:gmchat-icon-blizz:16:16|a BBF")

    frame.descriptionText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.descriptionText:SetPoint("TOP", frame, "TOP", 2, -25)
    frame.descriptionText:SetText(L["Profile_Description"])
    frame.descriptionText:SetWidth(100)

    frame.coreText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.coreText:SetPoint("TOP", frame.descriptionText, "BOTTOM", 0, -3)
    frame.coreText:SetText(L["Profile_Core"])

    frame.streamerText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.streamerText:SetPoint("TOP", frame.coreText, "BOTTOM", 0, -55)
    frame.streamerText:SetText(L["Profile_Streamers"])

    frame.infoText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.infoText:SetPoint("BOTTOM", frame, "BOTTOM", 2, 50)
    frame.infoText:SetText(L["Profile_Info_Message"])
    frame.infoText:SetWidth(100)

    frame:SetSize(130, parent:GetHeight())
    frame:SetPoint("TOPRIGHT", parent, "TOPLEFT", 7, 0)
    frame:SetFrameStrata("BACKGROUND")
    frame.ClosePanelButton:Hide()

    local function CopyNineSliceColors(fromFrame, toFrame)
        if not (fromFrame and toFrame and fromFrame.NineSlice and toFrame.NineSlice) then
            return
        end

        local parts = {
            "TopLeftCorner", "TopRightCorner",
            "BottomLeftCorner", "BottomRightCorner",
            "TopEdge", "BottomEdge",
            "LeftEdge", "RightEdge",
            "Center",
        }

        for _, name in ipairs(parts) do
            local src = fromFrame.NineSlice[name]
            local dst = toFrame.NineSlice[name]
            if src and dst and src.GetVertexColor and dst.SetVertexColor then
                local r, g, b, a = src:GetVertexColor()
                dst:SetVertexColor(r, g, b, a)

                if src.IsDesaturated and dst.SetDesaturated then
                    dst:SetDesaturated(src:IsDesaturated())
                end
            end
        end
    end

    CopyNineSliceColors(SettingsPanel, frame)

    BetterBlizzFrames.profilesFrame = frame
    return frame
end

local function guiGeneralTab()
    ----------------------
    -- Main panel:
    ----------------------
    local mainGuiAnchor = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor:SetPoint("TOPLEFT", 15, -15)
    mainGuiAnchor:SetText(" ")

    BetterBlizzFrames.searchName = L["Search_Name_General"]

    local profilesFrame = guiProfiles()

    local bgImg = BetterBlizzFrames:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", BetterBlizzFrames, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local midnightBeta = BetterBlizzFrames:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    midnightBeta:SetPoint("BOTTOM", SettingsPanel, "TOP", 0, 0)
    midnightBeta:SetText(L["Msg_Midnight_Early_Beta"])
    midnightBeta:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
    midnightBeta:Hide()
    BetterBlizzFrames:HookScript("OnShow",function()
        midnightBeta:Show()
    end)
    BetterBlizzFrames:HookScript("OnHide",function()
        midnightBeta:Hide()
    end)

    local newSearch = BetterBlizzFrames:CreateTexture(nil, "BACKGROUND")
    newSearch:SetAtlas("NewCharacter-Horde", true)
    newSearch:SetPoint("BOTTOM", BetterBlizzFrames, "TOP", -70, 2)
    CreateTooltipTwo(newSearch, L["Search"] .. " |A:shop-games-magnifyingglass:17:17|a", L["Tooltip_Search_Desc"])

    local newSearchPoint = BetterBlizzFrames:CreateTexture(nil, "BACKGROUND")
    newSearchPoint:SetAtlas("auctionhouse-icon-buyallarrow", true)
    newSearchPoint:SetPoint("LEFT", newSearch, "RIGHT", -25, 0)
    newSearchPoint:SetRotation(math.pi / 2)

    CreateSearchFrame()
    -- local addonNameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    -- addonNameText:SetPoint("TOPLEFT", mainGuiAnchor, "TOPLEFT", -20, 47)
    -- addonNameText:SetText("BetterBlizzFrames"])
    -- local addonNameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    -- addonNameIcon:SetAtlas("gmchat-icon-blizz")
    -- addonNameIcon:SetSize(22, 22)
    -- addonNameIcon:SetPoint("LEFT", addonNameText, "RIGHT", -2, -1)
    -- local verNumber = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- verNumber:SetPoint("LEFT", addonNameText, "RIGHT", 25, 0)
    -- verNumber:SetText(BBF.VersionNumber)
    CreateTitle(BetterBlizzFrames)

    ----------------------
    -- General:
    ----------------------
    -- "General:" text
    local settingsText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, 30)
    settingsText:SetText(L["General_Settings"])
    settingsText:SetFont(fontLarge, 16)
    settingsText:SetTextColor(1,1,1)
    local generalSettingsIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    generalSettingsIcon:SetAtlas("optionsicon-brown")
    generalSettingsIcon:SetSize(22, 22)
    generalSettingsIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)


    if BetterBlizzFrames.titleText then
        BetterBlizzFrames.titleText:Hide()
        BetterBlizzFrames.loadGUI:Hide()
    end



    local hideArenaFrames = CreateCheckbox("hideArenaFrames", L["Hide_Arena_Frames"], BetterBlizzFrames, nil, BBF.HideArenaFrames)
    hideArenaFrames:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -24, pixelsOnFirstBox)
    hideArenaFrames:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    CreateTooltip(hideArenaFrames, L["Tooltip_Hide_Arena_Frames"])

    local hideBossFrames = CreateCheckbox("hideBossFrames", L["Hide_Boss_Frames"], BetterBlizzFrames, nil, BBF.HideArenaFrames)
    hideBossFrames:SetPoint("TOPLEFT", hideArenaFrames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideBossFrames, L["Tooltip_Hide_Boss_Frames"])

    local hideBossFramesParty = CreateCheckbox("hideBossFramesParty", L["Party"], BetterBlizzFrames, nil, BBF.HideArenaFrames)
    hideBossFramesParty:SetPoint("LEFT", hideBossFrames.text, "RIGHT", 0, 0)
    CreateTooltip(hideBossFramesParty, L["Tooltip_Hide_Boss_Frames_Party"], "ANCHOR_LEFT")

    local hideBossFramesRaid = CreateCheckbox("hideBossFramesRaid", L["Raid"], BetterBlizzFrames, nil, BBF.HideArenaFrames)
    hideBossFramesRaid:SetPoint("LEFT", hideBossFramesParty.text, "RIGHT", 0, 0)
    CreateTooltip(hideBossFramesRaid, L["Tooltip_Hide_Boss_Frames_Raid"], "ANCHOR_LEFT")

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

    local playerFrameOCD = CreateCheckbox("playerFrameOCD", L["OCD_Tweaks"], BetterBlizzFrames, nil, BBF.FixStupidBlizzPTRShit)
    playerFrameOCD:SetPoint("TOPLEFT", hideBossFrames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(playerFrameOCD, L["Tooltip_OCD_Tweaks_Retail"])

    -- local playerFrameOCDTextureBypass = CreateCheckbox("playerFrameOCDTextureBypass", L["OCD_Skip_Bars"], BetterBlizzFrames, nil, BBF.HideFrames)
    -- playerFrameOCDTextureBypass:SetPoint("LEFT", playerFrameOCD.text, "RIGHT", 0, 0)
    -- CreateTooltip(playerFrameOCDTextureBypass, L["Tooltip_OCD_Skip_Bars"])

    playerFrameOCD:HookScript("OnClick", function(self)
        BBF.AllNameChanges()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    -- if not BetterBlizzFramesDB.playerFrameOCD then
    --     playerFrameOCDTextureBypass:Disable()
    --     playerFrameOCDTextureBypass:SetAlpha(0)
    -- end

    local hideLossOfControlFrameBg = CreateCheckbox("hideLossOfControlFrameBg", L["Hide_CC_Background"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideLossOfControlFrameBg:SetPoint("TOPLEFT", playerFrameOCD, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideLossOfControlFrameBg, L["Tooltip_Hide_CC_Background"])
    hideLossOfControlFrameBg:HookScript("OnClick", function()
        BBF.ToggleLossOfControlTestMode()
    end)

    local hideLossOfControlFrameLines = CreateCheckbox("hideLossOfControlFrameLines", L["Hide_CC_Red_Lines"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideLossOfControlFrameLines:SetPoint("TOPLEFT", hideLossOfControlFrameBg, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideLossOfControlFrameLines, L["Tooltip_Hide_CC_Red_Lines"])
    hideLossOfControlFrameLines:HookScript("OnClick", function()
        BBF.ToggleLossOfControlTestMode()
    end)

    local darkModeUi = CreateCheckbox("darkModeUi", L["Dark_Mode"], BetterBlizzFrames)
    darkModeUi:SetPoint("TOPLEFT", hideLossOfControlFrameLines, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeUi:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeUi, L["Tooltip_Dark_Mode"])

    local darkModeActionBars = CreateCheckbox("darkModeActionBars", L["ActionBars"], darkModeUi)
    darkModeActionBars:SetPoint("TOPLEFT", darkModeUi, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeActionBars:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeActionBars, L["Dark_Borders_ActionBars"])

    local darkModeMinimap = CreateCheckbox("darkModeMinimap", L["Minimap"], darkModeUi)
    darkModeMinimap:SetPoint("TOPLEFT", darkModeActionBars, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeMinimap:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeMinimap, L["Dark_Mode_Minimap"])

    local darkModeCastbars = CreateCheckbox("darkModeCastbars", L["Castbars"], darkModeUi)
    darkModeCastbars:SetPoint("LEFT", darkModeUi.Text, "RIGHT", 5, 0)
    darkModeCastbars:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeCastbars, L["Dark_Borders_Castbars"])

    local darkModeUiAura = CreateCheckbox("darkModeUiAura", L["Auras"], darkModeUi)
    darkModeUiAura:SetPoint("TOPLEFT", darkModeCastbars, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeUiAura:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltipTwo(darkModeUiAura, L["Tooltip_Dark_Mode_Auras"], L["Tooltip_Dark_Mode_Auras_Desc"])
    darkModeUiAura:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not BetterBlizzFramesDB.removeDebuffColorBorder then
                BetterBlizzFramesDB.removeDebuffColorBorder = true
            else
                BetterBlizzFramesDB.removeDebuffColorBorder = nil
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local darkModeNameplateResource = CreateCheckbox("darkModeNameplateResource", L["Nameplate_Resource"], darkModeUi)
    darkModeNameplateResource:SetPoint("TOPLEFT", darkModeUiAura, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeNameplateResource:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeNameplateResource, L["Dark_Mode_Nameplate_Resource"])

    local darkModeGameTooltip = CreateCheckbox("darkModeGameTooltip", L["Tooltip"], darkModeUi)
    darkModeGameTooltip:SetPoint("TOPLEFT", darkModeMinimap, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeGameTooltip:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltipTwo(darkModeGameTooltip, L["Dark_Mode_Tooltip"], L["Tooltip_Dark_Mode_GameTooltip_Desc"])

    local darkModeEliteTexture = CreateCheckbox("darkModeEliteTexture", L["Elite_Texture"], darkModeUi)
    darkModeEliteTexture:SetPoint("TOPLEFT", darkModeGameTooltip, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeEliteTexture:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltipTwo(darkModeEliteTexture, L["Dark_Mode_Elite_Texture"], L["Tooltip_Dark_Mode_Elite_Texture_Desc"])
    darkModeEliteTexture:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not BetterBlizzFramesDB.darkModeEliteTextureDesaturated then
                BetterBlizzFramesDB.darkModeEliteTextureDesaturated = true
            else
                BetterBlizzFramesDB.darkModeEliteTextureDesaturated = nil
            end
            BBF.DarkmodeFrames(true)
        end
    end)

    local darkModeObjectiveFrame = CreateCheckbox("darkModeObjectiveFrame", L["Objectives"], darkModeUi)
    darkModeObjectiveFrame:SetPoint("LEFT", darkModeGameTooltip.Text, "RIGHT", 5, 0)
    darkModeObjectiveFrame:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltipTwo(darkModeObjectiveFrame, L["Dark_Mode_Objectives"], L["Tooltip_Dark_Mode_Objectives_Desc"])

    local darkModeVigor = CreateCheckbox("darkModeVigor", L["Vigor"], darkModeUi)
    darkModeVigor:SetPoint("LEFT", darkModeObjectiveFrame.Text, "RIGHT", 5, 0)
    darkModeVigor:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltipTwo(darkModeVigor, L["Dark_Mode_Vigor"], L["Tooltip_Dark_Mode_Vigor_Desc"])

    local darkModeColor = CreateSlider(darkModeUi, L["Darkness"], 0, 1, 0.01, "darkModeColor", nil, 90)
    darkModeColor:SetPoint("LEFT", darkModeUiAura.text, "RIGHT", 3, -1)
    CreateTooltipTwo(darkModeColor, L["Dark_Mode_Value"], L["Tooltip_Dark_Mode_Value_Desc"])

    darkModeUi:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(darkModeUi, 0)
    end)
    if not BetterBlizzFramesDB.darkModeUi then
        CheckAndToggleCheckboxes(darkModeUi, 0)
    end










    local playerFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playerFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -173)
    playerFrameText:SetText(L["Player_Frame"])
    playerFrameText:SetFont(fontLarge, 16)
    playerFrameText:SetTextColor(1,1,1)
    local playerFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    playerFrameIcon:SetAtlas("groupfinder-icon-friend")
    playerFrameIcon:SetSize(28, 28)
    playerFrameIcon:SetPoint("RIGHT", playerFrameText, "LEFT", -0.5, 0)

    BetterBlizzFrames.playerFrameHidden = CreateCheckbox("playerFrameHidden", L["Hide_Frame"], BetterBlizzFrames, nil, BBF.ClickthroughFrames)
    BetterBlizzFrames.playerFrameHidden:SetPoint("TOPLEFT", playerFrameText, "BOTTOMLEFT", -24, pixelsOnFirstBox)
    CreateTooltipTwo(BetterBlizzFrames.playerFrameHidden, L["Hide_Frame"], L["Tooltip_Hide_Player_Frame"])
    BetterBlizzFrames.playerFrameHidden:HookScript("OnClick", function(self)
        BBF.HidePlayerFrame()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local playerFrameClickthrough = CreateCheckbox("playerFrameClickthrough", L["Clickthrough"], BetterBlizzFrames, nil, BBF.ClickthroughFrames)
    playerFrameClickthrough:SetPoint("LEFT", BetterBlizzFrames.playerFrameHidden.text, "RIGHT", 5, 0)
    CreateTooltip(playerFrameClickthrough, L["Tooltip_Clickthrough"])
    playerFrameClickthrough:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local playerReputationColor = CreateCheckbox("playerReputationColor", L["Add_Reputation_Color"], BetterBlizzFrames, nil, BBF.PlayerReputationColor)
    playerReputationColor:SetPoint("TOPLEFT", BetterBlizzFrames.playerFrameHidden, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(playerReputationColor, L["Tooltip_Add_Reputation_Color"] .. " |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")

    local playerReputationClassColor = CreateCheckbox("playerReputationClassColor", L["Class_Color_Combo"], BetterBlizzFrames, nil, BBF.PlayerReputationColor)
    playerReputationClassColor:SetPoint("LEFT", playerReputationColor.text, "RIGHT", 5, 0)
    CreateTooltip(playerReputationClassColor, L["Tooltip_Class_Color_Reputation"])
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

    local hidePlayerName = CreateCheckbox("hidePlayerName", L["Hide_Names"], BetterBlizzFrames, nil, BBF.UpdateNameSettings)
    hidePlayerName:SetPoint("TOPLEFT", playerReputationColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hidePlayerName:HookScript("OnClick", function(self)
        -- if self:GetChecked() then
        --     PlayerFrame.name:SetAlpha(0)
        --     if PlayerFrame.bbfName then
        --         PlayerFrame.bbfName:SetAlpha(0)
        --     end
        -- else
        --     PlayerFrame.name:SetAlpha(0)
        --     if PlayerFrame.bbfName then
        --         PlayerFrame.bbfName:SetAlpha(1)
        --     else
        --         PlayerFrame.name:SetAlpha(1)
        --     end
        -- end
        BBF.SetCenteredNamesCaller()
    end)

    local symmetricPlayerFrame = CreateCheckbox("symmetricPlayerFrame", L["Mirror_TargetFrame"], BetterBlizzFrames, nil, BBF.SymmetricPlayerFrame)
    symmetricPlayerFrame:SetPoint("LEFT", hidePlayerName.text, "RIGHT", 0, 0)
    CreateTooltipTwo(symmetricPlayerFrame, L["Mirror_TargetFrame"], L["Tooltip_Mirror_TargetFrame_Desc_Midnight"])
    symmetricPlayerFrame:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    -- local hidePlayerMaxHpReduction = CreateCheckbox("hidePlayerMaxHpReduction", "Hide Reduced HP", BetterBlizzFrames, nil, BBF.HideFrames)
    -- hidePlayerMaxHpReduction:SetPoint("LEFT", hidePlayerName.text, "RIGHT", 0, 0)
    -- CreateTooltipTwo(hidePlayerMaxHpReduction, L["Hide_Reduced_HP"], L["Tooltip_Hide_Reduced_HP_Player"])

    local hidePlayerPower = CreateCheckbox("hidePlayerPower", L["Hide_Resource_Power"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerPower:SetPoint("TOPLEFT", hidePlayerName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hidePlayerPower, L["Hide_Resource_Power"], L["Tooltip_Hide_Resource_Power_Desc"])

    local classOptionsFrame
    local function OpenClassSpecificWindow()
        if not classOptionsFrame then
            classOptionsFrame = CreateFrame("Frame", "ClassOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
            classOptionsFrame:SetSize(185, 210)
            classOptionsFrame:SetPoint("CENTER")
            classOptionsFrame:SetFrameStrata("DIALOG")
            classOptionsFrame:SetMovable(true)
            classOptionsFrame:EnableMouse(true)
            classOptionsFrame:RegisterForDrag("LeftButton")
            classOptionsFrame:SetScript("OnDragStart", classOptionsFrame.StartMoving)
            classOptionsFrame:SetScript("OnDragStop", classOptionsFrame.StopMovingOrSizing)
            classOptionsFrame.title = classOptionsFrame:CreateFontString(nil, "OVERLAY")
            classOptionsFrame.title:SetFontObject("GameFontHighlight")
            classOptionsFrame.title:SetPoint("LEFT", classOptionsFrame.TitleBg, "LEFT", 5, 0)
            classOptionsFrame.title:SetText(L["Class_Specific_Options"])

            local classes = {
                { classID = 11, var = "hidePlayerPowerNoDruid", color = RAID_CLASS_COLORS["DRUID"] },
                { classID = 4, var = "hidePlayerPowerNoRogue", color = RAID_CLASS_COLORS["ROGUE"] },
                { classID = 9, var = "hidePlayerPowerNoWarlock", color = RAID_CLASS_COLORS["WARLOCK"] },
                { classID = 2, var = "hidePlayerPowerNoPaladin", color = RAID_CLASS_COLORS["PALADIN"] },
                { classID = 6, var = "hidePlayerPowerNoDeathKnight", color = RAID_CLASS_COLORS["DEATHKNIGHT"] },
                { classID = 13, var = "hidePlayerPowerNoEvoker", color = RAID_CLASS_COLORS["EVOKER"] },
                { classID = 10, var = "hidePlayerPowerNoMonk", color = RAID_CLASS_COLORS["MONK"] },
                { classID = 8, var = "hidePlayerPowerNoMage", color = RAID_CLASS_COLORS["MAGE"] },
            }

            local previousCheckbox
            for i, classData in ipairs(classes) do
                local classCheckbox = CreateFrame("CheckButton", nil, classOptionsFrame, "UICheckButtonTemplate")
                classCheckbox:SetSize(24, 24)
                local localizedClassName = GetClassInfo(classData.classID)
                classCheckbox.Text:SetText(string.format(L["Ignore_Class"], localizedClassName))

                -- Set the color of the checkbox label to the class color
                local r, g, b = classData.color.r, classData.color.g, classData.color.b
                classCheckbox.Text:SetTextColor(r, g, b)

                -- Position the checkboxes
                if i == 1 then
                    classCheckbox:SetPoint("TOPLEFT", classOptionsFrame, "TOPLEFT", 10, -30)
                else
                    classCheckbox:SetPoint("TOPLEFT", previousCheckbox, "BOTTOMLEFT", 0, 3)
                end

                -- Set the state from the DB
                classCheckbox:SetChecked(BetterBlizzFramesDB[classData.var])

                -- Save the state back to the DB when toggled
                classCheckbox:SetScript("OnClick", function(self)
                    BetterBlizzFramesDB[classData.var] = self:GetChecked() or nil
                    BBF.HideFrames()
                end)

                previousCheckbox = classCheckbox
            end
            classOptionsFrame:Show()
        else
            -- Toggle visibility of the frame when the function is called
            if classOptionsFrame:IsShown() then
                classOptionsFrame:Hide()
            else
                classOptionsFrame:Show()
            end
        end
    end

    hidePlayerPower:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenClassSpecificWindow()
        end
    end)

    local textures = BetterBlizzFramesDB.classicFrames and 7 or 4
    local playerEliteFrame = CreateCheckbox("playerEliteFrame", L["Elite_Texture"], BetterBlizzFrames)
    playerEliteFrame:SetPoint("LEFT", hidePlayerPower.text, "RIGHT", 5, 0)
    playerEliteFrame:HookScript("OnClick", function(self)
        BBF.PlayerElite(BetterBlizzFramesDB.playerEliteFrameMode)
    end)
    playerEliteFrame:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" and IsShiftKeyDown() then
            if not BetterBlizzFramesDB.playerEliteFrameDarkmode then
                BetterBlizzFramesDB.playerEliteFrameDarkmode = true
            else
                BetterBlizzFramesDB.playerEliteFrameDarkmode = nil
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
            BBF.PlayerElite(BetterBlizzFramesDB["playerEliteFrameMode"])
        elseif button == "RightButton" then
            BetterBlizzFramesDB["playerEliteFrameMode"] = BetterBlizzFramesDB["playerEliteFrameMode"] % textures + 1
            BBF.PlayerElite(BetterBlizzFramesDB["playerEliteFrameMode"])
        end
    end)
    CreateTooltipTwo(playerEliteFrame, L["Show_Elite_Texture"], string.format(L["Tooltip_Show_Elite_Texture_Desc"], textures))

    local hideResourceTooltip = CreateCheckbox("hideResourceTooltip", L["Hide_Resource_Tooltip"], BetterBlizzFrames, nil, BBF.HideClassResourceTooltip)
    hideResourceTooltip:SetPoint("TOPLEFT", hidePlayerPower, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideResourceTooltip, L["Hide_Resource_Tooltip"], L["Tooltip_Hide_Resource_Tooltip_Desc"])

    local hideManaFeedback = CreateCheckbox("hideManaFeedback", L["Hide_Mana_Feedback"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideManaFeedback:SetPoint("TOPLEFT", hideResourceTooltip, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideManaFeedback, L["Hide_Mana_Feedback"], L["Tooltip_Hide_Mana_Feedback_Desc"])

    local hidePlayerRestAnimation = CreateCheckbox("hidePlayerRestAnimation", L["Hide_Zzz_Rest_Animation"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerRestAnimation:SetPoint("TOPLEFT", hideManaFeedback, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerRestAnimation, L["Tooltip_Hide_Zzz_Rest"])

    local hidePlayerCornerIcon = CreateCheckbox("hidePlayerCornerIcon", L["Hide_Corner_Icon"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerCornerIcon:SetPoint("TOPLEFT", hidePlayerRestAnimation, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerCornerIcon, L["Tooltip_Hide_Corner_Icon"] .. " |A:UI-HUD-UnitFrame-Player-PortraitOn-CornerEmbellishment:22:22|a")

    local hidePlayerHealthLossAnim = CreateCheckbox("hidePlayerHealthLossAnim", L["Hide_Health_Loss_FX"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerHealthLossAnim:SetPoint("LEFT", hidePlayerCornerIcon.text, "RIGHT", 0, 0)
    CreateTooltipTwo(hidePlayerHealthLossAnim, L["Tooltip_Hide_Health_Loss_FX"], L["Tooltip_Hide_Health_Loss_FX_Desc"])

    local hidePlayerRestGlow = CreateCheckbox("hidePlayerRestGlow", L["Hide_Rest_Glow"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerRestGlow:SetPoint("TOPLEFT", hidePlayerCornerIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerRestGlow, L["Tooltip_Hide_Rest_Glow"] .. " |A:UI-HUD-UnitFrame-Player-PortraitOn-Status:30:80|a")

    local hideFullPower = CreateCheckbox("hideFullPower", L["Hide_Full_Mana_FX"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideFullPower:SetPoint("LEFT", hidePlayerRestGlow.text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideFullPower, L["Tooltip_Hide_Full_Mana_FX"] .. " |A:FullAlert-FrameGlow:27:51|a", L["Tooltip_Hide_Full_Mana_FX_Desc"])

    local hideCombatIcon = CreateCheckbox("hideCombatIcon", L["Hide_Combat_Icon"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideCombatIcon:SetPoint("TOPLEFT", hidePlayerRestGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideCombatIcon, L["Tooltip_Hide_Combat_Icon"] .. " |A:UI-HUD-UnitFrame-Player-CombatIcon:22:22|a")

    local hideHitIndicator = CreateCheckbox("hideHitIndicator", L["Hide_Hit_Indicator"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideHitIndicator:SetPoint("LEFT", hideCombatIcon.text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideHitIndicator, L["Hide_Hit_Indicator"], L["Tooltip_Hide_Hit_Indicator_Desc"])

    local hideGroupIndicator = CreateCheckbox("hideGroupIndicator", L["Hide_Group_Indicator"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideGroupIndicator:SetPoint("TOPLEFT", hideCombatIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideGroupIndicator, L["Tooltip_Hide_Group_Indicator"])

    local hideTotemFrame = CreateCheckbox("hideTotemFrame", L["Hide_Totem_Frame"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideTotemFrame:SetPoint("LEFT", hideGroupIndicator.text, "RIGHT", 0, 0)
    CreateTooltip(hideTotemFrame, L["Tooltip_Hide_Totem_Frame"])

    local hidePlayerLeaderIcon = CreateCheckbox("hidePlayerLeaderIcon", L["Hide_Leader_Icon"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerLeaderIcon:SetPoint("TOPLEFT", hideGroupIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerLeaderIcon, L["Tooltip_Hide_Leader_Icon"] .. " |A:UI-HUD-UnitFrame-Player-Group-LeaderIcon:22:22|a")

    local hidePlayerGuideIcon = CreateCheckbox("hidePlayerGuideIcon", L["Hide_Guide_Icon"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerGuideIcon:SetPoint("LEFT", hidePlayerLeaderIcon.text, "RIGHT", 0, 0)
    CreateTooltip(hidePlayerGuideIcon, L["Tooltip_Hide_Guide_Icon"] .. " |A:UI-HUD-UnitFrame-Player-Group-GuideIcon:22:22|a")

    local hidePlayerRoleIcon = CreateCheckbox("hidePlayerRoleIcon", L["Hide_Role_Icon"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerRoleIcon:SetPoint("TOPLEFT", hidePlayerLeaderIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerRoleIcon, L["Tooltip_Hide_Role_Icon"] .. " |A:roleicon-tiny-dps:22:22|a")

    local hidePvpTimerText = CreateCheckbox("hidePvpTimerText", L["Hide_PvP_Timer"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePvpTimerText:SetPoint("LEFT", hidePlayerRoleIcon.text, "RIGHT", 0, 0)
    CreateTooltipTwo(hidePvpTimerText, L["Hide_PvP_Timer"], L["Tooltip_Hide_PvP_Timer_Desc"])





    local petFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    petFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, -455)
    petFrameText:SetText(L["Pet_Frame"])
    petFrameText:SetFont(fontLarge, 16)
    petFrameText:SetTextColor(1,1,1)
    local petFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    petFrameIcon:SetAtlas("newplayerchat-chaticon-newcomer")
    petFrameIcon:SetSize(21, 21)
    petFrameIcon:SetPoint("RIGHT", petFrameText, "LEFT", -2, 0)

    local hidePetFrame = CreateCheckbox("hidePetFrame", L["Hide_Pet_Frame"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePetFrame:SetPoint("TOPLEFT", petFrameText, "BOTTOMLEFT", -24, pixelsOnFirstBox)
    CreateTooltipTwo(hidePetFrame, L["Hide_Pet_Frame"], L["Tooltip_Hide_Pet_Frame_Desc"])

    local petCastbar = CreateCheckbox("petCastbar", L["Pet_Castbar"], BetterBlizzFrames, nil, BBF.UpdatePetCastbar)
    petCastbar:SetPoint("TOPLEFT", hidePetFrame, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(petCastbar, L["Tooltip_Pet_Castbar"])

    local hidePetName = CreateCheckbox("hidePetName", L["Hide_Pet_Name"], BetterBlizzFrames)
    hidePetName:SetPoint("TOPLEFT", petCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hidePetName:HookScript("OnClick", function (self)
        BBF.AllNameChanges()
    end)
    CreateTooltipTwo(hidePetName, L["Hide_Pet_Name"], L["Tooltip_Hide_Pet_Name_Desc"])

    local hidePetAuraTooltip = CreateCheckbox("hidePetAuraTooltip", L["Hide_Pet_Aura_Tooltip"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePetAuraTooltip:SetPoint("LEFT", hidePetName.text, "RIGHT", 0, 0)
    CreateTooltipTwo(hidePetAuraTooltip, L["Hide_Pet_Aura_Tooltip"], L["Tooltip_Hide_Pet_Aura_Tooltip_Desc"])

    local colorPetAfterOwner = CreateCheckbox("colorPetAfterOwner", L["Color_Pet_After_Player_Class"], BetterBlizzFrames)
    colorPetAfterOwner:SetPoint("TOPLEFT", hidePetName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    colorPetAfterOwner:HookScript("OnClick", function (self)
        BBF.UpdateFrames()
    end)

    local hidePetText = CreateCheckbox("hidePetText", L["Hide_Pet_Statusbar_Text"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePetText:SetPoint("TOPLEFT", colorPetAfterOwner, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hidePetText, L["Hide_Pet_Statusbar_Text"], L["Tooltip_Hide_Pet_Statusbar_Text_Desc"])

    local hidePetHitIndicator = CreateCheckbox("hidePetHitIndicator", L["Hide_Pet_Hit_Indicator"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePetHitIndicator:SetPoint("TOPLEFT", hidePetText, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hidePetHitIndicator, L["Hide_Pet_Hit_Indicator"], L["Tooltip_Hide_Pet_Hit_Indicator_Desc"])

    local partyFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    partyFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -423)
    partyFrameText:SetText(L["Party_Frame"])
    partyFrameText:SetFont(fontLarge, 16)
    partyFrameText:SetTextColor(1,1,1)
    local partyFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    partyFrameIcon:SetAtlas("groupfinder-icon-friend")
    partyFrameIcon:SetSize(25, 25)
    partyFrameIcon:SetPoint("RIGHT", partyFrameText, "LEFT", -4, -1)
    local partyFrameIcon2 = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    partyFrameIcon2:SetAtlas("groupfinder-icon-friend")
    partyFrameIcon2:SetSize(20, 20)
    partyFrameIcon2:SetPoint("RIGHT", partyFrameText, "LEFT", 0, 4)

    local showPartyCastbar = CreateCheckbox("showPartyCastbar", L["Party_Castbars"], BetterBlizzFrames, nil, BBF.UpdateCastbars)
    showPartyCastbar:SetPoint("TOPLEFT", partyFrameText, "BOTTOMLEFT", -24, pixelsOnFirstBox)
    showPartyCastbar:HookScript("OnClick", function(self)
        --BBF.AbsorbCaller()
    end)
    CreateTooltip(showPartyCastbar, L["Tooltip_Party_Castbars_Desc"])

    local hidePartyRoles = CreateCheckbox("hidePartyRoles", L["Hide_Role_Icons"], BetterBlizzFrames)
    hidePartyRoles:SetPoint("LEFT", showPartyCastbar.text, "RIGHT", 0, 0)
    hidePartyRoles:HookScript("OnClick", function()
        BBF.PartyNameChange()
    end)
    CreateTooltip(hidePartyRoles, L["Tooltip_Hide_Party_Role_Icons"])

--[=[
    local sortGroup = CreateCheckbox("sortGroup", L["Sort_Group"], BetterBlizzFrames, nil, BBF.SortGroup)
    sortGroup:SetPoint("TOPLEFT", showPartyCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(sortGroup, L["Tooltip_Sort_Group"])

    local sortGroupPlayerTop = CreateCheckbox("sortGroupPlayerTop", L["Player_On_Top"], BetterBlizzFrames, nil, BBF.SortGroup)
    sortGroupPlayerTop:SetPoint("LEFT", sortGroup.text, "RIGHT", 0, 0)

    local sortGroupPlayerBottom = CreateCheckbox("sortGroupPlayerBottom", L["Player_On_Bottom"], BetterBlizzFrames, nil, BBF.SortGroup)
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


    local hidePartyFramesInArena = CreateCheckbox("hidePartyFramesInArena", L["Hide_Party_in_Arena"], BetterBlizzFrames, nil, BBF.HidePartyInArena)
    hidePartyFramesInArena:SetPoint("TOPLEFT", showPartyCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePartyFramesInArena, L["Tooltip_Hide_Party_in_Arena_GEX"])

    local raidFramePixelBorder = CreateCheckbox("raidFramePixelBorder", L["Pixel_Border"], BetterBlizzFrames)
    raidFramePixelBorder:SetPoint("LEFT", hidePartyFramesInArena.text, "RIGHT", 0, 0)
    raidFramePixelBorder:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)
    raidFramePixelBorder:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not BetterBlizzFramesDB.raidFramePixelBorderSize then
                BetterBlizzFramesDB.raidFramePixelBorderSize = 1.5
            else
                BetterBlizzFramesDB.raidFramePixelBorderSize = nil
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    CreateTooltipTwo(raidFramePixelBorder, L["Tooltip_Pixel_Border_RaidFrames_Title"], L["Tooltip_Pixel_Border_RaidFrames_Desc"])

    local hidePartyNames = CreateCheckbox("hidePartyNames", L["Hide_Names"], BetterBlizzFrames)
    hidePartyNames:SetPoint("TOPLEFT", hidePartyFramesInArena, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hidePartyNames:HookScript("OnClick", function(self)
        BBF.AllNameChanges()
    end)

    local hidePartyAggroHighlight = CreateCheckbox("hidePartyAggroHighlight", L["Hide_Aggro_Highlight"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePartyAggroHighlight:SetPoint("LEFT", hidePartyNames.text, "RIGHT", 0, 0)
    CreateTooltip(hidePartyAggroHighlight, L["Tooltip_Hide_Party_Aggro_Highlight"])

    -- local hidePartyMaxHpReduction = CreateCheckbox("hidePartyMaxHpReduction", "Hide Reduced HP", BetterBlizzFrames, nil, BBF.HideFrames)
    -- hidePartyMaxHpReduction:SetPoint("LEFT", hidePartyRoles.text, "RIGHT", 0, 0)
    -- CreateTooltipTwo(hidePartyMaxHpReduction, L["Hide_Reduced_HP"], L["Tooltip_Hide_Reduced_HP_Party"])

    local hidePartyFrameTitle = CreateCheckbox("hidePartyFrameTitle", L["Hide_CompactPartyFrame_Title"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePartyFrameTitle:SetPoint("TOPLEFT", hidePartyNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePartyFrameTitle, L["Tooltip_Hide_CompactPartyFrame_Title"])

    local hideCompactUnitFrameBackground = CreateCheckbox("hideCompactUnitFrameBackground", L["Hide_Bg"], BetterBlizzFrames, nil, BBF.HideCompactUnitFrameBackgrounds)
    hideCompactUnitFrameBackground:SetPoint("LEFT", hidePartyFrameTitle.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideCompactUnitFrameBackground, L["Hide_Compact_Frame_Backgrounds"], L["Tooltip_Hide_Compact_Frame_Backgrounds"])

    local hideRaidFrameManager = CreateCheckbox("hideRaidFrameManager", L["Hide_RaidFrameManager"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideRaidFrameManager:SetPoint("TOPLEFT", hidePartyFrameTitle, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideRaidFrameManager, L["Tooltip_Hide_RaidFrameManager"])

    local classColorPartyNames = CreateCheckbox("classColorPartyNames", L["Color_Names"], BetterBlizzFrames, nil, BBF.AllNameChanges)
    classColorPartyNames:SetPoint("LEFT", hideRaidFrameManager.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(classColorPartyNames, L["Class_Color_Names"], L["Tooltip_Class_Color_Names_Party_Raid"])

    local hideRaidFrameContainerBorder = CreateCheckbox("hideRaidFrameContainerBorder", L["Hide_Container_Border"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideRaidFrameContainerBorder:SetPoint("TOPLEFT", hideRaidFrameManager, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideRaidFrameContainerBorder, L["Hide_CompactRaidFrame_Container_Border"], L["Tooltip_Hide_Container_Border_Desc"])

    local hidePartyDispelOverlay = CreateCheckbox("hidePartyDispelOverlay", L["Hide_Dispel_Overlay"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePartyDispelOverlay:SetPoint("LEFT", hideRaidFrameContainerBorder.Text, "RIGHT", 0, 0)
    hidePartyDispelOverlay:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if IsControlKeyDown() then
                if not BetterBlizzFramesDB.hidePartyDispelOverlayHideIcons then
                    BetterBlizzFramesDB.hidePartyDispelOverlayHideIcons = true
                else
                    BetterBlizzFramesDB.hidePartyDispelOverlayHideIcons = nil
                end
            elseif IsShiftKeyDown() then
                if not BetterBlizzFramesDB.hidePartyDispelOverlayKeepGradient then
                    BetterBlizzFramesDB.hidePartyDispelOverlayKeepGradient = true
                else
                    BetterBlizzFramesDB.hidePartyDispelOverlayKeepGradient = nil
                end
            else
                if not BetterBlizzFramesDB.hidePartyDispelOverlayKeepBorder then
                    BetterBlizzFramesDB.hidePartyDispelOverlayKeepBorder = true
                else
                    BetterBlizzFramesDB.hidePartyDispelOverlayKeepBorder = nil
                end
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
            BBF.HideFrames()
        end
    end)
    CreateTooltipTwo(hidePartyDispelOverlay, L["Hide_Dispel_Overlay"], L["Tooltip_Hide_Dispel_Overlay"])

    local hidePartyRangeIcon = CreateCheckbox("hidePartyRangeIcon", L["Hide_Range_Icon"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePartyRangeIcon:SetPoint("TOPLEFT", hidePartyDispelOverlay, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hidePartyRangeIcon, L["Hide_Range_Icon"], L["Tooltip_Hide_Range_Icon"])

    local newRaidFrameRoleIcons = CreateCheckbox("newRaidFrameRoleIcons", L["New_Role_Icons"], BetterBlizzFrames)
    newRaidFrameRoleIcons:SetPoint("TOPLEFT", hidePartyRangeIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(newRaidFrameRoleIcons, L["New_Role_Icons"], L["Tooltip_New_Role_Icons_Desc"])
    newRaidFrameRoleIcons:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local betterTargetHighlight = CreateCheckbox("betterTargetHighlight", L["Better_Target_Highlight"], BetterBlizzFrames)
    betterTargetHighlight:SetPoint("TOPLEFT", newRaidFrameRoleIcons, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(betterTargetHighlight, L["Better_Target_Highlight"], L["Tooltip_Better_Target_Highlight"])
    betterTargetHighlight:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        else
            BBF.BetterTargetHighlight()
        end
    end)

    local highlightAtlasOptions = BBF.highlightAtlasOptions

    betterTargetHighlight.extendedSettings = CreateFrame("Frame", nil, BetterBlizzFrames, "DefaultPanelFlatTemplate")
    betterTargetHighlight.extendedSettings:SetSize(250, 195)
    betterTargetHighlight.extendedSettings:SetPoint("BOTTOMRIGHT", betterTargetHighlight, "BOTTOMLEFT", -5, -10)
    betterTargetHighlight.extendedSettings:SetFrameStrata("DIALOG")
    betterTargetHighlight.extendedSettings:SetIgnoreParentAlpha(true)
    betterTargetHighlight.extendedSettings:Hide()
    betterTargetHighlight.extendedSettings:SetTitle(L["Better_Target_Highlight_Settings"])
    betterTargetHighlight.extendedSettings:EnableMouse(true)
    betterTargetHighlight.extendedSettings:SetMovable(true)
    betterTargetHighlight.extendedSettings:SetClampedToScreen(true)
    betterTargetHighlight.extendedSettings:RegisterForDrag("LeftButton")
    betterTargetHighlight.extendedSettings:SetScript("OnDragStart", function(self) self:StartMoving() end)
    betterTargetHighlight.extendedSettings:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    betterTargetHighlight.closeButton = CreateFrame("Button", nil, betterTargetHighlight.extendedSettings, "UIPanelCloseButton")
    betterTargetHighlight.closeButton:SetPoint("TOPRIGHT", betterTargetHighlight.extendedSettings, "TOPRIGHT", 0, 0)
    betterTargetHighlight.closeButton:SetScript("OnClick", function()
        betterTargetHighlight.extendedSettings:Hide()
        BetterBlizzFrames:SetAlpha(1)
    end)

    betterTargetHighlight.bg = betterTargetHighlight.extendedSettings:CreateTexture(nil, "BACKGROUND")
    betterTargetHighlight.bg:SetPoint("TOPLEFT", betterTargetHighlight.extendedSettings, "TOPLEFT", 7, -3)
    betterTargetHighlight.bg:SetPoint("BOTTOMRIGHT", betterTargetHighlight.extendedSettings, "BOTTOMRIGHT", -3, 3)
    betterTargetHighlight.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

    betterTargetHighlight:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            betterTargetHighlight.extendedSettings:SetShown(not betterTargetHighlight.extendedSettings:IsShown())
            BetterBlizzFrames:SetAlpha(betterTargetHighlight.extendedSettings:IsShown() and 0.5 or 1)
        end
    end)

    local thExt = betterTargetHighlight.extendedSettings

    local function GetAtlasDisplayName(atlasKey)
        for _, opt in ipairs(highlightAtlasOptions) do
            if opt.atlas == atlasKey then return opt.name end
        end
        return "Default"
    end

    local thDropdown = CreateFrame("DropdownButton", nil, thExt, "WowStyle1DropdownTemplate")
    thDropdown:SetPoint("TOPLEFT", thExt, "TOPLEFT", 15, -45)
    thDropdown:SetWidth(200)
    thDropdown:SetDefaultText(GetAtlasDisplayName(BetterBlizzFramesDB.betterTargetHighlightAtlas or "RaidFrame-TargetFrame"))
    thDropdown.Background:SetVertexColor(0.9, 0.9, 0.9)
    thDropdown.Arrow:SetVertexColor(0.9, 0.9, 0.9)

    local thDropdownLabel = thExt:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall2")
    thDropdownLabel:SetPoint("BOTTOM", thDropdown, "TOP", 0, 2)
    thDropdownLabel:SetText(L["Highlight_Texture"])
    thDropdownLabel:SetFont(fontSmall, 13)

    local function ThDropdownGenerator(owner, rootDescription)
        local itemHeight = 20
        local maxScrollExtent = math.min(#highlightAtlasOptions, 25) * itemHeight
        rootDescription:SetScrollMode(maxScrollExtent)

        for _, opt in ipairs(highlightAtlasOptions) do
            local button = rootDescription:CreateButton(opt.name, function()
                BetterBlizzFramesDB.betterTargetHighlightAtlas = opt.atlas
                thDropdown:SetDefaultText(opt.name)
                BBF.UpdateTargetHighlightSettings()
            end)

            button:SetOnEnter(function()
                BBF.PreviewTargetHighlightAtlas(opt.atlas)
            end)
        end
    end

    hooksecurefunc(thDropdown, "OnMenuClosed", function()
        thDropdown:SetDefaultText(GetAtlasDisplayName(BetterBlizzFramesDB.betterTargetHighlightAtlas or "RaidFrame-TargetFrame"))
        BBF.RevertTargetHighlightPreview()
    end)

    thDropdown:SetupMenu(ThDropdownGenerator)

    thExt.highlightColor = CreateColorBox(thExt, "betterTargetHighlightColor", L["Color"], function()
        BBF.UpdateTargetHighlightSettings()
    end)
    thExt.highlightColor:SetPoint("TOPLEFT", thDropdown, "BOTTOMLEFT", 0, -5)
    thExt.highlightColor:SetScale(1.1)

    local thDesaturate = CreateCheckbox("betterTargetHighlightDesaturate", L["Desaturate"], thExt, nil, function()
        BBF.UpdateTargetHighlightSettings()
    end)
    thDesaturate:SetPoint("LEFT", thExt.highlightColor.text, "RIGHT", 2, 0)
    CreateTooltipTwo(thDesaturate, L["Desaturate_Highlight"], L["Tooltip_Desaturate_Highlight"])

    local thTip = thExt:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall2")
    thTip:SetPoint("TOPLEFT", thExt.highlightColor, "BOTTOMLEFT", 0, -15)
    thTip:SetWidth(220)
    thTip:SetJustifyH("LEFT")
    thTip:SetText(L["Tip_Hide_Aggro_Highlight"])
    thTip:SetTextColor(0.6, 0.6, 0.6)

    local thHideAggro = CreateCheckbox("hidePartyAggroHighlight", L["Hide_Aggro_Highlight"], thExt, nil, BBF.HideFrames)
    thHideAggro:SetPoint("TOPLEFT", thTip, "BOTTOMLEFT", 0, -4)
    CreateTooltip(thHideAggro, L["Tooltip_Hide_Party_Aggro_Highlight"])
    thHideAggro:HookScript("OnClick", function(self)
        hidePartyAggroHighlight:SetChecked(self:GetChecked())
    end)
    hidePartyAggroHighlight:HookScript("OnClick", function(self)
        thHideAggro:SetChecked(self:GetChecked())
    end)

    local changePartyFrameRangeAlpha = CreateCheckbox("changePartyFrameRangeAlpha", "", BetterBlizzFrames)

    local partyFrameRangeAlpha = CreateSlider(changePartyFrameRangeAlpha, L["Party_Frame_Range_Alpha"], 0, 1, 0.01, "partyFrameRangeAlpha", nil, 120)
    partyFrameRangeAlpha:SetPoint("TOPLEFT", hideRaidFrameContainerBorder, "BOTTOMLEFT", 1, -9)
    CreateTooltipTwo(changePartyFrameRangeAlpha, L["Party_Frame_Range_Alpha"], L["Tooltip_Party_Frame_Range_Alpha"])

    changePartyFrameRangeAlpha:SetPoint("RIGHT", partyFrameRangeAlpha, "LEFT", 0, 0)
    CreateTooltipTwo(changePartyFrameRangeAlpha, L["Change_Party_Frame_Alpha"], L["Tooltip_Change_Party_Frame_Alpha"])
    changePartyFrameRangeAlpha:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBF.HookAndUpdatePartyFrameRangeAlpha(true)
            EnableElement(partyFrameRangeAlpha)
        else
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
            DisableElement(partyFrameRangeAlpha)
        end
    end)
    changePartyFrameRangeAlpha:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            BetterBlizzFramesDB.partyFrameRangeAlphaSolidBackground = not BetterBlizzFramesDB.partyFrameRangeAlphaSolidBackground
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)


    local targetFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 250, -197)
    targetFrameText:SetText(L["Target_Frame"])
    targetFrameText:SetFont(fontLarge, 16)
    targetFrameText:SetTextColor(1,1,1)
    local targetFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    targetFrameIcon:SetAtlas("groupfinder-icon-friend")
    targetFrameIcon:SetSize(28, 28)
    targetFrameIcon:SetPoint("RIGHT", targetFrameText, "LEFT", -0.5, 0)
    targetFrameIcon:SetDesaturated(1)
    targetFrameIcon:SetVertexColor(1, 0, 0)

    local targetFrameClickthrough = CreateCheckbox("targetFrameClickthrough", L["Clickthrough"], BetterBlizzFrames, nil, BBF.ClickthroughFrames)
    targetFrameClickthrough:SetPoint("TOPLEFT", targetFrameText, "BOTTOMLEFT", -24, pixelsOnFirstBox)
    CreateTooltip(targetFrameClickthrough, L["Tooltip_Target_Clickthrough"])
    targetFrameClickthrough:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local hideTargetName = CreateCheckbox("hideTargetName", L["Hide_Names"], BetterBlizzFrames, nil, BBF.UpdateNameSettings)
    hideTargetName:SetPoint("TOPLEFT", targetFrameClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetName, L["Tooltip_Hide_Target_Name"])
    hideTargetName:HookScript("OnClick", function(self)
        -- if self:GetChecked() then
        --     TargetFrame.name:SetAlpha(0)
        --     if TargetFrame.bbfName then
        --         TargetFrame.bbfName:SetAlpha(0)
        --     end
        -- else
        --     TargetFrame.name:SetAlpha(0)
        --     if TargetFrame.bbfName then
        --         TargetFrame.bbfName:SetAlpha(1)
        --     else
        --         TargetFrame.name:SetAlpha(1)
        --     end
        -- end
        BBF.AllNameChanges()
    end)

    -- local hideTargetMaxHpReduction = CreateCheckbox("hideTargetMaxHpReduction", "Hide Reduced HP", BetterBlizzFrames, nil, BBF.HideFrames)
    -- hideTargetMaxHpReduction:SetPoint("LEFT", hideTargetName.text, "RIGHT", 0, 0)
    -- CreateTooltipTwo(hideTargetMaxHpReduction, L["Hide_Reduced_HP"], L["Tooltip_Hide_Reduced_HP_Target"])

    local hideTargetLeaderIcon = CreateCheckbox("hideTargetLeaderIcon", L["Hide_Leader_Icon"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideTargetLeaderIcon:SetPoint("TOPLEFT", hideTargetName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetLeaderIcon, L["Tooltip_Hide_Target_Leader_Icon"] .. " |A:UI-HUD-UnitFrame-Player-Group-LeaderIcon:22:22|a")

    local classColorTargetReputationTexture = CreateCheckbox("classColorTargetReputationTexture", L["Reputation_Class_Color"], BetterBlizzFrames)
    classColorTargetReputationTexture:SetPoint("TOPLEFT", hideTargetLeaderIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classColorTargetReputationTexture, L["Tooltip_Target_Reputation_Class_Color"] .. " |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")
    classColorTargetReputationTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBF.ClassColorReputation(TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, "target")
        else
            BBF.ResetClassColorReputation(TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, "target")
        end
    end)

    local hideTargetReputationColor = CreateCheckbox("hideTargetReputationColor", L["Hide_Reputation_Color"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideTargetReputationColor:SetPoint("TOPLEFT", classColorTargetReputationTexture, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetReputationColor, L["Tooltip_Hide_Target_Reputation_Color"] .. " |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")






    local targetToTFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetToTFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 250, -308)
    targetToTFrameText:SetText(L["Target_of_Target"])
    targetToTFrameText:SetFont(fontLarge, 16)
    targetToTFrameText:SetTextColor(1,1,1)
    local targetToTFrameIcon = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    targetToTFrameIcon:SetAtlas("groupfinder-icon-friend")
    targetToTFrameIcon:SetSize(28, 28)
    targetToTFrameIcon:SetPoint("RIGHT", targetToTFrameText, "LEFT", -0.5, 0)
    targetToTFrameIcon:SetDesaturated(1)
    targetToTFrameIcon:SetVertexColor(1, 0, 0)
    local targetToTFrameIcon2 = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    targetToTFrameIcon2:SetAtlas("TargetCrosshairs")
    targetToTFrameIcon2:SetSize(28, 28)
    targetToTFrameIcon2:SetPoint("TOPLEFT", targetToTFrameIcon, "TOPLEFT", 13.5, -13)

    local hideTargetToT = CreateCheckbox("hideTargetToT", L["Hide_Frame"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideTargetToT:SetPoint("TOPLEFT", targetToTFrameText, "BOTTOMLEFT", -24, pixelsOnFirstBox)
    CreateTooltipTwo(hideTargetToT, L["Tooltip_Hide_ToT_Frame"])

    local hideTargetToTName = CreateCheckbox("hideTargetToTName", L["Hide_Names"], BetterBlizzFrames)
    hideTargetToTName:SetPoint("LEFT", hideTargetToT.Text, "RIGHT", 0, 0)
    hideTargetToTName:HookScript("OnClick", function(self)
        if self:GetChecked() then
            TargetFrame.totFrame.Name:SetAlpha(0)
            if TargetFrame.totFrame.bbfName then
                TargetFrame.totFrame.bbfName:SetAlpha(0)
            end
        else
            TargetFrame.totFrame.Name:SetAlpha(0)
            if TargetFrame.totFrame.bbfName then
                TargetFrame.totFrame.bbfName:SetAlpha(1)
            end
        end
    end)
    CreateTooltipTwo(hideTargetToTName, L["Tooltip_Hide_ToT_Name"])

    local hideTargetToTDebuffs = CreateCheckbox("hideTargetToTDebuffs", L["Hide_ToT_Debuffs"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideTargetToTDebuffs:SetPoint("TOPLEFT", hideTargetToT, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetToTDebuffs, L["Tooltip_Hide_ToT_Debuffs"])

    local targetToTScale = CreateSlider(BetterBlizzFrames, L["Size"], 0.6, 2.5, 0.01, "targetToTScale", nil, 120)
    targetToTScale:SetPoint("TOPLEFT", targetToTFrameText, "BOTTOMLEFT", -20, -50)
    CreateTooltip(targetToTScale, L["Tooltip_ToT_Size"])

    BBF.targetToTXPos = CreateSlider(BetterBlizzFrames, L["X_Offset"], -100, 100, 1, "targetToTXPos", "X", 120)
    BBF.targetToTXPos:SetPoint("TOP", targetToTScale, "BOTTOM", 0, -15)
    CreateTooltip(BBF.targetToTXPos, L["Tooltip_ToT_X_Offset"])

    local targetToTYPos = CreateSlider(BetterBlizzFrames, L["Y_Offset"], -100, 100, 1, "targetToTYPos", "Y", 120)
    targetToTYPos:SetPoint("TOP", BBF.targetToTXPos, "BOTTOM", 0, -15)
    CreateTooltip(targetToTYPos, L["Tooltip_ToT_Y_Offset"])




    local chatFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    chatFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 250, -467)
    chatFrameText:SetText(L["Chat_Frame"])
    chatFrameText:SetFont(fontLarge, 16)
    chatFrameText:SetTextColor(1,1,1)
    local chatFrameIcon = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    chatFrameIcon:SetAtlas("transmog-icon-chat")
    chatFrameIcon:SetSize(18, 16)
    chatFrameIcon:SetPoint("RIGHT", chatFrameText, "LEFT", -4, 0)

    local hideChatButtons = CreateCheckbox("hideChatButtons", L["Hide_Chat_Buttons"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideChatButtons:SetPoint("TOPLEFT", chatFrameText, "BOTTOMLEFT", -24, pixelsOnFirstBox)
    CreateTooltip(hideChatButtons, L["Tooltip_Hide_Chat_Buttons"])

    chatFrameText.hideChatBackground = CreateCheckbox("hideChatBackground", L["Hide_Chat_Background"], hideChatButtons, nil, BBF.HideFrames)
    chatFrameText.hideChatBackground:SetPoint("LEFT", hideChatButtons.text, "RIGHT", 0, 0)
    CreateTooltip(chatFrameText.hideChatBackground, L["Tooltip_Hide_Chat_Background"])

    hideChatButtons:HookScript("OnClick", function(self)
        if self:GetChecked() then
            EnableElement(chatFrameText.hideChatBackground)
        else
            DisableElement(chatFrameText.hideChatBackground)
        end
    end)

    local chatFrameFilters = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    chatFrameFilters:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 232, -507)
    chatFrameFilters:SetText(L["Filters"])
    chatFrameFilters:SetFont(fontLarge, 12)
    chatFrameFilters:SetTextColor(1,1,1)

    local filterGladiusSpam = CreateCheckbox("filterGladiusSpam", L["Gladius_Spam"], BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterGladiusSpam:SetPoint("TOPLEFT", hideChatButtons, "BOTTOMLEFT", 0, -10)
    CreateTooltip(filterGladiusSpam, L["Tooltip_Filter_Gladius_Spam"])

    local filterNpcArenaSpam = CreateCheckbox("filterNpcArenaSpam", L["Arena_Npc_Talk"], BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterNpcArenaSpam:SetPoint("LEFT", filterGladiusSpam.text, "RIGHT", 0, 0)
    CreateTooltip(filterNpcArenaSpam, L["Tooltip_Filter_Arena_Npc_Talk"])

    local filterTalentSpam = CreateCheckbox("filterTalentSpam", L["Talent_Spam"], BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterTalentSpam:SetPoint("TOPLEFT", filterGladiusSpam, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(filterTalentSpam, L["Tooltip_Filter_Talent_Spam"])

    local filterEmoteSpam = CreateCheckbox("filterEmoteSpam", L["Emote_Spam"], BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterEmoteSpam:SetPoint("TOPLEFT", filterTalentSpam, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(filterEmoteSpam, L["Tooltip_Filter_Emote_Spam"])

    local filterSystemMessages = CreateCheckbox("filterSystemMessages", L["System_Messages"], BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterSystemMessages:SetPoint("TOPLEFT", filterNpcArenaSpam, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(filterSystemMessages, L["Tooltip_Filter_System_Messages"])

    local filterMiscInfo = CreateCheckbox("filterMiscInfo", L["Misc_Info"], BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterMiscInfo:SetPoint("TOPLEFT", filterSystemMessages, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(filterMiscInfo, L["Tooltip_Filter_Misc_Info"])

    local arenaNamesText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arenaNamesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, -127)
    arenaNamesText:SetText(L["Arena_Names"])
    arenaNamesText:SetFont(fontLarge, 16)
    arenaNamesText:SetTextColor(1,1,1)
    CreateTooltip(arenaNamesText, L["Change_player_names_into_spec"], "ANCHOR_LEFT")
    local arenaNamesIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    arenaNamesIcon:SetAtlas("questlog-questtypeicon-pvp")
    arenaNamesIcon:SetSize(19, 22)
    arenaNamesIcon:SetPoint("RIGHT", arenaNamesText, "LEFT", -3.5, 0)

    local targetAndFocusArenaNames = CreateCheckbox("targetAndFocusArenaNames", L["Target_And_Focus_Arena_Names"], BetterBlizzFrames)
    targetAndFocusArenaNames:SetPoint("TOPLEFT", arenaNamesText, "BOTTOMLEFT", -24, pixelsOnFirstBox)
    CreateTooltipTwo(targetAndFocusArenaNames, L["Arena_Names"], L["Tooltip_Arena_Names_Target_Focus_Desc"], nil, "ANCHOR_LEFT")

    local partyArenaNames = CreateCheckbox("partyArenaNames", L["Party"], BetterBlizzFrames)
    partyArenaNames:SetPoint("LEFT", targetAndFocusArenaNames.text, "RIGHT", 0, 0)
    CreateTooltipTwo(partyArenaNames, L["Arena_Names"], L["Tooltip_Arena_Names_Desc"], nil, "ANCHOR_LEFT")

    local showSpecName = CreateCheckbox("showSpecName", L["Show_Spec_Name"], BetterBlizzFrames)
    showSpecName:SetPoint("TOPLEFT", targetAndFocusArenaNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showSpecName, L["Show_Spec_Name"], string.format(L["Tooltip_Show_Spec_Name_Desc"], (BetterBlizzFramesDB.targetAndFocusArenaNamePartyOverride and L["True"] or L["False"])))
    showSpecName:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if BetterBlizzFramesDB.targetAndFocusArenaNamePartyOverride then
                BetterBlizzFramesDB.targetAndFocusArenaNamePartyOverride = false
            else
                BetterBlizzFramesDB.targetAndFocusArenaNamePartyOverride = true
            end
            local value = (BetterBlizzFramesDB.targetAndFocusArenaNamePartyOverride and L["True"] or L["False"])
            local showSpecNameTip = L["Tooltip_Show_Spec_Name_Tip_Prefix"]..value.."|r"
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(L["Show_Spec_Name"])
            GameTooltip:AddLine(showSpecNameTip, 1, 1, 1, true)
            GameTooltip:Show()
            CreateTooltipTwo(showSpecName, L["Show_Spec_Name"], string.format(L["Tooltip_Show_Spec_Name_Desc"], (BetterBlizzFramesDB.targetAndFocusArenaNamePartyOverride and L["True"] or L["False"])))
            BBF.AllNameChanges()
        end
    end)

    local shortArenaSpecName = CreateCheckbox("shortArenaSpecName", L["Short"], BetterBlizzFrames)
    shortArenaSpecName:SetPoint("LEFT", showSpecName.Text, "RIGHT", 0, 0)
    CreateTooltip(shortArenaSpecName, L["Tooltip_Short_Arena_Spec_Name"], "ANCHOR_LEFT")

    local showArenaID = CreateCheckbox("showArenaID", L["Show_Arena_ID"], BetterBlizzFrames)
    showArenaID:SetPoint("TOPLEFT", showSpecName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showArenaID, L["Tooltip_Show_Arena_ID"])

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
    focusFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, -199)
    focusFrameText:SetText(L["Focus_Frame"])
    focusFrameText:SetFont(fontLarge, 16)
    focusFrameText:SetTextColor(1,1,1)
    local focusFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    focusFrameIcon:SetAtlas("groupfinder-icon-friend")
    focusFrameIcon:SetSize(28, 28)
    focusFrameIcon:SetPoint("RIGHT", focusFrameText, "LEFT", -0.5, 0)
    focusFrameIcon:SetDesaturated(1)
    focusFrameIcon:SetVertexColor(0, 1, 0)

    local focusFrameClickthrough = CreateCheckbox("focusFrameClickthrough", L["Clickthrough"], BetterBlizzFrames, nil, BBF.ClickthroughFrames)
    focusFrameClickthrough:SetPoint("TOPLEFT", focusFrameText, "BOTTOMLEFT", -24, pixelsOnFirstBox)
    CreateTooltip(focusFrameClickthrough, L["Tooltip_Focus_Clickthrough"])
    focusFrameClickthrough:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local hideFocusName = CreateCheckbox("hideFocusName", L["Hide_Names"], BetterBlizzFrames, nil, BBF.UpdateNameSettings)
    hideFocusName:SetPoint("TOPLEFT", focusFrameClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideFocusName, L["Tooltip_Hide_Focus_Name"])
    hideFocusName:HookScript("OnClick", function(self)
        -- if self:GetChecked() then
        --     FocusFrame.name:SetAlpha(0)
        --     if FocusFrame.bbfName then
        --         FocusFrame.bbfName:SetAlpha(0)
        --     end
        -- else
        --     FocusFrame.name:SetAlpha(0)
        --     if FocusFrame.bbfName then
        --         FocusFrame.bbfName:SetAlpha(1)
        --     else
        --         FocusFrame.name:SetAlpha(1)
        --     end
        -- end
        BBF.AllNameChanges()
    end)

    -- local hideFocusMaxHpReduction = CreateCheckbox("hideFocusMaxHpReduction", "Hide Reduced HP", BetterBlizzFrames, nil, BBF.HideFrames)
    -- hideFocusMaxHpReduction:SetPoint("LEFT", hideFocusName.text, "RIGHT", 0, 0)
    -- CreateTooltipTwo(hideFocusMaxHpReduction, L["Hide_Reduced_HP"], L["Tooltip_Hide_Reduced_HP_Focus"])

    local hideFocusLeaderIcon = CreateCheckbox("hideFocusLeaderIcon", L["Hide_Leader_Icon"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideFocusLeaderIcon:SetPoint("TOPLEFT", hideFocusName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideFocusLeaderIcon, L["Tooltip_Hide_Focus_Leader_Icon"] .. " |A:UI-HUD-UnitFrame-Player-Group-LeaderIcon:22:22|a")

    local classColorFocusReputationTexture = CreateCheckbox("classColorFocusReputationTexture", L["Reputation_Class_Color"], BetterBlizzFrames)
    classColorFocusReputationTexture:SetPoint("TOPLEFT", hideFocusLeaderIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classColorFocusReputationTexture, L["Tooltip_Focus_Reputation_Class_Color"] .. " |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")
    classColorFocusReputationTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBF.ClassColorReputation(FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, "focus")
        else
            BBF.ResetClassColorReputation(FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, "focus")
        end
    end)

    local hideFocusReputationColor = CreateCheckbox("hideFocusReputationColor", L["Hide_Reputation_Color"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideFocusReputationColor:SetPoint("TOPLEFT", classColorFocusReputationTexture, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideFocusReputationColor, L["Tooltip_Hide_Focus_Reputation_Color"] .. " |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")







    local focusToTFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    focusToTFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, -307)
    focusToTFrameText:SetText(L["Focus_ToT"])
    focusToTFrameText:SetFont(fontLarge, 16)
    focusToTFrameText:SetTextColor(1,1,1)
    local focusToTFrameIcon = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    focusToTFrameIcon:SetAtlas("groupfinder-icon-friend")
    focusToTFrameIcon:SetSize(28, 28)
    focusToTFrameIcon:SetPoint("RIGHT", focusToTFrameText, "LEFT", -0.5, 0)
    focusToTFrameIcon:SetDesaturated(1)
    focusToTFrameIcon:SetVertexColor(0, 1, 0)
    local focusToTFrameIcon2 = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    focusToTFrameIcon2:SetAtlas("TargetCrosshairs")
    focusToTFrameIcon2:SetSize(28, 28)
    focusToTFrameIcon2:SetPoint("TOPLEFT", focusToTFrameIcon, "TOPLEFT", 13.5, -13)

    local hideFocusToT = CreateCheckbox("hideFocusToT", L["Hide_Frame"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideFocusToT:SetPoint("TOPLEFT", focusToTFrameText, "BOTTOMLEFT", -24, pixelsOnFirstBox)
    CreateTooltipTwo(hideFocusToT, L["Tooltip_Hide_FocusToT_Frame"])

    local hideFocusToTName = CreateCheckbox("hideFocusToTName", L["Hide_Names"], BetterBlizzFrames)
    hideFocusToTName:SetPoint("LEFT", hideFocusToT.Text, "RIGHT", 0, 0)
    hideFocusToTName:HookScript("OnClick", function(self)
        if self:GetChecked() then
            FocusFrame.totFrame.Name:SetAlpha(0)
            if FocusFrame.totFrame.bbfName then
                FocusFrame.totFrame.bbfName:SetAlpha(0)
            end
        else
            FocusFrame.totFrame.Name:SetAlpha(0)
            if FocusFrame.totFrame.bbfName then
                FocusFrame.totFrame.bbfName:SetAlpha(1)
            end
        end
    end)
    CreateTooltipTwo(hideFocusToTName, L["Tooltip_Hide_FocusToT_Name"])

    local hideFocusToTDebuffs = CreateCheckbox("hideFocusToTDebuffs", L["Hide_FocusToT_Debuffs"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideFocusToTDebuffs:SetPoint("TOPLEFT", hideFocusToT, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideFocusToTDebuffs, L["Tooltip_Hide_ToT_Debuffs"])

    local focusToTScale = CreateSlider(BetterBlizzFrames, L["Size"], 0.6, 2.5, 0.01, "focusToTScale", nil, 120)
    focusToTScale:SetPoint("TOPLEFT", focusToTFrameText, "BOTTOMLEFT", -20, -50)
    CreateTooltip(focusToTScale, L["Tooltip_FocusToT_Size"])

    BBF.focusToTXPos = CreateSlider(BetterBlizzFrames, L["X_Offset"], -100, 100, 1, "focusToTXPos", "X", 120)
    BBF.focusToTXPos:SetPoint("TOP", focusToTScale, "BOTTOM", 0, -15)
    CreateTooltip(BBF.focusToTXPos, L["Tooltip_FocusToT_X_Offset"])

    local focusToTYPos = CreateSlider(BetterBlizzFrames, L["Y_Offset"], -100, 100, 1, "focusToTYPos", "Y", 120)
    focusToTYPos:SetPoint("TOP", BBF.focusToTXPos, "BOTTOM", 0, -15)
    CreateTooltip(focusToTYPos, L["Tooltip_FocusToT_Y_Offset"])





    local allFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    allFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 250, 30)
    allFrameText:SetText(L["All_Frames"])
    allFrameText:SetFont(fontLarge, 16)
    allFrameText:SetTextColor(1,1,1)
    local allFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    allFrameIcon:SetAtlas("groupfinder-icon-friend")
    allFrameIcon:SetSize(25, 25)
    allFrameIcon:SetPoint("RIGHT", allFrameText, "LEFT", -2, -1)
    local allFrameIcon2 = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    allFrameIcon2:SetAtlas("groupfinder-icon-friend")
    allFrameIcon2:SetSize(20, 20)
    allFrameIcon2:SetPoint("RIGHT", allFrameText, "LEFT", 2, 4)
    allFrameIcon2:SetDesaturated(1)
    allFrameIcon2:SetVertexColor(0, 1, 0)
    local allFrameIcon3 = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    allFrameIcon3:SetAtlas("groupfinder-icon-friend")
    allFrameIcon3:SetSize(20, 20)
    allFrameIcon3:SetPoint("RIGHT", allFrameText, "LEFT", -10, 4)
    allFrameIcon3:SetDesaturated(1)
    allFrameIcon3:SetVertexColor(1, 0, 0)

    local classicFrames = CreateCheckbox("classicFrames", L["Classic_Frames"], BetterBlizzFrames)
    classicFrames:SetPoint("TOPLEFT", allFrameText, "BOTTOMLEFT", -24, pixelsOnFirstBox)
    CreateTooltipTwo(classicFrames, L["Classic_Frames"], L["Tooltip_Classic_Frames_Desc"])
    classicFrames:HookScript("OnClick", function(self)
        BetterBlizzFramesDB.noPortraitModes = false
        if self:GetChecked() and C_AddOns.IsAddOnLoaded("ClassicFrames") then
            C_AddOns.DisableAddOn("ClassicFrames")
        end
        if self:GetChecked() then
            if not BBF.ClassicReloadWindow then
                local statusText = classicFrames:GetChecked() and "|cff00ff00ON|r" or "|cffff0000OFF|r"
                StaticPopupDialogs["BBF_CLASSIC_RELOAD"] = {
                    text = titleText..string.format(L["Popup_Classic_Frames_Turn"], statusText),
                    button1 = L["Reload_UI"],
                    button2 = L["No"],
                    OnAccept = function()
                        BetterBlizzFramesDB.reopenOptions = true
                        if BBF.ChangesOnReload then
                            for key, value in pairs(BBF.ChangesOnReload) do
                                BetterBlizzFramesDB[key] = value
                                if key == "comboPointLocation" and value ~= nil and not InCombatLockdown() then
                                    C_CVar.SetCVar("comboPointLocation", value)
                                end
                            end
                        end
                        C_AddOns.DisableAddOn("ClassicFrames")
                        ReloadUI()
                    end,
                    OnShow = function(self)
                        local statusText = classicFrames:GetChecked() and "|cff00ff00ON|r" or "|cffff0000OFF|r"
                        self.Text:SetText(titleText..string.format(L["Popup_Classic_Frames_Turn"], statusText))
                        if not self.classicSettings then
                            BBF.ChangesOnReload = {}
                            self.cfTextures = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
                            self.cfTextures:SetSize(26, 26)
                            CreateTooltipTwo(self.cfTextures, L["Use_Classic_Textures"], L["Tooltip_Use_Classic_Textures_Desc"])
                            self.cfTextures.Text:SetText(L["Classic_Health_Mana_Textures"])

                            self.cfCastbars = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
                            self.cfCastbars:SetSize(26, 26)
                            CreateTooltipTwo(self.cfCastbars, L["Use_Classic_Castbars"], L["Tooltip_Use_Classic_Castbars_Desc"])
                            self.cfCastbars.Text:SetText(L["Castbar_Classic"])

                            self.cfComboPoints = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
                            self.cfComboPoints:SetSize(26, 26)
                            CreateTooltipTwo(self.cfComboPoints, L["Use_Classic_Combo_Points"], L["Tooltip_Use_Classic_Combo_Points_Desc"])
                            self.cfComboPoints.Text:SetText(L["Classic_Combo_Points"])

                            local firstClick = BetterBlizzFramesDB.classicFramesClicked == nil
                            BetterBlizzFramesDB.classicFramesClicked = true

                            self.cfCastbars:SetChecked((firstClick and true) or BetterBlizzFramesDB.classicCastbars or false)
                            self.cfComboPoints:SetChecked(C_CVar.GetCVar("comboPointLocation") == "1" and true or false)
                            self.cfTextures:SetChecked(BetterBlizzFramesDB.changeUnitFrameHealthbarTexture or false)

                            self.classicSettings = true
                        end

                        local function CheckBoxes()
                            local castbarsEnabled = self.cfCastbars:GetChecked()
                            if castbarsEnabled then
                                BBF.ChangesOnReload["classicCastbarsParty"] = castbarsEnabled
                                BBF.ChangesOnReload["classicCastbarsPlayer"] = castbarsEnabled
                                BBF.ChangesOnReload["classicCastbarsPlayerBorder"] = castbarsEnabled
                                BBF.ChangesOnReload["classicCastbars"] = castbarsEnabled
                                BBF.ChangesOnReload["classicCastbarsParty"] = castbarsEnabled
                                BBF.ChangesOnReload["targetToTXPos"] = -1
                                BBF.ChangesOnReload["targetToTYPos"] = 17
                                BBF.ChangesOnReload["focusToTXPos"] = -1
                                BBF.ChangesOnReload["focusToTYPos"] = 17
                                BBF.ChangesOnReload["targetToTScale"] = 0.97
                                BBF.ChangesOnReload["focusToTScale"] = 0.97
                                BBF.ChangesOnReload["targetCastBarXPos"] = 5
                                BBF.ChangesOnReload["focusCastBarXPos"] = 5
                                BBF.ChangesOnReload["targetCastBarWidth"] = 143
                                BBF.ChangesOnReload["focusCastBarWidth"] = 143
                                BBF.ChangesOnReload["playerCastBarWidth"] = 205
                                BBF.ChangesOnReload["playerCastBarHeight"] = 12.5
                            end

                            local comboPointsEnabled = self.cfComboPoints:GetChecked()
                            BBF.ChangesOnReload["comboPointLocation"] = comboPointsEnabled and "1" or nil
                            BBF.ChangesOnReload["enableLegacyComboPoints"] = comboPointsEnabled and true or nil
                            BBF.ChangesOnReload["legacyCombosTurnedOff"] = comboPointsEnabled and nil or true

                            local statusBarsEnabled = self.cfTextures:GetChecked()
                            BBF.ChangesOnReload["changeUnitFrameHealthbarTexture"] = statusBarsEnabled or false
                            BBF.ChangesOnReload["changeUnitFrameManabarTexture"] = statusBarsEnabled or false
                            BBF.ChangesOnReload["unitFrameHealthbarTexture"] = statusBarsEnabled and "Blizzard CF" or nil
                            BBF.ChangesOnReload["unitFrameManabarTexture"] = statusBarsEnabled and "Blizzard CF" or nil
                            BBF.ChangesOnReload["hidePlayerHealthLossAnim"] = statusBarsEnabled and true or nil
                        end
                        CheckBoxes()

                        self.cfCastbars:SetScript("OnClick", function()
                            CheckBoxes()
                        end)
                        self.cfComboPoints:SetScript("OnClick", function()
                            CheckBoxes()
                        end)
                        self.cfTextures:SetScript("OnClick", function()
                            CheckBoxes()
                        end)
                        self.cfCastbars:SetPoint("BOTTOMLEFT", self.ButtonContainer.Button1, "TOPLEFT", 15, 43)
                        self.cfComboPoints:SetPoint("TOPLEFT", self.cfCastbars, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
                        self.cfTextures:SetPoint("TOPLEFT", self.cfComboPoints, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
                        self.cfTextures:Show()
                    end,
                    OnHide = function(self)
                        if self.cfTextures then
                            self.cfTextures:Hide()
                        end
                        if self.cfComboPoints then
                            self.cfComboPoints:Hide()
                        end
                        if self.cfCastbars then
                            self.cfCastbars:Hide()
                        end
                    end,
                    timeout = 0,
                    whileDead = true,
                }
                BBF.ClassicReloadWindow = true
            end
            StaticPopup_Show("BBF_CLASSIC_RELOAD")
        else
            local db = BetterBlizzFramesDB
            db.classicCastbarsParty = false
            db.classicCastbarsPlayer = false
            db.classicCastbarsPlayerBorder = false
            db.classicCastbars = false
            db.classicCastbarsParty = false
            db.changeUnitFrameHealthbarTexture = false
            db.changeUnitFrameManabarTexture = false
            db.comboPointLocation = nil
            db.targetToTXPos = -1
            db.targetToTYPos = 17
            db.focusToTXPos = -1
            db.focusToTYPos = 17
            db.targetToTScale = 0.97
            db.focusToTScale = 0.97
            db.targetCastBarXPos = 5
            db.focusCastBarXPos = 5
            db.targetCastBarWidth = 143
            db.focusCastBarWidth = 143
            db.playerCastBarWidth = 205
            db.playerCastBarHeight = 12.5
            db.hidePlayerHealthLossAnim = nil
            if not InCombatLockdown() then
                C_CVar.SetCVar("comboPointLocation", "2")
            end
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local noPortraitModes = CreateCheckbox("noPortraitModes", L["No_Portrait"], BetterBlizzFrames)
    noPortraitModes:SetPoint("LEFT", classicFrames.text, "RIGHT", 0, 0)
    CreateTooltipTwo(noPortraitModes, L["No_Portrait"], L["Tooltip_No_Portrait_Desc"])

    local noPortraitPixelBorder = CreateCheckbox("noPortraitPixelBorder", L["NP_PixelBorder"], BetterBlizzFrames)
    noPortraitPixelBorder:SetPoint("BOTTOMLEFT", noPortraitModes, "TOPRIGHT", -14, -5)
    CreateTooltipTwo(noPortraitPixelBorder, L["No_Portrait_PixelBorder"], L["Tooltip_No_Portrait_PixelBorder_Desc"])
    noPortraitPixelBorder:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzFramesDB.classicFrames = false
            BetterBlizzFramesDB.noPortraitModes = true
            noPortraitModes:SetChecked(true)
            if not BetterBlizzFramesDB.changeUnitFrameHealthbarTexture then
                BetterBlizzFramesDB.changeUnitFrameHealthbarTexture = true
                BetterBlizzFramesDB.unitFrameHealthbarTexture = "Blizzard Retail Bar Crop 2"
            end
            if not BetterBlizzFramesDB.changeUnitFrameManabarTexture then
                BetterBlizzFramesDB.changeUnitFrameManabarTexture = true
                BetterBlizzFramesDB.unitFrameManabarTexture = BetterBlizzFramesDB.unitFrameHealthbarTexture or "Blizzard Retail Bar Crop 2"
            end
        end
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    noPortraitModes:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzFramesDB.classicFrames = false
        else
            BetterBlizzFramesDB.noPortraitPixelBorder = false
            noPortraitPixelBorder:SetChecked(false)
        end
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local classColorFrames = CreateCheckbox("classColorFrames", L["Class_Color_Health"], BetterBlizzFrames)
    classColorFrames:SetPoint("TOPLEFT", classicFrames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    classColorFrames:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    classColorFrames:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if IsShiftKeyDown() and not IsControlKeyDown() then
                if not BetterBlizzFramesDB.classColorFramesSkipFriendly then
                    BetterBlizzFramesDB.classColorFramesSkipFriendly = true
                else
                    BetterBlizzFramesDB.classColorFramesSkipFriendly = nil
                end
            elseif IsControlKeyDown() and not IsShiftKeyDown() then
                if not BetterBlizzFramesDB.classColorFramesSkipPlayer then
                    BetterBlizzFramesDB.classColorFramesSkipPlayer = true
                else
                    BetterBlizzFramesDB.classColorFramesSkipPlayer = nil
                end
            end
            if BetterBlizzFramesDB.classColorFramesSkipPlayer then
                if PlayerFrame and PlayerFrame.healthbar then
                    PlayerFrame.healthbar:SetStatusBarDesaturated(false)
                    PlayerFrame.healthbar:SetStatusBarColor(1, 1, 1)
                end
                if CfPlayerFrameHealthBar then
                    BBF.updateFrameColorToggleVer(CfPlayerFrameHealthBar, "player")
                end
            else
                if PlayerFrame and PlayerFrame.healthbar then
                    BBF.updateFrameColorToggleVer(PlayerFrame.healthbar, "player")
                end
                if CfPlayerFrameHealthBar then
                    BBF.updateFrameColorToggleVer(CfPlayerFrameHealthBar, "player")
                end
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
            BBF.UpdateFrames()
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
    end)
    CreateTooltipTwo(classColorFrames, L["Tooltip_Class_Color_Healthbars_Title"], L["Tooltip_Class_Color_Frames_Desc"])

    local customHealthbarColors = CreateCheckbox("customHealthbarColors", L["Custom_Color_Health_Mana"], BetterBlizzFrames)
    customHealthbarColors:SetPoint("TOPLEFT", classColorFrames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(customHealthbarColors, L["Custom_Colors"], L["Tooltip_Custom_Colors_Desc"])
    customHealthbarColors:HookScript("OnClick", function(self)
        BBF.UpdateFrames()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    customHealthbarColors.extendedSettings = CreateFrame("Frame", nil, BetterBlizzFrames, "DefaultPanelFlatTemplate")
    customHealthbarColors.extendedSettings:SetSize(345, 560)
    customHealthbarColors.extendedSettings:SetPoint("TOPLEFT", classColorFrames, "BOTTOMLEFT", 0, -10)
    customHealthbarColors.extendedSettings:SetFrameStrata("DIALOG")
    customHealthbarColors.extendedSettings:SetIgnoreParentAlpha(true)
    customHealthbarColors.extendedSettings:Hide()
    customHealthbarColors.extendedSettings:SetTitle(L["Custom_Health_Colors"])
    customHealthbarColors.extendedSettings:EnableMouse(true)
    customHealthbarColors.extendedSettings:SetMovable(true)
    customHealthbarColors.extendedSettings:SetClampedToScreen(true)
    customHealthbarColors.extendedSettings:RegisterForDrag("LeftButton")
    customHealthbarColors.extendedSettings:SetScript("OnDragStart", function(self) self:StartMoving() end)
    customHealthbarColors.extendedSettings:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    customHealthbarColors.closeButton = CreateFrame("Button", nil, customHealthbarColors.extendedSettings, "UIPanelCloseButton")
    customHealthbarColors.closeButton:SetPoint("TOPRIGHT", customHealthbarColors.extendedSettings, "TOPRIGHT", 0, 0)
    customHealthbarColors.closeButton:SetScript("OnClick", function()
        customHealthbarColors.extendedSettings:Hide()
        BetterBlizzFrames:SetAlpha(1)
    end)

    customHealthbarColors.bg = customHealthbarColors.extendedSettings:CreateTexture(nil, "BACKGROUND")
    customHealthbarColors.bg:SetPoint("TOPLEFT", customHealthbarColors.extendedSettings, "TOPLEFT", 7, -3)
    customHealthbarColors.bg:SetPoint("BOTTOMRIGHT", customHealthbarColors.extendedSettings, "BOTTOMRIGHT", -3, 3)
    customHealthbarColors.bg:SetColorTexture(0.08, 0.08, 0.08, 1)

    customHealthbarColors:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if IsShiftKeyDown() and not IsControlKeyDown() then
                if not BetterBlizzFramesDB.classColorFramesSkipFriendly then
                    BetterBlizzFramesDB.classColorFramesSkipFriendly = true
                else
                    BetterBlizzFramesDB.classColorFramesSkipFriendly = nil
                end
                BBF.UpdateFrames()
            elseif IsControlKeyDown() and not IsShiftKeyDown() then
                if not BetterBlizzFramesDB.classColorFramesSkipPlayer then
                    BetterBlizzFramesDB.classColorFramesSkipPlayer = true
                else
                    BetterBlizzFramesDB.classColorFramesSkipPlayer = nil
                end
                if BetterBlizzFramesDB.classColorFramesSkipPlayer then
                    if PlayerFrame and PlayerFrame.healthbar then
                        PlayerFrame.healthbar:SetStatusBarDesaturated(false)
                        PlayerFrame.healthbar:SetStatusBarColor(1, 1, 1)
                    end
                    if CfPlayerFrameHealthBar then
                        BBF.updateFrameColorToggleVer(CfPlayerFrameHealthBar, "player")
                    end
                else
                    if PlayerFrame and PlayerFrame.healthbar then
                        BBF.updateFrameColorToggleVer(PlayerFrame.healthbar, "player")
                    end
                    if CfPlayerFrameHealthBar then
                        BBF.updateFrameColorToggleVer(CfPlayerFrameHealthBar, "player")
                    end
                end
            elseif not IsShiftKeyDown() and not IsControlKeyDown() then
                customHealthbarColors.extendedSettings:SetShown(not customHealthbarColors.extendedSettings:IsShown())
                BetterBlizzFrames:SetAlpha(customHealthbarColors.extendedSettings:IsShown() and 0.5 or 1)
            end
        end
    end)

    local clrFx = customHealthbarColors.extendedSettings
    clrFx.customColorsHeader = clrFx:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    clrFx.customColorsHeader:SetPoint("TOPLEFT", clrFx, "TOPLEFT", 11, -28)
    clrFx.customColorsHeader:SetText(L["Custom_Colors"])
    clrFx.customColorsHeader:SetFont(fontLarge, 14)
    clrFx.customColorsHeader:SetTextColor(1, 1, 1)

    clrFx.customColorsUnitFrames = CreateCheckbox("customColorsUnitFrames", L["Enable_On_UnitFrames"], clrFx)
    clrFx.customColorsUnitFrames:SetPoint("TOPLEFT", clrFx.customColorsHeader, "BOTTOMLEFT", 0, -1)
    CreateTooltipTwo(clrFx.customColorsUnitFrames, L["Enable_On_UnitFrames"], L["Tooltip_Enable_On_UnitFrames_Desc"])
    clrFx.customColorsUnitFrames:HookScript("OnClick", function(self)
        BBF.UpdateFrames()
    end)

    clrFx.customColorsUnitFramesNames = CreateCheckbox("customColorsUnitFramesNames", L["Enable_On_UnitFrames_Names"], clrFx)
    clrFx.customColorsUnitFramesNames:SetPoint("LEFT", clrFx.customColorsUnitFrames.text, "RIGHT", 2, 0)
    CreateTooltipTwo(clrFx.customColorsUnitFramesNames, L["Enable_On_UnitFrames_Names"], L["Tooltip_Enable_On_UnitFrames_Names_Desc"])
    clrFx.customColorsUnitFramesNames:HookScript("OnClick", function(self)
        BBF.UpdateFrames()
        BBF.AllNameChanges()
    end)

    clrFx.customColorsRaidFrames = CreateCheckbox("customColorsRaidFrames", L["Enable_On_Raid_Party_Frames"], clrFx)
    clrFx.customColorsRaidFrames:SetPoint("TOPLEFT", clrFx.customColorsUnitFrames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(clrFx.customColorsRaidFrames, L["Enable_On_Raid_Party_Frames"], L["Tooltip_Enable_On_Raid_Party_Frames_Desc"])
    clrFx.customColorsRaidFrames:HookScript("OnClick", function(self)
        BBF.UpdateFrames()
    end)

    clrFx.customColorsRaidFramesNames = CreateCheckbox("customColorsRaidFramesNames", L["Enable_On_Raid_Party_Names"], clrFx)
    clrFx.customColorsRaidFramesNames:SetPoint("LEFT", clrFx.customColorsRaidFrames.text, "RIGHT", 2, 0)
    CreateTooltipTwo(clrFx.customColorsRaidFramesNames, L["Enable_On_Raid_Party_Names"], L["Tooltip_Enable_On_Raid_Party_Names_Desc"])
    clrFx.customColorsRaidFramesNames:HookScript("OnClick", function(self)
        BBF.UpdateFrames()
        BBF.AllNameChanges()
    end)

    clrFx.reactionColorsSeparator = clrFx:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    clrFx.reactionColorsSeparator:SetPoint("TOPLEFT", clrFx.customColorsRaidFrames, "BOTTOMLEFT", 0, -2)
    clrFx.reactionColorsSeparator:SetText(L["Reaction_Colors"])
    clrFx.reactionColorsSeparator:SetFont(fontLarge, 14)
    clrFx.reactionColorsSeparator:SetTextColor(1, 1, 1)

    clrFx.enemyHealthColor = CreateColorBox(clrFx, "enemyHealthColor", L["Enemy"], function() BBF.UpdateFrames() end)
    clrFx.enemyHealthColor:SetPoint("TOPLEFT", clrFx.reactionColorsSeparator, "BOTTOMLEFT", 0, -1)
    CreateTooltipTwo(clrFx.enemyHealthColor, L["Enemy_Health_Color"], L["Tooltip_Color_Picker_Desc"])

    clrFx.friendlyHealthColor = CreateColorBox(clrFx, "friendlyHealthColor", L["Friendly"], function() BBF.UpdateFrames() end)
    clrFx.friendlyHealthColor:SetPoint("LEFT", clrFx.enemyHealthColor.text, "RIGHT", 0, 0)
    CreateTooltipTwo(clrFx.friendlyHealthColor, L["Friendly_Health_Color"], L["Tooltip_Color_Picker_Desc"])

    clrFx.neutralHealthColor = CreateColorBox(clrFx, "neutralHealthColor", L["Neutral"], function() BBF.UpdateFrames() end)
    clrFx.neutralHealthColor:SetPoint("LEFT", clrFx.friendlyHealthColor.text, "RIGHT", 0, 0)
    CreateTooltipTwo(clrFx.neutralHealthColor, L["Neutral_Health_Color"], L["Tooltip_Color_Picker_Desc"])

    clrFx.classColorsSeparator = clrFx:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    clrFx.classColorsSeparator:SetPoint("TOPLEFT", clrFx.enemyHealthColor, "BOTTOMLEFT", 0, -3)
    clrFx.classColorsSeparator:SetText(L["Class_Colors"])
    clrFx.classColorsSeparator:SetFont(fontLarge, 14)
    clrFx.classColorsSeparator:SetTextColor(1, 1, 1)

    clrFx.overrideClassColors = CreateCheckbox("overrideClassColors", L["Override_Class_Colors"], clrFx)
    clrFx.overrideClassColors:SetPoint("TOPLEFT", clrFx.classColorsSeparator, "BOTTOMLEFT", 0, -1)
    CreateTooltipTwo(clrFx.overrideClassColors, L["Override_Class_Colors"], L["Tooltip_Override_Class_Colors_Desc"].."\n\n|cffffaa00Individual class colors I think is gone in 12.1. I'll bring it back if I can later but it looks not good. Only \"Use One Color\" works.|r")

    clrFx.useOneClassColor = CreateCheckbox("useOneClassColor", L["Use_One_Color"], clrFx)
    clrFx.useOneClassColor:SetPoint("TOPLEFT", clrFx.overrideClassColors, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(clrFx.useOneClassColor, L["Use_One_Color_For_All_Classes"], L["Tooltip_Use_One_Color_For_All_Classes_Desc"])
    clrFx.useOneClassColor:HookScript("OnClick", function(self)
        local enabled = not self:GetChecked()
        if self:GetChecked() then
            clrFx.singleClassColor:SetAlpha(1)
        else
            clrFx.singleClassColor:SetAlpha(0.5)
        end
        for _, classData in ipairs(customHealthbarColors.classColorBoxes) do
            if enabled then
                classData.colorBox:SetAlpha(1)
            else
                classData.colorBox:SetAlpha(0.5)
            end
        end
        BBF.UpdateFrames()
    end)

    clrFx.singleClassColor = CreateColorBox(clrFx, "singleClassColor", L["All_Classes"], function() BBF.UpdateFrames() end)
    clrFx.singleClassColor:SetPoint("LEFT", clrFx.useOneClassColor.Text, "RIGHT", 4, 0)
    CreateTooltipTwo(clrFx.singleClassColor, L["Single_Class_Color"], L["Tooltip_Color_Picker_Desc"])

    if not BetterBlizzFramesDB.useOneClassColor then
        clrFx.singleClassColor:SetAlpha(0.5)
    end

    -- Disabled, probably dead cuz UnitClass secret :(
    customHealthbarColors.classColorBoxes = {}

    -- local classes = {}
    -- for classID = 1, GetNumClasses() do
    --     local _, classTag, classID = GetClassInfo(classID)
    --     if classTag then
    --         table.insert(classes, {key = classTag, name = FormatClassName(classTag)})
    --     end
    -- end

    -- table.sort(classes, function(a, b) return a.name < b.name end)

    -- local lastClassColorRow1
    -- local lastClassColorRow2
    -- local lastClassColorRow3
    -- local thirdCount = math.ceil(#classes / 3)

    -- for i, classData in ipairs(classes) do
    --     local classColor = CreateColorBox(clrFx, "classColor"..classData.key, classData.name, function() BBF.UpdateFrames() end)
        
    --     if i <= thirdCount then
    --         if i == 1 then
    --             classColor:SetPoint("TOPLEFT", clrFx.useOneClassColor, "BOTTOMLEFT", 0, 1)
    --         else
    --             classColor:SetPoint("TOPLEFT", lastClassColorRow1, "BOTTOMLEFT", 0, 1)
    --         end
    --         lastClassColorRow1 = classColor
    --     elseif i <= thirdCount * 2 then
    --         if i == thirdCount + 1 then
    --             classColor:SetPoint("TOPLEFT", clrFx.useOneClassColor, "BOTTOMLEFT", 105, 1)
    --         else
    --             classColor:SetPoint("TOPLEFT", lastClassColorRow2, "BOTTOMLEFT", 0, 1)
    --         end
    --         lastClassColorRow2 = classColor
    --     else
    --         if i == thirdCount * 2 + 1 then
    --             classColor:SetPoint("TOPLEFT", clrFx.useOneClassColor, "BOTTOMLEFT", 210, 1)
    --         else
    --             classColor:SetPoint("TOPLEFT", lastClassColorRow3, "BOTTOMLEFT", 0, 1)
    --         end
    --         lastClassColorRow3 = classColor
    --     end
        
    --     CreateTooltipTwo(classColor, classData.name.." Class Color", L["Tooltip_Color_Picker_Desc"])
    --     table.insert(customHealthbarColors.classColorBoxes, {colorBox = classColor, class = classData.key})
    -- end

    if not BetterBlizzFramesDB.overrideClassColors then
        clrFx.useOneClassColor:Disable()
        clrFx.useOneClassColor:SetAlpha(0.5)
        clrFx.singleClassColor:SetAlpha(0.5)
        for _, classData in ipairs(customHealthbarColors.classColorBoxes) do
            classData.colorBox:SetAlpha(0.5)
        end
    else
        if BetterBlizzFramesDB.useOneClassColor then
            clrFx.singleClassColor:SetAlpha(1)
            for _, classData in ipairs(customHealthbarColors.classColorBoxes) do
                classData.colorBox:SetAlpha(0.5)
            end
        else
            clrFx.singleClassColor:SetAlpha(0.5)
            for _, classData in ipairs(customHealthbarColors.classColorBoxes) do
                classData.colorBox:SetAlpha(1)
            end
        end
    end

    clrFx.useOneClassColor:HookScript("OnShow", function(self)
        local enabled = not BetterBlizzFramesDB.useOneClassColor
        local classColorsEnabled = BetterBlizzFramesDB.overrideClassColors
        for _, classData in ipairs(customHealthbarColors.classColorBoxes) do
            if classColorsEnabled and enabled then
                classData.colorBox:SetAlpha(1)
            else
                classData.colorBox:SetAlpha(0.5)
            end
        end
    end)
    
    clrFx.powerColorsSeparator = clrFx:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    clrFx.powerColorsSeparator:SetPoint("TOPLEFT", lastClassColorRow1 or clrFx.useOneClassColor, "BOTTOMLEFT", 0, -3)
    clrFx.powerColorsSeparator:SetText(L["Power_Colors"])
    clrFx.powerColorsSeparator:SetFont(fontLarge, 14)
    clrFx.powerColorsSeparator:SetTextColor(1, 1, 1)

    clrFx.customPowerColors = CreateCheckbox("customPowerColors", L["Enable_Power_Colors"], clrFx)
    clrFx.customPowerColors:SetPoint("TOPLEFT", clrFx.powerColorsSeparator, "BOTTOMLEFT", 0, -1)
    CreateTooltipTwo(clrFx.customPowerColors, L["Enable_Power_Colors"], L["Tooltip_Enable_Power_Colors_Desc"])

    clrFx.useOnePowerColor = CreateCheckbox("useOnePowerColor", L["Use_One_Color"], clrFx)
    clrFx.useOnePowerColor:SetPoint("TOPLEFT", clrFx.customPowerColors, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(clrFx.useOnePowerColor, L["Use_One_Color_For_All_Powers"], L["Tooltip_Use_One_Color_For_All_Powers_Desc"])
    clrFx.useOnePowerColor:HookScript("OnClick", function(self)
        local enabled = not self:GetChecked()
        if self:GetChecked() then
            clrFx.singlePowerColor:SetAlpha(1)
        else
            clrFx.singlePowerColor:SetAlpha(0.5)
        end
        for _, powerData in ipairs(customHealthbarColors.powerColorBoxes) do
            if enabled then
                powerData.colorBox:SetAlpha(1)
            else
                powerData.colorBox:SetAlpha(0.5)
            end
        end
        if BetterBlizzFramesDB.useOnePowerColor and not BetterBlizzFramesDB.changeUnitFrameManabarTexture and BetterBlizzFramesDB.useOnePowerColor and BetterBlizzFramesDB.customPowerColors then
            clrFx.singlePowerColorNote:Show()
        else
            clrFx.singlePowerColorNote:Hide()
        end
        BBF.UpdateFrames()
    end)

    clrFx.singlePowerColor = CreateColorBox(clrFx, "singlePowerColor", L["All_Powers"], function() BBF.UpdateFrames() end)
    clrFx.singlePowerColor:SetPoint("LEFT", clrFx.useOnePowerColor.Text, "RIGHT", 4, 0)
    CreateTooltipTwo(clrFx.singlePowerColor, L["Single_Power_Color"], L["Tooltip_Color_Picker_Desc"])

    clrFx.singlePowerColorNote = clrFx:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    clrFx.singlePowerColorNote:SetPoint("LEFT", clrFx.singlePowerColor.text, "RIGHT", 2, 1)
    clrFx.singlePowerColorNote:SetText("|cffff0000Note!|r")
    clrFx.singlePowerColorNote:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Texture_Change_Recommended"], 1, 1, 1, 1, true)
        GameTooltip:AddLine(L["Tooltip_Texture_Change_Recommended_Desc"], nil, nil, nil, true)
        GameTooltip:Show()
    end)
    clrFx.singlePowerColorNote:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    if BetterBlizzFramesDB.useOnePowerColor and not BetterBlizzFramesDB.changeUnitFrameManabarTexture and BetterBlizzFramesDB.useOnePowerColor and BetterBlizzFramesDB.customPowerColors then
        clrFx.singlePowerColorNote:Show()
    else
        clrFx.singlePowerColorNote:Hide()
    end

    if not BetterBlizzFramesDB.useOnePowerColor then
        clrFx.singlePowerColor:SetAlpha(0.5)
    end


    local powerColors = {
        {key = "MANA", name = L["Power_Mana"]},
        {key = "RAGE", name = L["Power_Rage"]},
        {key = "FOCUS", name = L["Power_Focus"]},
        {key = "ENERGY", name = L["Power_Energy"]},
        {key = "RUNIC_POWER", name = L["Power_Runic_Power"]},
        {key = "LUNAR_POWER", name = L["Power_Lunar_Power"]},
        {key = "MAELSTROM", name = L["Power_Maelstrom"]},
        {key = "INSANITY", name = L["Power_Insanity"]},
        {key = "CHI", name = L["Power_Chi"]},
        {key = "FURY", name = L["Power_Fury"]},
        {key = "EBON_MIGHT", name = L["Power_Ebon_Might"]},
        {key = "STAGGER", name = L["Power_Stagger"]},
        {key = "SOUL_FRAGMENTS", name = L["Power_Soul_Fragments"]},
    }

    customHealthbarColors.powerColorBoxes = {}
    local lastPowerColorRow1
    local lastPowerColorRow2
    local lastPowerColorRow3
    local thirdCount = 4
    
    for i, powerData in ipairs(powerColors) do
        local powerColor = CreateColorBox(clrFx, "powerColor"..powerData.key, powerData.name, function() BBF.UpdateFrames() end)

        if i <= thirdCount then
            if i == 1 then
                powerColor:SetPoint("TOPLEFT", clrFx.useOnePowerColor, "BOTTOMLEFT", 0, 1)
            else
                powerColor:SetPoint("TOPLEFT", lastPowerColorRow1, "BOTTOMLEFT", 0, 1)
            end
            lastPowerColorRow1 = powerColor
        elseif i <= thirdCount * 2 then
            if i == thirdCount + 1 then
                powerColor:SetPoint("TOPLEFT", clrFx.useOnePowerColor, "BOTTOMLEFT", 105, 1)
            else
                powerColor:SetPoint("TOPLEFT", lastPowerColorRow2, "BOTTOMLEFT", 0, 1)
            end
            lastPowerColorRow2 = powerColor
        else
            if i == thirdCount * 2 + 1 then
                powerColor:SetPoint("TOPLEFT", clrFx.useOnePowerColor, "BOTTOMLEFT", 210, 1)
            else
                powerColor:SetPoint("TOPLEFT", lastPowerColorRow3, "BOTTOMLEFT", 0, 1)
            end
            lastPowerColorRow3 = powerColor
        end
        
        CreateTooltipTwo(powerColor, powerData.name.." Color", L["Tooltip_Color_Picker_Desc"])
        table.insert(customHealthbarColors.powerColorBoxes, {colorBox = powerColor, power = powerData.key})
    end
    
    if not BetterBlizzFramesDB.customPowerColors then
        clrFx.useOnePowerColor:Disable()
        clrFx.useOnePowerColor:SetAlpha(0.5)
        clrFx.singlePowerColor:SetAlpha(0.5)
        for _, powerData in ipairs(customHealthbarColors.powerColorBoxes) do
            powerData.colorBox:SetAlpha(0.5)
        end
    else
        if BetterBlizzFramesDB.useOnePowerColor then
            clrFx.singlePowerColor:SetAlpha(1)
            for _, powerData in ipairs(customHealthbarColors.powerColorBoxes) do
                powerData.colorBox:SetAlpha(0.5)
            end
        else
            clrFx.singlePowerColor:SetAlpha(0.5)
            for _, powerData in ipairs(customHealthbarColors.powerColorBoxes) do
                powerData.colorBox:SetAlpha(1)
            end
        end
    end

    clrFx.useOnePowerColor:HookScript("OnShow", function(self)
        local enabled = not BetterBlizzFramesDB.useOnePowerColor
        local powerColorsEnabled = BetterBlizzFramesDB.customPowerColors
        for _, powerData in ipairs(customHealthbarColors.powerColorBoxes) do
            if powerColorsEnabled and enabled then
                powerData.colorBox:SetAlpha(1)
            else
                powerData.colorBox:SetAlpha(0.5)
            end
        end
    end)
    
    clrFx.customPowerColors:HookScript("OnShow", function(self)
        local enabled = BetterBlizzFramesDB.customPowerColors
        if enabled then
            clrFx.useOnePowerColor:Enable()
            clrFx.useOnePowerColor:SetAlpha(1)
            clrFx.singlePowerColor:SetAlpha(BetterBlizzFramesDB.useOnePowerColor and 1 or 0.5)
            for _, powerData in ipairs(customHealthbarColors.powerColorBoxes) do
                powerData.colorBox:SetAlpha(BetterBlizzFramesDB.useOnePowerColor and 0.5 or 1)
            end
        else
            clrFx.useOnePowerColor:Disable()
            clrFx.useOnePowerColor:SetAlpha(0.5)
            clrFx.singlePowerColor:SetAlpha(0.5)
            for _, powerData in ipairs(customHealthbarColors.powerColorBoxes) do
                powerData.colorBox:SetAlpha(0.5)
            end
        end
    end)
    
    clrFx.customPowerColors:HookScript("OnClick", function(self)
        local enabled = self:GetChecked()
        if enabled then
            clrFx.useOnePowerColor:Enable()
            clrFx.useOnePowerColor:SetAlpha(1)
            clrFx.singlePowerColor:SetAlpha(BetterBlizzFramesDB.useOnePowerColor and 1 or 0.5)
            for _, powerData in ipairs(customHealthbarColors.powerColorBoxes) do
                powerData.colorBox:SetAlpha(BetterBlizzFramesDB.useOnePowerColor and 0.5 or 1)
            end
        else
            clrFx.useOnePowerColor:Disable()
            clrFx.useOnePowerColor:SetAlpha(0.5)
            clrFx.singlePowerColor:SetAlpha(0.5)
            for _, powerData in ipairs(customHealthbarColors.powerColorBoxes) do
                powerData.colorBox:SetAlpha(0.5)
            end
        end
        if BetterBlizzFramesDB.useOnePowerColor and not BetterBlizzFramesDB.changeUnitFrameManabarTexture and BetterBlizzFramesDB.useOnePowerColor and BetterBlizzFramesDB.customPowerColors then
            clrFx.singlePowerColorNote:Show()
        else
            clrFx.singlePowerColorNote:Hide()
        end
        BBF.UpdateFrames()
    end)

    clrFx.backgroundColorsSeparator = clrFx:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    clrFx.backgroundColorsSeparator:SetPoint("TOPLEFT", lastPowerColorRow1 or clrFx.useOnePowerColor, "BOTTOMLEFT", 0, -3)
    clrFx.backgroundColorsSeparator:SetText(L["Background_Colors"])
    clrFx.backgroundColorsSeparator:SetFont(fontLarge, 14)
    clrFx.backgroundColorsSeparator:SetTextColor(1, 1, 1)

    clrFx.addUnitFrameBgTexture = CreateCheckbox("addUnitFrameBgTexture", L["Change_UnitFrame_Background_Color"], clrFx)
    clrFx.addUnitFrameBgTexture:SetPoint("TOPLEFT", clrFx.backgroundColorsSeparator, "BOTTOMLEFT", 0, -1)
    CreateTooltipTwo(clrFx.addUnitFrameBgTexture, L["Change_UnitFrame_Background_Color"], L["Tooltip_Change_UnitFrame_Background_Color_Desc"])

    clrFx.unitFrameBgTextureColor = CreateColorBox(clrFx, "unitFrameBgTextureColor", L["Health_BG"], function() BBF.UnitFrameBackgroundTexture() end)
    clrFx.unitFrameBgTextureColor:SetPoint("TOPLEFT", clrFx.addUnitFrameBgTexture, "BOTTOMLEFT", 16, 5)
    CreateTooltipTwo(clrFx.unitFrameBgTextureColor, L["Health_Bar_Background_Color"], L["Tooltip_Color_Picker_Desc"])

    clrFx.unitFrameBgTextureManaColor = CreateColorBox(clrFx, "unitFrameBgTextureManaColor", L["Mana_BG"], function() BBF.UnitFrameBackgroundTexture() end)
    clrFx.unitFrameBgTextureManaColor:SetPoint("LEFT", clrFx.unitFrameBgTextureColor.text, "RIGHT", 4, 0)
    CreateTooltipTwo(clrFx.unitFrameBgTextureManaColor, L["Mana_Bar_Background_Color"], L["Tooltip_Color_Picker_Desc"])

    clrFx.unitFrameBgTexture = CreateTextureDropdown(
        "unitFrameBgTexture",
        clrFx,
        L["Select_Texture"],
        "unitFrameBgTexture",
        function(arg1)
            BBF.UpdateCustomTextures()
            BBF.UnitFrameBackgroundTexture()
        end,
        { anchorFrame = clrFx.unitFrameBgTextureColor, x = 2, y = 4, label = "Texture" }
    )

    clrFx.changePartyRaidFrameBackgroundColor = CreateCheckbox("changePartyRaidFrameBackgroundColor", L["Change_Party_RaidFrame_Background_Color"], clrFx)
    clrFx.changePartyRaidFrameBackgroundColor:SetPoint("TOPLEFT", clrFx.unitFrameBgTextureColor, "BOTTOMLEFT", -16, pixelsBetweenBoxes-31)
    CreateTooltipTwo(clrFx.changePartyRaidFrameBackgroundColor, L["Change_Party_RaidFrame_Background_Color"], L["Tooltip_Change_Party_RaidFrame_Background_Color_Desc"])

    clrFx.partyRaidFrameBackgroundHealthColor = CreateColorBox(clrFx, "partyRaidFrameBackgroundHealthColor", L["Health_BG"], function() BBF.SetCompactUnitFramesBackground() end)
    clrFx.partyRaidFrameBackgroundHealthColor:SetPoint("TOPLEFT", clrFx.changePartyRaidFrameBackgroundColor, "BOTTOMLEFT", 16, 5)
    CreateTooltipTwo(clrFx.partyRaidFrameBackgroundHealthColor, L["Party_Raid_Health_Bar_Background_Color"], L["Tooltip_Color_Picker_Desc"])

    clrFx.partyRaidFrameBackgroundManaColor = CreateColorBox(clrFx, "partyRaidFrameBackgroundManaColor", L["Mana_BG"], function() BBF.SetCompactUnitFramesBackground() end)
    clrFx.partyRaidFrameBackgroundManaColor:SetPoint("LEFT", clrFx.partyRaidFrameBackgroundHealthColor.text, "RIGHT", 4, 0)
    CreateTooltipTwo(clrFx.partyRaidFrameBackgroundManaColor, L["Party_Raid_Mana_Bar_Background_Color"], L["Tooltip_Color_Picker_Desc"])

    clrFx.raidFrameBgTexture = CreateTextureDropdown(
        "raidFrameBgTexture",
        clrFx,
        L["Select_Texture"],
        "raidFrameBgTexture",
        function(arg1)
            BBF.UpdateCustomTextures()
            BBF.SetCompactUnitFramesBackground()
        end,
        { anchorFrame = clrFx.partyRaidFrameBackgroundHealthColor, x = 2, y = 4, label = "Texture" }
    )

    clrFx.addUnitFrameBgTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            clrFx.unitFrameBgTextureColor:SetAlpha(1)
            clrFx.unitFrameBgTextureManaColor:SetAlpha(1)
            clrFx.unitFrameBgTexture:SetEnabled(true)
        else
            clrFx.unitFrameBgTextureColor:SetAlpha(0.5)
            clrFx.unitFrameBgTextureManaColor:SetAlpha(0.5)
            clrFx.unitFrameBgTexture:SetEnabled(false)
        end
        BBF.UnitFrameBackgroundTexture()
        BBF.UpdateCustomTextures()

        if BBF.changeUnitFrameBackgroundColorTexture then
            BBF.changeUnitFrameBackgroundColorTexture:SetChecked(self:GetChecked())
            if BBF.unitFrameBgTextureDropdown then
                BBF.unitFrameBgTextureDropdown:SetEnabled(self:GetChecked())
            end
        end
    end)
    BBF.addUnitFrameBgTexture = clrFx.addUnitFrameBgTexture

    clrFx.changePartyRaidFrameBackgroundColor:HookScript("OnClick", function(self)
        if self:GetChecked() then
            clrFx.partyRaidFrameBackgroundHealthColor:SetAlpha(1)
            clrFx.partyRaidFrameBackgroundManaColor:SetAlpha(1)
            clrFx.raidFrameBgTexture:SetEnabled(true)
        else
            clrFx.partyRaidFrameBackgroundHealthColor:SetAlpha(0.5)
            clrFx.partyRaidFrameBackgroundManaColor:SetAlpha(0.5)
            clrFx.raidFrameBgTexture:SetEnabled(false)
        end
        BBF.SetCompactUnitFramesBackground()
        BBF.UpdateFrames()
        BBF.UpdateCustomTextures()

        if BBF.changePartyRaidFrameBackgroundColorTexture then
            BBF.changePartyRaidFrameBackgroundColorTexture:SetChecked(self:GetChecked())
            if BBF.raidFrameBgTextureDropdown then
                BBF.raidFrameBgTextureDropdown:SetEnabled(self:GetChecked())
            end
        end
    end)
    BBF.changePartyRaidFrameBackgroundColor = clrFx.changePartyRaidFrameBackgroundColor

    clrFx.overrideClassColors:HookScript("OnClick", function(self)
        local enabled = self:GetChecked()
        if enabled then
            clrFx.useOneClassColor:Enable()
            clrFx.useOneClassColor:SetAlpha(1)
            clrFx.singleClassColor:SetAlpha(BetterBlizzFramesDB.useOneClassColor and 1 or 0.5)
            for _, classData in ipairs(customHealthbarColors.classColorBoxes) do
                classData.colorBox:SetAlpha(BetterBlizzFramesDB.useOneClassColor and 0.5 or 1)
            end
        else
            clrFx.useOneClassColor:Disable()
            clrFx.useOneClassColor:SetAlpha(0.5)
            clrFx.singleClassColor:SetAlpha(0.5)
            for _, classData in ipairs(customHealthbarColors.classColorBoxes) do
                classData.colorBox:SetAlpha(0.5)
            end
        end
        BBF.UpdateFrames()
    end)
    
    clrFx.overrideClassColors:HookScript("OnShow", function(self)
        local enabled = BetterBlizzFramesDB.overrideClassColors
        if enabled then
            clrFx.useOneClassColor:Enable()
            clrFx.useOneClassColor:SetAlpha(1)
            clrFx.singleClassColor:SetAlpha(BetterBlizzFramesDB.useOneClassColor and 1 or 0.5)
            for _, classData in ipairs(customHealthbarColors.classColorBoxes) do
                classData.colorBox:SetAlpha(BetterBlizzFramesDB.useOneClassColor and 0.5 or 1)
            end
        else
            clrFx.useOneClassColor:Disable()
            clrFx.useOneClassColor:SetAlpha(0.5)
            clrFx.singleClassColor:SetAlpha(0.5)
            for _, classData in ipairs(customHealthbarColors.classColorBoxes) do
                classData.colorBox:SetAlpha(0.5)
            end
        end
    end)

    local classColorTargetNames = CreateCheckbox("classColorTargetNames", L["Class_Color_Names"], BetterBlizzFrames)
    classColorTargetNames:SetPoint("TOPLEFT", customHealthbarColors, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classColorTargetNames, L["Class_Color_Names"], L["Tooltip_Class_Color_Names_Desc"])

    local classColorLevelText = CreateCheckbox("classColorLevelText", L["Level"], classColorTargetNames)
    classColorLevelText:SetPoint("LEFT", classColorTargetNames.text, "RIGHT", 0, 0)
    CreateTooltip(classColorLevelText, L["Tooltip_Level"])

    classColorTargetNames:HookScript("OnClick", function(self)
        BBF.AllNameChanges()
        if self:GetChecked() then
            classColorLevelText:Enable()
            classColorLevelText:SetAlpha(1)
        else
            classColorLevelText:Disable()
            classColorLevelText:SetAlpha(0)
        end
    end)
    if not BetterBlizzFramesDB.classColorTargetNames then
        classColorLevelText:SetAlpha(0)
    end

    local classColorFrameTexture = CreateCheckbox("classColorFrameTexture", L["Class_Color_FrameTexture"], BetterBlizzFrames)
    classColorFrameTexture:SetPoint("TOPLEFT", classColorTargetNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    classColorFrameTexture:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        else
            BBF.HookFrameTextureColor()
        end
    end)
    CreateTooltipTwo(classColorFrameTexture, L["Class_Color_FrameTexture"], L["Tooltip_Class_Color_FrameTexture_Desc"])


    local centerNames = CreateCheckbox("centerNames", L["Center_Name"], BetterBlizzFrames, nil, BBF.SetCenteredNamesCaller)
    centerNames:SetPoint("TOPLEFT", classColorFrameTexture, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(centerNames, L["Center_Names"], L["Tooltip_Center_Name_Desc"])
    centerNames:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local removeRealmNames = CreateCheckbox("removeRealmNames", L["Hide_Realm"], BetterBlizzFrames)
    removeRealmNames:SetPoint("LEFT", centerNames.text, "RIGHT", 0, 0)
    CreateTooltipTwo(removeRealmNames, L["Tooltip_Hide_Realm_Indicator_Title"], L["Tooltip_Hide_Realm_Desc"])

    local formatStatusBarText = CreateCheckbox("formatStatusBarText", L["Format_Numbers"], BetterBlizzFrames, nil, BBF.HookStatusBarText)
    formatStatusBarText:SetPoint("TOPLEFT", centerNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(formatStatusBarText, L["Format_Numbers"], L["Tooltip_Format_Numbers_Desc"])
    formatStatusBarText:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if not BetterBlizzFramesDB.formatStatusBarTextExtraDecimals then
                BetterBlizzFramesDB.formatStatusBarTextExtraDecimals = true
            else
                BetterBlizzFramesDB.formatStatusBarTextExtraDecimals = nil
            end
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                self:GetScript("OnEnter")(self)
            end
            if formatStatusBarText:GetChecked() then
                BBF.HookStatusBarText()
            end
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local singleValueStatusBarText = CreateCheckbox("singleValueStatusBarText", L["No_Max"], formatStatusBarText)
    singleValueStatusBarText:SetPoint("LEFT", formatStatusBarText.text, "RIGHT", 0, 0)
    CreateTooltipTwo(singleValueStatusBarText, L["No_Max_Value"], L["Tooltip_No_Max_Value_Desc"])
    singleValueStatusBarText:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    formatStatusBarText:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
        CheckAndToggleCheckboxes(self)
    end)

    local hidePrestigeBadge = CreateCheckbox("hidePrestigeBadge", L["Tooltip_Hide_PvP_Icon"], BetterBlizzFrames, nil, BBF.HideFrames)
    hidePrestigeBadge:SetPoint("TOPLEFT", formatStatusBarText, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hidePrestigeBadge, L["Hide_Prestige_Honor_Badge_PvP_Icon"], L["Tooltip_Hide_Prestige_Badge_Desc"])

    local hideCombatGlow = CreateCheckbox("hideCombatGlow", L["Hide_Combat_Glow"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideCombatGlow:SetPoint("TOPLEFT", hidePrestigeBadge, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideCombatGlow, L["Tooltip_Hide_Combat_Glow"] .. " |A:UI-HUD-UnitFrame-Player-PortraitOn-InCombat:30:80|a")

    local hideUnitFrameShadow = CreateCheckbox("hideUnitFrameShadow", L["Hide_Shadow"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideUnitFrameShadow:SetPoint("LEFT", hideCombatGlow.text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideUnitFrameShadow, L["Hide_Shadow"], L["Tooltip_Hide_Shadow_Desc"])
    hideUnitFrameShadow:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        else
            BetterBlizzFramesDB.hideTargetReputationColor = true
            BetterBlizzFramesDB.hideFocusReputationColor = true
            hideTargetReputationColor:SetChecked(true)
            hideFocusReputationColor:SetChecked(true)
            BBF.HideFrames()
        end
    end)

    local hideLevelText = CreateCheckbox("hideLevelText", L["Hide_Max_Level_Text"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideLevelText:SetPoint("TOPLEFT", hideCombatGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideLevelText, L["Tooltip_Hide_Max_Level_Text"])
    hideLevelText:HookScript("OnClick", function()
        if BetterBlizzFramesDB.classicFrames then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local hideLevelTextAlways = CreateCheckbox("hideLevelTextAlways", L["Always"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideLevelTextAlways:SetPoint("LEFT", hideLevelText.Text, "RIGHT", 0, 0)
    CreateTooltip(hideLevelTextAlways, L["Tooltip_Always"])
    hideLevelTextAlways:HookScript("OnClick", function()
        if BetterBlizzFramesDB.classicFrames then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

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

    -- local hidePvpIcon = CreateCheckbox("hidePvpIcon", "Hide PvP Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    -- hidePvpIcon:SetPoint("TOPLEFT", hideLevelText, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltip(hidePvpIcon, L["Tooltip_Hide_PvP_Icon"])

    local hideRareDragonTexture = CreateCheckbox("hideRareDragonTexture", L["Hide_Dragon"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideRareDragonTexture:SetPoint("TOPLEFT", hideLevelText, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideRareDragonTexture, L["Tooltip_Hide_Dragon"] .. " |A:UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold:38:28|a")
    hideRareDragonTexture:HookScript("OnClick", function()
        if BetterBlizzFramesDB.classicFrames then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local hideThreatOnFrame = CreateCheckbox("hideThreatOnFrame", L["Hide_Threat"], BetterBlizzFrames, nil, BBF.HideFrames)
    hideThreatOnFrame:SetPoint("LEFT", hideRareDragonTexture.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideThreatOnFrame, L["Hide_Threat_Meter"], L["Tooltip_Hide_Threat_Meter_Desc"])

    local classPortraitsUseSpecIcons = CreateCheckbox("classPortraitsUseSpecIcons", L["Use_Spec_Icons"], BetterBlizzFrames, nil, BBF.SpecPortraits)
    classPortraitsUseSpecIcons:SetPoint("TOPLEFT", hideRareDragonTexture, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classPortraitsUseSpecIcons, L["Tooltip_Use_Spec_Icons"])
    classPortraitsUseSpecIcons:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local classPortraitsUseSpecIconsSkipSelf = CreateCheckbox("classPortraitsUseSpecIconsSkipSelf", L["Skip_Self"], BetterBlizzFrames, nil, BBF.SpecPortraits)
    classPortraitsUseSpecIconsSkipSelf:SetPoint("LEFT", classPortraitsUseSpecIcons.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(classPortraitsUseSpecIconsSkipSelf, L["Use_spec_icons_Skip_Self"], L["Tooltip_Skip_Self_Spec_Icon_Desc"])

    classPortraitsUseSpecIcons:HookScript("OnClick", function(self)
        if self:GetChecked() then
            classPortraitsUseSpecIconsSkipSelf:Enable()
            classPortraitsUseSpecIconsSkipSelf:Show()
        else
            classPortraitsUseSpecIconsSkipSelf:Disable()
            classPortraitsUseSpecIconsSkipSelf:Hide()
        end
    end)

    if not BetterBlizzFramesDB.classPortraitsUseSpecIcons then
        classPortraitsUseSpecIconsSkipSelf:Hide()
        classPortraitsUseSpecIconsSkipSelf:Disable()
    end

    local extraFeaturesText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    extraFeaturesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, 30)
    extraFeaturesText:SetText(L["Extra_Features"])
    extraFeaturesText:SetFont(fontLarge, 16)
    extraFeaturesText:SetTextColor(1,1,1)
    local extraFeaturesIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    extraFeaturesIcon:SetAtlas("Campaign-QuestLog-LoreBook")
    extraFeaturesIcon:SetSize(24, 24)
    extraFeaturesIcon:SetPoint("RIGHT", extraFeaturesText, "LEFT", -1, 0)

    local combatIndicator = CreateCheckbox("combatIndicator", L["Combat_Indicator"], BetterBlizzFrames)
    combatIndicator:SetPoint("TOPLEFT", extraFeaturesText, "BOTTOMLEFT", -24, pixelsOnFirstBox)
    combatIndicator:HookScript("OnClick", function()
        BBF.CombatIndicatorCaller()
    end)
    CreateTooltipTwo(combatIndicator, L["Combat_Indicator"], L["Tooltip_Combat_Indicator_Desc"], nil, nil, nil, 1)

    local healerIndicator = CreateCheckbox("healerIndicator", L["Healer_Indicator"], BetterBlizzFrames)
    healerIndicator:SetPoint("TOPLEFT", combatIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    healerIndicator:HookScript("OnClick", function(self)
        BBF.HealerIndicatorCaller()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    CreateTooltipTwo(healerIndicator, L["Healer_Indicator"], L["Tooltip_Healer_Indicator_Desc"])

    local absorbIndicator = CreateCheckbox("absorbIndicator", L["Absorb_Indicator"], BetterBlizzFrames, nil, BBF.AbsorbCaller)
    absorbIndicator:SetPoint("TOPLEFT", healerIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    absorbIndicator:HookScript("OnClick", function()
        BBF.AbsorbCaller()
    end)
    CreateTooltipTwo(absorbIndicator, L["Absorb_Indicator"], L["Tooltip_Absorb_Indicator_Desc"], nil, nil, nil, 1)

    local racialIndicator = CreateCheckbox("racialIndicator", L["Racial_Indicator"], BetterBlizzFrames, nil, BBF.RacialIndicatorCaller)
    racialIndicator:SetPoint("TOPLEFT", absorbIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    racialIndicator:HookScript("OnClick", function()
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltipTwo(racialIndicator, L["Racial_Indicator"], L["Tooltip_Racial_Indicator_Desc"], nil, nil, nil, 1)

    local overShields = CreateCheckbox("overShields", L["Overshields"], BetterBlizzFrames)
    overShields:SetPoint("TOPLEFT", racialIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(overShields, L["Overshields"], L["Tooltip_Overshields_Desc"], nil, "ANCHOR_LEFT", nil, 2)

    local overShieldsUnitFrames = CreateCheckbox("overShieldsUnitFrames", L["A"], BetterBlizzFrames)
    overShieldsUnitFrames:SetPoint("LEFT", overShields.text, "RIGHT", 0, 0)
    CreateTooltipTwo(overShieldsUnitFrames, L["UnitFrame_Overshields"], L["Tooltip_UnitFrame_Overshields_Desc"], nil, "ANCHOR_LEFT", nil, 1)
    overShieldsUnitFrames:HookScript("OnClick", function(self)
        BBF.HookOverShields()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local overShieldsCompactUnitFrames = CreateCheckbox("overShieldsCompactUnitFrames", L["B"], BetterBlizzFrames)
    overShieldsCompactUnitFrames:SetPoint("LEFT", overShieldsUnitFrames.text, "RIGHT", 0, 0)
    CreateTooltipTwo(overShieldsCompactUnitFrames, L["Compact_UnitFrames_Overshields"], L["Tooltip_Compact_UnitFrames_Overshields_Desc"], nil, "ANCHOR_LEFT", nil, 2)
    overShieldsCompactUnitFrames:HookScript("OnClick", function(self)
        BBF.HookOverShields()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    overShields:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzFramesDB.overShieldsCompact = true
            BetterBlizzFramesDB.overShieldsUnitFrames = true
            BBF.HookOverShields()
            overShieldsUnitFrames:SetAlpha(1)
            overShieldsUnitFrames:Enable()
            overShieldsUnitFrames:SetChecked(true)
            overShieldsCompactUnitFrames:SetAlpha(1)
            overShieldsCompactUnitFrames:Enable()
            overShieldsCompactUnitFrames:SetChecked(true)
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        else
            BetterBlizzFramesDB.overShieldsCompact = false
            BetterBlizzFramesDB.overShieldsUnitFrames = false
            overShieldsUnitFrames:SetAlpha(0)
            overShieldsUnitFrames:Disable()
            overShieldsUnitFrames:SetChecked(false)
            overShieldsCompactUnitFrames:SetAlpha(0)
            overShieldsCompactUnitFrames:Disable()
            overShieldsCompactUnitFrames:SetChecked(false)
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    if BetterBlizzFramesDB.overShields then
        overShieldsUnitFrames:SetAlpha(1)
        overShieldsUnitFrames:Enable()
        overShieldsCompactUnitFrames:SetAlpha(1)
        overShieldsCompactUnitFrames:Enable()
    else
        overShieldsUnitFrames:SetAlpha(0)
        overShieldsUnitFrames:Disable()
        overShieldsCompactUnitFrames:SetAlpha(0)
        overShieldsCompactUnitFrames:Disable()
    end

    local queueTimer = CreateCheckbox("queueTimer", L["Queue_Timer"], BetterBlizzFrames)
    queueTimer:SetPoint("TOPLEFT", overShields, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(queueTimer, L["Queue_Timer"], L["Tooltip_Queue_Timer_Desc"], nil, "ANCHOR_LEFT")

    local queueTimerAudio = CreateCheckbox("queueTimerAudio", L["SFX"], queueTimer)
    queueTimerAudio:SetPoint("LEFT", queueTimer.text, "RIGHT", 0, 0)
    CreateTooltipTwo(queueTimerAudio, L["Sound_Effect"], L["Tooltip_Sound_Effect_Desc"], L["Tooltip_Sound_Effect_Extra"], "ANCHOR_LEFT")

    local queueTimerWarning = CreateCheckbox("queueTimerWarning", L["Queue_Timer_Warning"], queueTimer)
    queueTimerWarning:SetPoint("LEFT", queueTimerAudio.text, "RIGHT", 0, 0)
    CreateTooltipTwo(queueTimerWarning, L["Sound_Alert"], L["Tooltip_Sound_Alert_Desc"], L["Tooltip_Sound_Alert_Extra"], "ANCHOR_LEFT")

    queueTimerAudio:HookScript("OnClick", function(self)
        if self:GetChecked() then
            EnableElement(queueTimerWarning)
        else
            DisableElement(queueTimerWarning)
        end
    end)

    if not BetterBlizzFramesDB.queueTimerAudio then
        DisableElement(queueTimerWarning)
    end

    queueTimer:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
        CheckAndToggleCheckboxes(queueTimer)
        if not BetterBlizzFramesDB.queueTimerAudio then
            DisableElement(queueTimerWarning)
        end
        if self:GetChecked() then
            BBF.SBUncheck()
            if C_AddOns.IsAddOnLoaded("SafeQueue") then
                C_AddOns.DisableAddOn("SafeQueue")
            end
        end
    end)

    local enableBigDebuffs = CreateCheckbox("enableBigDebuffs", L["Enable_Big_Debuffs"], BetterBlizzFrames, nil, function()
        BBF.CreateBigDebuffs()
    end)
    enableBigDebuffs:SetPoint("TOPLEFT", queueTimer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(enableBigDebuffs, L["Enable_Big_Debuffs"], L["Tooltip_Big_Debuffs_Desc"], nil, "ANCHOR_LEFT")

    BetterBlizzFrames.kickPopupEnabled = CreateCheckbox("kickPopupEnabled", L["Kick_Popup"], BetterBlizzFrames, nil, function()
        BBF.ToggleKickPopup()
        if BetterBlizzFramesDB.kickPopupEnabled then
            BBF.TestKickPopup(true)
            C_Timer.After(2.5, function()
                if not BetterBlizzFramesDB.kickPopupTestMode and BBF.kickPopupFrame and BBF.kickPopupFrame:IsShown() then
                    BBF.kickPopupFrame.fadeOut:Play()
                end
            end)
        end
    end)
    BetterBlizzFrames.kickPopupEnabled:SetPoint("TOPLEFT", enableBigDebuffs, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(BetterBlizzFrames.kickPopupEnabled, L["Kick_Popup"], L["Tooltip_Kick_Popup_Desc"], nil, "ANCHOR_LEFT")

    local btnGap = -2
    local lastCoreButton = profilesFrame.coreText
    local lastStreamerButton = profilesFrame.streamerText

    for _, profile in ipairs(BBF.ProfileData) do
        local additionalNote = profile.name == "Starter" and "|cff808080(If you want to completely reset BBF there\nis a button in Advanced Settings)|r\n\n" or nil
        local button = CreateClassButton(BetterBlizzFrames, profile.class, profile.name, profile.twitchName, function()
            ShowProfileConfirmation(profile.name, profile.class, function() BBF.ApplyProfile(profile.name) end, additionalNote)
        end)
        if profile.core then
            button:SetPoint("TOP", lastCoreButton, "BOTTOM", 0, lastCoreButton == profilesFrame.coreText and -3 or btnGap)
            lastCoreButton = button
        else
            button:SetPoint("TOP", lastStreamerButton, "BOTTOM", 0, lastStreamerButton == profilesFrame.streamerText and -3 or btnGap)
            lastStreamerButton = button
        end
    end

    local resetBBFButton = CreateFrame("Button", nil, BetterBlizzFrames, "UIPanelButtonTemplate")
    resetBBFButton:SetText(L["Full_Reset"])
    resetBBFButton:SetWidth(104)
    resetBBFButton:SetPoint("BOTTOM", profilesFrame, "BOTTOM", 2, 15)
    resetBBFButton:SetScript("OnClick", function()
        StaticPopup_Show("CONFIRM_RESET_BETTERBLIZZFRAMESDB")
    end)
    CreateTooltip(resetBBFButton, L["Tooltip_Full_Reset"], "ANCHOR_TOP")




    ----------------------
    -- Reload etc
    ----------------------
    local reloadUiButton = CreateFrame("Button", nil, BetterBlizzFrames, "UIPanelButtonTemplate")
    reloadUiButton:SetText(L["Reload_UI"])
    reloadUiButton:SetWidth(96)
    reloadUiButton:SetPoint("RIGHT", SettingsPanel.CloseButton, "LEFT", -3, 0)
    reloadUiButton:SetScript("OnClick", function()
        BetterBlizzFramesDB.reopenOptions = true
        ReloadUI()
    end)

    -- if not SettingsPanel.CloseButton.origPoint then
    --     SettingsPanel.CloseButton.origPoint, SettingsPanel.CloseButton.origRel, SettingsPanel.CloseButton.origAnchor, SettingsPanel.CloseButton.origX, SettingsPanel.CloseButton.origY = SettingsPanel.CloseButton:GetPoint()
    -- end
    -- SettingsPanel.CloseButton:ClearAllPoints()
    -- SettingsPanel.CloseButton:SetPoint("TOPRIGHT", BetterBlizzFrames, "BOTTOMRIGHT", 6, -41)
    -- BetterBlizzFrames:HookScript("OnShow", function()
    --     SettingsPanel.CloseButton:ClearAllPoints()
    --     SettingsPanel.CloseButton:SetPoint("TOPRIGHT", BetterBlizzFrames, "BOTTOMRIGHT", 6, -41)
    -- end)
    -- BetterBlizzFrames:HookScript("OnHide", function()
    --     if BetterBlizzPlates and BetterBlizzPlates:IsShown() then return end
    --     SettingsPanel.CloseButton:ClearAllPoints()
    --     SettingsPanel.CloseButton:SetPoint(SettingsPanel.CloseButton.origPoint, SettingsPanel.CloseButton.origRel, SettingsPanel.CloseButton.origAnchor, SettingsPanel.CloseButton.origX, SettingsPanel.CloseButton.origY)
    -- end)
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
    BetterBlizzFramesCastbars.name = L["Castbars"]
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
    contentFrame.name = BetterBlizzFramesCastbars.name
    contentFrame:SetSize(680, 520)
    scrollFrame:SetScrollChild(contentFrame)

    local mainGuiAnchor2 = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor2:SetPoint("TOPLEFT", 55, 20)
    mainGuiAnchor2:SetText(" ")

   ----------------------
    -- Party Castbars
    ----------------------
    local anchorSubPartyCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPartyCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, firstLineY)
    anchorSubPartyCastbar:SetText(L["Party_Castbars"])

    local partyCastbarBorder = CreateBorderedFrame(anchorSubPartyCastbar, 157, 386, 0, -145, contentFrame)

    local partyCastbars = contentFrame:CreateTexture(nil, "ARTWORK")
    partyCastbars:SetAtlas("ui-castingbar-filling-channel")
    partyCastbars:SetSize(110, 13)
    partyCastbars:SetPoint("BOTTOM", anchorSubPartyCastbar, "TOP", -1, 10)

    local partyCastBarScale = CreateSlider(contentFrame, L["Size"], 0.5, 1.9, 0.01, "partyCastBarScale")
    partyCastBarScale:SetPoint("TOP", anchorSubPartyCastbar, "BOTTOM", 0, -15)

    local partyCastBarXPos = CreateSlider(contentFrame, L["X_Offset"], -200, 200, 1, "partyCastBarXPos", "X")
    partyCastBarXPos:SetPoint("TOP", partyCastBarScale, "BOTTOM", 0, -15)

    local partyCastBarYPos = CreateSlider(contentFrame, L["Y_Offset"], -200, 200, 1, "partyCastBarYPos", "Y")
    partyCastBarYPos:SetPoint("TOP", partyCastBarXPos, "BOTTOM", 0, -15)

    local partyCastBarWidth = CreateSlider(contentFrame, L["Width"], 20, 200, 1, "partyCastBarWidth")
    partyCastBarWidth:SetPoint("TOP", partyCastBarYPos, "BOTTOM", 0, -15)

    local partyCastBarHeight = CreateSlider(contentFrame, L["Height"], 5, 30, 1, "partyCastBarHeight")
    partyCastBarHeight:SetPoint("TOP", partyCastBarWidth, "BOTTOM", 0, -15)

    local partyCastBarIconScale = CreateSlider(contentFrame, L["Icon_Size"], 0.4, 2, 0.01, "partyCastBarIconScale")
    partyCastBarIconScale:SetPoint("TOP", partyCastBarHeight, "BOTTOM", 0, -15)

    local partyCastbarIconXPos = CreateSlider(contentFrame, L["Icon_x_offset"], -50, 50, 1, "partyCastbarIconXPos")
    partyCastbarIconXPos:SetPoint("TOP", partyCastBarIconScale, "BOTTOM", 0, -15)

    local partyCastbarIconYPos = CreateSlider(contentFrame, L["Icon_y_offset"], -50, 50, 1, "partyCastbarIconYPos")
    partyCastbarIconYPos:SetPoint("TOP", partyCastbarIconXPos, "BOTTOM", 0, -15)

    local partyCastBarTestMode = CreateCheckbox("partyCastBarTestMode", L["Test"], contentFrame, nil, BBF.partyCastBarTestMode)
    partyCastBarTestMode:SetPoint("TOPLEFT", partyCastbarIconYPos, "BOTTOMLEFT", 10, -4)
    CreateTooltip(partyCastBarTestMode, L["Tooltip_Castbar_Test"])

    local partyCastBarTimer = CreateCheckbox("partyCastBarTimer", L["Timer"], contentFrame, nil, BBF.partyCastBarTestMode)
    partyCastBarTimer:SetPoint("LEFT", partyCastBarTestMode.Text, "RIGHT", 10, 0)
    CreateTooltip(partyCastBarTimer, L["Tooltip_Castbar_Timer"])

    local partyCastbarSelf = CreateCheckbox("partyCastbarSelf", L["Self"], contentFrame, nil, BBF.partyCastBarTestMode)
    partyCastbarSelf:SetPoint("TOPLEFT", partyCastBarTimer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(partyCastbarSelf, L["Tooltip_Show_Party_Castbar"])

    local showPartyCastBarIcon = CreateCheckbox("showPartyCastBarIcon", L["Icon"], contentFrame, nil, BBF.partyCastBarTestMode)
    showPartyCastBarIcon:SetPoint("TOPLEFT", partyCastBarTestMode, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    anchorSubPartyCastbar.classicCastbarsParty = CreateCheckbox("classicCastbarsParty", L["Castbar_Classic"], contentFrame, nil, BBF.partyCastBarTestMode)
    anchorSubPartyCastbar.classicCastbarsParty:SetPoint("TOPLEFT", showPartyCastBarIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubPartyCastbar.classicCastbarsParty, L["Castbar_Classic"], L["Tooltip_Castbar_Classic_Party_Desc"])

    anchorSubPartyCastbar.classicCastbarsParty:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local partyCastBarForceDefaultPartyFrames = CreateCheckbox("partyCastBarForceDefaultPartyFrames", L["Party_Castbar_Force_Default_Frames"], contentFrame)
    partyCastBarForceDefaultPartyFrames:SetPoint("TOPLEFT", anchorSubPartyCastbar.classicCastbarsParty, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(partyCastBarForceDefaultPartyFrames, L["Tooltip_Party_Castbar_Force_Default_Frames_Title"], L["Tooltip_Party_Castbar_Force_Default_Frames_Desc"])

    local resetPartyCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetPartyCastbar:SetText(L["Reset"])
    resetPartyCastbar:SetWidth(70)
    resetPartyCastbar:SetPoint("TOP", partyCastbarBorder, "BOTTOM", 0, -2)
    resetPartyCastbar:SetScript("OnClick", function()
        partyCastBarScale:SetMinMaxValues(0.5, 1.9)
        partyCastBarXPos:SetMinMaxValues(-200, 200)
        partyCastBarYPos:SetMinMaxValues(-200, 200)
        partyCastBarWidth:SetMinMaxValues(20, 200)
        partyCastBarHeight:SetMinMaxValues(5, 30)
        partyCastBarIconScale:SetMinMaxValues(0.4, 2)
        partyCastbarIconXPos:SetMinMaxValues(-50, 50)
        partyCastbarIconYPos:SetMinMaxValues(-50, 50)
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
    anchorSubTargetCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, firstLineY)
    anchorSubTargetCastbar:SetText(L["Target_Castbar"])

    local targetCastbarBorder = CreateBorderedFrame(anchorSubTargetCastbar, 157, 386, 0, -145, contentFrame)

    local targetCastBar = contentFrame:CreateTexture(nil, "ARTWORK")
    targetCastBar:SetAtlas("ui-castingbar-tier1-empower-2x")
    targetCastBar:SetSize(110, 13)
    targetCastBar:SetPoint("BOTTOM", anchorSubTargetCastbar, "TOP", -1, 10)

    local targetCastBarScale = CreateSlider(contentFrame, L["Size"], 0.1, 1.9, 0.01, "targetCastBarScale")
    targetCastBarScale:SetPoint("TOP", anchorSubTargetCastbar, "BOTTOM", 0, -15)

    local targetCastBarXPos = CreateSlider(contentFrame, L["X_Offset"], -130, 130, 1, "targetCastBarXPos", "X")
    targetCastBarXPos:SetPoint("TOP", targetCastBarScale, "BOTTOM", 0, -15)

    local targetCastBarYPos = CreateSlider(contentFrame, L["Y_Offset"], -130, 130, 1, "targetCastBarYPos", "Y")
    targetCastBarYPos:SetPoint("TOP", targetCastBarXPos, "BOTTOM", 0, -15)

    local targetCastBarWidth = CreateSlider(contentFrame, L["Width"], 60, 220, 1, "targetCastBarWidth")
    targetCastBarWidth:SetPoint("TOP", targetCastBarYPos, "BOTTOM", 0, -15)

    local targetCastBarHeight = CreateSlider(contentFrame, L["Height"], 5, 30, 1, "targetCastBarHeight")
    targetCastBarHeight:SetPoint("TOP", targetCastBarWidth, "BOTTOM", 0, -15)

    local targetCastBarIconScale = CreateSlider(contentFrame, L["Icon_Size"], 0.4, 2, 0.01, "targetCastBarIconScale")
    targetCastBarIconScale:SetPoint("TOP", targetCastBarHeight, "BOTTOM", 0, -15)

    local targetCastbarIconXPos = CreateSlider(contentFrame, L["Icon_x_offset"], -160, 160, 1, "targetCastbarIconXPos", "X")
    targetCastbarIconXPos:SetPoint("TOP", targetCastBarIconScale, "BOTTOM", 0, -15)

    local targetCastbarIconYPos = CreateSlider(contentFrame, L["Icon_y_offset"], -160, 160, 1, "targetCastbarIconYPos", "Y")
    targetCastbarIconYPos:SetPoint("TOP", targetCastbarIconXPos, "BOTTOM", 0, -15)

    local targetStaticCastbar = CreateCheckbox("targetStaticCastbar", L["Static"], contentFrame)
    targetStaticCastbar:SetPoint("TOPLEFT", targetCastbarIconYPos, "BOTTOMLEFT", 10, -4)
    CreateTooltip(targetStaticCastbar, L["Tooltip_Castbar_Static"])

    local targetCastBarTimer = CreateCheckbox("targetCastBarTimer", L["Timer"], contentFrame, nil, BBF.CastBarTimerCaller)
    targetCastBarTimer:SetPoint("LEFT", targetStaticCastbar.Text, "RIGHT", 10, 0)
    CreateTooltip(targetCastBarTimer, L["Tooltip_Castbar_Timer"])

    local targetToTCastbarAdjustment = CreateCheckbox("targetToTCastbarAdjustment", L["ToT_Offset"], contentFrame)
    targetToTCastbarAdjustment:SetPoint("TOPLEFT", targetStaticCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(targetToTCastbarAdjustment, L["Enable_ToT_Offset"], L["Tooltip_Castbar_ToT_Offset_Desc"])

    local targetToTAdjustmentOffsetY = CreateSlider(targetToTCastbarAdjustment, L["extra"], -20, 50, 1, "targetToTAdjustmentOffsetY", "Y", 55)
    targetToTAdjustmentOffsetY:SetPoint("LEFT", targetToTCastbarAdjustment.text, "RIGHT", 2, -5)
    CreateTooltipTwo(targetToTAdjustmentOffsetY, L["Tooltip_ToT_Adjustment_Offset_Y"], L["Tooltip_Castbar_ToT_Extra_Desc"])

    targetToTCastbarAdjustment:HookScript("OnClick", function(self)
        if self:GetChecked() then
            targetToTAdjustmentOffsetY:Enable()
            targetToTAdjustmentOffsetY:SetAlpha(1)
        else
            targetToTAdjustmentOffsetY:Disable()
            targetToTAdjustmentOffsetY:SetAlpha(0.5)
        end
        BBF.CastbarAdjustCaller("target")
    end)

    local targetDetachCastbar = CreateCheckbox("targetDetachCastbar", L["Castbar_Detach"], contentFrame)
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
            targetCastBarYPos:SetMinMaxValues(-130, 130)
            targetCastBarYPos:SetValue(0)
            targetToTCastbarAdjustment:Enable()
            targetToTCastbarAdjustment:SetAlpha(1)
            targetToTAdjustmentOffsetY:Enable()
            targetToTAdjustmentOffsetY:SetAlpha(1)
        end
        BBF.HideUnitCastbar("target")
        BBF.ChangeCastbarSizes()
        BBF.CastbarAdjustCaller("target")
    end)
    CreateTooltip(targetDetachCastbar, L["Tooltip_Detach_From_Frame"])

    if BetterBlizzFramesDB.targetDetachCastbar then
        targetCastBarXPos:SetMinMaxValues(-900, 900)
        targetCastBarYPos:SetMinMaxValues(-900, 900)
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
        BBF.HideUnitCastbar("target")
        BBF.CastbarAdjustCaller("target")
    end)
    if BetterBlizzFramesDB.targetStaticCastbar then
        targetToTCastbarAdjustment:Disable()
        targetToTCastbarAdjustment:SetAlpha(0.5)
        targetToTAdjustmentOffsetY:Disable()
        targetToTAdjustmentOffsetY:SetAlpha(0.5)
        targetDetachCastbar:SetChecked(false)
        BetterBlizzFramesDB.targetDetachCastbar = false
    end

    local hideTargetCastbar = CreateCheckbox("hideTargetCastbar", L["Hide_Bar"], contentFrame, nil, BBF.ChangeCastbarSizes)
    hideTargetCastbar:SetPoint("TOPLEFT", targetDetachCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideTargetCastbar, L["Hide_Bar"], L["Hide_Target_Castbar"])

    local hideTargetCastbarIcon = CreateCheckbox("hideTargetCastbarIcon", L["Hide_Icon"], contentFrame, nil, BBF.ChangeCastbarSizes)
    hideTargetCastbarIcon:SetPoint("LEFT", hideTargetCastbar.text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideTargetCastbarIcon, L["Hide_Icon"], L["Hide_Target_Castbar_Icon"])

    local resetTargetCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetTargetCastbar:SetText(L["Reset"])
    resetTargetCastbar:SetWidth(70)
    resetTargetCastbar:SetPoint("TOP", targetCastbarBorder, "BOTTOM", 0, -2)
    resetTargetCastbar:SetScript("OnClick", function()
        targetCastBarScale:SetMinMaxValues(0.1, 1.9)
        targetCastBarXPos:SetMinMaxValues(-130, 130)
        targetCastBarYPos:SetMinMaxValues(-130, 130)
        targetCastBarWidth:SetMinMaxValues(60, 220)
        targetCastBarHeight:SetMinMaxValues(5, 30)
        targetCastBarIconScale:SetMinMaxValues(0.4, 2)
        targetCastbarIconXPos:SetMinMaxValues(-160, 160)
        targetCastbarIconYPos:SetMinMaxValues(-160, 160)
        targetToTAdjustmentOffsetY:SetMinMaxValues(-20, 50)
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
        targetToTCastbarAdjustment:Enable()
        targetToTCastbarAdjustment:SetAlpha(1)
        targetToTCastbarAdjustment:SetChecked(true)
        targetToTAdjustmentOffsetY:Enable()
        targetToTAdjustmentOffsetY:SetValue(0)
        BetterBlizzFramesDB.targetToTCastbarAdjustment = true
        BBF.HideUnitCastbar("target")
        BBF.CastBarTimerCaller()
        BBF.ChangeCastbarSizes()
    end)


    ----------------------
    -- Pet Castbars
    ----------------------
    local anchorSubPetCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPetCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, secondLineY - 75)
    anchorSubPetCastbar:SetText(L["Pet_Castbar"])

    local petCastbarBorder = CreateBorderedFrame(anchorSubPetCastbar, 157, 320, 0, -122, contentFrame)

    local petCastbars = contentFrame:CreateTexture(nil, "ARTWORK")
    petCastbars:SetAtlas("ui-castingbar-filling-channel")
    petCastbars:SetDesaturated(true)
    petCastbars:SetVertexColor(1, 0.25, 0.98)
    petCastbars:SetSize(110, 13)
    petCastbars:SetPoint("BOTTOM", anchorSubPetCastbar, "TOP", -1, 10)

    local petCastBarScale = CreateSlider(contentFrame, L["Size"], 0.5, 1.9, 0.01, "petCastBarScale")
    petCastBarScale:SetPoint("TOP", anchorSubPetCastbar, "BOTTOM", 0, -15)

    local petCastBarXPos = CreateSlider(contentFrame, L["X_Offset"], -200, 200, 1, "petCastBarXPos", "X")
    petCastBarXPos:SetPoint("TOP", petCastBarScale, "BOTTOM", 0, -15)

    local petCastBarYPos = CreateSlider(contentFrame, L["Y_Offset"], -200, 200, 1, "petCastBarYPos", "Y")
    petCastBarYPos:SetPoint("TOP", petCastBarXPos, "BOTTOM", 0, -15)

    local petCastBarWidth = CreateSlider(contentFrame, L["Width"], 20, 200, 1, "petCastBarWidth")
    petCastBarWidth:SetPoint("TOP", petCastBarYPos, "BOTTOM", 0, -15)

    local petCastBarHeight = CreateSlider(contentFrame, L["Height"], 5, 30, 1, "petCastBarHeight")
    petCastBarHeight:SetPoint("TOP", petCastBarWidth, "BOTTOM", 0, -15)

    local petCastBarIconScale = CreateSlider(contentFrame, L["Icon_Size"], 0.4, 2, 0.01, "petCastBarIconScale")
    petCastBarIconScale:SetPoint("TOP", petCastBarHeight, "BOTTOM", 0, -15)

    local petCastBarTestMode = CreateCheckbox("petCastBarTestMode", L["Test"], contentFrame, nil, BBF.petCastBarTestMode)
    petCastBarTestMode:SetPoint("TOPLEFT", petCastBarIconScale, "BOTTOMLEFT", 10, -4)
    CreateTooltip(petCastBarTestMode, L["Tooltip_Need_Pet"])

    local petCastBarTimer = CreateCheckbox("petCastBarTimer", L["Timer"], contentFrame, nil, BBF.petCastBarTestMode)
    petCastBarTimer:SetPoint("LEFT", petCastBarTestMode.Text, "RIGHT", 10, 0)
    CreateTooltip(petCastBarTimer, L["Tooltip_Castbar_Timer"])

    local showPetCastBarIcon = CreateCheckbox("showPetCastBarIcon", L["Icon"], contentFrame, nil, BBF.petCastBarTestMode)
    showPetCastBarIcon:SetPoint("TOPLEFT", petCastBarTestMode, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local petDetachCastbar = CreateCheckbox("petDetachCastbar", L["Castbar_Detach"], contentFrame, nil, BBF.petCastBarTestMode)
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
            petCastBarYPos:SetMinMaxValues(-130, 130)
            petCastBarYPos:SetValue(0)
        end
        BBF.petCastBarTestMode()
        BBF.ChangeCastbarSizes()
    end)
    CreateTooltip(petDetachCastbar, L["Tooltip_Detach_From_Frame"])

    if BetterBlizzFramesDB.petDetachCastbar then
        petCastBarXPos:SetMinMaxValues(-900, 900)
        petCastBarXPos:SetValue(0)
        petCastBarYPos:SetMinMaxValues(-900, 900)
        petCastBarYPos:SetValue(0)
    end

    local resetpetCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetpetCastbar:SetText(L["Reset"])
    resetpetCastbar:SetWidth(70)
    resetpetCastbar:SetPoint("TOP", petCastbarBorder, "BOTTOM", 0, -2)
    resetpetCastbar:SetScript("OnClick", function()
        petCastBarScale:SetMinMaxValues(0.5, 1.9)
        petCastBarXPos:SetMinMaxValues(-200, 200)
        petCastBarYPos:SetMinMaxValues(-200, 200)
        petCastBarWidth:SetMinMaxValues(20, 200)
        petCastBarHeight:SetMinMaxValues(5, 30)
        petCastBarIconScale:SetMinMaxValues(0.4, 2)
        petCastBarScale:SetValue(1)
        petCastBarIconScale:SetValue(1)
        petCastBarXPos:SetValue(0)
        petCastBarYPos:SetValue(0)
        petCastBarWidth:SetValue(100)
        petCastBarHeight:SetValue(12)
        petCastBarTimer:SetChecked(true)
        petDetachCastbar:SetChecked(false)
        BetterBlizzFramesDB.petDetachCastbar = false
        BetterBlizzFramesDB.petCastBarTimer = true
        BBF.CastBarTimerCaller()
        BBF.ChangeCastbarSizes()
    end)

   ----------------------
    -- Focus Castbar
    ----------------------
    local anchorSubFocusCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubFocusCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, firstLineY)
    anchorSubFocusCastbar:SetText(L["Focus_Castbar"])

    local focusCastbarBorder = CreateBorderedFrame(anchorSubFocusCastbar, 157, 386, 0, -145, contentFrame)

    local focusCastBar = contentFrame:CreateTexture(nil, "ARTWORK")
    focusCastBar:SetAtlas("ui-castingbar-full-applyingcrafting")
    focusCastBar:SetSize(110, 16)
    focusCastBar:SetPoint("BOTTOM", anchorSubFocusCastbar, "TOP", -1, 8.5)

    local focusCastBarScale = CreateSlider(contentFrame, L["Size"], 0.1, 1.9, 0.01, "focusCastBarScale")
    focusCastBarScale:SetPoint("TOP", anchorSubFocusCastbar, "BOTTOM", 0, -15)

    local focusCastBarXPos = CreateSlider(contentFrame, L["X_Offset"], -130, 130, 1, "focusCastBarXPos", "X")
    focusCastBarXPos:SetPoint("TOP", focusCastBarScale, "BOTTOM", 0, -15)

    local focusCastBarYPos = CreateSlider(contentFrame, L["Y_Offset"], -130, 130, 1, "focusCastBarYPos", "Y")
    focusCastBarYPos:SetPoint("TOP", focusCastBarXPos, "BOTTOM", 0, -15)

    local focusCastBarWidth = CreateSlider(contentFrame, L["Width"], 60, 220, 1, "focusCastBarWidth")
    focusCastBarWidth:SetPoint("TOP", focusCastBarYPos, "BOTTOM", 0, -15)

    local focusCastBarHeight = CreateSlider(contentFrame, L["Height"], 5, 30, 1, "focusCastBarHeight")
    focusCastBarHeight:SetPoint("TOP", focusCastBarWidth, "BOTTOM", 0, -15)

    local focusCastBarIconScale = CreateSlider(contentFrame, L["Icon_Size"], 0.4, 2, 0.01, "focusCastBarIconScale")
    focusCastBarIconScale:SetPoint("TOP", focusCastBarHeight, "BOTTOM", 0, -15)

    local focusCastbarIconXPos = CreateSlider(contentFrame, L["Icon_x_offset"], -160, 160, 1, "focusCastbarIconXPos", "X")
    focusCastbarIconXPos:SetPoint("TOP", focusCastBarIconScale, "BOTTOM", 0, -15)

    local focusCastbarIconYPos = CreateSlider(contentFrame, L["Icon_y_offset"], -160, 160, 1, "focusCastbarIconYPos", "Y")
    focusCastbarIconYPos:SetPoint("TOP", focusCastbarIconXPos, "BOTTOM", 0, -15)

    local focusStaticCastbar = CreateCheckbox("focusStaticCastbar", L["Static"], contentFrame)
    focusStaticCastbar:SetPoint("TOPLEFT", focusCastbarIconYPos, "BOTTOMLEFT", 10, -4)
    CreateTooltip(focusStaticCastbar, L["Tooltip_Castbar_Static"])

    local focusCastBarTimer = CreateCheckbox("focusCastBarTimer", L["Timer"], contentFrame, nil, BBF.CastBarTimerCaller)
    focusCastBarTimer:SetPoint("LEFT", focusStaticCastbar.Text, "RIGHT", 10, 0)
    CreateTooltip(focusCastBarTimer, L["Tooltip_Castbar_Timer"])

    local focusToTCastbarAdjustment = CreateCheckbox("focusToTCastbarAdjustment", L["ToT_Offset"], contentFrame)
    focusToTCastbarAdjustment:SetPoint("TOPLEFT", focusStaticCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(focusToTCastbarAdjustment, L["Enable_ToT_Offset"], L["Tooltip_Castbar_ToT_Offset_Focus_Desc"])

    local focusToTAdjustmentOffsetY = CreateSlider(focusToTCastbarAdjustment, L["extra"], -20, 50, 1, "focusToTAdjustmentOffsetY", "Y", 55)
    focusToTAdjustmentOffsetY:SetPoint("LEFT", focusToTCastbarAdjustment.text, "RIGHT", 2, -5)
    CreateTooltipTwo(focusToTAdjustmentOffsetY, L["Tooltip_ToT_Adjustment_Offset_Y"], L["Tooltip_Castbar_ToT_Extra_Desc"])

    focusToTCastbarAdjustment:HookScript("OnClick", function(self)
        if self:GetChecked() then
            focusToTAdjustmentOffsetY:Enable()
            focusToTAdjustmentOffsetY:SetAlpha(1)
        else
            focusToTAdjustmentOffsetY:Disable()
            focusToTAdjustmentOffsetY:SetAlpha(0.5)
        end
        BBF.CastbarAdjustCaller("focus")
    end)

    local focusDetachCastbar = CreateCheckbox("focusDetachCastbar", L["Castbar_Detach"], contentFrame)
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
            focusCastBarYPos:SetMinMaxValues(-130, 130)
            focusCastBarYPos:SetValue(0)
            focusToTCastbarAdjustment:Enable()
            focusToTCastbarAdjustment:SetAlpha(1)
            focusToTAdjustmentOffsetY:Enable()
            focusToTAdjustmentOffsetY:SetAlpha(1)
        end
        BBF.HideUnitCastbar("focus")
        BBF.ChangeCastbarSizes()
        BBF.CastbarAdjustCaller("focus")
    end)
    CreateTooltip(focusDetachCastbar, L["Tooltip_Detach_From_Frame"])

    if BetterBlizzFramesDB.focusDetachCastbar then
        focusCastBarXPos:SetMinMaxValues(-900, 900)
        focusCastBarYPos:SetMinMaxValues(-900, 900)
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
            BetterBlizzFramesDB.focusDetachCastbar = false
        else
            focusToTCastbarAdjustment:Enable()
            focusToTCastbarAdjustment:SetAlpha(1)
            focusToTAdjustmentOffsetY:Enable()
            focusToTAdjustmentOffsetY:SetAlpha(1)
        end
        BBF.HideUnitCastbar("focus")
        BBF.CastbarAdjustCaller("focus")
    end)
    if BetterBlizzFramesDB.focusStaticCastbar then
        focusToTCastbarAdjustment:Disable()
        focusToTCastbarAdjustment:SetAlpha(0.5)
        focusToTAdjustmentOffsetY:Disable()
        focusToTAdjustmentOffsetY:SetAlpha(0.5)
        focusDetachCastbar:SetChecked(false)
        BetterBlizzFramesDB.focusDetachCastbar = false
    end

    local hideFocusCastbar = CreateCheckbox("hideFocusCastbar", L["Hide_Bar"], contentFrame, nil, BBF.ChangeCastbarSizes)
    hideFocusCastbar:SetPoint("TOPLEFT", focusDetachCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideFocusCastbar, L["Hide_Bar"], L["Tooltip_Hide_Focus_Castbar"])

    local hideFocusCastbarIcon = CreateCheckbox("hideFocusCastbarIcon", L["Hide_Icon"], contentFrame, nil, BBF.ChangeCastbarSizes)
    hideFocusCastbarIcon:SetPoint("LEFT", hideFocusCastbar.text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideFocusCastbarIcon, L["Hide_Icon"], L["Tooltip_Hide_Focus_Castbar_Icon"])

    local resetFocusCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetFocusCastbar:SetText(L["Reset"])
    resetFocusCastbar:SetWidth(70)
    resetFocusCastbar:SetPoint("TOP", focusCastbarBorder, "BOTTOM", 0, -2)
    resetFocusCastbar:SetScript("OnClick", function()
        focusCastBarScale:SetMinMaxValues(0.1, 1.9)
        focusCastBarXPos:SetMinMaxValues(-130, 130)
        focusCastBarYPos:SetMinMaxValues(-130, 130)
        focusCastBarWidth:SetMinMaxValues(60, 220)
        focusCastBarHeight:SetMinMaxValues(5, 30)
        focusCastBarIconScale:SetMinMaxValues(0.4, 2)
        focusCastbarIconXPos:SetMinMaxValues(-160, 160)
        focusCastbarIconYPos:SetMinMaxValues(-160, 160)
        focusToTAdjustmentOffsetY:SetMinMaxValues(-20, 50)
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
        focusToTCastbarAdjustment:Enable()
        focusToTCastbarAdjustment:SetAlpha(1)
        focusToTCastbarAdjustment:SetChecked(true)
        focusToTAdjustmentOffsetY:Enable()
        focusToTAdjustmentOffsetY:SetValue(0)
        BetterBlizzFramesDB.focusToTCastbarAdjustment = true
        BBF.HideUnitCastbar("focus")
        BBF.CastBarTimerCaller()
        BBF.ChangeCastbarSizes()
    end)


   ----------------------
    -- Player Castbar
    ----------------------
    local anchorSubPlayerCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPlayerCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, firstLineY)
    anchorSubPlayerCastbar:SetText(L["Player_Castbar"])

    local playerCastbarBorder = CreateBorderedFrame(anchorSubPlayerCastbar, 157, 450, 0, -77, contentFrame)

    local playerCastBar = contentFrame:CreateTexture(nil, "ARTWORK")
    playerCastBar:SetAtlas("ui-castingbar-filling-standard")
    playerCastBar:SetSize(110, 13)
    playerCastBar:SetPoint("BOTTOM", anchorSubPlayerCastbar, "TOP", -1, 10)


    local playerCastBarScale = CreateSlider(contentFrame, L["Size"], 0.1, 1.9, 0.01, "playerCastBarScale")
    playerCastBarScale:SetPoint("TOP", anchorSubPlayerCastbar, "BOTTOM", 0, -15)

    local playerCastbarIconXPos = CreateSlider(contentFrame, L["Icon_x_offset"], -200, 200, 1, "playerCastbarIconXPos", "X")
    playerCastbarIconXPos:SetPoint("TOP", playerCastBarScale, "BOTTOM", 0, -15)

    local playerCastbarIconYPos = CreateSlider(contentFrame, L["Icon_y_offset"], -200, 200, 1, "playerCastbarIconYPos", "Y")
    playerCastbarIconYPos:SetPoint("TOP", playerCastbarIconXPos, "BOTTOM", 0, -15)

    local playerCastBarIconScale = CreateSlider(contentFrame, L["Icon_Size"], 0.4, 2, 0.01, "playerCastBarIconScale")
    playerCastBarIconScale:SetPoint("TOP", playerCastbarIconYPos, "BOTTOM", 0, -15)

    local playerCastBarWidth = CreateSlider(contentFrame, L["Width"], 60, 230, 1, "playerCastBarWidth")
    --playerCastBarWidth:SetPoint("TOP", playerCastBarYPos, "BOTTOM", 0, -15)
    playerCastBarWidth:SetPoint("TOP", playerCastBarIconScale, "BOTTOM", 0, -15)

    local playerCastBarHeight = CreateSlider(contentFrame, L["Height"], 5, 30, 1, "playerCastBarHeight")
    playerCastBarHeight:SetPoint("TOP", playerCastBarWidth, "BOTTOM", 0, -15)

    local playerCastBarShowIcon = CreateCheckbox("playerCastBarShowIcon", L["Icon"], contentFrame, nil, BBF.ShowPlayerCastBarIcon)
    playerCastBarShowIcon:SetPoint("TOPLEFT", playerCastBarHeight, "BOTTOMLEFT", 10, -4)
    CreateTooltip(playerCastBarShowIcon, L["Tooltip_Player_Castbar_Icon"])

    local playerCastBarTimer = CreateCheckbox("playerCastBarTimer", L["Timer"], contentFrame, nil, BBF.CastBarTimerCaller)
    playerCastBarTimer:SetPoint("LEFT", playerCastBarShowIcon.Text, "RIGHT", 7, 0)
    CreateTooltip(playerCastBarTimer, L["Tooltip_Castbar_Timer"])

    local playerCastBarTimerCentered = CreateCheckbox("playerCastBarTimerCentered", L["Center"], contentFrame, nil, BBF.CastBarTimerCaller)
    --playerStaticCastbar:SetPoint("TOPLEFT", playerCastBarIconScale, "BOTTOMLEFT", 10, -4)
    playerCastBarTimerCentered:SetPoint("LEFT", playerCastBarTimer.Text, "RIGHT", 2, 0)
    CreateTooltip(playerCastBarTimerCentered, L["Tooltip_Player_Castbar_Timer_Center"])

    local playerCastBarNoTextBorder = CreateCheckbox("playerCastBarNoTextBorder", L["Player_Castbar_Simple"], contentFrame, nil, BBF.ChangeCastbarSizes)
    --playerStaticCastbar:SetPoint("TOPLEFT", playerCastBarIconScale, "BOTTOMLEFT", 10, -4)
    playerCastBarNoTextBorder:SetPoint("TOPLEFT", playerCastBarShowIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(playerCastBarNoTextBorder, L["Player_Castbar_Simple"], L["Tooltip_Player_Castbar_Simple_Desc"])

    local classicCastbarsPlayer = CreateCheckbox("classicCastbarsPlayer", L["Classic_Castbar"], contentFrame, nil, BBF.ChangeCastbarSizes)
    classicCastbarsPlayer:SetPoint("TOPLEFT", playerCastBarNoTextBorder, "BOTTOMLEFT", -15, pixelsBetweenBoxes)
    CreateTooltipTwo(classicCastbarsPlayer, L["Classic_Castbar"], L["Tooltip_Classic_Castbar_Desc"])

    local hidePlayerCastbar = CreateCheckbox("hidePlayerCastbar", L["Hide_Bar"], contentFrame, nil, BBF.ChangeCastbarSizes)
    hidePlayerCastbar:SetPoint("TOPLEFT", classicCastbarsPlayer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hidePlayerCastbar, L["Hide_Bar"], L["Hide_Player_Castbar"])

    local hidePlayerCastbarIcon = CreateCheckbox("hidePlayerCastbarIcon", L["Hide_Icon"], contentFrame, nil, BBF.ChangeCastbarSizes)
    hidePlayerCastbarIcon:SetPoint("LEFT", hidePlayerCastbar.text, "RIGHT", 0, 0)
    CreateTooltipTwo(hidePlayerCastbarIcon, L["Hide_Icon"], L["Hide_Player_Castbar_Icon"])
    hidePlayerCastbar:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local classicCastbarsPlayerBorder = CreateCheckbox("classicCastbarsPlayerBorder", L["Border"], classicCastbarsPlayer, nil, BBF.ChangeCastbarSizes)
    classicCastbarsPlayerBorder:SetPoint("LEFT", classicCastbarsPlayer.text, "RIGHT", 0, 0)
    CreateTooltipTwo(classicCastbarsPlayerBorder, L["Classic_Border"], L["Tooltip_Classic_Border_Desc"])

    classicCastbarsPlayer:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
        if self:GetChecked() then
            BetterBlizzFramesDB.castbarPixelBorder = nil
        end
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local resetPlayerCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetPlayerCastbar:SetText(L["Reset"])
    resetPlayerCastbar:SetWidth(70)
    resetPlayerCastbar:SetPoint("TOP", playerCastbarBorder, "BOTTOM", 0, -2)
    resetPlayerCastbar:SetScript("OnClick", function()
        playerCastBarScale:SetMinMaxValues(0.1, 1.9)
        playerCastbarIconXPos:SetMinMaxValues(-200, 200)
        playerCastbarIconYPos:SetMinMaxValues(-200, 200)
        playerCastBarIconScale:SetMinMaxValues(0.4, 2)
        playerCastBarWidth:SetMinMaxValues(60, 230)
        playerCastBarHeight:SetMinMaxValues(5, 30)
        playerCastbarIconXPos:SetValue(0)
        playerCastbarIconYPos:SetValue(0)
        playerCastBarScale:SetValue(1)
        playerCastBarIconScale:SetValue(1)
        playerCastBarWidth:SetValue(208)
        playerCastBarHeight:SetValue(11)
        playerCastBarShowIcon:SetChecked(false)
        playerCastBarTimer:SetChecked(false)
        playerCastBarTimerCentered:SetChecked(false)
        BetterBlizzFramesDB.playerCastBarShowIcon = false
        BetterBlizzFramesDB.playerCastBarTimer = false
        BetterBlizzFramesDB.playerStaticCastbar = false
        BetterBlizzFramesDB.playerCastBarTimerCentered = false
        --PlayerCastingBarFrame.showShield = false
        BBF.CastBarTimerCaller()
        BBF.ShowPlayerCastBarIcon()
        BBF.ChangeCastbarSizes()
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
            ColorPickerFrame.Content.ColorSwatchCurrent:SetAlpha(a)
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



    local castBarRecolorInterrupt = CreateCheckbox("castBarRecolorInterrupt", L["Interrupt_CD_Color"], contentFrame, nil, BBF.UpdateInterruptIconSettings)
    castBarRecolorInterrupt:SetPoint("LEFT", contentFrame, "TOPRIGHT", -455, -449)
    CreateTooltipTwo(castBarRecolorInterrupt, L["Interrupt_CD_Color"], L["Tooltip_Interrupt_CD_Color_Desc"])

    local castBarRecolorInterruptArenaFrames = CreateCheckbox("castBarRecolorInterruptArenaFrames", L["Arena"], contentFrame, nil, BBF.UpdateInterruptIconSettings)
    castBarRecolorInterruptArenaFrames:SetPoint("LEFT", castBarRecolorInterrupt.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(castBarRecolorInterruptArenaFrames, L["Interrupt_CD_Color_Arena_Frames"], L["Tooltip_Interrupt_CD_Color_Arena_Frames_Desc"])

    local castBarInterruptIconEnabled = CreateCheckbox("castBarInterruptIconEnabled", L["Interrupt_CD_Icon"], contentFrame, nil, BBF.UpdateInterruptIconSettings)
    castBarInterruptIconEnabled:SetPoint("BOTTOMLEFT", castBarRecolorInterrupt, "TOPLEFT", 0, -pixelsBetweenBoxes)
    CreateTooltipTwo(castBarInterruptIconEnabled, L["Interrupt_CD_Icon"], L["Tooltip_Interrupt_CD_Icon_Desc"], L["Tooltip_Interrupt_CD_Icon_Extra"])

    local castBarNoInterruptColor = CreateFrame("Button", nil, castBarRecolorInterrupt, "UIPanelButtonTemplate")
    castBarNoInterruptColor:SetText(L["Interrupt_On_CD"])
    castBarNoInterruptColor:SetPoint("TOPLEFT", castBarRecolorInterrupt, "BOTTOMRIGHT", -35, 3)
    castBarNoInterruptColor:SetSize(139, 20)
    CreateTooltip(castBarNoInterruptColor, L["Tooltip_Interrupt_On_CD"])
    local castBarNoInterruptColorIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    castBarNoInterruptColorIcon:SetAtlas("newplayertutorial-icon-key")
    castBarNoInterruptColorIcon:SetSize(18, 17)
    castBarNoInterruptColorIcon:SetPoint("LEFT", castBarNoInterruptColor, "RIGHT", 0, -1)
    UpdateColorSquare(castBarNoInterruptColorIcon, unpack(BetterBlizzFramesDB["castBarNoInterruptColor"] or {1, 1, 1}))
    castBarNoInterruptColor:SetScript("OnClick", function()
        OpenColorPicker("castBarNoInterruptColor", castBarNoInterruptColorIcon)
    end)

    local castBarDelayedInterruptColor = CreateFrame("Button", nil, castBarRecolorInterrupt, "UIPanelButtonTemplate")
    castBarDelayedInterruptColor:SetText(L["Interrupt_CD_Soon"])
    castBarDelayedInterruptColor:SetPoint("TOPLEFT", castBarNoInterruptColor, "BOTTOMLEFT", 0, -5)
    castBarDelayedInterruptColor:SetSize(139, 20)
    CreateTooltip(castBarDelayedInterruptColor, L["Tooltip_Interrupt_CD_Soon"])
    local castBarDelayedInterruptColorIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    castBarDelayedInterruptColorIcon:SetAtlas("newplayertutorial-icon-key")
    castBarDelayedInterruptColorIcon:SetSize(18, 17)
    castBarDelayedInterruptColorIcon:SetPoint("LEFT", castBarDelayedInterruptColor, "RIGHT", 0, -1)
    UpdateColorSquare(castBarDelayedInterruptColorIcon, unpack(BetterBlizzFramesDB["castBarDelayedInterruptColor"] or {1, 1, 1}))
    castBarDelayedInterruptColor:SetScript("OnClick", function()
        OpenColorPicker("castBarDelayedInterruptColor", castBarDelayedInterruptColorIcon)
    end)


    -- Wrapped: extraFunc is called as (option, value), and CastbarAdjustCaller's first arg is a key.
    local buffsOnTopReverseCastbarMovement = CreateCheckbox("buffsOnTopReverseCastbarMovement", L["Buffs_On_Top_Reverse"], contentFrame, nil, function() BBF.CastbarAdjustCaller() end)
    buffsOnTopReverseCastbarMovement:SetPoint("LEFT", contentFrame, "TOPRIGHT", -470, -517)
    CreateTooltipTwo(buffsOnTopReverseCastbarMovement, L["Buffs_On_Top_Reverse"], L["Tooltip_Buffs_On_Top_Reverse_Desc"])

    local normalCastbarForEmpoweredCasts = CreateCheckbox("normalCastbarForEmpoweredCasts", L["Normal_Evoker_Castbar"], contentFrame, nil, BBF.HookCastbarsForEvoker)
    normalCastbarForEmpoweredCasts:SetPoint("TOPLEFT", buffsOnTopReverseCastbarMovement, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(normalCastbarForEmpoweredCasts, L["Normal_Evoker_Castbar"], L["Tooltip_Normal_Evoker_Castbar_Desc"])
    normalCastbarForEmpoweredCasts:HookScript("OnClick", function(self)
        if BetterBlizzPlatesDB then
            if self:GetChecked() then
                BetterBlizzPlatesDB.normalCastbarForEmpoweredCasts = true
            else
                BetterBlizzPlatesDB.normalCastbarForEmpoweredCasts = false
            end
        end
    end)

    local quickHideCastbars = CreateCheckbox("quickHideCastbars", L["Quick_Hide_Castbars"], contentFrame)
    quickHideCastbars:SetPoint("TOPLEFT", normalCastbarForEmpoweredCasts, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(quickHideCastbars, L["Quick_Hide_Castbars"], L["Tooltip_Quick_Hide_Castbars_Desc"])
    quickHideCastbars:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local castBarTargetText = CreateCheckbox("castBarTargetText", L["Castbar_Target_Text"], contentFrame)
    castBarTargetText:SetPoint("LEFT", quickHideCastbars.text, "RIGHT", 0, 0)
    CreateTooltipTwo(castBarTargetText, L["Castbar_Target_Text"], L["Tooltip_Castbar_Target_Text_Desc"] .. "\n\n|cff32f795" .. L["Right_Click_To_Open_Options"] .. "|r")
    castBarTargetText:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local castBarTargetTextOptionsFrame
    local function OpenCastbarTargetTextOptions()
        if not castBarTargetTextOptionsFrame then
            castBarTargetTextOptionsFrame = CreateFrame("Frame", "BBFCastbarTargetTextOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
            castBarTargetTextOptionsFrame:SetSize(220, 275)
            castBarTargetTextOptionsFrame:SetPoint("CENTER")
            castBarTargetTextOptionsFrame:SetFrameStrata("HIGH")
            castBarTargetTextOptionsFrame:SetMovable(true)
            castBarTargetTextOptionsFrame:EnableMouse(true)
            castBarTargetTextOptionsFrame:RegisterForDrag("LeftButton")
            castBarTargetTextOptionsFrame:SetScript("OnDragStart", castBarTargetTextOptionsFrame.StartMoving)
            castBarTargetTextOptionsFrame:SetScript("OnDragStop", castBarTargetTextOptionsFrame.StopMovingOrSizing)
            castBarTargetTextOptionsFrame.title = castBarTargetTextOptionsFrame:CreateFontString(nil, "OVERLAY")
            castBarTargetTextOptionsFrame.title:SetFontObject("GameFontHighlight")
            castBarTargetTextOptionsFrame.title:SetPoint("LEFT", castBarTargetTextOptionsFrame.TitleBg, "LEFT", 5, 0)
            castBarTargetTextOptionsFrame.title:SetText(L["Castbar_Target_Text_Options"])

            local hideOnNpcs = CreateCheckbox("castBarTargetTextHideOnNpcs", L["Castbar_Target_Text_Hide_Npcs"], castBarTargetTextOptionsFrame, nil, BBF.CastbarTargetTextCaller)
            hideOnNpcs:SetPoint("TOPLEFT", castBarTargetTextOptionsFrame, "TOPLEFT", 10, -26)
            CreateTooltipTwo(hideOnNpcs, L["Castbar_Target_Text_Hide_Npcs"], L["Tooltip_Castbar_Target_Text_Hide_Npcs_Desc"])

            local outsideCastbar = CreateCheckbox("castBarTargetTextOutside", L["Castbar_Target_Text_Outside"], castBarTargetTextOptionsFrame, nil, BBF.CastbarTargetTextCaller)
            outsideCastbar:SetPoint("TOPLEFT", hideOnNpcs, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
            CreateTooltipTwo(outsideCastbar, L["Castbar_Target_Text_Outside"], L["Tooltip_Castbar_Target_Text_Outside_Desc"])

            local targetTextXPos = CreateSlider(outsideCastbar, L["X_Offset"], -100, 100, 1, "castBarTargetTextOutsideXPos", "X", 150)
            targetTextXPos:SetPoint("TOPLEFT", outsideCastbar, "BOTTOMLEFT", 12, -14)

            local targetTextYPos = CreateSlider(outsideCastbar, L["Y_Offset"], -100, 100, 1, "castBarTargetTextOutsideYPos", "Y", 150)
            targetTextYPos:SetPoint("TOPLEFT", targetTextXPos, "BOTTOMLEFT", 0, -17)

            local targetTextSize = CreateSlider(outsideCastbar, L["Size"], 6, 30, 1, "castBarTargetTextOutsideSize", nil, 150)
            targetTextSize:SetPoint("TOPLEFT", targetTextYPos, "BOTTOMLEFT", 0, -17)

            local targetTextAnchor = CreateAnchorDropdown(
                "castBarTargetTextAnchorDropdown",
                castBarTargetTextOptionsFrame,
                L["Select_Anchor_Point"],
                "castBarTargetTextOutsideAnchor",
                function()
                    BBF.CastbarTargetTextCaller()
                end,
                { anchorFrame = targetTextSize, x = -16, y = -40, label = L["Anchor"] }
            )

            local function UpdateTargetTextOptions()
                if outsideCastbar:GetChecked() then
                    EnableElement(targetTextXPos)
                    EnableElement(targetTextYPos)
                    EnableElement(targetTextSize)
                    LibDD:UIDropDownMenu_EnableDropDown(targetTextAnchor)
                else
                    DisableElement(targetTextXPos)
                    DisableElement(targetTextYPos)
                    DisableElement(targetTextSize)
                    LibDD:UIDropDownMenu_DisableDropDown(targetTextAnchor)
                end
            end

            UpdateTargetTextOptions()
            outsideCastbar:HookScript("OnClick", UpdateTargetTextOptions)

            castBarTargetTextOptionsFrame:Show()
        else
            castBarTargetTextOptionsFrame:SetShown(not castBarTargetTextOptionsFrame:IsShown())
        end
    end

    castBarTargetText:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            GameTooltip:Hide()
            OpenCastbarTargetTextOptions()
        end
    end)

    local castBarTargetHighlight = CreateCheckbox("castBarTargetHighlight", L["Castbar_Target_Highlight"], contentFrame)
    castBarTargetHighlight:SetPoint("LEFT", castBarTargetText.text, "RIGHT", 0, 0)
    CreateTooltipTwo(castBarTargetHighlight, L["Castbar_Target_Highlight"], L["Tooltip_Castbar_Target_Highlight_Desc"])
    castBarTargetHighlight:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local classicCastbars = CreateCheckbox("classicCastbars", L["Castbar_Classic"], contentFrame, nil, BBF.ChangeCastbarSizes)
    classicCastbars:SetPoint("TOPLEFT", quickHideCastbars, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classicCastbars, L["Castbar_Classic"], L["Tooltip_Castbar_Classic_Target_Focus_Desc"])
    classicCastbars:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzFramesDB.castbarPixelBorder = nil
        end
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local classicCastbarsModernSpark = CreateCheckbox("classicCastbarsModernSpark", L["Modern_Spark"], contentFrame, nil, BBF.ChangeCastbarSizes)
    classicCastbarsModernSpark:SetPoint("LEFT", classicCastbars.text, "RIGHT", 0, 0)
    CreateTooltipTwo(classicCastbarsModernSpark, L["Modern_Spark"], L["Tooltip_Modern_Spark_Desc"])
    classicCastbarsModernSpark:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local unitframeCastBarNoTextBorder = CreateCheckbox("unitframeCastBarNoTextBorder", L["UnitFrame_Simple_Castbars"], contentFrame, nil, BBF.ChangeCastbarSizes)
    unitframeCastBarNoTextBorder:SetPoint("TOPLEFT", classicCastbars, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(unitframeCastBarNoTextBorder, L["UnitFrame_Simple_Castbars"], L["Tooltip_UnitFrame_Simple_Castbars_Desc"])
    unitframeCastBarNoTextBorder:HookScript("OnClick", function()
        if classicCastbars:GetChecked() then
            BetterBlizzFrames.classicCastbars = nil
            classicCastbars:SetChecked(false)
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
        if anchorSubPartyCastbar.classicCastbarsParty:GetChecked() then
            anchorSubPartyCastbar.classicCastbarsParty:SetChecked(false)
            BetterBlizzFrames.classicCastbarsParty = nil
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local castbarPixelBorder = CreateCheckbox("castbarPixelBorder", L["Pixel_Border_Castbars"], contentFrame, nil, BBF.ChangeCastbarSizes)
    castbarPixelBorder:SetPoint("LEFT", unitframeCastBarNoTextBorder.text, "RIGHT", 0, 0)
    CreateTooltipTwo(castbarPixelBorder, L["Pixel_Border_Castbars"], L["Tooltip_Pixel_Border_Castbars_Desc"])

    local castbarPixelBorderTextInside = CreateCheckbox("castbarPixelBorderTextInside", L["Pixel_Border_Castbars_Text_Inside"], castbarPixelBorder, nil, BBF.ChangeCastbarSizes)
    castbarPixelBorderTextInside:SetPoint("LEFT", castbarPixelBorder.text, "RIGHT", 0, 0)
    CreateTooltipTwo(castbarPixelBorderTextInside, L["Pixel_Border_Castbars_Text_Inside"], L["Tooltip_Pixel_Border_Castbars_Text_Inside_Desc"])

    castbarPixelBorder:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzFramesDB.classicCastbars = nil
            BetterBlizzFramesDB.classicCastbarsPlayer = nil
        end
        EnableElement(castbarPixelBorderTextInside)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)


    classicCastbars:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
            DisableElement(classicCastbarsModernSpark)
        else
            EnableElement(classicCastbarsModernSpark)
        end
        if unitframeCastBarNoTextBorder:GetChecked() then
            BetterBlizzFrames.unitframeCastBarNoTextBorder = nil
            unitframeCastBarNoTextBorder:SetChecked(false)
        end
    end)

    if not BetterBlizzFramesDB.classicCastbars then
        DisableElement(classicCastbarsModernSpark)
    end

    local recolorCastbars = CreateCheckbox("recolorCastbars", L["Recolor_Castbars"], contentFrame)
    recolorCastbars:SetPoint("TOPLEFT", unitframeCastBarNoTextBorder, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(recolorCastbars, L["Recolor_Castbars"], L["Tooltip_Recolor_Castbars_Desc"])

    local castbarCastColor = CreateColorBox(recolorCastbars, "castbarCastColor", L["Cast"], function() BBF.CastbarColorHooks() end)
    castbarCastColor:SetPoint("LEFT", recolorCastbars.text, "RIGHT", 0, 0)

    local castbarChannelColor = CreateColorBox(recolorCastbars, "castbarChannelColor", L["Channel"], function() BBF.CastbarColorHooks() end)
    castbarChannelColor:SetPoint("LEFT", castbarCastColor.text, "RIGHT", 0, 0)

    local castbarUninterruptableColor = CreateColorBox(recolorCastbars, "castbarUninterruptableColor", L["Uninterruptable"], function() BBF.CastbarColorHooks() end)
    castbarUninterruptableColor:SetPoint("LEFT", castbarChannelColor.text, "RIGHT", 0, 0)

    recolorCastbars:HookScript("OnClick", function(self)
        local enable = self:GetChecked() and 1 or 0.5
        castbarCastColor:SetAlpha(enable)
        castbarChannelColor:SetAlpha(enable)
        castbarUninterruptableColor:SetAlpha(enable)
        BBF.CastbarRecolorWidgets()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local raiseTargetCastbarStrata = CreateCheckbox("raiseTargetCastbarStrata", L["Raise_Castbar_Stratas"], contentFrame, nil, BBF.RaiseTargetCastbarStratas)
    raiseTargetCastbarStrata:SetPoint("TOPLEFT", recolorCastbars, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(raiseTargetCastbarStrata, L["Raise_Castbar_Stratas"], L["Tooltip_Raise_Castbar_Strata_Desc"])

    BetterBlizzFramesCastbars.rightClickTip = BetterBlizzFramesCastbars:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    BetterBlizzFramesCastbars.rightClickTip:SetPoint("BOTTOMLEFT", bgImg, "BOTTOM", -231, -36)
    BetterBlizzFramesCastbars.rightClickTip:SetText("|A:smallquestbang:20:20|a" .. L["Right_Click_Slider_Tip"])
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
    BetterBlizzFramesSubPanel.name = L["Module_Name_Advanced"]
    BetterBlizzFramesSubPanel.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(BetterBlizzFramesSubPanel)
    local advancedSubCategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, BetterBlizzFramesSubPanel, BetterBlizzFramesSubPanel.name, BetterBlizzFramesSubPanel.name)
    advancedSubCategory.ID = BetterBlizzFramesSubPanel.name;
    BBF.category.AdvancedSettings = BetterBlizzFramesSubPanel.name
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
    contentFrame.name = BetterBlizzFramesSubPanel.name
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
    anchorFocusTarget:SetText(L["Focus_ToT"])

    CreateBorderBox(anchorFocusTarget)

    local focusTargetFrameIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    focusTargetFrameIcon:SetAtlas("greencross")
    focusTargetFrameIcon:SetSize(32, 32)
    focusTargetFrameIcon:SetPoint("BOTTOM", anchorFocusTarget, "TOP", 0, 0)
    focusTargetFrameIcon:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875)

    local focusToTScale = CreateSlider(contentFrame, L["Size"], 0.1, 1.9, 0.1, "focusToTScale")
    focusToTScale:SetPoint("TOP", anchorFocusTarget, "BOTTOM", 0, -15)

    local focusToTXPos = CreateSlider(contentFrame, L["X_Offset"], -100, 100, 1, "focusToTXPos", "X")
    focusToTXPos:SetPoint("TOP", focusToTScale, "BOTTOM", 0, -15)

    local focusToTYPos = CreateSlider(contentFrame, L["Y_Offset"], -100, 100, 1, "focusToTYPos", "Y")
    focusToTYPos:SetPoint("TOP", focusToTXPos, "BOTTOM", 0, -15)

    local focusToTDropdown = CreateAnchorDropdown(
        "focusToTDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "focusToTAnchor",
        function(arg1) 
            BBF.MoveToTFrames()
        end,
        { anchorFrame = focusToTYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    local combatIndicatorEnemyOnly = CreateCheckbox("combatIndicatorEnemyOnly", L["Enemies_Only"], contentFrame)
    combatIndicatorEnemyOnly:SetPoint("TOPLEFT", focusToTDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)
 
 ]]
 


 --[[
    ----------------------
    -- Pet Frame
    ----------------------
    local anchorPetFrame = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorPetFrame:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, firstLineY)
    anchorPetFrame:SetText(L["Pet_Frame"])

    CreateBorderBox(anchorPetFrame)

    local partyFrameIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    partyFrameIcon:SetAtlas("greencross")
    partyFrameIcon:SetSize(32, 32)
    partyFrameIcon:SetPoint("BOTTOM", anchorPetFrame, "TOP", 0, 0)
    partyFrameIcon:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875)

    local petFrameScale = CreateSlider(contentFrame, L["Size"], 0.1, 1.9, 0.1, "petFrameScale")
    petFrameScale:SetPoint("TOP", anchorPetFrame, "BOTTOM", 0, -15)

    local petFrameXPos = CreateSlider(contentFrame, L["X_Offset"], -100, 100, 1, "petFrameXPos", "X")
    petFrameXPos:SetPoint("TOP", petFrameScale, "BOTTOM", 0, -15)

    local petFrameYPos = CreateSlider(contentFrame, L["Y_Offset"], -100, 100, 1, "petFrameYPos", "Y")
    petFrameYPos:SetPoint("TOP", petFrameXPos, "BOTTOM", 0, -15)

    local petFrameDropdown = CreateAnchorDropdown(
        "petFrameDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "petFrameAnchor",
        function(arg1) 
            BBF.MoveToTFrames()
        end,
        { anchorFrame = petFrameYPos, x = -16, y = -35, label = L["Anchor"] }
    )
 
 ]]
 



   ----------------------
    -- Absorb Indicator
    ----------------------
    local anchorSubAbsorb = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubAbsorb:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX - 30, firstLineY)
    anchorSubAbsorb:SetText(L["Absorb_Indicator"])

    --CreateBorderBox(anchorSubAbsorb)
    CreateBorderedFrame(anchorSubAbsorb, 200, 293, 0, -98, BetterBlizzFramesSubPanel)

    local absorbIndicator = contentFrame:CreateTexture(nil, "ARTWORK")
    absorbIndicator:SetAtlas("ParagonReputation_Glow")
    absorbIndicator:SetSize(56, 56)
    absorbIndicator:SetPoint("BOTTOM", anchorSubAbsorb, "TOP", -1, -10)
    CreateTooltip(absorbIndicator, L["Tooltip_Absorb_Indicator"])

    local absorbIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.1, 1.9, 0.01, "absorbIndicatorScale")
    absorbIndicatorScale:SetPoint("TOP", anchorSubAbsorb, "BOTTOM", 0, -15)

    local absorbIndicatorXPos = CreateSlider(contentFrame, L["X_Offset"], -100, 100, 1, "playerAbsorbXPos", "X")
    absorbIndicatorXPos:SetPoint("TOP", absorbIndicatorScale, "BOTTOM", 0, -15)

    local absorbIndicatorYPos = CreateSlider(contentFrame, L["Y_Offset"], -100, 100, 1, "playerAbsorbYPos", "Y")
    absorbIndicatorYPos:SetPoint("TOP", absorbIndicatorXPos, "BOTTOM", 0, -15)

    local playerAbsorbAnchorDropdown = CreateAnchorDropdown(
        "playerAbsorbAnchorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "playerAbsorbAnchor",
        function(arg1)
        BBF.AbsorbCaller()
    end,
        { anchorFrame = absorbIndicatorYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    local absorbIndicatorTestMode = CreateCheckbox("absorbIndicatorTestMode", L["Test"], contentFrame, nil, BBF.AbsorbCaller)
    absorbIndicatorTestMode:SetPoint("TOPLEFT", playerAbsorbAnchorDropdown, "BOTTOMLEFT", 10, pixelsBetweenBoxes)

    local absorbIndicatorFlipIconText = CreateCheckbox("absorbIndicatorFlipIconText", L["Flip_Icon_Text"], contentFrame, nil, BBF.AbsorbCaller)
    absorbIndicatorFlipIconText:SetPoint("LEFT", absorbIndicatorTestMode.text, "RIGHT", 5, 0)




--[[
    local absorbIndicatorEnemyOnly = CreateCheckbox("absorbIndicatorEnemyOnly", L["Enemy_Only"], contentFrame)
    absorbIndicatorEnemyOnly:SetPoint("TOPLEFT", absorbIndicatorTestMode, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local absorbIndicatorOnPlayersOnly = CreateCheckbox("absorbIndicatorOnPlayersOnly", L["Players_Only"], contentFrame)
    absorbIndicatorOnPlayersOnly:SetPoint("TOPLEFT", absorbIndicatorEnemyOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

]]


    --
    local playerAbsorbAmount = CreateCheckbox("playerAbsorbAmount", L["Player"], contentFrame, nil, BBF.AbsorbCaller)
    playerAbsorbAmount:SetPoint("TOPLEFT", absorbIndicatorTestMode, "BOTTOMLEFT", -5, -14)
    CreateTooltip(playerAbsorbAmount, L["Tooltip_Absorb_Show_Player"])

    local playerAbsorbIcon = CreateCheckbox("playerAbsorbIcon", L["Icon"], contentFrame, nil, BBF.AbsorbCaller)
    playerAbsorbIcon:SetPoint("TOPLEFT", playerAbsorbAmount, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(playerAbsorbIcon, L["Tooltip_Absorb_Icon"])

    local targetAbsorbAmount = CreateCheckbox("targetAbsorbAmount", L["Target"], contentFrame, nil, BBF.AbsorbCaller)
    targetAbsorbAmount:SetPoint("LEFT", playerAbsorbAmount.Text, "RIGHT", 5, 0)
    CreateTooltip(targetAbsorbAmount, L["Tooltip_Absorb_Show_Target"])

    local targetAbsorbIcon = CreateCheckbox("targetAbsorbIcon", L["Icon"], contentFrame, nil, BBF.AbsorbCaller)
    targetAbsorbIcon:SetPoint("TOPLEFT", targetAbsorbAmount, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetAbsorbIcon, L["Tooltip_Absorb_Icon"])

    local focusAbsorbAmount = CreateCheckbox("focusAbsorbAmount", L["Focus"], contentFrame, nil, BBF.AbsorbCaller)
    focusAbsorbAmount:SetPoint("LEFT", targetAbsorbAmount.Text, "RIGHT", 5, 0)
    CreateTooltip(focusAbsorbAmount, L["Tooltip_Absorb_Show_Focus"])

    local focusAbsorbIcon = CreateCheckbox("focusAbsorbIcon", L["Icon"], contentFrame, nil, BBF.AbsorbCaller)
    focusAbsorbIcon:SetPoint("TOPLEFT", focusAbsorbAmount, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusAbsorbIcon, L["Tooltip_Absorb_Icon"])










    --------------------------
    -- Combat indicator
    ----------------------
    local anchorSubOutOfCombat = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubOutOfCombat:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX-145, firstLineY)
    anchorSubOutOfCombat:SetText(L["Combat_Indicator"])

    --CreateBorderBox(anchorSubOutOfCombat)
    CreateBorderedFrame(anchorSubOutOfCombat, 200, 293, 0, -98, BetterBlizzFramesSubPanel)

    local combatIconSub = contentFrame:CreateTexture(nil, "ARTWORK")
    combatIconSub:SetTexture("Interface\\Icons\\ABILITY_DUALWIELD")
    combatIconSub:SetSize(34, 34)
    combatIconSub:SetPoint("BOTTOM", anchorSubOutOfCombat, "TOP", 0, 1)
    CreateTooltip(combatIconSub, L["Tooltip_Combat_Indicator"])

    local combatIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.1, 1.9, 0.01, "combatIndicatorScale")
    combatIndicatorScale:SetPoint("TOP", anchorSubOutOfCombat, "BOTTOM", 0, -15)

    local combatIndicatorXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "combatIndicatorXPos", "X")
    combatIndicatorXPos:SetPoint("TOP", combatIndicatorScale, "BOTTOM", 0, -15)

    local combatIndicatorYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "combatIndicatorYPos", "Y")
    combatIndicatorYPos:SetPoint("TOP", combatIndicatorXPos, "BOTTOM", 0, -15)

    local combatIndicatorDropdown = CreateAnchorDropdown(
        "combatIndicatorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "combatIndicatorAnchor",
        function(arg1)
            BBF.CombatIndicatorCaller()
        end,
        { anchorFrame = combatIndicatorYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    local combatIndicatorArenaOnly = CreateCheckbox("combatIndicatorArenaOnly", L["Arena_Only"], contentFrame)
    combatIndicatorArenaOnly:SetPoint("TOPLEFT", combatIndicatorDropdown, "BOTTOMLEFT", 5, pixelsBetweenBoxes)
    combatIndicatorArenaOnly:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)
    CreateTooltip(combatIndicatorArenaOnly, L["Tooltip_Arena_Only"])

    local combatIndicatorShowSap = CreateCheckbox("combatIndicatorShowSap", L["No_Combat"], contentFrame)
    combatIndicatorShowSap:SetPoint("TOPLEFT", combatIndicatorArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    combatIndicatorShowSap:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)
    CreateTooltip(combatIndicatorShowSap, L["Tooltip_No_Combat"])

    local combatIndicatorShowSwords = CreateCheckbox("combatIndicatorShowSwords", L["In_Combat"], contentFrame)
    combatIndicatorShowSwords:SetPoint("LEFT", combatIndicatorShowSap.Text, "RIGHT", 5, 0)
    combatIndicatorShowSwords:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)
    CreateTooltip(combatIndicatorShowSwords, L["Tooltip_In_Combat"])

    local combatIndicatorPlayersOnly = CreateCheckbox("combatIndicatorPlayersOnly", L["Players_Only"], contentFrame)
    combatIndicatorPlayersOnly:SetPoint("LEFT", combatIndicatorArenaOnly.Text, "RIGHT", 5, 0)
    combatIndicatorPlayersOnly:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)
    CreateTooltip(combatIndicatorPlayersOnly, L["Tooltip_Players_Only"])

    local playerCombatIndicator = CreateCheckbox("playerCombatIndicator", L["Player"], contentFrame)
    playerCombatIndicator:SetPoint("TOPLEFT", combatIndicatorShowSap, "BOTTOMLEFT", -5, -10)
    playerCombatIndicator:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)

    local targetCombatIndicator = CreateCheckbox("targetCombatIndicator", L["Target"], contentFrame)
    targetCombatIndicator:SetPoint("LEFT", playerCombatIndicator.Text, "RIGHT", 5, 0)
    targetCombatIndicator:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)

    local focusCombatIndicator = CreateCheckbox("focusCombatIndicator", L["Focus"], contentFrame)
    focusCombatIndicator:SetPoint("LEFT", targetCombatIndicator.Text, "RIGHT", 5, 0)
    focusCombatIndicator:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)


    --------------------------
    -- Healer Indicator
    ----------------------
    local anchorSubHealerIndicator = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubHealerIndicator:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX+81, firstLineY)
    anchorSubHealerIndicator:SetText(L["Healer_Indicator"])

    --CreateBorderBox(anchorSubHealerIndicator)
    CreateBorderedFrame(anchorSubHealerIndicator, 200, 293, 0, -98, BetterBlizzFramesSubPanel)

    local healerIconSub = contentFrame:CreateTexture(nil, "ARTWORK")
    healerIconSub:SetAtlas("bags-icon-addslots")
    healerIconSub:SetSize(34, 34)
    healerIconSub:SetPoint("BOTTOM", anchorSubHealerIndicator, "TOP", 0, 1)
    CreateTooltip(healerIconSub, L["Tooltip_Healer_Indicator"])

    local healerIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.8, 2.5, 0.01, "healerIndicatorScale")
    healerIndicatorScale:SetPoint("TOP", anchorSubHealerIndicator, "BOTTOM", 0, -15)

    local healerIndicatorXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "healerIndicatorXPos", "X")
    healerIndicatorXPos:SetPoint("TOP", healerIndicatorScale, "BOTTOM", 0, -15)

    local healerIndicatorYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "healerIndicatorYPos", "Y")
    healerIndicatorYPos:SetPoint("TOP", healerIndicatorXPos, "BOTTOM", 0, -15)

    local healerIndicatorDropdown = CreateAnchorDropdown(
        "healerIndicatorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "healerIndicatorAnchor",
        function(arg1)
            BBF.HealerIndicatorCaller()
        end,
        { anchorFrame = healerIndicatorYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    local healerIndicatorIcon = CreateCheckbox("healerIndicatorIcon", L["Icon"], contentFrame)
    healerIndicatorIcon:SetPoint("TOPLEFT", healerIndicatorDropdown, "BOTTOMLEFT", 24, pixelsBetweenBoxes)
    healerIndicatorIcon:HookScript("OnClick", function(self)
        if self:GetChecked() and not BetterBlizzFramesDB.healerIndicator then
            BetterBlizzFramesDB.healerIndicator = true
        end
        BBF.HealerIndicatorCaller()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    CreateTooltip(healerIndicatorIcon, L["Tooltip_Healer_Icon_Show"])

    local healerIndicatorPortrait = CreateCheckbox("healerIndicatorPortrait", L["Portrait"], contentFrame)
    healerIndicatorPortrait:SetPoint("LEFT", healerIndicatorIcon.Text, "RIGHT", 5, 0)
    healerIndicatorPortrait:HookScript("OnClick", function(self)
        if self:GetChecked() and not BetterBlizzFramesDB.healerIndicator then
            BetterBlizzFramesDB.healerIndicator = true
        end
        BBF.HealerIndicatorCaller()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    CreateTooltip(healerIndicatorPortrait, L["Tooltip_Healer_Portrait_Change"])



    --------------------------
    -- Racial indicator
    ----------------------
    local anchorSubracialIndicator = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubracialIndicator:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX-145, secondLineY - 15)
    anchorSubracialIndicator:SetText(L["Racial_Indicator"])

    --CreateBorderBox(anchorSubracialIndicator)
    CreateBorderedFrame(anchorSubracialIndicator, 200, 293, 0, -98, BetterBlizzFramesSubPanel)

    local racialIndicatorIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    racialIndicatorIcon:SetTexture("Interface\\Icons\\ability_ambush")
    racialIndicatorIcon:SetSize(34, 34)
    racialIndicatorIcon:SetPoint("BOTTOM", anchorSubracialIndicator, "TOP", 0, 1)
    CreateTooltip(racialIndicatorIcon, L["Tooltip_Racial_Indicator_Enable"])

    local racialIndicatorScale = CreateSlider(contentFrame, L["Size"], 0.1, 1.9, 0.01, "racialIndicatorScale")
    racialIndicatorScale:SetPoint("TOP", anchorSubracialIndicator, "BOTTOM", 0, -15)

    local racialIndicatorXPos = CreateSlider(contentFrame, L["X_Offset"], -50, 50, 1, "racialIndicatorXPos", "X")
    racialIndicatorXPos:SetPoint("TOP", racialIndicatorScale, "BOTTOM", 0, -15)

    local racialIndicatorYPos = CreateSlider(contentFrame, L["Y_Offset"], -50, 50, 1, "racialIndicatorYPos", "Y")
    racialIndicatorYPos:SetPoint("TOP", racialIndicatorXPos, "BOTTOM", 0, -15)

    local racialIndicatorOrc = CreateCheckbox("racialIndicatorOrc", L["Orc"], contentFrame)
    racialIndicatorOrc:SetPoint("TOPLEFT", racialIndicatorYPos, "BOTTOMLEFT", 5, -5)
    racialIndicatorOrc:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorOrc, L["Tooltip_Show_Orc"])

    local racialIndicatorHuman = CreateCheckbox("racialIndicatorHuman", L["Human"], contentFrame)
    racialIndicatorHuman:SetPoint("TOPLEFT", racialIndicatorOrc, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    racialIndicatorHuman:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorHuman, L["Tooltip_Show_Human"])

    local racialIndicatorDwarf = CreateCheckbox("racialIndicatorDwarf", L["Dwarf"], contentFrame)
    racialIndicatorDwarf:SetPoint("TOPLEFT", racialIndicatorHuman, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    racialIndicatorDwarf:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorDwarf, L["Tooltip_Show_Dwarf"])

    local racialIndicatorNelf = CreateCheckbox("racialIndicatorNelf", L["Night_Elf"], contentFrame)
    racialIndicatorNelf:SetPoint("LEFT", racialIndicatorOrc.Text, "RIGHT", 25, 0)
    racialIndicatorNelf:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorNelf, L["Tooltip_Night_Elf"])

    local racialIndicatorUndead = CreateCheckbox("racialIndicatorUndead", L["Undead"], contentFrame)
    racialIndicatorUndead:SetPoint("TOPLEFT", racialIndicatorNelf, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    racialIndicatorUndead:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorUndead, L["Tooltip_Undead"])

    local racialIndicatorDarkIronDwarf = CreateCheckbox("racialIndicatorDarkIronDwarf", L["DI_Dwarf"], contentFrame)
    racialIndicatorDarkIronDwarf:SetPoint("TOPLEFT", racialIndicatorUndead, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    racialIndicatorDarkIronDwarf:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorDarkIronDwarf, L["Tooltip_DI_Dwarf"])

    local targetRacialIndicator = CreateCheckbox("targetRacialIndicator", L["Target"], contentFrame)
    targetRacialIndicator:SetPoint("TOPLEFT", racialIndicatorDwarf, "BOTTOMLEFT", 0, -10)
    targetRacialIndicator:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(targetRacialIndicator, L["Tooltip_Target"])

    local focusRacialIndicator = CreateCheckbox("focusRacialIndicator", L["Focus"], contentFrame)
    focusRacialIndicator:SetPoint("LEFT", targetRacialIndicator.Text, "RIGHT", 12, 0)
    focusRacialIndicator:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(focusRacialIndicator, L["Tooltip_Focus"])

    local racialIndicatorRaceIcons = CreateCheckbox("racialIndicatorRaceIcons", L["Race_Icon"], contentFrame)
    racialIndicatorRaceIcons:SetPoint("TOPLEFT", targetRacialIndicator, "BOTTOMLEFT", 12, pixelsBetweenBoxes)
    racialIndicatorRaceIcons:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorRaceIcons, L["Tooltip_Race_Icon"])

    ----------------------
    -- Castbar Interrupt Icon
    ----------------------
    local anchorSubInterruptIcon = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubInterruptIcon:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX+81, secondLineY-15)
    anchorSubInterruptIcon:SetText(L["Interrupt_Icon_AS"])

    --CreateBorderBox(anchorSubInterruptIcon)
    CreateBorderedFrame(anchorSubInterruptIcon, 200, 293, 0, -98, BetterBlizzFramesSubPanel)

    local castBarInterruptIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    castBarInterruptIcon:SetTexture("Interface\\Icons\\ability_kick")
    castBarInterruptIcon:SetSize(34, 34)
    castBarInterruptIcon:SetPoint("BOTTOM", anchorSubInterruptIcon, "TOP", 0, 0)
    CreateTooltip(castBarInterruptIcon, L["Show_Interrupt_Icon_Next_Castbar"])

    local castBarInterruptIconScale = CreateSlider(contentFrame, L["Size"], 0.1, 1.9, 0.01, "castBarInterruptIconScale")
    castBarInterruptIconScale:SetPoint("TOP", anchorSubInterruptIcon, "BOTTOM", 0, -15)

    local castBarInterruptIconXPos = CreateSlider(contentFrame, L["X_Offset"], -100, 100, 1, "castBarInterruptIconXPos", "X")
    castBarInterruptIconXPos:SetPoint("TOP", castBarInterruptIconScale, "BOTTOM", 0, -15)

    local castBarInterruptIconYPos = CreateSlider(contentFrame, L["Y_Offset"], -100, 100, 1, "castBarInterruptIconYPos", "Y")
    castBarInterruptIconYPos:SetPoint("TOP", castBarInterruptIconXPos, "BOTTOM", 0, -15)

    local castBarInterruptIconAnchorDropdown = CreateAnchorDropdown(
        "castBarInterruptIconAnchorDropdown",
        contentFrame,
        L["Select_Anchor_Point"],
        "castBarInterruptIconAnchor",
        function(arg1)
        BBF.UpdateInterruptIconSettings()
    end,
        { anchorFrame = castBarInterruptIconYPos, x = -16, y = -35, label = L["Anchor"] }
    )

    local castBarInterruptIconTarget = CreateCheckbox("castBarInterruptIconTarget", L["Target"], contentFrame, nil, BBF.UpdateInterruptIconSettings)
    castBarInterruptIconTarget:SetPoint("TOPLEFT", castBarInterruptIconAnchorDropdown, "BOTTOMLEFT", 24, pixelsBetweenBoxes)
    CreateTooltipTwo(castBarInterruptIconTarget, L["Show_On_Target"])

    local castBarInterruptIconFocus = CreateCheckbox("castBarInterruptIconFocus", L["Focus"], contentFrame, nil, BBF.UpdateInterruptIconSettings)
    castBarInterruptIconFocus:SetPoint("LEFT", castBarInterruptIconTarget.text, "RIGHT", 5, 0)
    CreateTooltipTwo(castBarInterruptIconFocus, L["Show_On_Focus"])

    local castBarInterruptIconShowActiveOnly = CreateCheckbox("castBarInterruptIconShowActiveOnly", L["Tooltip_Only_Show_If_Available_Desc"], contentFrame, nil, BBF.UpdateInterruptIconSettings)
    castBarInterruptIconShowActiveOnly:SetPoint("TOPLEFT", castBarInterruptIconTarget, "BOTTOMLEFT", -28, pixelsBetweenBoxes)
    CreateTooltipTwo(castBarInterruptIconShowActiveOnly, L["Tooltip_Only_Show_If_Available_Desc"], L["Tooltip_Only_Show_Available"])

    local interruptIconBorder = CreateCheckbox("interruptIconBorder", L["Border_Status_Color"], contentFrame, nil, BBF.UpdateInterruptIconSettings)
    interruptIconBorder:SetPoint("TOPLEFT", castBarInterruptIconShowActiveOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(interruptIconBorder, L["Border_Status_Color"], L["Tooltip_Interrupt_Icon_Border_Desc"])

    ----------------------
    -- Kick Popup
    ----------------------
    local anchorSubKickPopup = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubKickPopup:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX - 30, secondLineY - 15)
    anchorSubKickPopup:SetText(L["Kick_Popup"])

    CreateBorderedFrame(anchorSubKickPopup, 200, 293, 0, -98, BetterBlizzFramesSubPanel)

    local kickPopupIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    kickPopupIcon:SetTexture("Interface\\Icons\\ability_kick")
    kickPopupIcon:SetSize(34, 34)
    kickPopupIcon:SetPoint("BOTTOM", anchorSubKickPopup, "TOP", 0, 0)
    CreateTooltip(kickPopupIcon, L["Tooltip_Kick_Popup_Desc"])

    local kickPopupScale = CreateSlider(contentFrame, L["Size"], 0.5, 2, 0.01, "kickPopupScale", nil, 72)
    kickPopupScale:SetPoint("TOP", anchorSubKickPopup, "BOTTOM", -35, -15)

    local kickPopupIconScale = CreateSlider(contentFrame, L["Icon"], 0.5, 2.5, 0.01, "kickPopupIconScale", nil, 72)
    kickPopupIconScale:SetPoint("LEFT", kickPopupScale, "RIGHT", 0, 0)

    local kickPopupXPos = CreateSlider(contentFrame, L["X_Offset"], -500, 500, 1, "kickPopupXPos", "X")
    kickPopupXPos:SetPoint("TOP", kickPopupScale, "BOTTOM", 35, -15)

    local kickPopupYPos = CreateSlider(contentFrame, L["Y_Offset"], -500, 500, 1, "kickPopupYPos", "Y")
    kickPopupYPos:SetPoint("TOP", kickPopupXPos, "BOTTOM", 0, -15)

    local kickPopupFontDropdown = CreateFontDropdown(
        "kickPopupFont",
        contentFrame,
        L["Select_Font"],
        "kickPopupFont",
        function(fontPath)
            BBF.UpdateKickPopupFont()
        end,
        { anchorFrame = kickPopupYPos, x = -12, y = -13, label = L["Font"] },
        125,
        nil,
        "TOP"
    )

    local kickPopupFontOutline = CreateCheckbox("kickPopupFontOutline", L["Outline_Label"], contentFrame)
    kickPopupFontOutline:SetPoint("LEFT", kickPopupFontDropdown, "RIGHT", -2, 8)
    kickPopupFontOutline:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" and self:GetChecked() then
            local current = BetterBlizzFramesDB.kickPopupFontOutline
            if current == "THICKOUTLINE" then
                BetterBlizzFramesDB.kickPopupFontOutline = "OUTLINE"
            else
                BetterBlizzFramesDB.kickPopupFontOutline = "THICKOUTLINE"
            end
            BBF.UpdateKickPopupFont()
        end
    end)
    kickPopupFontOutline:HookScript("OnClick", function()
        BBF.UpdateKickPopupFont()
    end)
    CreateTooltip(kickPopupFontOutline, L["Tooltip_Outline_Toggle"])

    local kickPopupFontShadow = CreateCheckbox("kickPopupFontShadow", L["Shadow"], contentFrame, nil, function()
        BBF.UpdateKickPopupFont()
    end)
    kickPopupFontShadow:SetPoint("TOPLEFT", kickPopupFontOutline, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local kickPopupTestMode = CreateCheckbox("kickPopupTestMode", L["Test"], contentFrame, nil, function()
        BBF.TestKickPopup(BetterBlizzFramesDB.kickPopupTestMode)
    end)
    kickPopupTestMode:SetPoint("TOPLEFT", kickPopupFontDropdown, "BOTTOMLEFT", 26, -2)

    local kickPopupTextColor = CreateColorBox(contentFrame, "kickPopupTextColor", L["Kick_Popup_Text_Color"], function()
        BBF.UpdateKickPopupFont()
    end)
    kickPopupTextColor:SetPoint("LEFT", kickPopupTestMode.text, "RIGHT", 2, 0)

    local kickPopupPlaySound = CreateCheckbox("kickPopupPlaySound", L["Kick_Popup_Play_Sound"], contentFrame)
    kickPopupPlaySound:SetPoint("TOPLEFT", kickPopupTestMode, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(kickPopupPlaySound, L["Tooltip_Kick_Popup_Play_Sound_Desc"])
    kickPopupPlaySound:HookScript("OnClick", function(self)
        if self:GetChecked() then
            local channel = BetterBlizzFramesDB.kickPopupSoundChannel or "Master"
            local soundName = BetterBlizzFramesDB.kickPopupSoundName
            if soundName then
                local path = LSM:Fetch(LSM.MediaType.SOUND, soundName)
                if path then PlaySoundFile(path, channel) end
            end
        end
    end)

    local kickPopupSauce = CreateCheckbox("kickPopupSauce", L["Kick_Popup_Sauce"], contentFrame)
    kickPopupSauce:SetPoint("LEFT", kickPopupPlaySound.text, "RIGHT", 2, 0)
    CreateTooltipTwo(kickPopupSauce, L["Kick_Popup_Add_Sauce"], L["Tooltip_Kick_Popup_Sauce_Desc"])
    kickPopupSauce:HookScript("OnClick", function()
        if BetterBlizzFramesDB.kickPopupTestMode then
            BBF.TestKickPopup(true)
        end
    end)

    local kickPopupSoundNameDropdown = LibDD:Create_UIDropDownMenu("kickPopupSoundNameDropdown", contentFrame)
    BBF.kickPopupSoundNameDropdown = kickPopupSoundNameDropdown
    LibDD:UIDropDownMenu_SetWidth(kickPopupSoundNameDropdown, 65)
    local fileID = BetterBlizzFramesDB.kickPopupSoundFileID
    if fileID and fileID ~= 0 then
        LibDD:UIDropDownMenu_SetText(kickPopupSoundNameDropdown, "ID: " .. fileID)
    else
        LibDD:UIDropDownMenu_SetText(kickPopupSoundNameDropdown, BetterBlizzFramesDB.kickPopupSoundName or "Lossa Countered")
    end
    LibDD:UIDropDownMenu_Initialize(kickPopupSoundNameDropdown, function(self, level, menuList)
        local sounds = LSM:HashTable(LSM.MediaType.SOUND)
        local sorted = {}
        for name in pairs(sounds) do
            table.insert(sorted, name)
        end
        table.sort(sorted)
        for _, soundName in ipairs(sorted) do
            local info = LibDD:UIDropDownMenu_CreateInfo()
            info.text = soundName
            info.arg1 = soundName
            info.func = function(self, arg1)
                BetterBlizzFramesDB.kickPopupSoundName = arg1
                BetterBlizzFramesDB.kickPopupSoundFileID = nil
                LibDD:UIDropDownMenu_SetText(kickPopupSoundNameDropdown, arg1)
                local channel = BetterBlizzFramesDB.kickPopupSoundChannel or "Master"
                local path = LSM:Fetch(LSM.MediaType.SOUND, arg1)
                if path then PlaySoundFile(path, channel) end
            end
            info.checked = (BetterBlizzFramesDB.kickPopupSoundName == soundName)
            LibDD:UIDropDownMenu_AddButton(info)
        end
    end)
    kickPopupSoundNameDropdown:SetPoint("TOPLEFT", kickPopupPlaySound, "BOTTOMLEFT", -42, -14)

    local kickPopupSoundNameLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    kickPopupSoundNameLabel:SetPoint("BOTTOM", kickPopupSoundNameDropdown, "TOP", 0, 3)
    kickPopupSoundNameLabel:SetText(L["Kick_Popup_Sound"])

    local kickPopupSoundRightClick = CreateFrame("Button", nil, kickPopupSoundNameDropdown)
    kickPopupSoundRightClick:SetAllPoints()
    kickPopupSoundRightClick:RegisterForClicks("RightButtonUp")
    kickPopupSoundRightClick:SetScript("OnClick", function()
        StaticPopup_Show("BBF_KICK_POPUP_SOUND_ID")
    end)
    CreateTooltip(kickPopupSoundRightClick, "Right-click to enter a custom Sound ID.")

    local kickPopupSoundChannelDropdown = LibDD:Create_UIDropDownMenu("kickPopupSoundChannelDropdown", contentFrame)
    LibDD:UIDropDownMenu_SetWidth(kickPopupSoundChannelDropdown, 65)
    LibDD:UIDropDownMenu_SetText(kickPopupSoundChannelDropdown, BetterBlizzFramesDB.kickPopupSoundChannel or "Master")
    LibDD:UIDropDownMenu_Initialize(kickPopupSoundChannelDropdown, function(self, level, menuList)
        local channels = {"Master", "SFX", "Music", "Ambience", "Dialog"}
        for _, ch in ipairs(channels) do
            local info = LibDD:UIDropDownMenu_CreateInfo()
            info.text = ch
            info.arg1 = ch
            info.func = function(self, arg1)
                BetterBlizzFramesDB.kickPopupSoundChannel = arg1
                LibDD:UIDropDownMenu_SetText(kickPopupSoundChannelDropdown, arg1)
            end
            info.checked = (BetterBlizzFramesDB.kickPopupSoundChannel == ch)
            LibDD:UIDropDownMenu_AddButton(info)
        end
    end)
    kickPopupSoundChannelDropdown:SetPoint("LEFT", kickPopupSoundNameDropdown, "RIGHT", -35, 0)

    local kickPopupSoundChannelLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    kickPopupSoundChannelLabel:SetPoint("BOTTOM", kickPopupSoundChannelDropdown, "TOP", 0, 3)
    kickPopupSoundChannelLabel:SetText(L["Kick_Popup_Output"])

    local function UpdateKickSoundDropdownState()
        if BetterBlizzFramesDB.kickPopupPlaySound then
            LibDD:UIDropDownMenu_EnableDropDown(kickPopupSoundNameDropdown)
            LibDD:UIDropDownMenu_EnableDropDown(kickPopupSoundChannelDropdown)
            kickPopupSoundNameDropdown:SetAlpha(1)
            kickPopupSoundChannelDropdown:SetAlpha(1)
            kickPopupSoundNameLabel:SetAlpha(1)
            kickPopupSoundChannelLabel:SetAlpha(1)
        else
            LibDD:UIDropDownMenu_DisableDropDown(kickPopupSoundNameDropdown)
            LibDD:UIDropDownMenu_DisableDropDown(kickPopupSoundChannelDropdown)
            kickPopupSoundNameDropdown:SetAlpha(0.5)
            kickPopupSoundChannelDropdown:SetAlpha(0.5)
            kickPopupSoundNameLabel:SetAlpha(0.5)
            kickPopupSoundChannelLabel:SetAlpha(0.5)
        end
    end

    kickPopupPlaySound:HookScript("OnClick", function()
        UpdateKickSoundDropdownState()
    end)

    UpdateKickSoundDropdownState()

    local reloadUiButton2 = CreateFrame("Button", nil, BetterBlizzFramesSubPanel, "UIPanelButtonTemplate")
    reloadUiButton2:SetText(L["Label_Reload_Ui"])
    reloadUiButton2:SetWidth(85)
    reloadUiButton2:SetPoint("TOP", BetterBlizzFramesSubPanel, "BOTTOMRIGHT", -140, -9)
    reloadUiButton2:SetScript("OnClick", function()
        BetterBlizzFramesDB.reopenOptions = true
        ReloadUI()
    end)

    local resetBBFButton = CreateFrame("Button", nil, BetterBlizzFramesSubPanel, "UIPanelButtonTemplate")
    resetBBFButton:SetText(L["Reset_BetterBlizzFrames"])
    resetBBFButton:SetWidth(165)
    resetBBFButton:SetPoint("RIGHT", reloadUiButton2, "LEFT", -533, 0)
    resetBBFButton:SetScript("OnClick", function()
        StaticPopup_Show("CONFIRM_RESET_BETTERBLIZZFRAMESDB")
    end)
    CreateTooltip(resetBBFButton, L["Tooltip_Full_Reset"])

    BetterBlizzFramesSubPanel.rightClickTip = BetterBlizzFramesSubPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    BetterBlizzFramesSubPanel.rightClickTip:SetPoint("RIGHT", reloadUiButton2, "LEFT", -80, -2)
    BetterBlizzFramesSubPanel.rightClickTip:SetText("|A:smallquestbang:20:20|a" .. L["Right_Click_Slider_Tip"])
end

local function guiFrameLook()
    ----------------------
    -- Frame Auras
    ----------------------
    local guiFrameLook = CreateFrame("Frame")
    guiFrameLook.name = L["Module_Name_Font_Texture"]
    guiFrameLook.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(guiFrameAuras)
    local aurasSubCategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, guiFrameLook, guiFrameLook.name, guiFrameLook.name)
    aurasSubCategory.ID = guiFrameLook.name;
    CreateTitle(guiFrameLook)

    local bgImg = guiFrameLook:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiFrameLook, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local scrollFrame = CreateFrame("ScrollFrame", nil, guiFrameLook, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(700, 612)
    scrollFrame:SetPoint("CENTER", guiFrameLook, "CENTER", -20, 3)

    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame.name = guiFrameLook.name
    contentFrame:SetSize(680, 920)
    scrollFrame:SetScrollChild(contentFrame)

    local mainGuiAnchor = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor:SetPoint("TOPLEFT", 50, -25)
    mainGuiAnchor:SetText(" ")

    local settingsText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, 30)
    settingsText:SetText(L["Font_And_Texture_WIP"])
    local generalSettingsIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    generalSettingsIcon:SetAtlas("optionsicon-brown")
    generalSettingsIcon:SetSize(22, 22)
    generalSettingsIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)

    local howToImport = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    howToImport:SetFont(fontLarge, 16)
    howToImport:SetPoint("CENTER", mainGuiAnchor, "BOTTOMLEFT", 415, -355)
    howToImport:SetText(L["How_To_Import"])

    local howStepOne = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    howStepOne:SetJustifyH("LEFT")
    howStepOne:SetFont(fontSmall, 12)
    howStepOne:SetPoint("TOPLEFT", howToImport, "BOTTOMLEFT", -20, -10)
    howStepOne:SetText(L["How_Custom_Media"])

    local fontEditBox = CreateFrame("EditBox", nil, contentFrame, "InputBoxTemplate")
    fontEditBox:SetSize(330, 20)
    fontEditBox:SetPoint("TOPLEFT", howStepOne, "BOTTOMLEFT", 5, -5)
    fontEditBox:SetAutoFocus(false)
    fontEditBox:SetText("BBF.AddFont(\"MyFontName\")")
    fontEditBox:HighlightText()
    fontEditBox:SetCursorPosition(0)
    fontEditBox:SetScript("OnTextChanged", function(self)
        fontEditBox:SetText("BBF.AddFont(\"MyFontName\")")
    end)
    fontEditBox:SetScript("OnMouseUp", function(self)
        self:SetFocus()
        self:HighlightText()
    end)

    local howStepTwo = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    howStepTwo:SetJustifyH("LEFT")
    howStepTwo:SetFont(fontSmall, 12)
    howStepTwo:SetPoint("TOPLEFT", fontEditBox, "BOTTOMLEFT", -5, -13)
    howStepTwo:SetText(L["How_Custom_Media_2"])

    local textureEditBox = CreateFrame("EditBox", nil, contentFrame, "InputBoxTemplate")
    textureEditBox:SetSize(330, 20)
    textureEditBox:SetPoint("TOPLEFT", howStepTwo, "BOTTOMLEFT", 5, -5)
    textureEditBox:SetAutoFocus(false)
    textureEditBox:SetText("BBF.AddTexture(\"MyTextureName\")")
    textureEditBox:HighlightText()
    textureEditBox:SetCursorPosition(0)
    textureEditBox:SetScript("OnTextChanged", function(self)
        textureEditBox:SetText("BBF.AddTexture(\"MyTextureName\")")
    end)
    textureEditBox:SetScript("OnMouseUp", function(self)
        self:SetFocus()
        self:HighlightText()
    end)

    local howStepThree = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    howStepThree:SetJustifyH("LEFT")
    howStepThree:SetFont(fontSmall, 12)
    howStepThree:SetPoint("TOPLEFT", textureEditBox, "BOTTOMLEFT", -5, -13)
    howStepThree:SetText(L["How_Custom_Media_3"])
    howStepThree:SetWidth(330)

    local changeUnitFrameFont = CreateCheckbox("changeUnitFrameFont", L["Tooltip_Change_UnitFrame_Font_Desc"], contentFrame)
    changeUnitFrameFont:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltipTwo(changeUnitFrameFont, L["Tooltip_Change_UnitFrame_Font_Desc"], L["Tooltip_Change_UnitFrame_Font_Etc_Desc"])

    local unitFrameFontColor = CreateCheckbox("unitFrameFontColor", L["Color"], contentFrame)
    unitFrameFontColor:SetPoint("LEFT", changeUnitFrameFont.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(unitFrameFontColor, L["Color"], L["Tooltip_Color_Change_Font_Desc"])
    unitFrameFontColor:HookScript("OnClick", function()
        BBF.FontColors()
    end)
    unitFrameFontColor:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenColorOptions(BetterBlizzFramesDB.unitFrameFontColorRGB,  BBF.FontColors)
        end
    end)

    local unitFrameFontColorLvl = CreateCheckbox("unitFrameFontColorLvl", L["FontTexture_Color_Level"], contentFrame)
    unitFrameFontColorLvl:SetPoint("LEFT", unitFrameFontColor.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(unitFrameFontColorLvl, L["FontTexture_Color_Level"], L["Tooltip_Color_Level_Font_Desc"])
    unitFrameFontColorLvl:HookScript("OnClick", function()
        BBF.FontColors()
    end)

    local unitFrameFont = CreateFontDropdown(
        "unitFrameFont",
        contentFrame,
        L["Select_Font"],
        "unitFrameFont",
        function(arg1)
            BBF.SetCustomFonts()
        end,
        { anchorFrame = changeUnitFrameFont, x = 55, y = 1, label = L["Font"] }
    )

    -- For font outline
    local unitFrameFontOutline = CreateSimpleDropdown("FontOutlineDropdown", contentFrame, L["Outline_Label"], "unitFrameFontOutline", {
        "THICKOUTLINE", "OUTLINE", ""
    }, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = unitFrameFont, x = 0, y = -5 }, 155)

    -- For font size
    local fontSizeOptions = {}
    for i = 6, 24 do
        table.insert(fontSizeOptions, tostring(i))
    end

    local unitFrameFontSize = CreateSimpleDropdown("FontSizeDropdown", contentFrame, L["Size"], "unitFrameFontSize", fontSizeOptions, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = unitFrameFontOutline, x = 0, y = -5 }, 155)

    changeUnitFrameFont:HookScript("OnClick", function(self)
        BBF.SetCustomFonts()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
            unitFrameFont:Disable()
            unitFrameFontOutline:Disable()
            unitFrameFontSize:Disable()
        else
            unitFrameFont:Enable()
            unitFrameFontOutline:Enable()
            unitFrameFontSize:Enable()
        end
    end)

    if not changeUnitFrameFont:GetChecked() then
        unitFrameFont:Disable()
        unitFrameFontOutline:Disable()
        unitFrameFontSize:Disable()
    end





    local changeUnitFrameValueFont = CreateCheckbox("changeUnitFrameValueFont", L["Tooltip_Change_UnitFrame_Number_Font_Desc"], contentFrame)
    changeUnitFrameValueFont:SetPoint("TOPLEFT", changeUnitFrameFont, "BOTTOMLEFT", 0, -100)
    CreateTooltipTwo(changeUnitFrameValueFont, L["Tooltip_Change_UnitFrame_Number_Font_Desc"], L["Tooltip_Change_UnitFrame_Number_Font_Etc_Desc"])

    local unitFrameValueFontColor = CreateCheckbox("unitFrameValueFontColor", L["Color"], contentFrame)
    unitFrameValueFontColor:SetPoint("LEFT", changeUnitFrameValueFont.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(unitFrameValueFontColor, L["UnitFrame_Numbers_Font_Color"], L["Tooltip_UnitFrame_Numbers_Font_Color_Desc"])
    unitFrameValueFontColor:HookScript("OnClick", function()
        BBF.FontColors()
    end)
    unitFrameValueFontColor:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenColorOptions(BetterBlizzFramesDB.unitFrameValueFontColorRGB,  BBF.FontColors)
        end
    end)

    local unitFrameValueFont = CreateFontDropdown(
        "unitFrameValueFont",
        contentFrame,
        L["Select_Font"],
        "unitFrameValueFont",
        function(arg1)
            BBF.SetCustomFonts()
        end,
        { anchorFrame = changeUnitFrameValueFont, x = 55, y = 1, label = L["Font"] }
    )

    -- For font outline
    local unitFrameValueFontOutline = CreateSimpleDropdown("FontOutlineDropdown", contentFrame, L["Outline_Label"], "unitFrameValueFontOutline", {
        "THICKOUTLINE", "OUTLINE", ""
    }, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = unitFrameValueFont, x = 0, y = -5 }, 155)

    local unitFrameValueFontSize = CreateSimpleDropdown("FontSizeDropdown", contentFrame, L["Size"], "unitFrameValueFontSize", fontSizeOptions, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = unitFrameValueFontOutline, x = 0, y = -5 }, 155)

    changeUnitFrameValueFont:HookScript("OnClick", function(self)
        BBF.SetCustomFonts()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
            unitFrameValueFont:Disable()
            unitFrameValueFontOutline:Disable()
            unitFrameValueFontSize:Disable()
        else
            unitFrameValueFont:Enable()
            unitFrameValueFontOutline:Enable()
            unitFrameValueFontSize:Enable()
        end
    end)

    if not changeUnitFrameValueFont:GetChecked() then
        unitFrameValueFont:Disable()
        unitFrameValueFontOutline:Disable()
        unitFrameValueFontSize:Disable()
    end





    local changePartyFrameFont = CreateCheckbox("changePartyFrameFont", L["Change_Party_Font"], contentFrame)
    changePartyFrameFont:SetPoint("TOPLEFT", changeUnitFrameValueFont, "BOTTOMLEFT", 0, -100)
    CreateTooltipTwo(changePartyFrameFont, L["Change_Party_Font"], L["Tooltip_Change_PartyFrames_Font_Desc"])

    local partyFrameFontColor = CreateCheckbox("partyFrameFontColor", L["Color"], contentFrame)
    partyFrameFontColor:SetPoint("LEFT", changePartyFrameFont.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(partyFrameFontColor, L["Color"], L["Tooltip_Change_Party_Font_Color_Desc"])
    partyFrameFontColor:HookScript("OnClick", function()
        BBF.FontColors()
    end)
    partyFrameFontColor:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenColorOptions(BetterBlizzFramesDB.partyFrameFontColorRGB,  BBF.FontColors)
        end
    end)

    local partyFrameFont = CreateFontDropdown(
        "partyFrameFont",
        contentFrame,
        L["Select_Font"],
        "partyFrameFont",
        function(arg1)
            BBF.SetCustomFonts()
        end,
        { anchorFrame = changePartyFrameFont, x = 55, y = 1, label = L["Font"] }
    )

    -- For font outline
    local partyFrameFontOutline = CreateSimpleDropdown("FontOutlineDropdown", contentFrame, L["Outline_Label"], "partyFrameFontOutline", {
        "THICKOUTLINE", "OUTLINE", ""
    }, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = partyFrameFont, x = 0, y = -5 }, 155)

    local partyFrameFontSize = CreateSimpleDropdown("FontSizeDropdown", contentFrame, L["Size"], "partyFrameFontSize", fontSizeOptions, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = partyFrameFontOutline, x = 0, y = -5 }, 77.5)
    CreateTooltipTwo(partyFrameFontSize, L["Tooltip_Name_Size"])

    local partyFrameStatusFontSize = CreateSimpleDropdown("FontSizeDropdown", contentFrame, "", "partyFrameStatusFontSize", fontSizeOptions, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = partyFrameFontSize, x = 77.5, y = 25 }, 77.5)
    CreateTooltipTwo(partyFrameStatusFontSize, L["Tooltip_Status_Text_Size"])

    changePartyFrameFont:HookScript("OnClick", function(self)
        BBF.SetCustomFonts()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
            partyFrameFont:Disable()
            partyFrameFontOutline:Disable()
            partyFrameFontSize:Disable()
            partyFrameStatusFontSize:Disable()
        else
            partyFrameFont:Enable()
            partyFrameFontOutline:Enable()
            partyFrameFontSize:Enable()
            partyFrameStatusFontSize:Enable()
        end
    end)

    if not changePartyFrameFont:GetChecked() then
        partyFrameFont:Disable()
        partyFrameFontOutline:Disable()
        partyFrameFontSize:Disable()
        partyFrameStatusFontSize:Disable()
    end


    local changeActionBarFont = CreateCheckbox("changeActionBarFont", L["Change_ActionBar_Font"], contentFrame)
    changeActionBarFont:SetPoint("TOPLEFT", changePartyFrameFont, "BOTTOMLEFT", 0, -100)
    CreateTooltipTwo(changeActionBarFont, L["Change_ActionBar_Font"], L["Tooltip_Change_ActionBar_Font_Etc_Desc"])

    local actionBarFontColor = CreateCheckbox("actionBarFontColor", L["Color"], contentFrame)
    actionBarFontColor:SetPoint("LEFT", changeActionBarFont.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(actionBarFontColor, L["Color"], L["Tooltip_Change_ActionBar_Font_Color_Desc"])
    actionBarFontColor:HookScript("OnClick", function()
        BBF.FontColors()
    end)
    actionBarFontColor:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            OpenColorOptions(BetterBlizzFramesDB.actionBarFontColorRGB,  BBF.FontColors)
        end
    end)

    local actionBarChangeCharge = CreateCheckbox("actionBarChangeCharge", L["Charges"], contentFrame)
    actionBarChangeCharge:SetPoint("LEFT", actionBarFontColor.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(actionBarChangeCharge, L["Charges"], L["Tooltip_Charges_Font_Desc"])

    local actionBarFont = CreateFontDropdown(
        "actionBarFont",
        contentFrame,
        L["Select_Font"],
        "actionBarFont",
        function(arg1)
            BBF.SetCustomFonts()
        end,
        { anchorFrame = changeActionBarFont, x = 55, y = 1, label = L["Font"] }
    )

    -- For font outline
    local actionBarFontOutline = CreateSimpleDropdown("FontOutlineDropdown", contentFrame, L["Outline_Label"], "actionBarFontOutline", {
        "THICKOUTLINE", "OUTLINE", ""
    }, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = actionBarFont, x = 0, y = -5 }, 77.5)
    CreateTooltipTwo(actionBarFontOutline, L["Tooltip_Macro_Text_Outline"])

    local actionBarKeyFontOutline = CreateSimpleDropdown("FontOutlineDropdown", contentFrame, "", "actionBarKeyFontOutline", {
        "THICKOUTLINE", "OUTLINE", ""
    }, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = actionBarFontOutline, x = 77.5, y = 25 }, 77.5)
    CreateTooltipTwo(actionBarKeyFontOutline, L["Tooltip_Keybinding_Text_Outline"])

    local actionBarFontSize = CreateSimpleDropdown("FontSizeDropdown", contentFrame, L["Size"], "actionBarFontSize", fontSizeOptions, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = actionBarFontOutline, x = 0, y = -5 }, 77.5)
    CreateTooltipTwo(actionBarFontSize, L["Tooltip_Macro_Text_Size"])

    local actionBarKeyFontSize = CreateSimpleDropdown("FontSizeDropdown", contentFrame, "", "actionBarKeyFontSize", fontSizeOptions, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = actionBarFontSize, x = 77.5, y = 25 }, 77.5)
    CreateTooltipTwo(actionBarKeyFontSize, L["Tooltip_Keybinding_Text_Size"])

    local actionBarChargeFontSize = CreateSimpleDropdown("FontSizeDropdown", contentFrame, "", "actionBarChargeFontSize", fontSizeOptions, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = actionBarFontSize, x = 77.5, y = 0 }, 77.5)
    CreateTooltipTwo(actionBarChargeFontSize, L["Tooltip_Charge_Text_Size"])

    local function ToggleDropdowns(enable)
        for _, dd in ipairs({
            actionBarFont,
            actionBarFontOutline,
            actionBarKeyFontOutline,
            actionBarFontSize,
            actionBarKeyFontSize
        }) do
            dd:SetEnabled(enable)
        end
        actionBarChargeFontSize:SetEnabled(enable and actionBarChangeCharge:GetChecked())
    end

    changeActionBarFont:HookScript("OnClick", function(self)
        BBF.SetCustomFonts()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
        ToggleDropdowns(self:GetChecked())
    end)

    actionBarChangeCharge:HookScript("OnClick", function(self)
        BBF.FontColors()
        actionBarChargeFontSize:SetEnabled(changeActionBarFont:GetChecked() and self:GetChecked())
    end)

    ToggleDropdowns(changeActionBarFont:GetChecked())










    local changeAllFontsIngame = CreateCheckbox("changeAllFontsIngame", L["Tooltip_One_Font_All_Text_Desc"], contentFrame)
    changeAllFontsIngame:SetPoint("TOPLEFT", changeActionBarFont, "BOTTOMLEFT", 0, -110)
    CreateTooltipTwo(changeAllFontsIngame, L["Tooltip_One_Font_All_Text_Desc"], L["Tooltip_One_Font"], L["Tooltip_One_Font_All_Text_Extra"])

    local allIngameFont = CreateFontDropdown(
        "allIngameFont",
        contentFrame,
        L["Select_Font"],
        "allIngameFont",
        function(arg1)
            BBF.SetCustomFonts()
        end,
        { anchorFrame = changeAllFontsIngame, x = 55, y = 1, label = L["Font"] }
    )

    changeAllFontsIngame:HookScript("OnClick", function(self)
        BBF.SetCustomFonts()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
        allIngameFont:SetEnabled(self:GetChecked())
    end)
    allIngameFont:SetEnabled(changeAllFontsIngame:GetChecked())







    local changeUnitFrameHealthbarTexture = CreateCheckbox("changeUnitFrameHealthbarTexture", L["Tooltip_Change_UnitFrame_Healthbar_Texture_Desc"], contentFrame)
    changeUnitFrameHealthbarTexture:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", 260, pixelsOnFirstBox)
    if not BetterBlizzFramesDB.classicFrames then
        CreateTooltipTwo(changeUnitFrameHealthbarTexture, L["Tooltip_Change_UnitFrame_Healthbar_Texture_Desc"], L["Tooltip_Healthbar_Texture"])
    else
        CreateTooltipTwo(changeUnitFrameHealthbarTexture, L["Tooltip_Change_UnitFrame_Healthbar_Texture_Desc"], L["Tooltip_Change_UnitFrame_Healthbar_Texture_RightClick_Desc"])
            changeUnitFrameHealthbarTexture:HookScript("OnMouseDown", function(self, button)
            if button == "RightButton" then
                if not BetterBlizzFramesDB.changeUnitFrameHealthbarTextureRepColor then
                    BetterBlizzFramesDB.changeUnitFrameHealthbarTextureRepColor = true
                else
                    BetterBlizzFramesDB.changeUnitFrameHealthbarTextureRepColor = nil
                end
                local function retexture(tex)
                    if not tex then return end
                    tex:SetTexture((BetterBlizzFramesDB.changeUnitFrameHealthbarTextureRepColor and LSM:Fetch(LSM.MediaType.STATUSBAR, BetterBlizzFramesDB.unitFrameHealthbarTexture) or "Interface\\TargetingFrame\\UI-TargetingFrame-LevelBackground"))
                end
                retexture(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ReputationColor)
                retexture(TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor)
                retexture(FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor)
            end
        end)
    end

    if BetterBlizzFramesDB.classicFrames then
        local text = contentFrame:CreateFontString(nil, "OVERLAY")
        text:SetFont(fontSmall, 12)
        text:SetText(L["Classic_Frames_Label"])
        text:SetTextColor(1,0,0)
        CreateTooltipTwo(text, L["Classic_Frames_Healthbar"], L["Tooltip_Classic_Frames_Healthbar_Desc"], nil, "ANCHOR_BOTTOMRIGHT")
        text:SetPoint("LEFT", changeUnitFrameHealthbarTexture.Text, "RIGHT", 5, 0)
    end

    local unitFrameHealthbarTexture = CreateTextureDropdown(
        "unitFrameHealthbarTexture",
        contentFrame,
        L["Select_Texture"],
        "unitFrameHealthbarTexture",
        function(arg1)
            BBF.UpdateCustomTextures()
        end,
        { anchorFrame = changeUnitFrameHealthbarTexture, x = 5, y = 3, label = "Texture" }
    )

    changeUnitFrameHealthbarTexture:HookScript("OnClick", function(self)
        unitFrameHealthbarTexture:SetEnabled(self:GetChecked())
        BBF.UpdateCustomTextures()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    unitFrameHealthbarTexture:SetEnabled(changeUnitFrameHealthbarTexture:GetChecked())

    local changeUnitFrameManabarTexture = CreateCheckbox("changeUnitFrameManabarTexture", L["Tooltip_Change_UnitFrame_Manabar_Texture_Desc"], contentFrame)
    changeUnitFrameManabarTexture:SetPoint("TOPLEFT", changeUnitFrameHealthbarTexture, "BOTTOMLEFT", 0, -25)
    CreateTooltipTwo(changeUnitFrameManabarTexture, L["Tooltip_Change_UnitFrame_Manabar_Texture_Desc"], L["Tooltip_Manabar_Texture"])

    local changeUnitFrameManaBarTextureKeepFancy = CreateCheckbox("changeUnitFrameManaBarTextureKeepFancy", L["Keep_Fancy_Manabars"], changeUnitFrameManabarTexture)
    changeUnitFrameManaBarTextureKeepFancy:SetPoint("LEFT", changeUnitFrameManabarTexture.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(changeUnitFrameManaBarTextureKeepFancy, L["Keep_Fancy_Manabars"], L["Tooltip_Keep_Fancy_Manabars_Desc"])
    changeUnitFrameManaBarTextureKeepFancy:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local unitFrameManabarTexture = CreateTextureDropdown(
        "unitFrameManabarTexture",
        contentFrame,
        L["Select_Texture"],
        "unitFrameManabarTexture",
        function(arg1)
            BBF.UpdateCustomTextures()
        end,
        { anchorFrame = changeUnitFrameManabarTexture, x = 5, y = 3, label = "Texture" }
    )
    changeUnitFrameManabarTexture:HookScript("OnClick", function(self)
        unitFrameManabarTexture:SetEnabled(self:GetChecked())
        BBF.UpdateCustomTextures()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
        CheckAndToggleCheckboxes(self)
    end)
    unitFrameManabarTexture:SetEnabled(changeUnitFrameManabarTexture:GetChecked())

    if BetterBlizzFramesDB.classicFrames then

        local changeUnitFrameNameBgTexture = CreateCheckbox("changeUnitFrameNameBgTexture", L["Change_Name_Bg_Texture"], contentFrame)
        changeUnitFrameNameBgTexture:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", 465, -23)
        CreateTooltipTwo(changeUnitFrameNameBgTexture, L["Change_Name_Bg_Texture"], L["Tooltip_Change_Name_Bg_Texture_Desc"])

        local unitFrameNameBgTexture = CreateTextureDropdown(
            "unitFrameNameBgTexture",
            contentFrame,
            L["Select_Texture"],
            "unitFrameNameBgTexture",
            function(arg1)
                BBF.UpdateCustomTextures()
            end,
            { anchorFrame = changeUnitFrameNameBgTexture, x = 5, y = 3, label = "Texture" }
        )
        changeUnitFrameNameBgTexture:HookScript("OnClick", function(self)
            unitFrameNameBgTexture:SetEnabled(self:GetChecked())
            BBF.UpdateCustomTextures()
            if not self:GetChecked() then
                StaticPopup_Show("BBF_CONFIRM_RELOAD")
            end
        end)
        unitFrameNameBgTexture:SetEnabled(changeUnitFrameNameBgTexture:GetChecked())
    end

    local changeUnitFrameCastbarTexture = CreateCheckbox("changeUnitFrameCastbarTexture", L["Change_Castbar_Texture"], contentFrame)
    changeUnitFrameCastbarTexture:SetPoint("TOPLEFT", changeUnitFrameManabarTexture, "BOTTOMLEFT", 0, -25)
    CreateTooltipTwo(changeUnitFrameCastbarTexture, L["Change_Castbar_Texture"], L["Tooltip_Change_Castbar_Texture_Desc"])

    local unitFrameCastbarTexture = CreateTextureDropdown(
        "unitFrameCastbarTexture",
        contentFrame,
        L["Select_Texture"],
        "unitFrameCastbarTexture",
        function(arg1)
            BBF.UpdateCustomTextures()
        end,
        { anchorFrame = changeUnitFrameCastbarTexture, x = 5, y = 3, label = "Texture" }
    )
    changeUnitFrameCastbarTexture:HookScript("OnClick", function(self)
        unitFrameCastbarTexture:SetEnabled(self:GetChecked())
        BBF.UpdateCustomTextures()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    unitFrameCastbarTexture:SetEnabled(changeUnitFrameCastbarTexture:GetChecked())

    local changeUnitFrameBackgroundTexture = CreateCheckbox("addUnitFrameBgTexture", L["Change_UnitFrame_Background_Texture"], contentFrame)
    changeUnitFrameBackgroundTexture:SetPoint("TOPLEFT", changeUnitFrameCastbarTexture, "BOTTOMLEFT", 0, -25)
    CreateTooltipTwo(changeUnitFrameBackgroundTexture, L["Change_UnitFrame_Background_Texture"], L["Tooltip_Change_UnitFrame_Background_Texture_Desc"])

    local unitFrameBgTexture = CreateTextureDropdown(
        "unitFrameBgTexture",
        contentFrame,
        L["Select_Texture"],
        "unitFrameBgTexture",
        function(arg1)
            BBF.UpdateCustomTextures()
            BBF.UnitFrameBackgroundTexture()
        end,
        { anchorFrame = changeUnitFrameBackgroundTexture, x = 5, y = 3, label = "Texture" }
    )

    local unitFrameBgTextureColorFL = CreateColorBox(contentFrame, "unitFrameBgTextureColor", "Health BG", function() BBF.UnitFrameBackgroundTexture() end)
    unitFrameBgTextureColorFL:SetPoint("LEFT", unitFrameBgTexture, "RIGHT", 10, 0)
    CreateTooltipTwo(unitFrameBgTextureColorFL, "Health Bar Background Color", "Left-click to change.\n\n|cff32f795Shift+Right-click to reset to default.|r")

    local unitFrameBgTextureManaColorFL = CreateColorBox(contentFrame, "unitFrameBgTextureManaColor", "Mana BG", function() BBF.UnitFrameBackgroundTexture() end)
    unitFrameBgTextureManaColorFL:SetPoint("LEFT", unitFrameBgTextureColorFL.text, "RIGHT", 4, 0)
    CreateTooltipTwo(unitFrameBgTextureManaColorFL, "Mana Bar Background Color", "Left-click to change.\n\n|cff32f795Shift+Right-click to reset to default.|r")

    changeUnitFrameBackgroundTexture:HookScript("OnClick", function(self)
        local alpha = self:GetChecked() and 1 or 0.5
        unitFrameBgTextureColorFL:SetAlpha(alpha)
        unitFrameBgTextureManaColorFL:SetAlpha(alpha)
        unitFrameBgTexture:SetEnabled(self:GetChecked())
        BBF.UpdateCustomTextures()
        BBF.UnitFrameBackgroundTexture()
        BBF.UpdateFrames()
        
        if BBF.addUnitFrameBgTexture then
            BBF.addUnitFrameBgTexture:SetChecked(self:GetChecked())
            if BBF.addUnitFrameBgTexture.parent then
                local clrFx = BBF.addUnitFrameBgTexture.parent
                if clrFx.unitFrameBgTextureColor then
                    clrFx.unitFrameBgTextureColor:SetAlpha(alpha)
                end
                if clrFx.unitFrameBgTextureManaColor then
                    clrFx.unitFrameBgTextureManaColor:SetAlpha(alpha)
                end
                if clrFx.unitFrameBgTexture then
                    clrFx.unitFrameBgTexture:SetEnabled(self:GetChecked())
                end
            end
        end
        
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    BBF.changeUnitFrameBackgroundColorTexture = changeUnitFrameBackgroundTexture
    BBF.unitFrameBgTextureDropdown = unitFrameBgTexture
    unitFrameBgTexture:SetEnabled(changeUnitFrameBackgroundTexture:GetChecked())
    local unitFrameBgAlpha = changeUnitFrameBackgroundTexture:GetChecked() and 1 or 0.5
    unitFrameBgTextureColorFL:SetAlpha(unitFrameBgAlpha)
    unitFrameBgTextureManaColorFL:SetAlpha(unitFrameBgAlpha)

    local changeRaidFrameHealthbarTexture = CreateCheckbox("changeRaidFrameHealthbarTexture", L["Tooltip_Change_RaidFrame_Healthbar_Texture_Desc"], contentFrame)
    changeRaidFrameHealthbarTexture:SetPoint("TOPLEFT", changeUnitFrameBackgroundTexture, "BOTTOMLEFT", 0, -40)
    CreateTooltipTwo(changeRaidFrameHealthbarTexture, L["Tooltip_Change_RaidFrame_Healthbar_Texture_Desc"], L["Tooltip_Change_RaidFrame_Healthbar_Texture_Etc_Desc"])

    local raidFrameHealthbarTexture = CreateTextureDropdown(
        "raidFrameHealthbarTexture",
        contentFrame,
        L["Select_Texture"],
        "raidFrameHealthbarTexture",
        function(arg1)
            BBF.UpdateCustomTextures()
        end,
        { anchorFrame = changeRaidFrameHealthbarTexture, x = 5, y = 3, label = "Texture" }
    )

    changeRaidFrameHealthbarTexture:HookScript("OnClick", function(self)
        raidFrameHealthbarTexture:SetEnabled(self:GetChecked())
        BBF.UpdateCustomTextures()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    raidFrameHealthbarTexture:SetEnabled(changeRaidFrameHealthbarTexture:GetChecked())

    local changeRaidFrameManabarTexture = CreateCheckbox("changeRaidFrameManabarTexture", L["Tooltip_Change_RaidFrame_Manabar_Texture_Desc"], contentFrame)
    changeRaidFrameManabarTexture:SetPoint("TOPLEFT", changeRaidFrameHealthbarTexture, "BOTTOMLEFT", 0, -25)
    CreateTooltipTwo(changeRaidFrameManabarTexture, L["Tooltip_Change_RaidFrame_Manabar_Texture_Desc"], L["Tooltip_Change_RaidFrame_Manabar_Texture_Etc_Desc"])

    local raidFrameManabarTexture = CreateTextureDropdown(
        "raidFrameManabarTexture",
        contentFrame,
        L["Select_Texture"],
        "raidFrameManabarTexture",
        function(arg1)
            BBF.UpdateCustomTextures()
        end,
        { anchorFrame = changeRaidFrameManabarTexture, x = 5, y = 3, label = "Texture" }
    )

    changeRaidFrameManabarTexture:HookScript("OnClick", function(self)
        raidFrameManabarTexture:SetEnabled(self:GetChecked())
        BBF.UpdateCustomTextures()
    end)
    raidFrameManabarTexture:SetEnabled(changeRaidFrameManabarTexture:GetChecked())


    local changePartyRaidFrameBackgroundColor = CreateCheckbox("changePartyRaidFrameBackgroundColor", L["Change_RaidFrame_Background_Texture"], contentFrame)
    changePartyRaidFrameBackgroundColor:SetPoint("TOPLEFT", changeRaidFrameManabarTexture, "BOTTOMLEFT", 0, -25)
    CreateTooltipTwo(changePartyRaidFrameBackgroundColor, L["Change_RaidFrame_Background_Texture"], L["Tooltip_Change_RaidFrame_Background_Texture_Desc"])

    local raidFrameBgTexture = CreateTextureDropdown(
        "raidFrameBgTexture",
        contentFrame,
        L["Select_Texture"],
        "raidFrameBgTexture",
        function(arg1)
            BBF.UpdateCustomTextures()
            BBF.SetCompactUnitFramesBackground()
        end,
        { anchorFrame = changePartyRaidFrameBackgroundColor, x = 5, y = 3, label = "Texture" }
    )

    local partyRaidFrameBackgroundHealthColorFL = CreateColorBox(contentFrame, "partyRaidFrameBackgroundHealthColor", "Health BG", function() BBF.SetCompactUnitFramesBackground() end)
    partyRaidFrameBackgroundHealthColorFL:SetPoint("LEFT", raidFrameBgTexture, "RIGHT", 10, 0)
    CreateTooltipTwo(partyRaidFrameBackgroundHealthColorFL, "Party/Raid Health Bar Background Color", "Left-click to change.\n\n|cff32f795Shift+Right-click to reset to default.|r")

    local partyRaidFrameBackgroundManaColorFL = CreateColorBox(contentFrame, "partyRaidFrameBackgroundManaColor", "Mana BG", function() BBF.SetCompactUnitFramesBackground() end)
    partyRaidFrameBackgroundManaColorFL:SetPoint("LEFT", partyRaidFrameBackgroundHealthColorFL.text, "RIGHT", 4, 0)
    CreateTooltipTwo(partyRaidFrameBackgroundManaColorFL, "Party/Raid Mana Bar Background Color", "Left-click to change.\n\n|cff32f795Shift+Right-click to reset to default.|r")

    changePartyRaidFrameBackgroundColor:HookScript("OnClick", function(self)
        local alpha = self:GetChecked() and 1 or 0.5
        partyRaidFrameBackgroundHealthColorFL:SetAlpha(alpha)
        partyRaidFrameBackgroundManaColorFL:SetAlpha(alpha)
        raidFrameBgTexture:SetEnabled(self:GetChecked())
        BBF.UpdateCustomTextures()
        BBF.SetCompactUnitFramesBackground()
        BBF.UpdateFrames()
        
        if BBF.changePartyRaidFrameBackgroundColor then
            BBF.changePartyRaidFrameBackgroundColor:SetChecked(self:GetChecked())
            if BBF.changePartyRaidFrameBackgroundColor.parent then
                local clrFx = BBF.changePartyRaidFrameBackgroundColor.parent
                if clrFx.partyRaidFrameBackgroundHealthColor then
                    clrFx.partyRaidFrameBackgroundHealthColor:SetAlpha(alpha)
                end
                if clrFx.partyRaidFrameBackgroundManaColor then
                    clrFx.partyRaidFrameBackgroundManaColor:SetAlpha(alpha)
                end
                if clrFx.raidFrameBgTexture then
                    clrFx.raidFrameBgTexture:SetEnabled(self:GetChecked())
                end
            end
        end
        
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    BBF.changePartyRaidFrameBackgroundColorTexture = changePartyRaidFrameBackgroundColor
    BBF.raidFrameBgTextureDropdown = raidFrameBgTexture
    raidFrameBgTexture:SetEnabled(changePartyRaidFrameBackgroundColor:GetChecked())
    local raidFrameBgAlpha = changePartyRaidFrameBackgroundColor:GetChecked() and 1 or 0.5
    partyRaidFrameBackgroundHealthColorFL:SetAlpha(raidFrameBgAlpha)
    partyRaidFrameBackgroundManaColorFL:SetAlpha(raidFrameBgAlpha)


    local prdText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    prdText:SetPoint("TOPLEFT", changeAllFontsIngame, "BOTTOMLEFT", 0, -35)
    prdText:SetText("Personal Resource Display")

    local prdLegacyLook = CreateCheckbox("prdLegacyLook", L["PRD_Legacy_Look"], contentFrame)
    prdLegacyLook:SetPoint("TOPLEFT", prdText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltipTwo(prdLegacyLook, L["Tooltip_PRD_Legacy_Look"], L["Tooltip_PRD_Legacy_Look_Desc"])

    local prdSplitLines = CreateCheckbox("prdSplitLines", L["PRD_Split_Lines"], prdLegacyLook, nil, BBF.LegacyPRDLook)
    prdSplitLines:SetPoint("LEFT", prdLegacyLook.text, "RIGHT", 0, 0)
    CreateTooltipTwo(prdSplitLines, L["Tooltip_PRD_Split_Lines"], L["Tooltip_PRD_Split_Lines_Desc"])

    prdLegacyLook:HookScript("OnClick", function(self)
        BBF.LegacyPRDLook()
        BBF.TexturePRD()
        if self:GetChecked() then
            EnableElement(prdSplitLines)
        else
            DisableElement(prdSplitLines)
        end
    end)

    if not BetterBlizzFramesDB.prdLegacyLook then
        DisableElement(prdSplitLines)
    end

    local changePrdTextures = CreateCheckbox("changePrdTextures", L["Tooltip_Change_Personal_Resource_Display_Textures"], contentFrame)
    changePrdTextures:SetPoint("TOPLEFT", prdLegacyLook, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(changePrdTextures, L["Tooltip_Change_Personal_Resource_Display_Textures"], L["Tooltip_Change_Personal_Resource_Display_Textures_Desc"])

    useCustomTextureForExtraBars = CreateCheckbox("useCustomTextureForExtraBars", L["Tooltip_Change_PRD_Extra_Bars_Texture_Desc"], changePrdTextures)
    useCustomTextureForExtraBars:SetPoint("LEFT", changePrdTextures.text, "RIGHT", 0, 0)
    CreateTooltipTwo(useCustomTextureForExtraBars, L["Tooltip_Change_PRD_Extra_Bars_Texture_Desc"], L["Tooltip_Change_PRD_Extra_Bars_Texture_Full_Desc"])

    local useCustomTextureForSelf = CreateCheckbox("useCustomTextureForSelf", L["Tooltip_Change_PRD_Healthbar_Texture_Desc"], changePrdTextures)
    useCustomTextureForSelf:SetPoint("TOPLEFT", changePrdTextures, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(useCustomTextureForSelf, L["Tooltip_Change_PRD_Healthbar_Texture_Desc"], L["Tooltip_Change_PRD_Healthbar_Texture_Full_Desc"])
    useCustomTextureForSelf:HookScript("OnClick", function()
        BBF.TexturePRD()
    end)

    local prdHealthbarTexture = CreateTextureDropdown(
        "prdHealthbarTexture",
        contentFrame,
        L["Select_Texture"],
        "customTextureSelf",
        function(arg1)
            BBF.TexturePRD()
        end,
        { anchorFrame = useCustomTextureForSelf, x = 5, y = 3, label = "Texture" }
    )
    useCustomTextureForSelf:HookScript("OnClick", function(self)
        prdHealthbarTexture:SetEnabled(self:GetChecked() and changePrdTextures:GetChecked())
        BBF.TexturePRD()
    end)
    prdHealthbarTexture:SetEnabled(BetterBlizzFramesDB.changePrdTextures and BetterBlizzFramesDB.useCustomTextureForSelf)

    local useCustomTextureForSelfMana = CreateCheckbox("useCustomTextureForSelfMana", L["Tooltip_Change_PRD_Manabar_Texture_Desc"], changePrdTextures)
    useCustomTextureForSelfMana:SetPoint("TOPLEFT", useCustomTextureForSelf, "BOTTOMLEFT", 0, -25)
    CreateTooltipTwo(useCustomTextureForSelfMana, L["Tooltip_Change_PRD_Manabar_Texture_Desc"], L["Tooltip_Change_PRD_Manabar_Texture_Full_Desc"])

    local fancyPrdAltTexture = CreateCheckbox("fancyPrdAltTexture", L["Keep_Fancy_Manabars"], contentFrame)
    fancyPrdAltTexture:SetPoint("LEFT", useCustomTextureForSelfMana.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(fancyPrdAltTexture, L["Keep_Fancy_Manabars"], L["Tooltip_Keep_Fancy_PRD_Mana_Desc"])
    fancyPrdAltTexture:HookScript("OnClick", function()
        BBF.TexturePRD()
    end)

    local prdManabarTexture = CreateTextureDropdown(
        "prdManabarTexture",
        contentFrame,
        L["Select_Texture"],
        "customTextureSelfMana",
        function(arg1)
            BBF.TexturePRD()
        end,
        { anchorFrame = useCustomTextureForSelfMana, x = 5, y = 3, label = "Texture" }
    )
    useCustomTextureForSelfMana:HookScript("OnClick", function(self)
        local enabled = self:GetChecked() and changePrdTextures:GetChecked()
        prdManabarTexture:SetEnabled(enabled)
        BBF.TexturePRD()
        CheckAndToggleCheckboxes(self)
    end)
    prdManabarTexture:SetEnabled(BetterBlizzFramesDB.changePrdTextures and BetterBlizzFramesDB.useCustomTextureForSelfMana)
    changePrdTextures:HookScript("OnClick", function(self)
        local checked = self:GetChecked()
        CheckAndToggleCheckboxes(self)
        prdHealthbarTexture:SetEnabled(checked and BetterBlizzFramesDB.useCustomTextureForSelf)
        prdManabarTexture:SetEnabled(checked and BetterBlizzFramesDB.useCustomTextureForSelfMana)
        BBF.TexturePRD()
    end)


end

local function guiFrameAuras()
    ----------------------
    -- Frame Auras
    ----------------------
    local guiFrameAuras = CreateFrame("Frame")
    guiFrameAuras.name = L["Module_Name_Auras"]
    guiFrameAuras.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(guiFrameAuras)
    local aurasSubCategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, guiFrameAuras, guiFrameAuras.name, guiFrameAuras.name)
    BBF.aurasSubCategory = guiFrameAuras.name
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
    contentFrame.name = guiFrameAuras.name
    contentFrame:SetSize(680, 1470 + 3 * 17 + 3 * 34)
    scrollFrame:SetScrollChild(contentFrame)

    local auraBlacklistFrame = CreateFrame("Frame", nil, contentFrame)
    auraBlacklistFrame:SetSize(322, 320)
    auraBlacklistFrame:SetPoint("TOPLEFT", 6, -15)

    local blacklistText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    blacklistText:SetPoint("BOTTOM", auraBlacklistFrame, "TOP", -20, -5)
    blacklistText:SetText(L["Blacklist"])

    local blacklist = CreateList(auraBlacklistFrame, "auraBlacklist", BetterBlizzFramesDB.auraBlacklist, BBF.RefreshAllAuraFrames, nil, 265)

    local auraWhitelistFrame = CreateFrame("Frame", nil, contentFrame)
    auraWhitelistFrame:SetSize(322, 320)
    auraWhitelistFrame:SetPoint("TOPLEFT", 346, -15)

    local whitelistText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whitelistText:SetPoint("BOTTOM", auraWhitelistFrame, "TOP", -20, -5)
    whitelistText:SetText(L["Whitelist"])

    local whitelist = CreateList(auraWhitelistFrame, "auraWhitelist", BetterBlizzFramesDB.auraWhitelist, BBF.RefreshAllAuraFrames, true, 379, true)

    local pandemicAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    pandemicAuraTexture:SetAtlas("elementalstorm-boss-air")
    pandemicAuraTexture:SetPoint("CENTER", whitelist, "TOPRIGHT", -30, 11)
    pandemicAuraTexture:SetSize(25, 25)
    pandemicAuraTexture:SetDesaturated(true)
    BBF.TintGlowSwatch(pandemicAuraTexture, "auraPandemicGlowColor", 1, 0, 0)
    pandemicAuraTexture:EnableMouse(true)
    CreateTooltipTwo(pandemicAuraTexture, L["Pandemic_Glow_Icon"], L["Tooltip_Pandemic_Glow_Entry"])

    local importantAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    importantAuraTexture:SetAtlas("importantavailablequesticon")
    importantAuraTexture:SetPoint("CENTER", pandemicAuraTexture, "CENTER", -25, -2)
    importantAuraTexture:SetSize(16, 16)
    importantAuraTexture:SetDesaturated(true)
    BBF.auraImportantHeaderIcon = importantAuraTexture
    BBF.TintGlowSwatch(importantAuraTexture, "auraWhitelistImportantGlowColor", 0, 1, 0)
    importantAuraTexture:EnableMouse(true)
    importantAuraTexture:SetScript("OnMouseDown", function(_, mouseButton)
        if mouseButton == "RightButton" then
            BBF.OpenAuraGlowColor("auraWhitelistImportantGlowColor", 0, 1, 0)
        end
    end)
    CreateTooltipTwo(importantAuraTexture, L["Important_Glow_Icon"],
        L["Tooltip_Important_Glow_Entry"])

    local enlargedAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    enlargedAuraTexture:SetAtlas("ui-hud-minimap-zoom-in")
    enlargedAuraTexture:SetPoint("CENTER", importantAuraTexture, "CENTER", -23, -1)
    enlargedAuraTexture:SetSize(18, 18)
    enlargedAuraTexture:EnableMouse(true)
    enlargedAuraTexture:SetScript("OnMouseDown", function(_, mouseButton)
        if mouseButton == "RightButton" then
            BBF.OpenAuraGlowColor("auraEnlargedGlowColor", 1, 0.5, 0)
        end
    end)
    CreateTooltipTwo(enlargedAuraTexture, L["Enlarged_Aura_Icon"],
        L["Tooltip_Enlarged_Aura_Entry"])

    local onlyMeTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    onlyMeTexture:SetAtlas("UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon")
    onlyMeTexture:SetPoint("CENTER", enlargedAuraTexture, "CENTER", -24, 1)
    onlyMeTexture:SetSize(18, 20)
    onlyMeTexture:EnableMouse(true)
    CreateTooltipTwo(onlyMeTexture, L["Only_My_Aura_Icon"], L["Tooltip_Only_My_Aura"])

    local showMineTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    showMineTexture:SetAtlas("UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon")
    showMineTexture:SetPoint("RIGHT", blacklist, "TOPRIGHT", -21, 9)
    showMineTexture:SetSize(18, 20)
    showMineTexture:EnableMouse(true)
    CreateTooltipTwo(showMineTexture, L["Show_Mine_Icon"], L["Tooltip_Show_Mine"])

    local filterCaveat = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    filterCaveat:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 305, -325)
    filterCaveat:SetWidth(370)
    filterCaveat:SetJustifyH("LEFT")
    filterCaveat:SetText(L["Aura_SpellID_Filter_Caveat"])

    local UpdateLeadingGlowBoxes

    local friendlyFoeFilterBoxes, UpdateFriendlyFoeFilterBoxes = {}, nil

    local playerAuraFiltering = CreateCheckbox("playerAuraFiltering", L["Enable_Aura_Settings"], contentFrame)
    playerAuraFiltering.name = guiFrameAuras.name
    CreateTooltipTwo(playerAuraFiltering, L["Enable_Aura_Settings"], L["Tooltip_Enable_Aura_Settings_TargetFocus_Desc"])
    playerAuraFiltering:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 50, -347)
    playerAuraFiltering:HookScript("OnClick", function (self)
        if self:GetChecked() then
            if BetterBlizzFramesDB.targetToTXPos == 0 then
                StaticPopup_Show("BBF_TOT_MESSAGE")
                BetterBlizzFramesDB.targetToTXPos = 31
                BBF.targetToTXPos:SetValue(31)
                BetterBlizzFramesDB.focusToTXPos = 31
                BBF.focusToTXPos:SetValue(31)
                BBF.MoveToTFrames()
            else
                StaticPopup_Show("BBF_CONFIRM_RELOAD")
            end
            auraWhitelistFrame:SetAlpha(1)
            auraBlacklistFrame:SetAlpha(1)
        else
            if BetterBlizzFramesDB.targetToTXPos == 31 then
                BBF.Print(L["Chat_Aura_Settings_Off"])
                BetterBlizzFramesDB.targetToTXPos = 0
                BBF.targetToTXPos:SetValue(0)
                BetterBlizzFramesDB.focusToTXPos = 0
                BBF.focusToTXPos:SetValue(0)
                BBF.MoveToTFrames()
            end
            auraWhitelistFrame:SetAlpha(0.3)
            auraBlacklistFrame:SetAlpha(0.3)
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end

        CheckAndToggleCheckboxes(playerAuraFiltering)
        UpdateLeadingGlowBoxes()
        UpdateFriendlyFoeFilterBoxes()
    end)

    if not BetterBlizzFramesDB.playerAuraFiltering then
        auraWhitelistFrame:SetAlpha(0.3)
        auraBlacklistFrame:SetAlpha(0.3)
    end

    local auraTestMode = CreateCheckbox("auraTestMode", L["Aura_Test_Mode"], contentFrame)
    auraTestMode:SetPoint("LEFT", playerAuraFiltering.Text, "RIGHT", 8, 0)
    CreateTooltipTwo(auraTestMode, L["Aura_Test_Mode"], L["Tooltip_Aura_Test_Mode_Desc"])
    auraTestMode:HookScript("OnClick", function(self)
        BBF.SetAuraTestMode(self:GetChecked())
    end)

    local importPVPWhitelist = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    importPVPWhitelist:SetSize(138, 22)
    importPVPWhitelist:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 26, -325)
    importPVPWhitelist:SetText(L["Import_PvP_Whitelist"])
    importPVPWhitelist:SetScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_PVP_WHITELIST")
    end)
    importPVPWhitelist:Disable()
    importPVPWhitelist:SetAlpha(0.5)
    local coloredText = "|cff00FF00Important/Immunity|r\n" ..
                    "|cffFF8000Offensive Buff|r\n" ..
                    "|cffFFA9F1Defensive Buffs|r\n" ..
                    "|cff00FFFFFreedom/Speed|r\n" ..
                    "|cffEFFF33Fear Immunity|r"
    CreateTooltipTwo(importPVPWhitelist, L["Import_PvP_Whitelist"], string.format(L["Tooltip_Import_PvP_Whitelist_Desc"], coloredText), L["Tooltip_Aura_Filter_Unit_Note"])
    importPVPWhitelist.Middle:SetDesaturated(true)
    importPVPWhitelist.Left:SetDesaturated(true)
    importPVPWhitelist.Right:SetDesaturated(true)

    local importPVPBlacklist = CreateFrame("Button", nil, playerAuraFiltering, "UIPanelButtonTemplate")
    importPVPBlacklist:SetSize(138, 22)
    importPVPBlacklist:SetPoint("LEFT", importPVPWhitelist, "RIGHT", 0, 0)
    importPVPBlacklist:SetText(L["Import_PvP_Blacklist"])
    importPVPBlacklist:SetScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_PVP_BLACKLIST")
    end)
    CreateTooltipTwo(importPVPBlacklist, L["Import_PvP_Blacklist"], L["Tooltip_Import_PvP_Blacklist_Desc"], L["Tooltip_Aura_Filter_Unit_Note"])
    importPVPBlacklist.Middle:SetDesaturated(true)
    importPVPBlacklist.Left:SetDesaturated(true)
    importPVPBlacklist.Right:SetDesaturated(true)

    local function OpenColorPicker(entryColors)
        local colorData = entryColors or {0, 1, 0, 1}
        local r, g, b = colorData[1] or 1, colorData[2] or 1, colorData[3] or 1
        local a = colorData[4] or 1

        local function updateColors(newR, newG, newB, newA)
            entryColors[1] = newR
            entryColors[2] = newG
            entryColors[3] = newB
            entryColors[4] = newA or 1

            BBF.RefreshAllAuraFrames()
        end

        local function swatchFunc()
            r, g, b = ColorPickerFrame:GetColorRGB()
            updateColors(r, g, b, a)
        end

        local function opacityFunc()
            a = ColorPickerFrame:GetColorAlpha()
            updateColors(r, g, b, a)
        end

        local function cancelFunc(previousValues)
            if previousValues then
                r, g, b, a = previousValues.r, previousValues.g, previousValues.b, previousValues.a
                updateColors(r, g, b, a)
            end
        end

        ColorPickerFrame.previousValues = { r = r, g = g, b = b, a = a }

        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b, opacity = a, hasOpacity = true,
            swatchFunc = swatchFunc, opacityFunc = opacityFunc, cancelFunc = cancelFunc
        })
    end

    local COLUMN_TOP = -404
    local COLUMN_ROW_HEIGHT = 23 - pixelsBetweenBoxes

    local function AddGlowColorRightClick(box, option, colorKey)
        box:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        box:HookScript("OnClick", function(self, button)
            if button ~= "RightButton" then return end
            local restored = not self:GetChecked()
            self:SetChecked(restored)
            BetterBlizzFramesDB[option] = restored
            local color = BetterBlizzFramesDB[colorKey]
            if type(color) ~= "table" then
                color = { 1, 1, 1, 1 }
                BetterBlizzFramesDB[colorKey] = color
            end
            OpenColorPicker(color)
        end)
    end

    local leadingGlowBoxes = {}
    function UpdateLeadingGlowBoxes()
        local on = BetterBlizzFramesDB.importantAurasFirst ~= false
        for _, entry in ipairs(leadingGlowBoxes) do
            local box = entry.box
            local parent = box:GetParent()
            local filtered = entry.filter and entry.filter:GetChecked()
                and entry.section and entry.section:GetChecked()
            if (on or filtered) and parent:GetChecked() and playerAuraFiltering:GetChecked() then
                EnableElement(box)
            else
                DisableElement(box)
            end
        end
    end

    local FRIENDLY_FOE_BOX_SIZE = 18
    local FRIENDLY_FOE_ROW_INDENT = 15
    local FRIENDLY_FOE_ENEMY_X, FRIENDLY_FOE_FRIENDLY_X = 117, 138
    local FRIENDLY_FOE_ENEMY_COLOR = { 1, 0.25, 0.25 }
    local FRIENDLY_FOE_FRIENDLY_COLOR = { 0.25, 1, 0.25 }

    function UpdateFriendlyFoeFilterBoxes()
        local aurasOn = playerAuraFiltering:GetChecked()
        for _, entry in ipairs(friendlyFoeFilterBoxes) do
            local rowOn = entry.section:GetChecked() and entry.filter:GetChecked() and true or false
            if entry.pair then
                entry.box:SetShown(rowOn)
            end
            if not entry.locked and aurasOn and rowOn then
                EnableElement(entry.box)
            else
                DisableElement(entry.box)
                if entry.forced and aurasOn then entry.box:SetAlpha(1) end
            end
        end
    end

    local function AddFrameColumn(xOffset, titleText, iconR, iconG, iconB, keys)
        local overrides = keys.overrides or {}
        local function Key(prefix, suffix)
            return overrides[prefix .. suffix] or (prefix .. suffix)
        end

        local reservedX = keys.reserveTopRow and 15 or 0
        local reservedY = keys.reserveTopRow and -COLUMN_ROW_HEIGHT or 0

        local anchor = CreateCheckbox(keys.buffEnable or (keys.buff .. "Enable"),
            L["Show_Buffs"], playerAuraFiltering)
        anchor:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", xOffset + reservedX, COLUMN_TOP + reservedY)
        anchor:HookScript("OnClick", function()
            CheckAndToggleCheckboxes(anchor)
            UpdateFriendlyFoeFilterBoxes()
            BBF.RefreshAllAuraFrames()
        end)

        local title = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("LEFT", anchor, "CENTER", 35 - reservedX, 32 - reservedY)
        title:SetText(titleText)
        local icon = contentFrame:CreateTexture(nil, "ARTWORK")
        icon:SetAtlas("groupfinder-icon-friend")
        icon:SetSize(28, 28)
        icon:SetPoint("RIGHT", title, "LEFT", -3, 0)
        icon:SetDesaturated(1)
        icon:SetVertexColor(iconR, iconG, iconB)

        local border = CreateBorderedFrame(anchor, 195, 324 + 5 * COLUMN_ROW_HEIGHT,
            70 - reservedX, -145 - reservedY - math.floor(5 * COLUMN_ROW_HEIGHT / 2), contentFrame)

        local function FriendlyFoeBorder(box)
            local tex = box:CreateTexture(nil, "BACKGROUND")
            tex:SetAtlas("AlliedRace-UnlockingFrame-GenderSelectionGlow")
            tex:SetDesaturated(true)
            tex:SetPoint("TOPLEFT", box, "TOPLEFT", 1.5, -1.5)
            tex:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -2, 2)
            return tex
        end

        local previous, section = anchor, anchor
        local function Add(key, label, tooltip, extra)
            local box = CreateCheckbox(key, label, section, nil, BBF.RefreshAllAuraFrames)
            if previous == section then
                box:SetPoint("TOPLEFT", section, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
            else
                box:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
            end
            if tooltip then CreateTooltipTwo(box, label, tooltip, extra) end
            previous = box
            return box
        end

        local function AddSection(key, label, tooltip)
            local box = CreateCheckbox(key, label, playerAuraFiltering)
            box:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", -15, 0)
            if tooltip then CreateTooltipTwo(box, label, tooltip) end
            box:HookScript("OnClick", function()
                CheckAndToggleCheckboxes(box)
                UpdateLeadingGlowBoxes()
                UpdateFriendlyFoeFilterBoxes()
                BBF.RefreshAllAuraFrames()
            end)
            previous, section = box, box
            return box
        end

        local function AddCategoryFilter(key, label, tooltip)
            local box = Add(key, label, tooltip, L["Tooltip_Aura_Filter_Category_Note"])
            box:HookScript("OnClick", function()
                UpdateLeadingGlowBoxes()
            end)
            return box
        end

        local function AddFriendlyFoeToggles(filterBox, key, omit)
            if not keys.unitFrame then return end
            local locked = key == nil
            local forced = locked and omit ~= nil
            local sub = (not locked) and L["Tooltip_Filter_FriendlyFoe_Default"] or nil
            local lockedNote
            if omit == "Friendly" then
                lockedNote = L["Tooltip_Filter_FriendlyFoe_Locked_Enemy"]
            elseif omit == "Enemy" then
                lockedNote = L["Tooltip_Filter_FriendlyFoe_Locked_Friendly"]
            end
            local owner = filterBox.Text and filterBox.Text:GetText()
            local xShift = (filterBox == section) and FRIENDLY_FOE_ROW_INDENT or 0

            local function FriendlyFoeBox(suffix, xPos, color, title, desc)
                if owner and owner ~= "" then title = title .. " - " .. owner end
                local box
                if locked then
                    box = CreateFrame("CheckButton", nil, filterBox,
                        "InterfaceOptionsCheckButtonTemplate")
                    box:SetChecked(forced)
                else
                    box = CreateCheckbox(key .. suffix, "", filterBox, nil,
                        BBF.RefreshAllAuraFrames)
                end

                local normal, pushed = box:GetNormalTexture(), box:GetPushedTexture()
                if normal then normal:SetTexture(nil) end
                if pushed then pushed:SetTexture(nil) end
                box:SetMotionScriptsWhileDisabled(true)
                box:SetSize(FRIENDLY_FOE_BOX_SIZE, FRIENDLY_FOE_BOX_SIZE)
                box:ClearAllPoints()
                box:SetPoint("LEFT", filterBox, "LEFT", xPos + xShift, 0)
                FriendlyFoeBorder(box):SetVertexColor(unpack(color))
                if locked then
                    CreateTooltipTwo(box, title, lockedNote)
                else
                    CreateTooltipTwo(box, title, desc, sub)
                end
                friendlyFoeFilterBoxes[#friendlyFoeFilterBoxes + 1] = {
                    box = box, filter = filterBox, section = section, locked = locked,
                    forced = forced, pair = true,
                }
                return box
            end

            if omit ~= "Enemy" then
                FriendlyFoeBox("Enemy", FRIENDLY_FOE_ENEMY_X, FRIENDLY_FOE_ENEMY_COLOR,
                    L["Filter_Enemy"], L["Tooltip_Filter_Enemy_Only"])
            end
            if omit ~= "Friendly" then
                FriendlyFoeBox("Friendly", FRIENDLY_FOE_FRIENDLY_X, FRIENDLY_FOE_FRIENDLY_COLOR,
                    L["Filter_Friendly"], L["Tooltip_Filter_Friendly_Only"])
            end

            filterBox:HookScript("OnClick", UpdateFriendlyFoeFilterBoxes)
        end

        AddFriendlyFoeToggles(anchor, keys.buffEnable or (keys.buff .. "Enable"))

        AddFriendlyFoeToggles(
            Add(Key(keys.buff, "FilterWatchList"), L["Whitelist"], L["Tooltip_Whitelist"], L["Tooltip_Whitelist_Desc"]),
            nil, "Enemy")
        AddFriendlyFoeToggles(
            Add(Key(keys.buff, "FilterBlacklist"), L["Blacklist"], L["Tooltip_Blacklist"], L["Tooltip_Aura_Filter_Unit_Note"]),
            nil, "Enemy")
        local importantFilter = AddCategoryFilter(Key(keys.buff, "FilterImportant"),
            L["Important"], L["Tooltip_Aura_Filter_Important"])
        AddFriendlyFoeToggles(importantFilter, Key(keys.buff, "FilterImportant"))
        local defensivesFilter = AddCategoryFilter(Key(keys.buff, "FilterDefensives"),
            L["Defensive_Auras"], L["Tooltip_Aura_Filter_Defensives"])
        AddFriendlyFoeToggles(defensivesFilter, Key(keys.buff, "FilterDefensives"))
        AddFriendlyFoeToggles(
            Add(Key(keys.buff, "FilterLessMinite"), L["Under_One_Min"], L["Tooltip_Under_One_Min"]),
            Key(keys.buff, "FilterLessMinite"))
        if keys.unitFrame then
            AddFriendlyFoeToggles(
                Add(Key(keys.buff, "FilterOnlyMe"), L["Only_Mine"], L["Tooltip_Aura_Only_Mine"]),
                nil, "Enemy")
            AddFriendlyFoeToggles(
                Add(Key(keys.buff, "FilterPurgeable"), L["Purgeable"], L["Tooltip_Aura_Purgeable"]),
                Key(keys.buff, "FilterPurgeable"))
        end

        if not keys.unitFrame then
            local filteredIcon = Add("showHiddenAurasIcon", L["Filtered_Buffs_Icon"],
                L["Tooltip_Filtered_Buffs_Icon_Desc"])

            local changeIcon = CreateFrame("Button", "ChangeIconButton", filteredIcon, "UIPanelButtonTemplate")
            changeIcon:SetPoint("LEFT", filteredIcon.Text, "RIGHT", 3, 0)
            changeIcon:SetSize(37, 20)
            changeIcon:SetText(L["Icon"])
            local iconChangeWindow
            changeIcon:SetScript("OnClick", function()
                iconChangeWindow = iconChangeWindow or CreateIconChangeWindow()
                iconChangeWindow:Show()
            end)

            local function UpdateChangeIcon(shown)
                changeIcon:SetAlpha(shown and 1 or 0)
                changeIcon:SetEnabled(shown and true or false)
            end
            UpdateChangeIcon(BetterBlizzFramesDB.showHiddenAurasIcon)
            filteredIcon:HookScript("OnClick", function(self)
                UpdateChangeIcon(self:GetChecked())
                if not self:GetChecked() then
                    BetterBlizzFramesDB.toggleIconPosition = nil
                    BBF.UpdateHiddenAuraButtonPos()
                end
            end)
        end

        local debuffSection = AddSection(keys.debuffEnable or (keys.debuff .. "Enable"), L["Show_Debuffs"])
        AddFriendlyFoeToggles(debuffSection, keys.debuffEnable or (keys.debuff .. "Enable"))
        AddFriendlyFoeToggles(
            Add(Key(keys.debuff, "FilterWatchList"), L["Whitelist"], L["Tooltip_Aura_Whitelist_Filter"], L["Tooltip_Aura_Filter_Unit_Note"]),
            nil, "Friendly")
        AddFriendlyFoeToggles(
            Add(Key(keys.debuff, "FilterBlacklist"), L["Blacklist"], L["Tooltip_Aura_Blacklist_Filter"], L["Tooltip_Aura_Filter_Unit_Note"]),
            nil, "Friendly")
        local ccFilter = AddCategoryFilter(Key(keys.debuff, "FilterCrowdControl"),
            L["Crowd_Control"], L["Tooltip_Aura_Filter_CC"])
        AddFriendlyFoeToggles(ccFilter, Key(keys.debuff, "FilterCrowdControl"))
        if keys.unitFrame then
            local dispellable = Add(Key(keys.debuff, "FilterDispellable"),
                L["Dispellable"], L["Tooltip_Aura_Dispellable"])
            AddFriendlyFoeToggles(dispellable, nil, "Enemy")

            local dispellableAny = CreateCheckbox(Key(keys.debuff, "FilterDispellableAny"),
                L["Always_Show"], dispellable, nil, BBF.RefreshAllAuraFrames)
            dispellableAny:SetPoint("TOPLEFT", dispellable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
            CreateTooltipTwo(dispellableAny, L["Always_Show"], L["Tooltip_Aura_Dispellable_Any"])

            friendlyFoeFilterBoxes[#friendlyFoeFilterBoxes + 1] = {
                box = dispellableAny, filter = dispellable, section = section,
            }

            local outdent = CreateFrame("Frame", nil, section)
            outdent:SetSize(23, 23)
            outdent:SetPoint("TOPLEFT", dispellableAny, "TOPLEFT", -15, 0)
            previous = outdent

            dispellable:HookScript("OnClick", function()
                CheckAndToggleCheckboxes(dispellable)
                UpdateFriendlyFoeFilterBoxes()
            end)
        end
        AddFriendlyFoeToggles(
            Add(Key(keys.debuff, "FilterLessMinite"), L["Under_One_Min"], L["Tooltip_Under_One_Min"]),
            Key(keys.debuff, "FilterLessMinite"))
        if keys.unitFrame then
            AddFriendlyFoeToggles(
                Add(Key(keys.debuff, "FilterOnlyMe"), L["Only_Mine"], L["Tooltip_Aura_Only_Mine_Debuff"]),
                nil, "Friendly")
        end

        AddSection(keys.prefix .. "AuraGlows", L["Extra_Aura_Settings"])

        local function AddGlow(key, label, tooltip, colorKey, extra, colorNote)
            local box = Add(key, label, tooltip .. "\n\n" .. (colorNote or L["Tooltip_Glow_Color_Shared"]), extra)
            AddGlowColorRightClick(box, key, colorKey)
            return box
        end

        leadingGlowBoxes[#leadingGlowBoxes + 1] = {
            box = AddGlow(keys.importantGlow, L["Important_Glow"], L["Tooltip_Important_Glow_Desc"],
                "auraImportantGlowColor", L["Tooltip_Needs_Important_Auras_First"]),
            filter = importantFilter, section = anchor,
        }
        leadingGlowBoxes[#leadingGlowBoxes + 1] = {
            box = AddGlow(keys.prefix .. "AuraDefensiveGlow", L["Defensives_Glow"], L["Tooltip_Defensive_Glow_Desc"],
                "auraDefensiveGlowColor", L["Tooltip_Needs_Important_Auras_First"]),
            filter = defensivesFilter, section = anchor,
        }
        leadingGlowBoxes[#leadingGlowBoxes + 1] = {
            box = AddGlow(keys.prefix .. "AuraCCGlow", L["CC_Glow"], L["Tooltip_CC_Auras_Desc"],
                "auraCCGlowColor", L["Tooltip_Needs_Important_Auras_First"]),
            filter = ccFilter, section = debuffSection,
        }

        AddGlow(keys.purgeGlow, L["Purge_Glow"], L["Tooltip_Purge_Glow_Desc"],
            "purgeTextureColorRGB", nil, L["Tooltip_Purge_Glow_Color_Shared"])

        if keys.unitFrame then
            AddGlow(keys.pandemicGlow, L["Pandemic_Glow"], L["Tooltip_Pandemic_Glow_Midnight_Desc"],
                "auraPandemicGlowColor", L["Tooltip_Pandemic_Glow_Midnight_Extra"])
        end

        return border, previous
    end

    local targetBorder = AddFrameColumn(64, L["Target_Frame"], 1, 0, 0, {
        prefix = "target", buff = "targetBuff", debuff = "targetdeBuff",
        importantGlow = "targetImportantAuraGlow", purgeGlow = "targetBuffPurgeGlow",
        pandemicGlow = "targetdeBuffPandemicGlow",
        unitFrame = true,
    })

    local focusBorder = AddFrameColumn(285, L["Focus_Frame"], 0, 1, 0, {
        prefix = "focus", buff = "focusBuff", debuff = "focusdeBuff",
        importantGlow = "focusImportantAuraGlow", purgeGlow = "focusBuffPurgeGlow",
        pandemicGlow = "focusdeBuffPandemicGlow",
        unitFrame = true,
    })

    local playerColumnX = 506
    local playerBorder = AddFrameColumn(playerColumnX, L["Label_Player_Auras"], 1, 1, 1, {
        prefix = "player", buff = "PlayerAuraFrameBuff", debuff = "PlayerAuraFramedeBuff",
        importantGlow = "playerAuraImportantGlow", purgeGlow = "showPurgeTextureOnSelf",
        reserveTopRow = true,
        overrides = {
            PlayerAuraFrameBuffFilterBlacklist = "playerBuffFilterBlacklist",
            PlayerAuraFramedeBuffFilterBlacklist = "playerdeBuffFilterBlacklist",
        },
    })

    UpdateLeadingGlowBoxes()
    UpdateFriendlyFoeFilterBoxes()

    --------------------------
    -- Frame settings
    --------------------------
    local targetAndFocusAuraSettings = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetAndFocusAuraSettings:SetPoint("TOPLEFT", targetBorder, "BOTTOMLEFT", 2, -8)
    targetAndFocusAuraSettings:SetText(L["Target_And_Focus_Aura_Settings"])

    local targetAndFocusAuraScale = CreateSlider(playerAuraFiltering, L["All_Aura_Size"], 0.7, 2, 0.01, "targetAndFocusAuraScale")
    targetAndFocusAuraScale:SetPoint("TOPLEFT", targetAndFocusAuraSettings, "BOTTOMLEFT", 10, -20)
    CreateTooltip(targetAndFocusAuraScale, L["Tooltip_All_Aura_Size"])

    local targetAndFocusSmallAuraScale = CreateSlider(playerAuraFiltering, L["Small_Aura_Size"], 0.7, 2, 0.01, "targetAndFocusSmallAuraScale")
    targetAndFocusSmallAuraScale:SetPoint("TOP", targetAndFocusAuraScale, "BOTTOM", 0, -20)
    CreateTooltip(targetAndFocusSmallAuraScale, L["Tooltip_Small_Aura_Size"])

    local sameSizeAuras = CreateCheckbox("sameSizeAuras", L["Same_Size"], playerAuraFiltering)
    sameSizeAuras:SetPoint("LEFT", targetAndFocusSmallAuraScale, "RIGHT", 3, 2)
    CreateTooltipTwo(sameSizeAuras, L["Same_Size"], L["Tooltip_Same_Size"])
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

    local UpdateAuraWidthText, UpdateAuraWidthSeparate

    local auraWidthSpace = CreateSlider(playerAuraFiltering, L["Aura_Row_Width"], 20, 400, 1, "auraWidthSpace")
    auraWidthSpace:SetPoint("TOPLEFT", targetAndFocusSmallAuraScale, "BOTTOMLEFT", 0, -17)
    auraWidthSpace.integerOnly = true
    CreateTooltipTwo(auraWidthSpace, L["Aura_Row_Width"], L["Tooltip_Aura_Row_Width"])
    auraWidthSpace:HookScript("OnValueChanged", function()
        if UpdateAuraWidthText then UpdateAuraWidthText() end
    end)

    local auraWidthSpaceFullWidth = auraWidthSpace:GetWidth()
    local auraWidthSpaceGap = 8
    local auraWidthSpaceHalfWidth = (auraWidthSpaceFullWidth - auraWidthSpaceGap) / 2

    local auraWidthSpaceFocus = CreateSlider(playerAuraFiltering, L["Aura_Row_Width_Focus"], 20, 400, 1, "auraWidthSpaceFocus", nil, auraWidthSpaceHalfWidth)
    auraWidthSpaceFocus:SetPoint("LEFT", auraWidthSpace, "RIGHT", auraWidthSpaceGap, 0)
    auraWidthSpaceFocus.integerOnly = true
    auraWidthSpaceFocus.Text:Hide()
    auraWidthSpaceFocus:Hide()
    CreateTooltipTwo(auraWidthSpaceFocus, L["Aura_Row_Width_Focus"], L["Tooltip_Aura_Row_Width"])
    auraWidthSpaceFocus:HookScript("OnValueChanged", function()
        if UpdateAuraWidthText then UpdateAuraWidthText() end
    end)

    local auraWidthSpaceSeparate = CreateCheckbox("auraWidthSpaceSeparate", L["Separate"], playerAuraFiltering)
    CreateTooltipTwo(auraWidthSpaceSeparate, L["Separate"], L["Tooltip_Aura_Row_Width_Separate"])
    auraWidthSpaceSeparate:HookScript("OnClick", function()
        if UpdateAuraWidthSeparate then UpdateAuraWidthSeparate() end
        BBF.PreviewAuraRowWidth()
    end)

    function UpdateAuraWidthText()
        local target = BetterBlizzFramesDB.auraWidthSpace or 150
        local focus = BetterBlizzFramesDB.auraWidthSpaceFocus or target
        local text = L["Aura_Row_Width"] .. ": " .. math.floor(target)
        if BetterBlizzFramesDB.auraWidthSpaceSeparate then
            text = text .. " -/- " .. math.floor(focus)
        end
        auraWidthSpace.Text:SetText(text)
    end

    function UpdateAuraWidthSeparate()
        local separate = BetterBlizzFramesDB.auraWidthSpaceSeparate and true or false
        auraWidthSpaceFocus:SetShown(separate)
        auraWidthSpace:SetWidth(separate and auraWidthSpaceHalfWidth or auraWidthSpaceFullWidth)

        auraWidthSpace.Text:ClearAllPoints()
        if separate then
            auraWidthSpace.Text:SetPoint("BOTTOM", auraWidthSpace, "TOPRIGHT", auraWidthSpaceGap / 2, 0)
        else
            auraWidthSpace.Text:SetPoint("BOTTOM", auraWidthSpace, "TOP", 0, 0)
        end

        auraWidthSpaceSeparate:ClearAllPoints()
        auraWidthSpaceSeparate:SetPoint("LEFT", separate and auraWidthSpaceFocus or auraWidthSpace, "RIGHT", 3, 2)

        CreateTooltipTwo(auraWidthSpace, separate and L["Aura_Row_Width_Target"] or L["Aura_Row_Width"], L["Tooltip_Aura_Row_Width"])
        UpdateAuraWidthText()
    end

    UpdateAuraWidthSeparate()

    local targetAndFocusAuraOffsetX = CreateSlider(playerAuraFiltering, L["X_Offset"], -50, 50, 1, "targetAndFocusAuraOffsetX", "X")
    targetAndFocusAuraOffsetX:SetPoint("TOPLEFT", auraWidthSpace, "BOTTOMLEFT", 0, -17)

    local targetAndFocusAuraOffsetY = CreateSlider(playerAuraFiltering, L["Y_Offset"], -50, 50, 1, "targetAndFocusAuraOffsetY", "Y")
    targetAndFocusAuraOffsetY:SetPoint("TOPLEFT", targetAndFocusAuraOffsetX, "BOTTOMLEFT", 0, -17)

    local targetAndFocusHorizontalGap = CreateSlider(playerAuraFiltering, L["Horizontal_Gap"], 0, 18, 0.5, "targetAndFocusHorizontalGap", "X")
    targetAndFocusHorizontalGap:SetPoint("TOPLEFT", targetAndFocusAuraOffsetY, "BOTTOMLEFT", 0, -17)

    local targetAndFocusVerticalGap = CreateSlider(playerAuraFiltering, L["Vertical_Gap"], 0, 18, 0.5, "targetAndFocusVerticalGap", "Y")
    targetAndFocusVerticalGap:SetPoint("TOPLEFT", targetAndFocusHorizontalGap, "BOTTOMLEFT", 0, -17)

    local auraTypeGap = CreateSlider(playerAuraFiltering, L["Aura_Type_Gap"], 0, 30, 1, "auraTypeGap", "Y")
    auraTypeGap:SetPoint("TOPLEFT", targetAndFocusVerticalGap, "BOTTOMLEFT", 0, -17)
    CreateTooltip(auraTypeGap, L["Tooltip_Aura_Type_Gap"])

    local auraStackSize = CreateSlider(playerAuraFiltering, L["Aura_Stack_Size"], 0.4, 2, 0.01, "auraStackSize")
    auraStackSize:SetPoint("TOPLEFT", auraTypeGap, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(auraStackSize, L["Aura_Stack_Size"], L["Tooltip_Aura_Stack_Size"])

    local showAuraCdText = CreateCheckbox("showAuraCdText", L["Show_Aura_Timer_Text"], playerAuraFiltering)
    CreateTooltipTwo(showAuraCdText, L["Show_Aura_Timer_Text"], L["Tooltip_Show_Aura_Timer_Text"])

    local auraCdTextSize = CreateSlider(showAuraCdText, L["Aura_CD_Text_Size"], 0.25, 1.5, 0.01, "auraCdTextSize")
    auraCdTextSize:SetPoint("TOPLEFT", auraStackSize, "BOTTOMLEFT", 0, -17)
    CreateTooltip(auraCdTextSize, L["Tooltip_Aura_CD_Text_Size"])

    showAuraCdText:SetPoint("LEFT", auraCdTextSize, "RIGHT", 3, 7)

    local auraCdTextOnlyMine = CreateCheckbox("auraCdTextOnlyMine", L["Only_Mine"], showAuraCdText)
    auraCdTextOnlyMine:SetPoint("LEFT", showAuraCdText.text, "RIGHT", 3, 0)
    CreateTooltipTwo(auraCdTextOnlyMine, L["Aura_CD_Text_Only_Mine"], L["Tooltip_Aura_CD_Text_Only_Mine"])

    showAuraCdText:HookScript("OnClick", function(self)
        if self:GetChecked() then
            EnableElement(auraCdTextSize)
            EnableElement(auraCdTextOnlyMine)
        else
            DisableElement(auraCdTextSize)
            DisableElement(auraCdTextOnlyMine)
        end
    end)

    local auraHighlightScale = CreateSlider(playerAuraFiltering, L["Scale_Highlighted_Auras"], 1, 2, 0.05, "auraHighlightScale")
    auraHighlightScale:SetPoint("TOPLEFT", auraCdTextSize, "BOTTOMLEFT", 0, -17)
    CreateTooltip(auraHighlightScale, L["Tooltip_Scale_Highlighted_Auras"])

    local enlargedAuraSize = CreateSlider(playerAuraFiltering, L["Enlarged_Aura_Scale"], 1, 2, 0.01, "enlargedAuraSize")
    enlargedAuraSize:SetPoint("TOPLEFT", auraHighlightScale, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(enlargedAuraSize, L["Enlarged_Aura_Scale"], L["Tooltip_Enlarged_Aura_Scale"])

    local maxTargetBuffs = CreateSlider(playerAuraFiltering, L["Max_Buffs"], 1, 32, 1, "maxTargetBuffs")
    maxTargetBuffs:SetPoint("TOPLEFT", enlargedAuraSize, "BOTTOMLEFT", 0, -17)
    maxTargetBuffs.integerOnly = true
    CreateTooltipTwo(maxTargetBuffs, L["Max_Buffs"], L["Tooltip_Max_Buffs_Desc"], L["Tooltip_Max_Auras_Note"])

    local maxTargetDebuffs = CreateSlider(playerAuraFiltering, L["Max_Debuffs"], 1, 16, 1, "maxTargetDebuffs")
    maxTargetDebuffs:SetPoint("TOPLEFT", maxTargetBuffs, "BOTTOMLEFT", 0, -17)
    maxTargetDebuffs.integerOnly = true
    CreateTooltipTwo(maxTargetDebuffs, L["Max_Debuffs"], L["Tooltip_Max_Debuffs_Desc"], L["Tooltip_Max_Auras_Note"])

    local function AddColorButton(anchorTo, dbKey, tooltipTitle)
        local button = CreateFrame("Button", nil, playerAuraFiltering, "UIPanelButtonTemplate")
        button:SetText(L["Color"])
        button:SetSize(43, 18)
        button:SetPoint("LEFT", anchorTo.Text, "RIGHT", 2, 0)
        button:SetScript("OnClick", function()
            OpenColorPicker(BetterBlizzFramesDB[dbKey])
        end)
        CreateTooltip(button, tooltipTitle)
        return button
    end

    local playerAuraSettings = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playerAuraSettings:SetPoint("TOP", playerBorder, "BOTTOM", 0, -8)
    playerAuraSettings:SetText(L["Player_Aura_Settings"])

    local enablePlayerBuffFiltering = CreateCheckbox("enablePlayerBuffFiltering", L["Enable_Player_Aura_Adjustments"], playerAuraFiltering)
    enablePlayerBuffFiltering:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", playerColumnX - 5, COLUMN_TOP)

    local clickthroughPlayerAuras = CreateCheckbox("clickthroughPlayerAuras", L["Clickthrough_Player_Auras"], enablePlayerBuffFiltering)
    clickthroughPlayerAuras:SetPoint("TOPLEFT", playerAuraSettings, "BOTTOMLEFT", -10, 0)
    CreateTooltip(clickthroughPlayerAuras, L["Tooltip_Clickthrough_Player_Auras"], "ANCHOR_LEFT")

    local addCooldownFramePlayerAuras = CreateCheckbox("addCooldownFramePlayerAuras", L["Player_Aura_Cooldown_Swipe"], enablePlayerBuffFiltering)
    addCooldownFramePlayerAuras:SetPoint("TOPLEFT", clickthroughPlayerAuras, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(addCooldownFramePlayerAuras, L["Player_Aura_Cooldown_Swipe"], L["Tooltip_Player_Aura_Cooldown_Swipe_Desc"])
    addCooldownFramePlayerAuras:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local playerAuraDurationOnIcon = CreateCheckbox("playerAuraDurationOnIcon", L["Aura_Duration_On_Icon"], enablePlayerBuffFiltering, nil, BBF.RefreshAllAuraFrames)
    playerAuraDurationOnIcon:SetPoint("TOPLEFT", addCooldownFramePlayerAuras, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(playerAuraDurationOnIcon, L["Aura_Duration_On_Icon"], L["Tooltip_Aura_Duration_On_Icon_Desc"])

    local auraLegacyBorder = CreateCheckbox("auraLegacyBorder", L["Legacy_Aura_Border"], enablePlayerBuffFiltering)
    auraLegacyBorder:SetPoint("TOPLEFT", playerAuraDurationOnIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(auraLegacyBorder, L["Legacy_Aura_Border"], L["Tooltip_Legacy_Aura_Border_Desc"])
    auraLegacyBorder:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local playerAuraDurationColor = CreateCheckbox("playerAuraDurationColor", L["Duration_Text_Color"], enablePlayerBuffFiltering, nil, BBF.RefreshAllAuraFrames)
    playerAuraDurationColor:SetPoint("TOPLEFT", auraLegacyBorder, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(playerAuraDurationColor, L["Duration_Text_Color"], L["Tooltip_Duration_Text_Color_Desc"])
    AddColorButton(playerAuraDurationColor, "playerAuraDurationColorRGB", L["Duration_Text_Color"])

    local playerAuraSpacingX = CreateSlider(enablePlayerBuffFiltering, L["Horizontal_Padding"], 0, 10, 1, "playerAuraSpacingX", "X")
    playerAuraSpacingX:SetPoint("TOPLEFT", playerAuraDurationColor, "BOTTOMLEFT", 10, -20)
    CreateTooltip(playerAuraSpacingX, L["Tooltip_Horizontal_Aura_Padding"], "ANCHOR_LEFT")

    local playerAuraSpacingY = CreateSlider(enablePlayerBuffFiltering, L["Vertical_Padding"], -10, 10, 1, "playerAuraSpacingY", "Y")
    playerAuraSpacingY:SetPoint("TOP", playerAuraSpacingX, "BOTTOM", 0, -15)

    local playerAuraSortMethod = CreateSimpleDropdown("playerAuraSortMethod", enablePlayerBuffFiltering, L["Aura_Sort_Method"], "playerAuraSortMethod",
        { "blizzard", "default", "expiration", "firstending", "lastending", "name" },
        BBF.RefreshAllAuraFrames,
        { anchorFrame = playerAuraSpacingY, x = 42, y = -8 }, 130)
    CreateTooltipTwo(playerAuraSortMethod, L["Aura_Sort_Method"], L["Tooltip_Player_Aura_Sort_Method_Desc"], nil, "ANCHOR_LEFT")

    local useEditMode = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    useEditMode:SetPoint("TOP", playerAuraSortMethod, "BOTTOM", -20, -16)
    useEditMode:SetText(L["Use_Edit_Mode_For_Other_Settings"])

    enablePlayerBuffFiltering:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(enablePlayerBuffFiltering)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local moreAuraSettings = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    moreAuraSettings:SetPoint("TOPLEFT", focusBorder, "BOTTOMLEFT", 21, -8)
    moreAuraSettings:SetText(L["More_Aura_Settings"])

    local importantAurasFirst = CreateCheckbox("importantAurasFirst", L["Important_Auras_First"], playerAuraFiltering)
    importantAurasFirst:SetPoint("TOPLEFT", moreAuraSettings, "BOTTOMLEFT", -4, -6)
    CreateTooltipTwo(importantAurasFirst, L["Important_Auras_First"], L["Tooltip_Important_Auras_First_Desc"])
    importantAurasFirst:HookScript("OnClick", function()
        UpdateLeadingGlowBoxes()
    end)

    local purgeableAurasFirst = CreateCheckbox("purgeableAurasFirst", L["Purgeable_Auras_First"], playerAuraFiltering)
    purgeableAurasFirst:SetPoint("TOPLEFT", importantAurasFirst, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(purgeableAurasFirst, L["Purgeable_Auras_First"], L["Tooltip_Purgeable_Auras_First_Desc"])

    local hidePurgeTexture = CreateCheckbox("hidePurgeTexture", L["Hide_Purge_Texture"], playerAuraFiltering, nil, BBF.RefreshAllAuraFrames)
    hidePurgeTexture:SetPoint("TOPLEFT", purgeableAurasFirst, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hidePurgeTexture, L["Hide_Purge_Texture"], L["Tooltip_Hide_Purge_Texture"])

    local showPurgeTextureOnFriendly = CreateCheckbox("showPurgeTextureOnFriendly", L["Show_Purge_Texture_On_Friendly"], playerAuraFiltering, nil, BBF.RefreshAllAuraFrames)
    showPurgeTextureOnFriendly:SetPoint("TOPLEFT", hidePurgeTexture, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showPurgeTextureOnFriendly, L["Show_Purge_Texture_On_Friendly"], L["Tooltip_Show_Purge_Texture_On_Friendly"])

    local displayDispelGlowAlways = CreateCheckbox("displayDispelGlowAlways", L["Always_Show_Purge_Texture"], playerAuraFiltering, nil, BBF.RefreshAllAuraFrames)
    displayDispelGlowAlways:SetPoint("TOPLEFT", showPurgeTextureOnFriendly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(displayDispelGlowAlways, L["Always_Show_Purge_Texture"], L["Tooltip_Always_Show_Purge_Texture"])

    local changePurgeTextureColor = CreateCheckbox("changePurgeTextureColor", L["Change_Purge_Texture_Color"], playerAuraFiltering, nil, BBF.RefreshAllAuraFrames)
    changePurgeTextureColor:SetPoint("TOPLEFT", displayDispelGlowAlways, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(changePurgeTextureColor, L["Change_Purge_Texture_Color"])
    AddColorButton(changePurgeTextureColor, "purgeTextureColorRGB", L["Change_Purge_Texture_Color"])

    local function UpdatePurgeTextureBoxes()
        local hidden = hidePurgeTexture:GetChecked()
        for _, box in ipairs({ showPurgeTextureOnFriendly, displayDispelGlowAlways, changePurgeTextureColor }) do
            if hidden then
                box:Disable()
                box:SetAlpha(0.5)
            else
                box:Enable()
                box:SetAlpha(1)
            end
        end
    end
    hidePurgeTexture:HookScript("OnClick", UpdatePurgeTextureBoxes)
    UpdatePurgeTextureBoxes()

    local auraTimerColor = CreateCheckbox("auraTimerColor", L["Timer_Text_Color"], playerAuraFiltering)
    auraTimerColor:SetPoint("TOPLEFT", showAuraCdText, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(auraTimerColor, L["Timer_Text_Color"], L["Tooltip_Timer_Text_Color_Desc"])
    auraTimerColor:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)
    AddColorButton(auraTimerColor, "auraTimerBaseColor", L["Timer_Text_Color"])

    local auraTimerLowThreshold = CreateSlider(playerAuraFiltering, L["Timer_Low_Threshold"], 1, 20, 1, "auraTimerLowThreshold")
    auraTimerLowThreshold:SetPoint("TOPLEFT", auraTimerColor, "BOTTOMLEFT", 10, -20)
    auraTimerLowThreshold.integerOnly = true
    CreateTooltip(auraTimerLowThreshold, L["Tooltip_Timer_Low_Threshold"])

    local increaseAuraStrata = CreateCheckbox("increaseAuraStrata", L["Increase_Aura_Frame_Strata"], playerAuraFiltering)
    increaseAuraStrata:SetPoint("TOPLEFT", changePurgeTextureColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(increaseAuraStrata, L["Increase_Aura_Frame_Strata"], L["Tooltip_Increase_Aura_Frame_Strata"])
    increaseAuraStrata:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local hideUnitframeAuraTooltips = CreateCheckbox("hideUnitframeAuraTooltips", L["Hide_UnitFrame_Aura_Tooltips"], playerAuraFiltering)
    hideUnitframeAuraTooltips:SetPoint("TOPLEFT", increaseAuraStrata, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideUnitframeAuraTooltips, L["Hide_UnitFrame_Aura_Tooltips"], L["Tooltip_Hide_UnitFrame_Aura_Tooltips"])

    local pixelBorderAuras = CreateCheckbox("pixelBorderAuras", L["Pixel_Border_Auras"], playerAuraFiltering)
    pixelBorderAuras:SetPoint("TOPLEFT", hideUnitframeAuraTooltips, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(pixelBorderAuras, L["Pixel_Border_Auras"], L["Tooltip_Pixel_Border_Auras_Desc"])
    pixelBorderAuras:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local removeDebuffColorBorder = CreateCheckbox("removeDebuffColorBorder", L["Remove_Debuff_Color_Border"], playerAuraFiltering)
    removeDebuffColorBorder:SetPoint("TOPLEFT", pixelBorderAuras, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(removeDebuffColorBorder, L["Remove_Debuff_Color_Border"], L["Tooltip_Remove_Debuff_Color_Border"])
    removeDebuffColorBorder:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local auraTooltipSpellID = CreateCheckbox("auraTooltipSpellID", L["Aura_Tooltip_Spell_ID"], playerAuraFiltering)
    auraTooltipSpellID:SetPoint("TOPLEFT", removeDebuffColorBorder, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(auraTooltipSpellID, L["Aura_Tooltip_Spell_ID"], L["Tooltip_Aura_Tooltip_Spell_ID_Desc"])
    auraTooltipSpellID:HookScript("OnClick", function(self)
        BBF.ApplyAuraTooltipSpellID(not self:GetChecked())
    end)

    local hideLongAuraDurationText = CreateCheckbox("auraHideLongDurationText", L["Hide_Long_Aura_Duration_Text"], playerAuraFiltering, nil, BBF.RefreshAllAuraFrames)
    hideLongAuraDurationText:SetPoint("TOPLEFT", auraTooltipSpellID, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideLongAuraDurationText, L["Hide_Long_Aura_Duration_Text"], L["Tooltip_Hide_Long_Aura_Duration_Text_Desc"])

    local auraSortMethod = CreateSimpleDropdown("auraSortMethod", playerAuraFiltering, L["Aura_Sort_Method"], "auraSortMethod",
        { "blizzard", "stable", "expiration", "firstending", "lastending", "name" },
        BBF.RefreshAllAuraFrames,
        { anchorFrame = hideLongAuraDurationText, x = 30, y = -8 }, 130)
    CreateTooltipTwo(auraSortMethod, L["Aura_Sort_Method"], L["Tooltip_Aura_Sort_Method_Desc"], nil, "ANCHOR_LEFT")

    local resetAuraSettings = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetAuraSettings:SetSize(160, 22)
    resetAuraSettings:SetPoint("TOPRIGHT", auraSortMethod, "BOTTOMRIGHT", 0, -12)
    resetAuraSettings:SetText(L["Reset_All_Aura_Settings"])
    resetAuraSettings:SetScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RESET_AURA_SETTINGS")
    end)
    CreateTooltipTwo(resetAuraSettings, L["Reset_All_Aura_Settings"], L["Tooltip_Reset_All_Aura_Settings"])

    local betaHighlightIcon = playerAuraFiltering:CreateTexture(nil, "BACKGROUND")
    betaHighlightIcon:SetAtlas("CharacterCreate-NewLabel")
    betaHighlightIcon:SetSize(42, 34)
    betaHighlightIcon:SetPoint("RIGHT", playerAuraFiltering, "LEFT", 8, 0)
end

local function guiMisc()
    local guiMisc = CreateFrame("Frame")
    guiMisc.name = L["Module_Name_Misc"]
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
    settingsText:SetPoint("TOPLEFT", guiMisc, "TOPLEFT", 20, 0)
    settingsText:SetText(L["Misc_Settings"])
    local miscSettingsIcon = guiMisc:CreateTexture(nil, "ARTWORK")
    miscSettingsIcon:SetAtlas("optionsicon-brown")
    miscSettingsIcon:SetSize(22, 22)
    miscSettingsIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)

    local normalizeGameMenu = CreateCheckbox("normalizeGameMenu", L["Normal_Size_Game_Menu"], guiMisc)
    normalizeGameMenu:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltipTwo(normalizeGameMenu, L["Normal_Size_Game_Menu"], L["Tooltip_Normal_Size_Game_Menu_Desc"])
    normalizeGameMenu:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBF.NormalizeGameMenu(true)
        else
            BBF.NormalizeGameMenu(false)
        end
    end)

    local classColorFriendlist = CreateCheckbox("classColorFriendlist", L["Class_Color_Friendlist"], guiMisc)
    classColorFriendlist:SetPoint("TOPLEFT", normalizeGameMenu, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classColorFriendlist, L["Class_Color_Friendlist"], L["Tooltip_Class_Color_Friendlist_Desc"])
    classColorFriendlist:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local minimizeObjectiveTracker = CreateCheckbox("minimizeObjectiveTracker", L["Minimize_Objective_Better"], guiMisc, nil, BBF.MinimizeObjectiveTracker)
    minimizeObjectiveTracker:SetPoint("TOPLEFT", classColorFriendlist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(minimizeObjectiveTracker, L["Minimize_Objective_Better"], L["Tooltip_Minimize_Objective_Better_Desc"] .. " |A:UI-QuestTrackerButton-Collapse-All:19:19|a")

    local hideUiErrorFrame = CreateCheckbox("hideUiErrorFrame", L["Hide_UI_Error_Frame"], guiMisc, nil, BBF.HideFrames)
    hideUiErrorFrame:SetPoint("TOPLEFT", minimizeObjectiveTracker, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideUiErrorFrame, L["Hide_UI_Error_Frame"], L["Tooltip_Hide_UI_Error"])

    local fadeMicroMenu = CreateCheckbox("fadeMicroMenu", L["Fade_Micro_Menu"], guiMisc, nil, BBF.FadeMicroMenu)
    fadeMicroMenu:SetPoint("TOPLEFT", hideUiErrorFrame, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(fadeMicroMenu, L["Fade_Micro_Menu"], L["Tooltip_Fade_Micro_Menu_Desc"])

    local fadeMicroMenuExceptQueue = CreateCheckbox("fadeMicroMenuExceptQueue", L["Except_Queue_Eye"], fadeMicroMenu, nil, BBF.FadeMicroMenu)
    fadeMicroMenuExceptQueue:SetPoint("LEFT", fadeMicroMenu.text, "RIGHT", 0, 0)
    CreateTooltipTwo(fadeMicroMenuExceptQueue, L["Except_Queue_Eye"], L["Tooltip_Except_Queue_Eye_Desc"])

    fadeMicroMenu:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local moveQueueStatusEye = CreateCheckbox("moveQueueStatusEye", L["Move_Queue_Eye"], guiMisc, nil, BBF.MoveQueueStatusEye)
    moveQueueStatusEye:SetPoint("TOPLEFT", fadeMicroMenu, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(moveQueueStatusEye, L["Move_Queue_Eye"], L["Tooltip_Move_Queue_Eye_Desc"])

    moveQueueStatusEye:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local reduceEditModeSelectionAlpha = CreateCheckbox("reduceEditModeSelectionAlpha", L["Reduce_Edit_Mode_Glow"], guiMisc)
    reduceEditModeSelectionAlpha:SetPoint("TOPLEFT", moveQueueStatusEye, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(reduceEditModeSelectionAlpha, L["Reduce_Edit_Mode_Glow"], L["Tooltip_Reduce_Edit_Mode_Glow_Desc"])
    reduceEditModeSelectionAlpha:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzFramesDB.editModeSelectionAlpha = 0.15
            BBF.ReduceEditModeAlpha()
            if BBF.EditModeAlphaSlider then
                BBF.EditModeAlphaSlider:SetValue(0.15)
            end
        else
            BetterBlizzFramesDB.editModeSelectionAlpha = 1
            BBF.ReduceEditModeAlpha(true)
            if BBF.EditModeAlphaSlider then
                BBF.EditModeAlphaSlider:SetValue(1)
            end
        end
    end)

    local hideBagsBar = CreateCheckbox("hideBagsBar", L["Hide_Bags_Bar"], guiMisc, nil, BBF.HideFrames)
    hideBagsBar:SetPoint("TOPLEFT", reduceEditModeSelectionAlpha, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideBagsBar, L["Hide_Bags_Bar"], L["Tooltip_Hide_Bags_Bar_Desc"])

    hideBagsBar:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local showLastNameNpc = CreateCheckbox("showLastNameNpc", L["Tooltip_Only_Last_Name_NPCs_Desc"], guiMisc, nil, BBF.AllNameChanges)
    showLastNameNpc:SetPoint("TOPLEFT", hideBagsBar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showLastNameNpc, L["Tooltip_Only_Last_Name_NPCs_Desc"], L["Tooltip_Only_Last_Name_NPCs_Simple_Desc"])


    local moveableFPSCounter = CreateCheckbox("moveableFPSCounter", L["Moveable_FPS_Counter"], guiMisc, nil, BBF.MoveableFPSCounter)
    moveableFPSCounter:SetPoint("TOPLEFT", showLastNameNpc, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(moveableFPSCounter, L["Moveable_FPS_Counter"], L["Tooltip_Moveable_FPS_Counter_Desc"])
    moveableFPSCounter:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if IsShiftKeyDown() then
                BetterBlizzFramesDB.fpsCounterFontOutline = true
                BBF.MoveableFPSCounter(false, true)
            else
                BetterBlizzFramesDB.fpsCounterFontOutline = nil
                BBF.MoveableFPSCounter(true)
            end
        end
    end)

    local removeAddonListCategories = CreateCheckbox("removeAddonListCategories", L["Improved_AddonList"], guiMisc, nil, BBF.RemoveAddonCategories)
    removeAddonListCategories:SetPoint("TOPLEFT", moveableFPSCounter, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(removeAddonListCategories, L["Improved_AddonList"], L["Tooltip_Improved_AddonList_Desc"])

    local hideMinimap = CreateCheckbox("hideMinimap", L["Hide_Minimap"], guiMisc, nil, BBF.MinimapHider)
    hideMinimap:SetPoint("TOPLEFT", removeAddonListCategories, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local hideMinimapButtons = CreateCheckbox("hideMinimapButtons", L["Hide_Minimap_Buttons"], guiMisc, nil, BBF.HideFrames)
    hideMinimapButtons:SetPoint("TOPLEFT", hideMinimap, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hideMinimapButtons:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local hideMinimapAuto = CreateCheckbox("hideMinimapAuto", L["Hide_Minimap_Arena"], guiMisc)
    hideMinimapAuto:SetPoint("TOPLEFT", hideMinimapButtons, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideMinimapAuto, L["Tooltip_Minimap_Arena"])
    hideMinimapAuto:HookScript("OnClick", function()
        CheckAndToggleCheckboxes(hideMinimapAuto)
        BBF.MinimapHider()
    end)

    local hideMinimapAutoQueueEye = CreateCheckbox("hideMinimapAutoQueueEye", L["Hide_Queue_Eye_Arena"], guiMisc)
    hideMinimapAutoQueueEye:SetPoint("TOPLEFT", hideMinimapAuto, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideMinimapAutoQueueEye, L["Tooltip_Queue_Eye_Arena"])
    hideMinimapAutoQueueEye:HookScript("OnClick", function()
        BBF.MinimapHider()
    end)

    local hideObjectiveTracker = CreateCheckbox("hideObjectiveTracker", L["Hide_Objective_Arena"], guiMisc)
    hideObjectiveTracker:SetPoint("TOPLEFT", hideMinimapAutoQueueEye, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideObjectiveTracker, L["Tooltip_Objective_Arena"])
    hideObjectiveTracker:HookScript("OnClick", function()
        BBF.MinimapHider()
    end)

    local recolorTempHpLoss = CreateCheckbox("recolorTempHpLoss", L["Recolor_Temp_HP"], guiMisc)
    recolorTempHpLoss:SetPoint("TOPLEFT", hideObjectiveTracker, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(recolorTempHpLoss, L["Recolor_Temp_HP"], L["Tooltip_Recolor_Temp_HP_Desc"])
    recolorTempHpLoss:HookScript("OnClick", function()
        BBF.RecolorHpTempLoss()
    end)

    local hideAllAbsorbGlow = CreateCheckbox("hideAllAbsorbGlow", L["Hide_All_Absorb_Glow"], guiMisc)
    hideAllAbsorbGlow:SetPoint("TOPLEFT", recolorTempHpLoss, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideAllAbsorbGlow, L["Hide_All_Absorb_Glow"], L["Tooltip_Hide_All_Absorb_Glow_Desc"])
    hideAllAbsorbGlow:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local zoomActionBarIcons = CreateCheckbox("zoomActionBarIcons", "Zoom ActionBar Icons", guiMisc)
    zoomActionBarIcons:SetPoint("TOPLEFT", hideAllAbsorbGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(zoomActionBarIcons, "Zoom ActionBar Icons", "Zoom in on the icons on the action bar icons a little.")
    zoomActionBarIcons:HookScript("OnClick", function()
        BBF.ZoomDefaultActionbarIcons(zoomActionBarIcons:GetChecked())
    end)

    local hideActionBarHotKey = CreateCheckbox("hideActionBarHotKey", L["Hide_ActionBar_Keybinds"], guiMisc, nil, BBF.HideFrames)
    hideActionBarHotKey:SetPoint("TOPLEFT", zoomActionBarIcons, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideActionBarHotKey, L["Tooltip_Hide_Keybinds"])

    local hideActionBarMacroName = CreateCheckbox("hideActionBarMacroName", L["Hide_ActionBar_Macro"], guiMisc, nil, BBF.HideFrames)
    hideActionBarMacroName:SetPoint("TOPLEFT", hideActionBarHotKey, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideActionBarMacroName, L["Tooltip_Hide_Macro"])

    local hideActionBarQualityIcon = CreateCheckbox("hideActionBarQualityIcon", L["Hide_ActionBar_Quality"], guiMisc, nil, BBF.HideFrames)
    hideActionBarQualityIcon:SetPoint("TOPLEFT", hideActionBarMacroName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideActionBarQualityIcon, L["Tooltip_Hide_Quality"])

    local hideStanceBar = CreateCheckbox("hideStanceBar", L["Hide_StanceBar"], guiMisc, nil, BBF.HideFrames)
    hideStanceBar:SetPoint("TOPLEFT", hideActionBarQualityIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local hideDragonFlying = CreateCheckbox("hideDragonFlying", L["Auto_Hide_Dragonriding"], guiMisc)
    hideDragonFlying:SetPoint("TOPLEFT", hideStanceBar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideDragonFlying, L["Tooltip_Dragonriding"])

    local stealthIndicatorPlayer = CreateCheckbox("stealthIndicatorPlayer", L["Tooltip_Stealth_Indicator"], guiMisc, nil, BBF.StealthIndicator)
    stealthIndicatorPlayer:SetPoint("TOPLEFT", hideDragonFlying, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(stealthIndicatorPlayer, L["Tooltip_Stealth"])

    local useMiniPlayerFrame = CreateCheckbox("useMiniPlayerFrame", L["Mini_PlayerFrame"], guiMisc)
    useMiniPlayerFrame:SetPoint("TOPLEFT", stealthIndicatorPlayer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(useMiniPlayerFrame, L["Tooltip_Mini_Player"])
    useMiniPlayerFrame:HookScript("OnClick", function(self)
        BBF.MiniFrame(PlayerFrame)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local useMiniTargetFrame = CreateCheckbox("useMiniTargetFrame", L["Mini_TargetFrame"], guiMisc)
    useMiniTargetFrame:SetPoint("LEFT", useMiniPlayerFrame.Text, "RIGHT", 0, 0)
    CreateTooltip(useMiniTargetFrame, L["Tooltip_Mini_Target"])
    useMiniTargetFrame:HookScript("OnClick", function(self)
        BBF.MiniFrame(TargetFrame)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local useMiniFocusFrame = CreateCheckbox("useMiniFocusFrame", L["Mini_FocusFrame"], guiMisc)
    useMiniFocusFrame:SetPoint("LEFT", useMiniTargetFrame.Text, "RIGHT", 0, 0)
    CreateTooltip(useMiniFocusFrame, L["Tooltip_Mini_Focus"])
    useMiniFocusFrame:HookScript("OnClick", function(self)
        BBF.MiniFrame(FocusFrame)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local surrenderArena = CreateCheckbox("surrenderArena", L["Surrender_Arena"], guiMisc)
    surrenderArena:SetPoint("TOPLEFT", useMiniPlayerFrame, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(surrenderArena, L["Surrender_Arena"], L["Tooltip_Surrender_Arena_Desc"])

    -- local druidOverstacks = CreateCheckbox("druidOverstacks", L["Druid_Berserk_Blue"], guiMisc)
    -- druidOverstacks:SetPoint("TOPLEFT", surrenderArena, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltipTwo(druidOverstacks, L["Druid_Berserk_Blue"], L["Tooltip_Druid_Berserk"])
    -- druidOverstacks:HookScript("OnClick", function(self)
    --     BBF.DruidBlueComboPoints()
    --     if not self:GetChecked() then
    --         StaticPopup_Show("BBF_CONFIRM_RELOAD")
    --     end
    -- end) -- isMidnight

    local druidAlwaysShowCombos = CreateCheckbox("druidAlwaysShowCombos", L["Druid_Always_Combos"], guiMisc)
    druidAlwaysShowCombos:SetPoint("TOPLEFT", surrenderArena, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(druidAlwaysShowCombos, L["Druid_Always_Combos"], L["Tooltip_Druid_Always_Combos_Desc"])
    druidAlwaysShowCombos:HookScript("OnClick", function(self)
        BBF.DruidAlwaysShowCombos()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local createAltManaBarDruid = CreateCheckbox("createAltManaBarDruid", L["Druid_Manabar_CatBear"], guiMisc)
    createAltManaBarDruid:SetPoint("TOPLEFT", druidAlwaysShowCombos, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(createAltManaBarDruid, L["Druid_Manabar_CatBear"], L["Tooltip_Druid_Manabar_Desc"])
        createAltManaBarDruid:HookScript("OnClick", function(self)
        BBF.CreateAltManaBar()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local hideTalkingHeads = CreateCheckbox("hideTalkingHeads", L["Hide_Talking_Heads"], guiMisc, nil, BBF.HideTalkingHeads)
    hideTalkingHeads:SetPoint("TOPLEFT", createAltManaBarDruid, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideTalkingHeads, L["Hide_Talking_Heads"], L["Tooltip_Hide_Talking_Heads_Desc"])
    hideTalkingHeads:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local hideExpAndHonorBar = CreateCheckbox("hideExpAndHonorBar", L["Hide_XP_Honor"], guiMisc, nil, BBF.HideFrames)
    hideExpAndHonorBar:SetPoint("TOPLEFT", hideTalkingHeads, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideExpAndHonorBar, L["Hide_XP_Honor"], L["Tooltip_Hide_XP_Honor_Desc"])
    hideExpAndHonorBar:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local disableCastbarMovement = CreateCheckbox("disableCastbarMovement", L["Disable_Castbar_Movement"], guiMisc)
    disableCastbarMovement:SetPoint("TOPLEFT", hideExpAndHonorBar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(disableCastbarMovement, L["Disable_Castbar_Movement"], L["Tooltip_Disable_Castbar_Movement_Desc"])
    disableCastbarMovement:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local disableCastbarTweaks = CreateCheckbox("disableCastbarTweaks", L["Disable_Castbar_Tweaks"], guiMisc)
    disableCastbarTweaks:SetPoint("LEFT", disableCastbarMovement.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(disableCastbarTweaks, L["Disable_Castbar_Tweaks"], L["Tooltip_Disable_Castbar_Tweaks_Desc"])
    disableCastbarTweaks:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    -- local disableAddonProfiling = CreateCheckbox("disableAddonProfiling", "Disable AddOn Profiler", guiMisc)
    -- disableAddonProfiling:SetPoint("TOPLEFT", hideExpAndHonorBar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltipTwo(disableAddonProfiling, L["Disable_AddOn_Profiler"], L["Tooltip_Disable_AddOn_Profiler"])
    -- disableAddonProfiling:HookScript("OnClick", function(self)
    --     StaticPopup_Show("BBF_CONFIRM_RELOAD")
    -- end)

    local arenaOptimizer = CreateCheckbox("arenaOptimizer", L["Arena_Optimizer"], guiMisc)
    arenaOptimizer:SetPoint("TOPLEFT", disableCastbarMovement, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(arenaOptimizer, L["Arena_Optimizer"], L["Tooltip_Arena_Optimizer"])
    arenaOptimizer:HookScript("OnClick", function(self)
        BBF.ArenaOptimizer(not self:GetChecked(), true)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local gladWinTracker = CreateCheckbox("gladWinTracker", L["Glad_Win_Tracker"], guiMisc)
    gladWinTracker:SetPoint("TOPLEFT", arenaOptimizer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(gladWinTracker, L["Glad_Win_Tracker"], L["Tooltip_Glad_Tracker"])
    gladWinTracker:HookScript("OnClick", function(self)
        BBF.GladTracker()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local externalDefensivesHideTooltip = CreateCheckbox("externalDefensivesHideTooltip", L["External_Defensives_Hide_Tooltip"], guiMisc, nil, BBF.ExternalDefensivesClickthrough)
    externalDefensivesHideTooltip:SetPoint("TOPLEFT", gladWinTracker, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(externalDefensivesHideTooltip, L["External_Defensives_Hide_Tooltip"], L["Tooltip_External_Defensives_Hide_Tooltip"])

    local uiWidgetPowerBarScale = CreateSlider(guiMisc, L["UIWidgetPowerBarFrame_Scale"], 0.4, 1.8, 0.01, "uiWidgetPowerBarScale")
    uiWidgetPowerBarScale:SetPoint("LEFT", gladWinTracker.text, "RIGHT", 55, 0)
    CreateTooltipTwo(uiWidgetPowerBarScale, L["UIWidgetPowerBarFrame_Scale"], L["Tooltip_UIWidgetPowerBar_Scale_Desc"])

    local bbfBigPlayerHealthbar = CreateCheckbox("bigPlayerHealthbar", L["Big_PlayerHealthbar"], guiMisc, nil, BBF.UpdateBigPlayerHealthbar)
    bbfBigPlayerHealthbar:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", 320, 17)
    CreateTooltipTwo(bbfBigPlayerHealthbar, L["Big_PlayerHealthbar"], L["Tooltip_Big_PlayerHealthbar_Desc"])

    local hideUnitFramePlayerMana = CreateCheckbox("hideUnitFramePlayerMana", L["Hide_PlayerFrame_Mana"], guiMisc, nil, BBF.UpdateNoPortraitManaVisibility)
    hideUnitFramePlayerMana:SetPoint("TOPLEFT", bbfBigPlayerHealthbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideUnitFramePlayerMana, L["Hide_PlayerFrame_Mana"], L["Tooltip_Hide_Player_Mana"])

    local hideAllManabarText = CreateCheckbox("hideAllManabarText", L["Hide_All_Manabar_Text"], guiMisc, nil, BBF.HideFrames)
    hideAllManabarText:SetPoint("LEFT", hideUnitFramePlayerMana.text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideAllManabarText, L["Hide_All_Manabar_Text"], L["Tooltip_Hide_All_Manabar_Text_Desc"])

    local hideUnitFramePlayerSecondResource = CreateCheckbox("hideUnitFramePlayerSecondResource", L["Hide_PlayerFrame_2nd_Bar"], guiMisc, nil, BBF.UpdateNoPortraitManaVisibility)
    hideUnitFramePlayerSecondResource:SetPoint("TOPLEFT", hideUnitFramePlayerMana, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideUnitFramePlayerSecondResource, L["Hide_PlayerFrame_2nd_Bar"], L["Tooltip_Hide_2nd_Bar"])

    local hideUnitFrameTargetMana = CreateCheckbox("hideUnitFrameTargetMana", L["Hide_TargetFrame_Mana"], guiMisc, nil, BBF.UpdateNoPortraitManaVisibility)
    hideUnitFrameTargetMana:SetPoint("TOPLEFT", hideUnitFramePlayerSecondResource, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideUnitFrameTargetMana, L["Hide_TargetFrame_Mana"], L["Tooltip_Hide_Target_Mana"])

    local hideUnitFrameFocusMana = CreateCheckbox("hideUnitFrameFocusMana", L["Hide_FocusFrame_Mana"], guiMisc, nil, BBF.UpdateNoPortraitManaVisibility)
    hideUnitFrameFocusMana:SetPoint("TOPLEFT", hideUnitFrameTargetMana, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideUnitFrameFocusMana, L["Hide_FocusFrame_Mana"], L["Tooltip_Hide_Focus_Mana"])

    local hideDefaultPartyFramesMana = CreateCheckbox("hideDefaultPartyFramesMana", L["Hide_Default_PartyFrames_Mana"], guiMisc, nil, BBF.UpdateNoPortraitManaVisibility)
    hideDefaultPartyFramesMana:SetPoint("TOPLEFT", hideUnitFrameFocusMana, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideDefaultPartyFramesMana, L["Hide_Default_PartyFrames_Mana"], L["Tooltip_Hide_Default_PartyFrames_Mana_Desc"])

    local hideOgRaidFrameBg = CreateCheckbox("hideOgRaidFrameBg", L["Hide_Party_RaidFrame_Background"], guiMisc, nil, BBF.HideFrames)
    hideOgRaidFrameBg:SetPoint("TOPLEFT", hideDefaultPartyFramesMana, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideOgRaidFrameBg, L["Hide_Party_RaidFrame_Background"], L["Tooltip_Hide_Party_RaidFrame_Background_Desc"])

    local cdManagerCenterIcons = CreateCheckbox("cdManagerCenterIcons", L["CDM_Center_Icons"], guiMisc, nil, BBF.HookCooldownManagerTweaks)
    cdManagerCenterIcons:SetPoint("TOPLEFT", hideOgRaidFrameBg, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(cdManagerCenterIcons, L["CDM_Center_Icons"], L["CDM_Center_Icons_Tooltip"])
    cdManagerCenterIcons:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local actionBarCDNumberSizeChange = CreateCheckbox("actionBarCDNumberSizeChange", L["Change_ActionBar_CD_Size"], guiMisc)
    actionBarCDNumberSizeChange:SetPoint("TOPLEFT", cdManagerCenterIcons, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(actionBarCDNumberSizeChange, L["Change_ActionBar_CD_Size"], L["Tooltip_Change_ActionBar_CD_Size_Desc"])

    local actionBarCDNumberScaleSlider = CreateSlider(actionBarCDNumberSizeChange, L["ActionBar_CD_Size"], 0.5, 2, 0.01, "actionBarCDNumberScale", nil, 90)
    actionBarCDNumberScaleSlider:SetPoint("LEFT", actionBarCDNumberSizeChange.text, "RIGHT", 3, -3)
    CreateTooltipTwo(actionBarCDNumberScaleSlider, L["Change_ActionBar_CD_Size"], L["Tooltip_Change_ActionBar_CD_Size_Desc"])
    actionBarCDNumberScaleSlider:SetScale(0.9)

    actionBarCDNumberSizeChange:HookScript("OnClick", function(self)
        BBF.ActionBarCDNumberSize()
        if not self:GetChecked() then
            DisableElement(actionBarCDNumberScaleSlider)
        else
            EnableElement(actionBarCDNumberScaleSlider)
        end
    end)

    local hideActionBar1 = CreateCheckbox("hideActionBar1", L["Hide_ActionBar1"], guiMisc, nil, BBF.HideFrames)
    hideActionBar1:SetPoint("TOPLEFT", actionBarCDNumberSizeChange, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideActionBar1, L["Hide_ActionBar1"], L["Tooltip_Hide_ActionBar1"])
    hideActionBar1:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local hideActionBarBigProcGlow = CreateCheckbox("hideActionBarBigProcGlow", L["Hide_ActionBar_Big_Proc_Glow"], guiMisc, nil, BBF.ActionBarMods)
    hideActionBarBigProcGlow:SetPoint("TOPLEFT", hideActionBar1, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideActionBarBigProcGlow, L["Hide_Actionbar_Big_Proc_Glow"], L["Tooltip_Hide_ActionBar_Big_Proc_Glow_Desc"])

    local hideActionBarCastAnimation = CreateCheckbox("hideActionBarCastAnimation", L["Hide_ActionBar_Cast_Animation"], guiMisc, nil, BBF.ActionBarMods)
    hideActionBarCastAnimation:SetPoint("TOPLEFT", hideActionBarBigProcGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideActionBarCastAnimation, L["Hide_ActionBar_Cast_Animation"], L["Tooltip_Hide_ActionBar_Cast_Animation_Desc"])

    local hideActionBarActiveOverlay = CreateCheckbox("hideActionBarActiveOverlay", L["Hide_ActionBar_Active_Overlay"], guiMisc, nil, BBF.HideFrames)
    hideActionBarActiveOverlay:SetPoint("TOPLEFT", hideActionBarCastAnimation, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideActionBarActiveOverlay, L["Hide_ActionBar_Active_Overlay"], L["Tooltip_Hide_ActionBar_Active_Overlay"])

    local hideActionBarEquippedOverlay = CreateCheckbox("hideActionBarEquippedOverlay", L["Hide_ActionBar_Equipped_Overlay"], guiMisc, nil, BBF.HideFrames)
    hideActionBarEquippedOverlay:SetPoint("TOPLEFT", hideActionBarActiveOverlay, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideActionBarEquippedOverlay, L["Hide_ActionBar_Equipped_Overlay"], L["Tooltip_Hide_ActionBar_Equipped_Overlay_Desc"])

    local fixActionBarCDs = CreateCheckbox("fixActionBarCDs", L["Fix_ActionBar_Cooldowns_CC"], guiMisc, nil, BBF.ShowCooldownDuringCC)
    fixActionBarCDs:SetPoint("TOPLEFT", hideActionBarEquippedOverlay, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(fixActionBarCDs, L["Fix_ActionBar_Cooldowns_CC"], L["Tooltip_Fix_ActionBar_CDs_Desc"])

    fixActionBarCDs:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local raiseTargetFrameLevel = CreateCheckbox("raiseTargetFrameLevel", L["Raise_TargetFrame_Layer"], guiMisc, nil, BBF.RaiseTargetFrameLevel)
    raiseTargetFrameLevel:SetPoint("TOPLEFT", fixActionBarCDs, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(raiseTargetFrameLevel, L["Raise_TargetFrame_Layer"], L["Tooltip_Raise_TargetFrame_Layer_Desc"])

    local enableLegacyComboPoints = CreateCheckbox("enableLegacyComboPoints", L["Legacy_Combo_Points"], guiMisc)
    enableLegacyComboPoints:SetPoint("TOPLEFT", raiseTargetFrameLevel, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(enableLegacyComboPoints, L["Legacy_Combo_Points"], L["Tooltip_Legacy_Combo_Points_Desc"])
    enableLegacyComboPoints:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
        if not self:GetChecked() then
            BetterBlizzFramesDB.legacyCombosTurnedOff = true
        else
            BetterBlizzFramesDB.legacyCombosTurnedOff = nil
        end
        if not InCombatLockdown() then
            BBF.FixLegacyComboPointsLocation()
        end
        CheckAndToggleCheckboxes(self)
    end)

    function BBF.OpenLegacyComboSliderWindow(launch)
        if not BBF.ComboSliderWindow then
            local f = CreateFrame("Frame", "BBFComboSliderWindow", UIParent, "BasicFrameTemplateWithInset")
            f:SetSize(210, 165)
            f:SetPoint("RIGHT", enableLegacyComboPoints, "LEFT", -10, 0)
            f:SetMovable(true)
            f:EnableMouse(true)
            f:RegisterForDrag("LeftButton")
            f:SetScript("OnDragStart", f.StartMoving)
            f:SetScript("OnDragStop", f.StopMovingOrSizing)
            f:SetFrameStrata("DIALOG")
            f:SetClampedToScreen(true)
            f:SetToplevel(true)

            f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            f.title:SetPoint("TOP", f, "TOP", 0, -6)
            f.title:SetText(L["Legacy_Combo_Position"])

            BBF.ComboSliderWindow = f

            local sizeSlider = CreateSlider(f, L["Size"], 0.6, 1.3, 0.01, "legacyComboScale", nil, 140)
            sizeSlider:SetPoint("TOP", f, "TOP", 0, -45)
            CreateTooltipTwo(sizeSlider, L["Tooltip_Legacy_Combo_Points_Size"])

            local xOffsetSlider = CreateSlider(f, L["X_Offset"], -60, 10, 0.5, "legacyComboXPos", true, 140)
            xOffsetSlider:SetPoint("TOP", sizeSlider, "TOP", 0, -30)
            CreateTooltipTwo(xOffsetSlider, L["Tooltip_Legacy_Combo_Points_X_Offset"])

            local yOffsetSlider = CreateSlider(f, L["Y_Offset"], -60, 10, 0.5, "legacyComboYPos", true, 140)
            yOffsetSlider:SetPoint("TOP", xOffsetSlider, "TOP", 0, -30)
            CreateTooltipTwo(yOffsetSlider, L["Tooltip_FocusToT_Adjustment_Offset_Y"])

            local defaultButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
            defaultButton:SetSize(80, 22)
            defaultButton:SetText(L["Default"])
            defaultButton:SetPoint("BOTTOM", f, "BOTTOM", 0, 10)

            defaultButton:SetScript("OnClick", function()
                BetterBlizzFramesDB.legacyComboXPos = -28
                BetterBlizzFramesDB.legacyComboYPos = -25
                BetterBlizzFramesDB.legacyComboScale = 0.85
                BBF.UpdateLegacyComboPosition()
                sizeSlider:SetValue(0.85)
                xOffsetSlider:SetValue(-28)
                yOffsetSlider:SetValue(-25)
            end)

            f:Hide()
        end

        if launch then
            BBF.ComboSliderWindow:Hide()
            return
        end

        if BBF.ComboSliderWindow:IsShown() then
            BBF.ComboSliderWindow:Hide()
        else
            BBF.ComboSliderWindow:Show()
        end
    end
    BBF.OpenLegacyComboSliderWindow(true)

    enableLegacyComboPoints:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            BBF.OpenLegacyComboSliderWindow()
        end
    end)

    local legacyBlueComboPoints = CreateCheckbox("legacyBlueComboPoints", L["Blue_Combos"], enableLegacyComboPoints)
    legacyBlueComboPoints:SetPoint("LEFT", enableLegacyComboPoints.text, "RIGHT", 0, 0)
    legacyBlueComboPoints:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)
    CreateTooltipTwo(legacyBlueComboPoints, L["Blue_Legacy_Combo_Points"], L["Tooltip_Blue_Legacy_Combo_Points_Desc"])

    local alwaysShowLegacyComboPoints = CreateCheckbox("alwaysShowLegacyComboPoints", L["Show_Always"], enableLegacyComboPoints)
    alwaysShowLegacyComboPoints:SetPoint("LEFT", legacyBlueComboPoints.text, "RIGHT", 0, 0)
    alwaysShowLegacyComboPoints:HookScript("OnClick", function()
        BBF.AlwaysShowLegacyComboPoints()
    end)
    CreateTooltipTwo(alwaysShowLegacyComboPoints, L["Show_Always"], L["Tooltip_Show_Always_Legacy_Desc"])

    local enableLegacyComboPointsMulticlass = CreateCheckbox("enableLegacyComboPointsMulticlass", L["Tooltip_Legacy_Combo_Points_More_Classes_Desc"], enableLegacyComboPoints)
    enableLegacyComboPointsMulticlass:SetPoint("TOPLEFT", enableLegacyComboPoints, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(enableLegacyComboPointsMulticlass, L["Tooltip_Legacy_Combo_Points_More_Classes_Desc"], L["Tooltip_Legacy_Combo_Multiclass_Desc"])
    enableLegacyComboPointsMulticlass:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
        BBF.GenericLegacyComboSupport()
    end)

    local legacyMulticlassComboClassColor = CreateCheckbox("legacyMulticlassComboClassColor", L["Class_Color_Combo"], enableLegacyComboPointsMulticlass)
    legacyMulticlassComboClassColor:SetPoint("LEFT", enableLegacyComboPointsMulticlass.text, "RIGHT", 0, 0)
    legacyMulticlassComboClassColor:HookScript("OnClick", function()
        BBF.ClassColorLegacyCombos()
    end)
    CreateTooltipTwo(legacyMulticlassComboClassColor, L["Class_Color_Legacy_Combos"], L["Tooltip_Class_Color_Legacy_Combos_Desc"])


    local instantComboPoints = CreateCheckbox("instantComboPoints", L["Instant_Combo_Points"], guiMisc, nil, BBF.InstantComboPoints)
    instantComboPoints:SetPoint("TOPLEFT", enableLegacyComboPointsMulticlass, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(instantComboPoints, L["Instant_Combo_Points"],
    "Remove the combo point animations for instant feedback.\n\nCurrently works for:\n|cFFFFF569Rogue|r\n|cFFFF7D0ADruid|r\n|cFF00FF96Monk|r\n|cFF3FC7EBMage|r\n|cFFF58CBAPaladin|r\n|cFFAAAAAALegacy Combos (Rogue & Druid)|r")
    instantComboPoints:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
            if BetterBlizzPlatesDB then
                BetterBlizzPlatesDB.instantComboPoints = false
            end
        end
    end)

    local moveResource = CreateCheckbox("moveResource", L["Move_Resource"], guiMisc)
    moveResource:SetPoint("TOPLEFT", instantComboPoints, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(moveResource, L["Move_Resource"], string.format(L["Tooltip_Move_Resource_Desc"], playerClass), L["Tooltip_Move_Resource_SubText"])
    moveResource:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBF.EnableResourceMovement()
        end
    end)
    if not (BetterBlizzFramesDB.moveResourceStackPos and BetterBlizzFramesDB.moveResourceStackPos[playerClass]) then
        moveResource:SetChecked(false)
        BetterBlizzFramesDB.moveResource = false
    end

    local moveResourceToTarget = CreateCheckbox("moveResourceToTarget", L["Move_Resource_To_TargetFrame"], guiMisc)
    moveResourceToTarget:SetPoint("TOPLEFT", moveResource, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTarget, L["Tooltip_Move_Resource_To_Target"])

    local moveResourceToTargetCustom = CreateCheckbox("moveResourceToTargetCustom", L["Free_Move"], moveResourceToTarget)
    moveResourceToTargetCustom:SetPoint("LEFT", moveResourceToTarget.text, "RIGHT", 0, 0)
    moveResourceToTargetCustom:HookScript("OnClick", function(self)
        if self:GetChecked() then
            if BBF.ToggleEditMode then
                BBF.ToggleEditMode(true)
            end
            BBF.UpdateClassComboPoints()
        else
            if BBF.ToggleEditMode then
                BBF.ToggleEditMode(false)
            end
            BBF.UpdateClassComboPoints()
        end
    end)
    CreateTooltipTwo(moveResourceToTargetCustom, L["Free_Move_Resource_Tooltip"], L["Tooltip_Free_Move_Resource_Desc"] .. playerClass, L["Tooltip_Free_Move_Resource_SubText"])

    local moveResourceToTargetRogue = CreateCheckbox("moveResourceToTargetRogue", L["Rogue_Combo_Points"], moveResourceToTarget)
    moveResourceToTargetRogue:SetPoint("TOPLEFT", moveResourceToTarget, "BOTTOMLEFT", 12, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetRogue, L["Tooltip_Move_Resource_Rogue"])
    moveResourceToTargetRogue:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetDruid = CreateCheckbox("moveResourceToTargetDruid", L["Druid_Combo_Points"], moveResourceToTarget)
    moveResourceToTargetDruid:SetPoint("TOPLEFT", moveResourceToTargetRogue, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetDruid, L["Tooltip_Move_Resource_Druid"])
    moveResourceToTargetDruid:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetMonk = CreateCheckbox("moveResourceToTargetMonk", L["Monk_Chi_Points"], moveResourceToTarget)
    moveResourceToTargetMonk:SetPoint("TOPLEFT", moveResourceToTargetDruid, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetMonk, L["Tooltip_Move_Resource_Monk"])
    moveResourceToTargetMonk:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetWarlock = CreateCheckbox("moveResourceToTargetWarlock", L["Warlock_Shards"], moveResourceToTarget)
    moveResourceToTargetWarlock:SetPoint("TOPLEFT", moveResourceToTargetMonk, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetWarlock, L["Tooltip_Move_Resource_Warlock"])
    moveResourceToTargetWarlock:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetEvoker = CreateCheckbox("moveResourceToTargetEvoker", L["Evoker_Essence"], moveResourceToTarget)
    moveResourceToTargetEvoker:SetPoint("TOPLEFT", moveResourceToTargetWarlock, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetEvoker, L["Tooltip_Move_Resource_Evoker"])
    moveResourceToTargetEvoker:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetMage = CreateCheckbox("moveResourceToTargetMage", L["Mage_Arcane_Charges"], moveResourceToTarget)
    moveResourceToTargetMage:SetPoint("TOPLEFT", moveResourceToTargetEvoker, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetMage, L["Tooltip_Move_Resource_Mage"])
    moveResourceToTargetMage:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetDK = CreateCheckbox("moveResourceToTargetDK", L["Death_Knight_Runes"], moveResourceToTarget)
    moveResourceToTargetDK:SetPoint("TOPLEFT", moveResourceToTargetMage, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetDK, L["Tooltip_Move_Resource_DK"])
    moveResourceToTargetDK:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetPaladin = CreateCheckbox("moveResourceToTargetPaladin", L["Paladin_Holy_Charges"], moveResourceToTarget)
    moveResourceToTargetPaladin:SetPoint("TOPLEFT", moveResourceToTargetDK, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetPaladin, L["Tooltip_Move_Resource_Paladin"])
    moveResourceToTargetPaladin:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetPaladinBG = CreateCheckbox("moveResourceToTargetPaladinBG", L["BG"], moveResourceToTargetPaladin)
    moveResourceToTargetPaladinBG:SetPoint("LEFT", moveResourceToTargetPaladin.text, "RIGHT", 0, 0)
    CreateTooltipTwo(moveResourceToTargetPaladinBG, L["Background"], L["Tooltip_Paladin_Background_Desc"])

    moveResourceToTargetPaladinBG:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    moveResourceToTargetPaladin:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
    end)

    local key = "classResource" .. playerClass .. "Scale"
    local classResourceScale = CreateSlider(guiMisc, L["Class_Resource_Scale"], 0.4, 2, 0.01, key)
    classResourceScale:SetPoint("TOPLEFT", moveResourceToTargetPaladin, "BOTTOMLEFT", 5, -15)
    CreateTooltipTwo(classResourceScale, L["Class_Resource_Scale"], L["Tooltip_Class_Resource_Scale_Desc"], L["Tooltip_Class_Resource_Scale_Extra"])

    moveResource:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if BetterBlizzFramesDB.moveResourceStackPos then
                BetterBlizzFramesDB.moveResourceStackPos[playerClass] = nil
            end
            classResourceScale:SetValue(1)
            BBF.Print(string.format(L["Print_Combo_Points_Reset"], playerClass))
            BBF.ResetResourcePosition()
        end
    end)

    moveResourceToTargetCustom:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if BetterBlizzFramesDB.customComboPositions then
                BetterBlizzFramesDB.customComboPositions[playerClass] = nil
            end
            classResourceScale:SetValue(1)
            BBF.Print(string.format(L["Print_Combo_Points_Reset"], playerClass))
            BBF.UpdateClassComboPoints()
        end
    end)

    moveResourceToTarget:HookScript("OnClick", function(self)
        if self:GetChecked() then
            classResourceScale:SetValue(1)
        end
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
        CheckAndToggleCheckboxes(moveResourceToTarget)
    end)



    local rpNames = CreateCheckbox("rpNames", L["Roleplay_Names_TRP3"], guiMisc)
    rpNames:SetPoint("BOTTOMRIGHT", guiMisc, "BOTTOMRIGHT", -220, 50)
    CreateTooltipTwo(rpNames, L["Roleplay_Names_Tooltip"], L["Tooltip_Roleplay_Names_Desc"])

    local rpNamesFirst = CreateCheckbox("rpNamesFirst", L["First"], rpNames)
    rpNamesFirst:SetPoint("LEFT", rpNames.text, "RIGHT", 0, 0)
    CreateTooltipTwo(rpNamesFirst, L["First_Name_TRP3"], L["Tooltip_RP_First_Name_Desc"])

    local rpNamesLast = CreateCheckbox("rpNamesLast", L["Last"], rpNames)
    rpNamesLast:SetPoint("LEFT", rpNamesFirst.text, "RIGHT", 0, 0)
    CreateTooltipTwo(rpNamesLast, L["Last_Name_TRP3"], L["Tooltip_RP_Last_Name_Desc"])

    local rpNamesColor = CreateCheckbox("rpNamesColor", L["RP_Name_Text_Color"], guiMisc)
    rpNamesColor:SetPoint("TOPLEFT", rpNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(rpNamesColor, L["Roleplay_Name_Text_Color"], L["Tooltip_Roleplay_Name_Text_Color_Desc"])

    rpNames:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
        BBF.AllNameChanges()
    end)

    rpNamesFirst:HookScript("OnClick", function(self)
        BBF.AllNameChanges()
    end)

    rpNamesLast:HookScript("OnClick", function(self)
        BBF.AllNameChanges()
    end)

    rpNamesColor:HookScript("OnClick", function(self)
        BBF.AllNameChanges()
    end)

    local rpNamesHealthbarColor = CreateCheckbox("rpNamesHealthbarColor", L["RP_Healthbar_Color"], guiMisc)
    rpNamesHealthbarColor:SetPoint("TOPLEFT", rpNamesColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(rpNamesHealthbarColor, L["Roleplay_Healthbar_Color"], L["Tooltip_Roleplay_Healthbar_Color_Desc"])

    rpNamesHealthbarColor:HookScript("OnClick", function(self)
        BBF.HookHealthbarColors()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local rpNamesFrameTextureColor = CreateCheckbox("rpNamesFrameTextureColor", L["RP_FrameTexture_Color"], guiMisc)
    rpNamesFrameTextureColor:SetPoint("TOPLEFT", rpNamesHealthbarColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(rpNamesFrameTextureColor, L["Roleplay_FrameTexture_Color"], L["Tooltip_RP_FrameTexture_Color_Desc"])

    rpNamesFrameTextureColor:HookScript("OnClick", function(self)
        BBF.HookFrameTextureColor()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

end

local function guiImportAndExport()
    local guiImportAndExport = CreateFrame("Frame")
    guiImportAndExport.name = L["Module_Name_Import_Export"]
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

    local fullProfile = CreateImportExportUI(guiImportAndExport, "Full Profile", BetterBlizzFramesDB, 20, -20, "fullProfile")

    local auraWhitelist = CreateImportExportUI(fullProfile, L["Aura_Whitelist"], BetterBlizzFramesDB.auraWhitelist, 0, -100, "auraWhitelist")
    local auraBlacklist = CreateImportExportUI(auraWhitelist, L["Aura_Blacklist"], BetterBlizzFramesDB.auraBlacklist, 210, 0, "auraBlacklist")

    -- local importPVPWhitelist = CreateFrame("Button", nil, guiImportAndExport, "UIPanelButtonTemplate")
    -- importPVPWhitelist:SetSize(150, 35)
    -- importPVPWhitelist:SetPoint("TOP", auraWhitelist, "BOTTOM", 0, -25)
    -- importPVPWhitelist:SetText(L["Import_PvP_Whitelist"])
    -- importPVPWhitelist:SetScript("OnClick", function()
    --     StaticPopup_Show("BBF_CONFIRM_PVP_WHITELIST")
    -- end)
    -- local coloredText = L["Whitelist_Colors"]

    -- CreateTooltipTwo(importPVPWhitelist, L["Import_PvP_Whitelist"], string.format(L["Tooltip_Import_PvP_Whitelist_Desc"], coloredText))

    -- local importPVPBlacklist = CreateFrame("Button", nil, guiImportAndExport, "UIPanelButtonTemplate")
    -- importPVPBlacklist:SetSize(150, 35)
    -- importPVPBlacklist:SetPoint("TOP", auraBlacklist, "BOTTOM", 0, -25)
    -- importPVPBlacklist:SetText(L["Import_PvP_Blacklist"])
    -- importPVPBlacklist:SetScript("OnClick", function()
    --     StaticPopup_Show("BBF_CONFIRM_PVP_BLACKLIST")
    -- end)
    -- CreateTooltipTwo(importPVPBlacklist, L["Import_PvP_Blacklist"], L["Tooltip_Import_Blacklist_Desc"])

end

local function guiCustomCode()
    local guiCustomCode = CreateFrame("Frame")
    guiCustomCode.name = L["Module_Name_Custom_Code"]
    guiCustomCode.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(guiCustomCode)
    local guiCustomCodeSubCategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, guiCustomCode, guiCustomCode.name, guiCustomCode.name)
    BBF.guiCustomCode = guiCustomCode.name
    CreateTitle(guiCustomCode)

    local bgImg = guiCustomCode:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiCustomCode, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local discordLinkEditBox = CreateFrame("EditBox", nil, guiCustomCode, "InputBoxTemplate")
    discordLinkEditBox:SetPoint("TOPLEFT", guiCustomCode, "TOPLEFT", 25, -45)
    discordLinkEditBox:SetSize(180, 20)
    discordLinkEditBox:SetAutoFocus(false)
    discordLinkEditBox:SetFontObject("ChatFontSmall")
    discordLinkEditBox:SetText("https://discord.gg/cjqVaEMm25")
    discordLinkEditBox:SetCursorPosition(0)
    discordLinkEditBox:ClearFocus()
    discordLinkEditBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    discordLinkEditBox:SetScript("OnTextChanged", function(self)
        self:SetText("https://discord.gg/cjqVaEMm25")
    end)
    discordLinkEditBox:SetScript("OnCursorChanged", function() end)
    discordLinkEditBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    discordLinkEditBox:SetScript("OnMouseUp", function(self)
        if not self:IsMouseOver() then
            self:ClearFocus()
        end
    end)

    local discordText = guiCustomCode:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    discordText:SetPoint("BOTTOM", discordLinkEditBox, "TOP", 18, 8)
    discordText:SetText(L["Discord_Text"])

    local joinDiscord = guiCustomCode:CreateTexture(nil, "ARTWORK")
    joinDiscord:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\logos\\discord.tga")
    joinDiscord:SetSize(52, 52)
    joinDiscord:SetPoint("RIGHT", discordText, "LEFT", 0, 1)

    local boxOne = CreateFrame("EditBox", nil, guiCustomCode, "InputBoxTemplate")
    boxOne:SetPoint("LEFT", discordLinkEditBox, "RIGHT", 50, 0)
    boxOne:SetSize(180, 20)
    boxOne:SetAutoFocus(false)
    boxOne:SetFontObject("ChatFontSmall")
    boxOne:SetText("https://patreon.com/bodifydev")
    boxOne:SetCursorPosition(0)
    boxOne:ClearFocus()
    boxOne:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    boxOne:SetScript("OnTextChanged", function(self)
        self:SetText("https://patreon.com/bodifydev")
    end)
    boxOne:SetScript("OnCursorChanged", function() end)
    boxOne:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    boxOne:SetScript("OnMouseUp", function(self)
        if not self:IsMouseOver() then
            self:ClearFocus()
        end
    end)

    local boxOneTex = guiCustomCode:CreateTexture(nil, "ARTWORK")
    boxOneTex:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\logos\\patreon.tga")
    boxOneTex:SetSize(58, 58)
    boxOneTex:SetPoint("BOTTOMLEFT", boxOne, "TOPLEFT", 3, -2)

    local patText = guiCustomCode:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    patText:SetPoint("LEFT", boxOneTex, "RIGHT", 14, -1)
    patText:SetText("Patreon")

    local boxTwo = CreateFrame("EditBox", nil, guiCustomCode, "InputBoxTemplate")
    boxTwo:SetPoint("LEFT", boxOne, "RIGHT", 35, 0)
    boxTwo:SetSize(180, 20)
    boxTwo:SetAutoFocus(false)
    boxTwo:SetFontObject("ChatFontSmall")
    boxTwo:SetText("https://paypal.me/bodifydev")
    boxTwo:SetCursorPosition(0)
    boxTwo:ClearFocus()
    boxTwo:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    boxTwo:SetScript("OnTextChanged", function(self)
        self:SetText("https://paypal.me/bodifydev")
    end)
    boxTwo:SetScript("OnCursorChanged", function() end)
    boxTwo:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    boxTwo:SetScript("OnMouseUp", function(self)
        if not self:IsMouseOver() then
            self:ClearFocus()
        end
    end)

    local boxTwoTex = guiCustomCode:CreateTexture(nil, "ARTWORK")
    boxTwoTex:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\logos\\paypal.tga")
    boxTwoTex:SetSize(58, 58)
    boxTwoTex:SetPoint("BOTTOMLEFT", boxTwo, "TOPLEFT", 3, -2)

    local palText = guiCustomCode:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    palText:SetPoint("LEFT", boxTwoTex, "RIGHT", 14, -1)
    palText:SetText("Paypal")

    local FAIAP = BBF.indent

    -- Syntax highlighting
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

    local scrollFrame = CreateFrame("ScrollFrame", nil, guiCustomCode, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOP", guiCustomCode, "TOP", -10, -110)
    scrollFrame:SetSize(620, 440)

    local customCodeText = guiCustomCode:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    customCodeText:SetPoint("BOTTOM", scrollFrame, "TOP", 0, 5)
    customCodeText:SetText(L["Custom_Code_Text"])

    local codeEditBox = CreateFrame("EditBox", nil, scrollFrame)
    codeEditBox:SetMultiLine(true)
    codeEditBox:SetFontObject("ChatFontSmall")
    codeEditBox:SetSize(600, 370)
    codeEditBox:SetAutoFocus(false)
    codeEditBox:SetCursorPosition(0)
    codeEditBox:SetText(BetterBlizzFramesDB.customCode or "")
    codeEditBox:ClearFocus()
    scrollFrame:SetScrollChild(codeEditBox)


    local bg = scrollFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(0, 0, 0, 0.6)
    bg:SetAllPoints(scrollFrame)

    -- Add a static custom border around the scroll frame
    local border = CreateFrame("Frame", nil, scrollFrame, BackdropTemplateMixin and "BackdropTemplate")
    border:SetPoint("TOPLEFT", scrollFrame, -2, 2)
    border:SetPoint("BOTTOMRIGHT", scrollFrame, 2, -2)
    border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
    })
    border:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
    codeEditBox:SetTextInsets(6, 10, 4, 10)

    scrollFrame:EnableMouse(true)
    scrollFrame:SetScript("OnMouseDown", function()
        codeEditBox:SetFocus()
    end)

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
    FAIAP.enable(codeEditBox, colorTable, 4)

    local customCodeSaved = L["Print_Custom_Code_Saved"]

    local saveButton = CreateFrame("Button", nil, guiCustomCode, "UIPanelButtonTemplate")
    saveButton:SetSize(120, 30)
    saveButton:SetPoint("TOP", scrollFrame, "BOTTOM", 0, -10)
    saveButton:SetText(L["Save"])
    saveButton:SetScript("OnClick", function()
        BetterBlizzFramesDB.customCode = codeEditBox:GetText()
        unsavedChanges = false
        BBF.Print(customCodeSaved)
    end)

    -- Flag to prevent double triggering of the prompt
    local promptShown = false

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
        text = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames \n\n"..L["Popup_Unsaved_Changes_Midnight"],
        button1 = L["Yes"],
        button2 = L["No"],
        OnAccept = function()
            BetterBlizzFramesDB.customCode = codeEditBox:GetText()
            unsavedChanges = false
            codeEditBox:ClearFocus()
            BBF.Print(customCodeSaved)
            if BetterBlizzFramesDB.reopenOptions then
                ReloadUI()
            end
        end,
        OnCancel = function()
            unsavedChanges = false
            codeEditBox:ClearFocus()
            if BetterBlizzFramesDB.reopenOptions then
                ReloadUI()
            end
        end,
        timeout = 0,
        whileDead = true,
    }

    local reloadUiButton = CreateFrame("Button", nil, guiCustomCode, "UIPanelButtonTemplate")
    reloadUiButton:SetText(L["Reload_UI"])
    reloadUiButton:SetWidth(85)
    reloadUiButton:SetPoint("TOP", guiCustomCode, "BOTTOMRIGHT", -140, -9)
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

local function guiSupport()
    local guiSupport = CreateFrame("Frame")
    guiSupport.name = "|A:GarrisonTroops-Health:10:10|a Support"
    guiSupport.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(guiSupport)
    local guiSupportCategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, guiSupport, guiSupport.name, guiSupport.name)
    guiSupportCategory.ID = guiSupport.name;
    BBF.guiSupport = guiSupport.name
    BBF.category.guiSupportCategory = guiSupportCategory.ID
    CreateTitle(guiSupport)

    local bgImg = guiSupport:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiSupport, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local discordLinkEditBox = CreateFrame("EditBox", nil, guiSupport, "InputBoxTemplate")
    discordLinkEditBox:SetPoint("TOP", guiSupport, "TOP", 0, -170)
    discordLinkEditBox:SetSize(180, 20)
    discordLinkEditBox:SetAutoFocus(false)
    discordLinkEditBox:SetFontObject("ChatFontNormal")
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
    discordText:SetText(L["Discord_Text"])

    local joinDiscord = guiSupport:CreateTexture(nil, "ARTWORK")
    joinDiscord:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\logos\\discord.tga")
    joinDiscord:SetSize(52, 52)
    joinDiscord:SetPoint("RIGHT", discordText, "LEFT", 0, 1)

    local supportText = guiSupport:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    supportText:SetPoint("TOP", guiSupport, "TOP", 0, -230)
    supportText:SetText("|A:GarrisonTroops-Health:10:10|a " .. L["Support_Text"])

    local boxOne = CreateFrame("EditBox", nil, guiSupport, "InputBoxTemplate")
    boxOne:SetPoint("TOP", guiSupport, "TOP", -110, -360)
    boxOne:SetSize(180, 20)
    boxOne:SetAutoFocus(false)
    boxOne:SetFontObject("ChatFontNormal")
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
    boxOneTex:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\logos\\patreon.tga")
    boxOneTex:SetSize(58, 58)
    boxOneTex:SetPoint("BOTTOM", boxOne, "TOP", 0, 1)

    local boxTwo = CreateFrame("EditBox", nil, guiSupport, "InputBoxTemplate")
    boxTwo:SetPoint("TOP", guiSupport, "TOP", 110, -360)
    boxTwo:SetSize(180, 20)
    boxTwo:SetAutoFocus(false)
    boxTwo:SetFontObject("ChatFontNormal")
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
    boxTwoTex:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\logos\\paypal.tga")
    boxTwoTex:SetSize(58, 58)
    boxTwoTex:SetPoint("BOTTOM", boxTwo, "TOP", 0, 1)
end

------------------------------------------------------------
-- GUI Setup
------------------------------------------------------------
local function CombatOnGUICreation()
    if InCombatLockdown() then
        BBF.Print(L["Print_Waiting_For_Combat"])
        if not BBF.waitingCombat then
            local f = CreateFrame("Frame")
            f:RegisterEvent("PLAYER_REGEN_ENABLED")
            f:SetScript("OnEvent", function(self)
                self:UnregisterEvent("PLAYER_REGEN_ENABLED")
                BBF.LoadGUI()
            end)
            BBF.waitingCombat = true
        end
        return true
    end
end

function BBF.InitializeOptions()
    if not BetterBlizzFrames then
        BetterBlizzFrames = CreateFrame("Frame")
        BetterBlizzFrames.name = "Better|cff00c0ffBlizz|rFrames |A:gmchat-icon-blizz:16:16|a"
        --InterfaceOptions_AddCategory(BetterBlizzFrames)
        BBF.category = Settings.RegisterCanvasLayoutCategory(BetterBlizzFrames, BetterBlizzFrames.name, BetterBlizzFrames.name)
        Settings.RegisterAddOnCategory(BBF.category)

        local titleText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFont_Gigantic")
        titleText:SetPoint("CENTER", BetterBlizzFrames, "CENTER", -15, 33)
        titleText:SetText("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames")
        BetterBlizzFrames.titleText = titleText

        local loadGUI = CreateFrame("Button", nil, BetterBlizzFrames, "UIPanelButtonTemplate")
        loadGUI:SetText(L["Load_Settings"])
        loadGUI:SetWidth(100)
        loadGUI:SetPoint("CENTER", BetterBlizzFrames, "CENTER", -18, 6)
        BetterBlizzFrames.loadGUI = loadGUI
        loadGUI:SetScript("OnClick", function(self)
            if CombatOnGUICreation() then return end
            titleText:Hide()
            self:Hide()
            BBF.LoadGUI()
        end)
    end
end

function BBF.LoadGUI()
    -- First time opening settings
    if BetterBlizzFramesDB.hasNotOpenedSettings then
        BBF.CreateIntroMessageWindow()
        BetterBlizzFramesDB.hasNotOpenedSettings = nil
        return
    end

    if CombatOnGUICreation() then return end

    if BetterBlizzFrames.guiLoaded then
        Settings.OpenToCategory(BBF.category:GetID())
        return
    end

    guiGeneralTab()
    guiPositionAndScale()
    guiFrameAuras()
    guiFrameLook()
    guiCastbars()
    guiImportAndExport()
    guiMisc()
    --guiChatFrame()
    guiCustomCode()
    guiSupport()
    BetterBlizzFrames.guiLoaded = true

    if SettingsPanel:IsShown() then
        HideUIPanel(SettingsPanel)
    end
    Settings.OpenToCategory(BBF.category:GetID())
    Settings.OpenToCategory(BBF.category:GetID(), BBF.guiCustomCode)
    Settings.OpenToCategory(BBF.category:GetID())
end


function BBF.CreateIntroMessageWindow()
    if BBF.IntroMessageWindow then
        BBF.IntroMessageWindow:ClearAllPoints()
        if BBP and BBP.IntroMessageWindow and BBP.IntroMessageWindow:IsShown() then
            BBP.IntroMessageWindow:ClearAllPoints()
            BBP.IntroMessageWindow:SetPoint("CENTER", UIParent, "CENTER", 240, 45)
            BBF.IntroMessageWindow:SetPoint("CENTER", UIParent, "CENTER", -240, 45)
        else
            BBF.IntroMessageWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 45)
        end
        BBF.IntroMessageWindow:Show()
        return
    end

    BBF.IntroMessageWindow = CreateFrame("Frame", "BBFIntro", UIParent, "PortraitFrameTemplate")
    BBF.IntroMessageWindow:SetSize(470, 550)
    BBF.IntroMessageWindow.Bg:SetDesaturated(true)
    BBF.IntroMessageWindow.Bg:SetVertexColor(0.5,0.5,0.5, 0.98)
    if BBP and BBP.IntroMessageWindow and BBP.IntroMessageWindow:IsShown() then
        BBP.IntroMessageWindow:SetPoint("CENTER", UIParent, "CENTER", 240, 45)
        BBF.IntroMessageWindow:SetPoint("CENTER", UIParent, "CENTER", -240, 45)
    else
        BBF.IntroMessageWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 45)
    end
    BBF.IntroMessageWindow:SetMovable(true)
    BBF.IntroMessageWindow:EnableMouse(true)
    BBF.IntroMessageWindow:RegisterForDrag("LeftButton")
    BBF.IntroMessageWindow:SetScript("OnDragStart", BBF.IntroMessageWindow.StartMoving)
    BBF.IntroMessageWindow:SetScript("OnDragStop", BBF.IntroMessageWindow.StopMovingOrSizing)
    BBF.IntroMessageWindow:SetTitle("Better|cff00c0ffBlizz|rFrames "..BBF.VersionNumber)
    BBF.IntroMessageWindow:SetFrameStrata("HIGH")

    -- Add background texture
    BBF.IntroMessageWindow.textureTest = BBF.IntroMessageWindow:CreateTexture(nil, "BACKGROUND")
    BBF.IntroMessageWindow.textureTest:SetAtlas("communities-widebackground")
    BBF.IntroMessageWindow.textureTest:SetSize(465, 150)
    BBF.IntroMessageWindow.textureTest:SetPoint("TOP", BBF.IntroMessageWindow, "TOP", 0, -15)

    -- Create a mask texture
    local maskTexture = BBF.IntroMessageWindow:CreateMaskTexture()
    maskTexture:SetAtlas("Azerite-CenterBG-ChannelGlowBar-FillingMask")
    maskTexture:SetSize(665, 300)
    maskTexture:SetPoint("CENTER", BBF.IntroMessageWindow.textureTest, "CENTER", 0, 50)
    BBF.IntroMessageWindow.textureTest:AddMaskTexture(maskTexture)

    BBF.IntroMessageWindow:SetPortraitToAsset(135724)

    local welcomeText = BBF.IntroMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge2")
    welcomeText:SetPoint("TOP", BBF.IntroMessageWindow, "TOP", 0, -45)
    welcomeText:SetText(L["Welcome_Text"])
    welcomeText:SetJustifyH("CENTER")

    local description1 = BBF.IntroMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    description1:SetPoint("TOP", welcomeText, "BOTTOM", 0, -10)
    local starterProfileText = "|A:newplayerchat-chaticon-newcomer:16:16|a |cff32cd32" .. L["Label_Starter_Profile"] .. "|r"
    description1:SetText(string.format(L["Welcome_Description"], starterProfileText))
    description1:SetJustifyH("CENTER")
    description1:SetWidth(410)

    local btnWidth, btnHeight, btnGap = 150, 30, -3

    local function ShowProfileConfirmation(profileName, class, profileFunction, additionalNote)
        local noteText = additionalNote or ""
        local color = CLASS_COLORS[class] or "|cffffffff"
        local icon = CLASS_ICONS[class] or "groupfinder-icon-role-leader"
        local profileText = string.format("|A:%s:16:16|a %s%s|r", icon, color, profileName..L["Profile_Label"])
        local confirmationText = titleText .. string.format(L["Profile_Confirmation_Text_Intro"], profileText, noteText)
        StaticPopupDialogs["BBF_CONFIRM_PROFILE"].text = confirmationText
        StaticPopup_Show("BBF_CONFIRM_PROFILE", nil, nil, { func = profileFunction })
    end

    local starterButton = CreateClassButton(BBF.IntroMessageWindow, "STARTER", "Starter", nil, function()
        ShowProfileConfirmation("Starter", "STARTER", function() BBF.ApplyProfile("Starter") end)
    end)
    starterButton:SetPoint("TOP", description1, "BOTTOM", -75, -20)

    local bodifyButton = CreateClassButton(BBF.IntroMessageWindow, "MAGE", "Bodify", "bodify", function()
        ShowProfileConfirmation("Bodify", "MAGE", function() BBF.ApplyProfile("Bodify") end)
    end)
    bodifyButton:SetPoint("TOP", description1, "BOTTOM", 75, -20)

    local orText = BBF.IntroMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    orText:SetPoint("CENTER", bodifyButton, "BOTTOM", -75, -20)
    orText:SetText(L["OR"])
    orText:SetJustifyH("CENTER")

    local columnOffsets = { -114, 0, 114 }
    local columnAnchors = { orText, orText, orText }
    local columnFirstRow = { true, true, true }
    local colIndex = 1
    local lastCol1Button

    for _, profile in ipairs(BBF.ProfileData) do
        if not profile.core then
            local button = CreateClassButton(BBF.IntroMessageWindow, profile.class, profile.name, profile.twitchName, function()
                ShowProfileConfirmation(profile.name, profile.class, function() BBF.ApplyProfile(profile.name) end)
            end)

            if columnFirstRow[colIndex] then
                button:SetPoint("TOP", columnAnchors[colIndex], "BOTTOM", columnOffsets[colIndex], -10)
                columnFirstRow[colIndex] = false
            else
                button:SetPoint("TOP", columnAnchors[colIndex], "BOTTOM", 0, btnGap)
            end

            columnAnchors[colIndex] = button
            if colIndex == 1 then
                lastCol1Button = button
            end
            colIndex = colIndex + 1
            if colIndex > 3 then colIndex = 1 end
        end
    end

    local orText2 = BBF.IntroMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    orText2:SetPoint("CENTER", lastCol1Button, "BOTTOM", 114, -20)
    orText2:SetText(L["OR"])
    orText2:SetJustifyH("CENTER")

    local buttonLast = CreateFrame("Button", nil, BBF.IntroMessageWindow, "GameMenuButtonTemplate")
    buttonLast:SetSize(btnWidth, btnHeight)
    buttonLast:SetText(L["Exit_No_Profile"])
    buttonLast:SetPoint("TOP", lastCol1Button, "BOTTOM", 114, -40)
    buttonLast:SetNormalFontObject("GameFontNormal")
    buttonLast:SetHighlightFontObject("GameFontHighlight")
    buttonLast:SetScript("OnClick", function()
        BBF.IntroMessageWindow:Hide()
        if not BetterBlizzFrames.guiLoaded then
            BBF.LoadGUI()
        else
            Settings.OpenToCategory(BBF.category:GetID())
        end
    end)
    CreateTooltipTwo(buttonLast, L["Exit_No_Profile"], L["Tooltip_Exit_No_Profile"], nil, "ANCHOR_TOP")
    local f,s,o = buttonLast.Text:GetFont()
    buttonLast.Text:SetFont(f,s,"OUTLINE")

    BBF.IntroMessageWindow.CloseButton:HookScript("OnClick", function()
        if not BetterBlizzFrames.guiLoaded then
            BBF.LoadGUI()
        else
            Settings.OpenToCategory(BBF.category:GetID())
        end
    end)

    local function AdjustWindowHeight()
        local baseHeight = 334
        local perRowHeight = 29
        local buttonCount = 0
        for _, child in ipairs({BBF.IntroMessageWindow:GetChildren()}) do
            if child and child:IsObjectType("Button") then
                buttonCount = buttonCount + 1
            end
        end

        local rowCount = math.ceil(buttonCount / 3)
        local newHeight = baseHeight + (rowCount * perRowHeight)

        BBF.IntroMessageWindow:SetSize(470, newHeight)
    end
    AdjustWindowHeight()
end