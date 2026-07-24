local v1 = {}
function sub(...)
	coroutine.wrap(...)()
end
v1.upperbound = 95
v1.lowerbound = 80
v1.signs = 6
v1.cost = 5
local l__FireWhip__1 = game.ServerStorage.SpellEffects.FireWhip
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
local l__Parent__3 = script.Parent
function v1.Activate(p1, p2, p3, p4)
	if not (not game.CollectionService:HasTag(p2, "Casting")) or not (not p2:FindFirstChild("ActiveCast"))then
		return
	end
	local l__Mana__2 = p2.Mana
	local v3
	if p2.Name ~= "Shadow Buddy" then
		v3 = game.Players:GetPlayerFromCharacter(p2)
	else
		v3 = game.Players:GetPlayerFromCharacter(p2.Parent)
	end
	local playerdata = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	local ascended = false
	local cursed = false
	if playerdata.Ascended.Value == true and playerdata.Race.Value == "Azael" then
		ascended = true
	end
	if playerdata.Skills.Value:find("TheCursedFlame") then
		cursed = true
	end
	if p3 ~= 0 then 
		if p3 ~= 0 then
			local v5 = l__FireWhip__1.BackfireBrick:Clone()
			if ascended == true then
				v5 = l__FireWhip__1.BackfireBrickAscended:Clone()
			end
			if cursed == true then
				v5 = l__FireWhip__1.BackfireBrickCursed:Clone()
			end
			v5.CFrame = p2.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(90), math.rad(-90))
			v5.Parent = game.Workspace.Thrown
			v5.ParticleEmitter:Emit(30)
			v5.Hit:Play()
			game:GetService("Debris"):AddItem(v5, 1.5)
			l__TagHumanoid__2:Fire(p2, p2, {
				mana = true, 
				manaknockupself = true, 
				burn = true, 
				curse = true, 
				damage = 10,
				ascendedburn = ascended,
				cursedflame = cursed,
				move = "Ignis"
			})
			p2.HumanoidRootPart.Backfire:Play()
		end
		return
	end
	--game.ReplicatedStorage.Requests.ClientSprint:FireClient(v3)
	local v6 = Instance.new("Accessory")
	v6.Name = "ActiveCast"
	v6.Parent = p2
	local v7 = Instance.new("Accessory")
	v7.Name = "ConeCD"
	v7.Parent = p2
	l__Mana__2.Value = math.max(l__Mana__2.Value - v1.cost, 0)
	local v8 = Instance.new("IntValue")
	v8.Name = "SpeedBoost"
	v8.Value = -12
	v8.Parent = p2.Boosts
	p2.HumanoidRootPart.PerfectCast:Play()
	local v9 = l__FireWhip__1.BurnSpell:Clone()
	if ascended == true then
		v9 = l__FireWhip__1.AscendedBurnSpell:Clone()
	end
	if cursed == true then
		v9 = l__FireWhip__1.CursedBurnSpell:Clone()
	end
	local v10 = nil
	if p2.Name ~= "Shadow Buddy" then
		v10 = p2.Humanoid:LoadAnimation(script.RightPoint)
		if v3.Backpack:FindFirstChild("Fart")then
			v10 = p2.Humanoid:LoadAnimation(script.RightPoint2)
		end
		if p4 then
			v10 = p2.Humanoid:LoadAnimation(script.BookPoint)
		end
		v10:Play(0.1,1.3,1.25)
	end
	v9.Hit:Play()
	local v11 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180))
	if not p4 then
		v11 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180))
	end
	local u4 = Instance.new("Weld")
	local u5 = p2["Right Arm"]
	sub(function()
		u4.Name = "Weld"
		u4.Part0 = u5
		u4.Part1 = v9
		u4.Parent = v9
		u4.C1 = v11
	end)
	v9.Parent = game.Workspace.Thrown
	local v12 = 10
	if game.ServerStorage.PlayerData:FindFirstChild(p2.Name) and (game.ServerStorage.PlayerData[p2.Name].Race.Value == "Azael") then
		v12 = v12 * 1.5
	end
	if game.ServerStorage.PlayerData:FindFirstChild(p2.Name) and (game.ServerStorage.PlayerData[p2.Name].Race.Value == "Kasparan") then
		v12 = v12 * 1.25
	end
	local l__HumanoidRootPart__13 = p2.HumanoidRootPart

	local v15 = p2:FindFirstChild("EndCast") or (p2:FindFirstChild("Stun") or (p2:FindFirstChild("Knocked") or p2:FindFirstChild("Unconscious") or not p2:FindFirstChild("Ignis")))
	local v16 = p2.Parent:FindFirstChild("EndCast") or (p2.Parent:FindFirstChild("Stun") or (p2.Parent:FindFirstChild("Knocked") or p2.Parent:FindFirstChild("Unconscious") or not p2:FindFirstChild("Ignis")))
	if p2.Name == "Shadow Buddy" then
		while p2.Parent.Mana.Value > 0 and not v16 and p2:FindFirstChild("Ignis") do
			wait()
			local v17 = math.rad(15)
			local l__lookVector__18 = l__HumanoidRootPart__13.CFrame.lookVector
			local l__Position__19 = l__HumanoidRootPart__13.Position
			local v20 = {}
			for v21, v22 in pairs(workspace.Live:children()) do
				if v22 ~= p2 and v22:IsA("Model") then
					local v23 = v22 and v22:FindFirstChild("Humanoid")
					local v24 = v23 and v23.RootPart
					if v24 and not v22:FindFirstChild("Stun") and not v22:FindFirstChild("NoDam") and not v22:FindFirstChild("BurnCooldown") and not v22:FindFirstChild("FireImmune") and not v22:FindFirstChild("FireProtection") then
						local l__Position__25 = v24.Position
						local v26 = l__Position__25 - l__Position__19
						if math.acos(l__lookVector__18:Dot(v26.unit)) <= v17 then
							if v26.magnitude < 20 then
								table.insert(v20, v22)
							end
						elseif (l__Position__25 - l__Position__19).magnitude < 2 then
							table.insert(v20, v22)
						end
					end
				end
			end
			for v29, v30 in pairs(v20) do
				if not v30:FindFirstChild("Burning") or v30:FindFirstChild("MonsterInfo") then
					l__TagHumanoid__2:Fire(p2, v30, {
						mana = true, 
						damage = v12, 
						manaknockup = 60, 
						curse = true, 
						burn = true,
						canspellcounter = true,
						move = "Ignis"
					})	
					local v31 = Instance.new("Accessory")
					v31.Name = "BurnCooldown"
					v31.Parent = v30
					--// corner ignis baby!
					game:GetService("Debris"):AddItem(v31, 1)
					if not v30:FindFirstChild("NoStun") and not v30:FindFirstChild("MonsterInfo") then
						local v32 = Instance.new("Accessory")
						v32.Name = "NoStun"
						v32.Parent = v30
						game:GetService("Debris"):AddItem(v32, 1)
					end
				end
			end
			v16 = p2.Parent:FindFirstChild("EndCast") or (p2.Parent:FindFirstChild("Stun") or (p2.Parent:FindFirstChild("Knocked") or p2.Parent:FindFirstChild("Unconscious")))		
		end
	else
		while p2.Mana.Value > 0 and not v15 and p2.Parent and p2:FindFirstChild("Ignis") do
			local v33 = math.rad(15)
			local l__lookVector__34 = l__HumanoidRootPart__13.CFrame.lookVector
			local l__Position__35 = l__HumanoidRootPart__13.Position
			local v36 = {}
			for v37, v38 in pairs(workspace.Live:children()) do
				if v38 ~= p2 and v38:IsA("Model") then
					local v39 = v38 and v38:FindFirstChild("Humanoid")
					local v40 = v39 and v39.RootPart
					if v40 and not v38:FindFirstChild("Stun") and not v38:FindFirstChild("NoDam") and not v38:FindFirstChild("BurnCooldown") and not v38:FindFirstChild("FireImmune") and not v38:FindFirstChild("FireProtection") then
						local l__Position__41 = v40.Position
						local v42 = l__Position__41 - l__Position__35
						if math.acos(l__lookVector__34:Dot(v42.unit)) <= v33 then
							if v42.magnitude < 19 then
								table.insert(v36, v38)
							end
						elseif (l__Position__41 - l__Position__35).magnitude < 2 then
							table.insert(v36, v38)
						end
					end
				end
			end
			for v45, v46 in pairs(v36) do
				if not v46:FindFirstChild("Burning") or v46:FindFirstChild("MonsterInfo") then
					l__TagHumanoid__2:Fire(p2, v46, {
						mana = true, 
						damage = v12, 
						manaknockup = 60, 
						curse = true, 
						burn = true,
						canspellcounter = true,
						ascendedburn = ascended,
						cursedflame = cursed,
						move = "Ignis"
					})
					if not v46:FindFirstChild("NoStun") and not v46:FindFirstChild("MonsterInfo") then
						local v48 = Instance.new("Accessory")
						v48.Name = "NoStun"
						v48.Parent = v46
						game:GetService("Debris"):AddItem(v48, 1)
					end
				end
			end

			for _,destructible in pairs(workspace.Destructibles:GetChildren()) do
				if destructible:IsA("Part") then
					local v42 = (destructible.Position - l__Position__35)
					if math.acos(l__lookVector__34:Dot(v42.unit)) <= v33 then
						if v42.magnitude < 19 and not destructible:FindFirstChild("Burning") then
							local clone = destructible:Clone()
							clone.Parent = game.ServerStorage
							game:GetService("TweenService"):Create(destructible, TweenInfo.new(0.8), {
								Color = Color3.fromRGB(17, 17, 17)
							}):Play()
							if game.ServerStorage.PlayerData:FindFirstChild(p2.Name) then
								if ascended == true then
									local burning = game.ServerStorage.Assets.AscendedBurning:Clone()
									burning.Parent = destructible
									burning.Enabled = true
								else
									local burning = game.ServerStorage.Assets.Burning:Clone()
									burning.Parent = destructible
									burning.Enabled = true
								end
							end
							local Burning = Instance.new("Accessory")
							Burning.Name = "Burning"
							Burning.Parent = destructible
							local touching = {}
							local burnConnection = destructible.Touched:Connect(function(hit)
								if touching[hit.Parent] or touching[hit.Parent] == true then return end
								if hit.Parent:FindFirstChild("Humanoid") then
									touching[hit.Parent] = true
									task.spawn(function()
										task.wait(1.5)
										touching[hit.Parent] = false
										touching[hit.Parent] = nil
									end)
									l__TagHumanoid__2:Fire(p2, hit.Parent, {
										burn = true,
										curse = true,
										mana = true,
										damage = 3,
										move = "Ignis",
										ascendedburn = ascended,
										cursedflame = cursed
									})
								end
							end)
							task.spawn(function()
								task.wait(5)
								destructible.Material = Enum.Material.Slate
								game:GetService("TweenService"):Create(destructible, TweenInfo.new(4), {
									Size = Vector3.new(math.random(0.2, 0.6), 0.4, math.random(0.2, 0.6))
								}):Play()
								task.wait(4)
								burnConnection:Disconnect()
								destructible:Destroy()
								task.wait(15)
								clone.Transparency = 1
								clone.Parent = workspace.Destructibles
								game:GetService("TweenService"):Create(clone, TweenInfo.new(0.7), {
									Transparency = 0
								}):Play()
							end)
						end
					end
				end
			end
			local v49 = p2:FindFirstChild("EndCast")
			if not v49 then
				v49 = p2:FindFirstChild("Stun") or (p2:FindFirstChild("Knocked") or (p2:FindFirstChild("Unconscious")and l__Parent__3.Parent ~= p2))
			end
			v15 = v49		
			task.wait()
		end
	end
	sub(function()
		v6:Destroy()
		game.Debris:AddItem(v7,2)
		v8:Destroy()
		v9.ParticleEmitter.Enabled = false
		if v10 ~= nil then
			v10:Stop()
		end
		v9.SpotLight.Enabled = false
		v9.PointLight.Enabled = false
		wait(1.5)
		u4:Destroy()
		v9:Destroy()

	end)
end
function v1.Deactivate(p5, p6, p7)
	local v50 = Instance.new("Accessory")
	v50.Name = "EndCast"
	v50.Parent = p6
	game:GetService("Debris"):AddItem(v50, 0.5)
end
local u6 = {
	upperbound = 60, 
	lowerbound = 50, 
	signs = 0, 
	cost = 100,
}
local l__TweenService__7 = game:GetService("TweenService")
local u8 = require(game.ServerScriptService.Modules.HitDetection)
function u6.Activate(p8, p9, p10, p11, p12)
	if game.CollectionService:HasTag(p9, "Casting") then
		return
	end
	local l__Mana__51 = p9.Mana
	local v52 = game.Players:GetPlayerFromCharacter(p9)
	local v53 = v52 and game.ServerStorage.PlayerData:FindFirstChild(v52.Name)
	if not p12[script.Parent.Name] then
		return
	end
	--l__Mana__51.Value = 100
	local u9 = _G.MouseData(v52)
	if not u9 then
		return
	end
	if not v53 or not p9:FindFirstChild("HumanoidRootPart") then
		return
	end
	if p9:FindFirstChild("Charge") then
		p9.Charge:Destroy()
	end
	local playerdata = game.ServerStorage.PlayerData:FindFirstChild(v52.Name)
	local ascended = false
	local cursed = false
	if playerdata.Ascended.Value == true and playerdata.Race.Value == "Azael" then
		ascended = true
	end
	if playerdata.Skills.Value:find("TheCursedFlame") then
		cursed = true
	end
	l__Mana__51.Value = math.max(l__Mana__51.Value - u6.cost, 0)
	if p10 == 0 then
		sub(function()
			p9.HumanoidRootPart.PerfectCast:Play()
			p9.Humanoid:LoadAnimation(script.Snap2):Play()
			wait(0.2)
			local v54 = game.ReplicatedStorage.Assets.HandHoldFire:Clone()
			v54.IllusionArm.Enabled = false
			v54.Parent = workspace.Thrown
			v54.Snap:Play()
			v54.IllusionSnap:Emit(100)
			local v55 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180))
			if not p11 then
				v55 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180))
			end
			local u10 = Instance.new("Weld")
			local u11 = p9["Right Arm"]
			sub(function()
				u10.Name = "Weld"
				u10.Part0 = u11
				u10.Part1 = v54
				u10.Parent = v54
				u10.C1 = v55
				wait(1)
				v54:Destroy()
			end)
			local v56 = l__FireWhip__1.Fireball:Clone()
			if ascended == true then
				v56 = l__FireWhip__1.AscendedFireball:Clone()
			end
			if cursed == true then
				v56 = l__FireWhip__1.CursedFireball:Clone()
			end
			v56.Position = p9.HumanoidRootPart.Position + CFrame.new(p9.HumanoidRootPart.Position, u9.Hit.p).LookVector * 15
			v56.CFrame = CFrame.new(v56.Position, u9.Hit.Position)
			v56.Parent = workspace.Thrown
			v56.Firesound:Play()
			v56:SetNetworkOwner(nil)
			v56.BodyVelocity.Velocity = v56.CFrame.LookVector * 120
			task.delay(5, v56.Destroy, v56)
			sub(function()
				wait(3)
				if v56:IsDescendantOf(workspace)then
					if v56:FindFirstChild("BodyVelocity") then
						v56.BodyVelocity:Destroy()
					end
					v56.Anchored = true
					v56.Firesound2:Stop()
					v56.Explosion:Emit(100)
					local Attach = v56:FindFirstChild'Attach'
					if Attach then
						Attach:Destroy()
						v56.IllusionArm:Destroy()
						v56.IllusionArm2:Destroy()
						v56.IllusionArm3:Destroy()
					end
					l__TweenService__7:Create(v56, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Size = Vector3.new(12, 12, 12), 
						Transparency = 1
					}):Play()
					if v56:FindFirstChild("PointLight") then
						l__TweenService__7:Create(v56.PointLight, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
							Range = 15
						}):Play()
					end
					u8.magnitudeCheck(p9, v56.Position, 15, {
						mana = true, 
						damage = 12, 
						manaknockupself = true, 
						canspellcounter = true,
						curse = true, 
						burn = true,
						ascendedburn = ascended,
						cursedflame = cursed,
						move = "Ignis"
					}, false, true)
					sub(function()
						wait(0.45)
						if v56:FindFirstChild("PointLight") then
							l__TweenService__7:Create(v56.PointLight, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
								Range = 0
							}):Play()
						end
					end)
					game:GetService("Debris"):AddItem(v56, 2)
				end
			end)
			local v57 = {}
			local u12 = nil
			u12 = v56.Touched:Connect(function(p13)
				if not p13.Parent then
					return
				end
				if p13:IsDescendantOf(workspace.Terrain) then
					return
				end
				if p13:IsDescendantOf(p9)or p13.Name == p9.Name or p13.Parent.Name == p9.Name then
					return
				end
				if p13.Name == v56.Name then
					return
				end
				if p13.Parent.Name == "Shadow Buddy" then
					return
				end
				local v58 = p13.Parent:FindFirstChild("Humanoid") or p13.Parent.Parent:FindFirstChild("Humanoid")
				if v58 and v58.Parent.Name == p9.Name then
					return
				end
				u12:Disconnect()
				v56.BodyVelocity:Destroy()
				v56.Anchored = true
				v56.Firesound2:Stop()
				v56.Explosion:Emit(100)
				v56.Attachment:Destroy()
				v56.IllusionArm:Destroy()
				v56.IllusionArm2:Destroy()
				v56.IllusionArm3:Destroy()
				l__TweenService__7:Create(v56, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Size = Vector3.new(12, 12, 12), 
					Transparency = 1
				}):Play()
				l__TweenService__7:Create(v56.PointLight, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Range = 15
				}):Play()
				local v59 = 18
				if game.ServerStorage.PlayerData:FindFirstChild(p9.Name) and (game.ServerStorage.PlayerData[p9.Name].Race.Value == "Azael" or game.ServerStorage.PlayerData[p9.Name].Race.Value == "Kasparan") then
					v59 = v59 * 1.25
				end
				u8.magnitudeCheck(p9, v56.Position, 20, {
					mana = true, 
					damage = v59, 
					manaknockupself = true, 
					canspellcounter = true,
					curse = true, 
					burn = true,
					ascendedburn = ascended,
					cursedflame = cursed,
					move = "Ignis"
				}, false, true)
				sub(function()
					wait(0.45)
					l__TweenService__7:Create(v56.PointLight, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Range = 0
					}):Play()
				end)
				game:GetService("Debris"):AddItem(v56, 2)
			end)
		end)
	else
		local playerdata = game.ServerStorage.PlayerData:FindFirstChild(v52.Name)
		local v60 = l__FireWhip__1.BackfireBrick:Clone()
		if ascended == true then
			v60 = l__FireWhip__1.BackfireBrickAscended:Clone()
		end
		if cursed == true then
			v60 = l__FireWhip__1.BackfireBrickCursed:Clone()
		end
		v60.CFrame = p9.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(90), math.rad(-90))
		v60.Parent = game.Workspace.Thrown
		v60.ParticleEmitter:Emit(30)
		v60.Hit:Play()
		game:GetService("Debris"):AddItem(v60, 1.5)
		l__TagHumanoid__2:Fire(p9, p9, {
			mana = true, 
			manaknockupself = true, 
			burn = true, 
			curse = true, 
			backfire = true, 
			canspellcounter = true,
			damage = 20,
			ascendedburn = ascended,
			cursedflame = cursed,
			move = "Ignis"
		})
		p9.HumanoidRootPart.Backfire:Play()
	end
end
v1.alternate = u6
return v1