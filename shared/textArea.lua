local SIDES = { left = true, right = true, textLeft = true, textRight = true }

BBF.TextAreaLayouts = {
    player = {
        health = { y = -0.5 }, mana = { y = -1 },
        rules = {
            { style = "pixel", textRight = 0.5 },
            { client = "retail", style = "noPortrait", mode = "big", mana = "hidden", right = -0.5, healthY = -1, textLeft = 1.5 },
            { style = "noPortrait", mode = "big", right = -0.5 },
            { client = "retail", style = "noPortrait", mode = "none", right = -0.5, manaY = 0, textLeft = 1, textRight = 2.5, own = { manaY = true } },
            { style = "noPortrait", right = -1.5, manaY = -0.5 },
            { style = "symmetric", mode = "xl", mana = "hidden", left = 10, right = -0.5, textRight = 3 },
            { style = "symmetric", mode = "xl", left = 5.5, right = -0.5, textLeft = 1, textRight = 3 },
            { style = "symmetric", mode = "reduced", mana = "hidden", left = 5, right = -1, textLeft = 5, textRight = 3 },
            { style = "symmetric", mode = "reduced", left = 2, right = -1, textLeft = 1.5, textRight = 3 },
            { style = "symmetric", mana = "hidden", left = 7, right = -1, textLeft = 4.5, textRight = 3 },
            { style = "symmetric", left = 2, right = -1, textRight = 3 },
            { style = "retail", mode = "xl", left = 7.5, right = -1.5, healthY = -1, manaY = -0.5, textLeft = 1 },
            { style = "retail", mode = "reduced", mana = "hidden", left = 2, right = -1, textLeft = 3 },
            { style = "retail", mode = "reduced", left = 5.5, right = -1.5, manaY = -0.5 },
            { style = "retail", left = 2, right = -1.5, manaY = -0.5 },
            { style = "classic", mode = "big", mana = "hidden", inside = true, healthY = 1.5, manaY = 0 },
            { style = "classic", mode = "big", mana = "hidden", healthY = -1.5, manaY = 0 },
            { style = "classic", mode = "big", inside = true, bottom = -1, healthY = 2, manaY = -0.5, own = { bottom = true, manaY = true } },
            { style = "classic", mode = "big", bottom = -1, healthY = -1.5, manaY = -0.5, own = { bottom = true, manaY = true } },
            { style = "classic", mode = "none", mana = "hidden", healthY = 0.5 },
            { style = "classic", mode = "none", left = 2, right = 0, healthY = 0 },
            { style = "camelot", mode = "xl", healthY = -1 },
            { style = "camelot", mode = "big" },
            { style = "camelot", left = 0.5, right = 1, top = -0.5, textLeft = 0.5, textRight = 3.5 },
        },
    },
    target = {
        health = { y = -0.5 }, mana = { y = -0.5 },
        rules = {
            { style = "pixel", textRight = 1 },
            { style = "noPortrait", mode = "big", left = 1, right = -2.5 },
            { client = "retail", style = "noPortrait", mode = "none", right = -5, manaY = -0.5, textLeft = 1, textRight = 2.5 },
            { style = "noPortrait", left = 1, right = -6.5 },
            { style = "classic", mode = "big", mana = "hidden", inside = true, bottom = 1, healthY = 3.5 },
            { style = "classic", mode = "big", mana = "hidden", bottom = 1, healthY = -1.5 },
            { style = "classic", mode = "big", bottom = -1, manaY = -0.5, own = { bottom = true } },
            { style = "classic", mode = "none", mana = "hidden", top = 1, bottom = -1, healthY = 0 },
            { style = "classic", left = 1, right = -2, top = 1, bottom = -1, textLeft = -0.5, textRight = -0.5 },
            { client = "retail", style = "retail", mode = "none", mana = "shown", left = 1, right = -5, healthY = -1, manaY = 0, textRight = 7,
                own = { healthY = true, manaY = true } },
            { client = "retail", style = "retail", mode = "xl", mana = "shown", left = 1, right = -1.5, textRight = 11 },
            { client = "retail", style = "retail", mode = "xl", mana = "hidden", left = 1.5, right = -9.5, textRight = 3 },
            { client = "retail", style = "retail", left = 1.5, right = -9.5, textRight = 2 },
            { style = "retail", mode = "none", mana = "shown", left = 1, right = -5, textRight = 5 },
            { style = "retail", mode = "xl", mana = "shown", left = 1, right = -1.5, textRight = 9 },
            { style = "retail", mode = "xl", mana = "hidden", left = 1.5, right = -9.5, textRight = 1 },
            { style = "retail", left = 1.5, right = -9.5 },
            { style = "camelot", mode = "xl", mana = "hidden", left = 2, right = -1.5, healthY = -1, textRight = 2.5,
                own = { left = true, right = true, textLeft = true, textRight = true, healthY = true } },
            { style = "camelot", mode = "big", mana = "hidden", left = 2, right = -1.5, healthY = -0.5, textRight = 2.5,
                own = { left = true, right = true, textLeft = true, textRight = true, healthY = true } },
            { style = "camelot", mana = "hidden" },
            { style = "camelot", mode = "reduced", textRight = 2, own = { textRight = true } },
            { style = "camelot", mode = "big" },
            { style = "camelot", left = 2, right = -5, top = -0.5, textRight = 2.5 },
        },
    },
    tot = {
        health = {}, mana = {},
        rules = {
            { style = "pixel" },
            { style = "noPortrait", mode = "big", top = -0.5, bottom = 0.5, textCenter = 1 },
            { style = "noPortrait", right = -5.5, top = -0.5, bottom = 0.5, textCenter = 1 },
            { style = "retail", classicToT = true, mana = "hidden", left = 1.5, right = 0 },
            { style = "retail", classicToT = true, left = 1, right = 0, bottom = 7 },
            { style = "retail", mode = "xl", left = 12, right = 0 },
            { style = "retail", mode = "reduced", mana = "hidden", left = 7, right = 0 },
            { style = "retail", mana = "hidden", left = 3, right = 0 },
            { style = "retail", mode = "reduced", left = 1, right = 0, healthY = 0.5 },
            { style = "retail", left = 1, right = 0 },
            { style = "classic", mode = "big", top = -0.5 },
            { style = "classic", left = 1, right = 3.5, top = -0.5, bottom = -4, textLeft = -1.5, textRight = 1 },
            { style = "camelot", mode = "xl", mana = "hidden", left = -0.5, right = 0.5, bottom = -1, healthY = -0.5, textLeft = 1.5, textRight = 2, own = SIDES },
            { style = "camelot", mode = "big", mana = "hidden", left = -0.5, right = 0.5, bottom = 1, textLeft = 1.5, textRight = 2, own = SIDES },
            { style = "camelot", mana = "hidden", bottom = 1 },
            { style = "camelot", mode = "xl", healthY = -0.5 },
            { style = "camelot", mode = "reduced", top = 1 },
            { style = "camelot", left = -0.5, right = -0.5, top = 0.5, textRight = 2 },
        },
    },
    pet = {
        health = {}, mana = {},
        rules = {
            { style = "pixel" },
            { style = "noPortrait", mode = "big", right = -2.5, top = -1 },
            { style = "noPortrait", right = -3.5, top = -1 },
            { style = "retail", mode = "xl", left = 12.5, right = -0.5, healthY = -0.5 },
            { style = "retail", mode = "reduced", mana = "hidden", left = 7, right = -1 },
            { style = "retail", mana = "hidden", left = 2, right = -1 },
            { style = "retail", mode = "reduced", left = 1, right = 0 },
            { style = "retail", left = 1, right = 0, bottom = -1, healthY = -0.5, textLeft = -1 },
            { style = "classic", mode = "big", mana = "hidden", top = -0.5, bottom = -1.5, healthY = 0 },
            { style = "classic", mode = "big", top = -0.5 },
            { style = "classic", mode = "none", mana = "hidden", top = 1, bottom = -2, healthY = 0.5 },
            { style = "classic", left = 1, right = -1, bottom = -4, textLeft = -1.5 },
            { style = "camelot", mode = "big", mana = "hidden", left = 1, right = 1, textLeft = 0.5, textRight = 2.5, own = SIDES },
            { style = "camelot", mana = "hidden" },
            { style = "camelot", mode = "xl", bottom = -0.5, healthY = -0.5 },
            { style = "camelot", mode = "big" },
            { style = "camelot", left = 1, right = -1.5, top = -0.5, bottom = -0.5, textLeft = -1, textRight = 2.5 },
        },
    },
    party = {
        health = { y = -0.5 }, mana = { y = -0.5 }, classicTextRight = 1,
        rules = {
            { style = "pixel", textRight = 1 },
            { client = "retail", style = "noPortrait", mode = "big", mana = "hidden", left = -0.5, right = 1, bottom = -0.5, textLeft = 1.5 },
            { style = "noPortrait", mode = "big", left = -0.5, right = 1, bottom = -0.5 },
            { style = "noPortrait", right = -4.5, bottom = 1.5 },
            { style = "retail", mode = "xl", mana = "hidden", left = 12.5, right = 0, textRight = 1.5 },
            { style = "retail", mode = "xl", left = 12.5, right = 0 },
            { style = "retail", mode = "reduced", mana = "hidden", left = 7.5, right = -1 },
            { style = "retail", mana = "hidden", left = 2.5, right = -1 },
            { style = "retail", mode = "reduced", left = 0, right = 1, healthY = 0, textLeft = 1 },
            { style = "retail", left = 0, right = 1, healthY = 0 },
            { style = "classic", mode = "big", mana = "hidden", bottom = 0.5 },
            { style = "classic", mode = "big", bottom = -0.5, manaY = -2 },
            { style = "classic", mode = "none", mana = "hidden", bottom = -1.5, healthY = 0 },
            { style = "classic", left = 0, right = -1, bottom = -1.5, manaY = -2, textRight = -1 },
            { style = "camelot", mode = "big", mana = "hidden", left = -1, right = 1, textLeft = 1, textRight = 3, own = SIDES },
            { style = "camelot", mana = "hidden" },
            { style = "camelot", mode = "big" },
            { style = "camelot", left = -1, right = -0.5, textLeft = -0.5, textRight = 3 },
        },
    },
}
BBF.TextAreaOverrides = {}

BBF.NameLayouts = {
    player = { { style = "classic", inside = true, y = -13 }, { inside = true, y = -12 }, { client = "retail", style = "retail", mode = "xl", mana = "hidden", y = 1 }, { style = "retail", y = 1.5 },
        { style = "classic", y = 2.5 }, { style = "camelot", mode = "xl", mana = "hidden", y = 3 }, { style = "camelot", mode = "xl", y = 2 },
        { style = "camelot", mode = "reduced", y = 2 }, { y = 1 } },
    target = { { style = "classic", mode = "big", mana = "hidden", inside = true, y = -13.5, own = true },
        { style = "classic", mode = "big", mana = "hidden", y = 2, own = true }, { inside = true, y = -12 }, { client = "retail", style = "retail", mode = "xl", mana = "hidden", left = 23, right = 5, centerX = -14, width = -8, centerWidth = -14, y = 0.5, own = true }, { client = "retail", style = "retail", left = 23, right = 5, centerX = -14, width = -8, centerWidth = -14, y = 1, own = true },{ style = "retail", y = 2 }, { style = "camelot", mode = "none", mana = "hidden", y = -2, own = true },
        { style = "camelot", mode = "xl", mana = "hidden", y = 2, own = true },
        { style = "camelot", mode = "big", mana = "hidden", y = 1.5, own = true }, { y = 1 } },
    tot = { { classicToT = true, below = true, y = -4 }, { inside = true, y = -10 }, { style = "pixel", y = 1 }, { style = "retail", y = 2 },
        { style = "classic", mode = "big", mana = "hidden", y = -28 }, { style = "classic", y = -29 },
        { style = "camelot", mode = "xl", mana = "hidden", y = 2 }, { style = "camelot", mode = "xl", y = 2 },
        { style = "camelot", mode = "reduced", y = 1.5 }, { y = 0.5 } },
    pet = { { inside = true, y = -10 }, { style = "retail", y = 1.5 }, { style = "camelot", mode = "xl", mana = "hidden", y = 2.5 },
        { style = "camelot", mode = "reduced", y = 2 }, { y = 1.5 } },
    party = { { inside = true, y = -10 }, { style = "retail", mode = "xl", left = -21, y = 0.5 }, { style = "retail", y = 0.5 }, { style = "classic", mode = "big", y = -1 }, { style = "classic", y = -3 }, { y = 0.5 } },
}
BBF.NameAreaOverrides = {}
local NAME_HEIGHT = { player = 12, target = 12, tot = 10, pet = 10, party = 10 }

local POINTS = { "LEFT", "CENTER", "RIGHT" }
local GROUP_ICON = { x = -1, y = 11 }
local GROUP_ICON_DEFAULT = { player = { "TOPLEFT", 86, -10 }, target = { "TOPRIGHT", -85, -8 } }
local NAME_INSIDE_Y = { player = -6, target = -6, tot = -5, pet = -5, party = -5 }
local areas = {}
local textOwner = {}
local barOwner = {}
local relayoutPending = {}

local function TotUnit(frame)
    if TargetFrame and frame == TargetFrame.totFrame then return "target" end
    if FocusFrame and frame == FocusFrame.totFrame then return "focus" end
end

local function FrameInfo(frame)
    if not frame then return end
    if frame == PlayerFrame then return "player", "player", "Player" end
    if frame == TargetFrame then return "target", "target", "Target" end
    if frame == FocusFrame then return "target", "focus", "Focus" end
    local totUnit = TotUnit(frame)
    if totUnit then return "tot", totUnit, "ToT" end
    if frame == PetFrame then return "pet", "pet", "Pet" end
    if frame.PartyMemberOverlay then return "party", "party", "Party" end
end

local function Bars(frame)
    if frame == PlayerFrame then
        local manaBar = PlayerFrame_GetManaBar()
        local container = PlayerFrame_GetHealthBarContainer()
        return (BBF.HealthBar and BBF.HealthBar(frame)) or container.HealthBar or container, manaBar,
            { LEFT = container.LeftText, CENTER = container.HealthBarText, RIGHT = container.RightText },
            { LEFT = manaBar.LeftText, CENTER = manaBar.ManaBarText, RIGHT = manaBar.RightText }
    end
    if frame == TargetFrame or frame == FocusFrame then
        local main = frame.TargetFrameContent.TargetFrameContentMain
        local container, manaBar = main.HealthBarsContainer, main.ManaBar
        return BBF.HealthBar(frame), manaBar,
            { LEFT = container.LeftText, CENTER = container.HealthBarText, RIGHT = container.RightText, DEAD = container.DeadText, UNCONSCIOUS = container.UnconsciousText },
            { LEFT = manaBar.LeftText, CENTER = manaBar.ManaBarText, RIGHT = manaBar.RightText }
    end
    if frame == PetFrame then
        return PetFrameHealthBar, PetFrameManaBar,
            { LEFT = PetFrameHealthBarTextLeft, CENTER = PetFrameHealthBarText, RIGHT = PetFrameHealthBarTextRight },
            { LEFT = PetFrameManaBarTextLeft, CENTER = PetFrameManaBarText, RIGHT = PetFrameManaBarTextRight }
    end
    if frame.PartyMemberOverlay then
        local container, manaBar = frame.HealthBarContainer, frame.ManaBar
        return container.HealthBar or container, manaBar,
            { LEFT = container.LeftText, CENTER = container.CenterText, RIGHT = container.RightText },
            { LEFT = manaBar.LeftText, CENTER = manaBar.CenterText, RIGHT = manaBar.RightText }
    end
    if TotUnit(frame) then
        local bar = frame.HealthBar
        return bar, frame.ManaBar, { DEAD = bar and bar.DeadText, UNCONSCIOUS = bar and bar.UnconsciousText }, {}
    end
    return frame.HealthBar, frame.ManaBar, {}, {}
end

function BBF.TextAreaTexts(frame)
    if not FrameInfo(frame) then return {}, {} end
    local _, _, healthTexts, manaTexts = Bars(frame)
    return healthTexts, manaTexts
end

local function ManaHidden(manaBar)
    return not manaBar:IsShown() or (manaBar.GetEffectiveAlpha and manaBar:GetEffectiveAlpha() == 0) or false
end
BBF.TextAreaManaHidden = ManaHidden

local HIDE_MANA = { Target = "hideUnitFrameTargetMana", Focus = "hideUnitFrameFocusMana" }

local function MiniFrame(unit)
    return BBF.IsMiniFrame((unit == "player" and PlayerFrame) or (unit == "target" and TargetFrame) or (unit == "focus" and FocusFrame))
end

local CLIENT = BBF.isForever and "forever" or "retail"
local CLASSIC_EXTRA_TEXT_RIGHT = 2
local CLASSIC_MANA_GROW = { bottom = 2, retailTargetRight = -4 }

local function RetailArt(unit)
    if BBF.isForever then return BBF.RetailTexturesOn and BBF.RetailTexturesOn(unit) or false end
    return not BetterBlizzFramesDB.classicFrames
end

local function SymmetricPlayer()
    if BBF.isForever then return BBF.SymmetricPlayerOn and BBF.SymmetricPlayerOn() or false end
    local db = BetterBlizzFramesDB
    return db.symmetricPlayerFrame and not db.useMiniPlayerFrame and not db.classicFrames and true or false
end

local function NoPortraitStyle(unit)
    local db = BetterBlizzFramesDB
    local on
    if unit == "party" then
        on = BBF.HasNoPortrait("party")
    else
        on = BBF.HasNoPortrait and BBF.HasNoPortrait(unit)
    end
    if on then return db.noPortraitPixelBorder and "pixel" or "noPortrait" end
end

local function HasStyleRules(key, style)
    for _, rule in ipairs(BBF.TextAreaLayouts[key].rules) do
        if rule.style == style then return true end
    end
    return false
end

function BBF.TextAreaActive(frame)
    local key, unit = FrameInfo(frame)
    if not key or MiniFrame(unit) then return false end
    if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("ClassicFrames") then return false end
    local noPortrait = NoPortraitStyle(unit)
    if noPortrait then
        return BBF.TextAreaOverrides[key] ~= nil or HasStyleRules(key, noPortrait)
    end
    return true
end

function BBF.TextAreaSetup(frame)
    local key, unit, bigKey = FrameInfo(frame)
    if not key then return end
    local db = BetterBlizzFramesDB
    local style = db.classicFrames and "classic" or "camelot"
    if RetailArt(unit) then
        style = key == "player" and SymmetricPlayer() and "symmetric" or "retail"
    end
    style = NoPortraitStyle(unit) or style
    local big = BBF.BigHealthbarsOn() and db["bigHealthbar" .. bigKey]
    local xl = db["bigHealthbarExtraLarge" .. bigKey] and not db.classicFrames and style ~= "noPortrait"
    local mode = big and (xl and "xl" or "reduced") or "none"
    local _, manaBar = Bars(frame)
    local manaHidden = manaBar and ManaHidden(manaBar) or false
    if manaHidden and key == "target" and (style == "camelot" or style == "classic") and not db[HIDE_MANA[bigKey]] then
        manaHidden = false
    end
    local inside = db.biggerHealthbarsNameInside and mode ~= "none"
        and (mode == "xl" or key == "player" or key == "target") and true or false
    return {
        key = key,
        style = style,
        mode = mode,
        inside = inside,
        manaHidden = manaHidden,
        classicToT = key == "tot" and db[unit .. "ToTNameUnder"] and not NoPortraitStyle(unit) and true or false,
    }
end

local function Matches(rule, setup)
    if rule.client and rule.client ~= CLIENT then return false end
    if rule.style and rule.style ~= setup.style then return false end
    if rule.mode == "big" then
        if setup.mode == "none" then return false end
    elseif rule.mode and rule.mode ~= setup.mode then
        return false
    end
    if rule.mana and (rule.mana == "hidden") ~= setup.manaHidden then return false end
    if rule.classicToT ~= nil and rule.classicToT ~= setup.classicToT then return false end
    if rule.inside ~= nil and rule.inside ~= setup.inside then return false end
    return true
end

local function VerticalSetup(setup)
    local copy = {}
    for k, val in pairs(setup) do copy[k] = val end
    if copy.style == "symmetric" then copy.style = "retail" end
    return copy
end

local function ClassicBase(setup)
    return { key = setup.key, style = "classic", mode = "none", manaHidden = false, classicToT = setup.classicToT, inside = false }
end

local function Owns(rule, field)
    return rule and rule.own and rule.own[field] or false
end

local function ResolveText(frame)
    local setup = BBF.TextAreaSetup(frame)
    if not setup then return end
    local cfg = BBF.TextAreaLayouts[setup.key]
    local override = BBF.TextAreaOverrides[setup.key]
    local v = {
        left = 0, right = 0, top = 0, bottom = 0,
        healthX = cfg.health.x or 0, healthY = cfg.health.y or 0,
        manaX = cfg.mana.x or 0, manaY = cfg.mana.y or 0,
        textLeft = 0, textRight = 0,
    }
    if override then
        for k, val in pairs(override) do v[k] = val end
        return v, setup
    end
    for _, rule in ipairs(cfg.rules) do
        if Matches(rule, setup) then
            v.left, v.right, v.top, v.bottom = rule.left or 0, rule.right or 0, rule.top or 0, rule.bottom or 0
            v.healthHeight, v.gap = rule.healthHeight, rule.gap
            v.healthY = rule.healthY or v.healthY
            v.manaY = rule.manaY or v.manaY
            v.textLeft, v.textRight = rule.textLeft or 0, rule.textRight or 0
            v.textCenter = rule.textCenter
            v.own = rule.own
            break
        end
    end
    if setup.style == "symmetric" then
        local retail = VerticalSetup(setup)
        for _, rule in ipairs(cfg.rules) do
            if Matches(rule, retail) then
                v.healthY = rule.healthY or cfg.health.y or 0
                v.manaY = rule.manaY or cfg.mana.y or 0
                break
            end
        end
    end
    if setup.style == "classic" then
        local base = ClassicBase(setup)
        for _, rule in ipairs(cfg.rules) do
            if Matches(rule, base) then
                for _, field in ipairs({ "left", "right", "textLeft", "textRight" }) do v[field] = rule[field] or 0 end
                break
            end
        end
        if setup.mode ~= "none" or setup.manaHidden then
            v.textRight = cfg.classicTextRight or CLASSIC_EXTRA_TEXT_RIGHT
        end
    end
    if setup.style == "camelot" then
        local base = { key = setup.key, style = "camelot", mode = "none", manaHidden = false, classicToT = setup.classicToT, inside = false }
        for _, rule in ipairs(cfg.rules) do
            if Matches(rule, base) then
                for _, field in ipairs({ "left", "right", "textLeft", "textRight" }) do
                    if not Owns(v, field) then v[field] = rule[field] or 0 end
                end
                break
            end
        end
    end
    if setup.key == "player" then
        local targetSetup = {}
        for k, val in pairs(setup) do targetSetup[k] = val end
        targetSetup.key = "target"
        if targetSetup.style == "symmetric" then targetSetup.style = "retail" end
        for _, rule in ipairs(BBF.TextAreaLayouts.target.rules) do
            if Matches(rule, targetSetup) then
                for _, field in ipairs({ "top", "bottom" }) do
                    if not Owns(v, field) and not Owns(rule, field) then v[field] = rule[field] or 0 end
                end
                for _, field in ipairs({ "healthHeight", "gap" }) do
                    if not Owns(v, field) and not Owns(rule, field) then v[field] = rule[field] end
                end
                break
            end
        end
    end
    if setup.style == "classic" and not setup.manaHidden then
        v.bottom = v.bottom + CLASSIC_MANA_GROW.bottom
        if setup.key == "target" and CLIENT == "retail" then
            v.right = v.right + CLASSIC_MANA_GROW.retailTargetRight
        end
    end
    return v, setup
end

function BBF.TextAreaResolve(frame)
    local v, setup = ResolveText(frame)
    if v and setup.key == "target" and not (setup.style == "classic" and setup.manaHidden) then
        local player = BBF.TextAreaOverrides.player
        local cfg = BBF.TextAreaLayouts.player
        local shared = { healthY = cfg.health.y or 0, manaY = cfg.mana.y or 0 }
        local source = player
        if not player then
            local playerSetup = {}
            for k, val in pairs(setup) do playerSetup[k] = val end
            playerSetup.key = "player"
            for _, rule in ipairs(cfg.rules) do
                if Matches(rule, playerSetup) then
                    source = rule
                    shared.healthY, shared.manaY = rule.healthY or shared.healthY, rule.manaY or shared.manaY
                    break
                end
            end
        end
        for field, val in pairs(shared) do
            if not Owns(v, field) and not Owns(source, field) then
                v[field] = player and player[field] or val
            end
        end
    end
    return v, setup
end

local function InsideY(setup)
    if setup.mode == "none" or not BetterBlizzFramesDB.biggerHealthbarsNameInside then return 0 end
    if (setup.key == "tot" or setup.key == "pet" or setup.key == "party") and setup.mode ~= "xl" then return 0 end
    local health = BBF.TextAreaLayouts[setup.key].health
    return health.insideY or NAME_INSIDE_Y[setup.key]
end

local realignPending = {}
local function QueueRealign(frame)
    if realignPending[frame] then return end
    realignPending[frame] = true
    C_Timer.After(0, function()
        realignPending[frame] = nil
        if areas[frame] and areas[frame]:IsShown() then
            BBF.ApplyTextArea(frame)
        end
    end)
end

local gridWatcher
local function WatchGrid()
    if gridWatcher then return end
    gridWatcher = CreateFrame("Frame")
    gridWatcher:RegisterEvent("UI_SCALE_CHANGED")
    gridWatcher:RegisterEvent("DISPLAY_SIZE_CHANGED")
    gridWatcher:SetScript("OnEvent", function()
        for frame in pairs(areas) do
            QueueRealign(frame)
        end
    end)
end

local function GetArea(frame)
    local area = areas[frame]
    if area then return area end
    area = CreateFrame("Frame", nil, frame)
    area.Health = CreateFrame("Frame", nil, area)
    area.Mana = CreateFrame("Frame", nil, area)
    areas[frame] = area
    frame.bbfTextArea = area
    hooksecurefunc(frame, "SetPoint", QueueRealign)
    hooksecurefunc(frame, "SetScale", QueueRealign)
    WatchGrid()
    return area
end

local function MeasureBars(frame, healthBar, manaBar)
    local height, healthBottom, manaTop = healthBar:GetHeight(), healthBar:GetBottom(), manaBar:GetTop()
    if issecretvalue(height) or issecretvalue(healthBottom) or issecretvalue(manaTop) then
        if frame.PartyMemberOverlay then return BBF.PartyBarGeometry(frame) end
        return
    end
    return height or 0, healthBottom and manaTop and (healthBottom - manaTop) or 1
end

local function BoxGeometry(frame, v, healthBar, manaBar)
    local healthHeight, gap = v.healthHeight, v.gap
    if not healthHeight or not gap then
        local height, measuredGap = MeasureBars(frame, healthBar, manaBar)
        if not height then return end
        healthHeight = healthHeight or (height + (v.top or 0))
        gap = gap or measuredGap
    end
    return math.max(healthHeight, 1), gap
end

local function PixelUnit(region)
    local scale = region:GetEffectiveScale()
    if not scale or issecretvalue(scale) or scale == 0 or not PixelUtil then return end
    return PixelUtil.GetPixelToUIUnitFactor() / scale, scale
end

local function SnapLength(region, length)
    local px = PixelUnit(region)
    if not px then return length end
    return math.floor(length / px + 0.5) * px
end

local function SnapPoint(region, point, relative, relativePoint, x, y)
    local px, scale = PixelUnit(region)
    if not px then
        region:SetPoint(point, relative, relativePoint, x, y)
        return
    end
    local ax = relativePoint:find("LEFT") and relative:GetLeft() or relative:GetRight()
    local ay = relativePoint:find("TOP") and relative:GetTop() or relative:GetBottom()
    local relScale = relative:GetEffectiveScale()
    if ax and ay and relScale and not (issecretvalue(ax) or issecretvalue(ay) or issecretvalue(relScale)) then
        local absX, absY = ax * relScale / scale + x, ay * relScale / scale + y
        x = x + math.floor(absX / px + 0.5) * px - absX
        y = y + math.floor(absY / px + 0.5) * px - absY
    end
    region:SetPoint(point, relative, relativePoint, x, y)
end

local function WatchMana(manaBar, frame)
    manaBar.bbfTextAreaOwner = frame
    if manaBar.bbfTextAreaWatched then return end
    manaBar.bbfTextAreaWatched = true
    local function recheck(self)
        local owner = self.bbfTextAreaOwner
        local area = owner and areas[owner]
        if area and area.manaHidden ~= ManaHidden(self) and BBF.TextAreaActive(owner) then
            BBF.ApplyTextArea(owner)
            BBF.ApplyNameArea(owner)
        end
    end
    manaBar:HookScript("OnShow", recheck)
    manaBar:HookScript("OnHide", recheck)
    hooksecurefunc(manaBar, "SetAlpha", recheck)
end

local function Relayout(frame)
    relayoutPending[frame] = nil
    local area = areas[frame]
    if not area or not area:IsShown() or not BBF.TextAreaActive(frame) then return end
    local v = BBF.TextAreaResolve(frame)
    local healthBar, manaBar = Bars(frame)
    if not v or not healthBar or not manaBar then return end
    local healthHeight, gap = BoxGeometry(frame, v, healthBar, manaBar)
    local manaChanged = ManaHidden(manaBar) ~= area.manaHidden
    if healthHeight ~= area.healthHeight or gap ~= area.gap or manaChanged then
        BBF.ApplyTextArea(frame)
    end
    if manaChanged then
        BBF.ApplyNameArea(frame)
    end
end

local function QueueRelayout(bar)
    local frame = barOwner[bar]
    if not frame or relayoutPending[frame] or not areas[frame] then return end
    relayoutPending[frame] = true
    C_Timer.After(0, function() Relayout(frame) end)
end

local function WatchBar(bar, frame)
    if barOwner[bar] then
        barOwner[bar] = frame
        return
    end
    barOwner[bar] = frame
    hooksecurefunc(bar, "SetPoint", QueueRelayout)
    hooksecurefunc(bar, "SetHeight", QueueRelayout)
    hooksecurefunc(bar, "SetSize", QueueRelayout)
    bar:HookScript("OnSizeChanged", QueueRelayout)
end

local function HookText(text, frame)
    if not text then return end
    if textOwner[text] then
        textOwner[text] = frame
        return
    end
    textOwner[text] = frame
    hooksecurefunc(text, "SetPoint", function(self)
        if self.bbfTextAreaPlacing then return end
        local owner = textOwner[self]
        if owner and BBF.TextAreaActive(owner) then
            BBF.ApplyTextArea(owner)
        end
    end)
end

local SWAPPED = { LEFT = "RIGHT", RIGHT = "LEFT" }
function BBF.StatusTextPoint(point)
    return BetterBlizzFramesDB.swapStatusBarTexts and SWAPPED[point] or point
end

local function PlaceText(text, box, point, x, y)
    if not text then return end
    text.bbfTextAreaPlacing = true
    text:ClearAllPoints()
    text:SetPoint(point, box, point, x, y)
    text.bbfTextAreaPlacing = nil
    if point ~= "CENTER" then
        text:SetJustifyH(point)
    end
end

function BBF.TextAreaBox(frame, mana)
    if not BBF.TextAreaActive(frame) then return end
    local area = areas[frame]
    return area and area:IsShown() and (mana and area.Mana or area.Health) or nil
end

local function SideInset(v, point)
    if point == "LEFT" then return v.textLeft or 0 end
    if point == "RIGHT" then return -(v.textRight or 0) end
    if point == "CENTER" then return v.textCenter or 0 end
    return 0
end

function BBF.TextAreaOffset(frame, mana, point)
    local v, setup = BBF.TextAreaResolve(frame)
    if not v then return 0, 0 end
    if mana then return v.manaX + SideInset(v, point), v.manaY end
    return v.healthX + SideInset(v, point), v.healthY + InsideY(setup)
end

function BBF.TextAreaAnchors(frame)
    if not BBF.TextAreaActive(frame) then return end
    local area = GetArea(frame)
    local x, y = BBF.TextAreaOffset(frame, false)
    local v = BBF.TextAreaResolve(frame)
    local function anchor(point)
        return { point, x + SideInset(v, point), y, relativeTo = area.Health }
    end
    return {
        HealthBarText = anchor("CENTER"),
        LeftText = anchor(BBF.StatusTextPoint("LEFT")),
        RightText = anchor(BBF.StatusTextPoint("RIGHT")),
        DeadText = anchor("CENTER"),
        UnconsciousText = anchor("CENTER"),
    }
end

local function GroupIconContext(frame)
    if frame == PlayerFrame then return PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual end
    if frame == TargetFrame or frame == FocusFrame then return frame.TargetFrameContent.TargetFrameContentContextual end
end

local function GroupIconNameY(setup)
    local override = BBF.NameAreaOverrides.player
    if override and not setup.inside then return override.y or 0 end
    local playerSetup = VerticalSetup(setup)
    playerSetup.key = "player"
    playerSetup.inside = false
    for _, rule in ipairs(BBF.NameLayouts.player) do
        if Matches(rule, playerSetup) then return rule.y or 0 end
    end
    return 0
end

local function PlaceGroupIcons(frame, area, setup, v)
    local context = GroupIconContext(frame)
    if not context then return end
    local _, unit = FrameInfo(frame)
    local retail = BBF.isForever and RetailArt(unit)
    local onName = setup.mode == "xl" or (retail and BBF.RetailNoShadowOn and BBF.RetailNoShadowOn() or false)
    local y = retail and GroupIconNameY(setup) + (onName and (frame.bbfNameBaseHeight or NAME_HEIGHT[setup.key]) / 2 or GROUP_ICON.y)
    local vertical = onName and "" or "BOTTOM"
    for _, icon in ipairs({ context.LeaderIcon, context.GuideIcon }) do
        if retail then
            icon:ClearAllPoints()
            if frame == PlayerFrame then
                icon:SetPoint(vertical .. "LEFT", area, "TOPLEFT", GROUP_ICON.x + (v.textLeft or 0), y)
            else
                icon:SetPoint(vertical .. "RIGHT", area, "TOPRIGHT", -(GROUP_ICON.x + (v.textRight or 0)), y)
            end
            icon.bbfGroupIconArea = true
        elseif icon.bbfGroupIconArea then
            icon.bbfGroupIconArea = nil
            local default = GROUP_ICON_DEFAULT[setup.key]
            icon:ClearAllPoints()
            icon:SetPoint(default[1], default[2], default[3])
        end
    end
end

local LEVEL_X = { player = -2.5, target = 1.5 }
local LEVEL_EDGE = { player = 209, target = 23 }

local function LevelText(frame)
    if frame == PlayerFrame then return PlayerLevelText end
    if frame == TargetFrame or frame == FocusFrame then return frame.TargetFrameContent.TargetFrameContentMain.LevelText end
end

function BBF.LevelOnTextArea(frame)
    if CLIENT ~= "retail" or not LevelText(frame) or not BBF.TextAreaActive(frame) then return false end
    local setup = BBF.TextAreaSetup(frame)
    return setup and setup.style == "retail" and not setup.inside or false
end

local function PlaceLevel(frame)
    local level, area = LevelText(frame), areas[frame]
    if not level then return end
    if not area or not area:IsShown() or not BBF.LevelOnTextArea(frame) then
        local default = level.bbfLevelDefault
        if level.bbfLevelArea and default then
            level.bbfLevelArea = nil
            level.bbfLevelAreaPlacing = true
            level:ClearAllPoints()
            level:SetPoint(default[1], default[2], default[3], default[4], default[5])
            level.bbfLevelAreaPlacing = nil
        end
        return
    end
    local setup = BBF.TextAreaSetup(frame)
    if not level.bbfLevelDefault and level:GetNumPoints() > 0 then
        level.bbfLevelDefault = { level:GetPoint(1) }
        level.bbfLevelDefault[5] = level.bbfLevelDefault[5] - (level.bbfShiftY or 0)
    end
    level.bbfLevelArea = true
    level.bbfShiftY = nil
    if not level.bbfLevelAreaHooked then
        level.bbfLevelAreaHooked = true
        hooksecurefunc(level, "SetPoint", function(self)
            if not self.bbfLevelAreaPlacing then PlaceLevel(frame) end
        end)
    end
    local name = BBF.NameAreaResolve(frame)
    local y = (name and name.y or 0) + (frame.bbfNameBaseHeight or NAME_HEIGHT[setup.key]) / 2
    local player = frame == PlayerFrame
    local x = player and LEVEL_X.player or LEVEL_X.target
    local frameLeft, edge = frame:GetLeft(), player and area:GetRight() or area:GetLeft()
    if issecretvalue(frameLeft) or issecretvalue(edge) then
        x = level.bbfLevelAreaX or x
    elseif frameLeft and edge then
        local ratio = area:GetEffectiveScale() / frame:GetEffectiveScale()
        x = x + frameLeft + (player and LEVEL_EDGE.player or LEVEL_EDGE.target) - edge * ratio
        level.bbfLevelAreaX = x
    end
    level.bbfLevelAreaPlacing = true
    level:ClearAllPoints()
    if player then
        level:SetPoint("RIGHT", area, "TOPRIGHT", x, y)
    else
        level:SetPoint("LEFT", area, "TOPLEFT", x, y)
    end
    level.bbfLevelAreaPlacing = nil
end

local function ApplyTextArea(frame)
    if not BBF.TextAreaActive(frame) then
        if areas[frame] then areas[frame]:Hide() end
        return false
    end
    local v, setup = BBF.TextAreaResolve(frame)
    local healthBar, manaBar, healthTexts, manaTexts = Bars(frame)
    if not v or not healthBar or not manaBar then return false end
    local area = GetArea(frame)
    WatchMana(manaBar, frame)
    WatchBar(healthBar, frame)
    WatchBar(manaBar, frame)
    area.manaHidden = ManaHidden(manaBar)
    area:SetFrameLevel(math.max(healthBar:GetFrameLevel(), manaBar:GetFrameLevel()) + 5)
    area:ClearAllPoints()
    area.Health:ClearAllPoints()
    area.Mana:ClearAllPoints()
    local healthBox, manaBox
    if setup.style == "pixel" and BBF.PixelBorderBoxes then
        healthBox, manaBox = BBF.PixelBorderBoxes(frame)
    end
    if healthBox then
        local manaHidden = setup.manaHidden or not manaBox:IsShown()
        SnapPoint(area, "TOPLEFT", healthBox, "TOPLEFT", v.left, v.top)
        SnapPoint(area, "BOTTOMRIGHT", healthBox, "BOTTOMRIGHT", v.right, manaHidden and v.bottom or 0)
        area.Health:SetAllPoints(area)
        if manaHidden then
            area.Mana:SetAllPoints(area)
        else
            SnapPoint(area.Mana, "TOPLEFT", manaBox, "TOPLEFT", v.left, 0)
            SnapPoint(area.Mana, "BOTTOMRIGHT", manaBox, "BOTTOMRIGHT", v.right, v.bottom)
        end
    elseif setup.manaHidden then
        SnapPoint(area, "TOPLEFT", healthBar, "TOPLEFT", v.left, v.top)
        SnapPoint(area, "BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", v.right, v.bottom)
        area.Health:SetAllPoints(area)
        area.Mana:SetAllPoints(area)
    else
        SnapPoint(area, "TOPLEFT", healthBar, "TOPLEFT", v.left, v.top)
        SnapPoint(area, "BOTTOMRIGHT", manaBar, "BOTTOMRIGHT", v.right, v.bottom)
        local healthHeight, gap = BoxGeometry(frame, v, healthBar, manaBar)
        area.healthHeight, area.gap = healthHeight, gap
        if healthHeight then
            healthHeight, gap = SnapLength(area, healthHeight), SnapLength(area, gap)
            area.Health:SetPoint("TOPLEFT", area, "TOPLEFT")
            area.Health:SetPoint("TOPRIGHT", area, "TOPRIGHT")
            area.Health:SetHeight(healthHeight)
            area.Mana:SetPoint("TOPLEFT", area, "TOPLEFT", 0, -(healthHeight + gap))
        else
            area.Health:SetPoint("TOPLEFT", area, "TOPLEFT")
            area.Health:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", v.right, 0)
            area.Mana:SetPoint("TOPLEFT", manaBar, "TOPLEFT", v.left, 0)
        end
        area.Mana:SetPoint("BOTTOMRIGHT", area, "BOTTOMRIGHT")
    end
    area:Show()
    local healthY = v.healthY + InsideY(setup)
    for _, info in ipairs({ { healthTexts, area.Health, v.healthX, healthY }, { manaTexts, area.Mana, v.manaX, v.manaY } }) do
        local texts, box, x, y = info[1], info[2], info[3], info[4]
        for _, point in ipairs(POINTS) do
            local text, place = texts[point], BBF.StatusTextPoint(point)
            if text and BBF.IsCenteredValueText and BBF.IsCenteredValueText(text) then
                place = "CENTER"
            end
            HookText(text, frame)
            PlaceText(text, box, place, x + SideInset(v, place), y)
        end
        for _, extra in ipairs({ "DEAD", "UNCONSCIOUS" }) do
            HookText(texts[extra], frame)
            PlaceText(texts[extra], box, "CENTER", x + SideInset(v, "CENTER"), y)
        end
    end
    for _, point in ipairs(POINTS) do
        local text = manaTexts[point]
        if text then
            local detached = text:GetParent() ~= manaBar
            if area.manaHidden and detached then
                text.bbfTextAreaHidden = true
                text:SetAlpha(0)
            elseif text.bbfTextAreaHidden then
                text.bbfTextAreaHidden = nil
                text:SetAlpha(1)
            end
        end
    end
    PlaceGroupIcons(frame, area, setup, v)
    PlaceLevel(frame)
    return true
end

local applyingText = {}
function BBF.ApplyTextArea(frame)
    if not frame then return false end
    if applyingText[frame] then return areas[frame] ~= nil and areas[frame]:IsShown() end
    applyingText[frame] = true
    local ok, result = pcall(ApplyTextArea, frame)
    applyingText[frame] = nil
    if not ok then error(result, 0) end
    return result
end

local nameBoxes = {}

local function ResolveName(frame)
    if not BBF.TextAreaActive(frame) then return end
    local setup = BBF.TextAreaSetup(frame)
    if not setup then return end
    local override = BBF.NameAreaOverrides[setup.key]
    if override then return override, setup end
    local nameSetup = VerticalSetup(setup)
    local rules = BBF.NameLayouts[setup.key] or {}
    for _, rule in ipairs(rules) do
        if Matches(rule, nameSetup) then
            local v = { left = rule.left or 0, right = rule.right or 0, y = rule.y or 0, below = rule.below or nil, own = rule.own, centerX = rule.centerX, width = rule.width, centerWidth = rule.centerWidth }
            if setup.style == "classic" then
                local base = ClassicBase(setup)
                for _, baseRule in ipairs(rules) do
                    if Matches(baseRule, base) then
                        v.left, v.right = baseRule.left or 0, baseRule.right or 0
                        break
                    end
                end
            end
            return v, setup
        end
    end
end

function BBF.NameAreaResolve(frame)
    local v, setup = ResolveName(frame)
    if not v or setup.key ~= "target" or v.own then return v, setup end
    local synced = {}
    for k, val in pairs(v) do synced[k] = val end
    local player = BBF.NameAreaOverrides.player
    if player then
        if not player.own then synced.y = player.y end
    else
        local playerSetup = {}
        for k, val in pairs(setup) do playerSetup[k] = val end
        playerSetup.key = "player"
        for _, rule in ipairs(BBF.NameLayouts.player) do
            if Matches(rule, playerSetup) then
                if not rule.own then synced.y = rule.y or 0 end
                break
            end
        end
    end
    return synced, setup
end

function BBF.NameAreaBox(frame)
    local v, setup = BBF.NameAreaResolve(frame)
    local box = nameBoxes[frame]
    if not v then
        if box then box:Hide() end
        return
    end
    local area = areas[frame]
    if not area or not area:IsShown() then
        if not BBF.ApplyTextArea(frame) then return end
        area = areas[frame]
    end
    if not box then
        box = CreateFrame("Frame", nil, frame)
        nameBoxes[frame] = box
        frame.bbfNameBox = box
    end
    box:ClearAllPoints()
    local db = BetterBlizzFramesDB
    local shift = db.centerNames and v.centerX or 0
    local left, right = (v.left or 0) + shift, (v.right or 0) + shift
    if db.centerNames then
        local shrink = v.centerWidth or 0
        left, right = left - shrink / 2, right + shrink / 2
    elseif db.mirroredNames then
        left = left - (v.width or 0)
    else
        right = right + (v.width or 0)
    end
    if v.below then
        box:SetPoint("TOPLEFT", area, "BOTTOMLEFT", left, v.y or 0)
        box:SetPoint("TOPRIGHT", area, "BOTTOMRIGHT", right, v.y or 0)
    else
        box:SetPoint("BOTTOMLEFT", area, "TOPLEFT", left, v.y or 0)
        box:SetPoint("BOTTOMRIGHT", area, "TOPRIGHT", right, v.y or 0)
    end
    box.bbfHeight = frame.bbfNameBaseHeight or NAME_HEIGHT[setup.key]
    box:SetHeight(box.bbfHeight)
    box:Show()
    return box
end

local nameOwner = {}

local function NameLayoutKey(frame)
    if frame == PlayerFrame then return "player" end
    if frame == TargetFrame then return "target" end
    if frame == FocusFrame then return "focus" end
    if frame == PetFrame then return "pet" end
    local unit = TotUnit(frame)
    return unit and (unit .. "ToT")
end

local function NameFontStrings(frame)
    if frame.PartyMemberOverlay then return { frame.Name, frame.bbfName } end
    return { frame.bbfName }
end

local partyAlign = { Left = "LEFT", Center = "CENTER", Right = "RIGHT" }

local function PlacePartyName(name, box)
    local drag = name.bbfDragBox
    if drag then
        local inset = drag.inset * drag:GetEffectiveScale() / name:GetEffectiveScale()
        local moveScale = name.bbfMoveScale or 1
        local extraX, extraY = (drag.extraX or 0) / moveScale, (drag.extraY or 0) / moveScale
        name:ClearAllPoints()
        name:SetPoint("TOPLEFT", drag, "TOPLEFT", inset + extraX, -inset + extraY)
        name:SetPoint("BOTTOMRIGHT", drag, "BOTTOMRIGHT", -inset + extraX, inset + extraY)
        return
    end
    local db = BetterBlizzFramesDB
    local moved = db and db.moveNames
    local dx = moved and tonumber(db.moveNamePartyX) or 0
    local dy = moved and tonumber(db.moveNamePartyY) or 0
    local dw = moved and tonumber(db.moveNamePartyWidth) or 0
    local justify = (db and db.centerNames and "CENTER") or (moved and partyAlign[db.moveNamePartyAlign]) or name:GetJustifyH()
    local left = justify == "RIGHT" and dw or justify == "CENTER" and dw / 2 or 0
    local scale = BBF.GetNameMoveScale and BBF.GetNameMoveScale("moveNameParty") or 1
    local multiLine = moved and db.moveNamePartyMultiLine and true or false
    local edge = moved and db.moveNamePartyGrowDown and "TOP" or "BOTTOM"
    local boxHeight = box.bbfHeight
    if multiLine then
        local _, fontHeight = name:GetFont()
        if boxHeight and fontHeight then
            local nudge = (boxHeight - fontHeight) / 2
            dy = dy + (edge == "BOTTOM" and nudge or -nudge)
        end
    end
    local x1, y1, x2, y2 = dx - left, dy, dx + dw - left, dy
    if BBF.SetNameMoveScale then
        BBF.SetNameMoveScale(name, scale)
    end
    if scale ~= 1 then
        local boxWidth = box:GetWidth()
        if issecretvalue(boxWidth) then boxWidth = nil end
        x1, y1, x2, y2 = BBF.ScaleNameBox(justify, boxWidth and boxWidth + dw, not multiLine and boxHeight, scale, x1, y1, x2, y2)
    end
    name:ClearAllPoints()
    name:SetWordWrap(multiLine)
    if name.SetMaxLines then
        name:SetMaxLines(multiLine and 3 or 0)
    end
    name.bbfMultiLine = multiLine or nil
    if multiLine then
        name:SetPoint(edge .. "LEFT", box, edge .. "LEFT", x1, y1)
        name:SetPoint(edge .. "RIGHT", box, edge .. "RIGHT", x2, y2)
        name:SetHeight(0)
    else
        name:SetPoint("TOPLEFT", box, "TOPLEFT", x1, y1)
        name:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", x2, y2)
    end
    if name:GetJustifyH() ~= justify then
        name:SetJustifyH(justify)
        local text = name:GetText()
        name:SetText("")
        name:SetText(text)
    end
end

local function PlaceGuarded(name, func)
    name.bbfNameBoxPlacing = true
    func()
    name.bbfNameBoxPlacing = nil
end

local function ApplyNameArea(frame)
    local box = BBF.NameAreaBox(frame)
    if not box then return false end
    for _, name in pairs(NameFontStrings(frame)) do
        nameOwner[name] = frame
        name.bbfNameAreaOwner = frame
        if not name.bbfNameBoxHooked then
            name.bbfNameBoxHooked = true
            hooksecurefunc(name, "SetPoint", function(self)
                if self.bbfNameBoxPlacing then return end
                local owner = nameOwner[self]
                if owner and BBF.NameAreaResolve(owner) then
                    BBF.ApplyNameArea(owner)
                end
            end)
        end
    end
    if frame.PartyMemberOverlay then
        for _, name in pairs(NameFontStrings(frame)) do
            PlaceGuarded(name, function()
                PlacePartyName(name, box)
            end)
        end
    elseif frame.bbfName and BBF.ApplyNameLayout then
        PlaceGuarded(frame.bbfName, function()
            BBF.ApplyNameLayout(NameLayoutKey(frame))
        end)
    end
    return true
end

local applyingName = {}
function BBF.ApplyNameArea(frame)
    if not frame then return false end
    if applyingName[frame] then return nameBoxes[frame] ~= nil end
    applyingName[frame] = true
    local ok, result = pcall(ApplyNameArea, frame)
    applyingName[frame] = nil
    if not ok then error(result, 0) end
    return result
end

function BBF.RefreshTextAreas()
    local frames = { PlayerFrame, TargetFrame, FocusFrame, PetFrame, TargetFrame and TargetFrame.totFrame, FocusFrame and FocusFrame.totFrame }
    if PartyFrame then
        for i = 1, 4 do
            frames[#frames + 1] = PartyFrame["MemberFrame" .. i]
        end
    end
    for _, frame in pairs(frames) do
        if frame then
            BBF.ApplyTextArea(frame)
            BBF.ApplyNameArea(frame)
        end
    end
    if BBF.PlaceTotStatusTexts then
        BBF.PlaceTotStatusTexts(true)
    end
    if BBF.ApplyNameLayouts then
        BBF.ApplyNameLayouts()
    end
    if BBF.UpdatePartyRoleIcons then
        BBF.UpdatePartyRoleIcons()
    end
end
