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
local clone = game.ServerStorage.Assets.LightArrow
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Light Piercer") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Light Piercer"
	CD.Value = 15
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 15)
	local damaged = {}
	canuse = false
	task.delay(15, function()
		canuse = true
	end)
	--local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	local anim = p1.Humanoid:LoadAnimation(script.Parent.Anim)
	if game.ServerStorage.PlayerData[p1.Name].Skills.Value:find("PrincesVeins") then
		anim = p1.Humanoid:LoadAnimation(script.Parent.Anim2)
	end
	anim.Priority = Enum.AnimationPriority.Action2
	anim:Play(0.1, 1.1)
	local v1 = Instance.new("Accessory")
	v1.Name = "Action"
	v1.Parent = p1
	game.Debris:AddItem(v1, 0.3)
	HumanoidRootPart.SpearEmit:Emit(30)
	HumanoidRootPart.SwordCharge:Play()
	local cancel = false
	local stuncheck = p1.ChildAdded:Connect(function(child)
		if child.Name == "Stun" then
			cancel = true
		end
	end)
	local totaltimewait = 0.18
	local val = 8
	if game.ServerStorage.PlayerData[p1.Name].Class.Value ~= "Church Knight" and game.ServerStorage.PlayerData[p1.Name].Class.Value ~= "DeepKnight" and game.ServerStorage.PlayerData[p1.Name].Hybrid.Value ~= "Church Knight" then
		val=4
	end
	if game.ServerStorage.PlayerData[p1.Name].Skills.Value:find("PrincesChaos") then
		val = 9
		clone = game.ServerStorage.Assets.LightArrow2
		totaltimewait = 0.12
	end
	
	
	task.wait(0.15)
	stuncheck:Disconnect()
	if cancel then return end
	if v1 then
		v1:Destroy()
	end
	
	local vallighttimes = 1
	if game.ServerStorage.PlayerData[p1.Name].Skills.Value:find("PrincesVeins") then
		if p1:FindFirstChild("Stun") then return end
		damaged[0] = {}
		local arrow = game.ServerStorage.Assets.MegaArrow:Clone()
		arrow.CFrame = HumanoidRootPart.CFrame*CFrame.new(0,0,-2)
		arrow.CFrame = arrow.CFrame*CFrame.Angles(0,math.rad(0*1),0)
		arrow.BodyVelocity.Velocity = arrow.CFrame.LookVector*130 + Vector3.new(0 * 7, 0, 0)
		arrow.Parent = workspace.Thrown
		arrow.Sound:Play()
		arrow:SetNetworkOwner(nil)
		local con = nil
		con = arrow.Touched:Connect(function(p)
			if p.Parent == p1 or p.Parent.Parent == p1 then
				return
			end
			local hum = p.Parent:FindFirstChild("Humanoid")or p.Parent.Parent:FindFirstChild("Humanoid")
			if not hum then
				return
			end
			if damaged[0]and damaged[0][hum.Parent.Name]then
				return
			end
			damaged[0][hum.Parent.Name] = true
			game.ServerStorage.Requests.TagHumanoid:Fire(p1,hum.Parent,{damage = 33,physical = true,lpiercer = true,noenchant = true,bypassblock = true,manabreaker = true,canspellcounter = true,move = "Light Piercer", stun = 1.7})
		end)
		game.Debris:AddItem(arrow,3)
		HumanoidRootPart.Swing:Play()
	else
		for i = -vallighttimes,vallighttimes do
			if p1:FindFirstChild("Stun") then return end
			damaged[i] = {}
			local arrow = clone:Clone()
			arrow.CFrame = HumanoidRootPart.CFrame*CFrame.new(0,0,-2)
			arrow.CFrame = arrow.CFrame*CFrame.Angles(0,math.rad(i*1),0)
			arrow.BodyVelocity.Velocity = arrow.CFrame.LookVector*130 + Vector3.new(i * 7, 0, 0)
			arrow.Parent = workspace.Thrown
			arrow.Sound:Play()
			arrow:SetNetworkOwner(nil)
			local con = nil
			con = arrow.Touched:Connect(function(p)
				if p.Parent == p1 or p.Parent.Parent == p1 then
					return
				end
				local hum = p.Parent:FindFirstChild("Humanoid")or p.Parent.Parent:FindFirstChild("Humanoid")
				if not hum then
					return
				end
				if damaged[i]and damaged[i][hum.Parent.Name]then
					return
				end
				damaged[i][hum.Parent.Name] = true
				game.ServerStorage.Requests.TagHumanoid:Fire(p1,hum.Parent,{damage = val,physical = true,lpiercer = true,noenchant = true,bypassblock = true,manabreaker = true,canspellcounter = true,move = "Light Piercer"})
			end)
			game.Debris:AddItem(arrow,3)
			HumanoidRootPart.Swing:Play()
			task.wait(0.18)
		end
	end
end)