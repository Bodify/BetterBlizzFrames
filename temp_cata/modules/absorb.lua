local CataAbsorb = {}
CataAbsorb.spells = {
    [17] = true, -- Priest: Power Word: Shield
    [47753] = true, -- Priest: Divine Aegis
    [86273] = true, -- Paladin: Illuminated Healing
    [96263] = true, -- Paladin: Sacred Shield
    [62606] = true, -- Druid: Savage Defense
    [77535] = true, -- DK: Blood Shield
    [1463] = true, -- Mage: Mana Shield
    [11426] = true, -- Mage: Ice Barrier
    [98864] = true, -- Mage: Ice Barrier
    [55277] = true, -- Shaman: Totem Shield
}

local function ComputeAbsorb(unit)
    local value = 0
    local maxAbsorbIcon = nil
    for index = 1, 40 do
        local name, icon, _, _, _, _, _, _, _, spellId, _, _, _, _, _, _, absorb = UnitAura(unit, index)
        if not name then break end
        if CataAbsorb.spells[spellId] and absorb then
            value = value + absorb
            maxAbsorbIcon = icon -- Always use the last matching icon
        end
    end
    return value, maxAbsorbIcon
end

local function RaiseStrataOnHpText(frame)
    local leftText = _G[frame.."HealthBarTextLeft"] or _G[frame].textureFrame.HealthBarTextLeft
    local rightText = _G[frame.."HealthBarTextRight"] or _G[frame].textureFrame.HealthBarTextRight
    local centerText = _G[frame.."HealthBarText"] or _G[frame].textureFrame.HealthBarText

    if leftText then
        leftText:SetDrawLayer("OVERLAY")
    end
    if rightText then
        rightText:SetDrawLayer("OVERLAY")
    end
    if centerText then
        centerText:SetDrawLayer("OVERLAY")
    end
end

local function UpdateAbsorbIndicator(frame, unit)
    if not BetterBlizzFramesDB.absorbIndicator and not BetterBlizzFramesDB.absorbIndicatorTestMode then return end

    local settingsPrefix = unit
    local showAmount = BetterBlizzFramesDB[settingsPrefix .. "AbsorbAmount"]
    local showIcon = BetterBlizzFramesDB[settingsPrefix .. "AbsorbIcon"]
    local xPos = BetterBlizzFramesDB.playerAbsorbXPos
    local yPos = BetterBlizzFramesDB.playerAbsorbYPos
    local anchor = BetterBlizzFramesDB.playerAbsorbAnchor
    local reverseAnchor = BBF.GetOppositeAnchor(anchor)
    local darkModeOn = BetterBlizzFramesDB.darkModeUi
    local vertexColor = darkModeOn and BetterBlizzFramesDB.darkModeColor or 1
    local testMode = BetterBlizzFramesDB.absorbIndicatorTestMode
    local flipIconText = BetterBlizzFramesDB.absorbIndicatorFlipIconText

    if not frame.absorbParent then
        frame.absorbParent = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        frame.absorbParent:SetSize(50, 50) -- Set this size to fit both icon and text
        frame.absorbParent:SetPoint("CENTER", frame, "CENTER", xPos, yPos) -- Position it according to your needs
        frame.absorbParent:SetFrameStrata("HIGH")

        frame.absorbIcon = frame.absorbParent:CreateTexture(nil, "OVERLAY")
        frame.absorbIcon:SetSize(20, 20)
        frame.absorbIcon:SetPoint("CENTER", frame.absorbParent, "CENTER") -- Position the icon inside the parent frame

        frame.absorbIndicator = frame.absorbParent:CreateFontString(nil, "OVERLAY")
        frame.absorbIndicator:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
        frame.absorbIndicator:SetPoint("CENTER", frame.absorbParent, "CENTER") -- Position the text inside the parent frame
        frame.absorbIndicator:SetDrawLayer("OVERLAY", 7)
    end

    -- Ensure the border is attached to the absorbParent and appears above the icon
    if not frame.absorbIcon.border then
        local border = CreateFrame("Frame", nil, frame.absorbParent, "BackdropTemplate")
        border:SetBackdrop({
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tileEdge = true,
            edgeSize = 8,
        })

        border:SetPoint("TOPLEFT", frame.absorbIcon, "TOPLEFT", -2, 2)
        border:SetPoint("BOTTOMRIGHT", frame.absorbIcon, "BOTTOMRIGHT", 2, -2)
        border:SetFrameLevel(frame.absorbParent:GetFrameLevel() + 1)  -- Ensure the border is above the icon
        frame.absorbIcon.border = border
    end

    if darkModeOn then
        frame.absorbIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        frame.absorbIcon.border:SetBackdropBorderColor(vertexColor, vertexColor, vertexColor)
        frame.absorbIcon.border:SetAlpha(0)
    else
        frame.absorbIcon:SetTexCoord(0, 1, 0, 1)
        frame.absorbIcon.border:SetAlpha(0)
    end

    frame.absorbIcon:ClearAllPoints()
    frame.absorbIndicator:ClearAllPoints()

    if frame == PlayerFrame then
        xPos = xPos * -1 -- invert the xPos value for PlayerFrame
    end

    if testMode then
        frame.absorbIcon:SetTexture("Interface\\Icons\\SPELL_HOLY_POWERWORDSHIELD")
        frame.absorbIcon:SetAlpha(1)
        frame.absorbIndicator:SetText("69k")
        frame.absorbIndicator:SetAlpha(1)
        if frame == PlayerFrame then
            if anchor == "LEFT" or anchor == "RIGHT" then
                frame.absorbIcon:SetPoint(anchor, frame, reverseAnchor, -45 + xPos, 2.5 + yPos)
            else
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, -5 + xPos, -21.5 + yPos)
            end
            if showIcon then
                if darkModeOn then
                    frame.absorbIcon.border:SetAlpha(1)
                else
                    frame.absorbIcon.border:SetAlpha(0)
                end
                if flipIconText then
                    frame.absorbIndicator:SetPoint("RIGHT", frame.absorbIcon, "LEFT", 0, 0)
                else
                    frame.absorbIndicator:SetPoint("LEFT", frame.absorbIcon, "RIGHT", 3, 0)
                end
            else
                frame.absorbIndicator:SetPoint("LEFT", frame.absorbIcon, "RIGHT", -23, 0)
            end
        else
            if anchor == "LEFT" or anchor =="RIGHT" then
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, -5 + xPos, 3 + yPos)
            else
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, 5 + xPos, -21 + yPos)
            end
            if showIcon then
                if darkModeOn then
                    frame.absorbIcon.border:SetAlpha(1)
                else
                    frame.absorbIcon.border:SetAlpha(0)
                end
                if flipIconText then
                    frame.absorbIndicator:SetPoint("LEFT", frame.absorbIcon, "RIGHT", 3, 0)
                else
                    frame.absorbIndicator:SetPoint("RIGHT", frame.absorbIcon, "LEFT", 0, 0)
                end
            else
                frame.absorbIndicator:SetPoint("RIGHT", frame.absorbIcon, "LEFT", 20, 0)
            end
        end
        return
    end

    if showAmount then
        if frame == PlayerFrame then
            if anchor == "LEFT" or anchor == "RIGHT" then
                frame.absorbIcon:SetPoint(anchor, frame, reverseAnchor, -45 + xPos, 2.5 + yPos)
            else
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, -5 + xPos, -21.5 + yPos)
            end
            if showIcon then
                if darkModeOn then
                    frame.absorbIcon.border:SetAlpha(1)
                else
                    frame.absorbIcon.border:SetAlpha(0)
                end
                if flipIconText then
                    frame.absorbIndicator:SetPoint("RIGHT", frame.absorbIcon, "LEFT", 0, 0)
                else
                    frame.absorbIndicator:SetPoint("LEFT", frame.absorbIcon, "RIGHT", 3, 0)
                end
            else
                frame.absorbIndicator:SetPoint("LEFT", frame.absorbIcon, "RIGHT", -23, 0)
            end
        else
            if anchor == "LEFT" or anchor =="RIGHT" then
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, -5 + xPos, 3 + yPos)
            else
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, 5 + xPos, -21 + yPos)
            end
            if showIcon then
                if darkModeOn then
                    frame.absorbIcon.border:SetAlpha(1)
                else
                    frame.absorbIcon.border:SetAlpha(0)
                end
                if flipIconText then
                    frame.absorbIndicator:SetPoint("LEFT", frame.absorbIcon, "RIGHT", 3, 0)
                else
                    frame.absorbIndicator:SetPoint("RIGHT", frame.absorbIcon, "LEFT", 0, 0)
                end
            else
                frame.absorbIndicator:SetPoint("RIGHT", frame.absorbIcon, "LEFT", 20, 0)
            end
        end

        frame.absorbIndicator:SetScale(BetterBlizzFramesDB.absorbIndicatorScale)
        frame.absorbIcon:SetScale(BetterBlizzFramesDB.absorbIndicatorScale)

        local totalAbsorb, auraIcon = ComputeAbsorb(unit)
        if totalAbsorb >= 100 then
            --local displayValue = math.floor(totalAbsorb / 1000) .. "k"
            local displayValue
            if totalAbsorb >= 1000 then
                displayValue = string.format("%.1fk", totalAbsorb / 1000)
            else
                displayValue = tostring(totalAbsorb)
            end
            frame.absorbIndicator:SetText(displayValue)
            frame.absorbIndicator:SetAlpha(1)

            if showIcon then
                if auraIcon then
                    frame.absorbIcon:SetTexture(auraIcon)
                    frame.absorbIcon:SetAlpha(1)
                    if frame.absorbIcon.border and darkModeOn then
                        frame.absorbIcon.border:SetAlpha(1)
                    end
                else
                    frame.absorbIcon:SetAlpha(0)
                    if frame.absorbIcon.border then
                        frame.absorbIcon.border:SetAlpha(0)
                    end
                end
            else
                frame.absorbIcon:SetAlpha(0)
                if frame.absorbIcon.border then
                    frame.absorbIcon.border:SetAlpha(0)
                end
            end
        else
            frame.absorbIndicator:SetAlpha(0)
            frame.absorbIcon:SetAlpha(0)
            if frame.absorbIcon.border then
                frame.absorbIcon.border:SetAlpha(0)
            end
        end
    else
        if frame.absorbIndicator then frame.absorbIndicator:SetAlpha(0) end
        if frame.absorbIcon then frame.absorbIcon:SetAlpha(0) end
        if frame.absorbIcon.border then
            frame.absorbIcon.border:SetAlpha(0)
        end
    end
end


local absorbHooked = false
function BBF.AbsorbCaller()
    --if not cataReady then return end

    UpdateAbsorbIndicator(PlayerFrame, "player")
    UpdateAbsorbIndicator(TargetFrame, "target")
    UpdateAbsorbIndicator(FocusFrame, "focus")
    if not BetterBlizzFramesDB.absorbIndicator and not BetterBlizzFramesDB.absorbIndicatorTestMode then
        if TargetFrame.absorbIcon and TargetFrame.absorbIcon.border then TargetFrame.absorbIcon.border:SetAlpha(0) end
        if TargetFrame.absorbIndicator then TargetFrame.absorbIndicator:SetAlpha(0) end
        if TargetFrame.absorbIcon then TargetFrame.absorbIcon:SetAlpha(0) end
        if PlayerFrame.absorbIndicator then PlayerFrame.absorbIndicator:SetAlpha(0) end
        if PlayerFrame.absorbIcon then PlayerFrame.absorbIcon:SetAlpha(0) end
        if PlayerFrame.absorbIcon and PlayerFrame.absorbIcon.border then PlayerFrame.absorbIcon.border:SetAlpha(0) end
        if FocusFrame.absorbIndicator then FocusFrame.absorbIndicator:SetAlpha(0) end
        if FocusFrame.absorbIcon then FocusFrame.absorbIcon:SetAlpha(0) end
        if FocusFrame.absorbIcon and FocusFrame.absorbIcon.border then FocusFrame.absorbIcon.border:SetAlpha(0) end
    end
    if not absorbHooked then
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:RegisterEvent("GROUP_ROSTER_UPDATE")
        frame:RegisterEvent("UNIT_HEALTH")
        frame:RegisterEvent("UNIT_MAXHEALTH")
        frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        frame:RegisterEvent("PLAYER_TARGET_CHANGED")
        frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
        frame:SetScript("OnEvent", function(self, event, ...)
            if event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" then
                BBF.AbsorbCaller()
            elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
                local unit = ...
                if unit == "player" then
                    UpdateAbsorbIndicator(PlayerFrame, unit)
                elseif unit == "target" then
                    UpdateAbsorbIndicator(TargetFrame, unit)
                elseif unit == "focus" then
                    UpdateAbsorbIndicator(FocusFrame, unit)
                end
                -- UpdateAbsorbIndicator(PlayerFrame, unit)
                -- UpdateAbsorbIndicator(TargetFrame, unit)
                -- UpdateAbsorbIndicator(FocusFrame, unit)
            elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
                local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName = CombatLogGetCurrentEventInfo()
                if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" or subEvent == "SPELL_AURA_REMOVED" then
                    local spellId = select(12, CombatLogGetCurrentEventInfo())
                    if not CataAbsorb.spells[spellId] then return end
                    UpdateAbsorbIndicator(PlayerFrame, "player")
                    UpdateAbsorbIndicator(TargetFrame, "target")
                    UpdateAbsorbIndicator(FocusFrame, "focus")
                end
            elseif event == "PLAYER_TARGET_CHANGED" then
                UpdateAbsorbIndicator(TargetFrame, "target")
            elseif event == "PLAYER_FOCUS_CHANGED" then
                UpdateAbsorbIndicator(FocusFrame, "focus")
            end
        end)

        RaiseStrataOnHpText("PlayerFrame")
        RaiseStrataOnHpText("TargetFrame")
        RaiseStrataOnHpText("FocusFrame")

        absorbHooked = true
    end
end


local CataAbsorb = {}
CataAbsorb.spells = {
    [17] = true, -- Priest: Power Word: Shield
    [47753] = true, -- Priest: Divine Aegis
    [86273] = true, -- Paladin: Illuminated Healing
    [96263] = true, -- Paladin: Sacred Shield
    [62606] = true, -- Druid: Savage Defense
    [77535] = true, -- DK: Blood Shield
    [1463] = true, -- Mage: Mana Shield
    [11426] = true, -- Mage: Ice Barrier
    [98864] = true, -- Mage: Ice Barrier
}


local function CreateAbsorbBar(frame)
    local absorbBar = CreateFrame("StatusBar", nil, frame)
    absorbBar:SetStatusBarTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\absorbStripes")
    absorbBar:SetMinMaxValues(0, 100)
    absorbBar:SetValue(0)
    absorbBar:SetStatusBarColor(0.7, 0.7, 1, 0.7)
    absorbBar:SetFrameLevel(frame:GetFrameLevel() + 1)
    if not TargetFrameToT.adjustedLevel then
        PlayerFrameTexture:GetParent():SetFrameLevel(56)--5
        TargetFrameTextureFrame:SetFrameLevel(55)
        FocusFrameTextureFrame:SetFrameLevel(55)
        if not InCombatLockdown() then
            TargetFrameToT:SetFrameLevel(56)
        end
        TargetFrameToT.adjustedLevel = true
    end

    -- Maintain the aspect ratio of the texture
    local tex = absorbBar:GetStatusBarTexture()
    tex:SetHorizTile(true) -- Repeat the texture horizontally
    --tex:SetVertTile(true) -- Repeat the texture vertically

    -- -- Hook the SetValue method to update the texture coordinates
    -- hooksecurefunc(absorbBar, "SetValue", function(self, value)
    --     local min, max = self:GetMinMaxValues()
    --     local percentage = value / max
    --     local width = self:GetWidth() * percentage
    --     local height = self:GetHeight()

    --     -- Calculate texCoord to maintain aspect ratio
    --     local texWidth = width / tex:GetWidth()
    --     local texHeight = height / tex:GetHeight()

    --     if texWidth > 1 then
    --         texWidth = 1
    --     end

    --     tex:SetTexCoord(0, texWidth, 0, texHeight)
    -- end)

    return absorbBar
end


local function HookUnitFrame(frame)
    if not frame then return end

    if not frame.absorbBar then
        frame.absorbBar = CreateAbsorbBar(frame)
        frame.absorbBar:SetPoint("TOPLEFT", frame, "TOPLEFT")
        frame.absorbBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
        frame.absorbBar:SetWidth(frame:GetWidth())
    end
end

local function HookAllFrames()
    -- Hook party frames
    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember" .. i]
        if frame then
            HookUnitFrame(frame.healthBar)
        end
    end

    -- Hook raid frames
    for i = 1, 5 do
        local frame = _G["CompactRaidFrame" .. i]
        if frame then
            HookUnitFrame(frame.healthBar)
        end
    end

    -- Hook other frames
    HookUnitFrame(_G["PlayerFrame"].healthbar)
    HookUnitFrame(_G["TargetFrame"].healthbar)
    HookUnitFrame(_G["FocusFrame"].healthbar)
end

local function UpdateFrame(unit)
    local function CheckAndHookFrame(frame, healthBar)
        if frame and frame.unit and UnitIsUnit(unit, frame.unit) then
            if not healthBar.absorbBar then
                healthBar.absorbBar = CreateAbsorbBar(healthBar)
            end

            local state = CataAbsorb.allstates[unit]
            if state and state.show then
                local width, height = healthBar:GetSize()

                healthBar.absorbBar:SetOrientation("HORIZONTAL")
                healthBar.absorbBar:ClearAllPoints()
                local additionalOffset = 0
                if frame == _G["TargetFrame"] or frame == _G["FocusFrame"] then
                    additionalOffset = 3
                end

                if state.healthPercent + (state.value / 100) > 1 then
                    local absorbWidth = width * (state.value / 100)
                    healthBar.absorbBar:SetPoint("TOPLEFT", healthBar, "TOPLEFT", width - absorbWidth - additionalOffset, 0)
                    healthBar.absorbBar:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", width - absorbWidth - additionalOffset, 0)
                else
                    local offset = math.floor(width * state.healthPercent)
                    healthBar.absorbBar:SetPoint("TOPLEFT", healthBar, "TOPLEFT", offset - additionalOffset, 0)
                    healthBar.absorbBar:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", offset - additionalOffset, 0)
                    healthBar.absorbBar:SetWidth(width - offset + additionalOffset)
                end

                healthBar.absorbBar:SetSize(width, height)
                healthBar.absorbBar:SetValue(state.value)
                healthBar.absorbBar:Show()
            else
                if healthBar.absorbBar then
                    healthBar.absorbBar:Hide()
                end
            end
        end
    end

    local framesToCheck = {
        {frame = _G["PlayerFrame"], healthBar = _G["PlayerFrame"].healthbar},
        {frame = _G["TargetFrame"], healthBar = _G["TargetFrameHealthBar"]},
        {frame = _G["FocusFrame"], healthBar = _G["FocusFrameHealthBar"]}
    }

    for i = 1, 5 do
        local partyFrame = _G["CompactPartyFrameMember" .. i]
        if partyFrame then
            table.insert(framesToCheck, {frame = partyFrame, healthBar = partyFrame.healthBar})
        end
    end

    for i = 1, 5 do
        local raidFrame = _G["CompactRaidFrame" .. i]
        if raidFrame then
            table.insert(framesToCheck, {frame = raidFrame, healthBar = raidFrame.healthBar})
        end
    end

    for _, frameInfo in ipairs(framesToCheck) do
        CheckAndHookFrame(frameInfo.frame, frameInfo.healthBar)
    end
end


CataAbsorb.playerName = UnitName("player")

local validUnits = {
    ["player"] = true,
    ["target"] = true,
    ["focus"] = true,
    ["party1"] = true,
    ["party2"] = true,
    ["party3"] = true,
    ["party4"] = true,
    ["raid1"] = true,
    ["raid2"] = true,
    ["raid3"] = true,
    ["raid4"] = true,
    ["raid5"] = true,
}

local function UnitValid(unit)
    return unit and UnitExists(unit)-- and (unit == "player" or unit == "target" or unit == "focus" or UnitInParty(unit) or UnitInRaid(unit))
end

local function SetupState(allstates, unit, absorb)
    if absorb > 0 then
        local maxHealth = UnitHealthMax(unit)
        local health = UnitHealth(unit)
        local healthPercent = health / maxHealth
        local healthDeficitPercent = 1.0 - healthPercent
        local absorbPercent = absorb / maxHealth

        if healthPercent < 1.0 and absorbPercent > healthDeficitPercent then
            if absorbPercent < 2 * healthDeficitPercent then
                absorbPercent = healthDeficitPercent
            else
                absorbPercent = absorbPercent - healthDeficitPercent
            end
        end

        allstates[unit] = {
            unit = unit,
            name = unit,
            progressType = "static",
            value = absorbPercent * 100,
            total = 100,
            show = true,
            changed = true,
            healthPercent = healthPercent,
        }
    else
        allstates[unit] = {
            show = false,
            changed = true,
        }
    end
end

local function ResetAll(allstates)
    for _, state in pairs(allstates) do
        state.show = false
        state.changed = true
    end
end

local function RosterUpdated(allstates)
    for unit, state in pairs(allstates) do
        if not UnitValid(unit) then
            state.show = false
            state.changed = true
        end
    end
end

local function RefreshUnit(allstates, unit)
    if not UnitValid(unit) then return end
    local absorb = ComputeAbsorb(unit)
    SetupState(allstates, unit, absorb)
    UpdateFrame(unit)
end

local function GetRelevantUnitsByName(name)
    local units = {}
    if UnitName("player") == name then table.insert(units, "player") end
    if UnitName("target") == name then table.insert(units, "target") end
    if UnitName("focus") == name then table.insert(units, "focus") end
    for i = 1, 5 do
        if UnitName("party" .. i) == name then table.insert(units, "party" .. i) end
    end
    for i = 1, 5 do
        if UnitName("raid" .. i) == name then table.insert(units, "raid" .. i) end
    end
    return units
end

local relevantUnits = {}

local function UpdateRelevantUnits()
    relevantUnits = {}

    -- Add the player, target, and focus units if they exist
    local playerName = UnitName("player")
    if playerName then
        relevantUnits[playerName] = "player"
    end

    local targetName = UnitName("target")
    if targetName then
        relevantUnits[targetName] = "target"
    end

    local focusName = UnitName("focus")
    if focusName then
        relevantUnits[focusName] = "focus"
    end

    -- Add party units
    for i = 1, 5 do
        local unit = "party" .. i
        local name = UnitName(unit)
        if name then
            relevantUnits[name] = unit
        end
    end

    -- Add raid units
    for i = 1, 5 do
        local unit = "raid" .. i
        local name = UnitName(unit)
        if name then
            relevantUnits[name] = unit
        end
    end
end


local function OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        ResetAll(CataAbsorb.allstates)
        UpdateRelevantUnits()
        HookAllFrames()
        RefreshUnit(CataAbsorb.allstates, "player")
    elseif event == "GROUP_ROSTER_UPDATE" then
        UpdateRelevantUnits()
        RosterUpdated(CataAbsorb.allstates)
    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        local unit = select(1, ...)
        if validUnits[unit] then
            RefreshUnit(CataAbsorb.allstates, unit)
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, _, _, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()
        if destName then
            destName = Ambiguate(destName, "short")
            if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" or subEvent == "SPELL_AURA_REMOVED" then
                local spellId = select(12, CombatLogGetCurrentEventInfo())
                if not CataAbsorb.spells[spellId] then return end
                -- local units = GetRelevantUnitsByName(destName)
                -- for _, unit in ipairs(units) do
                --     RefreshUnit(CataAbsorb.allstates, unit)
                -- end
                -- Directly refresh the unit if its name matches
                local unit = relevantUnits[destName]
                if unit then
                    RefreshUnit(CataAbsorb.allstates, unit)
                end
            elseif subEvent == "SPELL_ABSORBED" then
                local unit = relevantUnits[destName]
                if unit then
                    RefreshUnit(CataAbsorb.allstates, unit)
                end
            end
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        UpdateRelevantUnits()
        RefreshUnit(CataAbsorb.allstates, "target")
    elseif event == "PLAYER_FOCUS_CHANGED" then
        UpdateRelevantUnits()
        RefreshUnit(CataAbsorb.allstates, "focus")
    end
end

local overshieldSetup = false
function BBF.HookOverShields()
    if BetterBlizzFramesDB.overShields and not overshieldSetup then
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:RegisterEvent("GROUP_ROSTER_UPDATE")
        frame:RegisterEvent("PLAYER_TARGET_CHANGED")
        frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
        -- frame:RegisterUnitEvent("UNIT_HEALTH", "player", "party", "raid", "focus", "target") --4max
        -- frame:RegisterUnitEvent("UNIT_MAXHEALTH", "player", "party", "raid", "focus", "target")
        frame:RegisterEvent("UNIT_HEALTH")
        frame:RegisterEvent("UNIT_MAXHEALTH")
        frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        frame:SetScript("OnEvent", OnEvent)

        overshieldSetup = true
    end
end

-- Initialize allstates
CataAbsorb.allstates = {}