-- Setting up the database
BetterBlizzFramesDB = BetterBlizzFramesDB or {}
BBF = BBF or {}
--BetterBlizzFramesDB.userDefinedSpam = BetterBlizzFramesDB.userDefinedSpam or {}

local gladiusSpam = {
    -- Gladius spam removed
    "LOW HEALTH:", "WENIG LEBEN:", "NIEDRIGE GESUNDHEIT:", "VIDA BAJA:",
    "Entidad desconocida -",
    "Enemy spec:", "Enemy Spec:", "Especialización de enemigo:",
    "- Mage", "Magier",
    "- Monk", "- Mönch",
    "- Warrior", "Krieger",
    "- Warlock", "Hexenmeister",
    "- Priest",
    "- Shaman", "Schamane",
    "- Demon Hunter",
    "- Paladin",
    "- Death Knight", "- Todesritter",
    "- Druid",
    "- Rogue",
    "- Hunter",
}

local talentSpam = {
    -- Talent rechange spam
    "You have learned a new",
    "You have unlearned",
    "Soulbound with ",
}

local systemMessages = {
    -- Some system messages removed
    "Thirty seconds until the Arena",
    "Fifteen seconds until the Arena",
    "The Arena battle has begun!",
    "Party converted to Raid",
    "Raid Difficulty set to Normal",
    "Legacy Raid Difficulty set to 10 Player.",
    "has joined the battle.",
    "has joined the instance group.",
    "has left the instance group.",
    "You have been removed from the group.",
    "Your group has been disbanded.",
    "You have joined the queue for Arena Skirmish",
    "A role check has been initiated.",
    "You have been awarded",
    "You are in both a party and an instance group.",
    "This is now a cross-faction",

    -- Left Channel and Changed Channel chat notices removed
    "SUSPENDED",
    "YOU_CHANGED",
}

local emoteSpam = {
    -- Annoying emotes from teams removed
    "yells at her team members.",
    "yells at his team members.",
    "makes some strange gestures.",
}

local function chatFilter(frame, event, message, sender, ...)
    -- Check and filter user-defined spam (applies to all channels)
--[[
    if BetterBlizzFramesDB.filterUserSpam then
        for _, v in ipairs(BetterBlizzFramesDB.userDefinedSpam) do
            if message:find(v) then
                return true
            end
        end
    end
]]
    -- Channel-specific filtering
    if event == "CHAT_MSG_INSTANCE_CHAT" or event == "CHAT_MSG_INSTANCE_CHAT_LEADER" or event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
        if BetterBlizzFramesDB.filterGladiusSpam then
            for _, v in ipairs(gladiusSpam) do
                if message:find(v) then
                    return true
                end
            end
        end
    elseif event == "CHAT_MSG_SYSTEM" or event == "CHAT_MSG_COMBAT_HONOR_GAIN" or event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" or event == "CHAT_MSG_CHANNEL_NOTICE" or event == "CHAT_MSG_CURRENCY" then
        if BetterBlizzFramesDB.filterSystemMessages then
            for _, v in ipairs(systemMessages) do
                if message:find(v) then
                    return true
                end
            end
        end
        if BetterBlizzFramesDB.filterTalentSpam then
            for _, v in ipairs(talentSpam) do
                if message:find(v) then
                    return true
                end
            end
        end
    elseif event == "CHAT_MSG_EMOTE" or event == "CHAT_MSG_TEXT_EMOTE" then
        if BetterBlizzFramesDB.filterEmoteSpam then
            for _, v in ipairs(emoteSpam) do
                if message:find(v) then
                    return true
                end
            end
        end
    elseif event == "CHAT_MSG_MONSTER_SAY" then
        if BetterBlizzFramesDB.filterNpcArenaSpam and IsActiveBattlefieldArena() then
            return true
        end
    end
    return false
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", chatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", chatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", chatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", chatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", chatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_NOTICE", chatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", chatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_HONOR_GAIN", chatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CURRENCY", chatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", chatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", chatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_NEUTRAL", chatFilter)