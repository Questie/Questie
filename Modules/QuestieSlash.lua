---@class QuestieSlash
local QuestieSlash = QuestieLoader:CreateModule("QuestieSlash")

---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type QuestieSearch
local QuestieSearch = QuestieLoader:ImportModule("QuestieSearch")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")

local stringtrim, stringgmatch, stringmatch = string.trim, string.gmatch, string.match

function QuestieSlash.RegisterSlashCommands()
    Questie:RegisterChatCommand("questieclassic", QuestieSlash.HandleCommands)
    Questie:RegisterChatCommand("questie", QuestieSlash.HandleCommands)
    Questie:RegisterChatCommand("q", QuestieSlash.HandleCommands)
end

function QuestieSlash.HandleCommands(input)
    if not Questie.started then
        print(Questie:Colorize("/questie "..input..":"), l10n("Please wait a moment for Questie to finish loading"))
        return
    end

    input = stringtrim(input, " ");
    local commands = {}
    for c in stringgmatch(input, "([^%s]+)") do
        table.insert(commands, c)
    end

    local mainCommand = commands[1]
    local subCommand = commands[2]

    if mainCommand == "" or not mainCommand then
        QuestieCombatQueue:Queue(function()
            QuestieOptions:ToggleConfigWindow();
        end)

        if QuestieJourney:IsShown() then
            QuestieJourney:ToggleJourneyWindow();
        end
        return ;
    end

    -- lazy match commands
    -- command priority is last match in the table
    -- NEW COMMANDS SHOULD BE ADDED HERE
    local ctypes = {"doable", "flex", "help", "journey", "minimap", "search", "tracker", "toggle", "tomap"}
    local tempCommand
    for i=1, #ctypes do
        local partialMatch = stringmatch(ctypes[i], "^"..mainCommand)
        if partialMatch then
            tempCommand = ctypes[i]
        end
    end
    if tempCommand then mainCommand = tempCommand end

    if mainCommand == "help" or mainCommand == "?" then
        print(Questie:Colorize(l10n("Questie Commands")));
        print(Questie:Colorize("/questie"), l10n("Toggles the Config window"));
        print(Questie:Colorize("/questie toggle"), ("Toggles showing questie on the map and minimap"));
        print(Questie:Colorize("/questie tomap reset||npc|object [ID or name]"), l10n("Try to add markers for NPCs or objects to the map by search. If the \"tomap\" command is entered without subcommand it will attempt to mark the currently selected target. Searches by ID return exact matches, searches by name return partial matches. The \"reset\" subcommand does not accept additional parameters and just removes all markers."));
        print(Questie:Colorize("/questie minimap"), l10n("Toggles the Minimap Button for Questie"));
        print(Questie:Colorize("/questie journey"), l10n("Toggles the My Journey window"));
        print(Questie:Colorize("/questie tracker reset|show||hide"), ("Toggles the Tracker. Add 'show', 'hide', 'reset' to explicit show/hide or reset the Tracker"));
        print(Questie:Colorize("/questie flex"), l10n("Flex the amount of quests you have completed so far"));
        print(Questie:Colorize("/questie doable [questID]"), l10n("Prints whether you are eligibile to do a quest"));
        print(Questie:Colorize("/questie version"), l10n("Prints Questie and client version info"));
        return;
    end

    if mainCommand == "toggle" then
        Questie.db.profile.enabled = (not Questie.db.profile.enabled)
        QuestieQuest:ToggleNotes(Questie.db.profile.enabled);

        -- Close config window if it's open to avoid desyncing the Checkbox
        QuestieOptions:HideFrame();
        return;
    end

    if mainCommand == "reload" then
        QuestieQuest:SmoothReset()
        return
    end

    if mainCommand == "minimap" then
        Questie.db.profile.minimap.hide = not Questie.db.profile.minimap.hide;

        if Questie.db.profile.minimap.hide then
            Questie.minimapConfigIcon:Hide("Questie");
        else
            Questie.minimapConfigIcon:Show("Questie");
        end
        return;
    end

    if mainCommand == "journey" or mainCommand == "journal" then
        QuestieJourney:ToggleJourneyWindow();
        QuestieOptions:HideFrame();
        return;
    end

    if mainCommand == "tracker" then
        if subCommand == "show" then
            QuestieTracker:Enable()
        elseif subCommand == "hide" then
            QuestieTracker:Disable()
        elseif subCommand == "reset" then
            QuestieTracker:ResetLocation()
        else
            QuestieTracker:Toggle()
        end
        return
    end

    if mainCommand == "tomap" or mainCommand == "search" then
        -- TODO using this command can affect search history for the UI window through the QuestieSearch:Search calls, that should be prevented
        local searchType
        local numCommands = #commands
        -- no subcommand received, try to search for current target by name
        if not subCommand then
            local unit = UnitName("target")
            if not unit then
                print(Questie:Colorize("/questie "..input..":"), l10n("An active target or search parameters are required."))
                return
            end
            searchType = "npc"
            commands[3] = unit
            numCommands = 3
        -- subcommand received,  check it
        else
            local types = {"npc", "item", "object", "quest", "reset"}
            for i=1, #types do
                local partialMatch = stringmatch(types[i], "^"..subCommand)
                if partialMatch then
                    searchType = types[i]
                end
            end
        end
        -- known command found
        if searchType then
            -- reset command
            if searchType == "reset" then
                QuestieMap:ResetManualFrames()
                print(Questie:Colorize("/questie "..input..":"), l10n("All map markers cleared."))
                return
            end
            -- no search term provided
            if numCommands < 3 then
                print(Questie:Colorize("/questie "..input..":"), l10n("Search term required."))
                return
            end
            -- TODO
            if searchType == "item" or searchType == "quest" then
                print(Questie:Colorize("/questie "..input..":"), "TODO: Implement ShowItem and ShowQuest functions.")
                return
            end
            local isid = tonumber(commands[3])
            local result
            -- Search term is an ID
            if isid and numCommands == 3 then
                -- Look for an exact match and fake the result table if found
                local name
                if searchType == "npc" then
                    name = QuestieDB.QueryNPCSingle(isid, "name")
                elseif searchType == "object" then
                    name = QuestieDB.QueryObjectSingle(isid, "name")
                end
                if name then
                    result = {[isid]=true}
                    print(Questie:Colorize("/questie "..input..":"), l10n("Exact match found, added %s to map.", name))
                end
            -- Search term is not an ID
            else
                -- glue search terms back together if needed
                local search = ""
                for i=3, numCommands do
                    search = search .. commands[i]
                    if i < numCommands then
                        search = search .. " "
                    end
                end
                -- perform search
                result = QuestieSearch:Search(search, searchType)
                local results = QuestieLib:Count(result)
                if results ~= 0 then
                    print(Questie:Colorize("/questie "..input..":"), l10n("%d matches found and added to map.", results))
                else
                    result = nil
                end
            end
            -- if either of the searches above found something then add it to the map
            if result then
                for resultid, _ in pairs(result) do
                    if searchType == "npc" then
                        QuestieMap:ShowNPC(resultid)
                    elseif searchType == "object" then
                        QuestieMap:ShowObject(resultid)
                    end
                end
            -- if nothing was found inform the user
            else
                print(Questie:Colorize("/questie "..input..":"), l10n("No match found, nothing added to map."))
            end
            return
        end
    end

    if mainCommand == "flex" then
        local questCount = 0
        for _, _ in pairs(Questie.db.char.complete) do
            questCount = questCount + 1
        end
        if GetDailyQuestsCompleted then
            questCount = questCount - GetDailyQuestsCompleted() -- We don't care about daily quests
        end
        SendChatMessage(l10n("has completed a total of %d quests", questCount) .. "!", "EMOTE")
        return
    end

    if mainCommand == "version" then
        -- By checking each object in Questie
        -- We can find out which version is currently running.
        local gameType = ""
        do
            for k, v in pairs(Questie) do
                if type(k) == "string" then
                    if k:sub(1, 2) == "Is" and type(v) == "boolean" then
                        if v then
                            gameType = gameType .. k:sub(3) .. "-"
                        end
                    end
                end
            end
            gameType = gameType:sub(1, -2) -- remove last dash
        end

        Questie:Print("Questie " .. QuestieLib:GetAddonVersionString() .. ", Client " .. GetBuildInfo() .. " " .. gameType .. ", Locale " .. GetLocale())
        return
    end

    if mainCommand == "doable" or mainCommand == "eligible" or mainCommand == "eligibility" then
        if not subCommand then
            print(Questie:Colorize("/questie "..input..":"), "Usage: /questie", mainCommand, "<questID>")
            do return end
        elseif QuestieDB.QueryQuestSingle(tonumber(subCommand), "name") == nil then
            print(Questie:Colorize("/questie "..input..":"), "Invalid quest ID")
            return
        end

        Questie:Print("[Eligibility] " .. tostring(QuestieDB.IsDoableVerbose(tonumber(subCommand), false, true, false)))

        return
    end

    -- if no condition returned so far we have received an invalid command
    print(Questie:Colorize("/questie "..input..":"), l10n("Invalid command. For a list of options please type:"), Questie:Colorize("/questie help"))
end
