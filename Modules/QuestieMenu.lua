---@class QuestieCorrections
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
    ["Spirit Healer"] = QuestieLib.AddonPath.."Icons\\grave.blp",
    ["Weapon Master"] = QuestieLib.AddonPath.."Icons\\slay.blp",
    ["Profession Trainer"] = "Interface\\Minimap\\tracking\\profession",

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

local function toggle(key) -- /run QuestieLoader:ImportModule("QuestieMap"):ShowNPC(525, nil, 1, "teaste", {}, true)
    local ids = Questie.db.global.townsfolk[key] or Questie.db.char.townsfolk[key] or Questie.db.global.professionTrainers[key]
    local icon = _townsfolk_texturemap[key] or ("Interface\\Minimap\\tracking\\" .. strlower(key))
    if key == "Mailbox" then -- the only obnject-type townsfolk
        if Questie.db.char.townsfolkConfig[key] then
            for _, id in pairs(ids) do
                QuestieMap:ShowObject(id, icon, 1.2, "|cFFFFFFFF" .. key, {}, true, key)
            end
        else
            for _, id in pairs(ids) do
                QuestieMap:UnloadManualFrames(id, key)
            end
        end
    else
        if Questie.db.char.townsfolkConfig[key] then
            local faction = UnitFactionGroup("Player")
            for _, id in pairs(ids) do
                local friendly = QuestieDB.QueryNPCSingle(id, "friendlyToFaction")
                if ((not friendly) or friendly == "AH" or (faction == "Alliance" and friendly == "A") or (faction == "Horde" and friendly == "H")) and not QuestieCorrections.questNPCBlacklist[id] then -- (QuestieLocale:GetUIStringNillable(tostring(key)) or key)
                    QuestieMap:ShowNPC(id, icon, 1.2, "|cFF00FF00" .. QuestieDB.QueryNPCSingle(id, "name") .. " |r|cFFFFFFFF(" .. (QuestieDB.QueryNPCSingle(id, "subName") or QuestieLocale:GetUIStringNillable(tostring(key)) or key) .. ")", {}--[[{key, ""}]], true, key)
                end
            end
        else
            for _, id in pairs(ids) do
                QuestieMap:UnloadManualFrames(id, key)
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

function QuestieMenu:OnLogin() -- toggle all icons 
    if not Questie.db.char.townsfolkConfig then
        Questie.db.char.townsfolkConfig = {}
    end
    for key in pairs(Questie.db.global.townsfolk) do
        toggle(key)
    end
    for key in pairs(Questie.db.char.townsfolk) do
        toggle(key)
    end
    for key in pairs(Questie.db.global.professionTrainers) do
        toggle(key)
    end
end

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

    local profMenu = {}
    for key, v in pairs(Questie.db.global.professionTrainers) do
        tinsert(profMenu, build(key))
    end

    tinsert(menuTable, {text=QuestieLocale:GetUIString("Available Quest"), func = function()
        local value = not Questie.db.global.enableAvailable
        Questie.db.global.enableAvailable = value
        QuestieQuest:ToggleNotes(value)
        QuestieQuest:SmoothReset()
    end, icon=QuestieLib.AddonPath.."Icons\\available.blp", notCheckable=false, checked=Questie.db.global.enableAvailable, isNotRadio=true, keepShownOnClick=true})
    tinsert(menuTable, {text=QuestieLocale:GetUIString("Objective"), func = function() 
        local value = not Questie.db.global.enableObjectives
        Questie.db.global.enableObjectives = value
        QuestieQuest:ToggleNotes(value)
        QuestieQuest:SmoothReset()
    end, icon=QuestieLib.AddonPath.."Icons\\event.blp", notCheckable=false, checked=Questie.db.global.enableObjectives, isNotRadio=true, keepShownOnClick=true})
    tinsert(menuTable, {text=QuestieLocale:GetUIString("Profession Trainer"), func = function() end, keepShownOnClick=true, hasArrow=true, menuList=profMenu, notCheckable=true})
    tinsert(menuTable, {text=QuestieLocale:GetUIString("Vendor"), func = function() end, keepShownOnClick=true, hasArrow=true, menuList={}, notCheckable=true})


    tinsert(menuTable, {text=QuestieLocale:GetUIString('JOURNEY_SEARCH_TAB'), func=function() QuestieJourney.private.lastOpenWindow = "search"; QuestieJourney.ToggleJourneyWindow() end})
    tinsert(menuTable, {text=QuestieLocale:GetUIString("Questie Options"), func=function() QuestieOptions:OpenConfigWindow() end})
    tinsert(menuTable, {text=QuestieLocale:GetUIString('JOUNREY_TAB'), func=function() QuestieJourney.private.lastOpenWindow = "journey"; QuestieJourney.ToggleJourneyWindow() end})

    tinsert(menuTable, {text=QuestieLocale:GetUIString('TRACKER_CANCEL'), func=function() end})
    LQuestie_EasyMenu(menuTable, QuestieMenu.menu, "cursor", -80, 0, "MENU")
end

