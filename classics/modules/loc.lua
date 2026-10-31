local L = BBF.L
local interruptSpells = BBF.LoCInterrupts or {}

local spellLockReducer = {
    [317920] = 0.7,
    [234084] = 0.5,
    [383020] = 0.5,
}

local interruptEvents = {
    ["SPELL_INTERRUPT"] = true,
    ["SPELL_CAST_SUCCESS"] = true,
    ["SPELL_AURA_APPLIED"] = true,
}

local spellList = BBF.LoCSpells or {}

local hardCCSet = {
    ["Stunned"] = true,
    ["Feared"] = true,
    ["Horrified"] = true,
    ["Cycloned"] = true,
    ["Incapacitated"] = true,
    ["Mind Controlled"] = true,
    ["Disoriented"] = true,
    ["Polymorphed"] = true,
    ["Hexed"] = true,
    ["Frozen"] = true,
    ["Blinded"] = true,
    ["Seduced"] = true,
    ["Asleep"] = true,
    ["Shackled"] = true,
    ["Gouged"] = true,
    ["Sapped"] = true,
}

local function isHardCC(type)
    return hardCCSet[type]
end

local ccTypeText

local function CCTypeText(ccType)
    if not ccTypeText then
        ccTypeText = {
            ["Stunned"] = LOSS_OF_CONTROL_DISPLAY_STUN,
            ["Feared"] = LOSS_OF_CONTROL_DISPLAY_FEAR,
            ["Horrified"] = LOSS_OF_CONTROL_DISPLAY_HORROR,
            ["Cycloned"] = LOSS_OF_CONTROL_DISPLAY_CYCLONE,
            ["Incapacitated"] = LOSS_OF_CONTROL_DISPLAY_INCAPACITATE,
            ["Mind Controlled"] = L["Label_LoC_Mind_Controlled"],
            ["Disoriented"] = LOSS_OF_CONTROL_DISPLAY_DISORIENT,
            ["Polymorphed"] = LOSS_OF_CONTROL_DISPLAY_POLYMORPH,
            ["Hexed"] = L["Label_LoC_Hexed"],
            ["Frozen"] = LOSS_OF_CONTROL_DISPLAY_FREEZE,
            ["Blinded"] = L["Label_LoC_Blinded"],
            ["Seduced"] = L["Label_LoC_Seduced"],
            ["Asleep"] = LOSS_OF_CONTROL_DISPLAY_SLEEP,
            ["Shackled"] = LOSS_OF_CONTROL_DISPLAY_SHACKLE_UNDEAD,
            ["Gouged"] = L["Label_LoC_Gouged"],
            ["Sapped"] = LOSS_OF_CONTROL_DISPLAY_SAP,
            ["Silenced"] = LOSS_OF_CONTROL_DISPLAY_SILENCE,
            ["Disarmed"] = LOSS_OF_CONTROL_DISPLAY_DISARM,
            ["Rooted"] = LOSS_OF_CONTROL_DISPLAY_ROOT,
        }
    end
    return ccTypeText[ccType] or ccType
end

local function SecondsText(timeLeft)
    return string.format("%.1f %s", timeLeft, LOSS_OF_CONTROL_SECONDS or "seconds")
end

function BBF.SetupLoCFrame()
    if not BetterBlizzFramesDB.enableLoCFrame or BBFLossOfControlFrame or BBF.BBCCHandlesLoC() or BBF.LoC.Supported() then return end
    local f = CreateFrame("Frame")

    local parentFrame = CreateFrame("Frame", "BBFLossOfControlParentFrame", UIParent)
    parentFrame:SetScale(BetterBlizzFramesDB.lossOfControlScale or 1)

    local iconOnlyMode = BetterBlizzFramesDB.lossOfControlIconOnly

    local frame = CreateFrame("Frame", "BBFLossOfControlFrame", parentFrame, "BackdropTemplate")
    frame:SetSize(256, 58)
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetFrameStrata("MEDIUM")
    frame:SetToplevel(true)
    frame:Hide()

    frame.fadeInScale = frame:CreateAnimationGroup()

    frame.fadeIn = frame.fadeInScale:CreateAnimation("Alpha")
    frame.fadeIn:SetFromAlpha(0)
    frame.fadeIn:SetToAlpha(1)
    frame.fadeIn:SetDuration(0.10)
    frame.fadeIn:SetOrder(1)
    frame.fadeIn:SetSmoothing("OUT")

    frame.scaleOvershoot = frame.fadeInScale:CreateAnimation("Scale")
    frame.scaleOvershoot:SetScaleFrom(0.85, 0.85)
    frame.scaleOvershoot:SetScaleTo(1.1, 1.1)
    frame.scaleOvershoot:SetDuration(0.08)
    frame.scaleOvershoot:SetOrder(1)
    frame.scaleOvershoot:SetSmoothing("OUT")

    frame.scaleSettle = frame.fadeInScale:CreateAnimation("Scale")
    frame.scaleSettle:SetScaleFrom(1.1, 1.1)
    frame.scaleSettle:SetScaleTo(1, 1)
    frame.scaleSettle:SetDuration(0.07)
    frame.scaleSettle:SetOrder(2)
    frame.scaleSettle:SetSmoothing("IN")

    frame.fadeInScale:SetToFinalAlpha(true)

    frame.fadeOutShrink = frame:CreateAnimationGroup()

    frame.fadeOut = frame.fadeOutShrink:CreateAnimation("Alpha")
    frame.fadeOut:SetFromAlpha(1)
    frame.fadeOut:SetToAlpha(0)
    frame.fadeOut:SetDuration(0.07)
    frame.fadeOut:SetOrder(1)
    frame.fadeOut:SetSmoothing("IN")

    frame.scaleDown = frame.fadeOutShrink:CreateAnimation("Scale")
    frame.scaleDown:SetScaleFrom(1, 1)
    frame.scaleDown:SetScaleTo(0.85, 0.85)
    frame.scaleDown:SetDuration(0.07)
    frame.scaleDown:SetOrder(1)
    frame.scaleDown:SetSmoothing("IN")

    frame.fadeOutShrink:SetToFinalAlpha(false)

    frame.fadeOutShrink:SetScript("OnFinished", function()
        frame:Hide()
        frame:SetAlpha(1)
        frame:SetScale(1)
        frame.duration = nil
        frame.expiration = nil
        frame.lockedBy = nil
        frame.returnEarly = nil
    end)

    frame.RedLineTop = frame:CreateTexture(nil, "BACKGROUND")
    frame.RedLineTop:SetTexture("Interface\\Cooldown\\Loc-RedLine")
    frame.RedLineTop:SetSize(iconOnlyMode and 70 or 236, 27)
    frame.RedLineTop:SetPoint("BOTTOM", frame, "TOP")

    frame.RedLineBottom = frame:CreateTexture(nil, "BACKGROUND")
    frame.RedLineBottom:SetTexture("Interface\\Cooldown\\Loc-RedLine")
    frame.RedLineBottom:SetSize(iconOnlyMode and 70 or 236, 27)
    frame.RedLineBottom:SetPoint("TOP", frame, "BOTTOM")
    frame.RedLineBottom:SetTexCoord(0, 1, 1, 0)

    frame.blackBg = frame:CreateTexture(nil, "BACKGROUND")
    frame.blackBg:SetTexture("Interface\\Cooldown\\loc-shadowbg")
    frame.blackBg:SetPoint("TOPLEFT", frame.RedLineTop, "BOTTOMLEFT")
    frame.blackBg:SetPoint("BOTTOMRIGHT", frame.RedLineBottom, "TOPRIGHT")

    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:SetSize(48, 48)
    frame.Icon:SetPoint("CENTER", frame, "CENTER", iconOnlyMode and 0 or -70, 0)

    frame.Icon.Cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.Icon.Cooldown:SetMinimumCountdownDuration(0)
    frame.Icon.Cooldown:SetAllPoints(frame.Icon)

    frame.SecondaryIcon = CreateFrame("Frame", nil, frame)
    frame.SecondaryIcon:SetSize(48, 48)
    frame.SecondaryIcon:SetPoint("RIGHT", frame.Icon, "LEFT", -4, 0)

    frame.SecondaryIcon.Cooldown = CreateFrame("Cooldown", nil, frame.SecondaryIcon, "CooldownFrameTemplate")
    frame.SecondaryIcon.Cooldown:SetMinimumCountdownDuration(0)
    frame.SecondaryIcon.Cooldown:SetAllPoints(frame.SecondaryIcon)

    local cooldownSwipe = frame.SecondaryIcon:GetRegions()
    if cooldownSwipe then
        cooldownSwipe:SetAllPoints(frame.SecondaryIcon)
    end

    frame.SecondaryIcon.icon = frame.SecondaryIcon:CreateTexture(nil, "ARTWORK")
    frame.SecondaryIcon.icon:SetAllPoints()
    frame.SecondaryIcon.icon:SetTexture(nil)

    frame.Icon.SchoolText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.Icon.SchoolText:SetPoint("BOTTOM", frame.Icon, "BOTTOM", 0, 1)
    frame.Icon.SchoolText:SetJustifyH("CENTER")
    frame.Icon.SchoolText:SetTextColor(1, 1, 1)
    frame.Icon.SchoolText:SetFont("Interface/Addons/BetterBlizzFrames/media/fonts/Prototype.ttf", 11, "OUTLINE")

    frame.SecondaryIcon.SchoolText = frame.SecondaryIcon:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.SecondaryIcon.SchoolText:SetPoint("BOTTOM", frame.SecondaryIcon, "BOTTOM", 0, 1)
    frame.SecondaryIcon.SchoolText:SetJustifyH("CENTER")
    frame.SecondaryIcon.SchoolText:SetTextColor(1, 1, 1)
    frame.SecondaryIcon.SchoolText:SetFont("Interface/Addons/BetterBlizzFrames/media/fonts/Prototype.ttf", 11, "OUTLINE")
    frame.SecondaryIcon.SchoolText:SetDrawLayer("OVERLAY", 7)

    frame.AbilityName = frame:CreateFontString(nil, "ARTWORK", "MovieSubtitleFont")
    frame.AbilityName:SetPoint("TOPLEFT", frame.Icon, "TOPRIGHT", 5, -4)
    frame.AbilityName:SetSize(0, 20)

    frame.TimeLeft = CreateFrame("Frame", nil, frame)
    frame.TimeLeft:SetSize(200, 20)
    frame.TimeLeft:SetPoint("TOPLEFT", frame.AbilityName, "BOTTOMLEFT")

    frame.TimeLeft.NumberText = frame.TimeLeft:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    frame.TimeLeft.NumberText:SetPoint("LEFT", frame.TimeLeft, "LEFT", 0, -3)
    frame.TimeLeft.NumberText:SetShadowOffset(2, -2)
    frame.TimeLeft.NumberText:SetTextColor(1, 1, 1)

    BBF.LoC.ApplyOwnLayout(frame)

    local schoolNames = {
        [1]   = {"Physical",     0.85, 0.65, 0.45},
        [2]   = {"Holy",         1.00, 0.95, 0.60},
        [4]   = {"Fire",         1.00, 0.35, 0.10},
        [8]   = {"Nature",       0.30, 0.85, 0.30},
        [16]  = {"Frost",        0.45, 0.70, 1.00},
        [32]  = {"Shadow",       0.50, 0.25, 0.75},
        [64]  = {"Arcane",       0.80, 0.60, 1.00},

        [3]   = {"Holystrike",   1.00, 0.85, 0.50},
        [5]   = {"Flamestrike",  1.00, 0.45, 0.10},
        [6]   = {"Holyfire",     1.00, 0.65, 0.30},
        [9]   = {"Stormstrike",  0.40, 0.80, 1.00},
        [10]  = {"Holystorm",    0.90, 0.90, 0.60},
        [12]  = {"Firestorm",    1.00, 0.55, 0.10},
        [17]  = {"Froststrike",  0.50, 0.75, 1.00},
        [18]  = {"Holyfrost",    0.80, 0.90, 1.00},
        [20]  = {"Frostfire",    0.80, 0.45, 1.00},
        [24]  = {"Froststorm",   0.50, 0.80, 1.00},
        [28]  = {"Spellfrost",   0.60, 0.70, 1.00},
        [33]  = {"Shadowstrike", 0.65, 0.25, 0.60},
        [34]  = {"Twilight",     0.70, 0.40, 0.85},
        [36]  = {"Shadowflame",  0.80, 0.30, 0.60},
        [40]  = {"Shadowstorm",  0.50, 0.30, 0.85},
        [48]  = {"Shadowfrost",  0.55, 0.40, 0.85},
        [65]  = {"Spellstrike",  0.90, 0.60, 1.00},
        [66]  = {"Divine",       1.00, 0.85, 0.55},
        [96]  = {"Spellshadow",  0.75, 0.45, 0.85},
        [124] = {"Elemental",    0.95, 0.60, 0.20},
        [126] = {"Chromatic",    0.95, 0.95, 1.00},
        [127] = {"Magic",        0.90, 0.90, 1.00},

        [200] = {"Astral",       0.50, 0.85, 1.00},
        [201] = {"Chaos",        1.00, 0.15, 0.15},
        [202] = {"Chimeric",     0.95, 0.55, 0.85},
        [203] = {"Cosmic",       0.80, 0.80, 1.00},
        [204] = {"Radiant",      1.00, 0.70, 0.40},
        [205] = {"Volcanic",     1.00, 0.40, 0.20},
        [206] = {"Plague",       0.55, 0.80, 0.40},
    }

    local function GetSchoolInfo(school)
        local info = schoolNames[school]
        if not info then
            return L["Label_Interrupted"], 1, 1, 1
        end
        local name = school <= 127 and C_Spell.GetSchoolString(school) or info[1]
        return name, info[2], info[3], info[4]
    end

    local function checkAuras()
        local mainHardCC, secondHardCC, silence, disarm, root
        local interrupt = frame.interruptData
        local now = GetTime()

        if BetterBlizzFramesDB.lossOfControlInterruptsOnly then
            local main = interrupt
            if main and main.expiration <= now then
                frame.interruptData = nil
                main = nil
            end

            frame.mainCC = main
            frame.secondaryCC = nil

            if main then
                if frame.fadeOutShrink:IsPlaying() then
                    frame.fadeOutShrink:Stop()
                end

                frame.Icon:SetTexture(main.icon)
                frame.Icon.Cooldown:SetCooldown(main.expiration - main.duration, main.duration)

                local name, r, g, b = GetSchoolInfo(main.school)
                frame.AbilityName:SetText(L["Label_Interrupted"])
                frame.AbilityName:SetTextColor(r, g, b)

                frame.duration = main.duration
                frame.expiration = main.expiration
                frame.lockedBy = main.spellID

                if not frame:IsShown() then
                    frame:SetAlpha(0)
                    frame:SetScale(0.85)
                    frame:Show()
                    frame.fadeInScale:Stop()
                    frame.fadeInScale:Play()
                end

                frame.Icon.SchoolText:SetText(name)
                frame.Icon.SchoolText:SetTextColor(r, g, b)
            elseif not frame.fadeOutShrink:IsPlaying() then
                frame.fadeOutShrink:Play()
                frame.Icon.SchoolText:SetText("")
            end

            frame.SecondaryIcon:Hide()
            frame.SecondaryIcon.SchoolText:SetText("")
            return
        end

        local function getAuraData()
            for i = 1, 40 do
                local aura = C_UnitAuras.GetAuraDataByIndex("player", i, "HARMFUL")
                if not aura then break end

                local spellID = aura.spellId
                local ccType = spellList[spellID]
                local remaining = aura.expirationTime and (aura.expirationTime - now) or 0
                local duration = aura.duration or 0

                if ccType == "Silenced" and duration == 0 then
                    frame.silenceFallbacks = frame.silenceFallbacks or {}

                    local fallback = frame.silenceFallbacks[spellID]
                    if not fallback or fallback.expirationTime <= now then
                        local solarBeamDuration = 8.1
                        fallback = {
                            startTime = now,
                            duration = solarBeamDuration,
                            expirationTime = now + solarBeamDuration,
                        }
                        frame.silenceFallbacks[spellID] = fallback
                    end

                    duration = fallback.duration
                    aura.expirationTime = fallback.expirationTime
                    remaining = fallback.expirationTime - now
                end

                if remaining > 0 then
                    local auraData = {
                        icon = aura.icon,
                        type = ccType,
                        duration = duration,
                        expiration = aura.expirationTime,
                        remaining = remaining,
                        spellID = spellID
                    }

                    if isHardCC(ccType) then
                        if ccType == "Stunned" or ccType == "Horrified" then
                            local isSameType = (mainHardCC and mainHardCC.type == ccType)
                            if not mainHardCC or not isSameType or remaining > mainHardCC.remaining then
                                if mainHardCC and not (mainHardCC.type == "Stunned" or mainHardCC.type == "Horrified") then
                                    secondHardCC = mainHardCC
                                end
                                mainHardCC = auraData
                            end
                        elseif not mainHardCC then
                            mainHardCC = auraData
                        elseif auraData.spellID ~= mainHardCC.spellID then
                            if not secondHardCC or auraData.remaining > secondHardCC.remaining then
                                secondHardCC = auraData
                            end
                        end
                    elseif ccType == "Silenced" or ccType == "Silenced+" then
                        if not silence or remaining > silence.remaining then
                            silence = auraData
                        end
                    elseif ccType == "Disarmed" then
                        if not disarm or remaining > disarm.remaining then
                            disarm = auraData
                        end
                    elseif ccType == "Rooted" then
                        if not root or remaining > root.remaining then
                            root = auraData
                        end
                    end
                end
            end
        end

        getAuraData()

        if interrupt and interrupt.expiration <= now then
            frame.interruptData = nil
            interrupt = nil
        end

        local main, secondary
        local fullCC = mainHardCC

        if fullCC then
            main = fullCC
            if interrupt and silence then
                secondary = (silence.remaining > interrupt.remaining) and silence or interrupt
            elseif interrupt then
                secondary = interrupt
            elseif secondHardCC then
                secondary = secondHardCC
            else
                secondary = interrupt or silence or disarm or root
            end
        elseif interrupt and silence then
            if silence.remaining > interrupt.remaining then
                main = silence
                secondary = interrupt
            else
                main = interrupt
                secondary = silence
            end
        elseif interrupt then
            main = interrupt
            secondary = silence or disarm or root
        elseif silence then
            main = silence
            secondary = disarm or root
        elseif disarm then
            main = disarm
            secondary = root
        elseif root then
            main = root
            secondary = nil
        end

        if secondary and secondary ~= interrupt and BetterBlizzFramesDB.lossOfControlSecondIconInterruptsOnly then
            secondary = nil
        end

        frame.mainCC = main
        frame.secondaryCC = secondary

        if main then
            if frame.fadeOutShrink:IsPlaying() then
                frame.fadeOutShrink:Stop()
            end

            frame.Icon:SetTexture(main.icon)
            if frame.Icon.Cooldown then
                frame.Icon.Cooldown:SetCooldown(main.expiration - main.duration, main.duration)
            end

            local r, g, b = 1, 0.819, 0
            if main.type == "Silenced" and interrupt then
                frame.AbilityName:SetText(L["Label_Silenced"])
                _, r, g, b = GetSchoolInfo(interrupt.school)
            elseif main == interrupt then
                frame.AbilityName:SetText(L["Label_Interrupted"])
                _, r, g, b = GetSchoolInfo(interrupt.school)
            else
                frame.AbilityName:SetText(main.type and CCTypeText(main.type) or L["Unknown"])
            end
            frame.AbilityName:SetTextColor(r, g, b)

            frame.duration = main.duration
            frame.expiration = main.expiration
            frame.lockedBy = main.spellID

            if not frame:IsShown() then
                frame:SetAlpha(0)
                frame:SetScale(0.85)
                frame:Show()
                frame.fadeInScale:Stop()
                frame.fadeInScale:Play()
            end

            if main == interrupt or (main.type == "Silenced" and interrupt) then
                local name, r, g, b = GetSchoolInfo(interrupt.school)
                frame.Icon.SchoolText:SetText(name)
                frame.Icon.SchoolText:SetTextColor(r, g, b)
            else
                frame.Icon.SchoolText:SetText("")
            end
        else
            if not (interrupt and (interrupt.expiration - now) > 0.2) and not frame.fadeOutShrink:IsPlaying() then
                frame.fadeOutShrink:Stop()
                frame.fadeOutShrink:Play()
            end
            frame.Icon.SchoolText:SetText("")
        end

        if secondary then
            frame.SecondaryIcon.icon:SetTexture(secondary.icon)
            frame.SecondaryIcon.Cooldown:SetCooldown(secondary.expiration - secondary.duration, secondary.duration)
            frame.SecondaryIcon:Show()

            if interrupt and (secondary == interrupt or secondary == silence) then
                local name, r, g, b = GetSchoolInfo(interrupt.school)
                frame.SecondaryIcon.SchoolText:SetText(name)
                frame.SecondaryIcon.SchoolText:SetTextColor(r, g, b)
            else
                frame.SecondaryIcon.SchoolText:SetText("")
            end
        else
            frame.SecondaryIcon:Hide()
            frame.SecondaryIcon.SchoolText:SetText("")
        end

        if frame.silenceFallbacks then
            for spellID, fallback in pairs(frame.silenceFallbacks) do
                if fallback.expirationTime <= now then
                    frame.silenceFallbacks[spellID] = nil
                end
            end
        end
    end

    f:SetScript("OnEvent", function()
        if frame.returnEarly then return end
        checkAuras()
    end)

    function BBF.UpdateLoCFrame()
        BBF.LoC.ApplyOwnLayout(frame)
        if BetterBlizzFramesDB.lossOfControlInterruptsOnly then
            f:UnregisterEvent("UNIT_AURA")
        else
            f:RegisterUnitEvent("UNIT_AURA", "player")
        end
        BBF.LoC.RefreshOwnTest()
    end
    BBF.UpdateLoCFrame()

    frame:SetScript("OnUpdate", function(self)
        local now = GetTime()
        if self.expiration and not self.returnEarly then
            local timeLeft = self.expiration - now

            if timeLeft <= 0 then
                checkAuras()
            else
                self.TimeLeft.NumberText:SetText(SecondsText(timeLeft))

                if self.interruptData and self.secondaryCC == self.interruptData and self.interruptData.expiration <= now then
                    self.interruptData = nil
                    checkAuras()
                end
            end
        end
    end)

    frame.interruptWatcher = CreateFrame("Frame")
    frame.interruptWatcher:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    frame.interruptWatcher:SetScript("OnEvent", function()
        local _, event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID, spellName, _, _, _, school = C_CombatLog.GetCurrentEventInfo()

        if not interruptEvents[event] then return end
        if destGUID ~= UnitGUID("player") then return end

        local duration = interruptSpells[spellID]
        if not duration then return end

        if event ~= "SPELL_INTERRUPT" then
            local _, _, _, _, _, _, notInterruptibleChannel = UnitChannelInfo("player")

            local ccData
            if not schoolNames[school] then
                for i = 1, C_LossOfControl.GetActiveLossOfControlDataCount() do
                    local cc = C_LossOfControl.GetActiveLossOfControlData(i)
                    if cc and cc.locType == "SCHOOL_INTERRUPT" then
                        ccData = cc
                        break
                    end
                end
                if ccData then
                    school = ccData.lockoutSchool
                    duration = ccData.duration
                else
                    return
                end
            end -- avoid showing on casts like first aid etc
            if not ccData and notInterruptibleChannel ~= false then -- nil when not channeling
                return
            end
        end

        for i = 1, 40 do
            local aura = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
            if not aura then break end
            local mult = spellLockReducer[aura.spellId]
            if mult then
                duration = duration * mult
            end
        end

        local schoolName = GetSchoolInfo(school)

        local now = GetTime()
        local expirationTime = now + duration
        local remaining = expirationTime - now

        frame.interruptData = {
            icon = C_Spell.GetSpellTexture(spellID),
            type = schoolName or "Interrupted",
            duration = duration,
            expiration = expirationTime,
            expirationTime = expirationTime,
            remaining = remaining,
            spellID = spellID,
            school = school
        }

        checkAuras()

    end)
end
