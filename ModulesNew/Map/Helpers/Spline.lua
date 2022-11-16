
---@class Spline
local Spline = QuestieLoader:CreateModule("Spline")

local function CatmullRom_CalculatePointOnCurveHelper(t, tSquared, tCubed, p1, p2, p3, p4)
	local term1 = 2.0 * p2 + (p3 - p1) * t;
	local term2 = (2.0 * p1 - 5.0 * p2 + 4.0 * p3 - p4) * tSquared;
	local term3 = (3.0 * p2 - p1 - 3.0 * p3 + p4) * tCubed;

	return 0.5 * (term1 + term2 + term3);
end

-- function CatmullRom_CalculatePointOnCurve(t, p1, p2, p3, p4)
-- 	local tSquared = t * t;
-- 	local tCubed = tSquared * t;
-- 	return CatmullRom_CalculatePointOnCurveHelper(t, tSquared, tCubed, p1, p2, p3, p4);
-- end

function CatmullRom_Calculate2DPointOnCurve(t, p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y)
	local tSquared = t * t;
	local tCubed = tSquared * t;
	return
		CatmullRom_CalculatePointOnCurveHelper(t, tSquared, tCubed, p1x, p2x, p3x, p4x),
		CatmullRom_CalculatePointOnCurveHelper(t, tSquared, tCubed, p1y, p2y, p3y, p4y);
end

-- function CatmullRom_Calculate3DPointOnCurve(t, p1x, p1y, p1z, p2x, p2y, p2z, p3x, p3y, p3z, p4x, p4y, p4z)
-- 	local tSquared = t * t;
-- 	local tCubed = tSquared * t;
-- 	return
-- 		CatmullRom_CalculatePointOnCurveHelper(t, tSquared, tCubed, p1x, p2x, p3x, p4x),
-- 		CatmullRom_CalculatePointOnCurveHelper(t, tSquared, tCubed, p1y, p2y, p3y, p4y),
-- 		CatmullRom_CalculatePointOnCurveHelper(t, tSquared, tCubed, p1z, p2z, p3z, p4z);
-- end

-- function CatmullRom_Calculate4DPointOnCurve(t, p1x, p1y, p1z, p1w, p2x, p2y, p2z, p2w, p3x, p3y, p3z, p3w, p4x, p4y, p4z, p4w)
-- 	local tSquared = t * t;
-- 	local tCubed = tSquared * t;
-- 	return
-- 		CatmullRom_CalculatePointOnCurveHelper(t, tSquared, tCubed, p1x, p2x, p3x, p4x),
-- 		CatmullRom_CalculatePointOnCurveHelper(t, tSquared, tCubed, p1y, p2y, p3y, p4y),
-- 		CatmullRom_CalculatePointOnCurveHelper(t, tSquared, tCubed, p1z, p2z, p3z, p4z),
-- 		CatmullRom_CalculatePointOnCurveHelper(t, tSquared, tCubed, p1w, p2w, p3w, p4w);
-- end

local CatmullRomSplineMixinQuestie = {};

function Spline:CreateCatmullRomSpline(numDimensions)
	local spline = CreateFromMixins(CatmullRomSplineMixinQuestie);
	spline:OnLoad(numDimensions)
	return spline;
end

function CatmullRomSplineMixinQuestie:OnLoad(numDimensions)
	-- if numDimensions == 1 then
    --     self.calculateFunction = CatmullRom_CalculatePointOnCurve;
	if numDimensions == 2 then
		self.calculateFunction = CatmullRom_Calculate2DPointOnCurve;
	-- elseif numDimensions == 3 then
	-- 	self.calculateFunction = CatmullRom_Calculate3DPointOnCurve;
	-- elseif numDimensions == 4 then
	-- 	self.calculateFunction = CatmullRom_Calculate4DPointOnCurve;
	else
		-- In the interest of performance, limiting number of dimensions
		error("Unsupported number of dimensions");
	end

	self.numDimensions = numDimensions;
	self:ClearPoints();
end

function CatmullRomSplineMixinQuestie:GetNumDimensions()
	return self.numDimensions;
end

local function AddPointHelper(pointData, startIndex, ...)
	local pointIndex = 1;
	for i = startIndex, startIndex + select("#", ...) do
		pointData[i] = select(pointIndex, ...);
		pointIndex = pointIndex + 1;
	end
end

function CatmullRomSplineMixinQuestie:AddPoint(...)
    --? This is removed for performance reasons
	-- assert(select("#", ...) == self.numDimensions);


	if #self.pointData == 0 then
		-- If first point, put it in the list three times times to simplify the curve calculation, at this time the curve represents a single point
		AddPointHelper(self.pointData, 1, ...);
		AddPointHelper(self.pointData, 1 + self.numDimensions, ...);
		AddPointHelper(self.pointData, 1 + self.numDimensions * 2, ...);
	else
		-- For each other point, add it to the end twice but replacing the last one that was added twice
		AddPointHelper(self.pointData, #self.pointData - self.numDimensions + 1, ...);
		AddPointHelper(self.pointData, #self.pointData + 1, ...);
	end

	self.numPoints = self.numPoints + 1;
end

function CatmullRomSplineMixinQuestie:GetPoint(pointIndex)
	if pointIndex > 0 and pointIndex <= self:GetNumPoints() then
		return unpack(self.pointData, (pointIndex + 1) * self.numDimensions + 1, (pointIndex + 2) * self.numDimensions);
	end
end

function CatmullRomSplineMixinQuestie:GetNumPoints()
	return self.numPoints;
end

function CatmullRomSplineMixinQuestie:ClearPoints()
	self.numPoints = 0;
	self.pointData = {};
end

function CatmullRomSplineMixinQuestie:CalculatePointOnGlobalCurve(t)
	local startSegmentIndex, localT = self:FindSegmentOnGlobalCurve(t);
	if startSegmentIndex then
		return self:CalculatePointOnLocalCurveSegment(startSegmentIndex, localT);
	end
end

function CatmullRomSplineMixinQuestie:CalculatePointOnLocalCurveSegment(startSegmentIndex, t)
	return self.calculateFunction(t, unpack(self.pointData, (startSegmentIndex - 2) * self.numDimensions + 1, (startSegmentIndex + 2) * self.numDimensions));
end

function CatmullRomSplineMixinQuestie:FindSegmentOnGlobalCurve(t)
	local numPoints = self:GetNumPoints();
	if numPoints > 1 then
		local numSegments = numPoints - 1;
		local segment = numSegments * t;
		local segmentIndex = Clamp(math.floor(segment), 0, numSegments - 1) + 2;
		return segmentIndex, PercentageBetween(segment + 2, segmentIndex, segmentIndex + 1);
	end
end
