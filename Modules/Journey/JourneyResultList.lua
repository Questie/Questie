---The list of search results of one kind.
---@class JourneyResultList
local JourneyResultList = QuestieLoader:CreateModule("JourneyResultList")

---@type JourneyList
local JourneyList = QuestieLoader:ImportModule("JourneyList")

---@class JourneyResultList.Instance
---@field list Frame
---@field ids number[]
---@field selectedId number?

---@param parent Frame The list fills it
---@param getText fun(id: number): string
---@param getIcon fun(id: number): JourneyIcon.Icon?
---@param onSelect fun(id: number) Called when the user clicks a result
---@return JourneyResultList.Instance
function JourneyResultList.Create(parent, getText, getIcon, onSelect)
    ---@type JourneyResultList.Instance
    local results = {ids = {}}
    results.list = JourneyList.Create(parent, function(index)
        local id = results.ids[index]
        return {text = getText(id), icon = getIcon(id), isSelected = id == results.selectedId}
    end, function(index)
        results.selectedId = results.ids[index]
        JourneyList.Update(results.list)
        onSelect(results.selectedId)
    end)
    return results
end

---@param results JourneyResultList.Instance
---@param ids number[] Other ones start at the top. The same table as before stays scrolled, with everything up to date.
---@param selectedId number? Doesn't have to be one of them
function JourneyResultList.Show(results, ids, selectedId)
    results.selectedId = selectedId
    if ids == results.ids then
        JourneyList.Update(results.list)
        return
    end
    results.ids = ids
    JourneyList.SetCount(results.list, #ids, false)
end

---@param results JourneyResultList.Instance
function JourneyResultList.ScrollToSelected(results)
    for index, id in ipairs(results.ids) do
        if id == results.selectedId then
            JourneyList.ScrollTo(results.list, index)
            return
        end
    end
end

return JourneyResultList
