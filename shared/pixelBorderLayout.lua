local PIXEL_MASK = "Interface\\AddOns\\BetterBlizzFrames\\media\\masks\\pixelMask.png"

local GROUPS = {
    Main = { gap = 1 },
    ToT = { gap = 3 },
    Pet = { gap = 3 },
    Party = { gap = 4 },
}

local DEFAULTS = {
    Main = { SeparateWidth = false, HealthWidth = 130, HealthHeight = 22, ManaWidth = 130, ManaHeight = 8, ManaX = 0, ManaY = 0 },
    ToT = { SeparateWidth = false, HealthWidth = 65, HealthHeight = 15, ManaWidth = 65, ManaHeight = 7, ManaX = 0, ManaY = 2 },
    Pet = { SeparateWidth = false, HealthWidth = 65, HealthHeight = 15, ManaWidth = 65, ManaHeight = 7, ManaX = 0, ManaY = 2 },
    Party = { SeparateWidth = false, HealthWidth = 100, HealthHeight = 22, ManaWidth = 100, ManaHeight = 8, ManaX = 0, ManaY = 3.5 },
}
BBF.PixelBorderDefaults = DEFAULTS

BBF.pixelBorderSliders = { pixelBorderSize = true }
for group, values in pairs(DEFAULTS) do
    for key in pairs(values) do
        if key ~= "SeparateWidth" then
            BBF.pixelBorderSliders["pixelBorder" .. group .. key] = true
        end
    end
end

local function PixelSize(region)
    local scale = (region or UIParent):GetEffectiveScale()
    if not scale or issecretvalue(scale) or scale == 0 then return 1 end
    return PixelUtil.GetPixelToUIUnitFactor() / scale
end
BBF.PixelBorderPixelSize = PixelSize

local function Snap(value, px)
    return math.floor(value / px + 0.5) * px
end

local function Setting(group, key)
    local value = BetterBlizzFramesDB["pixelBorder" .. group .. key]
    if value == nil then return DEFAULTS[group][key] end
    return value
end

local function TotOwner(frame)
    if TargetFrame and frame == TargetFrame.totFrame then return TargetFrame end
    if FocusFrame and frame == FocusFrame.totFrame then return FocusFrame end
end

local function FrameInfo(frame)
    local db = BetterBlizzFramesDB
    if frame == PlayerFrame then
        return "Main", "TOPLEFT", 86, -41, db.hideUnitFramePlayerMana
    end
    if frame == TargetFrame or frame == FocusFrame then
        local hideMana = frame == TargetFrame and db.hideUnitFrameTargetMana or frame == FocusFrame and db.hideUnitFrameFocusMana
        return "Main", "TOPRIGHT", -86, -41, hideMana
    end
    if TotOwner(frame) then
        local owner = TotOwner(frame)
        local ownerMana = owner == FocusFrame and db.hideUnitFrameFocusMana or owner == TargetFrame and db.hideUnitFrameTargetMana
        return "ToT", "TOPRIGHT", -21, -10, db.hideUnitFrameTotMana or ownerMana
    end
    if frame == PetFrame then
        return "Pet", "TOPRIGHT", -19, -10, db.hideUnitFramePetMana or db.hideUnitFramePlayerMana
    end
    if frame and frame.PartyMemberOverlay then
        return "Party", "TOPLEFT", 45, -14, db.hideDefaultPartyFramesMana
    end
end

local function BorderSize()
    local size = tonumber(BetterBlizzFramesDB.pixelBorderSize) or 1
    return math.max(math.floor(size + 0.5), 1)
end

local function GridShift(frame, point, x, y)
    local anchorX = point == "TOPLEFT" and frame:GetLeft() or frame:GetRight()
    local anchorY = frame:GetTop()
    local scale = frame:GetEffectiveScale()
    if not anchorX or not anchorY or not scale or issecretvalue(anchorX) or issecretvalue(anchorY) or issecretvalue(scale) or scale == 0 then
        return 0, 0
    end
    local unit = PixelUtil.GetPixelToUIUnitFactor()
    local absX, absY = (anchorX + x) * scale, (anchorY + y) * scale
    return (math.floor(absX / unit + 0.5) * unit - absX) / scale, (math.floor(absY / unit + 0.5) * unit - absY) / scale
end

function BBF.PixelBorderGeometry(frame)
    local group, point, x, y, hideMana = FrameInfo(frame)
    if not group then return end
    local px = PixelSize(frame)
    local healthW = Snap(Setting(group, "HealthWidth"), px)
    local healthH = Snap(Setting(group, "HealthHeight"), px)
    local manaW = Setting(group, "SeparateWidth") and Snap(Setting(group, "ManaWidth"), px) or healthW
    local manaH = Snap(Setting(group, "ManaHeight"), px)
    local gap = Snap(GROUPS[group].gap, px)
    x, y = Snap(x, px), Snap(y, px)
    local shiftX, shiftY = GridShift(frame, point, x, y)
    x, y = x + shiftX, y + shiftY
    local outward = point == "TOPLEFT" and 1 or -1
    local manaX = x + Snap(Setting(group, "ManaX"), px) * outward
    local manaY = y - healthH - gap + Snap(Setting(group, "ManaY"), px)
    local health = { x = x, y = y, w = healthW, h = healthH }
    local mana = { x = manaX, y = manaY, w = manaW, h = manaH }
    local edge = px * BorderSize()
    local bleed = edge + px
    local function Bleed(rect)
        return { x = rect.x - bleed * outward, y = rect.y + bleed, w = rect.w + bleed * 2, h = rect.h + bleed * 2 }
    end
    return {
        group = group,
        point = point,
        edge = edge,
        bleed = bleed,
        manaShown = not hideMana,
        health = health,
        mana = mana,
        healthBar = Bleed(health),
        manaBar = Bleed(mana),
        below = { x = manaX, y = hideMana and (y - healthH - gap) or (manaY - manaH - gap), w = manaW, h = manaH },
    }
end

function BBF.PixelBorderMirrorLayout(frame)
    local g = BBF.PixelBorderGeometry(frame)
    if not g then return end
    return {
        point = { g.point, g.point, g.healthBar.x, g.healthBar.y }, width = g.healthBar.w, height = g.healthBar.h,
        glowOffset = -7, texts = false, pixel = true,
        mask = { texture = PIXEL_MASK, x = g.bleed, y = -g.bleed, width = g.health.w, height = g.health.h },
    }
end

local function GetBox(bar, owner, strata, key)
    local box = owner[key]
    if not box then
        box = CreateFrame("Frame", nil, owner)
        box.edges = {}
        for i = 1, 4 do
            local edge = box:CreateTexture(nil, "BORDER", nil, 4)
            edge:SetColorTexture(0, 0, 0, 1)
            if edge.SetSnapToPixelGrid then
                edge:SetSnapToPixelGrid(false)
                edge:SetTexelSnappingBias(0)
            end
            box.edges[i] = edge
        end
        box.emptyBg = box:CreateTexture(nil, "BACKGROUND")
        box.emptyBg:SetColorTexture(0, 0, 0, 0.45)
        box.emptyBg:SetAllPoints(box)
        box.emptyBg:Hide()
        owner[key] = box
    end
    if not bar.bbfPixelBg then
        bar.bbfPixelBg = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
        bar.bbfPixelBg:SetColorTexture(0, 0, 0, 0.45)
    end
    bar.bbfPixelBg:ClearAllPoints()
    bar.bbfPixelBg:SetAllPoints(box)
    box.bg = bar.bbfPixelBg
    bar.bbfPixelBox = box
    bar.BBFPositionFrame = box
    bar.BBFPixelBorder = box
    bar.pixelBorderBackground = bar.bbfPixelBg
    return box
end

local function Readable(...)
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if v == nil or issecretvalue(v) then return false end
    end
    return true
end

local function RaiseName(frame, level, strata)
    local name = frame.bbfName
    if not name or name:GetParent() == frame.noPortraitMode then return end
    local layer = frame.bbfPixelNameLayer
    if not layer then
        layer = CreateFrame("Frame", nil, frame)
        layer:SetAllPoints(frame)
        frame.bbfPixelNameLayer = layer
    end
    layer:SetFrameStrata(strata)
    layer:SetFrameLevel(level)
    if name:GetParent() ~= layer then
        name:SetParent(layer)
    end
end

local function StatusTexts(frame)
    local list = {}
    local health, mana = {}, {}
    if BBF.TextAreaTexts then health, mana = BBF.TextAreaTexts(frame) end
    for _, texts in ipairs({ health, mana }) do
        for _, text in pairs(texts) do list[#list + 1] = text end
    end
    if BBF.StatusTextExtraTexts then
        for _, text in ipairs(BBF.StatusTextExtraTexts(frame)) do list[#list + 1] = text end
    end
    return list
end

local function RaiseTexts(frame, level, strata)
    BBF.RunAfterCombat(function()
        for _, text in ipairs(StatusTexts(frame)) do
            local owner = text.bbfPixelTextOwner or text:GetParent()
            local ownerStrata, ownerLevel = owner:GetFrameStrata(), owner:GetFrameLevel()
            if Readable(ownerStrata, ownerLevel) and ownerStrata == strata and ownerLevel < level then
                text.bbfPixelTextOwner = owner
                local layer = owner.bbfPixelTextLayer
                if not layer then
                    layer = CreateFrame("Frame", nil, owner)
                    layer:SetAllPoints(owner)
                    owner.bbfPixelTextLayer = layer
                end
                layer:SetFrameLevel(level)
                if text:GetParent() ~= layer then
                    text:SetParent(layer)
                end
            end
        end
    end)
end

function BBF.LayerPixelBorderTexts(frame)
    local manaBox = frame and frame.bbfPixelManaBox
    if not BetterBlizzFramesDB.noPortraitPixelBorder or not manaBox then return end
    local strata, level = manaBox:GetFrameStrata(), manaBox:GetFrameLevel()
    if not Readable(strata, level) then return end
    RaiseTexts(frame, level + 1, strata)
end

local function LayerBoxes(frame, healthBar, manaBar, healthBox, manaBox)
    local healthStrata, healthLevel = healthBar:GetFrameStrata(), healthBar:GetFrameLevel()
    local manaStrata, manaLevel = manaBar:GetFrameStrata(), manaBar:GetFrameLevel()
    if not Readable(healthStrata, healthLevel, manaStrata, manaLevel) then return end
    healthBox:SetFrameStrata(healthStrata)
    healthBox:SetFrameLevel(healthLevel + 1)
    local wanted = math.max(manaLevel, healthLevel + 2)
    local usesParent = manaBar.IsUsingParentLevel and manaBar:IsUsingParentLevel()
    if manaLevel < wanted or usesParent then
        BBF.RunAfterCombat(function()
            if manaBar.IsUsingParentLevel and manaBar:IsUsingParentLevel() then
                manaBar:SetUsingParentLevel(false)
            end
            manaBar:SetFrameLevel(wanted)
        end)
    end
    manaBox:SetFrameStrata(manaStrata)
    manaBox:SetFrameLevel(wanted + 1)
    RaiseName(frame, wanted + 2, manaStrata)
    RaiseTexts(frame, wanted + 2, manaStrata)
end

local function PlaceBox(box, owner, point, rect)
    local px = PixelSize(box) * BorderSize()
    box:ClearAllPoints()
    box:SetPoint(point, owner, point, rect.x, rect.y)
    box:SetSize(rect.w, rect.h)
    local top, right, bottom, left = box.edges[1], box.edges[2], box.edges[3], box.edges[4]
    top:ClearAllPoints()
    top:SetPoint("BOTTOMLEFT", box, "TOPLEFT", -px, 0)
    top:SetPoint("BOTTOMRIGHT", box, "TOPRIGHT", px, 0)
    top:SetHeight(px)
    bottom:ClearAllPoints()
    bottom:SetPoint("TOPLEFT", box, "BOTTOMLEFT", -px, 0)
    bottom:SetPoint("TOPRIGHT", box, "BOTTOMRIGHT", px, 0)
    bottom:SetHeight(px)
    left:ClearAllPoints()
    left:SetPoint("TOPRIGHT", box, "TOPLEFT", 0, 0)
    left:SetPoint("BOTTOMRIGHT", box, "BOTTOMLEFT", 0, 0)
    left:SetWidth(px)
    right:ClearAllPoints()
    right:SetPoint("TOPLEFT", box, "TOPRIGHT", 0, 0)
    right:SetPoint("BOTTOMLEFT", box, "BOTTOMRIGHT", 0, 0)
    right:SetWidth(px)
end

local function SetBoxShown(box, shown, barShown)
    box:SetShown(shown)
    box.bg:SetShown(shown)
    box.emptyBg:SetShown(shown and barShown == false)
end

local function PlaceBar(bar, owner, point, rect)
    bar:ClearAllPoints()
    bar:SetPoint(point, owner, point, rect.x, rect.y)
    bar:SetSize(rect.w, rect.h)
end

local function Bars(frame)
    if frame == PlayerFrame then
        local main = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain
        local container = main.HealthBarsContainer
        return container.HealthBar, container.HealthBarMask, main.ManaBarArea.ManaBar, main.ManaBarArea.ManaBar.ManaBarMask, "MEDIUM"
    end
    if frame == TargetFrame or frame == FocusFrame then
        local manaBar = frame.TargetFrameContent.TargetFrameContentMain.ManaBar
        return BBF.HealthBar(frame), BBF.HealthBarMask(frame), manaBar, manaBar.ManaBarMask, "MEDIUM"
    end
    if TotOwner(frame) then
        return frame.HealthBar, frame.HealthBar.HealthBarMask, frame.ManaBar, frame.ManaBar.ManaBarMask, "FULLSCREEN"
    end
    if frame == PetFrame then
        return PetFrameHealthBar, PetFrameHealthBarMask, PetFrameManaBar, PetFrameManaBarMask, "MEDIUM"
    end
    if frame and frame.PartyMemberOverlay then
        local container = frame.HealthBarContainer
        return container.HealthBar, container.HealthBarMask, frame.ManaBar, frame.ManaBar.ManaBarMask, "MEDIUM"
    end
end

local function KeepEmptyManaBox(frame)
    return frame == TargetFrame or frame == FocusFrame
end

local function UpdateManaBox(frame)
    local _, _, manaBar = Bars(frame)
    local box = frame.bbfPixelManaBox
    if not box or not manaBar then return end
    local g = BBF.PixelBorderGeometry(frame)
    SetBoxShown(box, g.manaShown and (KeepEmptyManaBox(frame) or manaBar:IsShown()), manaBar:IsShown())
    if BBF.TextAreaActive and BBF.TextAreaActive(frame) then
        BBF.ApplyTextArea(frame)
    end
end

local function WatchMana(frame, manaBar)
    if manaBar.bbfPixelWatched then return end
    manaBar.bbfPixelWatched = true
    manaBar:HookScript("OnShow", function() UpdateManaBox(frame) end)
    manaBar:HookScript("OnHide", function() UpdateManaBox(frame) end)
end

local function SnapBars(frame, g, healthBar, manaBar)
    if frame == PlayerFrame then
        if PlayerFrame.state == "vehicle" then return end
        local container = healthBar:GetParent()
        PlaceBar(container, frame, g.point, g.healthBar)
        healthBar:ClearAllPoints()
        healthBar:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
        healthBar:SetSize(g.healthBar.w, g.healthBar.h)
        PlaceBar(manaBar, frame, g.point, g.manaBar)
    elseif frame == TargetFrame or frame == FocusFrame then
        if BBF.UpdateHealthbarMirror then
            BBF.UpdateHealthbarMirror(frame)
        end
        PlaceBar(manaBar, frame, g.point, g.manaBar)
    elseif frame.PartyMemberOverlay then
        local bars = BBF.PartyBars(frame)
        local container = frame.HealthBarContainer
        bars:ClearAllPoints(container)
        bars:SetPoint(container, g.point, frame, g.point, g.healthBar.x, g.healthBar.y)
        bars:SetSize(container, g.healthBar.w, g.healthBar.h)
        bars:ClearAllPoints(healthBar)
        bars:SetPoint(healthBar, "TOPLEFT", container, "TOPLEFT", 0, 0)
        bars:SetSize(healthBar, g.healthBar.w, g.healthBar.h)
        bars:ClearAllPoints(manaBar)
        bars:SetPoint(manaBar, g.point, frame, g.point, g.manaBar.x, g.manaBar.y)
        bars:SetSize(manaBar, g.manaBar.w, g.manaBar.h)
    else
        PlaceBar(healthBar, frame, g.point, g.healthBar)
        PlaceBar(manaBar, frame, g.point, g.manaBar)
    end
end

local function HitInsets(frame, g)
    if not frame.SetHitRectInsets then return end
    if not frame.bbfDefaultHitInsets then
        local l, r, t, b = frame:GetHitRectInsets()
        if not l or issecretvalue(l) or issecretvalue(r) or issecretvalue(t) or issecretvalue(b) then return end
        frame.bbfDefaultHitInsets = { l, r, t, b }
    end
    local width, height = frame:GetSize()
    if not width or issecretvalue(width) or issecretvalue(height) then return end
    local def = frame.bbfDefaultHitInsets
    local rects = { g.health }
    if g.manaShown then rects[2] = g.mana end
    local left, right, top, bottom = def[1], def[2], def[3], def[4]
    for _, rect in ipairs(rects) do
        local rectLeft = g.point == "TOPLEFT" and rect.x or width + rect.x - rect.w
        local rectTop = -rect.y
        left = math.min(left, rectLeft)
        right = math.min(right, width - rectLeft - rect.w)
        top = math.min(top, rectTop)
        bottom = math.min(bottom, height - rectTop - rect.h)
    end
    BBF.RunAfterCombat(function()
        frame:SetHitRectInsets(left, right, top, bottom)
    end)
end

function BBF.ApplyPixelBorderLayout(frame)
    local db = BetterBlizzFramesDB
    if not db.noPortraitPixelBorder or not frame then return end
    local g = BBF.PixelBorderGeometry(frame)
    local healthBar, healthMask, manaBar, manaMask, strata = Bars(frame)
    if not g or not healthBar or not manaBar then return end
    local healthBox = GetBox(healthBar, frame, strata, "bbfPixelHealthBox")
    local manaBox = GetBox(manaBar, frame, strata, "bbfPixelManaBox")
    PlaceBox(healthBox, frame, g.point, g.health)
    PlaceBox(manaBox, frame, g.point, g.mana)
    LayerBoxes(frame, healthBar, manaBar, healthBox, manaBox)
    SetBoxShown(healthBox, true)
    WatchMana(frame, manaBar)
    UpdateManaBox(frame)
    if frame.PartyMemberOverlay then
        SnapBars(frame, g, healthBar, manaBar)
    else
        BBF.RunAfterCombat(function()
            local now = BBF.PixelBorderGeometry(frame)
            local hb, _, mb = Bars(frame)
            SnapBars(frame, now, hb, mb)
        end)
    end
    HitInsets(frame, g)
    if BBF.NoPortraitSetBarMask then
        BBF.NoPortraitSetBarMask(healthBar, healthMask, true)
        BBF.NoPortraitSetBarMask(manaBar, manaMask, true)
        for _, pair in ipairs({ { healthMask, healthBox }, { manaMask, manaBox } }) do
            local mask, box = pair[1], pair[2]
            if mask then
                mask:ClearAllPoints()
                mask:SetPoint("TOPLEFT", box, "TOPLEFT", 0, 0)
                mask:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", 0, 0)
            end
        end
    end
    if frame == PlayerFrame and BBF.ApplyPixelBorderAltBar then
        BBF.ApplyPixelBorderAltBar()
    end
    BBF.HideMiniFrameBarArt(frame)
end

function BBF.PixelBorderBoxes(frame)
    if not BetterBlizzFramesDB.noPortraitPixelBorder or not frame then return end
    local health, mana = frame.bbfPixelHealthBox, frame.bbfPixelManaBox
    if health and mana then return health, mana end
end

function BBF.PixelBorderAltRect()
    local g = BBF.PixelBorderGeometry(PlayerFrame)
    if not g then return end
    local b, outward = g.bleed, g.point == "TOPLEFT" and 1 or -1
    local r = g.below
    return g.point, r, { x = r.x - b * outward, y = r.y + b, w = r.w + b * 2, h = r.h + b * 2 }
end

function BBF.PlacePixelBorderBox(bar, anchor, point, rect)
    local box = GetBox(bar, bar, "MEDIUM", "bbfPixelAltBox")
    PlaceBox(box, anchor, point, rect)
    SetBoxShown(box, true)
    return box
end

local function AllFrames()
    local list = { PlayerFrame, TargetFrame, FocusFrame, PetFrame }
    if TargetFrame and TargetFrame.totFrame then list[#list + 1] = TargetFrame.totFrame end
    if FocusFrame and FocusFrame.totFrame then list[#list + 1] = FocusFrame.totFrame end
    if PartyFrame and PartyFrame.PartyMemberFramePool then
        for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
            list[#list + 1] = frame
        end
    end
    return list
end

local function HasNoPortraitFrame(frame)
    if frame == PlayerFrame then return BBF.HasNoPortrait("player") end
    if frame == TargetFrame then return BBF.HasNoPortrait("target") end
    if frame == FocusFrame then return BBF.HasNoPortrait("focus") end
    if frame == PetFrame then return BBF.HasNoPortrait("pet") end
    local owner = TotOwner(frame)
    if owner then return BBF.HasNoPortrait(owner == TargetFrame and "target" or "focus") end
    return frame and frame.PartyMemberOverlay and true or false
end

function BBF.UpdatePixelBorderLayout()
    if not BetterBlizzFramesDB.noPortraitPixelBorder then return end
    for _, frame in ipairs(AllFrames()) do
        if frame and HasNoPortraitFrame(frame) and frame.bbfPixelBorderReady then
            BBF.ApplyPixelBorderLayout(frame)
        end
    end
    if BBF.RefreshTextAreas then
        BBF.RefreshTextAreas()
    end
end

local scaleWatcher
local scaleHooked = {}

function BBF.WatchPixelBorderScale(frame)
    frame.bbfPixelBorderReady = true
    if not scaleWatcher then
        scaleWatcher = CreateFrame("Frame")
        scaleWatcher:RegisterEvent("UI_SCALE_CHANGED")
        scaleWatcher:RegisterEvent("DISPLAY_SIZE_CHANGED")
        scaleWatcher:SetScript("OnEvent", BBF.UpdatePixelBorderLayout)
    end
    if scaleHooked[frame] then return end
    scaleHooked[frame] = true
    local function Realign(self)
        BBF.ApplyPixelBorderLayout(self)
        if self.totFrame and self.totFrame.bbfPixelBorderReady then
            BBF.ApplyPixelBorderLayout(self.totFrame)
        end
    end
    hooksecurefunc(frame, "SetScale", Realign)
    hooksecurefunc(frame, "SetPoint", Realign)
    frame:HookScript("OnShow", Realign)
end
