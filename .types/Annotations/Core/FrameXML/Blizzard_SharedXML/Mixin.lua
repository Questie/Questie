---@meta _
---[FrameXML](https://www.townlong-yak.com/framexml/go/Mixin)
--- Copies mixins into an existing object
---@generic T1, T2
---@param object T1
---@param ... T2
---@return T1|T2 mixin
function Mixin(object, ...)
	for i = 1, select("#", ...) do
		local mixin = select(i, ...);
		for k, v in pairs(mixin) do
			object[k] = v;
		end
	end
	return object;
end

---[FrameXML](https://www.townlong-yak.com/framexml/go/CreateFromMixins)
--- Copies mixins into a new object
---@generic T1, T2
---@param mixin T1
---@param ... T2
---@return T1|T2 mixin
function CreateFromMixins(mixin, ...)
	return Mixin({}, mixin, ...)
end

---[FrameXML](https://www.townlong-yak.com/framexml/go/CreateAndInitFromMixin)
--- Copies mixins into a new object and initializes it
---@generic T
---@param mixin T
---@param ... any
---@return T mixin
function CreateAndInitFromMixin(mixin, ...)
	local object = CreateFromMixins(mixin);
	object:Init(...);
	return object;
end
