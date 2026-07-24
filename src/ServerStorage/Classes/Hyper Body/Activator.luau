

local v1 = {}
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
local v3 = require(game.ServerScriptService.Modules.HitDetection)
local l__Parent__1 = script.Parent.Parent
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast"},
		presentTagBlocks = {"Unconscious","Knocked"},
	})
end
local v4 = tick()
local u2 = { workspace.Live }
function ray(p1, p2, p3, p4)
	local v5, v6, v7 = workspace:FindPartOnRayWithIgnoreList(Ray.new(p1, CFrame.new(p1, p2).LookVector * p3), u2)
	return v5, v6, v7
end
local u3 = { workspace.Live, workspace.AreaMarkers, workspace.Thrown, workspace.Stations, workspace.Ingredients, workspace.Terrain }
local u4 = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)) })
local u5 = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 203, 98)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 203, 98)) })
local l__TweenService__6 = game:GetService("TweenService")
function thebuff(p5, p6, p7)
	if not p5:FindFirstChild("HasSigilBuff") then
		local v8 = 1 + p6 / 5
		local v9 = Instance.new("StringValue")
		v9.Name = "HasSigilBuff"
		v9.Value = l__Parent__1.Name
		v9.Parent = p5
		game:GetService("Debris"):AddItem(v9, 90)
		local l__Boosts__10 = p5.Boosts
		local v11 = Instance.new("IntValue")
		v11.Name = "SpeedBoost"
		v11.Value = 5 / v8
		v11.Parent = l__Boosts__10
		game:GetService("Debris"):AddItem(v11, 90)
		local v12 = Instance.new("IntValue")
		v12.Name = "AttackSpeedBoost"
		v12.Value = 4 / v8
		v12.Parent = l__Boosts__10
		game:GetService("Debris"):AddItem(v12, 90)
		local v13 = Instance.new("NumberValue")
		v13.Name = "HealthBoost"
		v13.Value = 0.35 / v8
		v13.Parent = l__Boosts__10
		game:GetService("Debris"):AddItem(v13, 90)
		local v14 = Instance.new("NumberValue")
		v14.Name = "HealthRegen"
		v14.Value = 0.4 / v8
		v14.Parent = l__Boosts__10
		game:GetService("Debris"):AddItem(v14, 90)
		if p7 then
			local v15 = Instance.new("Accessory")
			v15.Name = "FireProtection"
			v15.Parent = nil
			game:GetService("Debris"):AddItem(v15, 90)
			local v16 = Instance.new("Accessory")
			v16.Name = "HeatProtect"
			v16.Parent = nil
			game:GetService("Debris"):AddItem(v16, 90)
			local u7 = false
			spawn(function()
				local l__HumanoidRootPart__17 = l__Parent__1.HumanoidRootPart
				local l__Humanoid__18 = l__Parent__1.Humanoid
				while true do
					if v9 then
					else
						break
					end
					local v19 = game.Lighting:GetSunDirection()
					local v20 = not workspace:FindPartOnRayWithIgnoreList(Ray.new(l__HumanoidRootPart__17.Position, v19 * 2000), u3) and not workspace:FindPartOnRayWithIgnoreList(Ray.new(l__HumanoidRootPart__17.Position + v19 * 500, v19 * -500), u3)
					if v20 then
						if v20 then
							if not u7 then
								u7 = true
								v11.Value = v11.Value + 5 / v8
								v12.Value = v12.Value + 4 / v8
								v13.Value = v13.Value + 0.35 / v8
								v14.Value = v14.Value + 0.4 / v8
								v15.Parent = p5
								v16.Parent = p5
								for _,v25 in pairs(p5:GetChildren())do
									if v25:IsA("BasePart") then
										local l__hyperptcl__26 = v25:FindFirstChild("hyperptcl")
										if l__hyperptcl__26 then
											l__hyperptcl__26.Color = u4
										end
									end								
								end
							elseif u7 then
								u7 = false
								v11.Value = v11.Value - 5 / v8
								v12.Value = v12.Value - 4 / v8
								v13.Value = v13.Value - 0.35 / v8
								v14.Value = v14.Value - 0.4 / v8
								v15.Parent = nil
								v16.Parent = nil
								for _,v31 in pairs(p5:GetChildren())do
									if v31:IsA("BasePart") then
										local l__hyperptcl__32 = v31:FindFirstChild("hyperptcl")
										if l__hyperptcl__32 then
											l__hyperptcl__32.Color = u5
										end
									end								
								end
							end
						elseif u7 then
							u7 = false
							v11.Value = v11.Value - 5 / v8
							v12.Value = v12.Value - 4 / v8
							v13.Value = v13.Value - 0.35 / v8
							v14.Value = v14.Value - 0.4 / v8
							v15.Parent = nil
							v16.Parent = nil
							for _,v31 in pairs(p5:GetChildren())do
								if v31:IsA("BasePart") then
									local l__hyperptcl__32 = v31:FindFirstChild("hyperptcl")
									if l__hyperptcl__32 then
										l__hyperptcl__32.Color = u5
									end
								end							
							end
						end
					elseif u7 then
						u7 = false
						v11.Value = v11.Value - 5 / v8
						v12.Value = v12.Value - 4 / v8
						v13.Value = v13.Value - 0.35 / v8
						v14.Value = v14.Value - 0.4 / v8
						v15.Parent = nil
						v16.Parent = nil
						for _,v31 in pairs(p5:GetChildren())do
							if v31:IsA("BasePart") then
								local l__hyperptcl__32 = v31:FindFirstChild("hyperptcl")
								if l__hyperptcl__32 then
									l__hyperptcl__32.Color = u5
								end
							end						
						end
					end
					wait(0.5)				
				end
			end)
		end
		local l__HumanoidRootPart__33 = l__Parent__1.HumanoidRootPart
		local v34 = game.Lighting:GetSunDirection()
		local v35 = not workspace:FindPartOnRayWithIgnoreList(Ray.new(l__HumanoidRootPart__33.Position, v34 * 2000), u3) and not workspace:FindPartOnRayWithIgnoreList(Ray.new(l__HumanoidRootPart__33.Position + v34 * 500, v34 * -500), u3)
		local v36 = game.ServerStorage.SpellEffects.sigilfire.HyperBody:Clone()
		if p7 then
			if v35 then
				v36.Color = Color3.fromRGB(255, 255, 255)
			end
		end
		game.Debris:AddItem(v36, 1)
		v36.CFrame = p5.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0) * CFrame.Angles(0, 0, math.rad(90))
		v36.Parent = game.Workspace
		v36.Sound:Play()
		local v37 = TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local v38 = l__TweenService__6:Create(v36.Mesh, v37, {
			Scale = Vector3.new(1, 1, 1)
		}):Play()
		local v39 = l__TweenService__6:Create(v36, v37, {
			Transparency = 1
		}):Play()
		local l__next__40 = next
		local v41, v42 = p5:GetChildren()
		while true do
			local v43, v44 = l__next__40(v41, v42)
			if v43 then
			else
				break
			end
			v42 = v43
			if v44:IsA("BasePart") then
				local v45 = game.ServerStorage.SpellEffects.sigilfire.hyperptcl:Clone()
				v45.Parent = v44
				game.Debris:AddItem(v45, 90)
			end		
		end
	end
end
local u8 = true
function v1.Active(p8, p9, p10, p11)
	if ActionCheck() then
		return
	end
	if game.CollectionService:HasTag(p8, "Knocked") then
		return
	end
	if p8.Cooldowns:FindFirstChild("Hyper Body") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Hyper Body"
	CD.Value = 120
	CD.Parent = p8.Cooldowns
	game.Debris:AddItem(CD, 120)
	u8 = false
	local l__Value__46 = game.ServerStorage.PlayerData:FindFirstChild(p9.Name).LastName.Value
	local l__HumanoidRootPart__47 = p8.HumanoidRootPart
	local v48 = Instance.new("Accessory")
	v48.Name = "NoJump"
	v48.Parent = p8
	game:GetService("Debris"):AddItem(v48, 1)
	local v49 = Instance.new("Accessory")
	v49.Name = "Action"
	v49.Parent = p8
	game:GetService("Debris"):AddItem(v49, 1.2)
	p8.Humanoid:LoadAnimation(script.Parent:FindFirstChild("Animation")):Play()
	wait(1.2)
	local l__UpgradedHyperBody__50 = p9.Backpack:FindFirstChild("UpgradedHyperBody")
	if not p8:FindFirstChild("Stunned") then
		local v51 = 0
		local l__next__52 = next
		local v53, v54 = game.Workspace.Live:GetChildren()
		while true do
			local v55, v56 = l__next__52(v53, v54)
			if not v55 then
				break
			end
			v54 = v55
			if game.Players:GetPlayerFromCharacter(v56) and game.ServerStorage.PlayerData[v56.Name].LastName.Value == l__Value__46 and (v56.HumanoidRootPart.Position - l__HumanoidRootPart__47.Position).magnitude < 45 and v56 ~= p8 then
				v51 = v51 + 1
			end		
		end
		if l__Value__46 ~= "" then
			local l__next__57 = next
			local v58, v59 = game.Workspace.Live:GetChildren()
			while true do
				local v60, v61 = l__next__57(v58, v59)
				if not v60 then
					break
				end
				v59 = v60
				if game.Players:GetPlayerFromCharacter(v61) and game.ServerStorage.PlayerData[v61.Name].LastName.Value == l__Value__46 and (v61.HumanoidRootPart.Position - l__HumanoidRootPart__47.Position).magnitude < 45 then
					thebuff(v61, v51, l__UpgradedHyperBody__50)
				end			
			end
		else
			thebuff(p8, 0, l__UpgradedHyperBody__50)
		end
	end
	wait(120)
	u8 = true
end
return v1