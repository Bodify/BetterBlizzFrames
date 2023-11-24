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

local function CheckUnit(frame, unit, party)
    local originalNameObject = frame.name or frame.Name
    local newName
    local showSpecName = BetterBlizzFramesDB.showSpecName
    local shortSpecName = BetterBlizzFramesDB.shortArenaSpecName
    local showArenaID = BetterBlizzFramesDB.showArenaID
    local hidePartyNames = BetterBlizzFramesDB.hidePartyNames
    local partyArenaNames = BetterBlizzFramesDB.partyArenaNames

    if (party and hidePartyNames) and not partyArenaNames then
        frame.cleanName:SetAlpha(0)
        originalNameObject:SetAlpha(0)
        print("test")
        return
    end

    if UnitIsUnit(unit, "player") then
        frame.cleanName:SetText(GetUnitName(unit, true))
        frame.cleanName:SetAlpha(1)
        originalNameObject:SetAlpha(0)
    elseif UnitIsUnit(unit, "party1") then
        local specID
        local Details = Details
        if Details and Details.realversion >= 134 then
            local unitGUID = UnitGUID(unit)
            specID = Details:GetSpecByGUID(unitGUID)
        end
        local specName = specID and specIDToName[specID]
        if shortSpecName then
            specName = specID and specIDToNameShort[specID]
        end

        if specName then
            if showSpecName and showArenaID then
                newName = specName .. " 1"
            elseif showSpecName then
                newName = specName
            elseif showArenaID then
                newName = "Party 1"
            end
            frame.cleanName:SetText(newName)
            frame.cleanName:SetAlpha(1)
            originalNameObject:SetAlpha(0)
        end

    elseif UnitIsUnit(unit, "party2") then
        local specID
        local Details = Details
        if Details and Details.realversion >= 134 then
            local unitGUID = UnitGUID(unit)
            specID = Details:GetSpecByGUID(unitGUID)
        end
        local specName = specID and specIDToName[specID]
        if shortSpecName then
            specName = specID and specIDToNameShort[specID]
        end

        if specName then
            if showSpecName and showArenaID then
                newName = specName .. " 2"
            elseif showSpecName then
                newName = specName
            elseif showArenaID then
                newName = "Party 2"
            end
            frame.cleanName:SetText(newName)
            frame.cleanName:SetAlpha(1)
            originalNameObject:SetAlpha(0)
        end

    elseif UnitIsUnit(unit, "arena1") then
        local specID = GetArenaOpponentSpec(1)
        local specName = specID and specIDToName[specID]
        if shortSpecName then
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

    elseif UnitIsUnit(unit, "arena2") then
        local specID = GetArenaOpponentSpec(2)
        local specName = specID and specIDToName[specID]
        if shortSpecName then
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

    elseif UnitIsUnit(unit, "arena3") then
        local specID = GetArenaOpponentSpec(3)
        local specName = specID and specIDToName[specID]
        if shortSpecName then
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
    else
        frame.cleanName:SetText(GetUnitName(unit, true))
        frame.cleanName:SetAlpha(0)
        if not hidePartyNames and party then
            originalNameObject:SetAlpha(1)
        end
    end
end

function ChangeName(frame, unit, party)
    local originalNameObject = frame.name or frame.Name
    local name = GetUnitName(unit, true)
    local newName

    local isPlayer = UnitIsPlayer(unit)
    local removeRealm = BetterBlizzFramesDB.removeRealmNames
    local isInArena = IsActiveBattlefieldArena() and ((BetterBlizzFramesDB.partyArenaNames and party) or BetterBlizzFramesDB.targetAndFocusArenaNames)
    local hidePartyNames = BetterBlizzFramesDB.hidePartyNames
    local classColorNames = BetterBlizzFramesDB.classColorTargetNames

    if not frame.cleanName then
        local a, p, a2, x, y = originalNameObject:GetPoint()
        frame.cleanName = frame:CreateFontString(nil, "OVERLAY")
        frame.cleanName:SetFont(originalNameObject:GetFont())
        frame.cleanName:SetJustifyH(originalNameObject:GetJustifyH())
        frame.cleanName:SetJustifyV(originalNameObject:GetJustifyV())
        frame.cleanName:SetTextColor(originalNameObject:GetTextColor())
        frame.cleanName:SetShadowColor(PlayerName:GetShadowColor())
        frame.cleanName:SetShadowOffset(originalNameObject:GetShadowOffset())
        frame.cleanName:SetShadowColor(originalNameObject:GetShadowColor())
        frame.cleanName:SetWidth(originalNameObject:GetWidth() + 10)
        frame.cleanName:SetWordWrap(false)

        if BetterBlizzFramesDB.centerNames and not party then
            frame.cleanName:SetJustifyH("CENTER")
            frame.cleanName:SetPoint("TOP", frame.HealthBar, "TOP", 2, 13)
            if frame == TargetFrame.totFrame or frame == FocusFrame.totFrame then
                frame.cleanName:SetJustifyH("CENTER")
                local _,anchor,_,_,yPos = originalNameObject:GetPoint()
                frame.cleanName:ClearAllPoints()
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
                frame.cleanName:SetPoint(a, p, a2, x, y-2)
            end
        end

        for i = 1, 4 do
            if frame == PartyFrame["MemberFrame" .. i] then
                local hideRole = BetterBlizzFramesDB.hidePartyRoles
                if hideRole then
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

    if (classColorNames and not party) and isPlayer then
        local _, class = UnitClass(unit)
        if class then
            local classColor = RAID_CLASS_COLORS[class]
            if classColor then
                frame.cleanName:SetTextColor(classColor.r, classColor.g, classColor.b)
                originalNameObject:SetTextColor(classColor.r, classColor.g, classColor.b)
                if BetterBlizzFramesDB.classColorLevelText then
                    if frame.LevelText then
                        frame.LevelText:SetTextColor(classColor.r, classColor.g, classColor.b)
                    end
                end
            end
        end
    elseif (classColorNames and not party) and not isPlayer then
        frame.cleanName:SetTextColor(1, 0.81960791349411, 0, 1)
        originalNameObject:SetTextColor(1, 0.81960791349411, 0, 1)
    end

    if isInArena then
        if party then
            if BetterBlizzFramesDB.partyArenaNames then
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
            if BetterBlizzFramesDB.targetAndFocusArenaNames then
                CheckUnit(frame, unit)
            else
                if frame.cleanName then
                    frame.cleanName:SetAlpha(0)
                end
                originalNameObject:SetAlpha(1)
            end
        end
    elseif hideNames and party then
        originalNameObject:SetAlpha(0)
        if frame.cleanName then
            frame.cleanName:SetAlpha(0)
        end
    elseif removeRealm then
        if party then
            if hidePartyName then
                frame.cleanName:SetAlpha(0)
            else
                if name then
                    newName = string.gsub(name, "-.*$", "")
                end
                frame.cleanName:SetText(newName)
                frame.cleanName:SetAlpha(1)
            end
            originalNameObject:SetAlpha(0)
        else
            if isPlayer and name then
                newName = string.gsub(name, "-.*$", "")
            else
                newName = name
            end
            frame.cleanName:SetText(newName)
            frame.cleanName:SetAlpha(1)
            originalNameObject:SetAlpha(0)
        end
    else
        if isPlayer then
            newName = string.gsub(name, "%-.+", " (*)")
            frame.cleanName:SetText(newName)
        else
            frame.cleanName:SetText(name)
        end
        frame.cleanName:SetAlpha(1)
        if party then
            if hidePartyName then
                originalNameObject:SetAlpha(0)
            else
                originalNameObject:SetAlpha(1)
            end
        else
            originalNameObject:SetAlpha(0)
        end
    end
end

function BBF.PartyNameChange()
    if CompactPartyFrame:IsVisible() then
        for i = 1, 3 do
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
    if BetterBlizzFramesDB.targetAndFocusArenaNames or BetterBlizzFramesDB.removeRealmNames or BetterBlizzFramesDB.classColorTargetNames then
        ChangeName(TargetFrame.TargetFrameContent.TargetFrameContentMain, "target")
        ChangeName(FocusFrame.TargetFrameContent.TargetFrameContentMain, "focus")
        ChangeName(TargetFrame.totFrame, "targettarget")
        ChangeName(FocusFrame.totFrame, "focustarget")
    end
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

local UpdateTargetAndFocusNames = CreateFrame("Frame")
UpdateTargetAndFocusNames:RegisterEvent("PLAYER_TARGET_CHANGED")
UpdateTargetAndFocusNames:RegisterEvent("PLAYER_FOCUS_CHANGED")
UpdateTargetAndFocusNames:SetScript("OnEvent", function(self, event, ...)
    local classColorTargetRep = BetterBlizzFramesDB.classColorTargetReputationTexture
    local classColorFocusRep = BetterBlizzFramesDB.classColorFocusReputationTexture
    TargetAndFocusNameChange()
    BBF.PartyNameChange()
    if classColorTargetRep then
        BBF.ClassColorReputation(TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, "target")
    end
    if classColorFocusRep then
        BBF.ClassColorReputation(FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, "focus")
    end
end)

function BBF.ClassColorPlayerName()
    local frame = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain
    if BetterBlizzFramesDB.classColorTargetNames then
        if not coloredName then
            local _, class = UnitClass("player")
            if class then
                local classColor = RAID_CLASS_COLORS[class]
                if classColor then
                    if frame.cleanName then
                        frame.cleanName:SetTextColor(classColor.r, classColor.g, classColor.b)
                    end
                    PlayerName:SetTextColor(classColor.r, classColor.g, classColor.b)
                    if BetterBlizzFramesDB.classColorLevelText then
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
    if BetterBlizzFramesDB.classColorTargetNames then
        local _, class = UnitClass(unit)
        local isPlayer = UnitIsPlayer(unit)
        if class and isPlayer then
            local classColor = RAID_CLASS_COLORS[class]
            if classColor then
                if name then
                    name:SetTextColor(classColor.r, classColor.g, classColor.b)
                end
                if BetterBlizzFramesDB.classColorLevelText then
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
    ClassColorNames(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.cleanName, "player", PlayerLevelText)
    ClassColorNames(TargetFrame.TargetFrameContent.TargetFrameContentMain.cleanName, "target", TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText)
    ClassColorNames(FocusFrame.TargetFrameContent.TargetFrameContentMain.cleanName, "focus", FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText)
    ClassColorNames(TargetFrame.totFrame.cleanName, "targettarget")
    ClassColorNames(TargetFrame.totFrame.cleanName, "focustarget")
    ClassColorNames(TargetFrame.totFrame.Name, "targettarget")
    ClassColorNames(TargetFrame.totFrame.Name, "focustarget")
end

local function UpdateToTName(frame, unit)
    local isPlayer = UnitIsPlayer(unit)
    local name = GetUnitName(unit)
    local removeRealmNames = BetterBlizzFramesDB.removeRealmNames
    local newName = name
    if isPlayer and removeRealmNames then
        newName = string.gsub(name, "-.*$", "")
    end
    if frame.cleanName then
        frame.cleanName:SetText(newName)
    end
end


local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_TARGET")
frame:SetScript("OnEvent", function(self, event, unit)
    if unit == "target" then
        UpdateToTName(TargetFrame.totFrame, "targettarget")
        UpdateToTName(FocusFrame.totFrame, "focustarget")

        ClassColorNames(TargetFrame.totFrame.Name, "targettarget")
        ClassColorNames(TargetFrame.totFrame.cleanName, "targettarget")
    elseif unit =="focus" then
        ClassColorNames(FocusFrame.totFrame.Name, "focustarget")
        ClassColorNames(FocusFrame.totFrame.cleanName, "focustarget")
    end
end)


function BBF.AllCaller()
    local hidePartyName = BetterBlizzFramesDB.hidePartyNames
    local hidePartyRole = BetterBlizzFramesDB.hidePartyRoles

    BBF.PartyNameChange()
    TargetAndFocusNameChange()
    BBF.OnUpdateName()
    if hidePartyName or hidePartyRole then
        BBF.OnUpdateName()
    end
end

function BBF.RunOnUpdateName()
    local hidePartyName = BetterBlizzFramesDB.hidePartyNames
    local hidePartyRole = BetterBlizzFramesDB.hidePartyRoles
    if hidePartyName or hidePartyRole then
        BBF.OnUpdateName()
    end
end

function BBF.OnUpdateName()
    local hideNames = BetterBlizzFramesDB.hidePartyNames
    local hideRoles = BetterBlizzFramesDB.hidePartyRoles
    local arenaNames = BetterBlizzFramesDB.partyArenaNames
    local realmNameFix = BetterBlizzFramesDB.removeRealmNames
    local scaleNames = true
    local defaultPartyFrame = PartyFrame

    local groupMembers = GetNumGroupMembers()
    for i = 1, groupMembers do
        local compactPartyMember = _G["CompactPartyFrameMember" .. i]
        local roleIcon = _G["CompactPartyFrameMember" .. i .. "RoleIcon"]
        local defaultMember = defaultPartyFrame["MemberFrame" .. i]

        if compactPartyMember and compactPartyMember:IsVisible() then
            -- Hide the name if hidePartyNames is true
--[=[
            if (hideNames and compactPartyMember.name) and not arenaNames then -- mby remove all this cuz already done with realm/arena thing, test bodify
                compactPartyMember.name:SetAlpha(0)
                if compactPartyMember.cleanName then
                    compactPartyMember.cleanName:SetAlpha(0)
                end
            end

]=]

            -- Hide the role icon if hidePartyRoles is true
            if hideRoles and compactPartyMember.roleIcon then
                compactPartyMember.roleIcon:SetAlpha(0)
                compactPartyMember.name:SetPoint("TOPLEFT", roleIcon, "TOPRIGHT", -10, -1)
                if compactPartyMember.cleanName then
                    compactPartyMember.cleanName:SetPoint("TOPLEFT", roleIcon, "TOPRIGHT", -10, -1)
                end
            else
                compactPartyMember.roleIcon:SetAlpha(1)
                compactPartyMember.name:SetPoint("TOPLEFT", roleIcon, "TOPRIGHT", 0, -1)
                if compactPartyMember.cleanName then
                    compactPartyMember.cleanName:SetPoint("TOPLEFT", roleIcon, "TOPRIGHT", 0, -1)
                end
            end

--[=[
            if hideRoles and not hideNames and compactPartyMember.name and roleIcon then
                compactPartyMember.name:SetPoint("TOPLEFT", roleIcon, "TOPRIGHT", -10, -1)
                if compactPartyMember.cleanName then
                    compactPartyMember.cleanName:SetPoint("TOPLEFT", roleIcon, "TOPRIGHT", -10, -1)
                end
            else
                if compactPartyMember.name and roleIcon then
                    compactPartyMember.name:SetPoint("TOPLEFT", roleIcon, "TOPRIGHT", 0, -1)
                    if compactPartyMember.cleanName then
                        compactPartyMember.cleanName:SetPoint("TOPLEFT", roleIcon, "TOPRIGHT", 0, -1)
                    end
                end
            end

]=]

        else
            if defaultMember then --will always be true find fix bodify
                if (hideNames and defaultMember.name) and not arenaNames then
                    defaultMember.Name:SetAlpha(0)
                    if defaultMember.cleanName then
                        defaultMember.cleanName:SetAlpha(0)
                    end
                else
                    defaultMember.Name:SetAlpha(1)
                    if defaultMember.cleanName then
                        defaultMember.cleanName:SetAlpha(1)
                    end
                end

                if hideRoles and defaultMember.PartyMemberOverlay.RoleIcon then
                    defaultMember.PartyMemberOverlay.RoleIcon:SetAlpha(0)
                else
                    defaultMember.PartyMemberOverlay.RoleIcon:SetAlpha(1)
                end
            end
        end
    end
end

function BBF.CenteredFrameNames(frame, unit)
    local originalNameObject = frame.Name

    local a, b, c, x, y = originalNameObject:GetPoint()
    originalNameObject:SetAlpha(0)
    if BetterBlizzFramesDB.centerNames then
        if not frame.cleanName then
            frame.cleanName = frame:CreateFontString(nil, "OVERLAY")
            frame.cleanName:SetFont(originalNameObject:GetFont())
            frame.cleanName:SetTextColor(1, 0.81960791349411, 0)
            frame.cleanName:SetShadowColor(originalNameObject:GetShadowColor())
            frame.cleanName:SetShadowOffset(originalNameObject:GetShadowOffset())
            frame.cleanName:SetShadowColor(originalNameObject:GetShadowColor())
        end
        frame.cleanName:SetJustifyH("CENTER")
        frame.cleanName:SetJustifyV(originalNameObject:GetJustifyV())
        frame.cleanName:SetWidth(originalNameObject:GetWidth())
        frame.cleanName:ClearAllPoints()
        frame.cleanName:SetPoint("TOP", frame.HealthBar, "TOP", 2, 13)
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
            frame.cleanName:ClearAllPoints()
            frame.cleanName:SetPoint(a,b,c,x,y-2)
            frame.cleanName:SetAlpha(1)
        end
        --frame.cleanName:SetAlpha(0)
        --originalNameObject:SetAlpha(1)
    end
end



local function CenteredPlayerName()
    local frame = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain
    if BetterBlizzFramesDB.centerNames then
        PlayerName:SetAlpha(0)
        if not frame.cleanName then
            frame.cleanName = frame:CreateFontString(nil, "OVERLAY")
            frame.cleanName:SetFont(PlayerName:GetFont())
            frame.cleanName:SetJustifyH("CENTER")
            frame.cleanName:SetJustifyV(PlayerName:GetJustifyV())
            frame.cleanName:SetText(GetUnitName("player", true))
            frame.cleanName:ClearAllPoints()
            frame.cleanName:SetPoint("TOP", frame.HealthBarArea.HealthBar, "TOP", 0, 13)
            --frame.cleanName:SetTextColor(1, 0.81960791349411, 0)
            frame.cleanName:SetShadowColor(PlayerName:GetShadowColor())
            frame.cleanName:SetShadowOffset(PlayerName:GetShadowOffset())
            frame.cleanName:SetShadowColor(PlayerName:GetShadowColor())
            frame.cleanName:SetHeight(PlayerName:GetHeight())
            frame.cleanName:SetWidth(PlayerName:GetWidth())
        end
        frame.cleanName:SetAlpha(1)
    else
        PlayerName:SetAlpha(1)
        if frame.cleanName then
            frame.cleanName:SetAlpha(0)
        end
    end
end

function BBF.SetCenteredNamesCaller()
    CenteredPlayerName()
    --BBF.CenteredFrameNames(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain, "player")
    BBF.CenteredFrameNames(TargetFrame.TargetFrameContent.TargetFrameContentMain, "target")
    BBF.CenteredFrameNames(FocusFrame.TargetFrameContent.TargetFrameContentMain, "focus")
end


hooksecurefunc("CompactUnitFrame_UpdateName", BBF.RunOnUpdateName)