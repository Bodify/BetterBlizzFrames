-- Setting up the database
BetterBlizzFramesDB = BetterBlizzFramesDB or {}
BBF = BBF or {}

local nahjAuraBlacklist = {
    {
        ["name"] = "Sign of the Skirmisher",
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
    }, -- [1]
    {
        ["name"] = "Sign of the Scourge",
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
    }, -- [2]
    {
        ["name"] = "Stormwind Champion",
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
    }, -- [3]
    {
        ["name"] = "Honorless Target",
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
    }, -- [4]
    {
        ["name"] = "Guild Champion",
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
    }, -- [5]
    {
        ["name"] = "Sign of Iron",
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
    }, -- [6]
    {
        ["id"] = 397734,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
    }, -- [7]
    {
        ["id"] = 186403,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
    }, -- [8]
    {
        ["id"] = 282559,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
    }, -- [9]
    {
        ["id"] = 32727,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
    }, -- [10]
    {
        ["id"] = 418563,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
    }, -- [11]
    {
        ["id"] = 93805,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
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
        ["name"] = "264420 - Solider of the Alliance",
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
        ["name"] = "Orgrimmar Champion",
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
        ["name"] = "Encapsulated Destiny",
        ["comment"] = "",
    }, -- [15]
    {
        ["flags"] = {
            ["important"] = false,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 245686,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [16]
}



local nahjAuraWhitelist = {
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 248518,
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
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 7165,
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
        },
        ["comment"] = "",
        ["id"] = 378464,
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
        },
        ["comment"] = "",
        ["id"] = 48707,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [4]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 29166,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [5]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 115192,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [6]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 6940,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [7]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 199448,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [8]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 360827,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [9]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 204336,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [10]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 31224,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [11]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 278454,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [12]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 185313,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [13]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 410126,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [14]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 408557,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [15]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 323654,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [16]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 210256,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [17]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 3411,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [18]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 102351,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [19]
    {
        ["flags"] = {
            ["important"] = false,
            ["pandemic"] = true,
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
    }, -- [20]
    {
        ["flags"] = {
            ["important"] = false,
            ["pandemic"] = true,
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
    }, -- [21]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
        },
        ["comment"] = "",
        ["id"] = 345231,
        ["entryColors"] = {
            ["text"] = {
                ["r"] = 1,
                ["g"] = 1,
                ["b"] = 0,
            },
        },
        ["name"] = "",
    }, -- [22]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 117906,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [23]
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
	db.petCastBarHeightScale = 10
	db.frameAurasXPos = 0
	db.maxTargetDebuffs = 16
	db.targetCastBarWidth = 150
	db.combatIndicatorArenaOnly = false
	db.petCastBarWidth = 100
	db.darkModeUi = true
	db.targetAndFocusAuraScale = 1.149999976158142
	db.hideFocusLeaderIcon = true
	db.focusdeBuffFilterBlizzard = true
	db.targetdeBuffFilterBlizzard = true
	db.petCastBarScale = 1
	db.focusdeBuffFilterWatchList = false
	db.hideFocusCombatGlow = false
	db.hidePlayerCornerIcon = true
	db.playerAbsorbAnchor = "TOP"
	db.playerCastBarTimerCentered = true
	db.hideChatButtons = true
	db.focusCastBarXPos = 0
	db.playerAuraImportantGlow = true
	db.playerCastBarIconScale = 1
	db.focusCastBarIconScale = 1
	db.colorPetAfterOwner = false
	db.focusdeBuffFilterLessMinite = false
	db.combatIndicatorScale = 1
	db.playerCastBarTimer = true
	db.printAuraSpellIds = false
	db.maxBuffFrameBuffs = 32
	db.petCastBarWidthScale = 100
	db.targetImportantAuraGlow = true
	db.targetAndFocusAurasPerRowScale = 5
	db.focusdeBuffEnable = true
	db.PlayerAuraFramedeBuffEnable = true
	db.combatIndicatorShowSap = true
	db.combatIndicatorYPos = 0
	db.playerCastBarScale = 1.069999933242798
	db.focusToTAnchor = "BOTTOMRIGHT"
	db.focusCastBarYPos = 0
	db.partyCastBarScale = 1.099999904632568
	db.playerCastBarScaleScale = 1.069999933242798
	db.playerAuraSpacingXScale = 5
	db.combatIndicatorXPos = 0
	db.targetAndFocusArenaNames = true
	db.hideTargetLeaderIcon = false
	db.targetToTAnchor = "BOTTOMRIGHT"
	db.frameAuraWidthGap = 0
	db.playerCastBarWidth = 208
	db.focusdeBuffFilterOnlyMe = false
	db.focusBuffFilterWatchList = false
	db.hasSaved = true
	db.showArenaID = true
	db.showPetCastBarTimer = false
	db.playerAuraFiltering = true
	db.targetCombatIndicator = true
	db.targetCastBarYPos = 0
	db.focusToTYPos = 20
	db.hideFocusReputationColor = true
	db.petCastBarHeight = 10
	db.focusToTYPosScale = 20
	db.targetBuffFilterOnlyMe = false
	db.hideRaidFrameManager = true
	db.targetCastBarScaleScale = 1.069999933242798
	db.darkModeColor = 0.30
	db.targetBuffFilterWatchList = false
	db.targetCastBarIconScale = 1
	db.targetCastBarTimer = true
	db.hidePvpTimerText = true
	db.petDetachCastbar = false
	db.petCastBarTimer = true
	db.removeRealmNames = true
	db.maxDebuffFrameDebuffs = 16
	db.showPartyCastBarIcon = true
	db.focusToTXPos = 8
	db.focusBuffFilterOnlyMe = false
	db.petCastbar = false
	db.focusdeBuffFilterAll = false
	db.partyCastBarIconScale = 1
	db.targetToTYPosScale = 20
	db.centerNames = false
	db.frameAuraRowAmount = 0
	db.hidePvpIcon = true
	db.playerAbsorbYPosScale = 0
	db.hideTargetToTDebuffs = true
	db.wasOnLoadingScreen = false
	db.targetdeBuffEnable = true
	db.partyCastBarTimer = true
	db.partyCastBarScaleScale = 1.099999904632568
	db.targetCastBarScale = 1.069999933242798
	db.targetBuffEnable = true
	db.targetToTCastbarAdjustment = true
	db.focusdeBuffPandemicGlow = true
	db.targetdeBuffPandemicGlow = true
	db.targetdeBuffFilterOnlyMe = false
	db.focusCastBarWidth = 150
	db.partyCastBarYPos = 0
	db.hideTargetReputationColor = true
	db.targetdeBuffFilterLessMinite = false
	db.playerAbsorbXPosScale = -60
	db.focusBuffPurgeGlow = true
	db.showPetCastBarIcon = true
	db.hidePlayerRestAnimation = true
	db.hidePlayerRoleIcon = true
	db.targetToTYPos = 20
	db.targetAbsorbYPos = 0
	db.targetAbsorbAmount = true
	db.targetAndFocusAuraOffsetX = 0
	db.targetAbsorbIcon = false
	db.combatIndicatorPlayersOnly = true
	db.targetToTXPosScale = 8
	db.focusCombatIndicator = true
	db.playerAbsorbAmount = true
	db.targetAndFocusHorizontalGap = 3
	db.absorbIndicatorFlipIconText = false
	db.targetBuffFilterAll = true
	db.petCastBarIconScaleScale = 1
	db.focusBuffEnable = true
	db.focusCastBarScaleScale = 1.069999933242798
	db.focusAbsorbAmount = true
	db.PlayerAuraFrameBuffEnable = true
	db.focusToTScaleScale = 0.8999999761581421
	db.hidePrestigeBadge = true
	db.classColorFrames = true
	db.focusCastBarTimer = true
	db.maxTargetBuffs = 32
	db.targetBuffPurgeGlow = true
	db.PlayerAuraFrameBuffFilterWatchList = false
	db.hideArenaFrames = true
	db.targetAuraGlows = true
	db.focusPrestigeBadgeAlpha = true
	db.partyCastBarHeight = 12
	db.targetCastBarXPos = 0
	db.partyCastBarWidth = 100
	db.targetBuffFilterLessMinite = false
	db.focusToTCastbarAdjustment = true
	db.absorbIndicatorTestMode = false
	db.targetToTScale = 0.8999999761581421
	db.playerAuraSpacingX = 5
	db.targetAbsorbAnchor = "TOP"
	db.focusBuffFilterPurgeable = false
	db.hideFocusToTDebuffs = true
	db.darkModeUiAura = true
	db.PlayerAuraFramedeBuffFilterWatchList = false
	db.hasCheckedUi = true
	db.playerCombatIndicator = false
	db.focusImportantAuraGlow = true
	db.focusAbsorbIcon = false
	db.targetdeBuffFilterWatchList = false
	db.hideCombatGlow = true
	db.hidePartyNames = false
	db.partyCastBarXPos = 0
	db.showSpecName = true
	db.focusBuffFilterLessMinite = false
	db.playerAbsorbYPos = 0
	db.targetPrestigeBadgeAlpha = true
	db.focusCastBarHeight = 10
	db.playerCastBarHeight = 11
	db.targetAndFocusAurasPerRow = 5
	db.maxAurasOnFrame = 0
	db.showPartyCastbar = true
	db.targetCastBarHeight = 10
	db.targetToTScaleScale = 0.8999999761581421
	db.petCastBarXPos = 0
	db.combatIndicatorShowSwords = true
	db.targetBuffFilterPurgeable = false
	db.focusBuffFilterAll = true
	db.playerAbsorbIcon = false
	db.playerReputationClassColor = true
	db.combatIndicator = true
	db.petCastBarYPos = 0
	db.targetToTXPos = 8
	db.playerCastBarTimerCenter = false
	db.focusToTXPosScale = 8
	db.playerFrameOCD = true
	db.partyArenaNames = true
	db.petCastBarTestMode = false
	db.hideGroupIndicator = true
	db.frameAurasYPos = 0
	db.hideLevelText = true
	db.playerAbsorbXPos = -60
	db.absorbIndicator = false
	db.focusCastBarScale = 1.069999933242798
	db.absorbIndicatorScale = 1
	db.focusToTScale = 0.8999999761581421
	db.partyCastbars = false
	db.frameAuraHeightGap = 0
	db.combatIndicatorAnchor = "RIGHT"
	db.targetAndFocusAuraScaleScale = 1.149999976158142
	db.frameAuraScale = 0
	db.reopenOptions = false
	db.hidePartyRoles = false
	db.showHiddenAurasIcon = true
	db.shortArenaSpecName = true
	db.hidePlayerRestGlow = true
	db.hidePartyFrameTitle = true
	db.targetdeBuffFilterAll = false
	db.partyCastBarTestMode = false
	db.targetAbsorbXPos = 0
	db.playerAuraGlows = true
	db.targetAndFocusVerticalGap = 4
	db.petCastBarIconScale = 1
	db.focusAuraGlows = true
end