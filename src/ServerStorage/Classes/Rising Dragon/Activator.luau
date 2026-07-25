local l__Parent__1 = script.Parent
local l__Parent__2 = l__Parent__1.Parent
local l__TweenService__3 = game:GetService("TweenService")
function sub(...)
	coroutine.wrap(...)()
end
function ActionCheck(p1)
	if not p1:FindFirstChild("Humanoid") then
		return true
	end
	if p1:FindFirstChild("Stun") then
		if not p1:FindFirstChild("LandedShoryuExcept") then
			return true
		end
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
	if p1:FindFirstChild("Blocking") then
		return true
	end
	if p1:FindFirstChild("Knocked") then
		return true
	end
	if p1:FindFirstChild("Immortal") then
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
local v4 = {}
local u1 = true
local u2 = require(game.ServerScriptService.Modules.HitDetection)
function v4.Active(p1, p2, p3, p4)
	local v6 = nil
	if ActionCheck(p1) then
		return
	end
	local l__Humanoid__7 = p1.Humanoid
	local l__HumanoidRootPart__8 = p1.HumanoidRootPart
	if l__HumanoidRootPart__8:FindFirstChild("ForwardVelocity") then
		return
	end
	if p1.Cooldowns:FindFirstChild("Rising Dragon") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Rising Dragon"
	CD.Value = 10
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 10)
	u1 = false
	
	local fixingsomething = Instance.new("Folder")
	fixingsomething.Name = "STOPBLOCKING"
	fixingsomething.Parent = p1
	
	l__Humanoid__7:LoadAnimation(l__Parent__1.Shoryu):Play()
	local l__Value__9 = game.ServerStorage.PlayerData:FindFirstChild(p2.Name).Class.Value
	game.ReplicatedStorage.Requests.ClearDodgeVels:FireClient(p2)
	task.wait(1/30)
	local v10 = Instance.new("BodyVelocity")
	game.CollectionService:AddTag(v10, "AllowedBM")
	v10.MaxForce = Vector3.new(80000, 0, 80000)
	v10.Velocity = l__HumanoidRootPart__8.CFrame.lookVector.unit * 35
	v10.Name = "ForwardVelocity"
	v10.Parent = l__HumanoidRootPart__8
	game.Debris:AddItem(v10, 0.8)
	local v11 = Instance.new("Folder")
	v11.Name = "Planted"
	v11.Parent = p1
	local v12 = Instance.new("Folder")
	v12.Name = "Stun"
	v12.Parent = p1
	Instance.new("Folder", v12).Name = "NoDelete"
	l__Humanoid__7:UnequipTools()
	local v13 = {}
	table.insert(v13, p1["Right Arm"])
	local v14 = Instance.new("Attachment")
	v14.Name = "StepAttach"
	v14.Parent = p1["Right Arm"]
	if l__Value__9 == "Sunaikinti" then
		l__Parent__1.UberParticle:Clone().Parent = v14
		v14.UberParticle.Name = "Particle"
	else
		l__Parent__1.Particle:Clone().Parent = v14
	end
	v14.Position = Vector3.new(0, -p1["Right Arm"].Size.Y / 2, 0)
	task.wait(0.2)
	p1.HumanoidRootPart.Shoryu:Play()
	local v15 = tick()
	local v16 = {
		fist = true,
		physical = true, 
		damage = 5, 
		blockallsides = true,
		usingrising = true,
		aoe = true,
		move = "Rising Dragon"
	}
	local v17 = true
	for v18 = 1, 5 do
		if v18 == 4 or v18 == 5 then
			v16.knockup = true
			v16.shoryu = true
		end
		local v19, v20 = u2.magnitudeCheck(p1, p1.Torso.Position, 6.5, v16)
		if v19 then
			v17 = false
		end
		v6 = v20
		if v19 and v18 == 4 then
			break
		end
		task.wait(0.2)
	end
	for v21, v22 in next, v13 do
		local l__next__23 = next
		local v24, v25 = v22:children()
		while true do
			local v26, v27 = l__next__23(v24, v25)
			if not v26 then
				break
			end
			v25 = v26
			if v27.Name == "StepAttach" then
				v27.Particle.Enabled = false
				game.Debris:AddItem(v27, 0.3)
			end		
		end
	end
	v11:Destroy()
	if v6 or v17 then
		game.Debris:AddItem(v12, 1)
	else
		game.Debris:AddItem(v12, 0.25)
	end
	fixingsomething:Destroy()
	task.wait(10)
	u1 = true
end
local u3 = true
local l__TweenService__4 = game:GetService("TweenService")
local l__TagHumanoid__5 = game.ServerStorage.Requests.TagHumanoid
function v4.Active2(p5, p6, p7, p8)
	if ActionCheck(p5) then
		return
	end
	local l__Humanoid__28 = p5.Humanoid
	local l__HumanoidRootPart__29 = p5.HumanoidRootPart
	if not p6.Backpack:FindFirstChild("Misogi") then
		return
	end
	local l__Value__30 = game.ServerStorage.PlayerData:FindFirstChild(p6.Name).Class.Value
	if p5:FindFirstChild("LandedShoryuExcept") then
		local l__Value__31 = p5.LandedShoryuExcept.Value
		if not l__Value__31 or l__Value__31.Parent ~= workspace.Live or not (l__Value__31.Humanoid.Health > 0) then
			return
		elseif not u3 then
			return
		else
			u3 = false
			local v32 = game.Players:GetPlayerFromCharacter(l__Value__31)
			local v33 = Instance.new("Folder")
			v33.Name = "Immortal"
			v33.Parent = p5
			game.Debris:AddItem(v33, 5)
			local v34 = Instance.new("Folder")
			v34.Name = "TPSafe"
			v34.Parent = p5
			game.Debris:AddItem(v34, 5)
			local v35 = Instance.new("Folder")
			v35.Name = "Stun"
			v35.Parent = p5
			game.Debris:AddItem(v35, 5)
			local v36 = Instance.new("Folder")
			v36.Name = "NoFall"
			v36.Parent = p5
			game.Debris:AddItem(v36, 5)
			l__Value__31.Torso.Anchored = true
			if v32 then
				game.ReplicatedStorage.Requests.ScreenFlip:FireClient(v32)
			end
			game.ReplicatedStorage.Requests.ScreenFlip:FireClient(p6)
			local v37 = game.ReplicatedStorage.Assets.MisogiParticle:Clone()
			v37.Position = l__HumanoidRootPart__29.Position
			v37.Parent = workspace.Thrown
			if l__Value__30 == "Sunaikinti" then
				v37.Attachment.UberParticle.Enabled = true
			else
				v37.Attachment.Particle.Enabled = true
			end
			l__TweenService__4:Create(l__HumanoidRootPart__29, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				CFrame = l__HumanoidRootPart__29.CFrame + Vector3.new(0, 15, 0)
			}):Play()
			l__Humanoid__28:LoadAnimation(l__Parent__1.MisogiDown):Play()
			local v38 = l__Parent__1.Sound:Clone()
			v38.Parent = l__HumanoidRootPart__29
			v38:Play()
			game.Debris:AddItem(v38, 2)
			l__Humanoid__28:UnequipTools()
			task.wait(0.3)
			v37.Attachment.Particle.Enabled = false
			v37.Attachment.UberParticle.Enabled = false
			game.Debris:AddItem(v37, 1)
			l__Value__31.Torso.Anchored = false
			local v39, v40, v41 = workspace:FindPartOnRayWithIgnoreList(Ray.new(l__Value__31.Torso.Position, Vector3.new(0, 10, 0)), { workspace.Live, workspace.MonsterSpawns, workspace.Ingredients, workspace.Thrown })
			local v42 = CFrame.new(l__Value__31.Torso.Position) + Vector3.new(0, 10, 0)
			if v39 and v39.CanCollide then
				v42 = CFrame.new(v40) - Vector3.new(0, 3, 0)
			end
			p5:SetPrimaryPartCFrame(v42)
			local v43 = Instance.new("BodyVelocity")
			game.CollectionService:AddTag(v43, "AllowedBM")
			v43.Velocity = Vector3.new(0, -50, 0)
			v43.MaxForce = Vector3.new(0, 100000000, 0)
			v43.Parent = l__HumanoidRootPart__29
			game.Debris:AddItem(v43, 0.5)
			local v44 = {}
			table.insert(v44, p5["Left Arm"])
			local v45 = Instance.new("Attachment")
			v45.Name = "StepAttach"
			v45.Parent = p5["Left Arm"]
			if l__Value__30 == "Sunaikinti" then
				l__Parent__1.UberParticle:Clone().Parent = v45
				v45.UberParticle.Name = "Particle"
			else
				l__Parent__1.Particle:Clone().Parent = v45
			end
			v45.Position = Vector3.new(0, -p5["Left Arm"].Size.Y / 2, 0)
			l__TagHumanoid__5:Fire(p5, l__Value__31, {
				fist = true,
				physical = true, 
				damage = 30, 
				knockdown = true, 
				downbypass = true, 
				blockallsides = true, 
				misogi = true,
				move = "Rising Dragon"
			})
			task.wait(0.5)
			v33:Destroy()
			game.Debris:AddItem(v34, 0.5)
			game.Debris:AddItem(v35, 0.3)
			game.Debris:AddItem(v36, 1)
			for v46, v47 in next, v44 do
				if v47:FindFirstChild("StepAttach") then
					v47.StepAttach.Particle.Enabled = false
					game.Debris:AddItem(v47.StepAttach, 0.3)
				end
			end
			task.wait(5)
			u3 = true
			return
		end
	end
	if p6.Backpack:FindFirstChild("Misogi 2") then
		local v48 = nil
		if not u3 then
			return
		end
		u3 = false
		local u6 = nil
		local v49, v50 = pcall(function()
			u6 = game.ReplicatedStorage.Requests.GetTargetByCam:InvokeClient(p6)
		end)
		if not u6 then
			u3 = true
			return
		end
		local l__HumanoidRootPart__51 = u6:FindFirstChild("HumanoidRootPart")
		local v52 = l__HumanoidRootPart__51 and u6:FindFirstChild("Torso")
		if not v52 then
			u3 = true
			return
		end
		if (l__HumanoidRootPart__29.Position - l__HumanoidRootPart__51.Position).Magnitude > 50 then
			u3 = true
			return
		end
		l__Humanoid__28:LoadAnimation(l__Parent__1.MisogiStart):Play()
		local v53 = Instance.new("Folder")
		v53.Parent = p5
		v53.Name = "Action"
		game.Debris:AddItem(v53, 0.5)
		l__Humanoid__28:UnequipTools()
		local v54 = tick()
		while true do
			v48 = not (not p5:FindFirstChild("Stun"))
			task.wait(1/30)
			if tick() - v54 > 0.4 then
				break
			end
			if v48 then
				break
			end		
		end
		if v48 then
			task.wait(5)
			u3 = true
			return
		end
		local v55 = game.Players:GetPlayerFromCharacter(u6)
		local v56 = Instance.new("Folder")
		v56.Name = "Immortal"
		v56.Parent = p5
		game.Debris:AddItem(v56, 5)
		local v57 = Instance.new("Folder")
		v57.Name = "TPSafe"
		v57.Parent = p5
		game.Debris:AddItem(v57, 5)
		local v58 = Instance.new("Folder")
		v58.Name = "Stun"
		v58.Parent = p5
		game.Debris:AddItem(v58, 5)
		local v59 = Instance.new("Folder")
		v59.Name = "NoFall"
		v59.Parent = p5
		game.Debris:AddItem(v59, 5)
		if v55 then
			game.ReplicatedStorage.Requests.ScreenFlip:FireClient(v55)
		end
		game.ReplicatedStorage.Requests.ScreenFlip:FireClient(p6)
		local v60 = game.ReplicatedStorage.Assets.MisogiParticle:Clone()
		v60.Position = l__HumanoidRootPart__29.Position
		v60.Parent = workspace.Thrown
		if l__Value__30 == "Sunaikinti" then
			v60.Attachment.UberParticle.Enabled = true
		else
			v60.Attachment.Particle.Enabled = true
		end
		l__TweenService__4:Create(l__HumanoidRootPart__29, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			CFrame = l__HumanoidRootPart__29.CFrame + Vector3.new(0, 15, 0)
		}):Play()
		l__Humanoid__28:LoadAnimation(l__Parent__1.MisogiDown):Play()
		local v61 = l__Parent__1.Sound:Clone()
		v61.Parent = l__HumanoidRootPart__29
		v61:Play()
		game.Debris:AddItem(v61, 2)
		task.wait(0.3)
		v60.Attachment.UberParticle.Enabled = false
		v60.Attachment.Particle.Enabled = false
		game.Debris:AddItem(v60, 1)
		local v62, v63, v64 = workspace:FindPartOnRayWithIgnoreList(Ray.new(v52.Position, Vector3.new(0, 10, 0)), { workspace.Live, workspace.MonsterSpawns, workspace.Ingredients, workspace.Thrown })
		local v65 = CFrame.new(v52.Position) + Vector3.new(0, 10, 0)
		if v62 and v62.CanCollide then
			v65 = CFrame.new(v63) - Vector3.new(0, 3, 0)
		end
		p5:SetPrimaryPartCFrame(v65)
		local v66 = Instance.new("BodyVelocity")
		game.CollectionService:AddTag(v66, "AllowedBM")
		v66.Velocity = Vector3.new(0, -50, 0)
		v66.MaxForce = Vector3.new(0, 100000000, 0)
		v66.Parent = l__HumanoidRootPart__29
		game.Debris:AddItem(v66, 0.25)
		local v67 = {}
		table.insert(v67, p5["Left Arm"])
		local v68 = Instance.new("Attachment")
		v68.Name = "StepAttach"
		v68.Parent = p5["Left Arm"]
		if l__Value__30 == "Sunaikinti" then
			l__Parent__1.UberParticle:Clone().Parent = v68
			v68.UberParticle.Name = "Particle"
		else
			l__Parent__1.Particle:Clone().Parent = v68
		end
		v68.Position = Vector3.new(0, -p5["Left Arm"].Size.Y / 2, 0)
		l__TagHumanoid__5:Fire(p5, u6, {
			fist = true,
			damage = 30,
			physical = true, 
			knockdown = true, 
			downbypass = true, 
			blockallsides = true, 
			misogi = true,
			move = "Rising Dragon"
		})
		v56:Destroy()
		task.wait(0.5)
		game.Debris:AddItem(v57, 0.5)
		game.Debris:AddItem(v58, 0.3)
		game.Debris:AddItem(v59, 1)
		for v69, v70 in next, v67 do
			if v70:FindFirstChild("StepAttach") then
				v70.StepAttach.Particle.Enabled = false
				game.Debris:AddItem(v70.StepAttach, 0.3)
			end
		end
		task.wait(10)
		u3 = true
	end
end
return v4