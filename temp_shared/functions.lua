function BBF.KeyDoublePress()
    if not BetterBlizzFramesDB.enableKeyDoublePress or BBF.hookedKeyDoublePress then return end

    local barPrefixes = {
        "ActionButton",
        "MultiBarBottomLeftButton",
        "MultiBarBottomRightButton",
        "MultiBarRightButton",
        "MultiBarLeftButton",
        "MultiBar5Button",
        "MultiBar6Button",
    }

    local buttonNames = {}
    for _, prefix in ipairs(barPrefixes) do
        for i = 1, 12 do
            buttonNames[#buttonNames + 1] = prefix .. i
        end
    end

    local bindingMap = {
        ActionButton = "ACTIONBUTTON",
        MultiBarBottomLeftButton = "MULTIACTIONBAR1BUTTON",
        MultiBarBottomRightButton = "MULTIACTIONBAR2BUTTON",
        MultiBarRightButton = "MULTIACTIONBAR3BUTTON",
        MultiBarLeftButton = "MULTIACTIONBAR4BUTTON",
        MultiBar5Button = "MULTIACTIONBAR5BUTTON",
        MultiBar6Button = "MULTIACTIONBAR6BUTTON",
    }

    local function WalmartAHK(buttonName)
        local btn = _G[buttonName]
        if not btn then return end

        local prefix, id = buttonName:match("^(.-)(%d+)$")
        local bindingPrefix = bindingMap[prefix]
        if not bindingPrefix or not id then return end

        local clickButton = bindingPrefix .. id
        local key1, key2 = GetBindingKey(clickButton)

        for _, key in pairs({key1, key2}) do
            if key then
                local wahkName = "WAHK_" .. key .. "_" .. buttonName
                local wahk = _G[wahkName] or CreateFrame("Button", wahkName, nil, "SecureActionButtonTemplate")

                wahk:RegisterForClicks("AnyDown", "AnyUp")
                wahk:SetAttribute("type", "click")
                wahk:SetAttribute("pressAndHoldAction", "1")
                wahk:SetAttribute("typerelease", "click")
                wahk:SetAttribute("clickbutton", btn)

                SetOverrideBindingClick(wahk, true, key, wahkName)

                wahk:SetScript("OnMouseDown", function()
                    btn:SetButtonState("PUSHED")
                end)
                wahk:SetScript("OnMouseUp", function()
                    btn:SetButtonState("NORMAL")
                end)
            end
        end
    end

    for _, name in ipairs(buttonNames) do
        WalmartAHK(name)
    end

    BBF.hookedKeyDoublePress = true
end

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