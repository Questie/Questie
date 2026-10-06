-- Contains library functions that do not have a logical place.
---@class QuestiePolygon
local QuestiePolygon = QuestieLoader:CreateModule("QuestiePolygon")

NOTES_DEBUG = true;--Set to nil to not get debug shit

--Contains all the frames ever created, this is not to orphan any frames by mistake...
local Polygon_AllFrames = {};

--Contains frames that are created but currently not used (Frames can't be deleted so we pool them to prevent crashing from frameoverflow);
local Polygon_FramePool = {};

--Contains all the used frames
local Polygon_UsedNoteFrames = {};

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

Polygon = {};



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

			--Loop through upper and lower to get the polygon artifacts out, should not change any performance but the code is longer.
			for i = 1, table.getn(hull) do
				local PointB;
				if(hull[i+1]) then
					PointB = hull[i+1];
				else
					PointB = center;
				end
				--Polygon:debug_Print(upper[i], PointB, center);
				local f = Polygon:DrawPolygon(hull[i], PointB, center,r,g,b);
				table.insert(ReturnFrames, f);
			end

			local f = Polygon:DrawPolygon(hull[1],hull[table.getn(hull)],center,r,g,b);
			table.insert(ReturnFrames, f);
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
local HBD = LibStub("HereBeDragonsQuestie-2.0")
function Polygon:CalcHotzones(points, rangeR, count)
	print("calc1")
    if(points == nil) then return nil; end

    --If count isn't set we want to distance clustering to still work,
    --to simplify the logic we just use a big number.
    if not count then
      count = 99999;
    end

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
                            times = 100
                        end
                        local aX, aY = HBD:GetWorldCoordinatesFromZone(
                                            point.x / times, point.y / times,
                                            point.UiMapID)
                        local bX, bY = HBD:GetWorldCoordinatesFromZone(
                                            point2.x / times, point2.y / times,
                                            point2.UiMapID)
                        -- local dX = (point.x*times) - (point2.x*times)
                        -- local dY = (point.y*times) - (point2.y*times);
                        local distance =
                            QuestieLib:Euclid(aX or 0, aY or 0, bX or 0, bY or 0)
                        if (distance < range and point2.touched == nil) then
                            point2.touched = true
                            tinsert(notes, point2)
                        end
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

--DEBUG CODE!
function Polygon_SlashHandler(msgbase)
	print("test")
	if(msgbase=="test") then
		--local Points = {}
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
		--p2.x = 1;
		--p2.y = 0;
		--local p3 = {};
		--p3.x = 0.5;
		--p3.y = 0.5;
--
		--table.insert(Points, p1);
		--table.insert(Points, p2);
		--table.insert(Points, p3);
		----Polygon:DrawPolygon(p1,p2,p3);
--
		--Polygon:CLEAR_ALL_NOTES();
		--Polygon:DrawPointList(Points,0,1,0);
		

		--ff:SetWidth(16);
		--ff:SetHeight(16);
		----t:SetAllPoints(f);
		--ff:SetPoint("TOPLEFT",(hull[i].x*WorldMapFrame:GetCanvas():GetWidth()),(-hull[i].y*WorldMapFrame:GetCanvas():GetHeight())+8)
		--t:SetAllPoints(ff);

		local mask = UIParent:CreateMaskTexture()
		mask:SetTexture(QuestieLib.AddonPath.."Icons\\triangletgablacknoedge", "CLAMPTOBLACK", "CLAMPTOBLACK")
		mask:SetSize(128, 128)
		mask:SetPoint("CENTER", 0, 0);

		local mask2 = UIParent:CreateMaskTexture()
		mask2:SetTexture(QuestieLib.AddonPath.."Icons\\triangletgablacknoedge", "CLAMPTOWHITE", "CLAMPTOWHITE")
		mask2:SetSize(128, 128)
		mask2:SetPoint("CENTER", 50, 0);

		local mask3 = UIParent:CreateMaskTexture()
		mask3:SetTexture(QuestieLib.AddonPath.."Icons\\triangletgablacknoedge", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask3:SetSize(128, 128)
		mask3:SetPoint("CENTER", 80, 0);

		local mask4 = UIParent:CreateMaskTexture()
		mask4:SetTexture(QuestieLib.AddonPath.."Icons\\triangletgablacknoedge", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask4:SetSize(128, 128)
		mask4:SetPoint("CENTER", 100, 0);
		
		local texture = UIParent:CreateTexture(nil, "ARTWORK")
		texture:SetColorTexture(0, 1, 1, 0.5)
		texture:SetSize(2000, 2000)
		texture:SetPoint("TOPLEFT")
		texture:AddMaskTexture(mask)
		texture:AddMaskTexture(mask2)
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

			return texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
		end
	end

	-- Removes one-pixel transparent border
	local BORDER_OFFSET = -1 / 512
	local BORDER_SCALE = 512 / 510
	local TRIANGLE_PATH = QuestieLib.AddonPath.."Icons\\triangletga";

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
		local width, height = windowX*WorldMapFrame:GetCanvas():GetWidth(), windowY*WorldMapFrame:GetCanvas():GetHeight();
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
