---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_MovieFrame)
---@class MovieFrame : Frame
local MovieFrame  = {}
---@class movieframe : MovieFrame
---@class MOVIEFRAME : MovieFrame

---@param scriptType ScriptMovieFrame
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return function handler
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_GetScript)
function MovieFrame:GetScript(scriptType, bindingType) end

---@param scriptType ScriptMovieFrame
---@return boolean hasScript
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HasScript)
function MovieFrame:HasScript(scriptType) end

---@param scriptType ScriptMovieFrame
---@param handler function
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return boolean success
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HookScript)
function MovieFrame:HookScript(scriptType, handler, bindingType) end

---@param scriptType ScriptMovieFrame
---@param handler function|nil
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_SetScript)
function MovieFrame:SetScript(scriptType, handler) end


---[Documentation](https://warcraft.wiki.gg/wiki/API_MovieFrame_EnableSubtitles)
---@param enable boolean
function MovieFrame:EnableSubtitles(enable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MovieFrame_StartMovie)
---@param movieID number
---@param looping? boolean Default = false
---@return boolean success
---@return number returnCode
function MovieFrame:StartMovie(movieID, looping) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MovieFrame_StartMovieByName)
---@param movieName string
---@param looping? boolean Default = false
---@param resolution? number Default = 0
---@return boolean success
---@return number returnCode
function MovieFrame:StartMovieByName(movieName, looping, resolution) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MovieFrame_StopMovie)
function MovieFrame:StopMovie() end
