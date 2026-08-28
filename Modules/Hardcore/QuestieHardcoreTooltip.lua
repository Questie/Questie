---@class QuestieHardcoreTooltip
local QuestieHardcoreTooltip = QuestieLoader:CreateModule("QuestieHardcoreTooltip")
local _QuestieHardcoreTooltip = QuestieHardcoreTooltip.private

---@type QuestieHardcore
local QuestieHardcore = QuestieLoader:ImportModule("QuestieHardcore")

local function IsForbidden(tooltip)
    return tooltip.IsForbidden and tooltip:IsForbidden()
end

local function GetQuestIdFromOwner(owner)
    if not owner then
        return nil
    end

    -- Questie's map/minimap pins expose their quest/objective data here.
    local data = owner.data
    if type(data) == "table" then
        if type(data.Id) == "number" and data.Id > 0 then
            return data.Id
        end
        if type(data.questId) == "number" and data.questId > 0 then
            return data.questId
        end
    end

    if type(owner.questId) == "number" and owner.questId > 0 then
        return owner.questId
    end

    return nil
end

local function AddHCBlock(tooltip, questId)
    if not questId or not QuestieHardcore then
        return
    end

    if tooltip._QuestieHardcoreQuestId == questId and tooltip._QuestieHardcoreAdded then
        return
    end

    local lines = QuestieHardcore:GetQuestRiskLines(questId)
    if not lines then
        return
    end

    tooltip._QuestieHardcoreQuestId = questId
    tooltip._QuestieHardcoreAdded = true

    tooltip:AddLine(" ")
    for _, line in ipairs(lines) do
        tooltip:AddLine(line)
    end

    -- We append lines from OnShow, after WoW/Questie has already calculated the
    -- tooltip backdrop. Showing it once more forces the backdrop to resize to
    -- the new HC lines. The guard above prevents recursive duplication.
    tooltip:Show()
end

function QuestieHardcoreTooltip:Initialize()
    if not GameTooltip or _QuestieHardcoreTooltip.initialized then
        return
    end

    if Questie.IsHardcore == false then
        return
    end

    _QuestieHardcoreTooltip.initialized = true

    GameTooltip:HookScript("OnShow", function(tooltip)
        if IsForbidden(tooltip) then
            return
        end

        local owner = tooltip._owner
        local questId = GetQuestIdFromOwner(owner)

        -- Map/minimap quest icons.
        if questId then
            AddHCBlock(tooltip, questId)
        end
    end)

    GameTooltip:HookScript("OnHide", function(tooltip)
        tooltip._QuestieHardcoreQuestId = nil
        tooltip._QuestieHardcoreAdded = nil
    end)
end

-- Bootstrap the Hardcore modules once Questie has finished loading.
local bootstrapFrame = CreateFrame("Frame")
bootstrapFrame:RegisterEvent("PLAYER_LOGIN")
bootstrapFrame:RegisterEvent("ADDON_LOADED")
bootstrapFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName ~= "Questie" then
        return
    end

    C_Timer.After(0.5, function()
        local Hardcore = QuestieLoader:ImportModule("QuestieHardcore")
        local HardcoreTooltip = QuestieLoader:ImportModule("QuestieHardcoreTooltip")

        if Hardcore and Hardcore.Initialize then
            Hardcore:Initialize()
        end
        if HardcoreTooltip and HardcoreTooltip.Initialize then
            HardcoreTooltip:Initialize()
        end
    end)

    self:UnregisterAllEvents()
end)

return QuestieHardcoreTooltip
