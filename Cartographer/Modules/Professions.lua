local revision = tonumber(string.sub("$Revision: 18625 $", 12, -3))
if revision > Cartographer.revision then
	Cartographer.version = "r" .. revision
	Cartographer.revision = revision
	Cartographer.date = string.sub("$Date: 2006-12-02 16:13:35 +0300 (Сб, 02 дек 2006) $", 8, 17)
end

local bs = AceLibrary("Babble-Spell-2.2")
local L = AceLibrary("AceLocale-2.2"):new("Cartographer_Professions")
L:RegisterTranslations("enUS", function() return {
	["Professions"] = true,

	["Stub for loading Cartographer module addons based on your professions."] = true,
	["Unable to load addon `%s': %s"] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Professions"] = "전문 기술",

	["Stub for loading Cartographer module addons based on your professions."] = "당신의 직업에 기초를 둔 Cartographer 모듈 애드온을 불려옵니다.",
	["Unable to load addon `%s': %s"] = "%s 애드온 로드 실패: %s",
} end)

local mod = Cartographer:NewModule('Professions', 'AceEvent-2.0', 'AceConsole-2.0')

function mod:OnInitialize()
	self.name    = L["Professions"]
	self.title   = L["Professions"]
	self.author  = 'Chris "kergoth" Larson'
	self.notes   = L["Stub for loading Cartographer module addons based on your professions."]
	self.email   = 'clarson@kergoth.com'
	self.website = nil
	self.version = nil

	local opts = {
		name = L["Professions"],
		desc = L["Stub for loading Cartographer module addons based on your professions."],
		type = 'group',
		args = {
			toggle = {
				name = AceLibrary("AceLocale-2.2"):new("Cartographer")["Active"],
				desc = AceLibrary("AceLocale-2.2"):new("Cartographer")["Suspend/resume this module."],
				type  = 'toggle',
				order = -1,
				get   = function() return Cartographer:IsModuleActive(self) end,
				set   = function() Cartographer:ToggleModuleActive(self) end,
			},
		},
		handler = self,
	}
	self:RegisterChatCommand({'/cartprof'}, opts)
	Cartographer.options.args.Professions = opts

	self.addons = {}
end

function mod:OnEnable()
	self:RegisterEvent('SKILL_LINES_CHANGED')
	self:SKILL_LINES_CHANGED()
end

function mod:SKILL_LINES_CHANGED()
	local skills = {}
	for i=1,GetNumSkillLines() do
		local skillname, isHeader = GetSkillLineInfo(i)
		if not isHeader then
			skills[skillname] = true
		end
	end

	for n=1,GetNumAddOns() do
		local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(n)
		local pipometa = GetAddOnMetadata(n, 'X-Cartographer-Prof')
		if pipometa then
			for skillname in pairs(skills) do
				if bs:HasReverseTranslation(skillname) and pipometa == bs:GetReverseTranslation(skillname) then
					if not IsAddOnLoaded(n) then
						if enabled and loadable then
							local loaded, reason = LoadAddOn(n)
							if not loaded then
								self:Print(L["Unable to load addon `%s': %s"], name, reason)
							end
						end
					elseif self.addons[skillname] then
						Cartographer:ToggleModuleActive(self.addons[skillname], true)
					end
				end
			end
		end
	end

	for k,v in pairs(self.addons) do
		if not skills[k] then
			Cartographer:ToggleModuleActive(v, false)
		end
	end
end
