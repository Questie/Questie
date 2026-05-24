---@meta _
C_Spell = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.CancelSpellByID)
---@param spellID number
function C_Spell.CancelSpellByID(spellID) end

---Returns true if the spell exists, regardless of whether the player has learned it
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.DoesSpellExist)
---@param spellIdentifier SpellIdentifier
---@return boolean spellExists
function C_Spell.DoesSpellExist(spellIdentifier) end

---Used in conjunction with SpellRangeCheckUpdate to inform the UI when a spell goes in or out of range with the current target.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.EnableSpellRangeCheck)
---@param spellIdentifier SpellIdentifier
---@param enable boolean
function C_Spell.EnableSpellRangeCheck(spellIdentifier, enable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetBaseSpell)
---@param spellIdentifier SpellIdentifier
---@param spec? number Default = 0
---@return number baseSpellID
function C_Spell.GetBaseSpell(spellIdentifier, spec) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetDeadlyDebuffInfo)
---@param spellIdentifier SpellIdentifier
---@return DeadlyDebuffInfo deadlyDebuffInfo
function C_Spell.GetDeadlyDebuffInfo(spellIdentifier) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetMawPowerBorderAtlasBySpellID)
---@param spellID number
---@return textureAtlas rarityBorderAtlas
function C_Spell.GetMawPowerBorderAtlasBySpellID(spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetMawPowerLinkBySpellID)
---@param spellID number
---@return string link
function C_Spell.GetMawPowerLinkBySpellID(spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetOverrideSpell)
---@param spellIdentifier SpellIdentifier
---@param spec? number Default = 0
---@param onlyKnown? boolean Default = true
---@param ignoreOverrideSpellID? number Default = 0
---@return number overrideSpellID
function C_Spell.GetOverrideSpell(spellIdentifier, spec, onlyKnown, ignoreOverrideSpellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSchoolString)
---@param schoolMask number
---@return string result
function C_Spell.GetSchoolString(schoolMask) end

---Returns nil if spell is not found
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellAutoCast)
---@param spellIdentifier SpellIdentifier
---@return boolean autoCastAllowed
---@return boolean autoCastEnabled
function C_Spell.GetSpellAutoCast(spellIdentifier) end

---Returns number of times a spell can be cast, typically based on availability of things like required reagent items; Returns 0 if spell is not found
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellCastCount)
---@param spellIdentifier SpellIdentifier
---@return number castCount
function C_Spell.GetSpellCastCount(spellIdentifier) end

---Returns a table of info about the charges of a charge-accumulating spell; May return nil if spell is not found or is not charge-based
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellCharges)
---@param spellIdentifier SpellIdentifier
---@return SpellChargeInfo chargeInfo
function C_Spell.GetSpellCharges(spellIdentifier) end

---Returns nil if spell is not found
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellCooldown)
---@param spellIdentifier SpellIdentifier
---@return SpellCooldownInfo spellCooldownInfo
function C_Spell.GetSpellCooldown(spellIdentifier) end

---Returns nil if spell is not found
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellDescription)
---@param spellIdentifier SpellIdentifier
---@return string description
function C_Spell.GetSpellDescription(spellIdentifier) end

---Meant primarily for getting a spell id from a spell name or link; Returns nothing if spell does not exist
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellIDForSpellIdentifier)
---@param spellIdentifier SpellIdentifier
---@return number spellID
function C_Spell.GetSpellIDForSpellIdentifier(spellIdentifier) end

---Returns nil if spell is not found
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellInfo)
---@param spellIdentifier SpellIdentifier
---@return SpellInfo spellInfo
function C_Spell.GetSpellInfo(spellIdentifier) end

---Returns the level the spell is learned at; May return a different value if the player is currently Level Linked with another player
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellLevelLearned)
---@param spellIdentifier SpellIdentifier
---@return number levelLearned
function C_Spell.GetSpellLevelLearned(spellIdentifier) end

---Returns nil if spell is not found
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellLink)
---@param spellIdentifier SpellIdentifier
---@param glyphID? number
---@return string spellLink
function C_Spell.GetSpellLink(spellIdentifier, glyphID) end

---Returns nil if spell is not found
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellLossOfControlCooldown)
---@param spellIdentifier SpellIdentifier
---@return number startTime
---@return number duration
function C_Spell.GetSpellLossOfControlCooldown(spellIdentifier) end

---Returns nil if spell is not found
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellName)
---@param spellIdentifier SpellIdentifier
---@return string name
function C_Spell.GetSpellName(spellIdentifier) end

---Returns a table containing one or more SpellPowerCostInfos, one for each power type this spell costs; May return nil if spell is not found or has no resource costs
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellPowerCost)
---@param spellIdentifier SpellIdentifier
---@return SpellPowerCostInfo[] powerCosts
function C_Spell.GetSpellPowerCost(spellIdentifier) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellQueueWindow)
---@return number result
function C_Spell.GetSpellQueueWindow() end

---Returns the rank of a spell that corresponds to an ability within a ranked SkillLine (ex: a crafting Recipe); Returns nil if spell is not found, or isn't part of a ranked SkillLine
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellSkillLineAbilityRank)
---@param spellIdentifier SpellIdentifier
---@return number rank
function C_Spell.GetSpellSkillLineAbilityRank(spellIdentifier) end

---Returns nil if spell is not found
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellSubtext)
---@param spellIdentifier SpellIdentifier
---@return string subtext
function C_Spell.GetSpellSubtext(spellIdentifier) end

---Returns nothing if spell is not found
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellTexture)
---@param spellIdentifier SpellIdentifier
---@return fileID iconID
---@return fileID originalIconID
function C_Spell.GetSpellTexture(spellIdentifier) end

---Returns nil if spell is not associated with a trade skill
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.GetSpellTradeSkillLink)
---@param spellIdentifier SpellIdentifier
---@return string spellLink
function C_Spell.GetSpellTradeSkillLink(spellIdentifier) end

---Returns true if the spell is the player's melee Auto Attack spell
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.IsAutoAttackSpell)
---@param spellIdentifier SpellIdentifier
---@return boolean isAutoAttack
function C_Spell.IsAutoAttackSpell(spellIdentifier) end

---Returns true if the spell is an auto repeat player spell
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.IsAutoRepeatSpell)
---@param spellIdentifier SpellIdentifier
---@return boolean isAutoRepeat
function C_Spell.IsAutoRepeatSpell(spellIdentifier) end

---Returns true if the spell comes from a Class Talent
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.IsClassTalentSpell)
---@param spellIdentifier SpellIdentifier
---@return boolean isAutoRepeat
function C_Spell.IsClassTalentSpell(spellIdentifier) end

---Returns true if the spell is currently being cast or is queued to be cast
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.IsCurrentSpell)
---@param spellIdentifier SpellIdentifier
---@return boolean isCurrentSpell
function C_Spell.IsCurrentSpell(spellIdentifier) end

---Returns true if the spell is an 'empower' type spell that is cast by pressing and holding, with the on-release cast typically being affected by time held
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.IsPressHoldReleaseSpell)
---@param spellIdentifier SpellIdentifier
---@return boolean isPressHoldRelease
function C_Spell.IsPressHoldReleaseSpell(spellIdentifier) end

---Returns true if the spell comes from a PvP Talent
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.IsPvPTalentSpell)
---@param spellIdentifier SpellIdentifier
---@return boolean isAutoRepeat
function C_Spell.IsPvPTalentSpell(spellIdentifier) end

---Returns true if the spell is the player's ranged Auto Attack spell (ex: Shoot, Auto Shot, etc)
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.IsRangedAutoAttackSpell)
---@param spellIdentifier SpellIdentifier
---@return boolean isRangedAutoAttack
function C_Spell.IsRangedAutoAttackSpell(spellIdentifier) end

---Returns true if data for the spell has already been loaded and cached this session
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.IsSpellDataCached)
---@param spellIdentifier SpellIdentifier
---@return boolean isCached
function C_Spell.IsSpellDataCached(spellIdentifier) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.IsSpellDisabled)
---@param spellIdentifier SpellIdentifier
---@return boolean disabled
function C_Spell.IsSpellDisabled(spellIdentifier) end

---Returns true if the spell can be cast on hostile targets
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.IsSpellHarmful)
---@param spellIdentifier SpellIdentifier
---@return boolean isHarmful
function C_Spell.IsSpellHarmful(spellIdentifier) end

---Returns true if the spell can be cast on the player or other friendly targets
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.IsSpellHelpful)
---@param spellIdentifier SpellIdentifier
---@return boolean isHelpful
function C_Spell.IsSpellHelpful(spellIdentifier) end

---Returns true if the current target is within range of the spell; False if out of range; Nil if range check was invalid
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.IsSpellInRange)
---@param spellIdentifier SpellIdentifier
---@param targetUnit? UnitToken
---@return boolean? inRange
function C_Spell.IsSpellInRange(spellIdentifier, targetUnit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.IsSpellPassive)
---@param spellIdentifier SpellIdentifier
---@return boolean isPassive
function C_Spell.IsSpellPassive(spellIdentifier) end

---Returns whether the spell is currently castable; Typically based on things like learned status, required resources, etc
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.IsSpellUsable)
---@param spellIdentifier SpellIdentifier
---@return boolean isUsable
---@return boolean insufficientPower
function C_Spell.IsSpellUsable(spellIdentifier) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.PickupSpell)
---@param spellIdentifier SpellIdentifier
function C_Spell.PickupSpell(spellIdentifier) end

---Requests data for the spell be loaded; Listen for SPELL_DATA_LOAD_RESULT to be notified when load is finished
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.RequestLoadSpellData)
---@param spellIdentifier SpellIdentifier
function C_Spell.RequestLoadSpellData(spellIdentifier) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.SetSpellAutoCastEnabled)
---@param spellIdentifier SpellIdentifier
---@param enabled boolean
function C_Spell.SetSpellAutoCastEnabled(spellIdentifier, enabled) end

---Returns true if the spell has a min and/or max range greater than 0
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.SpellHasRange)
---@param spellIdentifier SpellIdentifier
---@return boolean hasRange
function C_Spell.SpellHasRange(spellIdentifier) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.TargetSpellIsEnchanting)
---@return boolean isEnchanting
function C_Spell.TargetSpellIsEnchanting() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.TargetSpellJumpsUpgradeTrack)
---@return boolean jumpsUpgradeTrack
function C_Spell.TargetSpellJumpsUpgradeTrack() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.TargetSpellReplacesBonusTree)
---@return boolean result
function C_Spell.TargetSpellReplacesBonusTree() end

---Toggles whether spell's autoCast is enabled
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Spell.ToggleSpellAutoCast)
---@param spellIdentifier SpellIdentifier
function C_Spell.ToggleSpellAutoCast(spellIdentifier) end

---@class DeadlyDebuffInfo
---@field criticalTimeRemainingMs number?
---@field criticalStacks number?
---@field priority number
---@field warningText string
---@field soundKitID number?

---@class SpellInfo
---@field name string
---@field iconID fileID
---@field originalIconID fileID
---@field castTime number
---@field minRange number
---@field maxRange number
---@field spellID number
