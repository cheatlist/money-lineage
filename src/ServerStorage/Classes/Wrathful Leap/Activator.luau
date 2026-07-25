-- Decompiled with the Synapse X Luau decompiler.

local v1 = {};
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;
local l__Parent__1 = script.Parent.Parent;
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge", "Stun", "ReturnStun", "Action", "Blocking", "SpellBlocking", "ActiveCast"},
		presentTagBlocks = {"Unconscious", "Knocked"},
	})
end
local v3 = tick();
local l__TweenService__4 = game:GetService("TweenService");
local u2 = true;
local u3 = require(game.ServerScriptService.Modules.HitDetection);
function v1.Active(p1, p2, p3, p4)
	if ActionCheck() then
		return;
	end;
	if game.CollectionService:HasTag(p1, "Knocked") then
		return;
	end;
	if p1.Cooldowns:FindFirstChild("Wrathful Leap") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Wrathful Leap"
	CD.Value = 15
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 15)
	local l__HumanoidRootPart__5 = p1.HumanoidRootPart;
	game.ReplicatedStorage.Requests.ClearDodgeVels:FireClient(p2);
	local v6 = p1.Humanoid:LoadAnimation(script.Parent.Animation);
	v6:Play();
	u2 = false;
	local v7 = nil;
	if not p4:FindFirstChild("AbyssTrail") then
		v7 = script.Parent.AbyssTrail:Clone();
		v7.Attachment0 = p4:WaitForChild("Attachment1");
		v7.Attachment1 = p4:WaitForChild("Attachment2");
		v7.Parent = p4;
	elseif p4:FindFirstChild("AbyssTrail") then
		v7 = p4:FindFirstChild("AbyssTrail");
	end;
	local u4 = false;
	v6.KeyframeReached:Connect(function(p5)
		if p5 == "slash" then
			v7.Enabled = true;
			v6:AdjustSpeed(0);
		end;
		if p5 == "wait" and not u4 then
			v6:AdjustSpeed(0);
		end;
		if p5 == "end" then
			v7.Enabled = false;
		end;
	end);
	local l__HumanoidRootPart__8 = p1.HumanoidRootPart;
	local v9 = Instance.new("Folder");
	v9.Name = "Action";
	v9.Parent = p1;
	local v10 = tick();
	local v11 = false;
	l__HumanoidRootPart__8.LeapHiss:Play();
	while true do
		if p1:FindFirstChild("Stun") then
			v11 = true;
		end;
		task.wait();
		if tick() - v10 > 0.3 then
			break;
		end;
		if v11 then
			break;
		end;	
	end;
	if v11 then
		v9:Destroy();
		v6:Stop();
		task.wait(10);
		u2 = true;
		return;
	end;
	local v12 = Instance.new("BodyVelocity");
	game.CollectionService:AddTag(v12, "AllowedBM");
	v12.Name = "WrathfulLeapBV";
	v12.MaxForce = Vector3.new(100000000, 100000000, 100000000);
	v12.Parent = p1.HumanoidRootPart;
	game.Debris:AddItem(v12, 0.5);
	local v13 = Instance.new("Folder");
	v13.Name = "Immortal";
	v13.Parent = p1;
	local v14 = Instance.new("Folder");
	v14.Name = "NoFall";
	v14.Parent = p1;
	local v15 = Instance.new("Folder");
	v15.Name = "TPSafe";
	v15.Parent = p1;
	local v16 = tick();
	local v17 = nil;
	while true do
		task.wait();
		if v12 and v12.Parent and tick() - v16 > 0.4 then
			v6:AdjustSpeed(1);
		end;
		if tick() - v16 > 0.75 then
			break;
		end;
		if not v12 then
			break;
		end;
		if not v12.Parent then
			break;
		end;	
	end;
	local v18, v19, v20 = workspace:FindPartOnRayWithIgnoreList(Ray.new(l__HumanoidRootPart__8.Position, l__HumanoidRootPart__8.CFrame.lookVector * 10 + Vector3.new(0, -10, 0)), { workspace.Live, workspace.Terrain, workspace.NPCs, workspace.Thrown, workspace.Destructibles, workspace.Ingredients, workspace.MonsterSpawns });
	if v18 and tick() - v16 > 0.25 then
		v17 = v19;
		l__HumanoidRootPart__8.CFrame = CFrame.new(v19) * (l__HumanoidRootPart__8.CFrame - l__HumanoidRootPart__8.Position);
	end;
	v12:Destroy();
	v6:AdjustSpeed(2);
	v13:Destroy();
	game.Debris:AddItem(v15, 1);
	game.Debris:AddItem(v14, 1.5);
	u4 = true;
	local v21 = game.ServerStorage.Assets.ARDORSMASH:Clone();
	if not v17 then
		local v22, v23, v24 = workspace:FindPartOnRayWithIgnoreList(Ray.new(l__HumanoidRootPart__8.Position, l__HumanoidRootPart__8.CFrame.lookVector * 10 + Vector3.new(0, -20, 0)), { workspace.Live, workspace.Terrain, workspace.NPCs, workspace.Thrown, workspace.Destructibles, workspace.Ingredients, workspace.MonsterSpawns });
		if v22 then
			v17 = v23;
		else
			v17 = (l__HumanoidRootPart__8.CFrame * CFrame.new(0, 0, -5)).p - Vector3.new(0, 20, 0);
		end;
	end;
	v21.Position = v17;
	v21.Parent = workspace.Thrown;
	v21.BLACK:Emit(25);
	v21.Boom:Play();
	u3.magnitudeCheck(p1, v21.Position, 20, {
		physical = true, 
		damage = 20, 
		knockback = true, 
		cursestack = true, 
		blockallsides = true,
		move = "Wrathful Leap",
		aoe = true
	}, false);
	task.wait(0.1);
	v7.Enabled = false;
	v6:Stop();
	task.wait(0.1);
	v9:Destroy();
	v21.BLACK.Enabled = false;
	game.Debris:AddItem(v21, 3);
	task.wait(10);
	u2 = true;
end;
return v1;
