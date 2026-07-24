function sub(...)
	coroutine.wrap(...)()
end
local u1 = require(game.ServerScriptService.Modules.HitDetection)
local u2 = require(game.ServerScriptService.Modules.EffectModule)
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
	if p1.Cooldowns:FindFirstChild("Subzero Strike") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Subzero Strike"
	CD.Value = 10
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 10)
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local pdata = game.ServerStorage.PlayerData:FindFirstChild(tostring(p2))
	if not pdata then
		return
	end
	if pdata.PrimaryWeapon.Value ~= "Fairfrozen" and pdata.PrimaryWeapon.Value ~= "SpearFairfrozen" then
		return
	end
	canuse = false
	task.delay(10, function()
		canuse = true
	end)
	local HumanoidRootPart = p1.HumanoidRootPart
	local anim = p1.Humanoid:LoadAnimation(script.Parent.Anim)
	anim.Priority = Enum.AnimationPriority.Action2
	anim:Play(0.1, 1.1)
	local v1 = Instance.new("Accessory")
	v1.Name = "Action"
	v1.Parent = p1
	game.Debris:AddItem(v1,1)
	HumanoidRootPart.SpearEmit:Emit(30)
	HumanoidRootPart.SwordCharge:Play()
	--HumanoidRootPart.ColdWind:Play()
	u2.ColdStrike(p1)
	local cancelat = false
	local stuncheck = p1.ChildAdded:Connect(function(child)
		if child.Name == "Stun" then
			cancelat = true
		end
	end)
	wait(0.4)
	stuncheck:Disconnect()
	if cancelat == true then return end
	HumanoidRootPart.Swing:Play()
	u1.magnitudeCheck(p1,HumanoidRootPart.Position,13,{
		--mana = true,
		--manabreak = true,
		damage = 10,
		physical = true,
		knockback = true,
		spear = true,
		manabypass = true,
		slash = true,
		subzero = true,
		spearmovestack = true,
		move = "Subzero Strike"
	})
	
end)