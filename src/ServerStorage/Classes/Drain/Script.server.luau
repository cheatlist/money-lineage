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
local l__TagHumanoid__4 = game.ServerStorage.Requests.TagHumanoid;
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Drain") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Drain"
	CD.Value = 30
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 30)
	local damaged = {}
	canuse = false
	task.delay(30, function()
		canuse = true
	end)
	local grabbing = false
	
	local HumanoidRootPart = p1.HumanoidRootPart
	local anim = p1.Humanoid:LoadAnimation(script.Parent.Grab)
	anim:Play(0.1, 1.1)
	local v1 = Instance.new("Accessory")
	v1.Name = "Action"
	v1.Parent = p1
	HumanoidRootPart.AkumaEmit:Emit(30)
	HumanoidRootPart.Shoryu1:Play()
	local cancel = false
	local stuncheck = p1.ChildAdded:Connect(function(child)
		if child.Name == "Stun" then
			cancel = true
			grabbing = true
			anim:Stop()
			v1:Destroy()
		end
	end)
	
	local BV
	
	anim:GetMarkerReachedSignal("Begin"):Connect(function()
		if cancel then return end
		HumanoidRootPart.VampGrab:Play()
		grabbing = true
		
		BV = Instance.new("BodyVelocity")
		BV.Velocity = HumanoidRootPart.CFrame.LookVector * 150
		BV.Parent = HumanoidRootPart
		BV.MaxForce = Vector3.new(5000000,0,5000000)
		
		while grabbing do
			BV.Velocity = HumanoidRootPart.CFrame.LookVector * 125
			
			local hit = u1.magnitudeCheck(p1,HumanoidRootPart.Position,6.5,{
				grabmove = true,
				blockallsides = true,
			})
			
			if hit then
				
				BV:Destroy()
				
				anim:Stop()
				
				local EnemyHumanoid = hit:FindFirstChild("Humanoid")
				local GrabbedAnim = EnemyHumanoid:LoadAnimation(script.Parent.Grabbed)
				local GrabbingAnim = p1.Humanoid:LoadAnimation(script.Parent.Grabbing)
				
				local weld = Instance.new("Weld")
				weld.Part0 = p1["HumanoidRootPart"]
				weld.Part1 = hit["HumanoidRootPart"]
				weld.C1 = CFrame.new(1, -0.5, -2.5, -1, 0, -1.50995803e-07, 0, 1, 0, 1.50995803e-07, 0, -1)
				weld.Parent = p1
				
				GrabbedAnim:Play()
				GrabbingAnim:Play()
				
				HumanoidRootPart.CrazyLaugh:Play()
				hit.HumanoidRootPart.BloodSuck:Play()
				
				local v2 = Instance.new("Accessory")
				v2.Name = "Action"
				v2.Parent = hit
				
				hit.HumanoidRootPart.Anchored = true
				EnemyHumanoid.AutoRotate = false
				
				local immortal2 = Instance.new("Accessory")
				immortal2.Name = "Immortal"
				immortal2.Parent = hit
				game.Debris:AddItem(immortal2, 3)
				
				local immortal3 = Instance.new("Accessory")
				immortal3.Name = "Immortal"
				immortal3.Parent = p1
				game.Debris:AddItem(immortal3, 3)
				
				for i = 1,6 do
					l__TagHumanoid__4:Fire(p1, hit, {
						damage = 4,
						physical = true,
						nohitanim = true,
						noenchant = true,
						nododge = true,
						move = "Drain",
						bypassiframes = true
					});
					
					hit.HumanoidRootPart.PotionPour:Play()
					
					p1.Humanoid.Health += 4
					
					if hit:FindFirstChild("Stomach") then
						p1.Stomach.Value += 7
						hit.Stomach.Value -= 7
					end
					
					task.wait(0.5)
				end
				
				hit.HumanoidRootPart.Anchored = false
				EnemyHumanoid.AutoRotate = true
				
				weld:Destroy()
				GrabbedAnim:Stop()
				GrabbingAnim:Stop()
				
				v2:Destroy()
				v1:Destroy()
				
				local Knocked = Instance.new("BoolValue")
				Knocked.Name = "Knocked"
				Knocked.Parent = hit
				game.Debris:AddItem(Knocked, 2)
				
				local immortal = Instance.new("Accessory")
				immortal.Name = "Immortal"
				immortal.Parent = hit
				game.Debris:AddItem(immortal, 2)
				
				return
			end
			
			task.wait(0.1)
		end
	end)
	
	anim:GetMarkerReachedSignal("End"):Connect(function()
		grabbing = false
		if BV then
			BV:Destroy()
		end
		
		task.delay(1, function()
			v1:Destroy()
		end)
	end)
end)