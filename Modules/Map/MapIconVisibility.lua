---@class MapIconVisibility
local MapIconVisibility = QuestieLoader:CreateModule("MapIconVisibility")

---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")

---@return boolean
function MapIconVisibility.IsWorldMapShown()
    return Questie.db.profile.enabled and Questie.db.profile.enableMapIcons
end

---@return boolean
function MapIconVisibility.IsMinimapShown()
    return Questie.db.profile.enabled and Questie.db.profile.enableMiniMapIcons
end

--- Re-applies the icon visibility from the profile to all existing quest and manual icons.
function MapIconVisibility.Refresh()
    ThreadLib.ThreadInstant(function()
        QuestieQuest:ShowQuestIcons()
        QuestieQuest.private:ShowManualIcons()
        QuestieQuest.private:HideManualIcons()
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
