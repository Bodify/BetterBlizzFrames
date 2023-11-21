-- Setting up the database
BetterBlizzFramesDB = BetterBlizzFramesDB or {}
BBF = BBF or {}

function BBF.CombatIndicator(unitFrame, unit)
    if not BetterBlizzFramesDB.combatIndicator or not unitFrame then return end

    local settingsPrefix = unit --== "player" and "player" or "target"
    local combatIndicatorOn = BetterBlizzFramesDB[settingsPrefix .. "CombatIndicator"]
    if not combatIndicatorOn then return end

    local xPos = BetterBlizzFramesDB.combatIndicatorXPos - 20
    local yPos = BetterBlizzFramesDB.combatIndicatorYPos
    local mainAnchor = BetterBlizzFramesDB.combatIndicatorAnchor
    local reverseAnchor = BBF.GetOppositeAnchor(mainAnchor)
    local inCombat = UnitAffectingCombat(unit)
    local inInstance, instanceType = IsInInstance()
    local darkModeOn = BetterBlizzFramesDB.darkModeUi
    local vertexColor = darkModeOn and BetterBlizzFramesDB.darkModeColor or 1

    if not unitFrame.combatParent then
        unitFrame.combatParent = CreateFrame("Frame", nil, unitFrame, "BackdropTemplate")
        unitFrame.combatParent:SetSize(32, 32)
        unitFrame.combatParent:SetPoint("CENTER", unitFrame, "CENTER", xPos, yPos)
        unitFrame.combatParent:SetFrameStrata("HIGH")

        -- Create the combat indicator texture within the parent frame
        unitFrame.combatIndicator = unitFrame.combatParent:CreateTexture(nil, "OVERLAY")
        unitFrame.combatIndicator:SetSize(32, 32)
        unitFrame.combatIndicator:SetPoint("CENTER", unitFrame.combatParent, "CENTER")

        -- Create the border within the parent frame
        local border = CreateFrame("Frame", nil, unitFrame.combatParent, "BackdropTemplate")
        border:SetBackdrop({
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tileEdge = true,
            edgeSize = 8,
        })
        border:SetPoint("TOPLEFT", unitFrame.combatIndicator, "TOPLEFT", -1.5, 1.5)
        border:SetPoint("BOTTOMRIGHT", unitFrame.combatIndicator, "BOTTOMRIGHT", 1.5, -1.5)
        border:SetFrameLevel(unitFrame.combatParent:GetFrameLevel() + 1)
        unitFrame.combatIndicator.border = border
    end

    if darkModeOn then
        unitFrame.combatIndicator:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        unitFrame.combatIndicator.border:SetBackdropBorderColor(vertexColor, vertexColor, vertexColor)
        unitFrame.combatIndicator.border:Hide()
    else
        unitFrame.combatIndicator:SetTexCoord(0, 1, 0, 1)
        unitFrame.combatIndicator.border:Hide()
    end

    unitFrame.combatIndicator:ClearAllPoints()

    if unitFrame == PlayerFrame then
        xPos = xPos * -1 -- invert the xPos value for PlayerFrame
    end
    if mainAnchor == "LEFT" then
        if unitFrame == TargetFrame or unitFrame == FocusFrame then
            xPos = xPos + 38.5
            yPos = yPos - 6.5
        else
            xPos = xPos - 35
            yPos = yPos - 7
        end
    end

    if unitFrame == PlayerFrame then
        if mainAnchor == "TOP" or mainAnchor == "BOTTOM" then
            unitFrame.combatIndicator:SetPoint(reverseAnchor, unitFrame, mainAnchor, xPos - 3, yPos)
        else
            unitFrame.combatIndicator:SetPoint(mainAnchor, unitFrame, reverseAnchor, xPos - 3, yPos)
        end
    else
        unitFrame.combatIndicator:SetPoint(reverseAnchor, unitFrame, mainAnchor, xPos, yPos)
    end
    unitFrame.combatIndicator:SetScale(BetterBlizzFramesDB.combatIndicatorScale)



    -- Conditions to check before showing textures
    if BetterBlizzFramesDB.combatIndicatorArenaOnly and not (inInstance and instanceType == "arena") then
        unitFrame.combatIndicator:Hide()
        return
    end

    if BetterBlizzFramesDB.combatIndicatorPlayersOnly and not UnitIsPlayer(unit) then
        unitFrame.combatIndicator:Hide()
        return
    end

    -- Show or hide textures based on combat status
    if inCombat then
        if BetterBlizzFramesDB.combatIndicatorShowSwords then
            unitFrame.combatIndicator:SetTexture("Interface\\Icons\\ABILITY_DUALWIELD")
            unitFrame.combatIndicator:Show()
            if unitFrame.combatIndicator:IsVisible() and darkModeOn then
                unitFrame.combatIndicator.border:Show()
            end
        else
            unitFrame.combatIndicator:Hide()
        end
    else
        if BetterBlizzFramesDB.combatIndicatorShowSap then
            unitFrame.combatIndicator:SetTexture("Interface\\Icons\\Ability_Sap")
            unitFrame.combatIndicator:Show()
            if unitFrame.combatIndicator:IsVisible() and darkModeOn then
                unitFrame.combatIndicator.border:Show()
            end
        else
            unitFrame.combatIndicator:Hide()
        end
    end
end



function BBF.CombatIndicatorCaller()
    BBF.CombatIndicator(TargetFrame, "target")
    BBF.CombatIndicator(FocusFrame, "focus")
    BBF.CombatIndicator(PlayerFrame, "player")
    if not BetterBlizzFramesDB.combatIndicator then
        if TargetFrame.combatIndicator then TargetFrame.combatIndicator:Hide() TargetFrame.combatIndicator.border:Hide() end
        if PlayerFrame.combatIndicator then PlayerFrame.combatIndicator:Hide() PlayerFrame.combatIndicator.border:Hide() end
        if FocusFrame.combatIndicator then FocusFrame.combatIndicator:Hide() FocusFrame.combatIndicator.border:Hide() end
    end
    if not BetterBlizzFramesDB.playerCombatIndicator then
        if PlayerFrame.combatIndicator then PlayerFrame.combatIndicator:Hide() PlayerFrame.combatIndicator.border:Hide() end
    end
    if not BetterBlizzFramesDB.targetCombatIndicator then
        if TargetFrame.combatIndicator then TargetFrame.combatIndicator:Hide() TargetFrame.combatIndicator.border:Hide() end
    end
    if not BetterBlizzFramesDB.focusCombatIndicator then
        if FocusFrame.combatIndicator then FocusFrame.combatIndicator:Hide() FocusFrame.combatIndicator.border:Hide() end
    end
    --BBF:UpdateCombatBorder()
end




-- Event Listener for Combat Indicator
local combatIndicatorFrame = CreateFrame("Frame")
combatIndicatorFrame:SetScript("OnEvent", function()
    BBF.CombatIndicator(TargetFrame, "target")
    BBF.CombatIndicator(FocusFrame, "focus")
    BBF.CombatIndicator(PlayerFrame, "player")
end)
combatIndicatorFrame:RegisterEvent("UNIT_FLAGS")
combatIndicatorFrame:RegisterEvent("UNIT_COMBAT")
combatIndicatorFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
combatIndicatorFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
combatIndicatorFrame:RegisterEvent("PLAYER_ENTERING_WORLD")