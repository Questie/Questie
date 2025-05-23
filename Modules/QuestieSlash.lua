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


function QuestieSlash.RegisterSlashCommands()
    Questie:RegisterChatCommand("questieclassic", QuestieSlash.HandleCommands)
    Questie:RegisterChatCommand("questie", QuestieSlash.HandleCommands)
end

function QuestieSlash.HandleCommands(input)
    input = string.trim(input, " ");

    local commands = {}
    for c in string.gmatch(input, "([^%s]+)") do
        table.insert(commands, c)
    end

    local mainCommand = commands[1]
    local subCommand = commands[2]

    -- /questie
    if mainCommand == "" or not mainCommand then
        QuestieCombatQueue:Queue(function()
            QuestieOptions:OpenConfigWindow();
        end)

        if QuestieJourney:IsShown() then
            QuestieJourney:ToggleJourneyWindow();
        end
        return ;
    end

    -- /questie help || /questie ?
    if mainCommand == "help" or mainCommand == "?" then
        print(Questie:Colorize(l10n("Questie Commands"), "yellow"));
        print(Questie:Colorize("/questie - " .. l10n("Toggles the Config window"), "yellow"));
        print(Questie:Colorize("/questie toggle - " .. l10n("Toggles showing questie on the map and minimap"), "yellow"));
        print(Questie:Colorize("/questie tomap [<npcId>/<npcName>/reset] - " .. l10n("Adds manual notes to the map for a given NPC ID or name. If the name is ambiguous multipe notes might be added. Without a second command the target will be added to the map. The 'reset' command removes all notes"), "yellow"));
        print(Questie:Colorize("/questie minimap - " .. l10n("Toggles the Minimap Button for Questie"), "yellow"));
        print(Questie:Colorize("/questie journey - " .. l10n("Toggles the My Journey window"), "yellow"));
        print(Questie:Colorize("/questie tracker [show/hide/reset] - " .. l10n("Toggles the Tracker. Add 'show', 'hide', 'reset' to explicit show/hide or reset the Tracker"), "yellow"));
        print(Questie:Colorize("/questie flex - " .. l10n("Flex the amount of quests you have completed so far"), "yellow"));
        print(Questie:Colorize("/questie doable [questID] - " .. l10n("Prints whether you are eligibile to do a quest"), "yellow"));
        print(Questie:Colorize("/questie version - " .. l10n("Prints Questie and client version info"), "yellow"));
        return;
    end

    -- /questie toggle
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

    -- /questie minimap
    if mainCommand == "minimap" then
        Questie.db.profile.minimap.hide = not Questie.db.profile.minimap.hide;

        if Questie.db.profile.minimap.hide then
            Questie.minimapConfigIcon:Hide("Questie");
        else
            Questie.minimapConfigIcon:Show("Questie");
        end
        return;
    end

    -- /questie journey (or /questie journal, because of a typo)
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

    if mainCommand == "tomap" then
        if not subCommand then
            subCommand = UnitName("target")
        end

        if subCommand ~= nil then
            if subCommand == "reset" then
                QuestieMap:ResetManualFrames()
                return
            end

            local conversionTry = tonumber(subCommand)
            if conversionTry then -- We've got an ID
                subCommand = conversionTry
                local result = QuestieSearch:Search(subCommand, "npc", "int")
                if result then
                    for npcId, _ in pairs(result) do
                        QuestieMap:ShowNPC(npcId)
                    end
                end
                return
            elseif type(subCommand) == "string" then
                local result = QuestieSearch:Search(subCommand, "npc")
                if result then
                    for npcId, _ in pairs(result) do
                        QuestieMap:ShowNPC(npcId)
                    end
                end
                return
            end
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
            print(Questie:Colorize("[Questie] ", "yellow") .. "Usage: /questie " .. mainCommand .. " <questID>")
            do return end
        elseif QuestieDB.QueryQuestSingle(tonumber(subCommand), "name") == nil then
            print(Questie:Colorize("[Questie] ", "yellow") .. "Invalid quest ID")
            return
        end

        Questie:Print("[Eligibility] " .. tostring(QuestieDB.IsDoableVerbose(tonumber(subCommand), false, true, false)))

        return
    end

    print(Questie:Colorize("[Questie] ", "yellow") .. l10n("Invalid command. For a list of options please type: ") .. Questie:Colorize("/questie help", "yellow"));
end
