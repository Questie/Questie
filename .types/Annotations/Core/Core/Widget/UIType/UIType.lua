---@meta _
---@alias BlendMode
---|"DISABLE"
---|"BLEND"
---|"ALPHAKEY"
---|"ADD"
---|"MOD"

---@alias CurveType
---|"NONE"
---|"SMOOTH"

---@alias DrawLayer
---|"BACKGROUND"
---|"BORDER"
---|"ARTWORK"
---|"OVERLAY"
---|"HIGHLIGHT"

---@alias FilterMode
---|"LINEAR"
---|"TRILINEAR"
---|"NEAREST"

---@alias FontAlphabet
---|"roman"
---|"korean"
---|"simplifiedchinese"
---|"traditionalchinese"
---|"russian"

---@alias FramePoint
---|"TOPLEFT"
---|"TOPRIGHT"
---|"BOTTOMLEFT"
---|"BOTTOMRIGHT"
---|"TOP"
---|"BOTTOM"
---|"LEFT"
---|"RIGHT"
---|"CENTER"

---@alias FrameStrata
---|"PARENT"
---|"BACKGROUND"
---|"LOW"
---|"MEDIUM"
---|"HIGH"
---|"DIALOG"
---|"FULLSCREEN"
---|"FULLSCREEN_DIALOG"
---|"TOOLTIP"
---|"BLIZZARD"

---@alias InsertMode
---|"TOP"
---|"BOTTOM"

---@alias JustifyHorizontal
---|"LEFT"
---|"RIGHT"
---|"CENTER"

---@alias JustifyVertical 
---|"TOP"
---|"BOTTOM"
---|"MIDDLE"

---@alias LoopType 
---|"NONE"
---|"REPEAT"
---|"BOUNCE"

---@alias mouseButton
---|"LeftButton"
---|"RightButton"
---|"MiddleButton"
---|"Button4"
---|"Button5"

---@alias MouseButton mouseButton

---@alias ClickButton
---|"AnyUp"
---|"AnyDown"
---|"LeftButtonUp"
---|"LeftButtonDown"
---|"RightButtonUp"
---|"RightButtonDown"
---|"MiddleButtonUp"
---|"MiddleButtonDown"
---|"Button4Up"
---|"Button4Down"
---|"Button5Up"
---|"Button5Down"

---@alias Orientation
---|"HORIZONTAL"
---|"VERTICAL"

---@alias SimpleButtonStateToken
---|"DISABLED"
---|"NORMAL"
---|"PUSHED"

---@alias SmoothingType
---|"NONE"
---|"IN"
---|"OUT"
---|"IN_OUT"
---|"OUT_IN"

---@alias StatusBarFillStyle
---|"STANDARD"
---|"STANDARD_NO_RANGE_FILL"
---|"CENTER"
---|"REVERSE"

---@alias TBFFlags
---|""
---|"MONOCHROME"
---|"OUTLINE"
---|"THICKOUTLINE"
---|"SLUG"

--- `uiRect` cannot be annotated as a list of numbers
--- it's the same as Model:GetViewInsets/SetViewInsets params

---------------
-- custom types
---------------

---@alias TooltipAnchor
---|"ANCHOR_TOP"
---|"ANCHOR_RIGHT"
---|"ANCHOR_BOTTOM"
---|"ANCHOR_LEFT"
---|"ANCHOR_TOPRIGHT"
---|"ANCHOR_BOTTOMRIGHT"
---|"ANCHOR_TOPLEFT"
---|"ANCHOR_BOTTOMLEFT"
---|"ANCHOR_CURSOR"
---|"ANCHOR_CURSOR_RIGHT"
---|"ANCHOR_PRESERVE"
---|"ANCHOR_NONE"

---@alias WrapMode
---|"CLAMP"
---|"REPEAT"
---|"CLAMPTOBLACK"
---|"CLAMPTOBLACKADDITIVE"
---|"CLAMPTOWHITE"
---|"MIRROR"
