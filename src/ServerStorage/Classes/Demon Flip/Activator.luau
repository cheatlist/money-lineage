local l__Parent__1 = script.Parent
local l__Parent__2 = l__Parent__1.Parent
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid
local l__TweenService__4 = game:GetService("TweenService")
function sub(...)
	coroutine.wrap(...)()
end
local l__TweenService__5 = game:GetService("TweenService")
function ActionCheck(p1)
	if not p1:FindFirstChild("Humanoid") then
		return true
	end
	if p1:FindFirstChild("Stun") then
		return true
	end
	if p1:FindFirstChild("ReturnStun") then
		return true
	end
	if p1:FindFirstChild("ActiveCast") then
		return true
	end
	if p1:FindFirstChild("Action") then
		return true
	end
	if p1:FindFirstChild("Immortal") then
		return true
	end
	if p1:FindFirstChild("Knocked") then
		return true
	end
	if p1:FindFirstChild("Blocking") then
		return true
	end
	if p1:FindFirstChild("SpellBlocking") then
		return true
	end
	if p1:FindFirstChild("NoDemonFlip") then
		return true
	end
	if p1.Humanoid.Health == 0 then
		return true
	end
	if p1:FindFirstChild("Climbing") then

	else
		return
	end
	return true
end
local v6 = {}
local u1 = true
local u2 = require(game.ServerScriptService.Modules.HitDetection)
function v6.Active(p2, p3, p4, p5)
	if ActionCheck(p2) then
		return
	end
	local l__Humanoid__7 = p2.Humanoid
	local l__HumanoidRootPart__8 = p2.HumanoidRootPart
	if l__HumanoidRootPart__8:FindFirstChild("ForwardVelocity") then
		return
	end
	if p2.Cooldowns:FindFirstChild("Demon Flip") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Demon Flip"
	CD.Value = 8
	CD.Parent = p2.Cooldowns
	game.Debris:AddItem(CD, 8)
	u1 = false
	
	local fixingsomething = Instance.new("Folder")
	fixingsomething.Name = "STOPBLOCKING"
	fixingsomething.Parent = p2
	
	game.ReplicatedStorage.Requests.ClearDodgeVels:FireClient(p3)
	l__Humanoid__7:LoadAnimation(l__Parent__1.Chop):Play()
	local v10 = l__Parent__1.Sound:Clone()
	v10.Parent = l__HumanoidRootPart__8
	v10:Play()
	game.Debris:AddItem(v10, 2)
	local v11 = Instance.new("BodyVelocity")
	game.CollectionService:AddTag(v11, "AllowedBM")
	v11.MaxForce = Vector3.new(80000, 0, 80000)
	v11.Velocity = l__HumanoidRootPart__8.CFrame.lookVector.unit*35
	v11.Name = "ForwardVelocity"
	v11.Parent = l__HumanoidRootPart__8
	game.Debris:AddItem(v11, 1)
	local v12 = Instance.new("Accessory")
	v12.Name = "IFRAME"
	v12.Parent = p2
	game.Debris:AddItem(v12, 1)
	local v13 = Instance.new("Accessory")
	v13.Name = "FallDamageBypass"
	v13.Parent = p2
	game.Debris:AddItem(v13, 1)
	local v14 = Instance.new("Accessory")
	v14.Name = "Action"
	v14.Parent = p2
	l__Humanoid__7:UnequipTools()
	wait(0.1)
	local v15 = {}
	table.insert(v15, p2["Left Arm"])
	table.insert(v15, p2["Left Leg"])
	table.insert(v15, p2["Right Arm"])
	table.insert(v15, p2["Right Leg"])
	for _,v19 in pairs(v15)do
		local v20 = Instance.new("Attachment")
		v20.Name = "StepAttach"
		v20.Parent = v19
		l__Parent__1.Particle:Clone().Parent = v20
		if v19.Name == "Right Arm" then
			v20.Position = Vector3.new(0, -v19.Size.Y / 2, 0)
		elseif v19.Name == "Left Arm" then
			v20.Position = Vector3.new(0, v19.Size.Y / 2, v19.Size.Z / 2)
		else
			v20.Position = Vector3.new(0, 0, -v19.Size.Z / 2)
		end	
	end
	wait(0.7)
	for v21, v22 in next, v15 do
		for _,v27 in pairs(v22:children())do
			if v27.Name == "StepAttach" then
				v27.Particle.Enabled = false
				game.Debris:AddItem(v27, 0.3)
			end		
		end
	end
	local v28 = {}
	wait(0.1)
	p2.HumanoidRootPart.Swing:Play()
	u2.magnitudeCheck(p2, l__HumanoidRootPart__8.Position, 10, {
		physical = true,
		fist = true,
		damage = 20,
		move = "Demon Flip"
	})
	v14:Destroy()
	fixingsomething:Destroy()
	wait(7)
	u1 = true
end
function v6.Active2(p6, p7, p8, p9)
	if ActionCheck(p6) then
		return
	end
	local l__Humanoid__29 = p6.Humanoid
	local l__HumanoidRootPart__30 = p6.HumanoidRootPart
	if l__HumanoidRootPart__30:FindFirstChild("ForwardVelocity") then
		return
	end
	if p6.Cooldowns:FindFirstChild("Demon Flip") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Demon Flip"
	CD.Value = 8
	CD.Parent = p6.Cooldowns
	game.Debris:AddItem(CD, 8)
	u1 = false
	game.ReplicatedStorage.Requests.ClearDodgeVels:FireClient(p7)
	l__Humanoid__29:LoadAnimation(l__Parent__1.Slide):Play()
	
	local v31 = l__Parent__1.Sound:Clone()
	v31.Parent = l__HumanoidRootPart__30
	v31:Play()
	game.Debris:AddItem(v31, 2)
	local v33 = Instance.new("BodyVelocity")
	game.CollectionService:AddTag(v33, "AllowedBM")
	v33.MaxForce = Vector3.new(80000, 0, 80000)
	v33.Velocity = l__HumanoidRootPart__30.CFrame.LookVector.Unit * 35
	v33.Name = "ForwardVelocity"
	v33.Parent = l__HumanoidRootPart__30
	game.Debris:AddItem(v33, 1)
	local v34 = Instance.new("Accessory")
	v34.Name = "Action"
	v34.Parent = p6
	game.Debris:AddItem(v34,1)
	l__Humanoid__29:UnequipTools()
	wait(0.1)
	local v35 = {}
	table.insert(v35, p6["Left Arm"])
	table.insert(v35, p6["Left Leg"])
	table.insert(v35, p6["Right Arm"])
	table.insert(v35, p6["Right Leg"])
	local v37 = nil
	for _,v39 in pairs(v35)do
		local v40 = Instance.new("Attachment")
		v40.Name = "StepAttach"
		v40.Parent = v39
		l__Parent__1.Particle:Clone().Parent = v40
		if v39.Name == "Right Arm" or v39.Name == "Left Arm" then
			v40.Position = Vector3.new(0, -v39.Size.Y / 2, 0)
		else
			v40.Position = Vector3.new(0, 0, -v39.Size.Z / 2)
		end	
	end
	local v41 = tick()
	local v42 = false
	while true do
		if p6:FindFirstChild("Stun") then
			v42 = true
		end
		wait()
		if tick() - v41 > 0.7 then
			break
		end
		if v42 then
			break
		end	
	end
	if not v42 then
		local v44 = tick()
		local v45 = {
			physical = true,
			damage = 8,
			blockbreak = true,
			noparry = true,
			fist = true,
			aoe = true,
			move = "Demon Flip"
		}
		while true do
			 u2.magnitudeCheck(p6, l__HumanoidRootPart__30.Position, 10, v45, nil, true)
			
			if tick() - v44 > 0.2 then
				break
			end	
			task.wait(0.05)
		end
	end
	for v46, v47 in next, v35 do
		local v49, v50 = v47:children()
		for _,v52 in pairs(v47:getChildren())do
			if v52.Name == "StepAttach" then
				v52.Particle.Enabled = false
				game.Debris:AddItem(v52, 0.3)
			end		
		end
	end
	wait(7)
	u1 = true
end
return v6