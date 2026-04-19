local L = BBF.L
local UnitIsFriend = UnitIsFriend
local UnitIsEnemy = UnitIsEnemy
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass

local LSM = LibStub("LibSharedMedia-3.0")

local healthbarsHooked = nil
local classColorsOn
local colorPetAfterOwner
local skipPlayer
local skipFriendly

local function getUnitReaction(unit)
    if UnitIsFriend(unit, "player") then
        return "FRIENDLY"
    elseif UnitIsEnemy(unit, "player") then
        return "HOSTILE"
    else
        return "NEUTRAL"
    end
end

local OnSetPointHookScript = function(point, relativeTo, relativePoint, xOffset, yOffset)
    return function(frame, _, _, _, _, _, flag)
        if flag ~= "BBFHookSetPoint" then
            frame:ClearAllPoints()
            frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset, "BBFHookSetPoint")
        end
    end
end

function BBF.MoveRegion(frame, point, relativeTo, relativePoint, xOffset, yOffset)
    frame:ClearAllPoints()
    frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset, "BBFHookSetPoint")

    if (not frame.BBFHookSetPoint) then
        hooksecurefunc(frame, "SetPoint", OnSetPointHookScript(point, relativeTo, relativePoint, xOffset, yOffset))
        frame.BBFHookSetPoint = true
    end
end

local OnShowHookScript = function()
    return function(frame)
        frame:Hide()
    end
end


local OnSetWidthHookScript = function()
    return function(frame)
        frame:SetWidth(value)
    end
end

function BBF.HideRegion(frame)
    frame:Hide()

    if not frame.BBFHookHide then
        hooksecurefunc(frame, "Show", OnShowHookScript())
        frame.BBFHookHide = true
    end
end

local OnSetWidthHookScript = function(width)
    return function(frame, width, flag)
        if flag ~= "BBFHookSetWidth" then
            frame:SetWidth(width, "BBFHookSetWidth")
        end
    end
end

function BBF.SetRegionWidth(frame, width)
    frame:SetWidth(width, "BBFHookSetWidth")

    if (not frame.BBFHookSetWidth) then
        hooksecurefunc(frame, "SetWidth", OnSetWidthHookScript(width))
        frame.BBFHookSetWidth = true
    end
end


local OnSetHeightHookScript = function(height)
    return function(frame, height, flag)
        if flag ~= "BBFHookSetHeight" then
            frame:SetWidth(height, "BBFHookSetHeight")
        end
    end
end

function BBF.SetRegionHeight(frame, height)
    frame:SetHeight(height, "BBFHookSetHeight")

    if (not frame.BBFHookSetWidth) then
        hooksecurefunc(frame, "SetHeight", OnSetHeightHookScript(height))
        frame.BBFHookSetHeight = true
    end
end


local OnSetSizeHookScript = function(width, height)
    return function(frame, width, height, flag)
        if flag ~= "BBFHookSetSize" then
            frame:SetSize(width, height, "BBFHookSetSize")
        end
    end
end

function BBF.SetRegionSize(frame, width, height)
    frame:SetSize(width, height, "BBFHookSetSize")

    if (not frame.BBFHookSetSize) then
        hooksecurefunc(frame, "SetSize", OnSetSizeHookScript(width, height))
        frame.BBFHookSetSize = true
    end
end



local npcColorCache = {}
local function GetBBPNameplateColor(unit)
    local guid = UnitGUID(unit)
    if not guid then return end

    local npcID = select(6, strsplit("-", guid))
    local npcName = UnitName(unit)
    local lowerCaseNpcName = npcName and strlower(npcName)

    -- First check cache by npcID
    if npcID and npcColorCache[npcID] ~= nil then
        return npcColorCache[npcID]
    end

    -- Fallback to cache by name
    if lowerCaseNpcName and npcColorCache[lowerCaseNpcName] ~= nil then
        return npcColorCache[lowerCaseNpcName]
    end

    local colorNpcList = BetterBlizzPlatesDB.colorNpcList
    local npcHealthbarColor = nil

    for _, npc in ipairs(colorNpcList) do
        if npc.id == tonumber(npcID) or (npc.name and strlower(npc.name) == lowerCaseNpcName) then
            if npc.entryColors then
                npcHealthbarColor = npc.entryColors.text
            else
                npc.entryColors = {}
            end
            break
        end
    end

    -- Cache both ID and name for future use
    if npcID then
        npcColorCache[npcID] = npcHealthbarColor
    end
    if lowerCaseNpcName then
        npcColorCache[lowerCaseNpcName] = npcHealthbarColor
    end

    return npcHealthbarColor
end

local function getUnitColor(unit, useCustomColors, txt)
    if not UnitExists(unit) then return end
    if UnitIsPlayer(unit) then
        local color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
        if color then
            if skipFriendly then
                local reaction = getUnitReaction(unit)
                return { r = color.r, g = color.g, b = color.b },
                    ((unit == "player" and skipPlayer) or (skipFriendly and reaction == "FRIENDLY" and unit ~= "player"))
            else
                return { r = color.r, g = color.g, b = color.b }, false
            end
        end
    elseif colorPetAfterOwner and UnitIsUnit(unit, "pet") then
        -- Check if the unit is the player's pet and the setting is enabled
        local _, playerClass = UnitClass("player")
        local color = RAID_CLASS_COLORS[playerClass]
        if color then
            return {r = color.r, g = color.g, b = color.b}, false
        end
    else
        if BetterBlizzPlatesDB and BetterBlizzPlatesDB.colorNPC then
            local npcHealthbarColor = GetBBPNameplateColor(unit)
            if npcHealthbarColor then
                return {r = npcHealthbarColor.r, g = npcHealthbarColor.g, b = npcHealthbarColor.b}, false
            else
                local reaction = getUnitReaction(unit)
                if reaction == "HOSTILE" then
                    if UnitIsTapDenied(unit) and not txt then
                        return {r = 0.9, g = 0.9, b = 0.9}, false
                    else
                        return {r = 1, g = 0, b = 0}, false
                    end
                elseif reaction == "NEUTRAL" then
                    if UnitIsTapDenied(unit) and not txt then
                        return {r = 0.9, g = 0.9, b = 0.9}, false
                    else
                        return {r = 1, g = 1, b = 0}, false
                    end
                elseif reaction == "FRIENDLY" then
                    return {r = 0, g = 1, b = 0}, true
                end
            end
        else
            local reaction = getUnitReaction(unit)

            if reaction == "HOSTILE" then
                if UnitIsTapDenied(unit) and not txt then
                    return {r = 0.9, g = 0.9, b = 0.9}, false
                else
                    return {r = 1, g = 0, b = 0}, false
                end
            elseif reaction == "NEUTRAL" then
                if UnitIsTapDenied(unit) and not txt then
                    return {r = 0.9, g = 0.9, b = 0.9}, false
                else
                    return {r = 1, g = 1, b = 0}, false
                end
            elseif reaction == "FRIENDLY" then
                return {r = 0, g = 1, b = 0}, true
            end
        end
    end
end
BBF.getUnitColor = getUnitColor

local function updateFrameColorToggleVer(frame, unit)
    if unit == "player" and skipPlayer then
        frame:SetStatusBarColor(0, 1, 0, 1)
        return
    end
    if classColorsOn then
        local color, isFriendly = getUnitColor(unit)
        if color then
            if isFriendly and (not frame.bbfChangedTexture or skipFriendly) then
                frame:SetStatusBarDesaturated(false)
                frame:SetStatusBarColor(0, 1, 0, 1)
            else
                frame:SetStatusBarDesaturated(true)
                frame:SetStatusBarColor(color.r, color.g, color.b, 1)
            end
        end
    end
end

BBF.updateFrameColorToggleVer = updateFrameColorToggleVer

local function resetFrameColor(frame, unit)
    frame:SetStatusBarDesaturated(false)
    frame:SetStatusBarColor(0, 1, 0, 1)
end

local validUnits = {
    player = true,
    target = true,
    targettarget = true,
    focus = true,
    focustarget = true,
    pet = true,
    party1 = true,
    party2 = true,
    party3 = true,
    party4 = true,
}

local function UpdateHealthColor(frame, unit)
    if not validUnits[unit] then return end
    if unit == "player" and skipPlayer then
        frame:SetStatusBarColor(0, 1, 0, 1)
        return
    end
    local color, isFriendly = getUnitColor(unit)
    if color then
        if isFriendly and skipFriendly then
            frame:SetStatusBarDesaturated(true)
            frame:SetStatusBarColor(0, 1, 0, 1)
        else
            frame:SetStatusBarDesaturated(true)
            frame:SetStatusBarColor(color.r, color.g, color.b, 1)
        end
    end
end

function BBF.UpdateToTColor()
    updateFrameColorToggleVer(TargetFrameToTHealthBar, "targettarget")
end

function BBF.UpdateFrames()
    classColorsOn = BetterBlizzFramesDB.classColorFrames
    colorPetAfterOwner = BetterBlizzFramesDB.colorPetAfterOwner
    skipPlayer = BetterBlizzFramesDB.classColorFramesSkipPlayer
    skipFriendly = BetterBlizzFramesDB.classColorFramesSkipFriendly
    if C_AddOns.IsAddOnLoaded("DragonflightUI") then
        if not BBF.dfuiHbWarning then
            BBF.dfuiHbWarning = true
            BBF.Print(L["Print_DragonflightUI_Class_Color_Conflict"])
        end
    end
    if classColorsOn then
        BBF.HookHealthbarColors()
        if UnitExists("player") then updateFrameColorToggleVer(PlayerFrameHealthBar, "player") end
        if UnitExists("target") then updateFrameColorToggleVer(TargetFrameHealthBar, "target") end
        if UnitExists("focus") then updateFrameColorToggleVer(FocusFrameHealthBar, "focus") end
        if UnitExists("targettarget") then updateFrameColorToggleVer(TargetFrameToTHealthBar, "targettarget") end
        if UnitExists("focustarget") then updateFrameColorToggleVer(FocusFrameToTHealthBar, "focustarget") end
        if UnitExists("party1") then updateFrameColorToggleVer(PartyFrame.MemberFrame1.HealthBar, "party1") end
        if UnitExists("party2") then updateFrameColorToggleVer(PartyFrame.MemberFrame2.HealthBar, "party2") end
        if UnitExists("party3") then updateFrameColorToggleVer(PartyFrame.MemberFrame3.HealthBar, "party3") end
        if UnitExists("party4") then updateFrameColorToggleVer(PartyFrame.MemberFrame4.HealthBar, "party4") end
        BBF.HealthColorOn = true
    else
        if BBF.HealthColorOn then
            if UnitExists("player") then resetFrameColor(PlayerFrameHealthBar, "player") end
            if UnitExists("target") then resetFrameColor(TargetFrameHealthBar, "target") end
            if UnitExists("focus") then resetFrameColor(FocusFrameHealthBar, "focus") end
            if UnitExists("targettarget") then resetFrameColor(TargetFrameToTHealthBar, "targettarget") end
            if UnitExists("focustarget") then resetFrameColor(FocusFrameToTHealthBar, "focustarget") end
            if UnitExists("party1") then resetFrameColor(PartyFrame.MemberFrame1.HealthBar, "party1") end
            if UnitExists("party2") then resetFrameColor(PartyFrame.MemberFrame2.HealthBar, "party2") end
            if UnitExists("party3") then resetFrameColor(PartyFrame.MemberFrame3.HealthBar, "party3") end
            if UnitExists("party4") then resetFrameColor(PartyFrame.MemberFrame4.HealthBar, "party4") end
            BBF.HealthColorOn = nil
        end
    end
    if colorPetAfterOwner then
        if UnitExists("pet") then updateFrameColorToggleVer(PetFrameHealthBar, "pet") end
    end
end

function BBF.UpdateFrameColor(frame, unit)
    local color = getUnitColor(unit)
    if color then
        frame:SetStatusBarDesaturated(true)
        frame:SetStatusBarColor(color.r, color.g, color.b, 1)
    end
end

function BBF.ClassColorReputation(frame, unit)
    local color = getUnitColor(unit)
    if color then
        frame:SetDesaturated(true)
        frame:SetVertexColor(color.r, color.g, color.b)
    end

    if not frame.bbfColorHook then
        hooksecurefunc(frame, "SetVertexColor", function(self)
            if self.changing then return end
            self.changing = true
            local color = getUnitColor(unit)
            if color then
                frame:SetDesaturated(true)
                frame:SetVertexColor(color.r, color.g, color.b)
            end
            self.changing = false
        end)
        frame.bbfColorHook = true
    end
end

function BBF.ClassColorReputationCaller()
    if BetterBlizzFramesDB.classColorTargetReputationTexture then
        BBF.ClassColorReputation(TargetFrameNameBackground, "target")
    end

    if BetterBlizzFramesDB.classColorFocusReputationTexture then
        BBF.ClassColorReputation(FocusFrameNameBackground, "focus")
    end
end

function BBF.ResetClassColorReputation(frame, unit)
    local color = getUnitColor(unit)
    if color then
        frame:SetDesaturated(false)
        frame:SetVertexColor(UnitSelectionColor(unit))
    end
end

function BBF.HookHealthbarColors()
    if not healthbarsHooked and classColorsOn then
        hooksecurefunc("UnitFrameHealthBar_Update", function(self, unit)
            if unit then
                UpdateHealthColor(self, unit)
                UpdateHealthColor(TargetFrameToTHealthBar, "targettarget")
                UpdateHealthColor(FocusFrameToTHealthBar, "focustarget")
            end
        end)


        hooksecurefunc("HealthBar_OnValueChanged", function(self)
            if self.unit then
                UpdateHealthColor(self, self.unit)
                UpdateHealthColor(TargetFrameToTHealthBar, "targettarget")
                UpdateHealthColor(FocusFrameToTHealthBar, "focustarget")
            end
        end)



        healthbarsHooked = true
    end
end

function BBF.PlayerReputationColor()
    if BetterBlizzFramesDB.biggerHealthbars then return end
    BBF.HookAndDo(PlayerFrameBackground, "SetSize", function(frame, width, height, flag)
        frame:SetSize(120, 41, flag)
    end)
    PlayerFrameBackground:SetSize(120, 41)
    if not BBF.reputationFrame then
        -- Create the new frame and texture
        local reputationFrame = CreateFrame("Frame", "PlayerReputationFrame", PlayerFrame)
        reputationFrame:SetFrameStrata("LOW")
        reputationFrame:SetSize(119, 19)
        reputationFrame:SetPoint("TOP", PlayerFrameBackground, "TOP")

        local reputationTexture = reputationFrame:CreateTexture(nil, "ARTWORK")
        reputationTexture:SetAllPoints(reputationFrame)
        reputationFrame.texture = reputationTexture

        BBF.reputationFrame = reputationFrame
        BBF.reputationTexture = reputationTexture
    end

    local reputationFrame = BBF.reputationFrame
    local reputationTexture = BBF.reputationTexture

    if BetterBlizzFramesDB.playerReputationColor and not BetterBlizzFramesDB.biggerHealthbars then
        reputationFrame:Show()
        if BetterBlizzFramesDB.playerReputationClassColor then
            local color = getUnitColor("player")
            if color then
                reputationFrame:SetSize(119, 19)
                if not BetterBlizzFramesDB.changeUnitFrameHealthbarTexture then
                    reputationTexture:SetTexture(137017)
                else
                    local texture = BBF.LSM:Fetch(BBF.LSM.MediaType.STATUSBAR, BetterBlizzFramesDB.unitFrameHealthbarTexture)
                    reputationTexture:SetTexture(texture)
                end
                reputationTexture:SetDesaturated(true)
                reputationTexture:SetVertexColor(color.r, color.g, color.b)
                reputationTexture:SetTexCoord(0, 1, 0, 1)
            end
        else
            if not BetterBlizzFramesDB.changeUnitFrameHealthbarTexture then
                reputationTexture:SetTexture(137017)
            else
                local texture = BBF.LSM:Fetch(BBF.LSM.MediaType.STATUSBAR, BetterBlizzFramesDB.unitFrameHealthbarTexture)
                reputationTexture:SetTexture(texture)
            end
            reputationTexture:SetDesaturated(false)
            local r, g, b = UnitSelectionColor("player")
            reputationTexture:SetVertexColor(r, g, b)
            reputationTexture:SetTexCoord(0, 1, 0, 1)
        end
    else
        reputationFrame:Hide()
    end
end

local biggerHealthbarHooked
local frameTextureHooked
local hideManabarHooked
local maxLvl = BBF.isMoP and 90 or BBF.isTBC and 70 or 85

local bigNoManaTexture = "Interface\\Addons\\BetterBlizzFrames\\media\\NoManas\\UI-TargetingFrame-Big-NoMana"
local bigNoLevelNoManaTexture = "Interface\\Addons\\BetterBlizzFrames\\media\\NoManas\\UI-TargetingFrame-NoLevel-Big-NoMana"
local bigEliteNoManaTexture = "Interface\\Addons\\BetterBlizzFrames\\media\\NoManas\\UI-TargetingFrame-Elite-Big-NoMana"
local bigRareNoManaTexture = "Interface\\Addons\\BetterBlizzFrames\\media\\NoManas\\UI-TargetingFrame-Rare-Big-NoMana"
local bigRareEliteNoManaTexture = "Interface\\Addons\\BetterBlizzFrames\\media\\NoManas\\UI-TargetingFrame-Rare-Elite-Big-NoMana"
local bigMinusNoManaTexture = "Interface\\Addons\\BetterBlizzFrames\\media\\NoManas\\UI-TargetingFrame-Minus-Big-NoMana"
local bigPlayerStatusNoManaTexture = "Interface\\Addons\\BetterBlizzFrames\\media\\NoManas\\UI-Player-Status-Big-NoMana"

local noManaTexture = "Interface\\Addons\\BetterBlizzFrames\\media\\NoManas\\UI-TargetingFrame-NoMana"
local noLevelNoManaTexture = "Interface\\Addons\\BetterBlizzFrames\\media\\NoManas\\UI-TargetingFrame-NoLevel-NoMana"
local eliteNoManaTexture = "Interface\\Addons\\BetterBlizzFrames\\media\\NoManas\\UI-TargetingFrame-Elite-NoMana"
local rareNoManaTexture = "Interface\\Addons\\BetterBlizzFrames\\media\\NoManas\\UI-TargetingFrame-Rare-NoMana"
local rareEliteNoManaTexture = "Interface\\Addons\\BetterBlizzFrames\\media\\NoManas\\UI-TargetingFrame-Rare-Elite-NoMana"
local minusNoManaTexture = "Interface\\Addons\\BetterBlizzFrames\\media\\NoManas\\UI-TargetingFrame-Minus-NoMana"

local function ShouldHideManabar(frameName)
    if frameName == "PlayerFrame" then return BetterBlizzFramesDB.hidePlayerManabar end
    if frameName == "TargetFrame" then return BetterBlizzFramesDB.hideTargetManabar end
    if frameName == "FocusFrame" then return BetterBlizzFramesDB.hideFocusManabar end
    return false
end

local function HideManabarElements(frameName)
    local manabar = _G[frameName.."ManaBar"]
    if manabar then
        manabar:SetAlpha(0)
        if manabar.TextString then manabar.TextString:SetAlpha(0) end
        if manabar.LeftText then manabar.LeftText:SetAlpha(0) end
        if manabar.RightText then manabar.RightText:SetAlpha(0) end
    end
end

function BBF.BiggerHealthbars(frame, name)
    local texture = _G[frame.."Texture"] or _G[frame.."TextureFrameTexture"]
    local playerGlowTexture = _G["PlayerStatusTexture"]
    local healthbar = _G[frame.."HealthBar"]
    local manabar = _G[frame.."ManaBar"]
    local leftText = _G[frame.."HealthBarTextLeft"] or _G[frame].textureFrame.HealthBarTextLeft
    local leftTextMana = _G[frame].textureFrame and _G[frame].textureFrame.ManaBarTextLeft or (manabar and manabar.LeftText)
    local rightTextMana = _G[frame].textureFrame and _G[frame].textureFrame.ManaBarTextRight or (manabar and manabar.RightText)
    local centerTextMana = (manabar and manabar.TextString)
    local rightText = _G[frame.."HealthBarTextRight"] or _G[frame].textureFrame.HealthBarTextRight
    local centerText = _G[frame.."HealthBarText"] or _G[frame].textureFrame.HealthBarText
    local nameBackground = _G[frame.."NameBackground"]
    local background = _G[frame.."Background"]
    local deadText = _G[frame.."TextureFrameDeadText"]

    local noLevelTexture = "Interface\\Addons\\BetterBlizzFrames\\media\\UI-TargetingFrame-NoLevel"
    local normalTexture = "Interface\\Addons\\BetterBlizzFrames\\media\\UI-TargetingFrame"

    local hideMana = ShouldHideManabar(frame)

    local targetTexture
    if hideMana then
        targetTexture = bigNoManaTexture
    else
        targetTexture = normalTexture
    end
    if BetterBlizzFramesDB.hideLevelText then
        if BetterBlizzFramesDB.hideLevelTextAlways then
            targetTexture = hideMana and bigNoLevelNoManaTexture or noLevelTexture
        elseif frame == "PlayerFrame" and UnitLevel("player") == maxLvl then
            targetTexture = hideMana and bigNoLevelNoManaTexture or noLevelTexture
        end
    end
    -- Texture
    texture:SetTexture(targetTexture)
    local hidePlayerMana = BetterBlizzFramesDB.hidePlayerManabar
    local playerGlowPath = hidePlayerMana and bigPlayerStatusNoManaTexture or "Interface\\Addons\\BetterBlizzFrames\\media\\UI-Player-Status"
    playerGlowTexture:SetTexture(playerGlowPath)
    hooksecurefunc(playerGlowTexture, "SetTexture",
        function(self, texture)
            if texture ~= playerGlowPath then
                self:SetTexture(playerGlowPath)
                playerGlowTexture:SetHeight(69)
            end
        end
    )
    playerGlowTexture:SetHeight(69)

    -- Healthbar
    local point, relativeTo, relativePoint, xOfs, yOfs = healthbar:GetPoint()
    local newYOffset = yOfs + 18
    BBF.MoveRegion(healthbar, point, relativeTo, relativePoint, xOfs, newYOffset)
    healthbar:SetHeight(hideMana and 40 or 27)
    if not BetterBlizzFramesDB.changeUnitFrameHealthbarTexture then
        healthbar:SetStatusBarTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, "Smooth"))
    end

    if hideMana then
        HideManabarElements(frame)
    end

    BBF.SetRegionWidth(manabar, 120)
    --BBF.SetRegionSize(manabar, 120, 12)

    if nameBackground then
        BBF.HideRegion(nameBackground)
        -- nameBackground:Hide()
        -- nameBackground:SetAlpha(0)
    end
    if background then
    -- background:SetHeight(41)
    -- background:SetWidth(120)
        -- BBF.SetRegionHeight(background, 41)
        -- BBF.SetRegionWidth(background, 120)
        BBF.HookAndDo(background, "SetSize", function(frame, width, height, flag)
            frame:SetSize(120, 42, flag)
        end)
        hooksecurefunc(background, "SetPoint", function(self, point, relativeTo, relativePoint, xOffset, yOffset)
            if yOffset and yOffset ~= 47 then return end
            if self.changing then return end
            self.changing = true
            self:SetPoint(point, relativeTo, relativePoint, xOffset, (yOffset or 0) - 12)
            self.changing = false
        end)

        -- BBF.HookAndDo(background, "SetWidth", function(frame, width, height, flag)
        --     frame:SetWidth(119, 42, flag)
        -- end)
        -- if not background.bbfHooked then
        --     hooksecurefunc("PlayerFrame_UpdateArt", function()
        --         background:SetWidth(120)
        --     end)
        --     background.bbfHooked = true
        -- end
        --BBF.SetRegionWidth(background, 120)
        --BBF.SetRegionSize(background, 120, 41)
    end

    if BetterBlizzFramesDB.biggerHealthbarsNameInside then
        if deadText then
            local point, relativeTo, relativePoint, xOfs, yOfs = deadText:GetPoint()
            local newYOffset = yOfs + 4
            BBF.MoveRegion(deadText, point, relativeTo, relativePoint, xOfs, newYOffset)
        end

        -- Name
        local point, relativeTo, relativePoint, xOfs, yOfs = name:GetPoint()
        local newYOffset = yOfs + 1
        BBF.MoveRegion(name, point, relativeTo, relativePoint, xOfs, newYOffset)


        -- Statustext
        if leftTextMana then
            local point, relativeTo, relativePoint, xOfs, yOfs = leftTextMana:GetPoint()
            local newXOffset = xOfs + 1
            local newYOffset = yOfs + 1
            BBF.MoveRegion(leftTextMana, point, relativeTo, relativePoint, newXOffset, newYOffset)
        end
        if rightTextMana then
            local point, relativeTo, relativePoint, xOfs, yOfs = rightTextMana:GetPoint()
            local newYOffset = yOfs + 1
            BBF.MoveRegion(rightTextMana, point, relativeTo, relativePoint, xOfs, newYOffset)
        end
        if centerTextMana then
            local point, relativeTo, relativePoint, xOfs, yOfs = centerTextMana:GetPoint()
            local newYOffset = yOfs + 1
            BBF.MoveRegion(centerTextMana, point, relativeTo, relativePoint, xOfs, newYOffset)
        end
        local point, relativeTo, relativePoint, xOfs, yOfs = leftText:GetPoint()
        local newYOffset = yOfs + 4 - (hideMana and 7 or 0)
        local newXOffset = xOfs + 1
        if not leftTextMana then
            BBF.MoveRegion(leftText, point, relativeTo, relativePoint, xOfs, newYOffset)
        else
            BBF.MoveRegion(leftText, point, relativeTo, relativePoint, newXOffset, newYOffset)
        end

        local point, relativeTo, relativePoint, xOfs, yOfs = rightText:GetPoint()
        local newYOffset = yOfs + 4 - (hideMana and 7 or 0)
        BBF.MoveRegion(rightText, point, relativeTo, relativePoint, xOfs, newYOffset)

        local point, relativeTo, relativePoint, xOfs, yOfs = centerText:GetPoint()
        local newYOffset = yOfs + 4 - (hideMana and 7 or 0)
        BBF.MoveRegion(centerText, point, relativeTo, relativePoint, xOfs, newYOffset)
    else
        if deadText then
            local point, relativeTo, relativePoint, xOfs, yOfs = deadText:GetPoint()
            local newYOffset = yOfs + 10
            BBF.MoveRegion(deadText, point, relativeTo, relativePoint, xOfs, newYOffset)
        end

        -- Name
        local point, relativeTo, relativePoint, xOfs, yOfs = name:GetPoint()
        local newYOffset = yOfs + 17
        BBF.MoveRegion(name, point, relativeTo, relativePoint, xOfs, newYOffset)
        if rightTextMana then
            local point, relativeTo, relativePoint, xOfs, yOfs = rightTextMana:GetPoint()
            local newYOffset = yOfs + 1
            BBF.MoveRegion(rightTextMana, point, relativeTo, relativePoint, xOfs, newYOffset)
        end
        if centerTextMana then
            local point, relativeTo, relativePoint, xOfs, yOfs = centerTextMana:GetPoint()
            local newYOffset = yOfs + 1
            BBF.MoveRegion(centerTextMana, point, relativeTo, relativePoint, xOfs, newYOffset)
        end

        -- Statustext
        if leftTextMana then
            local point, relativeTo, relativePoint, xOfs, yOfs = leftTextMana:GetPoint()
            local newXOffset = xOfs + 1
            local newYOffset = yOfs + 1
            BBF.MoveRegion(leftTextMana, point, relativeTo, relativePoint, newXOffset, newYOffset)
        end
        local point, relativeTo, relativePoint, xOfs, yOfs = leftText:GetPoint()
        local newYOffset = yOfs + 10 - (hideMana and 7 or 0)
        local newXOffset = xOfs + 1
        if not leftTextMana then
            BBF.MoveRegion(leftText, point, relativeTo, relativePoint, xOfs, newYOffset)
        else
            BBF.MoveRegion(leftText, point, relativeTo, relativePoint, newXOffset, newYOffset)
        end

        local point, relativeTo, relativePoint, xOfs, yOfs = rightText:GetPoint()
        local newYOffset = yOfs + 10 - (hideMana and 7 or 0)
        BBF.MoveRegion(rightText, point, relativeTo, relativePoint, xOfs, newYOffset)

        local point, relativeTo, relativePoint, xOfs, yOfs = centerText:GetPoint()
        local newYOffset = yOfs + 10 - (hideMana and 7 or 0)
        BBF.MoveRegion(centerText, point, relativeTo, relativePoint, xOfs, newYOffset)
    end

    if not frameTextureHooked then
        local function BiggerHBCheckClassification(self)
            if not self or not self.unit then return end
            local classification = UnitClassification(self.unit);
        
            if BetterBlizzFramesDB.biggerHealthbars then
                local frameName = self:GetName()
                local hideMana = ShouldHideManabar(frameName)
                if (classification == "minus") then
                    self.borderTexture:SetTexture(hideMana and bigMinusNoManaTexture or "Interface\\Addons\\BetterBlizzFrames\\media\\UI-TargetingFrame-Minus")
                elseif (classification == "worldboss" or classification == "elite") then
                    self.borderTexture:SetTexture(hideMana and bigEliteNoManaTexture or "Interface\\Addons\\BetterBlizzFrames\\media\\UI-TargetingFrame-Elite")
                elseif (classification == "rareelite") then
                    self.borderTexture:SetTexture(hideMana and bigRareEliteNoManaTexture or "Interface\\Addons\\BetterBlizzFrames\\media\\UI-TargetingFrame-Rare-Elite")
                elseif (classification == "rare") then
                    self.borderTexture:SetTexture(hideMana and bigRareNoManaTexture or "Interface\\Addons\\BetterBlizzFrames\\media\\UI-TargetingFrame-Rare")
                else
                    local textureToUse
                    if hideMana then
                        textureToUse = bigNoManaTexture
                    else
                        textureToUse = normalTexture
                    end
                    if BetterBlizzFramesDB.hideLevelText then
                        if BetterBlizzFramesDB.hideLevelTextAlways or UnitLevel(self.unit) == maxLvl then
                            textureToUse = hideMana and bigNoLevelNoManaTexture or noLevelTexture
                        end
                    end
                    self.borderTexture:SetTexture(textureToUse)
                end
            end
        end
        hooksecurefunc(TargetFrame, "CheckClassification", BiggerHBCheckClassification)
        hooksecurefunc(FocusFrame, "CheckClassification", BiggerHBCheckClassification)
        frameTextureHooked = true

        -- Hide LTP Name background
        for i = 1, PlayerFrame:GetNumChildren() do
            local child = select(i, PlayerFrame:GetChildren())
            if child and child:IsObjectType("Frame") and not child:GetName() then
                for j = 1, child:GetNumRegions() do
                    local region = select(j, child:GetRegions())
                    if region and region:IsObjectType("Texture") then
                        local texture = region:GetTexture()
                        if texture == 137017 then
                        region:SetTexture(nil)
                        end
                    end
                end
            end
        end
    end
end

function BBF.HookBiggerHealthbars()
    if C_AddOns.IsAddOnLoaded("DragonflightUI") then
        if not BBF.DFUIUnsupported then
            BBF.Print(L["Print_Bigger_Healthbars_Not_Supported_DragonflightUI"])
            BBF.DFUIUnsupported = true
        end
        return
    end
    if BetterBlizzFramesDB.biggerHealthbars and not biggerHealthbarHooked then
        local playerName = PlayerFrame.bbfName or PlayerName
        local targetName = TargetFrame.bbfName or TargetFrameTextureFrameName
        local focusName = FocusFrame.bbfName or FocusFrameTextureFrameName
        BBF.BiggerHealthbars("PlayerFrame", playerName)
        BBF.BiggerHealthbars("TargetFrame", targetName)
        BBF.BiggerHealthbars("FocusFrame",focusName)

        -- BBF.BiggerHealthbars("PlayerFrame", PlayerName)
        -- BBF.BiggerHealthbars("TargetFrame", TargetFrameTextureFrameName)
        -- BBF.BiggerHealthbars("FocusFrame", FocusFrameTextureFrameName)

        biggerHealthbarHooked = true
    end
end

function BBF.HookHideManabars()
    if BetterBlizzFramesDB.biggerHealthbars then return end

    local frames = {
        { name = "PlayerFrame", setting = "hidePlayerManabar" },
        { name = "TargetFrame", setting = "hideTargetManabar" },
        { name = "FocusFrame", setting = "hideFocusManabar" },
    }

    for _, info in ipairs(frames) do
        if BetterBlizzFramesDB[info.setting] then
            HideManabarElements(info.name)
            local healthbar = _G[info.name.."HealthBar"]
            if healthbar then
                healthbar:SetHeight(22)
                if healthbar.LeftText then
                    local point, relativeTo, relativePoint, xOfs, yOfs = healthbar.LeftText:GetPoint()
                    BBF.MoveRegion(healthbar.LeftText, point, relativeTo, relativePoint, xOfs, yOfs - 6)
                end
                if healthbar.RightText then
                    local point, relativeTo, relativePoint, xOfs, yOfs = healthbar.RightText:GetPoint()
                    BBF.MoveRegion(healthbar.RightText, point, relativeTo, relativePoint, xOfs, yOfs - 6)
                end
                if healthbar.TextString then
                    local point, relativeTo, relativePoint, xOfs, yOfs = healthbar.TextString:GetPoint()
                    BBF.MoveRegion(healthbar.TextString, point, relativeTo, relativePoint, xOfs, yOfs - 6)
                end
            end
            local texture = _G[info.name.."Texture"] or _G[info.name.."TextureFrameTexture"]
            if texture then
                local textureToUse = noManaTexture
                if BetterBlizzFramesDB.hideLevelText then
                    if BetterBlizzFramesDB.hideLevelTextAlways then
                        textureToUse = noLevelNoManaTexture
                    elseif info.name == "PlayerFrame" and UnitLevel("player") == maxLvl then
                        textureToUse = noLevelNoManaTexture
                    end
                end
                texture:SetTexture(textureToUse)
            end
        end
    end

    if not hideManabarHooked then
        local function HideManaCheckClassification(self)
            if not self or not self.unit then return end
            local frameName = self:GetName()
            if not ShouldHideManabar(frameName) then return end
            if BetterBlizzFramesDB.biggerHealthbars then return end
            local classification = UnitClassification(self.unit)
            if classification == "minus" then
                self.borderTexture:SetTexture(minusNoManaTexture)
            elseif classification == "worldboss" or classification == "elite" then
                self.borderTexture:SetTexture(eliteNoManaTexture)
            elseif classification == "rareelite" then
                self.borderTexture:SetTexture(rareEliteNoManaTexture)
            elseif classification == "rare" then
                self.borderTexture:SetTexture(rareNoManaTexture)
            else
                local textureToUse = noManaTexture
                if BetterBlizzFramesDB.hideLevelText then
                    if BetterBlizzFramesDB.hideLevelTextAlways or UnitLevel(self.unit) == maxLvl then
                        textureToUse = noLevelNoManaTexture
                    end
                end
                self.borderTexture:SetTexture(textureToUse)
            end
        end
        hooksecurefunc(TargetFrame, "CheckClassification", HideManaCheckClassification)
        hooksecurefunc(FocusFrame, "CheckClassification", HideManaCheckClassification)
        hideManabarHooked = true
    end
end

--TargetFrame.textureFrame.HealthBarTextRight

--PlayerFrameHealthBar   PlayerFrameHealthBarTextRight
--/run BBF.LargeUnitFrameHealthbars("PlayerFrame", PlayerName)

--PlayerName