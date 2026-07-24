local v1 = {}
local l__Parent__2 = script.Parent
function ActionCheck(p1)
	if p1:FindFirstChild("Stun")then
		return true
	end
	if p1:FindFirstChild("NoDam")then
		return true
	end
	if p1:FindFirstChild("Action")then
		return true
	end
	if p1:FindFirstChild("Knocked")then
		return true
	end
	if p1:FindFirstChild("Unconscious")then
		return true
	end
	if p1:FindFirstChild("SpellBlocking")then
		return true
	end
	if p1:FindFirstChild("Blocking")then
		return true
	end
	if p1:FindFirstChild("Immortal") then
	else
		return
	end
	return true
end
local taghumanoid = game.ServerStorage.Requests.TagHumanoid
local u1 = false
function v1.Active(p1, p2, p3, p4)
	if u1 == true then
		return
	end
	if ActionCheck(p1) then
		return
	end
	local v3 = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	if v3.Lives.Value <= 0 then return end
	local v4 = 5
	local runemaster = false
	if v3.Skills.Value:find("TheRunemaster") then
		v4 = 3
		runemaster = true
	end
	local v5 = nil
	for v6, v7 in pairs(game.Workspace.Live:GetChildren()) do
		if v7 ~= p1 and (v7.HumanoidRootPart.Position - p1.HumanoidRootPart.Position).magnitude <= 12 and v7:FindFirstChild("Humanoid") and v7.Humanoid.Health > 0 and (v7:FindFirstChild("Unconscious") and not v7:FindFirstChild("MonsterInfo"))then
			v5 = v7
			break
		end
	end
	if v5 then
		u1 = true
		local l__Humanoid__8 = v5:FindFirstChild("Humanoid")
		local v9 = game.Players:GetPlayerFromCharacter(v5)
		if v9 then
			local danger = Instance.new("Accessory")
			danger.Name = "Danger"
			danger.Parent = v9
			game:GetService("Debris"):AddItem(danger, v4+1)
		end
		local v10 = p1.Humanoid:LoadAnimation(script.SoulRip)
		v10:Play()
		local v11 = game.ServerStorage.Assets.HandHoldSoul:Clone()
		v11.Weld.Part0 = p1["Right Arm"]
		v11.Weld.Part1 = v11
		v11.Parent = p1
		game:GetService("Debris"):AddItem(v11, v4+0.5)
		local v12 = Instance.new("Accessory")
		v12.Name = "Action"
		v12.Parent = p1
		game:GetService("Debris"):AddItem(v12, v4)
		local v13 = Instance.new("ObjectValue")
		v13.Name = "Executing"
		v13.Parent = p1
		v13.Value = v5
		game:GetService("Debris"):AddItem(v13, v4)
		local u3 = false
		spawn(function()
			task.wait(0.2)
			v10:AdjustSpeed(0)
			task.wait(v4 - 1.2)
			if u3 then
				v10:AdjustSpeed(1)
				return
			end
			v10:Stop()
		end)
		local v14 = 1
		while v14 < v4 and l__Humanoid__8.Health > 0 and not p1:FindFirstChild("Stun") and not p1:FindFirstChild("Unconscious") and not p1:FindFirstChild("Knocked") do
			v14 = v14 + task.wait(0.2)
			if p1:FindFirstChild("Stun") then
				break
			end
			if p1:FindFirstChild("Knocked") then
				break
			end
			if v5:FindFirstChild("Grabbed") then
				break
			end		
		end
		if v11.Parent then
			v11:Destroy()
		end
		if v12.Parent then
			v12:Destroy()
		end
		if v13.Parent then
			v13:Destroy()
		end
		if v4 <= v14 then
			if l__Humanoid__8.Health>0 then
				u3 = true

				if p2 and p2.Backpack:FindFirstChild("NoKill")then
					if v9 then
						for _,v in pairs(v9:GetChildren())do
							if v.Name == "Danger"then
								v:Destroy()
							end
						end
						task.wait()
					end
				end
				--[[task.spawn(function()
					if game.ServerStorage.PlayerData[l__Humanoid__8.Parent.Name].Class.Value ~= "" then
						game.ServerStorage.RankData[p2.Name].Grips.Value += 1
						game.ServerScriptService.WorldHandler.RankHandler.UpdateGrips:Fire(p2)
					end
				end)]]--
				p1.HumanoidRootPart.SoulRip:Play()
				if runemaster then
					local ShinobiResurrection = game.ReplicatedStorage.Assets.SoulRipEffect:Clone()
					ShinobiResurrection.Parent = workspace.Thrown
					ShinobiResurrection.CFrame = p1.HumanoidRootPart.CFrame
					
					for _,live in pairs(workspace.Live:GetChildren()) do
						if live:FindFirstChild("Torso") and live:FindFirstChild("HumanoidRootPart") and live ~= p1 then
							if (live.HumanoidRootPart.Position - p1.HumanoidRootPart.Position).Magnitude <= 15 then
								taghumanoid:Fire(p1, live, {
									damage = 15;
									physical = true;
									strongknockback = true,
									move = "Soul Rip"
								})
							end
						end
					end
					
					task.spawn(function()
						game:GetService("TweenService"):Create(ShinobiResurrection, TweenInfo.new(0.35), {
							Transparency = 0;
							CFrame = p1.HumanoidRootPart.CFrame;
						}):Play()

						game:GetService("TweenService"):Create(ShinobiResurrection, TweenInfo.new(0.35), {
							Transparency = 0;
							Size = Vector3.new(15, 15, 15);
						}):Play()

						task.wait(0.35)

						game:GetService("TweenService"):Create(ShinobiResurrection, TweenInfo.new(0.35), {
							Transparency = 1;
							Size = Vector3.new(0,0,0);
						}):Play()

						task.wait(0.35)

						ShinobiResurrection:Destroy()
					end)
				end
				--l__Humanoid__8:TakeDamage(100000000000)
				--l__Humanoid__8.Health = 0
				_G.Death(v5 ,p1, true)
				if not runemaster then
					v3.Runes.Value = v3.Runes.Value + 4 < 16 and v3.Runes.Value + 4 or 16
				else
					v3.Runes.Value = v3.Runes.Value + 8 < 16 and v3.Runes.Value + 8 or 16
				end
				v3.Alignment.Value -= 8
				v3.SoulRipsAchieved.Value += 1
				require(game.ServerScriptService.Modules.Commands).ChangeInsight(p2, v3, 1)
			end
		end
		wait(3)
		u1 = false
	end
end
local u4 = false
function v1.Active2(p5, p6, p7, p8)
	local zzzzzzzzzz = script.Parent.Parent
	if u4 then
		return
	end
	if ActionCheck(p5) then
		return
	end
	u4 = true
	local l__Humanoid__17 = p5:FindFirstChild("Humanoid")
	local l__HumanoidRootPart__18 = p5:FindFirstChild("HumanoidRootPart")
	local l__Boosts__19 = p5.Boosts
	local l__Data__20 = game.ServerStorage.PlayerData:FindFirstChild(p6.Name)
	if l__Data__20.Runes.Value > 0 and not p5:FindFirstChild("FullMana") then
		if l__Data__20.Lives.Value <= 0 then
			return
		end
		l__Data__20.Runes.Value = l__Data__20.Runes.Value - 1
		l__Humanoid__17:LoadAnimation(p7.SCREAM):Play()
		l__HumanoidRootPart__18.AbyssalScream:Play()
		l__Humanoid__17:LoadAnimation(p7.CrazedIdle):Play()
		local part = Instance.new("Part", p5)
		part.Name = "RuneChargeEffect"
		part.Size = Vector3.new(1,1,1)
		part.Material = Enum.Material.Neon
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 0
		part.CFrame = l__HumanoidRootPart__18.CFrame
		local goal = {}
		goal.Size = Vector3.new(0,0,0)
		goal.Transparency = 1
		goal.CFrame = l__HumanoidRootPart__18.CFrame + l__HumanoidRootPart__18.CFrame.rightVector*math.random(5, 10)
		local tween = game:GetService("TweenService"):Create(part, TweenInfo.new(0.7), goal)
		tween:Play()
		game.Debris:AddItem(part, 1)
		local v21 = l__Data__20.Class.Value == "DarkSigilKnight"
		local v22 = p6.Backpack:FindFirstChild("MasteredRune")
		local v23 = l__Data__20.Race.Value == "Dinakeri"
		local v24 = v21 or v23
		local v25 = Instance.new("Accessory")
		v25.Name = "RuneBoy"
		v25.Parent = p5
		game:GetService("Debris"):AddItem(v25, 30)
		if v21 then
			local v26 = Instance.new("Accessory")
			v26.Name = "TightGrip"
			v26.Parent = p5
			game:GetService("Debris"):AddItem(v26, 30)
		end
		local v27 = Instance.new("Accessory")
		v27.Name = "FullMana"
		v27.Parent = p5
		game:GetService("Debris"):AddItem(v27, 30)
		local v28 = Instance.new("NumberValue")
		v28.Name = "MeleeDamageMultiplier"
		local v29
		if v22 then
			v29 = 1.25
		else
			v29 = 1.15
		end
		v28.Value = v29
		v28.Parent = l__Boosts__19
		game:GetService("Debris"):AddItem(v28,30)
		if v22 or not v23 then
			if v23 then
				local v30 = Instance.new("NumberValue")
				v30.Name = "DamageDivisor"
				v30.Value = 0.85
				v30.Parent = l__Boosts__19
				game:GetService("Debris"):AddItem(v30, 30)
			else
				local v31 = Instance.new("NumberValue")
				v31.Name = "DamageDivisor"
				v31.Value = 1.15
				v31.Parent = l__Boosts__19
				game:GetService("Debris"):AddItem(v31, 30)
			end
		elseif v24 and not v22 then
			local v32 = Instance.new("NumberValue")
			v32.Name = "DamageDivisor"
			v32.Value = 1.1
			v32.Parent = l__Boosts__19
			game:GetService("Debris"):AddItem(v32, 30)
		end
		if v22 or not v23 then
			if v23 then
				local v33 = Instance.new("NumberValue")
				v33.Name = "SpeedBoost"
				v33.Value = 4
				v33.Parent = l__Boosts__19
				game:GetService("Debris"):AddItem(v33, 30)
			else
				local v34 = Instance.new("NumberValue")
				v34.Name = "SpeedBoost"
				v34.Value = 3
				v34.Parent = l__Boosts__19
				game:GetService("Debris"):AddItem(v34, 30)
			end
		elseif v24 then
			local v35 = Instance.new("NumberValue")
			v35.Name = "SpeedBoost"
			v35.Value = 2
			v35.Parent = l__Boosts__19
			game:GetService("Debris"):AddItem(v35, 30)
		end
		if v22 or not v23 then
			local v36 = Instance.new("NumberValue")
			v36.Name = "AttackSpeedBoost"
			v36.Value = 1.4
			v36.Parent = l__Boosts__19
			game:GetService("Debris"):AddItem(v36, 30)
		elseif v24 then
			local v37 = Instance.new("NumberValue")
			v37.Name = "AttackSpeedBoost"
			v37.Value = 1.1
			v37.Parent = l__Boosts__19
			game:GetService("Debris"):AddItem(v37, 30)
		end
		if l__Data__20.Skills.Value:find("TheRunemaster") then
			local guaranteedcast = Instance.new("BoolValue")
			guaranteedcast.Name = "GuaranteedCast"
			guaranteedcast.Parent = l__Boosts__19
			game:GetService("Debris"):AddItem(guaranteedcast, 30)
		end
		wait(30)
		if v23 then
			local v2 = Instance.new("Accessory")
			v2.Name = "HalfSoul"
			v2.Parent = zzzzzzzzzz
			game.Debris:AddItem(v2,15)
		end
		wait(15)
	end
	u4 = false
end
return v1