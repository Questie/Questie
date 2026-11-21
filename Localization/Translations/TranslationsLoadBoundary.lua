---@type QuestieLoader
local QuestieLoader = select(2, ...).QuestieLoader

-- Names the leading edge of the translation files after Translations.xml, which loads this file first.
-- An inline XML <Script> gets no addon namespace, so the stamp lives in a file of its own.
QuestieLoader:StampLoadBoundary("Localization/Translations/Translations.xml")
