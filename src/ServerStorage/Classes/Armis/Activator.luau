

local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local v2 = require(game.ServerScriptService.Modules.HitDetection);
v1.upperbound = 60;
v1.lowerbound = 40;
v1.signs = 3;
v1.cost = 20;
local v3 = {
	upperbound = 80, 
	lowerbound = 70, 
	signs = 0, 
	cost = 20
};
local l__Disarm__1 = game.ServerStorage.SpellEffects.Armis;
local u2 = require(game.ServerScriptService.Modules.DangerHandler);
local l__TweenService__3 = game:GetService("TweenService");
local l__TagHumanoid__4 = game.ServerStorage.Requests.TagHumanoid;
function v1.Activate(p1, p2, p3, p4)
	local v4 = nil;
	if game.CollectionService:HasTag(p2, "Casting") then
		return;
	end;
	v4 = p2.Mana;
	local v5 = game.Players:GetPlayerFromCharacter(p2);
	local l__Value__6 = v5.Backpack.ManaColor.Value;
	local u5 = _G.MouseData(v5);
	if not u5 then
		return;
	end;
	task.spawn(function()
		if p3 == 0 then
			v4.Value = math.max(v4.Value - v1.cost, 0);
			p2.HumanoidRootPart.PerfectCast:Play();
			local v7 = l__Disarm__1.DisarmSpell:Clone();
			v7.CFrame = p2.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3);
			v7.CFrame = CFrame.new(v7.Position, u5.Hit.p);
			v7.Parent = game.Workspace;
			v7:SetNetworkOwner(nil);
			local l__Motor6D__8 = v7:FindFirstChild("Motor6D");
			local v9 = Instance.new("NumberValue", l__Motor6D__8);
			game.TweenService:Create(v9, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
				Value = 360
			}):Play();
			v9:GetPropertyChangedSignal("Value"):connect(function()
				if l__Motor6D__8 and l__Motor6D__8.Parent then
					l__Motor6D__8.C0 = CFrame.Angles(0, 0, math.rad(v9.Value));
				end;
			end);
			game.Debris:AddItem(v7, 10);
			v7.BodyVelocity.Velocity = v7.CFrame.lookVector * 300;
			local u6 = false;
			local u7 = {};
			local u8 = false;
			local u9 = nil;
			local u10 = false;
			local u11 = {
				mana = true, 
				disarm = true, 
				knockondisarm = 1, 
				damage = 0, 
				noenchant = true,
				move = "Armis"
			};
			u9 = v7.Touched:connect(function(p5)
				if p5 and p5:IsDescendantOf(p2) and not u6 then
					return;
				end;
				if p5 and p5.Name == v7.Name then
					return;
				end;
				if not p5:FindFirstChild("SpellParry") then
					if p5.Parent:FindFirstChild("SpellParry") and u6 == false then
						u6 = true;
						v7.CFrame = CFrame.new(v7.Position, p2.HumanoidRootPart.Position);
						v7.BodyVelocity.Velocity = v7.CFrame.lookVector * 300;
						return;
					end;
				elseif u6 == false then
					u6 = true;
					v7.CFrame = CFrame.new(v7.Position, p2.HumanoidRootPart.Position);
					v7.BodyVelocity.Velocity = v7.CFrame.lookVector * 300;
					return;
				end;
				local v10 = p5.Parent:FindFirstChild("Humanoid") or p5.Parent.Parent:FindFirstChild("Humanoid");
				if v10 and not u7[v10.Parent.Name] and not u8 and (not v10.Parent:FindFirstChild("SpellParry") and not u6) then
					u9:disconnect();
					v7.Anchored = true;
					v7.CFrame = v10.Parent.HumanoidRootPart.CFrame;
					local v11 = u2:getEntity(v10.Parent);
					if v11 then
						v11:createTag(p2.Name, {
							lifespan = 20
						});
					end;
					l__TweenService__3:Create(v7, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Size = Vector3.new(6, 6, 6), 
						Transparency = 1
					}):Play();
					if not v10.Parent:FindFirstChild("SpellBlocking") then
						v7.Hit:Play();
					end;
					local l__Parent__12 = v10.Parent;
					u10 = true;
					u7[l__Parent__12.Name] = true;
					local v13 = {};
					for v14, v15 in next, u11 do
						v13[v14] = v15;
					end;
					if u6 then
						v13.manaknockup = nil;
						v13.manaknockupself = true;
					end;
					if l__Parent__12:FindFirstChild("ManaFlying") or l__Parent__12:FindFirstChild("IsClimbing") then
						v13.manaknockup = true;
					end;
					l__TagHumanoid__4:Fire(p2, l__Parent__12, v13);
					sub(function()
						game.Debris:AddItem(v7, 0.4);
					end);
				end;
			end);
			local u12 = nil;
			u12 = v7.TrailP.Touched:Connect(function(p6)
				if p6.Anchored == true and ((p6.CanCollide == true or p6.Name == "Field") and u10 == false) then
					u8 = true;
					v7.Anchored = true;
					u12:disconnect();
					for v16, v17 in pairs(game.Workspace.Live:GetChildren()) do
						if v17 ~= p2 then
							if (v17.HumanoidRootPart.Position - v7.Position).Magnitude <= 10 then
								local v18 = u2:getEntity(v17.Parent);
								if v18 then
									v18:createTag(p2.Name, {
										lifespan = 20
									});
								end;
								v7.CFrame = v17.HumanoidRootPart.CFrame;
								l__TweenService__3:Create(v7, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
									Size = Vector3.new(6, 6, 6), 
									Transparency = 1
								}):Play();
								if not v17:FindFirstChild("SpellBlocking") then
									v7.Hit:Play();
								end;
								local v19 = {};
								for v20, v21 in next, u11 do
									v19[v20] = v21;
								end;
								if v17:FindFirstChild("ManaFlying") or v17:FindFirstChild("IsClimbing") then
									v19.manaknockup = true;
								end;
								l__TagHumanoid__4:Fire(p2, v17, u11);
								sub(function()
									game.Debris:AddItem(v7, 0.4);
								end);
							else
								l__TweenService__3:Create(v7, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
									Size = Vector3.new(8, 8, 8), 
									Transparency = 1
								}):Play();
								v7.WallHit:Play();
								sub(function()
									game.Debris:AddItem(v7, 0.4);
								end);
							end;
						end;
					end;
				end;
			end);
		elseif p3 == 1 then
			if v4.Value - v1.cost <= 0 then
				v4.Value = 0;
			else
				v4.Value = v4.Value - v1.cost;
			end;
			local v22 = l__Disarm__1.BackfireBrick:Clone();
			l__TagHumanoid__4:Fire(p2, p2, {
				mana = true, 
				manaknockupself = true, 
				disarm = true, 
				damage = 0,
				noenchant = true,
				move = "Armis"
			});
			v22.CFrame = p2.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(90), math.rad(-90));
			v22.Parent = workspace.Thrown;
			game:GetService("Debris"):AddItem(v22, 1);
			if p2.HumanoidRootPart:FindFirstChild("Backfire") then
				p2.HumanoidRootPart.Backfire:Play();
			end;
			l__TweenService__3:Create(v22, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Size = Vector3.new(10, 4.5, 10), 
				Transparency = 1
			}):Play();
		else
			p2.HumanoidRootPart.Diffusion:Play();
			if p4 and p4:FindFirstChild("Backfire") then
				p4.Backfire.Color = ColorSequence.new(Color3.new(l__Value__6.r, l__Value__6.g, l__Value__6.b));
				p4.Backfire:Emit(15);
			end;
		end;
	end)
end;
function v3.Activate(p7, p8, p9, p10, p11)
	if game.CollectionService:HasTag(p8, "Casting") then
		return;
	end;
	local l__Mana__23 = p8.Mana;
	local v24 = game.Players:GetPlayerFromCharacter(p8);
	local v25 = v24 and game.ServerStorage.PlayerData:FindFirstChild(v24.Name);
	if not p11[script.Parent.Name] then
		return;
	end;
	if not v25 or not v25.ManaColor.Value or not p8:FindFirstChild("HumanoidRootPart") then
		return;
	end;
	if p9 == 0 then
		sub(function()
			p8.HumanoidRootPart.PerfectCast:Play();
			p8.Humanoid:LoadAnimation(script.Snap2):Play();
			wait(0.2);
			local v26 = game.ReplicatedStorage.Assets.HandHoldDisarm:Clone();
			v26.IllusionArm.Enabled = false;
			v26.Parent = game.Workspace.Thrown;
			v26.Snap:Play();
			v26.IllusionSnap:Emit(100);
			local v27 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
			if not p10 then
				v27 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
			end;
			local u13 = Instance.new("Weld");
			local u14 = p8["Right Arm"];
			sub(function()
				u13.Name = "Weld";
				u13.Part0 = u14;
				u13.Part1 = v26;
				u13.Parent = v26;
				u13.C1 = v27;
				wait(1);
				v26:Destroy();
			end);
			for v28, v29 in pairs(game.Workspace.Live:GetChildren()) do
				if (v29.Torso.Position - p8.HumanoidRootPart.Position).Magnitude <= 35 and v29 ~= p8 then
					l__TagHumanoid__4:Fire(p8, v29, {
						mana = true, 
						disarm = true, 
						knockondisarm = 1, 
						damage = 0, 
						noenchant = true,
						move = "Armis"
					});
				end;
			end;
		end);
		return;
	end;
	p8.HumanoidRootPart.PerfectCast:Play();
	p8.Humanoid:LoadAnimation(script.Snap):Play();
	wait(0.2);
	local v30 = game.ReplicatedStorage.Assets.HandHoldDisarm:Clone();
	v30.IllusionArm.Enabled = false;
	v30.Parent = game.Workspace.Thrown;
	v30.Snap:Play();
	v30.IllusionSnap:Emit(100);
	local v31 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
	if not p10 then
		v31 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
	end;
	local u15 = Instance.new("Weld");
	local u16 = p8["Right Arm"];
	sub(function()
		u15.Name = "Weld";
		u15.Part0 = u16;
		u15.Part1 = v30;
		u15.Parent = v30;
		u15.C1 = v31;
		wait(1);
		v30:Destroy();
	end);
	l__TagHumanoid__4:Fire(p8, p8, {
		mana = true, 
		dam = 20, 
		manaknockupself = 45, 
		damage = 0,
		move = "Armis"
	});
end;
v1.alternate = v3;
return v1;
