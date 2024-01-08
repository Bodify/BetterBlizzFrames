-- Setting up the database
BetterBlizzFramesDB = BetterBlizzFramesDB or {}
BBF = BBF or {}

local nahjAuraBlacklist = {
    {
        ["name"] = "Sign of the Skirmisher",
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
    }, -- [1]
    {
        ["name"] = "Sign of the Scourge",
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
    }, -- [2]
    {
        ["name"] = "Stormwind Champion",
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
    }, -- [3]
    {
        ["name"] = "Honorless Target",
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
    }, -- [4]
    {
        ["name"] = "Guild Champion",
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
    }, -- [5]
    {
        ["name"] = "Sign of Iron",
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
    }, -- [6]
    {
        ["id"] = 397734,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
    }, -- [7]
    {
        ["id"] = 186403,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
    }, -- [8]
    {
        ["id"] = 282559,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
    }, -- [9]
    {
        ["id"] = 32727,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
    }, -- [10]
    {
        ["id"] = 418563,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
    }, -- [11]
    {
        ["id"] = 93805,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
    }, -- [12]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "Sign of the Legion",
        ["comment"] = "",
    }, -- [13]
    {
        ["flags"] = {
            ["important"] = false,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Sign of the Warrior",
        ["comment"] = "",
    }, -- [14]
    {
        ["flags"] = {
            ["important"] = false,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Sign of the emissary",
        ["comment"] = "",
    }, -- [15]
    {
        ["flags"] = {
            ["important"] = false,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Fashionable!",
        ["comment"] = "",
    }, -- [16]
    {
        ["flags"] = {
            ["important"] = false,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Soldier of the alliance",
        ["comment"] = "",
    }, -- [17]
}

local nahjAuraWhitelist = {
    {
        ["flags"] = {
            ["important"] = false,
            ["pandemic"] = true,
            ["enlarged"] = false,
        },
        ["comment"] = "",
        ["id"] = 703,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [1]
    {
        ["flags"] = {
            ["important"] = false,
            ["pandemic"] = true,
            ["enlarged"] = false,
        },
        ["comment"] = "",
        ["id"] = 1943,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [2]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["comment"] = "",
        ["id"] = 117906,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [3]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Shadow Dance",
        ["comment"] = "",
    }, -- [4]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Cenarion Ward",
        ["comment"] = "",
    }, -- [5]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 0.007843137718737125,
                ["b"] = 0.03529411926865578,
            },
        },
        ["name"] = "Lifebloom",
        ["comment"] = "",
    }, -- [6]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Battle Stance",
        ["comment"] = "",
    }, -- [7]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Intervene",
        ["comment"] = "",
    }, -- [8]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Blessing of Sanctuary",
        ["comment"] = "",
    }, -- [9]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Phase Shift",
        ["comment"] = "",
    }, -- [10]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Roar of Sacrifice",
        ["comment"] = "",
    }, -- [11]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Grounding Totem",
        ["comment"] = "",
    }, -- [12]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Blessing of Sacrifice",
        ["comment"] = "",
    }, -- [13]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Interlope",
        ["comment"] = "",
    }, -- [14]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Subterfuge",
        ["comment"] = "",
    }, -- [15]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Gladiator's Emblem",
        ["comment"] = "",
    }, -- [16]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Flagellation",
        ["comment"] = "",
    }, -- [17]
    {
        ["flags"] = {
            ["important"] = true,
            ["enlarged"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0.03529411926865578,
                ["g"] = 0.007843137718737125,
                ["r"] = 1,
            },
        },
        ["name"] = "Defensive Stance",
        ["comment"] = "",
    }, -- [18]
}

local function updateAuraList(nahjList, userList)
    for _, newEntry in ipairs(nahjList) do
        local isEntryExists = false
        local entryId = newEntry.id or ""
        local entryName = newEntry.name or ""

        for _, existingEntry in ipairs(userList) do
            local existingId = existingEntry.id or ""
            local existingName = existingEntry.name or ""

            if (entryId ~= "" and entryId == existingId) or (entryName ~= "" and entryName == existingName) then
                isEntryExists = true
                break
            end
        end

        if not isEntryExists then
            local entryToAdd = {}
            if entryName ~= "" then
                entryToAdd.name = entryName
            else
                entryToAdd.id = entryId
                entryToAdd.name = ""
            end
            entryToAdd.entryColors = newEntry.entryColors
            entryToAdd.flags = newEntry.flags
            entryToAdd.comment = newEntry.comment or ""
            table.insert(userList, entryToAdd)
        end
    end
end

function BBF.NahjProfile()
    updateAuraList(nahjAuraWhitelist, BetterBlizzFramesDB.auraWhitelist)
    updateAuraList(nahjAuraBlacklist, BetterBlizzFramesDB.auraBlacklist)

    local db = BetterBlizzFramesDB
    db.targetAndFocusAuraOffsetY = 0
	db.frameAurasXPos = 0
	db.maxTargetDebuffs = 16
	db.racialIndicatorOrc = true
	db.filterNpcArenaSpam = true
	db.targetCastBarWidth = 150
	db.petCastBarWidth = 100
	db.darkModeUi = true
	db.targetAndFocusAuraScale = 1.149999976158142
	db.showArenaID = true
	db.hideFocusLeaderIcon = true
	db.targetAbsorbIcon = false
	db.targetToTYPos = 20
	db.targetdeBuffFilterBlizzard = true
	db.petCastBarScale = 1
	db.focusdeBuffFilterWatchList = false
	db.focusCastbarIconYPos = 0
	db.hidePlayerCornerIcon = true
	db.playerAbsorbAnchor = "TOP"
	db.hidePartyRoles = false
	db.targetBuffFilterPurgeable = false
	db.racialIndicatorYPosYPos = 2
	db.playerCastBarTimerCentered = true
	db.racialIndicatorNelf = false
	db.racialIndicatorXPos = 11
	db.combatIndicatorPlayersOnly = true
	db.hideChatButtons = true
	db.focusCastBarXPos = 0
	db.playerAuraImportantGlow = true
	db.playerCastBarIconScale = 1
	db.focusToTScaleScale = 0.8999999761581421
	db.targetDetachCastbar = true
	db.focusAuraGlows = true
	db.focusCastBarIconScale = 1
	db.combatIndicatorScale = 1
	db.partyCastBarTestMode = false
	db.focusdeBuffFilterLessMinite = false
	db.racialIndicatorYPos = 2
	db.playerCastBarTimer = true
	db.focusdeBuffFilterBlizzard = true
	db.focusCastbarIconXPos = 0
	db.printAuraSpellIds = false
	db.maxBuffFrameBuffs = 32
	db.playerAuraSpacingY = 0
	db.playerAuraGlows = true
	db.hideFocusCombatGlow = false
	db.petCastBarWidthScale = 100
	db.targetBuffFilterBlacklist = true
	db.enablePlayerBuffFiltering = true
	db.targetAbsorbAnchor = "TOP"
	db.targetToTYPosScale = 20
	db.racialIndicatorXPosXPos = 11
	db.PlayerAuraFramedeBuffEnable = true
	db.partyCastbarIconYPos = 0
	db.targetCastbarIconYPos = 0
	db.combatIndicatorShowSap = true
	db.combatIndicatorYPos = 0
	db.targetAndFocusAuraOffsetX = 0
	db.playerCastBarScale = 1.100000023841858
	db.focusToTAnchor = "BOTTOMRIGHT"
	db.focusCastBarYPos = 0
	db.partyCastBarScale = 1.099999904632568
	db.playerCastBarScaleScale = 1.079999923706055
	db.shortArenaSpecName = true
	db.combatIndicatorXPos = 0
	db.targetAndFocusSmallAuraScale = 1
	db.targetAndFocusArenaNames = false
	db.targetEnlargeAura = true
	db.hidePrestigeBadge = true
	db.targetBuffFilterLessMinite = false
	db.frameAuraWidthGap = 0
	db.playerCastBarWidth = 208
	db.focusdeBuffFilterOnlyMe = false
	db.targetCastBarXPosXPos = -254
	db.focusBuffFilterWatchList = false
	db.auraWhitelistColorsUpdated = true
	db.playerCastBarTimerCenter = false
	db.targetImportantAuraGlow = true
	db.playerAuraFiltering = true
	db.targetStaticCastbar = false
	db.targetCombatIndicator = true
	db.targetCastBarYPos = 273
	db.racialIndicator = true
	db.hideFocusReputationColor = true
	db.darkModeUiAura = true
	db.racialIndicatorScale = 1.649999976158142
	db.focusToTYPosScale = 20
	db.targetBuffFilterOnlyMe = false
	db.hideRaidFrameManager = true
	db.partyCastBarScaleScale = 1.099999904632568
	db.darkModeColor = 0.199999988079071
	db.targetBuffFilterWatchList = false
	db.playerdeBuffFilterBlacklist = true
	db.targetCastBarIconScale = 1
	db.hidePlayerRestGlow = true
	db.focusdeBuffEnable = true
	db.targetAndFocusHorizontalGap = 3
	db.focusBuffFilterBlacklist = true
	db.partyCastBarWidth = 100
	db.racialIndicatorScaleScale = 1.649999976158142
	db.targetCastbarIconXPos = 0
	db.removeRealmNames = true
	db.maxDebuffFrameDebuffs = 16
	db.showPartyCastBarIcon = true
	db.absorbIndicatorScale = 1
	db.targetdeBuffFilterBlacklist = true
	db.focusBuffFilterOnlyMe = false
	db.targetAbsorbXPos = 0
	db.petCastbar = false
	db.focusdeBuffFilterAll = false
	db.targetToTXPosScale = 8
	db.partyCastBarIconScale = 1
	db.targetToTAnchor = "BOTTOMRIGHT"
	db.centerNames = false
	db.wasOnLoadingScreen = false
	db.hidePvpIcon = true
	db.auraTypeGap = 0
	db.hideTargetToTDebuffs = true
	db.targetdeBuffFilterAll = false
	db.playerAuraSpacingX = 5
	db.partyCastBarTimer = true
	db.auraToggleIconTexture = 134430
	db.reopenOptions = false
	db.targetToTXPos = 8
	db.targetToTCastbarAdjustment = true
	db.playerCastbarIconYPos = 0
	db.enlargedAuraSize = 1.5
	db.focusCombatIndicator = true
	db.focusCastBarWidth = 150
	db.partyCastBarYPos = 0
	db.showPetCastBarTimer = false
	db.targetdeBuffFilterLessMinite = false
	db.partyCastBarHeight = 12
	db.focusPrestigeBadgeAlpha = true
	db.focusdeBuffFilterBlacklist = true
	db.hidePlayerRestAnimation = true
	db.hidePlayerRoleIcon = true
	db.playerBuffFilterBlacklist = true
	db.targetAbsorbYPos = 0
	db.targetAbsorbAmount = true
	db.frameAurasYPos = 0
	db.petCastBarHeight = 10
	db.targetRacialIndicator = true
	db.targetCastBarScaleScale = 1.200000047683716
	db.racialIndicatorUndead = false
	db.focusBuffFilterAll = true
	db.targetCastBarTimer = true
	db.targetdeBuffFilterWatchList = false
	db.targetBuffFilterAll = true
	db.partyCastbars = false
	db.partyCastbarIconXPos = 0
	db.focusRacialIndicator = false
	db.focusAbsorbAmount = true
	db.PlayerAuraFrameBuffEnable = true
	db.absorbIndicator = false
	db.filterEmoteSpam = true
	db.classColorFrames = true
	db.focusCastBarTimer = true
	db.hideArenaFrames = true
	db.focusToTXPos = 8
	db.filterGladiusSpam = true
	db.PlayerAuraFrameBuffFilterWatchList = false
	db.focusToTScale = 0.8999999761581421
	db.enablePlayerDebuffFiltering = false
	db.frameAuraRowAmount = 0
	db.targetAndFocusAurasPerRowScale = 5
	db.targetdeBuffEnable = true
	db.targetAndFocusVerticalGap = 4
	db.frameAuraHeightGap = 0
	db.focusToTCastbarAdjustment = true
	db.targetCastBarHeight = 10
	db.playerAbsorbAmount = true
	db.enlargedAuraSizeScale = 1.5
	db.targetdeBuffFilterOnlyMe = false
	db.focusBuffFilterPurgeable = false
	db.hideFocusToTDebuffs = true
	db.focusCastBarScale = 1.079999923706055
	db.playerReputationClassColor = true
	db.playerAbsorbXPosScale = -60
	db.targetCastBarYPosYPos = 273
	db.focusBuffPurgeGlow = true
	db.focusImportantAuraGlow = true
	db.combatIndicator = true
	db.filterTalentSpam = false
	db.hideCombatGlow = true
	db.hidePartyNames = false
	db.partyCastBarXPos = 0
	db.showSpecName = true
	db.focusAbsorbIcon = false
	db.playerAbsorbYPos = 0
	db.targetCastBarXPos = -254
	db.focusCastBarHeight = 10
	db.playerCastBarHeight = 11
	db.hidePvpTimerText = true
	db.maxAurasOnFrame = 0
	db.showPartyCastbar = true
	db.focusToTXPosScale = 8
	db.targetBuffPurgeGlow = true
	db.focusToTYPos = 20
	db.targetAndFocusAurasPerRow = 5
	db.targetPrestigeBadgeAlpha = true
	db.racialIndicatorHuman = false
	db.focusBuffFilterLessMinite = false
	db.playerAbsorbIcon = false
	db.PlayerAuraFramedeBuffFilterWatchList = false
	db.petCastBarYPos = 0
	db.maxTargetBuffs = 32
	db.darkModeColorScale = 0.199999988079071
	db.darkModeCastbars = true
	db.darkModeActionBars = true
	db.playerFrameOCD = true
	db.partyArenaNames = false
	db.petCastBarTestMode = false
	db.hideGroupIndicator = true
	db.targetAuraGlows = true
	db.hideLevelText = true
	db.playerAbsorbXPos = -60
	db.targetToTScale = 0.8999999761581421
	db.absorbIndicatorTestMode = false
	db.focusEnlargeAura = true
	db.targetToTScaleScale = 0.8999999761581421
	db.playerCombatIndicator = false
	db.focusBuffEnable = true
	db.combatIndicatorAnchor = "RIGHT"
	db.targetAndFocusAuraScaleScale = 1.149999976158142
	db.frameAuraScale = 0
	db.targetdeBuffPandemicGlow = true
	db.showHiddenAurasIcon = true
	db.combatIndicatorShowSwords = true
	db.showPetCastBarIcon = true
	db.hidePartyFrameTitle = true
	db.focusdeBuffPandemicGlow = true
	db.targetBuffEnable = true
	db.targetCastBarScale = 1.200000047683716
	db.playerCastbarIconXPos = 0
	db.petCastBarXPos = 0
	db.petCastBarIconScale = 1
	db.focusCastBarScaleScale = 1.079999923706055
end