local function QuestObjectiveParser(text)
    local current, goal, objective_name = string.match(text, "^(%d+)/(%d+)%s+(.+)$")
    if objective_name then
        return objective_name, current, goal
    end
    return string.match(text, "^(.-):%s*(%d+)/(%d+)$")
end

local TooltipFrame = CreateFrame("GameTooltip", "BBF_QuestTooltip", nil, "GameTooltipTemplate")
local PlayerName = UnitName("player")

function BBF.IsQuestUnit(unit)
    if not unit or not UnitExists(unit) or UnitIsPlayer(unit) then
        return false
    end

    if C_Secrets and C_Secrets.ShouldUnitIdentityBeSecret(unit) then
        return false
    end

    local unitGUID = UnitGUID(unit)
    if not unitGUID then
        return false
    end

    local quest_title
    local quest_player = true

    TooltipFrame:SetOwner(WorldFrame, "ANCHOR_NONE")
    TooltipFrame:SetHyperlink("unit:" .. unitGUID)

    for i = 3, TooltipFrame:NumLines() do
        local line = _G["BBF_QuestTooltipTextLeft" .. i]
        local text = line and line:GetText()
        if not text then
            break
        end
        local text_r, text_g, text_b = line:GetTextColor()

        if text_r > 0.99 and text_g > 0.81 and text_b == 0 then
            if quest_title then
                quest_player = (text == PlayerName)
            else
                quest_title = text
            end
        elseif quest_title and quest_player then
            local objective_name, current, goal
            local objective_type = false

            quest_title = false

            if string.find(text, "%%") then
                objective_name, current, goal = string.match(text, "^(.*) %(?(%d+)%%%)?$")
                objective_type = "area"
            else
                objective_name, current, goal = QuestObjectiveParser(text)
            end

            if objective_name then
                current = tonumber(current)

                if objective_type then
                    goal = 100
                else
                    goal = tonumber(goal)
                end

                if current and goal then
                    if current ~= goal then
                        TooltipFrame:Hide()
                        return true
                    end
                else
                    TooltipFrame:Hide()
                    return false
                end
            end
        end
    end

    TooltipFrame:Hide()
    return false
end

local questEventFrame

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
        indicator:SetShown(BBF.IsQuestUnit(unit))
    end
end

local function UpdateQuestIndicators()
    BBF.QuestIndicator(TargetFrame, "target")
    BBF.QuestIndicator(FocusFrame, "focus")
end

local function OnQuestEvent(self, event)
    if event == "PLAYER_TARGET_CHANGED" then
        BBF.QuestIndicator(TargetFrame, "target")
    elseif event == "PLAYER_FOCUS_CHANGED" then
        BBF.QuestIndicator(FocusFrame, "focus")
    elseif event == "UNIT_QUEST_LOG_CHANGED" then
        UpdateQuestIndicators()
    else
        local _, instanceType = IsInInstance()
        if instanceType == "arena" or instanceType == "pvp" then
            self:UnregisterEvent("PLAYER_TARGET_CHANGED")
            self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
            self:UnregisterEvent("UNIT_QUEST_LOG_CHANGED")
            HideQuestIndicator(TargetFrame)
            HideQuestIndicator(FocusFrame)
        else
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self:RegisterEvent("PLAYER_FOCUS_CHANGED")
            self:RegisterUnitEvent("UNIT_QUEST_LOG_CHANGED", "player")
            UpdateQuestIndicators()
        end
    end
end

function BBF.QuestIndicatorCaller()
    if not BetterBlizzFramesDB.questIndicator then
        if questEventFrame then
            questEventFrame:UnregisterAllEvents()
        end
        HideQuestIndicator(TargetFrame)
        HideQuestIndicator(FocusFrame)
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
