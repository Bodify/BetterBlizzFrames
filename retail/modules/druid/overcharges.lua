function BBF.DruidBlueComboPoints()
    if not BetterBlizzFramesDB.druidOverstacks then return end
    if BBF.druidBlueCombos then return end
    if select(2, UnitClass("player")) ~= "DRUID" then return end
    local druid = _G.DruidComboPointBarFrame

    local function CreateChargedPoints(comboPointFrame)
        if not comboPointFrame then return end
        if comboPointFrame.blueOverchargePoints then return end

        local comboPoints = {}
        local visibleComboPoints = 0

        -- Loop through the combo point children and gather visible ones
        for i = 1, comboPointFrame:GetNumChildren() do
            local child = select(i, comboPointFrame:GetChildren())

            -- Only consider shown combo points
            if child:IsShown() then
                visibleComboPoints = visibleComboPoints + 1
                table.insert(comboPoints, child)
            end
        end

        -- Sort the combo points by their layoutIndex
        table.sort(comboPoints, function(a, b)
            return (a.layoutIndex or 0) < (b.layoutIndex or 0)
        end)

        -- Apply textures to the first three combo points
        for i = 1, 3 do
            if comboPoints[i] then
                local comboPoint = comboPoints[i]
                comboPointFrame["ComboPoint"..i] = comboPoint

                -- Create the overlayActive texture and reference it as ChargedFrameActive
                local overlayActive = comboPoint:CreateTexture(nil, "OVERLAY")
                overlayActive:SetAtlas("UF-RogueCP-BG-Anima")
                overlayActive:SetSize(20, 20)
                overlayActive:SetPoint("CENTER", comboPoint, "CENTER")
                comboPoint.ChargedFrameActive = overlayActive

                -- Initially hide the active overlay
                overlayActive:Hide()
            end
        end

        -- Mark as overcharge points if all points are visible
        if visibleComboPoints == 5 then
            comboPointFrame.blueOverchargePoints = true
        end
    end

    CreateChargedPoints(druid)

    -- Function to handle updating combo points based on aura
    local function UpdateComboPoints(self)
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(405189)

        if not aura then
            if self.overcharged then
                for i = 1, 3 do
                    local comboPoint = self["ComboPoint"..i]
                    if comboPoint then
                        -- Revert to default combo point and hide the overlay
                        comboPoint.Point_Icon:SetAtlas("UF-DruidCP-Icon")  -- Default Druid combo point
                        comboPoint.Point_Deplete:SetDesaturated(false)
                        comboPoint.Point_Deplete:SetVertexColor(1, 1, 1)
                        comboPoint.Smoke:SetDesaturated(false)
                        comboPoint.Smoke:SetVertexColor(1, 1, 1)
                        comboPoint.FB_Slash:SetDesaturated(false)
                        comboPoint.FB_Slash:SetVertexColor(1, 1, 1)

                        if comboPoint.ChargedFrameActive then
                            comboPoint.ChargedFrameActive:Hide()  -- Hide active overlay
                        end
                    end
                end
                self.overcharged = nil
            end
            return
        end

        for i = 1, 3 do
            local comboPoint = self["ComboPoint"..i]

            if comboPoint then
                if i <= aura.applications then  -- Show blue combo point and active overlay for stacks <= i
                    self.overcharged = true
                    comboPoint.Point_Icon:SetAtlas("UF-RogueCP-Icon-Blue") -- Blue combo point
                    comboPoint.Point_Deplete:SetDesaturated(true)
                    comboPoint.Point_Deplete:SetVertexColor(0, 0, 1)
                    comboPoint.Smoke:SetDesaturated(true)
                    comboPoint.Smoke:SetVertexColor(0, 0, 1)
                    comboPoint.FB_Slash:SetDesaturated(true)
                    comboPoint.FB_Slash:SetVertexColor(0, 0, 1)
                    comboPoint.ChargedFrameActive:Show()  -- Show active overlay
                else  -- Revert to default combo point and hide the overlay for stacks > i
                    comboPoint.Point_Icon:SetAtlas("UF-DruidCP-Icon")  -- Default Druid combo point
                    comboPoint.Point_Deplete:SetDesaturated(false)
                    comboPoint.Point_Deplete:SetVertexColor(1, 1, 1)
                    comboPoint.Smoke:SetDesaturated(false)
                    comboPoint.Smoke:SetVertexColor(1, 1, 1)
                    comboPoint.FB_Slash:SetDesaturated(false)
                    comboPoint.FB_Slash:SetVertexColor(1, 1, 1)
                    comboPoint.ChargedFrameActive:Hide()  -- Hide active overlay
                end
            end
        end
    end

    -- Create a frame to listen to form changes
    local currentForm = GetShapeshiftFormID()
    if currentForm ~= 1 then
        local formWatch = CreateFrame("Frame")
        local function OnFormChanged()
            CreateChargedPoints(druid)
            if druid.blueOverchargePoints then
                formWatch:UnregisterAllEvents()
            end
        end
        formWatch:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
        formWatch:SetScript("OnEvent", OnFormChanged)
    end

    druid.auraWatch = CreateFrame("Frame")
    druid.auraWatch:SetScript("OnEvent", function()
        UpdateComboPoints(druid)
    end)
    druid.auraWatch:RegisterUnitEvent("UNIT_AURA", "player")
    BBF.druidBlueCombos = true
end

function BBF.DruidAlwaysShowCombos()
    if not BetterBlizzFramesDB.druidAlwaysShowCombos then return end
    if select(2, UnitClass("player")) ~= "DRUID" then return end
    if BBF.DruidAlwaysShowCombos then return end
    local frame = DruidComboPointBarFrame

    local function UpdateDruidComboPoints(self)
        local form = GetShapeshiftFormID()
        if form == 1 then return end

        local comboPoints = UnitPower("player", self.powerType)

        if comboPoints > 0 then
            self:Show()
        else
            self:Hide()
        end

        for i, point in ipairs(self.classResourceButtonTable) do
            local isFull = i <= comboPoints

            point.Point_Icon:SetAlpha(isFull and 1 or 0)
            point.BG_Active:SetAlpha(isFull and 1 or 0)
            point.BG_Inactive:SetAlpha(isFull and 0 or 1)
            point.Point_Deplete:SetAlpha(0)
        end
    end

    frame:HookScript("OnHide", function(self)
        if UnitPower("player", self.powerType) > 0 then
            self:Show()
        end
    end)

    local listener = CreateFrame("Frame")
    listener:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    listener:SetScript("OnEvent", function(_, _, _, powerType)
        if powerType == "COMBO_POINTS" then
            UpdateDruidComboPoints(frame)
        end
    end)
    BBF.DruidAlwaysShowCombos = true
end