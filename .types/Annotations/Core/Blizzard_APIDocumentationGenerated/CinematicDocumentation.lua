---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicFinished)
---@param movieType Enum.CinematicType
---@param userCanceled? boolean Default = false
---@param didError? boolean Default = false
function CinematicFinished(movieType, userCanceled, didError) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicStarted)
---@param movieType Enum.CinematicType
---@param movieID number
---@param canCancel? boolean Default = true
function CinematicStarted(movieType, movieID, canCancel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_InCinematic)
---@return boolean inCinematic
function InCinematic() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MouseOverrideCinematicDisable)
---@param doOverride? boolean Default = false
function MouseOverrideCinematicDisable(doOverride) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_OpeningCinematic)
function OpeningCinematic() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StopCinematic)
function StopCinematic() end
