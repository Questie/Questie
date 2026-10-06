-- Contains library functions that do not have a logical place.
---@class Blob
---@param util BlobUtil
local Blob = QuestieLoader:CreateModule("Blob")



---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

Blob.DrawData = {}

---@type SplineMixin
local SplineLib = CreateCatmullRomSpline(2);

local math_abs = math.abs
local math_sqrt = math.sqrt
local tInsert = table.insert
local function Euclid(x, y, i, e)
    local xd = math_abs(x - i)
    local yd = math_abs(y - e)
    return math_sqrt(xd * xd + yd * yd)
end
local function EuclidSquared(x, y, i, e)
    local xd = math_abs(x - i)
    local yd = math_abs(y - e)
    return xd * xd + yd * yd
end
local WorldMapFrame = WorldMapFrame;


local HBD = LibStub("HereBeDragonsQuestie-2.0")

local function updateMaskTexture()
    print("updateMaskTexture ran")
    Blob.minimapMask:ClearAllPoints();
    Blob.minimapMask:SetAllPoints(Minimap)
    Blob.minimapMask:SetTexture(MinimapMaskTexture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
end

Blob.minimapMask = Minimap:CreateMaskTexture()
Blob.playerMask = Minimap:CreateMaskTexture()
local timer;
local count = 0;
timer = C_Timer.NewTicker(0.5, function()
    if(count > 10) then --60 seconds
        MinimapMaskTexture = QuestieLib.AddonPath.."Icons\\circlemask";
    end
    if(MinimapMaskTexture) then
        --Blob.minimapMask:ClearAllPoints();
        --Blob.minimapMask:SetAllPoints(Minimap)
        --Blob.minimapMask:SetTexture(MinimapMaskTexture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
        updateMaskTexture()
        --print(QuestieLib.AddonPath.."Icons\\playermask")
        Blob.playerMask:SetTexture(QuestieLib.AddonPath.."Icons\\playermask", "CLAMP", "CLAMP", "NEAREST")
        Blob.playerMask:SetParent(Minimap)
        Blob.playerMask:SetPoint("CENTER", 0, 0)
        Blob.playerMask:SetSize(38,38)
        timer:Cancel();
        timer = nil
        print("Got a minimap texture", MinimapMaskTexture)

        --local f = CreateFrame("Frame")
        --f:SetPoint("CENTER")
        --f:SetSize(32, 32)

        --f.tex = f:CreateTexture(nil, "ARTWORK")
        --f.tex:SetAllPoints(f)
        --f.tex:SetTexture(MinimapMaskTexture)
        --f.tex:SetColorTexture(0, 0, 0, 0.5) -- black, 50% opacity
    end
    count = count + 1
end)

--Hook the minimap.SetMaskTexture
local BlizzSetMaskTexture = Minimap.SetMaskTexture
MinimapMaskTexture = nil
local function SetMaskTexture(...)
  print("Something called the SetMaskTexture for the minimap", unpack({...}))
  MinimapMaskTexture = select("2", ...)
  updateMaskTexture()
  BlizzSetMaskTexture(...)
end

Minimap.SetMaskTexture = SetMaskTexture

local function drawLine(parentFrame, sX, sY, eX, eY, Linedata, framePosX, framePosY, maskTextures)
    --local lineTexture
    --if(not maskTexture and true == false) then
    --    lineTexture = Blob.LinePool:Acquire()
    --    local width, height = WorldMapFrame:GetCanvas():GetSize();
    --    local startX = sX * width
    --    local startY = sY * height -- We do by / -100 due to using the top left point
    --    local endX = eX * width
    --    local endY = eY * height
    --    lineTexture.color = {r=Linedata.r or 1, g=Linedata.g or 0, b=Linedata.b or 0, a=Linedata.a or 0.6}
    --    lineTexture:SetParent(parentFrame)
    --    lineTexture:SetColorTexture(lineTexture.color.r, lineTexture.color.g, lineTexture.color.b, lineTexture.color.a)
    --    --lineTexture:SetColorTexture(math.random(), math.random(), math.random(), 0.5)
    --    lineTexture:SetStartPoint("TOPLEFT",startX-framePosX, -(startY-framePosY))
    --    lineTexture:SetEndPoint("TOPLEFT",endX-framePosX,-(endY-framePosY))
    --    --lineTexture:SetFrameLevel(5000);
    --    lineTexture:SetThickness(lineTexture.thickness);
    --    lineTexture:SetTexCoord(0,1,0,1)
    --    --lineTexture:AddMaskTexture(maskTexture)
    --end

    local lineTexture = Blob.LinePool:Acquire();
    lineTexture:SetParent(parentFrame)
    local width, height = WorldMapFrame:GetCanvas():GetSize();
    local startX = sX * width
    local startY = sY * height -- We do by / -100 due to using the top left point
    local endX = eX * width
    local endY = eY * height
    --Due to thickness being used in linemixin we instead just use defaultThickness
    lineTexture.defaultThickness = Linedata.thickness or 1.5;
    lineTexture.color = {r=Linedata.r or 1, g=Linedata.g or 0, b=Linedata.b or 0, a=Linedata.a or 0.6}
    if(maskTextures) then
        for _, maskTexture in pairs(maskTextures) do
            lineTexture:AddMaskTexture(maskTexture)
            tInsert(lineTexture.maskTextures, maskTexture)
        end
    end
    lineTexture:SetVertexColor(lineTexture.color.r, lineTexture.color.g, lineTexture.color.b, lineTexture.color.a)
    lineTexture:SetStartPoint(startX-framePosX, -(startY-framePosY))
    lineTexture:SetEndPoint(endX-framePosX, -(endY-framePosY))
    lineTexture:SetThickness(lineTexture.defaultThickness);
    lineTexture:Show();
    --lineTexture:Redraw();
    --lineTexture.redraw = function() 
    --    lineTexture:SetVertexColor(lineTexture.color.r, lineTexture.color.g, lineTexture.color.b, lineTexture.color.a)
    --    lineTexture.drawlinefunction(lineTexture, parentFrame, startX-framePosX, -(startY-framePosY), endX-framePosX, -(endY-framePosY), lineTexture.thickness, 1, "TOPLEFT")
    --end
    lineTexture.redraw(lineTexture)
    --lineTexture:Draw();
    return lineTexture
end

--totalPointsBefore = 0;
--totalPointsAfterJarv = 0
--totalPointsAfterBeizer = 0;
--Maybe local this func

---comment
---@param Points any
---@return table @Points
function Blob:CalcSpine(Points)
    local pPerDist = 0.7 --1 (Nicer looking with 0.5) but more performant with 0.7
    local pStep = 1
    local pReduce = 0.03--0.05 (Nicer looking with 0.03)
    --print("CalcSpline")
    --Reset
    SplineLib:ClearPoints()

    --print(#Points)

    -- First we preprocess the points, remove all "Internal" points to speed up the jarvis_march
    local filteredPoints, removedPoints = Blob.util:PreprocessHull(Points)
    --print(#filteredPoints)
    local hull = Blob.util:jarvis_march(filteredPoints)
    --print(#hull)
    if(hull == nil) then
        return {};
    end

    --We add the last and first point to the list extra times to make the curve smoother
    --local totalDistance = 0;
    --local previousX, previousY = hull[1].x, hull[1].y;
    SplineLib:AddPoint(hull[#hull].x, hull[#hull].y);
    for i = 1, table.getn(hull) do
        --local distance = Euclid(previousX, previousY, hull[i].x, hull[i].y);
        --if(distance > 0.000001) then  
        SplineLib:AddPoint(hull[i].x, hull[i].y);
        --previousX = hull[i].x
        --previousY = hull[i].y
        --end
        --totalDistance = totalDistance + distance
    end
    SplineLib:AddPoint(hull[1].x, hull[1].y);

    --The new splined hull
    local newHull = {}


    --Number of points per distance
    --local distanceIt = 1/(totalDistance / pPerDist)
    --local minDist = 0.1
    --local last = nil;
    --for i = 0, 1, distanceIt do
    --    local x, y = SplineLib:CalculatePointOnGlobalCurve(i);
    --    local point = {x=x, y=y}
    --    --If the points are too close to eachother the drawing starts to overlap.
    --    if(not last or Euclid(last.x, last.y, x, y) > minDist) then
    --        tInsert(newHull, point);
    --        last = point
    --    end
    --end
    
    --print("-----")
    --print("Hull", #hull)
    --It's absolute percentage 0-1
    local percentageBetweenPoints = 0.10
    for i = 2, SplineLib:GetNumPoints() do
        for subPoint = 1, math.floor(1/percentageBetweenPoints) do
            --print(subPoint*percentageBetweenPoints)
            --It should never be 0 or 1, but due to us starting on 1 we only need to check for 1
            if(subPoint*percentageBetweenPoints ~= 1) then
                local x, y = SplineLib:CalculatePointOnLocalCurveSegment(i, subPoint*percentageBetweenPoints)
                local point = {x=x, y=y}
                tInsert(newHull, point);
            end
        end
    end

	--if numPoints > 1 then
	--	local segment = numSegments * t;
	--	local segmentIndex = Clamp(math.floor(segment), 0, numSegments - 1) + 2;
	--	return segmentIndex, PercentageBetween(segment + 2, segmentIndex, segmentIndex + 1);
	--end


    --totalPointsBefore = totalPointsBefore + #newHull;
    --print("BeforeJarv:"..(#newHull))
    --We run jarvis_march one more time to get rid of potential "loopty loops" created by the spline
    newHull = Blob.util:jarvis_march(newHull);
    --print("AfterJarv:"..(#newHull))
    --totalPointsAfterJarv = totalPointsAfterJarv + #newHull;
    if(newHull == nil) then
        return {};
    end
    --print("newHull", #newHull)
    Blob.util.Bezier:init();
    Blob.util.Bezier:setPoints(newHull)
    --Blob.util.Bezier:setAutoStepScale(1)
    Blob.util.Bezier:reduce(pReduce)
    --print("AfterBezier:"..(#Blob.util.Bezier:getPoints()))
    --totalPointsAfterBeizer = totalPointsAfterBeizer + (#Blob.util.Bezier:getPoints())
    --print("Bezier", #Blob.util.Bezier:getPoints())
    --local retPoints = Blob.util.Bezier:getPoints()

    --Calculate the Area of the polygon and throw away ones that are too small
    --Function is in BlobUtil, we could remove this
    --local areaCutoff = 0.9
    --local combinedArea = 0
    --local midPoint = Blob.util:CenterPoint(retPoints)
    --local mX, mY = midPoint.x, midPoint.y
    --for index, Point in pairs(retPoints) do
    --    local pX, pY = Point.x, Point.y
    --    local Point2 = retPoints[index+1]
    --    if(Point2) then
    --        local p2X, p2Y = Point2.x, Point2.y
    --        local area = (pX*(p2Y - mY)+p2X*(mY - pY)+mX*(pY-p2Y))/2
    --        combinedArea = combinedArea + area
    --        --print(area)
    --    else
    --        Point2 = retPoints[1]
    --        local p2X, p2Y = Point2.x, Point2.y
    --        local area = (pX*(p2Y - mY)+p2X*(mY - pY)+mX*(pY-p2Y))/2
    --        combinedArea = combinedArea + area
    --        --print(area)
    --    end
    --    --If the area is bigger than the cutoff, no need to continue
    --    if(combinedArea > areaCutoff) then
    --        --print("area big enough, stopping")
    --        break
    --    end
    --end
    
    --Reset
    SplineLib:ClearPoints()
    return Blob.util.Bezier:getPoints()--newHull;
end

--Look into BlobMapPin to see overridable functions
---@param UiMapID integer @Optional if omitted not added to drawData for maps
---@param Points Point[] @point = {x=?, y=?}
---@param TexData table @r, g, b, a colors
---@param LineData table @r, g, b, a colors AND thickness
---@param overrideFunctions function[] @overideable functions, check BlobMap.lua for what ones work
---@return table
function Blob:AddBlob(UiMapID, Points, TexData, LineData, overrideFunctions)
    return Blob:AddBlobRaw(UiMapID, Blob:CalcSpine(Points), TexData, LineData, overrideFunctions)
end

---No processing is run on the points in this function
---@param UiMapID integer @Optional if omitted not added to drawData for maps
---@param Points Point[] @point = {x=?, y=?}
---@param TexData table @r, g, b, a colors
---@param LineData table @r, g, b, a colors AND thickness
---@param overrideFunctions function[] @overideable functions, check BlobMap.lua for what ones work
---@return table
function Blob:AddBlobRaw(UiMapID, Points, TexData, LineData, overrideFunctions)
    --print("AddBlob")
    -- Create table if missing
    if(UiMapID and Blob.DrawData[UiMapID] == nil) then
        Blob.DrawData[UiMapID] = {}
    end
    local drawData = {}
    --Set the color
    drawData.texData = TexData;
    drawData.lineData = LineData;
    drawData.UiMapID = UiMapID;
    drawData.pinTemplate = Blob.worldPinTemplate
    drawData.overrideFunctions = overrideFunctions;
    --Calculate the spline points and cache
    drawData.points = Points;
    if(drawData.points ~= nil and #drawData.points > 2) then
        if(UiMapID) then
            Blob.DrawData[UiMapID][drawData] = drawData;
        end
        return drawData;
    else
        --We need atleast 4 points to draw a blob, skip!
        return nil;
    end
end

--Look into BlobMapPin to see overridable functions
---@param UiMapID integer @Optional if omitted not added to drawData for maps
---@param Points Point[] @point = {x=?, y=?}
---@param TexData table @r, g, b, a colors
---@param LineData table @r, g, b, a colors AND thickness
---@param overrideFunctions function[] @overideable functions, check BlobMap.lua for what ones work
---@return table
function Blob:AddMinimapBlob(UiMapID, Points, TexData, LineData, overrideFunctions)
    return Blob:AddMinimapBlobRaw(UiMapID, Blob:CalcSpine(Points), TexData, LineData, overrideFunctions)
end

---No processing is run on the points in this function
---@param UiMapID integer @Optional if omitted not added to drawData for maps
---@param Points Point[] @point = {x=?, y=?}
---@param TexData table @r, g, b, a colors
---@param LineData table @r, g, b, a colors AND thickness
---@param overrideFunctions function[] @overideable functions, check BlobMap.lua for what ones work
---@return table
function Blob:AddMinimapBlobRaw(UiMapID, Points, TexData, LineData, overrideFunctions)
    --print("AddBlob")
    -- Create table if missing
    --if(UiMapID and Blob.DrawData[UiMapID] == nil) then
    --    Blob.DrawData[UiMapID] = {}
    --end
    local drawData = {}
    --Set the color
    drawData.texData = TexData;
    drawData.lineData = LineData;
    drawData.UiMapID = UiMapID;
    drawData.pinTemplate = Blob.minimapPinTemplate
    drawData.overrideFunctions = overrideFunctions;
    --Calculate the spline points and cache
    drawData.points = Points;
    if(drawData.points ~= nil and #drawData.points > 2) then
        --if(UiMapID) then
        --    Blob.DrawData[UiMapID][drawData] = drawData;
        --end
        return drawData;
    else
        --We need atleast 4 points to draw a blob, skip!
        return nil;
    end
end

function Blob:RemoveBlob(drawData)
    if(Blob.DrawData[drawData.UiMapID] ~= nil) then
        Blob.DrawData[drawData.UiMapID][drawData] = nil;
    end
end

function Blob:RemoveAllBlobs()
    --Here we just remove everything wholesale!
    Blob.DrawData = {}
end

function Blob:DrawPointList(frame, drawData, maskTextures)
    --print("DrawPointList")
    --Loop through upper and lower to get the polygon artifacts out, should not change any performance but the code is longer.
    ---@type BlobIconFrame
    local blobFrame = frame;--BlobMapProvider:GetMap():AcquirePin(drawData.pinTemplate, 2000)
    blobFrame:Hide();
    blobFrame.drawData = drawData;
    blobFrame.UiMapID = drawData.UiMapID;
    blobFrame.overrideFunctions = drawData.overrideFunctions

    -- Used to build the framesize
    local minX = 99999999999999 -- A big number
    local minY = 99999999999999 -- A big number
    local maxX = 0 -- A Small number
    local maxY = 0 -- A Small number

    local center = Blob.util:CenterPoint(blobFrame.drawData.points);

    local splineHullCount = #blobFrame.drawData.points;
    for i = 1, splineHullCount, 2 do
        local PointA = blobFrame.drawData.points[i];
        local PointB;
        local PointC;
        if(blobFrame.drawData.points[i+1]) then
            PointB = blobFrame.drawData.points[i+1];
        else
            PointA = blobFrame.drawData.points[1];
            PointB = blobFrame.drawData.points[splineHullCount];
        end
        if(blobFrame.drawData.points[i+2]) then
            PointC = blobFrame.drawData.points[i+2];
        else
            PointC = blobFrame.drawData.points[splineHullCount];
        end

        --Depending on the end points we have to do this differently
        if(i == splineHullCount) then
            PointC = center;
        elseif(i + 2 > splineHullCount) then
            PointA = blobFrame.drawData.points[1]
            PointB = blobFrame.drawData.points[splineHullCount]
            PointC = blobFrame.drawData.points[splineHullCount-1]
        end
        local miX, miY, maX, maY = Blob:DrawSquare(blobFrame, PointA, PointB, PointC, center);
        minX = math.min(minX, miX);
        minY = math.min(minY, miY);
        maxX = math.max(maxX, maX);
        maxY = math.max(maxY, maY);

    end

    local windowX = maxX - minX
    local windowY = maxY - minY

    blobFrame.fCenterX = minX + ((maxX - minX)/2)
    blobFrame.fCenterY = minY + ((maxY - minY)/2)
    --print("bFrame:", blobFrame.fCenterX, blobFrame.fCenterY)

    -- The world frame has been assigned a local variable, we don't want to save this between runs because
    -- things like resolution and mapsize might change
    local width, height = WorldMapFrame:GetCanvas():GetSize();
    local framePosX, framePosY = minX*width, minY*height

    blobFrame:ClearAllPoints();
    blobFrame:SetParent(WorldMapFrame:GetCanvas())
    blobFrame:SetScale(1)

    --Due to minimap frames not really having the same functions, we pcall it... dirty
    --Todo REMOVE
    pcall(blobFrame.SetPosition, blobFrame, minX+(windowX/2), minY+(windowY/2));

    blobFrame:SetSize(windowX*width, windowY*height);
    local fWidth, fHeight = blobFrame:GetSize();

    --Minimap Stuff
    local x1, y1= HBD:GetWorldCoordinatesFromZone(0, 0, blobFrame.UiMapID)
    local x2, y2 = HBD:GetWorldCoordinatesFromZone(1, 1, blobFrame.UiMapID)
    local mapWidth = x1 - x2;


    local mSizeX, mSizeY = Minimap:GetSize()
    blobFrame.minimapScale = {}

    local worldWidth = windowX * mapWidth
    local numberOfMinimaps = worldWidth/(466 + 2/3)
    local frameWidth = numberOfMinimaps*mSizeX
    blobFrame.minimapScale["outdoor"] =  frameWidth/fWidth

    numberOfMinimaps = worldWidth/300
    frameWidth = numberOfMinimaps*mSizeX
    blobFrame.minimapScale["indoor"] =  frameWidth/fWidth
    --end Minimap stuff

    --Cache the divide
    center.x = center.x/100;
    center.y = center.y/100;
    blobFrame.center = center;
    for _, tex in pairs(blobFrame.textures) do

        if(tex.ULv.x ~= center.x and tex.ULv.y ~= center.y and tex.URv.x ~= center.x and tex.URv.y ~= center.y) then
            local line = drawLine(blobFrame, tex.ULv.x, tex.ULv.y, tex.URv.x, tex.URv.y, drawData.lineData, framePosX, framePosY, maskTextures)
            if(line) then
                tInsert(blobFrame.lines, line);
            end
        end
        if(tex.LRv.x ~= center.x and tex.LRv.y ~= center.y and tex.URv.x ~= center.x and tex.URv.y ~= center.y) then
            local line = drawLine(blobFrame, tex.URv.x, tex.URv.y, tex.LRv.x, tex.LRv.y, drawData.lineData, framePosX, framePosY, maskTextures)
            if(line) then
                tInsert(blobFrame.lines, line);
            end
        end

        tex:ClearAllPoints();
        tex:SetParent(blobFrame)
        tex:SetAllPoints();
        tex:SetPoint("CENTER");

        --Questie:Debug(DEBUG_SPAM, "tex.ULv X:", tex.ULv.x, "tex.Y:", tex.ULv.y)
        --Questie:Debug(DEBUG_SPAM, "tex.LLv X:", tex.LLv.x, "tex.Y:", tex.LLv.y)
        --Questie:Debug(DEBUG_SPAM, "tex.URv X:", tex.URv.x, "tex.Y:", tex.URv.y)
        --Questie:Debug(DEBUG_SPAM, "tex.LRv X:", tex.LRv.x, "tex.Y:", tex.LRv.y)

        local ULvx = tex.ULv.x*width - framePosX;
        local ULvy = tex.ULv.y*height - framePosY;
        local LLvx = tex.LLv.x*width - framePosX;
        local LLvy = tex.LLv.y*height - framePosY;
        local URvx = tex.URv.x*width - framePosX;
        local URvy = tex.URv.y*height - framePosY;
        local LRvx = tex.LRv.x*width - framePosX;
        local LRvy = tex.LRv.y*height - framePosY;

        --Questie:Debug(DEBUG_SPAM, "ULv X:", ULvx, "Y:", ULvy)
        --Questie:Debug(DEBUG_SPAM, "LLv X:", LLvx, "Y:", LLvy)
        --Questie:Debug(DEBUG_SPAM, "URv X:", URvx, "Y:", URvy)
        --Questie:Debug(DEBUG_SPAM, "LRv X:", LRvx, "Y:", LRvy)
        --Questie:Debug(DEBUG_SPAM, "FrameSize:", fWidth, ":", fHeight)
        tex:SetVertexOffset(UPPER_LEFT_VERTEX, ULvx, -(ULvy));
        tex:SetVertexOffset(LOWER_LEFT_VERTEX, LLvx, fHeight-LLvy);
        tex:SetVertexOffset(UPPER_RIGHT_VERTEX, -(fWidth-URvx), -(URvy));
        tex:SetVertexOffset(LOWER_RIGHT_VERTEX, -(fWidth-LRvx), fHeight-LRvy);
        tex:SetTexture(tex.selectedTexture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
        tex:SetTexCoord(tex.ULt.x, tex.ULt.y, tex.LLt.x, tex.LLt.y, tex.URt.x, tex.URt.y, tex.LRt.x, tex.LRt.y);
        --print(drawData.lineData.r, drawData.lineData.r, drawData.lineData.r, drawData.lineData.a or 0.3)
        tex:SetVertexColor(drawData.lineData.r, drawData.lineData.g, drawData.lineData.b, drawData.lineData.a or 0.3)
        --tex:SetVertexColor(math.random(), math.random(), math.random(), 0.5)
        if(maskTextures) then
            for _, maskTexture in pairs(maskTextures) do
                --print("Adding mask", maskTexture)
                tex:AddMaskTexture(maskTexture)
                tInsert(tex.maskTextures, maskTexture)
            end
        end
        tex:Show();
    end
    blobFrame:Show();
    return blobFrame;
end

---@param parentFrame BlobIconFrame
function Blob:DrawSquare(parentFrame, Point1, Point2, Point3, center)
    local ULp, URp, LRp;
    -- If we are upside down left and right is swapped!
    if(Blob.util:isCCW(Point1, Point2, Point3)) then
		ULp = Point3
        URp = Point2
        LRp = Point1
    else
		ULp = Point1
		URp = Point2
        LRp = Point3
    end

    --TexCoords
    local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy;
	ULx, ULy = 0,0---0.25,-0.25
	URx, URy = 1,0
	LLx, LLy = 0,1
	LRx, LRy = 1,1 -- X +=LEFT, -=RIGTH

    local ULvx = ULp.x;
	local ULvy = ULp.y;

	local LLvx = center.x;
	local LLvy = center.y;

	local URvx = URp.x;
	local URvy = URp.y;

	local LRvx = LRp.x;
    local LRvy = LRp.y;

    --Because we are shifting a texture we want to do this before we change any XY to get the smallest possible
    --framesize while still encompassing all the points!
    local minX = math.min((ULvx/100), (LLvx/100), (URvx/100), (LRvx/100));
    local minY = math.min((ULvy/100), (LLvy/100), (URvy/100), (LRvy/100));
    local maxX = math.max((ULvx/100), (LLvx/100), (URvx/100), (LRvx/100))
    local maxY = math.max((ULvy/100), (LLvy/100), (URvy/100), (LRvy/100))

    --Create the texture object that will be used by the frame and populated it with data.
    local tex = Blob.TexturePool:Acquire()
    tInsert(parentFrame.textures, tex);

    tex.selectedTexture = Blob.TexturePool.TEXTURE.path;
    tex.ULt = { x=ULx, y=ULy};
    tex.LLt = { x=LLx, y=LLy};
    tex.URt = { x=URx, y=URy};
    tex.LRt = { x=LRx, y=LRy};

    --The actual point on the map 0-1
    tex.ULv = { 
        x=ULvx/100,
        y=ULvy/100
    }
    tex.LLv = { 
        x=LLvx/100,
        y=LLvy/100
    }
    tex.URv = { 
        x=URvx/100,
        y=URvy/100
    }
    tex.LRv = {
        x=LRvx/100,
        y=LRvy/100
    }

    --tex.color = {r=r,g=g,b=b,a=a}

    --Return the size of the texture
    return minX, minY, maxX, maxY
end

--[[

function Blob:DrawTriangleOLD(parentFrame, texture, Point1, Point2, center, r, g, b)
	local ULp, URp;
	if(Point1.x < Point2.x) then
		ULp = Point1
		URp = Point2
	else
		ULp = Point2
		URp = Point1
	end
	local tex = parentFrame.TexturePool:Acquire()
	local width, height = WorldMapFrame:GetCanvas():GetSize();		--local tex = f:CreateTexture()
	--tex:SetAllPoints(f)
	--tex:SetTexture(QuestieLib.AddonPath.."Icons\\square", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST") --'interface/icons/ability_ambush'
	tex:SetTexture(texture, "CLAMPTOWHITE", "CLAMPTOWHITE", "NEAREST") --'interface/icons/ability_ambush'
	--tex:SetColorTexture(0, 1, 1, 0.5)
	tex:SetVertexColor(r or 0, g or 1, b or 1, 0.5)
	tex:SetSize(width, height)
	tex:SetPoint("CENTER")
	local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy;

	ULx, ULy = 0,0---0.25,-0.25
	URx, URy = 1,0
	LLx, LLy = 0,1
	LRx, LRy = 1,1 -- X +=LEFT, -=RIGTH

	local ULvx = (ULp.x/100)*width;
	local ULvy = -((ULp.y/100)*height);

	local LLvx = (center.x/100)*width;
	local LLvy = (1-(center.y/100))*height;

	local URvx = -((1-(URp.x/100))*width);
	local URvy = -((URp.y/100)*height);

	local LRvx = -((1-(center.x/100))*width);
    local LRvy = (1-(center.y/100))*height;

    local ULvx = ULp.x/100;
	local ULvy = -(ULp.y/100);

	local LLvx = center.x/100;
	local LLvy = 1-(center.y/100);

	local URvx = -(1-(URp.x/100));
	local URvy = -(URp.y/100);

	local LRvx = -(1-(center.x/100));
    local LRvy = 1-(center.y/100);

    local ULvx = ULp.x;
	local ULvy = ULp.y;

	local LLvx = center.x;
	local LLvy = center.y;

	local URvx = URp.x;
	local URvy = URp.y;

	local LRvx = center.x;
    local LRvy = center.y;

    ---@type Vector2D
    local rULv = CreateFromMixins(Vector2DMixin)
    ---@type Vector2D
    local rURv = CreateFromMixins(Vector2DMixin)
    local UI = ConvertPixelsToUI(128, WorldMapFrame:GetCanvas():GetScale())
    local yOffset = 0.01;
    if(Point1.x < Point2.x) then
		yOffset = -0.01
	else
		yOffset = 0.01
	end
    rULv:SetXY(0, yOffset)--yOffset*(512/height))
    rURv:SetXY(0, yOffset)--yOffset*(512/height))
    local angle = Vector2D_CalculateAngleBetween(ULvx, ULvy, URvx, URvy);
    local gradient = (URvy-ULvy) / (URvx-ULvx)
    local degrees = 1.57079633;
    if (gradient > 0) then
        degrees = 1.57079633;
    else
        degrees = -1.57079633;
    end
    rULv:RotateDirection(angle+degrees)
    rURv:RotateDirection(angle+degrees)
    --ULvx, ULvy = rULv.x+ULvx, rULv.y+ULvy
    --URvx, URvy = rURv.x+URvx, rURv.y+URvy

    --ULvx, ULvy = ULvx, ULvy;
    --URvx, URvy = URvx, URvy+yOffset

	--Questie:Debug(DEBUG_DEVELOP, "Old coords: ");
	--Questie:Debug(DEBUG_DEVELOP, "UL: ", ULvx ,  " : ",  ULvy);
	--Questie:Debug(DEBUG_DEVELOP, "LL: ", LLvx ,  " : ",  LLvy);
	--Questie:Debug(DEBUG_DEVELOP, "UR: ", URvx ,  " : ",  URvy);
	--Questie:Debug(DEBUG_DEVELOP, "LR: ", LRvx ,  " : ",  LRvy);

	tex:SetVertexOffset(UPPER_LEFT_VERTEX, ((ULvx/100)*width), -((((ULvy/100))*height)));
	tex:SetVertexOffset(LOWER_LEFT_VERTEX, (LLvx/100)*width, (1-((LLvy/100)))*height);
	tex:SetVertexOffset(UPPER_RIGHT_VERTEX, -(((1-((URvx/100)))*width)), -((((URvy/100))*height)));
	tex:SetVertexOffset(LOWER_RIGHT_VERTEX, -((1-((LRvx/100)))*width), (1-((LRvy/100)))*height);
	--	tex:SetVertTile(true)
	--	tex:SetHorizTile(true)
    tex:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
    tex:Show();
	local oULx,oULy,oLLx,oLLy,oURx,oURy,oLRx,oLRy = tex:GetTexCoord()
	--Questie:Debug(DEBUG_DEVELOP, "Old coords: ");
	--Questie:Debug(DEBUG_DEVELOP, "UL: ", oULx ,  " : ",  oULy);
	--Questie:Debug(DEBUG_DEVELOP, "LL: ", oLLx ,  " : ",  oLLy);
	--Questie:Debug(DEBUG_DEVELOP, "UR: ", oURx ,  " : ",  oURy);
    --Questie:Debug(DEBUG_DEVELOP, "LR: ", oLRx ,  " : ",  oLRy);
    return URp;
end


---@param parentFrame BlobIconFrame
function Blob:DrawTriangle2OLD(parentFrame, Point1, Point2, Point3, center, r, g, b, a)
    local ULp, URp, LRp;
    -- If we are upside down left and right is swapped!
    if(Blob.util:isCCW(Point1, Point2, Point3)) then
		ULp = Point3
        URp = Point2
        LRp = Point1
    else
		ULp = Point1
		URp = Point2
        LRp = Point3
    end
	local width, height = WorldMapFrame:GetCanvas():GetSize();		--local tex = f:CreateTexture()


    --TexCoords
    local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy;
	ULx, ULy = 0,0---0.25,-0.25
	URx, URy = 1,0
	LLx, LLy = 0,1
	LRx, LRy = 1,1 -- X +=LEFT, -=RIGTH

    local ULvx = ULp.x;
	local ULvy = ULp.y;

	local LLvx = center.x;
	local LLvy = center.y;

	local URvx = URp.x;
	local URvy = URp.y;

	local LRvx = LRp.x;
    local LRvy = LRp.y;

    local distance = Euclid(ULvx, ULvy, URvx, URvy)
    local straightTextureCutoff = 4;

    --Because we are shifting a texture we want to do this before we change any XY to get the smallest possible
    --framesize while still encompassing all the points!
    local minX = math.min((ULvx/100), (LLvx/100), (URvx/100), (LRvx/100));
    local minY = math.min((ULvy/100), (LLvy/100), (URvy/100), (LRvy/100));
    local maxX = math.max((ULvx/100), (LLvx/100), (URvx/100), (LRvx/100))
    local maxY = math.max((ULvy/100), (LLvy/100), (URvy/100), (LRvy/100))

    --Create the texture object that will be used by the frame and populated it with data.
    local tex = Blob.TexturePool:Acquire()
    tInsert(parentFrame.textures, tex);

    if(distance > straightTextureCutoff and false == true) then
        --Scale the texture to place a subregion of the texture on the point
        local scale = 1+Blob.TexturePool.TEXTURECURVE.offsetY/Blob.TexturePool.TEXTURECURVE.height

        ---@type Vector2D
        local C2 = CreateFromMixins(Vector2DMixin)
        C2:SetXY(center.x, center.y);
        ---@type Vector2D
        local P2 = CreateFromMixins(Vector2DMixin)
        P2:SetXY(ULvx, ULvy);
        P2:Subtract(C2);
        P2:ScaleBy(scale)
        P2:Add(C2);

        local P3 = CreateFromMixins(Vector2DMixin)
        P3:SetXY(URvx, URvy);
        P3:Subtract(C2);
        P3:ScaleBy(scale)
        P3:Add(C2);

        ULvx, ULvy = P2.x, P2.y
        URvx, URvy = P3.x, P3.y

        --Set TexCoords
        --The number 74 is the height of the curve
        tex.selectedTexture = Blob.TexturePool.TEXTURECURVE.path;
        tex.ULt = { x=ULx, y=ULy};
        tex.LLt = { x=LLx, y=LLy};
        tex.URt = { x=URx, y=URy-(Blob.TexturePool.TEXTURECURVE.texoffsetY/Blob.TexturePool.TEXTURECURVE.height)};
        tex.LRt = { x=LRx, y=LRy};
    else
        --Scale the texture to place a subregion of the texture on the point
        --local scale = 1+Blob.TexturePool.TEXTURE.offsetY/Blob.TexturePool.TEXTURE.height

        -----@type Vector2D
        --local C2 = CreateFromMixins(Vector2DMixin)
        --C2:SetXY(center.x, center.y);
        -----@type Vector2D
        --local P2 = CreateFromMixins(Vector2DMixin)
        --P2:SetXY(ULvx, ULvy);
        --P2:Subtract(C2);
        --P2:ScaleBy(scale)
        --P2:Add(C2);

        --local P3 = CreateFromMixins(Vector2DMixin)
        --P3:SetXY(URvx, URvy);
        --P3:Subtract(C2);
        --P3:ScaleBy(scale)
        --P3:Add(C2);

        --ULvx, ULvy = P2.x, P2.y
        --URvx, URvy = P3.x, P3.y

        --Set TexCoords
        --The number 74 is the height of the curve
        tex.selectedTexture = Blob.TexturePool.TEXTURE.path;
        tex.ULt = { x=ULx, y=ULy};
        tex.LLt = { x=LLx, y=LLy};
        tex.URt = { x=URx, y=URy};
        tex.LRt = { x=LRx, y=LRy};
    end

    --The actual point on the map 0-1
    tex.ULv = { 
        x=ULvx/100,
        y=ULvy/100
    }
    tex.LLv = { 
        x=LLvx/100,
        y=LLvy/100
    }
    tex.URv = { 
        x=URvx/100,
        y=URvy/100
    }
    tex.LRv = {
        x=LRvx/100,
        y=LRvy/100
    }

    tex.color = {r=r,g=g,b=b}

    --Return the size of the texture
    return minX, minY, maxX, maxY
end




]]--


local HBD = LibStub("HereBeDragonsQuestie-2.0")
local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")
local test = {}
function Blob_SlashHandler(msgbase)
    --https://wow.gamepedia.com/UIOBJECT_Texture

    --Texture:SetSnapToPixelGrid()
    --Texture:GetTexelSnappingBias()
    --Texture:SetTexelSnappingBias(texelSnappingBias) where texelSnappingBias is [0-1]

    --local f = CreateFrame("Frame", "LineFrameTest", UIParent)
    --f:SetPoint("CENTER")
    --f:SetSize(32, 32)
--
    --f.tex = f:CreateTexture(nil, "ARTWORK")
    ----f.tex:SetAllPoints(f)
    ----f.tex:SetSize(32, 32)
    ----f.tex:SetPoint("TOPLEFT", 0, 0)
    --f.tex:SetTexture(maskTex, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")--"Interface/Icons/Ability_Ambush")--maskTex)--
    --local mix = Mixin(f.tex, LineMixin)
    --mix:SetParent(f)
    --local fX, fY = f:GetLeft(), f:GetBottom()
    --mix:SetStartPoint(fX,fY)
    --mix:SetEndPoint(fX+6,fY+6)
    --mix:SetThickness(5)
    --mix:SetVertexColor(0,0,1,0.5)
    --local parent = f;
	--local x, y = parent:GetLeft(), parent:GetBottom();
--
	----mix:ClearAllPoints();
    ----DrawLine(mix, parent, mix.startX - x, mix.startY - y, mix.endX - x, mix.endY - y, mix.thickness or 32, 1);
    --mix:Draw()
    --mix:Show();
    ----f.tex:SetDesaturated(true)
    ----f.tex:SetSnapToPixelGrid(false)
    ----f.tex:SetTexelSnappingBias(0)
    ----f.tex:SetColorTexture(1, 1, 1, 1) -- black, 50% opacity
--
    --f.mask = f:CreateMaskTexture()
    --f.mask:SetTexture(maskTex, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
    ----f.mask:SetAllPoints(f.tex)
    --f.mask:SetAllPoints(Minimap)
    ----f.mask:SetPoint("CENTER", 10, 0)
    ----f.mask:SetSize(32, 32)
    ----f.mask:SetPoint("CENTER", 10, 10)
    ----f.mask:SetPoint("TOPLEFT", f.tex,"TOPLEFT", 1, 1)
    ----f.mask:SetSize(32, 32)
    --print(maskTex)
    --f.tex:AddMaskTexture(f.mask)
    
    
    --local mask = Minimap:CreateMaskTexture()
    --mask:SetTexture(maskTex, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
    --mask:SetAllPoints(Minimap)

    --local playerMask = Minimap:CreateMaskTexture()
    --print(QuestieLib.AddonPath.."Icons\\playermask")
    --playerMask:SetTexture(QuestieLib.AddonPath.."Icons\\playermask", "CLAMP", "CLAMP", "NEAREST")
    --playerMask:SetParent(Minimap)
    --playerMask:SetPoint("CENTER", 0, 0)
    --playerMask:SetSize(38,38)


    --playerMask:SetAllPoints(Minimap)

    local map = C_Map.GetBestMapForUnit("player")
    local position = C_Map.GetPlayerMapPosition(map, "player")
    local points = {
        {x=(position.x-0.01)*100, y=(position.y-0.01)*100},
        {x=(position.x+0.01)*100, y=(position.y-0.01)*100},
        {x=(position.x-0.01)*100, y=(position.y+0.01)*100},
        {x=(position.x+0.01)*100, y=(position.y+0.01)*100}
    }--CreateFrame("BUTTON", "wwwwww", Minimap)
    

    --IMPROVE HERE!
    --local width, height = Blob.FramePool.parent:GetSize();
    --frame:SetSize(100, 100)
    --frame:SetPoint("TOPLEFT")
    --frame.width = width;
    --frame.height = height;
    --bData = Blob:AddMinimapBlob(nil, points, {r=0, g=0, b=1}, {r=0, g=0, b=1}, {})
    -----@class BlobIconFrame
    --local frame = Blob.MinimapFramePool:Acquire(bData.pinTemplate, 2000);
    --frame:SetParent(Minimap)
    --frame.parent = Minimap;
    --frame.textures = {}
    --frame.lines = {}
    --frame = Mixin(frame, BlobMapPin)
    --bFrame = Blob:DrawPointList(frame, bData, {Blob.minimapMask, Blob.playerMask});--
    --bFrame:Hide()
    --HBDPins:AddMinimapIconMap(test, bFrame, map, position.x, position.y, true, false)

    --bData2 = Blob:AddBlob(1436, points, {r=0, g=0, b=1}, {r=0, g=0, b=1}, {})

    
    --local MyLib = {}
    --local MyLib2 = {}
    --MyLib.callbacks = LibStub("CallbackHandler-1.0"):New(MyLib)
    --MyLib.RegisterCallback(MyLib, "TestEvent", function(self, arg1, arg2) print("1", self, arg1, arg2) end, "test")
    --MyLib.RegisterCallback(MyLib2, "TestEvent", function() print("2") end)
    ----cbbb:RegisterCallback(cbbb, "TestEvent", function() print("2") end)
    --MyLib.callbacks:Fire("TestEvent")

    --local t = {}

    --t[13] = 13
    --t[12] = 12
    --t[1337] = 1337
    --local tableKeys = {}
    --local orderedList = {}
    --for k in pairs(t) do
    --    tinsert(tableKeys, k)
    --end
    --table.sort(tableKeys)

    ---- use the keys to retrieve the values in the sorted order
    --for _, key in ipairs(tableKeys) do
    --    tinsert(orderedList, t[key]);
    --end

    --for index, value in pairs(orderedList) do
    --    print(index, value)
    --end
    local WaypointMap = QuestieLoader:ImportModule("WaypointMap")

    local Pin = WaypointMap.MapProvider:GetMap():AcquirePin(WaypointMap.waypointPinTemplate, 0.5, 0.5, 0.6, 0.4)
    --Pin:SetPosition(0, 0)
    --Pin:SetSize(100, 100);
    Pin:Show();

   



    --local t = Blob:DrawSquare(Minimap, {x=0, y=0}, {x=0.1, y=0}, {x=0.2, y=0}, {x=0.1, y=0.1})
end
SlashCmdList["BLOB"] = Blob_SlashHandler;
SLASH_BLOB1 = "/bl";