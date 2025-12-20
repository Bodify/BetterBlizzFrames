-- :)

BetterBlizzFramesDB = BetterBlizzFramesDB or {}
BBF = BBF or {}
BBA = BBA or {}

---------------------------------------
-- Standard BBF Print Function
---------------------------------------

-- BBF prefix for print messages (icon + colored addon name)
BBF.PRINT_PREFIX = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: "

-- Standard print function that adds BBF prefix automatically
function BBF.Print(msg)
	if msg then
		print(BBF.PRINT_PREFIX .. msg)
	end
end

-- Print without the colon (for special cases like "BBF first run")
function BBF.PrintNoColon(msg)
	if msg then
		print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames " .. msg)
	end
end

-- Initialize locale table (will be populated by locale files)
BBF.L = BBF.L or {}

local gameVersion = select(1, GetBuildInfo())
BBF.isMidnight = gameVersion:match("^12")
BBF.isRetail = gameVersion:match("^11")
BBF.isMoP = gameVersion:match("^5%.")
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