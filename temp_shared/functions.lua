-- Taint/combat lockdown concerns, use own to avoid Show call especially
local FrameFadeManager = CreateFrame("Frame");
local fadeFrames = {};

function BBF.UIFrameFadeContains(frame)
	for i, fadeFrame in ipairs(fadeFrames) do
		if fadeFrame == frame then
			return true;
		end
	end
	return false;
end

function BBF.UIFrameFade_OnUpdate(self, elapsed)
	local index = 1;

	while fadeFrames[index] do
		local frame = fadeFrames[index];
		local fadeInfo = frame and frame.BBF_fadeInfo;

		if not frame or not fadeInfo then
			if frame then
				frame.BBF_fadeInfo = nil;
			end
			tDeleteItem(fadeFrames, frame);
		else
			fadeInfo.fadeTimer = (fadeInfo.fadeTimer or 0) + elapsed;

			if fadeInfo.fadeTimer < fadeInfo.timeToFade then
				if fadeInfo.mode == "IN" then
					frame:SetAlpha((fadeInfo.fadeTimer / fadeInfo.timeToFade) * (fadeInfo.endAlpha - fadeInfo.startAlpha) + fadeInfo.startAlpha);
				else -- "OUT"
					frame:SetAlpha(((fadeInfo.timeToFade - fadeInfo.fadeTimer) / fadeInfo.timeToFade) * (fadeInfo.startAlpha - fadeInfo.endAlpha) + fadeInfo.endAlpha);
				end
			else
				frame:SetAlpha(fadeInfo.endAlpha);

				if fadeInfo.fadeHoldTime and fadeInfo.fadeHoldTime > 0 then
					fadeInfo.fadeHoldTime = fadeInfo.fadeHoldTime - elapsed;
				else
					tDeleteItem(fadeFrames, frame);

					local finishedFunc = fadeInfo.finishedFunc;
					if finishedFunc then
						fadeInfo.finishedFunc = nil;
						finishedFunc(fadeInfo.finishedArg1, fadeInfo.finishedArg2, fadeInfo.finishedArg3, fadeInfo.finishedArg4);
					end

					frame.BBF_fadeInfo = nil;
				end
			end

			index = index + 1;
		end
	end

	if #fadeFrames == 0 then
		self:SetScript("OnUpdate", nil);
	end
end

function BBF.UIFrameFade(frame, fadeInfo)
	if not frame then
		return;
	end

	fadeInfo = fadeInfo or {};

	if not fadeInfo.mode then
		fadeInfo.mode = "IN";
	end

	if fadeInfo.mode == "IN" then
		if fadeInfo.startAlpha == nil then fadeInfo.startAlpha = 0 end
		if fadeInfo.endAlpha == nil then fadeInfo.endAlpha = 1 end
	elseif fadeInfo.mode == "OUT" then
		if fadeInfo.startAlpha == nil then fadeInfo.startAlpha = 1 end
		if fadeInfo.endAlpha == nil then fadeInfo.endAlpha = 0 end
	end

	frame.BBF_fadeInfo = fadeInfo;

	frame:SetAlpha(fadeInfo.startAlpha);
	--frame:Show();

	if not BBF.UIFrameFadeContains(frame) then
		tinsert(fadeFrames, frame);
	end

	FrameFadeManager:SetScript("OnUpdate", BBF.UIFrameFade_OnUpdate);
end

function BBF.UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
	BBF.UIFrameFade(frame, {
		mode = "IN",
		timeToFade = timeToFade,
		startAlpha = startAlpha,
		endAlpha = endAlpha,
	});
end

function BBF.UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	BBF.UIFrameFade(frame, {
		mode = "OUT",
		timeToFade = timeToFade,
		startAlpha = startAlpha,
		endAlpha = endAlpha,
	});
end

function BBF.UIFrameFadeRemoveFrame(frame)
	tDeleteItem(fadeFrames, frame);
	if frame then
		frame.BBF_fadeInfo = nil;
	end
end

function BBF.UIFrameIsFading(frame)
	return frame and BBF.UIFrameFadeContains(frame) or false;
end

function BBF.ActionBarCDNumberSize(reset)
	if not BetterBlizzFramesDB.actionBarCDNumberSizeChange then
		if BBF.actionBarCDNumberSizeActive then
			reset = true
			BBF.actionBarCDNumberSizeActive = nil
		else
			return
		end
	end

	local cdTextSize = reset and 1 or (BetterBlizzFramesDB.actionBarCDNumberScale or 1)

	local function SetCooldownFontScale(button, size)
		if button then
			local cd = button.Cooldown or button.cooldown
			if cd then
				local r1 = cd:GetRegions()
				if r1 and r1.GetObjectType and r1:GetObjectType() == "FontString" then
					r1:SetScale(size)
				end
			end
		end
	end

	local function ApplyToAll(size)
		if C_AddOns.IsAddOnLoaded("Bartender4") then
			for i = 1, 180 do
				SetCooldownFontScale(_G["BT4Button" .. i], size)
			end
			for i = 1, 10 do
				SetCooldownFontScale(_G["BT4PetButton" .. i], size)
			end
		else
			for i = 1, 12 do
				SetCooldownFontScale(_G["ActionButton" .. i], size)
				SetCooldownFontScale(_G["MultiBarBottomLeftButton" .. i], size)
				SetCooldownFontScale(_G["MultiBarBottomRightButton" .. i], size)
				SetCooldownFontScale(_G["MultiBarRightButton" .. i], size)
				SetCooldownFontScale(_G["MultiBarLeftButton" .. i], size)
				SetCooldownFontScale(_G["MultiBar5Button" .. i], size)
				SetCooldownFontScale(_G["MultiBar6Button" .. i], size)
				SetCooldownFontScale(_G["MultiBar7Button" .. i], size)
				SetCooldownFontScale(_G["PetActionButton" .. i], size)
				SetCooldownFontScale(_G["StanceButton" .. i], size)
			end
		end
	end

	if C_AddOns.IsAddOnLoaded("Bartender4") and not BBF.actionBarCDNumberSizeActive then
		ApplyToAll(cdTextSize)
	else
		ApplyToAll(cdTextSize)
	end

	BBF.actionBarCDNumberSizeActive = BetterBlizzFramesDB.actionBarCDNumberSizeChange or nil
end

local LSM = LibStub("LibSharedMedia-3.0")
local FontValidatorString = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormal")

local function IsFontFileValid(path)
	if type(path) ~= "string" or path == "" then
		return false
	end

	local ok = pcall(FontValidatorString.SetFont, FontValidatorString, path, 12, "")
	if not ok then
		return false
	end

	return path
end

BBF.LSM = setmetatable({}, {
	__index = function(_, k)
		if k == "Register" then
			return function(_, mediaType, key, data, langMask)
				if mediaType == "font" and not IsFontFileValid(data) then
					return false
				end
				return LSM:Register(mediaType, key, data, langMask)
			end
		end

		return LSM[k]
	end
})

BBF.allLocales = LSM.LOCALE_BIT_western+LSM.LOCALE_BIT_ruRU+LSM.LOCALE_BIT_zhCN+LSM.LOCALE_BIT_zhTW+LSM.LOCALE_BIT_koKR

function BBF.AddFont(name)
	if type(name) ~= "string" then
		C_Timer.After(4, function()
			BBF.Print(L["Print_AddFont_Name_Not_String"])
		end)
		return
	end
	if name:sub(-4):lower() == ".ttf" then
		name = name:sub(1, -5)
	end
	BBF.LSM:Register("font", name, "Interface\\AddOns\\CustomMedia\\" .. name .. ".ttf", BBF.allLocales)
end

function BBF.AddTexture(name)
	if type(name) ~= "string" then
		C_Timer.After(4, function()
			BBF.Print(L["Print_AddTexture_Name_Not_String"])
		end)
		return
	end
	BBF.LSM:Register("statusbar", name, "Interface\\AddOns\\CustomMedia\\" .. name)
end