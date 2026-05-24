---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_ScriptRegion)
---@class AnimatableObject : Object
local AnimatableObject = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_AnimatableObject_CreateAnimationGroup)
---@param name? string
---@param templateName? string
---@return SimpleAnimGroup group
function AnimatableObject:CreateAnimationGroup(name, templateName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_AnimatableObject_GetAnimationGroups)
---@return SimpleAnimGroup ... scriptObject
function AnimatableObject:GetAnimationGroups() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_AnimatableObject_StopAnimating)
function AnimatableObject:StopAnimating() end
