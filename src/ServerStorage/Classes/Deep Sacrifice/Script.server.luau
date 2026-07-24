function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local TagHumanoid = game.ServerStorage.Requests.TagHumanoid
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
	damage = 10,
	aoe = true,
	bypassblock = true,
	noenchant = true,
	move = "Deep Sacrifice"
}
local enabled = false
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Deep Sacrifice") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Deep Sacrifice"
	CD.Value = 22
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 22)
	canuse = false
	task.delay(22, function()
		canuse = true
	end)
	local playerdata = game.ServerStorage.PlayerData:FindFirstChild(p1.Name)
	local HumanoidRootPart = p1.HumanoidRootPart
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	p1.Humanoid:LoadAnimation(script.Raise):Play(0.1,1,1)
	local cancel = false
	local stuncheck = p1.ChildAdded:Connect(function(child)
		if child.Name == "Stun" then
			cancel = true
		end
	end)
	wait(0.45)
	stuncheck:Disconnect()
	wait(0.05)
	if cancel then return end
	local p3 = game.ServerStorage.Assets.DeepSacrifice:Clone()
	local p4 = game.ServerStorage.Assets.BloodImpact:Clone()
	p3.Parent = HumanoidRootPart
	p4.Parent = HumanoidRootPart
	p3:Emit(50)
	p4:Play()
	game.Debris:AddItem(p3,2)
	game.Debris:AddItem(p4,2)
	TagHumanoid:Fire(p1,p1,info)
	u3.magnitudeCheck(p1,HumanoidRootPart.Position,16,info,nil,false)
	local healing = 1.25
	local timeforheal = 0.125
	local totalheals = 30
	if playerdata.Skills.Value:find("PrincesVeins") then
		healing = 1.632
	elseif playerdata.Skills.Value:find("PrincesChaos") then
		timeforheal = 0.0625
		totalheals = 35
	end
	task.spawn(function()
		for i = 1,totalheals do
			if p1:FindFirstChild("NoRegen") or p1:FindFirstChild("Burning") then
				wait(timeforheal)
				continue
			end
			p1.Humanoid.Health += healing
			wait(timeforheal)
		end
	end)
end)