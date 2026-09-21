local boundRings = {}
local ringRefreshers = {}
local ringsForcedHidden = false

local function BindLevelRing(levelText, ring)
    if not levelText or not ring then return end
    if boundRings[ring] then return end
    boundRings[ring] = true

    local originalParent = levelText:GetParent()
    local anchoredToRing = true

    local function Refresh()
        if ring.bbfRefreshing then return end
        ring.bbfRefreshing = true
        local ownedByBlizzard = anchoredToRing and levelText:GetParent() == originalParent
        if ringsForcedHidden or not ownedByBlizzard then
            ring:Hide()
        else
            ring:Show()
            ring:SetAlpha(levelText:GetAlpha())
        end
        ring.bbfRefreshing = false
    end

    tinsert(ringRefreshers, Refresh)

    hooksecurefunc(levelText, "SetPoint", function(_, _, relativeTo)
        anchoredToRing = (relativeTo == ring)
        Refresh()
    end)

    hooksecurefunc(levelText, "SetParent", Refresh)
    hooksecurefunc(levelText, "SetAlpha", Refresh)
    hooksecurefunc(ring, "Show", function()
        if ringsForcedHidden and not ring.bbfRefreshing then
            Refresh()
        end
    end)

    Refresh()
end

function BBF.SetLevelRingsHidden(hidden)
    ringsForcedHidden = hidden and true or false
    BBF.BindLevelRings()
    for _, Refresh in ipairs(ringRefreshers) do
        Refresh()
    end
end

function BBF.BindLevelRings()
    if BBF.levelRingsBound then return end
    BBF.levelRingsBound = true

    local playerMain = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain
    BindLevelRing(PlayerLevelText, playerMain.LevelBackgroundCircle)

    local function BindTargetStyle(frame)
        if not frame or not frame.TargetFrameContent then return end
        local main = frame.TargetFrameContent.TargetFrameContentMain
        BindLevelRing(main.LevelText, main.LevelBackgroundCircle)
    end

    BindTargetStyle(TargetFrame)
    BindTargetStyle(FocusFrame)
    for i = 1, MAX_BOSS_FRAMES or 5 do
        BindTargetStyle(_G["Boss" .. i .. "TargetFrame"])
    end
end

local function RaisePvpIconAboveCircle(container)
    local circle = container and container.PvpBackgroundCircle
    local icon = container and container.PvpBackgroundIcon
    if not circle or not icon then return end
    local circleLayer, circleSubLevel = circle:GetDrawLayer()
    local iconLayer, iconSubLevel = icon:GetDrawLayer()
    if iconLayer == circleLayer and iconSubLevel <= circleSubLevel then
        icon:SetDrawLayer(circleLayer, circleSubLevel + 1)
    end
end

function BBF.FixPvpIconDrawOrder()
    RaisePvpIconAboveCircle(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain)
    RaisePvpIconAboveCircle(TargetFrame.TargetFrameContent.TargetFrameContentContextual)
    RaisePvpIconAboveCircle(FocusFrame.TargetFrameContent.TargetFrameContentContextual)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    BBF.BindLevelRings()
    BBF.ApplyPlayerLevelColor()
    BBF.FixPvpIconDrawOrder()
end)

local pvpBadgeRegions = {}
local pvpBadgeParents = {}

local function CollectPvpBadge(container)
    if not container then return end
    if container.PvpBackgroundCircle then
        tinsert(pvpBadgeRegions, container.PvpBackgroundCircle)
    end
    if container.PvpBackgroundIcon then
        tinsert(pvpBadgeRegions, container.PvpBackgroundIcon)
    end
end

function BBF.SetPvpBadgeShown(shown)
    if #pvpBadgeRegions == 0 then
        CollectPvpBadge(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain)
        CollectPvpBadge(TargetFrame.TargetFrameContent.TargetFrameContentContextual)
        if FocusFrame then
            CollectPvpBadge(FocusFrame.TargetFrameContent.TargetFrameContentContextual)
        end
        for _, region in ipairs(pvpBadgeRegions) do
            pvpBadgeParents[region] = region:GetParent()
        end
    end

    for _, region in ipairs(pvpBadgeRegions) do
        if shown then
            region:SetParent(pvpBadgeParents[region])
        else
            region:SetParent(BBF.hiddenFrame)
        end
    end
end

local specInfo = C_SpecializationInfo

function BBF.GetSpecialization()
    if GetSpecialization then return GetSpecialization() end
    if specInfo and specInfo.GetSpecialization then return specInfo.GetSpecialization() end
    return nil
end

function BBF.GetSpecializationInfo(specIndex)
    if not specIndex then return nil end
    if GetSpecializationInfo then return GetSpecializationInfo(specIndex) end
    if specInfo and specInfo.GetSpecializationInfo then return specInfo.GetSpecializationInfo(specIndex) end
    return nil
end

local PLAYER_LEVEL_R, PLAYER_LEVEL_G, PLAYER_LEVEL_B = 1.0, 0.82, 0.0

local function BBFOwnsLevelColor()
    local db = BetterBlizzFramesDB
    if not db then return false end
    if db.unitFrameFontColor and db.unitFrameFontColorLvl then return true end
    if db.classColorTargetNames and db.classColorLevelText then return true end
    return false
end

function BBF.ApplyPlayerLevelColor()
    if not UnitExists("player") then return end
    if BBFOwnsLevelColor() then return end
    local unit = PlayerFrame.unit
    if UnitLevel(unit) ~= UnitEffectiveLevel(unit) then return end
    PlayerLevelText:SetVertexColor(PLAYER_LEVEL_R, PLAYER_LEVEL_G, PLAYER_LEVEL_B, 1.0)
end

hooksecurefunc("PlayerFrame_UpdateLevel", BBF.ApplyPlayerLevelColor)

local BRONZE_R, BRONZE_G, BRONZE_B = 0.95, 0.68, 0.35
local MINIMAP_BRONZE_R, MINIMAP_BRONZE_G, MINIMAP_BRONZE_B = 1, 0.71, 0.34
local bronzedTextures = {}
local bronzedMinimapTextures = {}

local function BronzeTintActive()
    local db = BetterBlizzFramesDB
    return db.classicFrames and db.classicFramesBronzeTint and not db.darkModeUi and not db.classColorFrameTexture
end

local function MinimapBronzeTintActive()
    local db = BetterBlizzFramesDB
    return db.classicMinimap and db.classicFramesBronzeTint and not (db.darkModeUi and db.darkModeMinimap)
end

local function SetBronze(texture)
    texture.bbfBronzeChanging = true
    if texture.bbfBronzeMinimap then
        texture:SetDesaturated(true)
        texture:SetVertexColor(MINIMAP_BRONZE_R, MINIMAP_BRONZE_G, MINIMAP_BRONZE_B, 1)
    else
        texture:SetDesaturated(true)
        texture:SetVertexColor(BRONZE_R, BRONZE_G, BRONZE_B, 1)
    end
    texture.bbfBronzeChanging = false
end

local function BronzeTexture(texture, isMinimap)
    if not texture or texture:IsForbidden() then return end
    if not texture.bbfBronzeHooked then
        texture.bbfBronzeHooked = true
        texture.bbfBronzeMinimap = isMinimap
        tinsert(isMinimap and bronzedMinimapTextures or bronzedTextures, texture)
        hooksecurefunc(texture, "SetVertexColor", function(self)
            if self.bbfBronzeChanging then return end
            if self.bbfBronzeMinimap then
                if not MinimapBronzeTintActive() then return end
            elseif not BronzeTintActive() then
                return
            end
            SetBronze(self)
        end)
    end
    SetBronze(texture)
end

local function GetUnitFrameBorderTextures()
    local textures = {
        PlayerFrame.PlayerFrameContainer.FrameTexture,
        PlayerFrame.PlayerFrameContainer.FrameTextureBBF,
        PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture,
        PlayerFrame.PlayerFrameContainer.VehicleFrameTexture,
        TargetFrame.TargetFrameContainer.FrameTexture,
        TargetFrame.TargetFrameContainer.FrameTextureBBF,
        TargetFrame.totFrame and TargetFrame.totFrame.FrameTexture,
        FocusFrame and FocusFrame.TargetFrameContainer.FrameTexture,
        FocusFrameToT and FocusFrameToT.FrameTexture,
        PetFrameTexture,
    }
    for i = 1, 5 do
        local boss = _G["Boss" .. i .. "TargetFrame"]
        if boss then
            tinsert(textures, boss.TargetFrameContainer.FrameTexture)
        end
    end
    if PartyFrame then
        for i = 1, 4 do
            local member = PartyFrame["MemberFrame" .. i]
            if member then
                tinsert(textures, member.Texture)
            end
        end
    end
    return textures
end

local function GetClassicCastbarBorderTextures()
    local db = BetterBlizzFramesDB
    local textures = {}
    if db.classicCastbars then
        tinsert(textures, TargetFrameSpellBar and TargetFrameSpellBar.Border)
        tinsert(textures, FocusFrameSpellBar and FocusFrameSpellBar.Border)
    end
    if db.classicCastbarsPlayer then
        tinsert(textures, PlayerCastingBarFrame and PlayerCastingBarFrame.Border)
        tinsert(textures, PetCastingBarFrame and PetCastingBarFrame.Border)
    end
    if db.classicCastbarsParty and db.showPartyCastbar then
        for i = 1, 5 do
            local partyCastbar = _G["Party" .. i .. "SpellBar"]
            if partyCastbar then
                tinsert(textures, partyCastbar.Border)
            end
        end
    end
    return textures
end

local function GetClassicMinimapTextures()
    local textures = {}
    if not BBF.classicMinimapTextures then return textures end
    for _, texture in ipairs(BBF.classicMinimapTextures) do
        tinsert(textures, texture)
    end
    tinsert(textures, MinimapCompassTexture)
    return textures
end

local PVP_CIRCLE_R, PVP_CIRCLE_G, PVP_CIRCLE_B = 1, 0.9, 0.19

local function GetPvpCircles()
    return {
        PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.PvpBackgroundCircle,
        TargetFrame.TargetFrameContent.TargetFrameContentContextual.PvpBackgroundCircle,
        FocusFrame and FocusFrame.TargetFrameContent.TargetFrameContentContextual.PvpBackgroundCircle,
    }
end

function BBF.UpdateClassicPvpCircles()
    if not BetterBlizzFramesDB.classicFrames then return end
    local r, g, b = PVP_CIRCLE_R, PVP_CIRCLE_G, PVP_CIRCLE_B
    if BronzeTintActive() then
        r, g, b = BRONZE_R, BRONZE_G, BRONZE_B
    end
    for _, circle in pairs(GetPvpCircles()) do
        if not circle:IsForbidden() then
            circle:SetDesaturated(true)
            circle:SetVertexColor(r, g, b, 1)
        end
    end
end

local eliteOverlayClassifications = { elite = true, worldboss = true, rareelite = true }
local ELITE_OVERLAY_R, ELITE_OVERLAY_G, ELITE_OVERLAY_B = 1, 0.816, 0.251

local hdEliteOverlays = {
    rare = { atlas = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare-Silver", width = 97.5, height = 102, x = 22, y = 20 },
    rareelite = { atlas = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged", width = 107, height = 92, x = 32, y = 15, desaturated = true },
    elite = { atlas = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold", width = 97.5, height = 102, x = 22, y = 20 },
    worldboss = { atlas = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged", width = 107, height = 92, x = 32, y = 15 },
}

local function HDEliteActive()
    local db = BetterBlizzFramesDB
    return db.classicFrames and db.classicFramesHDElite and not db.hideRareDragonTexture
end
BBF.ClassicHDEliteActive = HDEliteActive

function BBF.UpdateClassicEliteOverlay(frame)
    local classicFrame = frame and frame.ClassicFrame
    if not classicFrame or not classicFrame.Texture then return end
    local classification = frame.unit and UnitExists(frame.unit) and UnitClassification(frame.unit)
    local db = BetterBlizzFramesDB
    local darkModeKeepsDragon = db.classicFrames and db.darkModeUi and not db.darkModeEliteTexture
    local overlay = classicFrame.EliteOverlay
    if not ((BronzeTintActive() or darkModeKeepsDragon) and not db.hideRareDragonTexture and not HDEliteActive() and eliteOverlayClassifications[classification]) then
        if overlay then overlay:Hide() end
        return
    end
    if not overlay then
        overlay = classicFrame:CreateTexture(nil, "OVERLAY")
        overlay:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\eliteOverlayClassic")
        overlay:SetAllPoints(classicFrame.Texture)
        classicFrame.EliteOverlay = overlay
    end
    local layer, subLevel = classicFrame.Texture:GetDrawLayer()
    overlay:SetDrawLayer(layer, math.min((subLevel or 0) + 1, 7))
    overlay:SetTexCoord(classicFrame.Texture:GetTexCoord())
    if classification == "rareelite" then
        overlay:SetDesaturated(true)
        overlay:SetVertexColor(1, 1, 1, 1)
    else
        overlay:SetDesaturated(false)
        overlay:SetVertexColor(ELITE_OVERLAY_R, ELITE_OVERLAY_G, ELITE_OVERLAY_B, 1)
    end
    overlay:Show()
end

function BBF.UpdateClassicHDElite(frame)
    local classicFrame = frame and frame.ClassicFrame
    if not classicFrame then return end
    local portrait = frame.TargetFrameContainer and frame.TargetFrameContainer.Portrait
    if not portrait then return end
    local overlay = classicFrame.HDElite
    local classification = frame.unit and UnitExists(frame.unit) and UnitClassification(frame.unit)
    local bossTexture = frame.TargetFrameContainer.BossPortraitFrameTexture
    if classification and bossTexture and bossTexture:IsShown() then
        local atlas = bossTexture:GetAtlas()
        if atlas and not (issecretvalue and issecretvalue(atlas)) and atlas:lower():find("gold-winged", 1, true) then
            classification = "worldboss"
        end
    end
    local data = HDEliteActive() and classification and hdEliteOverlays[classification]
    if not data then
        if overlay then overlay:Hide() end
        return
    end
    if not overlay then
        overlay = classicFrame:CreateTexture(nil, "OVERLAY", nil, 6)
        classicFrame.HDElite = overlay
    end
    local db = BetterBlizzFramesDB
    overlay:SetAtlas(data.atlas)
    overlay:SetSize(data.width, data.height)
    overlay:ClearAllPoints()
    overlay:SetPoint("TOPRIGHT", portrait, "TOPRIGHT", data.x, data.y)
    if db.darkModeUi and db.darkModeEliteTexture then
        local v = db.darkModeColor + 0.25
        overlay:SetDesaturated(db.darkModeEliteTextureDesaturated or data.desaturated or false)
        overlay:SetVertexColor(v, v, v, 1)
    else
        overlay:SetDesaturated(data.desaturated or false)
        overlay:SetVertexColor(1, 1, 1, 1)
    end
    overlay:Show()
end

function BBF.RefreshClassicHDElite()
    if not BetterBlizzFramesDB.classicFrames then return end
    for _, frame in ipairs({ TargetFrame, FocusFrame }) do
        local classicFrame = frame and frame.ClassicFrame
        if classicFrame then
            if classicFrame.RefreshEliteArt then
                classicFrame.RefreshEliteArt()
            else
                BBF.UpdateClassicHDElite(frame)
            end
            BBF.UpdateClassicEliteOverlay(frame)
        end
    end
    if BetterBlizzFramesDB.playerEliteFrame then
        if BBF.UpdateClassicPlayerArt then
            BBF.UpdateClassicPlayerArt()
        end
        BBF.PlayerElite(BetterBlizzFramesDB.playerEliteFrameMode)
    end
end

function BBF.UpdateBronzeTint()
    BBF.UpdateClassicPvpCircles()
    BBF.UpdateClassicEliteOverlay(TargetFrame)
    BBF.UpdateClassicEliteOverlay(FocusFrame)
    if BronzeTintActive() then
        for _, texture in pairs(GetUnitFrameBorderTextures()) do
            BronzeTexture(texture)
        end
        for _, texture in pairs(GetClassicCastbarBorderTextures()) do
            BronzeTexture(texture)
        end
    elseif not BetterBlizzFramesDB.darkModeUi then
        for _, texture in ipairs(bronzedTextures) do
            if not texture:IsForbidden() then
                texture:SetVertexColor(1, 1, 1, 1)
            end
        end
    end

    if MinimapBronzeTintActive() then
        for _, texture in pairs(GetClassicMinimapTextures()) do
            BronzeTexture(texture, true)
        end
    elseif not (BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeMinimap) then
        for _, texture in ipairs(bronzedMinimapTextures) do
            if not texture:IsForbidden() then
                texture:SetDesaturated(false)
                texture:SetVertexColor(1, 1, 1, 1)
            end
        end
    end
end

local bagSlotNames = {"MainMenuBarBackpackButton", "CharacterBag0Slot", "CharacterBag1Slot", "CharacterBag2Slot", "CharacterBag3Slot"}
local bagSlotIconNames = {"MainMenuBarBackpackButton", "CharacterBag0Slot", "CharacterBag1Slot", "CharacterBag2Slot", "CharacterBag3Slot", "CharacterReagentBag0Slot"}
local desaturatedIconNames = {"MainMenuBarBackpackButton", "CharacterBag0Slot", "CharacterBag1Slot", "CharacterBag2Slot", "CharacterBag3Slot", "CharacterReagentBag0Slot", "KeyRingButton"}
local actionButtonPrefixes = {"ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton", "MultiBarLeftButton", "MultiBar5Button", "MultiBar6Button", "MultiBar7Button", "PetActionButton", "StanceButton"}

local function ActionBarBronzeRemovalActive()
    local db = BetterBlizzFramesDB
    return db.removeActionBarBronzeTint and not (db.darkModeUi and db.darkModeActionBars)
end

local function SlotArtDesaturationActive()
    local db = BetterBlizzFramesDB
    return ActionBarBronzeRemovalActive() or (db.darkModeUi and db.darkModeActionBars) or false
end

local emptyBagSlotAtlases = {
    ["ui-hud-actionbar-iconframe-slot"] = true,
    ["ui-hud-actionbar-iconframe-slot-small"] = true,
}

local function IsEmptyBagSlotArt(texture)
    local atlas = texture:GetAtlas()
    return atlas and emptyBagSlotAtlases[atlas:lower()] or false
end

local function ReapplyDesaturated(self)
    if self.bbfDesatChanging then return end
    local desaturate = SlotArtDesaturationActive() and (not self.bbfDesatCheck or self.bbfDesatCheck(self)) or false
    if not desaturate and not self.bbfDesatForced then return end
    self.bbfDesatChanging = true
    self.bbfDesatForced = desaturate
    self:SetDesaturated(desaturate)
    self.bbfDesatChanging = false
end

local function ForceDesaturated(texture, check)
    if not texture or texture:IsForbidden() then return end
    texture.bbfDesatCheck = check
    if not texture.bbfDesatHooked then
        texture.bbfDesatHooked = true
        hooksecurefunc(texture, "SetDesaturated", ReapplyDesaturated)
        hooksecurefunc(texture, "SetTexture", ReapplyDesaturated)
        hooksecurefunc(texture, "SetAtlas", ReapplyDesaturated)
    end
    ReapplyDesaturated(texture)
end

local slotArtDesaturated

function BBF.UpdateActionBarBronzeTint()
    local active = SlotArtDesaturationActive()
    if not active and not slotArtDesaturated then return end
    slotArtDesaturated = active
    if ActionBarBronzeRemovalActive() and BBF.ApplyActionBarArt then
        BBF.ApplyActionBarArt(true, 1, 1)
    end
    for _, slotName in ipairs(desaturatedIconNames) do
        local slot = _G[slotName]
        ForceDesaturated(slot and slot.icon, IsEmptyBagSlotArt)
    end
    for _, prefix in ipairs(actionButtonPrefixes) do
        for i = 1, 12 do
            local button = _G[prefix .. i]
            ForceDesaturated(button and button.SlotArt)
        end
    end
end

local BAG_SLOT_BORDER_ATLAS = "UI-HUD-ActionBar-IconFrame"

local function ReapplyDarkModeColor(texture)
    if texture and texture.bbfHooked and not texture:IsForbidden() then
        texture:SetVertexColor(texture:GetVertexColor())
    end
end

function BBF.UpdateBagSlotTextures()
    for _, slotName in ipairs(bagSlotIconNames) do
        local slot = _G[slotName]
        if slot then
            if not slot.bbfBagSlotHooked and slot.UpdateTextures then
                slot.bbfBagSlotHooked = true
                hooksecurefunc(slot, "UpdateTextures", BBF.UpdateBagSlotTextures)
            end
            if slot.icon and slot ~= MainMenuBarBackpackButton and not GetInventoryItemTexture("player", slot:GetID()) then
                slot.icon:SetAtlas("UI-HUD-ActionBar-IconFrame-Slot")
            end
        end
    end
    for _, slotName in ipairs(bagSlotNames) do
        local slot = _G[slotName]
        if slot then
            local normalTexture = slot.NormalTexture or (slot.GetNormalTexture and slot:GetNormalTexture())
            local pushedTexture = slot.PushedTexture or (slot.GetPushedTexture and slot:GetPushedTexture())
            if normalTexture then normalTexture:SetAtlas(BAG_SLOT_BORDER_ATLAS) end
            if pushedTexture then pushedTexture:SetAtlas(BAG_SLOT_BORDER_ATLAS) end
        end
    end
    for _, slotName in ipairs(bagSlotIconNames) do
        local slot = _G[slotName]
        if slot then
            ReapplyDarkModeColor(slot.NormalTexture)
            ReapplyDarkModeColor(slot.PushedTexture)
        end
    end
end

function BBF.ForeverTweaks()
    BBF.UpdateBagSlotTextures()
    BBF.UpdateBronzeTint()
    BBF.UpdateActionBarBronzeTint()
    BBF.UpdateMinimapTweaks()
end
