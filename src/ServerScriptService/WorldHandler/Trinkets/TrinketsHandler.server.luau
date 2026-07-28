local trinketspawns = game.ServerStorage.TrinketSpawns:GetChildren()
local waitamount = 50
local commands = require(game.ServerScriptService.Modules.Commands)
local ingredients = workspace.Ingredients:getChildren()
local trinketfolder = workspace:FindFirstChild'Trinkets'
if not trinketfolder then
	return
end
local storage = game.ServerStorage.Storage
local findfirstchild = game.FindFirstChild

for _,v in pairs(trinketspawns)do
	v.Transparency = 1
	if not findfirstchild(v,"Spawned")then
		local spawned = Instance.new("BoolValue")
		spawned.Name = "Spawned"
		spawned.Parent = v
	end
end

local spawnrates = {
	common = {
		["Nothing"] = 5000,

		["Old Amulet"] = 7500,
		["Amulet"] = 7500,
		["Ring"] = 7500,
		["Old Ring"] = 7500,
		["Goblet"] = 7500,
		["Idol of the Forgotten"] = 7500,

		["Opal"] = 2500,
		["Sapphire"] = 1000,
		["Emerald"] = 1000,
		["Ruby"] = 1000,
		["Diamond"] = 500,

		["Scroll of Ignis"] = 250,
		["Scroll of Velo"] = 250,
		["Scroll of Armis"] = 250,
		["Scroll of Celeritas"] = 250,
		["Scroll of Telorum"] = 250,
		["Scroll of Trahere"] = 250,
		["Scroll of Viribus"] = 250,
		["Scroll of Nocere"] = 250,
		["Scroll of Sagitta Sol"] = 250,

		["Scroll of Fimbulvetr"] = 50,
		["Scroll of Manus Dei"] = 50,

		--["Phoenix Down"] = 500,
		["Ice Essence"] = 100, 
		
		["Seraph Essence"] = 40,
		["Azael Horn"] = 50,
		["Amulet of the White King"] = 30,
		["Mysterious Artifact"] = 40,
		["Nightstone"] = 40,
		["Lannis Amulet"] = 40,
		["Pocket Watch"] = 20,
		["Race Reroll Essence"] = 10, 
		["Inquisitive Essence"] = 20,
		["Phoenix Feather"] = 30,
		["Unwavering Focus"] = 30,
		["Exoskeleton"] = 50,
		["Charming Stone"] = 90,
		["Playful Stone"] = 90,
		["Black Pill"] = 70,
		["Weights"] = 300,
	},
	tundra = {
		["Nothing"] = 5000,
		["Old Amulet"] = 5000,
		["Amulet"] = 5000,
		["Ring"] = 5000,
		["Old Ring"] = 5000,
		["Goblet"] = 5000,
		["Idol of the Forgotten"] = 5000,

		["Opal"] = 2500,
		["Sapphire"] = 1000,
		["Emerald"] = 1000,
		["Ruby"] = 1000,
		["Diamond"] = 500,

		["Scroll of Ignis"] = 300,
		["Scroll of Velo"] = 300,
		["Scroll of Armis"] = 300,
		["Scroll of Celeritas"] = 300,
		["Scroll of Telorum"] = 300,
		["Scroll of Trahere"] = 300,
		["Scroll of Viribus"] = 300,
		["Scroll of Nocere"] = 300,
		["Scroll of Sagitta Sol"] = 300,

		["Scroll of Fimbulvetr"] = 100,
		["Scroll of Manus Dei"] = 100,

		--["Phoenix Down"] = 250,
		["Ice Essence"] = 150, 
		
		["Seraph Essence"] = 90,
		["Rift Gem"] = 15,
		["Azael Horn"] = 100,
		["Amulet of the White King"] = 100,
		["Mysterious Artifact"] = 100,
		["Nightstone"] = 80,
		["Howler Friend"] = 30,
		["Lannis Amulet"] = 80,
		["Pocket Watch"] = 30,
		["Race Reroll Essence"] = 40,
		["Inquisitive Essence"] = 50,
		["Phoenix Feather"] = 40,
		["Unwavering Focus"] = 50,
		["Exoskeleton"] = 50,
		["Charming Stone"] = 90,
		["Playful Stone"] = 90,
		["Black Pill"] = 70,
		["Weights"] = 300,
	},
	castlerock = {
		["Nothing"] = 5000,
		["Old Amulet"] = 4000,
		["Amulet"] = 4000,
		["Ring"] = 4000,
		["Old Ring"] = 4000,
		["Goblet"] = 4000,
		["Idol of the Forgotten"] = 4000,

		["Opal"] = 2500,
		["Sapphire"] = 1000,
		["Emerald"] = 1000,
		["Ruby"] = 1000,
		["Diamond"] = 500,

		["Scroll of Ignis"] = 300,
		["Scroll of Velo"] = 300,
		["Scroll of Armis"] = 300,
		["Scroll of Celeritas"] = 300,
		["Scroll of Telorum"] = 300,
		["Scroll of Trahere"] = 300,
		["Scroll of Viribus"] = 300,
		["Scroll of Nocere"] = 300,
		["Scroll of Sagitta Sol"] = 300,

		["Scroll of Fimbulvetr"] = 150,
		["Scroll of Manus Dei"] = 150,

		--["Phoenix Down"] = 1000,
		["Ice Essence"] = 800,
		
		["Seraph Essence"] = 304,
		["Rift Gem"] = 54,
		["Azael Horn"] = 320,
		["Amulet of the White King"] = 320,
		["Mysterious Artifact"] = 200,
		["Nightstone"] = 240,
		["Howler Friend"] = 80,
		["Lannis Amulet"] = 240,
		["Race Reroll Essence"] = 400, 
		["Inquisitive Essence"] = 480,
		["Pocket Watch"] = 80,
		["Phoenix Feather"] = 96,
		["Unwavering Focus"] = 80,
		["Exoskeleton"] = 70,
		["Charming Stone"] = 90,
		["Playful Stone"] = 90,
		["Black Pill"] = 70,
		["Weights"] = 300,
	},
}

local function getrandom(number,tables)
	local chosenum = 0
	for i,v in pairs(tables)do
		chosenum += v
		if number <= chosenum then
			return i
		end
	end
end

local CommonJunk = {
	["Nothing"] = true,
	["Old Amulet"] = true,
	["Amulet"] = true,
	["Ring"] = true,
	["Old Ring"] = true,
	["Goblet"] = true,
	["Idol of the Forgotten"] = true,
	["Opal"] = true,
	["Sapphire"] = true,
	["Emerald"] = true,
	["Ruby"] = true,
	["Diamond"] = true,
}

local function ChooseWeightedItem(tables,luck)
	local weights = spawnrates[tables]
	if luck and luck > 0 then
		weights = table.clone(weights)
		if weights["Nothing"] then
			weights["Nothing"] = math.max(weights["Nothing"] - luck, 0)
		end
		for name,w in pairs(weights) do
			if not CommonJunk[name] then
				weights[name] = w + w * (luck / 1000)
			end
		end
	end
	local total: number = 0
	for _,v in pairs(weights)do
		total += v
	end
	local random: number = math.random(1,total)
	local chosen = getrandom(random,weights)
	return chosen
end

--[[task.spawn(function()
	task.wait(60)
	while true do
		task.wait(1)
		for _,v in pairs(ingredients)do
			if v.Transparency == 1 and not v:FindFirstChild("CD") and not v:FindFirstChild("FrostPrincess") then
				if math.random(1,2)==1 then
					local v1 = Instance.new("Accessory")
					v1.Name = "CD"
					v1.Parent = v
					game.Debris:AddItem(v1,30)
					v.ClickDetector.MaxActivationDistance = 12
					v.Transparency = 0
				end
			elseif v.Transparency == 1 and not v:FindFirstChild("CD") and v:FindFirstChild("FrostPrincess") and tick() < 1652455080 + 73600 + 25200 then
				local randomamount = 1000 - math.clamp(#game.Players:GetPlayers(), 1, 10) * 90
				if math.random(1,randomamount)==1 then
					local v1 = Instance.new("Accessory")
					v1.Name = "CD"
					v1.Parent = v
					game.Debris:AddItem(v1,30)
					v.ClickDetector.MaxActivationDistance = 12
					v.Transparency = 0
				end
			end
			wait(0.15)
		end
	end
end)]]

--[[for _,v in pairs(ingredients)do
	v.ClickDetector.MaxActivationDistance = 12
	v.ClickDetector.MouseClick:Connect(function(p)
		if v.Transparency == 0 then
			if (v.Position-p.Character.PrimaryPart.Position).Magnitude>20 then
				return
			end
			local data = game.ServerStorage.PlayerData[p.Name]
			v.Transparency = 1
			commands.AddToInventory(p,v.Name)
			if p.Backpack:FindFirstChild("Nature Mastery") or data.Skills.Value:find("Green Thumb") then
				commands.AddToInventory(p,v.Name)
			end
			if v.Name == "Blood Thorn"and data.Vampire.Value ~= true then
				local race = data.Race.Value
				if race~="Lich"and race~="Metascroom"and race~="Vind"and race~="Seraph"and race~="Fischeran"and race~="Azael"and race~="Gaian"and race~="Cameo"and race~="Dullahan" and race~= "Scroom" then
					data.Vampire.Value = true
					game.ServerStorage.Requests.TagHumanoid:Fire(p.Character,p.Character,{injury = true,nododge = true})
				end
			end
			local v1 = Instance.new("Accessory")
			v1.Name = "CD"
			v1.Parent = v
			game.Debris:AddItem(v1,60)
			v.ClickDetector.MaxActivationDistance = 0
		end
	end)
end]]

local function Shuffle(tbl)
	for i = 1,#tbl,-1 do
		local random = math.random(i)
		tbl[i],tbl[random] = tbl[random],tbl[i]
	end
end

local flags = {}
local GetChildren = game.GetChildren
local Pickups = {}

local function Send(Title, Content, Color)
	game.ServerStorage.Requests.SendWebhook:Fire(
		Title,
		Content,
		Color
	)
end

local function update(plr)
	if Pickups[plr] > 10 then
		Send(plr.Name.." Banned", "Picked up trinkets too fast.", Color3.new(1, 0, 0.0156863))
		game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(plr.Name, true)
		plr:Kick("Exploiting")
	end
end

local function addCount(plr)
	if not Pickups[plr] then
		Pickups[plr] = 0
	end
	Pickups[plr] += 1
	update(plr)
	task.spawn(function()
		task.wait(0.5)
		Pickups[plr] -= 1
	end)
end

local trinkets = {}
local Players = game.Players
local GetPlayers = Players.GetPlayers
while task.wait(10) do
	local PlayfulStoneUsers = 0
	for _,plr in pairs(GetPlayers(Players)) do
		local plrdata = game.ServerStorage.PlayerData:FindFirstChild(plr.Name)
		-- UserId 3858219477 has the Playful Stone effect built in permanently, without owning
		-- the artifact/spending their Artifact slot on it.
		if plrdata and (plrdata.Artifact.Value == "Playful Stone" or plr.UserId == 3858219477) then
			PlayfulStoneUsers += 1
		end
	end
	local LuckBonus = PlayfulStoneUsers * 500
	Shuffle(trinketspawns)
	for _,v in pairs(trinketspawns)do
		if not v.Spawned.Value and not trinkets[v] then
			task.spawn(function()
				trinkets[v] = true
				local maxval: number = 0
				local trinket: string = "Nothing"
				if v.Name == "trinketspawn"then
					trinket = ChooseWeightedItem("common",LuckBonus)
				elseif v.Name == "tundratrinketspawn"then
					trinket = ChooseWeightedItem("tundra",LuckBonus)
				elseif v.Name == "castlerock"then
					trinket = ChooseWeightedItem("castlerock",LuckBonus)
				elseif v.Name == "dungeonspawn" then
					trinket = ChooseWeightedItem("tundra",LuckBonus)
				elseif v.Name == 'norp' then
					trinket = ChooseWeightedItem("castlerock",LuckBonus)
				elseif v.Name == 'modoffice' then
					trinket = ChooseWeightedItem("castlerock",LuckBonus)
				else
					trinket = ChooseWeightedItem("common",LuckBonus)
				end
				if v.Name~="castlerock" then
					task.wait(math.random(30,150))
				else
					task.wait(1.2)
				end
				if trinket == "Nothing"then
					trinkets[v] = nil
					return
				else
					for j,k in pairs(game.Players:GetPlayers()) do
						local char = k.Character
						if not char then continue end
						if not char:FindFirstChild("HumanoidRootPart") then continue end
						if (char.HumanoidRootPart.Position - v.Position).magnitude < 200 then
							return
						end
					end
					--print("Spawned "..trinket)
					if not script:FindFirstChild(trinket) then return end
					local trinketmodel = script[trinket]:Clone()
					trinketmodel.Position = v.Position
					trinketmodel.Name = ""
					trinketmodel.Parent = trinketfolder
					if v:FindFirstChild("Spawned") then
						v.Spawned.Value = true
					end
					local clicked: boolean = false
					local connection: RBXScriptConnection? = nil
					connection = trinketmodel.ClickPart.ClickDetector.MouseClick:Connect(function(player)
						local Char = player.Character
						if not Char then
							return
						end
						local PrimaryP = Char.PrimaryPart
						if not PrimaryP then
							return
						end
						local Hum = Char:FindFirstChild'Humanoid'
						if not Hum or Hum.Health <= 1 then
							return
						end
						if not clicked then
							local mag: number = (trinketmodel.Position-PrimaryP.Position).Magnitude
							if mag>20 then
								if mag>30 then
									if not flags[player.Name]then
										flags[player.Name] = 1
									else
										flags[player.Name] += 1
									end
									if flags[player.Name] == 5 then
										game.ServerStorage.Requests.SendWebhook:Fire(
											"Exploit Detection",
											player.Name.." ("..player.UserId..") ".." tried to pick up a trinket from "..tostring(math.round(mag)).. "studs away",
											"black",
											"Exploit"
										)
									end
								end
								return
							end
							if v.Name == "castlerock"then
								if not player.Character:FindFirstChild("INCR") then
									if not flags[player.Name]then
										flags[player.Name] = 1
									else
										flags[player.Name] += 1
									end
									if flags[player.Name]<5 and flags[player.Name]>10 then
										game.ServerStorage.Requests.SendWebhook:Fire(
											"Exploit Detection",
											player.Name.." tried to pick up a trinket in CR but didn't enter properly",
											"black",
											"Exploit"
										)
										game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(player.Name, true)
										player:Kick("ok buddy")
									end
									return
								end
							end
							if v:FindFirstChild(player.Name)then
								return
							end
							addCount(player)
							trinkets[v] = nil
							v.Spawned.Value = false
							clicked = true
							commands.AddToInventory(player,trinket)
							trinketmodel:Destroy()
							if connection then
								connection:Disconnect()
								connection = nil
							end
						end
					end)
				end
			end)
		end
	end
end