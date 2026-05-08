local filterGladiusSpam
local filterTalentSpam
local filterSystemMessages
local filterEmoteSpam
local filterNpcArenaSpam
local filterMiscInfo

local filterGladiusSpamHooked = false
local filterTalentSpamHooked = false
local filterSystemMessagesHooked = false
local filterEmoteSpamHooked = false
local filterNpcArenaSpamHooked = false
local filterMiscInfoHooked = false

local gladiusSpam = {
    ["LOW HEALTH:"] = true, ["WENIG LEBEN:"] = true, ["NIEDRIGE GESUNDHEIT:"] = true, ["VIDA BAJA:"] = true,
    ["Entidad desconocida -"] = true,
    ["BIJOU UTILISE"] = true,
    ["Enemy spec:"] = true, ["Enemy Spec:"] = true, ["Especialización de enemigo:"] = true,
    ["- Mage"] = true, ["Magier"] = true,
    ["- Monk"] = true, ["- Mönch"] = true,
    ["- Warrior"] = true, ["Krieger"] = true,
    ["- Warlock"] = true, ["Hexenmeister"] = true,
    ["- Priest"] = true,
    ["- Shaman"] = true, ["Schamane"] = true,
    ["- Demon Hunter"] = true,
    ["- Paladin"] = true,
    ["- Death Knight"] = true, ["- Todesritter"] = true,
    ["- Druid"] = true,
    ["- Rogue"] = true,
    ["- Hunter"] = true,
}

local talentSpam = {
    [ERR_ACTIVATE_SOULBIND_S] = true, -- Soulbind with ...
    [ERR_LEARN_PASSIVE_S] = true, -- You have learned a new passive effect: %s.
    [ERR_LEARN_ABILITY_S] = true, -- You have learned a new ability: %s.
    [ERR_LEARN_SPELL_S] = true, -- You have learned a new spell: %s.
}

local systemMessages = {
    ["Thirty seconds until the Arena"] = true,
    ["Fifteen seconds until the Arena"] = true,
    ["The Arena battle has begun!"] = true,
    [ERR_PARTY_CONVERTED_TO_RAID] = true, -- Party converted to Raid
    [ERR_RAID_DIFFICULTY_CHANGED_S] = true, -- Raid Difficulty set to
    [ERR_LEGACY_RAID_DIFFICULTY_CHANGED_S] = true, -- Legacy Raid Difficulty set to
    [ERR_INSTANCE_GROUP_ADDED_S] = true, -- has joined the instance group.
    [ERR_INSTANCE_GROUP_REMOVED_S] = true, -- [player] has left the instance group.
    [ERR_UNINVITE_YOU] = true, -- You have been removed from the group.
    [ERR_GROUP_DISBANDED] = true, -- Your group has been disbanded.
    ["You have joined the queue for Arena Skirmish"] = true,
    [ERR_SOLO_JOIN_TRAINING_GROUND] = true, -- You have joined the solo training ground
    [ERR_SOLO_JOIN_BATTLEGROUND_S] = true, -- You have joined the solo battleground
    [ERR_SOLO_JOIN_BATTLEGROUND_SPEC_S] = true, -- You have joined the solo battleground with a specific role
    [ERR_JOIN_SINGLE_SCENARIO_S] = true, -- You have joined a single scenario
    [ERR_LFG_ROLE_CHECK_INITIATED] = true, -- A role check has been initiated.
    [COMBATLOG_HONORAWARD] = true, -- You have been awarded [amount] honor points.
    [COMBATLOG_ARENAPOINTSAWARD] = true, -- You have been awarded [amount] arena points.
    [ERR_INSTANCE_GROUP_JOINED_WITH_PARTY] = true, -- You are in both a party and an instance group
    [ERR_CROSS_FACTION_GROUP_JOINED] = true, -- This is now a cross-faction group.
    [ERR_NOT_IN_GROUP] = true, -- You aren't in a party
    [ERR_LFG_JOINED_QUEUE] = true, -- You are now queued in the Dungeon Finder.
    [ERR_DUNGEON_DIFFICULTY_CHANGED_S] = true, -- Dungeon Difficulty set to
    [ERR_LOOT_SPEC_CHANGED_S] = true, -- Loot Specialization set to
    ["SUSPENDED"] = true,
    ["YOU_CHANGED"] = true,
    [ERR_BG_PLAYER_JOINED_SS] = true, -- [player] has joined the battle
}

local miscInfo = {
    [DURABILITYDAMAGE_DEATH] = true, -- Your equipped items suffer a durability loss
}

local emoteSpam = {
    [CHAT_YELL_UNKNOWN_FEMALE] = true, -- yells at her team members.
    [CHAT_YELL_UNKNOWN] = true, -- yells at his team members.
    [CHAT_EMOTE_UNKNOWN] = true, -- makes some strange gestures.
    [CHAT_SAY_UNKNOWN] = true, -- says something unintelligible.
}

-- Function to check if a message is spam based on user settings
local function isSpam(message, spamTable)
    for spamString, _ in pairs(spamTable) do
        if string.find(message, spamString) then
            return true
        end
    end
    return false
end

--CHAT_MSG_COMBAT_MISC_INFO
local function chatFilter(frame, event, message, sender, ...)
    -- Check and filter user-defined spam (applies to all channels)
--[[
    if BetterBlizzFramesDB.filterUserSpam and isSpam(message, BetterBlizzFramesDB.userDefinedSpam) then
        return true
    end
]]
    -- Channel-specific filtering
    if (event == "CHAT_MSG_INSTANCE_CHAT" or event == "CHAT_MSG_INSTANCE_CHAT_LEADER" or
        event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER") and
        filterGladiusSpam and isSpam(message, gladiusSpam) then
        return true
    elseif (event == "CHAT_MSG_SYSTEM" or event == "CHAT_MSG_COMBAT_HONOR_GAIN" or
            event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" or event == "CHAT_MSG_CHANNEL_NOTICE" or
            event == "CHAT_MSG_CURRENCY") then
        if filterSystemMessages and isSpam(message, systemMessages) then
            return true
        end
        if filterTalentSpam and isSpam(message, talentSpam) then
            return true
        end
    elseif (event == "CHAT_MSG_EMOTE" or event == "CHAT_MSG_TEXT_EMOTE") and
           filterEmoteSpam and isSpam(message, emoteSpam) then
        return true
    elseif event == "CHAT_MSG_MONSTER_SAY" and filterNpcArenaSpam and IsActiveBattlefieldArena() then
        return true
    elseif event == "CHAT_MSG_COMBAT_MISC_INFO" and isSpam(message, miscInfo) then
        return true
    end

    return false
end

function BBF.ChatFilterCaller()
    -- Update settings
    filterGladiusSpam = BetterBlizzFramesDB.filterGladiusSpam
    filterTalentSpam = BetterBlizzFramesDB.filterTalentSpam
    filterSystemMessages = BetterBlizzFramesDB.filterSystemMessages
    filterEmoteSpam = BetterBlizzFramesDB.filterEmoteSpam
    filterNpcArenaSpam = BetterBlizzFramesDB.filterNpcArenaSpam
    filterMiscInfo = BetterBlizzFramesDB.filterMiscInfo

    -- Gladius Spam
    if filterGladiusSpam and not filterGladiusSpamHooked then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", chatFilter)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", chatFilter)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", chatFilter)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", chatFilter)
        filterGladiusSpamHooked = true
    end

    -- Talent Spam
    if filterTalentSpam and not filterTalentSpamHooked then
        if not filterSystemMessagesHooked then
            ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", chatFilter)
        end
        filterTalentSpamHooked = true
    end

    -- System Messages
    if filterSystemMessages and not filterSystemMessagesHooked then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_HONOR_GAIN", chatFilter)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_NEUTRAL", chatFilter)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_NOTICE", chatFilter)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CURRENCY", chatFilter)
        if not filterTalentSpamHooked then
            ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", chatFilter)
        end
        if ONLINE_SAFETY_NOTICE then
            hooksecurefunc(ChatFrameUtil, "AddSystemMessage", function(message)
                if message ~= ONLINE_SAFETY_NOTICE then return end
                for i = 1, NUM_CHAT_WINDOWS do
                    local cf = _G["ChatFrame" .. i]
                    if cf and cf.RemoveMessagesByPredicate then
                        cf:RemoveMessagesByPredicate(function(line) return line == ONLINE_SAFETY_NOTICE end)
                    end
                end
            end)
        end
        filterSystemMessagesHooked = true
    end

    if filterMiscInfo and not filterMiscInfoHooked then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_MISC_INFO", chatFilter)
        filterMiscInfoHooked = true
    end

    -- Emote Spam
    if filterEmoteSpam and not filterEmoteSpamHooked then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", chatFilter)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", chatFilter)
        filterEmoteSpamHooked = true
    end

    -- NPC Arena Spam
    if filterNpcArenaSpam and not filterNpcArenaSpamHooked then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", chatFilter)
        filterNpcArenaSpamHooked = true
    end
end