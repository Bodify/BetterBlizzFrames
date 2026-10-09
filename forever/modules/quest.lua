local UnitIsRelatedToActiveQuest = C_QuestLog.UnitIsRelatedToActiveQuest
local GetUnitTooltip = C_TooltipInfo.GetUnit
local LINE_OBJECTIVE = Enum.TooltipDataLineType.QuestObjective
local LINE_TITLE = Enum.TooltipDataLineType.QuestTitle
local LINE_PLAYER = Enum.TooltipDataLineType.QuestPlayer
local PlayerName = UnitName("player")
local PlayerGUID = UnitGUID("player")

local function IsObjectiveDone(line)
    if line.completed then
        return true
    end
    local text = line.leftText
    if type(text) ~= "string" then
        return false
    end
    local current, goal = text:match("(%d+)%s*/%s*(%d+)")
    if current then
        return tonumber(current) >= tonumber(goal)
    end
    local percent = text:match("(%d+)%s*%%")
    return percent ~= nil and tonumber(percent) >= 100
end

function BBF.IsQuestUnit(unit)
    if not unit or not UnitExists(unit) or UnitIsPlayer(unit) then
        return false
    end

    if C_Secrets.ShouldUnitIdentityBeSecret(unit) then
        return false
    end

    local data = GetUnitTooltip(unit)
    local lines = data and data.lines
    if lines then
        local hasQuestLines = false
        local isMine = true
        for _, line in ipairs(lines) do
            local lineType = line.type
            if lineType == LINE_TITLE then
                hasQuestLines = true
                isMine = true
            elseif lineType == LINE_PLAYER then
                isMine = line.guid == PlayerGUID or line.leftText == PlayerName
            elseif lineType == LINE_OBJECTIVE then
                hasQuestLines = true
                if isMine and not IsObjectiveDone(line) then
                    return true
                end
            end
        end
        if hasQuestLines then
            return false
        end
    end

    return UnitIsRelatedToActiveQuest(unit) == true
end

local questEventFrame
local updatePending

local function SetupQuestIndicator(unitFrame)
    if not unitFrame then return end
    local indicator = unitFrame.bbfQuestIndicator
    if not indicator then
        indicator = (unitFrame.bbfOverlayFrame or unitFrame):CreateTexture(nil, "OVERLAY", nil, 7)
        indicator:SetAtlas("QuestNormal")
        indicator:SetSize(28, 28)
        indicator:Hide()
        unitFrame.bbfQuestIndicator = indicator
    end
    indicator:ClearAllPoints()
    indicator:SetPoint("CENTER", unitFrame, "RIGHT", (BetterBlizzFramesDB.questIndicatorXPos or 0) - 24, (BetterBlizzFramesDB.questIndicatorYPos or 0) + 3)
    indicator:SetScale(BetterBlizzFramesDB.questIndicatorScale or 1)
end

local function HideQuestIndicator(unitFrame)
    if unitFrame and unitFrame.bbfQuestIndicator then
        unitFrame.bbfQuestIndicator:Hide()
    end
end

function BBF.QuestIndicator(unitFrame, unit)
    local indicator = unitFrame and unitFrame.bbfQuestIndicator
    if indicator then
        indicator:SetShown(BetterBlizzFramesDB.questIndicatorTestMode or BBF.IsQuestUnit(unit))
    end
end

local function UpdateQuestIndicators()
    updatePending = nil
    if not (BetterBlizzFramesDB.questIndicator or BetterBlizzFramesDB.questIndicatorTestMode) then return end
    BBF.QuestIndicator(TargetFrame, "target")
    BBF.QuestIndicator(FocusFrame, "focus")
end

local function OnQuestEvent(self, event)
    if event == "PLAYER_TARGET_CHANGED" then
        BBF.QuestIndicator(TargetFrame, "target")
    elseif event == "PLAYER_FOCUS_CHANGED" then
        BBF.QuestIndicator(FocusFrame, "focus")
    elseif event == "UNIT_QUEST_LOG_CHANGED" or event == "QUEST_LOG_UPDATE" then
        if not updatePending then
            updatePending = true
            C_Timer.After(0.1, UpdateQuestIndicators)
        end
    else
        local _, instanceType = IsInInstance()
        if instanceType == "arena" or instanceType == "pvp" then
            self:UnregisterEvent("PLAYER_TARGET_CHANGED")
            self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
            self:UnregisterEvent("UNIT_QUEST_LOG_CHANGED")
            self:UnregisterEvent("QUEST_LOG_UPDATE")
            HideQuestIndicator(TargetFrame)
            HideQuestIndicator(FocusFrame)
        else
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self:RegisterEvent("PLAYER_FOCUS_CHANGED")
            self:RegisterUnitEvent("UNIT_QUEST_LOG_CHANGED", "player")
            self:RegisterEvent("QUEST_LOG_UPDATE")
            UpdateQuestIndicators()
        end
    end
end

function BBF.QuestIndicatorCaller()
    local db = BetterBlizzFramesDB
    if not db.questIndicator then
        if questEventFrame then
            questEventFrame:UnregisterAllEvents()
        end
        if db.questIndicatorTestMode then
            SetupQuestIndicator(TargetFrame)
            SetupQuestIndicator(FocusFrame)
            UpdateQuestIndicators()
        else
            HideQuestIndicator(TargetFrame)
            HideQuestIndicator(FocusFrame)
        end
        return
    end

    SetupQuestIndicator(TargetFrame)
    SetupQuestIndicator(FocusFrame)

    if not questEventFrame then
        questEventFrame = CreateFrame("Frame")
        questEventFrame:SetScript("OnEvent", OnQuestEvent)
    end
    questEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    OnQuestEvent(questEventFrame, "PLAYER_ENTERING_WORLD")
end
