local LSM = LibStub("LibSharedMedia-3.0")

local DEFAULT_ABSORB_ICON = 1723997

local function UpdateAbsorbIndicator(frame, unit)
    local db = BetterBlizzFramesDB
    if not db.absorbIndicator and not db.absorbIndicatorTestMode then return end

    local settingsPrefix = unit
    local showAmount = db[settingsPrefix .. "AbsorbAmount"]
    local showIcon = db[settingsPrefix .. "AbsorbIcon"]
    local xPos = db.playerAbsorbXPos
    local yPos = db.playerAbsorbYPos
    local anchor = db.playerAbsorbAnchor
    local reverseAnchor = BBF.GetOppositeAnchor(anchor)
    local darkModeOn = db.darkModeUi
    local vertexColor = darkModeOn and db.darkModeColor or 1
    local testMode = db.absorbIndicatorTestMode
    local flipIconText = db.absorbIndicatorFlipIconText

    if not frame.absorbParent then
        frame.absorbParent = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        frame.absorbParent:SetSize(50, 50)
        frame.absorbParent:SetPoint("CENTER", frame, "CENTER", xPos, yPos)
        frame.absorbParent:SetFrameStrata("HIGH")

        frame.absorbIcon = frame.absorbParent:CreateTexture(nil, "OVERLAY")
        frame.absorbIcon:SetSize(20, 20)
        frame.absorbIcon:SetPoint("CENTER", frame.absorbParent, "CENTER")

        frame.absorbIndicator = frame.absorbParent:CreateFontString(nil, "OVERLAY")

        if db.changeUnitFrameFont then
            local fontName = db.unitFrameFont
            local fontPath = LSM:Fetch(LSM.MediaType.FONT, fontName)
            local outline = db.unitFrameFontOutline or "OUTLINE"
            frame.absorbIndicator:SetFont(fontPath, 16, outline)
        else
            frame.absorbIndicator:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
        end
        frame.absorbIndicator:SetPoint("CENTER", frame.absorbParent, "CENTER")
        frame.absorbIndicator:SetDrawLayer("OVERLAY", 7)
    end

    if not frame.absorbIcon.border then
        local border = CreateFrame("Frame", nil, frame.absorbParent, "BackdropTemplate")
        border:SetBackdrop({
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tileEdge = true,
            edgeSize = 8,
        })

        border:SetPoint("TOPLEFT", frame.absorbIcon, "TOPLEFT", -2, 2)
        border:SetPoint("BOTTOMRIGHT", frame.absorbIcon, "BOTTOMRIGHT", 2, -2)
        border:SetFrameLevel(frame.absorbParent:GetFrameLevel() + 1)
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

    frame.absorbIndicator:SetScale(db.absorbIndicatorScale)
    frame.absorbIcon:SetScale(db.absorbIndicatorScale)

    if testMode then
        frame.absorbIcon:SetTexture(DEFAULT_ABSORB_ICON)
        frame.absorbIcon:SetAlpha(1)
        frame.absorbIndicator:SetText("69k")
        frame.absorbIndicator:SetAlpha(1)
        if frame == PlayerFrame then
            if anchor == "LEFT" or anchor == "RIGHT" then
                frame.absorbIcon:SetPoint(anchor, frame, reverseAnchor, -20 + xPos, -1.5 + yPos)
            else
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, -30 + xPos, -25.5 + yPos)
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
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, 20 + xPos, -1 + yPos)
            else
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, 30 + xPos, -25 + yPos)
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
                frame.absorbIcon:SetPoint(anchor, frame, reverseAnchor, -20 + xPos, -1.5 + yPos)
            else
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, -30 + xPos, -25.5 + yPos)
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
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, 20 + xPos, -1 + yPos)
            else
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, 30 + xPos, -25 + yPos)
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
                    frame.absorbIndicator:SetPoint("RIGHT", frame.absorbIcon, "LEFT", -2, 0)
                end
            else
                frame.absorbIndicator:SetPoint("RIGHT", frame.absorbIcon, "LEFT", 20, 0)
            end
        end


        local absorb = UnitGetTotalAbsorbs(unit) or 0
        local shown = issecretvalue(absorb) and absorb or (absorb > 0 and 1 or 0)
        frame.absorbIndicator:SetText(AbbreviateNumbers(absorb))
        frame.absorbIndicator:SetAlpha(shown)
        if showIcon then
            frame.absorbIcon:SetTexture(DEFAULT_ABSORB_ICON)
            frame.absorbIcon:SetAlpha(shown)
            frame.absorbIcon.border:SetAlpha(darkModeOn and shown or 0)
        else
            frame.absorbIcon:SetAlpha(0)
            frame.absorbIcon.border:SetAlpha(0)
        end
    else
        if frame.absorbIndicator then frame.absorbIndicator:SetAlpha(0) end
        if frame.absorbIcon then frame.absorbIcon:SetAlpha(0) end
        if frame.absorbIcon.border then
            frame.absorbIcon.border:SetAlpha(0)
        end
    end
end

local units = {
    ["target"] = true,
    ["player"] = true,
    ["focus"] = true,
}

local function OnAbsorbEvent(self, event, unit)
    if not units[unit] then return end
    if unit == "target" then
        UpdateAbsorbIndicator(TargetFrame, "target")
    elseif unit == "player" then
        UpdateAbsorbIndicator(PlayerFrame, "player")
    elseif unit == "focus" then
        UpdateAbsorbIndicator(FocusFrame, "focus")
    end
end

local function OnTargetChange(self, event)
    if event == "PLAYER_TARGET_CHANGED" then
        UpdateAbsorbIndicator(TargetFrame, "target")
    elseif event == "PLAYER_FOCUS_CHANGED" then
        UpdateAbsorbIndicator(FocusFrame, "focus")
    elseif event == "PLAYER_ENTERING_WORLD" then
        UpdateAbsorbIndicator(PlayerFrame, "player")
        UpdateAbsorbIndicator(FocusFrame, "focus")
        UpdateAbsorbIndicator(TargetFrame, "target")
    end
end

local absorbEventFrame
function BBF.AbsorbCaller()
    if BetterBlizzFramesDB.absorbIndicator and not absorbEventFrame then
        absorbEventFrame = CreateFrame("Frame")
        absorbEventFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player", "target", "focus")
        absorbEventFrame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", "player", "target", "focus")
        absorbEventFrame:SetScript("OnEvent", OnAbsorbEvent)

        local targetChangeFrame = CreateFrame("Frame")
        targetChangeFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        targetChangeFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
        targetChangeFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        targetChangeFrame:SetScript("OnEvent", OnTargetChange)
    end
    UpdateAbsorbIndicator(PlayerFrame, "player")
    UpdateAbsorbIndicator(FocusFrame, "focus")
    UpdateAbsorbIndicator(TargetFrame, "target")
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
end