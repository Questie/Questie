










-- TODO move this into a utils.lua?
RaceBitIndexTable = { -- addressing the indexes directly to make it more clear
	['human'] = 1,
	['orc'] = 2,
	['dwarf'] = 3,
	['nightelf'] = 4,
	['scourge'] = 5,
	['undead'] = 5,
	['tauren'] = 6,
	['gnome'] = 7,
	['troll'] = 8,
	['goblin'] = 9
};

ClassBitIndexTable = {
	['warrior'] = 1,
	['paladin'] = 2,
	['hunter'] = 3,
	['rogue'] = 4,
	['priest'] = 5,
	['shaman'] = 7,
	['mage'] = 8,
	['warlock'] = 9,
	['druid'] = 11
}

function unpackBinary(val)
	-- assume 32 bit
	ret = {};
	for q=0,16 do
		if bit.band(bit.rshift(val,q), 1) == 1 then
			table.insert(ret, true);
		else
			table.insert(ret, false);
		end
	end
	return ret;
end

function checkQuestRequirements(class, dbClass, race, dbRace)
	local valid = nil;
	if class and dbClass then
		local racemap = unpackBinary(dbRace);
		valid = racemap[RaceBitIndexTable[tolower(race)]];
	end
	
	if race and dbRace and (valid == nil or valid == true) then
		local classmap = unpackBinary(dbClass);
		valid = classmap[ClassBitIndexTable[tolower(class)]];
	end
	
	return valid;
end