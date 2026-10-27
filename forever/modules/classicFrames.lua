local function SetXYPoint(frame, xOffset, yOffset)
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
    frame:SetPoint(point, relativeTo, relativePoint, xOffset or xOfs, yOffset or yOfs)
end

local function RoundToPixel(region)
    if not region or region.bbfPixelRounded or not region.SetRoundLayoutToNearestPixel or InCombatLockdown() then return end
    region.bbfPixelRounded = true
    region:SetRoundLayoutToNearestPixel(true)
end

local function SetManaTextParent(text, parent)
    if BetterBlizzFramesDB.hideAllManabarText then
        text.bbfOriginalParent = parent
        parent = BBF.hiddenFrame
    end
    text:SetParent(parent)
end

function BBF.ClassicLevelShift(levelText)
    local place = levelText.bbfClassicLevel
    if not place then return 0 end
    local text = levelText:GetText()
    if text == nil or issecretvalue(text) then return place.other end
    text = tostring(text)
    if place.levels then return place.levels(text) end
    if text:sub(-1) == "1" then return 0.5 end
    if text == "10" then return place.ten end
    if text:sub(1, 1) == "1" then return place.startsOne end
    return place.other
end

local function PlaceClassicLevelText(levelText)
    local place = levelText.bbfClassicLevel
    if not place then return end
    local x = place.x + BBF.ClassicLevelShift(levelText)
    levelText:ClearAllPoints()
    if place.relativeTo then
        levelText:SetPoint("CENTER", place.relativeTo, place.relativePoint, x, place.y)
    else
        levelText:SetPoint("CENTER", x, place.y)
    end
end

local function SetClassicLevelPoint(levelText, x, y, startsOne, ten, other, relativeTo, relativePoint, levels)
    levelText.bbfClassicLevel = { x = x, y = y, startsOne = startsOne, ten = ten, other = other, relativeTo = relativeTo, relativePoint = relativePoint, levels = levels }
    if not levelText.bbfClassicLevelHooked then
        levelText.bbfClassicLevelHooked = true
        hooksecurefunc(levelText, "SetText", PlaceClassicLevelText)
    end
    PlaceClassicLevelText(levelText)
end

local function PlayerLevelShift(text)
    if #text == 1 or text == "10" then return -1.5 end
    return -2
end

local class = UnitClassBase("player")
local defaultTex = "Interface\\TargetingFrame\\UI-TargetingFrame"
local noLvlTex = "Interface\\TargetingFrame\\UI-FocusFrame-Large"
local flashTex = "Interface\\TargetingFrame\\UI-TargetingFrame-Flash"
local flashNoLvl = "Interface\\TargetingFrame\\UI-FocusFrame-Large-Flash"
local bigPath = "Interface\\AddOns\\BetterBlizzFrames\\media\\classicTextures\\"
local bigTex = bigPath .. "UI-TargetingFrame-Retail.png"
local bigNoLvlTex = bigPath .. "UI-TargetingFrame-NoLevel-Retail.png"
local bigNoManaTex = bigPath .. "UI-TargetingFrame-Retail-NoMana.png"
local bigNoManaNoLvlTex = bigPath .. "UI-TargetingFrame-NoLevel-Retail-NoMana.png"
local bigStatusTex = bigPath .. "UI-Player-Status-Big.png"
local bigStatusNoLvlTex = bigPath .. "UI-Player-Status-Big-NoLevel.png"
local bigStatusNoManaTex = bigPath .. "NoManas\\UI-Player-Status-Big-NoMana.png"
local bigStatusNoManaNoLvlTex = bigPath .. "NoManas\\UI-Player-Status-Big-NoLevel-NoMana.png"
local bigTotTex = bigPath .. "ui-targetoftargetframe-large.png"
local smallTex = "Interface\\TargetingFrame\\UI-SmallTargetingFrame"
local smallNoManaTex = bigPath .. "UI-SmallTargetingFrame-NoMana.png"
local smallBigTex = bigPath .. "UI-SmallTargetingFrame-Big.png"
local smallBigNoManaTex = bigPath .. "UI-SmallTargetingFrame-Big-NoMana.png"

local function ClassicBigParty()
    local db = BetterBlizzFramesDB
    return BBF.BigHealthbarsOn() and db.bigHealthbarParty and true or false
end

local function ClassicBigToT()
    local db = BetterBlizzFramesDB
    return BBF.BigHealthbarsOn() and db.bigHealthbarToT and true or false
end

local function ClassicPartyNoMana()
    return BetterBlizzFramesDB.hideDefaultPartyFramesMana and true or false
end

local classicNoManaArt = {
    ["Interface\\TargetingFrame\\UI-TargetingFrame"] = bigPath .. "NoManas\\UI-TargetingFrame-NoMana.png",
    ["Interface\\TargetingFrame\\UI-FocusFrame-Large"] = bigPath .. "NoManas\\UI-TargetingFrame-NoLevel-NoMana.png",
    ["Interface\\TargetingFrame\\UI-TargetingFrame-Elite"] = bigPath .. "NoManas\\UI-TargetingFrame-Elite-NoMana.png",
    ["Interface\\TargetingFrame\\UI-TargetingFrame-Rare"] = bigPath .. "NoManas\\UI-TargetingFrame-Rare-NoMana.png",
    ["Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite"] = bigPath .. "NoManas\\UI-TargetingFrame-Rare-Elite-NoMana.png",
    [bigPath .. "UI-TargetingFrame-Elite-NoLevel.png"] = bigPath .. "NoManas\\UI-TargetingFrame-Elite-NoLevel-NoMana.png",
    [bigPath .. "UI-TargetingFrame-Rare-NoLevel.png"] = bigPath .. "NoManas\\UI-TargetingFrame-Rare-NoLevel-NoMana.png",
    [bigPath .. "UI-TargetingFrame-Rare-Elite-NoLevel.png"] = bigPath .. "NoManas\\UI-TargetingFrame-Rare-Elite-NoLevel-NoMana.png",
}

local playerEliteNames = { "Rare", "Rare-Elite", "Elite" }

local function PlayerEliteArt(mode, noLvl)
    local name = "UI-TargetingFrame-" .. playerEliteNames[mode]
    if noLvl then
        return bigPath .. name .. "-NoLevel.png", bigPath .. name .. "-NoLevel-Retail.png", bigPath .. "NoManas\\" .. name .. "-NoLevel-Big-NoMana.png"
    end
    return "Interface\\TargetingFrame\\" .. name, bigPath .. name .. "-Retail.png", bigPath .. "NoManas\\" .. name .. "-Big-NoMana.png"
end

local function ClassicToTNoMana()
    return ClassicBigToT() or (BetterBlizzFramesDB.hideUnitFrameTotMana and true or false)
end
local eliteTextures = {
    rareelite = "Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite",
    worldboss = "Interface\\TargetingFrame\\UI-TargetingFrame-Elite",
    elite = "Interface\\TargetingFrame\\UI-TargetingFrame-Elite",
    rare = "Interface\\TargetingFrame\\UI-TargetingFrame-Rare",
}
local eliteNoLvlTextures = {
    rareelite = bigPath .. "UI-TargetingFrame-Rare-Elite-NoLevel.png",
    worldboss = bigPath .. "UI-TargetingFrame-Elite-NoLevel.png",
    elite = bigPath .. "UI-TargetingFrame-Elite-NoLevel.png",
    rare = bigPath .. "UI-TargetingFrame-Rare-NoLevel.png",
}

local HD_MO = "Interface\\AddOns\\BetterBlizzFrames\\media\\classicTextures\\MoTextures\\"
local HD_NOMANA = HD_MO .. "NoManas\\"

local hdFrame = { HD_MO .. "UI-TargetingFrame-NoLevel.png", HD_NOMANA .. "UI-TargetingFrame-NoLevel-NoMana.png" }
local hdBig = { HD_MO .. "UI-TargetingFrame-NoLevel-Retail.png", HD_NOMANA .. "UI-TargetingFrame-NoLevel-Retail-NoMana.png" }
local hdBigNoMana = { HD_NOMANA .. "UI-TargetingFrame-NoLevel-Retail-NoMana.png" }
local hdFrameNoMana = { HD_NOMANA .. "UI-TargetingFrame-NoLevel-NoMana.png" }
local hdSmall = { HD_MO .. "UI-SmallTargetingFrame.png", HD_NOMANA .. "UI-SmallTargetingFrame-NoMana.png" }
local hdTot = { HD_MO .. "UI-TargetOfTargetFrame.png", HD_NOMANA .. "UI-TargetOfTargetFrame-NoMana.png" }
local hdTotNoMana = { HD_NOMANA .. "UI-TargetOfTargetFrame-NoMana.png" }
local hdSmallNoMana = { HD_NOMANA .. "UI-SmallTargetingFrame-NoMana.png" }
local hdSmallBig = { HD_MO .. "UI-SmallTargetingFrame-Big.png", HD_NOMANA .. "UI-SmallTargetingFrame-Big-NoMana.png" }
local hdSmallBigNoMana = { HD_NOMANA .. "UI-SmallTargetingFrame-Big-NoMana.png" }
local hdCastbar = { HD_MO .. "UI-CastingBar-Border.png" }
local hdCastbarSmall = { HD_MO .. "ui-castingbar-border-small.png" }
local hdCastbarShield = { HD_MO .. "ui-castingbar-small-shield.png" }

local frameTextures = {
    ["Interface\\TargetingFrame\\UI-TargetingFrame"] = hdFrame,
    ["Interface\\TargetingFrame\\UI-FocusFrame-Large"] = hdFrame,
    ["Interface\\TargetingFrame\\UI-TargetingFrame-Elite"] = hdFrame,
    ["Interface\\TargetingFrame\\UI-TargetingFrame-Rare"] = hdFrame,
    ["Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite"] = hdFrame,
    [bigPath .. "UI-TargetingFrame-Retail.png"] = hdBig,
    [bigPath .. "UI-TargetingFrame-NoLevel-Retail.png"] = hdBig,
    [bigPath .. "UI-TargetingFrame-Retail-NoMana.png"] = hdBigNoMana,
    [bigPath .. "UI-TargetingFrame-NoLevel-Retail-NoMana.png"] = hdBigNoMana,
    [bigPath .. "NoManas\\UI-TargetingFrame-NoMana.png"] = hdFrameNoMana,
    [bigPath .. "NoManas\\UI-TargetingFrame-NoLevel-NoMana.png"] = hdFrameNoMana,
    [bigPath .. "NoManas\\UI-TargetingFrame-Elite-NoMana.png"] = hdFrameNoMana,
    [bigPath .. "NoManas\\UI-TargetingFrame-Rare-NoMana.png"] = hdFrameNoMana,
    [bigPath .. "NoManas\\UI-TargetingFrame-Rare-Elite-NoMana.png"] = hdFrameNoMana,
    ["Interface\\TargetingFrame\\UI-SmallTargetingFrame"] = hdSmall,
    ["Interface\\TargetingFrame\\UI-TargetofTargetFrame"] = hdTot,
    [bigTotTex] = hdTotNoMana,
    [smallNoManaTex] = hdSmallNoMana,
    [smallBigTex] = hdSmallBig,
    [smallBigNoManaTex] = hdSmallBigNoMana,
}

local castbarTextures = {
    [130873] = hdCastbarSmall,
    [130874] = hdCastbar,
    ["Interface\\CastingBar\\UI-CastingBar-Border"] = hdCastbar,
    [311862] = hdCastbarShield,
}

local hdTextures = {}
local hdRings = {}

function BBF.ClassicHDTexturesActive()
    local db = BetterBlizzFramesDB
    return db.classicFrames and db.classicFramesHDTextures and true or false
end

function BBF.ClassicHDCastbarsActive()
    return BetterBlizzFramesDB.classicFramesHDTextures and true or false
end

function BBF.GetClassicTexture(original, noMana, isCastbar)
    local active = isCastbar and BBF.ClassicHDCastbarsActive() or (not isCastbar and BBF.ClassicHDTexturesActive())
    local entry = active and (isCastbar and castbarTextures or frameTextures)[original]
    if not entry then return original, false end
    return (noMana and entry[2]) or entry[1], true
end

function BBF.ClassicHDBronze(isCastbar)
    local check
    if isCastbar then
        check = BBF.CastbarBronzeTintActive
    else
        check = BBF.ClassicBronzeTintActive
    end
    return check and check() and true or false
end

function BBF.ApplyClassicHDColor(texture, isCastbar)
    if not texture or texture:IsForbidden() then return end
    if BBF.ClassicHDBronze(isCastbar) then
        texture.bbfBronzeChanging = true
        texture:SetDesaturated(false)
        texture:SetVertexColor(1, 1, 1)
        texture.bbfBronzeChanging = false
    else
        local desat = texture.bbfSyncedDesat
        if desat == nil then desat = true end
        texture:SetDesaturated(desat)
    end
end

function BBF.SetClassicFlash(texture, noLvl, flip)
    if BBF.ClassicHDTexturesActive() then
        texture:SetTexture(HD_MO .. "UI-FocusFrame-Large-Flash.png")
        noLvl = true
    else
        texture:SetTexture(noLvl and flashNoLvl or flashTex)
    end
    if noLvl then
        if flip then
            texture:SetTexCoord(0.9553125, 0, -0.01, 0.733)
        else
            texture:SetTexCoord(0, 0.9553125, -0.01, 0.733)
        end
    elseif flip then
        texture:SetTexCoord(0.9453125, 0, 0, 0.181640625)
    else
        texture:SetTexCoord(0, 0.9453125, 0, 0.181640625)
    end
end

function BBF.SetClassicTexture(texture, original, noMana, isCastbar)
    if not texture then return end
    local path, hd = BBF.GetClassicTexture(original, noMana, isCastbar)
    texture:SetTexture(path)
    if hd then
        texture.bbfClassicHD = isCastbar and "castbar" or "frame"
        hdTextures[texture] = true
        BBF.ApplyClassicHDColor(texture, isCastbar)
    elseif texture.bbfClassicHD then
        local db = BetterBlizzFramesDB
        local wasCastbar = texture.bbfClassicHD == "castbar"
        texture.bbfClassicHD = nil
        hdTextures[texture] = nil
        local desat = not wasCastbar and (db.classicFramesDesaturated or db.classColorFrameTexture) and true or false
        if desat and texture.bbfSyncedDesat ~= nil then desat = texture.bbfSyncedDesat end
        texture:SetDesaturated(desat)
    end
end

function BBF.ClassicHDFrameColor(texture, r, g, b)
    if texture.bbfClassicHD and BBF.ClassicHDBronze() then
        return 1, 1, 1
    end
    return r, g, b
end

function BBF.SquishClassicPlayerHealth()
    local hpContainer = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
    local healthBar = hpContainer.HealthBar
    healthBar:SetSize(120, BetterBlizzFramesDB.hideUnitFramePlayerMana and 21 or 9)
    healthBar:ClearAllPoints()
    healthBar:SetPoint("TOPLEFT", hpContainer, "TOPLEFT", 0, -7)
    BBF.MaskClassicPlayerHealth()
end

local FRAME_MASK = "Interface\\AddOns\\BetterBlizzFrames\\media\\masks\\frameMask.png"

BBF.ClassicManaMask = {
    player = { left = 0, right = 0, top = 0, bottom = 0 },
    target = { left = 0, right = 0, top = 0, bottom = 0 },
}

BBF.ClassicHealthMask = {
    player = { left = 0, right = 0, top = 0, bottom = 0 },
}

local function FitFrameMask(mask, bar, o)
    mask:SetTexture(FRAME_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:ClearAllPoints()
    mask:SetPoint("TOPLEFT", bar, "TOPLEFT", -o.left, o.top)
    mask:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", o.right, -o.bottom)
    mask:Show()
end

local function MaskClassicMana(manaBar, key)
    FitFrameMask(manaBar.ManaBarMask, manaBar, BBF.ClassicManaMask[key])
end

local classicHealthHooked

function BBF.MaskClassicPlayerHealth()
    if not BetterBlizzFramesDB.classicFrames or PlayerFrame.state == "vehicle" then return end
    if not classicHealthHooked and PlayerFrame_UpdateHealthBarVisuals then
        classicHealthHooked = true
        hooksecurefunc("PlayerFrame_UpdateHealthBarVisuals", BBF.MaskClassicPlayerHealth)
    end
    local hpContainer = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
    FitFrameMask(hpContainer.HealthBarMask, hpContainer.HealthBar, BBF.ClassicHealthMask.player)
end

function BBF.RefreshClassicManaMasks()
    if not BetterBlizzFramesDB.classicFrames then return end
    if PlayerFrame.state ~= "vehicle" then
        MaskClassicMana(PlayerFrame_GetManaBar(), "player")
        BBF.MaskClassicPlayerHealth()
    end
    for _, frame in ipairs({ TargetFrame, FocusFrame }) do
        if frame and frame.ClassicFrame then
            MaskClassicMana(frame.TargetFrameContent.TargetFrameContentMain.ManaBar, "target")
        end
    end
end

local classicManaHooked

function BBF.SizeClassicPlayerMana()
    local db = BetterBlizzFramesDB
    if not db.classicFrames or PlayerFrame.state == "vehicle" then return end
    if not classicManaHooked and PlayerFrame_UpdateManaBarVisuals then
        classicManaHooked = true
        hooksecurefunc("PlayerFrame_UpdateManaBarVisuals", BBF.SizeClassicPlayerMana)
    end
    if InCombatLockdown() then
        BBF.RunAfterCombat(BBF.SizeClassicPlayerMana)
        return
    end
    local manaBar = PlayerFrame_GetManaBar()
    manaBar:SetSize(120, 11)
    MaskClassicMana(manaBar, "player")
end

function BBF.SyncClassicFrameDesaturation(texture, source)
    local db = BetterBlizzFramesDB
    if not db.classColorFrameTexture or db.classicFramesDesaturated then return end
    texture.bbfSyncedDesat = source:IsDesaturated() and true or false
    if texture.bbfClassicHD and BBF.ClassicHDBronze() then return end
    texture:SetDesaturated(texture.bbfSyncedDesat)
end

function BBF.ColorClassicHDLevelRing(frame)
    local classicFrame = frame and frame.ClassicFrame
    local ring = classicFrame and classicFrame.HDLevelCircle
    local texture = classicFrame and classicFrame.Texture
    if not ring or not texture or not BBF.ClassicHDTexturesActive() then return end
    hdRings[frame] = true
    local r, g, b = texture:GetVertexColor()
    ring:SetDesaturated(texture:IsDesaturated())
    ring:SetVertexColor(r, g, b)
end

function BBF.UpdateClassicHDTextureColors()
    for texture in pairs(hdTextures) do
        if texture.bbfClassicHD then
            BBF.ApplyClassicHDColor(texture, texture.bbfClassicHD == "castbar")
        end
    end
    for frame in pairs(hdRings) do
        BBF.ColorClassicHDLevelRing(frame)
    end
end

local function BigPlayerHealthbar()
    return BBF.BigPlayerHealthbar()
end

local function BigPlayerHealthbarNoMana()
    return BBF.BigPlayerHealthbar() and BetterBlizzFramesDB.hideUnitFramePlayerMana
end

local function PlayerNoManaArt()
    return not BBF.BigPlayerHealthbar() and BetterBlizzFramesDB.hideUnitFramePlayerMana
end

local function SetPlayerNormalTexture(texture, path)
    BBF.SetClassicTexture(texture, PlayerNoManaArt() and classicNoManaArt[path] or path)
end

local function SetPlayerFrameTexture(texture, normal, big, bigNoMana)
    if not BigPlayerHealthbar() then
        SetPlayerNormalTexture(texture, normal)
        return
    end
    BBF.SetClassicTexture(texture, BigPlayerHealthbarNoMana() and (bigNoMana or big) or big)
end

local function SetStatusGlowTexture(texture, normal, big, bigNoMana)
    if PlayerNoManaArt() then
        texture:SetTexture(nil)
        return
    end
    SetPlayerFrameTexture(texture, normal, big, bigNoMana)
end

local function UpdateClassicToTMana(totFrame)
    local noMana = ClassicToTNoMana()
    totFrame.HealthBar:SetSize(47, noMana and 15 or 7)
    BBF.SetClassicTexture(totFrame.FrameTexture, noMana and bigTotTex or "Interface\\TargetingFrame\\UI-TargetofTargetFrame")
    totFrame.ManaBar:SetAlpha(noMana and 0 or 1)
end

function BBF.ClassicBigPet()
    local db = BetterBlizzFramesDB
    return db.classicFrames and BBF.BigHealthbarsOn() and db.bigHealthbarPet and true or false
end

local function ClassicPetHealthTextY()
    local y = BetterBlizzFramesDB.hideUnitFramePetMana and -29.5 or -26
    return BBF.ClassicBigPet() and y + 6 or y
end

local function PlaceClassicPetHealthText()
    local y = ClassicPetHealthTextY()
    PetFrameHealthBarText:ClearAllPoints()
    PetFrameHealthBarText:SetPoint("CENTER", PetFrame, "TOPLEFT", 82, y)
    PetFrameHealthBarTextLeft:ClearAllPoints()
    PetFrameHealthBarTextLeft:SetPoint("LEFT", PetFrame, "TOPLEFT", 46, y)
    PetFrameHealthBarTextRight:ClearAllPoints()
    PetFrameHealthBarTextRight:SetPoint("RIGHT", PetFrame, "TOPLEFT", 115, y)
end

local function UpdateClassicPetMana()
    local noMana = BetterBlizzFramesDB.hideUnitFramePetMana
    local big = BBF.ClassicBigPet()
    if big then
        BBF.SetClassicTexture(PetFrameTexture, noMana and smallBigNoManaTex or smallBigTex)
    else
        BBF.SetClassicTexture(PetFrameTexture, noMana and smallNoManaTex or smallTex)
    end
    PetFrameTexture:SetTexCoord(0, 1, 0, 1)
    local grow = big and 12 or 0
    PetFrameHealthBar:SetSize(69, (noMana and 15 or 8) + grow)
    PetFrameHealthBar:ClearAllPoints()
    PetFrameHealthBar:SetPoint("TOPLEFT", 47, -22 + grow)
    PlaceClassicPetHealthText()
    local alpha = noMana and 0 or 1
    PetFrameManaBar:SetAlpha(alpha)
    PetFrameManaBarText:SetAlpha(alpha)
    PetFrameManaBarTextLeft:SetAlpha(alpha)
    PetFrameManaBarTextRight:SetAlpha(alpha)
end

function BBF.UpdateClassicHiddenMana()
    if not BBF.classicFramesBuilt or not BetterBlizzFramesDB.classicFrames then return end
    if InCombatLockdown() then
        BBF.RunAfterCombat(BBF.UpdateClassicHiddenMana)
        return
    end
    UpdateClassicToTMana(TargetFrame.totFrame)
    if FocusFrame then
        UpdateClassicToTMana(FocusFrame.totFrame)
    end
    UpdateClassicPetMana()
    if BBF.RefreshClassicPartyMana then
        BBF.RefreshClassicPartyMana()
    end
end

local function MakeClassicFrame(frame)
    local db = BetterBlizzFramesDB
    local hideLvl = db.hideLevelText
    local alwaysHideLvl = hideLvl and db.hideLevelTextAlways
    local hideDragon = db.hideRareDragonTexture

    local ClassResourceFrames = {
        ROGUE      = RogueComboPointBarFrame or BBF.ComboPointBar,
        DRUID      = DruidComboPointBarFrame or BBF.ComboPointBar,
        WARLOCK    = WarlockPowerFrame,
        MAGE       = MageArcaneChargesFrame,
        MONK       = MonkHarmonyBarFrame,
        EVOKER     = EssencePlayerFrame,
        PALADIN    = PaladinPowerBarFrame,
        DEATHKNIGHT = RuneFrame,
    }
    local classFrame = ClassResourceFrames[class]

    if frame == TargetFrame or frame == FocusFrame then
        -- Frame
        local content = frame.TargetFrameContent
        local frameContainer = frame.TargetFrameContainer
        local contentMain = content.TargetFrameContentMain
        local contentContext = content.TargetFrameContentContextual

        -- Status
        local hpContainer = contentMain.HealthBarsContainer
        local manaBar = contentMain.ManaBar

        local function PlaceClassicManaBar()
            if InCombatLockdown() then
                BBF.RunAfterCombat(PlaceClassicManaBar)
                return
            end
            manaBar:ClearAllPoints()
            manaBar:SetPoint("TOPRIGHT", frameContainer, "LEFT", 148, -12)
            manaBar:SetSize(120, 11)
        end
        PlaceClassicManaBar()

        frame.ClassicFrame = CreateFrame("Frame")
        frame.ClassicFrame:SetParent(frame)
        frame.ClassicFrame:SetFrameStrata("MEDIUM")
        frame.ClassicFrame:SetFrameLevel(9996)
        if frame == TargetFrame then
            BBF.RaiseCombosAboveTargetArt()
        end
        frame.ClassicFrame:SetAllPoints(frame)
        frame.ClassicFrame.Texture = frame.ClassicFrame:CreateTexture(nil, "OVERLAY")
        frame.ClassicFrame.Texture:SetParent(frame.ClassicFrame)
        frame.ClassicFrame.Texture:SetSize(232, 100)
        frame.ClassicFrame.Texture:SetTexCoord(0.09375, 1, 0, 0.78125)
        frame.ClassicFrame.Texture:SetPoint("TOPLEFT", 20, -8)

        frame.bbfName:SetParent(frame.ClassicFrame)
        frame.bbfName:SetDrawLayer("OVERLAY", 7)
        frame.ClassicFrame.Background = frame:CreateTexture(nil, "BACKGROUND")
        frame.ClassicFrame.Background:SetColorTexture(0,0,0,0.45)
        frame.ClassicFrame.BackgroundMask = frame:CreateMaskTexture()
        frame.ClassicFrame.BackgroundMask:SetTexture(FRAME_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        frame.ClassicFrame.BackgroundMask:SetAllPoints(frame.ClassicFrame.Background)
        frame.ClassicFrame.Background:AddMaskTexture(frame.ClassicFrame.BackgroundMask)
        frame.ClassicFrame.UpdateBackground = function()
            local background = frame.ClassicFrame.Background
            local healthBar = BBF.HealthBar(frame)
            background:ClearAllPoints()
            if BBF.IsBigHealthbarActive(frame) then
                background:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 0, 0)
                background:SetPoint("BOTTOMRIGHT", contentMain.ManaBar, "BOTTOMRIGHT", -2, -1)
                return
            end
            background:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 0, 19)
            background:SetPoint("BOTTOMRIGHT", contentMain.ManaBar, "BOTTOMRIGHT", -2, -1)
        end
        frame.ClassicFrame.UpdateBackground()

        local function GetFrameColor()
            local r,g,b = frameContainer.FrameTexture:GetVertexColor()
            BBF.SyncClassicFrameDesaturation(frame.ClassicFrame.Texture, frameContainer.FrameTexture)
            frame.ClassicFrame.Texture:SetVertexColor(BBF.ClassicHDFrameColor(frame.ClassicFrame.Texture, r, g, b))
            frameContainer.FrameTexture:SetAlpha(0)
            BBF.ColorClassicHDLevelRing(frame)
        end
        GetFrameColor()
        hooksecurefunc(frameContainer.FrameTexture, "SetVertexColor", GetFrameColor)

        local hpTextYOffset = BBF.ClassicHealthTextY(frame)
        hpContainer.LeftText:SetParent(frame.ClassicFrame)
        hpContainer.LeftText:ClearAllPoints()
        hpContainer.LeftText:SetPoint("LEFT", frame.ClassicFrame.Texture, "LEFT", 7.5, hpTextYOffset)
        hpContainer.RightText:SetParent(frame.ClassicFrame)
        hpContainer.RightText:ClearAllPoints()
        hpContainer.RightText:SetPoint("RIGHT", frame.ClassicFrame.Texture, "RIGHT", -109.5, hpTextYOffset)
        hpContainer.HealthBarText:SetParent(frame.ClassicFrame)
        hpContainer.HealthBarText:ClearAllPoints()
        hpContainer.HealthBarText:SetPoint("CENTER", frame.ClassicFrame.Texture, "LEFT", 66.5, hpTextYOffset)
        hpContainer.DeadText:SetParent(frame.ClassicFrame)
        hpContainer.DeadText:ClearAllPoints()
        hpContainer.DeadText:SetPoint("CENTER", frame.ClassicFrame.Texture, "LEFT", 66, hpTextYOffset)
        hpContainer.UnconsciousText:SetParent(frame.ClassicFrame)
        hpContainer.UnconsciousText:ClearAllPoints()
        hpContainer.UnconsciousText:SetPoint("CENTER", frame.ClassicFrame.Texture, "LEFT", 66, hpTextYOffset)
        --AdjustFramePoint(hpContainer.HealthBar.OverAbsorbGlow, -7)
        hpContainer.HealthBar.OverAbsorbGlow:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPRIGHT", -7, 0)

        SetManaTextParent(manaBar.LeftText, frame.ClassicFrame)
        manaBar.LeftText:ClearAllPoints()
        manaBar.LeftText:SetPoint("LEFT", frame.ClassicFrame.Texture, "LEFT", 7.5, -8.5)
        SetManaTextParent(manaBar.RightText, frame.ClassicFrame)
        manaBar.RightText:ClearAllPoints()
        manaBar.RightText:SetPoint("RIGHT", frame.ClassicFrame.Texture, "RIGHT", -109.5, -8.5)
        SetManaTextParent(manaBar.ManaBarText, frame.ClassicFrame)
        manaBar.ManaBarText:ClearAllPoints()
        manaBar.ManaBarText:SetPoint("CENTER", frame.ClassicFrame.Texture, "LEFT", 66.5, -8.5)

        contentContext:SetParent(frame.ClassicFrame)
        contentContext.HighLevelTexture:SetParent(frame.ClassicFrame)
        contentContext.HighLevelTexture:SetDrawLayer("OVERLAY", 7)
        contentContext.HighLevelTexture:ClearAllPoints()
        contentContext.HighLevelTexture:SetSize(16, 20)
        contentContext.HighLevelTexture:SetPoint("CENTER", frame, "BOTTOMRIGHT", -34.5, 25)
        contentContext.PetBattleIcon:ClearAllPoints()
        contentContext.PetBattleIcon:SetPoint("CENTER", frame, "BOTTOMRIGHT", -35, 25)
        contentContext.PrestigePortrait:ClearAllPoints()
        contentContext.PrestigePortrait:SetPoint("TOPRIGHT", 5, -17)
        if contentContext.PvpBackgroundCircle then
            contentContext.PvpBackgroundCircle:ClearAllPoints()
            contentContext.PvpBackgroundCircle:SetPoint("TOP", contentContext, "TOPRIGHT", -20, -50)
        end
        contentContext.LeaderIcon:ClearAllPoints()
        contentContext.LeaderIcon:SetPoint("TOPRIGHT", -84, -13.5)
        contentContext.GuideIcon:ClearAllPoints()
        contentContext.GuideIcon:SetPoint("TOPRIGHT", -20, -14)
        contentContext.RaidTargetIcon:ClearAllPoints()
        contentContext.RaidTargetIcon:SetPoint("CENTER", frameContainer.Portrait, "TOP", 1.5, 1)

        --AdjustFramePoint(frameContainer.Portrait, nil, -4)
        frameContainer.Portrait:SetPoint("TOPRIGHT", frameContainer, "TOPRIGHT", -26, -19)

        contentMain.LevelText:SetParent(frame.ClassicFrame)
        contentMain.LevelText:SetDrawLayer("OVERLAY", 7)
        SetClassicLevelPoint(contentMain.LevelText, BBF.ClassicHDTexturesActive() and -36 or -34.5, 25.5, 1, 1.5, 2, frame, "BOTTOMRIGHT")
        local lvlFont, _, lvlFlags = contentMain.LevelText:GetFont()
        contentMain.LevelText:SetFont(lvlFont, 12, lvlFlags)
        contentMain.LevelText:SetJustifyH("CENTER")
        contentMain.ReputationColor:SetSize(119, 18)
        contentMain.ReputationColor:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-LevelBackground")
        contentMain.ReputationColor:ClearAllPoints()
        contentMain.ReputationColor:SetPoint("TOPRIGHT", -87, -31)

        -- if true then
        --     contentMain.ReputationColor:SetSize(121, 18)
        --     contentMain.ReputationColor:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health-Status")

        --     hooksecurefunc(contentMain.ReputationColor, "SetVertexColor", function(self)
        --         if self.changing then return end
        --         self.changing = true
        --         local r,g,b = self:GetVertexColor()
        --         if g == 1 then
        --             self:SetVertexColor(1,1,1)
        --             self:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health")
        --         else
        --             self:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health-Status")
        --         end
        --         self.changing = false
        --     end)
        -- end

        frameContainer.Flash:SetDrawLayer("BACKGROUND")
        frameContainer.Flash:SetParent(db.hideCombatGlow and BBF.hiddenFrame or frame)
        frameContainer.Portrait:SetSize(62,62)
        frameContainer.Portrait:ClearAllPoints()
        frameContainer.Portrait:SetPoint("TOPRIGHT", -23, -22)
        frameContainer.PortraitMask:SetSize(61,61)
        frameContainer.PortraitMask:ClearAllPoints()
        frameContainer.PortraitMask:SetPoint("CENTER", frameContainer.Portrait, "CENTER", 0, 0)
        frameContainer.BossPortraitFrameTexture:SetAlpha(0)


        -- frameContainer.PlayerPortrait:SetSize(62, 62)
        -- frameContainer.PlayerPortrait:ClearAllPoints()
        -- frameContainer.PlayerPortrait:SetPoint("TOPLEFT", 25, -22)
        -- frameContainer.PlayerPortraitMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        -- frameContainer.PlayerPortraitMask:ClearAllPoints()
        -- frameContainer.PlayerPortraitMask:SetPoint("CENTER", frameContainer.PlayerPortrait, "CENTER", 0, 0)



        --------- these might need updates / different method
        local totFrame = frame.totFrame
        local totHpBar = totFrame.HealthBar
        local totManaBar = totFrame.ManaBar
        totFrame:SetFrameStrata("MEDIUM")
        totFrame:SetFrameLevel(9998)
        totHpBar:SetStatusBarColor(0, 1, 0)
        totHpBar:ClearAllPoints()
        totHpBar:SetPoint("TOPRIGHT", -29, -15)
        totHpBar:SetFrameLevel(9998)
        totHpBar.HealthBarMask:Hide()
        totManaBar:SetSize(49, 7)
        totManaBar:ClearAllPoints()
        totManaBar:SetPoint("TOPRIGHT", -29, -23)
        totManaBar:SetFrameLevel(9998)
        totFrame.Background = totFrame.HealthBar:CreateTexture(nil, "BACKGROUND")
        totFrame.Background:SetColorTexture(0,0,0,0.45)
        totFrame.Background:SetPoint("TOPLEFT", totFrame.HealthBar, "TOPLEFT", 1, 0)
        totFrame.Background:SetPoint("BOTTOMRIGHT", totFrame.manabar, "BOTTOMRIGHT", -1, 0)
        totFrame.FrameTexture:SetSize(93, 45)
        UpdateClassicToTMana(totFrame)
        totFrame.FrameTexture:SetTexCoord(0.015625, 0.7265625, 0, 0.703125)
        totFrame.FrameTexture:ClearAllPoints()
        totFrame.FrameTexture:SetPoint("TOPLEFT", 0, 0)
        totFrame.FrameTexture:SetDrawLayer("OVERLAY", 7)
        if totFrame.bbfName then
            totFrame.bbfNameLayer = totFrame.bbfNameLayer or CreateFrame("Frame", nil, totFrame)
            totFrame.bbfNameLayer:SetAllPoints(totFrame)
            totFrame.bbfNameLayer:SetFrameLevel(9999)
            totFrame.bbfName:SetParent(totFrame.bbfNameLayer)
        end
        totFrame.Portrait:SetSize(37, 37)
        totFrame.Portrait:ClearAllPoints()
        totFrame.Portrait:SetPoint("TOPLEFT", 4, -5)
        totFrame.HealthBar.DeadText:SetParent(totFrame)
        totFrame.HealthBar.DeadText:ClearAllPoints()
        totFrame.HealthBar.DeadText:SetPoint("LEFT", 48, 3)
        totFrame.HealthBar.DeadText:SetDrawLayer("OVERLAY", 7)
        totFrame.HealthBar.UnconsciousText:SetParent(totFrame)
        totFrame.HealthBar.UnconsciousText:ClearAllPoints()
        totFrame.HealthBar.UnconsciousText:SetPoint("LEFT", 48, 3)
        totFrame.HealthBar.UnconsciousText:SetDrawLayer("OVERLAY", 7)

        local hideToTDebuffs = (frame.unit == "target" and db.hideTargetToTDebuffs) or (frame.unit == "focus" and db.hideFocusToTDebuffs)
        if not hideToTDebuffs then
            -- totFrame.lastUpdate = 0
            -- totFrame:HookScript("OnUpdate", function(self, elapsed)
            --     self.lastUpdate = self.lastUpdate + elapsed
            --     if self.lastUpdate >= 0.2 then
            --         self.lastUpdate = 0
            --         AuraUtil.RefreshAuras(self, self.unit, nil, nil, true) -- procs secret errors now
            --     end
            -- end)
            local debuffFrameName = totFrame:GetName().."Debuff"
            for i = 1, 4 do
                local debuffFrame = _G[debuffFrameName..i]
                debuffFrame:ClearAllPoints()
                if i == 1 then
                    debuffFrame:SetPoint("TOPLEFT", totFrame, "TOPRIGHT", -23, -8)
                elseif i == 2 then
                    debuffFrame:SetPoint("TOPLEFT", totFrame, "TOPRIGHT", -10, -8)
                elseif i== 3 then
                    debuffFrame:SetPoint("TOPLEFT", totFrame, "TOPRIGHT", -23, -21)
                elseif  i==4  then
                    debuffFrame:SetPoint("TOPLEFT", totFrame, "TOPRIGHT", -10, -21)
                end
            end
        end

        local function FrameAdjustments(frame)
            frame.FrameTexture:ClearAllPoints()
            frame.FrameTexture:SetPoint("TOPLEFT", 20.5, -18)
            frame.Flash:SetSize(240.5, 93)
            BBF.SetClassicFlash(frame.Flash, false)
            frame.Flash:ClearAllPoints()
            frame.Flash:SetPoint("TOPLEFT", -2.5, -8)
            contentMain.LevelText:SetAlpha(1)
            if frame.unit == "target" then
                contentMain.ReputationColor:SetShown(not BetterBlizzFramesDB.hideTargetReputationColor)
            elseif frame.unit == "focus" then
                contentMain.ReputationColor:SetShown(not BetterBlizzFramesDB.hideFocusReputationColor)
            end
        end

        local function UseHDElite()
            return BBF.ClassicHDEliteActive()
        end

        local function ToggleNoLevelFrame(noLvl, skipTexture)
            if noLvl then
                if not skipTexture then
                    BBF.SetClassicTexture(frame.ClassicFrame.Texture, BBF.ClassicBigTargetTexture(frame, noLvlTex))
                end
                BBF.SetClassicFlash(frameContainer.Flash, true)
                contentMain.LevelText:SetAlpha(0)
            else
                if not skipTexture then
                    BBF.SetClassicTexture(frame.ClassicFrame.Texture, BBF.ClassicBigTargetTexture(frame, defaultTex))
                end
                BBF.SetClassicFlash(frameContainer.Flash, false)
                contentMain.LevelText:SetAlpha(1)
            end
        end

        local function LevelHidden()
            return alwaysHideLvl or (hideLvl and UnitLevel(frame.unit) == GetMaxLevelForPlayerExpansion()) or false
        end

        local function HDLevelFrame()
            ToggleNoLevelFrame(LevelHidden(), true)
            BBF.SetClassicTexture(frame.ClassicFrame.Texture, BBF.ClassicBigTargetTexture(frame, noLvlTex))
            BBF.SetClassicHDLevelRing(frame, true)
        end

        local function SetEliteArt(classification)
            local noLvl = LevelHidden()
            if UseHDElite() then
                HDLevelFrame()
            elseif hideDragon then
                ToggleNoLevelFrame(noLvl)
            else
                local path = noLvl and eliteNoLvlTextures[classification] or eliteTextures[classification]
                BBF.SetClassicTexture(frame.ClassicFrame.Texture, BBF.ClassicBigTargetTexture(frame, path))
                ToggleNoLevelFrame(noLvl, true)
            end
        end

        local function RefreshEliteArt()
            local classification = UnitExists(frame.unit) and BBF.GetUnitClassification(frame.unit)
            if classification and eliteTextures[classification] then
                SetEliteArt(classification)
            end
            BBF.UpdateClassicHDElite(frame)
        end
        frame.ClassicFrame.RefreshEliteArt = RefreshEliteArt

        local function OnCheckClassification(self)
            local classification = BBF.GetUnitClassification(self.unit)

            -- Frame
            local content = self.TargetFrameContent
            local frameContainer = frameContainer
            local contentMain = content.TargetFrameContentMain
            -- Status
            local hpContainer = contentMain.HealthBarsContainer
            local manaBar = contentMain.ManaBar

            frame.ClassicFrame.UpdateBackground()
            frameContainer.FrameTexture:SetAlpha(0)

            MaskClassicMana(manaBar, "target")

            frame.ClassicFrame.Texture:ClearAllPoints()
            frame.ClassicFrame.Texture:SetPoint("TOPLEFT", 20, -8)


            if eliteTextures[classification] then
                FrameAdjustments(frameContainer)
                SetEliteArt(classification)
            else
                FrameAdjustments(frameContainer)
                if frame.unit == "target" then
                    contentMain.ReputationColor:SetShown(not BetterBlizzFramesDB.hideTargetReputationColor)
                elseif frame.unit == "focus" then
                    contentMain.ReputationColor:SetShown(not BetterBlizzFramesDB.hideFocusReputationColor)
                end
                ToggleNoLevelFrame(LevelHidden())
            end
            BBF.UpdateClassicEliteOverlay(self)
            BBF.UpdateClassicHDElite(self)
            BBF.SyncSelfEliteClassicArt(self)
        end
        frame.ClassicFrame.OnCheckClassification = OnCheckClassification
        hooksecurefunc(frame, "CheckClassification", OnCheckClassification)

        hooksecurefunc(frame, "CheckFaction", function(self)
            if (self.showPVP) then
                local factionGroup = UnitFactionGroup(self.unit)
                if (factionGroup == "Alliance") then
                    contentContext.PvpIcon:ClearAllPoints()
                    contentContext.PvpIcon:SetPoint("TOPRIGHT", -4, -24)
                elseif (factionGroup == "Horde") then
                    contentContext.PvpIcon:ClearAllPoints()
                    contentContext.PvpIcon:SetPoint("TOPRIGHT", 3, -22)
                end
                contentContext.PrestigePortrait:ClearAllPoints()
                contentContext.PrestigePortrait:SetPoint("TOPRIGHT", 5, -17)
            end
        end)

        if db.classicFramesDesaturated or db.classColorFrameTexture then
            frame.ClassicFrame.Texture:SetDesaturated(true)
            totFrame.FrameTexture:SetDesaturated(true)
        end

    elseif frame == PlayerFrame then
        local hideLvl, alwaysHideLvl = BBF.PlayerLevelHideFlags()
        -- PlayerFrame
        -- Frame
        local content = frame.PlayerFrameContent
        local frameContainer = frame.PlayerFrameContainer
        local contentMain = content.PlayerFrameContentMain
        local contentContext = content.PlayerFrameContentContextual
        -- Status
        local hpContainer = contentMain.HealthBarsContainer
        local manaBar = contentMain.ManaBarArea.ManaBar

        frame.ClassicFrame = CreateFrame("Frame")
        frame.ClassicFrame:SetParent(frame)
        frame.ClassicFrame:SetFrameStrata("MEDIUM")
        frame.ClassicFrame:SetFrameLevel(9996)
        frame.ClassicFrame:SetAllPoints(frame)
        frame.ClassicFrame.Texture = frame.ClassicFrame:CreateTexture(nil, "OVERLAY")
        frame.ClassicFrame.Texture:SetParent(frame.ClassicFrame)

        manaBar.FullPowerFrame:SetParent(frame.ClassicFrame)
        if frame.bbfName then
            frame.bbfName:SetParent(frame.ClassicFrame)
            frame.bbfName:SetDrawLayer("OVERLAY", 7)
        end

        contentMain.HitIndicator.HitText:ClearAllPoints()
        contentMain.HitIndicator.HitText:SetPoint("CENTER", frameContainer.PlayerPortrait)
        contentMain.HitIndicator.HitText:SetScale(0.85)
        contentMain.HitIndicator:SetParent(PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual)

        contentContext:SetParent(frame.ClassicFrame)
        if contentMain.PvpBackgroundCircle then
            contentMain.PvpBackgroundCircle:SetParent(frame.ClassicFrame)
            contentMain.PvpBackgroundCircle:SetDrawLayer("OVERLAY", 5)
        end
        if contentMain.PvpBackgroundIcon then
            contentMain.PvpBackgroundIcon:SetParent(frame.ClassicFrame)
            contentMain.PvpBackgroundIcon:SetDrawLayer("OVERLAY", 6)
        end
        contentContext.AttackIcon:ClearAllPoints()
        contentContext.AttackIcon:SetPoint("CENTER", -80, -23.5)
        contentContext.AttackIcon:SetSize(32, 31)
        contentContext.AttackIcon:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
        contentContext.AttackIcon:SetTexCoord(0.5, 1.0, 0, 0.484375)
        contentContext.AttackIcon:SetDrawLayer("OVERLAY")
        contentContext.PlayerPortraitCornerIcon:SetAtlas(nil)
        contentContext.PrestigePortrait:ClearAllPoints()
        contentContext.PrestigePortrait:SetPoint("TOPLEFT", -4, -17)
        contentContext.LeaderIcon:ClearAllPoints()
        contentContext.LeaderIcon:SetPoint("TOPLEFT", 86, -14)
        contentContext.RoleIcon:ClearAllPoints()
        contentContext.RoleIcon:SetPoint("TOPLEFT", 192, -34)

        --AdjustFramePoint(contentContext.GroupIndicator, nil, -3)

        frameContainer.PlayerPortrait:SetSize(62, 62)
        frameContainer.PlayerPortraitMask:SetSize(62, 62)
        frameContainer.PlayerPortraitMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        frameContainer.PlayerPortraitMask:ClearAllPoints()
        frameContainer.PlayerPortraitMask:SetPoint("CENTER", frameContainer.PlayerPortrait, "CENTER", 0, 0)

        -- Resource frame positioning table
        local resourceFrameAnchorPositions = {
            default = {point = "TOP", relativePoint = "BOTTOM", xOffset = 30, yOffset = 25},
            [102] = {point = "TOP", relativePoint = "BOTTOM", xOffset = 30, yOffset = 15}, -- Balance Druid
            [268] = {point = "TOP", relativePoint = "BOTTOM", xOffset = 30, yOffset = 15}, -- Brewmaster Monk
            [1473] = {point = "TOP", relativePoint = "BOTTOM", xOffset = 30, yOffset = 25}, -- Augmentation Evoker
        }

        frame.ClassicFrame.Background = frame:CreateTexture(nil, "BACKGROUND")
        frame.ClassicFrame.Background:SetColorTexture(0,0,0,0.45)
        frame.ClassicFrame.Background:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", 0, 20)
        frame.ClassicFrame.Background:SetPoint("BOTTOMRIGHT", manaBar, "BOTTOMRIGHT", -4, 1)
        frame.ClassicFrame.BackgroundMask = frame:CreateMaskTexture()
        frame.ClassicFrame.BackgroundMask:SetTexture(FRAME_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        frame.ClassicFrame.BackgroundMask:SetAllPoints(frame.ClassicFrame.Background)
        frame.ClassicFrame.Background:AddMaskTexture(frame.ClassicFrame.BackgroundMask)

        local function AdjustBackground()
            frame.ClassicFrame.Background:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", 0, BigPlayerHealthbar() and 0 or 20)
            frame.ClassicFrame.Background:SetPoint("BOTTOMRIGHT", hpContainer, "BOTTOMRIGHT", BigPlayerHealthbar() and 0 or -3, BigPlayerHealthbarNoMana() and 0 or -10)
        end


        C_Timer.After(1, function()
            local bd = BigDebuffsplayerUnitFrame
            local oa = C_AddOns.IsAddOnLoaded("OmniAuras")
            if bd then
                if bd.mask then
                    bd.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                elseif bd.icon then
                    bd.mask = bd:CreateMaskTexture()
                    bd.mask:SetAllPoints(bd.icon)
                    bd.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                    bd.icon:AddMaskTexture(bd.mask)
                end
            end
            if oa then
                for _, child in ipairs({PlayerFrame.PlayerFrameContainer:GetChildren()}) do
                    if child:IsObjectType("Button") then
                        local mask = child.mask
                        if mask and mask.SetTexture then
                            mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                            break
                        end
                    end
                end
            end
        end)


        local function AdjustStatusBarText()
            local hpTextYOffset = 2.8
            if BigPlayerHealthbar() then
                hpTextYOffset = (BigPlayerHealthbarNoMana() and 0.3 or 3.3) + (BetterBlizzFramesDB.biggerHealthbarsNameInside and 0 or 7) + (BBF.ClassicHDTexturesActive() and 1 or 0)
            end

            hpContainer.LeftText:SetParent(frame.ClassicFrame)
            hpContainer.LeftText:ClearAllPoints()
            hpContainer.LeftText:SetPoint("LEFT", frame.ClassicFrame.Texture, "LEFT", 108.5, hpTextYOffset)
            hpContainer.RightText:SetParent(frame.ClassicFrame)
            hpContainer.RightText:ClearAllPoints()
            hpContainer.RightText:SetPoint("RIGHT", frame.ClassicFrame.Texture, "RIGHT", -8, hpTextYOffset)
            hpContainer.HealthBarText:SetParent(frame.ClassicFrame)
            hpContainer.HealthBarText:ClearAllPoints()
            hpContainer.HealthBarText:SetPoint("CENTER", frame.ClassicFrame.Texture, "CENTER", 52, hpTextYOffset)

            SetManaTextParent(manaBar.LeftText, frame.ClassicFrame)
            manaBar.LeftText:ClearAllPoints()
            manaBar.LeftText:SetPoint("LEFT", frame.ClassicFrame.Texture, "LEFT", 108.5, -8.5)
            SetManaTextParent(manaBar.RightText, frame.ClassicFrame)
            manaBar.RightText:ClearAllPoints()
            manaBar.RightText:SetPoint("RIGHT", frame.ClassicFrame.Texture, "RIGHT", -8, -8.5)
            SetManaTextParent(manaBar.ManaBarText, frame.ClassicFrame)
            manaBar.ManaBarText:ClearAllPoints()
            manaBar.ManaBarText:SetPoint("CENTER", frame.ClassicFrame.Texture, "CENTER", 52, -8.5)
        end

        --AdjustFramePoint(hpContainer.HealthBar.OverAbsorbGlow,-3)
        hpContainer.HealthBar.OverAbsorbGlow:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPRIGHT", -7, 0)

        if BBF.LegacyCombosOn() and BBF.LegacyComboFrame then
            BBF.LegacyComboFrame:SetParent(TargetFrame)
            BBF.LegacyComboFrame:SetFrameStrata("HIGH")
            BBF.UpdateLegacyComboPosition()
        end

        local function UpdateLevelDetails()
            PlayerLevelText:SetParent(frame.ClassicFrame)
            PlayerLevelText:SetDrawLayer("OVERLAY", 7)
            PlayerLevelText:Show()
            SetClassicLevelPoint(PlayerLevelText, -81, -24.5, 0, -1, 1, nil, nil, PlayerLevelShift)
            local plvlFont, _, plvlFlags = PlayerLevelText:GetFont()
            if plvlFont then
                PlayerLevelText:SetFont(plvlFont, 12, plvlFlags)
            end
            PlayerLevelText:SetJustifyH("CENTER")
        end

        local function PlayerLevelHidden()
            return alwaysHideLvl or (hideLvl and UnitLevel("player") == GetMaxLevelForPlayerExpansion())
        end

        local function UpdatePlayerLevelRing()
            BBF.SetClassicHDLevelRing(frame, BBF.ClassicHDTexturesActive() or (db.playerEliteFrame and BBF.GetPlayerEliteMode() > 3))
        end
        BBF.UpdateClassicPlayerLevelRing = UpdatePlayerLevelRing

        local function UpdateLevel()
            if PlayerLevelHidden() then
                PlayerLevelText:SetParent(BBF.hiddenFrame)
                SetClassicLevelPoint(PlayerLevelText, -81, -24.5, 0, -1, 1, nil, nil, PlayerLevelShift)
            else
                UpdateLevelDetails()
            end
            UpdatePlayerLevelRing()
        end
        hooksecurefunc("PlayerFrame_UpdateLevel", function()
            UpdateLevel()
        end)
        UpdateLevel()

        hooksecurefunc("PlayerFrame_UpdateRolesAssigned", function()
            contentContext.RoleIcon:ClearAllPoints()
            contentContext.RoleIcon:SetPoint("TOPLEFT", 192, -34)
            PlayerLevelText:SetShown(not UnitHasVehiclePlayerFrameUI("player"))
        end)

        if not db.hidePvpTimerText then
            hooksecurefunc("PlayerFrame_UpdatePvPStatus", function()
                contentContext.PvpTimerText:ClearAllPoints()
                contentContext.PvpTimerText:SetPoint("BOTTOMLEFT", 8, 8)
            end)
        end

        local function GetFrameColor()
            local r, g, b = frameContainer.FrameTexture:GetVertexColor()
            BBF.SyncClassicFrameDesaturation(frame.ClassicFrame.Texture, frameContainer.FrameTexture)
            frame.ClassicFrame.Texture:SetVertexColor(BBF.ClassicHDFrameColor(frame.ClassicFrame.Texture, r, g, b))
            BBF.ColorClassicHDLevelRing(frame)

            if not db.darkModeUi then
                local soulShards = _G.WarlockPowerFrame
                if soulShards then
                    for _, v in pairs({soulShards:GetChildren()}) do
                        v.Background:SetVertexColor(
                            math.max(r - 0.35, 0),
                            math.max(g - 0.35, 0),
                            math.max(b - 0.35, 0)
                        )
                    end
                end
            end
            frameContainer.FrameTexture:SetAlpha(0)
        end

        GetFrameColor()
        hooksecurefunc(frameContainer.FrameTexture, "SetVertexColor", GetFrameColor)

        local DEFAULT_X, DEFAULT_Y = 29, 28.5
        local resourceFramePositions = {
            EVOKER = {x = 28, y = 31, scale = 1.05, specs = {[1473] = { x = 29, y = 23, scale = 1 }}},
            WARRIOR = { x = 28, y = 30 },
            ROGUE   = { x = 48, y = 38, scale = 0.85},
            MAGE = { x = 32, y = 32, scale = 0.95 },
            PALADIN = { scale = 0.91 },
            DEATHKNIGHT = { x = 35, y = 34, scale = 0.90 },
            DRUID = { x = 31, y = 30},
            MONK = { x = 29.5, y = 31, scale = 0.96 },
        }

        local function GetPlayerClassAndSpecPosition()
            local specID = BBF.GetSpecialization() and BBF.GetSpecializationInfo(BBF.GetSpecialization())
            local position = resourceFramePositions[class]

            if position then
                if position.specs and specID and position.specs[specID] then
                    local specData = position.specs[specID]
                    local x = specData.x or DEFAULT_X
                    local y = specData.y or DEFAULT_Y
                    local scale = specData.scale or 1
                    return x, y, scale
                end
                local x = position.x or DEFAULT_X
                local y = position.y or DEFAULT_Y
                local scale = position.scale or 1
                return x, y, scale
            end

            return DEFAULT_X, DEFAULT_Y, 1
        end

        local classConflicts = {
            ROGUE = db.moveResourceToTargetRogue,
            DRUID = db.moveResourceToTargetDruid,
            WARLOCK = db.moveResourceToTargetWarlock,
            MAGE = db.moveResourceToTargetMage,
            PALADIN = db.moveResourceToTargetPaladin,
        }

        local function UpdateResourcePosition(rogueCheck)
            if db.moveResourceToTarget and classConflicts[class] then
                return
            end

            if not InCombatLockdown() then
                local specID = BBF.GetSpecialization() and BBF.GetSpecializationInfo(BBF.GetSpecialization())
                local posData = resourceFrameAnchorPositions[specID] or resourceFrameAnchorPositions.default
                local point = posData.point or "TOP"
                local relativeFrame = PlayerFrame
                local relativePoint = posData.relativePoint or "BOTTOM"
                local xOffset = posData.xOffset or 30
                local yOffset = posData.yOffset or 25

                local _, _, scale = GetPlayerClassAndSpecPosition()

                if rogueCheck then
                    local maxCombos = UnitPowerMax("player", Enum.PowerType.ComboPoints)
                    if maxCombos == 5 then
                        xOffset, yOffset, scale = 31.5, 35, 0.95
                    elseif maxCombos == 6 then
                        xOffset, yOffset = 46, 37
                    end
                end

                if not db["moveResource" .. class] then
                    PlayerBottomManagedFrameContainer:ClearAllPoints()
                    PlayerBottomManagedFrameContainer:SetPoint(point, relativeFrame, relativePoint, xOffset, yOffset)
                end
                PlayerBottomManagedFrameContainer:SetScale(scale)
                PlayerBottomManagedFrameContainer:SetFrameStrata("HIGH")
            else
                PlayerBottomManagedFrameContainer.positionNeedsUpdate = true
                if not BBF.CombatWaiter then
                    BBF.CombatWaiter = CreateFrame("Frame")
                    BBF.CombatWaiter:SetScript("OnEvent", function(self)
                        if PlayerBottomManagedFrameContainer.positionNeedsUpdate then
                            PlayerBottomManagedFrameContainer.positionNeedsUpdate = false
                            UpdateResourcePosition()
                        end
                        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
                    end)
                end
                if not BBF.CombatWaiter:IsEventRegistered("PLAYER_REGEN_ENABLED") then
                    BBF.CombatWaiter:RegisterEvent("PLAYER_REGEN_ENABLED")
                end
            end
        end

        BBF.UpdateResourcePositionClassic = function()
            UpdateResourcePosition(class == "ROGUE")
        end

        local isRogue = class == "ROGUE"
        if isRogue then
            local specWatcher = CreateFrame("Frame")
            specWatcher:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
            specWatcher:RegisterEvent("TRAIT_CONFIG_UPDATED")
            specWatcher:RegisterUnitEvent("UNIT_MAXPOWER", "player")
            specWatcher:SetScript("OnEvent", function(self, event, unit, powerType)
                local rogueCombos = UnitPowerMax("player", Enum.PowerType.ComboPoints)
                UpdateResourcePosition(rogueCombos)
            end)
        end

        local function PlayerEliteFrame()
            local playerElite = frame.ClassicFrame.Texture
            local mode = BBF.GetPlayerEliteMode()
            local hideLvl, alwaysHideLvl = BBF.PlayerLevelHideFlags()

            -- Set Elite style according to value
            if mode <= 3 then
                SetPlayerFrameTexture(playerElite, PlayerEliteArt(mode, PlayerLevelHidden()))
                playerElite:SetDesaturated(mode ~= 3)
            elseif mode > 3 then
                SetPlayerFrameTexture(playerElite, noLvlTex, bigNoLvlTex, bigNoManaNoLvlTex)
                if playerElite.bbfClassicHD then
                    BBF.ApplyClassicHDColor(playerElite)
                else
                    playerElite:SetDesaturated(false)
                end
            else
                SetPlayerFrameTexture(frame.ClassicFrame.Texture, defaultTex, bigTex, bigNoManaTex)
                BBF.SetClassicFlash(frameContainer.FrameFlash, false, true)
                SetStatusGlowTexture(contentMain.StatusTexture, "Interface\\CharacterFrame\\UI-Player-Status", bigStatusTex, bigStatusNoManaTex)
            -- elseif mode == 4 then -- Only 3 available for classic
            --     db.playerEliteFrameMode = 3
            --     playerElite:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
            --     playerElite:SetDesaturated(false)
            end
        end

        local function ToggleNoLevelFrame(noLvl)
            if noLvl then
                SetPlayerFrameTexture(frame.ClassicFrame.Texture, noLvlTex, bigNoLvlTex, bigNoManaNoLvlTex)
                BBF.SetClassicFlash(frameContainer.FrameFlash, true, true)
                SetStatusGlowTexture(contentMain.StatusTexture, "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\classic-statustexture-nolevel.png", bigStatusNoLvlTex, bigStatusNoManaNoLvlTex)
            else
                SetPlayerFrameTexture(frame.ClassicFrame.Texture, defaultTex, bigTex, bigNoManaTex)
                BBF.SetClassicFlash(frameContainer.FrameFlash, false, true)
                SetStatusGlowTexture(contentMain.StatusTexture, "Interface\\CharacterFrame\\UI-Player-Status", bigStatusTex, bigStatusNoManaTex)
            end
        end

        local function AdjustStatusGlow()
            local big = BigPlayerHealthbar()
            contentMain.StatusTexture:SetSize(big and 190 or 191, 77)
            contentMain.StatusTexture:ClearAllPoints()
            contentMain.StatusTexture:SetPoint("TOPLEFT", 17, big and -17 or -15)
        end

        local function UpdatePlayerFrameTexture()
            if db.playerEliteFrame then
                ToggleNoLevelFrame(PlayerLevelHidden())
                PlayerEliteFrame()
            else
                if alwaysHideLvl then
                    ToggleNoLevelFrame(true)
                elseif hideLvl then
                    if UnitLevel("player") == GetMaxLevelForPlayerExpansion() then
                        ToggleNoLevelFrame(true)
                    else
                        ToggleNoLevelFrame(false)
                    end
                else
                    ToggleNoLevelFrame(false)
                end
            end
        end

        function BBF.UpdateClassicPlayerArt()
            UpdatePlayerFrameTexture()
            UpdateLevel()
            AdjustStatusGlow()
            AdjustStatusBarText()
            AdjustBackground()
        end

        local function ToPlayerArt()
            UpdateResourcePosition(isRogue)

            if not BigPlayerHealthbar() then
                SetXYPoint(hpContainer, nil, -44)
                BBF.SquishClassicPlayerHealth()
            end

            BBF.SizeClassicPlayerMana()

            frameContainer.FrameTexture:ClearAllPoints()
            frameContainer.FrameTexture:SetPoint("TOPLEFT", -19, 7)
            frameContainer.FrameTexture:SetAlpha(0)

            contentContext.RoleIcon:ClearAllPoints()
            contentContext.RoleIcon:SetPoint("TOPLEFT", 192, -34)

            contentContext.GroupIndicator:ClearAllPoints()
            contentContext.GroupIndicator:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -21, -33.5)
            PlayerFrameGroupIndicatorText:ClearAllPoints()
            PlayerFrameGroupIndicatorText:SetPoint("LEFT", contentContext.GroupIndicator.GroupIndicatorLeft, "LEFT", 20, 2.5)

            frame.ClassicFrame.Texture:SetSize(232, 100)
            UpdatePlayerFrameTexture()
            frame.ClassicFrame.Texture:SetTexCoord(1, 0.09375, 0, 0.78125)
            frame.ClassicFrame.Texture:ClearAllPoints()
            frame.ClassicFrame.Texture:SetPoint("TOPLEFT", -19, -8)
            frame.ClassicFrame.Texture:SetDrawLayer("BORDER")

            frameContainer.AlternatePowerFrameTexture:ClearAllPoints()
            frameContainer.AlternatePowerFrameTexture:SetPoint("TOPLEFT", -9, -8)
            frameContainer.AlternatePowerFrameTexture:SetAlpha(0)

            frameContainer.FrameFlash:SetParent(db.hideCombatGlow and BBF.hiddenFrame or frame)
            frameContainer.FrameFlash:SetSize(240.5, 93)
            --frameContainer.FrameFlash:SetTexture(flashTex)
            --frameContainer.FrameFlash:SetTexCoord(0.9453125, 0, 0, 0.181640625)
            frameContainer.FrameFlash:ClearAllPoints()
            frameContainer.FrameFlash:SetPoint("TOPLEFT", -4.5, -8)
            frameContainer.FrameFlash:SetDrawLayer("BACKGROUND")

            AdjustStatusGlow()
            contentMain.StatusTexture:SetTexCoord(0, 0.74609375, 0, 0.58125)
            contentMain.StatusTexture:SetBlendMode("ADD")

            AdjustStatusBarText()

            frameContainer.PlayerPortrait:ClearAllPoints()
            frameContainer.PlayerPortrait:SetPoint("TOPLEFT", 26, -23)
            frame.ClassicFrame.Texture:Show()

            AdjustBackground()
        end

        local function ToVehicleArt()
            frameContainer.VehicleFrameTexture:ClearAllPoints()
            frameContainer.VehicleFrameTexture:SetPoint("TOPLEFT", -3, 1)
            frameContainer.VehicleFrameTexture:SetAlpha(0)

            frame.ClassicFrame.Texture:SetSize(240, 120)
            BBF.SetClassicTexture(frame.ClassicFrame.Texture, "Interface\\Vehicles\\UI-Vehicle-Frame")
            frame.ClassicFrame.Texture:ClearAllPoints()
            frame.ClassicFrame.Texture:SetPoint("TOPLEFT", -3, 1)
            frame.ClassicFrame.Texture:SetTexCoord(0, 1, 0, 1)

            hpContainer.HealthBarMask:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Mask")
            hpContainer.HealthBarMask:ClearAllPoints()
            hpContainer.HealthBarMask:SetPoint("TOPLEFT", hpContainer, "TOPLEFT", -8, 6)
            hpContainer.HealthBarMask:SetSize(120, 32)
            hpContainer.HealthBarMask:Show()
            manaBar.ManaBarMask:ClearAllPoints()
            manaBar.ManaBarMask:SetPoint("TOPLEFT", -2, 2)
            manaBar.ManaBarMask:Show()

            frameContainer.FrameFlash:SetParent(frame)
            frameContainer.FrameFlash:SetSize(240.5, 93)
            frameContainer.FrameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Flash")
            frameContainer.FrameFlash:SetTexCoord(-0.02, 1, 0.07, 0.86)
            frameContainer.FrameFlash:ClearAllPoints()
            frameContainer.FrameFlash:SetPoint("TOPLEFT", -4.5, -4)
            frameContainer.FrameFlash:SetDrawLayer("BACKGROUND")

            contentContext.RoleIcon:ClearAllPoints()
            contentContext.RoleIcon:SetPoint("TOPLEFT", 186, -29)

            contentMain.StatusTexture:SetSize(242, 93)
            contentMain.StatusTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Flash")
            contentMain.StatusTexture:SetTexCoord(-0.02, 1, 0.07, 0.86)
            contentMain.StatusTexture:ClearAllPoints()
            contentMain.StatusTexture:SetPoint("TOPLEFT", -6, -4)
            contentMain.StatusTexture:SetDrawLayer("BACKGROUND")

            hpContainer.LeftText:SetParent(frame.ClassicFrame)
            hpContainer.LeftText:ClearAllPoints()
            hpContainer.LeftText:SetPoint("LEFT", frame.ClassicFrame.Texture, "LEFT", 101, 3)
            hpContainer.RightText:SetParent(frame.ClassicFrame)
            hpContainer.RightText:ClearAllPoints()
            hpContainer.RightText:SetPoint("RIGHT", frame.ClassicFrame.Texture, "RIGHT", -38, 3)
            hpContainer.HealthBarText:SetParent(frame.ClassicFrame)
            hpContainer.HealthBarText:ClearAllPoints()
            hpContainer.HealthBarText:SetPoint("CENTER", frame.ClassicFrame.Texture, "CENTER", 34, 3)

            SetManaTextParent(manaBar.LeftText, frame.ClassicFrame)
            manaBar.LeftText:ClearAllPoints()
            manaBar.LeftText:SetPoint("LEFT", frame.ClassicFrame.Texture, "LEFT", 101, -9)
            SetManaTextParent(manaBar.RightText, frame.ClassicFrame)
            manaBar.RightText:ClearAllPoints()
            manaBar.RightText:SetPoint("RIGHT", frame.ClassicFrame.Texture, "RIGHT", -7, -9)
            SetManaTextParent(manaBar.ManaBarText, frame.ClassicFrame)
            manaBar.ManaBarText:ClearAllPoints()
            manaBar.ManaBarText:SetPoint("CENTER", frame.ClassicFrame.Texture, "CENTER", 52, -9)

            frameContainer.PlayerPortrait:ClearAllPoints()
            frameContainer.PlayerPortrait:SetPoint("TOPLEFT", 23, -17)

            frame.ClassicFrame.Background:SetPoint("BOTTOMRIGHT", contentMain.HealthBarsContainer, "BOTTOMRIGHT", -7, -12)
        end

        local artQueued
        local function UpdateArt()
            if InCombatLockdown() then
                if not artQueued then
                    artQueued = true
                    BBF.RunAfterCombat(function()
                        artQueued = nil
                        UpdateArt()
                    end)
                end
                return
            end
            if PlayerFrame.state == "vehicle" then
                ToVehicleArt()
            else
                ToPlayerArt()
            end
        end

        hooksecurefunc("PlayerFrame_ToPlayerArt", UpdateArt)
        hooksecurefunc("PlayerFrame_ToVehicleArt", UpdateArt)
        UpdateArt()
        BBF.UnregisterPlayerFrameArtEvents()

        hooksecurefunc(TotemFrame, "Update", function(self)
            for child in self.totemPool:EnumerateActive() do
                child.Border:SetSize(39, 39)
                child.Border:SetTexture("Interface\\CharacterFrame\\TotemBorder")
                child.Border:ClearAllPoints()
                child.Border:SetPoint("CENTER")
            end
        end)

        TotemFrame:SetScale(0.85)
        hooksecurefunc(TotemFrame, "SetPoint", function(self)
            if self.changing then return end
            if classFrame and classFrame:IsShown() then return end
            self.changing = true
            local a, b, c, d, e = self:GetPoint()
            self:ClearAllPoints()
            self:SetPoint(a, b, c, d, e - 5)
            self.changing = false
        end)

        if db.classicFramesDesaturated or db.classColorFrameTexture then
            frame.ClassicFrame.Texture:SetDesaturated(true)
        end

    elseif frame == PetFrame then
        PetFrame:SetSize(128, 53)
        PetPortrait:ClearAllPoints()
        PetPortrait:SetPoint("TOPLEFT", 7, -6)

        PetFrameTexture:SetSize(128, 64)
        PetFrameTexture:ClearAllPoints()
        PetFrameTexture:SetPoint("TOPLEFT", 1, -1)

        PetFrameFlash:SetSize(128, 67)
        PetFrameFlash:SetTexture("Interface\\TargetingFrame\\UI-PartyFrame-Flash")
        PetFrameFlash:SetPoint("TOPLEFT", -3, 12)
        PetFrameFlash:SetTexCoord(0, 1, 1, 0)
        PetFrameFlash:SetDrawLayer("BACKGROUND")

        --PetFrameHealthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        BBF.ShowHealthGreen(PetFrameHealthBar)
        PetFrameHealthBar:ClearAllPoints()
        PetFrameHealthBar:SetPoint("TOPLEFT", 47, -22)
        PetFrameHealthBar:SetFrameLevel(1)
        PetFrameHealthBarMask:Hide()

        PetFrameManaBar:SetSize(71, 8)
        PetFrameManaBar:ClearAllPoints()
        PetFrameManaBar:SetPoint("TOPLEFT", 45, -29)
        PetFrameManaBar:SetFrameLevel(1)
        PetFrameManaBarMask:Hide()

        PetFrameHealthBarText:SetParent(PetFrame)
        PetFrameHealthBarTextLeft:SetParent(PetFrame)
        PetFrameHealthBarTextRight:SetParent(PetFrame)
        SetManaTextParent(PetFrameManaBarText, PetFrame)
        SetManaTextParent(PetFrameManaBarTextLeft, PetFrame)
        SetManaTextParent(PetFrameManaBarTextRight, PetFrame)

        PlaceClassicPetHealthText()
        PetFrameManaBarText:ClearAllPoints()
        PetFrameManaBarText:SetPoint("CENTER", PetFrame, "TOPLEFT", 82, -35)
        PetFrameManaBarTextLeft:ClearAllPoints()
        PetFrameManaBarTextLeft:SetPoint("LEFT", PetFrame, "TOPLEFT", 46, -35)
        PetFrameManaBarTextRight:ClearAllPoints()
        PetFrameManaBarTextRight:SetPoint("RIGHT", PetFrame, "TOPLEFT", 115, -35)
        UpdateClassicPetMana()

        PetFrameOverAbsorbGlow:SetParent(PetFrame)
        PetFrameOverAbsorbGlow:SetDrawLayer("ARTWORK", 7)

        PetAttackModeTexture:SetSize(76, 64)
        PetAttackModeTexture:SetTexture("Interface\\TargetingFrame\\UI-Player-AttackStatus")
        PetAttackModeTexture:SetTexCoord(0.703125, 1, 0, 1)
        PetAttackModeTexture:ClearAllPoints()
        PetAttackModeTexture:SetPoint("TOPLEFT", 6, -9)

        PetHitIndicator:ClearAllPoints()
        PetHitIndicator:SetPoint("CENTER", PetFrame, "TOPLEFT", 28, -27)

        if db.classicFramesDesaturated then
            PetFrameTexture:SetDesaturated(true)
        end
    end
end

local fancyManas = {
    ["INSANITY"] = true,
    ["MAELSTROM"] = true,
    ["FURY"] = true,
    ["LUNAR_POWER"] = true,
    ["SOUL_FRAGMENTS"] = true,                 -- alt mana, powerName (as opposed to powerType)
}

local function AdjustAlternateBars()
    local altBarWidth = 105
    AlternatePowerBar:SetSize(altBarWidth, 12)
    AlternatePowerBar:ClearAllPoints()
    AlternatePowerBar:SetPoint("BOTTOMLEFT", 95, 16)

    AlternatePowerBarText:SetPoint("CENTER", 2, -1)
    AlternatePowerBar.LeftText:SetPoint("LEFT", 0, -1)
    AlternatePowerBar.RightText:SetPoint("RIGHT", 0, -1)

    AlternatePowerBar.Background = AlternatePowerBar:CreateTexture(nil, "BACKGROUND")
    AlternatePowerBar.Background:SetAllPoints()
    AlternatePowerBar.Background:SetColorTexture(0, 0, 0, 0.5)

    AlternatePowerBar.Border = AlternatePowerBar:CreateTexture(nil, "OVERLAY")
    AlternatePowerBar.Border:SetSize(0, 16)
    AlternatePowerBar.Border:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
    AlternatePowerBar.Border:SetTexCoord(0.125, 0.250, 1, 0)
    AlternatePowerBar.Border:SetPoint("TOPLEFT", 4, 0)
    AlternatePowerBar.Border:SetPoint("TOPRIGHT", -4, 0)

    AlternatePowerBar.LeftBorder = AlternatePowerBar:CreateTexture(nil, "OVERLAY")
    AlternatePowerBar.LeftBorder:SetSize(16, 16)
    AlternatePowerBar.LeftBorder:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
    AlternatePowerBar.LeftBorder:SetTexCoord(0, 0.125, 1, 0)
    AlternatePowerBar.LeftBorder:SetPoint("RIGHT", AlternatePowerBar.Border, "LEFT")

    AlternatePowerBar.RightBorder = AlternatePowerBar:CreateTexture(nil, "OVERLAY")
    AlternatePowerBar.RightBorder:SetSize(16, 16)
    AlternatePowerBar.RightBorder:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
    AlternatePowerBar.RightBorder:SetTexCoord(0.125, 0, 1, 0)
    AlternatePowerBar.RightBorder:SetPoint("LEFT", AlternatePowerBar.Border, "RIGHT")

    if BBF.UnitFrameTextureOn("mana") then
        BBF.ApplyTextureChange("mana", AlternatePowerBar, nil, true, false, true)
        if AlternatePowerBar.PowerBarMask then
            AlternatePowerBar.PowerBarMask:Hide()
        end
    else
        --AdjustFramePoint(AlternatePowerBar.PowerBarMask, nil, -1)
        AlternatePowerBar.PowerBarMask:SetPoint("TOPLEFT", AlternatePowerBar, "TOPLEFT", -2, 3)
    end

    if class == "MONK" and MonkStaggerBar then
        MonkStaggerBar:SetSize(94, 12)
        MonkStaggerBar:ClearAllPoints()
        MonkStaggerBar:SetPoint("TOPLEFT", PlayerFrameAlternatePowerBarArea, "TOPLEFT", 101, -72)

        MonkStaggerBar.PowerBarMask:Hide()

        if MonkStaggerBarText then MonkStaggerBarText:SetPoint("CENTER", 1, -1) end
        MonkStaggerBar.LeftText:SetPoint("LEFT", 0, -1)
        MonkStaggerBar.RightText:SetPoint("RIGHT", 0, -1)

        MonkStaggerBar.Background = MonkStaggerBar:CreateTexture(nil, "BACKGROUND")
        MonkStaggerBar.Background:SetSize(128, 16)
        MonkStaggerBar.Background:SetTexture("Interface\\PlayerFrame\\MonkManaBar")
        MonkStaggerBar.Background:SetTexCoord(0, 1, 0.5, 1)
        MonkStaggerBar.Background:SetPoint("TOPLEFT", -17, 0)

        MonkStaggerBar.Border = MonkStaggerBar:CreateTexture(nil, "OVERLAY")
        MonkStaggerBar.Border:SetSize(128, 16)
        MonkStaggerBar.Border:SetTexture("Interface\\PlayerFrame\\MonkManaBar")
        MonkStaggerBar.Border:SetTexCoord(0, 1, 0, 0.5)
        MonkStaggerBar.Border:SetPoint("TOPLEFT", -17, 0)

        if BBF.UnitFrameTextureOn("mana") then
            BBF.ApplyTextureChange("mana", MonkStaggerBar, nil, true, false, true)
        end
    end

    -- if class == "DRUID" then
    --     C_Timer.After(1, function()
    --         BBF.CreateAltManaBar() --allow time for specID not to be nil cuz yea
    --     end)
    -- end


    if class == "EVOKER" and EvokerEbonMightBar then
        EvokerEbonMightBar:SetSize(altBarWidth, 12)
        EvokerEbonMightBar:ClearAllPoints()
        EvokerEbonMightBar:SetPoint("BOTTOMLEFT", 95, 17)

        if EvokerEbonMightBarText then EvokerEbonMightBarText:SetPoint("CENTER", 1, -1) end
        EvokerEbonMightBar.LeftText:SetPoint("LEFT", 0, -1)
        EvokerEbonMightBar.RightText:SetPoint("RIGHT", 0, -1)

        EvokerEbonMightBar.Background = EvokerEbonMightBar:CreateTexture(nil, "BACKGROUND")
        EvokerEbonMightBar.Background:SetAllPoints()
        EvokerEbonMightBar.Background:SetColorTexture(0, 0, 0, 0.5)

        EvokerEbonMightBar.Border = EvokerEbonMightBar:CreateTexture(nil, "OVERLAY")
        EvokerEbonMightBar.Border:SetSize(0, 16)
        EvokerEbonMightBar.Border:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
        EvokerEbonMightBar.Border:SetTexCoord(0.125, 0.250, 1, 0)
        EvokerEbonMightBar.Border:SetPoint("TOPLEFT", 4, 0)
        EvokerEbonMightBar.Border:SetPoint("TOPRIGHT", -4, 0)

        EvokerEbonMightBar.LeftBorder = EvokerEbonMightBar:CreateTexture(nil, "OVERLAY")
        EvokerEbonMightBar.LeftBorder:SetSize(16, 16)
        EvokerEbonMightBar.LeftBorder:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
        EvokerEbonMightBar.LeftBorder:SetTexCoord(0, 0.125, 1, 0)
        EvokerEbonMightBar.LeftBorder:SetPoint("RIGHT", EvokerEbonMightBar.Border, "LEFT")

        EvokerEbonMightBar.RightBorder = EvokerEbonMightBar:CreateTexture(nil, "OVERLAY")
        EvokerEbonMightBar.RightBorder:SetSize(16, 16)
        EvokerEbonMightBar.RightBorder:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
        EvokerEbonMightBar.RightBorder:SetTexCoord(0.125, 0, 1, 0)
        EvokerEbonMightBar.RightBorder:SetPoint("LEFT", EvokerEbonMightBar.Border, "RIGHT")

        if BBF.UnitFrameTextureOn("mana") then
            BBF.ApplyTextureChange("mana", EvokerEbonMightBar, nil, true, false, true)
        end
        if EvokerEbonMightBar.PowerBarMask then
            EvokerEbonMightBar.PowerBarMask:Hide()
        end
    end

    if class == "DEMONHUNTER" and DemonHunterSoulFragmentsBar then
        DemonHunterSoulFragmentsBar:SetSize(altBarWidth, 12)
        DemonHunterSoulFragmentsBar:ClearAllPoints()
        DemonHunterSoulFragmentsBar:SetPoint("BOTTOMLEFT", 95, 17)

        if DemonHunterSoulFragmentsBar.TextString then
            DemonHunterSoulFragmentsBar.TextString:SetPoint("CENTER", 1, -1)
        end
        if DemonHunterSoulFragmentsBar.LeftText then
            DemonHunterSoulFragmentsBar.LeftText:SetPoint("LEFT", 0, -1)
        end
        if DemonHunterSoulFragmentsBar.RightText then
            DemonHunterSoulFragmentsBar.RightText:SetPoint("RIGHT", 0, -1)
        end

        DemonHunterSoulFragmentsBar.Background = DemonHunterSoulFragmentsBar:CreateTexture(nil, "BACKGROUND")
        DemonHunterSoulFragmentsBar.Background:SetAllPoints()
        DemonHunterSoulFragmentsBar.Background:SetColorTexture(0, 0, 0, 0.5)

        DemonHunterSoulFragmentsBar.Border = DemonHunterSoulFragmentsBar:CreateTexture(nil, "OVERLAY")
        DemonHunterSoulFragmentsBar.Border:SetSize(0, 16)
        DemonHunterSoulFragmentsBar.Border:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
        DemonHunterSoulFragmentsBar.Border:SetTexCoord(0.125, 0.250, 1, 0)
        DemonHunterSoulFragmentsBar.Border:SetPoint("TOPLEFT", 4, 0)
        DemonHunterSoulFragmentsBar.Border:SetPoint("TOPRIGHT", -4, 0)

        DemonHunterSoulFragmentsBar.LeftBorder = DemonHunterSoulFragmentsBar:CreateTexture(nil, "OVERLAY")
        DemonHunterSoulFragmentsBar.LeftBorder:SetSize(16, 16)
        DemonHunterSoulFragmentsBar.LeftBorder:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
        DemonHunterSoulFragmentsBar.LeftBorder:SetTexCoord(0, 0.125, 1, 0)
        DemonHunterSoulFragmentsBar.LeftBorder:SetPoint("RIGHT", DemonHunterSoulFragmentsBar.Border, "LEFT")

        DemonHunterSoulFragmentsBar.RightBorder = DemonHunterSoulFragmentsBar:CreateTexture(nil, "OVERLAY")
        DemonHunterSoulFragmentsBar.RightBorder:SetSize(16, 16)
        DemonHunterSoulFragmentsBar.RightBorder:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
        DemonHunterSoulFragmentsBar.RightBorder:SetTexCoord(0.125, 0, 1, 0)
        DemonHunterSoulFragmentsBar.RightBorder:SetPoint("LEFT", DemonHunterSoulFragmentsBar.Border, "RIGHT")

        DemonHunterSoulFragmentsBar.CollapsingStarBackground:SetSize(altBarWidth, 12)
        DemonHunterSoulFragmentsBar.Glow:SetSize(altBarWidth, 12)
        DemonHunterSoulFragmentsBar.Ready:SetSize(altBarWidth, 12)
        DemonHunterSoulFragmentsBar.Deplete:SetSize(altBarWidth, 12)
        DemonHunterSoulFragmentsBar.CollapsingStarDepleteFin:SetSize(altBarWidth, 12)

        if BBF.UnitFrameTextureOn("mana") then
            BBF.ApplyTextureChange("mana", DemonHunterSoulFragmentsBar, nil, true, false, true)
        end
    end

    local classicFrameColorTargets = {
        AlternatePowerBar.Border,
        AlternatePowerBar.LeftBorder,
        AlternatePowerBar.RightBorder,
    }

    if class == "MONK" and MonkStaggerBar and MonkStaggerBar.Border then
        tinsert(classicFrameColorTargets, MonkStaggerBar.Border)
    end

    if class == "EVOKER" and EvokerEbonMightBar and EvokerEbonMightBar.Border then
        tinsert(classicFrameColorTargets, EvokerEbonMightBar.Border)
        tinsert(classicFrameColorTargets, EvokerEbonMightBar.LeftBorder)
        tinsert(classicFrameColorTargets, EvokerEbonMightBar.RightBorder)
    end

    local function GetFrameColor()
        local r, g, b = PlayerFrame.PlayerFrameContainer.FrameTexture:GetVertexColor()
        for _, frame in pairs(classicFrameColorTargets) do
            if frame then
                frame:SetVertexColor(r, g, b)
            end
        end
    end
    GetFrameColor()
    hooksecurefunc(PlayerFrame.PlayerFrameContainer.FrameTexture, "SetVertexColor", GetFrameColor)

    if BetterBlizzFramesDB.hideUnitFramePlayerSecondResource then
        if AlternatePowerBar then
            AlternatePowerBar:SetAlpha(0)
        end
        if MonkStaggerBar then
            MonkStaggerBar:SetAlpha(0)
        end
        if EvokerEbonMightBar then
            EvokerEbonMightBar:SetAlpha(0)
        end
        if DemonHunterSoulFragmentsBar then
            DemonHunterSoulFragmentsBar:SetAlpha(0)
        end
        BBF.changedSecondResourceAlpha = true
    end
end

local function SetClassicPartyManaShown(frame, shown)
    local manaBar = frame.ManaBar
    local alpha = shown and 1 or 0
    manaBar:SetAlpha(alpha)
    for _, key in ipairs({ "TextString", "LeftText", "RightText" }) do
        if manaBar[key] then manaBar[key]:SetAlpha(alpha) end
    end
end

local function ApplyClassicNormalParty(frame)
    local hpContainer = frame.HealthBarContainer
    local bars = BBF.PartyBars(frame)
    local noMana = ClassicPartyNoMana()
    local grow = noMana and 7 or 0
    bars:ClearAllPoints(hpContainer)
    bars:SetPoint(hpContainer, "TOPLEFT", frame, "TOPLEFT", 47, -20)
    bars:SetHeight(hpContainer, 10 + grow)
    bars:ClearAllPoints(hpContainer.HealthBar)
    bars:SetPoint(hpContainer.HealthBar, "TOPLEFT", hpContainer, "TOPLEFT", -2, -2)
    bars:SetHeight(hpContainer.HealthBar, 7 + grow)
    hpContainer.HealthBarMask:SetSize(128, noMana and 18 or 10)
    hpContainer.HealthBarMask:ClearAllPoints()
    hpContainer.HealthBarMask:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", -29, 2)
    local manaBar = frame.ManaBar
    bars:ClearAllPoints(manaBar)
    bars:SetPoint(manaBar, "TOPLEFT", frame, "TOPLEFT", 41, -28)
    SetClassicPartyManaShown(frame, not noMana)
    if frame.Background then
        frame.Background:ClearAllPoints()
        frame.Background:SetPoint("TOPLEFT", frame, "TOPLEFT", 44, -11)
        frame.Background:SetSize(70, 25)
    end
    local nameScale = 0.85
    frame.bbfPartyNameWidth = 91
    frame.bbfName:ClearAllPoints()
    frame.bbfName:SetPoint("BOTTOM", hpContainer, "TOP", -1 / nameScale, -3)
    frame.bbfName:SetWidth(91)
    local textScale = 0.72
    hpContainer.LeftText:ClearAllPoints()
    hpContainer.LeftText:SetPoint("LEFT", hpContainer, "LEFT", -1.5 / textScale, -2 + 1 / textScale)
    hpContainer.RightText:ClearAllPoints()
    hpContainer.RightText:SetPoint("RIGHT", hpContainer, "RIGHT", -2 / textScale, -2 + 1 / textScale)
    hpContainer.CenterText:ClearAllPoints()
    hpContainer.CenterText:SetPoint("CENTER", hpContainer, "CENTER", 2 - 2 / textScale, -2 + 1 / textScale)
    manaBar.LeftText:ClearAllPoints()
    manaBar.LeftText:SetPoint("LEFT", manaBar, "LEFT", 6 + 0.5 / textScale, 1 - 2 / textScale)
    manaBar.RightText:ClearAllPoints()
    manaBar.RightText:SetPoint("RIGHT", manaBar, "RIGHT", -1 / textScale, 1 - 2 / textScale)
    manaBar.TextString:ClearAllPoints()
    manaBar.TextString:SetPoint("CENTER", manaBar, "CENTER", 4.5, 1 - 2 / textScale)
end

local function ApplyClassicBigParty(frame)
    if not ClassicBigParty() then
        ApplyClassicNormalParty(frame)
        return
    end
    local hpContainer = frame.HealthBarContainer
    local bars = BBF.PartyBars(frame)
    bars:ClearAllPoints(hpContainer.HealthBar)
    bars:SetPoint(hpContainer.HealthBar, "TOPLEFT", hpContainer, "TOPLEFT", 0, 0)
    bars:ClearAllPoints(hpContainer)
    bars:SetPoint(hpContainer, "TOPLEFT", frame, "TOPLEFT", 45, -12)
    local noMana = ClassicPartyNoMana()
    local height = noMana and 24 or 17
    bars:SetHeight(hpContainer, height)
    bars:SetHeight(hpContainer.HealthBar, height)
    BBF.SetStretchedTotHealthMask(hpContainer, hpContainer.HealthBarMask, height)
    local manaBar = frame.ManaBar
    bars:ClearAllPoints(manaBar)
    bars:SetPoint(manaBar, "TOPLEFT", frame, "TOPLEFT", 41, -28)
    SetClassicPartyManaShown(frame, not noMana)
    if frame.Background then
        frame.Background:ClearAllPoints()
        frame.Background:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", 0, 0)
        if noMana then
            frame.Background:SetPoint("BOTTOMLEFT", hpContainer.HealthBar, "BOTTOMLEFT", 0, 0)
        else
            frame.Background:SetPoint("BOTTOMLEFT", manaBar, "BOTTOMLEFT", 4, 3)
        end
        frame.Background:SetWidth(69)
    end
    local textScale = 0.72
    hpContainer.LeftText:ClearAllPoints()
    hpContainer.LeftText:SetPoint("LEFT", hpContainer, "LEFT", 1 / textScale, -2 + 0.5 / textScale)
    hpContainer.RightText:ClearAllPoints()
    hpContainer.RightText:SetPoint("RIGHT", hpContainer, "RIGHT", -1 / textScale, -2 + 0.5 / textScale)
    hpContainer.CenterText:ClearAllPoints()
    hpContainer.CenterText:SetPoint("CENTER", hpContainer, "CENTER", 2, -2 + 0.5 / textScale)
    manaBar.LeftText:ClearAllPoints()
    manaBar.LeftText:SetPoint("LEFT", manaBar, "LEFT", 6 + 0.5 / 0.72, 1 - 2 / textScale)
    manaBar.RightText:ClearAllPoints()
    manaBar.RightText:SetPoint("RIGHT", manaBar, "RIGHT", -1 / textScale, 1 - 2 / textScale)
    manaBar.TextString:ClearAllPoints()
    manaBar.TextString:SetPoint("CENTER", manaBar, "CENTER", 4.5, 1 - 2 / textScale)
    local nameScale = 0.85
    frame.bbfPartyNameWidth = 94
    frame.bbfName:ClearAllPoints()
    frame.bbfName:SetPoint("BOTTOM", hpContainer, "TOP", -1 / nameScale, -3 + 5 / nameScale)
    frame.bbfName:SetWidth(94)
end

local function SetClassicPartyArt(frame)
    if ClassicBigParty() then
        BBF.SetClassicTexture(frame.Texture, ClassicPartyNoMana() and bigNoManaTex or bigTex)
    else
        BBF.SetClassicTexture(frame.Texture, ClassicPartyNoMana() and classicNoManaArt[defaultTex] or defaultTex)
    end
    frame.Texture:SetTexCoord(1, 0.09375, 0, 0.78125)
end

function BBF.RefreshClassicPartyMana()
    if not PartyFrame or not PartyFrame.PartyMemberFramePool then return end
    for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
        if frame.Background then
            SetClassicPartyArt(frame)
            ApplyClassicBigParty(frame)
        end
    end
end

local function MakeClassicPartyFrame()
    for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
        local overlay = frame.PartyMemberOverlay
        local hpContainer = frame.HealthBarContainer
        local manaBar = frame.ManaBar

        frame.Texture:SetSize(136, 59)
        SetClassicPartyArt(frame)
        frame.Texture:ClearAllPoints()
        frame.Texture:SetPoint("TOPLEFT", -18, 2)
        frame.Texture:SetDrawLayer("ARTWORK", 7)
        frame.Texture:SetParent(hpContainer)
        RoundToPixel(frame.Texture)
        RoundToPixel(frame.Flash)
        RoundToPixel(overlay.Status)

        frame.Flash:SetSize(143, 56)
        frame.Flash:SetTexture(flashTex)
        frame.Flash:SetTexCoord(0.9453125, 0, 0, 0.181640625)
        frame.Flash:ClearAllPoints()
        frame.Flash:SetPoint("TOPLEFT", -10.5, 2.5)

        overlay.Status:SetSize(143, 56)
        overlay.Status:SetTexture(flashTex)
        overlay.Status:SetTexCoord(0.9453125, 0, 0, 0.181640625)
        overlay.Status:ClearAllPoints()
        overlay.Status:SetPoint("TOPLEFT", -10.5, 2.5)


        overlay.LeaderIcon:SetSize(14,14)
        --AdjustFramePoint(overlay.LeaderIcon, nil, -6)
        overlay.LeaderIcon:SetPoint("BOTTOM", overlay, "TOP", -10, -6)
        local function PlaceRoleIcon()
            overlay.RoleIcon:ClearAllPoints()
            overlay.RoleIcon:SetPoint("BOTTOMLEFT", 2, 19)
        end
        PlaceRoleIcon()
        for _, method in ipairs({ "ToPlayerArt", "ToCharacterStyleArt", "ToVehicleArt" }) do
            if frame[method] then
                hooksecurefunc(frame, method, PlaceRoleIcon)
            end
        end
        overlay.PVPIcon:SetParent(BBF.hiddenFrame)

        --AdjustFramePoint(hpContainer.HealthBarMask, nil, -3)
        hpContainer.HealthBarMask:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", -29, 0)

        frame.Background = frame:CreateTexture(nil, "BACKGROUND")
        frame.Background:SetColorTexture(0,0,0,0.45)
        frame.Background:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", 0, 7)
        frame.Background:SetPoint("BOTTOMRIGHT", manaBar, "BOTTOMRIGHT", 1, 3)

        frame.bbfName:ClearAllPoints()
        frame.bbfName:SetPoint("BOTTOM", hpContainer, "TOP", 0, -3)
        frame.bbfName:SetWidth(69)
        frame.bbfName:SetScale(0.85)
        frame.bbfName:SetJustifyH("CENTER")

        hpContainer.LeftText:SetScale(0.72)
        hpContainer.RightText:SetScale(0.72)
        hpContainer.CenterText:SetScale(0.72)
        manaBar.TextString:SetScale(0.72)
        manaBar.LeftText:SetScale(0.72)
        manaBar.RightText:SetScale(0.72)

        hpContainer.CenterText:ClearAllPoints()
        hpContainer.CenterText:SetPoint("CENTER", hpContainer, "CENTER", 2, -2)
        hpContainer.LeftText:ClearAllPoints()
        hpContainer.LeftText:SetPoint("LEFT", hpContainer, "LEFT", 0, -2)
        hpContainer.RightText:ClearAllPoints()
        hpContainer.RightText:SetPoint("RIGHT", hpContainer, "RIGHT", 0, -2)
        manaBar.TextString:ClearAllPoints()
        manaBar.TextString:SetPoint("CENTER", manaBar, "CENTER", 4.5, 1)
        manaBar.LeftText:ClearAllPoints()
        manaBar.LeftText:SetPoint("LEFT", manaBar, "LEFT", 6 + 0.5 / 0.72, 1)
        manaBar.RightText:ClearAllPoints()
        manaBar.RightText:SetPoint("RIGHT", manaBar, "RIGHT", 0, 1)

        BBF.HookPartyArt(frame, function(self)
            SetClassicPartyArt(self)

            --AdjustFramePoint(frame.HealthBarContainer.HealthBarMask, nil, -3)
            hpContainer.HealthBarMask:SetPoint("TOPLEFT", frame.HealthBarContainer.HealthBar, "TOPLEFT", -29, 0)

            hpContainer.CenterText:ClearAllPoints()
            hpContainer.CenterText:SetPoint("CENTER", hpContainer, "CENTER", 2, -2)
            hpContainer.LeftText:ClearAllPoints()
            hpContainer.LeftText:SetPoint("LEFT", hpContainer, "LEFT", 0, -2)
            hpContainer.RightText:ClearAllPoints()
            hpContainer.RightText:SetPoint("RIGHT", hpContainer, "RIGHT", 0, -2)
            manaBar.TextString:ClearAllPoints()
            manaBar.TextString:SetPoint("CENTER", manaBar, "CENTER", 4.5, 1)
            manaBar.LeftText:ClearAllPoints()
            manaBar.LeftText:SetPoint("LEFT", manaBar, "LEFT", 6 + 0.5 / 0.72, 1)
            manaBar.RightText:ClearAllPoints()
            manaBar.RightText:SetPoint("RIGHT", manaBar, "RIGHT", 0, 1)

            frame.Flash:SetSize(143, 56)
            frame.Flash:SetTexture(flashTex)
            frame.Flash:SetTexCoord(0.9453125, 0, 0, 0.181640625)
            frame.Flash:ClearAllPoints()
            frame.Flash:SetPoint("TOPLEFT", -10.5, 2.5)

            overlay.Status:SetSize(143, 56)
            overlay.Status:SetTexture(flashTex)
            overlay.Status:SetTexCoord(0.9453125, 0, 0, 0.181640625)
            overlay.Status:ClearAllPoints()
            overlay.Status:SetPoint("TOPLEFT", -10.5, 2.5)
            ApplyClassicBigParty(self)
        end)
        ApplyClassicBigParty(frame)
    end
end

function BBF.ClassicHealthTextY(frame)
    if not BBF.IsBigHealthbarActive(frame) then return 2.9 end
    local hdOffset = BBF.ClassicHDTexturesActive() and 1 or 0
    local noManaOffset = BBF.GetHealthbarMirror(frame).layout.noMana and 3 or 0
    return (BetterBlizzFramesDB.biggerHealthbarsNameInside and 3.4 or 10.4) + hdOffset - noManaOffset
end

local function SortLocalizationChanges()
    -- On Chinese clients the positions change after BBF.ClassicFrames run.
    -- This would be better solved to run it later but at this point I don't want to mess with the order of things
    hooksecurefunc("LocalizeFrames", function()
        for _, f in ipairs({TargetFrame, FocusFrame}) do
            local contentMain = f.TargetFrameContent.TargetFrameContentMain
            local hpContainer = contentMain.HealthBarsContainer
            local manaBar = contentMain.ManaBar
            local tex = f.ClassicFrame.Texture

            SetClassicLevelPoint(contentMain.LevelText, BBF.ClassicHDTexturesActive() and -36 or -34.5, 25.5, 1, 1.5, 2, f, "BOTTOMRIGHT")

            hpContainer.HealthBarText:ClearAllPoints()
            hpContainer.HealthBarText:SetPoint("CENTER", tex, "LEFT", 66.5, BBF.ClassicHealthTextY(f))
            hpContainer.LeftText:ClearAllPoints()
            hpContainer.LeftText:SetPoint("LEFT", tex, "LEFT", 7.5, BBF.ClassicHealthTextY(f))
            hpContainer.RightText:ClearAllPoints()
            hpContainer.RightText:SetPoint("RIGHT", tex, "RIGHT", -109.5, BBF.ClassicHealthTextY(f))
            hpContainer.DeadText:ClearAllPoints()
            hpContainer.DeadText:SetPoint("CENTER", tex, "LEFT", 66, BBF.ClassicHealthTextY(f))
            hpContainer.UnconsciousText:ClearAllPoints()
            hpContainer.UnconsciousText:SetPoint("CENTER", tex, "LEFT", 66, BBF.ClassicHealthTextY(f))

            manaBar.ManaBarText:ClearAllPoints()
            manaBar.ManaBarText:SetPoint("CENTER", tex, "LEFT", 66.5, -8.5)
            manaBar.LeftText:ClearAllPoints()
            manaBar.LeftText:SetPoint("LEFT", tex, "LEFT", 7.5, -8.5)
            manaBar.RightText:ClearAllPoints()
            manaBar.RightText:SetPoint("RIGHT", tex, "RIGHT", -109.5, -8.5)
        end

        PlaceClassicPetHealthText()
        PetFrameManaBarText:ClearAllPoints()
        PetFrameManaBarText:SetPoint("CENTER", PetFrame, "TOPLEFT", 82, -35)
        PetFrameManaBarTextLeft:ClearAllPoints()
        PetFrameManaBarTextLeft:SetPoint("LEFT", PetFrame, "TOPLEFT", 46, -35)
        PetFrameManaBarTextRight:ClearAllPoints()
        PetFrameManaBarTextRight:SetPoint("RIGHT", PetFrame, "TOPLEFT", 115, -35)
    end)
end

local function RoundClassicArt()
    for _, frame in ipairs({ PlayerFrame, TargetFrame, FocusFrame }) do
        RoundToPixel(frame.ClassicFrame and frame.ClassicFrame.Texture)
        RoundToPixel(frame.totFrame and frame.totFrame.FrameTexture)
    end
    for _, frame in ipairs({ TargetFrame, FocusFrame }) do
        RoundToPixel(frame.TargetFrameContainer.Flash)
    end
    RoundToPixel(PlayerFrame.PlayerFrameContainer.FrameFlash)
    RoundToPixel(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture)
    RoundToPixel(PetFrameTexture)
    RoundToPixel(PetFrameFlash)
end

function BBF.ClassicFrames()
    if not BetterBlizzFramesDB.classicFrames then
        BBF.SetLevelRingsHidden(false)
        return
    end
    BBF.SetLevelRingsHidden(true)
    MakeClassicFrame(TargetFrame)
    MakeClassicFrame(FocusFrame)
    MakeClassicFrame(PlayerFrame)
    MakeClassicFrame(PetFrame)
    BBF.classicFramesBuilt = true
    RoundClassicArt()

    MakeClassicPartyFrame()
    BBF.UpdateClassicPvpCircles()

    AdjustAlternateBars()
    SortLocalizationChanges()
    C_Timer.After(1, function()
        if C_AddOns.IsAddOnLoaded("ClassicFrames") then
            C_AddOns.DisableAddOn("ClassicFrames")
        end
    end)
end