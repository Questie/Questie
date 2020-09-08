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


local _townsfolk_texturemap = {
    ["Flight Master"] = "Interface\\Minimap\\tracking\\flightmaster",
    ["Class Trainer"] = "Interface\\Minimap\\tracking\\class",
    ["Stable Master"] = "Interface\\Minimap\\tracking\\stablemaster",
    ["Spirit Healer"] = QuestieLib.AddonPath.."Icons\\grave.blp",
    ["Profession Trainer"] = "Interface\\Minimap\\tracking\\profession",
}

local function toggle(key) -- /run QuestieLoader:ImportModule("QuestieMap"):ShowNPC(525, nil, 1, "teaste", {}, true)
    local ids = Questie.db.global.townsfolk[key] or Questie.db.char.townsfolk[key]
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
                if (not friendly) or friendly == "AH" or (faction == "Alliance" and friendly == "A") or (faction == "Horde" and friendly == "H") then
                    QuestieMap:ShowNPC(id, icon, 1.2, "|cFF00FF00" .. QuestieDB.QueryNPCSingle(id, "name") .. " |r|cFFFFFFFF(" .. key .. ")", {}--[[{key, ""}]], true, key)
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
        text = key, 
        func = function() Questie.db.char.townsfolkConfig[key] = not Questie.db.char.townsfolkConfig[key] toggle(key) end, 
        icon=icon, 
        notCheckable=false, 
        checked=Questie.db.char.townsfolkConfig[key], 
        isNotRadio=true, 
        keepShownOnClick=true
    }
end

function QuestieMenu:OnLogin() -- toggle all icons
    for key in pairs(Questie.db.global.townsfolk) do
        toggle(key)
    end
    for key in pairs(Questie.db.char.townsfolk) do
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
    tinsert(menuTable, {text="Available Quest", func = function() end, icon=QuestieLib.AddonPath.."Icons\\available.blp", notCheckable=false, checked=true, isNotRadio=true, keepShownOnClick=true})
    tinsert(menuTable, {text="Objective", func = function() end, icon=QuestieLib.AddonPath.."Icons\\event.blp", notCheckable=false, checked=true, isNotRadio=true, keepShownOnClick=true})

    tinsert(menuTable, {text="Questie Options", func=function() QuestieOptions:OpenConfigWindow() end})
    tinsert(menuTable, {text="My Journey", func=function() QuestieJourney.ToggleJourneyWindow() end})

    tinsert(menuTable, {text="Cancel", func=function() end})
    LQuestie_EasyMenu(menuTable, QuestieMenu.menu, "cursor", -80, 0, "MENU")
end

