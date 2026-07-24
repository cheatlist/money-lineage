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
local clone = game.ServerStorage.Assets.DarkOrb
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	local damaged = {}
	canuse = false
	task.delay(10, function()
		canuse = true
	end)
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	local anim = p1.Humanoid:LoadAnimation(script.Parent.Anim)
	anim.Priority = Enum.AnimationPriority.Action2
	anim:Play(0.1, 1.1)
	local v1 = Instance.new("Accessory")
	v1.Name = "Action"
	v1.Parent = p1
	game.Debris:AddItem(v1, 0.3)
	HumanoidRootPart.SpellDeath:Play()
	local cancel = false
	local stuncheck = p1.ChildAdded:Connect(function(child)
		if child.Name == "Stun" then
			cancel = true
		end
	end)
	wait(0.15)
	stuncheck:Disconnect()
	if cancel then return end
	if v1 then
		v1:Destroy()
	end
	for i = -1,-1 do -- this is the laziest thing of all time
		if p1:FindFirstChild("Stun") then return end
		damaged[i] = {}
		local arrow = clone:Clone()
		arrow.CFrame = HumanoidRootPart.CFrame*CFrame.new(0,0,-2)
		arrow.CFrame = arrow.CFrame*CFrame.Angles(0,0,0)
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
			game.ServerStorage.Requests.TagHumanoid:Fire(p1,hum.Parent,{damage = 20,physical = true,lpiercer = true,noenchant = false,bypassblock = true,manabreaker = true,canspellcounter = true, necroflame = true, injury = "dizzy", move = "Obscura"})
		end)
		game.Debris:AddItem(arrow,3)
		HumanoidRootPart.Swing:Play()
		wait(0.04)
	end

end)