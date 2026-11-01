local L = BBF.L

local PADDING = 4
local FILL_ALPHA = 0.2
local FILL_ALPHA_HOVER = 0.35

local nameLabels = {
    player = L["Player"],
    target = L["Target"],
    focus = L["Focus"],
    targetToT = L["Target_ToT"],
    focusToT = L["Focus_ToT"],
    pet = L["Pet"],
    party = L["Party"],
}

local PARTY_PREFIX = "moveNameParty"
if BBF.nameMovePrefix then
    BBF.nameMovePrefix.party = PARTY_PREFIX
end
if BBF.nameMoveSliders then
    BBF.nameMoveSliders[PARTY_PREFIX .. "X"] = true
    BBF.nameMoveSliders[PARTY_PREFIX .. "Y"] = true
    BBF.nameMoveSliders[PARTY_PREFIX .. "Width"] = true
    BBF.nameMoveSliders[PARTY_PREFIX .. "Scale"] = true
end

local boxes = {}
local boxesShown = false
local guideAlpha = 1

local function Fraction(point, low, high)
    if not point then return 0.5 end
    if point:find(low) then return 0 end
    if point:find(high) then return 1 end
    return 0.5
end

function BBF.GetNameMoveScale(prefix)
    local db = BetterBlizzFramesDB
    local scale = prefix and db and db.moveNames and tonumber(db[prefix .. "Scale"]) or 1
    return scale > 0 and scale or 1
end

function BBF.SetNameMoveScale(fontString, scale)
    if scale == 1 and not fontString.bbfMoveScale then return end
    if not fontString.bbfScaleHooked then
        fontString.bbfScaleHooked = true
        fontString.bbfBaseScale = fontString:GetScale()
        hooksecurefunc(fontString, "SetScale", function(self, value)
            if self.bbfScaling then return end
            self.bbfBaseScale = value
            if self.bbfMoveScale then
                self.bbfScaling = true
                self:SetScale(value * self.bbfMoveScale)
                self.bbfScaling = nil
            end
        end)
    end
    fontString.bbfMoveScale = scale ~= 1 and scale or nil
    fontString.bbfScaling = true
    fontString:SetScale(fontString.bbfBaseScale * scale)
    fontString.bbfScaling = nil
end

function BBF.ScaleNamePoint(point, justify, width, height, scale, x, y)
    local grow = scale - 1
    if width and not issecretvalue(width) then
        x = x + (Fraction(point, "LEFT", "RIGHT") - Fraction(justify, "LEFT", "RIGHT")) * grow * width
    end
    if height and not issecretvalue(height) then
        y = y + (Fraction(point, "BOTTOM", "TOP") - 0.5) * grow * height
    end
    return x / scale, y / scale
end

function BBF.ScaleNameBox(justify, width, height, scale, left, top, right, bottom)
    local grow = scale - 1
    if width and not issecretvalue(width) then
        local pivot = Fraction(justify, "LEFT", "RIGHT")
        left = left - pivot * grow * width
        right = right + (1 - pivot) * grow * width
    end
    if height and not issecretvalue(height) then
        top = top + grow * height / 2
        bottom = bottom - grow * height / 2
    end
    return left / scale, top / scale, right / scale, bottom / scale
end

local function Round(value)
    return math.floor(value * 2 + 0.5) / 2
end

local function PartyFrames()
    local list = {}
    for i = 1, 4 do
        local frame = PartyFrame and PartyFrame["MemberFrame" .. i] or _G["PartyMemberFrame" .. i]
        if frame and frame.bbfName then
            list[#list + 1] = frame
        end
    end
    return list
end

local alignJustify = { Left = "LEFT", Center = "CENTER", Right = "RIGHT" }
local edgeOffset = { TOP = 0.5, BOTTOM = -0.5 }

local function PartySettings()
    local db = BetterBlizzFramesDB
    if not db or not db.moveNames then return 0, 0, 0 end
    local p = PARTY_PREFIX
    local justify = db.centerNames and "CENTER" or alignJustify[db[p .. "Align"]]
    return tonumber(db[p .. "X"]) or 0, tonumber(db[p .. "Y"]) or 0, tonumber(db[p .. "Width"]) or 0,
        justify, db[p .. "MultiLine"] and true or false, db[p .. "GrowDown"] and "TOP" or "BOTTOM",
        BBF.GetNameMoveScale(p)
end

local function ToEdge(point, y, height, edge)
    local vertical = point:match("^TOP") or point:match("^BOTTOM") or ""
    local horizontal = point:sub(#vertical + 1)
    if horizontal == "CENTER" then
        horizontal = ""
    end
    return edge .. horizontal, y + ((edgeOffset[edge] or 0) - (edgeOffset[vertical] or 0)) * height
end

local function MultiLineNudge(fontString, height, edge)
    local _, fontHeight = fontString:GetFont()
    if not height or not fontHeight then return 0 end
    local nudge = (height - fontHeight) / 2
    return edge == "BOTTOM" and nudge or -nudge
end

local function StorePartyBase(fontString, point, relativeTo, relativePoint, x, y)
    local base = fontString.bbfPartyBase
    if not base then
        base = {}
        fontString.bbfPartyBase = base
    end
    base[1], base[2], base[3], base[4], base[5] = point, relativeTo, relativePoint, x, y
end

local function ApplyPartyName(fontString)
    local owner = fontString.bbfNameAreaOwner
    if owner and BBF.NameAreaResolve and BBF.NameAreaResolve(owner) then
        BBF.ApplyNameArea(owner)
        return
    end
    local base = fontString.bbfPartyBase
    if not base then return end
    local box = fontString.bbfDragBox
    local dx, dy, dw, justify, multiLine, edge, scale = PartySettings()
    scale = scale or 1
    local active = box or dx ~= 0 or dy ~= 0 or dw ~= 0 or justify or multiLine or scale ~= 1
    if not active and not fontString.bbfPartyMoved then return end
    fontString.bbfPartyApplying = true
    fontString:ClearAllPoints()
    if box then
        local moveScale = fontString.bbfMoveScale or 1
        local extraX, extraY = (box.extraX or 0) / moveScale, (box.extraY or 0) / moveScale
        local inset = box.inset * box:GetEffectiveScale() / fontString:GetEffectiveScale()
        fontString:SetPoint("TOPLEFT", box, "TOPLEFT", inset + extraX, -inset + extraY)
        fontString:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -inset + extraX, inset + extraY)
    else
        local height = fontString.bbfPartyBaseHeight
        local point, x, y = base[1], base[4] + dx, base[5] + dy
        if multiLine and height then
            point, y = ToEdge(point, y, height, edge)
            y = y + MultiLineNudge(fontString, height, edge)
        end
        local width = fontString.bbfPartyBaseWidth and math.max(fontString.bbfPartyBaseWidth + dw, 10)
        BBF.SetNameMoveScale(fontString, scale)
        if scale ~= 1 then
            x, y = BBF.ScaleNamePoint(point, justify or fontString.bbfPartyBaseJustify, width, not multiLine and height, scale, x, y)
        end
        fontString:SetPoint(point, base[2], base[3], x, y)
        if width then
            fontString:SetWidth(width)
        end
        fontString:SetWordWrap(multiLine)
        if fontString.SetMaxLines then
            fontString:SetMaxLines(multiLine and 3 or 0)
        end
        if multiLine then
            fontString:SetHeight(0)
        elseif height then
            fontString:SetHeight(height)
        end
        fontString.bbfMultiLine = multiLine or nil
        local wanted = justify or fontString.bbfPartyBaseJustify
        if wanted and fontString.bbfPartyLaidJustify ~= wanted then
            fontString.bbfPartyLaidJustify = wanted
            fontString:SetJustifyH(wanted)
            local text = fontString:GetText()
            fontString:SetText("")
            fontString:SetText(text)
        end
    end
    fontString.bbfPartyMoved = active and true or nil
    fontString.bbfPartyApplying = nil
end

local function HookPartyName(fontString)
    if fontString.bbfPartyHooked then return end
    fontString.bbfPartyHooked = true
    local point, relativeTo, relativePoint, x, y = fontString:GetPoint(1)
    if point and not issecretvalue(x) and not issecretvalue(y) then
        StorePartyBase(fontString, point, relativeTo, relativePoint or point, x or 0, y or 0)
    end
    local width, height = fontString:GetWidth(), fontString:GetHeight()
    if width and not issecretvalue(width) then
        fontString.bbfPartyBaseWidth = width
    end
    if height and not issecretvalue(height) and height > 0 then
        fontString.bbfPartyBaseHeight = height
    end
    fontString.bbfPartyBaseJustify = fontString:GetJustifyH()
    hooksecurefunc(fontString, "SetPoint", function(self, p, rel, rp, px, py)
        if self.bbfPartyApplying or self.bbfNameBoxPlacing then return end
        if type(rel) == "number" then
            rel, rp, px, py = self:GetParent(), p, rel, rp
        end
        if issecretvalue(px) or issecretvalue(py) then return end
        StorePartyBase(self, p, rel or self:GetParent(), rp or p, px or 0, py or 0)
        ApplyPartyName(self)
    end)
    hooksecurefunc(fontString, "SetWidth", function(self, w)
        if self.bbfPartyApplying or self.bbfNameBoxPlacing or issecretvalue(w) then return end
        self.bbfPartyBaseWidth = w
        ApplyPartyName(self)
    end)
    hooksecurefunc(fontString, "SetHeight", function(self, h)
        if self.bbfPartyApplying or self.bbfNameBoxPlacing or issecretvalue(h) or not h or h <= 0 then return end
        self.bbfPartyBaseHeight = h
        ApplyPartyName(self)
    end)
    hooksecurefunc(fontString, "SetJustifyH", function(self, j)
        if self.bbfPartyApplying or self.bbfNameBoxPlacing then return end
        self.bbfPartyBaseJustify = j
        self.bbfPartyLaidJustify = nil
        ApplyPartyName(self)
    end)
end

function BBF.ApplyPartyNames()
    for _, frame in ipairs(PartyFrames()) do
        HookPartyName(frame.bbfName)
        ApplyPartyName(frame.bbfName)
    end
end

local function ApplyKey(key)
    if key == "party" then
        BBF.ApplyPartyNames()
    else
        BBF.ApplyNameLayout(key)
    end
end

if BBF.nameLayoutSettings then
    BBF.nameLayoutSettings[PARTY_PREFIX .. "MultiLine"] = true
    BBF.nameLayoutSettings[PARTY_PREFIX .. "GrowDown"] = true
end

if BBF.NameAlignForced then
    local forced = BBF.NameAlignForced
    BBF.NameAlignForced = function(key, ...)
        if key == "party" then
            return BetterBlizzFramesDB and BetterBlizzFramesDB.centerNames and true or false
        end
        return forced(key, ...)
    end
end

if BBF.GetNameJustify then
    local getJustify = BBF.GetNameJustify
    BBF.GetNameJustify = function(key, ...)
        if key == "party" then
            local party1 = PartyFrames()[1]
            return party1 and (party1.bbfName.bbfPartyBaseJustify or party1.bbfName:GetJustifyH())
        end
        return getJustify(key, ...)
    end
end

if BBF.RefreshNameLayouts then
    local refresh = BBF.RefreshNameLayouts
    BBF.RefreshNameLayouts = function(...)
        refresh(...)
        BBF.ApplyPartyNames()
    end
end

local partyLogin = CreateFrame("Frame")
partyLogin:RegisterEvent("PLAYER_LOGIN")
partyLogin:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    if BetterBlizzFramesDB and BetterBlizzFramesDB.moveNames then
        BBF.ApplyPartyNames()
    end
end)

local function EffectiveScale(region)
    if region.GetEffectiveScale then
        return region:GetEffectiveScale()
    end
    return region:GetParent():GetEffectiveScale() * (region.GetScale and region:GetScale() or 1)
end

local function Nudge(key, dx, dy)
    local db = BetterBlizzFramesDB
    local prefix = BBF.nameMovePrefix[key]
    db[prefix .. "X"] = Round((tonumber(db[prefix .. "X"]) or 0) + dx)
    db[prefix .. "Y"] = Round((tonumber(db[prefix .. "Y"]) or 0) + dy)
    ApplyKey(key)
    if BBF.UpdateNameFit then
        BBF.UpdateNameFit()
    end
    if BBF.OnNameMoved then
        BBF.OnNameMoved(key)
    end
end

local function AnchorBox(box)
    box:ClearAllPoints()
    box:SetPoint("TOPLEFT", box.fontString, "TOPLEFT", -PADDING, PADDING)
    box:SetPoint("BOTTOMRIGHT", box.fontString, "BOTTOMRIGHT", PADDING, -PADDING)
end

local function UpdateBoxVisibility(box)
    box:SetShown(boxesShown and box.owner:IsVisible() or false)
end

local function StartDrag(box)
    local left, top = box:GetLeft(), box:GetTop()
    local width, height = box:GetSize()
    if not left or not top or issecretvalue(left) or issecretvalue(top) or issecretvalue(width) or issecretvalue(height) then
        box.cursorX, box.cursorY = GetCursorPosition()
        box.dragging = "cursor"
        return
    end
    box:ClearAllPoints()
    box:SetSize(width, height)
    box:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
    box.startLeft, box.startTop = left, top
    box.extraX, box.extraY = 0, 0
    box.fontString.bbfDragBox = box
    ApplyKey(box.key)
    box:StartMoving()
    box.dragging = "box"
end

local function StopDrag(box)
    local mode = box.dragging
    if not mode then return end
    box.dragging = nil
    box:StopMovingOrSizing()
    local fontString = box.fontString
    fontString.bbfDragBox = nil
    if box.key == "party" then
        ApplyKey("party")
    end
    local scale = EffectiveScale(fontString) / (fontString.bbfMoveScale or 1)
    local dx, dy = 0, 0
    if mode == "box" then
        local left, top = box:GetLeft(), box:GetTop()
        if left and top and not issecretvalue(left) and not issecretvalue(top) then
            local ratio = box:GetEffectiveScale() / scale
            dx, dy = (left - box.startLeft) * ratio, (top - box.startTop) * ratio
        end
        dx, dy = dx + box.extraX, dy + box.extraY
        box.extraX, box.extraY = nil, nil
    else
        local cursorX, cursorY = GetCursorPosition()
        dx, dy = (cursorX - box.cursorX) / scale, (cursorY - box.cursorY) / scale
    end
    Nudge(box.key, dx, dy)
    AnchorBox(box)
end

local arrowKeys = {
    UP = { 0, 1 },
    DOWN = { 0, -1 },
    LEFT = { -1, 0 },
    RIGHT = { 1, 0 },
}

local function CreateBox(target)
    local box = CreateFrame("Button", nil, UIParent)
    box.key = target.key
    box.owner = target.frame
    box.fontString = target.frame.bbfName
    box.inset = PADDING
    box:SetFrameStrata("FULLSCREEN_DIALOG")
    box:SetFrameLevel(600)
    box:SetMovable(true)
    box:SetClampedToScreen(false)
    box:EnableMouse(true)

    box.display = CreateFrame("Frame", nil, box)
    box.display:SetPoint("TOPLEFT", box.fontString, "TOPLEFT", -PADDING, PADDING)
    box.display:SetPoint("BOTTOMRIGHT", box.fontString, "BOTTOMRIGHT", PADDING, -PADDING)

    box.display:SetAlpha(guideAlpha)

    box.fill = box.display:CreateTexture(nil, "BACKGROUND")
    box.fill:SetAllPoints()
    box.fill:SetColorTexture(0, 0.75, 1, FILL_ALPHA)

    box.label = box.display:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    box.label:SetPoint("BOTTOMLEFT", box.display, "TOPLEFT", 0, 1)
    box.label:SetText(nameLabels[target.key])

    box:SetScript("OnEnter", function(self)
        self.fill:SetColorTexture(0, 0.75, 1, FILL_ALPHA_HOVER)
        if not InCombatLockdown() then
            self:EnableKeyboard(true)
        end
    end)
    box:SetScript("OnLeave", function(self)
        self.fill:SetColorTexture(0, 0.75, 1, FILL_ALPHA)
        if not InCombatLockdown() then
            self:EnableKeyboard(false)
        end
    end)
    box:SetScript("OnKeyDown", function(self, key)
        local arrow = arrowKeys[key]
        if not arrow then
            self:SetPropagateKeyboardInput(true)
            return
        end
        self:SetPropagateKeyboardInput(false)
        local step = IsControlKeyDown() and 0.5 or 1
        if self.dragging == "box" then
            self.extraX = self.extraX + arrow[1] * step
            self.extraY = self.extraY + arrow[2] * step
            ApplyKey(self.key)
            return
        end
        Nudge(self.key, arrow[1] * step, arrow[2] * step)
    end)
    box:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            StartDrag(self)
        end
    end)
    box:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            StopDrag(self)
        end
    end)
    box:SetScript("OnHide", function(self)
        StopDrag(self)
        if not InCombatLockdown() then
            self:EnableKeyboard(false)
        end
    end)

    target.frame:HookScript("OnShow", function() UpdateBoxVisibility(box) end)
    target.frame:HookScript("OnHide", function() UpdateBoxVisibility(box) end)

    AnchorBox(box)
    box:Hide()
    return box
end

function BBF.ShowNameMoveBoxes(show)
    boxesShown = show and true or false
    if boxesShown and not next(boxes) and BBF.NameLayoutTargets then
        for _, target in ipairs(BBF.NameLayoutTargets) do
            if target.frame and target.frame.bbfName then
                boxes[target.key] = CreateBox(target)
            end
        end
        local party1 = PartyFrames()[1]
        if party1 then
            BBF.ApplyPartyNames()
            boxes.party = CreateBox({ key = "party", frame = party1 })
        end
    end
    for _, box in pairs(boxes) do
        if boxesShown then
            AnchorBox(box)
        end
        UpdateBoxVisibility(box)
    end
end

function BBF.UpdateNameMoveGuideAlpha(alpha)
    guideAlpha = tonumber(alpha) or 1
    for _, box in pairs(boxes) do
        box.display:SetAlpha(guideAlpha)
    end
end
