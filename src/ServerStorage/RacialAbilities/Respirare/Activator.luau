

local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local l__TweenService__2 = game:GetService("TweenService");
v1.upperbound = 100;
v1.lowerbound = 0;
v1.signs = 0;
v1.cost = 55;
local l__FireWhip__1 = game.ServerStorage.SpellEffects.FireWhip;
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;
function v1.Activate(p1, p2, p3, p4)
	if p2:FindFirstChild("Grabbed") then
		return;
	end;
	if p2:FindFirstChild("Grabbing") then
		return;
	end;
	if game.CollectionService:HasTag(p2, "Casting") or p2:FindFirstChild("ActiveCast") then
		return;
	end;
	local l__Mana__3 = p2.Mana;
	local v4 = game.Players:GetPlayerFromCharacter(p2);
	if p3 ~= 0 then
		if p3 ~= 0 then
			local v6 = l__FireWhip__1.BackfireBrick:Clone();
			v6.CFrame = p2.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(90), math.rad(-90));
			v6.Parent = game.Workspace.Thrown;
			v6.ParticleEmitter:Emit(30);
			v6.Hit:Play();
			game:GetService("Debris"):AddItem(v6, 1.5);
			l__TagHumanoid__2:Fire(p2, p2, {
				mana = true, 
				manaknockupself = true, 
				burn = true, 
				curse = true, 
				damage = 20,
				noenchant = true
			});
			local l__HumanoidRootPart__7 = p2.HumanoidRootPart;
			l__HumanoidRootPart__7.Backfire:Play();
			local v8, v9, v10 = pairs(game.Workspace.Live:GetChildren());
			while true do
				local v11, v12 = v8(v9, v10);
				if not v11 then
					break;
				end;
				local v13 = v12:IsA("Model") and v12 or nil;
				if v13 and v13:FindFirstChild("Humanoid") and v13:FindFirstChild("HumanoidRootPart") and v13 ~= p2 and (l__HumanoidRootPart__7.Position - v13.HumanoidRootPart.Position).magnitude <= 10 then
					l__TagHumanoid__2:Fire(p2, p2, {
						mana = true, 
						damage = 10, 
						manaselfknockback = true, 
						firepoison = true,
						noenchant = true
					});
				end;			
			end;
		end;
		return;
	end;
	if p2:FindFirstChild("EndCast") then
		return;
	end;
	game.ReplicatedStorage.Requests.StopSprint:FireClient(v4);
	local v14 = Instance.new("Accessory");
	v14.Name = "ActiveCast";
	v14.Parent = p2;
	l__Mana__3.Value = math.max(l__Mana__3.Value - v1.cost, 0);
	local v15 = Instance.new("IntValue");
	v15.Name = "SpeedBoost";
	v15.Value = -14;
	v15.Parent = p2.Boosts;
	p2.HumanoidRootPart.PerfectCast:Play();
	local v16 = l__FireWhip__1.BurnSpell:Clone();
	v16.Parent = game.Workspace.Thrown;
	local v17 = p2.Humanoid:LoadAnimation(script.Breathe);
	p2.Humanoid:LoadAnimation(script.BreathCharge):Play();
	local l__HumanoidRootPart__18 = p2.HumanoidRootPart;
	local v19 = script.Start:clone();
	v19.Parent = l__HumanoidRootPart__18;
	v19:Play();
	wait(0.5);
	v17:Play();
	v16.Hit:Play();
	local attachC1 = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-90), 0, 0);
	local u3 = Instance.new("Weld");
	local l__Head__4 = p2.Head;
	sub(function()
		u3.Name = "Weld";
		u3.Part0 = l__Head__4;
		u3.Part1 = v16;
		u3.Parent = v16;
		u3.C0 = attachC1;
	end);
	local v21 = p2:FindFirstChild("EndCast") or (p2:FindFirstChild("Stun") or (game.CollectionService:HasTag(p2, "Knocked") or game.CollectionService:HasTag(p2, "Unconscious")));
	while p2.Mana.Value > 0 and not v21 and p2.Parent do
		wait();
		local v22 = math.rad(15);
		local l__lookVector__23 = l__HumanoidRootPart__18.CFrame.lookVector;
		local l__Position__24 = l__HumanoidRootPart__18.Position;
		local v25 = {};
		for v26, v27 in pairs(workspace.Live:children()) do
			if v27 ~= p2 and v27:IsA("Model") then
				local v28 = v27 and v27:FindFirstChild("Humanoid");
				local v29 = v28 and v28.RootPart;
				if v29 and not v27:FindFirstChild("Stun") and not v27:FindFirstChild("NoDam") then
					local l__Position__30 = v29.Position;
					local v31 = l__Position__30 - l__Position__24;
					if math.acos(l__lookVector__23:Dot(v31.unit)) <= v22 then
						if v31.magnitude < 20 then
							table.insert(v25, v27);
						end;
					elseif (l__Position__30 - l__Position__24).magnitude < 2 then
						table.insert(v25, v27);
					end;
				end;
			end;
		end;
		for v32, v33 in pairs(v25) do
			local v34 = {
				mana = true, 
				damage = 10, 
				manaknockup = true, 
				curse = true, 
				burn = true,
				noenchant = true
			};
			if v33:FindFirstChild("Burning") and not v33:FindFirstChild("MonsterInfo") then
				v34.manaknockup = nil;
			end;
			if not v33:FindFirstChild("BurnCooldown2") then
				l__TagHumanoid__2:Fire(p2, v33, v34);
			end
			if not v33:FindFirstChild("BurnCooldown2") then
			local v35 = Instance.new("Accessory");
			v35.Name = "BurnCooldown2";
			v35.Parent = v33;
			game:GetService("Debris"):AddItem(v35, 1);
			local v36 = Instance.new("Accessory");
			v36.Name = "NoStun";
			v36.Parent = v33;
				game:GetService("Debris"):AddItem(v36, 1);
				end
		end;
		local v37 = p2:FindFirstChild("EndCast") or (p2:FindFirstChild("Stun") or (game.CollectionService:HasTag(p2, "Knocked") or game.CollectionService:HasTag(p2, "Unconscious")));
		v21 = v37;	
	end;
	sub(function()
		v14:Destroy();
		v15:Destroy();
		v16.ParticleEmitter.Enabled = false;
		v17:Stop();
		v19:Destroy();
		wait(1.5);
		u3:Destroy();
		v16:Destroy();
	end);
end;
function v1.Deactivate(p5, p6, p7)
	local v38 = Instance.new("Accessory");
	v38.Name = "EndCast";
	v38.Parent = p6;
	game:GetService("Debris"):AddItem(v38, 0.3);
end;
return v1;
