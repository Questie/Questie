---@type QuestieMenu
local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")

local meetingStones
if Questie.IsWotlk then
    meetingStones = {
        178824,178825,178826,178827,178828,178829,178831,178832,178833,178834,178844,178845,
        178884,179554,179555,179584,179585,179586,179587,179595,179596,179597,182558,182559,
        182560,184455,184456,184458,184462,184463,185321,185322,185433,185550,186251,188171,
        188172,188488,191227,191529,192017,192399,192557,192622,193166,193602,194097,195013,
        195498,195695,202184
    }
elseif Questie.IsTBC then
    meetingStones = {
        178824,178825,178826,178827,178828,178829,178831,178832,178833,178834,178844,178845,
        178884,179554,179555,179584,179585,179586,179587,179595,179596,179597,182558,182559,
        182560,184455,184456,184458,184462,184463,185321,185322,185433,185550,186251,188171,
        188172
    }
else
    meetingStones = {} -- Meeting Stones can not be used for teleports in Classic
end

function QuestieMenu.GetMeetingStones()
    return meetingStones
end