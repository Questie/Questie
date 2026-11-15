---@type Townsfolk
local Townsfolk = QuestieLoader:ImportModule("Townsfolk")

---@type NpcId[]
local weaponTrainers = {}

-- Weapon Masters only exist up to WotLK
if Questie.IsWotlk or Questie.IsTBC then
    weaponTrainers = {
        2704,11865,11866,11867,11868,11869,11870,13084,16621,16773,17005,
    }
elseif not (Questie.IsCata or Questie.IsMoP) then
    weaponTrainers = {
        2704,11865,11866,11867,11868,11869,11870,13084,
    }
end

function Townsfolk.GetWeaponTrainers()
    return weaponTrainers
end
