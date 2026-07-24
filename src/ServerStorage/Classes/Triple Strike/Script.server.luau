function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local canuse = true
local info = {
	damage = 6.3,
	physical = true,
	spear = true,
	slash = true,
	move = "Triple Strike"
}
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Triple Strike") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Triple Strike"
	CD.Value = 11
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 11)
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play(0.1,1,1.1)
	local v1 = Instance.new("Accessory")
	v1.Name = "Action"
	v1.Parent = p1
	game.Debris:AddItem(v1,1)
	Instance.new("Folder", v1).Name = "NoDelete"
	HumanoidRootPart.SpearEmit:Emit(30)
	HumanoidRootPart.SwordCharge:Play()
	wait(0.3)
	for i = 1,3 do
		info.knockback = i == 3
		HumanoidRootPart.Swing:Play()
		u3.magnitudeCheck(p1,HumanoidRootPart.Position,10,info)
		wait(0.2)
	end
	wait(11)
	canuse = true
end)