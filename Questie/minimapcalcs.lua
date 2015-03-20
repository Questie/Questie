----- mapnotes stuffs


-- Do NOT Localise any names in this array --

MapNotes_MiniConst = {};
MapNotes_MiniConst[1] = {};
MapNotes_MiniConst[2] = {};
MapNotes_MiniConst = {
	[1] = {
		[0] = {
			["xscale"] = 11016.6,
			["yscale"] = 7399.9,
		},
		[1] = {
			["xscale"] = 12897.3,
			["yscale"] = 8638.1,
		},
		[2] = {
			["xscale"] = 15478.8,
			["yscale"] = 10368.0,
		},
		[3] = {
			["xscale"] = 19321.8,
			["yscale"] = 12992.7,
		},
		[4] = {
			["xscale"] = 25650.4,
			["yscale"] = 17253.2,
		},
		[5] = {
			["xscale"] = 38787.7,
			["yscale"] = 26032.1,
		}
	},
	[2] = {
		[0] = {
			["xscale"] = 10448.3,
			["yscale"] = 7072.7,
		},
		[1] = {
			["xscale"] = 12160.5,
			["yscale"] = 8197.8,
		},
		[2] = {
			["xscale"] = 14703.1,
			["yscale"] = 9825.0,
		},
		[3] = {
			["xscale"] = 18568.7,
			["yscale"] = 12472.2,
		},
		[4] = {
			["xscale"] = 24390.3,
			["yscale"] = 15628.5,
		},
		[5] = {
			["xscale"] = 37012.2,
			["yscale"] = 25130.6,
		}
	},
	[3] = {
		[0] = {
			["xscale"] = 10448.3,
			["yscale"] = 7072.7,
		},
		[1] = {
			["xscale"] = 12160.5,
			["yscale"] = 8197.8,
		},
		[2] = {
			["xscale"] = 14703.1,
			["yscale"] = 9825.0,
		},
		[3] = {
			["xscale"] = 18568.7,
			["yscale"] = 12472.2,
		},
		[4] = {
			["xscale"] = 24390.3,
			["yscale"] = 15628.5,
		},
		[5] = {
			["xscale"] = 37012.2,
			["yscale"] = 25130.6,
		}
	},
};

MAPNOTES_DEFAULT_MINIDATA = {
			["scale"] = 0.15,
			["xoffset"] = 0.4,
			["yoffset"] = 0.4,
};


----- end mapnotes







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
	DEFAULT_CHAT_FRAME:AddMessage(zone)
	DEFAULT_CHAT_FRAME:AddMessage(r.xoffset)
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

function getMinimapPosFromCoord(coord_x, coord_y, zone)
	local cont = GetCurrentMapContinent(); -- hax (eastern kingdoms)
	local currentZoom = Minimap:GetZoom();
	local MapNotes_MiniNote_IsInCity = false; -- hax
	local xscale,yscale;
	local x, y = Questie:getPlayerPos();
	local currentConst = QuestieRegionScale[zone];
	if currentConst == nil then
		return 0, 0, 0;
	end
	if cont > 0 then
		xscale = MapNotes_MiniConst[cont][currentZoom].xscale;
		yscale = MapNotes_MiniConst[cont][currentZoom].yscale;
	else
		xscale = MapNotes_MiniConst[2][currentZoom].xscale;
		yscale = MapNotes_MiniConst[2][currentZoom].yscale;
	end

	if MapNotes_MiniNote_IsInCity then
		xscale = xscale * MapNotes_CityConst[currentZoom].cityscale;
		yscale = yscale * MapNotes_CityConst[currentZoom].cityscale;
	end

	local xpos = coord_x * currentConst.scale + currentConst.xoffset; --abscoord
	local ypos = coord_y * currentConst.scale + currentConst.yoffset; --abscoord

	x = x * currentConst.scale + currentConst.xoffset;--abscoord(player)
	y = y * currentConst.scale + currentConst.yoffset;--abscoord

	local deltax = (xpos - x) * xscale;
	local deltay = (ypos - y) * yscale;
	if sqrt( (deltax * deltax) + (deltay * deltay) ) > 57 then
		local adjust = 1;
		if deltax == 0 then
			deltax = deltax + 0.0000000001;
		elseif deltax < 0 then
			adjust = -1;
		end
		local m = math.atan(deltay / deltax);
		deltax = math.cos(m) * 58 * adjust;
		deltay = math.sin(m) * 58 * adjust;
	end

	--!!!>  MiniNotePOI:SetPoint("CENTER", "MinimapCluster", "TOPLEFT", 105 + deltax, -93 - deltay);

	--DEFAULT_CHAT_FRAME:AddMessage("GMFRMC " .. zone)
	--log(zone)
	
	--local px, py = Questie:getPlayerPos();
	--local absplayerx, absplayery = QGatherer_AbsCoord(zone, px, py)
	--local abstargx, abstargy = QGatherer_AbsCoord(zone, x, y)
	--abstargy = math.floor(abstargy * 100000)/100000;
	--local zoomLevel = Minimap:GetZoom()
	----local deltax, deltay = Gatherer_Distance(absplayerx, absplayery, abstargx, abstargy);
	--local scalex, scaley = QGatherer_GetMapScale(GetCurrentMapContinent(), false, zoomLevel);
	--local deltax = (abstargx - absplayerx) * scalex; --(xpos - x) * xscale;
	--local deltay = (abstargy - absplayery) * scaley;
	--local offsX, offsY, gDist = Gatherer_MiniMapPos(deltax, deltay, scalex, scaley);
	--return offsX, offsY, gDist;
	return deltax, deltay, 0;
end