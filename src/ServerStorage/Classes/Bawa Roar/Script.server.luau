function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
		healthBelow = 5,
	})
end
local canuse = true
local info = {
	damage = 0.0001,
	fist = true,
	physical = true,
	noenchant = false,
	aoe = true,
	droar = true,
}
local enabled = false
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
	HumanoidRootPart.DragonRoar:Play()
	HumanoidRootPart.DragonRoarPtcl:Emit(1)
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play(0.1,1,2)
	u3.magnitudeCheck(p1,HumanoidRootPart.Position,45,info,nil,false)
	wait(0.01)
	canuse = true
end)