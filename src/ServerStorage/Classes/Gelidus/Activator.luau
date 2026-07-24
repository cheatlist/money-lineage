local v1 = {}
function sub(...)
	coroutine.wrap(...)()
end
local v2 = require(game.ServerScriptService.Modules.HitDetection)
local v3 = require(game.ServerScriptService.Modules.TemperatureHandler)
v1.upperbound = 95
v1.lowerbound = 80
v1.signs = 6
v1.cost = 25
local v3 = {
	upperbound = 100, 
	lowerbound = 80, 
	signs = 0, 
	cost = 0
}
local l__FireWhip__1 = game.ServerStorage.SpellEffects.FireWhip
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
local l__Parent__3 = script.Parent
function v1.Activate(p1, p2, p3, p4)
	if not (not game.CollectionService:HasTag(p2, "Casting")) or not (not p2:FindFirstChild("ActiveCast"))then
		return
	end
	local l__Mana__4 = p2.Mana
	local v5 = game.Players:GetPlayerFromCharacter(p2)
	if p3 ~= 0 then
		if p3 ~= 0 then
			p2.HumanoidRootPart.Backfire:Play()
			l__TagHumanoid__2:Fire(p2, p2, {
				damage = 5,
				mana = true, 
				manaknockupself = true, 
				curse = true, 
				downbypass = true, 
				freeze = 7.5,
				move = "Gelidus"
			})
		end
		return
	end
	if p2:FindFirstChild("EndCast") then
		return
	end
	--game.ReplicatedStorage.Requests.ClientSprint:FireClient(v5)
	local v7 = Instance.new("Accessory")
	v7.Name = "ActiveCast"
	v7.Parent = p2
	local v8 = Instance.new("Accessory")
	v8.Name = "ConeCD"
	v8.Parent = p2
	l__Mana__4.Value = math.max(l__Mana__4.Value - v1.cost, 0)
	local v9 = Instance.new("IntValue")
	v9.Name = "SpeedBoost"
	v9.Value = -12
	v9.Parent = p2.Boosts
	p2.HumanoidRootPart.PerfectCast:Play()
	local v10 = l__FireWhip__1.IceSpell:Clone()
	local v11 = p2.Humanoid:LoadAnimation(script.RightPoint)
	if p4 then
		v11 = p2.Humanoid:LoadAnimation(script.BookPoint)
	end
	v11:Play(0.1,1.3,1.25)
	v10.Hit:Play()
	local v12 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180))
	if not p4 then
		v12 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180))
	end
	local u4 = Instance.new("Weld")
	local u5 = p2["Right Arm"]
	sub(function()
		u4.Name = "Weld"
		u4.Part0 = u5
		u4.Part1 = v10
		u4.Parent = v10
		u4.C1 = v12
	end)
	v10.Parent = game.Workspace.Thrown
	local l__HumanoidRootPart__13 = p2.HumanoidRootPart
	local v14 = script.BigLoopFire:clone()
	v14.Parent = l__HumanoidRootPart__13
	v14:Play()
	local v15 = 10
	if game.ServerStorage.PlayerData:FindFirstChild(p2.Name) and game.ServerStorage.PlayerData[p2.Name].Race.Value == "Rigan" then
		v15 = v15 * 1.25
	end
	local v16 = p2:FindFirstChild("EndCast") or (p2:FindFirstChild("Stun") or (p2:FindFirstChild("Knocked") or game.CollectionService:HasTag(p2, "Unconscious")))
	while p2.Mana.Value > 0 and not v16 and p2.Parent do
		
		local v17 = math.rad(15)
		local l__lookVector__18 = l__HumanoidRootPart__13.CFrame.lookVector
		local l__Position__19 = l__HumanoidRootPart__13.Position
		local v20 = {}
		local children = workspace.Live:GetChildren()
		for i = 1,#children do
			local v22 = children[i]
			if v22 ~= p2 and v22:IsA("Model") then
				local v23 = v22 and v22:FindFirstChild("Humanoid")
				local v24 = v23 and v23.RootPart
				if v24 and not v22:FindFirstChild("Stun") and not v22:FindFirstChild("Immortal") and not v22:FindFirstChild("CurseBlocking") and not v22:FindFirstChild("KenDodged") and (not v22:FindFirstChild("Knocked") and not v22:FindFirstChild("BurnCooldown")) then
					local l__Position__25 = v24.Position
					local v26 = l__Position__25 - l__Position__19
					if math.acos(l__lookVector__18:Dot(v26.unit)) <= v17 then
						if v26.magnitude < 24 then
							table.insert(v20, v22)
						end
					elseif (l__Position__25 - l__Position__19).magnitude < 2 then
						table.insert(v20, v22)
					end
				end
			end
		end
		for v27, v28 in pairs(v20)do
			if not v28:FindFirstChild("IceCase") and not v28:FindFirstChild("GelidusCD") then
				l__TagHumanoid__2:Fire(p2, v28, {
					mana = true, 
					damage = v15, 
					gelidusfreeze = true, 
					curse = true, 
					freeze = 7.5,
					canspellcounter = true,
					move = "Gelidus"
				})
			end
		end
		local v29 = p2:FindFirstChild("EndCast")
		if not v29 then
			v29 = p2:FindFirstChild("Stun")
			if not v29 then
				v29 = p2:FindFirstChild("Knocked")
				if not v29 then
					v29 = p2:FindFirstChild("Unconscious")
					if not v29 then
						v29 = not game.CollectionService:HasTag(p2, "SpellbladeCD") and l__Parent__3.Parent ~= p2
					end
				end
			end
		end
		v16 = v29
		task.wait()
	end
	sub(function()
		v7:Destroy()
		game.Debris:AddItem(v8,2)
		v9:Destroy()
		v10.ParticleEmitter.Enabled = false
		v11:Stop()
		v14:Destroy()
		v10.SpotLight.Enabled = false
		wait(1.5)
		u4:Destroy()
		v10:Destroy()
	end)
end
function v1.Deactivate(p5, p6, p7)
	local v30 = Instance.new("Accessory")
	v30.Name = "EndCast"
	v30.Parent = p6
	game:GetService("Debris"):AddItem(v30, 0.5)
end
local l__TweenService__6 = game:GetService("TweenService")
function v3.Activate(p8, p9, p10, p11, p12)
	if game.CollectionService:HasTag(p9, "Casting") then
		return
	end
	local PlayerData = game.ServerStorage.PlayerData[p9.Name]
	local v31 = game.Players:GetPlayerFromCharacter(p9)
	if PlayerData.Injuries.Value:find("Frostbite")or p9.Temperature.Value <= -5 or PlayerData.Temperature.Value <= -5 then return end
	local v32 = v31 and game.ServerStorage.PlayerData:FindFirstChild(v31.Name)
	local l__HumanoidRootPart__34 = p9.HumanoidRootPart
	if not p12[script.Parent.Name] and v31.Name ~= "Melon_Sensei" then
		return
	end
	if p10 == 0 and not game.CollectionService:HasTag(p9, "BrokenLeg")then
		local v35 = Instance.new("Accessory")
		v35.Name = "ActiveCast"
		v35.Parent = p9
		p9.Humanoid:LoadAnimation(script.Snap):Play()
		wait(0.2)
		local v36 = game.ReplicatedStorage.Assets.HandHoldIcey:Clone()
		v36.IllusionArm.Enabled = false
		v36.Parent = game.Workspace.Thrown
		v36.Snap:Play()
		v36.IllusionSnap:Emit(100)
		local v37 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180))
		if not p11 then
			v37 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180))
		end
		local u7 = Instance.new("Weld")
		local u8 = p9["Right Arm"]
		sub(function()
			u7.Name = "Weld"
			u7.Part0 = u8
			u7.Part1 = v36
			u7.Parent = v36
			u7.C1 = v37
			wait(1)
			v36:Destroy()
		end)
		local v38 = not p9 or not p9.Parent or (p9:FindFirstChild("EndCast") or (p9:FindFirstChild("Stun") or (p9:FindFirstChild("Knocked") or game.CollectionService:HasTag(p9, "Unconscious"))))
		local v39 = p9.Humanoid:LoadAnimation(script.Frozone)
		v39:Play(0.100000001, 1, 1.25)
		local v40 = Instance.new("BodyVelocity")
		game.CollectionService:AddTag(v40, "AllowedBM")
		v40.MaxForce = Vector3.new(80000, 10, 80000)
		v40.Velocity = l__HumanoidRootPart__34.CFrame.lookVector.unit * 90
		v40.Name = "ForwardVelocity"
		v40.Parent = l__HumanoidRootPart__34
		local v41 = script.SkateLoop:Clone()
		v41.Parent = l__HumanoidRootPart__34
		v41:Play()
		local v42 = script.WindLoop:Clone()
		v42.Parent = l__HumanoidRootPart__34
		v42:Play()
		local v43 = l__FireWhip__1.Frost:Clone()
		v43.Parent = l__HumanoidRootPart__34
		local v44 = Instance.new("Accessory")
		v44.Name = "IceCase"
		v44.Parent = p9
		local v45 = Instance.new("Accessory")
		v45.Name = "GeliFreezing"
		v45.Parent = p9
		task.spawn(function()
			local Temp = p9.Temperature
			local Boosts = p9:FindFirstChild'Boosts'
			if Boosts then
				while true do
					if not v45:IsDescendantOf(p9) then
						break
					end
					local ColdRes = Boosts:FindFirstChild'ColdResist'
					if not ColdRes then
						ColdRes = {Value = 0}
					end
						Temp.Value -= (.015)
						wait(0.1)	
				end
			end
		end)
		local v46 = {}
		for Indx, Obj in ipairs(p9:GetChildren())do
			if Obj:IsA("BasePart") and (Obj.Name:match("Arm") or Obj.Name:match("Leg")) then
				local v52 = Instance.new("Attachment")
				v52.Name = "IceyAttach"
				v52.Position = Vector3.new(0, -Obj.Size.Y / 2.25, 0)
				v52.Parent = Obj
				l__FireWhip__1.IceyTrail:Clone().Parent = v52
				table.insert(v46, v52)
			end		
		end
		local NoRegen = Instance.new("Accessory")
		NoRegen.Name = "NoRegen"
		NoRegen.Parent = p9
		game.Debris:AddItem(NoRegen,30)
		while p9.Mana.Value > 0 and not v38 do
			wait()
			local v53 = l__HumanoidRootPart__34.CFrame * CFrame.new(0, 4, -24)
			local v54, v55, v56 = workspace:FindPartOnRayWithIgnoreList(Ray.new(v53.p, Vector3.new(0, -10, 0)), { workspace.Live, workspace.Terrain, workspace.NPCs, workspace.Thrown, workspace.Destructibles, workspace.Ingredients, workspace.MonsterSpawns })
			if v54 then
				if v54.Material ~= Enum.Material.Ice then
					local v57 = l__FireWhip__1.IcePath:Clone()
					v57.Parent = workspace.Thrown
					v57.CFrame = CFrame.new(v55, v55 + v56) * CFrame.Angles(math.rad(90), math.rad(math.random(0, 360)), 0)
					l__TweenService__6:Create(v57, TweenInfo.new(1, Enum.EasingStyle.Linear), {
						Transparency = 1
					}):Play()
					game.Debris:AddItem(v57, 1)
					v57.Touched:Connect(function(p13)
						if p13.Parent.Name == "Shadow Buddy" then
							return
						end
						if p13 and p13.Parent and p13.Parent:FindFirstChild("Humanoid") and not p13.Parent:FindFirstChild("Freezing") then
							local v58 = Instance.new("Accessory")
							v58.Name = "GeliFreezing"
							v58.Parent = p13.Parent
							game.Debris:AddItem(v58, 5)
						end
					end)
				end
			else
				local v59 = l__FireWhip__1.IcePath:Clone()
				v59.Parent = workspace.Thrown
				v59.CFrame = CFrame.new(v53.p - Vector3.new(0, 10, 0)) * CFrame.Angles(0, math.rad(math.random(0, 360)), 0)
				l__TweenService__6:Create(v59, TweenInfo.new(1, Enum.EasingStyle.Linear), {
					Transparency = 1
				}):Play()
				game.Debris:AddItem(v59, 1)
				v59.Touched:Connect(function(p14)
					if not p14.Parent then
						return
					end
					if p14.Parent.Name == "Shadow Buddy" then
						return
					end
					if p14 and p14.Parent and p14.Parent:FindFirstChild("Humanoid") and not p14.Parent:FindFirstChild("Freezing") then
						local v60 = Instance.new("Accessory")
						v60.Name = "GeliFreezing"
						v60.Parent = p14.Parent
						game.Debris:AddItem(v60, 5)
					end
				end)
			end
			local v61 = not p9 or not p9.Parent or (p9:FindFirstChild("EndCast") or (p9:FindFirstChild("Stun") or (p9:FindFirstChild("Knocked") or (game.CollectionService:HasTag(p9, "Unconscious") ))))
			v38 = v61
			if not v38 then
				local v62, v63, v64 = workspace:FindPartOnRayWithIgnoreList(Ray.new(l__HumanoidRootPart__34.Position, l__HumanoidRootPart__34.CFrame.lookVector.unit * 3), { workspace.Live, workspace.Terrain, workspace.NPCs, workspace.Thrown, workspace.Destructibles, workspace.Ingredients, workspace.MonsterSpawns })
				if v62 and v62.Name ~= "IcePath" and (math.abs(v64.X) > 0.5 or math.abs(v64.Z) > 0.5) then
					v38 = true
				end
			end		
		end
		for v65, v66 in pairs(v46) do
			if v66 then
				v66:Destroy()
			end
		end
		v43.Enabled = false
		game.Debris:AddItem(v43,1)
		game.Debris:AddItem(NoRegen,2)
		v44:Destroy()
		v45:Destroy()
		v41:Destroy()
		v40:Destroy()
		v42:Destroy()
		v39:Stop()
		v35:Destroy()
	else
		local l__Backfire__67 = p9.HumanoidRootPart.Backfire
		l__Backfire__67.Play(l__Backfire__67)
		local v68 = {}
		v68.mana = true
		v68.damage = 12
		v68.manaknockupself = true
		v68.curse = true
		v68.downbypass = true
		v68.freeze = 7.5
		v68.move = "Gelidus"
		l__TagHumanoid__2.Fire(l__TagHumanoid__2, p9, p9, v68)
	end
	spawn(function()
		if v31 and v31:FindFirstChild("Danger")then
			wait(3)
			wait(20)
		else
			wait(3)
		end
	end)
end
v1.alternate = v3
return v1