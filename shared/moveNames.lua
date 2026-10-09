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
}

local boxes = {}
local boxesShown = false
local guideAlpha = 1

local function IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

local function Round(value)
    return math.floor(value * 2 + 0.5) / 2
end

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
    BBF.ApplyNameLayout(key)
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
    if not left or not top or IsSecret(left) or IsSecret(top) or IsSecret(width) or IsSecret(height) then
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
    BBF.ApplyNameLayout(box.key)
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
    local scale = EffectiveScale(fontString)
    local dx, dy = 0, 0
    if mode == "box" then
        local left, top = box:GetLeft(), box:GetTop()
        if left and top and not IsSecret(left) and not IsSecret(top) then
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
            BBF.ApplyNameLayout(self.key)
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
