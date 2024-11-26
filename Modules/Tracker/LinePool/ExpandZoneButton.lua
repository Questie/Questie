---@class ExpandZoneButton
local ExpandZoneButton = QuestieLoader:CreateModule("ExpandZoneButton")

---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker") -- TODO: Remove this explicit dependency
---@type TrackerFadeTicker
local TrackerFadeTicker = QuestieLoader:ImportModule("TrackerFadeTicker")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")

---@param index number
---@param parent LineFrame
---@param OnEnter function @Callback function for OnEnter
---@param OnLeave function @Callback function for OnLeave
---@return LineFrame
function ExpandZoneButton.New(index, parent, OnEnter, OnLeave)
    local expandZone = CreateFrame("Button", "linePool.expandZone" .. index, parent)
    expandZone:SetWidth(1)
    expandZone:SetHeight(1)
    expandZone:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)

    function expandZone:SetMode(mode)
        if mode ~= self.mode then
            self.mode = mode
        end
    end

    expandZone:SetMode(1) -- maximized
    expandZone:EnableMouse(true)
    expandZone:RegisterForDrag("LeftButton")
    expandZone:RegisterForClicks("LeftButtonUp", "LeftButtonDown", "RightButtonUp", "RightButtonDown")

    expandZone:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            if IsShiftKeyDown() then
                -- This sets up the minAllQuestsInZone table upon first click
                if not Questie.db.char.collapsedZones[self.zoneId] then
                    if not Questie.db.char.minAllQuestsInZone[self.zoneId] then
                        Questie.db.char.minAllQuestsInZone[self.zoneId] = {}
                        -- This flag prevents repopulating QuestID's where we don't want them.
                        Questie.db.char.minAllQuestsInZone[self.zoneId].isTrue = true

                        QuestieCombatQueue:Queue(function()
                            QuestieTracker:Update()
                        end)
                    end
                end
            end
        end
    end)

    expandZone:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            if IsShiftKeyDown() then
                if not Questie.db.char.collapsedZones[self.zoneId] then
                    C_Timer.After(0.1, function()
                        if Questie.db.char.minAllQuestsInZone[self.zoneId].isTrue then
                            -- Places all QuestID's into the collapsedQuests table and keeps the Min/Max buttons in sync.
                            Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLine:minAllQuestsInZone] - Minimize")
                            for questId, _ in pairs(Questie.db.char.minAllQuestsInZone[self.zoneId]) do
                                if type(questId) == "number" then
                                    Questie.db.char.collapsedQuests[questId] = true
                                end
                            end

                            Questie.db.char.minAllQuestsInZone[self.zoneId].isTrue = nil
                        else
                            -- Removes all QuestID's from the collapsedQuests table.
                            Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLine:minAllQuestsInZone] - Maximize")
                            for questId, _ in pairs(Questie.db.char.minAllQuestsInZone[self.zoneId]) do
                                if type(questId) == "number" then
                                    Questie.db.char.collapsedQuests[questId] = nil
                                end
                            end

                            Questie.db.char.minAllQuestsInZone[self.zoneId] = nil
                        end

                        QuestieCombatQueue:Queue(function()
                            QuestieTracker:Update()
                        end)
                    end)
                end
            else
                if self.mode == 1 then
                    self:SetMode(0)
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLine:expandZone] - Minimize")
                else
                    self:SetMode(1)
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLine:expandZone] - Maximize")
                end

                if Questie.db.char.collapsedZones[self.zoneId] == true then
                    Questie.db.char.collapsedZones[self.zoneId] = nil
                else
                    Questie.db.char.collapsedZones[self.zoneId] = true
                end

                QuestieCombatQueue:Queue(function()
                    QuestieTracker:Update()
                end)
            end
        end
    end)

    expandZone:SetScript("OnEnter", function(self)
        OnEnter(self)
        TrackerFadeTicker.Unfade()
    end)

    expandZone:SetScript("OnLeave", function(self)
        OnLeave(self)
        TrackerFadeTicker.Fade()
    end)

    expandZone:Hide()

    return expandZone
end
