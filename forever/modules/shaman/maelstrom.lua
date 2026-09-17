local MAELSTROM_WEAPON = 344179
local MAX_POINTS = 5
local ENHANCEMENT_SPEC_INDEX = 2
local PRD_Y_OFFSET = 9

local playerBar, prdBar, updater, specWatcher, legacyActive

local function GetStacks()
    local aura = C_UnitAuras.GetPlayerAuraBySpellID(MAELSTROM_WEAPON)
    return (aura and aura.applications) or 0
end

local function SetPointInstant(point, isFull, isCharged)
    point:ResetVisuals()
    point.isFull = isFull
    point.isCharged = isCharged

    point.BGActive:SetAlpha(isFull and 1 or 0)
    point.BGInactive:SetAlpha(isFull and 0 or 1)
    point.IconUncharged:SetAlpha(isFull and not isCharged and 1 or 0)
    point.IconCharged:SetAlpha(isFull and isCharged and 1 or 0)
    point.FXUncharged:SetAlpha(isFull and not isCharged and 1 or 0)
    point.FXCharged:SetAlpha(isFull and isCharged and 1 or 0)
    point.ChargedFrameActive:SetAlpha(isCharged and isFull and 1 or 0)
    point.ChargedFrameInactive:SetAlpha(isCharged and not isFull and 1 or 0)
end

local function UpdateBar(bar, stacks)
    if not bar then return end
    local instant = BetterBlizzFramesDB.instantComboPoints
    for i = 1, MAX_POINTS do
        local point = bar.classResourceButtonTable[i]
        if point then
            local isFull, isCharged = i <= stacks, stacks >= i + MAX_POINTS
            if instant then
                SetPointInstant(point, isFull, isCharged)
            else
                point:Update(isFull, isCharged)
            end
        end
    end
end

local function RecolorUnchargedArt(point)
    point.IconUncharged:SetAtlas("uf-roguecp-icon-blue", true)
    point.FXUncharged:SetAtlas("uf-roguecp-fx-blue", true)
    point.SlashFBUncharged:SetAtlas("uf-roguecp-slash-blue")

    point.IconUncharged:SetDesaturated(true)
    point.FXUncharged:SetDesaturated(true)
    point.SlashFBUncharged:SetDesaturated(true)

    point.IconUncharged:SetVertexColor(0.365, 0.643, 1, 1)
    point.FXUncharged:SetVertexColor(0.365, 0.643, 1, 1)
    point.SlashFBUncharged:SetVertexColor(0.365, 0.643, 1, 1)
end

local function CreatePoint(bar, index)
    local point = CreateFrame("Frame", nil, bar, "RogueComboPointTemplate")
    point.layoutIndex = index
    RecolorUnchargedArt(point)
    point:Setup()
    return point
end

local function CreateBar(name, parent)
    local bar = CreateFrame("Frame", name, parent, "HorizontalLayoutFrame")
    bar.spacing = 4
    bar.topPadding = 10
    bar.leftPadding = 0
    bar.maxUsablePoints = MAX_POINTS
    bar.powerType = Enum.PowerType.ComboPoints
    bar.classResourceButtonTable = {}

    for i = 1, MAX_POINTS do
        bar.classResourceButtonTable[i] = CreatePoint(bar, i)
    end

    bar.UpdatePower = function(self)
        UpdateBar(self, GetStacks())
    end

    bar:Layout()
    return bar
end

local function LegacyOwnsDisplay()
    return BetterBlizzFramesDB.enableLegacyComboPoints
        and BetterBlizzFramesDB.enableLegacyComboPointsMulticlass
        and C_CVar.GetCVar("comboPointLocation") == "1"
        and not BetterBlizzFramesDB.ignoreShamanLegacyCombos
end

local function UpdateTotemOffset()
    local totem = TotemFrame
    if not totem or totem.bbfShifting then return end

    local base = totem.bbfBasePoint
    if not base then return end

    if InCombatLockdown() and totem:IsProtected() then
        BBF.RunAfterCombat(UpdateTotemOffset)
        return
    end

    local drop = 0
    if playerBar and playerBar:IsShown() then
        local height = playerBar:GetHeight()
        if height and height > 0 then
            drop = (height * (playerBar:GetScale() or 1)) + 2
        end
    end

    totem.bbfShifting = true
    totem:ClearAllPoints()
    totem:SetPoint(base.point, base.relativeTo, base.relativePoint, base.x, base.y - drop)
    totem.bbfShifting = false
end

local function NormalizePoint(frame, point, a, b, c, d)
    if not point then return end
    if type(a) == "number" or a == nil then
        return { point = point, relativeTo = frame:GetParent(), relativePoint = point, x = a or 0, y = b or 0 }
    end
    return { point = point, relativeTo = a, relativePoint = b or point, x = c or 0, y = d or 0 }
end

local function HookTotemFrame()
    local totem = TotemFrame
    if not totem or totem.bbfTotemHooked then return end
    totem.bbfTotemHooked = true

    totem.bbfBasePoint = NormalizePoint(totem, totem:GetPoint())

    hooksecurefunc(totem, "SetPoint", function(self, point, a, b, c, d)
        if self.bbfShifting then return end
        self.bbfBasePoint = NormalizePoint(self, point, a, b, c, d)
        UpdateTotemOffset()
    end)

    UpdateTotemOffset()
end

local function PlatesWantsBar()
    local pdb = BBP and BetterBlizzPlatesDB
    return pdb and pdb.shamanMaelstromCombos and not pdb.disablePrdMovement
        and not BetterBlizzFramesDB.prdResourceAdjust and true or false
end

local function PlatesCoversPrd()
    if not PlatesWantsBar() then return false end
    local pdb = BetterBlizzPlatesDB
    local onTarget = pdb.nameplateResourceOnTarget == "1" or pdb.nameplateResourceOnTarget == true
    return not onTarget or pdb.nameplateResourceOnTargetAndNoTargetOnSelf == true
end

function BBF.MaelstromPlatesShouldShow()
    if not BetterBlizzFramesDB.shamanMaelstromCombos or LegacyOwnsDisplay() then return true end
    return PlatesWantsBar()
end

local function AnchorPrdBarToPrd(xOfs, yOfs)
    local prd = PersonalResourceDisplayFrame
    if not prd then return end

    local y = PRD_Y_OFFSET - prd:GetBarPadding()
    local point, relativeTo, relativePoint = "TOP", prd, "TOP"
    if prd.AlternatePowerBar and prd.AlternatePowerBar:IsShown() then
        relativeTo, relativePoint = prd.AlternatePowerBar, "BOTTOM"
    elseif not prd.hidePower then
        relativeTo, relativePoint = prd.PowerBar, "BOTTOM"
    elseif not prd.hideHealth then
        relativeTo, relativePoint = prd.HealthBarsContainer, "BOTTOM"
    else
        y = PRD_Y_OFFSET
    end
    prdBar:SetParent(prd)
    prdBar:ClearAllPoints()
    prdBar:SetPoint(point, relativeTo, relativePoint, xOfs or 0, y + (yOfs or 0))
end

function BBF.UpdateMaelstromPrdAnchor()
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

    prdBar = CreateBar("BBFMaelstromWeaponBarPRD", prd)
    BBF.MaelstromWeaponPrdBar = prdBar
    prdBar.bbfPrdRestore = AnchorPrdBarToPrd
    AnchorPrdBarToPrd()

    hooksecurefunc(prd, "UpdateAdditionalBarAnchors", BBF.UpdateMaelstromPrdAnchor)

    if BBF.DarkModeNameplateResources then
        BBF.DarkModeNameplateResources()
    end
end

function BBF.UpdateMaelstromWeaponBar()
    if not playerBar then return end

    local show = BetterBlizzFramesDB.shamanMaelstromCombos
        and BBF.GetSpecialization() == ENHANCEMENT_SPEC_INDEX and not LegacyOwnsDisplay()
    local showPrd = show and not PlatesCoversPrd()
    if showPrd and not prdBar then
        CreatePrdBar()
        BBF.UpdateMaelstromPrdAnchor()
    end

    playerBar:SetShown(show)
    if prdBar then
        prdBar:SetShown(showPrd)
    end
    if playerBar.bbfLastShown ~= show then
        playerBar.bbfLastShown = show
        UpdateTotemOffset()
    end
    if not show then return end

    playerBar:UpdatePower()
    if showPrd and prdBar then
        prdBar:UpdatePower()
    end
end

local function CreateUpdater()
    updater = CreateFrame("Frame")
    updater:RegisterUnitEvent("UNIT_AURA", "player")
    updater:RegisterEvent("PLAYER_ENTERING_WORLD")
    updater:RegisterEvent("PLAYER_TARGET_CHANGED")
    updater:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    updater:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    updater:SetScript("OnEvent", function(_, event)
        if event == "UNIT_AURA" then
            BBF.UpdateMaelstromWeaponBar()
        elseif event == "PLAYER_ENTERING_WORLD" then
            BBF.UpdateMaelstromWeaponBar()
            BBF.UpdateMaelstromPrdAnchor()
        else
            BBF.UpdateMaelstromPrdAnchor()
        end
    end)
end

function BBF.CreateMaelstromWeaponBar()
    if not BetterBlizzFramesDB.shamanMaelstromCombos then return end
    if UnitClassBase("player") ~= "SHAMAN" then return end
    if BBF.MaelstromWeaponBarsBuilt then
        BBF.UpdateMaelstromWeaponBar()
        return
    end

    if not specWatcher then
        specWatcher = CreateFrame("Frame")
        specWatcher:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        specWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
        specWatcher:SetScript("OnEvent", function()
            BBF.CreateMaelstromWeaponBar()
        end)
    end

    if BBF.GetSpecialization() ~= ENHANCEMENT_SPEC_INDEX then return end

    playerBar = CreateBar("BBFMaelstromWeaponBar", PlayerFrame)
    playerBar:SetPoint("TOP", PlayerBottomManagedFrameContainer, "TOP", 0, 4)
    BBF.MaelstromWeaponBar = playerBar

    BBF.resourceFrames.SHAMAN = playerBar
    BBF.classPowerFrames.SHAMAN = playerBar

    CreateUpdater()
    HookTotemFrame()

    BBF.MaelstromWeaponBarsBuilt = true
    BBF.UpdateMaelstromWeaponBar()
    BBF.UpdateMaelstromPrdAnchor()
end

function BBF.ShamanLegacyMaelstrom()
    if not BetterBlizzFramesDB.shamanMaelstromCombos then return end
    if UnitClassBase("player") ~= "SHAMAN" then return end
    if legacyActive then return end
    if not LegacyOwnsDisplay() then return end
    if not ComboFrame or not ComboFrame.ComboPoints then return end

    local function UpdateShamanLegacyCombo()
        local frame = ComboFrame
        if not frame.ComboPoints then return end

        local stacks = BBF.GetSpecialization() == ENHANCEMENT_SPEC_INDEX and GetStacks() or 0
        local showAlways = BetterBlizzFramesDB.alwaysShowLegacyComboPoints
        local comboIndex = 2

        for i = 1, MAX_POINTS do
            local point = frame.ComboPoints[comboIndex]
            if point then
                local isActive = i <= stacks
                point:Show()
                point:SetAlpha(1)
                point:SetShown(showAlways or isActive)

                if point.Highlight then
                    point.Highlight:SetAlpha(isActive and 1 or 0)

                    local isBlue = stacks >= i + MAX_POINTS
                    if isBlue and not point.bbfMaelstromBlue then
                        point.Highlight:SetAtlas("AncientMana")
                        point.Highlight:SetTexCoord(0, 1, 0, 1)
                        point.Highlight:SetSize(14, 14)
                        point.Highlight:SetPoint("TOPLEFT", point, "TOPLEFT", -1, 1.5)
                        point.bbfMaelstromBlue = true
                    elseif not isBlue and point.bbfMaelstromBlue then
                        point.Highlight:SetTexture(130973)
                        point.Highlight:SetTexCoord(0.375, 0.5625, 0, 1)
                        point.Highlight:SetSize(8, 16)
                        point.Highlight:SetPoint("TOPLEFT", point, "TOPLEFT", 2, 0)
                        point.bbfMaelstromBlue = false
                    end
                end

                comboIndex = comboIndex + 1
            end
        end

        if stacks == 0 and not showAlways then
            frame:Hide()
        else
            frame:SetAlpha(1)
            frame:Show()
        end

        BBF.UIFrameFadeRemoveFrame(frame)
    end

    hooksecurefunc("ComboFrame_Update", UpdateShamanLegacyCombo)

    local auraWatch = CreateFrame("Frame")
    auraWatch:RegisterUnitEvent("UNIT_AURA", "player")
    auraWatch:RegisterEvent("PLAYER_ENTERING_WORLD")
    auraWatch:SetScript("OnEvent", UpdateShamanLegacyCombo)

    legacyActive = true
    UpdateShamanLegacyCombo()
end
