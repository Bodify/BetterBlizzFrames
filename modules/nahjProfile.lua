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
                ["r"] = 1,
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
                ["r"] = 1,
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
                ["r"] = 1,
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
                ["r"] = 1,
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
                ["r"] = 1,
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
                ["g"] = 1,
                ["b"] = 0,
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
                ["r"] = 1,
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
                ["r"] = 1,
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
                ["r"] = 1,
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
                ["r"] = 1,
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
                ["r"] = 1,
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
                ["r"] = 1,
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
                ["r"] = 1,
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
                ["r"] = 1,
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
                ["r"] = 1,
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
                ["r"] = 1,
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
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "Flagellation",
        ["comment"] = "",
    }, -- [17]
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
    db.combatIndicatorPlayersOnly = true
	db.focusBuffFilterWatchList = false
	db.frameAurasXPos = 0
	db.enablePlayerBuffFiltering = true
	db.racialIndicatorXPos = 11
	db.racialIndicatorOrc = true
	db.targetCastBarWidth = 150
	db.petCastBarWidth = 100
	db.darkModeUi = true
	db.focusToTScaleScale = 0.8999999761581421
	db.darkModeUiAura = true
	db.hideFocusLeaderIcon = true
	db.targetAbsorbIcon = false
	db.racialIndicatorUndead = false
	db.focusdeBuffFilterBlizzard = true
	db.focusCastbarIconXPos = 0
	db.petCastBarScale = 1
	db.focusdeBuffFilterWatchList = false
	db.hideFocusCombatGlow = false
	db.hidePlayerCornerIcon = true
	db.targetAbsorbAnchor = "TOP"
	db.playerCastBarTimerCentered = true
	db.targetStaticCastbar = false
	db.targetAndFocusAuraOffsetY = 0
	db.wasOnLoadingScreen = false
	db.hideChatButtons = true
	db.focusCastBarXPos = 0
	db.playerAuraImportantGlow = true
	db.playerCastBarIconScale = 1
	db.targetToTAnchor = "BOTTOMRIGHT"
	db.targetDetachCastbar = true
	db.focusAuraGlows = true
	db.focusCastBarIconScale = 1
	db.maxTargetDebuffs = 16
	db.enablePlayerDebuffFiltering = false
	db.focusdeBuffFilterLessMinite = false
	db.combatIndicatorScale = 1
	db.playerCastBarTimer = true
	db.targetAndFocusAuraScale = 1.149999976158142
	db.targetAndFocusHorizontalGap = 3
	db.printAuraSpellIds = false
	db.maxBuffFrameBuffs = 32
	db.playerAuraSpacingY = 0
	db.targetAbsorbXPos = 0
	db.partyCastBarScale = 1.099999904632568
	db.petCastBarWidthScale = 100
	db.targetBuffFilterBlacklist = true
	db.targetImportantAuraGlow = true
	db.targetToTYPos = 20
	db.targetAndFocusAurasPerRowScale = 5
	db.racialIndicatorXPosXPos = 11
	db.PlayerAuraFramedeBuffEnable = true
	db.targetdeBuffFilterBlizzard = true
	db.targetCastbarIconYPos = 0
	db.combatIndicatorShowSap = true
	db.combatIndicatorYPos = 0
	db.playerAuraGlows = true
	db.playerCastBarScale = 1.100000023841858
	db.focusToTAnchor = "BOTTOMRIGHT"
	db.focusCastBarYPos = 0
	db.showArenaID = true
	db.playerCastBarScaleScale = 1.079999923706055
	db.focusCastbarIconYPos = 0
	db.combatIndicatorXPos = 0
	db.targetAndFocusSmallAuraScale = 1
	db.targetAndFocusArenaNames = false
	db.targetEnlargeAura = true
	db.hidePrestigeBadge = true
	db.playerAbsorbAnchor = "TOP"
	db.frameAuraWidthGap = 0
	db.playerCastBarWidth = 208
	db.targetBuffFilterPurgeable = false
	db.darkModeColorScale = 0.199999988079071
	db.enlargedAuraSize = 1.5
	db.reopenOptions = false
	db.hasSaved = true
	db.targetCastBarXPosXPos = -254
	db.playerdeBuffFilterBlacklist = true
	db.hasCheckedUi = true
	db.playerAuraFiltering = true
	db.hideCombatGlow = true
	db.targetCombatIndicator = true
	db.hidePartyRoles = false
	db.focusToTYPos = 20
	db.hideFocusReputationColor = true
	db.targetPrestigeBadgeAlpha = true
	db.racialIndicatorScale = 1.649999976158142
	db.focusToTYPosScale = 20
	db.targetBuffFilterOnlyMe = false
	db.hideRaidFrameManager = true
	db.partyCastBarScaleScale = 1.099999904632568
	db.darkModeColor = 0.199999988079071
	db.targetBuffFilterWatchList = false
	db.playerCastBarTimerCenter = false
	db.targetCastBarIconScale = 1
	db.targetCastBarTimer = true
	db.partyCastBarTestMode = false
	db.targetdeBuffFilterAll = false
	db.focusBuffFilterBlacklist = true
	db.hidePvpTimerText = true
	db.racialIndicatorScaleScale = 1.649999976158142
	db.absorbIndicator = false
	db.removeRealmNames = true
	db.maxDebuffFrameDebuffs = 16
	db.showPartyCastBarIcon = true
	db.focusEnlargeAura = true
	db.targetdeBuffFilterWatchList = false
	db.focusBuffFilterOnlyMe = false
	db.targetToTYPosScale = 20
	db.petCastbar = false
	db.focusdeBuffFilterAll = false
	db.partyCastBarIconScale = 1
	db.playerCombatIndicator = false
	db.centerNames = false
	db.frameAuraRowAmount = 0
	db.hidePvpIcon = true
	db.targetdeBuffFilterBlacklist = true
	db.hideTargetToTDebuffs = true
	db.targetdeBuffPandemicGlow = true
	db.targetdeBuffEnable = true
	db.partyCastBarTimer = true
	db.targetToTXPosScale = 8
	db.targetAndFocusVerticalGap = 4
	db.auraTypeGap = 0
	db.targetToTCastbarAdjustment = true
	db.playerCastbarIconYPos = 0
	db.targetdeBuffFilterOnlyMe = false
	db.focusCastBarScale = 1.079999923706055
	db.partyCastBarYPos = 0
	db.focusToTScale = 0.8999999761581421
	db.targetdeBuffFilterLessMinite = false
	db.playerAbsorbXPosScale = -60
	db.focusPrestigeBadgeAlpha = true
	db.focusdeBuffFilterBlacklist = true
	db.hidePlayerRestAnimation = true
	db.hidePlayerRoleIcon = true
	db.playerBuffFilterBlacklist = true
	db.targetAbsorbYPos = 0
	db.focusAbsorbIcon = false
	db.playerAbsorbYPos = 0
	db.frameAuraHeightGap = 0
	db.targetRacialIndicator = true
	db.targetCastBarHeight = 10
	db.showPetCastBarTimer = false
	db.targetCastBarYPos = 273
	db.racialIndicator = true
	db.targetBuffFilterAll = true
	db.partyCastbars = false
	db.partyCastbarIconXPos = 0
	db.focusCastBarScaleScale = 1.079999923706055
	db.focusAbsorbAmount = true
	db.PlayerAuraFrameBuffEnable = true
	db.racialIndicatorYPosYPos = 2
	db.targetCastBarScaleScale = 1.200000047683716
	db.classColorFrames = true
	db.focusCastBarTimer = true
	db.hideArenaFrames = true
	db.targetCastBarXPos = -254
	db.PlayerAuraFrameBuffFilterWatchList = false
	db.showPetCastBarIcon = true
	db.targetAuraGlows = true
	db.hidePlayerRestGlow = true
	db.racialIndicatorYPos = 2
	db.partyCastbarIconYPos = 0
	db.targetCastbarIconXPos = 0
	db.absorbIndicatorScale = 1
	db.focusToTCastbarAdjustment = true
	db.targetBuffFilterLessMinite = false
	db.targetBuffPurgeGlow = true
	db.enlargedAuraSizeScale = 1.5
	db.targetToTScale = 0.8999999761581421
	db.focusBuffFilterPurgeable = false
	db.hideFocusToTDebuffs = true
	db.focusdeBuffEnable = true
	db.focusBuffFilterLessMinite = false
	db.focusToTXPosScale = 8
	db.targetCastBarYPosYPos = 273
	db.playerAuraSpacingX = 5
	db.focusImportantAuraGlow = true
	db.filterNpcArenaSpam = true
	db.targetAbsorbAmount = true
	db.playerReputationClassColor = true
	db.hidePartyNames = false
	db.partyCastBarXPos = 0
	db.showSpecName = true
	db.petCastBarYPos = 0
	db.playerAbsorbAmount = true
	db.focusCombatIndicator = true
	db.combatIndicatorShowSwords = true
	db.playerCastBarHeight = 11
	db.focusCastBarWidth = 150
	db.maxAurasOnFrame = 0
	db.showPartyCastbar = true
	db.focusBuffPurgeGlow = true
	db.partyCastBarHeight = 12
	db.partyCastBarWidth = 100
	db.targetAndFocusAurasPerRow = 5
	db.playerCastbarIconXPos = 0
	db.focusBuffFilterAll = true
	db.playerAbsorbIcon = false
	db.racialIndicatorHuman = false
	db.combatIndicator = true
	db.petCastBarXPos = 0
	db.targetAndFocusAuraOffsetX = 0
	db.darkModeCastbars = true
	db.darkModeActionBars = true
	db.playerFrameOCD = true
	db.partyArenaNames = false
	db.petCastBarTestMode = false
	db.hideGroupIndicator = true
	db.focusRacialIndicator = false
	db.hideLevelText = true
	db.playerAbsorbXPos = -60
	db.PlayerAuraFramedeBuffFilterWatchList = false
	db.maxTargetBuffs = 32
	db.racialIndicatorNelf = false
	db.focusCastBarHeight = 10
	db.focusdeBuffFilterOnlyMe = false
	db.focusBuffEnable = true
	db.combatIndicatorAnchor = "RIGHT"
	db.targetAndFocusAuraScaleScale = 1.149999976158142
	db.frameAuraScale = 0
	db.targetToTScaleScale = 0.8999999761581421
	db.absorbIndicatorTestMode = false
	db.showHiddenAurasIcon = true
	db.focusToTXPos = 8
	db.frameAurasYPos = 0
	db.hidePartyFrameTitle = true
	db.focusdeBuffPandemicGlow = true
	db.targetBuffEnable = true
	db.targetCastBarScale = 1.200000047683716
	db.shortArenaSpecName = true
	db.petCastBarHeight = 10
	db.petCastBarIconScale = 1
	db.targetToTXPos = 8
end