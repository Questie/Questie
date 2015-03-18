function Gatherer_Pythag(dx, dy)
	local d = math.sqrt(dx*dx + dy*dy); -- (a*a) is usually computationally faster than math.pow(a,2)
	if (d == 0) then d = 0.0000000001; end -- to avoid divide by zero errors.
	return d;
end

function Gatherer_Distance(originX, originY, targetX, targetY)
	local dx = (targetX - originX);
	local dy = (targetY - originY);
	local d = Gatherer_Pythag(dx, dy);
	return d, dx, dy;
end

function QGatherer_GetMapScale(continent, inCity, zoomLevel) -- changed for questie
	if (zoomLevel == nil) then return 0,0; end
	if ((not GatherRegionData) or 
	(not GatherRegionData[continent]) or 
	(not GatherRegionData[continent].scales) or 
	(not GatherRegionData[continent].scales[zoomLevel]) or 
	(not GatherRegionData[continent].scales[zoomLevel].xscale) or
	(not GatherRegionData[continent].scales[zoomLevel].yscale)) then
		return 0,0;
	end

	local scaleX = GatherRegionData[continent].scales[zoomLevel].xscale;
	local scaleY = GatherRegionData[continent].scales[zoomLevel].yscale;
	if (inCity == true) then
		local cityScale = GatherRegionData.cityZoom[zoomLevel];
		scaleX = scaleX * cityScale;
		scaleY = scaleY * cityScale;
	end
	
	return scaleX, scaleY;
end

function Gatherer_GetMapScale(continent, zone, inCity, zoomLevel)
	if ((continent == nil) or (zoomLevel == nil)) then return 0,0; end
	if ((not GatherRegionData) or 
	(not GatherRegionData[continent]) or 
	(not GatherRegionData[continent].scales) or 
	(not GatherRegionData[continent].scales[zoomLevel]) or 
	(not GatherRegionData[continent].scales[zoomLevel].xscale) or
	(not GatherRegionData[continent].scales[zoomLevel].yscale)) then
		return 0,0;
	end

	local scaleX = GatherRegionData[continent].scales[zoomLevel].xscale;
	local scaleY = GatherRegionData[continent].scales[zoomLevel].yscale;
	if (inCity == true) then
		local cityScale = GatherRegionData.cityZoom[zoomLevel];
		scaleX = scaleX * cityScale;
		scaleY = scaleY * cityScale;
	end
	
	return scaleX, scaleY;
end

function QGatherer_AbsCoord(zone, x, y) -- changed to use questie zone id
	if (zone == 0) then return x, y; end
	local r = QuestieRegionScale[zone];
	log(zone)
	log(r.xoffset)
	local absX = x * r.scale + r.xoffset;
	local absY = y * r.scale + r.yoffset;
	return absX, absY;
end

function Gatherer_AbsCoord(continent, zone, x, y)
	if ((continent == 0) or (zone == 0)) then return x, y; end
	local r = GatherRegionData[continent][zone];
	local absX = x * r.scale + r.xoffset;
	local absY = y * r.scale + r.yoffset;
	return absX, absY;
end

function Gatherer_MiniMapPos(deltaX, deltaY, scaleX, scaleY) -- works out the distance on the minimap
	local mapX = deltaX * scaleX;
	local mapY = deltaY * scaleY;
	local mapDist = 0;

	mapDist = Gatherer_Pythag(mapX, mapY);

	if (mapDist >= 57) then
		-- Remap it to just inside the minimap, by:converting dx,dy to angle,distance 
		-- then truncate distance to 58 and convert angle,58 to dx,dy
		local flipAxis = 1;
		if (mapX == 0) then mapX = 0.0000000001;
		elseif (mapX < 0) then flipAxis = -1;
		end
		local angle = math.atan(mapY / mapX);
		mapX = math.cos(angle) * 58 * flipAxis;
		mapY = math.sin(angle) * 58 * flipAxis;
	end
	return mapX, mapY, mapDist;
end
