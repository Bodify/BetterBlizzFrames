-- Locale system for BetterBlizzFrames

BBF.L = BBF.L or {}
BBF.L_native = {}
BBF.locale = GetLocale()

setmetatable(BBF.L, {
	__index = function(t, key)
		return key
	end
})

function BBF.ApplyLocale()
	if not BBF.L_native then return end
	if BetterBlizzFramesDB and BetterBlizzFramesDB.forceEnglishGUI then
		BBF.locale = "enUS"
	else
		for key, value in pairs(BBF.L_native) do
			BBF.L[key] = value
		end
	end
	BBF.L_native = nil
end
