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
local wingflaps = 0
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	if wingflaps>2 then
		return
	end
	if wingflaps>1 and p1.Humanoid:GetState().Name ~= "Freefall"then
		return
	end
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
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
	if wingflaps < 4 then
		canuse = false
		local v1 = Instance.new("Accessory")
		v1.Name = "NoFall"
		v1.Parent = p1
		game.Debris:AddItem(v1,(stormherald == true or emberwyrm == true or abyssalwyrm == true) and 10 or 5)
		local v3 = Instance.new("Accessory")
		v3.Name = "NOLDROP"
		v3.Parent = p1
		game.Debris:AddItem(v3,5)
		local wingcolor = Color3.fromRGB(9, 137, 207)
		if stormherald == true then
			HumanoidRootPart.MegaFlap:Play()
			wingcolor = Color3.fromRGB(157, 108, 211)
		elseif emberwyrm == true then
			HumanoidRootPart.MegaFlap:Play()
			wingcolor = Color3.fromRGB(255, 100, 20)
		elseif abyssalwyrm == true then
			HumanoidRootPart.MegaFlap:Play()
			wingcolor = Color3.fromRGB(90, 30, 130)
		else
			HumanoidRootPart.WingFlap:Play()
		end
		u2.Wings(HumanoidRootPart, wingcolor, 1)
		wingflaps+=1
		sub(function()
			local old = wingflaps
			wait(5)
			canuse = false
			wait(10)
			if wingflaps == old then
				canuse = true
				wingflaps = 0
			end
		end)
		wait(0.25)
		local v2 = Instance.new("BodyVelocity")
		v2.MaxForce = Vector3.new(0,math.huge,0)
		v2.Velocity = wingflaps == 1 and Vector3.new(0,180,0) or (stormherald == true or emberwyrm == true or abyssalwyrm == true) and Vector3.new(0,100,0) or Vector3.new(0,60,0)
		v2.Parent = HumanoidRootPart
		game.Debris:AddItem(v2,0.2)
		wait(0.2)
		canuse = true
		if wingflaps>2 then
			wait(15)
			wingflaps = 0
			canuse = true
		end
	end
end)