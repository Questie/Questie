-- Prints the outline quads of each turn. Usage, from the repo root: lua scratch/waypoint-turns/turn_quads.lua
local mod = {private = {}}
QuestieLoader = {CreateModule = function() return mod end, ImportModule = function() return mod end}
dofile("Modules/Map/Waypoints/WaypointGeometry.lua")
local G = QuestieLoader:ImportModule("WaypointGeometry")
local hw = 2 -- half width, 4-unit line
for _, deg in ipairs({90, 150, 170, 179, 179.95}) do
    local t = math.rad(180 - deg) -- angle of the return leg from straight back
    local pts = {{x = -40, y = 0}, {x = 0, y = 0}, {x = -40 * math.cos(t), y = 40 * math.sin(t)}}
    print(("turn %g deg: smoothed points %d"):format(deg, #G.Smooth(pts, 0.75 * hw, hw * 16 / 12)))
    local q = G.Quads(pts, hw)
    local function f(qd) return ("(%.1f,%.1f) (%.1f,%.1f) | end (%.1f,%.1f) (%.1f,%.1f)"):format(unpack(qd)) end
    print("  a: start " .. f(q[1]))
    print("  b: start " .. f(q[2]))
end
