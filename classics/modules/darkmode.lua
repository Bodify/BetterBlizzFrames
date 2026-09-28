local darkModeUi
local darkModeUiAura
local darkModeColor = 1
local removeDebuffColorBorder
local raidBorderSat, raidBorderColor = false, 1
local hookedAuras
local raidUpdates
local BuffFrame = BuffFrame

local function ReapplyDarkModeColor(self)
    if not self.bbfDarkColor then return end
    if self.changing or self:IsProtected() then return end
    local color = self.bbfDarkColor
    self.changing = true
    if self.bbfDarkDesat ~= nil and self.SetDesaturated then
        self:SetDesaturated(self.bbfDarkDesat)
    end
    self:SetVertexColor(color, color, color, 1)
    self.changing = false
end

local function applySettings(frame, desaturate, colorValue, hook)
    if frame then
        if hook and frame.SetVertexColor then
            if colorValue == 1 and not desaturate then
                frame.bbfDarkColor = nil
            else
                frame.bbfDarkColor = colorValue
                frame.bbfDarkDesat = desaturate
            end
            if not frame.bbfHooked then
                frame.bbfHooked = true
                hooksecurefunc(frame, "SetVertexColor", ReapplyDarkModeColor)
            end
        end

        if desaturate ~= nil and frame.SetDesaturated then
            frame:SetDesaturated(desaturate)
        end

        if frame.SetVertexColor then
            frame:SetVertexColor(colorValue, colorValue, colorValue)
        end
    end
end

local function OnSetVertexColorHookScript(frame, _, _, _, _, flag)
    local color = frame.bbfHookColor
    if color and flag ~= "BBFHookSetVertexColor" then
        frame:SetVertexColor(color[1], color[2], color[3], color[4], "BBFHookSetVertexColor")
    end
end

function BBF.HookVertexColor(frame, r, g, b, a)
    if not frame then return end
    if r == 1 and g == 1 and b == 1 then
        frame.bbfHookColor = nil
    else
        frame.bbfHookColor = { r, g, b, a }
    end
    frame:SetVertexColor(r, g, b, a, "BBFHookSetVertexColor")

    if not frame.BBFHookSetVertexColor then
        hooksecurefunc(frame, "SetVertexColor", OnSetVertexColorHookScript)
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
    if not (darkModeUi and darkModeUiAura) then
        for auraFrame in pairs(hooked) do
            if auraFrame.border then
                auraFrame.border:Hide()
            end
            if auraFrame.Icon then
                auraFrame.Icon:SetTexCoord(0, 1, 0, 1)
            end
            if auraFrame.Border then
                auraFrame.Border:Show()
            end
        end
        return
    end

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
                    auraFrame.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
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
                    auraFrame.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
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
            hooksecurefunc(FocusFrame, "UpdateAuras", function(self)
                UpdateFrameAuras(self)
            end)
        end
        hookedAuras = true
    end
    if hookedAuras then
        UpdateFrameAuras(TargetFrame)
        if FocusFrame then
            UpdateFrameAuras(FocusFrame)
        end
    end
end

BBF.auraBorders = {}
local function createOrUpdateBorders(frame, colorValue, textureName, bypass)
    if (darkModeUi and darkModeUiAura) or bypass then
        if not BBF.auraBorders[frame] then
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
            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

            if not bypass then
                border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1.5, 2)
                border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1.5, -1.5)
            else
                border:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
                border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
            end
            border:SetBackdropBorderColor(colorValue, colorValue, colorValue)

            BBF.auraBorders[frame] = border
            if frame.ImportantGlow then
                frame.ImportantGlow:SetParent(border)
                frame.ImportantGlow:SetPoint("TOPLEFT", frame, "TOPLEFT", -15, 16)
                frame.ImportantGlow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 15, -6)
            end
        else
            local border = BBF.auraBorders[frame]
            if border then
                border:SetBackdropBorderColor(colorValue, colorValue, colorValue)
            end
        end
    else
        if BBF.auraBorders[frame] then
            BBF.auraBorders[frame]:Hide()
            BBF.auraBorders[frame]:SetParent(nil)
            BBF.auraBorders[frame] = nil

            local icon = frame.Icon
            if textureName then
                icon = frame[textureName]
            end
            icon:SetTexCoord(0, 1, 0, 1)
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
            totemButton.Border:SetVertexColor(vertexColor, vertexColor, vertexColor)
        end
    end
end

local function DesaturateRegionsExcludingIcon(frame, iconTexture, color, desaturate)
    if not frame then return end

    for _, region in ipairs({ frame:GetRegions() }) do
        if region:IsObjectType("Texture") and region ~= iconTexture then
            region:SetDesaturated(desaturate)
            region:SetVertexColor(color, color, color)
        end
    end

    for _, child in ipairs({ frame:GetChildren() }) do
        DesaturateRegionsExcludingIcon(child, iconTexture, color, desaturate)
    end
end

local function ColorCompactUnitFrameBorders(frame)
    if not frame then return end
    if not raidBorderSat and not frame.bbfDarkmode then return end
    applySettings(frame.horizDivider, raidBorderSat, raidBorderColor)
    applySettings(frame.horizTopBorder, raidBorderSat, raidBorderColor)
    applySettings(frame.horizBottomBorder, raidBorderSat, raidBorderColor)
    applySettings(frame.vertLeftBorder, raidBorderSat, raidBorderColor)
    applySettings(frame.vertRightBorder, raidBorderSat, raidBorderColor)
    frame.bbfDarkmode = raidBorderSat or nil
end

function BBF.DarkmodeFrames(bypass)
    BBF.UpdateUserDarkModeSettings()
    if not bypass and not BetterBlizzFramesDB.darkModeUi then return end

    BBF.CombatIndicatorCaller()

    local desaturationValue = BetterBlizzFramesDB.darkModeUi and true or false
    local vertexColor = BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeColor or 1
    local lighterVertexColor = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.3) or 1
    local druidComboPoint = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.2) or 1
    local druidComboPointActive = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.1) or 1
    local actionBarOn = BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeActionBars and true or false
    local actionBarSat = actionBarOn
    local actionBarColor = actionBarOn and (vertexColor + 0.25) or 1
    local birdColor = actionBarOn and (vertexColor + 0.25) or 1
    local rogueCombo = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.45) or 1
    local rogueComboActive = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.30) or 1
    local monkChi = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.10) or 1
    local castbarBorder = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.1) or 1
    local color25 = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.25) or 1
    local unitFramesOn = BBF.DarkModeUnitFramesOn()
    local frameSat = unitFramesOn
    local frameColor = unitFramesOn and vertexColor or 1

    local minimapColor = (BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeMinimap) and BetterBlizzFramesDB.darkModeColor or 1
    local minimapSat = (BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeMinimap) and true or false

    local darkModeNpBBP = BetterBlizzPlatesDB and BetterBlizzPlatesDB.darkModeNameplateResource
    local darkModeNp = BetterBlizzFramesDB.darkModeNameplateResource and not darkModeNpBBP
    local darkModeNpSatVal = darkModeNp and desaturationValue or false

    if BetterBlizzFramesDB.darkModeColor == 0 then
        if actionBarOn then
            actionBarColor = 0
            birdColor = 0.07
        end
        rogueCombo = 0.25
        rogueComboActive = 0.15
    end

    if ComboFrame then
        local legacyComboColor = color25
        if BetterBlizzFramesDB.legacyComboColor then
            legacyComboColor = legacyComboColor + BetterBlizzFramesDB.legacyComboColor
        end
        for i = 1, 9 do
            local point = _G["ComboPoint"..i]
            if point and point:GetNumRegions() then
                for j = 1, point:GetNumRegions() do
                    local region = select(j, point:GetRegions())
                    if region and region:IsObjectType("Texture") then
                        local layer = region:GetDrawLayer()
                        if layer == "BACKGROUND" then
                            region:SetVertexColor(legacyComboColor, legacyComboColor, legacyComboColor)
                        end
                    end
                end
            end
        end
    end

    for i = 1, 4 do
        local totem = _G["TotemFrameTotem" .. i]
        if totem and totem.icon and totem.icon.texture then
            DesaturateRegionsExcludingIcon(totem, totem.icon.texture, vertexColor, desaturationValue)
        end
    end

    if BuffFrame and _G.BuffFrame.AuraContainer then
        for _, frame in pairs({_G.BuffFrame.AuraContainer:GetChildren()}) do
            createOrUpdateBorders(frame, vertexColor)
        end
    elseif BuffFrame then
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

    applySettings(TargetFrameTextureFrameTexture, frameSat, frameColor)
    applySettings(FocusFrameTextureFrameTexture, frameSat, frameColor)
    applySettings(TargetFrameToTTextureFrameTexture, frameSat, frameColor)
    applySettings(PetFrameTexture, frameSat, frameColor)
    applySettings(FocusFrameToTTextureFrameTexture, frameSat, frameColor)

    if TimeManagerClockButton then
        for i = 1, TimeManagerClockButton:GetNumRegions() do
            local region = select(i, TimeManagerClockButton:GetRegions())
            if region:IsObjectType("Texture") and region:GetName() ~= "" then
                applySettings(region, minimapSat, minimapColor)
            end
        end
    end

    if GameTimeTexture and GameTimeFrame then
        local ring = GameTimeFrame.bbfDarkRing
        if not ring and minimapSat then
            ring = GameTimeFrame:CreateTexture(nil, "ARTWORK", nil, 1)
            ring:SetTexture(GameTimeTexture:GetTexture())
            ring:SetAllPoints(GameTimeTexture)
            ring:SetTexCoord(GameTimeTexture:GetTexCoord())
            ring:SetAlpha(GameTimeTexture:GetAlpha())
            local mask = GameTimeFrame:CreateMaskTexture()
            mask:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\timeRingMask.tga", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            mask:SetAllPoints(GameTimeTexture)
            ring:AddMaskTexture(mask)
            hooksecurefunc(GameTimeTexture, "SetTexCoord", function(self)
                ring:SetTexCoord(self:GetTexCoord())
            end)
            hooksecurefunc(GameTimeTexture, "SetAlpha", function(self)
                ring:SetAlpha(self:GetAlpha())
            end)
            hooksecurefunc(GameTimeTexture, "Show", function()
                ring:SetShown(ring.bbfEnabled)
            end)
            hooksecurefunc(GameTimeTexture, "Hide", function()
                ring:Hide()
            end)
            GameTimeFrame.bbfDarkRing = ring
        end
        if ring then
            ring.bbfEnabled = minimapSat
            ring:SetShown(minimapSat and GameTimeTexture:IsShown())
            applySettings(ring, minimapSat, minimapColor)
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

    for i = 1, MinimapBackdrop:GetNumChildren() do
        local child = select(i, MinimapBackdrop:GetChildren())
        if not child then return end
        checkAndApplySettings(child, minimapSat, minimapColor)
    end

    for i = 1, Minimap:GetNumChildren() do
        local child = select(i, Minimap:GetChildren())
        if not child then return end
        checkAndApplySettings(child, minimapSat, minimapColor)
    end

    for i = 1, TimeManagerClockButton:GetNumChildren() do
        local child = select(i, Minimap:GetChildren())
        for j = 1, child:GetNumRegions() do
            local region = select(j, child:GetRegions())
            if region:IsObjectType("Texture") then
                local texturePath = region:GetTexture()
                if texturePath and string.find(texturePath, "136430") then
                    applySettings(region, minimapSat, minimapColor)
                end
                applySettings(region, minimapSat, minimapColor)
            end
        end
    end


    local zoomOutButton = MinimapZoomOut
    local zoomInButton = MinimapZoomIn

    for i = 1, zoomOutButton:GetNumRegions() do
        local region = select(i, zoomOutButton:GetRegions())
        if region:IsObjectType("Texture") then
            applySettings(region, minimapSat, minimapColor)
        end
    end

    for i = 1, zoomInButton:GetNumRegions() do
        local region = select(i, zoomInButton:GetRegions())
        if region:IsObjectType("Texture") then
            applySettings(region, minimapSat, minimapColor)
        end
    end

    local compactPartyBorder = CompactPartyFrameBorderFrame or CompactRaidFrameContainerBorderFrame
    if compactPartyBorder then
        raidBorderSat, raidBorderColor = desaturationValue, vertexColor

        for i = 1, compactPartyBorder:GetNumRegions() do
            local region = select(i, compactPartyBorder:GetRegions())
            if region:IsObjectType("Texture") then
                applySettings(region, desaturationValue, vertexColor)
            end
        end

        for i = 1, 40 do
            local frame = _G["CompactRaidFrame"..i]
            if frame then
                ColorCompactUnitFrameBorders(frame)
            end
        end

        if not raidUpdates then
            if C_CVar.GetCVar("raidOptionDisplayPets") == "1" or C_CVar.GetCVar("raidOptionDisplayMainTankAndAssist") == "1" then
                hooksecurefunc("DefaultCompactMiniFrameSetup", function(frame)
                    ColorCompactUnitFrameBorders(frame)
                end)
            end
            hooksecurefunc("CompactUnitFrame_SetUnit", function(frame)
                ColorCompactUnitFrameBorders(frame)
            end)
            raidUpdates = true
        end
    end


    applySettings(MinimapBorder, minimapSat, minimapColor)

    BBF.DarkModeCastbars()



    for _, v in pairs({
        PlayerFrameTexture,
    }) do
        applySettings(v, frameSat, frameColor)
    end
    BBF.RefreshSelfEliteTargets()
    BBF.UpdateClassicEliteOverlay(TargetFrame)
    BBF.UpdateClassicEliteOverlay(FocusFrame)

    if PartyFrame and PartyFrame.MemberFrame1 then
        for i = 1, 4 do
            local partyMemberFrame = PartyFrame["MemberFrame"..i]
            applySettings(partyMemberFrame.PartyMemberOverlay.Texture, frameSat, frameColor)
        end
    elseif PartyMemberFrame1 then
        for i = 1, 4 do
            local partyMemberFrame = _G["PartyMemberFrame"..i]
            applySettings(partyMemberFrame.Texture, frameSat, frameColor)
        end
    end

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
                applySettings(button, actionBarSat, actionBarColor)
                BBF.HookVertexColor(button, actionBarColor, actionBarColor, actionBarColor, 1)
            end
        end



        for i = 0, 3 do
            local buttons = {
                _G["CharacterBag"..i.."SlotNormalTexture"],
                _G["MainMenuBarTexture"..i],
                _G["MainMenuBarTextureExtender"],
                _G["MainMenuMaxLevelBar"..i],
                _G["ReputationWatchBar"] and _G["ReputationWatchBar"].StatusBar["XPBarTexture"..i],
                _G["MainMenuXPBarTexture"..i],
                _G["SlidingActionBarTexture"..i]
            }
            for _, button in ipairs(buttons) do
                applySettings(button, actionBarSat, actionBarColor)
                BBF.HookVertexColor(button, actionBarColor, actionBarColor, actionBarColor, 1)
            end
        end

        applySettings(MainMenuBarBackpackButtonNormalTexture, actionBarSat, actionBarColor)
        BBF.HookVertexColor(MainMenuBarBackpackButtonNormalTexture, actionBarColor, actionBarColor, actionBarColor, 1)

        local endCaps = MainActionBar and MainActionBar.EndCaps
        for _, v in pairs({
            MainMenuBarLeftEndCap,
            MainMenuBarRightEndCap,
            endCaps and endCaps.LeftEndCap,
            endCaps and endCaps.RightEndCap,
        }) do
            applySettings(v, actionBarSat, birdColor)
        end

        local BARTENDER4_NUM_MAX_BUTTONS = 180
        for i = 1, BARTENDER4_NUM_MAX_BUTTONS do
            local button = _G["BT4Button" .. i]
            if button then
                local normalTexture = button:GetNormalTexture()
                if normalTexture then
                    applySettings(normalTexture, actionBarSat, actionBarColor)
                end
            end
        end

        if BlizzardArtTex0 then
            for i = 0, 3 do
                local texture = _G["BlizzardArtTex"..i]
                if texture then
                    applySettings(texture, actionBarSat, actionBarColor)
                end
            end
        end

        if MainMenuBarMaxLevelBar then
            for i = 0, 3 do
                local texture = _G["MainMenuMaxLevelBar"..i]
                if texture then
                    applySettings(texture, actionBarSat, actionBarColor)
                end
            end
        end

        local BARTENDER4_PET_BUTTONS = 10
        for i = 1, BARTENDER4_PET_BUTTONS do
            local button = _G["BT4PetButton" .. i]
            if button then
                local normalTexture = button:GetNormalTexture()
                if normalTexture then
                    applySettings(normalTexture, actionBarSat, actionBarColor)
                end
            end
        end

        if BT4BarBlizzardArt and BT4BarBlizzardArt.nineSliceParent then
            for _, child in ipairs({BT4BarBlizzardArt.nineSliceParent:GetChildren()}) do
                applySettings(child, actionBarSat, actionBarColor)
                local DividerArt = child:GetChildren()
                applySettings(DividerArt, actionBarSat, actionBarColor)
            end
        end

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
                        applySettings(normalTexture, actionBarSat, actionBarColor, true)
                    end
                end
            end
        end

        for _, v in pairs({BlizzardArtLeftCap, BlizzardArtRightCap}) do
            if v then
                applySettings(v, actionBarSat, birdColor)
            end
        end

        BBF.actionBarColorEnabled = true
    end

    if PriestBarFrame then
        for i = 1, PriestBarFrame:GetNumRegions() do
            local region = select(i, PriestBarFrame:GetRegions())
            if region and region:IsObjectType("Texture") then
                local tex = region:GetTexture()
                if tex == 593367 then
                    applySettings(region, desaturationValue, vertexColor)
                end
            end
        end
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
                local desaturationValue = BetterBlizzFramesDB.darkModeUi and true or false
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
        local maxBuffs = 32
        local maxDebuffs = 16

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
    local CastingBarFrame = CastingBarFrame or PlayerCastingBarFrame
    if BetterBlizzFramesDB.darkModeCastbars then
        local desaturationValue = BetterBlizzFramesDB.darkModeUi and true or false
        local vertexColor = BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeColor or 1
        local castbarBorder = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.1) or 1
        local lighterVertexColor = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.3) or 1
        BBF.darkModeCastbars = true

        applySettings(TargetFrame.spellbar.Border, desaturationValue, castbarBorder)
        applySettings(TargetFrame.spellbar.Background, desaturationValue, lighterVertexColor)

        applySettings(FocusFrame.spellbar.Border, desaturationValue, castbarBorder)
        applySettings(FocusFrame.spellbar.Background, desaturationValue, lighterVertexColor)

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

        applySettings(FocusFrame.spellbar.Border, false, 1)
        applySettings(FocusFrame.spellbar.Background, false, 1)

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