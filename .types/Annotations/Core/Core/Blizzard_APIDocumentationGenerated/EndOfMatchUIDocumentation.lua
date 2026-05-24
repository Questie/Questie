---@meta _
C_EndOfMatchUI = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EndOfMatchUI.GetEndOfMatchDetails)
---@return MatchDetails? matchDetails
function C_EndOfMatchUI.GetEndOfMatchDetails() end

---@class MatchDetail
---@field type Enum.MatchDetailType
---@field value number

---@class MatchDetails
---@field matchType Enum.EndOfMatchType
---@field matchEnded boolean
---@field detailsList MatchDetail[]
