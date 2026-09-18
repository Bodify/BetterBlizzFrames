local ART = "Interface\\Minimap\\"
local TRACKING_BORDER = 136430
local CLASSIC_MAP_SIZE = 140
local COMPASS_RING_SIZE = 365 * 0.7
local NUDGE_Y = 22

local skin

local function AddTexture(parent, layer, subLevel, file, width, height, point, relativeTo, relativePoint, x, y)
    local texture = parent:CreateTexture(nil, layer, nil, subLevel)
    texture:SetTexture(file)
    if width then
        texture:SetSize(width, height)
    end
    texture:SetPoint(point, relativeTo or parent, relativePoint or point, x or 0, y or 0)
    return texture
end

local function Track(texture)
    table.insert(BBF.classicMinimapTextures, texture)
    return texture
end

local function KeepHidden(frame)
    if not frame then return end
    frame:Hide()
    frame:HookScript("OnShow", frame.Hide)
end

local function UpdateCompass()
    if skin.updatingCompass then return end
    skin.updatingCompass = true
    local rotated = GetCVarBool("rotateMinimap")
    skin.NorthTag:SetShown(not rotated)
    MinimapCompassTexture:SetTexture(ART .. "CompassRing")
    MinimapCompassTexture:SetTexCoord(0, 1, 0, 1)
    MinimapCompassTexture:SetSize(COMPASS_RING_SIZE, COMPASS_RING_SIZE)
    MinimapCompassTexture:SetShown(rotated)
    MinimapCompassTextureUnderlay:SetAlpha(0)
    skin.updatingCompass = nil
end

local function SkinCompass()
    skin.NorthTag = Track(AddTexture(skin, "OVERLAY", 0, ART .. "CompassNorthTag", 16, 16, "CENTER", skin, "CENTER", 0, 67))

    MinimapCompassTexture:SetParent(skin)
    MinimapCompassTexture:ClearAllPoints()
    MinimapCompassTexture:SetPoint("CENTER", skin, "CENTER", -2, 0)

    hooksecurefunc(MinimapCompassTexture, "SetAtlas", UpdateCompass)
    hooksecurefunc(MinimapCompassTexture, "SetSize", UpdateCompass)
    CVarCallbackRegistry:RegisterCallback("rotateMinimap", UpdateCompass, skin)
    UpdateCompass()
end

local function SkinHeader()
    local header = Track(AddTexture(skin, "ARTWORK", 0, ART .. "UI-Minimap-Border", 176, 28, "BOTTOM", skin, "CENTER", 0, 64))
    header:SetTexCoord(0.3125, 1, 0, 0.109375)

    KeepHidden(MinimapCluster.BorderTop)

    local zoneButton = MinimapCluster.ZoneTextButton
    zoneButton:SetParent(skin)
    zoneButton:ClearAllPoints()
    zoneButton:SetSize(140, 12)
    zoneButton:SetPoint("LEFT", header, "LEFT", 10, 0)

    MinimapZoneText:ClearAllPoints()
    MinimapZoneText:SetSize(140, 12)
    MinimapZoneText:SetPoint("CENTER", zoneButton, "CENTER", 0, 1)
    MinimapZoneText:SetJustifyH("CENTER")
end

local function SkinZoomButton(button, kind, x, y)
    button:SetParent(skin)
    button:ClearAllPoints()
    button:SetSize(32, 32)
    button:SetPoint("CENTER", skin, "CENTER", x, y)
    button:SetHitRectInsets(4, 4, 2, 6)
    button:SetNormalTexture(ART .. "UI-Minimap-Zoom" .. kind .. "Button-Up")
    button:SetPushedTexture(ART .. "UI-Minimap-Zoom" .. kind .. "Button-Down")
    button:SetDisabledTexture(ART .. "UI-Minimap-Zoom" .. kind .. "Button-Disabled")
    button:SetHighlightTexture(ART .. "UI-Minimap-ZoomButton-Highlight", "ADD")
    for _, texture in ipairs({ button:GetNormalTexture(), button:GetPushedTexture(), button:GetDisabledTexture(), button:GetHighlightTexture() }) do
        texture:SetTexCoord(0, 1, 0, 1)
    end
    button:GetDisabledTexture():SetDesaturated(false)
    Track(button:GetNormalTexture())
    Track(button:GetPushedTexture())
    Track(button:GetDisabledTexture())
    button:Show()
end

local function SkinZoom()
    SkinZoomButton(Minimap.ZoomIn, "In", 69, -37)
    SkinZoomButton(Minimap.ZoomOut, "Out", 43, -65)
    Minimap:HookScript("OnLeave", function(self)
        self.ZoomIn:Show()
        self.ZoomOut:Show()
    end)
end

local function SkinTracking()
    local tracking = MinimapCluster.Tracking
    if not tracking then return end
    tracking:SetParent(skin)
    tracking:ClearAllPoints()
    tracking:SetSize(32, 32)
    tracking:SetPoint("TOPLEFT", skin, "TOPLEFT", 5, -64)

    local background = tracking.Background
    background:SetTexture(ART .. "UI-Minimap-Background")
    background:SetTexCoord(0, 1, 0, 1)
    background:ClearAllPoints()
    background:SetSize(25, 25)
    background:SetPoint("TOPLEFT", tracking, "TOPLEFT", 2, -4)
    background:SetVertexColor(1, 1, 1, 0.6)

    AddTexture(tracking, "ARTWORK", 0, ART .. "Tracking\\None", 20, 20, "TOPLEFT", tracking, "TOPLEFT", 6, -6)

    local button = tracking.Button
    button:ClearAllPoints()
    button:SetSize(32, 32)
    button:SetPoint("TOPLEFT", tracking, "TOPLEFT")
    button:ClearNormalTexture()
    button:ClearPushedTexture()
    button:SetHighlightTexture(ART .. "UI-Minimap-ZoomButton-Highlight", "ADD")
    button:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
    Track(AddTexture(button, "BORDER", 0, TRACKING_BORDER, 54, 54, "TOPLEFT"))
end

local function SkinIndicator(frame, icon, iconFile, point, x, y)
    frame.ignoreInLayout = true
    frame:ClearAllPoints()
    frame:SetSize(33, 33)
    frame:SetPoint(point, skin, "CENTER", x, y)
    icon:SetTexture(iconFile)
    icon:SetTexCoord(0, 1, 0, 1)
    icon:ClearAllPoints()
    icon:SetSize(18, 18)
    icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 7, -6)
    Track(AddTexture(frame, "OVERLAY", 0, TRACKING_BORDER, 52, 52, "TOPLEFT"))
end

local function SkinIndicators()
    local indicators = MinimapCluster.IndicatorFrame
    indicators:SetParent(skin)

    local mail = indicators.MailFrame
    local letter = mail:CreateTexture(nil, "ARTWORK")
    SkinIndicator(mail, letter, "Interface\\Icons\\INV_Letter_15", "TOPRIGHT", 94, 33)
    MiniMapMailIcon:SetAlpha(0)
    mail.NewMailFlipbook:SetTexture(nil)
    mail.MailReminderFlipbook:SetTexture(nil)

    SkinIndicator(indicators.CraftingOrderFrame, MiniMapCraftingOrderIcon, "Interface\\Icons\\INV_Hammer_12", "CENTER", -67, -39)
    indicators:Layout()
end

local function PlaceDifficulty()
    local difficulty = MinimapCluster.InstanceDifficulty
    difficulty:ClearAllPoints()
    difficulty:SetPoint("TOPLEFT", skin, "CENTER", -83, 75)
    difficulty:SetFlipped(false)
end

local function SkinDifficulty()
    local difficulty = MinimapCluster.InstanceDifficulty
    difficulty:SetParent(skin)
    difficulty:SetFrameLevel(skin:GetFrameLevel() + 10)
    hooksecurefunc(MinimapCluster, "SetHeaderUnderneath", PlaceDifficulty)
    PlaceDifficulty()
end

local function SkinClock()
    local clock = TimeManagerClockButton
    clock:SetParent(skin)
    clock:ClearAllPoints()
    clock:SetSize(60, 28)
    clock:SetPoint("CENTER", skin, "CENTER", 0, -68)

    local background = Track(clock:CreateTexture(nil, "BORDER"))
    background:SetTexture("Interface\\TimeManager\\ClockBackground")
    background:SetTexCoord(0.015625, 0.8125, 0.015625, 0.390625)
    background:SetAllPoints(clock)

    TimeManagerClockTicker:ClearAllPoints()
    TimeManagerClockTicker:SetPoint("CENTER", clock, "CENTER", 3, 1.5)
end

local function TintCycleBorder(frame)
    for _, region in ipairs({ frame:GetRegions() }) do
        if region:IsObjectType("Texture") and region:GetAtlas() and region:GetAtlas():lower() == "ui-hud-minimap-frame-cycle" then
            region:SetDesaturated(true)
            region:SetVertexColor(1, 0.816, 0.251, 1)
        end
    end
    for _, child in ipairs({ frame:GetChildren() }) do
        TintCycleBorder(child)
    end
end

local function Relayout()
    local width = Minimap:GetWidth()
    if not width or width <= 0 then return end
    local scale = width / CLASSIC_MAP_SIZE
    skin:SetScale(scale)

    local diel = MinimapCluster.DielFrame
    if diel then
        diel:SetScale(1 / scale)
        diel:ClearAllPoints()
        diel:SetPoint("CENTER", skin, "CENTER", 71 * scale, 35 * scale)
    end

    local coords = MinimapCluster.MinimapContainer.PlayerCoords
    if coords then
        coords:ClearAllPoints()
        coords:SetPoint("TOP", skin, "CENTER", 0, -84 * scale)
    end
end

local function NudgeMinimap()
    if Minimap.bbfNudging or Minimap:GetNumPoints() ~= 1 then return end
    local point, relativeTo, relativePoint, x, y = Minimap:GetPoint(1)
    Minimap.bbfNudging = true
    Minimap:ClearAllPoints()
    Minimap:SetPoint(point, relativeTo, relativePoint, x, y + NUDGE_Y)
    Minimap.bbfNudging = nil
end

function BBF.ClassicMinimap()
    if not BetterBlizzFramesDB.classicMinimap or skin then return end
    if InCombatLockdown() then
        BBF.RunAfterCombat(BBF.ClassicMinimap)
        return
    end

    BBF.classicMinimapTextures = {}
    skin = CreateFrame("Frame", nil, Minimap)
    skin:SetSize(192, 192)
    skin:SetPoint("CENTER", Minimap, "CENTER")
    skin:SetFrameLevel(Minimap:GetFrameLevel() + 2)

    local border = Track(AddTexture(skin, "ARTWORK", 1, ART .. "UI-Minimap-Border", nil, nil, "TOPLEFT", skin, "TOPLEFT", -8, -24))
    border:SetPoint("BOTTOMRIGHT", skin, "BOTTOMRIGHT", -8, -24)
    border:SetTexCoord(0.25, 1, 0.125, 0.875)

    SkinCompass()
    SkinHeader()
    SkinZoom()
    SkinTracking()
    SkinIndicators()
    SkinDifficulty()

    if MinimapCluster.DielFrame then
        MinimapCluster.DielFrame:SetParent(skin)
        hooksecurefunc(MinimapCluster, "SetEditModeScale", Relayout)
    end
    Minimap:HookScript("OnSizeChanged", Relayout)
    Relayout()
    hooksecurefunc(Minimap, "SetPoint", NudgeMinimap)
    NudgeMinimap()
    TintCycleBorder(Minimap)

    KeepHidden(GameTimeFrame)
    KeepHidden(AddonCompartmentFrame)
    KeepHidden(ExpansionLandingPageMinimapButton)

    EventUtil.ContinueOnAddOnLoaded("Blizzard_TimeManager", SkinClock)
end
