---@class TitanReforgedQuestTags
local TitanReforgedQuestTags = QuestieLoader:CreateModule("TitanReforgedQuestTags")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

---Returns tag corrections owned by Titan-only quest templates.
---@return table<QuestId, {[1]: QuestTagIds, [2]: string}>
function TitanReforgedQuestTags.LoadQuestTagCorrections()
    return {
        [93975] = {62, l10n("Raid")}, -- Ragnaros Must Die!
        [94577] = {62, l10n("Raid")}, -- Kael'thas Must Die!
        [94579] = {62, l10n("Raid")}, -- Patchwerk Must Die!
        [95037] = {62, l10n("Raid")}, -- Lord Jaraxxus Must Die!
        [95072] = {62, l10n("Raid")}, -- Hoodoo Embodiment
        [95074] = {62, l10n("Raid")}, -- Falcon's Prophecy
        [95075] = {62, l10n("Raid")}, -- Destructive Prophecy
        [95076] = {62, l10n("Raid")}, -- Divine Prophecy
        [95077] = {62, l10n("Raid")}, -- Redeemer's Prophecy
        [95078] = {62, l10n("Raid")}, -- Prophecy of Protection
        [95079] = {62, l10n("Raid")}, -- Stormcaller's Prophecy
        [95080] = {62, l10n("Raid")}, -- Witchdoctor's Prophecy
        [95081] = {62, l10n("Raid")}, -- Guardian's Prophecy
        [95082] = {62, l10n("Raid")}, -- Lunar Prophecy
        [95083] = {62, l10n("Raid")}, -- Naturalist's Prophecy
        [95084] = {62, l10n("Raid")}, -- Dread Prophecy
        [95085] = {62, l10n("Raid")}, -- Desecrator's Prophecy
        [95088] = {62, l10n("Raid")}, -- Death's Embodiment
        [95089] = {62, l10n("Raid")}, -- Arcanist's Embodiment
        [95090] = {62, l10n("Raid")}, -- Embodiment of Desecration
        [95092] = {62, l10n("Raid")}, -- Embodiment of Dread
        [95093] = {62, l10n("Raid")}, -- Embodiment of Protection
        [95094] = {62, l10n("Raid")}, -- Embodiment of Wrath
        [95095] = {62, l10n("Raid")}, -- Auratic Embodiment
        [95096] = {62, l10n("Raid")}, -- Destructive Embodiment
        [95097] = {62, l10n("Raid")}, -- Syncretist's Embodiment
        [95098] = {62, l10n("Raid")}, -- Divine Embodiment
        [95099] = {62, l10n("Raid")}, -- Redeemer's Embodiment
        [95100] = {62, l10n("Raid")}, -- Witchdoctor's Embodiment
        [95101] = {62, l10n("Raid")}, -- Vodouisant's Embodiment
        [95102] = {62, l10n("Raid")}, -- Stormcaller's Embodiment
        [95103] = {62, l10n("Raid")}, -- Guardian's Embodiment
        [95104] = {62, l10n("Raid")}, -- Animist's Embodiment
        [95105] = {62, l10n("Raid")}, -- Lunar Embodiment
        [95106] = {62, l10n("Raid")}, -- Naturalist's Embodiment
        [96312] = {62, l10n("Raid")}, -- Brutallus Must Die!
        [96315] = {62, l10n("Raid")}, -- XT-002 Deconstructor Must Die!
        [96318] = {62, l10n("Raid")}, -- Shade of Aran Must Die!
    }
end
