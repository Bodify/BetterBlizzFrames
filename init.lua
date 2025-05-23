-- :)

BetterBlizzFramesDB = BetterBlizzFramesDB or {}
BBF = BBF or {}
BBA = BBA or {}

local function CreateOverlayFrame(frame)
    frame.bbfOverlayFrame = CreateFrame("Frame", nil, frame)
    frame.bbfOverlayFrame:SetFrameStrata("DIALOG")
    frame.bbfOverlayFrame:SetSize(frame:GetSize())
    frame.bbfOverlayFrame:SetAllPoints(frame)
end

CreateOverlayFrame(TargetFrame)
CreateOverlayFrame(FocusFrame)
CreateOverlayFrame(PlayerFrame)