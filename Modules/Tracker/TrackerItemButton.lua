---@class TrackerItemButton
local TrackerItemButton = QuestieLoader:CreateModule("TrackerItemButton")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---@param buttonName string
function TrackerItemButton.New(buttonName)
    local btn = CreateFrame("Button", buttonName, UIParent, "SecureActionButtonTemplate")
    local cooldown = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
    btn.range = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray")
    btn.count = btn:CreateFontString(nil, "ARTWORK", "Game10Font_o1")
    btn:Hide()

    if Questie.db.profile.trackerFadeQuestItemButtons then
        btn:SetAlpha(0)
    end

    btn.SetItem = function(self, quest, buttonType, size)
        local validTexture

        for bag = -2, 4 do
            for slot = 1, QuestieCompat.GetContainerNumSlots(bag) do
                local texture, _, _, _, _, _, _, _, _, itemId = QuestieCompat.GetContainerItemInfo(bag, slot)
                -- These type of quest items can never be secondary buttons
                if quest.sourceItemId == itemId and QuestieDB.QueryItemSingle(itemId, "class") == 12 and buttonType == "primary" then
                    validTexture = texture
                    self.itemId = quest.sourceItemId
                    break
                end
            end
        end
    end

    return btn
end

return TrackerItemButton
