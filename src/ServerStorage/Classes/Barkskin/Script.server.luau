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
local enabled = false
local TS = game:GetService("TweenService")
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Barkskin") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Barkskin"
	CD.Value = 40
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 40)
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	local Hardened = Instance.new("StringValue")
	Hardened.Name = "BarkskinBuff"
	Hardened.Parent = p1
	local ExtraHardened
	if game:GetService("ServerStorage"):FindFirstChild("PlayerData"):FindFirstChild(p2.Name):FindFirstChild("Skills").Value:find("Nature's Calling") then
		ExtraHardened = Instance.new("StringValue")
		ExtraHardened.Name = "Nature's Calling"
		ExtraHardened.Parent = p1
		HumanoidRootPart:FindFirstChild("Petal"):FindFirstChild("ParticleEmitter").Enabled = true
	end
	local Effect = game:GetService("ServerStorage"):FindFirstChild("SpellEffects"):FindFirstChild("BarkSkin"):Clone()
	Effect.Parent = p1
	Effect.Adornee = p1
	HumanoidRootPart:FindFirstChild("Barkskin"):Play()
	TS:Create(Effect, TweenInfo.new(1), {OutlineTransparency = 0}):Play()
	if ExtraHardened then
		task.wait(20)
	else
		task.wait(10)
	end
	TS:Create(Effect, TweenInfo.new(1), {OutlineTransparency = 0}):Play()
	task.wait(1)
	Effect:Destroy()
	Hardened:Destroy()
	if ExtraHardened then
		ExtraHardened:Destroy()
		HumanoidRootPart:FindFirstChild("Petal"):FindFirstChild("ParticleEmitter").Enabled = false
	end
	task.wait(39)
	canuse = true
end)