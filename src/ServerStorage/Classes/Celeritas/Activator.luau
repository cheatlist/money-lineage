local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local l__TweenService__2 = game:GetService("TweenService");
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid;
v1.upperbound = 90;
v1.lowerbound = 70;
v1.signs = 5;
v1.cost = 0;
local v4 = {
	upperbound = 80, 
	lowerbound = 70, 
	signs = 0, 
	cost = 20
};
local l__SpeedUp__1 = game.ServerStorage.SpellEffects.SpeedUp;
function v1.Activate(p1, p2, p3, p4)
	if game.CollectionService:HasTag(p2, "Casting") or p2:FindFirstChild("ActiveCast") then
		return;
	end;
	local l__Mana__5 = p2.Mana;
	local v6 = game.Players:GetPlayerFromCharacter(p2);
	local l__Value__7 = v6:FindFirstChildOfClass("Backpack").ManaColor
	if p3 ~= 0 then
		if p3 == 1 then
			local v8 = Instance.new("IntValue");
			v8.Name = "SpeedBoost";
			v8.Value = -12;
			v8.Parent = p2.Boosts;
			local v9 = Instance.new("NumberValue");
			v9.Name = "AttackSpeedBoost";
			v9.Value = 0.75;
			v9.Parent = p2.Boosts;
			local v10 = l__SpeedUp__1.Sound:Clone();
			v10.Parent = p2.HumanoidRootPart;
			v10:Play();
			local v11 = l__SpeedUp__1.Particle:Clone();
			v11.Parent = p2.Torso;
			game.Debris:AddItem(v8, 10);
			game.Debris:AddItem(v9, 10);
			game.Debris:AddItem(v10, 10);
			game.Debris:AddItem(v11, 10);
			sub(function()
				wait(9);
				v11.Enabled = false;
			end);
			return;
		else
			p2.HumanoidRootPart.Diffusion:Play();
			if p4 and p4:FindFirstChild("Backfire") then
				p4.Backfire.Color = ColorSequence.new(Color3.new(l__Value__7.r, l__Value__7.g, l__Value__7.b));
				p4.Backfire:Emit(15);
			end;
			return;
		end;
	end;
	if p2:FindFirstChild("EndCast") then
		return;
	end;
	game.ReplicatedStorage.Requests.StopSprint:FireClient(v6);
	local v12 = Instance.new("Accessory");
	v12.Name = "ActiveCast";
	v12.Parent = p2;
	l__Mana__5.Value = math.max(l__Mana__5.Value - v1.cost, 0);
	local v13 = Instance.new("IntValue");
	v13.Name = "SpeedBoost";
	v13.Value = -12;
	v13.Parent = p2.Boosts;
	p2.HumanoidRootPart.PerfectCast:Play();
	local v14 = game.ServerStorage.Assets.HandHoldSpeed:Clone();
	v14.Parent = game.Workspace.Thrown;
	local v15 = p2.Humanoid:LoadAnimation(script.RightPoint);
	if p4 then
		v15 = p2.Humanoid:LoadAnimation(script.BookPoint);
	end;
	v15:Play();
	local v16 = l__SpeedUp__1.Sound:Clone();
	v16.Parent = v14;
	v16:Play();
	local v17 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
	if not p4 then
		v17 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
	end;
	local u2 = Instance.new("Weld");
	local u3 = p2["Right Arm"];
	sub(function()
		u2.Name = "Weld";
		u2.Part0 = u3;
		u2.Part1 = v14;
		u2.Parent = v14;
		u2.C1 = v17;
	end);
	local l__HumanoidRootPart__18 = p2.HumanoidRootPart;
	if not p2:FindFirstChild("EndCast") and not p2:FindFirstChild("Stun") and not game.CollectionService:HasTag(p2, "Knocked") then
		local v19 = game.CollectionService:HasTag(p2, "Unconscious");
	end;
	local v20 = nil;
	local v21 = Instance.new("IntValue");
	v21.Name = "SpeedBoost";
	v21.Value = 7;
	game:GetService("Debris"):AddItem(v21, 20);
	local v22 = Instance.new("NumberValue");
	v22.Name = "AttackSpeedBoost";
	v22.Value = 6;
	game:GetService("Debris"):AddItem(v22, 20);
	local v23 = l__SpeedUp__1.Particle:Clone();
	game:GetService("Debris"):AddItem(v23, 20);
	while true do
		if not v20 then
			local v24 = nil;
			local v25 = math.rad(15);
			local l__lookVector__26 = l__HumanoidRootPart__18.CFrame.lookVector;
			local l__Position__27 = l__HumanoidRootPart__18.Position;
			local v28 = {};
			for v29, v30 in pairs(workspace.Live:children()) do
				if v30 ~= p2 and v30:IsA("Model") then
					local v31 = v30 and v30:FindFirstChild("Humanoid");
					local v32 = v31 and v31.RootPart;
					if v32 then
						local v33 = v32.Position - l__Position__27;
						if math.acos(l__lookVector__26:Dot(v33.unit)) <= v25 and v33.magnitude < 40 then
							local l__Data__34 = game.ServerStorage.PlayerData[v6.Name]
							local v35 = game.ServerStorage.PlayerData:FindFirstChild(v30.Name);
							if v35 and (l__Data__34.LastName.Value == "" or l__Data__34.LastName.Value == v35.LastName.Value) then
								table.insert(v28, v30);
							end;
						end;
					end;
				end;
			end;
			for v36, v37 in pairs(v28) do
				local l__Magnitude__38 = (v37.HumanoidRootPart.Position - l__HumanoidRootPart__18.Position).Magnitude;
				if not v20 or v20 and l__Magnitude__38 < v24 then
					v20 = v37;
					v24 = l__Magnitude__38;
				end;
			end;
			if v20 then
				v21.Parent = v20.Boosts;
				v22.Parent = v20.Boosts;
				v23.Parent = v20.Torso;
			end;
		else
			local v39 = math.min(1.25, math.max(0.75, (v20.HumanoidRootPart.Position - l__HumanoidRootPart__18.Position).Magnitude / 50));
			v21.Value = 7 * v39;
			v22.Value = 6 * v39;
		end;
		local v40 = true;
		if not (p2.Mana.Value <= 0) then
			v40 = p2:FindFirstChild("EndCast") or (p2:FindFirstChild("Stun") or (game.CollectionService:HasTag(p2, "Knocked") or game.CollectionService:HasTag(p2, "Unconscious")));
		end;
		wait();
		if v40 then
			break;
		end;	
	end;
	sub(function()
		v21:Destroy();
		v22:Destroy();
		v12:Destroy();
		v13:Destroy();
		v14.OrbParticle.Enabled = false;
		v15:Stop();
		v23.Enabled = false;
		v14.PointLight.Enabled = false;
		wait(1.5);
		v23:Destroy();
		u2:Destroy();
		v14:Destroy();
	end);
end;
function v1.Deactivate(p5, p6, p7)
	local v41 = Instance.new("Accessory");
	v41.Name = "EndCast";
	v41.Parent = p6;
	game:GetService("Debris"):AddItem(v41, 2);
end;

-- snap

function v4.Activate(p8, p9, p10, p11, p12)
	if game.CollectionService:HasTag(p9, "Casting") then
		return;
	end;
	if not p12[script.Parent.Name] and p9.Name ~= "Ragoozer" then
		return;
	end;
	local l__Mana__42 = p9.Mana;
	local v43 = game.Players:GetPlayerFromCharacter(p9);
	local v44 = v43 and game.ServerStorage.PlayerData:FindFirstChild(v43.Name);
	local v45 = v44 and v43:FindFirstChildOfClass("Backpack").ManaColor
	local u4 = _G.MouseData(v43);
	if not u4 then
		return;
	end;
	local v46 = v45 and p9:FindFirstChild("HumanoidRootPart");
	if not v46 then
		return;
	end;
	local l__Humanoid__47 = p9:FindFirstChild("Humanoid");
	if not l__Humanoid__47 or not (not l__Humanoid__47.SeatPart) or l__Humanoid__47.Sit then
		return;
	end;
	local l__CFrame__48 = v46.CFrame;
	local l__p__49 = u4.Hit.p;
	if (l__p__49 - v46.Position).magnitude > 600 then
		return;
	end;
	if not workspace:FindPartOnRayWithIgnoreList(Ray.new(l__CFrame__48.p, Vector3.new(0, -10, 0)), { workspace.AreaMarkers, workspace.MonsterSpawns, workspace.Live }) then
		return;
	end;
	if p10 == 0 then
		p9.HumanoidRootPart.PerfectCast:Play();
		p9.Humanoid:LoadAnimation(script.Snap):Play();
		wait(0.2);
		if (l__p__49 - v46.Position).magnitude > 600 then
			return;
		end;
		local v50 = game.ReplicatedStorage.Assets.HandHoldCeleri:Clone();
		v50.IllusionArm.Enabled = false;
		v50.Parent = game.Workspace.Thrown;
		v50.Snap:Play();
		v50.IllusionSnap:Emit(100);
		local v51 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
		if not p11 then
			v51 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
		end;
		local u5 = Instance.new("Weld");
		local u6 = p9["Right Arm"];
		sub(function()
			u5.Name = "Weld";
			u5.Part0 = u6;
			u5.Part1 = v50;
			u5.Parent = v50;
			u5.C1 = v51;
			wait(1);
			v50:Destroy();
		end);
		local v52 = nil;
		local v53 = 10;
		for v54, v55 in pairs(game.Workspace.Live:GetChildren()) do
			local l__HumanoidRootPart__56 = v55:FindFirstChild("HumanoidRootPart");
			if l__HumanoidRootPart__56 and (l__HumanoidRootPart__56.Position - l__p__49).magnitude <= 10 and (l__HumanoidRootPart__56.Position - l__p__49).magnitude < v53 and v55 ~= p9 and not v55:FindFirstChild("Immortal") and not v55:FindFirstChildOfClass("ForceField") then
				v53 = (v55.Torso.Position - l__p__49).magnitude;
				v52 = v55;
			end;
		end;
		if v52 then
			p9.HumanoidRootPart.Spark:Play();
			if v52.HumanoidRootPart:FindFirstChild("Spark") then
				v52.HumanoidRootPart.Spark:Play();
			end;
			p9.HumanoidRootPart.CelerParticle:Emit(60);
			if v52.HumanoidRootPart:FindFirstChild("CelerParticle") then
				v52.HumanoidRootPart.CelerParticle:Emit(60);
			end;
			local v57 = Instance.new("Vector3Value");
			v57.Name = "TPSafe";
			v57.Value = v52.Torso.Position;
			v57.Parent = p9;
			game.Debris:AddItem(v57, 3);
			local v58 = Instance.new("Vector3Value");
			v58.Name = "TPSafe";
			v58.Value = l__CFrame__48.p;
			v58.Parent = v52;
			game.Debris:AddItem(v58, 3);
			p9.Torso.CFrame = v52.Torso.CFrame;
			if v52.Name ~= "Ragoozer" then
				v52.Torso.CFrame = l__CFrame__48;
			end;
		end;
	else
		p9.HumanoidRootPart.Diffusion:Play();
		if p11 and p11:FindFirstChild("Backfire") then
			p11.Backfire.Color = ColorSequence.new(Color3.new(v45.r, v45.g, v45.b));
			p11.Backfire:Emit(15);
		end;
	end;
end;
v1.alternate = v4;
return v1;
