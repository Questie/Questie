--[[--------------------------------------------------------------------------
--  TomTom - A navigational assistant for World of Warcraft
-- 
--  CrazyTaxi: A crazy-taxi style arrow used for waypoint navigation.
--    concept taken from MapNotes2 (Thanks to Mery for the idea, along
--    with the artwork.)
----------------------------------------------------------------------------]]

math.modf = function(number)
	local fractional = Questie:modulo(number, 1)
	local integral = number - fractional
	return integral, fractional
end

function GetPlayerFacing()
        local p = Minimap
        local m = ({p:GetChildren()})[9]
        return m:GetFacing()
end

local sformat = string.format

local function ColorGradient(perc, tablee)
	local num = table.getn(tablee)
	local hexes = tablee[1] == "string"

	if perc == 1 then
		return tablee[num-2], tablee[num-1], tablee[num]
	end

	num = num / 3

	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2
	r1, g1, b1 = tablee[(segment*3)+1], tablee[(segment*3)+2], tablee[(segment*3)+3]
	r2, g2, b2 = tablee[(segment*3)+4], tablee[(segment*3)+5], tablee[(segment*3)+6]

	if not r2 or not g2 or not b2 then
		return r1, g1, b1
	else
		return r1 + (r2-r1)*relperc,
		g1 + (g2-g1)*relperc,
		b1 + (b2-b1)*relperc
	end
end

local twopi = math.pi * 2

local wayframe = CreateFrame("Button", "TomTomCrazyArrow", UIParent)
wayframe:SetHeight(42)
wayframe:SetWidth(56)
wayframe:SetPoint("CENTER", 0, 0)
wayframe:EnableMouse(true)
wayframe:SetMovable(true)
wayframe:Hide()

-- Frame used to control the scaling of the title and friends
local titleframe = CreateFrame("Frame", nil, wayframe)

wayframe.title = titleframe:CreateFontString("OVERLAY", nil, "GameFontHighlightSmall")
wayframe.status = titleframe:CreateFontString("OVERLAY", nil, "GameFontNormalSmall")
wayframe.tta = titleframe:CreateFontString("OVERLAY", nil, "GameFontNormalSmall")
wayframe.title:SetPoint("TOP", wayframe, "BOTTOM", 0, 0)
wayframe.status:SetPoint("TOP", wayframe.title, "BOTTOM", 0, 0)
wayframe.tta:SetPoint("TOP", wayframe.status, "BOTTOM", 0, 0)

local function OnDragStart(self, button)
	this:StartMoving()
end

local function OnDragStop(self, button)
	this:StopMovingOrSizing()
end

local function OnEvent(self, event, ...)
	if event == "ZONE_CHANGED_NEW_AREA" then
		self:Show()
	end
end

wayframe:SetScript("OnDragStart", OnDragStart)
wayframe:SetScript("OnDragStop", OnDragStop)
wayframe:RegisterForDrag("LeftButton")
wayframe:RegisterEvent("ZONE_CHANGED_NEW_AREA")
wayframe:SetScript("OnEvent", OnEvent)

wayframe.arrow = wayframe:CreateTexture("OVERLAY")
wayframe.arrow:SetTexture("Interface\\AddOns\\Questie\\Images\\Arrow")
wayframe.arrow:SetAllPoints()

local active_point, arrive_distance, showDownArrow, point_title

function SetCrazyArrow(point, dist, title)
	local isHide = false;
	if not (active_point == nil) then -- bad logic is bad
		if active_point.x == point.x and active_point.y == point.y then
			isHide = true;
		end
	end --srsly
	
	active_point = point
	arrive_distance = dist
	point_title = title

	if active_point and not isHide then
		wayframe.title:SetText(point_title or "Unknown waypoint")
		wayframe:Show()
	else
		active_point = nil; -- important
		wayframe:Hide()
	end
end

local status = wayframe.status
local tta = wayframe.tta
local arrow = wayframe.arrow
local count = 0
local last_distance = 0
local tta_throttle = 0
local speed = 0
local speed_count = 0

HACK_DUMP = 0;

local function OnUpdate(self, elapsed)
	self = this
	elapsed = 1/GetFramerate()
	if not active_point then
		self:Hide()
		return
	end

	local dist,x,y = GetDistanceToIcon(active_point)
	-- The only time we cannot calculate the distance is when the waypoint
	-- is on another continent, or we are in an instance
	if not dist or IsInInstance() then
		if not active_point.x and not active_point.y then
			active_point = nil
		end

		self:Hide()
		return
	end

	status:SetText(sformat("%d yards", dist))

	local cell

	-- Showing the arrival arrow?
	if dist <= arrive_distance then
		if not showDownArrow then
			arrow:SetHeight(70)
			arrow:SetWidth(53)
			arrow:SetTexture("Interface\\AddOns\\Questie\\Images\\Arrow-UP")
			arrow:SetVertexColor(1, 1, 1)
			showDownArrow = true
		end

		count = count + 1
		if count >= 55 then
			count = 0
		end

		cell = count
		local column = Questie:modulo(cell, 9)
		local row = floor(cell / 9)

		local xstart = (column * 53) / 512
		local ystart = (row * 70) / 512
		local xend = ((column + 1) * 53) / 512
		local yend = ((row + 1) * 70) / 512
		arrow:SetTexCoord(xstart,xend,ystart,yend)
	else
		if showDownArrow then
			arrow:SetHeight(56)
			arrow:SetWidth(42)
			arrow:SetTexture("Interface\\AddOns\\TomTom\\Images\\Arrow")
			showDownArrow = false
		end

		local angle = GetDirectionToIcon(active_point)
		angle = math.rad(angle);
		local player = GetPlayerFacing()

		angle = player - angle

		local perc = math.abs((math.pi - math.abs(angle)) / math.pi)
		
		angle = math.rad(-math.deg(angle)-180);

		local gr,gg,gb = 1, 1, 1
		local mr,mg,mb = 0.75, 0.75, 0.75
		local br,bg,bb = 0.5, 0.5, 0.5
		local tablee = {};
		table.insert(tablee, gr)
		table.insert(tablee, gg)
		table.insert(tablee, gb)
		table.insert(tablee, mr)
		table.insert(tablee, mg)
		table.insert(tablee, mb)
		table.insert(tablee, br)
		table.insert(tablee, bg)
		table.insert(tablee, bb)
				
		local r,g,b = ColorGradient(perc,tablee)	
		if not g then 
			g = 0;
		end	
		arrow:SetVertexColor(1-g,-1+g*2,0)

		cell = Questie:modulo(floor(angle / twopi * 108 + 0.5), 108);
		local column = Questie:modulo(cell, 9)
		local row = floor(cell / 9)

		local xstart = (column * 56) / 512
		local ystart = (row * 42) / 512
		local xend = ((column + 1) * 56) / 512
		local yend = ((row + 1) * 42) / 512
		arrow:SetTexCoord(xstart,xend,ystart,yend)
	end

	-- Calculate the TTA every second  (%01d:%02d)

	tta_throttle = tta_throttle + elapsed

	if tta_throttle >= 1.0 then
		-- Calculate the speed in yards per sec at which we're moving
		local current_speed = (last_distance - dist) / tta_throttle

		if last_distance == 0 then
			current_speed = 0
		end

		if speed_count < 2 then
			speed = (speed + current_speed) / 2
			speed_count = speed_count + 1
		else
			speed_count = 0
			speed = current_speed
		end

		if speed > 0 then
			local eta = math.abs(dist / speed)
			local text = string.format("%01d:%02d", eta / 60, Questie:modulo(eta, 60))
			tta:SetText(text) 
		else
			tta:SetText("***")
		end
		
		last_distance = dist
		tta_throttle = 0
	end
end

function ShowHideCrazyArrow()
	if true then
		wayframe:Show()

		if true then
			wayframe:EnableMouse(false)
		else
			wayframe:EnableMouse(true)
		end

		-- Set the scale and alpha
		wayframe:SetScale(1)
		wayframe:SetAlpha(1)
		local width = 80
		local height = 80
		local scale = 1

		wayframe.title:SetWidth(width)
		wayframe.title:SetHeight(height)
		titleframe:SetScale(scale)
		titleframe:SetAlpha(1)

		if true then
			tta:Show()
		else
			tta:Hide()
		end
	else
		wayframe:Hide()
	end
end

wayframe:SetScript("OnUpdate", OnUpdate)

wayframe:RegisterForClicks("RightButtonUp")
wayframe:SetScript("OnClick", WayFrame_OnClick)

local function getCoords(column, row)
	local xstart = (column * 56) / 512
	local ystart = (row * 42) / 512
	local xend = ((column + 1) * 56) / 512
	local yend = ((row + 1) * 42) / 512
	return xstart, xend, ystart, yend
end

--this is where texcoords are extracted incorrectly (I think), leading the arrow to not point in the correct direction
local texcoords = setmetatable({}, {__index = function(t, k)
	-- this was k:match("(%d+):(%d+)") - so we need string.match, but that's not in Lua 5.0
	
	local fIndex, lIndex = string.find(k, "(%d+)")
	local col = string.sub(k, fIndex, lIndex)
	fIndex2, lIndex2 = string.find(k, ":(%d+)")
	local row = string.sub(k, fIndex2+1, lIndex2)
--	DEFAULT_CHAT_FRAME:AddMessage(k)
	col,row = tonumber(col), tonumber(row)
	local obj = {getCoords(col, row)}
	rawset(t, k, obj)
	return obj
end})

wayframe:RegisterEvent("ADDON_LOADED")
wayframe:SetScript("OnEvent", function(self, event, arg1, ...)
	if true then
		if true then
			local feed_crazy = CreateFrame("Frame")
			local crazyFeedFrame = CreateFrame("Frame")
			local throttle = 1
			local counter = 0

			crazyFeedFrame:SetScript("OnUpdate", function(self, elapsed)
				elapsed = 1/GetFramerate()
				counter = counter + elapsed
				if counter < throttle then
					return
				end

				counter = 0

				local angle = GetDirectionToIcon(active_point)
				local player = GetPlayerFacing()
				if not angle or not player then
					feed_crazy.iconCoords = texcoords["1:1"]
					feed_crazy.iconR = 0.2
					feed_crazy.iconG = 1.0
					feed_crazy.iconB = 0.2
					feed_crazy.text = "No waypoint"
					return
				end

				angle = angle - player

				local perc = math.abs((math.pi - math.abs(angle)) / math.pi)

				local gr,gg,gb = 1, 1, 1
				local mr,mg,mb = 0.75, 0.75, 0.75
				local br,bg,bb = 0.5, 0.5, 0.5
				local tablee = {};
				table.insert(tablee, gr)
				table.insert(tablee, gg)
				table.insert(tablee, gb)
				table.insert(tablee, mr)
				table.insert(tablee, mg)
				table.insert(tablee, mb)
				table.insert(tablee, br)
				table.insert(tablee, bg)
				table.insert(tablee, bb)
				
				
				local r,g,b = ColorGradient(perc, tablee)		
				feed_crazy.iconR = r
				feed_crazy.iconG = g
				feed_crazy.iconB = b

				cell = Questie:modulo(floor(angle / twopi * 108 + 0.5) ,108)
				local column = Questie:modulo(cell, 9)
				local row = floor(cell / 9)

				local key = column .. ":" .. row
				feed_crazy.iconCoords = texcoords[key]
				feed_crazy.text = point_title or "Unknown waypoint"
			end)
		end
	end
end)


--- more astrolabe code
function ComputeDistance( qzid, x1, y1, x2, y2 )
	z1 = z1 or 0;
	z2 = z2 or 0;
	
	local dist, xDelta, yDelta;
	
	local zscale = QuestieRegionScale[qzid];
	

	xDelta = (x2 - x1) * zscale.width;
	yDelta = (y2 - y1) * zscale.height;
	
	if ( xDelta and yDelta ) then
		dist = sqrt(xDelta*xDelta + yDelta*yDelta);
	end
	return dist, xDelta, yDelta;
end

-- this is a function used by Astrolabe (which we should ONLY be using in the future)
-- it doesn't work for our current coords system
-- so move everything over to Astrolabe, which is FAR superior to our own system anyway!
-- the problem could also be with GetPlayerFacing()
function GetDirectionToIcon( point )
	if not point then return end
	--GetCurrentMapContinent()
	--Astrolabe:ComputeDistance( c1, z1, x1, y1, c2, z2, x2, y2 )
	
	local dist, xDelta, yDelta = ComputeDistance(point.zoneID, point.x, point.y, Questie.player_x,  Questie.player_y);
	
	--local xDist = point.x - Questie.player_x;
	--local yDist = point.y - Questie.player_y;
	
	-- atan(y2-y1/x2-x1) = radiant between 2 
	
	local dir = atan2(xDelta, -(yDelta))
	if ( dir > 0 ) then
		return twopi - dir;
	else
		return -dir;
	end
end


--[[

-- there are more functions in TomTom affecting the arrow that need to be somehow implemented, I think
-- maybe a switch to Astrolabe entirely, first, would sort out a lot of issues (with distance calculation and such too)

local square_half = math.sqrt(0.5)
local rad_135 = math.rad(135)

local function rotateArrow(self)
	if self.disabled then return end

	local angle = Astrolabe:GetDirectionToIcon(self)
	if not angle then return self:Hide() end
	angle = angle + rad_135

	if GetCVar("rotateMinimap") == "1" then
		--local cring = MiniMapCompassRing:GetFacing()
        local cring = GetPlayerFacing()
		angle = angle - cring
	end

	local sin,cos = math.sin(angle) * square_half, math.cos(angle) * square_half
	self.arrow:SetTexCoord(0.5-sin, 0.5+cos, 0.5+cos, 0.5+sin, 0.5-cos, 0.5-sin, 0.5+sin, 0.5-cos)
end]]

function GetDistanceToIcon( point )
	return Questie:getPlayerFormatDistTo(point.x, point.y)
end
