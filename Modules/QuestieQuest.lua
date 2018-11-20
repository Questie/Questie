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
            if(Zone == 1) then
              Questie:Debug("Zone", Zone)
              Questie:Debug("Qid:", questid)
              for _, coords in ipairs(Spawns) do
                Questie:Debug("Coords", coords[1], coords[2])
                local Note = QuestieFramePool:GetFrame()
                Note.data.QuestData = Quest;
                Note.data.Starter = NPC;
                Questie:Debug("Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[Zone])
                --HBDPins:AddWorldMapIconMap(Questie, Note, zoneDataAreaIDToUiMapID[Zone], coords[1]/100, coords[2]/100, HBD_PINS_WORLDMAP_SHOW_WORLD)
                QuestieMap:DrawWorldIcon(Note, Zone, coords[1], coords[2])
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
    elseif(MaxLevel >= v[DB_MIN_LEVEL]) then
      table.insert(qAvailableQuests, i)
    elseif(MaxLevel >= v[DB_MIN_LEVEL] and Questie.db.char.lowlevel) then
      table.insert(qAvailableQuests, i)
    end
  end
end
