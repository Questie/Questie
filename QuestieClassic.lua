
TradeShout = LibStub("AceAddon-3.0"):NewAddon("TradeShout", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0")
local LibC = LibStub:GetLibrary("LibCompress")
local LibCE = LibC:GetAddonEncodeTable()
local AceGUI = LibStub("AceGUI-3.0")

debug = false
send = true

-- get option value
local function GetGlobalOptionLocal(info)
	return TradeShout.db.global[info[#info]]
end


-- set option value
local function SetGlobalOptionLocal(info, value)
	if debug and TradeShout.db.global[info[#info]] ~= value then
		TradeShout:Printf("DEBUG: global option %s changed from '%s' to '%s'", info[#info], tostring(TradeShout.db.global[info[#info]]), tostring(value))
	end

	TradeShout.db.global[info[#info]] = value
end





function TradeShout:OnUpdate()

end

function TradeShout:SlashTest(input)
	TradeShout:Print("SlashTest!");
end

function TradeShout:MySlashProcessorFunc(input)
	--TradeShout:Print(ChatFrame1, "Hello, World!")
	--SetMessage("test", "test")
		TradeShout:Print("MySlashProcessorFunc!");
  -- Process the slash command ('input' contains whatever follows the slash command)

end

function TradeShout:GetNextMessage()
	local message = { strsplit("\n", TradeShout.db.global.message) }
	local count = 0
	for i, k in ipairs(message) do
		count = count + 1
	end
	for i, k in ipairs(message) do
		if(TradeShout.db.global.lastmessage == count) then
			TradeShout.db.global.lastmessage = 0
		end
		if(i > TradeShout.db.global.lastmessage) then
			k = TradeShout:TSMConvert(k)
			if(strlen(k) > 255) then
				TradeShout:Print("ERROR: Message", i, "is too long, will be cut!")
			end
			k = string.sub(k, 0,255)
			TradeShout.db.global.lastmessage = TradeShout.db.global.lastmessage + 1
			return k
		end
	end
end

function TradeShout:OnEnable()
    -- Called when the addon is enabled
end

function TradeShout:OnDisable()
    -- Called when the addon is disabled
end

function TradeShout:Announce()
	if(TradeShout.db.realm.enabled == true) then
		--TradeShout:Print("ANNOUNCE!", TradeShout.db.global.NrMessages)
		msg = TradeShout:GetNextMessage()
		SendChatMessage(msg, "CHANNEL", nil, TradeShout.db.global.channel)
		TradeShout:SetTimer()
	end
end

function TradeShout:SetTimer()
	TradeShout:CancelAllTimers()
	rNr = math.random(1,7)
	TradeShout:Print("Random number generated "..rNr.. " Total: "..TradeShout.db.global.timer+rNr)
	TradeShout:ScheduleRepeatingTimer("Announce", TradeShout.db.global.timer+rNr)
end


local options = {
    name = "Trade Shout",
    handler = TradeShout,
    type = "group",
	childGroups = "tab",
    args = {
		general_tab = {
			name = "Messages",
			type = "group",
			order = 10,
			args = {
				enabled = {
					type = "toggle",
					order = 11,
					name = "Enable TradeShout",
					desc = "Enable or disable addon functionality.",
					width = 200,
					get =	function ()
								return TradeShout.db.realm.enabled
							end,
					set =	function (info, value)
								TradeShout.db.realm.enabled = value
								TradeShout:SetTimer()
							end,
				},
				TSM = {
					type = "toggle",
					order = 11,
					name = "Enable TSM resolve",
					desc = "Enable replacement of %(80% dbmarket) with gold using TSM",
					width = 200,
					get =	function ()
								return TradeShout.db.char.tsmenabled
							end,
					set =	function (info, value)
								TradeShout.db.char.tsmenabled = value
							end,
				},
				description = {
					type = "description",
					order = 12,
					fontSize = "medium",
					name = "This addon spams tradechat with preset messages",
				},
				debug_options = {
					type = "header",
					order = 13,
					name = "Messages",
				},
				message = {
					type = "input",
					order = 14,
					name = "Message to announce, one per line",
					desc = "Type the message to announce, every line will be announced.",
					multiline = 7,
					width = "full",
					get = GetGlobalOptionLocal,
					set = SetMessage,
				},
				channel = {
					type = "input",
					order = 15,
					name = "Channel number",
					desc = "What channel should be posted to.",
					width = "normal",
					get = GetGlobalOptionLocal,
					set = SetGlobalOptionLocal,
				},
				timer = {
					type = "range",
					order = 16,
					name = "Announce interval, seconds",
					desc = "How often announce your message to channel.",
					min = 30,
					max = 1800,
					step = 1,
					get = GetGlobalOptionLocal,
					set = SetGlobalOptionLocal,
				},
				test = {
					type = "execute",
					order = 16,
					name = "Test Message",
					desc = "Print next message in say.",
					func = function() TradeShout:Print(TradeShout:GetNextMessage()) end,
				},
			},
		}
	}
}

function TradeShout:OnInitialize()
	TradeShout:RegisterChatCommand("tradeshout", "MySlashProcessorFunc")
	TradeShout:RegisterChatCommand("test", "SlashTest")
	TradeShout:RegisterChatCommand("ts", "MySlashProcessorFunc")
	self.db = LibStub("AceDB-3.0"):New("TradeShoutDB", defaults, true)
	TradeShout.db.TradeShoutFrame = AceGUI:Create("Frame")
	TradeShout.db.global.lastmessage = 0

	--TradeShoutFrame:SetTitle("Example frame")
	--TradeShoutFrame:SetStatusText("AceGUI-3.0 Example Container frame")
	--TradeShoutFrame:SetCallback("OnClose", function() TradeShoutFrame:Hide() end)
	--TradeShoutFrame:SetLayout(options)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("TradeShout", options)
	TradeShoutFrame = LibStub("AceConfigDialog-3.0"):Open("TradeShout", TradeShout.db.TradeShoutFrame)

	TradeShout:SetTimer()

	--self.configFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("TradeShout", "Trade Shout");

  -- Code that you want to run when the addon is first loaded goes here.
  --TradeShout:Print("Hello, world!")
  --self:RegisterChatCommand("TradeShout", "ChatCommand")
end
