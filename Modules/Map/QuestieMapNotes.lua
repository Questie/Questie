---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

QuestieMapNotes = {["npcs"]={}, ["objects"]={}, ["extraObjectives"]={}, ["dungeons"]={}, ["areaTriggers"]={}}

function QuestieNotesReset()
    QuestieMapNotes = {["npcs"]={}, ["objects"]={}, ["extraObjectives"]={}, ["dungeons"]={}, ["areaTriggers"]={}}
end

function QuestieNotesFill()
    QuestieNotesReset()
    for questId, _ in pairs(availableQuests) do
        if QuestieDB.IsDoable(questId) then
            local quest = QuestieDB.GetQuest(questId)
            if (quest.Starts.NPC) then
                for _, npcId in pairs(quest.Starts.NPC) do
                    if not QuestieMapNotes.npcs[npcId] then
                        QuestieMapNotes.npcs[npcId] = {}
                    end
                    if not QuestieMapNotes.npcs[npcId].starts then
                        QuestieMapNotes.npcs[npcId]["starts"] = {}
                    end
                    table.insert(QuestieMapNotes.npcs[npcId].starts, questId)
                end
            end
            if (quest.Starts.GameObject) then
                for _, objectId in pairs(quest.Starts.GameObject) do
                    if not QuestieMapNotes.objects[objectId] then
                        QuestieMapNotes.objects[objectId] = {}
                    end
                    if not QuestieMapNotes.objects[objectId].starts then
                        QuestieMapNotes.objects[objectId]["starts"] = {}
                    end
                    table.insert(QuestieMapNotes.objects[objectId].starts, questId)
                end
            end
        end
    end
    for questLogIndex = 1, 75 do
        local title, _, questTag, isHeader, _, isCompleteAccordingToBlizzard, _, questId = GetQuestLogTitle(questLogIndex)
        if (title) and (questId ~= 0) then
            local quest = QuestieDB.GetQuest(questId)
            if (not isHeader) then
                if isCompleteAccordingToBlizzard == 1 then
                    if (quest.Finisher.NPC) then
                        for _, npcId in pairs(quest.Finisher.NPC) do
                            if not QuestieMapNotes.npcs[npcId] then
                                QuestieMapNotes.npcs[npcId] = {}
                            end
                            if not QuestieMapNotes.npcs[npcId].ends then
                                QuestieMapNotes.npcs[npcId]["ends"] = {}
                            end
                            table.insert(QuestieMapNotes.npcs[npcId].ends, questId)
                        end
                    end
                    if (quest.Finisher.GameObject) then
                        for _, objectId in pairs(quest.Finisher.GameObject) do
                            if not QuestieMapNotes.objects[objectId] then
                                QuestieMapNotes.objects[objectId] = {}
                            end
                            if not QuestieMapNotes.objects[objectId].ends then
                                QuestieMapNotes.objects[objectId]["ends"] = {}
                            end
                            table.insert(QuestieMapNotes.objects[objectId].ends, questId)
                        end
                    end
                else
                    local allFinished = true
                    local objectives = C_QuestLog.GetQuestObjectives(questId)
                    for i=1, #objectives do
                        local objective = objectives[i]
                        if not objective.finished then
                            allFinished = false
                            if objective.type == "monster" then
                                local theNPC = 0
                                for _, npcIdAndAltText in pairs(quest.objectives[1]) do
                                    local npc = QuestieDB:GetNPC(npcIdAndAltText[1])
                                    if string.match(objective.text, npc.name) or (npcIdAndAltText[2] and string.match(objective.text, npcIdAndAltText[2])) then
                                        theNPC = npcIdAndAltText[1]
                                        break
                                    end
                                end
                                if theNPC ~= 0 then
                                    if not QuestieMapNotes.npcs[theNPC] then
                                        QuestieMapNotes.npcs[theNPC] = {}
                                    end
                                    if not QuestieMapNotes.npcs[theNPC].objectives then
                                        QuestieMapNotes.npcs[theNPC]["objectives"] = {}
                                    end
                                    if not QuestieMapNotes.npcs[theNPC].objectives["monster"] then
                                        QuestieMapNotes.npcs[theNPC].objectives["monster"] = {}
                                    end
                                    table.insert(QuestieMapNotes.npcs[theNPC].objectives["monster"], {["quest"]=questId, ["numFulfilled"]=objective.numFulfilled, ["numRequired"]=objective.numRequired})
                                end
                            elseif objective.type == "item" then
                                local theItem = 0
                                for _, itemIdAndAltText in pairs(quest.objectives[3]) do
                                    local item = QuestieDB:GetItem(itemIdAndAltText[1])
                                    if string.match(objective.text, item.name) or (itemIdAndAltText[2] and string.match(objective.text, itemIdAndAltText[2])) then
                                        theItem = itemIdAndAltText[1]
                                        break
                                    end
                                end
                                if theItem ~= 0 then
                                    local item = QuestieDB:GetItem(theItem)
                                    if item.npcDrops then
                                        for _, npcId in pairs(item.npcDrops) do
                                            if not QuestieMapNotes.npcs[npcId] then
                                                QuestieMapNotes.npcs[npcId] = {}
                                            end
                                            if not QuestieMapNotes.npcs[npcId].objectives then
                                                QuestieMapNotes.npcs[npcId]["objectives"] = {}
                                            end
                                            if not QuestieMapNotes.npcs[npcId].objectives["item"] then
                                                QuestieMapNotes.npcs[npcId].objectives["item"] = {}
                                            end
                                            table.insert(QuestieMapNotes.npcs[npcId].objectives.item, {["quest"]=questId, ["numFulfilled"]=objective.numFulfilled, ["numRequired"]=objective.numRequired})
                                        end
                                    end
                                    --TODO object/item drops
                                end
                            elseif objective.type == "object" then
                                local theObject = 0
                                for _, objIdAndAltText in pairs(quest.objectives[2]) do
                                    local object = QuestieDB:GetObject(objIdAndAltText[1])
                                    if objIdAndAltText[2] and string.match(objective.text, objIdAndAltText[2]) then
                                        theObject = objIdAndAltText[1]
                                        break
                                    end
                                end
                                if theObject ~= 0 then
                                    local object = QuestieDB:GetObject(theObject)
                                    if not QuestieMapNotes.objects[theObject] then
                                        QuestieMapNotes.objects[theObject] = {}
                                    end
                                    if not QuestieMapNotes.objects[theObject].objectives then
                                        QuestieMapNotes.objects[theObject]["objectives"] = {}
                                    end
                                    if not QuestieMapNotes.objects[theObject].objectives["object"] then
                                        QuestieMapNotes.objects[theObject].objectives["object"] = {}
                                    end
                                    table.insert(QuestieMapNotes.objects[theObject].objectives["object"], {["quest"]=questId, ["numFulfilled"]=objective.numFulfilled, ["numRequired"]=objective.numRequired})
                                end
                            elseif objective.type == "event" or objective.type == "log" then
                                if quest.triggerEnd then
                                    for zone, spawns in pairs(quest.triggerEnd[2]) do
                                        if not QuestieMapNotes.areaTriggers[zone] then
                                            QuestieMapNotes.areaTriggers[zone] = {}
                                        end
                                        if not QuestieMapNotes.areaTriggers[zone][questId] then
                                            QuestieMapNotes.areaTriggers[zone][questId] = {}
                                        end
                                        for _, spawn in pairs(spawns) do
                                            table.insert(QuestieMapNotes.areaTriggers[zone][questId], spawn)
                                        end
                                    end
                                end
                            elseif objective.type == "?" then
                                --TODO "reputation", "player", "progressbar"
                            end
                        end
                    end
                    --TODO check `allFinished`
                    --TODO extraObjectives
                end
                --TODO dungeonEntranceNotes
            end
        end
    end
end
