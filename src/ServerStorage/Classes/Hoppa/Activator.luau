local l__Parent__1 = script.Parent
local v2 = {}
function sub(...)
	coroutine.wrap(...)()
end
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid
local v4 = require(game.ServerScriptService.Modules.HitDetection)
v2.upperbound = 60
v2.lowerbound = 40
v2.signs = 5
v2.cost = 25
local v5 = {
	upperbound = 60, 
	lowerbound = 50, 
	signs = 0, 
	cost = 20
}
local l__FireWhip__6 = game.ServerStorage.SpellEffects.FireWhip
local l__TweenService__1 = game:GetService("TweenService")
function v2.Activate(p1, p2, p3, p4)
	if game.CollectionService:HasTag(p2,"Casting") or p2:FindFirstChild("ActiveCast")then
		return
	end
	if game.CollectionService:HasTag(p2,"HoppaCD")then
		return
	end
	local l__Mana__7 = p2.Mana
	local l__Value__8 = game.ServerStorage.PlayerData[game.Players:GetPlayerFromCharacter(p2).Name].ManaColor.Value
	local l__Position__9 = p2.HumanoidRootPart.Position
	local v10, v11 = workspace:FindPartOnRayWithIgnoreList(Ray.new(l__Position__9, Vector3.new(0, -1000, 0)), { workspace.Live, workspace.AreaMarkers })
	if not v10 then
		return
	end

	local v12 = (v11 - l__Position__9).magnitude < 20
	game.CollectionService:AddTag(p2, "HoppaCD")
		task.delay(8, function()
			game.CollectionService:RemoveTag(p2, "HoppaCD")
		end)

	if p3 ~= 0 then
		if p3 ~= 0 then
			local v13 = game.ReplicatedStorage.Assets.Tornado:Clone()
			v13.CFrame = p2.HumanoidRootPart.CFrame * CFrame.new(0, 70, 0) * CFrame.Angles(math.rad(180), 0, 0)
			v13.Parent = game.Workspace.Thrown
			v13.Sound:Play()
			l__TweenService__1:Create(v13, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
				CFrame = v13.CFrame * CFrame.Angles(0, math.rad(180), 0)
			}):Play()
			l__TweenService__1:Create(v13, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
				Transparency = 0.8
			}):Play()
			game:GetService("Debris"):AddItem(v13, 2.5)
			local KNOCK = Instance.new("Accessory")
			KNOCK.Name = "Knocked"
			KNOCK.Parent = p2
			game.Debris:AddItem(KNOCK,3)
			local v14 = Instance.new("BodyVelocity")
			game.CollectionService:AddTag(v14, "AllowedBM")
			v14.Name = "WindVelocity"
			v14.MaxForce = Vector3.new(1000000, 1000000, 1000000)
			v14.Velocity = Vector3.new(0, 400, 0)
			v14.Parent = p2.HumanoidRootPart
			game:GetService("Debris"):AddItem(v14, 0.3)
			local v15 = Instance.new("Accessory")
			v15.Name = "FlightOk"
			v15.Parent = p2
			game:GetService("Debris"):AddItem(v15, 3)
		end
		return
	end
	if p2:FindFirstChild("EndCast") then
		return
	end
	local v16 = game.ReplicatedStorage.Assets.Tornado:Clone()
	if not v12 then
		v16.Size = v16.Size * 0.5
	end
	v16.CFrame = p2.HumanoidRootPart.CFrame * CFrame.new(0, v16.Size.y / 2, 0) * CFrame.Angles(math.rad(180), 0, 0)
	v16.Parent = game.Workspace.Thrown
	v16.Sound:Play()
	local v17 = p2.Humanoid:LoadAnimation(script.Animation)
	v17:Play()
	v17:AdjustSpeed(2)
	l__TweenService__1:Create(v16, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
		CFrame = v16.CFrame * CFrame.Angles(0, math.rad(180), 0)
	}):Play()
	l__TweenService__1:Create(v16, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
		Transparency = 0.8
	}):Play()
	game:GetService("Debris"):AddItem(v16, 2.5)
	local v18 = Instance.new("BodyVelocity")
	game.CollectionService:AddTag(v18, "AllowedBM")
	v18.Name = "WindVelocity"
	v18.MaxForce = Vector3.new(1000000, 1000000, 1000000)
	v18.Velocity = v12 and Vector3.new(0, 200, 0) or Vector3.new(0, 50, 0)
	v18.Parent = p2.HumanoidRootPart
	game:GetService("Debris"):AddItem(v18, 0.3)
	local v19 = Instance.new("Accessory")
	v19.Name = "FlightOk"
	v19.Parent = p2
	game:GetService("Debris"):AddItem(v19, 3)
	local v20 = Instance.new("Accessory")
	v20.Name = "NoFall"
	v20.Parent = p2
	game:GetService("Debris"):AddItem(v20, 7)
end
function v2.Deactivate(p5, p6, p7)
	local v21 = Instance.new("Accessory")
	v21.Name = "EndCast"
	v21.Parent = p6
	game:GetService("Debris"):AddItem(v21, 2)
end
function v5.Activate(p8, p9, p10, p11, p12)
	if game.CollectionService:HasTag(p9, "Casting") then
		return
	end
	local l__Mana__22 = p9.Mana
	local v23 = game.Players:GetPlayerFromCharacter(p9)
	local v24 = v23 and game.ServerStorage.PlayerData:FindFirstChild(v23.Name)
	if not p12[script.Parent.Name] then
		return
	end
	local l__Position__25 = p9.HumanoidRootPart.Position
	local v26, v27 = workspace:FindPartOnRayWithIgnoreList(Ray.new(l__Position__25, Vector3.new(0, -1000, 0)), { workspace.Live, workspace.AreaMarkers })
	if not v26 then
		return
	end

	local u2 = _G.MouseData(v23)
	if not u2 then
		return
	end
	if not v24 or not v24.ManaColor.Value or not p9:FindFirstChild("HumanoidRootPart") then
		return
	end
	if p10 == 0 then
		local u3 = (v27 - l__Position__25).magnitude < 20
		sub(function()
			p9.HumanoidRootPart.PerfectCast:Play()
			p9.Humanoid:LoadAnimation(script.Snap2):Play()
			wait(0.2)
			local v28 = game.ReplicatedStorage.Assets.HandHoldCeleri:Clone()
			v28.IllusionArm.Enabled = false
			v28.Parent = game.Workspace.Thrown
			v28.Snap:Play()
			v28.IllusionSnap:Emit(100)
			local v29 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180))
			if not p11 then
				v29 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180))
			end
			local u4 = Instance.new("Weld")
			local u5 = p9["Right Arm"]
			sub(function()
				u4.Name = "Weld"
				u4.Part0 = u5
				u4.Part1 = v28
				u4.Parent = v28
				u4.C1 = v29
				wait(1)
				v28:Destroy()
			end)
			local v30 = p9.Humanoid:LoadAnimation(script.Animation)
			v30:Play()
			v30:AdjustSpeed(2)
			local v31 = game.ReplicatedStorage.Assets.Tornado:Clone()
			v31.CFrame = p9.HumanoidRootPart.CFrame * CFrame.new(0, 70, 0) * CFrame.Angles(math.rad(180), 0, 0)
			v31.Parent = game.Workspace.Thrown
			v31.Sound:Play()
			l__TweenService__1:Create(v31, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
				CFrame = v31.CFrame * CFrame.Angles(0, math.rad(180), 0)
			}):Play()
			l__TweenService__1:Create(v31, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
				Transparency = 0.8
			}):Play()
			game:GetService("Debris"):AddItem(v31, 2.5)
			local v32 = Instance.new("Accessory")
			v32.Name = "NoFall"
			v32.Parent = p9
			game:GetService("Debris"):AddItem(v32, 7)
			local v33 = Instance.new("Accessory")
			v33.Name = "FlightOk"
			v33.Parent = p9
			game:GetService("Debris"):AddItem(v33, 3)
			for v34, v35 in pairs(game.Workspace.Live:GetChildren()) do
				if not v35:FindFirstChild("Knocked") and not v35:FindFirstChildOfClass("ForceField") and v35:FindFirstChild("HumanoidRootPart") and not v35:FindFirstChild("Blocking") and (v35.Torso.Position - p9.Torso.Position).Magnitude <= 20 then
					if v35 == p9 then
						local v36 = Instance.new("BodyVelocity")
						game.CollectionService:AddTag(v36, "AllowedBM")
						v36.Name = "WindVelocity"
						v36.MaxForce = Vector3.new(1000000, 1000000, 1000000)
						v36.Velocity = u3 and Vector3.new(0, 300, 0) or Vector3.new(0, 150, 0)
						v36.Parent = v35.HumanoidRootPart
						game:GetService("Debris"):AddItem(v36, 0.3)
					else
						local v37 = Instance.new("BodyVelocity")
						game.CollectionService:AddTag(v37, "AllowedBM")
						v37.Name = "WindVelocity"
						v37.MaxForce = Vector3.new(1000000, 1000000, 1000000)
						v37.Velocity = Vector3.new(0, 0, 0)
						v37.Parent = v35.HumanoidRootPart
						game:GetService("Debris"):AddItem(v37, 0.2)
						v37.Name = "WindVelocity"
						v37.MaxForce = Vector3.new(1000000, 1000000, 1000000)
						local v38
						if u3 then
							v38 = -100
						else
							v38 = -50
						end
						v37.Velocity = p9.HumanoidRootPart.CFrame.lookVector * v38
						v37.Parent = v35.HumanoidRootPart
						game:GetService("Debris"):AddItem(v37, 0.3)
					end
				end
			end
		end)
	else
		local v39 = game.ReplicatedStorage.Assets.Tornado:Clone()
		v39.CFrame = p9.HumanoidRootPart.CFrame * CFrame.new(0, 70, 0) * CFrame.Angles(math.rad(180), 0, 0)
		v39.Parent = game.Workspace.Thrown
		v39.Sound:Play()
		l__TweenService__1:Create(v39, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
			CFrame = v39.CFrame * CFrame.Angles(0, math.rad(180), 0)
		}):Play()
		l__TweenService__1:Create(v39, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
			Transparency = 0.8
		}):Play()
		game:GetService("Debris"):AddItem(v39, 2.5)
		local KNOCK = Instance.new("Accessory")
		KNOCK.Name = "Knocked"
		KNOCK.Parent = p9
		game.Debris:AddItem(KNOCK,3)
		local v40 = Instance.new("BodyVelocity")
		game.CollectionService:AddTag(v40, "AllowedBM")
		v40.Name = "WindVelocity"
		v40.MaxForce = Vector3.new(1000000, 1000000, 1000000)
		v40.Velocity = Vector3.new(0, 400, 0)
		v40.Parent = p9.HumanoidRootPart
		game:GetService("Debris"):AddItem(v40, 0.3)
		local v41 = Instance.new("Accessory")
		v41.Name = "FlightOk"
		v41.Parent = p9
		game:GetService("Debris"):AddItem(v41, 3)
	end
end
v2.alternate = v5
return v2