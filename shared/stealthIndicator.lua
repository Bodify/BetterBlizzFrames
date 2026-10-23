local function SymmetricPlayer()
    if BBF.SymmetricPlayerOn then return BBF.SymmetricPlayerOn() end
    return BetterBlizzFramesDB.symmetricPlayerFrame
end

local function GetStealthIndicatorHeight()
    local db = BetterBlizzFramesDB
    if db.hideUnitFramePlayerMana and db.hideUnitFramePlayerSecondResource then
        return 36.5  -- health only
    elseif db.hideUnitFramePlayerSecondResource then
        return 48  -- health + mana
    elseif db.hideUnitFramePlayerMana then
        local altBarShown = PlayerFrame and
            PlayerFrame.PlayerFrameContainer and
            PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture and
            PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture:IsShown()
        return altBarShown and 48 or 36.5  -- health + alt, or health only
    else
        local altBarShown = PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture:IsShown()
        return altBarShown and 59 or 48  -- health + mana + alt, or health + mana
    end
end

local function CreateStealthIndicator()
    PlayerFrame.bbfStealthIndicatorFrame.Texture = PlayerFrame.bbfStealthIndicatorFrame:CreateTexture(nil, "BACKGROUND")
    if BBF.isRetail then
        if BBF.ClassicStealthGlowOn and BBF.ClassicStealthGlowOn() then
            PlayerFrame.bbfStealthIndicatorFrame.Texture.bbfClassicGlow = true
            PlayerFrame.bbfStealthIndicatorFrame.Texture:SetVertexColor(0.212, 0.486, 1)
            BBF.SetClassicStealthGlow(PlayerFrame.bbfStealthIndicatorFrame.Texture)
        elseif BetterBlizzFramesDB.classicFrames then
            PlayerFrame.bbfStealthIndicatorFrame.Texture:SetVertexColor(0.212, 0.486, 1)
            PlayerFrame.bbfStealthIndicatorFrame.Texture:SetSize(240.5, 93)
            PlayerFrame.bbfStealthIndicatorFrame.Texture:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", -4.5, -8)
            if BBF.SetClassicFlash then
                BBF.SetClassicFlash(PlayerFrame.bbfStealthIndicatorFrame.Texture, false, true)
            else
                PlayerFrame.bbfStealthIndicatorFrame.Texture:SetTexture(137016)
                PlayerFrame.bbfStealthIndicatorFrame.Texture:SetTexCoord(0.9453125, 0, 0, 0.181640625)
            end
        elseif BBF.HasNoPortrait("player") then
            PlayerFrame.bbfStealthIndicatorFrame.Texture:SetAtlas("loottoast-glow")
            PlayerFrame.bbfStealthIndicatorFrame.Texture:SetDesaturated(true)
            PlayerFrame.bbfStealthIndicatorFrame.Texture:SetVertexColor(0.212, 0.486, 1)
            PlayerFrame.bbfStealthIndicatorFrame.Texture:SetPoint("TOP", BBF.HealthBar and BBF.HealthBar(PlayerFrame) or PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar, "CENTER", 0, 17.5)
            PlayerFrame.bbfStealthIndicatorFrame.Texture:SetSize(143, GetStealthIndicatorHeight())
        else
            PlayerFrame.bbfStealthIndicatorFrame.Texture:SetAtlas("ui-hud-unitframe-player-portraiton-vehicle-status")
            PlayerFrame.bbfStealthIndicatorFrame.Texture:SetSize(SymmetricPlayer() and 200 or 201, 83.5)
            PlayerFrame.bbfStealthIndicatorFrame.Texture:SetVertexColor(0.212, 0.486, 1)
            if SymmetricPlayer() then
                PlayerFrame.bbfStealthIndicatorFrame.Texture:SetPoint("CENTER", PlayerFrame, "CENTER", -3, 1)
            else
                PlayerFrame.bbfStealthIndicatorFrame.Texture:SetPoint("CENTER", PlayerFrame, "CENTER", -4, 0)
            end
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
    if (BBF.isRetail or BBF.isForever) and not BetterBlizzFramesDB.classicFrames and BBF.HasNoPortrait("player") then
        PlayerFrame.bbfStealthIndicatorFrame.Texture:SetHeight(GetStealthIndicatorHeight())
    end
    if IsStealthed() then
        if PlayerFrame.bbfStealthIndicatorFrame.Texture.bbfClassicGlow then
            BBF.SetClassicStealthGlow(PlayerFrame.bbfStealthIndicatorFrame.Texture)
        end
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
        PlayerFrame.bbfStealthIndicatorFrame:RegisterEvent("UNIT_POWER_BAR_SHOW")
        PlayerFrame.bbfStealthIndicatorFrame:RegisterEvent("UNIT_POWER_BAR_HIDE")
        UpdateStealthIndicator()
    else
        if PlayerFrame.bbfStealthIndicatorFrame then
            PlayerFrame.bbfStealthIndicatorFrame:UnregisterEvent("UPDATE_STEALTH")
            PlayerFrame.bbfStealthIndicatorFrame:UnregisterEvent("UNIT_POWER_BAR_SHOW")
            PlayerFrame.bbfStealthIndicatorFrame:UnregisterEvent("UNIT_POWER_BAR_HIDE")
            PlayerFrame.bbfStealthIndicatorFrame.Texture:Hide()
        end
    end
end