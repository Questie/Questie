-- Renders patrol turns with today's join and with alternative joins for sharp turns, as one SVG.
-- Usage, from the repo root: lua scratch/waypoint-turns/turns_svg.lua . scratch/waypoint-turns/turns.svg
local repo, out = arg[1], arg[2]

-- Loads WaypointGeometry, from the working tree or a git revision, with optional source
-- replacements, into its own table.
local function loadGeometry(replacements, revision)
    local path = "Modules/Map/Waypoints/WaypointGeometry.lua"
    local file = revision and assert(io.popen(("git -C %q show %s:%s"):format(repo, revision, path)))
        or assert(io.open(repo .. "/" .. path))
    local source = file:read("*a")
    file:close()
    for _, r in ipairs(replacements or {}) do
        local replaced, count = source:gsub(r[1], r[2], 1)
        assert(count == 1, "replacement not found: " .. r[1])
        source = replaced
    end
    local mod = {private = {}}
    QuestieLoader = {CreateModule = function() return mod end, ImportModule = function() return mod end}
    assert(loadstring(source))()
    return mod
end

local G = loadGeometry()
-- Before sharp turns got fills and caps.
local GBefore = loadGeometry(nil, "7c1e28bd8")
-- That join, with the inner pull-back capped at the miter limit instead of half the shorter segment.
local GShortPullBack = loadGeometry({{
    "math%.min%(lengths%[a%], lengths%[b%]%) / 2%)",
    "math.min(lengths[a], lengths[b]) / 2, WaypointGeometry.MITER_LIMIT * halfWidth)",
}}, "7c1e28bd8")

local THICKNESS = 3                -- default waypointWidth
local HW = THICKNESS / 2
local QHW = HW * 16 / 12           -- WaypointRenderer QUAD_SCALE
local SMOOTH = 0.75 * HW           -- default waypointSmoothing
local TRIM = HW / 8                -- WaypointRenderer.TRIMMING
local ALPHA = 0.5                  -- default patrol color alpha
local CORE = "rgb(255,184,0)"      -- default patrol color
local LEG = 40
local SHARP_COS = math.cos(math.rad(120)) -- turns past this angle exceed MITER_LIMIT 2
local ROUND_STEP = math.rad(30)    -- widest wedge of a round join

local PX = 13                      -- pixels per unit
local PANEL_W, PANEL_H = 300, 230
local ORIGIN_X, ORIGIN_Y = 240, 115  -- turn point in the panel; 18 units of the first leg show

-- Texture rows across the 16-row image: fade, black, core, black, fade.
local BANDS = {
    {0 / 16, 2 / 16, "black", 0.25}, {2 / 16, 5 / 16, "black", 1}, {5 / 16, 11 / 16, CORE, 1},
    {11 / 16, 14 / 16, "black", 1}, {14 / 16, 16 / 16, "black", 0.25},
}

local function px(x, y) return ("%.2f,%.2f"):format(ORIGIN_X + x * PX, ORIGIN_Y + y * PX) end
local function lerp(ax, ay, bx, by, t) return ax + (bx - ax) * t, ay + (by - ay) * t end

local function polygon(buf, points, fill, opacity)
    local parts = {}
    for i = 1, #points, 2 do parts[#parts + 1] = px(points[i], points[i + 1]) end
    buf[#buf + 1] = ('<polygon points="%s" fill="%s" fill-opacity="%.2f"/>'):format(table.concat(parts, " "), fill, opacity)
end

local function outline(buf, points)
    local parts = {}
    for i = 1, #points, 2 do parts[#parts + 1] = px(points[i], points[i + 1]) end
    buf[#buf + 1] = ('<polygon points="%s" fill="none" stroke="#999" stroke-width="0.7" stroke-dasharray="3 2"/>'):format(
        table.concat(parts, " "))
end

-- Whether quad start left, end left, end right, start right turns the same way at every corner.
local function isConvex(q)
    local xs, ys = {q[1], q[5], q[7], q[3]}, {q[2], q[6], q[8], q[4]}
    local sign = 0
    for i = 1, 4 do
        local j, k = i % 4 + 1, (i + 1) % 4 + 1
        local cross = (xs[j] - xs[i]) * (ys[k] - ys[j]) - (ys[j] - ys[i]) * (xs[k] - xs[j])
        if math.abs(cross) > 1e-9 then
            local s = cross > 0 and 1 or -1
            if sign ~= 0 and s ~= sign then return false end
            sign = s
        end
    end
    return true
end

-- A segment texture: rows run from the quad's left edge (v=0) to its right edge (v=1).
local function drawQuad(buf, q, stats)
    buf[#buf + 1] = ('<g opacity="%.2f">'):format(ALPHA)
    for _, band in ipairs(BANDS) do
        local v0, v1 = band[1], band[2]
        local s0x, s0y = lerp(q[1], q[2], q[3], q[4], v0)
        local s1x, s1y = lerp(q[1], q[2], q[3], q[4], v1)
        local e0x, e0y = lerp(q[5], q[6], q[7], q[8], v0)
        local e1x, e1y = lerp(q[5], q[6], q[7], q[8], v1)
        polygon(buf, {s0x, s0y, e0x, e0y, e1x, e1y, s1x, s1y}, band[3], band[4])
    end
    buf[#buf + 1] = "</g>"
    outline(buf, {q[1], q[2], q[5], q[6], q[7], q[8], q[3], q[4]})
    stats.textures = stats.textures + 1
    if not isConvex(q) then stats.concave = stats.concave + 1 end
end

-- A join wedge: a triangle from the turn point to the outer edge, using the texture's rows from
-- its center (v=0.5) outwards, as SetTexCoord would select them.
local function drawWedge(buf, p, ax, ay, bx, by, stats)
    buf[#buf + 1] = ('<g opacity="%.2f">'):format(ALPHA)
    for _, band in ipairs(BANDS) do
        local f0, f1 = math.max(0, band[1] - 0.5) * 2, math.max(0, band[2] - 0.5) * 2
        if f1 > f0 then
            polygon(buf, {p.x + ax * f0, p.y + ay * f0, p.x + ax * f1, p.y + ay * f1,
                p.x + bx * f1, p.y + by * f1, p.x + bx * f0, p.y + by * f0}, band[3], band[4])
        end
    end
    buf[#buf + 1] = "</g>"
    outline(buf, {p.x, p.y, p.x + ax, p.y + ay, p.x + bx, p.y + by})
    stats.textures = stats.textures + 1
end

-- The renderer's pipeline for one run.
local function drawRun(buf, run, geometry, stats)
    local points = G.Trim(G.Smooth(run, SMOOTH, QHW), TRIM)
    for _, q in ipairs((geometry or G).Quads(points, QHW)) do drawQuad(buf, q, stats) end
end

local function unit(a, b)
    local dx, dy = b.x - a.x, b.y - a.y
    local length = math.sqrt(dx * dx + dy * dy)
    return dx / length, dy / length
end

local function isSharp(a, p, b)
    local inX, inY = unit(a, p)
    local outX, outY = unit(p, b)
    return inX * outX + inY * outY < SHARP_COS
end

-- Square-ended legs meeting at p, each extended by extend past it.
local function drawLegs(buf, a, p, b, extend, stats)
    local inX, inY = unit(a, p)
    local outX, outY = unit(p, b)
    drawRun(buf, {a, {x = p.x + inX * extend, y = p.y + inY * extend}}, nil, stats)
    drawRun(buf, {{x = p.x - outX * extend, y = p.y - outY * extend}, b}, nil, stats)
end

-- Fills the outer side of the turn at p with wedges, at most maxStep wide; one wedge is a bevel.
local function drawOuterFan(buf, a, p, b, maxStep, stats)
    local inX, inY = unit(a, p)
    local outX, outY = unit(p, b)
    -- The outer side is opposite the way the path turns.
    local turnsLeft = inX * outY - inY * outX > 0
    local side = turnsLeft and -1 or 1
    local from = math.atan2(side * inX, -side * inY)
    local to = math.atan2(side * outX, -side * outY)
    local sweep = (to - from + math.pi) % (2 * math.pi) - math.pi
    local steps = maxStep and math.max(1, math.ceil(math.abs(sweep) / maxStep - 1e-9)) or 1
    for i = 1, steps do
        local t0, t1 = from + sweep * (i - 1) / steps, from + sweep * i / steps
        drawWedge(buf, p, math.cos(t0) * QHW, math.sin(t0) * QHW, math.cos(t1) * QHW, math.sin(t1) * QHW, stats)
    end
end

-- A round cap: the line's rows run outwards from p as rings, over sweep radians from angle from.
-- One texture in game; the SVG samples its arc. corners outline the texture's quad.
local function drawCap(buf, p, from, sweep, corners, stats)
    local steps = 48
    buf[#buf + 1] = ('<g opacity="%.2f">'):format(ALPHA)
    for _, band in ipairs(BANDS) do
        local f0, f1 = math.max(0, band[1] - 0.5) * 2 * QHW, math.max(0, band[2] - 0.5) * 2 * QHW
        if f1 > f0 then
            local points = {}
            for i = 0, steps do
                local t = from + sweep * i / steps
                points[#points + 1], points[#points + 2] = p.x + math.cos(t) * f1, p.y + math.sin(t) * f1
            end
            for i = steps, 0, -1 do
                local t = from + sweep * i / steps
                points[#points + 1], points[#points + 2] = p.x + math.cos(t) * f0, p.y + math.sin(t) * f0
            end
            polygon(buf, points, band[3], band[4])
        end
    end
    buf[#buf + 1] = "</g>"
    outline(buf, corners)
    stats.textures = stats.textures + 1
end

-- A half disc on the outgoing leg's start edge, bulging back against its direction: a plain
-- rectangle quad R long and 2R wide.
local function drawStartCap(buf, p, b, stats)
    local dirX, dirY = unit(p, b)
    local normalX, normalY = -dirY, dirX
    local from = math.atan2(normalY, normalX)
    -- Sweep through the backwards direction.
    local mid = from + math.pi / 2
    local sweep = (math.cos(mid) * -dirX + math.sin(mid) * -dirY > 0) and math.pi or -math.pi
    local nx, ny, bx, by = normalX * QHW, normalY * QHW, -dirX * QHW, -dirY * QHW
    drawCap(buf, p, from, sweep, {p.x + nx, p.y + ny, p.x + nx + bx, p.y + ny + by,
        p.x - nx + bx, p.y - ny + by, p.x - nx, p.y - ny}, stats)
end

-- The outer gap's exact sector of a disc, on a kite p, p + L u0, p + L m, p + L u1 with L = √2 R.
local function drawKiteCap(buf, a, p, b, stats)
    local inX, inY = unit(a, p)
    local outX, outY = unit(p, b)
    local side = (inX * outY - inY * outX > 0) and -1 or 1
    local from = math.atan2(side * inX, -side * inY)
    local to = math.atan2(side * outX, -side * outY)
    local sweep = (to - from + math.pi) % (2 * math.pi) - math.pi
    local L, mid = math.sqrt(2) * QHW, from + sweep / 2
    drawCap(buf, p, from, sweep, {p.x, p.y, p.x + math.cos(from) * L, p.y + math.sin(from) * L,
        p.x + math.cos(mid) * L, p.y + math.sin(mid) * L, p.x + math.cos(to) * L, p.y + math.sin(to) * L}, stats)
end

-- Legs whose inner corners are mitered as today, pulled back to where the inner edges cross, at
-- most half the shorter leg, and whose outer corners end square at the turn point. Returns the
-- uncovered area between them and p: inner corner a, outer corner a, p, outer corner b, inner corner b.
local function drawMiteredLegs(buf, a, p, b, stats)
    local inX, inY = unit(a, p)
    local outX, outY = unit(p, b)
    local turnsLeft = inX * outY - inY * outX > 0
    local cosTurn = inX * outX + inY * outY
    local pullBack = math.min(QHW * math.sqrt((1 - cosTurn) / (1 + cosTurn)), LEG / 2)
    -- Left is the side of the normal (-dy, dx); the inner side is the side the path turns to.
    local inner = turnsLeft and 1 or -1
    local aNX, aNY, bNX, bNY = -inY * QHW, inX * QHW, -outY * QHW, outX * QHW
    local aInnerX, aInnerY = p.x - inX * pullBack + aNX * inner, p.y - inY * pullBack + aNY * inner
    local bInnerX, bInnerY = p.x + outX * pullBack + bNX * inner, p.y + outY * pullBack + bNY * inner
    local aOuterX, aOuterY = p.x - aNX * inner, p.y - aNY * inner
    local bOuterX, bOuterY = p.x - bNX * inner, p.y - bNY * inner
    local aEnd = turnsLeft and {aInnerX, aInnerY, aOuterX, aOuterY} or {aOuterX, aOuterY, aInnerX, aInnerY}
    local bStart = turnsLeft and {bInnerX, bInnerY, bOuterX, bOuterY} or {bOuterX, bOuterY, bInnerX, bInnerY}
    drawQuad(buf, {a.x + aNX, a.y + aNY, a.x - aNX, a.y - aNY, aEnd[1], aEnd[2], aEnd[3], aEnd[4]}, stats)
    drawQuad(buf, {bStart[1], bStart[2], bStart[3], bStart[4], b.x + bNX, b.y + bNY, b.x - bNX, b.y - bNY}, stats)
    return {aInnerX, aInnerY, aOuterX, aOuterY, p.x, p.y, bOuterX, bOuterY, bInnerX, bInnerY}
end

-- Clips a convex polygon of {x, y} points to lo <= f(point) <= hi, for a linear f.
local function clipLinear(poly, f, lo, hi)
    local function clip(points, keep)
        local out = {}
        for i, a in ipairs(points) do
            local b = points[i % #points + 1]
            local fa, fb = keep(f(a)), keep(f(b))
            if fa >= 0 then out[#out + 1] = a end
            if (fa >= 0) ~= (fb >= 0) then
                local t = fa / (fa - fb)
                out[#out + 1] = {x = a.x + (b.x - a.x) * t, y = a.y + (b.y - a.y) * t}
            end
        end
        return out
    end
    poly = clip(poly, function(v) return v - lo end)
    if #poly < 3 then return poly end
    return clip(poly, function(v) return hi - v end)
end

-- A triangle textured with a leg's rows: in game a quad with two corners together and 8-value
-- SetTexCoord placing each corner at its distance from the leg's centerline.
local function drawLegTriangle(buf, triangle, p, legX, legY, stats)
    local function v(point) return 0.5 - ((point.x - p.x) * -legY + (point.y - p.y) * legX) / (2 * QHW) end
    buf[#buf + 1] = ('<g opacity="%.2f">'):format(ALPHA)
    for _, band in ipairs(BANDS) do
        local clipped = clipLinear(triangle, v, band[1], band[2])
        if #clipped >= 3 then
            local flat = {}
            for _, point in ipairs(clipped) do flat[#flat + 1], flat[#flat + 2] = point.x, point.y end
            polygon(buf, flat, band[3], band[4])
        end
    end
    buf[#buf + 1] = "</g>"
    local flat = {}
    for _, point in ipairs(triangle) do flat[#flat + 1], flat[#flat + 2] = point.x, point.y end
    outline(buf, flat)
    stats.textures = stats.textures + 1
end

local function fillHole(buf, a, p, b, hole, stats)
    local inX, inY = unit(a, p)
    local outX, outY = unit(p, b)
    local center = {x = p.x, y = p.y}
    drawLegTriangle(buf, {{x = hole[1], y = hole[2]}, {x = hole[3], y = hole[4]}, center}, p, inX, inY, stats)
    drawLegTriangle(buf, {center, {x = hole[7], y = hole[8]}, {x = hole[9], y = hole[10]}}, p, outX, outY, stats)
end

local function outlineHole(buf, hole)
    local parts = {}
    for i = 1, #hole, 2 do parts[#parts + 1] = px(hole[i], hole[i + 1]) end
    buf[#buf + 1] = ('<polygon points="%s" fill="none" stroke="#ff5050" stroke-width="1.2" stroke-dasharray="4 2"/>'):format(
        table.concat(parts, " "))
end

local function sharpOr(draw)
    return function(buf, pts, stats)
        local a, p, b = pts[1], pts[2], pts[3]
        if not isSharp(a, p, b) then return drawRun(buf, pts, nil, stats) end
        draw(buf, a, p, b, stats)
    end
end

-- A triangle whose texture rows run linearly between the values at its corners, as SetTexCoord sets them.
local function drawRowTriangle(buf, a, b, c, va, vb, vc, stats)
    local det = (b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y)
    local function v(point)
        local wb = ((point.x - a.x) * (c.y - a.y) - (c.x - a.x) * (point.y - a.y)) / det
        local wc = ((b.x - a.x) * (point.y - a.y) - (point.x - a.x) * (b.y - a.y)) / det
        return va + (vb - va) * wb + (vc - va) * wc
    end
    buf[#buf + 1] = ('<g opacity="%.2f">'):format(ALPHA)
    for _, band in ipairs(BANDS) do
        local clipped = clipLinear({a, b, c}, v, band[1], band[2])
        if #clipped >= 3 then
            local flat = {}
            for _, point in ipairs(clipped) do flat[#flat + 1], flat[#flat + 2] = point.x, point.y end
            polygon(buf, flat, band[3], band[4])
        end
    end
    buf[#buf + 1] = "</g>"
    outline(buf, {a.x, a.y, b.x, b.y, c.x, c.y})
    stats.textures = stats.textures + 1
end

-- What Modules/Map/Waypoints draws: the renderer's pipeline with every piece Quads returns.
local function drawShipped(buf, pts, stats)
    local points = G.Trim(G.Smooth(pts, SMOOTH, QHW), TRIM)
    local quads, fills, caps = G.Quads(points, QHW)
    for _, q in ipairs(quads) do drawQuad(buf, q, stats) end
    for _, f in ipairs(fills) do
        drawRowTriangle(buf, {x = f[1], y = f[2]}, {x = f[3], y = f[4]}, {x = f[5], y = f[6]}, 0, 1, 0.5, stats)
    end
    for _, c in ipairs(caps) do
        local p = {x = c[1], y = c[2]}
        local from = math.atan2(c[4] - p.y, c[3] - p.x)
        local to = math.atan2(c[6] - p.y, c[5] - p.x)
        local mid = math.atan2(c[8] - p.y, c[7] - p.x)
        local sweep = (to - from) % (2 * math.pi)
        -- Sweep through the kite's outward corner.
        if math.cos(from + sweep / 2 - mid) < 0 then sweep = sweep - 2 * math.pi end
        drawCap(buf, p, from, sweep, {c[1], c[2], c[5], c[6], c[7], c[8], c[3], c[4]}, stats)
    end
end

local ROWS = {
    {"Shipped now", "Modules/Map/Waypoints as changed: the miter up to 120\194\176, J past it.", drawShipped},
    {"Before", "Commit 7c1e28bd8: miter tip clamped at 2 half widths; inner corners pulled back up to half the shorter segment.",
        function(buf, pts, stats) drawRun(buf, pts, GBefore, stats) end},
    {"A. Shorter pull-back", "Today's join, but inner corners pulled back at most 2 half widths. One-line change.",
        function(buf, pts, stats) drawRun(buf, pts, GShortPullBack, stats) end},
    {"B. Square ends at the turn", "Past 120\194\176 each leg ends square at the turn point. No new textures.",
        sharpOr(function(buf, a, p, b, stats) drawLegs(buf, a, p, b, 0, stats) end)},
    {"C. Square ends past the turn", "Past 120\194\176 each leg ends square half a line width past the turn point. No new textures.",
        sharpOr(function(buf, a, p, b, stats) drawLegs(buf, a, p, b, HW, stats) end)},
    {"D. Bevel", "Past 120\194\176: square ends at the turn plus one flat wedge on the outer side. +1 texture per sharp turn.",
        sharpOr(function(buf, a, p, b, stats)
            drawLegs(buf, a, p, b, 0, stats)
            drawOuterFan(buf, a, p, b, nil, stats)
        end)},
    {"E. Round", "Past 120\194\176: square ends at the turn plus a fan of 30\194\176 wedges on the outer side. +5 or 6 textures per sharp turn.",
        sharpOr(function(buf, a, p, b, stats)
            drawLegs(buf, a, p, b, 0, stats)
            drawOuterFan(buf, a, p, b, ROUND_STEP, stats)
        end)},
    {"F. Half-circle start cap", "Past 120\194\176: square ends at the turn plus a half-disc texture capping the outgoing leg. +1 texture, a plain rectangle quad.",
        sharpOr(function(buf, a, p, b, stats)
            drawLegs(buf, a, p, b, 0, stats)
            drawStartCap(buf, p, b, stats)
        end)},
    {"G. Disc cap on a kite", "Past 120\194\176: square ends at the turn plus the gap's exact sector of a disc texture. +1 texture, needs 8-value SetTexCoord.",
        sharpOr(function(buf, a, p, b, stats)
            drawLegs(buf, a, p, b, 0, stats)
            drawKiteCap(buf, a, p, b, stats)
        end)},
    {"H. Mitered inner corners + half-circle cap", "Past 120\194\176: inner corners mitered as today, outer corners square at the turn, F's cap. Red: the uncovered hollow.",
        sharpOr(function(buf, a, p, b, stats)
            local hole = drawMiteredLegs(buf, a, p, b, stats)
            drawStartCap(buf, p, b, stats)
            outlineHole(buf, hole)
        end)},
    {"I. Mitered inner corners + kite cap", "Past 120\194\176: inner corners mitered as today, outer corners square at the turn, G's cap. No overlap anywhere. Red: the hollow.",
        sharpOr(function(buf, a, p, b, stats)
            local hole = drawMiteredLegs(buf, a, p, b, stats)
            drawKiteCap(buf, a, p, b, stats)
            outlineHole(buf, hole)
        end)},
    {"J. I with the hollow filled", "Each leg also gets the triangle between its inner corner, the turn point and its outer corner, with the leg's own rows. +3 textures, 8-value SetTexCoord.",
        sharpOr(function(buf, a, p, b, stats)
            local hole = drawMiteredLegs(buf, a, p, b, stats)
            fillHole(buf, a, p, b, hole, stats)
            drawKiteCap(buf, a, p, b, stats)
        end)},
}

local ANGLES = {90, 135, 150, 170, 179, 179.95}

local function patrol(deg)
    local t = math.rad(180 - deg)
    return {{x = -LEG, y = 0}, {x = 0, y = 0}, {x = -LEG * math.cos(t), y = LEG * math.sin(t)}}
end

local function drawPatrol(buf, pts)
    local parts = {}
    for _, p in ipairs(pts) do parts[#parts + 1] = px(p.x, p.y) end
    buf[#buf + 1] = ('<polyline points="%s" fill="none" stroke="#3d8bff" stroke-width="1"/>'):format(table.concat(parts, " "))
    local x, y = px(pts[2].x, pts[2].y):match("([^,]+),([^,]+)")
    buf[#buf + 1] = ('<circle cx="%s" cy="%s" r="2.5" fill="#3d8bff"/>'):format(x, y)
end

local TOP, ROW_HEADER = 60, 46
local W = PANEL_W * #ANGLES
local H = TOP + (ROW_HEADER + PANEL_H) * #ROWS
local buf = {('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" font-family="sans-serif" font-size="14">'):format(W, H),
    ('<rect width="%d" height="%d" fill="#3b4a3a"/>'):format(W, H),
    ('<text x="12" y="24" fill="white" font-size="16" font-weight="bold">Sharp patrol turns, default 3-unit line, %d px per unit</text>'):format(PX),
    '<text x="12" y="46" fill="#ccc">Blue: patrol data. Dashed: each texture\'s quad. Darker: textures overlapping at the default 50% alpha. Red numbers: concave quads, which the client draws wrong.</text>'}
for r, row in ipairs(ROWS) do
    local rowY = TOP + (r - 1) * (ROW_HEADER + PANEL_H)
    buf[#buf + 1] = ('<text x="12" y="%d" fill="white" font-weight="bold">%s</text>'):format(rowY + 20, row[1])
    buf[#buf + 1] = ('<text x="12" y="%d" fill="#ccc">%s</text>'):format(rowY + 38, row[2])
    for c, deg in ipairs(ANGLES) do
        local ox, oy = (c - 1) * PANEL_W, rowY + ROW_HEADER
        local clip = ("clip%d_%d"):format(r, c)
        buf[#buf + 1] = ('<clipPath id="%s"><rect width="%d" height="%d"/></clipPath>'):format(clip, PANEL_W, PANEL_H)
        buf[#buf + 1] = ('<g transform="translate(%d,%d)"><g clip-path="url(#%s)">'):format(ox, oy, clip)
        buf[#buf + 1] = ('<rect width="%d" height="%d" fill="none" stroke="#5d6e5c"/>'):format(PANEL_W, PANEL_H)
        local stats = {textures = 0, concave = 0}
        local pts = patrol(deg)
        row[3](buf, pts, stats)
        drawPatrol(buf, pts)
        buf[#buf + 1] = ('<text x="10" y="20" fill="white">turn %g\194\176</text>'):format(deg)
        buf[#buf + 1] = ('<text x="10" y="%d" fill="#ccc" font-size="12">%d textures</text>'):format(PANEL_H - 10, stats.textures)
        if stats.concave > 0 then
            buf[#buf + 1] = ('<text x="110" y="%d" fill="#ff5050" font-size="12">%d concave</text>'):format(PANEL_H - 10, stats.concave)
        end
        buf[#buf + 1] = "</g></g>"
    end
end
buf[#buf + 1] = "</svg>"
local file = assert(io.open(out, "w"))
file:write(table.concat(buf, "\n"))
file:close()
print(out)
