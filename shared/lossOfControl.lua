local SCHOOL_FONT = "Interface\\AddOns\\BetterBlizzFrames\\media\\fonts\\Prototype.ttf"

local function DB()
    return BetterBlizzFramesDB
end

local LoC = {}
BBF.LoC = LoC

local DISPLAY_TYPE_NONE = 0
local ICON_ONLY_LINE_WIDTH = 70
local ICON_ONLY_BG_WIDTH = 90
local LINE_WIDTH = 236
local BG_WIDTH = 256
local BG_ALPHA = 0.6
local TIME_LEFT_WIDTH = 200
local TIME_OFFSET = 6
local SECONDARY_SCALE = 0.75
local LOW_COLOR = { 1, 0.1, 0.1, 1 }
local WHITE = { 1, 1, 1, 1 }

local SECONDARY_ANCHORS = {
    LEFT = { "RIGHT", "LEFT", -4, 0 },
    RIGHT = { "LEFT", "RIGHT", 4, 0 },
    UP = { "BOTTOM", "TOP", 0, 4 },
    DOWN = { "TOP", "BOTTOM", 0, -4 },
}

local INTERRUPT_PRIORITY = 2

local SCHOOLS = {
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
}

local hooked, enabled, changed, eventFrame, interruptFrame, testFrame, testTimer

local function SettingsOpen()
    return BBF.LoCSettingsOpen and BBF.LoCSettingsOpen()
end

local function FontPath(key)
    local name = DB()[key]
    if not name or name == "" then return end
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    return LSM and LSM:Fetch("font", name, true)
end

local function ApplyFont(text, path)
    if not text then return end
    if not text.bbLoCFont then
        if not path then return end
        text.bbLoCFont = { text:GetFont() }
    end
    local font, size, flags = unpack(text.bbLoCFont)
    if font and size then
        text:SetFont(path or font, size, flags)
    end
end

local function ApplyFonts(frame, restore)
    local textFont = not restore and FontPath("lossOfControlFont")
    local secondary = frame.bbLoCSecondary or frame.SecondaryIcon
    ApplyFont(frame.AbilityName, textFont)
    ApplyFont(frame.bbLoCSchoolText or frame.Icon.SchoolText, textFont)
    ApplyFont(secondary and secondary.SchoolText, textFont)
    ApplyFont(frame.TimeLeft.NumberText, textFont)
    ApplyFont(frame.TimeLeft.SecondsText, textFont)
end

local function ActiveIndex()
    local consts = Constants and Constants.LossOfControlConsts
    return consts and consts.LOSS_OF_CONTROL_ACTIVE_INDEX or LOSS_OF_CONTROL_ACTIVE_INDEX or 1
end

function LoC.Supported()
    return LossOfControlFrame ~= nil and C_LossOfControl ~= nil and LossOfControlFrame.SetUpDisplay ~= nil
end

function LoC.HasEditMode()
    return LossOfControlFrame ~= nil and LossOfControlFrame.SetIsInEditMode ~= nil
end

local function ReadEntry(index)
    local data = C_LossOfControl.GetActiveLossOfControlData(index)
    if not data then return end
    data.index = index
    data.secret = issecretvalue(data.locType) or issecretvalue(data.spellID) or issecretvalue(data.iconTexture)
        or issecretvalue(data.startTime) or issecretvalue(data.duration) or issecretvalue(data.lockoutSchool)
        or issecretvalue(data.displayText)
    return data
end

local function IsInterrupt(data)
    if not data then return false end
    if not data.secret then return data.locType == "SCHOOL_INTERRUPT" end
    local aura = data.auraInstanceID
    return data.priority == INTERRUPT_PRIORITY and not issecretvalue(aura) and aura == nil
end

local function Expiration(data)
    if data.secret then return 0 end
    if data.startTime and data.duration then
        return data.startTime + data.duration
    end
    return math.huge
end

local function SchoolInfo(school)
    local info = SCHOOLS[school]
    local name = C_Spell.GetSchoolString(school) or (info and info[1])
    if info then
        return name, info[2], info[3], info[4]
    end
    return name, 1, 1, 1
end

local function SetSchoolText(fontString, school)
    if issecretvalue(school) then
        fontString:SetText(C_Spell.GetSchoolString(school))
        fontString:SetTextColor(1, 1, 1)
    elseif school and school ~= 0 then
        local name, r, g, b = SchoolInfo(school)
        fontString:SetText(name or "")
        fontString:SetTextColor(r, g, b)
    else
        fontString:SetText("")
    end
end

local function SetCooldown(cooldown, data)
    if data and data.secret then
        local duration = C_LossOfControl.GetActiveLossOfControlDuration and C_LossOfControl.GetActiveLossOfControlDuration("player", data.index)
        if duration and cooldown.SetCooldownFromDurationObject then
            cooldown:SetCooldownFromDurationObject(duration)
        else
            CooldownFrame_Clear(cooldown)
        end
    elseif data and data.startTime and data.duration and data.duration > 0 then
        cooldown:SetCooldown(data.startTime, data.duration)
    else
        CooldownFrame_Clear(cooldown)
    end
end

local function DisplayText(data)
    if data.secret then return data.displayText end
    local text = data.displayText or ""
    if data.locType == "SCHOOL_INTERRUPT" and data.lockoutSchool and data.lockoutSchool ~= 0 and LOSS_OF_CONTROL_DISPLAY_INTERRUPT_SCHOOL then
        local school = SchoolInfo(data.lockoutSchool)
        if school then
            text = string.format(LOSS_OF_CONTROL_DISPLAY_INTERRUPT_SCHOOL, school)
        end
    end
    return text
end

local function CreateSchoolText(frame, anchor, size)
    local holder = CreateFrame("Frame", nil, frame)
    holder:SetAllPoints(anchor)
    holder:SetFrameLevel(frame:GetFrameLevel() + 10)
    local text = holder:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("BOTTOM", anchor, "BOTTOM", 0, 1)
    text:SetJustifyH("CENTER")
    text:SetFont(SCHOOL_FONT, size, "OUTLINE")
    return text
end

local function ShowSecondIcon()
    return DB().lossOfControlShowSecondIcon ~= false
end

local function ShowSchool()
    return DB().lossOfControlShowSchool ~= false
end

local function AnchorSecondary(secondary, icon)
    local db = DB()
    local scale = db.lossOfControlSecondIconScale or SECONDARY_SCALE
    local anchor = SECONDARY_ANCHORS[db.lossOfControlSecondaryPosition or "LEFT"] or SECONDARY_ANCHORS.LEFT
    secondary:SetScale(scale)
    secondary:ClearAllPoints()
    secondary:SetPoint(anchor[1], icon, anchor[2], anchor[3] / scale, anchor[4] / scale)
end

local function ApplyCountdownStyle(cooldown)
    local db = DB()
    local text = cooldown.GetCountdownFontString and cooldown:GetCountdownFontString()
    if text then
        if not cooldown.bbLoCFont then
            cooldown.bbLoCFont = { text:GetFont() }
            cooldown.bbLoCTextColor = { text:GetTextColor() }
        end
        local font, size, flags = unpack(cooldown.bbLoCFont)
        if font and size then
            text:SetFont(FontPath("lossOfControlNumberFont") or font, size * (db.lossOfControlCountdownScale or 1), flags)
        end
        local color = db.lossOfControlTimerBaseColor or WHITE
        text:SetTextColor(color[1], color[2], color[3], color[4] or 1)
    end
    if BBF.GetTimerFormatter and cooldown.SetCountdownFormatter and C_StringUtil and C_StringUtil.CreateNumericRuleFormatter then
        local formatter, key = BBF.GetTimerFormatter(db.lossOfControlTimerLowColor or LOW_COLOR, db.lossOfControlTimerLowThreshold or 3,
            db.lossOfControlTimerMilliseconds ~= false, false, nil, db.lossOfControlTimerHighThreshold or 10, db.lossOfControlTimerHighColor or WHITE)
        if cooldown.bbLoCFormatterKey ~= key then
            cooldown:SetCountdownFormatter(formatter)
            cooldown.bbLoCFormatterKey = key
        end
    end
end

local function RestoreCountdownStyle(cooldown)
    if cooldown.bbLoCFormatterKey then
        cooldown:SetCountdownFormatter(nil)
        cooldown.bbLoCFormatterKey = nil
    end
    local text = cooldown.bbLoCFont and cooldown:GetCountdownFontString()
    if text then
        local font, size, flags = unpack(cooldown.bbLoCFont)
        if font and size then
            text:SetFont(font, size, flags)
        end
        text:SetTextColor(unpack(cooldown.bbLoCTextColor))
    end
end

local function SetupCooldown(cooldown)
    if cooldown.SetMinimumCountdownDuration then
        cooldown:SetMinimumCountdownDuration(0)
    end
end

local function GetSecondary(frame)
    if frame.bbLoCSecondary then return frame.bbLoCSecondary end
    local secondary = CreateFrame("Frame", nil, frame)
    secondary:SetSize(48, 48)
    AnchorSecondary(secondary, frame.Icon)
    secondary.Icon = secondary:CreateTexture(nil, "ARTWORK")
    secondary.Icon:SetAllPoints()
    secondary.Cooldown = CreateFrame("Cooldown", nil, secondary, "CooldownFrameTemplate")
    secondary.Cooldown:SetAllPoints()
    SetupCooldown(secondary.Cooldown)
    secondary.SchoolText = CreateSchoolText(secondary, secondary, 11)
    secondary:Hide()
    frame.bbLoCSecondary = secondary
    return secondary
end

local function GetSchoolText(frame)
    if not frame.bbLoCSchoolText then
        frame.bbLoCSchoolText = CreateSchoolText(frame, frame.Icon, 11)
    end
    return frame.bbLoCSchoolText
end

local function BuildFrame()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(BG_WIDTH, 58)
    frame:SetFrameStrata("MEDIUM")
    frame:SetToplevel(true)
    frame.bbLoCOwned = true

    frame.blackBg = frame:CreateTexture(nil, "BACKGROUND")
    frame.blackBg:SetTexture("Interface\\Cooldown\\LoC-ShadowBG")
    frame.blackBg:SetSize(BG_WIDTH, 58)
    frame.blackBg:SetPoint("BOTTOM")

    frame.RedLineTop = frame:CreateTexture(nil, "BACKGROUND")
    frame.RedLineTop:SetTexture("Interface\\Cooldown\\Loc-RedLine")
    frame.RedLineTop:SetSize(LINE_WIDTH, 27)
    frame.RedLineTop:SetPoint("BOTTOM", frame, "TOP")

    frame.RedLineBottom = frame:CreateTexture(nil, "BACKGROUND")
    frame.RedLineBottom:SetTexture("Interface\\Cooldown\\Loc-RedLine")
    frame.RedLineBottom:SetSize(LINE_WIDTH, 27)
    frame.RedLineBottom:SetPoint("TOP", frame, "BOTTOM")
    frame.RedLineBottom:SetTexCoord(0, 1, 1, 0)

    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:SetSize(48, 48)
    frame.Icon:SetPoint("CENTER")

    frame.AbilityName = frame:CreateFontString(nil, "ARTWORK", "MovieSubtitleFont")
    frame.AbilityName:SetSize(0, 20)
    frame.AbilityName:SetPoint("CENTER")

    frame.Cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.Cooldown:SetAllPoints(frame.Icon)
    frame.Cooldown:SetSwipeColor(0.17, 0, 0, 0.64)
    frame.Cooldown:SetHideCountdownNumbers(true)
    SetupCooldown(frame.Cooldown)

    local timeLeft = CreateFrame("Frame", nil, frame)
    timeLeft:SetSize(TIME_LEFT_WIDTH, 20)
    frame.TimeLeft = timeLeft
    for _, key in ipairs({ "NumberText", "SecondsText" }) do
        local text = timeLeft:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
        text:SetSize(0, 20)
        text:SetShadowOffset(2, -2)
        text:SetShadowColor(0, 0, 0)
        text:SetTextColor(1, 1, 1)
        timeLeft[key] = text
    end
    timeLeft.NumberText:SetJustifyH("LEFT")
    timeLeft.NumberText:SetPoint("LEFT")
    timeLeft.NumberText:SetText("8.8")
    timeLeft.SecondsText:SetPoint("LEFT", timeLeft, "CENTER", -64, 0)
    timeLeft.SecondsText:SetText(LOSS_OF_CONTROL_SECONDS or "seconds")
    timeLeft.baseNumberWidth = timeLeft.NumberText:GetStringWidth() + TIME_OFFSET
    timeLeft.secondsWidth = timeLeft.SecondsText:GetStringWidth()

    frame:Hide()
    return frame
end

local function LayoutSide(frame, scale, timerScale, side, noTimer, noName)
    local timeLeft = frame.TimeLeft
    local timeScale = scale * timerScale
    local abilityWidth = noName and 0 or frame.AbilityName:GetStringWidth() * scale
    local timeWidth = noTimer and 0 or (timeLeft.NumberText:GetStringWidth() + TIME_OFFSET + (timeLeft.secondsWidth or 0)) * timeScale
    local longest = math.max(abilityWidth, timeWidth)
    local xOffset = (abilityWidth - longest) / 2 + 27
    frame.AbilityName:ClearAllPoints()
    frame.AbilityName:SetPoint("CENTER", frame, "CENTER", side * xOffset / scale, noTimer and 0 or 11)
    frame.Icon:ClearAllPoints()
    frame.Icon:SetPoint("CENTER", frame, "CENTER", -side * ((6 + longest) / 2), 0)
    timeLeft:ClearAllPoints()
    timeLeft:SetPoint("CENTER", frame, "CENTER", side * (xOffset + (TIME_LEFT_WIDTH * timeScale - abilityWidth) / 2) / timeScale, noName and 0 or -(2 + 10 * timerScale) / timerScale)
end

local measureText

local function TextWidth(fontString, sample)
    local width = fontString:GetStringWidth()
    if not issecretvalue(width) then return width end
    if not measureText then
        measureText = UIParent:CreateFontString(nil, "BACKGROUND", "GameFontNormalHuge")
        measureText:Hide()
    end
    local font, size, flags = fontString:GetFont()
    if font and size then
        measureText:SetFont(font, size, flags)
    end
    measureText:SetText(sample)
    return measureText:GetStringWidth()
end

local function WidthsSecret(frame)
    return issecretvalue(frame.AbilityName:GetText()) or issecretvalue(frame.TimeLeft.NumberText:GetText())
        or issecretvalue(frame.AbilityName:GetStringWidth()) or issecretvalue(frame.TimeLeft.NumberText:GetStringWidth())
end

local function ResetBlizzardAnchors(frame)
    if not frame.bbLoCChained then return end
    frame.bbLoCChained = nil
    for _, region in ipairs({ frame.Icon, frame.AbilityName, frame.TimeLeft }) do
        region:ClearAllPoints()
        region:SetPoint("CENTER")
    end
end

local function LayoutChained(frame, scale, timerScale, side, noTimer, noName)
    local near, far = side == 1 and "LEFT" or "RIGHT", side == 1 and "RIGHT" or "LEFT"
    local timeScale = scale * timerScale
    frame.bbLoCChained = true
    frame.Icon:ClearAllPoints()
    frame.Icon:SetPoint("CENTER", frame, "CENTER", -side * (6 + 80 * scale) / 2, 0)
    frame.AbilityName:ClearAllPoints()
    frame.AbilityName:SetPoint(near, frame.Icon, far, side * 6 / scale, (noTimer and 0 or 11) / scale)
    frame.TimeLeft:ClearAllPoints()
    frame.TimeLeft:SetPoint(near, frame.Icon, far, side * 6 / timeScale, noName and 0 or -(2 + 10 * timerScale) / timerScale)
end

local function RestoreDefaultAnchors(frame)
    if not frame.bbLoCMoved then return end
    frame.bbLoCMoved = nil
    ResetBlizzardAnchors(frame)
    if not WidthsSecret(frame) then
        LayoutSide(frame, 1, 1, 1)
    end
end

local function LayoutAnchored(frame, scale, timerScale, side, noTimer)
    local near, far = side == 1 and "LEFT" or "RIGHT", side == 1 and "RIGHT" or "LEFT"
    local nameY = noTimer and 0 or 11
    frame.bbLoCChained = true
    frame.AbilityName:ClearAllPoints()
    frame.AbilityName:SetPoint("CENTER", frame, "CENTER", side * 27 / scale, nameY / scale)
    frame.Icon:ClearAllPoints()
    frame.Icon:SetPoint(far, frame.AbilityName, near, -side * 6, -nameY)
    frame.TimeLeft:ClearAllPoints()
    frame.TimeLeft:SetPoint(near, frame.AbilityName, near, 0, -(10 * scale + 3 + 10 * scale * timerScale) / (scale * timerScale))
end

local function AnchorTimeText(timeLeft, align)
    local number, seconds = timeLeft.NumberText, timeLeft.SecondsText
    number:ClearAllPoints()
    seconds:ClearAllPoints()
    if align == "RIGHT" then
        seconds:SetPoint("RIGHT", timeLeft, "RIGHT", 0, 0)
        number:SetPoint("RIGHT", seconds, "LEFT", -TIME_OFFSET, 0)
    elseif align == "CENTER" then
        local base = timeLeft.baseNumberWidth or (TextWidth(number, "8.8") + TIME_OFFSET)
        local secondsWidth = timeLeft.secondsWidth or TextWidth(seconds, LOSS_OF_CONTROL_SECONDS or "seconds")
        number:SetPoint("RIGHT", timeLeft, "CENTER", (base - secondsWidth) / 2 - TIME_OFFSET, 0)
        seconds:SetPoint("LEFT", number, "RIGHT", TIME_OFFSET, 0)
    else
        number:SetPoint("LEFT", timeLeft, "LEFT", 0, 0)
        seconds:SetPoint("LEFT", timeLeft, "CENTER", -64, 0)
    end
end

local function GetSecretTimer(frame)
    if frame.bbLoCTimer ~= nil then return frame.bbLoCTimer or nil end
    local holder = CreateFrame("Frame", nil, frame)
    holder:SetSize(TIME_LEFT_WIDTH, 20)
    local cooldown = CreateFrame("Cooldown", nil, holder, "CooldownFrameTemplate")
    cooldown:SetSize(1, 1)
    cooldown:SetPoint("CENTER")
    cooldown:SetDrawSwipe(false)
    cooldown:SetDrawEdge(false)
    cooldown:SetDrawBling(false)
    cooldown:SetHideCountdownNumbers(false)
    SetupCooldown(cooldown)
    local number = cooldown.GetCountdownFontString and cooldown:GetCountdownFontString()
    if not number or not cooldown.SetCooldownFromDurationObject then
        frame.bbLoCTimer = false
        return
    end
    if BBF.GetTimerFormatter and cooldown.SetCountdownFormatter and C_StringUtil and C_StringUtil.CreateNumericRuleFormatter then
        cooldown:SetCountdownFormatter((BBF.GetTimerFormatter(WHITE, 10, true)))
    end
    holder.Cooldown = cooldown
    holder.NumberText = number
    holder.SecondsText = holder:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    holder.SecondsText:SetText(LOSS_OF_CONTROL_SECONDS or "seconds")
    holder:Hide()
    frame.bbLoCTimer = holder
    return holder
end

local function StyleSecretTimer(frame, holder, alpha, timeScale, align)
    local font, size, flags = frame.TimeLeft.SecondsText:GetFont()
    for _, text in ipairs({ holder.NumberText, holder.SecondsText }) do
        if font and size then
            text:SetFont(font, size, flags)
        end
        text:SetTextColor(1, 1, 1)
        text:SetShadowOffset(2, -2)
        text:SetShadowColor(0, 0, 0)
    end
    holder.baseNumberWidth = frame.TimeLeft.baseNumberWidth
    holder.secondsWidth = frame.TimeLeft.secondsWidth
    holder:SetAlpha(alpha)
    holder:SetScale(timeScale)
    holder:ClearAllPoints()
    holder:SetPoint("CENTER", frame.TimeLeft, "CENTER")
    AnchorTimeText(holder, align)
end

local function UpdateSecretTimer(frame, data)
    local duration = data and data.secret and not frame.isInEditMode and C_LossOfControl.GetActiveLossOfControlDuration
        and C_LossOfControl.GetActiveLossOfControlDuration("player", data.index)
    local holder = duration and GetSecretTimer(frame)
    if holder then
        holder.Cooldown:SetCooldownFromDurationObject(duration)
        holder:Show()
    elseif frame.bbLoCTimer then
        frame.bbLoCTimer:Hide()
    end
    frame.bbLoCTimerActive = holder and true or nil
    frame.TimeLeft.NumberText:SetAlpha(holder and 0 or 1)
    frame.TimeLeft.SecondsText:SetAlpha(holder and 0 or 1)
end

local function ApplyCooldownSettings(cooldown, forceNumbers)
    local db = DB()
    local swipe = db.showCooldownOnLoC ~= false
    cooldown:SetDrawSwipe(swipe)
    cooldown:SetReverse(db.lossOfControlReverseSwipe and true or false)
    if swipe then
        if cooldown.bbLoCEdgeHidden then
            cooldown:SetEdgeColor(unpack(cooldown.bbLoCEdgeColor or { 1, 1, 1, 1 }))
            cooldown.bbLoCEdgeHidden = nil
        end
    else
        cooldown:SetEdgeColor(0, 0, 0, 0)
        cooldown.bbLoCEdgeHidden = true
    end
    cooldown:SetHideCountdownNumbers(not (db.lossOfControlCountdown or forceNumbers))
    ApplyCountdownStyle(cooldown)
end

local function ApplyLayout(frame)
    local db = DB()
    local iconOnly = db.lossOfControlIconOnly
    local position = db.lossOfControlTextPosition or "RIGHT"
    local scale = db.lossOfControlTextScale or 1
    local timerScale = db.lossOfControlTimerScale or 1
    local noTimer = frame.bbLoCNoTimer or db.lossOfControlHideTimer
    local noName = db.lossOfControlHideName
    local shown = frame.bbLoCOwned or frame.isInEditMode or not db.lossOfControlInterruptsOnly
    local visible = shown and 1 or 0
    local textAlpha = iconOnly and 0 or visible

    frame.blackBg:SetVertexColor(1, 1, 1, 1)
    frame.blackBg:SetAlpha(db.hideLossOfControlFrameBg and 0 or visible * BG_ALPHA)
    frame.RedLineTop:SetAlpha(db.hideLossOfControlFrameLines and 0 or visible)
    frame.RedLineBottom:SetAlpha(db.hideLossOfControlFrameLines and 0 or visible)
    frame.RedLineTop:SetWidth(iconOnly and ICON_ONLY_LINE_WIDTH or LINE_WIDTH)
    frame.RedLineBottom:SetWidth(iconOnly and ICON_ONLY_LINE_WIDTH or LINE_WIDTH)
    frame.blackBg:SetWidth(iconOnly and ICON_ONLY_BG_WIDTH or BG_WIDTH)
    frame.Icon:SetAlpha(visible)
    frame.Cooldown:SetAlpha(visible)
    frame.AbilityName:SetAlpha(noName and 0 or textAlpha)
    local timerAlpha = noTimer and 0 or textAlpha
    frame.TimeLeft:SetAlpha(timerAlpha)
    frame.AbilityName:SetScale(scale)
    frame.TimeLeft:SetScale(scale * timerScale)
    ApplyFonts(frame)
    if frame.bbLoCSchoolText then
        frame.bbLoCSchoolText:SetAlpha(ShowSchool() and visible or 0)
    end
    if frame.bbLoCSecondary then
        frame.bbLoCSecondary:SetAlpha(visible)
        frame.bbLoCSecondary.SchoolText:SetAlpha(ShowSchool() and 1 or 0)
        AnchorSecondary(frame.bbLoCSecondary, frame.Icon)
        ApplyCooldownSettings(frame.bbLoCSecondary.Cooldown)
    end
    ApplyCooldownSettings(frame.Cooldown, frame.bbLoCNoTimer)

    local sideways = position == "RIGHT" or position == "LEFT"
    if iconOnly or not sideways then
        frame.bbLoCMoved = true
        frame.Icon:ClearAllPoints()
        frame.Icon:SetPoint("CENTER", frame, "CENTER", 0, 0)
    end
    if not iconOnly and not sideways then
        local near = 26 + 10 * scale
        local timeHalf = 10 * scale * timerScale
        local nameY, timeY
        if position == "OVER" then
            timeY = 26 + timeHalf
            nameY = noTimer and near or timeY + timeHalf + 12 * scale
        else
            nameY = -near
            timeY = noName and -(26 + timeHalf) or nameY - 12 * scale - timeHalf
        end
        frame.AbilityName:ClearAllPoints()
        frame.AbilityName:SetPoint("CENTER", frame, "CENTER", 0, nameY / scale)
        frame.TimeLeft:ClearAllPoints()
        frame.TimeLeft:SetPoint("CENTER", frame, "CENTER", 0, timeY / (scale * timerScale))
        AnchorTimeText(frame.TimeLeft, "CENTER")
    else
        AnchorTimeText(frame.TimeLeft, position == "LEFT" and "RIGHT" or "LEFT")
        if not iconOnly then
            local side = position == "LEFT" and -1 or 1
            if WidthsSecret(frame) then
                frame.bbLoCMoved = true
                if noName then
                    LayoutChained(frame, scale, timerScale, side, noTimer, noName)
                else
                    LayoutAnchored(frame, scale, timerScale, side, noTimer)
                end
            elseif not frame.bbLoCOwned and side == 1 and scale == 1 and timerScale == 1 and not noTimer and not noName then
                RestoreDefaultAnchors(frame)
            else
                frame.bbLoCMoved = true
                LayoutSide(frame, scale, timerScale, side, noTimer, noName)
            end
        end
    end
end

local function ApplyTimerLayout(frame)
    local holder = frame.bbLoCTimer
    if not holder then return end
    local db = DB()
    local position = db.lossOfControlTextPosition or "RIGHT"
    local align = (position == "OVER" or position == "UNDER") and "CENTER" or position == "LEFT" and "RIGHT" or "LEFT"
    StyleSecretTimer(frame, holder, frame.TimeLeft:GetAlpha(), frame.TimeLeft:GetScale(), align)
end

local function RestoreBlizzard(frame)
    frame.blackBg:SetAlpha(1)
    frame.blackBg:SetVertexColor(1, 1, 1, BG_ALPHA)
    frame.RedLineTop:SetAlpha(1)
    frame.RedLineBottom:SetAlpha(1)
    frame.RedLineTop:SetWidth(LINE_WIDTH)
    frame.RedLineBottom:SetWidth(LINE_WIDTH)
    frame.blackBg:SetWidth(BG_WIDTH)
    frame.Icon:SetAlpha(1)
    frame.Cooldown:SetAlpha(1)
    frame.AbilityName:SetAlpha(1)
    frame.TimeLeft:SetAlpha(1)
    frame.AbilityName:SetScale(1)
    frame.TimeLeft:SetScale(1)
    ApplyFonts(frame, true)
    RestoreCountdownStyle(frame.Cooldown)
    frame.Cooldown:SetDrawSwipe(true)
    frame.Cooldown:SetReverse(false)
    if frame.Cooldown.bbLoCEdgeHidden then
        frame.Cooldown:SetEdgeColor(unpack(frame.Cooldown.bbLoCEdgeColor or { 1, 1, 1, 1 }))
        frame.Cooldown.bbLoCEdgeHidden = nil
    end
    frame.Cooldown:SetHideCountdownNumbers(true)
    AnchorTimeText(frame.TimeLeft, "LEFT")
    UpdateSecretTimer(frame, nil)
    if frame.bbLoCSecondary then
        frame.bbLoCSecondary:Hide()
    end
    if frame.bbLoCSchoolText then
        frame.bbLoCSchoolText:SetText("")
    end
end

local function ShowSecondary(frame, data)
    local secondary = GetSecondary(frame)
    if not data then
        secondary:Hide()
        return
    end
    secondary.Icon:SetTexture(data.iconTexture)
    SetCooldown(secondary.Cooldown, data)
    SetSchoolText(secondary.SchoolText, IsInterrupt(data) and data.lockoutSchool)
    secondary:Show()
end

local function GetInterruptFrame()
    if interruptFrame then return interruptFrame end
    interruptFrame = BuildFrame()
    interruptFrame.bbLoCNoTimer = true
    interruptFrame:SetPoint("CENTER", LossOfControlFrame, "CENTER")
    interruptFrame.Cooldown:SetScript("OnCooldownDone", function()
        interruptFrame:Hide()
    end)
    return interruptFrame
end

local function ShowInterrupt(data)
    if not data then
        if interruptFrame then
            interruptFrame:Hide()
        end
        return
    end
    local frame = GetInterruptFrame()
    frame:SetScale(LossOfControlFrame:GetScale())
    frame.Icon:SetTexture(data.iconTexture)
    frame.AbilityName:SetText(DisplayText(data))
    SetCooldown(frame.Cooldown, data)
    SetSchoolText(GetSchoolText(frame), data.lockoutSchool)
    ApplyLayout(frame)
    frame:Show()
end

local function SelectEntries()
    local count = C_LossOfControl.GetActiveLossOfControlDataCount()
    if not count or issecretvalue(count) then return end
    local activeIndex = ActiveIndex()
    local main = ReadEntry(activeIndex)
    local secondary, secondaryInterrupt, interrupt
    for i = 1, count do
        local data = i == activeIndex and main or ReadEntry(i)
        if data and data.displayType ~= DISPLAY_TYPE_NONE then
            local isInterrupt = IsInterrupt(data)
            if isInterrupt and (not interrupt or Expiration(data) > Expiration(interrupt)) then
                interrupt = data
            end
            if i ~= activeIndex and not (main and not main.secret and not data.secret and data.spellID == main.spellID) then
                if not secondary or (isInterrupt and not secondaryInterrupt)
                    or (isInterrupt == secondaryInterrupt and (data.priority > secondary.priority
                    or (data.priority == secondary.priority and Expiration(data) > Expiration(secondary)))) then
                    secondary, secondaryInterrupt = data, isInterrupt
                end
            end
        end
    end
    return main, secondary, interrupt, secondaryInterrupt
end

local function UpdateExtras()
    if not enabled then return end
    local frame = LossOfControlFrame
    local db = DB()
    if frame.isInEditMode then
        UpdateSecretTimer(frame, nil)
        ShowSecondary(frame, nil)
        GetSchoolText(frame):SetText("")
        ShowInterrupt(nil)
        return
    end
    local main, secondary, interrupt, secondaryInterrupt = SelectEntries()
    UpdateSecretTimer(frame, main)
    ApplyTimerLayout(frame)
    if db.lossOfControlSecondIconInterruptsOnly and not secondaryInterrupt then
        secondary = nil
    end
    if db.lossOfControlInterruptsOnly then
        ShowSecondary(frame, nil)
        GetSchoolText(frame):SetText("")
        ShowInterrupt(interrupt)
        return
    end
    ShowInterrupt(nil)
    SetSchoolText(GetSchoolText(frame), IsInterrupt(main) and main.lockoutSchool)
    ShowSecondary(frame, ShowSecondIcon() and secondary or nil)
    ApplyLayout(frame)
end

local function OnSetUpDisplay(frame)
    if not enabled then return end
    if not frame.bbLoCChained then
        frame.bbLoCMoved = nil
    end
    ApplyLayout(frame)
    UpdateExtras()
    ApplyTimerLayout(frame)
end

local editModeScale, scaleHooked

local function EditModeScale()
    local setting = Enum.EditModeLossOfControlSetting and Enum.EditModeLossOfControlSetting.Size
    local size = setting and LossOfControlFrame.GetSettingValue and LossOfControlFrame:GetSettingValue(setting)
    if size and size > 0 then
        return size / 100
    end
end

function LoC.GetScale()
    return DB().lossOfControlEditModeScale or EditModeScale() or 1
end

local function ApplyEditModeScale()
    local db = DB()
    local current = EditModeScale()
    if current and current ~= editModeScale then
        local copy = editModeScale or db.lossOfControlEditModeScale == nil
        editModeScale = current
        if copy then
            db.lossOfControlEditModeScale = current
            if BBF.LoCPositionChanged then
                BBF.LoCPositionChanged()
            end
        end
    end
    local scale = db.lossOfControlEditModeScale or current
    if scale then
        LossOfControlFrame:SetScale(scale)
    end
end

local function OnEditModeSize()
    if enabled then
        ApplyEditModeScale()
    end
end

local function ApplyPosition()
    if LoC.HasEditMode() then
        if not scaleHooked and LossOfControlFrame.UpdateSystemSettingSize then
            hooksecurefunc(LossOfControlFrame, "UpdateSystemSettingSize", OnEditModeSize)
            scaleHooked = true
        end
        ApplyEditModeScale()
        return
    end
    local db = DB()
    local frame = LossOfControlFrame
    frame:SetScale(db.lossOfControlScale or 1)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", db.lossOfControlXPos or 0, db.lossOfControlYPos or 0)
end

local function DropOffset(frame)
    local cx, cy = frame:GetCenter()
    local ux, uy = UIParent:GetCenter()
    local ratio = UIParent:GetEffectiveScale() / frame:GetEffectiveScale()
    return math.floor(cx - ux * ratio + 0.5), math.floor(cy - uy * ratio + 0.5)
end

local function MakeDraggable(frame, apply)
    frame:EnableMouse(true)
    if frame.bbLoCDraggable then return end
    frame.bbLoCDraggable = true
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self:SetUserPlaced(false)
        local db = DB()
        db.lossOfControlXPos, db.lossOfControlYPos = DropOffset(self)
        apply(self)
        if BBF.LoCPositionChanged then
            BBF.LoCPositionChanged()
        end
    end)
end

function LoC.Refresh()
    if not LoC.Supported() then return end
    local frame = LossOfControlFrame
    enabled = DB().enableLoCFrame and true or false
    if enabled then
        changed = true
        if not hooked then
            if not LoC.HasEditMode() then
                frame.Cooldown.bbLoCEdgeColor = { 1, 1, 0, 1 }
            end
            hooksecurefunc(frame, "SetUpDisplay", OnSetUpDisplay)
            hooked = true
        end
        if not eventFrame then
            eventFrame = CreateFrame("Frame")
            eventFrame:SetScript("OnEvent", UpdateExtras)
        end
        eventFrame:RegisterUnitEvent("LOSS_OF_CONTROL_ADDED", "player")
        eventFrame:RegisterUnitEvent("LOSS_OF_CONTROL_UPDATE", "player")
        ApplyPosition()
        ApplyLayout(frame)
        UpdateExtras()
    elseif changed then
        changed = nil
        if eventFrame then
            eventFrame:UnregisterAllEvents()
        end
        ShowInterrupt(nil)
        RestoreBlizzard(frame)
        if LoC.HasEditMode() then
            frame:SetScale(EditModeScale() or 1)
        end
    end
    if testFrame and testFrame:IsShown() then
        LoC.Test()
    end
end

function LoC.StopTest()
    if testTimer then
        testTimer:Cancel()
        testTimer = nil
    end
    if testFrame then
        testFrame:Hide()
    end
end

function LoC.Test()
    if not LoC.Supported() then return end
    local db = DB()
    if not testFrame then
        testFrame = BuildFrame()
        testFrame:SetPoint("CENTER", LossOfControlFrame, "CENTER")
        testFrame.Close = CreateFrame("Button", nil, testFrame, "UIPanelCloseButton")
        testFrame.Close:SetSize(30, 30)
        testFrame.Close:SetPoint("TOPRIGHT", testFrame, "TOPRIGHT", 5, 40)
        testFrame.Close:SetScript("OnClick", LoC.StopTest)
        GetSecondary(testFrame)
        GetSchoolText(testFrame)
        if not LoC.HasEditMode() then
            MakeDraggable(testFrame, function(self)
                ApplyPosition()
                self:ClearAllPoints()
                self:SetPoint("CENTER", LossOfControlFrame, "CENTER")
            end)
        end
    end
    local now = GetTime()
    local interruptsOnly = db.lossOfControlInterruptsOnly
    testFrame:SetScale(LossOfControlFrame:GetScale())
    testFrame.bbLoCNoTimer = interruptsOnly or nil
    if interruptsOnly then
        testFrame.Icon:SetTexture(132219)
        testFrame.AbilityName:SetText(LOSS_OF_CONTROL_DISPLAY_INTERRUPT or "Interrupted")
        testFrame.Cooldown:SetCooldown(now, 4)
        SetSchoolText(testFrame.bbLoCSchoolText, 32)
        testFrame.bbLoCSecondary:Hide()
    else
        testFrame.Icon:SetTexture(132298)
        testFrame.AbilityName:SetText(LOSS_OF_CONTROL_DISPLAY_STUN or "Stunned")
        testFrame.Cooldown:SetCooldown(now, 8)
        testFrame.TimeLeft.NumberText:SetFormattedText("%.1F", 8)
        SetSchoolText(testFrame.bbLoCSchoolText, nil)
        local secondary = testFrame.bbLoCSecondary
        secondary.Icon:SetTexture(132219)
        secondary.Cooldown:SetCooldown(now, 4)
        SetSchoolText(secondary.SchoolText, 32)
        secondary:SetShown(ShowSecondIcon())
    end
    ApplyLayout(testFrame)
    testFrame:Show()
    if testTimer then
        testTimer:Cancel()
    end
    testTimer = C_Timer.NewTimer(8, function()
        testTimer = nil
        if SettingsOpen() then
            LoC.Test()
        else
            LoC.StopTest()
        end
    end)
end

local function ApplyOwnCooldown(cooldown)
    if not cooldown then return end
    local db = DB()
    local swipe = db.showCooldownOnLoC ~= false
    cooldown:SetDrawSwipe(swipe)
    cooldown:SetDrawEdge(swipe)
    cooldown:SetReverse(db.lossOfControlReverseSwipe and true or false)
    cooldown:SetHideCountdownNumbers(not db.lossOfControlCountdown)
    ApplyCountdownStyle(cooldown)
end

function LoC.ApplyOwnLayout(frame)
    local db = DB()
    local iconOnly = db.lossOfControlIconOnly
    local position = db.lossOfControlTextPosition or "RIGHT"
    local lines = db.hideLossOfControlFrameLines and 0 or 1
    local noTimer = db.lossOfControlHideTimer
    local noName = db.lossOfControlHideName

    frame:GetParent():SetScale(db.lossOfControlScale or 1)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", db.lossOfControlXPos or 0, db.lossOfControlYPos or 0)

    frame.RedLineTop:SetWidth(iconOnly and ICON_ONLY_LINE_WIDTH or LINE_WIDTH)
    frame.RedLineBottom:SetWidth(iconOnly and ICON_ONLY_LINE_WIDTH or LINE_WIDTH)
    frame.RedLineTop:SetAlpha(lines)
    frame.RedLineBottom:SetAlpha(lines)
    frame.blackBg:SetAlpha(db.hideLossOfControlFrameBg and 0 or BG_ALPHA)
    frame.AbilityName:SetShown(not iconOnly and not noName)
    frame.TimeLeft:SetShown(not iconOnly and not noTimer)
    frame.AbilityName:SetScale(db.lossOfControlTextScale or 1)
    frame.TimeLeft:SetScale((db.lossOfControlTextScale or 1) * (db.lossOfControlTimerScale or 1))
    ApplyFonts(frame)
    if frame.Icon.SchoolText then
        frame.Icon.SchoolText:SetAlpha(ShowSchool() and 1 or 0)
    end
    if frame.SecondaryIcon then
        AnchorSecondary(frame.SecondaryIcon, frame.Icon)
        frame.SecondaryIcon:SetAlpha(ShowSecondIcon() and 1 or 0)
        if frame.SecondaryIcon.SchoolText then
            frame.SecondaryIcon.SchoolText:SetAlpha(ShowSchool() and 1 or 0)
        end
    end
    ApplyOwnCooldown(frame.Icon.Cooldown)
    ApplyOwnCooldown(frame.SecondaryIcon and frame.SecondaryIcon.Cooldown)

    local left = position == "LEFT"
    local centered = iconOnly or not (left or position == "RIGHT")
    frame.Icon:ClearAllPoints()
    frame.Icon:SetPoint("CENTER", frame, "CENTER", centered and 0 or (left and 70 or -70), 0)
    frame.AbilityName:ClearAllPoints()
    frame.TimeLeft:ClearAllPoints()
    frame.TimeLeft.NumberText:ClearAllPoints()
    if centered and not iconOnly then
        if position == "OVER" and noTimer then
            frame.TimeLeft:SetPoint("BOTTOM", frame.Icon, "TOP", 0, 4)
            frame.AbilityName:SetPoint("BOTTOM", frame.Icon, "TOP", 0, 4)
        elseif position == "OVER" then
            frame.TimeLeft:SetPoint("BOTTOM", frame.Icon, "TOP", 0, 4)
            frame.AbilityName:SetPoint("BOTTOM", frame.TimeLeft, "TOP")
        elseif noName then
            frame.TimeLeft:SetPoint("TOP", frame.Icon, "BOTTOM", 0, -4)
        else
            frame.AbilityName:SetPoint("TOP", frame.Icon, "BOTTOM", 0, -4)
            frame.TimeLeft:SetPoint("TOP", frame.AbilityName, "BOTTOM")
        end
        frame.TimeLeft.NumberText:SetPoint("CENTER", frame.TimeLeft, "CENTER", 0, -3)
    elseif left then
        if noTimer then
            frame.AbilityName:SetPoint("RIGHT", frame.Icon, "LEFT", -5, 0)
        else
            frame.AbilityName:SetPoint("TOPRIGHT", frame.Icon, "TOPLEFT", -5, -4)
        end
        if noName then
            frame.TimeLeft:SetPoint("RIGHT", frame.Icon, "LEFT", -5, 0)
            frame.TimeLeft.NumberText:SetPoint("RIGHT", frame.TimeLeft, "RIGHT", 0, 0)
        else
            frame.TimeLeft:SetPoint("TOPRIGHT", frame.AbilityName, "BOTTOMRIGHT")
            frame.TimeLeft.NumberText:SetPoint("RIGHT", frame.TimeLeft, "RIGHT", 0, -3)
        end
    else
        if noTimer then
            frame.AbilityName:SetPoint("LEFT", frame.Icon, "RIGHT", 5, 0)
        else
            frame.AbilityName:SetPoint("TOPLEFT", frame.Icon, "TOPRIGHT", 5, -4)
        end
        if noName then
            frame.TimeLeft:SetPoint("LEFT", frame.Icon, "RIGHT", 5, 0)
            frame.TimeLeft.NumberText:SetPoint("LEFT", frame.TimeLeft, "LEFT", 0, 0)
        else
            frame.TimeLeft:SetPoint("TOPLEFT", frame.AbilityName, "BOTTOMLEFT")
            frame.TimeLeft.NumberText:SetPoint("LEFT", frame.TimeLeft, "LEFT", 0, -3)
        end
    end
end

local ownTestTicker, ownTestFrame, ownTestText

local function EndOwnTest(frame)
    if ownTestTicker then
        ownTestTicker:Cancel()
        ownTestTicker = nil
    end
    frame.returnEarly = nil
    frame:EnableMouse(false)
    frame.bbLoCClose:Hide()
    frame.TimeLeft.NumberText:SetText("")
    frame.SecondaryIcon:Hide()
    frame.fadeOutShrink:Stop()
    frame.fadeOutShrink:Play()
end

function LoC.TestOwn(frame, text)
    if not frame then return end
    LoC.ApplyOwnLayout(frame)
    if ownTestTicker then
        ownTestTicker:Cancel()
        ownTestTicker = nil
    end
    ownTestFrame, ownTestText = frame, text

    local interruptsOnly = DB().lossOfControlInterruptsOnly
    local duration = interruptsOnly and 4 or 8
    local now = GetTime()
    frame.returnEarly = true
    frame:GetParent():SetParent(UIParent)
    if not frame.bbLoCClose then
        frame.bbLoCClose = CreateFrame("Button", nil, frame:GetParent(), "UIPanelCloseButton")
        frame.bbLoCClose:SetSize(30, 30)
        frame.bbLoCClose:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 5, 40)
        frame.bbLoCClose:SetFrameStrata(frame:GetFrameStrata())
        frame.bbLoCClose:SetFrameLevel(frame:GetFrameLevel() + 10)
        frame.bbLoCClose:SetScript("OnClick", function()
            EndOwnTest(frame)
        end)
    end
    frame.bbLoCClose:Show()
    frame.expiration = now + duration
    frame.duration = duration
    frame.Icon.Cooldown:SetCooldown(now, duration)
    if interruptsOnly then
        frame.Icon:SetTexture(132219)
        frame.AbilityName:SetText(LOSS_OF_CONTROL_DISPLAY_INTERRUPT or "Interrupted")
        SetSchoolText(frame.Icon.SchoolText, 32)
        frame.AbilityName:SetTextColor(frame.Icon.SchoolText:GetTextColor())
        frame.SecondaryIcon:Hide()
    else
        frame.Icon:SetTexture(132298)
        frame.AbilityName:SetText(text or LOSS_OF_CONTROL_DISPLAY_STUN or "Stunned")
        frame.AbilityName:SetTextColor(1, 0.819, 0)
        frame.Icon.SchoolText:SetText("")
        frame.SecondaryIcon.icon:SetTexture(132219)
        frame.SecondaryIcon.Cooldown:SetCooldown(now, 4)
        SetSchoolText(frame.SecondaryIcon.SchoolText, 32)
        frame.SecondaryIcon:Show()
    end

    if not frame:IsShown() then
        frame:SetAlpha(0)
        frame:SetScale(0.85)
        frame:Show()
        frame.fadeInScale:Stop()
        frame.fadeInScale:Play()
    end
    frame.TimeLeft.NumberText:SetText(string.format("%.1f %s", duration, LOSS_OF_CONTROL_SECONDS or "seconds"))
    MakeDraggable(frame, LoC.ApplyOwnLayout)

    ownTestTicker = C_Timer.NewTicker(0.1, function()
        local remaining = frame.expiration and (frame.expiration - GetTime()) or 0
        if remaining > 0 then
            frame.TimeLeft.NumberText:SetText(string.format("%.1f %s", remaining, LOSS_OF_CONTROL_SECONDS or "seconds"))
            return
        end
        if SettingsOpen() then
            LoC.TestOwn(frame, text)
            return
        end
        EndOwnTest(frame)
    end)
end

function LoC.RefreshOwnTest()
    if ownTestTicker then
        LoC.TestOwn(ownTestFrame, ownTestText)
    end
end
