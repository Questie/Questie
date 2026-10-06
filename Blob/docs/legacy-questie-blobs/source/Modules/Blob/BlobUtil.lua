-------------------------
--Import modules.
-------------------------
---@type Blob
local Blob = QuestieLoader:ImportModule("Blob");

---@class BlobUtil
Blob.util = {}

local tInsert = table.insert


-- Calculates the signed area
local function signedArea(p, q, r)
    local cross = (q.y - p.y) * (r.x - q.x)
                - (q.x - p.x) * (r.y - q.y)
    return cross
  end

-- Checks if points p, q, r are oriented counter-clockwise
function Blob.util:isCCW(p, q, r) return signedArea(p, q, r) < 0 end

-- Checks if points p, q, r are oriented counter-clockwise
function Blob.util:intersects(A, B, C, D)
    return Blob.util:isCCW(A,C,D) ~= Blob.util:isCCW(B,C,D) and Blob.util:isCCW(A,B,C) ~= Blob.util:isCCW(A,B,D)
end

-- Returns the convex hull using Jarvis' Gift wrapping algorithm).
-- It expects an array of points as input. Each point is defined
-- as : {x = <value>, y = <value>}.
-- See : http://en.wikipedia.org/wiki/Gift_wrapping_algorithm
-- points  : an array of points
-- returns : the convex hull as an array of points
function Blob.util:jarvis_march(points)
  -- We need at least 3 points
  local numPoints = #points
  if numPoints < 3 then return end

  --Lets just look it up once instead of multiple times!
  local isCCWFunc = Blob.util.isCCW

  -- Find the left-most point
  local leftMostPointIndex = 1
  for i = 1, numPoints do
    if points[i].x < points[leftMostPointIndex].x then
      leftMostPointIndex = i
    end
  end

  local p = leftMostPointIndex
  local hull = {} -- The convex hull to be returned
  local indexesPartOfHull = {}
  local maxCount = 2000;
  local count = 0;
  -- Process CCW from the left-most point to the start point
  repeat
    -- Find the next point q such that (p, i, q) is CCW for all i
    local q = points[p + 1] and p + 1 or 1
    for i = 1, numPoints, 1 do
      if isCCWFunc(self, points[p], points[i], points[q]) then q = i end
    end

	tInsert(hull, points[q]) -- Save q to the hull
	tInsert(indexesPartOfHull, q); -- To be able to fetch "non-hull" points we save the indexes part of the hull
	p = q  -- p is now q for the next iteration
	count = count + 1
  until (p == leftMostPointIndex or count > maxCount) --Added a counter to exit if it runs to long
  return hull, indexesPartOfHull
end

---comment
---@param points table
---@param areaCutoff number @OPTIONAL: A cutoff
---@return integer @Combined Area WARNING IF USING CUTOFF DOES NOT CONTAIN THE FULL AREA!!!
---@return boolean @Outside of the cutoff i.e big enough!
function Blob.util:CalculateArea(points, areaCutoff)
    --Calculate the Area of the polygon and throw away ones that are too small
    local combinedArea = 0
    local midPoint = Blob.util:CenterPoint(points)
    local mX, mY = midPoint.x, midPoint.y
    for index, Point in pairs(points) do
        local pX, pY = Point.x, Point.y
        local Point2 = points[index+1]
        if(Point2) then
            local p2X, p2Y = Point2.x, Point2.y
            local area = (pX*(p2Y - mY)+p2X*(mY - pY)+mX*(pY-p2Y))/2
            combinedArea = combinedArea + area
            --print(area)
        else
            Point2 = points[1]
            local p2X, p2Y = Point2.x, Point2.y
            local area = (pX*(p2Y - mY)+p2X*(mY - pY)+mX*(pY-p2Y))/2
            combinedArea = combinedArea + area
            --print(area)
        end
        --If the area is bigger than the cutoff, no need to continue
        if(areaCutoff and combinedArea > areaCutoff) then
			--print("area big enough, stopping")
			return combinedArea, true
        end
	end
	return combinedArea, false
end

function Blob.util:GetMinMaxRect(points)
	local minX, maxX, minY, maxY = {x=99999999,y=99999999}, {x=0,y=0}, {x=99999999,y=99999999}, {x=0,y=0}
	-- Find Xmin, Xmax, Ymin, Ymax
	for i = 1, #points do
		if points[i].x < minX.x then
			minX.x = points[i].x
			minX.y = points[i].y
		end
		if points[i].x > maxX.x then
			maxX.x = points[i].x
			maxX.y = points[i].y
		end
		if points[i].y < minY.y then
			minY.x = points[i].x
			minY.y = points[i].y
		end
		if points[i].y > maxY.y then
			maxY.x = points[i].x
			maxY.y = points[i].y
		end
	end

	return minX, maxX, minY, maxY
end

-- https://www.researchgate.net/figure/Time-performance-s-of-Jarvis-march-and-Graham-scan-algorithms-versus-the-proposed_tbl1_340636304
function Blob.util:PreprocessHull(points)
	-- This could probably be improved by returning this on another loop functions rather than doing it once a again.
	-- for example when we do the clustering
	local minX, maxX, minY, maxY = Blob.util:GetMinMaxRect(points)

	--lets just lookup once
	local insidePolygon = Blob.util.insidePolygon

	--	Insert the coords into the polygon
	local polygon = {} --minX, maxX, minY, maxY
	tInsert(polygon, minX)
	tInsert(polygon, maxX)
	tInsert(polygon, minY)
	tInsert(polygon, maxY)

	local filteredPoints = {}
	local removedPoints = {}
	-- Check which points are outside of the polygon
	local inside=nil --I don't know if it saves time / speed to have this defined here, but lets just say it does.
	for i = 1, #points do
		inside = insidePolygon(self, polygon, points[i])
		if (not inside) then
			tInsert(filteredPoints, points[i]);
		else
			tInsert(removedPoints, points[i]);
		end
	end

	return filteredPoints, removedPoints;
end

function Blob.util:CenterPoint(points)
    local center = {x=0, y=0}
    local count = 0
    for index, point in pairs(points) do
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
---@param points table<number, Point> @Pointlist {x=0, y=0}
---@return Point @{x=?, y=?}
function Blob.util:AbsCenterPoint(points)
    --Localize the functions
    local min, max = math.min, math.max
    local minX = 99999999999
    local minY = 99999999999
    local maxX = 0
    local maxY = 0
    for _, point in pairs(points) do
        minX = min(minX, point.x);
        minY = min(minY, point.y);
        maxX = max(maxX, point.x);
        maxY = max(maxY, point.y);
    end
    --local fCenterX = minX + ((maxX - minX)/2)--local fCenterY = minY + ((maxY - minY)/2)
    return {x=minX + ((maxX - minX)/2), y=minY + ((maxY - minY)/2)}
end

---UNTESTED
---@param points table<number, Point> @Pointlist {x=0, y=0}
---@return Point @{x=?, y=?}
function Blob.util:AvgAbsCenterPoint(points)
    --Localize the functions
    local min, max = math.min, math.max
    --Avg
    local avgCenter = {x=0, y=0}
    local count = 0
    --Abs
    local minX = 99999999999
    local minY = 99999999999
    local maxX = 0
    local maxY = 0
    for _, point in pairs(points) do
        --Avg
        avgCenter.x = avgCenter.x + point.x
        avgCenter.y = avgCenter.y + point.y
        count = count + 1
        --Abs
        minX = min(minX, point.x);
        minY = min(minY, point.y);
        maxX = max(maxX, point.x);
        maxY = max(maxY, point.y);
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


function Blob.util:PolygonCentroid(points)
	--https://stackoverflow.com/questions/2792443/finding-the-centroid-of-a-polygon
	local centroid = {x=0, y=0};
    local signedArea = 0;
    local x0 = 0; -- Current vertex X
    local y0 = 0; -- Current vertex Y
    local x1 = 0; -- Next vertex X
    local y1 = 0; -- Next vertex Y
    local a = 0;  -- Partial signed area
	if(not points) then return {x=nil, y=nil} end
	if(#points == 0) then return {x=nil, y=nil} end

	-- For all vertices except last
	for i = 1, (#points-1) do
		x0 = points[i].x;
        y0 = points[i].y;
        x1 = points[i+1].x;
        y1 = points[i+1].y;
        a = x0*y1 - x1*y0;
        signedArea = signedArea + a;
        centroid.x = centroid.x + (x0 + x1)*a;
        centroid.y = centroid.y + (y0 + y1)*a;
	end

    -- Do last vertex separately to avoid performing an expensive
	-- modulus operation in each iteration.
    x0 = points[#points].x;
    y0 = points[#points].y;
    x1 = points[1].x;
    y1 = points[1].y;
    a = x0*y1 - x1*y0;
	signedArea = signedArea + a;
	centroid.x = centroid.x + (x0 + x1)*a;
	centroid.y = centroid.y + (y0 + y1)*a;

    --signedArea = signedArea * 0.5;
    --centroid.x = centroid.x / (6.0*signedArea);
	--centroid.y = centroid.y / (6.0*signedArea);
	--Shouldn't just times 3 be the same?
	if(signedArea ~= 0) then
		centroid.x = centroid.x / (3*signedArea);
		centroid.y = centroid.y / (3*signedArea);
	else
		centroid.x = nil;
		centroid.y = nil;
	end

    return centroid;
end

--General function
---@param polygon table<number, Point> @A table with the outside points
---@param point Point
---@return boolean @Inside or not, true or false
function Blob.util:insidePolygon(polygon, point)
    local oddNodes = false
    local j = #polygon
    for i = 1, #polygon do
        if (polygon[i].y < point.y and polygon[j].y >= point.y or polygon[j].y < point.y and polygon[i].y >= point.y) then
            if (polygon[i].x + ( point.y - polygon[i].y ) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < point.x) then
                oddNodes = not oddNodes;
            end
        end
        j = i;
    end
    return oddNodes
end

--Mouse specific function
local WMF = WorldMapFrame;
---@param polygon table<number, Point> @A table with the outside points
---@return boolean @Inside or not, true or false
function Blob.util:insidePolygonMouse(polygon)
    local x, y = WMF.ScrollContainer:GetNormalizedCursorPosition()
    local point = {x=x, y=y}
    --is it 0-100 or 0-1
    if(polygon[1].x > 1 or polygon[1].y > 1) then
        point = {x=x*100, y=y*100}
    end
    return Blob.util:insidePolygon(polygon, point);
end
-- Bezier
-- https://github.com/nshafer/Bezier

-- The MIT License (MIT)

-- Copyright (c) 2013 Nathan Shafer

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

Blob.util.Bezier = {}

function Blob.util.Bezier:init()
	self.points = {}
	self.autoStepScale = .1
end

function Blob.util.Bezier:getPoints()
	return self.points
end

function Blob.util.Bezier:setPoints(points)
	self.points = points
end

function Blob.util.Bezier:setAutoStepScale(scale)
	self.autoStepScale = scale
end

function Blob.util.Bezier:getAutoStepScale()
	return self.autoStepScale
end

function Blob.util.Bezier:pointDistance(p1, p2)
	local dx = p2.x - p1.x
	local dy = p2.y - p1.y
	return math.sqrt(dx*dx + dy*dy)
end

function Blob.util.Bezier:getLength()
	local length = 0
	local last = nil

	for i,point in ipairs(self.points) do
		if last then
			length = length + self:pointDistance(point, last)
		end
		last = point
	end

	return(length)
end

function Blob.util.Bezier:draw(isClosed)
	self:beginPath()

	for i,point in ipairs(self.points) do
		self:lineTo(point.x, point.y)
	end

	if isClosed then self:closePath() end

	self:endPath()
end

-- Estimate number of steps based on the distance between each point/control
-- Inspired by http://antigrain.com/research/adaptive_bezier/
function Blob.util.Bezier:estimateSteps(p1, p2, p3, p4)
	local distance = 0
	if p1 and p2 then
		distance = distance + self:pointDistance(p1, p2)
	end
	if p2 and p3 then
		distance = distance + self:pointDistance(p2, p3)
	end
	if p3 and p4 then
		distance = distance + self:pointDistance(p3, p4)
	end

	return math.max(1, math.floor(distance * self.autoStepScale))
end

-- Bezier functions from Paul Bourke
-- http://paulbourke.net/geometry/bezier/
function Blob.util.Bezier:createQuadraticCurve(p1, p2, p3, steps)
	self.points = {}
	steps = steps or self:estimateSteps(p1, p2, p3)
	for i = 0, steps do
		tInsert(self.points, self:bezier3(p1, p2, p3, i/steps))
	end
end

function Blob.util.Bezier:createCubicCurve(p1, p2, p3, p4, steps)
	self.points = {}
	steps = steps or self:estimateSteps(p1, p2, p3, p4)
	for i = 0, steps do
		tInsert(self.points, self:bezier4(p1, p2, p3, p4, i/steps))
	end
end

function Blob.util.Bezier:bezier3(p1,p2,p3,mu)
	local mum1,mum12,mu2
	local p = {}
	mu2 = mu * mu
	mum1 = 1 - mu
	mum12 = mum1 * mum1
	p.x = p1.x * mum12 + 2 * p2.x * mum1 * mu + p3.x * mu2
	p.y = p1.y * mum12 + 2 * p2.y * mum1 * mu + p3.y * mu2
	--p.z = p1.z * mum12 + 2 * p2.z * mum1 * mu + p3.z * mu2
	
	return p
end

function Blob.util.Bezier:bezier4(p1,p2,p3,p4,mu)
	local mum1,mum13,mu3;
	local p = {}

	mum1 = 1 - mu
	mum13 = mum1 * mum1 * mum1
	mu3 = mu * mu * mu

	p.x = mum13*p1.x + 3*mu*mum1*mum1*p2.x + 3*mu*mu*mum1*p3.x + mu3*p4.x
	p.y = mum13*p1.y + 3*mu*mum1*mum1*p2.y + 3*mu*mu*mum1*p3.y + mu3*p4.y
	--p.z = mum13*p1.z + 3*mu*mum1*mum1*p2.z + 3*mu*mu*mum1*p3.z + mu3*p4.z

	return p	
end

-- Reduce nodes based on Ramer-Douglas-Peucker algorithm
-- http://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm
-- Additional help from http://quangnle.wordpress.com/2012/12/30/corona-sdk-curve-fitting-1-implementation-of-ramer-douglas-peucker-algorithm-to-reduce-points-of-a-curve/
function Blob.util.Bezier:reduce(epsilon)
	epsilon = epsilon or .1

	if #self.points > 1 then
		-- Keep first and last
		self.points[1].keep = true
		self.points[#self.points].keep = true

		-- Figure out the rest
		self:douglasPeucker(1, #self.points, epsilon)
	end

	-- Replace point list with only those that are marked to keep
	local old = self.points
	self.points = {}

	for i,point in ipairs(old) do
		if point.keep then
			tInsert(self.points, {x=point.x, y=point.y})
		end
	end
end

function Blob.util.Bezier:douglasPeucker(first, last, epsilon)
	local dmax = 0
	local index = 0

	for i=first+1, last-1 do
		local d = self:pointLineDistance(self.points[i], self.points[first], self.points[last])

		if d > dmax then
			index = i
			dmax = d
		end
	end

	if dmax >= epsilon then
		self.points[index].keep = true

		-- Recursive call
		self:douglasPeucker(first, index, epsilon)
		self:douglasPeucker(index, last, epsilon)
	end
end

function Blob.util.Bezier:pointLineDistance(p, a, b)
	-- calculates area of the triangle
	local area = math.abs(0.5 * (a.x * b.y + b.x * p.y + p.x * a.y - b.x * a.y - p.x * b.y - a.x * p.y))
	-- calculates the length of the bottom edge
	local dx = a.x - b.x
	local dy = a.y - b.y
	local bottom = math.sqrt(dx*dx + dy*dy)
	-- the triangle's height is also the distance found
	return area / bottom
end