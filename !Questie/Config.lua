
if not QuestieConfig then QuestieConfig = {
	["alwaysShowDistance"] = false,
	["alwaysShowLevel"] = true,
	["alwaysShowQuests"] = true,
	["arrowEnabled"] = true,
	["boldColors"] = false,
	["maxLevelFilter"] = false,
	["maxShowLevel"] = 3,
	["minLevelFilter"] = false,
	["minShowLevel"] = 10,
	["showMapAids"] = true,
	["showProfessionQuests"] = false,
	["showTrackerHeader"] = false,
	["trackerEnabled"] = true,
	["trackerList"] = false,
} end

if not QuestieTrackerVariables then QuestieTrackerVariables = {
	["position"] = {
		["relativeTo"] = "UIParent",
		["point"] = "LEFT",
		["relativePoint"] = "LEFT",
		["yOfs"] = 0,
		["xOfs"] = 0,
	},
} end