local LSM = LibStub("LibSharedMedia-3.0")

local xpColor = { r = 0.58, g = 0.0, b = 0.55 }
local restedColor = { r = 0.0, g = 0.39, b = 0.88 }
local honorColor = { r = 1.0, g = 0.24, b = 0.0 }
local artifactColor = { r = 0.901, g = 0.8, b = 0.601 }

local factionIndex = {
    ["UI-HUD-ExperienceBar-Fill-Reputation-Faction-Red"] = 2,
    ["UI-HUD-ExperienceBar-Fill-Reputation-Faction-Orange"] = 3,
    ["UI-HUD-ExperienceBar-Fill-Reputation-Faction-Yellow"] = 4,
    ["UI-HUD-ExperienceBar-Fill-Reputation-Faction-Green"] = 5,
}

local atlasColors = {
    ["UI-HUD-ExperienceBar-Fill-Experience"] = xpColor,
    ["UI-HUD-ExperienceBar-Fill-Rested"] = restedColor,
    ["UI-HUD-ExperienceBar-Fill-Reputation-Faction-Blue"] = restedColor,
    ["UI-HUD-ExperienceBar-Fill-Honor"] = honorColor,
    ["UI-HUD-ExperienceBar-Fill-ArtifactPower"] = artifactColor,
}

local function GetAtlasColor(atlas)
    local index = factionIndex[atlas]
    if index then
        return FACTION_BAR_COLORS and FACTION_BAR_COLORS[index]
    end
    return atlasColors[atlas]
end

local TILE_WIDTH = 256
local xpBarTexture
local drivers = {}

local function GetBarColor(statusBar)
    local fill = statusBar:GetStatusBarTexture()
    local atlas = statusBar.bbfXpAtlas or (fill and fill.GetAtlas and fill:GetAtlas())
    local color = atlas and GetAtlasColor(atlas)
    if color then
        return color.r, color.g, color.b
    end
    local r, g, b = statusBar:GetStatusBarColor()
    return r, g, b
end

local function Layout(driver, width, height, fillWidth, r, g, b)
    local statusBar = driver.statusBar
    local pieces = driver.pieces
    local count = width > 0 and math.max(1, math.floor(width / TILE_WIDTH + 0.5)) or 0
    local repeatWidth = count > 0 and width / count or 0
    for i = 1, math.max(count, #pieces) do
        local piece = pieces[i]
        local pieceWidth = i <= count and math.min(repeatWidth, fillWidth - (i - 1) * repeatWidth) or 0
        if pieceWidth > 0 then
            if not piece then
                piece = statusBar:CreateTexture(nil, "BORDER")
                pieces[i] = piece
            end
            piece:SetDrawLayer(driver.layer, driver.sub)
            piece:SetTexture(xpBarTexture)
            piece:SetVertexColor(r, g, b, 1)
            piece:ClearAllPoints()
            piece:SetPoint("TOPLEFT", statusBar, "TOPLEFT", (i - 1) * repeatWidth, 0)
            piece:SetSize(pieceWidth, height)
            piece:SetTexCoord(0, pieceWidth / repeatWidth, 0, 1)
            piece:Show()
        elseif piece then
            piece:Hide()
        end
    end
end

local function Update(statusBar)
    local driver = drivers[statusBar]
    if not driver or not driver.enabled then return end
    local fill = statusBar:GetStatusBarTexture()
    if fill then
        if fill:GetAlpha() ~= 0 then
            fill:SetAlpha(0)
        end
        if not driver.layer then
            driver.layer, driver.sub = fill:GetDrawLayer()
        end
    end
    local width, height = statusBar:GetSize()
    local minValue, maxValue = statusBar:GetMinMaxValues()
    local value = statusBar:GetValue()
    local r, g, b = GetBarColor(statusBar)
    if width == driver.width and height == driver.height and minValue == driver.minValue and maxValue == driver.maxValue
        and value == driver.value and r == driver.r and g == driver.g and b == driver.b and xpBarTexture == driver.texture then
        return
    end
    driver.width, driver.height, driver.minValue, driver.maxValue, driver.value = width, height, minValue, maxValue, value
    driver.r, driver.g, driver.b, driver.texture = r, g, b, xpBarTexture

    local fillWidth = 0
    if width and width > 0 and maxValue > minValue then
        fillWidth = width * math.max(0, math.min((value - minValue) / (maxValue - minValue), 1))
    end
    Layout(driver, width or 0, height or 0, fillWidth, r, g, b)
end

local function SetupBar(statusBar)
    if not statusBar or not statusBar.GetStatusBarTexture then return end
    local driver = drivers[statusBar]
    if not driver then
        driver = { statusBar = statusBar, pieces = {} }
        drivers[statusBar] = driver
        hooksecurefunc(statusBar, "SetStatusBarTexture", function(self, asset)
            if type(asset) == "string" then
                self.bbfXpAtlas = asset
            end
            Update(self)
        end)
        hooksecurefunc(statusBar, "SetStatusBarColor", Update)
        hooksecurefunc(statusBar, "SetMinMaxValues", Update)
        hooksecurefunc(statusBar, "SetValue", Update)
        statusBar:HookScript("OnSizeChanged", Update)
    end
    driver.enabled = true
    driver.texture = nil
    Update(statusBar)
end

local function DisableBar(statusBar, driver)
    driver.enabled = false
    for _, piece in ipairs(driver.pieces) do
        piece:Hide()
    end
    local fill = statusBar:GetStatusBarTexture()
    if fill then
        fill:SetAlpha(1)
    end
end

local function ForEachBar(func)
    local manager = StatusTrackingBarManager
    if manager and manager.barContainers then
        for _, container in ipairs(manager.barContainers) do
            if container.bars then
                for _, bar in pairs(container.bars) do
                    func(bar.StatusBar)
                end
            end
        end
    end
    func(MainMenuExpBar)
    func(ReputationWatchBar and ReputationWatchBar.StatusBar)
end

function BBF.XpBarTexture()
    if not BetterBlizzFramesDB.changeXpBarTexture then
        for statusBar, driver in pairs(drivers) do
            DisableBar(statusBar, driver)
        end
        return
    end
    xpBarTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, BetterBlizzFramesDB.xpBarTexture)
    ForEachBar(SetupBar)
end
