--[[
Name: Tablet-2.0
Revision: $Rev: 14636 $
Author(s): ckknight (ckknight@gmail.com)
Website: http://ckknight.wowinterface.com/
Documentation: http://wiki.wowace.com/index.php/Tablet-2.0
SVN: http://svn.wowace.com/root/trunk/TabletLib/Tablet-2.0
Description: A library to provide an efficient, featureful tooltip-style display.
Dependencies: AceLibrary, (optional) Dewdrop-2.0
]]

local MAJOR_VERSION = "Tablet-2.0"
local MINOR_VERSION = "$Revision: 14636 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

local DEBUG = false


local SCROLL_UP = "Scroll up"
local SCROLL_DOWN = "Scroll down"
local HINT = "Hint"
local DETACH = "Detach"
local DETACH_DESC = "Detach the tablet from its source."
local SIZE = "Size"
local SIZE_DESC = "Scale the tablet."
local CLOSE_MENU = "Close menu"
local CLOSE_MENU_DESC = "Close the menu."
local COLOR = "Background color"
local COLOR_DESC = "Set the background color."
local LOCK = "Lock"
local LOCK_DESC = "Lock the tablet in its current position. Alt+Right-click for menu or Alt+drag to drag it when locked."

if GetLocale() == "deDE" then
	SCROLL_UP = "Hochscrollen"
	SCROLL_DOWN = "Runterscrollen"
	HINT = "Hinweis"
	DETACH = "L\195\182sen"
	DETACH_DESC = "L\195\182st den Tooltip aus seiner Verankerung."
	SIZE = "Gr\195\182\195\159e"
	SIZE_DESC = "Gr\195\182\195\159e des Tooltips \195\164ndern."
	CLOSE_MENU = "Menu schlie\195\159en"
	CLOSE_MENU_DESC = "Schlie\195\159t das Menu."
	COLOR = "Hintergrundfarbe"
	COLOR_DESC = "Hintergrundfarbe setzen."
	LOCK = "Sperren"
	LOCK_DESC = "Sperrt die aktuelle Position vom Tooltip. Alt+Rechts-klick f\195\188rs Men\195\188 oder Alt+Verschieben f\195\188rs verschieben wenn es gesperrt ist."
elseif  GetLocale() == "koKR" then
	SCROLL_UP = "위로 스크롤"
	SCROLL_DOWN = "아래로 스크롤"
	HINT = "힌트"
	DETACH = "분리"
	DETACH_DESC = "테이블을 분리합니다."
	SIZE = "크기"
	SIZE_DESC = "테이블의 크기입니다."
	CLOSE_MENU = "메뉴 닫기"
	CLOSE_MENU_DESC = "메뉴를 닫습니다."
	COLOR = "배경 색상"
	COLOR_DESC = "배경 색상을 설정합니다."
	LOCK = "고정"
	LOCK_DESC = "현재 위치에 테이블을 고정합니다. 알트+우클릭 : 메뉴열기, 알트+드래그 : 고정된것을 드래그합니다."
elseif GetLocale() == "zhCN" then
	SCROLL_UP = "向上翻转"
	SCROLL_DOWN = "向上翻转"
	HINT = "提示"
	DETACH = "分离"
	DETACH_DESC = "分离菜单为独立提示."
	SIZE = "尺寸"
	SIZE_DESC = "缩放菜单显示尺寸."
	CLOSE_MENU = "关闭菜单"
	CLOSE_MENU_DESC = "关闭菜单"
	COLOR = "背景颜色"
	COLOR_DESC = "设置菜单背景颜色."
	LOCK = "锁定"
	LOCK_DESC = "锁定菜单当前位置. alt+右键 将显示选项, alt+拖动 可以移动已锁定的菜单."
elseif GetLocale() == "zhTW" then
	SCROLL_UP = "向上翻轉"
	SCROLL_DOWN = "向上翻轉"
	HINT = "提示"
	DETACH = "分離"
	DETACH_DESC = "分離選單為獨立提示。"
	SIZE = "尺寸"
	SIZE_DESC = "縮放選單顯示尺寸。"
	CLOSE_MENU = "關閉選單"
	CLOSE_MENU_DESC = "關閉選單"
	COLOR = "背景顏色"
	COLOR_DESC = "設置選單背景顏色。"
	LOCK = "鎖定"
	LOCK_DESC = "鎖定選單目前位置. Alt+右鍵 將顯示選項，Alt+拖動 可以移動已鎖定的選單。"
elseif  GetLocale() == "frFR" then
	SCROLL_UP = "Parcourir vers le haut"
	SCROLL_DOWN = "Parcourir vers le bas"
	HINT = "Astuce"
	DETACH = "D\195\169tacher"
	DETACH_DESC = "Permet de d\195\169tacher le tableau de sa source."
	SIZE = "Taille"
	SIZE_DESC = "Permet de changer l'\195\169chelle du tableau."
	CLOSE_MENU = "Fermer le menu"
	CLOSE_MENU_DESC = "Ferme ce menu."
	COLOR = "Couleur du fond"
	COLOR_DESC = "Permet de d\195\169finir la couleur du fond."
	LOCK = "Bloquer"
	LOCK_DESC = "Bloque le tableau \195\160 sa position actuelle. Alt+clic-droit pour le menu ou Alt+glisser pour le d\195\169placer quand il est bloqu\195\169."
end

local start = GetTime()
local wrap
local GetProfileInfo
if DEBUG then
	local tree = {}
	local treeMemories = {}
	local treeTimes = {}
	local memories = {}
	local times = {}
	function wrap(value, name)
		if type(value) == "function" then
			local oldFunction = value
			memories[name] = 0
			times[name] = 0
			return function(self, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30, a31, a32, a33, a34, a35, a36, a37, a38, a39, a40, a41, a42, a43, a44, a45, a46, a47, a48, a49, a50, a51, a52, a53, a54, a55, a56, a57, a58, a59, a60)
				local pos = table.getn(tree)
				table.insert(tree, name)
				table.insert(treeMemories, 0)
				table.insert(treeTimes, 0)
				local t, mem = GetTime(), gcinfo()
				local r1, r2, r3, r4, r5, r6, r7, r8 = oldFunction(self, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30, a31, a32, a33, a34, a35, a36, a37, a38, a39, a40, a41, a42, a43, a44, a45, a46, a47, a48, a49, a50, a51, a52, a53, a54, a55, a56, a57, a58, a59, a60)
				mem, t = gcinfo() - mem, GetTime() - t
				if pos > 0 then
					treeMemories[pos] = treeMemories[pos] + mem
					treeTimes[pos] = treeTimes[pos] + t
				end
				local otherMem = table.remove(treeMemories)
				if mem - otherMem > 0 then
					memories[name] = memories[name] + mem - otherMem
				end
				times[name] = times[name] + t - table.remove(treeTimes)
				table.remove(tree)
				return r1, r2, r3, r4, r5, r6, r7, r8
			end
		end
	end

	function GetProfileInfo()
		return GetTime() - start, times, memories
	end
else
	function wrap(value)
		return value
	end
end

local MIN_TOOLTIP_SIZE = 200
local Tablet = {}
local function getsecond(_, value)
	return value
end
local Dewdrop
local sekeys
local CleanCategoryPool
local pool = {}

local table_setn
do
	local version = GetBuildInfo()
	if string.find(version, "^2%.") then
		-- 2.0.0
		table_setn = function() end
	else
		table_setn = table.setn
	end
end

local function del(t)
	if t then
		for k in pairs(t) do
			t[k] = nil
		end
		setmetatable(t, nil)
		table_setn(t, 0)
		table.insert(pool, t)
	end
end

local new

local function copy(parent)
	local t
	if table.getn(pool) > 0 then
		t = table.remove(pool)
	else
		t = {}
	end
	if parent then
		for k,v in pairs(parent) do
			t[k] = v
		end
		table_setn(t, table.getn(parent))
		setmetatable(t, getmetatable(parent))
	end
	return t
end

function new(k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20, k21, v21, k22, v22, k23, v23, k24, v24, k25, v25, k26, v26, k27, v27, k28, v28, k29, v29, k30, v30)
	local t
	if table.getn(pool) > 0 then
		t = table.remove(pool)
	else
		t = {}
	end
	if k1 then t[k1] = v1
	if k2 then t[k2] = v2
	if k3 then t[k3] = v3
	if k4 then t[k4] = v4
	if k5 then t[k5] = v5
	if k6 then t[k6] = v6
	if k7 then t[k7] = v7
	if k8 then t[k8] = v8
	if k9 then t[k9] = v9
	if k10 then t[k10] = v10
	if k11 then t[k11] = v11
	if k12 then t[k12] = v12
	if k13 then t[k13] = v13
	if k14 then t[k14] = v14
	if k15 then t[k15] = v15
	if k16 then t[k16] = v16
	if k17 then t[k17] = v17
	if k18 then t[k18] = v18
	if k19 then t[k19] = v19
	if k20 then t[k20] = v20
	if k21 then t[k21] = v21
	if k22 then t[k22] = v22
	if k23 then t[k23] = v23
	if k24 then t[k24] = v24
	if k25 then t[k25] = v25
	if k26 then t[k26] = v26
	if k27 then t[k27] = v27
	if k28 then t[k28] = v28
	if k29 then t[k29] = v29
	if k30 then t[k30] = v30
	end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end
	return t
end
local tmp
tmp = setmetatable({}, {__index = function(self, key)
	local t = {}
	tmp[key] = function(k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20, k21, v21, k22, v22, k23, v23, k24, v24, k25, v25, k26, v26, k27, v27, k28, v28, k29, v29, k30, v30)
		for k in pairs(t) do
			t[k] = nil
		end
		if k1 then t[k1] = v1
		if k2 then t[k2] = v2
		if k3 then t[k3] = v3
		if k4 then t[k4] = v4
		if k5 then t[k5] = v5
		if k6 then t[k6] = v6
		if k7 then t[k7] = v7
		if k8 then t[k8] = v8
		if k9 then t[k9] = v9
		if k10 then t[k10] = v10
		if k11 then t[k11] = v11
		if k12 then t[k12] = v12
		if k13 then t[k13] = v13
		if k14 then t[k14] = v14
		if k15 then t[k15] = v15
		if k16 then t[k16] = v16
		if k17 then t[k17] = v17
		if k18 then t[k18] = v18
		if k19 then t[k19] = v19
		if k20 then t[k20] = v20
		if k21 then t[k21] = v21
		if k22 then t[k22] = v22
		if k23 then t[k23] = v23
		if k24 then t[k24] = v24
		if k25 then t[k25] = v25
		if k26 then t[k26] = v26
		if k27 then t[k27] = v27
		if k28 then t[k28] = v28
		if k29 then t[k29] = v29
		if k30 then t[k30] = v30
		end end end end end end end end end end end end end end end end end end end end end end end end end end end end end end
		return t
	end
	return tmp[key]
end})

local headerSize, normalSize
if GameTooltipHeaderText then
	_,headerSize = GameTooltipHeaderText:GetFont()
else
	headerSize = 14
end
if GameTooltipText then
	_,normalSize = GameTooltipText:GetFont()
else
	normalSize = 12
end
local tooltip
local testString
local TabletData = {}
local Category = {}
local Line = {}
do
	local TabletData_mt = { __index = TabletData }
	function TabletData:new(tablet)
		if not testString then
			testString = UIParent:CreateFontString()
			testString:Hide()
		end
		local self = new()
		self.categories = new()
		self.id = 0
		self.width = 0--(MIN_TOOLTIP_SIZE - 20)*tablet.fontSizePercent
		self.tablet = tablet
		self.title = "Title"
		setmetatable(self, TabletData_mt)
		return self
	end

	function TabletData:del()
		for k, v in ipairs(self.categories) do
			v:del()
		end
		del(self.categories)
		del(self)
	end

	function TabletData:Display()
		if self.tablet == tooltip or self.tablet.registration.showTitleWhenDetached then
			local info = new(
				'hideBlankLine', true,
				'text', self.title,
				'justify', "CENTER",
				'font', GameTooltipHeaderText,
				'isTitle', true
			)
			self:AddCategory(info, 1)
			del(info)
		end
		if self.tablet == tooltip or self.tablet.registration.showHintWhenDetached then
			if self.hint then
				self:AddCategory(nil):AddLine(
					'text', HINT .. ": " .. self.hint,
					'textR', 0,
					'textG', 1,
					'textB', 0,
					'wrap', true
				)
			end
		end

		local tabletData = self.tabletData
		local width
		for k, v in ipairs(self.categories) do
			if v.columns <= 2 then
				width = v.x1
			else
				width = v.x1 + v.x2 + v.x3 + v.x4 + v.x5 + v.x6 + (v.columns - 1) * 20
			end
			if self.width < width then
				self.width = width
			end
		end

		local good = false
		local lastTitle = true
		for k, v in ipairs(self.categories) do
			if lastTitle then
				v.hideBlankLine = true
				lastTitle = false
			end
			if v:Display(self.tablet) then
				good = true
			end
			if v.isTitle then
				lastTitle = true
			end
		end
		if not good then
			if self.tablet == tooltip or not self.tablet.registration.hideWhenEmpty then
				local width
				local info = new(
					'hideBlankLine', true,
					'text', self.title,
					'justify', "CENTER",
					'font', GameTooltipHeaderText,
					'isTitle', true
				)
				local cat = self:AddCategory(info)
				del(info)
				self.width = self.categories[table.getn(self.categories)].x1
				cat:Display(self.tablet)
			else
				self.tablet:__Hide()
				self.tablet.tmpHidden = true
			end
		else
			self.tablet:__Show()
			self.tablet.tmpHidden = nil
		end
	end

	function TabletData:AddCategory(info, index)
		local made = false
		if not info then
			made = true
			info = new()
		end
		local cat = Category:new(self, info)
		if index then
			table.insert(self.categories, index, cat)
		else
			table.insert(self.categories, cat)
		end
		if made then
			del(info)
		end
		return cat
	end

	function TabletData:SetHint(hint)
		self.hint = hint
	end

	function TabletData:SetTitle(title)
		self.title = title or "Title"
	end
end
do
	local Category_mt = { __index = Category }
	function Category:new(tabletData, info, superCategory)
		local self = copy(info)
		if superCategory and not self.noInherit then
			self.superCategory = superCategory.superCategory
			for k, v in pairs(superCategory) do
				if string.find(k, "^child_") then
					local k = strsub(k, 7)
					if self[k] == nil then
						self[k] = v
					end
				end
			end
			self.columns = superCategory.columns
		else
			self.superCategory = self
		end
		self.tabletData = tabletData
		self.lines = new()
		if not self.columns then
			self.columns = 1
		end
		self.x1 = 0
		self.x2 = 0
		self.x3 = 0
		self.x4 = 0
		self.x5 = 0
		self.x6 = 0
		setmetatable(self, Category_mt)
		self.lastWasTitle = nil
		if self.text or self.text2 or self.text3 or self.text4 or self.text5 or self.text6 then
			local x = new(
				'category', category,
				'text', self.text,
				'textR', self.textR or 1,
				'textG', self.textG or 1,
				'textB', self.textB or 1,
				'fakeChild', true,
				'func', self.func,
				'arg1', info.arg1,
				'arg2', self.arg2,
				'arg3', self.arg3,
				'hasCheck', self.hasCheck,
				'checked', self.checked,
				'checkIcon', self.checkIcon,
				'isRadio', self.isRadio,
				'font', self.font,
				'size', self.size,
				'wrap', self.wrap,
				'catStart', true,
				'indentation', self.indentation,
				'noInherit', true,
				'justify', self.justify,
				'justify2', self.justify2,
				'justify3', self.justify3,
				'justify4', self.justify4,
				'justify5', self.justify5,
				'justify6', self.justify6
			)
			if self.isTitle then
				x.textR = self.textR or 1
				x.textG = self.textG or 0.823529
				x.textB = self.textB or 0
			else
				x.textR = self.textR or 1
				x.textG = self.textG or 1
				x.textB = self.textB or 1
			end
			x.text2 = self.text2
			x.text3 = self.text3
			x.text4 = self.text4
			x.text5 = self.text5
			x.text6 = self.text6
			x.text2R = self.text2R or self.textR2 or 1
			x.text2G = self.text2G or self.textG2 or 1
			x.text2B = self.text2B or self.textB2 or 1
			x.text3R = self.text3R or self.textR3 or 1
			x.text3G = self.text3G or self.textG3 or 1
			x.text3B = self.text3B or self.textB3 or 1
			x.text4R = self.text4R or self.textR4 or 1
			x.text4G = self.text4G or self.textG4 or 1
			x.text4B = self.text4B or self.textB4 or 1
			x.text5R = self.text5R or self.textR5 or 1
			x.text5G = self.text5G or self.textG5 or 1
			x.text5B = self.text5B or self.textB5 or 1
			x.text6R = self.text6R or self.textR6 or 1
			x.text6G = self.text6G or self.textG6 or 1
			x.text6B = self.text6B or self.textB6 or 1
			x.font2 = self.font2
			x.font3 = self.font3
			x.font4 = self.font4
			x.font5 = self.font5
			x.font6 = self.font6
			x.size2 = self.size2
			x.size3 = self.size3
			x.size4 = self.size4
			x.size5 = self.size5
			x.size6 = self.size6
			self:AddLine(x)
			del(x)
			self.lastWasTitle = true
		end
		return self
	end

	function Category:del()
		local prev = garbageLine
		for k, v in pairs(self.lines) do
			v:del()
		end
		del(self.lines)
		del(self)
	end

	function Category:AddLine(k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20, k21, v21, k22, v22, k23, v23, k24, v24, k25, v25, k26, v26, k27, v27, k28, v28, k29, v29, k30, v30)
		self.lastWasTitle = nil
		local line
		if type(k1) == "table" then
			Line:new(self, k1, v1)
		else
			local info = new(k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20, k21, v21, k22, v22, k23, v23, k24, v24, k25, v25, k26, v26, k27, v27, k28, v28, k29, v29, k30, v30)
			Line:new(self, info)
			del(info)
		end
	end

	function Category:AddCategory(k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20, k21, v21, k22, v22, k23, v23, k24, v24, k25, v25, k26, v26, k27, v27, k28, v28, k29, v29, k30, v30)
		local lastWasTitle = self.lastWasTitle
		self.lastWasTitle = nil
		local info
		if type(k1) == "table" then
			info = k1
		else
			info = new(k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20, k21, v21, k22, v22, k23, v23, k24, v24, k25, v25, k26, v26, k27, v27, k28, v28, k29, v29, k30, v30)
		end
		if lastWasTitle or table.getn(self.lines) == 0 then
			info.hideBlankLine = true
		end
		local cat = Category:new(self.tabletData, info, self)
		table.insert(self.lines, cat)
		return cat
	end

	function Category:HasChildren()
		local hasChildren = false
		for k, v in ipairs(self.lines) do
			if v.HasChildren then
				if v:HasChildren() then
					return true
				end
			end
			if not v.fakeChild then
				return true
			end
		end
		return false
	end

	local lastWasTitle = false
	function Category:Display(tablet)
		if not self.isTitle and not self.showWithoutChildren and not self:HasChildren() then
			return false
		end
		if not self.hideBlankLine and not lastWasTitle then
			local info = new(
				'blank', true,
				'fakeChild', true
			)
			self:AddLine(info, 1)
			del(info)
		end
		local good = false
		if table.getn(self.lines) > 0 then
			self.tabletData.id = self.tabletData.id + 1
			self.id = self.tabletData.id
			for k, v in ipairs(self.lines) do
				if v:Display(tablet) then
					good = true
				end
			end
		end
		lastWasTitle = self.isTitle
		return good
	end
end
do
	local Line_mt = { __index = Line }
	function Line:new(category, info, position)
		local self = copy(info)
		if not info.noInherit then
			for k, v in pairs(category) do
				if string.find(k, "^child_") then
					local k = strsub(k, 7)
					if self[k] == nil then
						self[k] = v
					end
				end
			end
		end
		self.category = category
		if position then
			table.insert(category.lines, position, self)
		else
			table.insert(category.lines, self)
		end
		setmetatable(self, Line_mt)
		local columns = category.columns
		if columns == 1 then
			if not self.justify then
				self.justify = "LEFT"
			end
		elseif columns == 2 then
			self.justify = "LEFT"
			self.justify2 = "RIGHT"
			if self.wrap then
				self.wrap2 = false
			end
		elseif columns == 3 then
			if not self.justify then
				self.justify = "LEFT"
			end
			if not self.justify2 then
				self.justify2 = "CENTER"
			end
			if not self.justify3 then
				self.justify3 = "RIGHT"
			end
			if self.wrap then
				self.wrap2 = false
				self.wrap3 = false
			elseif self.wrap2 then
				self.wrap3 = false
			end
		elseif columns == 4 then
			if not self.justify then
				self.justify = "LEFT"
			end
			if not self.justify2 then
				self.justify2 = "CENTER"
			end
			if not self.justify3 then
				self.justify3 = "CENTER"
			end
			if not self.justify4 then
				self.justify4 = "RIGHT"
			end
			if self.wrap then
				self.wrap2 = false
				self.wrap3 = false
				self.wrap4 = false
			elseif self.wrap2 then
				self.wrap3 = false
				self.wrap4 = false
			elseif self.wrap3 then
				self.wrap4 = false
			end
		elseif columns == 5 then
			if not self.justify then
				self.justify = "LEFT"
			end
			if not self.justify2 then
				self.justify2 = "CENTER"
			end
			if not self.justify3 then
				self.justify3 = "CENTER"
			end
			if not self.justify4 then
				self.justify4 = "CENTER"
			end
			if not self.justify5 then
				self.justify5 = "RIGHT"
			end
			if self.wrap then
				self.wrap2 = false
				self.wrap3 = false
				self.wrap4 = false
				self.wrap5 = false
			elseif self.wrap2 then
				self.wrap3 = false
				self.wrap4 = false
				self.wrap5 = false
			elseif self.wrap3 then
				self.wrap4 = false
				self.wrap5 = false
			elseif self.wrap4 then
				self.wrap5 = false
			end
		elseif columns == 6 then
			if not self.justify then
				self.justify = "LEFT"
			end
			if not self.justify2 then
				self.justify2 = "CENTER"
			end
			if not self.justify3 then
				self.justify3 = "CENTER"
			end
			if not self.justify4 then
				self.justify4 = "CENTER"
			end
			if not self.justify5 then
				self.justify5 = "CENTER"
			end
			if not self.justify6 then
				self.justify6 = "RIGHT"
			end
			if self.wrap then
				self.wrap2 = false
				self.wrap3 = false
				self.wrap4 = false
				self.wrap5 = false
				self.wrap6 = false
			elseif self.wrap2 then
				self.wrap3 = false
				self.wrap4 = false
				self.wrap5 = false
				self.wrap6 = false
			elseif self.wrap3 then
				self.wrap4 = false
				self.wrap5 = false
				self.wrap6 = false
			elseif self.wrap4 then
				self.wrap5 = false
				self.wrap6 = false
			elseif self.wrap5 then
				self.wrap6 = false
			end
		end
		if self.textR2 then
			self.text2R, self.textR2 = self.text2R or self.textR2
			self.text2G, self.textG2 = self.text2G or self.textG2
			self.text2B, self.textB2 = self.text2B or self.textB2
			if self.textR3 then
				self.text3R, self.textR3 = self.text3R or self.textR3
				self.text3G, self.textG3 = self.text3G or self.textG3
				self.text3B, self.textB3 = self.text3B or self.textB3
				if self.textR4 then
					self.text4R, self.textR4 = self.text4R or self.textR4
					self.text4G, self.textG4 = self.text4G or self.textG4
					self.text4B, self.textB4 = self.text4B or self.textB4
					if self.textR5 then
						self.text5R, self.textR5 = self.text5R or self.textR5
						self.text5G, self.textG5 = self.text5G or self.textG5
						self.text5B, self.textB5 = self.text5B or self.textB5
						if self.textR5 then
							self.text6R, self.textR6 = self.text6R or self.textR6
							self.text6G, self.textG6 = self.text6G or self.textG6
							self.text6B, self.textB6 = self.text6B or self.textB6
						end
					end
				end
			end
		end
		if not self.indentation or self.indentation < 0 then
			self.indentation = 0
		end
		if not self.font then
			self.font = GameTooltipText
		end
		if not self.font2 then
			self.font2 = self.font
		end
		if not self.font3 then
			self.font3 = self.font
		end
		if not self.font4 then
			self.font4 = self.font
		end
		if not self.font5 then
			self.font5 = self.font
		end
		if not self.font6 then
			self.font6 = self.font
		end
		if not self.size then
			_,self.size = self.font:GetFont()
		end
		if not self.size2 then
			_,self.size2 = self.font2:GetFont()
		end
		if not self.size3 then
			_,self.size3 = self.font3:GetFont()
		end
		if not self.size4 then
			_,self.size4 = self.font4:GetFont()
		end
		if not self.size5 then
			_,self.size5 = self.font5:GetFont()
		end
		if not self.size6 then
			_,self.size6 = self.font6:GetFont()
		end

		local fontSizePercent = category.tabletData.tablet.fontSizePercent
		local w = 0
		self.checkWidth = 0
		if self.text then
			if not self.wrap then
				testString:SetWidth(0)
				testString:SetFontObject(self.font)
				local font,_,flags = testString:GetFont()
				testString:SetFont(font, self.size * fontSizePercent, flags)
				testString:SetText(self.text)
				local checkWidth = self.hasCheck and self.size * fontSizePercent or 0
				self.checkWidth = checkWidth
				w = testString:GetWidth() + self.indentation * fontSizePercent + checkWidth
				if category.superCategory.x1 < w then
					category.superCategory.x1 = w
				end
			else
				if columns == 1 then
					testString:SetWidth(0)
					testString:SetFontObject(self.font)
					local font,_,flags = testString:GetFont()
					testString:SetFont(font, self.size * fontSizePercent, flags)
					testString:SetText(self.text)
					local checkWidth = self.hasCheck and self.size * fontSizePercent or 0
					self.checkWidth = checkWidth
					w = testString:GetWidth() + self.indentation * fontSizePercent + checkWidth
					if w > (MIN_TOOLTIP_SIZE - 20) * fontSizePercent then
						w = (MIN_TOOLTIP_SIZE - 20) * fontSizePercent
					end
				else
					w = MIN_TOOLTIP_SIZE * fontSizePercent / 2
				end
				if category.superCategory.x1 < w then
					category.superCategory.x1 = w
				end
			end
		end
		if columns == 2 and self.text2 then
			if not self.wrap2 then
				testString:SetWidth(0)
				testString:SetFontObject(self.font2)
				local font,_,flags = testString:GetFont()
				testString:SetFont(font, self.size2 * fontSizePercent, flags)
				testString:SetText(self.text2)
				w = w + 40 * fontSizePercent + testString:GetWidth()
				if category.superCategory.x1 < w then
					category.superCategory.x1 = w
				end
			else
				w = w + 40 * fontSizePercent + MIN_TOOLTIP_SIZE * fontSizePercent / 2
				if category.superCategory.x1 < w then
					category.superCategory.x1 = w
				end
			end
		elseif columns >= 3 then
			if self.text2 then
				if not self.wrap2 then
					testString:SetWidth(0)
					testString:SetFontObject(self.font2)
					local font,_,flags = testString:GetFont()
					testString:SetFont(font, self.size2 * fontSizePercent, flags)
					testString:SetText(self.text2)
					local w = testString:GetWidth()
					if category.superCategory.x2 < w then
						category.superCategory.x2 = w
					end
				else
					local w = MIN_TOOLTIP_SIZE / 2
					if category.superCategory.x2 < w then
						category.superCategory.x2 = w
					end
				end
			end
			if self.text3 then
				if not self.wrap3 then
					testString:SetWidth(0)
					testString:SetFontObject(self.font3)
					local font,_,flags = testString:GetFont()
					testString:SetFont(font, self.size3 * fontSizePercent, flags)
					testString:SetText(self.text3)
					local w = testString:GetWidth()
					if category.superCategory.x3 < w then
						category.superCategory.x3 = w
					end
				else
					local w = MIN_TOOLTIP_SIZE / 2
					if category.superCategory.x3 < w then
						category.superCategory.x3 = w
					end
				end
			end
			if columns >= 4 then
				if self.text4 then
					if not self.wrap4 then
						testString:SetWidth(0)
						testString:SetFontObject(self.font4)
						local font,_,flags = testString:GetFont()
						testString:SetFont(font, self.size4 * fontSizePercent, flags)
						testString:SetText(self.text4)
						w = testString:GetWidth()
						if category.superCategory.x4 < w then
							category.superCategory.x4 = w
						end
					else
						local w = MIN_TOOLTIP_SIZE / 2
						if category.superCategory.x4 < w then
							category.superCategory.x4 = w
						end
					end
				end
				if columns >= 5 then
					if self.text5 then
						if not self.wrap5 then
							testString:SetWidth(0)
							testString:SetFontObject(self.font5)
							local font,_,flags = testString:GetFont()
							testString:SetFont(font, self.size5 * fontSizePercent, flags)
							testString:SetText(self.text5)
							w = testString:GetWidth()
							if category.superCategory.x5 < w then
								category.superCategory.x5 = w
							end
						else
							local w = MIN_TOOLTIP_SIZE / 2
							if category.superCategory.x5 < w then
								category.superCategory.x5 = w
							end
						end
					end
					if columns >= 6 then
						if self.text6 then
							if not self.wrap6 then
								testString:SetWidth(0)
								testString:SetFontObject(self.font6)
								local font,_,flags = testString:GetFont()
								testString:SetFont(font, self.size6 * fontSizePercent, flags)
								testString:SetText(self.text6)
								w = testString:GetWidth()
								if category.superCategory.x6 < w then
									category.superCategory.x6 = w
								end
							else
								local w = MIN_TOOLTIP_SIZE / 2
								if category.superCategory.x6 < w then
									category.superCategory.x6 = w
								end
							end
						end
					end
				end
			end
		end
		return self
	end

	function Line:del()
		del(self)
	end

	function Line:Display(tablet)
		tablet:AddLine(self)
		return true
	end
end

local function button_OnEnter()
	if type(this.self:GetScript("OnEnter")) == "function" then
		this.self:GetScript("OnEnter")()
	end
	this.highlight:Show()
end

local function button_OnLeave()
	if type(this.self:GetScript("OnLeave")) == "function" then
		this.self:GetScript("OnLeave")()
	end
	this.highlight:Hide()
end

local function NewLine(self)
	if self.maxLines <= self.numLines then
		self.maxLines = self.maxLines + 1
		local button = CreateFrame("Button", nil, self)
		button.indentation = 0
		local check = button:CreateTexture(nil, "ARTWORK")
		local left = button:CreateFontString(nil, "ARTWORK")
		local right = button:CreateFontString(nil, "ARTWORK")
		local third = button:CreateFontString(nil, "ARTWORK")
		local fourth = button:CreateFontString(nil, "ARTWORK")
		local fifth = button:CreateFontString(nil, "ARTWORK")
		local sixth = button:CreateFontString(nil, "ARTWORK")
		local highlight = button:CreateTexture(nil, "BACKGROUND")
		highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		button.highlight = highlight
		highlight:SetBlendMode("ADD")
		highlight:SetAllPoints(button)
		highlight:Hide()
		table.insert(self.buttons, button)
		table.insert(self.checks, check)
		table.insert(self.lefts, left)
		table.insert(self.rights, right)
		table.insert(self.thirds, third)
		table.insert(self.fourths, fourth)
		table.insert(self.fifths, fifth)
		table.insert(self.sixths, sixth)
		left:SetWidth(0)
		if self.maxLines == 1 then
			left:SetFontObject(GameTooltipHeaderText)
			right:SetFontObject(GameTooltipHeaderText)
			third:SetFontObject(GameTooltipHeaderText)
			fourth:SetFontObject(GameTooltipHeaderText)
			fifth:SetFontObject(GameTooltipHeaderText)
			sixth:SetFontObject(GameTooltipHeaderText)
			left:SetJustifyH("CENTER")
			button:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -10)
		else
			left:SetFontObject(GameTooltipText)
			right:SetFontObject(GameTooltipText)
			third:SetFontObject(GameTooltipText)
			fourth:SetFontObject(GameTooltipText)
			fifth:SetFontObject(GameTooltipText)
			sixth:SetFontObject(GameTooltipText)
			button:SetPoint("TOPLEFT", self.buttons[self.maxLines - 1], "BOTTOMLEFT", 0, -2)
		end
		button:SetScript("OnEnter", button_OnEnter)
		button:SetScript("OnLeave", button_OnLeave)
		button.check = check
		button.self = self
		button:SetPoint("RIGHT", self, "RIGHT", -12, 0)
		check.shown = false
		check:SetPoint("TOPLEFT", button, "TOPLEFT")
		left:SetPoint("TOPLEFT", check, "TOPLEFT")
		right:SetPoint("TOPLEFT", left, "TOPRIGHT", 40 * self.fontSizePercent, 0)
		third:SetPoint("TOPLEFT", right, "TOPRIGHT", 20 * self.fontSizePercent, 0)
		fourth:SetPoint("TOPLEFT", third, "TOPRIGHT", 20 * self.fontSizePercent, 0)
		fifth:SetPoint("TOPLEFT", fourth, "TOPRIGHT", 20 * self.fontSizePercent, 0)
		sixth:SetPoint("TOPLEFT", fifth, "TOPRIGHT", 20 * self.fontSizePercent, 0)
		right:SetJustifyH("RIGHT")
		local _,size = GameTooltipText:GetFont()
		check:SetHeight(size * 1.5)
		check:SetWidth(size * 1.5)
		check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
		check:SetAlpha(0)
		if not button.clicked then
			button:SetScript("OnMouseWheel", self:GetScript("OnMouseWheel"))
			button:EnableMouseWheel(true)
			button:Hide()
		end
		check:Show()
		left:Hide()
		right:Hide()
		third:Hide()
		fourth:Hide()
		fifth:Hide()
		sixth:Hide()
	end
end
NewLine = wrap(NewLine, "NewLine")

local function GetMaxLinesPerScreen(self)
	if self == tooltip then
		return floor(50 / self.fontSizePercent)
	else
		return floor(30 / self.fontSizePercent)
	end
end
GetMaxLinesPerScreen = wrap(GetMaxLinesPerScreen, "GetMaxLinesPerScreen")

local detachedTooltips = {}
local AcquireDetachedFrame, ReleaseDetachedFrame
local function AcquireFrame(self, registration, data, detachedData)
	if not detachedData then
		detachedData = data
	end
	if tooltip then
		tooltip.data = data
		tooltip.detachedData = detachedData
		local fontSizePercent = tooltip.data and tooltip.data.fontSizePercent or 1
		local transparency = tooltip.data and tooltip.data.transparency or 0.75
		local r = tooltip.data and tooltip.data.r or 0
		local g = tooltip.data and tooltip.data.g or 0
		local b = tooltip.data and tooltip.data.b or 0
		tooltip:SetFontSizePercent(fontSizePercent)
		tooltip:SetTransparency(transparency)
		tooltip:SetColor(r, g, b)
	else
		tooltip = CreateFrame("Frame", "Tablet20Frame", UIParent)
		self.tooltip = tooltip
		tooltip.data = data
		tooltip.detachedData = detachedData
		tooltip:EnableMouse(true)
		tooltip:EnableMouseWheel(true)
		tooltip:SetFrameStrata("TOOLTIP")
		tooltip:SetFrameLevel(10)
		local backdrop = new(
			'bgFile', "Interface\\Buttons\\WHITE8X8",
			'edgeFile', "Interface\\Tooltips\\UI-Tooltip-Border",
			'tile', true,
			'tileSize', 16,
			'edgeSize', 16,
			'insets', new(
				'left', 5,
				'right', 5,
				'top', 5,
				'bottom', 5
			)
		)
		tooltip:SetBackdrop(backdrop)
		del(backdrop.insets)
		del(backdrop)
		tooltip:SetBackdropColor(0, 0, 0, 1)

		tooltip.numLines = 0
		tooltip.owner = nil
		tooltip.fontSizePercent = tooltip.data and tooltip.data.fontSizePercent or 1
		tooltip.maxLines = 0
		tooltip.buttons = {}
		tooltip.checks = {}
		tooltip.lefts = {}
		tooltip.rights = {}
		tooltip.thirds = {}
		tooltip.fourths = {}
		tooltip.fifths = {}
		tooltip.sixths = {}
		tooltip.transparency = tooltip.data and tooltip.data.transparency or 0.75
		tooltip:SetBackdropColor(0, 0, 0, tooltip.transparency)
		tooltip:SetBackdropBorderColor(1, 1, 1, tooltip.transparency)
		tooltip.scroll = 0

		tooltip:SetScript("OnUpdate", function()
			if not tooltip.updating and not tooltip.enteredFrame then
				tooltip.scroll = 0
				tooltip:Hide()
				tooltip.registration.tooltip = nil
				tooltip.registration = nil
			end
		end)

		tooltip:SetScript("OnEnter", function()
			if tooltip.clickable then
				tooltip.enteredFrame = true
			end
		end)

		tooltip:SetScript("OnLeave", function()
			if not tooltip.updating then
				tooltip.enteredFrame = false
			end
		end)

		tooltip:SetScript("OnMouseWheel", function()
			tooltip.updating = true
			tooltip:Scroll(arg1 < 0)
			tooltip.updating = false
		end)

		NewLine(tooltip)

		tooltip.scrollUp = tooltip:CreateFontString(nil, "ARTWORK")
		tooltip.scrollUp:SetPoint("TOPLEFT", tooltip.buttons[1], "BOTTOMLEFT", 0, -2)
		tooltip.scrollUp:SetPoint("RIGHT", tooltip, "RIGHT", 0, -10)
		tooltip.scrollUp:SetFontObject(GameTooltipText)
		tooltip.scrollUp:Hide()
		local font,_,flags = tooltip.scrollUp:GetFont()
		tooltip.scrollUp:SetFont(font, normalSize * tooltip.fontSizePercent, flags)
		tooltip.scrollUp:SetJustifyH("CENTER")
		tooltip.scrollUp:SetTextColor(1, 0.823529, 0)
		tooltip.scrollUp:SetText(" ")

		tooltip.scrollDown = tooltip:CreateFontString(nil, "ARTWORK")
		tooltip.scrollDown:SetPoint("TOPLEFT", tooltip.buttons[1], "BOTTOMLEFT", 0, -2)
		tooltip.scrollDown:SetPoint("RIGHT", tooltip, "RIGHT", 0, -10)
		tooltip.scrollDown:SetFontObject(GameTooltipText)
		tooltip.scrollDown:Hide()
		local font,_,flags = tooltip.scrollUp:GetFont()
		tooltip.scrollDown:SetFont(font, normalSize * tooltip.fontSizePercent, flags)
		tooltip.scrollDown:SetJustifyH("CENTER")
		tooltip.scrollDown:SetTextColor(1, 0.823529, 0)
		tooltip.scrollDown:SetText(" ")

		function tooltip:SetOwner(o)
			self:Hide(o)
			self.owner = o
		end
		tooltip.SetOwner = wrap(tooltip.SetOwner, "tooltip:SetOwner")

		function tooltip:IsOwned(o)
			return self.owner == o
		end
		tooltip.IsOwned = wrap(tooltip.IsOwned, "tooltip:IsOwned")

		function tooltip:ClearLines(hide)
			CleanCategoryPool(self)
			for i = 1, self.numLines do
				local button = self.buttons[i]
				local check = self.checks[i]
				if not button.clicked or hide then
					button:Hide()
				end
				check.shown = false
				check:SetAlpha(0)
			end
			self.numLines = 0
		end
		tooltip.ClearLines = wrap(tooltip.ClearLines, "tooltip:ClearLines")

		function tooltip:NumLines()
			return self.numLines
		end

		local lastWidth
		local old_tooltip_Hide = tooltip.Hide
		tooltip.__Hide = old_tooltip_Hide
		function tooltip:Hide(newOwner)
			if self == tooltip or newOwner == nil then
				old_tooltip_Hide(self)
			end
			self:ClearLines(true)
			self.owner = nil
			self.lastWidth = nil
			self.tmpHidden = nil
		end
		tooltip.Hide = wrap(tooltip.Hide, "tooltip:Hide")

		local old_tooltip_Show = tooltip.Show
		tooltip.__Show = old_tooltip_Show
		function tooltip:Show(tabletData)
			if self.owner == nil or self.notInUse then
				return
			end
			if not self.tmpHidden then
				old_tooltip_Show(self)
			end

			local maxWidth = tabletData and tabletData.width or self:GetWidth() - 20
			local hasWrap = false
			local screenWidth = GetScreenWidth()
			local scrollMax = self.numLines
			if scrollMax > GetMaxLinesPerScreen(self) + self.scroll then
				scrollMax = GetMaxLinesPerScreen(self) + self.scroll
			end
			local numColumns

			local height = 20
			if scrollMax ~= self.numLines then
				self.scrollDown:SetWidth(maxWidth)
				height = height + self.scrollDown:GetHeight() + 2
			end
			if self.scroll ~= 0 then
				self.scrollUp:SetWidth(maxWidth)
				height = height + self.scrollUp:GetHeight() + 2
			end
			self:SetWidth(maxWidth + 20)

			local tmp = self.scroll + 1
			if tmp ~= 1 then
				tmp = tmp + 1
			end
			for i = 1, self.numLines do
				if i < tmp or i > scrollMax or (i == scrollMax and i ~= self.numLines) then
					self.buttons[i]:ClearAllPoints()
					self.buttons[i]:Hide()
				else
					local button = self.buttons[i]
					local left = self.lefts[i]
					local right = self.rights[i]
					local check = self.checks[i]
					button:SetWidth(maxWidth)
					button:SetHeight(math.max(left:GetHeight(), right:GetHeight()))
					height = height + button:GetHeight() + 2
					if i == self.scroll + 1 then
						button:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -10)
					else
						button:SetPoint("TOPLEFT", self.buttons[i - 1], "BOTTOMLEFT", 0, -2)
					end
					if button.clicked then
						check:SetPoint("TOPLEFT", button, "TOPLEFT", button.indentation * self.fontSizePercent + (check.width - check:GetWidth()) / 2 + 1, -1)
					else
						check:SetPoint("TOPLEFT", button, "TOPLEFT", button.indentation * self.fontSizePercent + (check.width - check:GetWidth()) / 2, 0)
					end
					button:Show()
				end
			end
			if self.scroll ~= 0 then
				self.scrollUp:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -10)
				self.buttons[self.scroll + 2]:SetPoint("TOPLEFT", self.scrollUp, "BOTTOMLEFT", 0, -2)
				self.scrollUp:SetText(SCROLL_UP .. " (" .. self.scroll + 2 .. " / " .. self.numLines .. ")")
				self.scrollUp:Show()
			else
				self.scrollUp:Hide()
			end
			if scrollMax ~= self.numLines and self.buttons[scrollMax - 1] then
				self.scrollDown:SetPoint("TOPLEFT", self.buttons[scrollMax - 1], "BOTTOMLEFT", 0, -2)
				self.scrollDown:SetText(SCROLL_DOWN .. " (" .. scrollMax - 1 .. " / " .. self.numLines .. ")")
				self.scrollDown:Show()
			else
				self.scrollDown:Hide()
			end
			self:SetHeight(height)
		end
		tooltip.Show = wrap(tooltip.Show, "tooltip:Show")

		local lastMouseDown
		local function button_OnClick()
			if this.self:HasScript("OnClick") and type(this.self:GetScript("OnClick")) == "function" then
				this.self:GetScript("OnClick")()
			end
			if arg1 == "RightButton" then
				if this.self:HasScript("OnClick") and type(this.self:GetScript("OnClick")) == "function" then
					this.self:GetScript("OnClick")()
				end
			elseif arg1 == "LeftButton" then
				if this.self.preventClick == nil or GetTime() > this.self.preventClick and GetTime() < lastMouseDown + 0.5 then
					this.self.preventClick = nil
					this.self.updating = true
					this.self.preventRefresh = true
					this.func(this.a1, this.a2, this.a3)
					if this.self then
						this.self.preventRefresh = false
						this.self:children()
						this.self.updating = false
					end
				end
			end
		end
		local function button_OnMouseUp()
			if this.self:HasScript("OnMouseUp") and type(this.self:GetScript("OnMouseUp")) == "function" then
				this.self:GetScript("OnMouseUp")()
			end
			if arg1 ~= "RightButton" then
				if this.clicked then
					local a,b,c,d,e = this.check:GetPoint(1)
					this.check:SetPoint(a,b,c,d-1,e+1)
					this.clicked = false
				end
			end
		end
		local function button_OnMouseDown()
			if this.self:HasScript("OnMouseDown") and type(this.self:GetScript("OnMouseDown")) == "function" then
				this.self:GetScript("OnMouseDown")()
			end
			lastMouseDown = GetTime()
			if arg1 ~= "RightButton" then
				local a,b,c,d,e = this.check:GetPoint(1)
				this.check:SetPoint(a,b,c,d+1,e-1)
				this.clicked = true
			end
		end
		function tooltip:AddLine(info)
			local category = info.category.superCategory
			local maxWidth = category.tabletData.width
			local text = info.blank and "\n" or info.text
			local id = info.id
			local func = info.func
			local checked = info.checked
			local isRadio = info.isRadio
			local checkTexture = info.checkTexture
			local fontSizePercent = self.fontSizePercent
			if not info.font then
				info.font = GameTooltipText
			end
			if not info.size then
				_,info.size = info.font:GetFont()
			end
			local catStart = false
			local columns = category and category.columns or 1
			local x1, x2, x3, x4, x5, x6
			if category then
				x1, x2, x3, x4, x5, x6 = category.x1, category.x2, category.x3, category.x4, category.x5, category.x6
			else
				x1, x2, x3, x4, x5, x6 = 0, 0, 0, 0, 0, 0
			end
			if info.isTitle then
				justAddedTitle = true
			end

			self.numLines = self.numLines + 1
			NewLine(self)
			self.lefts[self.numLines]:Show()
			self.buttons[self.numLines]:Show()
			num = self.numLines

			local button = self.buttons[num]
			button.indentation = info.indentation
			local left = self.lefts[num]
			local right = self.rights[num]
			local third = self.thirds[num]
			local fourth = self.fourths[num]
			local fifth = self.fifths[num]
			local sixth = self.sixths[num]
			local check = self.checks[num]
			do -- if columns >= 1 then
				left:SetFontObject(info.font)
				left:SetText(text)
				left:Show()
				if info.textR and info.textG and info.textB then
					left:SetTextColor(info.textR, info.textG, info.textB)
				else
					left:SetTextColor(1, 0.823529, 0)
				end
				local a,_,b = left:GetFont()
				left:SetFont(a, info.size * fontSizePercent, b)
				left:SetJustifyH(info.justify)
				if columns < 2 then
					right:SetText(nil)
					right:Hide()
					right:SetPoint("TOPLEFT", left, "TOPRIGHT", 40 * fontSizePercent, 0)
					right:SetPoint("TOPRIGHT", button, "TOPRIGHT", -5, 0)
					third:SetText(nil)
					third:Hide()
					fourth:SetText(nil)
					fourth:Hide()
					fifth:SetText(nil)
					fifth:Hide()
					sixth:SetText(nil)
					sixth:Hide()
				else
					right:SetFontObject(info.font2)
					right:SetText(info.text2)
					right:Show()
					if info.text2R and info.text2G and info.text2B then
						right:SetTextColor(info.text2R, info.text2G, info.text2B)
					else
						right:SetTextColor(1, 0.823529, 0)
					end
					local a,_,b = right:GetFont()
					right:SetFont(a, info.size2 * fontSizePercent, b)
					right:SetJustifyH(info.justify2)
					if columns < 3 then
						right:SetPoint("TOPLEFT", left, "TOPRIGHT", 40 * fontSizePercent, 0)
						right:SetPoint("TOPRIGHT", button, "TOPRIGHT", -5, 0)
						third:SetText(nil)
						third:Hide()
						fourth:SetText(nil)
						fourth:Hide()
						fifth:SetText(nil)
						fifth:Hide()
						sixth:SetText(nil)
						sixth:Hide()
					else
						third:SetFontObject(info.font3)
						third:SetText(info.text3)
						third:Show()
						if info.text3R and info.text3G and info.text3B then
							third:SetTextColor(info.text3R, info.text3G, info.text3B)
						else
							third:SetTextColor(1, 0.823529, 0)
						end
						local a,_,b = third:GetFont()
						third:SetFont(a, info.size3 * fontSizePercent, b)
						right:ClearAllPoints()
						right:SetPoint("TOPLEFT", left, "TOPRIGHT", 20 * fontSizePercent, 0)
						third:SetJustifyH(info.justify3)
						if columns < 4 then
							fourth:SetText(nil)
							fourth:Hide()
							fifth:SetText(nil)
							fifth:Hide()
							sixth:SetText(nil)
							sixth:Hide()
						else
							fourth:SetFontObject(info.font4)
							fourth:SetText(info.text4)
							fourth:Show()
							if info.text4R and info.text4G and info.text4B then
								fourth:SetTextColor(info.text4R, info.text4G, info.text4B)
							else
								fourth:SetTextColor(1, 0.823529, 0)
							end
							local a,_,b = fourth:GetFont()
							fourth:SetFont(a, info.size4 * fontSizePercent, b)
							fourth:SetJustifyH(info.justify4)
							if columns < 5 then
								fifth:SetText(nil)
								fifth:Hide()
								sixth:SetText(nil)
								sixth:Hide()
							else
								fifth:SetFontObject(info.font5)
								fifth:SetText(info.text5)
								fifth:Show()
								if info.text5R and info.text5G and info.text5B then
									fifth:SetTextColor(info.text5R, info.text5G, info.text5B)
								else
									fifth:SetTextColor(1, 0.823529, 0)
								end
								local a,_,b = fourth:GetFont()
								fifth:SetFont(a, info.size5 * fontSizePercent, b)
								fifth:SetJustifyH(info.justify5)
								if columns < 6 then
									sixth:SetText(nil)
									sixth:Hide()
								else
									sixth:SetFontObject(info.font6)
									sixth:SetText(info.text6)
									sixth:Show()
									if info.text5R and info.text6G and info.text6B then
										sixth:SetTextColor(info.text6R, info.text6G, info.text6B)
									else
										sixth:SetTextColor(1, 0.823529, 0)
									end
									local a,_,b = fourth:GetFont()
									sixth:SetFont(a, info.size6 * fontSizePercent, b)
									sixth:SetJustifyH(info.justify6)
								end
							end
						end
					end
				end
			end

			check:SetWidth(info.size)
			check:SetHeight(info.size)
			check.width = info.size
			if info.hasCheck then
				check.shown = true
				check:Show()
				if isRadio then
					check:SetTexture(info.checkIcon or "Interface\\Buttons\\UI-RadioButton")
					if info.checked then
						check:SetAlpha(1)
						check:SetTexCoord(0.25, 0.5, 0, 1)
					else
						check:SetAlpha(self.transparency)
						check:SetTexCoord(0, 0.25, 0, 1)
					end
				else
					if info.checkIcon then
						check:SetTexture(info.checkIcon)
						if string.sub(info.checkIcon, 1, 16) == "Interface\\Icons\\" then
							check:SetTexCoord(0.05, 0.95, 0.05, 0.95)
						else
							check:SetTexCoord(0, 1, 0, 1)
						end
					else
						check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
						check:SetWidth(info.size * 1.5)
						check:SetHeight(info.size * 1.5)
						check.width = info.size * 1.2
						check:SetTexCoord(0, 1, 0, 1)
					end
					check:SetAlpha(info.checked and 1 or 0)
				end
				left:SetPoint("TOPLEFT", check, "TOPLEFT", check.width, 0)
			else
				left:SetPoint("TOPLEFT", check, "TOPLEFT")
			end
			if columns == 1 then
				left:SetWidth(maxWidth)
			elseif columns == 2 then
				left:SetWidth(0)
				right:SetWidth(0)
				if info.wrap then
					left:SetWidth(maxWidth - right:GetWidth() - 40 * fontSizePercent)
				elseif info.wrap2 then
					right:SetWidth(maxWidth - left:GetWidth() - 40 * fontSizePercent)
				end
				right:ClearAllPoints()
				right:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
				if not info.text2 then
					left:SetJustifyH(info.justify or "LEFT")
				end
			elseif columns == 3 then
				left:SetWidth(x1 - info.checkWidth)
				right:SetWidth(x2)
				third:SetWidth(x3)
				right:ClearAllPoints()
				local num = (category.tabletData.width - x1 - x2 - x3) / 2
				right:SetPoint("TOPLEFT", left, "TOPRIGHT", num, 0)
				third:SetPoint("TOPLEFT", right, "TOPRIGHT", num, 0)
			elseif columns == 4 then
				left:SetWidth(x1 - info.checkWidth)
				right:SetWidth(x2)
				third:SetWidth(x3)
				fourth:SetWidth(x4)
				local num = (category.tabletData.width - x1 - x2 - x3 - x4) / 3
				right:SetPoint("TOPLEFT", left, "TOPRIGHT", num, 0)
				third:SetPoint("TOPLEFT", right, "TOPRIGHT", num, 0)
				fourth:SetPoint("TOPLEFT", third, "TOPRIGHT", num, 0)
			elseif columns == 5 then
				left:SetWidth(x1 - info.checkWidth)
				right:SetWidth(x2)
				third:SetWidth(x3)
				fourth:SetWidth(x4)
				fifth:SetWidth(x5)
				local num = (category.tabletData.width - x1 - x2 - x3 - x4 - x5) / 4
				right:SetPoint("TOPLEFT", left, "TOPRIGHT", num, 0)
				third:SetPoint("TOPLEFT", right, "TOPRIGHT", num, 0)
				fourth:SetPoint("TOPLEFT", third, "TOPRIGHT", num, 0)
				fifth:SetPoint("TOPLEFT", fourth, "TOPRIGHT", num, 0)
			elseif columns == 6 then
				left:SetWidth(x1 - info.checkWidth)
				right:SetWidth(x2)
				third:SetWidth(x3)
				fourth:SetWidth(x4)
				fifth:SetWidth(x5)
				sixth:SetWidth(x6)
				local num = (category.tabletData.width - x1 - x2 - x3 - x4 - x5 - x6) / 5
				right:SetPoint("TOPLEFT", left, "TOPRIGHT", num, 0)
				third:SetPoint("TOPLEFT", right, "TOPRIGHT", num, 0)
				fourth:SetPoint("TOPLEFT", third, "TOPRIGHT", num, 0)
				fifth:SetPoint("TOPLEFT", fourth, "TOPRIGHT", num, 0)
				sixth:SetPoint("TOPLEFT", fifth, "TOPRIGHT", num, 0)
			end
			if not self.locked or IsAltKeyDown() then
				local func = info.func
				if func then
					if type(func) == "string" then
						Tablet:assert(type(info.arg1) == "table", "Cannot call method " .. info.func .. " on a non-table")
						func = info.arg1[func]
						Tablet:assert(type(func) == "function", "Method " .. info.func .. " nonexistant")
					end
					Tablet:assert(type(func) == "function", "func must be a function or method")
					button.func = func
					button.a1 = info.arg1
					button.a2 = info.arg2
					button.a3 = info.arg3
					button.self = self
					button:SetScript("OnMouseUp", button_OnMouseUp)
					button:SetScript("OnMouseDown", button_OnMouseDown)
					button:SetScript("OnClick", button_OnClick)
					if button.clicked then
						button:SetButtonState("PUSHED")
					end
					button:EnableMouse(true)
				else
					button:SetScript("OnMouseDown", nil)
					button:SetScript("OnMouseUp", nil)
					button:SetScript("OnClick", nil)
					button:EnableMouse(false)
				end
			else
				button:SetScript("OnMouseDown", nil)
				button:SetScript("OnMouseUp", nil)
				button:SetScript("OnClick", nil)
				button:EnableMouse(false)
			end
		end
		tooltip.AddLine = wrap(tooltip.AddLine, "tooltip:AddLine")

		function tooltip:SetFontSizePercent(percent)
			local data, detachedData = self.data, self.detachedData
			if detachedData and detachedData.detached then
				data = detachedData
			end
			local lastSize = self.fontSizePercent
			percent = tonumber(percent) or 1
			if percent < 0.25 then
				percent = 0.25
			elseif percent > 4 then
				percent = 4
			end
			self.fontSizePercent = percent
			if data then
				data.fontSizePercent = percent ~= 1 and percent or nil
			end
			self.scrollUp:SetFont(font, normalSize * self.fontSizePercent, flags)
			self.scrollDown:SetFont(font, normalSize * self.fontSizePercent, flags)
			local ratio = self.fontSizePercent / lastSize
			for i = 1, self.numLines do
				local left = self.lefts[i]
				local right = self.rights[i]
				local third = self.thirds[i]
				local fourth = self.fourths[i]
				local fifth = self.fifths[i]
				local sixth = self.sixths[i]
				local check = self.checks[i]
				local font, size, flags = left:GetFont()
				left:SetFont(font, size * ratio, flags)
				font, size, flags = right:GetFont()
				right:SetFont(font, size * ratio, flags)
				font, size, flags = third:GetFont()
				third:SetFont(font, size * ratio, flags)
				font, size, flags = fourth:GetFont()
				fourth:SetFont(font, size * ratio, flags)
				font, size, flags = fifth:GetFont()
				fifth:SetFont(font, size * ratio, flags)
				font, size, flags = sixth:GetFont()
				sixth:SetFont(font, size * ratio, flags)
				check.width = check.width * ratio
				check:SetWidth(check:GetWidth() * ratio)
				check:SetHeight(check:GetHeight() * ratio)
			end
			self:SetWidth((self:GetWidth() - 51) * ratio + 51)
			self:SetHeight((self:GetHeight() - 51) * ratio + 51)
			if self:IsShown() and self.children then
				self:Show()
			end
		end
		tooltip.SetFontSizePercent = wrap(tooltip.SetFontSizePercent, "tooltip:SetFontSizePercent")

		function tooltip:GetFontSizePercent()
			return self.fontSizePercent
		end

		function tooltip:SetTransparency(alpha)
			local data, detachedData = self.data, self.detachedData
			if detachedData and detachedData.detached then
				data = detachedData
			end
			self.transparency = alpha
			if data then
				data.transparency = alpha ~= 0.75 and alpha or nil
			end
			self:SetBackdropColor(self.r or 0, self.g or 0, self.b or 0, alpha)
			self:SetBackdropBorderColor(1, 1, 1, alpha)
		end
		tooltip.SetTransparency = wrap(tooltip.SetTransparency, "tooltip:SetTransparency")

		function tooltip:GetTransparency()
			return self.transparency
		end

		function tooltip:SetColor(r, g, b)
			local data, detachedData = self.data, self.detachedData
			if detachedData and detachedData.detached then
				data = detachedData
			end
			self.r = r
			self.g = g
			self.b = b
			if data then
				data.r = r ~= 0 and r or nil
				data.g = g ~= 0 and g or nil
				data.b = b ~= 0 and b or nil
			end
			self:SetBackdropColor(r or 0, g or 0, b or 0, self.transparency)
			self:SetBackdropBorderColor(1, 1, 1, self.transparency)
		end
		tooltip.SetColor = wrap(tooltip.SetColor, "tooltip:SetColor")

		function tooltip:GetColor()
			return self.r, self.g, self.b
		end

		function tooltip:Scroll(down)
			if down then
				if IsShiftKeyDown() then
					self.scroll = self.numLines - GetMaxLinesPerScreen(self)
				else
					self.scroll = self.scroll + 3
				end
			else
				if IsShiftKeyDown() then
					self.scroll = 0
				else
					self.scroll = self.scroll - 3
				end
			end
			if self.scroll > self.numLines - GetMaxLinesPerScreen(self) then
				self.scroll = self.numLines - GetMaxLinesPerScreen(self)
			end
			if self.scroll < 0 then
				self.scroll = 0
			end
			if self:IsShown() then
				self:Show()
			end
		end
		tooltip.Scroll = wrap(tooltip.Scroll, "tooltip:Scroll")

		function tooltip.Detach(tooltip)
			local owner = tooltip.owner
			tooltip:Hide()
			self:assert(tooltip.detachedData, "You cannot detach if detachedData is not present")
			tooltip.detachedData.detached = true
			local detached = AcquireDetachedFrame(self, tooltip.registration, tooltip.data, tooltip.detachedData)

			detached.menu, tooltip.menu = tooltip.menu, nil
			detached.children = tooltip.children
			tooltip.children = nil
			detached:SetOwner(owner)
			detached:children()
			detached:Show()
		end
		tooltip.Detach = wrap(tooltip.Detach, "tooltip:Detach")

	end

	tooltip.registration = registration
	registration.tooltip = tooltip
	return tooltip
end
AcquireFrame = wrap(AcquireFrame, "AcquireFrame")

function ReleaseDetachedFrame(self, data, detachedData)
	if not detachedData then
		detachedData = data
	end
	for _, detached in ipairs(detachedTooltips) do
		if detached.detachedData == detachedData then
			detached.notInUse = true
			detached:Hide()
			detached.registration.tooltip = nil
			detached.registration = nil
		end
	end
end
ReleaseDetachedFrame = wrap(ReleaseDetachedFrame, "ReleaseDetachedFrame")

local StartCheckingAlt, StopCheckingAlt
do
	local frame
	function StartCheckingAlt(func)
		if not frame then
			frame = CreateFrame("Frame")
		end
		local last = IsAltKeyDown()
		frame:SetScript("OnUpdate", function()
			local now = IsAltKeyDown()
			if last ~= now then
				last = now
				func()
			end
		end)
	end
	function StopCheckingAlt()
		if frame then
			frame:SetScript("OnUpdate", nil)
		end
	end
end

function AcquireDetachedFrame(self, registration, data, detachedData)
	if not detachedData then
		detachedData = data
	end
	for _, detached in ipairs(detachedTooltips) do
		if detached.notInUse then
			detached.data = data
			detached.detachedData = detachedData
			detached.notInUse = nil
			local fontSizePercent = detachedData.fontSizePercent or 1
			local transparency = detachedData.transparency or 0.75
			local r = detachedData.r or 0
			local g = detachedData.g or 0
			local b = detachedData.b or 0
			detached:SetFontSizePercent(fontSizePercent)
			detached:SetTransparency(transparency)
			detached:SetColor(r, g, b)
			detached:ClearAllPoints()
			detached:SetPoint(detachedData.anchor or "CENTER", UIParent, detachedData.anchor or "CENTER", detachedData.offsetx or 0, detachedData.offsety or 0)
			detached.registration = registration
			registration.tooltip = detached
			return detached
		end
	end

	if not Dewdrop and AceLibrary:HasInstance("Dewdrop-2.0") then
		Dewdrop = AceLibrary("Dewdrop-2.0")
	end
	StartCheckingAlt(function()
		for _, detached in ipairs(detachedTooltips) do
			if detached:IsShown() and detached.locked then
				detached:EnableMouse(IsAltKeyDown())
				detached:children()
				if detached.moving then
					local a1 = arg1
					arg1 = "LeftButton"
					if type(detached:GetScript("OnMouseUp")) == "function" then
						detached:GetScript("OnMouseUp")()
					end
					arg1 = a1
				end
			end
		end
	end)
	if not tooltip then
		AcquireFrame(self, {})
	end
	local detached = CreateFrame("Frame", "Tablet20DetachedFrame" .. (table.getn(detachedTooltips) + 1), UIParent)
	table.insert(detachedTooltips, detached)
	detached.notInUse = true
	detached:EnableMouse(not data.locked)
	detached:EnableMouseWheel(true)
	detached:SetMovable(true)
	detached:SetPoint(data.anchor or "CENTER", UIParent, data.anchor or "CENTER", data.offsetx or 0, data.offsety or 0)

	detached.numLines = 0
	detached.owner = nil
	detached.fontSizePercent = 1
	detached.maxLines = 0
	detached.buttons = {}
	detached.checks = {}
	detached.lefts = {}
	detached.rights = {}
	detached.thirds = {}
	detached.fourths = {}
	detached.fifths = {}
	detached.sixths = {}
	detached.transparency = 0.75
	detached.r = 0
	detached.g = 0
	detached.b = 0
	detached:SetFrameStrata("BACKGROUND")
	detached:SetBackdrop(tmp.a(
		'bgFile', "Interface\\Buttons\\WHITE8X8",
		'edgeFile', "Interface\\Tooltips\\UI-Tooltip-Border",
		'tile', true,
		'tileSize', 16,
		'edgeSize', 16,
		'insets', tmp.b(
			'left', 5,
			'right', 5,
			'top', 5,
			'bottom', 5
		)
	))
	detached.locked = detachedData.locked
	detached.scroll = 0
	detached:EnableMouse(not detached.locked)

	local width = GetScreenWidth()
	local height = GetScreenHeight()
	detached:SetScript("OnMouseDown", function()
		if arg1 == "LeftButton" then
			detached:StartMoving()
			detached.moving = true
		end
	end)

	detached:SetScript("OnMouseUp", function()
		if arg1 == "LeftButton" then
			detached:StopMovingOrSizing()
			detached.moving = nil
			local anchor
			local offsetx
			local offsety
			if detached:GetTop() + detached:GetBottom() < height then
				anchor = "BOTTOM"
				offsety = detached:GetBottom()
				if offsety < 0 then
					offsety = 0
				end
				if offsety < MainMenuBar:GetTop() and MainMenuBar:IsVisible() then
					offsety = MainMenuBar:GetTop()
				end
				local top = 0
				if FuBar then
					for i = 1, FuBar:GetNumPanels() do
						local panel = FuBar:GetPanel(i)
						if panel:GetAttachPoint() == "BOTTOM" then
							if panel.frame:GetTop() > top then
								top = panel.frame:GetTop()
								break
							end
						end
					end
				end
				if offsety < top then
					offsety = top
				end
			else
				anchor = "TOP"
				offsety = detached:GetTop() - height
				if offsety > 0 then
					offsety = 0
				end
				local bottom = GetScreenHeight()
				if FuBar then
					for i = 1, FuBar:GetNumPanels() do
						local panel = FuBar:GetPanel(i)
						if panel:GetAttachPoint() == "TOP" then
							if panel.frame:GetBottom() < bottom then
								bottom = panel.frame:GetBottom()
								break
							end
						end
					end
				end
				bottom = bottom - GetScreenHeight()
				if offsety > bottom then
					offsety = bottom
				end
			end
			if detached:GetLeft() + detached:GetRight() < width * 2 / 3 then
				anchor = anchor .. "LEFT"
				offsetx = detached:GetLeft()
				if offsetx < 0 then
					offsetx = 0
				end
			elseif detached:GetLeft() + detached:GetRight() < width * 4 / 3 then
				if anchor == "" then
					anchor = "CENTER"
				end
				offsetx = (detached:GetLeft() + detached:GetRight() - GetScreenWidth()) / 2
			else
				anchor = anchor .. "RIGHT"
				offsetx = detached:GetRight() - width
				if offsetx > 0 then
					offsetx = 0
				end
			end
			detached:ClearAllPoints()
			detached:SetPoint(anchor, UIParent, anchor, offsetx, offsety)
			local t = detached.detachedData
			if t.anchor ~= anchor or math.abs(t.offsetx - offsetx) > 8 or math.abs(t.offsety - offsety) > 8 then
				detached.preventClick = GetTime() + 0.05
			end
			t.anchor = anchor
			t.offsetx = offsetx
			t.offsety = offsety
			detached:Show()
		end
	end)

	Dewdrop:Register(detached,
		'children', function(level, value)
			if not detached.registration then
				return
			end
			if detached.menu then
				detached.menu(level, value)
				if level == 1 then
					Dewdrop:AddLine()
				end
			end
			if level == 1 then
				if not detached.registration.cantAttach then
					Dewdrop:AddLine(
						'text', DETACH,
						'tooltipTitle', DETACH,
						'tooltipText', DETACH_DESC,
						'checked', true,
						'arg1', detached,
						'func', "Attach",
						'closeWhenClicked', true
					)
				end
				Dewdrop:AddLine(
					'text', LOCK,
					'tooltipTitle', LOCK,
					'tooltipText', LOCK_DESC,
					'checked', detached:IsLocked(),
					'arg1', detached,
					'func', "Lock",
					'closeWhenClicked', not detached:IsLocked()
				)
				Dewdrop:AddLine(
					'text', COLOR,
					'tooltipTitle', COLOR,
					'tooltipText', COLOR_DESC,
					'hasColorSwatch', true,
					'r', detached.r,
					'g', detached.g,
					'b', detached.b,
					'hasOpacity', true,
					'opacity', detached.transparency,
					'colorFunc', function(r, g, b, a)
						detached:SetColor(r, g, b)
						detached:SetTransparency(a)
					end
				)
				Dewdrop:AddLine(
					'text', SIZE,
					'tooltipTitle', SIZE,
					'tooltipText', SIZE_DESC,
					'hasArrow', true,
					'hasSlider', true,
					'sliderFunc', function(value)
						detached:SetFontSizePercent(value)
					end,
					'sliderMax', 2,
					'sliderMin', 0.5,
					'sliderStep', 0.05,
					'sliderIsPercent', true,
					'sliderValue', detached:GetFontSizePercent()
				)
				Dewdrop:AddLine(
					'text', CLOSE_MENU,
					'tooltipTitle', CLOSE_MENU,
					'tooltipText', CLOSE_MENU_DESC,
					'func', function()
						Dewdrop:Close()
					end
				)
			end
		end,
		'point', function()
			local x, y = detached:GetCenter()
			if x < GetScreenWidth() / 2 then
				if y < GetScreenHeight() / 2 then
					return "BOTTOMLEFT", "BOTTOMRIGHT"
				else
					return "TOPLEFT", "TOPRIGHT"
				end
			else
				if y < GetScreenHeight() / 2 then
					return "BOTTOMRIGHT", "BOTTOMLEFT"
				else
					return "TOPRIGHT", "TOPLEFT"
				end
			end
		end
	)

	NewLine(detached)

	detached.scrollUp = detached:CreateFontString(nil, "ARTWORK")
	detached.scrollUp:SetPoint("TOPLEFT", detached.buttons[1], "BOTTOMLEFT", 0, -2)
	detached.scrollUp:SetPoint("RIGHT", detached, "RIGHT", 0, -10)
	detached.scrollUp:SetFontObject(GameTooltipText)
	detached.scrollUp:Hide()
	local font,_,flags = detached.scrollUp:GetFont()
	detached.scrollUp:SetFont(font, normalSize * detached.fontSizePercent, flags)
	detached.scrollUp:SetJustifyH("CENTER")
	detached.scrollUp:SetTextColor(1, 0.823529, 0)
	detached.scrollUp:SetText(" ")

	detached.scrollDown = detached:CreateFontString(nil, "ARTWORK")
	detached.scrollDown:SetPoint("TOPLEFT", detached.buttons[1], "BOTTOMLEFT", 0, -2)
	detached.scrollDown:SetPoint("RIGHT", detached, "RIGHT", 0, -10)
	detached.scrollDown:SetFontObject(GameTooltipText)
	detached.scrollDown:Hide()
	local font,_,flags = detached.scrollUp:GetFont()
	detached.scrollDown:SetFont(font, normalSize * detached.fontSizePercent, flags)
	detached.scrollDown:SetJustifyH("CENTER")
	detached.scrollDown:SetTextColor(1, 0.823529, 0)
	detached.scrollDown:SetText(" ")

	detached:SetScript("OnMouseWheel", function()
		detached:Scroll(arg1 < 0)
	end)

	detached.SetTransparency = tooltip.SetTransparency
	detached.GetTransparency = tooltip.GetTransparency
	detached.SetColor = tooltip.SetColor
	detached.GetColor = tooltip.GetColor
	detached.SetFontSizePercent = tooltip.SetFontSizePercent
	detached.GetFontSizePercent = tooltip.GetFontSizePercent
	detached.SetOwner = tooltip.SetOwner
	detached.IsOwned = tooltip.IsOwned
	detached.ClearLines = tooltip.ClearLines
	detached.NumLines = tooltip.NumLines
	detached.__Hide = detached.Hide
	detached.__Show = detached.Show
	detached.Hide = tooltip.Hide
	detached.Show = tooltip.Show
	local old_IsShown = detached.IsShown
	function detached:IsShown()
		if self.tmpHidden then
			return true
		else
			return old_IsShown(self)
		end
	end
	detached.AddLine = tooltip.AddLine
	detached.Scroll = tooltip.Scroll
	function detached:IsLocked()
		return self.locked
	end
	function detached:Lock()
		self:EnableMouse(self.locked)
		self.locked = not self.locked
		self.detachedData.locked = self.locked or nil
		self:children()
	end

	function detached.Attach(detached)
		self:assert(detached, "Detached tooltip not given.")
		self:assert(detached.AddLine, "detached argument not a Tooltip.")
		self:assert(detached.owner, "Detached tooltip has no owner.")
		self:assert(not detached.notInUse, "Detached tooltip not in use.")
		detached.menu = nil
		detached.detachedData.detached = nil
		detached:SetOwner(nil)
		detached.notInUse = TRUE
	end

	return AcquireDetachedFrame(self, registration, data, detachedData)
end
AcquireDetachedFrame = wrap(AcquireDetachedFrame, "AcquireDetachedFrame")

function Tablet:Close(parent)
	if not parent then
		if tooltip and tooltip:IsShown() then
			tooltip:Hide()
			tooltip.registration.tooltip = nil
			tooltip.registration = nil
		end
		return
	else
		self:argCheck(parent, 2, "table", "string")
	end
	local info = self.registry[parent]
	self:assert(info, "You cannot close a tablet with an unregistered parent frame.")
	local data = info.data
	local detachedData = info.detachedData
	if detachedData and detachedData.detached then
		ReleaseDetachedFrame(self, data, detachedData)
	elseif tooltip.data == data then
		tooltip:Hide()
		tooltip.registration.tooltip = nil
		tooltip.registration = nil
	end
end
Tablet.Close = wrap(Tablet.Close, "Tablet:Close")

local currentFrame
local currentTabletData

function Tablet:Open(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	self:assert(info, "You cannot open a tablet with an unregistered parent frame.")
	self:Close()
	local data = info.data
	local detachedData = info.detachedData
	local children = info.children
	if not children then
		return
	end
	local frame = AcquireFrame(self, info, data, detachedData)
	frame.clickable = info.clickable
	frame.menu = info.menu
	local children = info.children
	function frame:children()
		if not self.preventRefresh then
			currentFrame = self
			currentTabletData = TabletData:new(self)
			self:ClearLines()
			if children then
				children()
			end
			currentTabletData:Display(currentFrame)
			self:Show(currentTabletData)
			currentTabletData:del()
			currentTabletData = nil
			currentFrame = nil
		end
	end
	frame:SetOwner(parent)
	frame:children()
	local point = info.point
	local relativePoint = info.point
	if type(point) == "function" then
		local b
		point, b = point(parent)
		if b then
			relativePoint = b
		end
	end
	if type(relativePoint) == "function" then
		relativePoint = relativePoint(parent)
	end
	if not point then
		point = "CENTER"
	end
	if not relativePoint then
		relativePoint = point
	end
	frame:ClearAllPoints()
	if type(parent) ~= "string" then
		frame:SetPoint(point, parent, relativePoint)
	end
	local offsetx = 0
	local offsety = 0
	if frame:GetBottom() and frame:GetLeft() then
		if frame:GetRight() > GetScreenWidth() then
			offsetx = frame:GetRight() - GetScreenWidth()
		elseif frame:GetLeft() < 0 then
			offsetx = -frame:GetLeft()
		end
		local ratio = GetScreenWidth() / GetScreenHeight()
		if ratio >= 2.4 and frame:GetRight() > GetScreenWidth() / 2 and frame:GetLeft() < GetScreenWidth() / 2 then
			if frame:GetCenter() < GetScreenWidth() / 2 then
				offsetx = frame:GetRight() - GetScreenWidth() / 2
			else
				offsetx = frame:GetLeft() - GetScreenWidth() / 2
			end
		end
		if frame:GetBottom() < 0 then
			offsety = frame:GetBottom()
		elseif frame:GetTop() and frame:GetTop() > GetScreenHeight() then
			offsety = frame:GetTop() - GetScreenHeight()
		end
		if MainMenuBar:IsVisible() and frame:GetBottom() < MainMenuBar:GetTop() and offsety < frame:GetBottom() - MainMenuBar:GetTop() then
			offsety = frame:GetBottom() - MainMenuBar:GetTop()
		end

		if FuBar then
			local top = 0
			if FuBar then
				for i = 1, FuBar:GetNumPanels() do
					local panel = FuBar:GetPanel(i)
					if panel:GetAttachPoint() == "BOTTOM" then
						if panel.frame:GetTop() and panel.frame:GetTop() > top then
							top = panel.frame:GetTop()
							break
						end
					end
				end
			end
			if frame:GetBottom() < top and offsety < frame:GetBottom() - top then
				offsety = frame:GetBottom() - top
			end
			local bottom = GetScreenHeight()
			if FuBar then
				for i = 1, FuBar:GetNumPanels() do
					local panel = FuBar:GetPanel(i)
					if panel:GetAttachPoint() == "TOP" then
						if panel.frame:GetBottom() and panel.frame:GetBottom() < bottom then
							bottom = panel.frame:GetBottom()
							break
						end
					end
				end
			end
			if frame:GetTop() > bottom and offsety < frame:GetTop() - bottom then
				offsety = frame:GetTop() - bottom
			end
		end
	end
	if type(parent) ~= "string" then
		frame:SetPoint(point, parent, relativePoint, -offsetx, -offsety)
	end

	if detachedData and (info.cantAttach or detachedData.detached) and frame == tooltip then
		detachedData.detached = false
		frame:Detach()
	end
end
Tablet.Open = wrap(Tablet.Open, "Tablet:Open")

function Tablet:Register(parent, k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20, k21, v21, k22, v22, k23, v23, k24, v24, k25, v25, k26, v26, k27, v27, k28, v28, k29, v29, k30, v30)
	self:argCheck(parent, 2, "table", "string")
	if self.registry[parent] then
		self:Unregister(parent)
	end
	local info
	if type(k1) == "table" and k1[0] then
		self:assert(type(self.registry[k1]) == "table", "Other parent not registered")
		info = copy(self.registry[k1])
		if type(v1) == "function" then
			info.point = v1
			info.relativePoint = nil
		end
	else
		info = new(k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20, k21, v21, k22, v22, k23, v23, k24, v24, k25, v25, k26, v26, k27, v27, k28, v28, k29, v29, k30, v30)
	end
	self.registry[parent] = info
	info.data = info.data or info.detachedData or {}
	info.detachedData = info.detachedData or info.data
	local data = info.data
	local detachedData = info.detachedData
	if not self.onceRegistered[parent] and type(parent) == "table" and type(parent.SetScript) == "function" and not info.dontHook then
		if not Dewdrop then
			Dewdrop = AceLibrary("Dewdrop-2.0")
		end
		local script = parent:GetScript("OnEnter")
		parent:SetScript("OnEnter", function()
			if script then
				script()
			end
			if self.registry[parent] then
				if (not data or not detachedData.detached) and not Dewdrop:IsOpen(parent) then
					self:Open(parent)
					self.tooltip.enteredFrame = true
				end
			end
		end)
		local script = parent:GetScript("OnLeave")
		parent:SetScript("OnLeave", function()
			if script then
				script()
			end
			if self.registry[parent] then
				if self.tooltip and (not data or not detachedData or not detachedData.detached) then
					self.tooltip.enteredFrame = false
				end
			end
		end)
		if parent:HasScript("OnMouseDown") then
			local script = parent:GetScript("OnMouseDown")
			parent:SetScript("OnMouseDown", function()
				if script then
					script()
				end
				if self.registry[parent] and self.registry[parent].tooltip and self.registry[parent].tooltip == self.tooltip then
					self.tooltip:Hide()
				end
			end)
		end
		if parent:HasScript("OnMouseWheel") then
			local script = parent:GetScript("OnMouseWheel")
			parent:SetScript("OnMouseWheel", function()
				if script then
					script()
				end
				if self.registry[parent] and self.registry[parent].tooltip then
					self.registry[parent].tooltip:Scroll(arg1 < 0)
				end
			end)
		end
	end
	self.onceRegistered[parent] = true
	if GetMouseFocus() == parent then
		self:Open(parent)
	end
end
Tablet.Register = wrap(Tablet.Register, "Tablet:Register")

function Tablet:Unregister(parent)
	self:argCheck(parent, 2, "table", "string")
	self:assert(self.registry[parent], "You cannot unregister a parent frame if it has not been registered already.")
	self.registry[parent] = nil
end
Tablet.Unregister = wrap(Tablet.Unregister, "Tablet:Unregister")

function Tablet:IsRegistered(parent)
	self:argCheck(parent, 2, "table", "string")
	return self.registry[parent] and true
end
Tablet.IsRegistered = wrap(Tablet.IsRegistered, "Tablet:IsRegistered")

local _id = 0
local addedCategory
local currentCategoryInfo
local depth = 0
local categoryPool = {}
function CleanCategoryPool(self)
	for k,v in pairs(categoryPool) do
		del(v)
		categoryPool[k] = nil
	end
	_id = 0
end

function Tablet:AddCategory(k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20, k21, v21, k22, v22, k23, v23, k24, v24, k25, v25, k26, v26, k27, v27, k28, v28, k29, v29, k30, v30)
	self:assert(currentFrame, "You must add categories in within a registration.")
	local info = new(k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20, k21, v21, k22, v22, k23, v23, k24, v24, k25, v25, k26, v26, k27, v27, k28, v28, k29, v29, k30, v30)
	local cat = currentTabletData:AddCategory(info)
	del(info)
	return cat
end
Tablet.AddCategory = wrap(Tablet.AddCategory, "Tablet:AddCategory")

function Tablet:SetHint(text)
	self:assert(currentFrame, "You must set hint within a registration.")
	self:assert(not currentCategoryInfo, "You cannot set hint in a category.")
	currentTabletData:SetHint(text)
end
Tablet.SetHint = wrap(Tablet.SetHint, "Tablet:SetHint")

function Tablet:SetTitle(text)
	self:assert(currentFrame, "You must set title within a registration")
	self:assert(not currentCategoryInfo, "You cannot set title in a category.")
	currentTabletData:SetTitle(text)
end
Tablet.SetTitle = wrap(Tablet.SetTitle, "Tablet:SetTitle")

function Tablet:GetNormalFontSize()
	return normalSize
end

function Tablet:GetHeaderFontSize()
	return headerSize
end

function Tablet:GetNormalFontObject()
	return GameTooltipText
end

function Tablet:GetHeaderFontObject()
	return GameTooltipHeaderText
end

function Tablet:SetFontSizePercent(parent, percent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if info then
		if info.tooltip then
			info.tooltip:SetFontSizePercent(percent)
		else
			local data = info.data
			local detachedData = info.detachedData
			if detachedData.detached then
				detachedData.fontSizePercent = percent
			else
				data.fontSizePercent = percent
			end
		end
	elseif type(parent) == "table" then
		parent.fontSizePercent = percent
	else
		self:assert(false, "You cannot change font size with an unregistered parent frame.")
	end
end
Tablet.SetFontSizePercent = wrap(Tablet.SetFontSizePercent, "Tablet:SetFontSizePercent")

function Tablet:GetFontSizePercent(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if info then
		local data = info.data
		local detachedData = info.detachedData
		if detachedData.detached then
			return detachedData.fontSizePercent or 1
		else
			return data.fontSizePercent or 1
		end
	elseif type(parent) == "table" then
		return parent.fontSizePercent or 1
	else
		self:assert(false, "You cannot check font size with an unregistered parent frame.")
	end
end
Tablet.GetFontSizePercent = wrap(Tablet.GetFontSizePercent, "Tablet:GetFontSizePercent")

function Tablet:SetTransparency(parent, percent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if info then
		local data = info.data
		local detachedData = info.detachedData
		if info.tooltip then
			info.tooltip:SetTransparency(percent)
		else
			if detachedData.detached then
				detachedData.transparency = percent
			elseif data then
				data.transparency = percent
			end
		end
	elseif type(parent) == "table" then
		parent.transparency = percent
	else
		self:assert(false, "You cannot change transparency with an unregistered parent frame.")
	end
end
Tablet.SetTransparency = wrap(Tablet.SetTransparency, "Tablet:SetTransparency")

function Tablet:GetTransparency(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if info then
		local data = info.data
		local detachedData = info.detachedData
		if detachedData.detached then
			return detachedData.transparency or 0.75
		else
			return data.transparency or 0.75
		end
	elseif type(parent) == "table" then
		return parent.transparency or 0.75
	else
		self:assert(parent, "You must provide a parent frame to check transparency")
	end
end
Tablet.GetTransparency = wrap(Tablet.GetTransparency, "Tablet:GetTransparency")

function Tablet:SetColor(parent, r, g, b)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if info then
		if info.tooltip then
			info.tooltip:SetColor(r, g, b)
		else
			local data = info.data
			local detachedData = info.detachedData
			if detachedData.detached then
				detachedData.r = r
				detachedData.g = g
				detachedData.b = b
			else
				data.r = r
				data.g = g
				data.b = b
			end
		end
	elseif type(parent) == "table" then
		parent.r = r
		parent.g = g
		parent.b = b
	else
		self:assert(false, "You cannot change color with an unregistered parent frame.")
	end
end
Tablet.SetColor = wrap(Tablet.SetColor, "Tablet:SetColor")

function Tablet:GetColor(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if info then
		local data = info.data
		local detachedData = info.detachedData
		if detachedData.detached then
			return detachedData.r or 0, detachedData.g or 0, detachedData.b or 0
		else
			return data.r or 0, data.g or 0, data.b or 0
		end
	elseif type(parent) == "table" then
		return parent.r or 0, parent.g or 0, parent.b or 0
	else
		self:assert(parent, "You must provide a parent frame to check color")
	end
end
Tablet.GetColor = wrap(Tablet.GetColor, "Tablet:GetColor")

function Tablet:Detach(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	self:assert(info, "You cannot detach tablet with an unregistered parent frame.")
	self:assert(info.detachedData, "You cannot detach tablet without a data field.")
	if info.tooltip and info.tooltip == tooltip then
		tooltip:Detach()
	else
		info.detachedData.detached = true
		local detached = AcquireDetachedFrame(self, info, info.data, info.detachedData)

		detached.menu = info.menu
		local children = info.children
		function detached:children()
			if not self.preventRefresh then
				currentFrame = self
				currentTabletData = TabletData:new(self)
				self:ClearLines()
				if children then
					children()
				end
				currentTabletData:Display(currentFrame)
				self:Show(currentTabletData)
				currentTabletData:del()
				currentTabletData = nil
				currentFrame = nil
			end
		end
		detached:SetOwner(parent)
		detached:children()
	end
end
Tablet.Detach = wrap(Tablet.Detach, "Tablet:Detach")

function Tablet:Attach(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	self:assert(info, "You cannot detach tablet with an unregistered parent frame.")
	self:assert(info.detachedData, "You cannot attach tablet without a data field.")
	if info.tooltip and info.tooltip ~= tooltip then
		info.tooltip:Attach()
	else
		info.detachedData.detached = false
	end
end
Tablet.Attach = wrap(Tablet.Attach, "Tablet:Attach")

function Tablet:IsAttached(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	self:assert(info, "You cannot check tablet with an unregistered parent frame.")
	return not info.detachedData or not info.detachedData.detached
end
Tablet.IsAttached = wrap(Tablet.IsAttached, "Tablet:IsAttached")

function Tablet:Refresh(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	self:assert(info, "You cannot refresh tablet with an unregistered parent frame.")
	local tt = info.tooltip
	if tt and not tt.preventRefresh and tt:IsShown() then
		tt.updating = true
		tt:children()
		tt.updating = false
	end
end
Tablet.Refresh = wrap(Tablet.Refresh, "Tablet:Refresh")

function Tablet:IsLocked(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	self:assert(info, "You cannot detach tablet with an unregistered parent frame.")
	return info.detachedData and info.detachedData.locked
end
Tablet.IsLocked = wrap(Tablet.IsLocked, "Tablet:IsLocked")

function Tablet:ToggleLocked(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	self:assert(info, "You cannot detach tablet with an unregistered parent frame.")
	if info.tooltip and info.tooltip ~= tooltip then
		info.tooltip:Lock()
	elseif info.detachedData then
		info.detachedData.locked = info.detachedData.locked
	end
end
Tablet.ToggleLocked = wrap(Tablet.ToggleLocked, "Tablet:ToggleLocked")

function Tablet:UpdateDetachedData(parent, detachedData)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	self:assert(info, "You cannot detach tablet with an unregistered parent frame.")
	self:argCheck(detachedData, 3, "table")
	if info.data == info.detachedData then
		info.data = detachedData
	end
	info.detachedData = detachedData
	if info.detachedData.detached then
		self:Detach(parent)
	elseif info.tooltip and info.tooltip.owner then
		self:Attach(parent)
	end
end
Tablet.UpdateDetachedData = wrap(Tablet.UpdateDetachedData, "Tablet:UpdateDetachedData")

if DEBUG then
	function Tablet:ListProfileInfo()
		local duration, times, memories = GetProfileInfo()
		self:assert(duration and times and memories)
		local t = new()
		for method in pairs(memories) do
			table.insert(t, method)
		end
		table.sort(t, function(alpha, bravo)
			if memories[alpha] ~= memories[bravo] then
				return memories[alpha] < memories[bravo]
			elseif times[alpha] ~= times[bravo] then
				return times[alpha] < times[bravo]
			else
				return alpha < bravo
			end
		end)
		local memory = 0
		local time = 0
		for _,method in ipairs(t) do
			DEFAULT_CHAT_FRAME:AddMessage(format("%s || %.3f s || %.3f%% || %d KiB", method, times[method], times[method] / duration * 100, memories[method]))
			memory = memory + memories[method]
			time = time + times[method]
		end
		DEFAULT_CHAT_FRAME:AddMessage(format("%s || %.3f s || %.3f%% || %d KiB", "Total", time, time / duration * 100, memory))
		table_setn(t, 0)
		del(t)
	end
	SLASH_TABLET1 = "/tablet"
	SLASH_TABLET2 = "/tabletlib"
	SlashCmdList["TABLET"] = function(msg)
		TabletLib:GetInstance(MAJOR_VERSION):ListProfileInfo()
	end
end

local function activate(self, oldLib, oldDeactivate)
	Tablet = self
	if oldLib then
		self.registry = oldLib.registry
		self.onceRegistered = oldLib.onceRegistered
		self.tooltip = oldLib.tooltip
	else
		self.registry = {}
		self.onceRegistered = {}
	end

	tooltip = self.tooltip

	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end

local function deactivate(self)
	StopCheckingAlt()
end

AceLibrary:Register(Tablet, MAJOR_VERSION, MINOR_VERSION, activate, deactivate)
