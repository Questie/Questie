---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_Frame)
---@class Frame : Region, ScriptObject
local Frame = {}
---@class frame : Frame
---@class FRAME : Frame

---@param scriptType ScriptFrame
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return function handler
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_GetScript)
function Frame:GetScript(scriptType, bindingType) end

---@param scriptType ScriptFrame
---@return boolean hasScript
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HasScript)
function Frame:HasScript(scriptType) end

---@param scriptType ScriptFrame
---@param handler function
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return boolean success
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HookScript)
function Frame:HookScript(scriptType, handler, bindingType) end

---@param scriptType ScriptFrame
---@param handler function|nil
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_SetScript)
function Frame:SetScript(scriptType, handler) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Object_GetParent)
---@return Frame? parent
function Frame:GetParent() end


---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_AbortDrag)
function Frame:AbortDrag() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_CanChangeAttribute)
---@return boolean canChangeAttributes
function Frame:CanChangeAttribute() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_ClearAlphaGradient)
function Frame:ClearAlphaGradient() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_ClearAttribute)
---@param attributeName string
---@return boolean cleared
function Frame:ClearAttribute(attributeName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_ClearAttributes)
function Frame:ClearAttributes() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_CreateFontString)
---@param name? string
---@param drawLayer? DrawLayer
---@param templateName? string
---@return SimpleFontString line
function Frame:CreateFontString(name, drawLayer, templateName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_CreateLine)
---@param name? string
---@param drawLayer? DrawLayer
---@param templateName? string
---@param subLevel? number
---@return SimpleLine line
function Frame:CreateLine(name, drawLayer, templateName, subLevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_CreateMaskTexture)
---@param name? string
---@param drawLayer? DrawLayer
---@param templateName? string
---@param subLevel? number
---@return SimpleMaskTexture maskTexture
function Frame:CreateMaskTexture(name, drawLayer, templateName, subLevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_CreateTexture)
---@param name? string
---@param drawLayer? DrawLayer
---@param templateName? string
---@param subLevel? number
---@return SimpleTexture texture
function Frame:CreateTexture(name, drawLayer, templateName, subLevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_DesaturateHierarchy)
---@param desaturation number
---@param excludeRoot? boolean Default = false
function Frame:DesaturateHierarchy(desaturation, excludeRoot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_DisableDrawLayer)
---@param layer DrawLayer
function Frame:DisableDrawLayer(layer) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_DoesClipChildren)
---@return boolean clipsChildren
function Frame:DoesClipChildren() end

---Returns whether hyperlink events (ex. OnHyperlinkEnter, OnHyperlinkLeave, OnHyperlinkClick) are propagated to this frame's parent.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_DoesHyperlinkPropagateToParent)
---@return boolean canPropagate
function Frame:DoesHyperlinkPropagateToParent() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_EnableDrawLayer)
---@param layer DrawLayer
function Frame:EnableDrawLayer(layer) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_EnableGamePadButton)
---@param enable? boolean Default = false
function Frame:EnableGamePadButton(enable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_EnableGamePadStick)
---@param enable? boolean Default = false
function Frame:EnableGamePadStick(enable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_EnableKeyboard)
---@param enable? boolean Default = false
function Frame:EnableKeyboard(enable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_ExecuteAttribute)
---@param attributeName string
---@param ...? string arguments
---@return boolean success
---@return string? ... returns
function Frame:ExecuteAttribute(attributeName, ...) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetAlpha)
---@return SingleColorValue alpha
function Frame:GetAlpha() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetAttribute)
---@param attributeName string
---@return string value
function Frame:GetAttribute(attributeName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetBoundsRect)
---@return uiUnit left
---@return uiUnit bottom
---@return uiUnit width
---@return uiUnit height
function Frame:GetBoundsRect() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetChildren)
---@return SimpleFrame ... children
function Frame:GetChildren() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetClampRectInsets)
---@return uiUnit left
---@return uiUnit right
---@return uiUnit top
---@return uiUnit bottom
function Frame:GetClampRectInsets() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetDontSavePosition)
---@return boolean dontSave
function Frame:GetDontSavePosition() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetEffectiveAlpha)
---@return SingleColorValue effectiveAlpha
function Frame:GetEffectiveAlpha() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetEffectiveScale)
---@return number effectiveScale
function Frame:GetEffectiveScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetEffectivelyFlattensRenderLayers)
---@return boolean flatten
function Frame:GetEffectivelyFlattensRenderLayers() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetFlattensRenderLayers)
---@return boolean flatten
function Frame:GetFlattensRenderLayers() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetFrameLevel)
---@return number frameLevel
function Frame:GetFrameLevel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetFrameStrata)
---@return FrameStrata strata
function Frame:GetFrameStrata() end

---Returns the highest framelevel of the frame and its first order children, or all children if iterateAllChildren is true.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetHighestFrameLevel)
---@param iterateAllChildren? boolean Default = false
---@return number frameLevel
function Frame:GetHighestFrameLevel(iterateAllChildren) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetHitRectInsets)
---@return uiUnit left
---@return uiUnit right
---@return uiUnit top
---@return uiUnit bottom
function Frame:GetHitRectInsets() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetHyperlinksEnabled)
---@return boolean enabled
function Frame:GetHyperlinksEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetID)
---@return number id
function Frame:GetID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetNumChildren)
---@return number numChildren
function Frame:GetNumChildren() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetNumRegions)
---@return number numRegions
function Frame:GetNumRegions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetPropagateKeyboardInput)
---@return boolean propagate
function Frame:GetPropagateKeyboardInput() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetRaisedFrameLevel)
---@return number frameLevel
function Frame:GetRaisedFrameLevel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetRegions)
---@return SimpleRegion ... regions
function Frame:GetRegions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetResizeBounds)
---@return uiUnit minWidth
---@return uiUnit minHeight
---@return uiUnit maxWidth
---@return uiUnit maxHeight
function Frame:GetResizeBounds() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetScale)
---@return number frameScale
function Frame:GetScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_GetWindow)
---@return SimpleWindow window
function Frame:GetWindow() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_HasAlphaGradient)
---@return boolean hasAlphaGradient
function Frame:HasAlphaGradient() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_HasFixedFrameLevel)
---@return boolean isFixed
function Frame:HasFixedFrameLevel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_HasFixedFrameStrata)
---@return boolean isFixed
function Frame:HasFixedFrameStrata() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_Hide)
function Frame:Hide() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_InterceptStartDrag)
---@param delegate SimpleFrame
---@return boolean success
function Frame:InterceptStartDrag(delegate) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsClampedToScreen)
---@return boolean clampedToScreen
function Frame:IsClampedToScreen() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsDrawLayerEnabled)
---@param layer DrawLayer
---@return boolean isEnabled
function Frame:IsDrawLayerEnabled(layer) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsEventRegistered)
---@param eventName FrameEvent
---@return boolean isRegistered
---@return UnitToken? ... units
function Frame:IsEventRegistered(eventName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsFrameBuffer)
---@return boolean isFrameBuffer
function Frame:IsFrameBuffer() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsGamePadButtonEnabled)
---@return boolean enabled
function Frame:IsGamePadButtonEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsGamePadStickEnabled)
---@return boolean enabled
function Frame:IsGamePadStickEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsHighlightLocked)
---@return boolean locked
function Frame:IsHighlightLocked() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsIgnoringParentAlpha)
---@return boolean ignore
function Frame:IsIgnoringParentAlpha() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsIgnoringParentScale)
---@return boolean ignore
function Frame:IsIgnoringParentScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsKeyboardEnabled)
---@return boolean enabled
function Frame:IsKeyboardEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsMovable)
---@return boolean isMovable
function Frame:IsMovable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsObjectLoaded)
---@return boolean isLoaded
function Frame:IsObjectLoaded() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsResizable)
---@return boolean resizable
function Frame:IsResizable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsShown)
---@return boolean isShown
function Frame:IsShown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsToplevel)
---@return boolean isTopLevel
function Frame:IsToplevel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsUserPlaced)
---@return boolean isUserPlaced
function Frame:IsUserPlaced() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsUsingParentLevel)
---@return boolean usingParentLevel
function Frame:IsUsingParentLevel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_IsVisible)
---@return boolean isVisible
function Frame:IsVisible() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_LockHighlight)
function Frame:LockHighlight() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_Lower)
function Frame:Lower() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_Raise)
function Frame:Raise() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_RegisterAllEvents)
function Frame:RegisterAllEvents() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_RegisterEvent)
---@param eventName FrameEvent
---@return boolean registered
function Frame:RegisterEvent(eventName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_RegisterForDrag)
---@param ... MouseButton buttons
function Frame:RegisterForDrag(...) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_RegisterUnitEvent)
---@param eventName FrameEvent
---@param ... UnitToken units
---@return boolean registered
function Frame:RegisterUnitEvent(eventName, ...) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_RotateTextures)
---@param radians number
---@param x? number Default = 0.5
---@param y? number Default = 0.5
function Frame:RotateTextures(radians, x, y) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetAlpha)
---@param alpha SingleColorValue
function Frame:SetAlpha(alpha) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetAlphaGradient)
---@param index number
---@param gradient vector2
function Frame:SetAlphaGradient(index, gradient) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetAttribute)
---@param attributeName string
---@param value any
function Frame:SetAttribute(attributeName, value) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetAttributeNoHandler)
---@param attributeName string
---@param value any
function Frame:SetAttributeNoHandler(attributeName, value) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetClampRectInsets)
---@param left uiUnit
---@param right uiUnit
---@param top uiUnit
---@param bottom uiUnit
function Frame:SetClampRectInsets(left, right, top, bottom) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetClampedToScreen)
---@param clampedToScreen boolean
function Frame:SetClampedToScreen(clampedToScreen) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetClipsChildren)
---@param clipsChildren boolean
function Frame:SetClipsChildren(clipsChildren) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetDontSavePosition)
---@param dontSave boolean
function Frame:SetDontSavePosition(dontSave) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetDrawLayerEnabled)
---@param layer DrawLayer
---@param isEnabled? boolean Default = false
function Frame:SetDrawLayerEnabled(layer, isEnabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetFixedFrameLevel)
---@param isFixed boolean
function Frame:SetFixedFrameLevel(isFixed) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetFixedFrameStrata)
---@param isFixed boolean
function Frame:SetFixedFrameStrata(isFixed) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetFlattensRenderLayers)
---@param flatten boolean
function Frame:SetFlattensRenderLayers(flatten) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetFrameLevel)
---@param frameLevel number
function Frame:SetFrameLevel(frameLevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetFrameStrata)
---@param strata FrameStrata
function Frame:SetFrameStrata(strata) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetHighlightLocked)
---@param locked boolean
function Frame:SetHighlightLocked(locked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetHitRectInsets)
---@param left uiUnit
---@param right uiUnit
---@param top uiUnit
---@param bottom uiUnit
function Frame:SetHitRectInsets(left, right, top, bottom) end

---Enables or disables propagating hyperlink events (ex. OnHyperlinkEnter, OnHyperlinkLeave, OnHyperlinkClick) to this frame's parent.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetHyperlinkPropagateToParent)
---@param canPropagate boolean
function Frame:SetHyperlinkPropagateToParent(canPropagate) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetHyperlinksEnabled)
---@param enabled? boolean Default = false
function Frame:SetHyperlinksEnabled(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetID)
---@param id number
function Frame:SetID(id) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetIgnoreParentAlpha)
---@param ignore boolean
function Frame:SetIgnoreParentAlpha(ignore) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetIgnoreParentScale)
---@param ignore boolean
function Frame:SetIgnoreParentScale(ignore) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetIsFrameBuffer)
---@param isFrameBuffer boolean
function Frame:SetIsFrameBuffer(isFrameBuffer) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetMovable)
---@param movable boolean
function Frame:SetMovable(movable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetPropagateKeyboardInput)
---@param propagate boolean
function Frame:SetPropagateKeyboardInput(propagate) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetResizable)
---@param resizable boolean
function Frame:SetResizable(resizable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetResizeBounds)
---@param minWidth uiUnit
---@param minHeight uiUnit
---@param maxWidth? uiUnit
---@param maxHeight? uiUnit
function Frame:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetScale)
---@param scale number
function Frame:SetScale(scale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetShown)
---@param shown? boolean Default = false
function Frame:SetShown(shown) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetToplevel)
---@param topLevel boolean
function Frame:SetToplevel(topLevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetUserPlaced)
---@param userPlaced boolean
function Frame:SetUserPlaced(userPlaced) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetUsingParentLevel)
---@param usingParentLevel boolean
function Frame:SetUsingParentLevel(usingParentLevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetWindow)
---@param window? SimpleWindow
function Frame:SetWindow(window) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_Show)
function Frame:Show() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_StartMoving)
---@param alwaysStartFromMouse? boolean Default = false
function Frame:StartMoving(alwaysStartFromMouse) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_StartSizing)
---@param resizePoint? FramePoint
---@param alwaysStartFromMouse? boolean Default = false
function Frame:StartSizing(resizePoint, alwaysStartFromMouse) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_StopMovingOrSizing)
function Frame:StopMovingOrSizing() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_UnlockHighlight)
function Frame:UnlockHighlight() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_UnregisterAllEvents)
function Frame:UnregisterAllEvents() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Frame_UnregisterEvent)
---@param eventName FrameEvent
---@return boolean registered
function Frame:UnregisterEvent(eventName) end
