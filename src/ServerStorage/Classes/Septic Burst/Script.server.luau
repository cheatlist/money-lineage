local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local Helpers = require(game.ServerScriptService.WorldHandler.TagHumanoid.Helpers)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end

script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1) then
		return
	end
	if p1.Cooldowns:FindFirstChild("Septic Burst") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Septic Burst"
	CD.Value = 14
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 14)
	local HumanoidRootPart = p1.HumanoidRootPart
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play()
	HumanoidRootPart.DaggerCharge:Play()
	task.wait(0.3)
	if p1:FindFirstChild("Stun") then
		return
	end
	local closest, closestDist = nil, 10
	for _,ochar in pairs(game.Workspace.Live:GetChildren()) do
		if ochar ~= p1 and ochar:FindFirstChild("HumanoidRootPart") and ochar:FindFirstChild("Humanoid") and ochar.Humanoid.Health > 0 then
			local dist = (ochar.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
			if dist < closestDist then
				closest, closestDist = ochar, dist
			end
		end
	end
	if not closest then
		return
	end
	local stacks = Helpers.clearToxinStacks(closest)
	HumanoidRootPart.ShineStab:Play()
	game.ServerStorage.Requests.TagHumanoid:Fire(p1, closest, {
		physical = true,
		dagger = true,
		damage = 4 + (stacks * 6),
		noenchant = true,
		noparry = true,
		blockbreak = true,
		nobackstab = true,
		move = "Septic Burst",
	})
end)
