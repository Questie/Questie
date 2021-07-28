local QuestieProfiler = QuestieLoader:CreateModule("Profiler")

QuestieProfiler.hooks = {}
QuestieProfiler.alreadyHooked = {}
QuestieProfiler.needsHook = {}
QuestieProfiler.hookCallCount = {}
QuestieProfiler.hookTimeCount = {}
QuestieProfiler.lowerCaseLookup = {}
QuestieProfiler.shortestName = {}
QuestieProfiler.lookupToHook = {}
QuestieProfiler.hooks = {}
QuestieProfiler.needsHookCount = 0
QuestieProfiler.finishedHookCount = 0
QuestieProfiler.hookedFunctionCount = 0
QuestieProfiler.highestMS = 0
QuestieProfiler.highestCalls = 0
QuestieProfiler.searchFilter = nil

QuestieProfiler.condensedMode = false

QuestieProfiler.scriptsToWatch = {
    "OnUpdate",
    "OnShow",
    "OnHide"
}

function QuestieProfiler:HookFunction(key, val, table, name)
    local lookupKey = name .. "." .. tostring(key)
    QuestieProfiler.shortestName[val] = lookupKey
    QuestieProfiler.alreadyHooked[val] = true
    QuestieProfiler.lookupToHook[lookupKey] = val
    local hook = {}
    hook.original = val
    hook.originalKey = key
    hook.originalParent = table
    
    QuestieProfiler.hookCallCount[lookupKey] = 0
    QuestieProfiler.hookTimeCount[lookupKey] = 0
    hook.override = function(...)
        --local _, _, name = strsplit("\\", debugstack(2))
        --print(name)
        --print("Hookboy run " .. name .. "->"..key)
        local htc = QuestieProfiler.hookCallCount[lookupKey] + 1
        QuestieProfiler.hookCallCount[lookupKey] = htc
        if htc > QuestieProfiler.highestCalls then
            QuestieProfiler.highestCalls = htc
        end
        local start = debugprofilestop()
        local ret = {hook.original(...)}
        start = debugprofilestop() - start
        htc = QuestieProfiler.hookTimeCount[lookupKey] + start
        QuestieProfiler.hookTimeCount[lookupKey] = htc
        if htc > QuestieProfiler.highestMS then
            QuestieProfiler.highestMS = htc
        end
        return unpack(ret)
    end
    QuestieProfiler.lowerCaseLookup[lookupKey] = string.lower(lookupKey)
    tinsert(QuestieProfiler.hooks, hook)
    table[key] = hook.override
    QuestieProfiler.hookedFunctionCount = QuestieProfiler.hookedFunctionCount + 1
end

function QuestieProfiler:HookTable(table, name)
    QuestieProfiler.alreadyHooked[table] = true
    for key, val in pairs(table) do
        if QuestieProfiler.alreadyHooked[val] then
            if QuestieProfiler.shortestName[val] then
                local lookupKey
                if type(key) == "table" then
                    lookupKey = name .. ".(key)"..tostring(key)
                else
                    lookupKey = name .. "." .. tostring(key)
                end
                if string.len(lookupKey) < string.len(QuestieProfiler.shortestName[val]) then
                    QuestieProfiler.shortestName[val] = lookupKey
                    QuestieProfiler.lowerCaseLookup[lookupKey] = string.lower(lookupKey)
                    --print("Shorter name: " .. lookupKey)
                end
            end
        else
            --QuestieProfiler.alreadyHooked[val] = true
            local typ = type(val)
            if type(key) == "table" then
                tinsert(QuestieProfiler.needsHook, {key, name .. ".(key)"..tostring(key)})
                QuestieProfiler.needsHookCount = QuestieProfiler.needsHookCount + 1
            end
            if typ == "function" then
                if key == "GetScript" then -- get all scripts
                    for _, script in pairs(QuestieProfiler.scriptsToWatch) do
                        local res, ret = pcall(val, table, script)
                        if res then
                            QuestieProfiler:HookScript(script, ret, table, name)
                        end
                    end
                end
                --print("["..QuestieProfiler.finishedHookCount.."/"..QuestieProfiler.needsHookCount.."]Hooking function " .. name .. "->" .. key)
                QuestieProfiler:HookFunction(key, val, table, name)
            elseif typ == "table" then
                --QuestieProfiler:HookTable(val, name .. "->"..key)
                
                tinsert(QuestieProfiler.needsHook, {val, name .. "."..tostring(key)})
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

function QuestieProfiler:HookFrames()
    -- bit of a hack but I want to keep questie's code 100% unaffected, this should be a stand-alone module. 
    -- that also makes sure the profiler doesnt mess with the performance of the addon when its not running (which is almost always)
    --C_Timer.NewTicker(2, function()
    --    QuestieProfiler:HookTable(QuestieFramePool, "QuestieFramePool") -- update framepool functions
    --end)
end

function QuestieProfiler:CreateUI()
    local base = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    QuestieProfiler.baseUI = base
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
    base.lastIndex = 0
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
            for call, _ in pairs(QuestieProfiler.hookTimeCount) do
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
                QuestieProfiler.lowerCaseLookup[ncall] = string.lower(ncall)
                if time > highestMS then
                    highestMS = time
                end
                if calls > highestCalls then
                    highestCalls = calls
                end
            end
        end
        for call, count in pairs(timeCount) do
            if ((count > 0 and not QuestieProfiler.searchFilter) or (callCount[call] > 0 and QuestieProfiler.searchFilter and string.match(QuestieProfiler.lowerCaseLookup[call], QuestieProfiler.searchFilter))) then
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
            local color2 = valToHex(1 - (count / (highestMS/2))) or "\124cFFFF0000"
            local color3 = valToHex(1 - (callCount[call] / (highestCalls/2))) or "\124cFFFF0000"
            --print("Highest ms: " .. QuestieProfiler.highestMS)
            --print("Highest calls: " .. QuestieProfiler.highestCalls)
            local callstr = QuestieProfiler.shortestName[QuestieProfiler.lookupToHook[call]] or call

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
        if base.lastIndex > index then
            for _=index, base.lastIndex do
                local line = base.scrollContainer.GetNextLine()
                line[1]:SetText("")
                line[2]:SetText("")
                line[3]:SetText("")
            end
        end
        base.lastIndex = index
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
    button:SetPoint("TOPLEFT", base, base:GetWidth() - 40, 20)
    button:SetWidth(60)
    button:SetHeight(20)
    
    button:SetText("Close")
   
    button:SetNormalFontObject("GameFontNormal")
    button:SetNormalTexture(buildTexture("Interface/Buttons/UI-Panel-Button-Up"))
    button:SetHighlightTexture(buildTexture("Interface/Buttons/UI-Panel-Button-Highlight"))
    button:SetPushedTexture(buildTexture("Interface/Buttons/UI-Panel-Button-Down"))
    button:SetScript("OnClick", function()
        QuestieProfiler:Unhook()
        base:Hide()
    end)

    button = CreateFrame("Button", nil, base)
    button:SetPoint("TOPLEFT", base, 60, 20)
    button:SetWidth(140)
    button:SetHeight(20)
    
    button:SetText("Mode: Full")
    button:SetNormalFontObject("GameFontNormal")
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



    local search = CreateFrame("EditBox", nil, base, BackdropTemplateMixin and "BackdropTemplate" or nil)
    search:SetMultiLine(false)
    search:SetFontObject(ChatFontNormal)
    search:SetWidth(180)
    search:SetHeight(20)
    search:SetFrameStrata("TOOLTIP")
    search:SetPoint("TOPLEFT", base, 220, 20)
    search:SetText("\124cFF888888Filter...")
    search:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = nil,
        tile = true, tileSize = 0, edgeSize = 0, 
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    });
    search:HookScript("OnMouseDown", function()
        if search:GetText() == "\124cFF888888Filter..." then
            search:SetText("")
        end
    end)
    local function clearFocus()
        search:ClearFocus()
        if string.len(search:GetText()) == 0 then
            search:SetText("\124cFF888888Filter...")
        end
    end
    search:SetAutoFocus(false)
    search:SetScript("OnEscapePressed", clearFocus)
    search:HookScript("OnKeyUp", function()
        local txt = string.lower(search:GetText())
        if string.len(txt) == 0 then
            txt = nil
        end
        QuestieProfiler.searchFilter = txt
    end)
    base:SetScript("OnMouseDown", clearFocus)
    base:SetScript("OnDragStart", function()
        base:StartMoving()
        clearFocus()
    end)
    base:SetScript("OnDragStop", function()
        base:StopMovingOrSizing()
    end)
    search:Show()

    base:Show()
    C_Timer.NewTicker(0.5, base.update)
end

function QuestieProfiler:DoHooks(after)
    local timer

    -- libstub modules. TODO: check debugstack() to only include calls made by questie
    --QuestieProfiler.needsHookCount = QuestieProfiler.needsHookCount + 1
    --tinsert(QuestieProfiler.needsHook, {LibStub, "LibStub"})

    for moduleName, module in pairs(QuestieLoader._modules) do
        if module ~= QuestieProfiler then
            QuestieProfiler.needsHookCount = QuestieProfiler.needsHookCount + 1
            tinsert(QuestieProfiler.needsHook, {module, moduleName})
        end
    end

    timer = C_Timer.NewTicker(0.01, function()
        for _=0,512 do
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
        if QuestieProfiler.baseUI then
            QuestieProfiler.baseUI:Show()
        else
            QuestieProfiler:CreateUI()
        end
    end)
end
