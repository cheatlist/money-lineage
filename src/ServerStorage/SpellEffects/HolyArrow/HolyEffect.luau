local module = {}
local l__Parent__1 = script.Parent;
function sub(...)
	coroutine.wrap(...)();
end;
function module.hitEffect(character,hit,info,stun,checkvamp)

	game.ServerStorage.Requests.TagHumanoid:Fire(character,hit,info)
	local v1 = game.ServerStorage.Assets.ArrowImpact:Clone()
	v1.Parent = character.HumanoidRootPart
	v1:Play()
	game.Debris:AddItem(v1,2)
	if hit and hit:FindFirstChild("HumanoidRootPart") then
	local v2 = script.Parent.ParticleEmitter:Clone()
	v2.Parent = hit.HumanoidRootPart
	v2.Enabled = true
	v2:Emit(1)
		game.Debris:AddItem(v2,2)
		end
end
local u4 = { workspace.Live, workspace.Terrain, workspace.Thrown, workspace.MonsterSpawns, workspace.AreaMarkers };
local u5 = {
	damage = 10, 
	sunlight = 25, 
	mana = true,
	move = "Telorum"
};

local l__TweenService__3 = game:GetService("TweenService");
function module.impactEffect(p6, p7)
	sub(function()
		local v4 = l__Parent__1.HolyCross:Clone();
		v4.CFrame = p6;
		v4.Parent = workspace.Thrown;
		game.Debris:AddItem(v4, 0.5);
		l__TweenService__3:Create(v4.PointLight, TweenInfo.new(0.25), {
			Range = p7 * 1.5
		}):Play();
		for v5, v6 in pairs(v4:GetChildren()) do
			if v6:IsA("Attachment") then
				l__TweenService__3:Create(v6, TweenInfo.new(0.25), {
					Position = v6.Position * p7
				}):Play();
			elseif v6:IsA("Beam") then
				l__TweenService__3:Create(v6, TweenInfo.new(0.25), {
					Width0 = v6.Width0 * p7
				}):Play();
			end;
		end;
		wait(0.25);
		l__TweenService__3:Create(v4.PointLight, TweenInfo.new(0.25), {
			Range = 0
		}):Play();
		for v7, v8 in pairs(v4:GetChildren()) do
			if v8:IsA("Beam") then
				l__TweenService__3:Create(v8, TweenInfo.new(0.25), {
					Width0 = 0
				}):Play();
			end;
		end;
	end);
end;
function swordDrop(p8, p9)
	sub(function()
		local v9 = Vector3.new(p8.HumanoidRootPart.Position.X, p9.Y, p8.HumanoidRootPart.Position.Z);
		local v10
		if v9 == p9 then
			v10 = CFrame.new(v9);
		else
			v10 = CFrame.new(v9, p9);
		end;
		local v11 = v10 * CFrame.new(0, 40, -(v9 - p9).Magnitude) * CFrame.Angles(0, 1.5707963267948966, 1.5707963267948966);
		local l__Position__12 = v11.Position;
		local v13, v14, v15 = game.Workspace:FindPartOnRayWithIgnoreList(Ray.new(l__Position__12, CFrame.new(l__Position__12, v11.Position + Vector3.new(0, -1, 0)).lookVector * 100), u4);
		if not v13 then
			return;
		end;
		local v16 = l__Parent__1.HolySword:Clone();
		game.Debris:AddItem(v16, 4);
		v16.CFrame = v11;
		v16.Transparency = 1;
		v16.Parent = workspace.Thrown;
		l__TweenService__3:Create(v16, TweenInfo.new(1.5), {
			Transparency = 0
		}):Play();
		l__TweenService__3:Create(v16.PointLight, TweenInfo.new(1.5), {
			Range = 10
		}):Play();
		v16.Sound:Play();
		local v17 = (v16.Position.Y - v14.Y) / 100;
		l__TweenService__3:Create(v16, TweenInfo.new(v17, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
			Position = v14 + Vector3.new(0, v16.Size.X / 2, 0)
		}):Play();
		wait(v17);
		l__TweenService__3:Create(v16, TweenInfo.new(v16.Size.X / 100, Enum.EasingStyle.Linear), {
			Position = v16.Position + Vector3.new(0, -v16.Size.X, 0)
		}):Play();
		local v18 = v16.CFrame * CFrame.Angles(math.rad(v16.Orientation.X), 0, 4.71238898038469) * CFrame.new(0, -v16.Size.X / 2, 0);
		module.impactEffect(v18, 12.5);
		local v19, v20, v21 = pairs(workspace.Live:GetChildren());
		while true do
			local v22, v23 = v19(v20, v21);
			if v22 then

			else
				break;
			end;
			v21 = v22;
			if (v23.HumanoidRootPart.Position - v18.Position).Magnitude < 12.5 then
				module.hitEffect(p8, v23, u5, 0, false);
			end;		
		end;
		l__TweenService__3:Create(v16, TweenInfo.new(0.1), {
			Transparency = 1
		}):Play();
		l__TweenService__3:Create(v16.PointLight, TweenInfo.new(0.1), {
			Range = 0
		}):Play();
	end);
end;
function module.illuminate(p10, p11)
	if (p10.HumanoidRootPart.Position - p11).Magnitude > 500 then
		return;
	end;
	for v24 = 1, 3 do
		local v25 = math.rad(math.random(-15, 15) + v24 * 120);
		swordDrop(p10, (Vector3.new(p11.X + 7.5 * math.cos(v25), p11.Y, p11.Z + 7.5 * math.sin(v25))));
		wait(0.1);
	end;
end;
function module.snapEffect(p12, p13)
	p12.HumanoidRootPart.PerfectCast:Play();
	p12.Humanoid:LoadAnimation(script.Snap2):Play();
	local v26 = game.ReplicatedStorage.Assets.HandHoldLight:Clone();
	v26.Parent = game.Workspace.Thrown;
	v26.Snap:Play();
	l__TweenService__3:Create(v26.PointLight, TweenInfo.new(0.25), {
		Range = 8
	}):Play();
	local v27 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, 3.141592653589793);
	if not p13 then
		v27 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, 3.141592653589793);
	end;
	local u6 = Instance.new("Weld");
	local u7 = p12["Right Arm"];
	sub(function()
		u6.Name = "Weld";
		u6.Part0 = u7;
		u6.Part1 = v26;
		u6.Parent = v26;
		u6.C1 = v27;
		wait(1);
		v26:Destroy();
	end);
	wait(0.25);
	l__TweenService__3:Create(v26.PointLight, TweenInfo.new(0.25), {
		Range = 0
	}):Play();
end;
return module