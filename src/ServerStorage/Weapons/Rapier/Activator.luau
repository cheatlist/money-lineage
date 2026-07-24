local v1 = {}
local l__Parent__1 = script.Parent.Parent
function ActionCheck()
	if not l__Parent__1:FindFirstChild("Humanoid") then
		return true
	end
	if l__Parent__1:FindFirstChild("Charge") and not l__Parent__1.Artifacts:FindFirstChild("Unwavering Focus") then
		return true
	end
	if l__Parent__1:FindFirstChild("Stun") then
		return true
	end
	if l__Parent__1:FindFirstChild("ReturnStun") then
		return true
	end
	if l__Parent__1:FindFirstChild("Action") then
		return true
	end
	if l__Parent__1:FindFirstChild("Blocking") then
		return true
	end
	if l__Parent__1:FindFirstChild("SpellBlocking") then
		return true
	end
	if l__Parent__1:FindFirstChild("Unconscious")then
		return true
	end
	if l__Parent__1:FindFirstChild("Knocked")then
	else
		return
	end
	return true
end
local u2 = true
local u3 = false
local l__ComboTimer__4 = l__Parent__1:WaitForChild("ComboTimer")
local l__Combo__5 = l__Parent__1:WaitForChild("Combo")
local u6 = false
local l__TagHumanoid__7 = game.ServerStorage.Requests.TagHumanoid
local l__TweenService__8 = game:GetService("TweenService")
local u9 = require(game.ServerScriptService.Modules.HitDetection)
function v1.Active(p1, p2, p3, p4)
	if ActionCheck() then
		return
	end
	if p1:FindFirstChild("NoAttack") then
		return
	end
	if p1:FindFirstChild("Grabbing") then
		return
	end
	if p1:FindFirstChild("Knocked")then
		return
	end
	if not u2 then
		return
	end
	local l__Humanoid__2 = p1.Humanoid
	local v3 = false
	if p2.Backpack:FindFirstChild("ManaGun") then
		v3 = true
	end
	local v4 = 0.1
	local l__next__5 = next
	local v6, v7 = p1.Boosts:GetChildren()
	for _,v9 in pairs(p1.Boosts:GetChildren())do
		if v9.Name == "AttackSpeedBoost" then
			v4 = v4 / v9.Value
		end	
	end
	local v10 = 0.5
	if v3 == true and u3 == true then
		v10 = 0.4
	end
	local v11 = Instance.new("Accessory")
	v11.Name = "LightAttack"
	v11.Parent = p1
	game:GetService("Debris"):AddItem(v11, v10 + v4)
	local v12 = Instance.new("Accessory")
	v12.Name = "NoJump"
	v12.Parent = p1
	game:GetService("Debris"):AddItem(v12, 1)
	local v13 = 0
	if p4 ~= nil then
		v13 = p4.Stats.Damage.Value
	end
	u2 = false
	if tick() - l__ComboTimer__4.Value > 1.2 then
		l__Combo__5.Value = 1
	end
	l__ComboTimer__4.Value = tick()
	if l__Combo__5.Value >= 6 then
		l__Combo__5.Value = 5
	end
	if p1:FindFirstChild("Grabbing") and l__Combo__5.Value == 3 then
		l__Combo__5.Value = 4
	end
	if p1:FindFirstChild("Grabbing") and l__Combo__5.Value == 1 then
		l__Combo__5.Value = 2
	end
	local v14 = l__Humanoid__2:LoadAnimation(p3["Rapier" .. l__Combo__5.Value])
	if l__Combo__5.Value >= 5 and v3 == true then
		v14 = l__Humanoid__2:LoadAnimation(script.QuickBlast)
	end
	local v15 = 1.05
	if game.CollectionService:HasTag(p1, "BrokenArm") and l__Combo__5.Value < 6 then
		v15 = 0.8
	end
	if game.CollectionService:HasTag(p1, "Armless") and l__Combo__5.Value < 6 then
		v15 = 0.8
	end
	v14:Play(0.1, 1, v15 * 1.45)
	local u10 = p4
	local l__HumanoidRootPart__11 = p1.HumanoidRootPart
	v14.KeyframeReached:Connect(function(p5)
		if p5 == "slash" then
			if u10:FindFirstChild("TestTrail") then
				u10.TestTrail.Enabled = true
			end
			local v16 = math.random(1, 2)
			if l__Combo__5.Value == 7 then
				l__HumanoidRootPart__11.DaggerSlash2:Play()
			else
				l__HumanoidRootPart__11.DaggerSlash1:Play()
			end
		end
		if p5 == "lastframe" and u10:FindFirstChild("TestTrail") then
			u10.TestTrail.Enabled = false
		end
	end)
	u6 = true
	if v3 == true and u3 == true then
		wait(0.4)
	else
		wait(0.2)
	end
	u6 = false
	l__Combo__5.Value = l__Combo__5.Value + 1
	if l__Combo__5.Value >= 6 then
		u3 = true
		l__Combo__5.Value = 1
	end
	local l__BaneEff__17 = p1:FindFirstChild("BaneEff")
	if not p1:FindFirstChild("Stun") then
		if l__BaneEff__17 then
			local v18 = {}
			local v19 = nil
			local v20 = math.random(1,20)
			for _,v25 in pairs(workspace.Live:GetChildren())do
				local l__Humanoid__26 = v25:FindFirstChild("Humanoid")
				local v27 = l__Humanoid__26 and l__Humanoid__26.RootPart
				local v28 = false
				if l__Humanoid__26.Health >= 0 then
					v28 = not v25:FindFirstChild("Unconscious")
				end
				if v25 ~= p1 and v27 and v28 then
					local l__magnitude__29 = (l__HumanoidRootPart__11.Position - v27.Position).magnitude
					if l__magnitude__29 <= 20 and (l__HumanoidRootPart__11.CFrame:inverse() * v27.CFrame).Z < 0 then
						v18[v25] = {
							pos = v27.Position, 
							mag = l__magnitude__29
						}
						if l__magnitude__29 < v20 then
							local v30, v31, v32 = workspace:FindPartOnRayWithIgnoreList(Ray.new(l__HumanoidRootPart__11.Position, CFrame.new(l__HumanoidRootPart__11.Position, v27.Position).LookVector * 20 * 1.5), { workspace.Live, workspace.Thrown, workspace.Destructibles, workspace.MonsterSpawns })
							if not v30 then
								v19 = v25
								v20 = l__magnitude__29
							end
						end
					end
				end			
			end
			if v19 and l__BaneEff__17 and l__Combo__5.Value == 2 then
				local v33 = v18[v19]
				v33.mag = 1.5
				l__HumanoidRootPart__11.ShadowEmitter:Emit(30)
				--l__HumanoidRootPart__11.Blink:Play()
				local l__CFrame__34 = l__HumanoidRootPart__11.CFrame
				l__HumanoidRootPart__11.CFrame = CFrame.new(v33.pos, l__CFrame__34.p) * CFrame.new(0, 0, -4) * (l__CFrame__34 - l__CFrame__34.p)
			end
			for v35, v36 in pairs(v18)do
				if v36.mag <= 10 then
					if u3 == false then
						l__TagHumanoid__7:Fire(p1, v35, {
							physical = true, 
							rapier = true, 
							dagger = true,
							damage = v13, 
							slash = true,
							blade = true,
							poison = (p1:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
						})
					else
						l__TagHumanoid__7:Fire(p1, v35, {
							physical = true, 
							dagger = true, 
							rapier = true,
							damage = v13, 
							knockback = true, 
							slash = true,
							blade = true,
							poison = (p1:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
						})
					end
				end
			end
		elseif v3 == true and u3 == true then
			u10 = p1:FindFirstChild("ManaPistol", true)
			if u10 == nil then
				return
			end
			u10.Blast:Play()
			local v37 = game.ServerStorage.Assets.LaserPart1:Clone()
			local v38 = game.ServerStorage.Assets.LaserPart2:Clone()
			game:GetService("Debris"):AddItem(v37, 0.25)
			game:GetService("Debris"):AddItem(v38, 0.25)
			v37.CFrame = p1.HumanoidRootPart.CFrame * CFrame.new(0.25, 1, -18) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0))
			local l__Value__39 = p2.Backpack.ManaColor.Value
			v37.Color = Color3.new(l__Value__39.r, l__Value__39.g, l__Value__39.b)
			v37.PointLight.Color = Color3.new(l__Value__39.r, l__Value__39.g, l__Value__39.b)
			v38.CFrame = p1.HumanoidRootPart.CFrame * CFrame.new(0.25, 1, -18) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0))
			v37.Parent = game.Workspace.Thrown
			v38.Parent = game.Workspace.Thrown
			l__TweenService__8:Create(v37, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
				Transparency = 0, 
				Size = Vector3.new(25, 1.63, 1.69)
			}):Play()
			l__TweenService__8:Create(v38, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
				Transparency = 0, 
				Size = Vector3.new(23, 0.58, 0.52)
			}):Play()
			for v40, v41 in pairs(game.Workspace.Live:GetChildren()) do
				if v41:FindFirstChild("HumanoidRootPart") then
					local v42 = p1.HumanoidRootPart.CFrame:inverse() * v41.HumanoidRootPart.CFrame
					if v42.Z < 0 and v42.Z > -25 and math.abs(v42.X) < 10 and math.abs(v42.Y) < 10 then
						l__TagHumanoid__7:Fire(p1, v41, {
							physical = true, 
							mana = true, 
							manabreaker = true, 
							damage = 20, 
							knockback = true,
							blade = true,
							poison = (p1:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
						})
						if u10 ~= nil and u10:FindFirstChild("Hit") then
							local v43 = u10.Hit:Clone()
							v43.Parent = v41.HumanoidRootPart
							v43:Play()
							game:GetService("Debris"):AddItem(v43, 2)
						end
					end
				end
			end
		else
			local v44 = {
				physical = true, 
				sword = true, 
				damage = v13, 
				slash = true,
				blade = true,
				poison = (p1:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
			}
			if u3 then
				v44 = {
					physical = true, 
					sword = true, 
					damage = v13,
					knockback = true, 
					slash = true,
					blade = true,
					poison = (p1:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
				}
			end
			u9.magnitudeCheck(p1, l__HumanoidRootPart__11.Position, 10, v44, true)
		end
	end
	if u3 then
		local v45 = Instance.new("Accessory")
		v45.Name = "Action"
		v45.Parent = p1
		game:GetService("Debris"):AddItem(v45,0.75)
		Instance.new("Folder",v45).Name = "NoDelete"
		u3 = false
		wait(0.1)
	end
	wait(v4)
	u2 = true
end
local u12 = false
local u13 = 1
function v1.Active2(p6, p7, p8, p9)
	if p6:FindFirstChild("Grabbing")then
		return
	end
	if ActionCheck()then
		return
	end
	if p6:FindFirstChild("NoAttack")then
		return
	end
	if u12 == true then
		return
	end
	if p6:FindFirstChild("Knocked")then
		return
	end
	if not u2 then
		return
	end
	local v46 = false
	if p7.Backpack:FindFirstChild("ManaGun")then
		v46 = true
	end
	local l__HumanoidRootPart__47 = p6.HumanoidRootPart
	u12 = true
	local v48 = 0
	if p9 ~= nil then
		v48 = p9.Stats.Damage.Value
	end
	if v46 == true then
		p9 = p6:FindFirstChild("ManaPistol", true)
		p6.Humanoid:LoadAnimation(script.ManaBlast):Play()
		local v49 = Instance.new("Accessory")
		v49.Name = "HeavyAttack"
		v49.Parent = p6
		game:GetService("Debris"):AddItem(v49, 1.2)
		local v50 = Instance.new("Accessory")
		v50.Name = "NoJump"
		v50.Parent = p6
		game:GetService("Debris"):AddItem(v50, 1)
		u2 = false
		wait(0.3)
		local v51 = p9 and p9:FindFirstChild("SpinSound")
		if v51 then
			spawn(function()
				v51:Play()
				wait(1.2)
				v51:Stop()
			end)
		end
		spawn(function()
			if p9 and p9:FindFirstChild("Attachment") then
				p9.Attachment.Charge.Enabled = true
				p9.Attachment.Partic.Enabled = true
			end
		end)
		wait(0.85)
		spawn(function()
			if p9 and p9:FindFirstChild("Blast") then
				p9.Blast:Play()
			end
			p9.Attachment.Charge.Enabled = false
			p9.Attachment.Partic.Enabled = false
		end)
		local v52 = game.ServerStorage.Assets.LaserPart1:Clone()
		local v53 = game.ServerStorage.Assets.LaserPart2:Clone()
		game:GetService("Debris"):AddItem(v52, 0.25)
		game:GetService("Debris"):AddItem(v53, 0.25)
		v52.CFrame = p6.HumanoidRootPart.CFrame * CFrame.new(0.25, 1, -18) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0))
		local l__Value__54 = p7.Backpack.ManaColor.Value
		v52.Color = Color3.new(l__Value__54.r, l__Value__54.g, l__Value__54.b)
		v52.PointLight.Color = Color3.new(l__Value__54.r, l__Value__54.g, l__Value__54.b)
		v53.CFrame = p6.HumanoidRootPart.CFrame * CFrame.new(0.25, 1, -18) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0))
		v52.Parent = game.Workspace.Thrown
		v53.Parent = game.Workspace.Thrown
		l__TweenService__8:Create(v52, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
			Transparency = 0, 
			Size = Vector3.new(25, 1.63, 1.69)
		}):Play()
		l__TweenService__8:Create(v53, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
			Transparency = 0, 
			Size = Vector3.new(23, 0.58, 0.52)
		}):Play()
		for v55, v56 in pairs(game.Workspace.Live:GetChildren()) do
			if v56:FindFirstChild("HumanoidRootPart") then
				local v57 = p6.HumanoidRootPart.CFrame:inverse() * v56.HumanoidRootPart.CFrame
				if v57.Z < 0 and v57.Z > -25 and math.abs(v57.X) < 10 and math.abs(v57.Y) < 10 then
					l__TagHumanoid__7:Fire(p6, v56, {
						physical = true, 
						mana = true, 
						manabreaker = true, 
						damage = 20, 
						disarm = true, 
						blockbreak = true,
						blade = true,
						poison = (p6:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
					})
					if p9 ~= nil and p9:FindFirstChild("Hit") then
						local v58 = p9.Hit:Clone()
						v58.Parent = v56.HumanoidRootPart
						v58:Play()
						game:GetService("Debris"):AddItem(v58, 2)
					end
				end
			end
		end
	else
		local v59 = Instance.new("Accessory")
		v59.Name = "HeavyAttack"
		v59.Parent = p6
		game:GetService("Debris"):AddItem(v59, 1.2)
		local v60 = Instance.new("Accessory")
		v60.Name = "NoJump"
		v60.Parent = p6
		game:GetService("Debris"):AddItem(v60, 1)
		u2 = false
		if tick() - l__ComboTimer__4.Value > 5 then
			u13 = 1
		end
		l__ComboTimer__4.Value = tick()
		local v61 = l__HumanoidRootPart__47.ChargePart:Clone()
		if u13 == 1 then
			v61.Parent = p6["Right Arm"]
			v61.Enabled = true
		end
		local v62 = p6.Humanoid:LoadAnimation(p8["RapierHeavy" .. u13])
		v62:Play(0.1, 1, 1.25)
		u6 = true
		l__HumanoidRootPart__47.DaggerCharge:Play()
		game:GetService("Debris"):AddItem(v61, 0.5)
		wait(0.125)
		v62:AdjustSpeed(0)
		spawn(function()
			wait(0.35)
			wait(0.35)
			v62:Stop()
		end)
		wait(0.35)
		if p9:FindFirstChild("TestTrail") then
			p9.TestTrail.Enabled = true
		end
		l__HumanoidRootPart__47.DaggerSlash2:Play()
		v62.KeyframeReached:Connect(function(p10)
			if p10 == "final" and p9:FindFirstChild("TestTrail") then
				p9.TestTrail.Enabled = false
			end
		end)
		if u13 == 2 then
			v62:AdjustSpeed(1)
		else
			v62:AdjustSpeed(1.5)
		end
		u6 = false
		u13 = u13 + 1
		if u13 >= 1 then
			u13 = 1
		end
		spawn(function()
			wait(1)
			if p9:FindFirstChild("TestTrail") then
				p9.TestTrail.Enabled = false
			end
		end)
		local v63 = Instance.new("Accessory")
		v63.Name = "Action"
		v63.Parent = p6
		game:GetService("Debris"):AddItem(v63, 0.65)
		if not p6:FindFirstChild("Stun") and not p6:FindFirstChild("NoDam") then
			u9.magnitudeCheck(p6, l__HumanoidRootPart__47.Position, 8.5, {
				physical = true,
				damage = v48,
				knockback = true,
				dagger = true,
				disarm = true,
				blockbreak = true,
				slash = true,
				blade = true,
				poison = (p6:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
			})
		end
	end
	wait(0.35)
	l__Combo__5.Value = 1
	u3 = false
	u2 = true
	wait(1.5)
	u12 = false
end
return v1