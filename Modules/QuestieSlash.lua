---@class QuestieSlash
local QuestieSlash = QuestieLoader:CreateModule("QuestieSlash")

-------------------------
--Import modules.
-------------------------
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

function QuestieSlash:HandleCommands(input)
    input = string.trim(input, " ");

    local commands = {}
    for c in string.gmatch(input, "([^%s]+)") do
        table.insert(commands, c)
    end

    local mainCommand = commands[1]
    local subCommand = commands[2]

    -- /questie
    if mainCommand == "" or not mainCommand then
        QuestieOptions:OpenConfigWindow();

        if QuestieJourney:IsShown() then
            QuestieJourney.ToggleJourneyWindow();
        end
        return ;
    end

    -- /questie help || /questie ?
    if mainCommand == "help" or mainCommand == "?" then
        print(Questie:Colorize(QuestieLocale:GetUIString('SLASH_HEAD'), 'yellow'));
        print(Questie:Colorize(QuestieLocale:GetUIString('SLASH_CONFIG'), 'yellow'));
        print(Questie:Colorize(QuestieLocale:GetUIString('SLASH_TOGGLE_QUESTIE'), 'yellow'));
        print(Questie:Colorize(QuestieLocale:GetUIString('SLASH_TO_MAP'), 'yellow'));
        print(Questie:Colorize(QuestieLocale:GetUIString('SLASH_MINIMAP'), 'yellow'));
        print(Questie:Colorize(QuestieLocale:GetUIString('SLASH_JOURNEY'), 'yellow'));
        print(Questie:Colorize(QuestieLocale:GetUIString('SLASH_TRACKER'), 'yellow'));
        return;
    end

    -- /questie toggle
    if mainCommand == "toggle" then
        Questie.db.char.enabled = (not Questie.db.char.enabled)
        QuestieQuest:ToggleNotes(Questie.db.char.enabled);

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

    -- /questie journey
    if mainCommand == "journey" then
        QuestieJourney.ToggleJourneyWindow();
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
        if subCommand == nil then
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

    print(Questie:Colorize("[Questie] :: ", 'yellow') .. QuestieLocale:GetUIString('SLASH_INVALID') .. Questie:Colorize('/questie help', 'yellow'));
end
