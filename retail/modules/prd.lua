local LSM = LibStub("LibSharedMedia-3.0")

local fancyPRDTokenAtlasMap = {
    ["LUNAR_POWER"] = "Unit_Druid_AstralPower_Fill",
    ["FURY"]        = "Unit_DemonHunter_Fury_Fill",
    ["PAIN"]        = "Unit_DemonHunter_Fury_Fill",
    ["MAELSTROM"]   = "Unit_Shaman_Maelstrom_Fill",
    ["INSANITY"]    = "Unit_Priest_Insanity_Fill",
}

local fancyPRDAltBarClassAtlasMap = {
    ["EVOKER"] = "Unit_Evoker_EbonMight_Fill",
}

local monkStaggerAtlasMap = {
    ["green"]  = "Unit_Monk_Stagger_Fill_Green",
    ["yellow"] = "Unit_Monk_Stagger_Fill_Yellow",
    ["red"]    = "Unit_Monk_Stagger_Fill_Red",
}

function BBF.HidePersonalManabarFX()
    if BetterBlizzFramesDB.hidePersonalManaFX then
        if PersonalResourceDisplayFrame then
            PersonalResourceDisplayFrame.PowerBar.FullPowerFrame:SetParent(BBF.hiddenFrame)
            PersonalResourceDisplayFrame.PowerBar.FeedbackFrame:SetParent(BBF.hiddenFrame)
        end
    end
end

local function ApplyPRDBarMask(bar, container)
    if not bar or bar:IsForbidden() then return end
    if not bar.bbfPRDMask then
        bar.bbfPRDMask = bar:CreateMaskTexture()
    end
    local mask = bar.bbfPRDMask
    mask:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\midnightNpMask.tga")
    mask:ClearAllPoints()
    mask:SetPoint("TOPLEFT", container, "TOPLEFT", -0.5, 1)
    mask:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0.5, -1)
    mask:Show()
    bar:GetStatusBarTexture():AddMaskTexture(mask)
end
BBF.ApplyPRDBarMask = ApplyPRDBarMask

local function ApplyPRDMasks()
    if BetterBlizzFramesDB.prdLegacyLook then return end
    local db = BetterBlizzFramesDB
    local prd = PersonalResourceDisplayFrame
    local healthBar = prd.HealthBarsContainer.healthBar

    local hpTextureActive   = db.changePrdTextures and db.useCustomTextureForSelf
    local manaTextureActive = db.changePrdTextures and db.useCustomTextureForSelfMana

    if hpTextureActive then
        ApplyPRDBarMask(healthBar, prd.HealthBarsContainer)
        if healthBar.totalAbsorb and not healthBar.totalAbsorb:IsForbidden() then
            if not healthBar.totalAbsorb.bbfPRDMasked then
                ApplyPRDBarMask(healthBar, prd.HealthBarsContainer)
                healthBar.totalAbsorb:AddMaskTexture(healthBar.bbfPRDMask)
                healthBar.totalAbsorb.bbfPRDMasked = true
            end
        end
    else
        if healthBar.bbfPRDMask then
            healthBar.bbfPRDMask:Hide()
        end
    end

    if manaTextureActive then
        ApplyPRDBarMask(prd.PowerBar, prd.PowerBar)
        if prd.AlternatePowerBar and prd.AlternatePowerBar:IsShown() then
            ApplyPRDBarMask(prd.AlternatePowerBar, prd.AlternatePowerBar)
        end
    else
        if prd.PowerBar.bbfPRDMask then
            prd.PowerBar.bbfPRDMask:Hide()
        end
        if prd.AlternatePowerBar and prd.AlternatePowerBar.bbfPRDMask then
            prd.AlternatePowerBar.bbfPRDMask:Hide()
        end
    end
end

local function applyExtraBarTexture(tex, setting)
    if not tex then return end
    if not tex.bbfTextureHooked then
        tex.bbfTextureHooked = true
        hooksecurefunc(tex, "SetTexture", function(self)
            if self.changingTexture then return end
            if self.bbfTexture then
                self.changingTexture = true
                self:SetTexture(self.bbfTexture)
                self.changingTexture = false
            end
        end)
    end
    tex.bbfTexture = setting
    tex.changingTexture = true
    tex:SetTexture(setting)
    tex.changingTexture = false
end

local function textureExtraBars(frame, setting)
    local extraBars = BetterBlizzFramesDB.useCustomTextureForExtraBars
    if extraBars then
        applyExtraBarTexture(frame.otherHealPrediction, setting)
        applyExtraBarTexture(frame.myHealPrediction, setting)
        applyExtraBarTexture(frame.totalAbsorb, setting)
        applyExtraBarTexture(frame.ManaCostPredictionBar, setting)
        if frame.FeedbackFrame then
            applyExtraBarTexture(frame.FeedbackFrame.BarTexture, setting)
            applyExtraBarTexture(frame.FeedbackFrame.GainGlowTexture, setting)
            applyExtraBarTexture(frame.FeedbackFrame.LossGlowTexture, setting)
        end
        applyExtraBarTexture(frame.myHealAbsorb, setting)
        -- applyExtraBarTexture(frame.totalAbsorbOverlay, setting)
    end
end

function BBF.TexturePRD()
    local customTextureSelf = LSM:Fetch(LSM.MediaType.STATUSBAR, BetterBlizzFramesDB.customTextureSelf)
    local customTextureSelfMana = LSM:Fetch(LSM.MediaType.STATUSBAR, BetterBlizzFramesDB.customTextureSelfMana)

    local frame = PersonalResourceDisplayFrame
    if not frame then return end
    if BetterBlizzFramesDB.changePrdTextures and BetterBlizzFramesDB.useCustomTextureForSelf then
        frame.changedPrdHealthTexture = true
        frame.HealthBarsContainer.healthBar:SetStatusBarTexture(customTextureSelf)
        textureExtraBars(frame.HealthBarsContainer.healthBar, customTextureSelf)
    elseif frame.changedPrdHealthTexture then
        frame.HealthBarsContainer.healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
        textureExtraBars(frame.HealthBarsContainer.healthBar, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
        frame.changedPrdHealthTexture = nil
    end
    if BetterBlizzFramesDB.changePrdTextures and BetterBlizzFramesDB.useCustomTextureForSelfMana then
        frame.changedPrdManaTexture = true
        frame.PowerBar:SetStatusBarTexture(customTextureSelfMana)
        frame.AlternatePowerBar:SetStatusBarTexture(customTextureSelfMana)
        textureExtraBars(frame.PowerBar, customTextureSelfMana)
        textureExtraBars(frame.AlternatePowerBar, customTextureSelfMana)
    elseif frame.changedPrdManaTexture then
        frame.PowerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
        textureExtraBars(frame.PowerBar, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
        frame.AlternatePowerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
        textureExtraBars(frame.AlternatePowerBar, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
        frame.changedPrdManaTexture = nil
    end

    ApplyPRDMasks()

    -- fix borders
    local borderContainers = {
        PersonalResourceDisplayFrame.HealthBarsContainer.border,
        PersonalResourceDisplayFrame.PowerBar.Border,
        PersonalResourceDisplayFrame.AlternatePowerBar.Border,
    }

    for _, borderContainer in ipairs(borderContainers) do
        if borderContainer then
            for _, child in ipairs({borderContainer:GetChildren()}) do
                child:SetIgnoreParentAlpha(true)
            end
            for _, region in ipairs({borderContainer:GetRegions()}) do
                region:SetIgnoreParentAlpha(true)
            end
        end
    end
    BBF.FancyPRDAltTexture()
end

function BBF.FancyPRDAltTexture()
    if BBF.fancyPRDAltTextureRunning then return end
    local prd = PersonalResourceDisplayFrame

    BBF.fancyPRDAltTextureRunning = true

    local db = BetterBlizzFramesDB
    local powerBar = prd.PowerBar
    local altPowerBar = prd.AlternatePowerBar
    local _, playerClass = UnitClass("player")

    if not BBF.fancyPRDColorHooked then
        hooksecurefunc(powerBar, "SetStatusBarColor", function(self, r, g, b, a)
            if self.coloredBarTexture and not self.bbfSettingBarColor then
                self.bbfSettingBarColor = true
                self:SetStatusBarColor(1, 1, 1)
                self.bbfSettingBarColor = nil
            end
        end)
        hooksecurefunc(altPowerBar, "SetStatusBarColor", function(self, r, g, b, a)
            if self.coloredBarTexture and not self.bbfSettingBarColor then
                self.bbfSettingBarColor = true
                self:SetStatusBarColor(1, 1, 1)
                self.bbfSettingBarColor = nil
            end
        end)
        BBF.fancyPRDColorHooked = true
    end

    if not BBF.fancyPRDPowerBarHooked then
        hooksecurefunc(PersonalResourceDisplayFrame, "UpdatePowerBar", function()
            BBF.FancyPRDAltTexture()
        end)
        hooksecurefunc(PersonalResourceDisplayFrame, "UpdateAlternatePowerBar", function()
            BBF.FancyPRDAltTexture()
        end)
        if playerClass == "MONK" then
            hooksecurefunc(MonkStaggerBar, "SetStatusBarTexture", function()
                BBF.FancyPRDAltTexture()
            end)
        end
        BBF.fancyPRDPowerBarHooked = true
    end

    local _, powerToken = UnitPowerType("player")
    local atlas    = db.fancyPrdAltTexture and powerToken and fancyPRDTokenAtlasMap[powerToken]
    local altAtlas
    if db.fancyPrdAltTexture then
        if playerClass == "MONK" then
            local staggerKey = altPowerBar.staggerStateKey
            if staggerKey then
                altAtlas = monkStaggerAtlasMap[staggerKey]
            end
        else
            altAtlas = fancyPRDAltBarClassAtlasMap[playerClass]
        end
    end
    local customTextureActive = db.changePrdTextures and db.useCustomTextureForSelfMana

    -- PowerBar
    if not atlas then
        if powerBar.coloredBarTexture then
            powerBar.coloredBarTexture = nil
            if customTextureActive then
                BBF.TexturePRD()
            elseif db.prdLegacyLook then
                powerBar:SetStatusBarTexture(137014)
            else
                powerBar:SetStatusBarTexture("UI-HUD-CoolDownManager-Bar")
            end
            local pt, ptok, altR, altG, altB = UnitPowerType("player")
            local info = PowerBarColor[ptok] or PowerBarColor[pt]
            if info then
                powerBar:SetStatusBarColor(info.r, info.g, info.b)
            elseif altR then
                powerBar:SetStatusBarColor(altR, altG, altB)
            end
        end
    else
        powerBar:SetStatusBarTexture(atlas)
        powerBar.coloredBarTexture = true
        powerBar:SetStatusBarColor(1, 1, 1)
        if powerBar.FeedbackFrame and powerBar.FeedbackFrame.BarTexture then
            powerBar.FeedbackFrame.BarTexture:SetAtlas(atlas)
        end
        if not db.prdLegacyLook then
            BBF.ApplyPRDBarMask(powerBar, powerBar)
        end
    end

    -- AltPowerBar, Ebon Might and Stagger shows here, but Mealstrom and Insanity for example shows on PowerBar
    if not altAtlas then
        if altPowerBar.coloredBarTexture then
            altPowerBar.coloredBarTexture = nil
            if altPowerBar.bbfOrigBarTextureAtlas then
                altPowerBar.barTextureAtlas = altPowerBar.bbfOrigBarTextureAtlas
                altPowerBar:SetStatusBarTexture(altPowerBar.bbfOrigBarTextureAtlas)
                altPowerBar.bbfOrigBarTextureAtlas = nil
            end
        end
    else
        if not altPowerBar.bbfOrigBarTextureAtlas and altPowerBar.barTextureAtlas then
            altPowerBar.bbfOrigBarTextureAtlas = altPowerBar.barTextureAtlas
        end
        altPowerBar:SetStatusBarTexture(altAtlas)
        altPowerBar.barTextureAtlas = altAtlas
        altPowerBar.coloredBarTexture = true
        altPowerBar:SetStatusBarColor(1, 1, 1)
        if not db.prdLegacyLook and altPowerBar:IsShown() then
            BBF.ApplyPRDBarMask(altPowerBar, altPowerBar)
        end
    end

    BBF.fancyPRDAltTextureRunning = nil
end

function BBF.LegacyPRDLook()
    local prd = PersonalResourceDisplayFrame
    local hpBar = prd.HealthBarsContainer.healthBar
    local powerBar = prd.PowerBar
    local altPowerBar = prd.AlternatePowerBar

    if not BetterBlizzFramesDB.prdLegacyLook then
        if BBF.LegacyPRDLookEnabled then
            BBF.LegacyPRDLookEnabled = false
            if prd.bbfBorderContainer then
                prd.bbfBorderContainer:Hide()
            end
            for _, frame in ipairs({ hpBar, powerBar, altPowerBar }) do
                for _, region in ipairs({ frame:GetRegions() }) do
                    if region.blizzBgBorderTexture then
                        region:SetAtlas("UI-HUD-CoolDownManager-Bar-BG")
                    end
                end
                if frame.bbfPRDMask then
                    frame.bbfPRDMask:Show()
                end
                local customTextureActive
                local db = BetterBlizzFramesDB
                if frame == hpBar then
                    customTextureActive = db.changePrdTextures and db.useCustomTextureForSelf
                else
                    customTextureActive = db.changePrdTextures and db.useCustomTextureForSelfMana
                end
                if not customTextureActive then
                    frame:SetStatusBarTexture("UI-HUD-CoolDownManager-Bar")
                end
                if frame.bbfPRDBarBg then
                    frame.bbfPRDBarBg:Hide()
                end
            end
            prd:UpdatePowerBarAnchor()
            prd:UpdateAdditionalBarAnchors()
        end
        BBF.FancyPRDAltTexture()
        return
    end

    local db = BetterBlizzFramesDB
    local prdBars = { hpBar, powerBar, altPowerBar }

    for _, frame in ipairs(prdBars) do
        for _, region in ipairs({ frame:GetRegions() }) do
            if region:GetObjectType() == "Texture" and region:GetAtlas() == "UI-HUD-CoolDownManager-Bar-BG" then
                region.blizzBgBorderTexture = true
                region:SetTexture(nil)
            end
        end
        if frame.bbfPRDMask then
            frame.bbfPRDMask:Hide()
        end
        local customTextureActive
        if frame == hpBar then
            customTextureActive = db.changePrdTextures and db.useCustomTextureForSelf
        else
            customTextureActive = db.changePrdTextures and db.useCustomTextureForSelfMana
        end
        if not customTextureActive then
            frame:SetStatusBarTexture(137014)
        end
        if not frame.bbfPRDBarBg then
            local bg = frame:CreateTexture(nil, "BACKGROUND", nil, -1)
            bg:SetAllPoints(frame)
            frame.bbfPRDBarBg = bg
        end
        if db.changeNpHpBgColor and db.npBgColorRGB then
            local r, g, b = unpack(db.npBgColorRGB)
            frame.bbfPRDBarBg:SetColorTexture(r, g, b, 0.4)
        else
            frame.bbfPRDBarBg:SetColorTexture(0, 0, 0, 0.4)
        end
        frame.bbfPRDBarBg:Show()
    end

    if not prd.bbfBorderContainer then
        local c = CreateFrame("Frame", nil, prd)
        c:SetAllPoints(prd)
        c:SetFrameStrata("MEDIUM")
        c:SetFrameLevel(500)
        prd.bbfBorderContainer = c
    end
    prd.bbfBorderContainer:Show()

    local bc = prd.bbfBorderContainer

    local function MakePRDTex()
        local t = bc:CreateTexture(nil, "OVERLAY", nil, 7)
        t:SetColorTexture(0, 0, 0, 1)
        t:SetIgnoreParentScale(true)
        t:SetIgnoreParentAlpha(true)
        return t
    end

    if not prd.bbfBorderTop then
        prd.bbfBorderTop    = MakePRDTex()
        prd.bbfBorderBottom = MakePRDTex()
        prd.bbfBorderLeft   = MakePRDTex()
        prd.bbfBorderRight  = MakePRDTex()
        prd.bbfSplitLine1   = MakePRDTex()
        prd.bbfSplitLine2   = MakePRDTex()
    end

    local function UpdatePRDBorderLayout()
        local db = BetterBlizzFramesDB
        local th = (db.changeNameplateBorderSize and db.nameplatePersonalBorderSize) or 1
        local hpShown    = prd.HealthBarsContainer:IsShown()
        local powerShown = powerBar:IsShown()
        local altShown   = altPowerBar:IsShown()

        if not hpShown and not powerShown and not altShown then
            prd.bbfBorderContainer:Hide()
            prd.bbfBorderTop:Hide()
            prd.bbfBorderBottom:Hide()
            prd.bbfBorderLeft:Hide()
            prd.bbfBorderRight:Hide()
            prd.bbfSplitLine1:Hide()
            prd.bbfSplitLine2:Hide()
            return
        end

        prd.bbfBorderContainer:Show()

        local topBar  = hpShown    and hpBar    or (powerShown and powerBar or altPowerBar)
        local lastBar = altShown   and altPowerBar or (powerShown and powerBar or hpBar)

        local bTop = prd.bbfBorderTop
        bTop:ClearAllPoints()
        bTop:SetPoint("TOPLEFT",  topBar, "TOPLEFT",  -th, th)
        bTop:SetPoint("TOPRIGHT", topBar, "TOPRIGHT",  th, th)
        bTop:SetHeight(th)
        bTop:Show()

        local bBot = prd.bbfBorderBottom
        bBot:ClearAllPoints()
        bBot:SetPoint("BOTTOMLEFT",  lastBar, "BOTTOMLEFT",  -th, -th)
        bBot:SetPoint("BOTTOMRIGHT", lastBar, "BOTTOMRIGHT",  th, -th)
        bBot:SetHeight(th)
        bBot:Show()

        local bLeft = prd.bbfBorderLeft
        bLeft:ClearAllPoints()
        bLeft:SetPoint("TOPLEFT",    topBar,  "TOPLEFT",    -th,  th)
        bLeft:SetPoint("BOTTOMLEFT", lastBar, "BOTTOMLEFT", -th, -th)
        bLeft:SetWidth(th)
        bLeft:Show()

        local bRight = prd.bbfBorderRight
        bRight:ClearAllPoints()
        bRight:SetPoint("TOPRIGHT",    topBar,  "TOPRIGHT",    th,  th)
        bRight:SetPoint("BOTTOMRIGHT", lastBar, "BOTTOMRIGHT", th, -th)
        bRight:SetWidth(th)
        bRight:Show()

        if db.prdSplitLines then
            local sl1 = prd.bbfSplitLine1
            if hpShown and powerShown then
                sl1:ClearAllPoints()
                sl1:SetPoint("BOTTOMLEFT",  hpBar, "BOTTOMLEFT",  -th, 0)
                sl1:SetPoint("BOTTOMRIGHT", hpBar, "BOTTOMRIGHT",  th, 0)
                sl1:SetHeight(th)
                sl1:Show()
            else
                sl1:Hide()
            end

            local sl2 = prd.bbfSplitLine2
            if altShown and powerShown then
                sl2:ClearAllPoints()
                sl2:SetPoint("BOTTOMLEFT",  powerBar, "BOTTOMLEFT",  -th, 0)
                sl2:SetPoint("BOTTOMRIGHT", powerBar, "BOTTOMRIGHT",  th, 0)
                sl2:SetHeight(th)
                sl2:Show()
            else
                sl2:Hide()
            end
        else
            prd.bbfSplitLine1:Hide()
            prd.bbfSplitLine2:Hide()
        end
    end

    prd.bbfUpdateBorderLayout = UpdatePRDBorderLayout

    if BBF.LegacyPRDLookEnabled then
        UpdatePRDBorderLayout()
        BBF.FancyPRDAltTexture()
        return
    end

    BBF.LegacyPRDLookEnabled = true

    local function TweakPowerBarAnchor(self)
        if not BBF.LegacyPRDLookEnabled then return end
        self.PowerBar:ClearAllPoints()
        if self.hideHealth then
            self.PowerBar:SetPoint("TOP", self, "TOP", 0, 0)
        else
            self.PowerBar:SetPoint("TOP", self.HealthBarsContainer, "BOTTOM", 0, 0)
        end
    end

    local function TweakAdditionalBarAnchors(self)
        if not BBF.LegacyPRDLookEnabled then return end
        local alternatePowerBarShown = self.AlternatePowerBar:IsShown()
        local classFrameContainerShown = self.ClassFrameContainer:IsShown()

        if alternatePowerBarShown then
            self.AlternatePowerBar:ClearAllPoints()
            if not self.hidePower then
                self.AlternatePowerBar:SetPoint("TOP", self.PowerBar, "BOTTOM", 0, 0)
            elseif not self.hideHealth then
                self.AlternatePowerBar:SetPoint("TOP", self.HealthBarsContainer, "BOTTOM", 0, 0)
            else
                self.AlternatePowerBar:SetPoint("TOP", self, "TOP", 0, 0)
            end
        end

        if classFrameContainerShown then
            self.ClassFrameContainer:ClearAllPoints()
            if alternatePowerBarShown then
                self.ClassFrameContainer:SetPoint("TOP", self.AlternatePowerBar, "BOTTOM", 0, self.ClassFrameContainer.yOffset)
            elseif not self.hidePower then
                self.ClassFrameContainer:SetPoint("TOP", self.PowerBar, "BOTTOM", 0, self.ClassFrameContainer.yOffset)
            elseif not self.hideHealth then
                self.ClassFrameContainer:SetPoint("TOP", self.HealthBarsContainer, "BOTTOM", 0, self.ClassFrameContainer.yOffset)
            else
                self.ClassFrameContainer:SetPoint("TOP", self, "TOP", 0, self.ClassFrameContainer.yOffset)
            end
        end
        if self == PersonalResourceDisplayFrame and prd.bbfUpdateBorderLayout then
            prd.bbfUpdateBorderLayout()
        end
    end

    altPowerBar:HookScript("OnShow", function()
        C_Timer.After(0, function() -- Next frame, toggling ui is too fast
            UpdatePRDBorderLayout()
            TweakPowerBarAnchor(PersonalResourceDisplayFrame)
            TweakAdditionalBarAnchors(PersonalResourceDisplayFrame)
        end)
    end)
    altPowerBar:HookScript("OnHide", function()
        UpdatePRDBorderLayout()
        TweakPowerBarAnchor(PersonalResourceDisplayFrame)
        TweakAdditionalBarAnchors(PersonalResourceDisplayFrame)
    end)

    TweakPowerBarAnchor(PersonalResourceDisplayFrame)
    TweakAdditionalBarAnchors(PersonalResourceDisplayFrame)

    hooksecurefunc(PersonalResourceDisplayMixin, "UpdatePowerBarAnchor", TweakPowerBarAnchor)
    hooksecurefunc(PersonalResourceDisplayMixin, "UpdateAdditionalBarAnchors", TweakAdditionalBarAnchors)
    hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function()
        C_Timer.After(0, function()
            UpdatePRDBorderLayout()
            TweakPowerBarAnchor(PersonalResourceDisplayFrame)
            TweakAdditionalBarAnchors(PersonalResourceDisplayFrame)
        end)
    end)
    BBF.FancyPRDAltTexture()
end