---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/ScriptObject_HousingFixturePointFrame)
---@class HousingFixturePointFrame
local HousingFixturePointFrame = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingFixturePointFrame_HasAttachedFixture)
---@return boolean hasAttachedFixture
function HousingFixturePointFrame:HasAttachedFixture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingFixturePointFrame_IsSelected)
---@return boolean isSelected
function HousingFixturePointFrame:IsSelected() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingFixturePointFrame_IsValid)
---@return boolean isValid
function HousingFixturePointFrame:IsValid() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingFixturePointFrame_Select)
function HousingFixturePointFrame:Select() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingFixturePointFrame_SetUpdateCallback)
---@param cb FixturePointUpdatedCallback
function HousingFixturePointFrame:SetUpdateCallback(cb) end

---@alias FixturePointUpdatedCallback FunctionContainer|fun()
