---@class TrackerItemButton
local TrackerItemButton = QuestieLoader:CreateModule("TrackerItemButton")

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

    return btn
end

return TrackerItemButton
