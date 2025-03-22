local function AdjustFramePoint(frame, xOffset, yOffset)
    if not frame._storedPoint then
        local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
        frame._storedPoint = point
        frame._storedRelativeTo = relativeTo
        frame._storedRelativePoint = relativePoint
        frame._storedXOfs = xOfs
        frame._storedYOfs = yOfs
    end
    frame:SetPoint(frame._storedPoint, frame._storedRelativeTo, frame._storedRelativePoint, frame._storedXOfs + (xOffset or 0), frame._storedYOfs + (yOffset or 0))
end

local function SetXYPoint(frame, xOffset, yOffset)
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
    frame:SetPoint(point, relativeTo, relativePoint, xOffset or xOfs, yOffset or yOfs)
end

local function MakeClassicFrame(frame)
    if frame == TargetFrame or frame == FocusFrame then
        -- Frame
        local content = frame.TargetFrameContent
        local frameContainer = frame.TargetFrameContainer
        local contentMain = content.TargetFrameContentMain
        local contentContext = content.TargetFrameContentContextual

        -- Status
        local hpContainer = contentMain.HealthBarsContainer
        local manaBar = contentMain.ManaBar


        frame.bbfName:SetParent(frame.TargetFrameContainer)
        frame.bbfClassicBg = frame:CreateTexture(nil, "BACKGROUND")
        frame.bbfClassicBg:SetColorTexture(0,0,0,0.45)
        frame.bbfClassicBg:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", 3, 9)
        frame.bbfClassicBg:SetPoint("BOTTOMRIGHT", contentMain.ManaBar, "BOTTOMRIGHT", 0, 0)

        frameContainer:SetFrameStrata("MEDIUM")

        frameContainer.FrameTextureBBF = TargetFrame:CreateTexture(nil, "BACKGROUND")
        frameContainer.FrameTextureBBF:SetDrawLayer("BACKGROUND", 2)
        frameContainer.FrameTextureBBF:SetParent(frameContainer)

        local function GetFrameColor()
            local r,g,b = frameContainer.FrameTexture:GetVertexColor()
            frameContainer.FrameTextureBBF:SetVertexColor(r,g,b)
        end
        GetFrameColor()
        hooksecurefunc(frameContainer.FrameTexture, "SetVertexColor", GetFrameColor)

        hpContainer.LeftText:SetParent(frameContainer)
        hpContainer.LeftText:ClearAllPoints()
        hpContainer.LeftText:SetPoint("LEFT", frameContainer.FrameTextureBBF, "LEFT", 7, 2.5)
        hpContainer.RightText:SetParent(frameContainer)
        hpContainer.RightText:ClearAllPoints()
        hpContainer.RightText:SetPoint("RIGHT", frameContainer.FrameTextureBBF, "RIGHT", -110, 2.5)
        hpContainer.HealthBarText:SetParent(frameContainer)
        hpContainer.HealthBarText:ClearAllPoints()
        hpContainer.HealthBarText:SetPoint("CENTER", frameContainer.FrameTextureBBF, "LEFT", 66, 2.5)
        hpContainer.DeadText:SetParent(frameContainer)
        hpContainer.DeadText:ClearAllPoints()
        hpContainer.DeadText:SetPoint("CENTER", frameContainer.FrameTextureBBF, "LEFT", 66, 2.5)
        AdjustFramePoint(hpContainer.HealthBar.OverAbsorbGlow, -6)

        manaBar.LeftText:SetParent(frameContainer)
        manaBar.LeftText:ClearAllPoints()
        manaBar.LeftText:SetPoint("LEFT", frameContainer.FrameTextureBBF, "LEFT", 7, -8.5)
        manaBar.RightText:SetParent(frameContainer)
        manaBar.RightText:ClearAllPoints()
        manaBar.RightText:SetPoint("RIGHT", frameContainer.FrameTextureBBF, "RIGHT", -110, -8.5)
        manaBar.ManaBarText:SetParent(frameContainer)
        manaBar.ManaBarText:ClearAllPoints()
        manaBar.ManaBarText:SetPoint("CENTER", frameContainer.FrameTextureBBF, "LEFT", 66, -8.5)

        --AdjustFramePoint(manaBar, 0, 3)

        contentContext:SetFrameStrata("MEDIUM")
        contentContext.HighLevelTexture:ClearAllPoints()
        contentContext.HighLevelTexture:SetPoint("CENTER", frame, "BOTTOMRIGHT", -34, 25)
        contentContext.PetBattleIcon:ClearAllPoints()
        contentContext.PetBattleIcon:SetPoint("CENTER", frame, "BOTTOMRIGHT", -35, 25)
        contentContext.PrestigePortrait:ClearAllPoints()
        contentContext.PrestigePortrait:SetPoint("TOPRIGHT", 5, -17)
        contentContext.LeaderIcon:ClearAllPoints()
        contentContext.LeaderIcon:SetPoint("TOPRIGHT", -84, -13.5)
        contentContext.GuideIcon:ClearAllPoints()
        contentContext.GuideIcon:SetPoint("TOPRIGHT", -20, -14)

        contentContext.RaidTargetIcon:ClearAllPoints()
        contentContext.RaidTargetIcon:SetPoint("CENTER", frameContainer.Portrait, "TOP", 1.5, 1)

        AdjustFramePoint(frameContainer.Portrait, nil, -4)

        contentMain.LevelText:ClearAllPoints()
        contentMain.LevelText:SetPoint("CENTER", frame, "BOTTOMRIGHT", -34.5, 25.5)
        contentMain.LevelText:SetParent(frameContainer)
        contentMain.ReputationColor:SetSize(119, 18)
        contentMain.ReputationColor:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-LevelBackground")
        contentMain.ReputationColor:ClearAllPoints()
        contentMain.ReputationColor:SetPoint("TOPRIGHT", -86, -31)
        frameContainer.Flash:SetDrawLayer("BACKGROUND")
        frameContainer.Flash:SetParent(BetterBlizzFramesDB.hidePlayerRestGlow and BBF.hiddenFrame or TargetFrame) --was content
        frameContainer.PortraitMask:SetSize(61,61)
        frameContainer.PortraitMask:ClearAllPoints()
        frameContainer.PortraitMask:SetPoint("CENTER", frameContainer.Portrait, "CENTER", 0, 0)
        frameContainer.BossPortraitFrameTexture:SetAlpha(0)




        --AdjustFramePoint(contentContext.RaidTargetIcon, 1)



        --------- these might need updates / different method
        local totFrame = frame.totFrame
        local totHpBar = totFrame.HealthBar
        local totManaBar = totFrame.ManaBar
        totFrame:SetFrameStrata("HIGH")
        totHpBar:SetStatusBarColor(0, 1, 0)
        totHpBar:SetSize(47, 7)
        totHpBar:ClearAllPoints()
        totHpBar:SetPoint("TOPRIGHT", -29, -15)
        totHpBar:SetFrameLevel(1)
        totManaBar:SetSize(49, 7)
        totManaBar:ClearAllPoints()
        totManaBar:SetPoint("TOPRIGHT", -29, -23)
        totManaBar:SetFrameLevel(1)
        local function fixDebuffs()
			local frameName = totFrame:GetName()
			local suffix = "Debuff";
			local frameNameWithSuffix = frameName..suffix;
			for i= 1, 4 do
				local debuffName = frameNameWithSuffix..i;
				_G[debuffName]:ClearAllPoints()
				if (i == 1) then
					_G[debuffName]:SetPoint("TOPLEFT", totFrame, "TOPRIGHT", -23, -8)
				elseif (i==2) then
					_G[debuffName]:SetPoint("TOPLEFT", totFrame, "TOPRIGHT", -10, -8)
				elseif (i==3) then
					_G[debuffName]:SetPoint("TOPLEFT", totFrame, "TOPRIGHT", -23, -21)
				elseif (i==4) then
					_G[debuffName]:SetPoint("TOPLEFT", totFrame, "TOPRIGHT", -10, -21)
				end
			end
		end
        fixDebuffs()
        totFrame.bbfClassicBg = totFrame.HealthBar:CreateTexture(nil, "BACKGROUND")
        totFrame.bbfClassicBg:SetColorTexture(0,0,0,0.45)
        totFrame.bbfClassicBg:SetPoint("TOPLEFT", totFrame.HealthBar, "TOPLEFT", 1, -1)
        totFrame.bbfClassicBg:SetPoint("BOTTOMRIGHT", totFrame.manabar, "BOTTOMRIGHT", -1, 1)


        local hideToTDebuffs = (frame.unit == "target" and BetterBlizzFramesDB.hideTargetToTDebuffs) or frame.unit == "focus" and BetterBlizzFramesDB.hideFocusToTDebuffs
        if not hideToTDebuffs then
            frame.totFrame.lastUpdate = 0
            frame.totFrame:HookScript("OnUpdate", function(self, elapsed)
                self.lastUpdate = self.lastUpdate + elapsed
                if self.lastUpdate >= 0.2 then
                    self.lastUpdate = 0
                    RefreshDebuffs(self, self.unit, nil, nil, true)
                end
            end)
        end


        -------------------------

        -- frame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetHeight(12)
        -- AdjustFramePoint(frame.TargetFrameContent.TargetFrameContentMain.ManaBar, 0, 2)
        --TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar

        hooksecurefunc(frame, "CheckClassification", function(self)
            local classification = UnitClassification(self.unit)

            -- Frame
            local content = self.TargetFrameContent
            local frameContainer = frameContainer
            local contentMain = content.TargetFrameContentMain
            local contentContext = content.TargetFrameContentContextual

            -- Status
            local hpContainer = contentMain.HealthBarsContainer
            local manaBar = contentMain.ManaBar

            local totFrame = frame.totFrame

            -- FrameHealthBar:SetAlpha(0)
            -- FrameManaBar:SetAlpha(0)
            if false then -- bodify
                contentMain.ReputationColor:Show()
            end
            frame.bbfClassicBg:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", 3, 9)
            -- contextual.BossIcon:Hide()
            -- frameContainer.BossPortraitFrameTexture:Hide()

            -- CfTargetFrameBackground:SetSize(119, 25)
            -- CfTargetFrameBackground:SetPoint("BOTTOMLEFT", 7, 35)

            -- CfFocusFrameBackground:SetSize(119, 25)
            -- CfFocusFrameBackground:SetPoint("BOTTOMLEFT", 7, 35)

            -- self.haveElite = nil;
            -- CfTargetFrameManaBar.pauseUpdates = false;
            -- local a,b,c,d,e = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer:GetPoint()
            -- TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer:SetPoint("BOTTOMRIGHT", b, "LEFT", 149, -39)

            SetXYPoint(hpContainer.HealthBarMask, 1, -6)
            hpContainer.HealthBarMask:SetSize(125, 17)
            SetXYPoint(manaBar.ManaBarMask, -59)

            --manaBar.ManaBarMask:SetPoint()

            -- SetXYPoint(hpContainer.HealthBar.HealthBarTexture, nil, -8)
            -- if not BBF.hooketh then
            --     local a,b,c,d,e = hpContainer.HealthBar.HealthBarTexture:GetPoint()
            --     hooksecurefunc(hpContainer.HealthBar.HealthBarTexture, "SetPoint", function(self)
            --         if self.changing then return end
            --         self.changing = true
            --         hpContainer.HealthBar.HealthBarTexture:ClearAllPoints()
            --         C_Timer.After(0.5, function()
            --             hpContainer.HealthBar.HealthBarTexture:SetPoint(a,b,c,d,-6) -- this also changes the texture wtf
            --         end)
            --         hpContainer.HealthBar.HealthBarTexture:SetPoint(a,b,c,d,-6)
            --         self.changing = false
            --     end)
            --     BBF.hooketh = true
            -- end
            -- print("uhh")

            if ( classification == "rareelite" ) then
                frameContainer.FrameTexture:SetSize(232, 100)
                frameContainer.FrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite")
                frameContainer.FrameTexture:SetTexCoord(0.09375, 1, 0, 0.78125)
                frameContainer.FrameTexture:ClearAllPoints()
                frameContainer.FrameTexture:SetPoint("TOPLEFT", 20, -4)
                frameContainer.Flash:SetSize(242, 112)
                frameContainer.Flash:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash")
                frameContainer.Flash:SetTexCoord(0, 0.9453125, 0.181640625, 0.400390625)
                frameContainer.Flash:ClearAllPoints()
                frameContainer.Flash:SetPoint("TOPLEFT", -2, 5)
                --self.haveElite = true;
            elseif ( classification == "worldboss" or classification == "elite" ) then
                frameContainer.FrameTexture:SetSize(232, 100)
                frameContainer.FrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
                frameContainer.FrameTextureBBF:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
                frameContainer.FrameTexture:SetTexCoord(0.09375, 1, 0, 0.78125)
                frameContainer.FrameTexture:ClearAllPoints()
                frameContainer.FrameTexture:SetPoint("TOPLEFT", 20, -4)
                frameContainer.Flash:SetSize(242, 112)
                frameContainer.Flash:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash")
                frameContainer.Flash:SetTexCoord(0, 0.9453125, 0.181640625, 0.400390625)
                frameContainer.Flash:ClearAllPoints()
                frameContainer.Flash:SetPoint("TOPLEFT", -2, 5)
                --self.haveElite = true;
            elseif ( classification == "rare" ) then
                frameContainer.FrameTexture:SetSize(232, 100)
                frameContainer.FrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
                frameContainer.FrameTexture:SetTexCoord(0.09375, 1, 0, 0.78125)
                frameContainer.FrameTexture:ClearAllPoints()
                frameContainer.FrameTexture:SetPoint("TOPLEFT", 20, -4)
                frameContainer.Flash:SetSize(242, 93)
                frameContainer.Flash:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash")
                frameContainer.Flash:SetTexCoord(0, 0.9453125, 0, 0.181640625)
                frameContainer.Flash:ClearAllPoints()
                frameContainer.Flash:SetPoint("TOPLEFT", -4, -4)
                --self.haveElite = true;
            elseif ( classification == "minus" ) then
                -- CfTargetFrameBackground:SetSize(119, 12)
                -- CfTargetFrameBackground:SetPoint("BOTTOMLEFT", 7, 47)
                -- CfFocusFrameBackground:SetSize(119, 12)
                -- CfFocusFrameBackground:SetPoint("BOTTOMLEFT", 7, 47)
                frameContainer.FrameTexture:SetSize(232, 100)
                frameContainer.FrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Minus")
                frameContainer.FrameTexture:SetTexCoord(0.09375, 1, 0, 0.78125)
                frameContainer.FrameTexture:ClearAllPoints()
                frameContainer.FrameTexture:SetPoint("TOPLEFT", 20, -4)
                frameContainer.Flash:SetSize(256, 128)
                frameContainer.Flash:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Minus-Flash")
                frameContainer.Flash:SetTexCoord(0, 1, 0, 1)
                frameContainer.Flash:ClearAllPoints()
                frameContainer.Flash:SetPoint("TOPLEFT", -4, -4)

                frameContainer.FrameTextureBBF:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Minus")
                self.bbfClassicBg:SetPoint("TOPLEFT", self.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar, "TOPLEFT", 3, -10)

                contentMain.ReputationColor:Hide()
                -- CfTargetFrameManaBar.pauseUpdates = true;
            else
                frameContainer.FrameTexture:SetSize(232, 100)
                --frameContainer.FrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
                frameContainer.FrameTexture:SetTexCoord(0.09375, 1, 0, 0.78125)
                frameContainer.FrameTexture:ClearAllPoints()
                --frameContainer.FrameTexture:SetPoint("TOPLEFT", 55, -8)
                frameContainer.Flash:SetSize(242, 93)
                frameContainer.Flash:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash")
                frameContainer.Flash:SetTexCoord(0, 0.9453125, 0, 0.181640625)
                frameContainer.Flash:ClearAllPoints()
                frameContainer.Flash:SetPoint("TOPLEFT", -4, -8)

                -- frameContainer.Flash:SetParent(TargetFrame)
                -- frameContainer.Flash:SetDrawLayer("BACKGROUND", 0)

                frameContainer.FrameTexture:SetPoint("TOPLEFT", 22, 14)
                frameContainer.FrameTexture:SetAlpha(0)

                frameContainer.FrameTextureBBF:SetSize(232, 100)
                frameContainer.FrameTextureBBF:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
                --frameContainer.FrameTextureBBF:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\ui-targetingframe-nolevel")
                -- local hideLvl = BetterBlizzFramesDB.hideLevelText
                -- frameContainer.FrameTextureBBF:SetTexture(hideLvl and "Interface\\TargetingFrame\\UI-TargetingFrame-NoLevel" or "Interface\\TargetingFrame\\UI-TargetingFrame")
                frameContainer.FrameTextureBBF:SetTexCoord(0.09375, 1, 0, 0.78125)
                frameContainer.FrameTextureBBF:ClearAllPoints()
                frameContainer.FrameTextureBBF:SetPoint("TOPLEFT", 20, -8)
            end

            if (totFrame) then
                totFrame.FrameTexture:SetSize(93, 45)
                totFrame.FrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetofTargetFrame")
                totFrame.FrameTexture:SetTexCoord(0.015625, 0.7265625, 0, 0.703125)
                totFrame.FrameTexture:ClearAllPoints()
                totFrame.FrameTexture:SetPoint("TOPLEFT", 0, 0)

                totFrame.Portrait:SetSize(37, 37)
                totFrame.Portrait:ClearAllPoints()
                totFrame.Portrait:SetPoint("TOPLEFT", 4, -5)
                -- totFrame.HealthBar:SetStatusBarColor(0, 1, 0)
                -- totFrame.HealthBar:SetSize(46, 7)
                -- totFrame.HealthBar:ClearAllPoints()
                -- totFrame.HealthBar:SetPoint("TOPRIGHT", -29, -15)
                -- totFrame.HealthBar:SetFrameLevel(1)
                totFrame.HealthBar.DeadText:SetParent(totFrame)
                totFrame.HealthBar.DeadText:ClearAllPoints()
                totFrame.HealthBar.DeadText:SetPoint("LEFT", 48, 3)

                totFrame.HealthBar.UnconsciousText:SetParent(totFrame)
                totFrame.HealthBar.UnconsciousText:ClearAllPoints()
                totFrame.HealthBar.UnconsciousText:SetPoint("LEFT", 48, 3)

                -- totFrame.ManaBar:SetSize(46, 7)
                -- totFrame.ManaBar:ClearAllPoints()
                -- totFrame.ManaBar:SetPoint("TOPRIGHT", -29, -23)
                --totFrame.ManaBar:SetFrameLevel(1)
            end
        end)


        hooksecurefunc(frame, "CheckFaction", function(self)
            if (self.showPVP) then
                local factionGroup = UnitFactionGroup(self.unit)
                if (factionGroup == "Alliance") then
                    contentContext.PvpIcon:ClearAllPoints()
                    contentContext.PvpIcon:SetPoint("TOPRIGHT", -4, -24)
                elseif (factionGroup == "Horde") then
                    contentContext.PvpIcon:ClearAllPoints()
                    contentContext.PvpIcon:SetPoint("TOPRIGHT", 3, -22)
                end
                contentContext.PrestigePortrait:ClearAllPoints()
                contentContext.PrestigePortrait:SetPoint("TOPRIGHT", 5, -17)
            end
        end)





    elseif frame == PlayerFrame then
        -- PlayerFrame
        -- Frame
        local content = frame.PlayerFrameContent
        local frameContainer = frame.PlayerFrameContainer
        local contentMain = content.PlayerFrameContentMain
        local contentContext = content.PlayerFrameContentContextual



        -- Status
        local hpContainer = contentMain.HealthBarsContainer
        local manaBar = contentMain.ManaBarArea.ManaBar




        frameContainer:SetFrameStrata("MEDIUM")
        frameContainer:SetFrameLevel(4)
        frameContainer.FrameTextureBBF = frame:CreateTexture(nil, "BORDER")
        frameContainer.FrameTextureBBF:SetParent(frameContainer)

        local function GetFrameColor()
            local r,g,b = frameContainer.FrameTexture:GetVertexColor()
            frameContainer.FrameTextureBBF:SetVertexColor(r,g,b)
        end
        GetFrameColor()
        hooksecurefunc(frameContainer.FrameTexture, "SetVertexColor", GetFrameColor)
        -- frameContainer.FrameTextureBBF:SetSize(232, 100)
        -- frameContainer.FrameTextureBBF:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
        -- --frameContainer.FrameTextureBBF:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\ui-targetingframe-nolevel")
        -- frameContainer.FrameTextureBBF:SetTexCoord(1, 0.09375, 0, 0.78125)
        -- frameContainer.FrameTextureBBF:ClearAllPoints()
        -- frameContainer.FrameTextureBBF:SetPoint("TOPLEFT", -19, -5)

        contentMain.HitIndicator:SetParent(contentContext)
        contentMain.HitIndicator.HitText:ClearAllPoints()
        contentMain.HitIndicator.HitText:SetPoint("CENTER", contentMain.HitIndicator, "TOPLEFT", 54, -46)

        contentContext:SetFrameStrata("MEDIUM")
        contentContext:SetFrameLevel(5)
        contentContext.AttackIcon:ClearAllPoints()
        contentContext.AttackIcon:SetPoint("CENTER", PlayerLevelText, "CENTER", 1, 1)
        contentContext.AttackIcon:SetSize(32, 31)
        contentContext.AttackIcon:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
        contentContext.AttackIcon:SetTexCoord(0.5, 1.0, 0, 0.484375)
        contentContext.PlayerPortraitCornerIcon:SetAtlas(nil)
        contentContext.PrestigePortrait:ClearAllPoints()
        contentContext.PrestigePortrait:SetPoint("TOPLEFT", -4, -17)
        contentContext.LeaderIcon:ClearAllPoints()
        contentContext.LeaderIcon:SetPoint("TOPLEFT", 86, -14)
        contentContext.RoleIcon:ClearAllPoints()
        contentContext.RoleIcon:SetPoint("TOPLEFT", 192, -34)
        AdjustFramePoint(contentContext.GroupIndicator, nil, -3)





        frameContainer.PlayerPortrait:SetSize(64, 64)
        frameContainer.PlayerPortrait:ClearAllPoints()
        frameContainer.PlayerPortrait:SetPoint("TOPLEFT", 23, -19)
        frameContainer.PlayerPortraitMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        frameContainer.PlayerPortraitMask:ClearAllPoints()
        frameContainer.PlayerPortraitMask:SetPoint("CENTER", frameContainer.PlayerPortrait, "CENTER", 0, 0)



        local a2,b2,c2,d2,e2 = PlayerFrameBottomManagedFramesContainer:GetPoint()

        --AdjustFramePoint(hpContainer.HealthBarMask, 0, -7)
        --SetXYPoint(hpContainer.HealthBarMask, nil, -1)
        --hpContainer.HealthBarMask:SetHeight(18)


        frame.bbfClassicBg = frame:CreateTexture(nil, "BACKGROUND")
        frame.bbfClassicBg:SetColorTexture(0,0,0,0.45)
        frame.bbfClassicBg:SetPoint("TOPLEFT", hpContainer.HealthBar, "TOPLEFT", 0, 11)
        frame.bbfClassicBg:SetPoint("BOTTOMRIGHT", manaBar, "BOTTOMRIGHT", -3, 0)



        hpContainer.LeftText:SetParent(frameContainer)
        hpContainer.LeftText:ClearAllPoints()
        hpContainer.LeftText:SetPoint("LEFT", frameContainer.FrameTextureBBF, "LEFT", 109, 2.6)
        hpContainer.RightText:SetParent(frameContainer)
        hpContainer.RightText:ClearAllPoints()
        hpContainer.RightText:SetPoint("RIGHT", frameContainer.FrameTextureBBF, "RIGHT", -7, 2.6)
        hpContainer.HealthBarText:SetParent(frameContainer)
        hpContainer.HealthBarText:ClearAllPoints()
        hpContainer.HealthBarText:SetPoint("CENTER", frameContainer.FrameTextureBBF, "CENTER", 52, 2.6)

        manaBar.LeftText:SetParent(frameContainer)
        manaBar.LeftText:ClearAllPoints()
        manaBar.LeftText:SetPoint("LEFT", frameContainer.FrameTextureBBF, "LEFT", 109, -8.5)
        manaBar.RightText:SetParent(frameContainer)
        manaBar.RightText:ClearAllPoints()
        manaBar.RightText:SetPoint("RIGHT", frameContainer.FrameTextureBBF, "RIGHT", -7, -8.5)
        manaBar.ManaBarText:SetParent(frameContainer)
        manaBar.ManaBarText:ClearAllPoints()
        manaBar.ManaBarText:SetPoint("CENTER", frameContainer.FrameTextureBBF, "CENTER", 52, -8.5)

        --AdjustFramePoint(manaBar, 0, 3)
        AdjustFramePoint(hpContainer.HealthBar.OverAbsorbGlow,-3)

        if ComboFrame then
            ComboFrame:ClearAllPoints()
            ComboFrame:SetPoint("TOPRIGHT", TargetFrame, "TOPRIGHT", -31, -26)
        end

        local function UpdateLevel()
            PlayerLevelText:SetParent(contentContext)
            PlayerLevelText:SetDrawLayer("OVERLAY")
            PlayerLevelText:ClearAllPoints()
            PlayerLevelText:SetPoint("CENTER", -81, -24.5)
            PlayerLevelText:Show()
        end
        hooksecurefunc("PlayerFrame_UpdateLevel", function()
            UpdateLevel()
        end)
        UpdateLevel()
        hooksecurefunc("PlayerFrame_UpdateRolesAssigned", function()
            contentContext.RoleIcon:ClearAllPoints()
            contentContext.RoleIcon:SetPoint("TOPLEFT", 192, -34)
            PlayerLevelText:SetShown(not UnitHasVehiclePlayerFrameUI("player"))
        end)

        local DEFAULT_X, DEFAULT_Y = 29, 29.5
        local resourceFramePositions = {
            EVOKER = {x = 28, y = 31, scale = 1.05, specs = {[1473] = { x = 30, y = 24 }}},
            WARRIOR = { x = 28, y = 30 },
            ROGUE   = { x = 48, y = 38, scale = 0.85},
            MAGE = { x = 32, y = 32, scale = 0.95 },
            PALADIN = { scale = 0.91 },
            DEATHKNIGHT = { x = 35, y = 34, scale = 0.90 },
            DRUID = { x = 30, y = 30},
        }

        local function GetPlayerClassAndSpecPosition()
            local _, classToken = UnitClass("player")
            local specID = GetSpecialization() and GetSpecializationInfo(GetSpecialization())
            local position = resourceFramePositions[classToken]

            if position then
                if position.specs and specID and position.specs[specID] then
                    local specData = position.specs[specID]
                    local x = specData.x or DEFAULT_X
                    local y = specData.y or DEFAULT_Y
                    local scale = specData.scale
                    return x, y, scale
                end
                local x = position.x or DEFAULT_X
                local y = position.y or DEFAULT_Y
                local scale = position.scale or 1
                return x, y, scale
            end

            return DEFAULT_X, DEFAULT_Y, 1
        end

        local function ToPlayerArt()
            if not InCombatLockdown() then
                PlayerFrameBottomManagedFramesContainer:ClearAllPoints()
                local xOffset, yOffset, scale = GetPlayerClassAndSpecPosition()
                PlayerFrameBottomManagedFramesContainer:SetPoint(a2, b2, c2, xOffset, yOffset)
                PlayerFrameBottomManagedFramesContainer:SetScale(scale)
                PlayerFrameBottomManagedFramesContainer:SetFrameStrata("MEDIUM")
            else
                PlayerFrameBottomManagedFramesContainer.positionNeedsUpdate = true
                if not BBF.CombatWaiter then
                    BBF.CombatWaiter = CreateFrame("Frame")
                    BBF.CombatWaiter:SetScript("OnEvent", function(self)
                        if PlayerFrameBottomManagedFramesContainer.positionNeedsUpdate then
                            PlayerFrameBottomManagedFramesContainer.positionNeedsUpdate = false
                            ToPlayerArt()
                        end
                        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
                    end)
                end
                if not BBF.CombatWaiter:IsEventRegistered("PLAYER_REGEN_ENABLED") then
                    BBF.CombatWaiter:RegisterEvent("PLAYER_REGEN_ENABLED")
                end
            end

            AdjustFramePoint(hpContainer.HealthBarMask, 0, -11)
            hpContainer.HealthBarMask:SetSize(126, 17)

            manaBar.ManaBarMask:SetSize(126, 19)
            AdjustFramePoint(manaBar.ManaBarMask, 0, 2)

            frameContainer.FrameTexture:ClearAllPoints()
            frameContainer.FrameTexture:SetPoint("TOPLEFT", -19, 7)
            frameContainer.FrameTexture:SetAlpha(0)

            frameContainer.FrameTextureBBF:SetSize(232, 100)
            frameContainer.FrameTextureBBF:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
            --frameContainer.FrameTextureBBF:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\ui-targetingframe-nolevel")
            frameContainer.FrameTextureBBF:SetTexCoord(1, 0.09375, 0, 0.78125)
            frameContainer.FrameTextureBBF:ClearAllPoints()
            frameContainer.FrameTextureBBF:SetPoint("TOPLEFT", -19, -8)
            frameContainer.FrameTextureBBF:SetDrawLayer("BORDER")

            frameContainer.AlternatePowerFrameTexture:SetSize(232, 100)
            frameContainer.AlternatePowerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
            frameContainer.AlternatePowerFrameTexture:SetTexCoord(1, 0.09375, 0, 0.78125)
            frameContainer.AlternatePowerFrameTexture:ClearAllPoints()
            frameContainer.AlternatePowerFrameTexture:SetPoint("TOPLEFT", -19, -8)
            frameContainer.AlternatePowerFrameTexture:SetAlpha(0)

            frameContainer.FrameFlash:SetParent(BetterBlizzFramesDB.hideCombatGlow and BBF.hiddenFrame or frame)
            frameContainer.FrameFlash:SetSize(242, 93)
            frameContainer.FrameFlash:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash")
            frameContainer.FrameFlash:SetTexCoord(0.9453125, 0, 0, 0.181640625)
            frameContainer.FrameFlash:ClearAllPoints()
            frameContainer.FrameFlash:SetPoint("TOPLEFT", -6, -8)
            frameContainer.FrameFlash:SetDrawLayer("BACKGROUND")

            contentMain.StatusTexture:SetParent(BetterBlizzFramesDB.hidePlayerRestGlow and BBF.hiddenFrame or contentContext)
            contentMain.StatusTexture:SetSize(190, 66)
            contentMain.StatusTexture:SetTexture("Interface\\CharacterFrame\\UI-Player-Status")
            contentMain.StatusTexture:SetTexCoord(0, 0.74609375, 0, 0.53125)
            contentMain.StatusTexture:ClearAllPoints()
            contentMain.StatusTexture:SetPoint("TOPLEFT", 16, -16)
            contentMain.StatusTexture:SetBlendMode("ADD")




            -- hpContainer.LeftText:SetParent(frameContainer)
            -- hpContainer.LeftText:ClearAllPoints()
            -- hpContainer.LeftText:SetPoint("LEFT", frameContainer.FrameTextureBBF, "LEFT", 109, 3)
            -- hpContainer.RightText:SetParent(frameContainer)
            -- hpContainer.RightText:ClearAllPoints()
            -- hpContainer.RightText:SetPoint("RIGHT", frameContainer.FrameTextureBBF, "RIGHT", -7, 3)
            -- hpContainer.HealthBarText:SetParent(frameContainer)
            -- hpContainer.HealthBarText:ClearAllPoints()
            -- hpContainer.HealthBarText:SetPoint("CENTER", frameContainer.FrameTextureBBF, "CENTER", 52, 3)

            -- manaBar.LeftText:SetParent(frameContainer)
            -- manaBar.LeftText:ClearAllPoints()
            -- manaBar.LeftText:SetPoint("LEFT", frameContainer.FrameTextureBBF, "LEFT", 109, -8.5)
            -- manaBar.RightText:SetParent(frameContainer)
            -- manaBar.RightText:ClearAllPoints()
            -- manaBar.RightText:SetPoint("RIGHT", frameContainer.FrameTextureBBF, "RIGHT", -7, -8.5)
            -- manaBar.ManaBarText:SetParent(frameContainer)
            -- manaBar.ManaBarText:ClearAllPoints()
            -- manaBar.ManaBarText:SetPoint("CENTER", frameContainer.FrameTextureBBF, "CENTER", 52, -8.5)

            frameContainer.PlayerPortrait:ClearAllPoints()
            frameContainer.PlayerPortrait:SetPoint("TOPLEFT", 23, -19)
            frameContainer.FrameTextureBBF:Show()

            frame.bbfClassicBg:SetPoint("BOTTOMRIGHT", contentMain.HealthBarsContainer, "BOTTOMRIGHT", -3, -11)

        end

        hooksecurefunc("PlayerFrame_ToPlayerArt", function()
            ToPlayerArt()
        end)
        ToPlayerArt()

        local function ToVehicleArt()
            frameContainer.VehicleFrameTexture:SetSize(240, 120)
            frameContainer.VehicleFrameTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame")
            frameContainer.VehicleFrameTexture:ClearAllPoints()
            frameContainer.VehicleFrameTexture:SetPoint("TOPLEFT", -3, 1)
            frameContainer.VehicleFrameTexture:SetDrawLayer("BORDER")
            frameContainer.FrameTextureBBF:Hide()

            hpContainer.HealthBarMask:SetSize(120, 32)

            frameContainer.FrameFlash:SetParent(frame)
            frameContainer.FrameFlash:SetSize(242, 93)
            frameContainer.FrameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Flash")
            frameContainer.FrameFlash:SetTexCoord(-0.02, 1, 0.07, 0.86)
            frameContainer.FrameFlash:ClearAllPoints()
            frameContainer.FrameFlash:SetPoint("TOPLEFT", -6, -4)
            frameContainer.FrameFlash:SetDrawLayer("BACKGROUND")

            contentMain.StatusTexture:SetParent(frame)
            contentMain.StatusTexture:SetSize(242, 93)
            contentMain.StatusTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Flash")
            contentMain.StatusTexture:SetTexCoord(-0.02, 1, 0.07, 0.86)
            contentMain.StatusTexture:ClearAllPoints()
            contentMain.StatusTexture:SetPoint("TOPLEFT", -6, -4)
            contentMain.StatusTexture:SetDrawLayer("BACKGROUND")

            hpContainer.LeftText:SetParent(frameContainer)
            hpContainer.LeftText:ClearAllPoints()
            hpContainer.LeftText:SetPoint("LEFT", frameContainer.FrameTextureBBF, "LEFT", 109, 1.5)
            hpContainer.RightText:SetParent(frameContainer)
            hpContainer.RightText:ClearAllPoints()
            hpContainer.RightText:SetPoint("RIGHT", frameContainer.FrameTextureBBF, "RIGHT", -7, 1.5)
            hpContainer.HealthBarText:SetParent(frameContainer)
            hpContainer.HealthBarText:ClearAllPoints()
            hpContainer.HealthBarText:SetPoint("CENTER", frameContainer.FrameTextureBBF, "CENTER", 52, 1.5)

            manaBar.LeftText:SetParent(frameContainer)
            manaBar.LeftText:ClearAllPoints()
            manaBar.LeftText:SetPoint("LEFT", frameContainer.FrameTextureBBF, "LEFT", 109, -9)
            manaBar.RightText:SetParent(frameContainer)
            manaBar.RightText:ClearAllPoints()
            manaBar.RightText:SetPoint("RIGHT", frameContainer.FrameTextureBBF, "RIGHT", -7, -9)
            manaBar.ManaBarText:SetParent(frameContainer)
            manaBar.ManaBarText:ClearAllPoints()
            manaBar.ManaBarText:SetPoint("CENTER", frameContainer.FrameTextureBBF, "CENTER", 52, -9)

            frameContainer.PlayerPortrait:ClearAllPoints()
            frameContainer.PlayerPortrait:SetPoint("TOPLEFT", 23, -17)

            frame.bbfClassicBg:SetPoint("BOTTOMRIGHT", contentMain.HealthBarsContainer, "BOTTOMRIGHT", -7, -12)
        end

        hooksecurefunc("PlayerFrame_ToVehicleArt", function(self)
            ToVehicleArt()

            -- self.PlayerFrameContent.PlayerFrameContentContextual.GroupIndicator:ClearAllPoints()
            -- self.PlayerFrameContent.PlayerFrameContentContextual.GroupIndicator:SetPoint("BOTTOMLEFT", CfPlayerFrame, "TOPLEFT", 97, -13)
            -- self.PlayerFrameContent.PlayerFrameContentContextual.RoleIcon:SetPoint("TOPLEFT", 76, -19)

            -- PlayerName:SetParent(frameContainer)
            -- PlayerName:ClearAllPoints()
            -- PlayerName:SetPoint("TOPLEFT", frameContainer, "TOPLEFT", 97, -25.5)

            -- CfPlayerFrameHealthBar:SetWidth(100)
            -- CfPlayerFrameHealthBar:SetPoint("TOPLEFT",119,-41)
            -- CfPlayerFrameManaBar:SetWidth(100)
            -- CfPlayerFrameManaBar:SetPoint("TOPLEFT",119,-52)
            -- CfPlayerFrameBackground:SetSize(114, 41)
            -- PlayerLevelText:Hide()

            -- CfUnitFrame_SetUnit(CfPlayerFrame, "vehicle", CfPlayerFrameHealthBar, CfPlayerFrameManaBar)
        end)

    elseif frame == PetFrame then
        PetFrame:SetSize(128, 53)
        PetPortrait:ClearAllPoints()
        PetPortrait:SetPoint("TOPLEFT", 7, -6)

        PetFrameTexture:SetSize(128, 64)
        PetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame")
        PetFrameTexture:ClearAllPoints()
        PetFrameTexture:SetPoint("TOPLEFT", 1, -1)

        PetFrameFlash:SetSize(128, 67)
        PetFrameFlash:SetTexture("Interface\\TargetingFrame\\UI-PartyFrame-Flash")
        PetFrameFlash:SetPoint("TOPLEFT", -3, 12)
        PetFrameFlash:SetTexCoord(0, 1, 1, 0)
        PetFrameFlash:SetDrawLayer("BACKGROUND")

        PetFrameHealthBar:SetSize(69, 8)
        PetFrameHealthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        PetFrameHealthBar:SetStatusBarColor(0, 1, 0)
        PetFrameHealthBar:ClearAllPoints()
        PetFrameHealthBar:SetPoint("TOPLEFT", 47, -22)
        PetFrameHealthBar:SetFrameLevel(1)
        PetFrameHealthBarMask:Hide()

        PetFrameManaBar:SetSize(71, 8)
        PetFrameManaBar:ClearAllPoints()
        PetFrameManaBar:SetPoint("TOPLEFT", 45, -29)
        PetFrameManaBar:SetFrameLevel(1)
        PetFrameManaBarMask:Hide()

        PetFrameHealthBarText:SetParent(PetFrame)
        PetFrameHealthBarTextLeft:SetParent(PetFrame)
        PetFrameHealthBarTextRight:SetParent(PetFrame)
        PetFrameManaBarText:SetParent(PetFrame)
        PetFrameManaBarTextLeft:SetParent(PetFrame)
        PetFrameManaBarTextRight:SetParent(PetFrame)

        PetFrameHealthBarText:ClearAllPoints()
        PetFrameHealthBarText:SetPoint("CENTER", PetFrame, "TOPLEFT", 82, -26)
        PetFrameHealthBarTextLeft:ClearAllPoints()
        PetFrameHealthBarTextLeft:SetPoint("LEFT", PetFrame, "TOPLEFT", 46, -26)
        PetFrameHealthBarTextRight:ClearAllPoints()
        PetFrameHealthBarTextRight:SetPoint("RIGHT", PetFrame, "TOPLEFT", 113, -26)
        PetFrameManaBarText:ClearAllPoints()
        PetFrameManaBarText:SetPoint("CENTER", PetFrame, "TOPLEFT", 82, -35)
        PetFrameManaBarTextLeft:ClearAllPoints()
        PetFrameManaBarTextLeft:SetPoint("LEFT", PetFrame, "TOPLEFT", 46, -35)
        PetFrameManaBarTextRight:ClearAllPoints()
        PetFrameManaBarTextRight:SetPoint("RIGHT", PetFrame, "TOPLEFT", 113, -35)

        PetFrameOverAbsorbGlow:SetParent(PetFrame)
        PetFrameOverAbsorbGlow:SetDrawLayer("ARTWORK", 7)

        PetAttackModeTexture:SetSize(76, 64)
        PetAttackModeTexture:SetTexture("Interface\\TargetingFrame\\UI-Player-AttackStatus")
        PetAttackModeTexture:SetTexCoord(0.703125, 1, 0, 1)
        PetAttackModeTexture:ClearAllPoints()
        PetAttackModeTexture:SetPoint("TOPLEFT", 6, -9)

        PetHitIndicator:ClearAllPoints()
        PetHitIndicator:SetPoint("CENTER", PetFrame, "TOPLEFT", 28, -27)
    end
end

local function AdjustAlternateBars()
    local class = select(2, UnitClass("player"))

    AlternatePowerBar:SetSize(104, 12)
    AlternatePowerBar:ClearAllPoints()
    AlternatePowerBar:SetPoint("BOTTOMLEFT", 95, 16)

    AlternatePowerBarText:SetPoint("CENTER", 2, -1)
    AlternatePowerBar.LeftText:SetPoint("LEFT", 0, -1)
    AlternatePowerBar.RightText:SetPoint("RIGHT", 0, -1)

    AlternatePowerBar.bbfClassicBg = AlternatePowerBar:CreateTexture(nil, "BACKGROUND")
    AlternatePowerBar.bbfClassicBg:SetAllPoints()
    AlternatePowerBar.bbfClassicBg:SetColorTexture(0, 0, 0, 0.5)

    AlternatePowerBar.Border = AlternatePowerBar:CreateTexture(nil, "OVERLAY")
    AlternatePowerBar.Border:SetSize(0, 16)
    AlternatePowerBar.Border:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
    AlternatePowerBar.Border:SetTexCoord(0.125, 0.250, 1, 0)
    AlternatePowerBar.Border:SetPoint("TOPLEFT", 4, 0)
    AlternatePowerBar.Border:SetPoint("TOPRIGHT", -4, 0)

    AlternatePowerBar.LeftBorder = AlternatePowerBar:CreateTexture(nil, "OVERLAY")
    AlternatePowerBar.LeftBorder:SetSize(16, 16)
    AlternatePowerBar.LeftBorder:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
    AlternatePowerBar.LeftBorder:SetTexCoord(0, 0.125, 1, 0)
    AlternatePowerBar.LeftBorder:SetPoint("RIGHT", AlternatePowerBar.Border, "LEFT")

    AlternatePowerBar.RightBorder = AlternatePowerBar:CreateTexture(nil, "OVERLAY")
    AlternatePowerBar.RightBorder:SetSize(16, 16)
    AlternatePowerBar.RightBorder:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
    AlternatePowerBar.RightBorder:SetTexCoord(0.125, 0, 1, 0)
    AlternatePowerBar.RightBorder:SetPoint("LEFT", AlternatePowerBar.Border, "RIGHT")

    if BetterBlizzFramesDB.changeUnitFrameManabarTexture then
        hooksecurefunc(AlternatePowerBar, "EvaluateUnit", function(self)
            self:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
            self:SetStatusBarColor(0, 0, 1)

            if self.PowerBarMask then
                self.PowerBarMask:Hide()
            end
        end)
    else
        AdjustFramePoint(AlternatePowerBar.PowerBarMask, nil, -1)
    end

    if class == "MONK" then
        MonkStaggerBar:SetSize(94, 12)
        MonkStaggerBar:ClearAllPoints()
        MonkStaggerBar:SetPoint("TOPLEFT", PlayerFrameAlternatePowerBarArea, "TOPLEFT", 101, -72)

        MonkStaggerBar.PowerBarMask:Hide()

        MonkStaggerBarText:SetPoint("CENTER", 1, -1)
        MonkStaggerBar.LeftText:SetPoint("LEFT", 0, -1)
        MonkStaggerBar.RightText:SetPoint("RIGHT", 0, -1)

        MonkStaggerBar.Background = MonkStaggerBar:CreateTexture(nil, "BACKGROUND")
        MonkStaggerBar.Background:SetSize(128, 16)
        MonkStaggerBar.Background:SetTexture("Interface\\PlayerFrame\\MonkManaBar")
        MonkStaggerBar.Background:SetTexCoord(0, 1, 0.5, 1)
        MonkStaggerBar.Background:SetPoint("TOPLEFT", -17, 0)

        MonkStaggerBar.Border = MonkStaggerBar:CreateTexture(nil, "OVERLAY")
        MonkStaggerBar.Border:SetSize(128, 16)
        MonkStaggerBar.Border:SetTexture("Interface\\PlayerFrame\\MonkManaBar")
        MonkStaggerBar.Border:SetTexCoord(0, 1, 0, 0.5)
        MonkStaggerBar.Border:SetPoint("TOPLEFT", -17, 0)

        hooksecurefunc(MonkStaggerBar, "EvaluateUnit", function(self)
            self:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
            self:SetStatusBarColor(0, 0, 1)
        end)
    end

    if class == "EVOKER" then
        EvokerEbonMightBar:SetSize(104, 12)
        EvokerEbonMightBar:ClearAllPoints()
        EvokerEbonMightBar:SetPoint("BOTTOMLEFT", 95, 17)

        EvokerEbonMightBarText:SetPoint("CENTER", 1, -1)
        EvokerEbonMightBar.LeftText:SetPoint("LEFT", 0, -1)
        EvokerEbonMightBar.RightText:SetPoint("RIGHT", 0, -1)

        EvokerEbonMightBar.bbfClassicBg = EvokerEbonMightBar:CreateTexture(nil, "BACKGROUND")
        EvokerEbonMightBar.bbfClassicBg:SetAllPoints()
        EvokerEbonMightBar.bbfClassicBg:SetColorTexture(0, 0, 0, 0.5)

        EvokerEbonMightBar.Border = EvokerEbonMightBar:CreateTexture(nil, "OVERLAY")
        EvokerEbonMightBar.Border:SetSize(0, 16)
        EvokerEbonMightBar.Border:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
        EvokerEbonMightBar.Border:SetTexCoord(0.125, 0.250, 1, 0)
        EvokerEbonMightBar.Border:SetPoint("TOPLEFT", 4, 0)
        EvokerEbonMightBar.Border:SetPoint("TOPRIGHT", -4, 0)

        EvokerEbonMightBar.LeftBorder = EvokerEbonMightBar:CreateTexture(nil, "OVERLAY")
        EvokerEbonMightBar.LeftBorder:SetSize(16, 16)
        EvokerEbonMightBar.LeftBorder:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
        EvokerEbonMightBar.LeftBorder:SetTexCoord(0, 0.125, 1, 0)
        EvokerEbonMightBar.LeftBorder:SetPoint("RIGHT", EvokerEbonMightBar.Border, "LEFT")

        EvokerEbonMightBar.RightBorder = EvokerEbonMightBar:CreateTexture(nil, "OVERLAY")
        EvokerEbonMightBar.RightBorder:SetSize(16, 16)
        EvokerEbonMightBar.RightBorder:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
        EvokerEbonMightBar.RightBorder:SetTexCoord(0.125, 0, 1, 0)
        EvokerEbonMightBar.RightBorder:SetPoint("LEFT", EvokerEbonMightBar.Border, "RIGHT")

        hooksecurefunc(EvokerEbonMightBar, "EvaluateUnit", function(self)
            self:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
            self:SetStatusBarColor(1, 0.5, 0.25)

            if self.PowerBarMask then
                self.PowerBarMask:Hide()
            end
        end)
    end

    local classicFrameColorTargets = {
        AlternatePowerBar.Border,
        AlternatePowerBar.LeftBorder,
        AlternatePowerBar.RightBorder,
    }

    if class == "MONK" then
        tinsert(classicFrameColorTargets, MonkStaggerBar.Border)
    end

    if class == "EVOKER" then
        tinsert(classicFrameColorTargets, EvokerEbonMightBar.Border)
        tinsert(classicFrameColorTargets, EvokerEbonMightBar.LeftBorder)
        tinsert(classicFrameColorTargets, EvokerEbonMightBar.RightBorder)
    end

    local function GetFrameColor()
        local r, g, b = PlayerFrame.PlayerFrameContainer.FrameTexture:GetVertexColor()
        for _, frame in pairs(classicFrameColorTargets) do
            if frame then
                frame:SetVertexColor(r, g, b)
            end
        end
    end
    GetFrameColor()
    hooksecurefunc(PlayerFrame.PlayerFrameContainer.FrameTexture, "SetVertexColor", GetFrameColor)
end

function BBF.ClassicFrames()
    if not BetterBlizzFramesDB.classicFrames then return end
    MakeClassicFrame(TargetFrame)
    MakeClassicFrame(FocusFrame)
    MakeClassicFrame(PlayerFrame)
    MakeClassicFrame(PetFrame)
    AdjustAlternateBars()
end