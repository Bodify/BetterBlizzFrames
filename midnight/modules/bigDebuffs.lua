-- Huge thanks to Verz and Muleyo.
-- Verz for helping with this in the past and many other things and
-- Muleyo for helping me with questions and examples about the new aura systems in 12.1

-- Auras Blizzard doesn't flag as CROWD_CONTROL
local OTHER_CC = {
    -- CC
    [383005] = true,    -- Chrono Loop
    -- Disarms
    [207777] = true,    -- Dismantle (Rogue)
    [236077] = true,    -- Disarm (Warrior)
    [233759] = true,    -- Grapple Weapon (Monk)
    [407028] = true,    -- Sticky Tar Bomb (Hunter)
    [209749] = true,    -- Faerie Swarm (Druid)
}

-- Other auras that are nice to know.
local OTHER_DEBUFFS = {
    [41425] = true,     -- Hypothermia
    [25771] = true,     -- Forbearance
    [372048] = true,    -- Oppressing Roar
    [212182] = true,    -- Smoke Bomb
    [359053] = true,    -- Smoke Bomb
    [121164] = true,    -- Orb of Power
    [121175] = true,    -- Orb of Power
    [121176] = true,    -- Orb of Power
    [121177] = true,    -- Orb of Power
}

local TIERS = {
    { key = "OtherDebuffs", filter = "HARMFUL", needsSpellIDs = true, candidateFilters = { includeSpellIDs = OTHER_DEBUFFS } },
    { key = "ExtDef",       filter = "HELPFUL|EXTERNAL_DEFENSIVE" },
    { key = "BigDef",       filter = "HELPFUL|BIG_DEFENSIVE" },
    { key = "Important",    filter = "HELPFUL|IMPORTANT|!BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE" },
    { key = "OtherCC",      filter = "HARMFUL", needsSpellIDs = true, candidateFilters = { includeSpellIDs = OTHER_CC } },
    { key = "CC",           filter = "HARMFUL|CROWD_CONTROL" },
}

local SORT_METHOD = AuraContainerSortMethod.ExpirationOnly
local SORT_DIRECTION = AuraContainerSortDirection.Reverse

local SWIPE_TEXTURE = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask"
local ALWAYS_ASSISTABLE = { player = true, pet = true }

local hosts = {}
local buildQueued = false
local hostsEnabled = false

local STRATA_BELOW = {
    BACKGROUND = "BACKGROUND",
    LOW = "BACKGROUND",
    MEDIUM = "LOW",
    HIGH = "MEDIUM",
    DIALOG = "HIGH",
    FULLSCREEN = "DIALOG",
    FULLSCREEN_DIALOG = "FULLSCREEN",
    TOOLTIP = "FULLSCREEN_DIALOG",
}

local function InitIcon(host, button)
    button:SetAllPoints(host.anchor)

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints(button)
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    if host.portraitMask then
        icon:AddMaskTexture(host.portraitMask)
    end
    button:SetIcon(icon)

    local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetAllPoints(button)
    cooldown:SetUsingParentLevel(true)
    cooldown:SetReverse(true)
    cooldown:SetDrawBling(false)
    cooldown:SetDrawEdge(false)
    cooldown:SetSwipeTexture(SWIPE_TEXTURE)
    button:SetDurationCooldown(cooldown)

    button:EnableMouse(false)
end

local function CreateHost(unit, unitFrame, portrait, portraitMask)
    if not portrait then return end

    local portraitParent = portrait:GetParent()
    local strata = STRATA_BELOW[portraitParent:GetFrameStrata()] or "BACKGROUND"
    local point, relTo, relPoint, x, y = portrait:GetPoint()
    if not point then return end

    local portraitLayer = CreateFrame("Frame", nil, portraitParent)
    portraitLayer:SetAllPoints(portraitParent)
    portraitLayer:SetFrameStrata(strata)
    portraitLayer:SetFrameLevel(0)

    portrait:SetParent(portraitLayer)
    portrait:ClearAllPoints()
    portrait:SetPoint(point, relTo or portraitLayer, relPoint or point, x or 0, y or 0)

    local anchor = CreateFrame("Frame", nil, portraitLayer, BBF.AURA_ANCHOR_TEMPLATE)
    anchor:SetPoint(point, relTo or portraitLayer, relPoint or point, x or 0, y or 0)
    anchor:SetSize(portrait:GetSize())
    anchor:SetFrameStrata(strata)
    anchor:SetFrameLevel(0)

    local host = {
        unit = unit,
        anchor = anchor,
        portraitLayer = portraitLayer,
        portraitMask = portraitMask,
        containers = {},
    }

    for index, tier in ipairs(TIERS) do
        if not (tier.needsSpellIDs and ALWAYS_ASSISTABLE[unit]) then
            local container = CreateFrame("AuraContainer", nil, anchor, "CustomAuraContainerTemplate")
            container:SetAllPoints(anchor)
            container:SetUnit(unit)
            container:SetFrameStrata(strata)
            container:SetFrameLevel(index)
            container:SetEnabled(false)
            container:Hide()

            container:AddAuraSlot("Aura", tier.filter, {
                sortMethod = SORT_METHOD,
                sortDirection = SORT_DIRECTION,
                candidateFilters = tier.candidateFilters,
                initializeFrame = function(button) InitIcon(host, button) end,
            })

            host.containers[index] = container
        end
    end

    hosts[unit] = host
    unitFrame.bbfBigDebuff = anchor
end

local function UpdateHostContainers(host)
    local spellIDsUsable = BBF.CanFilterBySpellID(host.unit, false)

    for index, tier in ipairs(TIERS) do
        local container = host.containers[index]
        if container then
            local on = hostsEnabled and (not tier.needsSpellIDs or spellIDsUsable)
            container:SetEnabled(on)
            container:SetShown(on)
        end
    end
end

local function SetHostsEnabled(enabled)
    hostsEnabled = enabled

    for _, host in pairs(hosts) do
        UpdateHostContainers(host)
    end
end

local function RefreshHost(unit)
    local host = hosts[unit]
    if not host then return end

    UpdateHostContainers(host)

    for index = 1, #TIERS do
        local container = host.containers[index]
        if container and container:IsShown() then
            container:UpdateAllAuras()
        end
    end
end

local unitWatcher

local function CreateUnitWatcher()
    if unitWatcher then return end

    unitWatcher = CreateFrame("Frame")
    unitWatcher:RegisterEvent("PLAYER_TARGET_CHANGED")
    unitWatcher:RegisterEvent("PLAYER_FOCUS_CHANGED")
    unitWatcher:RegisterUnitEvent("UNIT_PET", "player")
    unitWatcher:RegisterUnitEvent("UNIT_FACTION", "target", "focus")
    unitWatcher:SetScript("OnEvent", function(_, event, unit)
        if event == "PLAYER_TARGET_CHANGED" then
            RefreshHost("target")
        elseif event == "PLAYER_FOCUS_CHANGED" then
            RefreshHost("focus")
        elseif event == "UNIT_FACTION" then
            RefreshHost(unit)
        else
            RefreshHost("pet")
        end
    end)
end

local function BuildHosts()
    if next(hosts) then return true end
    if InCombatLockdown() then return false end

    CreateHost("player", PlayerFrame,
        PlayerFrame.PlayerFrameContainer.PlayerPortrait,
        PlayerFrame.PlayerFrameContainer.PlayerPortraitMask)

    CreateHost("target", TargetFrame,
        TargetFrame.TargetFrameContainer.Portrait,
        TargetFrame.TargetFrameContainer.PortraitMask)

    CreateHost("focus", FocusFrame,
        FocusFrame.TargetFrameContainer.Portrait,
        FocusFrame.TargetFrameContainer.PortraitMask)

    CreateHost("pet", PetFrame,
        PetPortrait,
        PetFrame.PortraitMask)

    CreateUnitWatcher()

    return true
end

function BBF.CreateBigDebuffs()
    if not BetterBlizzFramesDB.enableBigDebuffs then
        SetHostsEnabled(false)
        return
    end

    if C_AddOns.IsAddOnLoaded("MiniAuras") or C_AddOns.IsAddOnLoaded("MvqUI") or BetterBlizzFramesDB.noPortraitModes then return end

    if not BuildHosts() then
        if not buildQueued then
            buildQueued = true
            local combatEnd = CreateFrame("Frame")
            combatEnd:RegisterEvent("PLAYER_REGEN_ENABLED")
            combatEnd:SetScript("OnEvent", function(self)
                self:UnregisterAllEvents()
                self:SetScript("OnEvent", nil)
                buildQueued = false
                BBF.CreateBigDebuffs()
            end)
        end
        return
    end

    SetHostsEnabled(true)
end
