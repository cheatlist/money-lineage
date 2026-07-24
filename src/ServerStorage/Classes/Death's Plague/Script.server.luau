function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local u8 = game.ServerStorage.Requests.TagHumanoid
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
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
	if p1.Cooldowns:FindFirstChild("Death's Plague") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Death's Plague"
	CD.Value = 15
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 15)
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	HumanoidRootPart.Snap:Play()
	HumanoidRootPart.DeathPlague.Enabled = true
	task.wait(0.5)
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play()
	u3.aoeCombatTag(p1,HumanoidRootPart.Position, 40);
	u3.magnitudeCheck(p1,HumanoidRootPart.Position,40,{aoe = true,deathplague = true, move = "Death's Plague"},nil,false)
	HumanoidRootPart.DeathPlague.Enabled = false
	wait(15)
	canuse = true
end)