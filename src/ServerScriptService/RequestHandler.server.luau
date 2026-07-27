local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Collection = game:GetService("CollectionService")
local BanStore = game:GetService("DataStoreService"):GetDataStore('BanUsers', 1)

local ServerRequests = ServerStorage.Requests
local Requests = ReplicatedStorage.Requests
local TagHumanoid = ServerStorage.Requests.TagHumanoid
--local dangerHandler = require(ServerScriptService.DangerHandler)
--local DataStore2 = require(ServerScriptService.DataStore2)


local RNG = Random.new()

--local NameGenerator = require(ReplicatedStorage.Info.NameGenerator)
--local RaceGenerator = require(ServerScriptService.RaceGenerator)
--local FaceGenerator = require(ServerScriptService.FaceGenerator)
--local SpawnGenerator = require(ServerScriptService.SpawnGenerator)
local HookedAlready = {}

local alchemyFolder = ServerStorage.Alchemy
local list_ingredients = require(ServerScriptService.Alchemy.list_alchemy)

local ingredientProps = list_ingredients.ingredients
local potionRecipes = list_ingredients.recipes

local EventHooks = {
	--["UpdateLogs"] = "https://hooks.hyra.io/api/webhooks/1038282031584526376/IVYt4QXEqjqnAFRjdeRa4C4JZsggq_rOtciYHBVZ0HzsSDhld9wLFNTRpSXF9KqiYP2T",
	--["Critical"] = "https://hooks.hyra.io/api/webhooks/1038319633817677835/O4lyf85YTlam7xkZStH1x28hzXUMVYGwVumLf33h6LNR2WMcHvOWVA-dl4luXz0xgKbS",

	--["Bans"] = "https://hooks.hyra.io/api/webhooks/1038320393049620544/fEO34UZdgAKq7ctXph0LGkgWObNfu1kAVa7LpyFLkVZq7P0CwHm2_Sqa9o_DY7hRvo0y",
	--["Restores"] = "https://hooks.hyra.io/api/webhooks/1038320306667933736/KEjEBcqVjPoq3H0rdogFebJyo3FDy_3ieKLq8Y2zUwt-8-UZZ2HRl_CdRKWgf6huNQso",
	--["Unbans"] = "https://hooks.hyra.io/api/webhooks/1038320449530105917/VI5-Jxp7hnYg1LX3KjwyCacxUDX1Sc74mK1ZalFyosQDvwrIgLCjfyYQ8XmW2j1VgNva",
	--["Admin"] = "https://hooks.hyra.io/api/webhooks/1078770350059438080/0Va22IiYOP1LYqpfXqxJwwhhNdodyUJfCs3W1AQABFjJDqnh0kAPfDfwZ7TZBziANKde",
}


local DoorCooldowns = {}

ServerStorage.Debris.Event:Connect(function(obj, t)
	task.delay(t, game.Destroy, obj)
end)

--[[
ServerStorage.Requests.GiveSkill.OnInvoke = function(plr, name, donteffect)
	if not ServerStorage.PlayerData:FindFirstChild(plr.Name) then
		return
	end

	if not donteffect then
		task.spawn(function()
			plr.Character.HumanoidRootPart.Learn:Play()

			local LearnEffect = game.ServerStorage.Assets.Learn.Attachment:Clone()
			LearnEffect.Parent = plr.Character.Head
			LearnEffect.ParticleEmitter:Emit(15)
			ServerStorage.Debris:Fire(LearnEffect, 1.5)
		end)
	end

	local skills = ServerStorage.PlayerData[plr.Name].Data.Skills
	local data = HttpService:JSONDecode(skills.Value)
	if not table.find(data, name) then
		table.insert(data, name)
	end
	skills.Value = HttpService:JSONEncode(data)
end

ServerStorage.Requests.GiveSpell.OnInvoke = function(plr, name, donteffect)
	if not ServerStorage.PlayerData:FindFirstChild(plr.Name) then
		return
	end

	if not donteffect then
		task.spawn(function()
			plr.Character.HumanoidRootPart.Learn:Play()

			local LearnEffect = game.ServerStorage.Assets.Learn.Attachment:Clone()
			LearnEffect.Parent = plr.Character.Head
			LearnEffect.ParticleEmitter:Emit(15)
			ServerStorage.Debris:Fire(LearnEffect, 1.5)
		end)
	end

	local spells = ServerStorage.PlayerData[plr.Name].Data.Spells
	local data = HttpService:JSONDecode(spells.Value)
	if not table.find(data, name) then
		table.insert(data, name)
	end
	spells.Value = HttpService:JSONEncode(data)
end

ServerStorage.Requests.RemoveSkill.Event:Connect(function(plr, name)
	if not ServerStorage.PlayerData:FindFirstChild(plr.Name) then
		return
	end

	local skills = ServerStorage.PlayerData[plr.Name].Data.Skills
	local data = HttpService:JSONDecode(skills.Value)
	for i,v in next, data do
		if v == name then
			table.remove(data, i)
		end
	end
	skills.Value = HttpService:JSONEncode(data)
end)

ServerStorage.Requests.GiveSnap.Event:Connect(function(plr, name)
	if not ServerStorage.PlayerData:FindFirstChild(plr.Name) or name == "" then
		return
	end
	local snaps = ServerStorage.PlayerData[plr.Name].Data.UpgradedSpells
	local data = HttpService:JSONDecode(snaps.Value)
	if not data[name] then
		data[name] = true
	end
	snaps.Value = HttpService:JSONEncode(data)
	print(snaps.Value, HttpService:JSONEncode(data))
end)
]]
local FixedInjuries = {
	["brokenleg"] = "BrokenLeg",
	["brokenarm"] = "BrokenArm"
}

local mentalInjuries = {
	fearful=true,
	careless=true,
	maniacal=true,
	hallucinations=true,
}

local gaianInjuries = {
	brokenarm = true,
	brokenleg = true,
	brokenrib = true,
	armless = true,
	legless = true,
	burn = true,
	frostbite = true,
}

local lichInjuries = {
	brokenarm = true,
	brokenleg = true,
	brokenrib = true,
	armless = true,
	legless = true,
	automailarm = true,
}

local scroomImmune = {
	brokenleg = true,
	brokenrib = true,
	brokenarm = true,
	dizzy = true,
}

local novampRaces = {
	Scroom = true,
	Metascroom = true,
	Gaian = true,
	Azael = true,
	Vind = true,
	Dullahan = true,
	Fischeran = true,
	Lich = true,
	Seraph = true,
	Cameo = true,
	Howler = true,
	Phoenix = true,
}


local function Injure(plr, injury, bypassCooldown, bypassImmunity)
	if not ServerStorage.PlayerData:FindFirstChild(plr.Name) then
		return
	end

	local Injury = FixedInjuries[injury] or injury
	local Character = plr.Character
	local Data = ServerStorage.PlayerData[Character.Name]
	local race = Data.Race.Value
	
	if injury == "vampirism" and (race == "Cameo" or race == "Seraph") then
		return false,"Immune to injury."
		-- cameos and seraphs cannot EVER be vampires
	end

	if not bypassImmunity then
		if injury == "vampirism" and novampRaces[race] then
			return false,"Immune to injury."
		end

		if race == "Scroom" and scroomImmune[injury:lower()] then
			return false,"Immune to injury."
		end

		if (race == "Gaian" or race == "Metascroom") and not gaianInjuries[injury:lower()] then
			return false,"Immune to injury."
		end

		if race == "Lich" and not lichInjuries[injury:lower()] then
			return false,"Immune to injury."
		end

		-- Checked against server-only Data (PlayerData) instead of plr.Backpack - Backpack is
		-- replicated to the owning client, so a spoofed "MentalBlock" Instance there would be
		-- trusted the same way a spoofed Character Instance would.
		if mentalInjuries[injury] and Data.Skills.Value:find("MentalBlock") then
			return false,"Injury mentally blocked."
		end
	end
	
	if Character:FindFirstChild("InjuryCooldown") and not bypassCooldown then return end
	if Injury == "dizzy" and (Data.Race.Value == "Metascroom" or Data.Race.Value == "Gaian") then
		return
	end

	if (Injury == "rib cage" or Injury == "leg") and Data.Race.Value == "Scroom" then
		return
	end

	if Data.Injuries.Value:match(Injury) then
		return
	end

	if Injury == "leg" and (Data.Race.Value == "Cameo" or Data.Race.Value == "Scroom") then
		return
	end

	if Character:FindFirstChild("InjuryCooldown") then
		return
	end

	if not bypassCooldown then
		local InjuryCooldown = Instance.new("Accessory")
		InjuryCooldown.Name = "InjuryCooldown"
		InjuryCooldown.Parent = Character
		ServerStorage.Debris:Fire(InjuryCooldown, 30)
	end

	local InjureEffect = game.ReplicatedStorage.Assets.Injure:Clone()

	InjureEffect.Name = "InjureEffect"
	Character.HumanoidRootPart.Injury:Play()
	InjureEffect.Parent = Character.HumanoidRootPart
	InjureEffect:Emit(1)

	ServerStorage.Debris:Fire(InjureEffect, 1.5)

	if #Data.Injuries.Value == 0 then Data.Injuries.Value = "[]" end

	local Injuries = HttpService:JSONDecode(Data.Injuries.Value)
	table.insert(Injuries, Injury)
	Data.Injuries.Value = HttpService:JSONEncode(Injuries)
end


ServerStorage.Requests.Injure.OnInvoke = function(plr, value)
	if typeof(value) == "table" then
		return Injure(plr, value[math.random(1, #value)])
	else
		return Injure(plr, value)
	end
end

Requests.UpdateSlotData.OnServerEvent:Connect(function(Player, NewData)
	local PlayerData = ServerStorage.PlayerData:FindFirstChild(Player.Name)

	if NewData and typeof(NewData) == "table" then
		PlayerData.SlotData.Value = HttpService:JSONEncode(NewData)
	end
end)

Requests.Get.OnServerInvoke = function(plr, key, ...)
	local PlayerData = ServerStorage.PlayerData:FindFirstChild(plr.Name)
	local TargetValues = {"LastName", "FirstName", "ManaColor", "Lives", "SlotData", "Money", "DaysSurvived", "Race", "HouseRank", "Gender", "Insight", "UberTitle", "SpecMeta"}
	local Return = {}

	for _, Target in next, TargetValues do
		Return[Target] = PlayerData[Target].Value
	end

	return Return
end

--[[

ServerStorage.Requests.HasSkill.OnInvoke = function(Player, SkillName)
	if not ServerStorage.PlayerData:FindFirstChild(Player.Name) then
		return
	end

	local Skills = HttpService:JSONDecode(ServerStorage.PlayerData[Player.Name].Data.Skills.Value)
	local HasSkill = false

	for _,Skill in next, Skills do
		if Skill == SkillName then
			HasSkill = true
			break
		end
	end

	return HasSkill
end

ServerStorage.Requests.BanPlayer.Event:Connect(function(Player, Info, Mod)
	if HookedAlready[Player] then return end
	HookedAlready[Player] = true
	local IncidentID = HttpService:GenerateGUID(false):sub(1,8)
	local PlayerData = ServerStorage.PlayerData:FindFirstChild(Player.Name)
	
	if Player.Character then
		Instance.new("Accessory", Player.Character).Name = "NoCombatLog"
		Player.Character:BreakJoints()
		task.wait(0.3)
	end

	ServerStorage.Requests.Webhook:Fire("Bans", ("%s was banned from the game [%s] **(%s)**\n\nIncident: [%s]"):format(Player.Name, Mod and "Mod" or "Anticheat", tostring(Info), IncidentID), true)
	local reason = ("You have been banned from this game [%s]          | Incident ID: %s"):format(Mod and "Mod" or "Anticheat", IncidentID)
	local banned = HttpService:JSONEncode({reason = reason, info = tostring(Info)})
	if PlayerData then
		PlayerData.banned.Value = banned
	end
	
	Player:Kick(reason)
end)

local actionCheckList = { 'NoAttack', 'Charge', 'Stun', 'ReturnStun', 'Action', 'Blocking', 'SpellBlocking', 'HeavyAttack', 'LightAttack' }
ServerStorage.Requests.ActionCheck.OnInvoke = function(Character, ...)
	local List = ...
	if List then
		List = {...}
	end

	if not Character:FindFirstChild("Humanoid") then
		return true
	end
	for i = 1, #actionCheckList do
		if List then
			if table.find(List, actionCheckList[i]) and Character:FindFirstChild(actionCheckList[i]) then
				return true
			end
		elseif Character:FindFirstChild(actionCheckList[i]) then
			return true
		end
	end
	if game.CollectionService:HasTag(Character, "Unconscious") then
		return true
	end
	if game.CollectionService:HasTag(Character, "Knocked") then
		return true
	end
end

ReplicatedStorage.Requests.Tango.OnServerEvent:Connect(function(Player, Info, Script)
	if typeof(Info) == "table" and tonumber(Info[1]) then
		return
	end

	ServerStorage.Requests.BanPlayer:Fire(Player, typeof(Info) == "table" and Info[1] or "???")
end)

Requests.SetCurrentArea.OnServerEvent:Connect(function(Player, Area)
	local TempData = ServerStorage.PlayerData:FindFirstChild(Player.Name).Temp
	TempData.CurrentArea.Value = Area
end)

Requests.UpdateSlotData.OnServerEvent:Connect(function(Player, NewData)
	local PlayerData = ServerStorage.PlayerData:FindFirstChild(Player.Name).Data

	if NewData and typeof(NewData) == "table" then
		PlayerData.SlotData.Value = HttpService:JSONEncode(NewData)
	end
end)

Requests.BardError.OnServerEvent:Connect(function(plr)
	if not plr.Character then 
		return 
	end

	local char = plr.Character
	if char:FindFirstChild("BardError") then return end
	local err = Instance.new("Folder")
	err.Name = "BardError"
	err.Parent = char
	ServerStorage.Debris:Fire(err, 10)
end)

Requests.BardStreak.OnServerEvent:Connect(function(plr, amount)
	if not plr.Character then 
		return 
	end

	local char = plr.Character
	if not char:FindFirstChild("MusicMeter") then return end
	if game.CollectionService:HasTag(char, "MusicStreakCD") then return end
	if amount > 40 then return end

	Collection:AddTag(char,"MusicStreakCD") 
	char.MusicMeter.Value = char.MusicMeter.Value + amount

	wait(4.99)
	Collection:RemoveTag(char, "MusicStreakCD") 
end)

ServerStorage.Requests.GetStoryMarker.OnInvoke = function(Player, Marker)
	local PlayerData = ServerStorage.PlayerData:FindFirstChild(Player.Name).Data
	local StoryMarkers = HttpService:JSONDecode(PlayerData.StoryMarkers.Value)

	return StoryMarkers[Marker]
end

ServerStorage.Requests.SetStoryMarker.OnInvoke = function(Player, Marker, Value)
	local PlayerData = ServerStorage.PlayerData:FindFirstChild(Player.Name).Data
	local StoryMarkers = HttpService:JSONDecode(PlayerData.StoryMarkers.Value)

	StoryMarkers[Marker] = Value
	PlayerData.StoryMarkers.Value = HttpService:JSONEncode(StoryMarkers)

	if Marker == "NecroBounds_Shrieker" then
		local Tool = Player.Character:FindFirstChild("Vocare") or Player.Backpack:FindFirstChild("Vocare")
		if Tool then
			if Tool:FindFirstChild("Quantity") then
				print(Value)
				Tool.Quantity.Value = Value
			end
		end
	end
end

ServerStorage.Requests.Wakeup.Event:Connect(function(Character, FullWakeup)
	if Character:FindFirstChild("Knocked") then
		Character.Knocked:Destroy()
	end
	local Tag = Instance.new("Accessory", Character)
	Tag.Name = "WAKEUP"
	ServerStorage.Debris:Fire(Tag, 1)
end)

ServerStorage.Requests.ClassCheck.OnInvoke = function(ClassType, Class, LastClass, PlayerData)
	if (ClassType == "SuperClass" and #PlayerData.UltraClass.Value == 0 or (ClassType == "UltraClass" and PlayerData.SuperClass.Value == LastClass and #PlayerData.HybridClass.Value == 0)) and ((
		(ClassType == "SuperClass" and PlayerData.HybridClass.Value == Class) or PlayerData[ClassType].Value == Class) or (
		(ClassType == "SuperClass" and #PlayerData.HybridClass.Value == 0) or #PlayerData[ClassType].Value == 0)) then
		return true
	end
end

ServerStorage.Requests.Knock.Event:Connect(function(Character, Span, FullKnock)
	local hum = Character:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	
	if Character:FindFirstChild("CustomRig") then
		if FullKnock then
			return hum:TakeDamage(99999) -- custom rig mobs don't get knocked, just kill em
		else
			return
		end
	end
	
	if FullKnock then
		local Old = hum.Health
		hum.Health = 1 -- lazy way of making the character unconscious
		hum.Health = Old

		if Span then
			task.wait(Span)
			local Tag = Instance.new("Accessory")
			Tag.Name = "WAKEUP"
			Tag.Parent = Character
			ServerStorage.Debris:Fire(Tag, 1)
		end
	else
		local Tag = Instance.new("Accessory")
		Tag.Name = "Knocked"
		Tag.Parent = Character
		ServerStorage.Debris:Fire(Tag, Span)
	end
end)

local defaultArmors = { 'BlueAdventurer', 'BlueTunic', 'GreenAdventurer', 'GreenTunic', 'RedAdventuruer', 'RedTunic' }

ServerStorage.Requests.Wipe.Event:Connect(function(player, gender, rerollRace, setRace)
	local playerData = ServerStorage.PlayerData[player.Name].Data
	local raceData
	local face
	local spawnLocation = SpawnGenerator()

	for _, val in next, ServerStorage.DataTemplate.Data:GetChildren() do
		if val.Name ~= "HouseRank" and val.Name ~= "LastName" and val.Name ~= "Race" and val.Name ~= "Banked" then
			playerData[val.Name].Value = val.Value
		end
	end

	local changeName = true
	if setRace == "Seraph" and gender == playerData.Gender.Value then
		changeName = false
	end

	if setRace then
		raceData = RaceGenerator(setRace)
		playerData.Race.Value = setRace
	elseif playerData.Race.Value == "Cameo" or rerollRace then
		repeat 
			raceData = RaceGenerator()
		until raceData.Race ~= playerData.Race.Value

		playerData.Race.Value = raceData.Race
	else
		raceData = RaceGenerator(playerData.Race.Value)
	end

	face = FaceGenerator(raceData.Race)
	playerData.Face.Value = face
	playerData.ManaColor.Value = Color3.new(math.random(),math.random(),math.random())
	playerData.RaceVariant.Value = raceData.Variant
	playerData.Gender.Value = gender
	playerData.SpawnLocation.Value = spawnLocation

	if changeName then
		playerData.FirstName.Value = NameGenerator:FirstName({ race = raceData.Race, gender = gender })
		playerData.AltName.Value = NameGenerator:FirstName({ race = raceData.Race, gender = gender == "Male" and "Female" or "Male" })
	end

	playerData.Outfit.Value =
		playerData.Race.Value == 'Morvid' and 'Rags' or
		playerData.Race.Value == 'Gaian' and 'GaianDefault' or
		playerData.Race.Value == 'Scroom' and 'ScroomDefault' or
		defaultArmors[math.random(1, #defaultArmors)]

	playerData.Lives.Value =
		playerData.Race.Value == 'Kasparan' and 4 or
		playerData.Race.Value == 'Azael' and 2 or 3

	player:LoadCharacter()
end)

ServerStorage.Requests.Webhook.Event:Connect(function(Hook, ToPost, Embed, HideExtra)
	if Embed ~= false then -- argument wasnt entered
		Embed = true
	end
	
	if Hook == "Critical" then
		Embed = false
		ToPost = "<@251545092983226370> " .. ToPost
	end

	if Embed then
		local Data = {
			title = HideExtra and "" or Hook,
			description = tostring(ToPost),
			color = 0x2274a5,
		}

		HttpService:PostAsync(EventHooks[Hook], HttpService:JSONEncode({content = "",embeds = {Data}}))
	else
		--HttpService:PostAsync(EventHooks[Hook], HttpService:JSONEncode({content = ToPost}))
	end
end)

ServerStorage.Requests.SetCollisionGroup.Event:Connect(function(Character, Group)
	for _, Part in next, Character:GetChildren() do
		if Part:IsA("BasePart") then  
			game:GetService("PhysicsService"):SetPartCollisionGroup(Part, Group)
		end
	end
end)

local toolHandler = require(game.ServerScriptService.ToolHandler)
local dropCd = {}
local drops = {}
local dropped = {}

local MAX_PLAYERS_DROP = 5 -- max amount of bags that can be dropped at once by a player
local MAX_SAME_ARTIFACT = 15 -- max amount of the same artifact you can have
local SILVER_DROP_LIMIT = 5000

ReplicatedStorage.Requests.PlaceTool.OnServerInvoke = function(pl,tool)
	if typeof(tool) ~= "Instance" then
		return ServerStorage.Requests.BanPlayer:Fire(pl, "tried to pass a non instance on PlaceTool")
	end
	
	if tool.Parent ~= pl.Backpack and tool.Parent ~= pl.Character then
		return ServerStorage.Requests.BanPlayer:Fire(pl, "tried to drop another persons tool: " .. tool:GetFullName())
	end
	
	if not tool:IsA("Tool") then
		return ServerStorage.Requests.BanPlayer:Fire(pl, "tried to drop a non tool: " .. tool:GetFullName())
	end
	
	if dropped[tool] then return end
	if dropCd[pl] then return end
	dropCd[pl] = true
	dropped[tool] = true
	if not drops[pl.UserId] then
		drops[pl.UserId] = 0
	end

	if (drops[pl.UserId] + 1) > MAX_PLAYERS_DROP then
		dropCd[pl] = nil
		dropped[tool] = nil
		
		return
	end

	print("pt",tool)
	if not pl.Parent then return end
	if not tool or typeof(tool) ~= "Instance" or not tool:IsA("Tool") then return end
	if not tool:FindFirstChild("Droppable") or not tool:FindFirstChild("Handle") then return end	
	local toolName = tool:GetAttribute("ToolName")
	if not toolName then toolName = tool.Name end
	if tool:FindFirstChild("DONOTGIVE") then return end
	local toolRef = ServerStorage.Items:FindFirstChild(toolName)
	if not toolRef or not toolRef:FindFirstChild("Droppable") then
		dropCd[pl] = nil
		dropped[tool] = nil
		return -- toolRef doesn't exist or isn't droppable
	end

	local tag = Instance.new("Accessory")
	tag.Name = "DONOTGIVE"
	tag.Parent = tool

	local char = pl.Character
	local torso = char.Torso
	local hum = char.Humanoid

	local stCF = torso.CFrame
	local igtab = {workspace.Thrown,workspace.Live,workspace.Terrain}

	local placeLoc
	do
		for y = -1,1,2 do
			local cf = stCF*CFrame.new(3,0,y*5)
			local lcf = CFrame.new(stCF.p,cf.p)
			local ray = Ray.new(stCF.p,lcf.lookVector*5)
			local hit = workspace:FindPartOnRayWithIgnoreList(ray,igtab)
			if not hit then
				placeLoc = cf.p
				break
			end
		end

		if not placeLoc then
			for x = -1,1,2 do
				local cf = stCF*CFrame.new(x*5,0,0)
				local lcf = CFrame.new(stCF.p,cf.p)
				local ray = Ray.new(stCF.p,lcf.lookVector*5)
				local hit = workspace:FindPartOnRayWithIgnoreList(ray,igtab)
				if not hit then
					placeLoc = cf.p
					break
				end
			end
		end
	end

	if not placeLoc then
		dropCd[pl] = nil
		dropped[tool] = nil
		return tag:Destroy()
	end


	if not pl or not pl.Parent then return end

	local charDanger = dangerHandler:getEntity(char)
	if charDanger then
		charDanger:createTag(".ToolDrop",{lifespan=10})
	end

	local dray = Ray.new(placeLoc,Vector3.new(0,-6,0))
	local dhit,dpos = workspace:FindPartOnRayWithIgnoreList(dray,igtab)

	local mBag = game.ServerStorage.Assets.ToolBag:clone()
	mBag.Transparency = 0.5
	mBag.BillboardGui.Tool.Text = tool.Name
	mBag.Parent = workspace.Thrown
	mBag.CFrame = CFrame.new(placeLoc)

	if dhit and dpos then
		mBag.Anchored = true
		mBag.CanCollide = false
		mBag.CFrame = CFrame.new(dpos+Vector3.new(0,mBag.Size.y/2,0))
	end

	if mBag:CanSetNetworkOwnership() then
		mBag:SetNetworkOwner(nil)
	end

	game.PhysicsService:SetPartCollisionGroup(mBag,"WalkThrough")

	local toolName = tool.Name
	toolHandler.RemoveTool(pl, tool)

	drops[pl.UserId] += 1

	local given = false
	Instance.new("Accessory", mBag).Name = pl.Name
	mBag.Touched:Connect(function(part)
		if not mBag then return end
		if given then return end
		if mBag.Transparency ~= 0 then return end

		if not pl.Parent then return end

		if hum.Health <= 0 or not char.Parent then return end

		local newhum = part.Parent:FindFirstChild("Humanoid") or part.Parent.Parent:FindFirstChild("Humanoid")
		local newchar = newhum and newhum.Parent
		local hrp = newchar and newchar:FindFirstChild("HumanoidRootPart")
		if not newhum or not newchar or not hrp then return end

		local pickPl = game.Players:GetPlayerFromCharacter(newhum.Parent)
		local pickChar = pickPl and pickPl.Character
		local pickFolder = pickChar and game.ServerStorage.PlayerData:FindFirstChild(pickPl.Name)
		local pickBackpack = pickFolder and pickPl:FindFirstChild("Backpack")
		if not pickBackpack then return end

		local ref = ServerStorage.Items:FindFirstChild(toolName)
		if not ref then return end

		if ref:FindFirstChild("Bankable") or ref.Name == "Phoenix Down" then
			local sameArti = 0
			if pickChar:FindFirstChild(toolName) then
				sameArti +=1
			end
			for _,v in next, pickBackpack:GetChildren() do
				if v.Name == toolName then
					sameArti += 1
				end
			end

			if sameArti > MAX_SAME_ARTIFACT then
				return
			end
		end

		if pickFolder.Data.Lives.Value <= 0 then return end

		local isArtifact = toolRef:FindFirstChild("Bankable")

		local mag = (mBag.Position-hrp.Position).magnitude
		if mag > 100 then
			return print(pickPl,"tried to pick up bag from 100< studs")
		end

		if tool.Parent then return end
		if mBag then
			mBag:Destroy()
			mBag = nil
		end

		given = true
		drops[pl.UserId] -= 1

		if ingredientProps[toolName] or ServerStorage.Alchemy.Tools:FindFirstChild(toolName) then
			toolHandler.GiveAlchemy(pickPl, toolName, ingredientProps[toolName])
		else
			toolHandler.GiveTool(pickPl, toolName)
		end
	end)

	task.wait(1)
	mBag.Transparency = 0
	dropCd[pl] = nil
end

ReplicatedStorage.Requests.PlaceMoney.OnServerInvoke = function(pl,amt)
	local plData = ServerStorage.PlayerData[pl.Name].Data
	
	if not amt or type(amt) ~= 'number' then return end
	amt = math.floor(amt)
	amt = math.clamp(amt,0,SILVER_DROP_LIMIT)
	if amt == tonumber("NaN") or 0 >= amt or amt > plData.Silver.Value or amt >= math.huge then return end

	if dropCd[pl] then return end
	dropCd[pl] = true
	if not drops[pl.UserId] then
		drops[pl.UserId] = 0
	end

	if (drops[pl.UserId] + 1) > MAX_PLAYERS_DROP then
		return
	end

	print("pm",amt)
	if not pl.Parent then return end


	local char = pl.Character
	local torso = char.Torso
	local hum = char.Humanoid

	local stCF = torso.CFrame
	local igtab = {workspace.Thrown,workspace.Live,workspace.Terrain}

	local placeLoc
	do
		for y = -1,1,2 do
			local cf = stCF*CFrame.new(3,0,y*5)
			local lcf = CFrame.new(stCF.p,cf.p)
			local ray = Ray.new(stCF.p,lcf.lookVector*5)
			local hit = workspace:FindPartOnRayWithIgnoreList(ray,igtab)
			if not hit then
				placeLoc = cf.p
				break
			end
		end

		if not placeLoc then
			for x = -1,1,2 do
				local cf = stCF*CFrame.new(x*5,0,0)
				local lcf = CFrame.new(stCF.p,cf.p)
				local ray = Ray.new(stCF.p,lcf.lookVector*5)
				local hit = workspace:FindPartOnRayWithIgnoreList(ray,igtab)
				if not hit then
					placeLoc = cf.p
					break
				end
			end
		end
	end

	if not placeLoc then
		dropCd[pl] = nil
		return
	end

	
	plData.Silver.Value -= amt
	if not pl or not pl.Parent then return end

	local charDanger = dangerHandler:getEntity(char)
	if charDanger then
		charDanger:createTag(".ToolDrop",{lifespan=10})
	end

	local dray = Ray.new(placeLoc,Vector3.new(0,-6,0))
	local dhit,dpos = workspace:FindPartOnRayWithIgnoreList(dray,igtab)

	local mBag = game.ServerStorage.Assets.ToolBag:clone()
	mBag.Transparency = 0.5
	mBag.BillboardGui.Tool.Text = tostring(amt)
	mBag.Parent = workspace.Thrown
	mBag.CFrame = CFrame.new(placeLoc)

	if dhit and dpos then
		mBag.Anchored = true
		mBag.CanCollide = false
		mBag.CFrame = CFrame.new(dpos+Vector3.new(0,mBag.Size.y/2,0))
	end

	if mBag:CanSetNetworkOwnership() then
		mBag:SetNetworkOwner(nil)
	end

	game.PhysicsService:SetPartCollisionGroup(mBag,"WalkThrough")

	drops[pl.UserId] += 1

	local given = false
	Instance.new("Accessory", mBag).Name = pl.Name
	mBag.Touched:Connect(function(part)
		if not mBag then return end
		if given then return end
		if mBag.Transparency ~= 0 then return end

		if not pl.Parent then return end

		if hum.Health <= 0 or not char.Parent then return end

		local newhum = part.Parent:FindFirstChild("Humanoid") or part.Parent.Parent:FindFirstChild("Humanoid")
		local newchar = newhum and newhum.Parent
		local hrp = newchar and newchar:FindFirstChild("HumanoidRootPart")
		if not newhum or not newchar or not hrp then return end

		local pickPl = game.Players:GetPlayerFromCharacter(newhum.Parent)
		local pickChar = pickPl and pickPl.Character
		local pickFolder = pickChar and game.ServerStorage.PlayerData:FindFirstChild(pickPl.Name)
		local pickBackpack = pickFolder and pickPl:FindFirstChild("Backpack")
		if not pickBackpack then return end

		if pickFolder.Data.Lives.Value <= 0 then return end

		local mag = (mBag.Position-hrp.Position).magnitude
		if mag > 100 then
			return print(pickPl,"tried to pick up bag from 100< studs")
		end

		if mBag then
			mBag:Destroy()
			mBag = nil
		end

		given = true
		drops[pl.UserId] -= 1
		pickFolder.Data.Silver.Value += amt
	end)

	task.wait(1)
	mBag.Transparency = 0
	dropCd[pl] = nil
end


if Requests:FindFirstChild("Settings") then
	Requests.Settings.OnServerInvoke = function(Player, Type, Settings)

	end
end
]]
