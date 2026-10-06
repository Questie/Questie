---@class MapLib
local MapLib = QuestieLoader:CreateModule("MapLib")

---Alias
---@alias UiMapId number

----Generic type declarations
---@class PointXY
---@param x number
---@param y number
---@param UiMapId UiMapId @Optional, not always there...

-----Local declarations
--Table
local tInsert, tSort = table.insert, table.sort
--Math
local mCeil, mMin, mMax = math.ceil, math.min, math.max

------------------------------------------------
--#region Median, Avarage, Absolute list calculations
------------------------------------------------

local function median (numlist)
    if type(numlist) ~= 'table' then return numlist end
    tSort(numlist)
    if #numlist %2 == 0 then return (numlist[#numlist/2] + numlist[#numlist/2+1]) / 2 end
    return numlist[mCeil(#numlist/2)]
end

---Returns the median X, Y from a pointList
---@param pointArray PointXY[] @pointArray {x=0, y=0}
---@return PointXY @{x=?, y=?}
function MapLib:MedianPoint(pointArray)
    if type(pointArray) ~= 'table' then return nil, nil end
    local x = {}
    local y = {}

    ---@param point PointXY
    for _, point in pairs(pointArray)do
        tInsert(x, point.x)
        tInsert(y, point.y)
    end
    return {x=median(x), y=median(y)}
end

---Returns the Avarage center point.
---@param pointArray PointXY[] @pointArray {x=0, y=0}
---@return PointXY @{x=?, y=?}
function MapLib:CenterPoint(pointArray)
    local center = {x=0, y=0}
    local count = 0
    for _, point in pairs(pointArray) do
        center.x = center.x + point.x
        center.y = center.y + point.y
        count = count + 1
    end
    center.x = center.x / count
    center.y = center.y / count
    if(count == 0) then
        center.x = nil
        center.y = nil
    end
    return center
end

---Absolute center, not avarage
---@param pointArray PointXY[] @pointArray {x=0, y=0}
---@return PointXY @{x=?, y=?}
function MapLib:AbsCenterPoint(pointArray)
    --Localize the functions
    local minX = 99999999999
    local minY = 99999999999
    local maxX = 0
    local maxY = 0
    for _, point in pairs(pointArray) do
        minX = mMin(minX, point.x);
        minY = mMin(minY, point.y);
        maxX = mMax(maxX, point.x);
        maxY = mMax(maxY, point.y);
    end
    --local fCenterX = minX + ((maxX - minX)/2)--local fCenterY = minY + ((maxY - minY)/2)
    return {x=minX + ((maxX - minX)/2), y=minY + ((maxY - minY)/2)}
end

---UNTESTED
---@param pointArray PointXY[] @pointArray {x=0, y=0}
---@return PointXY @{x=?, y=?}
function MapLib:AvgAbsCenterPoint(pointArray)
    --Avg
    local avgCenter = {x=0, y=0}
    local count = 0
    --Abs
    local minX = 99999999999
    local minY = 99999999999
    local maxX = 0
    local maxY = 0
    for _, point in pairs(pointArray) do
        --Avg
        avgCenter.x = avgCenter.x + point.x
        avgCenter.y = avgCenter.y + point.y
        count = count + 1
        --Abs
        minX = mMin(minX, point.x);
        minY = mMin(minY, point.y);
        maxX = mMax(maxX, point.x);
        maxY = mMax(maxY, point.y);
    end

    if(count ~= 0 and minX ~= 99999999999 and minY ~= 99999999999 and maxX ~= 0 and minX ~= 0) then
        avgCenter.x = avgCenter.x / count
        avgCenter.y = avgCenter.y / count
        local absCenter = {x=minX + ((maxX - minX)/2), y=minY + ((maxY - minY)/2)}
        return {x=(absCenter.x+avgCenter.x)/2, y=(absCenter.y+avgCenter.y)/2}
    else
		if(count == 0) then
			avgCenter.x = nil
			avgCenter.y = nil
		end
		return avgCenter
    end
end
--#endregion