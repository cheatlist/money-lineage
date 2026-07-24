local v1 = {}
function sub(...)
	coroutine.wrap(...)()
end
local l__Parent__1 = script.Parent.Parent
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked"},
	})
end
local v2 = tick()
function buffCheck(p1)
	if l__Parent__1:FindFirstChild("SigilBuff") then
		l__Parent__1.SigilBuff:Destroy()
	end
	for i,v in pairs(p1:GetChildren()) do
		if v.Name == "SigilPtcl" or v.Name == "SigilPartEffect" or v.Name == "SigilSound" or v.Name == "SigilLight" then
			v:Destroy()
		end
	end
end
local u2 = { workspace.Live, workspace.AreaMarkers }
function ray(p2, p3, p4, p5)
	local v3, v4, v5 = workspace:FindPartOnRayWithIgnoreList(Ray.new(p2, CFrame.new(p2, p3).LookVector * p4), u2)
	return v3, v4, v5
end
function rayCalculate(p6, p7, p8)
	local v6, v7, v8 = workspace:FindPartOnRayWithIgnoreList(Ray.new(p6, p7 * p8), u2)
	return v7, v8
end
local u3 = true
local u4 = l__Parent__1:FindFirstChild("Resolve")
local u5 = false
local u6 = true
local u7 = require(game.ServerScriptService.Modules.HitDetection)
local l__TweenService__8 = game:GetService("TweenService")
local u9 = require(game.ServerScriptService.Modules.EffectModule)
local u10 = true
local l__TagHumanoid__11 = game.ServerStorage.Requests.TagHumanoid
local u12 = true
local u13 = true
local u14 = true
function v1.Active(p9, p10, p11, p12)
	if ActionCheck() then
		return
	end
	if not p9:FindFirstChild("SigilBuff") then
		return
	end
	if not u3 then
		return
	end
	u3 = false
	local l__HumanoidRootPart__9 = p9.HumanoidRootPart
	local l__Humanoid__10 = p9.Humanoid
	local l__Value__11 = p9:FindFirstChild("SigilBuff").Value
	u4 = p9:FindFirstChild("Resolve")
	u5 = false
	if u4 and u4.Value >= 100 then
		u5 = true
	end
	if l__Value__11 == "Thunder" then
		if p9.Cooldowns:FindFirstChild("Thunder Charged Blow") then
			u3 = true
			return
		end
		local CD = Instance.new("NumberValue")
		CD.Name = "Thunder Charged Blow"
		CD.Value = 14
		CD.Parent = p9.Cooldowns
		game.Debris:AddItem(CD, 14)
		if not u5 then
			local v12 = Instance.new("Accessory")
			v12.Name = "HeavyAttack"
			v12.Parent = p9
			game:GetService("Debris"):AddItem(v12, 1)
			local v13 = Instance.new("Accessory")
			v13.Name = "NoJump"
			v13.Parent = p9
			game:GetService("Debris"):AddItem(v13, 1)
			local v14 = Instance.new("Accessory")
			v14.Name = "Action"
			v14.Parent = p9
			game:GetService("Debris"):AddItem(v14, 1)
			local v15 = l__Humanoid__10:LoadAnimation(script.Parent:FindFirstChild("thunderA"))
			v15:Play()
			v15:AdjustSpeed(1.5)
			p9.HumanoidRootPart.SworderEmit:Emit(30)
			p9.HumanoidRootPart.SwordCharge2:Play()
			v15.KeyframeReached:connect(function(p13)
				if p13 == "hitstart" then
					local v16 = 25
					local v17, v18, v19 = ray(l__HumanoidRootPart__9.Position, l__HumanoidRootPart__9.CFrame * CFrame.new(0, 0, -25).Position, 25)
					if v17 then
						v16 = (l__HumanoidRootPart__9.Position - v18).magnitude
					end
					u7.magnitudeCheck(p9, l__HumanoidRootPart__9.Position, v16,{
						physical = true, 
						damage = 25,
						manabreaker = true, 
						sword = true, 
						slash = true, 
						sigilthunder = true,
						chargedblow = true, 
						currentprop = p12,
						move = "Charged Blow"
					}, false, false, true)
					p9:SetPrimaryPartCFrame(l__HumanoidRootPart__9.CFrame * CFrame.new(0, 0, -v16))
					p9.HumanoidRootPart.LordSlash2:Play()
				end
			end)
		elseif u5 then
			u4.Value = 0
			local v20 = Instance.new("Accessory")
			v20.Name = "HeavyAttack"
			v20.Parent = p9
			game:GetService("Debris"):AddItem(v20, 1)
			local v21 = Instance.new("Accessory")
			v21.Name = "NoJump"
			v21.Parent = p9
			game:GetService("Debris"):AddItem(v21, 1)
			local v22 = Instance.new("Accessory")
			v22.Name = "Action"
			v22.Parent = p9
			game:GetService("Debris"):AddItem(v22, 1.2)
			local v23 = l__Humanoid__10:LoadAnimation(script.Parent:FindFirstChild("thunderA"))
			v23:Play()
			v23:AdjustSpeed(1.5)
			p9.HumanoidRootPart.LimitParticle.Enabled = true
			p9.HumanoidRootPart.LimitBreakActivate:Play()
			p9.HumanoidRootPart.LimitBreakActivate.TimePosition = 0.25
			spawn(function()
				wait(0.25)
				p9.HumanoidRootPart.LimitParticle.Enabled = false
			end)
			local v24 = game.ServerStorage.SpellEffects.sigilfire.lightninglimit:Clone()
			game.Debris:AddItem(v24, 2)
			v24.Parent = game.Workspace.Thrown
			v24.CFrame = l__HumanoidRootPart__9.CFrame * CFrame.new(0, -1.5, 0) * CFrame.Angles(0, 0, math.rad(90))
			local v25 = l__TweenService__8:Create(v24.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = Vector3.new(1, 80, 80)
			}):Play()
			local v26 = l__TweenService__8:Create(v24, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			v23.KeyframeReached:connect(function(p14)
				if p14 == "hitstart" then
					local v27 = {
						physical = true, 
						damage = 25, 
						sword = true, 
						slash = true, 
						sigilthunder = true,
						chargedblow = true, 
						currentprop = p12,
						move = "Charged Blow"
					}
					local l__Position__28 = l__HumanoidRootPart__9.Position
					for _,v33 in pairs(workspace.Live:GetChildren())do
						local l__Torso__34 = v33:FindFirstChild("Torso")
						local l__Humanoid__35 = v33:FindFirstChild("Humanoid")
						if v33 ~= p9 and l__Torso__34 and l__Humanoid__35 and l__Humanoid__35.Health > 0 and not v33:FindFirstChild("ForceField") and (l__Torso__34 and (l__Torso__34.Position - l__Position__28).magnitude) < 50 then
							local l__HumanoidRootPart__36 = l__Torso__34.Parent.HumanoidRootPart
							u7.magnitudeCheck(p9, l__HumanoidRootPart__36.Position, 3, v27, false)
							wait()
							p9:SetPrimaryPartCFrame(l__HumanoidRootPart__36.CFrame * CFrame.new(0, 0, -3))
							u9.Lightning(l__HumanoidRootPart__9.CFrame.p, l__HumanoidRootPart__9.Position, 1, 6, "White")
							l__HumanoidRootPart__36.Thunderbolt:Play()
							p9.HumanoidRootPart.LordSlash2:Play()
							local v37 = l__Humanoid__10:LoadAnimation(script.Parent:FindFirstChild("thunderA"))
							v37:Play()
							v37:AdjustSpeed(1.5)
							wait(0.1)
						end					
					end
				end
			end)
		end
		spawn(function()
			wait(14)
			u6 = true
		end)
	elseif l__Value__11 == "Flame" then
		if p9.Cooldowns:FindFirstChild("Flame Charged Blow") then
			u3 = true
			return
		end
		local CD = Instance.new("NumberValue")
		CD.Name = "Flame Charged Blow"
		CD.Value = 14
		CD.Parent = p9.Cooldowns
		game.Debris:AddItem(CD, 14)
		if not u5 then
			local v38 = Instance.new("Accessory")
			v38.Name = "HeavyAttack"
			v38.Parent = p9
			game:GetService("Debris"):AddItem(v38, 1)
			local v39 = Instance.new("Accessory")
			v39.Name = "NoJump"
			v39.Parent = p9
			game:GetService("Debris"):AddItem(v39, 1)
			local v40 = Instance.new("Accessory")
			v40.Name = "Action"
			v40.Parent = p9
			game:GetService("Debris"):AddItem(v40, 1.2)
			local v41 = l__Humanoid__10:LoadAnimation(script.Parent:FindFirstChild("flameA"))
			v41:Play()
			v41:AdjustSpeed(1.5)
			p9.HumanoidRootPart.SworderEmit:Emit(30)
			p9.HumanoidRootPart.SwordCharge:Play()
			v41.KeyframeReached:connect(function(p15)
				if p15 == "hitstart" then
					p9.HumanoidRootPart.LordSlash:Play()
					local v42 = game.ServerStorage.SpellEffects.sigilfire.crescent:Clone()
					local playerdata = game.ServerStorage:FindFirstChild("PlayerData"):FindFirstChild(p9.Name)
					local ascended = false
					if playerdata.Ascended.Value == true and playerdata.Race.Value == "Azael" then
						v42 = game.ServerStorage.SpellEffects.sigilfire.illusorycrescent:Clone()
						ascended = true
					end
					game.Debris:AddItem(v42, 1.25)
					v42.Parent = game.Workspace.Thrown
					v42.FireSlash:Play()
					v42.CFrame = l__HumanoidRootPart__9.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(math.rad(180), 0, math.rad(90))
					v42.BodyVelocity.Velocity = l__HumanoidRootPart__9.CFrame.LookVector * 80
					v42:SetNetworkOwner(nil)
					local u15 = {}
					local touched = false
					v42.Touched:connect(function(p16)
						if p16.Parent.Name == "Shadow Buddy" then
							return
						end
						if touched == true then return end
						local v43 = p16.Parent:FindFirstChild("Humanoid") or p16.Parent.Parent:FindFirstChild("Humanoid")
						if v43 and v43 ~= l__Humanoid__10 and not u15[v43.Parent] then
							u15[v43.Parent] = true
							l__TagHumanoid__11:Fire(p9, v43.Parent, {
								mana = true, 
								monkbreaker = true,
								damage = 12,
								manaknockupself = true, 
								burn = true,
								azaelcheck = true,
								downbypass = true,
								canspellcounter = true,
								ascendedburn = ascended,
								move = "Charged Blow"
							})
							touched = true
							return
						end
						if p16.Anchored == true and p16.Transparency ~= 1 then
							v42:Destroy()
						end
					end)
				end
			end)
		elseif u5 then
			u4.Value = 0
			local v44 = Instance.new("Accessory")
			v44.Name = "HeavyAttack"
			v44.Parent = p9
			game:GetService("Debris"):AddItem(v44, 0.8)
			local v45 = Instance.new("Accessory")
			v45.Name = "NoJump"
			v45.Parent = p9
			game:GetService("Debris"):AddItem(v45, 0.8)
			local v46 = Instance.new("Accessory")
			v46.Name = "Action"
			v46.Parent = p9
			game:GetService("Debris"):AddItem(v46, 0.8)
			local v47 = l__Humanoid__10:LoadAnimation(script.Parent:FindFirstChild("flameA"))
			v47:Play()
			v47:AdjustSpeed(1.5)
			p9.HumanoidRootPart.LimitParticle.Enabled = true
			p9.HumanoidRootPart.LimitBreakActivate:Play()
			p9.HumanoidRootPart.LimitBreakActivate.TimePosition = 0.25
			spawn(function()
				wait(0.25)
				p9.HumanoidRootPart.LimitParticle.Enabled = false
			end)
			v47.KeyframeReached:connect(function(p17)
				if p17 == "hitstart" then
					p9.HumanoidRootPart.LordSlash:Play()
					for v48 = 1, 3 do
						local v49 = game.ServerStorage.SpellEffects.sigilfire.crescent:Clone()
						game.Debris:AddItem(v49, 2)
						v49.Parent = game.Workspace.Thrown
						v49.FireSlash:Play()
						v49.CFrame = l__HumanoidRootPart__9.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(math.rad(180), 0, math.rad(90)) * CFrame.Angles(0, 0, math.rad(math.random(-20, 20)))
						v49.BodyVelocity.Velocity = l__HumanoidRootPart__9.CFrame.LookVector * 100
						local u16 = {}
						v49.Touched:connect(function(p18)
							if p18.Parent.Name == "Shadow Buddy" then
								return
							end
							local v50 = p18.Parent:FindFirstChild("Humanoid") or p18.Parent.Parent:FindFirstChild("Humanoid")
							if v50 and v50 ~= l__Humanoid__10 and not u16[v50.Parent] then
								u16[v50.Parent] = true
								l__TagHumanoid__11:Fire(p9, v50.Parent, {
									mana = true, 
									damage = 20, 
									manaknockupself = true, 
									burn = true,
									move = "Charged Blow"
								})
								return
							end
							if p18.Anchored == true and p18.Transparency ~= 1 then
								v49:Destroy()
							end
						end)
						wait(0.25)
					end
				end
			end)
		end
		spawn(function()
			wait(13)
			u10 = true
		end)
	elseif l__Value__11 == "Ice" then
		if p9.Cooldowns:FindFirstChild("Ice Charged Blow") then
			u3 = true
			return
		end
		local CD = Instance.new("NumberValue")
		CD.Name = "Ice Charged Blow"
		CD.Value = 14
		CD.Parent = p9.Cooldowns
		game.Debris:AddItem(CD, 14)
		if not u5 then
			local v51 = Instance.new("Accessory")
			v51.Name = "HeavyAttack"
			v51.Parent = p9
			game:GetService("Debris"):AddItem(v51, 1)
			local v52 = Instance.new("Accessory")
			v52.Name = "NoJump"
			v52.Parent = p9
			game:GetService("Debris"):AddItem(v52, 1)
			local v53 = Instance.new("Accessory")
			v53.Name = "Action"
			v53.Parent = p9
			game:GetService("Debris"):AddItem(v53, 1.2)
			local v54 = l__Humanoid__10:LoadAnimation(script.Parent:FindFirstChild("iceA"))
			v54:Play()
			v54:AdjustSpeed(1.5)
			p9.HumanoidRootPart.SworderEmit:Emit(30)
			p9.HumanoidRootPart.SwordCharge:Play()
			v54.KeyframeReached:Connect(function(p19)
				if p19 == "hitstart" then
					p9.HumanoidRootPart.LordSlash:Play()
					return
				elseif p19 == "hitfinish" then
					p9.HumanoidRootPart.Smashing:Play()
					local v55 = {}
					for v56: number = 1, 6 do
						local v57 = game.ServerStorage.SpellEffects.sigilfire.IceSpike:Clone()
						v57.Size = Vector3.new(v57.Size.X * (1 + v56 / 4), v57.Size.Y * (1 + v56 / 4), v57.Size.Z * (1 + v56 / 4))
						v57.CFrame = l__HumanoidRootPart__9.CFrame * CFrame.new(math.random(-2, 2), -7, -(v56 * 7 + v56)) * CFrame.Angles(math.rad(math.random(-10, 10)), math.rad(math.random(0, 360)), math.rad(math.random(-25, 25)))
						game.Debris:AddItem(v57, 10)
						v57.Parent = workspace
						v57.Burst:Play()
						l__TweenService__8:Create(v57, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							CFrame = v57.CFrame * CFrame.new(0, 8, 0)
						}):Play()
						local u17 = v57.Touched:Connect(function(p20)
							local Par = p20.Parent
							if not Par then
								return
							end
							if Par.Name == "Shadow Buddy" then
								return
							end
							local v59 = Par:FindFirstChild("Humanoid") or Par.Parent:FindFirstChild("Humanoid")
							if v59 and v59 ~= l__Humanoid__10 and not v55[v59.Parent] then
								v55[v59.Parent] = true
								l__TagHumanoid__11:Fire(p9, v59.Parent, {
									mana = true, 
									monkbreaker = true,
									manabreaker = true, 
									damage = 25, 
									manaknockupself = true,
									canspellcounter = true,
									move = "Charged Blow"
								})
							end
						end)
						task.spawn(function()
							wait(0.5)
							u17:Disconnect()
						end)
						wait(0.1)
					end
				end
			end)
		elseif u5 then
			u4.Value = 0
			local v60 = Instance.new("Accessory")
			v60.Name = "HeavyAttack"
			v60.Parent = p9
			game:GetService("Debris"):AddItem(v60, 0.8)
			local v61 = Instance.new("Accessory")
			v61.Name = "NoJump"
			v61.Parent = p9
			game:GetService("Debris"):AddItem(v61, 0.8)
			local v62 = Instance.new("Accessory")
			v62.Name = "Action"
			v62.Parent = p9
			game:GetService("Debris"):AddItem(v62, 0.8)
			local v63 = l__Humanoid__10:LoadAnimation(script.Parent:FindFirstChild("flameA"))
			v63:Play()
			v63:AdjustSpeed(1.5)
			p9.HumanoidRootPart.LimitParticle.Enabled = true
			p9.HumanoidRootPart.LimitBreakActivate:Play()
			p9.HumanoidRootPart.LimitBreakActivate.TimePosition = 0.25
			spawn(function()
				wait(0.25)
				p9.HumanoidRootPart.LimitParticle.Enabled = false
			end)
			v63.KeyframeReached:Connect(function(p21)
				if p21 == "hitstart" then
					p9.HumanoidRootPart.LordSlash:Play()
					for v64 = -2, 2 do
						local v65 = game.ServerStorage.SpellEffects.sigilfire.Snowflake:Clone()
						v65.CFrame = l__HumanoidRootPart__9.CFrame * CFrame.new(4 * v64, 1, -3) * CFrame.Angles(0, math.rad(-15 * v64), 0)
						game.Debris:AddItem(v65, 3)
						v65.Parent = workspace.Thrown
						game.Debris:AddItem(v65, 9)
						v65.WindBlow:Play()
						Instance.new("BodyVelocity", v65).Velocity = v65.CFrame.lookVector * 160
						local u18 = {}
						local v66 = v65.Touched:Connect(function(p22)
							if p22.Parent.Name == "Shadow Buddy" then
								return
							end
							local v67 = p22.Parent:FindFirstChild("Humanoid") or p22.Parent.Parent:FindFirstChild("Humanoid")
							if v67 and v67 ~= l__Humanoid__10 and not u18[v67.Parent] then
								u18[v67.Parent] = true
								l__TagHumanoid__11:Fire(p9, v67.Parent, {
									mana = true, 
									damage = 25, 
									manaknockupself = true, 
									icecase = 10, 
									sigilicelimit = true,
									canspellcounter = true,
									move = "Charged Blow"
								})
							end
						end)
					end
				end
			end)
		end
		task.spawn(function()
			wait(13)
			u12 = true
		end)
	elseif l__Value__11 == "White Fire" then
		if p9.Cooldowns:FindFirstChild("White Fire Charged Blow") then
			u3 = true
			return
		end
		local CD = Instance.new("NumberValue")
		CD.Name = "White Fire Charged Blow"
		CD.Value = 60
		CD.Parent = p9.Cooldowns
		game.Debris:AddItem(CD, 60)
		if not u5 then
			local v68 = Instance.new("Accessory")
			v68.Name = "HeavyAttack"
			v68.Parent = p9
			game:GetService("Debris"):AddItem(v68, 1)
			local v69 = Instance.new("Accessory")
			v69.Name = "NoJump"
			v69.Parent = p9
			game:GetService("Debris"):AddItem(v69, 1)
			local v70 = Instance.new("Accessory")
			v70.Name = "Action"
			v70.Parent = p9
			game:GetService("Debris"):AddItem(v70, 1.2)
			local v71 = l__Humanoid__10:LoadAnimation(script.Parent:FindFirstChild("flameA"))
			v71:Play()
			v71:AdjustSpeed(1.5)
			p9.HumanoidRootPart.SworderEmit:Emit(30)
			p9.HumanoidRootPart.SwordCharge:Play()
			v71.KeyframeReached:Connect(function(p23)
				if p23 == "hitstart" then
					p9.HumanoidRootPart.LordSlash:Play()
					local v72 = game.ServerStorage.SpellEffects.sigilfire.sportal:Clone()
					v72.CFrame = l__HumanoidRootPart__9.CFrame * CFrame.new(-10, 1, -5)
					game.Debris:AddItem(v72, 20)
					v72.Parent = workspace.Thrown
					v72.sownd:Play()
					l__TweenService__8:Create(v72, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						CFrame = v72.CFrame * CFrame.new(10, 0, 0), 
						Size = Vector3.new(20, 0.2, 0.2)
					}):Play()
					wait(0.3)
					local v74 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					l__TweenService__8:Create(v72, v74, {
						Size = Vector3.new(20, 10, 0)
					}):Play()
					wait(0.25)
					task.spawn(function()
						for v76 = 1, 40 do
							local v77 = game.ServerStorage.SpellEffects.sigilfire.WHITEBALL:Clone()
							game.Debris:AddItem(v77, 3.5)
							v77.FireSlash:Play()
							v77.CFrame = v72.CFrame * CFrame.new(math.random(-50, 50), math.random(0, 3), 0)
							v77.BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
							v77.BodyVelocity.Velocity = v72.CFrame.LookVector * 100
							v77.Parent = workspace.Thrown
							v77:SetNetworkOwner(nil)
							local u19 = {}
							v77.Touched:Connect(function(p24)
								if p24.Parent.Name == "Shadow Buddy" then
									return
								end
								local v78 = p24.Parent:FindFirstChild("Humanoid") or p24.Parent.Parent:FindFirstChild("Humanoid")
								if v78 and v78 ~= l__Humanoid__10 and not u19[v78.Parent]then
									u19[v78.Parent] = true
									l__TagHumanoid__11:Fire(p9, v78.Parent,{
										mana = true, 
										damage = 5, 
										sigilwhitefire = true,
										manaknockupself = true, 
										burn = true, 
										burncolor = Color3.fromRGB(255,255,255),
										downbypass = true,
										move = "Charged Blow"
									})
									return
								end
								if v78 and v78 == l__Humanoid__10 and not u19[v78.Parent] then
									u19[v78.Parent] = true
									l__TagHumanoid__11:Fire(p9, v78.Parent, {
										mana = true, 
										damage = 0, 
										manaknockupself = true
									})
									return
								end
								if p24.Anchored == true and p24.Transparency ~= 1 then
									v77:Destroy()
								end
							end)
							wait(0.15)
						end
						wait(1)
						l__TweenService__8:Create(v72, v74, {
							Size = Vector3.new(20, 0, 0)
						}):Play()
						l__TweenService__8:Create(v72.Light, v74, {
							Range = 0
						}):Play()
						v72.sownd.PlaybackSpeed = 2
						v72.sownd:Play()
						wait(0.5)
						v72.solan:Destroy()
						v72.solan2:Destroy()
					end)
				end
			end)
		elseif u5 then
			u4.Value = 0
			local v81 = Instance.new("Accessory")
			v81.Name = "HeavyAttack"
			v81.Parent = p9
			game:GetService("Debris"):AddItem(v81, 1)
			local v82 = Instance.new("Accessory")
			v82.Name = "NoJump"
			v82.Parent = p9
			game:GetService("Debris"):AddItem(v82, 1)
			local v83 = Instance.new("Accessory")
			v83.Name = "Action"
			v83.Parent = p9
			game:GetService("Debris"):AddItem(v83, 1.2)
			local v84 = l__Humanoid__10:LoadAnimation(script.Parent:FindFirstChild("flameA"))
			v84:Play()
			v84:AdjustSpeed(1.5)
			p9.HumanoidRootPart.SworderEmit:Emit(30)
			p9.HumanoidRootPart.SwordCharge:Play()
			v84.KeyframeReached:Connect(function(p25)
				if p25 == "hitstart" then
					p9.HumanoidRootPart.LordSlash:Play()
					local v85 = game.ServerStorage.SpellEffects.sigilfire.sportal:Clone()
					game.Debris:AddItem(v85, 20)
					v85.Parent = game.Workspace.Thrown
					v85.CFrame = l__HumanoidRootPart__9.CFrame * CFrame.new(-10, 1, -5)
					v85.sownd:Play()
					local v86 = l__TweenService__8:Create(v85, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						CFrame = v85.CFrame * CFrame.new(10, 0, 0), 
						Size = Vector3.new(20, 0.2, 0.2)
					}):Play()
					wait(0.2)
					local v87 = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					local v88 = l__TweenService__8:Create(v85, v87, {
						Size = Vector3.new(20, 10, 0)
					}):Play()
					wait(0.15)
					spawn(function()
						local v89 = game.ServerStorage.SpellEffects.sigilfire.WHITELASER:Clone()
						game.Debris:AddItem(v89, 1)
						v89.Parent = game.Workspace.Thrown
						v89.CFrame = v85.CFrame * CFrame.new(0, 0, -65) * CFrame.Angles(0, math.rad(90), 0)
						v89.lasersound:Play()
						local u20 = {}
						v89.Touched:connect(function(p26)
							if p26.Parent.Name == "Shadow Buddy" then
								return
							end
							local v90 = p26.Parent:FindFirstChild("Humanoid") or p26.Parent.Parent:FindFirstChild("Humanoid")
							if v90 and v90 ~= l__Humanoid__10 and not u20[v90.Parent] then
								u20[v90.Parent] = true
								l__TagHumanoid__11:Fire(p9, v90.Parent, {
									mana = true, 
									damage = 20, 
									sigilwhitefire = true, 
									manaknockupself = true, 
									burn = true, 
									burncolor = Color3.fromRGB(255, 255, 255),
									move = "Charged Blow"
								})
							end
						end)
						local v91 = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
						local v92 = l__TweenService__8:Create(v89.Mesh, v91, {
							Scale = Vector3.new(1, 1, 1)
						}):Play()
						wait(0.2)
						local v93 = l__TweenService__8:Create(v89.Mesh, v91, {
							Scale = Vector3.new(1, 0, 0)
						}):Play()
						wait(0.2)
						v89.WhiteBurning.Enabled = false
						wait(1)
						local v94 = l__TweenService__8:Create(v85, v87, {
							Size = Vector3.new(20, 0, 0)
						}):Play()
						local v95 = l__TweenService__8:Create(v85.Light, v87, {
							Range = 0
						}):Play()
						v85.sownd.PlaybackSpeed = 2
						v85.sownd:Play()
						wait(0.5)
						v85.solan:Destroy()
						v85.solan2:Destroy()
					end)
				end
			end)
		end
		spawn(function()
			wait(13)
			u13 = true
		end)
	elseif l__Value__11 == "Truth" then
		if not u14 then
			u3 = true
			return
		end
		u14 = false
		local l__sigilfire__96 = game.ServerStorage.SpellEffects.sigilfire
		if not u5 then
			local v97 = Instance.new("Accessory")
			v97.Name = "LightAttack"
			v97.Parent = p9
			game:GetService("Debris"):AddItem(v97, 1.2)
			local v98 = Instance.new("Accessory")
			v98.Name = "NoJump"
			v98.Parent = p9
			game:GetService("Debris"):AddItem(v98, 1.2)
			local v99 = Instance.new("Accessory")
			v99.Name = "Action"
			v99.Parent = p9
			game:GetService("Debris"):AddItem(v99, 1.2)
			local v100 = Instance.new("Accessory")
			v100.Name = "NoDelete"
			v100.Parent = v99
			local v101: TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local l__CFrame__102: CFrame = l__HumanoidRootPart__9.CFrame
			for v103: number = 1, 4 do
				l__Humanoid__10:LoadAnimation(script.Parent:FindFirstChild("truthA" .. v103)):Play()
				local v104 = l__sigilfire__96.TriSlash:Clone()
				game.Debris:AddItem(v104, 4)
				v104.Transparency = 0
				v104.Mesh.Scale = Vector3.new(0, 0, 0)
				if v103 == 1 then
					v104.CFrame = l__CFrame__102 * CFrame.new(0, -1.25, -4)
				elseif v103 == 2 then
					v104.CFrame = l__CFrame__102 * CFrame.new(-2, 2.5, -4) * CFrame.Angles(0, 0, math.rad(55))
				elseif v103 == 3 then
					v104.CFrame = l__CFrame__102 * CFrame.new(2, 2.5, -4) * CFrame.Angles(0, 0, math.rad(-55))
				elseif v103 == 4 then
					v104.CFrame = l__CFrame__102 * CFrame.new(0, 0, -7) * CFrame.Angles(0, math.rad(90), 0)
				end
				v104.Parent = workspace.Thrown
				l__TweenService__8:Create(v104.Mesh, v101, {
					Scale = Vector3.new(1, 1, 1)
				}):Play()
				task.spawn(function()
					wait(1.25)
					l__TweenService__8:Create(v104, v101, {
						Transparency = 1
					}):Play()
				end)
				local v107 = script.BasicHit:Clone()
				v107.PlaybackSpeed = math.random(10, 15) / 10
				v107.Parent = l__HumanoidRootPart__9
				v107:Play()
				game.Debris:AddItem(v107, 2)
				wait(0.1)
				local v108
				if v103 < 4 then
					v108 = {
						physical = true,
						sword = true, 
						damage = 7,
						slash = true,
						currentprop = p12,
						move = "Charged Blow"
					}
				else
					v108 = {
						physical = true,
						sword = true,
						damage = 10,
						knockback = true,
						slash = true,
						currentprop = p12,
						move = "Charged Blow"
					}
				end
				if not p9:FindFirstChild("Stun") then
					u7.magnitudeCheck(p9, l__HumanoidRootPart__9.Position, 13, v108, true)
				end
				wait(0.1)
			end
		elseif u5 then
			u4.Value = 0
			local v109 = Instance.new("Accessory")
			v109.Name = "LightAttack"
			v109.Parent = p9
			game:GetService("Debris"):AddItem(v109, 2)
			local v110 = Instance.new("Accessory")
			v110.Name = "NoJump"
			v110.Parent = p9
			game:GetService("Debris"):AddItem(v110, 2)
			local v111 = Instance.new("Accessory")
			v111.Name = "Action"
			v111.Parent = p9
			game:GetService("Debris"):AddItem(v111, 2)
			local v112 = Instance.new("Accessory")
			v112.Name = "Immortal"
			v112.Parent = p9
			game.Debris:AddItem(v112, 20)
			l__Humanoid__10:LoadAnimation(script.Parent:FindFirstChild("truthB1")):Play()
			p9.HumanoidRootPart.LimitParticle.Enabled = true
			p9.HumanoidRootPart.LimitBreakActivate:Play()
			p9.HumanoidRootPart.LimitBreakActivate.TimePosition = 0.25
			wait(0.25)
			p9.HumanoidRootPart.LimitParticle.Enabled = false
			if not p9:FindFirstChild("Stun") then
				p9.Humanoid.AutoRotate = false
				local v113 = Instance.new("BodyVelocity")
				game.CollectionService:AddTag(v113, "AllowedBM")
				v113.MaxForce = Vector3.new(1000000, 1000000, 1000000)
				v113.Velocity = p9.HumanoidRootPart.CFrame.lookVector * 100
				v113.Parent = p9.HumanoidRootPart
				game.Debris:AddItem(v113, 0.2)
				local v114 = nil
				local v115 = nil
				for v116 = 1, 3 do
					wait(0.1)
					if p9:FindFirstChild("Stun") then
						game:GetService("Debris"):AddItem(v113, 0.001)
						break
					end
					if p9:FindFirstChild("COUNTERED") then
						game:GetService("Debris"):AddItem(v113, 0.001)
						break
					end
					if p9:FindFirstChild("NoDam") then
						game:GetService("Debris"):AddItem(v113, 0.001)
						break
					end
					local l__next__117 = next
					local v118, v119 = game.Workspace.Live:GetChildren()
					while true do
						local v120, v121 = l__next__117(v118, v119)
						if not v120 then
							break
						end
						local l__HumanoidRootPart__122 = v121:FindFirstChild("HumanoidRootPart")
						local l__Humanoid__123 = v121:FindFirstChild("Humanoid")
						if v121 ~= p9 and l__HumanoidRootPart__122 and l__Humanoid__123 and l__Humanoid__123.Health > 0 and not v121:FindFirstChildOfClass("ForceField") and (l__HumanoidRootPart__122 and (l__HumanoidRootPart__122.Position - l__HumanoidRootPart__9.Position).magnitude) < 15 then
							v114 = v121
						end					
					end
					if v114 then
						game:GetService("Debris"):AddItem(v113, 0.001)
						v115 = l__HumanoidRootPart__9.CFrame
						break
					end
				end
				if v114 ~= nil then
					if v114 then
						local l__Humanoid__124 = v114:FindFirstChild("Humanoid")
					end
					local v125 = v114 and v114:FindFirstChild("HumanoidRootPart")
					local v126 = Instance.new("Accessory")
					v126.Name = "Action"
					v126.Parent = p9
					game:GetService("Debris"):AddItem(v126, 7)
					local v127 = Instance.new("Accessory")
					v127.Name = "NoDelete"
					v127.Parent = v126
					local v128 = Instance.new("Accessory")
					v128.Name = "FireRemove"
					v128.Parent = v114
					game.Debris:AddItem(v128, 1)
					local v129 = Instance.new("Accessory")
					v129.Name = "Action"
					v129.Parent = v114
					game:GetService("Debris"):AddItem(v129, 7)
					local v130 = Instance.new("Accessory")
					v130.Name = "NoDelete"
					v130.Parent = v129
					local v131 = l__sigilfire__96.limitTrail:Clone()
					game.Debris:AddItem(v131, 8)
					v131.Parent = p9.Torso
					v131.Attachment0 = p9.Torso.NeckAttachment
					v131.Attachment1 = p9.Torso.WaistCenterAttachment
					spawn(function()
						wait(7)
						v131.Enabled = false
					end)
					local l__p__132 = v115.p
					local v133 = v115 * CFrame.new(0, 0, 10).Position
					local v134 = Instance.new("BodyPosition")
					game.CollectionService:AddTag(v134, "AllowedBM")
					v134.Name = "TruthLimitFly"
					v134.D = 500
					v134.MaxForce = Vector3.new(1000000, 1000000, 1000000)
					v134.Position = l__p__132 + Vector3.new(0, 30, 0)
					v134.Parent = l__HumanoidRootPart__9
					game.Debris:AddItem(v134, 20)
					local v135 = Instance.new("BodyGyro")
					game.CollectionService:AddTag(v135, "AllowedBM")
					v135.Name = "TruthLimitAim"
					v135.D = 300
					v135.P = 10000
					v135.MaxTorque = Vector3.new(1000000, 1000000, 1000000)
					v135.CFrame = CFrame.new(l__HumanoidRootPart__9.Position, v125.Position)
					v135.Parent = l__HumanoidRootPart__9
					game.Debris:AddItem(v135, 20)
					spawn(function()
						while v135.Parent == l__HumanoidRootPart__9 do
							wait()
							v135.CFrame = CFrame.new(l__HumanoidRootPart__9.Position, v125.Position)						
						end
					end)
					local v136 = Instance.new("BodyPosition")
					game.CollectionService:AddTag(v136, "AllowedBM")
					v136.Name = "TruthLimitFly"
					v136.D = 500
					v136.MaxForce = Vector3.new(1000000, 1000000, 1000000)
					v136.Position = l__p__132 + Vector3.new(0, 30, 0)
					v136.Parent = v125
					game.Debris:AddItem(v136, 20)
					wait(0.5)
					local v137 = {
						physical = true, 
						sword = true, 
						damage = 4.5, 
						slash = true, 
						noenchant = true, 
						currentprop = p12,
						move = "Charged Blow"
					}
					local v138 = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					for v139 = 1, 7 do
						v134.Position = v125.CFrame * CFrame.new(math.random(-4, 4), math.random(-1, 1), math.random(-4, 4)).Position
						l__Humanoid__10:LoadAnimation(script.Parent:FindFirstChild("truthA" .. math.random(2, 3))):Play()
						wait(0.1)
						local v140 = script.HardHit:Clone()
						v140.Parent = l__HumanoidRootPart__9
						v140.PlaybackSpeed = math.random(10, 15) / 10
						v140:Play()
						game.Debris:AddItem(v140, 2)
						local v141 = l__sigilfire__96.ringeffect:Clone()
						game.Debris:AddItem(v141, 1)
						v141.Color = Color3.fromRGB(math.random(50, 255), math.random(50, 255), math.random(50, 255))
						v141.Parent = game.Workspace.Thrown
						v141.CFrame = v125.CFrame * CFrame.Angles(math.rad(math.random(0, 360)), math.rad(math.random(0, 360)), math.rad(math.random(0, 360)))
						local v142 = l__TweenService__8:Create(v141.Mesh, v138, {
							Scale = Vector3.new(30, 30, 1)
						}):Play()
						local v143 = l__TweenService__8:Create(v141, v138, {
							Transparency = 1
						}):Play()
						l__TagHumanoid__11:Fire(p9, v114, v137)
						wait(0.8 - v139 / 10)
					end
					v134.Position = v125.CFrame * CFrame.new(0, 0, -2).Position
					wait(0.2)
					l__Humanoid__10:LoadAnimation(script.Parent:FindFirstChild("truthB2")):Play()
					wait(0.6)
					local v144 = script.HardHit:Clone()
					v144.Parent = l__HumanoidRootPart__9
					v144.PlaybackSpeed = 1.5
					v144:Play()
					game.Debris:AddItem(v144, 2)
					l__TagHumanoid__11:Fire(p9, v114, {
						physical = true, 
						sword = true, 
						damage = 20, 
						knockback = 105, 
						slash = true, 
						noenchant = true, 
						currentprop = p12,
						move = "Charged Blow"
					})
					for v145 = 1, 3 do
						local v146 = l__sigilfire__96.ringeffect:Clone()
						game.Debris:AddItem(v146, 1)
						v146.Color = Color3.fromRGB(math.random(50, 255), math.random(50, 255), math.random(50, 255))
						v146.Parent = game.Workspace.Thrown
						v146.CFrame = v125.CFrame * CFrame.Angles(math.rad(math.random(0, 360)), math.rad(math.random(0, 360)), math.rad(math.random(0, 360)))
						local v147 = math.random(20, 45)
						local v148 = l__TweenService__8:Create(v146.Mesh, v138, {
							Scale = Vector3.new(v147, v147, 1)
						}):Play()
						local v149 = l__TweenService__8:Create(v146, v138, {
							Transparency = 1
						}):Play()
					end
					v136:Destroy()
					wait(0.4)
					v134:Destroy()
					v135:Destroy()
				end
				v112:Destroy()
				p9.Humanoid.AutoRotate = true
			else
				v112:Destroy()
			end
		end
		spawn(function()
			wait(2.5)
			u14 = true
		end)
	end
	wait(0.2)
	u3 = true
end
return v1