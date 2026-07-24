function sub(...)
	coroutine.wrap(...)()
end
local u1 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")
function ActionCheck(Parent)
	if Parent:FindFirstChild("EquipWarmup") then
		return true
	end
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("NoDam") then
		return true
	end
	if Parent:FindFirstChild("ReturnStun") then
		return true
	end
	if Parent:FindFirstChild("Action") then
		return true
	end
	if Parent:FindFirstChild("Blocking") then
		return true
	end
	if Parent:FindFirstChild("SpellBlocking") then
		return true
	end
	if Parent:FindFirstChild("ActiveCast") then
		return true
	end
	if Parent:FindFirstChild("Unconscious") then
		return true
	end
	if Parent:FindFirstChild("Knocked") then
		return true
	end
	if Parent:FindFirstChild("Immortal") then
	else
		return
	end
	return true
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Impale") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Impale"
	CD.Value = 11
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 11)
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play(0.1,1,1.1)
	local v1 = Instance.new("Accessory")
	v1.Name = "Action"
	v1.Parent = p1
	game.Debris:AddItem(v1,1)
	HumanoidRootPart.SpearEmit:Emit(30)
	HumanoidRootPart.SwordCharge:Play()
	wait(0.3)
	HumanoidRootPart.Swing:Play()
	if not p1:FindFirstChild("NoDam")then
		u1.magnitudeCheck(p1,HumanoidRootPart.Position,11,{
			damage = 10,
			noparry = true,
			physical = true,
			spear = true,
			knockback = true,
			slash = true,
			injury = "chestgash",
			spearmovestack = false,
			move = "Impale"
		})
	end
	wait(11)
	canuse = true
end)