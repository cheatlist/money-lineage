local v1 = {};
v1.upperbound = 100;
v1.lowerbound = 20;
v1.signs = 5;
v1.cost = 0;
local l__Lifesteal__1 = game.ServerStorage.SpellEffects.Lifesteal;
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;
local l__TweenService__3 = game:GetService("TweenService");
function v1.Activate(p1, p2, p3, p4)
	if game.CollectionService:HasTag(p2, "Casting") or p2:FindFirstChild("ActiveCast") then
		return;
	end;
	if p3 ~= 0 then
		local v5 = l__Lifesteal__1.BackfireBrick:Clone();
		l__TagHumanoid__2:Fire(p2, p2, {
			mana = true, 
			manablockbreak = true, 
			curse = true, 
			curseeffect = true, 
			damage = 20, 
			bloodhex = true, 
			manaknockupself = true,
			move = "Furantur"
		});
		v5.CFrame = p2.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(90), math.rad(-90));
		v5.Parent = workspace.Thrown;
		game:GetService("Debris"):AddItem(v5, 1);
		p2.HumanoidRootPart.Backfire:Play();
		l__TweenService__3:Create(v5, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Size = Vector3.new(10, 4.5, 10), 
			Transparency = 1
		}):Play();
		return;
	end;
	local l__Mana__2 = p2.Mana;
	local v3 = game.Players:GetPlayerFromCharacter(p2);
	if p2:FindFirstChild("EndCast") then
		return;
	end;
	game.ReplicatedStorage.Requests.StopSprint:FireClient(v3);
	local v6 = Instance.new("Accessory");
	v6.Name = "ActiveCast";
	v6.Parent = p2;
	l__Mana__2.Value = math.max(l__Mana__2.Value - v1.cost, 0);
	local v7 = Instance.new("IntValue");
	v7.Name = "SpeedBoost";
	v7.Value = -12;
	v7.Parent = p2.Boosts;
	p2.HumanoidRootPart.PerfectCast:Play();
	local v8 = l__Lifesteal__1.HandBall:Clone();
	v8.Parent = workspace.Thrown;
	local v9 = p2.Humanoid:LoadAnimation(script.RightPoint);
	if p4 then
		v9 = p2.Humanoid:LoadAnimation(script.BookPoint);
	end;
	v9:Play();
	local v10 = l__Lifesteal__1.LifeSteal:Clone();
	v10.Parent = v8;
	local v11 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
	if not p4 then
		v11 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
	end;
	local u4 = Instance.new("Weld");
	local u5 = p2["Right Arm"];
	u4.Name = "Weld";
	u4.Part0 = u5;
	u4.Part1 = v8;
	u4.C1 = v11;
	u4.Parent = v8;
	local l__HumanoidRootPart__12 = p2.HumanoidRootPart;
	local v14 = nil;
	local v15 = {
		mana = true, 
		damage = 1, 
		nostun = true, 
		noenchant = true,
		nododge = true,
		closemana = true,
		undead = true,
		move = "Furantur"
	};
	local v16 = l__Lifesteal__1.LifestealBeam:Clone();
	local v17 = Instance.new("Attachment");
	v17.Position = Vector3.new(0, 0, 0);
	v17.Name = "LifestealAttach";
	local v18 = {};
	for Indx: number, NPC in ipairs(workspace.Live:GetChildren())do
		local MonsterI = NPC:FindFirstChild'MonsterInfo'
		if MonsterI and MonsterI.Master.Value == p2 then
			v18[NPC] = true
		end
	end
	local v24 = l__Lifesteal__1.HandBall.PointLight:Clone();
	game.Debris:AddItem(v16, 17);
	game.Debris:AddItem(v17, 17);
	game.Debris:AddItem(v10, 17);
	game.Debris:AddItem(v24, 17);
	local v25: number = 0;
	while true do
		if not v14 then
			local v26: number?;
			local v27: number = math.rad(15);
			local l__lookVector__28: Vector3 = l__HumanoidRootPart__12.CFrame.LookVector;
			local l__Position__29: Vector3 = l__HumanoidRootPart__12.Position;
			local v30 = {};
			for v31, v32 in ipairs(workspace.Live:children()) do
				if v32 ~= p2 and v32:IsA("Model") and not v32:FindFirstChild("MonsterInfo") then
					local v33 = v32 and v32:FindFirstChild("Humanoid");
					local v34 = v33 and v33.RootPart;
					if v34 then
						local v35 = v34.Position - l__Position__29;
						if math.acos(l__lookVector__28:Dot(v35.unit)) <= v27 and v35.magnitude < 40 then
							local l__Data__36 = game.ServerStorage.PlayerData[v3.Name];
							local v37 = game.ServerStorage.PlayerData:FindFirstChild(v32.Name);
							if v37 then
								if v3.leaderstats.LastName.Value == "" or v3.leaderstats.LastName.Value ~= v37.LastName.Value then
									table.insert(v30, v32);
								end;
							elseif v32:FindFirstChild("MonsterInfo") and v32.MonsterInfo.Master.Value ~= p2 then
								table.insert(v30, v32);
							end;
						end;
					end;
				end;
			end;
			for _: number, v39 in ipairs(v30) do
				local l__Magnitude__40: number = (v39.HumanoidRootPart.Position - l__HumanoidRootPart__12.Position).Magnitude;
				if not v14 or v14 and l__Magnitude__40 < v26 then
					v14 = v39;
					v26 = l__Magnitude__40;
				end;
			end;
			if v14 then
				v17.Parent = v14.HumanoidRootPart;
				v16.Parent = v8;
				v16.Attachment0 = v8.Attachment;
				v16.Attachment1 = v17;
				v24.Parent = v14.HumanoidRootPart;
				v10:Play();
				for v41, v42 in pairs(v18)do
					if v41 and v41.Parent and v41 ~= v14 then
						local v43 = Instance.new("Attachment");
						v43.Position = Vector3.new(0, 0, 0);
						v43.Name = "LifestealAttach";
						v43.Parent = v41.HumanoidRootPart;
						local v44 = l__Lifesteal__1.HandBall.PointLight:Clone();
						v44.Name = "LifestealLight";
						v44.Parent = v41.HumanoidRootPart;
						local v45 = l__Lifesteal__1.LifestealBeam:Clone();
						v45.Attachment0 = v8.Attachment;
						v45.Attachment1 = v43;
						v45.Parent = v8;
					else
						v18[v41] = nil;
					end;
				end;
			end;
		else
			l__TagHumanoid__2:Fire(p2, v14, v15);
			if not p2:FindFirstChild("NoHeal") then
				p2.Humanoid.Health += 1;
			end;
			for v46, v47 in pairs(v18)do
				if v46 ~= v14 and v46.Parent and v46:FindFirstChild("Humanoid") and v46.Humanoid.Health > 0 then
					if not v46:FindFirstChild("NoHeal") then
						v46.Humanoid.Health += 1;
					end;
				else
					v18[v46] = nil;
				end;
			end;
		end;
		local v48: boolean = true;
		if not (p2.Mana.Value <= 0) then
			v48 = p2:FindFirstChild("EndCast") or (p2:FindFirstChild("Stun") or p2:FindFirstChild("Knocked") or p2:FindFirstChild("Unconscious"));
		end;
		v25 += wait(0.05);
		if v48 or not(p2:IsDescendantOf(workspace))then
			break;
		end;
		if v25 >= 15 then
			break;
		end;
	end;
	for v49, v50 in pairs(v18)do
		if v49 and v49.Parent and v49:FindFirstChild("HumanoidRootPart") then
			local l__LifestealLight__6 = v49.HumanoidRootPart:FindFirstChild("LifestealLight");
			local l__LifestealAttach__7 = v49.HumanoidRootPart:FindFirstChild("LifestealAttach");
			if l__LifestealLight__6 then
				l__LifestealLight__6:Destroy();
			end;
			if l__LifestealAttach__7 then
				l__LifestealAttach__7:Destroy();
			end;
		end;
	end;
	v6:Destroy();
	v7:Destroy();
	v8.OrbParticle.Enabled = false;
	v24.Enabled = false;
	v9:Stop();
	v8.PointLight.Enabled = false;
	wait(1.5);
	u4:Destroy();
	v8:Destroy();
	v17:Destroy();
	v24:Destroy();
end;
function v1.Deactivate(p5, p6, p7)
	local v51 = Instance.new("Accessory");
	v51.Name = "EndCast";
	v51.Parent = p6;
	game:GetService("Debris"):AddItem(v51, 0.3);
end;
return v1;