local L = BBF.L
local spellBars = {}
local classicCastbarTexture = 137012

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------
local BORDER_ADJUST        = 15 / 50
local BORDER_H_SCALE       = 5.0
local CASTBAR_ELEMENT_GAP  = 5
local CASTBAR_Y_OFFSET     = -30

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------
local function FitBorder(bar, border)
    local barWidth, barHeight, borderWidth, borderHeight = 150, 10, 196, 49
    if bar == CastingBarFrame then
        barWidth, barHeight, borderWidth, borderHeight = 195, 13, 256, 64
    end

    local deltaWidth = bar:GetWidth() - barWidth
    local deltaHeight = bar:GetHeight() - barHeight
    border:ClearAllPoints()
    border:SetPoint("CENTER", bar, "CENTER", 0, 0)
    border:SetSize(
        borderWidth + deltaWidth + (deltaWidth * BORDER_ADJUST),
        borderHeight + (deltaHeight * BORDER_H_SCALE)
    )
end

local function UpdateCastTimer(self)
    if not self.Timer or not self.Timer:IsShown() or self.testStartTime then return end
    local val = self:GetValue()
    local _, maxVal = self:GetMinMaxValues()
    if maxVal <= 0 then return end
    local remaining = self.channeling and val or (maxVal - val)
    self.Timer:SetText(format("%.1f", remaining))
end

local function AttachTimerHook(bar)
    if not bar.Timer then return end
    if bar.timerHooked then return end
    bar:HookScript("OnUpdate", UpdateCastTimer)
    bar.timerHooked = true
end

local function CreateBar(name, unit)
    if _G[name] then return _G[name] end
    local bar = CreateFrame("StatusBar", name, UIParent, "SmallCastingBarFrameTemplate")
    CastingBarFrame_SetUnit(bar, unit, true, true)
    bar:SetStatusBarTexture(classicCastbarTexture)
    bar.Text:SetFontObject("SystemFont_Shadow_Med1_Outline")
    bar:Hide()
    return bar
end

local function StyleBar(bar, opts)
    if not bar or not bar.Text or not bar.Border then return end

    -- Geometry
    bar:SetScale(opts.scale)
    bar:SetWidth(opts.width)
    bar:SetHeight(opts.height)
    bar:SetStatusBarTexture(opts.texture or classicCastbarTexture)
    -- if opts.ignoreParentAlpha then bar:SetIgnoreParentAlpha(true) end

    -- Text
    bar.Text:ClearAllPoints()
    bar.Text:SetPoint("CENTER", bar, "CENTER", 0, 0)
    bar.Text:SetWidth(opts.width)
    bar.Text:SetShown(opts.showText)

    -- Border
    bar.Border:SetShown(opts.showBorder)
    bar.bbfHideBorder = not opts.showBorder
    bar.Flash:SetShown(opts.showBorder)
    if not bar.bbfFlashHooked then
        hooksecurefunc(bar.Flash, "Show", function(self)
            if self:GetParent().bbfHideBorder then
                self:Hide()
            end
        end)
        bar.bbfFlashHooked = true
    end
    FitBorder(bar, bar.Border)
    FitBorder(bar, bar.Flash)

    -- Icon
    if not opts.showIcon then
        bar.Icon:Hide()
    else
        local iconSize = bar:GetHeight() * 2
        bar.Icon:SetSize(iconSize, iconSize)
        bar.Icon:ClearAllPoints()
        bar.Icon:SetPoint("RIGHT", bar, "LEFT", -CASTBAR_ELEMENT_GAP + (opts.iconX or 0), opts.iconY or 0)
        bar.Icon:SetScale(opts.iconScale or 1)
        -- bar.Icon:SetDrawLayer("OVERLAY", 7)
        bar.Icon:Show()

    end

    -- Timer
    if not bar.Timer then
        bar.Timer = bar:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1_Outline")
        bar.Timer:SetPoint("LEFT", bar, "RIGHT", CASTBAR_ELEMENT_GAP, 0)
    end
    bar.Timer:SetShown(opts.showTimer)
    AttachTimerHook(bar)

    -- Re-apply texture after Blizzard resets on cast events
    if not bar.bbfTextureHooked then
        bar:HookScript("OnEvent", function(self)
            self:SetStatusBarTexture(classicCastbarTexture)
        end)
        bar.bbfTextureHooked = true
    end
end

local function GetVisibleFrame(name)
    local frame = _G[name]
    return frame and frame:IsShown() and frame
end

local function GetPartySlotFrame(i, useCompact)
    if useCompact then
        return GetVisibleFrame("CompactPartyFrameMember" .. i)
            or GetVisibleFrame("CompactRaidFrame" .. i)
    end
    return GetVisibleFrame("PartyMemberFrame" .. i)
end

local function PartyBarOpts(db)
    return {
        scale      = db.partyCastBarScale,
        width      = db.partyCastBarWidth,
        height     = db.partyCastBarHeight,
        showText   = db.partyCastbarShowText,
        showBorder = db.partyCastbarShowBorder,
        showIcon   = db.showPartyCastBarIcon,
        iconX      = db.partyCastbarIconXPos,
        iconY      = db.partyCastbarIconYPos,
        iconScale  = db.partyCastBarIconScale,
        showTimer  = db.partyCastBarTimer,
    }
end

---------------------------------------------------------------------------
-- Castbar functions
---------------------------------------------------------------------------

function BBF.UpdateCastbars()
    local db = BetterBlizzFramesDB

    if db.partyCastBarTestMode then
        BBF.partyCastBarTestMode()
        return
    end

    if not db.showPartyCastbar then
        for i = 1, MEMBERS_PER_RAID_GROUP do
            if spellBars[i] then CastingBarFrame_SetUnit(spellBars[i], nil) end
        end
        return
    end

    if GetNumGroupMembers() > MEMBERS_PER_RAID_GROUP then
        for i = 1, MEMBERS_PER_RAID_GROUP do
            if spellBars[i] then CastingBarFrame_SetUnit(spellBars[i], nil) end
        end
        return
    end

    -- Create bars only when we know we need them
    for i = 1, MEMBERS_PER_RAID_GROUP do
        spellBars[i] = CreateBar("Party" .. i .. "SpellBar", "party" .. i)
    end

    local useCompact = GetCVarBool("useCompactPartyFrames")
    for i = 1, MEMBERS_PER_RAID_GROUP do
        local bar = spellBars[i]
        CastingBarFrame_SetUnit(bar, nil)

        StyleBar(bar, PartyBarOpts(db))

        local slotFrame = GetPartySlotFrame(i, useCompact)

        if not slotFrame or not slotFrame:IsVisible() then
            CastingBarFrame_SetUnit(bar, nil)
        else
            local xPos = db.partyCastBarXPos
            local yPos = db.partyCastBarYPos
            if not useCompact then
                yPos = yPos + CASTBAR_Y_OFFSET
            end

            local unitId = slotFrame.displayedUnit or slotFrame.unit
            local skipUnit = not unitId
                or unitId:match("^partypet%d$")
                or (UnitIsUnit(unitId, "player") and not db.partyCastbarSelf)

            if skipUnit then
                CastingBarFrame_SetUnit(bar, nil)
            else
                CastingBarFrame_SetUnit(bar, unitId, true, true)
                bar:SetFrameStrata("MEDIUM")
                bar:ClearAllPoints()
                bar:SetPoint("CENTER", slotFrame, "CENTER", xPos, yPos)
            end
        end
    end

    BBF.DarkModeCastbars()
end

local function PetBarOpts(db)
    return {
        scale      = db.petCastBarScale,
        width      = db.petCastBarWidth,
        height     = db.petCastBarHeight,
        showText   = db.petCastBarShowText,
        showBorder = db.petCastBarShowBorder,
        showIcon   = db.showPetCastBarIcon,
        iconX      = db.petCastbarIconXPos,
        iconY      = db.petCastbarIconYPos,
        iconScale  = db.petCastBarIconScale,
        showTimer  = db.petCastBarTimer,
    }
end

local function AnchorPetBar(bar, db)
    local petFrame = PetFrame
    if petFrame then
        bar:ClearAllPoints()
        if db.petDetachCastbar then
            bar:SetPoint("CENTER", UIParent, "CENTER", db.petCastBarXPos, db.petCastBarYPos)
        else
            bar:SetPoint("CENTER", petFrame, "CENTER", db.petCastBarXPos, db.petCastBarYPos + CASTBAR_Y_OFFSET)
        end
        bar:SetFrameStrata("MEDIUM")
        return true
    end
    return false
end

function BBF.UpdatePetCastbar()
    local db = BetterBlizzFramesDB

    if db.petCastBarTestMode then
        BBF.petCastBarTestMode()
        return
    end

    if not db.petCastbar then
        if spellBars["pet"] then CastingBarFrame_SetUnit(spellBars["pet"], nil) end
        return
    end

    spellBars["pet"] = CreateBar("PetSpellBar", "pet")
    local bar = spellBars["pet"]

    StyleBar(bar, PetBarOpts(db))

    if AnchorPetBar(bar, db) then
        CastingBarFrame_SetUnit(bar, "pet", true, true)
    else
        CastingBarFrame_SetUnit(bar, nil)
    end

    BBF.DarkModeCastbars()
end

function BBF.ChangeCastbarSizes()
    local db = BetterBlizzFramesDB
    -- BBF.UpdateUserAuraSettings() -- aura concern, doesn't belong in castbar module

    -- Player
    StyleBar(CastingBarFrame, {
        scale      = db.playerCastBarScale,
        width      = db.playerCastBarWidth,
        height     = db.playerCastBarHeight,
        showText   = db.playerCastBarShowText,
        showBorder = db.playerCastBarShowBorder,
        showIcon   = db.playerCastBarShowIcon,
        iconX      = -CASTBAR_ELEMENT_GAP + db.playerCastbarIconXPos,
        iconY      = db.playerCastbarIconYPos,
        iconScale  = db.playerCastBarIconScale,
        showTimer  = db.playerCastBarTimer,
    })

    local bottomY = CastingBarFrame:GetBottom()
    if bottomY then
        local centerY = bottomY + CastingBarFrame:GetHeight() / 2
        BBF.MoveRegion(CastingBarFrame, "CENTER", UIParent, "BOTTOM",
            db.playerCastBarXPos, centerY + db.playerCastBarYPos)
    end

    -- Spark hook (player only — Blizzard doesn't reposition for custom widths)
    if not CastingBarFrame.bbfSparkHooked then
        CastingBarFrame:HookScript("OnUpdate", function(self)
            self.Spark:SetHeight(db.playerCastBarHeight * 2.5)
            local val = self:GetValue()
            local _, maxVal = self:GetMinMaxValues()
            if maxVal > 0 then
                self.Spark:ClearAllPoints()
                self.Spark:SetPoint("CENTER", self, "LEFT", self:GetWidth() * (val / maxVal), -1.5)
            end
        end)
        CastingBarFrame.bbfSparkHooked = true
    end

    -- Target (XY positioning handled in auras.lua)
    StyleBar(TargetFrameSpellBar, {
        scale      = db.targetCastBarScale,
        width      = db.targetCastBarWidth,
        height     = db.targetCastBarHeight,
        showText   = db.targetCastBarShowText,
        showBorder = db.targetCastBarShowBorder,
        showIcon   = true, -- no DB key exists for target icon visibility
        iconX      = db.targetCastbarIconXPos,
        iconY      = db.targetCastbarIconYPos,
        iconScale  = db.targetCastBarIconScale,
        showTimer  = db.targetCastBarTimer,
    })

    -- Font customization
    if db.changeUnitFrameFont then
        local font = BBF.GetActiveFont()
        if font then
            local _, playerFontSize = CastingBarFrame.Text:GetFont()
            local _, targetFontSize = TargetFrameSpellBar.Text:GetFont()
            CastingBarFrame.Text:SetFont(font, playerFontSize, "OUTLINE")
            TargetFrameSpellBar.Text:SetFont(font, targetFontSize, "OUTLINE")
        end
    end
end

function BBF.ShowPlayerCastBarIcon()
    if CastingBarFrame then
        if BetterBlizzFramesDB.playerCastBarShowIcon then
            CastingBarFrame.Icon:Show()
        else
            CastingBarFrame.Icon:Hide()
        end
    end
end

function BBF.CastBarTimerCaller()
    BBF.ChangeCastbarSizes()
end

function BBF.UpdateClassicCastbarTexture(texture)
    classicCastbarTexture = texture
end

function BBF.CreateCastbars()
    BBF.UpdateCastbars()
    BBF.UpdatePetCastbar()
end

---------------------------------------------------------------------------
-- Test Mode
---------------------------------------------------------------------------
local function AnimateTestBar(bar, enabled, opts)
    if not bar then return end
    opts = opts or {}

    if enabled then
        CastingBarFrame_SetUnit(bar, nil)
        bar:Show()
        bar:SetMinMaxValues(0, 100)
        bar:SetValue(0)
        bar.Text:SetText(opts.spellName)
        bar.Flash:Hide()

        if opts.showIcon and opts.iconTexture then
            bar.Icon:SetTexture(opts.iconTexture)
            bar.Icon:Show()
        end

        if bar.Timer then
            bar.Timer:SetShown(opts.showTimer)
        end

        bar.testStartTime = GetTime()
        if not bar.testHooked then
            bar:HookScript("OnUpdate", function(self)
                if not self.testStartTime then return end
                local elapsed = GetTime() - self.testStartTime
                local progress = (elapsed % 3) / 3
                self:SetValue(progress * 100)
                if self.Timer and self.Timer:IsShown() then
                    self.Timer:SetText(format("%.1f", 3 - (progress * 3)))
                end
            end)
            bar.testHooked = true
        end
    else
        bar.testStartTime = nil
        bar:Hide()
        bar.Icon:Hide()
        if bar.Timer then bar.Timer:Hide() end
    end
end

function BBF.partyCastBarTestMode()
    local db = BetterBlizzFramesDB

    if db.partyCastBarTestMode then
        -- Clean up previous test state
        for i = 1, MEMBERS_PER_RAID_GROUP do
            if spellBars[i] then
                AnimateTestBar(spellBars[i], false)
            end
        end
        local useCompact = GetCVarBool("useCompactPartyFrames")
        local inGroup = GetNumGroupMembers() > 0

        -- Fill up default party frames when solo or in group with default frames
        if not useCompact or not inGroup then
            for i = 1, MAX_PARTY_MEMBERS do
                local frame = _G["PartyMemberFrame" .. i]
                if frame and not frame:IsShown() then
                    frame:Show()
                    frame.bbfTestShown = true
                end
            end
        end

        -- Create, style, anchor, and animate
        for i = 1, MEMBERS_PER_RAID_GROUP do
            spellBars[i] = CreateBar("Party" .. i .. "SpellBar", "party" .. i)

            StyleBar(spellBars[i], PartyBarOpts(db))

            local slotFrame = GetPartySlotFrame(i, useCompact)

            -- Skip own frame unless self-cast is enabled
            if slotFrame then
                local unitId = slotFrame.displayedUnit or slotFrame.unit

                if unitId and UnitIsUnit(unitId, "player") and not db.partyCastbarSelf then
                    slotFrame = nil
                end
            end

            if not slotFrame then
                AnimateTestBar(spellBars[i], false)
            else
                local xPos = db.partyCastBarXPos
                local yPos = db.partyCastBarYPos
                if not useCompact then
                    yPos = yPos + CASTBAR_Y_OFFSET
                end

                spellBars[i]:ClearAllPoints()
                spellBars[i]:SetPoint("CENTER", slotFrame, "CENTER", xPos, yPos)
                spellBars[i]:SetFrameStrata("MEDIUM")

                AnimateTestBar(spellBars[i], true, {
                    showIcon = db.showPartyCastBarIcon,
                    iconTexture = GetSpellTexture(116),
                    spellName = L["Label_Frostbolt"],
                    showTimer = db.partyCastBarTimer,
                })
            end
        end

        BBF.DarkModeCastbars()
    else
        -- Hide frames we forced visible
        for i = 1, MAX_PARTY_MEMBERS do
            local frame = _G["PartyMemberFrame" .. i]
            if frame and frame.bbfTestShown then
                frame:Hide()
                frame.bbfTestShown = nil
            end
        end

        -- Stop animations
        for i = 1, MEMBERS_PER_RAID_GROUP do
            if spellBars[i] then
                AnimateTestBar(spellBars[i], false)
            end
        end

        BBF.UpdateCastbars()
    end
end

function BBF.petCastBarTestMode()
    local db = BetterBlizzFramesDB

    if db.petCastBarTestMode then
        spellBars["pet"] = CreateBar("PetSpellBar", "pet")
        local bar = spellBars["pet"]

        StyleBar(bar, PetBarOpts(db))
        AnchorPetBar(bar, db)

        AnimateTestBar(bar, true, {
            showIcon = db.showPetCastBarIcon,
            iconTexture = GetSpellTexture(6358),
            spellName = L["Label_Seduction"],
            showTimer = db.petCastBarTimer,
        })

        BBF.DarkModeCastbars()
    else
        if spellBars["pet"] then
            AnimateTestBar(spellBars["pet"], false)
        end
        BBF.UpdatePetCastbar()
    end
end




function BBF.HookCastbarsForEvoker() end
function BBF.CastbarRecolorWidgets() end
function BBF.InitializeInterruptSpellID() end


