local spellBars = {}
local castBarsCreated = false
local petCastbarCreated = false

local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo

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

local function UpdateSparkPosition(castBar)
    local val = castBar:GetValue()
    local minVal, maxVal = castBar:GetMinMaxValues()
    --local progressPercent = castBar.value / castBar.maxValue
    local progressPercent = val / maxVal
    local newX = castBar:GetWidth() * progressPercent
    castBar.Spark:ClearAllPoints()
    castBar.Spark:SetPoint("CENTER", castBar, "LEFT", newX, 0)
end

local function HideChargeTiers(castBar)
    castBar.ChargeTier1:Hide()
    castBar.ChargeTier2:Hide()
    castBar.ChargeTier3:Hide()
    if castBar.ChargeTier4 then
        castBar.ChargeTier4:Hide()
    end
end

local function AdjustBorderSize(castBar)
    -- Only calculate scaling factors once based on initial castBar dimensions
    --if not castBar.borderAdjusted then
        local baseWidth, baseHeight = 150, 10       -- Original castBar dimensions
        local baseBorderWidth, baseBorderHeight = 200, 55 -- Original border dimensions

        -- Calculate scaling factors based on castBar's current size
        local widthScale = castBar:GetWidth() / baseWidth
        local heightScale = castBar:GetHeight() / baseHeight

        -- Apply scaled size to the border
        castBar.Border:SetTexture(130873)
        castBar.Border:SetSize(baseBorderWidth * widthScale, baseBorderHeight * heightScale)
        castBar.Border:ClearAllPoints()
        castBar.Border:SetPoint("CENTER", castBar, "CENTER", 0, 0)

        -- Mark as adjusted to prevent re-running this calculation
        --castBar.borderAdjusted = true
    --end
end

local function AdjustBorderShieldSize(castBar)
    -- Only calculate scaling factors once based on initial castBar dimensions
    --if not castBar.borderShieldAdjusted then
        local baseWidth, baseHeight = 150, 10       -- Original castBar dimensions
        local baseBorderWidth, baseBorderHeight = 196, 55 -- Original BorderShield dimensions
        local baseXOffset, baseYOffset = -28, 23    -- Original anchor offsets
        local baseIconSize = 18
        local baseIconYOffset = 1


        -- Calculate scaling factors based on castBar's current size
        local widthScale = castBar:GetWidth() / baseWidth
        local heightScale = castBar:GetHeight() / baseHeight

        -- Apply scaled size to the border
        castBar.BorderShield:SetTexture(311862)
        castBar.BorderShield:SetSize(baseBorderWidth * widthScale, baseBorderHeight * heightScale)
        castBar.BorderShield:SetDrawLayer("OVERLAY")
        castBar.BorderShield:ClearAllPoints()

        castBar.uninterruptibleIconSize = baseIconSize * ((widthScale + heightScale) / 2)
        castBar.adjustedIconYOffset = baseIconYOffset * heightScale

        -- Adjust the anchor position based on scale
        castBar.BorderShield:SetPoint(
            "TOPLEFT", castBar, "TOPLEFT",
            baseXOffset * widthScale,
            baseYOffset * heightScale
        )

        -- Mark as adjusted to prevent re-running this calculation
        --castBar.borderShieldAdjusted = true
    --end
end

local function AdjustFlash(castBar)
    -- Set the base dimensions for reference (208x11 in your case)
    local baseWidth, baseHeight = 208, 11
    local baseOffsetX = 33
    local baseOffsetYTop = 23
    local baseOffsetYBottom = -23

    -- Calculate scaling factors based on the current dimensions of the cast bar
    local widthScale = castBar:GetWidth() / baseWidth
    local heightScale = castBar:GetHeight() / baseHeight

    -- Adjust the offsets based on the scaling factors
    local offsetX = baseOffsetX * widthScale
    local offsetYTop = baseOffsetYTop * heightScale
    local offsetYBottom = baseOffsetYBottom * heightScale

    -- Set the flash texture
    castBar.Flash:SetTexture(130875)

    -- Clear any existing points and set new dynamic offsets
    castBar.Flash:ClearAllPoints()
    castBar.Flash:SetPoint("TOPLEFT", castBar, "TOPLEFT", -offsetX, offsetYTop)
    castBar.Flash:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", offsetX, offsetYBottom)

    -- Apply vertex color
    castBar.Flash:SetVertexColor(1, 0.702, 0, 1)
end





function BBF.ClassicCastbar(castBar, isParty)
    castBar.Text:ClearAllPoints()
    castBar.Text:SetPoint("CENTER", castBar, "CENTER", 0, 0.5)


    castBar.Spark:SetBlendMode("ADD")
    castBar.Spark:SetDrawLayer("OVERLAY", 2)
    castBar.Icon:SetDrawLayer("OVERLAY", 2)

    if castBar.StandardGlow then
        castBar.StandardGlow:SetAtlas(nil)
        castBar.EnergyGlow:SetAtlas(nil)
        castBar.EnergyMask:SetAtlas(nil)
        castBar.ChargeFlash:SetAtlas(nil)
        castBar.ChannelShadow:SetAtlas(nil)
        castBar.BaseGlow:SetAtlas(nil)
        castBar.WispGlow:SetAtlas(nil)
        castBar.WispMask:SetAtlas(nil)
        castBar.Shine:SetAtlas(nil)
        castBar.CraftGlow:SetAtlas(nil)

        for i = 1,3 do
            castBar["Flakes0"..i]:SetAtlas(nil)
        end

        for i = 1,2 do
            castBar["Sparkles0"..i]:SetAtlas(nil)
        end
    end


    -- castBar.BorderShield:SetTexture(311862)
    -- castBar.BorderShield:SetSize(196, 56)

    if not isParty then
        castBar.iconXPos = BetterBlizzFramesDB[castBar.unit.."CastbarIconXPos"]
        castBar.iconYPos = BetterBlizzFramesDB[castBar.unit.."CastbarIconYPos"]
    else
        castBar.iconXPos = BetterBlizzFramesDB["partyCastbarIconXPos"]
        castBar.iconYPos = BetterBlizzFramesDB["partyCastbarIconYPos"]
    end

    castBar.Icon:ClearAllPoints()
    --self.Icon:SetPoint("RIGHT", castBar, "LEFT", -5, -0.5)
    castBar.Icon:SetPoint("RIGHT", castBar, "LEFT", -5 + castBar.iconXPos, -0.5 + castBar.iconYPos)
    castBar.Icon:SetSize(18,18)

    AdjustBorderSize(castBar)
    AdjustBorderShieldSize(castBar)

    if not castBar.isClassicStyle then
        castBar:HookScript("OnEvent", function(self)
            self:SetStatusBarTexture(137012)
            if self.barType ~= "interrupted" and not self.casting then
                self:SetStatusBarColor(0, 1, 0, 1)
            else
                self:SetStatusBarColor(1, 0.7, 0, 1)
            end
            castBar.TextBorder:SetAlpha(0)
            if castBar == PlayerCastingBarFrame then
                castBar.Text:ClearAllPoints()
                castBar.Text:SetPoint("CENTER", castBar, "CENTER", 0, 0.5)
                AdjustFlash(castBar)
            else
                castBar.Flash:SetAlpha(0)
            end

            self.Background:SetTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
            self.Background:SetVertexColor(0, 0, 0, 0.6)

            self.Border:SetAlpha(1)

            --AdjustBorderSize(self)

            self.Icon:ClearAllPoints()
            --self.Icon:SetPoint("RIGHT", castBar, "LEFT", -5, -0.5)
            self.Icon:SetPoint("RIGHT", self, "LEFT", -5 + castBar.iconXPos, -0.5 + castBar.iconYPos)
            self.Icon:SetSize(18,18)

            if self.BorderShield:IsShown() then
                AdjustBorderShieldSize(self)
                --self.Icon:SetPoint("RIGHT", castBar, "LEFT", -3.5, castBar.adjustedIconYOffset)
                self.Icon:SetPoint("RIGHT", self, "LEFT", -3.5 + castBar.iconXPos, castBar.adjustedIconYOffset + castBar.iconYPos)
                self.Icon:SetSize(castBar.uninterruptibleIconSize, castBar.uninterruptibleIconSize)
                self.Border:SetAlpha(0)

                if self.ChargeTier1 and castBar ~= PlayerCastingBarFrame then
                    HideChargeTiers(self)
                end
            elseif self.barType == "empowered" then
                if castBar ~= PlayerCastingBarFrame then
                    HideChargeTiers(self)
                end
            elseif self.barType == "channeled" then
                self:SetStatusBarColor(0, 1, 0, 1)
            elseif self.barType == "interrupted" then
                self:SetStatusBarColor(1, 0, 0, 1)
            end
        end)

        hooksecurefunc(castBar.BorderShield, "Show", function()
            AdjustBorderShieldSize(castBar)
        end)

        hooksecurefunc(castBar, "PlayFinishAnim", function(self)
            self:SetStatusBarTexture(137012)
            self:SetStatusBarColor(0, 1, 0, 1)
            if castBar == PlayerCastingBarFrame then
                AdjustFlash(castBar)
            else
                castBar.Flash:SetAlpha(0)
            end
        end)

        castBar:HookScript("OnUpdate", function(self)
            self.Spark:SetTexture(130877)
            self.Spark:SetSize(36,36)
            UpdateSparkPosition(castBar)
        end)


        castBar.isClassicStyle = true
    end
end

function BBF.UpdateCastbars()
    local numGroupMembers = GetNumGroupMembers()
    local compactFrame = (_G["PartyFrame"]["MemberFrame1"] and _G["PartyFrame"]["MemberFrame1"]:IsShown() and _G["PartyFrame"]["MemberFrame1"])
                         or (_G["CompactPartyFrameMember1"] and _G["CompactPartyFrameMember1"]:IsShown() and _G["CompactPartyFrameMember1"])
                         --or (_G["CompactRaidFrame1"] and _G["CompactRaidFrame1"]:IsShown() and _G["CompactRaidFrame1"])

    if BetterBlizzFramesDB.showPartyCastbar or BetterBlizzFramesDB.partyCastBarTestMode then
        for i = 1, 5 do
            local spellbar = spellBars[i]
            if spellbar then
                spellbar:SetUnit(BetterBlizzFramesDB.partyCastBarTestMode and "player" or nil)
            end
        end
        if compactFrame and compactFrame:IsShown() and numGroupMembers <= 5 then
            local defaultPartyFrame
            if compactFrame:GetName() == nil then
                defaultPartyFrame = true
                numGroupMembers = numGroupMembers - 1
            end
            for i = 1, 5 do
                local spellbar = spellBars[i]
                if spellbar then
                    if not BetterBlizzFramesDB.partyCastBarTestMode then
                        spellbar:SetUnit(nil)
                    end
                    spellbar:SetParent(UIParent)
                    spellbar:SetScale(BetterBlizzFramesDB.partyCastBarScale)
                    spellbar:SetWidth(BetterBlizzFramesDB.partyCastBarWidth)
                    spellbar:SetHeight(BetterBlizzFramesDB.partyCastBarHeight)
                    -- spellbar.Icon:SetDrawLayer("OVERLAY")
                    -- spellbar.Text:ClearAllPoints()
                    -- spellbar.Text:SetPoint("CENTER", spellbar, "CENTER", 0, 0)

                    -- spellbar.Text:SetAlpha(BetterBlizzFramesDB.partyCastbarShowText and 1 or 0)
                    -- spellbar.Border:SetAlpha(BetterBlizzFramesDB.partyCastbarShowBorder and 1 or 0)
                    -- spellbar.BorderShield:SetAlpha(BetterBlizzFramesDB.partyCastbarShowBorder and 1 or 0)
                    -- spellbar.Flash:SetParent(BetterBlizzFramesDB.partyCastbarShowBorder and spellbar or hiddenFrame)

                    if not BetterBlizzFramesDB.showPartyCastBarIcon then
                        spellbar.Icon:SetAlpha(0)
                        spellbar.BorderShield:SetAlpha(0)
                    else
                        spellbar.Icon:ClearAllPoints()
                        spellbar.Icon:SetPoint("RIGHT", spellbar, "LEFT", -4 + BetterBlizzFramesDB.partyCastbarIconXPos, -5 + BetterBlizzFramesDB.partyCastbarIconYPos)
                        spellbar.Icon:SetScale(BetterBlizzFramesDB.partyCastBarIconScale)
                        spellbar.Icon:SetAlpha(1)
                        spellbar.BorderShield:ClearAllPoints()
                        spellbar.BorderShield:SetPoint("CENTER", spellbar.Icon, "CENTER", 0, 0)
                    end

                    if BetterBlizzFramesDB.classicCastbarsParty then
                        BBF.ClassicCastbar(spellbar, true)
                        if BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeCastbars then
                            local vertexColor = BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeColor or 1
                            local castbarBorder = BetterBlizzFramesDB.darkModeUi and (vertexColor + 0.1) or 1
                            spellbar.Border:SetVertexColor(castbarBorder,castbarBorder,castbarBorder)
                        end
                        spellbar.Text:SetWidth(spellbar:GetWidth())
                        spellbar.Text:SetScale(0.9)
                        spellbar.TextBorder:SetAlpha(0)

                        if BetterBlizzFramesDB.partyCastBarTestMode then
                            spellbar:SetStatusBarTexture(137012)
                            spellbar:SetStatusBarColor(1, 0.7, 0, 1)
                            spellbar.Background:SetTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
                            spellbar.Background:SetVertexColor(0, 0, 0, 0.6)
                        end
                    end

                    local partyFrame = nil

                    if _G["PartyFrame"]["MemberFrame"..i] and _G["PartyFrame"]["MemberFrame"..i]:IsShown() then
                        partyFrame = _G["PartyFrame"]["MemberFrame"..i]
                    elseif _G["CompactPartyFrameMember"..i] and _G["CompactPartyFrameMember"..i]:IsVisible() then
                        partyFrame = _G["CompactPartyFrameMember"..i]
                    -- elseif _G["CompactRaidFrame"..i] and _G["CompactRaidFrame"..i]:IsShown() then
                    --     partyFrame = _G["CompactRaidFrame"..i]
                    end

                    if partyFrame and partyFrame:IsShown() and partyFrame:IsVisible() then
                        local xPos = BetterBlizzFramesDB.partyCastBarXPos + 13
                        local yPos = BetterBlizzFramesDB.partyCastBarYPos + 3
                        if defaultPartyFrame then
                            xPos = xPos + 15
                            yPos = yPos - 20
                        end

                        local unitId = partyFrame.displayedUnit or partyFrame.unit

                        if UnitIsUnit(unitId, "player") and not BetterBlizzFramesDB.partyCastbarSelf then
                            spellbar:SetUnit(nil)
                        else
                            spellbar:SetUnit(unitId, true, true)
                            spellbar:SetFrameStrata("MEDIUM")
                        end

                        spellbar:ClearAllPoints()
                        spellbar:SetPoint("CENTER", partyFrame, "CENTER", BetterBlizzFramesDB.partyCastBarXPos + 13, BetterBlizzFramesDB.partyCastBarYPos + 3)
                    else
                        spellbar:SetUnit(nil)
                    end
                else
                    BBF.CreateCastbars()
                end
            end
        else
            for i = 1, 5 do
                local spellbar = spellBars[i]
                if spellbar then
                    spellbar:SetUnit(nil)
                end
            end
        end
    else
        for i = 1, 5 do
            local spellbar = spellBars[i]
            if spellbar then
                spellbar:SetUnit(nil)
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

        local petFrame = PetFrame
        if petFrame then
            local petDetachCastbar = BetterBlizzFramesDB.petDetachCastbar
            petSpellBar:ClearAllPoints()
            if petDetachCastbar then
                petSpellBar:SetPoint("CENTER", UIParent, "CENTER", xPos, yPos)
            else
                petSpellBar:SetPoint("CENTER", petFrame, "CENTER", xPos + 4, yPos - 27)
            end
            petSpellBar:SetFrameStrata("MEDIUM")
            petSpellBar:SetUnit("pet", true, true)
        else
            petSpellBar:SetUnit(nil)
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
            spellbar.Text:SetWidth(spellbar:GetWidth()+40)
            spellbar.Icon:ClearAllPoints()
            spellbar.Icon:SetPoint("RIGHT", spellbar, "LEFT", -4, -5)
            spellbar.Icon:SetSize(22,22)
            spellbar.Icon:SetScale(BetterBlizzFramesDB.partyCastBarIconScale)
            if not BetterBlizzFramesDB.classicCastbarsParty  then
                spellbar.BorderShield:ClearAllPoints()
                spellbar.BorderShield:SetPoint("RIGHT", spellbar, "LEFT", -1, -7)
                spellbar.BorderShield:SetSize(29,33)
                spellbar.BorderShield:SetScale(BetterBlizzFramesDB.partyCastBarIconScale)
            else
                spellbar.TextBorder:SetAlpha(0)
            end
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

            spellbar:Hide()

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

        petSpellBar:Hide()

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
                spellbar.Icon:SetTexture(C_Spell.GetSpellTexture(116))
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
            spellbar:StopFinishAnims()
        elseif spellbar then
            -- Stop the timer when exiting test mode
            if spellbar.tickTimer then
                spellbar.tickTimer:Cancel()
                spellbar.tickTimer = nil
            end
            spellbar:SetAlpha(0)
            if spellbar.FakeTimer then
                spellbar.FakeTimer:Hide()
            end
            spellbar:StopFinishAnims()
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
            spellBars["pet"].Icon:SetTexture(C_Spell.GetSpellTexture(6358))
        end
        spellBars["pet"].Text:SetText("Seduction")
        if BetterBlizzFramesDB.petCastBarTimer then
            spellBars["pet"].FakeTimer:Show()
        else
            spellBars["pet"].FakeTimer:Hide()
        end
    else
        -- Stop the timer when exiting test mode
        if spellBars["pet"] then
            if spellBars["pet"].tickTimer then
                spellBars["pet"].tickTimer:Cancel()
                spellBars["pet"].tickTimer = nil
            end
            spellBars["pet"]:SetAlpha(0)
            spellBars["pet"].FakeTimer:Hide()
        end
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




--[[
hooksecurefunc(CompactPartyFrame, "RefreshMembers", function()
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


local targetSpellBarTexture = TargetFrameSpellBar:GetStatusBarTexture()
local focusSpellBarTexture = FocusFrameSpellBar:GetStatusBarTexture()
local targetCastbarEdgeHooked
local focusCastbarEdgeHooked

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

function BBF.CastbarRecolorWidgets()
    local classicFrames = C_AddOns.IsAddOnLoaded("ClassicFrames")
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
                    local name, _, _, startTime, endTime, _, _, notInterruptible, spellId = UnitCastingInfo("target")
                    if not name then
                        name, _, _, startTime, endTime, _, notInterruptible, spellId = UnitChannelInfo("target")
                    end

                    if name and not notInterruptible then
                        if castBarRecolorInterrupt then
                            for _, interruptSpellID in ipairs(interruptSpellIDs) do
                                local start, duration = BBF.TWWGetSpellCooldown(interruptSpellID)
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
                                                if not classicFrames and not self.isClassicStyle then
                                                    self:SetStatusBarColor(1,1,1)
                                                end
                                            end
                                            self.Spark:SetVertexColor(1,1,1)
                                        end
                                    else
                                        targetSpellBarTexture:SetDesaturated(false)
                                        if not classicFrames and not self.isClassicStyle then
                                            self:SetStatusBarColor(1,1,1)
                                        end
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
                                    if not classicFrames and not self.isClassicStyle then
                                        self:SetStatusBarColor(1,1,1)
                                    end
                                end
                                self.Spark:SetVertexColor(1,1,1)
                            end
                        else
                            targetSpellBarTexture:SetDesaturated(false)
                            if not classicFrames and not self.isClassicStyle then
                                self:SetStatusBarColor(1,1,1)
                            end
                            self.Spark:SetVertexColor(1,1,1)
                        end
                    else
                        targetSpellBarTexture:SetDesaturated(false)
                        if not classicFrames and not self.isClassicStyle then
                            self:SetStatusBarColor(1,1,1)
                        end
                        self.Spark:SetVertexColor(1,1,1)
                    end
                else
                    targetSpellBarTexture:SetDesaturated(false)
                    if not classicFrames and not self.isClassicStyle then
                        self:SetStatusBarColor(1,1,1)
                    end
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
                    local name, _, _, startTime, endTime, _, _, notInterruptible, spellId = UnitCastingInfo("focus")
                    if not name then
                        name, _, _, startTime, endTime, _, notInterruptible, spellId = UnitChannelInfo("focus")
                    end

                    if name then--and not notInterruptible then
                        if castBarRecolorInterrupt then
                            for _, interruptSpellID in ipairs(interruptSpellIDs) do
                                local start, duration = BBF.TWWGetSpellCooldown(interruptSpellID)
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
                                                if not classicFrames and not self.isClassicStyle then
                                                    self:SetStatusBarColor(1,1,1)
                                                end
                                            end
                                            self.Spark:SetVertexColor(1,1,1)
                                        end
                                    else
                                        focusSpellBarTexture:SetDesaturated(false)
                                        if not classicFrames and not self.isClassicStyle then
                                            self:SetStatusBarColor(1,1,1)
                                        end
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
                                    if not classicFrames and not self.isClassicStyle then
                                        self:SetStatusBarColor(1,1,1)
                                    end
                                end
                                if not classicFrames and not self.isClassicStyle then
                                    self:SetStatusBarColor(1,1,1)
                                end
                            end
                        else
                            focusSpellBarTexture:SetDesaturated(false)
                            if not classicFrames and not self.isClassicStyle then
                                self:SetStatusBarColor(1,1,1)
                            end
                            self.Spark:SetVertexColor(1,1,1)
                        end
                    else
                        focusSpellBarTexture:SetDesaturated(false)
                        if not classicFrames and not self.isClassicStyle then
                            self:SetStatusBarColor(1,1,1)
                        end
                        self.Spark:SetVertexColor(1,1,1)
                    end
                else
                    focusSpellBarTexture:SetDesaturated(false)
                    if not classicFrames and not self.isClassicStyle then
                        self:SetStatusBarColor(1,1,1)
                    end
                    self.Spark:SetVertexColor(1,1,1)
                end
            end)
            focusCastbarEdgeHooked = true
        end

        -- if castBarRecolorInterrupt then
        --     local function HookGexCastbars(spellBar, i)
        --         local spellBarTexture = spellBar:GetStatusBarTexture()
        --         local unit = "arena"..i
        --         spellBar:HookScript("OnUpdate", function(self, elapsed)
        --             if self.isCasting or self.isChanneling then
        --                 print("x")
        --                 local name, _, _, startTime, endTime, _, _, notInterruptible, spellId = UnitCastingInfo(unit)
        --                 if not name then
        --                     name, _, _, startTime, endTime, _, notInterruptible, spellId = UnitChannelInfo(unit)
        --                 end
                
        --                 if name and not notInterruptible then
        --                     for _, interruptSpellID in ipairs(interruptSpellIDs) do
        --                         local start, duration = BBF.TWWGetSpellCooldown(interruptSpellID)
        --                         local cooldownRemaining = start + duration - GetTime()
        --                         local castRemaining = (endTime/1000) - GetTime()
                
        --                         if cooldownRemaining > 0 and cooldownRemaining > castRemaining then
        --                             spellBarTexture:SetDesaturated(true)
        --                             self:SetStatusBarColor(unpack(castBarNoInterruptColor))
        --                             --self.Spark:SetVertexColor(unpack(castBarNoInterruptColor))
        --                         elseif cooldownRemaining > 0 and cooldownRemaining <= castRemaining then
        --                             spellBarTexture:SetDesaturated(true)
        --                             self:SetStatusBarColor(unpack(castBarDelayedInterruptColor))
        --                             --self.Spark:SetVertexColor(unpack(castBarDelayedInterruptColor))
        --                         else
        --                             spellBarTexture:SetDesaturated(false)
        --                             --self:SetStatusBarColor(1,1,1)
        --                             --self.Spark:SetVertexColor(1,1,1)
        --                         end
        --                     end
        --                 else
        --                     spellBarTexture:SetDesaturated(false)
        --                     --self:SetStatusBarColor(1,1,1)
        --                     --self.Spark:SetVertexColor(1,1,1)
        --                 end
        --             end
        --         end)
        --     end
            
            
        --     if C_AddOns.IsAddOnLoaded("GladiusEx") then
        --         print("huh")
        --         if BBF.GexCastbarHooked then return end
        --         C_Timer.After(5, function()
        --             for i = 1, 3 do
        --                 local spellBar = _G["GladiusExCastBararena"..i.."Bar"]
        --                 if spellBar then
        --                     HookGexCastbars(spellBar, i)
        --                     print("hooking bar")
        --                 end
        --             end
        --             BBF.GexCastbarHooked = true
        --         end)

        --     end
        -- end

    end
end

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
    PlayerCastingBarFrame:SetScale(BetterBlizzFramesDB.playerCastBarScale or 1)
    PlayerCastingBarFrame:SetWidth(BetterBlizzFramesDB.playerCastBarWidth)
    PlayerCastingBarFrame:SetHeight(BetterBlizzFramesDB.playerCastBarHeight)
    PlayerCastingBarFrame.Text:ClearAllPoints()
    PlayerCastingBarFrame.Text:SetPoint("BOTTOM", PlayerCastingBarFrame, "BOTTOM", 0, -14)
    PlayerCastingBarFrame.Text:SetWidth(BetterBlizzFramesDB.playerCastBarWidth)
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
    BBF.UpdateUserAuraSettings()
    local classicFrames = C_AddOns.IsAddOnLoaded("ClassicFrames")
    local xClassicAdjustment = classicFrames and -1 or 0
    local yClassicAdjustment = classicFrames and 6 or 0
    --Player
    if not BetterBlizzFramesDB.playerCastBarScale then
        BetterBlizzFramesDB.playerCastBarScale = PlayerCastingBarFrame:GetScale()
    end
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
    TargetFrameSpellBar.Icon:SetPoint(a, b, c, -2 + BetterBlizzFramesDB.targetCastbarIconXPos + xClassicAdjustment, -5 + BetterBlizzFramesDB.targetCastbarIconYPos + yClassicAdjustment)

    if not classicFrames then
        TargetFrameSpellBar.BorderShield:ClearAllPoints()
        TargetFrameSpellBar.BorderShield:SetPoint("CENTER", TargetFrameSpellBar.Icon, "CENTER", 0, 0)
        TargetFrameSpellBar.BorderShield:SetScale(BetterBlizzFramesDB.targetCastBarIconScale)
        TargetFrameSpellBar.Text:ClearAllPoints()
        TargetFrameSpellBar.Text:SetPoint("BOTTOM", TargetFrameSpellBar, "BOTTOM", 0, -14)
    end
    TargetFrameSpellBar.Text:SetWidth(BetterBlizzFramesDB.targetCastBarWidth)

    --Focus
    FocusFrameSpellBar:SetScale(BetterBlizzFramesDB.focusCastBarScale)
    FocusFrameSpellBar:SetWidth(BetterBlizzFramesDB.focusCastBarWidth)
    FocusFrameSpellBar:SetHeight(BetterBlizzFramesDB.focusCastBarHeight)
    local a,b,c,d,e = FocusFrameSpellBar.Icon:GetPoint()
    FocusFrameSpellBar.Icon:ClearAllPoints()
    FocusFrameSpellBar.Icon:SetPoint(a, b, c, -2 + BetterBlizzFramesDB.focusCastbarIconXPos + xClassicAdjustment, -5 + BetterBlizzFramesDB.focusCastbarIconYPos + yClassicAdjustment)
    FocusFrameSpellBar.Icon:SetScale(BetterBlizzFramesDB.focusCastBarIconScale)

    if not classicFrames then
        FocusFrameSpellBar.BorderShield:ClearAllPoints()
        FocusFrameSpellBar.BorderShield:SetPoint("CENTER", FocusFrameSpellBar.Icon, "CENTER", 0, 0)
        FocusFrameSpellBar.BorderShield:SetScale(BetterBlizzFramesDB.focusCastBarIconScale)
        FocusFrameSpellBar.Text:ClearAllPoints()
        FocusFrameSpellBar.Text:SetPoint("BOTTOM", FocusFrameSpellBar, "BOTTOM", 0, -14)
    end
    FocusFrameSpellBar.Text:SetWidth(BetterBlizzFramesDB.focusCastBarWidth)


    if BetterBlizzFramesDB.classicCastbars then
        BBF.ClassicCastbar(TargetFrameSpellBar)
        BBF.ClassicCastbar(FocusFrameSpellBar)
    end
    if BetterBlizzFramesDB.classicCastbarsPlayer then
        BBF.ClassicCastbar(PlayerCastingBarFrame)
    end
end

PlayerCastingBarFrame:HookScript("OnShow", function()
    local showIcon = BetterBlizzFramesDB.playerCastBarShowIcon
    if showIcon then
        local playerCastBarIconScale = BetterBlizzFramesDB.playerCastBarIconScale
        PlayerCastingBarFrame.Icon:Show()
        --PlayerCastingBarFrame.showShield = true --taint concern TODO: add non-taint method
        PlayerCastingBarFrame.BorderShield:SetSize(30,36)
        PlayerCastingBarFrame.BorderShield:ClearAllPoints()
        PlayerCastingBarFrame.BorderShield:SetPoint("CENTER", PlayerCastingBarFrame.Icon, "CENTER", 0, 0)
        PlayerCastingBarFrame.BorderShield:SetScale(playerCastBarIconScale)
        PlayerCastingBarFrame.BorderShield:SetDrawLayer("BORDER")
    end
end)

hooksecurefunc(PlayerCastingBarFrame, "SetScale", function()
    if EditModeManagerFrame.editModeActive then
        BetterBlizzFramesDB.playerCastBarScale = PlayerCastingBarFrame:GetScale()
    end

    if not PlayerCastingBarFrame.isUpdating then
        PlayerCastingBarFrame.isUpdating = true
        PlayerCastingBarFrameMiscAdjustments()
        PlayerCastingBarFrame.isUpdating = false
    end
end)

local evokerCastbarsHooked
function BBF.HookCastbarsForEvoker()
    if (not evokerCastbarsHooked and BetterBlizzFramesDB.normalCastbarForEmpoweredCasts) then
        local castBars = {}

        if not BetterBlizzFramesDB.classicCastbars then
            table.insert(castBars, TargetFrameSpellBar)
            table.insert(castBars, FocusFrameSpellBar)
        end

        local function NormalEvokerCastbar(castBar)
            if castBar.empoweredFix then return end

            castBar:HookScript("OnEvent", function(self)
                if self:IsForbidden() then return end
                if self.barType == "uninterruptable" then
                    if self.ChargeTier1 then
                        if self.isSArena then
                            self:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
                            self:SetStatusBarColor(0.7, 0.7, 0.7, 1)
                        else
                            self:SetStatusBarTexture("UI-CastingBar-Uninterruptable")
                        end
                        HideChargeTiers(self)
                    end
                elseif self.barType == "empowered" then
                    if self.isSArena then
                        self:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
                        self:SetStatusBarColor(1, 0.7, 0, 1)
                    else
                        self:SetStatusBarTexture("ui-castingbar-filling-standard")
                    end
                    HideChargeTiers(self)
                end
            end)

            local sparkWidth = castBar.isSArena and 2 or 6
            castBar:HookScript("OnUpdate", function(self)
                if self:IsForbidden() then return end
                if self.barType == "uninterruptable" then
                    if self.ChargeTier1 then
                        self.Spark:SetAtlas("UI-CastingBar-Pip")
                        self.Spark:SetSize(sparkWidth,16)
                        UpdateSparkPosition(castBar)
                    end
                elseif self.barType == "empowered" then
                    self.Spark:SetAtlas("UI-CastingBar-Pip")
                    self.Spark:SetSize(sparkWidth,16)
                    UpdateSparkPosition(castBar)
                end
            end)

            castBar.empoweredFix = true
        end

        if sArena then
            for i = 1, 3 do
                local arenaFrame = sArena["arena" .. i]
                if arenaFrame and arenaFrame.CastBar then
                    -- Mark the cast bars as belonging to sArena
                    arenaFrame.CastBar.isSArena = true
                    table.insert(castBars, arenaFrame.CastBar)
                end
            end
        end

        for _, castBar in ipairs(castBars) do
            NormalEvokerCastbar(castBar)
        end

        evokerCastbarsHooked = true
    end
end

function BBF.HookCastbars()
    if BetterBlizzFramesDB.quickHideCastbars then
        local hideEvents = {
            ["UNIT_SPELLCAST_STOP"] = true,
            ["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
            ["UNIT_SPELLCAST_INTERRUPTED"] = true,
            ["UNIT_SPELLCAST_EMPOWER_STOP"] = true,
        }
        TargetFrameSpellBar:HookScript("OnEvent", function(self, event, ...)
            if hideEvents[event] then
                self:Hide()
            end
        end)
        FocusFrameSpellBar:HookScript("OnEvent", function(self, event, ...)
            if hideEvents[event] then
                self:Hide()
            end
        end)
    end

    if BetterBlizzFramesDB.petCastbar then
        local petUpdate = CreateFrame("Frame")
        petUpdate:RegisterEvent("UNIT_PET")
        petUpdate:SetScript("OnEvent", function(self, event, ...)
            BBF.UpdatePetCastbar()
        end)
    end
end