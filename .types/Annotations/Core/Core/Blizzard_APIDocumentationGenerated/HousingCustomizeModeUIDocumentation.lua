---@meta _
C_HousingCustomizeMode = {}

---If a dyeable decor is selected, applies a specific dye color in a specific slot as a preview; See CommitDyesForSelectedDecor to actually save applied dye changes
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.ApplyDyeToSelectedDecor)
---@param dyeSlotID number
---@param dyeColorID? number
function C_HousingCustomizeMode.ApplyDyeToSelectedDecor(dyeSlotID, dyeColorID) end

---Attempt to apply a specific theme set (aka style) to all applicable room components in the current room
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.ApplyThemeToRoom)
---@param themeSetID number
function C_HousingCustomizeMode.ApplyThemeToRoom(themeSetID) end

---Attempt to apply a specific theme set (aka style) to the currently selected room component only
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.ApplyThemeToSelectedRoomComponent)
---@param themeSetID number
function C_HousingCustomizeMode.ApplyThemeToSelectedRoomComponent(themeSetID) end

---Attempt to apply a specific wallpaper (aka material/texture) to all applicable room components in the current room
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.ApplyWallpaperToAllWalls)
---@param roomComponentTextureRecID number
function C_HousingCustomizeMode.ApplyWallpaperToAllWalls(roomComponentTextureRecID) end

---Attempt to apply a specific wallpaper (aka material/texture) to the currently selected room component only
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.ApplyWallpaperToSelectedRoomComponent)
---@param roomComponentTextureRecID number
function C_HousingCustomizeMode.ApplyWallpaperToSelectedRoomComponent(roomComponentTextureRecID) end

---Cancels all in-progress editing of the selected target, which will reset any unapplied customization changes and deselect the active target
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.CancelActiveEditing)
function C_HousingCustomizeMode.CancelActiveEditing() end

---Clears all previewed dye changes on the selected decor; Does not clear any already saved dyes that were previously applied
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.ClearDyesForSelectedDecor)
function C_HousingCustomizeMode.ClearDyesForSelectedDecor() end

---Deselect the currently selected room component, if there is one
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.ClearTargetRoomComponent)
function C_HousingCustomizeMode.ClearTargetRoomComponent() end

---Attempt to save all previewed dye changes made to the selected decor
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.CommitDyesForSelectedDecor)
---@return boolean hasChanges
function C_HousingCustomizeMode.CommitDyesForSelectedDecor() end

---Returns info for the placed decor instance currently being hovered, if there is one
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.GetHoveredDecorInfo)
---@return HousingDecorInstanceInfo? info
function C_HousingCustomizeMode.GetHoveredDecorInfo() end

---Returns info for the room component currently being hovered, if there is one
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.GetHoveredRoomComponentInfo)
---@return HousingRoomComponentInstanceInfo? info
function C_HousingCustomizeMode.GetHoveredRoomComponentInfo() end

---If a dyeable decor instance is selected, returns how many dye slots would be cleared on applying all currently previewed dye changes
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.GetNumDyesToRemoveOnSelectedDecor)
---@return number numDyesToRemove
function C_HousingCustomizeMode.GetNumDyesToRemoveOnSelectedDecor() end

---If a dyeable decor instance is selected, returns how many dye items would be spent on applying all currently previewed dye changes
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.GetNumDyesToSpendOnSelectedDecor)
---@return number numDyesToSpend
function C_HousingCustomizeMode.GetNumDyesToSpendOnSelectedDecor() end

---If a dyeable decor instance is selected, returns info structs for each new/changed dye currently being previewed
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.GetPreviewDyesOnSelectedDecor)
---@return PreviewDyeSlotInfo[] previewDyes
function C_HousingCustomizeMode.GetPreviewDyesOnSelectedDecor() end

---Returns a list of ids for the dyes most recently applied by the player, if any
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.GetRecentlyUsedDyes)
---@return number[] recentDyes
function C_HousingCustomizeMode.GetRecentlyUsedDyes() end

---Returns a list of ids for the theme sets (aka styles) most recently applied by the player, if any
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.GetRecentlyUsedThemeSets)
---@return number[] recentThemeSets
function C_HousingCustomizeMode.GetRecentlyUsedThemeSets() end

---Returns a list of ids for the wallpapers most recently applied by the player, if any
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.GetRecentlyUsedWallpapers)
---@return number[] recentWallpapers
function C_HousingCustomizeMode.GetRecentlyUsedWallpapers() end

---Returns info for the decor instance that's currently selected, if there is one
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.GetSelectedDecorInfo)
---@return HousingDecorInstanceInfo? info
function C_HousingCustomizeMode.GetSelectedDecorInfo() end

---Returns info for the currently selected room component, if there is one
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.GetSelectedRoomComponentInfo)
---@return HousingRoomComponentInstanceInfo? info
function C_HousingCustomizeMode.GetSelectedRoomComponentInfo() end

---Returns the name of the specified theme set (aka style) if it exists
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.GetThemeSetInfo)
---@param themeSetID number
---@return string? name
function C_HousingCustomizeMode.GetThemeSetInfo(themeSetID) end

---Get all wallpapers (aka materials/textures) available for the selected room component type, if any
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.GetWallpapersForRoomComponentType)
---@param type Enum.HousingRoomComponentType
---@return RoomComponentWallpaper[] availableWallpapers
function C_HousingCustomizeMode.GetWallpapersForRoomComponentType(type) end

---Returns true if a decor instance is currently selected for customization
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.IsDecorSelected)
---@return boolean hasSelectedDecor
function C_HousingCustomizeMode.IsDecorSelected() end

---Returns true if the entry door of the house's exterior is currently being hovered
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.IsHouseExteriorDoorHovered)
---@return boolean isHouseExteriorDoorHovered
function C_HousingCustomizeMode.IsHouseExteriorDoorHovered() end

---Returns true if a placed decor instance is currently being hovered
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.IsHoveringDecor)
---@return boolean isHoveringDecor
function C_HousingCustomizeMode.IsHoveringDecor() end

---Returns true if a room component is currently being hovered
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.IsHoveringRoomComponent)
---@return boolean isHovering
function C_HousingCustomizeMode.IsHoveringRoomComponent() end

---Returns true if a room component is currently selected for customization
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.IsRoomComponentSelected)
---@return boolean hasSelectedComponent
function C_HousingCustomizeMode.IsRoomComponentSelected() end

---Check whether a specific room component supports a particular variant; What kind of id or enum 'variant' equates to is complicated, as it depends on the component type
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.RoomComponentSupportsVariant)
---@param componentID number
---@param variant number
---@return boolean variantSupported
function C_HousingCustomizeMode.RoomComponentSupportsVariant(componentID, variant) end

---Attempt to set a specific ceiling component, within a specific room, to a specific new ceiling type
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.SetRoomComponentCeilingType)
---@param roomGUID WOWGUID
---@param componentID number
---@param ceilingType Enum.HousingRoomComponentCeilingType
function C_HousingCustomizeMode.SetRoomComponentCeilingType(roomGUID, componentID, ceilingType) end

---Attempt to set a specific door component, within a specific room, to a specific new door type
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCustomizeMode.SetRoomComponentDoorType)
---@param roomGUID WOWGUID
---@param componentID number
---@param newDoortype Enum.HousingRoomComponentDoorType
function C_HousingCustomizeMode.SetRoomComponentDoorType(roomGUID, componentID, newDoortype) end

---@class HousingRoomComponentInstanceInfo
---@field roomGUID WOWGUID
---@field type Enum.HousingRoomComponentType
---@field componentID number
---@field canBeCustomized boolean
---@field currentThemeSet number?
---@field availableThemeSets number[]
---@field currentWallpaper number?
---@field currentRoomComponentTextureRecID number?
---@field ceilingType Enum.HousingRoomComponentCeilingType
---@field doorType Enum.HousingRoomComponentDoorType

---@class PreviewDyeSlotInfo
---@field dyeColorID number
---@field dyeSlotID number

---@class RoomComponentWallpaper
---@field name string
---@field roomComponentTextureRecID number
