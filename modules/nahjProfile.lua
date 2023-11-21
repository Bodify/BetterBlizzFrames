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
        ["name"] = "264420 - Solider of the Alliance",
        ["comment"] = "",
    }, -- [13]
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
        ["name"] = "Orgrimmar Champion",
        ["comment"] = "",
    }, -- [14]
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
        ["name"] = "Encapsulated Destiny",
        ["comment"] = "",
    }, -- [15]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = false,
        },
        ["comment"] = "",
        ["id"] = 245686,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [16]
}





local nahjAuraWhitelist = {
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 248518,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [1]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 7165,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [2]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 378464,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [3]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 48707,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [4]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 29166,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [5]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 115192,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [6]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 6940,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [7]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 199448,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [8]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 360827,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [9]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 204336,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [10]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 31224,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [11]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 278454,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [12]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 185313,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [13]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 410126,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [14]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 408557,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [15]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 323654,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [16]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 210256,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [17]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 3411,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [18]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 102351,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [19]
    {
        ["flags"] = {
            ["pandemic"] = true,
            ["important"] = false,
        },
        ["comment"] = "",
        ["id"] = 703,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [20]
    {
        ["flags"] = {
            ["pandemic"] = true,
            ["important"] = false,
        },
        ["comment"] = "",
        ["id"] = 1943,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [21]
    {
        ["flags"] = {
            ["pandemic"] = false,
            ["important"] = true,
        },
        ["comment"] = "",
        ["id"] = 345231,
        ["entryColors"] = {
            ["text"] = {
                ["b"] = 0,
                ["g"] = 1,
                ["r"] = 1,
            },
        },
        ["name"] = "",
    }, -- [22]
    {
        ["flags"] = {
            ["important"] = true,
            ["pandemic"] = false,
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
	db.playerCastBarScale = 1.100000023841858
	db.focusToTAnchor = "BOTTOMRIGHT"
	db.focusCastBarYPos = 0
	db.partyCastBarScale = 1.099999904632568
	db.playerCastBarScaleScale = 1.100000023841858
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
	db.showPetCastBarTimer = false
	db.playerAuraFiltering = true
	db.hideTargetReputationColor = true
	db.targetCombatIndicator = true
	db.targetCastBarYPos = 0
	db.focusToTYPos = 20
	db.hideFocusReputationColor = true
	db.petCastBarHeight = 10
	db.focusToTYPosScale = 20
	db.targetBuffFilterOnlyMe = false
	db.targetCastBarScaleScale = 1.100000023841858
	db.darkModeColor = 0.5999999642372131
	db.targetBuffFilterWatchList = false
	db.targetCastBarIconScale = 1
	db.targetCastBarTimer = true
	db.hideFocusToTDebuffs = true
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
	db.hidePlayerRestGlow = true
	db.centerNames = false
	db.frameAuraRowAmount = 0
	db.hidePvpIcon = true
	db.playerAuraGlows = true
	db.hideTargetToTDebuffs = true
	db.shortArenaSpecName = true
	db.targetdeBuffEnable = true
	db.partyCastBarTimer = true
	db.targetAndFocusVerticalGap = 4
	db.targetAbsorbXPos = 0
	db.partyCastBarTestMode = false
	db.targetToTCastbarAdjustment = true
	db.targetdeBuffFilterAll = false
	db.targetdeBuffPandemicGlow = true
	db.targetdeBuffFilterOnlyMe = false
	db.showPetCastBarIcon = true
	db.partyCastBarYPos = 0
	db.playerAbsorbYPosScale = 0
	db.targetdeBuffFilterLessMinite = false
	db.playerAbsorbXPosScale = -60
	db.focusBuffPurgeGlow = true
	db.wasOnLoadingScreen = false
	db.hidePlayerRestAnimation = true
	db.hidePlayerRoleIcon = true
	db.targetToTYPosScale = 20
	db.targetAbsorbYPos = 0
	db.targetAbsorbAmount = true
	db.targetAndFocusAuraOffsetX = 0
	db.hidePartyRoles = true
	db.reopenOptions = false
	db.targetToTXPosScale = 8
	db.focusCombatIndicator = true
	db.playerAbsorbAmount = true
	db.targetAndFocusHorizontalGap = 3
	db.absorbIndicatorFlipIconText = false
	db.targetBuffFilterAll = true
	db.petCastBarIconScaleScale = 1
	db.frameAuraHeightGap = 0
	db.focusCastBarScaleScale = 1.100000023841858
	db.focusAbsorbAmount = true
	db.PlayerAuraFrameBuffEnable = true
	db.partyCastbars = false
	db.focusToTScale = 0.8999999761581421
	db.classColorFrames = true
	db.focusCastBarTimer = true
	db.maxTargetBuffs = 32
	db.absorbIndicatorScale = 1
	db.darkModeColorScale = 0.5999999642372131
	db.PlayerAuraFrameBuffFilterWatchList = false
	db.focusCastBarScale = 1.100000023841858
	db.targetAuraGlows = true
	db.absorbIndicator = false
	db.partyCastBarHeight = 12
	db.targetCastBarXPos = 0
	db.frameAurasYPos = 0
	db.absorbIndicatorTestMode = false
	db.focusToTCastbarAdjustment = true
	db.targetBuffFilterLessMinite = false
	db.petCastBarTestMode = false
	db.playerAuraSpacingX = 5
	db.targetAbsorbAnchor = "TOP"
	db.focusBuffFilterPurgeable = false
	db.hidePvpTimerText = true
	db.playerCastBarTimerCenter = false
	db.targetToTXPos = 8
	db.petCastBarYPos = 0
	db.combatIndicator = true
	db.focusImportantAuraGlow = true
	db.playerReputationClassColor = true
	db.partyCastBarXPos = 0
	db.hideCombatGlow = true
	db.hidePartyNames = true
	db.targetdeBuffFilterWatchList = false
	db.showSpecName = true
	db.focusBuffFilterAll = true
	db.targetBuffFilterPurgeable = false
	db.combatIndicatorShowSwords = true
	db.focusCastBarHeight = 10
	db.playerCastBarHeight = 11
	db.petCastBarXPos = 0
	db.maxAurasOnFrame = 0
	db.showPartyCastbar = true
	db.targetToTScaleScale = 0.8999999761581421
	db.targetCastBarHeight = 10
	db.targetAndFocusAurasPerRow = 5
	db.targetPrestigeBadgeAlpha = true
	db.playerAbsorbYPos = 0
	db.focusBuffFilterLessMinite = false
	db.playerAbsorbIcon = false
	db.focusAbsorbIcon = false
	db.playerCombatIndicator = false
	db.hasCheckedUi = true
	db.PlayerAuraFramedeBuffFilterWatchList = false
	db.darkModeUiAura = true
	db.focusToTXPosScale = 8
	db.playerFrameOCD = true
	db.partyArenaNames = true
	db.targetToTScale = 0.8999999761581421
	db.hideGroupIndicator = true
	db.partyCastBarWidth = 100
	db.hideLevelText = true
	db.playerAbsorbXPos = -60
	db.focusPrestigeBadgeAlpha = true
	db.hideArenaFrames = true
	db.targetBuffPurgeGlow = true
	db.hidePrestigeBadge = true
	db.focusToTScaleScale = 0.8999999761581421
	db.focusBuffEnable = true
	db.combatIndicatorAnchor = "RIGHT"
	db.targetAndFocusAuraScaleScale = 1.149999976158142
	db.frameAuraScale = 0
	db.combatIndicatorPlayersOnly = true
	db.targetAbsorbIcon = false
	db.showHiddenAurasIcon = true
	db.focusAuraGlows = true
	db.focusCastBarWidth = 150
	db.hidePartyFrameTitle = true
	db.focusdeBuffPandemicGlow = true
	db.targetBuffEnable = true
	db.targetCastBarScale = 1.100000023841858
	db.targetToTYPos = 20
	db.showArenaID = true
	db.petCastBarIconScale = 1
	db.partyCastBarScaleScale = 1.099999904632568
end