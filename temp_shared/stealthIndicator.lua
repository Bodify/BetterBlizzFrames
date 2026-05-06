local function CreateStealthIndicator()
    PlayerFrame.bbfStealthIndicatorFrame.Texture = PlayerFrame.bbfStealthIndicatorFrame:CreateTexture(nil, "BACKGROUND")
    if BBF.isRetail then
        PlayerFrame.bbfStealthIndicatorFrame.Texture:SetAtlas("ui-hud-unitframe-player-portraiton-vehicle-status")
        PlayerFrame.bbfStealthIndicatorFrame.Texture:SetSize(BetterBlizzFramesDB.symmetricPlayerFrame and 200 or 201, 83.5)
        PlayerFrame.bbfStealthIndicatorFrame.Texture:SetVertexColor(0.212, 0.486, 1)
        if BetterBlizzFramesDB.symmetricPlayerFrame then
            PlayerFrame.bbfStealthIndicatorFrame.Texture:SetPoint("CENTER", PlayerFrame, "CENTER", -3, 1)
        else
            PlayerFrame.bbfStealthIndicatorFrame.Texture:SetPoint("CENTER", PlayerFrame, "CENTER", -4, 0)
        end
    elseif BBF.isTBC then
        PlayerFrame.bbfStealthIndicatorFrame.Texture:SetTexture(137016)
        PlayerFrame.bbfStealthIndicatorFrame.Texture:SetVertexColor(0.212, 0.486, 1)
        PlayerFrame.bbfStealthIndicatorFrame.Texture:SetPoint("CENTER", PlayerFrameFlash, "CENTER", -7, -17)
        PlayerFrame.bbfStealthIndicatorFrame.Texture:SetSize(257, 128)
        PlayerFrame.bbfStealthIndicatorFrame.Texture:SetTexCoord(1, 0, 0, 1)
    else
        PlayerFrame.bbfStealthIndicatorFrame.Texture:SetTexture(137016)
        PlayerFrame.bbfStealthIndicatorFrame.Texture:SetVertexColor(0.212, 0.486, 1)
        PlayerFrame.bbfStealthIndicatorFrame.Texture:SetAllPoints(PlayerFrameFlash)
        PlayerFrame.bbfStealthIndicatorFrame.Texture:SetTexCoord(PlayerFrameFlash:GetTexCoord())
    end
end

local function UpdateStealthIndicator()
    if IsStealthed() then
        PlayerFrame.bbfStealthIndicatorFrame.Texture:Show()
    else
        PlayerFrame.bbfStealthIndicatorFrame.Texture:Hide()
    end
end

function BBF.StealthIndicator()
    if BetterBlizzFramesDB.stealthIndicatorPlayer then
        if not PlayerFrame.bbfStealthIndicatorFrame then
            PlayerFrame.bbfStealthIndicatorFrame = CreateFrame("Frame", nil, PlayerFrame)
            PlayerFrame.bbfStealthIndicatorFrame:SetScript("OnEvent", UpdateStealthIndicator)
            CreateStealthIndicator()
        end
        PlayerFrame.bbfStealthIndicatorFrame:RegisterEvent("UPDATE_STEALTH")
        UpdateStealthIndicator()
    else
        if PlayerFrame.bbfStealthIndicatorFrame then
            PlayerFrame.bbfStealthIndicatorFrame:UnregisterEvent("UPDATE_STEALTH")
            PlayerFrame.bbfStealthIndicatorFrame.Texture:Hide()
        end
    end
end