---@meta _

Menu = {}

---[FrameXML](https://www.townlong-yak.com/framexml/go/Menu.GetManager)
---@return MenuManagerProxy
function Menu.GetManager() end

---[FrameXML](https://www.townlong-yak.com/framexml/go/Menu.CreateRootMenuDescription)
---@generic M: table
---@param menuMixin M
---@return RootMenuDescriptionProxy|M rootMenuDescription
function Menu.CreateRootMenuDescription(menuMixin) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/Menu.CreateMenuElementDescription)
---@return ElementMenuDescriptionProxy
function Menu.CreateMenuElementDescription() end

---[FrameXML](https://www.townlong-yak.com/framexml/go/Menu.PopulateDescription)
---@param menuGenerator fun(ownerRegion: Region, description: RootMenuDescriptionProxy, ...)
---@param ownerRegion Region
---@param description RootMenuDescriptionProxy
---@param ... any? # passed to the generator
function Menu.PopulateDescription(menuGenerator, ownerRegion, description, ...) end

---Can be used by addons to modify blizzard's menus in a taint-safe manner
---[FrameXML](https://www.townlong-yak.com/framexml/go/Menu.ModifyMenu)
---@param tag string
---@param callback fun(ownerRegion: Region, description: RootMenuDescriptionProxy, contextData: any?)
function Menu.ModifyMenu(tag, callback) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/Menu.GetOpenMenuTags)
---@return string[] tags
function Menu.GetOpenMenuTags() end

---[FrameXML](https://www.townlong-yak.com/framexml/go/Menu.PrintOpenMenuTags)
function Menu.PrintOpenMenuTags() end
