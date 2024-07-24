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

local hidePartyNames
local hidePartyRoles
local removeRealmNames
local classColorFrames
local classColorTargetNames
local showSpecName
local shortArenaSpecName
local showArenaID
local targetAndFocusArenaNames
local classColorTargetReputationTexture
local classColorFocusReputationTexture
local partyArenaNames
local hideTargetName
local hideFocusName
local hideTargetToTName
local hideFocusToTName
local classColorLevelText
local centerNames
local playerFrameOCD
local playerFrameOCDTextureBypass
local hidePlayerName
local isAddonLoaded = C_AddOns.IsAddOnLoaded

function BBF.UpdateUserTargetSettings()
    hidePartyNames = BetterBlizzFramesDB.hidePartyNames
    hidePartyRoles = BetterBlizzFramesDB.hidePartyRoles
    removeRealmNames = BetterBlizzFramesDB.removeRealmNames
    classColorFrames = BetterBlizzFramesDB.classColorFrames
    classColorTargetNames = BetterBlizzFramesDB.classColorTargetNames
    showSpecName = BetterBlizzFramesDB.showSpecName
    shortArenaSpecName = BetterBlizzFramesDB.shortArenaSpecName
    showArenaID = BetterBlizzFramesDB.showArenaID
    targetAndFocusArenaNames = BetterBlizzFramesDB.targetAndFocusArenaNames
    classColorTargetReputationTexture = BetterBlizzFramesDB.classColorTargetReputationTexture
    classColorFocusReputationTexture = BetterBlizzFramesDB.classColorFocusReputationTexture
    partyArenaNames = BetterBlizzFramesDB.partyArenaNames
    hideTargetName = BetterBlizzFramesDB.hideTargetName
    hideFocusName = BetterBlizzFramesDB.hideFocusName
    hideTargetToTName = BetterBlizzFramesDB.hideTargetToTName
    hideFocusToTName = BetterBlizzFramesDB.hideFocusToTName
    classColorLevelText = BetterBlizzFramesDB.classColorLevelText
    centerNames = BetterBlizzFramesDB.centerNames
    playerFrameOCD = BetterBlizzFramesDB.playerFrameOCD and not BetterBlizzFramesDB.playerFrameOCDTextureBypass
    playerFrameOCDTextureBypass = BetterBlizzFramesDB.playerFrameOCDTextureBypass
    hidePlayerName = BetterBlizzFramesDB.hidePlayerName
end

local function CheckUnit(frame, unit, party, tot)
    if isAddonLoaded("ClassicFrames") then return end
    local originalNameObject = frame.name or frame.Name
    local newName

    local ogFontName, ogFontHeight, ogFontFlags = originalNameObject:GetFont()
    if not frame.cleanName then
        local a, p, a2, x, y = originalNameObject:GetPoint()
        frame.cleanName = frame:CreateFontString(nil, "OVERLAY")
        frame.cleanName:SetFont(ogFontName, ogFontHeight, ogFontFlags)
        frame.cleanName:SetJustifyH(originalNameObject:GetJustifyH())
        frame.cleanName:SetJustifyV(originalNameObject:GetJustifyV())
        frame.cleanName:SetTextColor(originalNameObject:GetTextColor())
        frame.cleanName:SetShadowColor(PlayerName:GetShadowColor())
        frame.cleanName:SetShadowOffset(originalNameObject:GetShadowOffset())
        frame.cleanName:SetShadowColor(originalNameObject:GetShadowColor())
        frame.cleanName:SetWidth(originalNameObject:GetWidth() + 10)
        frame.cleanName:SetHeight(originalNameObject:GetHeight())
        frame.cleanName:SetWordWrap(false)

        if centerNames and not party then
            frame.cleanName:SetJustifyH("CENTER")
            frame.cleanName:SetPoint("TOP", frame.HealthBar, "TOP", 2, 13)
            if frame == TargetFrame.totFrame or frame == FocusFrame.totFrame then
                frame.cleanName:SetJustifyH("CENTER")
                local _,anchor,_,_,yPos = originalNameObject:GetPoint()
                --frame.cleanName:ClearAllPoints()
                frame.cleanName:SetPoint("TOP", anchor, "TOP", 52, yPos)
            end
        else
            if party then
                frame.cleanName:SetPoint(a, p, a2, x, y)
            elseif frame == TargetFrame.totFrame or frame == FocusFrame.totFrame then
                frame.cleanName:SetPoint(a, p, a2, x, y)
                frame.cleanName:SetWidth(originalNameObject:GetWidth() + 10)
                frame.cleanName:SetWordWrap(false)
            else
                --if playerFrameOCD then
                    --frame.cleanName:SetPoint(a,p,a2,x,y-2)
                --else
                    frame.cleanName:SetPoint(a,p,a2,x,y)
                --end
            end
        end

        for i = 1, 4 do
            if frame == PartyFrame["MemberFrame" .. i] then
                if hidePartyRoles then
                    frame.cleanName:SetWidth(originalNameObject:GetWidth() + 13)
                    --frame.cleanName:SetPoint(a, p, a2, x, y+4)
                    frame.cleanName:SetWordWrap(false)
                else
                    frame.cleanName:SetWidth(originalNameObject:GetWidth() + 10)
                    --frame.cleanName:SetPoint(a, p, a2, x, y+4)
                    frame.cleanName:SetWordWrap(false)
                end
                break
            end
        end
    end

    if (party and hidePartyNames) and not partyArenaNames then
        frame.cleanName:SetAlpha(0)
        originalNameObject:SetAlpha(0)
        return
    end

    if UnitIsUnit(unit, "player") then
        frame.cleanName:SetText(GetUnitName(unit, true))
        frame.cleanName:SetAlpha(1)
        originalNameObject:SetAlpha(0)
        return
    elseif UnitIsUnit(unit, "party1") then
        local specID
        local Details = Details
        if Details and Details.realversion >= 134 then
            local unitGUID = UnitGUID(unit)
            specID = Details:GetSpecByGUID(unitGUID)
        end
        local specName = specID and specIDToName[specID]
        if shortArenaSpecName then
            specName = specID and specIDToNameShort[specID]
        end

        if not specName then
            if showArenaID then
                newName = "Party 1"
            elseif removeRealmNames then
                local name = (GetUnitName(unit, true))
                newName = string.gsub(name, "%s*%(.*%)", "")
            else
                local name = (GetUnitName(unit, true))
                newName = name
            end
        else
            if tot then
                newName = "Party 1"
            elseif showSpecName and showArenaID then
                newName = specName .. " 1"
            elseif showSpecName then
                newName = specName
            elseif showArenaID then
                newName = "Party 1"
            end
        end
        frame.cleanName:SetText(newName)
        frame.cleanName:SetAlpha(1)
        originalNameObject:SetAlpha(0)
        return

    elseif UnitIsUnit(unit, "party2") then
        local specID
        local Details = Details
        if Details and Details.realversion >= 134 then
            local unitGUID = UnitGUID(unit)
            specID = Details:GetSpecByGUID(unitGUID)
        end
        local specName = specID and specIDToName[specID]
        if shortArenaSpecName then
            specName = specID and specIDToNameShort[specID]
        end

        if not specName then
            if showArenaID then
                newName = "Party 2"
            elseif removeRealmNames then
                local name = (GetUnitName(unit, true))
                newName = string.gsub(name, "%s*%(.*%)", "")
            else
                local name = (GetUnitName(unit, true))
                newName = name
            end
        else
            if tot then
                newName = "Party 2"
            elseif showSpecName and showArenaID then
                newName = specName .. " 2"
            elseif showSpecName then
                newName = specName
            elseif showArenaID then
                newName = "Party 2"
            end
        end
        frame.cleanName:SetText(newName)
        frame.cleanName:SetAlpha(1)
        originalNameObject:SetAlpha(0)
        return

    elseif UnitIsUnit(unit, "arena1") then
        local specID = GetArenaOpponentSpec(1)
        local specName = specID and specIDToName[specID]
        if shortArenaSpecName then
            specName = specID and specIDToNameShort[specID]
        end

        if specName then
            if showSpecName and showArenaID then
                newName = specName .. " 1"
            elseif showSpecName then
                newName = specName
            elseif showArenaID then
                newName = "Arena 1"
            end
            frame.cleanName:SetText(newName)
            frame.cleanName:SetAlpha(1)
            originalNameObject:SetAlpha(0)
        end
        return

    elseif UnitIsUnit(unit, "arena2") then
        local specID = GetArenaOpponentSpec(2)
        local specName = specID and specIDToName[specID]
        if shortArenaSpecName then
            specName = specID and specIDToNameShort[specID]
        end

        if specName then
            if showSpecName and showArenaID then
                newName = specName .. " 2"
            elseif showSpecName then
                newName = specName
            elseif showArenaID then
                newName = "Arena 2"
            end
            frame.cleanName:SetText(newName)
            frame.cleanName:SetAlpha(1)
            originalNameObject:SetAlpha(0)
        end
        return

    elseif UnitIsUnit(unit, "arena3") then
        local specID = GetArenaOpponentSpec(3)
        local specName = specID and specIDToName[specID]
        if shortArenaSpecName then
            specName = specID and specIDToNameShort[specID]
        end

        if specName then
            if showSpecName and showArenaID then
                newName = specName .. " 3"
            elseif showSpecName then
                newName = specName
            elseif showArenaID then
                newName = "Arena 3"
            end
            frame.cleanName:SetText(newName)
            frame.cleanName:SetAlpha(1)
            originalNameObject:SetAlpha(0)
        end
        return
    else
        if hidePartyNames and party then
            frame.cleanName:SetAlpha(0)
            originalNameObject:SetAlpha(0)
            --originalNameObject:SetAlpha(1)
            return
        else
            local isPlayer = UnitIsPlayer(unit)
            local name = (GetUnitName(unit, true))

            if removeRealmNames then
                if isPlayer and name then
                    newName = string.gsub(name, "%s*%(.*%)", "")
                else
                    newName = name
                end
            end
            frame.cleanName:SetText(newName)
            frame.cleanName:SetAlpha(1)
            originalNameObject:SetAlpha(0)
        end
    end
end

local function ChangeName(frame, unit, party, tot)
    if isAddonLoaded("ClassicFrames") then return end
    local originalNameObject = frame.name or frame.Name
    local name

    if party then
        name = GetUnitName(unit, true)
    else
        name = GetUnitName(unit, false)
    end

    local newName

    local isPlayer = UnitIsPlayer(unit)
    local isInArena = IsActiveBattlefieldArena() and ((partyArenaNames and party) or targetAndFocusArenaNames)
    local ogFontName, ogFontHeight, ogFontFlags = originalNameObject:GetFont()

    if not frame.cleanName then
        local a, p, a2, x, y = originalNameObject:GetPoint()
        frame.cleanName = frame:CreateFontString(nil, "OVERLAY")
        frame.cleanName:SetFont(ogFontName, ogFontHeight, ogFontFlags)
        frame.cleanName:SetJustifyH(originalNameObject:GetJustifyH())
        frame.cleanName:SetJustifyV(originalNameObject:GetJustifyV())
        frame.cleanName:SetTextColor(originalNameObject:GetTextColor())
        frame.cleanName:SetShadowColor(PlayerName:GetShadowColor())
        frame.cleanName:SetShadowOffset(originalNameObject:GetShadowOffset())
        frame.cleanName:SetShadowColor(originalNameObject:GetShadowColor())
        frame.cleanName:SetWidth(originalNameObject:GetWidth() + 10)
        frame.cleanName:SetHeight(originalNameObject:GetHeight())
        frame.cleanName:SetWordWrap(false)

        if centerNames and not party then
            frame.cleanName:SetJustifyH("CENTER")
            frame.cleanName:SetPoint("TOP", frame.HealthBar, "TOP", 2, 13)
            if frame == TargetFrame.totFrame or frame == FocusFrame.totFrame then
                frame.cleanName:SetJustifyH("CENTER")
                local _,anchor,_,_,yPos = originalNameObject:GetPoint()
                --frame.cleanName:ClearAllPoints()
                frame.cleanName:SetPoint("TOP", anchor, "TOP", 52, yPos)
            end
        else
            if party then
                frame.cleanName:SetPoint(a, p, a2, x, y)
            elseif frame == TargetFrame.totFrame or frame == FocusFrame.totFrame then
                frame.cleanName:SetPoint(a, p, a2, x, y)
                frame.cleanName:SetWidth(originalNameObject:GetWidth() + 10)
                frame.cleanName:SetWordWrap(false)
            else
                --if playerFrameOCD then
                    --frame.cleanName:SetPoint(a,p,a2,x,y-2)
                --else
                    frame.cleanName:SetPoint(a,p,a2,x,y)
                --end
            end
        end

        for i = 1, 4 do
            if frame == PartyFrame["MemberFrame" .. i] then
                if hidePartyRoles then
                    frame.cleanName:SetWidth(originalNameObject:GetWidth() + 13)
                    --frame.cleanName:SetPoint(a, p, a2, x, y+4)
                    frame.cleanName:SetWordWrap(false)
                else
                    frame.cleanName:SetWidth(originalNameObject:GetWidth() + 10)
                    --frame.cleanName:SetPoint(a, p, a2, x, y+4)
                    frame.cleanName:SetWordWrap(false)
                end
                break
            end
        end
    end
    if party then
        local a, p, a2, x, y = originalNameObject:GetPoint()
        frame.cleanName:ClearAllPoints()
        frame.cleanName:SetPoint(a, p, a2, x, y)
    end
    if tot then
        frame.cleanName:SetWidth(originalNameObject:GetWidth() + 5)
    else
        frame.cleanName:SetWidth(originalNameObject:GetWidth() + 6)
    end
    frame.cleanName:SetHeight(originalNameObject:GetHeight())
    frame.cleanName:SetFont(ogFontName, ogFontHeight, ogFontFlags)

    if (classColorTargetNames and not party) and isPlayer then
        local _, class = UnitClass(unit)
        if class then
            local classColor = RAID_CLASS_COLORS[class]
            if classColor then
                frame.cleanName:SetTextColor(classColor.r, classColor.g, classColor.b)
                originalNameObject:SetTextColor(classColor.r, classColor.g, classColor.b)
                if classColorLevelText then
                    if frame.LevelText then
                        frame.LevelText:SetTextColor(classColor.r, classColor.g, classColor.b)
                    end
                end
            end
        end
    elseif (classColorTargetNames and not party) and not isPlayer then
        frame.cleanName:SetTextColor(1, 0.81960791349411, 0, 1)
        originalNameObject:SetTextColor(1, 0.81960791349411, 0, 1)
    end

    if isInArena then
        if party then
            if partyArenaNames then
                CheckUnit(frame, unit, true)
            else
                if frame.cleanName then
                    frame.cleanName:SetAlpha(0)
                end
                if hidePartyNames and party then
                    originalNameObject:SetAlpha(0)
                else
                    originalNameObject:SetAlpha(1)
                end
            end
        else
            if targetAndFocusArenaNames then
                CheckUnit(frame, unit, nil, tot)
--[=[
            else
                if frame.cleanName then
                    frame.cleanName:SetAlpha(0)
                end
                originalNameObject:SetAlpha(1)

]=]

            end
        end
    elseif hidePartyNames and party then
        originalNameObject:SetAlpha(0)
        if frame.cleanName then
            frame.cleanName:SetAlpha(0)
        end
    elseif removeRealmNames then
        if party then
            if hidePartyNames then
                frame.cleanName:SetAlpha(0)
            else
                if name then
                    newName = string.gsub(name, "%-.*$", "")
                end
                frame.cleanName:SetText(newName)
                frame.cleanName:SetAlpha(1)
            end
            originalNameObject:SetAlpha(0)
        else
            if isPlayer and name then
                newName = string.gsub(name, "%s*%(.*%)", "")
            else
                newName = name
            end
            frame.cleanName:SetText(newName)
            frame.cleanName:SetAlpha(1)
            originalNameObject:SetAlpha(0)
        end
    else
        if isPlayer then
            frame.cleanName:SetText(name)
            frame.cleanName:SetAlpha(1)
        else
            frame.cleanName:SetText(name)
            frame.cleanName:SetAlpha(1)
        end
        if party then
            if hidePartyNames then
                originalNameObject:SetAlpha(0)
            else
                originalNameObject:SetAlpha(1)
            end
            frame.cleanName:SetAlpha(0)
        else
            originalNameObject:SetAlpha(0)
        end
    end
    if (frame == TargetFrame.TargetFrameContent.TargetFrameContentMain and hideTargetName) or
    (frame == FocusFrame.TargetFrameContent.TargetFrameContentMain and hideFocusName) or
    (frame == FocusFrame.totFrame and hideFocusToTName) or
    (frame == TargetFrame.totFrame and hideTargetToTName) then
        originalNameObject:SetAlpha(0)
        if isInArena then
            if not party then
                frame.cleanName:SetAlpha(1)
            end
        else
            frame.cleanName:SetAlpha(0)
        end
    end
end

function BBF.PartyNameChange()
    if CompactPartyFrame:IsVisible() then
        local groupMembers = GetNumGroupMembers()
        for i = 1, groupMembers+1 do
            local memberFrame = _G["CompactPartyFrameMember" .. i]
            if memberFrame and memberFrame.displayedUnit then
                ChangeName(memberFrame, memberFrame.displayedUnit, true)
            end
        end
    else
        if PartyFrame:IsVisible() then ---PartyFrame:IsVisible() always true?
            for i = 1, 4 do
                local memberFrame = PartyFrame["MemberFrame" .. i]
                if memberFrame and memberFrame.unit then
                    ChangeName(memberFrame, memberFrame.unit, true)
                end
            end
        end
    end
end

local function TargetAndFocusNameChange()
    if isAddonLoaded("ClassicFrames") then return end
    --if BetterBlizzFramesDB.targetAndFocusArenaNames or BetterBlizzFramesDB.removeRealmNames or BetterBlizzFramesDB.classColorTargetNames then
        ChangeName(TargetFrame.TargetFrameContent.TargetFrameContentMain, "target")
        ChangeName(FocusFrame.TargetFrameContent.TargetFrameContentMain, "focus")
        ChangeName(TargetFrame.totFrame, "targettarget", nil, true)
        ChangeName(FocusFrame.totFrame, "focustarget", nil, true)
    --end
end

local UpdatePartyNames = CreateFrame("Frame")
UpdatePartyNames:RegisterEvent("GROUP_ROSTER_UPDATE")
UpdatePartyNames:RegisterEvent("PLAYER_ENTERING_WORLD")
UpdatePartyNames:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
UpdatePartyNames:SetScript("OnEvent", function(self, event, ...)
    for delay = 0, 8 do
        C_Timer.After(delay, BBF.PartyNameChange)
    end
end)

local function checkWeight()
    if isAddonLoaded("ClassicFrames") then return end
    TargetAndFocusNameChange()
    BBF.PartyNameChange()
    if classColorTargetReputationTexture then
        BBF.ClassColorReputation(TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, "target")
    end
    if classColorFocusReputationTexture then
        BBF.ClassColorReputation(FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, "focus")
    end
end

local UpdateTargetAndFocusNames = CreateFrame("Frame")
UpdateTargetAndFocusNames:RegisterEvent("PLAYER_TARGET_CHANGED")
UpdateTargetAndFocusNames:RegisterEvent("PLAYER_FOCUS_CHANGED")
UpdateTargetAndFocusNames:SetScript("OnEvent", function(self, event, ...)
    if isAddonLoaded("ClassicFrames") then return end
    checkWeight()
end)

function BBF.ClassColorPlayerName()
    if isAddonLoaded("ClassicFrames") then return end
    local frame = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain
    if classColorTargetNames then
        if not coloredName then
            local _, class = UnitClass("player")
            if class then
                local classColor = RAID_CLASS_COLORS[class]
                if classColor then
                    if frame.cleanName then
                        frame.cleanName:SetTextColor(classColor.r, classColor.g, classColor.b)
                    end
                    PlayerName:SetTextColor(classColor.r, classColor.g, classColor.b)
                    if classColorLevelText then
                        PlayerLevelText:SetTextColor(classColor.r, classColor.g, classColor.b)
                    else
                        PlayerLevelText:SetTextColor(1, 0.81960791349411, 0, 1)
                    end
                end
            end
        end
    else
        PlayerName:SetTextColor(1, 0.81960791349411, 0)
        PlayerLevelText:SetTextColor(1, 0.81960791349411, 0)
        if frame.cleanName then
            frame.cleanName:SetTextColor(1, 0.81960791349411, 0)
        end
    end
end

local function ClassColorNames(name, unit, level)
    if classColorTargetNames then
        local _, class = UnitClass(unit)
        local isPlayer = UnitIsPlayer(unit)
        if class and isPlayer then
            local classColor = RAID_CLASS_COLORS[class]
            if classColor then
                if name then
                    name:SetTextColor(classColor.r, classColor.g, classColor.b)
                end
                if classColorLevelText then
                    if level then
                        level:SetTextColor(classColor.r, classColor.g, classColor.b)
                    end
                else
                    if level then
                        level:SetTextColor(1, 0.81960791349411, 0, 1)
                    end
                end
            end
        else
            if name then
                name:SetTextColor(1, 0.81960791349411, 0)
            end
        end
    else
        if name then
            name:SetTextColor(1, 0.81960791349411, 0)
        end
        if level then
            level:SetTextColor(1, 0.81960791349411, 0, 1)
        end
    end
end

function BBF.ClassColorNamesCaller()
    if isAddonLoaded("ClassicFrames") then return end
    ClassColorNames(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.cleanName, "player", PlayerLevelText)
    ClassColorNames(TargetFrame.TargetFrameContent.TargetFrameContentMain.cleanName, "target", TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText)
    ClassColorNames(FocusFrame.TargetFrameContent.TargetFrameContentMain.cleanName, "focus", FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText)
    ClassColorNames(TargetFrame.totFrame.cleanName, "targettarget")
    ClassColorNames(TargetFrame.totFrame.cleanName, "focustarget")
    ClassColorNames(TargetFrame.totFrame.Name, "targettarget")
    ClassColorNames(TargetFrame.totFrame.Name, "focustarget")
end

local function UpdateToTName(frame, unit)
    if isAddonLoaded("ClassicFrames") then return end
    local isPlayer = UnitIsPlayer(unit)
    local name = GetUnitName(unit, false)
    local newName = name
    local isInArena = IsActiveBattlefieldArena()
    if targetAndFocusArenaNames and isInArena then
        CheckUnit(frame, unit, nil, true)
        return
    elseif isPlayer and removeRealmNames then
        newName = string.gsub(name, "%s*%(.*%)", "")
        if frame.cleanName then
            frame.cleanName:SetText(newName)
            frame.name:SetAlpha(0)
        end
    else
        if frame.cleanName then
            frame.cleanName:SetText(name)
            frame.name:SetAlpha(0)
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_TARGET")
frame:RegisterEvent("UNIT_FACTION")
frame:SetScript("OnEvent", function(self, event, unit)
    if isAddonLoaded("ClassicFrames") then return end
    UpdateToTName(TargetFrame.totFrame, "targettarget")
    UpdateToTName(FocusFrame.totFrame, "focustarget")
--[[
    if classColorFrames then
        BBF.UpdateFrameColor(TargetFrame.totFrame.HealthBar, "targettarget")
        BBF.UpdateFrameColor(FocusFrame.totFrame.HealthBar, "focustarget")
        BBF.UpdateToTColor()
    end

]]

    if classColorTargetNames then
        ClassColorNames(TargetFrame.totFrame.Name, "targettarget")
        ClassColorNames(TargetFrame.totFrame.cleanName, "targettarget")
        ClassColorNames(FocusFrame.totFrame.Name, "focustarget")
        ClassColorNames(FocusFrame.totFrame.cleanName, "focustarget")
    end
end)


function BBF.AllCaller()
    if isAddonLoaded("ClassicFrames") then return end
    BBF.PartyNameChange()
    TargetAndFocusNameChange()
    BBF.OnUpdateName()
    -- if hidePartyNames or hidePartyRoles then
    --     BBF.OnUpdateName()
    -- end
end

local function RemoveRealmName(frame)
    if isAddonLoaded("ClassicFrames") then return end
    local name = GetUnitName(frame.unit)
    if name then
        name = string.gsub(name, " %(%*%)$", "")
        if frame.cleanName then
            frame.cleanName:SetText(name)
        end
    end
end

local function RunOnUpdateName(frame)
    -- if isAddonLoaded("ClassicFrames") then return end
    if hidePartyNames or hidePartyRoles then
        BBF.OnUpdateName()
    end
    -- if not frame or frame:IsForbidden() then return end
    -- local isNameplate = frame.unit and frame.unit:find("nameplate")

    -- if removeRealmNames and not isNameplate then
    --     RemoveRealmName(frame)
    -- end
end

function BBF.OnUpdateName()
    if isAddonLoaded("ClassicFrames") then return end
    local defaultPartyFrame = PartyFrame

    local groupMembers = GetNumGroupMembers()
    for i = 1, groupMembers+1 do
        local compactPartyMember = _G["CompactPartyFrameMember" .. i]
        local roleIcon = _G["CompactPartyFrameMember" .. i .. "RoleIcon"]
        local defaultMember = defaultPartyFrame["MemberFrame" .. i]

        if compactPartyMember and compactPartyMember:IsShown() then
            -- Hide the role icon if hidePartyRoles is true
            if hidePartyNames then
                compactPartyMember.name:SetAlpha(0)
                if not partyArenaNames then
                    if compactPartyMember.cleanName then
                        compactPartyMember.cleanName:SetAlpha(0)
                    end
                end
            end
            if hidePartyRoles and roleIcon then
                roleIcon:SetAlpha(0)
            else
                roleIcon:SetAlpha(1)
            end
        else
            if defaultMember then --will always be true find fix bodify
                if (hidePartyNames and defaultMember.name) and not partyArenaNames then
                    defaultMember.Name:SetAlpha(0)
                    if defaultMember.cleanName then
                        defaultMember.cleanName:SetAlpha(0)
                    end
                else
                    defaultMember.Name:SetAlpha(0)
                    if defaultMember.cleanName then
                        defaultMember.cleanName:SetAlpha(1)
                    end
                end

                if hidePartyRoles and defaultMember.PartyMemberOverlay.RoleIcon then
                    defaultMember.PartyMemberOverlay.RoleIcon:SetAlpha(0)
                else
                    defaultMember.PartyMemberOverlay.RoleIcon:SetAlpha(1)
                end
            end
        end
    end
end

function BBF.CenteredFrameNames(frame, unit)
    if isAddonLoaded("ClassicFrames") then return end
    local originalNameObject = frame.Name

    local a, b, c, x, y = originalNameObject:GetPoint()
    originalNameObject:SetAlpha(0)
    if centerNames then
        if not frame.cleanName then
            ChangeName(frame, unit)
        end
        frame.cleanName:SetJustifyH("CENTER")
        frame.cleanName:SetJustifyV(originalNameObject:GetJustifyV())
        frame.cleanName:SetWidth(originalNameObject:GetWidth())
        frame.cleanName:ClearAllPoints()
        frame.cleanName:SetPoint("TOP", frame.HealthBar, "TOP", 2, 14)
        frame.cleanName:SetAlpha(1)
    else
        if frame.cleanName then
            frame.cleanName:SetJustifyH(originalNameObject:GetJustifyH())
            frame.cleanName:SetJustifyV(originalNameObject:GetJustifyV())
            --frame.cleanName:SetTextColor(1, 0.81960791349411, 0)
            frame.cleanName:SetShadowColor(originalNameObject:GetShadowColor())
            frame.cleanName:SetShadowOffset(originalNameObject:GetShadowOffset())
            frame.cleanName:SetShadowColor(originalNameObject:GetShadowColor())
            frame.cleanName:SetWidth(originalNameObject:GetWidth())
            --frame.cleanName:ClearAllPoints()
            if playerFrameOCD then
                frame.cleanName:SetPoint(a,b,c,x,y-1.5)
            else
                if playerFrameOCDTextureBypass then
                    frame.cleanName:SetPoint(a,b,c,x,y-1)
                else
                    frame.cleanName:SetPoint(a,b,c,x,y)
                end
            end
            frame.cleanName:SetAlpha(1)
        end
        --frame.cleanName:SetAlpha(0)
        --originalNameObject:SetAlpha(1)
    end
end

local function CenteredPlayerName()
    if isAddonLoaded("ClassicFrames") then return end
    local frame = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain
    if centerNames then
        if hidePlayerName then
            PlayerName:SetAlpha(0)
            if frame.cleanName then
                frame.cleanName:SetAlpha(0)
            end
            return
        end
        PlayerName:SetAlpha(0)
        if not frame.cleanName then
            frame.cleanName = frame:CreateFontString(nil, "OVERLAY")
            frame.cleanName:SetFont(PlayerName:GetFont())
            frame.cleanName:SetJustifyH("CENTER")
            frame.cleanName:SetJustifyV(PlayerName:GetJustifyV())
            frame.cleanName:SetText(GetUnitName("player", true))
            --frame.cleanName:ClearAllPoints()
            if playerFrameOCD then
                frame.cleanName:SetPoint("TOP", frame.HealthBarsContainer, "TOP", 0, 13.5)
            else
                frame.cleanName:SetPoint("TOP", frame.HealthBarsContainer, "TOP", 0, 14.5)
            end
            --frame.cleanName:SetTextColor(1, 0.81960791349411, 0)
            frame.cleanName:SetShadowColor(PlayerName:GetShadowColor())
            frame.cleanName:SetShadowOffset(PlayerName:GetShadowOffset())
            frame.cleanName:SetShadowColor(PlayerName:GetShadowColor())
            frame.cleanName:SetHeight(PlayerName:GetHeight())
            frame.cleanName:SetWidth(PlayerName:GetWidth())
        end
        frame.cleanName:SetAlpha(1)
        ClassColorNames(frame.cleanName, "player", PlayerLevelText)
    else
        if hidePlayerName then
            PlayerName:SetAlpha(0)
            if frame.cleanName then
                frame.cleanName:SetAlpha(0)
            end
        else
            PlayerName:SetAlpha(1)
            if frame.cleanName then
                frame.cleanName:SetAlpha(0)
            end
        end
    end
end

function BBF.SetCenteredNamesCaller()
    if isAddonLoaded("ClassicFrames") then
        return
    end
    
    BBF.UpdateUserTargetSettings()
    CenteredPlayerName()
    --BBF.CenteredFrameNames(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain, "player")
    BBF.CenteredFrameNames(TargetFrame.TargetFrameContent.TargetFrameContentMain, "target")
    BBF.CenteredFrameNames(FocusFrame.TargetFrameContent.TargetFrameContentMain, "focus")
end

-- function BBF.ChangeNameFocus()
--     ChangeName(FocusFrame.TargetFrameContent.TargetFrameContentMain, "focus")
-- end

local partyFrames = {
    ["CompactPartyFrameMember1"] = true,
    -- ["CompactPartyFrameMember2"] = true,
    -- ["CompactPartyFrameMember3"] = true,
    -- ["CompactPartyFrameMember4"] = true,
    -- ["CompactPartyFrameMember5"] = true,
}

hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
    --if partyFrames[frame:GetName()] then
        RunOnUpdateName(frame)
    --end
end)

-- i cba this whole fucking module is fkn aids causing taint and shit idek i cba i cba i cba