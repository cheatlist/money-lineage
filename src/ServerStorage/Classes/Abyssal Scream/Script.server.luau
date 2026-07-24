function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local u8 = game.ServerStorage.Requests.TagHumanoid
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
	if p1.Cooldowns:FindFirstChild("Abyssal Scream") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Abyssal Scream"
	CD.Value = 15
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 15)
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	HumanoidRootPart.AbyssalScream:Play()
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play()
	u8:Fire(p1,p1,{cursestack = true,nohitanim = true,noenchant = true,move = "Abyssal Scream"})
	u3.aoeCombatTag(p1,HumanoidRootPart.Position, 40);
	u3.magnitudeCheck(p1,HumanoidRootPart.Position,40,{nohitanim = true,aoe = true,cursestack = true,move = "Abyssal Scream"},nil,false)
end)