function sub(...)
	coroutine.wrap(...)()
end
local l__TweenService__1 = game:GetService("TweenService")
local v2 = {
	nofx = true, 
	upperbound = 0, 
	lowerbound = 0, 
	signs = 0, 
	cost = 1
}
local l__Heal__1 = game.ServerStorage.SpellEffects.Heal
local l__Parent__2 = script.Parent
function v2.Activate(p1, p2, p3, p4)
	if game.CollectionService:HasTag(p2,"Casting")or p2:FindFirstChild("ActiveCast")then
		return
	end
	local l__Mana__3 = p2.Mana
	local v4 = game.Players:GetPlayerFromCharacter(p2)
	local l__Value__5 = game.ServerStorage.PlayerData[v4.Name].ManaColor.Value
	if p2:FindFirstChild("EndCast") then
		return
	end
	local l__Humanoid__6 = p2:FindFirstChild("Humanoid")
	if not l__Humanoid__6 then
		return
	end
	local v7 = false
	if v4.Backpack:FindFirstChild("MederiUpgrade")then
		v7 = true
	end
	game.ReplicatedStorage.Requests.StopSprint:FireClient(v4)
	local v8 = Instance.new("Accessory")
	v8.Name = "ActiveCast"
	v8.Parent = p2
	local v9 = Instance.new("IntValue")
	v9.Name = "SpeedBoost"
	local v10
	if v7 then
		v10 = -10
	else
		v10 = -14
	end
	v9.Value = v10
	v9.Parent = p2.Boosts
	p2.HumanoidRootPart.PerfectCast:Play()
	local v11 = l__Heal__1.HealSpell:Clone()
	v11.Parent = game.Workspace.Thrown
	local v12 = l__Humanoid__6:LoadAnimation(script.LeftPoint)
	v12:Play()
	v11.Hit:Play()
	local u3 = Instance.new("Weld")
	local u4 = p2["Left Arm"]
	sub(function()
		u3.Name = "Weld"
		u3.Part0 = u4
		u3.Part1 = v11
		u3.Parent = v11
		u3.C1 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180))
	end)
	local l__HumanoidRootPart__13 = p2.HumanoidRootPart
	v11.Healing:Play()
	local v14 = p2:FindFirstChild("EndCast") or (p2:FindFirstChild("Stun") or (p2:FindFirstChild("Knocked") or p2:FindFirstChild("Unconscious")))
	local v15 = {}
	while p2.Mana.Value > 0 and not v14 and p2.Parent do
		wait(0.1)
		local l__Position__16 = v11.Position
		local v17 = {}
		local v18 = 0
		for v19, v20 in pairs(workspace.Live:children()) do
			if v20 ~= p2 and v20:IsA("Model") then
				local v21 = v20 and v20:FindFirstChild("Humanoid")
				local v22 = v21 and v21.RootPart
				if v22 and v21.Health > 0 and (v22.Position - l__Position__16).magnitude < 8 then
					v17[v20] = v21
					v18 = v18 + 1
				end
			end
		end
		local v23 = 1 / v18
		if v7 then
			v23 = 0.25 + 0.75 * v23
		end
		for v26,v27 in pairs(v17)do
			if not v15[v26]then
				v15[v26] = 0
			end
			v15[v26] = (v15[v26]) + 1
			if v27.Health < v27.MaxHealth and v27.Health > 0 then
				v27.Health = v27.Health + (0.5 + 0.5 * (v27.MaxHealth / 100)) * v23
			end
			if v7 then
				if v26:FindFirstChild("Unconscious")then
					if v15[v26] > 15 then
						for _,v in pairs(v26:GetChildren())do
							if v.Name == "Knocked"or v.Name == "Unconscious"then
								v:Destroy()
							end
						end
					end
				elseif v26:FindFirstChild("Knocked")then
					for _,v in pairs(v26:GetChildren())do
						if v.Name == "Knocked"or v.Name == "Unconscious"then
							v:Destroy()
						end
					end
				end
			end		
		end
		if v18 > 0 and v7 then
			l__Humanoid__6.Health = l__Humanoid__6.Health + (0.5 + 0.5 * (l__Humanoid__6.MaxHealth / 100))
		end
		local v28 = p2:FindFirstChild("EndCast")
		if not v28 then
			v28 = p2:FindFirstChild("Stun")
			if not v28 then
				v28 = p2:FindFirstChild("Knocked")
				if not v28 then
					v28 = p2:FindFirstChild("Unconscious") or l__Parent__2.Parent ~= p2
				end
			end
		end
		v14 = v28	
	end
	sub(function()
		v8:Destroy()
		v9:Destroy()
		v11.ParticleEmitter.Enabled = false
		v12:Stop()
		v11.PointLight.Enabled = false
		game.TweenService:Create(v11.Healing, TweenInfo.new(0.5), {
			Volume = 0
		}):Play()
		wait(1.5)
		u3:Destroy()
		v11:Destroy()
	end)
end
function v2.Deactivate(p5, p6, p7)
	local v29 = Instance.new("Accessory")
	v29.Name = "EndCast"
	v29.Parent = p6
	game.Debris:AddItem(v29, 2)
end
return v2