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
	if Parent.Humanoid.Health<5 then
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
	if not canuse then
		return
	end
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	HumanoidRootPart.Greatswordcharge:Play()
	HumanoidRootPart.ChargePart:Emit(30)
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play()
	local v6 = Instance.new("Accessory");
	v6.Name = "Action";
	v6.Parent = p1;
	game:GetService("Debris"):AddItem(v6, 1);
	wait(0.425)
	u3.magnitudeCheck(p1,HumanoidRootPart.Position,10,{
		physical = true,
		fist = true,
		injury = "rib cage",
		damage = 55,
		knockback = true,
		move = "Shove"
	},nil,false)
	wait(15)
	canuse = true
end)