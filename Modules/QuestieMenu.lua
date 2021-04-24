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
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local LibDropDown = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

local _townsfolk_texturemap = {
    ["Flight Master"] = "Interface\\Minimap\\tracking\\flightmaster",
    ["Available Flights"] = QuestieLib.AddonPath.."Icons\\flight.blp",
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
        local class = select(2, UnitClass("player"))
        if class == "ROGUE" then
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
    [QuestieProfessions.professionKeys.SKINNING] = "Interface\\Icons\\inv_misc_pelt_wolf_01"
}

local _spawned = {} -- used to check if we have already spawned an icon for this npc

local function toggle(key, forceRemove) -- /run QuestieLoader:ImportModule("QuestieMap"):ShowNPC(525, nil, 1, "teaste", {}, true)
    local ids = Questie.db.global.townsfolk[key] or Questie.db.char.townsfolk[key] or Questie.db.global.professionTrainers[key] or Questie.db.char.vendorList[key]
    if not ids then 
        Questie:Debug(DEBUG_INFO, " Invalid townsfolk key " .. tostring(key))
        return
    end

    local icon = _townsfolk_texturemap[key] or ("Interface\\Minimap\\tracking\\" .. strlower(key))
    if key == "Mailbox" then -- the only obnject-type townsfolk
        if Questie.db.char.townsfolkConfig[key] and not forceRemove then
            for _, id in pairs(ids) do
                QuestieMap:ShowObject(id, icon, 1.2, Questie:Colorize(l10n('Mailbox'), "white"), {}, true, key)
            end
        else
            for _, id in pairs(ids) do
                QuestieMap:UnloadManualFrames(id, key)
            end
        end
    else
        if Questie.db.char.townsfolkConfig[key] and not forceRemove then
            local faction = UnitFactionGroup("Player")
            local timer = nil
            local e = 1
            local max = (#ids)+1
            timer = C_Timer.NewTicker(0.01, function() 
                local start = e
                while e < max and e-start < 32 do
                    local id = ids[e] -- Questie.db.char.townsfolkConfig[key]
                    if not _spawned[id] and (key ~= "Available Flights" or not (Questie.db.char._knownFlights or {})[id]) and (key ~= "Flight Master" or (not Questie.db.char.townsfolkConfig["Available Flights"]) or (Questie.db.char._knownFlights or {})[id]) then
                        local friendly = QuestieDB.QueryNPCSingle(id, "friendlyToFaction")
                        if ((not friendly) or friendly == "AH" or (faction == "Alliance" and friendly == "A") or (faction == "Horde" and friendly == "H")) and not QuestieCorrections.questNPCBlacklist[id] then
                            QuestieMap:ShowNPC(id, icon, 1.2, Questie:Colorize(QuestieDB.QueryNPCSingle(id, "name"), "white") .. " (" .. (QuestieDB.QueryNPCSingle(id, "subName") or l10n(tostring(key)) or key) .. ")", {}--[[{key, ""}]], true, key, true)
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
    if not Questie.db.char.townsfolkConfig then
        Questie.db.char.townsfolkConfig = {
            ["Flight Master"] = true,
            ["Mailbox"] = true
        }
    end
    for key in pairs(Questie.db.char.townsfolkConfig) do
        if forceRemove then
            toggle(key, forceRemove)
        end
        toggle(key)
    end

    local lookupMap = {}
    for k, v in pairs(l10n.zoneLookup[1]) do
        lookupMap[strtrim(v)] = k
    end
    for k, v in pairs(l10n.zoneLookup[3]) do
        lookupMap[strtrim(v)] = k
    end
    for k, v in pairs(l10n.zoneLookup[2]) do
        lookupMap[strtrim(v)] = k
    end

    local function langify(area, zone)
        if area and not lookupMap[area] then
            print("Area not found: " .. area)
        end

        if zone and not lookupMap[zone] then
            print("Zone not found: " .. area)
        end
        return area and (area .. ", " .. zone) or zone -- todo: replace enUS with local language here
    end

    local map = {
        [12577] = langify("Talrendis Point", "Azshara"),
        [3841] = langify("Auberdine", "Darkshore"),
        [6706] = langify("Nijel's Point", "Desolace"),
        [4321] = langify("Theramore Isle", "Dustwallow Marsh"),
        [12578] = langify("Talonbranch Glade", "Felwood"),
        [8019] = langify("Feathermoon Stronghold", "Feralas"),
        [4319] = langify("Thalanaar", "Feralas"),
        [10897] = langify(nil, "Moonglade"),
        [15177] = langify("Cenarion Hold", "Silithus"),
        [4407] = langify("Stonetalon Peak", "Stonetalon Mountains"),
        [7823] = langify("Gadgetzan", "Tanaris"),
        [3838] = langify("Rut'theran Village", "Teldrassil"),
        [11138] = langify("Everlook", "Winterspring"),
        [8609] = langify("Nethergarde Keep", "Blasted Lands"),
        [2299] = langify("Morgan's Vigil", "Burning Steppes"),
        [1573] = langify("Ironforge", "Dun Morogh"),
        [2409] = langify("Darkshire", "Duskwood"),
        [12617] = langify("Light's Hope Chapel", "Eastern Plaguelands"),
        [352] = langify("Stormwind City", "Elwynn Forest"),
        [2432] = langify("Southshore", "Hillsbrad Foothills"),
        [8018] = langify("Aerie Peak", "The Hinterlands"),
        [1572] = langify("Thelsamar", "Loch Modan"),
        [931] = langify("Lakeshire", "Redridge Mountains"),
        [2941] = langify("Thorium Point", "Searing Gorge"),
        [2859] = langify("Booty Bay", "Stranglethorn"),
        [12596] = langify("Chillwind Camp", "Western Plaguelands"),
        [523] = langify("Sentinel Hill", "Westfall"),
        [1571] = langify("Menethil Harbor", "Wetlands"),
        [11901] = langify("Zoram'gar Outpost", "Ashenvale"),
        [8610] = langify("Valormok", "Azshara"),
        [6726] = langify("Shadowprey Village", "Desolace"),
        [3310] = langify("Orgrimmar", "Durotar"),
        [11899] = langify("Brackenwall Village", "Dustwallow Marsh"),
        [11900] = langify("Bloodvenom Post", "Felwood"),
        [8020] = langify("Camp Mojache", "Feralas"),
        [12740] = langify(nil, "Moonglade"),
        [2995] = langify("Thunder Bluff", "Mulgore"),
        [15178] = langify("Cenarion Hold", "Silithus"),
        [4312] = langify("Sun Rock Retreat", "Stonetalon Mountains"),
        [7824] = langify("Gadgetzan", "Tanaris"),
        [3615] = langify("Crossroads", "The Barrens"),
        [10378] = langify("Camp Taurajo", "The Barrens"),
        [16227] = langify("Ratchet", "The Barrens"),
        [4317] = langify("Freewind Post", "Thousand Needles"),
        [10583] = langify("Marshal's Refuge", "Un'Goro Crater"),
        [11139] = langify("Everlook", "Winterspring"),
        [2861] = langify("Kargath", "Badlands"),
        [13177] = langify("Flame Crest", "Burning Steppes"),
        [12636] = langify("Light's Hope Chapel", "Eastern Plaguelands"),
        [2389] = langify("Tarren Mill", "Hillsbrad"),
        [4314] = langify("Revantusk Village", "The Hinterlands"),
        [3305] = langify("Thorium Point", "Searing Gorge"),
        [2226] = langify("The Sepulcher", "Silverpine Forest"),
        [1387] = langify("Grom'gol", "Stranglethorn"),
        [6026] = langify("Stonard", "Swamp of Sorrows"),
        [4551] = langify("Undercity", "Tirisfal"),
        [4267] = langify("Astranaar", "Ashenvale"),
        [2835] = langify("Refuge Point", "Arathi Highlands"),
        [12616] = langify("Splintertree Post", "Ashenvale"),
        [2851] = langify("Hammerfall", "Arathi")
    }

    local revMap = {}

    for k,v in pairs(map) do
        revMap[v] = k
    end

    local frame = CreateFrame("Frame")

    frame:SetScript("OnEvent", function(self, evt, arg)
        if evt == "CHAT_MSG_SYSTEM" and arg == ERR_NEWTAXIPATH then
            -- open flight map
            -- todo: make sure this is the right button
            GossipTitleButton1:GetScript("OnClick")(GossipTitleButton1)
        elseif evt == "TAXIMAP_OPENED" then
            print("TaximapOpened!")
            local npcIDs = Questie.db.char._knownFlights or {}
            for i=1,NumTaxiNodes() do
                local npc = revMap[TaxiNodeName(i)]
                if npc then
                    npcIDs[npc] = true
                    print("Matched " .. QuestieDB.QueryNPCSingle(npc, "name"))
                else
                    print("|cFFFF0000Error:|r|cFFFFFFFF Questie is unable to detect the flight path \"" .. TaxiNodeName(i) .. "\"!")
                end
            end
            Questie.db.char._knownFlights = npcIDs

            -- if changed then
            toggle("Flight Master", true)
            toggle("Available Flights", true)
            toggle("Flight Master")
            toggle("Available Flights")
            -- end


        end
    end)

    frame:RegisterEvent("CHAT_MSG_SYSTEM")
    frame:RegisterEvent("TAXIMAP_OPENED")

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
    tinsert(menuTable, {text= l10n("Profession Trainer"), func = function() end, keepShownOnClick=true, hasArrow=true, menuList={}, notCheckable=true})
    tinsert(menuTable, {text= l10n("Vendor"), func = function() end, keepShownOnClick=true, hasArrow=true, menuList={}, notCheckable=true})

    tinsert(menuTable, div)

    tinsert(menuTable, { text= l10n('Advanced Search'), func=function() QuestieOptions:HideFrame(); QuestieJourney.tabGroup:SelectTab("search"); QuestieJourney.ToggleJourneyWindow() end})
    tinsert(menuTable, { text= l10n("Questie Options"), func=function() QuestieOptions:OpenConfigWindow() end})
    tinsert(menuTable, { text= l10n('My Journey'), func=function() QuestieOptions:HideFrame(); QuestieJourney.tabGroup:SelectTab("journey"); QuestieJourney.ToggleJourneyWindow() end})

    if Questie.db.global.debugEnabled then -- add recompile db & reload buttons when debugging is enabled
        tinsert(menuTable, { text= l10n('Recompile Database'), func=function() QuestieConfig.dbIsCompiled = false; ReloadUI() end})
        tinsert(menuTable, { text= l10n('Reload UI'), func=function() ReloadUI() end})
    end

    tinsert(menuTable, {text= l10n('Cancel'), func=function() end})
    EasyMenu(menuTable, QuestieMenu.menu, "cursor", -80, 0, "MENU")
end

