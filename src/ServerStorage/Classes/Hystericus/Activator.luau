
local cancel = false
local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local l__TweenService__2 = game:GetService("TweenService");
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid;
v1.upperbound = 90;
v1.lowerbound = 75;
v1.signs = 2;
v1.cost = 0;
local v4 = {
	upperbound = 35, 
	lowerbound = 15, 
	signs = 0, 
	cost = 100
};
local l__SpeedUp__5 = game.ServerStorage.SpellEffects.SpeedUp;
function v1.Activate(p1, p2, p3, p4)
	if game.CollectionService:HasTag(p2, "Casting") or p2:FindFirstChild("ActiveCast") then
		return;
	end;
	local l__Mana__6 = p2.Mana;
	local v7 = game.Players:GetPlayerFromCharacter(p2);
	local v8 = game.ServerStorage.PlayerData:FindFirstChild(v7.Name);
	if not v8 then
		return;
	end;
	local l__Value__9 = v7.Backpack.ManaColor.Value;
	if p3 ~= 0 then
		if p3 == 1 then
			local v10 = Instance.new("Accessory");
			v10.Name = "CamFlip";
			v10.Parent = p2;
			local v11 = Instance.new("Accessory");
			v11.Name = "Confused";
			v11.Parent = p2;
			local v12 = p2.Humanoid:LoadAnimation(script.Confused);
			v12:Play();
			v12:AdjustSpeed(0.35);
			local v13 = game.ReplicatedStorage.Assets.HandHoldIllusion.IllusionHead:Clone();
			v13.Parent = p2.Head;
			v13.Enabled = true;
			local v14 = game.ReplicatedStorage.Assets.HandHoldIllusion.Hit:Clone();
			v14.Parent = p2.Head;
			v14:Play();
			sub(function()
				wait(10);
				v11:Destroy();
				v14:Destroy();
				v10:Destroy();
				v13:Destroy();
				v12:Stop();
			end);
			return;
		else
			p2.HumanoidRootPart.Diffusion:Play();
			if p4 and p4:FindFirstChild("Backfire") then
				p4.Backfire.Color = ColorSequence.new(Color3.new(l__Value__9.r, l__Value__9.g, l__Value__9.b));
				p4.Backfire:Emit(15);
			end;
			return;
		end;
	end;
	if p2:FindFirstChild("EndCast") then
		return;
	end;
	local v15 = Instance.new("Accessory");
	v15.Name = "ActiveCast";
	v15.Parent = p2;
	l__Mana__6.Value = math.max(l__Mana__6.Value - v1.cost, 0);
	local v16 = Instance.new("IntValue");
	v16.Name = "SpeedBoost";
	v16.Value = -12;
	v16.Parent = p2.Boosts;
	p2.HumanoidRootPart.PerfectCast:Play();
	local v17 = game.ReplicatedStorage.Assets.HandHoldIllusion:Clone();
	game:GetService("Debris"):AddItem(v17, 70);
	v17.Parent = game.Workspace.Thrown;
	v17.Hit:Play();
	local v18 = p2.Humanoid:LoadAnimation(script.RightPoint);
	if p4 then
		v18 = p2.Humanoid:LoadAnimation(script.BookPoint);
	end;
	v18:Play();
	v18:AdjustSpeed(0.5);
	local v19 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
	if not p4 then
		v19 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
	end;
	local u1 = Instance.new("Weld");
	local u2 = p2["Right Arm"];
	sub(function()
		u1.Name = "Weld";
		u1.Part0 = u2;
		u1.Part1 = v17;
		u1.Parent = v17;
		u1.C1 = v19;
	end);
	local l__HumanoidRootPart__20 = p2.HumanoidRootPart;
	if not p2:FindFirstChild("EndCast") and not p2:FindFirstChild("Stun") and not game.CollectionService:HasTag(p2, "Knocked") then
		local v21 = game.CollectionService:HasTag(p2, "Unconscious");
	end;
	local v22 = nil;
	local v23 = Instance.new("Accessory");
	v23.Name = "Confused";
	local v24 = Instance.new("Accessory");
	v24.Name = "CamFlip";
	while true do
		if not v22 then
			local v25 = nil;
			local v26 = math.rad(15);
			local l__lookVector__27 = l__HumanoidRootPart__20.CFrame.lookVector;
			local l__Position__28 = l__HumanoidRootPart__20.Position;
			local v29 = {};
			for v30, v31 in pairs(workspace.Live:children()) do
				if v31 ~= p2 and v31:IsA("Model") then
					local v32 = v31 and v31:FindFirstChild("Humanoid");
					local v33 = v32 and v32.RootPart;
					if v33 then
						local v34 = v33.Position - l__Position__28;
						if math.acos(l__lookVector__27:Dot(v34.unit)) <= v26 and v34.magnitude < 40 then
							local l__Data__35 = game.ServerStorage.PlayerData[v7.Name];
							local v36 = game.ServerStorage.PlayerData:FindFirstChild(v31.Name);
							if v36 and (l__Data__35.LastName.Value == "" or l__Data__35.LastName.Value ~= v36.LastName.Value) then
								table.insert(v29, v31);
							end;
						end;
					end;
				end;
			end;
			for v37, v38 in pairs(v29) do
				local l__Magnitude__39 = (v38.HumanoidRootPart.Position - l__HumanoidRootPart__20.Position).Magnitude;
				if not v22 or v22 and l__Magnitude__39 < v25 then
					v22 = v38;
					v25 = l__Magnitude__39;
				end;
			end;
			if v22 then
				if p2:FindFirstChild("Unconscious") then
					return;
				end;
				if not game.ServerStorage.PlayerData:FindFirstChild(v22.Name) then
					return;
				end;
				if game.ServerStorage.PlayerData[v22.Name].Race.Value ~= "Dzin" and game.ServerStorage.PlayerData[v22.Name].Race.Value ~= "Lich" and not game.Players[v22.Name].Backpack:FindFirstChild("MentalBlock") then
					v24.Parent = v22;
					v23.Parent = v22;
					local v40 = v17.Hit:Clone();
					v40.Parent = v22.Head;
					v40:Play();
					local v41 = v17.IllusionHead:Clone();
					v41.Parent = v22.Head;
					v41.Enabled = true;
					local v42 = v22.Humanoid:LoadAnimation(script.Confused);
					v42:Play();
					v42:AdjustSpeed(0.35);
					sub(function()
						while v22 and v22 ~= nil and not cancel and p2.Mana.Value > 0 and not p2:FindFirstChild("Stun") and not p2:FindFirstChild("Action") and not p2:FindFirstChild("EndCast") do
							wait(0.5);						
						end;
						cancel = false
						v24:Destroy();
						v41:Destroy();
						v42:Stop();
						v40:Destroy();
					end);
				end;
			end;
		else
			local l__Magnitude__43 = (v22.HumanoidRootPart.Position - l__HumanoidRootPart__20.Position).Magnitude;
			local v44 = math.min(1.25, math.max(0.75, (v22.HumanoidRootPart.Position - l__HumanoidRootPart__20.Position).Magnitude / 50));
		end;
		local v45 = true;
		if (p2.Mana.Value > 0) then
			v45 = p2:FindFirstChild("EndCast") or (p2:FindFirstChild("Stun") or p2:FindFirstChild("Knocked") or p2:FindFirstChild("Unconscious"));
		elseif (p2.Mana.Value <= 0) then
			v16:Destroy();
			local u3 = v22;
			sub(function()
				u3 = nil;
				v23:Destroy();
				v15:Destroy();
				v18:Stop();
				v16:Destroy();
				v17.IllusionArm.Enabled = false;
				if p2:FindFirstChild("Action") then
					p2.Action:Destroy();
				end;
				v17.PointLight.Enabled = false;
				wait(1.5);
				u1:Destroy();
				v17:Destroy();
			end);
		end;
		wait();
		if v45 then
			v16:Destroy();
			local u3 = v22;
			sub(function()
				u3 = nil;
				v23:Destroy();
				v15:Destroy();
				v18:Stop();
				v16:Destroy();
				v17.IllusionArm.Enabled = false;
				if p2:FindFirstChild("Action") then
					p2.Action:Destroy();
				end;
				v17.PointLight.Enabled = false;
				wait(1.5);
				u1:Destroy();
				v17:Destroy();
			end);
			break;
		end;	
	end;
	
end;
function v1.Deactivate(p5, p6, p7)
	cancel = true
	local v46 = Instance.new("Accessory");
	v46.Name = "EndCast";
	v46.Parent = p6;
	game:GetService("Debris"):AddItem(v46, 0.4);
end;
local u4 = require(game.ServerScriptService.Modules.HitDetection);
function v4.Activate(p8, p9, p10, p11, p12)
	if game.CollectionService:HasTag(p9, "Casting") then
		return;
	end;
	local v47 = game.Players:GetPlayerFromCharacter(p9);
	if not p12[script.Parent.Name] and p9.Name ~= "Ragoozer" and not v47.Backpack:FindFirstChild("IllusionMastery") then
		return;
	end;
	local l__Mana__48 = p9.Mana;
	local v49 = v47 and game.ServerStorage.PlayerData:FindFirstChild(v47.Name);
	if not v49 or not v47.Backpack.ManaColor.Value or not p9:FindFirstChild("HumanoidRootPart") then
		return;
	end;
	local v52 = v47.Backpack:FindFirstChild("IllusionMastery")
	if p10 == 0 and v52 then
		sub(function()
			p9.HumanoidRootPart.PerfectCast:Play();
			p9.Humanoid:LoadAnimation(script.Snap):Play();
			wait(0.2);
			local v53 = game.ReplicatedStorage.Assets.HandHoldIllusion:Clone();
			v53.IllusionArm.Enabled = false;
			v53.Parent = game.Workspace.Thrown;
			v53.Snap:Play();
			v53.IllusionSnap:Emit(100);
			local v54 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
			if not p11 then
				v54 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
			end;
			local u5 = Instance.new("Weld");
			local u6 = p9["Right Arm"];
			sub(function()
				u5.Name = "Weld";
				u5.Part0 = u6;
				u5.Part1 = v53;
				u5.Parent = v53;
				u5.C1 = v54;
				wait(1);
				v53:Destroy();
			end);
			u4.aoeCombatTag(p9, p9.Torso.Position, 20);
			for v55, v56 in pairs(game.Workspace.Live:GetChildren()) do
				if (v56.Torso.Position - p9.HumanoidRootPart.Position).Magnitude <= 15 and v56 ~= p9 and (not v56:FindFirstChild("Unconscious") and not v56:FindFirstChild("Confused")  and (game.ServerStorage.PlayerData:FindFirstChild(v56.Name) and game.ServerStorage.PlayerData[v56.Name].Race.Value ~= "Dzin" and game.ServerStorage.PlayerData[v56.Name].Race.Value ~= "Lich") and not game.Players[v56.Name].Backpack:FindFirstChild("MentalBlock")) then
					local v57 = game.ServerStorage.PlayerData[v56.Name];
					if v57.LastName.Value == "" or v57.LastName.Value ~= v49.LastName.Value then
						local v58 = Instance.new("Accessory");
						v58.Name = "CamFlip";
						v58.Parent = v56;
						local v59 = Instance.new("Accessory");
						v59.Name = "Confused";
						v59.Parent = v56;
						local v60 = v56.Humanoid:LoadAnimation(script.Confused);
						v60:Play();
						v60:AdjustSpeed(0.35);
						local v61 = game.ReplicatedStorage.Assets.HandHoldIllusion.IllusionHead:Clone();
						v61.Parent = v56.Head;
						v61.Enabled = true;
						local v62 = game.ReplicatedStorage.Assets.HandHoldIllusion.Hit:Clone();
						v62.Parent = v56.Head;
						v62:Play();
						sub(function()
							wait(2);
							v53:Destroy();
							v59:Destroy();
							v58:Destroy();
							v62:Destroy();
							v61:Destroy();
							v60:Stop();
						end);
					end;
				end;
			end;
		end);
		return;
	end;
	if p9:FindFirstChild("Confused") then
		return;
	end;
	local v63 = Instance.new("Accessory");
	v63.Name = "Confused";
	v63.Parent = p9;
	local v64 = p9.Humanoid:LoadAnimation(script.Confused);
	v64:Play();
	v64:AdjustSpeed(0.35);
	local v65 = Instance.new("Accessory");
	v65.Name = "CamFlip";
	v65.Parent = p9;
	local v66 = game.ReplicatedStorage.Assets.HandHoldIllusion.IllusionHead:Clone();
	v66.Parent = p9.Head;
	v66.Enabled = true;
	local v67 = game.ReplicatedStorage.Assets.HandHoldIllusion.Hit:Clone();
	v67.Parent = p9.Head;
	v67:Play();
	sub(function()
		wait(10);
		v63:Destroy();
		v67:Destroy();
		v66:Destroy();
		v65:Destroy();
		v64:Stop();
	end);
end;
v1.alternate = v4;
return v1;
