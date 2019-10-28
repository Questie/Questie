QuestieProfessions = {...}
local playerProfessions = {}
local professionTable = {}

function QuestieProfessions:Update()
    Questie:Debug(DEBUG_DEVELOP, "QuestieProfession: Update")
    ExpandSkillHeader(0) -- Expand all header

    for i=1, GetNumSkillLines() do
        if i > 14 then break; end -- We don't have to go through all the weapon skills

        local skillName, isHeader, isExpanded, skillRank, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(i)
        if isHeader == nil and professionTable[skillName] then
            playerProfessions[professionTable[skillName]] = skillRank
        end
    end
end

-- This function is just for debugging purpose
-- These is no need to access the playerProfessions table somewhere else
function QuestieProfessions:GetPlayerProfessions()
    return playerProfessions
end

local function HasProfession(prof)
    return prof ~= nil and playerProfessions[prof] ~= nil
end

local function HasProfessionSkill(prof, reqSkill)
    return reqSkill ~= nil and playerProfessions[prof] >= reqSkill
end

function QuestieProfessions:HasProfessionAndSkill(reqSkill)
    return reqSkill == nil or (HasProfession(reqSkill[1]) and HasProfessionSkill(reqSkill[1], reqSkill[2]))
end

-- There are no quests for Skinning and Mining so we don't need them
professionTable = {
    ["First Aid"] = 129,
    ["Erste Hilfe"] = 129,
    ["Primeros auxilios"] = 129,
    ["Secourisme"] = 129,
    ["Primeiros Socorros"] = 129,
    ["Первая помощь"] = 129,
    ["急救"] = 129,
    ["急救"] = 129,
    ["응급치료"] = 129,

    ["Blacksmithing"] = 164,
    ["Schmiedekunst"] = 164,
    ["Herrería"] = 164,
    ["Forge"] = 164,
    ["Ferraria"] = 164,
    ["Кузнечное дело"] = 164,
    ["锻造"] = 164,
    ["鍛造"] = 164,
    ["대장기술"] = 164,

    ["Leatherworking"] = 165,
    ["Lederverarbeitung"] = 165,
    ["Marroquinería"] = 165,
    ["Travail du cuir"] = 165,
    ["Couraria"] = 165,
    ["Кожевничество"] = 165,
    ["制皮"] = 165,
    ["製皮"] = 165,
    ["가죽세공"] = 165,

    ["Alchemy"] = 171,
    ["Alchimie"] = 171,
    ["Alquimia"] = 171,
    ["Alchimie"] = 171,
    ["Alquimia"] = 171,
    ["Алхимия"] = 171,
    ["炼金术"] = 171,
    ["鍊金術"] = 171,
    ["연금술"] = 171,

    ["Herbalism"] = 182,
    ["Kräuterkunde"] = 182,
    ["Botánica"] = 182,
    ["Herboristerie"] = 182,
    ["Herborismo"] = 182,
    ["Травничество"] = 182,
    ["草药学"] = 182,
    ["草藥學"] = 182,
    ["약초채집"] = 182,

    ["Cooking"] = 185,
    ["Kochkunst"] = 185,
    ["Cocina"] = 185,
    ["Cuisine"] = 185,
    ["Culinária"] = 185,
    ["Кулинария"] = 185,
    ["烹饪"] = 185,
    ["烹飪"] = 185,
    ["요리"] = 185,

    ["Mining"] = 186,
    ["Bergbau"] = 186,
    ["Minería"] = 186,
    ["Minage"] = 186,
    ["Mineração"] = 186,
    ["Горное дело"] = 186,
    ["采矿"] = 186,
    ["採礦"] = 186,
    ["채광"] = 186,

    ["Tailoring"] = 197,
    ["Schneiderei"] = 197,
    ["Costura"] = 197,
    ["Couture"] = 197,
    ["Alfaiataria"] = 197,
    ["Портняжное дело"] = 197,
    ["裁缝"] = 197,
    ["裁縫"] = 197,
    ["재봉술"] = 197,

    ["Engineering"] = 202,
    ["Ingenieurskunst"] = 202,
    ["Ingeniería"] = 202,
    ["Ingénierie"] = 202,
    ["Engenharia"] = 202,
    ["Инженерное дело"] = 202,
    ["工程学"] = 202,
    ["工程學"] = 202,
    ["기계공학"] = 202,

    ["Enchanting"] = 333,
    ["Verzauberkunst"] = 333,
    ["Encantamiento"] = 333,
    ["Enchantement"] = 333,
    ["Encantamento"] = 333,
    ["Наложение чар"] = 333,
    ["附魔"] = 333,
    ["附魔"] = 333,
    ["마법부여"] = 333,

    ["Fishing"] = 356,
    ["Angeln"] = 356,
    ["Pesca"] = 356,
    ["Pêche"] = 356,
    ["Pesca"] = 356,
    ["Рыбная ловля"] = 356,
    ["钓鱼"] = 356,
    ["釣魚"] = 356,
    ["낚시"] = 356,

    ["Skinning"] = 393,
    ["Kürschnerei"] = 393,
    ["Desollar"] = 393,
    ["Dépeçage"] = 393,
    ["Esfolamento"] = 393,
    ["Снятие шкур"] = 393,
    ["剥皮"] = 393,
    ["剝皮"] = 393,
    ["무두질"] = 393,
}
