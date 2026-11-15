local L = BBF.L

local PADDING = 2
local FILL_ALPHA = 0.2
local FILL_ALPHA_HOVER = 0.35
local PREVIEW_SIZE = 20

local GROUP_NAMES = { player = "Player", target = "Target", party = "Party" }

local function Add(list, region)
    if region then
        list[#list + 1] = region
    end
end

local function PlayerContext(frame)
    return frame.PlayerFrameContent.PlayerFrameContentContextual
end

local function TargetContext(frame)
    return frame.TargetFrameContent.TargetFrameContentContextual
end

local function PlayerLeader(frame)
    local c = PlayerContext(frame)
    return { c.LeaderIcon, c.GuideIcon }
end

local function PlayerRole(frame)
    return { PlayerContext(frame).RoleIcon }
end

local function PlayerPvp(frame)
    if BBF.isForever then
        return { frame.PlayerFrameContent.PlayerFrameContentMain.PvpBackgroundIcon }
    end
    local c = PlayerContext(frame)
    return { c.PrestigePortrait, c.PrestigeBadge, c.PVPIcon }
end

local function PlayerCombat(frame)
    return { PlayerContext(frame).AttackIcon }
end

local function PlayerPvpHome(frame)
    if BBF.isForever then
        return frame.PlayerFrameContent.PlayerFrameContentMain
    end
    return PlayerContext(frame)
end

local function TargetRegion(key)
    return function(frame)
        return { TargetContext(frame)[key] }
    end
end

local function TargetLeader(frame)
    local c = TargetContext(frame)
    return { c.LeaderIcon, c.GuideIcon }
end

local function TargetPvp(frame)
    local c = TargetContext(frame)
    if BBF.isForever then
        return { c.PvpBackgroundIcon }
    end
    return { c.PrestigePortrait, c.PrestigeBadge, c.PvpIcon }
end

local function TargetThreat(frame)
    return { TargetContext(frame).NumericalThreat }
end

local function PartyLeader(frame)
    local overlay = frame.PartyMemberOverlay
    return { overlay.LeaderIcon, overlay.GuideIcon }
end

local function PartyRole(frame)
    local list = { frame.PartyMemberOverlay.RoleIcon }
    Add(list, frame.bbfModernRole and frame.bbfModernRole.roleIcon)
    Add(list, frame.bbfMicroRole and frame.bbfMicroRole.roleIcon)
    return list
end

local function PartyPvp(frame)
    return { frame.PartyMemberOverlay.PVPIcon }
end

local function PartyPvpHome(frame)
    return frame.PartyMemberOverlay
end

local function PartyReadyCheck(frame)
    return { frame.ReadyCheck }
end

local function PartyNotPresent(frame)
    return { frame.NotPresentIcon }
end

local PVP_PREVIEW = BBF.isForever and { atlas = "UI-HUD-UnitFrame-SmallCircle-Alliance" } or { atlas = "honorsystem-portrait-neutral" }

BBF.IconTweakElements = {
    player = {
        { key = "Leader", label = L["Icon_Leader"], regions = PlayerLeader, preview = { atlas = "UI-HUD-UnitFrame-Player-Group-LeaderIcon" } },
        { key = "Role", label = L["Icon_Role"], regions = PlayerRole, preview = { atlas = "roleicon-tiny-tank" } },
        { key = "Pvp", label = L["Icon_Pvp"], regions = PlayerPvp, home = PlayerPvpHome, preview = PVP_PREVIEW },
        { key = "Combat", label = L["Icon_Combat"], regions = PlayerCombat, preview = { atlas = "UI-HUD-UnitFrame-Player-CombatIcon" } },
    },
    target = {
        { key = "Leader", label = L["Icon_Leader"], regions = TargetLeader, preview = { atlas = "UI-HUD-UnitFrame-Player-Group-LeaderIcon" } },
        { key = "RaidTarget", label = L["Icon_Raid_Marker"], regions = TargetRegion("RaidTargetIcon"), preview = { raidTarget = 8 }, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8" },
        { key = "Quest", label = L["Icon_Quest"], regions = TargetRegion("QuestIcon"), preview = { atlas = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Quest" } },
        { key = "Pvp", label = L["Icon_Pvp"], regions = TargetPvp, home = TargetContext, preview = PVP_PREVIEW },
        { key = "Threat", label = L["Icon_Threat"], regions = TargetThreat, preview = { texture = "Interface\\TargetingFrame\\NumericThreatBorder", coords = { 0, 0.765625, 0, 0.5625 } } },
    },
    party = {
        { key = "Leader", label = L["Icon_Leader"], regions = PartyLeader, preview = { atlas = "UI-HUD-UnitFrame-Player-Group-LeaderIcon" } },
        { key = "Role", label = L["Icon_Role"], regions = PartyRole, preview = { atlas = "roleicon-tiny-tank" } },
        { key = "Pvp", label = L["Icon_Pvp"], regions = PartyPvp, home = PartyPvpHome, preview = { atlas = "ui-hud-unitframe-player-pvp-ffaicon" } },
        { key = "ReadyCheck", label = L["Icon_Ready_Check"], regions = PartyReadyCheck, preview = { texture = "Interface\\RaidFrame\\ReadyCheck-Ready" } },
        { key = "NotPresent", label = L["Icon_Not_Present"], regions = PartyNotPresent, preview = { atlas = "groupfinder-eye-single" } },
    },
}

if not BBF.isForever then
    table.insert(BBF.IconTweakElements.target, 3, { key = "Boss", label = L["Icon_Rare"], regions = TargetRegion("BossIcon"), preview = { atlas = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare-Star" } })
    table.insert(BBF.IconTweakElements.target, 5, { key = "PetBattle", label = L["Icon_Pet_Battle"], regions = TargetRegion("PetBattleIcon"), preview = { texture = "Interface\\TargetingFrame\\PetBadge-Beast" } })
end

local function PlayerLevel()
    return { PlayerLevelText }
end

local function TargetLevel(frame)
    return { frame.TargetFrameContent.TargetFrameContentMain.LevelText }
end

local function PartyLevel(frame)
    local list = {}
    Add(list, frame.bbfLevelText)
    return list
end

local LEVEL_PREVIEW = { atlas = "guild-levelring" }
for group, regions in pairs({ player = PlayerLevel, target = TargetLevel, party = PartyLevel }) do
    local elements = BBF.IconTweakElements[group]
    elements[#elements + 1] = { key = "Level", label = L["Level"], level = true, regions = regions, preview = LEVEL_PREVIEW }
end

function BBF.IconTweakMenuIcon(element)
    return element.icon or element.preview.atlas or element.preview.texture
end

function BBF.IconTweakKey(group, key, axis)
    return "iconTweak" .. GROUP_NAMES[group] .. key .. axis
end

local function Values(group, key)
    local db = BetterBlizzFramesDB
    if not db.unitFrameIconTweaks then return 0, 0, 1 end
    local prefix = "iconTweak" .. GROUP_NAMES[group] .. key
    return db[prefix .. "X"], db[prefix .. "Y"], db[prefix .. "Scale"]
end

function BBF.IconTweakMoved(group, key)
    local x, y = Values(group, key)
    return x ~= 0 or y ~= 0
end

local function GroupFrames(group)
    if group == "player" then
        return { PlayerFrame }
    elseif group == "target" then
        return { TargetFrame, FocusFrame }
    end
    local list = {}
    for i = 1, 4 do
        Add(list, PartyFrame and PartyFrame["MemberFrame" .. i])
    end
    return list
end

local function RelativeTo(region)
    local base = region.bbfIconPin or region.bbfIconBase
    if base then
        return base[2]
    end
    local _, relativeTo = region:GetPoint(1)
    return relativeTo
end

local function Follows(region)
    local relativeTo = RelativeTo(region)
    for _, other in ipairs(region.bbfIconSiblings) do
        if other ~= region and other == relativeTo then
            return true
        end
    end
    return false
end

local function ScreenCenter(region)
    local x, y = region:GetCenter()
    if not x or not y or issecretvalue(x) or issecretvalue(y) then return end
    local scale = region:GetEffectiveScale()
    return x * scale, y * scale
end

local function ScaledPoint(region, base, scale, x, y)
    BBF.SetNameMoveScale(region, 1)
    region:SetPoint(base[1], base[2], base[3], x, y)
    local wantX, wantY = ScreenCenter(region)
    BBF.SetNameMoveScale(region, scale)
    local sx, sy = BBF.ScaleNamePoint(base[1], "CENTER", region:GetWidth(), region:GetHeight(), scale, x, y)
    if not wantX then
        return sx, sy
    end
    region:SetPoint(base[1], base[2], base[3], sx, sy)
    local gotX, gotY = ScreenCenter(region)
    region:SetPoint(base[1], base[2], base[3], sx + 1, sy + 1)
    local stepX, stepY = ScreenCenter(region)
    if not gotX or not stepX then
        return sx, sy
    end
    local perX, perY = stepX - gotX, stepY - gotY
    if perX == 0 or perY == 0 then
        return sx, sy
    end
    return sx + (wantX - gotX) / perX, sy + (wantY - gotY) / perY
end

local function ApplyIcon(region)
    local base = region.bbfIconPin or region.bbfIconBase
    local dx, dy, scale = Values(region.bbfIconGroup, region.bbfIconKey)
    BBF.SetNameMoveScale(region, scale)
    region.bbfIconApplying = true
    region:ClearAllPoints()
    local box = region.bbfIconDragBox
    if box and not Follows(region) then
        region:SetPoint("CENTER", box, "CENTER", (box.extraX or 0) / scale, (box.extraY or 0) / scale)
    else
        local x, y = base[4], base[5] + (not region.bbfIconPin and region.bbfIconShiftY or 0)
        if not Follows(region) then
            x, y = x + dx, y + dy
        end
        if scale ~= 1 then
            x, y = ScaledPoint(region, base, scale, x, y)
        end
        region:SetPoint(base[1], base[2], base[3], x, y)
    end
    region.bbfIconApplying = nil
end

local function StoreBase(region, point, relativeTo, relativePoint, x, y)
    local base = region.bbfIconBase
    base[1], base[2], base[3], base[4], base[5] = point, relativeTo or region:GetParent(), relativePoint or point, x or 0, y or 0
end

local function HookIcon(region)
    if region.bbfIconHooked then return true end
    local point, relativeTo, relativePoint, x, y = region:GetPoint(1)
    if not point or issecretvalue(x) or issecretvalue(y) then return false end
    local shift = region.bbfShiftY or 0
    region.bbfShiftY = nil
    region.bbfIconShiftY = shift ~= 0 and shift or nil
    region.bbfIconBase = {}
    StoreBase(region, point, relativeTo, relativePoint, x, (y or 0) - shift)
    region.bbfIconHooked = true
    hooksecurefunc(region, "SetPoint", function(self, p, rel, rp, px, py)
        if self.bbfIconApplying then return end
        if type(rel) == "number" then
            rel, rp, px, py = nil, p, rel, rp
        end
        if issecretvalue(px) or issecretvalue(py) then return end
        StoreBase(self, p, rel, rp, px, py)
        ApplyIcon(self)
    end)
    return true
end

function BBF.ShiftIconY(region, shift)
    region.bbfIconShiftY = shift ~= 0 and shift or nil
    ApplyIcon(region)
end

function BBF.PinIconPoint(region, group, key, point, relativeTo, relativePoint, x, y)
    if not point and not region.bbfIconPin then return end
    region.bbfIconGroup, region.bbfIconKey = group, key
    region.bbfIconSiblings = region.bbfIconSiblings or { region }
    if not HookIcon(region) then return end
    region.bbfIconPin = point and { point, relativeTo, relativePoint, x, y } or nil
    ApplyIcon(region)
end

local function UpdateElement(group, element, frame, force)
    local list = element.regions(frame)
    local dx, dy, scale = Values(group, element.key)
    local active = force or dx ~= 0 or dy ~= 0 or scale ~= 1
    for _, region in ipairs(list) do
        region.bbfIconGroup, region.bbfIconKey, region.bbfIconSiblings = group, element.key, list
        if active then
            HookIcon(region)
        end
        if region.bbfIconHooked then
            ApplyIcon(region)
        end
    end
    return list
end

local function UpdateGroup(group)
    for _, frame in ipairs(GroupFrames(group)) do
        for _, element in ipairs(BBF.IconTweakElements[group]) do
            if not element.level then
                UpdateElement(group, element, frame)
            end
        end
    end
end

function BBF.UpdatePartyIconTweaks()
    UpdateGroup("party")
end

function BBF.UpdateIconTweaks()
    for group in pairs(BBF.IconTweakElements) do
        UpdateGroup(group)
    end
    if BBF.UpdateLevelUnderAttackIcon then
        BBF.UpdateLevelUnderAttackIcon()
    end
    if BBF.RefreshIconMover then
        BBF.RefreshIconMover()
    end
end

local mover = { guideAlpha = 1, borrowed = {} }

local function ReturnBorrowed()
    for region in pairs(mover.borrowed) do
        mover.borrowed[region] = nil
        region.bbfIconBorrowing = true
        region:SetParent(BBF.hiddenFrame)
        region.bbfIconBorrowing = nil
    end
end

local function Borrow(region, home)
    if region:GetParent() ~= BBF.hiddenFrame then return end
    if not region.bbfIconParentHooked then
        region.bbfIconParentHooked = true
        hooksecurefunc(region, "SetParent", function(self)
            if not self.bbfIconBorrowing then
                mover.borrowed[self] = nil
            end
        end)
    end
    mover.borrowed[region] = true
    region.bbfIconBorrowing = true
    region:SetParent(region.bbfPvpHome or home)
    region.bbfIconBorrowing = nil
end

local function MoverFrame(group)
    return GroupFrames(group)[1]
end

local function FindElement(group, key)
    for _, element in ipairs(BBF.IconTweakElements[group]) do
        if element.key == key then
            return element
        end
    end
end

local function Anchors(list)
    local anchors = {}
    for _, region in ipairs(list) do
        if not Follows(region) then
            anchors[#anchors + 1] = region
        end
    end
    return anchors
end

local function EffectiveScale(region)
    if region.GetEffectiveScale then
        return region:GetEffectiveScale()
    end
    return region:GetParent():GetEffectiveScale() * region:GetScale()
end

local function Round(value)
    return math.floor(value * 2 + 0.5) / 2
end

local function SetPreview(box, element, region)
    local preview = box.preview
    local info = element.preview
    local coords = info.coords
    preview:SetTexCoord(coords and coords[1] or 0, coords and coords[2] or 1, coords and coords[3] or 0, coords and coords[4] or 1)
    if info.raidTarget then
        preview:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        SetRaidTargetIconTexture(preview, info.raidTarget)
    elseif info.atlas then
        preview:SetAtlas(info.atlas)
    else
        preview:SetTexture(info.texture)
    end
    local border = region.bbfBorder
    if border then
        preview:SetDesaturated(border:IsDesaturated())
        preview:SetVertexColor(border:GetVertexColor())
    else
        preview:SetDesaturated(false)
        preview:SetVertexColor(1, 1, 1)
    end
    preview:ClearAllPoints()
    local width = region:GetWidth()
    if issecretvalue(width) or width > 1 then
        preview:SetAllPoints(region)
    else
        local point = region:GetPoint(1) or "CENTER"
        preview:SetSize(PREVIEW_SIZE, PREVIEW_SIZE)
        preview:SetPoint(point, region, point)
    end
    local shown = region:IsShown()
    preview:SetShown(not element.level and (issecretvalue(shown) or not shown))
end

local function AnchorBox(box)
    box:ClearAllPoints()
    box:SetPoint("TOPLEFT", box.preview, "TOPLEFT", -PADDING, PADDING)
    box:SetPoint("BOTTOMRIGHT", box.preview, "BOTTOMRIGHT", PADDING, -PADDING)
end

local function UpdateBoxVisibility()
    local box = mover.box
    if not box then return end
    local owner = mover.group and MoverFrame(mover.group)
    box:SetShown(mover.shown and owner and owner:IsVisible() and box.region and true or false)
end

local LEVEL_PREFIX = { player = "levelTweakPlayer", target = "levelTweakTarget", party = "levelTweakParty" }

function BBF.IconTweakSliderKey(group, element, axis)
    if element.level then
        return LEVEL_PREFIX[group] .. axis
    end
    return BBF.IconTweakKey(group, element.key, axis)
end

local function MoverKeys()
    local element = FindElement(mover.group, mover.key)
    return element, BBF.IconTweakSliderKey(mover.group, element, "X"), BBF.IconTweakSliderKey(mover.group, element, "Y")
end

local function Save(x, y)
    local db = BetterBlizzFramesDB
    local element, xKey, yKey = MoverKeys()
    db[xKey] = Round(x)
    db[yKey] = Round(y)
    if not db.unitFrameIconTweaks and BBF.iconTweaksCheckbox then
        BBF.iconTweaksCheckbox:Click()
    end
    if element.level then
        BBF.UpdateLevelTweaks()
    end
    BBF.UpdateIconTweaks()
    if BBF.OnIconMoved then
        BBF.OnIconMoved(mover.group, mover.key)
    end
end

local function Nudge(dx, dy)
    local db = BetterBlizzFramesDB
    local _, xKey, yKey = MoverKeys()
    Save(db[xKey] + dx, db[yKey] + dy)
end

local function DragDelta(box)
    local scale = box.dragScale
    if box.dragging == "box" then
        local dx, dy = 0, 0
        local left, top = box:GetLeft(), box:GetTop()
        if left and top and not issecretvalue(left) and not issecretvalue(top) then
            local ratio = box:GetEffectiveScale() / scale
            dx, dy = (left - box.startLeft) * ratio, (top - box.startTop) * ratio
        end
        return dx + box.extraX, dy + box.extraY
    end
    local cursorX, cursorY = GetCursorPosition()
    return (cursorX - box.cursorX) / scale, (cursorY - box.cursorY) / scale
end

local function LevelDragTick(box)
    local dx, dy = DragDelta(box)
    dx, dy = Round(dx), Round(dy)
    if dx == box.lastDX and dy == box.lastDY then return end
    box.lastDX, box.lastDY = dx, dy
    local db = BetterBlizzFramesDB
    local _, xKey, yKey = MoverKeys()
    db[xKey], db[yKey] = box.startX + dx, box.startY + dy
    if not db.unitFrameIconTweaks and BBF.iconTweaksCheckbox then
        BBF.iconTweaksCheckbox:Click()
    end
    BBF.UpdateLevelTweaks()
end

local function StartLevelTick(box)
    local db = BetterBlizzFramesDB
    local _, xKey, yKey = MoverKeys()
    box.startX, box.startY = db[xKey], db[yKey]
    box.lastDX, box.lastDY = 0, 0
    box:SetScript("OnUpdate", LevelDragTick)
end

local function SetDragPin(box, pinned)
    for _, region in ipairs(box.anchors) do
        region.bbfIconDragBox = pinned and box or nil
        ApplyIcon(region)
    end
end

local function StartDrag(box)
    local left, top = box:GetLeft(), box:GetTop()
    local width, height = box:GetSize()
    box.dragScale = EffectiveScale(box.region) / (box.region.bbfMoveScale or 1)
    if not box.level then
        for _, region in ipairs(box.list) do
            HookIcon(region)
        end
        box.anchors = Anchors(box.list)
    end
    if not left or not top or issecretvalue(left) or issecretvalue(top) or issecretvalue(width) or issecretvalue(height) then
        box.cursorX, box.cursorY = GetCursorPosition()
        box.dragging = "cursor"
        if box.level then
            StartLevelTick(box)
        end
        return
    end
    box:ClearAllPoints()
    box:SetSize(width, height)
    box:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
    box.startLeft, box.startTop = left, top
    box.extraX, box.extraY = 0, 0
    if not box.level then
        SetDragPin(box, true)
    end
    box:StartMoving()
    box.dragging = "box"
    if box.level then
        StartLevelTick(box)
    end
end

local function StopDrag(box)
    local mode = box.dragging
    if not mode then return end
    box:StopMovingOrSizing()
    local dx, dy = DragDelta(box)
    box.dragging = nil
    if mode == "box" and not box.level then
        SetDragPin(box, false)
    end
    if box.level then
        box:SetScript("OnUpdate", nil)
        Save(box.startX + dx, box.startY + dy)
    else
        Nudge(dx, dy)
    end
    AnchorBox(box)
end

local arrowKeys = {
    UP = { 0, 1 },
    DOWN = { 0, -1 },
    LEFT = { -1, 0 },
    RIGHT = { 1, 0 },
}

local function CreateBox()
    local box = CreateFrame("Button", nil, UIParent)
    box:SetFrameStrata("FULLSCREEN_DIALOG")
    box:SetFrameLevel(600)
    box:SetMovable(true)
    box:SetClampedToScreen(false)
    box:EnableMouse(true)

    box.display = CreateFrame("Frame", nil, box)
    box.display:SetAlpha(mover.guideAlpha)
    box.preview = box:CreateTexture(nil, "ARTWORK")
    box.display:SetPoint("TOPLEFT", box.preview, "TOPLEFT", -PADDING, PADDING)
    box.display:SetPoint("BOTTOMRIGHT", box.preview, "BOTTOMRIGHT", PADDING, -PADDING)

    box.fill = box.display:CreateTexture(nil, "BACKGROUND")
    box.fill:SetAllPoints()
    box.fill:SetColorTexture(0, 0.75, 1, FILL_ALPHA)

    box.label = box.display:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    box.label:SetPoint("BOTTOMLEFT", box.display, "TOPLEFT", 0, 1)

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
            if not self.level then
                SetDragPin(self, true)
            end
            return
        end
        Nudge(arrow[1] * step, arrow[2] * step)
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
    box:Hide()
    return box
end

local function HookOwner(frame)
    if not frame or frame.bbfIconMoverHooked then return end
    frame.bbfIconMoverHooked = true
    frame:HookScript("OnShow", UpdateBoxVisibility)
    frame:HookScript("OnHide", UpdateBoxVisibility)
end

function BBF.RefreshIconMover()
    local box = mover.box
    if not box or not mover.shown or box.dragging then return end
    ReturnBorrowed()
    local frame = MoverFrame(mover.group)
    local element = FindElement(mover.group, mover.key)
    if not frame or not element then
        box.region = nil
        UpdateBoxVisibility()
        return
    end
    HookOwner(frame)
    box.level = element.level
    box.list = element.regions(frame)
    for _, region in ipairs(box.list) do
        region.bbfIconGroup, region.bbfIconKey, region.bbfIconSiblings = mover.group, element.key, box.list
        if element.home then
            Borrow(region, element.home(frame))
        end
    end
    box.anchors = Anchors(box.list)
    box.region = box.anchors[1]
    if not box.region then
        UpdateBoxVisibility()
        return
    end
    for _, region in ipairs(box.anchors) do
        if region:GetAlpha() > 0 then
            box.region = region
            break
        end
    end
    box.label:SetText(element.label)
    SetPreview(box, element, box.region)
    AnchorBox(box)
    UpdateBoxVisibility()
end

function BBF.ShowIconMover(group, key)
    mover.box = mover.box or CreateBox()
    mover.group, mover.key, mover.shown = group, key, true
    BBF.RefreshIconMover()
end

function BBF.UpdateIconMoverGuideAlpha(alpha)
    mover.guideAlpha = tonumber(alpha) or 1
    if mover.box then
        mover.box.display:SetAlpha(mover.guideAlpha)
    end
end

function BBF.HideIconMover()
    mover.shown = false
    ReturnBorrowed()
    UpdateBoxVisibility()
end
