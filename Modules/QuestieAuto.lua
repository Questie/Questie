---@class QuestieAuto
local QuestieAuto = QuestieLoader:CreateModule("QuestieAuto");
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

local shouldRunAuto = true
local pauseAuto = false
local lastIndexTried = 0
 -- forward declarations
local _SelectAvailableQuest
local _IsBindTrue
local _IsQuestOrNPCAllowed
local _AcceptQuestFromGossip
local _CompleteQuestFromGossip

--- This function hooks some OnHide and OnShow events of the quest
--- frames to keep the "shouldRunAuto" value while stepping through
--- the different NPC quest steps.
function QuestieAuto:RegisterFrameEvents()
    -- Hooked when the Gossip Frame is closed so the shift
    -- modifier is reset
    GossipFrameGreetingPanel:HookScript("OnHide", function()
        Questie:Debug(DEBUG_DEVELOP, "GossipFrameGreetingPanel:OnHide")
        if not QuestieAuto:GetShouldRunAuto() then
            pauseAuto = true
        else
            pauseAuto = false
        end
        QuestieAuto:ResetShouldRunAuto()
    end)

    QuestFrameDetailPanel:HookScript("OnShow", function()
        Questie:Debug(DEBUG_DEVELOP, "QuestFrameDetailPanel:OnShow")
        if pauseAuto then
            QuestieAuto:DisableShouldRunAuto()
        end
        pauseAuto = false
    end)

    QuestFrameProgressPanel:HookScript("OnShow", function()
        Questie:Debug(DEBUG_DEVELOP, "QuestFrameProgressPanel:OnShow")
        if pauseAuto then
            QuestieAuto:DisableShouldRunAuto()
        end
        pauseAuto = false
    end)

    QuestFrameRewardPanel:HookScript("OnShow", function()
        Questie:Debug(DEBUG_DEVELOP, "QuestFrameRewardPanel:OnShow")
        if pauseAuto then
            QuestieAuto:DisableShouldRunAuto()
        end
        pauseAuto = false
    end)
end

function QuestieAuto:QUEST_PROGRESS(event, ...)
    Questie:Debug(DEBUG_DEVELOP, "PROGRESS", event, ...)
    if not shouldRunAuto then
        return
    end
    if Questie.db.char.autocomplete then
        if IsQuestCompletable() then
            CompleteQuest()
            lastIndexTried = lastIndexTried - 1
        else
            Questie:Debug("Quest not completeable. Skipping to next quest. Index:", lastIndexTried)
            if lastIndexTried == 0 then
                lastIndexTried = 1
            elseif lastIndexTried >= GetNumAvailableQuests() then
                return
            else
                lastIndexTried = lastIndexTried + 1
            end

            -- Close the QuestFrame if no quest is completeable again
            if QuestFrameGoodbyeButton then
                _SelectAvailableQuest(lastIndexTried)
                QuestFrameGoodbyeButton:Click()
            end
        end
    end
end

--- This function is run whenever the QuestFrame is closed so the shift modifier
--- and the last tried questIndex is reset
function QuestieAuto:ResetShouldRunAuto()
    Questie:Debug(DEBUG_DEVELOP, "QuestieAuto:ResetShouldRunAuto")
    shouldRunAuto = true
    lastIndexTried = 0
end

function QuestieAuto:DisableShouldRunAuto()
    Questie:Debug(DEBUG_DEVELOP, "QuestieAuto:DisableShouldRunAuto")
    shouldRunAuto = false
end

---@return boolean
function QuestieAuto:GetShouldRunAuto()
    return shouldRunAuto
end

function QuestieAuto:GOSSIP_SHOW(event, ...)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] GOSSIP_SHOW", event, ...)

    shouldRunAuto = true
    if _IsBindTrue(Questie.db.char.autoModifier) then
        shouldRunAuto = false
        Questie:Debug(DEBUG_DEVELOP, "Modifier-Key down: Don't run auto accept/turn in")
        return
    end

    if Questie.db.char.autoaccept and _IsQuestOrNPCAllowed() then
        Questie:Debug(DEBUG_DEVELOP, "Accepting quests from gossip", event, ...)
        _AcceptQuestFromGossip(GetGossipAvailableQuests())
    end
    if Questie.db.char.autocomplete and _IsQuestOrNPCAllowed() then
        Questie:Debug(DEBUG_DEVELOP, "Completing quests from gossip", event, ...)
        _CompleteQuestFromGossip(GetGossipActiveQuests())
    end
end

_AcceptQuestFromGossip = function(...)
    local MOP_INDEX_CONST = 7 -- was '5' in Cataclysm
    for i = select("#", ...), 1, -MOP_INDEX_CONST do
        local title = select(i - 6, ...)
        local isTrivial = select(i - 4, ...)
        local isRepeatable = select(i - 2, ...) -- complete status
        Questie:Debug(DEBUG_DEVELOP, "Accepting quest, Title:", title,
                      "Trivial", isTrivial, "Repeatable", isRepeatable, "index",
                      i)
        if ((not isTrivial) or Questie.db.char.acceptTrivial) then
            Questie:Debug(DEBUG_INFO, "Accepting quest, ", title)
            SelectGossipAvailableQuest(math.floor(i / MOP_INDEX_CONST))
        end
    end
end

_CompleteQuestFromGossip = function(...)
    local MOP_INDEX_CONST = 6 -- was '4' in Cataclysm
    for i = 1, select("#", ...), MOP_INDEX_CONST do
        local title = select(i, ...)
        local isComplete = select(i + 3, ...) -- complete status
        Questie:Debug(DEBUG_DEVELOP, "Completing quest, ", title, "Complete",
                      isComplete, "index", i)
        if (isComplete) then
            Questie:Debug(DEBUG_INFO, "Completing quest, ", title)
            SelectGossipActiveQuest(math.floor(i / MOP_INDEX_CONST) + 1)
        end
    end
end

function QuestieAuto:QUEST_ACCEPT_CONFIRM(event, ...)
    -- Escort stuff
    if(Questie.db.char.autoaccept) then
       ConfirmAcceptQuest()
    end
end


function QuestieAuto:QUEST_GREETING(event, ...)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_GREETING", event, GetNumActiveQuests(), ...)

    if _IsBindTrue(Questie.db.char.autoModifier) or (not shouldRunAuto) then
        shouldRunAuto = false
        Questie:Debug(DEBUG_DEVELOP, "Modifier-Key down: Don't run auto accept/turn in")
        return
    end

    -- Quest already taken
    if (Questie.db.char.autocomplete) then
        for index = 1, GetNumActiveQuests() do
            local quest, isComplete = GetActiveTitle(index)
            Questie:Debug(DEBUG_DEVELOP, quest, isComplete)
            if isComplete then SelectActiveQuest(index) end
        end
    end

    if (Questie.db.char.autoaccept) then
        if lastIndexTried == 0 then
            lastIndexTried = 1
        end
        Questie:Debug(DEBUG_DEVELOP, "lastIndex:", lastIndexTried)
        for index = lastIndexTried, GetNumAvailableQuests() do
            _SelectAvailableQuest(index)
            break
        end
    end
end

_SelectAvailableQuest = function (index)
    Questie:Debug(DEBUG_DEVELOP, "Selecting the " .. index .. ". available quest")
    SelectAvailableQuest(index)
end

function QuestieAuto:TurnInQuest(rewardIndex)
    Questie:Debug(DEBUG_DEVELOP, "Turn in function!")
    -- Maybe we want to do something smart?

    -- We really want to disable this in instances, mostly to prevent retards from ruining groups.
    if (Questie.db.char.autocomplete and _IsQuestOrNPCAllowed()) then
        GetQuestReward(rewardIndex)
    end
end

function QuestieAuto:QUEST_DETAIL(event, ...)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_DETAIL", event, ...)

    if _IsBindTrue(Questie.db.char.autoModifier) or (not shouldRunAuto) then
        shouldRunAuto = false
        Questie:Debug(DEBUG_DEVELOP, "Modifier-Key down: Don't run auto accept/turn in")
        return
    end

    -- We really want to disable this in instances, mostly to prevent retards from ruining groups.
    if (Questie.db.char.autoaccept and _IsQuestOrNPCAllowed()) then
        Questie:Debug(DEBUG_DEVELOP, "INSIDE", event, ...)

        local questId = GetQuestID()
        ---@type Quest
        local quest = QuestieDB:GetQuest(questId)

        if (not quest:IsTrivial()) or Questie.db.char.acceptTrivial then
            Questie:Debug(DEBUG_INFO, "Questie Auto-Acceping quest")
            AcceptQuest()
        end
    end
end

_IsQuestOrNPCAllowed = function()
    local npcGuid = UnitGUID("target") or nil
    local allowed = true
    if npcGuid then
        local _, _, _, _, _, npcID = strsplit("-", npcGuid)
        npcID = tonumber(npcID)
        -- Questie:Print(npcID, npcGuid, QuestieAuto.disallowedNPC[npcID]);
        if (QuestieAuto.disallowedNPC[npcID] ~= nil) then allowed = false end
    end
    local questId = GetQuestID()
    if (QuestieAuto.disallowedQuests[questId] ~= nil) then allowed = false end
    Questie:Debug(DEBUG_INFO, "[QuestieAuto]", " Is this quest or npc allowed:",
                  allowed, "QuestId:", questId)
    return allowed
end

-- I was forced to make decision on offhand, cloak and shields separate from armor but I can't pick up my mind about the reason...
function QuestieAuto:QUEST_COMPLETE(event, ...)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_COMPLETE", event, ...)

    if not shouldRunAuto then
        return
    end
    -- blasted Lands citadel wonderful NPC. They do not trigger any events except quest_complete.
    -- if not AllowedToHandle() then
    --    return
    -- end
    if (Questie.db.char.autocomplete) then

        local questname = GetTitleText()
        local numOptions = GetNumQuestChoices()
        Questie:Debug(DEBUG_DEVELOP, event, questname, numOptions, ...)

        if numOptions > 1 then
            Questie:Debug(DEBUG_DEVELOP, "Multiple rewards! ", numOptions)
            local function getItemId(typeStr)
                local link = GetQuestItemLink(typeStr, 1) -- first item is enough
                return link and link:match("%b::"):gsub(":", "")
            end

            local itemID = getItemId("choice")
            if (not itemID) then
                Questie:Debug(DEBUG_DEVELOP,
                              "Can't read reward link from server. Close NPC dialogue and open it again.")
                return
            end
            Questie:Debug(DEBUG_INFO,
                          "Multiple rewards! Please choose appropriate reward!")

        else
            Questie:Debug(DEBUG_DEVELOP, "Turn in!")
            QuestieAuto:TurnInQuest(1)
            Questie:Debug(DEBUG_DEVELOP, "Completed quest!")
        end
    end
end


local bindTruthTable = {
    ['shift'] = function()
        return IsShiftKeyDown()
    end,
    ['ctrl'] = function()
        return IsControlKeyDown()
    end,
    ['alt'] = function()
        return  IsAltKeyDown()
    end,
    ['disabled'] = function() return false; end,
}

_IsBindTrue = function(bind)
    return bind and bindTruthTable[bind]()
end


-- NPC Id based.
QuestieAuto.disallowedNPC = {
    -- AQ
    -- Ally
    [15446] = true, -- Bonnie Stoneflayer (Light Leather)
    [15458] = true, -- Commander Stronghammer (Alliance Ambassador)
    [15431] = true, -- Corporal Carnes (Iron Bar)
    [15432] = true, -- Dame Twinbraid (Thorium Bar)
    [15453] = true, -- Keeper Moonshade (Runecloth Bandage)
    [15457] = true, -- Huntress Swiftriver (Spotted Yellowtail)
    [15450] = true, -- Marta Finespindle (Thick Leather)
    [15437] = true, -- Master Nightsong (Purple Lotus)
    [15452] = true, -- Nurse Stonefield (Silk Bandage)
    [15434] = true, -- Private Draxlegauge (Stranglekelp)
    [15448] = true, -- Private Porter (Medium Leather)
    [15456] = true, -- Sarah Sadwhistle (Roast Raptor)
    [15451] = true, -- Sentinel Silversky (Linen Bandage)
    [15445] = true, -- Sergeant Major Germaine (Arthas' Tears)
    [15383] = true, -- Sergeant Stonebrow (Copper Bar)
    [15455] = true, -- Slicky Gastronome (Rainbow Fin Albacore)
    -- Horde
    [15512] = true, -- Apothecary Jezel (Purple Lotus)
    [15508] = true, -- Batrider Pele'keiki (Firebloom)
    [15533] = true, -- Bloodguard Rawtar (Lean Wolf Steak)
    [15535] = true, -- Chief Sharpclaw (Baked Salmon)
    [15525] = true, -- Doctor Serratus (Rugged Leather)
    [15534] = true, -- Fisherman Lin'do (Spotted Yellowtail)
    [15539] = true, -- General Zog (Horde Ambassador)
    [15460] = true, -- Grunt Maug (Tin Bar)
    [15528] = true, -- Healer Longrunner (Wool Bandage)
    [15477] = true, -- Herbalist Proudfeather (Peacebloom)
    [15529] = true, -- Lady Callow (Mageweave Bandage)
    [15459] = true, -- Miner Cromwell (Copper Bar)
    [15469] = true, -- Senior Sergeant T'kelah (Mithril Bar)
    [15522] = true, -- Sergeant Umala (Thick Leather)
    [15515] = true, -- Skinner Jamani (Heavy Leather)
    [15532] = true, -- Stoneguard Clayhoof (Runecloth Bandage)

    -- Commendations
    [15764] = true, -- Officer Ironbeard (Ironforge Commendations)
    [15762] = true, -- Officer Lunalight (Darnassus Commendations)
    [15766] = true, -- Officer Maloof (Stormwind Commendations)
    [15763] = true, -- Officer Porterhouse (Gnomeregan Commendations)
    [15768] = true, -- Officer Gothena (Undercity Commendations)
    [15765] = true, -- Officer Redblade (Orgrimmar Commendations)
    [15767] = true, -- Officer Thunderstrider (Thunder Bluff Commendations)
    [15761] = true, -- Officer Vu'Shalay (Darkspear Commendations)

    -- Stray
    [15192] = true, -- Anachronos (Caverns of Time)
    [12944] = true -- Lokhtos Darkbargainer (Thorium Brotherhood, Blackrock Depths)
}

QuestieAuto.disallowedQuests = {
    -- Escort Quests
    [155] = true, -- The Defias Traitor (The Defias Brotherhood)
    [219] = true, -- Corporal Keeshan (Missing In Action)
    [309] = true, -- Miran (Protecting the Shipment)
    [434] = true, -- Tyrion (The Attack!)
    [435] = true, -- Deathstalker Erland (Escorting Erland)
    [648] = true, -- Homing Robot OOX-17/TN (Rescue OOX-17/TN!)
    [660] = true, -- Kinelory (Hints of a New Plague?)
    [665] = true, -- Professor Phizzlethorpe (Sunken Treasure)
    [667] = true, -- Shakes O'Breen (Death From Below)
    [731] = true, -- Prospector Remtravel (The Absent Minded Prospector)
    [836] = true, -- Homing Robot OOX-09/HL (Rescue OOX-09/HL!)
    [863] = true, -- Wizzlecrank's Shredder (The Escape)
    [898] = true, -- Gilthares Firebough (Free From the Hold)
    [938] = true, -- Mist (Mist)
    [945] = true, -- Therylune (Therylune's Escape)
    [976] = true, -- Feero Ironhand (Supplies to Auberdine)
    [994] = true, -- Volcor (Escape Through Force)
    [995] = true, -- Volcor (Escape Through Stealth)
    [1144] = true, -- Willix the Importer (Willix the Importer)
    [1222] = true, -- Stinky Ignatz (Stinky's Escape)
    [1270] = true, -- Stinky Ignatz (Stinky's Escape)
    [1273] = true, -- Ogron (Questioning Reethe)
    [1393] = true, -- Galen Goodward (Galen's Escape)
    [1440] = true, -- Dalinda Malem (Return to Vahlarriel)
    [1560] = true, -- Tooga (Tooga's Quest)
    [2742] = true, -- Rin'ji (Rin'ji is Trapped!)
    [2767] = true, -- Homing Robot OOX-22/FE (Rescue OOX-22/FE!)
    [2845] = true, -- Shay Leafrunner (Wandering Shay)
    [2904] = true, -- Kernobee (A Fine Mess)
    [3367] = true, -- Dorius Stonetender (Suntara Stones)
    [3382] = true, -- Captain Vanessa Beltis (A Crew Under Fire)
    [3525] = true, -- Belnistrasz (Extinguishing the Idol)
    [3982] = true, -- Commander Gor'shak (What Is Going On?)
    [4121] = true, -- Grark Lorkrub (Precarious Predicament)
    [4245] = true, -- A-Me 01 (Chasing A-Me 01)
    [4261] = true, -- Arei (Ancient Spirit)
    [4322] = true, -- Marshal Windsor (Jail Break!)
    [4491] = true, -- Ringo (A Little Help From My Friends)
    [4770] = true, -- Pao'ka Swiftmountain (Homeward Bound)
    [4901] = true, -- Ranshalla (Guardians of the Altar)
    [4904] = true, -- Lakota Windsong (Free at Last)
    [4966] = true, -- Kanati Greycloud (Protect Kanati Greycloud)
    [5203] = true, -- Captured Arko'narin (Rescue From Jaedenar)
    [5321] = true, -- Kerlonian Evershade (The Sleeper Has Awakened)
    [5713] = true, -- Sentinel Aynasha (One Shot. One Kill.)
    [5821] = true, -- Cork Gizelton (Bodyguard for Hire)
    [5943] = true, -- Rigger Gizelton (Gizelton Caravan)
    [5944] = true, -- Highlord Taelan Fordring (In Dreams)
    [6132] = true, -- Melizza Brimbuzzle (Get Me Out of Here!)
    [6403] = true, -- Reginald Windsor (The Great Masquerade)
    [6482] = true, -- Ruul Snowhoof (Freedom to Ruul)
    [6523] = true, -- Kaya Flathoof (Protect Kaya)
    [6544] = true, -- Torek (Torek's Assault)
    [6641] = true, -- Muglash (Vorsha the Lasher)
    [7046] = true, -- Celebras the Redeemed (The Scepter of Celebras)
    [3375] = true,
    [2948] = true,
    [2199] = true,
    [2950] = true,
    [4781] = true,
    [4083] = true,
    [5166] = true,
    [5167] = true,
    -- The Barrens Bloodshard quests
    [889] = true,
    [5042] = true,
    [5043] = true,
    [5044] = true,
    [5945] = true,
    --
}
