function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Lockout") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Lockout"
	CD.Value = 12
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 12)
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play()
	local v1 = Instance.new("Accessory")
	v1.Name = "Action"
	v1.Parent = p1
	game.Debris:AddItem(v1,0.5)
	p1.HumanoidRootPart.MoneyCharge:Play()
	p1.HumanoidRootPart.Lockout.A:Emit(10)
	p1.HumanoidRootPart.Lockout.B:Emit(10)
	task.wait(0.475)
	HumanoidRootPart.FULLCOUNTER:Play()
	u3.magnitudeCheck(p1,HumanoidRootPart.Position,10,{
		physical = true,
		noparry = true,
		blockbreak = true,
		knockback = true,
		nobackstab = true,
		damage = 30,
		sword = true, 
		slash = true, 
		slow = true,
		move = "Lockout"
	})
	task.wait(12)
	canuse = true
end)