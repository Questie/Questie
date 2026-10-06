-- Contains library functions that do not have a logical place.
---@class QuestiePolygon
Polygon = QuestieLoader:CreateModule("QuestiePolygon")

NOTES_DEBUG = true;--Set to nil to not get debug shit

--Contains all the frames ever created, this is not to orphan any frames by mistake...
local Polygon_AllFrames = {};

--Contains frames that are created but currently not used (Frames can't be deleted so we pool them to prevent crashing from frameoverflow);
local Polygon_FramePool = {};

--Contains all the used frames
local Polygon_UsedNoteFrames = {};

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

--Polygon = {};



local CREATED_NOTE_FRAMES = 1;

function Polygon:CenterPoint(points)
	--local center = {};
	--center.x = 0;
	--center.y = 0;
	--for i=1, table.getn(points) do
	--	center.x = center.x + points[i].x
	--	center.y = center.y + points[i].y
	--end
	--center.x = center.x / table.getn(points);
	--center.y = center.y / table.getn(points);
	--return center;
	local center = {}
    local count = 0
    center.x = 0
    center.y = 0
    for index, point in pairs(points) do
        center.x = center.x + point.x
        center.y = center.y + point.y
        count = count + 1
    end
    center.x = center.x / count
    center.y = center.y / count
    return center
end

function Polygon:cross(o, a, b)
   return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
end
--From a point cloud it identifies the "border" points
function Polygon:ConvexHull(points)
	table.sort(points, function(a,b)
		if(a.x ~= b.x) then
			return a.x<b.x
		else
			return a.y<b.y
		end
	end);

	--TODO Check so that last point of each list is the first point of the other list.
	local lower = {};
	for i = 1, table.getn(points) do

      while table.getn(lower) >= 2 and Polygon:cross(lower[table.getn(lower) - 1], lower[table.getn(lower)], points[i]) <= 0 do
         table.remove(lower);
      end
      table.insert(lower, points[i]);
   	end

	local upper = {};
	 for i = table.getn(points), 1 do

      while table.getn(upper) >= 2 and Polygon:cross(upper[table.getn(upper) - 1], upper[table.getn(upper)], points[i]) <= 0 do
         table.remove(upper);
      end
      table.insert(upper, points[i]);
   	end

   	--Concat the arrays
   	local hull = upper;
   	for i = 1, table.getn(lower) do
   		table.insert(hull, lower[i]);
   	end

	if(NOTES_DEBUG) then
		for i=1,table.getn(points) do
			Polygon:debug_Print(points[i].x, points[i].y)
		end
   		Polygon:debug_Print(table.getn(lower),table.getn(upper),"Returned:"..table.getn(hull));
	end

   	return hull, upper, lower;
end

-- Calculates the signed area
local function signedArea(p, q, r)
  local cross = (q.y - p.y) * (r.x - q.x)
              - (q.x - p.x) * (r.y - q.y)
  return cross
end

-- Checks if points p, q, r are oriented counter-clockwise
local function isCCW(p, q, r) return signedArea(p, q, r) < 0 end

-- Returns the convex hull using Jarvis' Gift wrapping algorithm).
-- It expects an array of points as input. Each point is defined
-- as : {x = <value>, y = <value>}.
-- See : http://en.wikipedia.org/wiki/Gift_wrapping_algorithm
-- points  : an array of points
-- returns : the convex hull as an array of points
function Polygon:jarvis_march(points)
  -- We need at least 3 points
  local numPoints = table.getn(points)
  if numPoints < 3 then return end

  -- Find the left-most point
  local leftMostPointIndex = 1
  for i = 1, numPoints do
    if points[i].x < points[leftMostPointIndex].x then
      leftMostPointIndex = i
    end
  end

  local p = leftMostPointIndex
  local hull = {} -- The convex hull to be returned

  -- Process CCW from the left-most point to the start point
  repeat
    -- Find the next point q such that (p, i, q) is CCW for all i
    local q = points[p + 1] and p + 1 or 1
    for i = 1, numPoints, 1 do
      if isCCW(points[p], points[i], points[q]) then q = i end
    end

    table.insert(hull, points[q]) -- Save q to the hull
    p = q  -- p is now q for the next iteration
  until (p == leftMostPointIndex)
  return hull
end

--Creates a blank frame for use within the map system
function Polygon:CreateBlankFrameNote()
	local f = CreateFrame("Frame","PolygonFrame"..CREATED_NOTE_FRAMES,WorldMapFrame:GetCanvas())
	--Set frame strata here
	local frameLevel = WorldMapFrame:GetFrameLevel() + 6
	local frameStrata = WorldMapFrame:GetFrameStrata()
	f:SetFrameStrata(frameStrata)
	f:SetFrameLevel(frameLevel)
	CREATED_NOTE_FRAMES = CREATED_NOTE_FRAMES+1;
	table.insert(Polygon_FramePool, f);
	table.insert(Polygon_AllFrames, f);
end

function Polygon:GetBlankNoteFrame()
	if(table.getn(Polygon_FramePool)==0) then
		Polygon:CreateBlankFrameNote();
	end
	local frame = Polygon_FramePool[1];
	table.remove(Polygon_FramePool, 1);
	table.insert(Polygon_UsedNoteFrames, frame);
	return frame;
end

--Clears the notes, goes through the Polygon_UsedNoteFrames and clears them. Then sets the QuestieUsedNotesFrame to new table;
function Polygon:CLEAR_ALL_NOTES()
	--Astrolabe:RemoveAllMinimapIcons();
	for k, v in pairs(Polygon_UsedNoteFrames) do
		--Removed Polygon:Clear_Note(v)
		v:Hide();
		if(v.texture)then
			v.texture:SetTexture(nil);
		end
		table.insert(Polygon_FramePool, v);
	end
	Polygon_UsedNoteFrames = {};
end

function Polygon:DrawPolygon(PointA, PointB, PointC, r, g, b, a)
	local COORD_MAX = 2 ^ 16 - 1
	local texture, w, h, tlX,tlY = TextureAdd("BACKGROUND", 1, 1, 1,
		PointA.x/100,PointA.y/100,
		PointB.x/100,PointB.y/100,
		PointC.x/100,PointC.y/100)
	if(texture) then
		local fr = Polygon:GetBlankNoteFrame();
		fr:SetFrameLevel(10);
		fr:SetWidth(w);
		fr:SetHeight(h);
		fr:SetPoint("TOPLEFT",tlX,tlY)
		texture:SetDrawLayer("BACKGROUND");
		texture:SetVertexColor(r or 0.5, g or 0, b or 1,a or 0.5)
		texture:SetAllPoints(fr);
		fr.texture = texture;
		fr:Show();
		--f:SetScript("OnUpdate", function() this:SetFrameLevel(133223); end);
		return fr;
	end
end
local texFrame = CreateFrame("Frame", nil, WorldMapFrame:GetCanvas())
local frameLevel = WorldMapFrame:GetCanvas():GetFrameLevel() + 4
local frameStrata = WorldMapFrame:GetCanvas():GetFrameStrata()
texFrame:SetPoint("CENTER");
texFrame:SetSize(WorldMapFrame:GetCanvas():GetSize())
texFrame:SetParent(WorldMapFrame:GetCanvas())
texFrame:SetFrameStrata(frameStrata)
texFrame:SetFrameLevel(frameLevel)
--texFrame:SetFrameLevel(WorldMapFrame:GetCanvas():GetFrameLevel()+1000)
--texFrame:SetFrameStrata("DIALOG")
function DrawTriangle(Point1, Point2, center)
	local ULp, URp;
	if(Point1.x < Point2.x) then
		ULp = Point1
		URp = Point2
	else
		ULp = Point2
		URp = Point1
	end
	local tex = texFrame:CreateTexture(nil, "OVERLAY", nil, 7)
	local width, height = WorldMapFrame:GetCanvas():GetSize();		--local tex = f:CreateTexture()
	--tex:SetAllPoints(f)
	--tex:SetTexture(QuestieLib.AddonPath.."Icons\\square", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST") --'interface/icons/ability_ambush'
	tex:SetTexture(QuestieLib.AddonPath.."Icons\\square", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST") --'interface/icons/ability_ambush'
	--tex:SetColorTexture(0, 1, 1, 0.5)
	tex:SetVertexColor(0, 1, 1, 0.5)
	tex:SetSize(width, height)
	tex:SetPoint("CENTER")
	local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy;

	ULx, ULy = 0,0---0.25,-0.25
	URx, URy = 1,0
	LLx, LLy = 0,1
	LRx, LRy = 1,1 -- X +=LEFT, -=RIGTH

	ULvx = (ULp.x/100)*width;
	ULvy = -((ULp.y/100)*height);

	LLvx = (center.x/100)*width;
	LLvy = (1-(center.y/100))*height;

	URvx = -((1-(URp.x/100))*width);
	URvy = -((URp.y/100)*height);

	LRvx = -((1-(center.x/100))*width);
	LRvy = (1-(center.y/100))*height;

	Questie:Debug(DEBUG_DEVELOP, "Old coords: ");
	Questie:Debug(DEBUG_DEVELOP, "UL: ", ULvx ,  " : ",  ULvy);
	Questie:Debug(DEBUG_DEVELOP, "LL: ", LLvx ,  " : ",  LLvy);
	Questie:Debug(DEBUG_DEVELOP, "UR: ", URvx ,  " : ",  URvy);
	Questie:Debug(DEBUG_DEVELOP, "LR: ", LRvx ,  " : ",  LRvy);

	tex:SetVertexOffset(UPPER_LEFT_VERTEX, ULvx, ULvy);
	tex:SetVertexOffset(LOWER_LEFT_VERTEX, LLvx, LLvy);
	tex:SetVertexOffset(UPPER_RIGHT_VERTEX, URvx, URvy);
	tex:SetVertexOffset(LOWER_RIGHT_VERTEX, LRvx, LRvy);
	--	tex:SetVertTile(true)
	--	tex:SetHorizTile(true)
	tex:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
	local oULx,oULy,oLLx,oLLy,oURx,oURy,oLRx,oLRy = tex:GetTexCoord()
	Questie:Debug(DEBUG_DEVELOP, "Old coords: ");
	Questie:Debug(DEBUG_DEVELOP, "UL: ", oULx ,  " : ",  oULy);
	Questie:Debug(DEBUG_DEVELOP, "LL: ", oLLx ,  " : ",  oLLy);
	Questie:Debug(DEBUG_DEVELOP, "UR: ", oURx ,  " : ",  oURy);
	Questie:Debug(DEBUG_DEVELOP, "LR: ", oLRx ,  " : ",  oLRy);
end

function testfunc(points, center)

	for i = 1, table.getn(points) do
		local Point = {}
		table.insert(Point, points[i])
		if(points[i+1]) then
			table.insert(Point, points[i+1])
		else
			break
		end


		DrawTriangle(Point[1], Point[2], center);
	end

end
local once = true
function Polygon:DrawPointList(Points, r, g, b)
		local hull= Polygon:jarvis_march(Points);
		local ReturnFrames = {};
		--We dont want it to draw shit outside of the mapframe, looks bad.
		--LOGON: NEW 
		--for k, v in pairs(hull) do
		--	if(v.x > 1 or v.x < 0 or v.y > 1 or v.y < 0) then
		--		return;
		--	end
		--end
		if(hull == nil) then
			return;
		end
		if(convex == nil or convex == true) then
			local center = Polygon:CenterPoint(hull);
			testfunc(hull, center);
			--Loop through upper and lower to get the polygon artifacts out, should not change any performance but the code is longer.
			for i = 1, table.getn(hull) do
				local PointB;
				if(hull[i+1]) then
					PointB = hull[i+1];
				else
					PointB = center;
				end
				--Polygon:debug_Print(upper[i], PointB, center);
				--local f = Polygon:DrawPolygon(hull[i], PointB, center,r,g,b);
				--table.insert(ReturnFrames, f);
			end

			DrawTriangle(hull[1], hull[table.getn(hull)], center);
			--local f = Polygon:DrawPolygon(hull[1],hull[table.getn(hull)],center,r,g,b);
			--table.insert(ReturnFrames, f);
			--[[
			for i = 1, table.getn(lower) do
				local PointB;
				if(lower[i+1]) then
					PointB = lower[i+1];
				else
					PointB = center;
				end
				--Polygon:debug_Print(lower[i], PointB,center);
				--Polygon:DrawPolygon(lower[i], PointB, center);
			end]]--
		end



		--TODO: Debug Should move or remove later.
		if(NOTES_DEBUG=="tt") then
			for i=1, table.getn(hull) do
				--function Polygon:TextureAdd(layer, r, g, b, aX, aY, bX, bY, cX, cY)
				local ff = Polygon:GetBlankNoteFrame();
				local t = ff:CreateTexture(nil, "BACKGROUND");
				t:SetTexture("Interface/Icons/INV_Misc_Coin_06")
				ff:SetWidth(16);
				ff:SetHeight(16);
				--t:SetAllPoints(f);
				ff:SetPoint("TOPLEFT",(hull[i].x*WorldMapFrame:GetCanvas():GetWidth()),(-hull[i].y*WorldMapFrame:GetCanvas():GetHeight())+8)
				t:SetAllPoints(ff);
				ff.index = i;
				ff:SetScript("OnEnter", function() DEFAULT_CHAT_FRAME:AddMessage(this.index); end)
				ff.texture = t;
				ff:SetFrameLevel(10);
				ff:Show();
			end
		end
		Polygon:debug_Print("Total created frames:"..table.getn(Polygon_AllFrames))
		return ReturnFrames;
end

local function avgFromList(list)
	local sum = 0
	for k, v in pairs(list) do
		sum = sum + v
	end
	if(#list > 0) then
		return sum/#list
	end
	return 0
end


---@type Blob
local Blob = QuestieLoader:ImportModule("Blob")

local HBD = LibStub("HereBeDragonsQuestie-2.0")
function Polygon:CalcHotzones2(points, rangeR, count)
	print("calc2")
    if(points == nil) then return nil; end

    --If count isn't set we want to distance clustering to still work,
    --to simplify the logic we just use a big number.
    if not count then
      count = 99999;
	end

	--Lets just look it up once!
	local GetWorldCoordinatesFromZone = HBD.GetWorldCoordinatesFromZone
	local Euclid = QuestieLib.Euclid

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
				local checkPoint = point;
				local avgDistance = {}

				--local pointsByDistance = {}
                tinsert(notes, point);
                for index2, point2 in pairs(points) do
                    --We only want to cluster icons that are on the same map.
					if(checkPoint.UiMapID == point2.UiMapID) then
						local times = 1;

						if (checkPoint.x > 1 and checkPoint.y > 1) then
							times = 0.01
						end

						local aX, aY = GetWorldCoordinatesFromZone(self,
											checkPoint.x * times, checkPoint.y * times,
											checkPoint.UiMapID)
						local bX, bY = GetWorldCoordinatesFromZone(self,
											point2.x * times, point2.y * times,
											point2.UiMapID)
						--if(	bX < aX+range or --Maybe something like this could improve performance?
						--	bX > aX-range or
						--	bY < aY+range or
						--	bY > aY-range) then
						local distance =
							Euclid(self, aX or 0, aY or 0, bX or 0, bY or 0)
						--pointsByDistance[distance] = point2;
						point2.distance = distance
						if (distance < range and point2.touched == nil) then
							table.insert(avgDistance, distance);
							point2.touched = true
							tinsert(notes, point2)
							local newCheckPoint = Polygon:CenterPoint(notes)
							newCheckPoint.UiMapID = checkPoint.UiMapID
							checkPoint = newCheckPoint
						end
						--end
                    end
                end
				--print(avgFromList(avgDistance))

				--local iconCount = 0;
				--local orderedList = {}
				--local tableKeys = {}

				--for k in pairs(pointsByDistance) do
				--	tinsert(tableKeys, k)
				--end
				--table.sort(tableKeys)
				--globalKeys = tableKeys;
				---- use the keys to retrieve the values in the sorted order
				--for _, distance in ipairs(tableKeys) do
				--	iconCount = iconCount + 1;
				--	tinsert(orderedList, pointsByDistance[distance]);
				--end
				--globallist = orderedList

				-- Here we recalculate the distance for all untouched notes due to the drift of the center.
				local times = 1;
				if (checkPoint.x > 1 and checkPoint.y > 1) then
					times = 0.01
				end
				for k, opoint in pairs(points) do
					local aX, aY = GetWorldCoordinatesFromZone(self,
						checkPoint.x * times, checkPoint.y * times,
						checkPoint.UiMapID)
					local bX, bY = GetWorldCoordinatesFromZone(self,
						opoint.x * times, opoint.y * times,
						opoint.UiMapID)
					local distance =
						Euclid(self, aX or 0, aY or 0, bX or 0, bY or 0)
					if (distance < range and opoint.touched == nil) then
						table.insert(avgDistance, distance);
						opoint.touched = true
						tinsert(notes, opoint)
						local newCheckPoint = Polygon:CenterPoint(notes)
						newCheckPoint.UiMapID = checkPoint.UiMapID
						checkPoint = newCheckPoint
					end
				end

				--A test to try and remove overlaping polygons
				-- Kinda works but at the same time not...
				--local filteredPoints = Blob.util:PreprocessHull(notes)
				--if(#filteredPoints > 3) then
				--	local hull = Blob.util:jarvis_march(filteredPoints)
				--	if(#hull > 3) then
				--		for index, point2 in pairs(points) do
				--			local inside = Blob.util:insidePolygon(hull, point2)
				--			if(inside) then
				--				point2.touched = true
				--				tinsert(notes, point2)
				--			end
				--		end
				--	end
				--end

                tinsert(hotzones, notes)
            end
        end
		if (FoundUntouched == nil) then 
			for index, point in pairs(points) do
				point.touched = nil;
			end
			break 
		end
        itt = itt + 1
    end
    return hotzones
end

--- Start MeanShift (Shit)

local function gaussian_kernel(euclidean_distance, bandwidth)
    local val = (1/(bandwidth*math.sqrt(2*math.pi))) * math.exp(-0.5*((euclidean_distance / bandwidth))^2)
	return val
end

function Polygon:Shift(point, original_points, kernel_bandwidth)
	local GetWorldCoordinatesFromZone = HBD.GetWorldCoordinatesFromZone
	local Euclid = QuestieLib.Euclid
	local shift_point = {x=0, y=0, x_org=point.x_org, y_org=point.y_org}
	local scale_factor = 0
	local times = 1;
	if (point.x > 1 and point.y > 1) then
		times = 0.01
	end
	print("Inside Shift");
	for pI=1, #original_points do
		local p_temp = original_points[pI]
		--numerator
		local aX, aY = GetWorldCoordinatesFromZone(self,
			point.x, point.y,
			point.UiMapID)
		local bX, bY = GetWorldCoordinatesFromZone(self,
			p_temp.x, p_temp.y,
			p_temp.UiMapID)
		local distance =
			Euclid(self, aX or 0, aY or 0, bX or 0, bY or 0)
		print("Dist", distance)
		local weight = gaussian_kernel(distance, kernel_bandwidth)
		print(weight)
        shift_point.x = shift_point.x + (p_temp.x * weight)
        shift_point.y = shift_point.y + (p_temp.y * weight)
		print(shift_point.x, shift_point.y)
        --# denominator
		scale_factor = scale_factor + weight
	end
	print("ScaleFact:", scale_factor)
    shift_point.x = shift_point.x / scale_factor
    shift_point.y = shift_point.y / scale_factor
    return shift_point
end

function Polygon:CalcHotzones3(points, kernel_bandwidth)
	local GetWorldCoordinatesFromZone = HBD.GetWorldCoordinatesFromZone
	local Euclid = QuestieLib.Euclid


	globalData = {}
	local returnData = {}
	for UiMapID, mapPoints in pairs(points) do
		local max_min_dist = 1
		local iteration_number = 0

		local MIN_DISTANCE = 0.00001
		local shift_points = {} --CopyTable(mapPoints);
		local times = 1;
		if (mapPoints[1].x > 1 and mapPoints[1].y > 1) then
			times = 0.01
		end
		for k, v in pairs(mapPoints) do
			shift_points[k] = v
			shift_points[k].x_org = shift_points[k].x;
			shift_points[k].y_org = shift_points[k].y;
			shift_points[k].x = shift_points[k].x * times;
			shift_points[k].y = shift_points[k].y * times;
			shift_points[k].still_shifting = true
		end
		while max_min_dist > MIN_DISTANCE do
			print(max_min_dist)
			max_min_dist = 0
			iteration_number = iteration_number + 1
			for i=1, #shift_points do
				print(shift_points[i].still_shifting)
				if shift_points[i].still_shifting then
					local p_new = shift_points[i]
					local p_new_start = p_new
					p_new = Polygon:Shift(p_new, mapPoints, kernel_bandwidth)

					local aX, aY = GetWorldCoordinatesFromZone(self,
						p_new.x , p_new.y ,
						p_new.UiMapID)
					local bX, bY = GetWorldCoordinatesFromZone(self,
						p_new_start.x , p_new_start.y ,
						p_new_start.UiMapID)
					local distance =
						Euclid(self, aX or 0, aY or 0, bX or 0, bY or 0)

					print(p_new.x, p_new.y)
					print(p_new_start.x, p_new_start.y)
					if distance > max_min_dist then
						max_min_dist = distance
					end
					if distance < MIN_DISTANCE then
						shift_points[i].still_shifting = false
					end
					shift_points[i] = p_new
				end
			end
		end
		--/dump globalData[1429]


		local function distance_to_group(point, group)
			local min_distance = 9999999999
			local times = 1;
			if (point.x > 1 and point.y > 1) then
				times = 0.01
			end
			local distances = {}
			for _, pt in pairs(group) do
				local aX, aY = GetWorldCoordinatesFromZone(self,
					point.x * times, point.y * times,
					UiMapID)
				local bX, bY = GetWorldCoordinatesFromZone(self,
					pt.x * times, pt.y * times,
					UiMapID)
				local distance =
					Euclid(self, aX or 0, aY or 0, bX or 0, bY or 0)
				if distance < min_distance then
					table.insert(distances, distance)
				end
			end
			return avgFromList(distances)
		end
		GROUP_DISTANCE_TOLERANCE = 90
		local function determine_nearest_group(point, groups)
			local nearest_group_index = nil
			local index = 1
			local nearest_group_distance = 9999999999999
			for _, group in pairs(groups) do
				local distance_to_group = distance_to_group(point, group)
				print("DistToGroup", distance_to_group)
				if distance_to_group < GROUP_DISTANCE_TOLERANCE then
					if(distance_to_group < nearest_group_distance) then
						nearest_group_distance = distance_to_group
						nearest_group_index = index
					end
				end
				index = index + 1
			end
			return nearest_group_index
		end

		local group_assignment = {}
		local groups = {}
		local group_index = 1
		for k, p in pairs(shift_points) do
			print("Org", p.x_org)
			local nP = {x=p.x_org, y=p.y_org}
			local nearest_group_index = determine_nearest_group(nP, groups)
			if nearest_group_index == nil then
				table.insert(groups, {nP})
				table.insert(group_assignment, group_index)
				group_index = group_index + 1
			else
				table.insert(group_assignment, nearest_group_index)
				table.insert(groups[nearest_group_index], nP);
			end
		end

		if(UiMapID == 1429) then
			globaltestvar = {}
			globaltestvar.groups = groups
			globaltestvar.group_assignment = group_assignment
		end
		globalData[UiMapID] = groups
		returnData[UiMapID] = groups
	end
	return returnData
end

--- end meanshift

local HBD = LibStub("HereBeDragonsQuestie-2.0")
function Polygon:CalcHotzones(points, rangeR, count)
	print("calc2")
    if(points == nil) then return nil; end

    --If count isn't set we want to distance clustering to still work,
    --to simplify the logic we just use a big number.
    if not count then
      count = 99999;
	end

	--Lets just look it up once!
	local GetWorldCoordinatesFromZone = HBD.GetWorldCoordinatesFromZone
	local Euclid = QuestieLib.Euclid

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
                    --We only want to cluster icons that are on the same map.
					if(point.UiMapID == point2.UiMapID) then
						local times = 1;

						if (point.x > 1 and point.y > 1) then
							times = 0.01
						end

						local aX, aY = GetWorldCoordinatesFromZone(self,
											point.x * times, point.y * times,
											point.UiMapID)
						local bX, bY = GetWorldCoordinatesFromZone(self,
											point2.x * times, point2.y * times,
											point2.UiMapID)
						--if(	bX < aX+range or --Maybe something like this could improve performance?
						--	bX > aX-range or
						--	bY < aY+range or
						--	bY > aY-range) then
						local distance =
							Euclid(self, aX or 0, aY or 0, bX or 0, bY or 0)
						if (distance < range and point2.touched == nil) then
							point2.touched = true
							tinsert(notes, point2)
						end
						--end
                    end
                end
                tinsert(hotzones, notes)
            end
        end
		if (FoundUntouched == nil) then 
			for index, point in pairs(points) do
				point.touched = nil;
			end
			break 
		end
        itt = itt + 1
    end
    return hotzones
end

function Polygon:Hotzones(points)
    local allPoints = points;
    local t = {};
    local itt = 0;
    while(true) do
    	local FoundUntouched = nil;
    	for k, v in pairs(allPoints) do
    		if(v.touched == nil) then
    			local notes = {};
    			FoundUntouched = "true";
    			v.touched = true;
    			table.insert(notes, v);
    			for k2,v2 in pairs(allPoints) do
    				local times = 1;
    				--TODO Better stuff!!!
    				if(v.x < 1.01) then times = 100; end
    				local dX = (v.x*times) - (v2.x*times)
    				local dY = (v.y*times) - (v2.y*times);
    				if(dX*dX + dY * dY < (10*10) and v2.touched == nil) then
    					v2.touched = true;
						table.insert(notes, v2);
						DEFAULT_CHAT_FRAME:AddMessage(v2.x);
    				end
    			end
    			table.insert(t, notes);
    		end
    	end
    	if(FoundUntouched == nil) then
    		for k, v in pairs(allPoints) do
    			v.touched = nil;
    		end
    		break;
    	end
    	itt = itt +1
    end
    return t;
end

function RotateCoordPair (x,y,ox,oy,a,asp)
	y=y/asp
	oy=oy/asp
	return ox + (x-ox)*math.cos(a) - (y-oy)*math.sin(a),
		(oy + (y-oy)*math.cos(a) + (x-ox)*math.sin(a))*asp
end

--DEBUG CODE!
function Polygon_SlashHandler(msgbase)
	print("test")
	print("new")
	if(msgbase=="test") then
		local Points = {}
		--for i=1,3 do
		--	local point = {};
		--	point.x = (math.random()*0.6)+0.3;
		--	point.y = (math.random()*0.6)+0.3;
		--	--table.insert(Points, point);
		--end
		--local p1 = {};
		--p1.x = 0;
		--p1.y = 0;
		--local p2 = {};
		--p2.x = 100;
		--p2.y = 0;
		--local p3 = {};
		--p3.x = 50;
		--p3.y = 50;
----
		--table.insert(Points, p1);
		--table.insert(Points, p2);
		--table.insert(Points, p3);
		--Polygon:DrawPolygon(p1,p2,p3);
		
--
		--Polygon:CLEAR_ALL_NOTES();
		--Polygon:DrawPointList(Points,0,1,0);
		

		--ff:SetWidth(16);
		--ff:SetHeight(16);
		----t:SetAllPoints(f);
		--ff:SetPoint("TOPLEFT",(hull[i].x*WorldMapFrame:GetCanvas():GetWidth()),(-hull[i].y*WorldMapFrame:GetCanvas():GetHeight())+8)
		--t:SetAllPoints(ff);

		--local mask = UIParent:CreateMaskTexture()
		--mask:SetTexture(QuestieLib.AddonPath.."Icons\\triangletgablacknoedge", "CLAMPTOBLACK", "CLAMPTOBLACK")
		--mask:SetSize(128, 128)
		--mask:SetPoint("CENTER", 0, 0);

		--local mask2 = UIParent:CreateMaskTexture()
		--mask2:SetTexture(QuestieLib.AddonPath.."Icons\\triangletgablacknoedge", "CLAMPTOWHITE", "CLAMPTOWHITE")
		--mask2:SetSize(128, 128)
		--mask2:SetPoint("CENTER", 50, 0);

		--local mask3 = UIParent:CreateMaskTexture()
		--mask3:SetTexture(QuestieLib.AddonPath.."Icons\\triangletgablacknoedge", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		--mask3:SetSize(128, 128)
		--mask3:SetPoint("CENTER", 80, 0);

		--local mask4 = UIParent:CreateMaskTexture()
		--mask4:SetTexture(QuestieLib.AddonPath.."Icons\\triangletgablacknoedge", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		--mask4:SetSize(128, 128)
		--mask4:SetPoint("CENTER", 100, 0);

		
		local f = CreateFrame("Frame", nil, UIParent)
		f:SetPoint("CENTER")
		f:SetSize(128, 128)
		f:HookScript("OnMouseWheel", function(self, delta)
			DEFAULT_CHAT_FRAME:AddMessage("You scrolled!"..delta)
		end)

		--local tx = WorldMapFrame:CreateTexture(nil, 'OVERLAY')
		--tx:SetSize(128, 128)
		--tx:SetPoint('CENTER')
		--tx:SetColorTexture(0, 1, 1, 0.5)

		--local x = 0;
		--local size = 1;
		--for i = 1, 20*5, 1 do
		--	local tx = UIParent:CreateTexture(nil, 'OVERLAY')
		--	tx:SetTexture(QuestieLib.AddonPath.."Icons\\square", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "LINEAR")
		--	tx:SetSize(size, 10+i)
		--	tx:SetPoint('CENTER', x*size, 0)
		--	tx:SetColorTexture(0, 1, 1, 0.5)
		--	x = x + 1
		--end
		

		--tex:SetRotation(90*0.0174532925,0.5,0.5)
		--setCoords(texture, )
		--tex:SetTexCoord(0, -0.25, -0.25, 1.25, 1, -0.25, 1.25, 1.25)
		--tex:SetTexCoord(-300/width, 0, -300/width, 300/height,   1, -0.25,   1.5, 1.25)


		--coords={
		--	tl={x=0,y=0},
		--	bl={x=-0.5,y=1},
		--	tr={x=1,y=0},
		--	br={x=1.5,y=1}
		--}
		--origin={x=0.5,y=0.5}
		--aspect=(width/2)/(width/2) -- width/height
		--angle=0
		--local ULx, ULy = RotateCoordPair(coords.tl.x,coords.tl.y,origin.x,origin.y,angle,aspect)
		--local LLx, LLy = RotateCoordPair(coords.bl.x,coords.bl.y,origin.x,origin.y,angle,aspect)
		--local URx, URy = RotateCoordPair(coords.tr.x,coords.tr.y,origin.x,origin.y,angle,aspect)
		--local LRx, LRy = RotateCoordPair(coords.br.x,coords.br.y,origin.x,origin.y,angle,aspect)
		--tex:SetTexCoord(
--
		--)


		local tan = math.tan(1,1)
		local atan = math.atan(1, 1)
		--DEFAULT_CHAT_FRAME:AddMessage(tan)
		
		local angle1 = math.atan2(1, 1); --y, x
		local angle2 = math.atan2(0, 1); --y, x
		local angle = angle1 - angle2
		--DEFAULT_CHAT_FRAME:AddMessage(angle1);
		--DEFAULT_CHAT_FRAME:AddMessage(angle2);
		--DEFAULT_CHAT_FRAME:AddMessage(angle);
		--DEFAULT_CHAT_FRAME:AddMessage(angle);
		--DEFAULT_CHAT_FRAME:AddMessage(math.tan(angle));





		--local X = A * -1 + B * 0 + C
		--local Y = D * -1 + E * 0 + F

		--local det = A * E - B * D

		--x   = ( EX - BY + (BF-CE)) / det
		--y   = (-DX + AY - (AF-CD)) / det

		--ULx = ( B*F - C*E) / det
		--ULy = (-A*F + C*D) / det

		--LLx = (-B + B*F - C*E) / det
		--LLy = ( A - A*F + C*D) / det

		--URx = ( E + B*F - C*E) / det
		--URy = (-D - A*F + C*D) / det

		--LRx = ( E - B + B*F - C*E) / det
		--LRy = ( A - A*F + C*D) / det



		--A, B, C = 1,   0,   10;---15
		--D, E, F = 0,   1,   10;---15
		--G, H, I = 0,   0,   1;
--
		--ULx = ( B*F - C*E) / det
		--ULy = (-A*F + C*D) / det
--
		--LRx = ( E - B + B*F - C*E) / det
		--LRy = ( A - A*F + C*D) / det

		function setCoords(t, A, B, C, D, E, F, update)
			if(update) then
				
			end
			local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy;
			local oULx,oULy,oLLx,oLLy,oURx,oURy,oLRx,oLRy = t:GetTexCoord()
			local det = A*E - B*D;

			ULx, ULy = ( B*F - C*E ) / det, ( -(A*F) + C*D ) / det;
			LLx, LLy = ( -B + B*F - C*E ) / det, ( A - A*F + C*D ) / det;
			URx, URy = ( E + B*F - C*E ) / det, ( -D - A*F + C*D ) / det;
			LRx, LRy = ( E - B + B*F - C*E ) / det, ( -D + A -(A*F) + C*D ) / det;
			
			DEFAULT_CHAT_FRAME:AddMessage("setCoords");
			DEFAULT_CHAT_FRAME:AddMessage("UL: "..ULx .. " : ".. ULy);
			DEFAULT_CHAT_FRAME:AddMessage("LL: "..LLx .. " : ".. LLy);
			DEFAULT_CHAT_FRAME:AddMessage("UR: "..URx .. " : ".. URy);
			DEFAULT_CHAT_FRAME:AddMessage("LR: "..LRx .. " : ".. LRy);
			DEFAULT_CHAT_FRAME:AddMessage("---------");
			
			return ULx, ULy, LLx, LLy, URx, URy, LRx, LRy;
		end

		local tex = WorldMapFrame:GetCanvas():CreateTexture(nil, "OVERLAY", nil, 7)
		local width, height = WorldMapFrame:GetCanvas():GetSize();		--local tex = f:CreateTexture()
		--tex:SetAllPoints(f)
		--tex:SetTexture(QuestieLib.AddonPath.."Icons\\square", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST") --'interface/icons/ability_ambush'
		tex:SetTexture(QuestieLib.AddonPath.."Icons\\gridnoborder", "CLAMP", "CLAMP", "NEAREST") --'interface/icons/ability_ambush'
		--tex:SetColorTexture(0, 1, 1, 0.5)
		tex:SetVertexColor(0, 1, 1, 0.5)
		tex:SetSize(200, 100)
		DEFAULT_CHAT_FRAME:AddMessage(width);
		DEFAULT_CHAT_FRAME:AddMessage(height);
		Questie:Debug(DEBUG_DEVELOP, "W:", width, "H:", height, "H/2:", height/2)
		local UIhalf = ConvertPixelsToUI(256, WorldMapFrame:GetCanvas():GetScale());
		local UIt = ConvertPixelsToUI(256, WorldMapFrame:GetCanvas():GetScale());
		Questie:Debug(DEBUG_DEVELOP, "Pixels->UI", UIt);
		tex:SetPoint("CENTER")

		local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy;

		ULx, ULy = 0,0---0.25,-0.25
		URx, URy = 1,0
		LLx, LLy = 0,1
		LRx, LRy = 1,1 -- X +=LEFT, -=RIGTH

		URvx = -(0.4*width);
		URvy = -(0.4*height);

		ULvx = 0.4*width;
		ULvy = -(0.4*height);

		LRvx = -(0.6*width);
		LRvy = 0.6*height;

		LLvx = 0.4*width;
		LLvy = 0.4*height;


		URvx = -(0.1*width);
		URvy = -(0.1*height);

		ULvx = width;
		ULvy = -(0.1*height);

		LRvx = -(0.1*width);
		LRvy = (0.1*height);
		

		LLvx = 0;
		LLvy = 0;

		URvx = 0;
		URvy = 0;

		ULvx = 100;
		ULvy = 0;

		LRvx = 0;
		LRvy = 0;
		
		LLvx = 0;
		LLvy = 0;

		tex:SetVertexOffset(UPPER_RIGHT_VERTEX, URvx, URvy);
		tex:SetVertexOffset(UPPER_LEFT_VERTEX, ULvx, ULvy);
		tex:SetVertexOffset(LOWER_RIGHT_VERTEX, LRvx, LRvy);
		tex:SetVertexOffset(LOWER_LEFT_VERTEX, LLvx, LLvy);
		--	tex:SetVertTile(true)
		--	tex:SetHorizTile(true)
		tex:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
		local oULx,oULy,oLLx,oLLy,oURx,oURy,oLRx,oLRy = tex:GetTexCoord()
		Questie:Debug(DEBUG_DEVELOP, "Old coords: ");
		Questie:Debug(DEBUG_DEVELOP, "UL: ", oULx ,  " : ",  oULy);
		Questie:Debug(DEBUG_DEVELOP, "LL: ", oLLx ,  " : ",  oLLy);
		Questie:Debug(DEBUG_DEVELOP, "UR: ", oURx ,  " : ",  oURy);
		Questie:Debug(DEBUG_DEVELOP, "LR: ", oLRx ,  " : ",  oLRy);

		--[[
		DEFAULT_CHAT_FRAME:AddMessage("UL: "..ULx .. " : ".. ULy);
		DEFAULT_CHAT_FRAME:AddMessage("LL: "..LLx .. " : ".. LLy);
		DEFAULT_CHAT_FRAME:AddMessage("UR: "..URx .. " : ".. URy);
		DEFAULT_CHAT_FRAME:AddMessage("LR: "..LRx .. " : ".. LRy);
		DEFAULT_CHAT_FRAME:AddMessage("Width:"..-(width)/2);
		LR = affineLib.trans(1, 1);
		iLR = affineLib.inverse(LR);
		local A, B, C = 1,   0,   -5---(0.5*(1+width)) * oLRx;---15
		local D, E, F = 0,   1,   -5---(0.5*(1+height)) * oLRy;---15
		local G, H, I = 0,   0,   1;
		--_, _, _, _, _, _, LRx, LRy = setCoords(tex, A, B, C, D, E, F)
		
		UL = affineLib.trans(0, 0);
		iUL = affineLib.inverse(UL);
		A, B, C = 1,   0,   5;---15
		D, E, F = 0,   1,   5;---15
		G, H, I = 0,   0,   1;
		--ULx, ULy, _, _, _, _, _, _ = setCoords(tex, A, B, C, D, E, F)
		--tex:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)

		UR = affineLib.trans(1, 0);
		iUR = affineLib.inverse(UR);
		A, B, C = 1,   0,   0--0.3;---15
		D, E, F = 0,   1,   0--0.3;---15
		G, H, I = 0,   0,   1;
		--_, _, _, _, URx, URy, _, _ = setCoords(tex, A, B, C, D, E, F)
		---tex:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)

		LL = affineLib.trans(0, 1);
		iLL = affineLib.inverse(LL);
		A, B, C = 1,   0,   0;---15
		D, E, F = 0,   1,   0;---15
		G, H, I = 0,   0,   1;
		--_, _, LLx, LLy, _, _, _, _ = setCoords(tex, A, B, C, D, E, F)

		gLR = LR-- * iUL * iUR * iLL;
		gUL = UL-- * iLR * iUR * iLL;
		gUR = UR-- * iLR * iUL * iLL;
		gLL = LL-- * iLR * iUL * iUR;
		testVar = UL * LL * UR * LR;
		itestVar = affineLib.inverse(testVar);
		DEFAULT_CHAT_FRAME:AddMessage(testVar(5, 5))
		_, _, _, _, _, _, LRx, LRy = setCoords(tex, gLR[1][1], gLR[1][2], gLR[1][3], gLR[2][1], gLR[2][2], gLR[2][3])
		ULx, ULy, _, _, _, _, _, _ = setCoords(tex, gUL[1][1], gUL[1][2], gUL[1][3], gUL[2][1], gUL[2][2], gUL[2][3])
		_, _, _, _, URx, URy, _, _ = setCoords(tex, gUR[1][1], gUR[1][2], gUR[1][3], gUR[2][1], gUR[2][2], gUR[2][3])
		_, _, LLx, LLy, _, _, _, _ = setCoords(tex, gLL[1][1], gLL[1][2], gLL[1][3], gLL[2][1], gLL[2][2], gLL[2][3])
		
		
		--tex:SetTexCoord(ULx*oULx, ULy*oULy, LLx*oLLx, LLy*oLLy, URx*oURx, URy*oURy, LRx*oLRx, LRy*oLRy)
		--tex:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
		--ULx, ULy = testVar(0, 0)--LL(UR(UL(LR(0, 0))))  --LR(UL(UR(LL(-0.2, -0.2))))
		--LLx, LLy = testVar(0, 1)--LL(UR(UL(LR(0, 1))))  --LR(UL(UR(LL(0, 1))))
		--URx, URy = testVar(1, 0)--LL(UR(UL(LR(1, 0))))  --LR(UL(UR(LL(1, 0))))
		--LRx, LRy = testVar(1, 1)--LL(UR(UL(LR(1, 1))))  --LR(UL(UR(LL(1, 1))))
		--tex:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
		--tex:SetRotation(math.rad(45), 0.5, 0.5)
		DEFAULT_CHAT_FRAME:AddMessage("Old coords: ");
		DEFAULT_CHAT_FRAME:AddMessage("UL: "..oULx .. " : ".. oULy);
		DEFAULT_CHAT_FRAME:AddMessage("LL: "..oLLx .. " : ".. oLLy);
		DEFAULT_CHAT_FRAME:AddMessage("UR: "..oURx .. " : ".. oURy);
		DEFAULT_CHAT_FRAME:AddMessage("LR: "..oLRx .. " : ".. oLRy);
		DEFAULT_CHAT_FRAME:AddMessage("New coords: ");
		DEFAULT_CHAT_FRAME:AddMessage("UL: "..ULx .. " : ".. ULy);
		DEFAULT_CHAT_FRAME:AddMessage("LL: "..LLx .. " : ".. LLy);
		DEFAULT_CHAT_FRAME:AddMessage("UR: "..URx .. " : ".. URy);
		DEFAULT_CHAT_FRAME:AddMessage("LR: "..LRx .. " : ".. LRy);

		URpx, URpy = 0.1, 0.2*-1

		--ULxt, ULyt = UL(0, -0.2)
		--LLxt, LLyt = LL(0, 0)
		--URxt, URyt = UR(URpx, URpy)
		--local t = affineLib.trans(URxt, URyt);
		--t = affineLib.inverse(t)*iLR
		--LRxt, LRyt = LR(t(URpx+1, URpy+0.5))

		ULxt, ULyt = UL(0, -0.2)
		LLxt, LLyt = LL(0, 0)
		URxt, URyt = UR(URpx, URpy)
		local t = affineLib.trans(URxt, URyt);
		t = affineLib.inverse(t)*iLR
		LRxt, LRyt = t(1, 1)

		local ULcx, ULcy = 0, 0
		local LLcx, LLcy = 0, 1
		local LRcx, LRcy = 0.9, 0.9
		local URcx, URcy = 1, 0
		

		UL = affineLib.trans(0-ULcx, 0-ULcy)
		iUL = affineLib.inverse(UL);
		LL = affineLib.trans(UL(iUL(0-LLcx, 1+(1-LLcy))))
		iLL = affineLib.inverse(LL);
		LR = affineLib.trans(LL(iLL(1+(1-LRcx), 1+(1-LRcy))))
		iLR = affineLib.inverse(LR);
		UR = affineLib.trans(LR(iLR(1+(1-URcx), URcy*-1)))
		
		ULxt, ULyt = UL(0, 0)
		LLxt, LLyt = LL(0, 0)
		URxt, URyt = UR(0, 0)
		LRxt, LRyt = LR(0, 0)
		
		iULx, iULy = iUL(0,0)
		iLLx, iLLy = iLL(0,0)
		iLRx, iLRy = iLR(0,0)
		--tex:SetTexCoord(ULxt, ULyt, LLxt, LLyt, URxt, URyt, LRxt, LRyt)
		DEFAULT_CHAT_FRAME:AddMessage("ULt: "..ULxt .. " : ".. ULyt);
		DEFAULT_CHAT_FRAME:AddMessage("-iULt: "..iULx .. " : ".. iULy);
		DEFAULT_CHAT_FRAME:AddMessage("LLt: "..LLxt .. " : ".. LLyt);
		DEFAULT_CHAT_FRAME:AddMessage("-iLLt: "..iLLx .. " : ".. iLLy);
		DEFAULT_CHAT_FRAME:AddMessage("URt: "..URxt .. " : ".. URyt);
		DEFAULT_CHAT_FRAME:AddMessage("LRt: "..LRxt .. " : ".. LRyt);
		DEFAULT_CHAT_FRAME:AddMessage("-iLRt: "..iLRx .. " : ".. iLRy);


		--ULx, ULy = 0.4*(1/width), 0.4*(1/height)
		--URx, URy = 0.5*(1/width), 0.4*(1/height)
		--LLx, LLy = 0.5*(1/width), 0.4*(1/height)
		--LRx, LRy = 0.6*(1/width), 0.4*(1/height)
		-- <- = minus
		-- -> = plus
		-- ^ = plus
		-- v = minus
		]]--
		--
		--tex:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
		--tex:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
		--setCoords(tex, 0,0,1, 0,0,1)
		--tex:SetTexCoord((sin - cos), -(cos + sin), -cos, -sin, sin, -cos, 0, 0)
		--texture:AddMaskTexture(mask)
		--texture:AddMaskTexture(mask2)
		--texture:AddMaskTexture(mask3)
		--texture:AddMaskTexture(mask4)
		--[[
		local lol = {};
		for i=1, table.getn(DB_Creatures[504].Locations) do
			DEFAULT_CHAT_FRAME:AddMessage(DB_Creatures[504].Locations[i].x.." "..DB_Creatures[504].Locations[i].y)
			local shit = {x=DB_Creatures[504].Locations[i].x, y=DB_Creatures[504].Locations[i].y}
			table.insert(lol, shit);
		end
		local s = Polygon:Hotzones(lol);
		for k, v in s do
			Polygon:DrawPointList(v,0,1,0);
		end
		lol = {};
		for i=1, table.getn(DB_Creatures[95].Locations) do
			local shit = {x=DB_Creatures[95].Locations[i].x, y=DB_Creatures[95].Locations[i].y}
			table.insert(lol, shit);
		end
		s = Polygon:Hotzones(lol);
		for k, v in s do
			Polygon:DrawPointList(v, 0,1,0);
		end

		for k, v in Test do
			points = {};
			for i, Cord in v do
				Polygon:debug_Print(k, tostring(v));
				Cord.x = Cord.x/100;
				Cord.y = Cord.y/100;
				table.insert(points, Cord)
			end
			Polygon:DrawPointList(points);
		end]]--
	else
		Polygon:debug_Print("No such command");
	end

end


local TextureCreateFrame = CreateFrame("Frame","TextureCreateFrame",WorldMapFrame:GetCanvas());
local frameLevel = WorldMapFrame:GetFrameLevel() + 6
local frameStrata = WorldMapFrame:GetFrameStrata()
TextureCreateFrame:SetParent(WorldMapFrame)
TextureCreateFrame:SetFrameStrata(frameStrata)
TextureCreateFrame:SetFrameLevel(frameLevel)
local TextureCount = 0
function TextureCreate(Layer, R, G, B, A)
	local texture = TextureCreateFrame:CreateTexture("ScannerOverlayTexture" .. TextureCount, Layer)
	texture:SetDrawLayer("BACKGROUND");
	texture:SetVertexColor(R, G, B, A or 1)
	texture:SetBlendMode("BLEND");
	TextureCount = TextureCount+1;
	return texture
end

do
	local ApplyTransform
	do
		-- Bounds to prevent "TexCoord out of range" errors
		local function NormalizeBounds(coordinate)
			if coordinate < -1e4 then
				coordinate = -1e4
			elseif coordinate > 1e4 then
				coordinate = 1e4
			end
			return coordinate
		end

		-- Applies an affine transformation to Texture.
		-- @param texture Texture to set TexCoords for.
		-- @param ... First 6 elements of transformation matrix.
		function ApplyTransform(texture, A, B, C, D, E, F)
			local det = A * E - B * D

			if det == 0 then
				return texture:Hide() -- Scaled infinitely small
			end
			local AF = A * F
			local BF = B * F
			local CD = C * D
			local CE = C * E

			local ULx = NormalizeBounds((BF - CE) / det)
			local ULy = NormalizeBounds((CD - AF) / det)

			local LLx = NormalizeBounds((BF - CE - B) / det)
			local LLy = NormalizeBounds((CD - AF + A) / det)

			local URx = NormalizeBounds((BF - CE + E) / det)
			local URy = NormalizeBounds((CD - AF - D) / det)

			local LRx = NormalizeBounds((BF - CE + E - B) / det)
			local LRy = NormalizeBounds((CD - AF - D + A) / det)
			
			DEFAULT_CHAT_FRAME:AddMessage("UL: "..ULx .. " : ".. ULy);
			DEFAULT_CHAT_FRAME:AddMessage("LL: "..LLx .. " : ".. LLy);
			DEFAULT_CHAT_FRAME:AddMessage("UR: "..URx .. " : ".. URy);
			DEFAULT_CHAT_FRAME:AddMessage("LR: "..LRx .. " : ".. LRy);
			return texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
		end
	end

	-- Removes one-pixel transparent border
	local BORDER_OFFSET = -1 / 2048
	local BORDER_SCALE = 2048 / 2046
	local TRIANGLE_PATH = QuestieLib.AddonPath.."Icons\\trianglehuge"--square";

	-- Draw a triangle texture with vertices at relative coords.  (0,0) is top-left, (1,1) is bottom-right.
	function TextureAdd(layer, r, g, b, aX, aY, bX, bY, cX, cY)
		local abX = aX - bX
		local abY = aY - bY
		local bcX = bX - cX
		local bcY = bY - cY
		local scaleX = (bcX * bcX + bcY * bcY) ^ 0.5


		if scaleX == 0 then
			Polygon:debug_Print("B C SAME");
			return -- Points B and C are the same
		end
		local scaleY = (abX * bcY - abY * bcX) / scaleX

		if scaleY == 0 then
			Polygon:debug_Print("co-linear");
			return -- Points are co-linear
		end
		local shearFactor = -(abX * bcX + abY * bcY) / (scaleX * scaleX)
		local sin = bcY / scaleX
		local cos = -bcX / scaleX

		-- Note: The texture region is made as small as possible to improve framerates.
		local minX = math.min(aX, bX, cX)
		local minY = math.min(aY, bY, cY)
		local windowX = math.max(aX, bX, cX) - minX
		local windowY = math.max(aY, bY, cY) - minY
		-- Get a texture
		local texture = TextureCreate(WorldMapFrame:GetCanvas(), layer, r, g, b)
		texture:SetTexture(TRIANGLE_PATH, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
		local width, height = windowX*(WorldMapFrame:GetCanvas():GetWidth()), windowY*(WorldMapFrame:GetCanvas():GetHeight());

		--texture:SetPoint("TOPLEFT", minX * width, -minY * height)
		--texture:SetSize(windowX * width, windowY * height)

		--[[ Transform parallelogram so its corners lie on the tri's points:
		local Matrix = Identity
		-- Remove transparent border
		Matrix = Matrix:Scale( BorderScale, BorderScale )
		Matrix = Matrix:Translate( BorderOffset, BorderOffset )

		Matrix = Matrix:Shear( ShearFactor ) -- Shear the image so its bottom left corner aligns with point A
		Matrix = Matrix:Scale( ScaleX, ScaleY ) -- Scale X by the length of line BC, and Y by the length of the perpendicular line from BC to point A
		Matrix = Matrix:Rotate( Sin, Cos ) -- Align the top of the triangle with line BC.

		Matrix = Matrix:Translate( Bx - MinX, By - MinY ) -- Move origin to overlap point B
		Matrix = Matrix:Scale( 1 / WindowX, 1 / WindowY ) -- Adjust for change in texture size

		Polygon:ApplyTransform( unpack( Matrix, 1, 6 ) )
		]]

		-- Common operations
		local cosScaleX = cos * scaleX
		local cosScaleY = cos * scaleY
		local sinScaleX = -sin * scaleX
		local sinScaleY = sin * scaleY

		windowX = BORDER_SCALE / windowX
		windowY = BORDER_SCALE / windowY

		ApplyTransform(texture,
			windowX * cosScaleX,
			windowX * (sinScaleY + cosScaleX * shearFactor),
			windowX * ((sinScaleY + cosScaleX * (1 + shearFactor)) * BORDER_OFFSET + bX - minX) / BORDER_SCALE,
			windowY * sinScaleX,
			windowY * (cosScaleY + sinScaleX * shearFactor),
			windowY * ((cosScaleY + sinScaleX * (1 + shearFactor)) * BORDER_OFFSET + bY - minY) / BORDER_SCALE)

		return texture, width, height, minX * WorldMapFrame:GetCanvas():GetWidth(), -minY * WorldMapFrame:GetCanvas():GetHeight()
	end
end



SlashCmdList["POLYGON"] = Polygon_SlashHandler;
SLASH_POLYGON1 = "/pg";

--Debug print function
function Polygon:debug_Print(...)
	local debugWin = 0;
	local name, shown;
	for i=1, NUM_CHAT_WINDOWS do
		name,_,_,_,_,_,shown = GetChatWindowInfo(i);
		if (string.lower(name) == "mndebug") then debugWin = i; break; end
	end
	if (debugWin == 0) then return end

	local out = "";
	for i = 1, arg.n, 1 do
		if (i > 1) then out = out .. ", "; end
		local t = type(arg[i]);
		if (t == "string") then
			out = out .. '"'..arg[i]..'"';
		elseif (t == "number") then
			out = out .. arg[i];
		else
			out = out .. dump(arg[i]);
		end
	end
	getglobal("ChatFrame"..debugWin):AddMessage(out, 1.0, 1.0, 0.3);
end
