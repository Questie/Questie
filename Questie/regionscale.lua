QuestieRegionScale = {}


-- assemble data from gatherer table (switch to non-locaized zone id as the key)
for x=0,3 do
	local sec = GatherRegionData[x];
	if not (sec == nil) then
		for y=0,32 do
			local dat = sec[y];
			if not (dat == nil) and not (dat['scale'] == nil) then
				local qzoneid = QuestieZones[dat['name']][1];
				QuestieRegionScale[qzoneid] = {
					['scale'] = dat['scale'],
					['xoffset'] = dat['xoffset'],
					['yoffset'] = dat['yoffset']
				};
			end
		end
	end
end