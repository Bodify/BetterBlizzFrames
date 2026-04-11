local L = BBF.L
local spellBars = {}
local DEFAULT_CASTBAR_TEXTURE = 137012
local classicCastbarTexture = DEFAULT_CASTBAR_TEXTURE

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------
local BORDER_ADJUST        = 15 / 50
local BORDER_H_SCALE       = 5.0
local CASTBAR_ELEMENT_GAP  = 5
local CASTBAR_Y_OFFSET     = -30

---------------------------------------------------------------------------
-- Core Helpers
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
    if remaining <= 0 then self.Timer:SetText("") return end
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
    end
    bar.Timer:ClearAllPoints()
    if opts.timerCentered then
        bar.Timer:SetPoint("BOTTOM", bar, "TOP", 0, 6)
    else
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

---------------------------------------------------------------------------
-- Party Castbars
---------------------------------------------------------------------------
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

local function AnchorPartyBar(bar, slotFrame, db, useCompact)
    bar:ClearAllPoints()
    local yPos = db.partyCastBarYPos + (useCompact and 0 or CASTBAR_Y_OFFSET)
    bar:SetPoint("CENTER", slotFrame, "CENTER", db.partyCastBarXPos, yPos)
    bar:SetFrameStrata("MEDIUM")
end

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
            local unitId = slotFrame.displayedUnit or slotFrame.unit
            local skipUnit = not unitId
                or unitId:match("^partypet%d$")
                or (UnitIsUnit(unitId, "player") and not db.partyCastbarSelf)

            if skipUnit then
                CastingBarFrame_SetUnit(bar, nil)
            else
                CastingBarFrame_SetUnit(bar, unitId, true, true)
                AnchorPartyBar(bar, slotFrame, db, useCompact)
            end
        end
    end

    BBF.DarkModeCastbars()
end

---------------------------------------------------------------------------
-- Pet Castbar
---------------------------------------------------------------------------
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

---------------------------------------------------------------------------
-- Player + Target Castbars
---------------------------------------------------------------------------
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
        showTimer      = db.playerCastBarTimer,
        timerCentered  = db.playerCastBarTimerCentered,
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
        local fontPath = BBF.LSM:Fetch(BBF.LSM.MediaType.FONT, db.unitFrameFont)
        if fontPath then
            local outline = db.unitFrameFontOutline or "THINOUTLINE"
            local _, playerFontSize = CastingBarFrame.Text:GetFont()
            local _, targetFontSize = TargetFrameSpellBar.Text:GetFont()
            CastingBarFrame.Text:SetFont(fontPath, playerFontSize, outline)
            TargetFrameSpellBar.Text:SetFont(fontPath, targetFontSize, outline)
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
        -- FIX: Update darkmode borders so they follow icon visibility
        BBF.DarkModeCastbars()
    end
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
        local inGroup = IsInGroup()

        -- Fill up default party frames when solo or in group with default frames
        if not useCompact or not inGroup then
            -- We force-show default PartyMemberFrames here, so the
            -- lookup must also target them instead of compact frames.
            useCompact = false
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
                AnchorPartyBar(spellBars[i], slotFrame, db, useCompact)

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

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------
function BBF.CastBarTimerCaller()
    BBF.ChangeCastbarSizes()
end

function BBF.UpdateClassicCastbarTexture(texture)
    classicCastbarTexture = BetterBlizzFramesDB.changeUnitFrameCastbarTexture and texture or DEFAULT_CASTBAR_TEXTURE
end

function BBF.CreateCastbars()
    BBF.UpdateCastbars()
    BBF.UpdatePetCastbar()
end

function BBF.RefreshCastbars()
    BBF.UpdateCastbars()
    BBF.UpdatePetCastbar()
    BBF.ChangeCastbarSizes()
    BBF.DarkModeCastbars()
end

function BBF.HookCastbarsForEvoker() end

---------------------------------------------------------------------------
-- Event Wiring
---------------------------------------------------------------------------
local groupEventFrame = CreateFrame("Frame")
groupEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
groupEventFrame:SetScript("OnEvent", function()
    if BetterBlizzFramesDB.showPartyCastbar then
        BBF.UpdateCastbars()
    end
    if BetterBlizzFramesDB.partyCastBarTestMode then
        BBF.partyCastBarTestMode()
    end
end)

local petEventFrame = CreateFrame("Frame")
petEventFrame:RegisterEvent("UNIT_PET")
petEventFrame:SetScript("OnEvent", function(_, _, unit)
    if unit == "player" then
        BBF.InitializeInterruptSpellID()
    end
    if BetterBlizzFramesDB.petCastbar then
        BBF.UpdatePetCastbar()
    end
end)

---------------------------------------------------------------------------
-- Interrupt Highlighting (target castbar only — no FocusFrame in Era)
---------------------------------------------------------------------------
local interruptList = {
    -- Druid
    [16979]  = true,  -- Feral Charge (Bear)

    -- Mage
    [2139]   = true,  -- Counterspell

    -- Rogue
    [1766]   = true,  -- Kick

    -- Shaman
    [8042]   = true,  -- Earth Shock

    -- Warlock
    [19647]  = true,  -- Spell Lock (Felhunter)

    -- Warrior
    [72]     = true,  -- Shield Bash
    [6552]   = true,  -- Pummel
}

local interruptSpellIDs = {}

function BBF.InitializeInterruptSpellID()
    interruptSpellIDs = {}
    for spellID in pairs(interruptList) do
        if IsSpellKnownOrOverridesKnown(spellID)
        or (UnitExists("pet") and IsSpellKnownOrOverridesKnown(spellID, true)) then
            table.insert(interruptSpellIDs, spellID)
        end
    end
end

-- Cached config (read from DB via CastbarRecolorWidgets)
local highlightStartTime, highlightEndTime
local edgeColor, middleColor, colorMiddle
local castBarNoInterruptColor, castBarDelayedInterruptColor
local castBarRecolorInterrupt
local targetCastbarEdgeHighlight
local targetCastbarEdgeHooked

local targetSpellBarTexture

local function resetDefault(self)
    targetSpellBarTexture:SetDesaturated(false)
    self:SetStatusBarColor(1, 0.702, 0)
    self.Spark:SetVertexColor(1, 1, 1)
end

local function applyEdgeHighlight(self, startTime, endTime)
    local now = GetTime()
    local elapsed = now - startTime / 1000
    local remaining = endTime / 1000 - now

    if (elapsed <= highlightStartTime) or (remaining <= highlightEndTime) then
        targetSpellBarTexture:SetDesaturated(true)
        self:SetStatusBarColor(unpack(edgeColor))
        self.Spark:SetVertexColor(unpack(edgeColor))
    elseif colorMiddle then
        targetSpellBarTexture:SetDesaturated(true)
        self:SetStatusBarColor(unpack(middleColor))
        self.Spark:SetVertexColor(1, 1, 1)
    else
        resetDefault(self)
    end
end

local function GetInterruptState(castLeft)
    local now = GetTime()
    local best = "cannot"
    for _, id in ipairs(interruptSpellIDs) do
        local start, dur = GetSpellCooldown(id)
        local cdLeft = start + dur - now
        if cdLeft <= 0 then
            return "available"
        elseif cdLeft <= castLeft then
            best = "delayed"
        end
    end
    return best
end

local function HookTargetInterruptHighlight()
    if targetCastbarEdgeHooked then return end

    targetSpellBarTexture = TargetFrameSpellBar:GetStatusBarTexture()
    BBF.InitializeInterruptSpellID()

    TargetFrameSpellBar:HookScript("OnUpdate", function(self)
        if not UnitCanAttack(TargetFrame.unit, "player") then
            resetDefault(self)
            return
        end

        local name, _, _, startTime, endTime, _, _, notInterruptible = UnitCastingInfo("target")
        if not name then
            name, _, _, startTime, endTime, _, notInterruptible = UnitChannelInfo("target")
        end

        if not name or notInterruptible then
            resetDefault(self)
            return
        end

        local castLeft = endTime / 1000 - GetTime()

        if castBarRecolorInterrupt then
            local state = GetInterruptState(castLeft)
            if state == "cannot" then
                targetSpellBarTexture:SetDesaturated(true)
                self:SetStatusBarColor(unpack(castBarNoInterruptColor))
                self.Spark:SetVertexColor(unpack(castBarNoInterruptColor))
            elseif state == "delayed" then
                targetSpellBarTexture:SetDesaturated(true)
                self:SetStatusBarColor(unpack(castBarDelayedInterruptColor))
                self.Spark:SetVertexColor(unpack(castBarDelayedInterruptColor))
            elseif targetCastbarEdgeHighlight then
                applyEdgeHighlight(self, startTime, endTime)
            else
                resetDefault(self)
            end
        elseif targetCastbarEdgeHighlight then
            applyEdgeHighlight(self, startTime, endTime)
        else
            resetDefault(self)
        end
    end)
    targetCastbarEdgeHooked = true
end

function BBF.CastbarRecolorWidgets()
    local db = BetterBlizzFramesDB
    highlightStartTime = db.castBarInterruptHighlighterStartTime
    highlightEndTime   = db.castBarInterruptHighlighterEndTime
    edgeColor          = db.castBarInterruptHighlighterInterruptRGB
    middleColor        = db.castBarInterruptHighlighterDontInterruptRGB
    colorMiddle        = db.castBarInterruptHighlighterColorDontInterrupt
    castBarNoInterruptColor      = db.castBarNoInterruptColor
    castBarDelayedInterruptColor = db.castBarDelayedInterruptColor
    castBarRecolorInterrupt      = db.castBarRecolorInterrupt
    targetCastbarEdgeHighlight   = db.targetCastbarEdgeHighlight and db.castBarInterruptHighlighter

    if (targetCastbarEdgeHighlight or castBarRecolorInterrupt) then
        HookTargetInterruptHighlight()
    end
end
