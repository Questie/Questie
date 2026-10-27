---@class RecipeSection
local RecipeSection = QuestieLoader:CreateModule("RecipeSection")

---@type TrackerLayout
local TrackerLayout = QuestieLoader:ImportModule("TrackerLayout")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
---@type TrackerRecipes
local TrackerRecipes = QuestieLoader:ImportModule("TrackerRecipes")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local ZONE_NAME = "Recipes"

function RecipeSection.Draw()
    local recipes = TrackerRecipes.GetTrackedRecipes()
    if #recipes == 0 then
        return
    end

    local margins = TrackerLayout.GetMargins()

    local line = TrackerLinePool.GetZoneLine(ZONE_NAME)
    if (not line) then
        return
    end

    if Questie.db.char.collapsedZones[ZONE_NAME] then
        line.expandZone:SetMode(0)
        line.label:SetText("|cFFC0C0C0" .. l10n("Recipes") .. " +|r")
    else
        line.expandZone:SetMode(1)
        line.label:SetText("|cFFC0C0C0" .. l10n("Recipes") .. "|r")
    end

    TrackerLayout.UpdateWidth(line.label:GetUnboundedStringWidth() + margins.left + margins.right)
    line.label:SetWidth(TrackerLayout.GetBaseFrameWidth() - margins.left - margins.right)
    line:SetWidth(line.label:GetWidth())
    TrackerLayout.TrackLineWidth(line.label:GetUnboundedStringWidth() + margins.left)

    line.expandZone:ClearAllPoints()
    line.expandZone:SetPoint("TOPLEFT", line.label, "TOPLEFT", 0, 0)
    line.expandZone:SetWidth(line.label:GetWidth())
    line.expandZone:SetHeight(line.label:GetHeight())
    line.expandZone:Show()

    -- Adds 4 pixels between Zone and first Recipe Title
    line:SetHeight(line.label:GetHeight() + 4)
    line:Show()
    line.label:Show()
    line.Quest = nil
    line.Objective = nil

    if Questie.db.char.collapsedZones[ZONE_NAME] then
        return
    end

    for _, recipe in ipairs(recipes) do
        line = TrackerLinePool.GetRecipeTitleLine(recipe, margins.quest)
        if (not line) then
            return
        end

        line.label:SetText("|cFFFFFF00" .. recipe.Name .. "|r")
        TrackerLayout.UpdateWidth(line.label:GetUnboundedStringWidth() + margins.quest + margins.right)
        line.label:SetWidth(TrackerLayout.GetBaseFrameWidth() - margins.quest - margins.right)
        line:SetWidth(line.label:GetWidth() + margins.quest)
        TrackerLayout.TrackLineWidth(line.label:GetUnboundedStringWidth() + margins.quest)

        -- Adds 4 pixels between Recipe Title and first Reagent
        line:SetHeight(line.label:GetHeight() + 4)
        line:Show()
        line.label:Show()

        for _, reagent in ipairs(recipe.Reagents) do
            line = TrackerLinePool.GetRecipeReagentLine(recipe, margins.objective)
            if (not line) then
                return
            end

            local colorCollected = math.min(reagent.Collected, reagent.Needed)
            line.label:SetText(QuestieLib:GetRGBForObjective({Collected = colorCollected, Needed = reagent.Needed}) ..
                reagent.Name .. ": " .. reagent.Collected .. "/" .. reagent.Needed)
            TrackerLayout.UpdateLineWidth(line, margins.objective)

            -- Adds 1 pixel between multiple Reagents
            line:SetHeight(line.label:GetHeight() + 1)
            line:Show()
            line.label:Show()
        end

        -- Adds 2 pixels and "Padding Between Quests" setting in Tracker Options
        line:SetHeight(line.label:GetHeight() + (Questie.db.profile.trackerQuestPadding + 2))
    end
end
