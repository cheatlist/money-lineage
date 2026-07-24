function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
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
	if p1.Cooldowns:FindFirstChild("Pommel Strike") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Pommel Strike"
	CD.Value = 10
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 10)
	canuse = false
	task.delay(10,function()
		canuse = true
	end)
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play(0.1,1,1.1)
	local v1 = Instance.new("Accessory")
	v1.Name = "Action"
	v1.Parent = p1
	game.Debris:AddItem(v1,1)
	HumanoidRootPart.AgilityEmit:Emit(30)
	HumanoidRootPart.SwordCharge:Play()
	wait(0.3)
	if not p1:FindFirstChild("NoDam")then
		u3.magnitudeCheck(p1,HumanoidRootPart.Position,8,{
			physical = true, 
			damage = 10,
			manabreaker = true,
			fist = true,
			blacksmithm1 = true,
			knockback = true,
			injury = "dizzy",
			move = "Pommel Strike"
		})
	end
end)