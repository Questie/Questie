---@meta _
---[Documentation](https://www.wowace.com/projects/libsharedmedia-3-0/pages/api-documentation)
---@class LibSharedMedia-3.0
local LibSharedMedia = {}

LibSharedMedia.LOCALE_BIT_koKR = 1
LibSharedMedia.LOCALE_BIT_ruRU = 2
LibSharedMedia.LOCALE_BIT_zhCN = 4
LibSharedMedia.LOCALE_BIT_zhTW = 8
LibSharedMedia.LOCALE_BIT_western = 128

LibSharedMedia.MediaType = {
	BACKGROUND = "background",
	BORDER = "border",
	FONT = "font",
	STATUSBAR = "statusbar",
	SOUND = "sound",
}

---@alias LibSharedMediaTypes
---| '"background"' # Backgrounds
---| '"border"' # Borders
---| '"font"' # Fonts
---| '"sound"' # Sounds
---| '"statusbar"' # Statusbars

---@param mediatype LibSharedMediaTypes
---@param key string
---@param data string|number the data to associate with the handle; a filename or FileID
---@param langmask? number
---[Documentation](https://www.wowace.com/projects/libsharedmedia-3-0/pages/api-documentation/)
function LibSharedMedia:Register(mediatype, key, data, langmask) end

---@param mediatype LibSharedMediaTypes
---@param key string
---@param noDefault? boolean
---@return string?
---[Documentation](https://www.wowace.com/projects/libsharedmedia-3-0/pages/api-documentation/)
function LibSharedMedia:Fetch(mediatype, key, noDefault) end

---@param mediatype LibSharedMediaTypes
---@param key? string
---[Documentation](https://www.wowace.com/projects/libsharedmedia-3-0/pages/api-documentation/)
function LibSharedMedia:IsValid(mediatype, key) end

---@param mediatype LibSharedMediaTypes
---@return table<string, string>
---[Documentation](https://www.wowace.com/projects/libsharedmedia-3-0/pages/api-documentation/)
function LibSharedMedia:HashTable(mediatype) end

---@param mediatype LibSharedMediaTypes
---@return string[]
---[Documentation](https://www.wowace.com/projects/libsharedmedia-3-0/pages/api-documentation/)
function LibSharedMedia:List(mediatype) end

---@param mediatype LibSharedMediaTypes
---@return string?
---[Documentation](https://www.wowace.com/projects/libsharedmedia-3-0/pages/api-documentation/)
function LibSharedMedia:GetGlobal(mediatype) end

---@param mediatype LibSharedMediaTypes
---@param key? string
---[Documentation](https://www.wowace.com/projects/libsharedmedia-3-0/pages/api-documentation/)
function LibSharedMedia:SetGlobal(mediatype, key) end

---@param mediatype LibSharedMediaTypes
---@return string?
---[Documentation](https://www.wowace.com/projects/libsharedmedia-3-0/pages/api-documentation/)
function LibSharedMedia:GetDefault(mediatype) end

---@param type string
---@param handle string
---[Documentation](https://www.wowace.com/projects/libsharedmedia-3-0/pages/api-documentation/)
function LibSharedMedia:SetDefault(type, handle) end
