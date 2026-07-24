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
local enabled = false
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Dragon Blood") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Dragon Blood"
	CD.Value = 1.5
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 1.5)
	canuse = false
	local HumanoidRootPart = p1.HumanoidRootPart
	local data = game.ServerStorage.PlayerData:FindFirstChild(p1.Name)
	local Ugpraded = data and data.Skills.Value:find("DragonBloodUpgrade")
	if not enabled then
		enabled = true
		p1.Humanoid.Health-=0.2
		local v1 = Instance.new("NumberValue")
		v1.Name = "SpeedBoost"
		v1.Value = Ugpraded and 5 or 3
		v1.Parent = p1.Boosts
		local v2 = Instance.new("NumberValue")
		v2.Name = "MeleeDamageMultiplier"
		v2.Value = Ugpraded and 1.4 or 1.1
		v2.Parent = p1.Boosts
		local v3 = Instance.new("NumberValue")
		v3.Name = "AttackSpeedBoost"
		v3.Value = 3
		v3.Parent = p1.Boosts
		pcall(function()
			HumanoidRootPart.DragonBloodOn:Emit(1)
			HumanoidRootPart.DragonBloodC.Enabled = true
			HumanoidRootPart.Shoryu1:Play()
		end)
		sub(function()
			pcall(function()
				HumanoidRootPart.DragonBloodC.Changed:Wait()
				HumanoidRootPart.DragonBloodOff:Emit(1)
				HumanoidRootPart.Shoryu1:Play()
			end)
			if v1 then
				v1:Destroy()
			end
			if v2 then
				v2:Destroy()
			end
			if v3 then
				v3:Destroy()
			end
		end)
	else
		enabled = false
		HumanoidRootPart.DragonBloodC.Enabled = false
	end
	wait(1.5)
	canuse = true
end)