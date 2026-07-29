local FindFirstChild,WaitForChild = game.FindFirstChild,game.WaitForChild
local CollectionService = game:GetService("CollectionService")
local HasTag = CollectionService.HasTag
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Commands = require(ServerScriptService.Modules.Commands)
local Create = require(ServerScriptService.Modules.Create)
local Requests = ReplicatedStorage:WaitForChild("Requests")
local Stats = ServerStorage["PlayerData"]
function Requests.Get.OnServerInvoke(p,v1)
	local infotable = {}
	local plrstats = WaitForChild(Stats, p.Name)
	for _,v in pairs(plrstats:GetChildren())do
		if table.find(v1,v.Name)then
			infotable[v.Name] = v.Value
		end
	end
	return infotable
end

Requests.ShowMaxEdict.OnServerInvoke = function(Player)
	if (Stats[Player.Name]).EdictProgression.Value >= 10 then
		Player.leaderstats:WaitForChild("MaxEdict").Value = true
	end
end

Requests.SetCurrentArea.OnServerEvent:Connect(function(p,area)
	if not p.Character then
		return
	end
	local data = FindFirstChild(Stats,p.Name)
	if not data then
		return
	end
	if FindFirstChild(workspace.AreaMarkers,area)then
		data:WaitForChild'Area'.Value = area
		if area ~="Lannis's Lab"and area~="Castle Rock"then
			if FindFirstChild(p.Character,"INCR")then
				p.Character.INCR:Destroy()
			end
		end
		if not(area == "Decaying Isle")then
			if FindFirstChild(p.Character,"IN")then
				p.Character.IN:Destroy()
			end
		end
	end
end)

function CheckStun(ActionTable,Model)
	local _Return = false
	for Index,Value in pairs(Model:GetChildren()) do
		if table.find(ActionTable, Value.Name) then
			_Return = true
		end
	end
	return _Return
end

Requests.Reset.OnServerInvoke = function(Player)
	if Player ~= Player then
		return
	end
	local PlayerData = game:GetService("ServerStorage"):FindFirstChild("PlayerData"):FindFirstChild(Player.Name)
	if not PlayerData then
		return
	end
	local LastReset = PlayerData:WaitForChild("LastReset")
	local DaysSurvived = PlayerData:WaitForChild("DaysSurvived")
	local Area = PlayerData:WaitForChild("Area")
	local AreaData = require(game:GetService("ReplicatedStorage").Info.AreaData)
	local Biome = AreaData.biomes[Area.Value]
	if DaysSurvived.Value - LastReset.Value < 1 then
		return
	end
	if FindFirstChild(Player,"Danger") then
		return
	end
	if FindFirstChild(Player.Character,"Climbing") then
		return
	end
	if FindFirstChild(Player.Character,"ActiveCast") then
		return
	end
	if FindFirstChild(Player.Character,"Grabbed") then
		return
	end
	if not FindFirstChild(Player.Character,"Humanoid") then
		return
	end
	if HasTag(CollectionService,Player.Character,"Knocked") then
		return
	end
	if HasTag(CollectionService,Player.Character,"Unconscious") then
		return
	end
	if Player.Character.Humanoid.Health <= 0 then
		return
	end
	if string.match(Biome, "tundra") then
		return
	end
	LastReset.Value = DaysSurvived.Value
	local CanReset = true
	local ActionTable = {
		"Stun",
		"LannisCD",
		"Knocked",
		"Unconscious",
		"SunBurn",
		"Danger",
		"NoDam",
	}
	local ResetBillboard = script.Reset.BillboardGui:Clone()
	ResetBillboard.Parent = Player.Character
	ResetBillboard.Adornee = Player.Character["Head"]
	local ActionTag = Instance.new("Accessory")
	ActionTag.Name = "Action"
	ActionTag.Parent = Player.Character
	local AttemptReset = Instance.new("Accessory")
	AttemptReset.Name = "Resetting"
	AttemptReset.Parent = ActionTag
	for Index = 1,60 do
		ResetBillboard.TextLabel.Text = (60 - Index)
		if Index == 60 then
			CanReset = true
			break
		end
		if CheckStun(ActionTable,Player) then
			CanReset = false
			break
		end
		if CheckStun(ActionTable,Player.Character) then
			CanReset = false
			break
		end
		task.wait(1)
	end
	if CanReset then
		Player.Character:BreakJoints()
	end
	ActionTag:Destroy()
	ResetBillboard:Destroy()
	AttemptReset:Destroy()
end

local HttpService = game:GetService("HttpService")
local JsonEncode = HttpService.JSONEncode

game.ReplicatedStorage.Requests.DestroyWeapon.OnServerEvent:Connect(function(plr, mat)
	if workspace.Thrown:FindFirstChild(mat) then
		workspace.Thrown[mat]:Destroy()
	end
end)

--[[Requests.UpdateSlotData.OnServerEvent:Connect(function(p,SlotData)
	local plrstats = WaitForChild(Stats,p.Name)
	if not plrstats then
		return
	end

	local Data = JsonEncode(HttpService,SlotData)
	if Data then
		plrstats.SlotData.Value = Data
	end
end)]]

Requests.UpdateSettings.OnServerEvent:Connect(function(p,Settings)
	local Data = game.HttpService:JSONEncode(Settings)
	if Data then
		local plrstats = Stats:WaitForChild(p.Name)
		plrstats.Settings.Value = Data
	end
end)

game.ReplicatedStorage.Requests.GiveWeapon.OnServerEvent:Connect(function(Player, Weapon, FoundPart)
	if Player~= Player then 
		return 
	end

	if not FoundPart or not typeof(FoundPart) == "Instance" then
		Player:Kick([[
		
		Quran 2: 216

		But perhaps you hate a thing and it is good for you; and perhaps you love a thing and it is bad for you. And Allah Knows, while you know not.
		
		]])
		return
	end

	if not FoundPart:IsDescendantOf(workspace.Thrown) then
		Player:Kick("ALLAH!!!")
	end

	if (Player.Character.HumanoidRootPart.Position - FoundPart.Position).Magnitude >= 15 or not FoundPart:FindFirstChild(Player.Name)  then
		Player:Kick([[
		
		Qur’an, Al-Ma’idah, 5:11

		Believers, do not forget how Allah bestowed His favor upon you by restraining the hands of those who sought to harm you; so remain conscious of Allah, and depend only upon your Lord.
		
		]])
		return
	end

	require(game.ServerScriptService.Modules.Commands)["ChangeWeapon"](Player,Weapon, true)
	FoundPart:Destroy()
end)



game.ServerStorage.Requests.HasSkill.OnInvoke = function(player,skill)
	local data = game.ServerStorage.PlayerData:FindFirstChild(player.Name)
	if data then
		local skills = string.split(data.Skills.Value,",")
		if table.find(skills,skill)then
			return true
		else
			return false
		end
	end
end

game.ServerStorage.Requests.GetStoryMarker.OnInvoke = function(Player,Total)
	return true
end

--[[game.ServerStorage.Requests.Injure.OnInvoke = function(player,injurytable)
	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		for _,v in pairs(injurytable) do
			game.ServerStorage.PlayerData:FindFirstChild(player.Name).Injuries.Value = game.ServerStorage.PlayerData:FindFirstChild(player.Name).Injuries.Value..","..v
		end

		game.ServerStorage.Requests.TagHumanoid:Fire(player.Character,player.Character,{injury = true})
		player.Character.HumanoidRootPart.Injury:Play();
		local Injury = ReplicatedStorage.Assets.Injure:Clone();
		Injury.Parent = player.Character.HumanoidRootPart;
		Injury:Emit(2);
		game.Debris:AddItem(Injury, 1.5);
	end
end]]

local function DropBag(Type: string, Name: string, Character: Model)
	local Root = Character:FindFirstChild'HumanoidRootPart'
	if not Root then
		return
	end
	local ray = Ray.new(Root.CFrame*CFrame.new(0,-1,-4).Position,Root.CFrame.LookVector*2+Vector3.new(0,-500,0))
	local hit,pos = workspace:FindPartOnRayWithIgnoreList(ray,{workspace.Live})
	local BagCFrame: CFrame = Root.CFrame * CFrame.new(0,-2.75,-4.5)
	if hit then
		BagCFrame = CFrame.new(pos) * CFrame.new(0,0.25,0)
	end
	local Bag = game.ServerStorage.Assets.ToolBag:Clone()
	Bag.BillboardGui.Tool.Text = Name
	if Type ~= "Money" then
		if string.find(Bag.BillboardGui.Tool.Text, "Poisonous") or string.find(Bag.BillboardGui.Tool.Text, "Demisesous") then
			Bag.BillboardGui.Tool.Text = "Meat"
		end
	end
	Bag.CFrame = BagCFrame
	Bag.Transparency = 0.8
	Bag.Parent = workspace.Thrown
	task.wait(0.2)
	Bag.Transparency = 0
	local PickedUp: boolean = false
	Bag.Touched:Connect(function(part)
		if PickedUp then return end
		if part.Parent and part.Parent:FindFirstChild("Humanoid")and part.Parent.Humanoid.Health>1 then
			local Character = part.Parent
			if not Character then
				return
			end
			if not Character:FindFirstChild("HumanoidRootPart")then return end
			if Character:FindFirstChild("Carried")then return end
			if not game.Players:FindFirstChild(Character.Name) then return end
			local mag = (BagCFrame.Position - Character.PrimaryPart.Position).Magnitude
			local Player = game.Players:GetPlayerFromCharacter(Character)
			local PlayerStats = game.ServerStorage["PlayerData"]:FindFirstChild(Player.Name)
			if not PlayerStats then return end
			if mag <= 20 then
				PickedUp = true
				Bag:Destroy()
				if Type == "Money"then
					Commands["ChangeMoney"](Player,PlayerStats,tonumber(Name))
				else
					if ServerStorage.Alchemy.Models:FindFirstChild(Name) or ServerStorage.Alchemy.Tools:FindFirstChild(Name) then
						local toolHandler = require(game.ServerScriptService.ToolHandler)
						if ServerStorage.Alchemy.Models:FindFirstChild(Name) then
							toolHandler.GiveAlchemy(Player,Name,true)
						else
							toolHandler.GiveAlchemy(Player,Name)
						end
					else
						Commands["AddToInventory"](Player,Name)
					end
				end
			elseif mag > 100 and not Character:FindFirstChild("TPSafe") then
				game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(Player.Name, true)
				Player:Kick("you are so dumb")
			end
		end
	end)
end
_G.DropBag = DropBag
Requests.Drop.OnServerEvent:Connect(function(p, Path)
	if not Path then return end
	local Character = p.Character
	if not Character or not(Character.Parent == workspace.Live)or not(Character:FindFirstChild("HumanoidRootPart"))then
		return
	end
	if Character:FindFirstChild("DropCooldown")then return end
	if Character:FindFirstChild("Humanoid").Health<=1 then return end
	if Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
		return
	end
	local Number: number? = tonumber(Path)
	if not Number then
		if Path.Parent ~= Character and Path.Parent ~= p.Backpack then
			return
		end
	end
	local PlayerStats = Stats:FindFirstChild(p.Name)
	if not PlayerStats then return end
	Create("Danger",15,p)
	Create("DropCooldown",2,Character)
	if Number then
		if PlayerStats.Money.Value - Number < 0 then return end
		if Number > 5000 then
			Number = 5000
		end
		if Number < 1 then
			return
		end
		if Number ~= Number then
			return
		end
		Number = math.floor(Number)
		Commands["ChangeMoney"](p,PlayerStats, -Number)
		DropBag("Money",Number,Character)
		return
	else
		if Path:FindFirstChild("Droppable") then
			task.spawn(DropBag, Path, Path.Name, Character)
			Commands["RemoveFromInventory"](p,Path.Name)
		end
	end
end)

local last_action_check = os.time()
local last_player_fired_action_check = nil

Requests.GetMMInfo.OnServerInvoke = function(Player,toGet)
	if not toGet or not toGet.Parent then return false end
	if _G.GetAdminLevel(Player.UserId) > 0.5 then
		local pData = game.ServerStorage.PlayerData:FindFirstChild(toGet.Name)
		if not pData then return false end
		local send = {}
		if pData.Hybrid.Value ~= "" then
			send.Class = pData.Class.Value .. "-" .. pData.Hybrid.Value
		else
			send.Class = pData.Class.Value
		end
		send.CharacterName = (pData.HouseRank.Value == "Owner" and "Lord " or "").. pData.FirstName.Value .. " " .. pData.LastName.Value
		send.Race = pData.Race.Value
		send.Edict = pData.EdictType.Value
		send.FirstJoin = pData.FirstJoinDate.Value
		send.Days = pData.DaysSurvived.Value
		send.Shifted = toGet:FindFirstChild("Shifted") and toGet:FindFirstChild("Shifted").Value or false
		send.TotalGrips = pData.TotalGrips.Value
		send.LastGrips = pData.LastGrips.Value
		local tgAd = _G.GetAdminLevel(toGet.UserId)
		send.SpecWhitelist = (tgAd > 0) or false
		send.AdminLevel = tgAd
		return send
		--[[
				infoFrame.Class.Val.Text = pData.Class
				infoFrame.CharacterName.Val.Text = pData.CharacterName
				infoFrame.Race.Val.Text = pData.Race
				infoFrame.Edict.Val.Text = pData.Edict
				infoFrame.FirstJoin.Val.Text = pData.FirstJoin
				infoFrame.Days.Val.Text = pData.Days
				infoFrame.Shifted.Val.Text = pData.Shifted
				infoFrame.TotalGrips.Val.Text = pData.TotalGrips
				infoFrame.SpecWhitelist.Val.Text = pData.SpecWhitelist
				infoFrame.AdminLevel.Val.Text = pData.AdminLevel
		]]
	end
	return false
end