function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local u8 = game.ServerStorage.Requests.TagHumanoid
local Illusions = require(game.ServerScriptService.WorldHandler.MonsterControl.DecisionModules.Illusions)
local IllusionModule = require(game.ServerScriptService.Modules.IllusionModule)
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"NoDam","ReturnStun","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
		healthBelow = 5,
	})
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Mirror Image") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Mirror Image"
	CD.Value = 25
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 25)
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	HumanoidRootPart.Snap:Play()
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play()
	local v50 = game.ReplicatedStorage.Assets.HandHoldIllusion.PointLight:Clone();
	v50.Parent = HumanoidRootPart;
	HumanoidRootPart.PhantasmalEmit:Emit(30)
	local v29 = Instance.new("NumberValue")
	v29.Name = "Transparency"
	v29.Value = 1
	v29.Parent = p1.Boosts
	game.Debris:AddItem(v29, 0.75)
	local v1 = Instance.new("NumberValue")
	v1.Name = "SpeedBoost"
	v1.Value = 30
	v1.Parent = p1.Boosts
	game.Debris:AddItem(v1,0.75)
	local v17 = Instance.new("Accessory")
	v17.Name = "Immortal"
	v17.Parent = p1
	game:GetService("Debris"):AddItem(v17, 0.75)
	local v18 = Instance.new("Accessory")
	v18.Name = "NoAttack"
	v18.Parent = p1
	game:GetService("Debris"):AddItem(v18, 0.75)
	task.wait(0.5)
	v18:Destroy()
	v50:Destroy()
	HumanoidRootPart.Illusion.TimePosition = 0.5
	HumanoidRootPart.Illusion:Play()
	local PlayerData = game:GetService("ServerStorage")["PlayerData"]:FindFirstChild(p2.Name)
	for i = 1,math.random(2,3) do
		local Clone = game.ReplicatedStorage.Rig:Clone()
		Clone.Parent = workspace.Illusions
		Clone.HumanoidRootPart.CFrame = p1.HumanoidRootPart.CFrame * CFrame.new(math.random(-10,10),0,math.random(-10,10))
		Clone.HumanoidRootPart.Anchored = false
		IllusionModule.UpdateAppearance(p2, true, Clone)
		IllusionModule.ChangeArmor(Clone, p2, PlayerData.Armor.Value)
		local CloneHum = Clone.Humanoid
		CloneHum.MaxHealth = 20
		CloneHum.WalkSpeed = 16
		CloneHum.DisplayName = p1.Humanoid.DisplayName
		CloneHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
		CloneHum.HealthDisplayDistance = 0
		CloneHum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		CloneHum.NameDisplayDistance = 100
		CloneHum.NameOcclusion = Enum.NameOcclusion.OccludeAll
		CloneHum:LoadAnimation(Clone.WalkAnim):Play()
		task.spawn(function()
			task.wait(0.1)
			CloneHum:MoveTo(HumanoidRootPart.Position + Vector3.new(math.random(-100,100), 0, math.random(-100,100)))
			task.wait(3)
			require(game.ServerScriptService.Modules.Ragdoll).Ragdoll(Clone,true,false)
			Illusions.die(Clone)
		end)
	end
	task.wait(25)
	canuse = true
end)