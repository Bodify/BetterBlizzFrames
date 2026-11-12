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
    [407032] = true,    -- Sticky Tar Bomb (Hunter)
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
    [77606] = true,     -- Dark Simulacrum
    [356723] = true,    -- Scorpid Venom (90% slow with silence after)
    [80240] = true,     -- Havoc
}

-- Friendly buffs that are nice to know.
local OTHER_BUFFS = {
}

-- Auras Blizzard flags as CROWD_CONTROL that aren't CC
local CC_BLACKLIST = {
    [1280457] = true,   -- Mind Flay (Priest)
}

local INTERRUPTS = {
    [1766]   = 3,       -- Kick (Rogue)
    [2139]   = 5,       -- Counterspell (Mage)
    [6552]   = 3,       -- Pummel (Warrior)
    [19647]  = 5,       -- Spell Lock (Warlock)
    [47528]  = 3,       -- Mind Freeze (Death Knight)
    [57994]  = 2,       -- Wind Shear (Shaman)
    [91802]  = 2,       -- Shambling Rush (Death Knight)
    [96231]  = 3,       -- Rebuke (Paladin)
    [106839] = 3,       -- Skull Bash (Druid)
    [93985]  = 3,       -- Skull Bash (Druid)
    [115781] = 5,       -- Optical Blast (Warlock)
    [116705] = 3,       -- Spear Hand Strike (Monk)
    [132409] = 5,       -- Spell Lock (Warlock)
    [119910] = 5,       -- Spell Lock (Warlock Pet)
    [89766]  = 3,       -- Axe Toss (Warlock Pet)
    [147362] = 3,       -- Counter Shot (Hunter)
    [171138] = 5,       -- Shadow Lock (Warlock)
    [183752] = 3,       -- Disrupt (Demon Hunter)
    [187707] = 3,       -- Muzzle (Hunter)
    [212619] = 5,       -- Call Felhunter (Warlock)
    [231665] = 3,       -- Avenger's Shield (Paladin)
    [351338] = 4,       -- Quell (Evoker)
    [97547]  = 5,       -- Solar Beam (Druid)
    [78675]  = 5,       -- Solar Beam (Druid)
}

local SPEC_INTERRUPTS = {
    [250] = 47528, [251] = 47528, [252] = 47528,
    [577] = 183752, [581] = 183752, [1480] = 183752,
    [102] = 78675, [103] = 106839, [104] = 106839, [105] = false,
    [1467] = 351338, [1468] = false, [1473] = false,
    [253] = 147362, [254] = 147362, [255] = 187707,
    [62] = 2139, [63] = 2139, [64] = 2139,
    [268] = 116705, [270] = false, [269] = 116705,
    [65] = false, [66] = 96231, [70] = 96231,
    [259] = 1766, [260] = 1766, [261] = 1766,
    [262] = 57994, [263] = 57994, [264] = 57994,
    [265] = 132409, [266] = 132409, [267] = 132409,
    [71] = 6552, [72] = 6552, [73] = 6552,
}

local CLASS_INTERRUPTS = {
    DEATHKNIGHT = 47528,
    DEMONHUNTER = 183752,
    DRUID       = 106839,
    EVOKER      = 351338,
    HUNTER      = 147362,
    MAGE        = 2139,
    MONK        = 116705,
    PALADIN     = 96231,
    ROGUE       = 1766,
    SHAMAN      = 57994,
    WARLOCK     = 132409,
    WARRIOR     = 6552,
}

local MELEE_INTERRUPTS = {
    [1766]   = true,    -- Kick
    [6552]   = true,    -- Pummel
    [47528]  = true,    -- Mind Freeze
    [96231]  = true,    -- Rebuke
    [106839] = true,    -- Skull Bash
    [116705] = true,    -- Spear Hand Strike
    [183752] = true,    -- Disrupt
    [187707] = true,    -- Muzzle
}

local DEFAULT_INTERRUPT_DURATION = 3

local TIERS = {
    { key = "OtherDebuffs", filter = "HARMFUL", needsSpellIDs = true, spellList = OTHER_DEBUFFS, customKey = "bigDebuffsCustomDebuffs" },
    { key = "OtherBuffs",   filter = "HELPFUL", needsSpellIDs = true, helpful = true, spellList = OTHER_BUFFS, customKey = "bigDebuffsCustomBuffs" },
    { key = "ExtDef",       filter = "HELPFUL|EXTERNAL_DEFENSIVE" },
    { key = "BigDef",       filter = "HELPFUL|BIG_DEFENSIVE" },
    { key = "Important",    filter = "HELPFUL|IMPORTANT|!BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE" },
    { key = "Interrupt",    interrupt = true },
    { key = "OtherCC",      filter = "HARMFUL", needsSpellIDs = true, candidateFilters = { includeSpellIDs = OTHER_CC } },
    { key = "CC",           filter = "HARMFUL|CROWD_CONTROL", candidateFilters = { excludeSpellIDs = CC_BLACKLIST } },
}

local INTERRUPT_INDEX
for index, tier in ipairs(TIERS) do
    if tier.interrupt then
        INTERRUPT_INDEX = index
    end
end

local INTERRUPT_ICON = 132219
local KICK_WINDOW = 0.1
local GetSpellTexture = C_Spell.GetSpellTexture

local SORT_METHOD = AuraContainerSortMethod.ExpirationOnly
local SORT_DIRECTION = AuraContainerSortDirection.Reverse

local SWIPE_TEXTURE = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask"
local ALWAYS_ASSISTABLE = { player = true, pet = true }

local OFF_FILTERS = { includeSpellIDs = {} }

local hosts = {}
local partyHosts = {}
local mainBuilt = false
local partyBuilt = false
local buildQueued = false
local hostsEnabled = false
local cooldowns = {}

local TEXT_SIZE_BASE = 1.3
local PREVIEW_DURATION = 8
local PREVIEW_ICON = 136071
local previewTicker

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

local function BuildTierFilters()
    local db = BetterBlizzFramesDB
    for _, tier in ipairs(TIERS) do
        if tier.customKey then
            local ids = CopyTable(tier.spellList)
            for spellID in pairs(db[tier.customKey]) do
                ids[spellID] = true
            end
            for spellID in pairs(db.bigDebuffsBlacklist) do
                ids[spellID] = nil
            end
            tier.candidateFilters = { includeSpellIDs = ids }
            tier.empty = next(ids) == nil
        end
    end
end

local function ApplyTimerStyle(cooldown)
    local db = BetterBlizzFramesDB
    local formatter = BBF.GetTimerFormatter(db.bigDebuffsLowColor or { 1, 0.1, 0.1, 1 }, db.bigDebuffsLowThreshold or 6, db.bigDebuffsMilliseconds, false, nil, db.bigDebuffsHighThreshold or 30, db.bigDebuffsHighColor or { 1, 1, 1, 1 })
    cooldown:SetCountdownFormatter(formatter)
    cooldown:SetHideCountdownNumbers(db.bigDebuffsHideTimer and true or false)
    local text = cooldown:GetCountdownFontString()
    if text then
        local c = db.bigDebuffsBaseColor or { 1, 0.82, 0, 1 }
        text:SetTextColor(c[1], c[2], c[3], c[4] or 1)
        local base = cooldown.bbfBaseFont
        if not base then
            local font, size, flags = text:GetFont()
            base = { font, size, flags }
            cooldown.bbfBaseFont = base
        end
        if base[1] and base[2] then
            text:SetFont(base[1], base[2] * TEXT_SIZE_BASE * (db.bigDebuffsTextScale or 1), base[3])
        end
    end
end

local function CreateCooldown(parent)
    local cooldown = CreateFrame("Cooldown", nil, parent, "CooldownFrameTemplate")
    cooldown:SetMinimumCountdownDuration(0)
    cooldown:SetAllPoints(parent)
    cooldown:SetUsingParentLevel(true)
    cooldown:SetReverse(true)
    cooldown:SetDrawBling(false)
    cooldown:SetDrawEdge(false)
    cooldown:SetSwipeTexture(SWIPE_TEXTURE)
    ApplyTimerStyle(cooldown)
    cooldowns[#cooldowns + 1] = cooldown
    return cooldown
end

function BBF.UpdateBigDebuffsTimers()
    for _, cooldown in ipairs(cooldowns) do
        ApplyTimerStyle(cooldown)
    end
end

local function InitIcon(host, button, level)
    button:SetAllPoints(host.anchor)
    button:SetFrameLevel(level)

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints(button)
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    if host.portraitMask then
        icon:AddMaskTexture(host.portraitMask)
    end
    button:SetIcon(icon)

    button:SetDurationCooldown(CreateCooldown(button))

    button:EnableMouse(false)
end

local INTERRUPT_UNITS = { player = true, target = true, focus = true }
local KICK_UNITS = { "target", "focus" }
local CAST_START = {
    UNIT_SPELLCAST_START = true,
    UNIT_SPELLCAST_CHANNEL_START = true,
    UNIT_SPELLCAST_EMPOWER_START = true,
}
local CAST_STOP = {
    UNIT_SPELLCAST_INTERRUPTED = true,
    UNIT_SPELLCAST_CHANNEL_STOP = true,
    UNIT_SPELLCAST_EMPOWER_STOP = true,
}

local interruptsOn = false
local kickEvents
local lastKick = { time = -math.huge }
local kicks = {}

local function CreateInterruptSlot(host)
    local slot = CreateFrame("Frame", nil, host.anchor)
    slot:SetAllPoints(host.anchor)
    slot:SetFrameStrata(host.container:GetFrameStrata())
    slot:SetFrameLevel(host.container:GetFrameLevel() + INTERRUPT_INDEX)

    local icon = slot:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints(slot)
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    if host.portraitMask then
        icon:AddMaskTexture(host.portraitMask)
    end

    slot.icon = icon
    slot.cooldown = CreateCooldown(slot)
    slot:Hide()
    host.interrupt = slot
end

local function UpdateInterruptSlot(host)
    local slot = host.interrupt
    if not slot then return end

    local kick = interruptsOn and host.kick
    if kick then
        slot.icon:SetTexture(kick.texture)
        slot.cooldown:SetCooldown(kick.start, kick.duration)
        slot:Show()
    else
        slot.cooldown:Clear()
        slot:Hide()
    end
end

local function UpdatePlayerInterrupt()
    local host = hosts.player
    if not host or not host.interrupt then return end

    local slot = host.interrupt
    local data = interruptsOn and BBF.LoC.GetInterrupt()
    if data then
        slot.icon:SetTexture(data.iconTexture)
        BBF.LoC.SetCooldown(slot.cooldown, data)
        slot:Show()
    else
        slot.cooldown:Clear()
        slot:Hide()
    end
end

local function RestoreKick(unit)
    local host = hosts[unit]
    if not host or not host.interrupt then return end

    host.counted = nil
    local guid = UnitGUID(unit)
    if issecretvalue(guid) then
        guid = nil
    end
    host.kick = guid and kicks[guid]
    UpdateInterruptSlot(host)
end

local function SetKick(unit, texture, duration)
    local host = hosts[unit]
    local kick = { texture = texture, start = GetTime(), duration = duration }
    local guid = UnitGUID(unit)
    if issecretvalue(guid) then
        guid = nil
    end
    if guid then
        kicks[guid] = kick
    end

    C_Timer.NewTimer(duration, function()
        if guid and kicks[guid] == kick then
            kicks[guid] = nil
        end
        for _, kickUnit in ipairs(KICK_UNITS) do
            local kickHost = hosts[kickUnit]
            if kickHost and kickHost.kick == kick then
                kickHost.kick = nil
                UpdateInterruptSlot(kickHost)
            end
        end
    end)

    host.kick = kick
    UpdateInterruptSlot(host)
end

local function KickInfo(spellID)
    return GetSpellTexture(spellID) or INTERRUPT_ICON, INTERRUPTS[spellID] or DEFAULT_INTERRUPT_DURATION
end

local function PartyInterrupt(unit)
    local specID = BBF.GetSpecID(unit)
    if specID and SPEC_INTERRUPTS[specID] ~= nil then
        return SPEC_INTERRUPTS[specID]
    end
    return CLASS_INTERRUPTS[UnitClassBase(unit)]
end

local function SameUnit(unit1, unit2)
    if not UnitExists(unit1) then return end

    local name1, name2 = UnitName(unit1), UnitName(unit2)
    if issecretvalue(name1) or issecretvalue(name2) then return end

    return name1 == name2
end

local function GuessPartyKick(kickedUnit)
    local onlyInterrupt, onlyMelee, onlyRanged
    local count, meleeOnTarget, rangedCount = 0, 0, 0
    local targetsKnown = true

    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) then
            local interrupt = PartyInterrupt(unit)
            if interrupt then
                count = count + 1
                onlyInterrupt = interrupt
                if MELEE_INTERRUPTS[interrupt] then
                    local onTarget = SameUnit(unit .. "target", kickedUnit)
                    if onTarget == nil and UnitExists(unit .. "target") then
                        targetsKnown = false
                    elseif onTarget then
                        meleeOnTarget = meleeOnTarget + 1
                        onlyMelee = interrupt
                    end
                else
                    rangedCount = rangedCount + 1
                    onlyRanged = interrupt
                end
            end
        end
    end

    if count == 1 then
        return KickInfo(onlyInterrupt)
    end
    if meleeOnTarget == 1 then
        return KickInfo(onlyMelee)
    end
    if meleeOnTarget == 0 and targetsKnown and rangedCount == 1 then
        return KickInfo(onlyRanged)
    end
    return INTERRUPT_ICON, DEFAULT_INTERRUPT_DURATION
end

local function GuessKick(unit)
    if GetTime() - lastKick.time <= KICK_WINDOW then
        return lastKick.texture, lastKick.duration
    end
    if not UnitIsEnemy("player", unit) then
        return INTERRUPT_ICON, DEFAULT_INTERRUPT_DURATION
    end
    return GuessPartyKick(unit)
end

local function OnKickEvent(_, event, unit, _, spellID, arg4, arg5)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        if issecretvalue(spellID) then return end
        local duration = INTERRUPTS[spellID]
        if not duration then return end
        lastKick.texture = GetSpellTexture(spellID) or INTERRUPT_ICON
        lastKick.duration = duration
        lastKick.time = GetTime()
        return
    end

    if event == "LOSS_OF_CONTROL_ADDED" or event == "LOSS_OF_CONTROL_UPDATE" then
        UpdatePlayerInterrupt()
        return
    end

    local host = hosts[unit]
    if not host then return end

    if CAST_START[event] then
        host.counted = nil
        return
    end

    local interruptedBy
    if event == "UNIT_SPELLCAST_EMPOWER_STOP" then
        interruptedBy = arg5
    else
        interruptedBy = arg4
    end
    if not issecretvalue(interruptedBy) and interruptedBy == nil then return end
    if host.counted then return end
    host.counted = true

    C_Timer.After(0, function()
        if interruptsOn then
            SetKick(unit, GuessKick(unit))
        end
    end)
end

function BBF.UpdateBigDebuffsInterrupts()
    local on = hostsEnabled and BetterBlizzFramesDB.bigDebuffsInterrupts and true or false
    if on ~= interruptsOn then
        interruptsOn = on
        if on then
            kickEvents = kickEvents or CreateFrame("Frame")
            kickEvents:SetScript("OnEvent", OnKickEvent)
            kickEvents:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player", "pet")
            kickEvents:RegisterUnitEvent("LOSS_OF_CONTROL_ADDED", "player")
            kickEvents:RegisterUnitEvent("LOSS_OF_CONTROL_UPDATE", "player")
            for event in pairs(CAST_START) do
                kickEvents:RegisterUnitEvent(event, "target", "focus")
            end
            for event in pairs(CAST_STOP) do
                kickEvents:RegisterUnitEvent(event, "target", "focus")
            end
        elseif kickEvents then
            kickEvents:UnregisterAllEvents()
            wipe(kicks)
            for _, unit in ipairs(KICK_UNITS) do
                local host = hosts[unit]
                if host then
                    host.kick = nil
                end
            end
        end
    end

    for _, unit in ipairs(KICK_UNITS) do
        local host = hosts[unit]
        if host then
            UpdateInterruptSlot(host)
        end
    end
    UpdatePlayerInterrupt()
end

local function CreateHost(unit, unitFrame, portrait, portraitMask)
    if not portrait then return end

    local portraitParent = portrait:GetParent()
    local strata = STRATA_BELOW[portraitParent:GetFrameStrata()] or "BACKGROUND"

    local portraitLayer = CreateFrame("Frame", nil, portraitParent)
    portraitLayer:SetAllPoints(portraitParent)
    portraitLayer:SetFrameStrata(strata)
    portraitLayer:SetFrameLevel(0)

    portrait:SetParent(portraitLayer)

    local anchor = CreateFrame("Frame", nil, portraitLayer, BBF.AURA_ANCHOR_TEMPLATE)
    anchor:SetAllPoints(portrait)
    anchor:SetFrameStrata(strata)
    anchor:SetFrameLevel(0)

    local container = CreateFrame("AuraContainer", nil, anchor, "CustomAuraContainerTemplate")
    container:SetAllPoints(anchor)
    container:SetUnit(unit)
    container:SetFrameStrata(strata)
    container:SetFrameLevel(1)
    container:SetEnabled(false)
    container:Hide()

    local host = {
        unit = unit,
        anchor = anchor,
        portraitLayer = portraitLayer,
        portraitMask = portraitMask,
        container = container,
        canToggleSlots = container.SetAuraSlotEnabled ~= nil,
        tiers = {},
        slotOn = {},
    }

    local base = container:GetFrameLevel()
    for index, tier in ipairs(TIERS) do
        if not tier.interrupt and not (tier.needsSpellIDs and not tier.helpful and ALWAYS_ASSISTABLE[unit]) then
            container:AddAuraSlot(tier.key, tier.filter, {
                sortMethod = SORT_METHOD,
                sortDirection = SORT_DIRECTION,
                candidateFilters = tier.candidateFilters,
                initializeFrame = function(button) InitIcon(host, button, base + index) end,
            })
            host.tiers[index] = tier
            host.slotOn[index] = true
        end
    end

    if INTERRUPT_UNITS[unit] then
        CreateInterruptSlot(host)
    end

    hosts[unit] = host
    unitFrame.bbfBigDebuff = anchor
    return host
end

local function UpdateHostContainers(host)
    local debuffIDsUsable = BBF.CanFilterBySpellID(host.unit, false)
    local buffIDsUsable = BBF.CanFilterBySpellID(host.unit, true)
    local tokensOk = BBF.AuraTokensReliable(host.unit)
    local container = host.container
    local changed, anyOn = false, false
    local enabled = hostsEnabled and (not host.isParty or PartyFrame:ShouldShow())

    for index, tier in pairs(host.tiers) do
        local on
        if tier.needsSpellIDs then
            if tier.helpful then
                on = buffIDsUsable
            else
                on = debuffIDsUsable
            end
            on = on and not tier.empty
        else
            on = tokensOk
        end
        on = enabled and on and true or false
        if on then anyOn = true end
        if host.slotOn[index] ~= on then
            host.slotOn[index] = on
            changed = true
            if host.canToggleSlots then
                container:SetAuraSlotEnabled(tier.key, on)
            else
                container:SetAuraSlotCandidateFilters(tier.key, on and tier.candidateFilters or OFF_FILTERS)
            end
        end
    end

    if host.shown ~= anyOn then
        host.shown = anyOn
        changed = true
        container:SetEnabled(anyOn)
        container:SetShown(anyOn)
    end

    return changed
end

local function SetHostsEnabled(enabled)
    hostsEnabled = enabled

    for _, host in pairs(hosts) do
        UpdateHostContainers(host)
    end

    BBF.UpdateBigDebuffsInterrupts()
end

local function RefreshHost(unit, force)
    local host = hosts[unit]
    if not host then return end

    local changed = UpdateHostContainers(host)
    if (force or changed) and host.shown then
        host.container:UpdateAllAuras()
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
    unitWatcher:RegisterUnitEvent("UNIT_PHASE", "target", "focus")
    unitWatcher:RegisterUnitEvent("UNIT_FLAGS", "target", "focus")
    unitWatcher:RegisterUnitEvent("UNIT_CONNECTION", "target", "focus")
    unitWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    unitWatcher:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    unitWatcher:RegisterEvent("ZONE_CHANGED_INDOORS")
    unitWatcher:SetScript("OnEvent", function(_, event, unit)
        if event == "PLAYER_TARGET_CHANGED" then
            RefreshHost("target", true)
            RestoreKick("target")
        elseif event == "PLAYER_FOCUS_CHANGED" then
            RefreshHost("focus", true)
            RestoreKick("focus")
        elseif event == "UNIT_PET" then
            RefreshHost("pet", true)
        elseif unit then
            RefreshHost(unit, event == "UNIT_FACTION")
        else
            for hostUnit in pairs(hosts) do
                RefreshHost(hostUnit, true)
            end
        end
    end)
end

local function BuildPartyHosts()
    if partyBuilt or InCombatLockdown() or BBF.HasNoPortrait("party") then return end
    if EditModeManagerFrame:UseRaidStylePartyFrames() or not PartyFrame.MemberFrame1 then return end
    partyBuilt = true

    for i = 1, MAX_PARTY_MEMBERS do
        local frame = PartyFrame["MemberFrame" .. i]
        local host = CreateHost(frame.unitToken, frame, frame.Portrait, frame.PortraitMask)
        host.isParty = true
        partyHosts[frame] = host
    end

    for i = 1, MAX_PARTY_MEMBERS, 2 do
        local watcher = CreateFrame("Frame")
        for _, event in ipairs({ "UNIT_FACTION", "UNIT_PHASE", "UNIT_FLAGS", "UNIT_CONNECTION" }) do
            watcher:RegisterUnitEvent(event, "party" .. i, "party" .. (i + 1))
        end
        watcher:SetScript("OnEvent", function(_, event, unit)
            RefreshHost(unit, event == "UNIT_FACTION")
        end)
    end
end

local function SyncPartyHosts()
    if not hostsEnabled then return end
    BuildPartyHosts()

    for _, host in pairs(partyHosts) do
        hosts[host.unit] = nil
    end
    for frame, host in pairs(partyHosts) do
        local unit = frame.unitToken
        if host.unit ~= unit then
            host.unit = unit
            host.container:SetUnit(unit)
        end
        hosts[unit] = host
    end
    for _, host in pairs(partyHosts) do
        RefreshHost(host.unit, true)
    end
end

local function BuildHosts()
    if mainBuilt then
        BuildPartyHosts()
        return true
    end
    if InCombatLockdown() then return false end
    mainBuilt = true

    BuildTierFilters()

    if not BBF.HasNoPortrait("player") then
        CreateHost("player", PlayerFrame,
            PlayerFrame.PlayerFrameContainer.PlayerPortrait,
            PlayerFrame.PlayerFrameContainer.PlayerPortraitMask)
    end

    if not BBF.HasNoPortrait("target") then
        CreateHost("target", TargetFrame,
            TargetFrame.TargetFrameContainer.Portrait,
            TargetFrame.TargetFrameContainer.PortraitMask)
    end

    if not BBF.HasNoPortrait("focus") then
        CreateHost("focus", FocusFrame,
            FocusFrame.TargetFrameContainer.Portrait,
            FocusFrame.TargetFrameContainer.PortraitMask)
    end

    if not BBF.HasNoPortrait("pet") then
        CreateHost("pet", PetFrame,
            PetPortrait,
            PetFrame.PortraitMask)
    end

    CreateUnitWatcher()
    BuildPartyHosts()
    hooksecurefunc(PartyFrame, "UpdatePartyFrames", SyncPartyHosts)

    return true
end

function BBF.CreateBigDebuffs()
    if not BetterBlizzFramesDB.enableBigDebuffs then
        SetHostsEnabled(false)
        return
    end

    if C_AddOns.IsAddOnLoaded("MiniAuras") or C_AddOns.IsAddOnLoaded("MvqUI") then return end
    if BBF.HasNoPortrait("player") and BBF.HasNoPortrait("target") and BBF.HasNoPortrait("focus") and BBF.HasNoPortrait("pet") and BBF.HasNoPortrait("party") then return end

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

function BBF.UpdateBigDebuffsSpellLists()
    if not next(hosts) then return end
    BuildTierFilters()
    for unit, host in pairs(hosts) do
        for index, tier in pairs(host.tiers) do
            if tier.customKey and (host.canToggleSlots or host.slotOn[index]) then
                host.container:SetAuraSlotCandidateFilters(tier.key, tier.candidateFilters)
            end
        end
        RefreshHost(unit, true)
    end
end

local function RestartPreview()
    local now = GetTime()
    for _, host in pairs(hosts) do
        if host.preview then
            host.preview.cooldown:SetCooldown(now, PREVIEW_DURATION)
        end
    end
end

local function CreatePreview(host)
    local preview = CreateFrame("Frame", nil, host.anchor)
    preview:SetAllPoints(host.anchor)
    preview:SetFrameStrata(host.container:GetFrameStrata())
    preview:SetFrameLevel(host.container:GetFrameLevel() + #TIERS + 1)

    local icon = preview:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints(preview)
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    icon:SetTexture(PREVIEW_ICON)
    if host.portraitMask then
        icon:AddMaskTexture(host.portraitMask)
    end

    preview.cooldown = CreateCooldown(preview)
    preview:Hide()
    host.preview = preview
    return preview
end

function BBF.ToggleBigDebuffsPreview(show)
    if previewTicker then
        previewTicker:Cancel()
        previewTicker = nil
    end
    if show and (not BetterBlizzFramesDB.enableBigDebuffs or not BuildHosts()) then
        show = false
    end
    for _, host in pairs(hosts) do
        local preview = host.preview or (show and CreatePreview(host))
        if preview then
            preview:SetShown(show)
        end
    end
    if show then
        RestartPreview()
        previewTicker = C_Timer.NewTicker(PREVIEW_DURATION, RestartPreview)
    end
    return show
end

function BBF.IsBigDebuffsPreviewShown()
    return previewTicker ~= nil
end
