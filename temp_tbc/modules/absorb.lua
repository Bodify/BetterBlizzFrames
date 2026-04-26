local CataAbsorb = {}
CataAbsorb.spells = {
    [  7848] = {   1,    49,    0,  0,  0,  0, 0  }, -- Absorption
    [ 25750] = {   1,   247,    0, 20,  0,  0, 0  }, -- Damage Absorb
    [ 25747] = {   1,   309,    0, 20,  0,  0, 0  }, -- Damage Absorb
    [ 25746] = {   1,   391,    0, 20,  0,  0, 0  }, -- Damage Absorb
    [ 23991] = {   1,   494,    0, 20,  0,  0, 0  }, -- Damage Absorb
    [ 42137] = {   1,   399,    0,  0,  0,  0, 0  }, -- Greater Rune of Warding
    [ 11657] = {   1,    54,    0, 48,  0, 48, 0  }, -- Jang'thraze
    [  7447] = {   1,    24,    0,  0,  0,  0, 0  }, -- Lesser Absorption
    [ 42134] = {   1,   199,    0,  0,  0,  0, 0  }, -- Lesser Rune of Warding
    [  8373] = {   1,   999,    0,  0,  0,  0, 0  }, -- Mana Shield (PT)
    [  7423] = {   1,     9,    0,  0,  0,  0, 0  }, -- Minor Absorption
    [  3288] = {   1,    19,    0, 21,  0, 21, 0  }, -- Moss Hide
    [ 21956] = {   1,   349,    0, 20,  0,  0, 0  }, -- Physical Protection
    [ 34206] = {   1,  1949,    0, 40,  0,  0, 0  }, -- Physical Protection
    [ 37414] = {   1,   499,    0,  0,  0,  0, 0  }, -- Shield Block
    [ 37729] = {   1,  1079,    0, 20,  0,  0, 0  }, -- Unholy Armor
    [ 37416] = {   1,   499,    0,  0,  0,  0, 0  }, -- Weapon Deflection
    [ 28538] = {   2,  2799,    0, 40,  0,  0, 0  }, -- Holy Protection
    [  7245] = {   2,   299,    0, 20,  0,  0, 0  }, -- Holy Protection (Rank 1)
    [ 16892] = {   2,   299,    0, 20,  0,  0, 0  }, -- Holy Protection (Rank 1)
    [  7246] = {   2,   524,    0, 25,  0,  0, 0  }, -- Holy Protection (Rank 2)
    [  7247] = {   2,   674,    0, 30,  0,  0, 0  }, -- Holy Protection (Rank 3)
    [  7248] = {   2,   974,    0, 35,  0,  0, 0  }, -- Holy Protection (Rank 4)
    [  7249] = {   2,  1349,    0, 40,  0,  0, 0  }, -- Holy Protection (Rank 5)
    [ 17545] = {   2,  1949,    0, 40,  0,  0, 0  }, -- Holy Protection (Rank 6)
    [ 27536] = {   2,   299,    0, 60,  0,  0, 0  }, -- Holy Resistance
    [ 30997] = {   4,   899,    0, 40,  0,  0, 0  }, -- Fire Absorption
    [ 29432] = {   4,  1499,    0, 35,  0,  0, 0  }, -- Fire Protection
    [ 17543] = {   4,  1949,    0, 35,  0,  0, 0  }, -- Fire Protection
    [ 18942] = {   4,  1949,    0, 35,  0,  0, 0  }, -- Fire Protection
    [ 28511] = {   4,  2799,    0, 35,  0,  0, 0  }, -- Fire Protection
    [  7230] = {   4,   299,    0, 20,  0,  0, 0  }, -- Fire Protection (Rank 1)
    [ 12561] = {   4,   299,    0, 20,  0,  0, 0  }, -- Fire Protection (Rank 1)
    [  7231] = {   4,   524,    0, 25,  0,  0, 0  }, -- Fire Protection (Rank 2)
    [  7232] = {   4,   674,    0, 30,  0,  0, 0  }, -- Fire Protection (Rank 3)
    [  7233] = {   4,   974,    0, 35,  0,  0, 0  }, -- Fire Protection (Rank 4)
    [ 16894] = {   4,   974,    0, 35,  0,  0, 0  }, -- Fire Protection (Rank 4)
    [  7234] = {   4,  1349,    0, 35,  0,  0, 0  }, -- Fire Protection (Rank 5)
    [ 27533] = {   4,   299,    0, 60,  0,  0, 0  }, -- Fire Resistance
    [  4057] = {   4,   499,    0,  0,  0, 25, 0  }, -- Fire Resistance
    [ 30999] = {   8,   899,    0, 40,  0,  0, 0  }, -- Nature Absorption
    [ 17546] = {   8,  1949,    0, 40,  0,  0, 0  }, -- Nature Protection
    [ 28513] = {   8,  2799,    0, 40,  0,  0, 0  }, -- Nature Protection
    [  7250] = {   8,   299,    0, 20,  0,  0, 0  }, -- Nature Protection (Rank 1)
    [  7251] = {   8,   524,    0, 25,  0,  0, 0  }, -- Nature Protection (Rank 2)
    [  7252] = {   8,   674,    0, 30,  0,  0, 0  }, -- Nature Protection (Rank 3)
    [  7253] = {   8,   974,    0, 35,  0,  0, 0  }, -- Nature Protection (Rank 4)
    [  7254] = {   8,  1349,    0, 40,  0,  0, 0  }, -- Nature Protection (Rank 5)
    [ 16893] = {   8,  1349,    0, 40,  0,  0, 0  }, -- Nature Protection (Rank 5)
    [ 27538] = {   8,   299,    0, 60,  0,  0, 0  }, -- Nature Resistance
    [ 30994] = {  16,   899,    0, 40,  0,  0, 0  }, -- Frost Absorption
    [ 17544] = {  16,  1949,    0, 40,  0,  0, 0  }, -- Frost Protection
    [ 28512] = {  16,  2799,    0, 40,  0,  0, 0  }, -- Frost Protection
    [  7240] = {  16,   299,    0, 20,  0,  0, 0  }, -- Frost Protection (Rank 1)
    [  7236] = {  16,   524,    0, 25,  0,  0, 0  }, -- Frost Protection (Rank 2)
    [  7238] = {  16,   674,    0, 30,  0,  0, 0  }, -- Frost Protection (Rank 3)
    [  7237] = {  16,   974,    0, 35,  0,  0, 0  }, -- Frost Protection (Rank 4)
    [  7239] = {  16,  1349,    0, 40,  0,  0, 0  }, -- Frost Protection (Rank 5)
    [ 16895] = {  16,  1349,    0, 40,  0,  0, 0  }, -- Frost Protection (Rank 5)
    [ 27534] = {  16,   299,    0, 60,  0,  0, 0  }, -- Frost Resistance
    [  4077] = {  16,   599,    0,  0,  0, 25, 0  }, -- Frost Resistance
    [ 31000] = {  32,   899,    0, 40,  0,  0, 0  }, -- Shadow Absorption
    [ 33482] = {  32,  2294,    0, 60,  0, 60, 0  }, -- Shadow Defense
    [ 17548] = {  32,  1949,    0, 40,  0,  0, 0  }, -- Shadow Protection
    [ 28537] = {  32,  2799,    0, 40,  0,  0, 0  }, -- Shadow Protection
    [  7235] = {  32,   299,    0, 20,  0,  0, 0  }, -- Shadow Protection (Rank 1)
    [  7241] = {  32,   524,    0, 25,  0,  0, 0  }, -- Shadow Protection (Rank 2)
    [  7242] = {  32,   674,    0, 30,  0,  0, 0  }, -- Shadow Protection (Rank 3)
    [ 16891] = {  32,   674,    0, 30,  0,  0, 0  }, -- Shadow Protection (Rank 3)
    [  7243] = {  32,   974,    0, 35,  0,  0, 0  }, -- Shadow Protection (Rank 4)
    [  7244] = {  32,  1349,    0, 40,  0,  0, 0  }, -- Shadow Protection (Rank 5)
    [ 27535] = {  32,   299,    0, 60,  0,  0, 0  }, -- Shadow Resistance
    [  6229] = {  32,   289,    0, 32, 41, 32, 0  }, -- Shadow Ward (Rank 1)
    [ 11739] = {  32,   469,    0, 42, 51, 42, 0  }, -- Shadow Ward (Rank 2)
    [ 11740] = {  32,   674,    0, 52, 59, 52, 0  }, -- Shadow Ward (Rank 3)
    [ 28610] = {  32,   874,    0, 60, 69, 60, 0  }, -- Shadow Ward (Rank 4)
    [ 40322] = {  32, 11399,    0, 70,  0, 70, 0  }, -- Spirit Shield
    [ 31002] = {  64,   899,    0, 40,  0,  0, 0  }, -- Arcane Absorption
    [ 17549] = {  64,  1949,    0, 35,  0,  0, 0  }, -- Arcane Protection
    [ 28536] = {  64,  2799,    0, 35,  0,  0, 0  }, -- Arcane Protection
    [ 27540] = {  64,   299,    0, 60,  0,  0, 0  }, -- Arcane Resistance
    [ 31662] = { 126,199999,    0, 70,  0, 70, 0  }, -- Anti-Magic Shell
    [ 10618] = { 126,   599,    0, 30,  0,  0, 0  }, -- Elemental Protection
    [ 20620] = { 127, 29999,    0, 20,  0, 20, 0  }, -- Aegis of Ragnaros
    [ 36481] = { 127, 99999,    0,  0,  0,  0, 0  }, -- Arcane Barrier
    [ 39228] = { 127,  1149,    0,  0,  0,  1, 0  }, -- Argussian Compass
    [ 23506] = { 127,   749,    0, 20,  0,  0, 0  }, -- Aura of Protection
    [ 41341] = { 127,     0,    0,  0,  0,  0, 0  }, -- Balance of Power
    [ 11445] = { 127,   277,    0, 35,  0, 35, 0  }, -- Bone Armor
    [ 38882] = { 127,   878,    0, 60,  0, 60, 0  }, -- Bone Armor
    [ 16431] = { 127,  1387,    0, 55,  0, 55, 0  }, -- Bone Armor
    [ 27688] = { 127,  2499,    0,  0,  0,  0, 0  }, -- Bone Shield
    [ 33896] = { 127,   999,    0, 20,  0, 20, 0  }, -- Desperate Defense
    [ 28527] = { 127,   749,    0, 20,  0,  0, 0  }, -- Fel Blossom
    [ 33147] = { 127, 24999,    0,  0,  0,  0, 0  }, -- Greater Power Word: Shield
    [ 29701] = { 127,  3999,    0,  0,  0,  0, 0  }, -- Greater Shielding
    [ 29719] = { 127,  3999,    0,  0,  0,  0, 0  }, -- Greater Shielding
    [ 32278] = { 127,   399,    0,  0,  0,  0, 0  }, -- Greater Warding Shield
    [ 13234] = { 127,   499,    0,  0,  0,  0, 0  }, -- Harm Prevention Belt
    [  9800] = { 127,   174,    0, 52,  0,  0, 0  }, -- Holy Shield
    [ 33245] = { 127,   649,    0, 60,  0, 60, 0.1}, -- Ice Barrier
    [ 29674] = { 127,   999,    0,  0,  0,  0, 0  }, -- Lesser Shielding
    [ 29503] = { 127,   199,    0,  0,  0,  0, 0  }, -- Lesser Warding Shield
    [ 17252] = { 127,   499,    0,  0,  0,  0, 0  }, -- Mark of the Dragon Lord
    [ 30456] = { 127,  3999,    0,  0,  0,  0, 0  }, -- Nigh-Invulnerability
    [ 11835] = { 127,   115,    0, 20,  0, 20, 0.2}, -- Power Word: Shield
    [ 11974] = { 127,   136, 6.85, 20,  0, 20, 0.2}, -- Power Word: Shield
    [ 22187] = { 127,   205, 10.2, 20,  0, 20, 0.2}, -- Power Word: Shield
    [ 17139] = { 127,   273, 13.7, 20,  0, 20, 0.2}, -- Power Word: Shield
    [ 32595] = { 127,   410, 13.7, 20,  0, 20, 0.2}, -- Power Word: Shield
    [ 35944] = { 127,   547, 18.3, 20,  0, 20, 0.2}, -- Power Word: Shield
    [ 11647] = { 127,   780,  3.9, 54, 59,  1, 0.2}, -- Power Word: Shield
    [ 36052] = { 127,   821, 27.4, 20,  0, 20, 0.2}, -- Power Word: Shield
    [ 29408] = { 127,  2499,    0, 70,  0, 70, 0.2}, -- Power Word: Shield
    [ 20697] = { 127,  4999,    0,  0,  0,  0, 0.2}, -- Power Word: Shield
    [ 41373] = { 127,  4999,    0, 70,  0, 70, 0.2}, -- Power Word: Shield
    [ 41475] = { 127, 24999,    0, 70,  0, 70, 0  }, -- Reflective Shield
    [ 33810] = { 127,   136, 6.85, 20,  0, 20, 0  }, -- Rock Shell
    [ 41431] = { 127, 49999,    0,  0,  0,  0, 0  }, -- Rune Shield
    [ 31976] = { 127,   136, 6.85, 20,  0, 20, 0  }, -- Shadow Shield
    [ 12040] = { 127,   199,   10, 20,  0, 20, 0  }, -- Shadow Shield
    [ 22417] = { 127,   399,   20, 20,  0, 20, 0  }, -- Shadow Shield
    [ 31771] = { 127,   439,    0, 20,  0,  0, 0  }, -- Shell of Deterrence
    [ 27759] = { 127,    49,    0,  0,  0,  0, 0  }, -- Shield Generator
    [ 46165] = { 127,  9999,    0,  0,  0,  0, 0  }, -- Shock Barrier
    [ 36815] = { 127, 79999,    0,  0,  0,  0, 0  }, -- Shock Barrier
    [ 35618] = { 127,    19,    0,  0,  0,  1, 0  }, -- Spirit of Redemption
    [ 29506] = { 127,   899,    0, 20,  0,  0, 0  }, -- The Burrower's Shell
    [  1234] = { 127,     0,    0,  0,  0,  0, 0  }, -- Tony's God Mode
    [ 10368] = { 127,   199,  2.3, 30, 35, 30, 0  }, -- Uther's Light Effect (Rank 1)
    [ 37515] = { 127,   199,    0,  0,  0,  1, 0  }, -- [Warrior] Blade Turning
    [ 31228] = { 127,    32,    0,  0,  0,  1, 0  }, -- [Rogue] Cheat Death (Rank 1)
    [ 31229] = { 127,    65,    0,  0,  0,  1, 0  }, -- [Rogue] Cheat Death (Rank 2)
    [ 31230] = { 127,    99,    0,  0,  0,  1, 0  }, -- [Rogue] Cheat Death (Rank 3)
    [ 40251] = { 127,    99,    0, 70,  0, 70, 0  }, -- [Rogue] Shadow of Death
    [ 32504] = {  -2,  1318,  4.7, 65, 69, 65, 0  }, -- [Priest] Power Word: Warding (Rank 11)
    [ 28810] = { 127,   499,    0,  0,  0,  1, 0  }, -- [Priest] Armor of Faith
    [ 27779] = { 127,   349,    0,  0,  0,  0, 0  }, -- [Priest] Divine Protection
    [ 44175] = { 127,  1454,    0, 60,  0, 60, 0.2}, -- [Priest] Power Word: Shield
    [ 44291] = { 127,  1454,    0, 60,  0, 60, 0.2}, -- [Priest] Power Word: Shield
    [ 46193] = { 127,  2909,    0, 60,  0, 60, 0.2}, -- [Priest] Power Word: Shield
    [    17] = { 127,    43,  0.8,  6, 11,  6, 0.2}, -- [Priest] Power Word: Shield (Rank 1)
    [ 10901] = { 127,   941,  4.3, 60, 65, 60, 0.2}, -- [Priest] Power Word: Shield (Rank 10)
    [ 27607] = { 127,   941,  4.3, 60, 65, 60, 0.3}, -- [Priest] Power Word: Shield (Rank 10)
    [ 25217] = { 127,  1124,  4.7, 65, 69, 65, 0.3}, -- [Priest] Power Word: Shield (Rank 11)
    [ 25218] = { 127,  1264,  5.1, 70, 74, 70, 0.3}, -- [Priest] Power Word: Shield (Rank 12)
    [   592] = { 127,    87,  1.2, 12, 17, 12, 0.2}, -- [Priest] Power Word: Shield (Rank 2)
    [   600] = { 127,   157,  1.6, 18, 23, 18, 0.2}, -- [Priest] Power Word: Shield (Rank 3)
    [  3747] = { 127,   233,    2, 24, 29, 24, 0.2}, -- [Priest] Power Word: Shield (Rank 4)
    [  6065] = { 127,   300,  2.3, 30, 35, 30, 0.2}, -- [Priest] Power Word: Shield (Rank 5)
    [  6066] = { 127,   380,  2.6, 36, 41, 36, 0.2}, -- [Priest] Power Word: Shield (Rank 6)
    [ 10898] = { 127,   483,    3, 42, 47, 42, 0.2}, -- [Priest] Power Word: Shield (Rank 7)
    [ 10899] = { 127,   604,  3.4, 48, 53, 48, 0.2}, -- [Priest] Power Word: Shield (Rank 8)
    [ 10900] = { 127,   762,  3.9, 54, 59, 54, 0.2}, -- [Priest] Power Word: Shield (Rank 9)
    [ 20706] = { 127,   499,    3, 42, 47, 42, 0  }, -- [Priest] Power Word: Shield 500 (Rank 7)
    [ 17740] = {   1,   119,    6, 20,  0, 20, 0  }, -- [Mage] Mana Shield
    [ 30973] = {   1,   119,    6, 20,  0, 20, 0  }, -- [Mage] Mana Shield
    [ 17741] = {   1,   239,   12, 20,  0, 20, 0  }, -- [Mage] Mana Shield
    [ 46151] = {   1,   719,   36, 20,  0, 20, 0  }, -- [Mage] Mana Shield
    [ 15041] = {   4,   119,    0, 20,  0, 20, 0  }, -- [Mage] Fire Ward
    [ 37844] = {   4,   159,    8, 20,  0, 20, 0  }, -- [Mage] Fire Ward
    [   543] = {   4,   164,    0, 20, 29, 20, 0  }, -- [Mage] Fire Ward (Rank 1)
    [  8457] = {   4,   289,    0, 30, 39, 30, 0  }, -- [Mage] Fire Ward (Rank 2)
    [  8458] = {   4,   469,    0, 40, 49, 40, 0  }, -- [Mage] Fire Ward (Rank 3)
    [ 10223] = {   4,   674,    0, 50, 59, 50, 0  }, -- [Mage] Fire Ward (Rank 4)
    [ 10225] = {   4,   874,    0, 60, 68, 60, 0  }, -- [Mage] Fire Ward (Rank 5)
    [ 27128] = {   4,  1124,    0, 69, 78, 69, 0  }, -- [Mage] Fire Ward (Rank 6)
    [ 25641] = {   4,   499,   10, 60,  0, 60, 0  }, -- [Mage] Frost Ward
    [ 15044] = {  16,   119,    0, 20,  0, 20, 0  }, -- [Mage] Frost Ward
    [  6143] = {  16,   164,    0, 22, 31, 22, 0  }, -- [Mage] Frost Ward (Rank 1)
    [  8461] = {  16,   289,    0, 32, 41, 32, 0  }, -- [Mage] Frost Ward (Rank 2)
    [  8462] = {  16,   469,    0, 42, 51, 42, 0  }, -- [Mage] Frost Ward (Rank 3)
    [ 10177] = {  16,   674,    0, 52, 59, 52, 0  }, -- [Mage] Frost Ward (Rank 4)
    [ 28609] = {  16,   874,    0, 60, 69, 60, 0  }, -- [Mage] Frost Ward (Rank 5)
    [ 32796] = {  16,  1124,    0, 70, 78, 70, 0  }, -- [Mage] Frost Ward (Rank 6)
    [ 11426] = { 127,   437,  2.8, 40, 46, 40, 0.1}, -- [Mage] Ice Barrier (Rank 1)
    [ 13031] = { 127,   548,  3.2, 46, 52, 46, 0.1}, -- [Mage] Ice Barrier (Rank 2)
    [ 13032] = { 127,   677,  3.6, 52, 58, 52, 0.1}, -- [Mage] Ice Barrier (Rank 3)
    [ 13033] = { 127,   817,    4, 58, 64, 58, 0.1}, -- [Mage] Ice Barrier (Rank 4)
    [ 27134] = { 127,   924,  4.4, 64, 70, 64, 0.1}, -- [Mage] Ice Barrier (Rank 5)
    [ 33405] = { 127,  1074,  4.8, 70, 76, 70, 0.1}, -- [Mage] Ice Barrier (Rank 6)
    [ 35064] = { 127,  7999,    0, 20,  0, 20, 0  }, -- [Mage] Mana Shield
    [ 38151] = { 127,  9999,    0, 20,  0, 20, 0  }, -- [Mage] Mana Shield
    [ 29880] = { 127, 60000,    6, 20,  0, 20, 0  }, -- [Mage] Mana Shield
    [  1463] = { 127,   119,    0, 20, 27, 20, 0  }, -- [Mage] Mana Shield (Rank 1)
    [  8494] = { 127,   209,    0, 28, 35, 28, 0  }, -- [Mage] Mana Shield (Rank 2)
    [  8495] = { 127,   299,    0, 36, 43, 36, 0  }, -- [Mage] Mana Shield (Rank 3)
    [ 10191] = { 127,   389,    0, 44, 51, 44, 0  }, -- [Mage] Mana Shield (Rank 4)
    [ 10192] = { 127,   479,    0, 52, 59, 52, 0  }, -- [Mage] Mana Shield (Rank 5)
    [ 10193] = { 127,   569,    0, 60, 67, 60, 0  }, -- [Mage] Mana Shield (Rank 6)
    [ 27131] = { 127,   714,    0, 68, 75, 68, 0  }, -- [Mage] Mana Shield (Rank 7)
    [ 26470] = { 127,     0,    0,  0,  0,  1, 0  }, -- [Mage] Persistent Shield
    [  7812] = { 127,   304,  2.3, 16, 22, 16, 0  }, -- [Warlock] Sacrifice (Rank 1)
    [ 19438] = { 127,   509,  3.1, 24, 30, 24, 0  }, -- [Warlock] Sacrifice (Rank 2)
    [ 19440] = { 127,   769,  3.9, 32, 38, 32, 0  }, -- [Warlock] Sacrifice (Rank 3)
    [ 19441] = { 127,  1094,  4.7, 40, 46, 40, 0  }, -- [Warlock] Sacrifice (Rank 4)
    [ 19442] = { 127,  1469,  5.5, 48, 54, 48, 0  }, -- [Warlock] Sacrifice (Rank 5)
    [ 19443] = { 127,  1904,  6.4, 56, 62, 56, 0  }, -- [Warlock] Sacrifice (Rank 6)
    [ 27273] = { 127,  2854,  7.5, 64, 70, 64, 0  }, -- [Warlock] Sacrifice (Rank 7)
}
CataAbsorb.activeAbsorbs = {}
CataAbsorb.unitFrames = {}
CataAbsorb.compactUnitFrames = {}


local function GetImprovedPowerWordShieldMultiplier()
    return 1.15
end

CataAbsorb.talentMultiplier = {
    [   17] = GetImprovedPowerWordShieldMultiplier,
    [  592] = GetImprovedPowerWordShieldMultiplier,
    [  600] = GetImprovedPowerWordShieldMultiplier,
    [ 3747] = GetImprovedPowerWordShieldMultiplier,
    [ 6065] = GetImprovedPowerWordShieldMultiplier,
    [ 6066] = GetImprovedPowerWordShieldMultiplier,
    [10898] = GetImprovedPowerWordShieldMultiplier,
    [10899] = GetImprovedPowerWordShieldMultiplier,
    [10900] = GetImprovedPowerWordShieldMultiplier,
    [10901] = GetImprovedPowerWordShieldMultiplier,
}

CataAbsorb.absorbDbKeys = {
    ["school"] = 1,
    ["basePoints"] = 2,
    ["pointsPerLevel"] = 3,
    ["baseLevel"] = 4,
    ["maxLevel"] = 5,
    ["spellLevel"] = 6,
    ["healingMultiplier"] = 7,
}
local relevantUnits = {}

local function UpdateRelevantUnits()
    relevantUnits = {}

    local function AddUnit(unit)
        local name = UnitName(unit)
        if name then
            relevantUnits[name] = relevantUnits[name] or {}
            table.insert(relevantUnits[name], unit)
        end
    end

    -- Add main units
    AddUnit("player")
    AddUnit("target")

    -- Add party units (party1-4)
    for i = 1, 4 do
        if not UnitExists("party" .. i) then break end
        AddUnit("party" .. i)
    end

    -- Add raid units (raid1-40)
    for i = 1, 40 do
        if not UnitExists("raid" .. i) then break end
        AddUnit("raid" .. i)
    end
end



local function ComputeAbsorb(unit)
    local totalAbsorb = 0
    local maxAbsorbIcon = nil
    local bonusHealing = GetSpellBonusHealing()
    local level = UnitLevel("player")

    if not CataAbsorb.activeAbsorbs[unit] then
        CataAbsorb.activeAbsorbs[unit] = {}
    end

    for index = 1, 40 do
        local name, icon, _, _, _, _, _, _, _, spellId = UnitBuff(unit, index)
        if not name then break end

        local absorbInfo = CataAbsorb.spells[spellId]
        if absorbInfo then
            local base = absorbInfo[CataAbsorb.absorbDbKeys.basePoints]
            local perLevel = absorbInfo[CataAbsorb.absorbDbKeys.pointsPerLevel]
            local baseLevel = absorbInfo[CataAbsorb.absorbDbKeys.baseLevel]
            local maxLevel = absorbInfo[CataAbsorb.absorbDbKeys.maxLevel]
            local spellLevel = absorbInfo[CataAbsorb.absorbDbKeys.spellLevel]
            local bonusMult = absorbInfo[CataAbsorb.absorbDbKeys.healingMultiplier]
            local baseMultFn = CataAbsorb.talentMultiplier[spellId]
            local levelPenalty = math.min(1, 1 - (20 - spellLevel) * 0.0375)
            local levels = math.max(0, math.min(level, maxLevel) - baseLevel)
            local baseMult = baseMultFn and baseMultFn() or 1

            local fullAbsorb = (baseMult * (base + levels * perLevel) + bonusHealing * bonusMult * levelPenalty)
            local storedAbsorb = CataAbsorb.activeAbsorbs[unit][spellId] or fullAbsorb
            local currentAbsorb = math.min(storedAbsorb, fullAbsorb)

            CataAbsorb.activeAbsorbs[unit][spellId] = currentAbsorb

            totalAbsorb = totalAbsorb + currentAbsorb
            maxAbsorbIcon = icon
        end
    end

    return totalAbsorb, maxAbsorbIcon
end




local function RaiseStrataOnHpText(frame)
    local leftText = _G[frame.."HealthBarTextLeft"] or _G[frame].textureFrame.HealthBarTextLeft
    local rightText = _G[frame.."HealthBarTextRight"] or _G[frame].textureFrame.HealthBarTextRight
    local centerText = _G[frame.."HealthBarText"] or _G[frame].textureFrame.HealthBarText

    if leftText then
        leftText:SetDrawLayer("OVERLAY")
    end
    if rightText then
        rightText:SetDrawLayer("OVERLAY")
    end
    if centerText then
        centerText:SetDrawLayer("OVERLAY")
    end
end

local function UpdateAbsorbIndicator(frame, unit)
    if not BetterBlizzFramesDB.absorbIndicator and not BetterBlizzFramesDB.absorbIndicatorTestMode then return end

    local settingsPrefix = unit
    local showAmount = BetterBlizzFramesDB[settingsPrefix .. "AbsorbAmount"]
    local showIcon = BetterBlizzFramesDB[settingsPrefix .. "AbsorbIcon"]
    local xPos = BetterBlizzFramesDB.playerAbsorbXPos
    local yPos = BetterBlizzFramesDB.playerAbsorbYPos
    local anchor = BetterBlizzFramesDB.playerAbsorbAnchor
    local reverseAnchor = BBF.GetOppositeAnchor(anchor)
    local darkModeOn = BetterBlizzFramesDB.darkModeUi
    local vertexColor = darkModeOn and BetterBlizzFramesDB.darkModeColor or 1
    local testMode = BetterBlizzFramesDB.absorbIndicatorTestMode
    local flipIconText = BetterBlizzFramesDB.absorbIndicatorFlipIconText

    if not frame.absorbParent then
        frame.absorbParent = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        frame.absorbParent:SetSize(50, 50)
        frame.absorbParent:SetPoint("CENTER", frame, "CENTER", xPos, yPos)
        frame.absorbParent:SetFrameStrata("HIGH")

        frame.absorbIcon = frame.absorbParent:CreateTexture(nil, "OVERLAY")
        frame.absorbIcon:SetSize(20, 20)
        frame.absorbIcon:SetPoint("CENTER", frame.absorbParent, "CENTER")

        frame.absorbIndicator = frame.absorbParent:CreateFontString(nil, "OVERLAY")
        frame.absorbIndicator:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
        frame.absorbIndicator:SetPoint("CENTER", frame.absorbParent, "CENTER")
        frame.absorbIndicator:SetDrawLayer("OVERLAY", 7)
    end

    if not frame.absorbIcon.border then
        local border = CreateFrame("Frame", nil, frame.absorbParent, "BackdropTemplate")
        border:SetBackdrop({
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tileEdge = true,
            edgeSize = 8,
        })

        border:SetPoint("TOPLEFT", frame.absorbIcon, "TOPLEFT", -2, 2)
        border:SetPoint("BOTTOMRIGHT", frame.absorbIcon, "BOTTOMRIGHT", 2, -2)
        border:SetFrameLevel(frame.absorbParent:GetFrameLevel() + 1)  -- Ensure the border is above the icon
        frame.absorbIcon.border = border
    end

    if darkModeOn then
        frame.absorbIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        frame.absorbIcon.border:SetBackdropBorderColor(vertexColor, vertexColor, vertexColor)
        frame.absorbIcon.border:SetAlpha(0)
    else
        frame.absorbIcon:SetTexCoord(0, 1, 0, 1)
        frame.absorbIcon.border:SetAlpha(0)
    end

    frame.absorbIcon:ClearAllPoints()
    frame.absorbIndicator:ClearAllPoints()

    if frame == PlayerFrame then
        xPos = xPos * -1 -- invert the xPos value for PlayerFrame
    end

    if testMode then
        frame.absorbIcon:SetTexture("Interface\\Icons\\SPELL_HOLY_POWERWORDSHIELD")
        frame.absorbIcon:SetAlpha(1)
        frame.absorbIndicator:SetText("69k")
        frame.absorbIndicator:SetAlpha(1)
        if frame == PlayerFrame then
            if anchor == "LEFT" or anchor == "RIGHT" then
                frame.absorbIcon:SetPoint(anchor, frame, reverseAnchor, -45 + xPos, 2.5 + yPos)
            else
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, -5 + xPos, -21.5 + yPos)
            end
            if showIcon then
                if darkModeOn then
                    frame.absorbIcon.border:SetAlpha(1)
                else
                    frame.absorbIcon.border:SetAlpha(0)
                end
                if flipIconText then
                    frame.absorbIndicator:SetPoint("RIGHT", frame.absorbIcon, "LEFT", 0, 0)
                else
                    frame.absorbIndicator:SetPoint("LEFT", frame.absorbIcon, "RIGHT", 3, 0)
                end
            else
                frame.absorbIndicator:SetPoint("LEFT", frame.absorbIcon, "RIGHT", -23, 0)
            end
        else
            if anchor == "LEFT" or anchor =="RIGHT" then
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, -5 + xPos, 3 + yPos)
            else
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, 5 + xPos, -21 + yPos)
            end
            if showIcon then
                if darkModeOn then
                    frame.absorbIcon.border:SetAlpha(1)
                else
                    frame.absorbIcon.border:SetAlpha(0)
                end
                if flipIconText then
                    frame.absorbIndicator:SetPoint("LEFT", frame.absorbIcon, "RIGHT", 3, 0)
                else
                    frame.absorbIndicator:SetPoint("RIGHT", frame.absorbIcon, "LEFT", 0, 0)
                end
            else
                frame.absorbIndicator:SetPoint("RIGHT", frame.absorbIcon, "LEFT", 20, 0)
            end
        end
        return
    end

    if showAmount then
        if frame == PlayerFrame then
            if anchor == "LEFT" or anchor == "RIGHT" then
                frame.absorbIcon:SetPoint(anchor, frame, reverseAnchor, -45 + xPos, 2.5 + yPos)
            else
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, -5 + xPos, -21.5 + yPos)
            end
            if showIcon then
                if darkModeOn then
                    frame.absorbIcon.border:SetAlpha(1)
                else
                    frame.absorbIcon.border:SetAlpha(0)
                end
                if flipIconText then
                    frame.absorbIndicator:SetPoint("RIGHT", frame.absorbIcon, "LEFT", 0, 0)
                else
                    frame.absorbIndicator:SetPoint("LEFT", frame.absorbIcon, "RIGHT", 3, 0)
                end
            else
                frame.absorbIndicator:SetPoint("LEFT", frame.absorbIcon, "RIGHT", -23, 0)
            end
        else
            if anchor == "LEFT" or anchor =="RIGHT" then
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, -5 + xPos, 3 + yPos)
            else
                frame.absorbIcon:SetPoint(reverseAnchor, frame, anchor, 5 + xPos, -21 + yPos)
            end
            if showIcon then
                if darkModeOn then
                    frame.absorbIcon.border:SetAlpha(1)
                else
                    frame.absorbIcon.border:SetAlpha(0)
                end
                if flipIconText then
                    frame.absorbIndicator:SetPoint("LEFT", frame.absorbIcon, "RIGHT", 3, 0)
                else
                    frame.absorbIndicator:SetPoint("RIGHT", frame.absorbIcon, "LEFT", 0, 0)
                end
            else
                frame.absorbIndicator:SetPoint("RIGHT", frame.absorbIcon, "LEFT", 20, 0)
            end
        end

        frame.absorbIndicator:SetScale(BetterBlizzFramesDB.absorbIndicatorScale)
        frame.absorbIcon:SetScale(BetterBlizzFramesDB.absorbIndicatorScale)

        local totalAbsorb, auraIcon = ComputeAbsorb(unit)

        if totalAbsorb >= 1 then
            --local displayValue = math.floor(totalAbsorb / 1000) .. "k"
            local displayValue = string.format("%d", totalAbsorb)
            frame.absorbIndicator:SetText(displayValue)
            frame.absorbIndicator:SetAlpha(1)

            if showIcon then
                if auraIcon then
                    frame.absorbIcon:SetTexture(auraIcon)
                    frame.absorbIcon:SetAlpha(1)
                    if frame.absorbIcon.border and darkModeOn then
                        frame.absorbIcon.border:SetAlpha(1)
                    end
                else
                    frame.absorbIcon:SetAlpha(0)
                    if frame.absorbIcon.border then
                        frame.absorbIcon.border:SetAlpha(0)
                    end
                end
            else
                frame.absorbIcon:SetAlpha(0)
                if frame.absorbIcon.border then
                    frame.absorbIcon.border:SetAlpha(0)
                end
            end
        else
            frame.absorbIndicator:SetAlpha(0)
            frame.absorbIcon:SetAlpha(0)
            if frame.absorbIcon.border then
                frame.absorbIcon.border:SetAlpha(0)
            end
        end
    else
        if frame.absorbIndicator then frame.absorbIndicator:SetAlpha(0) end
        if frame.absorbIcon then frame.absorbIcon:SetAlpha(0) end
        if frame.absorbIcon.border then
            frame.absorbIcon.border:SetAlpha(0)
        end
    end
end


local absorbHooked = false
function BBF.AbsorbCaller()
    UpdateAbsorbIndicator(PlayerFrame, "player")
    UpdateAbsorbIndicator(TargetFrame, "target")
    if not BetterBlizzFramesDB.absorbIndicator and not BetterBlizzFramesDB.absorbIndicatorTestMode then
        if TargetFrame.absorbIcon and TargetFrame.absorbIcon.border then TargetFrame.absorbIcon.border:SetAlpha(0) end
        if TargetFrame.absorbIndicator then TargetFrame.absorbIndicator:SetAlpha(0) end
        if TargetFrame.absorbIcon then TargetFrame.absorbIcon:SetAlpha(0) end
        if PlayerFrame.absorbIndicator then PlayerFrame.absorbIndicator:SetAlpha(0) end
        if PlayerFrame.absorbIcon then PlayerFrame.absorbIcon:SetAlpha(0) end
        if PlayerFrame.absorbIcon and PlayerFrame.absorbIcon.border then PlayerFrame.absorbIcon.border:SetAlpha(0) end
    end
    if not absorbHooked then
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:RegisterEvent("GROUP_ROSTER_UPDATE")
        frame:RegisterEvent("UNIT_HEALTH")
        frame:RegisterEvent("UNIT_MAXHEALTH")
        frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        frame:RegisterEvent("PLAYER_TARGET_CHANGED")
        frame:SetScript("OnEvent", function(self, event, ...)
            if event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" then
                BBF.AbsorbCaller()
            elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
                local unit = ...
                if unit == "player" then
                    UpdateAbsorbIndicator(PlayerFrame, unit)
                elseif unit == "target" then
                    UpdateAbsorbIndicator(TargetFrame, unit)
                end
            elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
                local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName = CombatLogGetCurrentEventInfo()
                if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" or subEvent == "SPELL_AURA_REMOVED" then
                    if destName then
                        destName = Ambiguate(destName, "short")
                    end
                    local spellId = select(12, CombatLogGetCurrentEventInfo())
                    if not CataAbsorb.spells[spellId] then return end
                    if subEvent == "SPELL_AURA_REMOVED" then
                        local unit = relevantUnits[destName]
                        if unit and CataAbsorb.activeAbsorbs[unit] and CataAbsorb.activeAbsorbs[unit][spellId] then
                            CataAbsorb.activeAbsorbs[unit][spellId] = nil
                        end
                    end
                    UpdateAbsorbIndicator(PlayerFrame, "player")
                    UpdateAbsorbIndicator(TargetFrame, "target")
                end
            elseif event == "PLAYER_TARGET_CHANGED" then
                UpdateAbsorbIndicator(TargetFrame, "target")
            end
        end)

        RaiseStrataOnHpText("PlayerFrame")
        RaiseStrataOnHpText("TargetFrame")

        absorbHooked = true
    end
end


local function CreateAbsorbBar(frame)
    if frame.absorbBar then return end

    frame.absorbBar = frame:CreateTexture(nil, "ARTWORK", nil, 1)
    frame.absorbBar:SetTexture("Interface\\RaidFrame\\Shield-Fill")
    frame.absorbBar:Hide()

    frame.absorbOverlay = frame:CreateTexture(nil, "OVERLAY", nil, 2)
    frame.absorbOverlay:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
    frame.absorbOverlay:SetHorizTile(true)
    frame.absorbOverlay.tileSize = 32
    frame.absorbOverlay:SetAllPoints(frame.absorbBar)
    frame.absorbOverlay:Hide()

    frame.absorbGlow = frame:CreateTexture(nil, "OVERLAY", nil, 3)
    frame.absorbGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
    frame.absorbGlow:SetBlendMode("ADD")
    frame.absorbGlow:SetWidth(13)
    frame.absorbGlow:SetAlpha(0.6)
    frame.absorbGlow:Hide()
    frame.absorbGlow:SetParent(frame.healthbar or frame.healthBar or frame.HealthBar)

    if not TargetFrameToT.adjustedLevel then
        PlayerFrameTexture:GetParent():SetFrameLevel(56)
        TargetFrameTextureFrame:SetFrameLevel(55)
        if not InCombatLockdown() then
            TargetFrameToT:SetFrameLevel(56)
        end
        TargetFrameToT.adjustedLevel = true
    end
end

local function HookAllFrames()
    local function StoreCompactUnitFrame(frame, unit)
        if not frame or not unit then return end
        if unit:find("nameplate") then return end
        CataAbsorb.compactUnitFrames[unit] = frame
    end

    local function StoreUnitFrame(frame, unit)
        if not frame or not unit then return end
        CataAbsorb.unitFrames[unit] = frame
    end

    hooksecurefunc("CompactUnitFrame_SetUnit", function(frame, unit)
        local cufAbsorbEnabled = BetterBlizzFramesDB.overShieldsCompactUnitFrames
        if cufAbsorbEnabled then
            StoreCompactUnitFrame(frame, unit)
        end
    end)

    hooksecurefunc("UnitFrame_Update", function(frame, unit)
        local ufAbsorbEnabled = BetterBlizzFramesDB.overShieldsUnitFrames
        if ufAbsorbEnabled then
            StoreUnitFrame(frame, frame.unit)
        end
    end)
end

HookAllFrames()


local function UpdateAbsorbOnFrame(unit, frame, absorbValue)
    if not frame or not frame.unit or not UnitIsUnit(unit, frame.unit) then return end
    local healthBar = frame.healthBar or frame.HealthBar or frame.healthbar
    if not healthBar then return end

    local state = CataAbsorb.allstates[unit]
    CreateAbsorbBar(frame)

    if not (state and state.show) then
        frame.absorbGlow:Hide()
        frame.absorbOverlay:Hide()
        frame.absorbBar:Hide()
        return
    end

    local currentHealth, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
    if maxHealth <= 0 then return end
    local totalAbsorb = absorbValue or 0
    local missingHealth = maxHealth - currentHealth
    local totalWidth = healthBar:GetWidth()

    local absorbWidth = math.min(totalAbsorb, missingHealth) / maxHealth * totalWidth
    local offset = currentHealth / maxHealth * totalWidth

    if absorbWidth > 0 then
        frame.absorbBar:ClearAllPoints()
        frame.absorbBar:SetParent(healthBar)
        frame.absorbBar:SetPoint("TOPLEFT", healthBar, "TOPLEFT", offset, 0)
        frame.absorbBar:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", offset, 0)
        frame.absorbBar:SetWidth(absorbWidth)
        frame.absorbBar:Show()
    else
        frame.absorbBar:Hide()
    end

    frame.absorbOverlay:ClearAllPoints()
    frame.absorbOverlay:SetParent(healthBar)

    local overlayOffset = offset
    local overlayWidth = totalAbsorb / maxHealth * totalWidth

    if (currentHealth + totalAbsorb) > maxHealth then
        local overAbsorb = (currentHealth + totalAbsorb) - maxHealth
        local overAbsorbWidth = overAbsorb / maxHealth * totalWidth

        overlayWidth = overlayWidth + overAbsorbWidth
        overlayOffset = offset - overAbsorbWidth
    end

    frame.absorbOverlay:SetPoint("TOPLEFT", healthBar, "TOPLEFT", math.max(overlayOffset, 0), 0)
    frame.absorbOverlay:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", math.max(overlayOffset, 0), 0)
    frame.absorbOverlay:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", 0, 0)
    frame.absorbOverlay:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0)
    frame.absorbOverlay:SetWidth(math.min(overlayWidth, totalWidth))
    frame.absorbOverlay:SetTexCoord(0, frame.absorbOverlay:GetWidth() / frame.absorbOverlay.tileSize, 0, 1)
    frame.absorbOverlay:Show()

    frame.absorbGlow:ClearAllPoints()
    if (currentHealth + totalAbsorb) > maxHealth then
        frame.absorbGlow:SetPoint("TOPLEFT", frame.absorbOverlay, "TOPLEFT", -4, 1)
        frame.absorbGlow:SetPoint("BOTTOMLEFT", frame.absorbOverlay, "BOTTOMLEFT", -4, -1)
    else
        frame.absorbGlow:SetPoint("TOPRIGHT", frame.absorbOverlay, "TOPRIGHT", 7, 1)
        frame.absorbGlow:SetPoint("BOTTOMRIGHT", frame.absorbOverlay, "BOTTOMRIGHT", 7, 1)
        frame.absorbOverlay:SetPoint("TOPRIGHT", frame.absorbBar, "TOPRIGHT", 0, 0)
        frame.absorbOverlay:SetPoint("BOTTOMRIGHT", frame.absorbBar, "BOTTOMRIGHT", 0, 0)
    end
    frame.absorbBar:SetTexCoord(0, 1, 0, 1)
    frame.absorbGlow:Show()
end



CataAbsorb.playerName = UnitName("player")

local validUnits = {
    ["player"] = true,
    ["target"] = true,
}

-- Add party units (party1 to party5)
for i = 1, 5 do
    validUnits["party" .. i] = true
end

-- Add raid units (raid1 to raid40)
for i = 1, 40 do
    validUnits["raid" .. i] = true
end

function BBF.UpdateValidUnits()
    local ufEnabled = BetterBlizzFramesDB.overShieldsUnitFrames
    local cufEnabled = BetterBlizzFramesDB.overShieldsCompactUnitFrames

    if ufEnabled then
        CataAbsorb.unitFrames["player"] = PlayerFrame
        CataAbsorb.unitFrames["target"] = TargetFrame
    else
        CataAbsorb.unitFrames["player"] = nil
        CataAbsorb.unitFrames["target"] = nil
    end

    for i = 1, 40 do
        local unitID = "raid" .. i
        validUnits[unitID] = cufEnabled and true or nil
    end
end


local function UnitValid(unit)
    return unit and UnitExists(unit)-- and (unit == "player" or unit == "target" or unit == "focus" or UnitInParty(unit) or UnitInRaid(unit))
end

local function SetupState(allstates, unit, absorb)
    if absorb > 0 then
        local maxHealth = UnitHealthMax(unit)
        local health = UnitHealth(unit)
        local healthPercent = health / maxHealth
        local healthDeficitPercent = 1.0 - healthPercent
        local absorbPercent = absorb / maxHealth

        if healthPercent < 1.0 and absorbPercent > healthDeficitPercent then
            if absorbPercent < 2 * healthDeficitPercent then
                absorbPercent = healthDeficitPercent
            else
                absorbPercent = absorbPercent - healthDeficitPercent
            end
        end

        allstates[unit] = {
            unit = unit,
            name = unit,
            value = absorbPercent * 100,
            total = 100,
            show = true,
            changed = true,
            healthPercent = healthPercent,
        }
    else
        allstates[unit] = {
            show = false,
            changed = true,
        }
    end
end

local function ResetAll(allstates)
    for _, state in pairs(allstates) do
        state.show = false
        state.changed = true
    end
end

local function RosterUpdated(allstates)
    for unit, state in pairs(allstates) do
        if not UnitValid(unit) then
            state.show = false
            state.changed = true
        end
    end
end

local function RefreshUnit(allstates, unit, absorbValue)
    if not UnitValid(unit) then return end

    local absorb = absorbValue or ComputeAbsorb(unit)
    SetupState(allstates, unit, absorb)

    local unitFrames = CataAbsorb.unitFrames
    local compactUnitFrames = CataAbsorb.compactUnitFrames
    local framesToUpdate = {}

    if unitFrames[unit] then
        table.insert(framesToUpdate, unitFrames[unit])
    end

    if compactUnitFrames[unit] then
        table.insert(framesToUpdate, compactUnitFrames[unit])
    end

    for _, frame in ipairs(framesToUpdate) do
        if frame then
            UpdateAbsorbOnFrame(unit, frame, absorb)
        end
    end
end

local auraEvents = {
    ["SPELL_AURA_APPLIED"] = true,
    ["SPELL_AURA_REFRESH"] = true,
    ["SPELL_AURA_REMOVED"] = true,
    ["SPELL_ABSORBED"] = true,
}

local function OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        ResetAll(CataAbsorb.allstates)
        UpdateRelevantUnits()
        RefreshUnit(CataAbsorb.allstates, "player")
    elseif event == "GROUP_ROSTER_UPDATE" then
        UpdateRelevantUnits()
        RosterUpdated(CataAbsorb.allstates)
    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        local unit = select(1, ...)
        if validUnits[unit] then
            RefreshUnit(CataAbsorb.allstates, unit)
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, _, _, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()
        if not auraEvents[subEvent] then return end
        if destName then
            destName = Ambiguate(destName, "short")
        end
        local units = relevantUnits[destName]
        if units then
            local computedAbsorbs = {}
            for _, unit in ipairs(units) do
                if not computedAbsorbs[unit] then
                    computedAbsorbs[unit] = ComputeAbsorb(unit)
                    if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" then
                        local spellId = select(12, CombatLogGetCurrentEventInfo())
                        if CataAbsorb.spells[spellId] then
                            CataAbsorb.activeAbsorbs[unit][spellId] = nil
                            computedAbsorbs[unit] = ComputeAbsorb(unit)
                            CataAbsorb.activeAbsorbs[unit][spellId] = computedAbsorbs[unit]
                            RefreshUnit(CataAbsorb.allstates, unit, computedAbsorbs[unit])
                        end
                    elseif subEvent == "SPELL_AURA_REMOVED" then
                        local spellId = select(12, CombatLogGetCurrentEventInfo())
                        if CataAbsorb.activeAbsorbs[unit] then
                            CataAbsorb.activeAbsorbs[unit][spellId] = nil
                            RefreshUnit(CataAbsorb.allstates, unit, computedAbsorbs[unit])
                        end

                    elseif subEvent == "SPELL_ABSORBED" then
                        local absorbedAmount = select(19, CombatLogGetCurrentEventInfo()) or 0
                        local spellId = select(16, CombatLogGetCurrentEventInfo())

                        if CataAbsorb.activeAbsorbs[unit] and CataAbsorb.activeAbsorbs[unit][spellId] then
                            CataAbsorb.activeAbsorbs[unit][spellId] = math.max(0, CataAbsorb.activeAbsorbs[unit][spellId] - absorbedAmount)

                            if CataAbsorb.activeAbsorbs[unit][spellId] == 0 then
                                CataAbsorb.activeAbsorbs[unit][spellId] = nil
                            end

                            RefreshUnit(CataAbsorb.allstates, unit, computedAbsorbs[unit])
                        end
                    end
                end
            end
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        UpdateRelevantUnits()
        RefreshUnit(CataAbsorb.allstates, "target")
    end
end


local overshieldSetup = false
function BBF.HookOverShields()
    if BetterBlizzFramesDB.overShields and not overshieldSetup then
        if BetterBlizzFramesDB.overShieldsCompact then
            local frame = CreateFrame("Frame")
            frame:RegisterEvent("PLAYER_ENTERING_WORLD")
            frame:RegisterEvent("GROUP_ROSTER_UPDATE")
            frame:RegisterEvent("PLAYER_TARGET_CHANGED")
            frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
            frame:RegisterEvent("UNIT_HEALTH")
            frame:RegisterEvent("UNIT_MAXHEALTH")
            frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            frame:SetScript("OnEvent", OnEvent)
        end

        overshieldSetup = true

        BBF.UpdateValidUnits()
    end
end

CataAbsorb.allstates = {}