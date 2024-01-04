-- Setting up the database
BetterBlizzFramesDB = BetterBlizzFramesDB or {}
BBF = BBF or {}

local spellBars = {}
local castBarsCreated = false
local petCastbarCreated = false

local function GetPartyMemberFrame(unitId)
    if CompactPartyFrame:IsShown() then
        local showSelf = BetterBlizzFramesDB.partyCastbarSelf
        for i = 1, 5 do
            local frame = _G["CompactPartyFrameMember"..i]
            if frame and UnitIsUnit(frame.unit, unitId) then
                return frame, nil
            else
                if showSelf then
                    if UnitIsUnit(frame.unit, "player") then
                        unitId = "player"
                        return frame, unitId
                    end
                end
            end
        end
    else
        for i = 1, 5 do
            local frame = PartyFrame and PartyFrame["MemberFrame"..i]
            if frame and UnitIsUnit(frame.unit, unitId) then
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
            for i=1, numGroupMembers do
                local unitId = "party" .. i
                local spellbar = spellBars[i]
                if spellbar then
                    spellbar:SetParent(UIParent)
                    spellbar:SetScale(BetterBlizzFramesDB.partyCastBarScale)
                    spellbar:SetWidth(BetterBlizzFramesDB.partyCastBarWidth)
                    spellbar:SetHeight(BetterBlizzFramesDB.partyCastBarHeight)

                    if not BetterBlizzFramesDB.showPartyCastBarIcon then
                        spellbar.Icon:SetAlpha(0)
                        spellbar.BorderShield:SetAlpha(0)
                    else
                        spellbar.Icon:ClearAllPoints()
                        spellbar.Icon:SetPoint("RIGHT", spellbar, "LEFT", -4 + BetterBlizzFramesDB.partyCastbarIconXPos, -5 + BetterBlizzFramesDB.partyCastbarIconYPos)
                        spellbar.Icon:SetScale(BetterBlizzFramesDB.partyCastBarIconScale)
                        spellbar.Icon:SetAlpha(1)
                        spellbar.BorderShield:ClearAllPoints()
                        spellbar.BorderShield:SetPoint("RIGHT", spellbar, "LEFT", -1 + BetterBlizzFramesDB.partyCastbarIconXPos, -7 + BetterBlizzFramesDB.partyCastbarIconYPos)
                        spellbar.BorderShield:SetScale(BetterBlizzFramesDB.partyCastBarIconScale)
                        spellbar.BorderShield:SetAlpha(1)
                    end

                    local partyFrame, newUnitId = GetPartyMemberFrame(unitId)
                    if partyFrame then
                        if newUnitId then
                            spellbar:SetUnit("player", true, true)
                        end
                        spellbar:ClearAllPoints()
                        --spellbar:SetParent(partyFrame)
                        spellbar:SetPoint("CENTER", partyFrame, "CENTER", BetterBlizzFramesDB.partyCastBarXPos + 13, BetterBlizzFramesDB.partyCastBarYPos + 3)
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
            for i=1, 5 do
                local spellbar = spellBars[i]
                if spellbar then
                    spellbar:SetParent(hiddenFrame)
                end
            end
        end
    else
        for i=1, 5 do
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
            petSpellBar.Icon:SetPoint("RIGHT", petSpellBar, "LEFT", -4 + 0, -5 + 0)
            petSpellBar.Icon:SetScale(iconScale)
            petSpellBar.Icon:SetAlpha(1)
            petSpellBar.BorderShield:ClearAllPoints()
            petSpellBar.BorderShield:SetPoint("RIGHT", petSpellBar, "LEFT", -1 + 0, -7 + 0)
            petSpellBar.BorderShield:SetScale(iconScale)
            petSpellBar.BorderShield:SetAlpha(1)
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

            spellbar:SetUnit("party"..i, true, true)
            spellbar.Text:ClearAllPoints()
            spellbar.Text:SetPoint("CENTER", spellbar, "BOTTOM", 0, -5.5)
            spellbar.Text:SetFontObject("SystemFont_Shadow_Med1_Outline")
            spellbar.Icon:ClearAllPoints()
            spellbar.Icon:SetPoint("RIGHT", spellbar, "LEFT", -4, -5)
            spellbar.Icon:SetSize(22,22)
            spellbar.Icon:SetScale(BetterBlizzFramesDB.partyCastBarIconScale)
            spellbar.BorderShield:ClearAllPoints()
            spellbar.BorderShield:SetPoint("RIGHT", spellbar, "LEFT", -1, -7)
            spellbar.BorderShield:SetSize(29,33)
            spellbar.BorderShield:SetScale(BetterBlizzFramesDB.partyCastBarIconScale)
            spellbar:SetScale(BetterBlizzFramesDB.partyCastBarScale)
            spellbar:SetWidth(BetterBlizzFramesDB.partyCastBarWidth)
            spellbar:SetHeight(BetterBlizzFramesDB.partyCastBarHeight)

            spellbar.Timer = spellbar:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1_Outline")
            spellbar.Timer:SetPoint("LEFT", spellbar, "RIGHT", 3, 0)
            spellbar.Timer:SetTextColor(1, 1, 1, 1)

            spellbar.FakeTimer = spellbar:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1_Outline")
            spellbar.FakeTimer:SetPoint("LEFT", spellbar, "RIGHT", 3, 0)
            spellbar.FakeTimer:SetTextColor(1, 1, 1, 1)
            spellbar.FakeTimer:SetText("1.8")
            spellbar.FakeTimer:Hide()

            Mixin(spellbar, SmoothStatusBarMixin)
            spellbar:SetMinMaxSmoothedValue(0, 100)
            -- Add hooks for updating the cast timer.
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

        petSpellBar:SetUnit("pet", true, true)
        petSpellBar.Text:ClearAllPoints()
        petSpellBar.Text:SetPoint("CENTER", petSpellBar, "BOTTOM", 0, -5.5)
        petSpellBar.Text:SetFontObject("SystemFont_Shadow_Med1_Outline")
        petSpellBar.Icon:ClearAllPoints()
        petSpellBar.Icon:SetPoint("RIGHT", petSpellBar, "LEFT", -4, -5)
        petSpellBar.Icon:SetSize(22,22)
        petSpellBar.Icon:SetScale(BetterBlizzFramesDB.petCastBarIconScale)
        petSpellBar.BorderShield:ClearAllPoints()
        petSpellBar.BorderShield:SetPoint("RIGHT", petSpellBar, "LEFT", -1, -7)
        petSpellBar.BorderShield:SetSize(29,33)
        petSpellBar.BorderShield:SetScale(BetterBlizzFramesDB.petCastBarIconScale)
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
    local numGroupMembers = GetNumGroupMembers() - 1

    for i = 1, numGroupMembers do
        local spellbar = spellBars[i]
        if spellbar and BetterBlizzFramesDB.partyCastBarTestMode then
            spellbar:Show()
            spellbar:SetAlpha(1)
            spellbar:SetSmoothedValue(math.random(100))

            -- Create a timer for random ticks
            if not spellbar.tickTimer then
                spellbar.tickTimer = C_Timer.NewTicker(0.7, function()
                    spellbar:SetSmoothedValue(math.random(100))
                end)
            end
            if not BetterBlizzFramesDB.showPartyCastBarIcon then
                spellbar.Icon:Hide()
            else
                spellbar.Icon:Show()
                spellbar.Icon:SetTexture(GetSpellTexture(116));
            end
            spellbar.Text:SetText("Frostbolt")
            if BetterBlizzFramesDB.partyCastBarTimer then
                spellbar.FakeTimer:Show()
            else
                spellbar.FakeTimer:Hide()
            end
        elseif spellbar then
            -- Stop the timer when exiting test mode
            if spellbar.tickTimer then
                spellbar.tickTimer:Cancel()
                spellbar.tickTimer = nil
            end
            spellbar:SetAlpha(0)
            spellbar.FakeTimer:Hide()
        end
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
CompactPartyFrame:HookScript("OnShow", function()
    --Small delay to make EditMode happy going from party > compactparty
    C_Timer.After(0, function()
        BBF.UpdateCastbars()
    end)
    print("CompactPartyFrame:OnShow ran")
end)


]]


local petUpdate = CreateFrame("Frame")
petUpdate:RegisterEvent("UNIT_PET")
petUpdate:SetScript("OnEvent", function(self, event, ...)
    if BetterBlizzFramesDB.petCastbar then
        BBF.UpdatePetCastbar()
    end
end)



hooksecurefunc(CompactPartyFrame, "RefreshMembers", function()
    local showPartyCastbars = BetterBlizzFramesDB.showPartyCastbar
    if showPartyCastbars then
        BBF.CreateCastbars()
        BBF.UpdateCastbars()
    end
    --BBF.OnUpdateName()
end)


-- Hook into the OnUpdate, OnShow, and OnHide scripts for the spell bar
function CastBarTimer(bar)
    local castBarSetting = nil
    if bar == PlayerCastingBarFrame then
        castBarSetting = BetterBlizzFramesDB.playerCastBarTimer
    elseif bar == TargetFrameSpellBar then
        castBarSetting = BetterBlizzFramesDB.targetCastBarTimer
    elseif bar == FocusFrameSpellBar then
        castBarSetting = BetterBlizzFramesDB.focusCastBarTimer
    end
    if castBarSetting and not bar.Timer then
        bar.Timer = bar:CreateFontString(nil, "OVERLAY")
        bar.Timer:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    end
    if not bar.Timer then return end
    bar.Timer:ClearAllPoints()
    if bar == PlayerCastingBarFrame then
        if BetterBlizzFramesDB.playerCastBarTimerCentered then
            bar.Timer:SetPoint("CENTER", bar, "CENTER", 0, 0)
        else
            bar.Timer:SetPoint("LEFT", bar, "RIGHT", 3, -0)
        end
    else
        bar.Timer:SetPoint("LEFT", bar, "RIGHT", 3, -0)
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
    CastBarTimer(PlayerCastingBarFrame)
    CastBarTimer(TargetFrameSpellBar)
    CastBarTimer(FocusFrameSpellBar)
end

local PlayerCastingBarFrameHooked = false
function BBF.ShowPlayerCastBarIcon()
    if PlayerCastingBarFrame then
        if BetterBlizzFramesDB.playerCastBarShowIcon then
            PlayerCastingBarFrame.Icon:Show()
            --PlayerCastingBarFrame.showShield = true
        else
            PlayerCastingBarFrame.Icon:Hide()
            --PlayerCastingBarFrame.showShield = false
        end
    else
        C_Timer.After(1, BBF.ShowPlayerCastBarIcon)
    end
end


local function PlayerCastingBarFrameMiscAdjustments()
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
    PlayerCastingBarFrame.InterruptGlow:SetSize(newInterruptGlowWidth, newInterruptGlowHeight)

    PlayerCastingBarFrame.Spark:SetSize(8, BetterBlizzFramesDB.playerCastBarHeight + 9)
    --PlayerCastingBarFrame.StandardGlow:SetSize(37, BetterBlizzFramesDB.playerCastBarHeight + 1)
end

function BBF.ChangeCastbarSizes()
    --Player
    if not BetterBlizzFramesDB.playerCastBarScale then
        BetterBlizzFramesDB.playerCastBarScale = PlayerCastingBarFrame:GetScale()
    end
    PlayerCastingBarFrame:SetScale(BetterBlizzFramesDB.playerCastBarScale)
    PlayerCastingBarFrame:SetWidth(BetterBlizzFramesDB.playerCastBarWidth)
    PlayerCastingBarFrame:SetHeight(BetterBlizzFramesDB.playerCastBarHeight)
    PlayerCastingBarFrame.Text:ClearAllPoints()
    PlayerCastingBarFrame.Text:SetPoint("BOTTOM", PlayerCastingBarFrame, "BOTTOM", 0, -14)
    PlayerCastingBarFrame.Icon:SetSize(22,22)
    PlayerCastingBarFrame.Icon:ClearAllPoints()
    PlayerCastingBarFrame.Icon:SetPoint("RIGHT", PlayerCastingBarFrame, "LEFT", -5 + BetterBlizzFramesDB.playerCastbarIconXPos, -5 + BetterBlizzFramesDB.playerCastbarIconYPos)
    PlayerCastingBarFrame.Icon:SetScale(BetterBlizzFramesDB.playerCastBarIconScale)
    PlayerCastingBarFrame.BorderShield:SetSize(30,36)
    PlayerCastingBarFrame.BorderShield:ClearAllPoints()
    PlayerCastingBarFrame.BorderShield:SetPoint("RIGHT", PlayerCastingBarFrame, "LEFT", -1.5 + BetterBlizzFramesDB.playerCastbarIconXPos, -7 + BetterBlizzFramesDB.playerCastbarIconYPos)
    PlayerCastingBarFrame.BorderShield:SetScale(BetterBlizzFramesDB.playerCastBarIconScale)
    PlayerCastingBarFrame.BorderShield:SetDrawLayer("BORDER")
    PlayerCastingBarFrame.Icon:SetDrawLayer("ARTWORK")

    --
    PlayerCastingBarFrameMiscAdjustments()





    --Target & Focus XY in auras.lua
    --Target
    TargetFrameSpellBar:SetScale(BetterBlizzFramesDB.targetCastBarScale)
    TargetFrameSpellBar:SetWidth(BetterBlizzFramesDB.targetCastBarWidth)
    TargetFrameSpellBar:SetHeight(BetterBlizzFramesDB.targetCastBarHeight)
    TargetFrameSpellBar.Icon:SetScale(BetterBlizzFramesDB.targetCastBarIconScale)
    local a,b,c,d,e = TargetFrameSpellBar.Icon:GetPoint()
    TargetFrameSpellBar.Icon:ClearAllPoints()
    TargetFrameSpellBar.Icon:SetPoint(a, b, c, -2 + BetterBlizzFramesDB.targetCastbarIconXPos, -5 + BetterBlizzFramesDB.targetCastbarIconYPos)

    local a,b,c,d,e = TargetFrameSpellBar.BorderShield:GetPoint()
    TargetFrameSpellBar.BorderShield:ClearAllPoints()
    TargetFrameSpellBar.BorderShield:SetPoint(a, b, c, -27 + BetterBlizzFramesDB.targetCastbarIconXPos, 4 + BetterBlizzFramesDB.targetCastbarIconYPos)
    TargetFrameSpellBar.BorderShield:SetScale(BetterBlizzFramesDB.targetCastBarIconScale)
    TargetFrameSpellBar.Text:ClearAllPoints()
    TargetFrameSpellBar.Text:SetPoint("BOTTOM", TargetFrameSpellBar, "BOTTOM", 0, -14)

    --Focus
    FocusFrameSpellBar:SetScale(BetterBlizzFramesDB.focusCastBarScale)
    FocusFrameSpellBar:SetWidth(BetterBlizzFramesDB.focusCastBarWidth)
    FocusFrameSpellBar:SetHeight(BetterBlizzFramesDB.focusCastBarHeight)
    local a,b,c,d,e = FocusFrameSpellBar.Icon:GetPoint()
    FocusFrameSpellBar.Icon:ClearAllPoints()
    FocusFrameSpellBar.Icon:SetPoint(a, b, c, -2 + BetterBlizzFramesDB.focusCastbarIconXPos, -5 + BetterBlizzFramesDB.focusCastbarIconYPos)
    FocusFrameSpellBar.Icon:SetScale(BetterBlizzFramesDB.focusCastBarIconScale)

    local a,b,c,d,e = FocusFrameSpellBar.BorderShield:GetPoint()
    FocusFrameSpellBar.BorderShield:ClearAllPoints()
    FocusFrameSpellBar.BorderShield:SetPoint(a, b, c, -27 + BetterBlizzFramesDB.focusCastbarIconXPos, 4 + BetterBlizzFramesDB.focusCastbarIconYPos)
    FocusFrameSpellBar.BorderShield:SetScale(BetterBlizzFramesDB.focusCastBarIconScale)
    FocusFrameSpellBar.Text:ClearAllPoints()
    FocusFrameSpellBar.Text:SetPoint("BOTTOM", FocusFrameSpellBar, "BOTTOM", 0, -14)

end

PlayerCastingBarFrame:HookScript("OnShow", function()
    local showIcon = BetterBlizzFramesDB.playerCastBarShowIcon
    if showIcon then
        PlayerCastingBarFrame.Icon:Show()
        PlayerCastingBarFrame.showShield = true --taint concern TODO: add non-taint method
        PlayerCastingBarFrame.BorderShield:SetSize(30,36)
        PlayerCastingBarFrame.BorderShield:ClearAllPoints()
        PlayerCastingBarFrame.BorderShield:SetPoint("RIGHT", PlayerCastingBarFrame, "LEFT", -1, -7)
        PlayerCastingBarFrame.BorderShield:SetScale(BetterBlizzFramesDB.playerCastBarIconScale)
        PlayerCastingBarFrame.BorderShield:SetDrawLayer("BORDER")
    end
end)

hooksecurefunc(PlayerCastingBarFrame, "SetScale", function()
    if not BetterBlizzFramesDB.wasOnLoadingScreen then
        BetterBlizzFramesDB.playerCastBarScale = PlayerCastingBarFrame:GetScale()
    end
end)