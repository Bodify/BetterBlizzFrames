if not BBF.isMidnight then return end

local cdManagerFrames = {
    EssentialCooldownViewer,
    UtilityCooldownViewer,
    BuffIconCooldownViewer,
    BuffBarCooldownViewer,
}

-- Essential = 0
-- Utility  = 1
-- BuffIcon = 2
-- BuffBar  = 3

function BBF.RefreshCooldownManagerIcons()
    for _, frame in ipairs(cdManagerFrames) do
        local center = frame ~= BuffBarCooldownViewer
        BBF.SortCooldownManagerIcons(frame, center)
    end
end

function BBF.SortCooldownManagerIcons(frame, center)
    if not frame or not frame.GetItemFrames then return end

    local centering = BetterBlizzFramesDB.cdManagerCenterIcons
    if not center or not centering then return end

    local icons = frame:GetItemFrames()
    if not icons or #icons == 0 then return end
    local iconPadding = (frame.iconPadding or 5) - 4
    local iconWidth   = icons[1] and icons[1]:GetWidth()  or 32
    local iconHeight  = icons[1] and icons[1]:GetHeight() or 32
    local isBuffIcon  = (frame == BuffIconCooldownViewer)
    local rowLimit    = (isBuffIcon and frame.stride) or frame.iconLimit or 8
    local isVertical  = not frame.isHorizontal
    local goingUp     = frame.layoutFramesGoingUp

    if isVertical then
        if isBuffIcon then
            local activeIcons = {}
            for _, icon in ipairs(icons) do
                if icon:IsShown() and icon:GetAlpha() == 1 then
                    tinsert(activeIcons, icon)
                end
            end

            local activeCount = #activeIcons
            if activeCount == 0 then return end

            local colHeight       = (iconHeight * activeCount) + (iconPadding * (activeCount - 1))
            local containerHeight = (iconHeight * rowLimit)    + (iconPadding * (rowLimit    - 1))
            local startY          = -((containerHeight - colHeight) / 2)

            local container = frame:GetItemContainerFrame()

            for i, icon in ipairs(activeIcons) do
                local idx = goingUp and i or (activeCount - i + 1)
                local y = -((idx - 1) * (iconHeight + iconPadding))
                local x = 0
                icon:ClearAllPoints()
                icon:SetPoint("TOPLEFT", container, "TOPLEFT", x, startY + y)
            end
        else
            local totalIcons  = #icons
            local iconsPerCol = rowLimit

            local isSingleCol  = (totalIcons <= iconsPerCol)
            local lastColCount = totalIcons % iconsPerCol

            local shiftY = 0
            if not isSingleCol and lastColCount > 0 then
                local fullColHeight = (iconHeight * iconsPerCol)  + (iconPadding * (iconsPerCol  - 1))
                local colHeight     = (iconHeight * lastColCount) + (iconPadding * (lastColCount - 1))
                shiftY = (fullColHeight - colHeight) / 2
            end

            for i, icon in ipairs(icons) do
                local origCol = math.floor((i - 1) / rowLimit)
                local row = (i - 1) % rowLimit

                local isOrigLastCol = (origCol == math.floor((totalIcons - 1) / rowLimit))
                local origColSize = (isOrigLastCol and lastColCount > 0) and lastColCount or iconsPerCol
                local col = origCol

                if not goingUp then
                    local totalCols = math.ceil(totalIcons / iconsPerCol)
                    col = (totalCols - 1) - origCol
                    row = (origColSize - 1) - row
                end

                local x = col * (iconWidth + iconPadding)
                local y = -row * (iconHeight + iconPadding)

                if not isSingleCol and isOrigLastCol and lastColCount > 0 then
                    y = y - shiftY
                end

                icon:ClearAllPoints()
                icon:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
            end
        end
        return
    end

    if isBuffIcon then
        local activeIcons = {}
        for _, icon in ipairs(icons) do
            if icon:IsShown() and icon:GetAlpha() == 1 then
                tinsert(activeIcons, icon)
            end
        end

        local activeCount = #activeIcons
        if activeCount == 0 then return end

        local rowWidth       = (iconWidth * activeCount) + (iconPadding * (activeCount - 1))
        local containerWidth = (iconWidth * rowLimit)   + (iconPadding * (rowLimit   - 1))
        local startX         = (containerWidth - rowWidth) / 2

        local container = frame:GetItemContainerFrame()

        for i, icon in ipairs(activeIcons) do
            local x = (i - 1) * (iconWidth + iconPadding)
            local y = 0
            icon:ClearAllPoints()
            icon:SetPoint("TOPLEFT", container, "TOPLEFT", startX + x, y)
        end
    else
        local totalIcons  = #icons
        local iconsPerRow = rowLimit

        local isSingleRow = (totalIcons <= iconsPerRow)
        local lastRowCount = totalIcons % iconsPerRow

        local shiftX = 0
        if not isSingleRow and lastRowCount > 0 then
            local fullRowWidth = (iconWidth * iconsPerRow) + (iconPadding * (iconsPerRow - 1))
            local rowWidth     = (iconWidth * lastRowCount) + (iconPadding * (lastRowCount - 1))
            shiftX = (fullRowWidth - rowWidth) / 2
        end

        for i, icon in ipairs(icons) do
            local row = math.floor((i - 1) / rowLimit)
            local col = (i - 1) % rowLimit

            local x = col * (iconWidth + iconPadding)
            local y = -row * (iconHeight + iconPadding)

            if not isSingleRow then
                local isLastRow = (row == math.floor((totalIcons - 1) / rowLimit))
                if isLastRow and lastRowCount > 0 then
                    x = x + shiftX
                end
            end

            icon:ClearAllPoints()
            icon:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
        end
    end
end

function BBF.HookCooldownManagerTweaks()
    local centering = BetterBlizzFramesDB.cdManagerCenterIcons
    if not centering then return end

    for _, frame in ipairs(cdManagerFrames) do
        if frame and frame.RefreshLayout and not frame.bbfCenteringHooked then
            local center = frame ~= BuffBarCooldownViewer
            hooksecurefunc(frame, "Layout", function(self)
                BBF.SortCooldownManagerIcons(self, center)
            end)
            if frame == BuffIconCooldownViewer then
                hooksecurefunc(frame, "OnUnitAura", function(self)
                    BBF.SortCooldownManagerIcons(self, center)
                end)
            end
            frame.bbfCenteringHooked = true
        end
    end

    BBF.RefreshCooldownManagerIcons()
end
