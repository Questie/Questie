---@class TrackerQuestFrame
local TrackerQuestFrame = QuestieLoader:CreateModule("TrackerQuestFrame")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type TrackerFadeTicker
local TrackerFadeTicker = QuestieLoader:ImportModule("TrackerFadeTicker")

local questFrame, trackerBaseFrame, trackerHeaderFrame

function TrackerQuestFrame.Initialize(baseFrame, headerFrame)
    trackerBaseFrame = baseFrame
    trackerHeaderFrame = headerFrame

    -- TrackerQuestFrame
    questFrame = CreateFrame("Frame", "TrackedQuests", trackerBaseFrame)
    questFrame:SetWidth(25)
    questFrame:SetHeight(25)

    TrackerQuestFrame.PositionTrackedQuestsFrame()

    questFrame:EnableMouse(true)
    questFrame:SetMovable(true)
    questFrame:SetResizable(true)
    questFrame:RegisterForDrag("LeftButton")
    questFrame:SetScript("OnDragStart", TrackerBaseFrame.OnDragStart)
    questFrame:SetScript("OnDragStop", TrackerBaseFrame.OnDragStop)
    questFrame:SetScript("OnEnter", TrackerFadeTicker.OnEnter)
    questFrame:SetScript("OnLeave", TrackerFadeTicker.OnLeave)

    -- ScrollFrame
    questFrame.ScrollFrame = CreateFrame("ScrollFrame", "TrackedQuestsScrollFrame", questFrame, "UIPanelScrollFrameTemplate")
    questFrame.ScrollFrame:SetAllPoints(questFrame)

    local frameName = questFrame.ScrollFrame:GetName()
    questFrame.ScrollBar = _G[frameName .. "ScrollBar"]
    questFrame.ScrollBar:ClearAllPoints()
    questFrame.ScrollBar:SetPoint("TOPRIGHT", questFrame.ScrollUpButton, "BOTTOMRIGHT", -1, 4)
    questFrame.ScrollBar:SetPoint("BOTTOMRIGHT", questFrame.scrolldownbutton, "TOPRIGHT", -1, -2)
    questFrame.ScrollBar:SetValueStep(25)
    questFrame.ScrollBar.scrollStep = 25
    questFrame.ScrollBar:SetValue(0)
    questFrame.scrollBarHideable = true
    questFrame.ScrollBar:Hide()

    questFrame.ScrollUpButton = _G[frameName .. "ScrollBarScrollUpButton"]
    questFrame.ScrollUpButton:ClearAllPoints()
    questFrame.ScrollUpButton:SetPoint("TOPRIGHT", questFrame.ScrollFrame, "TOPRIGHT", -4, -1)
    questFrame.ScrollUpButton:Hide()

    questFrame.ScrollDownButton = _G[frameName .. "ScrollBarScrollDownButton"]
    questFrame.ScrollDownButton:ClearAllPoints()
    questFrame.ScrollDownButton:SetPoint("BOTTOMRIGHT", questFrame.ScrollFrame, "BOTTOMRIGHT", -4, -7)
    questFrame.ScrollDownButton:Hide()

    questFrame.ScrollBg = questFrame.ScrollBar:CreateTexture(nil, "BACKGROUND")
    questFrame.ScrollBg:SetAllPoints(questFrame.ScrollBar)
    questFrame.ScrollBg:SetColorTexture(0, 0, 0, 0.75)
    questFrame.ScrollBg:Hide()

    questFrame.ScrollChildFrame = CreateFrame("Frame", _G[frameName .. "ScrollChildFrame"])
    questFrame.ScrollChildFrame:SetSize(questFrame.ScrollFrame:GetWidth(), (questFrame.ScrollFrame:GetHeight()))

    questFrame.ScrollFrame:SetScrollChild(questFrame.ScrollChildFrame)

    questFrame:Hide()

    TrackerQuestFrame.questFrame = baseFrame

    return questFrame
end

function TrackerQuestFrame:Update()
    if Questie.db.char.isTrackerExpanded then
        questFrame:ClearAllPoints()
        TrackerQuestFrame.PositionTrackedQuestsFrame()

        questFrame:Show()
    else
        questFrame:Hide()
    end
end

function TrackerQuestFrame.PositionTrackedQuestsFrame()
    local QuestieTrackerLoc = Questie.db[Questie.db.global.questieTLoc].TrackerLocation
    if Questie.db.global.trackerHeaderEnabled then
        if Questie.db.global.autoMoveHeader then
            if QuestieTrackerLoc and (QuestieTrackerLoc[1] == "BOTTOMLEFT" or QuestieTrackerLoc[1] == "BOTTOMRIGHT") then
                -- Auto move tracker header to the bottom
                questFrame:SetPoint("BOTTOMLEFT", trackerHeaderFrame, "TOPLEFT", 0, 5)
            else
                -- Auto move tracker header to the top
                questFrame:SetPoint("TOPLEFT", trackerHeaderFrame, "BOTTOMLEFT", 0, 0)
            end
        else
            -- No Automove. Tracker header always up top
            questFrame:SetPoint("TOPLEFT", trackerHeaderFrame, "BOTTOMLEFT", 0, 0)
        end
    elseif QuestieTrackerLoc and (QuestieTrackerLoc[1] == "BOTTOMLEFT" or QuestieTrackerLoc[1] == "BOTTOMRIGHT") then
        -- No header. TrackedQuestsFrame is attached to the bottom.
        questFrame:SetPoint("BOTTOMLEFT", trackerBaseFrame, "BOTTOMLEFT", 0, 10)
    else
        -- No header. TrackedQuestsFrame is attached to the top.
        questFrame:SetPoint("TOPLEFT", trackerBaseFrame, "TOPLEFT", 0, -10)
    end
end
