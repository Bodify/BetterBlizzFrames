local darkModeUi
local darkModeUiAura
local darkModeColor = 1
local removeDebuffColorBorder
local hookedAuras

local function createIconBorder(parent, icon, edgeSize, offsets)
    local border = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    border:SetBackdrop({
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tileEdge = true,
        edgeSize = edgeSize,
    })
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    border:SetPoint("TOPLEFT", icon, "TOPLEFT", offsets[1], offsets[2])
    border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", offsets[3], offsets[4])
    return border
end

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
    darkModeColor = BetterBlizzFramesDB.darkModeColor
    removeDebuffColorBorder = BetterBlizzFramesDB.removeDebuffColorBorder
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
                        auraFrame.border = createIconBorder(auraFrame, icon, 8.5, {-1.5, 1.5, 1.5, -2})
                        auraFrame.border:SetBackdropBorderColor(darkModeColor, darkModeColor, darkModeColor)
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
                            auraFrame.border = createIconBorder(auraFrame, icon, 8.5, {-1.5, 2, 1.5, -2})
                            auraFrame.border:SetBackdropBorderColor(darkModeColor, darkModeColor, darkModeColor)
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
            local icon = frame.Icon
            if textureName then
                icon = frame[textureName]
            end

            local border
            if not bypass then
                border = createIconBorder(frame, icon, 8, {-1.5, 2, 1.5, -1.5})
            else
                border = createIconBorder(frame, icon, 10, {-2, 2, 2, -2})
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

function BBF.DarkModeMinimap()
    local minimapColor = (BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeMinimap) and BetterBlizzFramesDB.darkModeColor or 1
    local minimapSat = (BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeMinimap) and true or false

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

    for _, button in ipairs({MinimapZoomOut, MinimapZoomIn}) do
        for i = 1, button:GetNumRegions() do
            local region = select(i, button:GetRegions())
            if region:IsObjectType("Texture") then
                applySettings(region, minimapSat, minimapColor)
            end
        end
    end

    applySettings(MinimapBorder, minimapSat, minimapColor)
    applySettings(MinimapBorderTop, minimapSat, minimapColor)
end

function BBF.DarkmodeFrames(bypass)
    if not bypass and not BetterBlizzFramesDB.darkModeUi then return end

    BBF.CombatIndicatorCaller()

    local desaturationValue = BetterBlizzFramesDB.darkModeUi and true or false
    local vertexColor = BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeColor or 1

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

    BBF.DarkModeMinimap()

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

    BBF.DarkModeCastbars()

    applySettings(PlayerFrameTexture, desaturationValue, vertexColor)

    BBF.DarkModeActionBars()

end

local function darkModeBlizzardActionBars(desaturationValue, actionBarColor, birdColor)
    for i = 1, NUM_ACTIONBAR_BUTTONS do
        local buttons = {
            _G["ActionButton" .. i .. "NormalTexture"],
            _G["MultiBarBottomLeftButton" .. i .. "NormalTexture"],
            _G["MultiBarBottomRightButton" .. i .. "NormalTexture"],
            _G["MultiBarRightButton" .. i .. "NormalTexture"],
            _G["MultiBarLeftButton" .. i .. "NormalTexture"],
            _G["MultiBar5Button" .. i .. "NormalTexture"],
            _G["MultiBar6Button" .. i .. "NormalTexture"],
            _G["MultiBar7Button" .. i .. "NormalTexture"],
        }

        for _, button in ipairs(buttons) do
            applySettings(button, desaturationValue, actionBarColor)
            BBF.HookVertexColor(button, actionBarColor, actionBarColor, actionBarColor, 1)
        end
    end

    for i = 1, NUM_PET_ACTION_SLOTS do
        local button = _G["PetActionButton" .. i .. "NormalTexture"]
        applySettings(button, desaturationValue, actionBarColor)
        BBF.HookVertexColor(button, actionBarColor, actionBarColor, actionBarColor, 1)
    end

    for i = 1, NUM_STANCE_SLOTS do
        local button = _G["StanceButton" .. i .. "NormalTexture"]
        applySettings(button, desaturationValue, actionBarColor)
        BBF.HookVertexColor(button, actionBarColor, actionBarColor, actionBarColor, 1)
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
end

local function darkModeBartender4(desaturationValue, actionBarColor)
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
end

local function darkModeDominos(desaturationValue, actionBarColor, birdColor)
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
end

function BBF.DarkModeActionBars()
    if not (BetterBlizzFramesDB.darkModeActionBars or BBF.actionBarColorEnabled) then return end

    local desaturationValue = BetterBlizzFramesDB.darkModeUi and true or false
    local vertexColor = BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeColor or 1
    local actionBarColor = BetterBlizzFramesDB.darkModeActionBars and (vertexColor + 0.25) or 1
    local birdColor = BetterBlizzFramesDB.darkModeActionBars and (vertexColor + 0.25) or 1

    if BetterBlizzFramesDB.darkModeColor == 0 then
        actionBarColor = 0
        birdColor = 0.07
    end

    darkModeBlizzardActionBars(desaturationValue, actionBarColor, birdColor)
    darkModeBartender4(desaturationValue, actionBarColor)
    darkModeDominos(desaturationValue, actionBarColor, birdColor)

    BBF.actionBarColorEnabled = true
end

function BBF.UpdateFilteredBuffsIcon()
    if BetterBlizzFramesDB.darkModeUi then
        local vertexColor = BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeColor or 1
        if ToggleHiddenAurasButton then
            createOrUpdateBorders(ToggleHiddenAurasButton, vertexColor)
        end
    end
end

function BBF.CheckForAuraBorders()
    if not (BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeUiAura) then
        local function searchAuraFrames(prefix, count)
            for i = 1, count do
                local frame = _G[prefix .. i]
                if frame then
                    local iconTexture = _G[frame:GetName() .. "Icon"]
                    if iconTexture then
                        local borderColorValue
                        for j = 1, frame:GetNumChildren() do
                            local child = select(j, frame:GetChildren())
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
                                return true
                            end
                        end
                    end
                end
            end
        end

        if searchAuraFrames("BuffButton", 32) then return end
        searchAuraFrames("DebuffButton", 16)
    end
end

local function updateCastbarIconBorder(castbar, enabled, colorValue)
    if not castbar or not castbar.Icon then return end
    if enabled then
        if not castbar.bbfIconBorder then
            castbar.bbfIconBorder = createIconBorder(castbar, castbar.Icon, 8.5, {-1.5, 1.5, 1.5, -2})
        end
        castbar.bbfIconBorder:SetBackdropBorderColor(colorValue, colorValue, colorValue)
    elseif castbar.bbfIconBorder then
        castbar.bbfIconBorder:Hide()
        castbar.bbfIconBorder:SetParent(nil)
        castbar.bbfIconBorder = nil
        castbar.Icon:SetTexCoord(0, 1, 0, 1)
    end
end

function BBF.DarkModeCastbars()
    local enabled = BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeCastbars
    if not enabled and not BBF.darkModeCastbars then return end

    local desat = enabled and true or false
    local vertexColor = enabled and BetterBlizzFramesDB.darkModeColor or 1
    local borderColor = enabled and (vertexColor + 0.1) or 1
    local bgColor = enabled and (vertexColor + 0.3) or 1

    applySettings(TargetFrame.spellbar.Border, desat, borderColor)
    applySettings(TargetFrame.spellbar.Background, desat, bgColor)

    updateCastbarIconBorder(TargetFrame.spellbar, enabled, borderColor)

    applySettings(CastingBarFrame.Border, desat, borderColor)
    applySettings(CastingBarFrame.Background, desat, bgColor)
    updateCastbarIconBorder(CastingBarFrame, enabled, borderColor)

    if BetterBlizzFramesDB.showPartyCastbar then
        for i = 1, 5 do
            local partyCastbar = _G["Party"..i.."SpellBar"]
            if partyCastbar then
                applySettings(partyCastbar.Border, desat, borderColor)
                applySettings(partyCastbar.Background, desat, bgColor)
                updateCastbarIconBorder(partyCastbar, enabled, borderColor)
            end
        end
    end
    local petCastbar = _G["PetSpellBar"]
    if petCastbar then
        applySettings(petCastbar.Border, desat, borderColor)
        applySettings(petCastbar.Background, desat, bgColor)
        updateCastbarIconBorder(petCastbar, enabled, borderColor)
    end

    BBF.darkModeCastbars = enabled or nil
end
