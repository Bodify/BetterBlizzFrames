local DEFAULT_MAX_POINTS = 5
local PRD_Y_OFFSET = 9
local PLAYER_SCALE_OFFSET = 0.05
local REVEAL_FADE_TIME = 0.25
local TINT = { 1, 0.772, 0.34, 1 }
local TINT_CLASSIC_BRONZE = { 1, 0.749, 0.337, 1 }
local BORDER_KEYS = { "BGActive", "BGInactive", "BGGlow", "BG_Active", "BG_Inactive", "BG_Glow" }

local CLASS_INFO = {
    ROGUE = {
        template = "BBF_RogueComboPointTemplate",
        topPadding = 10,
        playerX = 2,
        playerY = 8,
        classicY = -1,
        prdY = 0,
        tooltip = "COMBO_POINTS_ROGUE_TOOLTIP",
    },
    DRUID = {
        template = "BBF_DruidComboPointTemplate",
        topPadding = 7,
        playerX = 2,
        playerY = 8,
        classicY = -1,
        prdY = 2,
        tooltip = "COMBO_POINTS_DRUID_TOOLTIP",
    },
}

local holder, playerBar, prdBar, updater, legacyHookInstalled
local ApplyTargetLayout, RestoreRowLayout

local function GetMaxPoints()
    local maxPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints) or 0
    if maxPoints <= 0 then
        maxPoints = DEFAULT_MAX_POINTS
    end
    return maxPoints
end

local function TintOwnedByDarkMode()
    return BetterBlizzFramesDB.darkModeUi and true or false
end

local function ApplyBorderTint(texture)
    local db = BetterBlizzFramesDB
    texture.bbfComboTinting = true
    if db.classicFrames and not db.classicFramesBronzeTint then
        texture:SetDesaturated(true)
        texture:SetVertexColor(1, 1, 1, 1)
    else
        local tint = (db.classicFrames and TINT_CLASSIC_BRONZE) or TINT
        texture:SetDesaturated(true)
        texture:SetVertexColor(tint[1], tint[2], tint[3], tint[4])
    end
    texture.bbfComboTinting = false
end

local function TintPoint(point)
    for _, key in ipairs(BORDER_KEYS) do
        local texture = point[key]
        if texture then
            if not texture.bbfComboTintHooked then
                texture.bbfComboTintHooked = true
                hooksecurefunc(texture, "SetVertexColor", function(self)
                    if self.bbfComboTinting or TintOwnedByDarkMode() then return end
                    ApplyBorderTint(self)
                end)
            end
            if not TintOwnedByDarkMode() then
                ApplyBorderTint(texture)
            end
        end
    end
end

local function TintBar(bar)
    if not bar then return end
    for _, point in ipairs(bar.pointPool) do
        TintPoint(point)
    end
end

function BBF.UpdateComboPointTint()
    TintBar(playerBar)
    TintBar(prdBar)
end

local function SetRogueInstant(point, isFull)
    point:ResetVisuals()
    point.isFull = isFull
    point.isCharged = false

    point.BGActive:SetAlpha(isFull and 1 or 0)
    point.BGInactive:SetAlpha(isFull and 0 or 1)
    point.IconUncharged:SetAlpha(isFull and 1 or 0)
    point.FXUncharged:SetAlpha(isFull and 1 or 0)
    point.IconCharged:SetAlpha(0)
    point.FXCharged:SetAlpha(0)
    point.ChargedFrameActive:SetAlpha(0)
    point.ChargedFrameInactive:SetAlpha(0)
end

local function SetDruidInstant(point, isActive)
    point:ResetVisuals()
    point.isActive = isActive

    point.Point_Icon:SetAlpha(isActive and 1 or 0)
    point.BG_Active:SetAlpha(isActive and 1 or 0)
    point.BG_Inactive:SetAlpha(isActive and 0 or 1)
end

local function UpdateBar(bar)
    local db = BetterBlizzFramesDB
    local instant = db.instantComboPoints
    local comboPoints = GetComboPoints("player", "target") or 0

    if bar.class == "ROGUE" then
        for i, point in ipairs(bar.classResourceButtonTable) do
            local isFull = i <= comboPoints
            if instant then
                SetRogueInstant(point, isFull)
            else
                point:Update(isFull, false)
            end
        end
    else
        for i, point in ipairs(bar.classResourceButtonTable) do
            local isActive = i <= comboPoints
            if instant then
                SetDruidInstant(point, isActive)
            else
                point:SetActive(isActive)
            end
        end
    end
end

local function UpdateMaxPower(bar)
    local maxPoints = GetMaxPoints()
    if bar.maxUsablePoints == maxPoints and #bar.classResourceButtonTable == maxPoints then return end

    bar.maxUsablePoints = maxPoints
    wipe(bar.classResourceButtonTable)

    for i = 1, math.max(maxPoints, #bar.pointPool) do
        local point = bar.pointPool[i]
        if i <= maxPoints then
            if not point then
                point = CreateFrame("Frame", nil, bar, bar.template)
                bar.pointPool[i] = point
            end
            point.layoutIndex = i
            point:Setup()
            TintPoint(point)
            bar.classResourceButtonTable[i] = point
        elseif point then
            point:ResetVisuals()
            point:Hide()
        end
    end

    if bar.class == "ROGUE" and not bar.isPrd then
        bar.leftPadding = maxPoints > DEFAULT_MAX_POINTS and (maxPoints - DEFAULT_MAX_POINTS) * -20 or 0
    end

    bar:Layout()
    UpdateBar(bar)

    if bar == playerBar then
        ApplyTargetLayout()
    end
end

local function ShowTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
    GameTooltip:SetText(self.tooltipTitle, 1, 1, 1)
    GameTooltip:AddLine(self.tooltip, nil, nil, nil, true)
    GameTooltip:Show()
end

local function HideTooltip()
    GameTooltip:Hide()
end

local function CreateBar(name, parent, class, isPrd)
    local info = CLASS_INFO[class]
    local bar = CreateFrame("Frame", name, parent, "HorizontalLayoutFrame")
    bar.spacing = 4
    bar.topPadding = info.topPadding
    bar.leftPadding = 0
    bar.class = class
    bar.template = info.template
    bar.isPrd = isPrd
    bar.powerType = Enum.PowerType.ComboPoints
    bar.powerToken = "COMBO_POINTS"
    bar.bbfForeverComboBar = true
    bar.classResourceButtonTable = {}
    bar.pointPool = {}

    bar.UpdatePower = UpdateBar
    bar.UpdateMaxPower = UpdateMaxPower

    if not isPrd and COMBO_POINTS_POWER and _G[info.tooltip] then
        bar.tooltipTitle = COMBO_POINTS_POWER
        bar.tooltip = _G[info.tooltip]
        bar:SetScript("OnEnter", ShowTooltip)
        bar:SetScript("OnLeave", HideTooltip)
        bar:EnableMouse(true)
        bar:SetMouseClickEnabled(false)
        bar.bbfTooltipMouse = true
    end

    UpdateMaxPower(bar)
    return bar
end

local TARGET_LAYOUTS = {
    DEFAULT = {
        xPos = -43, yPos = 1, pointScale = 0.6,
        classicXPos = -48, classicYPos = -1, classicPointScale = 0.55,
        points = { {-10.5, 47.5}, {7, 38}, {20, 21}, {27, 0}, {28, -22} },
        classic = { {8, 46.5}, {26, 33.5}, {39.5, 15.5}, {46.5, -6}, {46, -29} },
    },
}

local function MovedToTarget()
    local db = BetterBlizzFramesDB
    if not db.moveResourceToTarget then return false end
    local class = UnitClassBase("player")
    return (class == "ROGUE" and db.moveResourceToTargetRogue) or (class == "DRUID" and db.moveResourceToTargetDruid) or false
end

local function ResetBackgroundReveal()
    BBF.UIFrameFadeRemoveFrame(playerBar)
    playerBar.bbfRevealAlpha = nil
    playerBar:SetAlpha(1)
    if playerBar.bbfTooltipMouse then
        playerBar:EnableMouse(true)
    end
end

local function UpdateBackgroundReveal(force)
    if not playerBar then return end

    if not MovedToTarget() or playerBar.bbfRevealSuppressed then
        if playerBar.bbfRevealAlpha ~= nil then
            ResetBackgroundReveal()
        end
        return
    end

    local target = (GetComboPoints("player", "target") or 0) > 0 and 1 or 0
    local previous = playerBar.bbfRevealAlpha
    if not force and previous == target then return end

    playerBar.bbfRevealAlpha = target

    if playerBar.bbfTooltipMouse then
        playerBar:EnableMouse(target == 1)
    end

    if previous == nil or BetterBlizzFramesDB.instantComboPoints then
        BBF.UIFrameFadeRemoveFrame(playerBar)
        playerBar:SetAlpha(target)
        return
    end

    BBF.UIFrameFade(playerBar, {
        mode = (target == 1) and "IN" or "OUT",
        timeToFade = REVEAL_FADE_TIME,
        startAlpha = playerBar:GetAlpha() or (1 - target),
        endAlpha = target,
    })
end
BBF.UpdateComboPointBackgroundReveal = UpdateBackgroundReveal

local function ShouldShow()
    local db = BetterBlizzFramesDB
    if not db.foreverComboPoints then return false end

    if UnitInVehicle and UnitInVehicle("player") then
        return PlayerVehicleHasComboPoints and PlayerVehicleHasComboPoints() or false
    end

    if UnitClassBase("player") == "DRUID" then
        if UnitPowerType("player") == Enum.PowerType.Energy then return true end
        return db.druidAlwaysShowCombos and GetComboPoints("player", "target") > 0 or false
    end

    return true
end

local function PlatesWantsBar()
    local pdb = BBP and BetterBlizzPlatesDB
    return pdb and pdb.foreverComboPoints and not pdb.disablePrdMovement
        and not BetterBlizzFramesDB.prdResourceAdjust and true or false
end

local function PlatesCoversPrd()
    if not PlatesWantsBar() then return false end
    local pdb = BetterBlizzPlatesDB
    local onTarget = pdb.nameplateResourceOnTarget == "1" or pdb.nameplateResourceOnTarget == true
    return not onTarget or pdb.nameplateResourceOnTargetAndNoTargetOnSelf == true
end

function BBF.ComboPointsPlatesShouldShow()
    if not BetterBlizzFramesDB.foreverComboPoints then return true end
    return PlatesWantsBar()
end

local function OnTargetNameplate()
    return BBF.GetPrdResourceNameplate and BBF.GetPrdResourceNameplate() and true or false
end

local function PrdHidesClassInfo()
    if BetterBlizzFramesDB.hidePrdComboPoints and not OnTargetNameplate() then return true end
    local prd = PersonalResourceDisplayFrame
    return prd and prd.hideClassInfo and not BetterBlizzFramesDB.prdResourceAdjust or false
end

local function AnchorPrdBarToPrd(xOfs, yOfs)
    local prd = PersonalResourceDisplayFrame
    if not prd or not prdBar then return end

    local info = CLASS_INFO[prdBar.class]
    local y = PRD_Y_OFFSET + info.prdY - prd:GetBarPadding()
    local point, relativeTo, relativePoint = "TOP", prd, "TOP"
    if prd.AlternatePowerBar and prd.AlternatePowerBar:IsShown() then
        relativeTo, relativePoint = prd.AlternatePowerBar, "BOTTOM"
    elseif not prd.hidePower then
        relativeTo, relativePoint = prd.PowerBar, "BOTTOM"
    elseif not prd.hideHealth then
        relativeTo, relativePoint = prd.HealthBarsContainer, "BOTTOM"
    else
        y = PRD_Y_OFFSET + info.prdY
    end
    prdBar:SetParent(prd)
    prdBar:ClearAllPoints()
    prdBar:SetPoint(point, relativeTo, relativePoint, xOfs or 0, y + (yOfs or 0))
end

function BBF.UpdateComboPointPrdAnchor()
    if not prdBar then return end

    if BetterBlizzFramesDB.prdResourceAdjust then
        BBF.UpdatePrdResource()
        return
    end

    prdBar:SetScale(1)
    prdBar:SetFrameStrata("MEDIUM")
    AnchorPrdBarToPrd()
end

local function CreatePrdBar()
    local prd = PersonalResourceDisplayFrame
    if not prd then return end

    prdBar = CreateBar("BBFComboPointBarPRD", prd, playerBar.class, true)
    BBF.ComboPointPrdBar = prdBar
    prdBar.bbfPrdRestore = AnchorPrdBarToPrd
    AnchorPrdBarToPrd()

    hooksecurefunc(prd, "UpdateAdditionalBarAnchors", BBF.UpdateComboPointPrdAnchor)

    if BBF.DarkModeNameplateResources then
        BBF.DarkModeNameplateResources()
    end
end

function BBF.ReanchorComboPointBar()
    if not playerBar or not holder then return end
    UpdateBackgroundReveal(true)
    if MovedToTarget() then
        ApplyTargetLayout()
        return
    end
    RestoreRowLayout()
    if playerBar.bbfResourceDragging then return end

    local info = CLASS_INFO[playerBar.class]
    local baseY = BetterBlizzFramesDB.classicFrames and info.classicY or info.playerY
    local scale = playerBar:GetScale()
    if not scale or scale <= 0 then scale = 1 end
    playerBar.bbfPositioning = true
    playerBar:ClearAllPoints()
    playerBar:SetPoint("TOP", holder, "TOP", info.playerX, baseY + (BBF.classResourceNudgeY or 0) / scale)
    playerBar.bbfPositioning = nil
end

local function GetTargetPositions(layout)
    local db = BetterBlizzFramesDB
    if db.classicFrames and layout.classic then
        local scale = layout.classicPointScale or layout.pointScale
        local x = layout.classicXPos or layout.xPos
        local y = layout.classicYPos or layout.yPos
        if db.hideLevelText and db.hideLevelTextAlways and layout.classicHiddenLevel then
            return layout.classicHiddenLevel, scale, x, y
        end
        return layout.classic, scale, x, y
    end
    return layout.points, layout.pointScale, layout.xPos, layout.yPos
end

function ApplyTargetLayout()
    if not playerBar or not MovedToTarget() then return end

    local layout = TARGET_LAYOUTS[playerBar.class] or TARGET_LAYOUTS.DEFAULT
    if not layout or not TargetFrame then return end

    local db = BetterBlizzFramesDB
    local positions, pointScale, xPos, yPos = GetTargetPositions(layout)
    local custom = db.moveResourceToTargetCustom and db.customComboPositions and db.customComboPositions[playerBar.class]

    playerBar.bbfOnTarget = true
    playerBar.bbfPositioning = true
    playerBar:SetParent(TargetFrame)
    playerBar:ClearAllPoints()
    playerBar:SetPoint("LEFT", TargetFrame, "RIGHT", xPos, yPos)
    playerBar:SetFrameStrata("HIGH")
    playerBar:SetMouseClickEnabled(false)
    playerBar.bbfPositioning = nil

    if not playerBar.bbfTargetHooked then
        playerBar.bbfTargetHooked = true
        hooksecurefunc(playerBar, "SetPoint", function(self)
            if self.bbfPositioning or self.bbfResourceDragging or not MovedToTarget() then return end
            ApplyTargetLayout()
        end)
        hooksecurefunc(playerBar, "Layout", function(self)
            if self.bbfPositioning or not MovedToTarget() then return end
            ApplyTargetLayout()
        end)
    end

    for i, point in ipairs(playerBar.classResourceButtonTable) do
        local saved = custom and custom[i]
        if saved then
            saved[2] = UIParent
            point:ClearAllPoints()
            point:SetPoint(saved[1], UIParent, saved[3], saved[4], saved[5])
        elseif positions[i] then
            point:ClearAllPoints()
            point:SetPoint("TOPLEFT", playerBar, "TOPLEFT", positions[i][1], positions[i][2])
        end
        point:SetScale(pointScale)
    end
end
BBF.ApplyComboPointTargetLayout = ApplyTargetLayout

function RestoreRowLayout()
    if not playerBar or not playerBar.bbfOnTarget then return end
    playerBar.bbfOnTarget = nil

    for _, point in ipairs(playerBar.pointPool) do
        point:SetScale(1)
        point:ClearAllPoints()
    end
    playerBar:SetParent(holder)
    playerBar:SetFrameStrata("MEDIUM")
    playerBar:Layout()
end

local function SaveCustomPosition(point, index)
    local db = BetterBlizzFramesDB
    local class = playerBar and playerBar.class
    if not class then return end

    local anchor, _, relativePoint, x, y = point:GetPoint()
    db.customComboPositions = db.customComboPositions or {}
    db.customComboPositions[class] = db.customComboPositions[class] or {}
    db.customComboPositions[class][index] = { anchor, nil, relativePoint, x, y }
end

function BBF.ComboPointsEditMode(state)
    if not playerBar then return end

    playerBar.bbfRevealSuppressed = state and true or nil
    UpdateBackgroundReveal(true)

    for index, point in ipairs(playerBar.classResourceButtonTable) do
        if not point.bbfIndexLabel then
            local label = point:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            label:SetPoint("CENTER", point, "CENTER")
            label:SetText(index)
            point.bbfIndexLabel = label
        end
        point.bbfIndexLabel:SetText(index)
        point.bbfIndexLabel:SetShown(state)

        point:EnableMouse(state)
        point:SetMovable(state)
        point:SetMouseClickEnabled(state)
        point:RegisterForDrag("LeftButton")
        point:SetScript("OnDragStart", state and function(self)
            self:StartMoving()
        end or nil)
        point:SetScript("OnDragStop", state and function(self)
            self:StopMovingOrSizing()
            SaveCustomPosition(self, index)
        end or nil)
    end
end

function BBF.ApplyComboPointScale(scale)
    if not playerBar then return end
    playerBar:SetScale(math.max((scale or 1) - PLAYER_SCALE_OFFSET, 0.05))
    BBF.ReanchorComboPointBar()
end

function BBF.UpdateLegacyComboVisibility()
    local frame = ComboFrame
    if not frame then return end

    local hide = BetterBlizzFramesDB.foreverComboPoints and CLASS_INFO[UnitClassBase("player")] and true or false
    if hide == (frame.bbfComboPointsHidden or false) then return end
    frame.bbfComboPointsHidden = hide or nil

    if hide then
        if not legacyHookInstalled then
            legacyHookInstalled = true
            frame:HookScript("OnShow", function(self)
                if self.bbfComboPointsHidden then
                    self:Hide()
                end
            end)
        end
        frame:Hide()
    elseif ComboFrame_Update then
        ComboFrame_Update(frame)
    end
end

function BBF.UpdateComboPointBars()
    if not playerBar then return end

    local show = ShouldShow()
    local showPrd = show and not PlatesCoversPrd() and not PrdHidesClassInfo()
    if showPrd and not prdBar then
        CreatePrdBar()
        BBF.UpdateComboPointPrdAnchor()
    end

    if MovedToTarget() and playerBar:GetParent() ~= TargetFrame then
        ApplyTargetLayout()
    end

    playerBar:SetShown(show)
    if prdBar then
        prdBar:SetShown(showPrd)
    end

    if show then
        playerBar:UpdatePower()
    end
    if showPrd and prdBar then
        prdBar:UpdatePower()
    end

    UpdateBackgroundReveal()
end

local function RefreshMaxPower()
    if playerBar then
        UpdateMaxPower(playerBar)
    end
    if prdBar then
        UpdateMaxPower(prdBar)
    end
end

local function SyncHolder()
    local container = PlayerBottomManagedFrameContainer
    holder:SetScale(container:GetScale())
    holder:SetFrameStrata(container:GetFrameStrata())
end

local function CreateHolder()
    local container = PlayerBottomManagedFrameContainer
    holder = CreateFrame("Frame", "BBFComboPointHolder", PlayerFrame)
    holder:SetSize(1, 1)
    holder:SetPoint("TOP", container, "TOP", 0, 0)
    SyncHolder()
    hooksecurefunc(container, "SetScale", SyncHolder)
    hooksecurefunc(container, "SetFrameStrata", SyncHolder)
end

local function CreateUpdater(class)
    updater = CreateFrame("Frame")
    updater:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    updater:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    updater:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
    updater:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
    updater:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
    updater:RegisterEvent("PLAYER_ENTERING_WORLD")
    updater:RegisterEvent("PLAYER_TARGET_CHANGED")
    updater:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    updater:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    if class == "DRUID" then
        updater:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    end

    updater:SetScript("OnEvent", function(_, event, _, powerToken)
        if event == "UNIT_POWER_FREQUENT" then
            if powerToken ~= "COMBO_POINTS" then return end
        elseif event == "UNIT_MAXPOWER" or event == "PLAYER_ENTERING_WORLD" then
            RefreshMaxPower()
        end

        BBF.UpdateComboPointBars()

        if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TARGET_CHANGED"
            or event == "NAME_PLATE_UNIT_ADDED" or event == "NAME_PLATE_UNIT_REMOVED" then
            BBF.UpdateComboPointPrdAnchor()
        end

        if event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_SHAPESHIFT_FORM" then
            ApplyTargetLayout()
        end
    end)
end

function BBF.CreateComboPointBars()
    if not BetterBlizzFramesDB.foreverComboPoints then return end
    local class = UnitClassBase("player")
    if not CLASS_INFO[class] then return end
    if (class == "ROGUE" and _G.RogueComboPointBarFrame) or (class == "DRUID" and _G.DruidComboPointBarFrame) then return end
    if playerBar then
        BBF.UpdateComboPointBars()
        return
    end
    if not PlayerFrame or not PlayerBottomManagedFrameContainer then return end

    CreateHolder()
    playerBar = CreateBar("BBFComboPointBar", holder, class, false)
    BBF.ComboPointBar = playerBar
    BBF.resourceFrames[class] = playerBar
    BBF.classPowerFrames[class] = playerBar

    BBF.ApplyComboPointScale(BetterBlizzFramesDB["classResource" .. class .. "Scale"])
    CreateUpdater(class)

    local prd = PersonalResourceDisplayFrame
    if prd and prd.SetHideClassInfo then
        hooksecurefunc(prd, "SetHideClassInfo", BBF.UpdateComboPointBars)
    end

    BBF.UpdateComboPointBars()
    BBF.UpdateComboPointPrdAnchor()
    BBF.UpdateLegacyComboVisibility()
    ApplyTargetLayout()

    C_Timer.After(1, ApplyTargetLayout)
end
