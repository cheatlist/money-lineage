local v1 = {}
local v2 = require(game.ServerScriptService.Modules.HitDetection)
v1.upperbound = 90
v1.lowerbound = 70
v1.signs = 7
v1.cost = 100
local l__PlantGrowth__4 = game.ServerStorage.SpellEffects.PlantGrowth
local function u1(p1, p2, p3, p4)
	local v5, v6, v7 = workspace:FindPartOnRayWithIgnoreList(Ray.new(p1, CFrame.new(p1, p2).LookVector * p3), p4)
	return v5, v6, v7
end
local u2 = require(l__PlantGrowth__4.GrowthEffect)
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid
local canuse = true
function v1.Activate(p5, p6, p7, p8)
	if game.CollectionService:HasTag(p6, "Casting") then
		return
	end
	if not canuse then
		return
	end
	local l__Mana__8 = p6.Mana
	local v9 = game.Players:GetPlayerFromCharacter(p6)
	local l__Value__10 = game.ServerStorage.PlayerData[v9.Name].ManaColor.Value
	local u4 = _G.MouseData(v9)
	if not u4 then
		return
	end
	task.spawn(function()
		if p7 == 0 then
			l__Mana__8.Value = math.max(l__Mana__8.Value - v1.cost, 0)
			if (u4.Hit.p - p6.Torso.Position).Magnitude >= 250 then
				return
			end
			local v11, v12, v13 = u1(u4.Hit.p + Vector3.new(0, 0.5, 0), u4.Hit.p, 3, { workspace.Live, workspace.Thrown, workspace.Destructibles })
			if not v11 then
				return
			end
			local v14 = false
			if u4.Target and u4.Target.Material == Enum.Material.Grass then
				v14 = true
			end
			canuse = false
			local v15 = l__PlantGrowth__4.Flower:Clone()
			v15:SetPrimaryPartCFrame(CFrame.new(v12) + Vector3.new(0, 0.75, 0))
			v15.Parent = workspace.Thrown
			local v16
			if v14 then
				v16 = 20
			else
				v16 = 15
			end
			game.Debris:AddItem(v15, v16 + 10)
			local v17 = u2.fadeInStart(v15) + u2.fadeInSuccess(v15)
			local v18
			if v14 then
				v18 = 20
			else
				v18 = 15
			end
			u2.fadeOut(v15, v18 + v17 - 5, 0)
			wait(v17 + 0.5)
			v15.Stem.PoisonParticle.Enabled = true
			local v19
			if v14 then
				v19 = 75
			else
				v19 = 50
			end
			v15.Stem.PoisonParticle.Rate = v19
			wait(0.1)
			local l__Value__20 = game.ServerStorage.PlayerData[p6.Name].LastName.Value
			local u5 = 0
			spawn(function()
				while true do
					local v21
					if v14 then
						v21 = 20
					else
						v21 = 15
					end
					if not (u5 < v21) then
						break
					end
					wait(1)
					u5 += 1			
				end
			end)
			while v15:IsDescendantOf(game)do
				local v22
				if v14 then
					v22 = 20
				else
					v22 = 15
				end
				if not (u5 < v22) then
					break
				end
				for v26,v27 in pairs(workspace.Live:GetChildren())do
					local v28: number
					if v14 then
						v28 = 60
					else
						v28 = 50
					end
					if v15:FindFirstChild'Stem'and (v15.Stem.Position - v27.Torso.Position).Magnitude < v28 then
						local v29 = game.ServerStorage.PlayerData:FindFirstChild(v27.Name) and game.ServerStorage.PlayerData[v27.Name].LastName.Value
						if (not v29 or (l__Value__20 == "" or v29 ~= l__Value__20) and v27 ~= p6) and not v27.Boosts:FindFirstChild("FlowerDebuff") then
							local v30 = Instance.new("Accessory")
							v30.Name = "FlowerDebuff"
							v30.Parent = v27.Boosts
							game.CollectionService:AddTag(v30, "FlowerDebuff")
							game.Debris:AddItem(v30, 0.5)
							local v31 = Instance.new("NumberValue")
							v31.Name = "SpeedBoost"
							local v32
							if v14 then
								v32 = 16
							else
								v32 = -14
							end
							local v33
							if v14 then
								v33 = 60
							else
								v33 = 50
							end
							local v34
							if v14 then
								v34 = 60
							else
								v34 = 50
							end
							v31.Value = v32 * (v33 - (v15.Stem.Position - v27.Torso.Position).Magnitude) / v34
							local v35
							if v14 then
								v35 = 20
							else
								v35 = 15
							end
							if v35 - u5 <= 5 then
								local v36
								if v14 then
									v36 = 20
								else
									v36 = 15
								end
								v31.Value = v31.Value * ((v36 - u5) / 5)
							else
								local v37
								if v14 then
									v37 = 40
								else
									v37 = 30
								end
								if (v15.Stem.Position - v27.Torso.Position).Magnitude < v37 then
									l__TagHumanoid__3:Fire(v9.Character, v27, {
										damage = 0, 
										poison = true,
										move = "Perflora"
									})
									local l__Toxicity__38 = v27:FindFirstChild("Toxicity")
									if l__Toxicity__38 then
										l__Toxicity__38.Value += 1
									end
								end
							end
							v31.Parent = v27.Boosts
							game.CollectionService:AddTag(v31, "FlowerDebuff")
							game.Debris:AddItem(v31, 0.5)
						end
					end
				end
				wait(15)
				canuse = true
			end
		else
			l__TagHumanoid__3:Fire(v9.Character, v9.Character, {
				damage = 15, 
				poison = true,
				move = "Perflora"
			})
		end
	end)
end
local u6 = {
	upperbound = 50, 
	lowerbound = 30, 
	signs = 0, 
	cost = 100
}

local l__TweenService__7 = game:GetService("TweenService")
local u8 = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
function u6.Activate(p9, p10, p11, p12, p13)
	if game.CollectionService:HasTag(p10, "Casting") then
		return
	end
	local l__Mana__39 = p10.Mana
	local v40 = game.Players:GetPlayerFromCharacter(p10)
	local v41 = v40 and game.ServerStorage.PlayerData:FindFirstChild(v40.Name)
	if v41 then
		local l__Value__42 = v41.ManaColor.Value
	end
	if not v40.Backpack:FindFirstChild("Nature Mastery") then
		return
	end
	local u9 = _G.MouseData(v40)
	if not u9 then
		return
	end
	task.spawn(function()
		if p11 == 0 then
			l__Mana__39.Value = math.max(l__Mana__39.Value - u6.cost, 0)
			u2.snapEffect(p10, p12)
			local v43 = 3
			local v44 = {}
			for v45 = -v43, v43 do
				local v46 = l__PlantGrowth__4.FlowerProjectile:Clone()
				table.insert(v44, v46)
				v46.CFrame = p10.HumanoidRootPart.CFrame * CFrame.new(2 * v45, 0, -0.5 * math.pow(math.abs(v45), 2) + 4)
				v46.Orientation = Vector3.new(-90, 90, 0)
				v46.CanCollide = false
				v46.Anchored = false
				local v47 = Instance.new("BodyVelocity")
				v47.Velocity = Vector3.new(0, 10, 0)
				v47.Parent = v46
				v46.Parent = workspace.Thrown
				task.delay(11, v46.Destroy, v46)
				l__TweenService__7:Create(v47, u8, {
					Velocity = Vector3.new(0, 0, 0)
				}):Play()
				Instance.new("BodyAngularVelocity", v46).AngularVelocity = Vector3.new(0, 10, 0)
				u2.fadeInStart(v46)
				u2.fadeInSuccess(v46)
				u2.fadeOut(v46, 10)
			end
			wait(0.75)
			while #v44 > 0 do
				local v48 = table.remove(v44, (math.random(1, #v44)))
				v48:SetNetworkOwner(nil)
				wait(0.5 / (v43 * 2 + 1))
				u9 = _G.MouseData(v40)
				local v49 = u9.Hit.Position + 2 * Vector3.new(math.random(), math.random(), math.random())
				local v50 = CFrame.new(v48.Position, v49)
				local v51, v52, v53 = u1(v48.Position, v49, 2500, { game.Workspace.Live, workspace.Thrown, workspace.Destructibles })
				local l__Magnitude__54 = (v52 - v48.Position).Magnitude
				v48.CFrame = v50
				v48.BodyAngularVelocity.AngularVelocity = (v48.Position - u9.Hit.Position).unit * 10
				v48.CanCollide = false
				v48.BodyVelocity.Velocity = v48.CFrame.lookVector * 250
				v48.Fire:Play()
				local u10 = false
				local u11 = nil
				u11 = v48.Touched:Connect(function(p14)
					if not p14.Parent then
						return
					end
					if p14.Parent.Name == p10.Name then
						return
					end
					if p14:IsDescendantOf(p10) then
						return
					end
					if p14:IsDescendantOf(workspace.Terrain) then
						return
					end
					if p14.Name == v48.Name then
						return
					end
					if p14.Parent.Name == "Shadow Buddy" then
						return
					end
					local v55 = p14.Parent:FindFirstChild("Humanoid") or p14.Parent.Parent:FindFirstChild("Humanoid")
					if v55 and v55.Parent.Name == p10.Name then
						return
					end
					v48.BodyVelocity:Destroy()
					v48.BodyAngularVelocity:Destroy()
					if v55 and not v55.Parent:FindFirstChild("SpellParry") then
						if not v55.Parent:FindFirstChild("SpellBlocking") then
						end
						u10 = true
						v48.Position = p14.Position + (v48.Position - p14.Position).Unit
						local v56 = Instance.new("WeldConstraint")
						v56.Part0 = v48
						v56.Part1 = p14
						v56.Parent = v48
						l__TagHumanoid__3:Fire(v40.Character, v55.Parent, {
							damage = 5, 
							poison = true,
							move = "Perflora"
						})
					else
						v48.Position = v52
						v48.Anchored = true
					end
					u11:disconnect()
				end)		
			end
		else
			l__TagHumanoid__3:Fire(v40.Character, v40.Character, {
				damage = 15, 
				poison = true,
				move = "Perflora"
			})
		end
	end)
end
v1.alternate = u6
return v1