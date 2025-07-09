---@class TrackerItemButton
local TrackerItemButton = QuestieLoader:CreateModule("TrackerItemButton")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type TrackerFadeTicker
local TrackerFadeTicker = QuestieLoader:ImportModule("TrackerFadeTicker")

local LSM30 = LibStub("LibSharedMedia-3.0")
local GetItemCount = C_Item.GetItemCount or GetItemCount
local IsItemInRange = C_Item.IsItemInRange or IsItemInRange

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

    btn.SetItem = function(self, questItemId, questId, size)
        local validTexture

        for bag = -2, 4 do
            for slot = 1, QuestieCompat.GetContainerNumSlots(bag) do
                local texture, _, _, _, _, _, _, _, _, itemId = QuestieCompat.GetContainerItemInfo(bag, slot)

                if questItemId == itemId and QuestieDB.QueryItemSingle(itemId, "class") == QuestieDB.itemClasses.QUEST then
                    validTexture = texture
                    self.itemId = questItemId
                    break
                end
            end
        end

        -- Edge case to find "equipped" quest items since they will no longer be in the players bag
        if (not validTexture) then
            for inventorySlot = 1, 19 do
                local itemId = GetInventoryItemID("player", inventorySlot)

                if questItemId == itemId and QuestieDB.QueryItemSingle(itemId, "class") == QuestieDB.itemClasses.QUEST then
                    validTexture = GetInventoryItemTexture("player", inventorySlot)
                    self.itemId = questItemId
                    break
                end
            end
        end

        if validTexture and self.itemId then
            self.questID = questId
            self.charges = GetItemCount(self.itemId, nil, true)
            self.rangeTimer = -1

            self:SetNormalTexture(validTexture)
            self:SetPushedTexture(validTexture)
            self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
            self:SetSize(size, size)

            self:RegisterForClicks("anyUp")

            self:SetScript("OnEvent", self.OnEvent)
            self:SetScript("OnShow", self.OnShow)
            self:SetScript("OnHide", self.OnHide)
            self:SetScript("OnEnter", self.OnEnter)
            self:SetScript("OnLeave", self.OnLeave)

            self:SetAttribute("type1", "item")
            self:SetAttribute("item1", "item:" .. self.itemId)
            self:Show()

            -- Cooldown Updates
            cooldown:SetSize(size - 4, size - 4)
            cooldown:SetPoint("CENTER", self, "CENTER", 0, 0)
            cooldown:Hide()

            -- Range Updates
            self.range:SetText("●")
            self.range:SetPoint("TOPRIGHT", self, "TOPRIGHT", 3, 0)
            self.range:Hide()

            -- Charges Updates
            self.count:Hide()
            self.count:SetFont(LSM30:Fetch("font", Questie.db.profile.trackerFontQuest), Questie.db.profile.trackerFontSizeQuest, "OUTLINE")
            if self.charges > 1 then
                self.count:SetText(self.charges)
                self.count:Show()
            end
            self.count:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 3)

            return true
        else
            self:SetAttribute("item1", nil)
            self:Hide()
        end

        return false
    end
    btn.OnEvent = function(self, event, ...)
        if (event == "PLAYER_TARGET_CHANGED") then
            self.rangeTimer = -1
            self.range:Hide()
        end
    end
    btn.OnUpdate = function(self, elapsed)
        if not self.itemId or not self:IsVisible() then
            return
        end

        local start, duration, enabled = QuestieCompat.GetItemCooldown(self.itemId)

        if enabled == 1 and duration > 0 then
            cooldown:SetCooldown(start, duration, enabled)
            cooldown:Show()
        else
            cooldown:Hide()
        end

        local charges = GetItemCount(self.itemId, nil, true)
        if (not charges or charges ~= self.charges) then
            self.count:Hide()
            self.charges = GetItemCount(self.itemId, nil, true)
            if self.charges > 1 then
                self.count:SetText(self.charges)
                self.count:Show()
            end
            if self.charges == 0 then
                Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLinePool: Button.OnUpdate]")
                QuestieCombatQueue:Queue(function()
                    C_Timer.After(0.2, function()
                        QuestieTracker:Update()
                    end)
                end)
            end
        end

        if UnitExists("target") then
            local rangeTimer = self.rangeTimer
            if (rangeTimer) then
                rangeTimer = rangeTimer - elapsed

                -- IsItemInRange is restricted to only be used either on hostile targets or friendly ones while NOT in combat
                if (rangeTimer <= 0) and (not UnitIsFriend("player", "target") or (not InCombatLockdown())) then
                    local isInRange = IsItemInRange(self.itemId, "target")

                    if isInRange == false then
                        self.range:SetVertexColor(1.0, 0.1, 0.1)
                        self.range:Show()
                    elseif isInRange == true then
                        self.range:SetVertexColor(0.6, 0.6, 0.6)
                        self.range:Show()
                    end

                    rangeTimer = 0.3
                end

                self.rangeTimer = rangeTimer
            end
        end
    end
    btn.OnShow = function(self)
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
    end
    btn.OnHide = function(self)
        self:UnregisterEvent("PLAYER_TARGET_CHANGED")
    end
    btn.OnEnter = function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink("item:" .. tostring(self.itemId) .. ":0:0:0:0:0:0:0")
        GameTooltip:Show()

        TrackerFadeTicker.Unfade(self)
    end
    btn.OnLeave = function(self)
        GameTooltip:Hide()

        TrackerFadeTicker.Fade(self)
    end

    btn.FakeHide = function(self)
        self:RegisterForClicks()
        self:SetScript("OnEnter", nil)
        self:SetScript("OnLeave", nil)
    end

    btn:HookScript("OnUpdate", btn.OnUpdate)

    btn:FakeHide()

    return btn
end


return TrackerItemButton
