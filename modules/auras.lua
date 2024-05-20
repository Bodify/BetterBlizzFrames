local function sum(t)
    local sum = 0
    for k,v in pairs(t) do
        sum = sum + v
    end
    return sum
end

local TargetFrame = TargetFrame
local TargetFrameSpellBar = TargetFrameSpellBar
local FocusFrame = FocusFrame
local FocusFrameSpellBar = FocusFrameSpellBar

local BlizzardShouldShowDebuffs = TargetFrame.ShouldShowDebuffs

local playerBuffsHooked
local playerDebuffsHooked
local targetAurasHooked
local targetCastbarsHooked

local ipairs = ipairs
local math_ceil = math.ceil
local table_insert = table.insert
local table_sort = table.sort
local math_max = math.max
local print = print

local printSpellId
local betterTargetPurgeGlow
local betterFocusPurgeGlow
local userEnlargedAuraSize = 1
local userCompactedAuraSize = 1
local auraSpacingX = 4
local auraSpacingY = 4
local aurasPerRow = 5
local targetAndFocusAuraOffsetY = 0
local baseOffsetX = 25
local baseOffsetY = 12.5
local auraScale = 1
local targetImportantAuraGlow
local targetdeBuffPandemicGlow
local targetEnlargeAura
local targetCompactAura
local focusImportantAuraGlow
local focusdeBuffPandemicGlow
local focusEnlargeAura
local focusCompactAura
local auraTypeGap = 1
local targetAndFocusSmallAuraScale = 1.4
local auraFilteringOn
local enlargedTextureAdjustment = 10
local compactedTextureAdjustment = 10
local displayDispelGlowAlways
local customLargeSmallAuraSorting
local shouldAdjustCastbar
local shouldAdjustCastbarFocus
local targetCastBarXPos = 0
local targetCastBarYPos = 0
local focusCastBarXPos = 0
local focusCastBarYPos = 0
local targetToTCastbarAdjustment
local targetAndFocusAuraScale = 1
local targetAndFocusVerticalGap = 4
local targetDetachCastbar
local focusToTCastbarAdjustment = 0
local targetStaticCastbar
local showHiddenAurasIcon
local playerAuraSpacingX = 0
local playerAuraSpacingY = 0
local playerBuffFilterOn
local playerDebuffFilterOn
local printAuraSpellIds
local playerAuraImportantGlow
local focusStaticCastbar
local focusDetachCastbar
local purgeTextureColorRGB = {1, 1, 1, 1}
local changePurgeTextureColor
local targetToTAdjustmentOffsetY
local focusToTAdjustmentOffsetY
local buffsOnTopReverseCastbarMovement
local customImportantAuraSorting
local allowLargeAuraFirst
local onlyPandemicMine
local targetCastBarScale
local focusCastBarScale
local purgeableBuffSorting
local purgeableBuffSortingFirst

function BBF.UpdateUserAuraSettings()
    printSpellId = printAuraSpellIds
    betterTargetPurgeGlow = BetterBlizzFramesDB.targetBuffPurgeGlow
    betterFocusPurgeGlow = BetterBlizzFramesDB.focusBuffPurgeGlow
    userEnlargedAuraSize = BetterBlizzFramesDB.enlargedAuraSize
    userCompactedAuraSize = BetterBlizzFramesDB.compactedAuraSize
    auraSpacingX = BetterBlizzFramesDB.targetAndFocusHorizontalGap
    auraSpacingY = targetAndFocusVerticalGap
    aurasPerRow = BetterBlizzFramesDB.targetAndFocusAurasPerRow
    targetAndFocusAuraOffsetY = BetterBlizzFramesDB.targetAndFocusAuraOffsetY
    baseOffsetX = 25 + BetterBlizzFramesDB.targetAndFocusAuraOffsetX
    baseOffsetY = 12.5 + BetterBlizzFramesDB.targetAndFocusAuraOffsetY
    auraScale = BetterBlizzFramesDB.targetAndFocusAuraScale
    targetImportantAuraGlow = BetterBlizzFramesDB.targetImportantAuraGlow
    targetdeBuffPandemicGlow = BetterBlizzFramesDB.targetdeBuffPandemicGlow
    targetEnlargeAura = BetterBlizzFramesDB.targetEnlargeAura
    targetCompactAura = BetterBlizzFramesDB.targetCompactAura
    focusImportantAuraGlow = BetterBlizzFramesDB.focusImportantAuraGlow
    focusdeBuffPandemicGlow = BetterBlizzFramesDB.focusdeBuffPandemicGlow
    focusEnlargeAura = BetterBlizzFramesDB.focusEnlargeAura
    focusCompactAura = BetterBlizzFramesDB.focusCompactAura
    auraTypeGap = BetterBlizzFramesDB.auraTypeGap
    targetAndFocusSmallAuraScale = BetterBlizzFramesDB.targetAndFocusSmallAuraScale
    auraFilteringOn = BetterBlizzFramesDB.playerAuraFiltering
    enlargedTextureAdjustment = 10 * userEnlargedAuraSize
    compactedTextureAdjustment = 10 * userCompactedAuraSize
    displayDispelGlowAlways = BetterBlizzFramesDB.displayDispelGlowAlways
    customLargeSmallAuraSorting = BetterBlizzFramesDB.customLargeSmallAuraSorting
    focusStaticCastbar = BetterBlizzFramesDB.focusStaticCastbar
    focusDetachCastbar = BetterBlizzFramesDB.focusDetachCastbar
    targetStaticCastbar = BetterBlizzFramesDB.targetStaticCastbar
    targetDetachCastbar = BetterBlizzFramesDB.targetDetachCastbar
    shouldAdjustCastbar = targetStaticCastbar or targetDetachCastbar or BetterBlizzFramesDB.playerAuraFiltering
    shouldAdjustCastbarFocus = focusStaticCastbar or focusDetachCastbar or BetterBlizzFramesDB.playerAuraFiltering
    targetCastBarXPos = BetterBlizzFramesDB.targetCastBarXPos
    targetCastBarYPos = BetterBlizzFramesDB.targetCastBarYPos
    focusCastBarXPos = BetterBlizzFramesDB.focusCastBarXPos
    focusCastBarYPos = BetterBlizzFramesDB.focusCastBarYPos
    targetToTAdjustmentOffsetY = BetterBlizzFramesDB.targetToTAdjustmentOffsetY
    focusToTAdjustmentOffsetY = BetterBlizzFramesDB.focusToTAdjustmentOffsetY
    targetToTCastbarAdjustment = BetterBlizzFramesDB.targetToTCastbarAdjustment
    targetAndFocusAuraScale = BetterBlizzFramesDB.targetAndFocusAuraScale
    targetAndFocusVerticalGap = BetterBlizzFramesDB.targetAndFocusVerticalGap
    focusToTCastbarAdjustment = BetterBlizzFramesDB.focusToTCastbarAdjustment
    showHiddenAurasIcon = BetterBlizzFramesDB.showHiddenAurasIcon
    playerAuraSpacingX = BetterBlizzFramesDB.playerAuraSpacingX
    playerAuraSpacingY = BetterBlizzFramesDB.playerAuraSpacingY
    playerBuffFilterOn = BetterBlizzFramesDB.playerAuraFiltering and BetterBlizzFramesDB.enablePlayerBuffFiltering
    playerDebuffFilterOn = BetterBlizzFramesDB.playerAuraFiltering and BetterBlizzFramesDB.enablePlayerDebuffFiltering
    printAuraSpellIds = BetterBlizzFramesDB.printAuraSpellIds
    playerAuraImportantGlow = BetterBlizzFramesDB.playerAuraImportantGlow
    targetCastBarScale = BetterBlizzFramesDB.targetCastBarScale
    focusCastBarScale = BetterBlizzFramesDB.focusCastBarScale
    allowLargeAuraFirst = BetterBlizzFramesDB.allowLargeAuraFirst
    customImportantAuraSorting = BetterBlizzFramesDB.customImportantAuraSorting
    purgeTextureColorRGB = BetterBlizzFramesDB.purgeTextureColorRGB
    changePurgeTextureColor = BetterBlizzFramesDB.changePurgeTextureColor
    buffsOnTopReverseCastbarMovement = BetterBlizzFramesDB.buffsOnTopReverseCastbarMovement
    onlyPandemicMine = BetterBlizzFramesDB.onlyPandemicAuraMine
    purgeableBuffSorting = BetterBlizzFramesDB.purgeableBuffSorting
    purgeableBuffSortingFirst = BetterBlizzFramesDB.purgeableBuffSortingFirst
end

local function isInWhitelist(spellName, spellId)
    for _, entry in pairs(BetterBlizzFramesDB["auraWhitelist"]) do
        if (entry.name and spellName and string.lower(entry.name) == string.lower(spellName)) or entry.id == spellId then
            return true
        end
    end
    return false
end

local function isInBlacklist(spellName, spellId)
    if spellName and BetterBlizzFramesDB["auraBlacklist"][spellName] then
        return true
    elseif spellId and (BetterBlizzFramesDB["auraBlacklist"][spellId] or BetterBlizzFramesDB["auraBlacklist"][tostring(spellId)]) then
        return true
    end
    return false
end

local function isInBlacklist(spellName, spellId)
    for _, entry in pairs(BetterBlizzFramesDB["auraBlacklist"]) do
        if entry.id == spellId or (entry.name and not entry.id and spellName and string.lower(entry.name) == string.lower(spellName)) then
            return true
        end
    end
    return false
end

local function GetAuraDetails(spellName, spellId)
    local entry = nil

    if spellName and BetterBlizzFramesDB["auraWhitelist2"][spellName] then
        entry = BetterBlizzFramesDB["auraWhitelist2"][spellName]
    elseif spellId then
        entry = BetterBlizzFramesDB["auraWhitelist2"][spellId]
    end

    if entry then
        local isImportant = entry.important or false
        local isPandemic = entry.pandemic or false
        local isEnlarged = entry.enlarged or false
        local isCompacted = entry.compacted or false
        local auraColor = entry.auraColor or nil
        return true, isImportant, isPandemic, isEnlarged, isCompacted, auraColor
    else
        return false, false, false, false, false, nil
    end
end

local function GetAuraDetails(spellName, spellId)
    for _, entry in pairs(BetterBlizzFramesDB["auraWhitelist"]) do
        if entry.id == spellId or (entry.name and not entry.id and spellName and string.lower(entry.name) == string.lower(spellName)) then
            local isImportant = entry.flags and entry.flags.important or false
            local isPandemic = entry.flags and entry.flags.pandemic or false
            local isEnlarged = entry.flags and entry.flags.enlarged or false
            local isCompacted = entry.flags and entry.flags.compacted or false
            local auraColor = entry.entryColors and entry.entryColors.text or nil
            local onlyMine = entry.flags and entry.flags.onlyMine or false

            return true, isImportant, isPandemic, isEnlarged, isCompacted, auraColor, onlyMine
        end
    end
    return false, false, false, false, nil
end

local function ShouldShowBuff(unit, auraData, frameType)
    local spellName = auraData.name
    local spellId = auraData.spellId
    local duration = auraData.duration
    local expirationTime = auraData.expirationTime
    local caster = auraData.sourceUnit
    local isPurgeable = auraData.isStealable
    local castByPlayer = (caster == "player" or caster == "pet")

    -- TargetFrame
    if frameType == "target" then
        -- Buffs
        if BetterBlizzFramesDB["targetBuffEnable"] and auraData.isHelpful then
            local isTargetFriendly = UnitIsFriend("target", "player")
            local isInWhitelist, isImportant, isPandemic, isEnlarged, isCompacted, auraColor, onlyMine = GetAuraDetails(spellName, spellId)
            local isInBlacklist = isInBlacklist(spellName, spellId) and BetterBlizzFramesDB["targetBuffFilterBlacklist"]
            local filterWatchlist = BetterBlizzFramesDB["targetBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzFramesDB["targetBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)
            local filterPurgeable = BetterBlizzFramesDB["targetBuffFilterPurgeable"] and isPurgeable
            local filterOnlyMe = BetterBlizzFramesDB["targetBuffFilterOnlyMe"] and isTargetFriendly and (caster == "player" or (caster == "pet" and UnitIsUnit(caster, "pet")))
            if isInBlacklist then return end
            if not castByPlayer and onlyMine then return end
            if filterWatchlist or filterLessMinite or filterPurgeable or filterOnlyMe or isImportant or isPandemic or isEnlarged or isCompacted then return true, isImportant, isPandemic, isEnlarged, isCompacted, auraColor end
            if not BetterBlizzFramesDB["targetBuffFilterLessMinite"] and not BetterBlizzFramesDB["targetBuffFilterWatchList"] and not BetterBlizzFramesDB["targetBuffFilterPurgeable"] and not (BetterBlizzFramesDB["targetBuffFilterOnlyMe"] and isTargetFriendly) then
                return true
            end
        end
        -- Debuffs
        if BetterBlizzFramesDB["targetdeBuffEnable"] and auraData.isHarmful then
            local isInWhitelist, isImportant, isPandemic, isEnlarged, isCompacted, auraColor, onlyMine = GetAuraDetails(spellName, spellId)
            local isInBlacklist = isInBlacklist(spellName, spellId) and BetterBlizzFramesDB["targetdeBuffFilterBlacklist"]
            local filterWatchlist = BetterBlizzFramesDB["targetdeBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzFramesDB["targetdeBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)
            local filterBlizzard = BetterBlizzFramesDB["targetdeBuffFilterBlizzard"] and BlizzardShouldShowDebuffs
            local filterOnlyMe = BetterBlizzFramesDB["targetdeBuffFilterOnlyMe"] and (caster == "player" or (caster == "pet" and UnitIsUnit(caster, "pet")))
            if isInBlacklist then return end
            if not castByPlayer and onlyMine then return end
            if filterWatchlist or filterLessMinite or filterBlizzard or filterOnlyMe or isImportant or isPandemic or isEnlarged or isCompacted then return true, isImportant, isPandemic, isEnlarged, isCompacted, auraColor end
            if not BetterBlizzFramesDB["targetdeBuffFilterLessMinite"] and not BetterBlizzFramesDB["targetdeBuffFilterWatchList"] and not BetterBlizzFramesDB["targetdeBuffFilterBlizzard"] and not BetterBlizzFramesDB["targetdeBuffFilterOnlyMe"] then
                return true
            end
        end
    -- FocusFrame
    elseif frameType == "focus" then
        -- Buffs
        if BetterBlizzFramesDB["focusBuffEnable"] and auraData.isHelpful then
            local isInWhitelist, isImportant, isPandemic, isEnlarged, isCompacted, auraColor, onlyMine = GetAuraDetails(spellName, spellId)
            local isInBlacklist = isInBlacklist(spellName, spellId) and BetterBlizzFramesDB["focusBuffFilterBlacklist"]
            local isTargetFriendly = UnitIsFriend("focus", "player")
            local filterWatchlist = BetterBlizzFramesDB["focusBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzFramesDB["focusBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)
            local filterPurgeable = BetterBlizzFramesDB["focusBuffFilterPurgeable"] and isPurgeable
            local filterOnlyMe = BetterBlizzFramesDB["focusBuffFilterOnlyMe"] and isTargetFriendly and (caster == "player" or (caster == "pet" and UnitIsUnit(caster, "pet")))
            if isInBlacklist then return end
            if not castByPlayer and onlyMine then return end
            if filterWatchlist or filterLessMinite or filterPurgeable or filterOnlyMe or isImportant or isPandemic or isEnlarged or isCompacted then return true, isImportant, isPandemic, isEnlarged, isCompacted, auraColor end
            if not BetterBlizzFramesDB["focusBuffFilterLessMinite"] and not BetterBlizzFramesDB["focusBuffFilterWatchList"] and not BetterBlizzFramesDB["focusBuffFilterPurgeable"] and not BetterBlizzFramesDB["focusBuffFilterOnlyMe"] then
                return true
            end
        end
        -- Debuffs
        if BetterBlizzFramesDB["focusdeBuffEnable"] and auraData.isHarmful then
            local isInWhitelist, isImportant, isPandemic, isEnlarged, isCompacted, auraColor, onlyMine = GetAuraDetails(spellName, spellId)
            local filterWatchlist = BetterBlizzFramesDB["focusdeBuffFilterWatchList"] and isInWhitelist
            local isInBlacklist = isInBlacklist(spellName, spellId) and BetterBlizzFramesDB["focusdeBuffFilterBlacklist"]
            local filterLessMinite = BetterBlizzFramesDB["focusdeBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)
            local filterBlizzard = BetterBlizzFramesDB["focusdeBuffFilterBlizzard"] and BlizzardShouldShowDebuffs
            local filterOnlyMe = BetterBlizzFramesDB["focusdeBuffFilterOnlyMe"] and (caster == "player" or (caster == "pet" and UnitIsUnit(caster, "pet")))
            if isInBlacklist then return end
            if not castByPlayer and onlyMine then return end
            if filterWatchlist or filterLessMinite or filterBlizzard or filterOnlyMe or isImportant or isPandemic or isEnlarged or isCompacted then return true, isImportant, isPandemic, isEnlarged, isCompacted, auraColor end
            if not BetterBlizzFramesDB["focusdeBuffFilterLessMinite"] and not BetterBlizzFramesDB["focusdeBuffFilterWatchList"] and not BetterBlizzFramesDB["focusdeBuffFilterBlizzard"] and not BetterBlizzFramesDB["focusdeBuffFilterOnlyMe"] then
                return true
            end
        end
    -- Player Buffs and Debuffs
    else
        if frameType == "playerBuffFrame" then
            -- Buffs
            if BetterBlizzFramesDB["PlayerAuraFrameBuffEnable"] and (auraData.auraType == "Buff" or auraData.auraType == "TempEnchant") then
                local isInWhitelist, isImportant, isPandemic, isEnlarged, isCompacted, auraColor, onlyMine = GetAuraDetails(spellName, spellId)
                local isInBlacklist = isInBlacklist(spellName, spellId) and BetterBlizzFramesDB["playerBuffFilterBlacklist"]
                local filterWatchlist = BetterBlizzFramesDB["PlayerAuraFrameBuffFilterWatchList"] and isInWhitelist
                local filterLessMinite = BetterBlizzFramesDB["PlayerAuraFrameBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)
                if isInBlacklist then return end
                if filterWatchlist or filterLessMinite or isImportant then return true, isImportant, isPandemic, isEnlarged, isCompacted, auraColor end
                if not BetterBlizzFramesDB["PlayerAuraFrameBuffFilterLessMinite"] and not BetterBlizzFramesDB["PlayerAuraFrameBuffFilterWatchList"] then
                    return true
                end
            end
        else
            -- Debuffs
            if BetterBlizzFramesDB["PlayerAuraFramedeBuffEnable"] and auraData.auraType == "Debuff" then
                local isInWhitelist, isImportant, isPandemic, isEnlarged, isCompacted, auraColor, onlyMine = GetAuraDetails(spellName, spellId)
                local isInBlacklist = isInBlacklist(spellName, spellId) and BetterBlizzFramesDB["playerdeBuffFilterBlacklist"]
                local filterWatchlist = BetterBlizzFramesDB["PlayerAuraFramedeBuffFilterWatchList"] and isInWhitelist
                local filterLessMinite = BetterBlizzFramesDB["PlayerAuraFramedeBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)
                if isInBlacklist then return end
                if filterWatchlist or filterLessMinite or isImportant then return true, isImportant, isPandemic, isEnlarged, isCompacted, auraColor end
                if not BetterBlizzFramesDB["PlayerAuraFramedeBuffFilterLessMinite"] and not BetterBlizzFramesDB["PlayerAuraFramedeBuffFilterWatchList"] then
                    return true
                end
            end
        end
    end
end

local function CalculateAuraRowsYOffset(frame, rowHeights, castBarScale)
    local totalHeight = 0
    for _, height in ipairs(rowHeights) do
        totalHeight = totalHeight + (height * targetAndFocusAuraScale) / castBarScale  -- Scaling each row height
    end
    return totalHeight + #rowHeights * targetAndFocusVerticalGap
end

local function adjustCastbar(self, frame)
    local meta = getmetatable(self).__index
    local parent = meta.GetParent(self)
    local rowHeights = parent.rowHeights or {}

    meta.ClearAllPoints(self)
    if frame == TargetFrameSpellBar then
        local buffsOnTop = parent.buffsOnTop
        local yOffset = 14
        if targetStaticCastbar then
            --meta.SetPoint(self, "TOPLEFT", meta.GetParent(self), "BOTTOMLEFT", 43, 110);
            meta.SetPoint(self, "TOPLEFT", parent, "BOTTOMLEFT", 43 + targetCastBarXPos, -14 + targetCastBarYPos);
        elseif targetDetachCastbar then
            meta.SetPoint(self, "CENTER", UIParent, "CENTER", targetCastBarXPos, targetCastBarYPos);
        elseif buffsOnTopReverseCastbarMovement and buffsOnTop then
            yOffset = yOffset + CalculateAuraRowsYOffset(parent, rowHeights, targetCastBarScale) + 100/targetCastBarScale
            meta.SetPoint(self, "TOPLEFT", parent, "BOTTOMLEFT", 43 + targetCastBarXPos, yOffset + targetCastBarYPos);
        else
            if not buffsOnTop then
                yOffset = yOffset - CalculateAuraRowsYOffset(parent, rowHeights, targetCastBarScale)
            end
            -- Check if totAdjustment is true and the ToT frame is shown
            if targetToTCastbarAdjustment and parent.haveToT then
                local minOffset = -40
                -- Choose the more negative value
                yOffset = min(minOffset, yOffset)
                if frame == TargetFrameSpellBar then
                    yOffset = yOffset + targetToTAdjustmentOffsetY
                elseif frame == FocusFrameSpellBar then
                    yOffset = yOffset + focusToTAdjustmentOffsetY
                end
            end

            meta.SetPoint(self, "TOPLEFT", parent, "BOTTOMLEFT", 43 + targetCastBarXPos, yOffset + targetCastBarYPos);
        end
    elseif frame == FocusFrameSpellBar then
        local buffsOnTop = parent.buffsOnTop
        local yOffset = 14
        if focusStaticCastbar then
            --meta.SetPoint(self, "TOPLEFT", meta.GetParent(self), "BOTTOMLEFT", 43, 110);
            meta.SetPoint(self, "TOPLEFT", parent, "BOTTOMLEFT", 43 + focusCastBarXPos, -14 + focusCastBarYPos);
        elseif focusDetachCastbar then
            meta.SetPoint(self, "CENTER", UIParent, "CENTER", focusCastBarXPos, focusCastBarYPos);
        elseif buffsOnTopReverseCastbarMovement and buffsOnTop then
            yOffset = yOffset + CalculateAuraRowsYOffset(parent, rowHeights, focusCastBarScale) + 100/focusCastBarScale
            meta.SetPoint(self, "TOPLEFT", parent, "BOTTOMLEFT", 43 + focusCastBarXPos, yOffset + focusCastBarYPos);
        else
            if not buffsOnTop then
                yOffset = yOffset - CalculateAuraRowsYOffset(parent, rowHeights, focusCastBarScale)
            end
            -- Check if totAdjustment is true and the ToT frame is shown
            if focusToTCastbarAdjustment and parent.haveToT then
                local minOffset = -40
                -- Choose the more negative value
                yOffset = min(minOffset, yOffset)
            end

            meta.SetPoint(self, "TOPLEFT", parent, "BOTTOMLEFT", 43 + focusCastBarXPos, yOffset + focusCastBarYPos);
        end
    end
end

local function DefaultCastbarAdjustment(self, frame)
    local meta = getmetatable(self).__index
    local parentFrame = meta.GetParent(self)

    -- Determine whether to use the adjusted logic based on BetterBlizzFramesDB setting
    local useSpellbarAnchor = buffsOnTopReverseCastbarMovement and
                              ((parentFrame.haveToT and parentFrame.auraRows > 2) or (not parentFrame.haveToT and parentFrame.auraRows > 0)) or
                              (not buffsOnTopReverseCastbarMovement and not parentFrame.buffsOnTop and 
                               ((parentFrame.haveToT and parentFrame.auraRows > 2) or (not parentFrame.haveToT and parentFrame.auraRows > 0)))

    local relativeKey = useSpellbarAnchor and parentFrame.spellbarAnchor or parentFrame
    local pointX = useSpellbarAnchor and 18 or (parentFrame.smallSize and 38 or 43)
    local pointY = useSpellbarAnchor and -10 or (parentFrame.smallSize and 3 or 5)

    -- Adjustments for ToT and specific frame adjustments
    if (not useSpellbarAnchor) and parentFrame.haveToT then
        local totAdjustment = (TargetFrameSpellBar and targetToTCastbarAdjustment) or (FocusFrameSpellBar and focusToTCastbarAdjustment)
        if totAdjustment then
            pointY = parentFrame.smallSize and -48 or -46
            if frame == TargetFrameSpellBar then
                pointY = pointY + targetToTAdjustmentOffsetY
            elseif frame == FocusFrameSpellBar then
                pointY = pointY + focusToTAdjustmentOffsetY
            end
        end
    end

    if frame == TargetFrameSpellBar then
        pointX = pointX + targetCastBarXPos
        pointY = pointY + targetCastBarYPos
    elseif frame == FocusFrameSpellBar then
        pointX = pointX + focusCastBarXPos
        pointY = pointY + focusCastBarYPos
    end

    -- Apply setting-specific adjustment
    if buffsOnTopReverseCastbarMovement then
        meta.SetPoint(self, "TOPLEFT", relativeKey, "BOTTOMLEFT", pointX, -pointY + 50)
    else
        meta.SetPoint(self, "TOPLEFT", relativeKey, "BOTTOMLEFT", pointX, pointY)
    end
end

function BBF.CastbarAdjustCaller()
    BBF.UpdateUserAuraSettings()
    if shouldAdjustCastbar or shouldAdjustCastbarFocus then
        if shouldAdjustCastbar then
            adjustCastbar(TargetFrame.spellbar, TargetFrameSpellBar)
        end
        if shouldAdjustCastbarFocus then
            adjustCastbar(FocusFrame.spellbar, FocusFrameSpellBar)
        end
    else
        DefaultCastbarAdjustment(TargetFrame.spellbar, TargetFrameSpellBar)
        DefaultCastbarAdjustment(FocusFrame.spellbar, FocusFrameSpellBar)
    end
end

local trackedBuffs = {};
local checkBuffsTimer = nil;

local function StopCheckBuffsTimer()
    if checkBuffsTimer then
        checkBuffsTimer:Cancel();
        checkBuffsTimer = nil;
    end
end

local function CheckBuffs()
    local currentGameTime = GetTime()
    for auraInstanceID, aura in pairs(trackedBuffs) do
        if aura.isPandemic and aura.expirationTime then
            local remainingDuration = aura.expirationTime - currentGameTime
            if remainingDuration <= 0 then
                aura.isPandemic = false
                trackedBuffs[auraInstanceID] = nil
                if aura.PandemicGlow then
                    aura.PandemicGlow:Hide()
                end
                aura.isPandemicActive = false
            elseif remainingDuration <= 5.1 then
                if not aura.PandemicGlow then
                    aura.PandemicGlow = aura:CreateTexture(nil, "OVERLAY");
                    aura.PandemicGlow:SetAtlas("newplayertutorial-drag-slotgreen");
                    aura.PandemicGlow:SetDesaturated(true)
                    aura.PandemicGlow:SetVertexColor(1, 0, 0)
                    if aura.Cooldown then
                        aura.PandemicGlow:SetParent(aura.Cooldown)
                    end
                end
                if aura.isEnlarged then
                    aura.PandemicGlow:SetPoint("TOPLEFT", aura, "TOPLEFT", -enlargedTextureAdjustment, enlargedTextureAdjustment)
                    aura.PandemicGlow:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", enlargedTextureAdjustment, -enlargedTextureAdjustment)
                else
                    aura.PandemicGlow:SetPoint("TOPLEFT", aura, "TOPLEFT", -10, 10)
                    aura.PandemicGlow:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", 10, -10)
                end

                aura.isPandemicActive = true
                aura.PandemicGlow:Show();
                if aura.Border then
                    aura.Border:SetAlpha(0)
                end
            else
                if aura.PandemicGlow then
                    aura.PandemicGlow:Hide();
                end
                aura.isPandemicActive = false
            end
        else
            aura.isPandemicActive = false
            if aura.Border and not aura.isImportant and not aura.isPurgeGlow then
                aura.Border:SetAlpha(1)
            end
            if aura.border then
                aura.border:SetAlpha(1)
            end
            for auraInstanceID, _ in pairs(trackedBuffs) do
                trackedBuffs[auraInstanceID] = nil
            end
        end
    end
    if next(trackedBuffs) == nil then
        StopCheckBuffsTimer();
    end
end

local function StartCheckBuffsTimer()
    if not checkBuffsTimer then
        CheckBuffs()
        checkBuffsTimer = C_Timer.NewTicker(0.1, CheckBuffs);
    end
end

local MIN_AURA_SIZE = 17
local adjustmentForBuffsOnTop = -80  -- Height adjustment when buffs are on top
local function AdjustAuras(self, frameType)
    local adjustedSize = MIN_AURA_SIZE * targetAndFocusSmallAuraScale
    local buffsOnTop = self.buffsOnTop

    local initialOffsetX = (baseOffsetX / auraScale)
    local initialOffsetY = (baseOffsetY / auraScale)

    local function adjustAuraPosition(auras, yOffset, buffsOnTop)
        local currentYOffset = yOffset + (buffsOnTop and -(initialOffsetY + adjustmentForBuffsOnTop) or initialOffsetY)
        local rowWidths, rowHeights = {}, {}
        --local previousAuraWasImportant = false

        for i, aura in ipairs(auras) do
            aura:SetScale(auraScale)
            --aura:SetMouseClickEnabled(false)
            local auraSize = aura:GetHeight()
            if not aura.isLarge then
                -- Apply the adjusted size to smaller auras
                aura:SetSize(adjustedSize, adjustedSize)
                if aura.PurgeGlow then
                    aura.PurgeGlow:SetScale(targetAndFocusSmallAuraScale)
                end
                if aura.ImportantGlow then
                    aura.ImportantGlow:SetScale(targetAndFocusSmallAuraScale)
                end
                if aura.PandemicGlow then
                    aura.PandemicGlow:SetScale(targetAndFocusSmallAuraScale)
                end
                if aura.Stealable then
                    aura.Stealable:SetScale(targetAndFocusSmallAuraScale)
                end
                if aura.Border then
                    aura.Border:SetScale(targetAndFocusSmallAuraScale)
                end
                auraSize = adjustedSize
            end

            if aura.isEnlarged or aura.isCompacted then
                local sizeMultiplier = aura.isEnlarged and userEnlargedAuraSize or userCompactedAuraSize
                local defaultLargeAuraSize = aura.isLarge and 21 or 17
                local importantSize = defaultLargeAuraSize * sizeMultiplier
                aura:SetSize(importantSize, importantSize)
                auraSize = importantSize
            end

            local columnIndex, rowIndex
            columnIndex = (i - 1) % aurasPerRow
            rowIndex = math_ceil(i / aurasPerRow)

            rowWidths[rowIndex] = rowWidths[rowIndex] or initialOffsetX

            if columnIndex == 0 and i ~= 1 then
                if buffsOnTop then
                    -- Adjust the Y-offset for stacking upwards when buffs are on top
                    currentYOffset = currentYOffset + (rowHeights[rowIndex - 1] or 0) + auraSpacingY
                else
                    -- Existing logic for stacking downwards
                    currentYOffset = currentYOffset - (rowHeights[rowIndex - 1] or 0) - auraSpacingY
                end
            elseif columnIndex ~= 0 then
                rowWidths[rowIndex] = rowWidths[rowIndex] + auraSpacingX
            end


            local offsetX = rowWidths[rowIndex]
            rowHeights[rowIndex] = math_max(auraSize, (rowHeights[rowIndex] or 0))
            rowWidths[rowIndex] = offsetX + auraSize

            aura:ClearAllPoints()
            if buffsOnTop then
                aura:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", offsetX, currentYOffset + initialOffsetY)
            else
                aura:SetPoint("TOPLEFT", self, "BOTTOMLEFT", offsetX, currentYOffset + initialOffsetY)
            end
        end

        return rowHeights
    end

    local unit = self.unit
    local isFriend = unit and not UnitCanAttack("player", unit)

    local buffs, debuffs = {}, {}

    local function defaultComparator(a, b)
        -- Default sorting logic
        if a.isLarge and not b.isLarge then
            return true
        elseif not a.isLarge and b.isLarge then
            return false
        elseif a.canApply ~= b.canApply then
            return a.canApply
        else
            return a.auraInstanceID < b.auraInstanceID
        end
    end

    local function importantAuraComparator(a, b)
        if a.isImportant ~= b.isImportant then
            return a.isImportant
        end
        return defaultComparator(a, b)
    end

    local function importantAllowEnlargedAuraComparator(a, b)
        if a.isEnlarged ~= b.isEnlarged then
            return a.isEnlarged
        end
        if a.isImportant ~= b.isImportant then
            return a.isImportant
        end
        return defaultComparator(a, b)
    end

    local function largeSmallAuraComparator(a, b)
        if a.isEnlarged or b.isEnlarged then
            if a.isEnlarged and not b.isEnlarged then
                return true
            elseif not a.isEnlarged and b.isEnlarged then
                return false
            else
                return defaultComparator(a, b)
            end
        end

        if a.isCompacted or b.isCompacted then
            if a.isCompacted and not b.isCompacted then
                return false
            elseif not a.isCompacted and b.isCompacted then
                return true
            else
                return defaultComparator(a, b)
            end
        end

        -- For auras that are neither enlarged nor compacted, use default sorting
        if not a.isEnlarged and not a.isCompacted and not b.isEnlarged and not b.isCompacted then
            if a.isLarge and not b.isLarge then
                return true
            elseif not a.isLarge and b.isLarge then
                return false
            elseif a.canApply ~= b.canApply then
                return a.canApply
            else
                return defaultComparator(a, b)
            end
        end
        return defaultComparator(a, b)
    end

    local function largeSmallAndImportantAuraComparator(a, b)
        if a.isImportant ~= b.isImportant then
            return a.isImportant
        end

        if a.isEnlarged or b.isEnlarged then
            if a.isEnlarged and not b.isEnlarged then
                return true
            elseif not a.isEnlarged and b.isEnlarged then
                return false
            else
                -- Both are enlarged, sort by auraInstanceID
                return defaultComparator(a, b)
            end
        end

        -- Compacted auras come last, sorted by auraInstanceID
        if a.isCompacted or b.isCompacted then
            if a.isCompacted and not b.isCompacted then
                return false
            elseif not a.isCompacted and b.isCompacted then
                return true
            else
                -- Both are compacted, sort by auraInstanceID
                return defaultComparator(a, b)
            end
        end

        -- For auras that are neither enlarged nor compacted, use default sorting
        if not a.isEnlarged and not a.isCompacted and not b.isEnlarged and not b.isCompacted then
            if a.isLarge and not b.isLarge then
                return true
            elseif not a.isLarge and b.isLarge then
                return false
            elseif a.canApply ~= b.canApply then
                return a.canApply
            else
                return defaultComparator(a, b)
            end
        end
        return defaultComparator(a, b)
    end

    local function largeSmallAndImportantAndEnlargedFirstAuraComparator(a, b)
        if a.isEnlarged or b.isEnlarged then
            if a.isEnlarged and not b.isEnlarged then
                return true
            elseif not a.isEnlarged and b.isEnlarged then
                return false
            else
                -- Both are enlarged, sort by auraInstanceID
                return defaultComparator(a, b)
            end
        end

        -- Compacted auras come last, sorted by auraInstanceID
        if a.isCompacted or b.isCompacted then
            if a.isCompacted and not b.isCompacted then
                return false
            elseif not a.isCompacted and b.isCompacted then
                return true
            else
                -- Both are compacted, sort by auraInstanceID
                return defaultComparator(a, b)
            end
        end

        if a.isImportant ~= b.isImportant then
            return a.isImportant
        end

        -- For auras that are neither enlarged nor compacted, use default sorting
        if not a.isEnlarged and not a.isCompacted and not b.isEnlarged and not b.isCompacted then
            if a.isLarge and not b.isLarge then
                return true
            elseif not a.isLarge and b.isLarge then
                return false
            elseif a.canApply ~= b.canApply then
                return a.canApply
            else
                return defaultComparator(a, b)
            end
        end
        return defaultComparator(a, b)
    end

    local function allowLargeAuraFirstComparator(a, b)
        if a.isEnlarged ~= b.isEnlarged then
            return a.isEnlarged
        end
        -- Proceed with other sorting criteria without giving special treatment to isImportant
        if a.isLarge and not b.isLarge then
            return true
        elseif not a.isLarge and b.isLarge then
            return false
        elseif a.canApply ~= b.canApply then
            return a.canApply
        else
            return defaultComparator(a, b)
        end
    end

    local function getCustomAuraComparatorWithoutPurgeable()
        if customImportantAuraSorting and customLargeSmallAuraSorting and allowLargeAuraFirst then
            return largeSmallAndImportantAndEnlargedFirstAuraComparator
        elseif customImportantAuraSorting and customLargeSmallAuraSorting then
            return largeSmallAndImportantAuraComparator
        elseif customImportantAuraSorting and allowLargeAuraFirst then
            return importantAllowEnlargedAuraComparator
        elseif customImportantAuraSorting then
            return importantAuraComparator
        elseif customLargeSmallAuraSorting then
            return largeSmallAuraComparator
        elseif allowLargeAuraFirst then
            return allowLargeAuraFirstComparator
        else
            return defaultComparator
        end
    end

    local function purgeableFirstComparator(a, b)
        if a.isPurgeable ~= b.isPurgeable then
            return a.isPurgeable
        end
        return getCustomAuraComparatorWithoutPurgeable()(a, b)
    end

    local function purgeableAfterImportantAndEnlargedComparator(a, b)
        if a.isImportant ~= b.isImportant then
            return a.isImportant
        end

        if a.isEnlarged ~= b.isEnlarged then
            return a.isEnlarged
        end

        if a.isPurgeable ~= b.isPurgeable then
            return a.isPurgeable
        end

        return getCustomAuraComparatorWithoutPurgeable()(a, b)
    end

    local function getCustomAuraComparator()
        if purgeableBuffSorting then
            if purgeableBuffSortingFirst then
                return purgeableFirstComparator
            else
                return purgeableAfterImportantAndEnlargedComparator
            end
        end
        return getCustomAuraComparatorWithoutPurgeable()
    end

    for aura in self.auraPools:EnumerateActive() do
        local auraData = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, aura.auraInstanceID)
        if auraData then
            local isLarge = auraData.sourceUnit == "player" or auraData.sourceUnit == "pet"
            local canApply = auraData.canApplyAura or false

            -- Store the properties with the aura for later sorting
            aura.isLarge = isLarge
            aura.canApply = canApply
            local shouldShowAura, isImportant, isPandemic, isEnlarged, isCompacted, auraColor

            if frameType == "target" then
                shouldShowAura, isImportant, isPandemic, isEnlarged, isCompacted, auraColor = ShouldShowBuff(unit, auraData, "target")
                isImportant = isImportant and targetImportantAuraGlow
                isPandemic = isPandemic and targetdeBuffPandemicGlow
                isEnlarged = isEnlarged and targetEnlargeAura
                isCompacted = isCompacted and targetCompactAura
            elseif frameType == "focus" then
                shouldShowAura, isImportant, isPandemic, isEnlarged, isCompacted, auraColor = ShouldShowBuff(unit, auraData, "focus")
                isImportant = isImportant and focusImportantAuraGlow
                isPandemic = isPandemic and focusdeBuffPandemicGlow
                isEnlarged = isEnlarged and focusEnlargeAura
                isCompacted = isCompacted and focusCompactAura
            end

            if onlyPandemicMine and not isLarge then
                isPandemic = false
            end

            if shouldShowAura then
                aura:Show()

                aura.spellId = auraData.spellId

                if (auraData.isStealable or (auraData.dispelName == "Magic" and ((not isFriend and auraData.isHelpful) or (isFriend and auraData.isHarmful)))) then
                    aura.isPurgeable = true
                end

                if not aura.filterClick then
                    aura:HookScript("OnMouseDown", function(self, button)
                        if IsShiftKeyDown() and IsAltKeyDown() then
                            local spellName, _, icon = GetSpellInfo(aura.spellId)
                            local spellId = tostring(aura.spellId)
                            local iconString = "|T" .. icon .. ":16:16:0:0|t" -- Format the icon for display

                            if button == "LeftButton" then
                                BBF.auraWhitelist(aura.spellId)
                                print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconString .. " " .. spellName .. " (" .. spellId .. ") was added to |cff00ff00whitelist|r.")
                            elseif button == "RightButton" then
                                BBF.auraBlacklist(aura.spellId)
                                print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconString .. " " .. spellName .. " (" .. spellId .. ") was added to |cffff0000blacklist|r.")
                            end
                        end
                    end)
                    aura.filterClick = true
                end

                -- Print Logic
                if printSpellId and not aura.bbfHookAdded then
                    aura:HookScript("OnEnter", function()
                        local currentAuraID = aura.auraInstanceID
                        if not aura.bbfPrinted or aura.bbfLastPrintedAuraID ~= currentAuraID then
                            local thisAuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, currentAuraID)
                            if thisAuraData then
                                local iconTexture = thisAuraData.icon and "|T" .. thisAuraData.icon .. ":16:16|t" or ""
                                print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconTexture .. " " .. (thisAuraData.name or "Unknown") .. "  |A:worldquest-icon-engineering:14:14|a ID: " .. (thisAuraData.spellId or "Unknown"))
                                aura.bbfPrinted = true
                                aura.bbfLastPrintedAuraID = currentAuraID

                                -- Cancel existing timer if any
                                if aura.bbfTimer then
                                    aura.bbfTimer:Cancel()
                                end

                                -- Schedule the reset of bbfPrinted flag
                                aura.bbfTimer = C_Timer.NewTimer(6, function()
                                    aura.bbfPrinted = false
                                end)
                            end
                        end
                    end)
                    aura.bbfHookAdded = true
                end

                -- Enlarged logic
                if isEnlarged then
                    aura.isEnlarged = true
                else
                    aura.isEnlarged = false
                end

                -- Smaller logic
                if isCompacted then
                    aura.isCompacted = true
                else
                    aura.isCompacted = false
                end

                -- Important logic
                if isImportant then
                    aura.isImportant = true
                    if not aura.ImportantGlow then
                        aura.ImportantGlow = aura:CreateTexture(nil, "OVERLAY")
                        aura.ImportantGlow:SetAtlas("newplayertutorial-drag-slotgreen")
                        aura.ImportantGlow:SetDesaturated(true)
                    end
                    if aura.isEnlarged then
                        aura.ImportantGlow:SetPoint("TOPLEFT", aura, "TOPLEFT", -enlargedTextureAdjustment, enlargedTextureAdjustment)
                        aura.ImportantGlow:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", enlargedTextureAdjustment, -enlargedTextureAdjustment)
                    elseif aura.isCompacted then
                        aura.ImportantGlow:SetPoint("TOPLEFT", aura, "TOPLEFT", -compactedTextureAdjustment, compactedTextureAdjustment)
                        aura.ImportantGlow:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", compactedTextureAdjustment, -compactedTextureAdjustment)
                    else
                        aura.ImportantGlow:SetPoint("TOPLEFT", aura, "TOPLEFT", -10, 10)
                        aura.ImportantGlow:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", 10, -10)
                    end
                    if auraColor then
                        aura.ImportantGlow:SetVertexColor(auraColor.r, auraColor.g, auraColor.b, auraColor.a)
                    else
                        aura.ImportantGlow:SetVertexColor(0, 1, 0)
                    end
                    aura.ImportantGlow:Show()
                else
                    aura.isImportant = false
                    if aura.ImportantGlow then
                        aura.ImportantGlow:Hide()
                        if aura.Stealable and auraData.isStealable then
                            aura.Stealable:SetAlpha(1)
                        end
                    end
                end

                -- Better Purge Glow
                if ((frameType == "target" and (auraData.isStealable or (displayDispelGlowAlways and auraData.dispelName == "Magic" and ((not isFriend and auraData.isHelpful) or (isFriend and auraData.isHarmful)))) and betterTargetPurgeGlow) or
                (frameType == "focus" and (auraData.isStealable or (displayDispelGlowAlways and auraData.dispelName == "Magic" and ((not isFriend and auraData.isHelpful) or (isFriend and auraData.isHarmful)))) and betterFocusPurgeGlow)) then
                    if not aura.PurgeGlow then
                        aura.PurgeGlow = aura:CreateTexture(nil, "OVERLAY")
                        aura.PurgeGlow:SetAtlas("newplayertutorial-drag-slotblue")
                    end
                    if aura.isEnlarged then
                        aura.PurgeGlow:SetPoint("TOPLEFT", aura, "TOPLEFT", -enlargedTextureAdjustment, enlargedTextureAdjustment)
                        aura.PurgeGlow:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", enlargedTextureAdjustment, -enlargedTextureAdjustment)
                    elseif aura.isCompacted then
                        aura.PurgeGlow:SetPoint("TOPLEFT", aura, "TOPLEFT", -compactedTextureAdjustment, compactedTextureAdjustment)
                        aura.PurgeGlow:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", compactedTextureAdjustment, -compactedTextureAdjustment)
                    else
                        aura.PurgeGlow:SetPoint("TOPLEFT", aura, "TOPLEFT", -10, 10)
                        aura.PurgeGlow:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", 10, -10)
                    end
                    aura.isPurgeGlow = true
                    if changePurgeTextureColor then
                        aura.PurgeGlow:SetDesaturated(true)
                        aura.PurgeGlow:SetVertexColor(unpack(purgeTextureColorRGB))
                    end
                    aura.PurgeGlow:Show()
                else
                    if aura.PurgeGlow then
                        if aura.Stealable and auraData.isStealable then
                            aura.Stealable:SetAlpha(1)
                        end
                        aura.PurgeGlow:Hide()
                    end
                    aura.isPurgeGlow = false
                    if displayDispelGlowAlways then
                        if auraData.dispelName == "Magic" and ((not isFriend and auraData.isHelpful) or (isFriend and auraData.isHarmful)) then
                            if aura.Stealable then
                                aura.Stealable:Show()
                                if changePurgeTextureColor then
                                    aura.Stealable:SetVertexColor(unpack(purgeTextureColorRGB))
                                end
                            end
                        else
                            if aura.Stealable then
                                aura.Stealable:Hide()
                            end
                        end
                    end
                end

                -- Pandemic Logic
                if isPandemic then
                    aura.expirationTime = auraData.expirationTime
                    aura.isPandemic = true
                    trackedBuffs[aura.auraInstanceID] = aura
                    StartCheckBuffsTimer()
                else
                    aura.isPandemic = false
                    if aura.PandemicGlow then
                        aura.PandemicGlow:Hide()
                    end
                end

                if aura.isImportant or aura.isPurgeGlow or (aura.isPandemicActive and isPandemic) then
                    if aura.border then
                        aura.border:SetAlpha(0)
                    end
                    if aura.Border then
                        aura.Border:SetAlpha(0)
                    end
                    if aura.Stealable then
                        aura.Stealable:SetAlpha(0)
                    end
                else
                    if aura.border then
                        aura.border:SetAlpha(1)
                    end
                    if aura.Border then
                        aura.Border:SetAlpha(1)
                    end
                    if aura.Stealable then
                        aura.Stealable:SetAlpha(1)
                    end
                end

                if aura.Border ~= nil then
                    debuffs[#debuffs + 1] = aura
                else
                    buffs[#buffs + 1] = aura
                end
            else
                aura:Hide()
                if aura.PandemicGlow then
                    aura.PandemicGlow:Hide()
                end
            end
        end
    end

    local customAuraComparator = getCustomAuraComparator()
    table_sort(buffs, customAuraComparator)
    table_sort(debuffs, customAuraComparator)

    if not isFriend then
        if buffsOnTop then
            self.rowHeights = adjustAuraPosition(debuffs, targetAndFocusAuraOffsetY, buffsOnTop)
            local totalDebuffHeight = sum(self.rowHeights)

            local yOffsetForBuffs = totalDebuffHeight + (auraSpacingY * #self.rowHeights) + targetAndFocusAuraOffsetY
            if #debuffs > 0 then
                yOffsetForBuffs = yOffsetForBuffs + 5 + auraTypeGap
            end

            local buffRowHeights = adjustAuraPosition(buffs, yOffsetForBuffs, buffsOnTop)
            if #buffs > 0 and #debuffs > 0 then
                self.rowHeights[#self.rowHeights] = self.rowHeights[#self.rowHeights] + auraTypeGap
            end
            for _, height in ipairs(buffRowHeights) do
                table_insert(self.rowHeights, height)
            end
        else
            self.rowHeights = adjustAuraPosition(debuffs, 0)
            local totalDebuffHeight = sum(self.rowHeights)
            local buffRowHeights
            if #debuffs == 0 then
                buffRowHeights = adjustAuraPosition(buffs, -totalDebuffHeight - (auraSpacingY * #self.rowHeights))
            else
                buffRowHeights = adjustAuraPosition(buffs, -totalDebuffHeight - (auraSpacingY * #self.rowHeights) - auraTypeGap)
            end
            if #buffs > 0 and #debuffs > 0 then
                self.rowHeights[#self.rowHeights] = self.rowHeights[#self.rowHeights] + auraTypeGap
            end
            for _, height in ipairs(buffRowHeights) do
                table_insert(self.rowHeights, height)
            end
        end
    else
        if buffsOnTop then
            self.rowHeights = adjustAuraPosition(buffs, targetAndFocusAuraOffsetY, buffsOnTop)
            local totalBuffHeight = sum(self.rowHeights)

            local yOffsetForDebuffs = totalBuffHeight + (auraSpacingY * #self.rowHeights) + targetAndFocusAuraOffsetY
            if #buffs > 0 then
                yOffsetForDebuffs = yOffsetForDebuffs + 5 + auraTypeGap
            end

            local debuffRowHeights = adjustAuraPosition(debuffs, yOffsetForDebuffs, buffsOnTop)
            if #buffs > 0 and #debuffs > 0 then
                self.rowHeights[#self.rowHeights] = self.rowHeights[#self.rowHeights] + auraTypeGap
            end
            for _, height in ipairs(debuffRowHeights) do
                table_insert(self.rowHeights, height)
            end
        else
            self.rowHeights = adjustAuraPosition(buffs, 0)
            local totalBuffHeight = sum(self.rowHeights)
            local debuffRowHeights
            if #buffs == 0 then
                debuffRowHeights = adjustAuraPosition(debuffs, -totalBuffHeight - (auraSpacingY * #self.rowHeights))
            else
                debuffRowHeights = adjustAuraPosition(debuffs, -totalBuffHeight - (auraSpacingY * #self.rowHeights) - auraTypeGap)
            end
            if #buffs > 0 and #debuffs > 0 then
                self.rowHeights[#self.rowHeights] = self.rowHeights[#self.rowHeights] + auraTypeGap
            end
            for _, height in ipairs(debuffRowHeights) do
                table_insert(self.rowHeights, height)
            end
        end
    end

    if not targetStaticCastbar or not targetDetachCastbar then
        if frameType == "target" then
            adjustCastbar(TargetFrame.spellbar, TargetFrameSpellBar)
        elseif frameType == "focus" then
            adjustCastbar(FocusFrame.spellbar, FocusFrameSpellBar)
        end
    end
end

-- Function to create the toggle icon
local toggleIconGlobal = nil
local shouldKeepAurasVisible = false
local hiddenAuras = 0
--local showHiddenAurasIcon = true

local function UpdateHiddenAurasCount()
    if not showHiddenAurasIcon then
        if toggleIconGlobal then
            toggleIconGlobal:Hide()
            return
        end
    else
        if toggleIconGlobal then
            toggleIconGlobal:Show()
        end
    end

    if toggleIconGlobal then
        toggleIconGlobal.hiddenAurasCount:SetText(hiddenAuras)
        if hiddenAuras == 1 then
            toggleIconGlobal.hiddenAurasCount:SetPoint("CENTER", ToggleHiddenAurasButton, "CENTER", -1.5, 0)
        elseif hiddenAuras == 0 then
            toggleIconGlobal:Hide()
        else
            toggleIconGlobal.hiddenAurasCount:SetPoint("CENTER", ToggleHiddenAurasButton, "CENTER", 0, 0)
        end
    end
end

local function ResetHiddenAurasCount()
    hiddenAuras = 0
    UpdateHiddenAurasCount()
end

-- Functions to show and hide the hidden auras
local function ShowHiddenAuras()
    if ToggleHiddenAurasButton.isDropdownExpanded then
        for _, auraFrame in ipairs(BuffFrame.auraFrames) do
            if auraFrame.isAuraHidden then
                auraFrame:Show()
            end
        end
    end
end

local function HideHiddenAuras()
    if not shouldKeepAurasVisible then
        for _, auraFrame in ipairs(BuffFrame.auraFrames) do
            if auraFrame.isAuraHidden then
                auraFrame:Hide()
            end
        end
    end
end

local function CreateToggleIcon()
    if not showHiddenAurasIcon then return end
    if toggleIconGlobal then return toggleIconGlobal end
    local toggleIcon = CreateFrame("Button", "ToggleHiddenAurasButton", BuffFrame)
    toggleIcon:SetSize(30, 30)
    local currentAuraSize = BuffFrame.AuraContainer.iconScale
    local addIconsToRight = BuffFrame.AuraContainer.addIconsToRight or false
    if currentAuraSize then
        toggleIcon:SetScale(currentAuraSize)
    end
    if BuffFrame.CollapseAndExpandButton then
        if addIconsToRight then
            toggleIcon:SetPoint("RIGHT", BuffFrame.CollapseAndExpandButton, "LEFT", 0, 0)
        else
            toggleIcon:SetPoint("LEFT", BuffFrame.CollapseAndExpandButton, "RIGHT", 0, 0)
        end
    else
        toggleIcon:SetPoint("TOPLEFT", BuffFrame, "TOPRIGHT", 0, -6)
    end

    local Icon = toggleIcon:CreateTexture(nil, "BACKGROUND")
    Icon:SetAllPoints()
    Icon:SetTexture(BetterBlizzFramesDB.auraToggleIconTexture)
    -------
    if IsAddOnLoaded("SUI") then
        if SUIDB and SUIDB["profiles"] and SUIDB["profiles"]["Default"] and SUIDB["profiles"]["Default"]["general"] then
            -- Now check if the theme variable doesn't exist or is nil
            if SUIDB["profiles"]["Default"]["general"]["theme"] == "Dark" or SUIDB["profiles"]["Default"]["general"]["theme"] == "Custom" or SUIDB["profiles"]["Default"]["general"]["theme"] == "Class" then
                Icon:SetTexCoord(0.10000000149012, 0.89999997615814, 0.89999997615814, 0.10000000149012)
                -- Border creation
                local border = CreateFrame("Frame", nil, toggleIcon)
                border:SetSize(34, 34)
                border:SetPoint("CENTER", toggleIcon, "CENTER", 0, 0)

                border.texture = border:CreateTexture()
                border.texture:SetAllPoints()
                border.texture:SetTexture("Interface\\Addons\\SUI\\Media\\Textures\\Core\\gloss")
                border.texture:SetTexCoord(0, 1, 0, 1)
                border.texture:SetDrawLayer("BACKGROUND", -7)
                border.texture:SetVertexColor(0.4, 0.35, 0.35)

                -- Optional shadow effect
                local Backdrop = {
                    bgFile = nil,
                    edgeFile = "Interface\\Addons\\SUI\\Media\\Textures\\Core\\outer_shadow",
                    tile = false,
                    tileSize = 32,
                    edgeSize = 6,
                    insets = { left = 6, right = 6, top = 6, bottom = 6 },
                }

                border.shadow = CreateFrame("Frame", nil, border, "BackdropTemplate")
                border.shadow:SetPoint("TOPLEFT", border, "TOPLEFT", -4, 4)
                border.shadow:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", 4, -4)
                border.shadow:SetBackdrop(Backdrop)
                border.shadow:SetBackdropBorderColor(unpack(SUI:Color(0.25, 0.9)))
            end
        end
    end
    -------
    toggleIcon.Icon = Icon

    -- Creating FontString to display the count of hidden auras
    toggleIcon.hiddenAurasCount = toggleIcon:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    toggleIcon.hiddenAurasCount:SetPoint("CENTER", toggleIcon, "CENTER", 0, 0)
    toggleIcon.hiddenAurasCount:SetTextColor(1, 1, 1)

    toggleIcon.isAurasShown = false

    toggleIcon:SetScript("OnClick", function(self)
        shouldKeepAurasVisible = not shouldKeepAurasVisible
        BuffFrame:UpdateAuraButtons()
        if shouldKeepAurasVisible then
            ShowHiddenAuras()
        else
            HideHiddenAuras()
        end
        UpdateHiddenAurasCount()
    end)

    toggleIcon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 8, 5)
        GameTooltip:SetText("Better|cff00c0ffBlizz|rFrames\nFiltered Buffs\nClick to show", 1, 1, 1)
        GameTooltip:Show()
        if not self.isAurasShown then
            ShowHiddenAuras()
        end
    end)

    toggleIcon:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        if not self.isAurasShown then
            HideHiddenAuras()
        end
    end)
    toggleIconGlobal = toggleIcon
    return toggleIcon
end

local BuffFrame = BuffFrame
local function PersonalBuffFrameFilterAndGrid(self)
    ResetHiddenAurasCount()
    local isExpanded = BuffFrame:IsExpanded();
    local currentAuraSize = BuffFrame.AuraContainer.iconScale
    local addIconsToRight = BuffFrame.AuraContainer.addIconsToRight or false
    if ToggleHiddenAurasButton then
        ToggleHiddenAurasButton:SetScale(currentAuraSize)
    end

    -- Define the parameters for your grid system
    local maxAurasPerRow = BuffFrame.AuraContainer.iconStride
    local auraSpacingX = BuffFrame.AuraContainer.iconPadding - 7 + playerAuraSpacingX
    local auraSpacingY = BuffFrame.AuraContainer.iconPadding + 8 + playerAuraSpacingY
    local auraSize = 32;      -- Set the size of each aura frame
    --local auraScale = BuffFrame.AuraContainer.iconScale

    local currentRow = 1;
    local currentCol = 1;
    local xOffset = 0;
    local yOffset = 0;
    local hiddenYOffset = -auraSpacingY - auraSize + playerAuraSpacingY;
    local toggleIcon = showHiddenAurasIcon and CreateToggleIcon() or nil

    if isExpanded then
    for auraIndex, auraInfo in ipairs(BuffFrame.auraInfo) do
        --if isExpanded or not auraInfo.hideUnlessExpanded then
            local auraFrame = BuffFrame.auraFrames[auraIndex]
            if auraFrame and not auraFrame.isAuraAnchor then

                local name, icon, count, dispelType, duration, expirationTime, source,
                    isStealable, nameplateShowPersonal, spellId, canApplyAura,
                    isBossDebuff, castByPlayer, nameplateShowAll, timeMod

                local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID

                if auraInfo.auraType == "TempEnchant" then
                    hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID = GetWeaponEnchantInfo()
                    if mainHandEnchantID then
                        spellId = mainHandEnchantID
                        name = "Temp Enchant"
                    elseif offHandEnchantID then
                        spellId = offHandEnchantID
                        name = "Temp Enchant"
                    end
                else
                    name, icon, count, dispelType, duration, expirationTime, source,
                    isStealable, nameplateShowPersonal, spellId, canApplyAura,
                    isBossDebuff, castByPlayer, nameplateShowAll, timeMod
                    = UnitAura("player", auraInfo.index, 'HELPFUL');
                end

              local auraData = {
                  name = name,
                  --icon = icon,
                  --count = count,
                  --dispelType = dispelType,
                  --duration = duration,
                  --expirationTime = expirationTime,
                  --sourceUnit = source,
                  --isStealable = isStealable,
                  --nameplateShowPersonal = nameplateShowPersonal,
                  spellId = spellId,
                  auraType = "Buff",
              };
                --local unit = self.unit
                -- Print spell ID logic
                if printAuraSpellIds then
                    if not auraFrame.bbfHookAdded then
                        auraFrame.bbfHookAdded = true
                        auraFrame:HookScript("OnEnter", function()
                            if printAuraSpellIds then
                                local currentAuraIndex = auraInfo.index
                                if auraInfo.auraType == "TempEnchant" then
                                    hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID = GetWeaponEnchantInfo()
                                    if mainHandEnchantID then
                                        spellId = mainHandEnchantID
                                        name = "Temp Enchant Mainhand"
                                    elseif offHandEnchantID then
                                        spellId = offHandEnchantID
                                        name = "Temp Enchant Offhand"
                                    end
                                else
                                    name, icon, count, dispelType, duration, expirationTime, source,
                                    isStealable, nameplateShowPersonal, spellId, canApplyAura,
                                    isBossDebuff, castByPlayer, nameplateShowAll, timeMod
                                    = UnitAura("player", currentAuraIndex, 'HELPFUL');
                                end

                                auraData = {
                                    name = name,
                                    icon = icon,
                                    count = count,
                                    dispelType = dispelType,
                                    duration = duration,
                                    expirationTime = expirationTime,
                                    sourceUnit = source,
                                    isStealable = isStealable,
                                    nameplateShowPersonal = nameplateShowPersonal,
                                    spellId = spellId,
                                    auraType = auraInfo.auraType,
                                };

                                if auraData and (not auraFrame.bbfPrinted or auraFrame.bbfLastPrintedAuraIndex ~= currentAuraIndex) then
                                    local iconTexture = auraData.icon and "|T" .. auraData.icon .. ":16:16|t" or ""
                                    print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconTexture .. " " .. (auraData.name or "Unknown") .. "  |A:worldquest-icon-engineering:14:14|a ID: " .. (auraData.spellId or "Unknown"))
                                    auraFrame.bbfPrinted = true
                                    auraFrame.bbfLastPrintedAuraIndex = currentAuraIndex  -- Store the index of the aura that was just printed
                                    -- Cancel existing timer if any
                                    if auraFrame.bbfTimer then
                                        auraFrame.bbfTimer:Cancel()
                                    end
                                    -- Schedule the reset of bbfPrinted flag
                                    auraFrame.bbfTimer = C_Timer.NewTimer(6, function()
                                        auraFrame.bbfPrinted = false
                                    end)
                                end
                            end
                        end)
                    end
                end

                local shouldShowAura, isImportant, isPandemic, isEnlarged, isCompacted, auraColor
                shouldShowAura, isImportant, isPandemic, isEnlarged, isCompacted, auraColor = ShouldShowBuff("player", auraData, "playerBuffFrame")
                isImportant = isImportant and playerAuraImportantGlow
                -- Nonprint logic
                if shouldShowAura then
                    auraFrame.Duration:SetDrawLayer("OVERLAY", 7)
                    auraFrame:Show();
                    auraFrame:ClearAllPoints();
                    if addIconsToRight then
                        auraFrame:SetPoint("TOPLEFT", BuffFrame, "TOPLEFT", xOffset + 15, -yOffset);
                    else
                        auraFrame:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", -xOffset - 15, -yOffset);
                    end

                    auraFrame.spellId = auraData.spellId

                    if not auraFrame.filterClick then
                        auraFrame:HookScript("OnMouseDown", function(self, button)
                            if IsShiftKeyDown() and IsAltKeyDown() then
                                local spellName, _, icon = GetSpellInfo(auraFrame.spellId)
                                local spellId = tostring(auraFrame.spellId)
                                local iconString = "|T" .. icon .. ":16:16:0:0|t" -- Format the icon for display

                                if button == "LeftButton" then
                                    BBF.auraWhitelist(auraFrame.spellId)
                                    print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconString .. " " .. spellName .. " (" .. spellId .. ") was added to |cff00ff00whitelist|r.")
                                elseif button == "RightButton" then
                                    BBF.auraBlacklist(auraFrame.spellId)
                                    print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconString .. " " .. spellName .. " (" .. spellId .. ") was added to |cffff0000blacklist|r.")
                                end
                            end
                        end)
                        auraFrame.filterClick = true
                    end

                    -- Update column and row counters
                    currentCol = currentCol + 1;
                    if currentCol > maxAurasPerRow then
                        currentRow = currentRow + 1;
                        currentCol = 1;
                    end
                    -- Calculate the new offsets
                    xOffset = (currentCol - 1) * (auraSize + auraSpacingX);
                    yOffset = (currentRow - 1) * (auraSize + auraSpacingY);
                    auraFrame.isAuraHidden = false

                    -- Important logic
                    if isImportant then
                        local borderFrame = BBF.auraBorders[auraFrame]
                        auraFrame.isImportant = true
                        if not auraFrame.ImportantGlow then
                            auraFrame.ImportantGlow = auraFrame:CreateTexture(nil, "OVERLAY")
                            if borderFrame then
                                auraFrame.ImportantGlow:SetParent(borderFrame)
                                auraFrame.ImportantGlow:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", -15, 16)
                                auraFrame.ImportantGlow:SetPoint("BOTTOMRIGHT", auraFrame, "BOTTOMRIGHT", 15, -6)
                            else
                                auraFrame.ImportantGlow:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", -14, 13)
                                auraFrame.ImportantGlow:SetPoint("BOTTOMRIGHT", auraFrame, "BOTTOMRIGHT", 13, -3)
                            end
                            --auraFrame.ImportantGlow:SetDrawLayer("OVERLAY", 7)
                            auraFrame.ImportantGlow:SetAtlas("newplayertutorial-drag-slotgreen")
                            auraFrame.ImportantGlow:SetDesaturated(true)
                        end
                        if borderFrame then
                            auraFrame.ImportantGlow:SetParent(borderFrame)
                        end
                        if auraColor then
                            auraFrame.ImportantGlow:SetVertexColor(auraColor.r, auraColor.g, auraColor.b, auraColor.a)
                        else
                            auraFrame.ImportantGlow:SetVertexColor(0, 1, 0)
                        end
                        auraFrame.ImportantGlow:Show()
                    else
                        auraFrame.isImportant = false
                        if auraFrame.ImportantGlow then
                            auraFrame.ImportantGlow:Hide()
                        end
                    end
                else
                    hiddenAuras = hiddenAuras + 1
                    if not shouldKeepAurasVisible then
                        auraFrame:Hide()
                        auraFrame.isAuraHidden = true
                    end
                    auraFrame:ClearAllPoints()
                    if toggleIcon then
                        auraFrame:SetPoint("TOP", ToggleHiddenAurasButton, "TOP", 0, hiddenYOffset + 10)
                        --auraFrame:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", -auraSize - auraSpacingX + 60, hiddenYOffset)
                    end
                    hiddenYOffset = hiddenYOffset - auraSize - auraSpacingY + 10
                end
            end
        end
    end
    UpdateHiddenAurasCount()
end

--local tooltip = CreateFrame("GameTooltip", "AuraTooltip", nil, "GameTooltipTemplate")
--tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
local DebuffFrame = DebuffFrame
local function PersonalDebuffFrameFilterAndGrid(self)
    local maxAurasPerRow = DebuffFrame.AuraContainer.iconStride
    local auraSpacingX = DebuffFrame.AuraContainer.iconPadding - 7 + playerAuraSpacingX
    local auraSpacingY = DebuffFrame.AuraContainer.iconPadding + 8 + playerAuraSpacingY
    local auraSize = 32;      -- Set the size of each aura frame

    --local dotChecker = BetterBlizzFramesDB.debuffDotChecker
    local printAuraIds = printAuraSpellIds

    local currentRow = 1;
    local currentCol = 1;
    local xOffset = 0;
    local yOffset = 0;

    -- Create a texture next to the DebuffFrame
--[=[
    local warningTexture
    if dotChecker then
        if not DebuffFrame.warningTexture then
            warningTexture = DebuffFrame:CreateTexture(nil, "OVERLAY")
            warningTexture:SetPoint("TOPLEFT", DebuffFrame, "TOPRIGHT", 4, -2)
            warningTexture:SetSize(32, 32)
            warningTexture:SetAtlas("poisons")
            warningTexture:Hide()
            DebuffFrame.warningTexture = warningTexture
        else
            warningTexture = DebuffFrame.warningTexture
        end
        warningTexture:EnableMouse(true)
        warningTexture:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("BetterBlizzFrames\nDoT Detected", 1, 1, 1)
            GameTooltip:Show()
        end)

        warningTexture:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        warningTexture:SetMouseClickEnabled(false)
    end

    local keywordFound = false
    local keywords = {"over", "every",}

]=]


    for auraIndex, auraInfo in ipairs(DebuffFrame.auraInfo) do
        --if isExpanded or not auraInfo.hideUnlessExpanded then
            local auraFrame = DebuffFrame.auraFrames[auraIndex]
            if auraFrame and not auraFrame.isAuraAnchor then
--[[
                if auraInfo then
                    print("Aura Data:")
                    for k, v in pairs(auraInfo) do
                        print(k, v)
                    end
                else
                    print("No aura data available.")
                end
]]
                --local spellID = select(10, UnitAura("player", auraInfo.index));
                --if ShouldHideSpell(spellID) then
                    local name, icon, count, dispelType, duration, expirationTime, source, 
                    isStealable, nameplateShowPersonal, spellId, canApplyAura, 
                    isBossDebuff, castByPlayer, nameplateShowAll, timeMod 
                  = UnitAura("player", auraInfo.index, 'HARMFUL');

              local auraData = {
                  name = name,
                  icon = icon,
                  count = count,
                  dispelType = dispelType,
                  duration = duration,
                  expirationTime = expirationTime,
                  sourceUnit = source,
                  isStealable = isStealable,
                  nameplateShowPersonal = nameplateShowPersonal,
                  spellId = spellId,
                  auraType = auraInfo.auraType,
              };
                --local unit = self.unit
                if printAuraIds and not auraFrame.bbfHookAdded then
                    auraFrame.bbfHookAdded = true
                    auraFrame:HookScript("OnEnter", function()
                        if printAuraIds then
                            local currentAuraIndex = auraInfo.index
                            local name, icon, count, dispelType, duration, expirationTime, source, 
                            isStealable, nameplateShowPersonal, spellId, canApplyAura, 
                            isBossDebuff, castByPlayer, nameplateShowAll, timeMod 
                            = UnitAura("player", currentAuraIndex, 'HARMFUL');

                            local auraData = {
                                name = name,
                                icon = icon,
                                count = count,
                                dispelType = dispelType,
                                duration = duration,
                                expirationTime = expirationTime,
                                sourceUnit = source,
                                isStealable = isStealable,
                                nameplateShowPersonal = nameplateShowPersonal,
                                spellId = spellId,
                                auraType = auraInfo.auraType,
                            };

                            if auraData and (not auraFrame.bbfPrinted or auraFrame.bbfLastPrintedAuraIndex ~= currentAuraIndex) then
                                local iconTexture = auraData.icon and "|T" .. auraData.icon .. ":16:16|t" or ""
                                print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconTexture .. " " .. (auraData.name or "Unknown") .. "  |A:worldquest-icon-engineering:14:14|a ID: " .. (auraData.spellId or "Unknown"))
                                auraFrame.bbfPrinted = true
                                auraFrame.bbfLastPrintedAuraIndex = currentAuraIndex
                                -- Cancel existing timer if any
                                if auraFrame.bbfTimer then
                                    auraFrame.bbfTimer:Cancel()
                                end
                                -- Schedule the reset of bbfPrinted flag
                                auraFrame.bbfTimer = C_Timer.NewTimer(6, function()
                                    auraFrame.bbfPrinted = false
                                end)
                            end
                        end
                    end)
                end
                local shouldShowAura, isImportant, isPandemic, isEnlarged, isCompacted, auraColor = ShouldShowBuff("player", auraData, "playerDebuffFrame")
                if shouldShowAura then
                    -- Check the tooltip for specified keywords
--[=[
                    tooltip:ClearLines()
                    tooltip:SetHyperlink("spell:" .. auraData.spellId)

                    local tooltipText = ""
                    for i = 1, tooltip:NumLines() do
                        local line = _G["AuraTooltipTextLeft" .. i]
                        tooltipText = tooltipText .. line:GetText()
                    end

                    for _, keyword in ipairs(keywords) do
                        if string.find(tooltipText:lower(), keyword) then
                            keywordFound = true
                            break
                        end
                    end

]=]

                    auraFrame.spellId = auraData.spellId

                    if not auraFrame.filterClick then
                        auraFrame:HookScript("OnMouseDown", function(self, button)
                            if IsShiftKeyDown() and IsAltKeyDown() then
                                local spellName, _, icon = GetSpellInfo(auraFrame.spellId)
                                local spellId = tostring(auraFrame.spellId)
                                local iconString = "|T" .. icon .. ":16:16:0:0|t" -- Format the icon for display

                                if button == "LeftButton" then
                                    BBF.auraWhitelist(auraFrame.spellId)
                                    print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconString .. " " .. spellName .. " (" .. spellId .. ") was added to |cff00ff00whitelist|r.")
                                elseif button == "RightButton" then
                                    BBF.auraBlacklist(auraFrame.spellId)
                                    print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconString .. " " .. spellName .. " (" .. spellId .. ") was added to |cffff0000blacklist|r.")
                                end
                            end
                        end)
                        auraFrame.filterClick = true
                    end

                    auraFrame:Show();
                    auraFrame:ClearAllPoints();
                    auraFrame:SetPoint("TOPRIGHT", DebuffFrame, "TOPRIGHT", -xOffset, -yOffset);
                    --print(auraFrame:GetSize())

                    -- Update column and row counters
                    currentCol = currentCol + 1;
                    if currentCol > maxAurasPerRow then
                        currentRow = currentRow + 1;
                        currentCol = 1;
                    end

                    -- Calculate the new offsets
                    xOffset = (currentCol - 1) * (auraSize + auraSpacingX);
                    yOffset = (currentRow - 1) * (auraSize + auraSpacingY);

                    -- Important logic
                    if isImportant then
                        local borderFrame = BBF.auraBorders[auraFrame]
                        auraFrame.isImportant = true
                        if not auraFrame.ImportantGlow then
                            auraFrame.ImportantGlow = auraFrame:CreateTexture(nil, "OVERLAY")
                            if borderFrame then
                                auraFrame.ImportantGlow:SetParent(borderFrame)
                                auraFrame.ImportantGlow:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", -15, 16)
                                auraFrame.ImportantGlow:SetPoint("BOTTOMRIGHT", auraFrame, "BOTTOMRIGHT", 15, -6)
                            else
                                auraFrame.ImportantGlow:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", -14, 13)
                                auraFrame.ImportantGlow:SetPoint("BOTTOMRIGHT", auraFrame, "BOTTOMRIGHT", 13, -3)
                            end
                            --auraFrame.ImportantGlow:SetDrawLayer("OVERLAY", 7)
                            auraFrame.ImportantGlow:SetAtlas("newplayertutorial-drag-slotgreen")
                            auraFrame.ImportantGlow:SetDesaturated(true)
                        end
                        if borderFrame then
                            auraFrame.ImportantGlow:SetParent(borderFrame)
                        end
                        if auraColor then
                            auraFrame.ImportantGlow:SetVertexColor(auraColor.r, auraColor.g, auraColor.b, auraColor.a)
                        else
                            auraFrame.ImportantGlow:SetVertexColor(0, 1, 0)
                        end
                        auraFrame.ImportantGlow:Show()
                    else
                        auraFrame.isImportant = false
                        if auraFrame.ImportantGlow then
                            auraFrame.ImportantGlow:Hide()
                        end
                    end
                else
                    auraFrame:Hide();
                end
            end
        --end
    end
--[=[
    if dotChecker then
        if keywordFound then
            warningTexture:Show()
        else
            warningTexture:Hide()
        end
    end
]=]
end

local auraMsgSent = false
function BBF.RefreshAllAuraFrames()
    BBF.UpdateUserAuraSettings()
    if BetterBlizzFramesDB.playerAuraFiltering then
        PersonalBuffFrameFilterAndGrid(BuffFrame)
        PersonalDebuffFrameFilterAndGrid(DebuffFrame)
        AdjustAuras(TargetFrame, "target")
        AdjustAuras(FocusFrame, "focus")
    else
        if not auraMsgSent then
            auraMsgSent = true
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: You need to enable aura settings for blacklist and whitelist etc to work.")
            C_Timer.After(9, function()
                auraMsgSent = false
            end)
        end
    end
end

function BBF.HookPlayerAndTargetAuras()
    --Hook Player BuffFrame
    if playerBuffFilterOn and not playerBuffsHooked then
        hooksecurefunc(BuffFrame, "UpdateAuraButtons", PersonalBuffFrameFilterAndGrid)
        playerBuffsHooked = true
    end

    --Hook Player DebuffFrame
    if playerDebuffFilterOn and not playerDebuffsHooked then
        hooksecurefunc(DebuffFrame, "UpdateAuraButtons", PersonalDebuffFrameFilterAndGrid)
        playerDebuffsHooked = true
    end

    --Hook Target & Focus Frame
    if auraFilteringOn and not targetAurasHooked then
        hooksecurefunc(TargetFrame, "UpdateAuras", function(self) AdjustAuras(self, "target") end)
        hooksecurefunc(FocusFrame, "UpdateAuras", function(self) AdjustAuras(self, "focus") end)
        targetAurasHooked = true
    end

    --Hook Target & Focus Castbars
    if not targetCastbarsHooked then
        hooksecurefunc(TargetFrame.spellbar, "SetPoint", function()
            if shouldAdjustCastbar then
                adjustCastbar(TargetFrame.spellbar, TargetFrameSpellBar)
            else
                DefaultCastbarAdjustment(TargetFrame.spellbar, TargetFrameSpellBar)
            end
        end);
        hooksecurefunc(FocusFrame.spellbar, "SetPoint", function()
            if shouldAdjustCastbarFocus then
                adjustCastbar(FocusFrame.spellbar, FocusFrameSpellBar)
            else
                DefaultCastbarAdjustment(FocusFrame.spellbar, FocusFrameSpellBar)
            end
        end);
    end
end