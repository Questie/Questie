---@meta _
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-comm-3-0)
---@class AceComm-3.0
local AceComm = {}

---@param prefix string A printable character (\032-\255) classification of the message (typically AddonName or AddonNameEvent), max 16 characters
---@param method? function|string OPTIONAL: Callback to call on message reception: Function reference, or method name (string) to call on self. Defaults to "OnCommReceived"
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-comm-3-0#title-1)
function AceComm:RegisterComm(prefix, method) end

---@param eventname string
function AceComm:UnregisterComm(eventname) end

---@param ... table
function AceComm:UnregisterAllComm(...) end

---@param prefix string A printable character (\032-\255) classification of the message (typically AddonName or AddonNameEvent)
---@param text string Data to send, nils (\000) not allowed. Any length.
---@param distribution string Addon channel, e.g. "RAID", "GUILD", etc; see SendAddonMessage API
---@param target string? Destination for some distributions; see SendAddonMessage API
---@param prio "BULK"|"NORMAL"|"ALERT"? OPTIONAL: ChatThrottleLib priority, "BULK", "NORMAL" or "ALERT". Defaults to "NORMAL".
---@param callbackFn function? OPTIONAL: callback function to be called as each chunk is sent. receives 3 args: the user supplied arg (see next), the number of bytes sent so far, and the number of bytes total to send.
---@param callbackArg ...? OPTIONAL: first arg to the callback function. nil will be passed if not specified.
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-comm-3-0#title-1)
function AceComm:SendCommMessage(prefix, text, distribution, target, prio, callbackFn, callbackArg) end

---@param target table
function AceComm:Embed(target) end

---@param target table
function AceComm:OnEmbedDisable(target) end

---@protected
---@param prefix string
---@param message string
---@param distribution string
---@param sender string
function AceComm:OnReceiveMultipartFirst(prefix, message, distribution, sender) end

---@protected
---@param prefix string
---@param message string
---@param distribution string
---@param sender string
function AceComm:OnReceiveMultipartNext(prefix, message, distribution, sender) end

---@protected
---@param prefix string
---@param message string
---@param distribution string
---@param sender string
function AceComm:OnReceiveMultipartLast(prefix, message, distribution, sender) end
