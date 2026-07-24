local v2 = {}
local l__Parent__1 = script.Parent.Parent
function ActionCheck()
	if not l__Parent__1:FindFirstChild("Humanoid") then
		return true
	end
	if l__Parent__1:FindFirstChild("Charge") then
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
	if l__Parent__1:FindFirstChild("ActiveCast") then
		return true
	end
	if l__Parent__1:FindFirstChild("Unconscious")then
		return
	end
	if l__Parent__1:FindFirstChild("Knocked")then
		return
	end
	if l__Parent__1:FindFirstChild("Immortal") then
	else
		return
	end
	return true
end
local v3 = tick()
local u2 = true
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid
local l__TweenService__4 = game:GetService("TweenService")
local u5 = false
function v2.Active(p1, p2, p3, p4)
	if ActionCheck()then
		return
	end
	if p1:FindFirstChild("Knocked") then
		return
	end
	if p1.Cooldowns:FindFirstChild("Focus Slash") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Focus Slash"
	CD.Value = 15
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 15)
	local l__HumanoidRootPart__4 = p1.HumanoidRootPart
	local v5 = Instance.new("Accessory")
	v5.Name = "Action"
	Instance.new("Folder", v5).Name = "NoDelete"
	v5.Parent = p1
	game.Debris:AddItem(v5, 0.85)
	u2 = false
	local v6 = nil
	local v27 = p1.Humanoid:LoadAnimation(script.Parent.Animation)
	p1.HumanoidRootPart.MoneyCharge:Play()
	p1.HumanoidRootPart.FlourishParticles:Emit(10)
	v27:Play(0.1, 1, 1.5)
	local v10 = {}
	local attacked = false

	v27:GetMarkerReachedSignal("Handle"):Connect(function()
		l__HumanoidRootPart__4.Sonido.TimePosition = 0.5
		l__HumanoidRootPart__4.Sonido:Play()
		local v28 = l__HumanoidRootPart__4.FlourishParticles:Clone()
		v28.Parent = p1["Right Leg"]
		v28:Emit(30)
		game.Debris:AddItem(v28, 5)
		local v29 = Instance.new("NumberValue")
		v29.Name = "Transparency"
		v29.Value = 1
		v29.Parent = p1.Boosts
		game.Debris:AddItem(v29, 0.6)
		local v30 = Instance.new("Folder", p1)
		v30.Name = "Immortal"
		game.Debris:AddItem(v30, 0.6)
		local v31 = Instance.new("Folder", p1)
		v31.Name = "FallDamageBypass"
		game.Debris:AddItem(v31, 0.6)
		wait(0.5)
		if not p1:FindFirstChild("Stun")then
			if attacked then return end
			game.ReplicatedStorage.Requests.KatanaSkillFX:FireAllClients("windswirl", nil, l__HumanoidRootPart__4, nil);
			local l__CFrame__39 = l__HumanoidRootPart__4.CFrame;
			local v40 = RaycastParams.new();
			v40.IgnoreWater = true;
			v40.FilterType = Enum.RaycastFilterType.Exclude;
			v40.FilterDescendantsInstances = { workspace.Live, workspace.Thrown, workspace.Terrain, workspace.MonsterSpawns };
			local v37 = 29
			local v41 = workspace:Raycast(l__CFrame__39.p, l__CFrame__39.LookVector * v37, v40);
			local l__Value__36 = game.ServerStorage.PlayerData[p1.Name].LastName.Value;
			if v41 then
				v37 = (l__CFrame__39.p - v41.Position).Magnitude - 1;
			end;
			local Target = nil
			for v45, v46 in pairs(game.Workspace.Live:GetChildren()) do
				local v47 = game.ServerStorage.PlayerData:FindFirstChild(v46.Name) and game.ServerStorage.PlayerData[v46.Name].LastName.Value;
				if not v47 or v47 ~= l__Value__36 or l__Value__36 == "" and v46 ~= p4 then
					if v46:FindFirstChild("Knocked") or v46:FindFirstChild("Immortal") then continue end
					local v48 = l__HumanoidRootPart__4.CFrame:inverse() * v46.HumanoidRootPart.CFrame;
					if v48.Z < 5 and -(v37 + 6 - 5) < v48.Z and math.abs(v48.X) < 29 and math.abs(v48.Y) < 29 then
						Target = v46;
						break;
					end;
				end;	
			end;
			l__HumanoidRootPart__4.CFrame = l__HumanoidRootPart__4.CFrame * CFrame.new(0, 0, -v37);
			game.ReplicatedStorage.Requests.KatanaSkillFX:FireAllClients("dashline", false, l__HumanoidRootPart__4, nil, {
				from = l__HumanoidRootPart__4.Position
			});
			local v50 = p1.Humanoid:LoadAnimation(script.Parent.Animation2):Play()
			if Target then
				for v15 = 1,8 do
					if Target.Humanoid.Health <= 0 then
						break
					end
					if (l__HumanoidRootPart__4.Position - Target.HumanoidRootPart.Position).magnitude <= 30 then
						wait(0.075)
						l__TagHumanoid__3:Fire(p1, Target, {
							physical = true,
							damage = 3,
							sword = true, 
							slash = true, 
							noenchant = true,
							blockallsides = true,
							manabreaker = true,
							move = "Focus Slash"
						})
						local v16 = l__HumanoidRootPart__4.FocusSlash:Clone()
						v16.Parent = Target.Torso
						v16.A:Emit(3)
						v16.B:Emit(3)
						v16.C:Emit(3)

						--v16.CFrame = v52.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90)))
						--l__TweenService__4:Create(v16, TweenInfo.new(0.075, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						--	CFrame = v16.CFrame * CFrame.Angles(math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90))), 
						--	Transparency = 1
						--}):Play()
						game:GetService("Debris"):AddItem(v16, 0.5)
					end
				end
			end
			--[[
			if v52 then
				local v58 = Instance.new("Accessory")
				v58.Name = "Stun"
				v58.Parent = p1
				game.Debris:AddItem(v58, 0.8)
				v10[v52] = true;
				local v19 = Instance.new("Vector3Value");
				v19.Name = "TPSafe";
				v19.Parent = p1;
				game.ServerStorage.Debris:Fire(v19, 2);
				p1.HumanoidRootPart.CFrame = v52.HumanoidRootPart.CFrame * CFrame.new(3,0,0);
				p1.Boosts:FindFirstChild("Transparency"):Destroy()
				local v50 = p1.Humanoid:LoadAnimation(script.Parent.Animation2):Play()
				attacked = true
				for v15 = 1,8 do
					if v52.Humanoid.Health <= 0 then
						break
					end
					if (l__HumanoidRootPart__4.Position - v52.HumanoidRootPart.Position).magnitude <= 30 then
						wait(0.075)
						l__TagHumanoid__3:Fire(p1, v52, {
							physical = true,
							damage = 3,
							sword = true, 
							slash = true, 
							noenchant = true,
							blockallsides = true,
							manabreaker = true,
							move = "Focus Slash"
						})
						local v16 = l__HumanoidRootPart__4.FocusSlash:Clone()
						v16.Parent = v52.Torso
						v16.A:Emit(3)
						v16.B:Emit(3)
						v16.C:Emit(3)

						--v16.CFrame = v52.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90)))
						--l__TweenService__4:Create(v16, TweenInfo.new(0.075, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						--	CFrame = v16.CFrame * CFrame.Angles(math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90))), 
						--	Transparency = 1
						--}):Play()
						game:GetService("Debris"):AddItem(v16, 0.5)
					end
				end
			end;]]
		end
	end)
	u5 = false
	wait(15)
	u2 = true
end
return v2