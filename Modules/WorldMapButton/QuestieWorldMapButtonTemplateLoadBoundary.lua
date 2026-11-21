---@type QuestieLoader
local QuestieLoader = select(2, ...).QuestieLoader

-- Names this template's load interval after its XML, which loads this file first.
-- An inline XML <Script> gets no addon namespace, so the stamp lives in a file of its own.
QuestieLoader:StampLoadBoundary("Modules/WorldMapButton/QuestieWorldMapButtonTemplate.xml")
