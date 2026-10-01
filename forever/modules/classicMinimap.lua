local ART = "Interface\\Minimap\\"
local TRACKING_BORDER = 136430
local SKIN_BASE_WIDTH = 140
local MINIMAP_NUDGE = 12
local TITLE_NUDGE = 22
local TITLE_OFFSET = 64
local CLOCK_DROP = 3
local DEFAULT_Y_POS = 12

local skin
local title

local function AddTexture(parent, layer, subLevel, file, width, height, point, relativeTo, relativePoint, x, y)
    local texture = parent:CreateTexture(nil, layer, nil, subLevel)
    texture:SetTexture(file)
    if width then
        texture:SetSize(width, height)
    end
    texture:SetPoint(point, relativeTo or parent, relativePoint or point, x or 0, y or 0)
    table.insert(BBF.classicMinimapTextures, texture)
    return texture
end

local function KeepPoint(frame, point, relativeTo, relativePoint, x, y)
    frame.changing = true
    frame:ClearAllPoints()
    frame:SetPoint(point, relativeTo, relativePoint, x, y)
    frame.changing = false
    if not frame.bbfPointHooked then
        frame.bbfPointHooked = true
        hooksecurefunc(frame, "SetPoint", function(self)
            if self.changing then return end
            self.changing = true
            self:ClearAllPoints()
            self:SetPoint(unpack(self.bbfPoint))
            self.changing = false
        end)
    end
    frame.bbfPoint = { point, relativeTo, relativePoint, x, y }
end

function BBF.UpdateClassicMinimapLayout()
    if not skin or not title then return end
    local db = BetterBlizzFramesDB
    local tweaks = db.foreverMinimapTweaks
    local mapScale = tweaks and db.foreverMinimapScale or 1
    local titleScale = tweaks and db.foreverMinimapTitleScale or 1
    local halfHeight = Minimap:GetHeight() / 2
    local xPos = tweaks and db.foreverMinimapXPos or 0
    local yPos = tweaks and (db.foreverMinimapYPos or DEFAULT_Y_POS) - DEFAULT_Y_POS or 0

    Minimap:SetScale(mapScale)
    local base = Minimap.bbfBasePoint
    if base and type(base[5]) == "number" then
        Minimap.changing = true
        Minimap:ClearAllPoints()
        Minimap:SetPoint(base[1], base[2], base[3], base[4] + xPos / mapScale, base[5] + (MINIMAP_NUDGE + yPos + halfHeight) / mapScale - halfHeight)
        Minimap.changing = false
    end

    local skinScale = Minimap:GetWidth() / SKIN_BASE_WIDTH
    local titleFrameScale = skinScale * titleScale
    title:SetScale(titleFrameScale)
    title:ClearAllPoints()
    title:SetPoint("BOTTOM", MinimapCluster.MinimapContainer, "CENTER", 0, (TITLE_NUDGE + TITLE_OFFSET * skinScale) / titleFrameScale)

    local coords = MinimapCluster.MinimapContainer.PlayerCoords
    if coords and not TimeManagerClockTicker then
        KeepPoint(coords, "TOP", skin, "CENTER", 0, -(84 * skinScale + CLOCK_DROP) * mapScale)
    end

    BBF.UpdateMinimapTitle()
end

function BBF.ClassicMinimap()
    if not BetterBlizzFramesDB.classicMinimap or skin then return end
    if InCombatLockdown() then
        BBF.RunAfterCombat(BBF.ClassicMinimap)
        return
    end

    BBF.UpdateMinimapTweaks()

    BBF.classicMinimapTextures = {}
    skin = CreateFrame("Frame", nil, Minimap)
    skin:SetSize(192, 192)
    skin:SetPoint("CENTER", Minimap, "CENTER")
    skin:SetFrameLevel(Minimap:GetFrameLevel() + 2)

    local border = AddTexture(skin, "ARTWORK", 1, ART .. "UI-Minimap-Border", nil, nil, "TOPLEFT", skin, "TOPLEFT", -8, -24)
    border:SetPoint("BOTTOMRIGHT", skin, "BOTTOMRIGHT", -8, -24)
    border:SetTexCoord(0.25, 1, 0.125, 0.875)

    local northTag = AddTexture(skin, "OVERLAY", 0, ART .. "CompassNorthTag", 16, 16, "CENTER", skin, "CENTER", 0, 67)
    MinimapCompassTexture:SetParent(skin)
    MinimapCompassTexture:ClearAllPoints()
    MinimapCompassTexture:SetPoint("CENTER", skin, "CENTER", -2, 0)
    local function UpdateCompass()
        if skin.changing then return end
        skin.changing = true
        local rotated = GetCVarBool("rotateMinimap")
        northTag:SetShown(not rotated)
        MinimapCompassTexture:SetTexture(ART .. "CompassRing")
        MinimapCompassTexture:SetTexCoord(0, 1, 0, 1)
        MinimapCompassTexture:SetSize(365 * 0.7, 365 * 0.7)
        MinimapCompassTexture:SetShown(rotated)
        MinimapCompassTextureUnderlay:SetAlpha(0)
        skin.changing = false
    end
    hooksecurefunc(MinimapCompassTexture, "SetAtlas", UpdateCompass)
    hooksecurefunc(MinimapCompassTexture, "SetSize", UpdateCompass)
    CVarCallbackRegistry:RegisterCallback("rotateMinimap", UpdateCompass, skin)
    UpdateCompass()

    title = CreateFrame("Frame", nil, MinimapCluster.MinimapContainer)
    title:SetSize(176, 28)
    title:SetFrameLevel(Minimap:GetFrameLevel() + 1)

    local header = AddTexture(title, "ARTWORK", 0, ART .. "UI-Minimap-Border", 176, 28, "BOTTOM", title, "BOTTOM", 0, 0)
    header:SetTexCoord(0.3125, 1, 0, 0.109375)
    BBF.classicMinimapHeader = header

    local zoneButton = MinimapCluster.ZoneTextButton
    zoneButton:SetParent(title)
    zoneButton:SetFrameLevel(skin:GetFrameLevel() + 3)
    zoneButton:ClearAllPoints()
    zoneButton:SetSize(156, 12)
    zoneButton:SetPoint("LEFT", header, "LEFT", 10, 0)
    MinimapZoneText:ClearAllPoints()
    MinimapZoneText:SetSize(140, 12)
    MinimapZoneText:SetPoint("CENTER", zoneButton, "CENTER", 0, 1)
    MinimapZoneText:SetJustifyH("CENTER")

    for _, zoom in ipairs({ { Minimap.ZoomIn, "In", 69, -37 }, { Minimap.ZoomOut, "Out", 43, -65 } }) do
        local button, kind = zoom[1], zoom[2]
        button:SetParent(skin)
        button:ClearAllPoints()
        button:SetSize(32, 32)
        button:SetPoint("CENTER", skin, "CENTER", zoom[3], zoom[4])
        button:SetHitRectInsets(4, 4, 2, 6)
        button:SetNormalTexture(ART .. "UI-Minimap-Zoom" .. kind .. "Button-Up")
        button:SetPushedTexture(ART .. "UI-Minimap-Zoom" .. kind .. "Button-Down")
        button:SetDisabledTexture(ART .. "UI-Minimap-Zoom" .. kind .. "Button-Disabled")
        button:SetHighlightTexture(ART .. "UI-Minimap-ZoomButton-Highlight", "ADD")
        for _, texture in ipairs({ button:GetNormalTexture(), button:GetPushedTexture(), button:GetDisabledTexture(), button:GetHighlightTexture() }) do
            texture:SetTexCoord(0, 1, 0, 1)
        end
        button:GetDisabledTexture():SetDesaturated(false)
        table.insert(BBF.classicMinimapTextures, button:GetNormalTexture())
        table.insert(BBF.classicMinimapTextures, button:GetPushedTexture())
        table.insert(BBF.classicMinimapTextures, button:GetDisabledTexture())
        button:Show()
    end
    Minimap:HookScript("OnLeave", function(self)
        self.ZoomIn:Show()
        self.ZoomOut:Show()
    end)

    local tracking = MinimapCluster.Tracking
    if tracking then
        tracking:SetParent(skin)
        tracking:ClearAllPoints()
        tracking:SetSize(32, 32)
        tracking:SetPoint("TOPLEFT", skin, "TOPLEFT", 5, -64)

        tracking.Background:SetTexture(ART .. "UI-Minimap-Background")
        tracking.Background:SetTexCoord(0, 1, 0, 1)
        tracking.Background:ClearAllPoints()
        tracking.Background:SetSize(25, 25)
        tracking.Background:SetPoint("TOPLEFT", tracking, "TOPLEFT", 2, -4)
        tracking.Background:SetVertexColor(1, 1, 1, 0.6)

        local trackingIcon = tracking:CreateTexture(nil, "ARTWORK")
        trackingIcon:SetTexture(ART .. "Tracking\\None")
        trackingIcon:SetSize(20, 20)
        trackingIcon:SetPoint("TOPLEFT", tracking, "TOPLEFT", 6, -6)

        local button = tracking.Button
        button:ClearAllPoints()
        button:SetSize(32, 32)
        button:SetPoint("TOPLEFT", tracking, "TOPLEFT")
        button:ClearNormalTexture()
        button:ClearPushedTexture()
        button:SetHighlightTexture(ART .. "UI-Minimap-ZoomButton-Highlight", "ADD")
        button:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
        AddTexture(button, "BORDER", 0, TRACKING_BORDER, 54, 54, "TOPLEFT")
    end

    local indicators = MinimapCluster.IndicatorFrame
    indicators:SetParent(skin)
    local mail = indicators.MailFrame
    local craftingOrder = indicators.CraftingOrderFrame
    for _, indicator in ipairs({
        { mail, mail:CreateTexture(nil, "ARTWORK"), "Interface\\Icons\\INV_Letter_15", "TOPRIGHT", 94, 33 },
        { craftingOrder, MiniMapCraftingOrderIcon, "Interface\\Icons\\INV_Hammer_12", "CENTER", -67, -39 },
    }) do
        local frame, icon = indicator[1], indicator[2]
        frame.ignoreInLayout = true
        frame:ClearAllPoints()
        frame:SetSize(33, 33)
        frame:SetPoint(indicator[4], skin, "CENTER", indicator[5], indicator[6])
        icon:SetTexture(indicator[3])
        icon:SetTexCoord(0, 1, 0, 1)
        icon:ClearAllPoints()
        icon:SetSize(18, 18)
        icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 7, -6)
        AddTexture(frame, "OVERLAY", 0, TRACKING_BORDER, 52, 52, "TOPLEFT")
    end
    MiniMapMailIcon:SetAlpha(0)
    mail.NewMailFlipbook:SetTexture(nil)
    mail.MailReminderFlipbook:SetTexture(nil)
    indicators:Layout()

    local difficulty = MinimapCluster.InstanceDifficulty
    difficulty:SetParent(title)
    difficulty:SetFrameLevel(skin:GetFrameLevel() + 10)
    local function PlaceDifficulty()
        difficulty:ClearAllPoints()
        difficulty:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 10, 5)
        difficulty:SetFlipped(false)
    end
    hooksecurefunc(MinimapCluster, "SetHeaderUnderneath", PlaceDifficulty)
    PlaceDifficulty()

    for _, text in ipairs({ difficulty.Default.Text, difficulty.Guild.Instance.Text }) do
        local font, size = text:GetFont()
        text:SetFont(font, size, "OUTLINE")
    end
    function BBF.UpdateClassicMinimapDifficulty()
        local r, g, b = 0.588, 0.588, 0.6
        if BBF.MinimapBronzeTintActive and BBF.MinimapBronzeTintActive() then
            r, g, b = 0.573, 0.435, 0.216
        end
        for _, mode in ipairs({ difficulty.Default, difficulty.ChallengeMode }) do
            mode.Border:SetDesaturated(true)
            mode.Border:SetVertexColor(r, g, b, 1)
            mode.Background:SetVertexColor(0, 0, 0, 0.5)
        end
    end
    hooksecurefunc(difficulty, "SetFlipped", BBF.UpdateClassicMinimapDifficulty)
    BBF.UpdateClassicMinimapDifficulty()

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
    TintCycleBorder(Minimap)

    local coords = MinimapCluster.MinimapContainer.PlayerCoords
    local function Relayout()
        local width = Minimap:GetWidth()
        if not width or width <= 0 then return end
        local scale = width / SKIN_BASE_WIDTH
        skin:SetScale(scale)
        BBF.UpdateClassicMinimapLayout()

        local diel = MinimapCluster.DielFrame
        if diel then
            diel:SetScale(1 / scale)
            diel:ClearAllPoints()
            diel:SetPoint("CENTER", skin, "CENTER", 71 * scale, 35 * scale)
        end

    end
    if MinimapCluster.DielFrame then
        MinimapCluster.DielFrame:SetParent(skin)
        hooksecurefunc(MinimapCluster, "SetEditModeScale", Relayout)
    end
    Minimap:HookScript("OnSizeChanged", Relayout)
    Relayout()

    if Minimap:GetNumPoints() == 1 then
        Minimap.bbfBasePoint = { Minimap:GetPoint(1) }
    end
    hooksecurefunc(Minimap, "SetPoint", function(self, ...)
        if self.changing then return end
        self.bbfBasePoint = { ... }
        BBF.UpdateClassicMinimapLayout()
    end)
    BBF.UpdateClassicMinimapLayout()

    for _, frame in pairs({ MinimapCluster.BorderTop, GameTimeFrame, AddonCompartmentFrame, ExpansionLandingPageMinimapButton }) do
        frame:Hide()
        frame:HookScript("OnShow", frame.Hide)
    end

    EventUtil.ContinueOnAddOnLoaded("Blizzard_TimeManager", function()
        local clock = TimeManagerClockButton
        clock:SetParent(skin)
        clock:SetSize(60, 28)
        KeepPoint(clock, "CENTER", skin, "CENTER", 0, -74 - CLOCK_DROP * SKIN_BASE_WIDTH / Minimap:GetWidth())
        KeepPoint(TimeManagerClockTicker, "CENTER", clock, "CENTER", 3, 1.5)
        if coords then
            KeepPoint(coords, "TOP", TimeManagerClockTicker, "BOTTOM", 0, -1)
        end

        local background = clock:CreateTexture(nil, "BORDER")
        background:SetTexture("Interface\\TimeManager\\ClockBackground")
        background:SetTexCoord(0.015625, 0.8125, 0.015625, 0.390625)
        background:SetAllPoints(clock)
        table.insert(BBF.classicMinimapTextures, background)

        BBF.UpdateBronzeTint()
    end)
end
