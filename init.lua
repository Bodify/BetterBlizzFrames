-- :)

BetterBlizzFramesDB = BetterBlizzFramesDB or {}
BBF = BBF or {}
BBA = BBA or {}

---------------------------------------
-- Standard BBF Print Function
---------------------------------------

-- BBF prefix for print messages (icon + colored addon name)
BBF.PRINT_PREFIX = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: "
BBF.PRINT_PREFIX_NO_COLON = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames "

-- Standard print function that adds BBF prefix automatically
-- Set noColon to true to omit the colon after the addon name
function BBF.Print(msg, noColon)
	if msg then
		local prefix = noColon and BBF.PRINT_PREFIX_NO_COLON or BBF.PRINT_PREFIX
		print(prefix .. msg)
	end
end

-- Initialize locale table (will be populated by locale files)
BBF.L = BBF.L or {}

local gameVersion = select(1, GetBuildInfo())
BBF.isMidnight = gameVersion:match("^12")
BBF.isRetail = gameVersion:match("^11")
BBF.isMoP = gameVersion:match("^5%.")
BBF.isTBC = gameVersion:match("^2%.")
BBF.isEra = gameVersion:match("^1%.")

local function CreateOverlayFrame(frame)
    frame.bbfOverlayFrame = CreateFrame("Frame", nil, frame)
    frame.bbfOverlayFrame:SetFrameStrata("DIALOG")
    frame.bbfOverlayFrame:SetSize(frame:GetSize())
    frame.bbfOverlayFrame:SetAllPoints(frame)

    hooksecurefunc(frame, "SetFrameStrata", function()
        frame.bbfOverlayFrame:SetFrameStrata("DIALOG")
    end)
end

CreateOverlayFrame(PlayerFrame)
CreateOverlayFrame(TargetFrame)
if FocusFrame then
    CreateOverlayFrame(FocusFrame)
end