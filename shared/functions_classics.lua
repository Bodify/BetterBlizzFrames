-- Blizzard has messed up position of the FocusFrame center healthbar text. Fix it for them.
if BBF.isTBC then
    hooksecurefunc(FocusFrame, "SetSmallSize", function(self)
        local a,b,c,d,e = FocusFrame.textureFrame.HealthBarText:GetPoint()
        FocusFrame.textureFrame.HealthBarText:SetPoint(a,b,c,-33,-1)
    end)
end

local allowedPortraits = {
    ["PlayerFrame"] = true,
    ["PetFrame"] = true,
    ["TargetFrame"] = true,
    ["TargetFrameToT"] = true,
    ["FocusFrame"] = true,
    ["FocusFrameToT"] = true,
    ["PartyMemberFrame1"] = true,
    ["PartyMemberFrame2"] = true,
    ["PartyMemberFrame3"] = true,
    ["PartyMemberFrame4"] = true,
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
        if BBF.isTBC and not parentName then
            local parent = portrait:GetParent()
            if parent == PartyFrame.MemberFrame1 or
               parent == PartyFrame.MemberFrame2 or
               parent == PartyFrame.MemberFrame3 or
               parent == PartyFrame.MemberFrame4 then
            else
                return
            end
        elseif not allowedPortraits[parentName] then 
            return
        end
        if UnitIsPlayer(unit) then
            if BetterBlizzFramesDB.classPortraitsIgnoreSelf and portrait:GetParent():GetName() == "PlayerFrame" then return end

            if BetterBlizzFramesDB.classPortraitsUseSpecIcons and Details then
                local unitGUID = UnitGUID(unit)
                local specID = nil

                if unitGUID then
                    specID = Details:GetSpecByGUID(unitGUID)
                end

                if specID then
                    local _, _, _, icon = GetSpecializationInfoByID(specID)
                    if icon then
                        portrait:SetTexture(icon)
                        portrait:SetTexCoord(0, 1, 0, 1)

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
            local class = UnitClassBase(unit)
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

local eraShamanColor
if BBF.isEra then
    eraShamanColor = CreateColor(0, 0.44, 0.87)
    eraShamanColor.colorStr = eraShamanColor:GenerateHexColor()
end

function BBF.GetClassColor(class)
    if eraShamanColor and class == "SHAMAN" and BetterBlizzFramesDB.colorShamansBlue then
        return eraShamanColor
    end
    return RAID_CLASS_COLORS[class]
end
