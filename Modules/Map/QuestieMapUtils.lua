QuestieMap.utils = {};

local HBD = LibStub("HereBeDragonsQuestie-2.0")

-- ALl the speed we can get is worth it.
local tinsert = table.insert;
local pairs = pairs;

function QuestieMap.utils:SetDrawOrder(frame, level)
  frame.texture:SetDrawLayer("OVERLAY", level);
end

---@param points table<integer, Point> @Pointlist {x=0, y=0}
---@return Point @{x=?, y=?}
function QuestieMap.utils:CenterPoint(points)
    local center = {};
    local count = 0;
    center.x = 0;
    center.y = 0;
    for index, point in pairs(points) do
        center.x = center.x + point.x
        center.y = center.y + point.y
        count = count + 1;
    end
    center.x = center.x / count;
    center.y = center.y / count;
    return center;
end

---@param points table<integer, Point> @A simple pointlist with {x=0, y=0, zone=0}
---@param rangeR integer @Range of the hotzones.
---@return table<integer, table<integer, Point>> @A table of hotzones
function QuestieMap.utils:CalcHotzones(points, rangeR)
    if(points == nil) then return nil; end
    
    local range = rangeR or 100;
    local hotzones = {};
    local itt = 0;
    while(true) do
    	local FoundUntouched = nil;
    	for index, point in pairs(points) do
    		if(point.touched == nil) then
    			local notes = {};
    			FoundUntouched = true;
    			point.touched = true;
    			tinsert(notes, point);
    			for index2, point2 in pairs(points) do
    				local times = 1;

            if(point.x > 1 and point.y > 1) then times = 100; end
            local aX, aY = HBD:GetWorldCoordinatesFromZone(point.x/times, point.y/times, point.UIMapId);
            local bX, bY = HBD:GetWorldCoordinatesFromZone(point2.x/times, point2.y/times, point2.UIMapId);
    				--local dX = (point.x*times) - (point2.x*times)
            --local dY = (point.y*times) - (point2.y*times);
            local distance = QuestieLib:Euclid(aX or 0, aY or 0, bX or 0, bY or 0);
    				if(distance < range and point2.touched == nil and point.UIMapId == point2.UIMapId) then
    					point2.touched = true;
    					tinsert(notes, point2);
    				end
    			end
    			tinsert(hotzones, notes);
    		end
    	end
    	if(FoundUntouched == nil) then
    		break;
    	end
    	itt = itt +1
    end
    return hotzones;
end