	local talking = {}
local v1 = require(script.ModuleScript)
local remote = game.ReplicatedStorage.Requests.Dialogue
local dialoguenonpc = game.ReplicatedStorage.Requests.DialogueNoNPC
local commands = require(game.ServerScriptService.Modules.Commands)

local function exit(p1)
	local p2 = p1.Character
	if p2 and talking[p2]then
		if talking[p2].stun then
			talking[p2].stun:Destroy()
		end
		talking[p2] = nil
		remote:FireClient(p1,{exit = true})
	end
end

local function dialogue(p1,v)
	local talk = talking[p1.Character]
	local toreturn = nil
	if talk.npc.Name == nil then
		toreturn = v1[talk.npc].v1(p1,talking[p1.Character])
	else
		if not talk.shopdisplay then
			toreturn = v1[talk.npc.Name].v1(p1,talking[p1.Character])
		else
			toreturn = v1.shop(p1,talk)
		end
	end
	if not toreturn then
		return exit(p1)
	end
	if toreturn.exit then
		exit(p1)
		return
	end
	remote:FireClient(p1,toreturn)
end

local function npcclick(p1,v)
	local p2 = p1.Character
	if not p2 then
		return
	end
	if talking[p2]then
		return
	end
	if p2:FindFirstChild("NoDam")then
		return
	end
	if p2:FindFirstChild("Dialogue")then
		return
	end

	local magmax: number = 16

	if v.Name == "Dungeon Gate" or v.Name == "Dungeon Gate3" or v.Name == "Dungeon Gate2" or v.Name == "MistyGate" or v.Name == "SolanBall" then
		magmax = 50
	end

	if v.Name == "Yeti" then
		magmax = 100
	end

	if (v.HumanoidRootPart.Position-p2.HumanoidRootPart.Position).Magnitude> magmax then
		return
	end
	if v1[v.Name]then
		talking[p2] = {
			npc = v,
			page = 1,
		}
		local v3 = Instance.new("Accessory")
		v3.Name = "Action"
		v3.Parent = p2
		talking[p2].stun = v3
		dialogue(p1)
		if v.HumanoidRootPart:FindFirstChild("Approach")then
			v.HumanoidRootPart.Approach:Play()
		end
	else
		local display = v:FindFirstChild("ShopDisplay")
		if display then
			talking[p2] = {
				npc = v,
				page = 1,
			}
			talking[p2].shopdisplay = display
			local v3 = Instance.new("Accessory")
			v3.Name = "Action"
			v3.Parent = p2
			talking[p2].stun = v3
			dialogue(p1)
		end
	end
end
for _,v in pairs(workspace.NPCs:GetChildren())do
	if v:FindFirstChild("Humanoid")then
		v.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
	local v2 = v:FindFirstChild("ClickDetector",true)
	if v2 then
		v2.MouseClick:Connect(function(p1)
			npcclick(p1,v)
		end)
	end
end
dialoguenonpc.OnServerEvent:Connect(function(p1,p2)
	talking[p1.Character] = {
		npc = p2,
		page = 1,
	}
	if p2 ~= "SpellChange" then
		p1:Kick("Stop exploiting")
	end
	local v3 = Instance.new("Accessory")
	v3.Name = "Action"
	v3.Parent = p1.Character
	talking[p1.Character].stun = v3
	dialogue(p1)
end)
remote.OnServerEvent:Connect(function(p1,p2)
	if not p1.Character then
		return
	end
	if talking[p1.Character] == nil then
		return
	end
	if p1.Character.Parent == workspace.Live or p1.Character.Parent == workspace.Dead then
	else
		return
	end
	if p2.exit then
		exit(p1)
	elseif p2.choice then
		talking[p1.Character].page += 1
		talking[p1.Character].choice = p2.choice
		dialogue(p1)
	end
end)
game.ServerStorage.Requests.DialogueCreate.Event:Connect(function(p1,v)
	local p2 = p1.Character
	if not p2 then
		return
	end
	if talking[p2]then
		return
	end
	if p2:FindFirstChild("NoDam")then
		return
	end
	if p2:FindFirstChild("Dialogue")then
		return
	end

	local magmax: number = 16
	
	if v1[v]then
		talking[p2] = {
			npc = v,
			page = 1,
		}
		local v3 = Instance.new("Accessory")
		v3.Name = "Action"
		v3.Parent = p2
		talking[p2].stun = v3
		dialogue(p1)
	end
end)
game.ServerStorage.Requests.Exit.Event:Connect(function(p)
	exit(p)
end)
local npcanims = game.ServerStorage.NPCAnims
local BreathingIdle = {
	"Dreadhead",
	"Banker",
	"Monster Officer",
	"Merchant",
	"Cedric",
	"Cu",
	"Currin",
	"Dasher",
	"Shero",
	"Draug",
	"Fallion",
	"Ferin",
	"Ferryman",
	"Golis",
	"Grendel",
	"Hendrick",
	"Ishikk",
	"Koris",
	"Kyley",
	"Lab Assistant",
	"Lachesis",
	"Lakelis",
	"Laputa",
	"Luke",
	"Mitch",
	"Pawnbroker",
	"Quinno",
	"Rehagan",
	"Xenyari",
	"Eillie",
	"Dew",
	"Fir",
	"Ghost4",
	"Adralik",
	"Alfric",
	"Chalphy",
	"Dockmaster",
	"Dorgoth",
	"Fungchant",
	"Fungorian",
	"Fungtor",
	"Gharnef",
	"Jagen",
	"Johann",
	"Miner John",
	"Monk",
	"Orodin",
	"Regnier",
	"Renaire",
	"Reneri",
	"Ria",
	"Rita",
	"Sibyl",
	"Silas",
	"Soul Master",
	"Taelin",
	"Tlachta",
	"Vincent"
	
}

local SleepingIdle = {
	"Cosere",
	"Gilderoy",
}

local DocIdle = {
	"Oliver",
	"Isaiah",
	"Mother of Whispers",
	"Dirbys",
	"Doctor",
	"Dorgan",
	"Drake",
	"Eldin",
	"Engineer",
	"Fanari",
	"Vine",
	"Rem",
	"Soma",
	"Mysterious Stranger",
	"Bounty Officer",
	"Frey",
	"Fungkeeper",
	"Gerich",
	"Gurn",
	"Inn Keeper",
	"Dorgza",
	"Jahovan",
	"Fungratia",
	"Therapist"
}

local ChillIdle = {
	"Eil",
	"Eliwood",
	"Eslaf",
	"Ethel",
	"Fabiana",
	"Fang",
	"Feltr",
	"Kai",
	"Kalazar",
	"Knight",
	"Lerase",
	"Naimere",
	"Tiger",
	"Timothy",
	"Wayfinder",
	"Ethan",
	"Rowan",
	"Master Assassin",
	"Aptorgath",
	"Ghost",
	"Ghost2",
	"Charles",
	"Informant",
	"Rorschach",
	"Tanari",
	"Ghost4",
	"Steve"
}


local function NPCAnim(Table , Name: string)
	for i,v in pairs(workspace.NPCs:GetChildren()) do
		if table.find(Table, v.Name) then
			if v:FindFirstChild("Humanoid") then
				v.Humanoid.Animator:LoadAnimation(npcanims[Name]):Play()
			end
		end
	end
end

workspace.Map["Ragash Al'vul"].NPCHumanoid:LoadAnimation(workspace.Map["Ragash Al'vul"].Animation):Play()
workspace.NPCs["Big Hoss"].Humanoid:LoadAnimation(npcanims.Hoss):Play()
workspace.NPCs.Blacksmith.Humanoid:LoadAnimation(npcanims.Blacksmith):Play()
workspace.NPCs.BlacksmithAdvanced.Humanoid:LoadAnimation(npcanims.Blacksmith):Play()
workspace.NPCs.Fabiana.Humanoid:LoadAnimation(npcanims.LeanIdle):Play()
workspace.NPCs.Willow.Humanoid:LoadAnimation(npcanims.Sit):Play()
workspace.NPCs.Dormin.Humanoid:LoadAnimation(npcanims.Sit):Play()
workspace.NPCs.Sain.Humanoid:LoadAnimation(npcanims.Sit):Play()
workspace.NPCs.Nero.Humanoid:LoadAnimation(npcanims.Sit):Play()
workspace.NPCs.Alana.Humanoid:LoadAnimation(npcanims.Sit):Play()
workspace.NPCs.Merrith.Humanoid:LoadAnimation(npcanims.Sit):Play()
workspace.NPCs.Linari.Humanoid:LoadAnimation(npcanims.Sit):Play()
workspace.NPCs.Lilin.Humanoid:LoadAnimation(npcanims.Sit):Play()
workspace.NPCs.Delia.Humanoid:LoadAnimation(npcanims.Sit):Play()
workspace.NPCs.Hespe.Humanoid:LoadAnimation(npcanims.Sit):Play()
workspace.NPCs.Kothe.Humanoid:LoadAnimation(npcanims.Sit):Play()
workspace.NPCs.Loren.Humanoid:LoadAnimation(npcanims.Sit):Play()
workspace.NPCs.Sevier.Humanoid:LoadAnimation(npcanims.Sit):Play()
workspace.NPCs.Jafar.Humanoid:LoadAnimation(npcanims.SitIdle):Play()
workspace.NPCs.Tal.Humanoid:LoadAnimation(npcanims.SitIdle):Play()
workspace.NPCs.TalNew.Humanoid:LoadAnimation(npcanims.SitIdle):Play()
workspace.NPCs["As'endo"].Humanoid:LoadAnimation(npcanims.SitIdle):Play()
workspace.NPCs["Oracle"].Humanoid:LoadAnimation(npcanims.SitIdle):Play()
workspace.NPCs.Ghost3.Humanoid:LoadAnimation(npcanims.SitIdle):Play()
workspace.NPCs.Brom.Humanoid:LoadAnimation(npcanims.SitIdle):Play()
workspace.NPCs.Ezlo.Humanoid:LoadAnimation(npcanims.SitIdle):Play()
workspace.NPCs.Yaalda.Humanoid:LoadAnimation(npcanims.Yaalda):Play()
workspace.NPCs["Baby Yeti"].Humanoid:LoadAnimation(npcanims.BabyYeti):Play()
workspace.NPCs["Yeti"].Humanoid:LoadAnimation(npcanims.Yeti):Play()
workspace.NPCs.Isaac.Humanoid:LoadAnimation(npcanims.Isaac):Play()
workspace.NPCs.Vinifera.Humanoid:LoadAnimation(npcanims.Vinifera):Play()
workspace.NPCs.Enibras.Humanoid:LoadAnimation(npcanims.SitIdle):Play()
workspace.NPCs["Enibras "].Humanoid:LoadAnimation(npcanims.SitIdle):Play()
workspace.NPCs.Frank.Humanoid:LoadAnimation(npcanims.SitIdle):Play()
workspace.NPCs.Fallen.Humanoid:LoadAnimation(npcanims.RestIdle):Play()
workspace.NPCs.Heretic.Humanoid:LoadAnimation(npcanims.RestIdle):Play()
workspace.NPCs["Old Man"].Humanoid:LoadAnimation(npcanims.RestIdle):Play()

NPCAnim(BreathingIdle,"Breathing")
NPCAnim(SleepingIdle,"Sleeping")
NPCAnim(DocIdle,"DocIdle")
NPCAnim(ChillIdle,"LeanIdle")

local stations = {}
local toxvalues = {
	["Dire Flower"] = 4,
	["Crown Flower"] = 15,
	["Lava Flower"] = -6,
	["Tellbloom"] = 7,
	["Blood Thorn"] = 24,
	["Scroom"] = -18,
	["Periashroom"] = 33,
	["Trote"] = -21,
	["Zombie Scroom"] = 36,
	["Glow Shroom"] = 14,
	['Frost Princess'] = 99,
	["Snowshroom"] = 1,
	["Freeleaf"] = 5,
	["Orcher Leaf"] = 11,
	["Moss Plant"] = 2,
	["Potato"] = -5,
	["Polar Plant"] = 9,
	["Canewood"] = 12,
	["Uncanny Tentacle"] = 43,
	["Strange Tentacle"] = -44,
	["Vile Seed"] = 3,
	["Desert Mist"] = -20,
	["Acorn Light"] = 67,
	["Ice Jar"] = 2,
	["Creely"] = 32
}
local colors = {
	["Dire Flower"] = Color3.fromRGB(0, 15, 176),
	["Crown Flower"] = Color3.fromRGB(0, 31, 96),
	["Lava Flower"] = Color3.fromRGB(190, 104, 98),
	["Tellbloom"] = Color3.fromRGB(164, 189, 71),
	["Blood Thorn"] = Color3.fromRGB(0, 31, 96),
	["Scroom"] = Color3.fromRGB(255, 89, 89),
	["Periashroom"] = Color3.fromRGB(91, 154, 75),
	["Trote"] = Color3.fromRGB(177, 167, 255),
	["Zombie Scroom"] = Color3.fromRGB(159, 137, 136),
	["Glow Shroom"] = Color3.fromRGB(0, 255, 255),
	['Frost Princess'] = Color3.fromRGB(255,20,147),
	["Snowshroom"] = Color3.fromRGB(255, 255, 255),
	["Freeleaf"] = Color3.fromRGB(175, 221, 255),
	["Orcher Leaf"] = Color3.fromRGB(218, 133, 65),
	["Moss Plant"] = Color3.fromRGB(177, 167, 255),
	["Potato"] = Color3.fromRGB(159, 137, 136),
	["Polar Plant"] = Color3.fromRGB(233, 218, 218),
	["Canewood"] = Color3.fromRGB(86, 212, 63),
	["Uncanny Tentacle"] = Color3.fromRGB(124, 92, 69),
	["Strange Tentacle"] = Color3.fromRGB(204, 255, 204),
	["Vile Seed"] = Color3.fromRGB(51, 88, 130),
	["Desert Mist"] = Color3.fromRGB(255,255,255),
	["Acorn Light"] = Color3.fromRGB(226, 155, 63),
	["Ice Jar"] = Color3.fromRGB(200, 200, 255),
	["Creely"] = Color3.fromRGB(128, 187, 219)
}

function stationchange()
	for _,v in pairs(workspace.Stations:GetChildren())do
		if v.Name == "SmithingStation" then
			local soundeffect = v.Material.Success
			local soundeffect2 = v.Material.Failure
			v.Contents.Value = ""
			v.Contents.Changed:Connect(function(c)
				if c ~= "" then
					v.Material.ContentsChange:Play()

					local allmats = string.split(c, ",")
					--print("which")
					local chosen = game.ServerStorage.Storage[allmats[#allmats]]
					if chosen:FindFirstChild("Gem") then
						v.Material2.Transparency = 0.2
						v.Material2.BrickColor = game.ServerStorage.Storage[allmats[#allmats]].Handle.BrickColor
						v.Material2.Mesh:Destroy()
						game.ServerStorage.Storage[allmats[#allmats]].Handle.Mesh:Clone().Parent = v.Material2
						v.Material2.Size = game.ServerStorage.Storage[allmats[#allmats]].Handle.Size
					else
						v.Material.BrickColor = game.ServerStorage.Storage[allmats[#allmats].." Bar"].Handle.BrickColor
						v.Material.Transparency = 0
					end
				else
					v.Material.Transparency = 1
					v.Material2.Transparency = 1
				end
			end)
			v.Trash.ClickEmpty.MouseClick:Connect(function(p)
				v.Material.Failure:Play()
				v.Contents.Value = ""
			end)
			v.Hammer.ClickConcoct.MouseClick:Connect(function(p)
				local contents = string.split(v.Contents.Value,",")
				local St = contents[#contents]
				local Item = game.ServerStorage.Storage:FindFirstChild(St)
				if Item and Item:FindFirstChild("Gem") then
					v.Material.Success:Play()
					for i = 1,3 do
						commands.AddToInventory(p, Item.Name.." Shard")
					end
					v.Contents.Value = ""
					return
				end
				local recipes = {
					BronzeSword = {
						name = "Bronze Sword",
						tierneeded = "none",
						"Copper",
						"2xTin",

					},
					BronzeDagger = {
						name = "Bronze Dagger",
						tierneeded = "none",
						"Copper",
						"Tin",

					},
					BronzeSpear = {
						name = "Bronze Spear",
						tierneeded = "none",
						"2xCopper",
						"Tin",
					},
					SteelSword = {
						name = "Steel Sword",
						tierneeded = "IronWeapons",
						"2xIron",
						"Copper",
					},
					SteelDagger = {
						name = "Steel Dagger",
						tierneeded = "IronWeapons",
						"Iron",
						"Copper",
					},
					SteelSpear = {
						name = "Steel Spear",
						tierneeded = "IronWeapons",
						"2xCopper",
						"Iron"
					},
					MythrilSpear = {
						name = "Mythril Spear",
						tierneeded = "MythrilWeapons",
						"2xCopper",
						"Iron",
						"Mythril",
					},
					MythrilDagger = {
						name = "Mythril Dagger",
						tierneeded = "MythrilWeapons",
						"Copper",
						"Iron",
						"Mythril",
					},
					MythrilSword = {
						name = "Mythril Sword",
						tierneeded = "MythrilWeapons",
						"Copper",
						"2xIron",
						"Mythril"
					}
				}
				local numb = 0
				local inside = {}
				for i,v in pairs(contents) do
					if v == "Copper" then
						numb += 1
					end
				end
				if numb > 0 then
					if numb > 1 then
						table.insert(inside, numb.."x".."Copper")
					else
						table.insert(inside, "Copper")
					end
				end
				numb = 0
				for i,v in pairs(contents) do
					if v == "Tin" then
						numb += 1
					end
				end
				if numb > 0 then
					if numb > 1 then
						table.insert(inside, numb.."x".."Tin")
					else
						table.insert(inside, "Tin")
					end
				end
				numb = 0
				for i,v in pairs(contents) do
					if v == "Iron" then
						numb += 1
					end
				end
				if numb > 0 then
					if numb > 1 then
						table.insert(inside, numb.."x".."Iron")
					else
						table.insert(inside, "Iron")
					end
				end
				numb = 0
				for i,v in pairs(contents) do
					if v == "Mythril" then
						numb += 1
					end
				end
				if numb > 0 then
					if numb > 1 then
						table.insert(inside, numb.."x".."Mythril")
					else
						table.insert(inside, "Mythril")
					end
				end
				numb = 0

				v.Contents.Value = ""
				local starts = 0
				for i,v in pairs(recipes) do
					if #v == #inside then

						local start = #v
						for i = 1,#v do
							if table.find(v, inside[i]) then
								start -= 1

							end
						end
						if start == 0 then
							if v.tierneeded ~= "none" then
								if (not game.ServerStorage.PlayerData[p.Name].Skills.Value:find(v.tierneeded)) and not p.Character:FindFirstChild(string.gsub(v.tierneeded, "Weapons", "")) then
									soundeffect2:Play()
									return
								end
							end
							starts = 1
							soundeffect:Play()
							commands.AddToInventory(p, v.name)
							if game.ServerStorage.PlayerData[p.Name].Skills.Value:find("DoubleBars") then
								commands.AddToInventory(p, v.name)
							end

						end

					end
				end
				if starts ~= 1 then
					soundeffect2:Play()
				end
			end)
		end
		--if v.Name == "AlchemyStation"then
			--stations[v] = {started = false}
		--	v.Contents.Value = ""
		--	v.Contents.Changed:Connect(function(c)
		--		if not stations[v].started then
		--			stations[v].started = true
		--			v.Water.Boiling:Play()
		--			v.Water.Bubbles.Enabled = true
		--		end
		--		if c ~= "" then
		--			local contents = string.split(v.Contents.Value,",")
		--			stations[v].upped = math.clamp(#contents-1,1,6)
		--			local color = colors[contents[2]]
		--[[			for _,v in pairs(contents)do
						if colors[v]then
							color = color:lerp(colors[v],0.2)
						end
					end
					game.TweenService:Create(v.Water,TweenInfo.new(0.125),{Color = color}):Play()
					game.TweenService:Create(v.Water.Level,TweenInfo.new(0.125),{Scale = Vector3.new(1,math.clamp(0.125*stations[v].upped,0.1,0.8),1)}):Play()
				end
			end)
			v.Bucket.ClickEmpty.MouseClick:Connect(function(p)
				if v.Contents.Value~=""then
					if (p.Character.PrimaryPart.Position-v.Water.Position).Magnitude<16 then
						game.TweenService:Create(v.Water,TweenInfo.new(0.2),{Color = Color3.fromRGB(8,137,207)}):Play()
						v.Water.Drain:Play()
						v.Contents.Value = ""
						stations[v].upped = 0
						if stations[v].started then
							stations[v].started = false
							v.Water.Boiling:Stop()
							v.Water.Bubbles.Enabled = false
							game.TweenService:Create(v.Water.Level,TweenInfo.new(0.125),{Scale = Vector3.new(1,math.clamp(0.125*stations[v].upped,0.1,0.8),1)}):Play()
						end
					end
				end
			end)
			v.Ladle.ClickConcoct.MouseClick:Connect(function(p)
				if v.Contents.Value~=""then
					if (p.Character.PrimaryPart.Position-v.Water.Position).Magnitude<16 then
						game.TweenService:Create(v.Water,TweenInfo.new(0.2),{Color = Color3.fromRGB(8,137,207)}):Play()
						v.Water.FailSound:Play()
						v.Water.Smoke:Emit(16)
						local contents = string.split(v.Contents.Value,",")
						local ingredientsinside = {}
						for i = 1,#contents do
							ingredientsinside[contents[i] = ingredientsinside[contents[i]and ingredientsinside[contents[i]+1 or 1
						end
						if not  game.ServerStorage.PlayerData[p.Name].Skills.Value:find("PoisonMastery") then
							if ingredientsinside["Scroom"]and ingredientsinside["Scroom"]==2 and ingredientsinside["Lava Flower"]and ingredientsinside["Lava Flower"]==1 then
								commands.AddToInventory(p,"Health Potion")
								if game.ServerStorage.PlayerData[p.Name].Skills.Value:find("Potion Efficiency") then
									commands.AddToInventory(p,"Health Potion")
								end
							elseif ingredientsinside["Scroom"]and ingredientsinside["Scroom"]==1 and ingredientsinside["Moss Plant"] and ingredientsinside["Moss Plant"] == 2 and ingredientsinside["Lava Flower"]==1 then
								commands.AddToInventory(p,"Tespian Elixir")
								if game.ServerStorage.PlayerData[p.Name].Skills.Value:find("Potion Efficiency") then
									commands.AddToInventory(p,"Tespian Elixir")
								end
							elseif ingredientsinside["Desert Mist"]and ingredientsinside["Freeleaf"]==1 and ingredientsinside["Polar Plant"] then
								commands.AddToInventory(p,"Money Sun")
								if game.ServerStorage.PlayerData[p.Name].Skills.Value:find("Potion Efficiency") then
									commands.AddToInventory(p,"Money Sun")
								end
							elseif ingredientsinside["Crown Flower"]and ingredientsinside["Crown Flower"]==3 then
								commands.AddToInventory(p,"Lordsbane")
								if game.ServerStorage.PlayerData[p.Name].Skills.Value:find("Potion Efficiency") then
									commands.AddToInventory(p,"Lordsbane")
								end
							elseif ingredientsinside["Dire Flower"]and ingredientsinside["Polar Plant"]==1 then
								commands.AddToInventory(p,"Feather Feet")
								if game.ServerStorage.PlayerData[p.Name].Skills.Value:find("Potion Efficiency") then
									commands.AddToInventory(p,"Feather Feet")
								end
							elseif ingredientsinside["Dire Flower"]and ingredientsinside["Glow Shroom"]==2 then
								commands.AddToInventory(p,"Switch Witch")
								if game.ServerStorage.PlayerData[p.Name].Skills.Value:find("Potion Efficiency") then
									commands.AddToInventory(p,"Switch Witch")
								end
							end
						else
							local totalpoison = 0
							local mode = nil
							local failedpoison = false
							if #contents > 5 or #contents < 3 then
								failedpoison = true
							end
							for i = 1,#contents do
								if contents[i] and toxvalues[contents[i] then
									totalpoison += toxvalues[contents[i]
								end
							end
							if totalpoison > 0 and totalpoison <= 100 then
								mode = "poison"
							elseif totalpoison < 0 then
								mode = "cure"
							elseif totalpoison > 100 then
								if p.Name ~= "FireFlare100" and p.Name ~= "FungardLineage" then
									mode = "explode"
								else
									mode = "poison"
								end
							elseif totalpoison == 0 then
								mode = "perfection"
							end
							if failedpoison then
								mode = "explode"
							end
							local poisonvalues = {}
							if mode ~= nil then
								if mode == "poison" then
									for i,v in pairs(game.ServerStorage.Storage:GetChildren()) do
										if v:FindFirstChild("PoisonValue") then
											table.insert(poisonvalues, v.PoisonValue.Value)
										end
									end
									local chosenpoison = 0
									for i = 1,#poisonvalues do
										if totalpoison >= poisonvalues[i] and chosenpoison == 0 then
											chosenpoison = poisonvalues[i]
										elseif chosenpoison > 0 and totalpoison > chosenpoison and totalpoison >= poisonvalues[i] then
											chosenpoison = poisonvalues[i]
										end
									end

									for i,v in pairs(game.ServerStorage.Storage:GetChildren()) do
										if v:FindFirstChild("PoisonValue") and v.PoisonValue.Value == chosenpoison and not string.find(v.Name, "Cure") then
											chosenpoison = v
										end
									end
									if tostring(chosenpoison) then
										commands.AddToInventory(p, chosenpoison.Name)
										if game.ServerStorage.PlayerData[p.Name].Skills.Value:find("AdvancedPoisons") then
											commands.AddToInventory(p, chosenpoison.Name)
										end
									end
								elseif mode == "explode" then
									game.ServerStorage.Requests.TagHumanoid:Fire(p.Character, p.Character, {damage = 25, strongknockback = true, mana = true})
								elseif mode == "cure" then
									totalpoison = -totalpoison
									local chosenpot = 0
									for i,v in pairs(game.ServerStorage.Storage:GetChildren()) do
										if string.find(v.Name, "Cure") and totalpoison >= v.PoisonValue.Value and chosenpot <= 0 then
											chosenpot = v.PoisonValue.Value
										elseif string.find(v.Name, "Cure") and totalpoison >= v.PoisonValue.Value and chosenpot > 0 and totalpoison > chosenpot then
											chosenpot = v.PoisonValue.Value
										end
									end
									if chosenpot > 0 then
										for i,v in pairs(game.ServerStorage.Storage:GetChildren()) do
											if string.find(v.Name, "Cure") and v.PoisonValue.Value == chosenpot then
												chosenpot = v
											end
										end
									end
									if tostring(chosenpot) then
										commands.AddToInventory(p, chosenpot.Name)
										if game.ServerStorage.PlayerData[p.Name].Skills.Value:find("AdvancedPoisons") then
											commands.AddToInventory(p, chosenpot.Name)
										end
									end
								elseif mode == "perfection" then
									commands.AddToInventory(p, "Potion of Life")
									if game.ServerStorage.PlayerData[p.Name].Skills.Value:find("AdvancedPoisons") then
										commands.AddToInventory(p, "Potion of Life")
									end
								end

							end
						end
						v.Contents.Value = ""
						stations[v].upped = 0
						if stations[v].started then
							stations[v].started = false
							v.Water.Boiling:Stop()
							v.Water.Bubbles.Enabled = false
							game.TweenService:Create(v.Water.Level,TweenInfo.new(0.125),{Scale = Vector3.new(1,math.clamp(0.125*stations[v].upped,0.1,0.8),1)}):Play()
						end
					end
				end
			end)
		end]]
	end
end

stationchange()
workspace.Stations.ChildAdded:Connect(function()
	stationchange()
end)