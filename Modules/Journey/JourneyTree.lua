---A list with headers that can be collapsed, and entries below them.
---@class JourneyTree
local JourneyTree = QuestieLoader:CreateModule("JourneyTree")

---@type JourneyList
local JourneyList = QuestieLoader:ImportModule("JourneyList")

local PATH_SEPARATOR = "\001"

---@class JourneyTreeNode
---@field value string|number Unique among the nodes next to it
---@field text string|number
---@field children JourneyTreeNode[]? Makes the node a header, which is only shown with something below it

---@class JourneyTree.Row
---@field node JourneyTreeNode
---@field path string The values of the headers above the node and its own
---@field depth number How many headers are above the node

---@class JourneyTree.Instance
---@field list Frame
---@field nodes JourneyTreeNode[]
---@field rows JourneyTree.Row[] Those that aren't below a collapsed header
---@field expandedPaths table<string, boolean>
---@field selectedPath string?

---@param parentPath string?
---@param value string|number
---@return string
local function _GetPath(parentPath, value)
    return parentPath and (parentPath .. PATH_SEPARATOR .. value) or tostring(value)
end

---@param tree JourneyTree.Instance
---@param nodes JourneyTreeNode[]
---@param parentPath string?
---@param depth number
local function _AddRows(tree, nodes, parentPath, depth)
    for _, node in ipairs(nodes) do
        local path = _GetPath(parentPath, node.value)
        local isEmptyHeader = node.children and #node.children == 0
        if not isEmptyHeader then
            table.insert(tree.rows, {node = node, path = path, depth = depth})
        end
        if node.children and tree.expandedPaths[path] then
            _AddRows(tree, node.children, path, depth + 1)
        end
    end
end

---@param tree JourneyTree.Instance
local function _ShowRows(tree)
    local countBefore = #tree.rows
    tree.rows = {}
    _AddRows(tree, tree.nodes, nil, 0)
    if #tree.rows == countBefore then
        -- Keeps the frames, so a click that is being made right now isn't lost
        JourneyList.Update(tree.list)
    else
        JourneyList.SetCount(tree.list, #tree.rows, true)
    end
end

---@param parent Frame The tree fills it
---@param onSelect fun(node: JourneyTreeNode) Called when the user clicks an entry
---@param getIcon nil|fun(node: JourneyTreeNode): JourneyIcon.Icon? The icon in front of an entry
---@return JourneyTree.Instance
function JourneyTree.Create(parent, onSelect, getIcon)
    ---@type JourneyTree.Instance
    local tree = {nodes = {}, rows = {}, expandedPaths = {}}

    local function GetContent(index)
        local row = tree.rows[index]
        local node = row.node
        return {
            text = node.text,
            icon = getIcon and not node.children and getIcon(node) or nil,
            isSelected = row.path == tree.selectedPath,
            isCollapsed = node.children and not tree.expandedPaths[row.path],
            depth = row.depth,
        }
    end

    local function OnClick(index)
        local row = tree.rows[index]
        if row.node.children then
            tree.expandedPaths[row.path] = not tree.expandedPaths[row.path]
            _ShowRows(tree)
        else
            tree.selectedPath = row.path
            JourneyList.Update(tree.list)
            onSelect(row.node)
        end
    end

    tree.list = JourneyList.Create(parent, GetContent, OnClick)
    return tree
end

---Replaces all entries. What was expanded and selected stays that way, as far as it is still there.
---@param tree JourneyTree.Instance
---@param nodes JourneyTreeNode[]
function JourneyTree.SetNodes(tree, nodes)
    tree.nodes = nodes
    _ShowRows(tree)
end

---Expands headers, also ones that only come with the next entries.
---@param tree JourneyTree.Instance
---@param ... string|number The value of a header, of the one below it, and so on
function JourneyTree.Expand(tree, ...)
    local path
    for _, value in ipairs({...}) do
        path = _GetPath(path, value)
        tree.expandedPaths[path] = true
    end
end

---@param nodes JourneyTreeNode[]
---@param parent JourneyTreeNode?
---@param parentPath string?
---@param isWanted fun(node: JourneyTreeNode, parent: JourneyTreeNode?): boolean
---@return string? path
local function _FindPath(nodes, parent, parentPath, isWanted)
    for _, node in ipairs(nodes) do
        if node.children then
            local path = _FindPath(node.children, node, _GetPath(parentPath, node.value), isWanted)
            if path then
                return path
            end
        elseif isWanted(node, parent) then
            return _GetPath(parentPath, node.value)
        end
    end
end

---@param tree JourneyTree.Instance
---@param isWanted fun(node: JourneyTreeNode, parent: JourneyTreeNode?): boolean
---@return string? path Of the first entry that is wanted, also below collapsed headers. Headers are no entries.
function JourneyTree.FindPath(tree, isWanted)
    return _FindPath(tree.nodes, nil, nil, isWanted)
end

---@param tree JourneyTree.Instance
---@return boolean
function JourneyTree.IsEmpty(tree)
    return #tree.rows == 0
end

---@param nodes JourneyTreeNode[]
---@param value string
---@return JourneyTreeNode?
local function _FindNode(nodes, value)
    for _, node in ipairs(nodes) do
        if tostring(node.value) == value then
            return node
        end
    end
end

---@param tree JourneyTree.Instance
---@return boolean
function JourneyTree.IsSelectionListed(tree)
    if not tree.selectedPath then
        return false
    end

    local nodes = tree.nodes
    for _, value in ipairs({strsplit(PATH_SEPARATOR, tree.selectedPath)}) do
        local node = _FindNode(nodes, value)
        if not node then
            return false
        end
        nodes = node.children or {}
    end
    return true
end

---The selected entry is in another place now. Unlike JourneyTree.Select, what the user is looking at stays as it is.
---@param tree JourneyTree.Instance
---@param path string? Nothing is selected when nil
function JourneyTree.MoveSelection(tree, path)
    tree.selectedPath = path
    JourneyList.Update(tree.list)
end

---Selects an entry as if the user had clicked it, and brings it into view. Doesn't call onSelect.
---@param tree JourneyTree.Instance
---@param path string? Nothing is selected when nil, or when there is no such entry
function JourneyTree.Select(tree, path)
    tree.selectedPath = path
    if path then
        JourneyTree.Expand(tree, strsplit(PATH_SEPARATOR, path)) -- The headers above it
    end
    _ShowRows(tree)

    for index, row in ipairs(tree.rows) do
        if row.path == path then
            JourneyList.ScrollTo(tree.list, index)
            return
        end
    end
end

return JourneyTree
