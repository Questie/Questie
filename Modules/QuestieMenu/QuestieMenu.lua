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
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")

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
    ["Potions"] = 134831,--select(10, GetItemInfo(929)) -- Healing Potion
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
    [QuestieProfessions.professionKeys.INSCRIPTION] = "Interface\\Icons\\inv_inscription_tradeskill01",
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
        if Questie.db.profile.townsfolkConfig[key] and (not forceRemove) then
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
        if Questie.db.profile.townsfolkConfig[key] and (not forceRemove) then
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
                            local npcName = QuestieDB.QueryNPCSingle(id, "name") or ("Missing NPC name for " .. tostring(id))
                            local subName = l10n(QuestieDB.QueryNPCSingle(id, "subName") or tostring(key))
                            local npcTitle = Questie:Colorize(npcName, "white") .. " (" .. subName .. ")"
                            QuestieMap:ShowNPC(id, icon, 1.2, npcTitle, {}, true, key, true)
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
        func = function() Questie.db.profile.townsfolkConfig[key] = not Questie.db.profile.townsfolkConfig[key] toggle(key) end,
        icon=icon,
        notCheckable=false,
        checked=Questie.db.profile.townsfolkConfig[key],
        isNotRadio=true,
        keepShownOnClick=true
    }
end

local function buildLocalized(key, localizedText)
    local icon = _townsfolk_texturemap[key] or ("Interface\\Minimap\\tracking\\" .. strlower(key))

    return {
        text = localizedText,
        func = function() Questie.db.profile.townsfolkConfig[key] = not Questie.db.profile.townsfolkConfig[key] toggle(key) end,
        icon=icon,
        notCheckable=false,
        checked=Questie.db.profile.townsfolkConfig[key],
        isNotRadio=true,
        keepShownOnClick=true
    }
end

function QuestieMenu:OnLogin(forceRemove) -- toggle all icons
    QuestieMenu:UpdatePlayerVendors()

    if (not Questie.db.profile.townsfolkConfig) then
        Questie.db.profile.townsfolkConfig = {
            ["Flight Master"] = true,
            ["Mailbox"] = true,
            ["Meeting Stones"] = true
        }
    end
    for key in pairs(Questie.db.profile.townsfolkConfig) do
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

function QuestieMenu.buildProfessionMenu()
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

function QuestieMenu.buildVendorMenu()
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

function QuestieMenu.buildTownsfolkMenu()
    local townsfolkMenu = {}
    for key in pairs(Questie.db.global.townsfolk) do
        tinsert(townsfolkMenu, build(key))
    end
    for key in pairs(Questie.db.char.townsfolk) do
        tinsert(townsfolkMenu, build(key))
    end
    return townsfolkMenu
end

function QuestieMenu:Show(hideDelay)
    if not Questie.db.profile.townsfolkConfig then
        Questie.db.profile.townsfolkConfig = {}
    end
    if not QuestieMenu.menu then
        QuestieMenu.menu = LibDropDown:Create_UIDropDownMenu("QuestieTownsfolkMenuFrame", UIParent)
    end
    local menuTable = QuestieMenu.buildTownsfolkMenu()
    tinsert(menuTable, { text= l10n("Available Quest"), func = function()
        local value = not Questie.db.profile.enableAvailable
        Questie.db.profile.enableAvailable = value
        QuestieQuest:ToggleNotes(value)
        QuestieQuest:SmoothReset()
    end, icon=QuestieLib.AddonPath.."Icons\\available.blp", notCheckable=false, checked=Questie.db.profile.enableAvailable, isNotRadio=true, keepShownOnClick=true})
    tinsert(menuTable, { text= l10n("Trivial Quest"), func = function()
        local value = Questie.db.profile.lowLevelStyle == Questie.LOWLEVEL_ALL
        if value then
            Questie.db.profile.lowLevelStyle = Questie.LOWLEVEL_NONE
        else
            Questie.db.profile.lowLevelStyle = Questie.LOWLEVEL_ALL
        end
        AvailableQuests.CalculateAndDrawAll()
    end, icon=QuestieLib.AddonPath.."Icons\\available_gray.blp", notCheckable=false, checked=Questie.db.profile.lowLevelStyle==Questie.LOWLEVEL_ALL, isNotRadio=true, keepShownOnClick=true})
    tinsert(menuTable, { text= l10n("Objective"), func = function()
        local value = not Questie.db.profile.enableObjectives
        Questie.db.profile.enableObjectives = value
        QuestieQuest:ToggleNotes(value)
        QuestieQuest:SmoothReset()
    end, icon=QuestieLib.AddonPath.."Icons\\event.blp", notCheckable=false, checked=Questie.db.profile.enableObjectives, isNotRadio=true, keepShownOnClick=true})
    tinsert(menuTable, {text= l10n("Profession Trainer"), func = function() end, keepShownOnClick=true, hasArrow=true, menuList=QuestieMenu.buildProfessionMenu(), notCheckable=true})
    tinsert(menuTable, {text= l10n("Vendor"), func = function() end, keepShownOnClick=true, hasArrow=true, menuList=QuestieMenu.buildVendorMenu(), notCheckable=true})

    tinsert(menuTable, div)

    tinsert(menuTable, { text= l10n('Advanced Search'), func=function() QuestieOptions:HideFrame(); QuestieJourney.tabGroup:SelectTab("search"); QuestieJourney.ToggleJourneyWindow() end})
    tinsert(menuTable, { text= l10n("Questie Options"), func=function()
        QuestieCombatQueue:Queue(function()
            QuestieOptions:OpenConfigWindow()
        end)
    end})

    tinsert(menuTable, { text= l10n('My Journey'), func=function()
        QuestieCombatQueue:Queue(function()
            QuestieOptions:HideFrame();
            QuestieJourney.tabGroup:SelectTab("journey");
            QuestieJourney.ToggleJourneyWindow()
        end)
    end})

    if Questie.db.profile.debugEnabled then -- add recompile db & reload buttons when debugging is enabled
        tinsert(menuTable, { text= l10n('Recompile Database'), func=function()
            if Questie.IsSoD then
                Questie.db.global.sod.dbIsCompiled = false
            else
                Questie.db.global.dbIsCompiled = false
            end
            ReloadUI()
        end})
        tinsert(menuTable, { text= l10n('Reload UI'), func=function() ReloadUI() end})
    end

    tinsert(menuTable, {text= l10n('Cancel'), func=function() end})
    LibDropDown:EasyMenu(menuTable, QuestieMenu.menu, "cursor", -80, -15, "MENU", hideDelay or 2)
end

function QuestieMenu:ShowTownsfolk(hideDelay)
    if not Questie.db.profile.townsfolkConfig then
        Questie.db.profile.townsfolkConfig = {}
    end
    if not QuestieMenu.menuTowns then
        QuestieMenu.menuTowns = LibDropDown:Create_UIDropDownMenu("QuestieTownsfolkMenuFrameTownsfolk", UIParent)
    end
    local menuTable = QuestieMenu.buildTownsfolkMenu()
    tinsert(menuTable, {text= l10n('Cancel'), func=function() end})
    LibDropDown:EasyMenu(menuTable, QuestieMenu.menuTowns, "cursor", -80, -15, "MENU", hideDelay)
end

function QuestieMenu:ShowProfessions(hideDelay)
    if not Questie.db.profile.townsfolkConfig then
        Questie.db.profile.townsfolkConfig = {}
    end
    if not QuestieMenu.menuProfs then
        QuestieMenu.menuProfs = LibDropDown:Create_UIDropDownMenu("QuestieTownsfolkMenuFrameProfs", UIParent)
    end
    local menuTable = QuestieMenu.buildProfessionMenu()
    tinsert(menuTable, {text= l10n('Cancel'), func=function() end})
    LibDropDown:EasyMenu(menuTable, QuestieMenu.menuProfs, "cursor", -75, -15, "MENU", hideDelay)
end

function QuestieMenu:ShowVendors(hideDelay)
    if not Questie.db.profile.townsfolkConfig then
        Questie.db.profile.townsfolkConfig = {}
    end
    if not QuestieMenu.menuVendors then
        QuestieMenu.menuVendors = LibDropDown:Create_UIDropDownMenu("QuestieTownsfolkMenuFrameVendors", UIParent)
    end
    local menuTable = QuestieMenu.buildVendorMenu()
    tinsert(menuTable, {text= l10n('Cancel'), func=function() end})
    LibDropDown:EasyMenu(menuTable, QuestieMenu.menuVendors, "cursor", -60, -15, "MENU", hideDelay)
end

local function _reformatVendors(lst, existingTable)
    local newList = existingTable or {}
    for k in pairs(lst) do
        tinsert(newList, k)
    end
    return newList
end

local sub, bitband, strlen = string.sub, bit.band, string.len

---Fetches townfolk of a specific mask
---@param mask NpcFlags
---@param requireSubname boolean?
---@return NpcId[]
function QuestieMenu:PopulateTownsfolkType(mask, requireSubname) -- populate the table with all npc ids based on the given bitmask
    local tbl = {}
    for id, data in pairs(QuestieDB.npcData) do
        local flags = data[QuestieDB.npcKeys.npcFlags]
        if flags and bitband(flags, mask) == mask then
            local name = data[QuestieDB.npcKeys.name]
            local subName = data[QuestieDB.npcKeys.subName]
            if name and sub(name, 1, 5) ~= "[DND]" then
                if (not requireSubname) or (subName and string.len(subName) > 1) then
                    tinsert(tbl, id)
                end
            end
        end
    end
    return tbl
end

---Uses a table to fetch multiple townfolk types at the same time.
---@param folkTypes table<string, {mask: NpcFlags|integer, requireSubname: boolean, data: NpcId[]}>
function QuestieMenu:PopulateTownsfolkTypes(folkTypes) -- populate the table with all npc ids based on the given bitmask
    local count = 0
    for id, npcData in pairs(QuestieDB.npcData) do
        local flags = npcData[QuestieDB.npcKeys.npcFlags]
        for name, folkType in pairs(folkTypes) do
            if flags and bitband(flags, folkType.mask) == folkType.mask then
                local npcName = npcData[QuestieDB.npcKeys.name]
                local subName = npcData[QuestieDB.npcKeys.subName]
                if npcName and sub(npcName, 1, 5) ~= "[DND]" then
                    if (not folkType.requireSubname) or (subName and strlen(subName) > 1) then
                        folkType.data[#folkType.data+1] = id
                    end
                end
            end
        end
        if count > 700 then -- 700 seems like a good number
            count = 0
            coroutine.yield()
        end
        count = count + 1
    end
    return folkTypes
end


---Initialization for townfolk
function QuestieMenu:PopulateTownsfolk()

    --? This datastructure is used in PopulateTownsfolkTypes to fetch multiple townfolk data in the same npc loop cycle
    ---@type table<string, {mask: NpcFlags|integer, requireSubname: boolean, data: NpcId[]}>
    local townsfolkData = {
        ["Repair"] = {
            mask = QuestieDB.npcFlags.REPAIR,
            requireSubname = true,
            data = {}
        },
        ["Auctioneer"] = {
            mask = QuestieDB.npcFlags.AUCTIONEER,
            requireSubname = false,
            data = {}
        },
        ["Banker"] = {
            mask = QuestieDB.npcFlags.BANKER,
            requireSubname = true,
            data = {}
        },
        ["Battlemaster"] = {
            mask = QuestieDB.npcFlags.BATTLEMASTER,
            requireSubname = true,
            data = {}
        },
        ["Flight Master"] = {
            mask = QuestieDB.npcFlags.FLIGHT_MASTER,
            requireSubname = false,
            data = {}
        },
        ["Innkeeper"] = {
            mask = QuestieDB.npcFlags.INNKEEPER,
            requireSubname = true,
            data = {}
        },
        ["Stable Master"] = { -- Used further down by hunters.
            mask = QuestieDB.npcFlags.STABLEMASTER,
            requireSubname = false,
            data = {}
        },
        ["Spirit Healer"] = {-- Used further down
            mask = QuestieDB.npcFlags.SPIRIT_HEALER,
            requireSubname = false,
            data = {}
        }
    }
    QuestieMenu:PopulateTownsfolkTypes(townsfolkData)

    local townfolk = {
        ["Repair"] = townsfolkData["Repair"].data,
        ["Auctioneer"] = townsfolkData["Auctioneer"].data,
        ["Banker"] = townsfolkData["Banker"].data,
        ["Battlemaster"] = townsfolkData["Battlemaster"].data,
        ["Flight Master"] = townsfolkData["Flight Master"].data,
        ["Innkeeper"] = townsfolkData["Innkeeper"].data,
        ["Weapon Master"] = {}, -- populated below
    }

    ---@type table<ProfessionEnum, NpcId[]>
    local professionTrainers = {
        [QuestieProfessions.professionKeys.FIRST_AID] = {},
        [QuestieProfessions.professionKeys.BLACKSMITHING] = {},
        [QuestieProfessions.professionKeys.LEATHERWORKING] = {},
        [QuestieProfessions.professionKeys.ALCHEMY] = {},
        [QuestieProfessions.professionKeys.HERBALISM] = {},
        [QuestieProfessions.professionKeys.COOKING] = {
            19186, -- Kylene <Barmaid> (this is an edge case)
        },
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

    if Questie.IsWotlk then
        professionTrainers[QuestieProfessions.professionKeys.INSCRIPTION] = {}
    end

    local count = 0
    local validProfessionTrainers = QuestieMenu.GetProfessionTrainers()
    for i=1, #validProfessionTrainers do
        local id = validProfessionTrainers[i]
        if QuestieDB.npcData[id] then
            local subName = QuestieDB.npcData[id][QuestieDB.npcKeys.subName]
            if subName then
                if townfolk[subName] then -- weapon master,
                    tinsert(townfolk[subName], id)
                else
                    for k, professionId in pairs(QuestieProfessions.professionTable) do
                        if string.match(subName, k) then
                            tinsert(professionTrainers[professionId], id)
                        end
                    end
                end
            end
        end

        if count > 10 then -- Yield every 10 iterations, 10 is just a madeup number, is pretty fast.
            count = 0
            coroutine.yield()
        end
        count = count + 1
    end

    -- Fix NPC Gubber Blump (10216) can train fishing profession
    tinsert(professionTrainers[QuestieProfessions.professionKeys.FISHING], 10216)
    -- Fix NPC Aresella (18991) can train first aid profession
    if Questie.IsTBC or Questie.IsWotlk then
        tinsert(professionTrainers[QuestieProfessions.professionKeys.FIRST_AID], 18991)
    end

    if Questie.IsClassic then
        -- Vendors selling "Expert First Aid - Under Wraps"
        tinsert(professionTrainers[QuestieProfessions.professionKeys.FIRST_AID], 2805)
        tinsert(professionTrainers[QuestieProfessions.professionKeys.FIRST_AID], 13476)
    end

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

        townfolk["Meeting Stones"] = {}
        for _, id in pairs(meetingStones) do
            tinsert(townfolk["Meeting Stones"], id)
        end
    end

    -- todo: specialized trainer types (leatherworkers, engineers, etc)

    local classSpecificTownsfolk = {}
    local factionSpecificTownsfolk = {["Horde"] = {}, ["Alliance"] = {}}

    local classTrainers = QuestieMenu.GetClassTrainers()
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
        classSpecificTownsfolk[class] = {}
        classSpecificTownsfolk[class]["Class Trainer"] = newTrainers
    end

    -- These are filtered later, when the player class does not match
    classSpecificTownsfolk["HUNTER"]["Stable Master"] = townsfolkData["Stable Master"].data
    classSpecificTownsfolk["MAGE"]["Portal Trainer"] = {4165,2485,2489,5958,5957,2492,16654,16755,19340,20791,27703,27705}

    factionSpecificTownsfolk["Horde"]["Spirit Healer"]  = townsfolkData["Spirit Healer"].data
    factionSpecificTownsfolk["Alliance"]["Spirit Healer"]  = townsfolkData["Spirit Healer"].data

    factionSpecificTownsfolk["Horde"]["Mailbox"] = {}
    factionSpecificTownsfolk["Alliance"]["Mailbox"] = {}

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
                tinsert(factionSpecificTownsfolk["Horde"]["Mailbox"], id)
                tinsert(factionSpecificTownsfolk["Alliance"]["Mailbox"], id)
            elseif QuestieDB.factionTemplate[factionID] and bitband(QuestieDB.factionTemplate[factionID], 12) == 0 and bitband(QuestieDB.factionTemplate[factionID], 10) == 0 then
                tinsert(factionSpecificTownsfolk["Horde"]["Mailbox"], id)
                tinsert(factionSpecificTownsfolk["Alliance"]["Mailbox"], id)
            elseif QuestieDB.factionTemplate[factionID] and bitband(QuestieDB.factionTemplate[factionID], 12) == 0 then
                tinsert(factionSpecificTownsfolk["Horde"]["Mailbox"], id)
            elseif QuestieDB.factionTemplate[factionID] and bitband(QuestieDB.factionTemplate[factionID], 10) == 0 then
                tinsert(factionSpecificTownsfolk["Alliance"]["Mailbox"], id)
            else
                tinsert(factionSpecificTownsfolk["Horde"]["Mailbox"], id)
                tinsert(factionSpecificTownsfolk["Alliance"]["Mailbox"], id)
            end
        else
            Questie:Debug(Questie.DEBUG_DEVELOP, "Missing mailbox:", tostring(id))
        end
    end

    local petFoodVendorTypes = {["Meat"] = {},["Fish"]={},["Cheese"]={},["Bread"]={},["Fungus"]={},["Fruit"]={},["Raw Meat"]={},["Raw Fish"]={}}
    local petFoodIndexes = {"Meat","Fish","Cheese","Bread","Fungus","Fruit","Raw Meat","Raw Fish"}

    count = 0
    for id, data in pairs(QuestieDB.itemData) do
        local foodType = data[QuestieDB.itemKeys.foodType]
        if foodType then
            tinsert(petFoodVendorTypes[petFoodIndexes[foodType]], id)
        end
        if count > 300 then -- Yield every 300 iterations, 300 is just a madeup number, is pretty fast.
            count = 0
            coroutine.yield()
        end
        count = count + 1
    end

    coroutine.yield()

    --- Set the globals
    Questie.db.global.townsfolk = townfolk
    Questie.db.global.townsfolkNeedsUpdatedGlobalVendors = true

    Questie.db.global.professionTrainers = professionTrainers
    Questie.db.global.classSpecificTownsfolk = classSpecificTownsfolk
    Questie.db.global.factionSpecificTownsfolk = factionSpecificTownsfolk
    Questie.db.global.petFoodVendorTypes = petFoodVendorTypes
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
        ["ROGUE"] = Questie.IsWotlk and {2892} -- All poison vendors sell all ranks of poison, so Rank 1 of one poison is enough here
            or {5140,2928,8924,5173,2930,8923},
        ["DRUID"] = {17034,17026,17035,17021,17038,17036,17037}
    }
    reagents = reagents[playerClass]
    if Questie.IsSoD then
        table.insert(reagents, 212160) -- In SoD the Chronoboon Displacer is sold by reagent vendors
    end

    -- populate vendor IDs from db
    if #reagents > 0 then
        Questie.db.char.vendorList["Reagents"] = _reformatVendors(QuestieMenu:PopulateVendors(reagents))
    end
    Questie.db.char.vendorList["Trade Goods"] = _reformatVendors(QuestieMenu:PopulateVendors({ -- item ids from wowhead for trade goods   (temporarily disabled)
        14256,12810,13463,8845,8846,4234,3713,8170,14341,4389,3357,2453,13464,
        3355,3356,3358,4371,4304,5060,2319,18256,8925,3857,10940,2321,785,4404,2692,
        2605,3372,2320,6217,2449,4399,4364,10938,18567,4382,4289,765,3466,3371,2447,2880,
        2928,4361,10647,10648,4291,4357,8924,8343,4363,2678,5173,4400,2930,4342,2325,4340,
        6261,8923,2324,2604,6260,4378,10290,17194,4341
    }))
    Questie.db.char.vendorList["Bags"] = _reformatVendors(QuestieMenu:PopulateVendors({4496, 4497, 4498, 4499, (Questie.IsTBC or Questie.IsWotlk) and 30744 or nil}))
    Questie.db.char.vendorList["Potions"] = _reformatVendors(QuestieMenu:PopulateVendors({
        118, 858, 929, 1710, 3928, 13446, 18839, (Questie.IsTBC or Questie.IsWotlk) and 22829 or nil, (Questie.IsTBC or Questie.IsWotlk) and 32947 or nil, (Questie.IsWotlk) and 33447 or nil, -- Healing Potions
        2455, 3385, 3827, 6149, 13443, 13444, 18841, (Questie.IsTBC or Questie.IsWotlk) and 22832 or nil, (Questie.IsTBC or Questie.IsWotlk) and 32948 or nil, (Questie.IsWotlk) and 33448 or nil, -- Mana Potions
    }))
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
    -- Create a cache to minimize db calls
    local factionCache = {}
    local flagCache = {}

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
                for i=1, #vendors do
                    local vendorId = vendors[i]
                    --print(vendorId)
                    local friendlyToFaction = factionCache[vendorId] or QuestieDB.QueryNPCSingle(vendorId, "friendlyToFaction")
                    if not factionCache[vendorId] then
                        factionCache[vendorId] = friendlyToFaction
                    end
                    if (not friendlyToFaction) or friendlyToFaction == "AH" or friendlyToFaction == factionKey then
                        local flags = flagCache[vendorId] or QuestieDB.QueryNPCSingle(vendorId, "npcFlags")
                        if not flagCache[vendorId] then
                            flagCache[vendorId] = flags
                        end
                        if bitband(flags, QuestieDB.npcFlags.VENDOR) == QuestieDB.npcFlags.VENDOR then
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
    Questie.db.char.townsfolkClass = UnitClass("player")

    for key, npcs in pairs(Questie.db.global.factionSpecificTownsfolk[playerFaction]) do
        Questie.db.char.townsfolk[key] = npcs
    end

    for key, npcs in pairs(Questie.db.global.classSpecificTownsfolk[playerClass]) do
        Questie.db.char.townsfolk[key] = npcs
    end

end
