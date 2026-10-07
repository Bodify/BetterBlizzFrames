local boundRings = {}
local ringRefreshers = {}
local ringsForcedHidden = false

local function BindLevelRing(levelText, ring, highLevelTexture)
    if not levelText or not ring then return end
    if boundRings[ring] then return end
    boundRings[ring] = true

    local originalParent = levelText:GetParent()
    local anchoredToRing = true

    local function Refresh()
        if ring.bbfRefreshing then return end
        ring.bbfRefreshing = true
        local ownedByBlizzard = anchoredToRing and levelText:GetParent() == originalParent
        local hasLevelDisplay = levelText:IsShown() or (highLevelTexture and highLevelTexture:IsShown())
        if ringsForcedHidden or not ownedByBlizzard or not hasLevelDisplay then
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
    hooksecurefunc(levelText, "Show", Refresh)
    hooksecurefunc(levelText, "Hide", Refresh)
    hooksecurefunc(levelText, "SetShown", Refresh)
    if highLevelTexture then
        hooksecurefunc(highLevelTexture, "Show", Refresh)
        hooksecurefunc(highLevelTexture, "Hide", Refresh)
        hooksecurefunc(highLevelTexture, "SetShown", Refresh)
    end
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
        local contextual = frame.TargetFrameContent.TargetFrameContentContextual
        BindLevelRing(main.LevelText, main.LevelBackgroundCircle, contextual and contextual.HighLevelTexture)
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
local BRONZE_DRAGON_R, BRONZE_DRAGON_G, BRONZE_DRAGON_B = 0.776, 0.467, 0.278
local MINIMAP_BRONZE_R, MINIMAP_BRONZE_G, MINIMAP_BRONZE_B = 1, 0.71, 0.34
local NO_PORTRAIT_BRONZE_R, NO_PORTRAIT_BRONZE_G, NO_PORTRAIT_BRONZE_B = 1, 0.773, 0.361
local bronzedTextures = {}
local bronzedNoPortraitTextures = {}
local bronzedCastbarTextures = {}
local bronzedMinimapTextures = {}

local function BronzeTintActive()
    local db = BetterBlizzFramesDB
    return db.classicFrames and db.classicFramesBronzeTint and db.classicFramesBronzeTintUnitFrames and not db.classColorFrameTexture
end

BBF.ClassicBronzeTintActive = BronzeTintActive

local function NoPortraitBronzeTintActive()
    local db = BetterBlizzFramesDB
    return not db.classicFrames and (db.noPortraitModes or db.noPortraitPartyOnly) and db.classicFramesBronzeTint and db.classicFramesBronzeTintUnitFrames and not db.classColorFrameTexture
end

BBF.NoPortraitBronzeTintActive = NoPortraitBronzeTintActive

local function DarkModeEliteActive()
    local db = BetterBlizzFramesDB
    return db.darkModeUi and db.darkModeEliteTexture
end

local function BronzeDragonsActive()
    return BetterBlizzFramesDB.bronzeEliteDragons and not DarkModeEliteActive()
end

BBF.BronzeEliteDragonsActive = BronzeDragonsActive

local function BronzeDragonColor()
    if BBF.ClassicHDTexturesActive and BBF.ClassicHDTexturesActive() then
        return 0.788, 0.494, 0.318
    end
    return BRONZE_DRAGON_R, BRONZE_DRAGON_G, BRONZE_DRAGON_B
end

BBF.BronzeEliteDragonColor = BronzeDragonColor

local function CastbarBronzeTintActive()
    local db = BetterBlizzFramesDB
    return db.classicFramesBronzeTint and db.classicFramesBronzeTintCastbars and not db.classColorFrameTexture
end

BBF.CastbarBronzeTintActive = CastbarBronzeTintActive

local function MinimapBronzeTintActive()
    local db = BetterBlizzFramesDB
    return db.classicMinimap and db.classicFramesBronzeTint and db.classicFramesBronzeTintMinimap
end

BBF.MinimapBronzeTintActive = MinimapBronzeTintActive

local function SetBronze(texture)
    if texture.bbfClassicHD then
        BBF.ApplyClassicHDColor(texture, texture.bbfClassicHD == "castbar")
        return
    end
    texture.bbfBronzeChanging = true
    if texture.bbfBronzeNoPortrait then
        texture:SetVertexColor(NO_PORTRAIT_BRONZE_R, NO_PORTRAIT_BRONZE_G, NO_PORTRAIT_BRONZE_B, texture:GetAlpha())
    elseif texture.bbfBronzeMinimap then
        texture:SetDesaturated(true)
        texture:SetVertexColor(MINIMAP_BRONZE_R, MINIMAP_BRONZE_G, MINIMAP_BRONZE_B, 1)
    else
        texture:SetDesaturated(true)
        texture:SetVertexColor(BRONZE_R, BRONZE_G, BRONZE_B, 1)
    end
    texture.bbfBronzeChanging = false
end

local function BronzeTexture(texture, isMinimap, isCastbar, restoreSaturation, isNoPortrait)
    if not texture or texture:IsForbidden() then return end
    if not texture.bbfBronzeHooked then
        texture.bbfBronzeHooked = true
        texture.bbfBronzeMinimap = isMinimap
        texture.bbfBronzeCastbar = isCastbar
        texture.bbfBronzeRestoreSat = restoreSaturation
        texture.bbfBronzeNoPortrait = isNoPortrait
        tinsert(isNoPortrait and bronzedNoPortraitTextures or isMinimap and bronzedMinimapTextures or isCastbar and bronzedCastbarTextures or bronzedTextures, texture)
        hooksecurefunc(texture, "SetVertexColor", function(self)
            if self.bbfBronzeChanging then return end
            if self.bbfBronzeNoPortrait then
                if not NoPortraitBronzeTintActive() then return end
            elseif self.bbfBronzeMinimap then
                if not MinimapBronzeTintActive() then return end
            elseif self.bbfBronzeCastbar then
                if not CastbarBronzeTintActive() then return end
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

local function GetNoPortraitBorderTextures()
    local db = BetterBlizzFramesDB
    local textures = {}
    for unit, frame in pairs({ player = PlayerFrame, target = TargetFrame, focus = FocusFrame }) do
        if frame and frame.noPortraitMode and BBF.HasNoPortrait(unit) then
            local container = frame.PlayerFrameContainer or frame.TargetFrameContainer
            local texture = frame.noPortraitMode.Texture
            texture.bbfBronzeSource = container and container.FrameTexture
            tinsert(textures, texture)
            if frame.totFrame and frame.totFrame.FrameTexture then
                tinsert(textures, frame.totFrame.FrameTexture)
            end
        end
    end
    if PetFrameTexture and BBF.HasNoPortrait("pet") then
        tinsert(textures, PetFrameTexture)
    end
    if PartyFrame and (db.noPortraitModes or db.noPortraitPartyOnly) then
        for i = 1, 4 do
            local member = PartyFrame["MemberFrame" .. i]
            if member and member.Texture then
                tinsert(textures, member.Texture)
            end
        end
    end
    return textures
end

local function GetThreatBorder(frame)
    local threat = frame and frame.TargetFrameContent and frame.TargetFrameContent.TargetFrameContentContextual.NumericalThreat
    if not threat or threat:IsForbidden() then return end
    if threat.bbfBorder == nil then
        threat.bbfBorder = false
        for i = 1, threat:GetNumRegions() do
            local region = select(i, threat:GetRegions())
            if region and region:IsObjectType("Texture") and region ~= threat.bg and region:GetDrawLayer() == "ARTWORK" then
                threat.bbfBorder = region
                break
            end
        end
    end
    return threat.bbfBorder or nil
end

local function GetSaturatedBorderTextures()
    local textures = {}
    for _, bar in pairs({ AlternatePowerBar, EvokerEbonMightBar, MonkStaggerBar, PlayerFrame.AltManaBarBBF }) do
        if bar then
            tinsert(textures, bar.Border)
            tinsert(textures, bar.LeftBorder)
            tinsert(textures, bar.RightBorder)
        end
    end
    tinsert(textures, GetThreatBorder(TargetFrame))
    tinsert(textures, GetThreatBorder(FocusFrame))
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
        if MirrorTimerContainer and MirrorTimerContainer.bbfClassic then
            for _, timerFrame in ipairs(MirrorTimerContainer.mirrorTimers) do
                tinsert(textures, timerFrame.Border)
            end
        end
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

local minimapButtonSweepQueued

local function BronzeMinimapButtonRegions(frame)
    for i = 1, frame:GetNumRegions() do
        local region = select(i, frame:GetRegions())
        if region and region:IsObjectType("Texture") and not region:IsForbidden() then
            local texture = region:GetTexture()
            if texture and string.find(tostring(texture), "136430", 1, true) then
                BronzeTexture(region, true)
            end
        end
    end
end

local function BronzeMinimapButtons()
    if not Minimap then return end
    for i = 1, Minimap:GetNumChildren() do
        local child = select(i, Minimap:GetChildren())
        if child and not child:IsForbidden() then
            BronzeMinimapButtonRegions(child)
            for j = 1, child:GetNumChildren() do
                local nested = select(j, child:GetChildren())
                if nested and not nested:IsForbidden() then
                    BronzeMinimapButtonRegions(nested)
                end
            end
        end
    end
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
    if BBF.DarkModeUnitFramesOn() then
        local v = BetterBlizzFramesDB.darkModeColor
        r, g, b = v, v, v
    elseif BronzeTintActive() then
        r, g, b = BRONZE_R, BRONZE_G, BRONZE_B
    end
    local hd = BBF.ClassicHDTexturesActive()
    local hdBronze = hd and BronzeTintActive() and not BBF.DarkModeUnitFramesOn()
    for _, circle in pairs(GetPvpCircles()) do
        if not circle:IsForbidden() then
            if hd and not circle.bbfHDRing then
                circle.bbfHDRing = true
                circle:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\MoTextures\\lvlring.png")
                circle:SetTexCoord(0, 1, 0, 1)
                circle:SetSize(40, 40)
            end
            if hdBronze then
                circle:SetDesaturated(false)
                circle:SetVertexColor(1, 1, 1, 1)
            else
                circle:SetDesaturated(true)
                circle:SetVertexColor(r, g, b, 1)
            end
        end
    end
end

local eliteOverlayClassifications = { elite = true, worldboss = true, rareelite = true }

local hdEliteOverlays = {
    rare = { atlas = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare-Silver", width = 97.5, height = 102, x = 22, y = 20 },
    rareelite = { atlas = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged", width = 107, height = 92, x = 32, y = 15, desaturated = true },
    elite = { atlas = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold", width = 97.5, height = 102, x = 22, y = 20, gold = true },
    worldboss = { atlas = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged", width = 107, height = 92, x = 32, y = 15, gold = true },
}

local function HDEliteActive()
    local db = BetterBlizzFramesDB
    return db.classicFrames and (db.classicFramesHDElite or db.classicFramesHDTextures) and not db.hideRareDragonTexture
end
BBF.ClassicHDEliteActive = HDEliteActive

function BBF.UpdateClassicEliteOverlay(frame)
    local classicFrame = frame and frame.ClassicFrame
    if not classicFrame or not classicFrame.Texture then return end
    local classification = frame.unit and UnitExists(frame.unit) and BBF.GetUnitClassification(frame.unit)
    local db = BetterBlizzFramesDB
    local darkModeKeepsDragon = db.classicFrames and BBF.DarkModeUnitFramesOn() and not db.darkModeEliteTexture
    local overlay = classicFrame.EliteOverlay
    if not ((BronzeTintActive() or darkModeKeepsDragon or BronzeDragonsActive()) and not db.hideRareDragonTexture and not HDEliteActive() and eliteOverlayClassifications[classification] and not BBF.GetSelfEliteClassification(frame.unit)) then
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
    elseif BronzeDragonsActive() then
        overlay:SetDesaturated(true)
        local r, g, b = BronzeDragonColor()
        overlay:SetVertexColor(r, g, b, 1)
    else
        overlay:SetDesaturated(false)
        overlay:SetVertexColor(1, 0.816, 0.251, 1)
    end
    overlay:Show()
end

function BBF.UpdateClassicHDElite(frame)
    local classicFrame = frame and frame.ClassicFrame
    if not classicFrame then return end
    local portrait = frame.TargetFrameContainer and frame.TargetFrameContainer.Portrait
    if not portrait then return end
    local overlay = classicFrame.HDElite
    local classification = frame.unit and UnitExists(frame.unit) and BBF.GetUnitClassification(frame.unit)
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
        BBF.SetClassicHDLevelRing(frame, BBF.ClassicHDTexturesActive())
        return
    end
    if not overlay then
        overlay = classicFrame:CreateTexture(nil, "OVERLAY", nil, 4)
        classicFrame.HDElite = overlay
    end
    local db = BetterBlizzFramesDB
    overlay:SetAtlas(data.atlas)
    overlay:SetSize(data.width, data.height)
    overlay:ClearAllPoints()
    overlay:SetPoint("TOPRIGHT", portrait, "TOPRIGHT", data.x, data.y)
    if db.darkModeUi and db.darkModeEliteTexture then
        local v = BBF.DarkModeEliteValue()
        overlay:SetDesaturated(db.darkModeEliteTextureDesaturated or data.desaturated or false)
        overlay:SetVertexColor(v, v, v, 1)
    elseif data.gold and BronzeDragonsActive() then
        overlay:SetDesaturated(true)
        local r, g, b = BronzeDragonColor()
        overlay:SetVertexColor(r, g, b, 1)
    else
        overlay:SetDesaturated(data.desaturated or false)
        overlay:SetVertexColor(1, 1, 1, 1)
    end
    local playerElite = PlayerFrame.PlayerFrameContainer.PlayerElite
    if playerElite and BBF.GetSelfEliteClassification(frame.unit) then
        local r, g, b = playerElite:GetVertexColor()
        overlay:SetDesaturated(playerElite:IsDesaturated())
        overlay:SetVertexColor(r, g, b, 1)
    end
    overlay:Show()
end

local function BossDragonIsGold(frame, texture)
    local atlas = texture:GetAtlas()
    if not atlas or (issecretvalue and issecretvalue(atlas)) then return false end
    if not atlas:lower():find("gold", 1, true) then return false end
    return BBF.GetSelfEliteClassification(frame.unit) ~= "rareelite"
end

function BBF.UpdateBossDragonBronze(frame)
    local texture = frame and frame.TargetFrameContainer and frame.TargetFrameContainer.BossPortraitFrameTexture
    if not texture or texture:IsForbidden() then return end
    local alpha = texture:GetAlpha()
    if BronzeDragonsActive() and not BetterBlizzFramesDB.classicFrames and BossDragonIsGold(frame, texture) then
        texture.bbfBronzeDragon = true
        texture:SetDesaturated(true)
        local r, g, b = BronzeDragonColor()
        texture:SetVertexColor(r, g, b, alpha)
    elseif texture.bbfBronzeDragon then
        texture.bbfBronzeDragon = nil
        local db = BetterBlizzFramesDB
        if DarkModeEliteActive() then
            local v = BBF.DarkModeEliteValue()
            texture:SetDesaturated(db.darkModeEliteTextureDesaturated or false)
            texture:SetVertexColor(v, v, v, alpha)
        else
            texture:SetDesaturated(BBF.GetSelfEliteClassification(frame.unit) == "rareelite")
            texture:SetVertexColor(1, 1, 1, alpha)
        end
    end
end

function BBF.UpdateEliteDragonBronze()
    if BBF.ColorPlayerElite then
        BBF.ColorPlayerElite()
    end
    for _, frame in ipairs({ TargetFrame, FocusFrame }) do
        if frame then
            if not frame.bbfBronzeDragonHooked then
                frame.bbfBronzeDragonHooked = true
                hooksecurefunc(frame, "CheckClassification", BBF.UpdateBossDragonBronze)
            end
            BBF.UpdateBossDragonBronze(frame)
            BBF.UpdateClassicEliteOverlay(frame)
            BBF.UpdateClassicHDElite(frame)
            if BBF.SyncSelfEliteClassicArt then
                BBF.SyncSelfEliteClassicArt(frame)
            end
        end
    end
end

local function ColorHDLevelRing(circle)
    if not circle then return end
    if BBF.DarkModeUnitFramesOn() then
        local v = BetterBlizzFramesDB.darkModeColor
        circle:SetDesaturated(true)
        circle:SetVertexColor(v, v, v)
    elseif BronzeTintActive() then
        circle:SetDesaturated(true)
        circle:SetVertexColor(BRONZE_R, BRONZE_G, BRONZE_B)
    else
        circle:SetDesaturated(false)
        circle:SetVertexColor(1, 1, 1)
    end
end

function BBF.UpdateClassicHDLevelRingColors()
    for _, frame in ipairs({ PlayerFrame, TargetFrame, FocusFrame }) do
        ColorHDLevelRing(frame and frame.ClassicFrame and frame.ClassicFrame.HDLevelCircle)
        BBF.ColorClassicHDLevelRing(frame)
    end
end

local function PlaceHDLevelRing(circle, levelText)
    local text = levelText:GetText()
    local x = 0
    if text and not (issecretvalue and issecretvalue(text)) then
        text = tostring(text)
        if text:sub(1, 1) == "1" then
            x = 0.5
        end
    end
    circle:ClearAllPoints()
    circle:SetPoint("CENTER", levelText, "CENTER", x, 0)
end

function BBF.SetClassicHDLevelRing(frame, enabled)
    local classicFrame = frame and frame.ClassicFrame
    if not classicFrame then return end
    local levelText, highLevelTexture
    if frame == PlayerFrame then
        levelText = PlayerLevelText
    elseif frame.TargetFrameContent then
        levelText = frame.TargetFrameContent.TargetFrameContentMain.LevelText
        highLevelTexture = frame.TargetFrameContent.TargetFrameContentContextual.HighLevelTexture
    end
    if not levelText then return end
    local circle = classicFrame.HDLevelCircle
    if not circle then
        if not enabled then return end
        circle = classicFrame:CreateTexture(nil, "OVERLAY", nil, 5)
        classicFrame.HDLevelCircle = circle
        ColorHDLevelRing(circle)
        local function Refresh()
            local hasLevelDisplay = levelText:IsShown() or (highLevelTexture and highLevelTexture:IsShown())
            circle:SetShown(circle.bbfEnabled and hasLevelDisplay and levelText:GetParent() ~= BBF.hiddenFrame)
            circle:SetAlpha(levelText:GetAlpha())
        end
        circle.Refresh = Refresh
        for _, method in ipairs({ "SetParent", "SetAlpha", "Show", "Hide", "SetShown" }) do
            hooksecurefunc(levelText, method, Refresh)
        end
        hooksecurefunc(levelText, "SetText", function()
            if circle.bbfHD then
                PlaceHDLevelRing(circle, levelText)
            end
        end)
        if highLevelTexture then
            for _, method in ipairs({ "Show", "Hide", "SetShown" }) do
                hooksecurefunc(highLevelTexture, method, Refresh)
            end
        end
    end
    local hd = BBF.ClassicHDTexturesActive()
    if circle.bbfHD ~= hd then
        circle.bbfHD = hd
        circle:ClearAllPoints()
        if hd then
            circle:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\MoTextures\\lvlring.png")
            circle:SetTexCoord(0, 1, 0, 1)
            circle:SetSize(frame == PlayerFrame and 33.5 or 33, 31)
            PlaceHDLevelRing(circle, levelText)
        else
            circle:SetAtlas("hud-PlayerFrame-levelring")
            circle:SetSize(36, 32)
            circle:SetPoint("CENTER", levelText, "CENTER", -1, -1.5)
        end
    end
    circle.bbfEnabled = enabled and true or false
    circle:SetScale(BetterBlizzFramesDB.smallerLevelCircle and 0.8 or 1)
    circle.Refresh()
    BBF.ColorClassicHDLevelRing(frame)
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
    BBF.UpdateEliteDragonBronze()
    BBF.UpdateClassicHDLevelRingColors()
    if BBF.UpdateClassicMinimapDifficulty then
        BBF.UpdateClassicMinimapDifficulty()
    end
    if BBF.UpdateComboPointTint then
        BBF.UpdateComboPointTint()
    end
    if BronzeTintActive() then
        for _, texture in pairs(GetUnitFrameBorderTextures()) do
            BronzeTexture(texture)
        end
        for _, texture in pairs(GetSaturatedBorderTextures()) do
            BronzeTexture(texture, nil, nil, true)
        end
    elseif not BBF.DarkModeUnitFramesOn() then
        for _, texture in ipairs(bronzedTextures) do
            if not texture:IsForbidden() then
                if texture.bbfBronzeRestoreSat then
                    texture:SetDesaturated(false)
                end
                texture:SetVertexColor(1, 1, 1, 1)
            end
        end
    end

    if NoPortraitBronzeTintActive() then
        for _, texture in pairs(GetNoPortraitBorderTextures()) do
            BronzeTexture(texture, nil, nil, nil, true)
        end
    else
        for _, texture in ipairs(bronzedNoPortraitTextures) do
            if not texture:IsForbidden() then
                local source = texture.bbfBronzeSource
                if source then
                    local r, g, b = source:GetVertexColor()
                    texture:SetVertexColor(r, g, b, texture:GetAlpha())
                elseif not BBF.DarkModeUnitFramesOn() then
                    texture:SetVertexColor(1, 1, 1, texture:GetAlpha())
                end
            end
        end
    end

    if CastbarBronzeTintActive() then
        for _, texture in pairs(GetClassicCastbarBorderTextures()) do
            BronzeTexture(texture, nil, true)
        end
    elseif not (BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeCastbars) then
        for _, texture in ipairs(bronzedCastbarTextures) do
            if not texture:IsForbidden() then
                texture:SetDesaturated(false)
                texture:SetVertexColor(1, 1, 1, 1)
            end
        end
    end

    if MinimapBronzeTintActive() then
        for _, texture in pairs(GetClassicMinimapTextures()) do
            BronzeTexture(texture, true)
        end
        BronzeMinimapButtons()
        if not minimapButtonSweepQueued then
            minimapButtonSweepQueued = true
            C_Timer.After(2, function()
                if MinimapBronzeTintActive() then
                    BronzeMinimapButtons()
                end
            end)
        end
    elseif not (BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeMinimap) then
        for _, texture in ipairs(bronzedMinimapTextures) do
            if not texture:IsForbidden() then
                texture:SetDesaturated(false)
                texture:SetVertexColor(1, 1, 1, 1)
            end
        end
        if BBF.TintForeverMinimap then
            BBF.TintForeverMinimap()
        end
    end
    BBF.UpdateClassicHDTextureColors()
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

local function ApplySmallerLevelCircle(ring, levelText, point, x, y, enabled)
    if not ring or not levelText then return end
    if not ring.bbfOrigPoint then
        if not enabled then return end
        ring.bbfOrigPoint = { ring:GetPoint(1) }
        ring.bbfOrigScale = ring:GetScale()
    end
    ring:SetScale(enabled and 0.8 or ring.bbfOrigScale)
    ring:ClearAllPoints()
    if enabled then
        ring:SetPoint(point, x, y)
    else
        ring:SetPoint(unpack(ring.bbfOrigPoint))
    end
    if levelText:GetParent() ~= ring:GetParent() then return end
    if not levelText.bbfOrigFontHeight then
        levelText.bbfOrigFontHeight = select(2, levelText:GetFont())
    end
    levelText:SetFontHeight(enabled and 12 or levelText.bbfOrigFontHeight)
end

function BBF.UpdateSmallerLevelCircle()
    local enabled = BetterBlizzFramesDB.smallerLevelCircle and true or false
    local playerMain = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain
    if BBF.symmetricPlayerFrameActive then
        ApplySmallerLevelCircle(playerMain.LevelBackgroundCircle, PlayerLevelText, "BOTTOMLEFT", 22, 17, enabled)
    else
        ApplySmallerLevelCircle(playerMain.LevelBackgroundCircle, PlayerLevelText, "BOTTOMLEFT", 20, 16, enabled)
    end
    for _, frame in ipairs({ TargetFrame, FocusFrame }) do
        local main = frame.TargetFrameContent.TargetFrameContentMain
        ApplySmallerLevelCircle(main.LevelBackgroundCircle, main.LevelText, "BOTTOMRIGHT", -22, 17, enabled)
    end
    for _, frame in ipairs({ PlayerFrame, TargetFrame, FocusFrame }) do
        local circle = frame.ClassicFrame and frame.ClassicFrame.HDLevelCircle
        if circle then
            circle:SetScale(enabled and 0.8 or 1)
        end
    end
end

function BBF.RefreshBronzeTint()
    if BetterBlizzFramesDB.darkModeUi then
        BBF.DarkmodeFrames(true)
    end
    BBF.UpdateBronzeTint()
end

function BBF.ForeverTweaks()
    BBF.UpdateSmallerLevelCircle()
    BBF.UpdateBagSlotTextures()
    BBF.UpdateBronzeTint()
    BBF.UpdateActionBarBronzeTint()
    BBF.UpdateMinimapTweaks()
end
