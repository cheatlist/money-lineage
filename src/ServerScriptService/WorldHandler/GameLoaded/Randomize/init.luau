local FindFirstChild,WaitForChild = game.FindFirstChild,game.WaitForChild
local GetChildren,GetDescendants = game.GetChildren,game.GetDescendants
local RaceFolder = game.ReplicatedStorage.Info.Races
local NamesList = require(script.NameGenerator)

local module = {}

local Races = {
	{"Haseldan",1},
	{"Rigan",1},
	{"Ashiin",1},
	{"Castellan",1},
	{"Kasparan",1},
	{"Gaian",1},
	{"Scroom",1},
	{"LesserNavaran",1},
	{"Madrasian", 1},
	{"Dinakeri",1},
	{"Morvid",1},
	{"Vind",1},
	{"Fischeran",1},
	{"Dzin",1},
	{"Cameo",1},
	{"Azael",1},
}

local RolledRaces = {
	{"Haseldan",1},
	{"Rigan",1},
	{"Ashiin",1},
	{"Castellan",1},
	{"Kasparan",1},
	{"Gaian",1},
	{"Scroom",1},
	{"LesserNavaran",1},
	{"Madrasian", 1},
	{"Dinakeri",1},
	{"Morvid",1},
	{"Vind",1},
	{"Fischeran",1},
	{"Dzin",1},
}

local function GetRandomRace(num)
	local count = 0
	for pos,val in next,Races do
		count = count + val[2]
		if num <= count then 
			return val[1] 
		end
	end
	return nil
end

function module.Race()
	local MaxVal = 0
	for _,val in next,Races do
		MaxVal = MaxVal+val[2]
	end
	return GetRandomRace(math.random(1,MaxVal))
end

local function GetRandomRollableRace(num)
	local count = 0
	for pos,val in next,RolledRaces do
		count = count + val[2]
		if num <= count then 
			return val[1] 
		end
	end
	return nil
end


function module.RaceReroll()
	local MaxVal = 0
	for _,val in next,RolledRaces do
		MaxVal = MaxVal+val[2]
	end
	return GetRandomRollableRace(math.random(1,MaxVal))
end

local spawns = {
	"Oresfall",
	"Cave",
	"Wayside",
	"Southern Sanctuary",
	"Tower in the Wall",
	"Alana",
	"Renova",
}
local chaoticspawns = {
	"Oresfall",
	"Cave",
	"Wayside",
	"Southern Sanctuary",
	"Tower in the Wall",
	"Alana",
	"Renova",
}
local orderlyspawns = {
	"Oresfall",
	"Cave",
	"Wayside",
	"Southern Sanctuary",
	"Tower in the Wall",
	"Alana",
	"Renova",
}
function module.Spawn(Race, Alignment)
	if Race == "Scroom" or Race == "Metascroom" or Race == "Florian" then
		return "Scroomville"
	end
	if Alignment < 0 then
		return chaoticspawns[math.random(1, #chaoticspawns)]
	else
		return orderlyspawns[math.random(1, #orderlyspawns)]
	end
end

function module.Gender()
	if math.random(1,2) == 1 then
		return"Male"
	else
		return"Female"
	end
end

function module.FirstName(Race,Gender)
	return NamesList(({Race = Race,Gender = Gender}))
end

function module.RaceVariant(Race)
	local a = GetChildren(RaceFolder[Race])
	local variant = "Default"
	for i = 1,#a do
		local v = a[i]
		if v:IsA("Folder")and #GetChildren(v)>0 then
			if math.random(1,4)==4 then
				variant = v.Name
				break
			end
		end
	end
	return variant
end

local clothes = {
	"RedAdventurer",
	"GreenAdventurer",
	"BlueAdventurer",
	"RedTunic",
	"RedTunic",
	"RedTunic",
}

function module.Armor(Race)
	if Race ~= "Gaian" and Race ~= "Scroom" and Race ~= "Metascroom" and Race ~= "Cameo" and Race ~= "Morvid" then
		return clothes[math.random(1,#clothes)]
	end
	if Race == "Gaian" then
		return"GaianDefault"
	end
	if Race == "Scroom" or Race == "Metascroom" then
		return "ScroomDefault"
	end
	if Race == "Cameo" or Race == "Morvid" then
		return "Rags"
	end
end

function module.ManaColor()
	return Color3.new(math.random(0,255),math.random(0,255),math.random(0,255))
end

local faces = {
	Normal = {
		"Angry",
		"Friendly",
		"Disgruntled",
		"Hollow",
		"Sad",
		"Serious",
		"Tired",
		"Determined",
	},
	LesserNavaran = {
		"Blank",
	},
	Navaran = {
		"Blank",
	},
	Fischeran  = {
		"Variant Angry",
		"Variant Determined",
		"Variant Disgruntled",
		"Variant Friendly",
		"Variant Hollow",
		"Variant Sad",
		"Variant Serious",
		"Variant Tired",
	},
	Rigan  = {
		"Variant Angry",
		"Variant Determined",
		"Variant Disgruntled",
		"Variant Friendly",
		"Variant Hollow",
		"Variant Sad",
		"Variant Serious",
		"Variant Tired",
	},
	Gaian = {"Gaian"},
	Morvid = {"MorvidSupreme"},
	Kasparan = {
		"DragonAnxious",
		"DragonFrustrated",
		"DragonSigil",
		"DragonSmug",
		"DragonUnimpressed",
	},
	Azael = {
		"AzaelConcerned",
		"AzaelFired",
		"AzaelStern",
	},
	
	Dinakeri = {
		"Dinakeri Confident",
		"Dinakeri Indifferent",
	},
}

function module.Face(Race)
	return faces[Race]and faces[Race][math.random(1,#faces[Race])]or faces["Normal"][math.random(1,#faces["Normal"])]
end

return module