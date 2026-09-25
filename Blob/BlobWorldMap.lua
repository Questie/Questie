-- luacheck: globals MapCanvasDataProviderMixin CreateFromMixins SLASH_QUESTIEBLOBMAP1
local _, _, _, interfaceVersion = GetBuildInfo()
if interfaceVersion < 16000 or interfaceVersion >= 17000 then return end

---@class BlobWorldMap
local BlobWorldMap = QuestieLoader:CreateModule("BlobWorldMap")
local provider
local Provider = {}

function Provider:RemoveAllData()
    self.blob:SetScript("OnUpdate", nil)
    self.blob:DrawNone()
    self.blob:Hide()
end

function Provider:Draw()
    local map = self:GetMap()
    if not map or not map:IsShown() then return end
    self.blob:DrawNone()
    if self.questID then
        if C_QuestLog.GetLogIndexForQuestID(self.questID) then self.blob:DrawBlob(self.questID, true) end
    else
        for i = 1, C_QuestLog.GetNumQuestLogEntries() do
            local quest = C_QuestLog.GetInfo(i)
            if quest and not quest.isHeader then self.blob:DrawBlob(quest.questID, true) end
        end
    end
end

---Coalesce redraws until the canvas has applied its current size/scale. No idle update loop or hover work.
function Provider:RefreshAllData()
    local map = self:GetMap()
    if not map or not map:IsShown() or not map:GetMapID() then
        self:RemoveAllData()
        return
    end
    local blob = self.blob
    blob:DrawNone()
    blob:SetMapID(map:GetMapID())
    blob:SetSize(map:DenormalizeHorizontalSize(1), map:DenormalizeVerticalSize(1))
    blob:SetFrameLevel(map:GetPinFrameLevelsManager():GetValidFrameLevel("PIN_FRAME_LEVEL_QUEST_BLOB"))
    blob:Show()
    blob:SetScript("OnUpdate", function(frame)
        frame:SetScript("OnUpdate", nil)
        self:Draw()
    end)
end

function Provider:OnAdded(map)
    MapCanvasDataProviderMixin.OnAdded(self, map)
    if not self.blob then
        -- A plain native frame avoids QuestBlobPinMixin's polling, hover, tracking and tooltip scripts.
        self.blob = CreateFrame("QuestPOIFrame", nil, map:GetCanvas())
        self.blob:Hide()
        self.blob:SetPoint("CENTER", map:GetCanvas(), "CENTER")
        self.blob:SetFillTexture("Interface\\WorldMap\\UI-QuestBlob-Inside")
        self.blob:SetBorderTexture("Interface\\WorldMap\\UI-QuestBlob-Outside")
        self.blob:SetFillAlpha(96)
        self.blob:SetBorderAlpha(192)
        self.blob:SetBorderScalar(1)
        self.blob:EnableMouse(false)
    end
    self.blob:SetScript("OnEvent", function() self:RefreshAllData() end)
    -- Own event registrations on our frame, not the map's shared provider-event counters.
    self.blob:RegisterEvent("QUEST_POI_UPDATE")
    self.blob:RegisterEvent("QUEST_LOG_UPDATE")
    self:RefreshAllData()
end

function Provider:OnRemoved(map)
    self.blob:UnregisterAllEvents()
    self.blob:SetScript("OnEvent", nil)
    MapCanvasDataProviderMixin.OnRemoved(self, map)
end

Provider.OnShow = Provider.RefreshAllData
Provider.OnMapChanged = Provider.RefreshAllData
Provider.OnCanvasSizeChanged = Provider.RefreshAllData
Provider.OnCanvasScaleChanged = Provider.RefreshAllData
Provider.OnHide = Provider.RemoveAllData

---Draws one loaded quest, or all loaded quests when omitted. Does not open or select a map.
---@param questID number?
---@return boolean enabled
---@return string? error
function BlobWorldMap.Enable(questID)
    if questID ~= nil and (type(questID) ~= "number" or not (questID >= 1 and questID <= 2147483647)
        or questID % 1 ~= 0 or not C_QuestLog.GetLogIndexForQuestID(questID)) then
        return false, "Choose a quest ID from your current quest log."
    end
    if not WorldMapFrame or not MapCanvasDataProviderMixin then
        return false, "Open the world map once, then try /blobmap again."
    end
    if not provider then provider = CreateFromMixins(MapCanvasDataProviderMixin, Provider) end
    provider.questID = questID
    if not provider:GetMap() then WorldMapFrame:AddDataProvider(provider)
    else provider:RefreshAllData() end
    return true
end

---Detaches only this prototype's provider; the native frame is retained, hidden, for reuse.
function BlobWorldMap.Disable()
    if provider and provider:GetMap() then provider:GetMap():RemoveDataProvider(provider) end
end

SLASH_QUESTIEBLOBMAP1 = "/blobmap"
SlashCmdList.QUESTIEBLOBMAP = function(text)
    text = (text or ""):match("^%s*(.-)%s*$"):lower()
    if text == "off" then BlobWorldMap.Disable(); print("Blob world map: off"); return end
    local questID = tonumber(text)
    if text ~= "" and text ~= "all" and not questID then
        print("Usage: /blobmap [all|questID|off]")
        return
    end
    local ok, err = BlobWorldMap.Enable(questID)
    print(ok and ("Blob world map: " .. (questID and ("quest " .. questID) or "all loaded quests")) or err)
end
