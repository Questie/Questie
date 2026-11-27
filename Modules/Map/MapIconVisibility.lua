---@class MapIconVisibility
local MapIconVisibility = QuestieLoader:CreateModule("MapIconVisibility")

---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")

local coYield = coroutine.yield

-- this variable defines how many operations to run (batched at a time) before yielding for a frame.
local TICKS_PER_YIELD = 60

if Questie.IsHardcore then
    -- The addon timing restrictions from the Blizzard watchdog are much higher for HC servers.
    TICKS_PER_YIELD = 30
end

---@return boolean
function MapIconVisibility.IsWorldMapShown()
    return Questie.db.profile.enabled and Questie.db.profile.enableMapIcons
end

---@return boolean
function MapIconVisibility.IsMinimapShown()
    return Questie.db.profile.enabled and Questie.db.profile.enableMiniMapIcons
end

---Updates all quest icons to ensure they are correctly shown/hidden, e.g. after a focus change. Manual icons stay as they are.
---Icons of hidden quests already exist, so the quest log is not rebuilt; that would redraw the finishers of complete quests.
---@param showIcons boolean @ Whether to show or hide the icons
function MapIconVisibility.ToggleQuestNotes(showIcons)
    Questie.Debug(Questie.DEBUG_DEVELOP, "[MapIconVisibility.ToggleQuestNotes] showIcons:", showIcons)

    ThreadLib.ThreadInstant(function()
        if showIcons then
            MapIconVisibility.ShowQuestIcons()
        else
            MapIconVisibility.HideQuestIcons()
        end
    end)
end

---Hides or shows the icon according to ShouldBeHidden (evaluated once) and applies the quest's fade state.
---@param icon IconFrame
local function _ApplyIconVisibility(icon)
    if icon:ShouldBeHidden() then
        icon:FakeHide()
    else
        icon:FakeShow()
    end
    if icon.data.QuestData.FadeIcons and icon.data.Type ~= "complete" then
        icon:FadeOut()
    else
        icon:FadeIn()
    end
end

--- Shows all quest icons. Needs to be called from a coroutine.
function MapIconVisibility.ShowQuestIcons()
    assert(coroutine.running(), "ShowQuestIcons must be called from a coroutine")

    local trackerHiddenQuests = Questie.db.char.TrackerHiddenQuests
    local questCount = 0
    for questId, frameList in pairs(QuestieMap.questIdFrames) do
        if (not trackerHiddenQuests) or (not trackerHiddenQuests[questId]) then -- Skip quests which are completely hidden from the Tracker menu
            for _, frameName in pairs(frameList) do -- this may seem a bit expensive, but its actually really fast due to the order things are checked
                ---@type IconFrame
                local icon = _G[frameName];
                local objectiveString = tostring(questId) .. " " .. tostring(icon.data.ObjectiveIndex)
                if (not Questie.db.char.TrackerHiddenObjectives) or (not Questie.db.char.TrackerHiddenObjectives[objectiveString]) then
                    _ApplyIconVisibility(icon)
                end
            end
        end

        questCount = questCount + 1
        if questCount >= TICKS_PER_YIELD then
            questCount = 0
            coYield()
        end
    end
end

--- Hides all quest icons. Needs to be called from a coroutine
function MapIconVisibility.HideQuestIcons()
    assert(coroutine.running(), "HideQuestIcons must be called from a coroutine")

    local questCount = 0
    for _, frameList in pairs(QuestieMap.questIdFrames) do
        for _, frameName in pairs(frameList) do -- this may seem a bit expensive, but its actually really fast due to the order things are checked
            local icon = _G[frameName];
            _ApplyIconVisibility(icon)
        end

        questCount = questCount + 1
        if questCount >= TICKS_PER_YIELD then
            questCount = 0
            coYield()
        end
    end
end

-- Manual notes follow map visibility and exploration without quest-specific filters.
---@param icon IconFrame
---@return boolean
local function _ShouldShowManualIcon(icon)
    local profile = Questie.db.profile
    if (not profile.enabled) then
        return false
    end

    if profile.hideUnexploredMapIcons and icon.manualType ~= "any" and (not QuestieMap.utils.IsExplored(icon.UiMapID, icon.x, icon.y)) then
        return false
    end

    if icon.miniMapIcon then
        return profile.enableMiniMapIcons
    end
    return profile.enableMapIcons
end

function MapIconVisibility.ShowManualIcons()
    for _, townsfolk in pairs(QuestieMap.manualFrames) do
        for _, frameList in pairs(townsfolk) do
            for _, frameName in pairs(frameList) do
                local icon = _G[frameName];
                if icon ~= nil and icon.hidden and _ShouldShowManualIcon(icon) then
                    icon:FakeShow()
                end
            end
        end
    end
end

function MapIconVisibility.HideManualIcons()
    for _, townsfolk in pairs(QuestieMap.manualFrames) do
        for _, frameList in pairs(townsfolk) do
            for _, frameName in pairs(frameList) do
                local icon = _G[frameName];
                if icon ~= nil and (not icon.hidden) and (not _ShouldShowManualIcon(icon)) then
                    icon:FakeHide()
                end
            end
        end
    end
end

--- Re-applies the icon visibility from the profile to all existing quest and manual icons.
function MapIconVisibility.Refresh()
    ThreadLib.ThreadInstant(function()
        MapIconVisibility.ShowQuestIcons()
        MapIconVisibility.ShowManualIcons()
        MapIconVisibility.HideManualIcons()
    end)
end

--- Toggles the given surface. If Questie icons are disabled globally, Questie gets enabled and only the given surface is shown.
---@param surfaceKey "enableMapIcons"|"enableMiniMapIcons" @The profile key of the surface to toggle
---@param otherSurfaceKey "enableMapIcons"|"enableMiniMapIcons" @The profile key of the other surface
local function _Toggle(surfaceKey, otherSurfaceKey)
    local profile = Questie.db.profile

    if profile.enabled and profile[surfaceKey] then
        profile[surfaceKey] = false
    else
        if (not profile.enabled) then
            profile[otherSurfaceKey] = false
        end
        profile.enabled = true
        profile[surfaceKey] = true
    end

    MapIconVisibility.Refresh()
end

function MapIconVisibility.ToggleWorldMap()
    _Toggle("enableMapIcons", "enableMiniMapIcons")
end

function MapIconVisibility.ToggleMinimap()
    _Toggle("enableMiniMapIcons", "enableMapIcons")
end
