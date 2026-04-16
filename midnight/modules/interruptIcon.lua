local interruptSpells = {
    [1766]   = true, -- Kick (Rogue)
    [2139]   = true, -- Counterspell (Mage)
    [6552]   = true, -- Pummel (Warrior)
    [19647]  = true, -- Spell Lock (Warlock)
    [47528]  = true, -- Mind Freeze (Death Knight)
    [57994]  = true, -- Wind Shear (Shaman)
    --[91802]  = true, -- Shambling Rush (Death Knight)
    [96231]  = true, -- Rebuke (Paladin)
    [106839] = true, -- Skull Bash (Feral)
    [115781] = true, -- Optical Blast (Warlock)
    [116705] = true, -- Spear Hand Strike (Monk)
    [132409] = true, -- Spell Lock (Warlock)
    [119910] = true, -- Spell Lock (Warlock Pet)
    [89766]  = true, -- Axe Toss (Warlock Pet)
    [171138] = true, -- Shadow Lock (Warlock)
    [147362] = true, -- Countershot (Hunter)
    [183752] = true, -- Disrupt (Demon Hunter)
    [187707] = true, -- Muzzle (Hunter)
    [212619] = true, -- Call Felhunter (Warlock)
    --[231665] = true, -- Avengers Shield (Paladin)
    [351338] = true, -- Quell (Evoker)
    [97547]  = true, -- Solar Beam
    [78675]  = true, -- Solar Beam
    [15487]  = true, -- Silence
    --[47482]  = true, -- Leap (DK Transform)
}

local function GetInterruptSpell()
    for spellID, _ in pairs(interruptSpells) do
        if IsSpellKnownOrOverridesKnown(spellID) or (UnitExists("pet") and IsSpellKnownOrOverridesKnown(spellID, true)) then
            return spellID
        end
    end
    return nil
end

local playerKick = GetInterruptSpell()

-- Recheck interrupt spells when lock resummons/sacrifices pet
local petSummonSpells = {
    [30146]  = true, -- Summon Felguard (Demonology)
    [691]    = true, -- Summon Felhunter (for Spell Lock)
    [108503] = true, -- Grimoire of Sacrifice
}

local function UpdateInterruptIcon(frame)
    if not frame then return end

    if not playerKick then
        playerKick = GetInterruptSpell()
    end

    local castBar = frame:GetParent()
    local shouldShow = false

    if BetterBlizzFramesDB.castBarInterruptIconEnabled then
        if frame == TargetFrameSpellBar.interruptIconFrame then
            shouldShow = BetterBlizzFramesDB.castBarInterruptIconTarget
        elseif frame == FocusFrameSpellBar.interruptIconFrame then
            shouldShow = BetterBlizzFramesDB.castBarInterruptIconFocus
        end
    end

    if (castBar.unit and not UnitCanAttack("player", castBar.unit)) then
        frame:Hide()
        return
    end

    local notInterruptible

    if castBar.unit then
        if castBar.casting then
            notInterruptible = select(8, UnitCastingInfo(castBar.unit))
        elseif castBar.channeling then
            notInterruptible = select(7, UnitChannelInfo(castBar.unit))
        end
    end

    if notInterruptible ~= nil then
        frame:SetAlphaFromBoolean(notInterruptible, 0, 1)
    else
        frame:SetAlpha(1)
    end

    if playerKick then
        local cooldownInfo = C_Spell.GetSpellCooldownDuration(playerKick)
        if cooldownInfo then
            frame.cooldown:SetCooldownFromDurationObject(cooldownInfo)
            local isOnCooldown = frame.cooldown:IsShown()

            if BetterBlizzFramesDB.castBarInterruptIconShowActiveOnly and isOnCooldown then
                frame:Hide()
                return
            end

            if shouldShow then
                frame:Show()
                frame.icon:SetTexture(C_Spell.GetSpellTexture(playerKick))

                if frame.border then
                    if isOnCooldown then
                        frame.border:SetVertexColor(1, 0, 0)
                    else
                        frame.border:SetVertexColor(0, 1, 0)
                    end
                end
            else
                frame:Hide()
            end
        end
    else
        frame:Hide()
    end
end

local function UpdateIconsAndColor()
    if UnitExists("target") then
        BBF.ColorCastbar(TargetFrameSpellBar)
        if TargetFrameSpellBar.interruptIconFrame then
            UpdateInterruptIcon(TargetFrameSpellBar.interruptIconFrame)
        end
    end
    if UnitExists("focus") then
        BBF.ColorCastbar(FocusFrameSpellBar)
        if FocusFrameSpellBar.interruptIconFrame then
            UpdateInterruptIcon(FocusFrameSpellBar.interruptIconFrame)
        end
    end
end

BBF.interruptTrackingIcon = CreateFrame("Frame")
BBF.interruptTrackingIcon.cooldown = CreateFrame("Cooldown", nil, BBF.interruptTrackingIcon, "CooldownFrameTemplate")
BBF.interruptTrackingIcon.cooldown:HookScript("OnCooldownDone", function()
    BBF.interruptReady = true
    UpdateIconsAndColor()
end)

local function UpdateInterruptTracking()
    if not playerKick then
        playerKick = GetInterruptSpell()
    end
    if playerKick then
        local cooldownInfo = C_Spell.GetSpellCooldownDuration(playerKick)
        if cooldownInfo then
            BBF.interruptTrackingIcon.cooldown:SetCooldownFromDurationObject(cooldownInfo)
            BBF.interruptReady = not BBF.interruptTrackingIcon.cooldown:IsShown()
        end
    else
        BBF.interruptReady = nil
    end
end

local function OnPetEvent(self, event, unit, _, spellID)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        if not petSummonSpells[spellID] then return end
    end
    C_Timer.After(0.1, function()
        playerKick = GetInterruptSpell()
        UpdateInterruptTracking()
        UpdateIconsAndColor()
    end)
end

local cooldownFrame = CreateFrame("Frame")
cooldownFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
cooldownFrame:RegisterEvent("SPELL_UPDATE_USABLE")
cooldownFrame:SetScript("OnEvent", function(self, event, spellID)
    if event == "SPELL_UPDATE_COOLDOWN" then
        if spellID ~= playerKick then return end
        UpdateInterruptTracking()
        UpdateIconsAndColor()
    else
        local oldInterruptStatus = BBF.interruptReady
        UpdateInterruptTracking()
        if oldInterruptStatus ~= BBF.interruptReady then
            UpdateIconsAndColor()
        end
    end
end)

local interruptSpellUpdate = CreateFrame("Frame")
if select(2, UnitClass("player")) == "WARLOCK" then
    interruptSpellUpdate:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
end
interruptSpellUpdate:RegisterEvent("TRAIT_CONFIG_UPDATED")
interruptSpellUpdate:RegisterEvent("PLAYER_TALENT_UPDATE")
interruptSpellUpdate:SetScript("OnEvent", OnPetEvent)

local function IsAnyFeatureEnabled()
    return BetterBlizzFramesDB.castBarInterruptIconEnabled and
           (BetterBlizzFramesDB.castBarInterruptIconTarget or
            BetterBlizzFramesDB.castBarInterruptIconFocus)
end

local function CreateInterruptIconFrame(parentFrame)
    local button = CreateFrame("Frame", nil, parentFrame)
    button:SetSize(30, 30)
    button:SetPoint("CENTER", parentFrame, BetterBlizzFramesDB.castBarInterruptIconAnchor,
                    BetterBlizzFramesDB.castBarInterruptIconXPos + 45,
                    BetterBlizzFramesDB.castBarInterruptIconYPos - 7)
    button:SetScale(BetterBlizzFramesDB.castBarInterruptIconScale)

    button.icon = button:CreateTexture(nil, "BACKGROUND")
    button.icon:SetAllPoints()
    button.icon:SetTexCoord(0.04, 0.96, 0.04, 0.96)

    if BetterBlizzFramesDB.interruptIconBorder then
        button.border = button:CreateTexture(nil, "OVERLAY")
        button.border:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-ActionBar-IconFrame-AddRow-Light")
        button.border:SetSize(48, 48)
        button.border:SetPoint("CENTER", button, "CENTER", 2, -2)
        button.border:SetDrawLayer("OVERLAY", 7)
        button.border:SetVertexColor(0, 1, 0)
    end

    button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    button.cooldown:SetAllPoints()
    button.cooldown:HookScript("OnCooldownDone", function()
        if button.border then
            button.border:SetVertexColor(0, 1, 0)
        end
    end)

    return button
end

local updateEvents = {
    ["UNIT_SPELLCAST_START"] = true,
    ["UNIT_SPELLCAST_CHANNEL_START"] = true,
    ["UNIT_SPELLCAST_DELAYED"] = true,
    ["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
    ["UNIT_SPELLCAST_EMPOWER_START"] = true,
    ["UNIT_SPELLCAST_EMPOWER_UPDATE"] = true,
    ["UNIT_SPELLCAST_INTERRUPTED"] = true,
    ["UNIT_SPELLCAST_INTERRUPTIBLE"] = true,
    ["UNIT_SPELLCAST_NOT_INTERRUPTIBLE"] = true,
}

local function OnCastBarEvent(castBar, event)
    if not updateEvents[event] then return end
    if castBar.interruptIconFrame then
        UpdateInterruptIcon(castBar.interruptIconFrame)
    end
end

function BBF.ToggleCastbarInterruptIcon()
    if TargetFrameSpellBar.interruptIconFrame then
        TargetFrameSpellBar.interruptIconFrame:Hide()
        TargetFrameSpellBar.interruptIconFrame = nil
    end
    if FocusFrameSpellBar.interruptIconFrame then
        FocusFrameSpellBar.interruptIconFrame:Hide()
        FocusFrameSpellBar.interruptIconFrame = nil
    end

    if not IsAnyFeatureEnabled() then
        return
    end

    TargetFrameSpellBar.interruptIconFrame = CreateInterruptIconFrame(TargetFrameSpellBar)
    UpdateInterruptIcon(TargetFrameSpellBar.interruptIconFrame)

    if not TargetFrameSpellBar.interruptIconHooked then
        TargetFrameSpellBar:HookScript("OnEvent", OnCastBarEvent)
        TargetFrameSpellBar.interruptIconHooked = true
    end

    FocusFrameSpellBar.interruptIconFrame = CreateInterruptIconFrame(FocusFrameSpellBar)
    UpdateInterruptIcon(FocusFrameSpellBar.interruptIconFrame)

    if not FocusFrameSpellBar.interruptIconHooked then
        FocusFrameSpellBar:HookScript("OnEvent", OnCastBarEvent)
        FocusFrameSpellBar.interruptIconHooked = true
    end
end

local function UpdateSettings()
    if not IsAnyFeatureEnabled() then
        if TargetFrameSpellBar.interruptIconFrame then
            TargetFrameSpellBar.interruptIconFrame:Hide()
        end
        if FocusFrameSpellBar.interruptIconFrame then
            FocusFrameSpellBar.interruptIconFrame:Hide()
        end
        return
    end

    if TargetFrameSpellBar.interruptIconFrame then
        local frame = TargetFrameSpellBar.interruptIconFrame
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", TargetFrameSpellBar, BetterBlizzFramesDB.castBarInterruptIconAnchor,
                       BetterBlizzFramesDB.castBarInterruptIconXPos + 45,
                       BetterBlizzFramesDB.castBarInterruptIconYPos - 7)
        frame:SetScale(BetterBlizzFramesDB.castBarInterruptIconScale)
        if BetterBlizzFramesDB.castBarInterruptIconEnabled and BetterBlizzFramesDB.castBarInterruptIconTarget then
            frame:Show()
        else
            frame:Hide()
        end
    end

    if FocusFrameSpellBar.interruptIconFrame then
        local frame = FocusFrameSpellBar.interruptIconFrame
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", FocusFrameSpellBar, BetterBlizzFramesDB.castBarInterruptIconAnchor,
                       BetterBlizzFramesDB.castBarInterruptIconXPos + 45,
                       BetterBlizzFramesDB.castBarInterruptIconYPos - 7)
        frame:SetScale(BetterBlizzFramesDB.castBarInterruptIconScale)

        if BetterBlizzFramesDB.castBarInterruptIconEnabled and BetterBlizzFramesDB.castBarInterruptIconFocus then
            frame:Show()
        else
            frame:Hide()
        end
    end
end

function BBF.UpdateInterruptIconSettings()
    UpdateSettings()
    if BetterBlizzFramesDB.castBarInterruptIconEnabled then
        if BetterBlizzFramesDB.castBarInterruptIconTarget and TargetFrameSpellBar.interruptIconFrame then
            UpdateInterruptIcon(TargetFrameSpellBar.interruptIconFrame)
        end
        if BetterBlizzFramesDB.castBarInterruptIconFocus and FocusFrameSpellBar.interruptIconFrame then
            UpdateInterruptIcon(FocusFrameSpellBar.interruptIconFrame)
        end
    end
end

local LSM = LibStub("LibSharedMedia-3.0")

local function CreateKickPopupFrame()
    local xPos = BetterBlizzFramesDB.kickPopupXPos or 0
    local yPos = (BetterBlizzFramesDB.kickPopupYPos or 0) - 225
    local scale = BetterBlizzFramesDB.kickPopupScale or 1.2

    local anchor = CreateFrame("Frame", nil, UIParent)
    anchor:SetSize(1, 1)
    anchor:SetPoint("TOP", UIParent, "TOP", xPos, yPos)
    anchor:SetFrameStrata("HIGH")

    local popup = CreateFrame("Frame", nil, anchor)
    popup:SetSize(300, 32)
    popup:SetPoint("CENTER", anchor, "CENTER", 0, 0)
    popup:SetScale(scale)
    popup:Hide()

    popup.anchor = anchor

    popup.label = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    popup.label:SetPoint("CENTER", popup, "CENTER", 16, 0)

    popup.icon = popup:CreateTexture(nil, "ARTWORK")
    local iconScale = BetterBlizzFramesDB.kickPopupIconScale or 1
    popup.icon:SetSize(26 * iconScale, 26 * iconScale)
    popup.icon:SetPoint("RIGHT", popup.label, "LEFT", -4, 0)

    local fontName = BetterBlizzFramesDB.kickPopupFont
    local outlineVal = BetterBlizzFramesDB.kickPopupFontOutline
    local outlineFlag = (outlineVal == "THICKOUTLINE" and "THICKOUTLINE") or (outlineVal and "OUTLINE") or ""
    if fontName then
        local fontPath = LSM:Fetch(LSM.MediaType.FONT, fontName)
        if fontPath then
            popup.label:SetFont(fontPath, 18, outlineFlag)
        end
    else
        local existingFont, existingSize = popup.label:GetFont()
        if existingFont then
            popup.label:SetFont(existingFont, existingSize, outlineFlag)
        end
    end

    if BetterBlizzFramesDB.kickPopupFontShadow then
        popup.label:SetShadowOffset(1, -1)
        popup.label:SetShadowColor(0, 0, 0, 1)
    else
        popup.label:SetShadowOffset(0, 0)
        popup.label:SetShadowColor(0, 0, 0, 0)
    end

    local color = BetterBlizzFramesDB.kickPopupTextColor or {0.992, 0.992, 0.569}
    popup.label:SetTextColor(color[1], color[2], color[3])

    popup.fadeOut = popup:CreateAnimationGroup()
    local aOut = popup.fadeOut:CreateAnimation("Alpha")
    aOut:SetFromAlpha(1)
    aOut:SetToAlpha(0)
    aOut:SetDuration(0.5)
    popup.fadeOut:SetToFinalAlpha(true)
    popup.fadeOut:SetScript("OnFinished", function() popup:Hide() end)

    return popup
end

local function PlayKickSound()
    if not BetterBlizzFramesDB.kickPopupPlaySound then return end
    local channel = BetterBlizzFramesDB.kickPopupSoundChannel or "Master"
    local fileID = BetterBlizzFramesDB.kickPopupSoundFileID
    if fileID and fileID ~= 0 then
        PlaySound(fileID, channel)
    else
        local soundName = BetterBlizzFramesDB.kickPopupSoundName
        if soundName then
            local path = LSM:Fetch(LSM.MediaType.SOUND, soundName)
            if path then PlaySoundFile(path, channel) end
        end
    end
end

local function ShowKickPopup(interruptedSpellID)
    local popup = BBF.kickPopupFrame
    if not popup then return end

    local spellName = C_Spell.GetSpellName(interruptedSpellID)
    local spellIcon = C_Spell.GetSpellTexture(interruptedSpellID)

    if spellIcon then
        popup.icon:SetTexture(spellIcon)
        popup.icon:Show()
    else
        popup.icon:Hide()
    end

    if BetterBlizzFramesDB.kickPopupSauce then
        popup.label:SetText(spellName and ("good kick fam [" .. spellName .. "]") or "good kick fam")
    else
        popup.label:SetText(spellName and ("Interrupted " .. spellName) or "Interrupted")
    end

    popup.fadeOut:Stop()
    popup:SetAlpha(1)
    popup:Show()
    PlayKickSound()
    C_Timer.After(2, function()
        if popup:IsShown() then popup.fadeOut:Play() end
    end)
end

local kickPlayerKicked = false
local kickLastShownTime = 0

function BBF.ToggleKickPopup()
    if BBF.kickPopupFrame then
        BBF.kickPopupFrame.anchor:Hide()
        BBF.kickPopupFrame:Hide()
        BBF.kickPopupFrame = nil
    end
    if BBF.kickPopupEventFrame then
        BBF.kickPopupEventFrame:UnregisterAllEvents()
        BBF.kickPopupEventFrame = nil
    end

    if not BetterBlizzFramesDB.kickPopupEnabled then return end

    BBF.kickPopupFrame = CreateKickPopupFrame()

    BBF.kickPopupEventFrame = CreateFrame("Frame")
    BBF.kickPopupEventFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    BBF.kickPopupEventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")

    BBF.kickPopupEventFrame:SetScript("OnEvent", function(self, event, unit, castGUID, spellID, interruptedByOrCastBarID)
        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            if interruptSpells[spellID] then
                kickPlayerKicked = true
                self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
                C_Timer.After(0.5, function()
                    kickPlayerKicked = false
                end)
            end
            return
        end

        local now = GetTime()

        local isRealInterrupt = issecretvalue(interruptedByOrCastBarID) or (interruptedByOrCastBarID ~= nil)
        if not isRealInterrupt then
            if event == "UNIT_SPELLCAST_CHANNEL_STOP" then
                if kickPlayerKicked and unit ~= "player" then
                    kickLastShownTime = now
                    ShowKickPopup(spellID)
                end
                kickPlayerKicked = false
                self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
            end
            return
        end

        if now - kickLastShownTime < 0.01 then return end

        if kickPlayerKicked then
            kickLastShownTime = now
            ShowKickPopup(spellID)
        end
    end)
end

function BBF.UpdateKickPopupSettings()
    local popup = BBF.kickPopupFrame
    if not popup then return end
    local xPos = BetterBlizzFramesDB.kickPopupXPos or 0
    local yPos = (BetterBlizzFramesDB.kickPopupYPos or 0) - 225
    local scale = BetterBlizzFramesDB.kickPopupScale or 1.2
    popup.anchor:ClearAllPoints()
    popup.anchor:SetPoint("TOP", UIParent, "TOP", xPos, yPos)
    popup:SetScale(scale)
    local iconScale = BetterBlizzFramesDB.kickPopupIconScale or 1
    popup.icon:SetSize(26 * iconScale, 26 * iconScale)
end

function BBF.UpdateKickPopupFont()
    local popup = BBF.kickPopupFrame
    if not popup then return end
    local fontName = BetterBlizzFramesDB.kickPopupFont
    local outlineVal = BetterBlizzFramesDB.kickPopupFontOutline
    local outlineFlag = (outlineVal == "THICKOUTLINE" and "THICKOUTLINE") or (outlineVal and "OUTLINE") or ""
    if fontName then
        local fontPath = LSM:Fetch(LSM.MediaType.FONT, fontName)
        if fontPath then
            popup.label:SetFont(fontPath, 18, outlineFlag)
        end
    else
        local existingFont, existingSize = popup.label:GetFont()
        if existingFont then
            popup.label:SetFont(existingFont, existingSize, outlineFlag)
        end
    end

    if BetterBlizzFramesDB.kickPopupFontShadow then
        popup.label:SetShadowOffset(1, -1)
        popup.label:SetShadowColor(0, 0, 0, 1)
    else
        popup.label:SetShadowOffset(0, 0)
        popup.label:SetShadowColor(0, 0, 0, 0)
    end

    local color = BetterBlizzFramesDB.kickPopupTextColor or {0.992, 0.992, 0.569}
    popup.label:SetTextColor(color[1], color[2], color[3])
end

function BBF.TestKickPopup(enable)
    if not enable then
        if BBF.kickPopupFrame then
            BBF.kickPopupFrame.fadeOut:Stop()
            BBF.kickPopupFrame:Hide()
        end
        if not BetterBlizzFramesDB.kickPopupEnabled and BBF.kickPopupFrame then
            BBF.kickPopupFrame.anchor:Hide()
            BBF.kickPopupFrame = nil
        end
        return
    end
    if not BBF.kickPopupFrame then
        BBF.kickPopupFrame = CreateKickPopupFrame()
    end
    local popup = BBF.kickPopupFrame
    local spellName = C_Spell.GetSpellName(118)
    local spellIcon = C_Spell.GetSpellTexture(118)
    if spellIcon then
        popup.icon:SetTexture(spellIcon)
        popup.icon:Show()
    else
        popup.icon:Hide()
    end
    if BetterBlizzFramesDB.kickPopupSauce then
        popup.label:SetText(spellName and ("good kick fam [" .. spellName .. "]") or "good kick fam")
    else
        popup.label:SetText(spellName and ("Interrupted " .. spellName) or "Interrupted")
    end
    popup.fadeOut:Stop()
    popup:SetAlpha(1)
    popup:Show()
end
