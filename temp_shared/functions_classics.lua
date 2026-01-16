local ignoredPortraits = {
    ["CharacterMicroButton"] = true,
    ["PetStableFrame"] = true,
}

function BBF.ClassPortraits()
	TargetFrameToT.portrait:SetSize(38, 38)
	TargetFrameToT.portrait:ClearAllPoints()
	TargetFrameToT.portrait:SetPoint("TOPLEFT", TargetFrameToT, "TOPLEFT", 3, -4)

	if FocusFrameToT then
		FocusFrameToT.portrait:SetSize(38, 38)
		FocusFrameToT.portrait:ClearAllPoints()
		FocusFrameToT.portrait:SetPoint("TOPLEFT", FocusFrameToT, "TOPLEFT", 3, -4)
	end

    hooksecurefunc("SetPortraitTexture", function(portrait, unit)
        local parentName = portrait:GetParent():GetName()
        if ignoredPortraits[parentName] then return end
        if UnitIsPlayer(unit) then
            if BetterBlizzFramesDB.classPortraitsIgnoreSelf and portrait:GetParent():GetName() == "PlayerFrame" then return end

            -- Check if spec icons are enabled
            if BetterBlizzFramesDB.classPortraitsUseSpecIcons and Details then
                local unitGUID = UnitGUID(unit)
                local specID = nil

                -- Try to get spec from Details addon
                if unitGUID then
                    specID = Details:GetSpecByGUID(unitGUID)
                end

                -- If we have a specID, try to get spec icon
                if specID then
                    local _, _, _, icon = GetSpecializationInfoByID(specID)
                    if icon then
                        portrait:SetTexture(icon)
                        portrait:SetTexCoord(0, 1, 0, 1)

                        -- Apply circular mask to spec icons
                        if not portrait.circleMask then
                            portrait.circleMask = portrait:GetParent():CreateMaskTexture()
                            portrait.circleMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                            portrait.circleMask:SetAllPoints(portrait)
                            portrait:AddMaskTexture(portrait.circleMask)
                        end
                        return
                    end
                end
            end

            -- Fallback to class icons
            local _, class = UnitClass(unit)
            local texture = "Interface\\TargetingFrame\\UI-Classes-Circles"
            local coords = CLASS_ICON_TCOORDS[class]

            if coords then
                portrait:SetTexture(texture)
                portrait:SetTexCoord(unpack(coords))
            end
        else
            portrait:SetTexCoord(0, 1, 0, 1)
        end
    end)
end