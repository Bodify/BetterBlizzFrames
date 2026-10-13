local races = {
    Human = { id = 1, icon = "Interface\\Icons\\spell_shadow_charm", key = "racialIndicatorHuman" },
    Dwarf = { id = 3, icon = 136225 },
    NightElf = { id = 4, icon = "Interface\\Icons\\ability_ambush", key = "racialIndicatorNelf" },
    Gnome = { id = 7, spell = 20589 },
    Draenei = { id = 11, spell = 28880 },
    Worgen = { id = 22, spell = 68992 },
    VoidElf = { id = 29, spell = 256948 },
    LightforgedDraenei = { id = 30, spell = 255647, atlas = "lightforged" },
    DarkIronDwarf = { id = 34, icon = 1786406 },
    KulTiran = { id = 32, spell = 287712 },
    Mechagnome = { id = 37, spell = 312924 },
    Orc = { id = 2, icon = "Interface\\Icons\\inv_helmet_23" },
    Scourge = { id = 5, icon = "Interface\\Icons\\spell_shadow_raisedead", key = "racialIndicatorUndead", atlas = "undead" },
    Tauren = { id = 6, spell = 20549 },
    Troll = { id = 8, spell = 26297 },
    BloodElf = { id = 10, spell = 28730 },
    Goblin = { id = 9, spell = 69070 },
    Nightborne = { id = 27, spell = 260364 },
    HighmountainTauren = { id = 28, spell = 255654, atlas = "highmountain" },
    MagharOrc = { id = 36, spell = 274738 },
    ZandalariTroll = { id = 31, spell = 291944, atlas = "zandalari" },
    Vulpera = { id = 35, spell = 312411 },
    Pandaren = { id = 24, spell = 107079 },
    Dracthyr = { id = 52, spell = 357214 },
    EarthenDwarf = { id = 85, spell = 436344 },
    Harronir = { id = 86, spell = 1237885 },
    Skyborne = { id = 95, hordeID = 96, icon = 132845, hordeKey = "racialIndicatorSkyborneHorde" },
}

local alliance = { "Human", "Dwarf", "NightElf", "Gnome" }
local horde = { "Orc", "Scourge", "Tauren", "Troll" }

local function Add(list, ...)
    for i = 1, select("#", ...) do
        table.insert(list, (select(i, ...)))
    end
end

local expansion = BBF.isForever and 0 or tonumber(GetBuildInfo():match("^(%d+)"))
if expansion >= 2 then
    Add(alliance, "Draenei")
    Add(horde, "BloodElf")
end
if expansion >= 4 then
    Add(alliance, "Worgen")
    Add(horde, "Goblin")
end
if expansion >= 5 then
    Add(alliance, "Pandaren")
    Add(horde, "Pandaren")
end
if expansion >= 12 then
    Add(alliance, "VoidElf", "LightforgedDraenei", "DarkIronDwarf", "KulTiran", "Mechagnome", "Dracthyr", "EarthenDwarf", "Harronir")
    Add(horde, "Nightborne", "HighmountainTauren", "MagharOrc", "ZandalariTroll", "Vulpera", "Dracthyr", "EarthenDwarf", "Harronir")
end
if BBF.isForever then
    Add(alliance, "Skyborne")
    Add(horde, "Skyborne")
end

local raceByToken = {}
for token, race in pairs(races) do
    race.token = token
    race.key = race.key or ("racialIndicator" .. token)
    raceByToken[token:upper()] = race
end

BBF.racialIndicatorRaces = {}
for _, group in ipairs({ { FACTION_ALLIANCE, alliance }, { FACTION_HORDE, horde, true } }) do
    table.insert(BBF.racialIndicatorRaces, { header = group[1] })
    for _, token in ipairs(group[2]) do
        local race = races[token]
        local isHorde = group[3]
        local info = C_CreatureInfo.GetRaceInfo(isHorde and race.hordeID or race.id)
        table.insert(BBF.racialIndicatorRaces, {
            key = isHorde and race.hordeKey or race.key,
            label = info and info.raceName or token,
        })
    end
end

function BBF.GetRacialIndicatorRace(raceToken)
    return raceToken and raceByToken[raceToken:upper()]
end

function BBF.GetRacialIndicatorKey(race, unit)
    if race.hordeKey then
        local faction = UnitFactionGroup(unit)
        if not issecretvalue(faction) and faction == "Horde" then
            return race.hordeKey
        end
    end
    return race.key
end

local function GetRaceAtlas(race, unitSex)
    local name = race.atlas or race.token:lower()
    local atlas = string.format("raceicon-%s-%s", name, unitSex == 3 and "female" or "male")
    if C_Texture.GetAtlasInfo(atlas) then
        return atlas
    end
end

function BBF.GetRacialIndicatorIcon(race, unitSex, preferRaceIcon)
    if preferRaceIcon then
        local atlas = GetRaceAtlas(race, unitSex)
        if atlas then return atlas, true end
    end
    local icon = race.icon or (race.spell and C_Spell.GetSpellTexture(race.spell))
    if icon then return icon, false end
    local atlas = GetRaceAtlas(race, unitSex)
    if atlas then return atlas, true end
    return 134400, false
end

local function GetBorderStyle()
    if BBF.ClassicHDTexturesActive and BBF.ClassicHDTexturesActive() then
        return "hd"
    end
    if BBF.isForever then
        return "pvp"
    end
    return "default"
end

function BBF.UpdateRacialIndicatorBorder(indicator)
    local border = indicator.border
    local style = GetBorderStyle()
    if border.bbfStyle ~= style then
        border.bbfStyle = style
        border:ClearAllPoints()
        if style == "default" then
            border:SetAtlas("ui-frame-genericplayerchoice-portrait-border")
            border:SetAllPoints(indicator)
            border:SetDrawLayer("OVERLAY", 1)
        else
            if style == "hd" then
                border:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\MoTextures\\lvlring.png")
                border:SetTexCoord(0, 1, 0, 1)
            else
                border:SetAtlas("UI-HUD-UnitFrame-SmallCircle")
            end
            border:SetSize(31, 31)
            border:SetPoint("CENTER", indicator, "CENTER")
            border:SetDrawLayer("ARTWORK", 1)
        end
    end
    if style == "pvp" then
        border:SetDesaturated(false)
        border:SetVertexColor(1, 1, 1)
        return
    end
    if style == "default" then
        return 1, 1, 0, false
    end
    return 1, 0.9, 0.19, BBF.ClassicHDBronze and BBF.ClassicHDBronze()
end

BBF.popupBuilders["BBF_RACIAL_INDICATOR_RACES"] = function()
    return {
        text = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames:\n\nRacial Indicator now supports every race, and all races have been turned on.\n\nChange them with \"Races Shown\" in Advanced Settings.",
        button1 = "OK",
        timeout = 0,
        whileDead = true,
        preferredIndex = 3,
    }
end

function BBF.InitRacialIndicatorRaces()
    local db = BetterBlizzFramesDB
    local reset = not db.racialIndicatorRacesReset
    local keep = reset and BBF.isMidnight and db.racialIndicator
    for _, option in ipairs(BBF.racialIndicatorRaces) do
        if option.key and keep then
            if db[option.key] == nil then
                db[option.key] = false
            end
        elseif option.key and (reset or db[option.key] == nil) then
            db[option.key] = true
        end
    end
    if not reset then return end
    db.racialIndicatorRacesReset = true
    if db.racialIndicator and not keep then
        C_Timer.After(7, function()
            BBF.ShowPopup("BBF_RACIAL_INDICATOR_RACES")
        end)
    end
end
