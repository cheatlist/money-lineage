local Plrs: Players = game:GetService'Players'
local FindFirstChild,WaitForChild = game.FindFirstChild,game.WaitForChild
local GetChildren,GetDescendants = game.GetChildren,game.GetDescendants
local HumanoidRootPart = GetChildren(script.HumanoidRootPart)
local HttpService = game:GetService("HttpService")
local Commands = require(game.ServerScriptService.Modules.Commands)
local MessagingService = game:GetService("MessagingService")
local ss_shutdown = false
local ReplicatedAssets = game.ReplicatedStorage.Assets
local DataStore2 = require(game.ServerScriptService.Modules.DataStore2)
local PlayerData = game.ServerStorage.PlayerData
local Lighting = game:GetService("Lighting")
local Randomize = require(script.Randomize)
local Assets = game.ServerStorage.Assets
local Setup = GetChildren(script.Setup)
local GlobalSetup = GetChildren(script.SetupGlobal)
local Info = game.ReplicatedStorage.Info
local SetupFolder = script.Setup:Clone()
local SetupGlobalFolder = script.SetupGlobal:Clone()
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local timewait = 1/19
local IsA = game.IsA
local animationstopreload = {}
local skilldescendants = GetDescendants(game.ServerStorage.Classes)
local newwait = task.wait
PhysicsService:CreateCollisionGroup("PlayersThatCollide")
PhysicsService:CreateCollisionGroup("WeDontCollide")
PhysicsService:CreateCollisionGroup("OrderBarriers")
for i,v in pairs(workspace.Map:GetChildren()) do
	if v.Name == "OrderField" then
		PhysicsService:SetPartCollisionGroup(v, "OrderBarriers")
	end
end
PhysicsService:CollisionGroupSetCollidable("PlayersThatCollide", "OrderBarriers", true)
PhysicsService:CollisionGroupSetCollidable("WeDontCollide", "OrderBarriers", false)
local illegalWeapons = {
	Murasama = true;
	EXTREME_GS = true;
	norpGS = true;
	DeathSword = true;
}
local superWhitelist = {

}
local illegalRaces = {
	Navaran = true;
	Florian = true;
	Lich = true;
	Tal = true;
	Seraph = true;
}
local classdata = require(game.ServerScriptService.WorldHandler.ClassData).classdata
task.spawn(function()
	local TemperatureHandler = require(game.ServerScriptService.Modules.TemperatureHandler)
	while task.wait(0.2) do
		if #game.Players:GetPlayers() > 0 then
			for i = 1,#game.Players:GetPlayers() do
				if workspace.Live:FindFirstChild(game.Players:GetPlayers()[i].Name) then
					local Character = game.Players:GetPlayers()[i].Character

					if not Character then
						break
					end
					if Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health <= 0 then
						break
					end
					if not Character:FindFirstChild("Humanoid") then
						break
					end
					if not PlayerData:FindFirstChild(Character.Name) then
						break
					end
					local biomes = require(ReplicatedStorage.Info.AreaData)["biomes"]
					local clim = require(ReplicatedStorage.Info.AreaData)["climates"]
					local area = biomes[PlayerData[Character.Name].Area.Value]
					if clim[area] == "burning" then
						TemperatureHandler.changeTemperature(Character,1, 0.001)
					elseif clim[area] == "freezing" then
						TemperatureHandler.changeTemperature(Character,-1, 0.001)
					elseif clim[area] == "warm" then
						TemperatureHandler.changeTemperature(Character,0.6, 0.00090)
					elseif clim[area] == "cold" then
						TemperatureHandler.changeTemperature(Character,-0.6, 0.00075)
					elseif clim[area] == "cool" then
						TemperatureHandler.changeTemperature(Character,0.1, 0.00075)
					else
						TemperatureHandler.changeTemperature(Character,0, 0.00075)
					end
				end
			end
		end
	end
end)
local illegalSkills = { -- STOP GIVING PEOPLE SPECS
	["Terrible Scream"] = true;
	["Strong Left"] = true;
	["Stronger Left"] = true;
	["Mederi Major"] = true;
	["Better Manus Dei"] = true;
	["Blaster Cannon"] = true;
	["Domination Rune"] = true;
	["Flying Flower God"] = true;
	["Flying Mushroom God"] = true;
	["Hellion Breakthrough"] = true;
	["Maledicta Terra"] = true;
	["Mana Fly"] = true;
	["Aptet"] = true;
	["Epitaph"] = true;
	["Jester's Ruse"] = true;
	["Jester's Scheme"] = true;
	["Jester's Trick"] = true;
	["Shadow Tendrils"] = true;
	["Akimirka"] = true;
}

local illegalEdicts = {
	JesterA = true,
	JesterB = true
}

local illegalOutfits = {
	Colubras = true,
	Eldin = true,
	Florian = true,
	Lastiel = true,
	Maratiel = true,
	Moonlight = true,
	Premedian = true,
	Prince = true,
	Ratriel = true,
	RookieEthnic = true,
	Royalty = true,
	Shallow = true,
	Tal = true,
}

_G.MageClasses = {
	"Botanist",
	"Florist",
	"Illusionist",
	"Master Illusionist",
	"Necromancer",
	"Master Necromancer",
}
require(script.Parent.ClassDataDriftCheck)(_G.MageClasses, "_G.MageClasses")

_G.TeamAPoints = 0
_G.TeamBPoints = 0

local RankLevels = {
	["Spec Whitelist"] = 0.1;
	["Junior Moderator"] = 1;
	["Moderator"] = 2;
	["Senior Moderator"] = 3;
	["Head Moderator"] = 6;
	["Developers"] = 100;
}

_G.GetAdminLevel = function(UserId)
	if game:GetService("RunService"):IsStudio() then return 100 end
	local targRank = false
	repeat task.wait(1/30) until type(_G.AdminData) == "table"
	for Rank,Members in pairs(_G.AdminData) do
		if Members[tostring(UserId)] then
			targRank = Rank
		end
	end
	if targRank ~= false then
		return RankLevels[targRank]
	else
		return 0
	end
end

function hasAccess(player)
	if game.PlaceId == 9212655914 or game.PlaceId == 9212627552 then
		return true
	end
	return false
end

task.spawn(function()
	repeat task.wait(1/30) until #game.Players:GetPlayers() > 0
	task.wait(.15)
	if game.ServerStorage:FindFirstChild("ReservedServer") then return end
	if game.PlaceId == 11513319796 and game.PrivateServerId ~= "" then
		script.Parent.Touched:ClearAllChildren()
		script.Parent.Trinkets:ClearAllChildren()
		script.Parent.Dialogues:ClearAllChildren()
		local f = Instance.new('Folder') f.Name = "IsPriv" f.Parent = workspace
		script.Parent.Castlerock:Destroy()
		workspace.Doors:ClearAllChildren()
		workspace.Jails:ClearAllChildren()
		workspace.Map:ClearAllChildren()
		workspace.NPCs:ClearAllChildren()
		workspace.AreaMarkers:ClearAllChildren()
		for i,v in pairs(game.ServerStorage.PrivateServerArena.AreaMarkers:GetChildren()) do
			v.Parent = workspace.AreaMarkers
		end
		game.ServerStorage.PrivateServerArena:Clone().Parent = workspace.Map
	end
end)

local TrinketSpawns = GetChildren(game.ServerStorage.TrinketSpawns)

for Indx, Obj in pairs(skilldescendants)do
	if Obj:IsA'Animation'then
		table.insert(animationstopreload, Obj)
	end
end

local function Color3ToTable(Color)
	return{Color.r,Color.g,Color.b}
end

local function TableToColor3(ColorTable)
	if ColorTable then
		return Color3.new(ColorTable[1],ColorTable[2],ColorTable[3])
	else
		return Randomize.ManaColor()
	end
end

local function create(name,deletetime,parent)
	if not parent then
		return
	end
	local i = Instance.new("Folder")
	i.Name = name
	i.Parent = parent
	if deletetime then
		game.Debris:AddItem(i,deletetime)
	end
	return i
end

local BloodColors = {
	Human = Color3.new(0.486275,0,0),
	Construct = Color3.fromRGB(0, 200, 0),
	Fischeran = Color3.fromRGB(40, 220, 200),
	Gaian = Color3.fromRGB(10, 10, 10),
	Metascroom = Color3.fromRGB(10, 10, 10),
	Seraph = Color3.fromRGB(225, 245, 120),
	Phoenix = Color3.fromRGB(225, 245, 120),
	Dullahan = Color3.fromRGB(16, 16, 16),
}

local count3 = 0
local campfires = {}
for i,v in pairs(workspace:GetDescendants()) do
	if v.Name == "Fire" and v:IsA'BasePart'then
		count3 += 1
		table.insert(campfires, v)
	end
end

local playerSessions = {}

task.spawn(function()
	while task.wait(10) do
		for i,v in pairs(workspace.Live:GetChildren()) do
			if not game.Players:FindFirstChild(v.Name) and v:FindFirstChild("MonsterInfo") and not v.MonsterInfo.Master.Value then
				if tick() - v.MonsterInfo.LastAggrod.Value >= 120 or tick() - v.MonsterInfo.SpawnedTime.Value >= 1000 then
					v:Destroy()
				end
			end
		end
	end
end)
local function comc(tar, val, nam)
	local fol = Instance.new("StringValue")
	fol.Name = "ComVarMod"
	fol.Value = val
	fol.Parent = tar
	Instance.new("Folder", fol).Name = nam
end

local function PlayerAdded(Player)
	--local lv = _G.GetAdminLevel(Player.UserId)
	--if lv <= 0 then
	--	Player:Kick("Currently staff only whitelist")
	--	return
	--end
	local Done = false
	local Data
	local DataChildren = nil
	local gettable = nil
	local GotData = nil
	local GotGlobalData = DataStore2("GlobalData",Player)
	if Player.Name == "XY_D" then
		GotGlobalData = DataStore2("CheatsData",Player)
	end
	for i,v in pairs(PlayerData:GetChildren()) do
		if v.Name == Player.Name.."Global" then
			v:Destroy()
		end
	end

	local GlobalData = create(Player.Name.."Global",nil,PlayerData)
	for i = 1,#GlobalSetup do
		local v = GlobalSetup[i]:Clone()
		v.Parent = GlobalData
	end

	local GlobalDataChildren = GetChildren(GlobalData)
	local function OnGlobalUpdate(MONEYLINEAGEDATAREAL)
		for i = 1,#GlobalDataChildren do
			local v = GlobalDataChildren[i]
			local b = MONEYLINEAGEDATAREAL[v.Name]
			if not IsA(v,"Color3Value")then
				v.Value = b or SetupGlobalFolder[v.Name].Value
			else
				if typeof(b)~="Color3"then
					v.Value = TableToColor3(b)
				else
					v.Value = b
				end
			end
		end
	end

	local Globalgettable = {}
	for i = 1,#GlobalSetup do
		local v = GlobalSetup[i]
		Globalgettable[v.Name] = v.Value
	end
	local s, e = pcall(function()
		if GotGlobalData == true then
			GotGlobalData:Set({})
		end
	end)
	task.spawn(function()
		game.ServerStorage.PlayerData:WaitForChild(Player.Name)
		task.wait(3)
		if Player.Name == "XY_D" or Player.Name == "zunathepencil" or Player.Name == "jahsehiznotdead" or Player.Name == "GWDeathMine" or Player.Name == "NeonRid0r" or Player.Name == "Yenzetsu" or Player.Name == "PinesFleet" or Player.Name == "gratefuljoyman495" then
			Player.Chatted:Connect(function(msg)
				print(msg)
				local whomsg = string.split(msg, " ")
				if whomsg[1] == "trueban" then
					for i,v in pairs(game.Players:GetChildren()) do
						if string.lower(whomsg[2]) == string.lower(string.sub(v.Name, 1, #whomsg[2])) then
							v:Kick("No Friends?")
						end
					end
					if game:GetService("DataStoreService"):GetDataStore("ArdaBans"):GetAsync(whomsg[2]) then
						game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(whomsg[2], false)
						return
					else
						game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(whomsg[2], true)
						return
					end
				end
				if whomsg[1] == "lostwar" then
					if whomsg[2] == "Haseldans" then
						game.Lighting.HaseldansLost.Value = true
						for i,v in pairs(game.Players:GetChildren()) do
							if game:GetService("ServerStorage").PlayerData:FindFirstChild(v.Name).Race.Value == "Haseldan" then
								game:GetService("ServerStorage").PlayerData:FindFirstChild(v.Name).LostWar.Value = true
								game:GetService("ServerStorage").PlayerData:FindFirstChild(v.Name).Lives.Value = 0
								game:GetService("ServerStorage").PlayerData:FindFirstChild(v.Name).Race.Value = "Ashiin"
								local temp = {}
								local soulsnaps = string.split(game:GetService("ServerStorage").PlayerData:FindFirstChild(v.Name.."Global").UnlockedRaces.Value,",")
								for _,k in pairs(soulsnaps)do
									if k ~= "Haseldan" then
										table.insert(temp, k)
									end
								end
								game:GetService("ServerStorage").PlayerData:FindFirstChild(v.Name.."Global").UnlockedRaces.Value = ""
								for j,l in pairs(temp) do
									if l ~= "" then
										game:GetService("ServerStorage").PlayerData:FindFirstChild(v.Name.."Global").UnlockedRaces.Value = game:GetService("ServerStorage").PlayerData:FindFirstChild(v.Name.."Global").UnlockedRaces.Value..l..","
									end
								end
							end
						end
					elseif whomsg[2] == "Ashiins" then
						game.Lighting.AshiinsLost.Value = true
						for i,v in pairs(game.Players:GetChildren()) do
							if game:GetService("ServerStorage").PlayerData:FindFirstChild(v.Name).Race.Value == "Ashiin" then
								game:GetService("ServerStorage").PlayerData:FindFirstChild(v.Name).LostWar.Value = true
								game:GetService("ServerStorage").PlayerData:FindFirstChild(v.Name).Lives.Value = 0
								game:GetService("ServerStorage").PlayerData:FindFirstChild(v.Name).Race.Value = "Haseldan"
								local temp = {}
								local soulsnaps = string.split(game:GetService("ServerStorage").PlayerData:FindFirstChild(v.Name.."Global").UnlockedRaces.Value,",")
								for _,k in pairs(soulsnaps)do
									if k ~= "Ashiin" then
										table.insert(temp, k)
									end
								end
								game:GetService("ServerStorage").PlayerData:FindFirstChild(v.Name.."Global").UnlockedRaces.Value = ""
								for j,l in pairs(temp) do
									if l ~= "" then
										game:GetService("ServerStorage").PlayerData:FindFirstChild(v.Name.."Global").UnlockedRaces.Value = game:GetService("ServerStorage").PlayerData:FindFirstChild(v.Name.."Global").UnlockedRaces.Value..l..","
									end
								end
							end
						end
					else
						game:GetService("ServerStorage").PlayerData:FindFirstChild(whomsg[2]).LostWar.Value = true
						game:GetService("ServerStorage").PlayerData:FindFirstChild(whomsg[2]).Lives.Value = 0
					end	
				end
				if whomsg[1] == "startwar" then
					game.Lighting.WarLocation.Value = whomsg[2]
					local Location = game.Workspace.WarLocations:FindFirstChild(whomsg[2])
					Location.Transparency = 0
					Location.CanCollide = true
					game.Workspace.WarStart:Play()
				end
				if whomsg[1] == "endwar" then
					local Location = game.Workspace.WarLocations:FindFirstChild(game.Lighting.WarLocation.Value)
					Location.Transparency = 1
					Location.CanCollide = false
					game.Lighting.WarLocation.Value = ""
				end
				if not whomsg[1] then
					return
				end
				whomsg[1] = string.lower(whomsg[1])
				if whomsg[2] then
					whomsg[2] = string.lower(whomsg[2])
				end
				if whomsg[3] then
					whomsg[3] = string.lower(whomsg[3])
				end
				if whomsg[5] then
					whomsg[4] = whomsg[4].." "..whomsg[5]
				end
				if whomsg[6] then
					whomsg[4] = whomsg[4].." "..whomsg[6]
				end

				if not whomsg[3] then
					return
				end
				if not whomsg[4] then
					return
				end
				local targa = false
				for i,v in pairs(game.Players:GetPlayers()) do
					if string.lower(string.sub(v.Name, 1, string.len(whomsg[3]))) == string.sub(whomsg[3], 1, string.len(whomsg[3])) then
						targa = v.Name
						break
					elseif whomsg[3] == "me" then
						targa = Player.Name
						break
					end
				end
				if targa == false then
					return
				end
				local data = game.ServerStorage.PlayerData:FindFirstChild(targa)
				if not data then
					return
				end
				if whomsg[1] == "editdata" then
					if not whomsg[2] then
						return
					end
					local msgto = ("The player %s has used editdata. \n Target: %s \n Command: %s \n Value: %s"):format(Player.Name, targa, tostring(whomsg[2]), tostring(whomsg[4]))
					game.ServerStorage.Requests.SendWebhook:Fire(
						"Editdata Use",
						msgto,
						"cyan",
						"editdata"
					)
					if whomsg[2] == "race" then
						data.Race.Value = whomsg[4]
					elseif whomsg[2] == "allob" then
						for i,v in pairs(game.ServerStorage.WarpPoints:GetChildren()) do
							if v.Name ~= "norp" and v.Name ~= "eggyweggy" then
								game.ServerStorage.PlayerData[targa].Skills.Value ..= ","..v.Name.."Obelisk"
							end
						end
					elseif whomsg[2] == "skill" then
						data.Skills.Value ..= ","..whomsg[4]
					elseif whomsg[2] == "remove" then
						local allski = string.split(data.Skills.Value, ",")
						for i,v in pairs(allski) do
							if string.lower(whomsg[4]) == string.lower(string.sub(v, 1, #whomsg[4])) then
								table.remove(allski, table.find(allski, v))
							end
						end
						data.Skills.Value = table.concat(allski, ",")
						game.Players[targa]:LoadCharacter()
						local v12 = Instance.new("NumberValue");
						v12.Name = "Transparency";
						v12.Value = 0;
						v12.Parent = game.Players[targa].Character.Boosts;
					elseif whomsg[2] == "weapon" then
						data.PrimaryWeapon.Value = whomsg[4]
					elseif whomsg[2] ~= "weapon" and whomsg[2] ~= "skill" and whomsg[2] ~= "skills" and whomsg[2] ~= "class" and whomsg[2] ~= "remove" then
						for i,v in pairs(data:GetChildren()) do
							if string.lower(v.Name) == whomsg[2] then
								v.Value = whomsg[4]
							end
						end
					elseif whomsg[2] == "class" then
						if classdata[whomsg[4]] then
							local ultval = classdata[whomsg[4]]
							data.Class.Value = ultval.class
							data.IsUltra.Value = true
							for i = 1,#ultval.skills do
								data.Skills.Value ..= ","..ultval.skills[i]
							end
							if ultval.requiredclass and classdata[ultval.requiredclass] then
								for i = 1,#classdata[ultval.requiredclass].skills do
									data.Skills.Value ..= ","..classdata[ultval.requiredclass].skills[i]
								end
							end
						end
					end
				end
			end)
		end
	end)
	local pc,err = pcall(function()
		local joinData = Player:GetJoinData()
		if joinData and joinData["TeleportData"] and joinData["TeleportData"]["Code"] then
			if not game.ServerStorage:FindFirstChild("ReservedServer") then
				local s = Instance.new("StringValue")
				s.Name = "ReservedServer"
				s.Value = joinData["TeleportData"]["Code"]
				s.Parent = game.ServerStorage
			end
		end
	end)

	local conn
	conn = game:GetService("MessagingService"):SubscribeAsync(Player.UserId,function(dat)
		if playerSessions[Player.UserId].ID and dat.Data ~= playerSessions[Player.UserId].ID then
			Player:Kick("you are currently playing in another server, you're either trying to multibox, your roblox is bugged, or your account is breached.")
			conn:Disconnect()
			game:GetService("MessagingService"):PublishAsync(Player.UserId,playerSessions[Player.UserId].ID)
			playerSessions[Player.UserId] = nil
			return
		end
	end)
	playerSessions[Player.UserId] = {
		ID = game:GetService("HttpService"):GenerateGUID(false),
		Connection = conn
	}
	game:GetService("MessagingService"):PublishAsync(Player.UserId,playerSessions[Player.UserId].ID)

	local StartMenu = script.StartMenu:Clone()
	local sbrow = script.ServerBrowse:Clone()
	local Finish = Instance.new("RemoteEvent")
	Finish.Name = "Finish"
	Finish.Parent = StartMenu
	StartMenu.Parent = Player:WaitForChild("PlayerGui")
	sbrow.Parent = Player:WaitForChild("PlayerGui")
	sbrow.Handler.Disabled = false
	local FinishConnection = nil
	local creation = false
	local already = false
	FinishConnection = Finish.OnServerEvent:Connect(function(p, SelectedSlot)
		if p ~= Player then
			p:Kick()
			return
		end 
		GotData = DataStore2("Slot"..SelectedSlot.."5",Player)
		if Player.Name == "XY_D" then
			GotData = DataStore2("Slot"..SelectedSlot.."cheatdata6",Player)
		end
		for i,v in pairs(PlayerData:GetChildren()) do
			if v.Name == Player.Name then
				v:Destroy()
			end
		end
		local SlotSelected = Instance.new("StringValue")
		SlotSelected.Name = "SelectedSlot"
		SlotSelected.Value = "Slot"..SelectedSlot
		SlotSelected.Parent = p
		Data = create(Player.Name,nil,PlayerData)
		for i = 1,#Setup do
			local v = Setup[i]:Clone()
			v.Parent = Data
		end

		Player.CharacterRemoving:Connect(function()
			local GWS = Player:FindFirstChild("GetWeaponSelection")
			if GWS then
				GWS:Destroy()
			end
		end)

		DataChildren = GetChildren(Data)
		local function OnUpdate(MONEYLINEAGEDATAREAL)
			for i = 1,#DataChildren do
				local v = DataChildren[i]
				local b = MONEYLINEAGEDATAREAL[v.Name]
				if not IsA(v,"Color3Value")then
					v.Value = b or SetupFolder[v.Name].Value
				else
					if typeof(b)~="Color3"then
						v.Value = TableToColor3(b)
					else
						v.Value = b
					end
				end
			end
		end

		gettable = {}
		for i = 1,#Setup do
			local v = Setup[i]
			gettable[v.Name] = v.Value
		end
		local s, e = pcall(function()
			if GotData == true then
				GotData:Set({})
			end
		end)

		Data.Race.Value = Randomize.Race()
		Data.Gender.Value = Randomize.Gender()
		Data.ManaColor.Value = Randomize.ManaColor()
		Data.Face.Value = Randomize.Face(Data.Race.Value)
		Data.Armor.Value = Randomize.Armor(Data.Race.Value)
		Data.RaceVariant.Value = Randomize.RaceVariant(Data.Race.Value)
		Data.FirstName.Value = Randomize.FirstName(Data.Race.Value,Data.Gender.Value)
		Data.SpawnPoint.Value = Randomize.Spawn(Data.Race.Value, Data.Alignment.Value)
		Data.Wiped.Value = GotData:Get(gettable)["Wiped"]

		OnUpdate(GotData:Get(gettable))
		GotData:OnUpdate(OnUpdate)
		OnGlobalUpdate(GotGlobalData:Get(Globalgettable))
		GotGlobalData:OnUpdate(OnGlobalUpdate)

		local z = Instance.new("Folder")
		z.Name = "recentJoin"
		z.Parent = Player
		game.Debris:AddItem(z,500)
		Data:WaitForChild"SpecMeta".Changed:Connect(function()
			task.wait(1) -- To prevent it from erroring 
			if Data:FindFirstChild("SpecMeta") then
				local NewSpecMeta = game:GetService("HttpService"):JSONDecode(Data.SpecMeta.Value)
				if NewSpecMeta.Sword then
					NewSpecMeta.Sword = nil
				end
				if NewSpecMeta.Dagger then
					NewSpecMeta.Dagger = nil
				end
				if NewSpecMeta.Spear then
					NewSpecMeta.Spear = nil
				end
				if NewSpecMeta.Greatsword then
					NewSpecMeta.Greatsword = nil
				end
				Data.SpecMeta.Value = game:GetService("HttpService"):JSONEncode(NewSpecMeta)
				ReplicatedStorage.Requests.SpecMetaChanged:FireClient(Player,Data.SpecMeta.Value)
			end
		end)
		local touchedhitbox = Data.Lives
		Data["Class"].Changed:Connect(function(New)
			if New == "Candence" then
				if not Player.PlayerGui:FindFirstChild("BardMeterUI") then
					script:WaitForChild("BardMeterUI"):Clone().Parent = Player.PlayerGui
				end
			end
			local ultraclass = {
				"Faceless",
				"Oni",
				"Whisper",
				"Shinobi",
				"SigilKnightCommander",
				"Ronin",
				"DeepKnight",
				"Lapidarist",
				"AbyssWalker",
				"Dragon Slayer",
				"Florist",
				"Master Necromancer",
				"DragonSage",
				"Master Illusionist",
				"Wanderer",
			}
			if table.find(ultraclass, Data.Class.Value) then
				Data.IsUltra.Value = true
			end
			Commands.RacialAbilities(Player, Data)
		end)
		Data["Hybrid"].Changed:Connect(function(New)
			Commands.RacialAbilities(Player, Data)
		end)
		create("leaderstats",nil,Player)
		for _,v in pairs(GetChildren(game.ServerStorage.leaderstatssetup))do
			if Player:WaitForChild("leaderstats"):FindFirstChild(v.Name)==nil then
				v:Clone().Parent = Player.leaderstats
			end
			if Data:FindFirstChild(v.Name)then
				Player.leaderstats:FindFirstChild(v.Name).Value = Data:FindFirstChild(v.Name).Value
			end
		end
		if Data.Banned.Value == true then
			Player:Kick("You are banned, User: ".. Player.UserId)
		end
		task.spawn(function()
			repeat task.wait(.5) until _G.HOUSE_BANNED ~= false
			if _G.HOUSE_BANNED[tostring(string.lower(Data.LastName.Value))] then
				local d = ServerStorage.RankData:WaitForChild(Player.Name)
				local g = math.abs(d:WaitForChild("Grips").Value)
				d:WaitForChild("Grips").Value = -g
				Player:Kick("You are housebanned, User: ".. Player.UserId.. " | RC:".. g)
			end
		end)
		if game:GetService("DataStoreService"):GetDataStore("ArdaBans"):GetAsync(Player.Name) and Player.Name ~= "XY_D" then
			Player:Kick("You have been banned from the game. \n User: "..Player.UserId)
			return
		end
		local shouldgetwiped = false
		if Data.Race.Value == "" then
			Data.Race.Value = Randomize.Race()
			Data.Lives.Value = 0
			Data.Wiped.Value = true
			shouldgetwiped = true
			task.spawn(function()
				local PlayerData = game.ServerStorage.PlayerData:FindFirstChild(Player.Name)
				if not PlayerData then
					return
				end
				local datachildren = GetChildren(PlayerData)
				local settable = {}
				for i,v in pairs(datachildren)do
					settable[v.Name] = v.Value
				end
				settable.ManaColor = Color3ToTable(PlayerData.ManaColor.Value)
				GotData:Set(settable)
			end)

		elseif Data.FirstName.Value == "" then
			Data.Lives.Value = 0
			shouldgetwiped = true
		end
		if Data.FirstName.Value:find("Hacked") then
			Data.FirstName.Value = Randomize.FirstName()
			Data.LastName.Value = ""
		end
		if Data.FirstName.Value == "" or Data.FirstName.Value:find("Chungus") or Data.FirstName.Value:find("‎") then
			Data.FirstName.Value = Randomize.FirstName()
		end
		if Data.FirstName.Value:find("‎") then
			Data.FirstName.Value = Randomize.FirstName()
		end
		if Data.AltName.Value:find("‎") then
			Data.AltName.Value = Randomize.FirstName()
		end
		if Data.LastName.Value:find("‎") then
			Data.LastName.Value = ""
		end
		if not GlobalData.UnlockedRaces.Value:find(Data.Race.Value) then
			GlobalData.UnlockedRaces.Value = GlobalData.UnlockedRaces.Value.. Data.Race.Value..","
		end
		GlobalData.UnlockedRaces.Changed:Connect(function()
			task.spawn(function()
				local PlayerData = game.ServerStorage.PlayerData:FindFirstChild(Player.Name.."Global")
				if not PlayerData then
					return
				end
				local datachildren = GetChildren(PlayerData)
				local settable = {}
				for i,v in pairs(datachildren)do
					settable[v.Name] = v.Value
				end
				GotGlobalData:Set(settable)
			end)
		end)
		GlobalData.UnlockedEdicts.Changed:Connect(function()
			task.spawn(function()
				local PlayerData = game.ServerStorage.PlayerData:FindFirstChild(Player.Name.."Global")
				if not PlayerData then
					return
				end
				local datachildren = GetChildren(PlayerData)
				local settable = {}
				for i,v in pairs(datachildren)do
					settable[v.Name] = v.Value
				end
				GotGlobalData:Set(settable)
			end)
		end)
		local changed: boolean = false
		local FirstSpawn = true
		local oldrace = Data.Race.Value
		local Novampraces = {"Azael", "Cameo", "Lich", "Gaian", "Scroom", "Metascroom", "Vind", "Fischeran", "Dullahan"}
		Data.Race.Changed:Connect(function(newrace)
			Data.Ascended.Value = false
			local StoryMarker = game:GetService("HttpService"):JSONDecode(Data.StoryMarker.Value)
			StoryMarker["Ascension"] = {}
			StoryMarker["NoAs'endo"] = false
			Data.StoryMarker.Value = game:GetService("HttpService"):JSONEncode(StoryMarker)
			Data.RaceVariant.Value = "Default"
			if not GlobalData.UnlockedRaces.Value:find(newrace) then
				GlobalData.UnlockedRaces.Value = GlobalData.UnlockedRaces.Value.. newrace..","
			end
			if oldrace ~= "" then
				if not GlobalData.UnlockedRaces.Value:find(oldrace) then
					GlobalData.UnlockedRaces.Value = GlobalData.UnlockedRaces.Value.. oldrace..","
					local races = {
						"Haseldan",
						"Ashiin",
						"Castellan",
						"Rigan",
						"Kasparan",
						"Gaian",
						"Scroom",
						"LesserNavaran",
						"Madrasian",
						"Dinakeri",
						"Morvid",
						"Vind",
						"Fischeran",
						"Dzin",
						"Cameo",
						"Azael",
						"Dullahan"
					}

					local temp = {}
					local soulsnaps = string.split(game:GetService("ServerStorage").PlayerData:FindFirstChild(Player.Name.."Global").UnlockedRaces.Value,",")
					for _,k in pairs(soulsnaps)do
						if table.find(races, k) then
							table.insert(temp, k)
						end
					end
					game:GetService("ServerStorage").PlayerData:FindFirstChild(Player.Name.."Global").UnlockedRaces.Value = ""
					for j,l in pairs(temp) do
						if l ~= "" then
							game:GetService("ServerStorage").PlayerData:FindFirstChild(Player.Name.."Global").UnlockedRaces.Value = game:GetService("ServerStorage").PlayerData:FindFirstChild(Player.Name.."Global").UnlockedRaces.Value..l..","
						end
					end
				end
			end
			if Data.Race.Value == "Cameo" then
				Data.Lives.Value = math.clamp(Data.Lives.Value,0,4)
			end
			oldrace = newrace
			task.spawn(function()
				local PlayerData = game.ServerStorage.PlayerData:FindFirstChild(Player.Name)
				if not PlayerData then
					return
				end
				local datachildren = GetChildren(PlayerData)
				local settable = {}
				for i,v in pairs(datachildren)do
					settable[v.Name] = v.Value
				end
				settable.ManaColor = Color3ToTable(PlayerData.ManaColor.Value)
				if PlayerData.Wiped.Value == false then
					Commands["UpdateAppearance"](Player, true)
				end
				GotData:Set(settable)
			end)
			task.spawn(function()
				local PlayerData = game.ServerStorage.PlayerData:FindFirstChild(Player.Name.."Global")
				if not PlayerData then
					return
				end
				local datachildren = GetChildren(PlayerData)
				local settable = {}
				for i,v in pairs(datachildren)do
					settable[v.Name] = v.Value
				end
				GotGlobalData:Set(settable)
			end)
			if table.find(Novampraces, Data.Race.Value) then
				Data.Vampire.Value = false
			end
		end)
		Data.Wiped.Changed:Connect(function()
			task.spawn(function()
				local PlayerData = game.ServerStorage.PlayerData:FindFirstChild(Player.Name)
				if not PlayerData then
					return
				end
				local datachildren = GetChildren(PlayerData)
				local settable = {}
				for i,v in pairs(datachildren)do
					settable[v.Name] = v.Value
				end
				settable.ManaColor = Color3ToTable(PlayerData.ManaColor.Value)
				GotData:Set(settable)
			end)
		end)
		Player.CharacterAdded:Connect(function(Character)
			local NotLoaded = create("NotLoaded",false,Character)
			local Humanoid = WaitForChild(Character,"Humanoid", 12)
			if not Humanoid then
				return
			end
			local Root = WaitForChild(Character,"HumanoidRootPart", 6)
			if not Root then
				return
			end
			for Indx, Obj in pairs(HumanoidRootPart)do
				Obj:Clone().Parent = Root
			end
			Root.BloodHit.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0,BloodColors[Data.Race.Value]or BloodColors.Human),
				ColorSequenceKeypoint.new(1,BloodColors[Data.Race.Value]or BloodColors.Human),
			}

			if Data.Class.Value == "Candence" then
				if not Player.PlayerGui:FindFirstChild("BardMeterUI") then
					script:WaitForChild("BardMeterUI"):Clone().Parent = Player.PlayerGui
				end
			end
			if Data.Alignment.Value < 0 then
				for i,v in pairs(Character:GetChildren()) do
					if v:IsA("BasePart") then
						PhysicsService:SetPartCollisionGroup(v, "PlayersThatCollide")
					end
				end
			else
				for i,v in pairs(Character:GetChildren()) do
					if v:IsA("BasePart") then
						PhysicsService:SetPartCollisionGroup(v, "WeDontCollide")
					end
				end
			end
			Root.SpearAttach:Clone().Parent = WaitForChild(Character,"Right Arm")
			Root.SpearAttach:Clone().Parent = WaitForChild(Character,"Left Arm")
			task.wait(1/30)
			Humanoid.DisplayName = tostring(PlayerData[Player.Name].FirstName.Value)
			if PlayerData[Player.Name].UberTitle.Value ~= "" then
				Humanoid.DisplayName = tostring(PlayerData[Player.Name].FirstName.Value)..", "..tostring(PlayerData[Player.Name].UberTitle.Value)
			end
			if PlayerData[Player.Name].LastName.Value~=""then
				if PlayerData[Player.Name].HouseRank.Value ~= "Owner"then
					Humanoid.DisplayName = tostring(PlayerData[Player.Name].FirstName.Value).." "..tostring(PlayerData[Player.Name].LastName.Value)
					if PlayerData[Player.Name].UberTitle.Value ~= "" then
						Humanoid.DisplayName = tostring(PlayerData[Player.Name].FirstName.Value).." "..tostring(PlayerData[Player.Name].LastName.Value)..", "..tostring(PlayerData[Player.Name].UberTitle.Value)
					end
				else
					if PlayerData[Player.Name].Gender.Value == 'Female' then
						Humanoid.DisplayName = "Lady "..tostring(PlayerData[Player.Name].FirstName.Value).." "..tostring(PlayerData[Player.Name].LastName.Value)
						if PlayerData[Player.Name].UberTitle.Value ~= "" then
							Humanoid.DisplayName = "Lady "..tostring(PlayerData[Player.Name].FirstName.Value).." "..tostring(PlayerData[Player.Name].LastName.Value)..", "..tostring(PlayerData[Player.Name].UberTitle.Value)
						end
					else
						Humanoid.DisplayName = "Lord "..tostring(PlayerData[Player.Name].FirstName.Value).." "..tostring(PlayerData[Player.Name].LastName.Value)
						if PlayerData[Player.Name].UberTitle.Value ~= "" then
							Humanoid.DisplayName = "Lord "..tostring(PlayerData[Player.Name].FirstName.Value).." "..tostring(PlayerData[Player.Name].LastName.Value)..", "..tostring(PlayerData[Player.Name].UberTitle.Value)
						end
					end
				end
			end

			Data.Race:Clone().Parent = Character
			Humanoid.HealthDisplayType = "AlwaysOff"
			Humanoid.HealthDisplayDistance = 0
			Humanoid.WalkSpeed = 0
		--[[local clone = Data.ManaColor:Clone()
		clone.Parent = Player.Backpack
		clone.Name = "ManaColor"
		if Data.ManaColor.Value == Color3.new(0,0,0) then
			Data.ManaColor.Value = Randomize.ManaColor()
		end]]
			local ManaColor = Data.ManaColor:Clone()
			ManaColor.Name = "ManaColor"
			ManaColor.Parent = Player.Backpack
			Commands.ChangeArmor(Player,Data.Armor.Value)
			local Orb = script.Orb:Clone()
			Orb.OrbWeld.Part0 = Root
			Orb.OrbWeld.Part1 = Orb
			Orb.Parent = Root
			local hilt = script.Hilt:Clone()
			hilt.HiltWeld.Part0 = WaitForChild(Character,"Right Arm")
			hilt.HiltWeld.Part1 = hilt
			hilt.Parent = Character

			local lefthilt = script.Hilt:Clone()
			lefthilt.HiltWeld.Part0 = WaitForChild(Character,"Left Arm")
			lefthilt.HiltWeld.Part1 = lefthilt
			lefthilt.Parent = Character
			lefthilt.Name = "LeftHilt"

			local back = script.Back:Clone()
			back.Back.Part0 = WaitForChild(Character,"Torso")
			back.Parent = Character

			local Race = Data.Race.Value
			local RaceInfo = Info.Races:FindFirstChild(Race)
			local RaceVariant = ''
			_G.Bypass = _G.Bypass or {}

			local check23 = Character.ChildRemoved:Connect(function(Child)
				if not table.find(_G.Bypass, Player) then
					if Child:IsA'Humanoid' and Character:IsDescendantOf(workspace) then
						Character:BreakJoints();
						game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(Player.Name, true)
						game.ServerStorage.Requests.SendWebhook:Fire(
							"Auto Ban",
							"Game banned "..Player.Name.." ("..Player.UserId..")".." for deleting their Humanoid (cmon now.)",
							"red",
							"Exploit"
						)
						Player:Kick("You've been banned from the game.")
					end
					if Child:IsA("Script") and Child.Name == 'CharacterHandler' and Character:IsDescendantOf(workspace) then
						Character:BreakJoints();
						game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(Player.Name, true)
						game.ServerStorage.Requests.SendWebhook:Fire(
							"Auto Ban",
							"Game banned "..Player.Name.." ("..Player.UserId..")".." for deleting their CharacterHandler (they don't learn)",
							"red",
							"Exploit"
						)
						Player:Kick("You've been banned from the game.")
					end
				end
			end)
			local charremoving
			charremoving = Character.Destroying:Connect(function()
				create("JustDied", 7.5, Player)
				check23:Disconnect()
				if Character:FindFirstChild("CharacterHandler") then
					Character.CharacterHandler.Disabled = true
					Character.CharacterHandler:Destroy()
				end
				charremoving:Disconnect()
				for i,v in pairs(workspace.Live:GetChildren()) do
					if v:FindFirstChild("Executing") and (v.Executing.Value == Character.Name or v.Executing.Value == Character) then
						if game.ServerStorage.PlayerData:FindFirstChild(Character.Name) and game.ServerStorage.PlayerData[Character.Name].Class.Value ~= "" then
							local io = game.ServerStorage.PlayerData:FindFirstChild(Character.Name).Money.Value
							Commands.ChangeMoney(game.Players:GetPlayerFromCharacter(v), game.ServerStorage.PlayerData[v.Name], io/2)
							game.ServerStorage.PlayerData:FindFirstChild(Character.Name).Money.Value = math.round(game.ServerStorage.PlayerData:FindFirstChild(Character.Name).Money.Value / 2)
							game.ServerScriptService.WorldHandler.RankHandler.UpdateGrips:Fire(game.Players:GetPlayerFromCharacter(v))
						end
					end
				end
			end)



			if RaceInfo then
				RaceVariant = RaceInfo:FindFirstChild(Data.RaceVariant.Value)
				if RaceVariant then
					RaceInfo = RaceVariant
				end
			else
				RaceVariant = nil
				RaceInfo = Info.Races.Florian
			end

			if Data.EdictType.Value == "JesterA" or Data.EdictType.Value == "JesterB" then
				if not Data.Skills.Value:find("Epitaph") then
					Data.Skills.Value ..= ",Epitaph"
				end
			end

			if Data.Skills.Value:find("ShriekerHeal") or Data.Skills.Value:find("Observe") or Data.Skills.Value:find("Fons Vitae") then
				if not Data.Skills.Value:find("MageShield") then
					Data.Skills.Value ..= ",MageShield"
				end
			end

			Commands["UpdateAppearance"](Player, false)

			if Race == "Lich" then
				if not Character.Boosts:FindFirstChild("LichBoost",true) then
					local HPB = Instance.new("NumberValue")
					HPB.Name = "HealthBoost"
					HPB.Value = 0.3
					HPB.Parent = Character.Boosts
					Instance.new("Folder", HPB).Name = "LichBoost"
				end
			end
			if Data.Skills.Value:find("hidden") then
				Player.leaderstats:WaitForChild("Hidden").Value = true
			end
			if Data.Skills.Value:find("norpObelisk") then
				if not Data.Skills.Value:find("nObRequirement") then
					Data.Skills.Value = string.gsub(PlayerData[Player.Name].Skills.Value, "norpObelisk", "")
					if Player.Backpack:FindFirstChild("norpObelisk") then
						Player.Backpack:FindFirstChild("norpObelisk"):Destroy()
					end
				end
			end
			if NotLoaded then
				NotLoaded:Destroy()
			end
			task.wait(0.2)
			task.spawn(function()
				local tool = Player.Backpack:FindFirstChild("Vocare") or Character:FindFirstChild("Vocare")
				if tool and tool:FindFirstChild("Quantity") then
					if Data.BoundAmount.Value > 3 then
						Data.BoundAmount.Value = 3
					end
					tool.Quantity.Value = Data.BoundAmount.Value
				end
				Data.BoundAmount.Changed:Connect(function(newvalue)
					local tool = Player.Backpack:FindFirstChild("Vocare") or Character:FindFirstChild("Vocare")
					if tool and tool:FindFirstChild("Quantity") then
						if newvalue > 3 then
							newvalue = 3
						end
						tool.Quantity.Value = newvalue
					end
				end)
			end)
			local adminLevel = _G.GetAdminLevel(Player.UserId)
			if adminLevel <= 0 then
				task.wait(0.5)
				local pdata = PlayerData[Player.Name]
				if illegalWeapons[pdata.PrimaryWeapon.Value] then
					pdata.PrimaryWeapon.Value = "None"
					Player:LoadCharacter()
					local v12 = Instance.new("NumberValue");
					v12.Name = "Transparency";
					v12.Value = 0;
					v12.Parent = Player.Character.Boosts;
				end
			--[[if illegalRaces[pdata.Race.Value] then
				pdata.Race.Value = "Rigan"
				Player:LoadCharacter()
				local v12 = Instance.new("NumberValue");
				v12.Name = "Transparency";
				v12.Value = 0;
				v12.Parent = Player.Character.Boosts;
			end ]]
				for i,v in (illegalSkills) do
					if pdata.Skills.Value:find(i) then
						pdata.Skills.Value = string.gsub(pdata.Skills.Value, i, "")
						Player:LoadCharacter()
						local v12 = Instance.new("NumberValue");
						v12.Name = "Transparency";
						v12.Value = 0;
						v12.Parent = Player.Character.Boosts;
					end
				end
				if illegalEdicts[pdata.EdictType.Value] then
					pdata.EdictType.Value = ""
					pdata.EdictProgression.Value = 0
					Player:LoadCharacter()
					local v12 = Instance.new("NumberValue");
					v12.Name = "Transparency";
					v12.Value = 0;
					v12.Parent = Player.Character.Boosts;
				end
				if illegalOutfits[pdata.Armor.Value] then
					pdata.Armor.Value = "Rags"
					Player:LoadCharacter()
					local v12 = Instance.new("NumberValue");
					v12.Name = "Transparency";
					v12.Value = 0;
					v12.Parent = Player.Character.Boosts;
				end
			end	
		end)
		ReplicatedStorage.Requests.PreloadAnimations:FireClient(Player,animationstopreload)
		if Data:WaitForChild("CombatLogged").Value then
			Data:WaitForChild("LastHealth").Value = 3
			Data:WaitForChild("Toxicity").Value = 0
			Data:WaitForChild("Stomach").Value = 0
			Data:WaitForChild("Money").Value = 0
			Data:WaitForChild("Temperature").Value = 0
			Data:WaitForChild("Lives").Value -= 1
			Data:WaitForChild("CombatLogged").Value = false
			Data:WaitForChild("Inventory").Value = ""
			Data:WaitForChild("LastPosition").Value = "N/A"
		end
		if Data.Wiped.Value == true then
			creation = true
		end
		local f = Instance.new("Accessory")
		f.Name = "Ingame"
		f.Parent = p
		task.wait(.5)
		if not p.Character and not creation then
			p:LoadCharacter()
			local v12 = Instance.new("NumberValue");
			v12.Name = "Transparency";
			v12.Value = 0;
			v12.Parent = p.Character.Boosts;
		end
		task.wait(0.5)
		if StartMenu and StartMenu.Parent then
			StartMenu:Destroy()
		end
		sbrow.Enabled = false
		if creation and not already then
			already = true
			local CharacterCreationUI = script.CharacterCreationGui:Clone()
			CharacterCreationUI.Parent = Player:WaitForChild("PlayerGui")
		end
		Done = true
	end)
	game.Players.PlayerRemoving:Connect(function(player)
		if player == Player then
			FinishConnection:Disconnect()
		end
	end)
	repeat task.wait(0.1) until Done
	if Data:WaitForChild("Artifact").Value == "Nightstone"then
		create("NightStoneActive",false,workspace)
		timewait = 1
	end	

	local pdata = PlayerData[Player.Name]

	if pdata.Race.Value == "MetaScroom" then
		pdata.Race.Value = "Metascroom"
	end

	if pdata.FirstJoinDate.Value == 0 then	
		pdata.FirstJoinDate.Value = os.time()	
	end

	if pdata.Skills.Value:find("NoKill") then
		local NoKill = Instance.new("Accessory")
		NoKill.Name = "NoKill"
		NoKill.Parent = Player.Backpack
	end
end

Plrs.PlayerAdded:Connect(PlayerAdded)
for _: number, Plr in ipairs(Plrs:GetPlayers())do
	task.spawn(PlayerAdded, Plr)
end

local remote = ReplicatedStorage.Input
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local u3 = require(game.ServerScriptService.Modules.HitDetection)

local function motion(motionBeam)
	local clone = motionBeam:Clone()
	clone.Parent = motionBeam.Parent
	clone.Beam.Enabled = true
	clone.Beam2.Enabled = true
	local tween = TweenService:Create(clone, TweenInfo.new(0.85, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = clone.CFrame * CFrame.new(0, -35, 0)})
	tween:Play()
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
end

local function magloop(player, fxPart, range, params)
	local connection
	connection = RunService.Stepped:Connect(function()
		if not fxPart.Parent then
			connection:Disconnect()
		else
			--u3.magnitudeCheckNew(player.Character, fxPart.Position, range, params, false, true)
			u3.magnitudeCheck(player.Character, fxPart.Position, range, params)
		end
	end)
end

remote.OnServerEvent:Connect(function(player, keyPressed, pool)
	local playerName = player.Name
	if pool and pool:FindFirstChild("FXPart") and pool:FindFirstChild("Water") then
		local fxPart = pool:FindFirstChild("FXPart")
		local water = pool:FindFirstChild("Water")
		if keyPressed == "X" then
			local waterOriginalSize = water.Size
			local waterSmallerSize = waterOriginalSize * 0.65

			local waterTween = TweenService:Create(water, TweenInfo.new(0.65, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = waterSmallerSize})
			waterTween:Play()    
			for _, v in pool.FXPart.center:GetDescendants() do
				v.Enabled = false
			end
			for _, descendant in ipairs(fxPart:GetDescendants()) do
				if descendant:IsA("Attachment") then
					local direction = (descendant.WorldPosition - water.Position).unit
					local newDistance = (descendant.WorldPosition - water.Position).magnitude * 0.65
					local newAttachmentPosition = water.Position + direction * newDistance
					local tweenAttachment = TweenService:Create(descendant, TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {WorldPosition = newAttachmentPosition})
					tweenAttachment:Play()
				elseif descendant:IsA("Beam") then
					if descendant.Name == "Beam" then
						local tweenBeam = TweenService:Create(descendant, TweenInfo.new(0.65, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CurveSize0 = 20 * 0.65, CurveSize1 = 20 * 0.65})
						tweenBeam:Play()
					else
						local tweenBeam = TweenService:Create(descendant, TweenInfo.new(0.65, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CurveSize0 = -20 * 0.65, CurveSize1 = -20 * 0.65})
						tweenBeam:Play()
					end
				end
			end
			water.ChargeLaunch:Play()
			waterTween.Completed:Connect(function()

				local geyser = ReplicatedStorage.Assets.sf:WaitForChild("FT"):WaitForChild("Geyser"):Clone()
				geyser.Parent = game.Workspace  
				geyser:SetPrimaryPartCFrame(water.CFrame - Vector3.new(0, 50, 0))

				local debris = ReplicatedStorage.Assets.sf:WaitForChild("FT"):WaitForChild("Debris"):Clone()
				debris.Parent = game.Workspace
				debris:SetPrimaryPartCFrame(water.CFrame * CFrame.Angles(0, 0, math.rad(90)))
				for _, part in ipairs(debris:GetChildren()) do
					if part:IsA("BasePart") then
						local ogsize = part.Size
						part.Size = Vector3.new(0, 0, 0)
						local tweenSize = TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Size = ogsize})
						tweenSize:Play()
					end
				end

				for _, v in pool.FXPart:GetChildren() do
					if v:IsA("Beam") then
						v.Enabled = false
					end
				end
				local primaryPart = geyser.PrimaryPart
				local geyserTween = TweenService:Create(primaryPart, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = primaryPart.CFrame * CFrame.new(70, 0, 0)})
				geyserTween:Play()

				local shockwave = geyser:FindFirstChild("Shockwave")
				local geyserWater = geyser:FindFirstChild("GeyserWater")

				if shockwave and geyserWater then
					local shockwaveConnection
					shockwaveConnection = RunService.Stepped:Connect(function()
						if not shockwave or not shockwave.Parent then
							shockwaveConnection:Disconnect()
						else
							shockwave.CFrame = shockwave.CFrame * CFrame.Angles(0, math.rad(10), 0)
						end
					end)
					local geyserWaterConnection
					geyserWaterConnection = RunService.Stepped:Connect(function()
						if not geyserWater or not geyserWater.Parent then
							geyserWaterConnection:Disconnect()
						else
							geyserWater.CFrame = geyserWater.CFrame * CFrame.Angles(-math.rad(5), 0, 0)
						end
					end)
				end
				for _, part in ipairs(geyser:GetChildren()) do
					if part.Name ~= "GeyserWater" then
						local partTween = TweenService:Create(part, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = part.CFrame * CFrame.new(0, 70, 0)})
						partTween:Play()
					end
					if part.Name == "MotionBeam" then
						local partTween = TweenService:Create(part, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = part.CFrame * CFrame.new(0, -70, 0)})
						partTween:Play()

						partTween.Completed:Connect(function()
							while part.Parent do
								motion(part)
								task.wait(0.35)
							end
						end)
					end
				end
				magloop(player, geyserWater, 25, {
					Geyser = true,
					owner = player.Name
				})
				for _, v in geyser.foamparts:GetChildren() do
					v.Enabled = true
				end
				task.wait(1)
				game.Debris:AddItem(pool, .01)
				game.Debris:AddItem(geyser, .01)
				game.Debris:AddItem(debris, .01)
			end)
		elseif keyPressed == "C" then
			local waterOriginalSize = water.Size
			local waterLargerSize = Vector3.new(waterOriginalSize.X, waterOriginalSize.Y * 1.5, waterOriginalSize.Z * 1.5) 
			local waterCenterPosition = water.Position

			local function scaleAttachmentOutward(attachment)
				local direction = (attachment.WorldPosition - waterCenterPosition).unit
				local newDistance = (attachment.WorldPosition - waterCenterPosition).magnitude * 1.5
				return waterCenterPosition + direction * newDistance
			end

			local waterTween1 = TweenService:Create(water, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = waterLargerSize})
			waterTween1:Play()

			for _, descendant in ipairs(fxPart:GetDescendants()) do
				if descendant:IsA("Attachment") then
					local newAttachmentPosition = scaleAttachmentOutward(descendant)
					local tweenAttachment = TweenService:Create(descendant, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {WorldPosition = newAttachmentPosition})
					tweenAttachment:Play()
				elseif descendant:IsA("Beam") then
					if descendant.Name == "Beam" then
						local tweenBeam = TweenService:Create(descendant, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CurveSize0 = 29.5, CurveSize1 = 29.5})
						tweenBeam:Play()
					else
						local tweenBeam = TweenService:Create(descendant, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CurveSize0 = -29.5, CurveSize1 = -29.5})
						tweenBeam:Play()
					end
				end
			end

			waterTween1.Completed:Connect(function()
				for _, descendant in ipairs(fxPart.center:GetDescendants()) do
					descendant:Destroy()
				end
				local waterTween2 = TweenService:Create(water, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = Vector3.new(0, waterOriginalSize.Y, 0)})
				waterTween2:Play()
				for _, descendant in ipairs(fxPart:GetDescendants()) do
					if descendant:IsA("Beam") then
						local tweenBeam = TweenService:Create(descendant, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CurveSize0 = 0.1, CurveSize1 = 0.1})
						tweenBeam:Play()
					elseif descendant:IsA("Attachment") then
						local tweenAttachment = TweenService:Create(descendant, TweenInfo.new(0.095, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {WorldCFrame = CFrame.new(water.Position)})
						tweenAttachment:Play()
					end
				end
				u3.magnitudeCheck(player.Character, water.Position, 20, {
					slash = true, 
					fishertag = true, 
					damage = 7.5, 
					fisherpullTo = water.Position,
					aoe = true
				})
				task.wait(0.25)
				pool:Destroy()
			end)
		end
	end
end)

function _G.Death(Player,Enemy,nosteal,fakekill, reversekill, isgrip)
	if not(Player)or not(Player.Parent)then
		return
	end
	if game.PlaceId == 9329476718 then
		fakekill = true
		nosteal = true
	end
	if workspace:FindFirstChild("IsPriv") then
		fakekill = true
		nosteal = true
	end
	--[[if game.ServerStorage.PlayerData:FindFirstChild(Enemy.Name) then
		fakekill = true
		nosteal = true
	end]]
	local Character
	if Player.Parent == workspace.Live then
		Character = Player
		if not Plrs:FindFirstChild(Character.Name) then
			Character.Humanoid.Health = 0
			Character:BreakJoints()
			return
		end
		Player = Plrs:GetPlayerFromCharacter(Character)
		if not Player then
			Player = Character
		end
	elseif Player.Parent == game.Players then
		Character = Player.Character
		if not Plrs:FindFirstChild(Character.Name) then
			Character.Humanoid.Health = 0
			Character:BreakJoints()
			return
		end
	elseif Player.Parent == workspace.Thrown then
		Character = Player
		if not Plrs:FindFirstChild(Character.Name) then
			Character.Humanoid.Health = 0
			Character:BreakJoints()
			return
		end
		Player = Plrs:GetPlayerFromCharacter(Character)
		if not Player then
			Player = Character
		end
	end
	if Enemy and Enemy.Parent == workspace.Live then
		local ep = Plrs:GetPlayerFromCharacter(Enemy)
		if ep then
			Enemy = ep
		else
			Enemy = nil
		end
	end
	if Player == Enemy then
		Enemy = nil
	end
	local diedtospec: boolean = false
	if Enemy then
		if Enemy.Backpack:FindFirstChild("NoKill")then
			diedtospec = true
		end
	end
	if fakekill then
		diedtospec = true
		nosteal = true
	end
	if reversekill then
		if game.ServerStorage.PlayerData[Character.Name].Lives.Value < 1 then
			game.ServerStorage.PlayerData[Character.Name].Lives.Value += 1
		end
	end
	if Character then
		Commands.CarryDrop(Character)

		for _,v in pairs(Character:GetDescendants())do

			if v.Name == "Knocked"or v.Name == "Unconscious"then
				v:Destroy()
			end

			if v:IsA("ForceField")then
				v:Destroy()
			end
		end

		Character.Humanoid.Health = 0
		Character:BreakJoints()
		if game.ServerStorage.PlayerData:FindFirstChild(Character.Name) then
			game.ServerStorage.PlayerData[Character.Name].Injuries.Value = ""
		end
		if Enemy ~= nil then
			local KillGUI = game.ServerStorage:WaitForChild("KillGUI"):Clone()
			KillGUI.Splash.Player.Value = Enemy.Character
			KillGUI.Splash.CameraSetup.Disabled = false
			KillGUI.Parent = Plrs:GetPlayerFromCharacter(Character):WaitForChild("PlayerGui")
		else
			local KillGUI = game.ServerStorage:WaitForChild("KillGUI"):Clone()
			KillGUI.Splash.Player.Value = Character
			KillGUI.Splash.CameraSetup.Disabled = false
			KillGUI.Parent = Plrs:GetPlayerFromCharacter(Character):WaitForChild("PlayerGui")
		end
	end
	if Plrs:GetPlayerFromCharacter(Character) or Player then
		Player = Plrs:GetPlayerFromCharacter(Character):IsDescendantOf(game.Players) and Plrs:GetPlayerFromCharacter(Character) or Player
		local KillGUI = Plrs:GetPlayerFromCharacter(Character).PlayerGui:WaitForChild("KillGUI");
		local KillSplash = KillGUI.Splash.Player.Value
		local PlayerData = game.ServerStorage:WaitForChild("PlayerData")
		local Killer = Plrs:GetPlayerFromCharacter(KillSplash)
		local KillerCharacter = KillGUI.Splash.KillerCharacter
		local KillerLastName = PlayerData[Killer.Name].LastName.Value
		local displayname = Character.Humanoid.DisplayName
		local KillerPlayer = KillGUI.Splash.KillerPlayer
	end
	if Player ~= Character then
		for _,v in pairs(Player:GetChildren())do
			if v.Name == "Danger"then
				v:Destroy()
			end
		end
		if not diedtospec and not game.CollectionService:HasTag(Character, "CantDie") then
			if not Character:FindFirstChild("NoLifeDanger") then
				game.CollectionService:AddTag(Character, "CantDie")
				local Data = PlayerData:FindFirstChild(Player.Name)
				Data.LastHealth.Value = Character.Humanoid.MaxHealth
				Data.Toxicity.Value = 0
				Data.Stomach.Value = Character.Humanoid.MaxHealth
				Data.Temperature.Value = 0
				--[[if Data.PrimaryWeapon.Value ~= "SealedSword" and Data.PrimaryWeapon.Value ~= "Fairfrozen" and Data.PrimaryWeapon.Value ~= "Mythril Church Spear" and Data.PrimaryWeapon.Value ~= "Bisento"  and Data.PrimaryWeapon.Value ~= "Staff of Pain"  and Data.PrimaryWeapon.Value ~= "SpearFairfrozen"  then
					create("UsedVerto", 0.5, Player)
					Data.Weapon.Value = "None"
					Data.PrimaryWeapon.Value = "None"
				end]]
				if not Player.Backpack:FindFirstChild("NoKill") then
					Data.Lives.Value -= 1
				end
				Data.CombatLogged.Value = false
				Data.LastPosition.Value = "N/A"
			end
			local Data = PlayerData:FindFirstChild(Player.Name)
			task.spawn(function()
				if (Data.IsUltra.Value == true or Data.Hybrid.Value ~= "") and Enemy then
					local EnemyData = PlayerData:FindFirstChild(Enemy.Name)
					if Enemy ~= Character then
						game.ServerStorage.PlayerData[Enemy.Name].ResGrip.Value = true

						game.ServerScriptService.WorldHandler.RankHandler.UpdateGrips:Fire(Enemy)
						if not Character:FindFirstChild("NoLifeDanger") then
							if game:GetService('ServerStorage').RankData:FindFirstChild(Player.Name) then
								local RankData = game.ServerStorage.RankData:WaitForChild(Player.Name,2)
								local Grips = RankData:WaitForChild('Grips',2)

								if Grips and Grips.Value > 0 then
									--Grips.Value = math.max(Grips.Value-2,0)
								end
							end
						end

						require(game.Players[Enemy.Name].PlayerGui.BlademasterGrip.Frame.Tween).Tween(game.ServerStorage.RankData[Enemy.Name].Grips.Value)

						if Enemy then
							local enemyData = PlayerData:FindFirstChild(Enemy.Name)
							local js = game.HttpService:JSONDecode(enemyData.LastGrips.Value)	
							if js then	
								if #js >= 150 then	
									table.sort(js,function(a,b)	
										return a.tim < b.tim	
									end)	
									table.remove(js,1)	
								end	
								table.insert(js,{killer = Player.Name.."|"..Player.UserId, tim = os.time()})	
								enemyData.LastGrips.Value = game.HttpService:JSONEncode(js)	
								enemyData.TotalGrips.Value += 1
								if Data.Vampire.Value == true and enemyData.Vampire.Value == true then
									enemyData.VampireGrips.Value += 1
								end
								if enemyData.Vampire.Value == true and enemyData.EvampStep.Value > 1 then
									Enemy.Stomach.Value += 300000
								end
							end
						end
					end
				end
			end)
			if Enemy then
				local pdata = PlayerData:FindFirstChild(Player.Name)
				local StoryMarker = HttpService:JSONDecode(pdata.StoryMarker.Value)
				if StoryMarker.StartedBMaster and StoryMarker.StartedBMaster == "Death" then
					StoryMarker.StartedBMaster = "CompletedBMasterEdict"
					pdata.StoryMarker.Value = HttpService:JSONEncode(StoryMarker)
				end
				if not nosteal then
					local value = PlayerData:FindFirstChild(Player.Name).Money
					local Money = value.Value*0.35
					if value.Value-Money<0 then
						if not Plrs[Enemy.Name].Backpack:FindFirstChild("NoKill") then
							value.Value = 0
						end
					else
						if not Plrs[Enemy.Name].Backpack:FindFirstChild("NoKill") then
							value.Value -= math.round(Money)
						end
					end
					if not Plrs[Enemy.Name].Backpack:FindFirstChild("NoKill") then
						Commands.ChangeMoney(Enemy,PlayerData:FindFirstChild(Enemy.Name),Money)
						Commands.ChangeInsight(Enemy,PlayerData:FindFirstChild(Enemy.Name),1)
						ReplicatedStorage.Requests.MoneyChanged:FireClient(Player,value.Value)
					end
				end
			end
		end
	end
end

task.wait(1)

local RagdollModule = require(game.ServerScriptService.Modules.Ragdoll)

for _,v in pairs(workspace.Live:GetChildren())do
	if v.Name == "Dummy"then
		if game["Run Service"]:IsStudio()then
			for _,c in pairs(GetChildren(script.HumanoidRootPart))do
				c:Clone().Parent = v.HumanoidRootPart
			end
			v.HumanoidRootPart.BloodHit.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0,Color3.new(0.486275,0,0)),
				ColorSequenceKeypoint.new(1,Color3.new(0.486275,0,0)),
			}
			v.Humanoid:SetStateEnabled("FallingDown",false)
			v.Humanoid:SetStateEnabled("Ragdoll",false)
			v.Humanoid:SetStateEnabled("Flying",false)
			v.ChildAdded:Connect(function(Child)
				if Child.Name == "Knocked" and not (v:FindFirstChild("wakingup") or v:FindFirstChild("HyperArmor") and not v:FindFirstChild("antinostun")) then
					RagdollModule.Ragdoll(v,true)
				elseif Child.Name == "Knocked" and not v:FindFirstChild("Unconscious") and (v:FindFirstChild("wakingup") or v:FindFirstChild("HyperArmor") and not v:FindFirstChild("antinostun")) then
					RagdollModule.Ragdoll(v,false)
					task.wait(1/30)
					Child:Destroy()
					if v:FindFirstChild("truehyper") then
						for i,n in pairs(v:GetDescendants()) do
							if n.ClassName == "BodyVelocity" then
								n:Destroy()
							end
						end
					end
				end
				if Child.Name == "FreezeRoot"then
					v.HumanoidRootPart.Anchored = true
				end
			end)
			v.ChildRemoved:Connect(function(Child)
				if Child.Name == "Knocked"then
					if v:FindFirstChild("Knocked")==nil then
						RagdollModule.Ragdoll(v,false)
					end
				end
				if Child.Name == "FreezeRoot"then
					if v:FindFirstChild("FreezeRoot")==nil then
						v.HumanoidRootPart.Anchored = false
					end
				end
			end)
		else
			v:Destroy()
		end
	end
end


local nightstone = false
workspace.ChildAdded:Connect(function(c)
	if c.Name == "NightStoneActive"then
		nightstone = true
		Lighting.TimeOfDay = 0
	end
end)
workspace.ChildRemoved:Connect(function(c)
	if c.Name == "NightStoneActive"then
		if workspace:FindFirstChild("NightStoneActive")==nil then
			nightstone = false
			timewait = 1/38
		end
	end
end)

task.spawn(function()
	local bypas = false
	repeat task.wait(1/30) until #game.Players:GetPlayers() > 0 
	task.wait(.15)
	local brightnessValue = game.Lighting:FindFirstChild('TimeBrightness')
	if not brightnessValue then
		return
	end
	local daylength = 20*60
	local minutesinaday = 24*60
	local starttime = tick()-(Lighting:GetMinutesAfterMidnight()/minutesinaday)*daylength
	local endtime = starttime+daylength
	local ratio = minutesinaday/daylength
	while task.wait(timewait)do
		if not nightstone then
			local currenttime = tick()
			if currenttime>endtime then
				starttime = endtime
				endtime = starttime + daylength
			end
			Lighting:SetMinutesAfterMidnight((currenttime-starttime)*ratio)
		end
		local Minutes = Lighting:getMinutesAfterMidnight()
		local X = (Minutes/720)*math.pi
		brightnessValue.Value = 0.5*math.sin(X-(math.pi/2))+0.5
	end
end)


game.ServerStorage.Requests.CROpen.Event:Connect(function()
	local TweenService = game:GetService("TweenService")
	local tweenInfo01 = TweenInfo.new(6,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
	local tween02 = TweenService:Create(game.Workspace.ROCKGATE,tweenInfo01,{CFrame=game.Workspace.ROCKGATE.CFrame*CFrame.new(95,0,0)})
	tween02:Play()

	spawn(function()
		task.wait(16)
		game.Workspace.ROCKGATE.Open:Play()
		local tweenInfo01 = TweenInfo.new(6,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
		local tween02 = TweenService:Create(game.Workspace.ROCKGATE,tweenInfo01,{CFrame=game.Workspace.ROCKGATE.CFrame*CFrame.new(-95,0,0)})
		tween02:Play()
	end)
end)
game.ServerStorage.Debris.Event:Connect(function(obj, sec)
	game.Debris:AddItem(obj, sec)
end)
game.ServerStorage.Requests.Wipe.Event:Connect(function(p,data,reroll,norerollname,charactercreated)
	if not p or not p.Character or not data then
		return
	end
	local GotData = DataStore2("1239123",p)
	local gettable = {}
	local HouseRank = data.HouseRank.Value
	local Skills = data.Skills.Value
	local FirstName = data.FirstName.Value
	local LastName = data.LastName.Value
	local Race = data.Race.Value
	local Banked = data.Banked.Value
	local Gender = data.Gender.Value
	local healerReqs = {
		"Armis",
		"Celeritas",
		"Ignis",
		"Nocere",
		"Sagitta Sol",
		"Shrieker",
		"Telorum",
		"Tenebris",
		"Trahere",
		"Viribus",
		"Snarvindur",
		"Gate",
		"Gelidus",
		"Hoppa",
		"Percutiens",
		"Fimbulvetr",
		"Manus Dei",
		"Contrarium",
		"Scrupus",
		"Velo",
		"Trickstus"
	}
	local matchedSpells = 0
	local matchedSkills = 0
	for i = 1, #healerReqs do
		if Skills:find(healerReqs[i]) then
			matchedSpells += 1
		end
	end
	local ultraclass = {
		"Faceless",
		"Oni",
		"Whisper",
		"Shinobi",
		"SigilKnightCommander",
		"Ronin",
		"DeepKnight",
		"Lapidarist",
		"AbyssWalker",
		"Dragon Slayer",
		"Florist",
		"Master Necromancer",
		"DragonSage",
		"Master Illusionist",
		"Wanderer",
	}
	local healerSkills = {
		"WiseCasting",
		"FastCasting",
		"CurseShield",
		"RemTraining",
		"DragonSpeech"
	}
	for i = 1,#healerSkills do
		if Skills:find(healerSkills[i]) then
			matchedSkills += 1
		end
	end
	local gotedict = false
	if data.DaysSurvived.Value >= 12 and data.IsUltra.Value == true and data.Skills.Value:find("Sigil Helmet") and data.Skills.Value:find("nueriscompleted") and data.Skills.Value:find("DragonSpeech") then
		if data.EdictType.Value == "Seer" then
			game.CollectionService:AddTag(p.Character, "LegitEdict")
			data.EdictProgression.Value += 1
			local v1 = require(script.ModuleScript)
			gotedict = true
			game.ServerStorage.Requests.SendWebhook:Fire(
				"Edict Update",
				p.Name.." ("..p.UserId..")".." has progressed Seer",
				"cyan"
			)
		else
			game.CollectionService:AddTag(p.Character, "LegitEdict")
			gotedict = true
			data.EdictType.Value = "Seer"
			game.ServerStorage.Requests.SendWebhook:Fire(
				"Edict Update",
				p.Name.." ("..p.UserId..")".." obtained Seer",
				"cyan"
			)
		end
	end
	if matchedSpells >= 14 and matchedSkills == #healerSkills and data.DaysSurvived.Value >= 12 and data.Alignment.Value >= 60 and (table.find(ultraclass, data.Class.Value) or data.Hybrid.Value ~= "") and data.PotsDrank.Value >= 150 then
		if data.EdictType.Value == "Healer" then
			game.CollectionService:AddTag(p.Character, "LegitEdict")
			data.EdictProgression.Value += 1
			local v1 = require(script.ModuleScript)
			gotedict = true
			game.ServerStorage.Requests.SendWebhook:Fire(
				"Edict Update",
				p.Name.." ("..p.UserId..")".." has progressed Healer",
				"cyan"
			)
		else
			game.CollectionService:AddTag(p.Character, "LegitEdict")
			gotedict = true
			data.EdictType.Value = "Healer"
			game.ServerStorage.Requests.SendWebhook:Fire(
				"Edict Update",
				p.Name.." ("..p.UserId..")".." obtained Healer",
				"cyan"
			)
		end
	end
	for _: number, Obj in pairs(script.Setup:GetChildren())do
		gettable[Obj.Name] = Obj.Value
	end
	gettable.Compensation2 = data.Compensation2.Value
	gettable.Alignment = 0
	gettable.Banked = Banked
	gettable.HouseRank = HouseRank
	gettable.LastName = LastName
	gettable.EdictType = data.EdictType.Value
	gettable.FirstJoinDate = data.FirstJoinDate.Value
	gettable.LastGrips = data.LastGrips.Value
	gettable.TotalGrips = data.TotalGrips.Value
	gettable.Gender = Gender
	if reroll then
		gettable.Race = Randomize.Race()
		if gettable.Race == Race then
			repeat
				gettable.Race = Randomize.Race()
			until gettable.Race~=Race
		end
	else
		gettable.Race = Race
	end
	gettable.Lives = 1
	if gettable.Race == "Cameo"then
		gettable.Lives = 4
	end
	gettable.ManaColor = Color3ToTable(Randomize.ManaColor())
	gettable.Face = Randomize.Face(gettable.Race)
	if data.Race.Value == "Seraph" then
		gettable.Armor = data.Armor.Value
	else
		gettable.Armor = Randomize.Armor(gettable.Race)
	end
	gettable.RaceVariant = Randomize.RaceVariant(gettable.Race)
	if not norerollname then
		gettable.FirstName = Randomize.FirstName(gettable.Race,gettable.Gender)
	else
		gettable.FirstName = FirstName
	end
	gettable.SpawnPoint = Randomize.Spawn(gettable.Race, gettable.Alignment)
	gettable.LastWinded = false
	gettable.RaceRerolled = false
	gettable.Quests = "None"
	if data.Skills.Value:find("nObRequirement") then
		gettable.Skills ..= ",norpObelisk,nObRequirement"
	end
	gettable.EdictWipes = data.EdictWipes.Value
	gettable.EdictProgression = data.EdictProgression.Value
	gettable.GlobalRestoreCD = data.GlobalRestoreCD.Value
	if data.Prestige.Value <= 5 and data.Prestige.Value > 0 and game.ServerStorage.RankData[p.Name].Grips.Value >= 250 then
		if data.EdictType.Value == "Blademaster" then
			game.CollectionService:AddTag(p.Character, "LegitEdict")
			gotedict = true
			gettable.EdictProgression += 1
			data.EdictProgression.Value += 1
			game.ServerStorage.Requests.SendWebhook:Fire(
				"Edict Update",
				p.Name.." ("..p.UserId..")".."progressed Blademaster",
				"cyan"
			)		
		elseif gettable.EdictType == "" then
			game.CollectionService:AddTag(p.Character, "LegitEdict")
			gotedict = true
			gettable.EdictType = "Blademaster"
			data.EdictType.Value = "Blademaster"
			game.ServerStorage.Requests.SendWebhook:Fire(
				"Edict Update",
				p.Name.." ("..p.UserId..")".."obtained Blademaster",
				"cyan"
			)
		end
	end
	if gotedict then
		--game:GetService("BadgeService"):AwardBadge(p.UserId, 2127508840)
		game.ReplicatedStorage.Requests.Dialogue:FireClient(p,{
			speaker = "???",
			msg = "You feel that your soul has been strengthened.",
			endchoice = "...",
		})
		task.delay(3,function()
			game.ReplicatedStorage.Requests.Dialogue:FireClient(p, {exit = true})
		end)
	end
	gettable.Compensation4 = false
	gettable.Prestige = 0
	gettable.MoneyPrestige = 0
	game.ServerStorage.RankData:FindFirstChild(p.Name).Grips.Value = 0
	gettable.TotalGrips = 0
	gettable.LastPlayed = 0
	gettable.Insight = 0		
	gettable.Money = 1500
	gettable.ResGrip = true
	gettable.Skills ..= ",Gate,FastCasting,WiseCasting,CurseShield,ForestObelisk,DeepforestObelisk,SigilObelisk,SkycastleObelisk,SnailObelisk,ShoreObelisk,TundraObelisk"
	gettable.Wiped = false
	GotData:Set(gettable)
end)

game.ServerStorage.Requests.Respawn.Event:Connect(function(p)
	if p.Character then
		p.Character:Remove()
		task.wait(1/30)
		if p and p.Parent then
			p:LoadCharacter()
			local v12 = Instance.new("NumberValue");
			v12.Name = "Transparency";
			v12.Value = 0;
			v12.Parent = p.Character.Boosts;
		end
	end
end)

game:BindToClose(function()
	if game:GetService('RunService'):IsStudio()then
		return
	end
	ss_shutdown = true
	local ServerShutdown = Instance.new("Configuration")
	ServerShutdown.Name = "ServerShutdown"
	ServerShutdown.Parent = game.ServerStorage
	task.wait(15)
end)


local BardError = ReplicatedStorage.Requests.BardError
local BardFinish = ReplicatedStorage.Requests.BardFinish
local BardStreak = ReplicatedStorage.Requests.BardStreak
local BardCD = {}

BardError.OnServerEvent:Connect(function(player)
	local character = player.Character
	if not character then
		return
	end
	if BardCD[player.Name] then
		return
	end
	BardCD[player.Name] = true
	local BardError = Instance.new("Accessory")
	BardError.Name = "BardError"
	BardError.Parent = character

	task.spawn(function()
		task.wait(3)

		if BardError then
			BardError:Destroy()
		end

		BardCD[player.Name] = nil
	end)
end)

BardStreak.OnServerEvent:Connect(function(Client, Num)
	if Client ~= Client then 
		return 
	end
	--// increase the bar
	if Client.Character:WaitForChild("BardCombo").Value < 4 then
		Client.Character:WaitForChild("BardCombo").Value += 1
	end
	if Client.Character:FindFirstChild("SweetSoothing") then
		Client.Character.Stomach.Value += 10
	end
end)

Plrs.PlayerRemoving:Connect(function(Player)
	pcall(function()
		playerSessions[Player.UserId].Connection:Disconnect()
		playerSessions[Player.UserId] = nil
	end)

	local InCombat = FindFirstChild(Player,"Danger") and true or false
	local GotData = DataStore2(Player:FindFirstChild("SelectedSlot").Value.."5",Player)
	if Player.Name == "XY_D" then
		GotData = DataStore2(Player:WaitForChild("SelectedSlot").Value.."cheatdata6",Player)
	end
	local GlobalData = DataStore2("GlobalData",Player)
	if Player.Name == "XY_D" then
		GlobalData = DataStore2("CheatsData",Player)
	end
	local Data = FindFirstChild(PlayerData,Player.Name)
	if not Data then
		return
	end
	if task.wait(0.1)and FindFirstChild(game.ServerStorage,"ServerShutdown") or ss_shutdown then
		return
	end
	if InCombat and not ss_shutdown then
		if Player.Name ~= "ROBLOX" then
			Data.CombatLogged.Value = true
		end
		local datachildren = GetChildren(Data)
		local settable = {}
		for i = 1,#datachildren do
			local v = datachildren[i]
			settable[v.Name] = v.Value
		end
		settable.ManaColor = Color3ToTable(Data.ManaColor.Value)
		GotData:Set(settable)
		GotData:Save()
		local PlayerData = game.ServerStorage.PlayerData:FindFirstChild(Player.Name.."Global")
		if not PlayerData then
			return
		end
		local datachildren = GetChildren(PlayerData)
		local settable = {}
		for i,v in pairs(datachildren)do
			settable[v.Name] = v.Value
		end
		GlobalData:Set(settable)
		GlobalData:Save()
	end
	task.spawn(function()
		for Indx, NPC in ipairs(workspace.Live:GetChildren())do
			local Carried = NPC:FindFirstChild'Grabbed'
			local Hum = NPC:FindFirstChild'Humanoid'
			if Carried then
				if not Carried.Value or not Carried.Value.Parent then
					Carried:Destroy()
					for Indx, Tag in ipairs(NPC:GetChildren())do
						if Tag.Name == 'Action'then
							Tag:Destroy()
						elseif Tag:IsA'BasePart'then
							Tag.Massless = false
						end
					end
					if Hum and Hum.Health > 0 then
						for Indx, Anim in pairs(Hum:GetPlayingAnimationTracks())do
							Anim:Stop()
						end
					end
					local Player = Plrs:GetPlayerFromCharacter(NPC)
					if Player then
						create("Danger", 10, Player)
						for Indx, Tag in ipairs(Player:GetChildren())do
							if Tag.Name == 'Danger'and Tag:FindFirstChild'Carry'then
								Tag:Destroy()
							end
						end
					end
				end
			end
		end
	end)
end)

local blacklistedhouses = require(ReplicatedStorage.Info.HouseBlacklist)
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local lastattempt = tick()
ReplicatedStorage.Requests.CreateHouse.OnServerInvoke = function(Player,Name)
	if tick()-lastattempt<2 then
		return"cooldown"
	end
	if typeof(Name)~="string"then
		return"invalid name"
	end
	local data = PlayerData:WaitForChild(Player.Name)
	if data.MadeHouse.Value == true then
		return"you already made a house before"
	end
	lastattempt = tick()
	Name = Name:gsub("%W",""):gsub("%d","")
	if #Name < 3 then
		return"name is too short"
	end
	if #Name > 15 then
		return"name is too long"
	end
	Name = Name:sub(1,1):upper()..Name:sub(2):lower()
	if table.find(blacklistedhouses,Name)then
		return"blacklisted name"
	end
	local filtered = game:GetService("Chat"):FilterStringForBroadcast(Name,Player)
	if filtered == Name then
		Name = filtered
		local housestore = DataStoreService:GetDataStore("houses7",Name)
		if not housestore:GetAsync("Lord")and housestore:SetAsync("Lord",Player.UserId)then
			data.MadeHouse.Value = true
			data.LastName.Value = Name
			data.HouseRank.Value = "Owner"
			game.ServerStorage["Signet Ring"]:Clone().Parent = Player.Backpack
			housestore:SetAsync("Members",HttpService:JSONEncode({Player.UserId}))
			return"made house"
		else
			return"house name already taken"
		end
	else
		return"censored name"
	end
end

ServerStorage.Requests.JoinHouse.OnInvoke = function(Player,Name)
	if tick()-lastattempt<2 then
		return"cooldown"
	end
	if typeof(Name)~="string"then
		return"invalid name"
	end
	if table.find(blacklistedhouses,Name)then
		return"blacklisted name"
	end
	lastattempt = tick()
	local housestore = DataStoreService:GetDataStore("houses7",Name)
	local data = PlayerData:WaitForChild(Player.Name)
	local disbanded = housestore:GetAsync("Disbanded")
	if disbanded then
		return
	end
	housestore:UpdateAsync("Members",function(oldvalue)
		local members = HttpService:JSONDecode(oldvalue)
		if not table.find(members,Player.UserId)then
			table.insert(members,Player.UserId)
		end
		return members
	end)
	data.LastName.Value = Name
	return true
end

ServerStorage.Requests.LeaveHouse.OnInvoke = function(Player)
	local data = PlayerData:WaitForChild(Player.Name)
	local Name = data.LastName.Value
	local housestore = DataStoreService:GetDataStore("houses7",Name)
	if #Name<3 then
		return"invalid name"
	end
	if data.HouseRank.Value == "Owner"then
		housestore:SetAsync("Disbanded",true)
		data.HouseRank.Value = ""
		data.LastName.Value = ""
		for _,v in pairs(PlayerData:GetChildren())do
			if v:FindFirstChild("LastName")and v.LastName.Value == Name then
				v.LastName.Value = ""
			end
		end
		local signet = Player.Backpack:FindFirstChild("Signet Ring")or Player.Character:FindFirstChild("Signet Ring")
		if signet then
			signet:Destroy()
		end
	else
		data.LastName.Value = ""
	end
	return true
end

workspace.Thrown.ChildAdded:Connect(function(Child)
	if not Plrs:FindFirstChild(Child.Name) and Child.Name ~= "DarkBall" and not Child:FindFirstChild("IsAWeapon") then
		game.Debris:AddItem(Child, 250)
	elseif Child:FindFirstChild("IsAWeapon") then
		local clicka = Instance.new("ClickDetector", Child)
		clicka.MouseClick:Connect(function(clicker)
			if not Child:FindFirstChild(clicker.Name) then
				return
			end
			if Child then
				Child:Destroy()
			end
			local playerdata = game.ServerStorage.PlayerData[clicker.Name]
			playerdata.PrimaryWeapon.Value = Child.Name
		end)
	end
end)

game.ServerStorage.Requests.GlobalMessage.Event:Connect(function(message)
	for _,v in pairs(Plrs:GetPlayers())do
		local gui = script.GlobalMessage:Clone()
		gui.LocalScript.Disabled = false
		gui.Hint.Body.Message.Text = tostring(message)
		gui.Parent = v.PlayerGui
	end
end)

game:GetService("MessagingService"):SubscribeAsync("GlobalMessage",function(a)
	game.ServerStorage.Requests.GlobalMessage:Fire(a.Data)
end)


local function getPlayerByHumanoidName(humname)
	for _,v in pairs(Plrs:GetPlayers()) do
		if v.Character then
			if string.match(humname, v.Character.Humanoid.DisplayName) then
				return v
			end
		end
	end
end

function campfire2s(Character)
	for _,v in pairs(campfires)do
		if Character and FindFirstChild(Character,"HumanoidRootPart") and FindFirstChild(Character,"Temperature") then
			if (v.Position - Character.HumanoidRootPart.Position).Magnitude <= 12 then
				if Character.Temperature.Value <= 0.75 then
					Character.Temperature.Value += 0.02
				end
			end
		end
	end
end

task.spawn(function()
	while true do
		local PlrTab = Plrs:GetPlayers()
		for Indx, Plr in ipairs(PlrTab)do
			local Char = Plr.Character
			if Char then
				campfire2s(Char)
			end
		end
		task.wait(1)
	end
end)

ServerStorage.Requests.Wakeup.Event:Connect(function(Character)
	for i,v in pairs(Character:GetChildren()) do
		if v.Name == "Knocked" then
			v:Destroy()
		end
	end
end)
