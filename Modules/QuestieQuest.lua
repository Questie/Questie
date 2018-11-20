QuestieQuest = {...}
local _QuestieQuest = {...}


function QuestieQuest:TrackQuest(QuestID)--Should probably be called from some kind of questlog or similar, will have to wait untill classic to find out how tracking really works...

end


function QuestieQuest:DrawAvailableQuests()--All quests between
  for i, questid in ipairs(qAvailableQuests) do
    Quest = QuestieDB:GetQuest(questid)
    if(Quest.Starts["NPC"] ~= nil)then
      for index, NPCID in ipairs(Quest.Starts["NPC"]) do
        NPC = QuestieDB:GetNPC(NPCID)
        if(NPC ~= nil) then
          --Questie:Debug(NPCID)
          for Zone, Spawns in pairs(NPC.Spawns) do
            if(Zone ~= nil) then
              --Questie:Debug("Zone", Zone)
              --Questie:Debug("Qid:", questid)
              for _, coords in ipairs(Spawns) do
                --Questie:Debug("Coords", coords[1], coords[2])
                local data = {}
                data.ID = questid
                data.QuestData = Quest;
                data.Starter = NPC;
                if(coords[1] == -1 or coords[2] == -1) then
                  if(instanceData[Zone] ~= nil) then
                    for index, value in ipairs(instanceData[Zone]) do
                      Questie:Debug("Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[value[1]])
                      QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
                    end
                  end
                else
                  Questie:Debug("Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[Zone])
                  --HBDPins:AddWorldMapIconMap(Questie, Note, zoneDataAreaIDToUiMapID[Zone], coords[1]/100, coords[2]/100, HBD_PINS_WORLDMAP_SHOW_WORLD)
                  QuestieMap:DrawWorldIcon(data, Zone, coords[1], coords[2])
                end
              end
            end
          end
        end
      end
    end
  end
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
    elseif(MaxLevel >= v[DB_MIN_LEVEL] and MaxLevel >= v[DB_LEVEL]) then --MaxLevel >= v[DB_LEVEL] Hides lvl 60 quests if you are not close, some are pretty stupid to show such as 1-60 range quests
      table.insert(qAvailableQuests, i)
    elseif(MaxLevel >= v[DB_MIN_LEVEL] and Questie.db.char.lowlevel) then
      table.insert(qAvailableQuests, i)
    end
  end
end
