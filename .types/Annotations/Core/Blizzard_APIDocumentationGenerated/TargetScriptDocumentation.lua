---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_AssistUnit)
---@param name? string Default = 
---@param exactMatch? boolean Default = false
function AssistUnit(name, exactMatch) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_AttackTarget)
function AttackTarget() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ClearFocus)
function ClearFocus() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ClearTarget)
---@return boolean willMakeChange
function ClearTarget() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FocusUnit)
---@param name? string Default = 
function FocusUnit(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsTargetLoose)
---@return boolean isTargetLoose
function IsTargetLoose() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetDirectionEnemy)
---@param facing number
---@param coneAngle? number
function TargetDirectionEnemy(facing, coneAngle) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetDirectionFinished)
function TargetDirectionFinished() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetDirectionFriend)
---@param facing number
---@param coneAngle? number
function TargetDirectionFriend(facing, coneAngle) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetLastEnemy)
function TargetLastEnemy() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetLastFriend)
function TargetLastFriend() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetLastTarget)
function TargetLastTarget() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetNearest)
---@param reverse? boolean Default = false
function TargetNearest(reverse) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetNearestEnemy)
---@param reverse? boolean Default = false
function TargetNearestEnemy(reverse) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetNearestEnemyPlayer)
---@param reverse? boolean Default = false
function TargetNearestEnemyPlayer(reverse) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetNearestFriend)
---@param reverse? boolean Default = false
function TargetNearestFriend(reverse) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetNearestFriendPlayer)
---@param reverse? boolean Default = false
function TargetNearestFriendPlayer(reverse) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetNearestPartyMember)
---@param reverse? boolean Default = false
function TargetNearestPartyMember(reverse) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetNearestRaidMember)
---@param reverse? boolean Default = false
function TargetNearestRaidMember(reverse) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetPriorityHighlightEnd)
function TargetPriorityHighlightEnd() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetPriorityHighlightStart)
---@param useStartDelay? boolean Default = false
function TargetPriorityHighlightStart(useStartDelay) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetToggle)
function TargetToggle() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetUnit)
---@param name? string Default = 
---@param exactMatch? boolean Default = false
function TargetUnit(name, exactMatch) end
