local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local Ragdoll = require(ServerScriptService.Modules.Ragdoll)
local EffectModule = require(ServerScriptService.Modules.EffectModule)
local TagHumanoid = ServerStorage:WaitForChild("Requests"):WaitForChild("TagHumanoid")

local Live, currentMonsters = workspace.Live, {};
local expirationTicks = {}

local Tab = script.DecisionModules:GetChildren()
local thinkModules = {}
for i,v in next, Tab do
	thinkModules[v.Name] = require(v)
end

local Monsters = {}

local monsterId = 0
local function SpawnMonster(monsterType, position, master, dropsEnabled, Alignment, Sp)
	if not Alignment then Alignment = 7 end;
	if not script.MonsterModels:FindFirstChild(monsterType) then return end;

	local monster = script.MonsterModels[monsterType]:Clone()
	monster.Name = "." .. monster.Name .. monsterId
	monsterId = monsterId +1

	monster.Humanoid.Died:Connect(function()
		pcall(function()
			thinkModules[monsterType].die(monster)
		end)
		if monster:FindFirstChild("Spawner") then
			monster.Spawned.Value = false
		end

		if Sp and Sp:FindFirstChild("Spawned") then
			Sp.Spawned.Value = false
		end
	end)

	if monsterType == "Shrieker" or monsterType == "Husk" then
		monster.ChildAdded:Connect(function(obj)
			if obj.Name == "FreezeRoot" and monster:FindFirstChild("HumanoidRootPart") then
				monster.HumanoidRootPart.Anchored = true
			end
			if obj.Name == "Knocked" and monster:FindFirstChild("Humanoid") then
				task.spawn(function()
					monster.Humanoid.PlatformStand = true
					Ragdoll.Ragdoll(monster, true);
				end)
			end
		end)

		monster.ChildRemoved:Connect(function(obj)
			if obj.Name == "FreezeRoot" and monster:FindFirstChild("HumanoidRootPart") then
				repeat wait() until not obj or not obj.Parent
				if not monster:FindFirstChild("FreezeRoot") then
					monster.HumanoidRootPart.Anchored = false
				end
			end
			if obj.Name == "Knocked" and monster:FindFirstChild("Humanoid") and not monster:FindFirstChild("Knocked") then
				task.spawn(function()
					monster.Humanoid.PlatformStand = false
					Ragdoll.Ragdoll(monster, false);
				end)
			end
		end)
	end

	monster.MonsterInfo.LastAggrod.Value = tick()
	monster.MonsterInfo.Alignment.Value = Alignment
	monster.MonsterInfo.SpawnedTime.Value = tick()
	monster.Parent = workspace.Live

	if monster.Animations:FindFirstChild("Idle") then
		monster.Humanoid:LoadAnimation(monster.Animations.Idle):Play()
	end

	for _,v in next, ServerScriptService.WorldHandler.GameLoaded.HumanoidRootPart:GetChildren() do
		if not monster.HumanoidRootPart:FindFirstChild(v.Name) then
			v:Clone().Parent = monster.HumanoidRootPart
		end
	end

	monster.HumanoidRootPart.CFrame = CFrame.new(position)
	--[[
	if monsterType == "Terra Serpent" then
		task.spawn(function()
			local spawnpos = position
			local currentposition = position
			repeat wait() until (monster.HumanoidRootPart.Position - position).Magnitude <= 20
			while wait(0.5) do
				if monster and monster.HumanoidRootPart.Position ~= currentposition then
					currentposition = monster.HumanoidRootPart.Position
				end
				if (currentposition - spawnpos).Magnitude <= 300 then
					break
				end
				wait(1)
			end
			if monster then
				monster.Humanoid.Health = 0
			end
		end)
	end
	]]
	if master then
		monster.MonsterInfo.Master.Value = master

		if monster.Variables:FindFirstChild("Scout") then
			monster.Variables.Scout.Value = false
		end
	end

	if not dropsEnabled then
		local noDrop = Instance.new("Accessory")
		noDrop.Name = "NoDrops"
		noDrop.Parent = monster
	end

	local Tab = monster:GetDescendants()
	for Idx=1,#Tab do
		local Obj = Tab[Idx]
		if Obj:IsA("BasePart") then
			Obj:SetNetworkOwner(nil)
		end
	end

	--[[
	if monsterType == "Terra Serpent" then
		for i,v in pairs(monster:GetDescendants()) do
			if v:IsA("BasePart") then
				game:GetService("PhysicsService"):SetPartCollisionGroup(v,"TERRA_SERPENT")
			end
		end
	end
	--]]

	local monsterTbl = {}
	monsterTbl.monster = monster
	monsterTbl.tracks = {}

	for i,anim in next, monster.Animations:GetChildren() do
		monsterTbl.tracks[anim.Name] = monster.Humanoid:LoadAnimation(anim)
	end

	expirationTicks[monster] = tick()
	thinkModules[monsterType].setup(monster, monsterTbl.tracks)
	currentMonsters[#currentMonsters+1] = monsterTbl
	
	if Sp then
		Monsters[Sp] = monster
	end

	return monster
end

local function resetExpiration(monster)
	expirationTicks[monster] = tick()
end

ServerStorage.Requests.ResetMonsterExpiration.OnInvoke = resetExpiration

ServerStorage.Requests.SpawnMonster.OnInvoke = SpawnMonster

local MonsterSpawns = workspace.MonsterSpawns
local Groups = MonsterSpawns.Groups
local Triggers = MonsterSpawns.Triggers
local Tab = Triggers:GetChildren()

for Indx, Trigger in  pairs(Tab) do
	Trigger.Transparency = 1
	Trigger.Touched:Connect(function(part)
		if not part.Parent then
			return
		end
		if Trigger:FindFirstChild("OnCD") then return end;
		if Trigger:FindFirstChild("OncePerServer") and Trigger.OncePerServer.Value then return end;
		local Hu = part.Parent:FindFirstChild("Humanoid") or part.Parent.Parent:FindFirstChild("Humanoid")
		if Hu and Hu.Health > 0 then
			local Group = Groups:FindFirstChild(Trigger.Name)
			if Group then
				--[[if Trigger:FindFirstChild("OncePerServer") then
					Trigger.OncePerServer.Value = true
				end]]
				local spawned: boolean = false
				local Tab = Group:GetChildren()
				for Indx, Sp in pairs(Tab)do
					if Sp.Spawned.Value then
						if not Monsters[Sp] or Monsters[Sp].Parent ~= workspace.Live then
							Sp.Spawned.Value = false
						else
							spawned = true
						end
					end
				end
				if not spawned then
					if Trigger.Name == "CryptTrigger" and Trigger.Down.Value == true then return end
					for Indx, Sp in pairs(Tab)do
						Sp.Spawned.Value = true
						local monster = SpawnMonster(Sp.Name, Sp.Position, nil, true, nil, Sp)
						if not monster or (monster and not monster.Parent) then Sp.Spawned.Value = false return end;
						if Trigger.Name == "CryptTrigger" and Trigger.Down.Value == false then
							Trigger.Down.Value = true;
							TweenService:Create(Trigger.Doorz, TweenInfo.new(0.4), {
								Position = Vector3.new(Trigger.Doorz.Position.X, 197.956, Trigger.Doorz.Position.Z)
							}):Play();
							Trigger.Doorz.Close:Play()
							task.delay(60, function()
								TweenService:Create(Trigger.Doorz, TweenInfo.new(1.104), {
									Position = Vector3.new(Trigger.Doorz.Position.X, 228.154, Trigger.Doorz.Position.Z)
								}):Play();
								Trigger.Doorz.Open:Play()
								task.delay(60, function()
									Trigger.Down.Value = false;
								end)

							end)
						end
						if Sp:FindFirstChild("MakeScout") and monster.Variables:FindFirstChild("Scout") then
							monster.Variables.Scout.Value = true
						end
						if Sp:FindFirstChild("CastleRock") then
							monster.Variables.CastleRockSnake.Value = true
						end
						local objRef = Instance.new("ObjectValue")
						objRef.Name = "Spawner"
						objRef.Value = Sp
						objRef.Parent = monster
					end
					
					if Trigger:FindFirstChild("Cooldown") then
						local great = Instance.new("BoolValue")
						great.Name = "OnCD"
						great.Parent = Trigger
						game.Debris:AddItem(great, Trigger:FindFirstChild("Cooldown").Value)
					end
				end
			else
				warn("No spawn group matches: "..Trigger.Name)
			end
		end
	end)
end

local RCP: RaycastParams = RaycastParams.new()
RCP.FilterDescendantsInstances = {}
RCP.FilterType = Enum.RaycastFilterType.Blacklist
RCP.IgnoreWater = true
while task.wait(0.2) do
	local live = Live:GetChildren()
	for i,monsterTbl in ipairs(currentMonsters)do
		pcall(function()
			local monster = monsterTbl and monsterTbl.monster
			if monster and monster.Parent and monster:FindFirstChild("HumanoidRootPart") and monster:FindFirstChild("Humanoid") then
				local mhum = monster.Humanoid
				if monster:FindFirstChild("Action") or monster:FindFirstChild("Knocked") or monster:FindFirstChild("Unconscious") or monster:FindFirstChild("NoMove") then
					mhum.WalkSpeed = 0
				elseif monster:FindFirstChild("Stun") then
					mhum.WalkSpeed = monster.MonsterInfo.StunnedSpeed.Value
				else
					local base = monster.MonsterInfo.BaseWalkSpeed.Value
					if monster:FindFirstChild("Sprinting") and not monster:FindFirstChild("StoppedAttack") then
						base += monster.MonsterInfo.SprintBoost.Value
					end
					for _,boost in ipairs(monster.Boosts:GetChildren())do
						if boost.Name == "WalkSpeedBoost" then
							base += boost.Value
						end
					end
					mhum.WalkSpeed = base
				end
				if not monster:FindFirstChild("DontExpire") then
					local expiry = monster:FindFirstChild("Summoned") and 600 or monster:FindFirstChild("LongExpire") and 400 or 120
					if expirationTicks[monster] then
						if tick() - expirationTicks[monster] > expiry then
							local sp = monster:FindFirstChild("Spawner").Value
							sp.Value = false
							monster.Spawned.Value = false
							expirationTicks[monster] = nil
							monster:Destroy()
							table.remove(currentMonsters, i)
						end
					else
						expirationTicks[monster] = tick()
					end
				end
				if monster.MonsterInfo.Master.Value and not monster.MonsterInfo.Master.Value.Parent then
					thinkModules[monster.MonsterInfo.MonsterType.Value].die(monster)
					table.remove(currentMonsters, i)
				else
					local ThinkType = thinkModules[monster.MonsterInfo.MonsterType.Value]
					if not ThinkType then
						warn("No ThinkType for monster!")
						return
					end
					if monster:FindFirstChild("Spawner")then
						if not monster.MonsterInfo.Aggrod.Value and tick() - monster.MonsterInfo.LastAggrod.Value > 120 and not (monster.Variables:FindFirstChild("CastleRockSnake") and monster.Variables.CastleRockSnake.Value) then
							local found: boolean = false
							for _,char in ipairs(Live:GetChildren())do
								local cHRP = char:FindFirstChild'HumanoidRootPart'
								if cHRP and monster:FindFirstChild("HumanoidRootPart") then
									local obscuring = workspace:Raycast(monster.HumanoidRootPart.Position, (char.HumanoidRootPart.Position - monster.HumanoidRootPart.Position), RCP)
									if not obscuring then
										found = true
									end
								end
							end
							if not found then
								monster.Spawned.Value = false
								monster:Destroy()
								local sp = monster:FindFirstChild("Spawner").Value
								sp.Value = false
								table.remove(currentMonsters, i)
							else
								task.spawn(ThinkType.think, monster, live, monsterTbl.tracks)
							end
						else
							task.spawn(ThinkType.think, monster, live, monsterTbl.tracks)
						end
					else
						task.spawn(ThinkType.think, monster, live, monsterTbl.tracks)
					end
				end
			else
				if monster and monster.Parent then
					thinkModules[monster.MonsterInfo.MonsterType.Value].die(monster)
				end
				expirationTicks[monster] = nil
				table.remove(currentMonsters, i)
			end
		end)
	end
end