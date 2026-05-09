---@meta _
C_SpellBook = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.CastSpellBookItem)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@param targetSelf? boolean Default = false
function C_SpellBook.CastSpellBookItem(spellBookItemSlotIndex, spellBookItemSpellBank, targetSelf) end

---Returns true if player knows any Disenchant spells
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.ContainsAnyDisenchantSpell)
---@return boolean contains
function C_SpellBook.ContainsAnyDisenchantSpell() end

---If found, returns the first slot position of a SpellBookItem matching the specified spell and criteria
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.FindSpellBookSlotForSpell)
---@param spellIdentifier SpellIdentifier
---@param includeHidden? boolean Default = false
---@param includeFlyouts? boolean Default = true
---@param includeFutureSpells? boolean Default = false
---@param includeOffSpec? boolean Default = false
---@return number spellBookItemSlotIndex
---@return Enum.SpellBookSpellBank spellBookItemSpellBank
function C_SpellBook.FindSpellBookSlotForSpell(spellIdentifier, includeHidden, includeFlyouts, includeFutureSpells, includeOffSpec) end

---Returns general, class, and active spec spells that are learned at the specified level
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetCurrentLevelSpells)
---@param level number
---@return number[] spellIDs
function C_SpellBook.GetCurrentLevelSpells(level) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetNumSpellBookSkillLines)
---@return number numSpellBookSkillLines
function C_SpellBook.GetNumSpellBookSkillLines() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSkillLineIndexByID)
---@param skillLineID number
---@return number? skillIndex
function C_SpellBook.GetSkillLineIndexByID(skillLineID) end

---Returns nothing if item doesn't exist or isn't a spell
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemAutoCast)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return boolean autoCastAllowed
---@return boolean autoCastEnabled
function C_SpellBook.GetSpellBookItemAutoCast(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Returns number of times a SpellBookItem can be cast, typically based on availability of things like required reagent items; Always returns 0 if item is not found or is not a spell
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemCastCount)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return number castCount
function C_SpellBook.GetSpellBookItemCastCount(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Returns a table of info about the charges of a charge-accumulating SpellBookItem; May return nil if item is not found or is not charge-based
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemCharges)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return SpellChargeInfo chargeInfo
function C_SpellBook.GetSpellBookItemCharges(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Returns nil if item doesn't exist or if this kind of item doesn't display cooldowns (ex: future or offspec spells)
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemCooldown)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return SpellCooldownInfo spellCooldownInfo
function C_SpellBook.GetSpellBookItemCooldown(spellBookItemSlotIndex, spellBookItemSpellBank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemDescription)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return string description
function C_SpellBook.GetSpellBookItemDescription(spellBookItemSlotIndex, spellBookItemSpellBank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemInfo)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return SpellBookItemInfo spellBookItemInfo
function C_SpellBook.GetSpellBookItemInfo(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Returns the level the spell is learned at; May return a different value if the player is currently Level Linked with another player; Returns 0 if item is not a Spell
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemLevelLearned)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return number levelLearned
function C_SpellBook.GetSpellBookItemLevelLearned(spellBookItemSlotIndex, spellBookItemSpellBank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemLink)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@param glyphID? number
---@return string spellLink
function C_SpellBook.GetSpellBookItemLink(spellBookItemSlotIndex, spellBookItemSpellBank, glyphID) end

---Returns nil if item doesn't exist or if this kind of item doesn't display cooldowns (ex: future or offspec spells)
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemLossOfControlCooldown)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return number startTime
---@return number duration
function C_SpellBook.GetSpellBookItemLossOfControlCooldown(spellBookItemSlotIndex, spellBookItemSpellBank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemName)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return string name
---@return string subName
function C_SpellBook.GetSpellBookItemName(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Returns a table containing one or more SpellPowerCostInfos, one for each power type a SpellBookItem costs; May return nil if item is not found or has no resource costs
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemPowerCost)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return SpellPowerCostInfo[] powerCosts
function C_SpellBook.GetSpellBookItemPowerCost(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Get the index of the SkillLine this SpellBookItem is part of
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemSkillLineIndex)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return number? skillLineIndex
function C_SpellBook.GetSpellBookItemSkillLineIndex(spellBookItemSlotIndex, spellBookItemSpellBank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemTexture)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return fileID iconID
function C_SpellBook.GetSpellBookItemTexture(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Returns nil if SpellBookItem is not associated with a trade skill
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemTradeSkillLink)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return string spellLink
function C_SpellBook.GetSpellBookItemTradeSkillLink(spellBookItemSlotIndex, spellBookItemSpellBank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemType)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return Enum.SpellBookItemType itemType
---@return number actionID
---@return number? spellID
function C_SpellBook.GetSpellBookItemType(spellBookItemSlotIndex, spellBookItemSpellBank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookSkillLineInfo)
---@param skillLineIndex number
---@return SpellBookSkillLineInfo skillLineInfo
function C_SpellBook.GetSpellBookSkillLineInfo(skillLineIndex) end

---Returns nothing if player has no pet spells
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.HasPetSpells)
---@return number numPetSpells
---@return string petNameToken
function C_SpellBook.HasPetSpells() end

---Returns true if the SpellBookItem is the player's melee Auto Attack spell
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsAutoAttackSpellBookItem)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return boolean isAutoAttack
function C_SpellBook.IsAutoAttackSpellBookItem(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Returns true if the SpellBookItem comes from a Class Talent
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsClassTalentSpellBookItem)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return boolean isClassTalent
function C_SpellBook.IsClassTalentSpellBookItem(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Returns true if the SpellBookItem comes from a PvP Talent
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsPvPTalentSpellBookItem)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return boolean isPvPTalent
function C_SpellBook.IsPvPTalentSpellBookItem(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Returns true if the SpellBookItem is the player's ranged Auto Attack spell (ex: Shoot, Auto Shot, etc)
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsRangedAutoAttackSpellBookItem)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return boolean isRangedAutoAttack
function C_SpellBook.IsRangedAutoAttackSpellBookItem(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Returns true if the SpellBookIem can be cast on hostile targets
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellBookItemHarmful)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return boolean isHarmful
function C_SpellBook.IsSpellBookItemHarmful(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Returns true if the SpellBookIem can be cast on the player or other friendly targets
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellBookItemHelpful)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return boolean isHelpful
function C_SpellBook.IsSpellBookItemHelpful(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Returns true if the current target is within range of the SpellBookIem; False if out of range; Nil if range check was invalid
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellBookItemInRange)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@param targetUnit? UnitToken
---@return boolean? inRange
function C_SpellBook.IsSpellBookItemInRange(spellBookItemSlotIndex, spellBookItemSpellBank, targetUnit) end

---Returns true if the SpellBookItem belongs to a non-active class specialization
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellBookItemOffSpec)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return boolean isOffSpec
function C_SpellBook.IsSpellBookItemOffSpec(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Returns true if the SpellBookItem is a passive spell; Will always return false if it is not a spell
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellBookItemPassive)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return boolean isPassive
function C_SpellBook.IsSpellBookItemPassive(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Returns whether the SpellBookIem is currently castable; Typically based on things like learned status, required resources, etc
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellBookItemUsable)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return boolean isUsable
---@return boolean insufficientPower
function C_SpellBook.IsSpellBookItemUsable(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Returns true if a spell should be found in the spellbook. This function can also return true for spells that aren't known, such as override spells granted by an aura linked to class talents
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellInSpellBook)
---@param spellID number
---@param spellBank? Enum.SpellBookSpellBank Default = Player
---@param includeOverrides? boolean Default = true
---@return boolean isInSpellBook
function C_SpellBook.IsSpellInSpellBook(spellID, spellBank, includeOverrides) end

---Returns true if a player knows a spell. This function can also return true for spells that aren't in the spellbook, such as temporarily-granted abilities
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellKnown)
---@param spellID number
---@param spellBank? Enum.SpellBookSpellBank Default = Player
---@return boolean isKnown
function C_SpellBook.IsSpellKnown(spellID, spellBank) end

---Returns true if a spell is considered to be known or present in the spellbook
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellKnownOrInSpellBook)
---@param spellID number
---@param spellBank? Enum.SpellBookSpellBank Default = Player
---@param includeOverrides? boolean Default = true
---@return boolean isKnownOrInSpellBook
function C_SpellBook.IsSpellKnownOrInSpellBook(spellID, spellBank, includeOverrides) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.PickupSpellBookItem)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
function C_SpellBook.PickupSpellBookItem(spellBookItemSlotIndex, spellBookItemSpellBank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.SetSpellBookItemAutoCastEnabled)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@param enabled boolean
function C_SpellBook.SetSpellBookItemAutoCastEnabled(spellBookItemSlotIndex, spellBookItemSpellBank, enabled) end

---Returns true if the SpellBookIem has a min and/or max range greater than 0; Will always return false if it is not a spell
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.SpellBookItemHasRange)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return boolean hasRange
function C_SpellBook.SpellBookItemHasRange(spellBookItemSlotIndex, spellBookItemSpellBank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.ToggleSpellBookItemAutoCast)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
function C_SpellBook.ToggleSpellBookItemAutoCast(spellBookItemSlotIndex, spellBookItemSpellBank) end

---@class SpellBookItemInfo
---@field actionID number
---@field spellID number?
---@field itemType Enum.SpellBookItemType
---@field name string
---@field subName string
---@field iconID fileID
---@field isPassive boolean
---@field isOffSpec boolean
---@field skillLineIndex number?

---@class SpellBookSkillLineInfo
---@field name string
---@field iconID fileID
---@field itemIndexOffset number
---@field numSpellBookItems number
---@field isGuild boolean
---@field shouldHide boolean
---@field specID number?
---@field offSpecID number?
