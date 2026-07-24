

local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local l__TweenService__2 = game:GetService("TweenService");
v1.upperbound = 85;
v1.lowerbound = 70;
v1.signs = 3;
v1.cost = 0;
local v3 = {
	upperbound = 85, 
	lowerbound = 70, 
	signs = 0, 
	cost = 20
};
local l__FireWhip__4 = game.ServerStorage.SpellEffects.FireWhip;
local l__TagHumanoid__1 = game.ServerStorage.Requests.TagHumanoid;
function v1.Activate(p1, p2, p3, p4)
	if game.CollectionService:HasTag(p2, "Casting") or p2:FindFirstChild("ActiveCast") then
		return;
	end;
	local l__Mana__5 = p2.Mana;
	local v6 = game.Players:GetPlayerFromCharacter(p2);
	local l__Value__7 = v6.Backpack.ManaColor.Value;
	if p3 ~= 0 then
		if p3 ~= 0 then
			l__TagHumanoid__1:Fire(p2, p2, {
				mana = true, 
				curse = true, 
				torture = true, 
				manaknockupself = true,
				damage = 10,
				move = "Nocere"
			});
		end;
		return;
	end;
	if p2:FindFirstChild("EndCast") then
		return;
	end;
	game.ReplicatedStorage.Requests.StopSprint:FireClient(v6);
	local v8 = Instance.new("Accessory");
	v8.Name = "ActiveCast";
	v8.Parent = p2;
	l__Mana__5.Value = math.max(l__Mana__5.Value - v1.cost, 0);
	local v9 = Instance.new("IntValue");
	v9.Name = "SpeedBoost";
	v9.Value = -12;
	v9.Parent = p2.Boosts;
	p2.HumanoidRootPart.PerfectCast:Play();
	local v10 = game.ReplicatedStorage.Assets.HandHoldTorture:Clone();
	v10.Parent = game.Workspace.Thrown;
	local v11 = p2.Humanoid:LoadAnimation(script.RightPoint);
	if p4 then
		v11 = p2.Humanoid:LoadAnimation(script.BookPoint);
	end;
	v11:Play();
	v10.Hit:Play();
	local v12 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
	if not p4 then
		v12 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
	end;
	local u2 = Instance.new("Weld");
	local u3 = p2["Right Arm"];
	sub(function()
		u2.Name = "Weld";
		u2.Part0 = u3;
		u2.Part1 = v10;
		u2.Parent = v10;
		u2.C1 = v12;
	end);
	local l__HumanoidRootPart__13 = p2.HumanoidRootPart;
	local v14 = p2:FindFirstChild("EndCast") or (p2:FindFirstChild("Stun") or p2:FindFirstChild("Knocked") or p2:FindFirstChild("Unconscious"));
	while p2.Mana.Value > 0 and not v14 and p2.Parent do
		wait();
		local v15 = math.rad(15);
		local l__lookVector__16 = l__HumanoidRootPart__13.CFrame.lookVector;
		local l__Position__17 = l__HumanoidRootPart__13.Position;
		local v18 = {};
		for v19, v20 in pairs(workspace.Live:children()) do
			if v20 ~= p2 and v20:IsA("Model") then
				local v21 = v20 and v20:FindFirstChild("Humanoid");
				local v22 = v21 and v21.RootPart;
				if v22 and not v20:FindFirstChild("Stun") and not v20:FindFirstChild("NoDam") and not v20:FindFirstChild("TortureCooldown") then
					local l__Position__23 = v22.Position;
					local v24 = l__Position__23 - l__Position__17;
					if math.acos(l__lookVector__16:Dot(v24.unit)) <= v15 then
						if v24.magnitude < 15 then
							table.insert(v18, v20);
						end;
					elseif (l__Position__23 - l__Position__17).magnitude < 2 then
						table.insert(v18, v20);
					end;
				end;
			end;
		end;
		for v25, v26 in pairs(v18) do
			if v26:FindFirstChild("Unconscious") then
				while v26 ~= nil and p2.Mana.Value > 0 and not p2:FindFirstChild("EndCast") and not p2:FindFirstChild("Stun") do
					p2.Humanoid:LoadAnimation(script.Parent["FlickAnim" .. math.random(1, 4)]):Play();
					l__TagHumanoid__1:Fire(p2, v26, {
						mana = true, 
						damage = 10, 
						downbypass = true, 
						curse = true, 
						torture = true,
						noenchant = true,
						move = "Nocere"
					});
					local v27 = Instance.new("Accessory");
					v27.Name = "TortureCooldown";
					v27.Parent = v26;
					game:GetService("Debris"):AddItem(v27, 0.5);
					wait(1);				
				end;
			end;
		end;
		v14 = p2:FindFirstChild("EndCast") or (p2:FindFirstChild("Stun") or p2:FindFirstChild("Knocked") or p2:FindFirstChild("Unconscious"));	
	end;
	sub(function()
		v8:Destroy();
		v9:Destroy();
		v10.OrbParticle.Enabled = false;
		v11:Stop();
		v10.Hit:Stop();
		v10.PointLight.Enabled = false;
		wait(1.5);
		u2:Destroy();
		v10:Destroy();
	end);
end;
function v1.Deactivate(p5, p6, p7)
	local v28 = Instance.new("Accessory");
	v28.Name = "EndCast";
	v28.Parent = p6;
	game:GetService("Debris"):AddItem(v28, 0.5);
end;
function v3.Activate(p8, p9, p10, p11, p12)
	if game.CollectionService:HasTag(p9, "Casting") then
		return;
	end;
	if not p12[script.Parent.Name] and p9.Name ~= "Ragoozer" then
		return;
	end;
	local l__Mana__29 = p9.Mana;
	local v30 = game.Players:GetPlayerFromCharacter(p9);
	local v31 = v30 and game.ServerStorage.PlayerData:FindFirstChild(v30.Name);
	if not v31 or not v30.Backpack.ManaColor.Value or not p9:FindFirstChild("HumanoidRootPart") then
		return;
	end;
	local l__Value__32 = v31.Class.Value
	local v34 = true;
	if not table.find(_G.MageClasses, l__Value__32) then if not v30.Backpack:FindFirstChild("CurseAllow") then return end end
	
	if p10 ~= 0 or not v34 then
		l__TagHumanoid__1:Fire(p9, p9, {
			mana = true, 
			curse = true, 
			torture2 = true,
			noenchant = true,
			move = "Nocere"
		});
		return;
	end;
	p9.HumanoidRootPart.PerfectCast:Play();
	p9.Humanoid:LoadAnimation(script.Snap):Play();
	wait(0.2);
	local v35 = game.ReplicatedStorage.Assets.HandHoldTorture2:Clone();
	v35.IllusionArm.Enabled = false;
	v35.Parent = game.Workspace.Thrown;
	v35.Snap:Play();
	v35.IllusionSnap:Emit(100);
	local v36 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
	if not p11 then
		v36 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
	end;
	local u4 = Instance.new("Weld");
	local u5 = p9["Right Arm"];
	sub(function()
		u4.Name = "Weld";
		u4.Part0 = u5;
		u4.Part1 = v35;
		u4.Parent = v35;
		u4.C1 = v36;
		wait(1);
		v35:Destroy();
	end);
	local v37 = nil;
	local v38 = 15;
	for v39, v40 in pairs(game.Workspace.Live:GetChildren()) do
		local l__magnitude__41 = (v40.Torso.Position - p9.Torso.Position).magnitude;
		if l__magnitude__41 <= v38 and v40 ~= p9 and v40:FindFirstChild("Mana") and v40.Mana.Value <= 0 and (not v40:FindFirstChild("Knocked") and not v40:FindFirstChild("InjuryCooldown")) then
			v37 = v40;
			v38 = l__magnitude__41;
		end;
	end;
	if v37 ~= nil then
		game.ServerStorage.Requests.Wakeup:Fire(v37, true);
		local v42 = Instance.new("Accessory");
		v42.Name = "Action";
		v42.Parent = v37;
		local v43 = Instance.new("Accessory");
		v43.Name = "FlightOk";
		v43.Parent = v37;
		local v44 = Instance.new("Accessory");
		v44.Name = "Immortal";
		v44.Parent = v37;
		local v45 = Instance.new("IntValue");
		v45.Name = "ActionManaBypass";
		v45.Parent = v37;
		local v46 = Instance.new("IntValue");
		v46.Name = "NODAMAGE";
		v46.Parent = v37;
		v37.Humanoid.AutoRotate = false;
		v37.HumanoidRootPart.Torture:Play();
		v37.Humanoid:LoadAnimation(script.Parent.SnapAnim1):Play();
		local u6 = v37.Humanoid:LoadAnimation(script.Parent.SnapAnim2);
		sub(function()
			wait(1);
			u6:Play();
		end);
		local v47 = 0;
		sub(function()
			while v45 ~= nil do
				wait();
				if v37:FindFirstChild("ClimbCoolDown") then
					v37.ClimbCoolDown:Destroy();
				end;			
			end;
		end);
		task.spawn(function()
		while true do
			if v37:FindFirstChild("Mana") then
				if v37.Mana.Value >= 80 then
					break;
				end;
				if v37.Humanoid.Health <= 10 then
					break;
				end;
				if v37:FindFirstChild("ContrariumTag") then
					break;
				end;
				if v47 >= 10 then
					break;
				end;
				if v37:FindFirstChild("Knocked") then
					break;
				end;
			end;
			wait(2);
			v47 = v47 + 1;
			l__TagHumanoid__1:Fire(p9, v37, {
			    --damage = 1, 
				mana = true, 
				downbypass = true, 
				curse = true, 
				torture2 = true,
				noenchant = true,
				move = "Nocere"
			});
			if v37.Mana.Value >= 80 then
				break;
			end;
			if v37.Humanoid.Health <= 10 then
				break;
			end;
			if v47 >= 10 then
				break;
			end;
			if v37:FindFirstChild("Knocked") then
				break;
			end;		
		end;
		v37.Humanoid.AutoRotate = true;
		u6:Stop();
		v37.HumanoidRootPart.Torture:Stop();
		v45:Destroy();
		v43:Destroy();
		v42:Destroy();
		v46:Destroy();
			v44:Destroy();
		end)
	end;
end;
v1.alternate = v3;
return v1;
