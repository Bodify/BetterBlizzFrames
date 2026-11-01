local SEGMENTS = {
    { key = "HealAbsorbBar", template = "HealAbsorbBarTemplate" },
    { key = "MyHealPredictionBar", template = "MyHealPredictionBarTemplate" },
    { key = "OtherHealPredictionBar", template = "OtherHealPredictionBarTemplate" },
    { key = "TotalAbsorbBar", template = "TotalAbsorbBarTemplate" },
}
local SEGMENT_TEXTURES = { "Fill", "TiledFillOverlay", "LeftShadow", "RightShadow" }
local SHADOWS = { "LeftShadow", "RightShadow" }
local GLOWS = {
    OverAbsorbGlow = "OverAbsorbGlowTemplate",
    OverHealAbsorbGlow = "OverHealAbsorbGlowTemplate",
}
local HELPER_TEXTURE = "Interface\\Buttons\\WHITE8x8"
local FRAME_MASK = "Interface\\AddOns\\BetterBlizzFrames\\media\\masks\\frameMask.png"
local PIXEL_MASK = "Interface\\AddOns\\BetterBlizzFrames\\media\\masks\\pixelMask.png"
local DIVIDER_MIN_PERCENT = 0.015
local HELPER_SCALE = 0.01

local mirrors = {}

local function Interpolation()
    local db = BetterBlizzFramesDB
    local interp = Enum.StatusBarInterpolation
    if db.smoothBars and db.smoothHealthbars and interp then
        return interp.ExponentialEaseOut
    end
end

function BBF.HealthMirrorSpec(frame)
    if not frame then return end
    if frame == PlayerFrame then
        local main = frame.PlayerFrameContent.PlayerFrameContentMain
        local container = main.HealthBarsContainer
        return {
            frame = frame,
            parent = main,
            container = container,
            source = container.HealthBar,
            segmentTemplate = "PlayerFrameBarSegmentTemplate",
            loss = container.PlayerFrameHealthBarAnimatedLoss,
            tempLoss = container.PlayerFrameTempMaxHealthLoss,
            divider = container.TempMaxHealthLossDivider,
            snapUnits = { "player", "vehicle" },
            texts = {
                HealthBarText = { "CENTER", 0, 0 },
                LeftText = { "LEFT", 2, 0 },
                RightText = { "RIGHT", -2, 0 },
            },
        }
    end
    if frame.TargetFrameContent then
        local main = frame.TargetFrameContent.TargetFrameContentMain
        local container = main.HealthBarsContainer
        return {
            frame = frame,
            parent = main,
            container = container,
            source = container.HealthBar,
            segmentTemplate = "TargetFrameBarSegmentTemplate",
            tempLoss = container.TempMaxHealthLoss,
            snapEvent = frame == FocusFrame and "PLAYER_FOCUS_CHANGED" or "PLAYER_TARGET_CHANGED",
            texts = {
                HealthBarText = { "CENTER", BBF.isForever and 1 or 0, 0 },
                LeftText = { "LEFT", BBF.isForever and 3 or 2, 0 },
                RightText = { "RIGHT", -5, 0 },
                DeadText = { "CENTER", 0, 0 },
                UnconsciousText = { "CENTER", 0, 0 },
            },
        }
    end
    local container = frame.HealthBarContainer
    if container then
        return {
            frame = frame,
            parent = frame,
            container = container,
            source = container.HealthBar,
            segmentTemplate = "PartyFrameBarSegmentTemplate",
            tempLoss = container.TempMaxHealthLoss,
            snapEvent = "GROUP_ROSTER_UPDATE",
            texts = {
                CenterText = { "CENTER", 0, 0 },
                LeftText = { "LEFT", 0, 0 },
                RightText = { "RIGHT", 0, 0 },
            },
        }
    end
end

local function CreateHelper(parent)
    local helper = CreateFrame("StatusBar", nil, parent)
    helper:SetScale(HELPER_SCALE)
    helper:SetStatusBarTexture(HELPER_TEXTURE)
    local tex = helper:GetStatusBarTexture()
    tex:SetAlpha(0)
    tex:SetSnapToPixelGrid(false)
    tex:SetTexelSnappingBias(0)
    return helper
end

local function AddMask(mirror, region)
    if region and region.AddMaskTexture then
        region:AddMaskTexture(mirror.mask)
    end
end

local function HideSource(mirror)
    local spec = mirror.spec
    mirror.guard = true
    spec.source:SetAlpha(0)
    if spec.loss then spec.loss:SetAlpha(0) end
    if spec.tempLoss then spec.tempLoss:SetAlpha(0) end
    if spec.divider then spec.divider:SetAlpha(0) end
    mirror.guard = false
end

local function ShowSource(mirror)
    local spec = mirror.spec
    mirror.guard = true
    spec.source:SetAlpha(1)
    if spec.loss then spec.loss:SetAlpha(1) end
    if spec.tempLoss then spec.tempLoss:SetAlpha(1) end
    if spec.divider then spec.divider:SetAlpha(1) end
    mirror.guard = false
end

local function CopyColor(mirror)
    local r, g, b = mirror.spec.source:GetStatusBarColor()
    mirror.bar:SetStatusBarColor(r, g, b)
end

local CopyTexture

local function HookFill(mirror, src)
    if src.bbfHealthMirror then return end
    src.bbfHealthMirror = mirror
    hooksecurefunc(src, "SetVertexColor", function(self, r, g, b)
        if self.bbfHealthMirror ~= mirror or not mirror.active then return end
        mirror.fill:SetVertexColor(r, g, b)
    end)
    hooksecurefunc(src, "SetDesaturated", function(self, desaturated)
        if self.bbfHealthMirror ~= mirror or not mirror.active then return end
        mirror.fill:SetDesaturated(desaturated)
    end)
    hooksecurefunc(src, "SetAtlas", function(self)
        if self.bbfHealthMirror ~= mirror or not mirror.active then return end
        CopyTexture(mirror)
    end)
end

CopyTexture = function(mirror)
    local src = mirror.spec.source:GetStatusBarTexture()
    if not src then return end
    local dst = mirror.fill
    local atlas = src:GetAtlas()
    if atlas then
        dst:SetAtlas(atlas, false)
    else
        dst:SetTexture(src:GetTexture())
    end
    dst:SetTexCoord(src:GetTexCoord())
    if dst.SetSnapToPixelGrid then
        dst:SetSnapToPixelGrid(src:IsSnappingToPixelGrid())
        dst:SetTexelSnappingBias(src:GetTexelSnappingBias())
    end
    dst:SetDrawLayer(src:GetDrawLayer())
    dst:SetAlpha(1)
    CopyColor(mirror)
    HookFill(mirror, src)
end

local function SegmentEnd(segment)
    if segment and segment.source:IsShown() then
        return segment.sizeHelper:GetStatusBarTexture()
    end
end

local function SegmentAnchor(mirror, seg)
    if seg.key == "OtherHealPredictionBar" then
        return SegmentEnd(mirror.MyHealPredictionBar) or mirror.fill, false
    end
    if seg.key == "TotalAbsorbBar" then
        local healAbsorb = mirror.HealAbsorbBar
        if healAbsorb and healAbsorb.source:IsShown() then
            return mirror.fill, true
        end
        return SegmentEnd(mirror.OtherHealPredictionBar) or SegmentEnd(mirror.MyHealPredictionBar) or mirror.fill, true
    end
    return mirror.fill, false
end

local function UpdateSegment(mirror, seg)
    local src = seg.source
    if not seg.hasData then
        seg:Hide()
        return
    end
    local anchor, noOffset = SegmentAnchor(mirror, seg)
    if seg.anchor ~= anchor then
        seg.anchor = anchor
        seg.offsetHelper:ClearAllPoints()
        seg.offsetHelper:SetPoint("TOPRIGHT", anchor, "TOPRIGHT")
        seg.offsetHelper:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT")
    end
    if noOffset then
        seg.offsetHelper:SetValue(0)
    else
        seg.offsetHelper:SetValue(seg.lastOffset)
    end
    seg.sizeHelper:SetValue(seg.lastFill)
    local atlas = src.Fill and src.Fill:GetAtlas()
    local fill = atlas or (src.Fill and src.Fill:GetTexture())
    if fill and fill ~= seg.bbfFill then
        seg.bbfFill = fill
        if atlas then
            seg.Fill:SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize)
        else
            seg.Fill:SetTexture(fill)
        end
    end
    seg:SetShown(src:IsShown())
end

local function CreateSegment(mirror, src, info)
    local seg = CreateFrame("Frame", nil, mirror.bar, mirror.spec.segmentTemplate .. ", " .. info.template)
    seg:Initialize()
    seg.source = src
    seg.offsetHelper = CreateHelper(mirror.bar)
    seg.offsetHelper:SetMinMaxValues(-1, 0)
    seg.offsetHelper:SetValue(0)
    seg.sizeHelper = CreateHelper(mirror.bar)
    local offsetFill = seg.offsetHelper:GetStatusBarTexture()
    seg.sizeHelper:SetPoint("TOPLEFT", offsetFill, "TOPRIGHT")
    seg.sizeHelper:SetPoint("BOTTOMLEFT", offsetFill, "BOTTOMRIGHT")
    seg.FillMask:ClearAllPoints()
    seg.FillMask:SetPoint("TOPLEFT", offsetFill, "TOPRIGHT")
    seg.FillMask:SetPoint("BOTTOMRIGHT", seg.sizeHelper:GetStatusBarTexture(), "BOTTOMRIGHT")
    for _, key in ipairs(SEGMENT_TEXTURES) do
        AddMask(mirror, seg[key])
    end
    seg:Hide()
    seg.key = info.key

    hooksecurefunc(src, "UpdateFillPosition", function(_, _, fillValue, xOffsetPercent)
        if type(xOffsetPercent) == "nil" then
            xOffsetPercent = 0
        end
        seg.lastFill = fillValue
        seg.lastOffset = xOffsetPercent
        seg.hasData = true
        if mirror.active then
            UpdateSegment(mirror, seg)
        end
    end)
    hooksecurefunc(src, "Hide", function()
        if mirror.active then seg:Hide() end
    end)
    for _, key in ipairs(SHADOWS) do
        local srcShadow, shadow = src[key], seg[key]
        if srcShadow and shadow then
            hooksecurefunc(srcShadow, "SetShown", function(_, shown)
                shadow.bbfShown = shown
                if mirror.active then
                    shadow:SetAlphaFromBoolean(shown, 1, 0)
                end
            end)
        end
    end
    return seg
end

local function CreateGlow(mirror, key, template)
    local src = mirror.spec.source[key]
    if not src then return end
    local glow = mirror.bar:CreateTexture(nil, "ARTWORK", template)
    AddMask(mirror, glow)
    glow:SetShown(src:IsShown())
    if BetterBlizzFramesDB.hideAllAbsorbGlow then
        glow:SetAlpha(0)
    end
    hooksecurefunc(src, "Show", function()
        if mirror.active then glow:Show() end
    end)
    hooksecurefunc(src, "Hide", function()
        if mirror.active then glow:Hide() end
    end)
    glow.source = src
    mirror.glows[key] = glow
end

local function PlaceGlows(mirror, offset)
    local bar = mirror.bar
    local glow = mirror.glows.OverAbsorbGlow
    if glow and not glow.bbfOvershieldAnchored then
        glow:ClearAllPoints()
        glow:SetPoint("TOPLEFT", bar, "TOPRIGHT", offset, 0)
        glow:SetPoint("BOTTOMLEFT", bar, "BOTTOMRIGHT", offset, 0)
    end
    glow = mirror.glows.OverHealAbsorbGlow
    if glow then
        glow:ClearAllPoints()
        glow:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", -offset, 0)
        glow:SetPoint("TOPRIGHT", bar, "TOPLEFT", -offset, 0)
    end
end

local function CreateLoss(mirror)
    local src = mirror.spec.loss
    if not src then return end
    local loss = CreateFrame("StatusBar", nil, mirror.holder)
    loss:SetAllPoints(mirror.bar)
    local srcTex = src:GetStatusBarTexture()
    local atlas = srcTex and srcTex:GetAtlas()
    if atlas then
        loss:SetStatusBarTexture(atlas)
    else
        loss:SetStatusBarTexture(HELPER_TEXTURE)
    end
    loss:GetStatusBarTexture():SetDrawLayer("BACKGROUND")
    loss:SetStatusBarColor(src:GetStatusBarColor())
    loss:SetMinMaxValues(src:GetMinMaxValues())
    AddMask(mirror, loss:GetStatusBarTexture())
    loss:SetShown(src:IsShown())

    local function Allowed()
        return mirror.active and not BetterBlizzFramesDB.hidePlayerHealthLossAnim
    end
    hooksecurefunc(src, "SetMinMaxValues", function(_, minValue, maxValue)
        loss:SetMinMaxValues(minValue, maxValue)
    end)
    hooksecurefunc(src, "SetValue", function(_, value)
        loss:SetValue(value)
    end)
    hooksecurefunc(src, "Show", function()
        if Allowed() then loss:Show() end
    end)
    hooksecurefunc(src, "Hide", function()
        loss:Hide()
    end)
    mirror.loss = loss
end

local function TempLossPercent(mirror)
    local unit = mirror.spec.source.unit
    if not unit or not GetUnitTotalModifiedMaxHealthPercent then return 0 end
    if not C_CVar.GetCVarBool("showTempMaxHealthLoss") then return 0 end
    local percent = GetUnitTotalModifiedMaxHealthPercent(unit)
    if type(percent) ~= "number" or issecretvalue(percent) then return 0 end
    return Clamp(percent, 0, 1)
end

local function CreateTempLoss(mirror)
    local src = mirror.spec.tempLoss
    if not src then return end
    local tempLoss = CreateFrame("StatusBar", nil, mirror.holder)
    tempLoss:SetAllPoints(mirror.holder)
    local srcTex = src:GetStatusBarTexture()
    local atlas = srcTex and srcTex:GetAtlas()
    if atlas then
        tempLoss:SetStatusBarTexture(atlas)
    else
        tempLoss:SetStatusBarTexture(HELPER_TEXTURE)
    end
    tempLoss:GetStatusBarTexture():SetDrawLayer("BACKGROUND")
    tempLoss:SetFillStyle(Enum.StatusBarFillStyle.Reverse)
    tempLoss:SetMinMaxValues(0, 1)
    tempLoss:SetValue(0)
    AddMask(mirror, tempLoss:GetStatusBarTexture())
    mirror.tempLoss = tempLoss

    if mirror.spec.divider then
        local divider = mirror.holder:CreateTexture(nil, "OVERLAY")
        divider:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-TempHPLoss-Divider")
        divider:SetPoint("TOP", mirror.bar, "TOPRIGHT", 0, 2)
        divider:SetPoint("BOTTOM", mirror.bar, "BOTTOMRIGHT", 0, -2)
        divider:SetWidth(4)
        divider:Hide()
        mirror.divider = divider
    end

    local function Refresh()
        if mirror.active then BBF.RelayoutHealthbarMirror(mirror.spec.frame) end
    end
    hooksecurefunc(src, "SetValue", Refresh)
    hooksecurefunc(src, "Show", Refresh)
    hooksecurefunc(src, "Hide", Refresh)
end

local function SetSnapEvents(mirror, on)
    local bar = mirror.bar
    bar:UnregisterAllEvents()
    if not on then return end
    local spec = mirror.spec
    if spec.snapUnits then
        bar:RegisterUnitEvent("UNIT_MAXHEALTH", spec.snapUnits[1], spec.snapUnits[2])
    elseif spec.source.unit then
        bar:RegisterUnitEvent("UNIT_MAXHEALTH", spec.source.unit)
    end
    if spec.snapEvent then
        bar:RegisterEvent(spec.snapEvent)
    end
end

local function CreateMirror(frame)
    local spec = BBF.HealthMirrorSpec(frame)
    if not spec or not spec.source then return end
    local source = spec.source

    local mirror = { spec = spec, glows = {}, segments = {} }

    local holder = CreateFrame("Frame", nil, spec.parent)
    holder:SetFrameStrata(source:GetFrameStrata())
    holder:SetFrameLevel(source:GetFrameLevel())
    holder:EnableMouse(false)
    holder:Hide()
    mirror.holder = holder

    local bar = CreateFrame("StatusBar", nil, holder)
    bar:SetFrameLevel(holder:GetFrameLevel())
    bar:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
    bar:SetStatusBarTexture(HELPER_TEXTURE)
    bar:SetScript("OnEvent", bar.SetToTargetValue)
    bar.bbfMirror = mirror
    mirror.bar = bar
    mirror.fill = bar:GetStatusBarTexture()
    mirror.fill:SetDrawLayer("BACKGROUND")

    local mask = bar:CreateMaskTexture()
    mask:SetTexture(FRAME_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(holder)
    mirror.mask = mask
    AddMask(mirror, mirror.fill)

    mirror.text = CreateFrame("Frame", nil, holder)
    mirror.text:SetAllPoints(holder)
    mirror.text:SetFrameLevel(holder:GetFrameLevel() + 1)

    for _, info in ipairs(SEGMENTS) do
        local src = source[info.key]
        if src and src.UpdateFillPosition then
            mirror.segments[#mirror.segments + 1] = CreateSegment(mirror, src, info)
            mirror[info.key] = mirror.segments[#mirror.segments]
        end
    end
    for key, template in pairs(GLOWS) do
        CreateGlow(mirror, key, template)
    end
    CreateLoss(mirror)
    if mirror.loss then
        mirror.loss:SetFrameLevel(math.max(holder:GetFrameLevel() - 1, 0))
    end
    CreateTempLoss(mirror)

    hooksecurefunc(source, "SetValue", function(_, value)
        if not mirror.active then return end
        local interp = Interpolation()
        if interp then
            bar:SetValue(value, interp)
        else
            bar:SetValue(value)
        end
    end)
    hooksecurefunc(source, "SetMinMaxValues", function(_, minValue, maxValue)
        if not mirror.active then return end
        bar:SetMinMaxValues(minValue, maxValue)
        for _, seg in ipairs(mirror.segments) do
            seg.sizeHelper:SetMinMaxValues(minValue, maxValue)
        end
    end)
    hooksecurefunc(source, "SetStatusBarColor", function()
        if mirror.active then CopyColor(mirror) end
    end)
    hooksecurefunc(source, "SetStatusBarDesaturated", function(_, desaturated)
        if mirror.active then bar:SetStatusBarDesaturated(desaturated) end
    end)
    hooksecurefunc(source, "SetStatusBarTexture", function()
        if mirror.active then CopyTexture(mirror) end
    end)
    hooksecurefunc(source, "SetAlpha", function()
        if mirror.active and not mirror.guard then HideSource(mirror) end
    end)

    mirrors[frame] = mirror
    frame.bbfHealthbar = bar
    frame.bbfHealthbarHolder = holder
    return mirror
end

local function Snapshot(mirror)
    local source, bar = mirror.spec.source, mirror.bar
    local minValue, maxValue = source:GetMinMaxValues()
    bar:SetMinMaxValues(minValue, maxValue)
    bar:SetValue(source:GetValue())
    CopyTexture(mirror)
    for _, seg in ipairs(mirror.segments) do
        seg.sizeHelper:SetMinMaxValues(minValue, maxValue)
    end
    for _, seg in ipairs(mirror.segments) do
        UpdateSegment(mirror, seg)
        for _, key in ipairs(SHADOWS) do
            local shadow = seg[key]
            if shadow and type(shadow.bbfShown) ~= "nil" then
                shadow:SetAlphaFromBoolean(shadow.bbfShown, 1, 0)
            end
        end
    end
    for _, glow in pairs(mirror.glows) do
        glow:SetShown(glow.source:IsShown())
    end
    if mirror.loss then
        local loss = mirror.spec.loss
        mirror.loss:SetMinMaxValues(loss:GetMinMaxValues())
        mirror.loss:SetValue(loss:GetValue())
        mirror.loss:SetShown(loss:IsShown() and not BetterBlizzFramesDB.hidePlayerHealthLossAnim)
    end
end

local function PlaceTexts(mirror, layout)
    local spec = mirror.spec
    if layout.texts == false then return end
    local parent = layout.textParent or mirror.text
    local anchors = layout.texts or {}
    for key, default in pairs(spec.texts) do
        local text = spec.container[key]
        if text then
            local parentNow = text:GetParent()
            if parentNow == spec.container or parentNow == mirror.text or parentNow == layout.textParent then
                text:SetParent(parent)
                text.bbfHealthMirrorMoved = true
            end
            local anchor = anchors[key] or default
            text:ClearAllPoints()
            text:SetPoint(anchor[1], anchor.relativeTo or mirror.bar, anchor[1], anchor[2], anchor[3])
        end
    end
end

local function RestoreTexts(mirror)
    local spec = mirror.spec
    for key, default in pairs(spec.texts) do
        local text = spec.container[key]
        if text and text.bbfHealthMirrorMoved and text:GetParent() == mirror.text then
            text.bbfHealthMirrorMoved = nil
            text:SetParent(spec.container)
            text:ClearAllPoints()
            text:SetPoint(default[1], spec.container, default[1], default[2], default[3])
        end
    end
end

local function PlaceMask(mirror, layout)
    local mask, info = mirror.mask, layout.mask
    local fallback = layout.pixel and PIXEL_MASK or FRAME_MASK
    mask:ClearAllPoints()
    if not info then
        mask:SetTexture(fallback, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:SetAllPoints(mirror.holder)
        return
    end
    if info.retailSlot and BBF.MaskRetailSlot then
        local container = mirror.spec.frame.TargetFrameContainer
        if container and BBF.MaskRetailSlot(mask, container.FrameTexture, "health") then
            return
        end
        mask:SetTexture(fallback, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:SetAllPoints(mirror.holder)
        return
    end
    if info.artMask and BBF.ApplyFrameMask then
        local container = mirror.spec.frame.TargetFrameContainer
        if container and BBF.ApplyFrameMask(mask, info.artMask, "health", container.FrameTexture) then
            local adjust = info.adjust
            if adjust then
                mask:ClearAllPoints()
                mask:SetPoint("TOPLEFT", container.FrameTexture, "TOPLEFT", adjust.left or 0, adjust.top or 0)
                mask:SetPoint("BOTTOMRIGHT", container.FrameTexture, "BOTTOMRIGHT", adjust.right or 0, adjust.bottom or 0)
            end
            return
        end
        mask:SetTexture(fallback, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:SetAllPoints(mirror.holder)
        return
    end
    if info.atlas then
        mask:SetAtlas(info.atlas, info.atlasSize and true or false)
    else
        mask:SetTexture(info.texture or fallback, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    end
    if info.fit then
        mask:SetPoint("TOPLEFT", mirror.holder, "TOPLEFT")
        mask:SetPoint("BOTTOMRIGHT", mirror.holder, "BOTTOMRIGHT", info.right or 0, 0)
        return
    end
    mask:SetPoint("TOPLEFT", mirror.holder, "TOPLEFT", info.x or 0, info.y or 0)
    if not info.atlasSize then
        mask:SetSize(info.width, info.height)
    end
end

function BBF.RelayoutHealthbarMirror(frame)
    local mirror = mirrors[frame]
    if not mirror or not mirror.layout then return end
    local layout = mirror.layout
    local percent = TempLossPercent(mirror)
    local width = layout.width * (1 - percent)
    mirror.bar:SetSize(width, layout.height)
    for _, seg in ipairs(mirror.segments) do
        seg.offsetHelper:SetWidth(width / HELPER_SCALE)
        seg.sizeHelper:SetWidth(width / HELPER_SCALE)
    end
    if mirror.tempLoss then
        mirror.tempLoss:SetValue(percent)
        mirror.tempLoss:SetShown(percent > 0)
    end
    if mirror.divider then
        mirror.divider:SetShown(percent > DIVIDER_MIN_PERCENT)
    end
end

function BBF.ApplyHealthbarMirrorLayout(frame, layout)
    local mirror = mirrors[frame]
    if not mirror or not layout then return end
    mirror.layout = layout
    local holder = mirror.holder
    local point = layout.point
    holder:ClearAllPoints()
    holder:SetPoint(point[1], layout.relativeTo or frame, point[2], point[3], point[4])
    holder:SetSize(layout.width, layout.height)
    PlaceMask(mirror, layout)
    PlaceGlows(mirror, layout.glowOffset or -7)
    PlaceTexts(mirror, layout)
    BBF.RelayoutHealthbarMirror(frame)
end

function BBF.EnableHealthbarMirror(frame, layout)
    local mirror = mirrors[frame] or CreateMirror(frame)
    if not mirror then return end
    if layout then
        BBF.ApplyHealthbarMirrorLayout(frame, layout)
    end
    if mirror.active then
        SetSnapEvents(mirror, Interpolation() ~= nil)
        return mirror
    end
    mirror.active = true
    Snapshot(mirror)
    HideSource(mirror)
    SetSnapEvents(mirror, Interpolation() ~= nil)
    mirror.holder:Show()
    return mirror
end

function BBF.DisableHealthbarMirror(frame)
    local mirror = mirrors[frame]
    if not mirror or not mirror.active then return end
    mirror.active = false
    SetSnapEvents(mirror, false)
    mirror.holder:Hide()
    ShowSource(mirror)
    RestoreTexts(mirror)
end

function BBF.GetHealthbarMirror(frame)
    local mirror = mirrors[frame]
    if mirror and mirror.active then
        return mirror
    end
end

function BBF.HealthBar(frame)
    local mirror = BBF.GetHealthbarMirror(frame)
    if mirror then
        return mirror.bar
    end
    local spec = BBF.HealthMirrorSpec(frame)
    return spec and spec.source
end

function BBF.HealthBarMask(frame)
    local mirror = BBF.GetHealthbarMirror(frame)
    if mirror then
        return mirror.mask
    end
    local spec = BBF.HealthMirrorSpec(frame)
    return spec and spec.container.HealthBarMask
end

function BBF.BigHealthbarsOn()
    local db = BetterBlizzFramesDB
    return db.bigHealthbars and not db.noPortraitPixelBorder
end

function BBF.BigPlayerHealthbar()
    local db = BetterBlizzFramesDB
    return BBF.BigHealthbarsOn() and db.bigHealthbarPlayer ~= false and not BBF.IsMiniFrame(PlayerFrame)
end

local miniKeys = { player = "useMiniPlayerFrame", target = "useMiniTargetFrame", focus = "useMiniFocusFrame" }

function BBF.IsMiniFrame(frame)
    local db = BetterBlizzFramesDB
    local unit = (frame == PlayerFrame and "player") or (frame == TargetFrame and "target") or (frame == FocusFrame and "focus")
    return unit and db[miniKeys[unit]] and true or false
end

local stoppedBars = {}
local stopHooked = false

local function StopBar(bar)
    if InCombatLockdown() and bar:IsProtected() then
        BBF.RunAfterCombat(function() StopBar(bar) end)
        return
    end
    bar:UnregisterAllEvents()
    bar:SetScript("OnUpdate", nil)
end

local function MiniBarRegions(frame)
    local main, manaBar
    if frame == PlayerFrame then
        main = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain
        manaBar = main.ManaBarArea.ManaBar
    else
        main = frame.TargetFrameContent.TargetFrameContentMain
        manaBar = main.ManaBar
    end
    local hp = main.HealthBarsContainer
    local regions = {
        hp, manaBar,
        hp.LeftText, hp.RightText, hp.HealthBarText, hp.DeadText, hp.UnconsciousText,
        manaBar.LeftText, manaBar.RightText, manaBar.ManaBarText,
        frame.BBFHealthTextFrame, frame.BBFManaTextFrame,
        frame.bbfPixelHealthBox, frame.bbfPixelManaBox,
    }
    if frame.noPortraitMode then
        regions[#regions + 1] = frame.noPortraitMode.Texture
        regions[#regions + 1] = frame.noPortraitMode.Background
    end
    return regions
end

local keptHidden = {}

function BBF.HideMiniFrameBarArt(frame)
    if not BBF.IsMiniFrame(frame) then return end
    for _, region in pairs(MiniBarRegions(frame)) do
        region:SetAlpha(0)
        if not keptHidden[region] then
            keptHidden[region] = true
            hooksecurefunc(region, "SetAlpha", function(self, alpha)
                if alpha ~= 0 then self:SetAlpha(0) end
            end)
        end
    end
end

function BBF.StopMiniFrameBars(frame)
    if not BBF.IsMiniFrame(frame) then return end
    for _, bar in ipairs({ frame.healthbar, frame.manabar }) do
        stoppedBars[bar] = true
        StopBar(bar)
    end
    if stopHooked then return end
    stopHooked = true
    hooksecurefunc("UnitFrameHealthBar_RefreshUpdateEvent", function(bar)
        if stoppedBars[bar] then StopBar(bar) end
    end)
    hooksecurefunc("UnitFrame_SetUnit", function(_, _, healthBar, manaBar)
        if healthBar and stoppedBars[healthBar] then StopBar(healthBar) end
        if manaBar and stoppedBars[manaBar] then StopBar(manaBar) end
    end)
end
