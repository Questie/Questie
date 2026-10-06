
---------------
--NOTE - Please do not change this section without talking to Dan
--local _, tbl = ...;
--if tbl then
--	tbl.SecureCapsuleGet = SecureCapsuleGet;
--
--	local function Import(name)
--		tbl[name] = tbl.SecureCapsuleGet(name);
--	end
--
--	Import("IsOnGlueScreen");
--
--	if ( tbl.IsOnGlueScreen() ) then
--		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
--	end
--
--	setfenv(1, tbl);
--	
--	Import("pairs");
--	Import("ipairs");
--	Import("next");
--	Import("select");
--	Import("CreateFrame");
--	
--	function Mixin(object, ...)
--		for i = 1, select("#", ...) do
--			local mixin = select(i, ...);
--			for k, v in pairs(mixin) do
--				object[k] = v;
--			end
--		end
--
--		return object;
--	end
--
--	function ...)--- removed CreateFromMixin(VAR), We do this for the type because mixin is strange...-		return Mixin({}, ...)
--	end
--end
----------------

---@class ObjectPoolMixin
ObjectPoolMixin = {};

function ObjectPoolMixin:OnLoad(creationFunc, resetterFunc)
	self.creationFunc = creationFunc;
	self.resetterFunc = resetterFunc;

	self.activeObjects = {};
	self.inactiveObjects = {};

	self.numActiveObjects = 0;
end

function ObjectPoolMixin:Acquire()
	local numInactiveObjects = #self.inactiveObjects;
	if numInactiveObjects > 0 then
		local obj = self.inactiveObjects[numInactiveObjects];
		self.activeObjects[obj] = true;
		self.numActiveObjects = self.numActiveObjects + 1;
		self.inactiveObjects[numInactiveObjects] = nil;
		return obj, false;
	end

	local newObj = self.creationFunc(self);
	if self.resetterFunc then
		self.resetterFunc(self, newObj);
	end
	self.activeObjects[newObj] = true;
	self.numActiveObjects = self.numActiveObjects + 1;
	return newObj, true;
end

function ObjectPoolMixin:Release(obj)
	if self:IsActive(obj) then
		self.inactiveObjects[#self.inactiveObjects + 1] = obj;
		self.activeObjects[obj] = nil;
		self.numActiveObjects = self.numActiveObjects - 1;
		if self.resetterFunc then
			self.resetterFunc(self, obj);
		end

		return true;
	end

	return false;
end

function ObjectPoolMixin:ReleaseAll()
	for obj in pairs(self.activeObjects) do
		self:Release(obj);
	end
end

function ObjectPoolMixin:EnumerateActive()
	return pairs(self.activeObjects);
end

function ObjectPoolMixin:GetNextActive(current)
	return (next(self.activeObjects, current));
end

function ObjectPoolMixin:IsActive(object)
	return (self.activeObjects[object] ~= nil);
end

function ObjectPoolMixin:GetNumActive()
	return self.numActiveObjects;
end

function ObjectPoolMixin:EnumerateInactive()
	return ipairs(self.inactiveObjects);
end

---@return ObjectPoolMixin
function CreateObjectPool(creationFunc, resetterFunc)
	local objectPool = ObjectPoolMixin;-- removed CreateFromMixin(VAR), We do this for the type because mixin is strange...
	objectPool:OnLoad(creationFunc, resetterFunc);
	return objectPool;
end

---@class FramePoolMixin : ObjectPoolMixin
FramePoolMixin = ObjectPoolMixin;-- removed CreateFromMixin(VAR), We do this for the type because mixin is strange...

local function FramePoolFactory(framePool)
	return CreateFrame(framePool.frameType, nil, framePool.parent, framePool.frameTemplate);
end

function FramePoolMixin:OnLoad(frameType, parent, frameTemplate, resetterFunc)
	ObjectPoolMixin.OnLoad(self, FramePoolFactory, resetterFunc);
	self.frameType = frameType;
	self.parent = parent;
	self.frameTemplate = frameTemplate;
end

function FramePoolMixin:GetTemplate()
	return self.frameTemplate;
end

function FramePool_Hide(framePool, frame)
	frame:Hide();
end

function FramePool_HideAndClearAnchors(framePool, frame)
	frame:Hide();
	frame:ClearAllPoints();
end

---@return FramePoolMixin
function CreateFramePool(frameType, parent, frameTemplate, resetterFunc)
	local framePool = FramePoolMixin;-- removed CreateFromMixin(VAR), We do this for the type because mixin is strange...
	framePool:OnLoad(frameType, parent, frameTemplate, resetterFunc or FramePool_HideAndClearAnchors);
	return framePool;
end

---@class TexturePoolMixin : ObjectPoolMixin
TexturePoolMixin = ObjectPoolMixin;-- removed CreateFromMixin(VAR), We do this for the type because mixin is strange...

local function TexturePoolFactory(texturePool)
	return texturePool.parent:CreateTexture(nil, texturePool.layer, texturePool.textureTemplate, texturePool.subLayer);
end

function TexturePoolMixin:OnLoad(parent, layer, subLayer, textureTemplate, resetterFunc)
	ObjectPoolMixin.OnLoad(self, TexturePoolFactory, resetterFunc);
	self.parent = parent;
	self.layer = layer;
	self.subLayer = subLayer;
	self.textureTemplate = textureTemplate;
end

TexturePool_Hide = FramePool_Hide;
TexturePool_HideAndClearAnchors = FramePool_HideAndClearAnchors;

---@return TexturePoolMixin
function CreateTexturePool(parent, layer, subLayer, textureTemplate, resetterFunc)
	local texturePool = TexturePoolMixin;-- removed CreateFromMixin(VAR), We do this for the type because mixin is strange...
	texturePool:OnLoad(parent, layer, subLayer, textureTemplate, resetterFunc or TexturePool_HideAndClearAnchors);
	return texturePool;
end

---@class FontStringPoolMixin : ObjectPoolMixin
FontStringPoolMixin = ObjectPoolMixin;-- removed CreateFromMixin(VAR), We do this for the type because mixin is strange...

local function FontStringPoolFactory(fontStringPool)
	return fontStringPool.parent:CreateFontString(nil, fontStringPool.layer, fontStringPool.fontStringTemplate, fontStringPool.subLayer);
end

function FontStringPoolMixin:OnLoad(parent, layer, subLayer, fontStringTemplate, resetterFunc)
	ObjectPoolMixin.OnLoad(self, FontStringPoolFactory, resetterFunc);
	self.parent = parent;
	self.layer = layer;
	self.subLayer = subLayer;
	self.fontStringTemplate = fontStringTemplate;
end

FontStringPool_Hide = FramePool_Hide;
FontStringPool_HideAndClearAnchors = FramePool_HideAndClearAnchors;

---@return FontStringPoolMixin
function CreateFontStringPool(parent, layer, subLayer, fontStringTemplate, resetterFunc)
	local fontStringPool = FontStringPoolMixin;-- removed CreateFromMixin(VAR), We do this for the type because mixin is strange...
	fontStringPool:OnLoad(parent, layer, subLayer, fontStringTemplate, resetterFunc or FontStringPool_HideAndClearAnchors);
	return fontStringPool;
end

---@class ActorPoolMixin : ObjectPoolMixin
ActorPoolMixin = ObjectPoolMixin;-- removed CreateFromMixin(VAR), We do this for the type because mixin is strange...

local function ActorPoolFactory(actorPool)
	return actorPool.parent:CreateActor(nil, actorPool.actorTemplate);
end

function ActorPoolMixin:OnLoad(parent, actorTemplate, resetterFunc)
	ObjectPoolMixin.OnLoad(self, ActorPoolFactory, resetterFunc);
	self.parent = parent;
	self.actorTemplate = actorTemplate;
end

ActorPool_Hide = FramePool_Hide;
function ActorPool_HideAndClearModel(actorPool, actor)
	actor:ClearModel();
	actor:Hide();
end

---@return ActorPoolMixin
function CreateActorPool(parent, actorTemplate, resetterFunc)
	local actorPool = ActorPoolMixin;-- removed CreateFromMixin(VAR), We do this for the type because mixin is strange...
	actorPool:OnLoad(parent, actorTemplate, resetterFunc or ActorPool_HideAndClearModel);
	return actorPool;
end

PoolCollection = {};

function CreatePoolCollection()
	local poolCollection = PoolCollection;-- removed CreateFromMixin(VAR), We do this for the type because mixin is strange...
	poolCollection:OnLoad();
	return poolCollection;
end

function PoolCollection:OnLoad()
	self.pools = {};
end

function PoolCollection:CreatePool(frameType, parent, template, resetterFunc)
	assert(self:GetPool(template) == nil);
	local pool = CreateFramePool(frameType, parent, template, resetterFunc);
	self.pools[template] = pool;
	return pool;
end

function PoolCollection:GetPool(template)
	return self.pools[template];
end

function PoolCollection:Acquire(template)
	local pool = self:GetPool(template);
	assert(pool);
	return pool:Acquire();
end

function PoolCollection:Release(object)
	for _, pool in pairs(self.pools) do
		if pool:Release(object) then
			-- Found it! Just return
			return;
		end
	end

	-- Huh, we didn't find that object
	assert(false);
end

function PoolCollection:ReleaseAllByTemplate(template)
	local pool = self:GetPool(template);
	if pool then
		pool:ReleaseAll();
	end
end

function PoolCollection:ReleaseAll()
	for key, pool in pairs(self.pools) do
		pool:ReleaseAll();
	end
end

function PoolCollection:EnumerateActiveByTemplate(template)
	local pool = self:GetPool(template);
	if pool then
		return pool:EnumerateActive();
	end

	return nop;
end

function PoolCollection:EnumerateActive()
	local currentPoolKey, currentPool = next(self.pools, nil);
	local currentObject = nil;
	return function()
		if currentPool then
			currentObject = currentPool:GetNextActive(currentObject);
			while not currentObject do
				currentPoolKey, currentPool = next(self.pools, currentPoolKey);
				if currentPool then
					currentObject = currentPool:GetNextActive();
				else
					break;
				end
			end
		end

		return currentObject;
	end, nil;
end

function PoolCollection:GetNumActive()
	local count = 0;
	for _, pool in pairs(self.pools) do
		count = count + pool:GetNumActive();
	end
	return count;
end