local v1 = {
	masculineNames = require(script.Masculine), 
	feminineNames = require(script.Feminine), 
	kasparanNames = require(script.Kasparan), 
	scroomNames = require(script.Scroom), 
	cameoNames = require(script.Cameo), 
	VindNames = require(script.Vind), 
	AzaelNames = require(script.Azael), 
	navaranNames = require(script.Navaran), 
	lNavaranNames = require(script.LesserNavaran), 
	LichNames = require(script.Lich),
}
local u1 = Random.new()
return function(stat)
	local v2 = {}
	if stat.Race == "Kasparan" then
		v2 = v1.kasparanNames
	elseif stat.Race == "Scroom" or stat.Race == "Metascroom" then
		v2 = v1.scroomNames
	elseif stat.Race == "Cameo" then
		v2 = v1.cameoNames
	elseif stat.Race == "Navaran" then
		v2 = v1.navaranNames
	elseif stat.Race == "LesserNavaran" then
		v2 = v1.lNavaranNames
	elseif stat.Race == "Vind" or stat.Race == "Fischeran" then
		v2 = v1.VindNames
	elseif stat.Race == "Azael" or stat.Race == "Dinakeri" then
		v2 = v1.AzaelNames
	elseif stat.Race == "Lich" then
		v2 = v1.LichNames
	elseif stat.Gender == "Female" then
		v2 = v1.feminineNames
	else
		v2 = v1.masculineNames
	end
	return v2[u1:NextInteger(1, #v2)]
end