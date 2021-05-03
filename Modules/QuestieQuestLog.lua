---@class QuestieQuestLog
local QuestieQuestLog = QuestieLoader:CreateModule("QuestieQuestLog")

local elvEnabled = IsAddOnLoaded("ElvUI")

-- Is ElvUI skinning currently enabled?
function QuestieQuestLog:IsElvSkinningEnabled(elv)
    return elv.private.skins.blizzard.enable == true and elv.private.skins.blizzard.quest == true
end

-- Apply some extra positioning when dealing with ElvUI skinned frames
function QuestieQuestLog:ElvSkinFrames()
    if elvEnabled == false then
        return
    end

    local elv = ElvUI[1]
    local S = elv:GetModule("Skins")

    if QuestieQuestLog:IsElvSkinningEnabled(elv) == false then
        return
    end

    local function LoadSkin()
        for i = 1, QUESTS_DISPLAYED do
            local questLogTitle = _G["QuestLogTitle"..i]
            questLogTitle:Width(320)
        end

        QuestLogFrame:HookScript("OnShow", function()
            QuestLogNoQuestsText:ClearAllPoints();
            QuestLogNoQuestsText:SetPoint("CENTER", QuestLogFrame);
        end)
    end

    S:AddCallback("Quest", LoadSkin)
end

-- Initialize Quest Log level badges
function QuestieQuestLog:InitializeQuestLogLevelBadges()
    if (not Questie.db.char.enableQuestLogLevelBadges) then
        return
    end

    local numEntries = GetNumQuestLogEntries();

    if numEntries == 0 then
        return
    end

    for i = 1, QUESTS_DISPLAYED, 1 do
        local questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);

        if questIndex <= numEntries then
            local questLogTitle = _G["QuestLogTitle"..i]
            local questCheck = _G["QuestLogTitle"..i.."Check"]
            local title, level, _, isHeader = GetQuestLogTitle(questIndex)

            if (not isHeader) then
                local questTextFormatted = format("  [%d] %s", level, title)
                questLogTitle:SetText(questTextFormatted)
                QuestLogDummyText:SetText(questTextFormatted)
            end

            questCheck:SetPoint("LEFT", questLogTitle, "LEFT", QuestLogDummyText:GetWidth()+24, 0);
        end
    end
end

-- Resize and re-texture the Quest Log frame.
function QuestieQuestLog:InitializeWideQuestLogFrame()
    if (not Questie.db.char.enableWideQuestLog) then
        return
    end

    -- Configure this as a double-wide frame to stop the UIParent trampling on it
    UIPanelWindows["QuestLogFrame"] = {
        area = "override",
        pushable = 0,
        xoffset = -16,
        yoffset = 12,
        bottomClampOverride = 140+12,
        width = 724,
        height = 513,
        whileDead = 1
    };

    -- Widen the window, note that this size includes some pad on the right hand
    -- side after the scrollbars
    QuestLogFrame:SetWidth(724);
    QuestLogFrame:SetHeight(513);

    -- Adjust quest log title text
    QuestLogTitleText:ClearAllPoints();
    QuestLogTitleText:SetPoint("TOP", QuestLogFrame, "TOP", 0, -18);

    -- Relocate the detail frame over to the right, and stretch it to full height.
    QuestLogDetailScrollFrame:ClearAllPoints();
    QuestLogDetailScrollFrame:SetPoint("TOPLEFT", QuestLogListScrollFrame, "TOPRIGHT", 41, 0);
    QuestLogDetailScrollFrame:SetHeight(362);

    -- Relocate the 'no active quests' text
    QuestLogNoQuestsText:ClearAllPoints();
    QuestLogNoQuestsText:SetPoint("TOP", QuestLogListScrollFrame, 0, -90);

    -- Expand the quest list to full height
    QuestLogListScrollFrame:SetHeight(362);

    -- Create the additional rows
    local oldQuestsDisplayed = QUESTS_DISPLAYED;
    QUESTS_DISPLAYED = QUESTS_DISPLAYED + 17;

    local skinDefaultFrames = true;
    -- Show 3 more quests when ElvUI is present
    if (elvEnabled) then
        local elv = ElvUI[1]

        if QuestieQuestLog:IsElvSkinningEnabled(elv) then
            QUESTS_DISPLAYED = QUESTS_DISPLAYED + 1;

            QuestieQuestLog:ElvSkinFrames()

            skinDefaultFrames = false
        end
    end

    -- If ElvUI is not enabled OR ElvUI is enabled but Quest Frame skinning is disabled
    if skinDefaultFrames then
        QuestieQuestLog:SetQuestLogTextures()
        QuestieQuestLog:SetEmptyQuestLogTextures()
    end

    -- Add extra visible quest in the overview
    for i = oldQuestsDisplayed + 1, QUESTS_DISPLAYED do
        local button = CreateFrame("Button", "QuestLogTitle" .. i, QuestLogFrame, "QuestLogTitleButtonTemplate");
        button:SetID(i);
        button:Hide();
        button:ClearAllPoints();
        button:SetPoint("TOPLEFT", _G["QuestLogTitle" .. (i-1)], "BOTTOMLEFT", 0, 1);
    end

    QuestLog_Update()
end

-- Apply Quest Log textures to double wide Quest Log
function QuestieQuestLog:SetQuestLogTextures()
    -- Now do some trickery to replace the backing textures
    local regions = { QuestLogFrame:GetRegions() }

    -- Slightly freakish offsets to align the images with the frame
    local xOffsets = { Left = 3; Middle = 259; Right = 515; }
    local yOffsets =  { Top = 0; Bot = -256; }

    local textures = {
        TopLeft = "Interface\\AddOns\\Questie\\Icons\\QuestLog\\DW_TopLeft";
        TopMiddle = "Interface\\AddOns\\Questie\\Icons\\QuestLog\\DW_TopMid";
        TopRight = "Interface\\AddOns\\Questie\\Icons\\QuestLog\\DW_TopRight";

        BotLeft = "Interface\\AddOns\\Questie\\Icons\\QuestLog\\DW_BotLeft";
        BotMiddle = "Interface\\AddOns\\Questie\\Icons\\QuestLog\\DW_BotMid";
        BotRight = "Interface\\AddOns\\Questie\\Icons\\QuestLog\\DW_BotRight";
    }

    local PATTERN = "^Interface\\QuestFrame\\UI%-QuestLog%-(([A-Z][a-z]+)([A-Z][a-z]+))$";
    for _, region in ipairs(regions) do
        if (region:IsObjectType("Texture")) then
            local texturefile = region:GetTexture();
            local which, yofs, xofs = texturefile:match(PATTERN);
            xofs = xofs and xOffsets[xofs];
            yofs = yofs and yOffsets[yofs];
            if (xofs and yofs and textures[which]) then
                region:ClearAllPoints();
                region:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", xofs, yofs);
                region:SetTexture(textures[which]);
                region:SetWidth(256);
                region:SetHeight(256);
                textures[which] = nil;
            end
        end
    end

    -- Add in the new ones
    for name, path in pairs(textures) do
        local yofs, xofs = name:match("^([A-Z][a-z]+)([A-Z][a-z]+)$");
        xofs = xofs and xOffsets[xofs];
        yofs = yofs and yOffsets[yofs];
        if xofs and yofs then
            local region = QuestLogFrame:CreateTexture(nil, "ARTWORK");
            region:ClearAllPoints();
            region:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", xofs, yofs);
            region:SetWidth(256);
            region:SetHeight(256);
            region:SetTexture(path);
        end
    end
end

--[[
Adjust empty Quest Log textures to fit the double wide Quest Log

When the Quest Log is empty the original frame has a single pane that contained a parchment texture as
background for visual representation. Because the double wide window moves this empty Quest Log pane to the
right side of the window the dimensions change. This function uses a scaling ratio to make sure the original
empty Quest Log texture can be repurposed.
--]]
function QuestieQuestLog:SetEmptyQuestLogTextures()
    local topOfs = 0.37;
    local topH = 256 * (1 - topOfs);

    local botCap = 0.83;
    local botH = 128 *  botCap;

    local xSize = 256 + 64;
    local ySize = topH + botH;

    local nxSize = QuestLogDetailScrollFrame:GetWidth() + 26;
    local nySize = QuestLogDetailScrollFrame:GetHeight() + 8;

    -- Closure used to reposition and resize the empty Quest Log background texture
    local function relocateEmpty(t, w, h, x, y)
        local nx = x / xSize * nxSize - 10;
        local ny = y / ySize * nySize + 8;
        local nw = w / xSize * nxSize;
        local nh = h / ySize * nySize;

        t:SetWidth(nw);
        t:SetHeight(nh);
        t:ClearAllPoints();
        t:SetPoint("TOPLEFT", QuestLogDetailScrollFrame, "TOPLEFT", nx, ny);
    end

    local txset = { EmptyQuestLogFrame:GetRegions(); }
    -- Iterate all Textures in empty Quest Log frame regions
    for _, t in ipairs(txset) do
        -- When dealing with a texture we want to apply our repositioning and resizing
        if (t:IsObjectType("Texture")) then
            local p = t:GetTexture();
            if (type(p) == "string") then
                -- Pattern matching to check what texture we're currently dealing with
                p = p:match("-([^-]+)$");
                if (p) then
                    if (p == "TopLeft") then
                        t:SetTexCoord(0, 1, topOfs, 1);
                        relocateEmpty(t, 256, topH, 0, 0);
                    elseif (p == "TopRight") then
                        t:SetTexCoord(0, 1, topOfs, 1);
                        relocateEmpty(t, 64, topH, 256, 0);
                    elseif (p == "BotLeft") then
                        t:SetTexCoord(0, 1, 0, botCap);
                        relocateEmpty(t, 256, botH, 0, -topH);
                    elseif (p == "BotRight") then
                        t:SetTexCoord(0, 1, 0, botCap);
                        relocateEmpty(t, 64, botH, 256, -topH);
                    else
                        t:Hide();
                    end
                end
            end
        end
    end
end

-- Initialize the QuestieQuestLog module
function QuestieQuestLog:Initialize()
    Questie:Debug(DEBUG_DEVELOP, "[QuestieQuestLog:Initialize]", "Initializing quest log.")

    QuestieQuestLog:InitializeWideQuestLogFrame()

    QuestLogFrame:HookScript("OnUpdate", function()
        QuestieQuestLog:InitializeQuestLogLevelBadges()
    end)
end
