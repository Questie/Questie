local revision = tonumber(string.sub("$Revision: 18625 $", 12, -3))
if revision > Cartographer.revision then
	Cartographer.version = "r" .. revision
	Cartographer.revision = revision
	Cartographer.date = string.sub("$Date: 2006-12-02 16:13:35 +0300 (Сб, 02 дек 2006) $", 8, 17)
end

local L = AceLibrary("AceLocale-2.2"):new("Cartographer_InstanceNotes")

Cartographer_InstanceNotes = Cartographer:NewModule("InstanceNotes", "AceConsole-2.0")

function Cartographer_InstanceNotes:OnInitialize()
	self.name = L["Instance Notes"]
	self.title = L["Instance Notes"]
    Cartographer.options.args.InstanceNotes = {
        name = L["Instance Notes"],
        desc = L["Module which adds default notes to the instance maps."],
        type = 'group',
        args = {
            toggle = {
				name = AceLibrary("AceLocale-2.2"):new("Cartographer")["Active"],
				desc = AceLibrary("AceLocale-2.2"):new("Cartographer")["Suspend/resume this module."],
                type = "toggle",
                order = -1,
                get = function() return Cartographer:IsModuleActive(self) end,
                set = function() Cartographer:ToggleModuleActive(self) end
            },
        },
        handler = self,
    }
end

function Cartographer_InstanceNotes:OnEnable()
    if Cartographer_Notes then
        Cartographer_Notes:RegisterNotesDatabase("InstanceNotes", self.notes)
    end
end

function Cartographer_InstanceNotes:OnDisable()
    if Cartographer_Notes then
        Cartographer_Notes:UnregisterNotesDatabase("InstanceNotes")
    end
end
