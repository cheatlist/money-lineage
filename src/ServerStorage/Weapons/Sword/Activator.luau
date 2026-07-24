local v1 = {}
local l__Parent__2 = script.Parent
local function sub(...)
	coroutine.wrap(...)()
end
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid
local l__Parent__1 = l__Parent__2.Parent
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
function v1.Active(p1, p2, p3, p4)
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
	if p4:FindFirstChild("Poison") then
		u3 = true
	end
	local l__HumanoidRootPart__4 = p1:FindFirstChild("HumanoidRootPart")
	if not l__HumanoidRootPart__4 then
		return
	end
	local l__Value__5 = p4.Stats.Length.Value
	local v6 = p4.Stats.Damage.Value
	--game.ReplicatedStorage.Requests.ClientSprint:FireClient(p2)
	local l__Humanoid__7 = p1.Humanoid
	local v8 = 0.175
	if p2.Backpack:FindFirstChild("LordsTraining")then
		v8 = 0.125
	end
	local v9 = v8 - p4.Stats.Speed.Value
	local l__next__10 = next
	local v11, v12 = p1.Boosts:GetChildren()
	while true do
		local v13, v14 = l__next__10(v11, v12)
		if not v13 then
			break
		end
		v12 = v13
		if v14.Name == "AttackSpeedBoost" then
			v9 = v9 / v14.Value
		end	
	end
	local v15 = Instance.new("Accessory")
	v15.Name = "LightAttack"
	v15.Parent = p1
	game:GetService("Debris"):AddItem(v15, 0.45 + v9)
	local v102 = Instance.new("Accessory")
	v102.Name = "ChargeBlock"
	v102.Parent = p1
	game.Debris:AddItem(v102, 0.45 + v9)
	local v16 = Instance.new("Accessory")
	v16.Name = "NoJump"
	v16.Parent = p1
	game:GetService("Debris"):AddItem(v16, 1)
	u2 = false
	if tick() - l__ComboTimer__4.Value > 1.5 then
		l__Combo__5.Value = 1
	end
	l__ComboTimer__4.Value = tick()
	if l__Combo__5.Value >= 6 then
		l__Combo__5.Value = 5
	end
	if l__Combo__5.Value >= 5 and (p2.Backpack:FindFirstChild("LordsTraining") or p2.Backpack:FindFirstChild("WraithTraining")) then
		l__Combo__5.Value = 4
	end
	if p1:FindFirstChild("Grabbing") and l__Combo__5.Value == 3 then
		l__Combo__5.Value = 4
	end
	if p1:FindFirstChild("Grabbing") and l__Combo__5.Value == 1 then
		l__Combo__5.Value = 2
	end
	local v17
	if p2.Backpack:FindFirstChild("WraithTraining") then
		v17 = l__Humanoid__7:LoadAnimation(p3["Wraith" .. l__Combo__5.Value])
	elseif p2.Backpack:FindFirstChild("LordsTraining") then
		v17 = l__Humanoid__7:LoadAnimation(p3["Lord" .. l__Combo__5.Value])
	else
		v17 = l__Humanoid__7:LoadAnimation(p3["Sword" .. l__Combo__5.Value])
	end
	local v18 = 0.65
	if game.CollectionService:HasTag(p1, "BrokenArm") and l__Combo__5.Value < 6 then
		v18 = 0.5
	end
	if game.CollectionService:HasTag(p1, "Armless") and l__Combo__5.Value < 6 then
		v15 = 0.5
	end
	if p1:FindFirstChild("ActionSurgeEff") then
		v6 *= 0.75
		v18 = v18 * 2.5
	end
	local v19 = false
	if p2.Backpack:FindFirstChild("WraithTraining") and l__Combo__5.Value == 3 then
		v18 = 0.5
		v19 = true
	end
	v17:Play(0.1, 1, v18 * 1.45)
	v17.KeyframeReached:Connect(function(p5)
		if p5 == "slash" then
			if p4 and p4:FindFirstChild("TestTrail") then
				if p1:FindFirstChild("SigilBuff") then
					local l__Value__20 = p1:FindFirstChild("SigilBuff").Value
					if l__Value__20 == "Thunder" then
						p4.TestTrail.Color = ColorSequence.new(Color3.new(0.6862745098039216, 0.8666666666666667, 1))
					elseif l__Value__20 == "Flame" then
						p4.TestTrail.Color = ColorSequence.new(Color3.new(1, 0.6901960784313725, 0))
						local playerdata = game.ServerStorage.PlayerData:FindFirstChild(p1.Name)
						if playerdata then
							if playerdata.Ascended.Value == true and playerdata.Race.Value == "Azael" then
								p4.TestTrail.Color = ColorSequence.new(Color3.new(0.333333, 1, 1))
							end
						end
					elseif l__Value__20 == "Ice" then
						p4.TestTrail.Color = ColorSequence.new(Color3.new(0.592156862745098, 0.7568627450980392, 1))
					end
				else
					p4.TestTrail.Color = ColorSequence.new(Color3.new(1, 1, 1))
				end
				p4.TestTrail.Enabled = true
			end
			local v21 = math.random(1, 2)
			if p2.Backpack:FindFirstChild("LordsTraining") or p2.Backpack:FindFirstChild("WraithTraining") then
				l__HumanoidRootPart__4.LordSlash:Play()
			else
				l__HumanoidRootPart__4.SwordSlash:Play()
			end
		end
		if p5 == "lastframe" and p4 and p4:FindFirstChild("TestTrail") then
			p4.TestTrail.Enabled = false
		end
	end)
	u6 = true
	wait(0.1)
	if not p1:FindFirstChild("ActionSurgeEff") then
		wait(0.275)
	end
	if p1:FindFirstChild("Stun") then
		u2 = true
		return
	end
	u6 = false
	l__Combo__5.Value = l__Combo__5.Value + 1
	if l__Combo__5.Value >= 6 or l__Combo__5.Value >= 5 and (p2.Backpack:FindFirstChild("LordsTraining") or p2.Backpack:FindFirstChild("WraithTraining")) then
		u7 = true
		l__Combo__5.Value = 1
	end
	local v22 = {
		physical = true,
		damage = v6,
		blockbreak = v19,
		noparry = v19,
		sword = true,
		slash = true,
		poison = u3 or (p1:FindFirstChild("Nature's Calling") and math.random(1,2) == 1),
		currentprop = p4,
		blade = true,
	}
	if p1:FindFirstChild("SigilBuff") then
		local l__Value__23 = p1:FindFirstChild("SigilBuff").Value
		if l__Value__23 == "Thunder" then
			v22.sigilthunder = true
		elseif l__Value__23 == "Flame" then
			v22.sigilflame = true
		elseif l__Value__23 == "Ice" then
			v22.sigilice = true
		elseif l__Value__23 == "White Fire" then
			v22.sigilwhitefire = true
		end
	end
	if not p1:FindFirstChild("Stun") and not p1:FindFirstChild("NoDam") then
		if u7 then
			if p2.Backpack:FindFirstChild("WraithTraining") or not p2.Backpack:FindFirstChild("LordsTraining") then
				v22.knockback = true
				u8.magnitudeCheck(p1, l__HumanoidRootPart__4.Position, l__Value__5, v22, true)
			else
				for v24 = 1, 3 do
					if v24 == 3 then
						v22.knockback = true
					end
					if not p1:FindFirstChild("Stun") and not p1:FindFirstChild("NoDam") then
						u8.magnitudeCheck(p1, l__HumanoidRootPart__4.Position, l__Value__5, v22, true)
					end
					wait(0.25)
				end
			end
		else
			u8.magnitudeCheck(p1, l__HumanoidRootPart__4.Position, l__Value__5, v22, true)
		end
	end
	if u7 then
		local v25 = Instance.new("Accessory")
		v25.Name = "Action"
		v25.Parent = p1
		game:GetService("Debris"):AddItem(v25, 0.75)
		u7 = false
		wait(0.1)
	end
	if p1:FindFirstChild("ActionSurgeEff") then
		if v15.Parent then
			v15:Destroy()
		end
	else
		wait(v9)
	end
	if v19 then
		wait(0.2)
	end
	u2 = true
end
local u9 = false
local u10 = 1
local twom2 = true
local R3 = require(game.ServerScriptService.RotatedRegion3)
function v1.Active2(p6, p7, p8, p9)
	if p6:FindFirstChild("Grabbing") then
		return
	end
	if ActionCheck() then
		return
	end
	if p6:FindFirstChild("NoAttack") then
		return
	end
	if u9 == true then
		return
	end
	if p6:FindFirstChild("Knocked") then
		return
	end
	if not u2 then
		return
	end
	--game.ReplicatedStorage.Requests.ClientSprint:FireClient(p7)
	if p9:FindFirstChild("Poison") then
		u3 = true
	end
	local playerdata = game.ServerStorage.PlayerData:FindFirstChild(p6.Name)
	local cursedswordsman = false
	if playerdata.Skills.Value:find("TheCursedSwordsman") then
		cursedswordsman = true
	end
	local l__Value__26 = p9.Stats.Speed.Value
	local l__Value__27 = p9.Stats.Length.Value
	local v28 = p9.Stats.Damage.Value
	local l__HumanoidRootPart__29 = p6.HumanoidRootPart
	local l__Humanoid__30 = p6.Humanoid
	local v31 = Instance.new("Accessory")
	u9 = true
	v31.Name = "HeavyAttack"
	v31.Parent = p6
	game:GetService("Debris"):AddItem(v31, 1.2)
	local v32 = Instance.new("Accessory")
	v32.Name = "NoJump"
	v32.Parent = p6
	game:GetService("Debris"):AddItem(v32, 1)
	u2 = false
	if tick() - l__ComboTimer__4.Value > 5 then
		l__Combo__5.Value = 1
	end
	l__ComboTimer__4.Value = tick()
	local v33 = l__HumanoidRootPart__29.AkumaEmit:Clone()
	if p9.Name:match("Illusory") and twom2 == true then
		twom2 = false
		local v14 = game.ServerStorage.SpellEffects.sigilfire.atta:FindFirstChild("Attachment3"):Clone()
		v14.Name = "SigilPtcl"
		v14.Parent = p9
		v14.CFrame = CFrame.new(0, -1.5, 0, -4.37113883e-08, -1, 0, 1, -4.37113883e-08, 0, 0, 0, 1)
		v14.Orientation = Vector3.new(-0,0,90)
		local v15 = p9:FindFirstChild("FireLoop")
		v15:Play()
		local v16 = p9:FindFirstChild("Light")
		v16.Enabled = true
		local v41 = l__Humanoid__30:LoadAnimation(p9:FindFirstChild("flameA"))
		v41:Play()
		v41:AdjustSpeed(1.5)
		l__HumanoidRootPart__29.SworderEmit:Emit(30)
		l__HumanoidRootPart__29.SwordCharge:Play()
		v41.KeyframeReached:connect(function(p15)
			if p15 == "hitstart" then
				p9.Arrow:Play()
				l__HumanoidRootPart__29.LordSlash:Play()
				local v42 = game.ServerStorage.SpellEffects.sigilfire.illusorycrescent:Clone()
				game.Debris:AddItem(v42, 1.25)
				v42.Parent = game.Workspace.Thrown
				v42.FireSlash:Play()
				v42.CFrame = l__HumanoidRootPart__29.CFrame * CFrame.new(-1, 0, -5) * CFrame.Angles(math.rad(180), 0, math.rad(90))
				v42.BodyVelocity.Velocity = l__HumanoidRootPart__29.CFrame.LookVector * 80
				v42:SetNetworkOwner(nil)
				local u15 = {}
				local touched = false
				v42.Hitbox.Touched:connect(function(p16)
					if p16 ~= v42 then
						if touched ~= true then
							local v43 = p16.Parent:FindFirstChild("Humanoid") or p16.Parent.Parent:FindFirstChild("Humanoid")
							if v43 and v43 ~= l__Humanoid__30 and not u15[v43.Parent] then
								u15[v43.Parent] = true
								local Hitbox = R3.Block(v42.CFrame, Vector3.new(20,20,20))
								Hitbox:GetHumanoids({p6}, function(humanoid)
									l__TagHumanoid__3:Fire(p6, humanoid.Parent, {
										mana = true, 
										monkbreaker = true,
										damage = 25,
										manaknockupself = true, 
										downbypass = true,
										canspellcounter = true,
										illusorybeam = true
									})
								end)
								touched = true
								task.spawn(function()
									v42:Destroy()
								end)
							end
						end
					end
				end)
			end
		end)
		task.wait(1)
		v15:Stop()
		v14:Destroy()
		u2 = true
		u9 = false
		task.spawn(function()
			task.wait(20)
			twom2 = true
		end)
		return
	end
	if p7.Backpack:FindFirstChild("WraithTraining") then
		local v34 = l__Humanoid__30:LoadAnimation(p8.WraithHeavy)
		if u10 == 1 then
			v33.Parent = p6["Right Leg"]
			v33.Enabled = true
		end
		v34:Play(0.1, 1, 1.25)
		u6 = true
		l__HumanoidRootPart__29.EpicDemon:Play()
		game:GetService("Debris"):AddItem(v33, 0.5)
		task.wait(0.1)
		if not cursedswordsman then
			wait(0.1)
		end
		v34:AdjustSpeed(0)
		local multi = 1
		task.wait(0.05)
		if not cursedswordsman then
			multi = 0.5
			wait(0.05)
		end
		v34:AdjustSpeed(multi)
		sub(function()
			if not cursedswordsman then
				wait(0.275)
			end
			wait(0.275)
			v34:Stop()
		end)
		l__HumanoidRootPart__29.Shoryu1:Play()
		u6 = false
		u10 = u10 + 1
		if u10 >= 1 then
			u10 = 1
		end
		local v35 = Instance.new("Accessory")
		v35.Name = "Action"
		v35.Parent = p6
		local duration = 0.85
		if cursedswordsman then
			duration /= 2
		end
		game:GetService("Debris"):AddItem(v35, duration)
		local v36 = {
			fist = true,
			physical = true, 
			damage = v28,
			knockback = true, 
			blockbreak = true, 
			currentprop = p9,
			blade = true,
			poison = (p6:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
		}
		if cursedswordsman then
			v36.noparry = true
		end
		if p6:FindFirstChild("SigilBuff") then
			local l__Value__37 = p6:FindFirstChild("SigilBuff").Value
			if l__Value__37 == "Thunder" then
				v36.sigilthunder = true
			elseif l__Value__37 == "Flame" then
				v36.sigilflame = true
			elseif l__Value__37 == "Ice" then
				v36.sigilice = true
			elseif l__Value__37 == "White Fire" then
				v36.sigilwhitefire = true
			end
		end
		if not p6:FindFirstChild("Stun") and not p6:FindFirstChild("NoDam") then
			local v38 = u8.magnitudeCheck(p6, l__HumanoidRootPart__29.Position, 10, v36, true)
		end
		wait(0.175)
		if not cursedswordsman then
			wait(0.175)
		end
		l__Combo__5.Value = 1
		u7 = false
		u2 = true
		wait(1.5)
		u9 = false
		return
	end
	local v39 = l__Humanoid__30:LoadAnimation(p8["SwordHeavyAnim" .. u10])
	if u10 == 1 then
		v33.Parent = p6["Right Arm"]
		v33.Enabled = true
	end
	v39:Play(0.1, 1, 1.25)
	u6 = true
	l__HumanoidRootPart__29.SwordCharge:Play()
	game:GetService("Debris"):AddItem(v33, 0.5)
	wait(0.125)
	v39:AdjustSpeed(0)
	p6.Humanoid.AutoRotate = false
	sub(function()
		wait(2.25)
		p6.Humanoid.AutoRotate = true
	end)
	wait(0.35)
	sub(function()
		wait(0.35)
		v39:Stop()
	end)
	if p9:FindFirstChild("TestTrail") then
		p9.TestTrail.Enabled = true
	end
	l__HumanoidRootPart__29.HeavySlash:Play()
	local v40 = Instance.new("BodyVelocity")
	game.CollectionService:AddTag(v40, "AllowedBM")
	if not p6:FindFirstChild("Stun") then
		v40.MaxForce = Vector3.new(1000000, 1000000, 1000000)
		v40.Velocity = p6.HumanoidRootPart.CFrame.lookVector * 100
		v40.Parent = p6.HumanoidRootPart
		game.Debris:AddItem(v40, 0.2)
	end
	v39.KeyframeReached:Connect(function(p10)
		if p10 == "final" and p9:FindFirstChild("TestTrail") then
			p9.TestTrail.Enabled = false
		end
	end)
	if u10 == 2 then
		v39:AdjustSpeed(1)
	else
		v39:AdjustSpeed(1.5)
	end
	u6 = false
	u10 = u10 + 1
	if u10 >= 1 then
		u10 = 1
	end
	sub(function()
		wait(0.5)
		p6.Humanoid.AutoRotate = true
		wait(0.5)
		if p9:FindFirstChild("TestTrail") then
			p9.TestTrail.Enabled = false
		end
	end)
	local v41 = Instance.new("Accessory")
	v41.Name = "Action"
	v41.Parent = p6
	game:GetService("Debris"):AddItem(v41, 0.85)
	local v42 = false
	for v43 = 1, 3 do
		wait(0.1)
		if p6:FindFirstChild("Stun") then
			game:GetService("Debris"):AddItem(v40, 0.001)
			break
		end
		if p6:FindFirstChild("COUNTERED") then
			game:GetService("Debris"):AddItem(v40, 0.001)
			break
		end
		if p6:FindFirstChild("NoDam") then
			game:GetService("Debris"):AddItem(v40, 0.001)
			break
		end
		local v44 = {
			physical = true, 
			damage = v28 + 3, 
			knockback = true, 
			blockbreak = true, 
			sword = true, 
			slash = true, 
			poison = u3 or (p6:FindFirstChild("Nature's Calling") and math.random(1,2) == 1), 
			currentprop = p9,
			blade = true,
		}
		if p6:FindFirstChild("SigilBuff") then
			local l__Value__45 = p6:FindFirstChild("SigilBuff").Value
			if l__Value__45 == "Thunder" then
				v44.sigilthunder = true
			elseif l__Value__45 == "Flame" then
				v44.sigilflame = true
			elseif l__Value__45 == "Ice" then
				v44.sigilice = true
			elseif l__Value__45 == "White Fire" then
				v44.sigilwhitefire = true
			end
		end
		if not p6:FindFirstChild("Stun") and not p6:FindFirstChild("NoDam") then
			v42 = u8.magnitudeCheck(p6, l__HumanoidRootPart__29.Position, l__Value__27, v44, true)
		end
		if v42 then
			game:GetService("Debris"):AddItem(v40, 0.001)
			break
		end
	end
	wait(0.35)
	l__Combo__5.Value = 1
	u7 = false
	u2 = true
	wait(1.5)
	if p9:FindFirstChild("TestTrail") then
		p9.TestTrail.Enabled = false
	end
	u9 = false
end
return v1