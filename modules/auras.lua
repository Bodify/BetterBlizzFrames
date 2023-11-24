BetterBlizzFramesDB = BetterBlizzFramesDB or {}
BBF = BBF or {}

local function sum(t)
    local sum = 0
    for k,v in pairs(t) do
        sum = sum + v
    end
    return sum
end

local BlizzardShouldShowDebuffs = TargetFrame.ShouldShowDebuffs

local ipairs = ipairs
local math_ceil = math.ceil
local table_insert = table.insert
local table_sort = table.sort
local math_max = math.max
local print = print

function BBF.isInWhitelist(spellName, spellId)
    for _, entry in pairs(BetterBlizzFramesDB["auraWhitelist"]) do
        if (entry.name and spellName and string.lower(entry.name) == string.lower(spellName)) or entry.id == spellId then
            return true
        end
    end
    return false
end

function BBF.isInBlacklist(spellName, spellId)
    for _, entry in pairs(BetterBlizzFramesDB["auraBlacklist"]) do
        if (entry.name and spellName and string.lower(entry.name) == string.lower(spellName)) or entry.id == spellId then
            return true
        end
    end
    return false
end

function BBF.isAuraImportant(spellName, spellId)
    for _, entry in pairs(BetterBlizzFramesDB["auraWhitelist"]) do
        if (entry.name and spellName and string.lower(entry.name) == string.lower(spellName)) or entry.id == spellId then
            if entry.flags and entry.flags.important then
                return true
            end
        end
    end
    return false
end

function BBF.getAuraDetails(spellName, spellId)
    for _, entry in pairs(BetterBlizzFramesDB["auraWhitelist"]) do
        if (entry.name and spellName and string.lower(entry.name) == string.lower(spellName)) or entry.id == spellId then
            local isImportant = entry.flags and entry.flags.important or false
            local isPandemic = entry.flags and entry.flags.pandemic or false
            return true, isImportant, isPandemic
        end
    end
    return false, false, false
end

function BBF.ShouldShowBuff(unit, auraData, frameType)
    local spellName = auraData.name
    local spellId = auraData.spellId
    local duration = auraData.duration
    local expirationTime = auraData.expirationTime
    local caster = auraData.sourceUnit
    local isPurgeable = auraData.isStealable

    -- TargetFrame
    if frameType == "target" then
        -- Buffs
        if BetterBlizzFramesDB["targetBuffEnable"] and auraData.isHelpful then
            local isTargetFriendly = UnitIsFriend("target", "player")
            local isInWhitelist, isImportant, isPandemic = BBF.getAuraDetails(spellName, spellId)
            local filterWatchlist = BetterBlizzFramesDB["targetBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzFramesDB["targetBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)
            local filterPurgeable = BetterBlizzFramesDB["targetBuffFilterPurgeable"] and isPurgeable
            local filterOnlyMe = BetterBlizzFramesDB["targetBuffFilterOnlyMe"] and isTargetFriendly and (caster == "player" or (caster == "pet" and UnitIsUnit(caster, "pet")))
            if BBF.isInBlacklist(spellName, spellId) then return end
            if filterWatchlist or filterLessMinite or filterPurgeable or filterOnlyMe or isImportant or isPandemic then return true, isImportant, isPandemic end
            if not BetterBlizzFramesDB["targetBuffFilterLessMinite"] and not BetterBlizzFramesDB["targetBuffFilterWatchList"] and not BetterBlizzFramesDB["targetBuffFilterPurgeable"] and not (BetterBlizzFramesDB["targetBuffFilterOnlyMe"] and isTargetFriendly) then
                return true
            end
        end
        -- Debuffs
        if BetterBlizzFramesDB["targetdeBuffEnable"] and auraData.isHarmful then
            local isInWhitelist, isImportant, isPandemic = BBF.getAuraDetails(spellName, spellId)
            local filterWatchlist = BetterBlizzFramesDB["targetdeBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzFramesDB["targetdeBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)
            local filterBlizzard = BetterBlizzFramesDB["targetdeBuffFilterBlizzard"] and BlizzardShouldShowDebuffs
            local filterOnlyMe = BetterBlizzFramesDB["targetdeBuffFilterOnlyMe"] and (caster == "player" or (caster == "pet" and UnitIsUnit(caster, "pet")))
            if BBF.isInBlacklist(spellName, spellId) then return end
            if filterWatchlist or filterLessMinite or filterBlizzard or filterOnlyMe or isImportant or isPandemic then return true, isImportant, isPandemic end
            if not BetterBlizzFramesDB["targetdeBuffFilterLessMinite"] and not BetterBlizzFramesDB["targetdeBuffFilterWatchList"] and not BetterBlizzFramesDB["targetdeBuffFilterBlizzard"] and not BetterBlizzFramesDB["targetdeBuffFilterOnlyMe"] then
                return true
            end
        end
    -- FocusFrame
    elseif frameType == "focus" then
        -- Buffs
        if BetterBlizzFramesDB["focusBuffEnable"] and auraData.isHelpful then
            local isInWhitelist, isImportant, isPandemic = BBF.getAuraDetails(spellName, spellId)
            local isTargetFriendly = UnitIsFriend("focus", "player")
            local filterWatchlist = BetterBlizzFramesDB["focusBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzFramesDB["focusBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)
            local filterPurgeable = BetterBlizzFramesDB["focusBuffFilterPurgeable"] and isPurgeable
            local filterOnlyMe = BetterBlizzFramesDB["focusBuffFilterOnlyMe"] and isTargetFriendly and (caster == "player" or (caster == "pet" and UnitIsUnit(caster, "pet")))
            if BBF.isInBlacklist(spellName, spellId) then return end
            if filterWatchlist or filterLessMinite or filterPurgeable or filterOnlyMe or isImportant or isPandemic then return true, isImportant, isPandemic end
            if not BetterBlizzFramesDB["focusBuffFilterLessMinite"] and not BetterBlizzFramesDB["focusBuffFilterWatchList"] and not BetterBlizzFramesDB["focusBuffFilterPurgeable"] and not BetterBlizzFramesDB["focusBuffFilterOnlyMe"] then
                return true
            end
        end
        -- Debuffs
        if BetterBlizzFramesDB["focusdeBuffEnable"] and auraData.isHarmful then
            local isInWhitelist, isImportant, isPandemic = BBF.getAuraDetails(spellName, spellId)
            local filterWatchlist = BetterBlizzFramesDB["focusdeBuffFilterWatchList"] and isInWhitelist
            local filterLessMinite = BetterBlizzFramesDB["focusdeBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)
            local filterBlizzard = BetterBlizzFramesDB["focusdeBuffFilterBlizzard"] and BlizzardShouldShowDebuffs
            local filterOnlyMe = BetterBlizzFramesDB["focusdeBuffFilterOnlyMe"] and (caster == "player" or (caster == "pet" and UnitIsUnit(caster, "pet")))
            if BBF.isInBlacklist(spellName, spellId) then return end
            if filterWatchlist or filterLessMinite or filterBlizzard or filterOnlyMe or isImportant or isPandemic then return true, isImportant, isPandemic end
            if not BetterBlizzFramesDB["focusdeBuffFilterLessMinite"] and not BetterBlizzFramesDB["focusdeBuffFilterWatchList"] and not BetterBlizzFramesDB["focusdeBuffFilterBlizzard"] and not BetterBlizzFramesDB["focusdeBuffFilterOnlyMe"] then
                return true
            end
        end
    -- Player Buffs and Debuffs
    else
        if frameType == "playerBuffFrame" then
            -- Buffs
            if BetterBlizzFramesDB["PlayerAuraFrameBuffEnable"] and (auraData.auraType == "Buff" or auraData.auraType == "TempEnchant") then
                local isInWhitelist, isImportant, isPandemic = BBF.getAuraDetails(spellName, spellId)
                local filterWatchlist = BetterBlizzFramesDB["PlayerAuraFrameBuffFilterWatchList"] and isInWhitelist
                local filterLessMinite = BetterBlizzFramesDB["PlayerAuraFrameBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)
                if BBF.isInBlacklist(spellName, spellId) then return end
                if filterWatchlist or filterLessMinite or isImportant then return true, isImportant, isPandemic end
                if not BetterBlizzFramesDB["PlayerAuraFrameBuffFilterLessMinite"] and not BetterBlizzFramesDB["PlayerAuraFrameBuffFilterWatchList"] then
                    return true
                end
            end
        else
            -- Debuffs
            if BetterBlizzFramesDB["PlayerAuraFramedeBuffEnable"] and auraData.auraType == "Debuff" then
                local isInWhitelist, isImportant, isPandemic = BBF.getAuraDetails(spellName, spellId)
                local filterWatchlist = BetterBlizzFramesDB["PlayerAuraFramedeBuffFilterWatchList"] and isInWhitelist
                local filterLessMinite = BetterBlizzFramesDB["PlayerAuraFramedeBuffFilterLessMinite"] and (duration < 61 and duration ~= 0 and expirationTime ~= 0)
                if BBF.isInBlacklist(spellName, spellId) then return end
                if filterWatchlist or filterLessMinite or isImportant then return true, isImportant, isPandemic end
                if not BetterBlizzFramesDB["PlayerAuraFramedeBuffFilterLessMinite"] and not BetterBlizzFramesDB["PlayerAuraFramedeBuffFilterWatchList"] then
                    return true
                end
            end
        end
    end
end

local function CalculateAuraRowsYOffset(frame, rowHeights)
    local totalHeight = 0
    for _, height in ipairs(rowHeights) do
        totalHeight = totalHeight + (height * BetterBlizzFramesDB.targetAndFocusAuraScale)  -- Scaling each row height
    end
    return totalHeight + #rowHeights * BetterBlizzFramesDB.targetAndFocusVerticalGap
end

local function adjustCastbar(self, frame)
    local meta = getmetatable(self).__index
    local parent = meta.GetParent(self)
    local rowHeights = parent.rowHeights or {}

    meta.ClearAllPoints(self)
    if frame == "TargetFrame" then
        local totAdjustment = BetterBlizzFramesDB.targetToTCastbarAdjustment
        if BetterBlizzFramesDB.targetStaticCastbar then
            --meta.SetPoint(self, "TOPLEFT", meta.GetParent(self), "BOTTOMLEFT", 43, 110);
            meta.SetPoint(self, "TOPLEFT", parent, "BOTTOMLEFT", 43 + BetterBlizzFramesDB.targetCastBarXPos, -14 + BetterBlizzFramesDB.targetCastBarYPos);
        elseif BetterBlizzFramesDB.targetDetachCastbar then
            meta.SetPoint(self, "CENTER", UIParent, "CENTER", BetterBlizzFramesDB.targetCastBarXPos, BetterBlizzFramesDB.targetCastBarYPos);
        else
            local yOffset = 14 - CalculateAuraRowsYOffset(parent, rowHeights)
            -- Check if totAdjustment is true and the ToT frame is shown
            if totAdjustment and parent.haveToT then
                -- Apply the new logic only when totAdjustment is true
                local minOffset = -40  -- Your minimum offset
                local dynamicOffset = 14 - CalculateAuraRowsYOffset(parent, rowHeights)

                -- Choose the more negative value
                yOffset = min(minOffset, dynamicOffset)
            end
            meta.SetPoint(self, "TOPLEFT", parent, "BOTTOMLEFT", 43 + BetterBlizzFramesDB.targetCastBarXPos, yOffset + BetterBlizzFramesDB.targetCastBarYPos);
        end
    elseif frame == "FocusFrame" then
        local totFocusAdjustment = BetterBlizzFramesDB.focusToTCastbarAdjustment
        if BetterBlizzFramesDB.focusStaticCastbar then
            --meta.SetPoint(self, "TOPLEFT", meta.GetParent(self), "BOTTOMLEFT", 43, 110);
            meta.SetPoint(self, "TOPLEFT", parent, "BOTTOMLEFT", 43 + BetterBlizzFramesDB.focusCastBarXPos, -14 + BetterBlizzFramesDB.focusCastBarYPos);
        elseif BetterBlizzFramesDB.focusDetachCastbar then
            meta.SetPoint(self, "CENTER", UIParent, "CENTER", BetterBlizzFramesDB.focusCastBarXPos, BetterBlizzFramesDB.focusCastBarYPos);
        else
            local yOffset = 14 - CalculateAuraRowsYOffset(parent, rowHeights)
            -- Check if totAdjustment is true and the ToT frame is shown
            if totFocusAdjustment and parent.haveToT then
                -- Apply the new logic only when totAdjustment is true
                local minOffset = -40  -- Your minimum offset
                local dynamicOffset = 14 - CalculateAuraRowsYOffset(parent, rowHeights)

                -- Choose the more negative value
                yOffset = min(minOffset, dynamicOffset)
            end
            meta.SetPoint(self, "TOPLEFT", parent, "BOTTOMLEFT", 43 + BetterBlizzFramesDB.focusCastBarXPos, yOffset + BetterBlizzFramesDB.focusCastBarYPos);
        end
    end
end

local function DefaultCastbarAdjustment(self, frame)
    local meta = getmetatable(self).__index
    local parentFrame = meta.GetParent(self)

	-- If the buffs are on the bottom of the frame, and either:
	--  We have a ToT frame and more than 2 rows of buffs/debuffs.
	--  We have no ToT frame and any rows of buffs/debuffs.
	local useSpellbarAnchor = (not parentFrame.buffsOnTop) and ((parentFrame.haveToT and parentFrame.auraRows > 2) or ((not parentFrame.haveToT) and parentFrame.auraRows > 0));

	local relativeKey = useSpellbarAnchor and parentFrame.spellbarAnchor or parentFrame;
	local pointX = useSpellbarAnchor and 18 or  (parentFrame.smallSize and 38 or 43);
	local pointY = useSpellbarAnchor and -10 or (parentFrame.smallSize and 3 or 5);

    if (not useSpellbarAnchor) and parentFrame.haveToT then
        local isTargetFrame = frame == TargetFrame
        local isFocusFrame = frame == FocusFrame
        local totAdjustment = (isTargetFrame and BetterBlizzFramesDB.targetToTCastbarAdjustment) or (isFocusFrame and BetterBlizzFramesDB.focusToTCastbarAdjustment)

        if totAdjustment then
            pointY = parentFrame.smallSize and -48 or -46
        end
    end


    if frame == TargetFrame then
        local targetCastBarXPos = BetterBlizzFramesDB.targetCastBarXPos
        local targetCastBarYPos = BetterBlizzFramesDB.targetCastBarYPos
        pointX = pointX + targetCastBarXPos
        pointY = pointY + targetCastBarYPos
    elseif frame == FocusFrame then
        local focusCastBarXPos = BetterBlizzFramesDB.focusCastBarXPos
        local focusCastBarYPos = BetterBlizzFramesDB.focusCastBarYPos
        pointX = pointX + focusCastBarXPos
        pointY = pointY + focusCastBarYPos
    end

	meta.SetPoint(self, "TOPLEFT", relativeKey, "BOTTOMLEFT", pointX, pointY);
end

function BBF.CastbarAdjustCaller()
    local shouldAdjustCastbar = BetterBlizzFramesDB.targetStaticCastbar or BetterBlizzFramesDB.targetDetachCastbar or BetterBlizzFramesDB.playerAuraFiltering
    if shouldAdjustCastbar then
        adjustCastbar(TargetFrame.spellbar, TargetFrame)
        adjustCastbar(FocusFrame.spellbar, FocusFrame)
    else
        DefaultCastbarAdjustment(TargetFrame.spellbar, TargetFrame)
        DefaultCastbarAdjustment(FocusFrame.spellbar, FocusFrame)
    end
end

hooksecurefunc(TargetFrame.spellbar, "SetPoint", function()
    local shouldAdjustCastbar = BetterBlizzFramesDB.targetStaticCastbar or BetterBlizzFramesDB.targetDetachCastbar or BetterBlizzFramesDB.playerAuraFiltering
    if shouldAdjustCastbar then
        adjustCastbar(TargetFrame.spellbar, TargetFrame)
    else
        DefaultCastbarAdjustment(TargetFrame.spellbar, TargetFrame)
    end
end);

hooksecurefunc(FocusFrame.spellbar, "SetPoint", function()
    local shouldAdjustCastbar = BetterBlizzFramesDB.focusStaticCastbar or BetterBlizzFramesDB.focusDetachCastbar or BetterBlizzFramesDB.playerAuraFiltering
    if shouldAdjustCastbar then
        adjustCastbar(FocusFrame.spellbar, FocusFrame)
    else
        DefaultCastbarAdjustment(TargetFrame.spellbar, TargetFrame)
    end
end);

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
            elseif remainingDuration <= 5.1 then
                if not aura.PandemicGlow then
                    aura.PandemicGlow = aura:CreateTexture(nil, "OVERLAY");
                    aura.PandemicGlow:SetAtlas("newplayertutorial-drag-slotgreen");
                    aura.PandemicGlow:SetDesaturated(true)
                    aura.PandemicGlow:SetVertexColor(1, 0, 0)
                    if aura.Cooldown then
                        aura.PandemicGlow:SetParent(aura.Cooldown)
                    end
                    aura.PandemicGlow:SetPoint("TOPLEFT", aura, "TOPLEFT", -10, 10);
                    aura.PandemicGlow:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", 10, -10);
                end
                aura.PandemicGlow:Show();
            else
                if aura.PandemicGlow then
                    aura.PandemicGlow:Hide();
                end
            end
        else
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



function BBF.AdjustAuras(self, frameType)
    if not BetterBlizzFramesDB.playerAuraFiltering then return end

    -- Cache commonly used DB values to avoid table lookups
    local db = BetterBlizzFramesDB
    local baseOffsetX = 25 + db.targetAndFocusAuraOffsetX
    local baseOffsetY = 12.5 + db.targetAndFocusAuraOffsetY
    local auraScale = db.targetAndFocusAuraScale

    local auraSpacingX = db.targetAndFocusHorizontalGap
    local auraSpacingY = db.targetAndFocusVerticalGap
    local aurasPerRow = db.targetAndFocusAurasPerRow
    local aurasInShortRow = 3
    local shortRows = 2
    local controlFirstRows = false
    local darkModeOn = (BetterBlizzFramesDB.darkModeUiAura and BetterBlizzFramesDB.darkModeUi)

    local initialOffsetX = (baseOffsetX / auraScale)
    local initialOffsetY = (baseOffsetY / auraScale)

    local shortRowCounter = 0

    local function adjustAuraPosition(auras, yOffset, firstRow)
        local currentYOffset = yOffset + initialOffsetY
        local rowWidths, rowHeights = {}, {}


        for i, aura in ipairs(auras) do
            aura:SetScale(auraScale)
            aura:SetMouseClickEnabled(false)
            local columnIndex, rowIndex

            local effectiveOffsetX = initialOffsetX --+ xOffsetDarkAdjust
            local effectiveOffsetY = initialOffsetY --+ yOffsetDarkAdjust


            if controlFirstRows and firstRow and shortRowCounter < shortRows then
                columnIndex = (i-1) % aurasInShortRow
                rowIndex = math_ceil(i / aurasInShortRow)
                if columnIndex == 0 and i ~= 1 then
                    shortRowCounter = shortRowCounter + 1 -- Increment the counter when a new row starts
                end
            else
                local adjustedIndex = i - (controlFirstRows and firstRow and shortRowCounter * aurasInShortRow or 0)
                columnIndex = (adjustedIndex-1) % aurasPerRow
                rowIndex = math_ceil(adjustedIndex / aurasPerRow) + shortRowCounter
            end

            rowWidths[rowIndex] = rowWidths[rowIndex] or effectiveOffsetX

            if columnIndex == 0 and i ~= 1 then
                local extraSpacing = aura.darkBorder and 0 or 0
                local effectiveSpacingY = auraSpacingY + extraSpacing
                currentYOffset = currentYOffset - (rowHeights[rowIndex-1] or 0) - effectiveSpacingY
            elseif columnIndex ~= 0 then
                local extraSpacing = aura.darkBorder and 0 or 0
                local effectiveSpacingX = auraSpacingX + extraSpacing
                rowWidths[rowIndex] = rowWidths[rowIndex] + effectiveSpacingX
            end

            local offsetX = rowWidths[rowIndex]
            rowHeights[rowIndex] = math_max(aura:GetHeight(), (rowHeights[rowIndex] or 0))
            rowWidths[rowIndex] = offsetX + aura:GetWidth()

            aura:ClearAllPoints()
            aura:SetPoint("TOPLEFT", self, "BOTTOMLEFT", offsetX, currentYOffset + effectiveOffsetY)
        end

        return rowHeights
    end

    local auras = {}
    for aura in self.auraPools:EnumerateActive() do
        local auraData = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, aura.auraInstanceID)
        if auraData then
            --aura.isPandemic = false
            local isLarge = aura:GetWidth() > 20
            local canApply = auraData.canApplyAura or false

            -- Store the properties with the aura for later sorting
            aura.isLarge = isLarge
            aura.canApply = canApply
            local shouldShowAura, isImportant, isPandemic

            if frameType == "target" then
                shouldShowAura, isImportant, isPandemic = BBF.ShouldShowBuff(unit, auraData, "target")
                isImportant = isImportant and BetterBlizzFramesDB.targetImportantAuraGlow
                isPandemic = isPandemic and BetterBlizzFramesDB.targetdeBuffPandemicGlow
            elseif frameType == "focus" then
                shouldShowAura, isImportant, isPandemic = BBF.ShouldShowBuff(unit, auraData, "focus")
                isImportant = isImportant and BetterBlizzFramesDB.focusImportantAuraGlow
                isPandemic = isPandemic and BetterBlizzFramesDB.focusdeBuffPandemicGlow
            end

            if shouldShowAura then
                local printSpellId = BetterBlizzFramesDB.printAuraSpellIds
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

                -- Important logic
                if isImportant then
                    aura.isImportant = true
                    if not aura.ImportantGlow then
                        aura.ImportantGlow = aura:CreateTexture(nil, "OVERLAY")
                        aura.ImportantGlow:SetPoint("TOPLEFT", aura, "TOPLEFT", -10, 10)
                        aura.ImportantGlow:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", 10, -10)
                        aura.ImportantGlow:SetAtlas("newplayertutorial-drag-slotgreen")
                    end
                    if aura.border then
                        aura.border:Hide()
                    end
                    if aura.Border then
                        aura.Border:Hide()
                    end
                    aura.ImportantGlow:Show()
                else
                    if aura.Border then
                        aura.Border:Show()
                    end
                    aura.isImportant = false
                    if aura.ImportantGlow then
                        aura.ImportantGlow:Hide()
                    end
                end

                if (frameType == "target" and auraData.isStealable and BetterBlizzFramesDB.targetBuffPurgeGlow) or
                (frameType == "focus" and auraData.isStealable and BetterBlizzFramesDB.focusBuffPurgeGlow) then
                    if not aura.PurgeGlow then
                        aura.PurgeGlow = aura:CreateTexture(nil, "OVERLAY")
                        if aura.border:IsVisible() then
                            aura.PurgeGlow:SetParent(aura.border)
                        end
                        aura.PurgeGlow:SetPoint("TOPLEFT", aura, "TOPLEFT", -9, 9)
                        aura.PurgeGlow:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", 9, -9)
                        aura.PurgeGlow:SetAtlas("newplayertutorial-drag-slotblue")
                    end
                    if aura.Border then
                        aura.Border:Hide()
                    end
                    if aura.Stealable then
                        aura.Stealable:Hide()
                    end
                    aura.PurgeGlow:Show()
                else
                    if aura.PurgeGlow then
                        if aura.Border then
                            aura.Border:Show()
                        end
                        if aura.Stealable and auraData.isStealable then
                            aura.Stealable:Show()
                        end
                        aura.PurgeGlow:Hide()
                    end
                end


                table_insert(auras, aura)
            else
                aura:Hide()
                if aura.PandemicGlow then
                    aura.PandemicGlow:Hide()
                end
            end
        end
    end

    local function customAuraComparator(a, b)
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

    table_sort(auras, customAuraComparator)

    -- Sorting auras into buffs and debuffs
    local buffs, debuffs = {}, {}
    for _, aura in ipairs(auras) do
        if aura.Border ~= nil then
            table_insert(debuffs, aura)
        else
            table_insert(buffs, aura)
        end
    end

    local unit = self.unit
    local isFriend = unit and UnitIsFriend("player", unit)
    local darkmodeAdjustment = darkModeOn and 0 or 0

    if not isFriend then
        -- Adjust debuffs first for enemy
        self.rowHeights = adjustAuraPosition(debuffs, 0, true)
        local totalDebuffHeight = sum(self.rowHeights)
        --local buffRowHeights = adjustAuraPosition(buffs, -totalDebuffHeight - (auraSpacingY * #self.rowHeights), shortRowCounter < shortRows) -- Then adjust buffs
        local buffRowHeights = adjustAuraPosition(buffs, -totalDebuffHeight - (auraSpacingY * #self.rowHeights) - darkmodeAdjustment, shortRowCounter < shortRows)
        for _, height in ipairs(buffRowHeights) do
            table_insert(self.rowHeights, height)
        end
    else
        -- Adjust buffs first for friendly
        self.rowHeights = adjustAuraPosition(buffs, 0, true)
        local totalBuffHeight = sum(self.rowHeights)
        --local debuffRowHeights = adjustAuraPosition(debuffs, -totalBuffHeight - (auraSpacingY * #self.rowHeights))
        local debuffRowHeights = adjustAuraPosition(debuffs, -totalBuffHeight - (auraSpacingY * #self.rowHeights) - darkmodeAdjustment)
        for _, height in ipairs(debuffRowHeights) do
            table_insert(self.rowHeights, height)
        end
    end

    if frameType == "target" then
        adjustCastbar(TargetFrame.spellbar, TargetFrame)
    elseif frameType == "focus" then
        adjustCastbar(FocusFrame.spellbar, FocusFrame)
    end
end

local hiddenFrame = CreateFrame("Frame")
hiddenFrame:Hide()
local function HideTargetToTDebuffs()
    local hideToTDebuffs = BetterBlizzFramesDB.hideTargetToTDebuffs
    if not hideToTDebuffs then return end
    for i = 1, 4 do
        local targetToTDebuff = _G["TargetFrameToTDebuff" .. i]
        if targetToTDebuff then
            targetToTDebuff:SetParent(hiddenFrame)
            targetToTDebuff:SetAlpha(0)
            targetToTDebuff:Hide()
        end
    end
end

local function HideFocusToTDebuffs()
    if not BetterBlizzFramesDB.hideFocusToTDebuffs then return end
    for i = 1, 4 do
        local focusToTDebuff = _G["FocusFrameToTDebuff" .. i]
        if focusToTDebuff then
            focusToTDebuff:SetParent(hiddenFrame)
            focusToTDebuff:SetAlpha(0)
            focusToTDebuff:Hide()
        end
    end
end

hooksecurefunc(TargetFrame, "UpdateAuras", function(self)
    BBF.AdjustAuras(self, "target")
    HideTargetToTDebuffs()
end)

hooksecurefunc(FocusFrame, "UpdateAuras", function(self)
    BBF.AdjustAuras(self, "focus")
    HideFocusToTDebuffs()
end)


-- Function to create the toggle icon
local toggleIconGlobal = nil
local shouldKeepAurasVisible = false
local hiddenAuras = 0
--local BetterBlizzFramesDB.showHiddenAurasIcon = true

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
    if not BetterBlizzFramesDB.showHiddenAurasIcon then return end
    if toggleIconGlobal then return toggleIconGlobal end
    local toggleIcon = CreateFrame("Button", "ToggleHiddenAurasButton", BuffFrame)
    toggleIcon:SetSize(30, 30)
    local currentAuraSize = BuffFrame.AuraContainer.iconScale
    if currentAuraSize then
        toggleIcon:SetScale(currentAuraSize)
    end
    if BuffFrame.CollapseAndExpandButton then
        toggleIcon:SetPoint("LEFT", BuffFrame.CollapseAndExpandButton, "RIGHT", 0, 0)
    else
        toggleIcon:SetPoint("TOPLEFT", BuffFrame, "TOPRIGHT", 0, -6)
    end

    local Icon = toggleIcon:CreateTexture(nil, "BACKGROUND")
    Icon:SetAllPoints()
    Icon:SetTexture("Interface/Icons/INV_Misc_ShadowEgg")
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

function UpdateHiddenAurasCount()
    if not BetterBlizzFramesDB.showHiddenAurasIcon then
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


function BBF.PersonalBuffFrameFilterAndGrid(self)
    local auraFilterOn = BetterBlizzFramesDB.playerAuraFiltering
    if not auraFilterOn then return end
    ResetHiddenAurasCount()
    local isExpanded = BuffFrame:IsExpanded();
    local nextAuraInfoIndex = 1;
    local currentAuraSize = BuffFrame.AuraContainer.iconScale
        if ToggleHiddenAurasButton then
            ToggleHiddenAurasButton:SetScale(currentAuraSize)
        end

    -- Define the parameters for your grid system
    local maxAurasPerRow = BuffFrame.AuraContainer.iconStride
    local auraSpacingX = BuffFrame.AuraContainer.iconPadding - 7 + BetterBlizzFramesDB.playerAuraSpacingX
    local auraSpacingY = BuffFrame.AuraContainer.iconPadding + 8
    local auraSize = 32;      -- Set the size of each aura frame
    local auraScale = BuffFrame.AuraContainer.iconScale

    local printAuraIds = BetterBlizzFramesDB.printAuraSpellIds

    local currentRow = 1;
    local currentCol = 1;
    local xOffset = 0;
    local yOffset = 0;
    local hiddenYOffset = -auraSpacingY - auraSize;
    local toggleIcon = BetterBlizzFramesDB.showHiddenAurasIcon and CreateToggleIcon() or nil

    for _, auraFrame in ipairs(BuffFrame.auraFrames) do
        if not auraFrame.isAuraAnchor then
            -- Mimic the logic to get the auraInfo from the original method
            local auraInfo;
            while nextAuraInfoIndex <= #BuffFrame.auraInfo do
                local potentialAuraInfo = BuffFrame.auraInfo[nextAuraInfoIndex];
                nextAuraInfoIndex = nextAuraInfoIndex + 1;

                if isExpanded or not potentialAuraInfo.hideUnlessExpanded then
                    auraInfo = potentialAuraInfo;
                    break;
                end
            end

            if auraInfo then
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
                local unit = self.unit
                -- Print spell ID logic
                if printAuraIds and not auraFrame.bbfHookAdded then
                    auraFrame.bbfHookAdded = true
                    auraFrame:HookScript("OnEnter", function()
                        if printAuraIds then
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

                local shouldShowAura, isImportant, isPandemic
                shouldShowAura, isImportant, isPandemic = BBF.ShouldShowBuff(unit, auraData, "playerBuffFrame")
                isImportant = isImportant and BetterBlizzFramesDB.playerAuraImportantGlow
                -- Nonprint logic
                if shouldShowAura then
                    auraFrame:Show();
                    auraFrame:ClearAllPoints();
                    auraFrame:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", -xOffset - 15, -yOffset);
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
                        end
                        if borderFrame then
                            auraFrame.ImportantGlow:SetParent(borderFrame)
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

local tooltip = CreateFrame("GameTooltip", "AuraTooltip", nil, "GameTooltipTemplate")
tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

local scannerTooltip = CreateFrame("GameTooltip", "ScannerTooltip", nil, "GameTooltipTemplate")
scannerTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

function BBF.GetEnchantName(enchantId)
    scannerTooltip:ClearLines()
    -- The enchant link format is: "|cffffd000|Hitem:12345:::::::::::::|h[Enchant Name]|h|r"
    scannerTooltip:SetHyperlink("item:" .. enchantId)
    local enchantName = ScannerTooltipTextLeft1:GetText()
    return enchantName
end

function BBF.PersonalDebuffFrameFilterAndGrid(self)
    local auraFilterOn = BetterBlizzFramesDB.playerAuraFiltering
    if not auraFilterOn then return end
    local nextAuraInfoIndex = 1;

    local maxAurasPerRow = DebuffFrame.AuraContainer.iconStride
    local auraSpacingX = DebuffFrame.AuraContainer.iconPadding - 7 + BetterBlizzFramesDB.playerAuraSpacingX
    local auraSpacingY = DebuffFrame.AuraContainer.iconPadding + 8
    local auraSize = 32;      -- Set the size of each aura frame

    local dotChecker = BetterBlizzFramesDB.debuffDotChecker
    local printAuraIds = BetterBlizzFramesDB.printAuraSpellIds

    local currentRow = 1;
    local currentCol = 1;
    local xOffset = 0;
    local yOffset = 0;

    -- Create a texture next to the DebuffFrame
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

    for _, auraFrame in ipairs(DebuffFrame.auraFrames) do
        if not auraFrame.isAuraAnchor then
            -- Mimic the logic to get the auraInfo from the original method
            local auraInfo;
            while nextAuraInfoIndex <= #DebuffFrame.auraInfo do
                local potentialAuraInfo = DebuffFrame.auraInfo[nextAuraInfoIndex];
                nextAuraInfoIndex = nextAuraInfoIndex + 1;

                if not potentialAuraInfo.hideUnlessExpanded then
                    auraInfo = potentialAuraInfo;
                    break;
                end
            end

            if auraInfo then
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
                local unit = self.unit
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
                if BBF.ShouldShowBuff(unit, auraData, "playerDebuffFrame") then
                    -- Check the tooltip for specified keywords
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
                else
                    if auraFilterOn then
                        auraFrame:Hide();
                    end
                end
            end
        end
    end
    if dotChecker then
        if keywordFound then
            warningTexture:Show()
        else
            warningTexture:Hide()
        end
    end
end

hooksecurefunc(BuffFrame, "UpdateAuraButtons", BBF.PersonalBuffFrameFilterAndGrid)
hooksecurefunc(DebuffFrame, "UpdateAuraButtons", BBF.PersonalDebuffFrameFilterAndGrid)

function BBF.RefreshAllAuraFrames()
    BBF.PersonalBuffFrameFilterAndGrid(BuffFrame)
    BBF.PersonalDebuffFrameFilterAndGrid(DebuffFrame)
    BBF.AdjustAuras(TargetFrame, "target")
    BBF.AdjustAuras(FocusFrame, "focus")
end