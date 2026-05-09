---@meta _
---@class LibDBIcon-1.0
---@field loggedIn boolean
---@field callbackRegistered boolean
---@field objects table<string, LibDBIcon.button>
---@field radius integer
---@field isDraggingButton boolean
---@field tooltip Frame : GameTooltipTemplate
---@field notCreated table
---@field callbacks CallbackHandlerRegistry
local lib = {}

---@alias LibDBIcon.CallbackKey "'icon'"|"'iconCoords'"|"'iconR'"|"'iconG'"|"'iconB'"

---@param event any
---@param name string
---@param key LibDBIcon.CallbackKey
---@param value string|number
function lib:IconCallback(event, name, key, value)
end

---@param name string
---@param object LibDataBroker.DataObject
---@param db? LibDBIcon.button.DB
function lib:Register(name, object, db)
end

---@param name string
function lib:Lock(name)
end

---@param name string
function lib:Unlock(name)
end

---@param name string
function lib:Hide(name)
end

---@param name string
function lib:Show(name)
end

---@param name string
---@return boolean
function lib:IsRegistered(name)
end

---@param name string
---@param db LibDBIcon.button.DB
function lib:Refresh(name, db)
end

---@param name string
---@return LibDBIcon.button
function lib:GetMinimapButton(name)
end

---@return table<integer, LibDBIcon.button>
function lib:GetButtonList()
end

---Use to set the radius of the minimap
---@param radius integer
function lib:SetButtonRadius(radius)
end

---@param button string|LibDBIcon.button
---@param position integer
function lib:SetButtonToPosition(button, position)
end

---@param buttonName string
---@return boolean
function lib:IsButtonInCompartment(buttonName)
end

---@param buttonName string
---@param customIcon? string|number
function lib:AddButtonToCompartment(buttonName, customIcon)
end

---@param buttonName string
function lib:RemoveButtonFromCompartment(buttonName)
end

---@class LibDBIcon.button.DB
---@field hide boolean
---@field lock boolean
---@field minimapPos integer
local DB = {}

---@class LibDBIcon.dataObject
---@field OnClick function
---@field icon string|number
---@field iconR integer
---@field iconG integer
---@field iconB integer
local dataObject = {}

---@class LibDBIcon.button.icon : Texture
local icon = {}
icon.UpdateCoord = function() end

---@class LibDBIcon.button : Button
local button = {}
button.dataObject = dataObject
button.db = DB
button.icon = icon
button.isMouseDown = false
button.fadeOut = {} ---@type AnimationGroup