if not BBF.isMidnight then return end
local interruptSpells = {
    1766,   -- Kick (Rogue)
    2139,   -- Counterspell (Mage)
    6552,   -- Pummel (Warrior)
    19647,  -- Spell Lock (Warlock)
    47528,  -- Mind Freeze (Death Knight)
    57994,  -- Wind Shear (Shaman)
    96231,  -- Rebuke (Paladin)
    106839, -- Skull Bash (Feral)
    115781, -- Optical Blast (Warlock)
    116705, -- Spear Hand Strike (Monk)
    132409, -- Spell Lock (Warlock)
    119910, -- Spell Lock (Warlock Pet)
    89766,  -- Axe Toss (Warlock Pet)
    171138, -- Shadow Lock (Warlock)
    147362, -- Countershot (Hunter)
    183752, -- Disrupt (Demon Hunter)
    187707, -- Muzzle (Hunter)
    212619, -- Call Felhunter (Warlock)
    351338, -- Quell (Evoker)
}

-- Function to find and return the interrupt spell the player knows
local function GetInterruptSpell()
    for _, spellID in ipairs(interruptSpells) do
        if IsSpellKnownOrOverridesKnown(spellID) or (UnitExists("pet") and IsSpellKnownOrOverridesKnown(spellID, true)) then
            return spellID
        end
    end
    return nil
end

local playerKick = GetInterruptSpell()

-- Recheck interrupt spells when lock resummons/sacrifices pet
local petSummonSpells = {
    [30146]  = true, -- Summon Demonic Tyrant (Demonology)
    [691]    = true, -- Summon Felhunter (for Spell Lock)
    [108503] = true, -- Grimoire of Sacrifice
}

-- Function to update the interrupt icon
local function UpdateInterruptIcon(frame)
    if not frame then return end

    if not playerKick then
        playerKick = GetInterruptSpell()
    end

    if playerKick then
        -- Update icon
        frame:Show()
        frame.icon:SetTexture(C_Spell.GetSpellTexture(playerKick))

        -- Update cooldown
        local cooldownInfo = C_Spell.GetSpellCooldown(playerKick)
        if cooldownInfo then
            frame.cooldown:SetCooldown(cooldownInfo.startTime, cooldownInfo.duration)

            -- Update border color based on cooldown
            if frame.border then
                local isOnCooldown = frame.cooldown:IsShown()
                if isOnCooldown then
                    frame.border:SetVertexColor(1, 0, 0)
                else
                    frame.border:SetVertexColor(0, 1, 0)
                end
            end

            -- Update castbar color if recolor is enabled
            if BetterBlizzFramesDB.castBarRecolorInterrupt then
                local isOnCooldown = frame.cooldown:IsShown()
                if isOnCooldown then
                    frame:GetParent():SetStatusBarColor(1, 0, 0)
                else
                    frame:GetParent():SetStatusBarColor(1, 1, 1)
                end
            end
        end
    else
        frame:Hide()
    end
end

local function OnPetEvent(self, event, unit, _, spellID)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        if not petSummonSpells[spellID] then return end
    end
    C_Timer.After(0.1, function()
        playerKick = GetInterruptSpell()
        if TargetFrameSpellBar.interruptIconFrame then
            UpdateInterruptIcon(TargetFrameSpellBar.interruptIconFrame)
        end
        if FocusFrameSpellBar.interruptIconFrame then
            UpdateInterruptIcon(FocusFrameSpellBar.interruptIconFrame)
        end
    end)
end

-- Event frames (only created when needed)
local interruptSpellUpdate
local cooldownFrame

-- Helper function to check if any feature is enabled
local function IsAnyFeatureEnabled()
    return BetterBlizzFramesDB.castBarRecolorInterrupt or 
           BetterBlizzFramesDB.castBarInterruptIconTarget or 
           BetterBlizzFramesDB.castBarInterruptIconFocus
end

-- Initialize event frames if they don't exist and features are enabled
local function InitializeEventFrames()
    if not IsAnyFeatureEnabled() then
        if interruptSpellUpdate then
            interruptSpellUpdate:UnregisterAllEvents()
        end
        if cooldownFrame then
            cooldownFrame:UnregisterAllEvents()
        end
        return
    end

    -- Create and register interrupt spell update frame
    if not interruptSpellUpdate then
        interruptSpellUpdate = CreateFrame("Frame")
        if select(2, UnitClass("player")) == "WARLOCK" then
            interruptSpellUpdate:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
        end
        interruptSpellUpdate:RegisterEvent("TRAIT_CONFIG_UPDATED")
        interruptSpellUpdate:RegisterEvent("PLAYER_TALENT_UPDATE")
        interruptSpellUpdate:SetScript("OnEvent", OnPetEvent)
    end

    -- Create and register cooldown update frame
    if not cooldownFrame then
        cooldownFrame = CreateFrame("Frame")
        cooldownFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        cooldownFrame:SetScript("OnEvent", function(self, event, spellID)
            if spellID ~= playerKick then return end

            if TargetFrameSpellBar.interruptIconFrame then
                UpdateInterruptIcon(TargetFrameSpellBar.interruptIconFrame)
            end
            if FocusFrameSpellBar.interruptIconFrame then
                UpdateInterruptIcon(FocusFrameSpellBar.interruptIconFrame)
            end
        end)
    end
end

-- Function to create an interrupt icon frame
local function CreateInterruptIconFrame(parentFrame)
    local button = CreateFrame("Frame", nil, parentFrame)
    button:SetSize(30, 30)
    button:SetPoint("CENTER", parentFrame, BetterBlizzFramesDB.castBarInterruptIconAnchor, 
                    BetterBlizzFramesDB.castBarInterruptIconXPos + 45, 
                    BetterBlizzFramesDB.castBarInterruptIconYPos - 7)
    button:SetScale(BetterBlizzFramesDB.castBarInterruptIconScale)

    -- Create icon texture
    button.icon = button:CreateTexture(nil, "BACKGROUND")
    button.icon:SetAllPoints()
    button.icon:SetTexCoord(0.04, 0.96, 0.04, 0.96)

    -- Create border
    if BetterBlizzFramesDB.interruptIconBorder then
        button.border = button:CreateTexture(nil, "OVERLAY")
        button.border:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-ActionBar-IconFrame-AddRow-Light")
        button.border:SetSize(48, 48)
        button.border:SetPoint("CENTER", button, "CENTER", 2, -2)
        button.border:SetDrawLayer("OVERLAY", 7)
        button.border:SetVertexColor(0, 1, 0)
    end

    -- Create cooldown frame
    button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    button.cooldown:SetAllPoints()
    button.cooldown:HookScript("OnCooldownDone", function()
        if BetterBlizzFramesDB.castBarRecolorInterrupt then
            parentFrame:SetStatusBarColor(1, 1, 1)
        end
        if button.border then
            button.border:SetVertexColor(0, 1, 0)
        end
    end)

    return button
end

-- Function to initialize the interrupt icon frames
function BBF.ToggleCastbarInterruptIcon()
    -- Destroy existing frames if they exist
    if TargetFrameSpellBar.interruptIconFrame then
        TargetFrameSpellBar.interruptIconFrame:Hide()
        TargetFrameSpellBar.interruptIconFrame = nil
    end
    if FocusFrameSpellBar.interruptIconFrame then
        FocusFrameSpellBar.interruptIconFrame:Hide()
        FocusFrameSpellBar.interruptIconFrame = nil
    end

    -- Initialize or clean up event frames based on settings
    InitializeEventFrames()

    -- If no features are enabled, exit early
    if not IsAnyFeatureEnabled() then
        return
    end

    -- Always create target frame icon if any feature is enabled
    TargetFrameSpellBar.interruptIconFrame = CreateInterruptIconFrame(TargetFrameSpellBar)
    if BetterBlizzFramesDB.castBarInterruptIconTarget then
        TargetFrameSpellBar.interruptIconFrame:Show()
        UpdateInterruptIcon(TargetFrameSpellBar.interruptIconFrame)
    else
        TargetFrameSpellBar.interruptIconFrame:Hide()
    end

    -- Always create focus frame icon if any feature is enabled
    FocusFrameSpellBar.interruptIconFrame = CreateInterruptIconFrame(FocusFrameSpellBar)
    if BetterBlizzFramesDB.castBarInterruptIconFocus then
        FocusFrameSpellBar.interruptIconFrame:Show()
        UpdateInterruptIcon(FocusFrameSpellBar.interruptIconFrame)
    else
        FocusFrameSpellBar.interruptIconFrame:Hide()
    end
end

-- Function to update settings
local function UpdateSettings()
    -- If no features are enabled, hide everything
    if not IsAnyFeatureEnabled() then
        if TargetFrameSpellBar.interruptIconFrame then
            TargetFrameSpellBar.interruptIconFrame:Hide()
        end
        if FocusFrameSpellBar.interruptIconFrame then
            FocusFrameSpellBar.interruptIconFrame:Hide()
        end
        return
    end

    -- Update target frame icon
    if TargetFrameSpellBar.interruptIconFrame then
        local frame = TargetFrameSpellBar.interruptIconFrame
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", TargetFrameSpellBar, BetterBlizzFramesDB.castBarInterruptIconAnchor, 
                       BetterBlizzFramesDB.castBarInterruptIconXPos + 45, 
                       BetterBlizzFramesDB.castBarInterruptIconYPos - 7)
        frame:SetScale(BetterBlizzFramesDB.castBarInterruptIconScale)
        
        if BetterBlizzFramesDB.castBarInterruptIconTarget then
            frame:Show()
        else
            frame:Hide()
        end
    end

    -- Update focus frame icon
    if FocusFrameSpellBar.interruptIconFrame then
        local frame = FocusFrameSpellBar.interruptIconFrame
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", FocusFrameSpellBar, BetterBlizzFramesDB.castBarInterruptIconAnchor, 
                       BetterBlizzFramesDB.castBarInterruptIconXPos + 45, 
                       BetterBlizzFramesDB.castBarInterruptIconYPos - 7)
        frame:SetScale(BetterBlizzFramesDB.castBarInterruptIconScale)
        
        if BetterBlizzFramesDB.castBarInterruptIconFocus then
            frame:Show()
        else
            frame:Hide()
        end
    end
end

-- Function to call when user changes settings
function BBF.UpdateInterruptIconSettings()
    UpdateSettings()
    if BetterBlizzFramesDB.castBarInterruptIconTarget and TargetFrameSpellBar.interruptIconFrame then
        UpdateInterruptIcon(TargetFrameSpellBar.interruptIconFrame)
    end
    if BetterBlizzFramesDB.castBarInterruptIconFocus and FocusFrameSpellBar.interruptIconFrame then
        UpdateInterruptIcon(FocusFrameSpellBar.interruptIconFrame)
    end
end