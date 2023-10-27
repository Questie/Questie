---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local autoOptionsLocales = {
}

for k, v in pairs(autoOptionsLocales) do
    l10n.translations[k] = v
end
