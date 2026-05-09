---@meta _

-- ----------------------------------------------------------------------------
-- AceTab-3.0
-- ----------------------------------------------------------------------------

---@class AceTab-3.0
local AceTab = {}

-- stylua: ignore start

-- Registers a tab completion set with AceTab
---@param descriptor string Unique identifier for this tab completion set
---@param prematches string|table|nil String match(es) AFTER which this tab completion will apply.<br>AceTab will ignore tabs NOT preceded by the string(s).<br>If no value is passed, will check all tabs pressed in the specified editframe(s) UNLESS a more-specific tab complete applies.
---@param wordlist function|table Function that will be passed a table into which it will insert strings corresponding to all possible completions, or an equivalent table.<br>The text in the editbox, the position of the start of the word to be completed, and the uncompleted partial word are passed as second, third, and fourth arguments, to facilitate pre-filtering or conditional formatting, if desired.
---@param usagefunc	function|boolean|nil Usage statement function.  Defaults to the wordlist, one per line.  A boolean true squelches usage output.
---@param listenframes string|EditBox|nil EditFrames to monitor.  Defaults to ChatFrameEditBox.
---@param postfunc function|nil Post-processing function.  If supplied, matches will be passed through this function after they've been identified as a match.
---@param pmoverwrite boolean|number|nil Offset the beginning of the completion string in the editbox when making a completion.<br>Passing a boolean true indicates that we want to overwrite the entire prematch string, and passing a number will overwrite that many characters prior to the cursor.<br>This is useful when you want to use the prematch as an indicator character, but ultimately do not want it as part of the text, itself.
function AceTab:RegisterTabCompletion(descriptor, prematches, wordlist, usagefunc, listenframes, postfunc, pmoverwrite) end

-- stylua: ignore end

-- Returns whether or not a tab completion set is registered.
---@param descriptor string Unique identifier for this tab completion set
---@return boolean
function AceTab:IsTabCompletionRegistered(descriptor) end

-- Unregisters a tab completion set from AceTab
---@param descriptor string Unique identifier for this tab completion set
function AceTab:UnregisterTabCompletion(descriptor) end

-- AceTab internal OnTabPressed script hook
---@param editBox EditBox The editbox to operate on
function AceTab:OnTabPressed(editBox) end
