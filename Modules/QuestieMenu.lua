---@class QuestieMenu
local QuestieMenu = QuestieLoader:CreateModule("QuestieMenu")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type MeetingStones
local MeetingStones = QuestieLoader:ImportModule("MeetingStones")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")

local LibDropDown = LibStub:GetLibrary("LibUIDropDownMenuQuestie-4.0")

local _, playerClass = UnitClass("player")
local playerFaction = UnitFactionGroup("player")

local _townsfolk_texturemap = {
    ["Flight Master"] = "Interface\\Minimap\\tracking\\flightmaster",
    ["Meeting Stones"] = QuestieLib.AddonPath.."Icons\\mstone.blp",
    ["Class Trainer"] = "Interface\\Minimap\\tracking\\class",
    ["Stable Master"] = "Interface\\Minimap\\tracking\\stablemaster",
    ["Spirit Healer"] = "Interface\\raidframe\\raid-icon-rez",
    ["Weapon Master"] = QuestieLib.AddonPath.."Icons\\slay.blp",
    ["Profession Trainer"] = "Interface\\Minimap\\tracking\\profession",
    ["Ammo"] = 132382,--select(10, GetItemInfo(2515)) -- sharp arrow
    ["Bags"] = 133634,--select(10, GetItemInfo(4496)) -- small brown pouch
    ["Trade Goods"] = 132912,--select(10, GetItemInfo(2321)) -- thread
    ["Drink"] = 134712,--select(10, GetItemInfo(8766)) -- morning glory dew
    ["Food"] = 133964,--select(10, GetItemInfo(4540)) -- bread
    ["Pet Food"] = 132165,--select(3, GetSpellInfo(6991)) -- feed pet
    ["Portal Trainer"] = "Interface\\Minimap\\vehicle-alliancemageportal",
    ["Reagents"] = (function()
        if playerClass == "ROGUE" then
            return "Interface\\Minimap\\tracking\\poisons"
        end
        return "Interface\\Minimap\\tracking\\reagents"
    end)(),
    [QuestieProfessions.professionKeys.FIRST_AID] = "Interface\\Icons\\spell_holy_sealofsacrifice",
    [QuestieProfessions.professionKeys.BLACKSMITHING] = "Interface\\Icons\\trade_blacksmithing",
    [QuestieProfessions.professionKeys.LEATHERWORKING] = "Interface\\Icons\\trade_leatherworking",
    [QuestieProfessions.professionKeys.ALCHEMY] = "Interface\\Icons\\trade_alchemy",
    [QuestieProfessions.professionKeys.HERBALISM] = "Interface\\Icons\\trade_herbalism",
    [QuestieProfessions.professionKeys.COOKING] = "Interface\\Icons\\inv_misc_food_15",
    [QuestieProfessions.professionKeys.MINING] = "Interface\\Icons\\trade_mining",
    [QuestieProfessions.professionKeys.TAILORING] = "Interface\\Icons\\trade_tailoring",
    [QuestieProfessions.professionKeys.ENGINEERING] = "Interface\\Icons\\trade_engineering",
    [QuestieProfessions.professionKeys.ENCHANTING] = "Interface\\Icons\\trade_engraving",
    [QuestieProfessions.professionKeys.FISHING] = "Interface\\Icons\\trade_fishing",
    [QuestieProfessions.professionKeys.SKINNING] = "Interface\\Icons\\inv_misc_pelt_wolf_01",
    [QuestieProfessions.professionKeys.JEWELCRAFTING] = "Interface\\Icons\\inv_misc_gem_01",
}

local _spawned = {} -- used to check if we have already spawned an icon for this npc

local function toggle(key, forceRemove) -- /run QuestieLoader:ImportModule("QuestieMap"):ShowNPC(525, nil, 1, "teaste", {}, true)
    local ids = Questie.db.global.townsfolk[key] or
            Questie.db.char.townsfolk[key] or
            Questie.db.global.professionTrainers[key] or
            Questie.db.char.vendorList[key]

    if (not ids) then
        Questie:Debug(Questie.DEBUG_INFO, "Invalid townsfolk key", tostring(key))
        return
    end

    local icon = _townsfolk_texturemap[key] or ("Interface\\Minimap\\tracking\\" .. strlower(key))
    if key == "Mailbox" or key == "Meeting Stones" then -- object type townsfolk
        if Questie.db.char.townsfolkConfig[key] and (not forceRemove) then
            for _, id in pairs(ids) do
                if key == "Meeting Stones" then
                    local dungeonName, levelRange = MeetingStones:GetLocalizedDungeonNameAndLevelRangeByObjectId(id)
                    if dungeonName and levelRange then
                        QuestieMap:ShowObject(id, icon, 1.2, Questie:Colorize(l10n("Meeting Stone"), "white") .. "|n" .. dungeonName .. " " .. levelRange, {}, true, key)
                    end
                else
                    QuestieMap:ShowObject(id, icon, 1.2, Questie:Colorize(l10n(key), "white"), {}, true, key)
                end
            end
        else
            for _, id in pairs(ids) do
                QuestieMap:UnloadManualFrames(id, key)
            end
        end
    else
        if Questie.db.char.townsfolkConfig[key] and (not forceRemove) then
            local faction = UnitFactionGroup("Player")
            local timer
            local e = 1
            local max = (#ids)+1
            timer = C_Timer.NewTicker(0.01, function() 
                local start = e
                while e < max and e-start < 32 do
                    local id = ids[e]
                    if (not _spawned[id]) then
                        local friendly = QuestieDB.QueryNPCSingle(id, "friendlyToFaction")
                        if ((not friendly) or friendly == "AH" or (faction == "Alliance" and friendly == "A") or (faction == "Horde" and friendly == "H")) and (not QuestieCorrections.questNPCBlacklist[id]) then
                            QuestieMap:ShowNPC(id, icon, 1.2, Questie:Colorize(QuestieDB.QueryNPCSingle(id, "name") or ("Missing NPC name for " .. tostring(id)), "white") .. " (" .. (QuestieDB.QueryNPCSingle(id, "subName") or l10n(tostring(key)) or key) .. ")", {}--[[{key, ""}]], true, key, true)
                            _spawned[id] = true
                        end
                    end
                    e = e + 1
                end
                if e == max then
                    timer:Cancel()
                end
            end)
        else
            for _, id in pairs(ids) do
                QuestieMap:UnloadManualFrames(id, key)
                _spawned[id] = nil
            end
        end
    end
end

local function build(key)
    local icon = _townsfolk_texturemap[key] or ("Interface\\Minimap\\tracking\\" .. strlower(key))

    return {
        text = l10n(tostring(key)),
        func = function() Questie.db.char.townsfolkConfig[key] = not Questie.db.char.townsfolkConfig[key] toggle(key) end, 
        icon=icon, 
        notCheckable=false,
        checked=Questie.db.char.townsfolkConfig[key], 
        isNotRadio=true, 
        keepShownOnClick=true
    }
end

local function buildLocalized(key, localizedText)
    local icon = _townsfolk_texturemap[key] or ("Interface\\Minimap\\tracking\\" .. strlower(key))

    return {
        text = localizedText,
        func = function() Questie.db.char.townsfolkConfig[key] = not Questie.db.char.townsfolkConfig[key] toggle(key) end,
        icon=icon,
        notCheckable=false,
        checked=Questie.db.char.townsfolkConfig[key],
        isNotRadio=true,
        keepShownOnClick=true
    }
end

function QuestieMenu:OnLogin(forceRemove) -- toggle all icons
    QuestieMenu:UpdatePlayerVendors()

    if (not Questie.db.char.townsfolkConfig) then
        Questie.db.char.townsfolkConfig = {
            ["Flight Master"] = true,
            ["Mailbox"] = true,
            ["Meeting Stones"] = true
        }
    end
    for key in pairs(Questie.db.char.townsfolkConfig) do
        if forceRemove then
            toggle(key, forceRemove)
        end
        toggle(key)
    end
end

local div = { -- from libEasyMenu code
    hasArrow = false,
    dist = 0,
    isTitle = true,
    isUninteractable = true,
    notCheckable = true,
    iconOnly = true,
    isSeparator = true,
    icon = "Interface\\Common\\UI-TooltipDivider-Transparent",
    tCoordLeft = 0,
    tCoordRight = 1,
    tCoordTop = 0,
    tCoordBottom = 1,
    tSizeX = 0,
    tSizeY = 8,
    tFitDropDownSizeX = true,
    text="",
    iconInfo = {
        tCoordLeft = 0,
        tCoordRight = 1,
        tCoordTop = 0,
        tCoordBottom = 1,
        tSizeX = 0,
        tSizeY = 8,
        tFitDropDownSizeX = true
    },
}
local secondaryProfessions = {
    [QuestieProfessions.professionKeys.FIRST_AID] = true,
    [QuestieProfessions.professionKeys.COOKING] = true,
    [QuestieProfessions.professionKeys.FISHING] = true
}

function QuestieMenu:Show()
    if not Questie.db.char.townsfolkConfig then
        Questie.db.char.townsfolkConfig = {}
    end
    if not QuestieMenu.menu then
        QuestieMenu.menu = LibDropDown:Create_UIDropDownMenu("QuestieTownsfolkMenuFrame", UIParent)
    end
    local menuTable = {}
    for key in pairs(Questie.db.global.townsfolk) do
        tinsert(menuTable, build(key))
    end
    for key in pairs(Questie.db.char.townsfolk) do
        tinsert(menuTable, build(key))
    end

    local function buildProfessionMenu()
        local profMenu = {}
        local profMenuSorted = {}
        local secondaryProfMenuSorted = {}
        local profMenuData = {}
        for key, _ in pairs(Questie.db.global.professionTrainers) do
            local localizedKey = l10n(QuestieProfessions:GetProfessionName(key))
            profMenuData[localizedKey] = buildLocalized(key, localizedKey)
            if secondaryProfessions[key] then
                tinsert(secondaryProfMenuSorted, localizedKey)
            else
                tinsert(profMenuSorted, localizedKey)
            end
        end
        table.sort(profMenuSorted)
        table.sort(secondaryProfMenuSorted)
        for _, key in pairs(profMenuSorted) do
            tinsert(profMenu, profMenuData[key])
        end
        tinsert(profMenu, div)
        for _, key in pairs(secondaryProfMenuSorted) do
            tinsert(profMenu, profMenuData[key])
        end
        return profMenu
    end

    local function buildVendorMenu()
        local vendorMenu = {}
        local vendorMenuSorted = {}
        local vendorMenuData = {}
        for key, _ in pairs(Questie.db.char.vendorList) do
            local localizedKey = l10n(tostring(key))
            vendorMenuData[localizedKey] = build(key)
            tinsert(vendorMenuSorted, localizedKey)
        end
        table.sort(vendorMenuSorted)
        for _, key in pairs(vendorMenuSorted) do
            tinsert(vendorMenu, vendorMenuData[key])
        end
        return vendorMenu
    end

    tinsert(menuTable, { text= l10n("Available Quest"), func = function()
        local value = not Questie.db.global.enableAvailable
        Questie.db.global.enableAvailable = value
        QuestieQuest:ToggleNotes(value)
        QuestieQuest:SmoothReset()
    end, icon=QuestieLib.AddonPath.."Icons\\available.blp", notCheckable=false, checked=Questie.db.global.enableAvailable, isNotRadio=true, keepShownOnClick=true})
    tinsert(menuTable, { text= l10n("Trivial Quest"), func = function()
        local value = not Questie.db.char.lowlevel
        Questie.db.char.lowlevel = value
        QuestieOptions.AvailableQuestRedraw()
    end, icon=QuestieLib.AddonPath.."Icons\\available_gray.blp", notCheckable=false, checked=Questie.db.char.lowlevel, isNotRadio=true, keepShownOnClick=true})
    tinsert(menuTable, { text= l10n("Objective"), func = function()
        local value = not Questie.db.global.enableObjectives
        Questie.db.global.enableObjectives = value
        QuestieQuest:ToggleNotes(value)
        QuestieQuest:SmoothReset()
    end, icon=QuestieLib.AddonPath.."Icons\\event.blp", notCheckable=false, checked=Questie.db.global.enableObjectives, isNotRadio=true, keepShownOnClick=true})
    tinsert(menuTable, {text= l10n("Profession Trainer"), func = function() end, keepShownOnClick=true, hasArrow=true, menuList=buildProfessionMenu(), notCheckable=true})
    tinsert(menuTable, {text= l10n("Vendor"), func = function() end, keepShownOnClick=true, hasArrow=true, menuList=buildVendorMenu(), notCheckable=true})

    tinsert(menuTable, div)

    tinsert(menuTable, { text= l10n('Advanced Search'), func=function() QuestieOptions:HideFrame(); QuestieJourney.tabGroup:SelectTab("search"); QuestieJourney.ToggleJourneyWindow() end})
    tinsert(menuTable, { text= l10n("Questie Options"), func=function() QuestieOptions:OpenConfigWindow() end})
    tinsert(menuTable, { text= l10n('My Journey'), func=function() QuestieOptions:HideFrame(); QuestieJourney.tabGroup:SelectTab("journey"); QuestieJourney.ToggleJourneyWindow() end})

    if Questie.db.global.debugEnabled then -- add recompile db & reload buttons when debugging is enabled
        tinsert(menuTable, { text= l10n('Recompile Database'), func=function() Questie.db.global.dbIsCompiled = false; ReloadUI() end})
        tinsert(menuTable, { text= l10n('Reload UI'), func=function() ReloadUI() end})
    end

    tinsert(menuTable, {text= l10n('Cancel'), func=function() end})
    LibDropDown:EasyMenu(menuTable, QuestieMenu.menu, "cursor", -80, 0, "MENU")
end

local function _reformatVendors(lst, existingTable)
    local newList = existingTable or {}
    for k in pairs(lst) do
        tinsert(newList, k)
    end
    return newList
end

function QuestieMenu:PopulateTownsfolkType(mask, requireSubname) -- populate the table with all npc ids based on the given bitmask
    local tbl = {}
    for id, data in pairs(QuestieDB.npcData) do
        local flags = data[QuestieDB.npcKeys.npcFlags]
        if flags and bit.band(flags, mask) == mask then
            local name = data[QuestieDB.npcKeys.name]
            local subName = data[QuestieDB.npcKeys.subName]
            if name and string.sub(name, 1, 5) ~= "[DND]" then
                if (not requireSubname) or (subName and string.len(subName) > 1) then
                    tinsert(tbl, id)
                end
            end
        end
    end
    return tbl
end

function QuestieMenu:PopulateTownsfolk()
    Questie.db.global.townsfolk = {
        ["Repair"] = QuestieMenu:PopulateTownsfolkType(QuestieDB.npcFlags.REPAIR, true), 
        ["Auctioneer"] = QuestieMenu:PopulateTownsfolkType(QuestieDB.npcFlags.AUCTIONEER, false),
        ["Banker"] = QuestieMenu:PopulateTownsfolkType(QuestieDB.npcFlags.BANKER, true),
        ["Battlemaster"] = QuestieMenu:PopulateTownsfolkType(QuestieDB.npcFlags.BATTLEMASTER, true),
        ["Flight Master"] = QuestieMenu:PopulateTownsfolkType(QuestieDB.npcFlags.FLIGHT_MASTER),
        ["Innkeeper"] = QuestieMenu:PopulateTownsfolkType(QuestieDB.npcFlags.INNKEEPER, true),
        ["Weapon Master"] = {}, -- populated below
    }
    Questie.db.global.townsfolkNeedsUpdatedGlobalVendors = true

    -- SELECT entry FROM creature_template WHERE trainertype=0 AND trainerclass=1; --Warrior
    -- SELECT entry FROM creature_template WHERE trainertype=0 AND trainerclass=2; --Paladin
    -- SELECT entry FROM creature_template WHERE trainertype=0 AND trainerclass=3; --Hunter
    -- SELECT entry FROM creature_template WHERE trainertype=0 AND trainerclass=4; --Rogue
    -- SELECT entry FROM creature_template WHERE trainertype=0 AND trainerclass=5; --Priest
    -- SELECT entry FROM creature_template WHERE trainertype=0 AND trainerclass=6; --Deathknight
    -- SELECT entry FROM creature_template WHERE trainertype=0 AND trainerclass=7; --Shaman
    -- SELECT entry FROM creature_template WHERE trainertype=0 AND trainerclass=8; --Mage
    -- SELECT entry FROM creature_template WHERE trainertype=0 AND trainerclass=9; --Warlock
    -- SELECT entry FROM creature_template WHERE trainertype=0 AND trainerclass=10; --unknown
    -- SELECT entry FROM creature_template WHERE trainertype=0 AND trainerclass=11; --Druid
    local classTrainers
    if Questie.IsWotlk then
        classTrainers = {
            ["WARRIOR"]={911,912,913,914,985,1229,1901,2119,2131,3041,3042,3043,3059,3063,3153,3169,3353,3354,3408,3593,3598,4087,4089,4593,4594,4595,5113,5114,5479,5480,7315,8141,16503,16771,17120,17480,17504,26332},
            ["PALADIN"]={925,926,927,928,1232,5147,5148,5149,5491,5492,8140,15280,16275,16501,16679,16680,16681,16761,17121,17483,17509,17844,20406,23128,26327,35281},
            ["HUNTER"]={895,987,1231,1404,3038,3039,3040,3061,3065,3154,3171,3352,3406,3407,3596,3601,3963,4138,4146,4205,5115,5116,5117,5501,5515,5516,5517,8308,10930,15513,16270,16499,16672,16673,16674,16738,17110,17122,17505,26325},
            ["ROGUE"]={915,916,917,918,1234,1411,2122,2130,3155,3170,3327,3328,3401,3594,3599,4163,4214,4215,4582,4583,4584,5165,5166,5167,6707,13283,15285,16279,16684,16685,16686,26329},
            ["PRIEST"]={375,376,377,837,1226,2123,2129,3044,3045,3046,3595,3600,3706,3707,4090,4091,4092,4606,4607,4608,5141,5142,5143,5484,5489,5994,6014,6018,11397,11401,11406,15284,16276,16502,16658,16659,16660,16756,17482,17510,17511,26328},
            ["DEATHKNIGHT"]={28471,28472,28474,29194,29195,29196,31084},
            ["SHAMAN"]={986,3030,3031,3032,3062,3066,3157,3173,3344,3403,13417,17089,17204,17212,17219,17519,17520,20407,23127,26330},
            ["MAGE"]={198,328,331,944,1228,2124,2128,2485,2489,2492,3047,3048,3049,4165,4566,4567,4568,5144,5145,5146,5497,5498,5880,5882,5883,5884,5885,5957,5958,7311,7312,15279,16269,16500,16651,16652,16653,16654,16749,16755,17105,17481,17513,17514,19340,20791,23103,26326,27703,27704,27705,28956,28958,29156},
            ["WARLOCK"]={459,460,461,906,988,2126,2127,3156,3172,3324,3325,3326,4563,4564,4565,5171,5172,5173,5495,5496,5612,6251,15283,16266,16646,16647,16648,23534,26331},
            ["UNKNOWN"]={},
            ["DRUID"]={3033,3034,3036,3060,3064,3597,3602,4217,4218,4219,5504,5505,5506,8142,9465,12042,16655,16721,26324},
        }
    elseif Questie.IsTBC then
        classTrainers = {
            ["WARRIOR"] = {911,912,913,914,985,1229,1901,2119,2131,3041,3042,3043,3059,3063,3153,3169,3353,3354,3408,3593,3598,4087,4089,4593,4594,4595,4992,5113,5114,5479,5480,7315,8141,16387,16503,16771,17120,17480,17504,26332},
            ["PALADIN"] = {925,926,927,928,1232,4988,5147,5148,5149,5491,5492,8140,15280,16275,16501,16679,16680,16681,16761,17121,17483,17509,17844,20406,23128,26327},
            ["HUNTER"] = {895,987,1231,1404,3038,3039,3040,3061,3065,3154,3171,3352,3406,3407,3596,3601,3963,4138,4146,4205,4986,5115,5116,5117,5501,5515,5516,5517,8308,10930,15513,16270,16499,16672,16673,16674,16738,17110,17122,17505,26325},
            ["ROGUE"] = {915,916,917,918,1234,1411,2122,2130,3155,3170,3327,3328,3401,3594,3599,4163,4214,4215,4582,4583,4584,4990,5165,5166,5167,13283,15285,16279,16684,16685,16686,22005,26329},
            ["PRIEST"] = {375,376,377,837,1226,2123,2129,3044,3045,3046,3595,3600,3706,3707,4090,4091,4092,4606,4607,4608,4989,5141,5142,5143,5484,5489,5994,6014,6018,11397,11401,11406,15284,16276,16502,16658,16659,16660,16756,17482,17510,17511,26328},
            ["SHAMAN"] = {986,3030,3031,3032,3062,3066,3157,3173,3344,3403,4991,13417,17089,17204,17212,17219,17519,17520,20407,23127,26330},
            ["MAGE"] = {198,313,328,331,944,1228,2124,2128,3047,3048,3049,4566,4567,4568,4987,5144,5145,5146,5497,5498,5880,5882,5883,5884,5885,7311,7312,15279,16269,16500,16651,16652,16653,16749,17481,17513,17514,26326,27704},
            ["WARLOCK"] = {459,460,461,906,988,2126,2127,3156,3172,3324,3325,3326,4563,4564,4565,4993,5171,5172,5173,5495,5496,5612,6251,15283,16266,16646,16647,16648,26331},
            ["DRUID"] = {3033,3034,3036,3060,3064,3597,3602,4217,4218,4219,4985,5504,5505,5506,8142,9465,12042,16655,16721,26324}
        }
    else
        classTrainers = {
            ["WARRIOR"] = {911,912,913,914,985,1229,1901,2119,2131,3041,3042,3043,3059,3063,3153,3169,3353,3354,3408,3593,3598,4087,4089,4593,4594,4595,5113,5114,5479,5480,7315,8141,16387},
            ["PALADIN"] = {925,926,927,928,1232,5147,5148,5149,5491,5492,8140},
            ["HUNTER"] = {895,987,1231,1404,3038,3039,3040,3061,3065,3154,3171,3352,3406,3407,3596,3601,3963,4138,4146,4205,5115,5116,5117,5501,5515,5516,5517,8308,10930},
            ["ROGUE"] = {915,916,917,918,1234,1411,2122,2130,3155,3170,3327,3328,3401,3594,3599,4163,4214,4215,4582,4583,4584,5165,5166,5167,13283},
            ["PRIEST"] = {375,376,377,837,1226,2123,2129,3044,3045,3046,3595,3600,3706,3707,4090,4091,4092,4606,4607,4608,5141,5142,5143,5484,5489,5994,6014,6018,11397,11401,11406},
            ["SHAMAN"] = {986,3030,3031,3032,3062,3066,3157,3173,3344,3403,13417},
            ["MAGE"] = {198,313,328,331,944,1228,2124,2128,3047,3048,3049,4566,4567,4568,5144,5145,5146,5497,5498,5880,5882,5883,5884,5885,7311,7312},
            ["WARLOCK"] = {459,460,461,906,988,2126,2127,3156,3172,3324,3325,3326,4563,4564,4565,5171,5172,5173,5495,5496,5612},
            ["DRUID"] = {3033,3034,3036,3060,3064,3597,3602,4217,4218,4219,5504,5505,5506,8142,9465,12042}
        }
    end

    -- SELECT Entry FROM creature_template WHERE NpcFlags & 16 = 16 AND TrainerType=2
    local validProfessionTrainers
    if Questie.IsWotlk then
        validProfessionTrainers = {514,812,908,1103,1215,1218,1241,1292,1300,1317,1346,1355,1382,1385,1386,1430,1458,1470,1473,1632,1651,1676,1680,1681,1683,1699,1700,1701,1702,1703,2114,2132,2326,2327,2329,2367,2390,2391,2399,2627,2704,2798,2818,2834,2836,2837,2855,2856,2998,3001,3004,3007,3009,3011,3013,3026,3028,3067,3069,3087,3136,3137,3174,3175,3179,3181,3184,3185,3290,3332,3345,3347,3355,3357,3363,3365,3373,3399,3404,3478,3484,3494,3523,3549,3555,3557,3603,3604,3605,3606,3607,3703,3704,3964,3965,3967,4156,4159,4160,4193,4204,4210,4211,4212,4213,4254,4258,4552,4573,4576,4578,4588,4591,4596,4598,4611,4614,4616,4898,4900,5032,5037,5038,5040,5041,5127,5137,5150,5153,5157,5159,5161,5164,5174,5177,5392,5482,5493,5499,5502,5511,5513,5518,5564,5566,5690,5695,5759,5784,5938,5939,5941,5943,6094,6286,6287,6288,6289,6290,6291,6292,6295,6297,6299,6306,6387,7087,7088,7089,7230,7231,7232,7406,7866,7867,7868,7869,7870,7871,7944,7946,7948,7949,8126,8128,8144,8146,8153,8306,8736,8738,9584,10370,10993,11017,11025,11031,11037,11048,11050,11051,11052,11072,11073,11074,11097,11098,11146,11177,11178,11557,11865,11866,11867,11868,11869,11870,12025,12030,12032,12961,13084,14740,15400,15501,16000,16160,16161,16190,16253,16265,16272,16273,16277,16278,16366,16367,16583,16588,16621,16633,16639,16640,16642,16644,16662,16663,16667,16669,16676,16688,16692,16702,16719,16723,16724,16725,16726,16727,16728,16729,16731,16736,16744,16746,16752,16763,16773,16774,16780,16823,17005,17101,17214,17215,17222,17245,17246,17424,17434,17441,17442,17487,17488,17634,17637,17983,18018,18747,18748,18749,18751,18752,18753,18754,18755,18771,18772,18773,18774,18775,18776,18777,18779,18802,18804,18911,18987,18988,18990,18991,18993,19052,19063,19180,19184,19185,19186,19187,19251,19252,19341,19369,19478,19539,19540,19576,19774,19775,19777,19778,20124,20125,21087,22477,23734,24868,25099,25277,26564,26903,26904,26905,26906,26907,26909,26910,26911,26912,26913,26914,26915,26916,26951,26952,26953,26954,26955,26956,26957,26958,26959,26960,26961,26962,26963,26964,26969,26972,26974,26975,26976,26977,26980,26981,26982,26986,26987,26988,26989,26990,26991,26992,26993,26994,26995,26996,26997,26998,26999,27000,27001,27023,27029,27034,28693,28694,28696,28697,28698,28699,28700,28701,28702,28703,28704,28705,28706,28742,29233,29505,29506,29507,29508,29509,29513,29514,29631,29924,30706,30709,30710,30711,30713,30715,30716,30717,30721,30722,32474,33580,33581,33586,33587,33589,33590,33630,33631,33633,33634,33635,33636,33637,33638,33640,33641,33674,33675,33676,33677,33678,33679,33680,33681,33682,33683,33684,33996}
    elseif Questie.IsTBC then
        validProfessionTrainers =  {
            514,812,908,1103,1215,1218,1241,1292,1300,1317,1346,1355,1382,1385,1386,1430,1458,1470,1473,1632,1651,1676,1680,1681,1683,
            1699,1700,1701,1702,1703,2114,2132,2326,2327,2329,2367,2390,2391,2399,2627,2704,2798,2818,2834,2836,2837,2855,2856,2998,3001,
            3004,3007,3009,3011,3013,3026,3028,3067,3069,3087,3136,3137,3174,3175,3179,3181,3184,3185,3290,3332,3345,3347,3355,3357,3363,
            3365,3373,3399,3404,3478,3484,3494,3523,3549,3555,3557,3603,3604,3605,3606,3607,3703,3704,3964,3965,3967,4156,4159,4160,4193,
            4204,4210,4211,4212,4213,4254,4258,4552,4573,4576,4578,4588,4591,4596,4598,4611,4614,4616,4898,4900,5127,5137,5150,5153,5157,
            5159,5161,5164,5174,5177,5392,5482,5493,5499,5502,5511,5513,5518,5564,5566,5690,5695,5759,5784,5938,5939,5941,5943,6094,6286,
            6287,6288,6289,6290,6291,6292,6295,6297,6299,6306,6387,7087,7088,7089,7230,7231,7232,7406,7866,7867,7868,7869,7870,7871,7944,
            7946,7948,7949,8126,8128,8144,8146,8153,8306,8736,8738,9584,10370,10993,11017,11025,11031,11037,11048,11050,11051,11052,11072,
            11073,11074,11097,11098,11146,11177,11178,11865,11866,11867,11868,11869,11870,12025,12030,12032,12920,12939,12961,13084,14401,14740,15400,
            15501,16160,16161,16253,16272,16273,16277,16278,16366,16367,16583,16588,16621,16633,16639,16640,16642,16644,16662,16663,16667,
            16669,16676,16688,16692,16702,16719,16723,16724,16725,16726,16727,16728,16729,16731,16736,16744,16746,16752,16763,16773,16774,
            16780,16823,17005,17101,17214,17215,17222,17245,17246,17424,17434,17441,17442,17487,17488,17634,17637,17983,18018,18747,18748,
            18749,18751,18752,18753,18754,18755,18771,18772,18773,18774,18775,18776,18777,18779,18802,18804,18987,18988,18990,18991,18993,
            19052,19063,19180,19184,19185,19186,19187,19251,19252,19341,19369,19478,19539,19540,19576,19774,19775,19777,19778,20124,20125,
            21087,22477,24868,25099
        } 
    else 
        validProfessionTrainers = {
            223,514,812,908,957,1103,1215,1218,1241,1246,1292,1300,1317,1346,1355,1382,1383,1385,1386,1430,1458,1466,1470,1473,1632,1651,
            1676,1680,1681,1683,1699,1700,1701,1702,1703,2114,2132,2326,2327,2329,2367,2390,2391,2399,2627,2704,2737,2798,2818,2834,2836,
            2837,2855,2856,2857,2998,3001,3004,3007,3008,3009,3011,3013,3026,3028,3067,3069,3087,3136,3137,3174,3175,3179,3181,3184,3185,
            3290,3332,3345,3347,3355,3357,3363,3365,3373,3399,3404,3412,3478,3484,3494,3523,3530,3531,3549,3555,3557,3603,3604,3605,3606,
            3607,3703,3704,3964,3965,3967,4156,4159,4160,4193,4204,4210,4211,4212,4213,4254,4258,4552,4573,4576,4578,4586,4588,4591,4596,
            4598,4605,4609,4611,4614,4616,4898,4900,5127,5137,5150,5153,5157,5159,5161,5164,5174,5177,5392,5482,5493,5499,5500,5502,5511,
            5513,5518,5564,5566,5567,5690,5695,5759,5784,5811,5938,5939,5941,5943,6094,6286,6287,6288,6289,6290,6291,6292,6295,6297,6299,
            6306,6387,7087,7088,7089,7230,7231,7232,7406,7866,7867,7868,7869,7870,7871,7944,7946,7948,7949,8126,8128,8144,8146,8153,8306,
            8736,8738,9584,10266,10276,10277,10278,10993,11017,11025,11026,11028,11029,11031,11037,11041,11042,11044,11046,11047,11048,
            11049,11050,11051,11052,11065,11066,11067,11068,11070,11071,11072,11073,11074,11081,11083,11084,11096,11097,11098,11146,
            11177,11178,11865,11866,11867,11868,11869,11870,12025,12030,12032,12920,12939,12961,13084,14401,14740
        }
    end

    local professionTrainers = {
        [QuestieProfessions.professionKeys.FIRST_AID] = {},
        [QuestieProfessions.professionKeys.BLACKSMITHING] = {},
        [QuestieProfessions.professionKeys.LEATHERWORKING] = {},
        [QuestieProfessions.professionKeys.ALCHEMY] = {},
        [QuestieProfessions.professionKeys.HERBALISM] = {},
        [QuestieProfessions.professionKeys.COOKING] = {},
        [QuestieProfessions.professionKeys.MINING] = {},
        [QuestieProfessions.professionKeys.TAILORING] = {},
        [QuestieProfessions.professionKeys.ENGINEERING] = {},
        [QuestieProfessions.professionKeys.ENCHANTING] = {},
        [QuestieProfessions.professionKeys.FISHING] = {},
        [QuestieProfessions.professionKeys.SKINNING] = {}
    }

    if Questie.IsTBC or Questie.IsWotlk then
        professionTrainers[QuestieProfessions.professionKeys.JEWELCRAFTING] = {}
    end

    for _, id in pairs(validProfessionTrainers) do
        if QuestieDB.npcData[id] then
            local subName = QuestieDB.npcData[id][QuestieDB.npcKeys.subName]
            if subName then
                if Questie.db.global.townsfolk[subName] then -- weapon master, 
                    tinsert(Questie.db.global.townsfolk[subName], id)
                else
                    for k, professionId in pairs(QuestieProfessions.professionTable) do
                        if string.match(subName, k) then
                            tinsert(professionTrainers[professionId], id)
                        end
                    end
                end
            end
        end
    end

    -- Fix NPC Gubber Blump (10216) can train fishing profession
    tinsert(professionTrainers[QuestieProfessions.professionKeys.FISHING], 10216)

    -- Fix NPC Aresella (18991) can train first aid profession
    if Questie.IsTBC or Questie.IsWotlk then
        tinsert(professionTrainers[QuestieProfessions.professionKeys.FIRST_AID], 18991)
    end

    Questie.db.global.professionTrainers = professionTrainers

    if Questie.IsTBC or Questie.IsWotlk then
        local meetingStones = Questie.IsTBC and { --TBC
            178824,178825,178826,178827,178828,178829,178831,178832,178833,178834,178844,178845,
            178884,179554,179555,179584,179585,179586,179587,179595,179596,179597,182558,182559,
            182560,184455,184456,184458,184462,184463,185321,185322,185433,185550,186251,188171,
            188172
        } or {-- Wotlk
            178824,178825,178826,178827,178828,178829,178831,178832,178833,178834,178844,178845,
            178884,179554,179555,179584,179585,179586,179587,179595,179596,179597,182558,182559,
            182560,184455,184456,184458,184462,184463,185321,185322,185433,185550,186251,188171,
            188172,188488,191227,191529,192017,192399,192557,192622,193166,193602,194097,195013,
            195498,195695,202184}

        Questie.db.global.townsfolk["Meeting Stones"] = {}
        for _, id in pairs(meetingStones) do
            tinsert(Questie.db.global.townsfolk["Meeting Stones"], id)
        end
    end

    -- todo: specialized trainer types (leatherworkers, engineers, etc)

    Questie.db.global.classSpecificTownsfolk = {}
    Questie.db.global.factionSpecificTownsfolk = {["Horde"] = {}, ["Alliance"] = {}}


    for class, trainers in pairs(classTrainers) do
        local newTrainers = {}
        for _, trainer in pairs(trainers) do
            if QuestieDB.npcData[trainer] then
                local subName = QuestieDB.npcData[trainer][QuestieDB.npcKeys.subName]
                if subName and string.len(subName) > 0 then
                    tinsert(newTrainers, trainer)
                end
            end
        end
        Questie.db.global.classSpecificTownsfolk[class] = {}
        Questie.db.global.classSpecificTownsfolk[class]["Class Trainer"] = newTrainers
    end
    --Questie.db.char.townsfolk["Class Trainer"] = classTrainers[class]

    if playerClass == "HUNTER" then
        Questie.db.global.classSpecificTownsfolk["HUNTER"]["Stable Master"] = QuestieMenu:PopulateTownsfolkType(QuestieDB.npcFlags.STABLEMASTER)
    elseif playerClass == "MAGE" then
        Questie.db.global.classSpecificTownsfolk["MAGE"]["Portal Trainer"] = {4165,2485,2489,5958,5957,2492,16654,16755,19340,20791,27703,27705}
    end

    Questie.db.global.factionSpecificTownsfolk["Horde"]["Spirit Healer"]  = QuestieMenu:PopulateTownsfolkType(QuestieDB.npcFlags.SPIRIT_HEALER)
    Questie.db.global.factionSpecificTownsfolk["Alliance"]["Spirit Healer"]  = QuestieMenu:PopulateTownsfolkType(QuestieDB.npcFlags.SPIRIT_HEALER)

    Questie.db.global.factionSpecificTownsfolk["Horde"]["Mailbox"] = {}
    Questie.db.global.factionSpecificTownsfolk["Alliance"]["Mailbox"] = {}

    for _, id in pairs(Questie.IsTBC and { -- mailbox list
        --TBC
        32349,140908,142075,142089,142093,142094,142095,142102,142109,142110,142111,142117,143981,143982,143983,143984,
        143985,143987,143988,143989,143990,144011,144112,144125,144126,144127,144128,144129,144130,144131,144179,144570,
        153578,153716,157637,163313,163645,164618,164840,171556,171699,171752,173047,173221,176324,176404,177044,178864,
        179895,179896,180451,181236,181380,181381,181883,181980,182356,182357,182359,182360,182361,182362,182363,182364,
        182365,182567,182939,182946,182948,182949,182950,182955,183037,183038,183039,183040,183042,183047,183167,183856,
        183857,183858,184085,184133,184134,184135,184136,184137,184138,184139,184140,184147,184148,184490,184652,184944,
        185102,185471,185472,185473,185477,142103,176319,142119,143986,175864,181639,185965,186230,186629,188132,187260,
        187113,188123
    } or Questie.IsWotlk and {
        --Wotlk
        32349,140908,142075,142089,142093,142094,142095,142102,142103,142109,142110,142111,142117,142119,143981,143982,
        143983,143984,143985,143986,143987,143988,143989,143990,144011,144112,144125,144126,144127,144128,144129,144130,
        144131,144179,144570,153578,153716,157637,163313,163645,164618,164840,171556,171699,171752,173047,173221,175668,
        175864,176319,176324,176404,177044,178864,179895,179896,180451,181236,181380,181381,181639,181883,181980,182356,
        182357,182359,182360,182361,182362,182363,182364,182365,182391,182567,182939,182946,182948,182949,182950,182955,
        183037,183038,183039,183040,183042,183047,183167,183856,183857,183858,184085,184133,184134,184135,184136,184137,
        184138,184139,184140,184147,184148,184490,184652,184944,185102,185471,185472,185473,185477,185965,186230,186435,
        186506,186629,186687,187113,187260,187268,187316,187322,188123,188132,188241,188256,188355,188486,188531,188534,
        188541,188604,188618,188682,188710,189328,189329,189969,190914,190915,191228,191521,191605,191832,191946,191947,
        191948,191949,191950,191951,191952,191953,191954,191955,191956,191957,192952,193030,193043,193044,193045,193071,
        193791,193972,194016,194027,194147,194492,194788,195218,195219,195467,195468,195528,195529,195530,195554,195555,
        195556,195557,195558,195559,195560,195561,195562,195603,195604,195605,195606,195607,195608,195609,195610,195611,
        195612,195613,195614,195615,195616,195617,195618,195619,195620,195624,195625,195626,195627,195628,195629
    } or {
        --Classic
        32349,142075,142089,142093,142094,142095,142102,142103,142109,142110,142111,142117,142119,143981,143982,143983,
        143984,143985,143986,143987,143988,143989,143990,144011,144112,144125,144126,144127,144128,144129,144131,153578,
        153716,157637,163313,163645,164618,164840,171556,171699,171752,173047,173221,176319,176324,176404,177044,178864,
        179895,179896,180451,181236,181639,187260,188123
    }) do
        if QuestieDB.objectData[id] then
            local factionID = QuestieDB.objectData[id][QuestieDB.objectKeys.factionID]

            if factionID == 0 then
                tinsert(Questie.db.global.factionSpecificTownsfolk["Horde"]["Mailbox"], id)
                tinsert(Questie.db.global.factionSpecificTownsfolk["Alliance"]["Mailbox"], id)
            elseif QuestieDB.factionTemplate[factionID] and bit.band(QuestieDB.factionTemplate[factionID], 12) == 0 and bit.band(QuestieDB.factionTemplate[factionID], 10) == 0 then
                tinsert(Questie.db.global.factionSpecificTownsfolk["Horde"]["Mailbox"], id)
                tinsert(Questie.db.global.factionSpecificTownsfolk["Alliance"]["Mailbox"], id)
            elseif QuestieDB.factionTemplate[factionID] and bit.band(QuestieDB.factionTemplate[factionID], 12) == 0 then
                tinsert(Questie.db.global.factionSpecificTownsfolk["Horde"]["Mailbox"], id)
            elseif QuestieDB.factionTemplate[factionID] and bit.band(QuestieDB.factionTemplate[factionID], 10) == 0 then
                tinsert(Questie.db.global.factionSpecificTownsfolk["Alliance"]["Mailbox"], id)
            else
                tinsert(Questie.db.global.factionSpecificTownsfolk["Horde"]["Mailbox"], id)
                tinsert(Questie.db.global.factionSpecificTownsfolk["Alliance"]["Mailbox"], id)
            end
        else
            Questie:Debug(Questie.DEBUG_DEVELOP, "Missing mailbox:", tostring(id))
        end
    end

    Questie.db.global.petFoodVendorTypes = {["Meat"] = {},["Fish"]={},["Cheese"]={},["Bread"]={},["Fungus"]={},["Fruit"]={},["Raw Meat"]={},["Raw Fish"]={}}
    local petFoodIndexes = {"Meat","Fish","Cheese","Bread","Fungus","Fruit","Raw Meat","Raw Fish"}

    for id, data in pairs(QuestieDB.itemData) do
        local foodType = data[QuestieDB.itemKeys.foodType]
        if foodType then
            tinsert(Questie.db.global.petFoodVendorTypes[petFoodIndexes[foodType]], id)
        end
    end
end

function QuestieMenu:PopulateTownsfolkPostBoot() -- post DB boot (use queries here)

    if Questie.db.global.townsfolkNeedsUpdatedGlobalVendors then
        Questie.db.global.townsfolkNeedsUpdatedGlobalVendors = nil
        -- insert item-based profession vendors
        _reformatVendors(QuestieMenu:PopulateVendors({22012, 21992, 21993, 16084, 16112, 16113, 16085, 19442, 6454, 8547, 23689}), Questie.db.global.professionTrainers[QuestieProfessions.professionKeys.FIRST_AID])
        _reformatVendors(QuestieMenu:PopulateVendors({27532, 16082, 16083}), Questie.db.global.professionTrainers[QuestieProfessions.professionKeys.FISHING])
        _reformatVendors(QuestieMenu:PopulateVendors({27736, 16072, 16073}), Questie.db.global.professionTrainers[QuestieProfessions.professionKeys.COOKING])
    end

    -- item ids for class-specific reagents
    local reagents = {
        ["MAGE"] = {17031, 17032, 17020},
        ["SHAMAN"] = {17030},
        ["PRIEST"] = {17029,17028},
        ["PALADIN"] = {21177,17033},
        ["WARRIOR"] = {},
        ["HUNTER"] = {},
        ["DEATHKNIGHT"] = {37201},
        ["WARLOCK"] = {5565,16583},
        ["ROGUE"] = {5140,2928,8924,5173,2930,8923},
        ["DRUID"] = {17034,17026,17035,17021,17038,17036,17037}
    }
    reagents = reagents[playerClass]

    -- populate vendor IDs from db
    if #reagents > 0 then
        Questie.db.char.townsfolk["Reagents"] = _reformatVendors(QuestieMenu:PopulateVendors(reagents))
    end
    Questie.db.char.vendorList["Trade Goods"] = _reformatVendors(QuestieMenu:PopulateVendors({ -- item ids from wowhead for trade goods   (temporarily disabled)
        14256,12810,13463,8845,8846,4234,3713,8170,14341,4389,3357,2453,13464,
        3355,3356,3358,4371,4304,5060,2319,18256,8925,3857,10940,2321,785,4404,2692,
        2605,3372,2320,6217,2449,4399,4364,10938,18567,4382,4289,765,3466,3371,2447,2880,
        2928,4361,10647,10648,4291,4357,8924,8343,4363,2678,5173,4400,2930,4342,2325,4340,
        6261,8923,2324,2604,6260,4378,10290,17194,4341
    }))
    Questie.db.char.vendorList["Bags"] = _reformatVendors(QuestieMenu:PopulateVendors({4496, 4497, 4498, 4499}))
    QuestieMenu:UpdatePlayerVendors()
end

function QuestieMenu:UpdatePetFood() -- call on change pet
    Questie.db.char.vendorList["Pet Food"] = {}
    -- detect petfood vendors for player's pet
    for _, key in pairs({GetStablePetFoodTypes(0)}) do
        if Questie.db.global.petFoodVendorTypes[key] then
            QuestieMenu:PopulateVendors(Questie.db.global.petFoodVendorTypes[key], Questie.db.char.vendorList["Pet Food"], true)
        end
    end
    Questie.db.char.vendorList["Pet Food"] = _reformatVendors(Questie.db.char.vendorList["Pet Food"])
end

function QuestieMenu:UpdateAmmoVendors() -- call on change weapon
    Questie.db.char.vendorList["Ammo"] = _reformatVendors(QuestieMenu:PopulateVendors({11285,3030,19316,2515,2512,11284,19317,2519,2516,3033,28056,28053,28061,28060}, {}, true))
end

function QuestieMenu:UpdateFoodDrink()
    local drink = {159,8766,1179,1708,1645,1205,17404,19300,19299,27860,28399,29395,29454,33042,32453,32455} -- water item ids
    local food = { -- food item ids (from wowhead)
        8932,4536,8952,19301,13724,8953,3927,11109,8957,4608,4599,4593,4592,117,3770,3771,4539,8950,8948,7228,
        2287,4601,422,16166,4537,4602,4542,4594,1707,4540,414,4538,4607,17119,19225,2070,21552,787,4544,18632,16167,4606,16170,
        4541,4605,17408,17406,11444,21033,22324,18635,21030,17407,19305,18633,4604,21031,16168,19306,16169,19304,17344,19224,19223,
        27857,27854,20857,27858,27856,29448,27855,29451,30355,28486,29450,29393,29394,29449,29452
    }

    Questie.db.char.vendorList["Food"] = _reformatVendors(QuestieMenu:PopulateVendors(food, {}, true))
    Questie.db.char.vendorList["Drink"] = _reformatVendors(QuestieMenu:PopulateVendors(drink, {}, true))
end

function QuestieMenu:UpdatePlayerVendors() -- call on levelup
    QuestieMenu:UpdateFoodDrink()
    if playerClass == "HUNTER" then
        QuestieMenu:UpdatePetFood()
        QuestieMenu:UpdateAmmoVendors()
    elseif playerClass == "ROGUE" or playerClass == "WARRIOR" then
        QuestieMenu:UpdateAmmoVendors()
    end

end

function QuestieMenu:PopulateVendors(itemList, existingTable, restrictLevel)
    local factionKey = playerFaction == "Alliance" and "A" or "H"
    local tbl = existingTable or {}
    local playerLevel = restrictLevel and UnitLevel("Player") or 0
    for _, id in pairs(itemList) do
        --print(id)
        local valid = true
        if restrictLevel then
            local requiredLevel = QuestieDB.QueryItemSingle(id, "requiredLevel")
            valid = (not requiredLevel) or (requiredLevel and requiredLevel <= playerLevel and requiredLevel >= playerLevel - 20)
        end
        if valid then
            local vendors = QuestieDB.QueryItemSingle(id, "vendors")
            if vendors then
                for _, vendorId in pairs(vendors) do
                    --print(vendorId)
                    local friendlyToFaction = QuestieDB.QueryNPCSingle(vendorId, "friendlyToFaction")
                    if (not friendlyToFaction) or friendlyToFaction == "AH" or friendlyToFaction == factionKey then
                        local flags = QuestieDB.QueryNPCSingle(vendorId, "npcFlags")
                        if bit.band(flags, QuestieDB.npcFlags.VENDOR) == QuestieDB.npcFlags.VENDOR then
                            tbl[vendorId] = true
                        end
                    end
                end
            end
        end
    end
    return tbl
end

function QuestieMenu:BuildCharacterTownsfolk()
    Questie.db.char.townsfolk = {}
    Questie.db.char.vendorList = {}

    for key, npcs in pairs(Questie.db.global.factionSpecificTownsfolk[playerFaction]) do
        Questie.db.char.townsfolk[key] = npcs
    end

    for key, npcs in pairs(Questie.db.global.classSpecificTownsfolk[playerClass]) do
        Questie.db.char.townsfolk[key] = npcs
    end

end
