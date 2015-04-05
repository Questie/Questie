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
	if not TomTom.db.profile.arrow.lock then
		self:StartMoving()
	end
end

local function OnDragStop(self, button)
	self:StopMovingOrSizing()
end

local function OnEvent(self, event, ...)
	if event == "ZONE_CHANGED_NEW_AREA" and TomTom.profile.arrow.enable then
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

function SetCrazyArrow(uid, dist, title)
	active_point = uid
	arrive_distance = dist
	point_title = title 

	if self.profile.arrow.enable then
		wayframe.title:SetText(title or "Unknown waypoint")
		wayframe:Show()
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

local function OnUpdate(self, elapsed)
	if not active_point then
		self:Hide()
		return
	end

	local dist,x,y = GetDistanceToIcon(active_point)

	-- The only time we cannot calculate the distance is when the waypoint
	-- is on another continent, or we are in an instance
	if not dist or IsInInstance() then
		if not TomTom:IsValidWaypoint(active_point) then
			active_point = nil
			-- Change the crazy arrow to point at the closest waypoint
			if TomTom.profile.arrow.setclosest then
				TomTom:SetClosestWaypoint()
				return
			end
		end

		self:Hide()
		return
	end

	status:SetText(sformat(L["%d yards"], dist))

	local cell

	-- Showing the arrival arrow?
	if dist <= arrive_distance then
		if not showDownArrow then
			arrow:SetHeight(70)
			arrow:SetWidth(53)
			arrow:SetTexture("Interface\\AddOns\\Questie\\Images\\Arrow-UP")
			arrow:SetVertexColor(unpack(TomTom.db.profile.arrow.goodcolor))
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
		local player = GetPlayerFacing()

		angle = angle - player

		local perc = math.abs((math.pi - math.abs(angle)) / math.pi)

		local gr,gg,gb = unpack(TomTom.db.profile.arrow.goodcolor)
		local mr,mg,mb = unpack(TomTom.db.profile.arrow.middlecolor)
		local br,bg,bb = unpack(TomTom.db.profile.arrow.badcolor)
		local r,g,b = ColorGradient(perc, br, bg, bb, mr, mg, mb, gr, gg, gb)		
		arrow:SetVertexColor(r,g,b)

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
			tta:SetFormattedText("%01d:%02d", eta / 60, Questie:modulo(eta, 60)) 
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

local texcoords = setmetatable({}, {__index = function(t, k)
	--[[ this was k:match - so we need string.match, but that's not in Lua 5.0?
	local fIndex, lIndex = string.find(k, "(%d+):(%d+)")
	local col,row = string.sub(k, fIndex, lIndex)]]
	local col,row = string.find(k, "(%d+):(%d+)")
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
			--[[ Create a data feed for coordinates
			local feed_crazy = ldb:NewDataObject("TomTom_CrazyArrow", {
				type = "data source",
				icon = "Interface\\Addons\\TomTom\\Images\\Arrow",
				text = "Crazy",
				iconR = 1,
				iconG = 1,
				iconB = 1,
				iconCoords = {0, 1, 0, 1},
				OnTooltipShow = function(tooltip)
					local dist = TomTom:GetDistanceToWaypoint(active_point)
					if dist then
						tooltip:AddLine(point_title or L["Unknown waypoint"])
						tooltip:AddLine(sformat(L["%d yards"], dist), 1, 1, 1)
					end
				end,
				OnClick = WayFrame_OnClick,
			})]]

			local crazyFeedFrame = CreateFrame("Frame")
			local throttle = 1
			local counter = 0

			--[[function TomTom:UpdateArrowFeedThrottle()
				throttle = TomTom.db.profile.feeds.arrow_throttle
			end]]

			crazyFeedFrame:SetScript("OnUpdate", function(self, elapsed)
				elapsed = 0.01666667
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

function GetDirectionToIcon( icon )
	--[[local data = self.MinimapIcons[icon];
	if ( data ) then
		local dir = atan2(data.xDist, -(data.yDist))
		if ( dir > 0 ) then
			return twoPi - dir;
		else
			return -dir;
		end
	end]]
	return 50
end

function GetDistanceToIcon( icon )
	local data = self.MinimapIcons[icon];
	if ( data ) then
		return data.dist, data.xDist, data.yDist;
	end
end
