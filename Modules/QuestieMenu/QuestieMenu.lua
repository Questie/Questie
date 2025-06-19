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
---@type Townsfolk
local Townsfolk = QuestieLoader:ImportModule("Townsfolk")

local LibDropDown = LibStub:GetLibrary("LibUIDropDownMenuQuestie-4.0")

local _, playerClass = UnitClass("player")

local tinsert = tinsert

local professionKeys = QuestieProfessions.professionKeys

local _townsfolk_texturemap = {
    ["Flight Master"] = "Interface\\Minimap\\tracking\\flightmaster",
    ["Meeting Stones"] = QuestieLib.AddonPath.."Icons\\mstone.blp",
    ["Class Trainer"] = "Interface\\Minimap\\tracking\\class",
    ["Stable Master"] = "Interface\\Minimap\\tracking\\stablemaster",
    ["Spirit Healer"] = "Interface\\raidframe\\raid-icon-rez",
    ["Weapon Master"] = QuestieLib.AddonPath.."Icons\\weaponmaster.blp",
    ["Mailbox"] = QuestieLib.AddonPath.."Icons\\mailbox.blp",
    ["Profession Trainer"] = "Interface\\Minimap\\tracking\\profession",
    ["Ammo"] = 132382,--select(10, GetItemInfo(2515)) -- sharp arrow
    ["Bags"] = 133634,--select(10, GetItemInfo(4496)) -- small brown pouch
    ["Potions"] = 134831,--select(10, GetItemInfo(929)) -- Healing Potion
    ["Trade Goods"] = 132912,--select(10, GetItemInfo(2321)) -- thread
    ["Drink"] = 134712,--select(10, GetItemInfo(8766)) -- morning glory dew
    ["Food"] = 133964,--select(10, GetItemInfo(4540)) -- bread
    ["Pet Food"] = 132165,--select(3, GetSpellInfo(6991)) -- feed pet
    ["Portal Trainer"] = "Interface\\Minimap\\vehicle-alliancemageportal",
    ["Barber"] = QuestieLib.AddonPath.."Icons\\barber.png",
    ["Arcane Reforger"] = QuestieLib.AddonPath.."Icons\\reforge.png",
    ["Transmogrifier"] = QuestieLib.AddonPath.."Icons\\transmogrify.png",
    ["Battle Pet Trainer"] = QuestieLib.AddonPath.."Icons\\petbattle.png",
    ["Reagents"] = (function()
        if playerClass == "ROGUE" then
            return "Interface\\Minimap\\tracking\\poisons"
        end
        return QuestieLib.AddonPath.."Icons\\reagents.blp"
    end)(),
    [professionKeys.FIRST_AID] = "Interface\\Icons\\spell_holy_sealofsacrifice",
    [professionKeys.BLACKSMITHING] = "Interface\\Icons\\trade_blacksmithing",
    [professionKeys.LEATHERWORKING] = "Interface\\Icons\\trade_leatherworking",
    [professionKeys.ALCHEMY] = "Interface\\Icons\\trade_alchemy",
    [professionKeys.HERBALISM] = "Interface\\Icons\\trade_herbalism",
    [professionKeys.COOKING] = "Interface\\Icons\\inv_misc_food_15",
    [professionKeys.MINING] = "Interface\\Icons\\trade_mining",
    [professionKeys.TAILORING] = "Interface\\Icons\\trade_tailoring",
    [professionKeys.ENGINEERING] = "Interface\\Icons\\trade_engineering",
    [professionKeys.ENCHANTING] = "Interface\\Icons\\trade_engraving",
    [professionKeys.FISHING] = "Interface\\Icons\\trade_fishing",
    [professionKeys.SKINNING] = "Interface\\Icons\\inv_misc_pelt_wolf_01",
    [professionKeys.JEWELCRAFTING] = "Interface\\Icons\\inv_misc_gem_01",
    [professionKeys.ARCHAEOLOGY] = "Interface\\Icons\\trade_archaeology",
    [professionKeys.INSCRIPTION] = "Interface\\Icons\\inv_inscription_tradeskill01",
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
                            local subName = QuestieDB.QueryNPCSingle(id, "subName") or l10n(tostring(key))
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
    Townsfolk:UpdatePlayerVendors()

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
    [professionKeys.ARCHAEOLOGY] = true,
    [professionKeys.FIRST_AID] = true,
    [professionKeys.COOKING] = true,
    [professionKeys.FISHING] = true
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
        AvailableQuests.ResetLevelRequirementCache()
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

    tinsert(menuTable, { text= l10n('Advanced Search'), func=function()
        QuestieOptions:HideFrame();
        QuestieJourney.tabGroup:SelectTab("search");
        QuestieJourney:ToggleJourneyWindow()
    end})

    tinsert(menuTable, { text= l10n('Quests by Zone'), func=function()
        QuestieOptions:HideFrame();
        QuestieJourney.tabGroup:SelectTab("zone");
        QuestieJourney:ToggleJourneyWindow()
    end})
    tinsert(menuTable, { text= l10n("Questie Options"), func=function()
        QuestieCombatQueue:Queue(function()
            QuestieOptions:ToggleConfigWindow()
        end)
    end})

    tinsert(menuTable, { text= l10n('My Journey'), func=function()
        QuestieCombatQueue:Queue(function()
            QuestieOptions:HideFrame();
            QuestieJourney.tabGroup:SelectTab("journey");
            QuestieJourney:ToggleJourneyWindow()
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

function QuestieMenu:Hide()
    LibDropDown:CloseDropDownMenus()    
end

function QuestieMenu.IsOpen() 
   return LibDropDown:getOpen()
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

return QuestieMenu
