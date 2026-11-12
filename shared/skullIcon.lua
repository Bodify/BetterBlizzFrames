local NEW_ATLAS = "Islands-AzeriteBoss"
local DEFAULT_ATLAS = "UI-HUD-UnitFrame-Target-HighLevelTarget_Icon"

local function NewSkullSize(frame, skull)
    if frame.ClassicFrame and skull:GetParent() == frame.ClassicFrame then return 21, 34 end
    if frame.noPortraitMode then return 23, 25 end
    if BBF.isForever and not (BBF.RetailTexturesOn and BBF.RetailTexturesOn(frame.unit)) then return 29, 33, 0.5 end
    return 23, 25
end

function BBF.UpdateSkullIcon(frame, defaultWidth, defaultHeight)
    local content = frame and frame.TargetFrameContent
    local skull = content and content.TargetFrameContentContextual and content.TargetFrameContentContextual.HighLevelTexture
    local levelText = content and content.TargetFrameContentMain and content.TargetFrameContentMain.LevelText
    if not skull or not levelText then return end
    if defaultWidth then
        skull.bbfDefaultWidth, skull.bbfDefaultHeight = defaultWidth, defaultHeight
    end
    local newSkull = BetterBlizzFramesDB.newSkullLevelIcon
    local width, height, yOffset
    if newSkull then
        width, height, yOffset = NewSkullSize(frame, skull)
    end
    skull:ClearAllPoints()
    skull:SetPoint("CENTER", levelText, "CENTER", 0, yOffset or 0)
    if newSkull then
        skull:SetAtlas(NEW_ATLAS)
        skull:SetSize(width, height)
        skull.bbfNewSkull = true
    elseif skull.bbfNewSkull then
        skull.bbfNewSkull = nil
        skull:SetAtlas(DEFAULT_ATLAS, not skull.bbfDefaultWidth)
        if skull.bbfDefaultWidth then
            skull:SetSize(skull.bbfDefaultWidth, skull.bbfDefaultHeight)
        end
    end
end

function BBF.UpdateSkullIcons()
    BBF.UpdateSkullIcon(TargetFrame)
    BBF.UpdateSkullIcon(FocusFrame)
    for i = 1, MAX_BOSS_FRAMES or 5 do
        BBF.UpdateSkullIcon(_G["Boss" .. i .. "TargetFrame"])
    end
end
