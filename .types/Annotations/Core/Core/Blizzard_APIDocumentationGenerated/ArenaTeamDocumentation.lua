---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_AcceptArenaTeam)
function AcceptArenaTeam() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ArenaTeamDisband)
---@param index number
function ArenaTeamDisband(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ArenaTeamInviteByName)
---@param index number
---@param target string
function ArenaTeamInviteByName(index, target) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ArenaTeamLeave)
---@param index number
function ArenaTeamLeave(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ArenaTeamSetLeaderByName)
---@param index number
---@param target string
function ArenaTeamSetLeaderByName(index, target) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ArenaTeamUninviteByName)
---@param index number
---@param target string
function ArenaTeamUninviteByName(index, target) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DeclineArenaTeam)
function DeclineArenaTeam() end
