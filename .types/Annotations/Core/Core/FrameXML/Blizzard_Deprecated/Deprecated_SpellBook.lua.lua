---@meta _

---@deprecated
---Deprecated by [C_SpellBook.IsSpellKnown](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellKnown)
---@param spellID number
---@return boolean isKnown
function IsPlayerSpell(spellID) end

---@deprecated
---Deprecated by [C_SpellBook.IsSpellInSpellBook](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellInSpellBook)
---@param spellID number
---@param isPet boolean
---@return boolean isInSpellBook
function IsSpellKnown(spellID, isPet) end

---@deprecated
---Deprecated by [C_SpellBook.IsSpellInSpellBook](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellInSpellBook)
---@param spellID number
---@param isPet boolean
---@return boolean isInSpellBook
function IsSpellKnownOrOverridesKnown(spellID, isPet) end
