---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");
---@class QuestieMapUtils
QuestieMap.utils = QuestieMap.utils or {}

-- All the speed we can get is worth it.
local pairs = pairs

-- How far in front each icon type draws among the quest icons, 0 to 3. Every one of QuestieDB's icon
-- types is listed, by name and grouped as QuestieDB groups them: the numbers live in its enum alone,
-- which loads before Questie.
local DRAW_ORDER_BY_ICON_NAME = {
    -- Objective actions
    ICON_TYPE_SLAY = 0,
    ICON_TYPE_LOOT = 0,
    ICON_TYPE_EVENT = 0,
    ICON_TYPE_OBJECT = 0,
    ICON_TYPE_TALK = 0,
    ICON_TYPE_INTERACT = 0,
    ICON_TYPE_MOUNT_UP = 0,

    -- Quest availability, completion and variants
    ICON_TYPE_AVAILABLE = 1,
    ICON_TYPE_AVAILABLE_GRAY = 0,
    ICON_TYPE_COMPLETE = 3,
    ICON_TYPE_GLOW = 0,
    ICON_TYPE_REPEATABLE = 2,
    ICON_TYPE_REPEATABLE_COMPLETE = 3,
    ICON_TYPE_INCOMPLETE = 0,
    ICON_TYPE_EVENTQUEST = 2,
    ICON_TYPE_EVENTQUEST_COMPLETE = 3,
    ICON_TYPE_PVPQUEST = 2,
    ICON_TYPE_PVPQUEST_COMPLETE = 3,

    -- Gathering nodes and treasure
    ICON_TYPE_NODE_FISH = 0,
    ICON_TYPE_NODE_HERB = 0,
    ICON_TYPE_NODE_ORE = 0,
    ICON_TYPE_CHEST = 0,

    -- Runes and pet battles
    ICON_TYPE_SODRUNE = 3,
    ICON_TYPE_PET_BATTLE = 0,
}

-- Notes, such as townsfolk, are drawn from a texture rather than an icon type. They all draw at this
-- order, below every quest icon.
local NOTE_DRAW_ORDER = 0

local iconTypes = LibQuestieDB and LibQuestieDB.Enum and LibQuestieDB.Enum.iconTypes or {}
---@type table<number, number>
local DRAW_ORDER_BY_ICON_TYPE = {}
-- One more than the highest draw order, so it also counts them.
local MAX_DRAW_ORDER_BY_ICON_TYPE = 0
for name, order in pairs(DRAW_ORDER_BY_ICON_NAME) do
    if iconTypes[name] then DRAW_ORDER_BY_ICON_TYPE[iconTypes[name]] = order end
    MAX_DRAW_ORDER_BY_ICON_TYPE = math.max(MAX_DRAW_ORDER_BY_ICON_TYPE, order + 1)
end

-- Framelevel that is infront of all aboves
local DRAW_ORDER_QUEST_COMPLETE = 2 * MAX_DRAW_ORDER_BY_ICON_TYPE

-- Draw order
-- Each kind of icon has a tier: notes lowest, then quest objectives, quest givers, and turn-ins on top.
-- On the world map, Questie's icons are quest pins, so they draw in a block of frame levels of their
-- own just below Blizzard's quest pins: those and the player's arrow stay above them, flight points
-- and other points of interest below. Within a tier, an icon lower on its map draws in front. On the
-- minimap, and where the world map gives no block, tiers keep fixed levels from 2016, above patrol
-- paths and far above the minimap's own frames. A grown icon, such as a hovered one, draws in front
-- of all others on its map.
local TIERS = DRAW_ORDER_QUEST_COMPLETE + 1
local Y_STEPS = 101 -- One row of levels per percent of the map's height, 0 to 100.
local BLOCK_TYPE = "PIN_FRAME_LEVEL_QUESTIE"
local BLOCK_RANGE = TIERS * Y_STEPS + 1 -- And one more on top for a grown icon.
local FIXED_LEVEL = 2016

---@type table? Blizzard's world map pin frame levels, once Questie's block is registered in it.
local blockLevels
local blockTried = false

---The first frame level of Questie's block on the world map, registered on first use: before the map
---first shows, as icons are drawn at login. Nil when the map's level manager gives no block.
---@return number?
local function _BlockStart()
    if not blockTried then
        blockTried = true
        local levels = WorldMapFrame and WorldMapFrame.GetPinFrameLevelsManager and WorldMapFrame:GetPinFrameLevelsManager()
        if levels and levels.InsertFrameLevelBelow
            and levels:InsertFrameLevelBelow(BLOCK_TYPE, "PIN_FRAME_LEVEL_ACTIVE_QUEST", BLOCK_RANGE) then
            blockLevels = levels
        end
    end
    return blockLevels and blockLevels:GetFrameLevelStart(BLOCK_TYPE)
end

---@type table<unknown, true> Icon types without a draw order, each reported once.
local reportedIconTypes = {}

---The icon's tier, 0 to TIERS - 1: notes first, then the quest icons by their icon type's draw order,
---and turn-ins on top.
---@param frame IconFrame
---@param data IconData
---@return number
local function _Tier(frame, data)
    if data.Type == "complete" then return DRAW_ORDER_QUEST_COMPLETE end
    if frame.isManualIcon then return NOTE_DRAW_ORDER end
    local order = DRAW_ORDER_BY_ICON_TYPE[data.Icon]
    if not order then
        -- An icon type QuestieDB added after this list: drawn with the objectives until it is listed.
        if not reportedIconTypes[data.Icon] then
            reportedIconTypes[data.Icon] = true
            Questie.Error("No map draw order for icon type", tostring(data.Icon))
        end
        order = DRAW_ORDER_BY_ICON_NAME.ICON_TYPE_SLAY
    end
    return MAX_DRAW_ORDER_BY_ICON_TYPE + order
end

---Sets the icon's frame level from its tier, its place on its map and whether it is grown. HereBeDragons
---sets the parent frame and strata; the level stays fixed as the parent changes.
---@param frame IconFrame
function QuestieMap.utils.SetDrawOrder(frame)
    local data = frame.data
    -- A pooled icon shows nothing; its next draw sets its level.
    if not data then return end
    local frameLevel
    local start = (not frame.miniMapIcon) and _BlockStart()
    if start then
        if frame.pictureScale then
            frameLevel = start + BLOCK_RANGE - 1
        else
            local row = math.floor(math.min(math.max(frame.y or 0, 0), 100))
            frameLevel = start + _Tier(frame, data) * Y_STEPS + row
        end
    else
        frameLevel = FIXED_LEVEL + (frame.pictureScale and TIERS or _Tier(frame, data))
    end

    frame:SetFixedFrameLevel(false)
    frame:SetFrameLevel(frameLevel)
    frame:SetFixedFrameLevel(true) -- Stop framelevel changes when parent changes
end

function QuestieMap.utils.IsExplored(uiMapId, x, y)
    local IsExplored = false
    if uiMapId then
        local exploredAreaIDs = C_MapExplorationInfo.GetExploredAreaIDsAtPosition(uiMapId, CreateVector2D(x / 100, y / 100))
        if exploredAreaIDs then
            IsExplored = true -- Explored
        elseif (uiMapId == 1453) then
            IsExplored = true -- Stormwind
        elseif (uiMapId == 1455) then
            IsExplored = true -- Ironforge
        elseif (uiMapId == 1457) then
            IsExplored = true -- Darnassus
        elseif (uiMapId == 1458) then
            IsExplored = true -- Undercity
        elseif (uiMapId == 1454) then
            IsExplored = true -- Orgrimmar
        elseif (uiMapId == 1456) then
            IsExplored = true -- Thunder Bluff
        end
    end
    return IsExplored
end

function QuestieMap.utils.MapExplorationUpdate()
    for _, frameList in pairs(QuestieMap.questIdFrames) do
        for _, frameName in pairs(frameList) do
            local frame = _G[frameName]
            if (frame and frame.x and frame.y and frame.UiMapID and frame.hidden) then
                if (QuestieMap.utils.IsExplored(frame.UiMapID, frame.x, frame.y) and not frame:ShouldBeHidden()) then
                    frame:FakeShow()
                end
            end
        end
    end
end

--- Rescale a single icon
---@param frameRef string|IconFrame @The global name/iconRef of the icon frame, e.g. "QuestieFrame1"
---@param mapScale number? @Scale value for the final size of the Icon
function QuestieMap.utils.RescaleIcon(frameRef, mapScale)
    local frame = frameRef;
    local iconScale = mapScale or 1
    if type(frameRef) == "string" then
        frame = _G[frameRef];
    end
    if frame and frame.data then
        if frame.data.GetIconScale then
            frame.data.IconScale = frame.data:GetIconScale();
            local scale
            if frame.miniMapIcon then
                -- Use globalMiniMapTownsfolkScale for townsfolk icons, globalMiniMapScale for quest icons
                local scaleProfile = frame.isManualIcon and Questie.db.profile.globalMiniMapTownsfolkScale or Questie.db.profile.globalMiniMapScale
                scale = 16 * (frame.data.IconScale or 1) * (scaleProfile or 0.7);
            else
                --? If you ever chanage this logic, make sure you change the logic in QuestieMap:ProcessQueue() too!
                local scaleProfile = frame.isManualIcon and Questie.db.profile.globalTownsfolkScale or Questie.db.profile.globalScale
                scale = (16 * (frame.data.IconScale or 1) * (scaleProfile or 0.7)) * iconScale;
            end

            if scale > 1 then
                frame:SetSize(scale, scale)
                frame:GlowUpdate()
            end
        else
            Questie.Error("A frame is lacking the GetIconScale function for resizing!", frame.data.Id);
        end
    end
end
