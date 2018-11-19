QuestieQuest = {...}
local _QuestieQuest = {...}


function QuestieQuest:TrackQuest(QuestID)--Should probably be called from some kind of questlog or similar, will have to wait untill classic to find out how tracking really works...

end


function QuestieQuest:GetAvailableQuests()--All quests between

end


qAvailableQuests = {

}

--TODO Check that this function does what it is supposed to...
function QuestieQuest:CalculateAvailableQuests()
  local MinLevel = UnitLevel("player") - Questie.db.global.minLevelFilter
  local MaxLevel = UnitLevel("player") + Questie.db.global.maxLevelFilter
  for i, v in pairs(qData) do
    if(MinLevel >= v[DB_MIN_LEVEL]) then
      table.insert(qAvailableQuests, i)
    elseif(MaxLevel >= v[DB_MIN_LEVEL]) then
      table.insert(qAvailableQuests, i)
    elseif(MaxLevel >= v[DB_MIN_LEVEL] and Questie.db.char.lowlevel) then
      table.insert(qAvailableQuests, i)
    end
  end
end
