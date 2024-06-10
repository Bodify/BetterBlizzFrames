local spellBars = {}
local castBarsCreated = false
local petCastbarCreated = false

local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo

local function GetPartyMemberFrame(unitId)
    if ( (CompactPartyFrameMember1 and CompactPartyFrameMember1:IsShown()) or (CompactRaidFrame1 and CompactRaidFrame1:IsShown()) ) and UnitExists(unitId) then
        local showSelf = BetterBlizzFramesDB.partyCastbarSelf
        for i = 1, 5 do
            local frame = _G["CompactPartyFrameMember"..i] or _G["CompactRaidFrame"..i]
            if frame and unitId and frame.unit and UnitIsUnit(frame.unit, unitId) then
                return frame, nil
            else
                if showSelf then
                    if frame.displayedUnit and UnitIsUnit(frame.displayedUnit, "player") then
                        unitId = "player"
                        return frame, unitId
                    end
                end
            end
        end
    else
        for i = 1, 5 do
            local frame = PartyFrame and PartyFrame["MemberFrame"..i]
            if frame and unitId and frame.unit and UnitIsUnit(frame.unit, unitId) then
                return frame, nil
            end
        end
    end

    return nil, nil
end

local function UpdateCastTimer(self)
    local remainingTime
    if self.casting or self.reverseChanneling then
        -- For a cast, we calculate how much time is left until the cast completes
        remainingTime = self.maxValue - self.value
    elseif self.channeling then
        -- For a channel, the remaining time is directly related to the current value
        remainingTime = self.value
    end

    -- If the remaining time is zero or somehow negative, clear the timer
    if remainingTime then
        if remainingTime <= 0 then
            self.Timer:SetText("")
            return
        end
        self.Timer:SetFormattedText("%.1f", remainingTime)
    else
        self.Timer:SetText("")
    end
end

local hiddenFrame = CreateFrame("Frame")
hiddenFrame:Hide()

function BBF.UpdateCastbars()
    if BetterBlizzFramesDB.showPartyCastbar or BetterBlizzFramesDB.partyCastBarTestMode then
        local numGroupMembers = GetNumGroupMembers()
        if numGroupMembers <= 5 then
            for i = 1, numGroupMembers do
                local unitId = "party" .. i
                if BetterBlizzFramesDB.partyCastBarTestMode and numGroupMembers == 1 then
                    unitId = "player"
                end
                local spellbar = spellBars[i]
                if spellbar then
                    spellbar:SetParent(UIParent)
                    spellbar:SetScale(BetterBlizzFramesDB.partyCastBarScale)
                    spellbar:SetWidth(BetterBlizzFramesDB.partyCastBarWidth)
                    spellbar:SetHeight(BetterBlizzFramesDB.partyCastBarHeight)

                    if not BetterBlizzFramesDB.showPartyCastBarIcon then
                        spellbar.Icon:SetAlpha(0)
                    else
                        spellbar.Icon:ClearAllPoints()
                        spellbar.Icon:SetPoint("RIGHT", spellbar, "LEFT", -4 + BetterBlizzFramesDB.partyCastbarIconXPos, BetterBlizzFramesDB.partyCastbarIconYPos - 1)
                        spellbar.Icon:SetScale(BetterBlizzFramesDB.partyCastBarIconScale)
                        spellbar.Icon:SetAlpha(1)
                    end

                    local partyFrame, newUnitId = GetPartyMemberFrame(unitId)
                    if partyFrame then
                        if newUnitId and UnitIsUnit(partyFrame.unit, "player") then
                            CastingBarFrame_SetUnit(spellbar, "player", true, true)
                        else
                            CastingBarFrame_SetUnit(spellbar, unitId, true, true)
                        end
                        spellbar:ClearAllPoints()
                        spellbar:SetPoint("CENTER", partyFrame, "CENTER", BetterBlizzFramesDB.partyCastBarXPos + 10, BetterBlizzFramesDB.partyCastBarYPos + 3)
                        spellbar:SetParent(UIParent)
                        spellbar:SetFrameStrata("MEDIUM")
                    else
                        spellbar:SetParent(hiddenFrame)
                    end
                else
                    BBF.CreateCastbars()
                end
            end
        else
            for i = 1, 5 do
                local spellbar = spellBars[i]
                if spellbar then
                    spellbar:SetParent(hiddenFrame)
                end
            end
        end
    else
        for i = 1, 5 do
            local spellbar = spellBars[i]
            if spellbar then
                spellbar:SetParent(hiddenFrame)
            end
        end
    end
end

function BBF.UpdatePetCastbar()
    local petSpellBar = spellBars["pet"]
    if petSpellBar then
        local xPos = BetterBlizzFramesDB.petCastBarXPos
        local yPos = BetterBlizzFramesDB.petCastBarYPos
        local castbarScale = BetterBlizzFramesDB.petCastBarScale
        local iconScale = BetterBlizzFramesDB.petCastBarIconScale
        local width = BetterBlizzFramesDB.petCastBarWidth
        local height = BetterBlizzFramesDB.petCastBarHeight

        petSpellBar:SetParent(UIParent)
        if not BetterBlizzFramesDB.showPetCastBarIcon then
            petSpellBar.Icon:SetAlpha(0)
            petSpellBar.BorderShield:SetAlpha(0)
        else
            petSpellBar.Icon:ClearAllPoints()
            petSpellBar.Icon:SetPoint("RIGHT", petSpellBar, "LEFT", -4 + 0, 0)
            petSpellBar.Icon:SetScale(iconScale)
            petSpellBar.Icon:SetAlpha(1)
            -- petSpellBar.BorderShield:ClearAllPoints()
            -- petSpellBar.BorderShield:SetPoint("RIGHT", petSpellBar, "LEFT", -1 + 0, -7 + 0)
            -- petSpellBar.BorderShield:SetScale(iconScale)
            -- petSpellBar.BorderShield:SetAlpha(1)
        end
        petSpellBar:SetScale(castbarScale)
        petSpellBar:SetWidth(width)
        petSpellBar:SetHeight(height)

        local petFrame = PetFrame -- Assuming PetFrame is the frame you want to attach to
        if petFrame then
            local petDetachCastbar = BetterBlizzFramesDB.petDetachCastbar
            petSpellBar:ClearAllPoints()
            if petDetachCastbar then
                petSpellBar:SetPoint("CENTER", UIParent, "CENTER", xPos, yPos)
            else
                petSpellBar:SetPoint("CENTER", petFrame, "CENTER", xPos + 4, yPos - 27)
            end
            petSpellBar:SetFrameStrata("MEDIUM")
        else
            petSpellBar:SetParent(hiddenFrame)
        end
    else
        BBF.CreateCastbars()
    end
end


function BBF.CreateCastbars()
    if not castBarsCreated and (BetterBlizzFramesDB.showPartyCastbar or BetterBlizzFramesDB.partyCastBarTestMode) then
        for i = 1, 5 do
            local spellbar = CreateFrame("StatusBar", "Party"..i.."SpellBar", UIParent, "SmallCastingBarFrameTemplate")
            spellbar:SetScale(1)

            CastingBarFrame_SetUnit(spellbar, "party"..i, true, true)
            spellbar.Text:SetFontObject("SystemFont_Shadow_Med1_Outline")
            spellbar.Icon:ClearAllPoints()
            spellbar.Icon:SetPoint("RIGHT", spellbar, "LEFT", -4, -1)
            spellbar.Icon:SetSize(22, 22)
            spellbar.Icon:SetScale(BetterBlizzFramesDB.partyCastBarIconScale)
            spellbar:SetScale(BetterBlizzFramesDB.partyCastBarScale)
            spellbar:SetWidth(BetterBlizzFramesDB.partyCastBarWidth)
            spellbar:SetHeight(BetterBlizzFramesDB.partyCastBarHeight)

            spellbar.Timer = spellbar:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1_Outline")
            spellbar.Timer:SetPoint("LEFT", spellbar, "RIGHT", 5, 0)
            spellbar.Timer:SetTextColor(1, 1, 1, 1)

            spellbar.FakeTimer = spellbar:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1_Outline")
            spellbar.FakeTimer:SetPoint("LEFT", spellbar, "RIGHT", 5, 0)
            spellbar.FakeTimer:SetTextColor(1, 1, 1, 1)
            spellbar.FakeTimer:SetText("1.8")
            spellbar.FakeTimer:Hide()

            if BetterBlizzFramesDB.partyCastBarTimer then
                spellbar:HookScript("OnUpdate", function(self, elapsed)
                    UpdateCastTimer(self, elapsed)
                end)
            end

            spellBars[i] = spellbar
        end
        BBF.UpdateCastbars()
        castBarsCreated = true
    end
    if not petCastbarCreated and (BetterBlizzFramesDB.petCastbar or BetterBlizzFramesDB.petCastbarTestmode) then
        local petSpellBar = CreateFrame("StatusBar", "PetSpellBar", UIParent, "SmallCastingBarFrameTemplate")
        petSpellBar:SetScale(1)

        CastingBarFrame_SetUnit(petSpellBar, "pet", true, true)
        petSpellBar.Text:ClearAllPoints()
        petSpellBar.Text:SetPoint("CENTER", petSpellBar, "BOTTOM", 0, -5.5)
        petSpellBar.Text:SetFontObject("SystemFont_Shadow_Med1_Outline")
        petSpellBar.Icon:ClearAllPoints()
        petSpellBar.Icon:SetPoint("RIGHT", petSpellBar, "LEFT", -4, 0)
        petSpellBar.Icon:SetSize(22, 22)
        petSpellBar.Icon:SetScale(BetterBlizzFramesDB.petCastBarIconScale)
        petSpellBar:SetScale(BetterBlizzFramesDB.petCastBarScale)
        petSpellBar:SetWidth(BetterBlizzFramesDB.petCastBarWidth)
        petSpellBar:SetHeight(BetterBlizzFramesDB.petCastBarHeight)
        Mixin(petSpellBar, SmoothStatusBarMixin)
        petSpellBar:SetMinMaxSmoothedValue(0, 100)

        petSpellBar.Timer = petSpellBar:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1_Outline")
        petSpellBar.Timer:SetPoint("LEFT", petSpellBar, "RIGHT", 3, 0)
        petSpellBar.Timer:SetTextColor(1, 1, 1, 1)

        petSpellBar.FakeTimer = petSpellBar:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1_Outline")
        petSpellBar.FakeTimer:SetPoint("LEFT", petSpellBar, "RIGHT", 3, 0)
        petSpellBar.FakeTimer:SetTextColor(1, 1, 1, 1)
        petSpellBar.FakeTimer:SetText("1.8")
        petSpellBar.FakeTimer:Hide()

        if BetterBlizzFramesDB.petCastBarTimer then
            petSpellBar:HookScript("OnUpdate", function(self, elapsed)
                UpdateCastTimer(self, elapsed)
            end)
        end

        spellBars["pet"] = petSpellBar
        petCastbarCreated = true
        BBF.UpdatePetCastbar()
    end
end

function BBF.partyCastBarTestMode()
    BBF.CreateCastbars()
    BBF.UpdateCastbars()

    for i = 1, 5 do
        local spellbar = spellBars[i]
        if spellbar and BetterBlizzFramesDB.partyCastBarTestMode then
            spellbar:SetParent(UIParent)
            spellbar:Show()
            spellbar:SetAlpha(1)

            local minValue, maxValue = 0, 100
            local duration = 2 -- in seconds
            local stepsPerSecond = 50 -- adjust for smoothness
            local totalSteps = duration * stepsPerSecond
            local stepValue = (maxValue - minValue) / totalSteps
            local currentValue = minValue

            spellbar:SetMinMaxValues(minValue, maxValue)
            spellbar:SetValue(currentValue)
            spellbar.Text:SetText("Frostbolt")

            -- Cancel any existing timer before creating a new one
            if spellbar.tickTimer then
                spellbar.tickTimer:Cancel()
            end

            -- Create a timer for smooth cast progress
            spellbar.tickTimer = C_Timer.NewTicker(1 / stepsPerSecond, function()
                currentValue = currentValue + stepValue
                if currentValue >= maxValue then
                    currentValue = minValue
                end
                spellbar:SetValue(currentValue)
            end)

            if not BetterBlizzFramesDB.showPartyCastBarIcon then
                spellbar.Icon:Hide()
            else
                spellbar.Icon:Show()
                spellbar.Icon:SetTexture(GetSpellTexture(116))
            end
            if BetterBlizzFramesDB.partyCastBarTimer then
                if not spellbar.FakeTimer then
                    spellbar.FakeTimer = spellbar:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1_Outline")
                    spellbar.FakeTimer:SetPoint("LEFT", spellbar, "RIGHT", 3, 0)
                    spellbar.FakeTimer:SetTextColor(1, 1, 1, 1)
                end
                spellbar.FakeTimer:Show()
            else
                if spellbar.FakeTimer then
                    spellbar.FakeTimer:Hide()
                end
            end
            spellbar.Flash:SetAlpha(0)
        elseif spellbar then
            -- Stop the timer when exiting test mode
            if spellbar.tickTimer then
                spellbar.tickTimer:Cancel()
                spellbar.tickTimer = nil
            end
            spellbar.Flash:SetAlpha(1)
            spellbar:SetAlpha(0)
            if spellbar.FakeTimer then
                spellbar.FakeTimer:Hide()
            end
        end
        --spellbar:StopFinishAnims()
    end
end


function BBF.petCastBarTestMode()
    BBF.CreateCastbars()
    BBF.UpdatePetCastbar()
    if BetterBlizzFramesDB.petCastBarTestMode then
        spellBars["pet"]:Show()
        spellBars["pet"]:SetAlpha(1)
        spellBars["pet"]:SetSmoothedValue(math.random(100))

        -- Create a timer for random ticks
        if not spellBars["pet"].tickTimer then
            spellBars["pet"].tickTimer = C_Timer.NewTicker(0.7, function()
                spellBars["pet"]:SetSmoothedValue(math.random(100))
            end)
        end
        if not BetterBlizzFramesDB.showPetCastBarIcon then
            spellBars["pet"].Icon:Hide()
        else
            spellBars["pet"].Icon:Show()
            spellBars["pet"].Icon:SetTexture(GetSpellTexture(6358));
        end
        spellBars["pet"].Text:SetText("Seduction")
        if BetterBlizzFramesDB.petCastBarTimer then
            spellBars["pet"].FakeTimer:Show()
        else
            spellBars["pet"].FakeTimer:Hide()
        end
    else
        -- Stop the timer when exiting test mode
        if spellBars["pet"].tickTimer then
            spellBars["pet"].tickTimer:Cancel()
            spellBars["pet"].tickTimer = nil
        end
        spellBars["pet"]:SetAlpha(0)
        spellBars["pet"].FakeTimer:Hide()
    end
end




local CastBarFrame = CreateFrame("Frame")
CastBarFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
CastBarFrame:SetScript("OnEvent", function(self, event, ...)
    if BetterBlizzFramesDB.showPartyCastbar then
        BBF.UpdateCastbars()
        BBF.CreateCastbars()
    end
end)







--[[
CompactRaidFrame1:HookScript("OnShow", function()
    --Small delay to make EditMode happy going from party > compactparty
    C_Timer.After(0, function()
        BBF.UpdateCastbars()
    end)
    print("CompactRaidFrame1:OnShow ran")
end)


]]


local petUpdate = CreateFrame("Frame")
petUpdate:RegisterEvent("UNIT_PET")
petUpdate:SetScript("OnEvent", function(self, event, ...)
    if BetterBlizzFramesDB.petCastbar then
        BBF.UpdatePetCastbar()
    end
end)



--[[
hooksecurefunc(CompactRaidFrame, "RefreshMembers", function()
    local showPartyCastbars = BetterBlizzFramesDB.showPartyCastbar
    if showPartyCastbars then
        BBF.CreateCastbars()
        BBF.UpdateCastbars()
    end
    --BBF.OnUpdateName()
end)

]]



-- Hook into the OnUpdate, OnShow, and OnHide scripts for the spell bar
local function CastBarTimer(bar)
    local castBarSetting = nil
    if bar == CastingBarFrame then
        castBarSetting = BetterBlizzFramesDB.playerCastBarTimer
    elseif bar == TargetFrameSpellBar then
        castBarSetting = BetterBlizzFramesDB.targetCastBarTimer
    elseif bar == FocusFrameSpellBar then
        castBarSetting = BetterBlizzFramesDB.focusCastBarTimer
    end
    if castBarSetting and not bar.Timer then
        bar.Timer = bar:CreateFontString(nil, "OVERLAY")
        bar.Timer:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    end
    if not bar.Timer then return end
    bar.Timer:ClearAllPoints()
    if bar == CastingBarFrame then
        if BetterBlizzFramesDB.playerCastBarTimerCentered then
            bar.Timer:SetPoint("BOTTOM", bar, "TOP", 0, 6)
        else
            bar.Timer:SetPoint("LEFT", bar, "RIGHT", 3, 2)
        end
    else
        bar.Timer:SetPoint("LEFT", bar, "RIGHT", 3, -1)
    end
    if not castBarSetting then
        bar.Timer:Hide()
    else
        bar.Timer:Show()
    end
    if bar.isHooked then return end
    bar:HookScript("OnUpdate", function(self, elapsed)
        UpdateCastTimer(self, elapsed)
    end)
    bar.isHooked = true
end

function BBF.CastBarTimerCaller()
    CastBarTimer(CastingBarFrame)
    CastBarTimer(TargetFrameSpellBar)
    CastBarTimer(FocusFrameSpellBar)
end


local targetSpellBarTexture = TargetFrameSpellBar:GetStatusBarTexture()
local focusSpellBarTexture = FocusFrameSpellBar:GetStatusBarTexture()
local targetCastbarEdgeHooked
local focusCastbarEdgeHooked

local targetLastUpdate = 0
local focusLastUpdate = 0
local updateInterval = 0.05

local highlightStartTime = BetterBlizzFramesDB.castBarInterruptHighlighterStartTime
local highlightEndTime = BetterBlizzFramesDB.castBarInterruptHighlighterEndTime
local edgeColor = BetterBlizzFramesDB.castBarInterruptHighlighterInterruptRGB
local middleColor = BetterBlizzFramesDB.castBarInterruptHighlighterDontInterruptRGB
local colorMiddle = BetterBlizzFramesDB.castBarInterruptHighlighterColorDontInterrupt
local castBarNoInterruptColor = BetterBlizzFramesDB.castBarNoInterruptColor
local castBarDelayedInterruptColor = BetterBlizzFramesDB.castBarDelayedInterruptColor
local castBarRecolorInterrupt = BetterBlizzFramesDB.castBarRecolorInterrupt
local castBarInterruptHighlighter = BetterBlizzFramesDB.castBarInterruptHighlighter
local targetCastbarEdgeHighlight = BetterBlizzFramesDB.targetCastbarEdgeHighlight
local focusCastbarEdgeHighlight = BetterBlizzFramesDB.focusCastbarEdgeHighlight

local interruptList = {
    [1766] = true,  -- Kick (Rogue)
    [2139] = true,  -- Counterspell (Mage)
    [6552] = true,  -- Pummel (Warrior)
    [19647] = true, -- Spell Lock (Warlock)
    [47528] = true, -- Mind Freeze (Death Knight)
    [57994] = true, -- Wind Shear (Shaman)
    [91802] = true, -- Shambling Rush (Death Knight)
    [96231] = true, -- Rebuke (Paladin)
    [106839] = true,-- Skull Bash (Feral)
    [115781] = true,-- Optical Blast (Warlock)
    [116705] = true,-- Spear Hand Strike (Monk)
    [132409] = true,-- Spell Lock (Warlock)
    [119910] = true,-- Spell Lock (Warlock Pet)
    [147362] = true,-- Countershot (Hunter)
    [171138] = true,-- Shadow Lock (Warlock)
    [183752] = true,-- Consume Magic (Demon Hunter)
    [187707] = true,-- Muzzle (Hunter)
    [212619] = true,-- Call Felhunter (Warlock)
    [231665] = true,-- Avengers Shield (Paladin)
    [351338] = true,-- Quell (Evoker)
    [97547]  = true,-- Solar Beam
}

local interruptSpellIDs = {}
function BBF.InitializeInterruptSpellID()
    interruptSpellIDs = {}
    for spellID in pairs(interruptList) do
        if IsSpellKnownOrOverridesKnown(spellID) then
            table.insert(interruptSpellIDs, spellID)
        end
    end
end

local recheckInterruptListener = CreateFrame("Frame")
local function OnEvent(self, event, unit, _, spellID)
    if spellID == 691 or spellID == 108503 then
        BBF.InitializeInterruptSpellID()
    end
end
recheckInterruptListener:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
recheckInterruptListener:SetScript("OnEvent", OnEvent)

local function resetCastbarColor(castbar, channeling)
    if not channeling then
        castbar:SetStatusBarColor(1, 0.702, 0)
    else
        castbar:SetStatusBarColor(1, 0.702, 0)
    end
end

function BBF.CastbarRecolorWidgets()
    if BetterBlizzFramesDB.castBarInterruptHighlighter or BetterBlizzFramesDB.castBarDelayedInterruptColor then
        highlightStartTime = BetterBlizzFramesDB.castBarInterruptHighlighterStartTime
        highlightEndTime = BetterBlizzFramesDB.castBarInterruptHighlighterEndTime
        edgeColor = BetterBlizzFramesDB.castBarInterruptHighlighterInterruptRGB
        middleColor = BetterBlizzFramesDB.castBarInterruptHighlighterDontInterruptRGB
        colorMiddle = BetterBlizzFramesDB.castBarInterruptHighlighterColorDontInterrupt
        castBarNoInterruptColor = BetterBlizzFramesDB.castBarNoInterruptColor
        castBarDelayedInterruptColor = BetterBlizzFramesDB.castBarDelayedInterruptColor
        castBarRecolorInterrupt = BetterBlizzFramesDB.castBarRecolorInterrupt
        castBarInterruptHighlighter = BetterBlizzFramesDB.castBarInterruptHighlighter
        targetCastbarEdgeHighlight = BetterBlizzFramesDB.targetCastbarEdgeHighlight and castBarInterruptHighlighter
        focusCastbarEdgeHighlight = BetterBlizzFramesDB.focusCastbarEdgeHighlight and castBarInterruptHighlighter

        if (targetCastbarEdgeHighlight or castBarRecolorInterrupt) and not targetCastbarEdgeHooked then
            BBF.InitializeInterruptSpellID()

            TargetFrameSpellBar:HookScript("OnUpdate", function(self, elapsed)
                -- targetLastUpdate = targetLastUpdate + elapsed
                -- if targetLastUpdate < updateInterval then
                --     return
                -- end
                -- targetLastUpdate = 0

                if UnitCanAttack(TargetFrame.unit, "player") then
                    local channeling
                    local name, _, _, startTime, endTime, _, _, notInterruptible, spellId = UnitCastingInfo("target")
                    if not name then
                        name, _, _, startTime, endTime, _, notInterruptible, spellId = UnitChannelInfo("target")
                        channeling = true
                    end

                    if name and not notInterruptible then
                        if castBarRecolorInterrupt then
                            for _, interruptSpellID in ipairs(interruptSpellIDs) do
                                local start, duration = GetSpellCooldown(interruptSpellID)
                                local cooldownRemaining = start + duration - GetTime()
                                local castRemaining = (endTime/1000) - GetTime()

                                if cooldownRemaining > 0 and cooldownRemaining > castRemaining then
                                    targetSpellBarTexture:SetDesaturated(true)
                                    self:SetStatusBarColor(unpack(castBarNoInterruptColor))
                                    self.Spark:SetVertexColor(unpack(castBarNoInterruptColor))
                                elseif cooldownRemaining > 0 and cooldownRemaining <= castRemaining then
                                    targetSpellBarTexture:SetDesaturated(true)
                                    self:SetStatusBarColor(unpack(castBarDelayedInterruptColor))
                                    self.Spark:SetVertexColor(unpack(castBarDelayedInterruptColor))
                                else
                                    if targetCastbarEdgeHighlight then
                                        local currentTime = GetTime()  -- Current time in seconds
                                        local startTimeSeconds = startTime / 1000  -- Convert start time to seconds
                                        local endTimeSeconds = endTime / 1000
                                        local elapsed = currentTime - startTimeSeconds  -- Time elapsed since the start of the cast in seconds
                                        local timeRemaining = endTimeSeconds - currentTime  -- Time remaining until the cast ends in seconds

                                        if (elapsed <= highlightStartTime) or (timeRemaining <= highlightEndTime) then
                                            targetSpellBarTexture:SetDesaturated(true)
                                            self:SetStatusBarColor(unpack(edgeColor))
                                            self.Spark:SetVertexColor(unpack(edgeColor))
                                        else
                                            if colorMiddle then
                                                targetSpellBarTexture:SetDesaturated(true)
                                                self:SetStatusBarColor(unpack(middleColor))
                                            else
                                                targetSpellBarTexture:SetDesaturated(false)
                                                resetCastbarColor(self, channeling)
                                            end
                                            self.Spark:SetVertexColor(1,1,1)
                                        end
                                    else
                                        targetSpellBarTexture:SetDesaturated(false)
                                        resetCastbarColor(self, channeling)
                                        self.Spark:SetVertexColor(1,1,1)
                                    end
                                end
                            end
                        elseif targetCastbarEdgeHighlight then
                            local currentTime = GetTime()  -- Current time in seconds
                            local startTimeSeconds = startTime / 1000  -- Convert start time to seconds
                            local endTimeSeconds = endTime / 1000
                            local elapsed = currentTime - startTimeSeconds  -- Time elapsed since the start of the cast in seconds
                            local timeRemaining = endTimeSeconds - currentTime  -- Time remaining until the cast ends in seconds

                            if (elapsed <= highlightStartTime) or (timeRemaining <= highlightEndTime) then
                                targetSpellBarTexture:SetDesaturated(true)
                                self:SetStatusBarColor(unpack(edgeColor))
                                self.Spark:SetVertexColor(unpack(edgeColor))
                            else
                                if colorMiddle then
                                    targetSpellBarTexture:SetDesaturated(true)
                                    self:SetStatusBarColor(unpack(middleColor))
                                else
                                    targetSpellBarTexture:SetDesaturated(false)
                                    resetCastbarColor(self, channeling)
                                end
                                self.Spark:SetVertexColor(1,1,1)
                            end
                        else
                            targetSpellBarTexture:SetDesaturated(false)
                            resetCastbarColor(self, channeling)
                            self.Spark:SetVertexColor(1,1,1)
                        end
                    else
                        targetSpellBarTexture:SetDesaturated(false)
                        resetCastbarColor(self, channeling)
                        self.Spark:SetVertexColor(1,1,1)
                    end
                else
                    targetSpellBarTexture:SetDesaturated(false)
                    local channeling = UnitChannelInfo("target")
                    resetCastbarColor(self, channeling)
                    self.Spark:SetVertexColor(1,1,1)
                end
            end)
            targetCastbarEdgeHooked = true
        end

        if (focusCastbarEdgeHighlight or castBarRecolorInterrupt) and not focusCastbarEdgeHooked then
            FocusFrameSpellBar:HookScript("OnUpdate", function(self, elapsed)
                -- focusLastUpdate = focusLastUpdate + elapsed
                -- if focusLastUpdate < updateInterval then
                --     return
                -- end
                -- focusLastUpdate = 0
                if UnitCanAttack(FocusFrame.unit, "player") then
                    local channeling
                    local name, _, _, startTime, endTime, _, _, notInterruptible, spellId = UnitCastingInfo("focus")
                    if not name then
                        name, _, _, startTime, endTime, _, notInterruptible, spellId = UnitChannelInfo("focus")
                        channeling = true
                    end

                    if name then--and not notInterruptible then
                        if castBarRecolorInterrupt then
                            for _, interruptSpellID in ipairs(interruptSpellIDs) do
                                local start, duration = GetSpellCooldown(interruptSpellID)
                                local cooldownRemaining = start + duration - GetTime()
                                local castRemaining = (endTime/1000) - GetTime()

                                if cooldownRemaining > 0 and cooldownRemaining > castRemaining then
                                    focusSpellBarTexture:SetDesaturated(true)
                                    self:SetStatusBarColor(unpack(castBarNoInterruptColor))
                                    self.Spark:SetVertexColor(unpack(castBarNoInterruptColor))
                                elseif cooldownRemaining > 0 and cooldownRemaining <= castRemaining then
                                    focusSpellBarTexture:SetDesaturated(true)
                                    self:SetStatusBarColor(unpack(castBarDelayedInterruptColor))
                                    self.Spark:SetVertexColor(unpack(castBarDelayedInterruptColor))
                                else
                                    if focusCastbarEdgeHighlight then
                                        local currentTime = GetTime()  -- Current time in seconds
                                        local startTimeSeconds = startTime / 1000  -- Convert start time to seconds
                                        local endTimeSeconds = endTime / 1000
                                        local elapsed = currentTime - startTimeSeconds  -- Time elapsed since the start of the cast in seconds
                                        local timeRemaining = endTimeSeconds - currentTime  -- Time remaining until the cast ends in seconds

                                        if (elapsed <= highlightStartTime) or (timeRemaining <= highlightEndTime) then
                                            focusSpellBarTexture:SetDesaturated(true)
                                            self:SetStatusBarColor(unpack(edgeColor))
                                            self.Spark:SetVertexColor(unpack(edgeColor))
                                        else
                                            if colorMiddle then
                                                focusSpellBarTexture:SetDesaturated(true)
                                                self:SetStatusBarColor(unpack(middleColor))
                                            else
                                                focusSpellBarTexture:SetDesaturated(false)
                                                if not channeling then
                                                    resetCastbarColor(self, channeling)
                                                else
                                                    resetCastbarColor(self, channeling)
                                                end
                                            end
                                            self.Spark:SetVertexColor(1,1,1)
                                        end
                                    else
                                        focusSpellBarTexture:SetDesaturated(false)
                                        resetCastbarColor(self, channeling)
                                        self.Spark:SetVertexColor(1,1,1)
                                    end
                                end
                            end
                        elseif focusCastbarEdgeHighlight then
                            local currentTime = GetTime()  -- Current time in seconds
                            local startTimeSeconds = startTime / 1000  -- Convert start time to seconds
                            local endTimeSeconds = endTime / 1000
                            local elapsed = currentTime - startTimeSeconds  -- Time elapsed since the start of the cast in seconds
                            local timeRemaining = endTimeSeconds - currentTime  -- Time remaining until the cast ends in seconds

                            if (elapsed <= highlightStartTime) or (timeRemaining <= highlightEndTime) then
                                focusSpellBarTexture:SetDesaturated(true)
                                self:SetStatusBarColor(unpack(edgeColor))
                                self.Spark:SetVertexColor(unpack(edgeColor))
                            else
                                if colorMiddle then
                                    focusSpellBarTexture:SetDesaturated(true)
                                    self:SetStatusBarColor(unpack(middleColor))
                                else
                                    focusSpellBarTexture:SetDesaturated(false)
                                    resetCastbarColor(self, channeling)
                                end
                                self.Spark:SetVertexColor(1,1,1)
                            end
                        else
                            focusSpellBarTexture:SetDesaturated(false)
                            resetCastbarColor(self, channeling)
                            self.Spark:SetVertexColor(1,1,1)
                        end
                    else
                        focusSpellBarTexture:SetDesaturated(false)
                        resetCastbarColor(self, channeling)
                        self.Spark:SetVertexColor(1,1,1)
                    end
                else
                    local channeling = UnitChannelInfo("target")
                    focusSpellBarTexture:SetDesaturated(false)
                    resetCastbarColor(self, channeling)
                    self.Spark:SetVertexColor(1,1,1)
                end
            end)
            focusCastbarEdgeHooked = true
        end
    end
end

local CastingBarFrameHooked = false
function BBF.ShowPlayerCastBarIcon()
    if CastingBarFrame then
        if BetterBlizzFramesDB.playerCastBarShowIcon then
            CastingBarFrame.Icon:Show()
            --CastingBarFrame.showShield = true
        else
            CastingBarFrame.Icon:Hide()
            --CastingBarFrame.showShield = false
        end
    else
        C_Timer.After(1, BBF.ShowPlayerCastBarIcon)
    end
end


local function CastingBarFrameMiscAdjustments()
    -- InterruptGlow
    local baseWidthRatio = 444 / 208
    local baseHeightRatio = 50 / 11
    local newInterruptGlowWidth = baseWidthRatio * BetterBlizzFramesDB.playerCastBarWidth
    local newInterruptGlowHeight
    if BetterBlizzFramesDB.playerCastBarHeight > 14 and BetterBlizzFramesDB.playerCastBarHeight < 30 then
        newInterruptGlowHeight = baseHeightRatio * BetterBlizzFramesDB.playerCastBarHeight * 0.78
    else
        newInterruptGlowHeight = baseHeightRatio * BetterBlizzFramesDB.playerCastBarHeight
    end
    --CastingBarFrame.InterruptGlow:SetSize(newInterruptGlowWidth, newInterruptGlowHeight)

    CastingBarFrame.Spark:SetSize(8, BetterBlizzFramesDB.playerCastBarHeight + 9)
    --CastingBarFrame.StandardGlow:SetSize(37, BetterBlizzFramesDB.playerCastBarHeight + 1)
end

local function adjustCastBarBorder(castBar, border, adjust, shield, player)
    -- Default values for width
    local defaultCastBarWidth = player or 150
    local defaultBorderWidth = 200
    local widthAdjustmentFactor = adjust / 50  -- Adjustment per unit width change

    -- Default values for height
    local defaultCastBarHeight = 10
    local defaultBorderHeight = 56
    local heightAdjustmentFactor = 5.00  -- Average adjustment per unit height change

    -- Get current dimensions of the cast bar
    local currentCastBarWidth = castBar:GetWidth()
    local currentCastBarHeight = castBar:GetHeight()
    
    -- Calculate the new border width based on the current cast bar width
    local widthDifference = currentCastBarWidth - defaultCastBarWidth
    local borderWidth = defaultBorderWidth + widthDifference + (widthDifference * widthAdjustmentFactor)
    
    -- Calculate the new border height based on the current cast bar height
    local heightDifference = currentCastBarHeight - defaultCastBarHeight
    local borderHeight = defaultBorderHeight + (heightDifference * heightAdjustmentFactor)

    -- Apply the new border size
    border:ClearAllPoints()
    border:SetPoint("CENTER", castBar, "CENTER", shield and -4 or 0, 0)
    border:SetSize(borderWidth, shield and borderHeight-1 or borderHeight)
end

local hookedPlayerCastbar = false
function BBF.ChangeCastbarSizes()
    BBF.UpdateUserAuraSettings()
    --Player
    if not BetterBlizzFramesDB.playerCastBarScale then
        BetterBlizzFramesDB.playerCastBarScale = CastingBarFrame:GetScale()
    end
    CastingBarFrame:SetScale(BetterBlizzFramesDB.playerCastBarScale)
    CastingBarFrame:SetWidth(BetterBlizzFramesDB.playerCastBarWidth)
    CastingBarFrame:SetHeight(BetterBlizzFramesDB.playerCastBarHeight)
    CastingBarFrame.Text:ClearAllPoints()
    CastingBarFrame.Text:SetPoint("CENTER", CastingBarFrame, "CENTER", 0, 0)
    CastingBarFrame.Icon:SetSize(22,22)
    CastingBarFrame.Icon:ClearAllPoints()
    CastingBarFrame.Icon:SetPoint("RIGHT", CastingBarFrame, "LEFT", -5 + BetterBlizzFramesDB.playerCastbarIconXPos, 2 + BetterBlizzFramesDB.playerCastbarIconYPos)
    CastingBarFrame.Icon:SetScale(BetterBlizzFramesDB.playerCastBarIconScale)
    -- CastingBarFrame.BorderShield:SetSize(30,36)
    -- CastingBarFrame.BorderShield:ClearAllPoints()
    -- CastingBarFrame.BorderShield:SetPoint("RIGHT", CastingBarFrame, "LEFT", -1.5 + BetterBlizzFramesDB.playerCastbarIconXPos, -7 + BetterBlizzFramesDB.playerCastbarIconYPos)
    -- CastingBarFrame.BorderShield:SetScale(BetterBlizzFramesDB.playerCastBarIconScale)
    -- CastingBarFrame.BorderShield:SetDrawLayer("BORDER")
    CastingBarFrame.Icon:SetDrawLayer("ARTWORK")

    adjustCastBarBorder(CastingBarFrame, CastingBarFrame.Border, 15)
    adjustCastBarBorder(CastingBarFrame, CastingBarFrame.BorderShield, 12, true)

    -- CastingBarFrame:ClearAllPoints()
    -- CastingBarFrame:SetPoint("CENTER", UIParent, "BOTTOM", BetterBlizzFramesDB.playerCastBarXPos, BetterBlizzFramesDB.playerCastBarYPos + 157)

    BBF.MoveRegion(CastingBarFrame, "CENTER", UIParent, "BOTTOM", BetterBlizzFramesDB.playerCastBarXPos, BetterBlizzFramesDB.playerCastBarYPos + 157)

    --
    CastingBarFrameMiscAdjustments()





    --Target & Focus XY in auras.lua
    --Target
    TargetFrameSpellBar:SetScale(BetterBlizzFramesDB.targetCastBarScale)
    TargetFrameSpellBar:SetWidth(BetterBlizzFramesDB.targetCastBarWidth)
    TargetFrameSpellBar:SetHeight(BetterBlizzFramesDB.targetCastBarHeight)
    adjustCastBarBorder(TargetFrameSpellBar, TargetFrameSpellBar.Border, 15)
    adjustCastBarBorder(TargetFrameSpellBar, TargetFrameSpellBar.BorderShield, 12, true)
    TargetFrameSpellBar.Icon:SetDrawLayer("OVERLAY", 7)

    -- 227, 56

    TargetFrameSpellBar.Icon:SetScale(BetterBlizzFramesDB.targetCastBarIconScale)
    local a,b,c,d,e = TargetFrameSpellBar.Icon:GetPoint()
    TargetFrameSpellBar.Icon:ClearAllPoints()
    TargetFrameSpellBar.Icon:SetPoint(a, b, c, -5 + BetterBlizzFramesDB.targetCastbarIconXPos, 1 + BetterBlizzFramesDB.targetCastbarIconYPos)
    TargetFrameSpellBar.Text:ClearAllPoints()
    TargetFrameSpellBar.Text:SetPoint("CENTER", TargetFrameSpellBar, "CENTER", 0, 0)
    --TargetFrameSpellBar.Icon:SetPoint("RIGHT", b, "LEFT", 0 + BetterBlizzFramesDB.targetCastbarIconXPos, 0 + BetterBlizzFramesDB.targetCastbarIconYPos)

    -- TargetFrameSpellBar.BorderShield:ClearAllPoints()
    -- TargetFrameSpellBar.BorderShield:SetPoint("CENTER", TargetFrameSpellBar.Icon, "CENTER", 0, 0)
    -- TargetFrameSpellBar.BorderShield:SetScale(BetterBlizzFramesDB.targetCastBarIconScale)
    -- TargetFrameSpellBar.Text:ClearAllPoints()
    -- TargetFrameSpellBar.Text:SetPoint("BOTTOM", TargetFrameSpellBar, "BOTTOM", 0, -14)

    --Focus
    FocusFrameSpellBar:SetScale(BetterBlizzFramesDB.focusCastBarScale)
    FocusFrameSpellBar:SetWidth(BetterBlizzFramesDB.focusCastBarWidth)
    FocusFrameSpellBar:SetHeight(BetterBlizzFramesDB.focusCastBarHeight)
    adjustCastBarBorder(FocusFrameSpellBar, FocusFrameSpellBar.Border, 15)
    adjustCastBarBorder(FocusFrameSpellBar, FocusFrameSpellBar.BorderShield, 12, true)
    FocusFrameSpellBar.Icon:SetDrawLayer("OVERLAY", 7)

    -- 227, 56

    FocusFrameSpellBar.Icon:SetScale(BetterBlizzFramesDB.focusCastBarIconScale)
    local a,b,c,d,e = FocusFrameSpellBar.Icon:GetPoint()
    FocusFrameSpellBar.Icon:ClearAllPoints()
    FocusFrameSpellBar.Icon:SetPoint(a, b, c, -5 + BetterBlizzFramesDB.focusCastbarIconXPos, 1 + BetterBlizzFramesDB.focusCastbarIconYPos)
    FocusFrameSpellBar.Text:ClearAllPoints()
    FocusFrameSpellBar.Text:SetPoint("CENTER", FocusFrameSpellBar, "CENTER", 0, 0)

end

CastingBarFrame:HookScript("OnShow", function()
    local showIcon = BetterBlizzFramesDB.playerCastBarShowIcon
    if showIcon then
        local playerCastBarIconScale = BetterBlizzFramesDB.playerCastBarIconScale
        CastingBarFrame.Icon:Show()
        --CastingBarFrame.showShield = true --taint concern TODO: add non-taint method
        -- CastingBarFrame.BorderShield:SetSize(30,36)
        -- CastingBarFrame.BorderShield:ClearAllPoints()
        -- CastingBarFrame.BorderShield:SetPoint("CENTER", CastingBarFrame.Icon, "CENTER", 0, 0)
        -- CastingBarFrame.BorderShield:SetScale(playerCastBarIconScale)
        -- CastingBarFrame.BorderShield:SetDrawLayer("BORDER")
    end
end)

hooksecurefunc(CastingBarFrame, "SetScale", function()
    if not BetterBlizzFramesDB.wasOnLoadingScreen then
        BetterBlizzFramesDB.playerCastBarScale = CastingBarFrame:GetScale()
    end
end)

-- local frame = CreateFrame("Frame")
-- frame:RegisterEvent("PLAYER_LOGIN")
-- frame:SetScript("OnEvent", function(self, event, ...)
--     if IsAddOnLoaded("ClassicFrames") then
--         return
--     end
--     -- Put your original conditional logic here since it's now safe to check.
--     if TargetFrameSpellBar and FocusFrameSpellBar then
--         -- Adjust frame strata as originally intended.
--         TargetFrame:SetFrameStrata("MEDIUM")
--         TargetFrameSpellBar:SetFrameStrata("HIGH")
--         FocusFrameSpellBar:SetFrameStrata("HIGH")
--     end
-- end)

local evokerCastbarsHooked
function BBF.HookCastbarsForEvoker()
    -- if (not evokerCastbarsHooked and BetterBlizzFramesDB.normalCastbarForEmpoweredCasts) then
    --     hooksecurefunc(CastingBarMixin, "OnEvent", function(self, event, ...)
    --         if self.unit and self.unit:find("target") or self.unit:find("focus") then
    --             if ( event == "UNIT_SPELLCAST_EMPOWER_START" ) then
    --                 if not self:IsForbidden() then
    --                     if self.barType == "empowered" or self.barType == "standard" then
    --                         self:SetStatusBarTexture("ui-castingbar-filling-standard")
    --                     end
    --                     self.ChargeTier1:Hide()
    --                     self.ChargeTier2:Hide()
    --                     self.ChargeTier3:Hide()
    --                     if self.ChargeTier4 then
    --                         self.ChargeTier4:Hide()
    --                     end
    --                 end
    --             end
    --         end
    --     end)
    --     evokerCastbarsHooked = true
    -- end
end