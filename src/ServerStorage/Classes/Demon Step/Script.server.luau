function sub(...)
	coroutine.wrap(...)()
end
local m1 = require(game.ServerScriptService.Modules.m1)
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")
function ActionCheck(Parent)
	if Parent:FindFirstChild("DemonTP") then
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
	if Parent:FindFirstChild("Immortal") then
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
	return
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Demon Step") then
		return
	end
	local p3 = false
	local cd = 0.3
	if p1.Mana.Value<=5 then
		p3 = true
		cd += 0.2
		p1.Humanoid:UnequipTools()
	else
		p1.Mana.Value-=15
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Demon Step"
	CD.Value = cd
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, cd)
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play()
	local v1 = script.Parent.Sound:Clone()
	v1.Parent = HumanoidRootPart
	v1:Play()
	game.Debris:AddItem(v1,1)
	local v2 = Instance.new("BodyVelocity")
	game.CollectionService:AddTag(v2,"AllowedBM")
	v2.MaxForce = Vector3.new(80000,0,80000)
	v2.Velocity = HumanoidRootPart.CFrame.lookVector.unit*35
	v2.Name = "ForwardVelocity"
	if p1.SHeld.Value == true then
		v2.Name = "BackwardVelocity"
		v2.Velocity = -HumanoidRootPart.CFrame.lookVector.unit*35
	end
	v2.Parent = HumanoidRootPart
	game.Debris:AddItem(v2,0.415)
	wait()
	coroutine.wrap(function()
		for _,v in pairs(p1:GetChildren()) do
			if v:IsA("BasePart") then
				if v.Transparency ~= 1 then
					local part = Instance.new("Part")
					part.Anchored = true
					part.Transparency = 0.1
					part.CanCollide = false
					part.Parent = workspace.Thrown
					part.BrickColor = BrickColor.new("Really black")
					part.Material = Enum.Material.Neon
					part.Size = v.Size
					part.CFrame = v.CFrame
					if v:FindFirstChildOfClass("SpecialMesh") then
						v:FindFirstChildOfClass("SpecialMesh"):Clone().Parent = part
					end
					local tweenservice = game:GetService("TweenService")
					local goal = {}
					goal.Transparency = 1
					local tweeninfo = TweenInfo.new(0.6)
					local tween = tweenservice:Create(part, tweeninfo, goal)
					tween:Play()
					game.Debris:AddItem(part, 0.5)
				end
			end
		end
	end)()
	local v15 = {}
	table.insert(v15, p1["Left Arm"])
	table.insert(v15, p1["Left Leg"])
	for _,v19 in pairs(v15)do
		local v20 = Instance.new("Attachment")
		v20.Name = "StepAttach"
		v20.Parent = v19
		script.Parent.Particle:Clone().Parent = v20
		v20.Position = Vector3.new(0, -1, 0)
	end
	local v3 = Instance.new("Accessory")
	v3.Name = "Immortal"
	v3.Parent = p1
	game.Debris:AddItem(v3,0.25)
	local v4 = Instance.new("Accessory")
	v4.Name = "FallDamageBypass"
	v4.Parent = p1
	game.Debris:AddItem(v4,0.4)
	local v5 = Instance.new("Accessory")
	v5.Name = "DemonTP"
	v5.Parent = p1
	game.Debris:AddItem(v5,0.375)
	m1(p1,p2,p1.CharacterHandler.CombatAnims,game.ServerStorage.PlayerData[p2.Name])
	if p3 then
		wait(0.2)
	end
	wait(0.3)
	for v21, v22 in next, v15 do
		for _,v27 in pairs(v22:children())do
			if v27.Name == "StepAttach" then
				v27.Particle.Enabled = false
				game.Debris:AddItem(v27, 0.3)
			end		
		end
	end
	canuse = true
end)