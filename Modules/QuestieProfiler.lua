local QuestieProfiler = QuestieLoader:CreateModule("Profiler")

QuestieProfiler.hooks = {}
QuestieProfiler.alreadyHooked = {}
QuestieProfiler.needsHook = {}
QuestieProfiler.hookCallCount = {}
QuestieProfiler.hookTimeCount = {}
QuestieProfiler.hooks = {}
QuestieProfiler.needsHookCount = 0
QuestieProfiler.finishedHookCount = 0
QuestieProfiler.hookedFunctionCount = 0
QuestieProfiler.highestMS = 0
QuestieProfiler.highestCalls = 0

QuestieProfiler.condensedMode = false

function QuestieProfiler:HookTable(table, name)
    QuestieProfiler.alreadyHooked[table] = true
    for key, val in pairs(table) do
        if not QuestieProfiler.alreadyHooked[val] then
            QuestieProfiler.alreadyHooked[val] = true
            local typ = type(val)
            if typ == "function" then
                --print("["..QuestieProfiler.finishedHookCount.."/"..QuestieProfiler.needsHookCount.."]Hooking function " .. name .. "->" .. key)
                local hook = {}
                hook.original = val
                hook.originalKey = key
                hook.originalParent = table
                QuestieProfiler.hookCallCount[name .. "."..key] = 0
                QuestieProfiler.hookTimeCount[name .. "."..key] = 0
                hook.override = function(...)
                    --print("Hookboy run " .. name .. "->"..key)
                    local htc = QuestieProfiler.hookCallCount[name .. "."..key] + 1
                    QuestieProfiler.hookCallCount[name .. "."..key] = htc
                    if htc > QuestieProfiler.highestCalls then
                        QuestieProfiler.highestCalls = htc
                    end
                    local start = debugprofilestop()
                    ret = {hook.original(...)}
                    start = debugprofilestop() - start
                    htc = QuestieProfiler.hookTimeCount[name .. "."..key] + start
                    QuestieProfiler.hookTimeCount[name .. "."..key] = htc
                    if htc > QuestieProfiler.highestMS then
                        QuestieProfiler.highestMS = htc
                    end
                    return unpack(ret)
                end
                tinsert(QuestieProfiler.hooks, hook)
                table[key] = hook.override
                QuestieProfiler.hookedFunctionCount = QuestieProfiler.hookedFunctionCount + 1
            elseif typ == "table" then
                --QuestieProfiler:HookTable(val, name .. "->"..key)
                tinsert(QuestieProfiler.needsHook, {val, name .. "."..key})
                QuestieProfiler.needsHookCount = QuestieProfiler.needsHookCount + 1
            end
        end
    end
    QuestieProfiler.finishedHookCount = QuestieProfiler.finishedHookCount + 1
end

function QuestieProfiler:HookModules()
    for moduleName, module in pairs(QuestieLoader._modules) do
        print("Hooking module " .. moduleName)
        QuestieProfiler:HookTable(module, moduleName)
    end
end

local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")
function QuestieProfiler:HookFrames()
    -- bit of a hack but I want to keep questie's code 100% unaffected, this should be a stand-alone module. 
    -- that also makes sure the profiler doesnt mess with the performance of the addon when its not running (which is almost always)
    --C_Timer.NewTicker(2, function()
    --    QuestieProfiler:HookTable(QuestieFramePool, "QuestieFramePool") -- update framepool functions
    --end)
end

function QuestieProfiler:CreateUI()
    local base = CreateFrame("Frame", nil, UIParent)
    base:SetFrameStrata("TOOLTIP")
    base:SetSize(420, 120)
    base:SetPoint("Center",UIParent, 0, 50)

    base.scrollFrame = CreateFrame("ScrollFrame", nil, base, "UIPanelScrollFrameTemplate")
    base.scrollFrame:SetFrameStrata("TOOLTIP")
    base:SetSize(840, 580)
    base.scrollContainer = CreateFrame("Frame")

    local lineCounter = 0
    base.scrollContainer.ResetLines = function()
        lineCounter = 0
    end
    local lines = {}
    base.scrollContainer.CreateLineFrame = function()
        local label = base.scrollContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        label:SetText("")
        label:SetPoint("TOPLEFT", base.scrollContainer, 0, -lineCounter * 10)

        label:SetWidth(base.scrollFrame:GetWidth()-270)
        label:SetJustifyH("RIGHT")
        
        local label2 = base.scrollContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        label2:SetText("")
        label2:SetPoint("TOPLEFT", base.scrollContainer, base.scrollFrame:GetWidth()-260, -lineCounter * 10)

        local label3 = base.scrollContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        label3:SetText("")
        label3:SetPoint("TOPLEFT", base.scrollContainer, base.scrollFrame:GetWidth()-150, -lineCounter * 10)

        base.scrollContainer:SetSize(base.scrollFrame:GetWidth(), lineCounter * 10)

        return {label, label2, label3}
    end
    base.scrollContainer.GetNextLine = function()
        lineCounter = lineCounter + 1
        if not lines[lineCounter] then
            lines[lineCounter] = base.scrollContainer.CreateLineFrame()
        end
        return lines[lineCounter]
    end
    base.scrollContainer:SetFrameStrata("TOOLTIP")
    base.scrollFrame:SetScrollChild(base.scrollContainer);
    base.scrollFrame:SetAllPoints(base);
    base.scrollFrame:SetPoint("CENTER", base, "TOPLEFT", 0, -300)
    base.scrollContainer:SetSize(base.scrollFrame:GetWidth(), ( base.scrollFrame:GetHeight() * 2 ));
    base:SetBackdrop( { 
        bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", 
        tile = true, tileSize = -32, edgeSize = -32, 
        insets = { left = -24, right = -24, top = -24, bottom = -24 }
    });
    base.scrollFrame:Show()

    base:SetMovable(true)
    base:EnableMouse(true)
    base:RegisterForDrag("LeftButton")
    base:SetScript("OnDragStart", base.StartMoving)
    base:SetScript("OnDragStop", base.StopMovingOrSizing)

    -- should maybe be exposed in QuestieLib
    local function RGBToHex(r, g, b)
        if r > 255 then r = 255 end
        if g > 255 then g = 255 end
        if b > 255 then b = 255 end
        if r<0 then r=0 end
        if g<0 then g=0 end
        if b<0 then b=0 end
        return string.format("\124cFF%02x%02x%02x", r, g, b)
    end
    
    local function FloatRGBToHex(r, g, b) return RGBToHex(r * 254, g * 254, b * 254) end

    local function valToHex(float)
        if float < .49 then return FloatRGBToHex(1, 0 + float / .5, 0) end
        if float == .50 then return FloatRGBToHex(1, 1, 0) end
        if float > .50 then return FloatRGBToHex(1 - float / 2, 1, 0) end
    end
    
    local statusLabel = base:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    statusLabel:SetText("This is a test.")
    statusLabel:SetPoint("BOTTOMLEFT", base, -18, -18)
    statusLabel:Show()

    base.update = function()
        base.scrollContainer.ResetLines()
        local sorted = {}
        local index = 0
        local timeCount = QuestieProfiler.hookTimeCount
        local callCount = QuestieProfiler.hookCallCount
        local highestMS = QuestieProfiler.highestMS
        local highestCalls = QuestieProfiler.highestCalls
        
        if QuestieProfiler.condensedMode then
            timeCount = {}
            callCount = {}
            highestMS = 0
            highestCalls = 0
            for call, count in pairs(QuestieProfiler.hookTimeCount) do
                local callStack = {}
                index = 0
                for token in string.gmatch(call, "[^.]+") do
                    --print(token)
                    tinsert(callStack, token)
                    index = index + 1
                end
                --local ncall = (callStack[index-2] or "?") .. "." .. (callStack[index-1] or "?") .. ":" .. callStack[index].."()"
                --local ncall = (callStack[index-1] or "?") .. ":" .. callStack[index].."()"
                local ncall = callStack[index].."()"
                if callStack[index-1] and not tonumber(callStack[index-1]) then
                    ncall = callStack[index-1] .. "." .. ncall
                end
                if callStack[index-2] and not tonumber(callStack[index-2]) then
                    ncall = callStack[index-2] .. "." .. ncall
                end
                
                if not timeCount[ncall] then
                    timeCount[ncall] = 0
                    callCount[ncall] = 0
                end
                local time = timeCount[ncall] + QuestieProfiler.hookTimeCount[call]
                local calls = callCount[ncall] + QuestieProfiler.hookCallCount[call]
                timeCount[ncall] = time
                callCount[ncall] = calls
                if time > highestMS then
                    highestMS = time
                end
                if calls > highestCalls then
                    highestCalls = calls
                end
            end
        end
        for call, count in pairs(timeCount) do
            if count > 0 then
                tinsert(sorted, {call, count})
                index = index + 1
            end
        end
        table.sort(sorted, function(a, b) return a[2] > b[2] end)

        statusLabel:SetText(string.format("Total functions hooked: %d  Highest call count: %d  Highest time: %.2fms", QuestieProfiler.hookedFunctionCount, highestCalls, highestMS))

        index = 0
        for call in pairs(sorted) do
            call = sorted[call][1]
            local count = timeCount[call]

            local line = base.scrollContainer.GetNextLine()
            local color

            if mod(index,2) == 1 then
                color = "\124cFFFFFFFF"
                --color2 = "\124cFF88FFAA"
            else
                color = "\124cFFEEEEEE"
                --color2 = "\124cFF77EE99"
            end
            local color2 = valToHex(1 - (count / highestMS)) or "\124cFFFF0000"
            local color3 = valToHex(1 - (callCount[call] / highestCalls)) or "\124cFFFF0000"
            --print("Highest ms: " .. QuestieProfiler.highestMS)
            --print("Highest calls: " .. QuestieProfiler.highestCalls)
            local callstr = call

            if(string.len(callstr) > 64) then
                callstr = "..." .. string.sub(callstr, string.len(callstr)-64)
            end

            line[1]:SetText(color..callstr)
            line[2]:SetText(color2..string.format("time=%.2fms", count))
            line[3]:SetText(color3.."call count=" .. callCount[call])
            index = index + 1
            if index > 150 then
                break
            end
        end
    end
    base.update()


    local button = CreateFrame("Button", nil, base)
    button:SetPoint("TOPLEFT", base, -20, 20)
    button:SetWidth(80)
    button:SetHeight(20)
    
    button:SetText("Reset")
   
    button:SetNormalFontObject("GameFontNormal")
    
    local function buildTexture(str)
        local tex = button:CreateTexture()
        tex:SetTexture(str)
        tex:SetTexCoord(0, 0.625, 0, 0.6875)
        tex:SetAllPoints()
        return tex
    end
    
    button:SetNormalTexture(buildTexture("Interface/Buttons/UI-Panel-Button-Up"))
    button:SetHighlightTexture(buildTexture("Interface/Buttons/UI-Panel-Button-Highlight"))
    button:SetPushedTexture(buildTexture("Interface/Buttons/UI-Panel-Button-Down"))
    button:SetScript("OnClick", function(self, ...)
        self:Disable()
        QuestieProfiler:Unhook()
        QuestieProfiler:DoHooks(function()
            for key in pairs(QuestieProfiler.hookCallCount) do
                QuestieProfiler.hookCallCount[key] = 0
                QuestieProfiler.hookTimeCount[key] = 0
            end
            QuestieProfiler.highestMS = 0
            QuestieProfiler.highestCalls = 0
            for _,line in pairs(lines) do
                line[1]:SetText("")
                line[2]:SetText("")
                line[3]:SetText("")
            end
            self:Enable()
        end)
    end)

    button = CreateFrame("Button", nil, base)
    button:SetPoint("TOPLEFT", base, 60, 20)
    button:SetWidth(140)
    button:SetHeight(20)
    
    button:SetText("Mode: Full")
    button:SetNormalFontObject("GameFontNormal")
    
    local function buildTexture(str)
        local tex = button:CreateTexture()
        tex:SetTexture(str)
        tex:SetTexCoord(0, 0.625, 0, 0.6875)
        tex:SetAllPoints()
        return tex
    end
    
    button:SetNormalTexture(buildTexture("Interface/Buttons/UI-Panel-Button-Up"))
    button:SetHighlightTexture(buildTexture("Interface/Buttons/UI-Panel-Button-Highlight"))
    button:SetPushedTexture(buildTexture("Interface/Buttons/UI-Panel-Button-Down"))

    button:SetScript("OnClick", function(...)
        QuestieProfiler.condensedMode = not QuestieProfiler.condensedMode
        if QuestieProfiler.condensedMode then
            button:SetText("Mode: Condensed")
        else
            button:SetText("Mode: Full")
        end
        for key in pairs(QuestieProfiler.hookCallCount) do
            QuestieProfiler.hookCallCount[key] = 0
            QuestieProfiler.hookTimeCount[key] = 0
        end
        QuestieProfiler.highestMS = 0
        QuestieProfiler.highestCalls = 0
        for _,line in pairs(lines) do
            line[1]:SetText("")
            line[2]:SetText("")
            line[3]:SetText("")
        end
    end)




    base:Show()
    C_Timer.NewTicker(0.5, base.update)
end

function QuestieProfiler:DoHooks(after)
    local timer
    for moduleName, module in pairs(QuestieLoader._modules) do
        if module ~= QuestieProfiler then
            QuestieProfiler.needsHookCount = QuestieProfiler.needsHookCount + 1
            tinsert(QuestieProfiler.needsHook, {module, moduleName})
        end
    end
    timer = C_Timer.NewTicker(0.01, function()
        for i=0,512 do
            local toHook = tremove(QuestieProfiler.needsHook)
            if toHook then
                QuestieProfiler:HookTable(toHook[1], toHook[2])
            else
                timer:Cancel()
                if after then after() end
                return
            end
        end
    end)
end

function QuestieProfiler:Unhook()
    for _, hook in pairs(QuestieProfiler.hooks) do
        hook.originalParent[hook.originalKey] = hook.original
    end
    QuestieProfiler.hooks = {}
    QuestieProfiler.alreadyHooked = {}
    QuestieProfiler.needsHookCount = 0
    QuestieProfiler.finishedHookCount = 0
    QuestieProfiler.hookedFunctionCount = 0
    QuestieProfiler.highestMS = 0
    QuestieProfiler.highestCalls = 0
end

function QuestieProfiler:Start() -- call ingame when developing /run QuestieLoader:ImportModule("Profiler"):Start()
    print("Starting profiler...")
    QuestieProfiler:DoHooks(function()
        QuestieProfiler:HookFrames()
        QuestieProfiler:CreateUI()
    end)
end
