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
	if p1.Cooldowns:FindFirstChild("Ethereal Strike") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Ethereal Strike"
	CD.Value = 22.5
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 22.5)
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play()
	local v1 = Instance.new("Folder")
	v1.Name = "Action"
	v1.Parent = p1
	game.Debris:AddItem(v1,0.5)
	HumanoidRootPart.DaggerCharge:Play()
	task.wait(0.475)
	if not p1:FindFirstChild("Stun")then
		HumanoidRootPart.ShineStab:Play()
		u3.magnitudeCheck(p1,HumanoidRootPart.Position,8,{
			percent = 20,
			noparry = true,
			physical = true,
			dagger = true,
			blockbreak = true,
			noenchant = true,
			nobuff = true,
			knockback = true,
			slash = true,
			nobackstab = true,
			move = "Ethereal Strike"
		})
	end
	task.wait(22.5)
	canuse = true
end)	