function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
		healthBelow = 5,
	})
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Shoulder Bash") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Shoulder Bash"
	CD.Value = 10
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 10)
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
	task.wait(0.425)
	u3.magnitudeCheck(p1,HumanoidRootPart.Position,10,{
		physical = true,
		fist = true,
		injury = "rib cage",
		damage = 15,
		knockback = true,
		move = "Shoulder Bash",
		blockbreak = true
	},nil,false)
	task.wait(10)
	canuse = true
end)