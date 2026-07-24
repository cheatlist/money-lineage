

local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local l__TweenService__2 = game:GetService("TweenService");
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid;
v1.upperbound = 100;
v1.lowerbound = 50;
v1.signs = 0;
v1.cost = 100;
function v1.Activate(p1, p2, p3, p4)
	if game.CollectionService:HasTag(p2, "Casting") or p2:FindFirstChild("ActiveCast") then
		return;
	end;
	local l__Mana__4 = p2.Mana;
	local v5 = game.Players:GetPlayerFromCharacter(p2);
	local l__Value__6 = v5.Backpack.ManaColor.Value;
	if p3 ~= 0 or not (not p2:FindFirstChild("DomCD")) or not (not p2:FindFirstChildOfClass("ForceField")) then
		p2.HumanoidRootPart.Diffusion:Play();
		if p4 and p4:FindFirstChild("Backfire") then
			p4.Backfire.Color = ColorSequence.new(Color3.new(l__Value__6.r, l__Value__6.g, l__Value__6.b));
			p4.Backfire:Emit(15);
		end;
		return;
	end;
	if p2:FindFirstChild("EndCast") then
		return;
	end;
	game.ReplicatedStorage.Requests.StopSprint:FireClient(v5);
	if p2:FindFirstChild("Charge") then
		p2.Charge:Destroy()
		end
	game.CollectionService:AddTag(p2, "TempStop")
	p2.Mana.Value = 0
	game.CollectionService:RemoveTag(p2, "TempStop")
	
	local v7 = Instance.new("Folder", p2);
	v7.Name = "DomCD";
	game.Debris:AddItem(v7, 20);
	p2.Humanoid:LoadAnimation(script.Snap):Play();
	wait(0.2);
	local v8 = game.ReplicatedStorage.Assets.HandHoldIllusion:Clone();
	v8.IllusionArm.Enabled = false;
	v8.Parent = game.Workspace.Thrown;
	v8.Snap:Play();
	v8.IllusionSnap:Emit(100);
	local v9 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
	if not p4 then
		v9 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
	end;
	local u1 = Instance.new("Weld");
	local u2 = p2["Right Arm"];
	sub(function()
		u1.Name = "Weld";
		u1.Part0 = u2;
		u1.Part1 = v8;
		u1.Parent = v8;
		u1.C1 = v9;
		wait(1);
		v8:Destroy();
	end);
	local v10 = nil;
	local v11 = nil;
	local v12 = nil;
	for v13, v14 in pairs(game.Players:children()) do
		local v15 = game.ServerStorage.PlayerData:FindFirstChild(v14.Name);
		if v15 and v14 ~= v5 and v14.Character and v14.Character.Parent == workspace.Live then
			local l__Character__16 = v14.Character;
			if l__Character__16:FindFirstChild("HumanoidRootPart") and (not game.CollectionService:HasTag(l__Character__16, "Unconscious") and not l__Character__16:FindFirstChild("NoControl") and not l__Character__16:FindFirstChildOfClass("ForceField")) then
				local l__Magnitude__17 = (l__Character__16.HumanoidRootPart.Position - p2.HumanoidRootPart.Position).Magnitude;
				if l__Magnitude__17 < 20 and (not v11 or v11 and l__Magnitude__17 < v12) then
					v11 = l__Character__16;
					v12 = l__Magnitude__17;
					v10 = v15;
				end;
			end;
		end;
	end;
	if v11 then
		local v18 = game.ReplicatedStorage.Assets.HandHoldIllusion.PointLight:Clone();
		v18.Parent = v11.HumanoidRootPart;
		game.Debris:AddItem(v18, 7);
		if not v10 or v10.Alignment.Value < 0 then
			local v19 = Instance.new("Accessory");
			v19.Name = "NoControl";
			v19.Parent = v11;
			game.Debris:AddItem(v19, 7);
			local v20 = Instance.new("ObjectValue");
			v20.Name = "AttackExcept";
			v20.Value = v5;
			v20.Parent = v11;
			game.Debris:AddItem(v20, 7);
		else
			local v21 = Instance.new("Accessory");
			v21.Name = "NoControl";
			v21.Parent = v11;
			game.Debris:AddItem(v21, 4);
		end;
	end;
end;
return v1;
