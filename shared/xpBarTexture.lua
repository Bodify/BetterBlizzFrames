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
local MASK_ATLAS = "UI-HUD-ExperienceBar-Fill-Experience"
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
                if driver.mask then
                    piece:AddMaskTexture(driver.mask)
                end
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
        local background = statusBar.Background
        if background and background.GetAtlas and background:GetAtlas() == "UI-HUD-ExperienceBar-Background" then
            driver.mask = statusBar:CreateMaskTexture()
            driver.mask:SetAtlas(MASK_ATLAS)
            driver.mask:SetAllPoints(statusBar)
        end
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

local RefreshQuestXpBars

function BBF.XpBarTexture()
    if not BetterBlizzFramesDB.changeXpBarTexture then
        for statusBar, driver in pairs(drivers) do
            DisableBar(statusBar, driver)
        end
    else
        xpBarTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, BetterBlizzFramesDB.xpBarTexture)
        ForEachBar(SetupBar)
    end
    RefreshQuestXpBars()
end

local L = BBF.L
local defaultQuestXpColor = { 0.847, 0.51, 0.125, 1 }
local QUEST_ATLAS = "UI-HUD-ExperienceBar-Fill-ArtifactPower"
local questBars = {}
local questXp = 0
local questFrame
local questScanPending
local questEnabled
local levelTime, levelTimeAt
local silencedChatFrames

local GetNumQuestLogEntries = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries) or GetNumQuestLogEntries
local GetQuestLogInfo = C_QuestLog and C_QuestLog.GetInfo
local IsQuestComplete = (C_QuestLog and C_QuestLog.IsComplete) or IsQuestComplete
local ReadyForTurnIn = C_QuestLog and C_QuestLog.ReadyForTurnIn

local function GetLogEntry(index)
    if GetQuestLogInfo then
        local info = GetQuestLogInfo(index)
        if info and not info.isHeader then
            return info.questID
        end
        return
    end
    local _, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(index)
    if not isHeader then
        return questID, isComplete == 1
    end
end

local function GetCompletedQuestXp()
    local total = 0
    if not GetNumQuestLogEntries or not GetQuestLogRewardXP then return total end
    for i = 1, GetNumQuestLogEntries() do
        local questID, complete = GetLogEntry(i)
        if questID and questID > 0 then
            if complete == nil then
                complete = (IsQuestComplete and IsQuestComplete(questID)) or (ReadyForTurnIn and ReadyForTurnIn(questID))
            end
            if complete then
                total = total + (GetQuestLogRewardXP(questID) or 0)
            end
        end
    end
    return total
end

local function SetAtlasSlice(tex, info, startFrac, endFrac)
    local left, right = info.leftTexCoord, info.rightTexCoord
    tex:SetTexture(info.file or info.filename)
    tex:SetTexCoord(left + (right - left) * startFrac, left + (right - left) * endFrac, info.topTexCoord, info.bottomTexCoord)
end

local function ApplyQuestTexture(quest, statusBar, startFrac, endFrac, width)
    local tex = quest.tex
    local db = BetterBlizzFramesDB
    local custom = db.questXpBarTexture or (db.changeXpBarTexture and db.xpBarTexture)
    if custom then
        tex:SetTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, custom))
        tex:SetDesaturated(false)
        local count = math.max(1, math.floor(width / TILE_WIDTH + 0.5))
        tex:SetTexCoord(0, math.min(1, (endFrac - startFrac) * count), 0, 1)
        return
    end
    local fill = statusBar:GetStatusBarTexture()
    local atlas = statusBar.bbfXpAtlas or (fill and fill.GetAtlas and fill:GetAtlas())
    local GetAtlasInfo = C_Texture and C_Texture.GetAtlasInfo
    if atlas and GetAtlasInfo and atlas:find("^UI%-HUD%-ExperienceBar%-Fill") then
        local info = GetAtlasInfo(QUEST_ATLAS)
        if info and (info.file or info.filename) then
            SetAtlasSlice(tex, info, startFrac, endFrac)
            tex:SetDesaturated(false)
            return
        end
    end
    local info = atlas and GetAtlasInfo and GetAtlasInfo(atlas)
    if info and (info.file or info.filename) then
        SetAtlasSlice(tex, info, startFrac, endFrac)
    else
        tex:SetTexture(fill and fill:GetTexture() or "Interface\\TargetingFrame\\UI-StatusBar")
        tex:SetTexCoord(startFrac, endFrac, 0, 1)
    end
    tex:SetDesaturated(true)
end

local function HideQuestBar(quest)
    quest.tex:Hide()
    quest.hover:Hide()
    if quest.tick then
        quest.tick:Hide()
    end
end

local function UpdateQuestBar(statusBar)
    local quest = questBars[statusBar]
    if not quest then return end
    local maxXp = UnitXPMax("player") or 0
    local width, height = statusBar:GetSize()
    if not questEnabled or questXp <= 0 or maxXp <= 0 or not width or width <= 0 or (IsXPUserDisabled and IsXPUserDisabled()) then
        HideQuestBar(quest)
        return
    end
    local start = UnitXP("player") or 0
    if quest.rested and quest.rested:IsShown() then
        start = start + (GetXPExhaustion() or 0)
    end
    local startFrac = math.min(start / maxXp, 1)
    local endFrac = math.min((start + questXp) / maxXp, 1)
    if (endFrac - startFrac) * width < 0.5 then
        HideQuestBar(quest)
        return
    end
    ApplyQuestTexture(quest, statusBar, startFrac, endFrac, width)
    local color = BetterBlizzFramesDB.questXpBarColor or defaultQuestXpColor
    quest.tex:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
    quest.tex:ClearAllPoints()
    quest.tex:SetPoint("TOPLEFT", statusBar, "TOPLEFT", startFrac * width, 0)
    quest.tex:SetSize((endFrac - startFrac) * width, height)
    quest.tex:Show()
    quest.hover:Show()
    local tick = quest.tick
    if tick then
        tick:ClearAllPoints()
        tick:SetPoint("CENTER", statusBar, "LEFT", endFrac * width, quest.tickY)
        tick:SetShown(not quest.tickHideAtEdge or endFrac <= 0.99)
    end
end

local function ShowQuestTooltip(owner)
    local maxXp = UnitXPMax("player") or 0
    if maxXp <= 0 or owner:GetEffectiveAlpha() < 0.01 then return end
    GameTooltip:SetOwner(owner, "ANCHOR_CURSOR")
    GameTooltip_SetTitle(GameTooltip, L["Quest_Completion_XP"])
    GameTooltip_AddHighlightLine(GameTooltip, L["Quest_XP_Amount"]:format(BreakUpLargeNumbers(questXp), math.floor(questXp / maxXp * 100 + 0.5)))
    GameTooltip:Show()
end

local function GetLevelTime()
    if levelTime then
        return levelTime + GetTime() - levelTimeAt
    end
end

local function AppendQuestPercent()
    if not questEnabled then return end
    local tooltip = GetAppropriateTooltip and GetAppropriateTooltip() or GameTooltip
    local maxXp = UnitXPMax("player") or 0
    if not tooltip:IsShown() or maxXp <= 0 then return end
    local seconds = GetLevelTime()
    if questXp <= 0 and not seconds then return end
    local name = tooltip:GetName()
    local lines = {}
    for i = 1, tooltip:NumLines() do
        local line = _G[name .. "TextLeft" .. i]
        local r, g, b = line:GetTextColor()
        lines[i] = { line:GetText(), r, g, b }
    end
    if not lines[1] then return end
    tooltip:ClearLines()
    tooltip:AddLine(lines[1][1], lines[1][2], lines[1][3], lines[1][4], true)
    if questXp > 0 then
        local percent = math.ceil(((UnitXP("player") or 0) + questXp) / maxXp * 100)
        tooltip:AddLine(L["Quest_XP_Percent"]:format("|cffff9a1a" .. percent .. "%|r"), 1, 1, 1, true)
    end
    if seconds then
        tooltip:AddLine(L["Level_Time"]:format(SecondsToTime(seconds, true)), 1, 1, 1, true)
    end
    for i = 2, #lines do
        tooltip:AddLine(lines[i][1], lines[i][2], lines[i][3], lines[i][4], true)
    end
    tooltip:Show()
end

local function CreateQuestTick(statusBar, source)
    local tick = CreateFrame("Button", nil, statusBar)
    tick:SetSize(source:GetSize())
    tick:SetFrameStrata(source:GetFrameStrata())
    local normal = source.Normal or source:GetNormalTexture()
    if normal then
        local atlas = normal:GetAtlas()
        if atlas then tick:SetNormalAtlas(atlas) else tick:SetNormalTexture(normal:GetTexture()) end
    end
    local highlight = source.Highlight or source:GetHighlightTexture()
    if highlight then
        local atlas = highlight:GetAtlas()
        if atlas then tick:SetHighlightAtlas(atlas, "ADD") else tick:SetHighlightTexture(highlight:GetTexture(), "ADD") end
    end
    tick:SetScript("OnEnter", ShowQuestTooltip)
    tick:SetScript("OnLeave", GameTooltip_Hide)
    tick:Hide()
    return tick
end

local function SetupQuestBar(statusBar, rested, sourceTick)
    if not statusBar or not statusBar.CreateTexture or questBars[statusBar] then return end
    local quest = { rested = rested }
    quest.tex = statusBar:CreateTexture(nil, "BORDER", nil, -1)
    local background = statusBar.Background
    if background and background.GetAtlas and background:GetAtlas() == "UI-HUD-ExperienceBar-Background" then
        quest.mask = statusBar:CreateMaskTexture()
        quest.mask:SetAtlas(MASK_ATLAS)
        quest.mask:SetAllPoints(statusBar)
        quest.tex:AddMaskTexture(quest.mask)
    end
    quest.hover = CreateFrame("Frame", nil, statusBar)
    quest.hover:SetAllPoints(quest.tex)
    quest.hover:SetScript("OnEnter", ShowQuestTooltip)
    quest.hover:SetScript("OnLeave", GameTooltip_Hide)
    quest.hover:Hide()
    if sourceTick then
        quest.tick = CreateQuestTick(statusBar, sourceTick)
        quest.tickY = sourceTick.yOffset or EXHAUSTION_TICK_OFFSET_Y or 0
        quest.tickHideAtEdge = sourceTick.hideAtBarEdge
        if sourceTick.ExhaustionToolTipText then
            hooksecurefunc(sourceTick, "ExhaustionToolTipText", AppendQuestPercent)
        end
    end
    questBars[statusBar] = quest
    statusBar:HookScript("OnSizeChanged", UpdateQuestBar)
    if rested then
        hooksecurefunc(rested, "Show", function() UpdateQuestBar(statusBar) end)
        hooksecurefunc(rested, "Hide", function() UpdateQuestBar(statusBar) end)
    end
end

local function ForEachExpBar(func)
    local manager = StatusTrackingBarManager
    if manager and manager.barContainers then
        for _, container in ipairs(manager.barContainers) do
            if container.bars then
                for _, bar in pairs(container.bars) do
                    if bar.isExpBar and bar.ExhaustionLevelFillBar then
                        func(bar.StatusBar, bar.ExhaustionLevelFillBar, bar.ExhaustionTick)
                    end
                end
            end
        end
    end
    if MainMenuExpBar then
        func(MainMenuExpBar, ExhaustionLevelFillBar, ExhaustionTick)
    end
end

RefreshQuestXpBars = function()
    for statusBar in pairs(questBars) do
        UpdateQuestBar(statusBar)
    end
end

local function ScanQuestXp()
    questScanPending = nil
    if not questEnabled then return end
    questXp = GetCompletedQuestXp()
    RefreshQuestXpBars()
end

local function RestoreChatFrames()
    if not silencedChatFrames then return end
    for _, frame in ipairs(silencedChatFrames) do
        frame:RegisterEvent("TIME_PLAYED_MSG")
    end
    silencedChatFrames = nil
end

local function RequestLevelTime()
    if levelTime or silencedChatFrames or not RequestTimePlayed then return end
    silencedChatFrames = {}
    for i = 1, NUM_CHAT_WINDOWS or 10 do
        local frame = _G["ChatFrame" .. i]
        if frame and frame:IsEventRegistered("TIME_PLAYED_MSG") then
            frame:UnregisterEvent("TIME_PLAYED_MSG")
            table.insert(silencedChatFrames, frame)
        end
    end
    C_Timer.After(5, RestoreChatFrames)
    RequestTimePlayed()
end

local function OnQuestEvent(_, event, ...)
    if event == "TIME_PLAYED_MSG" then
        levelTime, levelTimeAt = select(2, ...), GetTime()
        C_Timer.After(0, RestoreChatFrames)
        return
    elseif event == "PLAYER_LEVEL_UP" and levelTime then
        levelTime, levelTimeAt = 0, GetTime()
    end
    if event == "PLAYER_XP_UPDATE" or event == "UPDATE_EXHAUSTION" then
        RefreshQuestXpBars()
    elseif not questScanPending then
        questScanPending = true
        C_Timer.After(0.2, ScanQuestXp)
    end
end

function BBF.QuestXpBar()
    questEnabled = BetterBlizzFramesDB.questXpBar
    if not questEnabled then
        if questFrame then
            questFrame:UnregisterAllEvents()
        end
        RefreshQuestXpBars()
        return
    end
    if not questFrame then
        questFrame = CreateFrame("Frame")
        questFrame:SetScript("OnEvent", OnQuestEvent)
    end
    questFrame:RegisterEvent("QUEST_LOG_UPDATE")
    questFrame:RegisterUnitEvent("UNIT_QUEST_LOG_CHANGED", "player")
    questFrame:RegisterEvent("PLAYER_LEVEL_UP")
    questFrame:RegisterEvent("PLAYER_XP_UPDATE")
    questFrame:RegisterEvent("UPDATE_EXHAUSTION")
    questFrame:RegisterEvent("TIME_PLAYED_MSG")
    ForEachExpBar(SetupQuestBar)
    ScanQuestXp()
    RequestLevelTime()
end
