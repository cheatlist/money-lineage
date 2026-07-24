function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")
function ActionCheck(Parent)
	if Parent:FindFirstChild("EquipWarmup") then
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
local info = {
	damage = 0,
	fist = true,
	physical = true,
	noenchant = true,
	aoe = true,
	droar = true,
	move = "Dragon Roar"
}
local enabled = false
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Dragon Roar") then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(p1.Name)
	local stormherald = false
	if data.Skills.Value:find("StormHerald") then
		stormherald = true
	end
	local emberwyrm = false
	if data.Skills.Value:find("TheEmberWyrm") then
		emberwyrm = true
	end
	local abyssalwyrm = false
	if data.Skills.Value:find("TheAbyssalWyrm") then
		abyssalwyrm = true
	end
	if stormherald and not p1.Cooldowns:FindFirstChild("Storm Herald Buff CD") then
		local CD = Instance.new("NumberValue")
		CD.Name = "The Storm Herald"
		CD.Value = 10
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 10)

		local CD = Instance.new("NumberValue")
		CD.Name = "Storm Herald Buff CD"
		CD.Value = 20
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 20)
	elseif emberwyrm and not p1.Cooldowns:FindFirstChild("Ember Wyrm Buff CD") then
		local CD = Instance.new("NumberValue")
		CD.Name = "The Ember Wyrm"
		CD.Value = 10
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 10)

		local CD = Instance.new("NumberValue")
		CD.Name = "Ember Wyrm Buff CD"
		CD.Value = 20
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 20)
	elseif abyssalwyrm and not p1.Cooldowns:FindFirstChild("Abyssal Wyrm Buff CD") then
		local CD = Instance.new("NumberValue")
		CD.Name = "The Abyssal Wyrm"
		CD.Value = 10
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 10)

		local CD = Instance.new("NumberValue")
		CD.Name = "Abyssal Wyrm Buff CD"
		CD.Value = 20
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 20)
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Dragon Roar"
	CD.Value = 17
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 17)
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	HumanoidRootPart.DragonRoar:Play()
	HumanoidRootPart.DragonRoarPtcl:Emit(1)
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play(0.1,1,2)
	u3.magnitudeCheck(p1,HumanoidRootPart.Position,45,info,nil,false)
	wait(17)
	canuse = true
end)