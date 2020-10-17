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
---@tyle QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")

local _townsfolk_texturemap = {
    ["Flight Master"] = "Interface\\Minimap\\tracking\\flightmaster",
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
                QuestieMap:ShowObject(id, icon, 1.2, "|cFFFFFFFF" .. QuestieLocale:GetUIString('Mailbox'), {}, true, key)
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
                    local id = ids[e]
                    if not _spawned[id] then
                        local friendly = QuestieDB.QueryNPCSingle(id, "friendlyToFaction")
                        if ((not friendly) or friendly == "AH" or (faction == "Alliance" and friendly == "A") or (faction == "Horde" and friendly == "H")) and not QuestieCorrections.questNPCBlacklist[id] then -- (QuestieLocale:GetUIStringNillable(tostring(key)) or key)
                            QuestieMap:ShowNPC(id, icon, 1.2, "|cFF00FF00" .. QuestieDB.QueryNPCSingle(id, "name") .. " |r|cFFFFFFFF(" .. (QuestieDB.QueryNPCSingle(id, "subName") or QuestieLocale:GetUIStringNillable(tostring(key)) or key) .. ")", {}--[[{key, ""}]], true, key, true)
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
        text = (QuestieLocale:GetUIStringNillable(tostring(key)) or key), 
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
        QuestieMenu.menu = LQuestie_Create_UIDropDownMenu("QuestieTownsfolkMenuFrame", UIParent)
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
        for key, v in pairs(Questie.db.global.professionTrainers) do
            local localizedKey = (QuestieLocale:GetUIStringNillable(tostring(key)) or key)
            profMenuData[localizedKey] = build(key)
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
        for key, v in pairs(Questie.db.char.vendorList) do
            local localizedKey = (QuestieLocale:GetUIStringNillable(tostring(key)) or key)
            vendorMenuData[localizedKey] = build(key)
            tinsert(vendorMenuSorted, localizedKey)
        end
        table.sort(vendorMenuSorted)
        for _, key in pairs(vendorMenuSorted) do
            tinsert(vendorMenu, vendorMenuData[key])
        end
        return vendorMenu
    end

    tinsert(menuTable, {text=QuestieLocale:GetUIString("Available Quest"), func = function()
        local value = not Questie.db.global.enableAvailable
        Questie.db.global.enableAvailable = value
        QuestieQuest:ToggleNotes(value)
        QuestieQuest:SmoothReset()
    end, icon=QuestieLib.AddonPath.."Icons\\available.blp", notCheckable=false, checked=Questie.db.global.enableAvailable, isNotRadio=true, keepShownOnClick=true})
    tinsert(menuTable, {text=QuestieLocale:GetUIString("Trivial Quest"), func = function()
        local value = not Questie.db.char.lowlevel
        Questie.db.char.lowlevel = value
        QuestieOptions.AvailableQuestRedraw()
    end, icon=QuestieLib.AddonPath.."Icons\\available_gray.blp", notCheckable=false, checked=Questie.db.char.lowlevel, isNotRadio=true, keepShownOnClick=true})
    tinsert(menuTable, {text=QuestieLocale:GetUIString("Objective"), func = function() 
        local value = not Questie.db.global.enableObjectives
        Questie.db.global.enableObjectives = value
        QuestieQuest:ToggleNotes(value)
        QuestieQuest:SmoothReset()
    end, icon=QuestieLib.AddonPath.."Icons\\event.blp", notCheckable=false, checked=Questie.db.global.enableObjectives, isNotRadio=true, keepShownOnClick=true})
    tinsert(menuTable, {text=QuestieLocale:GetUIString("Profession Trainer"), func = function() end, keepShownOnClick=true, hasArrow=true, menuList=buildProfessionMenu, notCheckable=true})
    tinsert(menuTable, {text=QuestieLocale:GetUIString("Vendor"), func = function() end, keepShownOnClick=true, hasArrow=true, menuList=buildVendorMenu, notCheckable=true})

    tinsert(menuTable, div)

    tinsert(menuTable, {text=QuestieLocale:GetUIString('JOURNEY_SEARCH_TAB'), func=function() QuestieOptions:HideFrame(); QuestieJourney.tabGroup:SelectTab("search"); QuestieJourney.ToggleJourneyWindow() end})
    tinsert(menuTable, {text=QuestieLocale:GetUIString("Questie Options"), func=function() QuestieOptions:OpenConfigWindow() end})
    tinsert(menuTable, {text=QuestieLocale:GetUIString('JOUNREY_TAB'), func=function() QuestieOptions:HideFrame(); QuestieJourney.tabGroup:SelectTab("journey"); QuestieJourney.ToggleJourneyWindow() end})

    if Questie.db.global.debugEnabled then -- add recompile db & reload buttons when debugging is enabled
        tinsert(menuTable, {text=QuestieLocale:GetUIString('RECOMPILE_DATABASE_BTN'), func=function() QuestieConfig.dbIsCompiled = false; ReloadUI() end})
        tinsert(menuTable, {text=QuestieLocale:GetUIString('Reload UI'), func=function() ReloadUI() end})
    end

    tinsert(menuTable, {text=QuestieLocale:GetUIString('TRACKER_CANCEL'), func=function() end})
    LQuestie_EasyMenu(menuTable, QuestieMenu.menu, "cursor", -80, 0, "MENU")
end

