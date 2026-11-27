---One of the pages the tabs of the quests show: a list, and the details of what is selected in it.
---
---What is in it comes from its content. Everything the user did with a page, like what is selected and how far it is scrolled,
---stays with it while another page is shown.
---@class JourneyPage
local JourneyPage = QuestieLoader:CreateModule("JourneyPage")

---@type JourneyDetails
local JourneyDetails = QuestieLoader:ImportModule("JourneyDetails")
---@type JourneyEntityDetails
local JourneyEntityDetails = QuestieLoader:ImportModule("JourneyEntityDetails")
---@type JourneyLinks
local JourneyLinks = QuestieLoader:ImportModule("JourneyLinks")
---@type JourneyQuestDetails
local JourneyQuestDetails = QuestieLoader:ImportModule("JourneyQuestDetails")
---@type JourneyThread
local JourneyThread = QuestieLoader:ImportModule("JourneyThread")
---@type JourneyTree
local JourneyTree = QuestieLoader:ImportModule("JourneyTree")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---@class JourneyPage.Selection
---@field kind string A JourneyKind, or one that only the content knows
---@field id number|string

---@class JourneyPage.Content
---@field Load fun(page: JourneyPage.Instance) Fills the list. Runs in a thread, so it can yield.
---@field GetRows nil|fun(page: JourneyPage.Instance, selection: JourneyPage.Selection): JourneyDetails.Row[]? For the kinds only the
---content knows. Nil for the others.
---@field OnShowDetails nil|fun(page: JourneyPage.Instance) Called when the details show something else
---@field GetIcon nil|fun(node: JourneyTreeNode): JourneyIcon.Icon? For entries of the list that don't have their own
---@field GetText nil|fun(node: JourneyTreeNode): string
---@field GetNote nil|fun(node: JourneyTreeNode): string?

---@class JourneyPage.Instance
---@field content JourneyPage.Content
---@field source string? What the content is about
---@field isLoaded boolean? Whether its list was filled before
---@field selection JourneyPage.Selection? It doesn't have to be in the list, because links lead anywhere
---@field backSelections JourneyPage.Selection[] What was shown before, the last one last
---@field forwardSelections JourneyPage.Selection[] What was gone back from, the last one first
---@field tree JourneyTree.Instance
---@field details JourneyDetails.Instance
---@field emptyText FontString
---@field progressText string
---@field progressShare number?
---@field data table What else the content keeps
---@field loadTimer Ticker?
---@field listFrame Frame
---@field detailsFrame Frame
---@field onOpenSource fun(source: string)
---@field onChange fun() When the progress changes, or what is shown

-------------------------
-- Details
-------------------------

---@param page JourneyPage.Instance
---@param selection JourneyPage.Selection
---@return JourneyDetails.Row[]
local function _GetRows(page, selection)
    local rows = page.content.GetRows and page.content.GetRows(page, selection)
    if rows then
        return rows
    end
    local function Update() JourneyPage.ShowDetails(page, true) end
    if selection.kind == "quest" then
        local quest = QuestieDB.GetQuest(selection.id)
        return quest and JourneyQuestDetails.GetRows(quest, Update) or {}
    end
    return JourneyEntityDetails.GetRows(selection.kind, selection.id, Update)
end

---@param page JourneyPage.Instance
---@param keepsScrollPosition boolean? For details of the same thing as before
function JourneyPage.ShowDetails(page, keepsScrollPosition)
    local rows = page.selection and _GetRows(page, page.selection) or {}
    JourneyDetails.SetRows(page.details, rows, keepsScrollPosition)
    if page.content.OnShowDetails and not keepsScrollPosition then
        page.content.OnShowDetails(page)
    end
    page.onChange()
end

---@param page JourneyPage.Instance
---@param selection JourneyPage.Selection
---@return string? path
local function _FindPath(page, selection)
    return JourneyTree.FindPath(page.tree, function(node)
        return node.value == selection.id and (node.kind or "quest") == selection.kind
    end)
end

---Shows something. It is highlighted in the list, if it is there.
---@param page JourneyPage.Instance
---@param selection JourneyPage.Selection
function JourneyPage.Select(page, selection)
    page.selection = selection
    local path = _FindPath(page, selection)
    if path then
        JourneyTree.Select(page.tree, path)
    else
        JourneyTree.MoveSelection(page.tree, nil)
    end
    JourneyPage.ShowDetails(page)
end

-------------------------
-- Back and forward
-------------------------

---Keeps what is shown, so that it can be gone back to. Like in a browser, what was gone back from is forgotten.
---@param page JourneyPage.Instance
---@param selection JourneyPage.Selection What is shown next
local function _Remember(page, selection)
    local shown = page.selection
    if shown and not (shown.kind == selection.kind and shown.id == selection.id) then
        table.insert(page.backSelections, shown)
        page.forwardSelections = {}
    end
end

---The same for a link. What was shown before can be gone back to.
---@param page JourneyPage.Instance
---@param kind JourneyKind
---@param id number
function JourneyPage.Open(page, kind, id)
    local selection = {kind = kind, id = id}
    _Remember(page, selection)
    JourneyPage.Select(page, selection)
end

---Forgets what was shown before, and what was gone back from.
---@param page JourneyPage.Instance
function JourneyPage.ForgetHistory(page)
    page.backSelections, page.forwardSelections = {}, {}
end

---@param page JourneyPage.Instance
---@return boolean
function JourneyPage.CanGoBack(page)
    return #page.backSelections > 0
end

---@param page JourneyPage.Instance
---@return boolean
function JourneyPage.CanGoForward(page)
    return #page.forwardSelections > 0
end

---@param page JourneyPage.Instance
function JourneyPage.GoBack(page)
    table.insert(page.forwardSelections, 1, page.selection)
    JourneyPage.Select(page, table.remove(page.backSelections))
end

---@param page JourneyPage.Instance
function JourneyPage.GoForward(page)
    table.insert(page.backSelections, page.selection)
    JourneyPage.Select(page, table.remove(page.forwardSelections, 1))
end

-------------------------
-- List
-------------------------

---Fills the list. What was selected before stays selected, wherever it is now.
---@param page JourneyPage.Instance
---@param nodes JourneyTreeNode[]
---@param emptyText string Shown when there are no entries
function JourneyPage.SetNodes(page, nodes, emptyText)
    local tree = page.tree
    JourneyTree.SetNodes(tree, nodes)
    page.emptyText:SetText(emptyText)
    page.emptyText:SetShown(JourneyTree.IsEmpty(tree))

    if page.selection and not JourneyTree.IsSelectionListed(tree) then
        local path = _FindPath(page, page.selection)
        if tree.selectedPath then
            JourneyTree.MoveSelection(tree, path)
        else
            JourneyTree.Select(tree, path)
        end
    end
end

---@param page JourneyPage.Instance
---@param text string
---@param share number? Without it, there is only the text
function JourneyPage.SetProgress(page, text, share)
    page.progressText, page.progressShare = text, share
    page.onChange()
end

-------------------------
-- Page
-------------------------

---@param page JourneyPage.Instance
---@param node JourneyTreeNode
local function _OnClick(page, node)
    if node.source then
        -- It leads somewhere else, so what is shown here stays selected
        JourneyTree.MoveSelection(page.tree, page.selection and _FindPath(page, page.selection))
        page.onOpenSource(node.source)
        return
    end
    local kind = node.kind or "quest"
    if kind == "quest" then
        JourneyLinks.TryInsertIntoChat(node.value)
    end
    local selection = {kind = kind, id = node.value}
    _Remember(page, selection)
    page.selection = selection
    JourneyPage.ShowDetails(page)
end

---@param box Frame
---@return Frame
local function _CreateFrame(box)
    local frame = CreateFrame("Frame", nil, box)
    frame:SetAllPoints(box)
    frame:Hide()
    return frame
end

---@param panes JourneyPanes.Instance
---@param onOpenSource fun(source: string)
---@param onChange fun() When the progress changes, or what is shown
---@return JourneyPage.Instance page Hidden, and without content
function JourneyPage.Create(panes, onOpenSource, onChange)
    ---@type JourneyPage.Instance
    local page = {
        onOpenSource = onOpenSource, onChange = onChange, backSelections = {}, forwardSelections = {}, progressText = "", data = {},
    }
    page.listFrame = _CreateFrame(panes.list.contentArea)
    page.detailsFrame = _CreateFrame(panes.details.contentArea)

    local function GetFrom(name)
        return function(node)
            local get = page.content[name]
            return get and get(node) or nil
        end
    end
    page.tree = JourneyTree.Create(page.listFrame, function(node) _OnClick(page, node) end, GetFrom("GetIcon"), GetFrom("GetText"), GetFrom("GetNote"))
    page.details = JourneyDetails.Create(page.detailsFrame)

    page.emptyText = page.listFrame:CreateFontString(nil, "ARTWORK", "GameFontDisable")
    page.emptyText:SetPoint("TOP", page.listFrame, "TOP", 0, -12)
    page.emptyText:SetPoint("LEFT", page.listFrame, "LEFT", 12, 0)
    page.emptyText:SetPoint("RIGHT", page.listFrame, "RIGHT", -12, 0)
    page.emptyText:Hide()
    return page
end

---Nothing of what a page showed is left.
---@param page JourneyPage.Instance
function JourneyPage.Clear(page)
    if page.loadTimer then
        page.loadTimer:Cancel()
    end
    page.isLoaded, page.data = false, {}
    page.selection, page.backSelections, page.forwardSelections = nil, {}, {}
    page.progressText, page.progressShare = "", nil
    page.emptyText:Hide()
    JourneyTree.Clear(page.tree)
    JourneyPage.ShowDetails(page)
end

---Makes a page be about something else.
---@param page JourneyPage.Instance
---@param content JourneyPage.Content
---@param source string?
function JourneyPage.SetContent(page, content, source)
    page.content, page.source = content, source
    JourneyPage.Clear(page)
end

---Brings a page up to date.
---@param page JourneyPage.Instance
function JourneyPage.Refresh(page)
    if page.loadTimer then
        page.loadTimer:Cancel()
    end
    page.loadTimer = JourneyThread.Start("JourneyPage", function()
        page.content.Load(page)
        page.isLoaded = true
    end)
end

---@param page JourneyPage.Instance
---@param isShown boolean
function JourneyPage.SetShown(page, isShown)
    page.listFrame:SetShown(isShown)
    page.detailsFrame:SetShown(isShown)
end

return JourneyPage
