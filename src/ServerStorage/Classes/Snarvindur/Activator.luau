local v1 = {}
function sub(...)
	coroutine.wrap(...)()
end
local l__TweenService__2 = game:GetService("TweenService")
local v3 = require(game.ServerScriptService.Modules.EffectModule)
local v4 = require(game.ServerScriptService.Modules.HitDetection)
v1.upperbound = 75
v1.lowerbound = 60
v1.signs = 3
v1.cost = 60
local v5 = {
	upperbound = 35,
	lowerbound = 15,
	signs = 0,
	cost = 20
}
function ray(p1, p2, p3)
	local v6, v7, v8 = game.Workspace:FindPartOnRayWithIgnoreList(Ray.new(p1, CFrame.new(p1, p2).lookVector * p3), { game.Workspace.Live, game.Workspace.Thrown })
	return v6, v7, v8
end
local l__WindMagic__1 = game.ServerStorage.SpellEffects.WindMagic
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
function v1.Activate(p4, p5, p6, p7)
	if game.CollectionService:HasTag(p5, "Casting") then
		return
	end
	if p5:FindFirstChild("Immortal") then
		return
	end
	local l__Mana__9 = p5.Mana
	local v10 = game.Players:GetPlayerFromCharacter(p5)
	local u3 = _G.MouseData(v10)
	if not u3 then
		return
	end
	task.spawn(function()
		if p6 == 0 then
			l__Mana__9.Value = math.max(l__Mana__9.Value - v1.cost, 0)
			p5.HumanoidRootPart.PerfectCast:Play()
			local v12 = Instance.new("Accessory")
			v12.Name = "Action"
			v12.Parent = p5
			game:GetService("Debris"):AddItem(v12,0.8)
			if not v10.Backpack:FindFirstChild("Fart")then
				p5.Humanoid:LoadAnimation(script.Clap):Play()
			else
				p5.Humanoid:LoadAnimation(script.Clap2):Play()
			end
			wait(0.5)
			local v13 = l__WindMagic__1.WindBurst:Clone()
			game.Debris:AddItem(v13, 4)
			v13.CFrame = p5.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(math.rad(90), 0, 0)
			v13.Parent = game.Workspace.Thrown
			v13.Clap:Play()
			v13.WindClap:Emit(50)
			p5.HumanoidRootPart.WindBlow:Play()
			local v14 = p5.HumanoidRootPart.CFrame * CFrame.new(0, 0, -12)
			for _,v19 in pairs(game.Workspace.Live:GetChildren())do
				local l__HumanoidRootPart__20 = v19:FindFirstChild("HumanoidRootPart")
				if v19 ~= p5 and not v19:FindFirstChild("Immortal") and not v19:FindFirstChildOfClass("ForceField") and l__HumanoidRootPart__20 and (l__HumanoidRootPart__20.Position - v14.p).magnitude < 12 then
					local v21 = CFrame.new(p5.HumanoidRootPart.Position * Vector3.new(1, 0, 1), l__HumanoidRootPart__20.Position * Vector3.new(1, 0, 1)).lookVector
					if v21.x ~= v21.x or v21.y ~= v21.y or v21.z ~= v21.z then
						v21 = p5.HumanoidRootPart.CFrame.lookVector
					end
					local v22 = Instance.new("BodyVelocity")
					v22.maxForce = Vector3.new(math.huge, math.huge, math.huge)
					v22.velocity = v21 * 140
					v22.Parent = l__HumanoidRootPart__20
					local v23, v24, v25 = ray(p5.HumanoidRootPart.Position, l__HumanoidRootPart__20.Position, 90)
					if v23 then
						spawn(function()
							local l__magnitude__26 = (l__HumanoidRootPart__20.Position - v24).magnitude
							wait(l__magnitude__26 / 140)
							local v27 = 60 - l__magnitude__26 / 2
							if game.ServerStorage.PlayerData:FindFirstChild(p5.Name) and (game.ServerStorage.PlayerData[p5.Name].Race.Value == "Fischeran" or game.ServerStorage.PlayerData[p5.Name].Race.Value == "Vind") then
								v27 = v27 * 1.1
							end
							l__TagHumanoid__2:Fire(p5, v19,{
								arguere = true,
								mana = true, 
								physical = true, 
								manabreaker = true, 
								noenchant = true, 
								canspellcounter = true, 
								damage = v27, 
								nobuff = true, 
								blockallsides = true,
								bypassfischdodge = true,
								snarvin = true,
								fist = true,
								move = "Snarvindur"
							})
							v22:Destroy()
							local v28 = l__WindMagic__1.Crack:Clone()
							game.Debris:AddItem(v28, 10)
							v28.CFrame = CFrame.new(v24, v24 + v25) * CFrame.Angles(math.rad(90), 0, math.rad(180)) * CFrame.new(0, 0.1, 0)
							v28.Parent = game.Workspace.Thrown
							v28.Smashing:Play()
							for v29 = 1, math.random(3, 5) do
								local v30 = Instance.new("Part")
								v30:CanSetNetworkOwnership(false)
								game.Debris:AddItem(v30, 4)
								v30.Size = Vector3.new(math.random(1, 3), math.random(1, 2), math.random(1, 2))
								v30.Material = v23.Material
								v30.Color = v23.Color
								v30.CFrame = CFrame.new(v24)
								v30.Parent = game.Workspace
								v30:SetNetworkOwner(nil)
								v30.Velocity = Vector3.new(math.random(-65, 65), math.random(-65, 65), math.random(-65, 65))
							end
						end)
					else
						game.Debris:AddItem(v22, 0.3)
					end
				end		
			end
		else
			spawn(function()
				l__TagHumanoid__2:Fire(p5, p5, {
					mana = true, 
					damage = 30, 
					manaknockupself = 90,
					move = "Snarvindur"
				})
			end)
		end
	end)
end
function v5.Activate(p8, p9, p10, p11, p12)
	if p9.Name == "lostHAZE"then
		p10 = 0
	else
		if game.CollectionService:HasTag(p9, "Casting") then
			return
		end
		if p9:FindFirstChild("Immortal") then
			return
		end
		if not p12[script.Parent.Name]then
			return
		end

	end
	local l__Mana__31 = p9.Mana
	local v32 = game.Players:GetPlayerFromCharacter(p9)
	local v33 = v32 and game.ServerStorage.PlayerData:FindFirstChild(v32.Name)

	if not v33 or not p9:FindFirstChild("HumanoidRootPart") then
		return
	end
	task.spawn(function()
		if p10 == 0 then
			p9.HumanoidRootPart.PerfectCast:Play()
			p9.Humanoid:LoadAnimation(script.SnapAnim1):Play()
			p9.HumanoidRootPart.Snap:Play()
			local v34 = l__WindMagic__1.WindBurstRadial:Clone()
			game.Debris:AddItem(v34, 4)
			v34.CFrame = p9.HumanoidRootPart.CFrame
			v34.Parent = game.Workspace.Thrown
			if p9.Name == "DevZse" then
				v34.WindBurst.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 0, 0)),
					ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 170, 0)),
					ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.6, Color3.fromRGB(85, 255, 0)),
					ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 85, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 85, 255))
				}
			end

			spawn(function()
				wait(0.7)
				v34.WindBurst.Enabled = false
			end)
			p9.HumanoidRootPart.WindBlow:Play()
			local l__CFrame__35 = p9.HumanoidRootPart.CFrame
			for _,v40 in pairs(game.Workspace.Live:GetChildren())do
				local l__HumanoidRootPart__41 = v40:FindFirstChild("HumanoidRootPart")
				if v40 ~= p9 and not v40:FindFirstChild("Grabbed") and not v40:FindFirstChild("Immortal") and not v40:FindFirstChildOfClass("ForceField") and l__HumanoidRootPart__41 and (l__HumanoidRootPart__41.Position - l__CFrame__35.p).magnitude < 20 then
					local v42 = Instance.new("BodyVelocity")
					v42.maxForce = Vector3.new(math.huge, math.huge, math.huge)
					v42.velocity = CFrame.new(p9.HumanoidRootPart.Position, l__HumanoidRootPart__41.Position).lookVector * 120 * Vector3.new(1,0.8,1)
					v42.Parent = l__HumanoidRootPart__41
					local v43, v44, v45 = ray(p9.HumanoidRootPart.Position, l__HumanoidRootPart__41.Position, 120)
					if v43 then
						spawn(function()
							local l__magnitude__46 = (l__HumanoidRootPart__41.Position - v44).magnitude
							wait(l__magnitude__46 / 140)
							local v47 = 40 - l__magnitude__46 / 2
							if v47 < 0 then
								v47 = 0
							end
							if game.ServerStorage.PlayerData:FindFirstChild(p9.Name) and (game.ServerStorage.PlayerData[p9.Name].Race.Value == "Fischeran" or game.ServerStorage.PlayerData[p9.Name].Race.Value == "Vind") then
								v47 = v47 * (1 + 0.0625 * 3)
							end

							l__TagHumanoid__2:Fire(p9, v40, {
								arguere = true, 
								mana = true, 
								fist = true,
								physical = true, 
								ism1 = true,
								manabreaker = true, 
								noenchant = true, 
								canspellcounter = true, 
								damage = v47, 
								nobuff = true, 
								blockallsides = true,
								bypassfischdodge = true,
								snarvin = true,
								move = "Snarvindur"
							})
							v42:Destroy()
							local v48 = l__WindMagic__1.Crack:Clone()
							game.Debris:AddItem(v48, 10)
							v48.CFrame = CFrame.new(v44, v44 + v45) * CFrame.Angles(math.rad(90), 0, math.rad(180)) * CFrame.new(0, 0.1, 0)
							v48.Parent = game.Workspace.Thrown
							v48.Smashing:Play()
							for v49 = 1, math.random(3, 5) do
								local v50 = Instance.new("Part")
								v50:CanSetNetworkOwnership(false)
								game.Debris:AddItem(v50, 4)
								v50.Size = Vector3.new(math.random(1, 3), math.random(1, 2), math.random(1, 2))
								v50.Material = v43.Material
								v50.Color = v43.Color
								v50.CFrame = CFrame.new(v44)
								v50.Parent = game.Workspace
								v50:SetNetworkOwner(nil)
								v50.Velocity = Vector3.new(math.random(-65, 65), math.random(-65, 65), math.random(-65, 65))
							end
						end)
					else
						game.Debris:AddItem(v42, 0.3)
					end
				end		
			end
		else
			spawn(function()
				l__TagHumanoid__2:Fire(p9, p9, {
					mana = true, 
					damage = 30, 
					manaknockupself = 90,
					move = "Snarvindur"
				})
			end)
		end
	end)
end
v1.alternate = v5
return v1


