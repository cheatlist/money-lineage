local v1 = {}
function sub(...)
	coroutine.wrap(...)()
end
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
local l__Parent__1 = script.Parent.Parent
function ActionCheck()
	if not l__Parent__1:FindFirstChild("Humanoid") then
		return true
	end
	if l__Parent__1:FindFirstChild("NoAttack") then
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
	if l__Parent__1:FindFirstChild("Unconscious") then
		return true
	end
	if l__Parent__1:FindFirstChild("Knocked") then
		return true
	end
	if l__Parent__1:FindFirstChild("HeavyAttack") then
		return true
	end
	if l__Parent__1:FindFirstChild("LightAttack") then
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
local u7 = false
local u8 = require(game.ServerScriptService.Modules.HitDetection)
function v1.Active(p1, p2, crazy, p3)
	if ActionCheck() then
		return
	end
	if p1:FindFirstChild("Grabbing") then
		return
	end
	if p1:FindFirstChild("Knocked") then
		return
	end
	if p1:FindFirstChild("NoAttack") then
		return
	end
	if p1:FindFirstChild("Rolling") and not game.Players:GetPlayerFromCharacter(p1).Backpack:FindFirstChild("SpearDash") then
		return
	end
	if not u2 then
		return
	end
	if p1:FindFirstChild("Stun") then
		return
	end
	u3 = false
	if p3:FindFirstChild("Poison") then
		u3 = true
	end
	game.ReplicatedStorage.Requests.StopSprint:FireClient(p2)
	local l__Humanoid__3 = p1.Humanoid
	local v4 = 0.175 - p3.Stats.Speed.Value
	local l__next__5 = next
	local v6, v7 = p1.Boosts:GetChildren()
	while true do
		local v8, v9 = l__next__5(v6, v7)
		if not v8 then
			break
		end
		v7 = v8
		if v9.Name == "AttackSpeedBoost" then
			v4 = v4 / v9.Value
		end	
	end
	local v10 = Instance.new("Accessory")
	v10.Name = "LightAttack"
	v10.Parent = p1
	game.Debris:AddItem(v10, 0.45 + v4)
	local v102 = Instance.new("Accessory")
	v102.Name = "ChargeBlock"
	v102.Parent = p1
	game.Debris:AddItem(v102, 0.45 + v4)
	local v11 = Instance.new("Accessory")
	v11.Name = "NoJump"
	v11.Parent = p1
	game.Debris:AddItem(v11, 1)
	u2 = false
	if tick() - l__ComboTimer__4.Value > 1.5 then
		l__Combo__5.Value = 1
	end
	l__ComboTimer__4.Value = tick()
	if l__Combo__5.Value >= 5 then
		l__Combo__5.Value = 4
	end
	if p1:FindFirstChild("Grabbing") and l__Combo__5.Value == 3 then
		l__Combo__5.Value = 4
	end
	if p1:FindFirstChild("Grabbing") and l__Combo__5.Value == 1 then
		l__Combo__5.Value = 2
	end
	local v12 = l__Humanoid__3:LoadAnimation(game.ReplicatedStorage.CombatAnims["Spear" .. l__Combo__5.Value])
	if p3.Name:match("Church") or p3.Name:match("Thorn") then
		v12 = l__Humanoid__3:LoadAnimation(game.ReplicatedStorage.CombatAnims["Church" .. l__Combo__5.Value])
	end
	local v13 = 0.65
	if p3.Name:match("Church") or p3.Name:match("Thorn") then
		v13 = 0.65
	end
	if game.CollectionService:HasTag(p1, "BrokenArm") and l__Combo__5.Value < 6 then
		v13 = 0.5
	end
	if game.CollectionService:HasTag(p1, "Armless") and l__Combo__5.Value < 6 then
		v13 = 0.5
	end
	v12:Play(0.1, 1, v13 * 1.45)
	local l__HumanoidRootPart__9 = p1.HumanoidRootPart
	v12.KeyframeReached:Connect(function(p4)
		if p4 == "slash" then
			if p3:FindFirstChild("TestTrail") then
				if p1:FindFirstChild("SigilBuff") then
					local l__Value__14 = p1:FindFirstChild("SigilBuff").Value
					if l__Value__14 == "Thunder" then
						p3.TestTrail.Color = ColorSequence.new(Color3.new(0.6862745098039216, 0.8666666666666667, 1))
					elseif l__Value__14 == "Flame" then
						p3.TestTrail.Color = ColorSequence.new(Color3.new(1, 0.6901960784313725, 0))
					elseif l__Value__14 == "Ice" then
						p3.TestTrail.Color = ColorSequence.new(Color3.new(0.592156862745098, 0.7568627450980392, 1))
					end
				else
					p3.TestTrail.Color = ColorSequence.new(Color3.new(1, 1, 1))
				end
				p3.TestTrail.Enabled = true
			end
			l__HumanoidRootPart__9.SpearSlash:Play()
		end
		if p4 == "lastframe" and p3:FindFirstChild("TestTrail") then
			p3.TestTrail.Enabled = false
		end
	end)
	u6 = true
	wait(0.375)
	if p1:FindFirstChild("Stun") then
		u2 = true
		return
	end
	u6 = false
	l__Combo__5.Value = l__Combo__5.Value + 1
	if l__Combo__5.Value >= 5 then
		u7 = true
		l__Combo__5.Value = 1
	end
	local v15 = {
		physical = true, 
		spear = true, 
		damage = p3.Stats.Damage.Value, 
		slash = true, 
		poison = u3 or (p1:FindFirstChild("Nature's Calling") and math.random(1,2) == 1) or (p3.Name:match("Thorn") and math.random(1,2) == 1),
		blade = true,
	}
	if u7 then
		v15.knockback = true
	end
	if not p1:FindFirstChild("Stun") and not p1:FindFirstChild("NoDam") then
		u8.magnitudeCheck(p1, l__HumanoidRootPart__9.Position, p3.Stats.Length.Value, v15, true)
	end
	if u7 then
		local v16 = Instance.new("Accessory")
		v16.Name = "Action"
		v16.Parent = p1
		game.Debris:AddItem(v16, 0.75)
		u7 = false
		wait(0.1)
	end
	wait(v4)
	u2 = true
end
local u10 = false
local twom2 = false
local u11 = 1
local VerdienModules = game.ServerStorage.VerdienModules
local VerdienModule = require(VerdienModules.VerdienModule)
local l__PlantGrowth__4 = game.ServerStorage.SpellEffects.PlantGrowth
local u4 = require(l__PlantGrowth__4.GrowthEffect)
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid

function v1.Active2(p5, p6, crazy, p7)
	if p5:FindFirstChild("Grabbing") then
		return
	end
	if ActionCheck() then
		return
	end
	if p5:FindFirstChild("NoAttack") then
		return
	end
	if u10 == true then
		return
	end
	if p5:FindFirstChild("Knocked") then
		return
	end
	if not u2 then
		return
	end
	game.ReplicatedStorage.Requests.StopSprint:FireClient(p6)
	if p7:FindFirstChild("Poison") then
		u3 = true
	end
	local l__Value__17 = p7.Stats.Speed.Value
	local l__Value__18 = p7.Stats.Length.Value
	local l__Value__19 = p7.Stats.Damage.Value
	local l__HumanoidRootPart__20 = p5.HumanoidRootPart
	local l__Humanoid__21 = p5.Humanoid
	local v22 = Instance.new("Accessory")
	u10 = true
	v22.Name = "Action"
	v22.Parent = p5
	local v23 = Instance.new("Accessory")
	v23.Name = "NoJump"
	v23.Parent = p5
	game.Debris:AddItem(v23, 1)
	u2 = false
	if tick() - l__ComboTimer__4.Value > 5 then
		u11 = 1
	end
	local v24 = l__HumanoidRootPart__20.ChargePart:Clone()
	l__ComboTimer__4.Value = tick()
	if not p7.Name:match("Church") then
		if p7.Name:match("Thorn") and twom2 == false then
			p5.Humanoid:LoadAnimation(game.ReplicatedStorage.CombatAnims.Snap2):Play()
			VerdienModule:snapEffect(p5, true);
			twom2 = true
			local v15 = l__PlantGrowth__4.Flower:Clone()
			v15:SetPrimaryPartCFrame(p5.HumanoidRootPart.CFrame * CFrame.new(0, -2.5, 0))
			v15.Parent = workspace.Thrown
			local v16 = 8
			game.Debris:AddItem(v15, v16 + 10)
			local v17 = u4.fadeInStart(v15) + u4.fadeInSuccess(v15)
			local v18 = 8
			v22:Destroy()
			u2 = true
			u4.fadeOut(v15, v18 + v17 + 3, 0)
			wait(v17 + 0.5)
			u10 = false
			v15.Stem.PoisonParticle.Enabled = true
			local v19 = 30
			v15.Stem.PoisonParticle.Rate = v19
			wait(0.1)
			local l__Value__20 = game.ServerStorage.PlayerData[p6.Name].LastName.Value
			local u5 = 0
			spawn(function()
				while true do
					local v21 = 8
					if not (u5 < v21) then
						break
					end
					wait(1)
					u5 += 1			
				end
			end)
			task.spawn(function()
				while v15:IsDescendantOf(game)do
					local v22 = 8
					if not (u5 < v22) then
						break
					end
					task.wait(0.3)
					for v26,v27 in pairs(workspace.Live:GetChildren())do
						local v28: number = 30
						if v15:FindFirstChild'Stem'and (v15.Stem.Position - v27.Torso.Position).Magnitude < v28 then
							local v29 = game.ServerStorage.PlayerData:FindFirstChild(v27.Name) and game.ServerStorage.PlayerData[v27.Name].LastName.Value
							if v27 ~= p5 then
								if game.ServerStorage.PlayerData:FindFirstChild(v27.Name) and (game.ServerStorage.PlayerData:FindFirstChild(v27.Name).LastName.Value ~= game.ServerStorage.PlayerData:FindFirstChild(p5.Name).LastName.Value) or game.ServerStorage.PlayerData:FindFirstChild(p5.Name).LastName.Value == "" then
									if not v27.Boosts:FindFirstChild("FlowerDebuff") then
										local v30 = Instance.new("Accessory")
										v30.Name = "FlowerDebuff"
										v30.Parent = v27.Boosts
										game.CollectionService:AddTag(v30, "FlowerDebuff")
										game.Debris:AddItem(v30, 0.65)
										local v31 = Instance.new("NumberValue")
										v31.Name = "SpeedBoost"
										v31.Value = -7
										local v37 = 30
										if (v15.Stem.Position - v27.Torso.Position).Magnitude < v37 then
											l__TagHumanoid__3:Fire(p5, v27, {
												damage = 0, 
												poison = true
											})
											local l__Toxicity__38 = v27:FindFirstChild("Toxicity")
											if l__Toxicity__38 then
												l__Toxicity__38.Value += 1
											end
										end
										v31.Parent = v27.Boosts
										game.CollectionService:AddTag(v31, "FlowerDebuff")
										game.Debris:AddItem(v31, 0.5)
									end
								end
							end
						end
					end
				end
				task.wait(20)
				twom2 = false
			end)
			return
		end
		local v25 = l__Humanoid__21:LoadAnimation(game.ReplicatedStorage.CombatAnims["SpearHeavy" .. u11])
		if u11 == 1 then
			v24.Parent = p5["Right Arm"]
			v24.Enabled = true
		end
		v25:Play(0.1, 1, 1.25)
		u6 = true
		l__HumanoidRootPart__20.SwordCharge:Play()
		game.Debris:AddItem(v24, 0.5)
		v25.KeyframeReached:Connect(function(p8)
			if p8 == "stop" then
				v25:AdjustSpeed(0)
				if p7:FindFirstChild("TestTrail") then
					p7.TestTrail.Enabled = true
				end
				if p7.Name:match("Pronged") then
					local v26 = game.ServerStorage.Assets.Trident.BubbleAura:Clone()
					v26.Parent = l__HumanoidRootPart__20
					v26.Enabled = false
					v26.Lifetime = NumberRange.new(1.5, 2)
					v26.Speed = NumberRange.new(20, 100)
					v26:Emit(30)
					game.Debris:AddItem(v26, 3)
				end
				sub(function()
					wait(0.1)
					v25:AdjustSpeed(1.25)
				end)
			end
			if p8 == "final" and p7:FindFirstChild("TestTrail") then
				p7.TestTrail.Enabled = false
			end
		end)
		wait(0.35)
		v22:Destroy()
		l__HumanoidRootPart__20.SpearSpin:Play()
		u6 = false
		u11 = u11 + 1
		if u11 >= 1 then
			u11 = 1
		end
		local v27 = Instance.new("Accessory")
		v27.Name = "Action"
		v27.Parent = p5
		game.Debris:AddItem(v27, 0.85)
		wait(0.1)
		if not p5:FindFirstChild("Stun") and not p5:FindFirstChild("NoDam") then
			local v28 = u8.magnitudeCheck(p5, l__HumanoidRootPart__20.Position, 10, {
				physical = true, 
				damage = l__Value__19 + 3, 
				knockback = true, 
				spear = true, 
				blockbreak = true, 
				slash = true, 
				poison = u3 or (p5:FindFirstChild("Nature's Calling") and math.random(1,2) == 1) or (p7.Name:match("Thorn") and math.random(1,2) == 1),
				blade = true,
			})
		end
		wait(0.35)
		l__Combo__5.Value = 1
		u7 = false
		u2 = true
		wait(1.5)
		u10 = false
		if p7:FindFirstChild("TestTrail") then
			p7.TestTrail.Enabled = false
		end
		return
	end
	local v29 = l__Humanoid__21:LoadAnimation(game.ReplicatedStorage.CombatAnims.ChurchHeavy)
	if u11 == 1 then
		v24.Parent = p5["Right Arm"]
		v24.Enabled = true
	end
	local v30 = Instance.new("BodyVelocity")
	game.CollectionService:AddTag(v30, "AllowedBM")
	v30.MaxForce = Vector3.new(1000000, 1000000, 1000000)
	v30.Velocity = p5.HumanoidRootPart.CFrame.lookVector * 100 + Vector3.new(0, 30, 0)
	v30.Parent = p5.HumanoidRootPart
	game.Debris:AddItem(v30, 0.2)
	v29:Play(0.1, 1, 1.25)
	u6 = true
	l__HumanoidRootPart__20.SwordCharge:Play()
	game.Debris:AddItem(v24, 0.5)
	local u12 = false
	local u13 = v29
	v29.KeyframeReached:Connect(function(p9)
		if p9 == "stop" and p7:FindFirstChild("TestTrail") then
			p7.TestTrail.Enabled = true
		end
		if p9 == "wait" then
		end
		if p9 == "hit" then
			u12 = true
			u13:AdjustSpeed(0)
		end
	end)
	p5.Humanoid.AutoRotate = false
	sub(function()
		if p7:FindFirstChild("TestTrail") then
			p7.TestTrail.Enabled = true
		end
	end)
	local v31 = false
	wait(0.3)
	local v32 = 0
	while v31 == false and v32 < 100 do
		wait()
		v32 = v32 + 1
		local v33, v34, v35 = workspace:FindPartOnRayWithIgnoreList(Ray.new(l__HumanoidRootPart__20.CFrame.p, Vector3.new(0, -6, 0)), { workspace.Live, workspace.Terrain })
		if v33 and v30 ~= nil and v31 == false then
			v31 = true
		end	
	end
	if u12 == false then
		u13:Stop()
		u13 = p5.Humanoid:LoadAnimation(game.ReplicatedStorage.CombatAnims.SpearLanding)
		u13:Play()
	else
		u13:AdjustSpeed(1)
	end
	l__HumanoidRootPart__20.Greatspearhit:Play()
	local v36 = game.ReplicatedStorage.Assets.DustPart:Clone()
	v36.Parent = game.Workspace.Thrown
	v36.CFrame = p5.HumanoidRootPart.CFrame * CFrame.new(2, -3, -5)
	v36.DUST:Emit(100)
	game.Debris:AddItem(v36, 1)
	v22:Destroy()
	sub(function()
		if p7:FindFirstChild("TestTrail") then
			p7.TestTrail.Enabled = false
		end
	end)
	u6 = false
	u11 = u11 + 1
	if u11 >= 1 then
		u11 = 1
	end
	local v37 = Instance.new("Accessory")
	v37.Name = "Action"
	v37.Parent = p5
	game.Debris:AddItem(v37, 0.85)
	wait(0.1)
	if not p5:FindFirstChild("Stun") and not p5:FindFirstChild("NoDam") then
		local v38 = u8.magnitudeCheck(p5, l__HumanoidRootPart__20.Position, 15, {
			physical = true, 
			damage = l__Value__19 + 5, 
			knockback = true, 
			spear = true, 
			blockbreak = true, 
			slash = true, 
			poison = u3 or (p5:FindFirstChild("Nature's Calling") and math.random(1,2) == 1) or (p7.Name:match("Thorn") and math.random(1,2) == 1),
			blade = true,
		})
	end
	wait(0.35)
	p5.Humanoid.AutoRotate = true
	l__Combo__5.Value = 1
	u7 = false
	u2 = true
	wait(1.5)
	u10 = false
end
return v1