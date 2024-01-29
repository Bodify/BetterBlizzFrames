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
                ["a"] = 1,
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
                ["a"] = 1,
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
                ["a"] = 1,
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
                ["a"] = 1,
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
                ["a"] = 1,
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
                ["a"] = 1,
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0.07450980693101883,
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
                ["a"] = 1,
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
                ["a"] = 1,
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
                ["a"] = 1,
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
                ["a"] = 1,
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
                ["a"] = 1,
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
                ["a"] = 1,
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
                ["a"] = 1,
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
                ["a"] = 1,
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
                ["a"] = 1,
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
                ["a"] = 1,
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
                ["a"] = 1,
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
                ["a"] = 1,
                ["b"] = 0.03529411926865578,
                ["g"] = 0.007843137718737125,
                ["r"] = 1,
            },
        },
        ["name"] = "Defensive Stance",
        ["comment"] = "",
    }, -- [18]
    {
        ["flags"] = {
            ["important"] = true,
            ["enlarged"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["a"] = 1,
                ["b"] = 0.007843137718737125,
                ["g"] = 0,
                ["r"] = 1,
            },
        },
        ["name"] = "Adaptive Swarm",
        ["comment"] = "",
    }, -- [19]
    {
        ["flags"] = {
            ["important"] = true,
            ["enlarged"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 375986,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "",
    }, -- [20]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["comment"] = "",
        ["id"] = 343312,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [21]
    {
        ["flags"] = {
            ["important"] = true,
            ["enlarged"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Adrenaline Rush",
        ["comment"] = "",
    }, -- [22]
    {
        ["flags"] = {
            ["important"] = false,
            ["enlarged"] = true,
            ["pandemic"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Skull and Crossbones",
        ["comment"] = "",
    }, -- [23]
    {
        ["flags"] = {
            ["important"] = false,
            ["enlarged"] = true,
            ["pandemic"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Ruthless Precision",
        ["comment"] = "",
    }, -- [24]
    {
        ["flags"] = {
            ["important"] = false,
            ["enlarged"] = true,
            ["pandemic"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Grand Melee",
        ["comment"] = "",
    }, -- [25]
    {
        ["flags"] = {
            ["important"] = false,
            ["enlarged"] = true,
            ["pandemic"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Burried Treasure",
        ["comment"] = "",
    }, -- [26]
    {
        ["flags"] = {
            ["important"] = false,
            ["enlarged"] = true,
            ["pandemic"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Broadside",
        ["comment"] = "",
    }, -- [27]
    {
        ["flags"] = {
            ["important"] = false,
            ["enlarged"] = true,
            ["pandemic"] = true,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "True Bearing",
        ["comment"] = "",
    }, -- [28]
    {
        ["flags"] = {
            ["important"] = true,
            ["enlarged"] = true,
            ["pandemic"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 0,
            },
        },
        ["name"] = "Arcane Artillery",
        ["comment"] = "",
    }, -- [29]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["comment"] = "",
        ["id"] = 417282,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [30]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
            ["enlarged"] = true,
            ["compacted"] = false,
        },
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Heart of the Wild",
        ["comment"] = "",
    }, -- [31]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
            ["enlarged"] = true,
        },
        ["comment"] = "",
        ["id"] = 157228,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 0,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [32]
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
    db.targetCastBarIconScaleScale = 0.9800000190734863
	db.petCastBarWidth = 100
	db.hideFocusLeaderIcon = true
	db.targetToTYPos = 20
	db.focusCastbarIconXPos = 0
	db.petCastBarScale = 1
	db.playerAuraGlows = true
	db.hideFocusCombatGlow = false
	db.playerAbsorbAnchor = "TOP"
	db.targetCastBarXPosXPos = -20
	db.targetDetachCastbar = false
	db.focusAuraGlows = true
	db.focusCastBarIconScale = 1
	db.racialIndicatorYPos = 2
	db.playerCastBarTimer = true
	db.printAuraSpellIds = false
	db.maxBuffFrameBuffs = 32
	db.petCastBarWidthScale = 100
	db.targetBuffFilterBlacklist = true
	db.enablePlayerBuffFiltering = true
	db.playerdeBuffFilterBlacklist = true
	db.targetStaticCastbar = true
	db.targetAndFocusHorizontalGap = 3
	db.combatIndicatorShowSap = true
	db.playerCastBarScale = 1.100000023841858
	db.playerCastBarScaleScale = 1.079999923706055
	db.combatIndicatorXPos = 0
	db.targetAndFocusSmallAuraScale = 1
	db.targetToTXPosScale = 8
	db.playerCastBarWidth = 208
	db.auraTypeGap = 0
	db.reopenOptions = false
	db.hasSaved = true
	db.hasCheckedUi = true
	db.targetCombatIndicator = true
	db.hidePartyRoles = false
	db.hideFocusReputationColor = true
	db.petCastBarHeight = 10
	db.racialIndicatorScale = 1.490000009536743
	db.focusToTYPosScale = 20
	db.racialIndicatorYPosYPos = 2
	db.partyCastBarScaleScale = 1.099999904632568
	db.hidePlayerRestGlow = true
	db.racialIndicatorScaleScale = 1.490000009536743
	db.absorbIndicator = true
	db.maxDebuffFrameDebuffs = 16
	db.showPartyCastBarIcon = true
	db.absorbIndicatorScale = 1
	db.focusdeBuffFilterAll = false
	db.partyCastBarIconScale = 1
	db.overShieldsCompact = true
	db.frameAuraRowAmount = 0
	db.targetdeBuffEnable = true
	db.partyCastBarTimer = true
	db.overShieldsUnitFrames = true
	db.playerAbsorbAmount = false
	db.focusCombatIndicator = true
	db.showPetCastBarIcon = true
	db.partyCastBarYPos = 0
	db.targetdeBuffFilterLessMinite = false
	db.playerAbsorbXPosScale = -60
	db.focusBuffPurgeGlow = true
	db.focusdeBuffFilterBlacklist = true
	db.hidePlayerRoleIcon = true
	db.playerBuffFilterBlacklist = true
	db.targetAbsorbYPos = 0
	db.playerAbsorbYPos = 0
	db.targetRacialIndicator = true
	db.targetBuffFilterAll = true
	db.partyCastbarIconXPos = 0
	db.focusCastBarScaleScale = 1.25
	db.classColorFrames = true
	db.focusCastBarTimer = true
	db.hideArenaFrames = true
	db.filterGladiusSpam = true
	db.focusToTCastbarAdjustment = true
	db.targetCastBarHeight = 10
	db.enlargedAuraSizeScale = 1.5
	db.hideFocusToTDebuffs = true
	db.targetCastBarYPosYPos = 100
	db.focusImportantAuraGlow = true
	db.playerReputationClassColor = true
	db.hidePartyNames = false
	db.targetdeBuffFilterWatchList = false
	db.combatIndicatorShowSwords = true
	db.petCastBarXPos = 0
	db.playerCastbarIconXPos = 0
	db.targetToTScaleScale = 0.8999999761581421
	db.combatIndicator = true
	db.darkModeCastbars = true
	db.focusCastBarXPosXPos = -20
	db.playerFrameOCD = true
	db.partyArenaNames = false
	db.hideLevelText = true
	db.partyCastbarIconYPos = 0
	db.focusBuffEnable = true
	db.combatIndicatorAnchor = "RIGHT"
	db.targetAndFocusAuraScaleScale = 1.149999976158142
	db.petCastBarIconScale = 1
	db.targetAbsorbIcon = true
	db.frameAurasXPos = 0
	db.racialIndicatorXPos = 14
	db.racialIndicatorOrc = true
	db.targetCastBarWidth = 150
	db.darkModeUi = true
	db.targetAndFocusAuraScale = 1.149999976158142
	db.focusdeBuffFilterWatchList = false
	db.hidePlayerCornerIcon = true
	db.playerCastBarTimerCentered = true
	db.hideChatButtons = true
	db.focusCastBarXPos = -20
	db.playerAuraImportantGlow = true
	db.playerCastBarIconScale = 1
	db.targetToTXPos = 8
	db.focusdeBuffFilterLessMinite = false
	db.combatIndicatorScale = 1
	db.playerAuraSpacingY = 0
	db.filterEmoteSpam = true
	db.racialIndicatorXPosXPos = 14
	db.targetCastbarIconYPos = 0
	db.combatIndicatorYPos = 0
	db.focusToTAnchor = "BOTTOMRIGHT"
	db.focusCastBarYPos = 100
	db.partyCastBarScale = 1.099999904632568
	db.targetAndFocusArenaNames = false
	db.compactedAuraSize = 0.7
	db.targetToTAnchor = "BOTTOMRIGHT"
	db.frameAuraWidthGap = 0
	db.focusCastBarYPosYPos = 100
	db.targetBuffFilterPurgeable = false
	db.focusBuffFilterWatchList = false
	db.showPetCastBarTimer = false
	db.playerAuraFiltering = true
	db.filterNpcArenaSpam = true
	db.targetPrestigeBadgeAlpha = true
	db.targetBuffFilterOnlyMe = false
	db.hideRaidFrameManager = true
	db.targetCastBarScaleScale = 1.25
	db.darkModeColor = 0.199999988079071
	db.targetBuffFilterWatchList = false
	db.racialIndicatorUndead = false
	db.targetCastBarIconScale = 0.9800000190734863
	db.targetCastBarTimer = true
	db.focusBuffFilterBlacklist = true
	db.targetCastbarIconXPos = 0
	db.removeRealmNames = true
	db.focusToTXPos = 8
	db.focusBuffFilterOnlyMe = false
	db.petCastbar = false
	db.centerNames = false
	db.wasOnLoadingScreen = false
	db.hidePvpIcon = true
	db.hideTargetToTDebuffs = true
	db.playerAuraSpacingX = 5
	db.auraToggleIconTexture = 134430
	db.targetToTCastbarAdjustment = true
	db.overShields = true
	db.playerCastbarIconYPos = 0
	db.targetdeBuffFilterOnlyMe = false
	db.focusCastBarWidth = 150
	db.hidePlayerRestAnimation = true
	db.enlargedAuraSize = 1.5
	db.focusDetachCastbar = false
	db.targetAbsorbAmount = true
	db.targetAndFocusAuraOffsetX = 0
	db.targetAbsorbAnchor = "TOP"
	db.racialIndicator = true
	db.targetAndFocusAurasPerRowScale = 5
	db.partyCastbars = false
	db.playerCastBarTimerCenter = false
	db.focusRacialIndicator = false
	db.focusAbsorbAmount = true
	db.PlayerAuraFrameBuffEnable = true
	db.focusAbsorbIcon = true
	db.maxTargetDebuffs = 16
	db.PlayerAuraFramedeBuffFilterWatchList = false
	db.targetAbsorbXPos = 0
	db.maxTargetBuffs = 32
	db.partyCastBarTestMode = false
	db.targetCastBarXPos = -20
	db.PlayerAuraFrameBuffFilterWatchList = false
	db.focusdeBuffPandemicGlow = true
	db.enablePlayerDebuffFiltering = false
	db.focusdeBuffFilterOnlyMe = false
	db.playerCombatIndicator = false
	db.darkModeUiAura = true
	db.focusPrestigeBadgeAlpha = true
	db.racialIndicatorHuman = false
	db.focusEnlargeAura = true
	db.absorbIndicatorTestMode = false
	db.targetdeBuffFilterBlacklist = true
	db.targetEnlargeAura = true
	db.targetdeBuffPandemicGlow = true
	db.focusBuffFilterPurgeable = false
	db.hidePvpTimerText = true
	db.focusToTYPos = 20
	db.targetAndFocusAuraOffsetY = 0
	db.frameAuraHeightGap = 0
	db.focusToTScaleScale = 0.8999999761581421
	db.PlayerAuraFramedeBuffEnable = true
	db.racialIndicatorNelf = false
	db.filterTalentSpam = false
	db.hideCombatGlow = true
	db.frameAurasYPos = 0
	db.partyCastBarXPos = 0
	db.showSpecName = true
	db.partyCastBarWidth = 100
	db.targetAuraGlows = true
	db.targetToTScale = 0.8999999761581421
	db.focusCastBarHeight = 10
	db.playerCastBarHeight = 11
	db.auraWhitelistAlphaUpdated = true
	db.maxAurasOnFrame = 0
	db.showPartyCastbar = true
	db.darkModeColorScale = 0.199999988079071
	db.auraWhitelistColorsUpdated = true
	db.focusToTXPosScale = 8
	db.targetAndFocusAurasPerRow = 5
	db.targetAndFocusVerticalGap = 4
	db.targetBuffPurgeGlow = true
	db.playerAbsorbIcon = true
	db.focusBuffFilterAll = true
	db.showArenaID = true
	db.focusCastBarScale = 1.25
	db.shortArenaSpecName = true
	db.darkModeActionBars = true
	db.focusdeBuffEnable = true
	db.targetToTYPosScale = 20
	db.petCastBarTestMode = false
	db.hideGroupIndicator = true
	db.targetImportantAuraGlow = true
	db.focusToTScale = 0.8999999761581421
	db.playerAbsorbXPos = -60
	db.combatIndicatorPlayersOnly = true
	db.focusStaticCastbar = true
	db.focusCastbarIconYPos = 0
	db.partyCastBarHeight = 12
	db.focusdeBuffFilterBlizzard = true
	db.focusBuffFilterLessMinite = false
	db.overShieldsCompactUnitFrames = true
	db.petCastBarYPos = 0
	db.frameAuraScale = 0
	db.customLargeSmallAuraSorting = true
	db.showHiddenAurasIcon = true
	db.targetBuffFilterLessMinite = false
	db.displayDispelGlowAlways = false
	db.hidePartyFrameTitle = true
	db.targetdeBuffFilterAll = false
	db.targetBuffEnable = true
	db.targetCastBarScale = 1.25
	db.targetCastBarYPos = 100
	db.hideLossOfControlFrameBg = true
	db.targetdeBuffFilterBlizzard = true
	db.hidePrestigeBadge = true
end