local darkModeUi
local darkModeUiAura
local darkModeColor = 1
local removeDebuffColorBorder
local auraFilteringOn
local minimapChanged =false

local hookedTotemBar
local hookedAuras

local function applySettings(frame, desaturate, colorValue, hook)
    if frame then
        if desaturate ~= nil and frame.SetDesaturated then
            frame:SetDesaturated(desaturate)
        end

        if frame.SetVertexColor then
            frame:SetVertexColor(colorValue, colorValue, colorValue)
            if hook then
                if not frame.bbfHooked then
                    frame.bbfHooked = true
                    frame:SetVertexColor(colorValue, colorValue, colorValue, 1)

                    hooksecurefunc(frame, "SetVertexColor", function(self)
                        if self.changing or self:IsProtected() then return end
                        self.changing = true
                        self:SetDesaturated(desaturate)
                        self:SetVertexColor(colorValue, colorValue, colorValue, 1)
                        self.changing = false
                    end)
                end
            end
        end
    end
end

-- Hook function for SetVertexColor
local function OnSetVertexColorHookScript(r, g, b, a)
    return function(frame, _, _, _, _, flag)
        if flag ~= "BBFHookSetVertexColor" then
            frame:SetVertexColor(r, g, b, a, "BBFHookSetVertexColor")
        end
    end
end

-- Function to hook SetVertexColor and keep the color on updates
function BBF.HookVertexColor(frame, r, g, b, a)
    frame:SetVertexColor(r, g, b, a, "BBFHookSetVertexColor")

    if not frame.BBFHookSetVertexColor then
        hooksecurefunc(frame, "SetVertexColor", OnSetVertexColorHookScript(r, g, b, a))
        frame.BBFHookSetVertexColor = true
    end
end

function BBF.UpdateUserDarkModeSettings()
    darkModeUi = BetterBlizzFramesDB.darkModeUi
    darkModeUiAura = BetterBlizzFramesDB.darkModeUiAura
    hookedTotemBar = BetterBlizzFramesDB.hookedTotemBar
    darkModeColor = BetterBlizzFramesDB.darkModeColor
    removeDebuffColorBorder = BetterBlizzFramesDB.removeDebuffColorBorder
    auraFilteringOn = BetterBlizzFramesDB.playerAuraFiltering
end

local hooked = {}
local function UpdateFrameAuras(self)
    if not (darkModeUi and darkModeUiAura) then return end

    local maxAuras = MAX_TARGET_BUFFS or 60
    local auraType = self:GetName().."Buff"

    for i = 1, maxAuras do
        local auraName = auraType..i
        local auraFrame = _G[auraName]

        if auraFrame and auraFrame:IsShown() then
            if not hooked[auraFrame] then
                local icon = _G[auraName.."Icon"]
                if icon then
                    auraFrame.Icon = icon
                    hooked[auraFrame] = true

                    if not auraFrame.border then
                        local border = CreateFrame("Frame", nil, auraFrame, "BackdropTemplate")
                        border:SetBackdrop({
                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                            tileEdge = true,
                            edgeSize = 8.5,
                        })

                        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                        border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1.5, 1.5)
                        border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1.5, -2)
                        auraFrame.border = border

                        -- Set the initial border color
                        border:SetBackdropBorderColor(darkModeColor, darkModeColor, darkModeColor)
                    end

                    if auraFrame.Border then
                        auraFrame.border:Hide()
                    else
                        auraFrame.border:Show()
                    end
                end
            else
                if auraFrame.Border then
                    auraFrame.border:Hide()
                else
                    auraFrame.border:Show()
                end
            end
        else
            break
        end
    end

    if removeDebuffColorBorder then
        local auraType = self:GetName().."Debuff"
        for i = 1, maxAuras do
            local auraName = auraType..i
            local auraFrame = _G[auraName]

            if auraFrame and auraFrame:IsShown() then
                if not hooked[auraFrame] then
                    local icon = _G[auraName.."Icon"]
                    local border = _G[auraName.."Border"]
                    if icon then
                        auraFrame.Icon = icon
                        auraFrame.Border = border
                        hooked[auraFrame] = true

                        if not auraFrame.border then
                            local border = CreateFrame("Frame", nil, auraFrame, "BackdropTemplate")
                            border:SetBackdrop({
                                edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                                tileEdge = true,
                                edgeSize = 8.5,
                            })

                            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                            border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1.5, 2)
                            border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1.5, -2)
                            auraFrame.border = border

                            border:SetBackdropBorderColor(darkModeColor, darkModeColor, darkModeColor)
                        end

                        auraFrame.Border:Hide()
                        auraFrame.border:Show()
                    end
                else
                    auraFrame.Border:Hide()
                    auraFrame.border:Show()
                end
            else
                break
            end
        end
    end
end
function BBF.DarkModeUnitframeBorders()
    if (BetterBlizzFramesDB.darkModeUiAura and BetterBlizzFramesDB.darkModeUi) and not hookedAuras then
        if TargetFrame_UpdateAuras then
            hooksecurefunc("TargetFrame_UpdateAuras", function(self)
                UpdateFrameAuras(self)
            end)
        else
            hooksecurefunc(TargetFrame, "UpdateAuras", function(self)
                UpdateFrameAuras(self)
            end)
        end
        UpdateFrameAuras(TargetFrame)
        hookedAuras = true
    end
end

BBF.auraBorders = {}  -- BuffFrame aura borders for darkmode
local function createOrUpdateBorders(frame, colorValue, textureName, bypass)
    if (darkModeUi and darkModeUiAura) or bypass then
        if not BBF.auraBorders[frame] then
            -- Create borders
            local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
            if not bypass then
                border:SetBackdrop({
                    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                    tileEdge = true,
                    edgeSize = 8,
                })
            else
                border:SetBackdrop({
                    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                    tileEdge = true,
                    edgeSize = 10,
                })
            end

            local icon = frame.Icon
            if textureName then
                icon = frame[textureName]
            end
            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Adjust the icon

            if not bypass then
                border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1.5, 2)
                border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1.5, -1.5)
            else
                border:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
                border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
            end
            border:SetBackdropBorderColor(colorValue, colorValue, colorValue)

            BBF.auraBorders[frame] = border -- Store the border
            if frame.ImportantGlow then
                frame.ImportantGlow:SetParent(border)
                frame.ImportantGlow:SetPoint("TOPLEFT", frame, "TOPLEFT", -15, 16)
                frame.ImportantGlow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 15, -6)
            end
        else
            -- Update border colors
            local border = BBF.auraBorders[frame]
            if border then
                border:SetBackdropBorderColor(colorValue, colorValue, colorValue)
            end
        end
    else
        -- Remove custom borders if they exist and revert the icon
        if BBF.auraBorders[frame] then
            BBF.auraBorders[frame]:Hide()
            BBF.auraBorders[frame]:SetParent(nil) -- Unparent the border
            BBF.auraBorders[frame] = nil -- Remove the reference

            local icon = frame.Icon
            if textureName then
                icon = frame[textureName]
            end
            icon:SetTexCoord(0, 1, 0, 1) -- Revert the icon to the original state
        end
    end
end

local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY or 32
local function ProcessBuffButtons()
    if BuffFrame.allAurasDarkMode then return end
    for i = 1, BUFF_MAX_DISPLAY do
        local buffButton = _G["BuffButton"..i]
        if buffButton then
            if not BBF.auraBorders[buffButton] then
                local icon = _G["BuffButton"..i.."Icon"]
                if icon then
                    if not buffButton.Icon then
                        buffButton.Icon = icon
                    end
                    createOrUpdateBorders(buffButton, BetterBlizzFramesDB.darkModeColor)
                end
                if i == BUFF_MAX_DISPLAY then
                    BuffFrame.allAurasDarkMode = true
                end
            end
        end
    end
end

function BBF.updateTotemBorders()
    local vertexColor = darkModeUi and BetterBlizzFramesDB.darkModeColor or 1
    for i = 1, TotemFrame:GetNumChildren() do
        local totemButton = select(i, TotemFrame:GetChildren())
        if totemButton and totemButton.Border then
            totemButton.Border:SetDesaturated(true)
            totemButton.Border:SetVertexColor(vertexColor, vertexColor, vertexColor) -- Set to dark color
        end
    end
end

function BBF.DarkmodeFrames(bypass)
    if not bypass and not BetterBlizzFramesDB.darkModeUi then return end

    BBF.CombatIndicatorCaller()

    local desaturationValue = BetterBlizzFramesDB.darkModeUi and true or false
    local vertexColor = BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeColor or 1
    local actionBarColor = BetterBlizzFramesDB.darkModeActionBars and (vertexColor + 0.25) or 1
    local birdColor = BetterBlizzFramesDB.darkModeActionBars and (vertexColor + 0.25) or 1

    local minimapColor = (BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeMinimap) and BetterBlizzFramesDB.darkModeColor or 1
    local minimapSat = (BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeMinimap) and true or false

    if BetterBlizzFramesDB.darkModeColor == 0 then
        actionBarColor = 0
        birdColor = 0.07
    end


    local function UpdateBorder(frame, colorValue)
        if BBF.auraBorders[frame] then
            if BetterBlizzFramesDB.darkModeUi then
                BBF.auraBorders[frame]:Show()
            else
                BBF.auraBorders[frame]:Hide()
            end
        end
    end

    -- Applying borders to BuffFrame
    if BuffFrame then
        if not BuffFrame.bbfHooked then
            if darkModeUi and darkModeUiAura then
                hooksecurefunc("BuffFrame_Update", ProcessBuffButtons)
                BuffFrame.bbfHooked = true
            end
        end
        for i = 1, BUFF_MAX_DISPLAY do
            local buffButton = _G["BuffButton"..i]
            if buffButton then
                local icon = _G["BuffButton"..i.."Icon"]
                if icon then
                    buffButton.Icon = icon
                end
                createOrUpdateBorders(buffButton, vertexColor)
            end
        end
    end

    if ToggleHiddenAurasButton then
        createOrUpdateBorders(ToggleHiddenAurasButton, vertexColor)
    end

    BBF.DarkModeUnitframeBorders()




    -- Applying settings based on BetterBlizzFramesDB.darkModeUi value
    applySettings(TargetFrameTextureFrameTexture, desaturationValue, vertexColor)
    applySettings(TargetFrameToTTextureFrameTexture, desaturationValue, vertexColor)
    applySettings(PetFrameTexture, desaturationValue, vertexColor)

    if TimeManagerClockButton then
        for i = 1, TimeManagerClockButton:GetNumRegions() do
            local region = select(i, TimeManagerClockButton:GetRegions())
            if region:IsObjectType("Texture") and region:GetName() ~= "" then
                applySettings(region, minimapSat, minimapColor)
            end
        end
    end

    local function checkAndApplySettings(object, minimapSat, minimapColor)
        if object:IsObjectType("Texture") then
            local texturePath = object:GetTexture()
            if texturePath and string.find(texturePath, "136430") then
                applySettings(object, minimapSat, minimapColor)
            end
        end

        if object.GetNumChildren and object:GetNumChildren() > 0 then
            for i = 1, object:GetNumChildren() do
                local child = select(i, object:GetChildren())
                if not child then return end
                checkAndApplySettings(child, minimapSat, minimapColor)
            end
        end

        if object.GetNumChildren and object:GetNumRegions() > 0 then
            for j = 1, object:GetNumRegions() do
                local region = select(j, object:GetRegions())
                checkAndApplySettings(region, minimapSat, minimapColor)
            end
        end
    end

    for i = 1, Minimap:GetNumChildren() do
        local child = select(i, Minimap:GetChildren())
        if not child then return end
        checkAndApplySettings(child, minimapSat, minimapColor)
    end


    --Minimap + and - zoom buttons
    local zoomOutButton = MinimapZoomOut
    local zoomInButton = MinimapZoomIn

    for _, button in ipairs({zoomOutButton, zoomInButton}) do
        for i = 1, button:GetNumRegions() do
            local region = select(i, button:GetRegions())
            if region:IsObjectType("Texture") then
                applySettings(region, minimapSat, minimapColor)
            end
        end
    end

    local compactPartyBorder = CompactPartyFrameBorderFrame or CompactRaidFrameContainerBorderFrame
    if compactPartyBorder then
        for i = 1, compactPartyBorder:GetNumRegions() do
            local region = select(i, compactPartyBorder:GetRegions())
            if region:IsObjectType("Texture") then
                applySettings(region, desaturationValue, vertexColor)
            end
        end
        for i = 1, 5 do
            local frame = _G["CompactRaidFrame"..i]
            if frame then
                applySettings(frame.horizDivider, desaturationValue, vertexColor)
                applySettings(frame.horizTopBorder, desaturationValue, vertexColor)
                applySettings(frame.horizBottomBorder, desaturationValue, vertexColor)
                applySettings(frame.vertLeftBorder, desaturationValue, vertexColor)
                applySettings(frame.vertRightBorder, desaturationValue, vertexColor)
            end
        end
    end

    applySettings(MinimapBorder, minimapSat, minimapColor)

    BBF.DarkModeCastbars()

    applySettings(PlayerFrameTexture, desaturationValue, vertexColor)

    -- Actionbars
    if BetterBlizzFramesDB.darkModeActionBars or BBF.actionBarColorEnabled then
        for i = 1, 12 do
            local buttons = {
                _G["ActionButton" .. i .. "NormalTexture"],
                _G["MultiBarBottomLeftButton" .. i .. "NormalTexture"],
                _G["MultiBarBottomRightButton" .. i .. "NormalTexture"],
                _G["MultiBarRightButton" .. i .. "NormalTexture"],
                _G["MultiBarLeftButton" .. i .. "NormalTexture"],
                _G["MultiBar5Button" .. i .. "NormalTexture"],
                _G["MultiBar6Button" .. i .. "NormalTexture"],
                _G["MultiBar7Button" .. i .. "NormalTexture"],
                _G["PetActionButton" .. i .. "NormalTexture"],
                _G["StanceButton" .. i .. "NormalTexture"]
            }

            for _, button in ipairs(buttons) do
                applySettings(button, desaturationValue, actionBarColor)
                BBF.HookVertexColor(button, actionBarColor, actionBarColor, actionBarColor, 1)
            end
        end



        for i = 0, 3 do
            local buttons = {
                _G["CharacterBag"..i.."SlotNormalTexture"],
                _G["MainMenuBarTexture"..i],
                _G["MainMenuBarTextureExtender"],
                _G["MainMenuMaxLevelBar"..i],
                _G["ReputationWatchBar"].StatusBar["XPBarTexture"..i],
                _G["MainMenuXPBarTexture"..i],
                _G["SlidingActionBarTexture"..i]
            }
            for _, button in ipairs(buttons) do
                applySettings(button, desaturationValue, actionBarColor)
                BBF.HookVertexColor(button, actionBarColor, actionBarColor, actionBarColor, 1)
            end
        end

        applySettings(MainMenuBarBackpackButtonNormalTexture, desaturationValue, actionBarColor)
        BBF.HookVertexColor(MainMenuBarBackpackButtonNormalTexture, actionBarColor, actionBarColor, actionBarColor, 1)


        for _, v in pairs({
            MainMenuBarLeftEndCap,
            MainMenuBarRightEndCap,
        }) do
            applySettings(v, desaturationValue, birdColor)
        end

        local BARTENDER4_NUM_MAX_BUTTONS = 180
        for i = 1, BARTENDER4_NUM_MAX_BUTTONS do
            local button = _G["BT4Button" .. i]
            if button then
                local normalTexture = button:GetNormalTexture()
                if normalTexture then
                    applySettings(normalTexture, desaturationValue, actionBarColor)
                end
            end
        end

        if BlizzardArtTex0 then
            for i = 0, 3 do
                local texture = _G["BlizzardArtTex"..i]
                if texture then
                    applySettings(texture, desaturationValue, actionBarColor)
                end
            end
        end

        local BARTENDER4_PET_BUTTONS = 10
        for i = 1, BARTENDER4_PET_BUTTONS do
            local button = _G["BT4PetButton" .. i]
            if button then
                local normalTexture = button:GetNormalTexture()
                if normalTexture then
                    applySettings(normalTexture, desaturationValue, actionBarColor)
                end
            end
        end

        if BT4BarBlizzardArt and BT4BarBlizzardArt.nineSliceParent then
            for _, child in ipairs({BT4BarBlizzardArt.nineSliceParent:GetChildren()}) do
                applySettings(child, desaturationValue, actionBarColor)
                local DividerArt = child:GetChildren()
                applySettings(DividerArt, desaturationValue, actionBarColor)
            end
        end

        -- Dominos actionbars
        local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
        local DOMINOS_NUM_MAX_BUTTONS = 14 * NUM_ACTIONBAR_BUTTONS
        local actionBars = {
            {name = "DominosActionButton", count = DOMINOS_NUM_MAX_BUTTONS},
            {name = "MultiBar5ActionButton", count = 12},
            {name = "MultiBar6ActionButton", count = 12},
            {name = "MultiBar7ActionButton", count = 12},
            {name = "MultiBarRightActionButton", count = 12},
            {name = "MultiBarLeftActionButton", count = 12},
            {name = "MultiBarBottomRightActionButton", count = 12},
            {name = "MultiBarBottomLeftActionButton", count = 12},
            {name = "DominosPetActionButton", count = 12},
            {name = "DominosStanceButton", count = 12},
            {name = "StanceButton", count = 6},
        }

        -- Loop through each bar and apply settings to its buttons
        for _, bar in ipairs(actionBars) do
            for i = 1, bar.count do
                local button = _G[bar.name .. i]
                if button then
                    local normalTexture = button:GetNormalTexture()
                    if normalTexture then
                        applySettings(normalTexture, desaturationValue, actionBarColor, true)
                    end
                end
            end
        end

        for _, v in pairs({BlizzardArtLeftCap, BlizzardArtRightCap}) do
            if v then
                applySettings(v, desaturationValue, birdColor)
            end
        end
        BBF.actionBarColorEnabled = true
    end

end




function BBF.UpdateFilteredBuffsIcon()
    if BetterBlizzFramesDB.darkModeUi then
        local vertexColor = BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeColor or 1
        if ToggleHiddenAurasButton then
            createOrUpdateBorders(ToggleHiddenAurasButton, vertexColor)
        end
    end
end


local specChangeListener = CreateFrame("Frame")
specChangeListener:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
specChangeListener:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_SPECIALIZATION_CHANGED" then
        if BetterBlizzFramesDB.darkModeUi then
            local unitID = ...
            if unitID == "player" then
                local vertexColor = BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeColor or 1
                local rogueCombo = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.45) or 1
                local rogueComboActive = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.30) or 1
                local rogueComboPoints = _G.RogueComboPointBarFrame
                if BetterBlizzFramesDB.darkModeColor == 0 then
                    rogueCombo = 0.25
                    rogueComboActive = 0.15
                end
                if rogueComboPoints then
                    for _, v in pairs({rogueComboPoints:GetChildren()}) do
                        applySettings(v.BGInactive, desaturationValue, rogueCombo)
                        applySettings(v.BGActive, desaturationValue, rogueComboActive)
                    end
                end
            end
        end
    end
end)

function BBF.CheckForAuraBorders()
    if not (BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeUiAura) then
        -- Define the maximum number of buffs and debuffs (change these numbers as needed)
        local maxBuffs = 32
        local maxDebuffs = 16

        -- Loop through buffs
        for i = 1, maxBuffs do
            local buffFrame = _G["BuffButton" .. i]
            if buffFrame then
                local iconTexture = _G[buffFrame:GetName() .. "Icon"]
                if iconTexture then
                    local borderColorValue
                    for j = 1, buffFrame:GetNumChildren() do
                        local child = select(j, buffFrame:GetChildren())
                        local bottomEdgeTexture = child.BottomEdge
                        if bottomEdgeTexture and bottomEdgeTexture:IsObjectType("Texture") then
                            local r, g, b, a = bottomEdgeTexture:GetVertexColor()
                            borderColorValue = r
                            break
                        end
                    end
                    if borderColorValue then
                        if ToggleHiddenAurasButton then
                            ToggleHiddenAurasButton.Icon:SetTexCoord(iconTexture:GetTexCoord())
                            createOrUpdateBorders(ToggleHiddenAurasButton, borderColorValue, nil, true)
                            return
                        end
                    end
                end
            end
        end

        -- Loop through debuffs
        for i = 1, maxDebuffs do
            local debuffFrame = _G["DebuffButton" .. i]
            if debuffFrame then
                local iconTexture = _G[debuffFrame:GetName() .. "Icon"]
                if iconTexture then
                    local borderColorValue
                    for j = 1, debuffFrame:GetNumChildren() do
                        local child = select(j, debuffFrame:GetChildren())
                        local bottomEdgeTexture = child.BottomEdge
                        if bottomEdgeTexture and bottomEdgeTexture:IsObjectType("Texture") then
                            local r, g, b, a = bottomEdgeTexture:GetVertexColor()
                            borderColorValue = r
                            break
                        end
                    end
                    if borderColorValue then
                        if ToggleHiddenAurasButton then
                            ToggleHiddenAurasButton.Icon:SetTexCoord(iconTexture:GetTexCoord())
                            createOrUpdateBorders(ToggleHiddenAurasButton, borderColorValue, nil, true)
                            return
                        end
                    end
                end
            end
        end
    end
end

function BBF.DarkModeCastbars()
    if BetterBlizzFramesDB.darkModeCastbars then
        local desaturationValue = BetterBlizzFramesDB.darkModeUi and true or false
        local vertexColor = BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeColor or 1
        local castbarBorder = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.1) or 1
        local lighterVertexColor = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.3) or 1
        BBF.darkModeCastbars = true

        applySettings(TargetFrame.spellbar.Border, desaturationValue, castbarBorder)
        applySettings(TargetFrame.spellbar.Background, desaturationValue, lighterVertexColor)

        applySettings(CastingBarFrame.Border, desaturationValue, castbarBorder)
        applySettings(CastingBarFrame.Background, desaturationValue, lighterVertexColor)

        if BetterBlizzFramesDB.showPartyCastbar then
            for i = 1, 5 do
                local partyCastbar = _G["Party"..i.."SpellBar"]
                if partyCastbar then
                    applySettings(partyCastbar.Border, desaturationValue, castbarBorder)
                    applySettings(partyCastbar.Background, desaturationValue, lighterVertexColor)
                end
            end
        end
        local petCastbar = _G["PetSpellBar"]
        if petCastbar then
            applySettings(petCastbar.Border, desaturationValue, castbarBorder)
            applySettings(petCastbar.Background, desaturationValue, lighterVertexColor)
        end
    elseif BBF.darkModeCastbars then
        applySettings(TargetFrame.spellbar.Border, false, 1)
        applySettings(TargetFrame.spellbar.Background, false, 1)

        applySettings(CastingBarFrame.Border, false, 1)
        applySettings(CastingBarFrame.Background, false, 1)

        if BetterBlizzFramesDB.showPartyCastbar then
            for i = 1, 5 do
                local partyCastbar = _G["Party"..i.."SpellBar"]
                if partyCastbar then
                    applySettings(partyCastbar.Border, false, 1)
                    applySettings(partyCastbar.Background, false, 1)
                end
            end
        end
        local petCastbar = _G["PetSpellBar"]
        if petCastbar then
            applySettings(petCastbar.Border, false, 1)
            applySettings(petCastbar.Background, false, 1)
        end
        BBF.darkModeCastbars = nil
    end
end