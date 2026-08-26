local print = require("cli.print")
local LoaderUsage = require("cli.loaderUsage")

local TOC_PATHS = {
    "Questie-Classic.toc",
    "Questie-BCC.toc",
    "Questie-WOTLKC.toc",
    "Questie-Cata.toc",
    "Questie-Mists.toc",
}

print("\n\27[36mChecking QuestieLoader module call sites...\27[0m")

local findings = LoaderUsage.ScanTocs(TOC_PATHS)
for _, bindingFinding in ipairs(LoaderUsage.ScanBindingsXml("Bindings.xml")) do
    table.insert(findings, bindingFinding)
end
local newFindings = {}
local knownCount = 0

for _, finding in ipairs(findings) do
    if finding.known then
        knownCount = knownCount + 1
    else
        table.insert(newFindings, finding)
    end
end

if knownCount > 0 then
    print(string.format("\27[33m%d known runtime call(s) in reviewed files, not reached during addon load:\27[0m",
        knownCount))
    for path, reason in pairs(LoaderUsage.knownRuntimeCallFiles) do
        print(string.format("  %s  (%s)", path, reason))
    end
end

if #newFindings == 0 then
    print("\27[32mNo new runtime QuestieLoader calls.\27[0m")
    os.exit(0)
end

print(string.format("\n\27[31m%d runtime QuestieLoader call(s) found outside a file's main chunk:\27[0m",
    #newFindings))
for _, finding in ipairs(newFindings) do
    local location = string.format("  %s:%d", finding.path, finding.lineNumber)
    if finding.parseError then
        print(location .. "\n    " .. finding.text .. "\n    <-- scope could not be resolved: " .. finding.parseError)
    else
        -- Outermost first, so the chain reads the way the file does.
        local chain = {}
        for i = #finding.enclosingBlocks, 1, -1 do
            table.insert(chain, finding.enclosingBlocks[i])
        end
        print(string.format("%s\n    %s\n    <-- enclosed by: %s", location, finding.text, table.concat(chain, " > ")))
    end
end
print("")
print("Why this fails: QuestieLoader measures addon file load by the gap between module calls, charging it to")
print("the file that opened the interval. A call from inside a function reopens that interval under the")
print("calling file's name and charges it everything that runs next, silently misattributing load cost.")
print("")
print("The fix: import once at file scope, then use the local inside the function.")
print("")
print("    ---@type QuestieDB")
print("    local QuestieDB = QuestieLoader:ImportModule(\"QuestieDB\")   <-- column zero, with the other imports")
print("")
print("    function Something.Update()")
print("        local quest = QuestieDB.GetQuest(questId)             <-- use the local, do not import again")
print("    end")
print("")
print("This works even when the imported module loads later in the TOC. ImportModule returns the same table")
print("CreateModule will populate, so the reference is live by the time any function runs - an import placed")
print("above the owning file is not an empty module.")
print("")
print("Last resort, if a call genuinely cannot move, add its file to knownRuntimeCallFiles in")
print("cli/loaderUsage.lua with the reason it cannot:")
print("")
print(string.format("    [%q] = \"why this one cannot move\",", newFindings[1].path))

os.exit(1)
