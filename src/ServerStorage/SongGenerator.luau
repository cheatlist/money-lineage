return function() --norp
	local dat = [[]]

	local d = Instance.new("ModuleScript")
	local dattab = {}
	local spltab = string.split(dat,"\n")
	local maxTime = tonumber(string.split(spltab[#spltab],",")[3])
	print(maxTime)
	local ROBLOX_SONG_TIMELENGTH = 88.858
	for _,v in ipairs(spltab) do
		local sp = string.split(v,",")
		if v == "" then continue end
		local z1 = (tonumber(sp[3]) / maxTime) * ROBLOX_SONG_TIMELENGTH
		local z2 = tonumber(sp[1])
		local z3 = tonumber(sp[2])
		--print(z1/100,z2/100,z3/100)
		table.insert(dattab,{z1,z2,z3})
	end
	local encoded = game.HttpService:JSONEncode(dattab)
	encoded = string.gsub(encoded,"%]","}")
	local encoded2 = encoded
	encoded2 = string.gsub(encoded2,"%[","{")
	d.Source = [[return {
	data = ]] .. encoded2 .. [[,
	noteSize = 100, 
	maxErrors = 10,
	newType = true
	}]]
	
	d.Parent = script
	d.Name = "songTest"
end
