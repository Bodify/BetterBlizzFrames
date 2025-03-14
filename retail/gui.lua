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
local titleText = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: \n\n"
local playerClass = select(2, UnitClass("player"))
local playerClassResourceScale = "classResource" .. playerClass .. "Scale"

local LibDeflate = LibStub("LibDeflate")
local LibSerialize = LibStub("LibSerialize")

BBF.squareGreenGlow = "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\newplayertutorial-drag-slotgreen.tga"

local checkBoxList = {}
local sliderList = {}

local function ConvertOldWhitelist(oldWhitelist)
    local optimizedWhitelist = {}
    for _, aura in ipairs(oldWhitelist) do
        local key = aura["id"] or string.lower(aura["name"])
        local flags = aura["flags"] or {}
        local entryColors = aura["entryColors"] or {}
        local textColors = entryColors["text"] or {}

        optimizedWhitelist[key] = {
            name = aura["name"] or nil,
            id = aura["id"] or nil,
            important = flags["important"] or nil,
            pandemic = flags["pandemic"] or nil,
            enlarged = flags["enlarged"] or nil,
            compacted = flags["compacted"] or nil,
            color = {textColors["r"] or 0, textColors["g"] or 1, textColors["b"] or 0, textColors["a"] or 1}
        }
    end
    return optimizedWhitelist
end

local function ConvertOldBlacklist(oldBlacklist)
    local optimizedBlacklist = {}
    for _, aura in ipairs(oldBlacklist) do
        local key = aura["id"] or string.lower(aura["name"])

        optimizedBlacklist[key] = {
            name = aura["name"] or nil,
            id = aura["id"] or nil,
            showMine = aura["showMine"] or nil,
        }
    end
    return optimizedBlacklist
end

local function ExportProfile(profileTable, dataType)
    -- Include a dataType in the table being serialized
    local wowVersion = GetBuildInfo()
    BetterBlizzFramesDB.exportVersion = "BBF: "..BBF.VersionNumber.." WoW: "..wowVersion
    local exportTable = {
        dataType = dataType,
        data = profileTable
    }
    local serialized = LibSerialize:Serialize(exportTable)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForPrint(compressed)
    return "!BBF" .. encoded .. "!BBF"
end

function BBF.ImportProfile(encodedString, expectedDataType)
    -- Check if the string starts and ends with !BBF
    if encodedString:sub(1, 4) == "!BBF" and encodedString:sub(-4) == "!BBF" then
        encodedString = encodedString:sub(5, -5) -- Remove both prefix and suffix
    elseif encodedString:sub(1, 4) == "!BBP" and encodedString:sub(-4) == "!BBP" then
        return nil, "This is a BetterBlizz|cffff4040Plates|r profile string, not a BetterBlizz|cff40ff40Frames|r one. Two different addons."
    else
        return nil, "Invalid format: Prefix or suffix not found."
    end

    -- Decode and decompress the data
    local compressed = LibDeflate:DecodeForPrint(encodedString)
    local serialized, decompressMsg = LibDeflate:DecompressDeflate(compressed)
    if not serialized then
        return nil, "Error decompressing: " .. tostring(decompressMsg)
    end

    -- Deserialize the data
    local success, importTable = LibSerialize:Deserialize(serialized)
    if not success then
        return nil, "Error deserializing the data."
    end

    -- Function to check if the data is in the new format
    local function IsNewFormat(auraList)
        local consecutiveIndex = 1  -- Start with the first numeric index
        -- Loop through the table to inspect its structure
        for key, _ in pairs(auraList) do
            if type(key) == "number" then
                if key ~= consecutiveIndex then
                    return true
                end
                consecutiveIndex = consecutiveIndex + 1
            elseif type(key) == "string" then
                return true
            end
        end
        return false
    end

    -- Convert old format to the new format if necessary
    local function ConvertIfNeeded(subTable, expectedType)
        if expectedType == "auraBlacklist" and not IsNewFormat(subTable) then
            return ConvertOldBlacklist(subTable)
        elseif expectedType == "auraWhitelist" and not IsNewFormat(subTable) then
            return ConvertOldWhitelist(subTable)
        end
        return subTable -- Return as-is if no conversion is needed
    end

    -- Handling full profile import by checking and converting the relevant portion if needed
    if importTable.dataType == "fullProfile" then
        if importTable.data[expectedDataType] then
            -- Check the subtable and convert if necessary
            importTable.data[expectedDataType] = ConvertIfNeeded(importTable.data[expectedDataType], expectedDataType)
            return importTable.data[expectedDataType], nil
        else
            return importTable.data, nil
        end
    elseif importTable.dataType ~= expectedDataType then
        return nil, "Data type mismatch"
    end

    -- For normal imports, check if conversion is needed for auraWhitelist and auraBlacklist
    importTable.data = ConvertIfNeeded(importTable.data, expectedDataType)

    return importTable.data, nil
end


local function deepMergeTables(destination, source)
    for k, v in pairs(source) do
        if destination[k] == nil then
            if type(v) == "table" then
                destination[k] = {}
                deepMergeTables(destination[k], v)
            else
                destination[k] = v
            end
        end
    end
end












local LSM = LibStub("LibSharedMedia-3.0")


local function CreateFontDropdown(name, parentFrame, defaultText, settingKey, toggleFunc, point, dropdownWidth, maxVisibleItems)
    maxVisibleItems = maxVisibleItems or 25  -- Default to 25 visible items if not provided

    -- Create container for label and dropdown
    local container = CreateFrame("Frame", nil, parentFrame)
    container:SetSize(dropdownWidth or 155, 50)

    -- Create and position label
    local label = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall2")
    label:SetPoint("LEFT", container, "LEFT", -50, -12)
    label:SetText("Font")

    -- Create the dropdown button with the new dropdown template
    local dropdown = CreateFrame("DropdownButton", nil, parentFrame, "WowStyle1DropdownTemplate")
    dropdown:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 0, 0)
    dropdown:SetWidth(dropdownWidth or 155)
    dropdown:SetDefaultText(BetterBlizzFramesDB[settingKey] or defaultText)
    dropdown.Background:SetVertexColor(0.9,0.9,0.9)
    dropdown.Arrow:SetVertexColor(0.9,0.9,0.9)

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
    dropdown:SetDefaultText(BetterBlizzFramesDB[settingKey] or "Select texture")
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

    -- Create the dropdown button with the new dropdown template
    local dropdown = CreateFrame("DropdownButton", nil, parentFrame, "WowStyle1DropdownTemplate")
    dropdown:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 0, 0)
    dropdown:SetWidth(dropdownWidth)
    dropdown:SetDefaultText(BetterBlizzFramesDB[settingKey] or ("Select "..labelText))
    dropdown.Background:SetVertexColor(0.9, 0.9, 0.9)
    dropdown.Arrow:SetVertexColor(0.9, 0.9, 0.9)

    -- Create and position label
    local label = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall2")
    label:SetPoint("LEFT", container, "LEFT", -50, -12)
    label:SetText(labelText)
    dropdown.LabelText = label

    -- Define the generator function for the dropdown menu
    local function GeneratorFunction(owner, rootDescription)
        local itemHeight = 20  -- Each item's height
        local maxScrollExtent = math.min(#optionsTable, 25) * itemHeight
        rootDescription:SetScrollMode(maxScrollExtent)

        for _, option in ipairs(optionsTable) do
            -- Create each item as a button
            local button = rootDescription:CreateButton(option, function()
                BetterBlizzFramesDB[settingKey] = option
                dropdown:SetDefaultText(option)
                if toggleFunc then
                    toggleFunc(option)
                end
            end)

            -- Add the text initializer for the button
            button:AddInitializer(function(button)
                --button.Text:SetText(option) -- 11.1 error
            end)
        end
    end

    -- Reset dropdown contents when closed
    hooksecurefunc(dropdown, "OnMenuClosed", function()
        dropdown:SetDefaultText(BetterBlizzFramesDB[settingKey] or ("Select "..labelText))
    end)

    dropdown:SetupMenu(GeneratorFunction)
    container:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    return dropdown, container
end



















StaticPopupDialogs["BBF_CONFIRM_RELOAD"] = {
    text = titleText.."This requires a reload. Reload now?",
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
    text = titleText.."The default Blizzard code to \"wrap auras\" around the target of target frame is stupid.\n\nThe \"Target of Target\" frames have been moved 31 pixels to the right to make more space for auras.\nYou can change this at any time.\n\nDo you want to keep this? (pick yes)",
    button1 = "Yes",
    button2 = "No",
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
    hideOnEscape = true,
}

StaticPopupDialogs["BBF_CONFIRM_PROFILE"] = {
    text = "",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self)
        if self.data and self.data.func then
            self.data.func()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["BBF_CONFIRM_PVP_WHITELIST"] = {
    text = titleText.."This will import a color coded PvP whitelist tailored by me.\nIt will only add auras you don't already have in your whitelist.\n\nAre you sure you want to continue?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        local importString = "!BBFnQvFWrrzAEMzYmmRuRlecq7zW01wClWvSL7XzOSqnHzYNObivMWeHTUsENzENm9LE6ES)yYnrWfz3)qQckOyTUsS2vICuYAvAjIxHB2vGBtXHIwOZM7diwlFLY7oVtpyR4PR)HRzFEE7(TNEs6PZ(pIP7NN333NN3Fp)E(ONaFV4zigKN9FxiYdD7KXvi5PNU3CeDQyICszn2hvrMOninZU(UszqroIu(cQAgefJD1xAvzvThnqOaHm2qYYbpnObvoJ4aez5Y1HkySHYH3v5ipAOUB9)S5M30cwWc6U1B3sl7c(Fcje5p83akvyjXsPRkBAaBivJQizuYsx89wAJBGq9V0NJsV0TvKQvqDyq0mIXjAAsunqEBPa5rnbzfcTLfzT6fPkdkPmOyBAM6KmCP96ezRnOPq43(0G2t3RMuEvTmsezWOksTpyWlDmRBU4flc6chWGXkbQCKnRyq1G9Klm84kwr07Tr8qTS4YuDD8qPMvmbjTMuwP0057Gbkh9jVDN2lf(GN82Snub2qIbQVqD7(lGny82LkkPaoudknJ95aEd)CekKWcFOMr7lMsAjQIbEm6rvJohhjiw7XyUD3N4o1GLvnpx6q2s3ESO355rHRpHPwrPIGtBZk6gskPn0NxB7opVqGd)IO233Mvst0uigsQkBuSltc6)vW9D7A6QPDwjhpV9zfuxi0buHLiv)5u1u0TnC4z(acdF1vIi32YPPQOcob1c8l5RUsxOVaFYxcInv)QMPZHhLhJOLNylj8oF2Gah(qOv1uvwvm4(IOHlum9CK8eh0ciThqRaNDFWAC8y6PPkzikPDK(S7BUsh9zhf3WfVvQroQMUHQwEXoLjdo7lxqoHqP(1GSL)oCxvQFTlmsOfLGDFKOGgLKbV77phvCaiEyJI9QPAqtJgdx1fLWhNqWp7im(b8WmeLwGffYIo(SJ4H9gj(xYmHykgsF)Tqguknqgr5Kk4RDD1e(z(kgcTnvmsf8WaXqmDDIPSb)Q8z(kp2KqTCt2MGgvCkr3qCajJCsogul30sPUB9)7p(nOoG2x6Oh98ZmZmHIU7dGWbhULb0ig5QfYeewiWKdGXLBtlfEP3lYFXVdNCa((8zF9FuK53oFtn16mZ8nHWB(FmEbjuBu)z)XcbVNtIwYYzU31j2brZi36ejkze7usZHh6EoPhyLYFcJKSpvl0OBUi8Kx(t85snuQZwn45SUapbE)xhVXDH65277)6(SM1DJR3jJT6gxNdwHJx3uWKWZNbcaLKronHWVwVif22kaWtlQj0k4x5VwVUHixBxy8t7QQ5b1vYWPgGN7v02r7Gbm2UceTXwxkKGQ48YpJkke4ghduEI2LYM1eYHYaVCl)ghZpIOj)lTW8PuZlz5Xe7rkFQAEZdka(8Zv9vW5CDfeSUwySXBLyyQrxTUyIHHe6kGZIdjQRfxoPi3(dX1QjEq2T)qpzI(jC8Of67N4vK16pf6d2jvrSt10M6I9t5CLWRCTLHAgVcND6qiFbq6ZRcaKP2ETONZkHZMtttPAIaEO0ejdZmCa85EE)aWI3I5Y7faquGvf3(TaWJA6YbfeQ)FapZhpUSQAgGC1H5gEUxUIuNNFbv2DUs8fcr(9OhVWk6bSEQMyTy7(9FOlxwDVYoWfSb7xc)PpENDGvBSpOkPH0hItSbp0hxsKOIO11rka9TfPbZXPqHN7H1v3K)piRwmtncG01HcFkvE2LqaYie(m9G0L9bvfnmEnhxMmItXuNPh)UIwKaAUFBoyyrc2chO7w)LccBYk0zS7NfERrguvb(pol9y3Vxq4jzEqrNB5RSIvyr7oQLmoHZtUJO)GFzsSeR0LetsL4Luap1RR6f)tXBZL2hCa4CvjKDNSdKWd9I8oyo4XBNcPqeBlhwSn3P)oUthx3goK7yD4pDt3(2xe38g6csvdxdqHxfL0LsjjxPCAqe)U4h9FKfl0oCGZb5oHYLlPBqKD8sJxF9wEPP002RlVeOievxpc0AhaAUOxGN6hF3pD9mSJwAcwPQzfZgEJhUPW75zzUjWaX6zSXMvJ1azec(VTvuUe5izuhwSD7QL8oEgKviWLxULHlrftvY6wByOscUx7YlV2gXh)WyYQp(HrjcoolVROvpq10nptKnW8AZeHr2Jv0PJu9RPnnjJ1AJS)NAObrB4)FbJFB7Ygs5jylsvNGgfWn5WgoC1qKdxbIe9VTaZotuaOwGuAzLDx)g8wxRt4roigqLiV6qqTrQojHQqFbsie6(2mgCWycLn1nQnT59T5OVXtBfibRNSA6HS3134PRSRrBAAqKP7sdjYzvBcLyM3wWMM2psIilaHF4Id8)5R95iYcec(GxljRXhhU2DwHdhEPFi2FXLavNOFGcZPTeoK9xCjFjXWodNI1ngYm0f01CP5MryrLGIo7gK80q5KqPOyF0dXVNBPB3r7xDe0iyj7YwIXOQrhMJyV6i(DwADtGQXJlB6Wk16M8r(GHNcHn3lqOGGHTkzocrDDSWeGfp9qIB7VV88vxeSgr)xFx03zLKakfPnNreaVXLLf83MKrIApjbWzLekXMwvuCn3MFBsHWzwn6a7LssthMcTS7uqyMv7cQn2TyjmK0bYz9kbbJDl)yiv2s1XI9IdRGwPBmqa)qp)Um4DwCydPAdbu0jYPAAhZ4vlg8aTFhCdTmCyehh62aQcUBIwE(n3YoDT3WOp0zyX7jj5liPb48oYNsJm)UrqpHiTCzq3uXn10u5Wk4z(zD)H)feIJzaeDi1QzGiiTqO1ogQX2vYPkxYvdB1i0DTJjewFN4DlMHcX7wDCXwo9D6rcJGx5nyqPyWLCANUh6GmOSt4(vEdp0lqFylxfUh3tEGpNKhdI14P3a58loB)xbwfn7HovB7A)xriYApbUHlXEOnZP1A49(blJeb0ECSdFGy3DNwWBMR5fTHFoEU6OiPQBOAbgA4NdLbHfVXQxIz2t2dpqQQ8Al0oV2cXyKktQqCnDJX8RLNAjYLWMRk3i)mEPoCL3jWHUiJixtvjfGK474H8RWL6FH9J4OkXv2Db6FyfOLqOPwys3npn1cDref(cxhVuAibg8ymmWeZ4TIrhuYP7XlCDxN9W3sL15k8V4tdwUTADIdm5JxTd9XTwMUB9wlzj2h3l8Cp3Owvh(b4qyG2naueBwoCh3hKWJl3sSrHS42KvjdXAMIvf08p9TsFLq4))NaJUIdzFXK0eEoA8f(LFyM3hpFwdBA4kjSGN7Y5eAQOv7QJ6YvhzeSnOJKGKLoigZXTWr(q)IVAdN03rIRMPexj)Zoakie69ENK8r0kRwyUZ7eeqiC7Sb2vFxGlxIaUC4Ah4oL51IGc4ZbRUHgMfnZ6Jfkvds5BvsJT2W7D7yAUyYkZRTtsrvN0YnxSICrF3UWKh9kbr4AwJGvT2fCbsleECSK8XHwBtRoiKNQcTa8g3HCV8Dq5IPBOrKTg5phx(Y3P2Mz0vZ6OJnilOzJSMUYIU6E8Gvn80hNDjROoCgnRnXBgrqqHWVYIz(WoYtHtvgX2uZN3uXLj8kl2pOXvXXHvEfCh5v9yWxcHI)3HNNUXKpdub0bp2Dm91X7YY7IVTxFyVwPPURQX23LBSDIXtAxAABQYoq7eJ7xiv63ddP6gAcH6AYTyJb)SgBCtU7Fj97je4K7fnewM3EjPDU9o5E9ZfnYejztPY6Zey1YI95FKj8tXdwhYs0hPeIc72kgIP2bRR2QTQ1GEOrMVy0vTgJHqWyF00dHteQsVKgd5HJpyPRIgXwOgK8QAfYPQ7qndVYl2XVjjBu)qPdITxP(b45(a03nItMogCxOGALfYRn)FdjqROFobn6ET3JpN4cve4WSr03yvFtG2adGYQ2OdztxFqGr9kA6G48NNEBP0LyLOKinbCyCy6bpGp3GbAfzCkSuRqxRP5x57OX2Ywl6J(r(Sx1nCh(Zkg2h3kU0l3948MD1mFCR(HUAeBbSGqvZde7xDySumLb5yTg9RBWWh4UHfjvF4OM4GA4z(PHeokcTUKLYxq3zkesR3ntWxGlA59wBARV4Ufc))(xZo(junLtzQb3PTtZRQa1E3MKwANYobXCZqmZk3G1sENJDS)zRLKv1QZKbSNS2AzU7zwPqGxcZIPzxXd)s7LEhpq8pJvpa9sGwwtyApPChI6N5m(DpptJ2v01isf7UIUKWo7uqxW0yVctetwwI92kewD3679cVayraV1N(up1O4QwH46YaJri0L(uoeiH8Jt8khfTKgQUy((n1mCvn)r9BbU2BI72E4cFT30d31fWpaz59B7EUWl6fB)iSIgZ6WwUqptj8TQoLW3Y1fE4h8)cP3JjJZPRFP8ZBhzOgcrwiB0oRNh2TWd7X(g5ctIlT1OeDLmaEUFmcV7tI8I9iLftsLwTYNQ5DFsFigp3G4b6q2oRZnOF7Wh9JqmI9m5SQLTMrsGWr7b5OMiouXl7tVRvHRUNIECVDU2sA3trz3LZbpp6BJDhmnZJGLVNPyLpFk8o3CY7(TsI5EiYYLS(5c4m40D)w(rEmDFS4e4FX4wCMcYqB25X0fXPK0G3KxQ1V5RyDia)7ST8GhpHzkapK1KnfuHW7H1s4IXXKmRV7vnOF2ZjecCc8hHrkRVTm)SFInmx)1QAcDxpHLiRQj)IAkVowyxhSXQNrSp6GufOMmJ)m6Devwi0d)FG7v7LN9aeHxie55Fax)AgW)K1gmX(tXyz0mo8OD3g66G)bpSv1ThoUFVB1tiW1Ezey3ojFbiXQRbNaVWhG9o2iAZlRtnQYisZ1OXZXo2Op638zyN1MzSRqPdzGfIiJfA1NPEUzJDhd)wzA9rkGFKo7LFSt5hG7apUBYf4pDHIdTIVMbCC(fy0pWciL2zK8R4R9lmT5Sj9ON3UShBeZZ1Cw)oA6yI0jqsnX2LQAyeWR8XLnwzCJxAh5z)YEa)e4SgGsku7zibQiu3GuqT91VMjvpNATBPaKti0sFPK8z0dGHk)eLW34NjDbCuHL)R4MXfUvzxvfCr2eWz2BcJk)0rU4MRsi8JpxyjB1esrAnT2e5GocDQn5I7YL0bV52Dhta)jo5ymPhR)m7p7HqKxelGV8pKtW)It4r6GWF0ODw7quq9nX2)pAuH6UlKsOWkCGn2HFDkzyqD1OzTc1b9JEkCc)tXQUgTr3fyFQN2pp8zW5Qw(b4UJZ4ZuuFomyPChwI(CNYdBoYVbXWNElq9WfvLP(91FarJE(dXIvppRJ(GhPhP05sPQPutkLG)34yhoo0qAktDd)MXjiPqWVe)Ib7lPQuMS(9Hja5I(RWYQN2zOJwXG2(VF1R6J)RUp9hXsab)laW7pNQjGrGkgjYCmvOhbNEWPTMrtvD7(iDvb6Tp8Nby)LkqNGyQrgiNKbvws34p9d!BBF"
        local profileData, errorMessage = BBF.ImportProfile(importString, "auraWhitelist")
        if errorMessage then
            print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rFrames: Error importing whitelist:", errorMessage)
            return
        end
        deepMergeTables(BetterBlizzFramesDB.auraWhitelist, profileData)
        BBF.auraWhitelistRefresh()
        Settings.OpenToCategory(BBF.aurasSubCategory)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["BBF_CONFIRM_PVP_BLACKLIST"] = {
    text = titleText.."This will import a large PvP blacklist focused on removing trash buffs, created by me.\nIt will only add auras you don't already have in your blacklist.\n\nAre you sure you want to continue?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        local importString = "!BBF113cCwzzD(7CU8oJkOGYLd3Kx1cARqxR11sZ05odWaJZmazT667CoVZzEDEpVVhFpN3zyyXmOvR0QTu7IUzURTzLTyPrW6LkaXYA7YzbSWlOciciI4aiGOc))(7Y75Cg0)vF(8tpZZ7ZLF3V98unZOHmwfT(gXNyQK33D8pEEoziydEw5S3yZfky7L22SHWGcfxrH(8hSDhp7RRUvF7ZaJdGsXYpUoSdk47z56Su7mMl22QyF2bPmw9c4PcWsXwFN((fnNVDXb9d6VuIRlLXW1l)1HRhZWyxKZawPDkoKPFVMTe4xOOmMg0X0WjpM55KTpEmjw1g5XayPyRyX2UUMTyNH)6hQl5RFOUW638ssBxOq1ZDt6C307z99dsBZJz16mSAmd5pRUkgyv0oRtAZ286nSGJVhVb(l)jzd8x(tyqJPbCeTT9mbkWS5HSlqdj5d8DeK6d8DWqMqZU25S9kA5A2yFw(fUuZMTck2hpW9FlYa3)Tuk2b60AP(byhBLLgopt1MqWAas76MWh64L1C2HbboPT84DD8PDP8yaeyKgcDDlypKEEwOEEwyPyLgf(P6wXPq)cayOn6hK3pWYLh6YtldD5PXcnX2Y6eynZcMngeA7AoFc5NZkWwoC3LE4UR33dxfm(lopzkFX5rlwFoMl2AazF9onpd(V8onxk291PDHW85DDSb31Dimz3b2UjtzStDc2jMGsNk)L7w)PDppIcTyNcz8Zr0qc9Vylx5SSZ21VR9YF3oNV(tZp6NsmJJl0XzCCmvtUDlqOXPOnVIbmT2SjRC5T9Sd4VFXfKD8Ilq8)n7L2kFHqxWEKXSj7cGOmeM7o01OJYl7P)LKF60)sGLSLWaMF7ZeAtCs1n1hHPft9rkf72B0FPdz2IJGIn25vPZ0vvzM(Y6m9LXpnz(NEQRw(PN6QjgX29Zgybrvq1ApsyX4B1RmKVvV0qwSdKwuKvtwdYSZg)1fjd5VUiSfBaNf)bllTv3QVtHGCNmbj2H)98ybeu0f57KPx)GC8S87)CYS87)Ce(P(8(axou(Iq2PrFVBi0wyjsE0VHW7C0Vbg24xCGv(8adUW8aTt6rgam38428DlJBZ3DPyBVLaB7LsS9l2Xldlwy8Q6M(vXME7D1NvgSPBoxpbwQG8P)1vS1xhRZ5vVlXDzU4aNcfZgAfKHqcn6NlVLhi0f6Zjp)rpREgEwCgoaukKfFt32ESEcEaB5FsgWw(NiSzx5HYNEbjZSR8q)hVW1oArhiGyo62gIP94ABUiNcwzfH12wJiS22AkflOR(c7Txxzl)n8foSVHpM8jTyRGES8Yy2oKT8dWgzE2dy7cKqQKpZ9i4MN5EiCyN2UyiUKUU2aI2PGdgpnHXErrrjGGWcQqb70qFMQfR2eDPkwGQU7Rb)C9a0IJWSN8j)bYk8K)aAfQiH3mMFxNEcCcfIUHy7aqs5uR95h66uOVrOTm5o(EYCTJVhPTOfhYQrXHUuZgCTs3Vzh(dMrw0yhuKqbSuShU1a5W7AliN1BlR06TPvI4uSdaJE3HfTDvmBYDO4LDq4LXvzLAEaNcPTjv5cR1)PYA9FIdEJ(UzinwEI4Yw)NLLzR)ZqKK4V7ZgACLDqVc5z99YNvsXGLl2cD0NLRL3ssz8eQO2tqdyInxOOnqBzeD9W(a4obEuoPlqpPKDYUHgwZgWYOS(Xp7FNWGC2)oiJ1Qpuza9g8oF)kQC)av(WKEE7IqAveaRnXNzgc98Zuk2gBEj59lGfVfS16pLXFs3A)jEVdXLIfTjEk1wpjO)mSktaioBOhQqrOeWgOxplf38JZltYpopnjTBbgUMa3MhSqgHBnULHKXCldbM72akQOJfFKVKtroYxYPqBDxF)mGFcSK8w)uf9yasl(8aIWMWgekd(zWiLP2QGuMAR0Pd0vBZoS9I2BXNQIZMkWzpmJXheSZ2IcUl(Ft2ux8)gRAkJfulnaeAl67zxaQPeB2j(zdZddqI(bH70W8VlHcl0pPVaSQcNA8Z)3kR25)BXMPbmlW0h0Sgra)7Bu(Z)9ncDtD7x0MnqbDDIn)yB(zfCXMFwYegmP3FoFyUHu(piqKI9MVLIj)watUXwDTTYryKoTgs0)L(weUX03cphb4VxiekSmNTTBEG0aFW1QY3xlue1UDqAhwhbW9dQO02uCwByko7ociRyzD8dlmcm7rVDzuhf(9TrmO0ofaQRpFX9eJxt5SETEzZIqQSNWapAR2wwpNiLnjMYu4TlGGNUzpOLagotzSdh5R3HdiB1NoTRvUYkOIF07qxzOCPNf5dUDwjCYNzLIuWZSsGEBY2ghxymlBwLvP2tZso4NMfPG1j9mbFeVxFHCYQ9c5iTADpOdW5w0o1Ram5x2LlJ1mOmU1miXi0yWqfaVkOUW)UC5jMaAO8w8f(3LT4l8VtubWVVe4ofPVV(cfScDf)vhOoHVAG6yuKyKI4iAyqiayLlJdVQBx3DBN2DNvJUqHG4DAhHbKWmF237pvo779NsdQbIIs4AI9IeedKf8u1f8ujXPQwWoSMz)H8qw1XKHSQJf5FrTJoJG2gDgWVmBsT3qMJW76B7MLn4TDZKICWkKZxOW0udCyKph1oABDMGU6sFw5BVf9Bj21XFsFBx(UQz7AhDV6N2B0Nw7OZQ)uw9NQBRVo9laaD0nzxeYPr2AEOFJGEEOFdDYNTvamgbDuPDYtKp6BxWfYF7cUqWhoNWmzJiLg)0Ll7WF6Ybxfh7ZiK5RD0o62WP8H6GQcXdcfI3ExdLRhh)comlunx(JZ)jabJDxHzGQiZM89f(W9fiF3(cyTXHG9c7UmyXG220INgxX3xgZv89PtcPJOxiCyxTkXJExQ8XDfPsTGTD)kpGXSecSXSiB)q9rqAlYlvsdvD)UvXiHF3QaLEUIIlZ2Ts3NGJsz8Clrw8NBj8g8KCZres(UFfzmF3VcXj2rFowSNLK1SYCcj35Qf6Xoxnm12LTnRctyNQzdISdGGu0ULNfC1ITvKCQVQ8vt9vHGp89ZBPco5vhu059QKC546QyiWQmvQl4efBXiLXF5ZlBR)YNh0KplW6De6kYoghTO85hTifZHtgiLclq4BQ)(KVP(7d4JocCYrA9HmtXqnGNJ)lKn0X)feNVe5iPNe)to9IGgkZ)TDHSdilEAXbPLHL9AXYru)BCpQRP3d5A6e6KmLrNblpWhx9SL4kMHqdVIzawseCf0x1PTvzU94)d)zHb4F4pJ9D9bu4GyzYbp0SeBi3PO7gqsd)8c9ScmRphKfQEzmwHeRkGKSjfaao9o2WtBZbXE2SdX744JwSsdyjoSxR0I47ICckgkiQJ8yY5)ipg2retl89cAyHFRfyw)K7wfq3neqVpYYAF59DejWKB8jL)2gFs64umWpFFi6Ho8DkOB0l5)w2OxY)nr)BhXcaosN(TVus7d8KxCsV2rjQVbms3wYT(eYuV1NaF5KMNDwR0dffhehUkuFwmTyDERVcpwaX2OXaSfLOH8uZ7gVYkKTXRScIPopyKcIm9xZ0QJ5XaKKCyZLGrbEj2Ptp947LY4nu1mVbuZSIoTY4yP(FDhSl3aaJwDch1dDe9s7q1CUdsZ5ywaCQHDCtCjxs2Wp(PLt3p(PbFY8STYtIzTqQler1ycshqInOR0SZcrhFYjxbTDJkA7glhYP9psKyS)rKL2a1heoiSug3TeHgGywNAtSg90M1hu8snB3NYhehJfLsaEtU5)OSj38FSIfhrwfWYQunwRmPgRLiuZ1jD)8gTf40cRKYNo1sWhjp2gKz8yBGWmqG1JI2S6HyK5bKdqMhaoV01Go9wKSMwa4wSQlxx9LxE1x)DkR(6VtI61ic(aQmPeB47LrPhj3XFKNsazPxeuMfR)SPaRS(EGs38q2PmAEvYc38QiKZ8Th0C(oqhLN589NvxE4F0XBMMDtySugdFRYyh(wXy)ar20ltGAabNSuBD(71Lyfb(5jv80ts4PwG7u))fpz8Tu1BFR7JSxIO(DlNDGR9Nl)PR9Nthg4agoYuiIykG(OmzHaQ4t1OUzL54MlZCSVVM8T77RrCvZ3I0wsHdf4xLf5eTEjIoSwVeMVoJFypItcNPoJNjMX13fffJzvQ6p0xvM8d9vjkXc9s7Nd8xW6ITvHiTYp0wf6)dTvqCj)pYWkLBt(ZX3T4QeGW8488HA4mWxaXpJeT8jLTvlFsWzpx)b8HQQ5c9aWlqwo(2(75)oGyBpBRq4BLkL8LveXxUmIi2)RkE9)YMLCTcb6vcGPRIbq)KifEA)bzyN2FadBAlwc4ZSlp)bnBfo7bRRHEmcxtH4U3KC829MydSKJiMla(xpyF2U5I034TerFJhzPEmT646beej1LlpOaPs(tEzzs(jVm(7tUIvABO2YCrWtcqSDJYUXRQS)VkX(pbW0dDWWRBjbxbHLjQgp2)HmWh7)qOobCki4JJJTemUXHuBphIIBOt68vnXl2UyF4iiL0jkVvMCwEKpEfkF5ki(YuVxtslmiDrrVIXr0n9rOn9z3kcN32llLMRibjgz6Eebp4EeSCZle4pe5Ng6lmxlbKbiDWBZldCzeUb44HOXmB0kWtZWqIjl5veqovzWJktY3knPMX2KYiSjk43C5Tlgk7X46FiotkjIyVQGAZie5Sc2FfRspZKkJj9EpZ1ds)qEcb4YKaqbKi7DsMyPSH0cDSuVDU7FMmK7(NHHagFRE8DH6r4UrOL77Vk638ze0WB(mSsLa)CMKnCAoPKLzxOss4nUBLcD3efAsVNPVdNIMZZpGKzQ7LoBAOaejXuZs(eI01s(ee5DUwUdvSpkzZQGg(Y09BR5VuC9cqGXB3xcTSRIQdo)X7x(R)X7h2QBlhrwHhHWwKJIfElXjtajUJi1I0Xg805TCKPz7sgHaeAdwecc2f2smxSL4sqDpOKY8h8uy7mC2jkCsLT4ELjy47fQyxWsOnOYBzSFvwz))hSCazWhew)0cRrYv9gcoFvVbPvOT0uyarsPn6heeMVOe3Vkw9ikz9razTKp)tNYli)0P8cykgpStKwSehYb3ujE6XF984aK0faNTjh(RyNPDFpWpBhibzF5JrmZD5JrYBnRATvRLAxN5uySHjfjFlUo5nxqOGeI9Ik7)lsjuKIhjDGLiqN8q7qoMhAhadxFbkFynAHOQhsrGFW)M8TFW)gPrPTSE206nBWUz2nCWIf((CZre((CZHs5lNSJQJqZyx)izo21pIOtT5naN5uWw1AOJKI1y9pbrRt)tGCDZQxOdgmDIH9h8WYw8bpmjK2vARax7IMC2IQ4G)M2NmOnTpqnB3kBolwzBp6w4dVfXu(hElGFS1a)qYf1(DigteNXTUozdERRJmuGOtHjTYUHIrRQrUd1DT7aURTrX702RqzIVmrzcGuGQusu9dlsYN9WSdjx)HKT46peThIsjBv2wVd1hR7yTePLIRRQP3ydQAOnSkkWXakMIkCZj3HE(3X(iCCdCIfAXpWeA7qGj8qo6EKHC09WICKx6Wx0HgPt6j33RjJAFVweFCY1R6Oxp0r)WTytBPCr6BIVbnNABOrkyxRGEGGcLfkzpVgDpVgkFQoq(SQ9Cn5pUyJmpvMNZAHEzOCHvCOQSsUrfLTXdrJOHaHGjQDNNtVYr)n1D8B(AKN79zLVGFgbLDTsE2beeS5hMRh6JbLPGU1Bs36nHJ6FM)IJl(Mai7YahGntOllvY78L9PKD(Y(uGutCXzQSPJVHM1PT5OPTM8NqpPNGSJ1DFH0zf7eeECLp0yhkfEhRIpTu2Rj1oCXoHAgXPXVHuOhaXzQEk1LqsbU6Ym61Dt)nUQq3elTwpyTSGFF25TKYlKY4WpK81h(HOLyeHCsA1eHXJ9wIW4XElAqDdwTcikEwyOSqDnl7YvuWLJt5tdLlVHQKb6lVV5esz9ZZsuafBnNUmHR50lh43(oSOgBFhMyZsvZV9JWdbqYGHhczUOy5e2J51ZB5QdvlNnvhKLygqyZLrF1C)IfjaXumpBBMEvjm1pW1q)5pW1a2u2Yk8FhEsZBMP9rLnZ0(OyUNsxoz9Ie(7Eqho5mu9YPkPh7fLymbKcKMQVUjvpKMStBjYptBw6CnlskR65QR0(KUreNUipbiqv1NNm4xo)upENYH4X7KmRcTWWGr3(HsiW1SVTliH9TDQgwHf6l0Pcci2bLYMci75UTvMHQyql(4gqw1XnqKF99eWMmP)ATjKkvdiZ4h62ByWSMNM9lYOV4W0WUAirUed2I9xmir1755ma5XAWqPQ9m(fsXoodkJmJz2(dwUSMDafIikZyIW6MJXON8(oUSHU5B7cxnc096Cevvacr6z7xe2cesvnE3OYgCJ033QhCCiWoRLxv8bZFVckC(7f28xCFobUWJojtP)Qhv2()QhL2Dnt1yqcQckfYakZr)1Y6E0Fn937g2qJOD5TfpBQ5xlLicWQn2vPji(3Kc7diMcy8WMkCqLAv0SxgoB)Taoh)CAe4juCscil8A8p9mXLF6zIdILOzmmiikLO3JQx7EGET8tKuZVymzsqPuIH7grhit9gFjvb6lXkey59HgHybqLFrfL(flPv9OaDAlJrR7M4icbaEp3mz9wsxAYNv33pBcQFpGsWEJQsU5niBqZBGw2MZrvKlJzN2uRPOA)J9WFtHB9H)MusAH1WcuPd5)un)qEhbyPy90Wf0c(VPm2MKQiajhYwq(8buyedyBUaOCJDNOnefEyuSdg3RMm37LsM7zZU9mRU8T6hC0Ida8zyRs9PaK8)rsvN6aa)3FErTdG0SmF7qQYtDb3wWYey2E)F8u1EQpQi6CQGPAJZd7i3Hm5IlPfeF9Y(4vxpZZ5LjKJVSB)YvRWyBAdWSTMOiI5Sb2vu5dtUUrl7W1nAYaRVNn085PLMTM99YQcHxMQnqO)17uLKqSdjcBaccu9WJKa1kFnE)Rkn)Fv0s5cupxRRkwJoMejoGeBrLA)ff5bVZFx1LO3LZGvLAV28sYtLyuloYbJjiXdgJfROmLsn0rN2fjXJugFeXmpGKYNw40GamWqU2xQPOhtWeNPIjoZsX2snjyXndjvvasc7KpnTgQUUAiQdbe4gUWbNuGD7sdwBxiyTTdVSjhBqGsrXMAySADcwnjQBdla0euoSSy7tYucGKvDjrar(SBz7IqZ91ka)pQkx)hHa(E45(TvUI3M4kglL8NI9bKbcXYjkFMj386v9cRVCkng(rKpB4hHT(NMlIc0BQfA)De)Tae74O6BVyBR8QxYBw5L28OlXDrLfzEPzxQGQor9srY9iLfdqSgFwQiQuivr2rQD0IfqalNEUdOiYd8BzUj7GaU9B4cWYjcMh11Uzzux7MPUQjyi)8qhOqjkiszaYEdyCZIDoa5)94tuJqAIxpNrPI(AcIfBUXptnF7N5FMqMDpePmOjBxYQuzhK36PRc6Noz(ZjFFGzVSqMrt3QS3A6wjdRKcFseVyLaANSYmn5Jt5h3NQj7GwUC)Zv7Pl0jabwFXoKJceJsupdLCZRtX6RRmDCB)jvI)prHs4cD7SBVkDm2pFIcN1pFIKabSHviVgAB1(QxJ3TOsX3cRIZXnRuN6Q8GEZ3KU23egYKihRcOKNqTIevfGreS8B9uYM6TEkA6yNBOcS2p7ignCgz)BwnVOasrPyvOpSouPvpxeMUwaLT)1jebz5vskGTn39xjhwPbdF6S1ObHYyYbJ5aBVLnDCwILpaPXqPKPa3lJn43tub2mEeXdBajIbfOe0zOzNB7A252oIcR09le3JOe3JuAeLSRR(GDa1Xajdlash9odl2hBLU(SzzRmQ4ZZwsM7NTew3z7a2J09zljM0yxxPWYURRe)noP7Cz)tzmdngOzSgYZt4tVzdwEAZRv7O0A7oQmkRrDDkLaSZvXbQkEGGyiZf5R6N4tj7HpXNIIuMuGMtlHkcIxniFOeCrC8hK4FLgaPM7xCQhqs0VEiwuG7Ice9sMYcjRzAYeSMPbt9iCRIfL4ZRnUKJuajgsnS0lLeUXGibDzZnSQHE4ZKqJyrCiHOg99s7huEvmsQ5(jjL7NX1LTtHCuArsNomh14Er9bLHUMg)bsFbcZH1HZZW3rBeGVZGIFAGyIfb8kzJm)xZxvcMgqG25kE1vy60(AH495)iGaTF18u(kBsOFVcLkWXuTF7DGtBkJXE)YFFS3FjQ)48LwvZYe)tqlMz9UUdLk5tNso)pDQYs6V1FrfQ(l88ouojFClYjnu(ikCFSPlF1JnDsPUI04YeXZWb0i(oWVV8KUb1Y0gGmyPFj)tdR(eom5t4y7aMZTKixNhH3f5M1DLYyw3vsKNU7lOQUoSLYzqCnBtg1A2gXP0zOhNQ1bOibO2QuItzYcNcG0XAEHP7pAIAkWIJylXHLqzaKR5ON0QdGqoR5inwrYhu5dEqAlxPz2QkRhXEQVnpgabUPBkD0KkLwvVXnEEvU95j52j3sOxwRahiIjrorTjRByHOo35QEhzWx17qT0lBNNYTF5QUK8V9tecXF7Nq13M1kZF4lQRYl(mSERcuhirNLQCu0ydVKssipTNe3Mgryes)MjSkMx93lXCeLYasiVwD9do5U7Xi(yf2T4JfdjvxPdDL8nopPLU5mkJ4Ts(mAdb(m)aYqcu0krbegi5JU2FLmn1(RGuaxl)UYZ1JpXC(cZq2dFbYzQzNk5rgVmthz8ezNyWlNbYoOThpFPpMmFPpg5YtvD308iB9l2h(rwiLXBOjn8n(BrjCSmxHX1OeHRbeH8tnk(O3V22vWdNTm84Nnl(KxnA1UvMY(GETIwzaPnElbozDYCsneuD)tCnXaGeEzZ(KBjG)Oll3bQKfrpXNxab6QnslDLi7sEXNN8hV4ZReNUkeHS77XH41SDv4z7eA9tlARMTQTA2LE)sjpzJZvsjFQKhtD(6y1rv2fcnLJovRyX4v(cIkn(6nBm0TOZaAaqn6J5b4)0VRsLExWO3LTR0igoSILujpSsOp845dzbOdVcgyZjL)4MtgflQr8jOl5eyBJ(P7NQrA7vKermw7xoH37(lXDWp3vNUuMRS9YQnxxtsggaSe3HuwPvZWv1IygVMw7YxJiutOdR0LfIIACzjKI4xX7iEHCfGn6H7aQf0KzatucZhGuPLd5Yt2ITxWqQfxPVVbSIkAPktashqUNCKUw3Pix2gfZNs5etrCI1doEFXZiYVnXlYpYBiyQpcvZGjEsXX0)qbozirVKR8ceC8kVaQ)5k3aYgxBmLrog1wjudomI4nmIpjDhmjI23IJ83PW)RVyrQoFQHZZ8VkhXZ8Vsy6f5SuhEF2viczoNf3ht1TT)fwGyB)lqcT5L0Nf0sgXcC9Q5ORF6LQoG1gGeSRQjDBAne32Tt1LXhYBePQa13MIcZDOkm3bjf0cVGp3m4f854wIjl7xq5ynVR3ug)D9ML46wMbo8gsQc6mmQdomIpf90pfYCc5wg1e4(MuFsXdyVQDR9UnwlnNWocZadyLJ0ElAFrVL7Os4(D0NVTNZsyM0xvAIaajky3(qpQf9X0gXg(dMMAq1ugx4yLP5chlJHTCZey1pCMLsyP1aItggpMujvazF8jShL4NOqoshxfsjhDNGKkTl6ts1tSQ8PLCfxUqmwXLt9RMTxHQYbBTN2Zje6t75Oud4W0ikLDcxWZQCbex9yk3y2De4NXrcao5K(mYKpPpd1Fkk)wL(tjrnIUAaPE9NUlo9g6wvV()6kz(1bzEJC8cS4GsqsU7pOm97(dwskBnK3Zk6Agr9nn6uIlaqw9mFPbc89lYPQXjF(iTdpT0)zas2oKkjyolWyhy3pz1Vj70ov6t1et)7kB)P)D561OxvHobks2EZq3EZGysfZnZ86KvyMxhXdPD4Xi4HQZK98bGsXwXvBzzfG)JWGAQmOMCS5fDkuKIdnuqwjxMgn)YOO5JZ)0BD(Yp9wNpPN2YlBi1lRvLDQd)bKbC4pa3pZbbG0dMEh1ZW4txxrwsTEpQfxy9bDPDmyDMJt2SJdXQ1kxHtm7dYAKRBBltubSSsX6SllTpkmUhT(X3dv)4ZkQj4QpZ1hwXkHX22Jk)Vhj1kuxuwvj)QBL7Hf2x5EiLZvv)HARzlctznBHXVuLtCo52IjMGvaeCDlKAsw3rCdsE9DRCD7MDjaUFWQjL8JwGpzpVOR55PwsVNQYQvDMtvWhtf0GhJNTH1zB4DZAnsh43dNvKQ6qKKBtcxaWsr3UeZoT71Ts70yCqDAoiMM1lnyxvB5d)fL)6H)ImHQNHkuahQM8Z54fnbJw9Iz0WlMn2yqOim2Gw(Je7Yv4L3Ll1h9IpR2rI6JQhbRoQEISPf7TUc(Naek4Bl9qMDxPR(R5vuIWRq7gPGESVWPhc6m5t8AuhHwZNKUWGuiav5uEYTOj0ylRJQ0c89FiZzdhpSlanP8H5Pu95pfRpV(kUc3QRLJwn19jobdiI1SB7C51BIuID5PhvpsU8Bs)w8PijUcqAll3qL2sBpeqqI9HeCR2L4PP)CJKod3rML7KRt63jaXqMc2UolLZaua1MGK1rQj0ICJl5tincbGi2t2zEWCjcixJMx5RHBsyQ()CwugkyMuXeKoj920Bl5T1a14QrjguAflEapTMXZNMY45zZ(ywj1HbffFvm(1sZGdiLZkY33EcZIWjKlDYM12YCZpz5QQTZls(PDEreEOn6SjDtZLg1DV1EQcJkG4KX(M3JURt2UMEJ2jhPhpFxHytW9aUhWk3VGPRBBBvKU2kg1KIKSI29Z1bSsuYTtL8HNQmDp8ujnjTLXNJ18Q9ZMDwDzfOKLHvFHg(ciS5vhotxUx9QUhHQ9m0T8zqIOJRsCIDAxa6ylNwHJPzr)ynvgF8lpHm7)YtaHQf61NV7qvPETM3EP8FgqsMJUPvu)MsxCrEcVxXxyaX6o5ORFREqLWAUQqB5USK8OxOSuh9cjboQh6TkQS61ErBtkk2frEMmUQZTqZljpCzNUIUBtfz22BYQiYcRui496HMMfKrSGeBlNR4CYwoxYE6ikTy)ob5G)GyIs0KCzRaegOO8xgfBr8B4TfFMVH3U0jvAYftnenOzgF)ALDX3VwkL3VNoFowdYT9bqwoK(mH3UCxuh)bLsecyj29r6kLWUq1GVxyHujF9pMumGx)JX7IqhYmpB0kNdNH9uX7x64vaPM5W3T4iYIDIZ4bKt4z8a0m0nIYRGuATSuvYvx9sEOpUqqo0hN6xcUIVD3NTMZLeLK0dbioO09mHSnwrDrTj077qc66ZCws3RzUG859dGVaA(xJFdAqi3W78EORGAioWTVJkBJ9DuTFkQ73ZzPdac)aDR8nXuAOiTHG6)ZRN)ppiHKY7MZOjgElNVYcq2gJwWgSO80LYiHi9dO4oqHb5wsUJaRHI8G6LLSaciLvme(jWjui48F8rL0hcijlwf)UiwY4LrDocEzuNtucl32liQdOMCASlEOGCuUXRY3(4QlvXVoAlNwVzaS4JCyVj9WEtsBDNUFjRXHAYWJ)MsgpbK5g8Y67dVGPRSl(Zh6UPv)quRopMz775hWoz3nLj9IPmwO6G0cHds3(8OSHrfAuoSg6H1GyIa)xrh6ElW6PDcxQL0cxF)ttLhoTY6PFFQTW(0gKzFhjQNzIFksTHaKmG4uvFaz8OQm2JwlXAnx4nn3iFJm3yNVCnraKg0c6HAIwlVrwcvJpQ00easkOKKXoyuc772jdrEPcrYdE5slwbig8eNh0aNXs6nryw3K6xAilZhNnj3SDa1RDbuGqD(w508UlnOKDHGsoWc9O7slOyis2i1e3Q0Ywac2mkEbAxffi3wLBCiGLoPBXvJ(0D(lnfLdZSvNKKra5MTWvIGPbO)weaJTLzOIdZ4K1O1iL8AOom5QMRSxx1CjD8wscpV6cG6XBM6)qYMP(pu188TAPfXHgtnXKlagGeTG5Y47swt29AhvjwJdO516aKUGZI8rm0tZpGfvZFEqNqf)obLe(XSayIRx66pVih4gIpZxMOv5Y2cyjop0Ev6dqlnNyBVgzw2EnKDGYPpK7AMmv3(SpN0BwaY84ejgRM0DnvctQn5caaiv5cQAkCd0YZWKkkZWKksSXwoULVwRjFjrdjGSPGQUXBnfwGlvuYtCzYqoXLvIVfEuQMyofkuhlnJxRvjqRDU08SqpxS49rMek3yCj3JYqUN6P4m5YK2Ov5R1PXwv8XwRHBjJ0PdLA3PI6Xk9HfUXsF4sX6PzVGO8TmSMo8HP0HFwv)UtuLNAhxBJ5JFNK3O8rpUHCDFbKyA0kpiL6cyhj25SsIzbKvauv)sACqnqXdIafZNAHKXhIDs8tKmiwUvSmUivL(frQ0NiIm2h)pWtnpGTHtxZYSLOmHhFIAw6Osgo56548LodFwTgqjGUjNc5DTGfP3vcnaqkufUkF5TT07NwYxtUKMacKzuL5Odwo5Q4FrFmDh9XyDoV3Duv9VBTjFxrao57siV)p50lndGb3maJRnx3qUloMRpfvK58aEh)nvV9bNo9DVc)DxM05)asC98L2nsYGlH5GdPjw5nftuaYsqC2egXvQoLX(vlD7pbLPTWaYp3oCs3V1sK)(PlMCamYvYe5(Hc9m3pKQTwi3h769gm5lixyxaP2b0jBwqnB1NaIv3nnkz620OWoA8rkH4SAY1HZpqBei5j0aqmUP0wU8uRNMrYitry4l0Uk3GQ5tkPAgqAwPiOONmeLoNUIJqF6aXHRpDaflNfDnHLkqMY4m)0Yg7m)0S9tkhrK33ZhFS2qAj(s3RuNGV09wIBb)Erqom7A7KAyQvpTHtDp3mvnnZKMiPz5mLlLCuaUltlq6YyPTo5JnLSFUcM2w9cwxnQP40BmZ41(FKZ(a1ttL7(YKxzbzXUs6f)ymLB1IQWn1wNKSwalZ4fFQIXcajP2kQX1YUKYyVY1ZfqTSYZS8LwX4Lus4lnkQhyPsRk2RfzMLPYmlJ0Zc6l3LQLTMPAJFq5A6bi4sud5fn5cTWy6tvsCnGLKROwgnT(4ORf(m(NvU(naIGMH9dOfvCf9JihyaH6M67br4u2lHTlXodi0EUi7IKJlZKVou82AtYlAcGu98Ddxc94oums36lDg65(mie5X5FBd6DaAdFvwZp10noEJSmi7vLb375uDNau(11X4eQpqNG9bQEclXByZp0SP8m83jsPA8x7pjT27N3T7uEhiaKqsJic3gCLl7y8FHCDube4IwSDLMxbmdtqzkMa5oHZaCY2QQ83gNq9j8eKpHJH3v87nZhI8Mq2t3SWOdiLYU8bqyhULvX1hJHLOEbeZX047QJv6IxQj3ujQfy2NBLQFVsXWbKvhgeq3ebkKiPR)8vFZ32yKPDBJH4)Oo0VsBHAmt1q2mVYsLZoYit8DYJl9OpGGkt9Qxvj4QUXXLtgaQbQXE0lR95YtCtApG1evpm242G2rDPxChjRTasAgKNoc(nvartsLgTmZWZjfodqQNwPIq2Ovb663Y7SJixDhaXQ3bWxo9AVebvozrJXWtMuhwbvoBOa1FWEj1OsdqdBzQS17E1cLJ67Pr2eYgpQ4mjG8qilNYvjN79qrdHKUvajgU3H3E7wQInGukydd8ml6BslaJ5gphPgaucA4SZtKnljtrFBjbZacHv(6ll3H8eN6FvL05c0WvyHz(JQVTC616nnmvVPPx50xpSJLRh3Y3pb6HwqYpWMftZaYX02)qYt5sz6WDj5AbWs8TLwUR0LBnvwJipWdQL34GJTS534J6)sWnJ6)ISXH5LIiGBUlMvjrZsLMbunLeuSqpu5vyZRPmw95kZ5QpxIvY3f8iTgLF0Khr1bDKRIAaskkRk8zjFETkfp)NbZ8KAonzXH2VCTJPc4NPSR6XVKjl7YlzY0n9IQxHMYYnlVGqawI77yx(vz4KUWUglx9Xy5KpgNBx5OW(d4esHOp4xohDLjhT13(LDViLbHEWJOlxMhNs7odDufcJtPJJBKkeAe2pt7WEc0KFGNFw55(Qg37IrKaskeQo)ADALRFlWzNQMDkowdyLwcrDQCdMenRvzPhVU0Jh)wSpc)B9OI09qT1j)4Iuq8ejZauub69PBb)gHAUGFdwG5NkzkrLpG4F)ZltUgp5WtGM8PZ)2MohrIDtNJuXfVLsH30nxJ4VJ0y8aczLiMVzdFisf)8KR5fGmvZjDKJtdprDnMyL1yyTJag(SlFOI9osGWac(Ntklnj)usO4awIFOuYzNXPQBFv7YAayugn2K0VZB6Mztm6tMeraQ0laNqIsdWsCdfi15Mmdc8i1YAAh65(VRets7(up5KLg1HMDsz9Y47P1947D(Keuh(CDYGegu2fjk8kYZCfGKOqdHUdQ9drNC9ayX5io(DCnYy3X1GXoXwhc(iN2pVtAZ5c3sCYW)BCnIMkxtgaORihwP8r1xm5(uHM9bHM13wH(TScSi1LCKaXoWFNG0pWFhVF1RxmCLVsZW)l1Cr(lVNY(rFkQxoNc7LZ89nBrIKJEu3khyMwQ3HNcrItXR2u2PSAtzNsF3pGZaSZrnyjQl3RQEFVq9(gl7XrupyMyT)yzzx7pMD4qF2vcbHRkp0wxFY5DD9r7TYv(U62yW4eQ99tq23hB1EUq3AxXjHNqtQWt8HO0ob7zfYRDpzT1jCBawjIOH1T(WtJoUNbFCh8jLmBm4tcRIZZ3N95gNonWO9o9Q9RAXrporjMT0cNasgK0N3e7OYsmS6v2WNt0cv3VIFfdaGkvwAxN8Weg3b68hCq9do45u2qqYJiEPdi1rw09JrY)R(iETU(vCy)0ACL8V1ElseiT3cNg(E4RFhNswCsu7c79CjhtIor1Rbqw3Kv01KlJUsUv5vSbqU0w2QNm8g(4kQ84ugJ4CFrnAJDprP834e6aob5fWzxLlEA9TycyYlrs7hGuJZNonhHi)91isvacnn6f5QxhnBjhtDo9yKZPtBX9zvKBkhFQHz(OiIq)mCxJG)TRGh)BPvz7TOQSHWfYg6wPPORnHM9RemhTLJGyOAat)541ifCaqIruFP962oDFEo0R6hVBVizmawI6IS3BW61hDbGs(sYR5dGLo505iVhHf5cdx8NlL6pdCaPQQR9vKm2diz0QCSO0l5xLgOTUjZn1ga0L0MtAnf)yic9611kD96hJZOORtoUSavUUzU3JQiLEc5oVtwrARu2KCSeRZZEOR3YnvYNsEhCaKSfrLNah86dYj(4eFp61HApduIltb9SMqndFvvT95K8gbiXkpbHHC6kd50lZqM42KNXmajnTaL6cnbZuKkJQWOe56QoGSNw1bOCD)(ClIFrDjFXpmLloU96I6G3AhLU0JA6Ln6)d1R38p8EjzXYxRqn7Dg)b1DM)a5oZ4kNOwOQwAgmXD0KhsggG8tFs2YnJDTJYuxsZYl5nRxM4B(fJY1DY1D7I4964xZMr2wPD1Vd1rG7wFao3n9aCorEI(A6RFXx7(i(xozk0MR6NOW4xMiTbi1n0rjLTCF7x3vZkSbatbqIUU8DBQXGkohZpohfCPkGWR6bvvZhKY3lmf2NDrhts4XEWOoKHREV0CE8NK6RloUK6RZK3IyFMMwkOxbqNE4l7qkJPjpRBaYwy6TODuxKv5Irf)0LURaqPXjy3JQ65xi(u)OAskORI4KBUifaJR(Km2KJvoFO5KDxirDYv)bqABbpQZ4u5(NqVRMKvP6Ma)yQaaSxeDdyRsUD7sT2be8BxvOdwf6f5Gp3pQy8gqkjz(U(Ctlu5fmDPA0YlLIwEcLVWZDA741l1RqLJ9CLA6rw5Y4BEOfDD4CIu8y8vKRVlGKRuJ45QP6oJ0Ow9bTR2Ej340NBxM9IrCVU4goGKI5a6Ke9y4v3JXTRgaupvQlqJobPLSYxZBO3d53GUhYNTel)iUSfiYA95NCM)ZKQGXYhRnRpZnBEd0fyZ1rAjbEVAknmcGu3UTuqChzLBsmh1lO5qEbnUU6321M78zFV(ThI61c5Lz(5(4QgOpoPKQDeWcy7Gly2f7byBr4v7k1dDEeAXf2qSR6EDAmBn5pZE0m2LKXSfHiYss2YP(y9I6FaPo6RCldAnWaIoIvQvtDLFCkjsQ37noKIctSw59Lcq6alExTiycO8d06xPnLk3gHaLNtSvQLmFLxi9B3iprNqiJasDVzFstMw2HYAhvrvHuXiN1xn)U1ca(HK8sTw9L9DTFjsXc9CTsTp7m5Gnu0sIlqy6aKUug0D1ix5YVM8X13XWhFLuoEydRdnI3rVrDl6U4wkRw00vP4UuY9OwMOAcEDN7U4D55UlYjh29NQE(SUtf3CN079445KzZjD)KEudn(WsVbdiXnu5nLTQ0uEnVTmKR5TjZtlG)TlvVrnxACQlbVa6(uA2I6YIXj()K)4j()WCE(lcHac6k1WpxQ58TxsyHz1byw43R75o0mhWEPsvZ2ZflF1EUyI9L89t9PZNA(dQmrmIChI5jajkrL391oHzpvHxnEEIWNNxj52N6zvOqyvpvoghrQpfG0iwKVBrlU)SOsTevKyJPPpyLtZHUt1KYxNOWjIVo5PbcWsr3Z)HBrg(WTqO8Ql9dxpbROBJ0B8nfD)VX3eScn7LTS0dc7iv8lq6IhaPxkVQ6HTA8YPNkUKHTf4tQeZAx1fZ6hjBkaXiMcIemVJDAjXg0nUNEpFR61izJ6f7BJRHD7eup47K(S8zSDTL92o1YEJnIHfUTgyx5TKtsJfGvAPIkx4mJNwV9ip9gP2lBj8l8Gx0Bh7ABufOASe9INsDWLzLBhrItvFEwp1HPhEeeynubjL2F)YlrgGewyKogqr(ZhT3rImdqm7DA3lF36QuDY1UbXm3APhtSjuFLgWPnVmqBMgx0fRQVUyY71ZQtFUZLemrVLVinlxFQIxo9ufpXUD8Yixw1wOBPElu2pkipkUj)zQVJ)SVcDpkZLFiyIMTcRpdsX3LmtX3fHXLNI9tQt6n2ZLPYix27JmYSJY)BYh42KL6bUnmSuLFIzoPhVDgv8uItuaYEpYTRu9E0B1IuRgdtpvjejlngT7vhHHNAhTOhhqAiYvWBKvUm(uNJ6cYCG4s9PI96sFvdiHB5TVFVC1Obsl6Qf946DC4XNnPl)BZ)26KMfcqsz0LZ)23w5d)2GpC7LJtO8n7k5Ri92dG0(tts)ioc14(d0qb43a7QdfOB4FO1sT8adXB()iRZB()uDgHKfjML84BbiffTFaLnCWC6P1a1i91js9PVowNuLB5s7wzZt(ZM8L)cY28L)cL4BtNNtF0Bt0iZG7n(zL9Wn(zj(Tkz(JNqkl5i6CHjyFY1QbWs8RHHxAv9b9K)FwsI3D8Q6rgjXasY3bK4aR6PKDUo56rBXL3v5aF3lJV8pUu7rSGCs)QLyGrPtavtYZQ6jaUmpZbfnlxI(03Ejqn2gBt()kf6SVHk2NuP17uFR3VtySMU3Vu1nm5w5mGlGUW2ohjn(aYSCQNPM6Zy2kO))7IUhkV9gTcdSyViPog7)3p!BBF"
        local profileData, errorMessage = BBF.ImportProfile(importString, "auraBlacklist")
        if errorMessage then
            print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rFrames: Error importing blacklist:", errorMessage)
            return
        end
        deepMergeTables(BetterBlizzFramesDB.auraBlacklist, profileData)
        BBF.auraBlacklistRefresh()
        Settings.OpenToCategory(BBF.aurasSubCategory)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
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
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetOrientation('HORIZONTAL')
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(stepValue)
    slider:SetObeyStepOnDrag(true)

    slider.Text:SetFontObject(GameFontHighlightSmall)
    slider.Text:SetTextColor(1, 0.81, 0, 1)

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
        category = "General"
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
                elseif element == "partyFrameScale" then
                    BetterBlizzFramesDB.partyFrameScale = value
                    BBF.CompactPartyFrameScale()
                elseif element == "darkModeColor" then
                    BetterBlizzFramesDB.darkModeColor = value
                    if not BBF.checkCombatAndWarn() then
                        BBF.DarkmodeFrames()
                    end
                elseif element == "lossOfControlScale" then
                    BetterBlizzFramesDB.lossOfControlScale = value
                    BBF.ToggleLossOfControlTestMode()
                    BBF.ChangeLossOfControlScale()
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
                    BBF.CastbarAdjustCaller()
                elseif element == "focusToTAdjustmentOffsetY" then
                    BetterBlizzFramesDB.focusToTAdjustmentOffsetY = value
                    BBF.CastbarAdjustCaller()
                elseif element == "castBarInterruptIconScale" then
                    BetterBlizzFramesDB.castBarInterruptIconScale = value
                    BBF.UpdateInterruptIconSettings()
                elseif element == "castBarInterruptIconXPos" then
                    BetterBlizzFramesDB.castBarInterruptIconXPos = value
                    BBF.UpdateInterruptIconSettings()
                elseif element == "castBarInterruptIconYPos" then
                    BetterBlizzFramesDB.castBarInterruptIconYPos = value
                    BBF.UpdateInterruptIconSettings()
                elseif element == "uiWidgetPowerBarScale" then
                    BetterBlizzFramesDB.uiWidgetPowerBarScale = value
                    BBF.ResizeUIWidgetPowerBarFrame()
                elseif element == playerClassResourceScale then
                    BetterBlizzFramesDB[playerClassResourceScale] = value
                    BBF.UpdateClassComboPoints()
                    --end
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
            GameTooltip:AddDoubleLine("CPU Usage:", starString, 0.2, 1, 0.6, 0.2, 1, 0.6)
        end

        if category then
            GameTooltip:AddLine("")
            GameTooltip:AddLine("|A:shop-games-magnifyingglass:17:17|a Setting located in "..category.." section.", 0.2, 1, 0.6, true)
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
    DEATHKNIGHT = "|ffc41f3b",
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
    local profileText = string.format("|A:%s:16:16|a %s%s|r", icon, color, profileName.." Profile")
    local confirmationText = titleText .. "This action will delete all settings and apply\nthe " .. profileText .. " and reload the UI.\n\n" .. noteText .. "Are you sure you want to continue?"

    StaticPopupDialogs["BBF_CONFIRM_PROFILE"].text = confirmationText
    StaticPopup_Show("BBF_CONFIRM_PROFILE", nil, nil, { func = profileFunction })
end

local function CreateClassButton(parent, class, name, twitchName, onClickFunc)
    local bbfParent = parent == BetterBlizzFrames
    local btnWidth, btnHeight = bbfParent and 96 or 150, bbfParent and 22 or  30
    local button = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    button:SetSize(btnWidth, btnHeight)

    local dontIncludeProfileText = bbfParent and "" or " Profile"
    local color = CLASS_COLORS[class] or "|cffffffff"
    local icon = CLASS_ICONS[class] or "groupfinder-icon-role-leader"

    button:SetText(string.format("|A:%s:16:16|a %s%s|r", icon, color, (name..dontIncludeProfileText)))
    button:SetNormalFontObject("GameFontNormal")
    button:SetHighlightFontObject("GameFontHighlight")
    local a,b,c = button.Text:GetFont()
    button.Text:SetFont(a,b,"OUTLINE")
    local a,b,c,d,e = button.Text:GetPoint()
    button.Text:SetPoint(a,b,c,d,e-0.5)

    button:SetScript("OnClick", function()
        if onClickFunc then
            onClickFunc()
        end
    end)

    if class == "STARTER" then
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name.." Profile"), "A basic starter profile that only enables the few things you need.\n\nIntended to work as a very minimal quick start that can be built upon.", nil, "ANCHOR_TOP")
    elseif class == "BLITZ" then
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name.." Profile"), "A more advanced profile enabling a few more settings and customizing things a bit more.\n\nGreat for Battlegrounds (and Arenas) with Class Icons showing Healers, Tanks and Battleground Objectives.", nil, "ANCHOR_TOP")
    elseif class == "MYTHIC" then
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name.." Profile"), "A great well rounded profile made by |cffc79c6eJovelo|r that enhances the default Blizzard nameplates.\n\nGreat for all types of content with Mythic+ Season 2 NPC nameplate colors included.", nil, "ANCHOR_TOP")
    else
        CreateTooltipTwo(button, string.format("|A:%s:16:16|a %s%s|r", icon, color, name.." Profile"), string.format("Enable all of %s's profile settings.", name), string.format("www.twitch.tv/%s", twitchName), "ANCHOR_TOP")
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
    importBtn:SetSize(title ~= "Full Profile" and 52 or 73, 20)
    importBtn:SetText("Import")
    importBtn:SetNormalFontObject("GameFontNormal")
    importBtn:SetHighlightFontObject("GameFontHighlight")
    CreateTooltipTwo(importBtn, "Import Data", "Import an export string.\nWill remove any current data (optional setting coming in non-beta)")

    -- Keep Old Checkbox
    local keepOldCheckbox
    if title ~= "Full Profile" then
        keepOldCheckbox = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
        keepOldCheckbox:SetPoint("RIGHT", importBtn, "LEFT", 3, -1)
        keepOldCheckbox:SetChecked(true)
        CreateTooltipTwo(keepOldCheckbox, "Keep Old Data", "Merge the imported data into your current data.\nWill keep your settings but add any new data.")
    end

    -- Button scripts
    exportBtn:SetScript("OnClick", function()
        local exportString = ExportProfile(dataTable, tableName)
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
    CreateTooltipTwo(wipeButton, "Delete "..title, "Delete all the data in "..title.."\n\nHold Shift+Alt and Right-Click to delete and reload.")

    wipeButton:HookScript("OnEnter", function()
        wipeButton:Show()
    end)

    wipeButton:HookScript("OnLeave", function()
        C_Timer.After(0.5, HideWipeButton)
    end)


    importBtn:SetScript("OnClick", function()
        local importString = importBox:GetText()
        local profileData, errorMessage = BBF.ImportProfile(importString, tableName)
        if errorMessage then
            print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rFrames: Error importing " .. title .. ":", errorMessage)
        else
            if not profileData then
                print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rFrames: Error importing.")
                return
            end
            if keepOldCheckbox and keepOldCheckbox:GetChecked() then
                -- Perform a deep merge if "Keep Old" is checked
                deepMergeTables(dataTable, profileData)
            else
                -- Replace existing data with imported data
                for k in pairs(dataTable) do dataTable[k] = nil end -- Clear current table
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

    local category
    if parent.name then
        category = parent.name
    elseif parent:GetParent() and parent:GetParent().name then
        category = parent:GetParent().name
    elseif parent:GetParent() and parent:GetParent():GetParent() and parent:GetParent():GetParent().name then
        category = parent:GetParent():GetParent().name
    end

    if category == "Better|cff00c0ffBlizz|rFrames |A:gmchat-icon-blizz:16:16|a" then
        category = "General"
    end

    checkBox.searchCategory = category


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
        --print("Checkbox option '" .. option .. "' changed to:", value)
    end

    UpdateOption(BetterBlizzFramesDB[option])

    checkBox:HookScript("OnClick", function(_, _, _)
        UpdateOption(checkBox:GetChecked())
    end)

    return checkBox
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
                print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconString .. " " .. spellName .. " (" .. entry.id .. ") removed from list.")
            elseif entry.name then
                print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. entry.name .. " (" .. entry.id .. ") removed from list.")
            else
                print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: Spell ID " .. entry.id .. " removed from list (info not found).")
            end
        else
            print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. entry.name .. " removed from list.")
        end

        BetterBlizzFramesDB[listName][key] = nil
    end

    BBF.currentSearchFilter = ""

    if SettingsPanel:IsShown() then
        if BBF[listName.."Refresh"] then
            BBF[listName.."Refresh"]()
        end
    else
        --print("prepping delayed update")
        BBF[listName.."DelayedUpdate"] = BBF[listName.."Refresh"]
    end

    BBF.RefreshAllAuraFrames()
end

local lists = { "auraBlacklist", "auraWhitelist" }

for _, listName in ipairs(lists) do
    -- Create static popup dialogs for duplicate confirmations
    StaticPopupDialogs["BBF_DUPLICATE_NPC_CONFIRM_" .. listName] = {
        text = "This name or spellID is already in the list. Do you want to remove it from the list?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            deleteEntry(listName, BBF.entryToDelete)  -- Delete the entry when "Yes" is clicked
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    -- Create static popup dialogs for delete confirmations
    StaticPopupDialogs["BBF_DELETE_NPC_CONFIRM_" .. listName] = {
        text = "Are you sure you want to delete this entry?\nHold shift to delete without this prompt",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            deleteEntry(listName, BBF.entryToDelete)  -- Delete the entry when "Yes" is clicked
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
end

StaticPopupDialogs["BBF_DUPLICATE_UPDATE_OR_DELETE"] = {
    text = "This name or spellID is already in the\nblacklist with \"Show Mine\" tag.\n\nDo you want to update the tag or\ndelete it from the blacklist?",
    button1 = "Update and always hide",
    button2 = "Delete from blacklist",
    OnAccept = function()
        BBF["auraBlacklist"](BBF.entryToDelete, "auraBlacklist", nil, true)  -- Update when accepted
    end,
    OnCancel = function()
        deleteEntry("auraBlacklist", BBF.entryToDelete)  -- Delete the entry when "Yes" is clicked
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}


local function addOrUpdateEntry(inputText, listName, addShowMineTag, skipRefresh, color)
    BBF.entryToDelete = nil
    local name, comment = strsplit("/", inputText, 2)
    name = strtrim(name or "")
    comment = comment and strtrim(comment) or nil
    local id = tonumber(name)
    local printMsg
    local spellName
    local icon
    local iconString
    local _

    -- Check if there's a numeric ID within the name and clear the name if found
    if id then
        spellName, _, icon = BBF.TWWGetSpellInfo(id)
        name = spellName or ""

        if not spellName then
            print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: No spell found for ID: "..id)
            return
        end

        if icon then
            iconString = "|T" .. icon .. ":16:16:0:0|t"
        else
            iconString = ""
        end

        -- Check if the spell is being added to blacklist or whitelist
        if listName == "auraBlacklist" then
            printMsg = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconString .. " " .. spellName .. " (" .. id .. ") added to |cffff0000blacklist|r."
        elseif listName == "auraWhitelist" then
            printMsg = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconString .. " " .. spellName .. " (" .. id .. ") added to |cff00ff00whitelist|r."
        end
    end

    -- Remove unwanted characters from name and comment individually
    name = gsub(name, "[%/%(%)%[%]]", "")
    if comment then
        comment = gsub(comment, "[%/%(%)%[%]]", "")
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
                    BBF.entryToDelete = key  -- Use key to identify the duplicate
                    if addShowMineTag then
                        BBF.DuplicateWithTag = true
                    end
                end
            elseif listName == "auraWhitelist" then
                isDuplicate = true
                BBF.entryToDelete = key  -- Use key to identify the duplicate
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
                    printMsg = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconString .. " " .. spellName .. " (" .. id .. ") added to |cffff0000blacklist|r with tag."
                end
            end

            -- Add the new entry to the list using key
            BetterBlizzFramesDB[listName][key] = newEntry

            -- Update UI: Re-create text line button and refresh the list display
            if BBF["UpdateTextLine"..listName] then
                BBF["UpdateTextLine"..listName](newEntry, #BBF[listName.."TextLines"] + 1, BBF[listName.."ExtraBoxes"])
            end

            BBF.currentSearchFilter = ""

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
                    --print("prepping delayed update")
                    BBF[listName.."DelayedUpdate"] = BBF[listName.."Refresh"]
                end
            end

            if printMsg then
                print(printMsg)
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
    BBF[listName.."TextLines"] = textLines
    BBF[listName.."ExtraBoxes"] = extraBoxes
    local framePool = {}
    BBF.entryToDelete = nil
    BBF.currentSearchFilter = ""

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

            -- Delete Button
            local deleteButton = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
            deleteButton:SetSize(20, 20)
            deleteButton:SetPoint("RIGHT", button, "RIGHT", 4, 0)
            deleteButton:SetText("X")
            deleteButton:SetScript("OnClick", function()
                if IsShiftKeyDown() then
                    deleteEntry(listName, button.npcData.id or button.npcData.name:lower())
                else
                    BBF.entryToDelete = button.npcData.id or button.npcData.name:lower()
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
            displayText = string.format("%s (%d)", (npc.name or "Name Missing"), npc.id)  -- Display as "Name (id)"
        else
            displayText = npc.name  -- Display just the name if there's no id
        end
        button.text:SetText(displayText)
        button.iconTexture:SetTexture(C_Spell.GetSpellTexture(npc.id or npc.name))

        -- Function to set text color
        local function SetTextColor(r, g, b, a)
            if colorText and button.checkBoxI and button.checkBoxI:GetChecked() then
                button.text:SetTextColor(r or 1, g or 1, b or 0, a or 1)
            else
                button.text:SetTextColor(1, 1, 0, 1)
            end
        end

        -- Function to set important box color
        local function SetImportantBoxColor(r, g, b, a)
            if button.checkBoxI then
                if button.checkBoxI:GetChecked() then
                    button.checkBoxI.texture:SetVertexColor(r or 0, g or 1, b or 0, a or 1)
                else
                    button.checkBoxI.texture:SetVertexColor(0, 1, 0, 1)
                end
            end
        end

        -- Initialize colors based on npc data
        local entryColors = npc.color or {1, 0.8196, 0, 1}  -- Default yellowish color 
        

        -- Extra logic for handling additional checkboxes and flags
        if extraBoxes then
            -- CheckBox for Pandemic
            if not button.checkBoxP then
                local checkBoxP = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxP:SetSize(24, 24)
                checkBoxP:SetPoint("RIGHT", button.deleteButton, "LEFT", 4, 0)
                checkBoxP:SetScript("OnClick", function(self)
                    button.npcData.pandemic = self:GetChecked() and true or nil
                    BBF.RefreshAllAuraFrames()
                end)
                checkBoxP.texture = checkBoxP:CreateTexture(nil, "ARTWORK", nil, 1)
                checkBoxP.texture:SetAtlas("newplayertutorial-drag-slotgreen")
                checkBoxP.texture:SetDesaturated(true)
                checkBoxP.texture:SetVertexColor(1, 0, 0)
                checkBoxP.texture:SetSize(27, 27)
                checkBoxP.texture:SetPoint("CENTER", checkBoxP, "CENTER", -0.5, 0.5)
                button.checkBoxP = checkBoxP
                local isWarlock = playerClass == "WARLOCK"
                local extraText = isWarlock and "\n\nIf Agony or Unstable Affliction refresh talents are specced it will first glow orange when entering this window then switch to red once it enters the pandemic window as well." or ""
                CreateTooltipTwo(checkBoxP, "Pandemic Glow |A:elementalstorm-boss-air:22:22|a", "Check for a red glow when the aura has less than 30% of its duration remaining.\nOr last 5sec if the aura has no pandemic effect."..extraText, "Also check which frame(s) you want this on down below in settings.", "ANCHOR_TOPRIGHT")
            end
            button.checkBoxP:SetChecked(button.npcData.pandemic)
    
            -- CheckBox for Important with color picker
            if not button.checkBoxI then
                local checkBoxI = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxI:SetSize(24, 24)
                checkBoxI:SetPoint("RIGHT", button.checkBoxP, "LEFT", 4, 0)
                checkBoxI:SetScript("OnClick", function(self)
                    button.npcData.important = self:GetChecked() and true or nil
                    BBF.RefreshAllAuraFrames()
                    SetImportantBoxColor(button.npcData.color[1], button.npcData.color[2], button.npcData.color[3], button.npcData.color[4])
                    SetTextColor(button.npcData.color[1], button.npcData.color[2], button.npcData.color[3], button.npcData.color[4])
                end)
                checkBoxI.texture = checkBoxI:CreateTexture(nil, "ARTWORK", nil, 1)
                checkBoxI.texture:SetAtlas("newplayertutorial-drag-slotgreen")
                checkBoxI.texture:SetSize(27, 27)
                checkBoxI.texture:SetDesaturated(true)
                checkBoxI.texture:SetPoint("CENTER", checkBoxI, "CENTER", -0.5, 0.5)
                button.checkBoxI = checkBoxI
                CreateTooltipTwo(checkBoxI, "Important Glow |A:importantavailablequesticon:22:22|a", "Check for a glow on the aura to highlight it.\n|cff32f795Right-click to change color.|r", "Also check which frame(s) you want this on down below in settings.", "ANCHOR_TOPRIGHT")
            end
            button.checkBoxI:SetChecked(button.npcData.important)
    
            -- Color picker logic
            local function OpenColorPicker()
                local colorData = entryColors or {0, 1, 0, 1}
                local r, g, b = colorData[1] or 1, colorData[2] or 1, colorData[3] or 1
                local a = colorData[4] or 1 -- Default alpha to 1 if not present

                local function updateColors(newR, newG, newB, newA)
                    -- Assign RGB values directly, and set alpha to 1 if not provided
                    entryColors[1] = newR
                    entryColors[2] = newG
                    entryColors[3] = newB
                    entryColors[4] = newA or 1  -- Default alpha value to 1 if not provided

                    -- Update text and box colors
                    SetTextColor(newR, newG, newB, newA or 1)  -- Update text color with default alpha if needed
                    SetImportantBoxColor(newR, newG, newB, newA or 1)  -- Update important box color with default alpha if needed
                    -- Refresh frames or elements that depend on these colors
                    BBF.RefreshAllAuraFrames()
                end

                local function swatchFunc()
                    r, g, b = ColorPickerFrame:GetColorRGB()
                    updateColors(r, g, b, a)  -- Pass current color values to updateColors
                end

                local function opacityFunc()
                    a = ColorPickerFrame:GetColorAlpha()
                    updateColors(r, g, b, a)  -- Pass current color values to updateColors including the alpha value
                end

                local function cancelFunc(previousValues)
                    -- Revert to previous values if the selection is cancelled
                    if previousValues then
                        r, g, b, a = previousValues.r, previousValues.g, previousValues.b, previousValues.a
                        updateColors(r, g, b, a)  -- Reapply the previous colors
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
    
            -- Right-click to open color picker
            button.checkBoxI:SetScript("OnMouseDown", function(self, button)
                if button == "RightButton" then
                    OpenColorPicker()
                end
            end)
    
            -- CheckBox for Compacted
            if not button.checkBoxC then
                local checkBoxC = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxC:SetSize(24, 24)
                checkBoxC:SetPoint("RIGHT", button.checkBoxI, "LEFT", 3, 0)
                button.checkBoxC = checkBoxC
                CreateTooltipTwo(checkBoxC, "Compacted Aura |A:ui-hud-minimap-zoom-out:22:22|a", "Check to make the aura smaller.", "Also check which frame(s) you want this on down below in settings.", "ANCHOR_TOPRIGHT")
            end
            button.checkBoxC:SetChecked(button.npcData.compacted)
    
            -- CheckBox for Enlarged
            if not button.checkBoxE then
                local checkBoxE = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxE:SetSize(24, 24)
                checkBoxE:SetPoint("RIGHT", button.checkBoxC, "LEFT", 3, 0)
                checkBoxE:SetScript("OnClick", function(self)
                    button.npcData.enlarged = self:GetChecked() and true or nil
                    button.checkBoxC:SetChecked(false)
                    button.npcData.compacted = false
                    BBF.RefreshAllAuraFrames()
                end)
                button.checkBoxC:SetScript("OnClick", function(self)
                    button.npcData.compacted = self:GetChecked() and true or nil
                    button.checkBoxE:SetChecked(false)
                    button.npcData.enlarged = false
                    BBF.RefreshAllAuraFrames()
                end)
                CreateTooltipTwo(checkBoxE, "Enlarged Aura |A:ui-hud-minimap-zoom-in:22:22|a", "Check to make the aura bigger.", "Also check which frame(s) you want this on down below in settings.", "ANCHOR_TOPRIGHT")
                button.checkBoxE = checkBoxE
            end
            button.checkBoxE:SetChecked(button.npcData.enlarged)
    
            -- CheckBox for "Only Mine"
            if not button.checkBoxOnlyMine then
                local checkBoxOnlyMine = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxOnlyMine:SetSize(24, 24)
                checkBoxOnlyMine:SetPoint("RIGHT", button.checkBoxE, "LEFT", 3, 0)
                checkBoxOnlyMine:SetScript("OnClick", function(self)
                    button.npcData.onlyMine = self:GetChecked() and true or nil
                    BBF.RefreshAllAuraFrames()
                end)
                button.checkBoxOnlyMine = checkBoxOnlyMine
                CreateTooltipTwo(checkBoxOnlyMine, "Only My Aura |A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:22:22|a", "Only show my aura.", nil, "ANCHOR_TOPRIGHT")
            end
            button.checkBoxOnlyMine:SetChecked(button.npcData.onlyMine)
        end

        if listName == "auraBlacklist" then
            if not button.checkBoxShowMine then
                -- Create Checkbox Only Mine if not already created
                local checkBoxShowMine = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxShowMine:SetSize(24, 24)
                checkBoxShowMine:SetPoint("RIGHT", button, "RIGHT", -13, 0)
                CreateTooltipTwo(checkBoxShowMine, "Show mine |A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:22:22|a", "Disregard the blacklist and show aura if it is mine.", nil, "ANCHOR_TOPRIGHT")

                -- Handler for the show mine checkbox
                checkBoxShowMine:SetScript("OnClick", function(self)
                    button.npcData.showMine = self:GetChecked() and true or nil
                    BBF.RefreshAllAuraFrames()
                end)

                -- Adjust text width and settings
                button.text:SetWidth(196)
                button.text:SetWordWrap(false)
                button.text:SetJustifyH("LEFT")

                -- Save the reference to the button
                button.checkBoxShowMine = checkBoxShowMine
            end
            button.checkBoxShowMine:SetChecked(button.npcData.showMine)
        end

        if button.checkBoxI then
            if button.checkBoxI:GetChecked() then
                SetImportantBoxColor(entryColors[1], entryColors[2], entryColors[3], entryColors[4])
                SetTextColor(entryColors[1], entryColors[2], entryColors[3], entryColors[4])
            else
                SetImportantBoxColor(0, 1, 0, 1)
                SetTextColor(1, 0.8196, 0, 1)
            end
        end

        if npc.id and not button.idTip then
            button:SetScript("OnEnter", function(self)
                if not button.npcData.id then return end
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:SetSpellByID(button.npcData.id)
                GameTooltip:AddLine("Spell ID: " .. button.npcData.id, 1, 1, 1)
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
            button.idTip = true
        end

        -- Update background colors
        updateBackgroundColors()

        return button
    end
    BBF["UpdateTextLine"..listName] = createOrUpdateTextLineButton

    local editBox = CreateFrame("EditBox", nil, subPanel, "InputBoxTemplate")
    editBox:SetSize((width and width - 62) or (322 - 62), 19)
    editBox:SetPoint("TOP", scrollFrame, "BOTTOM", -15, -5)
    editBox:SetAutoFocus(false)
    BBF[listName.."EditBox"] = editBox
    CreateTooltipTwo(editBox, "Filter auras by spell id and/or spell name", "You can click auras to add to lists.\n\n|cff00ff00To Whitelist:|r\nShift+Alt + LeftClick\n\n|cffff0000To Blacklist:|r\nShift+Alt + RightClick\nCtrl+Alt RightClick with \"Show Mine\" tag", nil, "ANCHOR_TOP")

    local function cleanUpEntry(entry)
        -- Iterate through each field in the entry
        for key, value in pairs(entry) do
            if value == false then
                entry[key] = nil
            end
        end
    end

    local function getSortedNpcList()
        local sortableNpcList = {}

        -- Iterate over the structure using pairs to access all entries
        for key, entry in pairs(listData) do
            cleanUpEntry(entry)
            -- Apply the search filter
            if BBF.currentSearchFilter == "" or (entry.name and entry.name:lower():match(BBF.currentSearchFilter)) or (entry.id and tostring(entry.id):match(BBF.currentSearchFilter)) then
                table.insert(sortableNpcList, entry)
            end
        end

        -- Sort the list alphabetically by the 'name' field, and then by 'id' if the names are the same
        table.sort(sortableNpcList, function(a, b)
            local nameA = a.name and a.name:lower() or ""
            local nameB = b.name and b.name:lower() or ""

            -- First, compare by name
            if nameA ~= nameB then
                return nameA < nameB
            end

            -- If names are the same, compare by id (sort low to high)
            local idA = a.id or math.huge
            local idB = b.id or math.huge
            return idA < idB
        end)

        return sortableNpcList
    end

    -- Function to update the list with batching logic
    local function refreshList()
        local sortedListData = getSortedNpcList()
        local totalEntries = #sortedListData
        local batchSize = 35  -- Number of entries to process per frame
        local currentIndex = 1

        local function processNextBatch()
            for i = currentIndex, math.min(currentIndex + batchSize - 1, totalEntries) do
                local npc = sortedListData[i]
                local button = createOrUpdateTextLineButton(npc, i, extraBoxes)
                textLines[i] = button
            end

            -- Hide any extra frames
            for i = totalEntries + 1, #framePool do
                if framePool[i] then
                    framePool[i]:Hide()
                end
            end

            -- Update the content frame height
            contentFrame:SetHeight(totalEntries * 20)
            updateBackgroundColors()

            -- Continue processing if there are more entries
            currentIndex = currentIndex + batchSize
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
            BBF.currentSearchFilter = searchText:lower()
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
    addButton:SetText("Add")
    addButton:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
    addButton:SetScript("OnClick", function()
        addOrUpdateEntry(editBox:GetText(), listName)
    end)
    scrollFrame:HookScript("OnShow", function()
        if BBF.auraWhitelistDelayedUpdate then
            BBF.auraWhitelistDelayedUpdate()
            --print("Ran delayed update WHITELIST, then set it to not run next time")
            BBF.auraWhitelistDelayedUpdate = nil
        end
        if BBF.auraBlacklistDelayedUpdate then
            BBF.auraBlacklistDelayedUpdate()
            --print("Ran delayed update BLACKLIST, then set it to not run next time")
            BBF.auraBlacklistDelayedUpdate = nil
        end
    end)
    return scrollFrame
end

SettingsPanel:HookScript("OnShow", function()
    if BBF.auraWhitelistDelayedUpdate then
        BBF.auraWhitelistDelayedUpdate()
        --print("Ran delayed update WHITELIST, then set it to not run next time")
        BBF.auraWhitelistDelayedUpdate = nil
    end
    if BBF.auraBlacklistDelayedUpdate then
        BBF.auraBlacklistDelayedUpdate()
        --print("Ran delayed update BLACKLIST, then set it to not run next time")
        BBF.auraBlacklistDelayedUpdate = nil
    end
end)

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

local function CreateSearchFrame()
    local searchFrame = CreateFrame("Frame", "BBFSearchFrame", UIParent)
    searchFrame:SetSize(680, 610)
    searchFrame:SetPoint("CENTER", UIParent, "CENTER")
    searchFrame:SetFrameStrata("HIGH")
    searchFrame:Hide()

    local wipText = searchFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    wipText:SetPoint("BOTTOM", searchFrame, "BOTTOM", -10, 10)
    wipText:SetText("Search is not complete and is WIP.")

    CreateTitle(searchFrame)

    local bgImg = searchFrame:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", searchFrame, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0, 0, 0)

    local settingsText = searchFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    settingsText:SetPoint("TOPLEFT", searchFrame, "TOPLEFT", 20, 0)
    settingsText:SetText("Search results:")

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
    CreateTooltipTwo(searchBox, "Search |A:shop-games-magnifyingglass:17:17|a", "You can now search for settings in BetterBlizzPlates. (WIP)", nil, "TOP")

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
                    resultCheckBox:SetSize(24, 24)
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
                    CreateTooltipTwo(resultCheckBox, "No data yet WIP", nil, nil, nil, nil, nil, data.checkbox.searchCategory)
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
                    CreateTooltipTwo(resultSlider, "No data yet WIP", nil, nil, nil, nil, nil, data.slider.searchCategory)
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
            SettingsPanel.SearchBox.Instructions:SetText("Search in BetterBlizzFrames")
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
            if SettingsPanel.SearchBox.Instructions:GetText() == "Search in BetterBlizzFrames" then
                SettingsPanel.SearchBox.Instructions:SetText("Search")
            end
            searchBox:Hide()
            searchFrame:Hide()
        end
    end)
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

    BetterBlizzFrames.searchName = "General"

    local bgImg = BetterBlizzFrames:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", BetterBlizzFrames, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local newSearch = BetterBlizzFrames:CreateTexture(nil, "BACKGROUND")
    newSearch:SetAtlas("NewCharacter-Horde", true)
    newSearch:SetPoint("BOTTOM", BetterBlizzFrames, "TOP", -70, 2)
    CreateTooltipTwo(newSearch, "Search |A:shop-games-magnifyingglass:17:17|a", "You can now search for settings in BetterBlizzFrames. (WIP)")

    local newSearchPoint = BetterBlizzFrames:CreateTexture(nil, "BACKGROUND")
    newSearchPoint:SetAtlas("auctionhouse-icon-buyallarrow", true)
    newSearchPoint:SetPoint("LEFT", newSearch, "RIGHT", -25, 0)
    newSearchPoint:SetRotation(math.pi / 2)

    CreateSearchFrame()
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


    if BetterBlizzFrames.titleText then
        BetterBlizzFrames.titleText:Hide()
        BetterBlizzFrames.loadGUI:Hide()
    end



    local hideArenaFrames = CreateCheckbox("hideArenaFrames", "Hide Arena Frames", BetterBlizzFrames, nil, BBF.HideArenaFrames)
    hideArenaFrames:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    hideArenaFrames:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    CreateTooltip(hideArenaFrames, "Hide the standard Blizzard Arena Frames.\nThis uses the same code as the addon\n\"Arena Anti-Malware\", also made by me.")

    local hideBossFrames = CreateCheckbox("hideBossFrames", "Hide Boss Frames", BetterBlizzFrames, nil, BBF.HideArenaFrames)
    hideBossFrames:SetPoint("TOPLEFT", hideArenaFrames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideBossFrames, "Hide the Blizzard Boss Frames that are underneath the minimap.")

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
    CreateTooltip(playerFrameOCD, "Removes small gap around player portrait, healthbars and manabars, etc.\nJust in general tiny OCD fixes on a few things. Requires a reload for full effect.\nTemporary setting I might remove if blizz fixes their stuff.")

    -- local playerFrameOCDTextureBypass = CreateCheckbox("playerFrameOCDTextureBypass", "OCD: Skip Bars", BetterBlizzFrames, nil, BBF.HideFrames)
    -- playerFrameOCDTextureBypass:SetPoint("LEFT", playerFrameOCD.text, "RIGHT", 0, 0)
    -- CreateTooltip(playerFrameOCDTextureBypass, "If healthbars & manabars look weird enable this to skip\nadjusting them and only fix portraits + reputation color")

    playerFrameOCD:HookScript("OnClick", function(self)
        BBF.AllNameChanges()
    end)

    -- if not BetterBlizzFramesDB.playerFrameOCD then
    --     playerFrameOCDTextureBypass:Disable()
    --     playerFrameOCDTextureBypass:SetAlpha(0)
    -- end

    local hideLossOfControlFrameBg = CreateCheckbox("hideLossOfControlFrameBg", "Hide CC Background", BetterBlizzFrames, nil, BBF.HideFrames)
    hideLossOfControlFrameBg:SetPoint("TOPLEFT", playerFrameOCD, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideLossOfControlFrameBg, "Hide the dark background on the LossOfControl frame (displaying CC on you)")
    hideLossOfControlFrameBg:HookScript("OnClick", function()
        BBF.ToggleLossOfControlTestMode()
    end)

    local hideLossOfControlFrameLines = CreateCheckbox("hideLossOfControlFrameLines", "Hide CC Red-lines", BetterBlizzFrames, nil, BBF.HideFrames)
    hideLossOfControlFrameLines:SetPoint("TOPLEFT", hideLossOfControlFrameBg, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideLossOfControlFrameLines, "Hide the red lines on top and bottom of the LossOfControl frame (displaying CC on you)")
    hideLossOfControlFrameLines:HookScript("OnClick", function()
        BBF.ToggleLossOfControlTestMode()
    end)

    local lossOfControlScale = CreateSlider(BetterBlizzFrames, "CC Scale", 0.4, 1.4, 0.01, "lossOfControlScale", nil, 90)
    lossOfControlScale:SetPoint("LEFT", hideLossOfControlFrameBg.text, "RIGHT", 3, -16)
    CreateTooltipTwo(lossOfControlScale, "Loss of Control Scale", "Adjust the scale of the LossOfControlFrame\n(displaying cc on you center screen)")

    local darkModeUi = CreateCheckbox("darkModeUi", "Dark Mode", BetterBlizzFrames)
    darkModeUi:SetPoint("TOPLEFT", hideLossOfControlFrameLines, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeUi:HookScript("OnClick", function()
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
    darkModeUiAura:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeUiAura, "Dark borders for Player, Target and Focus aura icons")

    local darkModeNameplateResource = CreateCheckbox("darkModeNameplateResource", "Nameplate Resource", darkModeUi)
    darkModeNameplateResource:SetPoint("TOPLEFT", darkModeUiAura, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeNameplateResource:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeNameplateResource, "Dark mode for nameplate resource (Combopoints etc)\n\n(If you are using this same feature in BBP\nthat one will be prioritized)")

    local darkModeGameTooltip = CreateCheckbox("darkModeGameTooltip", "Tooltip", darkModeUi)
    darkModeGameTooltip:SetPoint("TOPLEFT", darkModeMinimap, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeGameTooltip:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltipTwo(darkModeGameTooltip, "Dark Mode: Tooltip", "Dark mode for the Game Tooltip.")

    local darkModeObjectiveFrame = CreateCheckbox("darkModeObjectiveFrame", "Objectives", darkModeUi)
    darkModeObjectiveFrame:SetPoint("LEFT", darkModeGameTooltip.Text, "RIGHT", 5, 0)
    darkModeObjectiveFrame:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltipTwo(darkModeObjectiveFrame, "Dark Mode: Objectives", "Dark mode for Objectives/Quest Tracker")

    local darkModeVigor = CreateCheckbox("darkModeVigor", "Vigor", darkModeUi)
    darkModeVigor:SetPoint("LEFT", darkModeObjectiveFrame.Text, "RIGHT", 5, 0)
    darkModeVigor:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltipTwo(darkModeVigor, "Dark Mode: Vigor", "Dark mode for flying mount Vigor charges")

    local darkModeColor = CreateSlider(darkModeUi, "Darkness", 0, 1, 0.01, "darkModeColor", nil, 90)
    darkModeColor:SetPoint("LEFT", darkModeUiAura.text, "RIGHT", 3, -1)
    CreateTooltipTwo(darkModeColor, "Dark Mode Value", "Adjust how dark you want the dark mode to be.\nTip: You can rightclick all sliders to input a specific value.")

    darkModeUi:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(darkModeUi, 0)
    end)
    if not BetterBlizzFramesDB.darkModeUi then
        CheckAndToggleCheckboxes(darkModeUi, 0)
    end










    local playerFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playerFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -173)
    playerFrameText:SetText("Player Frame")
    local playerFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    playerFrameIcon:SetAtlas("groupfinder-icon-friend")
    playerFrameIcon:SetSize(28, 28)
    playerFrameIcon:SetPoint("RIGHT", playerFrameText, "LEFT", -3, 0)

    local playerFrameClickthrough = CreateCheckbox("playerFrameClickthrough", "Clickthrough", BetterBlizzFrames, nil, BBF.ClickthroughFrames)
    playerFrameClickthrough:SetPoint("TOPLEFT", playerFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltip(playerFrameClickthrough, "Makes the PlayerFrame clickthrough.\nYou can still hold shift to left/right click it\nwhile out of combat for trade/inspect etc.\n\nNOTE: You will NOT be able to click the frame\nat all during combat with this setting on.")

    local playerReputationColor = CreateCheckbox("playerReputationColor", "Add Reputation Color", BetterBlizzFrames, nil, BBF.PlayerReputationColor)
    playerReputationColor:SetPoint("TOPLEFT", playerFrameClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(playerReputationColor, "Add reputation color behind name like on Target & Focus.|A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a\nCan be class colored as well.")

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

    local hidePlayerName = CreateCheckbox("hidePlayerName", "Hide Name", BetterBlizzFrames, nil, BBF.UpdateNameSettings)
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

    local symmetricPlayerFrame = CreateCheckbox("symmetricPlayerFrame", "Mirror TargetFrame", BetterBlizzFrames, nil, BBF.SymmetricPlayerFrame)
    symmetricPlayerFrame:SetPoint("LEFT", hidePlayerName.text, "RIGHT", 0, 0)
    CreateTooltipTwo(symmetricPlayerFrame, "Mirror TargetFrame", "Make the PlayerFrame texture a mirrored version of TargetFrame (round circle etc).\n\n|cfffc8312EXPERIMENTAL:|r\nCan cause glitches/taint on certain updates (Vehicles/PvE/?).\nIf you decide to use this understand the potential risk and please report issues. (WIP)\n\n|cff32f795Toggle on/off with right-click.|r")
    -- symmetricPlayerFrame:HookScript("OnClick", function(self)
    --     if not self:GetChecked() then
    --         StaticPopup_Show("BBF_CONFIRM_RELOAD")
    --         BetterBlizzFramesDB.playerFrameOCD = nil
    --     end
    -- end)
    symmetricPlayerFrame:SetScript("OnClick", function(self)
        self:SetChecked(BetterBlizzFramesDB.symmetricPlayerFrame or false)
    end)

    symmetricPlayerFrame:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
            if BetterBlizzFramesDB.symmetricPlayerFrame then
                BetterBlizzFramesDB.symmetricPlayerFrame = nil
                symmetricPlayerFrame:SetChecked(false)
                return
            end
            symmetricPlayerFrame:SetChecked(true)
            BetterBlizzFramesDB.symmetricPlayerFrame = true
        end
    end)

    -- local hidePlayerMaxHpReduction = CreateCheckbox("hidePlayerMaxHpReduction", "Hide Reduced HP", BetterBlizzFrames, nil, BBF.HideFrames)
    -- hidePlayerMaxHpReduction:SetPoint("LEFT", hidePlayerName.text, "RIGHT", 0, 0)
    -- CreateTooltipTwo(hidePlayerMaxHpReduction, "Hide Reduced HP", "Hide the new max health loss indication introduced in TWW from PlayerFrame.")

    local hidePlayerPower = CreateCheckbox("hidePlayerPower", "Hide Resource/Power", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerPower:SetPoint("TOPLEFT", hidePlayerName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hidePlayerPower, "Hide Resource/Power", "Hide Resource/Power under PlayerFrame. Rogue combopoints, Warlock shards etc.\n\n|cff32f795Right-click for class specific options.|r")

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
            classOptionsFrame.title:SetText("Class Specific Options")

            local classes = {
                { class = "Druid", var = "hidePlayerPowerNoDruid", color = RAID_CLASS_COLORS["DRUID"] },
                { class = "Rogue", var = "hidePlayerPowerNoRogue", color = RAID_CLASS_COLORS["ROGUE"] },
                { class = "Warlock", var = "hidePlayerPowerNoWarlock", color = RAID_CLASS_COLORS["WARLOCK"] },
                { class = "Paladin", var = "hidePlayerPowerNoPaladin", color = RAID_CLASS_COLORS["PALADIN"] },
                { class = "Death Knight", var = "hidePlayerPowerNoDeathKnight", color = RAID_CLASS_COLORS["DEATHKNIGHT"] },
                { class = "Evoker", var = "hidePlayerPowerNoEvoker", color = RAID_CLASS_COLORS["EVOKER"] },
                { class = "Monk", var = "hidePlayerPowerNoMonk", color = RAID_CLASS_COLORS["MONK"] },
                { class = "Mage", var = "hidePlayerPowerNoMage", color = RAID_CLASS_COLORS["MAGE"] },
            }

            local previousCheckbox
            for i, classData in ipairs(classes) do
                local classCheckbox = CreateFrame("CheckButton", nil, classOptionsFrame, "UICheckButtonTemplate")
                classCheckbox:SetSize(24, 24)
                classCheckbox.Text:SetText("Ignore " .. classData.class)

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

    local hidePlayerRestAnimation = CreateCheckbox("hidePlayerRestAnimation", "Hide \"Zzz\" Rest Animation", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerRestAnimation:SetPoint("TOPLEFT", hidePlayerPower, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerRestAnimation, "Hide the \"Zzz\" animation on PlayerFrame while rested.")

    local hidePlayerRestGlow = CreateCheckbox("hidePlayerRestGlow", "Hide Rest Glow", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerRestGlow:SetPoint("TOPLEFT", hidePlayerRestAnimation, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerRestGlow, "Hide the flashing yellow rest glow animation around PlayerFrame while rested.|A:UI-HUD-UnitFrame-Player-PortraitOn-Status:30:80|a")

    local hidePlayerCornerIcon = CreateCheckbox("hidePlayerCornerIcon", "Hide Corner Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerCornerIcon:SetPoint("TOPLEFT", hidePlayerRestGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerCornerIcon, "Hide corner icon on PlayerFrame.|A:UI-HUD-UnitFrame-Player-PortraitOn-CornerEmbellishment:22:22|a\n")

    local hideCombatIcon = CreateCheckbox("hideCombatIcon", "Hide Combat Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hideCombatIcon:SetPoint("TOPLEFT", hidePlayerCornerIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideCombatIcon, "Hide combat icon on in the bottom right corner of the PlayerFrame.|A:UI-HUD-UnitFrame-Player-CombatIcon:22:22|a\n")

    local hideHitIndicator = CreateCheckbox("hideHitIndicator", "Hide Hit Indicator", BetterBlizzFrames, nil, BBF.HideFrames)
    hideHitIndicator:SetPoint("LEFT", hideCombatIcon.text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideHitIndicator, "Hide Hit Indicator", "Hide the Hit Indicator on PlayerFrame displaying damage/healing inc on Portrait.")

    local hideGroupIndicator = CreateCheckbox("hideGroupIndicator", "Hide Group Indicator", BetterBlizzFrames, nil, BBF.HideFrames)
    hideGroupIndicator:SetPoint("TOPLEFT", hideCombatIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideGroupIndicator, "Hide the group indicator on top of PlayerFrame\nwhile you are in a group.")

    local hideTotemFrame = CreateCheckbox("hideTotemFrame", "Hide Totem Frame", BetterBlizzFrames, nil, BBF.HideFrames)
    hideTotemFrame:SetPoint("LEFT", hideGroupIndicator.text, "RIGHT", 0, 0)
    CreateTooltip(hideTotemFrame, "Hide the TotemFrame under PlayerFrame.")

    local hidePlayerLeaderIcon = CreateCheckbox("hidePlayerLeaderIcon", "Hide Leader Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerLeaderIcon:SetPoint("TOPLEFT", hideGroupIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerLeaderIcon, "Hide the party leader icon from PlayerFrame.|A:UI-HUD-UnitFrame-Player-Group-LeaderIcon:22:22|a")

    local hidePlayerGuideIcon = CreateCheckbox("hidePlayerGuideIcon", "Hide Guide Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerGuideIcon:SetPoint("LEFT", hidePlayerLeaderIcon.text, "RIGHT", 0, 0)
    CreateTooltip(hidePlayerGuideIcon, "Hide the guide icon from PlayerFrame.|A:UI-HUD-UnitFrame-Player-Group-GuideIcon:22:22|a")

    local hidePlayerRoleIcon = CreateCheckbox("hidePlayerRoleIcon", "Hide Role Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerRoleIcon:SetPoint("TOPLEFT", hidePlayerLeaderIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerRoleIcon, "Hide the role icon from PlayerFrame|A:roleicon-tiny-dps:22:22|a")

    local hidePvpTimerText = CreateCheckbox("hidePvpTimerText", "Hide PvP Timer", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePvpTimerText:SetPoint("LEFT", hidePlayerRoleIcon.text, "RIGHT", 0, 0)
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

    local hidePetName = CreateCheckbox("hidePetName", "Hide Name", BetterBlizzFrames)
    hidePetName:SetPoint("TOPLEFT", petCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hidePetName:HookScript("OnClick", function (self)
        BBF.AllNameChanges()
    end)
    CreateTooltipTwo(hidePetName, "Hide Pet Name", "Hide the pet name on PetFrame")

    local colorPetAfterOwner = CreateCheckbox("colorPetAfterOwner", "Color Pet After Player Class", BetterBlizzFrames)
    colorPetAfterOwner:SetPoint("TOPLEFT", hidePetName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    colorPetAfterOwner:HookScript("OnClick", function (self)
        BBF.UpdateFrames()
    end)

    local hidePetText = CreateCheckbox("hidePetText", "Hide Pet Statusbar Text", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePetText:SetPoint("TOPLEFT", colorPetAfterOwner, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hidePetText, "Hide Pet Statusbar Text", "Hide the health and mana text on PetFrame.")

    local partyFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    partyFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -417)
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

    local hidePartyRoles = CreateCheckbox("hidePartyRoles", "Hide Role Icons", BetterBlizzFrames)
    hidePartyRoles:SetPoint("LEFT", showPartyCastbar.text, "RIGHT", 0, 0)
    hidePartyRoles:HookScript("OnClick", function()
        BBF.PartyNameChange()
    end)
    CreateTooltip(hidePartyRoles, "Hide the role icons from party frame|A:roleicon-tiny-dps:22:22|a|A:spec-role-dps:22:22|a")

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

    local hidePartyNames = CreateCheckbox("hidePartyNames", "Hide Names", BetterBlizzFrames)
    hidePartyNames:SetPoint("TOPLEFT", hidePartyFramesInArena, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hidePartyNames:HookScript("OnClick", function(self)
        BBF.AllNameChanges()
    end)

    local hidePartyAggroHighlight = CreateCheckbox("hidePartyAggroHighlight", "Hide Aggro Highlight", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePartyAggroHighlight:SetPoint("LEFT", hidePartyNames.text, "RIGHT", 0, 0)
    CreateTooltip(hidePartyAggroHighlight, "Hide the Aggro Highlight border around each party frame.")

    -- local hidePartyMaxHpReduction = CreateCheckbox("hidePartyMaxHpReduction", "Hide Reduced HP", BetterBlizzFrames, nil, BBF.HideFrames)
    -- hidePartyMaxHpReduction:SetPoint("LEFT", hidePartyRoles.text, "RIGHT", 0, 0)
    -- CreateTooltipTwo(hidePartyMaxHpReduction, "Hide Reduced HP", "Hide the new max health loss indication introduced in TWW from party frames.")

    local hidePartyFrameTitle = CreateCheckbox("hidePartyFrameTitle", "Hide CompactPartyFrame Title", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePartyFrameTitle:SetPoint("TOPLEFT", hidePartyNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePartyFrameTitle, "Hide the \"Party\" text above \"Raid-Style\" Party Frames.")

    local hideRaidFrameManager = CreateCheckbox("hideRaidFrameManager", "Hide RaidFrameManager", BetterBlizzFrames, nil, BBF.HideFrames)
    hideRaidFrameManager:SetPoint("TOPLEFT", hidePartyFrameTitle, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideRaidFrameManager, "Hide the CompactRaidFrameManager. Can still be shown with mouseover.")

    local partyFrameScale = CreateSlider(BetterBlizzFrames, "Party Frame Scale", 0.7, 1.7, 0.01, "partyFrameScale", nil, 120)
    partyFrameScale:SetPoint("TOPLEFT", hideRaidFrameManager, "BOTTOMLEFT", 15, -13)









    local targetFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 250, -173)
    targetFrameText:SetText("Target Frame")
    local targetFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    targetFrameIcon:SetAtlas("groupfinder-icon-friend")
    targetFrameIcon:SetSize(28, 28)
    targetFrameIcon:SetPoint("RIGHT", targetFrameText, "LEFT", -3, 0)
    targetFrameIcon:SetDesaturated(1)
    targetFrameIcon:SetVertexColor(1, 0, 0)

    local targetFrameClickthrough = CreateCheckbox("targetFrameClickthrough", "Clickthrough", BetterBlizzFrames, nil, BBF.ClickthroughFrames)
    targetFrameClickthrough:SetPoint("TOPLEFT", targetFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltip(targetFrameClickthrough, "Makes the TargetFrame clickthrough.\nYou can still hold shift to left/right click it\nwhile out of combat for trade/inspect etc.\n\nNOTE: You will NOT be able to click the frame\nat all during combat with this setting on.")

    local hideTargetName = CreateCheckbox("hideTargetName", "Hide Name", BetterBlizzFrames, nil, BBF.UpdateNameSettings)
    hideTargetName:SetPoint("TOPLEFT", targetFrameClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetName, "Hide the name of the target\n\nWill still show arena names if enabled.")
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
    -- CreateTooltipTwo(hideTargetMaxHpReduction, "Hide Reduced HP", "Hide the new max health loss indication introduced in TWW from TargetFrame.")

    local hideTargetLeaderIcon = CreateCheckbox("hideTargetLeaderIcon", "Hide Leader Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hideTargetLeaderIcon:SetPoint("TOPLEFT", hideTargetName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetLeaderIcon, "Hide the party leader icon from Target.|A:UI-HUD-UnitFrame-Player-Group-LeaderIcon:22:22|a")

    local classColorTargetReputationTexture = CreateCheckbox("classColorTargetReputationTexture", "Reputation Class Color", BetterBlizzFrames)
    classColorTargetReputationTexture:SetPoint("TOPLEFT", hideTargetLeaderIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classColorTargetReputationTexture, "Use class colors instead of the reputation color for Target. |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")
    classColorTargetReputationTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBF.ClassColorReputation(TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, "target")
        else
            BBF.ResetClassColorReputation(TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, "target")
        end
    end)

    local hideTargetReputationColor = CreateCheckbox("hideTargetReputationColor", "Hide Reputation Color", BetterBlizzFrames, nil, BBF.HideFrames)
    hideTargetReputationColor:SetPoint("TOPLEFT", classColorTargetReputationTexture, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetReputationColor, "Hide the color behind Target name. |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")






    local targetToTFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetToTFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 250, -298)
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

    local hideTargetToTDebuffs = CreateCheckbox("hideTargetToTDebuffs", "Hide ToT Debuffs", BetterBlizzFrames, nil, BBF.HideFrames)
    hideTargetToTDebuffs:SetPoint("TOPLEFT", hideTargetToT, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetToTDebuffs, "Hide the 4 small debuff icons to the right of ToT frame.")

    local targetToTScale = CreateSlider(BetterBlizzFrames, "Size", 0.6, 2.5, 0.01, "targetToTScale", nil, 120)
    targetToTScale:SetPoint("TOPLEFT", targetToTFrameText, "BOTTOMLEFT", 0, -55)
    CreateTooltip(targetToTScale, "Target of target size.\n\nYou can right-click sliders to enter a specific value.")

    BBF.targetToTXPos = CreateSlider(BetterBlizzFrames, "x offset", -100, 100, 1, "targetToTXPos", "X", 120)
    BBF.targetToTXPos:SetPoint("TOP", targetToTScale, "BOTTOM", 0, -15)
    CreateTooltip(BBF.targetToTXPos, "Target of target x offset.\n\nYou can right-click sliders to enter a specific value.")

    local targetToTYPos = CreateSlider(BetterBlizzFrames, "y offset", -100, 100, 1, "targetToTYPos", "Y", 120)
    targetToTYPos:SetPoint("TOP", BBF.targetToTXPos, "BOTTOM", 0, -15)
    CreateTooltip(targetToTYPos, "Target of target y offset.\n\nYou can right-click sliders to enter a specific value.")




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

    local filterNpcArenaSpam = CreateCheckbox("filterNpcArenaSpam", "Arena Npc Talk", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterNpcArenaSpam:SetPoint("LEFT", filterGladiusSpam.text, "RIGHT", 0, 0)
    CreateTooltip(filterNpcArenaSpam, "Filter out npc chat messages like \"Get in there and fight, stop hiding!\"\nfrom chat during arena.")

    local filterTalentSpam = CreateCheckbox("filterTalentSpam", "Talent Spam", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterTalentSpam:SetPoint("TOPLEFT", filterGladiusSpam, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(filterTalentSpam, "Filter out \"You have learned/unlearned\" spam from chat.\nEspecially annoying during respec.")

    local filterEmoteSpam = CreateCheckbox("filterEmoteSpam", "Emote Spam", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterEmoteSpam:SetPoint("TOPLEFT", filterTalentSpam, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(filterEmoteSpam, "Filter out \"yells at his/her team members.\" and\n\"makes some strange gestures.\" from chat.")

    local filterSystemMessages = CreateCheckbox("filterSystemMessages", "System Messages", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterSystemMessages:SetPoint("TOPLEFT", filterNpcArenaSpam, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(filterSystemMessages, "Filter out a few excessive system messages. Some examples:\n\"You have joined the queue for Arena Skirmish\"\n\"Your group has been disbanded.\"\n\"You have been awarded x currency\"\n\"You are in both a party and an instance group.\"\n\nFull lists in modules\\chatFrame.lua")

    local filterMiscInfo = CreateCheckbox("filterMiscInfo", "Misc Info", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterMiscInfo:SetPoint("TOPLEFT", filterSystemMessages, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(filterMiscInfo, "Filter out \"Your equipped items suffer a durability loss\" message.")

    local arenaNamesText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arenaNamesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, -91)
    arenaNamesText:SetText("Arena Names")
    CreateTooltip(arenaNamesText, "Change player names into spec/arena id instead during arena", "ANCHOR_LEFT")
    local arenaNamesIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    arenaNamesIcon:SetAtlas("questbonusobjective")
    arenaNamesIcon:SetSize(24, 24)
    arenaNamesIcon:SetPoint("RIGHT", arenaNamesText, "LEFT", -3, 0)

    local targetAndFocusArenaNames = CreateCheckbox("targetAndFocusArenaNames", "Target & Focus", BetterBlizzFrames)
    targetAndFocusArenaNames:SetPoint("TOPLEFT", arenaNamesText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltipTwo(targetAndFocusArenaNames, "Arena Names","Change Target & Focus name to arena ID and/or spec name during arena.", nil, "ANCHOR_LEFT")

    local partyArenaNames = CreateCheckbox("partyArenaNames", "Party", BetterBlizzFrames)
    partyArenaNames:SetPoint("LEFT", targetAndFocusArenaNames.text, "RIGHT", 0, 0)
    CreateTooltipTwo(partyArenaNames, "Arena Names", "Change party frame names to party ID and/or spec name during arena", nil, "ANCHOR_LEFT")

    local showSpecName = CreateCheckbox("showSpecName", "Show Spec Name", BetterBlizzFrames)
    showSpecName:SetPoint("TOPLEFT", targetAndFocusArenaNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showSpecName, "Show Spec Name", "Show spec name instead of player names.\n\nIf both spec name and arena id is selected it will display as for instance \"Fury 3\".\n\n|cff32f795Right-click to change whether Party units should have spec names or not.\nShow spec for Party units: "..(BetterBlizzFramesDB.targetAndFocusArenaNamePartyOverride and "True" or "|cffff0000False|r").."|r")
    showSpecName:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if BetterBlizzFramesDB.targetAndFocusArenaNamePartyOverride then
                BetterBlizzFramesDB.targetAndFocusArenaNamePartyOverride = false
            else
                BetterBlizzFramesDB.targetAndFocusArenaNamePartyOverride = true
            end
            local value = (BetterBlizzFramesDB.targetAndFocusArenaNamePartyOverride and "True" or "|cffff0000False|r")
            local showSpecNameTip = "Show spec name instead of player names.\n\nIf both spec name and arena id is selected it will display as for instance \"Fury 3\".\n\n|cff32f795Right-click to change whether Party units should have spec names or not.\nShow spec for Party units: "..value.."|r"
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine("Show Spec Name")
            GameTooltip:AddLine(showSpecNameTip, 1, 1, 1, true)
            GameTooltip:Show()
            CreateTooltipTwo(showSpecName, "Show Spec Name", "Show spec name instead of player names.\n\nIf both spec name and arena id is selected it will display as for instance \"Fury 3\".\n\n|cff32f795Right-click to change whether Party units should have spec names or not.\nShow spec for Party units: "..(BetterBlizzFramesDB.targetAndFocusArenaNamePartyOverride and "True" or "|cffff0000False|r").."|r")
            BBF.AllNameChanges()
        end
    end)

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
    focusFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, -173)
    focusFrameText:SetText("Focus Frame")
    local focusFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    focusFrameIcon:SetAtlas("groupfinder-icon-friend")
    focusFrameIcon:SetSize(28, 28)
    focusFrameIcon:SetPoint("RIGHT", focusFrameText, "LEFT", -3, 0)
    focusFrameIcon:SetDesaturated(1)
    focusFrameIcon:SetVertexColor(0, 1, 0)

    local focusFrameClickthrough = CreateCheckbox("focusFrameClickthrough", "Clickthrough", BetterBlizzFrames, nil, BBF.ClickthroughFrames)
    focusFrameClickthrough:SetPoint("TOPLEFT", focusFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltip(focusFrameClickthrough, "Makes the FocusFrame clickthrough.\nYou can still hold shift to left/right click it\nwhile out of combat for trade/inspect etc.\n\nNOTE: You will NOT be able to click the frame\nat all during combat with this setting on.")

    local hideFocusName = CreateCheckbox("hideFocusName", "Hide Name", BetterBlizzFrames, nil, BBF.UpdateNameSettings)
    hideFocusName:SetPoint("TOPLEFT", focusFrameClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideFocusName, "Hide the name of the focus\n\nWill still show arena names if enabled.")
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
    -- CreateTooltipTwo(hideFocusMaxHpReduction, "Hide Reduced HP", "Hide the new max health loss indication introduced in TWW from FocusFrame.")

    local hideFocusLeaderIcon = CreateCheckbox("hideFocusLeaderIcon", "Hide Leader Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hideFocusLeaderIcon:SetPoint("TOPLEFT", hideFocusName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideFocusLeaderIcon, "Hide the party leader icon from Focus.|A:UI-HUD-UnitFrame-Player-Group-LeaderIcon:22:22|a")

    local classColorFocusReputationTexture = CreateCheckbox("classColorFocusReputationTexture", "Reputation Class Color", BetterBlizzFrames)
    classColorFocusReputationTexture:SetPoint("TOPLEFT", hideFocusLeaderIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classColorFocusReputationTexture, "Use class colors instead of the reputation color for Focus. |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")
    classColorFocusReputationTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBF.ClassColorReputation(FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, "focus")
        else
            BBF.ResetClassColorReputation(FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, "focus")
        end
    end)

    local hideFocusReputationColor = CreateCheckbox("hideFocusReputationColor", "Hide Reputation Color", BetterBlizzFrames, nil, BBF.HideFrames)
    hideFocusReputationColor:SetPoint("TOPLEFT", classColorFocusReputationTexture, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideFocusReputationColor, "Hide the color behind Focus name. |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")







    local focusToTFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    focusToTFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, -298)
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

    local hideFocusToTDebuffs = CreateCheckbox("hideFocusToTDebuffs", "Hide FocusToT Debuffs", BetterBlizzFrames, nil, BBF.HideFrames)
    hideFocusToTDebuffs:SetPoint("TOPLEFT", hideFocusToT, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideFocusToTDebuffs, "Hide the 4 small debuff icons to the right of ToT frame.")

    local focusToTScale = CreateSlider(BetterBlizzFrames, "Size", 0.6, 2.5, 0.01, "focusToTScale", nil, 120)
    focusToTScale:SetPoint("TOPLEFT", focusToTFrameText, "BOTTOMLEFT", 0, -55)
    CreateTooltip(focusToTScale, "Focus target of target size.\n\nYou can right-click sliders to enter a specific value.")

    BBF.focusToTXPos = CreateSlider(BetterBlizzFrames, "x offset", -100, 100, 1, "focusToTXPos", "X", 120)
    BBF.focusToTXPos:SetPoint("TOP", focusToTScale, "BOTTOM", 0, -15)
    CreateTooltip(BBF.focusToTXPos, "Focus target of target x offset.\n\nYou can right-click sliders to enter a specific value.")

    local focusToTYPos = CreateSlider(BetterBlizzFrames, "y offset", -100, 100, 1, "focusToTYPos", "Y", 120)
    focusToTYPos:SetPoint("TOP", BBF.focusToTXPos, "BOTTOM", 0, -15)
    CreateTooltip(focusToTYPos, "Focus target of target y offset.\n\nYou can right-click sliders to enter a specific value.")





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
        BBF.UpdateFrames()
        if self:GetChecked() then
            PlayerFrame.healthbar:SetStatusBarDesaturated(false)
            PlayerFrame.healthbar:SetStatusBarColor(1, 1, 1)
        else
            BBF.updateFrameColorToggleVer(PlayerFrame.healthbar, "player")
            if CfPlayerFrameHealthBar then
                BBF.updateFrameColorToggleVer(CfPlayerFrameHealthBar, "player")
            end
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

    local classColorTargetNames = CreateCheckbox("classColorTargetNames", "Class Color Names", BetterBlizzFrames)
    classColorTargetNames:SetPoint("TOPLEFT", classColorFrames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classColorTargetNames, "Class Color Names","Class color Player, Target & Focus Names.", nil)

    local classColorLevelText = CreateCheckbox("classColorLevelText", "Level", classColorTargetNames)
    classColorLevelText:SetPoint("LEFT", classColorTargetNames.text, "RIGHT", 0, 0)
    CreateTooltip(classColorLevelText, "Also class color the level text.")

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

    local centerNames = CreateCheckbox("centerNames", "Center Name", BetterBlizzFrames, nil, BBF.SetCenteredNamesCaller)
    centerNames:SetPoint("TOPLEFT", classColorTargetNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(centerNames, "Center Names", "Center the name on Player, Target & Focus frames.", nil)
    centerNames:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local removeRealmNames = CreateCheckbox("removeRealmNames", "Hide Realm", BetterBlizzFrames)
    removeRealmNames:SetPoint("LEFT", centerNames.text, "RIGHT", 0, 0)
    CreateTooltipTwo(removeRealmNames, "Hide Realm Indicator", "Hide realm name and different realm indicator \"(*)\" from Target, Focus & Party frames.", nil)

    local formatStatusBarText = CreateCheckbox("formatStatusBarText", "Format Numbers", BetterBlizzFrames, nil, BBF.HookStatusBarText)
    formatStatusBarText:SetPoint("TOPLEFT", centerNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(formatStatusBarText, "Format Numbers", "Format the health & mana numbers on Player, Target & Focus frames to be millions instead of thousands.\n\n6800 K |A:glueannouncementpopup-arrow:20:20|a 6.8 M", "Requires reload.")

    local singleValueStatusBarText = CreateCheckbox("singleValueStatusBarText", "No Max", formatStatusBarText)
    singleValueStatusBarText:SetPoint("LEFT", formatStatusBarText.text, "RIGHT", 0, 0)
    CreateTooltipTwo(singleValueStatusBarText, "No Max Value", "If Numeric Value is selected as Status Text this setting will make it only display current HP instead of max HP as well.\n\n6800 K / 6800 K |A:glueannouncementpopup-arrow:20:20|a 6.8 M", "Requires reload.")
    singleValueStatusBarText:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    formatStatusBarText:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
        CheckAndToggleCheckboxes(self)
    end)

    local hidePrestigeBadge = CreateCheckbox("hidePrestigeBadge", "Hide Prestige Badge", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePrestigeBadge:SetPoint("TOPLEFT", formatStatusBarText, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePrestigeBadge, "Hide the Prestige/Honor level icon from Player, Target & Focus frames. |A:honorsystem-portrait-alliance:40:42|a |A:honorsystem-portrait-horde:40:42|a |A:honorsystem-portrait-neutral:40:42|a")

    local hideCombatGlow = CreateCheckbox("hideCombatGlow", "Hide Combat Glow", BetterBlizzFrames, nil, BBF.HideFrames)
    hideCombatGlow:SetPoint("TOPLEFT", hidePrestigeBadge, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideCombatGlow, "Hide the red combat around Player, Target & Focus.|A:UI-HUD-UnitFrame-Player-PortraitOn-InCombat:30:80|a")

    local hideLevelText = CreateCheckbox("hideLevelText", "Hide Level 80 Text", BetterBlizzFrames, nil, BBF.HideFrames)
    hideLevelText:SetPoint("TOPLEFT", hideCombatGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideLevelText, "Hide the level text for Player, Target & Focus frames if they are level 80")

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

    local hideUnitFrameShadow = CreateCheckbox("hideUnitFrameShadow", "Hide Shadow", BetterBlizzFrames, nil, BBF.HideFrames)
    hideUnitFrameShadow:SetPoint("LEFT", hidePvpIcon.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideUnitFrameShadow, "Hide Shadow", "Hide shadow texture behind name on Player, Target & Focus frames.\n\n(Target/Focus Reputation Color shows in front of this as well, maybe disable those as well)")
    hideUnitFrameShadow:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local hideRareDragonTexture = CreateCheckbox("hideRareDragonTexture", "Hide Dragon", BetterBlizzFrames, nil, BBF.HideFrames)
    hideRareDragonTexture:SetPoint("TOPLEFT", hidePvpIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideRareDragonTexture, "Hide Elite Dragon texture on Target & Focus|A:UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold:38:28|a")

    local hideThreatOnFrame = CreateCheckbox("hideThreatOnFrame", "Hide Threat", BetterBlizzFrames, nil, BBF.HideFrames)
    hideThreatOnFrame:SetPoint("LEFT", hideRareDragonTexture.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideThreatOnFrame, "Hide Threat Meter", "Hide the threat meter displaying on Target & Focus frames.")

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
    CreateTooltipTwo(combatIndicator, "Combat Indicator", "Show combat status on Player, Target and Focus Frame.\nSword icon for combat, Sap icon for no combat.\nMore settings in \"Advanced Settings\"", nil, nil, nil, 1)

    local absorbIndicator = CreateCheckbox("absorbIndicator", "Absorb Indicator", BetterBlizzFrames, nil, BBF.AbsorbCaller)
    absorbIndicator:SetPoint("TOPLEFT", combatIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    absorbIndicator:HookScript("OnClick", function()
        BBF.AbsorbCaller()
    end)
    CreateTooltipTwo(absorbIndicator, "Absorb Indicator", "Show absorb amount on Player, Target and Focus Frame\nMore settings in \"Advanced Settings\"", nil, nil, nil, 1)

    local racialIndicator = CreateCheckbox("racialIndicator", "PvP Racial Indicator", BetterBlizzFrames, nil, BBF.RacialIndicatorCaller)
    racialIndicator:SetPoint("TOPLEFT", absorbIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    racialIndicator:HookScript("OnClick", function()
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltipTwo(racialIndicator, "Racial Indicator", "Show important PvP racial icons on Target/Focus Frame", nil, nil, nil, 1)

    local overShields = CreateCheckbox("overShields", "Overshields", BetterBlizzFrames)
    overShields:SetPoint("TOPLEFT", racialIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(overShields, "Overshields", "Expand on Blizzards unit frame absorb texture and\nshow shield amount on frames regardless if HP is full or not", nil, "ANCHOR_LEFT", nil, 2)

    local overShieldsUnitFrames = CreateCheckbox("overShieldsUnitFrames", "A", BetterBlizzFrames)
    overShieldsUnitFrames:SetPoint("LEFT", overShields.text, "RIGHT", 0, 0)
    CreateTooltipTwo(overShieldsUnitFrames, "UnitFrame Overshields", "Show Overshields on UnitFrames (Player, Target, Focus)", nil, "ANCHOR_LEFT", nil, 1)
    overShieldsUnitFrames:HookScript("OnClick", function(self)
        BBF.HookOverShields()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local overShieldsCompactUnitFrames = CreateCheckbox("overShieldsCompactUnitFrames", "B", BetterBlizzFrames)
    overShieldsCompactUnitFrames:SetPoint("LEFT", overShieldsUnitFrames.text, "RIGHT", 0, 0)
    CreateTooltipTwo(overShieldsCompactUnitFrames, "Compact-UnitFrames Overshields", "Show Overshields on Compact UnitFrames (Party, Raid)", nil, "ANCHOR_LEFT", nil, 2)
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

    local queueTimer = CreateCheckbox("queueTimer", "Queue Timer", BetterBlizzFrames)
    queueTimer:SetPoint("TOPLEFT", overShields, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(queueTimer, "Queue Timer", "Displays the remaining time to accept when a queue pops.", nil, "ANCHOR_LEFT")

    local queueTimerAudio = CreateCheckbox("queueTimerAudio", "SFX", queueTimer)
    queueTimerAudio:SetPoint("LEFT", queueTimer.text, "RIGHT", 0, 0)
    CreateTooltipTwo(queueTimerAudio, "Sound Effect", "Play an alarm sound when queue pops.", "(Plays with game sounds muted)\n\nNote that \"Enable Sound\" needs to be on in the audio settings but you can disable the subcategories: Sound Effects, Ambience, Dialog and Music.", "ANCHOR_LEFT")

    local queueTimerWarning = CreateCheckbox("queueTimerWarning", "!", queueTimer)
    queueTimerWarning:SetPoint("LEFT", queueTimerAudio.text, "RIGHT", 0, 0)
    CreateTooltipTwo(queueTimerWarning, "Sound Alert!", "Warning sound if there is less than 6 seconds left to accept the queue.", "(Plays with game sounds muted.)\n\nNote that \"Enable Sound\" needs to be on in the audio settings but you can disable the subcategories: Sound Effects, Ambience, Dialog and Music.", "ANCHOR_LEFT")

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



    local btnGap = 5
    local starterButton = CreateClassButton(BetterBlizzFrames, "STARTER", "Starter", nil, function()
        ShowProfileConfirmation("Starter", "STARTER", BBF.StarterProfile, "|cff808080(If you want to completely reset BBF there\nis a button in Advanced Settings)|r\n\n")
    end)
    starterButton:SetPoint("TOPLEFT", SettingsPanel, "BOTTOMLEFT", 258, 38)

    local aeghisButton = CreateClassButton(BetterBlizzFrames, "MAGE", "Aeghis", "aeghis", function()
        ShowProfileConfirmation("Aeghis", "MAGE", BBF.AeghisProfile)
    end)
    aeghisButton:SetPoint("LEFT", starterButton, "RIGHT", btnGap, 0)

    local kalvishButton = CreateClassButton(BetterBlizzFrames, "ROGUE", "Kalvish", "kalvish", function()
        ShowProfileConfirmation("Kalvish", "ROGUE", BBF.KalvishProfile)
    end)
    kalvishButton:SetPoint("LEFT", aeghisButton, "RIGHT", btnGap, 0)

    local magnuszButton = CreateClassButton(BetterBlizzFrames, "WARRIOR", "Magnusz", "magnusz", function()
        ShowProfileConfirmation("Magnusz", "WARRIOR", BBF.MagnuszProfile)
    end)
    magnuszButton:SetPoint("LEFT", kalvishButton, "RIGHT", btnGap, 0)

    local nahjButton = CreateClassButton(BetterBlizzFrames, "ROGUE", "Nahj", "nahj", function()
        ShowProfileConfirmation("Nahj", "ROGUE", BBF.NahjProfile)
    end)
    nahjButton:SetPoint("LEFT", magnuszButton, "RIGHT", btnGap, 0)

    local snupyButton = CreateClassButton(BetterBlizzFrames, "DRUID", "Snupy", "snupy", function()
        ShowProfileConfirmation("Snupy", "DRUID", BBF.SnupyProfile)
    end)
    snupyButton:SetPoint("LEFT", nahjButton, "RIGHT", btnGap, 0)




    ----------------------
    -- Reload etc
    ----------------------
    local reloadUiButton = CreateFrame("Button", nil, BetterBlizzFrames, "UIPanelButtonTemplate")
    reloadUiButton:SetText("Reload UI")
    reloadUiButton:SetWidth(96)
    reloadUiButton:SetPoint("RIGHT", SettingsPanel.CloseButton, "LEFT", -3, 0)
    reloadUiButton:SetScript("OnClick", function()
        BetterBlizzFramesDB.reopenOptions = true
        ReloadUI()
    end)

    if not SettingsPanel.CloseButton.origPoint then
        SettingsPanel.CloseButton.origPoint, SettingsPanel.CloseButton.origRel, SettingsPanel.CloseButton.origAnchor, SettingsPanel.CloseButton.origX, SettingsPanel.CloseButton.origY = SettingsPanel.CloseButton:GetPoint()
    end
    SettingsPanel.CloseButton:ClearAllPoints()
    SettingsPanel.CloseButton:SetPoint("TOPRIGHT", BetterBlizzFrames, "BOTTOMRIGHT", 6, -41)
    BetterBlizzFrames:HookScript("OnShow", function()
        SettingsPanel.CloseButton:ClearAllPoints()
        SettingsPanel.CloseButton:SetPoint("TOPRIGHT", BetterBlizzFrames, "BOTTOMRIGHT", 6, -41)
    end)
    BetterBlizzFrames:HookScript("OnHide", function()
        if BetterBlizzPlates and BetterBlizzPlates:IsShown() then return end
        SettingsPanel.CloseButton:ClearAllPoints()
        SettingsPanel.CloseButton:SetPoint(SettingsPanel.CloseButton.origPoint, SettingsPanel.CloseButton.origRel, SettingsPanel.CloseButton.origAnchor, SettingsPanel.CloseButton.origX, SettingsPanel.CloseButton.origY)
    end)
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
    anchorSubPartyCastbar:SetText("Party Castbars")

    local partyCastbarBorder = CreateBorderedFrame(anchorSubPartyCastbar, 157, 386, 0, -145, contentFrame)

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

    anchorSubPartyCastbar.classicCastbarsParty = CreateCheckbox("classicCastbarsParty", "Classic Castbars", contentFrame, nil, BBF.partyCastBarTestMode)
    anchorSubPartyCastbar.classicCastbarsParty:SetPoint("TOPLEFT", showPartyCastBarIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(anchorSubPartyCastbar.classicCastbarsParty, "Classic Castbars", "Use classic style castbars for party castbars.")

    anchorSubPartyCastbar.classicCastbarsParty:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

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
    anchorSubTargetCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, firstLineY)
    anchorSubTargetCastbar:SetText("Target Castbar")

    local targetCastbarBorder = CreateBorderedFrame(anchorSubTargetCastbar, 157, 386, 0, -145, contentFrame)

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
    CreateTooltipTwo(targetToTCastbarAdjustment, "Enable ToT Offset", "Makes sure the castbar is under Target ToT frame until enough auras are displayed to push it down.\nUncheck this if you have moved your ToT frame out of the way and want to have the castbar follow the bottom of the auras no matter what")

    local targetToTAdjustmentOffsetY = CreateSlider(targetToTCastbarAdjustment, "extra", -20, 50, 1, "targetToTAdjustmentOffsetY", "Y", 55)
    targetToTAdjustmentOffsetY:SetPoint("LEFT", targetToTCastbarAdjustment.text, "RIGHT", 2, -5)
    CreateTooltipTwo(targetToTAdjustmentOffsetY, "Extra Finetuning for ToT Offset", "Finetune the space between castbar and auras when ToT is showing. This extra offset is only active when the ToT frame is showing.")

    targetToTCastbarAdjustment:HookScript("OnClick", function(self)
        if self:GetChecked() then
            targetToTAdjustmentOffsetY:Enable()
            targetToTAdjustmentOffsetY:SetAlpha(1)
        else
            targetToTAdjustmentOffsetY:Disable()
            targetToTAdjustmentOffsetY:SetAlpha(0.5)
        end
    end)

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
        BBF.ChangeCastbarSizes()
    end)
    CreateTooltip(targetDetachCastbar, "Detach castbar from frame and enable wider xy positioning.\nRight-click a slider to enter a specific number.")

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
        targetToTCastbarAdjustment:Enable()
        targetToTCastbarAdjustment:SetAlpha(1)
        targetToTCastbarAdjustment:SetChecked(true)
        targetToTAdjustmentOffsetY:Enable()
        targetToTAdjustmentOffsetY:SetValue(0)
        BetterBlizzFramesDB.targetToTCastbarAdjustment = true
        BBF.CastBarTimerCaller()
        BBF.ChangeCastbarSizes()
    end)


    ----------------------
    -- Pet Castbars
    ----------------------
    local anchorSubPetCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPetCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, secondLineY + 5)
    anchorSubPetCastbar:SetText("Pet Castbar")

    local petCastbarBorder = CreateBorderedFrame(anchorSubPetCastbar, 157, 320, 0, -112, contentFrame)

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
        BBF.ChangeCastbarSizes()
    end)
    CreateTooltip(petDetachCastbar, "Detach castbar from frame and enable wider xy positioning.\nRight-click a slider to enter a specific number.")

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
    anchorSubFocusCastbar:SetText("Focus Castbar")

    local focusCastbarBorder = CreateBorderedFrame(anchorSubFocusCastbar, 157, 386, 0, -145, contentFrame)

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
    CreateTooltipTwo(focusToTCastbarAdjustment, "Enable ToT Offset", "Makes sure the castbar is under Focus ToT frame until enough auras are displayed to push it down.\nUncheck this if you have moved your ToT frame out of the way and want to have the castbar follow the bottom of the auras no matter what.")

    local focusToTAdjustmentOffsetY = CreateSlider(focusToTCastbarAdjustment, "extra", -20, 50, 1, "focusToTAdjustmentOffsetY", "Y", 55)
    focusToTAdjustmentOffsetY:SetPoint("LEFT", focusToTCastbarAdjustment.text, "RIGHT", 2, -5)
    CreateTooltipTwo(focusToTAdjustmentOffsetY, "Extra Finetuning for ToT Offset", "Finetune the space between castbar and auras when ToT is showing. This extra offset is only active when the ToT frame is showing.")

    focusToTCastbarAdjustment:HookScript("OnClick", function(self)
        if self:GetChecked() then
            focusToTAdjustmentOffsetY:Enable()
            focusToTAdjustmentOffsetY:SetAlpha(1)
        else
            focusToTAdjustmentOffsetY:Disable()
            focusToTAdjustmentOffsetY:SetAlpha(0.5)
        end
    end)

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
        BBF.ChangeCastbarSizes()
    end)
    CreateTooltip(focusDetachCastbar, "Detach castbar from frame and enable wider xy positioning.\nRight-click a slider to enter a specific number.")

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
        focusToTCastbarAdjustment:Enable()
        focusToTCastbarAdjustment:SetAlpha(1)
        focusToTCastbarAdjustment:SetChecked(true)
        focusToTAdjustmentOffsetY:Enable()
        focusToTAdjustmentOffsetY:SetValue(0)
        BetterBlizzFramesDB.focusToTCastbarAdjustment = true
        BBF.CastBarTimerCaller()
        BBF.ChangeCastbarSizes()
    end)


   ----------------------
    -- Player Castbar
    ----------------------
    local anchorSubPlayerCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPlayerCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, firstLineY)
    anchorSubPlayerCastbar:SetText("Player Castbar")

    local playerCastbarBorder = CreateBorderedFrame(anchorSubPlayerCastbar, 157, 250, 0, -77, contentFrame)

    local playerCastBar = contentFrame:CreateTexture(nil, "ARTWORK")
    playerCastBar:SetAtlas("ui-castingbar-filling-standard")
    playerCastBar:SetSize(110, 13)
    playerCastBar:SetPoint("BOTTOM", anchorSubPlayerCastbar, "TOP", -1, 10)


    local playerCastBarScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "playerCastBarScale")
    playerCastBarScale:SetPoint("TOP", anchorSubPlayerCastbar, "BOTTOM", 0, -15)
--[[
    local playerCastBarXPos = CreateSlider(contentFrame, "x offset", -200, 200, 1, "playerCastBarXPos")
    playerCastBarXPos:SetPoint("TOP", playerCastBarScale, "BOTTOM", 0, -15)

    local playerCastBarYPos = CreateSlider(contentFrame, "y offset", -200, 200, 1, "playerCastBarYPos")
    playerCastBarYPos:SetPoint("TOP", playerCastBarXPos, "BOTTOM", 0, -15)

]]

    local playerCastBarIconScale = CreateSlider(contentFrame, "Icon Size", 0.4, 2, 0.01, "playerCastBarIconScale")
    playerCastBarIconScale:SetPoint("TOP", playerCastBarScale, "BOTTOM", 0, -15)

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

    local classicCastbarsPlayer = CreateCheckbox("classicCastbarsPlayer", "Classic Castbar", contentFrame, nil, BBF.ChangeCastbarSizes)
    classicCastbarsPlayer:SetPoint("TOPLEFT", playerCastBarTimerCentered, "BOTTOMLEFT", -15, pixelsBetweenBoxes)
    CreateTooltipTwo(classicCastbarsPlayer, "Classic Castbar", "Use Classic layout for Player Castbar")

    local classicCastbarsPlayerBorder = CreateCheckbox("classicCastbarsPlayerBorder", "Border", classicCastbarsPlayer, nil, BBF.ChangeCastbarSizes)
    classicCastbarsPlayerBorder:SetPoint("LEFT", classicCastbarsPlayer.text, "RIGHT", 0, 0)
    CreateTooltipTwo(classicCastbarsPlayerBorder, "Classic Border", "Use the default Player Classic Castbar Boder")

    classicCastbarsPlayer:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
    end)

    local resetPlayerCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetPlayerCastbar:SetText("Reset")
    resetPlayerCastbar:SetWidth(70)
    resetPlayerCastbar:SetPoint("TOP", playerCastbarBorder, "BOTTOM", 0, -2)
    resetPlayerCastbar:SetScript("OnClick", function()
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
            if BetterBlizzPlatesDB.castBarInterruptHighlighterColorDontInterrupt then
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
    castBarRecolorInterrupt:SetPoint("LEFT", contentFrame, "TOPRIGHT", -435, -460)
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
    buffsOnTopReverseCastbarMovement:SetPoint("LEFT", contentFrame, "TOPRIGHT", -470, -540)
    CreateTooltipTwo(buffsOnTopReverseCastbarMovement, "Buffs on Top: Reverse Castbar Movement", "Changes the castbar movement to follow the top row of auras on Target/Focus Frame similar to how it works by default without \"Buffs on Top\" enabled except in reverse.\n\nBy default with Buffs on Top enabled your castbar will just sit beneath the target frame and not move.")

    local normalCastbarForEmpoweredCasts = CreateCheckbox("normalCastbarForEmpoweredCasts", "Normal Evoker Empowered Castbar", contentFrame, nil, BBF.HookCastbarsForEvoker)
    normalCastbarForEmpoweredCasts:SetPoint("TOPLEFT", buffsOnTopReverseCastbarMovement, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(normalCastbarForEmpoweredCasts, "Normal Evoker Castbar", "Change Evoker empowered castbars to look like normal ones.\n(Easier to see if you can interrupt)")
    normalCastbarForEmpoweredCasts:HookScript("OnClick", function(self)
        if BetterBlizzPlatesDB then
            if self:GetChecked() then
                BetterBlizzPlatesDB.normalCastbarForEmpoweredCasts = true
            else
                BetterBlizzPlatesDB.normalCastbarForEmpoweredCasts = false
            end
        end
    end)

    local quickHideCastbars = CreateCheckbox("quickHideCastbars", "Quick Hide Castbars", contentFrame)
    quickHideCastbars:SetPoint("TOPLEFT", normalCastbarForEmpoweredCasts, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(quickHideCastbars, "Quick Hide Castbars", "Instantly hide target and focus castbars after their cast is finished or interrupted.\nBy default there is a slow fade out animation.")
    quickHideCastbars:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local classicCastbars = CreateCheckbox("classicCastbars", "Classic Castbars", contentFrame, nil, BBF.ChangeCastbarSizes)
    classicCastbars:SetPoint("TOPLEFT", quickHideCastbars, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classicCastbars, "Classic Castbars", "Use Classic layout for Target & Focus castbars")
    classicCastbars:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
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
    playerCombatIndicator:SetPoint("TOPLEFT", combatIndicatorShowSap, "BOTTOMLEFT", -5, -10)
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

    local racialIndicatorDwarf = CreateCheckbox("racialIndicatorDwarf", "Dwarf", contentFrame)
    racialIndicatorDwarf:SetPoint("TOPLEFT", racialIndicatorHuman, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    racialIndicatorDwarf:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorDwarf, "Show for Dwarf")

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

    local racialIndicatorDarkIronDwarf = CreateCheckbox("racialIndicatorDarkIronDwarf", "D.I.Dwarf", contentFrame)
    racialIndicatorDarkIronDwarf:SetPoint("TOPLEFT", racialIndicatorUndead, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    racialIndicatorDarkIronDwarf:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorDarkIronDwarf, "Show for Dark Iron Dwarf")

    local targetRacialIndicator = CreateCheckbox("targetRacialIndicator", "Target", contentFrame)
    targetRacialIndicator:SetPoint("TOPLEFT", racialIndicatorDwarf, "BOTTOMLEFT", 0, -10)
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

    local racialIndicatorRaceIcons = CreateCheckbox("racialIndicatorRaceIcons", "Race Icon", contentFrame)
    racialIndicatorRaceIcons:SetPoint("TOPLEFT", targetRacialIndicator, "BOTTOMLEFT", 12, pixelsBetweenBoxes)
    racialIndicatorRaceIcons:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorRaceIcons, "Show race icon instead of the racial spell icon")

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

    local resetBBFButton = CreateFrame("Button", nil, BetterBlizzFramesSubPanel, "UIPanelButtonTemplate")
    resetBBFButton:SetText("Reset BetterBlizzFrames")
    resetBBFButton:SetWidth(165)
    resetBBFButton:SetPoint("RIGHT", reloadUiButton2, "LEFT", -533, 0)
    resetBBFButton:SetScript("OnClick", function()
        StaticPopup_Show("CONFIRM_RESET_BETTERBLIZZFRAMESDB")
    end)
    CreateTooltip(resetBBFButton, "Reset ALL BetterBlizzFrames settings.")

end

local function guiFrameLook()
    ----------------------
    -- Frame Auras
    ----------------------
    local guiFrameLook = CreateFrame("Frame")
    guiFrameLook.name = "Font & Texture"
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

    local mainGuiAnchor = guiFrameLook:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor:SetPoint("TOPLEFT", 15, -15)
    mainGuiAnchor:SetText(" ")

    local settingsText = guiFrameLook:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, 30)
    settingsText:SetText("Font & Texture (WIP)")
    local generalSettingsIcon = guiFrameLook:CreateTexture(nil, "ARTWORK")
    generalSettingsIcon:SetAtlas("optionsicon-brown")
    generalSettingsIcon:SetSize(22, 22)
    generalSettingsIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)

    local changeUnitFrameFont = CreateCheckbox("changeUnitFrameFont", "Change UnitFrame Font", guiFrameLook)
    changeUnitFrameFont:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltipTwo(changeUnitFrameFont, "Change UnitFrame Font","Changes the font on Player, Target & Focus etc.")

    local unitFrameFont = CreateFontDropdown(
        "unitFrameFont",
        guiFrameLook,
        "Select Font",
        "unitFrameFont",
        function(arg1)
            BBF.SetCustomFonts()
        end,
        { anchorFrame = changeUnitFrameFont, x = 55, y = 1, label = "Font" }
    )

    -- For font outline
    local unitFrameFontOutline = CreateSimpleDropdown("FontOutlineDropdown", guiFrameLook, "Outline", "unitFrameFontOutline", {
        "THICKOUTLINE", "THINOUTLINE", "NONE"
    }, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = unitFrameFont, x = 0, y = -5 }, 155)

    -- For font size
    local fontSizeOptions = {}
    for i = 6, 24 do
        table.insert(fontSizeOptions, tostring(i))
    end

    local unitFrameFontSize = CreateSimpleDropdown("FontSizeDropdown", guiFrameLook, "Size", "unitFrameFontSize", fontSizeOptions, function(selectedSize)
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





    local changeUnitFrameValueFont = CreateCheckbox("changeUnitFrameValueFont", "Change UnitFrame Number Font", guiFrameLook)
    changeUnitFrameValueFont:SetPoint("TOPLEFT", changeUnitFrameFont, "BOTTOMLEFT", 0, -85)
    CreateTooltipTwo(changeUnitFrameValueFont, "Change UnitFrame Number Font","Changes the font on numbers on Player, Target & Focus etc.")

    local unitFrameValueFont = CreateFontDropdown(
        "unitFrameValueFont",
        guiFrameLook,
        "Select Font",
        "unitFrameValueFont",
        function(arg1)
            BBF.SetCustomFonts()
        end,
        { anchorFrame = changeUnitFrameValueFont, x = 55, y = 1, label = "Font" }
    )

    -- For font outline
    local unitFrameValueFontOutline = CreateSimpleDropdown("FontOutlineDropdown", guiFrameLook, "Outline", "unitFrameValueFontOutline", {
        "THICKOUTLINE", "THINOUTLINE", "NONE"
    }, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = unitFrameValueFont, x = 0, y = -5 }, 155)

    local unitFrameValueFontSize = CreateSimpleDropdown("FontSizeDropdown", guiFrameLook, "Size", "unitFrameValueFontSize", fontSizeOptions, function(selectedSize)
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





    local changePartyFrameFont = CreateCheckbox("changePartyFrameFont", "Change Party Font", guiFrameLook)
    changePartyFrameFont:SetPoint("TOPLEFT", changeUnitFrameValueFont, "BOTTOMLEFT", 0, -85)
    CreateTooltipTwo(changePartyFrameFont, "Change Party Font","Changes the font on PartyFrames")

    local partyFrameFont = CreateFontDropdown(
        "partyFrameFont",
        guiFrameLook,
        "Select Font",
        "partyFrameFont",
        function(arg1)
            BBF.SetCustomFonts()
        end,
        { anchorFrame = changePartyFrameFont, x = 55, y = 1, label = "Font" }
    )

    -- For font outline
    local partyFrameFontOutline = CreateSimpleDropdown("FontOutlineDropdown", guiFrameLook, "Outline", "partyFrameFontOutline", {
        "THICKOUTLINE", "THINOUTLINE", "NONE"
    }, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = partyFrameFont, x = 0, y = -5 }, 155)

    local partyFrameFontSize = CreateSimpleDropdown("FontSizeDropdown", guiFrameLook, "Size", "partyFrameFontSize", fontSizeOptions, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = partyFrameFontOutline, x = 0, y = -5 }, 77.5)
    CreateTooltipTwo(partyFrameFontSize, "Name Size")

    local partyFrameStatusFontSize = CreateSimpleDropdown("FontSizeDropdown", guiFrameLook, "", "partyFrameStatusFontSize", fontSizeOptions, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = partyFrameFontSize, x = 77.5, y = 25 }, 77.5)
    CreateTooltipTwo(partyFrameStatusFontSize, "Status Text Size")

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


    local changeActionBarFont = CreateCheckbox("changeActionBarFont", "Change ActionBar Font", guiFrameLook)
    changeActionBarFont:SetPoint("TOPLEFT", changePartyFrameFont, "BOTTOMLEFT", 0, -85)
    CreateTooltipTwo(changeActionBarFont, "Change ActionBar Font","Changes the font on Player, Target & Focus etc.")

    local actionBarFont = CreateFontDropdown(
        "actionBarFont",
        guiFrameLook,
        "Select Font",
        "actionBarFont",
        function(arg1)
            BBF.SetCustomFonts()
        end,
        { anchorFrame = changeActionBarFont, x = 55, y = 1, label = "Font" }
    )

    -- For font outline
    local actionBarFontOutline = CreateSimpleDropdown("FontOutlineDropdown", guiFrameLook, "Outline", "actionBarFontOutline", {
        "THICKOUTLINE", "THINOUTLINE", "NONE"
    }, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = actionBarFont, x = 0, y = -5 }, 77.5)
    CreateTooltipTwo(actionBarFontOutline, "Macro Text Outline")

    local actionBarKeyFontOutline = CreateSimpleDropdown("FontOutlineDropdown", guiFrameLook, "", "actionBarKeyFontOutline", {
        "THICKOUTLINE", "THINOUTLINE", "NONE"
    }, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = actionBarFontOutline, x = 77.5, y = 25 }, 77.5)
    CreateTooltipTwo(actionBarKeyFontOutline, "Keybinding Text Outline")

    local actionBarFontSize = CreateSimpleDropdown("FontSizeDropdown", guiFrameLook, "Size", "actionBarFontSize", fontSizeOptions, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = actionBarFontOutline, x = 0, y = -5 }, 77.5)
    CreateTooltipTwo(actionBarFontSize, "Macro Text Size")

    local actionBarKeyFontSize = CreateSimpleDropdown("FontSizeDropdown", guiFrameLook, "", "actionBarKeyFontSize", fontSizeOptions, function(selectedSize)
        BBF.SetCustomFonts()
    end, { anchorFrame = actionBarFontSize, x = 77.5, y = 25 }, 77.5)
    CreateTooltipTwo(actionBarKeyFontSize, "Keybinding Text Size")



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
    end

    changeActionBarFont:HookScript("OnClick", function(self)
        BBF.SetCustomFonts()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
        ToggleDropdowns(self:GetChecked())
    end)

    ToggleDropdowns(changeActionBarFont:GetChecked())










    local changeAllFontsIngame = CreateCheckbox("changeAllFontsIngame", "One font for all text ingame", guiFrameLook)
    changeAllFontsIngame:SetPoint("TOPLEFT", changeActionBarFont, "BOTTOMLEFT", 0, -125)
    CreateTooltipTwo(changeAllFontsIngame, "One font for all text ingame","Changes the font on all* text ingame.", "*Some text in the game world, like damage numbers, can not be changed with an addon. It's possible by editing the game files though.")

    local allIngameFont = CreateFontDropdown(
        "allIngameFont",
        guiFrameLook,
        "Select Font",
        "allIngameFont",
        function(arg1)
            BBF.SetCustomFonts()
        end,
        { anchorFrame = changeAllFontsIngame, x = 55, y = 1, label = "Font" }
    )

    changeAllFontsIngame:HookScript("OnClick", function(self)
        BBF.SetCustomFonts()
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
        allIngameFont:SetEnabled(self:GetChecked())
    end)
    allIngameFont:SetEnabled(changeAllFontsIngame:GetChecked())







    local changeUnitFrameHealthbarTexture = CreateCheckbox("changeUnitFrameHealthbarTexture", "Change UnitFrame Healthbar Texture", guiFrameLook)
    changeUnitFrameHealthbarTexture:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", 260, pixelsOnFirstBox)
    CreateTooltipTwo(changeUnitFrameHealthbarTexture, "Change UnitFrame Healthbar Texture","Changes the healthbar texture on Player, Target & Focus etc.")

    local unitFrameHealthbarTexture = CreateTextureDropdown(
        "unitFrameHealthbarTexture",
        guiFrameLook,
        "Select Texture",
        "unitFrameHealthbarTexture",
        function(arg1)
            BBF.UpdateCustomTextures()
        end,
        { anchorFrame = changeUnitFrameHealthbarTexture, x = 5, y = 1, label = "Texture" }
    )

    changeUnitFrameHealthbarTexture:HookScript("OnClick", function(self)
        unitFrameHealthbarTexture:SetEnabled(self:GetChecked())
        BBF.UpdateCustomTextures()
    end)
    unitFrameHealthbarTexture:SetEnabled(changeUnitFrameHealthbarTexture:GetChecked())

    local changeUnitFrameManabarTexture = CreateCheckbox("changeUnitFrameManabarTexture", "Change UnitFrame Manabar Texture", guiFrameLook)
    changeUnitFrameManabarTexture:SetPoint("TOPLEFT", changeUnitFrameHealthbarTexture, "BOTTOMLEFT", 0, -25)
    CreateTooltipTwo(changeUnitFrameManabarTexture, "Change UnitFrame Manabar Texture","Changes the manabar texture on Player, Target & Focus etc. This is more cpu heavy than it should be.")

    local unitFrameManabarTexture = CreateTextureDropdown(
        "unitFrameManabarTexture",
        guiFrameLook,
        "Select Texture",
        "unitFrameManabarTexture",
        function(arg1)
            BBF.UpdateCustomTextures()
        end,
        { anchorFrame = changeUnitFrameManabarTexture, x = 5, y = 1, label = "Texture" }
    )
    changeUnitFrameManabarTexture:HookScript("OnClick", function(self)
        unitFrameManabarTexture:SetEnabled(self:GetChecked())
        BBF.UpdateCustomTextures()
    end)
    unitFrameManabarTexture:SetEnabled(changeUnitFrameManabarTexture:GetChecked())


    local changeRaidFrameHealthbarTexture = CreateCheckbox("changeRaidFrameHealthbarTexture", "Change RaidFrame Healthbar Texture", guiFrameLook)
    changeRaidFrameHealthbarTexture:SetPoint("TOPLEFT", changeUnitFrameManabarTexture, "BOTTOMLEFT", 0, -25)
    CreateTooltipTwo(changeRaidFrameHealthbarTexture, "Change RaidFrame Healthbar Texture","Changes the healthbar texture on the RaidFrames")

    local raidFrameHealthbarTexture = CreateTextureDropdown(
        "raidFrameHealthbarTexture",
        guiFrameLook,
        "Select Texture",
        "raidFrameHealthbarTexture",
        function(arg1)
            BBF.UpdateCustomTextures()
        end,
        { anchorFrame = changeRaidFrameHealthbarTexture, x = 5, y = 1, label = "Texture" }
    )

    changeRaidFrameHealthbarTexture:HookScript("OnClick", function(self)
        raidFrameHealthbarTexture:SetEnabled(self:GetChecked())
        BBF.UpdateCustomTextures()
    end)
    raidFrameHealthbarTexture:SetEnabled(changeRaidFrameHealthbarTexture:GetChecked())

    local changeRaidFrameManabarTexture = CreateCheckbox("changeRaidFrameManabarTexture", "Change RaidFrame Manabar Texture", guiFrameLook)
    changeRaidFrameManabarTexture:SetPoint("TOPLEFT", changeRaidFrameHealthbarTexture, "BOTTOMLEFT", 0, -25)
    CreateTooltipTwo(changeRaidFrameManabarTexture, "Change RaidFrame Manabar Texture","Changes the manabar texture on the RaidFrames. This is more cpu heavy than it should be.")

    local raidFrameManabarTexture = CreateTextureDropdown(
        "raidFrameManabarTexture",
        guiFrameLook,
        "Select Texture",
        "raidFrameManabarTexture",
        function(arg1)
            BBF.UpdateCustomTextures()
        end,
        { anchorFrame = changeRaidFrameManabarTexture, x = 5, y = 1, label = "Texture" }
    )

    changeRaidFrameManabarTexture:HookScript("OnClick", function(self)
        raidFrameManabarTexture:SetEnabled(self:GetChecked())
        BBF.UpdateCustomTextures()
    end)
    raidFrameManabarTexture:SetEnabled(changeRaidFrameManabarTexture:GetChecked())














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
    contentFrame.name = guiFrameAuras.name
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

    if not BetterBlizzFramesDB.playerAuraFiltering then
        auraWhitelistFrame:SetAlpha(0.3)
        auraBlacklistFrame:SetAlpha(0.3)
    end

    local onlyMeTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    onlyMeTexture:SetAtlas("UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon")
    onlyMeTexture:SetPoint("RIGHT", whitelist, "TOPRIGHT", 296, 9)
    onlyMeTexture:SetSize(18,20)
    CreateTooltip(onlyMeTexture, "Only My Aura Checkboxes")

    local enlargeAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    enlargeAuraTexture:SetAtlas("ui-hud-minimap-zoom-in")
    enlargeAuraTexture:SetPoint("LEFT", onlyMeTexture, "RIGHT", 4, 0)
    enlargeAuraTexture:SetSize(18,18)
    CreateTooltip(enlargeAuraTexture, "Enlarged Aura Checkboxes")

    local compactAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    compactAuraTexture:SetAtlas("ui-hud-minimap-zoom-out")
    compactAuraTexture:SetPoint("LEFT", enlargeAuraTexture, "RIGHT", 3, 0)
    compactAuraTexture:SetSize(18,18)
    CreateTooltip(compactAuraTexture, "Compact Aura Checkboxes")

    local importantAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    importantAuraTexture:SetAtlas("importantavailablequesticon")
    importantAuraTexture:SetPoint("LEFT", compactAuraTexture, "RIGHT", 2, 0)
    importantAuraTexture:SetSize(17,16)
    importantAuraTexture:SetDesaturated(true)
    importantAuraTexture:SetVertexColor(0,1,0)
    CreateTooltip(importantAuraTexture, "Important Aura Checkboxes")

    local pandemicAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    pandemicAuraTexture:SetAtlas("elementalstorm-boss-air")
    pandemicAuraTexture:SetPoint("LEFT", importantAuraTexture, "RIGHT", -1, 1)
    pandemicAuraTexture:SetSize(26,26)
    pandemicAuraTexture:SetDesaturated(true)
    pandemicAuraTexture:SetVertexColor(1,0,0)
    CreateTooltip(pandemicAuraTexture, "Pandemic Aura Checkboxes")






    local playerAuraFiltering = CreateCheckbox("playerAuraFiltering", "Enable Aura Settings", contentFrame)
    playerAuraFiltering.name = guiFrameAuras.name
    CreateTooltipTwo(playerAuraFiltering, "Enable Buff Filtering & Aura settings", "Enables all the buff filtering settings.\nThis setting is cpu heavy and un-optimized so use at your own risk.", nil, nil, nil, 5)
    playerAuraFiltering:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 50, 190)
    playerAuraFiltering:HookScript("OnClick", function (self)
        if self:GetChecked() then
            if BetterBlizzFramesDB.targetToTXPos == 0 then
                StaticPopup_Show("BBF_TOT_MESSAGE")
                BetterBlizzFramesDB.targetToTXPos = 31
                BBF.targetToTXPos:SetValue(31)
                BetterBlizzFramesDB.focusToTXPos = 31
                BBF.focusToTXPos:SetValue(31)
                BBF.MoveToTFrames()
                BBF.UpdateFilteredBuffsIcon()
            else
                StaticPopup_Show("BBF_CONFIRM_RELOAD")
            end
            auraWhitelistFrame:SetAlpha(1)
            auraBlacklistFrame:SetAlpha(1)
        else
            if BetterBlizzFramesDB.targetToTXPos == 31 then
                DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: Aura Settings Off. Target of Target Frame changed back to its default position.")
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
    end)

    local enableMasque = CreateCheckbox("enableMasque", "Add Masque Support", contentFrame)
    enableMasque:SetPoint("LEFT", playerAuraFiltering.Text, "RIGHT", 5, 0)
    CreateTooltipTwo(enableMasque, "Enable Masque Support for Auras", "Add Masque support for all auras.\nHigh CPU usage, not recommended. Might try optimize in the future.", "Does not require Aura Settings to be enabled.", nil, nil, 4)
    enableMasque:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local printAuraSpellIds = CreateCheckbox("printAuraSpellIds", "Print Spell ID", playerAuraFiltering)
    printAuraSpellIds:SetPoint("LEFT", enableMasque.Text, "RIGHT", 5, 0)
    CreateTooltip(printAuraSpellIds, "Show aura spell id in chat when mousing over the aura.\n\nUsecase: Find spell ID to filter by ID, some spells have identical names.")

    local importPVPWhitelist = CreateFrame("Button", nil, playerAuraFiltering, "UIPanelButtonTemplate")
    importPVPWhitelist:SetSize(138, 22)
    importPVPWhitelist:SetPoint("LEFT", printAuraSpellIds.text, "RIGHT", 3, 1)
    importPVPWhitelist:SetText("Import PvP Whitelist")
    importPVPWhitelist:SetScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_PVP_WHITELIST")
    end)
    local coloredText = "|cff00FF00Important/Immunity|r\n" ..
                    "|cffFF8000Offensive Buff|r\n" ..
                    "|cffFFA9F1Defensive Buffs|r\n" ..
                    "|cff00FFFFFreedom/Speed|r\n" ..
                    "|cffEFFF33Fear Immunity|r"

    CreateTooltipTwo(importPVPWhitelist, "Import PvP Whitelist", "Import a color coded Whitelist with most important Offensives, Defensives & Freedoms for TWW added.\n\n"..coloredText.."\n\nThis will only add NEW entries and not mess with existing ones in your current whitelist.\n\nWill tweak this as time goes on probably.")
    importPVPWhitelist.Middle:SetDesaturated(true)
    importPVPWhitelist.Left:SetDesaturated(true)
    importPVPWhitelist.Right:SetDesaturated(true)

    local importPVPBlacklist = CreateFrame("Button", nil, playerAuraFiltering, "UIPanelButtonTemplate")
    importPVPBlacklist:SetSize(138, 22)
    importPVPBlacklist:SetPoint("LEFT", importPVPWhitelist, "RIGHT", 0, 0)
    importPVPBlacklist:SetText("Import PvP Blacklist")
    importPVPBlacklist:SetScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_PVP_BLACKLIST")
    end)
    CreateTooltipTwo(importPVPBlacklist, "Import PvP Blacklist", "Import a Blacklist with A LOT (750+) of trash buffs blacklisted.\n\nThis will only add NEW entries and not mess with existing ones already in your blacklist.")
    importPVPBlacklist.Middle:SetDesaturated(true)
    importPVPBlacklist.Left:SetDesaturated(true)
    importPVPBlacklist.Right:SetDesaturated(true)

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
        TargetFrame:UpdateAuras()
        if BBF.HidingAllTargetAuras then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
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
        if BBF.HidingAllTargetAuras then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local targetdeBuffFilterBlizzard = CreateCheckbox("targetdeBuffFilterBlizzard", "Blizzard Default Filter", targetdeBuffEnable)
    targetdeBuffFilterBlizzard:SetPoint("TOPLEFT", targetdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

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
        if BBF.HidingAllFocusAuras then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
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
        if BBF.HidingAllFocusAuras then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local focusdeBuffFilterBlizzard = CreateCheckbox("focusdeBuffFilterBlizzard", "Blizzard Default Filter", focusdeBuffEnable)
    focusdeBuffFilterBlizzard:SetPoint("TOPLEFT", focusdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

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
    enablePlayerBuffFiltering:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(enablePlayerBuffFiltering)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local PlayerAuraFrameBuffEnable = CreateCheckbox("PlayerAuraFrameBuffEnable", "Show BUFFS", enablePlayerBuffFiltering)
    PlayerAuraFrameBuffEnable:SetPoint("TOPLEFT", enablePlayerBuffFiltering, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    PlayerAuraFrameBuffEnable:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(PlayerAuraFrameBuffEnable)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    CreateTooltipTwo(PlayerAuraFrameBuffEnable, "Show Player Buffs", "Show Player Buffs (Top Right)", "If disabled all filtering will be skipped and instead just hide the BuffFrame entirely.")

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
    enablePlayerDebuffFiltering:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(enablePlayerDebuffFiltering)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    CreateTooltip(enablePlayerDebuffFiltering, "Enables Debuff Filtering.\nThis boy is a bit too heavy to run for my liking so I've turned it off by default.\nUntil I manage to optimize it use at your own risk.\n(It's probably fine, I'm just too cautious)")

    local PlayerAuraFramedeBuffEnable = CreateCheckbox("PlayerAuraFramedeBuffEnable", "Show DEBUFFS", enablePlayerDebuffFiltering)
    PlayerAuraFramedeBuffEnable:SetPoint("TOPLEFT", enablePlayerDebuffFiltering, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    PlayerAuraFramedeBuffEnable:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(PlayerAuraFramedeBuffEnable)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    CreateTooltipTwo(PlayerAuraFramedeBuffEnable, "Show Player Debuffs", "Show Player Debuffs (Top Right)", "If disabled all filtering will be skipped and instead just hide the DebuffFrame entirely.")

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

    local enlargedAuraSize = CreateSlider(playerAuraFiltering, "Enlarged Aura Scale", 1, 2, 0.01, "enlargedAuraSize")
    enlargedAuraSize:SetPoint("TOP", targetAndFocusSmallAuraScale, "BOTTOM", 0, -20)
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



    local playerAuraSpacingX = CreateSlider(playerAuraFiltering, "Horizontal Padding", 0, 10, 1, "playerAuraSpacingX", "X")
    playerAuraSpacingX:SetPoint("TOP", PlayerAuraBorder, "BOTTOM", 0, -35)
    CreateTooltip(playerAuraSpacingX, "Horizontal padding for aura icons.\nAllows you to set gap to 0 (Blizz limit is 5 in EditMode).", "ANCHOR_LEFT")

    local playerAuraSpacingY = CreateSlider(playerAuraFiltering, "Vertical Padding", -10, 10, 1, "playerAuraSpacingY", "Y")
    playerAuraSpacingY:SetPoint("TOP", playerAuraSpacingX, "BOTTOM", 0, -15)

    local useEditMode = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    useEditMode:SetPoint("TOP", PlayerAuraBorder, "BOTTOM", 0, -90)
    useEditMode:SetText("Use Edit Mode for other settings.")

    local moreAuraSettings = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    moreAuraSettings:SetPoint("TOP", PlayerAuraBorder, "BOTTOM", -100, -125)
    moreAuraSettings:SetText("More Aura Settings:")

    local displayDispelGlowAlways = CreateCheckbox("displayDispelGlowAlways", "Always show purge texture", playerAuraFiltering)
    displayDispelGlowAlways:SetPoint("TOPLEFT", moreAuraSettings, "BOTTOMLEFT", -10, -3)
    CreateTooltip(displayDispelGlowAlways, "Always display the purge/steal texture on auras\nregardless if you have a dispel/purge/steal ability or not.")

    local changePurgeTextureColor = CreateCheckbox("changePurgeTextureColor", "Change Purge Texture Color", playerAuraFiltering)
    changePurgeTextureColor:SetPoint("TOPLEFT", displayDispelGlowAlways, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(changePurgeTextureColor, "Change Purge Texture Color")

    local showPurgeTextureOnSelf = CreateCheckbox("showPurgeTextureOnSelf", "Show Purge Texture on Player Auras", playerAuraFiltering)
    showPurgeTextureOnSelf:SetPoint("TOPLEFT", changePurgeTextureColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(showPurgeTextureOnSelf, "Show Purge Texture on Player Auras", "Show Purge Texture on Player Auras (Top Right).")

    local onlyPandemicAuraMine = CreateCheckbox("onlyPandemicAuraMine", "Only Pandemic Mine", playerAuraFiltering)
    onlyPandemicAuraMine:SetPoint("TOPLEFT", showPurgeTextureOnSelf, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(onlyPandemicAuraMine, "Only show the red pandemic aura glow on my own auras", "ANCHOR_LEFT")

    local increaseAuraStrata = CreateCheckbox("increaseAuraStrata", "Increase Aura Frame Strata", playerAuraFiltering)
    increaseAuraStrata:SetPoint("TOPLEFT", onlyPandemicAuraMine, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(increaseAuraStrata, "Increase Aura Frame Strata", "Increase the strata of auras in order to make them appear above the Target & ToT Frames so they are not covered.")

    local clickthroughAuras = CreateCheckbox("clickthroughAuras", "Clickthrough Auras", playerAuraFiltering)
    clickthroughAuras:SetPoint("TOPLEFT", increaseAuraStrata, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(clickthroughAuras, "Clickthrough Auras", "Makes auras on target and focus frame clickthrough. This setting will make it so clicking auras to add to whitelist & blacklist is no longer possible.")
    clickthroughAuras:HookScript("OnClick", function(self)
        if self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local auraImportantDispelIcon = CreateCheckbox("auraImportantDispelIcon", "Important Glow: Dispel Icon", playerAuraFiltering)
    auraImportantDispelIcon:SetPoint("TOPLEFT", clickthroughAuras, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(auraImportantDispelIcon, "Important Glow: Dispel Icon", "If an aura is marked as Important and has a glow, this setting adds a blue exclamation mark in the bottom left corner if the aura is dispellable.\n\nSince the Important Glow hides the default dispellable glow, this helps you quickly see if an aura can be dispelled (especially for auras that have both dispellable and non-dispellable versions).")

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

    local dispelGlowButton = CreateFrame("Button", nil, playerAuraFiltering, "UIPanelButtonTemplate")
    dispelGlowButton:SetText("Color")
    dispelGlowButton:SetPoint("LEFT", changePurgeTextureColor.text, "RIGHT", -1, 0)
    dispelGlowButton:SetSize(43, 18)
    dispelGlowButton:SetScript("OnClick", function()
        OpenColorPicker(BetterBlizzFramesDB.purgeTextureColorRGB)
    end)
    CreateTooltip(dispelGlowButton, "Dispel/Purge Glow Color.")

    local sortingSettings = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sortingSettings:SetPoint("TOPLEFT", auraImportantDispelIcon, "BOTTOMLEFT", 10, -4)
    sortingSettings:SetText("Sorting:")

    local customImportantAuraSorting = CreateCheckbox("customImportantAuraSorting", "Sort Important Auras", playerAuraFiltering)
    customImportantAuraSorting:SetPoint("TOPLEFT", auraImportantDispelIcon, "BOTTOMLEFT", 0, -20)
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
    settingsText:SetPoint("TOPLEFT", guiMisc, "TOPLEFT", 20, 0)
    settingsText:SetText("Misc settings")
    local miscSettingsIcon = guiMisc:CreateTexture(nil, "ARTWORK")
    miscSettingsIcon:SetAtlas("optionsicon-brown")
    miscSettingsIcon:SetSize(22, 22)
    miscSettingsIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)

    local normalizeGameMenu = CreateCheckbox("normalizeGameMenu", "Normal Size Game Menu", guiMisc)
    normalizeGameMenu:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltipTwo(normalizeGameMenu, "Normal Size Game Menu", "Enable to make the Game Menu (Escape) normal size again.\nWe're old boomers but we're not that old jesus.")
    normalizeGameMenu:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBF.NormalizeGameMenu(true)
        else
            BBF.NormalizeGameMenu(false)
        end
    end)

    local minimizeObjectiveTracker = CreateCheckbox("minimizeObjectiveTracker", "Minimize Objective Frame Better", guiMisc, nil, BBF.MinimizeObjectiveTracker)
    minimizeObjectiveTracker:SetPoint("TOPLEFT", normalizeGameMenu, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(minimizeObjectiveTracker, "Minimize Objective Frame Better", "Also minimize the objectives header when clicking the -+ button |A:UI-QuestTrackerButton-Collapse-All:19:19|a")

    local hideUiErrorFrame = CreateCheckbox("hideUiErrorFrame", "Hide UI Error Frame", guiMisc, nil, BBF.HideFrames)
    hideUiErrorFrame:SetPoint("TOPLEFT", minimizeObjectiveTracker, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideUiErrorFrame, "Hide UI Error Frame", "Hides the UI Error Frame (The red text displaying \"Not enough mana\" etc)")

    local fadeMicroMenu = CreateCheckbox("fadeMicroMenu", "Fade Micro Menu", guiMisc, nil, BBF.FadeMicroMenu)
    fadeMicroMenu:SetPoint("TOPLEFT", hideUiErrorFrame, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(fadeMicroMenu, "Fade Micro Menu", "Fade out the Micro Menu bottom right and only show on mouseover.")

    local fadeMicroMenuExceptQueue = CreateCheckbox("fadeMicroMenuExceptQueue", "Except Queue Eye", fadeMicroMenu, nil, BBF.FadeMicroMenu)
    fadeMicroMenuExceptQueue:SetPoint("LEFT", fadeMicroMenu.text, "RIGHT", 0, 0)
    CreateTooltipTwo(fadeMicroMenuExceptQueue, "Except Queue Eye", "Do not fade Queue Status Eye together with the Micro Menu.")

    fadeMicroMenu:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local moveQueueStatusEye = CreateCheckbox("moveQueueStatusEye", "Move Queue Status Eye", guiMisc, nil, BBF.MoveQueueStatusEye)
    moveQueueStatusEye:SetPoint("TOPLEFT", fadeMicroMenu, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(moveQueueStatusEye, "Move Queue Status Eye", "Makes the Queue Status Eye movable. Default position on Minimap but can also be dragged with Ctrl + Leftclick.")

    moveQueueStatusEye:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local hideBagsBar = CreateCheckbox("hideBagsBar", "Hide Bags Bar", guiMisc, nil, BBF.HideFrames)
    hideBagsBar:SetPoint("TOPLEFT", moveQueueStatusEye, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideBagsBar, "Hide Bags Bar", "Hide the default Bag Bar showing your bags bottom right.")

    hideBagsBar:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local moveableFPSCounter = CreateCheckbox("moveableFPSCounter", "Moveable FPS Counter", guiMisc, nil, BBF.MoveableFPSCounter)
    moveableFPSCounter:SetPoint("TOPLEFT", hideBagsBar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(moveableFPSCounter, "Moveable FPS Counter", "Make the default Blizzard FPS Counter (Ctrl+R) moveable.\n\n|cff32f795Right-click to reset position.|r\n|cff32f795Shift+Right-click to toggle font outline on/off.|r")
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

    local removeAddonListCategories = CreateCheckbox("removeAddonListCategories", "Remove AddonList Categories", guiMisc, nil, BBF.RemoveAddonCategories)
    removeAddonListCategories:SetPoint("TOPLEFT", moveableFPSCounter, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(removeAddonListCategories, "Remove AddonList Categories", "Remove the categories from AddonList. (Escape -> AddOns)")

    local hideMinimap = CreateCheckbox("hideMinimap", "Hide Minimap", guiMisc, nil, BBF.MinimapHider)
    hideMinimap:SetPoint("TOPLEFT", removeAddonListCategories, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

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
        CheckAndToggleCheckboxes(hideMinimapAuto)
        BBF.MinimapHider()
    end)

    local hideMinimapAutoQueueEye = CreateCheckbox("hideMinimapAutoQueueEye", "Hide Queue Status Eye during Arena", guiMisc)
    hideMinimapAutoQueueEye:SetPoint("TOPLEFT", hideMinimapAuto, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideMinimapAutoQueueEye, "Automatically hide Queue Status Eye during arena games.")
    hideMinimapAutoQueueEye:HookScript("OnClick", function()
        BBF.MinimapHider()
    end)

    local hideObjectiveTracker = CreateCheckbox("hideObjectiveTracker", "Hide Objective Tracker during Arena", guiMisc)
    hideObjectiveTracker:SetPoint("TOPLEFT", hideMinimapAutoQueueEye, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideObjectiveTracker, "Automatically hide Objective Tracker during arena games.")
    hideObjectiveTracker:HookScript("OnClick", function()
        BBF.MinimapHider()
    end)

    local recolorTempHpLoss = CreateCheckbox("recolorTempHpLoss", "Recolor Temp Max HP Loss", guiMisc)
    recolorTempHpLoss:SetPoint("TOPLEFT", hideObjectiveTracker, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(recolorTempHpLoss, "Recolor Temp Max HP Loss", "Recolor the temp max hp loss on Player/Target/Focus/Party frame to a softer red color.")
    recolorTempHpLoss:HookScript("OnClick", function()
        BBF.RecolorHpTempLoss()
    end)

    local hideActionBarHotKey = CreateCheckbox("hideActionBarHotKey", "Hide ActionBar Keybinds", guiMisc, nil, BBF.HideFrames)
    hideActionBarHotKey:SetPoint("TOPLEFT", recolorTempHpLoss, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideActionBarHotKey, "Hides the keybind on default actionbars (I highly recommend getting Bartender though, doesnt bug like default does)")

    local hideActionBarMacroName = CreateCheckbox("hideActionBarMacroName", "Hide ActionBar Macro Name", guiMisc, nil, BBF.HideFrames)
    hideActionBarMacroName:SetPoint("TOPLEFT", hideActionBarHotKey, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideActionBarMacroName, "Hides the macro name on default actionbars (I highly recommend getting Bartender though, doesnt bug like default does)")

    local hideStanceBar = CreateCheckbox("hideStanceBar", "Hide StanceBar (ActionBar)", guiMisc, nil, BBF.HideFrames)
    hideStanceBar:SetPoint("TOPLEFT", hideActionBarMacroName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local hideDragonFlying = CreateCheckbox("hideDragonFlying", "Auto-hide Dragonriding (Temporary)", guiMisc)
    hideDragonFlying:SetPoint("TOPLEFT", hideStanceBar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideDragonFlying, "Automatically hide the dragon riding thing\nin zones where it shouldnt be showing.\n\n(Blizzard pls fix ur shit)")

    local stealthIndicatorPlayer = CreateCheckbox("stealthIndicatorPlayer", "Stealth Indicator (Temporary?)", guiMisc, nil, BBF.StealthIndicator)
    stealthIndicatorPlayer:SetPoint("TOPLEFT", hideDragonFlying, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    stealthIndicatorPlayer:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    CreateTooltip(stealthIndicatorPlayer, "Add a blue border texture around the\nplayer frame during stealth abilities")

    local addUnitFrameBgTexture = CreateCheckbox("addUnitFrameBgTexture", "UnitFrame Background Color", guiMisc)
    addUnitFrameBgTexture:SetPoint("TOPLEFT", stealthIndicatorPlayer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(addUnitFrameBgTexture, "UnitFrame Background Color", "Enables background color behind health and mana on UnitFrames.\n\n|cff32f795Right-click to change color.|r")
    addUnitFrameBgTexture:HookScript("OnClick", function(self)
        BBF.UnitFrameBackgroundTexture()
    end)
    addUnitFrameBgTexture:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            local function OpenColorPicker(entryColors)
                local colorData = entryColors or {0, 1, 0, 1}
                local r, g, b = colorData[1] or 1, colorData[2] or 1, colorData[3] or 1
                local a = colorData[4] or 1

                local function updateColors(newR, newG, newB, newA)
                    entryColors[1] = newR
                    entryColors[2] = newG
                    entryColors[3] = newB
                    entryColors[4] = newA or 1

                    BBF.UnitFrameBackgroundTexture()
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
            OpenColorPicker(BetterBlizzFramesDB.unitFrameBgTextureColor)
        end
    end)

    local useMiniPlayerFrame = CreateCheckbox("useMiniPlayerFrame", "Enable Mini-PlayerFrame", guiMisc)
    useMiniPlayerFrame:SetPoint("TOPLEFT", addUnitFrameBgTexture, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(useMiniPlayerFrame, "Removes healthbar and manabar from the PlayerFrame\nand just leaves Portrait and name.\n\nMove castbar and/or disable auras to your liking.")
    useMiniPlayerFrame:HookScript("OnClick", function(self)
        BBF.MiniFrame(PlayerFrame)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local useMiniTargetFrame = CreateCheckbox("useMiniTargetFrame", "Enable Mini-TargetFrame", guiMisc)
    useMiniTargetFrame:SetPoint("TOPLEFT", useMiniPlayerFrame, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(useMiniTargetFrame, "Removes healthbar and manabar from the TargetFrame\nand just leaves Portrait and name.\n\nMove castbar and/or disable auras to your liking.")
    useMiniTargetFrame:HookScript("OnClick", function(self)
        BBF.MiniFrame(TargetFrame)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local useMiniFocusFrame = CreateCheckbox("useMiniFocusFrame", "Enable Mini-FocusFrame", guiMisc)
    useMiniFocusFrame:SetPoint("TOPLEFT", useMiniTargetFrame, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(useMiniFocusFrame, "Removes healthbar and manabar from the FocusFrame\nand just leaves Portrait and name.\n\nMove castbar and/or disable auras to your liking.")
    useMiniFocusFrame:HookScript("OnClick", function(self)
        BBF.MiniFrame(FocusFrame)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local surrenderArena = CreateCheckbox("surrenderArena", "Surrender over Leaving Arena", guiMisc)
    surrenderArena:SetPoint("TOPLEFT", useMiniFocusFrame, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(surrenderArena, "Surrender over Leave", "Makes typing /afk in arena Surrender instead of Leaving so you don't lose honor/conquest gain.")

    local druidOverstacks = CreateCheckbox("druidOverstacks", "Druid: Color Berserk Overstack Combo Points Blue", guiMisc)
    druidOverstacks:SetPoint("TOPLEFT", surrenderArena, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(druidOverstacks, "Druid: Color Berserk Overstack Combo Points Blue", "Color the Druid Berserk Overstack Combo Points blue similar to Rogue's Echoing Reprimand.")

    local hideTalkingHeads = CreateCheckbox("hideTalkingHeads", "Hide Talking Heads Frame", guiMisc, nil, BBF.HideTalkingHeads)
    hideTalkingHeads:SetPoint("TOPLEFT", druidOverstacks, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideTalkingHeads, "Hide Talking Heads Frame", "Hide the frame showing npcs talking during quests etc.")
    hideTalkingHeads:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local hideExpAndHonorBar = CreateCheckbox("hideExpAndHonorBar", "Hide XP & Honor Bar", guiMisc, nil, BBF.HideFrames)
    hideExpAndHonorBar:SetPoint("TOPLEFT", hideTalkingHeads, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideExpAndHonorBar, "Hide XP & Honor Bar", "Hide XP & Honor Bar. Still shows when opening Character Panel.")
    hideExpAndHonorBar:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local uiWidgetPowerBarScale = CreateSlider(guiMisc, "UIWidgetPowerBarFrame Scale", 0.4, 1.8, 0.01, "uiWidgetPowerBarScale")
    uiWidgetPowerBarScale:SetPoint("TOPLEFT", hideExpAndHonorBar, "BOTTOMLEFT", 5, -15)
    CreateTooltipTwo(uiWidgetPowerBarScale, "UIWidgetPowerBarFrame Scale", "Changes the scale of UIWidgetPowerBarFrame, the frame with Dragonflying charges on it. Also has things like achievements etc I believe idk.")

    local hideActionBarBigProcGlow = CreateCheckbox("hideActionBarBigProcGlow", "Hide ActionBar Big Proc Glow", guiMisc, nil, BBF.ActionBarMods)
    hideActionBarBigProcGlow:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", 310, pixelsOnFirstBox)
    CreateTooltipTwo(hideActionBarBigProcGlow, "Hide Actionbar Big Proc Glow", "Hide the big proc glow on default actionbars.\n\nIt will still glow on procs etc but the giant animation when you get the proc will not appear.")

    local hideActionBarCastAnimation = CreateCheckbox("hideActionBarCastAnimation", "Hide ActionBar Cast Animation", guiMisc, nil, BBF.ActionBarMods)
    hideActionBarCastAnimation:SetPoint("TOPLEFT", hideActionBarBigProcGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideActionBarCastAnimation, "Hide ActionBar Cast Animation", "Hide the cast animation on default ActionBar buttons.")

    local fixActionBarCDs = CreateCheckbox("fixActionBarCDs", "Fix ActionBar Cooldowns During CC", guiMisc, nil, BBF.ShowCooldownDuringCC)
    fixActionBarCDs:SetPoint("TOPLEFT", hideActionBarCastAnimation, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(fixActionBarCDs, "Fix ActionBar Cooldowns During CC", "Always show ability cooldowns when you're CC'ed.\n\nBy default if the CC is longer than the ability cooldown it gets hidden. You've probably been in situations where you Trinket to interrupt someone only for interrupt to still be on a few seconds CD. No more!")

    local raiseTargetFrameLevel = CreateCheckbox("raiseTargetFrameLevel", "Raise TargetFrame Layer", guiMisc, nil, BBF.RaiseTargetFrameLevel)
    raiseTargetFrameLevel:SetPoint("TOPLEFT", fixActionBarCDs, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(raiseTargetFrameLevel, "Raise TargetFrame Layer", "Raise the frame level of TargetFrame so it is above FocusFrame.\n\nThis makes it so if you have TargetFrame positioned above FocusFrame and the Target has so many auras that the castbar goes down to the FocusFrame the castbar will not be hidden behind the FocusFrame.")

    local raiseTargetCastbarStrata = CreateCheckbox("raiseTargetCastbarStrata", "Raise Castbar Stratas", guiMisc, nil, BBF.RaiseTargetCastbarStratas)
    raiseTargetCastbarStrata:SetPoint("TOPLEFT", raiseTargetFrameLevel, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(raiseTargetCastbarStrata, "Raise Castbar Stratas", "Raise the Strata of Target & Focus frame so it does not appear behind the frames.")

    local instantComboPoints = CreateCheckbox("instantComboPoints", "Instant Combo Points", guiMisc, nil, BBF.InstantComboPoints)
    instantComboPoints:SetPoint("TOPLEFT", raiseTargetCastbarStrata, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(instantComboPoints, "Instant Combo Points", "Remove the combo point animations for instant feedback. Currently works for Rogues, Druids, Monks and Mages.")
    instantComboPoints:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local moveResource = CreateCheckbox("moveResource", "Move Resource", guiMisc)
    moveResource:SetPoint("TOPLEFT", instantComboPoints, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(moveResource, "Move Resource", "Move resource (Combo points etc) freely by holding |cff32f795Ctrl + Left Click|r to drag.\n\nToggle off/on to unlock them and reload to save.\n\n|cff32f795Right-click to reset positions and scale for " .. playerClass .. ".|r", "This setting is class specific to the class you are on.")
    moveResource:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBF.EnableResourceMovement()
        end
    end)
    if BetterBlizzFramesDB.moveResourceStackPos and not BetterBlizzFramesDB.moveResourceStackPos[playerClass] then
        moveResource:SetChecked(false)
    elseif not BetterBlizzFramesDB.moveResourceStackPos then
        moveResource:SetChecked(false)
    end

    local moveResourceToTarget = CreateCheckbox("moveResourceToTarget", "Move Resource to TargetFrame", guiMisc)
    moveResourceToTarget:SetPoint("TOPLEFT", moveResource, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTarget, "Move resource (Combo points, Warlock shards etc) to the TargetFrame.")

    local moveResourceToTargetCustom = CreateCheckbox("moveResourceToTargetCustom", "Free-Move", moveResourceToTarget)
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
    CreateTooltipTwo(moveResourceToTargetCustom, "Free-Move Resource", "Drag and drop resource/combo points to where you want them.\nWhile moving you can do half pixel adjustments with arrow keys.\n\nToggle off/on to unlock them and reload to save.\n\n" .. "|cff32f795Right-click to reset positions and scale for " .. playerClass .. ".|r", "This will unchain them from TargetFrame so they will no longer move with the TargetFrame if you move the TargetFrame.")

    local moveResourceToTargetRogue = CreateCheckbox("moveResourceToTargetRogue", "Rogue: Combo Points", moveResourceToTarget)
    moveResourceToTargetRogue:SetPoint("TOPLEFT", moveResourceToTarget, "BOTTOMLEFT", 12, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetRogue, "Move Rogue Combo Points to TargetFrame.")
    moveResourceToTargetRogue:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

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

    local moveResourceToTargetDK = CreateCheckbox("moveResourceToTargetDK", "Death Knight: Runes", moveResourceToTarget)
    moveResourceToTargetDK:SetPoint("TOPLEFT", moveResourceToTargetMage, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetDK, "Move Death Knight Runes to TargetFrame.")
    moveResourceToTargetDK:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetPaladin = CreateCheckbox("moveResourceToTargetPaladin", "Paladin: Holy Charges", moveResourceToTarget)
    moveResourceToTargetPaladin:SetPoint("TOPLEFT", moveResourceToTargetDK, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetPaladin, "Move Paladin Holy Charges to TargetFrame.")
    moveResourceToTargetPaladin:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetPaladinBG = CreateCheckbox("moveResourceToTargetPaladinBG", "BG", moveResourceToTargetPaladin)
    moveResourceToTargetPaladinBG:SetPoint("LEFT", moveResourceToTargetPaladin.text, "RIGHT", 0, 0)
    CreateTooltipTwo(moveResourceToTargetPaladinBG, "Background", "Show background for unfilled charges.")

    moveResourceToTargetPaladinBG:HookScript("OnClick", function(self)
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    moveResourceToTargetPaladin:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(self)
    end)

    local key = "classResource" .. playerClass .. "Scale"
    local classResourceScale = CreateSlider(guiMisc, "Class Resource Scale", 0.4, 2, 0.01, key)
    classResourceScale:SetPoint("TOPLEFT", moveResourceToTargetPaladin, "BOTTOMLEFT", 5, -15)
    CreateTooltipTwo(classResourceScale, "Class Resource Scale", "Changes the scale of Resource/ComboPoints.", "This setting is class specific to the class you are logged in on.")

    moveResource:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if BetterBlizzFramesDB.moveResourceStackPos then
                BetterBlizzFramesDB.moveResourceStackPos[playerClass] = nil
            end
            classResourceScale:SetValue(1)
            print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: Combo point positions for " .. playerClass .. " have been reset.")
            BBF.ResetResourcePosition()
        end
    end)

    moveResourceToTargetCustom:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            if BetterBlizzFramesDB.customComboPositions then
                BetterBlizzFramesDB.customComboPositions[playerClass] = nil
            end
            classResourceScale:SetValue(1)
            print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: Combo point positions for " .. playerClass .. " have been reset.")
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
end

local function guiChatFrame()

    local guiChatFrame = CreateFrame("Frame")
    guiChatFrame.name = "ChatFrame"
    guiChatFrame.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(guiChatFrame)

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

    local fullProfile = CreateImportExportUI(guiImportAndExport, "Full Profile", BetterBlizzFramesDB, 20, -20, "fullProfile")

    local auraWhitelist = CreateImportExportUI(fullProfile, "Aura Whitelist", BetterBlizzFramesDB.auraWhitelist, 0, -100, "auraWhitelist")
    local auraBlacklist = CreateImportExportUI(auraWhitelist, "Aura Blacklist", BetterBlizzFramesDB.auraBlacklist, 210, 0, "auraBlacklist")

    local importPVPWhitelist = CreateFrame("Button", nil, guiImportAndExport, "UIPanelButtonTemplate")
    importPVPWhitelist:SetSize(150, 35)
    importPVPWhitelist:SetPoint("TOP", auraWhitelist, "BOTTOM", 0, -25)
    importPVPWhitelist:SetText("Import PvP Whitelist")
    importPVPWhitelist:SetScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_PVP_WHITELIST")
    end)
    local coloredText = "|cff00FF00Important/Immunity|r\n" ..
                    "|cffFF8000Offensive Buff|r\n" ..
                    "|cffFFA9F1Defensive Buffs|r\n" ..
                    "|cff00FFFFFreedom/Speed|r\n" ..
                    "|cffEFFF33Fear Immunity|r"

    CreateTooltipTwo(importPVPWhitelist, "Import PvP Whitelist", "Import a color coded Whitelist with most important Offensives, Defensives & Freedoms for TWW added.\n\n"..coloredText.."\n\nThis will only add NEW entries and not mess with existing ones in your current whitelist.\n\nWill tweak this as time goes on probably.")

    local importPVPBlacklist = CreateFrame("Button", nil, guiImportAndExport, "UIPanelButtonTemplate")
    importPVPBlacklist:SetSize(150, 35)
    importPVPBlacklist:SetPoint("TOP", auraBlacklist, "BOTTOM", 0, -25)
    importPVPBlacklist:SetText("Import PvP Blacklist")
    importPVPBlacklist:SetScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_PVP_BLACKLIST")
    end)
    CreateTooltipTwo(importPVPBlacklist, "Import PvP Blacklist", "Import a Blacklist with A LOT (750+) of trash buffs blacklisted.\n\nThis will only add NEW entries and not mess with existing ones already in your blacklist.")

end

local function guiCustomCode()
    local guiCustomCode = CreateFrame("Frame")
    guiCustomCode.name = "Custom Code"
    guiCustomCode.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(guiCustomCode)
    local guiCustomCodeSubCategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, guiCustomCode, guiCustomCode.name, guiCustomCode.name)
    guiCustomCodeSubCategory.ID = guiCustomCode.name;
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

    local discordText = guiCustomCode:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    discordText:SetPoint("BOTTOM", discordLinkEditBox, "TOP", 18, 8)
    discordText:SetText("Join the Discord for info\nand help with BBP/BBF")

    local joinDiscord = guiCustomCode:CreateTexture(nil, "ARTWORK")
    joinDiscord:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\logos\\discord.tga")
    joinDiscord:SetSize(52, 52)
    joinDiscord:SetPoint("RIGHT", discordText, "LEFT", 0, 1)

    local boxOne = CreateFrame("EditBox", nil, guiCustomCode, "InputBoxTemplate")
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

    local boxOneTex = guiCustomCode:CreateTexture(nil, "ARTWORK")
    boxOneTex:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\logos\\patreon.tga")
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

    local boxTwoTex = guiCustomCode:CreateTexture(nil, "ARTWORK")
    boxTwoTex:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\logos\\paypal.tga")
    boxTwoTex:SetSize(58, 58)
    boxTwoTex:SetPoint("BOTTOMLEFT", boxTwo, "TOPLEFT", 3, -2)

    local palText = guiCustomCode:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    palText:SetPoint("LEFT", boxTwoTex, "RIGHT", 14, -1)
    palText:SetText("Paypal")







    -- Implementing the code editor inside the guiCustomCode frame
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
    local scrollFrame = CreateFrame("ScrollFrame", nil, guiCustomCode, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOP", guiCustomCode, "TOP", -10, -110)
    scrollFrame:SetSize(620, 440)  -- Fixed size for the entire editor box

    -- Label for the custom code box
    local customCodeText = guiCustomCode:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
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
    local saveButton = CreateFrame("Button", nil, guiCustomCode, "UIPanelButtonTemplate")
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
            if BetterBlizzFramesDB.reopenOptions then
                ReloadUI()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    local reloadUiButton = CreateFrame("Button", nil, guiCustomCode, "UIPanelButtonTemplate")
    reloadUiButton:SetText("Reload UI")
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
    discordText:SetText("Join the Discord for info\nand help with BBP/BBF")

    local joinDiscord = guiSupport:CreateTexture(nil, "ARTWORK")
    joinDiscord:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\logos\\discord.tga")
    joinDiscord:SetSize(52, 52)
    joinDiscord:SetPoint("RIGHT", discordText, "LEFT", 0, 1)

    local supportText = guiSupport:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    supportText:SetPoint("TOP", guiSupport, "TOP", 0, -230)
    supportText:SetText("If you wish to support me and my projects\nit would be greatly appreciated |A:GarrisonTroops-Health:10:10|a")

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
function BBF.InitializeOptions()
    if not BetterBlizzFrames then
        BetterBlizzFrames = CreateFrame("Frame")
        BetterBlizzFrames.name = "Better|cff00c0ffBlizz|rFrames |A:gmchat-icon-blizz:16:16|a"
        --InterfaceOptions_AddCategory(BetterBlizzFrames)
        BBF.category = Settings.RegisterCanvasLayoutCategory(BetterBlizzFrames, BetterBlizzFrames.name, BetterBlizzFrames.name)
        BBF.category.ID = BetterBlizzFrames.name
        Settings.RegisterAddOnCategory(BBF.category)

        local titleText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFont_Gigantic")
        titleText:SetPoint("CENTER", BetterBlizzFrames, "CENTER", -15, 33)
        titleText:SetText("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames")
        BetterBlizzFrames.titleText = titleText

        local loadGUI = CreateFrame("Button", nil, BetterBlizzFrames, "UIPanelButtonTemplate")
        loadGUI:SetText("Load Settings")
        loadGUI:SetWidth(100)
        loadGUI:SetPoint("CENTER", BetterBlizzFrames, "CENTER", -18, 6)
        BetterBlizzFrames.loadGUI = loadGUI
        loadGUI:SetScript("OnClick", function(self)
            if InCombatLockdown() then
                print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: Leave combat to open settings for the first time.")
                return
            end
            titleText:Hide()
            self:Hide()
            BBF.LoadGUI()
        end)
    end
end

local function MoveableSettingsPanel()
    local frame = SettingsPanel
    if frame and not frame:GetScript("OnDragStart") and not C_AddOns.IsAddOnLoaded("BlizzMove") then
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    end
end

function BBF.LoadGUI()
    if BetterBlizzFrames.guiLoaded then return end
    if BetterBlizzFramesDB.hasNotOpenedSettings then
        BBF.CreateIntroMessageWindow()
        BetterBlizzFramesDB.hasNotOpenedSettings = nil
        return
    end
    if InCombatLockdown() then
        print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: Leave combat to open settings for the first time.")
        return
    end
    MoveableSettingsPanel()

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

    Settings.OpenToCategory(BBF.guiCustomCode)
    Settings.OpenToCategory(BBF.category.ID)
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
    BBF.IntroMessageWindow:SetTitle("Better|cff00c0ffBlizz|rFrames v"..BBF.VersionNumber)
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
    welcomeText:SetText("Welcome to Better|cff00c0ffBlizz|rFrames!")
    welcomeText:SetJustifyH("CENTER")

    local description1 = BBF.IntroMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    description1:SetPoint("TOP", welcomeText, "BOTTOM", 0, -10)
    description1:SetText("Thank you for trying out my addon!\n\nBelow you can pick a profile to start with or you can exit and customize everything by yourself.\n\nI highly recommend the minimal |A:newplayerchat-chaticon-newcomer:16:16|a|cff32cd32Starter Profile|r if you just\nwant a quick start with only the essentials!")
    description1:SetJustifyH("CENTER")
    description1:SetWidth(410)

    local btnWidth, btnHeight, btnGap = 150, 30, -3

    local function ShowProfileConfirmation(profileName, class, profileFunction, additionalNote)
        local noteText = additionalNote or ""
        local color = CLASS_COLORS[class] or "|cffffffff"
        local icon = CLASS_ICONS[class] or "groupfinder-icon-role-leader"
        local profileText = string.format("|A:%s:16:16|a %s%s|r", icon, color, profileName.." Profile")
        local confirmationText = titleText .. "Are you sure you want to go\nwith the " .. profileText .. "?\n\n" .. noteText .. "Click yes to apply and Reload UI."
        StaticPopupDialogs["BBF_CONFIRM_PROFILE"].text = confirmationText
        StaticPopup_Show("BBF_CONFIRM_PROFILE", nil, nil, { func = profileFunction })
    end

    local starterButton = CreateClassButton(BBF.IntroMessageWindow, "STARTER", "Starter", nil, function()
        ShowProfileConfirmation("Starter", "STARTER", BBF.StarterProfile)
    end)
    starterButton:SetPoint("TOP", description1, "BOTTOM", 0, -20)

    local orText = BBF.IntroMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    orText:SetPoint("CENTER", starterButton, "BOTTOM", 0, -20)
    orText:SetText("OR")
    orText:SetJustifyH("CENTER")

    local aeghisButton = CreateClassButton(BBF.IntroMessageWindow, "MAGE", "Aeghis", "aeghis", function()
        ShowProfileConfirmation("Aeghis", "MAGE", BBF.AeghisProfile)
    end)
    aeghisButton:SetPoint("TOP", starterButton, "BOTTOM", 0, -40)

    local kalvishButton = CreateClassButton(BBF.IntroMessageWindow, "ROGUE", "Kalvish", "kalvish", function()
        ShowProfileConfirmation("Kalvish", "ROGUE", BBF.KalvishProfile)
    end)
    kalvishButton:SetPoint("TOP", aeghisButton, "BOTTOM", 0, btnGap)

    local magnuszButton = CreateClassButton(BBF.IntroMessageWindow, "WARRIOR", "Magnusz", "magnusz", function()
        ShowProfileConfirmation("Magnusz", "WARRIOR", BBF.MagnuszProfile)
    end)
    magnuszButton:SetPoint("TOP", kalvishButton, "BOTTOM", 0, btnGap)

    local nahjButton = CreateClassButton(BBF.IntroMessageWindow, "ROGUE", "Nahj", "nahj", function()
        ShowProfileConfirmation("Nahj", "ROGUE", BBF.NahjProfile)
    end)
    nahjButton:SetPoint("TOP", magnuszButton, "BOTTOM", 0, btnGap)

    local snupyButton = CreateClassButton(BBF.IntroMessageWindow, "DRUID", "Snupy", "snupy", function()
        ShowProfileConfirmation("Snupy", "DRUID", BBF.SnupyProfile)
    end)
    snupyButton:SetPoint("TOP", nahjButton, "BOTTOM", 0, btnGap)

    local orText2 = BBF.IntroMessageWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    orText2:SetPoint("CENTER", snupyButton, "BOTTOM", 0, -20)
    orText2:SetText("OR")
    orText2:SetJustifyH("CENTER")

    local buttonLast = CreateFrame("Button", nil, BBF.IntroMessageWindow, "GameMenuButtonTemplate")
    buttonLast:SetSize(btnWidth, btnHeight)
    buttonLast:SetText("Exit, No Profile.")
    buttonLast:SetPoint("TOP", snupyButton, "BOTTOM", 0, -40)
    buttonLast:SetNormalFontObject("GameFontNormal")
    buttonLast:SetHighlightFontObject("GameFontHighlight")
    buttonLast:SetScript("OnClick", function()
        BBF.IntroMessageWindow:Hide()
        if not BetterBlizzFrames.guiLoaded then
            BBF.LoadGUI()
        else
            Settings.OpenToCategory(BBF.category.ID)
        end
    end)
    CreateTooltipTwo(buttonLast, "Exit, No Profile", "Exit and customize everything yourself.", nil, "ANCHOR_TOP")
    local f,s,o = buttonLast.Text:GetFont()
    buttonLast.Text:SetFont(f,s,"OUTLINE")

    BBF.IntroMessageWindow.CloseButton:HookScript("OnClick", function()
        if not BetterBlizzFrames.guiLoaded then
            BBF.LoadGUI()
        else
            Settings.OpenToCategory(BBF.category.ID)
        end
    end)

    local function AdjustWindowHeight()
        local baseHeight = 334
        local perButtonHeight = 29
        local buttonCount = -1
        for _, child in ipairs({BBF.IntroMessageWindow:GetChildren()}) do
            if child and child:IsObjectType("Button") then
                buttonCount = buttonCount + 1
            end
        end
        local newHeight = baseHeight + (buttonCount * perButtonHeight)
        BBF.IntroMessageWindow:SetSize(470, newHeight)
    end
    AdjustWindowHeight()
end