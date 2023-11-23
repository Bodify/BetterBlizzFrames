-- Setting up the database
BetterBlizzFramesDB = BetterBlizzFramesDB or {}
BBF = BBF or {}

local function applySettings(frame, desaturate, colorValue)
    if frame then
        if desaturate ~= nil and frame.SetDesaturated then -- Check if SetDesaturated is available
            frame:SetDesaturated(desaturate)
        end
        if frame.SetVertexColor then
            frame:SetVertexColor(colorValue, colorValue, colorValue) -- Alpha set to 1
        end
    end
end

BBF.auraBorders = {}  -- BuffFrame aura borders for darkmode
local function createOrUpdateBorders(frame, colorValue, textureName)
    if (BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeUiAura) then
        if not BBF.auraBorders[frame] then
            -- Create borders
            local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
            border:SetBackdrop({
                edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                tileEdge = true,
                edgeSize = 8,
            })

            local icon = frame.Icon
            if textureName then
                icon = frame[textureName]
            end
            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Adjust the icon

            border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1.5, 2)
            border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1.5, -1.5)
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

function BBF.DarkmodeFrames()
    BBF.AbsorbCaller()
    BBF.CombatIndicatorCaller()
    local desaturationValue = BetterBlizzFramesDB.darkModeUi and true or false
    local vertexColor = BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeColor or 1
    local lighterVertexColor = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.15) or 1
    local birdColor = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.25) or 1
    local rogueCombo = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.45) or 1
    local monkChi = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.10) or 1

    if BetterBlizzFramesDB.darkModeColor == 0 then
        lighterVertexColor = 0
        birdColor = 0.07
        rogueCombo = 0.25
    end


    --MinimapCompassTexture:SetDesaturated(true)
    --MinimapCompassTexture:SetVertexColor(vertexColor, vertexColor, vertexColor)





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
        for _, frame in pairs({_G.BuffFrame.AuraContainer:GetChildren()}) do
            createOrUpdateBorders(frame, vertexColor)
        end
    end



    if ToggleHiddenAurasButton then
        createOrUpdateBorders(ToggleHiddenAurasButton, vertexColor)
    end

    --createOrUpdateBorders(TargetFrame, vertexColor, "absorbIcon")


--[[
    for unit, frame in pairs(BBF.combatIndicators) do
        createOrUpdateBorders(frame, vertexColor)
    end

    for unit, frame in pairs(BBF.absorbIndicators) do
        createOrUpdateBorders(frame, vertexColor)
    end

    function BBF.UpdateAbsorbBorder()
        for unit, frame in pairs(BBF.absorbIndicators) do
            UpdateBorder(frame, vertexColor)
        end
    end

    function BBF:UpdateCombatBorder()
        for unit, frame in pairs(BBF.combatIndicators) do
            UpdateBorder(frame, vertexColor)
        end
    end

]]

--asd
    BBF.DarkModeUnitframeBorders()




    -- Applying settings based on BetterBlizzFramesDB.darkModeUi value
    applySettings(TargetFrame.TargetFrameContainer.FrameTexture, desaturationValue, vertexColor)
    applySettings(FocusFrame.TargetFrameContainer.FrameTexture, desaturationValue, vertexColor)
    applySettings(TargetFrame.totFrame.FrameTexture, desaturationValue, vertexColor)
    applySettings(PetFrameTexture, desaturationValue, vertexColor)
    applySettings(FocusFrameToT.FrameTexture, desaturationValue, vertexColor)

    applySettings(PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon, desaturationValue, vertexColor)

    for _, v in pairs({
        PlayerFrame.PlayerFrameContainer.FrameTexture,
        PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture,
        PlayerFrame.PlayerFrameContainer.VehicleFrameTexture,
        PartyFrame.MemberFrame1.Texture,
        PartyFrame.MemberFrame2.Texture,
        PartyFrame.MemberFrame3.Texture,
        PartyFrame.MemberFrame4.Texture,
    }) do
        applySettings(v, desaturationValue, vertexColor)
    end
    for _, v in pairs({
        PaladinPowerBarFrame.Background,
        PaladinPowerBarFrame.ActiveTexture,
        PlayerFrameAlternateManaBarLeftBorder,
        PlayerFrameAlternateManaBarRightBorder,
        PlayerFrameAlternateManaBarBorder,
    }) do
        applySettings(v, false, vertexColor)  -- Only applying vertex color, desaturation is kept false
    end

    local runes = _G.RuneFrame
    if runes then
        for i = 1, 6 do
            applySettings(runes["Rune" .. i].BG_Active, desaturationValue, vertexColor)
            applySettings(runes["Rune" .. i].BG_Inactive, desaturationValue, vertexColor)
        end
    end

    local soulShards = _G.WarlockPowerFrame
    if soulShards then
        for _, v in pairs({soulShards:GetChildren()}) do
            applySettings(v.Background, desaturationValue, vertexColor)
        end
    end

    local druidComboPoints = _G.DruidComboPointBarFrame
    if druidComboPoints then
        for _, v in pairs({druidComboPoints:GetChildren()}) do
            applySettings(v.BG_Inactive, desaturationValue, vertexColor)
            applySettings(v.BG_Active, desaturationValue, vertexColor)
        end
    end

    local monkChiPoints = _G.MonkHarmonyBarFrame
    if monkChiPoints then
        for _, v in pairs({monkChiPoints:GetChildren()}) do
            applySettings(v.Chi_BG, desaturationValue, monkChi)
            applySettings(v.Chi_BG_Active, desaturationValue, monkChi)
        end
    end

    local monkNameplateChiPoints = _G.ClassNameplateBarWindwalkerMonkFrame
    if monkNameplateChiPoints then
        for _, v in pairs({monkNameplateChiPoints:GetChildren()}) do
            applySettings(v.Chi_BG, desaturationValue, monkChi)
            applySettings(v.Chi_BG_Active, desaturationValue, monkChi)
        end
    end

    local rogueComboPoints = _G.RogueComboPointBarFrame
    if rogueComboPoints then
        for _, v in pairs({rogueComboPoints:GetChildren()}) do
            applySettings(v.BGInactive, desaturationValue, rogueCombo)
            applySettings(v.BGActive, desaturationValue, rogueCombo)
        end
    end


    -- Actionbars
    for i = 1, 12 do
        applySettings(_G["ActionButton" .. i .. "NormalTexture"], desaturationValue, lighterVertexColor)
        applySettings(_G["MultiBarBottomLeftButton" .. i .. "NormalTexture"], desaturationValue, lighterVertexColor)
        applySettings(_G["MultiBarBottomRightButton" ..i.. "NormalTexture"], desaturationValue, lighterVertexColor)
        applySettings(_G["MultiBarRightButton" ..i.. "NormalTexture"], desaturationValue, lighterVertexColor)
        applySettings(_G["MultiBarLeftButton" ..i.. "NormalTexture"], desaturationValue, lighterVertexColor)
        applySettings(_G["MultiBar5Button" ..i.. "NormalTexture"], desaturationValue, lighterVertexColor)
        applySettings(_G["MultiBar6Button" ..i.. "NormalTexture"], desaturationValue, lighterVertexColor)
        applySettings(_G["MultiBar7Button" ..i.. "NormalTexture"], desaturationValue, lighterVertexColor)
        applySettings(_G["PetActionButton" ..i.. "NormalTexture"], desaturationValue, lighterVertexColor)
    end

    for _, v in pairs({
        MainMenuBar.BorderArt,
        ActionButton1.RightDivider,
        ActionButton2.RightDivider,
        ActionButton3.RightDivider,
        ActionButton4.RightDivider,
        ActionButton5.RightDivider,
        ActionButton6.RightDivider,
        ActionButton7.RightDivider,
        ActionButton8.RightDivider,
        ActionButton9.RightDivider,
        ActionButton10.RightDivider,
        ActionButton11.RightDivider,
    }) do
        applySettings(v, desaturationValue, lighterVertexColor)
    end

    for _, v in pairs({
        MainMenuBar.EndCaps.LeftEndCap,
        MainMenuBar.EndCaps.RightEndCap,
    }) do
        applySettings(v, desaturationValue, birdColor)
    end

    local BARTENDER4_NUM_MAX_BUTTONS = 180
    for i = 1, BARTENDER4_NUM_MAX_BUTTONS do
        local button = _G["BT4Button" .. i]
        if button then
            local normalTexture = button:GetNormalTexture()
            if normalTexture then
                applySettings(normalTexture, desaturationValue, lighterVertexColor)
            end
        end
    end

    local BARTENDER4_PET_BUTTONS = 10
    for i = 1, BARTENDER4_PET_BUTTONS do
        local button = _G["BT4PetButton" .. i]
        if button then
            local normalTexture = button:GetNormalTexture()
            if normalTexture then
                applySettings(normalTexture, desaturationValue, lighterVertexColor)
            end
        end
    end

    if BT4BarBlizzardArt and BT4BarBlizzardArt.nineSliceParent then
        for _, child in ipairs({BT4BarBlizzardArt.nineSliceParent:GetChildren()}) do
            applySettings(child, desaturationValue, lighterVertexColor)
            local DividerArt = child:GetChildren()
            applySettings(DividerArt, desaturationValue, lighterVertexColor)
        end
        for _, child in ipairs({BT4BarBlizzardArt:GetChildren()}) do
            --applySettings(child, desaturationValue, lighterVertexColor)
        end
    end

    for _, v in pairs({BlizzardArtLeftCap, BlizzardArtRightCap}) do
        if v then
            applySettings(v, desaturationValue, birdColor)
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


function BBF.updateTotemBorders()
    local darkModeOn = BetterBlizzFramesDB.darkModeUi
    if not darkModeOn then return end
    local vertexColor = BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeColor or 1
    for i = 1, TotemFrame:GetNumChildren() do
        local totemButton = select(i, TotemFrame:GetChildren())
        if totemButton and totemButton.Border then
            totemButton.Border:SetDesaturated(true)
            totemButton.Border:SetVertexColor(vertexColor, vertexColor, vertexColor) -- Set to dark color
        end
    end
end

hooksecurefunc(TotemFrame, "Update", function()
    BBF.updateTotemBorders()
end)

local hooked = {}

local function UpdateFrameAuras(pool)
    if not (BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeUiAura) then
        return
    end
    local vertexColor = BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeColor or 1

    for frame, _ in pairs(pool.activeObjects) do
        local icon = frame.Icon
        if not hooked[frame] then
            hooked[frame] = true


            if not frame.border then
                local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
                border:SetBackdrop({
                    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                    tileEdge = true,
                    edgeSize = 8.5,
                })

                icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1.5, 1.5)
                border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1.5, -2)

                --border:SetBackdropBorderColor(0.2, 0.2, 0.2)
                frame.border = border
                frame.darkBorder = true --test bodify
            end
        end
        if frame.border then
            frame.border:SetBackdropBorderColor(vertexColor, vertexColor, vertexColor)
        end
        if frame.Border or (frame.Stealable and frame.Stealable:IsVisible()) then
            frame.darkBorder = false
            if frame.border then
                frame.border:Hide()
                icon:SetTexCoord(0, 1, 0, 1)
            end
        else
            if frame.border then
                frame.border:Show()
                icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            end
        end
    end
end

local function ResetFrameAuras(pool)
    for frame, _ in pairs(pool.activeObjects) do
        if hooked[frame] then
            local icon = frame.Icon
            icon:SetTexCoord(0, 1, 0, 1)  -- Reset the icon's texture coordinates

            if frame.border then
                frame.border:Hide()  -- Hide the custom border
                frame.border = nil   -- Remove the border reference
            end

            hooked[frame] = nil  -- Unhook the frame
        end
    end
end

function BBF.DarkModeUnitframeBorders()
    local function ApplyToAllPools(func)
        for poolKey, pool in pairs(TargetFrame.auraPools.pools) do
            func(pool)
        end
        for poolKey, pool in pairs(FocusFrame.auraPools.pools) do
            func(pool)
        end
    end

    if (BetterBlizzFramesDB.darkModeUiAura and BetterBlizzFramesDB.darkModeUi) then
        ApplyToAllPools(UpdateFrameAuras)
    else
        ApplyToAllPools(ResetFrameAuras)
    end
end

for poolKey, pool in pairs(TargetFrame.auraPools.pools) do
    hooksecurefunc(pool, "Acquire", UpdateFrameAuras)
end

for poolKey, pool in pairs(FocusFrame.auraPools.pools) do
    hooksecurefunc(pool, "Acquire", UpdateFrameAuras)
end


local specChangeListener = CreateFrame("Frame")
specChangeListener:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
specChangeListener:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_SPECIALIZATION_CHANGED" then
        local unitID = ...
        if unitID == "player" then
            local vertexColor = BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeColor or 1
            local rogueCombo = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.55) or 1
            local rogueComboPoints = _G.RogueComboPointBarFrame
            if rogueComboPoints then
                for _, v in pairs({rogueComboPoints:GetChildren()}) do
                    applySettings(v.BGInactive, desaturationValue, rogueCombo)
                    applySettings(v.BGActive, desaturationValue, rogueCombo)
                end
            end
        end
    end
end)