function sub(...)
	coroutine.wrap(...)()
end
local TagHumanoid = game.ServerStorage:FindFirstChild("Requests"):WaitForChild("TagHumanoid")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local HasTag = CollectionService.HasTag
local canuse = true
local u4 = require(game.ServerScriptService.Modules.EffectModule)
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	if not data then
		return
	end
	if not p1:FindFirstChild("Knocked") then
		return
	end
	if not canuse then
		return
	end
	if p1:FindFirstChild("ResGlobalCD") then
		return
	end
	if data.LastRessed.Value == data.DaysSurvived.Value or data.GalvExcept.Value == data.DaysSurvived.Value then
		return
	end
	data.LastRessed.Value = data.DaysSurvived.Value
	data.GalvExcept.Value = data.DaysSurvived.Value
	local stormherald = false
	if data.Skills.Value:find("StormHerald") then
		stormherald = true
	end
	local emberwyrm = false
	if data.Skills.Value:find("TheEmberWyrm") then
		emberwyrm = true
	end
	local abyssalwyrm = false
	if data.Skills.Value:find("TheAbyssalWyrm") then
		abyssalwyrm = true
	end
	canuse = false
	task.spawn(function()
		task.wait(600)
		canuse = true
	end)
	data.Injuries.Value = ""
	require(game.ServerScriptService.Modules.Commands).StopBurn(p1)
	local ThunderZoom
	if stormherald == true then
		u4.HeraldWings(p1.HumanoidRootPart, 30)
		ThunderZoom = game.ServerStorage.Assets.HeraldZoom:Clone()
		ThunderZoom.Parent = workspace.Thrown
		ThunderZoom.CFrame = p1.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(-45), 0, 0)
		ThunderZoom.STRIKE:Play()
	else
		u4.Wings2(p1.HumanoidRootPart, 30)
		ThunderZoom = game.ServerStorage.Assets.ThunderZoom:Clone()
		ThunderZoom.Parent = workspace.Thrown
		ThunderZoom.CFrame = p1.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(-45), 0, 0)
		if emberwyrm then
			ThunderZoom.Color = Color3.fromRGB(255, 100, 20)
		elseif abyssalwyrm then
			ThunderZoom.Color = Color3.fromRGB(90, 30, 130)
		end
		ThunderZoom.STRIKE:Play()
	end
	p1.Humanoid.Health = p1.Humanoid.MaxHealth/2
	for i,v in pairs(p1:GetChildren())do
		if v.Name == "Knocked" or v.Name == "Unconscious" or v.Name == "Action" or v.Name == "NoDam" or v.Name == "FreezeRoot" then
			v:Destroy()
		end
	end
	for i,live in pairs(workspace.Live:GetChildren()) do
		if live:FindFirstChild("Torso") and live:FindFirstChild("HumanoidRootPart") and live ~= p1 then
			if (live.HumanoidRootPart.Position - p1.HumanoidRootPart.Position).Magnitude <= 15 then
				TagHumanoid:Fire(p1, live, {
					damage = 15;
					physical = true;
					strongknockback = true,
					noenchant = true,
					move = "Dragon Awakening"
				})
			end
		end
	end
	ThunderZoom.Transparency = 0
	TweenService:Create(ThunderZoom, TweenInfo.new(0.35), {
		Transparency = 1;
	}):Play()
	TweenService:Create(ThunderZoom.Mesh, TweenInfo.new(0.35), {
		Scale = Vector3.new(15, 15, 15);
	}):Play()
	task.wait(1)
	ThunderZoom:Destroy()
	task.spawn(function()
		for i, v in pairs(p1:GetDescendants()) do
			if v.Name == "Helm" then
				if stormherald == true then
					v.Handle.Color = Color3.fromRGB(185, 131, 245)
				elseif emberwyrm == true then
					v.Handle.Color = Color3.fromRGB(255, 100, 20)
				elseif abyssalwyrm == true then
					v.Handle.Color = Color3.fromRGB(90, 30, 130)
				else
					v.Handle.Color = Color3.fromRGB(248, 212, 32)
				end
				v.Handle.Material = Enum.Material.Neon
			end
		end
		task.wait(30)
		for i, v in pairs(p1:GetDescendants()) do
			if v.Name == "Helm" then
				v.Handle.Color = Color3.fromRGB(248, 248, 248)
				v.Handle.Material = Enum.Material.Metal
			end
		end
	end)
	local v1 = Instance.new("NumberValue")
	v1.Name = "SpeedBoost"
	v1.Value = 4
	v1.Parent = p1.Boosts
	game.Debris:AddItem(v1, 30)
	local v2 = Instance.new("NumberValue")
	v2.Name = "MeleeDamageMultiplier"
	v2.Value = 1.4
	v2.Parent = p1.Boosts
	game.Debris:AddItem(v2, 30)
	local v3 = Instance.new("NumberValue")
	v3.Name = "AttackSpeedBoost"
	v3.Value = 2
	v3.Parent = p1.Boosts
	game.Debris:AddItem(v3, 30)
	local v4 = Instance.new("Accessory")
	v4.Name = "ResGlobalCD"
	v4.Parent = p1
	game.Debris:AddItem(v4,300)
end)