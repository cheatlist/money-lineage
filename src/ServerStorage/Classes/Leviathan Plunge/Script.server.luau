function sub(...)
	coroutine.wrap(...)()
end
local u1 = require(game.ServerScriptService.Modules.HitDetection)
local u2 = game.ServerStorage.Requests.TagHumanoid
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local canuse = true
local clone = game.ServerStorage.Assets.LightArrow
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Leviathan Plunge") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Leviathan Plunge"
	CD.Value = 60
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 60)
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	p1.Humanoid:LoadAnimation(script.Plunge):Play()
	local v1 = Instance.new("Accessory")
	v1.Name = "Action"
	v1.Parent = p1
	
	local part = Instance.new("Part", workspace.Thrown)
	part.Size = Vector3.new(1, 0.1, 1)
	part.Color = Color3.new(0,0,0)
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Transparency = 0
	part.CFrame = HumanoidRootPart.CFrame + HumanoidRootPart.CFrame.lookVector*1 - Vector3.new(0, 2.9, 0)
	local mesh = Instance.new("SpecialMesh", part)
	mesh.MeshType = Enum.MeshType.Sphere
	game.Debris:AddItem(part, 1.5)
	local tweenservice = game:GetService("TweenService")
	local goal = {}
	goal.Size = Vector3.new(5, 0.2, 5)
	local tweeninfo = TweenInfo.new(0.3)
	local tween = tweenservice:Create(part, tweeninfo, goal)
	tween:Play()
	
	game.Debris:AddItem(v1,1)
	task.wait(0.5)
	tweenservice:Create(part, tweeninfo, {Size = Vector3.new(0.1, 0.1, 0.1)}):Play()
	local value = 10
	local lifestealnum = 35
	if game.ServerStorage.PlayerData[p1.Name].Skills.Value:find("PrincesVeins") then
		value = 0
		lifestealnum = 35
	elseif game.ServerStorage.PlayerData[p1.Name].Skills.Value:find("PrincesChaos") then
		value = 20
		lifestealnum = 60
	end
	u2:Fire(p1,p1,{nododge = true,damage = value,move = "Leviathan Plunge"})
	local v2 = script.Roar:Clone()
	v2.Parent = HumanoidRootPart
	v2:Play()
	game.Debris:AddItem(v2,2)
	local v3 = script.LifeSteal:Clone()
	v3.Parent = p1["Right Arm"]
	game.Debris:AddItem(v3,30)
	local lifesteal = Instance.new("Accessory")
	lifesteal.Name = "LifeSteal"
	lifesteal.Parent = p1
	game.Debris:AddItem(lifesteal,lifestealnum)
	task.wait(60)
	canuse = true
end)