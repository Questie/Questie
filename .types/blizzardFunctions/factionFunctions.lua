---@meta

---[Documentation](https://wowpedia.fandom.com/wiki/API_GetNumFactions)
function GetNumFactions() end

---[Documentation](https://wowpedia.fandom.com/wiki/API_GetFactionInfo)
---@param index number
---@return string name @Name of the faction
---@return string description @Description as shown in the detail pane that appears when you click on the faction row
---@return number standingID @StandingId representing the current standing (eg. 4 for Neutral, 5 for Friendly).
---@return number barMin @Minimum reputation since beginning of Neutral to reach the current standing.
---@return number barMax @Maximum reputation since the beginning of Neutral before graduating to the next standing.
---@return number barValue @Total reputation earned with the faction versus 0 at the beginning of Neutral.
---@return boolean atWarWith @True if the player is at war with the faction
---@return boolean canToggleAtWar @True if the player can toggle the "At War" checkbox
---@return boolean isHeader @True if the faction is a header (collapsible group title)
---@return boolean isCollapsed @True if the faction is a header and is currently collapsed
---@return boolean hasRep @True if the faction is a header and has its own reputation (eg. The Tillers)
---@return boolean isWatched @True if the "Show as Experience Bar" checkbox for the faction is currently checked
---@return boolean isChild @True if the faction is a second-level header (eg. Sholazar Basin) or is the child of a second-level header (eg. The Oracles)
---@return number factionID @Unique FactionID.
---@return boolean hasBonusRepGain @True if the player has purchased a Grand Commendation to unlock bonus reputation gains with this faction
---@return boolean canSetInactive
function GetFactionInfo(index) end

---[Documentation](https://wowpedia.fandom.com/wiki/API_GetFactionInfoByID)
---@param factionID FactionId
---@return string name @Name of the faction
---@return string description @Description as shown in the detail pane that appears when you click on the faction row
---@return number standingID @StandingId representing the current standing (eg. 4 for Neutral, 5 for Friendly).
---@return number barMin @Minimum reputation since beginning of Neutral to reach the current standing.
---@return number barMax @Maximum reputation since the beginning of Neutral before graduating to the next standing.
---@return number barValue @Total reputation earned with the faction versus 0 at the beginning of Neutral.
---@return boolean atWarWith @True if the player is at war with the faction
---@return boolean canToggleAtWar @True if the player can toggle the "At War" checkbox
---@return boolean isHeader @True if the faction is a header (collapsible group title)
---@return boolean isCollapsed @True if the faction is a header and is currently collapsed
---@return boolean hasRep @True if the faction is a header and has its own reputation (eg. The Tillers)
---@return boolean isWatched @True if the "Show as Experience Bar" checkbox for the faction is currently checked
---@return boolean isChild @True if the faction is a second-level header (eg. Sholazar Basin) or is the child of a second-level header (eg. The Oracles)
---@return number factionID @Unique FactionID.
---@return boolean hasBonusRepGain @True if the player has purchased a Grand Commendation to unlock bonus reputation gains with this faction
---@return boolean canSetInactive
function GetFactionInfoByID(factionID) end