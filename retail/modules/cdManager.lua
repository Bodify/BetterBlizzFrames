local cdManagerFrames = {
    EssentialCooldownViewer,
    UtilityCooldownViewer,
    BuffIconCooldownViewer,
    BuffBarCooldownViewer,
}

-- Essential = 0
-- Utility = 1
-- BuffIcon = 2
-- BuffBar = 3

function BBF.RefreshCooldownManagerIcons()
    for _, frame in ipairs(cdManagerFrames) do
        BBF.SortCooldownManagerIcons(frame)
    end
end

function BBF.SortCooldownManagerIcons(frame, center)
    if not frame or not frame.GetItemFrames then return end

    local sorting = BetterBlizzFramesDB.cdManagerSorting
    local centering = BetterBlizzFramesDB.cdManagerCenterIcons

    -- If neither setting is enabled, do nothing
    if not sorting and not centering then return end

    local icons = frame:GetItemFrames()
    if not icons or #icons == 0 then return end

    local iconPadding = frame.iconPadding or 5
    local iconWidth = icons[1] and icons[1]:GetWidth() or 32
    local iconHeight = icons[1] and icons[1]:GetHeight() or 32
    local rowLimit = (frame == BuffIconCooldownViewer and frame.stride) or frame.iconLimit or 8

    if sorting then
        local sortedIcons = {}

        for i, icon in ipairs(icons) do
            local spellID = icon.GetSpellID and icon:GetSpellID()
            if spellID and not BetterBlizzFramesDB.cdManagerBlacklist[spellID] then
                table.insert(sortedIcons, {
                    frame = icon,
                    spellID = spellID,
                    priority = BetterBlizzFramesDB.cdManagerPriorityList[spellID] or 0,
                    originalIndex = i,
                })
            else
                icon:Hide()
            end
        end

        -- Sort by priority, fallback to original order
        table.sort(sortedIcons, function(a, b)
            if a.priority ~= b.priority then
                return a.priority > b.priority
            end
            return a.originalIndex < b.originalIndex
        end)

        for i, data in ipairs(sortedIcons) do
            local icon = data.frame
            icon:ClearAllPoints()
            icon:Show()

            local row = math.floor((i - 1) / rowLimit)
            local col = (i - 1) % rowLimit

            local x = col * (iconWidth + iconPadding)
            local y = -row * (iconHeight + iconPadding)

            icon:SetPoint("TOPLEFT", frame:GetItemContainerFrame(), "TOPLEFT", x, y)
        end

        if center and centering and #sortedIcons > rowLimit then
            local totalIcons = #sortedIcons
            local lastRowCount = totalIcons % rowLimit
            if lastRowCount > 0 then
                local rowWidth = (iconWidth * lastRowCount) + (iconPadding * (lastRowCount - 1))
                local fullRowWidth = (iconWidth * rowLimit) + (iconPadding * (rowLimit - 1))
                local shiftX = (fullRowWidth - rowWidth) / 2

                for i = totalIcons - lastRowCount + 1, totalIcons do
                    local icon = sortedIcons[i].frame
                    if icon and icon:IsShown() then
                        local point, relativeTo, relativePoint, x, y = icon:GetPoint()
                        icon:SetPoint(point, relativeTo, relativePoint, x + shiftX, y)
                    end
                end
            end
        end
    elseif center and centering then
        -- No sorting, only centering
        local totalIcons = #icons
        local iconsPerRow = rowLimit
        if totalIcons <= iconsPerRow then return end

        local lastRowCount = totalIcons % iconsPerRow
        if lastRowCount == 0 then return end

        local rowWidth = (iconWidth * lastRowCount) + (iconPadding * (lastRowCount - 1))
        local fullRowWidth = (iconWidth * iconsPerRow) + (iconPadding * (iconsPerRow - 1))
        local shiftX = (fullRowWidth - rowWidth) / 2

        for i = totalIcons - lastRowCount + 1, totalIcons do
            local icon = icons[i]
            if icon and icon:IsShown() then
                local point, relativeTo, relativePoint, x, y = icon:GetPoint()
                icon:SetPoint(point, relativeTo, relativePoint, x + shiftX, y)
            end
        end
    end
end


function BBF.UpdateCooldownManagerSpellList(bypass)
    if SettingsPanel:IsShown() or bypass then
        local categories = {
            Enum.CooldownViewerCategory.Essential,
            Enum.CooldownViewerCategory.Utility,
            --Enum.CooldownViewerCategory.BuffIcons,
            --Enum.CooldownViewerCategory.BuffBars,
        }

        local seen = {}
        BBF.cooldownManagerSpells = {}

        for _, category in ipairs(categories) do
            local entries = C_CooldownViewer.GetCooldownViewerCategorySet(category)
            for _, id in ipairs(entries or {}) do
                local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(id)
                if info and info.spellID and not seen[info.spellID] then
                    seen[info.spellID] = true
                    table.insert(BBF.cooldownManagerSpells, info.spellID)
                end
            end
        end

        table.sort(BBF.cooldownManagerSpells, function(a, b)
            local pa = BetterBlizzFramesDB.cdManagerPriorityList[a] or 0
            local pb = BetterBlizzFramesDB.cdManagerPriorityList[b] or 0
            return pa > pb
        end)
        BBF.cdManagerNeedsUpdate = nil
    else
        BBF.cdManagerNeedsUpdate = true
    end
end

function BBF.HookCooldownManagerTweaks()
    local cdTweaksEnabled = BetterBlizzFramesDB.cdManagerCenterIcons or BetterBlizzFramesDB.cdManagerSorting
    if not cdTweaksEnabled then return end

    for _, frame in ipairs(cdManagerFrames) do
        if frame and frame.RefreshLayout then

            -- Override Cooldown Sorting
            if cdTweaksEnabled and not frame.bbfSortingHooked then
                local container = frame:GetItemContainerFrame()
                local center = frame == EssentialCooldownViewer or frame == UtilityCooldownViewer
                hooksecurefunc(container, "Layout", function()
                    BBF.SortCooldownManagerIcons(frame, center)
                end)
                frame.bbfSortingHooked = true
            end

        end
    end

    BBF.RefreshCooldownManagerIcons()

    if not BBF.CDManagerTweaks then
        BBF.CDManagerTweaks = CreateFrame("Frame")
        BBF.CDManagerTweaks:RegisterEvent("SPELLS_CHANGED")
        BBF.CDManagerTweaks:SetScript("OnEvent", function()
            if InCombatLockdown() then return end
            BBF.RefreshCooldownManagerIcons()
            BBF.UpdateCooldownManagerSpellList()
        end)

        SettingsPanel:HookScript("OnShow", function()
            if BBF.cdManagerNeedsUpdate and BBF.RefreshCdManagerList then
                BBF.RefreshCdManagerList()
            end
        end)
    end
end