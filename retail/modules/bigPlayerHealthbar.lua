local HEALTHBAR_HEIGHT = 19
local MANABAR_HEIGHT = 10
local BAR_GAP = 1
local HEALTHBAR_HEIGHT_GROWN = HEALTHBAR_HEIGHT + BAR_GAP + MANABAR_HEIGHT
local MANA_SPAN = MANABAR_HEIGHT + BAR_GAP
local BIG_RAISE = { reduced = 8, big = 12 }
local BIG_EXTRA = { reduced = 1, big = 0 }
local MEDIA = "Interface\\AddOns\\BetterBlizzFrames\\media\\"
local RETAIL_TEX = MEDIA .. "retailTextures\\"
local BLIZZ_TEX = MEDIA .. "blizzTex\\"

local function SetContainerPoint(hpContainer, xOffset, yOffset)
    local point, relativeTo, relativePoint, x, y = hpContainer:GetPoint()
    hpContainer:SetPoint(point, relativeTo, relativePoint, xOffset or x, yOffset or y)
end

local function GetHealthBits()
    local hpContainer = PlayerFrame_GetHealthBarContainer()
    return hpContainer, hpContainer.HealthBar, hpContainer.HealthBarMask
end

local function IsEnabled()
    return BBF.BigPlayerHealthbar()
end

local function DefaultArtFrame()
    local db = BetterBlizzFramesDB
    return not db.classicFrames and not BBF.HasNoPortrait("player")
end

function BBF.PlayerManaHiddenArt()
    return BetterBlizzFramesDB.hideUnitFramePlayerMana and DefaultArtFrame() and true or false
end

function BBF.PlayerBigRaise()
    if not IsEnabled() or not DefaultArtFrame() then return 0 end
    return BBF.BigHealthbarReduced(PlayerFrame) and BIG_RAISE.reduced or BIG_RAISE.big
end

local function CustomPlayerArt()
    return DefaultArtFrame() and (IsEnabled() or BBF.PlayerManaHiddenArt())
end

local function ArtSuffix()
    local suffix = ""
    if IsEnabled() and DefaultArtFrame() then
        suffix = "-BigHealthbar" .. (BBF.BigHealthbarReduced(PlayerFrame) and "-Reduced" or "")
    end
    if BBF.PlayerManaHiddenArt() then
        suffix = suffix .. "-NoMana"
    end
    return suffix
end

local function ShadowSuffix()
    return BetterBlizzFramesDB.hideUnitFrameShadow and "-NoShadow" or ""
end

local function SetHealthTextOffset(hpContainer, y)
    hpContainer.HealthBarText:SetPoint("CENTER", hpContainer, "CENTER", 0, y)
    hpContainer.LeftText:SetPoint("LEFT", hpContainer, "LEFT", 2, y)
    hpContainer.RightText:SetPoint("RIGHT", hpContainer, "RIGHT", -2, y)
end

local function SetDefaultManaShown(shown)
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea:SetAlpha(shown and 1 or 0)
end

function BBF.GetPlayerFrameArtTexture()
    return RETAIL_TEX .. "Player" .. ShadowSuffix() .. ArtSuffix() .. ".png"
end

function BBF.GetNoShadowPlayerFrameTexture()
    if CustomPlayerArt() then
        return BBF.GetPlayerFrameArtTexture()
    end
    return BLIZZ_TEX .. "UI-HUD-UnitFrame-Player-PortraitOn-NoShadow.png"
end

local function SetDefaultFrameTexture(atlas)
    if BetterBlizzFramesDB.symmetricPlayerFrame then return end
    local tex = PlayerFrame.PlayerFrameContainer.FrameTexture
    if CustomPlayerArt() then
        tex.bbfBigArt = true
        tex:SetTexture(BBF.GetPlayerFrameArtTexture())
        return
    end
    tex.bbfBigArt = nil
    if BetterBlizzFramesDB.hideUnitFrameShadow then
        tex:SetTexture(BBF.GetNoShadowPlayerFrameTexture())
        return
    end
    tex:SetAtlas(atlas)
end

local MIRROR_RAISE = { reduced = 7.5, big = 12 }

function BBF.GetMirrorPlayerHealthbarRaise()
    if not IsEnabled() or not DefaultArtFrame() then return 0 end
    return BBF.BigHealthbarReduced(PlayerFrame) and MIRROR_RAISE.reduced or MIRROR_RAISE.big
end

local function SetMirrorHealthTextY(hpContainer, y)
    hpContainer.RightText:SetPoint("RIGHT", hpContainer, "RIGHT", -4, y)
    hpContainer.LeftText:SetPoint("LEFT", hpContainer, "LEFT", 2, y)
    hpContainer.HealthBarText:SetPoint("CENTER", hpContainer, "CENTER", 0, y)
end

function BBF.GetMirrorPlayerHealthbarSize()
    local raise = BBF.GetMirrorPlayerHealthbarRaise()
    local noMana = BBF.PlayerManaHiddenArt() and MANA_SPAN or 0
    return 126, 20.5, 20 + raise + noMana
end


local function MirrorArtName()
    local suffix = ArtSuffix()
    if suffix == "" then return end
    return "Target" .. ShadowSuffix() .. suffix
end

function BBF.GetMirrorPlayerHealthbarGrow()
    local name = MirrorArtName()
    return name and BBF.FrameMaskGrow(name, "health") or 0
end

function BBF.SetMirrorPlayerHealthbarMask()
    local _, healthBar, mask = GetHealthBits()
    local name = MirrorArtName()
    if name and BBF.ApplyFrameMask(mask, name, "health", PlayerFrame.PlayerFrameContainer.FrameTexture, true) then return end
    local _, _, barHeight = BBF.GetMirrorPlayerHealthbarSize()
    mask:SetTexture(BLIZZ_TEX .. "UIUnitFrameTargetHealthMask2x-Flipped.png")
    mask:ClearAllPoints()
    mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -2, barHeight * 0.3)
    mask:SetSize(129, barHeight * 1.6)
end

local function MirrorTargetArt(flash)
    if flash then
        return RETAIL_TEX .. "Target-InCombat" .. ArtSuffix() .. ".png"
    end
    local name = MirrorArtName()
    return name and RETAIL_TEX .. name .. ".png"
end
BBF.MirrorPlayerTargetArt = MirrorTargetArt

function BBF.SetMirrorPlayerFrameTexture()
    if not BetterBlizzFramesDB.symmetricPlayerFrame then return end
    if BetterBlizzFramesDB.classicFrames then return end
    if BBF.HasNoPortrait("player") then return end
    local frameTexture = PlayerFrame.PlayerFrameContainer.FrameTexture
    if frameTexture.changing then return end
    frameTexture.changing = true
    local art = MirrorTargetArt()
    if art then
        frameTexture:SetTexture(art)
    elseif BetterBlizzFramesDB.hideUnitFrameShadow then
        frameTexture:SetTexture(BLIZZ_TEX .. "UI-HUD-UnitFrame-Target-PortraitOn-NoShadow.png")
    else
        frameTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn")
    end
    frameTexture:SetSize(192, 67)
    frameTexture:SetTexCoord(1, 0, 0, 1)
    frameTexture.changing = false
end

function BBF.SetMirrorPlayerAltFrameTexture()
    local db = BetterBlizzFramesDB
    if not db.symmetricPlayerFrame then return end
    if db.classicFrames then return end
    if BBF.HasNoPortrait("player") then return end
    local altTex = PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture
    local art = MirrorTargetArt()
    local path = BLIZZ_TEX .. "UI-HUD-UnitFrame-Target-PortraitOn" .. (db.hideUnitFrameShadow and "-NoShadow" or "")
    altTex:ClearAllPoints()
    if art and not db.hideUnitFramePlayerSecondResource and ArtSuffix():find("BigHealthbar", 1, true) then
        altTex:SetTexture(RETAIL_TEX .. MirrorArtName() .. "-Alt.png")
        altTex:SetTexCoord(0, 1, 0, 1)
        altTex:SetAllPoints(PlayerFrame.PlayerFrameContainer.FrameTexture)
        return
    end
    if art and not db.hideUnitFramePlayerSecondResource then
        path = path .. "-Alt-NoMana.png"
        art = nil
    else
        path = path .. "-Alt.png"
    end
    if db.hideUnitFramePlayerSecondResource or art then
        if art then
            altTex:SetTexture(art)
        elseif db.hideUnitFrameShadow then
            altTex:SetTexture(BLIZZ_TEX .. "UI-HUD-UnitFrame-Target-PortraitOn-NoShadow.png")
        else
            altTex:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn")
        end
        altTex:SetTexCoord(1, 0, 0, 1)
        altTex:SetAllPoints(PlayerFrame.PlayerFrameContainer.FrameTexture)
        return
    end
    altTex:SetTexture(path)
    altTex:SetTexCoord(0, 1, 0, 1)
    altTex:SetSize(192, 67)
    altTex:SetPoint("CENTER", 0, -0.5)
end

function BBF.UpdatePlayerAltFrameArt()
    local db = BetterBlizzFramesDB
    if db.classicFrames or db.symmetricPlayerFrame or BBF.HasNoPortrait("player") then return end
    local altTex = PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture
    if not CustomPlayerArt() then
        if altTex.bbfBigArt then
            altTex.bbfBigArt = nil
            altTex:SetAtlas(db.hideUnitFramePlayerSecondResource and "UI-HUD-UnitFrame-Player-PortraitOn" or "UI-HUD-UnitFrame-Player-PortraitOn-ClassResource")
        end
        if db.hideUnitFrameShadow then
            BBF.UpdateNoShadowPlayerAltFrameTexture()
        end
        return
    end
    altTex.bbfBigArt = true
    if db.hideUnitFramePlayerSecondResource then
        altTex:SetTexture(BBF.GetPlayerFrameArtTexture())
    else
        altTex:SetTexture(RETAIL_TEX .. "Player-ClassResource" .. ShadowSuffix() .. ArtSuffix() .. ".png")
    end
end

function BBF.UpdateNoShadowPlayerAltFrameTexture()
    local db = BetterBlizzFramesDB
    if not db.hideUnitFrameShadow or db.symmetricPlayerFrame or db.classicFrames then return end
    if CustomPlayerArt() then
        BBF.UpdatePlayerAltFrameArt()
        return
    end
    local altTex = PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture
    if db.hideUnitFramePlayerSecondResource then
        altTex:SetTexture(BBF.GetNoShadowPlayerFrameTexture())
    else
        altTex:SetTexture(BLIZZ_TEX .. "UI-HUD-UnitFrame-Player-PortraitOn-ClassResource-NoShadow.png")
    end
end

function BBF.SetMirrorPlayerStatusTexture(status)
    if IsEnabled() and DefaultArtFrame() then
        status:SetTexture(RETAIL_TEX .. "Target-Status-BigHealthbar" .. (BBF.BigHealthbarReduced(PlayerFrame) and "-Reduced" or "") .. ".png")
    else
        status:SetAtlas("UI-HUD-UnitFrame-Target-MinusMob-PortraitOn-Status")
    end
    status:SetTexCoord(1, 0, 0, 1)
    status:SetSize(194, 70)
end

local function UpdatePlayerStatusTexture()
    local db = BetterBlizzFramesDB
    local status = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture
    if db.classicFrames then return end
    if BBF.HasNoPortrait("player") or UNIT_FRAME_SHOW_HEALTH_ONLY then return end
    if PlayerFrame.state ~= "player" then return end
    if db.symmetricPlayerFrame then
        status.changing = true
        BBF.SetMirrorPlayerStatusTexture(status)
        status.changing = false
        return
    end
    if IsEnabled() then
        status.bbfBigStatus = true
        status:SetTexture(RETAIL_TEX .. "Player-Status-BigHealthbar" .. (BBF.BigHealthbarReduced(PlayerFrame) and "-Reduced" or "") .. ".png")
        status:SetTexCoord(0, 1, 0, 1)
    elseif status.bbfBigStatus then
        status.bbfBigStatus = nil
        status:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Status", TextureKitConstants.UseAtlasSize)
    end
end

function BBF.UpdatePlayerFrameFlash()
    if not BBF.hookedPlayerFrameFlash then
        BBF.hookedPlayerFrameFlash = true
        hooksecurefunc("PlayerFrame_ToPlayerArt", BBF.UpdatePlayerFrameFlash)
        if PlayerFrame_UpdateStatusTextureVisuals then
            hooksecurefunc("PlayerFrame_UpdateStatusTextureVisuals", UpdatePlayerStatusTexture)
        end
    end
    UpdatePlayerStatusTexture()
    local db = BetterBlizzFramesDB
    local container = PlayerFrame.PlayerFrameContainer
    local flash = container.FrameFlash
    if db.symmetricPlayerFrame or db.classicFrames then return end
    if BBF.HasNoPortrait("player") or UNIT_FRAME_SHOW_HEALTH_ONLY then return end
    if PlayerFrame.state ~= "player" then return end
    local showAltBar = PlayerFrame_GetAlternatePowerBar() and not db.hideUnitFramePlayerSecondResource
    if showAltBar then
        flash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-ClassResource-InCombat", TextureKitConstants.UseAtlasSize)
        flash:SetPoint("CENTER", container, "CENTER", -2, 0.5)
    else
        flash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize)
        flash:SetPoint("CENTER", container, "CENTER", -1.5, 1)
    end
    if not CustomPlayerArt() then return end
    flash:SetTexture(RETAIL_TEX .. "Player-" .. (showAltBar and "ClassResource-InCombat" or "InCombat") .. ArtSuffix() .. ".png")
    flash:SetTexCoord(0, 1, 0, 1)
end

local function PlayerMaskArt()
    local container = PlayerFrame.PlayerFrameContainer
    local db = BetterBlizzFramesDB
    if PlayerFrame_GetAlternatePowerBar() and not db.hideUnitFramePlayerSecondResource then
        return "Player-ClassResource" .. ShadowSuffix() .. ArtSuffix(), container.AlternatePowerFrameTexture
    end
    return "Player" .. ShadowSuffix() .. ArtSuffix(), container.FrameTexture
end

local function DefaultBarLayout(hpContainer, healthBar, mask)
    local raise = BBF.PlayerBigRaise()
    if not BBF.LevelOnTextArea(PlayerFrame) then
        BBF.ShiftRegionY(PlayerLevelText, raise)
    end
    BBF.ShiftRegionY(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ReputationColor, raise)
    local contextual = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual
    BBF.ShiftRegionY(contextual and contextual.LeaderIcon, raise)
    BBF.ShiftRegionY(contextual and contextual.GuideIcon, raise)
    BBF.ShiftRegionY(contextual and contextual.RoleIcon, raise)
    local noMana = BBF.PlayerManaHiddenArt() and MANA_SPAN or 0
    local extra = raise > 0 and (BBF.BigHealthbarReduced(PlayerFrame) and BIG_EXTRA.reduced or BIG_EXTRA.big) or 0
    local tall = (noMana > 0 and (raise == 0 or not BBF.BigHealthbarReduced(PlayerFrame))) and 0.5 or 0
    local height = HEALTHBAR_HEIGHT + raise + extra + noMana + tall * 2
    hpContainer:SetHeight(HEALTHBAR_HEIGHT)
    local art, artTexture = PlayerMaskArt()
    local grow = BBF.FrameMaskGrow(art, "health")
    healthBar:ClearAllPoints()
    healthBar:SetPoint("TOPLEFT", hpContainer, "TOPLEFT", -grow, raise + tall)
    healthBar:SetSize(124 + grow, height)
    if not BBF.ApplyFrameMask(mask, art, "health", artTexture) then
        mask:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Mask", true)
        mask:ClearAllPoints()
        mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -2, height * 6 / 19)
        mask:SetHeight(height * 31 / 19)
    end
    local textY = (raise - extra - noMana) / 2
    if raise > 0 and BetterBlizzFramesDB.biggerHealthbarsNameInside then
        textY = textY - 6
    end
    SetHealthTextOffset(hpContainer, textY)
end

local function GrowBar()
    local hpContainer, healthBar, mask = GetHealthBits()
    if BetterBlizzFramesDB.classicFrames then
        local hideMana = BetterBlizzFramesDB.hideUnitFramePlayerMana
        local height = hideMana and 39 or 29
        SetContainerPoint(hpContainer, 87, -34)
        hpContainer:SetSize(120, height)
        healthBar:SetSize(120, height)
        healthBar:ClearAllPoints()
        healthBar:SetPoint("TOPLEFT", hpContainer, "TOPLEFT", 0, 3)
        BBF.MaskClassicPlayerHealth()
        BBF.UpdatePlayerOvershieldAnchor()
        BBF.SizeClassicPlayerMana()
        return
    end
    if BBF.HasNoPortrait("player") then
        hpContainer:SetHeight(HEALTHBAR_HEIGHT_GROWN)
        healthBar:SetHeight(HEALTHBAR_HEIGHT_GROWN)
        if BetterBlizzFramesDB.noPortraitPixelBorder then
            BBF.UpdatePlayerPixelBorderSize()
            return
        end
        if PlayerFrame.state == "vehicle" then
            mask:SetSize(184, 46)
        else
            BBF.ApplyNoPortraitBigPlayerMask()
        end
        return
    end
    if PlayerFrame.state == "vehicle" then return end
    SetDefaultManaShown(not BBF.PlayerManaHiddenArt())
    SetDefaultFrameTexture("UI-HUD-UnitFrame-Player-PortraitOn")
    BBF.UpdatePlayerAltFrameArt()
    BBF.UpdatePlayerFrameFlash()
    if BetterBlizzFramesDB.symmetricPlayerFrame then
        local width, containerHeight, barHeight = BBF.GetMirrorPlayerHealthbarSize()
        local grow = BBF.GetMirrorPlayerHealthbarGrow()
        SetContainerPoint(hpContainer, 85)
        hpContainer:SetSize(width, containerHeight)
        healthBar:SetSize(width + grow, barHeight)
        local raise = BBF.GetMirrorPlayerHealthbarRaise()
        healthBar:SetPoint("TOPLEFT", hpContainer, "TOPLEFT", -1.5 - grow, 1 + raise)
        local noMana = BBF.PlayerManaHiddenArt() and MANA_SPAN or 0
        SetMirrorHealthTextY(hpContainer, 1 + (raise - noMana) / 2)
        local contextual = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual
        BBF.ShiftRegionY(contextual and contextual.LeaderIcon, raise)
        BBF.ShiftRegionY(contextual and contextual.GuideIcon, raise)
        BBF.ShiftRegionY(contextual and contextual.RoleIcon, raise)
        BBF.SetMirrorPlayerHealthbarMask()
        BBF.SetMirrorPlayerFrameTexture()
        BBF.SetMirrorPlayerAltFrameTexture()
        return
    end
    DefaultBarLayout(hpContainer, healthBar, mask)
end

local function RestoreBar()
    local hpContainer, healthBar, mask = GetHealthBits()
    if BetterBlizzFramesDB.classicFrames then
        SetContainerPoint(hpContainer, 87, -44)
        hpContainer:SetSize(124, 15)
        healthBar:SetWidth(124)
        BBF.SquishClassicPlayerHealth()
        BBF.UpdatePlayerOvershieldAnchor()
        BBF.SizeClassicPlayerMana()
        return
    end
    if BBF.HasNoPortrait("player") then
        hpContainer:SetHeight(HEALTHBAR_HEIGHT)
        healthBar:SetHeight(HEALTHBAR_HEIGHT)
        if BetterBlizzFramesDB.noPortraitPixelBorder then
            BBF.UpdatePlayerPixelBorderSize()
            return
        end
        BBF.ApplyNoPortraitPlayerMask()
        return
    end
    if PlayerFrame.state == "vehicle" then return end
    SetDefaultManaShown(not BBF.PlayerManaHiddenArt())
    SetDefaultFrameTexture("UI-HUD-UnitFrame-Player-PortraitOn")
    BBF.UpdatePlayerAltFrameArt()
    BBF.UpdateNoShadowPlayerAltFrameTexture()
    BBF.UpdatePlayerFrameFlash()
    if BetterBlizzFramesDB.symmetricPlayerFrame then
        local width, containerHeight, barHeight = BBF.GetMirrorPlayerHealthbarSize()
        local grow = BBF.GetMirrorPlayerHealthbarGrow()
        SetContainerPoint(hpContainer, 85)
        hpContainer:SetSize(width, containerHeight)
        healthBar:SetSize(width + grow, barHeight)
        healthBar:SetPoint("TOPLEFT", hpContainer, "TOPLEFT", -1.5 - grow, 1)
        SetMirrorHealthTextY(hpContainer, 1)
        local contextual = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual
        BBF.ShiftRegionY(contextual and contextual.LeaderIcon, 0)
        BBF.ShiftRegionY(contextual and contextual.GuideIcon, 0)
        BBF.ShiftRegionY(contextual and contextual.RoleIcon, 0)
        BBF.SetMirrorPlayerHealthbarMask()
        BBF.SetMirrorPlayerFrameTexture()
        BBF.SetMirrorPlayerAltFrameTexture()
        return
    end
    if BBF.PlayerManaHiddenArt() then
        DefaultBarLayout(hpContainer, healthBar, mask)
        return
    end
    if not BBF.LevelOnTextArea(PlayerFrame) then
        BBF.ShiftRegionY(PlayerLevelText, 0)
    end
    BBF.ShiftRegionY(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ReputationColor, 0)
    local contextual = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual
    BBF.ShiftRegionY(contextual and contextual.LeaderIcon, 0)
    BBF.ShiftRegionY(contextual and contextual.GuideIcon, 0)
    BBF.ShiftRegionY(contextual and contextual.RoleIcon, 0)
    hpContainer:SetHeight(HEALTHBAR_HEIGHT)
    healthBar:ClearAllPoints()
    healthBar:SetPoint("TOPLEFT", hpContainer, "TOPLEFT", 0, 0)
    healthBar:SetSize(124, HEALTHBAR_HEIGHT)
    SetHealthTextOffset(hpContainer, 0)
    mask:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Mask", true)
    mask:ClearAllPoints()
    mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -2, 6)
    mask:SetHeight(31)
end
local function PlayerMaskOffset()
    if not BBF.HasNoPortrait("player") or BetterBlizzFramesDB.noPortraitPixelBorder then return end
    if PlayerFrame.state == "vehicle" then
        local _, healthBar, mask = GetHealthBits()
        mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -30, 10)
        return
    end
    BBF.ApplyNoPortraitBigPlayerMask()
end
local function VehicleMaskOffset()
    if not BBF.HasNoPortrait("player") or BetterBlizzFramesDB.noPortraitPixelBorder then return end
    local _, healthBar, mask = GetHealthBits()
    mask:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -34, 10)
end
local function UpdateClassicArt()
    if not BetterBlizzFramesDB.classicFrames then return end
    BBF.PlayerReputationColor()
    if UnitHasVehiclePlayerFrameUI("player") then return end
    if BBF.UpdateClassicPlayerArt then BBF.UpdateClassicPlayerArt() end
    BBF.SetCenteredNamesCaller()
end
local function Apply()
    if not IsEnabled() then
        if BBF.PlayerManaHiddenArt() and PlayerFrame.state ~= "vehicle" then
            if InCombatLockdown() then
                BBF.RunAfterCombat(Apply)
                return
            end
            RestoreBar()
        end
        return
    end
    if InCombatLockdown() then
        BBF.RunAfterCombat(Apply)
        return
    end
    UpdateClassicArt()
    BBF.UpdateNoPortraitManaVisibility()
    GrowBar()
    PlayerMaskOffset()
    if BBF.HasNoPortrait("player") then
        BBF.UpdateNoPortraitText(PlayerFrame, "player")
    end
end

local vehicleExitListener
function BBF.UnregisterPlayerFrameArtEvents()
    if UnitInVehicle("player") then
        PlayerFrame:UnregisterEvent("UNIT_ENTERED_VEHICLE")
        PlayerFrame:UnregisterEvent("UNIT_EXITING_VEHICLE")
        if not vehicleExitListener then
            vehicleExitListener = CreateFrame("Frame")
            vehicleExitListener:SetScript("OnEvent", function(self)
                self:UnregisterAllEvents()
                BBF.UnregisterPlayerFrameArtEvents()
            end)
        end
        vehicleExitListener:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
        return
    end
    if vehicleExitListener then
        vehicleExitListener:UnregisterAllEvents()
    end
    PlayerFrame:UnregisterEvent("UNIT_ENTERED_VEHICLE")
    PlayerFrame:UnregisterEvent("UNIT_EXITING_VEHICLE")
    PlayerFrame:UnregisterEvent("UNIT_EXITED_VEHICLE")
    if AlternatePowerBar then
        AlternatePowerBar:UnregisterEvent("UNIT_DISPLAYPOWER")
    end
end

local hooked = false
local function EnsureHooks()
    if hooked then
        return
    end
    hooked = true
    hooksecurefunc(BBF, "noPortraitModes", function()
        if BBF.BigPlayerHealthbar() then
            C_Timer.After(0, Apply)
        end
    end)
    hooksecurefunc("PlayerFrame_ToPlayerArt", Apply)
    hooksecurefunc("PlayerFrame_ToVehicleArt", function()
        Apply()
        VehicleMaskOffset()
    end)
    local container = PlayerFrame.PlayerFrameContainer
    hooksecurefunc(container.FrameTexture, "SetAtlas", function(_, atlas)
        if atlas ~= "UI-HUD-UnitFrame-Player-PortraitOn" or not CustomPlayerArt() then return end
        if BetterBlizzFramesDB.symmetricPlayerFrame then return end
        SetDefaultFrameTexture(atlas)
    end)
    hooksecurefunc(container.AlternatePowerFrameTexture, "SetAtlas", function(_, atlas)
        if atlas ~= "UI-HUD-UnitFrame-Player-PortraitOn-ClassResource" or not CustomPlayerArt() then return end
        BBF.UpdatePlayerAltFrameArt()
    end)
    if BBF.HasNoPortrait("player") then
        BBF.UnregisterPlayerFrameArtEvents()
    end
end

local function SecondResourceBars()
    return { AlternatePowerBar, MonkStaggerBar, EvokerEbonMightBar, DemonHunterSoulFragmentsBar }
end

function BBF.UpdatePlayerSecondResource()
    local db = BetterBlizzFramesDB
    if db.classicFrames or BBF.HasNoPortrait("player") then return end
    local hide = db.hideUnitFramePlayerSecondResource
    if hide and not BBF.secondResourceHooked then
        BBF.secondResourceHooked = true
        hooksecurefunc("PlayerFrame_ToPlayerArt", BBF.UpdatePlayerSecondResource)
    end
    if not hide and not BBF.secondResourceHidden then return end
    for _, bar in pairs(SecondResourceBars()) do
        bar:SetAlpha(hide and 0 or 1)
    end
    BBF.secondResourceHidden = hide or nil
    if PlayerFrame.state ~= "player" or UNIT_FRAME_SHOW_HEALTH_ONLY then return end
    local container = PlayerFrame.PlayerFrameContainer
    local altBar = PlayerFrame_GetAlternatePowerBar()
    container.FrameTexture:SetShown(hide or altBar == nil)
    container.AlternatePowerFrameTexture:SetShown(not hide and altBar ~= nil)
    BBF.UpdatePlayerFrameFlash()
end

local function RefreshHealthbarTexture()
    if not BBF.customTexturesReady then return end
    if not BetterBlizzFramesDB.classicFrames then return end
    if not BBF.UnitFrameTextureOn("health") then return end
    BBF.UpdateCustomTextures()
end

function BBF.UpdateBigPlayerHealthbar()
    BBF.PlayerReputationColor()
    if IsEnabled() then
        EnsureHooks()
        Apply()
        RefreshHealthbarTexture()
        return
    end

    if InCombatLockdown() then
        BBF.RunAfterCombat(BBF.UpdateBigPlayerHealthbar)
        return
    end
    if CustomPlayerArt() then
        EnsureHooks()
    end
    RestoreBar()

    BBF.UpdateNoPortraitManaVisibility()
    UpdateClassicArt()
    RefreshHealthbarTexture()
    if BBF.HasNoPortrait("player") then
        BBF.UpdateNoPortraitText(PlayerFrame, "player")
    end
end
