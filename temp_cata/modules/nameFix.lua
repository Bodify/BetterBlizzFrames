local specIDToName = {
    -- Death Knight
    [250] = "Blood", [251] = "Frost", [252] = "Unholy",
    -- Demon Hunter
    [577] = "Havoc", [581] = "Vengeance",
    -- Druid
    [102] = "Balance", [103] = "Feral", [104] = "Guardian", [105] = "Restoration",
    -- Evoker
    [1467] = "Devastation", [1468] = "Preservation", [1473] = "Augmentation",
    -- Hunter
    [253] = "Beast Mastery", [254] = "Marksmanship", [255] = "Survival",
    -- Mage
    [62] = "Arcane", [63] = "Fire", [64] = "Frost",
    -- Monk
    [268] = "Brewmaster", [270] = "Mistweaver", [269] = "Windwalker",
    -- Paladin
    [65] = "Holy", [66] = "Protection", [70] = "Retribution",
    -- Priest
    [256] = "Discipline", [257] = "Holy", [258] = "Shadow",
    -- Rogue
    [259] = "Assassination", [260] = "Outlaw", [261] = "Subtlety",
    -- Shaman
    [262] = "Elemental", [263] = "Enhancement", [264] = "Restoration",
    -- Warlock
    [265] = "Affliction", [266] = "Demonology", [267] = "Destruction",
    -- Warrior
    [71] = "Arms", [72] = "Fury", [73] = "Protection",
}

local specIDToNameShort = {
    -- Death Knight
    [250] = "Blood", [251] = "Frost", [252] = "Unholy",
    -- Demon Hunter
    [577] = "Havoc", [581] = "Vengeance",
    -- Druid
    [102] = "Balance", [103] = "Feral", [104] = "Guardian", [105] = "Resto",
    -- Evoker
    [1467] = "Dev", [1468] = "Pres", [1473] = "Aug",
    -- Hunter
    [253] = "BM", [254] = "Marksman", [255] = "Survival",
    -- Mage
    [62] = "Arcane", [63] = "Fire", [64] = "Frost",
    -- Monk
    [268] = "Brewmaster", [270] = "Mistweaver", [269] = "Windwalker",
    -- Paladin
    [65] = "Holy", [66] = "Prot", [70] = "Ret",
    -- Priest
    [256] = "Disc", [257] = "Holy", [258] = "Shadow",
    -- Rogue
    [259] = "Assa", [260] = "Outlaw", [261] = "Sub",
    -- Shaman
    [262] = "Ele", [263] = "Enha", [264] = "Resto",
    -- Warlock
    [265] = "Aff", [266] = "Demo", [267] = "Destro",
    -- Warrior
    [71] = "Arms", [72] = "Fury", [73] = "Prot",
}

local removeRealmNames
local classColorTargetNames
local showSpecName
local shortArenaSpecName
local showArenaID
local targetAndFocusArenaNames
local classColorTargetReputationTexture
local classColorFocusReputationTexture
local partyArenaNames
local classColorLevelText

function BBF.UpdateUserTargetSettings()
    removeRealmNames = BetterBlizzFramesDB.removeRealmNames
    classColorTargetNames = BetterBlizzFramesDB.classColorTargetNames
    showSpecName = BetterBlizzFramesDB.showSpecName
    shortArenaSpecName = BetterBlizzFramesDB.shortArenaSpecName
    showArenaID = BetterBlizzFramesDB.showArenaID
    targetAndFocusArenaNames = BetterBlizzFramesDB.targetAndFocusArenaNames
    classColorTargetReputationTexture = BetterBlizzFramesDB.classColorTargetReputationTexture
    classColorFocusReputationTexture = BetterBlizzFramesDB.classColorFocusReputationTexture
    partyArenaNames = BetterBlizzFramesDB.partyArenaNames
    classColorLevelText = BetterBlizzFramesDB.classColorLevelText
end

-- Dictionary to store original points of frames
local originalPoints = {}

-- General function to center and adjust a frame
local function adjustFramePosition(frame, xOffset)
    -- Ensure we do not re-enter or mess with protected frames
    if frame.changing or frame:IsProtected() then return end
    frame.changing = true

    -- Capture the original point only once
    if not originalPoints[frame] then
        originalPoints[frame] = {frame:GetPoint()}
    end

    local a, b, c, d, e = unpack(originalPoints[frame])

    -- Clearing all previous points
    frame:ClearAllPoints()
    frame:SetJustifyH("CENTER")
    local playerFrameOCD = BetterBlizzFramesDB.playerFrameOCD and not BetterBlizzFramesDB.playerFrameOCDTextureBypass
    local ocdAdjustment = (frame == (TargetFrame.name or FocusFrame.name) and playerFrameOCD) and 1 or 0

    -- Setting the new point with customized x-offset
    frame:SetPoint("TOP", b, "TOP", xOffset, e-ocdAdjustment)
    if not BetterBlizzFramesDB.centerNames then
        frame:ClearAllPoints()
        frame:SetJustifyH("LEFT")
        frame:SetPoint(a, b, c, d, e)
    end

    frame.changing = false
end

local function adjustFramePositionOCD(frame)
    -- Capture the original point only once
    if not originalPoints[frame] then
        originalPoints[frame] = {frame:GetPoint()}
    end

    local a, b, c, d, e = unpack(originalPoints[frame])

    -- Clearing all previous points
    frame:ClearAllPoints()
    local playerFrameOCD = BetterBlizzFramesDB.playerFrameOCD and not BetterBlizzFramesDB.playerFrameOCDTextureBypass
    local ocdAdjustment = (frame == (TargetFrame.name or FocusFrame.name) and playerFrameOCD) and 1 or 0
    -- Setting the new point with customized x-offset
    frame:SetPoint(a, b, c, d, e-ocdAdjustment)

    frame.changing = false
end

function BBF.ShiftNamesCuzOCD()
    if not BetterBlizzFramesDB.centerNames then
        adjustFramePositionOCD(TargetFrame.cleanName)
        adjustFramePositionOCD(FocusFrame.cleanName)
    else
        adjustFramePosition(TargetFrame.cleanName, -2)
        adjustFramePosition(FocusFrame.cleanName, -2)
    end
end

local function updateArenaName(self, arenaIndex)
    local specID
    if Details and Details.realversion >= 134 then
        local unitGUID = UnitGUID(frame.unit)
        specID = Details:GetSpecByGUID(unitGUID)
    end
    local specName = specID and (shortArenaSpecName and specIDToNameShort[specID] or specIDToName[specID])

    if specName then
        local newName
        if showSpecName and showArenaID then
            newName = specName .. " " .. arenaIndex
        elseif showSpecName then
            newName = specName
        elseif showArenaID then
            newName = "Arena " .. arenaIndex
        end

        self:SetText(newName)
    end
end

-- Function to update the party member's name display
local function updatePartyName(self, partyIndex)
    local unit = "party" .. partyIndex
    local specID
    local Details = Details

    -- Fetch specID if Details is available and updated
    if Details and Details.realversion >= 134 then
        local unitGUID = UnitGUID(unit)
        specID = Details:GetSpecByGUID(unitGUID)
    end

    local specName = specID and (shortArenaSpecName and specIDToNameShort[specID] or specIDToName[specID])

    -- Determine the new name to display based on settings
    local newName
    if not specName then
        if showArenaID then
            newName = "Party " .. partyIndex
        end
    else
        if tot then
            newName = "Party " .. partyIndex
        elseif showSpecName and showArenaID then
            newName = specName .. " " .. partyIndex
        elseif showSpecName then
            newName = specName
        elseif showArenaID then
            newName = "Party " .. partyIndex
        end
    end

    self:SetText(newName)
end

local hookedLevels
local function updateTextForUnit(textElement, frame, hideName, isParty)
    -- if textElement.changing or textElement:IsProtected() then return end
    -- textElement.changing = true
    if not frame then return end

    local unit = frame.unit
    local isPlayer = UnitIsPlayer(unit)
    local isEnemy = UnitCanAttack("player", unit)

    -- create new fake name
    local ogFontName, ogFontHeight, ogFontFlags = textElement:GetFont()
    local a, p, a2, x, y = textElement:GetPoint()
    if not frame.cleanName then
        frame.cleanName = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    end
    if not isParty then
        frame.cleanName:SetParent(frame.name:GetParent())
    end
    frame.cleanName:SetFont(ogFontName, ogFontHeight, ogFontFlags)
    frame.cleanName:SetJustifyH(textElement:GetJustifyH())
    frame.cleanName:SetJustifyV(textElement:GetJustifyV())
    frame.cleanName:SetTextColor(textElement:GetTextColor())
    frame.cleanName:SetShadowColor(PlayerName:GetShadowColor())
    frame.cleanName:SetShadowOffset(textElement:GetShadowOffset())
    frame.cleanName:SetShadowColor(textElement:GetShadowColor())
    frame.cleanName:SetWordWrap(false)
    frame.cleanName:SetHeight(textElement:GetHeight())
    frame.cleanName:SetWidth(textElement:GetWidth())
    frame.cleanName:SetFont(ogFontName, ogFontHeight, ogFontFlags)
    frame.cleanName:ClearAllPoints()
    frame.cleanName:SetPoint(a,p,a2,x,y)

    frame.name:SetAlpha(0)
    frame.cleanName:SetAlpha(1)

    local textElement = frame.cleanName
    textElement:SetText(GetUnitName(unit))

    -- Early return if the name should be hidden
    if hideName then
        textElement:SetText("")
        return
    end

    -- Remove realm names for players
    if removeRealmNames and isPlayer then
        local currentText = GetUnitName(frame.unit, true)
        local newName = string.gsub(currentText, "%s*%-(.*)", "")  -- Remove diff realm indicator (*) from the name
        textElement:SetText(newName)
    end

    -- Set class colors for players
    if classColorTargetNames and not isParty then
        if isPlayer then
            local _, class = UnitClass(unit)
            local classColor = RAID_CLASS_COLORS[class]
            if classColor then
                textElement:SetTextColor(classColor.r, classColor.g, classColor.b)
                if classColorLevelText and frame.levelText then
                    if not hookedLevels then
                        BBF.HookLevelText()
                        hookedLevels = true
                    end
                    frame.levelText:SetTextColor(classColor.r, classColor.g, classColor.b)
                end
            end
        else
            textElement:SetTextColor(1, 0.81960791349411, 0)
        end
    end

    -- Arena name handling
    if (targetAndFocusArenaNames or partyArenaNames) and IsActiveBattlefieldArena() then
        if isEnemy then
            for i = 1, 3 do
                if UnitIsUnit(unit, "arena" .. i) then
                    updateArenaName(textElement, i)
                    textElement.changing = false
                    return
                end
            end
        else
            for i = 1, 2 do
                if UnitIsUnit(unit, "party" .. i) then
                    if (isParty and partyArenaNames) or (not isParty and targetAndFocusArenaNames) then
                        updatePartyName(textElement, i)
                        textElement.changing = false
                        return
                    end
                end
            end
        end
    end

    textElement.changing = false
end

function BBF.HookLevelText()
    hooksecurefunc(PlayerLevelText, "SetVertexColor", function(self)
        if not self.changing then
            self.changing = true
            local _, class = UnitClass("player")
            local classColor = RAID_CLASS_COLORS[class]
            self:SetTextColor(classColor.r, classColor.g, classColor.b)
            self.changing = false
        end
    end)
    local _, class = UnitClass("player")
    local classColor = RAID_CLASS_COLORS[class]
    PlayerLevelText:SetVertexColor(classColor.r, classColor.g, classColor.b)

    hooksecurefunc("TargetFrame_CheckLevel", function()
        if UnitIsPlayer("target") then
            local _, class = UnitClass("target")
            local classColor = RAID_CLASS_COLORS[class]
            TargetFrameTextureFrameLevelText:SetTextColor(classColor.r, classColor.g, classColor.b)
        end
        if UnitExists("focus") and UnitIsPlayer("focus") then
            local _, class = UnitClass("focus")
            local classColor = RAID_CLASS_COLORS[class]
            FocusFrameTextureFrameLevelText:SetTextColor(classColor.r, classColor.g, classColor.b)
        end
    end)

    if UnitExists("target") and UnitIsPlayer("target") then
        local _, class = UnitClass("target")
        local classColor = RAID_CLASS_COLORS[class]
        TargetFrameTextureFrameLevelText:SetTextColor(classColor.r, classColor.g, classColor.b)
    end
    if UnitExists("focus") and UnitIsPlayer("focus") then
        local _, class = UnitClass("focus")
        local classColor = RAID_CLASS_COLORS[class]
        FocusFrameTextureFrameLevelText:SetTextColor(classColor.r, classColor.g, classColor.b)
    end
    hookedLevels = true
end

BBF.updateTextForUnit = updateTextForUnit

local function RecolorReputationGlow()
    if BetterBlizzFramesDB.classColorTargetReputationTexture then
        BBF.ClassColorReputation(TargetFrameNameBackground, "target")
    end
    local focusExists = UnitExists("focus")

    if focusExists and BetterBlizzFramesDB.classColorFocusReputationTexture then
        BBF.ClassColorReputation(FocusFrameNameBackground, "focus")
    end
end

-- local UpdateTargetAndFocusNames = CreateFrame("Frame")
-- UpdateTargetAndFocusNames:RegisterEvent("PLAYER_TARGET_CHANGED")
-- UpdateTargetAndFocusNames:RegisterEvent("PLAYER_FOCUS_CHANGED")
-- UpdateTargetAndFocusNames:SetScript("OnEvent", function(self, event, ...)
--     RecolorReputationGlow()
-- end)

hooksecurefunc("TargetFrame_Update", function()
    RecolorReputationGlow()
end)

local playerName = _G["PlayerFrame"].name
hooksecurefunc("PlayerFrame_OnEvent", function()
    local hidePlayerName = BetterBlizzFramesDB.hidePlayerName
    updateTextForUnit(playerName, PlayerFrame, hidePlayerName)
end)

--bodify fix class color names toggle
--hide name, hide tot names

-- hooksecurefunc("PlayerFrame_UpdatePlayerNameTextAnchor", function()
--     print("PlayerFrame_UpdatePlayerNameTextAnchor has been called")
-- end)

-- local centerNameHooked
-- function BBF.SetCenteredNamesCaller()
--     if not centerNameHooked then
--         hooksecurefunc(PlayerFrame.name, "SetPoint", function(self)
--             adjustFramePosition(self, 32)
--         end)
--         centerNameHooked = true
--     end

--     adjustFramePosition(PlayerFrame.name, 32)
--     adjustFramePosition(TargetFrame.name, -2)
--     adjustFramePosition(FocusFrame.name, -2)
--     adjustFramePosition(TargetFrame.totFrame.Name, 55)
--     adjustFramePosition(FocusFrame.totFrame.Name, 55)
-- end

hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
    if not frame or not frame.unit then return end
    local isNameplate = frame.unit:find("nameplate")
    if isNameplate then return end

    local hidePartyNames = BetterBlizzFramesDB.hidePartyNames

    updateTextForUnit(frame.name, frame, hidePartyNames, true)

    local hidePartyRoles = BetterBlizzFramesDB.hidePartyRoles
    if hidePartyRoles then
        if frame.roleIcon then
            frame.roleIcon:SetAlpha(0)
        end
    end
end)

-- hooksecurefunc("CompactUnitFrame_UpdateRoleIcon", function(frame)
--     if not frame then return end
--     if hidePartyRoles then
--         if frame.roleIcon then
--             frame.roleIcon:SetAlpha(0)
--         end
--     end
-- end)

--local playerName = _G["PlayerFrame"].name
hooksecurefunc(playerName, "SetText", function(self)
    local hidePlayerName = BetterBlizzFramesDB.hidePlayerName
    updateTextForUnit(self, PlayerFrame, hidePlayerName)
end)
if not BetterBlizzFramesDB.biggerHealthbars then
    hooksecurefunc(playerName, "SetPoint", function(self)
        local hidePlayerName = BetterBlizzFramesDB.hidePlayerName
        updateTextForUnit(self, PlayerFrame, hidePlayerName)
    end)
end
local hidePlayerName = BetterBlizzFramesDB.hidePlayerName
updateTextForUnit(playerName, PlayerFrame, hidePlayerName)

local targetName = _G["TargetFrame"].name
hooksecurefunc(targetName, "SetText", function(self)
    local hideTargetName = BetterBlizzFramesDB.hideTargetName
    updateTextForUnit(self, TargetFrame, hideTargetName)
end)
local hideTargetName = BetterBlizzFramesDB.hideTargetName
updateTextForUnit(targetName, TargetFrame, hideTargetName)

local focusName = _G["FocusFrame"].name
hooksecurefunc(focusName, "SetText", function(self)
    local hideFocusName = BetterBlizzFramesDB.hideFocusName
    updateTextForUnit(self, FocusFrame, hideFocusName)
end)
local hideFocusName = BetterBlizzFramesDB.hideFocusName
updateTextForUnit(focusName, FocusFrame, hideFocusName)

local targetToTName = _G["TargetFrameToTTextureFrameName"]
hooksecurefunc(targetToTName, "SetText", function(self)
    local hideTargetToTName = BetterBlizzFramesDB.hideTargetToTName
    updateTextForUnit(self, TargetFrameToT, hideTargetToTName)
end)
local hideTargetToTName = BetterBlizzFramesDB.hideTargetToTName
updateTextForUnit(targetToTName, TargetFrameToT, hideTargetToTName)

local focusToTName = _G["FocusFrameToTTextureFrameName"]
hooksecurefunc(focusToTName, "SetText", function(self)
    local hideFocusToTName = BetterBlizzFramesDB.hideFocusToTName
    updateTextForUnit(self, FocusFrameToT, hideFocusToTName)
end)
local hideFocusToTName = BetterBlizzFramesDB.hideFocusToTName
updateTextForUnit(focusToTName, FocusFrameToT, hideFocusToTName)

-- for i = 1, 4 do
--     --local memberFrame = PartyFrame["MemberFrame" .. i]
--     local memberFrame = _G["PartyMemberFrame"..i]
--     local memberFrameName = memberFrame.name

--     hooksecurefunc(memberFrameName, "SetText", function(self, text)
--         local hidePartyNames = BetterBlizzFramesDB.hidePartyNames
--         updateTextForUnit(self, memberFrame, hidePartyNames, true)
--     end)
-- end

function BBF.UpdateAllNames()
    BBF.UpdateUserTargetSettings()
    local playerName = _G["PlayerFrame"].name
    local hidePlayerName = BetterBlizzFramesDB.hidePlayerName
    updateTextForUnit(playerName, PlayerFrame, hidePlayerName)

    local targetName = _G["TargetFrame"].name
    local hideTargetName = BetterBlizzFramesDB.hideTargetName
    updateTextForUnit(targetName, TargetFrame, hideTargetName)

    local focusName = _G["FocusFrame"].name
    local hideFocusName = BetterBlizzFramesDB.hideFocusName
    updateTextForUnit(focusName, FocusFrame, hideFocusName)

    local targetToTName = _G["TargetFrameToTTextureFrameName"]
    local hideTargetToTName = BetterBlizzFramesDB.hideTargetToTName
    updateTextForUnit(targetToTName, TargetFrameToT, hideTargetToTName)

    local focusToTName = _G["FocusFrameToTTextureFrameName"]
    local hideFocusToTName = BetterBlizzFramesDB.hideFocusToTName
    updateTextForUnit(focusToTName, FocusFrameToT, hideFocusToTName)

    local hidePartyNames = BetterBlizzFramesDB.hidePartyNames
    for i = 1, 40 do
        local memberFrame = nil

        -- Check PartyMemberFrame
        memberFrame = _G["PartyMemberFrame"..i]
        if memberFrame and memberFrame.name then
            updateTextForUnit(memberFrame.name, memberFrame, hidePartyNames, true)
        end

        -- Check CompactRaidGroup
        for j = 1, 8 do
            memberFrame = _G["CompactRaidGroup"..j.."Member"..i]
            if memberFrame and memberFrame.name then
                updateTextForUnit(memberFrame.name, memberFrame, hidePartyNames, true)
            end
        end

        -- Check RaidFrameMember
        memberFrame = _G["RaidFrameMember"..i]
        if memberFrame and memberFrame.name then
            updateTextForUnit(memberFrame.name, memberFrame, hidePartyNames, true)
        end
    end
end


function BBF.ClassColorPlayerName()
    local frame = PlayerFrame
    if BetterBlizzFramesDB.classColorTargetNames then
        local _, class = UnitClass("player")
        if class then
            local classColor = RAID_CLASS_COLORS[class]
            if classColor then
                frame.cleanName:SetTextColor(classColor.r, classColor.g, classColor.b)
                if classColorLevelText then
                    --PlayerLevelText:SetTextColor(classColor.r, classColor.g, classColor.b)
                else
                    --PlayerLevelText:SetTextColor(1, 0.81960791349411, 0, 1)
                end
            end
        end
    else
        frame.cleanName:SetTextColor(1, 0.81960791349411, 0)
        --PlayerLevelText:SetTextColor(1, 0.81960791349411, 0)
    end
end