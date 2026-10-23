local floor, max, abs = math.floor, math.max, math.abs

local boxes = {}
local pending = false
local queued = false
local watcher
local hookedRegions = {}

BBF.PixelTextOffsets = {
    healthY = 0,
    manaY = -1,
    centerX = 0,
    leftPad = 2,
    rightPad = 3,
    manaRightPad = 4,
}

local function Round(v)
    return floor(v + 0.5)
end

local function Readable(...)
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if v == nil or issecretvalue(v) then return false end
    end
    return true
end

function BBF.PixelSize(region)
    local scale = (region or UIParent):GetEffectiveScale()
    if not Readable(scale) or scale == 0 then return 1 end
    return PixelUtil.GetPixelToUIUnitFactor() / scale
end

function BBF.PixelRound(value, region)
    if not value or value == 0 then return 0 end
    local px = BBF.PixelSize(region)
    return Round(value / px) * px
end

local function Place(box, s)
    box:ClearAllPoints()
    if s.link then
        box:SetPoint("TOPLEFT", s.link, "BOTTOMLEFT", s.linkX, s.linkY)
    else
        box:SetPoint("TOPLEFT", s.bar, "TOPLEFT", s.x + (s.dx or 0), s.y + (s.dy or 0))
    end
    box:SetSize(s.W or s.w, s.H or s.h)
end

local function AbsTop(region)
    local top = region:GetTop()
    if not Readable(top) then return end
    return top * region:GetEffectiveScale()
end

local Snap

local function MatchedTop(box, s, rawTop)
    local m = s.match
    local ref = m and m.ref()
    local r = ref and ref ~= box and boxes[ref]
    if not r then return rawTop end
    Snap(ref)
    local refFrameTop, ownFrameTop = AbsTop(m.refFrame), AbsTop(m.frame)
    if not (r.rawTopAbs and refFrameTop and ownFrameTop) then return rawTop end
    local rel = (r.rawTopAbs - refFrameTop) / m.refFrame:GetEffectiveScale()
    return (ownFrameTop + rel * m.frame:GetEffectiveScale()) / box:GetEffectiveScale()
end

Snap = function(box)
    local s = boxes[box]
    if not s then return end
    if InCombatLockdown() then
        pending = true
        Place(box, s)
        return
    end
    local dx, dy, W0, H0, link = s.dx, s.dy, s.W, s.H, s.link
    s.dx, s.dy, s.W, s.H, s.link = nil, nil, nil, nil, nil
    Place(box, s)
    local left, rawTop = box:GetLeft(), box:GetTop()
    if not Readable(left, rawTop) then
        s.dx, s.dy, s.W, s.H, s.link = dx, dy, W0, H0, link
        Place(box, s)
        return
    end
    s.rawTopAbs = rawTop * box:GetEffectiveScale()
    local top = MatchedTop(box, s, rawTop)
    local px = BBF.PixelSize(box)
    local L = Round(left / px) * px
    local T = floor(top / px + 1e-6) * px
    local W = max(1, Round(s.w / px)) * px
    local H = max(1, Round(s.h / px)) * px
    local parts = s.parts
    if parts then
        local gap = parts.gapPixels and parts[2] or Round(parts[2] / px)
        H = (max(1, Round(parts[1] / px)) + gap + max(1, Round(parts[3] / px))) * px
    end

    local above = s.above and s.above()
    local a = above and above ~= box and boxes[above]
    local linked
    if a then
        Snap(above)
        if a.snapBottom and abs(BBF.PixelSize(above) - px) < 1e-6 then
            local gap = s.gap or Round((a.rawBottom - top) / px)
            T = a.snapBottom - gap * px
            if abs(a.rawLeft - left) < px then
                L = a.snapLeft
            end
            linked = true
        end
    end
    if linked then
        s.link, s.linkX, s.linkY = above, L - a.snapLeft, T - a.snapBottom
    end

    s.dx, s.dy, s.W, s.H = L - left, T - rawTop, W, H
    s.rawLeft, s.rawBottom = left, top - s.h
    s.snapLeft, s.snapBottom = L, T - H
    Place(box, s)
end

local function SnapAll()
    for box, s in pairs(boxes) do
        if not s.above and not s.match then Snap(box) end
    end
    for box, s in pairs(boxes) do
        if s.match and not s.above then Snap(box) end
    end
    for box, s in pairs(boxes) do
        if s.above then Snap(box) end
    end
end

local function QueueSnap()
    if queued then return end
    queued = true
    C_Timer.After(0, function()
        queued = false
        SnapAll()
    end)
end

local function HookMoves(region)
    if not region or hookedRegions[region] then return end
    hookedRegions[region] = true
    hooksecurefunc(region, "SetPoint", QueueSnap)
    hooksecurefunc(region, "SetScale", QueueSnap)
end

local function EnsureWatcher()
    if watcher then return end
    watcher = CreateFrame("Frame")
    watcher:RegisterEvent("UI_SCALE_CHANGED")
    watcher:RegisterEvent("DISPLAY_SIZE_CHANGED")
    watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    watcher:RegisterEvent("PLAYER_REGEN_ENABLED")
    watcher:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_REGEN_ENABLED" then
            if not pending then return end
            pending = false
        end
        QueueSnap()
    end)
    if EventRegistry and EventRegistry.RegisterCallback then
        EventRegistry:RegisterCallback("EditMode.Exit", QueueSnap, watcher)
    end
    for _, frame in ipairs({ PlayerFrame, TargetFrame, FocusFrame, PetFrame, PartyFrame }) do
        HookMoves(frame)
    end
end

function BBF.PixelSnapBox(box, bar, x, y, w, h, parts)
    EnsureWatcher()
    local s = boxes[box] or {}
    boxes[box] = s
    s.bar, s.x, s.y, s.w, s.h, s.parts = bar, x, y, w, h, parts
    HookMoves(bar)
    HookMoves(bar:GetParent())
    Snap(box)
    QueueSnap()
end

function BBF.PixelLinkBelow(box, aboveFn, gap)
    local s = boxes[box]
    if not s then return end
    s.above, s.gap = aboveFn, gap
    Snap(box)
    QueueSnap()
end

function BBF.PixelMatchTop(box, refFn, frame, refFrame)
    local s = boxes[box]
    if not s then return end
    s.match = { ref = refFn, frame = frame, refFrame = refFrame }
    Snap(box)
    QueueSnap()
end

function BBF.AnchorPixelBarTexts(box, yKey, leftText, rightText, ...)
    if not box then return end
    local o = BBF.PixelTextOffsets
    local db = BetterBlizzFramesDB
    local temp
    if yKey == "healthY" then
        temp = db.tempHpYOffset
    else
        temp = db.tempManaYOffset
    end
    local y = o[yKey] + (temp or 0)
    if leftText then
        leftText:ClearAllPoints()
        leftText:SetPoint("LEFT", box, "LEFT", BBF.PixelRound(o.leftPad, leftText), BBF.PixelRound(y, leftText))
    end
    if rightText then
        rightText:ClearAllPoints()
        local pad = yKey == "healthY" and o.rightPad or o.manaRightPad
        rightText:SetPoint("RIGHT", box, "RIGHT", -BBF.PixelRound(pad, rightText), BBF.PixelRound(y, rightText))
    end
    for i = 1, select("#", ...) do
        local text = select(i, ...)
        if text then
            text:ClearAllPoints()
            text:SetPoint("CENTER", box, "CENTER", BBF.PixelRound(o.centerX, text), BBF.PixelRound(y, text))
        end
    end
end
