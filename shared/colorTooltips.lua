local hooked
local active, classOn, npcOn, levelOn, factionOn, hideFaction, hideHealthbar, hideClass, classHealthbar
local barColor

local reactionColors = {
    hostile = { 1, 0.25, 0.25 },
    neutral = { 1, 1, 0 },
    friendly = { 0.25, 1, 0.25 },
}
local guildColor = { 0.25, 1, 0.25 }
local factionColors = {
    Alliance = { 0.29, 0.55, 1 },
    Horde = { 0.9, 0.15, 0.15 },
}

local function Clean(value)
    if value == nil or issecretvalue(value) then return nil end
    return value
end

local function GetLine(tooltip, index)
    local name = tooltip:GetName()
    return name and _G[name .. "TextLeft" .. index]
end

local function CopyLine(from, to)
    if not from or not to then return end
    local text = from:GetText()
    to:SetText(text)
    to:SetTextColor(from:GetTextColor())
    to:SetShown(from:IsShown())
end

local function RemoveLine(tooltip, index, numLines)
    local name = tooltip:GetName()
    if not name then return end
    for i = index, numLines do
        local left, right = _G[name .. "TextLeft" .. i], _G[name .. "TextRight" .. i]
        if (left and issecretvalue(left:GetText())) or (right and issecretvalue(right:GetText())) then return end
    end
    for i = index, numLines - 1 do
        CopyLine(_G[name .. "TextLeft" .. (i + 1)], _G[name .. "TextLeft" .. i])
        CopyLine(_G[name .. "TextRight" .. (i + 1)], _G[name .. "TextRight" .. i])
    end
    for _, side in ipairs({ "TextLeft", "TextRight" }) do
        local line = _G[name .. side .. numLines]
        if line then
            line:SetText(nil)
            line:Hide()
        end
    end
    tooltip:Show()
end

local function HandleFaction(tooltip, unit, firstLine, numLines)
    if not factionOn and not hideFaction then return end
    local faction, factionName = UnitFactionGroup(unit)
    faction, factionName = Clean(faction), Clean(factionName)
    if not faction or not factionName then return end
    for i = firstLine, numLines do
        local line = GetLine(tooltip, i)
        local text = line and Clean(line:GetText())
        if text == factionName then
            if hideFaction then
                RemoveLine(tooltip, i, numLines)
            else
                local color = factionColors[faction]
                if color then
                    line:SetTextColor(color[1], color[2], color[3])
                end
            end
            return
        end
    end
end

local customReactionKeys = {
    hostile = "enemyHealthColor",
    neutral = "neutralHealthColor",
    friendly = "friendlyHealthColor",
}

local function CustomReactionColor(kind)
    local db = BetterBlizzFramesDB
    if not db.customHealthbarColors then return end
    local key = customReactionKeys[kind]
    local custom, default = db[key], BBF.defaultSettings[key]
    if not custom or custom[1] == default[1] and custom[2] == default[2] and custom[3] == default[3] then return end
    return custom
end

local function ReactionColor(unit)
    local reaction = Clean(UnitReaction(unit, "player"))
    if not reaction then return end
    local kind = reaction <= 3 and "hostile" or reaction == 4 and "neutral" or "friendly"
    return CustomReactionColor(kind) or reactionColors[kind]
end

local function LevelColor(level)
    if level <= 0 then return QuestDifficultyColors and QuestDifficultyColors.impossible end
    if GetCreatureDifficultyColor then return GetCreatureDifficultyColor(level) end
    return GetQuestDifficultyColor(level)
end

local function ColorLevel(tooltip, unit, firstLine, numLines)
    if not Clean(UnitCanAttack("player", unit)) then return end
    local level = Clean(UnitEffectiveLevel and UnitEffectiveLevel(unit) or UnitLevel(unit))
    if not level then return end
    local color = LevelColor(level)
    if not color then return end
    local token = level > 0 and "%f[%d]" .. level .. "%f[%D]" or "%?%?"
    for i = firstLine, numLines do
        local line = GetLine(tooltip, i)
        local text = line and Clean(line:GetText())
        local ls, le
        if text then ls, le = text:find(LEVEL, 1, true) end
        if ls then
            local _, e = text:find(token, le + 1)
            if e then
                local hex = string.format("|cff%02x%02x%02x", math.floor(color.r * 255 + 0.5), math.floor(color.g * 255 + 0.5), math.floor(color.b * 255 + 0.5))
                line:SetText(text:sub(1, ls - 1) .. hex .. text:sub(ls, e) .. "|r" .. text:sub(e + 1))
                return
            end
        end
    end
end

local function HideClassName(tooltip, unit, firstLine, numLines)
    local className = Clean(UnitClass(unit))
    if not className then return numLines end
    for i = numLines, firstLine, -1 do
        local line = GetLine(tooltip, i)
        local text = line and Clean(line:GetText())
        local s, e
        if text then s, e = text:find(className, 1, true) end
        if s then
            local before, after = text:sub(1, s - 1), text:sub(e + 1)
            if before:sub(-1) == " " then
                before = before:sub(1, -2)
            elseif after:sub(1, 1) == " " then
                after = after:sub(2)
            end
            local rest = before .. after
            if rest:match("^%s*$") then
                RemoveLine(tooltip, i, numLines)
                numLines = numLines - 1
            else
                line:SetText(rest)
            end
        end
    end
    return numLines
end

local function ColorPlayer(tooltip, unit, numLines)
    local guildName = Clean(GetGuildInfo(unit))
    local firstLine = guildName and 3 or 2
    if levelOn then
        ColorLevel(tooltip, unit, firstLine, numLines)
    end

    local nameLine = GetLine(tooltip, 1)
    local class = classOn and Clean(UnitClassBase(unit))
    local classColor = class and RAID_CLASS_COLORS[class]
    if nameLine and classColor then
        nameLine:SetTextColor(classColor.r, classColor.g, classColor.b)
    end

    if guildName and numLines >= 2 then
        local guildLine = GetLine(tooltip, 2)
        if guildLine then
            guildLine:SetTextColor(guildColor[1], guildColor[2], guildColor[3])
        end
    end

    if hideClass then
        numLines = HideClassName(tooltip, unit, firstLine, numLines)
    end

    local className = classColor and not hideClass and Clean(UnitClass(unit))
    if className then
        local hex = string.format("|cff%02x%02x%02x", math.floor(classColor.r * 255 + 0.5), math.floor(classColor.g * 255 + 0.5), math.floor(classColor.b * 255 + 0.5))
        for i = firstLine, numLines do
            local line = GetLine(tooltip, i)
            local text = line and Clean(line:GetText())
            local s, e
            if text then s, e = text:find(className, 1, true) end
            if s then
                if text:find(LEVEL, 1, true) then
                    line:SetText(text:sub(1, s - 1) .. hex .. className .. "|r" .. text:sub(e + 1))
                else
                    line:SetText(hex .. text .. "|r")
                end
            end
        end
    end

    HandleFaction(tooltip, unit, firstLine, numLines)
end

local function GetHealthbar()
    return GameTooltipStatusBar or GameTooltip.StatusBar
end

local function ColorHealthbar(unit)
    local bar = GetHealthbar()
    local class = classHealthbar and Clean(UnitIsPlayer(unit)) and Clean(UnitClassBase(unit))
    barColor = class and RAID_CLASS_COLORS[class]
    if barColor then
        bar:SetStatusBarColor(barColor.r, barColor.g, barColor.b)
    elseif bar.bbfClassColored then
        bar:SetStatusBarColor(0, 1, 0)
    end
    bar.bbfClassColored = barColor and true or nil
end

local function ColorUnitTooltip(tooltip)
    if not active or not tooltip or not tooltip.GetUnit then return end
    local _, unit = tooltip:GetUnit()
    unit = Clean(unit)
    if not unit then return end
    if tooltip == GameTooltip and (classHealthbar or barColor) then
        ColorHealthbar(unit)
    end
    local numLines = Clean(tooltip:NumLines()) or 0
    if numLines < 1 then return end

    if Clean(UnitIsPlayer(unit)) then
        ColorPlayer(tooltip, unit, numLines)
        return
    end

    if levelOn then
        ColorLevel(tooltip, unit, 2, numLines)
    end

    local color = npcOn and ReactionColor(unit)
    local nameLine = color and GetLine(tooltip, 1)
    if nameLine then
        nameLine:SetTextColor(color[1], color[2], color[3])
    end

    if hideFaction then
        HandleFaction(tooltip, unit, 2, numLines)
    end
end

local function UpdateHealthbar()
    local bar = GetHealthbar()
    bar:SetAlpha(active and hideHealthbar and 0 or 1)
    if not (active and classHealthbar) and bar.bbfClassColored then
        barColor = nil
        bar.bbfClassColored = nil
        bar:SetStatusBarColor(0, 1, 0)
    end
    if active and classHealthbar and not bar.bbfClassColorHooked then
        bar.bbfClassColorHooked = true
        bar:HookScript("OnValueChanged", function(self)
            if barColor then
                self:SetStatusBarColor(barColor.r, barColor.g, barColor.b)
            end
        end)
    end
end

function BBF.ColorTooltips()
    local db = BetterBlizzFramesDB
    active = db.colorTooltips and true or false
    classOn = db.colorTooltipsClass and true or false
    npcOn = db.colorTooltipsNpc and true or false
    levelOn = db.colorTooltipsLevel and true or false
    factionOn = db.colorTooltipsFaction and true or false
    hideFaction = db.colorTooltipsHideFaction and true or false
    hideHealthbar = db.colorTooltipsHideHealthbar and true or false
    hideClass = db.colorTooltipsHideClass and true or false
    classHealthbar = db.colorTooltipsClassHealthbar and true or false
    if active or hooked then
        UpdateHealthbar()
    end
    if not active or hooked then return end
    hooked = true
    if TooltipDataProcessor and Enum.TooltipDataType then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, ColorUnitTooltip)
    else
        GameTooltip:HookScript("OnTooltipSetUnit", ColorUnitTooltip)
    end
end
