--[[
Name: AceAddon-2.0
Revision: $Rev: 1091 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Ace 1.x by Turan (turan@gryphon.com)
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/wiki/AceAddon-2.0
SVN: http://svn.wowace.com/wowace/trunk/Ace2/AceAddon-2.0
Description: Base for all Ace addons to inherit from.
Dependencies: AceLibrary, AceOO-2.0, AceEvent-2.0, (optional) AceConsole-2.0
License: LGPL v2.1
]]

local MAJOR_VERSION = "AceAddon-2.0"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 1091 $"):match("(%d+)"))

-- This ensures the code is only executed if the libary doesn't already exist, or is a newer version
if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary.") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if not AceLibrary:HasInstance("AceOO-2.0") then error(MAJOR_VERSION .. " requires AceOO-2.0.") end

local function safecall(func,...)
	local success, err = pcall(func,...)
	if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("\n(.-: )in.-\n") or "") .. err) end
end
-- Localization
local STANDBY, TITLE, NOTES, VERSION, AUTHOR, DATE, CATEGORY, EMAIL, CREDITS, WEBSITE, CATEGORIES, ABOUT, LICENSE, PRINT_ADDON_INFO, DONATE, DONATE_DESC, HOWTO_DONATE_WINDOWS, HOWTO_DONATE_MAC
if GetLocale() == "deDE" then
	STANDBY = "|cffff5050(Standby)|r" -- capitalized

	TITLE = "Titel"
	NOTES = "Anmerkung"
	VERSION = "Version"
	AUTHOR = "Autor"
	DATE = "Datum"
	CATEGORY = "Kategorie"
	EMAIL = "E-Mail"
	WEBSITE = "Webseite"
	CREDITS = "Credits" -- fix
	LICENSE = "License" -- fix

	ABOUT = "Über"
	PRINT_ADDON_INFO = "Gibt Addondaten aus"
	DONATE = "Donate" -- fix
	DONATE_DESC = "Give a much-needed donation to the author of this addon." -- fix
	HOWTO_DONATE_WINDOWS = "Press Ctrl-A to select the link, then Ctrl-C to copy, then Alt-Tab out of the game, open your favorite web browser, and paste the link into the address bar." -- fix
	HOWTO_DONATE_MAC = "Press Cmd-A to select the link, then Cmd-C to copy, then Cmd-Tab out of the game, open your favorite web browser, and paste the link into the address bar." -- fix

	CATEGORIES = {
		["Action Bars"] = "Aktionsleisten",
		["Auction"] = "Auktion",
		["Audio"] = "Audio",
		["Battlegrounds/PvP"] = "Schlachtfeld/PvP",
		["Buffs"] = "Stärkungszauber",
		["Chat/Communication"] = "Chat/Kommunikation",
		["Druid"] = "Druide",
		["Hunter"] = "Jäger",
		["Mage"] = "Magier",
		["Paladin"] = "Paladin",
		["Priest"] = "Priester",
		["Rogue"] = "Schurke",
		["Shaman"] = "Schamane",
		["Warlock"] = "Hexenmeister",
		["Warrior"] = "Krieger",
		["Healer"] = "Heiler",
		["Tank"] = "Tank",
		["Caster"] = "Zauberer",
		["Combat"] = "Kampf",
		["Compilations"] = "Zusammenstellungen",
		["Data Export"] = "Datenexport",
		["Development Tools"] = "Entwicklungs Tools",
		["Guild"] = "Gilde",
		["Frame Modification"] = "Frame Veränderungen",
		["Interface Enhancements"] = "Interface Verbesserungen",
		["Inventory"] = "Inventar",
		["Library"] = "Bibliotheken",
		["Map"] = "Karte",
		["Mail"] = "Post",
		["Miscellaneous"] = "Diverses",
		["Quest"] = "Quest",
		["Raid"] = "Schlachtzug",
		["Tradeskill"] = "Beruf",
		["UnitFrame"] = "Einheiten-Fenster",
	}
elseif GetLocale() == "frFR" then
	STANDBY = "|cffff5050(attente)|r"

	TITLE = "Titre"
	NOTES = "Notes"
	VERSION = "Version"
	AUTHOR = "Auteur"
	DATE = "Date"
	CATEGORY = "Catégorie"
	EMAIL = "E-mail"
	WEBSITE = "Site web"
	CREDITS = "Credits" -- fix
	LICENSE = "License" -- fix

	ABOUT = "A propos"
	PRINT_ADDON_INFO = "Afficher les informations sur l'addon"
	DONATE = "Donate" -- fix
	DONATE_DESC = "Give a much-needed donation to the author of this addon." -- fix
	HOWTO_DONATE_WINDOWS = "Press Ctrl-A to select the link, then Ctrl-C to copy, then Alt-Tab out of the game, open your favorite web browser, and paste the link into the address bar." -- fix
	HOWTO_DONATE_MAC = "Press Cmd-A to select the link, then Cmd-C to copy, then Cmd-Tab out of the game, open your favorite web browser, and paste the link into the address bar." -- fix

	CATEGORIES = {
		["Action Bars"] = "Barres d'action",
		["Auction"] = "Hôtel des ventes",
		["Audio"] = "Audio",
		["Battlegrounds/PvP"] = "Champs de bataille/JcJ",
		["Buffs"] = "Buffs",
		["Chat/Communication"] = "Chat/Communication",
		["Druid"] = "Druide",
		["Hunter"] = "Chasseur",
		["Mage"] = "Mage",
		["Paladin"] = "Paladin",
		["Priest"] = "Prêtre",
		["Rogue"] = "Voleur",
		["Shaman"] = "Chaman",
		["Warlock"] = "Démoniste",
		["Warrior"] = "Guerrier",
		["Healer"] = "Soigneur",
		["Tank"] = "Tank",
		["Caster"] = "Casteur",
		["Combat"] = "Combat",
		["Compilations"] = "Compilations",
		["Data Export"] = "Exportation de données",
		["Development Tools"] = "Outils de développement",
		["Guild"] = "Guilde",
		["Frame Modification"] = "Modification des fenêtres",
		["Interface Enhancements"] = "Améliorations de l'interface",
		["Inventory"] = "Inventaire",
		["Library"] = "Bibliothèques",
		["Map"] = "Carte",
		["Mail"] = "Courrier",
		["Miscellaneous"] = "Divers",
		["Quest"] = "Quêtes",
		["Raid"] = "Raid",
		["Tradeskill"] = "Métiers",
		["UnitFrame"] = "Fenêtres d'unité",
	}
elseif GetLocale() == "koKR" then
	STANDBY = "|cffff5050(사용가능)|r"

	TITLE = "제목"
	NOTES = "노트"
	VERSION = "버전"
	AUTHOR = "저작자"
	DATE = "날짜"
	CATEGORY = "분류"
	EMAIL = "전자 우편"
	WEBSITE = "웹 사이트"
	CREDITS = "공로자"
	LICENSE = "라이센스"

	ABOUT = "정보"
	PRINT_ADDON_INFO = "애드온에 대한 정보를 출력합니다."
	DONATE = "기부"
	DONATE_DESC = "이 애드온의 저작자에게 기부를 합니다."
	HOWTO_DONATE_WINDOWS = "Ctrl-A를 눌려 링크를 선택후, Ctrl-C로 복사합니다. Alt-Tab 눌려 게임으로 부터 나간후 웹 브라우저를 엽니다. 복사된 링크를 주소 창에 붙여넣기 합니다."
	HOWTO_DONATE_MAC = "Cmd-A를 눌려 링크를 선택후, Cmd-C로 복사합니다. Cmd-Tab 눌려 게임으로 부터 나간후 웹 브라우저를 엽니다. 복사된 링크를 주소 창에 붙여넣기 합니다."

	CATEGORIES = {
		["Action Bars"] = "액션바",
		["Auction"] = "경매",
		["Audio"] = "음향",
		["Battlegrounds/PvP"] = "전장/PvP",
		["Buffs"] = "버프",
		["Chat/Communication"] = "대화/의사소통",
		["Druid"] = "드루이드",
		["Hunter"] = "사냥꾼",
		["Mage"] = "마법사",
		["Paladin"] = "성기사",
		["Priest"] = "사제",
		["Rogue"] = "도적",
		["Shaman"] = "주술사",
		["Warlock"] = "흑마법사",
		["Warrior"] = "전사",
		["Healer"] = "힐러",
		["Tank"] = "탱커",
		["Caster"] = "캐스터",
		["Combat"] = "전투",
		["Compilations"] = "복합",
		["Data Export"] = "자료 출력",
		["Development Tools"] = "개발 도구",
		["Guild"] = "길드",
		["Frame Modification"] = "구조 변경",
		["Interface Enhancements"] = "인터페이스 강화",
		["Inventory"] = "인벤토리",
		["Library"] = "라이브러리",
		["Map"] = "지도",
		["Mail"] = "우편",
		["Miscellaneous"] = "기타",
		["Quest"] = "퀘스트",
		["Raid"] = "공격대",
		["Tradeskill"] = "전문기술",
		["UnitFrame"] = "유닛 프레임",
	}
elseif GetLocale() == "zhTW" then
	STANDBY = "|cffff5050(待命)|r"

	TITLE = "標題"
	NOTES = "註記"
	VERSION = "版本"
	AUTHOR = "作者"
	DATE = "日期"
	CATEGORY = "類別"
	EMAIL = "電子郵件"
	WEBSITE = "網站"
	CREDITS = "特別感謝"
	LICENSE = "版權"

	ABOUT = "關於"
	PRINT_ADDON_INFO = "顯示插件資訊。"
	DONATE = "捐贈"
	DONATE_DESC = "捐贈金錢給插件作者。"
	HOWTO_DONATE_WINDOWS = "請按Ctrl-A選擇網站連結，Ctrl-C複製網址，Alt-Tab切換到電腦桌面，打開瀏覽器，在網址列貼上網址。"
	HOWTO_DONATE_MAC = "請按Cmd-A選擇網站連結，Cmd-C複製網址，Cmd-Tab切換到電腦桌面，打開瀏覽器，在網址列貼上網址。"

	CATEGORIES = {
		["Action Bars"] = "動作條",
		["Auction"] = "拍賣",
		["Audio"] = "音效",
		["Battlegrounds/PvP"] = "戰場/PvP",
		["Buffs"] = "增益",
		["Chat/Communication"] = "聊天/通訊",
		["Druid"] = "德魯伊",
		["Hunter"] = "獵人",
		["Mage"] = "法師",
		["Paladin"] = "聖騎士",
		["Priest"] = "牧師",
		["Rogue"] = "盜賊",
		["Shaman"] = "薩滿",
		["Warlock"] = "術士",
		["Warrior"] = "戰士",
		["Healer"] = "治療者",
		["Tank"] = "坦克",
		["Caster"] = "施法者",
		["Combat"] = "戰鬥",
		["Compilations"] = "整合",
		["Data Export"] = "資料匯出",
		["Development Tools"] = "開發工具",
		["Guild"] = "公會",
		["Frame Modification"] = "框架修改",
		["Interface Enhancements"] = "介面增強",
		["Inventory"] = "庫存",
		["Library"] = "程式庫",
		["Map"] = "地圖",
		["Mail"] = "郵件",
		["Miscellaneous"] = "雜項",
		["Quest"] = "任務",
		["Raid"] = "團隊",
		["Tradeskill"] = "交易技能",
		["UnitFrame"] = "單位框架",
	}
elseif GetLocale() == "zhCN" then
	STANDBY = "|cffff5050(暂挂)|r"

	TITLE = "标题"
	NOTES = "附注"
	VERSION = "版本"
	AUTHOR = "作者"
	DATE = "日期"
	CATEGORY = "分类"
	EMAIL = "电子邮件"
	WEBSITE = "网站"
	CREDITS = "Credits" -- fix
	LICENSE = "License" -- fix

	ABOUT = "关于"
	PRINT_ADDON_INFO = "印列出插件信息"
	DONATE = "Donate" -- fix
	DONATE_DESC = "Give a much-needed donation to the author of this addon." -- fix
	HOWTO_DONATE_WINDOWS = "Press Ctrl-A to select the link, then Ctrl-C to copy, then Alt-Tab out of the game, open your favorite web browser, and paste the link into the address bar." -- fix
	HOWTO_DONATE_MAC = "Press Cmd-A to select the link, then Cmd-C to copy, then Cmd-Tab out of the game, open your favorite web browser, and paste the link into the address bar." -- fix

	CATEGORIES = {
		["Action Bars"] = "动作条",
		["Auction"] = "拍卖",
		["Audio"] = "音频",
		["Battlegrounds/PvP"] = "战场/PvP",
		["Buffs"] = "增益魔法",
		["Chat/Communication"] = "聊天/交流",
		["Druid"] = "德鲁伊",
		["Hunter"] = "猎人",
		["Mage"] = "法师",
		["Paladin"] = "圣骑士",
		["Priest"] = "牧师",
		["Rogue"] = "盗贼",
		["Shaman"] = "萨满祭司",
		["Warlock"] = "术士",
		["Warrior"] = "战士",
		["Healer"] = "Healer",
		["Tank"] = "Tank",
		["Caster"] = "Caster",
		["Combat"] = "战斗",
		["Compilations"] = "编译",
		["Data Export"] = "数据导出",
		["Development Tools"] = "开发工具",
		["Guild"] = "公会",
		["Frame Modification"] = "框架修改",
		["Interface Enhancements"] = "界面增强",
		["Inventory"] = "背包",
		["Library"] = "库",
		["Map"] = "地图",
		["Mail"] = "邮件",
		["Miscellaneous"] = "杂项",
		["Quest"] = "任务",
		["Raid"] = "团队",
		["Tradeskill"] = "商业技能",
		["UnitFrame"] = "头像框架",
	}
elseif GetLocale() == "esES" then
	STANDBY = "|cffff5050(espera)|r"

	TITLE = "Título"
	NOTES = "Notas"
	VERSION = "Versión"
	AUTHOR = "Autor"
	DATE = "Fecha"
	CATEGORY = "Categoría"
	EMAIL = "E-mail"
	WEBSITE = "Web"
	CREDITS = "Créditos"
	LICENSE = "License" -- fix

	ABOUT = "Acerca de"
	PRINT_ADDON_INFO = "Muestra información acerca del accesorio."
	DONATE = "Donate" -- fix
	DONATE_DESC = "Give a much-needed donation to the author of this addon." -- fix
	HOWTO_DONATE_WINDOWS = "Press Ctrl-A to select the link, then Ctrl-C to copy, then Alt-Tab out of the game, open your favorite web browser, and paste the link into the address bar." -- fix
	HOWTO_DONATE_MAC = "Press Cmd-A to select the link, then Cmd-C to copy, then Cmd-Tab out of the game, open your favorite web browser, and paste the link into the address bar." -- fix

	CATEGORIES = {
		["Action Bars"] = "Barras de Acción",
		["Auction"] = "Subasta",
		["Audio"] = "Audio",
		["Battlegrounds/PvP"] = "Campos de Batalla/JcJ",
		["Buffs"] = "Buffs",
		["Chat/Communication"] = "Chat/Comunicación",
		["Druid"] = "Druida",
		["Hunter"] = "Cazador",
		["Mage"] = "Mago",
		["Paladin"] = "Paladín",
		["Priest"] = "Sacerdote",
		["Rogue"] = "Pícaro",
		["Shaman"] = "Chamán",
		["Warlock"] = "Brujo",
		["Warrior"] = "Guerrero",
		["Healer"] = "Sanador",
		["Tank"] = "Tanque",
		["Caster"] = "Conjurador",
		["Combat"] = "Combate",
		["Compilations"] = "Compilaciones",
		["Data Export"] = "Exportar Datos",
		["Development Tools"] = "Herramientas de Desarrollo",
		["Guild"] = "Hermandad",
		["Frame Modification"] = "Modificación de Marcos",
		["Interface Enhancements"] = "Mejoras de la Interfaz",
		["Inventory"] = "Inventario",
		["Library"] = "Biblioteca",
		["Map"] = "Mapa",
		["Mail"] = "Correo",
		["Miscellaneous"] = "Misceláneo",
		["Quest"] = "Misión",
		["Raid"] = "Banda",
		["Tradeskill"] = "Habilidad de Comercio",
		["UnitFrame"] = "Marco de Unidades",
	}
elseif GetLocale() == "ruRU" then
	STANDBY = "|cffff5050(в режиме ожидания)|r"

	TITLE = "Заглавие"
	NOTES = "Заметки"
	VERSION = "Версия"
	AUTHOR = "Автор"
	DATE = "Дата"
	CATEGORY = "Категория"
	EMAIL = "E-mail"
	WEBSITE = "Сайт"
	CREDITS = "Титры"
	LICENSE = "Лицензия"

	ABOUT = "О аддоне"
	PRINT_ADDON_INFO = "Показать информацию о аддоне."
	DONATE = "Пожертвовать"
	DONATE_DESC = "Отблагодарить Автора за разработку аддона."
	HOWTO_DONATE_WINDOWS = "Для выбора всей ссылки нажмите Ctrl-A, потом для её копирования Ctrl-C, чтобы свернуть игру Alt-Tab, откройте ваш браузер, и вставьте ссылку в строку адреса Ctrl-V"
	HOWTO_DONATE_MAC = "Для выбора всей ссылки нажмите Cmd-A, потом для её копирования Ctrl-C, чтобы свернуть игру Cmd-Tab, откройте ваш браузер, и вставьте ссылку в строку адреса Cmd-V"

	CATEGORIES = {
		["Action Bars"] = "Панели команд",
		["Auction"] = "Аукцион",
		["Audio"] = "Аудио",
		["Battlegrounds/PvP"] = "Поля сражений/PvP",
		["Buffs"] = "Баффы",
		["Chat/Communication"] = "Чат/Коммуникация",
		["Druid"] = "Друид",
		["Hunter"] = "Охотник",
		["Mage"] = "Маг",
		["Paladin"] = "Паладин",
		["Priest"] = "Жрец",
		["Rogue"] = "Разбойник",
		["Shaman"] = "Шаман",
		["Warlock"] = "Чернокнижник",
		["Warrior"] = "Воин",
		["Healer"] = "Лекарь",
		["Tank"] = "Танк",
		["Caster"] = "Кастер",
		["Combat"] = "Сражения",
		["Compilations"] = "Компиляция",
		["Data Export"] = "Экспорт данных",
		["Development Tools"] = "Инструменты разработчика",
		["Guild"] = "Гильдия",
		["Frame Modification"] = "Модификация фреймов",
		["Interface Enhancements"] = "Улучшение интерфейса",
		["Inventory"] = "Инвентарь",
		["Library"] = "Библиотеки",
		["Map"] = "Карта",
		["Mail"] = "Почта",
		["Miscellaneous"] = "Разное",
		["Quest"] = "Задания",
		["Raid"] = "Рейд",
		["Tradeskill"] = "Умения",
		["UnitFrame"] = "Фрейми персонажа",
	}
else -- enUS
	STANDBY = "|cffff5050(standby)|r"

	TITLE = "Title"
	NOTES = "Notes"
	VERSION = "Version"
	AUTHOR = "Author"
	DATE = "Date"
	CATEGORY = "Category"
	EMAIL = "E-mail"
	WEBSITE = "Website"
	CREDITS = "Credits"
	LICENSE = "License"

	ABOUT = "About"
	PRINT_ADDON_INFO = "Show information about the addon."
	DONATE = "Donate"
	DONATE_DESC = "Give a much-needed donation to the author of this addon."
	HOWTO_DONATE_WINDOWS = "Press Ctrl-A to select the link, then Ctrl-C to copy, then Alt-Tab out of the game, open your favorite web browser, and paste the link into the address bar."
	HOWTO_DONATE_MAC = "Press Cmd-A to select the link, then Cmd-C to copy, then Cmd-Tab out of the game, open your favorite web browser, and paste the link into the address bar."

	CATEGORIES = {
		["Action Bars"] = "Action Bars",
		["Auction"] = "Auction",
		["Audio"] = "Audio",
		["Battlegrounds/PvP"] = "Battlegrounds/PvP",
		["Buffs"] = "Buffs",
		["Chat/Communication"] = "Chat/Communication",
		["Druid"] = "Druid",
		["Hunter"] = "Hunter",
		["Mage"] = "Mage",
		["Paladin"] = "Paladin",
		["Priest"] = "Priest",
		["Rogue"] = "Rogue",
		["Shaman"] = "Shaman",
		["Warlock"] = "Warlock",
		["Warrior"] = "Warrior",
		["Healer"] = "Healer",
		["Tank"] = "Tank",
		["Caster"] = "Caster",
		["Combat"] = "Combat",
		["Compilations"] = "Compilations",
		["Data Export"] = "Data Export",
		["Development Tools"] = "Development Tools",
		["Guild"] = "Guild",
		["Frame Modification"] = "Frame Modification",
		["Interface Enhancements"] = "Interface Enhancements",
		["Inventory"] = "Inventory",
		["Library"] = "Library",
		["Map"] = "Map",
		["Mail"] = "Mail",
		["Miscellaneous"] = "Miscellaneous",
		["Quest"] = "Quest",
		["Raid"] = "Raid",
		["Tradeskill"] = "Tradeskill",
		["UnitFrame"] = "UnitFrame",
	}
end

setmetatable(CATEGORIES, { __index = function(self, key) -- case-insensitive
	local lowerKey = key:lower()
	for k,v in pairs(CATEGORIES) do
		if k:lower() == lowerKey then
			self[lowerKey] = v
			return v
		end
	end
end })

-- Create the library object

local AceOO = AceLibrary("AceOO-2.0")
local AceAddon = AceOO.Class()
local AceEvent
local AceConsole
local AceModuleCore

function AceAddon:GetLocalizedCategory(name)
	self:argCheck(name, 2, "string")
	return CATEGORIES[name] or UNKNOWN
end

function AceAddon:ToString()
	return "AceAddon"
end

local function print(text)
	DEFAULT_CHAT_FRAME:AddMessage(text)
end

function AceAddon:ADDON_LOADED(name)
	local unregister = true
	local initAddon = {}
	while #self.nextAddon > 0 do
		local addon = table.remove(self.nextAddon, 1)
		if addon.possibleNames[name] then
			table.insert(initAddon, addon)
		else
			unregister = nil
			table.insert(self.skipAddon, addon)
		end
	end
	self.nextAddon, self.skipAddon = self.skipAddon, self.nextAddon
	if unregister then
		AceAddon:UnregisterEvent("ADDON_LOADED")
	end
	while #initAddon > 0 do
		local addon = table.remove(initAddon, 1)
		table.insert(self.addons, addon)
		if not self.addons[name] then
			self.addons[name] = addon
		end
		addon.possibleNames = nil
		self:InitializeAddon(addon, name)
	end
end

local function RegisterOnEnable(self)
	if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.defaultLanguage then -- HACK
		AceAddon.playerLoginFired = true
	end
	if AceAddon.playerLoginFired then
		AceAddon.addonsStarted[self] = true
		if (type(self.IsActive) ~= "function" or self:IsActive()) and (not AceModuleCore or not AceModuleCore:IsModule(self) or AceModuleCore:IsModuleActive(self)) then
			AceAddon:ManualEnable(self)
		end
	else
		if not AceAddon.addonsToOnEnable then
			AceAddon.addonsToOnEnable = {}
		end
		table.insert(AceAddon.addonsToOnEnable, self)
	end
end

function AceAddon:InitializeAddon(addon, name)
	if addon.name == nil then
		addon.name = name
	end
	if GetAddOnMetadata then
		-- TOC checks
		if addon.title == nil then
			addon.title = GetAddOnMetadata(name, "Title")
		end
		if type(addon.title) == "string" then
			local num = addon.title:find(" |cff7fff7f %-Ace2%-|r$")
			if num then
				addon.title = addon.title:sub(1, num - 1)
			end
			addon.title = addon.title:trim()
		end
		if addon.notes == nil then
			addon.notes = GetAddOnMetadata(name, "Notes")
		end
		if type(addon.notes) == "string" then
			addon.notes = addon.notes:trim()
		end
		if addon.version == nil then
			addon.version = GetAddOnMetadata(name, "Version")
		end
		if type(addon.version) == "string" then
			if addon.version:find("%$Revision: (%d+) %$") then
				addon.version = addon.version:gsub("%$Revision: (%d+) %$", "%1")
			elseif addon.version:find("%$Rev: (%d+) %$") then
				addon.version = addon.version:gsub("%$Rev: (%d+) %$", "%1")
			elseif addon.version:find("%$LastChangedRevision: (%d+) %$") then
				addon.version = addon.version:gsub("%$LastChangedRevision: (%d+) %$", "%1")
			end
			addon.version = addon.version:trim()
		end
		if addon.author == nil then
			addon.author = GetAddOnMetadata(name, "Author")
		end
		if type(addon.author) == "string" then
			addon.author = addon.author:trim()
		end
		if addon.credits == nil then
			addon.credits = GetAddOnMetadata(name, "X-Credits")
		end
		if type(addon.credits) == "string" then
			addon.credits = addon.credits:trim()
		end
		if addon.donate == nil then
			addon.donate = GetAddOnMetadata(name, "X-Donate")
		end
		if type(addon.donate) == "string" then
			addon.donate = addon.donate:trim()
		end
		if addon.date == nil then
			addon.date = GetAddOnMetadata(name, "X-Date") or GetAddOnMetadata(name, "X-ReleaseDate")
		end
		if type(addon.date) == "string" then
			if addon.date:find("%$Date: (.-) %$") then
				addon.date = addon.date:gsub("%$Date: (.-) %$", "%1")
			elseif addon.date:find("%$LastChangedDate: (.-) %$") then
				addon.date = addon.date:gsub("%$LastChangedDate: (.-) %$", "%1")
			end
			addon.date = addon.date:trim()
		end

		if addon.category == nil then
			addon.category = GetAddOnMetadata(name, "X-Category")
		end
		if type(addon.category) == "string" then
			addon.category = addon.category:trim()
		end
		if addon.email == nil then
			addon.email = GetAddOnMetadata(name, "X-eMail") or GetAddOnMetadata(name, "X-Email")
		end
		if type(addon.email) == "string" then
			addon.email = addon.email:trim()
		end
		if addon.license == nil then
			addon.license = GetAddOnMetadata(name, "X-License")
		end
		if type(addon.license) == "string" then
			addon.license = addon.license:trim()
		end
		if addon.website == nil then
			addon.website = GetAddOnMetadata(name, "X-Website")
		end
		if type(addon.website) == "string" then
			addon.website = addon.website:trim()
		end
	end
	local current = addon.class
	while true do
		if current == AceOO.Class or not current then
			break
		end
		if current.mixins then
			for mixin in pairs(current.mixins) do
				if type(mixin.OnEmbedInitialize) == "function" then
					mixin:OnEmbedInitialize(addon, name)
				end
			end
		end
		current = current.super
	end
	local n = AceAddon.addonsToOnEnable and #AceAddon.addonsToOnEnable or 0

	if type(addon.OnInitialize) == "function" then
		safecall(addon.OnInitialize, addon, name)
	end
	if AceEvent then
		AceEvent:TriggerEvent("Ace2_AddonInitialized", addon)
	end
	RegisterOnEnable(addon)
	local n2 = AceAddon.addonsToOnEnable and #AceAddon.addonsToOnEnable or 0
	if n2 - n > 1 then
		local mine = table.remove(AceAddon.addonsToOnEnable)
		table.insert(AceAddon.addonsToOnEnable, n+1, mine)
	end
end

local aboutFrame
local function createAboutFrame()
	aboutFrame = CreateFrame("Frame", "AceAddon20AboutFrame", UIParent, "DialogBoxFrame")
	aboutFrame:SetWidth(500)
	aboutFrame:SetHeight(400)
	aboutFrame:SetPoint("CENTER")
	aboutFrame:SetBackdrop({
		bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
	    edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
	    tile = true, tileSize = 16, edgeSize = 16,
	    insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	aboutFrame:SetBackdropColor(0,0,0,1)

	local donateButton = CreateFrame("Button", "AceAddon20AboutFrameDonateButton", aboutFrame, "UIPanelButtonTemplate2")
	aboutFrame.donateButton = donateButton
	donateButton:SetPoint("BOTTOMRIGHT", -20, 20)
	_G.AceAddon20AboutFrameDonateButtonText:SetText(DONATE)
	donateButton:SetWidth(_G.AceAddon20AboutFrameDonateButtonText:GetWidth()+20)
	donateButton:SetScript("OnClick", function()
		aboutFrame.currentAddon:OpenDonationFrame()
	end)

	local text = aboutFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	aboutFrame.title = text
	text:SetPoint("TOP", 0, -5)

	aboutFrame:Hide()

	aboutFrame.lefts = {}
	aboutFrame.rights = {}
	aboutFrame.textLefts = {}
	aboutFrame.textRights = {}
	function aboutFrame:Clear()
		self.title:SetText("")
		for i = 1, #self.lefts do
			self.lefts[i] = nil
			self.rights[i] = nil
		end
	end

	function aboutFrame:AddLine(left, right)
		aboutFrame.lefts[#aboutFrame.lefts+1] = left
		aboutFrame.rights[#aboutFrame.rights+1] = right
	end

	local aboutFrame_Show = aboutFrame.Show
	function aboutFrame:Show(...)
		local maxLeftWidth = 0
		local maxRightWidth = 0
		local textHeight = 0
		for i = 1, #self.lefts do
			if not self.textLefts[i] then
				local left = aboutFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				self.textLefts[i] = left
				local right = aboutFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				self.textRights[i] = right
				if i == 1 then
					left:SetPoint("TOPRIGHT", aboutFrame, "TOPLEFT", 75, -35)
				else
					left:SetPoint("TOPRIGHT", self.textLefts[i-1], "BOTTOMRIGHT", 0, -5)
				end
				right:SetPoint("LEFT", left, "RIGHT", 5, 0)
			end
			self.textLefts[i]:SetText(self.lefts[i] .. ":")
			self.textRights[i]:SetText(self.rights[i])
			local leftWidth = self.textLefts[i]:GetWidth()
			local rightWidth = self.textRights[i]:GetWidth()
			textHeight = self.textLefts[i]:GetHeight()
			if maxLeftWidth < leftWidth then
				maxLeftWidth = leftWidth
			end
			if maxRightWidth < rightWidth then
				maxRightWidth = rightWidth
			end
		end
		for i = #self.lefts+1, #self.textLefts do
			self.textLefts[i]:SetText('')
			self.textRights[i]:SetText('')
		end
		aboutFrame:SetWidth(75 + maxRightWidth + 20)
		aboutFrame:SetHeight(#self.lefts * (textHeight + 5) + 100)

		aboutFrame_Show(self, ...)
	end
	aboutFrame:Hide()

	createAboutFrame = nil
end
local donateFrame

local function unobfuscateEmail(email)
	return email:gsub(" AT ", "@"):gsub(" DOT ", ".")
end

local function isGoodVariable(var)
	return type(var) == "string" or type(var) == "number"
end
function AceAddon.prototype:PrintAddonInfo()
	if createAboutFrame then
		createAboutFrame()
	end
	aboutFrame:Clear()
	local x
	if isGoodVariable(self.title) then
		x = tostring(self.title)
	elseif isGoodVariable(self.name) then
		x = tostring(self.name)
	else
		x = "<" .. tostring(self.class) .. " instance>"
	end
	if type(self.IsActive) == "function" then
		if not self:IsActive() then
			x = x .. " " .. STANDBY
		end
	end
	aboutFrame.title:SetText(x)

	if isGoodVariable(self.version) then
		aboutFrame:AddLine(VERSION, tostring(self.version))
	end
	if isGoodVariable(self.notes) then
		aboutFrame:AddLine(NOTES, tostring(self.notes))
	end
	if isGoodVariable(self.author) then
		aboutFrame:AddLine(AUTHOR, tostring(self.author))
	end
	if isGoodVariable(self.credits) then
		aboutFrame:AddLine(CREDITS, tostring(self.credits))
	end
	if isGoodVariable(self.date) then
		aboutFrame:AddLine(DATE, tostring(self.date))
	end
	if isGoodVariable(self.category) then
		local category = CATEGORIES[self.category]
		aboutFrame:AddLine(CATEGORY, category or tostring(self.category))
	end
	if isGoodVariable(self.email) then
		aboutFrame:AddLine(EMAIL, unobfuscateEmail(tostring(self.email)))
	end
	if isGoodVariable(self.website) then
		aboutFrame:AddLine(WEBSITE, tostring(self.website))
	end
	if isGoodVariable(self.license) then
		aboutFrame:AddLine(LICENSE, tostring(self.license))
	end

	if donateFrame and donateFrame:IsShown() then
		donateFrame:Hide()
	end

	aboutFrame.currentAddon = self

	aboutFrame:Show()

	if self.donate then
		aboutFrame.donateButton:Show()
	else
		aboutFrame.donateButton:Hide()
	end
end

local function createDonateFrame()
	donateFrame = CreateFrame("Frame", "AceAddon20Frame", UIParent, "DialogBoxFrame")

	donateFrame:SetWidth(500)
	donateFrame:SetHeight(200)
	donateFrame:SetPoint("CENTER")
	donateFrame:SetBackdrop({
		bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	donateFrame:SetBackdropColor(0,0,0,1)

	local text = donateFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	text:SetPoint("TOP", 0, -5)
	text:SetText(DONATE)

	local howto = donateFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	howto:SetPoint("TOP", text, "BOTTOM", 0, -5)
	howto:SetPoint("LEFT", 16, 0)
	howto:SetPoint("RIGHT", -16, 0)
	if not IsMacClient() then
		-- Windows or Linux
		howto:SetText(HOWTO_DONATE_WINDOWS)
	else
		howto:SetText(HOWTO_DONATE_MAC)
	end

	local scrollFrame = CreateFrame("ScrollFrame", "AceAddon20FrameScrollFrame", donateFrame, "UIPanelScrollFrameTemplate")
	scrollFrame:SetToplevel(true)
	scrollFrame:SetPoint("TOP", -10, -76)
	scrollFrame:SetWidth(455)
	scrollFrame:SetHeight(70)
	howto:SetPoint("BOTTOM", scrollFrame, "TOP")

	local editBox = CreateFrame("EditBox", nil, scrollFrame)
	donateFrame.editBox = editBox
	scrollFrame:SetScrollChild(editBox)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:SetWidth(450)
	editBox:SetHeight(54)
	editBox:SetPoint("BOTTOM", 5, 0)
	editBox:SetJustifyH("LEFT")
	editBox:SetJustifyV("TOP")
	editBox:SetAutoFocus(false)
	editBox:SetScript("OnTextChanged", function(this)
		if this:GetText() ~= this.text then
			this:SetText(this.text)
		end
	end)
	editBox:SetScript("OnEscapePressed", function(this)
		this:ClearFocus()
	end)
	createDonateFrame = nil
end

local function fix(char)
	return ("%%%02x"):format(char:byte())
end

local function urlencode(text)
	return text:gsub("[^0-9A-Za-z]", fix)
end

function AceAddon.prototype:OpenDonationFrame()
	if createDonateFrame then
		createDonateFrame()
	end
	local donate = self.donate
	if type(donate) ~= "string" then
		donate = "Wowace"
	end
	local style, data = (":"):split(donate, 2)
	style = style:lower()
	if style ~= "website" and style ~= "paypal" then
		style = "wowace"
	end
	if style == "wowace" then
		donateFrame.editBox.text = "http://www.wowace.com/wiki/Donations"
	elseif style == "website" then
		donateFrame.editBox.text = data
	else -- PayPal
		local text = "https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=" .. urlencode(unobfuscateEmail(data))
		local name
		if type(self.title) == "string" then
			name = self.title
		elseif type(self.name) == "string" then
			name = self.name
		end
		if name then
			name = name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
			text = text .. "&item_name=" .. urlencode(name)
		end
		donateFrame.editBox.text = text
	end
	donateFrame.editBox:SetText(donateFrame.editBox.text)

	if aboutFrame and aboutFrame:IsShown() then
		aboutFrame:Hide()
	end

	donateFrame:Show()

	donateFrame.editBox:SetFocus()
end

local options
function AceAddon:GetAceOptionsDataTable(target)
	return {
		about = {
			name = ABOUT,
			desc = PRINT_ADDON_INFO,
			type = "execute",
			func = "PrintAddonInfo",
			order = -1,
		},
		donate = {
			name = DONATE,
			desc = DONATE_DESC,
			type = "execute",
			func = "OpenDonationFrame",
			order = -1,
			hidden = function()
				return not target.donate
			end
		}
	}
end

function AceAddon:PLAYER_LOGIN()
	self.playerLoginFired = true
	if self.addonsToOnEnable then
		while #self.addonsToOnEnable > 0 do
			local addon = table.remove(self.addonsToOnEnable, 1)
			self.addonsStarted[addon] = true
			if (type(addon.IsActive) ~= "function" or addon:IsActive()) and (not AceModuleCore or not AceModuleCore:IsModule(addon) or AceModuleCore:IsModuleActive(addon)) then
				AceAddon:ManualEnable(addon)
			end
		end
		self.addonsToOnEnable = nil
	end
end

function AceAddon.prototype:Inject(t)
	AceAddon:argCheck(t, 2, "table")
	for k,v in pairs(t) do
		self[k] = v
	end
end

function AceAddon.prototype:init()
	if not AceEvent then
		error(MAJOR_VERSION .. " requires AceEvent-2.0", 4)
	end
	AceAddon.super.prototype.init(self)

	self.super = self.class.prototype

	AceAddon:RegisterEvent("ADDON_LOADED", "ADDON_LOADED")
	local names = {}
	for i = 1, GetNumAddOns() do
		if IsAddOnLoaded(i) then names[GetAddOnInfo(i)] = true end
	end
	self.possibleNames = names
	table.insert(AceAddon.nextAddon, self)
end

function AceAddon.prototype:ToString()
	local x
	if type(self.title) == "string" then
		x = self.title
	elseif type(self.name) == "string" then
		x = self.name
	else
		x = "<" .. tostring(self.class) .. " instance>"
	end
	if (type(self.IsActive) == "function" and not self:IsActive()) or (AceModuleCore and AceModuleCore:IsModule(addon) and AceModuleCore:IsModuleActive(addon)) then
		x = x .. " " .. STANDBY
	end
	return x
end

AceAddon.new = function(self, ...)
	local class = AceAddon:pcall(AceOO.Classpool, self, ...)
	return class:new()
end

function AceAddon:ManualEnable(addon)
	AceAddon:argCheck(addon, 2, "table")
	local first = nil
	if AceOO.inherits(addon, "AceAddon-2.0") then
		if AceAddon.addonsEnabled and not AceAddon.addonsEnabled[addon] then
			first = true
			AceAddon.addonsEnabled[addon] = true
		end
	end
	local current = addon.class
	while current and current ~= AceOO.Class do
		if current.mixins then
			for mixin in pairs(current.mixins) do
				if type(mixin.OnEmbedEnable) == "function" then
					safecall(mixin.OnEmbedEnable, mixin, addon, first)
				end
			end
		end
		current = current.super
	end
	if type(addon.OnEnable) == "function" then
		safecall(addon.OnEnable, addon, first)
	end
	if AceEvent then
		AceEvent:TriggerEvent("Ace2_AddonEnabled", addon, first)
	end
end

function AceAddon:ManualDisable(addon)
	AceAddon:argCheck(addon, 2, "table")
	local current = addon.class
	while current and current ~= AceOO.Class do
		if current.mixins then
			for mixin in pairs(current.mixins) do
				if type(mixin.OnEmbedDisable) == "function" then
					safecall(mixin.OnEmbedDisable, mixin, addon)
				end
			end
		end
		current = current.super
	end
	if type(module.OnDisable) == "function" then
		safecall(module.OnDisable, addon)
	end
	if AceEvent then
		AceEvent:TriggerEvent("Ace2_AddonDisabled", addon)
	end
end

local function external(self, major, instance)
	if major == "AceEvent-2.0" then
		AceEvent = instance

		AceEvent:embed(self)

		self:RegisterEvent("PLAYER_LOGIN", "PLAYER_LOGIN", true)
	elseif major == "AceConsole-2.0" then
		AceConsole = instance

		local slashCommands = { "/ace2" }
		local _,_,_,enabled,loadable = GetAddOnInfo("Ace")
		if not enabled or not loadable then
			table.insert(slashCommands, "/ace")
		end
		local function listAddon(addon, depth)
			if not depth then
				depth = 0
			end

			local s = ("  "):rep(depth) .. " - " .. tostring(addon)
			if rawget(addon, 'version') then
				s = s .. " - |cffffff7f" .. tostring(addon.version) .. "|r"
			end
			if rawget(addon, 'slashCommand') then
				s = s .. " |cffffff7f(" .. tostring(addon.slashCommand) .. ")|r"
			end
			print(s)
			if type(rawget(addon, 'modules')) == "table" then
				local i = 0
				for k,v in pairs(addon.modules) do
					i = i + 1
					if i == 6 then
						print(("  "):rep(depth + 1) .. " - more...")
						break
					else
						listAddon(v, depth + 1)
					end
				end
			end
		end
		local function listNormalAddon(i)
			local name,_,_,enabled,loadable = GetAddOnInfo(i)
			if not loadable then
				enabled = false
			end
			if self.addons[name] then
				listAddon(self.addons[name])
			else
				local s = " - " .. tostring(GetAddOnMetadata(i, "Title") or name)
				local version = GetAddOnMetadata(i, "Version")
				if version then
					if version:find("%$Revision: (%d+) %$") then
						version = version:gsub("%$Revision: (%d+) %$", "%1")
					elseif version:find("%$Rev: (%d+) %$") then
						version = version:gsub("%$Rev: (%d+) %$", "%1")
					elseif version:find("%$LastChangedRevision: (%d+) %$") then
						version = version:gsub("%$LastChangedRevision: (%d+) %$", "%1")
					end
					s = s .. " - |cffffff7f" .. version .. "|r"
				end
				if not enabled then
					s = s .. " |cffff0000(disabled)|r"
				end
				if IsAddOnLoadOnDemand(i) then
					s = s .. " |cff00ff00[LoD]|r"
				end
				print(s)
			end
		end
		local function mySort(alpha, bravo)
			return tostring(alpha) < tostring(bravo)
		end
		AceConsole.RegisterChatCommand(self, slashCommands, {
			desc = "AddOn development framework",
			name = "Ace2",
			type = "group",
			args = {
				about = {
					desc = "Get information about Ace2",
					name = "About",
					type = "execute",
					func = function()
						print("|cffffff7fAce2|r - |cffffff7f2.0." .. MINOR_VERSION:gsub("%$Revision: (%d+) %$", "%1") .. "|r - AddOn development framework")
						print(" - |cffffff7f" .. AUTHOR .. ":|r Ace Development Team")
						print(" - |cffffff7f" .. WEBSITE .. ":|r http://www.wowace.com/")
					end
				},
				list = {
					desc = "List addons",
					name = "List",
					type = "group",
					args = {
						ace2 = {
							desc = "List addons using Ace2",
							name = "Ace2",
							type = "execute",
							func = function()
								print("|cffffff7fAddon list:|r")
								table.sort(self.addons, mySort)
								for _,v in ipairs(self.addons) do
									listAddon(v)
								end
							end
						},
						all = {
							desc = "List all addons",
							name = "All",
							type = "execute",
							func = function()
								print("|cffffff7fAddon list:|r")
								local count = GetNumAddOns()
								for i = 1, count do
									listNormalAddon(i)
								end
							end
						},
						enabled = {
							desc = "List all enabled addons",
							name = "Enabled",
							type = "execute",
							func = function()
								print("|cffffff7fAddon list:|r")
								local count = GetNumAddOns()
								for i = 1, count do
									local _,_,_,enabled,loadable = GetAddOnInfo(i)
									if enabled and loadable then
										listNormalAddon(i)
									end
								end
							end
						},
						disabled = {
							desc = "List all disabled addons",
							name = "Disabled",
							type = "execute",
							func = function()
								print("|cffffff7fAddon list:|r")
								local count = GetNumAddOns()
								for i = 1, count do
									local _,_,_,enabled,loadable = GetAddOnInfo(i)
									if not enabled or not loadable then
										listNormalAddon(i)
									end
								end
							end
						},
						lod = {
							desc = "List all LoadOnDemand addons",
							name = "LoadOnDemand",
							type = "execute",
							func = function()
								print("|cffffff7fAddon list:|r")
								local count = GetNumAddOns()
								for i = 1, count do
									if IsAddOnLoadOnDemand(i) then
										listNormalAddon(i)
									end
								end
							end
						},
						ace1 = {
							desc = "List all addons using Ace1",
							name = "Ace 1.x",
							type = "execute",
							func = function()
								print("|cffffff7fAddon list:|r")
								local count = GetNumAddOns()
								for i = 1, count do
									local dep1, dep2, dep3, dep4 = GetAddOnDependencies(i)
									if dep1 == "Ace" or dep2 == "Ace" or dep3 == "Ace" or dep4 == "Ace" then
										listNormalAddon(i)
									end
								end
							end
						},
						libs = {
							desc = "List all libraries using AceLibrary",
							name = "Libraries",
							type = "execute",
							func = function()
								if type(AceLibrary) == "table" and type(AceLibrary.libs) == "table" then
									print("|cffffff7fLibrary list:|r")
									for name, data in pairs(AceLibrary.libs) do
										local s
										if data.minor then
											s = " - " .. tostring(name) .. "." .. tostring(data.minor)
										else
											s = " - " .. tostring(name)
										end
										if rawget(AceLibrary(name), 'slashCommand') then
											s = s .. " |cffffff7f(" .. tostring(AceLibrary(name).slashCommand) .. "|cffffff7f)"
										end
										print(s)
									end
								end
							end
						},
						search = {
							desc = "Search by name",
							name = "Search",
							type = "text",
							usage = "<keyword>",
							input = true,
							get = false,
							set = function(...)
								local arg = { ... }
								for i,v in ipairs(arg) do
									arg[i] = v:gsub('%*', '.*'):gsub('%%', '%%%%'):lower()
								end
								local count = GetNumAddOns()
								for i = 1, count do
									local name = GetAddOnInfo(i)
									local good = true
									for _,v in ipairs(arg) do
										if not name:lower():find(v) then
											good = false
											break
										end
									end
									if good then
										listNormalAddon(i)
									end
								end
							end
						}
					},
				},
				enable = {
					desc = "Enable addon(s).",
					name = "Enable",
					type = "text",
					usage = "<addon 1> <addon 2> ...",
					get = false,
					input = true,
					set = function(...)
						for i = 1, select("#", ...) do
							local addon = select(i, ...)
							local name, title, _, enabled, _, reason = GetAddOnInfo(addon)
							if reason == "MISSING" then
								print(("|cffffff7fAce2:|r AddOn %q does not exist."):format(addon))
							elseif not enabled then
								EnableAddOn(addon)
								print(("|cffffff7fAce2:|r %s is now enabled."):format(addon or name))
							else
								print(("|cffffff7fAce2:|r %s is already enabled."):format(addon or name))
							end
						end
					end,
				},
				disable = {
					desc = "Disable addon(s).",
					name = "Disable",
					type = "text",
					usage = "<addon 1> <addon 2> ...",
					get = false,
					input = true,
					set = function(...)
						for i = 1, select("#", ...) do
							local addon = select(i, ...)
							local name, title, _, enabled, _, reason = GetAddOnInfo(addon)
							if reason == "MISSING" then
							print(("|cffffff7fAce2:|r AddOn %q does not exist."):format(addon))
							elseif enabled then
								DisableAddOn(addon)
								print(("|cffffff7fAce2:|r %s is now disabled."):format(addon or name))
							else
								print(("|cffffff7fAce2:|r %s is already disabled."):format(addon or name))
							end
						end
					end,
				},
				load = {
					desc = "Load addon(s).",
					name = "Load",
					type = "text",
					usage = "<addon 1> <addon 2> ...",
					get = false,
					input = true,
					set = function(...)
						for i = 1, select("#", ...) do
							local addon = select(i, ...)
							local name, title, _, _, loadable, reason = GetAddOnInfo(addon)
							if reason == "MISSING" then
								print(("|cffffff7fAce2:|r AddOn %q does not exist."):format(addon))
							elseif not loadable then
								print(("|cffffff7fAce2:|r AddOn %q is not loadable. Reason: %s."):format(addon, reason))
							else
								LoadAddOn(addon)
								print(("|cffffff7fAce2:|r %s is now loaded."):format(addon or name))
							end
						end
					end
				},
				info = {
					desc = "Display information",
					name = "Information",
					type = "execute",
					func = function()
						local mem, threshold = gcinfo()
						print((" - |cffffff7fMemory usage [|r%.3f MiB|cffffff7f]|r"):format(mem / 1024))
						if threshold then
							print((" - |cffffff7fThreshold [|r%.3f MiB|cffffff7f]|r"):format(threshold / 1024))
						end
						print((" - |cffffff7fFramerate [|r%.0f fps|cffffff7f]|r"):format(GetFramerate()))
						local bandwidthIn, bandwidthOut, latency = GetNetStats()
						bandwidthIn, bandwidthOut = floor(bandwidthIn * 1024), floor(bandwidthOut * 1024)
						print((" - |cffffff7fLatency [|r%.0f ms|cffffff7f]|r"):format(latency))
						print((" - |cffffff7fBandwidth in [|r%.0f B/s|cffffff7f]|r"):format(bandwidthIn))
						print((" - |cffffff7fBandwidth out [|r%.0f B/s|cffffff7f]|r"):format(bandwidthOut))
						print((" - |cffffff7fTotal addons [|r%d|cffffff7f]|r"):format(GetNumAddOns()))
						print((" - |cffffff7fAce2 addons [|r%d|cffffff7f]|r"):format(#self.addons))
						local ace = 0
						local enabled = 0
						local disabled = 0
						local lod = 0
						for i = 1, GetNumAddOns() do
							local dep1, dep2, dep3, dep4 = GetAddOnDependencies(i)
							if dep1 == "Ace" or dep2 == "Ace" or dep3 == "Ace" or dep4 == "Ace" then
								ace = ace + 1
							end
							if IsAddOnLoadOnDemand(i) then
								lod = lod + 1
							end
							local isActive, loadable = select(4, GetAddOnInfo(i))
							if not isActive or not loadable then
								disabled = disabled + 1
							else
								enabled = enabled + 1
							end
						end
						print((" - |cffffff7fAce 1.x addons [|r%d|cffffff7f]|r"):format(ace))
						print((" - |cffffff7fLoadOnDemand addons [|r%d|cffffff7f]|r"):format(lod))
						print((" - |cffffff7fenabled addons [|r%d|cffffff7f]|r"):format(enabled))
						print((" - |cffffff7fdisabled addons [|r%d|cffffff7f]|r"):format(disabled))
						local libs = 0
						if type(AceLibrary) == "table" and type(AceLibrary.libs) == "table" then
							for _ in pairs(AceLibrary.libs) do
								libs = libs + 1
							end
						end
						print((" - |cffffff7fAceLibrary instances [|r%d|cffffff7f]|r"):format(libs))
					end
				}
			}
		})
	elseif major == "AceModuleCore-2.0" then
		AceModuleCore = instance
	end
end

local function activate(self, oldLib, oldDeactivate)
	AceAddon = self

	self.playerLoginFired = oldLib and oldLib.playerLoginFired or DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.defaultLanguage
	self.addonsToOnEnable = oldLib and oldLib.addonsToOnEnable
	self.addons = oldLib and oldLib.addons or {}
	self.nextAddon = oldLib and oldLib.nextAddon or {}
	self.skipAddon = oldLib and oldLib.skipAddon or {}
	self.addonsStarted = oldLib and oldLib.addonsStarted or {}
	self.addonsEnabled = oldLib and oldLib.addonsEnabled or {}

	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end

AceLibrary:Register(AceAddon, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)
