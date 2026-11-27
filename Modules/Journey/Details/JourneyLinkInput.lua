---Lets edit boxes take links, like the chat does: Shift-clicking something puts its link into the box that is typed in.
---@class JourneyLinkInput
local JourneyLinkInput = QuestieLoader:CreateModule("JourneyLinkInput")

---@type EditBox[]
local editBoxes = {}

---@param link string
local function _InsertLink(link)
    for _, editBox in ipairs(editBoxes) do
        if editBox:HasFocus() then
            editBox:Insert(link)
        end
    end
end

---@param editBox EditBox
function JourneyLinkInput.Enable(editBox)
    if #editBoxes == 0 then
        -- Every supported client but Cata calls the first one. Checked in Blizzard's source (see AGENTS.md).
        if ChatFrameUtil and ChatFrameUtil.InsertLink then
            hooksecurefunc(ChatFrameUtil, "InsertLink", _InsertLink)
        else
            hooksecurefunc("ChatEdit_InsertLink", _InsertLink)
        end
    end
    table.insert(editBoxes, editBox)
end

return JourneyLinkInput
