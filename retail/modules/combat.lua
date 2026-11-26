local PLAYER_MIRROR = { x = 0, y = 0, innerX = 0, innerY = 0 }
local PLAYER_NO_PORTRAIT = { x = 0.5, y = 0, innerX = 0.5, innerY = 0 }
local PLAYER_TWEAK = { x = -3, y = 0, innerX = 0.5, innerY = -0.5 }

function BBF.PlayerMirrorsTarget()
    return BBF.HasNoPortrait("player")
end

function BBF.CombatIndicator(unitFrame, unit)
    if not BetterBlizzFramesDB.combatIndicator or not unitFrame then return end

    local settingsPrefix = unit
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

        unitFrame.combatIndicator = unitFrame.combatParent:CreateTexture(nil, "OVERLAY")
        unitFrame.combatIndicator:SetSize(32, 32)
        unitFrame.combatIndicator:SetPoint("CENTER", unitFrame.combatParent, "CENTER")

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

    local indicator = unitFrame.combatIndicator
    local round = BetterBlizzFramesDB.combatIndicatorRound and true or false
    if round and not indicator.round then
        local roundFrame = CreateFrame("Frame", nil, unitFrame.combatParent)
        roundFrame:SetPoint("CENTER", indicator, "CENTER")
        roundFrame.mask = unitFrame.combatParent:CreateMaskTexture()
        roundFrame.mask:SetTexture("Interface/Masks/CircleMaskScalable")
        roundFrame.mask:SetAllPoints(indicator)
        roundFrame.border = unitFrame.combatParent:CreateTexture(nil, "OVERLAY")
        indicator.round = roundFrame
        indicator.roundMasked = false
    end
    if indicator.round and indicator.roundMasked ~= round then
        indicator.roundMasked = round
        if round then
            indicator:AddMaskTexture(indicator.round.mask)
        else
            indicator:RemoveMaskTexture(indicator.round.mask)
        end
    end

    if darkModeOn or round then
        indicator:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    else
        indicator:SetTexCoord(0, 1, 0, 1)
    end
    indicator.border:SetBackdropBorderColor(vertexColor, vertexColor, vertexColor)
    indicator.border:SetAlpha(0)

    unitFrame.combatIndicator:ClearAllPoints()

    local inner = mainAnchor == "LEFT"
    if inner then
        xPos = xPos + 38.5
        yPos = yPos - 6.5
    end

    if unitFrame == PlayerFrame then
        local tweak = BBF.HasNoPortrait("player") and PLAYER_NO_PORTRAIT or BBF.PlayerMirrorsTarget() and PLAYER_MIRROR or PLAYER_TWEAK
        xPos = -xPos + (inner and tweak.innerX or tweak.x)
        yPos = yPos + (inner and tweak.innerY or tweak.y)
        if mainAnchor == "TOP" or mainAnchor == "BOTTOM" then
            unitFrame.combatIndicator:SetPoint(reverseAnchor, unitFrame, mainAnchor, xPos, yPos)
        else
            unitFrame.combatIndicator:SetPoint(mainAnchor, unitFrame, reverseAnchor, xPos, yPos)
        end
    else
        unitFrame.combatIndicator:SetPoint(reverseAnchor, unitFrame, mainAnchor, xPos, yPos)
    end
    unitFrame.combatIndicator:SetScale(BetterBlizzFramesDB.combatIndicatorScale)
    if round then
        local size = indicator:GetWidth() * BetterBlizzFramesDB.combatIndicatorScale
        indicator.round:SetSize(size, size)
        BBF.ColorRoundIndicatorBorder(indicator.round, unit)
    end

    local icon
    local arenaBlocked = BetterBlizzFramesDB.combatIndicatorArenaOnly and not (inInstance and instanceType == "arena")
    local npcBlocked = BetterBlizzFramesDB.combatIndicatorPlayersOnly and not UnitIsPlayer(unit)
    if not arenaBlocked and not npcBlocked then
        if inCombat then
            icon = BetterBlizzFramesDB.combatIndicatorShowSwords and "Interface\\Icons\\ABILITY_DUALWIELD"
        else
            icon = BetterBlizzFramesDB.combatIndicatorShowSap and "Interface\\Icons\\Ability_Sap"
        end
    end

    if icon then
        indicator:SetTexture(icon)
        indicator:SetAlpha(1)
        if darkModeOn and not round and indicator:IsVisible() then
            indicator.border:SetAlpha(1)
        end
    else
        indicator:SetAlpha(0)
    end
    if indicator.round then
        indicator.round.border:SetAlpha(icon and round and 1 or 0)
    end
end



function BBF.CombatIndicatorCaller()
    BBF.CombatIndicator(TargetFrame, "target")
    BBF.CombatIndicator(FocusFrame, "focus")
    BBF.CombatIndicator(PlayerFrame, "player")
    local combatIndicators = {
        { frame = TargetFrame, setting = "targetCombatIndicator" },
        { frame = PlayerFrame, setting = "playerCombatIndicator" },
        { frame = FocusFrame, setting = "focusCombatIndicator" },
    }

    for _, data in pairs(combatIndicators) do
        local frame, setting = data.frame, data.setting
        if frame and frame.combatIndicator then
            if not BetterBlizzFramesDB[setting] or not BetterBlizzFramesDB.combatIndicator then
                frame.combatIndicator:SetAlpha(0)
                if frame.combatIndicator.border then
                    frame.combatIndicator.border:SetAlpha(0)
                end
                if frame.combatIndicator.round then
                    frame.combatIndicator.round.border:SetAlpha(0)
                end
            end
        end
    end
    --BBF:UpdateCombatBorder()
end



function BBF.RacialIndicator(unitFrame, unit)
    if not unitFrame or not BetterBlizzFramesDB.racialIndicator then return end

    local settingsPrefix = unit
    local racialIndicatorOn = BetterBlizzFramesDB[settingsPrefix .. "RacialIndicator"]
    if not racialIndicatorOn then return end

    local xPos = BetterBlizzFramesDB.racialIndicatorXPos + 26
    local yPos = BetterBlizzFramesDB.racialIndicatorYPos + 20
    local scale = BetterBlizzFramesDB.racialIndicatorScale

    local raceOverSpells = BetterBlizzFramesDB.racialIndicatorRaceIcons

    local raceIcon, isAtlas, npcIcon, shouldShow
    if UnitIsPlayer(unit) then
        local _, raceToken = UnitRace(unit)
        if issecretvalue(raceToken) then return end
        local race = BBF.GetRacialIndicatorRace(raceToken)
        if race then
            raceIcon, isAtlas = BBF.GetRacialIndicatorIcon(race, UnitSex(unit), raceOverSpells)
        end
        shouldShow = race and BetterBlizzFramesDB[BBF.GetRacialIndicatorKey(race, unit)]
    else
        npcIcon = BetterBlizzFramesDB.racialIndicatorNpcs and BBF.GetRacialIndicatorCreatureIcon(unit)
        shouldShow = npcIcon
    end

    if not unitFrame.racialIndicator then
        unitFrame.racialIndicator = CreateFrame("Frame", nil, unitFrame, "BackdropTemplate")
        unitFrame.racialIndicator:SetSize(20, 20)
        unitFrame.racialIndicator:SetPoint("CENTER", unitFrame, "CENTER", 23, 21)
        unitFrame.racialIndicator:SetFrameStrata("HIGH")

        unitFrame.racialIndicator.icon = unitFrame.racialIndicator:CreateTexture(nil, "OVERLAY")
        unitFrame.racialIndicator.icon:SetAllPoints(unitFrame.racialIndicator)

        unitFrame.racialIndicator.mask = unitFrame.racialIndicator:CreateMaskTexture()
        unitFrame.racialIndicator.mask:SetTexture("Interface/Masks/CircleMaskScalable")
        unitFrame.racialIndicator.mask:SetSize(20, 20)
        unitFrame.racialIndicator.mask:SetPoint("CENTER", unitFrame.racialIndicator.icon)

        unitFrame.racialIndicator.icon:AddMaskTexture(unitFrame.racialIndicator.mask)

        unitFrame.racialIndicator.border = unitFrame.racialIndicator:CreateTexture(nil, "OVERLAY")
        unitFrame.racialIndicator.border:SetAtlas("ui-frame-genericplayerchoice-portrait-border")
        unitFrame.racialIndicator.border:SetAllPoints(unitFrame.racialIndicator)
        unitFrame.racialIndicator.border:SetDesaturated(true)
--[[
        -- Create the border within the parent frame
        local border = CreateFrame("Frame", nil, unitFrame.racialIndicator, "BackdropTemplate")
        border:SetBackdrop({
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tileEdge = true,
            edgeSize = 8,
        })
        border:SetPoint("TOPLEFT", unitFrame.racialIndicator.icon, "TOPLEFT", -1.5, 1.5)
        border:SetPoint("BOTTOMRIGHT", unitFrame.racialIndicator.icon, "BOTTOMRIGHT", 1.5, -1.5)
        border:SetFrameLevel(unitFrame.racialIndicator:GetFrameLevel() + 1)
        unitFrame.racialIndicator.border = border

]]
    end

    unitFrame.racialIndicator:SetPoint("CENTER", unitFrame, "CENTER", xPos, yPos)
    unitFrame.racialIndicator:SetScale(scale)
    if unitFrame.noPortraitMode then
        unitFrame.racialIndicator:SetFrameLevel(unitFrame.noPortraitMode:GetFrameLevel() + 2)
    end

    BBF.ColorRoundIndicatorBorder(unitFrame.racialIndicator, unit)

    if npcIcon then
        BBF.SetRacialIndicatorIcon(unitFrame.racialIndicator, npcIcon, false, true)
    elseif raceIcon then
        BBF.SetRacialIndicatorIcon(unitFrame.racialIndicator, raceIcon, isAtlas)
    end

    if shouldShow then
        unitFrame.racialIndicator:SetAlpha(1)
        --unitFrame.racialIndicator.border:SetAlpha(1)
    else
        unitFrame.racialIndicator:SetAlpha(0)
        --unitFrame.racialIndicator.border:SetAlpha(0)
    end
end

function BBF.RacialIndicatorCaller()
    BBF.RacialIndicator(TargetFrame, "target")
    BBF.RacialIndicator(FocusFrame, "focus")
    if not BetterBlizzFramesDB.racialIndicator then
        if TargetFrame.racialIndicator then TargetFrame.racialIndicator:SetAlpha(0) end
        if FocusFrame.racialIndicator then FocusFrame.racialIndicator:SetAlpha(0) end
    end
    if not BetterBlizzFramesDB.targetRacialIndicator then
        if TargetFrame.racialIndicator then TargetFrame.racialIndicator:SetAlpha(0) end
    end
    if not BetterBlizzFramesDB.focusRacialIndicator then
        if FocusFrame.racialIndicator then FocusFrame.racialIndicator:SetAlpha(0) end
    end
end



local unitFrameMap = {
    player = PlayerFrame,
    target = TargetFrame,
    focus = FocusFrame
}

local function updateIndicators(frame, unit)
    BBF.CombatIndicator(frame, unit)
    BBF.RacialIndicator(frame, unit)
end

local function UpdateCombatIndicator(self, event, unit)
    if event == "UNIT_FLAGS" then
        local frame = unitFrameMap[unit]
        if frame then
            --updateIndicators(frame, unit)
            BBF.CombatIndicator(frame, unit)
        end
    else
        for unit, frame in pairs(unitFrameMap) do
            updateIndicators(frame, unit)
        end
    end
end

local combatIndicatorFrame = CreateFrame("Frame")
combatIndicatorFrame:SetScript("OnEvent", UpdateCombatIndicator)
combatIndicatorFrame:RegisterUnitEvent("UNIT_FLAGS", "player", "target", "focus")
combatIndicatorFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
combatIndicatorFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
combatIndicatorFrame:RegisterEvent("PLAYER_ENTERING_WORLD")