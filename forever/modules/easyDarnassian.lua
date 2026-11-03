local L = BBF.L
local DARNASSIAN = 2
local registered

local function KnowsDarnassian()
    for i = 1, GetNumLanguages() do
        local _, id = GetLanguageByIndex(i)
        if id == DARNASSIAN then
            return true
        end
    end
end

local function SendBattleNetWhisper(msg, target)
    local bnetIDAccount = BNet_GetBNetIDAccount(target)
    if bnetIDAccount then
        ChatFrameUtil.SetLastToldTarget(target, "BN_WHISPER")
        C_BattleNet.SendWhisper(bnetIDAccount, msg)
    else
        ChatFrameUtil.DisplaySystemMessageInPrimary(format(BN_UNABLE_TO_RESOLVE_NAME, target))
    end
end

local function Speak(msg, editBox)
    if msg == "" or not BetterBlizzFramesDB.easyDarnassian then return end

    if not KnowsDarnassian() then
        BBF.Print(L["Print_Easy_Darnassian_Unknown"])
        return
    end

    local chatType = editBox and editBox:GetChatType() or "SAY"
    msg = ChatFrameUtil.SubstituteChatMessageBeforeSend(msg)

    if chatType == "BN_WHISPER" then
        SendBattleNetWhisper(msg, editBox:GetTellTarget())
    elseif chatType == "WHISPER" then
        local target = editBox:GetTellTarget()
        ChatFrameUtil.SetLastToldTarget(target, chatType)
        C_ChatInfo.SendChatMessage(msg, chatType, DARNASSIAN, target)
    elseif chatType == "CHANNEL" then
        C_ChatInfo.SendChatMessage(msg, chatType, DARNASSIAN, editBox:GetChannelTarget())
    else
        C_ChatInfo.SendChatMessage(msg, chatType, DARNASSIAN)
    end
end

function BBF.EasyDarnassian()
    if registered or not BetterBlizzFramesDB.easyDarnassian then return end
    registered = true
    SLASH_BBFEASYDARNASSIAN1 = "/d"
    SlashCmdList.BBFEASYDARNASSIAN = Speak
end
