---@class QuestieQuestLog
local QuestieQuestLog = QuestieLoader:CreateModule("QuestieQuestLog")

local elvEnabled = IsAddOnLoaded("ElvUI")

function QuestieQuestLog:IsElvSkinningEnabled(E)
    return E.private.skins.blizzard.enable == true and E.private.skins.blizzard.quest == true
end

function QuestieQuestLog:ElvSkinFrames()
    if elvEnabled == false then
        return
    end

    local E, L, V, P, G = unpack(ElvUI)
    local S = E:GetModule('Skins')

    if QuestieQuestLog:IsElvSkinningEnabled(E) == false then
        return
    end

    local function LoadSkin()
        for i = 1, QUESTS_DISPLAYED do
            local questLogTitle = _G['QuestLogTitle'..i]
            questLogTitle:Width(320)
        end

        QuestLogFrame:HookScript('OnShow', function()
            QuestLogNoQuestsText:ClearAllPoints();
            QuestLogNoQuestsText:SetPoint("CENTER", QuestLogFrame);
        end)
    end

    S:AddCallback('Quest', LoadSkin)
end

function QuestieQuestLog:InitializeQuestLogLevelBadges()
    if not Questie.db.char.enableQuestLogLevelBadges then
        return
    end

    local numEntries, numQuests = GetNumQuestLogEntries();

    if (numEntries == 0) then return end

    local questIndex, questLogTitle, title, level, _, isHeader, questTextFormatted, questCheck, questCheckXOfs
    for i = 1, QUESTS_DISPLAYED, 1 do
        questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);

        if (questIndex <= numEntries) then
            questLogTitle = _G["QuestLogTitle"..i]
            questCheck = _G["QuestLogTitle"..i.."Check"]
            title, level, _, isHeader = GetQuestLogTitle(questIndex)

            if (not isHeader) then
                questTextFormatted = format("  [%d] %s", level, title)
                questLogTitle:SetText(questTextFormatted)
                QuestLogDummyText:SetText(questTextFormatted)
            end

            questCheck:SetPoint("LEFT", questLogTitle, "LEFT", QuestLogDummyText:GetWidth()+24, 0);
        end
    end
end

function QuestieQuestLog:InitializeWindow()
    if not Questie.db.char.enableWideQuestLog then
        return
    end

    -- Configure this as a double-wide frame to stop the UIParent trampling on it
    UIPanelWindows["QuestLogFrame"] = { area = "override", pushable = 0, xoffset = -16, yoffset = 12, bottomClampOverride = 140+12, width = 724, height = 513, whileDead = 1 };

    -- Widen the window, note that this size includes some pad on the right hand
    -- side after the scrollbars
    QuestLogFrame:SetWidth(724);
    QuestLogFrame:SetHeight(513);

    -- Adjust quest log title text
    QuestLogTitleText:ClearAllPoints();
    QuestLogTitleText:SetPoint("TOP", QuestLogFrame, "TOP", 0, -18);

    -- Relocate the detail frame over to the right, and stretch it to full
    -- height.
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
        local E, L, V, P, G = unpack(ElvUI)
        local S = E:GetModule('Skins')

        if QuestieQuestLog:IsElvSkinningEnabled(E) then
            QUESTS_DISPLAYED = QUESTS_DISPLAYED + 1;

            QuestieQuestLog:ElvSkinFrames()

            skinDefaultFrames = false
        end
    end

    if skinDefaultFrames then
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
                Questie:Debug(DEBUG_DEVELOP, "[QuestieQuestLog:InitializeWindow]", texturefile)
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
            if (xofs and yofs) then
                local region = QuestLogFrame:CreateTexture(nil, "ARTWORK");
                region:ClearAllPoints();
                region:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", xofs, yofs);
                region:SetWidth(256);
                region:SetHeight(256);
                region:SetTexture(path);
            end
        end

        -- And do some tricks with the empty quest log textures...
        local topOfs = 0.37;
        local topH = 256 * (1 - topOfs);

        local botCap = 0.83;
        local botH = 128 *  botCap;

        local xSize = 256 + 64;
        local ySize = topH + botH;

        local nxSize = QuestLogDetailScrollFrame:GetWidth() + 26;
        local nySize = QuestLogDetailScrollFrame:GetHeight() + 8;

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
        for _, t in ipairs(txset) do
            if (t:IsObjectType("Texture")) then
                local p = t:GetTexture();
                if (type(p) == "string") then
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

    for i = oldQuestsDisplayed + 1, QUESTS_DISPLAYED do
        local button = CreateFrame("Button", "QuestLogTitle" .. i, QuestLogFrame, "QuestLogTitleButtonTemplate");
        button:SetID(i);
        button:Hide();
        button:ClearAllPoints();
        button:SetPoint("TOPLEFT", getglobal("QuestLogTitle" .. (i-1)), "BOTTOMLEFT", 0, 1);
    end

    QuestLog_Update()
end

function QuestieQuestLog:Initialize()
    Questie:Debug(DEBUG_DEVELOP, "[QuestieQuestLog:Initialize]", "Initializing quest log.")

    QuestieQuestLog:InitializeWindow()

    QuestLogFrame:HookScript("OnUpdate", function()
        QuestieQuestLog:InitializeQuestLogLevelBadges()
    end)
end
