---@meta _

---@deprecated
---Deprecated by [C_SpecializationInfo.GetNumSpecializationsForClassID](https://warcraft.wiki.gg/wiki/API_C_SpecializationInfo.GetNumSpecializationsForClassID)
---@param classID number
---@return number specCount
function GetNumSpecializationsForClassID(classID) end

---Deprecated by [C_SpecializationInfo.GetSpecializationInfo](https://warcraft.wiki.gg/wiki/API_C_SpecializationInfo.GetSpecializationInfo)
---@param specializationIndex number
---@param isInspect? boolean Default = false
---@param isPet? boolean Default = false
---@param inspectTarget? string
---@param sex? number
---@param groupIndex? number
---@return number? specId Default = 0
---@return string? name
---@return string? description
---@return fileID? icon
---@return string? role
---@return number? primaryStat
---@return number? pointsSpent Default = 0
---@return string? background
---@return number? previewPointsSpent Default = 0
---@return boolean? isUnlocked Default = true
function GetSpecializationInfo(specializationIndex, isInspect, isPet, inspectTarget, sex, groupIndex) end

---Deprecated by [C_SpecializationInfo.GetSpecialization](https://warcraft.wiki.gg/wiki/API_C_SpecializationInfo.GetSpecialization)
---@param isInspect? boolean
---@param isPet? boolean
---@param specGroupIndex? number
---@return number specializationIndex
function GetSpecialization(isInspect, isPet, specGroupIndex) end

---Deprecated by [C_SpecializationInfo.GetActiveSpecGroup](https://warcraft.wiki.gg/wiki/API_C_SpecializationInfo.GetActiveSpecGroup)
---@param isInspect? boolean
---@param isPet? boolean
---@return number groupIndex
function GetActiveSpecGroup(isInspect, isPet) end

---Deprecated by [C_SpecializationInfo.GetSpecializationMasterySpells](https://warcraft.wiki.gg/wiki/API_C_SpecializationInfo.GetSpecializationMasterySpells)
---@param specializationIndex number
---@param isInspect? boolean
---@param isPet? boolean
---@return number masterySpell1
---@return number masterySpell2
function GetSpecializationMasterySpells(specializationIndex, isInspect, isPet) end

---Deprecated by [C_SpecializationInfo.GetTalentInfo](https://warcraft.wiki.gg/wiki/API_C_SpecializationInfo.GetTalentInfo)
---@param talentTier number
---@param talentColumn number 
---@param specGroupIndex number 
---@param isInspect? boolean
---@param target? string
---@return number talentID
---@return string name
---@return number icon
---@return boolean selected
---@return boolean available
---@return number spellID
---@return boolean isPVPTalentUnlocked
---@return number tier
---@return number column
---@return boolean known
---@return boolean isGrantedByAura;
function GetTalentInfo(talentTier, talentColumn, specGroupIndex, isInspect, target) end
