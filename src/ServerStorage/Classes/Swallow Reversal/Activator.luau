

local v1 = {}
local l__Parent__2 = script.Parent.Parent
function sub(...)
	coroutine.wrap(...)()
end
local l__TweenService__3 = game:GetService("TweenService")
local v4 = require(game.ServerScriptService.Modules.HitDetection)
en = true
local u2 = require(game.ServerScriptService.Modules.SamuraiModule)
local l__TagHumanoid__1 = game.ServerStorage.Requests.TagHumanoid
local l__TweenService__3 = game:GetService("TweenService");
local function u4(p1, p2, p3, p4, p5, p6, p7, p8)
	for v4, v5 in next, p5 do
		if v5:FindFirstChild("Humanoid") and v5:FindFirstChild("HumanoidRootPart") and v5 ~= p1 and not p4[v5] and (v5.HumanoidRootPart.Position - p2).magnitude <= p3 then
			if p7 == false then
				p4[v5] = true;
			end;
			task.spawn(function()
				l__TagHumanoid__1:Fire(p1, v5, p6);
				if p8 == true then
					wait(0.1);
					l__TagHumanoid__1:Fire(p1, v5, p6);
				end;
			end);
		end;
	end;
	return p4;
end;
function v1.Active(p9, p10, p11, p12) --p1, p2, p3, p4
	if u2.ActionCheck(p9) then
		return;
	end;
	if game.CollectionService:HasTag(p9, "Knocked") then
		return;
	end;
	if p9.Cooldowns:FindFirstChild("Swallow Reversal") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Swallow Reversal"
	CD.Value = 15
	CD.Parent = p9.Cooldowns
	game.Debris:AddItem(CD, 15)
	en = false;
	local v6 = u2.isCalm(p9);
	local l__HumanoidRootPart__7 = p9.HumanoidRootPart;
	local l__Humanoid__8 = p9.Humanoid;
	local v9 = l__Humanoid__8:LoadAnimation(script.Parent.Finisher);
	local v10 = l__Humanoid__8:LoadAnimation(script.Parent.BladeDance);
	local v11 = l__Humanoid__8:LoadAnimation(script.Parent.Windup);
	v11:Play();
	p9.HumanoidRootPart.SworderEmit:Emit(30);
	l__HumanoidRootPart__7.SwordCharge:Play();
	local v12 = Instance.new("Folder");
	v12.Name = "Action";
	v12.Parent = p9;
	game.Debris:AddItem(v12, 4);
	wait(0.1);
	local v13 = script.ChargeSound:Clone();
	game.Debris:AddItem(v13, 3);
	v13.Parent = l__HumanoidRootPart__7;
	v13:Play();
	local v14 = game.ReplicatedStorage.Assets.SwallowReversalKatana:Clone();
	game.Debris:AddItem(v14, 4);
	v14:ClearAllChildren();
	v14.Size = Vector3.new(v14.Size.X * 1.1, v14.Size.Y * 1.1, v14.Size.Z * 1.1);
	v14.Transparency = 1;
	v14.Parent = p9;
	local v15 = Instance.new("Weld", v14);
	v15.Part0 = v14;
	v15.Part1 = p9["Right Arm"];
	local v16 = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
	local v17 = l__TweenService__3:Create(v14, v16, {
		Transparency = 0.25
	}):Play();
	wait(0.2);
	u2.glint(p9);
	wait(0.3);
	v11:Stop();
	local v18 = 80;
	local l__CFrame__19 = l__HumanoidRootPart__7.CFrame;
	local v20 = RaycastParams.new();
	v20.IgnoreWater = true;
	v20.FilterType = Enum.RaycastFilterType.Exclude;
	v20.FilterDescendantsInstances = { workspace.Live, workspace.Thrown, workspace.Terrain, workspace.MonsterSpawns };
	local v21 = workspace:Raycast(l__CFrame__19.p, l__CFrame__19.LookVector * v18, v20);
	if v21 then
		v18 = (l__CFrame__19.p - v21.Position).Magnitude - 1;
	end;
	local v22 = v18 / 85;
	local v23 = math.ceil(v18 / 8);
	local v24 = Instance.new("NumberValue");
	v24.Name = "Transparency";
	v24.Value = 1;
	v24.Parent = p9.Boosts;
	game.Debris:AddItem(v24, 3);
	local v25 = Instance.new("Folder", p9);
	v25.Name = "Immortal";
	game.Debris:AddItem(v25, v22 + 0.1);
	l__Humanoid__8.AutoRotate = false;
	local l__CFrame__26 = l__HumanoidRootPart__7.CFrame;
	game.ReplicatedStorage.Requests.KatanaSkillFX:FireAllClients("SwallowReversal", v6, l__HumanoidRootPart__7, p11, {
		distance = v18, 
		time = v22, 
		rootcf = l__CFrame__26
	});
	v10:Play(0.1, 1, 1.3);
	local u5 = {};
	local u6 = game.Workspace.Live:GetChildren();
	spawn(function()
		wait(0.2);
		local v27 = {
			damage = 7.5, 
			physical = true, 
			slash = true, 
			katana = true, 
			swallowrev = true, 
			noparry = true, 
			manabreaker = true,
			move = "Swallow Reversal"
		};
		local v28 = 8.5;
		local v29 = true;
		for v30 = 1, v23 do
			local v31 = l__CFrame__26 * CFrame.new(0, 0, -(8.25 * v30 - 8.25));
			if v30 == v23 then
				v28 = 10;
				v29 = false;
				v27.damage = 16;
				v31 = l__HumanoidRootPart__7.CFrame;
				wait(0.15);
			end;
			u5 = u4(p9, v31.p, v28, u5, u6, v27, true, v29);
			wait(v22 / v23);
		end;
	end);
	wait(v22);
	v10:Stop();
	v9:Play();
	wait(0.05);
	v24:Destroy();
	v25:Destroy();
	l__Humanoid__8.AutoRotate = true;
	local v32 = l__TweenService__3:Create(v14, v16, {
		Transparency = 1
	}):Play();
	game.Debris:AddItem(v14, 0.45);
	wait(0.05);
	local v33 = script.slica:Clone();
	game.Debris:AddItem(v33, 2.5);
	v33.Parent = l__HumanoidRootPart__7;
	v33:Play();
	wait(0.7);
	if v12 then
		v12:Destroy();
	end;
	wait(15);
	en = true;
end;
function v1.Active2(p12, p13, p14, p15)
	if u2.ActionCheck(p12) then
		return;
	end;
	if game.CollectionService:HasTag(p12, "Knocked") then
		return;
	end;
	if p12.Cooldowns:FindFirstChild("Swallow Reversal") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Swallow Reversal"
	CD.Value = 15
	CD.Parent = p12.Cooldowns
	game.Debris:AddItem(CD, 15)
	en = false;
	local v34 = u2.isCalm(p12);
	local v35 = p12.Humanoid:LoadAnimation(script.Parent.M2Anim);
	v35:Play();
	local v36 = Instance.new("Folder");
	v36.Name = "Action";
	v36.Parent = p12;
	game.Debris:AddItem(v36, 1.5);
	v35:GetMarkerReachedSignal("pause"):Connect(function()
		v35:AdjustSpeed(0);
		wait(0.2);
		u2.glint(p12);
		wait(0.2);
		v35:AdjustSpeed(1);
	end);
	local u7 = nil;
	local l__HumanoidRootPart__8 = p12.HumanoidRootPart;
	local u9 = true;
	v35:GetMarkerReachedSignal("swing"):Connect(function()
		u7 = l__HumanoidRootPart__8.CFrame;
		l__HumanoidRootPart__8.HeavySlash:Play();
		local v37 = Instance.new("BodyVelocity");
		game.CollectionService:AddTag(v37, "AllowedBM");
		v37.Name = "BodyVelocity";
		v37.MaxForce = Vector3.new(80000, 80000, 80000);
		v37.Velocity = l__HumanoidRootPart__8.CFrame.lookVector.unit * 250;
		v37.Parent = l__HumanoidRootPart__8;
		game.Debris:AddItem(v37, 0.15);
		sub(function()
			wait(0.2);
			u9 = false;
		end);
		local l__SwallowTrail__38 = p15:FindFirstChild("SwallowTrail");
		if l__SwallowTrail__38 then
			l__SwallowTrail__38.Enabled = true;
		end;
		local u10 = 0;
		while u10 < 2 do
			wait()
			sub(function()
				local v40 = p15:Clone();
				v40.PropWeld:Destroy();
				v40.CanCollide = false;
				v40.Material = Enum.Material.Neon;
				v40.Color = Color3.fromRGB(170, 85, 255);
				v40.Parent = workspace.Thrown;
				game.Debris:AddItem(v40, 3);
				local v41 = Instance.new("Weld");
				v41.Parent = v40;
				v41.Part0 = l__HumanoidRootPart__8;
				v41.part1 = v40;
				while u9 do
					local l__CFrame__42 = l__HumanoidRootPart__8.CFrame;
					v41.C1 = (l__CFrame__42 * CFrame.Angles(0, 0, math.rad(120 * u10)) * p15.CFrame:toObjectSpace(l__CFrame__42):inverse()):ToObjectSpace(l__HumanoidRootPart__8.CFrame);
					wait();				
				end;
				if l__SwallowTrail__38 then
					l__SwallowTrail__38.Enabled = false;
				end;
				v41:Destroy();
				v40.Anchored = true;
				l__TweenService__3:Create(v40, TweenInfo.new(1), {
					Transparency = 1
				}):Play();
			end);
			u10 += 1;		
		end;
		wait();
		local v43 = {
			damage = p15.Stats.Damage.Value + 15, 
			physical = true, 
			slash = true, 
			katana = true, 
			blockbreak = true, 
			noparry = v34, 
			manabreaker = v34, 
			swallowrev = true,
			move = "Swallow Reversal"
		};
		local v44 = p15.Stats.Length.Value + 50;
		local v45 = p15.Stats.Length.Value + 5;
		for v46, v47 in pairs(workspace.Live:GetChildren()) do
			if v47 ~= p12 then
				local v48 = u7:inverse() * v47.HumanoidRootPart.CFrame;
				if v48.Z < 5 and -v44 < v48.Z and math.abs(v48.X) < v45 and math.abs(v48.Y) < v45 then
					local v49 = workspace:Raycast(u7.p, CFrame.new(u7.p, v47.HumanoidRootPart.Position).LookVector * v44);
					if v49 and not v49.Instance:IsDescendantOf(workspace.Map) then
						l__TagHumanoid__1:Fire(p12, v47, v43);
						for v50 = 1, 3 do
							u2.slash(v47);
						end;
					end;
				end;
			end;
		end;
	end);
	wait(15);
	en = true;
end;
return v1;
