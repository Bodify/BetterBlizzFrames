local tracked = setmetatable({}, { __mode = "k" })
local ticker, eventFrame

local function GetRangeLook()
    local db = BetterBlizzFramesDB
    local own = db.interruptIconRangeOwnSettings
    local overlay, desat, color
    if own then
        overlay = db.interruptIconRangeUseOverlay
        desat = db.interruptIconRangeDesaturate
        color = overlay and db.interruptIconRangeOverlayColor or db.interruptIconRangeIconColor
    else
        overlay = db.actionBarRangeUseOverlay
        desat = db.actionBarRangeDesaturate
        color = overlay and db.actionBarRangeOverlayColor or db.actionBarRangeIconColor
    end
    color = color or (overlay and { 1, 0, 0, 0.35 } or { 0.59, 0.24, 0.22, 1 })
    return overlay and true or false, color, desat and true or false
end

local function IsOutOfRange(spellID, unit)
    local inRange
    if C_Spell and C_Spell.IsSpellInRange then
        inRange = C_Spell.IsSpellInRange(spellID, unit)
    elseif IsSpellInRange then
        local name = GetSpellInfo(spellID)
        local result = name and IsSpellInRange(name, unit)
        if result ~= nil then
            inRange = result == 1 or result == true
        end
    end
    if issecretvalue(inRange) then return false end
    return inRange == false
end

local function GetOverlay(frame)
    local overlay = frame.bbfRangeOverlay
    if overlay then return overlay end
    local layer, sublevel = frame.icon:GetDrawLayer()
    overlay = frame:CreateTexture(nil, layer, nil, math.min((sublevel or 0) + 1, 6))
    overlay:SetAllPoints(frame.icon)
    overlay:SetColorTexture(1, 1, 1, 1)
    overlay:Hide()
    frame.bbfRangeOverlay = overlay
    return overlay
end

local function PaintBorder(frame)
    local border = frame.border
    local c = frame.bbfRangeBorderColor
    frame.bbfPaintingBorder = true
    if c then
        border:SetVertexColor(c[1], c[2], c[3], 1)
    else
        border:SetVertexColor(frame.bbfBorderR, frame.bbfBorderG, frame.bbfBorderB, frame.bbfBorderA)
    end
    frame.bbfPaintingBorder = nil
end

local function HookBorder(frame)
    local border = frame.border
    if frame.bbfBorderHooked == border then return end
    frame.bbfBorderHooked = border
    frame.bbfBorderR, frame.bbfBorderG, frame.bbfBorderB, frame.bbfBorderA = border:GetVertexColor()
    hooksecurefunc(border, "SetVertexColor", function(_, r, g, b, a)
        if frame.bbfPaintingBorder then return end
        frame.bbfBorderR, frame.bbfBorderG, frame.bbfBorderB, frame.bbfBorderA = r, g, b, a
        if frame.bbfRangeBorderColor then
            PaintBorder(frame)
        end
    end)
end

local function ApplyLook(frame)
    local icon = frame.icon
    if not icon then return end
    local out = frame.bbfRangeOut
    if not out and not frame.bbfRangeStyled then return end
    local overlayMode, c, desat = GetRangeLook()
    local borderMode = BetterBlizzFramesDB.interruptIconRangeBorder and frame.border
    if borderMode then
        HookBorder(frame)
        frame.bbfRangeBorderColor = out and c or nil
        PaintBorder(frame)
    elseif frame.bbfRangeBorderColor then
        frame.bbfRangeBorderColor = nil
        PaintBorder(frame)
    end
    if out and not overlayMode and not borderMode then
        icon:SetVertexColor(c[1], c[2], c[3], c[4] or 1)
    else
        icon:SetVertexColor(1, 1, 1, 1)
    end
    icon:SetDesaturated(out and desat or false)
    if out and overlayMode and not borderMode then
        local overlay = GetOverlay(frame)
        overlay:SetVertexColor(c[1], c[2], c[3], c[4] or 0.35)
        overlay:Show()
    elseif frame.bbfRangeOverlay then
        frame.bbfRangeOverlay:Hide()
    end
    frame.bbfRangeStyled = out
end

local function IsCasting(frame)
    local castBar = frame:GetParent()
    return castBar and (castBar.casting or castBar.channeling) and frame:IsShown()
end

local function CheckFrame(frame)
    local spellID, unit = frame.bbfRangeSpell, frame.bbfRangeUnit
    local out = false
    if BetterBlizzFramesDB.interruptIconRangeColor and spellID and unit and UnitExists(unit) then
        out = IsOutOfRange(spellID, unit)
    end
    if out ~= frame.bbfRangeOut then
        frame.bbfRangeOut = out
        ApplyLook(frame)
    end
end

local function OnTick()
    local busy
    for frame in pairs(tracked) do
        if IsCasting(frame) then
            busy = true
            CheckFrame(frame)
        end
    end
    if not busy or not BetterBlizzFramesDB.interruptIconRangeColor then
        ticker:Cancel()
        ticker = nil
    end
end

local function StartTicker()
    if ticker then return end
    for frame in pairs(tracked) do
        if IsCasting(frame) then
            ticker = C_Timer.NewTicker(0.1, OnTick)
            return
        end
    end
end

function BBF.UpdateInterruptIconRange(frame, spellID, unit)
    if not frame or not frame.icon then return end
    tracked[frame] = true
    frame.bbfRangeSpell, frame.bbfRangeUnit = spellID, unit
    CheckFrame(frame)
    if BetterBlizzFramesDB.interruptIconRangeColor then
        StartTicker()
    end
end

function BBF.RefreshInterruptIconRange()
    local on = BetterBlizzFramesDB.interruptIconRangeColor
    for frame in pairs(tracked) do
        CheckFrame(frame)
        ApplyLook(frame)
    end
    if on then
        if not eventFrame then
            eventFrame = CreateFrame("Frame")
            eventFrame:SetScript("OnEvent", function()
                C_Timer.After(0, BBF.RefreshInterruptIconRange)
            end)
        end
        eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
        StartTicker()
    elseif eventFrame then
        eventFrame:UnregisterAllEvents()
    end
end
