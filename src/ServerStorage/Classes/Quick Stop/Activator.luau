local l__Parent__1 = script.Parent
local l__Parent__2 = l__Parent__1.Parent
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid
local l__TweenService__4 = game:GetService("TweenService")
function sub(...)
	coroutine.wrap(...)()
end
local l__TweenService__5 = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(p1)
	return ActionCheckModule(p1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Stun", "ReturnStun", "ActiveCast", "Action", "Blocking", "Climbing"},
		healthAtOrBelow = 0,
	})
end
function ActionCheck2(p2)
	if not p2:FindFirstChild("Humanoid") then
		return true
	end
	if p2:FindFirstChild("Climbing") then

	else
		return
	end
	return true
end
local v6 = {}
local u1 = true
local u2 = require(game.ServerScriptService.Modules.HitDetection)
function v6.Active(p3, p4, p5)
	if not u1 then
		return
	end
	if ActionCheck(p3) then
		return
	end
	local l__Humanoid__7 = p3.Humanoid
	local l__HumanoidRootPart__8 = p3.HumanoidRootPart
	u1 = false
	local u3 = _G.MouseData(p4)
	if not u3 then
		u1 = true
		return
	end
	local l__p__9 = u3.Hit.p
	if (l__p__9 - l__HumanoidRootPart__8.Position).Magnitude > 150 then
		u1 = true
		return
	end
	local v10 = CFrame.new(l__p__9 + Vector3.new(0, 2, 0)) * (l__HumanoidRootPart__8.CFrame - l__HumanoidRootPart__8.Position)
	local v11 = Instance.new("Vector3Value", p3)
	v11.Name = "TPSafe"
	v11.Value = v10.p
	game.Debris:AddItem(v11, 0.5)
	local v12 = Instance.new("Folder",p3)
	v12.Name = "NoFall"
	game.Debris:AddItem(v12,0.5)
	l__HumanoidRootPart__8.CFrame = v10
	local v13 = l__Parent__1.Sound:Clone()
	v13.Parent = l__HumanoidRootPart__8
	v13:Play()
	game.Debris:AddItem(v13,1)
	for _,v18 in pairs(game.Players:GetPlayers())do
		if v18.Character and (v18.Character:FindFirstChild("HumanoidRootPart") and (v18.Character.Torso.Position - l__p__9).Magnitude < 150) then
			game.ReplicatedStorage.Requests.ScreenFlip:FireClient(v18, false, 0.1)
		end
	end
	task.wait(3)
	u1 = true
end
local u4 = true
function v6.Active2(p6, p7, p8)
	if not u4 then
		return
	end
	if ActionCheck2(p6) then
		return
	end
	local l__Humanoid__19 = p6.Humanoid
	local l__HumanoidRootPart__20 = p6.HumanoidRootPart
	u4 = false
	local v21 = Instance.new("Folder", p6)
	v21.Name = "Immortal"
	game.Debris:AddItem(v21,1)
	for _,v26 in pairs(game.Players:GetPlayers())do
		if v26.Character and (v26.Character:FindFirstChild("HumanoidRootPart") and (v26.Character.Torso.Position - l__HumanoidRootPart__20.Position).Magnitude < 150) then
			game.ReplicatedStorage.Requests.TimeErase:FireClient(v26)
		end	
	end
	for _,v31 in pairs(workspace.Live:GetChildren())do
		if v31 and v31:FindFirstChild("HumanoidRootPart") and (v31.HumanoidRootPart.Position - l__HumanoidRootPart__20.Position).Magnitude < 150 then
			local l__HumanoidRootPart__32 = v31.HumanoidRootPart
			local v33 = game.Players:GetPlayerFromCharacter(v31)
			if not v33 then
				continue
			end
			local v34 = Instance.new("Accessory")
			v34.Name = "TPSafe"
			v34.Parent = v31
			game.Debris:AddItem(v34,0.5)
			local v35 = Instance.new("Accessory")
			v35.Name = "TIMESKIP"
			v35.Parent = v31
			game.Debris:AddItem(v35,0.25)
			local l__Velocity__36 = l__HumanoidRootPart__32.Velocity
			local v37, v38, v39 = workspace:FindPartOnRayWithIgnoreList(Ray.new(l__HumanoidRootPart__32.Position, l__Velocity__36 * 4), { v31, workspace.AreaMarkers, workspace.Thrown })
			if v37 then
				local l__p__40 = (CFrame.new(v38, l__HumanoidRootPart__20.Position) * CFrame.new(0, 0, -1)).p
				if v33 then
					local v43, v44, v45 = workspace:FindPartOnRayWithIgnoreList(Ray.new(l__p__40, Vector3.new(0, -50, 0)), { workspace.Thrown, workspace.Live })
					if not v43 or not v43.CanCollide and v43.Transparency ~= 0 then
						game.ReplicatedStorage.Requests.TPtoNonCliff:FireClient(v33, l__p__40)
					else
						l__HumanoidRootPart__32.CFrame = CFrame.new(l__p__40, l__p__40 + l__HumanoidRootPart__32.CFrame.lookVector)
					end
				else
					l__HumanoidRootPart__32.CFrame = CFrame.new(l__p__40, l__p__40 + l__HumanoidRootPart__32.CFrame.lookVector)
				end
			else
				local l__p__46 = (CFrame.new(l__HumanoidRootPart__32.Position, l__HumanoidRootPart__32.Position + l__Velocity__36) * CFrame.new(0, 0, -l__Velocity__36.Magnitude * 4)).p
				if v33 then
					local v49, v50, v51 = workspace:FindPartOnRayWithIgnoreList(Ray.new(l__p__46, Vector3.new(0, -50, 0)), { workspace.Thrown, workspace.Live })
					if not v49 or not v49.CanCollide and v49.Transparency ~= 0 then
						game.ReplicatedStorage.Requests.TPtoNonCliff:FireClient(v33, l__p__46)
					else
						l__HumanoidRootPart__32.CFrame = CFrame.new(l__p__46, l__p__46 + l__HumanoidRootPart__32.CFrame.lookVector)
					end
				else
					l__HumanoidRootPart__32.CFrame = CFrame.new(l__p__46, l__p__46 + l__HumanoidRootPart__32.CFrame.lookVector)
				end
			end
		end	
	end
	task.wait(6)
	u4 = true
end
return v6