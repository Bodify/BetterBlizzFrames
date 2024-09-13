BetterBlizzFrames = nil
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")
--local anchorPoints = {"CENTER", "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}
local anchorPoints = {"CENTER", "TOP", "LEFT", "RIGHT", "BOTTOM"}
local anchorPoints2 = {"TOP", "LEFT", "RIGHT", "BOTTOM"}
local pixelsBetweenBoxes = 6
local pixelsOnFirstBox = -1
local sliderUnderBoxX = 12
local sliderUnderBoxY = -10
local sliderUnderBox = "12, -10"
local titleText = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: \n\n"

local LibDeflate = LibStub("LibDeflate")
local LibSerialize = LibStub("LibSerialize")

BBF.squareGreenGlow = "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\newplayertutorial-drag-slotgreen.tga"

local function ConvertOldWhitelist(oldWhitelist)
    local optimizedWhitelist = {}
    for _, aura in ipairs(oldWhitelist) do
        local key = aura["id"] or string.lower(aura["name"])
        local flags = aura["flags"] or {}
        local entryColors = aura["entryColors"] or {}
        local textColors = entryColors["text"] or {}

        optimizedWhitelist[key] = {
            name = aura["name"] or nil,
            id = aura["id"] or nil,
            important = flags["important"] or nil,
            pandemic = flags["pandemic"] or nil,
            enlarged = flags["enlarged"] or nil,
            compacted = flags["compacted"] or nil,
            color = {textColors["r"] or 0, textColors["g"] or 1, textColors["b"] or 0, textColors["a"] or 1}
        }
    end
    return optimizedWhitelist
end

local function ConvertOldBlacklist(oldBlacklist)
    local optimizedBlacklist = {}
    for _, aura in ipairs(oldBlacklist) do
        local key = aura["id"] or string.lower(aura["name"])

        optimizedBlacklist[key] = {
            name = aura["name"] or nil,
            id = aura["id"] or nil,
            showMine = aura["showMine"] or nil,
        }
    end
    return optimizedBlacklist
end

local function ExportProfile(profileTable, dataType)
    -- Include a dataType in the table being serialized
    BetterBlizzFramesDB.exportVersion = BBF.VersionNumber
    local exportTable = {
        dataType = dataType,
        data = profileTable
    }
    local serialized = LibSerialize:Serialize(exportTable)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForPrint(compressed)
    return "!BBF" .. encoded .. "!BBF"
end

function BBF.ImportProfile(encodedString, expectedDataType)
    if encodedString:sub(1, 4) == "!BBF" and encodedString:sub(-4) == "!BBF" then
        encodedString = encodedString:sub(5, -5) -- Remove both prefix and suffix
    else
        return nil, "Invalid format: Prefix or suffix not found."
    end

    local compressed = LibDeflate:DecodeForPrint(encodedString)
    local serialized, decompressMsg = LibDeflate:DecompressDeflate(compressed)
    if not serialized then
        return nil, "Error decompressing: " .. tostring(decompressMsg)
    end

    local success, importTable = LibSerialize:Deserialize(serialized)
    if not success or importTable.dataType ~= expectedDataType then
        return nil, "Error deserializing or data type mismatch"
    end

    -- Check if the imported data matches the new optimized format
    local function IsNewFormat(auraList)
        for key, aura in pairs(auraList) do
            if type(aura) ~= "table" then
                return false
            end
            if aura["id"] ~= nil or aura["flags"] ~= nil then
                return true
            end
            return false
        end
        return true
    end

    -- Convert if the data is in the old format
    if expectedDataType == "auraBlacklist" and not IsNewFormat(importTable.data) then
        importTable.data = ConvertOldBlacklist(importTable.data)
    elseif expectedDataType == "auraWhitelist" and not IsNewFormat(importTable.data) then
        importTable.data = ConvertOldWhitelist(importTable.data)
    end

    return importTable.data, nil
end


local function deepMergeTables(destination, source)
    for k, v in pairs(source) do
        if type(v) == "table" then
            if not destination[k] then
                destination[k] = {}
            end
            deepMergeTables(destination[k], v) -- Recursive merge for nested tables
        else
            destination[k] = v
        end
    end
end

StaticPopupDialogs["BBF_CONFIRM_RELOAD"] = {
    text = titleText.."This requires a reload. Reload now?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        BetterBlizzFramesDB.reopenOptions = true
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["BBF_TOT_MESSAGE"] = {
    text = titleText.."The default Blizzard code to \"wrap auras\" around the target of target frame is stupid.\n\nThe \"Target of Target\" frames have been moved 31 pixels to the right to make more space for auras.\nYou can change this at any time.\n\nDo you want to keep this? (pick yes)",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end,
    OnCancel = function()
        BetterBlizzFramesDB.targetToTXPos = 0
        BBF.targetToTXPos:SetValue(0)
        BetterBlizzFramesDB.focusToTXPos = 0
        BBF.focusToTXPos:SetValue(0)
        BBF.MoveToTFrames()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["BBF_CONFIRM_NAHJ_PROFILE"] = {
    text = titleText.."This action will modify all settings to Nahj's profile and reload the UI.\n\nAre you sure you want to continue?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        BBF.NahjProfile()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["BBF_CONFIRM_PVP_WHITELIST"] = {
    text = titleText.."This will import a color coded PvP whitelist tailored by me.\nIt will only add auras you don't already have in your whitelist.\n\nAre you sure you want to continue?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        local importString = "!BBFfM1BSXrXvCoF2xoGkKjjagWkzln0qutfTr1rOayN78)r2Pw(mofKQKNBV5UBK3BNRZU7zzteqS4dujhfuGpKqBPguebK4djbjtneBkO0ecvbUMwjci5eseTuvObKrq5dTK(EZEZE7fV3MpGiEN3BM38E)E)EV3Cr(HjZqSjp5STe7EV0OjnjfOhDO8elQwQ8SS2ttnniIC0mJDhSmOi7JvOixytmThByDUbx8arIgjA8NqpB5gkER9BQteMeBg3CBAJiOunEwTbyzPLBe3aqSYnnw5ypq0(64V3wBB)AUMRPVoUu7Tpg8pIUpDEHIeDBAM8T00XokSFlpKGvGlYWigA7KuQYMGl6TlFCZnRbkhjA545JFKhD0YnSV(1PAjn46Jx5mpYJ6kT0o39CGifBEicZulLtXIcQLfySveD3ZvFZRLg31xd6(2DXkXmbVJnLMPIbbROoIOrBjYb6g9fn)GMuZmmZCAdtT4gsRVoBnOmUnGIWTOReO2RjPbAzG2GdShWrMHxWDdWZWvHUsGx6Vy)O8RoLJOeRe4O630YMzQBBD1opqtq)wIC(FpCTotxSSzDGO(GKCm9k3lyPq8hr)nFFqXxyNeHwsIPjvurl47vD4Te5P2l6XxFniJeLaiNaVAjSYtkqmvHwq6vgABjYctJNuclDWJsm19KEHPxP0XFYzLU)DqTZtfw2CrbTEmi5uEViQR)tolE9JM(nG9U83tz8PFdFHYME5MX96g7UavqmYO1jVqbhtp8cUE9Dq4U3WNVpy3pAk0kgNsl65KGfc4Igl53iT9eM2SFSmsazHudJkkblx1ZIBFt7(BLGLo5ywc4DPzapQfXXWwzH7(BdmxPLOT)XYJAK8q2cLyzRTtMDEM6Mbl7QxFD8V)FFhQgSbN6ah4nV8LVS7r)rZ2t9HxqEs3eHDEKeHAKrAjF0Sq4Dwem0AnGHoZZTOMiyOBdhFiHzdWbfTJTdBqYKgoEOTo2Eiy0gU1d1ZvE5rRR4nldjBwtALBwJyMrRhMGkdn36HIx(FI25nom3fLMIOlyzzkGhSCy5fPxOwe1c(qunE(ZTvjLX5phEa9rHZhpbaRcbaJmQ0MON9q4MSA1MC2dfG3OPLgdZl6IZlakBMXsf0xASGK(dVtxWvAEbMRZhOMlK2JNWVlsUnF4D6MHSyT3Nf9t2DKIONAT9kOa6taSpLywS0mdM9KQi5rkgI3k2LEFWQUyIsuZCiD3ofe78k8(LE)6aENAvGsVqsdsgQmdxzBtTQ6OG2fK39Ha(EkqGGU8bbpwDV7GcY83)2oa9E7u5jz4tO1vfUNGvbKfvj2xIxOI3Yaa)n4qQxQ8x((1Mk34l)qGJm9i55ctvCe(w99CXFOwbfMojrmU14Q8w4JHHm3YHrQ(hgY26HR7yPncLO8CB5W(iTBAUbabV4Wut6eyqbC0t5v9DUbc7iU(wq8Wn5V81vK9GYeY16N8hClIpP2OuMYvaFni2GMFA8WwZWKCuvsukd)0SGebrZEY3qwjhGS5b6hS)gvy5K(P)BCR71pYh(t)i)JDcCX7qHYp2jcXT00Ydlt7H)pAWDXSkAq0PfOM2i7Rourr56F6TG2wcHob7YWPQTbReKp4(7fGBh1TAh0LKq1ucSqTiSiN(ML9(0fJQLEsxN1eCp5HLR)fyFmti72GxKkdoQ)OS)AQY8SR)2WZy1pOHnRaqieqS)28HZISRxdVSdtmmMeblDk8in21RfgkRTHcaLbn94q82bqMq2Hil9IyH5Uifkczd9r8OqGfcbCE8Nd0sKe6RGku9xE8NlGWsd)LrLvMDR)H23OabhTgcK61hiORScBMnIM4qa8GobfA)vbQHf85dJUU(HtAFqhV8mgow21NsBD9l5NIfd95ylraDKSmGc8hlwqLnSEyPNcsR0sIS8k2zyHGU4FWrKx8ewfP6EL26MKZqbbajcMKo2MoOSQBLoShsWTHTWN9TPdgsOzT)o4CfDxIuPF(q9XG0Yt8uyR6LVf1bCQUVIuM9I54t3VGBMMOc44xddBEXvvt5YlUk)KgV4xiZUTSH(jDNWsTPV4xeYLBszFEn3PbNmUeSlliD1BXFYVvwf7Y)zSpbxoIjigQlc8D)aPlgVwdpEvdp(F9DWkhdc9jsfB0sRtIQsgSIV7x02knA1zK6HuI7Xe3wjFNvtV9QX6Qq5yDEotMVGmSsnXG4BuwkAi(eYUlGzuQoU2ghiicXnnp2qXdAMNBmPVUHRtsXMMhpKFPSlMMtvesjG51YA4h4bR630p3eOBQDL9EUjcYiAVpKvgAMbAQgyL9C5WcvDxsgZlED161VoFE9bkb7Yzsc94ihbUARrWkbNd1G(7IDg1hWRt9n2t0i91XVT1w3U)2v0Fxje)qposP3faV1gcM(wbhp0JhcgVHet6vhaACZlZoXK(Cun8PC0uGzMsd0s(tkxrNtFk31vCT16kUwFiRyR6PqmC3PHUwhKLlVYqHVhG)p2BLf9)dsmOL4g0WABdefo8N5WirW97UPpZHd25gDgoAG3LYaNHhsk7xrqz7Ts86Ri(Uln9sNcZMgb6TsRxOKvggXd()sNke)Et7zgqXL)5PTyOoAP0HlOxx)7zMqun2()zUKRKkT)6oXHPQ8pSUpIVyF(R4pua)zvZ)t6a3OB2FT3RKQ(t6imcYwxg3GwQP4nM4nb6jmZP8UTUC93e7XL9nq1hh3et4)C1YE8aadnXWwQe9AWku0YRBk2w8NuFbzKDa1IxG7FX)1pvAWP4ogPDeWiRDrlWnHo67Kj09QRbI5lghPdKjS4ACjU2jKpUnnOxDbZRmoiriEPip)jrlABkHF(tg0n7eJjdQ7WXWGLv2cvQ8cUJkOcRx9EeFES7FXWKI2oc1KSZF4WsZ1pnY)Ka2CjQPkFsFD8Up7Z(hbBOVo(Sh5rMfLUkVYPLDVqppA)DOSe65dW(B4doaA)RT2MfgXry7RBHdegwAprHn4OdtMevUp3wsLON9enmN7cpbACRr5Cx4jwPX9j3hkYTvbqFFHLA1(PbrtN0ri4tOYyA)0HLhFp)dKAmHboY8iScx9EcbnK07tEwzDyQnPaxump3IPs)HLcIi84FisB6oQJp(D4713(2WDLv(IGUp0PSd2RMbUH7clJUyo0NLTc2AXCHfc(OhdpKktw7ojFD5ObHXT)2BfjP38vZwa5KS13Y)1TOU6LrhbU(mDL)cwoe27J9RrIwPBdA3jrMsvF2rynF55XEUZ4hNd)zq48LEvuipm9sVAacf5TWM8EHuoPburwNCbwYkV0D8wY26A6RVb0FC711TbcilXFWTI4t3hDvb5p4wxPjSH1Jwzcxr2W6dl69o)kmVdFzFTo56CV23Gfclt59sHw8guoR3l1kncmq)o4mTlpedMpr4(a486pydinQtFDIT9vz0miTcFuGYnI(lyj3JPEVLz0PKXqVkptDMqqgp02qu1n1JGAofJMb6wmh0bKW3GuGiHOFBZ1dktBYFQHgworgyJigyM2Wow5VIBy8f7unGszVbTL5wDkraZ8l8xMg(ZQiZ437CYzggfgXLjGIvDxiTGC1h)e0tcAAlRKAofQSno0GSX)ERSfYyDBzdLAUr02s7ri3yy4PZofMV1dxyxPogmQPIlfwmmU0)ZFcd8YgyL)cbwH1QjiTS)M19DOX59ACR77ciHSPJFb0fS6DqWcMWLp1eW8AvB2afOSV2eMBqCp)rQfNBWqS6gUNLWlSVxh8H5v7J(Ewkea06X2NwUxOmV7pV0iqVxvE9cyTquC(lilfWGITcFtrn)fcZ7oZnGChdJVdOxxfZCdHOrJx36LV)PhTBLQ69WSTP(YIRxLoqFmDExZGa)FqDt631mYxnnhfeB6reouR886pMhiNmFz(7w6ceKCCtbP6tRn)Dhq8pwCnmGMsbsIRTsHI)M7fF9Lby65tZfMkgN3CVHY4eFX9lrw9RttJHrnjW32jJQeZI7pmSt5nJE412T8kScgOWDVy9tWaE9xrcIQm8HMBwELd)1FLWcVF2J5(dy8zpg0b(i55oWSyw2uIHxEWjKpif2wJwkBErLp(e9xnzbmHPXF25rMSi9mehbzN5z2udML9))!BBF"
        local profileData, errorMessage = BBF.ImportProfile(importString, "auraWhitelist")
        if errorMessage then
            print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rFrames: Error importing whitelist:", errorMessage)
            return
        end
        deepMergeTables(BetterBlizzFramesDB.auraWhitelist, profileData)
        BBF.auraWhitelistRefresh()
        Settings.OpenToCategory(BBF.aurasSubCategory)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["BBF_CONFIRM_PVP_BLACKLIST"] = {
    text = titleText.."This will import a large PvP blacklist focused on removing trash buffs, created by me.\nIt will only add auras you don't already have in your blacklist.\n\nAre you sure you want to continue?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        local importString = "!BBF1XxcCYrzzEZ0xZaKqUjDUGcqt2ffq0LfniIZmzUiZKeMzsMfCbTMURPNIP6QARURmzYgxK4cSi76IakckIlEJciymz5qnjeu0fw7FjbnHqascqchbYK7eHKV)phv19K4N6pFGPFR3JN7R33AMzdznlzE7XoC6KpWD(pEU2zjydUM5TwFtflA5MXYOHa)ILwEX(9gSdBxRVqDR8oMjghaLJvyIlWYVONRPJ9sTYA0JLzP(T8tNALZNNkalhBTD65vYyEwLg0ZFGYj(cPJFMpo)RaIzyS9y67B75B41NrtobUw0qsnC9YemC9yiJBr2l2mJDPHOX0SVxXsYyAqhtdN4yA3ox)8ysSI1ZJbWYXwEpwoognBLL)6hTl5RF0UWwSPLKXQyXQN75OZ9CoP13ZpJShxPodReZqHX3vjFZsw5SZy0MBFbfT9C5nWF65LnWF65PZAdalyz5AaSKrtdzvKgsYh8Uf8(dE3yiNztow5TClz6y0y)MEfNTrtM(L6Nh47DZYaFVBUCS92P5sbsRzFZC0W5zQ2ecwdqAxph8H2U5mAnai4mMcMn(mMTG8NXSbgPHahNIwdPNNfQNNfwow5rJ)uDl)uO)cayOn65xWZ30Hh6nMrg6nMbl0KBlNTV5SkA0OFGLJX8iKFEtFl5WDp6H7E(BE4QGXFL2LP8vANwS(Tn6XCXY(69BAM8V8(nvo2d0PvXGcfCSTad4Dk8H3j2UjXEXs3tw0EQBB3Sy3IDvZEdcQUjw1I2M8eUlDP2v7eHRh7Iz9YtKwIQ0JPdDeR7jVd(O)KGjF7ZXkVNliSnA7NXr2tV(8KP41Nhw8tJP0Z8ycLEMhdZ6u7WeSc4C2MBjFMBWyoM5ly5A5ZFFpfLZupfjHOMCZywOyGdyGYAmhRIGSneM7fORXccxJuN(Ti)Pt)watBZb(mh5)uGLRCU0pyx0hmf(p9SxT8NE2RMy)6WlNVjKHbwPJqrKuFJ(KH8n6JLgTHmIIlMJ5GYe)NxKmK)8IWY2a2FEdgjJv3kVlHmCxmzi2b)d8ybe0Xf5zNTpp)88S8h(CYS8h(C0zU(cEa)muHseI1Z9lgyjmcjp8TlCmh(2XWMup(MfkaSYclaujPGzXGLMh3gVxzCB8EbjQzFlRLsm79a6ojmux5Vgtal)1kh7X62olifedvrbn(1u0i(XcNB9oe7Krp(2flLlW0plD(B0lFbtxq3k2VDb(JErD7)Iy7VxOfih(MUTCzfd8a20)SmGn9ptiYUkaTn9z7Bz0vbOtKzBQD0IEraXC0TfKl71XYyr2fnZjsNTTkr6STvvoMFx9h0xFkd3T7jmm3UhM8PaDM9A6M1Odim55Jns7wl2YbN)0j389jOLnFFe6Rtlhmehs5wBahBx0gJNMWyVIOzeqqtbbOOvgOatvBvBIU4LdqiZ1Gx(EbAXgA2t(mFFz6FMVpn9vKNBctUJDV(2bcXoLymbqsvul97f4yxS)rOBm5o(oYCTJVdPBOzBYmsPHMTrdoMzgWybEdMvKwsUMFOmW18djmlRZyW(TCka(46Tf15RvL(xlj9poIpXYh)C3bLSCuKBYDOOMDqOMjwz9AAX2fZyrQVfgR)BLX6)gN9g9CYsAPCfHLT(5LLzRF(YXUdI7UFlOLv2b9juO12hFIjrDw)Zc630X0DjPt90QG2ttdyYnvSKfqEzf97WMqt5bVaJ8ITpHnbqqB6gAvnAalJY4NAT50JAoW4Vi7LAZN0Umx8Iz(WKVNIwFpGwFmsdVvjiXQcHpVUjEEEx2v)MLkzrmqQXEEm3VVmM73hJzcn445L9c6YZCamSw89cCfm(pPGmQFsbAM6WeSyZb8xUWiyiQm1npKmMBEiWo3gWiLevWXU0troHx6Pq7rAfateyczMVtvuAbirUBhNBl6Wtyi4TblNm9we5KP3s5yRVjqgTmwGLRRPqMIp9FV(Z)Em9mcEqWaRQjVK)lztDj)xSEOSMqh0IHyAjpxRIqNKQK4Uhug2DpiTl62oVfPNcSv5cruXpVFNSmN3Vd7IgWNdZAq)PsOI)XAu(5pwJGq1Txjl2kd0Oj2ZJTXxuqcB8fj7qWC9a59GHIMHsJbbguSu8nuu43aOW13IJLzEcv0P5qYUmZnlCDzUzEo8XVxmaBrJwH8bWwqe(6eSzIRd6C6WYpJnRoai9bvCzBkYQnICVaFY(toBVGIJaLE47qg1HHfX1JbLXUiWz97jUEK6Du(Q3Pp2Ggqt9g47sB12Y5AhQxjX0MgVDbewhAYf6eGjV014MN)ZasNI2G4wFKcwYlH8fW3IL9o1Lh6t6DrEGPwy238djm7B(Hyd1w4md7w5YfYOmM)p57gZ)hXL29qKOYCGQsSbnd53xLsPxfrPNCJ(dvemJGkcF0YxWBqlFshhpBV83wMTx(BZ7txRLaxIiv41xSOzGJ4Z5IRJheGmQiFV(MWlAq5ByqWHBMpRnVQBpVSQBNpZn6abCXdZfeapTkk6IE7FMC8E7FgnOgikhHtj2issZxwWtvxWtL4uRAbxG5SgiGfPs0NYeqKNX3cuQbnoZVa8ORuGRAaR2rNvg0OZcoLwjfBdzmcFMVTBs2Y32nrkSbta5xerBPfRn3IrUDV4tx3rNoH1RAhnx789gi(qEB3SozeN7KoHjRlpydWsMRrPZ1OOTE1Zf89DwdkU0nUFKigmUFenz94jgXnnW)uP(hYaM4hQUT(U0ebauDphRswzc5kt(O)wbl)O)wcb2QPpSubDzzSlqCbyi1n)lI)25FrGT9kdYMlKJi1p7gLtXp7gb)hhPeJ4jUg67EJFo)DVXpVCSg6eQq4VzFQMZ9bnN3rxdLVxBVI2m7Anx(tX)eGqXvxbzjY0C88eD37w1lVBFw3DaytX2llwTsqLK4eYv8DLXCfFx6Oq6u6ZbbZvTUZdFpQO09eQ7TOL1akVuQlqW2PUaYTaOUXpJj5pkPrRUF)k4tZVFfG)yUIIoJomZ0VTg12wwIS4Bzj8g8e8asuu8TUvzmFRBLiNlOFBt2FtYkxe)tYxFLcb51xjmb3LLfRYtycRzDImiGGw0HPRj8cJzcso93s(QP)wqhb8i0DPmojXyUq5mnMlKIBcEk5dvxnbhZ9kiiT)0)QSN(t)RGGCnaLVGahram1HljmwhUef8HDwiQd7u5sNQ(hq(M6FamPlW3opohiASmLc0iFo2Vu2nh7xsclsiKKsv8pz3hIniI7B7cnhqwg3KJwllZI3SPTyRi19PUSEFKlRNzNKbpsmb6WknIzlXvmt5WEfZemKq)PTlWCMr86X)hufI)dqH4ER3NIleltE48MPyW5Uef9asMdApW103O(8qsO6LjvkHcbiwgqHk1prJ4O64Lz0InCalZX9AMreSxKn04iiOd9KY5(qpj2jeNkCeZe26HrbMFp5UuXYDbXYhOzhZI9xWZwK7sU(Nr(T1)m0XGiL9JajwGNDrDdEP)CzdEP)CslChiSaWgApG1SjfvMH68sUrDE24ZefK1UVbvm7gGtlDBHO2KitIT13G)baXA2Op2psuqUHEM9glx(Y3y5eBBbWT4h6mqnZOoXe3miRcJJnGcUbynQt7E7fw4sThvtYEGMKL3Pzw7q7tX)eDk4YprNqMSd4IWaGOwFGpX1x3DYoKda2SDcF4dSfft1(Rfg3A)1qkNft6QGphHWp5fKJ8p5faPRDlZceLRzslHiHgtq7asmaDLH9PimMqYNxAu1oQVepkaJqCw)yzjT(XKTyF1vfoIS0PUxjCnaXSo9WqQR3V0Sn6WJYAeh1vi)tYn(CkD55IM(uRwz5wnMHPmx7mdW7QMHJmSIipsPSe(rYJUo5Zp66kZrmaVyWQv9qIFoxJGvpNRHy)cdX3mY9TuR9UK1BT3frXAersbfHuQl8CZQy5K7454JmGSyj0TyYAfNdSn55cQBtdzLovtRqqmnTc6SppRbnMNDF9b9mZZ7c6Yf)J2UZYOBAda3bub9Tdb9T3t)2mheCo1YsmB(nu9oFJhGmJHi0Dc1AwZZAW)eGKTikikVGsgeI6C4p9D(pLp9D(pzZ3qPqivnmyCvP3p8(Lb(dVF4Rx39dp(b5btOihKOLlvuX0YLY8Cz9c6L)HAhJ4FaGGrTlkMdJkQHRDu3SYXCZHK0Kp6wfY0JUvSqKdezzvKTjQqJVlX7habpC7EqPywyxw9lO5pLSlA(tHt7C9wShuGmxezyGyLTMB7JjyJB7JHDzRMbWDjMZn523GSOBFdeAOn3SWsp0FJWbHs1gn9D14ftDA)rbnCA)rmWz0JecMrxUEdA0cCxd21cCZbSsrwWPUBGp9aG1RjeOGRy2Ug3LOo3swfhBl2oUwMfR4ABYF6Rj7NF6RHFFQvSiAbfiglcgRGwxNWKm8wkt5BrmLNjyfHQp4mSK2i)Gi98PEYVNmWN87rCVl01NZeaFaST0d4(vv97N8PVt6e1nKAlQwWITt2HjcsP9HYCKbNNf5x)bIAsalpIm7X8jZ2Ov8)lRYY)fYQS8FbgyAk9ryASTGwbJbH5nJf6NPKi1h7h8L158ltd9KMZoO50xuC7CibR5CiS5ApaKpe8wyKzj3(lQ0yeAv57N3gJUSSngDzCyB0pOiBXIcdI)5ycxbGuOQqPFParDyC9hItSlJF(W7H(unonHaAZjKLLVc9mss4t5KpJ1B5p4qUcL5YKOgbK4h6Km5rrL0mDcubW79rKHCVpcgcy5n71ZbANGz)atN)2km33MLt8(2moEDzIaA7UFeWz9C6mtN8a6pFGntBWM99YBqMCPLKY1LvXkjnp19QeS7Liyt5Kw9fyxYOD4HnXZ)QtG55F1jeksxZs(KIy3s(KejCUqRsP(PKdRsG4lZmGLM5rXdjaz7As4IDvs9d55(rYV(CWL(92wEIa7wcS55TvK0rehbbKStfQBNWkqwOGPTmnBxYMdGC2sYz7aBbg9ywkd5yvDpSKI7h(uy7eCQgkEcLzqvgomugEhZFj0gmmWX3tLXEVVhl)qMSbD3lJW5KCf7rW5RypK(J2YqUQhkD3ONVFqHssS8Q44JRu9hhu9YYIFkVS8NoLxgtXKGvLmIzZaocKi3XIpPRNhhGKoe4qm5uEUiR2D45wLOZLpwXO1LpwjlYSo3wmxQvDgtJXggu05n7yxWy(bY(i2ROshVcLpqkMHm(MIIGK7FhYXC)7ay46ls5YQrti1oKIa)W)f5B)W)fstuB5CTO1RvWUz0nCrIgtIp3vYJbqYDsobgvfgv6u78hlZXo)XeDQns7kmVa2QwcSLmKgBGZu0DmWzsoFz2h0wdMoXm9dFqzl(WhKKH7kJPVJvjdo1pv8dFd7wg0g2nOMDyMlVjRKUxDlC(BsmIF(Bc8JsEWm6AaBIXeHdCNQtt3jCAA9mZt1ARIVmrjcGvBAgcE96XR9A3VS2RD)0KhMT0kgptDNQZp35QjAgfuvvtFQ1PQFw3kOO28jF6RWMMCh6bBh7MqEnWXp3SNVb0YbFa4HC43ugYHFtwwI8wgEeo0j4S8UFhzu7(DczqtUwvn8AHA4hRzlAlLpsrs8DkBR47K9GIlpeMWc2vY0CQ1TkDRVkkxN2q(RQTEnfoMy7SavuLXVqYreUqCrwptTDvz12jLvucnZ6nic4pdCBnIYEaDFFG3HCTUFZcf9Yk0L1j15dqkwyt)EHmkLulERDmX9daXuprjCwMYgjFX7XL9PL94Y(0G2s8JzRkVvRRjDbAcOSnjNPJRNPJtgoR4EvqF9v15AhkjDhKffevOdHtWMJkZiuyize42LITai46QNsSi45HlOsYhUH)cxzMBGL7Qh8sMgiUJcMc2pDQd(OYxFWhLwIreJhPFseRo6reXQJEeAqDdERI9HTlPvjs8SMLD5kk4YXP8fHAI9OQlGMVh4kdO0X5AkQsITkj3qag5g4UpOOqA3hK4RsxZV7JWdbqs1VlIrTKyIunwxJ7nQUuDJSnz)CW)T8io1i0xn)iX2cGykA3YIPxvfFy8d8PfcZb(0K0ocP3ZRielcejQyVIekhGC0baZAqfCzowzmfzHT8bcp1w(aW3QXrtblYYZXhTiwaiqaW7AGUcZXtSEfp4bKYDDjc14iXFXNTDVD5ST7Tt1icUPeyx5CfBFsvgbKDX2Ym7qvS4eFIlww2jU4qhW71NTPr)ATNXVukQZzqzKySTs1fvTpGybgaXAftosBmgPeOleSTdBbzEwoWgUVUgxPOQaqim1QxjOKvQiq8d)BKF5W)MYCgZleo9q0rmQN4)sQXmGKJnTaVnX5No8fhGgCtUz5Kt3mW3E51ibtO7QeG54D5)0MJl)PnhhhtrPqGVFyk5UpPYwaI1yYKIUEWKXBKgOSz2nCywokF7)mJqauksOLITaJ1xrzW(kL1uZxKodvriESVUqiESVoLepOWUivYjEdSTNw2aB7Pj7(ZVqbFkTTWJS5djp2QvBU95ee6SATN6tWJhqWq0ogOZqgC5cehqFR1kt3BTwcTcuuahhs3Er5Lo5AgTGqwZOj1yEUwqGWvREwn7(1ugQxJsRBG31d)4RCo2Vq0beKZ6HLjFvBFnU)Bko4FJzhSDW5JlqrfLuFGA17d4ufuPMxnTKcuTE0KyVVyI49(IX8fuYOOsJ3PvjI(No1hrm(biPNTzoGwOOBihRzBiS4YHCm6HCmGr4Om7ukjXDacIaLOb4pG61rkrqbqCQ5eZEcUSVt1n8Dc3W3ouaqMUGpUfdd))MuxEUPxjYBS)Qsj(ReLyCuW3L6hhb4uRDyoGsU6Xl7YvpEqkynKgDnOL6f(wfDFasYN2f6hyZUIQn3E1D0E)Dmc3Y3NBiaUWsCURK9LOFaqwzzQ3Aq5F)TgKTsvkil5NmLCqyqHlCw6u3Lwa)7ArYmdkPOTIQ6zGMA2KR5ouemN5VU73VQEbaE6OPhAQkIDQhJYkNhvUObnD4o7P2txqqasjVWMIsHtUKTw)7r1R87JQ3OS6STNxfwEEYXjhihZw39fFIJ9lMSWE(lMmD66PF7Ifup0R2ZKACVzLxLkMWeAW2jNucTQ5vVmLx9Y4eIbUmxJ5NxRj4rEw5hpYZsFpRVNkc0aSzNomLgxQ2rlPOdqS9)Ccx0NvW(78ZcSbNfjU8BPtoSsQhMlbs9dAoGfLR(R0mRvFk6i1lOAQEH1tLPCjSVtUATtRD050flx4ILOfPRtaKeK6Y2TId(MUcx9CedpawEe5)VR(HhRsvC(1sOGasN1odk1pRZT(C5y9uQ9XJkIwasEPioBgUAAG5e)Wh6APH9HUwCa4yrnG7LUAgchuj2dgsSJFzxRmPx21sU5AgYFekcuxNsbg6CfSl2Ibe4KCEDkt(jfJ2as(4tQpYRvOjDnoFFHfWH7mHq6oNjfSmMlfgOH7aI3maYU8anWfHdvouyezJcRBVQxv79peUXRnUKkiaj2q117ztsLqDjjHk7VHvvudpgc1IP3MKfB0ZndIxoA()Ms(CbKQlm5ZaTfyDu8ILsxSuyXUdQvOI(PAEk5tbKczgryHGb72lGJLnDn)hsqcacYbNr9UcYKXtRsONW8SypCQUAEJ8uTkBKNQ1YX2untKh2koQmSvC0i3ZEH0YP6fshj1EK)KkV8NyoXHYlPiyr2zaPuux)KNT8vp5zt(MQOIi3CsU7JQ(8DuXNp3mQem1szJN5igKuOxraEyvAzyYU(4waewmf3XBNWSIf9jRXbp5RNtOyjpMFTzFXPTuRABYuSQTrlsNbUCc)wmfyo18v8CK4zL2Ocqkn)uVVGqfDP4zfh4sCqHiaix4cxPCKGqDbxPuA3HBw3PntSIv39G8UXuL)J9SFtECas5zLsWgjn0I6SuQxsfuFjsqDQnh4MdX0A6Ai0DQH7Cckg2Nax17ld(QEFQixSzmk)Krzhown)qgbdy5y92Wf2m(VPt9k6s8kBM1sbLRssHB1eM6dvP8vvvkFvYHuYwGnLkXOm1K4kLmbciXm0IJN)j29aPIpornz8XHHKURmbosUpAx6yuo5x(dbN8082VX1rEvbwQbmAtLAg(XvK6JZX6KHRqBKHIex5xEMYM4lt8Y)dPtEOjjt1HMerRPschPTCb0(JN0mcxiGKwUQAFI2jJU94bFEkMo1E0mySN)sy2pOe8l5n8Av8(1c8EHPh6r7FRo6tqetqgE8jWcofiHuSR6WmlLkowYy9VQSXx)RY0eoSSHgz0ljkls6acviWsyjkZtv(9KUsYXbeAcAZfi3k53l57lHCdi(4W2pQhlZcQQ)F7kf3I)TRKY1GzX(H4h1LdNt6eN6WY6EQdtzicHkMlqllR7xsLF)sKQVwC9YdFmYzwT3IXNKYequKjvVrJboLGSH4sCJEGVb46mFGsrqCv7TllhXpgBw9bcO8)vqFX(FzNDCmdWHk0iIpCrIZe)M7GgfaL5K6rfLVDBRGswv4hptDRCMSnqVmdqLGPJkcGPtD)VNSu3)7vMBbyUfXCOLXYnNuv2ehx8RcqkPR9lFEfe9gv3Y34OfDAMK6Ay8md2QHTny8R49fS9v8(KdJqhqyqi1gxy7aKM9G85PMdYY1FijCUA2K8Z1SjAd2aL4HtSoyPoYlQ6PPwmAcC98L2C1UeNTznf3PvMY0ecREW87jE(qoIjfuBJRrpkRjYSWdjLvhqQLCI6HXuxNerbGufOPYKAxDPHtfFk6QnfInOzB53P40QVujQgfApioM)SC(gZFMWEvA0TaepvEtPFhs(qxKUjUiGJG5hwZtJdP9PBY3)NOS6)ekdTw9XURwj5tVYou1F7GuA8XjENTTfM3zBBHlpEo2(TYbxor)GVmUYFgN0y0JxpylDXFkkf)UUuxfv0e6XsDphqM475aL5QVKf(Tgq6c6miQ(IXNMIhMgzgH89I6OupdQZk4b82Q1Q3EBSIalwtjWrWSvu)NKsQFnGLP86BxS0)FlkAQzylJDg2usj6JKBYhs0UOXj)2fnogzB6K13Ca4YkL1fZflUqK6jLccbi7RU5GsW6HXVKutiFYVnlCAzxmpLR6mzcYtAcdZg3YVCHMS8lN6Xfl3IvLjPApTTie9tBluKS25m46oj6yQDmVOYrqCZJnQjpxGVxw7Ck)WNq5h(eefDHefD6SHdaiVP8w6qrHJK6DvY)7cY)6zN(zEEf)NC)NRmx7)CPwEZXe66QkDkPs)1eoH0ulzm56l5LNcRfXU3PfG29YrVLovNsGaasS7sck998kXDtPDHcAB5K4S)wIUKZ(BXzqw7N5oXPN3m7s6Rdallf(d(1NtYK3ikeuQvTDz9w12jmW5tyaJzWyaJzaL2xTPPPp(pclOHYcAW2ure7LO(JliRmvZwYZcGeX4cjNgmiwmEdDKZt2qh58if1MU5cOoMRQgeDBsIIauIaN6LPQtQFYdQwOp4KyJuJiVWjFkTX(EQhIMEnTUv6XS622Ye50LvowNDzk12TUh6n5mE(qVjPkTsQoR7C4erdamO1dN5(iBL1TTxI)MT9su246DeP3yMAUPN5QOWBCGXSgmDdBH)yY5hqOMBHuBP5yODNMWCTlL5AxSLE4vbRgusuLKjW9jXZbiM)w8Lo62XsuDTETKaRNYkY4BWxQ0GuoX2T7twKLMswKLMI4kIkSqNw2uhuMPIEI981fM1981b6SjxSxSeZMnyMlDQ9P719H96ALwXPQtY1PPy)6OuSFMqEg7rcXsgDXEMlboHj)N5(laaMrN8GNsAb3BYolUshkTthHrFNouuVIhQwQiEIvVoXnUvVozTSc9zRn3SqaRe5hs6uhs6oeazTvEoLmHMgEjz33ODZzYbRdaipZliFVJ0dQKRs9qAvFk6kkrrcuDbvmKGLaKmdS0aFlGtPl6uymCpRQG)zzf8q0jCF2IJP9I1cJPzUC)j4(xYBqYLzj6(e70vrcUKu6xM(B146QUq5wws6OlqSbvAvGeCJ7K4fi(PgjvhoJ8mL6jKgChqYYlCOQyrWugDvps(0sTzbeQc5g8e8IsKR76dRQx(W0(565PB16Tnz13cDgP7CGJzwIE2AqKsWxqZD3lqCPtGD9Psoj8ljUQK63ibvciL3lYP3EdYzCLs8djF9lww7x)IPtwB(2z1s5p7WM(l5WQVgdFH0w5QdMLd3DnHnelnMApvHjgqC6yV07v706uBrSkaiTcDaptHAAtJUSk1lKyyTaBv0cSvYmA1jpGojZfr57sjCfHREyzJS7dhMvWApntzDpnt6oBGaZGWd)dNHUHodsdWeR0ndGtYUyLQipEvl74jpkgh1Gbf5BtxdE9g2ZMjFtPNIbeAPUgk2eYiFuLM3)ht50(yCVJLRskMU)KYKF)jXKp1WR0NEUKqzUQaljlyjpS6m1HHZupqBu34AwkKz(D)4s86V7hNi0DfytgWiN26csLKhCPtCgpOWtFgpinKUra6fLK6NJkyLQjkrnsatas3BhsjvFbor3BN0jMJWediolumMosVgadjA7QSn6szrnIgv3c6UnOTF63Tw53)U1sfr(KAnYynixAaajUaUrlLCAf1MLXFyhXz8h2PmNRDQb1PDoLINGIWvCjOaazXEJoiZAsNy4h2p9diDghGCLLCknIORs(qltqYp0Y4A0ysL)iYPIK7x9Fz)FcQsUCg1qi3AovIpb9EnmHFpWnTG)kvWk(SFWVIC2pivWIXwFVdXI(ZbQmDdZO3xud04l((S7zu(pdZNxE7ISFRjUn5Urai7tJBoOPV4SO2LGRlljAYCK19hyDBaqlhuFY3IlPLguLrF3ttPgNwKMHtU37JTPZtYkXMiROH7PgmlvIuZNqumaiFOCloiFxvwGV5qQGrQxtsOhGukVcWzUBkL8IrVNquadirTQI5xuGWyLtr6znajDI2vkkFDB7LfvcVmR9Bi)8uSdv13wp20fs1JnDsDDBz94KLF1E5YDbDz6Rt)a3GYmCdspJMzaPF(uRuWOQ2wsxxzAwA23oh4Rh59oy)3lTr2p14KJTvpxpF2T7UPuFGqIxOKNnaXbODkFyu1OKZV6DWtqEhmbiRvYMkpaxtp7GLAk9EqhYoaqYUnFdT4av6DiJUPnCy8kgIDBabPI)5rysSMyYfAaq6KWBu(UrmhR(SclgvQNqLrFIAPbnxi1ZTG0iZF25jnHoG0GMFVuFbA6EcwG)OsrIbK0SjzIDWWu2l34pUiA8GVrP5qaK4RBhKNSMstxbl(gCpHBlNI)pXufGyKgNulOb7Us1RK0nWiWDQb0SteqZExOlDT(ajgrehQ4zoYDUfWY8T4aivjR8vDtvsEe1HKJ8P4lKhI2WXRamGjoK8UQf039O8A4yNNvaxXz6LjLEbqyyko)NwXCL)0kMl1XBMsXCU6Iw(YDMO()ozkR)VRAPJOSYZJPvjdgas8gS6e1VX6999YvjL5AwW2lPBz8uRse4QPqWKQPlpOJRYQhNs((yNpSC3hDXlxKnqLEsixxIgY1LCUL5(9OVaP)xd7vnEE2EnY8S9AWGoZO8nYnkq2Q7cWTixalaz(FUSxzLXvvF)SgPDwbeJAATIzBPCz5yLDK3RdA3xPOSZnLsYONsjsFHPTt0DRl(0eKfGS9f(wm2wgRHaVJIptECPiuaY6m4yEyMfk(jtXoxYvR0TvpxAEaX2YSy)K12O2bk5Bk30BaPix5AqwvRlx7OK46ammBnXkF(cpy5ZVCSEBY1pmW)Tk3epalFcx(jWd6WytTF7oW)JmYd8)avTr3DiT343TOgfqIMi19mYpqlGK8LUHnro5cKciRVTQMal1TkTPdGmZw1Tio5vuKFaxSAw4IjZctgXg6H)hiuTdAeOCxGrZHzq)(0ixUpkYLXhERjQp71huvhiDXFCD6(4SIKtE6QUDcVmXtlaPZjFx(IYRpFVuhsty2hCfcf6dUckKkUGIfSm1RztTjLUhbqU9sCKez0acnv7ZxTM5P4AMpX2CCc4oiyUEKLDJ2rajPRTorZpGKp7Vm)DBriZasfiIA7)gnlsxNeEtDi5jtaqQGddAl3wPMdVUMVNAV89sqXpe4t2bwGDMbmxI(7QZKVxsAb3o)32GC9SaKiAHAz4MkNRUMNQE7LLBziGuxszNdEwy0Ihbe3(UfPnlbSm3v2qbjhSNrhesHAklTk1BuU9(asIRTLVGVhvahUYsWvWCbwv5TvnFkjBiasBVOITnh7IfOBywuhu8z8f3B)m(u4GM0LBuI1pDQX8zKt4y(mK4yRuwNOypMh(yTIqjFh1NU3zzKIgGe4q1JeGuFD(QsxicieGihEjZvrzduFnlItVMfts73lMBLAzLOUnlX9ljzdqMXW3NA7uYuG0hmEAhp(zlk7Opl9adm2irWkOMsSOrPFHK5RSiEOQcKCRQg2Twd3oMzYeiv8j0XI3wUXHasr2IynMvut7N6vvgIxDuuhbsr9kg35T1Lkofci1TjyEjEm(xEy5cdbi5DHyPVKbx2g63JxJeBcGLJ6ZpJUTY0VRn92bWJ5A(pKXCn)hismyFbAuf)M)iscUbekDQV3a3OIXgBWNrCaDWNb7O2980mmCC11PJNI(cwlyO(Ix9m0d4zqsb7LLNtmdrumXma(Shyvi0ejvKO6(18nFaakftzCSlaUl(IvXZ3XvxIoETuAzPLQsPIxNCIaKnPqfe12DewdtUHRsqCB4QOQ14eSekhs6n2lD8FP0DiaIZrZwosqJPtDtZsM4BAwu61ka3oPA1uXNLuhFg6UAg0P8i8FBBJv(BBBSePL6X3Qk(8ZjTsjGu43W2xwFZ(4u1nr(UIbafCkmcJGD4lKsIFLgQ3V6(IkS8XNUUStNw23NpHhtAoyaP03r9xzLA9Ko1S(SYxmRpBfRUNqsY)oAQ6(oNhnKf4XjnfEm644P9SvCBjlTawMtKgDJ05BSDpiaTwn9dr3X27FVieV3)EEU894lskunxPSphQdz)EOoWbEbEUimuRLW)YAgq(L1maXeh1kxvxtPuV95OYwNdDAdVaq1R2FEcLS8eZOmxQgyQtuIZTGgVd3OypdqU2GdmK8GkeXWSlP81ac2Xgc8Dnk5zq9TTGp3NwjG9XLQDHuTfj1WARmfWriP3pNlDQcs7sNkDNjOa5f5TeTkTtdGumU61y1kmBmV9zPNWZQ6R4uL35MnkV0gawM7drh(Qotpsbv67K0PgwXedtyIzW3egZmWvbUc1QRECSGIcKKhxs2kGL50tkOCsCQ(SCox06XnQFGCOg1pGmubmh1X(C7xjmTnjxSoavZb(Lk2l19NSbZ0PwPs)w55qL3WZb8pTeMk1Khsfwp0vr3OjIJzqRW(gm5l9pj)4l9pHzEknLHm5rKwUOYuX8ZwXX8H16ip8eg5PVryTmJnBdEoE(UWfD9f7r9B5gj)woNUYt3aCFohAW7d(j5qxkYfAnNcpTgGWt)3rrwcM4If0oHQgN7rB2g6z9zIvNVSonZpGz)wu)AmrDlorikhBAmYB()wb5n)FlK4NF6KVU8EAaijqmIu)1GtGQdulsX6mi0cJWdDXG6MkqS9lekPp8K01CsrRzQELaRaSS((guu8pj7IP4a0(hy1sLcbSm1zq6fOpaSjvfqrArDmGy7)vKvuJSCykYYZUcHOEepv(EDI66d6TjqzC1QToCAApEE8F7UVaXDV7MU21HLXSv44t64NRCbwaKfYSZe(avm8K15zYvMN7rYtkGL5lDSmrr9xlhuoRK49LONbSAN51(8)tloZdyz(TEiVvw7QUSjDilmGHQTtCQsTAbKWESIn2)LWMAHN2pqnX)b8DcwUPiJS5WtUM(LHSM(PZen31njUr0aGuLWvlK80Xu8A4nK3ChajEJgcCguBOIo5QkWhEvPu8P)HKT90)qeVwL8tuvFQKC3QQNDdvpRTTIdyA6BsQwLNaOHNQqLgg67kmTk06wHxVEd2h57R0e(PtUdPt3aedDYTmeIniJxbeoZCHpH2z5)njHdoFBvuICOB6NyQNdBpJo5mSEkshbaiDeMNhCD3rJpoQsUdRLvE4PrOWlIP2t71fQ90ED561Sy7fZnDrdMI2K3w1L(2S7lHAKJABZ6eECaPOvSxmxOVQ7yUHvR2dtwTJXnswQnCwcYAdNLupt3LAZVysuVvSfjmFajR8VQSitwxKjhfntItvpVNkFEbNywTBrGdXAlXLCxspyaizUJEJT42GOZaPWPXN(mfpGM(mP92fGfiTUqPRe20WQjPHpRWdqDBqUoNB4Mynt67werwQCr52N(v7J)QXqF105MYaa6YIbf7fIUcthqh8bolI7xCG9eE4D(MsnEbeI68BkG(QoSpnhF77SdxieRHu2baX5oSTsPAGLNzwtUv5frcqkz(zSQkJvPoMsVp2mOw6I8ZHUFFw9gv729P6C3NrLfClIlJashG5jTJG8sWe60yncxpGud1l3SL(cly8rvD9hL01pJE63Se32pEuR38rrSGEz5gpb)BxbpzBxZ902hn1AhwLOSgpl(gvZt3RkpPjawM97RYtJYCckYwPs0MuMqaPMZLqpnyPxI5ultBC3LrUno(o5ivPE1I7PulZ(sNSJMLqc7OzS(l0LrosD2XIMtx8CN0IRpAAjVvPmaasMiJI8KEyXQ0NT1nvUX4aGUITCAVPqDdkLo5Rj3fwazdsUU29t3DXrOsTgN7tvEqpPvN7jQ8OfkLs2MIP9wh66nDa7WtRSf0LtykTBLd8yJidguVbjU0h)n1RtYBU4YC1qONzbQdMQQ2WX)ccrk(xG0SKrB9C2)zwQEucxpGrU4F6st8cy0F6y6TA(y3fjskDw9ROzY4voFI4XDMxy1ttUI9khIvSxUfnp5Rsz8jR93f124tTEUfrKlh9faxCGtdscagkDQ)O6y0FKCmAIrzVfFG00zAFg9SYZwcGK2mQErGvSE)8I50A(RlL)zaPuTk9mQ8WcYBNlwcEfWYu7pEYPyQ(Wcaf)cLcQci98Muv77e7isgLaKfOhYO7WNmR6myxTaaCrTW3c1wqONQ72x3gLf)62i1am(dfLv56UA2AlayxbCNJd3MHn6xXPf(zmOOdvVfrVG6s4(OCgdBz9BvY2G0Lznyy34WTpGCxHzm3g0uvUH6llpukEepPtuttNAgYdufGmJo1xsApQ5KnSoMXpDjtEakntcBlPQlRE8P)rv18FuIIhETQKWbNJTzESAQr06K7ddGKPz4HEw7kjRKEmajZAPt9r2JWc9rOBV7KpHBLYadbxvPzl52Lc5diOkxva1XQ0lvaVNgq7H(bGVllNOynLv6nbJPl0lyUS8AyS02Kgoaq26aDxdHc5(CQ6vkAtAl4TP1qxPTGmiWUw9qihfrCcmISw9n4Q2(i320x)ZkxCJ9R5sy)uUeg3cDZ4XDuy1yXuBtBRHTDa2fTCqvd0iqPGA(zL4OQzp6vYCp0vYCcsgdgXfYaHIRVsEZ6ZtwpsYF2uftoasZmT9RIjJBL2epI2CPpYWmHH6fzF5QXjEVgvSJexP6xWvs(fmXUgWYXIsgrhEUdyne1ihS()uZsvonRVaDIBaX7SuRti3a1oQBrvqDlrn24r1ITF06GonQ)Uj8yduVpOoERzCyy20r1T398mdF(FsDivL2HOhQHjiV4w5Olut19SqIvlVboas9zIe0XIGDIOhvYBvsBkGKMXVf)32K(2kUP7KUW1YvpCbGjW1MZYqT1iVtnasOA5s5YSczgc4BEDVqjv7asD2eDPvYhw526wj)aCcaqimTl2BjVYjaseMU9c8PhiyOLPZaCymQNtaccqtFtGw3kXx(KcQsBSOHPwGyC1NX3RxUjyRobofLlZjG8nbi5F5NkO))YpLEgN4BeepU7wVTc3DRL)B9SemIseCxkA7UO30UjX21y3JoXh0T3vCEeqYHfFs6n6nTl5oKusdiT5R8Er2jS2esM)1pHS5)1pbBIKE)aLoJI5xaUqtE86OKhpHkx4KruuPuV5LiJ6nVeIFMYhV6THh13jurM4HfxDdm(zZsNUKVqspye9eCL8HLHK8HP9CLYxw9tNX61()E9RI9sd(N5yf(iALAnkZ9AiM7t4sG1CONVXxZ)UG3wZ)E41Ao5BiD)bG0MtJsyeLSn5gL6hay4v5m11(xLL7A)Re)9Lr8FB7FH5)22)cuO20s63mOyKkWFSSSaI1yAi2Oc2wzKKKq3mz6niTQUI5f1cB)ILXmrL2VRm9BPx)KTkDsbGvKHQ(spSC9o6S8oR0ehvUwAj)vhx(8F1XzFd73db6xvRpUAPWJawME0gPocZOko5hxUu4aQPpNAbevA4A1h5TRLFK3ihA4s0mK)SiolXI(YVBDZrVy0t6KFTrwG8K1MCJ3GIVPlMXuO6E6txVm9kTXZB0ZCXLOVQOxc5r7470JBcajkL(cV0oPoFrZiGenUYlkBL0)N8ruhLEKBLUCb5lmemVW2HLxlI4VN8oqbiToJK)Is4HipO3vV38Y(Bip0Auk9EWBtwRh82WWsh92ACcVY08m(6sozbmYPtdXYnG0HrTomcg2AhT0noaYcC8L4tsyl1PHYeRpM0VE7rLA9DL(2gq6iY7zV(4ROhIxxVPs1M4FuM6e)JSjSaN(c8VG213Zp6jsrM(10Iko2czkvs50r1eADukHwJVY7J6iklWM1hQ3n)9jhwTSCKo(cQU5F(LeLUasI5ZZkGvkrxSNmWzOog4talI6R50OUPOtMP8ufbiL5wpFkv8Gc6QL1m(60x8011yOAHugFrfl)fzfs5Plrr2tOvo(sYtXfGK9Lk5vH96NYapSDkNQRxVuzxpRbmkb6n4t9IU4k(VrE8CbSCvpLivYo)U0N)PDXVNpsATjBh0lkC(W4QM3BltY8EB6IftjeHUmAcpXYvEILhDjqVu9P88sZxMU1zmMUZ(HXwPpatmBLupBIgEpcnuFG5p6CuK7YP3H)UhQG16nbTG9BLA(S)Fd!BBF"
        local profileData, errorMessage = BBF.ImportProfile(importString, "auraBlacklist")
        if errorMessage then
            print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rFrames: Error importing blacklist:", errorMessage)
            return
        end
        deepMergeTables(BetterBlizzFramesDB.auraBlacklist, profileData)
        BBF.auraBlacklistRefresh()
        Settings.OpenToCategory(BBF.aurasSubCategory)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["BBF_CONFIRM_MAGNUSZ_PROFILE"] = {
    text = titleText.."This action will modify all settings to Magnusz's profile and reload the UI.\n\nAre you sure you want to continue?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        BBF.MagnuszProfile()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}
------------------------------------------------------------
-- GUI Creation Functions
------------------------------------------------------------
local function CheckAndToggleCheckboxes(frame, alpha)
    for i = 1, frame:GetNumChildren() do
        local child = select(i, frame:GetChildren())
        if child and (child:GetObjectType() == "CheckButton" or child:GetObjectType() == "Slider" or child:GetObjectType() == "Button") then
            if frame:GetChecked() then
                child:Enable()
                child:SetAlpha(1)
            else
                child:Disable()
                child:SetAlpha(alpha or 0.5)
            end
        end

        -- Check if the child has children and if it's a CheckButton or Slider
        for j = 1, child:GetNumChildren() do
            local childOfChild = select(j, child:GetChildren())
            if childOfChild and (childOfChild:GetObjectType() == "CheckButton" or childOfChild:GetObjectType() == "Slider" or childOfChild:GetObjectType() == "Button") then
                if child.GetChecked and child:GetChecked() and frame.GetChecked and frame:GetChecked() then
                    childOfChild:Enable()
                    childOfChild:SetAlpha(1)
                else
                    childOfChild:Disable()
                    childOfChild:SetAlpha(0.5)
                end
            end
        end
    end
end

local function DisableElement(element)
    element:Disable()
    element:SetAlpha(0.5)
end

local function EnableElement(element)
    element:Enable()
    element:SetAlpha(1)
end

local function CreateBorderBox(anchor)
    local contentFrame = anchor:GetParent()
    local texture = contentFrame:CreateTexture(nil, "BACKGROUND")
    texture:SetAtlas("UI-Frame-Neutral-PortraitWiderDisable")
    texture:SetDesaturated(true)
    texture:SetRotation(math.rad(90))
    texture:SetSize(295, 163)
    texture:SetPoint("CENTER", anchor, "CENTER", 0, -95)
    return texture
end

--[[
-- dark grey with dark bg
border:SetBackdrop({
    bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
    edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
    tile = true,
    tileEdge = true,
    tileSize = 12,
    edgeSize = 12,
    insets = { left = 5, right = 5, top = 9, bottom = 9 },
})

]]

--[[
-- clean dark fancy
border:SetBackdrop({
    bgFile = "Interface\\FriendsFrame\\UI-Toast-Background",
    edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
    tile = true,
    tileEdge = true,
    tileSize = 12,
    edgeSize = 12,
    insets = { left = 5, right = 5, top = 5, bottom = 5 },
})

]]

-- Function to update the icon texture
local function UpdateIconTexture(editBox, textureFrame)
    local iconID = tonumber(editBox:GetText())
    if iconID then
        textureFrame:SetTexture(iconID)
    end
end

local function CreateIconChangeWindow()
    local window = CreateFrame("Frame", "IconChangeWindow", UIParent, "BasicFrameTemplateWithInset")
    window:SetSize(300, 180)  -- Adjust size as needed
    window:SetPoint("CENTER")
    window:SetFrameStrata("HIGH")

    -- Make the frame movable
    window:SetMovable(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)
    window:Hide()

    -- Edit box
    local editBox = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
    editBox:SetSize(150, 20)
    editBox:SetPoint("CENTER", window, "CENTER", 20, 10)

    -- Text above the icon
    local text = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("BOTTOM", editBox, "TOP", -10, 15)
    text:SetText("Enter New Icon ID")

    -- Icon texture frame
    local textureFrame = window:CreateTexture(nil, "ARTWORK")
    textureFrame:SetSize(50, 50)  -- Enlarged icon
    textureFrame:SetPoint("RIGHT", editBox, "LEFT", -10, 0)
    textureFrame:SetTexture(BetterBlizzFramesDB.auraToggleIconTexture)

    -- Text for finding icon IDs
    local findIconText = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    findIconText:SetPoint("CENTER", window, "CENTER", 0, -40)
    findIconText:SetText("Find Icon IDs @ wowhead.com/icons")

    -- OK button
    local okButton = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
    okButton:SetSize(60, 20)
    okButton:SetPoint("BOTTOM", window, "BOTTOM", 30, 10)
    okButton:SetText("OK")
    okButton:SetScript("OnClick", function()
        local newIconID = tonumber(editBox:GetText())
        if newIconID then
            BetterBlizzFramesDB.auraToggleIconTexture = newIconID
            if ToggleHiddenAurasButton then
                ToggleHiddenAurasButton.Icon:SetTexture(newIconID)
            end
        end
        window:Hide()
    end)

    local resetButton = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
    resetButton:SetSize(60, 20)
    resetButton:SetPoint("BOTTOM", window, "BOTTOM", -30, 10)
    resetButton:SetText("Default")
    resetButton:SetScript("OnClick", function()
        BetterBlizzFramesDB.auraToggleIconTexture = 134430
        if ToggleHiddenAurasButton then
            ToggleHiddenAurasButton.Icon:SetTexture(134430)
        end
        textureFrame:SetTexture(134430)
        editBox:SetText(134430)
    end)

    editBox:SetScript("OnTextChanged", function()
        UpdateIconTexture(editBox, textureFrame)
    end)

    editBox:SetScript("OnEnterPressed", function()
        local newIconID = tonumber(editBox:GetText())
        if newIconID then
            BetterBlizzFramesDB.auraToggleIconTexture = newIconID
            if ToggleHiddenAurasButton then
                ToggleHiddenAurasButton.Icon:SetTexture(newIconID)
            end
        end
        window:Hide()
    end)

    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        window:Hide()
    end)

    window.editBox = editBox
    return window
end



local function CreateBorderedFrame(point, width, height, xPos, yPos, parent)
    local border = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    border:SetBackdrop({
        bgFile = "Interface\\FriendsFrame\\UI-Toast-Background",
        edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
        tile = true,
        tileEdge = true,
        tileSize = 10,
        edgeSize = 10,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
    })
    border:SetBackdropColor(1, 1, 1, 0.4)
    border:SetFrameLevel(1)
    border:SetSize(width, height)
    border:SetPoint("CENTER", point, "CENTER", xPos, yPos)

    return border
end

local function CreateSlider(parent, label, minValue, maxValue, stepValue, element, axis, sliderWidth)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetOrientation('HORIZONTAL')
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(stepValue)
    slider:SetObeyStepOnDrag(true)

    slider.Text:SetFontObject(GameFontHighlightSmall)
    slider.Text:SetTextColor(1, 0.81, 0, 1)

    slider.Low:SetText(" ")
    slider.High:SetText(" ")

    if sliderWidth then
        slider:SetWidth(sliderWidth)
    end

    local function UpdateSliderRange(newValue, minValue, maxValue)
        newValue = tonumber(newValue) -- Convert newValue to a number

        if (axis == "X" or axis == "Y") and (newValue < minValue or newValue > maxValue) then
            -- For X or Y axis: extend the range by ±30
            local newMinValue = math.min(newValue - 30, minValue)
            local newMaxValue = math.max(newValue + 30, maxValue)
            slider:SetMinMaxValues(newMinValue, newMaxValue)
        elseif newValue < minValue or newValue > maxValue then
            -- For other sliders: adjust the range, ensuring it never goes below a specified minimum (e.g., 0)
            local nonAxisRangeExtension = 2
            local newMinValue = math.max(newValue - nonAxisRangeExtension, 0.1)  -- Prevent going below 0.1
            local newMaxValue = math.max(newValue + nonAxisRangeExtension, maxValue)
            slider:SetMinMaxValues(newMinValue, newMaxValue)
        end
    end

    local function SetSliderValue()
        if BBF.variablesLoaded then
            local initialValue = tonumber(BetterBlizzFramesDB[element]) -- Convert to number

            if initialValue then
                local currentMin, currentMax = slider:GetMinMaxValues() -- Fetch the latest min and max values

                -- Check if the initial value is outside the current range and update range if necessary
                UpdateSliderRange(initialValue, currentMin, currentMax)

                slider:SetValue(initialValue) -- Set the initial value
                local textValue = initialValue % 1 == 0 and tostring(math.floor(initialValue)) or string.format("%.2f", initialValue)
                slider.Text:SetText(label .. ": " .. textValue)
            end
        else
            C_Timer.After(0.1, SetSliderValue)
        end
    end

    SetSliderValue()

    if parent:GetObjectType() == "CheckButton" and parent:GetChecked() == false then
        slider:Disable()
        slider:SetAlpha(0.5)
    else
        if parent:GetObjectType() == "CheckButton" and parent:IsEnabled() then
            slider:Enable()
            slider:SetAlpha(1)
        elseif parent:GetObjectType() ~= "CheckButton" then
            slider:Enable()
            slider:SetAlpha(1)
        end
    end

    -- Create Input Box on Right Click
    local editBox = CreateFrame("EditBox", nil, slider, "InputBoxTemplate")
    editBox:SetAutoFocus(false)
    editBox:SetWidth(50) -- Set the width of the EditBox
    editBox:SetHeight(20) -- Set the height of the EditBox
    editBox:SetMultiLine(false)
    editBox:SetPoint("CENTER", slider, "CENTER", 0, 0) -- Position it to the right of the slider
    editBox:SetFrameStrata("DIALOG") -- Ensure it appears above other UI elements
    editBox:Hide()
    editBox:SetFontObject(GameFontHighlightSmall)

    -- Function to handle the entered value and update the slider
    local function HandleEditBoxInput()
        local inputValue = tonumber(editBox:GetText())
        if inputValue then
            -- Check if it's a non-axis slider and inputValue is <= 0
            if (axis ~= "X" and axis ~= "Y") and inputValue <= 0 then
                inputValue = 0.1  -- Set to minimum allowed value for non-axis sliders
            end

            local currentMin, currentMax = slider:GetMinMaxValues()
            if inputValue < currentMin or inputValue > currentMax then
                UpdateSliderRange(inputValue, currentMin, currentMax)
            end

            slider:SetValue(inputValue)
            BetterBlizzFramesDB[element] = inputValue
        end
        editBox:Hide()
    end


    editBox:SetScript("OnEnterPressed", HandleEditBoxInput)

    slider:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            editBox:Show()
            editBox:SetFocus()
        end
    end)

    slider:SetScript("OnMouseWheel", function(slider, delta)
        if IsShiftKeyDown() then
            local currentVal = slider:GetValue()
            if delta > 0 then
                slider:SetValue(currentVal + stepValue)
            else
                slider:SetValue(currentVal - stepValue)
            end
        end
    end)

    slider:SetScript("OnValueChanged", function(self, value)
        if not BetterBlizzFramesDB.wasOnLoadingScreen then
            local textValue = value % 1 == 0 and tostring(math.floor(value)) or string.format("%.2f", value)
            self.Text:SetText(label .. ": " .. textValue)
            --if not BBF.checkCombatAndWarn() then
                -- Update the X or Y position based on the axis
                if axis == "X" then
                    BetterBlizzFramesDB[element .. "XPos"] = value
                elseif axis == "Y" then
                    BetterBlizzFramesDB[element .. "YPos"] = value
                elseif axis == "Alpha" then
                    BetterBlizzFramesDB[element .. "Alpha"] = value
                elseif axis == "Height" then
                    BetterBlizzFramesDB[element .. "Height"] = value
                end

                if not axis then
                    BetterBlizzFramesDB[element .. "Scale"] = value
                end

                local xPos = BetterBlizzFramesDB[element .. "XPos"] or 0
                local yPos = BetterBlizzFramesDB[element .. "YPos"] or 0
                local anchorPoint = BetterBlizzFramesDB[element .. "Anchor"] or "CENTER"

                --If no frames are present still adjust values
                if element == "targetToTXPos" then
                    BetterBlizzFramesDB.targetToTXPos = value
                    if not BBF.checkCombatAndWarn() then
                        BBF.MoveToTFrames()
                    end
                elseif element == "targetToTYPos" then
                    BetterBlizzFramesDB.targetToTYPos = value
                    if not BBF.checkCombatAndWarn() then
                        BBF.MoveToTFrames()
                    end
                elseif element == "targetToTScale" then
                    BetterBlizzFramesDB.targetToTScale = value
                    if not BBF.checkCombatAndWarn() then
                        BBF.MoveToTFrames()
                    end
                elseif element == "focusToTScale" then
                    BetterBlizzFramesDB.focusToTScale = value
                    if not BBF.checkCombatAndWarn() then
                        BBF.MoveToTFrames()
                    end
                elseif element == "focusToTXPos" then
                    BetterBlizzFramesDB.focusToTXPos = value
                    if not BBF.checkCombatAndWarn() then
                        BBF.MoveToTFrames()
                    end
                elseif element == "focusToTYPos" then
                    BetterBlizzFramesDB.focusToTYPos = value
                    if not BBF.checkCombatAndWarn() then
                        BBF.MoveToTFrames()
                    end
                elseif element == "darkModeColor" then
                    BetterBlizzFramesDB.darkModeColor = value
                    if not BBF.checkCombatAndWarn() then
                        BBF.DarkmodeFrames()
                    end
                elseif element == "lossOfControlScale" then
                    BetterBlizzFramesDB.lossOfControlScale = value
                    BBF.ToggleLossOfControlTestMode()
                    BBF.ChangeLossOfControlScale()
                elseif element == "targetAndFocusAuraOffsetX" then
                    BetterBlizzFramesDB.targetAndFocusAuraOffsetX = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "targetAndFocusAuraOffsetY" then
                    BetterBlizzFramesDB.targetAndFocusAuraOffsetY = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "targetAndFocusAuraScale" then
                    BetterBlizzFramesDB.targetAndFocusAuraScale = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "targetAndFocusHorizontalGap" then
                    BetterBlizzFramesDB.targetAndFocusHorizontalGap = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "targetAndFocusVerticalGap" then
                    BetterBlizzFramesDB.targetAndFocusVerticalGap = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "targetAndFocusAurasPerRow" then
                    BetterBlizzFramesDB.targetAndFocusAurasPerRow = value
                    BBF.RefreshAllAuraFrames()
                    --
                elseif element == "castBarInterruptHighlighterStartTime" then
                    BetterBlizzFramesDB.castBarInterruptHighlighterStartTime = value
                    BBF.CastbarRecolorWidgets()
                elseif element == "castBarInterruptHighlighterEndTime" then
                    BetterBlizzFramesDB.castBarInterruptHighlighterEndTime = value
                    BBF.CastbarRecolorWidgets()
                elseif element == "combatIndicatorScale" then
                    BetterBlizzFramesDB.combatIndicatorScale = value
                    BBF.CombatIndicatorCaller()
                elseif element == "combatIndicatorXPos" then
                    BetterBlizzFramesDB.combatIndicatorXPos = value
                    BBF.CombatIndicatorCaller()
                elseif element == "combatIndicatorYPos" then
                    BetterBlizzFramesDB.combatIndicatorYPos = value
                    BBF.CombatIndicatorCaller()
                elseif element == "absorbIndicatorScale" then
                    BetterBlizzFramesDB.absorbIndicatorScale = value
                    BBF.AbsorbCaller()
                elseif element == "playerAbsorbXPos" then
                    BetterBlizzFramesDB.playerAbsorbXPos = value
                    BBF.AbsorbCaller()
                elseif element == "playerAbsorbYPos" then
                    BetterBlizzFramesDB.playerAbsorbYPos = value
                    BBF.AbsorbCaller()
                elseif element == "targetAbsorbXPos" then
                    BetterBlizzFramesDB.targetAbsorbXPos = value
                    BBF.AbsorbCaller()
                elseif element == "targetAbsorbYPos" then
                    BetterBlizzFramesDB.targetAbsorbYPos = value
                    BBF.AbsorbCaller()
                elseif element == "partyCastBarScale" then
                    BetterBlizzFramesDB.partyCastBarScale = value
                    BBF.UpdateCastbars()
                elseif element == "partyCastBarXPos" then
                    BetterBlizzFramesDB.partyCastBarXPos = value
                    BBF.UpdateCastbars()
                elseif element == "partyCastBarYPos" then
                    BetterBlizzFramesDB.partyCastBarYPos = value
                    BBF.UpdateCastbars()
                elseif element == "partyCastbarIconXPos" then
                    BetterBlizzFramesDB.partyCastbarIconXPos = value
                    BBF.UpdateCastbars()
                elseif element == "partyCastbarIconYPos" then
                    BetterBlizzFramesDB.partyCastbarIconYPos = value
                    BBF.UpdateCastbars()
                elseif element == "partyCastBarWidth" then
                    BetterBlizzFramesDB.partyCastBarWidth = value
                    BBF.UpdateCastbars()
                elseif element == "partyCastBarHeight" then
                    BetterBlizzFramesDB.partyCastBarHeight = value
                    BBF.UpdateCastbars()
                elseif element == "partyCastBarIconScale" then
                    BetterBlizzFramesDB.partyCastBarIconScale = value
                    BBF.UpdateCastbars()
                elseif element == "targetCastBarScale" then
                    BetterBlizzFramesDB.targetCastBarScale = value
                    BBF.ChangeCastbarSizes()
                elseif element == "targetCastBarXPos" then
                    BetterBlizzFramesDB.targetCastBarXPos = value
                    BBF.CastbarAdjustCaller()
                elseif element == "targetCastBarYPos" then
                    BetterBlizzFramesDB.targetCastBarYPos = value
                    BBF.CastbarAdjustCaller()
                elseif element == "targetCastBarWidth" then
                    BetterBlizzFramesDB.targetCastBarWidth = value
                    BBF.ChangeCastbarSizes()
                elseif element == "targetCastBarHeight" then
                    BetterBlizzFramesDB.targetCastBarHeight = value
                    BBF.ChangeCastbarSizes()
                elseif element == "targetCastBarIconScale" then
                    BetterBlizzFramesDB.targetCastBarIconScale = value
                    BBF.ChangeCastbarSizes()
                elseif element == "targetCastbarIconXPos" then
                    BetterBlizzFramesDB.targetCastbarIconXPos = value
                    BBF.ChangeCastbarSizes()
                elseif element == "targetCastbarIconYPos" then
                    BetterBlizzFramesDB.targetCastbarIconYPos = value
                    BBF.ChangeCastbarSizes()
                elseif element == "focusCastBarScale" then
                    BetterBlizzFramesDB.focusCastBarScale = value
                    BBF.ChangeCastbarSizes()
                elseif element == "focusCastBarXPos" then
                    BetterBlizzFramesDB.focusCastBarXPos = value
                    BBF.CastbarAdjustCaller()
                elseif element == "focusCastBarYPos" then
                    BetterBlizzFramesDB.focusCastBarYPos = value
                    BBF.CastbarAdjustCaller()
                elseif element == "focusCastBarWidth" then
                    BetterBlizzFramesDB.focusCastBarWidth = value
                    BBF.ChangeCastbarSizes()
                elseif element == "focusCastBarHeight" then
                    BetterBlizzFramesDB.focusCastBarHeight = value
                    BBF.ChangeCastbarSizes()
                elseif element == "focusCastBarIconScale" then
                    BetterBlizzFramesDB.focusCastBarIconScale = value
                    BBF.ChangeCastbarSizes()
                elseif element == "playerCastBarScale" then
                    BetterBlizzFramesDB.playerCastBarScale = value
                    BBF.ChangeCastbarSizes()
                elseif element == "focusCastbarIconXPos" then
                    BetterBlizzFramesDB.focusCastbarIconXPos = value
                    BBF.ChangeCastbarSizes()
                elseif element == "focusCastbarIconYPos" then
                    BetterBlizzFramesDB.focusCastbarIconYPos = value
                    BBF.ChangeCastbarSizes()
                elseif element == "playerCastBarIconScale" then
                    BetterBlizzFramesDB.playerCastBarIconScale = value
                    BBF.ChangeCastbarSizes()
                elseif element == "playerCastBarWidth" then
                    BetterBlizzFramesDB.playerCastBarWidth = value
                    BBF.ChangeCastbarSizes()
                elseif element == "playerCastBarHeight" then
                    BetterBlizzFramesDB.playerCastBarHeight = value
                    BBF.ChangeCastbarSizes()
                elseif element == "maxTargetBuffs" then
                    BetterBlizzFramesDB.maxTargetBuffs = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "maxTargetDebuffs" then
                    BetterBlizzFramesDB.maxTargetDebuffs = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "maxBuffFrameBuffs" then
                    BetterBlizzFramesDB.maxBuffFrameBuffs = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "maxBuffFrameDebuffs" then
                    BetterBlizzFramesDB.maxBuffFrameDebuffs = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "petCastBarScale" then
                    BetterBlizzFramesDB.petCastBarScale = value
                    BBF.UpdatePetCastbar()
                elseif element == "petCastBarXPos" then
                    BetterBlizzFramesDB.petCastBarXPos = value
                    BBF.UpdatePetCastbar()
                elseif element == "petCastBarYPos" then
                    BetterBlizzFramesDB.petCastBarYPos = value
                    BBF.UpdatePetCastbar()
                elseif element == "petCastBarWidth" then
                    BetterBlizzFramesDB.petCastBarWidth = value
                    BBF.UpdatePetCastbar()
                elseif element == "petCastBarHeight" then
                    BetterBlizzFramesDB.petCastBarHeight = value
                    BBF.UpdatePetCastbar()
                elseif element == "petCastBarIconScale" then
                    BetterBlizzFramesDB.petCastBarIconScale = value
                    BBF.UpdatePetCastbar()
                elseif element == "playerAuraMaxBuffsPerRow" then
                    BetterBlizzFramesDB.playerAuraMaxBuffsPerRow = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "playerAuraSpacingX" then
                    BetterBlizzFramesDB.playerAuraSpacingX = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "playerAuraSpacingY" then
                    BetterBlizzFramesDB.playerAuraSpacingY = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "auraTypeGap" then
                    BetterBlizzFramesDB.auraTypeGap = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "auraStackSize" then
                    BetterBlizzFramesDB.auraStackSize = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "targetAndFocusSmallAuraScale" then
                    BetterBlizzFramesDB.targetAndFocusSmallAuraScale = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "enlargedAuraSize" then
                    BetterBlizzFramesDB.enlargedAuraSize = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "compactedAuraSize" then
                    BetterBlizzFramesDB.compactedAuraSize = value
                    BBF.RefreshAllAuraFrames()
                elseif element == "racialIndicatorScale" then
                    BetterBlizzFramesDB.racialIndicatorScale = value
                    BBF.RacialIndicatorCaller()
                elseif element == "racialIndicatorXPos" then
                    BetterBlizzFramesDB.racialIndicatorXPos = value
                    BBF.RacialIndicatorCaller()
                elseif element == "racialIndicatorYPos" then
                    BetterBlizzFramesDB.racialIndicatorYPos = value
                    BBF.RacialIndicatorCaller()
                elseif element == "targetToTAdjustmentOffsetY" then
                    BetterBlizzFramesDB.targetToTAdjustmentOffsetY = value
                    BBF.CastbarAdjustCaller()
                elseif element == "focusToTAdjustmentOffsetY" then
                    BetterBlizzFramesDB.focusToTAdjustmentOffsetY = value
                    BBF.CastbarAdjustCaller()
                elseif element == "castBarInterruptIconScale" then
                    BetterBlizzFramesDB.castBarInterruptIconScale = value
                    BBF.UpdateInterruptIconSettings()
                elseif element == "castBarInterruptIconXPos" then
                    BetterBlizzFramesDB.castBarInterruptIconXPos = value
                    BBF.UpdateInterruptIconSettings()
                elseif element == "castBarInterruptIconYPos" then
                    BetterBlizzFramesDB.castBarInterruptIconYPos = value
                    BBF.UpdateInterruptIconSettings()

                    --end
                end
            end
        end)
        
    return slider
end

local function CreateTooltip(widget, tooltipText, anchor)
    widget:SetScript("OnEnter", function(self)
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
        end

        if anchor then
            GameTooltip:SetOwner(self, anchor)
        else
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        end
        GameTooltip:SetText(tooltipText)

        GameTooltip:Show()
    end)

    widget:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

local function CreateTooltipTwo(widget, title, mainText, subText, anchor, cvarName)
    widget:SetScript("OnEnter", function(self)
        -- Clear the tooltip before showing new information
        GameTooltip:ClearLines()
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
        end
        if anchor then
            GameTooltip:SetOwner(self, anchor)
        else
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        end
        -- Set the bold title
        GameTooltip:AddLine(title)
        --GameTooltip:AddLine(" ") -- Adding an empty line as a separator
        -- Set the main text
        GameTooltip:AddLine(mainText, 1, 1, 1, true) -- true for wrap text
        -- Set the subtext
        if subText then
            GameTooltip:AddLine("____________________________", 0.8, 0.8, 0.8, true)
            GameTooltip:AddLine(subText, 0.8, 0.80, 0.80, true)
        end
        -- Add CVar information if provided
        if cvarName then
            --GameTooltip:AddLine(" ")
            --GameTooltip:AddLine("Default Value: " .. cvarName, 0.5, 0.5, 0.5) -- grey color for subtext
            GameTooltip:AddDoubleLine("Changes CVar:", cvarName, 0.2, 1, 0.6, 0.2, 1, 0.6)
        end
        GameTooltip:Show()
    end)
    widget:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

local function CreateImportExportUI(parent, title, dataTable, posX, posY, tableName)
    -- Frame to hold all import/export elements
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetSize(210, 65) -- Adjust size as needed
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", posX, posY)
    
    -- Setting the backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground", -- More subtle background
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Sleeker border
        tile = false, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.7) -- Semi-transparent black

    -- Title
    local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    titleText:SetPoint("BOTTOM", frame, "TOP", 0, 0)
    titleText:SetText(title)

    -- Export EditBox
    local exportBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    exportBox:SetSize(100, 20)
    exportBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -15, -10)
    exportBox:SetAutoFocus(false)
    CreateTooltipTwo(exportBox, "Ctrl+C to copy and share")

    -- Import EditBox
    local importBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    importBox:SetSize(100, 20)
    importBox:SetPoint("TOP", exportBox, "BOTTOM", 0, -5)
    importBox:SetAutoFocus(false)

    -- Export Button
    local exportBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    exportBtn:SetPoint("RIGHT", exportBox, "LEFT", -10, 0)
    exportBtn:SetSize(73, 20)
    exportBtn:SetText("Export")
    exportBtn:SetNormalFontObject("GameFontNormal")
    exportBtn:SetHighlightFontObject("GameFontHighlight")
    CreateTooltipTwo(exportBtn, "Export Data", "Create an export string to share your data.")

    -- Import Button
    local importBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    importBtn:SetPoint("RIGHT", importBox, "LEFT", -10, 0)
    importBtn:SetSize(title ~= "Full Profile" and 52 or 73, 20)
    importBtn:SetText("Import")
    importBtn:SetNormalFontObject("GameFontNormal")
    importBtn:SetHighlightFontObject("GameFontHighlight")
    CreateTooltipTwo(importBtn, "Import Data", "Import an export string.\nWill remove any current data (optional setting coming in non-beta)")

    -- Keep Old Checkbox
    local keepOldCheckbox
    if title ~= "Full Profile" then
        keepOldCheckbox = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
        keepOldCheckbox:SetPoint("RIGHT", importBtn, "LEFT", 3, -1)
        keepOldCheckbox:SetChecked(true)
        CreateTooltipTwo(keepOldCheckbox, "Keep Old Data", "Merge the imported data into your current data.\nWill keep your settings but add any new data.")
    end

    -- Button scripts
    exportBtn:SetScript("OnClick", function()
        local exportString = ExportProfile(dataTable, tableName)
        exportBox:SetText(exportString)
        exportBox:SetFocus()
        exportBox:HighlightText()
    end)


    importBtn:SetScript("OnClick", function()
        local importString = importBox:GetText()
        local profileData, errorMessage = BBF.ImportProfile(importString, tableName)
        if errorMessage then
            print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rFrames: Error importing " .. title .. ":", errorMessage)
        else
            if not profileData then
                print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rFrames: Error importing.")
                return
            end
            if keepOldCheckbox and keepOldCheckbox:GetChecked() then
                -- Perform a deep merge if "Keep Old" is checked
                deepMergeTables(dataTable, profileData)
            else
                -- Replace existing data with imported data
                for k in pairs(dataTable) do dataTable[k] = nil end -- Clear current table
                for k, v in pairs(profileData) do
                    dataTable[k] = v -- Populate with new data
                end
            end
            print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rFrames: " .. title .. " imported successfully. While still BETA this requires a reload to load in new lists.")
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    return frame
end

local function CreateAnchorDropdown(name, parent, defaultText, settingKey, toggleFunc, point)
    -- Create the dropdown frame using the library's creation function
    local dropdown = LibDD:Create_UIDropDownMenu(name, parent)
    LibDD:UIDropDownMenu_SetWidth(dropdown, 125)

    -- Function to get the display text based on the setting value
    local function getDisplayTextForSetting(settingValue)
        if name == "combatIndicatorDropdown" or name == "playerAbsorbAnchorDropdown" then
            if settingValue == "LEFT" then
                return "INNER"
            elseif settingValue == "RIGHT" then
                return "OUTER"
            end
        end
        return settingValue
    end

    -- Set the initial dropdown text
    LibDD:UIDropDownMenu_SetText(dropdown, getDisplayTextForSetting(BetterBlizzFramesDB[settingKey]) or defaultText)

    local anchorPointsToUse = anchorPoints
    if name == "combatIndicatorDropdown" or name == "playerAbsorbAnchorDropdown" then
        anchorPointsToUse = anchorPoints2
    end

    -- Initialize the dropdown using the library's initialize function
    LibDD:UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = LibDD:UIDropDownMenu_CreateInfo()
        for _, anchor in ipairs(anchorPointsToUse) do
            local displayText = anchor

            -- Customize display text for specific dropdowns
            if name == "combatIndicatorDropdown" or name == "playerAbsorbAnchorDropdown" then
                if anchor == "LEFT" then
                    displayText = "INNER"
                elseif anchor == "RIGHT" then
                    displayText = "OUTER"
                end
            end

            info.text = displayText
            info.arg1 = anchor
            info.func = function(self, arg1)
                if BetterBlizzFramesDB[settingKey] ~= arg1 then
                    BetterBlizzFramesDB[settingKey] = arg1
                    LibDD:UIDropDownMenu_SetText(dropdown, getDisplayTextForSetting(arg1))
                    toggleFunc(arg1)
                    BBF.MoveToTFrames()
                end
            end
            info.checked = (BetterBlizzFramesDB[settingKey] == anchor)
            LibDD:UIDropDownMenu_AddButton(info)
        end
    end)

    -- Position the dropdown
    dropdown:SetPoint("TOPLEFT", point.anchorFrame, "TOPLEFT", point.x, point.y)

    -- Create and set up the label
    local dropdownText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownText:SetPoint("BOTTOM", dropdown, "TOP", 0, 3)
    dropdownText:SetText(point.label)

    -- Enable or disable the dropdown based on the parent's check state
    if parent:GetObjectType() == "CheckButton" and parent:GetChecked() == false then
        LibDD:UIDropDownMenu_DisableDropDown(dropdown)
    else
        LibDD:UIDropDownMenu_EnableDropDown(dropdown)
    end

    return dropdown
end

local function CreateCheckbox(option, label, parent, cvarName, extraFunc)
    local checkBox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    checkBox.Text:SetText(label)

    local function UpdateOption(value)
        if option == 'friendlyFrameClickthrough' and BBF.checkCombatAndWarn() then
            return
        end

        local function SetChecked()
            if BetterBlizzFramesDB.hasCheckedUi then
                BetterBlizzFramesDB[option] = value
                checkBox:SetChecked(value)
            else
                C_Timer.After(0.1, function()
                    SetChecked()
                end)
            end
        end
        SetChecked()

        local grandparent = parent:GetParent()

        if parent:GetObjectType() == "CheckButton" and (parent:GetChecked() == false or (grandparent:GetObjectType() == "CheckButton" and grandparent:GetChecked() == false)) then
            checkBox:Disable()
            checkBox:SetAlpha(0.5)
        else
            checkBox:Enable()
            checkBox:SetAlpha(1)
        end

        if extraFunc and not BetterBlizzFramesDB.wasOnLoadingScreen then
            extraFunc(option, value)
        end

        if not BetterBlizzFramesDB.wasOnLoadingScreen then
            BBF.UpdateUserTargetSettings()
        end

        if not BetterBlizzFramesDB.wasOnLoadingScreen and BetterBlizzFramesDB.playerAuraFiltering then
            BBF.RefreshAllAuraFrames()
        end
        --print("Checkbox option '" .. option .. "' changed to:", value)
    end

    UpdateOption(BetterBlizzFramesDB[option])

    checkBox:HookScript("OnClick", function(_, _, _)
        UpdateOption(checkBox:GetChecked())
    end)

    return checkBox
end

local function CreateList(subPanel, listName, listData, refreshFunc, extraBoxes, colorText, width, pos)
    -- Create the scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, subPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(width or 322, 270)
    if not pos then
        scrollFrame:SetPoint("TOPLEFT", 10, -10)
    else
        scrollFrame:SetPoint("TOPLEFT", -48, -10)
    end

    -- Create the content frame
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(width or 322, 270)
    scrollFrame:SetScrollChild(contentFrame)

    local textLines = {}
    local framePool = {}
    local selectedLineIndex = nil

    -- Function to update the background colors of the entries
    local function updateBackgroundColors()
        for i, button in ipairs(textLines) do
            local bg = button.bgImg
            if i % 2 == 0 then
                bg:SetColorTexture(0.3, 0.3, 0.3, 0.1)  -- Dark color for even lines
            else
                bg:SetColorTexture(0.3, 0.3, 0.3, 0.3)  -- Light color for odd lines
            end
        end
    end

    local function deleteEntry(key)
        if not key then return end

        if BetterBlizzFramesDB[listName][key] then
            BetterBlizzFramesDB[listName][key] = nil
        end

        contentFrame.refreshList()
        BBF.RefreshAllAuraFrames()
    end

    local function createOrUpdateTextLineButton(npc, index, extraBoxes)
        local button

        -- Reuse frame from the pool if available
        if framePool[index] then
            button = framePool[index]
            button:Show()
        else
            -- Create a new frame if pool is exhausted
            button = CreateFrame("Frame", nil, contentFrame)
            button:SetSize((width and width - 12) or (322 - 12), 20)
            button:SetPoint("TOPLEFT", 10, -(index - 1) * 20)

            -- Background
            local bg = button:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            button.bgImg = bg  -- Store the background texture for later updates

            -- Icon
            local iconTexture = button:CreateTexture(nil, "OVERLAY")
            iconTexture:SetSize(20, 20)  -- Same height as the button
            iconTexture:SetPoint("LEFT", button, "LEFT", 0, 0)
            button.iconTexture = iconTexture

            -- Text
            local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("LEFT", button, "LEFT", 25, 0)
            button.text = text

            -- Delete Button
            local deleteButton = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
            deleteButton:SetSize(20, 20)
            deleteButton:SetPoint("RIGHT", button, "RIGHT", 4, 0)
            deleteButton:SetText("X")
            deleteButton:SetScript("OnClick", function()
                if IsShiftKeyDown() then
                    deleteEntry(button.npcData.id or button.npcData.name:lower())
                else
                    selectedLineIndex = button.npcData.id or button.npcData.name:lower()
                    StaticPopup_Show("BBF_DELETE_NPC_CONFIRM_" .. listName)
                end
            end)
            button.deleteButton = deleteButton

            -- Save button to the pool
            framePool[index] = button
        end

        -- Update button's content
        button.npcData = npc
        local displayText
        if npc.id then
            displayText = string.format("%s (%d)", npc.name, npc.id)  -- Display as "Name (id)"
        else
            displayText = npc.name  -- Display just the name if there's no id
        end
        button.text:SetText(displayText)
        button.iconTexture:SetTexture(C_Spell.GetSpellTexture(npc.id or npc.name))

        -- Function to set text color
        local function SetTextColor(r, g, b, a)
            if colorText and button.checkBoxI and button.checkBoxI:GetChecked() then
                button.text:SetTextColor(r or 1, g or 1, b or 0, a or 1)
            else
                button.text:SetTextColor(1, 1, 0, 1)
            end
        end

        -- Function to set important box color
        local function SetImportantBoxColor(r, g, b, a)
            if button.checkBoxI then
                if button.checkBoxI:GetChecked() then
                    button.checkBoxI.texture:SetVertexColor(r or 0, g or 1, b or 0, a or 1)
                else
                    button.checkBoxI.texture:SetVertexColor(0, 1, 0, 1)
                end
            end
        end

        -- Initialize colors based on npc data
        local entryColors = npc.color or {1, 0.8196, 0, 1}  -- Default yellowish color 
        

        -- Extra logic for handling additional checkboxes and flags
        if extraBoxes then
            -- CheckBox for Pandemic
            if not button.checkBoxP then
                local checkBoxP = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxP:SetSize(24, 24)
                checkBoxP:SetPoint("RIGHT", button.deleteButton, "LEFT", 4, 0)
                checkBoxP:SetScript("OnClick", function(self)
                    button.npcData.pandemic = self:GetChecked() -- Save the state in npc flags
                    BBF.RefreshAllAuraFrames()
                end)
                checkBoxP.texture = checkBoxP:CreateTexture(nil, "ARTWORK", nil, 1)
                checkBoxP.texture:SetAtlas("newplayertutorial-drag-slotgreen")
                checkBoxP.texture:SetDesaturated(true)
                checkBoxP.texture:SetVertexColor(1, 0, 0)
                checkBoxP.texture:SetSize(27, 27)
                checkBoxP.texture:SetPoint("CENTER", checkBoxP, "CENTER", -0.5, 0.5)
                button.checkBoxP = checkBoxP
                CreateTooltipTwo(checkBoxP, "Pandemic Glow |A:elementalstorm-boss-air:22:22|a", "Check for a red glow when the aura has less than 5 sec remaining.", "Also check which frame(s) you want this on down below in settings.", "ANCHOR_TOPRIGHT")
            end
            button.checkBoxP:SetChecked(button.npcData.pandemic)
    
            -- CheckBox for Important with color picker
            if not button.checkBoxI then
                local checkBoxI = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxI:SetSize(24, 24)
                checkBoxI:SetPoint("RIGHT", button.checkBoxP, "LEFT", 4, 0)
                checkBoxI:SetScript("OnClick", function(self)
                    button.npcData.important = self:GetChecked() -- Save the state in npc flags
                    BBF.RefreshAllAuraFrames()
                    SetImportantBoxColor(button.npcData.color[1], button.npcData.color[2], button.npcData.color[3], button.npcData.color[4])
                    SetTextColor(button.npcData.color[1], button.npcData.color[2], button.npcData.color[3], button.npcData.color[4])
                end)
                checkBoxI.texture = checkBoxI:CreateTexture(nil, "ARTWORK", nil, 1)
                checkBoxI.texture:SetAtlas("newplayertutorial-drag-slotgreen")
                checkBoxI.texture:SetSize(27, 27)
                checkBoxI.texture:SetDesaturated(true)
                checkBoxI.texture:SetPoint("CENTER", checkBoxI, "CENTER", -0.5, 0.5)
                button.checkBoxI = checkBoxI
                CreateTooltipTwo(checkBoxI, "Important Glow |A:importantavailablequesticon:22:22|a", "Check for a glow on the aura to highlight it.\n|cff32f795Right-click to change color.|r", "Also check which frame(s) you want this on down below in settings.", "ANCHOR_TOPRIGHT")
            end
            button.checkBoxI:SetChecked(button.npcData.important)
    
            -- Color picker logic
            local function OpenColorPicker()
                local colorData = entryColors or {0, 1, 0, 1}
                local r, g, b = colorData[1] or 1, colorData[2] or 1, colorData[3] or 1
                local a = colorData[4] or 1 -- Default alpha to 1 if not present

                local function updateColors(newR, newG, newB, newA)
                    -- Assign RGB values directly, and set alpha to 1 if not provided
                    entryColors[1] = newR
                    entryColors[2] = newG
                    entryColors[3] = newB
                    entryColors[4] = newA or 1  -- Default alpha value to 1 if not provided

                    -- Update text and box colors
                    SetTextColor(newR, newG, newB, newA or 1)  -- Update text color with default alpha if needed
                    SetImportantBoxColor(newR, newG, newB, newA or 1)  -- Update important box color with default alpha if needed
                    -- Refresh frames or elements that depend on these colors
                    BBF.RefreshAllAuraFrames()
                end

                local function swatchFunc()
                    r, g, b = ColorPickerFrame:GetColorRGB()
                    updateColors(r, g, b, a)  -- Pass current color values to updateColors
                end

                local function opacityFunc()
                    a = ColorPickerFrame:GetColorAlpha()
                    updateColors(r, g, b, a)  -- Pass current color values to updateColors including the alpha value
                end

                local function cancelFunc(previousValues)
                    -- Revert to previous values if the selection is cancelled
                    if previousValues then
                        r, g, b, a = previousValues.r, previousValues.g, previousValues.b, previousValues.a
                        updateColors(r, g, b, a)  -- Reapply the previous colors
                    end
                end

                -- Store the initial values before showing the color picker
                ColorPickerFrame.previousValues = { r = r, g = g, b = b, a = a }

                -- Setup and show the color picker with the necessary callbacks and initial values
                ColorPickerFrame:SetupColorPickerAndShow({
                    r = r, g = g, b = b, opacity = a, hasOpacity = true,
                    swatchFunc = swatchFunc, opacityFunc = opacityFunc, cancelFunc = cancelFunc
                })
            end
    
            -- Right-click to open color picker
            button.checkBoxI:SetScript("OnMouseDown", function(self, button)
                if button == "RightButton" then
                    OpenColorPicker()
                end
            end)
    
            -- CheckBox for Compacted
            if not button.checkBoxC then
                local checkBoxC = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxC:SetSize(24, 24)
                checkBoxC:SetPoint("RIGHT", button.checkBoxI, "LEFT", 3, 0)
                button.checkBoxC = checkBoxC
                CreateTooltipTwo(checkBoxC, "Compacted Aura |A:ui-hud-minimap-zoom-out:22:22|a", "Check to make the aura smaller.", "Also check which frame(s) you want this on down below in settings.", "ANCHOR_TOPRIGHT")
            end
            button.checkBoxC:SetChecked(button.npcData.compacted)
    
            -- CheckBox for Enlarged
            if not button.checkBoxE then
                local checkBoxE = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxE:SetSize(24, 24)
                checkBoxE:SetPoint("RIGHT", button.checkBoxC, "LEFT", 3, 0)
                checkBoxE:SetScript("OnClick", function(self)
                    button.npcData.enlarged = self:GetChecked()
                    button.checkBoxC:SetChecked(false)
                    button.npcData.compacted = false
                    BBF.RefreshAllAuraFrames()
                end)
                button.checkBoxC:SetScript("OnClick", function(self)
                    button.npcData.compacted = self:GetChecked()
                    button.checkBoxE:SetChecked(false)
                    button.npcData.enlarged = false
                    BBF.RefreshAllAuraFrames()
                end)
                CreateTooltipTwo(checkBoxE, "Enlarged Aura |A:ui-hud-minimap-zoom-in:22:22|a", "Check to make the aura bigger.", "Also check which frame(s) you want this on down below in settings.", "ANCHOR_TOPRIGHT")
                button.checkBoxE = checkBoxE
            end
            button.checkBoxE:SetChecked(button.npcData.enlarged)
    
            -- CheckBox for "Only Mine"
            if not button.checkBoxOnlyMine then
                local checkBoxOnlyMine = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxOnlyMine:SetSize(24, 24)
                checkBoxOnlyMine:SetPoint("RIGHT", button.checkBoxE, "LEFT", 3, 0)
                checkBoxOnlyMine:SetScript("OnClick", function(self)
                    button.npcData.onlyMine = self:GetChecked()
                    BBF.RefreshAllAuraFrames()
                end)
                button.checkBoxOnlyMine = checkBoxOnlyMine
                CreateTooltipTwo(checkBoxOnlyMine, "Only My Aura |A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:22:22|a", "Only show my aura.", nil, "ANCHOR_TOPRIGHT")
            end
            button.checkBoxOnlyMine:SetChecked(button.npcData.onlyMine)
        end

        if listName == "auraBlacklist" then
            if not button.checkBoxShowMine then
                -- Create Checkbox Only Mine if not already created
                local checkBoxShowMine = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                checkBoxShowMine:SetSize(24, 24)
                checkBoxShowMine:SetPoint("RIGHT", button, "RIGHT", -13, 0)
                CreateTooltipTwo(checkBoxShowMine, "Show mine |A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:22:22|a", "Disregard the blacklist and show aura if it is mine.", nil, "ANCHOR_TOPRIGHT")

                -- Handler for the show mine checkbox
                checkBoxShowMine:SetScript("OnClick", function(self)
                    button.npcData.showMine = self:GetChecked()
                    BBF.RefreshAllAuraFrames()
                end)

                -- Adjust text width and settings
                button.text:SetWidth(196)
                button.text:SetWordWrap(false)
                button.text:SetJustifyH("LEFT")

                -- Save the reference to the button
                button.checkBoxShowMine = checkBoxShowMine
            end
            button.checkBoxShowMine:SetChecked(button.npcData.showMine)
        end

        if button.checkBoxI then
            if button.checkBoxI:GetChecked() then
                SetImportantBoxColor(entryColors[1], entryColors[2], entryColors[3], entryColors[4])
                SetTextColor(entryColors[1], entryColors[2], entryColors[3], entryColors[4])
            else
                SetImportantBoxColor(0, 1, 0, 1)
                SetTextColor(1, 0.8196, 0, 1)
            end
        end

        if npc.id and not button.idTip then
            button:SetScript("OnEnter", function(self)
                if not button.npcData.id then return end
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:SetSpellByID(button.npcData.id)
                GameTooltip:AddLine("Spell ID: " .. button.npcData.id, 1, 1, 1)
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
            button.idTip = true
        end

        -- Update background colors
        updateBackgroundColors()

        return button
    end

    -- Create static popup dialogs for duplicate and delete confirmations
    StaticPopupDialogs["BBF_DUPLICATE_NPC_CONFIRM_" .. listName] = {
        text = "This name or spellID is already in the list. Do you want to remove it from the list?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            deleteEntry(selectedLineIndex)  -- Delete the entry when "Yes" is clicked
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    StaticPopupDialogs["BBF_DELETE_NPC_CONFIRM_" .. listName] = {
        text = "Are you sure you want to delete this entry?\nHold shift to delete without this prompt",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            deleteEntry(selectedLineIndex)  -- Delete the entry when "Yes" is clicked
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    local editBox = CreateFrame("EditBox", nil, subPanel, "InputBoxTemplate")
    editBox:SetSize((width and width - 62) or (322 - 62), 19)
    editBox:SetPoint("TOP", scrollFrame, "BOTTOM", -15, -5)
    editBox:SetAutoFocus(false)
    CreateTooltipTwo(editBox, "Filter auras by spell id and/or spell name", "You can click auras to add to lists.\n\nTo whitelist:\nShift+Alt + LeftClick\n\nTo blacklist:\nShift+Alt + RightClick\nCtrl+Alt RightClick with \"Show Mine\" tag", nil, "ANCHOR_TOP")

    local function getSortedNpcList()
        local sortableNpcList = {}

        -- Iterate over the new structure using pairs to access all entries
        for key, entry in pairs(listData) do
            table.insert(sortableNpcList, entry)  -- Collect all entries into a sortable list
        end

        -- Sort the list alphabetically by the 'name' field
        table.sort(sortableNpcList, function(a, b)
            local nameA = a.name and a.name:lower() or ""
            local nameB = b.name and b.name:lower() or ""
            return nameA < nameB
        end)
        --print("Number of entries in the list: " .. #sortableNpcList)
        return sortableNpcList
    end

    local function refreshList()
        local sortedListData = getSortedNpcList()
        local totalEntries = #sortedListData
        local batchSize = 35  -- Number of entries to process per frame
        local currentIndex = 1

        local function processNextBatch()
            for i = currentIndex, math.min(currentIndex + batchSize - 1, totalEntries) do
                local npc = sortedListData[i]
                local button = createOrUpdateTextLineButton(npc, i, extraBoxes)
                textLines[i] = button
            end

            -- Hide any extra frames
            for i = totalEntries + 1, #framePool do
                if framePool[i] then
                    framePool[i]:Hide()
                end
            end

            -- Update the content frame height
            contentFrame:SetHeight(totalEntries * 20)
            updateBackgroundColors()

            -- Continue processing if there are more entries
            currentIndex = currentIndex + batchSize
            if currentIndex <= totalEntries then
                C_Timer.After(0.04, processNextBatch)  -- Defer to the next frame
            end
        end
        -- Start processing in the first frame
        processNextBatch()
        --print("refreshing.....")
    end

    contentFrame.refreshList = refreshList
    refreshList()
    --BBF[listName.."DelayedUpdate"] = refreshList
    BBF[listName.."Refresh"] = refreshList

    local function addOrUpdateEntry(inputText, addShowMineTag, skipRefresh, color)
        selectedLineIndex = nil
        local name, comment = strsplit("/", inputText, 2)
        name = strtrim(name or "")
        comment = comment and strtrim(comment) or nil
        local id = tonumber(name)

        -- Check if there's a numeric ID within the name and clear the name if found
        if id then
            local spellName = BBF.TWWGetSpellInfo(id)
            name = spellName or ""
        end

        -- Remove unwanted characters from name and comment individually
        name = gsub(name, "[%/%(%)%[%]]", "")
        if comment then
            comment = gsub(comment, "[%/%(%)%[%]]", "")
        end

        if (name ~= "" or id) then
            local key = id or string.lower(name)  -- Use id if available, otherwise use name
            local isDuplicate = false

            -- Directly check if the key already exists in the list
            if BetterBlizzFramesDB[listName][key] then
                isDuplicate = true
                selectedLineIndex = key  -- Use key to identify the duplicate
            end

            if isDuplicate then
                StaticPopup_Show("BBF_DUPLICATE_NPC_CONFIRM_" .. listName)
            else
                -- Initialize the new entry with appropriate structure
                local newEntry = {
                    name = name,
                    id = id,
                    comment = comment or nil,
                }

                if listName == "auraWhitelist" then
                    newEntry = {name = name, id = id, comment = comment or nil, color = {0,1,0,1}}
                end

                -- if color then
                --     --newEntry.color = {1,0.501960813999176,0,1} -- offensive
                --     --newEntry.color = {1,0.6627451181411743,0.9450981020927429,1} -- defensive
                --     newEntry.color = {0,1,1,1} -- mobility
                --     --newEntry.color = {0,1,0,1} --muy importante
                --     newEntry.important = true
                --     newEntry.enlarged = true
                -- end

                -- If adding to auraBlacklist and addShowMineTag is true, set showMine to true
                if addShowMineTag and listName == "auraBlacklist" then
                    newEntry.showMine = true
                end

                -- Add the new entry to the list using key
                BetterBlizzFramesDB[listName][key] = newEntry

                -- Update UI: Re-create text line button and refresh the list display
                createOrUpdateTextLineButton(newEntry, #textLines + 1, extraBoxes)

                if not skipRefresh then
                    refreshList()
                    --print("not skipping so sending")
                else
                    if SettingsPanel:IsShown() then
                        --print("refreshing list cuz settings are open")
                        refreshList()
                    else
                        --print("prepping delayed update")
                        BBF[listName.."DelayedUpdate"] = refreshList
                    end
                end

                refreshFunc()
            end
        end

        BBF.RefreshAllAuraFrames()
        editBox:SetText("")  -- Clear the EditBox
    end

    BBF[listName] = addOrUpdateEntry
    --BBF.auraWhitelist & BBF.auraBlacklist

    editBox:SetScript("OnEnterPressed", function(self)
        addOrUpdateEntry(self:GetText())
    end)

    local addButton = CreateFrame("Button", nil, subPanel, "UIPanelButtonTemplate")
    addButton:SetSize(60, 24)
    addButton:SetText("Add")
    addButton:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
    addButton:SetScript("OnClick", function()
        addOrUpdateEntry(editBox:GetText())
    end)
    scrollFrame:HookScript("OnShow", function()
        if BBF.auraWhitelistDelayedUpdate then
            BBF.auraWhitelistDelayedUpdate()
            --print("Ran delayed update WHITELIST, then set it to not run next time")
            BBF.auraWhitelistDelayedUpdate = nil
        end
        if BBF.auraBlacklistDelayedUpdate then
            BBF.auraBlacklistDelayedUpdate()
            --print("Ran delayed update BLACKLIST, then set it to not run next time")
            BBF.auraBlacklistDelayedUpdate = nil
        end
    end)
    return scrollFrame
end

SettingsPanel:HookScript("OnShow", function()
    if BBF.auraWhitelistDelayedUpdate then
        BBF.auraWhitelistDelayedUpdate()
        --print("Ran delayed update WHITELIST, then set it to not run next time")
        BBF.auraWhitelistDelayedUpdate = nil
    end
    if BBF.auraBlacklistDelayedUpdate then
        BBF.auraBlacklistDelayedUpdate()
        --print("Ran delayed update BLACKLIST, then set it to not run next time")
        BBF.auraBlacklistDelayedUpdate = nil
    end
end)

local function CreateTitle(parent)
    local mainGuiAnchor = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor:SetPoint("TOPLEFT", 15, -15)
    mainGuiAnchor:SetText(" ")
    local addonNameText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    addonNameText:SetPoint("TOPLEFT", mainGuiAnchor, "TOPLEFT", -20, 47)
    addonNameText:SetText("BetterBlizzFrames")
    local addonNameIcon = parent:CreateTexture(nil, "ARTWORK")
    addonNameIcon:SetAtlas("gmchat-icon-blizz")
    addonNameIcon:SetSize(22, 22)
    addonNameIcon:SetPoint("LEFT", addonNameText, "RIGHT", -2, -1)
    local verNumber = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    verNumber:SetPoint("LEFT", addonNameText, "RIGHT", 25, 0)
    verNumber:SetText("v" .. BBF.VersionNumber)
end

------------------------------------------------------------
-- GUI Panels
------------------------------------------------------------
local function guiGeneralTab()
    ----------------------
    -- Main panel:
    ----------------------
    local mainGuiAnchor = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor:SetPoint("TOPLEFT", 15, -15)
    mainGuiAnchor:SetText(" ")

    local bgImg = BetterBlizzFrames:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", BetterBlizzFrames, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    -- local addonNameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    -- addonNameText:SetPoint("TOPLEFT", mainGuiAnchor, "TOPLEFT", -20, 47)
    -- addonNameText:SetText("BetterBlizzFrames")
    -- local addonNameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    -- addonNameIcon:SetAtlas("gmchat-icon-blizz")
    -- addonNameIcon:SetSize(22, 22)
    -- addonNameIcon:SetPoint("LEFT", addonNameText, "RIGHT", -2, -1)
    -- local verNumber = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- verNumber:SetPoint("LEFT", addonNameText, "RIGHT", 25, 0)
    -- verNumber:SetText("v" .. BBF.VersionNumber)
    CreateTitle(BetterBlizzFrames)

    ----------------------
    -- General:
    ----------------------
    -- "General:" text
    local settingsText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, 30)
    settingsText:SetText("General settings")
    local generalSettingsIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    generalSettingsIcon:SetAtlas("optionsicon-brown")
    generalSettingsIcon:SetSize(22, 22)
    generalSettingsIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)






    local hideArenaFrames = CreateCheckbox("hideArenaFrames", "Hide Arena Frames", BetterBlizzFrames, nil, BBF.HideArenaFrames)
    hideArenaFrames:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    hideArenaFrames:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    CreateTooltip(hideArenaFrames, "Hide the standard Blizzard Arena Frames.\nThis uses the same code as the addon\n\"Arena Anti-Malware\", also made by me.")

    local hideBossFrames = CreateCheckbox("hideBossFrames", "Hide Boss Frames", BetterBlizzFrames, nil, BBF.HideArenaFrames)
    hideBossFrames:SetPoint("TOPLEFT", hideArenaFrames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideBossFrames, "Hide the Blizzard Boss Frames that are underneath the minimap.")

    local hideBossFramesParty = CreateCheckbox("hideBossFramesParty", "Party", BetterBlizzFrames, nil, BBF.HideArenaFrames)
    hideBossFramesParty:SetPoint("LEFT", hideBossFrames.text, "RIGHT", 0, 0)
    CreateTooltip(hideBossFramesParty, "Hide Boss Frames in Party", "ANCHOR_LEFT")

    local hideBossFramesRaid = CreateCheckbox("hideBossFramesRaid", "Raid", BetterBlizzFrames, nil, BBF.HideArenaFrames)
    hideBossFramesRaid:SetPoint("LEFT", hideBossFramesParty.text, "RIGHT", 0, 0)
    CreateTooltip(hideBossFramesRaid, "Hide Boss Frames in Raid", "ANCHOR_LEFT")

    hideBossFrames:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzFramesDB.overShieldsCompact = true
            BetterBlizzFramesDB.hideBossFramesParty = true
            hideBossFramesParty:SetAlpha(1)
            hideBossFramesParty:Enable()
            hideBossFramesParty:SetChecked(true)
            hideBossFramesRaid:SetAlpha(1)
            hideBossFramesRaid:Enable()
            hideBossFramesRaid:SetChecked(true)
        else
            BetterBlizzFramesDB.overShieldsCompact = false
            BetterBlizzFramesDB.hideBossFramesParty = false
            hideBossFramesParty:SetAlpha(0)
            hideBossFramesParty:Disable()
            hideBossFramesParty:SetChecked(false)
            hideBossFramesRaid:SetAlpha(0)
            hideBossFramesRaid:Disable()
            hideBossFramesRaid:SetChecked(false)
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    if not BetterBlizzFramesDB.hideBossFrames then
        hideBossFramesParty:SetAlpha(0)
        hideBossFramesParty:Disable()
        hideBossFramesRaid:SetAlpha(0)
        hideBossFramesRaid:Disable()
    end

    local playerFrameOCD = CreateCheckbox("playerFrameOCD", "OCD Tweaks", BetterBlizzFrames, nil, BBF.FixStupidBlizzPTRShit)
    playerFrameOCD:SetPoint("TOPLEFT", hideBossFrames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(playerFrameOCD, "Removes small gap around player portrait, healthbars and manabars, etc.\nJust in general tiny OCD fixes on a few things. Requires a reload for full effect.\nTemporary setting I might remove if blizz fixes their stuff.")

    local playerFrameOCDTextureBypass = CreateCheckbox("playerFrameOCDTextureBypass", "OCD: Skip Bars", BetterBlizzFrames, nil, BBF.HideFrames)
    playerFrameOCDTextureBypass:SetPoint("LEFT", playerFrameOCD.text, "RIGHT", 0, 0)
    CreateTooltip(playerFrameOCDTextureBypass, "If healthbars & manabars look weird enable this to skip\nadjusting them and only fix portraits + reputation color")

    playerFrameOCD:HookScript("OnClick", function(self)
        if self:GetChecked() then
            playerFrameOCDTextureBypass:Enable()
            playerFrameOCDTextureBypass:SetAlpha(1)
        else
            BetterBlizzFramesDB.playerFrameOCDTextureBypass = false
            playerFrameOCDTextureBypass:SetChecked(false)
            playerFrameOCDTextureBypass:Disable()
            playerFrameOCDTextureBypass:SetAlpha(0)
        end
    end)

    if not BetterBlizzFramesDB.playerFrameOCD then
        playerFrameOCDTextureBypass:Disable()
        playerFrameOCDTextureBypass:SetAlpha(0)
    end

    local hideLossOfControlFrameBg = CreateCheckbox("hideLossOfControlFrameBg", "Hide CC Background", BetterBlizzFrames, nil, BBF.HideFrames)
    hideLossOfControlFrameBg:SetPoint("TOPLEFT", playerFrameOCD, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideLossOfControlFrameBg, "Hide the dark background on the LossOfControl frame (displaying CC on you)")
    hideLossOfControlFrameBg:HookScript("OnClick", function()
        BBF.ToggleLossOfControlTestMode()
    end)

    local hideLossOfControlFrameLines = CreateCheckbox("hideLossOfControlFrameLines", "Hide CC Red-lines", BetterBlizzFrames, nil, BBF.HideFrames)
    hideLossOfControlFrameLines:SetPoint("TOPLEFT", hideLossOfControlFrameBg, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideLossOfControlFrameLines, "Hide the red lines on top and bottom of the LossOfControl frame (displaying CC on you)")
    hideLossOfControlFrameLines:HookScript("OnClick", function()
        BBF.ToggleLossOfControlTestMode()
    end)

    local lossOfControlScale = CreateSlider(BetterBlizzFrames, "CC Scale", 0.4, 1.4, 0.01, "lossOfControlScale", nil, 90)
    lossOfControlScale:SetPoint("LEFT", hideLossOfControlFrameBg.text, "RIGHT", 3, -16)
    CreateTooltipTwo(lossOfControlScale, "Loss of Control Scale", "Adjust the scale of the LossOfControlFrame\n(displaying cc on you center screen)")

    local darkModeUi = CreateCheckbox("darkModeUi", "Dark Mode", BetterBlizzFrames)
    darkModeUi:SetPoint("TOPLEFT", hideLossOfControlFrameLines, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeUi:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeUi, "Simple dark mode for: UnitFrames, Actionbars & Aura Icons.\n\nIf you want a more advanced & thorough dark mode\nI recommend the addon FrameColor instead of this setting.")

    local darkModeActionBars = CreateCheckbox("darkModeActionBars", "ActionBars", darkModeUi)
    darkModeActionBars:SetPoint("TOPLEFT", darkModeUi, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeActionBars:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeActionBars, "Dark borders for action bars.")

    local darkModeMinimap = CreateCheckbox("darkModeMinimap", "Minimap", darkModeUi)
    darkModeMinimap:SetPoint("TOPLEFT", darkModeActionBars, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeMinimap:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeMinimap, "Dark mode for Minimap")

    local darkModeCastbars = CreateCheckbox("darkModeCastbars", "Castbars", darkModeUi)
    darkModeCastbars:SetPoint("LEFT", darkModeUi.Text, "RIGHT", 5, 0)
    darkModeCastbars:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeCastbars, "Dark borders for castbars.")

    local darkModeUiAura = CreateCheckbox("darkModeUiAura", "Auras", darkModeUi)
    darkModeUiAura:SetPoint("TOPLEFT", darkModeCastbars, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeUiAura:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeUiAura, "Dark borders for Player, Target and Focus aura icons")

    local darkModeNameplateResource = CreateCheckbox("darkModeNameplateResource", "Nameplate Resource", darkModeUi)
    darkModeNameplateResource:SetPoint("TOPLEFT", darkModeUiAura, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeNameplateResource:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltip(darkModeNameplateResource, "Dark mode for nameplate resource (Combopoints etc)\n\n(If you are using this same feature in BBP\nthat one will be prioritized)")

    local darkModeGameTooltip = CreateCheckbox("darkModeGameTooltip", "Tooltip", darkModeUi)
    darkModeGameTooltip:SetPoint("TOPLEFT", darkModeMinimap, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    darkModeGameTooltip:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltipTwo(darkModeGameTooltip, "Dark Mode: Tooltip", "Dark mode for the Game Tooltip.")

    local darkModeObjectiveFrame = CreateCheckbox("darkModeObjectiveFrame", "Objectives", darkModeUi)
    darkModeObjectiveFrame:SetPoint("LEFT", darkModeGameTooltip.Text, "RIGHT", 5, 0)
    darkModeObjectiveFrame:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltipTwo(darkModeObjectiveFrame, "Dark Mode: Objectives", "Dark mode for Objectives/Quest Tracker")

    local darkModeVigor = CreateCheckbox("darkModeVigor", "Vigor", darkModeUi)
    darkModeVigor:SetPoint("LEFT", darkModeObjectiveFrame.Text, "RIGHT", 5, 0)
    darkModeVigor:HookScript("OnClick", function()
        BBF.DarkmodeFrames(true)
    end)
    CreateTooltipTwo(darkModeVigor, "Dark Mode: Vigor", "Dark mode for flying mount Vigor charges")

    local darkModeColor = CreateSlider(darkModeUi, "Darkness", 0, 1, 0.01, "darkModeColor", nil, 90)
    darkModeColor:SetPoint("LEFT", darkModeUiAura.text, "RIGHT", 3, -1)
    CreateTooltipTwo(darkModeColor, "Dark Mode Value", "Adjust how dark you want the dark mode to be.\nTip: You can rightclick all sliders to input a specific value.")

    darkModeUi:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(darkModeUi, 0)
    end)
    if not BetterBlizzFramesDB.darkModeUi then
        CheckAndToggleCheckboxes(darkModeUi, 0)
    end










    local playerFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playerFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -180)
    playerFrameText:SetText("Player Frame")
    local playerFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    playerFrameIcon:SetAtlas("groupfinder-icon-friend")
    playerFrameIcon:SetSize(28, 28)
    playerFrameIcon:SetPoint("RIGHT", playerFrameText, "LEFT", -3, 0)

    local playerFrameClickthrough = CreateCheckbox("playerFrameClickthrough", "Clickthrough", BetterBlizzFrames, nil, BBF.ClickthroughFrames)
    playerFrameClickthrough:SetPoint("TOPLEFT", playerFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltip(playerFrameClickthrough, "Makes the PlayerFrame clickthrough.\nYou can still hold shift to left/right click it\nwhile out of combat for trade/inspect etc.\n\nNOTE: You will NOT be able to click the frame\nat all during combat with this setting on.")

    local playerReputationColor = CreateCheckbox("playerReputationColor", "Add Reputation Color", BetterBlizzFrames, nil, BBF.PlayerReputationColor)
    playerReputationColor:SetPoint("TOPLEFT", playerFrameClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(playerReputationColor, "Add reputation color behind name like on Target & Focus.|A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a\nCan be class colored as well.")

    local playerReputationClassColor = CreateCheckbox("playerReputationClassColor", "Class color", BetterBlizzFrames, nil, BBF.PlayerReputationColor)
    playerReputationClassColor:SetPoint("LEFT", playerReputationColor.text, "RIGHT", 5, 0)
    CreateTooltip(playerReputationClassColor, "Class color the Player reputation texture.")
    playerReputationColor:HookScript("OnClick", function(self)
        if self:GetChecked() then
            playerReputationClassColor:Enable()
            playerReputationClassColor:SetAlpha(1)
        else
            playerReputationClassColor:Disable()
            playerReputationClassColor:SetAlpha(0)
        end
    end)
    if not BetterBlizzFramesDB.playerReputationColor then
        playerReputationClassColor:SetAlpha(0)
        playerReputationClassColor:Disable()
    end

    local hidePlayerName = CreateCheckbox("hidePlayerName", "Hide Name", BetterBlizzFrames, nil, BBF.UpdateNameSettings)
    hidePlayerName:SetPoint("TOPLEFT", playerReputationColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hidePlayerName:HookScript("OnClick", function(self)
        -- if self:GetChecked() then
        --     PlayerFrame.name:SetAlpha(0)
        --     if PlayerFrame.cleanName then
        --         PlayerFrame.cleanName:SetAlpha(0)
        --     end
        -- else
        --     PlayerFrame.name:SetAlpha(0)
        --     if PlayerFrame.cleanName then
        --         PlayerFrame.cleanName:SetAlpha(1)
        --     else
        --         PlayerFrame.name:SetAlpha(1)
        --     end
        -- end
        BBF.SetCenteredNamesCaller()
    end)

    -- local hidePlayerMaxHpReduction = CreateCheckbox("hidePlayerMaxHpReduction", "Hide Reduced HP", BetterBlizzFrames, nil, BBF.HideFrames)
    -- hidePlayerMaxHpReduction:SetPoint("LEFT", hidePlayerName.text, "RIGHT", 0, 0)
    -- CreateTooltipTwo(hidePlayerMaxHpReduction, "Hide Reduced HP", "Hide the new max health loss indication introduced in TWW from PlayerFrame.")

    local hidePlayerPower = CreateCheckbox("hidePlayerPower", "Hide Resource/Power", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerPower:SetPoint("TOPLEFT", hidePlayerName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerPower, "Hide Resource/Power under PlayerFrame. Rogue combopoints, Warlock shards etc.")

    local hidePlayerRestAnimation = CreateCheckbox("hidePlayerRestAnimation", "Hide \"Zzz\" Rest Animation", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerRestAnimation:SetPoint("TOPLEFT", hidePlayerPower, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerRestAnimation, "Hide the \"Zzz\" animation on PlayerFrame while rested.")

    local hidePlayerRestGlow = CreateCheckbox("hidePlayerRestGlow", "Hide Rest Glow", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerRestGlow:SetPoint("TOPLEFT", hidePlayerRestAnimation, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerRestGlow, "Hide the flashing yellow rest glow animation around PlayerFrame while rested.|A:UI-HUD-UnitFrame-Player-PortraitOn-Status:30:80|a")

    local hidePlayerCornerIcon = CreateCheckbox("hidePlayerCornerIcon", "Hide Corner Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerCornerIcon:SetPoint("TOPLEFT", hidePlayerRestGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerCornerIcon, "Hide corner icon on PlayerFrame.|A:UI-HUD-UnitFrame-Player-PortraitOn-CornerEmbellishment:22:22|a\n")

    local hideCombatIcon = CreateCheckbox("hideCombatIcon", "Hide Combat Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hideCombatIcon:SetPoint("TOPLEFT", hidePlayerCornerIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideCombatIcon, "Hide combat icon on in the bottom right corner of the PlayerFrame.|A:UI-HUD-UnitFrame-Player-CombatIcon:22:22|a\n")

    local hideGroupIndicator = CreateCheckbox("hideGroupIndicator", "Hide Group Indicator", BetterBlizzFrames, nil, BBF.HideFrames)
    hideGroupIndicator:SetPoint("TOPLEFT", hideCombatIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideGroupIndicator, "Hide the group indicator on top of PlayerFrame\nwhile you are in a group.")

    local hideTotemFrame = CreateCheckbox("hideTotemFrame", "Hide Totem Frame", BetterBlizzFrames, nil, BBF.HideFrames)
    hideTotemFrame:SetPoint("LEFT", hideGroupIndicator.text, "RIGHT", 0, 0)
    CreateTooltip(hideTotemFrame, "Hide the TotemFrame under PlayerFrame.")

    local hidePlayerLeaderIcon = CreateCheckbox("hidePlayerLeaderIcon", "Hide Leader Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerLeaderIcon:SetPoint("TOPLEFT", hideGroupIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerLeaderIcon, "Hide the party leader icon from PlayerFrame.|A:UI-HUD-UnitFrame-Player-Group-LeaderIcon:22:22|a")

    local hidePlayerGuideIcon = CreateCheckbox("hidePlayerGuideIcon", "Hide Guide Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerGuideIcon:SetPoint("LEFT", hidePlayerLeaderIcon.text, "RIGHT", 0, 0)
    CreateTooltip(hidePlayerGuideIcon, "Hide the guide icon from PlayerFrame.|A:UI-HUD-UnitFrame-Player-Group-GuideIcon:22:22|a")

    local hidePlayerRoleIcon = CreateCheckbox("hidePlayerRoleIcon", "Hide Role Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePlayerRoleIcon:SetPoint("TOPLEFT", hidePlayerLeaderIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePlayerRoleIcon, "Hide the role icon from PlayerFrame|A:roleicon-tiny-dps:22:22|a")

    local hidePvpTimerText = CreateCheckbox("hidePvpTimerText", "Hide PvP Timer", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePvpTimerText:SetPoint("LEFT", hidePlayerRoleIcon.text, "RIGHT", 0, 0)
    CreateTooltip(hidePvpTimerText, "Hide the PvP timer text under the Prestige Badge.\nI don't even know what it is a timer for.\nMy best guess is for when you're no longer PvP tagged.")





    local petFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    petFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, -455)
    petFrameText:SetText("Pet Frame")
    local petFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    petFrameIcon:SetAtlas("newplayerchat-chaticon-newcomer")
    petFrameIcon:SetSize(21, 21)
    petFrameIcon:SetPoint("RIGHT", petFrameText, "LEFT", -2, 0)

    local petCastbar = CreateCheckbox("petCastbar", "Pet Castbar", BetterBlizzFrames, nil, BBF.UpdatePetCastbar)
    petCastbar:SetPoint("TOPLEFT", petFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltip(petCastbar, "Show pet castbar.\n\nMore settings in the \"Castbars\" tab")

    local colorPetAfterOwner = CreateCheckbox("colorPetAfterOwner", "Color Pet After Player Class", BetterBlizzFrames)
    colorPetAfterOwner:SetPoint("TOPLEFT", petCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    colorPetAfterOwner:HookScript("OnClick", function (self)
        BBF.UpdateFrames()
    end)


    local partyFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    partyFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 0, -430)
    partyFrameText:SetText("Party Frame")
    local partyFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    partyFrameIcon:SetAtlas("groupfinder-icon-friend")
    partyFrameIcon:SetSize(25, 25)
    partyFrameIcon:SetPoint("RIGHT", partyFrameText, "LEFT", -4, -1)
    local partyFrameIcon2 = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    partyFrameIcon2:SetAtlas("groupfinder-icon-friend")
    partyFrameIcon2:SetSize(20, 20)
    partyFrameIcon2:SetPoint("RIGHT", partyFrameText, "LEFT", 0, 4)

    local showPartyCastbar = CreateCheckbox("showPartyCastbar", "Party Castbars", BetterBlizzFrames, nil, BBF.UpdateCastbars)
    showPartyCastbar:SetPoint("TOPLEFT", partyFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    showPartyCastbar:HookScript("OnClick", function(self)
        --BBF.AbsorbCaller()
    end)
    CreateTooltip(showPartyCastbar, "Show party members castbar on party frames.\n\nMore settings in the \"Castbars\" tab.")

--[=[
    local sortGroup = CreateCheckbox("sortGroup", "Sort Group", BetterBlizzFrames, nil, BBF.SortGroup)
    sortGroup:SetPoint("TOPLEFT", showPartyCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(sortGroup, "Always sort the group members in chronological order from top to bottom. ")

    local sortGroupPlayerTop = CreateCheckbox("sortGroupPlayerTop", "Player on Top", BetterBlizzFrames, nil, BBF.SortGroup)
    sortGroupPlayerTop:SetPoint("LEFT", sortGroup.text, "RIGHT", 0, 0)

    local sortGroupPlayerBottom = CreateCheckbox("sortGroupPlayerBottom", "Player on Bottom", BetterBlizzFrames, nil, BBF.SortGroup)
    sortGroupPlayerBottom:SetPoint("LEFT", sortGroupPlayerTop.text, "RIGHT", 0, 0)

    sortGroupPlayerTop:HookScript("OnClick", function(self)
        if self:GetChecked() then
            sortGroupPlayerBottom:SetChecked(false)
            BetterBlizzFramesDB.sortGroupPlayerBottom = false
        end
    end)

    sortGroupPlayerBottom:HookScript("OnClick", function(self)
        if self:GetChecked() then
            sortGroupPlayerTop:SetChecked(false)
            BetterBlizzFramesDB.sortGroupPlayerTop = false
        end
    end)

    sortGroup:HookScript("OnClick", function(self)
        if self:GetChecked() then
            sortGroupPlayerTop:Enable()
            sortGroupPlayerTop:SetAlpha(1)
            sortGroupPlayerBottom:Enable()
            sortGroupPlayerBottom:SetAlpha(1)
        else
            sortGroupPlayerTop:Disable()
            sortGroupPlayerTop:SetAlpha(0)
            sortGroupPlayerBottom:Disable()
            sortGroupPlayerBottom:SetAlpha(0)
        end
    end)
    if not BetterBlizzFramesDB.sortGroup then
        sortGroupPlayerTop:SetAlpha(0)
        sortGroupPlayerBottom:SetAlpha(0)
    end

]=]


    local hidePartyFramesInArena = CreateCheckbox("hidePartyFramesInArena", "Hide Party in Arena (GEX)", BetterBlizzFrames, nil, BBF.HidePartyInArena)
    hidePartyFramesInArena:SetPoint("TOPLEFT", showPartyCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePartyFramesInArena, "Hide Party Frames in Arena. Made with GladiusEx Party Frames in mind.")

    local hidePartyNames = CreateCheckbox("hidePartyNames", "Hide Names", BetterBlizzFrames)
    hidePartyNames:SetPoint("TOPLEFT", hidePartyFramesInArena, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hidePartyNames:HookScript("OnClick", function(self)
        for i = 1, 5 do
            local frame = _G["CompactPartyFrameMember" .. i]
            if frame then
                local nameFrame = frame.name
                if nameFrame then
                    if self:GetChecked() then
                        nameFrame:SetAlpha(0)
                        if frame.cleanName then
                            frame.cleanName:SetAlpha(0)
                        end
                    else
                        if frame.cleanName then
                            frame.cleanName:SetAlpha(1)
                        else
                            nameFrame:SetAlpha(1)
                        end
                    end
                end
            end
        end
    end)

    local hidePartyAggroHighlight = CreateCheckbox("hidePartyAggroHighlight", "Hide Aggro Highlight", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePartyAggroHighlight:SetPoint("LEFT", hidePartyNames.text, "RIGHT", 0, 0)
    CreateTooltip(hidePartyAggroHighlight, "Hide the Aggro Highlight border around each party frame.")

    local hidePartyRoles = CreateCheckbox("hidePartyRoles", "Hide Role Icons", BetterBlizzFrames)
    hidePartyRoles:SetPoint("TOPLEFT", hidePartyNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hidePartyRoles:HookScript("OnClick", function()
        BBF.OnUpdateName()
        BBF.PartyNameChange()
    end)
    CreateTooltip(hidePartyRoles, "Hide the role icons from party frame|A:roleicon-tiny-dps:22:22|a|A:spec-role-dps:22:22|a")

    -- local hidePartyMaxHpReduction = CreateCheckbox("hidePartyMaxHpReduction", "Hide Reduced HP", BetterBlizzFrames, nil, BBF.HideFrames)
    -- hidePartyMaxHpReduction:SetPoint("LEFT", hidePartyRoles.text, "RIGHT", 0, 0)
    -- CreateTooltipTwo(hidePartyMaxHpReduction, "Hide Reduced HP", "Hide the new max health loss indication introduced in TWW from party frames.")

    local hidePartyFrameTitle = CreateCheckbox("hidePartyFrameTitle", "Hide CompactPartyFrame Title", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePartyFrameTitle:SetPoint("TOPLEFT", hidePartyRoles, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePartyFrameTitle, "Hide the \"Party\" text above \"Raid-Style\" Party Frames.")

    local hideRaidFrameManager = CreateCheckbox("hideRaidFrameManager", "Hide RaidFrameManager", BetterBlizzFrames, nil, BBF.HideFrames)
    hideRaidFrameManager:SetPoint("TOPLEFT", hidePartyFrameTitle, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideRaidFrameManager, "Hide the CompactRaidFrameManager. Can still be shown with mouseover.")











    local targetFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 250, -173)
    targetFrameText:SetText("Target Frame")
    local targetFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    targetFrameIcon:SetAtlas("groupfinder-icon-friend")
    targetFrameIcon:SetSize(28, 28)
    targetFrameIcon:SetPoint("RIGHT", targetFrameText, "LEFT", -3, 0)
    targetFrameIcon:SetDesaturated(1)
    targetFrameIcon:SetVertexColor(1, 0, 0)

    local targetFrameClickthrough = CreateCheckbox("targetFrameClickthrough", "Clickthrough", BetterBlizzFrames, nil, BBF.ClickthroughFrames)
    targetFrameClickthrough:SetPoint("TOPLEFT", targetFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltip(targetFrameClickthrough, "Makes the TargetFrame clickthrough.\nYou can still hold shift to left/right click it\nwhile out of combat for trade/inspect etc.\n\nNOTE: You will NOT be able to click the frame\nat all during combat with this setting on.")

    local hideTargetName = CreateCheckbox("hideTargetName", "Hide Name", BetterBlizzFrames, nil, BBF.UpdateNameSettings)
    hideTargetName:SetPoint("TOPLEFT", targetFrameClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetName, "Hide the name of the target\n\nWill still show arena names if enabled.")
    hideTargetName:HookScript("OnClick", function(self)
        -- if self:GetChecked() then
        --     TargetFrame.name:SetAlpha(0)
        --     if TargetFrame.cleanName then
        --         TargetFrame.cleanName:SetAlpha(0)
        --     end
        -- else
        --     TargetFrame.name:SetAlpha(0)
        --     if TargetFrame.cleanName then
        --         TargetFrame.cleanName:SetAlpha(1)
        --     else
        --         TargetFrame.name:SetAlpha(1)
        --     end
        -- end
        BBF.AllCaller()
    end)

    -- local hideTargetMaxHpReduction = CreateCheckbox("hideTargetMaxHpReduction", "Hide Reduced HP", BetterBlizzFrames, nil, BBF.HideFrames)
    -- hideTargetMaxHpReduction:SetPoint("LEFT", hideTargetName.text, "RIGHT", 0, 0)
    -- CreateTooltipTwo(hideTargetMaxHpReduction, "Hide Reduced HP", "Hide the new max health loss indication introduced in TWW from TargetFrame.")

    local hideTargetLeaderIcon = CreateCheckbox("hideTargetLeaderIcon", "Hide Leader Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hideTargetLeaderIcon:SetPoint("TOPLEFT", hideTargetName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetLeaderIcon, "Hide the party leader icon from Target.|A:UI-HUD-UnitFrame-Player-Group-LeaderIcon:22:22|a")

    local classColorTargetReputationTexture = CreateCheckbox("classColorTargetReputationTexture", "Reputation Class Color", BetterBlizzFrames)
    classColorTargetReputationTexture:SetPoint("TOPLEFT", hideTargetLeaderIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classColorTargetReputationTexture, "Use class colors instead of the reputation color for Target. |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")
    classColorTargetReputationTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBF.ClassColorReputation(TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, "target")
        else
            BBF.ResetClassColorReputation(TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, "target")
        end
    end)

    local hideTargetReputationColor = CreateCheckbox("hideTargetReputationColor", "Hide Reputation Color", BetterBlizzFrames, nil, BBF.HideFrames)
    hideTargetReputationColor:SetPoint("TOPLEFT", classColorTargetReputationTexture, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetReputationColor, "Hide the color behind Target name. |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")






    local targetToTFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetToTFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 250, -298)
    targetToTFrameText:SetText("Target of Target")
    local targetToTFrameIcon = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    targetToTFrameIcon:SetAtlas("groupfinder-icon-friend")
    targetToTFrameIcon:SetSize(28, 28)
    targetToTFrameIcon:SetPoint("RIGHT", targetToTFrameText, "LEFT", -3, 0)
    targetToTFrameIcon:SetDesaturated(1)
    targetToTFrameIcon:SetVertexColor(1, 0, 0)
    local targetToTFrameIcon2 = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    targetToTFrameIcon2:SetAtlas("TargetCrosshairs")
    targetToTFrameIcon2:SetSize(28, 28)
    targetToTFrameIcon2:SetPoint("TOPLEFT", targetToTFrameIcon, "TOPLEFT", 11, -13)

    local hideTargetToT = CreateCheckbox("hideTargetToT", "Hide Frame", BetterBlizzFrames, nil, BBF.HideFrames)
    hideTargetToT:SetPoint("TOPLEFT", targetToTFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)

    local hideTargetToTName = CreateCheckbox("hideTargetToTName", "Hide Name", BetterBlizzFrames)
    hideTargetToTName:SetPoint("LEFT", hideTargetToT.Text, "RIGHT", 0, 0)
    hideTargetToTName:HookScript("OnClick", function(self)
        if self:GetChecked() then
            TargetFrame.totFrame.Name:SetAlpha(0)
            if TargetFrame.totFrame.cleanName then
                TargetFrame.totFrame.cleanName:SetAlpha(0)
            end
        else
            TargetFrame.totFrame.Name:SetAlpha(0)
            if TargetFrame.totFrame.cleanName then
                TargetFrame.totFrame.cleanName:SetAlpha(1)
            end
        end
    end)

    local hideTargetToTDebuffs = CreateCheckbox("hideTargetToTDebuffs", "Hide ToT Debuffs", BetterBlizzFrames, nil, BBF.HideFrames)
    hideTargetToTDebuffs:SetPoint("TOPLEFT", hideTargetToT, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideTargetToTDebuffs, "Hide the 4 small debuff icons to the right of ToT frame.")

    local targetToTScale = CreateSlider(BetterBlizzFrames, "Size", 0.6, 2.5, 0.01, "targetToTScale", nil, 120)
    targetToTScale:SetPoint("TOPLEFT", targetToTFrameText, "BOTTOMLEFT", 0, -55)
    CreateTooltip(targetToTScale, "Target of target size.\n\nYou can right-click sliders to enter a specific value.")

    BBF.targetToTXPos = CreateSlider(BetterBlizzFrames, "x offset", -100, 100, 1, "targetToTXPos", "X", 120)
    BBF.targetToTXPos:SetPoint("TOP", targetToTScale, "BOTTOM", 0, -15)
    CreateTooltip(BBF.targetToTXPos, "Target of target x offset.\n\nYou can right-click sliders to enter a specific value.")

    local targetToTYPos = CreateSlider(BetterBlizzFrames, "y offset", -100, 100, 1, "targetToTYPos", "Y", 120)
    targetToTYPos:SetPoint("TOP", BBF.targetToTXPos, "BOTTOM", 0, -15)
    CreateTooltip(targetToTYPos, "Target of target y offset.\n\nYou can right-click sliders to enter a specific value.")




    local chatFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    chatFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 250, -455)
    chatFrameText:SetText("Chat Frame")
    local chatFrameIcon = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    chatFrameIcon:SetAtlas("transmog-icon-chat")
    chatFrameIcon:SetSize(18, 16)
    chatFrameIcon:SetPoint("RIGHT", chatFrameText, "LEFT", -3, 0)

    local hideChatButtons = CreateCheckbox("hideChatButtons", "Hide Chat Buttons", BetterBlizzFrames, nil, BBF.HideFrames)
    hideChatButtons:SetPoint("TOPLEFT", chatFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltip(hideChatButtons, "Hide the chat buttons. Can still be shown with mouseover.")

    local chatFrameFilters = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    chatFrameFilters:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 250, -495)
    chatFrameFilters:SetText("Filters")

    local filterGladiusSpam = CreateCheckbox("filterGladiusSpam", "Gladius Spam", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterGladiusSpam:SetPoint("TOPLEFT", hideChatButtons, "BOTTOMLEFT", 0, -10)
    CreateTooltip(filterGladiusSpam, "Filter out Gladius \"LOW HEALTH\" spam from chat.")

    local filterNpcArenaSpam = CreateCheckbox("filterNpcArenaSpam", "Arena Npc Talk", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterNpcArenaSpam:SetPoint("LEFT", filterGladiusSpam.text, "RIGHT", 0, 0)
    CreateTooltip(filterNpcArenaSpam, "Filter out npc chat messages like \"Get in there and fight, stop hiding!\"\nfrom chat during arena.")

    local filterTalentSpam = CreateCheckbox("filterTalentSpam", "Talent Spam", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterTalentSpam:SetPoint("TOPLEFT", filterGladiusSpam, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(filterTalentSpam, "Filter out \"You have learned/unlearned\" spam from chat.\nEspecially annoying during respec.")

    local filterEmoteSpam = CreateCheckbox("filterEmoteSpam", "Emote Spam", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterEmoteSpam:SetPoint("TOPLEFT", filterTalentSpam, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(filterEmoteSpam, "Filter out \"yells at his/her team members.\" and\n\"makes some strange gestures.\" from chat.")

    local filterSystemMessages = CreateCheckbox("filterSystemMessages", "System Messages", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterSystemMessages:SetPoint("TOPLEFT", filterNpcArenaSpam, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(filterSystemMessages, "Filter out a few excessive system messages. Some examples:\n\"You have joined the queue for Arena Skirmish\"\n\"Your group has been disbanded.\"\n\"You have been awarded x currency\"\n\"You are in both a party and an instance group.\"\n\nFull lists in modules\\chatFrame.lua")

    local filterMiscInfo = CreateCheckbox("filterMiscInfo", "Misc Info", BetterBlizzFrames, nil, BBF.ChatFilterCaller)
    filterMiscInfo:SetPoint("TOPLEFT", filterSystemMessages, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(filterMiscInfo, "Filter out \"Your equipped items suffer a durability loss\" message.")

    local arenaNamesText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arenaNamesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, -91)
    arenaNamesText:SetText("Arena Names")
    CreateTooltip(arenaNamesText, "Change player names into spec/arena id instead during arena", "ANCHOR_LEFT")
    local arenaNamesIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    arenaNamesIcon:SetAtlas("questbonusobjective")
    arenaNamesIcon:SetSize(24, 24)
    arenaNamesIcon:SetPoint("RIGHT", arenaNamesText, "LEFT", -3, 0)

    local targetAndFocusArenaNames = CreateCheckbox("targetAndFocusArenaNames", "Target & Focus", BetterBlizzFrames)
    targetAndFocusArenaNames:SetPoint("TOPLEFT", arenaNamesText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltipTwo(targetAndFocusArenaNames, "Arena Names","Change Target & Focus name to arena ID and/or spec name during arena", "Will enable a fake name. Because of this other addons like HealthBarColor's name stuff will not work properly.", "ANCHOR_LEFT")

    local partyArenaNames = CreateCheckbox("partyArenaNames", "Party", BetterBlizzFrames)
    partyArenaNames:SetPoint("LEFT", targetAndFocusArenaNames.text, "RIGHT", 0, 0)
    CreateTooltipTwo(partyArenaNames, "Arena Names", "Change party frame names to party ID and/or spec name during arena","Will enable a fake name. Because of this other addons like HealthBarColor's name stuff will not work properly.", "ANCHOR_LEFT")

    local showSpecName = CreateCheckbox("showSpecName", "Show Spec Name", BetterBlizzFrames)
    showSpecName:SetPoint("TOPLEFT", targetAndFocusArenaNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showSpecName, "Show spec name instead of name\n\nIf both spec name and arena id is selected\nit will display as for instance \"Fury 3\"")

    local shortArenaSpecName = CreateCheckbox("shortArenaSpecName", "Short", BetterBlizzFrames)
    shortArenaSpecName:SetPoint("LEFT", showSpecName.Text, "RIGHT", 0, 0)
    CreateTooltip(shortArenaSpecName, "Enable to use abbreviated specialization names.\nFor instance, \"Assassination\" will be displayed as \"Assa\".", "ANCHOR_LEFT")

    local showArenaID = CreateCheckbox("showArenaID", "Show Arena/Party ID", BetterBlizzFrames)
    showArenaID:SetPoint("TOPLEFT", showSpecName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showArenaID, "Show arena/party id instead of name\n\nIf both spec name and arena id is selected\nit will display as for instance \"Fury 3\"")

    local function ToggleDependentCheckboxes()
        local enable = targetAndFocusArenaNames:GetChecked() or partyArenaNames:GetChecked()

        if enable then
            EnableElement(showSpecName)
            EnableElement(shortArenaSpecName)
            EnableElement(showArenaID)
        else
            DisableElement(showSpecName)
            DisableElement(shortArenaSpecName)
            DisableElement(showArenaID)
        end
    end
    -- Initial setup to ensure correct state upon UI load/reload
    ToggleDependentCheckboxes()
    -- Hook into the OnClick event of targetAndFocusArenaNames
    targetAndFocusArenaNames:HookScript("OnClick", ToggleDependentCheckboxes)
    -- Hook into the OnClick event of partyArenaNames
    partyArenaNames:HookScript("OnClick", ToggleDependentCheckboxes)

    local focusFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    focusFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, -173)
    focusFrameText:SetText("Focus Frame")
    local focusFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    focusFrameIcon:SetAtlas("groupfinder-icon-friend")
    focusFrameIcon:SetSize(28, 28)
    focusFrameIcon:SetPoint("RIGHT", focusFrameText, "LEFT", -3, 0)
    focusFrameIcon:SetDesaturated(1)
    focusFrameIcon:SetVertexColor(0, 1, 0)

    local focusFrameClickthrough = CreateCheckbox("focusFrameClickthrough", "Clickthrough", BetterBlizzFrames, nil, BBF.ClickthroughFrames)
    focusFrameClickthrough:SetPoint("TOPLEFT", focusFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltip(focusFrameClickthrough, "Makes the FocusFrame clickthrough.\nYou can still hold shift to left/right click it\nwhile out of combat for trade/inspect etc.\n\nNOTE: You will NOT be able to click the frame\nat all during combat with this setting on.")

    local hideFocusName = CreateCheckbox("hideFocusName", "Hide Name", BetterBlizzFrames, nil, BBF.UpdateNameSettings)
    hideFocusName:SetPoint("TOPLEFT", focusFrameClickthrough, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideFocusName, "Hide the name of the focus\n\nWill still show arena names if enabled.")
    hideFocusName:HookScript("OnClick", function(self)
        -- if self:GetChecked() then
        --     FocusFrame.name:SetAlpha(0)
        --     if FocusFrame.cleanName then
        --         FocusFrame.cleanName:SetAlpha(0)
        --     end
        -- else
        --     FocusFrame.name:SetAlpha(0)
        --     if FocusFrame.cleanName then
        --         FocusFrame.cleanName:SetAlpha(1)
        --     else
        --         FocusFrame.name:SetAlpha(1)
        --     end
        -- end
        BBF.AllCaller()
    end)

    -- local hideFocusMaxHpReduction = CreateCheckbox("hideFocusMaxHpReduction", "Hide Reduced HP", BetterBlizzFrames, nil, BBF.HideFrames)
    -- hideFocusMaxHpReduction:SetPoint("LEFT", hideFocusName.text, "RIGHT", 0, 0)
    -- CreateTooltipTwo(hideFocusMaxHpReduction, "Hide Reduced HP", "Hide the new max health loss indication introduced in TWW from FocusFrame.")

    local hideFocusLeaderIcon = CreateCheckbox("hideFocusLeaderIcon", "Hide Leader Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hideFocusLeaderIcon:SetPoint("TOPLEFT", hideFocusName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideFocusLeaderIcon, "Hide the party leader icon from Focus.|A:UI-HUD-UnitFrame-Player-Group-LeaderIcon:22:22|a")

    local classColorFocusReputationTexture = CreateCheckbox("classColorFocusReputationTexture", "Reputation Class Color", BetterBlizzFrames)
    classColorFocusReputationTexture:SetPoint("TOPLEFT", hideFocusLeaderIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(classColorFocusReputationTexture, "Use class colors instead of the reputation color for Focus. |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")
    classColorFocusReputationTexture:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBF.ClassColorReputation(TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, "target")
        else
            BBF.ResetClassColorReputation(TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, "target")
        end
    end)

    local hideFocusReputationColor = CreateCheckbox("hideFocusReputationColor", "Hide Reputation Color", BetterBlizzFrames, nil, BBF.HideFrames)
    hideFocusReputationColor:SetPoint("TOPLEFT", classColorFocusReputationTexture, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideFocusReputationColor, "Hide the color behind Focus name. |A:UI-HUD-UnitFrame-Target-PortraitOn-Type:18:98|a")







    local focusToTFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    focusToTFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, -298)
    focusToTFrameText:SetText("Focus ToT")
    local focusToTFrameIcon = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    focusToTFrameIcon:SetAtlas("groupfinder-icon-friend")
    focusToTFrameIcon:SetSize(28, 28)
    focusToTFrameIcon:SetPoint("RIGHT", focusToTFrameText, "LEFT", -3, 0)
    focusToTFrameIcon:SetDesaturated(1)
    focusToTFrameIcon:SetVertexColor(0, 1, 0)
    local focusToTFrameIcon2 = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    focusToTFrameIcon2:SetAtlas("TargetCrosshairs")
    focusToTFrameIcon2:SetSize(28, 28)
    focusToTFrameIcon2:SetPoint("TOPLEFT", focusToTFrameIcon, "TOPLEFT", 11, -13)

    local hideFocusToT = CreateCheckbox("hideFocusToT", "Hide Frame", BetterBlizzFrames, nil, BBF.HideFrames)
    hideFocusToT:SetPoint("TOPLEFT", focusToTFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)

    local hideFocusToTName = CreateCheckbox("hideFocusToTName", "Hide Name", BetterBlizzFrames)
    hideFocusToTName:SetPoint("LEFT", hideFocusToT.Text, "RIGHT", 0, 0)
    hideFocusToTName:HookScript("OnClick", function(self)
        if self:GetChecked() then
            FocusFrame.totFrame.Name:SetAlpha(0)
            if FocusFrame.totFrame.cleanName then
                FocusFrame.totFrame.cleanName:SetAlpha(0)
            end
        else
            FocusFrame.totFrame.Name:SetAlpha(0)
            if FocusFrame.totFrame.cleanName then
                FocusFrame.totFrame.cleanName:SetAlpha(1)
            end
        end
    end)

    local hideFocusToTDebuffs = CreateCheckbox("hideFocusToTDebuffs", "Hide FocusToT Debuffs", BetterBlizzFrames, nil, BBF.HideFrames)
    hideFocusToTDebuffs:SetPoint("TOPLEFT", hideFocusToT, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideFocusToTDebuffs, "Hide the 4 small debuff icons to the right of ToT frame.")

    local focusToTScale = CreateSlider(BetterBlizzFrames, "Size", 0.6, 2.5, 0.01, "focusToTScale", nil, 120)
    focusToTScale:SetPoint("TOPLEFT", focusToTFrameText, "BOTTOMLEFT", 0, -55)
    CreateTooltip(focusToTScale, "Focus target of target size.\n\nYou can right-click sliders to enter a specific value.")

    BBF.focusToTXPos = CreateSlider(BetterBlizzFrames, "x offset", -100, 100, 1, "focusToTXPos", "X", 120)
    BBF.focusToTXPos:SetPoint("TOP", focusToTScale, "BOTTOM", 0, -15)
    CreateTooltip(BBF.focusToTXPos, "Focus target of target x offset.\n\nYou can right-click sliders to enter a specific value.")

    local focusToTYPos = CreateSlider(BetterBlizzFrames, "y offset", -100, 100, 1, "focusToTYPos", "Y", 120)
    focusToTYPos:SetPoint("TOP", BBF.focusToTXPos, "BOTTOM", 0, -15)
    CreateTooltip(focusToTYPos, "Focus target of target y offset.\n\nYou can right-click sliders to enter a specific value.")





    local allFrameText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    allFrameText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 250, 30)
    allFrameText:SetText("All Frames")
    local allFrameIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    allFrameIcon:SetAtlas("groupfinder-icon-friend")
    allFrameIcon:SetSize(25, 25)
    allFrameIcon:SetPoint("RIGHT", allFrameText, "LEFT", -4, -1)
    local allFrameIcon2 = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    allFrameIcon2:SetAtlas("groupfinder-icon-friend")
    allFrameIcon2:SetSize(20, 20)
    allFrameIcon2:SetPoint("RIGHT", allFrameText, "LEFT", 0, 4)
    allFrameIcon2:SetDesaturated(1)
    allFrameIcon2:SetVertexColor(0, 1, 0)
    local allFrameIcon3 = BetterBlizzFrames:CreateTexture(nil, "BORDER")
    allFrameIcon3:SetAtlas("groupfinder-icon-friend")
    allFrameIcon3:SetSize(20, 20)
    allFrameIcon3:SetPoint("RIGHT", allFrameText, "LEFT", -12, 4)
    allFrameIcon3:SetDesaturated(1)
    allFrameIcon3:SetVertexColor(1, 0, 0)

    local classColorFrames = CreateCheckbox("classColorFrames", "Class Color Frames", BetterBlizzFrames)
    classColorFrames:SetPoint("TOPLEFT", allFrameText, "BOTTOMLEFT", -4, pixelsOnFirstBox)

    local classColorFramesSkipPlayer = CreateCheckbox("classColorFramesSkipPlayer", "Skip Self", BetterBlizzFrames)
    classColorFramesSkipPlayer:SetPoint("LEFT", classColorFrames.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(classColorFramesSkipPlayer, "Skip Self", "Skip PlayerFrame healthbar coloring and leave it default green.")
    classColorFramesSkipPlayer:HookScript("OnClick", function(self)
        if self:GetChecked() then
            PlayerFrame.healthbar:SetStatusBarDesaturated(false)
            PlayerFrame.healthbar:SetStatusBarColor(1, 1, 1)
        else
            BBF.updateFrameColorToggleVer(PlayerFrame.healthbar, "player")
            if CfPlayerFrameHealthBar then
                BBF.updateFrameColorToggleVer(CfPlayerFrameHealthBar, "player")
            end
        end
    end)

    classColorFrames:HookScript("OnClick", function (self)
        local function UpdateCVar()
            if not InCombatLockdown() then
                if BetterBlizzFramesDB.classColorFrames then
                    SetCVar("raidFramesDisplayClassColor", 1)
                end
            else
                C_Timer.After(1, function()
                    UpdateCVar()
                end)
            end
        end
        UpdateCVar()
        BBF.UpdateFrames()
        if self:GetChecked() then
            classColorFramesSkipPlayer:Show()
        else
            classColorFramesSkipPlayer:Hide()
        end
    end)
    CreateTooltipTwo(classColorFrames, "Class Color Healthbars", "Class color Player, Target, Focus & Party frames.", "If you want a more I recommend the addon HealthBarColor instead of this setting.")

    if not BetterBlizzFramesDB.classColorFrames then
        classColorFramesSkipPlayer:Hide()
    end

    local classColorTargetNames = CreateCheckbox("classColorTargetNames", "Class Color Names", BetterBlizzFrames)
    classColorTargetNames:SetPoint("TOPLEFT", classColorFrames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(classColorTargetNames, "Class Color Names","Class color Player, Target & Focus Names.", "Will enable a fake name. Because of this other addons like HealthBarColor's name stuff will not work properly.")

    local classColorLevelText = CreateCheckbox("classColorLevelText", "Level", classColorTargetNames)
    classColorLevelText:SetPoint("LEFT", classColorTargetNames.text, "RIGHT", 0, 0)
    CreateTooltip(classColorLevelText, "Also class color the level text.")

    classColorTargetNames:HookScript("OnClick", function(self)
        if self:GetChecked() then
            classColorLevelText:Enable()
            classColorLevelText:SetAlpha(1)
            local function SetTextColorBasedOnClass(unitFrame, unit)
                if unitFrame and unitFrame.name and UnitExists(unit) then
                    local _, class = UnitClass(unit)
                    if class then
                        local color = RAID_CLASS_COLORS[class]
                        unitFrame.name:SetTextColor(color.r, color.g, color.b)
                    end
                end
            end

            -- Set text color for main frames
            SetTextColorBasedOnClass(TargetFrame, "target")
            SetTextColorBasedOnClass(PlayerFrame, "player")
            SetTextColorBasedOnClass(FocusFrame, "focus")

            -- Function to set text color for ToT frames
            local function SetToTTextColorBasedOnClass(totFrame, unit)
                if totFrame and totFrame.Name and UnitExists(unit) then
                    local _, class = UnitClass(unit)
                    if class then
                        local color = RAID_CLASS_COLORS[class]
                        totFrame.Name:SetTextColor(color.r, color.g, color.b)
                    end
                end
            end

            -- Set text color for ToT frames
            SetToTTextColorBasedOnClass(TargetFrame.totFrame, "targettarget")
            SetToTTextColorBasedOnClass(FocusFrame.totFrame, "focustarget")
        else
            classColorLevelText:Disable()
            classColorLevelText:SetAlpha(0)
            if TargetFrame and TargetFrame.name then TargetFrame.name:SetTextColor(1, 0.81960791349411, 0) end
            if PlayerFrame and PlayerFrame.name then PlayerFrame.name:SetTextColor(1, 0.81960791349411, 0) end
            if FocusFrame and FocusFrame.name then FocusFrame.name:SetTextColor(1, 0.81960791349411, 0) end
            if TargetFrame.totFrame and TargetFrame.totFrame.Name then TargetFrame.totFrame.Name:SetTextColor(1, 0.81960791349411, 0) end
            if FocusFrame.totFrame and FocusFrame.totFrame.Name then FocusFrame.totFrame.Name:SetTextColor(1, 0.81960791349411, 0) end
        end
    end)
    if not BetterBlizzFramesDB.classColorTargetNames then
        classColorLevelText:SetAlpha(0)
    end

    local centerNames = CreateCheckbox("centerNames", "Center Name", BetterBlizzFrames, nil, BBF.SetCenteredNamesCaller)
    centerNames:SetPoint("TOPLEFT", classColorTargetNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(centerNames, "Center Names", "Center the name on Player, Target & Focus frames.", "Will enable a fake name. Because of this other addons like HealthBarColor's name stuff will not work properly.")
    centerNames:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local removeRealmNames = CreateCheckbox("removeRealmNames", "Hide Realm Name", BetterBlizzFrames)
    removeRealmNames:SetPoint("TOPLEFT", centerNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    removeRealmNames:HookScript("OnClick", function()
        --StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)
    CreateTooltipTwo(removeRealmNames, "Hide Realm Indicator", "Hide realm name and different realm indicator \"(*)\" from Target, Focus & Party frames.", "Will enable a fake name. Because of this other addons like HealthBarColor's name stuff will not work properly.")

    local hidePrestigeBadge = CreateCheckbox("hidePrestigeBadge", "Hide Prestige Badge", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePrestigeBadge:SetPoint("TOPLEFT", removeRealmNames, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePrestigeBadge, "Hide the Prestige/Honor level icon from Player, Target & Focus frames. |A:honorsystem-portrait-alliance:40:42|a |A:honorsystem-portrait-horde:40:42|a |A:honorsystem-portrait-neutral:40:42|a")

    local hideCombatGlow = CreateCheckbox("hideCombatGlow", "Hide Combat Glow", BetterBlizzFrames, nil, BBF.HideFrames)
    hideCombatGlow:SetPoint("TOPLEFT", hidePrestigeBadge, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideCombatGlow, "Hide the red combat around Player, Target & Focus.|A:UI-HUD-UnitFrame-Player-PortraitOn-InCombat:30:80|a")

    local hideLevelText = CreateCheckbox("hideLevelText", "Hide Level 80 Text", BetterBlizzFrames, nil, BBF.HideFrames)
    hideLevelText:SetPoint("TOPLEFT", hideCombatGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideLevelText, "Hide the level text for Player, Target & Focus frames if they are level 80")

    local hideLevelTextAlways = CreateCheckbox("hideLevelTextAlways", "Always", BetterBlizzFrames, nil, BBF.HideFrames)
    hideLevelTextAlways:SetPoint("LEFT", hideLevelText.Text, "RIGHT", 0, 0)
    CreateTooltip(hideLevelTextAlways, "Always hide the level text.")

    hideLevelText:HookScript("OnClick", function(self)
        if self:GetChecked() then
            hideLevelTextAlways:Enable()
            hideLevelTextAlways:Show()
        else
            hideLevelTextAlways:Disable()
            hideLevelTextAlways:Hide()
        end
    end)

    if not BetterBlizzFramesDB.hideLevelText then
        hideLevelTextAlways:Hide()
        hideLevelTextAlways:Disable()
    end

    local hidePvpIcon = CreateCheckbox("hidePvpIcon", "Hide PvP Icon", BetterBlizzFrames, nil, BBF.HideFrames)
    hidePvpIcon:SetPoint("TOPLEFT", hideLevelText, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hidePvpIcon, "Hide PvP Icon on Player, Target & Focus|A:UI-HUD-UnitFrame-Player-PVP-FFAIcon:44:28|a")

    local hideRareDragonTexture = CreateCheckbox("hideRareDragonTexture", "Hide Dragon", BetterBlizzFrames, nil, BBF.HideFrames)
    hideRareDragonTexture:SetPoint("TOPLEFT", hidePvpIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideRareDragonTexture, "Hide Elite Dragon texture on Target & Focus|A:UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold:38:28|a")

    local hideThreatOnFrame = CreateCheckbox("hideThreatOnFrame", "Hide Threat", BetterBlizzFrames, nil, BBF.HideFrames)
    hideThreatOnFrame:SetPoint("LEFT", hideRareDragonTexture.Text, "RIGHT", 0, 0)
    CreateTooltipTwo(hideThreatOnFrame, "Hide Threat Meter", "Hide the threat meter displaying on Target & Focus frames.")

    local extraFeaturesText = BetterBlizzFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    extraFeaturesText:SetPoint("TOPLEFT", mainGuiAnchor, "BOTTOMLEFT", 460, 30)
    extraFeaturesText:SetText("Extra Features")
    local extraFeaturesIcon = BetterBlizzFrames:CreateTexture(nil, "ARTWORK")
    extraFeaturesIcon:SetAtlas("Campaign-QuestLog-LoreBook")
    extraFeaturesIcon:SetSize(24, 24)
    extraFeaturesIcon:SetPoint("RIGHT", extraFeaturesText, "LEFT", -3, 0)

    local combatIndicator = CreateCheckbox("combatIndicator", "Combat Indicator", BetterBlizzFrames)
    combatIndicator:SetPoint("TOPLEFT", extraFeaturesText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    combatIndicator:HookScript("OnClick", function()
        BBF.CombatIndicatorCaller()
    end)
    CreateTooltip(combatIndicator, "Show combat status on Player, Target and Focus Frame.\nSword icon for combat, Sap icon for no combat.\nMore settings in \"Advanced Settings\"")

    local absorbIndicator = CreateCheckbox("absorbIndicator", "Absorb Indicator", BetterBlizzFrames, nil, BBF.AbsorbCaller)
    absorbIndicator:SetPoint("TOPLEFT", combatIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    absorbIndicator:HookScript("OnClick", function()
        BBF.AbsorbCaller()
    end)
    CreateTooltip(absorbIndicator, "Show absorb amount on Player, Target and Focus Frame\nMore settings in \"Advanced Settings\"")

    local racialIndicator = CreateCheckbox("racialIndicator", "PvP Racial Indicator", BetterBlizzFrames, nil, BBF.RacialIndicatorCaller)
    racialIndicator:SetPoint("TOPLEFT", absorbIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    racialIndicator:HookScript("OnClick", function()
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicator, "Show important PvP racial icons on Target/Focus Frame")

    local overShields = CreateCheckbox("overShields", "Overshields", BetterBlizzFrames)
    overShields:SetPoint("TOPLEFT", racialIndicator, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(overShields, "Expand on Blizzards unit frame absorb texture and\nshow shield amount on frames regardless if HP is full or not", "ANCHOR_LEFT")

    local overShieldsUnitFrames = CreateCheckbox("overShieldsUnitFrames", "A", BetterBlizzFrames)
    overShieldsUnitFrames:SetPoint("LEFT", overShields.text, "RIGHT", 0, 0)
    CreateTooltip(overShieldsUnitFrames, "Show Overshields on UnitFrames (Player, Target, Focus)", "ANCHOR_LEFT")
    overShieldsUnitFrames:HookScript("OnClick", function(self)
        BBF.HookOverShields()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local overShieldsCompactUnitFrames = CreateCheckbox("overShieldsCompactUnitFrames", "B", BetterBlizzFrames)
    overShieldsCompactUnitFrames:SetPoint("LEFT", overShieldsUnitFrames.text, "RIGHT", 0, 0)
    CreateTooltip(overShieldsCompactUnitFrames, "Show Overshields on Compact UnitFrames (Party, Raid)", "ANCHOR_LEFT")
    overShieldsCompactUnitFrames:HookScript("OnClick", function(self)
        BBF.HookOverShields()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    overShields:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BetterBlizzFramesDB.overShieldsCompact = true
            BetterBlizzFramesDB.overShieldsUnitFrames = true
            BBF.HookOverShields()
            overShieldsUnitFrames:SetAlpha(1)
            overShieldsUnitFrames:Enable()
            overShieldsUnitFrames:SetChecked(true)
            overShieldsCompactUnitFrames:SetAlpha(1)
            overShieldsCompactUnitFrames:Enable()
            overShieldsCompactUnitFrames:SetChecked(true)
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        else
            BetterBlizzFramesDB.overShieldsCompact = false
            BetterBlizzFramesDB.overShieldsUnitFrames = false
            overShieldsUnitFrames:SetAlpha(0)
            overShieldsUnitFrames:Disable()
            overShieldsUnitFrames:SetChecked(false)
            overShieldsCompactUnitFrames:SetAlpha(0)
            overShieldsCompactUnitFrames:Disable()
            overShieldsCompactUnitFrames:SetChecked(false)
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    if BetterBlizzFramesDB.overShields then
        overShieldsUnitFrames:SetAlpha(1)
        overShieldsUnitFrames:Enable()
        overShieldsCompactUnitFrames:SetAlpha(1)
        overShieldsCompactUnitFrames:Enable()
    else
        overShieldsUnitFrames:SetAlpha(0)
        overShieldsUnitFrames:Disable()
        overShieldsCompactUnitFrames:SetAlpha(0)
        overShieldsCompactUnitFrames:Disable()
    end

    local queueTimer = CreateCheckbox("queueTimer", "Queue Timer", BetterBlizzFrames)
    queueTimer:SetPoint("TOPLEFT", overShields, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(queueTimer, "Queue Timer", "Displays the remaining time to accept when a queue pops.", nil, "ANCHOR_LEFT")

    local queueTimerAudio = CreateCheckbox("queueTimerAudio", "SFX", queueTimer)
    queueTimerAudio:SetPoint("LEFT", queueTimer.text, "RIGHT", 0, 0)
    CreateTooltipTwo(queueTimerAudio, "Sound Effect", "Play an alarm sound when queue pops.", "(Plays with game sounds muted)", "ANCHOR_LEFT")

    local queueTimerWarning = CreateCheckbox("queueTimerWarning", "!", queueTimer)
    queueTimerWarning:SetPoint("LEFT", queueTimerAudio.text, "RIGHT", 0, 0)
    CreateTooltipTwo(queueTimerWarning, "Sound Alert!", "Warning sound if there is less than 6 seconds left to accept the queue.", "(Plays with game sounds muted)", "ANCHOR_LEFT")

    queueTimer:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
        CheckAndToggleCheckboxes(queueTimer)
    end)

    ----------------------
    -- Reload etc
    ----------------------
    local reloadUiButton = CreateFrame("Button", nil, BetterBlizzFrames, "UIPanelButtonTemplate")
    reloadUiButton:SetText("Reload UI")
    reloadUiButton:SetWidth(85)
    reloadUiButton:SetPoint("TOP", BetterBlizzFrames, "BOTTOMRIGHT", -140, -9)
    reloadUiButton:SetScript("OnClick", function()
        BetterBlizzFramesDB.reopenOptions = true
        ReloadUI()
    end)

    local nahjProfileButton = CreateFrame("Button", nil, BetterBlizzFrames, "UIPanelButtonTemplate")
    nahjProfileButton:SetText("Nahj Profile")
    nahjProfileButton:SetWidth(100)
    nahjProfileButton:SetPoint("RIGHT", reloadUiButton, "LEFT", -50, 0)
    nahjProfileButton:SetScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_NAHJ_PROFILE")
    end)
    CreateTooltipTwo(nahjProfileButton, "Nahj Profile", "Enable all of Nahj's profile settings.", "www.twitch.tv/nahj", "ANCHOR_TOP")

    local magnuszProfileButton = CreateFrame("Button", nil, BetterBlizzFrames, "UIPanelButtonTemplate")
    magnuszProfileButton:SetText("Magnusz Profile")
    magnuszProfileButton:SetWidth(120)
    magnuszProfileButton:SetPoint("RIGHT", nahjProfileButton, "LEFT", -5, 0)
    magnuszProfileButton:SetScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_MAGNUSZ_PROFILE")
    end)
    CreateTooltipTwo(magnuszProfileButton, "Magnusz Profile", "Enable all of Magnusz's profile settings.", "www.twitch.tv/magnusz", "ANCHOR_TOP")

    local resetBBFButton = CreateFrame("Button", nil, BetterBlizzFrames, "UIPanelButtonTemplate")
    resetBBFButton:SetText("Reset BetterBlizzFrames")
    resetBBFButton:SetWidth(165)
    resetBBFButton:SetPoint("RIGHT", nahjProfileButton, "LEFT", -180, 0)
    resetBBFButton:SetScript("OnClick", function()
        StaticPopup_Show("CONFIRM_RESET_BETTERBLIZZFRAMESDB")
    end)
    CreateTooltip(resetBBFButton, "Reset ALL BetterBlizzFrames settings.")
end

local function guiCastbars()

    ----------------------
    -- Advanced settings
    ----------------------
    local firstLineX = 53
    local firstLineY = -65
    local secondLineX = 222
    local secondLineY = -360
    local thirdLineX = 391
    local thirdLineY = -655
    local fourthLineX = 560

    local BetterBlizzFramesCastbars = CreateFrame("Frame")
    BetterBlizzFramesCastbars.name = "Castbars"
    BetterBlizzFramesCastbars.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(BetterBlizzFramesCastbars)
    local castbarsSubCategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, BetterBlizzFramesCastbars, BetterBlizzFramesCastbars.name, BetterBlizzFramesCastbars.name)
    castbarsSubCategory.ID = BetterBlizzFramesCastbars.name;
    CreateTitle(BetterBlizzFramesCastbars)

    local bgImg = BetterBlizzFramesCastbars:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", BetterBlizzFramesCastbars, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)





    local scrollFrame = CreateFrame("ScrollFrame", nil, BetterBlizzFramesCastbars, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(700, 612)
    scrollFrame:SetPoint("CENTER", BetterBlizzFramesCastbars, "CENTER", -20, 3)

    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(680, 520)
    scrollFrame:SetScrollChild(contentFrame)

    local mainGuiAnchor2 = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor2:SetPoint("TOPLEFT", 55, 20)
    mainGuiAnchor2:SetText(" ")

   ----------------------
    -- Party Castbars
    ----------------------
    local anchorSubPartyCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPartyCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, firstLineY)
    anchorSubPartyCastbar:SetText("Party Castbars")

    local partyCastbarBorder = CreateBorderedFrame(anchorSubPartyCastbar, 157, 386, 0, -145, contentFrame)

    local partyCastbars = contentFrame:CreateTexture(nil, "ARTWORK")
    partyCastbars:SetAtlas("ui-castingbar-filling-channel")
    partyCastbars:SetSize(110, 13)
    partyCastbars:SetPoint("BOTTOM", anchorSubPartyCastbar, "TOP", -1, 10)

    local partyCastBarScale = CreateSlider(contentFrame, "Size", 0.5, 1.9, 0.01, "partyCastBarScale")
    partyCastBarScale:SetPoint("TOP", anchorSubPartyCastbar, "BOTTOM", 0, -15)

    local partyCastBarXPos = CreateSlider(contentFrame, "x offset", -200, 200, 1, "partyCastBarXPos", "X")
    partyCastBarXPos:SetPoint("TOP", partyCastBarScale, "BOTTOM", 0, -15)

    local partyCastBarYPos = CreateSlider(contentFrame, "y offset", -200, 200, 1, "partyCastBarYPos", "Y")
    partyCastBarYPos:SetPoint("TOP", partyCastBarXPos, "BOTTOM", 0, -15)

    local partyCastBarWidth = CreateSlider(contentFrame, "Width", 20, 200, 1, "partyCastBarWidth")
    partyCastBarWidth:SetPoint("TOP", partyCastBarYPos, "BOTTOM", 0, -15)

    local partyCastBarHeight = CreateSlider(contentFrame, "Height", 5, 30, 1, "partyCastBarHeight")
    partyCastBarHeight:SetPoint("TOP", partyCastBarWidth, "BOTTOM", 0, -15)

    local partyCastBarIconScale = CreateSlider(contentFrame, "Icon Size", 0.4, 2, 0.01, "partyCastBarIconScale")
    partyCastBarIconScale:SetPoint("TOP", partyCastBarHeight, "BOTTOM", 0, -15)

    local partyCastbarIconXPos = CreateSlider(contentFrame, "Icon x offset", -50, 50, 1, "partyCastbarIconXPos")
    partyCastbarIconXPos:SetPoint("TOP", partyCastBarIconScale, "BOTTOM", 0, -15)

    local partyCastbarIconYPos = CreateSlider(contentFrame, "Icon y offset", -50, 50, 1, "partyCastbarIconYPos")
    partyCastbarIconYPos:SetPoint("TOP", partyCastbarIconXPos, "BOTTOM", 0, -15)

    local partyCastBarTestMode = CreateCheckbox("partyCastBarTestMode", "Test", contentFrame, nil, BBF.partyCastBarTestMode)
    partyCastBarTestMode:SetPoint("TOPLEFT", partyCastbarIconYPos, "BOTTOMLEFT", 10, -4)
    CreateTooltip(partyCastBarTestMode, "Need to be in party to test")

    local partyCastBarTimer = CreateCheckbox("partyCastBarTimer", "Timer", contentFrame, nil, BBF.partyCastBarTestMode)
    partyCastBarTimer:SetPoint("LEFT", partyCastBarTestMode.Text, "RIGHT", 10, 0)
    CreateTooltip(partyCastBarTimer, "Show cast timer next to the castbar.")

    local partyCastbarSelf = CreateCheckbox("partyCastbarSelf", "Self", contentFrame, nil, BBF.partyCastBarTestMode)
    partyCastbarSelf:SetPoint("TOPLEFT", partyCastBarTimer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(partyCastbarSelf, "Show castbar on party frame belonging to yourself as well.")

    local showPartyCastBarIcon = CreateCheckbox("showPartyCastBarIcon", "Icon", contentFrame, nil, BBF.partyCastBarTestMode)
    showPartyCastBarIcon:SetPoint("TOPLEFT", partyCastBarTestMode, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local resetPartyCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetPartyCastbar:SetText("Reset")
    resetPartyCastbar:SetWidth(70)
    resetPartyCastbar:SetPoint("TOP", partyCastbarBorder, "BOTTOM", 0, -2)
    resetPartyCastbar:SetScript("OnClick", function()
        partyCastBarScale:SetValue(1)
        partyCastBarIconScale:SetValue(1)
        partyCastBarXPos:SetValue(0)
        partyCastBarYPos:SetValue(0)
        partyCastbarIconXPos:SetValue(0)
        partyCastbarIconYPos:SetValue(0)
        partyCastBarWidth:SetValue(100)
        partyCastBarHeight:SetValue(12)
        partyCastBarTimer:SetChecked(true)
        BetterBlizzFramesDB.partyCastBarTimer = true
        BBF.CastBarTimerCaller()
    end)


   ----------------------
    -- Target Castbar
    ----------------------
    local anchorSubTargetCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubTargetCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, firstLineY)
    anchorSubTargetCastbar:SetText("Target Castbar")

    local targetCastbarBorder = CreateBorderedFrame(anchorSubTargetCastbar, 157, 386, 0, -145, contentFrame)

    local targetCastBar = contentFrame:CreateTexture(nil, "ARTWORK")
    targetCastBar:SetAtlas("ui-castingbar-tier1-empower-2x")
    targetCastBar:SetSize(110, 13)
    targetCastBar:SetPoint("BOTTOM", anchorSubTargetCastbar, "TOP", -1, 10)

    local targetCastBarScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "targetCastBarScale")
    targetCastBarScale:SetPoint("TOP", anchorSubTargetCastbar, "BOTTOM", 0, -15)

    local targetCastBarXPos = CreateSlider(contentFrame, "x offset", -130, 130, 1, "targetCastBarXPos", "X")
    targetCastBarXPos:SetPoint("TOP", targetCastBarScale, "BOTTOM", 0, -15)

    local targetCastBarYPos = CreateSlider(contentFrame, "y offset", -130, 130, 1, "targetCastBarYPos", "Y")
    targetCastBarYPos:SetPoint("TOP", targetCastBarXPos, "BOTTOM", 0, -15)

    local targetCastBarWidth = CreateSlider(contentFrame, "Width", 60, 220, 1, "targetCastBarWidth")
    targetCastBarWidth:SetPoint("TOP", targetCastBarYPos, "BOTTOM", 0, -15)

    local targetCastBarHeight = CreateSlider(contentFrame, "Height", 5, 30, 1, "targetCastBarHeight")
    targetCastBarHeight:SetPoint("TOP", targetCastBarWidth, "BOTTOM", 0, -15)

    local targetCastBarIconScale = CreateSlider(contentFrame, "Icon Size", 0.4, 2, 0.01, "targetCastBarIconScale")
    targetCastBarIconScale:SetPoint("TOP", targetCastBarHeight, "BOTTOM", 0, -15)

    local targetCastbarIconXPos = CreateSlider(contentFrame, "Icon x offset", -160, 160, 1, "targetCastbarIconXPos", "X")
    targetCastbarIconXPos:SetPoint("TOP", targetCastBarIconScale, "BOTTOM", 0, -15)

    local targetCastbarIconYPos = CreateSlider(contentFrame, "Icon y offset", -160, 160, 1, "targetCastbarIconYPos", "Y")
    targetCastbarIconYPos:SetPoint("TOP", targetCastbarIconXPos, "BOTTOM", 0, -15)

    local targetStaticCastbar = CreateCheckbox("targetStaticCastbar", "Static", contentFrame)
    targetStaticCastbar:SetPoint("TOPLEFT", targetCastbarIconYPos, "BOTTOMLEFT", 10, -4)
    CreateTooltip(targetStaticCastbar, "Lock the castbar in place on its frame.\nNo longer moves depending on aura amount.")

    local targetCastBarTimer = CreateCheckbox("targetCastBarTimer", "Timer", contentFrame, nil, BBF.CastBarTimerCaller)
    targetCastBarTimer:SetPoint("LEFT", targetStaticCastbar.Text, "RIGHT", 10, 0)
    CreateTooltip(targetCastBarTimer, "Show cast timer next to the castbar.")

    local targetToTCastbarAdjustment = CreateCheckbox("targetToTCastbarAdjustment", "ToT Offset", contentFrame)
    targetToTCastbarAdjustment:SetPoint("TOPLEFT", targetStaticCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(targetToTCastbarAdjustment, "Enable ToT Offset", "Makes sure the castbar is under Target ToT frame until enough auras are displayed to push it down.\nUncheck this if you have moved your ToT frame out of the way and want to have the castbar follow the bottom of the auras no matter what")

    local targetToTAdjustmentOffsetY = CreateSlider(targetToTCastbarAdjustment, "extra", -20, 50, 1, "targetToTAdjustmentOffsetY", "Y", 55)
    targetToTAdjustmentOffsetY:SetPoint("LEFT", targetToTCastbarAdjustment.text, "RIGHT", 2, -5)
    CreateTooltipTwo(targetToTAdjustmentOffsetY, "Extra Finetuning for ToT Offset", "Finetune the space between castbar and auras when ToT is showing. This extra offset is only active when the ToT frame is showing.")

    targetToTCastbarAdjustment:HookScript("OnClick", function(self)
        if self:GetChecked() then
            targetToTAdjustmentOffsetY:Enable()
            targetToTAdjustmentOffsetY:SetAlpha(1)
        else
            targetToTAdjustmentOffsetY:Disable()
            targetToTAdjustmentOffsetY:SetAlpha(0.5)
        end
    end)

    local targetDetachCastbar = CreateCheckbox("targetDetachCastbar", "Detach from frame", contentFrame)
    targetDetachCastbar:SetPoint("TOPLEFT", targetToTCastbarAdjustment, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    targetDetachCastbar:HookScript("OnClick", function(self)
        if self:GetChecked() then
            targetCastBarXPos:SetMinMaxValues(-900, 900)
            targetCastBarXPos:SetValue(0)
            targetCastBarYPos:SetMinMaxValues(-900, 900)
            targetCastBarYPos:SetValue(0)
            targetToTCastbarAdjustment:Disable()
            targetToTCastbarAdjustment:SetAlpha(0.5)
            targetToTAdjustmentOffsetY:Disable()
            targetToTAdjustmentOffsetY:SetAlpha(0.5)
            targetStaticCastbar:SetChecked(false)
            BetterBlizzFramesDB.targetStaticCastbar = false
        else
            targetCastBarXPos:SetMinMaxValues(-130, 130)
            targetCastBarXPos:SetValue(0)
            targetToTCastbarAdjustment:Enable()
            targetToTCastbarAdjustment:SetAlpha(1)
            targetToTAdjustmentOffsetY:Enable()
            targetToTAdjustmentOffsetY:SetAlpha(1)
        end
        BBF.ChangeCastbarSizes()
    end)
    CreateTooltip(targetDetachCastbar, "Detach castbar from frame and enable wider xy positioning.\nRight-click a slider to enter a specific number.")

    if BetterBlizzFramesDB.targetDetachCastbar then
        targetCastBarXPos:SetMinMaxValues(-900, 900)
        targetCastBarXPos:SetValue(0)
        targetCastBarYPos:SetMinMaxValues(-900, 900)
        targetCastBarYPos:SetValue(0)
        targetToTCastbarAdjustment:Disable()
        targetToTCastbarAdjustment:SetAlpha(0.5)
        targetToTAdjustmentOffsetY:Disable()
        targetToTAdjustmentOffsetY:SetAlpha(0.5)
        targetStaticCastbar:SetChecked(false)
        BetterBlizzFramesDB.targetStaticCastbar = false
    end
    targetStaticCastbar:HookScript("OnClick", function(self)
        if self:GetChecked() then
            targetToTCastbarAdjustment:Disable()
            targetToTCastbarAdjustment:SetAlpha(0.5)
            targetToTAdjustmentOffsetY:Disable()
            targetToTAdjustmentOffsetY:SetAlpha(0.5)
            targetDetachCastbar:SetChecked(false)
            BetterBlizzFramesDB.targetDetachCastbar = false
        else
            targetToTCastbarAdjustment:Enable()
            targetToTCastbarAdjustment:SetAlpha(1)
            targetToTAdjustmentOffsetY:Enable()
            targetToTAdjustmentOffsetY:SetAlpha(1)
        end
    end)
    if BetterBlizzFramesDB.targetStaticCastbar then
        targetToTCastbarAdjustment:Disable()
        targetToTCastbarAdjustment:SetAlpha(0.5)
        targetToTAdjustmentOffsetY:Disable()
        targetToTAdjustmentOffsetY:SetAlpha(0.5)
        targetDetachCastbar:SetChecked(false)
        BetterBlizzFramesDB.targetDetachCastbar = false
    end

    local resetTargetCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetTargetCastbar:SetText("Reset")
    resetTargetCastbar:SetWidth(70)
    resetTargetCastbar:SetPoint("TOP", targetCastbarBorder, "BOTTOM", 0, -2)
    resetTargetCastbar:SetScript("OnClick", function()
        targetCastBarScale:SetValue(1)
        targetCastBarIconScale:SetValue(1)
        targetCastBarXPos:SetValue(0)
        targetCastBarYPos:SetValue(0)
        targetCastbarIconXPos:SetValue(0)
        targetCastbarIconYPos:SetValue(0)
        targetCastBarWidth:SetValue(150)
        targetCastBarHeight:SetValue(10)
        targetCastBarTimer:SetChecked(false)
        BetterBlizzFramesDB.targetCastBarTimer = false
        targetStaticCastbar:SetChecked(false)
        BetterBlizzFramesDB.targetStaticCastbar = false
        targetDetachCastbar:SetChecked(false)
        BetterBlizzFramesDB.targetDetachCastbar = false
        targetToTCastbarAdjustment:Enable()
        targetToTCastbarAdjustment:SetAlpha(1)
        targetToTCastbarAdjustment:SetChecked(true)
        targetToTAdjustmentOffsetY:Enable()
        targetToTAdjustmentOffsetY:SetValue(0)
        BetterBlizzFramesDB.targetToTCastbarAdjustment = true
        BBF.CastBarTimerCaller()
        BBF.ChangeCastbarSizes()
    end)


    ----------------------
    -- Pet Castbars
    ----------------------
    local anchorSubPetCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPetCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, secondLineY + 5)
    anchorSubPetCastbar:SetText("Pet Castbar")

    local petCastbarBorder = CreateBorderedFrame(anchorSubPetCastbar, 157, 320, 0, -112, contentFrame)

    local petCastbars = contentFrame:CreateTexture(nil, "ARTWORK")
    petCastbars:SetAtlas("ui-castingbar-filling-channel")
    petCastbars:SetDesaturated(true)
    petCastbars:SetVertexColor(1, 0.25, 0.98)
    petCastbars:SetSize(110, 13)
    petCastbars:SetPoint("BOTTOM", anchorSubPetCastbar, "TOP", -1, 10)

    local petCastBarScale = CreateSlider(contentFrame, "Size", 0.5, 1.9, 0.01, "petCastBarScale")
    petCastBarScale:SetPoint("TOP", anchorSubPetCastbar, "BOTTOM", 0, -15)

    local petCastBarXPos = CreateSlider(contentFrame, "x offset", -200, 200, 1, "petCastBarXPos", "X")
    petCastBarXPos:SetPoint("TOP", petCastBarScale, "BOTTOM", 0, -15)

    local petCastBarYPos = CreateSlider(contentFrame, "y offset", -200, 200, 1, "petCastBarYPos", "Y")
    petCastBarYPos:SetPoint("TOP", petCastBarXPos, "BOTTOM", 0, -15)

    local petCastBarWidth = CreateSlider(contentFrame, "Width", 20, 200, 1, "petCastBarWidth")
    petCastBarWidth:SetPoint("TOP", petCastBarYPos, "BOTTOM", 0, -15)

    local petCastBarHeight = CreateSlider(contentFrame, "Height", 5, 30, 1, "petCastBarHeight")
    petCastBarHeight:SetPoint("TOP", petCastBarWidth, "BOTTOM", 0, -15)

    local petCastBarIconScale = CreateSlider(contentFrame, "Icon Size", 0.4, 2, 0.01, "petCastBarIconScale")
    petCastBarIconScale:SetPoint("TOP", petCastBarHeight, "BOTTOM", 0, -15)

    local petCastBarTestMode = CreateCheckbox("petCastBarTestMode", "Test", contentFrame, nil, BBF.petCastBarTestMode)
    petCastBarTestMode:SetPoint("TOPLEFT", petCastBarIconScale, "BOTTOMLEFT", 10, -4)
    CreateTooltip(petCastBarTestMode, "Need pet to test.")

    local petCastBarTimer = CreateCheckbox("petCastBarTimer", "Timer", contentFrame, nil, BBF.petCastBarTestMode)
    petCastBarTimer:SetPoint("LEFT", petCastBarTestMode.Text, "RIGHT", 10, 0)
    CreateTooltip(petCastBarTimer, "Show cast timer next to the castbar.")

    local showPetCastBarIcon = CreateCheckbox("showPetCastBarIcon", "Icon", contentFrame, nil, BBF.petCastBarTestMode)
    showPetCastBarIcon:SetPoint("TOPLEFT", petCastBarTestMode, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local petDetachCastbar = CreateCheckbox("petDetachCastbar", "Detach from frame", contentFrame, nil, BBF.petCastBarTestMode)
    petDetachCastbar:SetPoint("TOPLEFT", showPetCastBarIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    petDetachCastbar:HookScript("OnClick", function(self)
        if self:GetChecked() then
            petCastBarXPos:SetMinMaxValues(-900, 900)
            petCastBarXPos:SetValue(0)
            petCastBarYPos:SetMinMaxValues(-900, 900)
            petCastBarYPos:SetValue(0)
        else
            petCastBarXPos:SetMinMaxValues(-130, 130)
            petCastBarXPos:SetValue(0)
        end
        BBF.petCastBarTestMode()
        BBF.ChangeCastbarSizes()
    end)
    CreateTooltip(petDetachCastbar, "Detach castbar from frame and enable wider xy positioning.\nRight-click a slider to enter a specific number.")

    if BetterBlizzFramesDB.petDetachCastbar then
        petCastBarXPos:SetMinMaxValues(-900, 900)
        petCastBarXPos:SetValue(0)
        petCastBarYPos:SetMinMaxValues(-900, 900)
        petCastBarYPos:SetValue(0)
    end

    local resetpetCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetpetCastbar:SetText("Reset")
    resetpetCastbar:SetWidth(70)
    resetpetCastbar:SetPoint("TOP", petCastbarBorder, "BOTTOM", 0, -2)
    resetpetCastbar:SetScript("OnClick", function()
        petCastBarScale:SetValue(1)
        petCastBarIconScale:SetValue(1)
        petCastBarXPos:SetValue(0)
        petCastBarYPos:SetValue(0)
        petCastBarWidth:SetValue(100)
        petCastBarHeight:SetValue(12)
        petCastBarTimer:SetChecked(true)
        petDetachCastbar:SetChecked(false)
        BetterBlizzFramesDB.petDetachCastbar = false
        BetterBlizzFramesDB.petCastBarTimer = true
        BBF.CastBarTimerCaller()
        BBF.ChangeCastbarSizes()
    end)

   ----------------------
    -- Focus Castbar
    ----------------------
    local anchorSubFocusCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubFocusCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX, firstLineY)
    anchorSubFocusCastbar:SetText("Focus Castbar")

    local focusCastbarBorder = CreateBorderedFrame(anchorSubFocusCastbar, 157, 386, 0, -145, contentFrame)

    local focusCastBar = contentFrame:CreateTexture(nil, "ARTWORK")
    focusCastBar:SetAtlas("ui-castingbar-full-applyingcrafting")
    focusCastBar:SetSize(110, 16)
    focusCastBar:SetPoint("BOTTOM", anchorSubFocusCastbar, "TOP", -1, 8.5)

    local focusCastBarScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "focusCastBarScale")
    focusCastBarScale:SetPoint("TOP", anchorSubFocusCastbar, "BOTTOM", 0, -15)

    local focusCastBarXPos = CreateSlider(contentFrame, "x offset", -130, 130, 1, "focusCastBarXPos", "X")
    focusCastBarXPos:SetPoint("TOP", focusCastBarScale, "BOTTOM", 0, -15)

    local focusCastBarYPos = CreateSlider(contentFrame, "y offset", -130, 130, 1, "focusCastBarYPos", "Y")
    focusCastBarYPos:SetPoint("TOP", focusCastBarXPos, "BOTTOM", 0, -15)

    local focusCastBarWidth = CreateSlider(contentFrame, "Width", 60, 220, 1, "focusCastBarWidth")
    focusCastBarWidth:SetPoint("TOP", focusCastBarYPos, "BOTTOM", 0, -15)

    local focusCastBarHeight = CreateSlider(contentFrame, "Height", 5, 30, 1, "focusCastBarHeight")
    focusCastBarHeight:SetPoint("TOP", focusCastBarWidth, "BOTTOM", 0, -15)

    local focusCastBarIconScale = CreateSlider(contentFrame, "Icon Size", 0.4, 2, 0.01, "focusCastBarIconScale")
    focusCastBarIconScale:SetPoint("TOP", focusCastBarHeight, "BOTTOM", 0, -15)

    local focusCastbarIconXPos = CreateSlider(contentFrame, "Icon x offset", -160, 160, 1, "focusCastbarIconXPos", "X")
    focusCastbarIconXPos:SetPoint("TOP", focusCastBarIconScale, "BOTTOM", 0, -15)

    local focusCastbarIconYPos = CreateSlider(contentFrame, "Icon y offset", -160, 160, 1, "focusCastbarIconYPos", "Y")
    focusCastbarIconYPos:SetPoint("TOP", focusCastbarIconXPos, "BOTTOM", 0, -15)

    local focusStaticCastbar = CreateCheckbox("focusStaticCastbar", "Static", contentFrame)
    focusStaticCastbar:SetPoint("TOPLEFT", focusCastbarIconYPos, "BOTTOMLEFT", 10, -4)
    CreateTooltip(focusStaticCastbar, "Lock the castbar in place on its frame.\nNo longer moves depending on aura amount.")

    local focusCastBarTimer = CreateCheckbox("focusCastBarTimer", "Timer", contentFrame, nil, BBF.CastBarTimerCaller)
    focusCastBarTimer:SetPoint("LEFT", focusStaticCastbar.Text, "RIGHT", 10, 0)
    CreateTooltip(focusCastBarTimer, "Show cast timer next to the castbar.")

    local focusToTCastbarAdjustment = CreateCheckbox("focusToTCastbarAdjustment", "ToT Offset", contentFrame)
    focusToTCastbarAdjustment:SetPoint("TOPLEFT", focusStaticCastbar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(focusToTCastbarAdjustment, "Enable ToT Offset", "Makes sure the castbar is under Focus ToT frame until enough auras are displayed to push it down.\nUncheck this if you have moved your ToT frame out of the way and want to have the castbar follow the bottom of the auras no matter what.")

    local focusToTAdjustmentOffsetY = CreateSlider(focusToTCastbarAdjustment, "extra", -20, 50, 1, "focusToTAdjustmentOffsetY", "Y", 55)
    focusToTAdjustmentOffsetY:SetPoint("LEFT", focusToTCastbarAdjustment.text, "RIGHT", 2, -5)
    CreateTooltipTwo(focusToTAdjustmentOffsetY, "Extra Finetuning for ToT Offset", "Finetune the space between castbar and auras when ToT is showing. This extra offset is only active when the ToT frame is showing.")

    focusToTCastbarAdjustment:HookScript("OnClick", function(self)
        if self:GetChecked() then
            focusToTAdjustmentOffsetY:Enable()
            focusToTAdjustmentOffsetY:SetAlpha(1)
        else
            focusToTAdjustmentOffsetY:Disable()
            focusToTAdjustmentOffsetY:SetAlpha(0.5)
        end
    end)

    local focusDetachCastbar = CreateCheckbox("focusDetachCastbar", "Detach from frame", contentFrame)
    focusDetachCastbar:SetPoint("TOPLEFT", focusToTCastbarAdjustment, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    focusDetachCastbar:HookScript("OnClick", function(self)
        if self:GetChecked() then
            focusCastBarXPos:SetMinMaxValues(-900, 900)
            focusCastBarXPos:SetValue(0)
            focusCastBarYPos:SetMinMaxValues(-900, 900)
            focusCastBarYPos:SetValue(0)
            focusToTCastbarAdjustment:Disable()
            focusToTCastbarAdjustment:SetAlpha(0.5)
            focusToTAdjustmentOffsetY:Disable()
            focusToTAdjustmentOffsetY:SetAlpha(0.5)
            focusStaticCastbar:SetChecked(false)
            BetterBlizzFramesDB.focusStaticCastbar = false
        else
            focusCastBarXPos:SetMinMaxValues(-130, 130)
            focusCastBarXPos:SetValue(0)
            focusToTCastbarAdjustment:Enable()
            focusToTCastbarAdjustment:SetAlpha(1)
            focusToTAdjustmentOffsetY:Enable()
            focusToTAdjustmentOffsetY:SetAlpha(1)
        end
        BBF.ChangeCastbarSizes()
    end)
    CreateTooltip(focusDetachCastbar, "Detach castbar from frame and enable wider xy positioning.\nRight-click a slider to enter a specific number.")

    if BetterBlizzFramesDB.focusDetachCastbar then
        focusCastBarXPos:SetMinMaxValues(-900, 900)
        focusCastBarXPos:SetValue(0)
        focusCastBarYPos:SetMinMaxValues(-900, 900)
        focusCastBarYPos:SetValue(0)
        focusToTCastbarAdjustment:Disable()
        focusToTCastbarAdjustment:SetAlpha(0.5)
        focusToTAdjustmentOffsetY:Disable()
        focusToTAdjustmentOffsetY:SetAlpha(0.5)
        focusStaticCastbar:SetChecked(false)
        BetterBlizzFramesDB.focusStaticCastbar = false
    end
    focusStaticCastbar:HookScript("OnClick", function(self)
        if self:GetChecked() then
            focusToTCastbarAdjustment:Disable()
            focusToTCastbarAdjustment:SetAlpha(0.5)
            focusToTAdjustmentOffsetY:Disable()
            focusToTAdjustmentOffsetY:SetAlpha(0.5)
            focusDetachCastbar:SetChecked(false)
        else
            focusToTCastbarAdjustment:Enable()
            focusToTCastbarAdjustment:SetAlpha(1)
            focusToTAdjustmentOffsetY:Enable()
            focusToTAdjustmentOffsetY:SetAlpha(1)
        end
    end)
    if BetterBlizzFramesDB.focusStaticCastbar then
        focusToTCastbarAdjustment:Disable()
        focusToTCastbarAdjustment:SetAlpha(0.5)
        focusToTAdjustmentOffsetY:Disable()
        focusToTAdjustmentOffsetY:SetAlpha(0.5)
        focusDetachCastbar:SetChecked(false)
        BetterBlizzFramesDB.focusDetachCastbar = false
    end

    local resetFocusCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetFocusCastbar:SetText("Reset")
    resetFocusCastbar:SetWidth(70)
    resetFocusCastbar:SetPoint("TOP", focusCastbarBorder, "BOTTOM", 0, -2)
    resetFocusCastbar:SetScript("OnClick", function()
        focusCastBarScale:SetValue(1)
        focusCastBarIconScale:SetValue(1)
        focusCastBarXPos:SetValue(0)
        focusCastBarYPos:SetValue(0)
        focusCastbarIconXPos:SetValue(0)
        focusCastbarIconYPos:SetValue(0)
        focusCastBarWidth:SetValue(150)
        focusCastBarHeight:SetValue(10)
        focusCastBarTimer:SetChecked(false)
        BetterBlizzFramesDB.focusCastBarTimer = false
        focusStaticCastbar:SetChecked(false)
        BetterBlizzFramesDB.focusStaticCastbar = false
        focusDetachCastbar:SetChecked(false)
        BetterBlizzFramesDB.focusDetachCastbar = false
        focusToTCastbarAdjustment:Enable()
        focusToTCastbarAdjustment:SetAlpha(1)
        focusToTCastbarAdjustment:SetChecked(true)
        focusToTAdjustmentOffsetY:Enable()
        focusToTAdjustmentOffsetY:SetValue(0)
        BetterBlizzFramesDB.focusToTCastbarAdjustment = true
        BBF.CastBarTimerCaller()
        BBF.ChangeCastbarSizes()
    end)


   ----------------------
    -- Player Castbar
    ----------------------
    local anchorSubPlayerCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPlayerCastbar:SetPoint("CENTER", mainGuiAnchor2, "CENTER", firstLineX, firstLineY)
    anchorSubPlayerCastbar:SetText("Player Castbar")

    local playerCastbarBorder = CreateBorderedFrame(anchorSubPlayerCastbar, 157, 250, 0, -77, contentFrame)

    local playerCastBar = contentFrame:CreateTexture(nil, "ARTWORK")
    playerCastBar:SetAtlas("ui-castingbar-filling-standard")
    playerCastBar:SetSize(110, 13)
    playerCastBar:SetPoint("BOTTOM", anchorSubPlayerCastbar, "TOP", -1, 10)


    local playerCastBarScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "playerCastBarScale")
    playerCastBarScale:SetPoint("TOP", anchorSubPlayerCastbar, "BOTTOM", 0, -15)
--[[
    local playerCastBarXPos = CreateSlider(contentFrame, "x offset", -200, 200, 1, "playerCastBarXPos")
    playerCastBarXPos:SetPoint("TOP", playerCastBarScale, "BOTTOM", 0, -15)

    local playerCastBarYPos = CreateSlider(contentFrame, "y offset", -200, 200, 1, "playerCastBarYPos")
    playerCastBarYPos:SetPoint("TOP", playerCastBarXPos, "BOTTOM", 0, -15)

]]

    local playerCastBarIconScale = CreateSlider(contentFrame, "Icon Size", 0.4, 2, 0.01, "playerCastBarIconScale")
    playerCastBarIconScale:SetPoint("TOP", playerCastBarScale, "BOTTOM", 0, -15)

    local playerCastBarWidth = CreateSlider(contentFrame, "Width", 60, 230, 1, "playerCastBarWidth")
    --playerCastBarWidth:SetPoint("TOP", playerCastBarYPos, "BOTTOM", 0, -15)
    playerCastBarWidth:SetPoint("TOP", playerCastBarIconScale, "BOTTOM", 0, -15)

    local playerCastBarHeight = CreateSlider(contentFrame, "Height", 5, 30, 1, "playerCastBarHeight")
    playerCastBarHeight:SetPoint("TOP", playerCastBarWidth, "BOTTOM", 0, -15)

    local playerCastBarShowIcon = CreateCheckbox("playerCastBarShowIcon", "Icon", contentFrame, nil, BBF.ShowPlayerCastBarIcon)
    playerCastBarShowIcon:SetPoint("TOPLEFT", playerCastBarHeight, "BOTTOMLEFT", 10, -4)
    CreateTooltip(playerCastBarShowIcon, "Show spell icon to the left of the castbar\nlike on every other castbar in the game")

    local playerCastBarTimer = CreateCheckbox("playerCastBarTimer", "Timer", contentFrame, nil, BBF.CastBarTimerCaller)
    playerCastBarTimer:SetPoint("LEFT", playerCastBarShowIcon.Text, "RIGHT", 10, 0)
    CreateTooltip(playerCastBarTimer, "Show cast timer next to the castbar.")

    local playerCastBarTimerCentered = CreateCheckbox("playerCastBarTimerCentered", "Centered Timer", contentFrame, nil, BBF.CastBarTimerCaller)
    --playerStaticCastbar:SetPoint("TOPLEFT", playerCastBarIconScale, "BOTTOMLEFT", 10, -4)
    playerCastBarTimerCentered:SetPoint("TOPLEFT", playerCastBarShowIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(playerCastBarTimerCentered, "Center the timer in the middle of the castbar")

    local resetPlayerCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetPlayerCastbar:SetText("Reset")
    resetPlayerCastbar:SetWidth(70)
    resetPlayerCastbar:SetPoint("TOP", playerCastbarBorder, "BOTTOM", 0, -2)
    resetPlayerCastbar:SetScript("OnClick", function()
        playerCastBarScale:SetValue(1)
        playerCastBarIconScale:SetValue(1)
        playerCastBarWidth:SetValue(208)
        playerCastBarHeight:SetValue(11)
        playerCastBarShowIcon:SetChecked(false)
        playerCastBarTimer:SetChecked(false)
        playerCastBarTimerCentered:SetChecked(false)
        BetterBlizzFramesDB.playerCastBarShowIcon = false
        BetterBlizzFramesDB.playerCastBarTimer = false
        BetterBlizzFramesDB.playerStaticCastbar = false
        BetterBlizzFramesDB.playerCastBarTimerCentered = false
        --PlayerCastingBarFrame.showShield = false
        BBF.CastBarTimerCaller()
        BBF.ShowPlayerCastBarIcon()
        BBF.ChangeCastbarSizes()
    end)

    local function UpdateColorSquare(icon, r, g, b, a)
        if r and g and b and a then
            icon:SetVertexColor(r, g, b, a)
        else
            icon:SetVertexColor(r, g, b)
        end
    end

    local function OpenColorPicker(colorType, icon)
        -- Ensure originalColorData has four elements, defaulting alpha (a) to 1 if not present
        local originalColorData = BetterBlizzFramesDB[colorType] or {1, 1, 1, 1}
        if #originalColorData == 3 then
            table.insert(originalColorData, 1) -- Add default alpha value if not present
        end
        local r, g, b, a = unpack(originalColorData)

        local function updateColors()
            UpdateColorSquare(icon, r, g, b, a)
            ColorPickerFrame.Content.ColorSwatchCurrent:SetAlpha(a)
        end

        local function swatchFunc()
            r, g, b = ColorPickerFrame:GetColorRGB()
            BetterBlizzFramesDB[colorType] = {r, g, b, a}
            updateColors()
        end

        local function opacityFunc()
            a = ColorPickerFrame:GetColorAlpha()
            BetterBlizzFramesDB[colorType] = {r, g, b, a}
            updateColors()
        end

        local function cancelFunc()
            r, g, b, a = unpack(originalColorData)
            BetterBlizzFramesDB[colorType] = {r, g, b, a}
            updateColors()
        end

        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b, opacity = a, hasOpacity = true,
            swatchFunc = swatchFunc, opacityFunc = opacityFunc, cancelFunc = cancelFunc
        })
    end

    local castBarInterruptHighlighterText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    castBarInterruptHighlighterText:SetPoint("LEFT", contentFrame, "TOPRIGHT", -235, -465)
    castBarInterruptHighlighterText:SetText("Castbar Edge Highlight settings")

    local castBarInterruptHighlighter = CreateCheckbox("castBarInterruptHighlighter", "Castbar Edge Highlight", contentFrame, nil, BBF.CastbarRecolorWidgets)
    castBarInterruptHighlighter:SetPoint("TOPLEFT", castBarInterruptHighlighterText, "BOTTOMLEFT", 0, pixelsOnFirstBox)
    CreateTooltip(castBarInterruptHighlighter, "Color the start and end of the castbar differently.\nSet the percentile of cast to color down below.")

    local targetCastbarEdgeHighlight = CreateCheckbox("targetCastbarEdgeHighlight", "Target", castBarInterruptHighlighter, nil, BBF.CastbarRecolorWidgets)
    targetCastbarEdgeHighlight:SetPoint("TOPLEFT", castBarInterruptHighlighter, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(targetCastbarEdgeHighlight, "Enable for TargetFrame Castbar")

    local focusCastbarEdgeHighlight = CreateCheckbox("focusCastbarEdgeHighlight", "Focus", castBarInterruptHighlighter, nil, BBF.CastbarRecolorWidgets)
    focusCastbarEdgeHighlight:SetPoint("LEFT", targetCastbarEdgeHighlight.text, "RIGHT", 0, 0)
    CreateTooltip(focusCastbarEdgeHighlight, "Enable for FocusFrame Castbar")

    local castBarInterruptHighlighterColorDontInterrupt = CreateCheckbox("castBarInterruptHighlighterColorDontInterrupt", "Re-color between portion", castBarInterruptHighlighter, nil, BBF.CastbarRecolorWidgets)
    castBarInterruptHighlighterColorDontInterrupt:SetPoint("TOPLEFT", targetCastbarEdgeHighlight, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(castBarInterruptHighlighterColorDontInterrupt,"Re-color the middle part of the castbar between the percentages")

    local castBarInterruptHighlighterDontInterruptRGB = CreateFrame("Button", nil, castBarInterruptHighlighterColorDontInterrupt, "UIPanelButtonTemplate")
    castBarInterruptHighlighterDontInterruptRGB:SetText("Color")
    castBarInterruptHighlighterDontInterruptRGB:SetPoint("LEFT", castBarInterruptHighlighterColorDontInterrupt.text, "RIGHT", 2, 0)
    castBarInterruptHighlighterDontInterruptRGB:SetSize(50, 20)
    CreateTooltip(castBarInterruptHighlighterDontInterruptRGB, "Castbar color inbetween the start and finish")
    local castBarInterruptHighlighterDontInterruptRGBIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    castBarInterruptHighlighterDontInterruptRGBIcon:SetAtlas("newplayertutorial-icon-key")
    castBarInterruptHighlighterDontInterruptRGBIcon:SetSize(18, 17)
    castBarInterruptHighlighterDontInterruptRGBIcon:SetPoint("LEFT", castBarInterruptHighlighterDontInterruptRGB, "RIGHT", 0, -1)
    UpdateColorSquare(castBarInterruptHighlighterDontInterruptRGBIcon, unpack(BetterBlizzFramesDB["castBarInterruptHighlighterDontInterruptRGB"] or {1, 1, 1}))
    castBarInterruptHighlighterDontInterruptRGB:SetScript("OnClick", function()
        OpenColorPicker("castBarInterruptHighlighterDontInterruptRGB", castBarInterruptHighlighterDontInterruptRGBIcon)
    end)

    local castBarInterruptHighlighterStartTime = CreateSlider(castBarInterruptHighlighter, "Start Seconds", 0, 2, 0.01, "castBarInterruptHighlighterStartTime", "Height")
    castBarInterruptHighlighterStartTime:SetPoint("TOPLEFT", castBarInterruptHighlighterColorDontInterrupt, "BOTTOMLEFT", 10, -6)
    CreateTooltip(castBarInterruptHighlighterStartTime, "How many seconds of the start of the cast you want to color the castbar.")

    local castBarInterruptHighlighterEndTime = CreateSlider(castBarInterruptHighlighter, "End Seconds", 0, 2, 0.01, "castBarInterruptHighlighterEndTime", "Height")
    castBarInterruptHighlighterEndTime:SetPoint("TOPLEFT", castBarInterruptHighlighterStartTime, "BOTTOMLEFT", 0, -10)
    CreateTooltip(castBarInterruptHighlighterEndTime, "How many seconds of the end of the cast you want to color the castbar.")

    local castBarInterruptHighlighterInterruptRGB = CreateFrame("Button", nil, castBarInterruptHighlighter, "UIPanelButtonTemplate")
    castBarInterruptHighlighterInterruptRGB:SetText("Color")
    castBarInterruptHighlighterInterruptRGB:SetPoint("LEFT", castBarInterruptHighlighterEndTime, "RIGHT", 0, 15)
    castBarInterruptHighlighterInterruptRGB:SetSize(50, 20)
    CreateTooltip(castBarInterruptHighlighterInterruptRGB, "Castbar edge color")
    local castBarInterruptHighlighterInterruptRGBIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    castBarInterruptHighlighterInterruptRGBIcon:SetAtlas("newplayertutorial-icon-key")
    castBarInterruptHighlighterInterruptRGBIcon:SetSize(18, 17)
    castBarInterruptHighlighterInterruptRGBIcon:SetPoint("LEFT", castBarInterruptHighlighterInterruptRGB, "RIGHT", 0, -1)
    UpdateColorSquare(castBarInterruptHighlighterInterruptRGBIcon, unpack(BetterBlizzFramesDB["castBarInterruptHighlighterInterruptRGB"] or {1, 1, 1}))
    castBarInterruptHighlighterInterruptRGB:SetScript("OnClick", function()
        OpenColorPicker("castBarInterruptHighlighterInterruptRGB", castBarInterruptHighlighterInterruptRGBIcon)
    end)

    castBarInterruptHighlighter:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(castBarInterruptHighlighter)
        if self:GetChecked() then
            if BetterBlizzPlatesDB.castBarInterruptHighlighterColorDontInterrupt then
                castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(1)
            end
            castBarInterruptHighlighterInterruptRGBIcon:SetAlpha(1)
        else
            castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(0)
            castBarInterruptHighlighterInterruptRGBIcon:SetAlpha(0)
        end
    end)

    castBarInterruptHighlighterColorDontInterrupt:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(castBarInterruptHighlighter)
        if self:GetChecked() then
            castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(1)
        else
            castBarInterruptHighlighterDontInterruptRGBIcon:SetAlpha(0)
        end
    end)



    local castBarRecolorInterrupt = CreateCheckbox("castBarRecolorInterrupt", "Interrupt CD color", contentFrame, nil, BBF.CastbarRecolorWidgets)
    castBarRecolorInterrupt:SetPoint("LEFT", contentFrame, "TOPRIGHT", -435, -465)
    CreateTooltip(castBarRecolorInterrupt, "Checks if you have interrupt ready\nand colors Target & Focus castbar thereafter.")

    local castBarInterruptIconEnabled = CreateCheckbox("castBarInterruptIconEnabled", "Interrupt CD Icon", contentFrame, nil, BBF.UpdateInterruptIconSettings)
    castBarInterruptIconEnabled:SetPoint("BOTTOMLEFT", castBarRecolorInterrupt, "TOPLEFT", 0, -pixelsBetweenBoxes)
    CreateTooltipTwo(castBarInterruptIconEnabled, "Interrupt CD Icon", "Shows your interrupt CD next to the enemy castbars.\nMore settings in Advanced Settings", "Needs a few tweaks still for pet class interrupts etc.")

    local castBarNoInterruptColor = CreateFrame("Button", nil, castBarRecolorInterrupt, "UIPanelButtonTemplate")
    castBarNoInterruptColor:SetText("Interrupt on CD")
    castBarNoInterruptColor:SetPoint("TOPLEFT", castBarRecolorInterrupt, "BOTTOMRIGHT", -35, 3)
    castBarNoInterruptColor:SetSize(139, 20)
    CreateTooltip(castBarNoInterruptColor, "Castbar color when interrupt is on CD")
    local castBarNoInterruptColorIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    castBarNoInterruptColorIcon:SetAtlas("newplayertutorial-icon-key")
    castBarNoInterruptColorIcon:SetSize(18, 17)
    castBarNoInterruptColorIcon:SetPoint("LEFT", castBarNoInterruptColor, "RIGHT", 0, -1)
    UpdateColorSquare(castBarNoInterruptColorIcon, unpack(BetterBlizzFramesDB["castBarNoInterruptColor"] or {1, 1, 1}))
    castBarNoInterruptColor:SetScript("OnClick", function()
        OpenColorPicker("castBarNoInterruptColor", castBarNoInterruptColorIcon)
    end)

    local castBarDelayedInterruptColor = CreateFrame("Button", nil, castBarRecolorInterrupt, "UIPanelButtonTemplate")
    castBarDelayedInterruptColor:SetText("Interrupt CD soon")
    castBarDelayedInterruptColor:SetPoint("TOPLEFT", castBarNoInterruptColor, "BOTTOMLEFT", 0, -5)
    castBarDelayedInterruptColor:SetSize(139, 20)
    CreateTooltip(castBarDelayedInterruptColor, "Castbar color when interrupt is on CD but\nwill be ready before the cast ends")
    local castBarDelayedInterruptColorIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    castBarDelayedInterruptColorIcon:SetAtlas("newplayertutorial-icon-key")
    castBarDelayedInterruptColorIcon:SetSize(18, 17)
    castBarDelayedInterruptColorIcon:SetPoint("LEFT", castBarDelayedInterruptColor, "RIGHT", 0, -1)
    UpdateColorSquare(castBarDelayedInterruptColorIcon, unpack(BetterBlizzFramesDB["castBarDelayedInterruptColor"] or {1, 1, 1}))
    castBarDelayedInterruptColor:SetScript("OnClick", function()
        OpenColorPicker("castBarDelayedInterruptColor", castBarDelayedInterruptColorIcon)
    end)


    local buffsOnTopReverseCastbarMovement = CreateCheckbox("buffsOnTopReverseCastbarMovement", "Buffs on Top: Reverse Castbar Movement", contentFrame, nil, BBF.CastbarAdjustCaller)
    buffsOnTopReverseCastbarMovement:SetPoint("LEFT", contentFrame, "TOPRIGHT", -470, -545)
    CreateTooltipTwo(buffsOnTopReverseCastbarMovement, "Buffs on Top: Reverse Castbar Movement", "Changes the castbar movement to follow the top row of auras on Target/Focus Frame similar to how it works by default without \"Buffs on Top\" enabled except in reverse.\n\nBy default with Buffs on Top enabled your castbar will just sit beneath the target frame and not move.")

    local normalCastbarForEmpoweredCasts = CreateCheckbox("normalCastbarForEmpoweredCasts", "Normal Evoker Empowered Castbar", contentFrame, nil, BBF.HookCastbarsForEvoker)
    normalCastbarForEmpoweredCasts:SetPoint("TOPLEFT", buffsOnTopReverseCastbarMovement, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(normalCastbarForEmpoweredCasts, "Normal Evoker Castbar", "Change Evoker empowered castbars to look like normal ones.\n(Easier to see if you can interrupt)")

    local quickHideCastbars = CreateCheckbox("quickHideCastbars", "Quick Hide Castbars", contentFrame)
    quickHideCastbars:SetPoint("TOPLEFT", normalCastbarForEmpoweredCasts, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(quickHideCastbars, "Quick Hide Castbars", "Instantly hide target and focus castbars after their cast is finished or interrupted.\nBy default there is a slow fade out animation.")
    quickHideCastbars:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)
end

local function guiPositionAndScale()

    ----------------------
    -- Advanced settings
    ----------------------
    local firstLineX = 53
    local firstLineY = -65
    local secondLineX = 222
    local secondLineY = -360
    local thirdLineX = 391
    local thirdLineY = -655
    local fourthLineX = 560

    local BetterBlizzFramesSubPanel = CreateFrame("Frame")
    BetterBlizzFramesSubPanel.name = "Advanced Settings"
    BetterBlizzFramesSubPanel.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(BetterBlizzFramesSubPanel)
    local advancedSubCategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, BetterBlizzFramesSubPanel, BetterBlizzFramesSubPanel.name, BetterBlizzFramesSubPanel.name)
    advancedSubCategory.ID = BetterBlizzFramesSubPanel.name;
    CreateTitle(BetterBlizzFramesSubPanel)

    local bgImg = BetterBlizzFramesSubPanel:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", BetterBlizzFramesSubPanel, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)





    local scrollFrame = CreateFrame("ScrollFrame", nil, BetterBlizzFramesSubPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(700, 612)
    scrollFrame:SetPoint("CENTER", BetterBlizzFramesSubPanel, "CENTER", -20, 3)

    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(680, 520)
    scrollFrame:SetScrollChild(contentFrame)

    local mainGuiAnchor2 = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainGuiAnchor2:SetPoint("TOPLEFT", 55, 20)
    mainGuiAnchor2:SetText(" ")

 --[[
    ----------------------
    -- Focus Target
    ----------------------
    local anchorFocusTarget = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorFocusTarget:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX, firstLineY)
    anchorFocusTarget:SetText("Focus ToT")

    CreateBorderBox(anchorFocusTarget)

    local focusTargetFrameIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    focusTargetFrameIcon:SetAtlas("greencross")
    focusTargetFrameIcon:SetSize(32, 32)
    focusTargetFrameIcon:SetPoint("BOTTOM", anchorFocusTarget, "TOP", 0, 0)
    focusTargetFrameIcon:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875)

    local focusToTScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.1, "focusToTScale")
    focusToTScale:SetPoint("TOP", anchorFocusTarget, "BOTTOM", 0, -15)

    local focusToTXPos = CreateSlider(contentFrame, "x offset", -100, 100, 1, "focusToTXPos", "X")
    focusToTXPos:SetPoint("TOP", focusToTScale, "BOTTOM", 0, -15)

    local focusToTYPos = CreateSlider(contentFrame, "y offset", -100, 100, 1, "focusToTYPos", "Y")
    focusToTYPos:SetPoint("TOP", focusToTXPos, "BOTTOM", 0, -15)

    local focusToTDropdown = CreateAnchorDropdown(
        "focusToTDropdown",
        contentFrame,
        "Select Anchor Point",
        "focusToTAnchor",
        function(arg1) 
            BBF.MoveToTFrames()
        end,
        { anchorFrame = focusToTYPos, x = -16, y = -35, label = "Anchor" }
    )

    local combatIndicatorEnemyOnly = CreateCheckbox("combatIndicatorEnemyOnly", "Enemies only", contentFrame)
    combatIndicatorEnemyOnly:SetPoint("TOPLEFT", focusToTDropdown, "BOTTOMLEFT", 16, pixelsBetweenBoxes)
 
 ]]
 


 --[[
    ----------------------
    -- Pet Frame
    ----------------------
    local anchorPetFrame = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorPetFrame:SetPoint("CENTER", mainGuiAnchor2, "CENTER", thirdLineX, firstLineY)
    anchorPetFrame:SetText("Pet Frame")

    CreateBorderBox(anchorPetFrame)

    local partyFrameIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    partyFrameIcon:SetAtlas("greencross")
    partyFrameIcon:SetSize(32, 32)
    partyFrameIcon:SetPoint("BOTTOM", anchorPetFrame, "TOP", 0, 0)
    partyFrameIcon:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875)

    local petFrameScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.1, "petFrameScale")
    petFrameScale:SetPoint("TOP", anchorPetFrame, "BOTTOM", 0, -15)

    local petFrameXPos = CreateSlider(contentFrame, "x offset", -100, 100, 1, "petFrameXPos", "X")
    petFrameXPos:SetPoint("TOP", petFrameScale, "BOTTOM", 0, -15)

    local petFrameYPos = CreateSlider(contentFrame, "y offset", -100, 100, 1, "petFrameYPos", "Y")
    petFrameYPos:SetPoint("TOP", petFrameXPos, "BOTTOM", 0, -15)

    local petFrameDropdown = CreateAnchorDropdown(
        "petFrameDropdown",
        contentFrame,
        "Select Anchor Point",
        "petFrameAnchor",
        function(arg1) 
            BBF.MoveToTFrames()
        end,
        { anchorFrame = petFrameYPos, x = -16, y = -35, label = "Anchor" }
    )
 
 ]]
 



   ----------------------
    -- Absorb Indicator
    ----------------------
    local anchorSubAbsorb = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubAbsorb:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX - 120, firstLineY)
    anchorSubAbsorb:SetText("Absorb Indicator")

    --CreateBorderBox(anchorSubAbsorb)
    CreateBorderedFrame(anchorSubAbsorb, 200, 293, 0, -98, BetterBlizzFramesSubPanel)

    local absorbIndicator = contentFrame:CreateTexture(nil, "ARTWORK")
    absorbIndicator:SetAtlas("ParagonReputation_Glow")
    absorbIndicator:SetSize(56, 56)
    absorbIndicator:SetPoint("BOTTOM", anchorSubAbsorb, "TOP", -1, -10)
    CreateTooltip(absorbIndicator, "Show absorb amount on target/focus frame. Enable on the General page.")

    local absorbIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "absorbIndicatorScale")
    absorbIndicatorScale:SetPoint("TOP", anchorSubAbsorb, "BOTTOM", 0, -15)

    local absorbIndicatorXPos = CreateSlider(contentFrame, "x offset", -100, 100, 1, "playerAbsorbXPos", "X")
    absorbIndicatorXPos:SetPoint("TOP", absorbIndicatorScale, "BOTTOM", 0, -15)

    local absorbIndicatorYPos = CreateSlider(contentFrame, "y offset", -100, 100, 1, "playerAbsorbYPos", "Y")
    absorbIndicatorYPos:SetPoint("TOP", absorbIndicatorXPos, "BOTTOM", 0, -15)

    local playerAbsorbAnchorDropdown = CreateAnchorDropdown(
        "playerAbsorbAnchorDropdown",
        contentFrame,
        "Select Anchor Point",
        "playerAbsorbAnchor",
        function(arg1)
        BBF.AbsorbCaller()
    end,
        { anchorFrame = absorbIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    local absorbIndicatorTestMode = CreateCheckbox("absorbIndicatorTestMode", "Test", contentFrame, nil, BBF.AbsorbCaller)
    absorbIndicatorTestMode:SetPoint("TOPLEFT", playerAbsorbAnchorDropdown, "BOTTOMLEFT", 10, pixelsBetweenBoxes)

    local absorbIndicatorFlipIconText = CreateCheckbox("absorbIndicatorFlipIconText", "Flip Icon & Text", contentFrame, nil, BBF.AbsorbCaller)
    absorbIndicatorFlipIconText:SetPoint("LEFT", absorbIndicatorTestMode.text, "RIGHT", 5, 0)




--[[
    local absorbIndicatorEnemyOnly = CreateCheckbox("absorbIndicatorEnemyOnly", "Enemy only", contentFrame)
    absorbIndicatorEnemyOnly:SetPoint("TOPLEFT", absorbIndicatorTestMode, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local absorbIndicatorOnPlayersOnly = CreateCheckbox("absorbIndicatorOnPlayersOnly", "Players only", contentFrame)
    absorbIndicatorOnPlayersOnly:SetPoint("TOPLEFT", absorbIndicatorEnemyOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

]]


    --
    local playerAbsorbAmount = CreateCheckbox("playerAbsorbAmount", "Player", contentFrame, nil, BBF.AbsorbCaller)
    playerAbsorbAmount:SetPoint("TOPLEFT", absorbIndicatorTestMode, "BOTTOMLEFT", -5, -14)
    CreateTooltip(playerAbsorbAmount, "Show absorb indicator on PlayerFrame")

    local playerAbsorbIcon = CreateCheckbox("playerAbsorbIcon", "Icon", contentFrame, nil, BBF.AbsorbCaller)
    playerAbsorbIcon:SetPoint("TOPLEFT", playerAbsorbAmount, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(playerAbsorbIcon, "Show icon of the largest absorb spell")

    local targetAbsorbAmount = CreateCheckbox("targetAbsorbAmount", "Target", contentFrame, nil, BBF.AbsorbCaller)
    targetAbsorbAmount:SetPoint("LEFT", playerAbsorbAmount.Text, "RIGHT", 5, 0)
    CreateTooltip(targetAbsorbAmount, "Show absorb indicator on TargetFrame")

    local targetAbsorbIcon = CreateCheckbox("targetAbsorbIcon", "Icon", contentFrame, nil, BBF.AbsorbCaller)
    targetAbsorbIcon:SetPoint("TOPLEFT", targetAbsorbAmount, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetAbsorbIcon, "Show icon of the largest absorb spell")

    local focusAbsorbAmount = CreateCheckbox("focusAbsorbAmount", "Focus", contentFrame, nil, BBF.AbsorbCaller)
    focusAbsorbAmount:SetPoint("LEFT", targetAbsorbAmount.Text, "RIGHT", 5, 0)
    CreateTooltip(focusAbsorbAmount, "Show absorb indicator on FocusFrame")

    local focusAbsorbIcon = CreateCheckbox("focusAbsorbIcon", "Icon", contentFrame, nil, BBF.AbsorbCaller)
    focusAbsorbIcon:SetPoint("TOPLEFT", focusAbsorbAmount, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusAbsorbIcon, "Show icon of the largest absorb spell")










    --------------------------
    -- Combat indicator
    ----------------------
    local anchorSubOutOfCombat = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubOutOfCombat:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX-70, firstLineY)
    anchorSubOutOfCombat:SetText("Combat Indicator")

    --CreateBorderBox(anchorSubOutOfCombat)
    CreateBorderedFrame(anchorSubOutOfCombat, 200, 293, 0, -98, BetterBlizzFramesSubPanel)

    local combatIconSub = contentFrame:CreateTexture(nil, "ARTWORK")
    combatIconSub:SetTexture("Interface\\Icons\\ABILITY_DUALWIELD")
    combatIconSub:SetSize(34, 34)
    combatIconSub:SetPoint("BOTTOM", anchorSubOutOfCombat, "TOP", 0, 1)
    CreateTooltip(combatIconSub, "Show combat status on target/focus frame. Enable on the General page.")

    local combatIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "combatIndicatorScale")
    combatIndicatorScale:SetPoint("TOP", anchorSubOutOfCombat, "BOTTOM", 0, -15)

    local combatIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "combatIndicatorXPos", "X")
    combatIndicatorXPos:SetPoint("TOP", combatIndicatorScale, "BOTTOM", 0, -15)

    local combatIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "combatIndicatorYPos", "Y")
    combatIndicatorYPos:SetPoint("TOP", combatIndicatorXPos, "BOTTOM", 0, -15)

    local combatIndicatorDropdown = CreateAnchorDropdown(
        "combatIndicatorDropdown",
        contentFrame,
        "Select Anchor Point",
        "combatIndicatorAnchor",
        function(arg1) 
            BBF.CombatIndicatorCaller()
        end,
        { anchorFrame = combatIndicatorYPos, x = -16, y = -35, label = "Anchor" }
    )

    local combatIndicatorArenaOnly = CreateCheckbox("combatIndicatorArenaOnly", "Arena only", contentFrame)
    combatIndicatorArenaOnly:SetPoint("TOPLEFT", combatIndicatorDropdown, "BOTTOMLEFT", 5, pixelsBetweenBoxes)
    combatIndicatorArenaOnly:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)
    CreateTooltip(combatIndicatorArenaOnly, "Only show Combat Indicator during arena")

    local combatIndicatorShowSap = CreateCheckbox("combatIndicatorShowSap", "No combat", contentFrame)
    combatIndicatorShowSap:SetPoint("TOPLEFT", combatIndicatorArenaOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    combatIndicatorShowSap:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)
    CreateTooltip(combatIndicatorShowSap, "Show sap icon when not in combat")

    local combatIndicatorShowSwords = CreateCheckbox("combatIndicatorShowSwords", "In combat", contentFrame)
    combatIndicatorShowSwords:SetPoint("LEFT", combatIndicatorShowSap.Text, "RIGHT", 5, 0)
    combatIndicatorShowSwords:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)
    CreateTooltip(combatIndicatorShowSwords, "Show swords icon when in combat")

    local combatIndicatorPlayersOnly = CreateCheckbox("combatIndicatorPlayersOnly", "Players only", contentFrame)
    combatIndicatorPlayersOnly:SetPoint("LEFT", combatIndicatorArenaOnly.Text, "RIGHT", 5, 0)
    combatIndicatorPlayersOnly:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)
    CreateTooltip(combatIndicatorPlayersOnly, "Only show on players and not npcs")

    local playerCombatIndicator = CreateCheckbox("playerCombatIndicator", "Player", contentFrame)
    playerCombatIndicator:SetPoint("TOPLEFT", combatIndicatorShowSap, "BOTTOMLEFT", -5, -10)
    playerCombatIndicator:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)

    local targetCombatIndicator = CreateCheckbox("targetCombatIndicator", "Target", contentFrame)
    targetCombatIndicator:SetPoint("LEFT", playerCombatIndicator.Text, "RIGHT", 5, 0)
    targetCombatIndicator:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)

    local focusCombatIndicator = CreateCheckbox("focusCombatIndicator", "Focus", contentFrame)
    focusCombatIndicator:SetPoint("LEFT", targetCombatIndicator.Text, "RIGHT", 5, 0)
    focusCombatIndicator:HookScript("OnClick", function(self)
        BBF.CombatIndicatorCaller()
    end)


    --------------------------
    -- Racial indicator
    ----------------------
    local anchorSubracialIndicator = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubracialIndicator:SetPoint("CENTER", mainGuiAnchor2, "CENTER", secondLineX-70, secondLineY - 15)
    anchorSubracialIndicator:SetText("PvP Racial Indicator")

    --CreateBorderBox(anchorSubracialIndicator)
    CreateBorderedFrame(anchorSubracialIndicator, 200, 293, 0, -98, BetterBlizzFramesSubPanel)

    local racialIndicatorIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    racialIndicatorIcon:SetTexture("Interface\\Icons\\ability_ambush")
    racialIndicatorIcon:SetSize(34, 34)
    racialIndicatorIcon:SetPoint("BOTTOM", anchorSubracialIndicator, "TOP", 0, 1)
    CreateTooltip(racialIndicatorIcon, "Show racial icon on target/focus. Enable on the General page.")

    local racialIndicatorScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "racialIndicatorScale")
    racialIndicatorScale:SetPoint("TOP", anchorSubracialIndicator, "BOTTOM", 0, -15)

    local racialIndicatorXPos = CreateSlider(contentFrame, "x offset", -50, 50, 1, "racialIndicatorXPos", "X")
    racialIndicatorXPos:SetPoint("TOP", racialIndicatorScale, "BOTTOM", 0, -15)

    local racialIndicatorYPos = CreateSlider(contentFrame, "y offset", -50, 50, 1, "racialIndicatorYPos", "Y")
    racialIndicatorYPos:SetPoint("TOP", racialIndicatorXPos, "BOTTOM", 0, -15)

    local racialIndicatorOrc = CreateCheckbox("racialIndicatorOrc", "Orc", contentFrame)
    racialIndicatorOrc:SetPoint("TOPLEFT", racialIndicatorYPos, "BOTTOMLEFT", 5, -5)
    racialIndicatorOrc:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorOrc, "Show for Orc")

    local racialIndicatorHuman = CreateCheckbox("racialIndicatorHuman", "Human", contentFrame)
    racialIndicatorHuman:SetPoint("TOPLEFT", racialIndicatorOrc, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    racialIndicatorHuman:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorHuman, "Show for Human")

    local racialIndicatorNelf = CreateCheckbox("racialIndicatorNelf", "Night Elf", contentFrame)
    racialIndicatorNelf:SetPoint("LEFT", racialIndicatorOrc.Text, "RIGHT", 25, 0)
    racialIndicatorNelf:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorNelf, "Show for Night Elf")

    local racialIndicatorUndead = CreateCheckbox("racialIndicatorUndead", "Undead", contentFrame)
    racialIndicatorUndead:SetPoint("TOPLEFT", racialIndicatorNelf, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    racialIndicatorUndead:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(racialIndicatorUndead, "Show for Undead")

    local targetRacialIndicator = CreateCheckbox("targetRacialIndicator", "Target", contentFrame)
    targetRacialIndicator:SetPoint("TOPLEFT", racialIndicatorHuman, "BOTTOMLEFT", 0, -10)
    targetRacialIndicator:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(targetRacialIndicator, "Show on TargetFrame")

    local focusRacialIndicator = CreateCheckbox("focusRacialIndicator", "Focus", contentFrame)
    focusRacialIndicator:SetPoint("LEFT", targetRacialIndicator.Text, "RIGHT", 12, 0)
    focusRacialIndicator:HookScript("OnClick", function(self)
        BBF.RacialIndicatorCaller()
    end)
    CreateTooltip(focusRacialIndicator, "Show on FocusFrame")

       ----------------------
    -- Castbar Interrupt Icon
    ----------------------
    local anchorSubInterruptIcon = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubInterruptIcon:SetPoint("CENTER", mainGuiAnchor2, "CENTER", fourthLineX - 120, secondLineY-15)
    anchorSubInterruptIcon:SetText("Interrupt Icon")

    --CreateBorderBox(anchorSubInterruptIcon)
    CreateBorderedFrame(anchorSubInterruptIcon, 200, 293, 0, -98, BetterBlizzFramesSubPanel)

    local castBarInterruptIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    castBarInterruptIcon:SetTexture("Interface\\Icons\\ability_kick")
    castBarInterruptIcon:SetSize(34, 34)
    castBarInterruptIcon:SetPoint("BOTTOM", anchorSubInterruptIcon, "TOP", 0, 0)
    CreateTooltip(castBarInterruptIcon, "Show interrupt icon next to castbar")

    local castBarInterruptIconScale = CreateSlider(contentFrame, "Size", 0.1, 1.9, 0.01, "castBarInterruptIconScale")
    castBarInterruptIconScale:SetPoint("TOP", anchorSubInterruptIcon, "BOTTOM", 0, -15)

    local castBarInterruptIconXPos = CreateSlider(contentFrame, "x offset", -100, 100, 1, "castBarInterruptIconXPos", "X")
    castBarInterruptIconXPos:SetPoint("TOP", castBarInterruptIconScale, "BOTTOM", 0, -15)

    local castBarInterruptIconYPos = CreateSlider(contentFrame, "y offset", -100, 100, 1, "castBarInterruptIconYPos", "Y")
    castBarInterruptIconYPos:SetPoint("TOP", castBarInterruptIconXPos, "BOTTOM", 0, -15)

    local castBarInterruptIconAnchorDropdown = CreateAnchorDropdown(
        "castBarInterruptIconAnchorDropdown",
        contentFrame,
        "Select Anchor Point",
        "castBarInterruptIconAnchor",
        function(arg1)
        BBF.UpdateInterruptIconSettings()
    end,
        { anchorFrame = castBarInterruptIconYPos, x = -16, y = -35, label = "Anchor" }
    )

    local castBarInterruptIconTarget = CreateCheckbox("castBarInterruptIconTarget", "Target", contentFrame, nil, BBF.UpdateInterruptIconSettings)
    castBarInterruptIconTarget:SetPoint("TOPLEFT", castBarInterruptIconAnchorDropdown, "BOTTOMLEFT", 24, pixelsBetweenBoxes)
    CreateTooltipTwo(castBarInterruptIconTarget, "Show on Target")

    local castBarInterruptIconFocus = CreateCheckbox("castBarInterruptIconFocus", "Focus", contentFrame, nil, BBF.UpdateInterruptIconSettings)
    castBarInterruptIconFocus:SetPoint("LEFT", castBarInterruptIconTarget.text, "RIGHT", 5, 0)
    CreateTooltipTwo(castBarInterruptIconFocus, "Show on Focus")

    local castBarInterruptIconShowActiveOnly = CreateCheckbox("castBarInterruptIconShowActiveOnly", "Only show icon if available", contentFrame, nil, BBF.UpdateInterruptIconSettings)
    castBarInterruptIconShowActiveOnly:SetPoint("TOPLEFT", castBarInterruptIconTarget, "BOTTOMLEFT", -28, pixelsBetweenBoxes)
    CreateTooltipTwo(castBarInterruptIconShowActiveOnly, "Only show icon if available", "Hides the icon if interrupt is on cooldown")

    local interruptIconBorder = CreateCheckbox("interruptIconBorder", "Border Status Color", contentFrame, nil, BBF.UpdateInterruptIconSettings)
    interruptIconBorder:SetPoint("TOPLEFT", castBarInterruptIconShowActiveOnly, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(interruptIconBorder, "Border Status Color", "Colors the border on the icon after interrupt status.\nBy default red if on cooldown, purple if will be ready before cast ends and green if ready.")

    local reloadUiButton2 = CreateFrame("Button", nil, BetterBlizzFramesSubPanel, "UIPanelButtonTemplate")
    reloadUiButton2:SetText("Reload UI")
    reloadUiButton2:SetWidth(85)
    reloadUiButton2:SetPoint("TOP", BetterBlizzFramesSubPanel, "BOTTOMRIGHT", -140, -9)
    reloadUiButton2:SetScript("OnClick", function()
        BetterBlizzFramesDB.reopenOptions = true
        ReloadUI()
    end)



end

local function guiFrameLook()
    ----------------------
    -- Frame Auras
    ----------------------
    local guiFrameLook = CreateFrame("Frame")
    guiFrameLook.name = "Font & Texture"
    guiFrameLook.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(guiFrameAuras)
    local aurasSubCategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, guiFrameLook, guiFrameLook.name, guiFrameLook.name)
    aurasSubCategory.ID = guiFrameLook.name;
    CreateTitle(guiFrameLook)

    local bgImg = guiFrameLook:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiFrameLook, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

















-- Define the path to your custom power bar texture
local pathToPowerBarTexture = "Interface\\TargetingFrame\\UI-StatusBar"

-- Function to set the power bar texture and color
local units = {
    ["player"] = true,
    ["target"] = true,
    ["focus"] = true,
}

local function UpdatePowerBarAppearance(powerBar)
    local unit = powerBar.unit

    if units[unit] then
        -- Set the texture of the power bar
        powerBar:SetStatusBarTexture(pathToPowerBarTexture)
        
        -- Determine and set the power bar color
        local powerType = UnitPowerType(unit)
        local powerColor = PowerBarColor[powerType] or PowerBarColor["MANA"] -- Default to mana color if not found

        if powerColor then
            -- Apply the power bar color
            powerBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
        end
    end
end

-- Hook the function to update the mana bar type using the secure function
hooksecurefunc("UnitFrameManaBar_UpdateType", UpdatePowerBarAppearance)

end

local function guiFrameAuras()
    ----------------------
    -- Frame Auras
    ----------------------
    local guiFrameAuras = CreateFrame("Frame")
    guiFrameAuras.name = "Buffs & Debuffs"
    guiFrameAuras.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(guiFrameAuras)
    local aurasSubCategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, guiFrameAuras, guiFrameAuras.name, guiFrameAuras.name)
    aurasSubCategory.ID = guiFrameAuras.name;
    BBF.aurasSubCategory = aurasSubCategory.ID
    CreateTitle(guiFrameAuras)

    local bgImg = guiFrameAuras:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiFrameAuras, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local scrollFrame = CreateFrame("ScrollFrame", nil, guiFrameAuras, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(700, 612)
    scrollFrame:SetPoint("CENTER", guiFrameAuras, "CENTER", -20, 3)

    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(680, 520)
    scrollFrame:SetScrollChild(contentFrame)

    local auraWhitelistFrame = CreateFrame("Frame", nil, contentFrame)
    auraWhitelistFrame:SetSize(322, 390)
    auraWhitelistFrame:SetPoint("TOPLEFT", 346, -15)

    local auraBlacklistFrame = CreateFrame("Frame", nil, contentFrame)
    auraBlacklistFrame:SetSize(322, 390)
    auraBlacklistFrame:SetPoint("TOPLEFT", 6, -15)

    local whitelist = CreateList(auraBlacklistFrame, "auraBlacklist", BetterBlizzFramesDB.auraBlacklist, BBF.RefreshAllAuraFrames, nil, nil, 265)

    local blacklistText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    blacklistText:SetPoint("BOTTOM", auraBlacklistFrame, "TOP", -20, -5)
    blacklistText:SetText("Blacklist")

    local blacklist = CreateList(auraWhitelistFrame, "auraWhitelist", BetterBlizzFramesDB.auraWhitelist, BBF.RefreshAllAuraFrames, true, true, 379, true)

    local whitelistText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whitelistText:SetPoint("BOTTOM", auraWhitelistFrame, "TOP", -60, -5)
    whitelistText:SetText("Whitelist")

    if not BetterBlizzFramesDB.playerAuraFiltering then
        auraWhitelistFrame:SetAlpha(0.3)
        auraBlacklistFrame:SetAlpha(0.3)
    end

    local onlyMeTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    onlyMeTexture:SetAtlas("UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon")
    onlyMeTexture:SetPoint("RIGHT", whitelist, "TOPRIGHT", 296, 9)
    onlyMeTexture:SetSize(18,20)
    CreateTooltip(onlyMeTexture, "Only My Aura Checkboxes")

    local enlargeAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    enlargeAuraTexture:SetAtlas("ui-hud-minimap-zoom-in")
    enlargeAuraTexture:SetPoint("LEFT", onlyMeTexture, "RIGHT", 4, 0)
    enlargeAuraTexture:SetSize(18,18)
    CreateTooltip(enlargeAuraTexture, "Enlarged Aura Checkboxes")

    local compactAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    compactAuraTexture:SetAtlas("ui-hud-minimap-zoom-out")
    compactAuraTexture:SetPoint("LEFT", enlargeAuraTexture, "RIGHT", 3, 0)
    compactAuraTexture:SetSize(18,18)
    CreateTooltip(compactAuraTexture, "Compact Aura Checkboxes")

    local importantAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    importantAuraTexture:SetAtlas("importantavailablequesticon")
    importantAuraTexture:SetPoint("LEFT", compactAuraTexture, "RIGHT", 2, 0)
    importantAuraTexture:SetSize(17,16)
    importantAuraTexture:SetDesaturated(true)
    importantAuraTexture:SetVertexColor(0,1,0)
    CreateTooltip(importantAuraTexture, "Important Aura Checkboxes")

    local pandemicAuraTexture = contentFrame:CreateTexture(nil, "OVERLAY")
    pandemicAuraTexture:SetAtlas("elementalstorm-boss-air")
    pandemicAuraTexture:SetPoint("LEFT", importantAuraTexture, "RIGHT", -1, 1)
    pandemicAuraTexture:SetSize(26,26)
    pandemicAuraTexture:SetDesaturated(true)
    pandemicAuraTexture:SetVertexColor(1,0,0)
    CreateTooltip(pandemicAuraTexture, "Pandemic Aura Checkboxes")






    local playerAuraFiltering = CreateCheckbox("playerAuraFiltering", "Enable Aura Settings", contentFrame)
    CreateTooltipTwo(playerAuraFiltering, "Enable Buff Filtering & Aura settings", "Enables all the buff filtering settings.\nThis setting is cpu heavy and un-optimized so use at your own risk.")
    playerAuraFiltering:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 50, 190)
    playerAuraFiltering:HookScript("OnClick", function (self)
        if self:GetChecked() then
            if BetterBlizzFramesDB.targetToTXPos == 0 then
                StaticPopup_Show("BBF_TOT_MESSAGE")
                BetterBlizzFramesDB.targetToTXPos = 31
                BBF.targetToTXPos:SetValue(31)
                BetterBlizzFramesDB.focusToTXPos = 31
                BBF.focusToTXPos:SetValue(31)
                BBF.MoveToTFrames()
                BBF.UpdateFilteredBuffsIcon()
            else
                StaticPopup_Show("BBF_CONFIRM_RELOAD")
            end
            auraWhitelistFrame:SetAlpha(1)
            auraBlacklistFrame:SetAlpha(1)
        else
            if BetterBlizzFramesDB.targetToTXPos == 31 then
                DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: Aura Settings Off. Target of Target Frame changed back to its default position.")
                BetterBlizzFramesDB.targetToTXPos = 0
                BBF.targetToTXPos:SetValue(0)
                BetterBlizzFramesDB.focusToTXPos = 0
                BBF.focusToTXPos:SetValue(0)
                BBF.MoveToTFrames()
            end
            auraWhitelistFrame:SetAlpha(0.3)
            auraBlacklistFrame:SetAlpha(0.3)
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local enableMasque = CreateCheckbox("enableMasque", "Add Masque Support", contentFrame)
    enableMasque:SetPoint("LEFT", playerAuraFiltering.Text, "RIGHT", 5, 0)
    CreateTooltipTwo(enableMasque, "Add Masque Support", "Enable to add Masque support on all auras.\n(Does not require Aura Settings to be enabled)")
    enableMasque:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local printAuraSpellIds = CreateCheckbox("printAuraSpellIds", "Print Spell ID", playerAuraFiltering)
    printAuraSpellIds:SetPoint("LEFT", enableMasque.Text, "RIGHT", 5, 0)
    CreateTooltip(printAuraSpellIds, "Show aura spell id in chat when mousing over the aura.\n\nUsecase: Find spell ID to filter by ID, some spells have identical names.")

    -- local tipText = playerAuraFiltering:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- tipText:SetPoint("LEFT", printAuraSpellIds.Text, "RIGHT", 5, 0)
    -- tipText:SetText("Tip")

    --------------------------
    -- Target Frame
    --------------------------
    -- Target Buffs
    local targetBuffEnable = CreateCheckbox("targetBuffEnable", "Show BUFFS", playerAuraFiltering)
    targetBuffEnable:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 64, 140)
    targetBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(targetBuffEnable)
        TargetFrame:UpdateAuras()
    end)

    local bigEnemyBorderText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bigEnemyBorderText:SetPoint("LEFT", targetBuffEnable, "CENTER", 35, 25)
    bigEnemyBorderText:SetText("Target Frame")
    local targetFrameIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    targetFrameIcon:SetAtlas("groupfinder-icon-friend")
    targetFrameIcon:SetSize(28, 28)
    targetFrameIcon:SetPoint("RIGHT", bigEnemyBorderText, "LEFT", -3, 0)
    targetFrameIcon:SetDesaturated(1)
    targetFrameIcon:SetVertexColor(1, 0, 0)

    local targetAuraBorder = CreateBorderedFrame(targetBuffEnable, 185, 400, 65, -186, contentFrame)

    local targetBuffFilterWatchList = CreateCheckbox("targetBuffFilterWatchList", "Whitelist", targetBuffEnable)
    CreateTooltipTwo(targetBuffFilterWatchList, "Whitelist", "Only show whitelisted auras.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)")
    targetBuffFilterWatchList:SetPoint("TOPLEFT", targetBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local targetBuffFilterBlacklist = CreateCheckbox("targetBuffFilterBlacklist", "Blacklist", targetBuffEnable)
    targetBuffFilterBlacklist:SetPoint("TOPLEFT", targetBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetBuffFilterBlacklist, "Filter out blacklisted auras.")

    local targetBuffFilterLessMinite = CreateCheckbox("targetBuffFilterLessMinite", "Under one min", targetBuffEnable)
    targetBuffFilterLessMinite:SetPoint("TOPLEFT", targetBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetBuffFilterLessMinite, "Only show buffs that are 60sec or shorter.")

    local targetBuffFilterOnlyMe = CreateCheckbox("targetBuffFilterOnlyMe", "Only mine", targetBuffEnable)
    targetBuffFilterOnlyMe:SetPoint("TOPLEFT", targetBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetBuffFilterOnlyMe, "If the target is friendly only show your own buffs on them")

    local targetBuffFilterPurgeable = CreateCheckbox("targetBuffFilterPurgeable", "Purgeable", targetBuffEnable)
    targetBuffFilterPurgeable:SetPoint("TOPLEFT", targetBuffFilterOnlyMe, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local targetBuffFilterMount = CreateCheckbox("targetBuffFilterMount", "Mount", targetBuffEnable)
    targetBuffFilterMount:SetPoint("TOPLEFT", targetBuffFilterPurgeable, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(targetBuffFilterMount, "Mount", "Show all mounts.\n(Needs testing, please report if you see a mount that is not displayed by this filter)")


--[[targetBuffPurgeGlow
    local otherNpBuffBlueBorder = CreateCheckbox("otherNpBuffBlueBorder", "Blue border on buffs", targetBuffEnable)
    otherNpBuffBlueBorder:SetPoint("TOPLEFT", targetBuffFilterOnlyMe, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local otherNpBuffEmphasisedBorder = CreateCheckbox("otherNpBuffEmphasisedBorder", "Red glow on whitelisted buffs", targetBuffEnable)
    otherNpBuffEmphasisedBorder:SetPoint("TOPLEFT", otherNpBuffBlueBorder, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

]]


    -- Target Debuffs
    local targetdeBuffEnable = CreateCheckbox("targetdeBuffEnable", "Show DEBUFFS", playerAuraFiltering)
    targetdeBuffEnable:SetPoint("TOPLEFT", targetBuffFilterMount, "BOTTOMLEFT", -15, 0)
    targetdeBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(targetdeBuffEnable)
    end)

    local targetdeBuffFilterBlizzard = CreateCheckbox("targetdeBuffFilterBlizzard", "Blizzard Default Filter", targetdeBuffEnable)
    targetdeBuffFilterBlizzard:SetPoint("TOPLEFT", targetdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local targetdeBuffFilterWatchList = CreateCheckbox("targetdeBuffFilterWatchList", "Whitelist", targetdeBuffEnable)
    CreateTooltipTwo(targetdeBuffFilterWatchList, "Whitelist", "Only show whitelisted auras.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)")
    targetdeBuffFilterWatchList:SetPoint("TOPLEFT", targetdeBuffFilterBlizzard, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local targetdeBuffFilterBlacklist = CreateCheckbox("targetdeBuffFilterBlacklist", "Blacklist", targetdeBuffEnable)
    targetdeBuffFilterBlacklist:SetPoint("TOPLEFT", targetdeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetdeBuffFilterBlacklist, "Filter out blacklisted auras.")

    local targetdeBuffFilterLessMinite = CreateCheckbox("targetdeBuffFilterLessMinite", "Under one min", targetdeBuffEnable)
    targetdeBuffFilterLessMinite:SetPoint("TOPLEFT", targetdeBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetdeBuffFilterLessMinite, "Only show debuffs that are 60sec or shorter.")

    local targetdeBuffFilterOnlyMe = CreateCheckbox("targetdeBuffFilterOnlyMe", "Only mine", targetdeBuffEnable)
    targetdeBuffFilterOnlyMe:SetPoint("TOPLEFT", targetdeBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local targetAuraGlows = CreateCheckbox("targetAuraGlows", "Extra Aura Settings", playerAuraFiltering)
    targetAuraGlows:SetPoint("TOPLEFT", targetdeBuffFilterOnlyMe, "BOTTOMLEFT", -15, 0)
    targetAuraGlows:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(targetAuraGlows)
    end)

    local targetEnlargeAura = CreateCheckbox("targetEnlargeAura", "Enlarge Aura", targetAuraGlows)
    targetEnlargeAura:SetPoint("TOPLEFT", targetAuraGlows, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(targetEnlargeAura, "Enlarge checked whitelisted auras.")

    local targetEnlargeAuraEnemy = CreateCheckbox("targetEnlargeAuraEnemy", "", targetAuraGlows, nil, BBF.UpdateUserAuraSettings)
    targetEnlargeAuraEnemy:SetPoint("LEFT", targetEnlargeAura.Text, "RIGHT", 0, 0)
    CreateTooltip(targetEnlargeAuraEnemy, "Enable on Enemy")
    targetEnlargeAuraEnemy:SetSize(22,22)

    targetEnlargeAuraEnemy.texture = targetEnlargeAuraEnemy:CreateTexture(nil, "ARTWORK", nil, 1)
    targetEnlargeAuraEnemy.texture:SetTexture(BBF.squareGreenGlow)
    targetEnlargeAuraEnemy.texture:SetSize(46, 46)
    targetEnlargeAuraEnemy.texture:SetDesaturated(true)
    targetEnlargeAuraEnemy.texture:SetVertexColor(1,0,0)
    targetEnlargeAuraEnemy.texture:SetPoint("CENTER", targetEnlargeAuraEnemy, "CENTER", -0.5, 0)

    local targetEnlargeAuraFriendly = CreateCheckbox("targetEnlargeAuraFriendly", "", targetAuraGlows, nil, BBF.UpdateUserAuraSettings)
    targetEnlargeAuraFriendly:SetPoint("LEFT", targetEnlargeAuraEnemy, "RIGHT", 0, 0)
    CreateTooltip(targetEnlargeAuraFriendly, "Enable on Friendly")
    targetEnlargeAuraFriendly:SetSize(22,22)

    targetEnlargeAuraFriendly.texture = targetEnlargeAuraFriendly:CreateTexture(nil, "ARTWORK", nil, 1)
    targetEnlargeAuraFriendly.texture:SetTexture(BBF.squareGreenGlow)
    targetEnlargeAuraFriendly.texture:SetSize(46, 46)
    --targetEnlargeAuraFriendly.texture:SetDesaturated(true)
    targetEnlargeAuraFriendly.texture:SetPoint("CENTER", targetEnlargeAuraFriendly, "CENTER", -0.5, 0)

    local targetCompactAura = CreateCheckbox("targetCompactAura", "Compact Aura", targetAuraGlows)
    targetCompactAura:SetPoint("TOPLEFT", targetEnlargeAura, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetCompactAura, "Decrease the size of checked whitelisted auras.")

    local targetdeBuffPandemicGlow = CreateCheckbox("targetdeBuffPandemicGlow", "Pandemic Glow", targetAuraGlows)
    targetdeBuffPandemicGlow:SetPoint("TOPLEFT", targetCompactAura, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetdeBuffPandemicGlow, "Red glow on whitelisted auras with less than 5 seconds left.")

    local targetBuffPurgeGlow = CreateCheckbox("targetBuffPurgeGlow", "Purge Glow", targetAuraGlows)
    targetBuffPurgeGlow:SetPoint("TOPLEFT", targetdeBuffPandemicGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetBuffPurgeGlow, "Bright blue glow on all dispellable/purgeable buffs.\n\nReplaces the standard yellow glow.")

    local targetImportantAuraGlow = CreateCheckbox("targetImportantAuraGlow", "Important Glow", targetAuraGlows)
    targetImportantAuraGlow:SetPoint("TOPLEFT", targetBuffPurgeGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(targetImportantAuraGlow, "Green glow on whitelisted auras marked as important")



    --------------------------
    -- Focus Frame
    --------------------------
    -- Focus Buffs
    local focusBuffEnable = CreateCheckbox("focusBuffEnable", "Show BUFFS", playerAuraFiltering)
    focusBuffEnable:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 285, 140)
    focusBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(focusBuffEnable)
    end)

    local friendlyFramesText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    friendlyFramesText:SetPoint("LEFT", focusBuffEnable, "CENTER", 35, 25)
    friendlyFramesText:SetText("Focus Frame")
    local focusFrameIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    focusFrameIcon:SetAtlas("groupfinder-icon-friend")
    focusFrameIcon:SetSize(28, 28)
    focusFrameIcon:SetPoint("RIGHT", friendlyFramesText, "LEFT", -3, 0)
    focusFrameIcon:SetDesaturated(1)
    focusFrameIcon:SetVertexColor(0, 1, 0)

    CreateBorderedFrame(focusBuffEnable, 185, 400, 65, -186, contentFrame)

    local focusBuffFilterWatchList = CreateCheckbox("focusBuffFilterWatchList", "Whitelist", focusBuffEnable)
    CreateTooltipTwo(focusBuffFilterWatchList, "Whitelist", "Only show whitelisted auras.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)")
    focusBuffFilterWatchList:SetPoint("TOPLEFT", focusBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local focusBuffFilterBlacklist = CreateCheckbox("focusBuffFilterBlacklist", "Blacklist", focusBuffEnable)
    focusBuffFilterBlacklist:SetPoint("TOPLEFT", focusBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusBuffFilterBlacklist, "Filter out blacklisted auras.")

    local focusBuffFilterLessMinite = CreateCheckbox("focusBuffFilterLessMinite", "Under one min", focusBuffEnable)
    focusBuffFilterLessMinite:SetPoint("TOPLEFT", focusBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusBuffFilterLessMinite, "Only show buffs that are 60sec or shorter.")

    local focusBuffFilterOnlyMe = CreateCheckbox("focusBuffFilterOnlyMe", "Only mine", focusBuffEnable)
    focusBuffFilterOnlyMe:SetPoint("TOPLEFT", focusBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusBuffFilterOnlyMe, "If the unit is friendly show your buffs")

    local focusBuffFilterPurgeable = CreateCheckbox("focusBuffFilterPurgeable", "Purgeable", focusBuffEnable)
    focusBuffFilterPurgeable:SetPoint("TOPLEFT", focusBuffFilterOnlyMe, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local focusBuffFilterMount = CreateCheckbox("focusBuffFilterMount", "Mount", focusBuffEnable)
    focusBuffFilterMount:SetPoint("TOPLEFT", focusBuffFilterPurgeable, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(focusBuffFilterMount, "Mount", "Show all mounts.\n(Needs testing, please report if you see a mount that is not displayed by this filter)")

    -- Focus Debuffs
    local focusdeBuffEnable = CreateCheckbox("focusdeBuffEnable", "Show DEBUFFS", playerAuraFiltering)
    focusdeBuffEnable:SetPoint("TOPLEFT", focusBuffFilterMount, "BOTTOMLEFT", -15, 0)
    focusdeBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(focusdeBuffEnable)
    end)

    local focusdeBuffFilterBlizzard = CreateCheckbox("focusdeBuffFilterBlizzard", "Blizzard Default Filter", focusdeBuffEnable)
    focusdeBuffFilterBlizzard:SetPoint("TOPLEFT", focusdeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local focusdeBuffFilterWatchList = CreateCheckbox("focusdeBuffFilterWatchList", "Whitelist", focusdeBuffEnable)
    focusdeBuffFilterWatchList:SetPoint("TOPLEFT", focusdeBuffFilterBlizzard, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(focusdeBuffFilterWatchList, "Whitelist", "Only show whitelisted auras.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)")

    local focusdeBuffFilterBlacklist = CreateCheckbox("focusdeBuffFilterBlacklist", "Blacklist", focusdeBuffEnable)
    focusdeBuffFilterBlacklist:SetPoint("TOPLEFT", focusdeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusdeBuffFilterBlacklist, "Filter out blacklisted auras.")

    local focusdeBuffFilterLessMinite = CreateCheckbox("focusdeBuffFilterLessMinite", "Under one min", focusdeBuffEnable)
    focusdeBuffFilterLessMinite:SetPoint("TOPLEFT", focusdeBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusdeBuffFilterLessMinite, "Only show debuffs that are 60sec or shorter.")

    local focusdeBuffFilterOnlyMe = CreateCheckbox("focusdeBuffFilterOnlyMe", "Only mine", focusdeBuffEnable)
    focusdeBuffFilterOnlyMe:SetPoint("TOPLEFT", focusdeBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local focusAuraGlows = CreateCheckbox("focusAuraGlows", "Extra Aura Settings", playerAuraFiltering)
    focusAuraGlows:SetPoint("TOPLEFT", focusdeBuffFilterOnlyMe, "BOTTOMLEFT", -15, 0)
    focusAuraGlows:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(focusAuraGlows)
    end)

    local focusEnlargeAura = CreateCheckbox("focusEnlargeAura", "Enlarge Aura", focusAuraGlows)
    focusEnlargeAura:SetPoint("TOPLEFT", focusAuraGlows, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(focusEnlargeAura, "Enlarge checked whitelisted auras.")

    local focusEnlargeAuraEnemy = CreateCheckbox("focusEnlargeAuraEnemy", "", focusAuraGlows, nil, BBF.UpdateUserAuraSettings)
    focusEnlargeAuraEnemy:SetPoint("LEFT", focusEnlargeAura.Text, "RIGHT", 0, 0)
    CreateTooltip(focusEnlargeAuraEnemy, "Enable on Enemy")
    focusEnlargeAuraEnemy:SetSize(22,22)

    focusEnlargeAuraEnemy.texture = focusEnlargeAuraEnemy:CreateTexture(nil, "ARTWORK", nil, 1)
    focusEnlargeAuraEnemy.texture:SetTexture(BBF.squareGreenGlow)
    focusEnlargeAuraEnemy.texture:SetSize(46, 46)
    focusEnlargeAuraEnemy.texture:SetDesaturated(true)
    focusEnlargeAuraEnemy.texture:SetVertexColor(1,0,0)
    focusEnlargeAuraEnemy.texture:SetPoint("CENTER", focusEnlargeAuraEnemy, "CENTER", -0.5, 0)

    local focusEnlargeAuraFriendly = CreateCheckbox("focusEnlargeAuraFriendly", "", focusAuraGlows, nil, BBF.UpdateUserAuraSettings)
    focusEnlargeAuraFriendly:SetPoint("LEFT", focusEnlargeAuraEnemy, "RIGHT", 0, 0)
    CreateTooltip(focusEnlargeAuraFriendly, "Enable on Friendly")
    focusEnlargeAuraFriendly:SetSize(22,22)

    focusEnlargeAuraFriendly.texture = focusEnlargeAuraFriendly:CreateTexture(nil, "ARTWORK", nil, 1)
    focusEnlargeAuraFriendly.texture:SetTexture(BBF.squareGreenGlow)
    focusEnlargeAuraFriendly.texture:SetSize(46, 46)
    --focusEnlargeAuraFriendly.texture:SetDesaturated(true)
    focusEnlargeAuraFriendly.texture:SetPoint("CENTER", focusEnlargeAuraFriendly, "CENTER", -0.5, 0)

    local focusCompactAura = CreateCheckbox("focusCompactAura", "Compact Aura", focusAuraGlows)
    focusCompactAura:SetPoint("TOPLEFT", focusEnlargeAura, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusCompactAura, "Decrease the size of checked whitelisted auras.")

    local focusdeBuffPandemicGlow = CreateCheckbox("focusdeBuffPandemicGlow", "Pandemic Glow", focusAuraGlows)
    focusdeBuffPandemicGlow:SetPoint("TOPLEFT", focusCompactAura, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusdeBuffPandemicGlow, "Red glow on whitelisted auras with less than 5 seconds left.")

    local focusBuffPurgeGlow = CreateCheckbox("focusBuffPurgeGlow", "Purge Glow", focusAuraGlows)
    focusBuffPurgeGlow:SetPoint("TOPLEFT", focusdeBuffPandemicGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusBuffPurgeGlow, "Bright blue glow on all dispellable/purgeable buffs.\n\nReplaces the standard yellow glow.")

    local focusImportantAuraGlow = CreateCheckbox("focusImportantAuraGlow", "Important Glow", focusAuraGlows)
    focusImportantAuraGlow:SetPoint("TOPLEFT", focusBuffPurgeGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(focusImportantAuraGlow, "Green glow on auras marked as important in whitelist")

    --------------------------
    -- Player Auras
    --------------------------
    -- Player Auras

    local enablePlayerBuffFiltering = CreateCheckbox("enablePlayerBuffFiltering", "Enable Buff Filtering", playerAuraFiltering)
    enablePlayerBuffFiltering:SetPoint("TOPLEFT", contentFrame, "BOTTOMLEFT", 503, 140)
    enablePlayerBuffFiltering:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(enablePlayerBuffFiltering)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local PlayerAuraFrameBuffEnable = CreateCheckbox("PlayerAuraFrameBuffEnable", "Show BUFFS", enablePlayerBuffFiltering)
    PlayerAuraFrameBuffEnable:SetPoint("TOPLEFT", enablePlayerBuffFiltering, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    PlayerAuraFrameBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(PlayerAuraFrameBuffEnable)
    end)

    local personalBarText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    personalBarText:SetPoint("LEFT", enablePlayerBuffFiltering, "CENTER", 35, 25)
    personalBarText:SetText("Player Auras")
    local personalBarIcon = contentFrame:CreateTexture(nil, "ARTWORK")
    personalBarIcon:SetAtlas("groupfinder-icon-friend")
    personalBarIcon:SetSize(28, 28)
    personalBarIcon:SetPoint("RIGHT", personalBarText, "LEFT", -3, 0)

    local PlayerAuraBorder = CreateBorderedFrame(enablePlayerBuffFiltering, 185, 400, 65, -186, contentFrame)

    local PlayerAuraFrameBuffFilterWatchList = CreateCheckbox("PlayerAuraFrameBuffFilterWatchList", "Whitelist", PlayerAuraFrameBuffEnable)
    CreateTooltipTwo(PlayerAuraFrameBuffFilterWatchList, "Whitelist", "Only show whitelisted auras.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)")
    PlayerAuraFrameBuffFilterWatchList:SetPoint("TOPLEFT", PlayerAuraFrameBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local playerBuffFilterBlacklist = CreateCheckbox("playerBuffFilterBlacklist", "Blacklist", PlayerAuraFrameBuffEnable)
    playerBuffFilterBlacklist:SetPoint("TOPLEFT", PlayerAuraFrameBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(playerBuffFilterBlacklist, "Filter out blacklisted auras.")

    local PlayerAuraFrameBuffFilterLessMinite = CreateCheckbox("PlayerAuraFrameBuffFilterLessMinite", "Under one min", PlayerAuraFrameBuffEnable)
    PlayerAuraFrameBuffFilterLessMinite:SetPoint("TOPLEFT", playerBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(PlayerAuraFrameBuffFilterLessMinite, "Only show buffs that are 60sec or shorter.")

    local showHiddenAurasIcon = CreateCheckbox("showHiddenAurasIcon", "Filtered Buffs Icon", PlayerAuraFrameBuffEnable)
    showHiddenAurasIcon:SetPoint("TOPLEFT", PlayerAuraFrameBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(showHiddenAurasIcon, "Show an icon next to the buff frame displaying\nthe amount of auras filtered out.\nClick icon to show which auras are filtered.")

    -- Create a button next to the checkbox
    local changeIconButton = CreateFrame("Button", "ChangeIconButton", showHiddenAurasIcon, "UIPanelButtonTemplate")
    changeIconButton:SetPoint("RIGHT", showHiddenAurasIcon, "LEFT", 0, 0)
    changeIconButton:SetSize(37, 20)  -- Adjust size as needed
    changeIconButton:SetText("Icon")
    local iconChangeWindow

    changeIconButton:SetScript("OnClick", function()
        if not iconChangeWindow then
            iconChangeWindow = CreateIconChangeWindow()
        end
        iconChangeWindow:Show()
    end)

    showHiddenAurasIcon:HookScript("OnClick", function(self)
        if self:GetChecked() then
            changeIconButton:SetAlpha(1)
            changeIconButton:Enable()
        else
            changeIconButton:SetAlpha(0)
            changeIconButton:Disable()
        end
    end)

    if not BetterBlizzFramesDB.showHiddenAurasIcon then
        changeIconButton:SetAlpha(0)
        changeIconButton:Disable()
    end

    local playerBuffFilterMount = CreateCheckbox("playerBuffFilterMount", "Mount", PlayerAuraFrameBuffEnable)
    playerBuffFilterMount:SetPoint("TOPLEFT", showHiddenAurasIcon, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(playerBuffFilterMount, "Mount", "Show all mounts.\n(Needs testing, please report if you see a mount that is not displayed by this filter)")

    -- Personal Bar Debuffs
    local enablePlayerDebuffFiltering = CreateCheckbox("enablePlayerDebuffFiltering", "Enable Debuff Filtering", playerAuraFiltering)
    enablePlayerDebuffFiltering:SetPoint("TOPLEFT", playerBuffFilterMount, "BOTTOMLEFT", -30, 0)
    enablePlayerDebuffFiltering:HookScript("OnClick", function (self)
        CheckAndToggleCheckboxes(enablePlayerDebuffFiltering)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    CreateTooltip(enablePlayerDebuffFiltering, "Enables Debuff Filtering.\nThis boy is a bit too heavy to run for my liking so I've turned it off by default.\nUntil I manage to optimize it use at your own risk.\n(It's probably fine, I'm just too cautious)")

    local PlayerAuraFramedeBuffEnable = CreateCheckbox("PlayerAuraFramedeBuffEnable", "Show DEBUFFS", enablePlayerDebuffFiltering)
    PlayerAuraFramedeBuffEnable:SetPoint("TOPLEFT", enablePlayerDebuffFiltering, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    PlayerAuraFramedeBuffEnable:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(PlayerAuraFramedeBuffEnable)
    end)

    local PlayerAuraFramedeBuffFilterWatchList = CreateCheckbox("PlayerAuraFramedeBuffFilterWatchList", "Whitelist", PlayerAuraFramedeBuffEnable)
    CreateTooltipTwo(PlayerAuraFramedeBuffFilterWatchList, "Whitelist", "Only show whitelisted auras.\n(Plus other filters)", "You can have spells whitelisted to add settings such as \"Only Mine\" and \"Important\" etc without needing to enable the whitelist filter here.\n\nOnly check this if you only want whitelisted auras here or the addition of them.\n(Plus other filters)")
    PlayerAuraFramedeBuffFilterWatchList:SetPoint("TOPLEFT", PlayerAuraFramedeBuffEnable, "BOTTOMLEFT", 15, pixelsBetweenBoxes)

    local playerdeBuffFilterBlacklist = CreateCheckbox("playerdeBuffFilterBlacklist", "Blacklist", PlayerAuraFramedeBuffEnable)
    playerdeBuffFilterBlacklist:SetPoint("TOPLEFT", PlayerAuraFramedeBuffFilterWatchList, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(playerdeBuffFilterBlacklist, "Filter out blacklisted auras.")

    local PlayerAuraFramedeBuffFilterLessMinite = CreateCheckbox("PlayerAuraFramedeBuffFilterLessMinite", "Under one min", PlayerAuraFramedeBuffEnable)
    PlayerAuraFramedeBuffFilterLessMinite:SetPoint("TOPLEFT", playerdeBuffFilterBlacklist, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(PlayerAuraFramedeBuffFilterLessMinite, "Only show debuffs that are 60sec or shorter.")

--[=[
    local debuffDotChecker = CreateCheckbox("debuffDotChecker", "DoT Indicator", PlayerAuraFramedeBuffEnable)
    debuffDotChecker:SetPoint("TOPLEFT", PlayerAuraFramedeBuffFilterLessMinite, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(debuffDotChecker, "Adds an icon next to the player\ndebuffs if one of them is a DoT.")

]=]



    local playerAuraGlows = CreateCheckbox("playerAuraGlows", "Extra Aura Settings", playerAuraFiltering)
    playerAuraGlows:SetPoint("TOPLEFT", PlayerAuraFramedeBuffFilterLessMinite, "BOTTOMLEFT", -30, -20)
    playerAuraGlows:HookScript("OnClick", function ()
        CheckAndToggleCheckboxes(playerAuraGlows)
    end)
    --playerAuraGlows:Disable()
    --playerAuraGlows:SetAlpha(0.5)

--[=[
    local playerAuraPandemicGlow = CreateCheckbox("playerAuraPandemicGlow", "Pandemic Glow", playerAuraGlows)
    playerAuraPandemicGlow:SetPoint("TOPLEFT", playerAuraGlows, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(playerAuraPandemicGlow, "Red glow on whitelisted auras with less than 5 seconds left.")

]=]


    local playerAuraImportantGlow = CreateCheckbox("playerAuraImportantGlow", "Important Glow", playerAuraGlows)
    playerAuraImportantGlow:SetPoint("TOPLEFT", playerAuraGlows, "BOTTOMLEFT", 15, pixelsBetweenBoxes)
    CreateTooltip(playerAuraImportantGlow, "Green glow on auras marked as important in whitelist")

    local addCooldownFramePlayerBuffs = CreateCheckbox("addCooldownFramePlayerBuffs", "Buff Cooldown", playerAuraGlows)
    addCooldownFramePlayerBuffs:SetPoint("TOPLEFT", playerAuraImportantGlow, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(addCooldownFramePlayerBuffs, "Buff Cooldown", "Add a cooldown spiral to player buffs similar to other aura icons.")

    local addCooldownFramePlayerDebuffs = CreateCheckbox("addCooldownFramePlayerDebuffs", "Debuff Cooldown", playerAuraGlows)
    addCooldownFramePlayerDebuffs:SetPoint("TOPLEFT", addCooldownFramePlayerBuffs, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(addCooldownFramePlayerDebuffs, "Debuff Cooldown", "Add a cooldown spiral to player debuffs similar to other aura icons.")

    local hideDefaultPlayerAuraDuration = CreateCheckbox("hideDefaultPlayerAuraDuration", "Hide Duration Text", playerAuraGlows)
    hideDefaultPlayerAuraDuration:SetPoint("TOPLEFT", addCooldownFramePlayerDebuffs, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideDefaultPlayerAuraDuration, "Hide Duration Text", "Hide the default duration text if Buff Cooldown or Debuff Cooldown is on.")

    local hideDefaultPlayerAuraCdText = CreateCheckbox("hideDefaultPlayerAuraCdText", "Hide CD Duration Text", playerAuraGlows)
    hideDefaultPlayerAuraCdText:SetPoint("TOPLEFT", hideDefaultPlayerAuraDuration, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideDefaultPlayerAuraCdText, "Hide CD Duration Text", "Hide the cd text on the new cooldown frame from Buff & Debuff Cooldown.", "This setting will get overwritten by OmniCC unless you make a rule for it.")


    local personalAuraSettings = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    personalAuraSettings:SetPoint("TOP", PlayerAuraBorder, "BOTTOM", 0, -5)
    personalAuraSettings:SetText("Player Aura Settings:")



    local targetAndFocusAuraSettings = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetAndFocusAuraSettings:SetPoint("TOP", targetAuraBorder, "BOTTOMRIGHT", 20, -5)
    targetAndFocusAuraSettings:SetText("Target & Focus Aura Settings:")

    --------------------------
    -- Frame settings
    --------------------------






    local targetAndFocusAuraScale = CreateSlider(playerAuraFiltering, "All Aura size", 0.7, 2, 0.01, "targetAndFocusAuraScale")
    targetAndFocusAuraScale:SetPoint("TOP", targetAndFocusAuraSettings, "BOTTOM", 0, -20)
    CreateTooltip(targetAndFocusAuraScale, "Adjusts the size of ALL auras")

    local targetAndFocusSmallAuraScale = CreateSlider(playerAuraFiltering, "Small Aura size", 0.7, 2, 0.01, "targetAndFocusSmallAuraScale")
    targetAndFocusSmallAuraScale:SetPoint("TOP", targetAndFocusAuraScale, "BOTTOM", 0, -20)
    CreateTooltip(targetAndFocusSmallAuraScale, "Adjusts the size of small auras / auras that are not yours.")

    local sameSizeAuras = CreateCheckbox("sameSizeAuras", "Same Size", playerAuraFiltering)
    sameSizeAuras:SetPoint("LEFT", targetAndFocusSmallAuraScale, "RIGHT", 3, 0)
    CreateTooltipTwo(sameSizeAuras, "Same Size", "Enable same sized auras.\n\nBy default your own auras are a little bigger than others. This makes them same size.")
    sameSizeAuras:HookScript("OnClick", function(self)
        if self:GetChecked() then
            DisableElement(targetAndFocusSmallAuraScale)
        else
            EnableElement(targetAndFocusSmallAuraScale)
        end
    end)
    if BetterBlizzFramesDB.sameSizeAuras then
        DisableElement(targetAndFocusSmallAuraScale)
    end

    local enlargedAuraSize = CreateSlider(playerAuraFiltering, "Enlarged Aura Scale", 1, 2, 0.01, "enlargedAuraSize")
    enlargedAuraSize:SetPoint("TOP", targetAndFocusSmallAuraScale, "BOTTOM", 0, -20)
    CreateTooltip(enlargedAuraSize, "The scale of how much bigger you want enlarged auras to be")

    local compactedAuraSize = CreateSlider(playerAuraFiltering, "Compacted Aura Scale", 0.3, 1.5, 0.01, "compactedAuraSize")
    compactedAuraSize:SetPoint("TOP", enlargedAuraSize, "BOTTOM", 0, -20)
    CreateTooltip(compactedAuraSize, "The scale of how much smaller you want compacted auras to be")

    local targetAndFocusAurasPerRow = CreateSlider(playerAuraFiltering, "Max auras per row", 1, 12, 1, "targetAndFocusAurasPerRow")
    targetAndFocusAurasPerRow:SetPoint("TOPLEFT", compactedAuraSize, "BOTTOMLEFT", 0, -17)

    local targetAndFocusAuraOffsetX = CreateSlider(playerAuraFiltering, "x offset", -50, 50, 1, "targetAndFocusAuraOffsetX", "X")
    targetAndFocusAuraOffsetX:SetPoint("TOPLEFT", targetAndFocusAurasPerRow, "BOTTOMLEFT", 0, -17)

    local targetAndFocusAuraOffsetY = CreateSlider(playerAuraFiltering, "y offset", -50, 50, 1, "targetAndFocusAuraOffsetY", "Y")
    targetAndFocusAuraOffsetY:SetPoint("TOPLEFT", targetAndFocusAuraOffsetX, "BOTTOMLEFT", 0, -17)

    local targetAndFocusHorizontalGap = CreateSlider(playerAuraFiltering, "Horizontal gap", 0, 18, 0.5, "targetAndFocusHorizontalGap", "X")
    targetAndFocusHorizontalGap:SetPoint("TOPLEFT", targetAndFocusAuraOffsetY, "BOTTOMLEFT", 0, -17)

    local targetAndFocusVerticalGap = CreateSlider(playerAuraFiltering, "Vertical gap", 0, 18, 0.5, "targetAndFocusVerticalGap", "Y")
    targetAndFocusVerticalGap:SetPoint("TOPLEFT", targetAndFocusHorizontalGap, "BOTTOMLEFT", 0, -17)

    local auraTypeGap = CreateSlider(playerAuraFiltering, "Aura Type Gap", 0, 30, 1, "auraTypeGap", "Y")
    auraTypeGap:SetPoint("TOPLEFT", targetAndFocusVerticalGap, "BOTTOMLEFT", 0, -17)
    CreateTooltip(auraTypeGap, "The gap size between buffs & debuffs")

    local auraStackSize = CreateSlider(playerAuraFiltering, "Aura Stack Size", 0.4, 2, 0.01, "auraStackSize")
    auraStackSize:SetPoint("TOPLEFT", auraTypeGap, "BOTTOMLEFT", 0, -17)
    CreateTooltipTwo(auraStackSize, "Aura Stack Size", "Size of the stack number on auras.")

--[=[
    local maxTargetBuffs = CreateSlider(playerAuraFiltering, "Max Buffs", 1, 32, 1, "maxTargetBuffs")
    maxTargetBuffs:SetPoint("TOPLEFT", targetAndFocusVerticalGap, "BOTTOMLEFT", 0, -17)
    maxTargetBuffs:Disable()
    maxTargetBuffs:SetAlpha(0.5)

    local maxTargetDebuffs = CreateSlider(playerAuraFiltering, "Max Debuffs", 1, 32, 1, "maxTargetDebuffs")
    maxTargetDebuffs:SetPoint("TOPLEFT", maxTargetBuffs, "BOTTOMLEFT", 0, -17)
    maxTargetDebuffs:Disable()
    maxTargetDebuffs:SetAlpha(0.5)

]=]



    local playerAuraSpacingX = CreateSlider(playerAuraFiltering, "Horizontal Padding", 0, 10, 1, "playerAuraSpacingX", "X")
    playerAuraSpacingX:SetPoint("TOP", PlayerAuraBorder, "BOTTOM", 0, -35)
    CreateTooltip(playerAuraSpacingX, "Horizontal padding for aura icons.\nAllows you to set gap to 0 (Blizz limit is 5 in EditMode).", "ANCHOR_LEFT")

    local playerAuraSpacingY = CreateSlider(playerAuraFiltering, "Vertical Padding", -10, 10, 1, "playerAuraSpacingY", "Y")
    playerAuraSpacingY:SetPoint("TOP", playerAuraSpacingX, "BOTTOM", 0, -15)

    local useEditMode = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    useEditMode:SetPoint("TOP", PlayerAuraBorder, "BOTTOM", 0, -90)
    useEditMode:SetText("Use Edit Mode for other settings.")

    local moreAuraSettings = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    moreAuraSettings:SetPoint("TOP", PlayerAuraBorder, "BOTTOM", -100, -140)
    moreAuraSettings:SetText("More Aura Settings:")

    local displayDispelGlowAlways = CreateCheckbox("displayDispelGlowAlways", "Always show purge texture", playerAuraFiltering)
    displayDispelGlowAlways:SetPoint("TOPLEFT", moreAuraSettings, "BOTTOMLEFT", -10, -3)
    CreateTooltip(displayDispelGlowAlways, "Always display the purge/steal texture on auras\nregardless if you have a dispel/purge/steal ability or not.")

    local onlyPandemicAuraMine = CreateCheckbox("onlyPandemicAuraMine", "Only Pandemic Mine", playerAuraFiltering)
    onlyPandemicAuraMine:SetPoint("TOPLEFT", displayDispelGlowAlways, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(onlyPandemicAuraMine, "Only show the red pandemic aura glow on my own auras", "ANCHOR_LEFT")

    local changePurgeTextureColor = CreateCheckbox("changePurgeTextureColor", "Change Purge Texture Color", playerAuraFiltering)
    changePurgeTextureColor:SetPoint("TOPLEFT", onlyPandemicAuraMine, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(changePurgeTextureColor, "Change Purge Texture Color")

    local increaseAuraStrata = CreateCheckbox("increaseAuraStrata", "Increase Aura Frame Strata", playerAuraFiltering)
    increaseAuraStrata:SetPoint("TOPLEFT", changePurgeTextureColor, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(increaseAuraStrata, "Increase Aura Frame Strata", "Inrease the strata of auras in order to make them appear above the Target & ToT Frames so they are not covered.")

    local function OpenColorPicker(colorData)
        local r, g, b, a = unpack(colorData)
        local function updateColors()
            colorData[1], colorData[2], colorData[3], colorData[4] = r, g, b, a
            BBF.RefreshAllAuraFrames()
        end

        local function swatchFunc()
            r, g, b = ColorPickerFrame:GetColorRGB()
            updateColors()
        end

        local function opacityFunc()
            a = ColorPickerFrame:GetColorAlpha()
            updateColors()
        end

        local function cancelFunc(previousValues)
            if previousValues then
                r, g, b, a = unpack(previousValues)
                updateColors()
            end
        end

        ColorPickerFrame.previousValues = {r, g, b, a}

        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b, opacity = a, hasOpacity = true,
            swatchFunc = swatchFunc,
            opacityFunc = opacityFunc,
            cancelFunc = cancelFunc
        })
    end

    local dispelGlowButton = CreateFrame("Button", nil, playerAuraFiltering, "UIPanelButtonTemplate")
    dispelGlowButton:SetText("Color")
    dispelGlowButton:SetPoint("LEFT", changePurgeTextureColor.text, "RIGHT", -1, 0)
    dispelGlowButton:SetSize(43, 18)
    dispelGlowButton:SetScript("OnClick", function()
        OpenColorPicker(BetterBlizzFramesDB.purgeTextureColorRGB)
    end)
    CreateTooltip(dispelGlowButton, "Dispel/Purge Glow Color.")

    local sortingSettings = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sortingSettings:SetPoint("TOPLEFT", increaseAuraStrata, "BOTTOMLEFT", 10, -4)
    sortingSettings:SetText("Sorting:")

    local customImportantAuraSorting = CreateCheckbox("customImportantAuraSorting", "Sort Important Auras", playerAuraFiltering)
    customImportantAuraSorting:SetPoint("TOPLEFT", increaseAuraStrata, "BOTTOMLEFT", 0, -20)
    CreateTooltip(customImportantAuraSorting, "Show Important Auras first in the list\n\n(Remember to enable Important Auras on\nTarget/Focus Frame and check checkbox in whitelist)")

    local customLargeSmallAuraSorting = CreateCheckbox("customLargeSmallAuraSorting", "Sort Enlarged & Compact Auras", playerAuraFiltering)
    customLargeSmallAuraSorting:SetPoint("TOPLEFT", customImportantAuraSorting, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(customLargeSmallAuraSorting, "Show Enlarged Auras first in the list and Compact Auras last.\n\n(Remember to enable Enlarged Auras on\nTarget/Focus Frame and check checkbox in whitelist)")

    local allowLargeAuraFirst = CreateCheckbox("allowLargeAuraFirst", "Sort Enlarged before Important", playerAuraFiltering)
    allowLargeAuraFirst:SetPoint("TOPLEFT", customLargeSmallAuraSorting, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(allowLargeAuraFirst, "If there are both Enlarged and Important auras\nthen show the Enlarged ones first.")

    local purgeableBuffSorting = CreateCheckbox("purgeableBuffSorting", "Sort Purgeable Auras", playerAuraFiltering)
    purgeableBuffSorting:SetPoint("TOPLEFT", allowLargeAuraFirst, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(purgeableBuffSorting, "Sort Purgeable Auras", "Sort purgeable auras before normal auras.\nEnlarged and Important auras will still be prioritized over Purgeable ones unless \"Sort Purgeable before Enlarged/Important\" is checked.")

    local purgeableBuffSortingFirst = CreateCheckbox("purgeableBuffSortingFirst", "Sort Purgeable before Enlarged/Important", purgeableBuffSorting)
    purgeableBuffSortingFirst:SetPoint("TOPLEFT", purgeableBuffSorting, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(purgeableBuffSortingFirst, "Sort Purgeable before Enlarged/Important", "Sort Purgeable before Enlarged and Important auras.")
    purgeableBuffSorting:HookScript("OnClick", function(self)
        CheckAndToggleCheckboxes(purgeableBuffSorting)
    end)

    -- local customPandemicAuraSorting = CreateCheckbox("customPandemicAuraSorting", "Sort Pandemic Auras before all", playerAuraFiltering)
    -- customPandemicAuraSorting:SetPoint("TOPLEFT", allowLargeAuraFirst, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    -- CreateTooltip(customPandemicAuraSorting, "Sort Pandemic Auras before all other auras during their pandemic window.")




    playerAuraFiltering:HookScript("OnClick", function (self)
        if self:GetChecked() then
            --asd
        else
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end

        CheckAndToggleCheckboxes(playerAuraFiltering)
    end)

    local betaHighlightIcon = playerAuraFiltering:CreateTexture(nil, "BACKGROUND")
    betaHighlightIcon:SetAtlas("CharacterCreate-NewLabel")
    betaHighlightIcon:SetSize(42, 34)
    betaHighlightIcon:SetPoint("RIGHT", playerAuraFiltering, "LEFT", 8, 0)
end

local function guiMisc()
    local guiMisc = CreateFrame("Frame")
    guiMisc.name = "Misc"--"|A:GarrMission_CurrencyIcon-Material:19:19|a Misc"
    guiMisc.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(guiMisc)
    local guiMiscSubcategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, guiMisc, guiMisc.name, guiMisc.name)
    guiMiscSubcategory.ID = guiMisc.name;
    CreateTitle(guiMisc)

    local bgImg = guiMisc:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiMisc, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local settingsText = guiMisc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsText:SetPoint("TOPLEFT", guiMisc, "TOPLEFT", 20, -10)
    settingsText:SetText("Misc settings")
    local miscSettingsIcon = guiMisc:CreateTexture(nil, "ARTWORK")
    miscSettingsIcon:SetAtlas("optionsicon-brown")
    miscSettingsIcon:SetSize(22, 22)
    miscSettingsIcon:SetPoint("RIGHT", settingsText, "LEFT", -3, -1)

    local normalizeGameMenu = CreateCheckbox("normalizeGameMenu", "Normal Size Game Menu", guiMisc)
    normalizeGameMenu:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", -4, pixelsOnFirstBox)
    CreateTooltipTwo(normalizeGameMenu, "Normal Size Game Menu", "Enable to make the Game Menu (Escape) normal size again.\nWe're old boomers but we're not that old jesus.")
    normalizeGameMenu:HookScript("OnClick", function(self)
        if self:GetChecked() then
            BBF.NormalizeGameMenu(true)
        else
            BBF.NormalizeGameMenu(false)
        end
    end)

    local minimizeObjectiveTracker = CreateCheckbox("minimizeObjectiveTracker", "Minimize Objective Frame Better", guiMisc, nil, BBF.MinimizeObjectiveTracker)
    minimizeObjectiveTracker:SetPoint("TOPLEFT", normalizeGameMenu, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(minimizeObjectiveTracker, "Minimize Objective Frame Better", "Also minimize the objectives header when clicking the -+ button |A:UI-QuestTrackerButton-Collapse-All:19:19|a")

    local hideUiErrorFrame = CreateCheckbox("hideUiErrorFrame", "Hide UI Error Frame", guiMisc, nil, BBF.HideFrames)
    hideUiErrorFrame:SetPoint("TOPLEFT", minimizeObjectiveTracker, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(hideUiErrorFrame, "Hide UI Error Frame", "Hides the UI Error Frame (The red text displaying \"Not enough mana\" etc)")

    local hideMinimap = CreateCheckbox("hideMinimap", "Hide Minimap", guiMisc, nil, BBF.MinimapHider)
    hideMinimap:SetPoint("TOPLEFT", hideUiErrorFrame, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local hideMinimapButtons = CreateCheckbox("hideMinimapButtons", "Hide Minimap Buttons (still shows on mouseover)", guiMisc, nil, BBF.HideFrames)
    hideMinimapButtons:SetPoint("TOPLEFT", hideMinimap, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    hideMinimapButtons:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)

    local hideMinimapAuto = CreateCheckbox("hideMinimapAuto", "Hide Minimap during Arena", guiMisc)
    hideMinimapAuto:SetPoint("TOPLEFT", hideMinimapButtons, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideMinimapAuto, "Automatically hide Minimap during arena games.")
    hideMinimapAuto:HookScript("OnClick", function()
        CheckAndToggleCheckboxes(hideMinimapAuto)
        BBF.MinimapHider()
    end)

    local hideMinimapAutoQueueEye = CreateCheckbox("hideMinimapAutoQueueEye", "Hide Queue Status Eye during Arena", guiMisc)
    hideMinimapAutoQueueEye:SetPoint("TOPLEFT", hideMinimapAuto, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideMinimapAutoQueueEye, "Automatically hide Queue Status Eye during arena games.")
    hideMinimapAutoQueueEye:HookScript("OnClick", function()
        BBF.MinimapHider()
    end)

    local hideObjectiveTracker = CreateCheckbox("hideObjectiveTracker", "Hide Objective Tracker during Arena", guiMisc)
    hideObjectiveTracker:SetPoint("TOPLEFT", hideMinimapAutoQueueEye, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideObjectiveTracker, "Automatically hide Objective Tracker during arena games.")
    hideObjectiveTracker:HookScript("OnClick", function()
        BBF.MinimapHider()
    end)

    local recolorTempHpLoss = CreateCheckbox("recolorTempHpLoss", "Recolor Temp Max HP Loss", guiMisc)
    recolorTempHpLoss:SetPoint("TOPLEFT", hideObjectiveTracker, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(recolorTempHpLoss, "Recolor Temp Max HP Loss", "Recolor the temp max hp loss on Player/Target/Focus/Party frame to a softer red color.")
    recolorTempHpLoss:HookScript("OnClick", function()
        BBF.RecolorHpTempLoss()
    end)

    local hideActionBarHotKey = CreateCheckbox("hideActionBarHotKey", "Hide ActionBar Keybinds", guiMisc, nil, BBF.HideFrames)
    hideActionBarHotKey:SetPoint("TOPLEFT", recolorTempHpLoss, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideActionBarHotKey, "Hides the keybind on default actionbars (I highly recommend getting Bartender though, doesnt bug like default does)")

    local hideActionBarMacroName = CreateCheckbox("hideActionBarMacroName", "Hide ActionBar Macro Name", guiMisc, nil, BBF.HideFrames)
    hideActionBarMacroName:SetPoint("TOPLEFT", hideActionBarHotKey, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideActionBarMacroName, "Hides the macro name on default actionbars (I highly recommend getting Bartender though, doesnt bug like default does)")

    local hideStanceBar = CreateCheckbox("hideStanceBar", "Hide StanceBar (ActionBar)", guiMisc, nil, BBF.HideFrames)
    hideStanceBar:SetPoint("TOPLEFT", hideActionBarMacroName, "BOTTOMLEFT", 0, pixelsBetweenBoxes)

    local hideDragonFlying = CreateCheckbox("hideDragonFlying", "Auto-hide Dragonriding (Temporary)", guiMisc)
    hideDragonFlying:SetPoint("TOPLEFT", hideStanceBar, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(hideDragonFlying, "Automatically hide the dragon riding thing\nin zones where it shouldnt be showing.\n\n(Blizzard pls fix ur shit)")

    local stealthIndicatorPlayer = CreateCheckbox("stealthIndicatorPlayer", "Stealth Indicator (Temporary?)", guiMisc, nil, BBF.StealthIndicator)
    stealthIndicatorPlayer:SetPoint("TOPLEFT", hideDragonFlying, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    stealthIndicatorPlayer:HookScript("OnClick", function(self)
        if not self:GetChecked() then
            StaticPopup_Show("BBF_CONFIRM_RELOAD")
        end
    end)
    CreateTooltip(stealthIndicatorPlayer, "Add a blue border texture around the\nplayer frame during stealth abilities")

    local useMiniFocusFrame = CreateCheckbox("useMiniFocusFrame", "Enable Mini-FocusFrame", guiMisc, nil, BBF.MiniFocusFrame)
    useMiniFocusFrame:SetPoint("TOPLEFT", stealthIndicatorPlayer, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(useMiniFocusFrame, "Removes healthbar and manabar from the FocusFrame\nand just leaves Portrait and name.\n\nMove castbar and/or disable auras to your liking.")

    local surrenderArena = CreateCheckbox("surrenderArena", "Surrender over Leaving Arena", guiMisc)
    surrenderArena:SetPoint("TOPLEFT", useMiniFocusFrame, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(surrenderArena, "Surrender over Leave", "Makes typing /afk in arena Surrender instead of Leaving so you don't lose honor/conquest gain.")

    local druidOverstacks = CreateCheckbox("druidOverstacks", "Druid: Color Berserk Overstack Combo Points Blue", guiMisc)
    druidOverstacks:SetPoint("TOPLEFT", surrenderArena, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltipTwo(druidOverstacks, "Druid: Color Berserk Overstack Combo Points Blue", "Color the Druid Berserk Overstack Combo Points blue similar to Rogue's Echoing Reprimand.")

    local moveResourceToTarget = CreateCheckbox("moveResourceToTarget", "Move Resource to TargetFrame", guiMisc)
    moveResourceToTarget:SetPoint("TOPLEFT", druidOverstacks, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTarget, "Move resource (Combo points, Warlock shards etc) to the TargetFrame.")

    local moveResourceToTargetRogue = CreateCheckbox("moveResourceToTargetRogue", "Rogue: Combo Points", moveResourceToTarget)
    moveResourceToTargetRogue:SetPoint("TOPLEFT", moveResourceToTarget, "BOTTOMLEFT", 12, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetRogue, "Move Rogue Combo Points to TargetFrame.")
    moveResourceToTargetRogue:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetDruid = CreateCheckbox("moveResourceToTargetDruid", "Druid: Combo Points", moveResourceToTarget)
    moveResourceToTargetDruid:SetPoint("TOPLEFT", moveResourceToTargetRogue, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetDruid, "Move Druid Combo Points to TargetFrame.")
    moveResourceToTargetDruid:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetMonk = CreateCheckbox("moveResourceToTargetMonk", "Monk: Chi Points", moveResourceToTarget)
    moveResourceToTargetMonk:SetPoint("TOPLEFT", moveResourceToTargetDruid, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetMonk, "Move Monk Chi Points to TargetFrame.")
    moveResourceToTargetMonk:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetWarlock = CreateCheckbox("moveResourceToTargetWarlock", "Warlock: Shards", moveResourceToTarget)
    moveResourceToTargetWarlock:SetPoint("TOPLEFT", moveResourceToTargetMonk, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetWarlock, "Move Warlock Shards to TargetFrame.")
    moveResourceToTargetWarlock:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetEvoker = CreateCheckbox("moveResourceToTargetEvoker", "Evoker: Essence", moveResourceToTarget)
    moveResourceToTargetEvoker:SetPoint("TOPLEFT", moveResourceToTargetWarlock, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetEvoker, "Move Evoker Essence to TargetFrame.")
    moveResourceToTargetEvoker:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    local moveResourceToTargetMage = CreateCheckbox("moveResourceToTargetMage", "Mage: Arcane Charges", moveResourceToTarget)
    moveResourceToTargetMage:SetPoint("TOPLEFT", moveResourceToTargetEvoker, "BOTTOMLEFT", 0, pixelsBetweenBoxes)
    CreateTooltip(moveResourceToTargetMage, "Move Mage Arcane Charges to TargetFrame.")
    moveResourceToTargetMage:HookScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_RELOAD")
    end)

    moveResourceToTarget:HookScript("OnClick", function()
        CheckAndToggleCheckboxes(moveResourceToTarget)
    end)
end

local function guiChatFrame()

    local guiChatFrame = CreateFrame("Frame")
    guiChatFrame.name = "ChatFrame"
    guiChatFrame.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(guiChatFrame)

    local bgImg = guiChatFrame:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiChatFrame, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local playerAuraGlows = CreateCheckbox("playerAuraGlows", "Extra Aura Glow", guiChatFrame)
    playerAuraGlows:SetPoint("TOPLEFT", debuffDotChecker, "BOTTOMLEFT", -15, -22)
end

local function guiImportAndExport()
    local guiImportAndExport = CreateFrame("Frame")
    guiImportAndExport.name = "Import & Export"--"|A:GarrMission_CurrencyIcon-Material:19:19|a Misc"
    guiImportAndExport.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(guiImportAndExport)
    local guiImportSubcategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, guiImportAndExport, guiImportAndExport.name, guiImportAndExport.name)
    guiImportSubcategory.ID = guiImportAndExport.name;
    CreateTitle(guiImportAndExport)

    local bgImg = guiImportAndExport:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiImportAndExport, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local text = guiImportAndExport:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    text:SetText("BETA")
    text:SetPoint("TOP", guiImportAndExport, "TOPRIGHT", -220, 0)

    local text2 = guiImportAndExport:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text2:SetText("Please backup your settings just in case.\nWTF\\Account\\ACCOUNT_NAME\\SavedVariables\n\nWhile this is beta any export codes\nwill be temporary until non-beta.")
    text2:SetPoint("TOP", text, "BOTTOM", 0, 0)

    local fullProfile = CreateImportExportUI(guiImportAndExport, "Full Profile", BetterBlizzFramesDB, 20, -20, "fullProfile")

    local auraWhitelist = CreateImportExportUI(fullProfile, "Aura Whitelist", BetterBlizzFramesDB.auraWhitelist, 0, -100, "auraWhitelist")
    local auraBlacklist = CreateImportExportUI(auraWhitelist, "Aura Blacklist", BetterBlizzFramesDB.auraBlacklist, 210, 0, "auraBlacklist")

    local importPVPWhitelist = CreateFrame("Button", nil, guiImportAndExport, "UIPanelButtonTemplate")
    importPVPWhitelist:SetSize(150, 35)
    importPVPWhitelist:SetPoint("TOP", auraWhitelist, "BOTTOM", 0, -25)
    importPVPWhitelist:SetText("Import PvP Whitelist")
    importPVPWhitelist:SetScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_PVP_WHITELIST")
    end)
    CreateTooltipTwo(importPVPWhitelist, "Import PvP Whitelist", "Import a color coded Whitelist with most important Offensives, Defensives & Freedoms for TWW added.\n\nThis will only add NEW entries and not mess with existing ones in your current whitelist.\n\nWill tweak this as time goes on probably.")

    local importPVPBlacklist = CreateFrame("Button", nil, guiImportAndExport, "UIPanelButtonTemplate")
    importPVPBlacklist:SetSize(150, 35)
    importPVPBlacklist:SetPoint("TOP", auraBlacklist, "BOTTOM", 0, -25)
    importPVPBlacklist:SetText("Import PvP Blacklist")
    importPVPBlacklist:SetScript("OnClick", function()
        StaticPopup_Show("BBF_CONFIRM_PVP_BLACKLIST")
    end)
    CreateTooltipTwo(importPVPBlacklist, "Import PvP Blacklist", "Import a Blacklist with A LOT (750+) of trash buffs blacklisted.\n\nThis will only add NEW entries and not mess with existing ones already in your blacklist.")

end

local function guiSupport()
    local guiSupport = CreateFrame("Frame")
    guiSupport.name = "|A:GarrisonTroops-Health:10:10|a Support & Code"
    guiSupport.parent = BetterBlizzFrames.name
    --InterfaceOptions_AddCategory(guiSupport)
    local guiSupportSubCategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, guiSupport, guiSupport.name, guiSupport.name)
    guiSupportSubCategory.ID = guiSupport.name;
    CreateTitle(guiSupport)

    local bgImg = guiSupport:CreateTexture(nil, "BACKGROUND")
    bgImg:SetAtlas("professions-recipe-background")
    bgImg:SetPoint("CENTER", guiSupport, "CENTER", -8, 4)
    bgImg:SetSize(680, 610)
    bgImg:SetAlpha(0.4)
    bgImg:SetVertexColor(0,0,0)

    local discordLinkEditBox = CreateFrame("EditBox", nil, guiSupport, "InputBoxTemplate")
    discordLinkEditBox:SetPoint("TOPLEFT", guiSupport, "TOPLEFT", 25, -45)
    discordLinkEditBox:SetSize(180, 20)
    discordLinkEditBox:SetAutoFocus(false)
    discordLinkEditBox:SetFontObject("ChatFontSmall")
    discordLinkEditBox:SetText("https://discord.gg/cjqVaEMm25")
    discordLinkEditBox:SetCursorPosition(0) -- Places cursor at start of the text
    discordLinkEditBox:ClearFocus() -- Removes focus from the EditBox
    discordLinkEditBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus() -- Allows user to press escape to unfocus the EditBox
    end)

    -- Make the EditBox text selectable and readonly
    discordLinkEditBox:SetScript("OnTextChanged", function(self)
        self:SetText("https://discord.gg/cjqVaEMm25")
    end)
    --discordLinkEditBox:HighlightText() -- Highlights the text for easy copying
    discordLinkEditBox:SetScript("OnCursorChanged", function() end) -- Prevents cursor changes
    discordLinkEditBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end) -- Re-highlights text when focused
    discordLinkEditBox:SetScript("OnMouseUp", function(self)
        if not self:IsMouseOver() then
            self:ClearFocus()
        end
    end)

    local discordText = guiSupport:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    discordText:SetPoint("BOTTOM", discordLinkEditBox, "TOP", 18, 8)
    discordText:SetText("Join the Discord for info\nand help with BBP/BBF")

    local joinDiscord = guiSupport:CreateTexture(nil, "ARTWORK")
    joinDiscord:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\logos\\discord.tga")
    joinDiscord:SetSize(52, 52)
    joinDiscord:SetPoint("RIGHT", discordText, "LEFT", 0, 1)

    local supportText = guiSupport:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    supportText:SetPoint("TOP", guiSupport, "TOP", 0, -90)
    supportText:SetText("If you wish to support me and my projects\nit would be greatly appreciated |A:GarrisonTroops-Health:10:10|a")

    local boxOne = CreateFrame("EditBox", nil, guiSupport, "InputBoxTemplate")
    boxOne:SetPoint("LEFT", discordLinkEditBox, "RIGHT", 50, 0)
    boxOne:SetSize(180, 20)
    boxOne:SetAutoFocus(false)
    boxOne:SetFontObject("ChatFontSmall")
    boxOne:SetText("https://patreon.com/bodifydev")
    boxOne:SetCursorPosition(0) -- Places cursor at start of the text
    boxOne:ClearFocus() -- Removes focus from the EditBox
    boxOne:SetScript("OnEscapePressed", function(self)
        self:ClearFocus() -- Allows user to press escape to unfocus the EditBox
    end)

    -- Make the EditBox text selectable and readonly
    boxOne:SetScript("OnTextChanged", function(self)
        self:SetText("https://patreon.com/bodifydev")
    end)
    --boxOne:HighlightText() -- Highlights the text for easy copying
    boxOne:SetScript("OnCursorChanged", function() end) -- Prevents cursor changes
    boxOne:SetScript("OnEditFocusGained", function(self) self:HighlightText() end) -- Re-highlights text when focused
    boxOne:SetScript("OnMouseUp", function(self)
        if not self:IsMouseOver() then
            self:ClearFocus()
        end
    end)

    local boxOneTex = guiSupport:CreateTexture(nil, "ARTWORK")
    boxOneTex:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\logos\\patreon.tga")
    boxOneTex:SetSize(58, 58)
    boxOneTex:SetPoint("BOTTOMLEFT", boxOne, "TOPLEFT", 3, -2)

    local patText = guiSupport:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    patText:SetPoint("LEFT", boxOneTex, "RIGHT", 14, -1)
    patText:SetText("Patreon")

    local boxTwo = CreateFrame("EditBox", nil, guiSupport, "InputBoxTemplate")
    boxTwo:SetPoint("LEFT", boxOne, "RIGHT", 35, 0)
    boxTwo:SetSize(180, 20)
    boxTwo:SetAutoFocus(false)
    boxTwo:SetFontObject("ChatFontSmall")
    boxTwo:SetText("https://paypal.me/bodifydev")
    boxTwo:SetCursorPosition(0) -- Places cursor at start of the text
    boxTwo:ClearFocus() -- Removes focus from the EditBox
    boxTwo:SetScript("OnEscapePressed", function(self)
        self:ClearFocus() -- Allows user to press escape to unfocus the EditBox
    end)

    -- Make the EditBox text selectable and readonly
    boxTwo:SetScript("OnTextChanged", function(self)
        self:SetText("https://paypal.me/bodifydev")
    end)
    --boxTwo:HighlightText() -- Highlights the text for easy copying
    boxTwo:SetScript("OnCursorChanged", function() end) -- Prevents cursor changes
    boxTwo:SetScript("OnEditFocusGained", function(self) self:HighlightText() end) -- Re-highlights text when focused
    boxTwo:SetScript("OnMouseUp", function(self)
        if not self:IsMouseOver() then
            self:ClearFocus()
        end
    end)

    local boxTwoTex = guiSupport:CreateTexture(nil, "ARTWORK")
    boxTwoTex:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\logos\\paypal.tga")
    boxTwoTex:SetSize(58, 58)
    boxTwoTex:SetPoint("BOTTOMLEFT", boxTwo, "TOPLEFT", 3, -2)

    local palText = guiSupport:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    palText:SetPoint("LEFT", boxTwoTex, "RIGHT", 14, -1)
    palText:SetText("Paypal")







    -- Implementing the code editor inside the guiSupport frame
    local FAIAP = BBF.indent

    -- Define your color table for syntax highlighting
    local colorTable = {
        [FAIAP.tokens.TOKEN_SPECIAL] = "|c00F1D710",
        [FAIAP.tokens.TOKEN_KEYWORD] = "|c00BD6CCC",
        [FAIAP.tokens.TOKEN_COMMENT_SHORT] = "|c00999999",
        [FAIAP.tokens.TOKEN_COMMENT_LONG] = "|c00999999",
        [FAIAP.tokens.TOKEN_STRING] = "|c00E2A085",
        [FAIAP.tokens.TOKEN_NUMBER] = "|c00B1FF87",
        [FAIAP.tokens.TOKEN_ASSIGNMENT] = "|c0055ff88",
        [FAIAP.tokens.TOKEN_WOW_API] = "|c00ff8000",
        [FAIAP.tokens.TOKEN_WOW_EVENTS] = "|c004ec9b0",
        [0] = "|r",  -- Reset color
    }

    -- Add a scroll frame for the code editor
    local scrollFrame = CreateFrame("ScrollFrame", nil, guiSupport, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOP", guiSupport, "TOP", -10, -170)
    scrollFrame:SetSize(620, 370)  -- Fixed size for the entire editor box

    -- Label for the custom code box
    local customCodeText = guiSupport:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    customCodeText:SetPoint("BOTTOM", scrollFrame, "TOP", 0, 5)
    customCodeText:SetText("Enter Custom Lua Code (Executes at Login)")

    -- Create the code editor
    local codeEditBox = CreateFrame("EditBox", nil, scrollFrame)
    codeEditBox:SetMultiLine(true)
    codeEditBox:SetFontObject("ChatFontSmall")
    codeEditBox:SetSize(600, 370)  -- Smaller than the scroll frame to allow scrolling
    codeEditBox:SetAutoFocus(false)
    codeEditBox:SetCursorPosition(0)
    codeEditBox:SetText(BetterBlizzFramesDB.customCode or "")
    codeEditBox:ClearFocus()

    -- Attach the EditBox to the scroll frame
    scrollFrame:SetScrollChild(codeEditBox)

    -- Add a static custom background to the scroll frame
    local bg = scrollFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(0, 0, 0, 0.6)  -- Semi-transparent black background
    bg:SetAllPoints(scrollFrame)  -- Apply the background to the entire scroll frame

    -- Add a static custom border around the scroll frame
    local border = CreateFrame("Frame", nil, scrollFrame, BackdropTemplateMixin and "BackdropTemplate")
    border:SetPoint("TOPLEFT", scrollFrame, -2, 2)
    border:SetPoint("BOTTOMRIGHT", scrollFrame, 2, -2)
    border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
    })
    border:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)  -- Light gray border

    -- Optional: Set padding or insets if needed
    codeEditBox:SetTextInsets(6, 10, 4, 10)

    -- Track changes to detect unsaved edits
    local unsavedChanges = false
    codeEditBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            -- Compare current text with saved code
            local currentText = self:GetText()
            if currentText ~= BetterBlizzFramesDB.customCode then
                unsavedChanges = true
            else
                unsavedChanges = false
            end
        end
    end)

    -- Enable syntax highlighting and indentation with FAIAP
    FAIAP.enable(codeEditBox, colorTable, 4)  -- Assuming a tab width of 4

    local customCodeSaved = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: Custom code has been saved."

    -- Create Save Button
    local saveButton = CreateFrame("Button", nil, guiSupport, "UIPanelButtonTemplate")
    saveButton:SetSize(120, 30)
    saveButton:SetPoint("TOP", scrollFrame, "BOTTOM", 0, -10)
    saveButton:SetText("Save")
    saveButton:SetScript("OnClick", function()
        BetterBlizzFramesDB.customCode = codeEditBox:GetText()
        unsavedChanges = false
        print(customCodeSaved)
    end)

    -- Flag to prevent double triggering of the prompt
    local promptShown = false

    -- Function to show the save prompt if needed
    local function showSavePrompt()
        if unsavedChanges and not promptShown then
            promptShown = true
            StaticPopup_Show("UNSAVED_CHANGES_PROMPT")
        end
    end

    -- Prevent the EditBox from clearing focus with ESC if there are unsaved changes
    codeEditBox:SetScript("OnEscapePressed", function(self)
        if unsavedChanges then
            showSavePrompt()
        else
            self:ClearFocus()
        end
    end)

    StaticPopupDialogs["UNSAVED_CHANGES_PROMPT"] = {
        text = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames \n\nYou have unsaved changes to the custom code.\n\nDo you want to save them?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            BetterBlizzFramesDB.customCode = codeEditBox:GetText()
            unsavedChanges = false
            codeEditBox:ClearFocus()
            print(customCodeSaved)
            if BetterBlizzFramesDB.reopenOptions then
                ReloadUI()
            end
        end,
        OnCancel = function()
            unsavedChanges = false
            codeEditBox:ClearFocus()
            if BetterBlizzFramesDB.reopenOptions then
                ReloadUI()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    local reloadUiButton = CreateFrame("Button", nil, guiSupport, "UIPanelButtonTemplate")
    reloadUiButton:SetText("Reload UI")
    reloadUiButton:SetWidth(85)
    reloadUiButton:SetPoint("TOP", guiSupport, "BOTTOMRIGHT", -140, -9)
    reloadUiButton:SetScript("OnClick", function()
        if unsavedChanges then
            showSavePrompt()
            BetterBlizzFramesDB.reopenOptions = true
            return
        end
        BetterBlizzFramesDB.reopenOptions = true
        ReloadUI()
    end)
end
------------------------------------------------------------
-- GUI Setup
------------------------------------------------------------
function BBF.InitializeOptions()
    if not BetterBlizzFrames then
        BetterBlizzFrames = CreateFrame("Frame")
        BetterBlizzFrames.name = "Better|cff00c0ffBlizz|rFrames |A:gmchat-icon-blizz:16:16|a"
        --InterfaceOptions_AddCategory(BetterBlizzFrames)
        BBF.category = Settings.RegisterCanvasLayoutCategory(BetterBlizzFrames, BetterBlizzFrames.name, BetterBlizzFrames.name)
        BBF.category.ID = BetterBlizzFrames.name
        Settings.RegisterAddOnCategory(BBF.category)

        guiGeneralTab()
        guiPositionAndScale()
        guiFrameAuras()
        --guiFrameLook()
        guiCastbars()
        guiImportAndExport()
        guiMisc()
        --guiChatFrame()
        guiSupport()
    end
end