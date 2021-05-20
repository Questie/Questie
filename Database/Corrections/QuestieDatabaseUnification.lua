
-- this module is used to combine data from classic and TBC databases

---@class QuestieDatabaseUnification
local QuestieDatabaseUnification = QuestieLoader:CreateModule("QuestieDatabaseUnification")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local function combineTable(t1, t2) -- return a table that contains all entries in t1, and include entries from t2 if they dont exist in t1 (recursive)
    for k, v in pairs(t2) do
        if not t1[k] then
            t1[k] = v
        elseif type(v) == "table" and type(t1[k]) == "table" then
            t1[k] = combineTable(t1[k], v)
        end
    end
    return t1
end

function QuestieDatabaseUnification:CombineQuests(classic, tbc)

    tbc = combineTable(tbc, classic)

    for k, v in pairs(tbc) do
        local classicData = classic[k]

        -- replace racemask where possible
        if (0 == v[QuestieDB.questKeys.requiredRaces] or not v[QuestieDB.questKeys.requiredRaces]) and classicData and 0 ~= classicData[QuestieDB.questKeys.requiredRaces] then
            classicData = classicData[QuestieDB.questKeys.requiredRaces]

            if classicData == 77 then
                v[QuestieDB.questKeys.requiredRaces] = QuestieDB.raceKeys.ALL_ALLIANCE
            elseif classicData == 178 then
                v[QuestieDB.questKeys.requiredRaces] = QuestieDB.raceKeys.ALL_HORDE
            end
        end
    end

    return tbc
end

function QuestieDatabaseUnification:CombineItems(classic, tbc)
    return combineTable(tbc, classic)
end

function QuestieDatabaseUnification:CombineNPCs(classic, tbc)
    return combineTable(tbc, classic)
end

function QuestieDatabaseUnification:CombineObjects(classic, tbc)
    return combineTable(tbc, classic)
end
