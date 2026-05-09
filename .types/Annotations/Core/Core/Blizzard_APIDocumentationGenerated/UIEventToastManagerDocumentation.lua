---@meta _
C_EventToastManager = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EventToastManager.GetLevelUpDisplayToastsFromLevel)
---@param level number
---@return EventToastInfo[] toastInfo
function C_EventToastManager.GetLevelUpDisplayToastsFromLevel(level) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EventToastManager.GetNextToastToDisplay)
---@return EventToastInfo toastInfo
function C_EventToastManager.GetNextToastToDisplay() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EventToastManager.RemoveCurrentToast)
function C_EventToastManager.RemoveCurrentToast() end

---@class EventToastInfo
---@field eventToastID number
---@field title string
---@field subtitle string
---@field instructionText string
---@field iconFileID fileID
---@field subIcon textureAtlas?
---@field link string
---@field qualityString string?
---@field quality number?
---@field eventType Enum.EventToastEventType
---@field displayType Enum.EventToastDisplayType
---@field uiTextureKit textureKit
---@field sortOrder number
---@field time number?
---@field uiWidgetSetID number?
---@field extraUiWidgetSetID number?
---@field titleTooltip string?
---@field subtitleTooltip string?
---@field titleTooltipUiWidgetSetID number?
---@field subtitleTooltipUiWidgetSetID number?
---@field hideDefaultAtlas boolean?
---@field showSoundKitID number?
---@field hideSoundKitID number?
---@field colorTint colorRGB?
---@field flags number
