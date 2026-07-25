local v1 = {};
v1.upperbound = 65;
v1.lowerbound = 50;
v1.signs = 6;
v1.cost = 40;
local function radrandom(p1, p2)
	return math.rad(math.random(p1, p2));
end;
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
		healthBelow = 1,
	})
end
local function nowalkthrough(p3)
	for Indx, Obj in ipairs(p3:GetDescendants())do
		if Obj:IsA'BasePart'then
			game:GetService("PhysicsService"):SetPartCollisionGroup(Obj, "WalkThrough");
		end
	end
end;
local RCP: RaycastParams = RaycastParams.new()
RCP.FilterDescendantsInstances = {workspace.Map, workspace.Thrown}
RCP.FilterType = Enum.RaycastFilterType.Whitelist
RCP.IgnoreWater = true
local l__Orion__1 = game.ServerStorage.SpellEffects.Orion;
local l__TweenService__2 = game:GetService("TweenService");
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid;
function v1.Activate(p4, p5, p6, p7)
	if game.CollectionService:HasTag(p5, "Casting") then
		return;
	end;
	local l__Mana__8 = p5.Mana;
	local v9 = game.Players:GetPlayerFromCharacter(p5);
	local v10 = game.ServerStorage.PlayerData:FindFirstChild(v9.Name);
	local l__HumanoidRootPart__12 = p5:FindFirstChild'HumanoidRootPart';
	if not l__HumanoidRootPart__12 then
		return warn("Sagitta Sol no HumanoidRootPart")
	end
	local l__Value__13 = v10.LastName.Value;
	local v14: number = 0;
	for v15, v16 in ipairs(workspace.Thrown:GetChildren()) do
		if v16.Name == "Orion" then
			local l__HumanoidRootPart__17 = v16:FindFirstChild("HumanoidRootPart");
			if l__HumanoidRootPart__17 and (l__HumanoidRootPart__17.Position - l__HumanoidRootPart__12.Position).Magnitude < 250 then
				local l__Caster__18 = v16:FindFirstChild("Caster");
				local v19 = l__Caster__18 and game.ServerStorage.PlayerData:FindFirstChild(l__Caster__18.Value);
				local v20 = v19 and v19.LastName.Value;
				if v20 == "" and v19 == v10 or v20 ~= "" and v20 == l__Value__13 then
					v14 += 1;
				end;
			end;
		end;
	end;
	if v14 >= 1 then
		return
	end;
	local v22 = workspace:Raycast(l__HumanoidRootPart__12.Position, Vector3.new(0, -7, 0), RCP)
	if not v22 or not v22.Instance then
		return
	end;
	local v21: CFrame = l__HumanoidRootPart__12.CFrame * CFrame.new(8, 0, 0);
	if p6 == 0 then
		local v28 = l__Orion__1.Ray:Clone();
		game.Debris:AddItem(v28, 30);
		v28.Mesh.Scale = Vector3.new(1, 0, 0);
		v28.CFrame = v21 * CFrame.new(0, 5.5, 0) * CFrame.Angles(0, 0, math.rad(90));
		v28.Parent = workspace;
		local v29 = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
		v28.Sound:Play();
		l__TweenService__2:Create(v28.Mesh, v29, {
			Scale = Vector3.new(1, 0.8, 0.8)
		}):Play();
		task.wait(0.2);
		local v31 = l__Orion__1.Orion:Clone();
		local OrionHRP = v31:WaitForChild('HumanoidRootPart', 12)
		if not OrionHRP then
			v31:Destroy()
			return
		end
		game.Debris:AddItem(v31, 27);
		task.spawn(function()
			task.wait(26.7);
			if v31:IsDescendantOf(workspace)then
				v28.Sound:Play();
				l__TweenService__2:Create(v28.Mesh, v29, {
					Scale = Vector3.new(1, 0.8, 0.8)
				}):Play();
				task.wait(0.2);
				l__TweenService__2:Create(v28.Mesh, v29, {
					Scale = Vector3.new(1, 0, 0)
				}):Play();
			end;
			game.Debris:AddItem(v28, 0.5);
		end);
		v31:WaitForChild("Caster").Value = v9.Name;
		v31:PivotTo(v21);
		local v34 = l__Orion__1.Holder:Clone();
		v34.MaxForce = Vector3.new(math.huge, math.huge, math.huge);
		v34.Position = OrionHRP.Position;
		v34.Parent = OrionHRP;
		v31.Parent = workspace.Thrown;
		nowalkthrough(v31);
		l__TweenService__2:Create(v28.Mesh, v29, {
			Scale = Vector3.new(1, 0, 0)
		}):Play();
		local v36 = v31.Humanoid:LoadAnimation(l__Orion__1.PullShoot);
		local u6: boolean = false;
		v31.ChildAdded:Connect(function(p12)
			if p12.Name == "ContrariumTag" then
				if u6 then
					while true do
						task.wait();
						if not u6 then
							break;
						end;					
					end;
				end;
				v28.Sound:Play();
				l__TweenService__2:Create(v28.Mesh, v29, {
					Scale = Vector3.new(1, 0.8, 0.8)
				}):Play();
				task.wait(0.2);
				l__TweenService__2:Create(v28.Mesh, v29, {
					Scale = Vector3.new(1, 0, 0)
				}):Play();
				v31:Destroy();
				v31 = nil;
			end;
		end);
		task.wait(1);
		task.spawn(function()
			local v40: number = 0;
			while v31:IsDescendantOf(workspace)and OrionHRP.Parent do
				local Now: number = tick()
				if Now - v40 > 1.9 then
					v40 = Now
					local v42;
					local CurrentDist: number = 101
					for _: number, NPC in ipairs(workspace.Live:GetChildren())do
						local HRP = NPC:FindFirstChild('HumanoidRootPart')
						local Hum = NPC:FindFirstChild('Humanoid')
						if HRP and Hum and Hum.Health > 0 then
							local PD = game.ServerStorage.PlayerData:FindFirstChild(NPC.Name)
							if PD then
								if PD.LastName.Value == l__Value__13 and PD.LastName.Value ~= "" then
									continue
								end
							end
							if NPC.Name == p5.Name then
								continue
							end
							local Mag: number = (HRP.Position - OrionHRP.Position).Magnitude
							if Mag <= CurrentDist then
								v42 = NPC
								CurrentDist = Mag
							end
						end
					end
					if v42 then
						u6 = true;
						v31.Torso.CFrame = CFrame.new(OrionHRP.Position, Vector3.new(v42.HumanoidRootPart.Position.X, v42.HumanoidRootPart.Position.Y, v42.HumanoidRootPart.Position.Z));
						v36:Play();
						task.wait(0.3);
						OrionHRP.PullString:Play();
						task.wait(0.3);
						OrionHRP.FireArrow:Play();
						task.spawn(function()
							local v52 = l__Orion__1.Arrow:Clone();
							game.Debris:AddItem(v52, 10);
							local v53 = CFrame.new(OrionHRP.Position, v42.HumanoidRootPart.Position);
							v52.CFrame = v53 * CFrame.new(0, 0, -4);
							v52.BodyVelocity.Velocity = v53.LookVector * 200;
							v52.Parent = workspace;
							local u7;
							local u8 = {};
							u7 = v52.Touched:Connect(function(p13)
								if not p13.Parent then
									return
								end
								if p13.Parent == v31 then 
									return;
								end
								if p13.Parent.Name == "Shadow Buddy" then
									return;
								end;
								if p13.Anchored and p13.CanCollide and p13.Transparency ~= 1 then
									u7:Disconnect();
									v52.ArrowWall:Play();
									v52.BodyVelocity.Velocity = Vector3.new(0, 0, 0);
									v52.Velocity = Vector3.new(0, 0, 0);
									v52.Anchored = true;
								end;
								local v54 = p13.Parent:FindFirstChild("Humanoid") or p13.Parent.Parent:FindFirstChild("Humanoid")
								if v54 and v54.Parent ~= p5 and not u8[v54.Parent.Name] and not v54.Parent:FindFirstChild("SpellParry") then
									v52.ArrowHit:Play();
									u8[v54.Parent.Name] = true;
									l__TagHumanoid__3:Fire(p5, v54.Parent, {
										mana = true, 
										damage = 12, 
										lightarrow = true, 
										hitpart = p13,
										move = "Sagitta Sol"
									});
									v52.Transparency = 1;
									u7:Disconnect();
								end;
							end);
						end);
						u6 = false;
					end;
				end;
				task.wait(.5);
			end;
		end)
	else
		if l__Mana__8.Value - v1.cost <= 0 then
			l__Mana__8.Value = 0;
		else
			l__Mana__8.Value -= v1.cost;
		end;
		local v55 = {
			mana = true, 
			damage = 23, 
			manaknockupself = 45, 
			lightarrow = true,
			move = "Sagitta Sol"
		};
		l__TagHumanoid__3:Fire(p5, p5, v55);
	end;
end;
local v2 = {
	upperbound = 60, 
	lowerbound = 50, 
	signs = 0, 
	cost = 100,
}
local u11 = true
local HitDetect = require(game.ServerScriptService.Modules.HitDetection)
function v2.Activate(p8, p9, p10, p11, p12)
	if game.CollectionService:HasTag(p9, "Casting") then
		return
	end
	local hit = nil
	if not p12[script.Parent.Name] then
		return
	end
	if ActionCheck(p9) then
		return
	end
	local Mana = p9.Mana
	local Player = game.Players:GetPlayerFromCharacter(p9)
	local Action = Instance.new("Accessory")
	Action.Name = "Action"
	Action.Parent = p9
	game.Debris:AddItem(Action,0.2)
	Mana.Value = math.max(Mana.Value - v2.cost, 0)
	if p10 ~= 0 then
		if p10 == 1 then
			l__TagHumanoid__3:Fire(p9, p9, {
				mana = true, 
				damage = 23, 
				manaknockupself = 45, 
				lightarrow = true, 
				manadisarm = true, 
				disarm = true,
				move = "Sagitta Sol"
			})
			return
		else
			p9.HumanoidRootPart.Diffusion:Play()
			if p11 and p11:FindFirstChild("Backfire") then
				p11.Backfire:Emit(15)
			end
			return
		end
	end
	p9.HumanoidRootPart.PerfectCast:Play()
	p9.Humanoid:LoadAnimation(script.Snap):Play()
	task.wait(0.2)
	local HandHoldSag = game.ReplicatedStorage.Assets.HandHoldSag:Clone()
	HandHoldSag.IllusionArm.Enabled = false
	HandHoldSag.Parent = game.Workspace.Thrown
	HandHoldSag.Snap:Play()
	HandHoldSag.IllusionSnap:Emit(100)
	local Angle = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, 3.141592653589793)
	if not p11 then
		Angle = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, 3.141592653589793)
	end
	local Weld = Instance.new("Weld")
	local RightArm = p9["Right Arm"]
	coroutine.wrap(function()
		Weld.Name = "Weld"
		Weld.Part0 = RightArm
		Weld.Part1 = HandHoldSag
		Weld.Parent = HandHoldSag
		Weld.C1 = Angle
		task.wait(1)
		HandHoldSag:Destroy()
	end)()
	local CF = CFrame.new(0, 0, -7)
	if not u11 then
		CF = CFrame.new(0, 0, -7)
	end
	u11 = not u11
	local v46 = p9.HumanoidRootPart.CFrame * CF
	local OrionRay = l__Orion__1.Ray:Clone()
	game.Debris:AddItem(OrionRay, 30)
	OrionRay.Mesh.Scale = Vector3.new(1, 0, 0)
	OrionRay.CFrame = v46 * CFrame.new(0, 5.5, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
	OrionRay.Parent = game.Workspace.Thrown
	local TweenInf = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	OrionRay.Sound:Play()
	local v49 = l__TweenService__2:Create(OrionRay.Mesh, TweenInf, {
		Scale = Vector3.new(1, 0.8, 0.8)
	}):Play()
	task.wait(0.2)
	l__TweenService__2:Create(OrionRay.Mesh, TweenInf, {
		Scale = Vector3.new(1, 0, 0)
	}):Play()
	local SwordOrion = l__Orion__1.SwordOrion:Clone()
	SwordOrion:WaitForChild("Caster").Value = Player.Name
	SwordOrion:SetPrimaryPartCFrame(v46)
	SwordOrion.Parent = game.Workspace.Thrown
	nowalkthrough(SwordOrion)
	SwordOrion.Humanoid:LoadAnimation(l__Orion__1.SwordAttack):Play()

	spawn(function()
		task.wait(0.75)
		if SwordOrion then
			OrionRay.Sound:Play()
			OrionRay.Position = SwordOrion.HumanoidRootPart.Position + Vector3.new(0, 5.5, 0)
			local v51 = l__TweenService__2:Create(OrionRay.Mesh, TweenInf, {
				Scale = Vector3.new(1, 0.8, 0.8)
			}):Play()
			task.wait(0.2)
			SwordOrion:Destroy()
			local OrionArrow = l__TweenService__2:Create(OrionRay.Mesh, TweenInf, {
				Scale = Vector3.new(1, 0, 0)
			}):Play()
		end
		game.Debris:AddItem(OrionRay, 0.5)
	end)
	l__TweenService__2:Create(SwordOrion.HumanoidRootPart, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		CFrame = SwordOrion.HumanoidRootPart.CFrame * CFrame.new(0, 0, -20)
	}):Play()
	local Info = {
		mana = true, 
		damage = 15, 
		disarm = true, 
		knockondisarm = 1, 
		manaknockup = true, 
		lightarrow = true, 
		manadisarm = true,
		move = "Sagitta Sol"
	}
	SwordOrion.Torso.SwordSlash:Play()
	local HitEnemy = tick()
	while true do
		hit = HitDetect.magnitudeCheck(p9, SwordOrion.HumanoidRootPart.Position, 12, Info, true)
		task.wait(0.05)
		if hit then
			break
		end
		if tick() - HitEnemy > 0.5 then
			break
		end	
	end
	if hit then
		SwordOrion.Torso.SwordHit:Play()
	end
	if SwordOrion and SwordOrion:FindFirstChild("Mythril Sword") then
		SwordOrion["Mythril Sword"].TestTrail.Enabled = false
	end
end
v1.alternate = v2
return v1;
