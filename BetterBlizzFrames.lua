-- I did not know what a variable was when I started. I know a little bit more now and I am so sorry.

local addonVersion = "1.00" --too afraid to to touch for now
local addonUpdates = "1.5.2b"
local sendUpdate = false
BBF.VersionNumber = addonUpdates
BBF.variablesLoaded = false
local isAddonLoaded = C_AddOns.IsAddOnLoaded

local defaultSettings = {
    version = addonVersion,
    updates = "empty",
    wasOnLoadingScreen = true,
    -- General
    removeRealmNames = true,
    centerNames = false,
    darkModeUi = false,
    darkModeActionBars = true,
    darkModeUiAura = true,
    darkModeCastbars = true,
    darkModeColor = 0.20,
    darkModeVigor = true,
    hideGroupIndicator = false,
    hideFocusCombatGlow = false,
    hideDragonFlying = true,
    targetToTScale = 1,
    focusToTScale = 1,
    targetToTXPos = 0,
    targetToTYPos = 0,
    focusToTXPos = 0,
    focusToTYPos = 0,
    targetToTAnchor = "BOTTOMRIGHT",
    focusToTAnchor = "BOTTOMRIGHT",
    targetToTCastbarAdjustment = true,
    focusToTCastbarAdjustment = true,
    playerReputationClassColor = true,
    enlargedAuraSize = 1.4,
    compactedAuraSize = 0.7,
    onlyPandemicAuraMine = true,
    lossOfControlScale = 1,
    customCode = "-- Enter custom code below here. Feel free to contact me @bodify",

    --Target castbar
    playerCastbarIconXPos = 0,
    playerCastbarIconYPos = 0,
    targetCastbarIconXPos = 0,
    targetCastbarIconYPos = 0,
    focusCastbarIconXPos = 0,
    focusCastbarIconYPos = 0,
    targetEnlargeAuraEnemy = true,
    targetEnlargeAuraFriendly = true,
    focusEnlargeAuraEnemy = true,
    focusEnlargeAuraFriendly = true,

    -- Absorb Indicator
    absorbIndicatorScale = 1,
    playerAbsorbAnchor = "TOP",
    targetAbsorbAnchor = "TOP",
    playerAbsorbAmount = true,
    playerAbsorbIcon = true,
    targetAbsorbAmount = true,
    targetAbsorbIcon = true,
    focusAbsorbAmount = true,
    focusAbsorbIcon = true,
    playerAbsorbXPos = 0,
    playerAbsorbYPos = 0,
    targetAbsorbXPos = 0,
    targetAbsorbYPos = 0,
    --Combat Indicator
    combatIndicator = false,
    combatIndicatorShowSap = true,
    combatIndicatorShowSwords = true,
    playerCombatIndicator = true,
    targetCombatIndicator = true,
    focusCombatIndicator = true,
    combatIndicatorAnchor = "RIGHT",
    combatIndicatorScale = 1,
    combatIndicatorXPos = 0,
    combatIndicatorYPos = 0,
    --Race Indicator
    racialIndicator = false,
    targetRacialIndicator = true,
    focusRacialIndicator = true,
    racialIndicatorXPos = 0,
    racialIndicatorYPos = 0,
    racialIndicatorScale = 1,
    racialIndicatorOrc = true,
    racialIndicatorNelf = true,
    racialIndicatorHuman = true,
    racialIndicatorUndead = true,

    --Party castbars
    partyCastBarScale = 1,
    partyCastBarIconScale = 1,
    partyCastBarXPos = 0,
    partyCastBarYPos = 0,
    partyCastBarWidth = 100,
    partyCastBarHeight = 12,
    partyCastBarTimer = false,
    showPartyCastBarIcon = true,
    partyCastbarIconXPos = 0,
    partyCastbarIconYPos = 0,

    --Pet Castbar
    petCastbar = false,
    petCastBarScale = 1,
    petCastBarIconScale = 1,
    petCastBarXPos = 0,
    petCastBarYPos = 0,
    petCastBarWidth = 103,
    petCastBarHeight = 10,
    showPetCastBarIcon = true,
    showPetCastBarTimer = false,

    --Castbar edge highlight
    castBarInterruptHighlighterStartTime = 0.8,
    castBarInterruptHighlighterEndTime = 0.6,
    castBarInterruptHighlighterDontInterruptRGB = {1,0,0},
    castBarInterruptHighlighterInterruptRGB = {0,1,0},
    castBarNoInterruptColor = {1, 0, 0.01568627543747425},
    castBarDelayedInterruptColor = {1, 0.4784314036369324, 0.9568628072738647},

    --Target castbar
    targetCastBarScale = 1,
    targetCastBarIconScale = 1,
    targetCastBarXPos = 0,
    targetCastBarYPos = 0,
    targetCastBarWidth = 150,
    targetCastBarHeight = 10,
    targetCastBarTimer = false,
    targetToTAdjustmentOffsetY = 0,

    --Focus castbar
    focusCastBarScale = 1,
    focusCastBarIconScale = 1,
    focusCastBarXPos = 0,
    focusCastBarYPos = 0,
    focusCastBarWidth = 150,
    focusCastBarHeight = 10,
    focusCastBarTimer = false,
    focusToTAdjustmentOffsetY = 0,

    --Player castbar
    --playerCastBarScale = 1,
    playerCastBarIconScale = 1,
    playerCastBarWidth = 208,
    playerCastBarHeight = 11,
    playerCastBarTimer = false,
    playerCastBarTimerCenter = false,

    --Auras
    --playerAuraMaxBuffsPerRow = 10,
    --playerAuraMaxDebuffsPerRow = 10,
    auraStackSize = 1,
    auraToggleIconTexture = 134430,
    enablePlayerBuffFiltering = true,
    enablePlayerDebuffFiltering = false,
    playerdeBuffFilterBlacklist = true,
    playerBuffFilterBlacklist = true,
    focusdeBuffFilterBlacklist = true,
    focusBuffFilterBlacklist = true,
    targetdeBuffFilterBlacklist = true,
    targetBuffFilterBlacklist = true,
    auraTypeGap = 4,
    playerAuraSpacingX = 5,
    playerAuraSpacingY = 0,
    maxBuffFrameBuffs = 32,
    maxDebuffFrameDebuffs = 16,
    printAuraSpellIds = false,
    showHiddenAurasIcon = true,
    PlayerAuraFrameBuffEnable = true,
    PlayerAuraFramedeBuffEnable = true,
    targetAndFocusAuraScale = 1,
    targetAndFocusAuraOffsetX = 0,
    targetAndFocusAuraOffsetY = 0,
    targetAndFocusHorizontalGap = 3,
    targetAndFocusVerticalGap = 4,
    targetAndFocusAurasPerRow = 6,
    targetAndFocusSmallAuraScale = 1,
    purgeTextureColorRGB = {0, 0.92, 1, 0.85},
    hiddenIconDirection = "BOTTOM",

    frameAurasXPos = 0,
    frameAurasYPos = 0,
    frameAuraScale = 0,
    maxAurasOnFrame = 0,
    frameAuraRowAmount = 0,
    frameAuraWidthGap = 0,
    frameAuraHeightGap = 0,

    playerAuraFiltering = false,
    displayDispelGlowAlways = false,
    overShieldsUnitFrames = true,
    overShieldsCompactUnitFrames = true,

    --Target buffs
    maxTargetBuffs = 32,
    maxTargetDebuffs = 16,
    targetBuffEnable = true,
    targetBuffFilterAll = true,
    targetBuffFilterWatchList = false,
    targetBuffFilterLessMinite = false,
    targetBuffFilterPurgeable = false,
    targetImportantAuraGlow = true,
    targetBuffFilterOnlyMe = false,
    targetAuraGlows = true,
    targetEnlargeAura = true,
    targetCompactAura = true,

    --Target debuffs
    targetdeBuffEnable = true,
    targetdeBuffFilterAll = false,
    targetdeBuffFilterBlizzard = true,
    targetdeBuffFilterWatchList = false,
    targetdeBuffFilterLessMinite = false,
    targetdeBuffFilterOnlyMe = false,
    targetdeBuffPandemicGlow = true,

    --Focus buffs
    focusBuffEnable = true,
    focusBuffFilterAll = true,
    focusBuffFilterWatchList = false,
    focusBuffFilterLessMinite = false,
    focusBuffFilterOnlyMe = false,
    focusBuffFilterPurgeable = false,
    focusAuraGlows = true,
    focusEnlargeAura = true,
    focusCompactAura = true,
    focusImportantAuraGlow = true,

    --Focus debuffs
    focusdeBuffEnable = true,
    focusdeBuffFilterAll = false,
    focusdeBuffFilterBlizzard = true,
    focusdeBuffFilterWatchList = false,
    focusdeBuffFilterLessMinite = false,
    focusdeBuffFilterOnlyMe = false,
    focusdeBuffPandemicGlow = true,

    PlayerAuraFrameBuffFilterWatchList = false,
    PlayerAuraFramedeBuffFilterWatchList = false,

    -- Interrupt icon
    castBarInterruptIconScale = 1,
    castBarInterruptIconXPos = 0,
    castBarInterruptIconYPos = 0,
    castBarInterruptIconAnchor = "RIGHT",
    castBarInterruptIconTarget = true,
    castBarInterruptIconFocus = true,
    castBarInterruptIconShowActiveOnly = false,
    castBarInterruptIconDisplayCD = true,


    auraWhitelist = {
        {["name"] = "Example Aura :3 (delete me)"}
    },
    auraBlacklist = {
        {name = "Sign of the Skirmisher"},
        {name = "Sign of the Scourge"},
        {name = "Stormwind Champion"},
        {name = "Honorless Target"},
        {name = "Guild Champion"},
        {name = "Sign of Iron"},
        {id = 397734}, -- Word of a Worthy Ally
        {id = 186403}, -- Sign of Battle
        {id = 282559}, -- Enlisted
        {id = 32727}, -- Arena Preparation
        {id = 418563}, -- WoW's 19th Anniversary
        {id = 93805}, -- Ironforge Champion
        {id = 335148}, -- Sign of the Twisting Nether
        {id = 269083}, -- Enlisted 2
        {id = 394005}, -- A cultivators colors
    },
}

local function InitializeSavedVariables()
    if not BetterBlizzFramesDB then
        BetterBlizzFramesDB = {}
    end

    -- Check the stored version against the current addon version
    if not BetterBlizzFramesDB.version or BetterBlizzFramesDB.version ~= addonVersion then
        BetterBlizzFramesDB.version = addonVersion  -- Update the version number in the database
    end

    for key, defaultValue in pairs(defaultSettings) do
        if BetterBlizzFramesDB[key] == nil then
            BetterBlizzFramesDB[key] = defaultValue
        end
    end
end

local function FetchAndSaveValuesOnFirstLogin()
    -- Check if already saved the first login values
    if BetterBlizzFramesDB.hasSaved then
        return
    end



    local function GetUIInfo() --uhhh yeah idk, not needed delete eventually TODO:
        if BBF.variablesLoaded then
            local function ShownChecker()
                if PlayerFrame:IsShown() then
                    BetterBlizzFramesDB.hidePrestigeBadge = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigeBadge:GetAlpha() ~= 1 or not PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigeBadge:IsShown()
                    BetterBlizzFramesDB.targetPrestigeBadgeAlpha = TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge:GetAlpha() ~= 1 or not TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge:IsShown()
                    BetterBlizzFramesDB.focusPrestigeBadgeAlpha = FocusFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge:GetAlpha() ~= 1 or not FocusFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge:IsShown()

--[[
                    print(BetterBlizzFramesDB.hideTargetPrestigeBadge)
                    BetterBlizzFramesDB.hideTargetPrestigeBadge = not TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigePortrait:IsShown()
                    print(BetterBlizzFramesDB.hideTargetPrestigeBadge)              
]]
                    BetterBlizzFramesDB.hasCheckedUi = true
                else
                    C_Timer.After(0.1, function()
                        ShownChecker()
                    end)
                end
            end
            ShownChecker()
        else
            C_Timer.After(1, function()
                GetUIInfo()
            end)
        end
    end
    GetUIInfo()


    C_Timer.After(5, function()
        if not C_AddOns.IsAddOnLoaded("SkillCapped") then
        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rFrames first run. Thank you for trying out my AddOn. Access settings with /bbf")
        end
        BetterBlizzFramesDB.hasSaved = true
    end)
end

-- Define the popup window
StaticPopupDialogs["BetterBlizzFrames_COMBAT_WARNING"] = {
    text = "Leave combat to adjust this setting.",
    button1 = "Okay",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["BBF_NEW_VERSION"] = {
    text = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames " .. addonUpdates .. ":\n\n|A:Professions-Crafting-Orders-Icon:16:16|a Tweak:   \nI've adjusted the default target/focus castbar icon position for users of ClassicFrames to have it fit the old style castbars.\n\nYou might have to re-adjust the position slightly because of this.",
    button1 = "OK",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local function UpdateAuraColorsToGreen()
    if BetterBlizzFramesDB and BetterBlizzFramesDB["auraWhitelist"] then
        for _, entry in pairs(BetterBlizzFramesDB["auraWhitelist"]) do
            if entry.entryColors and entry.entryColors.text then
                -- Update to green color
                entry.entryColors.text.r = 0
                entry.entryColors.text.g = 1
                entry.entryColors.text.b = 0
            else
                entry.entryColors = { text = { r = 0, g = 1, b = 0 } }
            end
        end
    end
end

local function AddAlphaValuesToAuraColors()
    if BetterBlizzFramesDB and BetterBlizzFramesDB["auraWhitelist"] then
        for _, entry in pairs(BetterBlizzFramesDB["auraWhitelist"]) do
            if entry.entryColors and entry.entryColors.text then
                entry.entryColors.text.a = 1
            else
                entry.entryColors = { text = { r = 0, g = 1, b = 0, a = 1 } }
            end
        end
    end
end

local function ResetBBF()
    BetterBlizzFramesDB = {}
    ReloadUI()
end

StaticPopupDialogs["CONFIRM_RESET_BETTERBLIZZFRAMESDB"] = {
    text = "Are you sure you want to reset all BetterBlizzFrames settings?\nThis action cannot be undone.",
    button1 = "Confirm",
    button2 = "Cancel",
    OnAccept = function()
        ResetBBF()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Update message
local function SendUpdateMessage()
    if sendUpdate then
        if not BetterBlizzFramesDB.scStart then
            C_Timer.After(7, function()
                -- if BetterBlizzFramesDB.castBarInterruptIconEnabled then


                -- DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames news:")
                -- --DEFAULT_CHAT_FRAME:AddMessage("|A:QuestNormal:16:16|a New Stuff:")
                -- -- DEFAULT_CHAT_FRAME:AddMessage("   - Sort Purgeable Auras setting (Buffs & Debuffs).")

                -- DEFAULT_CHAT_FRAME:AddMessage("|A:Professions-Crafting-Orders-Icon:16:16|a Tweak:")
                -- DEFAULT_CHAT_FRAME:AddMessage("   - Reset castbar interrupt icon y offset to 0 due to default positional changes You may have to readjust to your liking.")

                -- end
                -- DEFAULT_CHAT_FRAME:AddMessage("   Reverted all name logic to 1.3.8b version. It's old and not optimal but at least it doesn't taint(?). I will never touch this again until TWW >_>")
                --DEFAULT_CHAT_FRAME:AddMessage("   A lot of behind the scenes Name logic changed. Should now work better and be happier with other addons.")
            end)
        else
            BetterBlizzFramesDB.scStart = nil
        end
    end
end

local function NewsUpdateMessage()
    DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames news:")
    DEFAULT_CHAT_FRAME:AddMessage("|A:QuestNormal:16:16|a New Settings:")
    DEFAULT_CHAT_FRAME:AddMessage("   - Castbar Edge Highlighter now uses seconds instead of percentages.")
    DEFAULT_CHAT_FRAME:AddMessage("   - Added \"Hide Player Guide Flag\" setting.")

    DEFAULT_CHAT_FRAME:AddMessage("|A:Professions-Crafting-Orders-Icon:16:16|a Bugfixes:")
    DEFAULT_CHAT_FRAME:AddMessage("   Fixed Overshields for PlayerFrame/TargetFrame etc after Blizzard change.")
    DEFAULT_CHAT_FRAME:AddMessage("   A lot of behind the scenes Name logic changed. Should now work better and be happier with other addons.")

    DEFAULT_CHAT_FRAME:AddMessage("|A:GarrisonTroops-Health:16:16|a Patreon link: www.patreon.com/bodydev")
end

-- added minimap hider and auto hider

local function CheckForUpdate()
    if not BetterBlizzFramesDB.hasSaved then
        BetterBlizzFramesDB.updates = addonUpdates
        return
    end
    if not BetterBlizzFramesDB.updates or BetterBlizzFramesDB.updates ~= addonUpdates then
        SendUpdateMessage()
        BetterBlizzFramesDB.updates = addonUpdates
    end
end

local function LoadingScreenDetector(_, event)
    --#######TEMPORARY BUGFIX FOR BLIZZARD#########
    local _, instanceType = GetInstanceInfo()
    local inArena = instanceType == "arena" or instanceType == "pvp"
    --#######TEMPORARY BUGFIX FOR BLIZZARD#########
    if event == "PLAYER_ENTERING_WORLD" or event == "LOADING_SCREEN_ENABLED" then
        BetterBlizzFramesDB.wasOnLoadingScreen = true

        BBF.MinimapHider()

        --#######TEMPORARY BUGFIX FOR BLIZZARD#########
        if BetterBlizzFramesDB.hideDragonFlying then
            if inArena and UIWidgetPowerBarContainerFrame then
                UIWidgetPowerBarContainerFrame:SetAlpha(0)
            else
                UIWidgetPowerBarContainerFrame:SetAlpha(1)
            end
        end
        --#######TEMPORARY BUGFIX FOR BLIZZARD#########
    elseif event == "LOADING_SCREEN_DISABLED" or event == "PLAYER_LEAVING_WORLD" then
        if BetterBlizzFramesDB.playerFrameOCD then
            BBF.FixStupidBlizzPTRShit()
        end

        BBF.MinimapHider()

        --#######TEMPORARY BUGFIX FOR BLIZZARD#########
        if BetterBlizzFramesDB.hideDragonFlying then
            if inArena and UIWidgetPowerBarContainerFrame then
                UIWidgetPowerBarContainerFrame:SetAlpha(0)
            else
                UIWidgetPowerBarContainerFrame:SetAlpha(1)
            end
        end
        --#######TEMPORARY BUGFIX FOR BLIZZARD#########
        C_Timer.After(2, function()
            BetterBlizzFramesDB.wasOnLoadingScreen = false
        end)
    end
end
local LoadingScreenFrame = CreateFrame("Frame")
LoadingScreenFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
LoadingScreenFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
LoadingScreenFrame:RegisterEvent("LOADING_SCREEN_ENABLED")
LoadingScreenFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
LoadingScreenFrame:SetScript("OnEvent", LoadingScreenDetector)

-- Function to check combat and show popup if in combat
function BBF.checkCombatAndWarn()
    if InCombatLockdown() then
        if not BetterBlizzFramesDB.wasOnLoadingScreen then
            if IsActiveBattlefieldArena() then
                return true -- Player is in combat but don't show the popup during arena
            else
                StaticPopup_Show("BetterBlizzFrames_COMBAT_WARNING")
                return true -- Player is in combat and outside of arena, so show the pop-up
            end
        end
    end
    return false -- Player is not in combat
end

function BBF.GetOppositeAnchor(anchor)
    local opposites = {
        LEFT = "RIGHT",
        RIGHT = "LEFT",
        TOP = "BOTTOM",
        BOTTOM = "TOP",
        TOPLEFT = "BOTTOMRIGHT",
        TOPRIGHT = "BOTTOMLEFT",
        BOTTOMLEFT = "TOPRIGHT",
        BOTTOMRIGHT = "TOPLEFT",
    }
    return opposites[anchor] or "CENTER"
end

--------------------------------------
-- CLICKTHROUGH
--------------------------------------
function BBF.ClickthroughFrames()
	if not InCombatLockdown() then
        local shift = IsShiftKeyDown()
        if BetterBlizzFramesDB.playerFrameClickthrough then
            PlayerFrame:SetMouseClickEnabled(shift)
        end

        if BetterBlizzFramesDB.targetFrameClickthrough then
            TargetFrame:SetMouseClickEnabled(shift)
            TargetFrameToT:SetMouseClickEnabled(false)
        end

        if BetterBlizzFramesDB.focusFrameClickthrough then
            FocusFrame:SetMouseClickEnabled(shift)
            FocusFrameToT:SetMouseClickEnabled(false)
        end
	end
end

-- Function to toggle test mode on and off
function BBF.ToggleLossOfControlTestMode()
    local LossOfControlFrameAlphaBg = BetterBlizzFramesDB.hideLossOfControlFrameBg and 0 or 0.6
    local LossOfControlFrameAlphaLines = BetterBlizzFramesDB.hideLossOfControlFrameLines and 0 or 1
    if not _G.FakeBBFLossOfControlFrame then  -- Changed to a global reference for wider access
        -- Main Frame Creation
        local frame = CreateFrame("Frame", "FakeBBFLossOfControlFrame", UIParent, "BackdropTemplate")
        frame:SetSize(256, 58)
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        frame:SetFrameStrata("MEDIUM")
        frame:SetToplevel(true)
        frame:Hide()

        -- Background Texture
        local blackBg = frame:CreateTexture(nil, "BACKGROUND")
        blackBg:SetTexture(LossOfControlFrame.blackBg:GetTexture())
        blackBg:SetPoint("BOTTOM", frame, "BOTTOM", 0, 0)
        blackBg:SetSize(256, 58)
        frame.blackBg = blackBg  -- Correctly scoped

        -- Red Lines Textures
        local redLineTop = frame:CreateTexture(nil, "BACKGROUND")
        redLineTop:SetTexture("Interface\\Cooldown\\Loc-RedLine")
        redLineTop:SetSize(236, 27)
        redLineTop:SetPoint("BOTTOM", frame, "TOP", 0, 0)
        frame.RedLineTop = redLineTop  -- Correctly scoped

        local redLineBottom = frame:CreateTexture(nil, "BACKGROUND")
        redLineBottom:SetTexture("Interface\\Cooldown\\Loc-RedLine")
        redLineBottom:SetSize(236, 27)
        redLineBottom:SetPoint("TOP", frame, "BOTTOM", 0, 0)
        redLineBottom:SetTexCoord(0, 1, 1, 0)
        frame.RedLineBottom = redLineBottom  -- Correctly scoped

        -- Icon Texture
        local icon = frame:CreateTexture(nil, "ARTWORK")
        icon:SetSize(48, 48)
        icon:SetPoint("LEFT", frame, "LEFT", 42, 0)
        icon:SetTexture(132298)
        frame.Icon = icon  -- Correctly scoped

        -- Ability Name FontString
        local abilityName = frame:CreateFontString(nil, "ARTWORK", "MovieSubtitleFont")
        abilityName:SetPoint("TOPLEFT", icon, "TOPRIGHT", 5, -4)
        abilityName:SetSize(0, 20)
        abilityName:SetText("Stunned")
        frame.AbilityName = abilityName  -- Correctly scoped

        -- Time Left Frame
        local timeLeft = CreateFrame("Frame", nil, frame)
        timeLeft:SetSize(200, 20)
        timeLeft:SetPoint("TOPLEFT", abilityName, "BOTTOMLEFT", 0, 0)
        frame.TimeLeft = timeLeft  -- Correctly scoped

        -- Number and Seconds Text
        local numberText = timeLeft:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
        numberText:SetText("5.5 seconds")
        numberText:SetPoint("LEFT", timeLeft, "LEFT", 0, -3)
        numberText:SetShadowOffset(2, -2)
        numberText:SetTextColor(1,1,1)
        timeLeft.NumberText = numberText  -- Correctly scoped

        -- Stop Testing Button
        local stopButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        stopButton:SetSize(120, 30)
        stopButton:SetPoint("BOTTOM", redLineBottom, "BOTTOM", 0, -35)
        stopButton:SetText("Stop Testing")
        stopButton:SetScript("OnClick", function() frame:Hide() end)
        frame.StopButton = stopButton  -- Correctly scoped

        _G.FakeBBFLossOfControlFrame = frame  -- Store the frame globally
    end
    FakeBBFLossOfControlFrame:SetScale(BetterBlizzFramesDB.lossOfControlScale)
    FakeBBFLossOfControlFrame.blackBg:SetAlpha(LossOfControlFrameAlphaBg)
    FakeBBFLossOfControlFrame.RedLineTop:SetAlpha(LossOfControlFrameAlphaLines)
    FakeBBFLossOfControlFrame.RedLineBottom:SetAlpha(LossOfControlFrameAlphaLines)
    FakeBBFLossOfControlFrame:Show()
end

function BBF.ChangeLossOfControlScale()
    LossOfControlFrame:SetScale(BetterBlizzFramesDB.lossOfControlScale)
end

--TODO Bodify, already in aura function, this is better perf tho so figure out how (debuffs only)
-- Make player debuffs clickthrough
local debuffFrame = DebuffFrame and DebuffFrame.AuraContainer
if debuffFrame then
    for i = 1, debuffFrame:GetNumChildren() do
        local child = select(i, debuffFrame:GetChildren())
        if child then
            child:SetMouseClickEnabled(false)
        end
    end
end

-- Warlock Alternate Power Clickthrough
local function DisableClickForWarlockPowerFrame()
    if WarlockPowerFrame then
        WarlockPowerFrame:SetMouseClickEnabled(false)
    end
end

-- Rogue Alternate Power Clickthrough
local function DisableClickForRogueComboPointBarFrame()
    if RogueComboPointBarFrame then
        RogueComboPointBarFrame:SetMouseClickEnabled(false)
    end
end

-- Druid Alternate Power Clickthrough
local function DisableClickForDruidComboPointBarFrame()
    if DruidComboPointBarFrame then
        DruidComboPointBarFrame:SetMouseClickEnabled(false)
    end
end

-- Paladin Alternate Power Clickthrough
local function DisableClickForPaladinPowerBarFrame()
    if PaladinPowerBarFrame then
        PaladinPowerBarFrame:SetMouseClickEnabled(false)
    end
end

-- Death Knight Alternate Power Clickthrough
local function DisableClickForRuneFrame()
    if RuneFrame then
        RuneFrame:SetMouseClickEnabled(false)
    end
end

-- Evoker Alternate Power Clickthrough
local function DisableClickForEssencePlayerFrame()
    if EssencePlayerFrame then
        EssencePlayerFrame:SetMouseClickEnabled(false)
    end
end

local function DisableClickForClassSpecificFrame()
    local _, playerClass = UnitClass("player")
    if playerClass == "WARLOCK" and WarlockPowerFrame then
        hooksecurefunc(WarlockPowerBar, "UpdatePower", DisableClickForWarlockPowerFrame)
    elseif playerClass == "ROGUE" and RogueComboPointBarFrame then
        hooksecurefunc(RogueComboPointBarFrame, "UpdatePower", DisableClickForRogueComboPointBarFrame)
    elseif playerClass == "DRUID" and DruidComboPointBarFrame then
        hooksecurefunc(DruidComboPointBarFrame, "UpdatePower", DisableClickForDruidComboPointBarFrame)
    elseif playerClass == "PALADIN" and PaladinPowerBarFrame then
        hooksecurefunc(PaladinPowerBar, "UpdatePower", DisableClickForPaladinPowerBarFrame)
    elseif playerClass == "DEATHKNIGHT" and RuneFrame then
        hooksecurefunc(RuneFrame, "UpdateRunes", DisableClickForRuneFrame)
    elseif playerClass == "EVOKER" and EssencePlayerFrame then
        hooksecurefunc(EssencePlayerFrame, "UpdatePower", DisableClickForEssencePlayerFrame)
    end
end

local ClickthroughFrames = CreateFrame("frame")
ClickthroughFrames:SetScript("OnEvent", function()
    BBF.ClickthroughFrames()
end)
ClickthroughFrames:RegisterEvent("MODIFIER_STATE_CHANGED")


--######################################################################
-- Move Resource Frames to TargetFrame
local hookedResourceFrames
local function RepositionIndividualComboPoints(comboPointFrame, positions, scale)
    local comboPoints = {}
    local allPointsReady = true

    for i = 1, comboPointFrame:GetNumChildren() do
        local child = select(i, comboPointFrame:GetChildren())
        if child ~= comboPointFrame.layoutParent and child:IsShown() then -- Check if child is shown
            local point, relativeTo, relativePoint, x, y = child:GetPoint()
            if x then
                table.insert(comboPoints, {child = child, x = x})
            else
                allPointsReady = false
                break -- Exit the loop early if any child is not ready
            end
        end
    end

    if allPointsReady and #comboPoints > 0 then
        -- Proceed if all combo points have valid 'x' values and there's at least one combo point
        table.sort(comboPoints, function(a, b) return a.x < b.x end)

        for i, info in ipairs(comboPoints) do
            if positions[i] then
                info.child:ClearAllPoints()
                info.child:SetPoint(unpack(positions[i]))
                info.child:SetScale(scale)
            end
        end
    else
        -- Retry after a short delay if not all combo points are ready
        C_Timer.After(0.5, function()
            RepositionIndividualComboPoints(comboPointFrame, positions, scale)
        end)
    end
end

-- Function to setup combo points for any class
local function SetupClassComboPoints(comboPointFrame, positions, expectedClass, scale, xPos, yPos, changeDrawLayer)
    -- Reposition individual combo points based on their x position

    if comboPointFrame and changeDrawLayer then
        local drawLayerOrder = {
            "BACKGROUND",
            "BORDER",
            "ARTWORK",
            "OVERLAY"
        }

        local function getNextDrawLayer(currentLayer)
            for i, layer in ipairs(drawLayerOrder) do
                if layer == currentLayer then
                    if i < #drawLayerOrder then
                        return drawLayerOrder[i + 1], false
                    else
                        return currentLayer, true  -- Indicate it's already the top layer
                    end
                end
            end
            return currentLayer  -- Default fallback, should not happen
        end

        for _, frameChild in pairs({comboPointFrame:GetChildren()}) do
            for i = 1, frameChild:GetNumRegions() do
                local region = select(i, frameChild:GetRegions())
                if region:IsObjectType("Texture") then
                    local currentLayer, sublevel = region:GetDrawLayer()
                    local nextLayer, isOverlay = getNextDrawLayer(currentLayer)
                    if isOverlay then
                        region:SetDrawLayer(currentLayer, sublevel + 1)
                    else
                        region:SetDrawLayer(nextLayer, sublevel + 1)
                    end
                end
            end
        end
    end

    -- Secure hook to reposition the combo point bar frame
    if not hookedResourceFrames then
        hooksecurefunc(comboPointFrame, "SetPoint", function(self)
            if self.changing or self:IsProtected() then return end
            self.changing = true

            comboPointFrame:SetParent(TargetFrame)
            comboPointFrame:SetFrameStrata(FocusFrameSpellBar:GetFrameStrata())
            comboPointFrame:SetFrameLevel(FocusFrameSpellBar:GetParent():GetFrameLevel() + 1)
            comboPointFrame:ClearAllPoints()
            comboPointFrame:SetPoint("LEFT", TargetFrame, "RIGHT", xPos, yPos or -2)
            comboPointFrame:SetMouseClickEnabled(false)
            RepositionIndividualComboPoints(comboPointFrame, positions, scale)

            self.changing = false
        end)
    end

    -- Initial repositioning of combo points
    RepositionIndividualComboPoints(comboPointFrame, positions, scale)
end

local roguePositions = {
    { "TOPLEFT", RogueComboPointBarFrame, "TOPLEFT", 2, 44 },
    { "TOPLEFT", RogueComboPointBarFrame, "TOPLEFT", 18.5, 30 },
    { "TOPLEFT", RogueComboPointBarFrame, "TOPLEFT", 29, 11.5 },
    { "TOPLEFT", RogueComboPointBarFrame, "TOPLEFT", 33, -11 },
    { "TOPLEFT", RogueComboPointBarFrame, "TOPLEFT", 29, -34 },
    { "TOPLEFT", RogueComboPointBarFrame, "TOPLEFT", 18.5, -53 },
    { "TOPLEFT", RogueComboPointBarFrame, "TOPLEFT", 2.5, -67.5 },
}

local druidPositions = {
    { "TOPLEFT", DruidComboPointBarFrame, "TOPLEFT", 34, 32.5 },
    { "TOPLEFT", DruidComboPointBarFrame, "TOPLEFT", 45, 14 },
    { "TOPLEFT", DruidComboPointBarFrame, "TOPLEFT", 48, -7 },
    { "TOPLEFT", DruidComboPointBarFrame, "TOPLEFT", 44, -28 },
    { "TOPLEFT", DruidComboPointBarFrame, "TOPLEFT", 33.5, -46.5 },
}

local warlockPositions = {
    { "TOPLEFT", WarlockPowerFrame, "TOPLEFT", 34, 32.5 },
    { "TOPLEFT", WarlockPowerFrame, "TOPLEFT", 45, 14 },
    { "TOPLEFT", WarlockPowerFrame, "TOPLEFT", 48, -7 },
    { "TOPLEFT", WarlockPowerFrame, "TOPLEFT", 44, -28 },
    { "TOPLEFT", WarlockPowerFrame, "TOPLEFT", 33.5, -46.5 },
}

local magePositions = {
    { "TOPLEFT", MageArcaneChargesFrame, "TOPLEFT", 39, 33 },
    { "TOPLEFT", MageArcaneChargesFrame, "TOPLEFT", 48, 11.5 },
    { "TOPLEFT", MageArcaneChargesFrame, "TOPLEFT", 48, -11.5 },
    { "TOPLEFT", MageArcaneChargesFrame, "TOPLEFT", 39, -33 },
}

local monkPositions = {
    { "TOPLEFT", MonkHarmonyBarFrame, "TOPLEFT", 15, 38.5 },
    { "TOPLEFT", MonkHarmonyBarFrame, "TOPLEFT", 27, 22 },
    { "TOPLEFT", MonkHarmonyBarFrame, "TOPLEFT", 33, 2 },
    { "TOPLEFT", MonkHarmonyBarFrame, "TOPLEFT", 33, -19 },
    { "TOPLEFT", MonkHarmonyBarFrame, "TOPLEFT", 27, -39 },
    { "TOPLEFT", MonkHarmonyBarFrame, "TOPLEFT", 15, -55 },
}

local evokerPositions = {
    { "TOPLEFT", EssencePlayerFrame, "TOPLEFT", 15, 33 },
    { "TOPLEFT", EssencePlayerFrame, "TOPLEFT", 27, 19 },
    { "TOPLEFT", EssencePlayerFrame, "TOPLEFT", 33, 1 },
    { "TOPLEFT", EssencePlayerFrame, "TOPLEFT", 33, -18 },
    { "TOPLEFT", EssencePlayerFrame, "TOPLEFT", 27, -36 },
    { "TOPLEFT", EssencePlayerFrame, "TOPLEFT", 15, -50 },
}


local function HookClassComboPoints()
    local db = BetterBlizzFramesDB
    if db.moveResourceToTarget then
        if db.moveResourceToTargetRogue then SetupClassComboPoints(RogueComboPointBarFrame, roguePositions, "ROGUE", 0.5, -44, -2, true) end
        if db.moveResourceToTargetDruid then SetupClassComboPoints(DruidComboPointBarFrame, druidPositions, "DRUID", 0.55, -53, -2, true) end
        if db.moveResourceToTargetWarlock then SetupClassComboPoints(WarlockPowerFrame, warlockPositions, "DRUID", 0.6, -56, 1) end
        if db.moveResourceToTargetMage then SetupClassComboPoints(MageArcaneChargesFrame, magePositions, "DRUID", 0.7, -61, -4) end
        if db.moveResourceToTargetMonk then SetupClassComboPoints(MonkHarmonyBarFrame, monkPositions, "ROGUE", 0.5, -44, -2, true) end
        if db.moveResourceToTargetEvoker then SetupClassComboPoints(EssencePlayerFrame, evokerPositions, "ROGUE", 0.65, -50, 0.5, true) end
        hookedResourceFrames = true
    end
end

--########################################################
local hiddenFrame = CreateFrame("Frame")
hiddenFrame:Hide()
function BBF.MiniFocusFrame()
    if BetterBlizzFramesDB.useMiniFocusFrame then
        FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer:SetAlpha(0)
        FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetAlpha(0)

        if not FocusFrame.TargetFrameContainer.compactRing then
            FocusFrame.TargetFrameContainer.compactRing = FocusFrame.TargetFrameContainer:CreateTexture(nil, "ARTWORK")
            FocusFrame.TargetFrameContainer.compactRing:SetAtlas("Map_Faction_Ring")
            FocusFrame.TargetFrameContainer.compactRing:SetSize(71,70)
            FocusFrame.TargetFrameContainer.compactRing:SetPoint("CENTER", FocusFrame.TargetFrameContainer.Portrait, "CENTER", 0, -2)

            if BetterBlizzFramesDB.darkModeUi then
                FocusFrame.TargetFrameContainer.compactRing:SetDesaturated(true)
                local color = BetterBlizzFramesDB.darkModeColor
                FocusFrame.TargetFrameContainer.compactRing:SetVertexColor(color,color,color)
            end
        end

        if FocusFrame.TargetFrameContainer.compactRing then
            FocusFrame.TargetFrameContainer.compactRing:Show()
        end

        FocusFrame.TargetFrameContainer.FrameTexture:Hide()
        --FocusFrame.TargetFrameContainer.Flash:Hide()
        FocusFrame.TargetFrameContainer.Flash:SetAlpha(0)
        FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetAlpha(0)

        --Name
        -- if not FocusFrame.TargetFrameContent.TargetFrameContentMain.cleanName then
        --     BBF.ChangeNameFocus()
        -- end
        local name = FocusFrame.TargetFrameContent.TargetFrameContentMain.cleanName or FocusFrame.TargetFrameContent.TargetFrameContentMain.Name
        name:SetScale(1.4)
        name:ClearAllPoints()
        name:SetJustifyH("RIGHT")
        name:SetPoint("RIGHT", FocusFrame.TargetFrameContainer.Portrait, "LEFT", -10, 10)

        FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:Hide()
        FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:ClearAllPoints()
        FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetPoint("CENTER", hiddenFrame, "CENTER")
    else
        --reset to original
        FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer:SetAlpha(1)
        FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetAlpha(1)

        if FocusFrame.TargetFrameContainer.compactRing then
            FocusFrame.TargetFrameContainer.compactRing:Hide()
        end

        FocusFrame.TargetFrameContainer.FrameTexture:Show()
        --FocusFrame.TargetFrameContainer.Flash:Hide()
        FocusFrame.TargetFrameContainer.Flash:SetAlpha(1)
        if not BetterBlizzFramesDB.hideFocusReputationColor then
            FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetAlpha(1)
        end

        if not BetterBlizzFramesDB.hideLevelText then
            FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:Show()
        end

        local ogName = FocusFrame.TargetFrameContent.TargetFrameContentMain.Name
        if FocusFrame.TargetFrameContent.TargetFrameContentMain.cleanName then
            FocusFrame.TargetFrameContent.TargetFrameContentMain.cleanName:SetScale(ogName:GetScale())
            FocusFrame.TargetFrameContent.TargetFrameContentMain.cleanName:ClearAllPoints()
            FocusFrame.TargetFrameContent.TargetFrameContentMain.cleanName:SetJustifyH(ogName:GetJustifyH())
            FocusFrame.TargetFrameContent.TargetFrameContentMain.cleanName:SetPoint(ogName:GetPoint())
        end
    end
end

function BBF.MoveToTFrames()
    if not InCombatLockdown() then
        TargetFrameToT:ClearAllPoints()
        if BetterBlizzFramesDB.targetToTAnchor == "BOTTOMRIGHT" then
            TargetFrameToT:SetPoint(BBF.GetOppositeAnchor(BetterBlizzFramesDB.targetToTAnchor),TargetFrame,BetterBlizzFramesDB.targetToTAnchor,BetterBlizzFramesDB.targetToTXPos - 108,BetterBlizzFramesDB.targetToTYPos + 10)
        else
            TargetFrameToT:SetPoint(BBF.GetOppositeAnchor(BetterBlizzFramesDB.targetToTAnchor),TargetFrame,BetterBlizzFramesDB.targetToTAnchor,BetterBlizzFramesDB.targetToTXPos,BetterBlizzFramesDB.targetToTYPos)
        end
        TargetFrameToT:SetScale(BetterBlizzFramesDB.targetToTScale)
        --TargetFrameToT.SetPoint=function()end

        FocusFrameToT:ClearAllPoints()
        if BetterBlizzFramesDB.focusToTAnchor == "BOTTOMRIGHT" then
            FocusFrameToT:SetPoint(BBF.GetOppositeAnchor(BetterBlizzFramesDB.focusToTAnchor),FocusFrame,BetterBlizzFramesDB.focusToTAnchor,BetterBlizzFramesDB.focusToTXPos - 108,BetterBlizzFramesDB.focusToTYPos + 10)
        else
            FocusFrameToT:SetPoint(BBF.GetOppositeAnchor(BetterBlizzFramesDB.focusToTAnchor),FocusFrame,BetterBlizzFramesDB.focusToTAnchor,BetterBlizzFramesDB.focusToTXPos,BetterBlizzFramesDB.focusToTYPos)
        end
        FocusFrameToT:SetScale(BetterBlizzFramesDB.focusToTScale)
        --FocusFrameToT.SetPoint=function()end
    else
        C_Timer.After(1.5, function()
            BBF.MoveToTFrames()
        end)
    end
end

function BBF.RecolorHpTempLoss()
    -- Player Frame
    local player = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
    local playerTexture = player.PlayerFrameTempMaxHealthLoss:GetStatusBarTexture()
    if playerTexture then
        playerTexture:SetVertexColor(1,0,0)
        playerTexture:SetBlendMode("ADD")
    end

    -- Hide the TempMaxHealthLossDivider if it exists
    if player.TempMaxHealthLossDivider then
        player.TempMaxHealthLossDivider:SetAlpha(0)
    end

    -- Target Frame
    local target = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.TempMaxHealthLoss.TempMaxHealthLossTexture
    if target then
        target:SetVertexColor(1,0,0)
        target:SetBlendMode("ADD")
    end

    -- Focus Frame
    local focus = FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.TempMaxHealthLoss.TempMaxHealthLossTexture
    if focus then
        focus:SetVertexColor(1,0,0)
        focus:SetBlendMode("ADD")
    end

    -- Party Frames
    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember"..i.."TempMaxHealthLoss"]
        if frame then
            local texture = frame:GetStatusBarTexture()
            if texture then
                texture:SetVertexColor(1,0,0,0.9)
                texture:SetBlendMode("ADD")
            end
        end
    end
end


function BBF.FixStupidBlizzPTRShit()
    if InCombatLockdown() then return end
    if isAddonLoaded("ClassicFrames") then return end
    -- For god knows what reason PTR has a gap between Portrait and PlayerFrame. This fixes it + other gaps.
    --PlayerFrame.PlayerFrameContainer.PlayerPortrait:SetScale(1.02)
    PlayerFrame.PlayerFrameContainer.PlayerPortrait:SetSize(64,64)
    PlayerFrame.PlayerFrameContainer.PlayerPortrait:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContainer, "TOPLEFT", 22, -17)
    PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:SetScale(1.01)
    PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:SetSize(63,63)
    PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContainer, "TOPLEFT", 22, -16)

    local a, b, c, d, e = TargetFrame.totFrame.Portrait:GetPoint()
    TargetFrame.totFrame.Portrait:SetPoint(a, b, c, 6, -4)
    TargetFrame.TargetFrameContainer.Portrait:SetSize(57,57)

    local a, b, c, d, e = FocusFrame.totFrame.Portrait:GetPoint()
    FocusFrame.totFrame.Portrait:SetPoint(a, b, c, 6, -4)

    for i = 1, 4 do
        local memberFrame = PartyFrame["MemberFrame" .. i]
        if memberFrame and memberFrame.Portrait then
            memberFrame.Portrait:SetHeight(38)
        end
    end

    --BBF.ShiftNamesCuzOCD()

    local a, b, c, d, e = TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:GetPoint()
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetPoint(a, b, c, d, -24)
    --TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetHeight()

    local a, b, c, d, e = FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:GetPoint()
    FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetPoint(a, b, c, d, -24)
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetHeight(20)

    FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetHeight(20)
    



    local a, b, c, d, e = TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:GetPoint()
    TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetPoint(a, b, c, d, -3)

    local a, b, c, d, e = FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:GetPoint()
    FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetPoint(a, b, c, d, -3)

    -- HealthBarColorActive
    if not BetterBlizzFramesDB.playerFrameOCDTextureBypass then
        local a, b, c, d, e = PlayerLevelText:GetPoint()
        PlayerLevelText:SetPoint(a,b,c,d,-28)
        PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBarMask:SetHeight(33)
        PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.ManaBarMask:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar, "TOPLEFT", -2, 3)
        PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.ManaBarMask:SetHeight(17)
        PlayerFrame.healthbar:SetHeight(21)
        PlayerFrame.manabar:SetSize(125,12)
        local p, r, rr, x, y = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.RightText:GetPoint()
        PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.RightText:SetPoint(p, r, rr, -3, 0)
        --local a, b, c, d, e = TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:GetPoint()
        --TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:ClearAllPoints()
        --TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:SetPoint(a, b, c, d, 99)
        TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBarMask:SetWidth(129)
        TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetSize(136, 10)
        TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.ManaBarMask:SetSize(258, 16)
        local point, relativeTo, relativePoint, xOffset, yOffset = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:GetPoint()
        TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetPoint(point, relativeTo, relativePoint, 9, yOffset)
        local p, r, rr, x, y = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:GetPoint()
        TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:SetPoint(p, r, rr, -14, y)
        local a, b, c, d, e = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.LeftText:GetPoint()
        TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.LeftText:SetPoint(a,b,c,3,e)
        FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBarMask:SetWidth(129)
        FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetSize(136, 10)
        FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.ManaBarMask:SetSize(258, 16)
        local point, relativeTo, relativePoint, xOffset, yOffset = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:GetPoint()
        FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetPoint(point, relativeTo, relativePoint, 9, yOffset)
        local p, r, rr, x, y = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:GetPoint()
        FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:SetPoint(p, r, rr, -14, y)
        local a, b, c, d, e = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.LeftText:GetPoint()
        FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.LeftText:SetPoint(a,b,c,3,e)


        local a, b, c, d, e = TargetFrame.totFrame.HealthBar:GetPoint()
        TargetFrame.totFrame.HealthBar:SetPoint(a,b,c,-5,-5)
        TargetFrame.totFrame.HealthBar:SetSize(71, 13)
        TargetFrame.totFrame.ManaBar:SetSize(76, 8)
        local a, b, c, d, e = TargetFrame.totFrame.ManaBar:GetPoint()
        TargetFrame.totFrame.ManaBar:SetPoint(a,b,c,-5,3)
        TargetFrame.totFrame.ManaBar.ManaBarMask:SetWidth(130)
        TargetFrame.totFrame.ManaBar.ManaBarMask:SetHeight(17)
        local a, b, c, d, e = FocusFrame.totFrame.HealthBar:GetPoint()
        FocusFrame.totFrame.HealthBar:SetPoint(a,b,c,-5,-5)
        FocusFrame.totFrame.HealthBar:SetSize(71, 13)
        FocusFrame.totFrame.ManaBar:SetSize(77, 10)
        local a, b, c, d, e = FocusFrame.totFrame.ManaBar:GetPoint()
        FocusFrame.totFrame.ManaBar:SetPoint(a,b,c,-5,3)
        FocusFrame.totFrame.ManaBar.ManaBarMask:SetWidth(130)
        FocusFrame.totFrame.ManaBar.ManaBarMask:SetHeight(17)


        -- local a,b,c,d,e = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.RightText:GetPoint()
        -- PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.RightText:ClearAllPoints()
        -- PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.RightText:SetPoint(a,b,c,d,e-0.2)

        -- local a,b,c,d,e = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.LeftText:GetPoint()
        -- PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.LeftText:ClearAllPoints()
        -- PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.LeftText:SetPoint(a,b,c,d,e-0.2)
    end
end

function BBF.NormalizeGameMenu(enabled)
    GameMenuFrame:ClearAllPoints()
    GameMenuFrame:SetPoint("CENTER", UIParent, "CENTER", 0, enabled and 65 or 0)
    GameMenuFrame:SetScale(enabled and 0.75 or 1)
end

local function TurnTestModesOff()
    BetterBlizzFramesDB.absorbIndicatorTestMode = false
    BetterBlizzFramesDB.partyCastBarTestMode = false
    BetterBlizzFramesDB.petCastBarTestMode = false
end

local function executeCustomCode()
    if BetterBlizzFramesDB and BetterBlizzFramesDB.customCode then
        local func, errorMsg = loadstring(BetterBlizzFramesDB.customCode)
        if func then
            func() -- Execute the custom code
        else
            print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: Error in custom code:", errorMsg)
        end
    end
end

-- Event registration for PLAYER_LOGIN
local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_LOGIN")
--Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:SetScript("OnEvent", function(...)

    executeCustomCode()
    CheckForUpdate()
    --BBF.HideFrames()
    DisableClickForClassSpecificFrame()
    BBF.MoveToTFrames()
    BBF.HookHealthbarColors()
    C_Timer.After(1, function()
       -- BBF.HideFrames()
        --BBF.MoveToTFrames()
       -- BBF.ChangeCastbarSizes()
        if BetterBlizzFramesDB.partyCastbars then
            --BBF.CreateCastbars()
        end
    end)

    local function LoginVariablesLoaded()
        if BBF.variablesLoaded then
            -- add setings updates
            BBF.UpdateUserTargetSettings()
            BBF.UpdateUserDarkModeSettings()
            BBF.ChatFilterCaller()
            HookClassComboPoints()



            BBF.HookOverShields()
            BBF.HookCastbarsForEvoker()
            BBF.StealthIndicator()
            BBF.CastbarRecolorWidgets()
            BBF.CastBarTimerCaller()
            BBF.ShowPlayerCastBarIcon()
            BBF.CombatIndicator(PlayerFrame, "player")
            if BetterBlizzFramesDB.hideArenaFrames then
                BBF.HideArenaFrames()
            end
            BBF.MoveToTFrames()
            BBF.UpdateUserAuraSettings()
            if BetterBlizzFramesDB.enableMasque then
                BBF.SetupMasqueSupport()
            end
            BBF.HookPlayerAndTargetAuras()


            local hidePartyName = BetterBlizzFramesDB.hidePartyNames
            local hidePartyRole = BetterBlizzFramesDB.hidePartyRoles
            if hidePartyName or hidePartyRole then
                BBF.OnUpdateName()
            end
            if BetterBlizzFramesDB.removeRealmNames or (BetterBlizzFramesDB.partyArenaNames or BetterBlizzFramesDB.targetAndFocusArenaNames) then
                BBF.AllCaller()
            end

            if BetterBlizzFramesDB.playerFrameOCD then
                BBF.FixStupidBlizzPTRShit()
            end

            if BetterBlizzFramesDB.recolorTempHpLoss then
                BBF.RecolorHpTempLoss()
            end
            C_Timer.After(1, function()
                if BetterBlizzFramesDB.playerFrameOCD then
                    BBF.FixStupidBlizzPTRShit()
                end
                if BetterBlizzFramesDB.classColorFrames then
                    BBF.UpdateFrames()
                end
                if BetterBlizzFramesDB.normalizeGameMenu then
                    BBF.NormalizeGameMenu(true)
                end
                if not isAddonLoaded("ClassicFrames") then
                    BBF.SetCenteredNamesCaller()
                end
                BBF.ToggleCastbarInterruptIcon()
                BBF.DarkmodeFrames()
                BBF.PlayerReputationColor()
                BBF.ClassColorPlayerName()
                BBF.CheckForAuraBorders()
                if BetterBlizzFramesDB.useMiniFocusFrame then
                    BBF.MiniFocusFrame()
                end
                BBF.UpdateCastbars()
                BBF.ChangeLossOfControlScale()
                BBF.ChangeCastbarSizes()
            end)
            BBF.HideFrames()
            if BetterBlizzFramesDB.partyCastbars then
                BBF.CreateCastbars()
            end

        else
            C_Timer.After(1, function()
                LoginVariablesLoaded()
            end)
        end
    end
    LoginVariablesLoaded()

    if BetterBlizzFramesDB.reopenOptions then
        --InterfaceOptionsFrame_OpenToCategory(BetterBlizzFrames)
        Settings.OpenToCategory(BBF.category.ID)
        BetterBlizzFramesDB.reopenOptions = false
    end
end)

-- Slash command
SLASH_BBF1 = "/BBF"
SlashCmdList["BBF"] = function(msg)
    local command, arg = msg:match("^(%S*)%s*(.-)$") -- Capture the command and argument
    command = string.lower(command or "")

    if command == "news" then
        NewsUpdateMessage()
    elseif command == "test" then
        --playerFrameTest()
    elseif command == "nahj" then
        StaticPopup_Show("BBF_CONFIRM_NAHJ_PROFILE")
    elseif command == "magnusz" then
        StaticPopup_Show("BBF_CONFIRM_MAGNUSZ_PROFILE")
    elseif command == "whitelist" or command == "wl" then
        if arg and arg ~= "" then
            if tonumber(arg) then
                -- The argument is a number, treat it as a spell ID
                local spellId = tonumber(arg)
                local spellName, _, icon = BBF.TWWGetSpellInfo(spellId)
                if spellName then
                    local iconString = "|T" .. icon .. ":16:16:0:0|t" -- Format the icon for display
                    BBF.auraWhitelist(spellId)
                    print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconString .. " " .. spellName .. " (" .. spellId .. ") was added to |cff00ff00whitelist|r.")
                else
                    print("Error: Invalid spell ID.")
                end
            else
                -- The argument is not a number, treat it as a spell name
                local spellName = arg
                BBF.auraWhitelist(spellName)
                print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. spellName .. " was added to |cff00ff00whitelist|r.")
            end
        else
            print("Usage: /bbf whitelist <spellID or auraName>")
        end
    elseif command == "blacklist" or command == "bl" then
        if arg and arg ~= "" then
            if tonumber(arg) then
                -- The argument is a number, treat it as a spell ID
                local spellId = tonumber(arg)
                local spellName, _, icon = BBF.TWWGetSpellInfo(spellId)
                if spellName then
                    local iconString = "|T" .. icon .. ":16:16:0:0|t" -- Format the icon for display
                    BBF.auraBlacklist(spellId)
                    print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconString .. " " .. spellName .. " (" .. spellId .. ") was added to |cffff0000blacklist|r.")
                else
                    print("Error: Invalid spell ID.")
                end
            else
                -- The argument is not a number, treat it as a spell name
                local spellName = arg
                BBF.auraBlacklist(spellName)
                print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. spellName .. " was added to |cffff0000blacklist|r.")
            end
        else
            print("Usage: /bbf blacklist <spellID or auraName>")
        end
    else
        -- InterfaceOptionsFrame_OpenToCategory(BetterBlizzFrames)
        Settings.OpenToCategory(BBF.category.ID)
    end
end

-- Event registration for PLAYER_LOGIN
local First = CreateFrame("Frame")
First:RegisterEvent("ADDON_LOADED")
First:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName then
        if addonName == "BetterBlizzFrames" then
            BetterBlizzFramesDB.wasOnLoadingScreen = true

            InitializeSavedVariables()
            FetchAndSaveValuesOnFirstLogin()
            TurnTestModesOff()
            --TurnOnEnabledFeaturesOnLogin()

            if not BetterBlizzFramesDB.auraWhitelistColorsUpdated then
                UpdateAuraColorsToGreen() --update default yellow text to green for new color feature
                BetterBlizzFramesDB.auraWhitelistColorsUpdated = true
            end

            if not BetterBlizzFramesDB.auraWhitelistAlphaUpdated then
                AddAlphaValuesToAuraColors()
                BetterBlizzFramesDB.auraWhitelistAlphaUpdated = true
            end

            if BetterBlizzFramesDB.hideLossOfControlFrameLines == nil then
                if BetterBlizzFramesDB.hideLossOfControlFrameBg then
                    BetterBlizzFramesDB.hideLossOfControlFrameLines = true
                end
            end

            BBF.InitializeOptions()
        end
    end
end)

local function OnVariablesLoaded(self, event)
    if event == "VARIABLES_LOADED" then
        BBF.variablesLoaded = true
    end
end

-- Register the frame to listen for the "VARIABLES_LOADED" event
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:SetScript("OnEvent", OnVariablesLoaded)

local PlayerEnteringWorld = CreateFrame("frame")
PlayerEnteringWorld:SetScript("OnEvent", function()
    BBF.DarkmodeFrames()
    BBF.ClickthroughFrames()
    BBF.CheckForAuraBorders()
    -- if not isAddonLoaded("ClassicFrames") and not isAddonLoaded("MyRolePlay") then
    --     --BBF.HookNameChangeStuff()
    --     TargetFrame:SetFrameStrata("MEDIUM")
    --     TargetFrameSpellBar:SetFrameStrata("HIGH")
    --     FocusFrameSpellBar:SetFrameStrata("HIGH")
    -- end
end)
PlayerEnteringWorld:RegisterEvent("PLAYER_ENTERING_WORLD")