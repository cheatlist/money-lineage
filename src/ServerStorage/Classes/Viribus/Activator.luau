local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
v1.upperbound = 35;
v1.lowerbound = 25;
v1.signs = 3;
v1.cost = 25;
local v2 = {
	upperbound = 70, 
	lowerbound = 60, 
	signs = 0, 
	cost = 20
};
function ray(p1, p2, p3, p4)
	local v3, v4, v5 = workspace:FindPartOnRay(Ray.new(p1, CFrame.new(p1, p2).LookVector * p3), p4);
	return v3, v4, v5;
end;
local l__Killing__6 = game.ServerStorage.SpellEffects.Killing;
function Weld(p5, p6, p7, p8, p9, p10)
	p6.CFrame = p7.CFrame;
	local v7 = Instance.new(p5);
	v7.Part0 = p7;
	v7.Part1 = p6;
	v7.C0 = p8 or CFrame.new();
	v7.C1 = p9 or CFrame.new();
	v7.Parent = p10 and p6;
	return v7;
end;
local l__TweenService__1 = game:GetService("TweenService");
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;
local cd = false
function v1.Activate(p11, p12, p13, p14)
	if game.CollectionService:HasTag(p12, "Casting") then
		return;
	end;
	if cd then return end
	cd = true
	local l__Mana__8 = p12.Mana;
	local v9 = game.Players:GetPlayerFromCharacter(p12);
	local l__Value__10 = v9:FindFirstChildOfClass("Backpack").ManaColor
	local u3 = _G.MouseData(v9);
	if not u3 then
		cd = false
		return;
	end;
	if p13 == 0 then
		l__Mana__8.Value = math.max(l__Mana__8.Value - v1.cost, 0);
		p12.HumanoidRootPart.ChargeUpCast:Play();
		p12.Humanoid:LoadAnimation(script.MagicSlam):Play();
		local v11 = game.ServerStorage.Assets.HandHold:Clone();
		v11.Parent = p12;
		Weld("Weld", v11, p12["Right Arm"], CFrame.new(0, -1, 0));
		local v12 = Instance.new("Accessory");
		v12.Name = "Action";
		v12.Parent = p12;
		game:GetService("Debris"):AddItem(v12, 1);
		wait(1);
		sub(function()
			v11.Attachment.OrbParticle:Destroy();
			v11.Attachment.OrbEmit:Emit(3);
			wait(0.1);
			cd = false
			v11:Destroy();
		end);
		local v13 = Instance.new("Accessory");
		v13.Name = "SuperStrength";
		v13.Parent = p12;
		game:GetService("Debris"):AddItem(v13, 3);
		for v14=1, 10 do
			local u4 = v14;
			sub(function()
				local v15 = nil;
				local v16 = game.ServerStorage.Assets.EarthPillar:Clone();
				local v17 = Instance.new("Accessory");
				v17.Name = "EarthSpear" .. p12.Name;
				v17.Parent = v16;
				local v18 = p12.HumanoidRootPart.CFrame * CFrame.new(4, 0, -3.5 * u4);
				if u4 % 2 == 0 then
					v18 = p12.HumanoidRootPart.CFrame * CFrame.new(-4, 0, -3.5 * u4);
				end;
				local v19, v20, v21 = workspace:FindPartOnRayWithIgnoreList(Ray.new(v18.p, Vector3.new(0, -25, 0)), { workspace.Live, workspace.Terrain, workspace.Thrown, workspace.MonsterSpawns });
				if v19 and v21.y > 0.1 and (v19.Material == Enum.Material.Slate or v19.Material == Enum.Material.SmoothPlastic or v19.Material == Enum.Material.Brick or v19.Material == Enum.Material.Grass or v19.Material == Enum.Material.Concrete or v19.Material == Enum.Material.Sand or v19.Material == Enum.Material.Cobblestone) then
					if v19.Material ~= Enum.Material.Grass then
						v16.Crater.Color = v19.Color;
						v16.Earth.Color = v19.Color;
						v16.Crater.Material = v19.Material;
						v16.Earth.Material = v19.Material;
					end;
					if v19:IsA("WedgePart") then
						v16.Crater.Position = v20 * Vector3.new(0, -2, 0);
					else
						v16.Crater.Position = v20;
					end;
					if p12:FindFirstChild("MonasticStance") then
						v16.Earth.MonkParticle.Enabled = true;
					end;
					v16.Earth.CFrame = v16.Crater.CFrame * CFrame.new(0, 10, 0);
					v16.Parent = game.Workspace.Thrown;
					v16.Earth.Sound:Play();
					v16.Crater.ParticleEmitter.Color = ColorSequence.new(v19.Color);
					v16.Crater.ParticleEmitter:Emit(50);
					l__TweenService__1:Create(v16.Earth, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						CFrame = v16.Earth.CFrame * CFrame.new(0, -15, 0)
					}):Play();
					game:GetService("Debris"):AddItem(v16, 30);
					local l__Earth__22 = v16.Earth;
					local u5 = {};
					local u6 = false;
					v15 = l__Earth__22.Touched:Connect(function(p15)
						if p15 and p15:IsDescendantOf(p12) then
							return;
						end;
						if p15 and p15.Name == l__Earth__22.Name then
							return;
						end;
						local v23 = p15.Parent:FindFirstChild("Humanoid") or p15.Parent.Parent:FindFirstChild("Humanoid");
						if v23 and not u5[v23.Parent.Name] and not v23.Parent:FindFirstChild("SpellParry") then
							u6 = true;
							u5[v23.Parent.Name] = true;
							l__TagHumanoid__2:Fire(p12, v23.Parent, {
								physical = true, 
								noenchant = true, 
								blockbreak = true, 
								knockback = true, 
								damage = 12, 
								smash = true,
								blacksmithm1 = true,
								fist = true,
								move = "Viribus"
							});
						end;
					end);
				end;
				wait(0.5);
				if not p12:FindFirstChild("MonasticStance") and v15 ~= nil then
					v15:disconnect();
				end;
			end);
			wait(0.1);
			u4 = u4 + 1;		
		end;
	elseif p13 == 1 then
		local v24 = Instance.new("Accessory");
		v24.Name = "Action";
		v24.Parent = p12;
		game:GetService("Debris"):AddItem(v24, 1);
		sub(function()
			wait(0.1);
			cd = false
			local v25 = nil;
			local v26 = game.ServerStorage.Assets.EarthPillar:Clone();
			local v27 = Instance.new("Accessory");
			v27.Name = "EarthSpear" .. p12.Name;
			v27.Parent = v26;
			local v28, v29, v30 = workspace:FindPartOnRayWithIgnoreList(Ray.new((p12.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0)).p, Vector3.new(0, -25, 0)), { workspace.Live, workspace.Terrain, workspace.Thrown, workspace.MonsterSpawns });
			if v28 and v30.y > 0.1 and (v28.Material == Enum.Material.Slate or v28.Material == Enum.Material.Brick or v28.Material == Enum.Material.Concrete or v28.Material == Enum.Material.Grass or v28.Material == Enum.Material.Sand or v28.Material == Enum.Material.Cobblestone) then
				if v28.Material ~= Enum.Material.Grass then
					v26.Crater.Color = v28.Color;
					v26.Earth.Color = v28.Color;
					v26.Crater.Material = v28.Material;
					v26.Earth.Material = v28.Material;
				end;
				if v28:IsA("WedgePart") then
					v26.Crater.Position = v29 * Vector3.new(0, -2, 0);
				else
					v26.Crater.Position = v29;
				end;
				v26.Earth.CFrame = v26.Crater.CFrame * CFrame.new(0, 10, 0);
				v26.Parent = game.Workspace.Thrown;
				v26.Earth.Sound:Play();
				v26.Crater.ParticleEmitter.Color = ColorSequence.new(v28.Color);
				v26.Crater.ParticleEmitter:Emit(50);
				l__TweenService__1:Create(v26.Earth, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = v26.Earth.CFrame * CFrame.new(0, -15, 0)
				}):Play();
				game:GetService("Debris"):AddItem(v26, 30);
				local l__Earth__31 = v26.Earth;
				local u7 = {};
				local u8 = false;
				v25 = l__Earth__31.Touched:Connect(function(p16)
					if p16 and p16.Name == l__Earth__31.Name then
						return;
					end;
					local v32 = p16.Parent:FindFirstChild("Humanoid") or p16.Parent.Parent:FindFirstChild("Humanoid");
					if v32 and not u7[v32.Parent.Name] and not v32.Parent:FindFirstChild("SpellParry") then
						u8 = true;
						u7[v32.Parent.Name] = true;
						l__TagHumanoid__2:Fire(p12, v32.Parent, {
							physical = true, 
							noenchant = true, 
							blockbreak = true, 
							knockback = true, 
							damage = 12, 
							smash = true,
							blacksmithm1 = true,
							fist = true,
							move = "Viribus"
						});
					end;
				end);
			end;
			wait(0.5);
			if v25 ~= nil then
				v25:disconnect();
			end;
		end);
	else
		cd = false
		p12.HumanoidRootPart.Diffusion:Play();
	end;
end;

-- snap

function v2.Activate(p17, p18, p19, p20, p21)
	if game.CollectionService:HasTag(p18, "Casting") then
		return;
	end;
	if not p21[script.Parent.Name] and p18.Name ~= "Ragoozer" then
		return;
	end;
	local l__Mana__33 = p18.Mana;
	local v34 = game.Players:GetPlayerFromCharacter(p18);
	local v35 = v34 and game.ServerStorage.PlayerData:FindFirstChild(v34.Name);
	local u9 = _G.MouseData(v34);
	if not u9 then
		return;
	end;
	if not v35 or not v34:FindFirstChildOfClass("Backpack").ManaColor or not p18:FindFirstChild("HumanoidRootPart") then
		return;
	end;
	if p19 == 0 then
		p18.HumanoidRootPart.PerfectCast:Play();
		p18.Humanoid:LoadAnimation(script.Snap):Play();
		wait(0.2);
		local v36 = game.ReplicatedStorage.Assets.HandHoldCeleri:Clone();
		v36.IllusionArm.Enabled = false;
		v36.Parent = game.Workspace.Thrown;
		v36.Snap:Play();
		v36.IllusionSnap:Emit(100);
		local v37 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
		if not p20 then
			v37 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
		end;
		local u10 = Instance.new("Weld");
		local u11 = p18["Right Arm"];
		sub(function()
			u10.Name = "Weld";
			u10.Part0 = u11;
			u10.Part1 = v36;
			u10.Parent = v36;
			u10.C1 = v37;
			wait(1);
			v36:Destroy();
		end);
		local v38 = Instance.new("Accessory");
		v38.Name = "SuperStrength";
		v38.Parent = p18;
		game:GetService("Debris"):AddItem(v38, 3);
		for v3=1, 10 do
			local u12 = v3
			sub(function()
				local v40 = nil;
				local v41 = game.ServerStorage.Assets.EarthPillar:Clone();
				local v42 = Instance.new("Accessory");
				v42.Name = "EarthSpear" .. p18.Name;
				v42.Parent = v41;
				local v43 = p18.HumanoidRootPart.CFrame * CFrame.new(4, 0, -3.5 * u12);
				if u12 % 2 == 0 then
					v43 = p18.HumanoidRootPart.CFrame * CFrame.new(-4, 0, -3.5 * u12);
				end;
				local v44, v45, v46 = workspace:FindPartOnRayWithIgnoreList(Ray.new(v43.p, Vector3.new(0, -25, 0)), { workspace.Live, workspace.Terrain, workspace.Thrown, workspace.MonsterSpawns });
				if v44 and v46.y > 0.1 and (v44.Material == Enum.Material.Slate or v44.Material == Enum.Material.Brick or v44.Material == Enum.Material.Grass or v44.Material == Enum.Material.Concrete or v44.Material == Enum.Material.Sand or v44.Material == Enum.Material.Cobblestone) then
					if v44.Material ~= Enum.Material.Grass then
						v41.Crater.Color = v44.Color;
						v41.Earth.Color = v44.Color;
						v41.Crater.Material = v44.Material;
						v41.Earth.Material = v44.Material;
					end;
					if v44:IsA("WedgePart") then
						v41.Crater.Position = v45 * Vector3.new(0, -2, 0);
					else
						v41.Crater.Position = v45;
					end;
					if p18:FindFirstChild("MonasticStance") then
						v41.Earth.MonkParticle.Enabled = true;
					end;
					v41.Earth.CFrame = v41.Crater.CFrame * CFrame.new(0, 10, 0);
					v41.Parent = workspace.Thrown;
					v41.Earth.Sound:Play();
					v41.Crater.ParticleEmitter.Color = ColorSequence.new(v44.Color);
					v41.Crater.ParticleEmitter:Emit(50);
					l__TweenService__1:Create(v41.Earth, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						CFrame = v41.Earth.CFrame * CFrame.new(0, -15, 0)
					}):Play();
					game:GetService("Debris"):AddItem(v41, 30);
					local l__Earth__47 = v41.Earth;
					local u13 = {};
					local u14 = false;
					v40 = l__Earth__47.Touched:Connect(function(p22)
						if p22 and p22:IsDescendantOf(p18) then
							return;
						end;
						if p22 and p22.Name == l__Earth__47.Name then
							return;
						end;
						local v48 = p22.Parent:FindFirstChild("Humanoid") or p22.Parent.Parent:FindFirstChild("Humanoid");
						if v48 and not u13[v48.Parent.Name] and not v48.Parent:FindFirstChild("SpellParry") then
							u14 = true;
							u13[v48.Parent.Name] = true;
							l__TagHumanoid__2:Fire(p18, v48.Parent, { 
								physical = true, 
								noenchant = true, 
								blockbreak = true, 
								knockback = true, 
								damage = 12, 
								smash = true,
								blacksmithm1 = true,
								fist = true,
								move = "Viribus"
							});
						end;
					end);
				end;
				wait(0.5);
				if not p18:FindFirstChild("MonasticStance") and v40 ~= nil then
					v40:disconnect();
				end;
			end);
			wait(0.1);
			u12 = u12 + 1;		
		end;
	else
		local v49 = Instance.new("Accessory");
		v49.Name = "Action";
		v49.Parent = p18;
		game:GetService("Debris"):AddItem(v49, 1);
		sub(function()
			wait(0.1);
			local v50 = nil;
			local v51 = game.ServerStorage.Assets.EarthPillar:Clone();
			local v52 = Instance.new("Accessory");
			v52.Name = "EarthSpear" .. p18.Name;
			v52.Parent = v51;
			local v53, v54, v55 = workspace:FindPartOnRayWithIgnoreList(Ray.new((p18.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0)).p, Vector3.new(0, -25, 0)), { workspace.Live, workspace.Terrain, workspace.Thrown, workspace.MonsterSpawns });
			if v53 and v55.y > 0.1 and (v53.Material == Enum.Material.Slate or v53.Material == Enum.Material.Brick or v53.Material == Enum.Material.Concrete or v53.Material == Enum.Material.Grass or v53.Material == Enum.Material.Sand or v53.Material == Enum.Material.Cobblestone) then
				if v53.Material ~= Enum.Material.Grass then
					v51.Crater.Color = v53.Color;
					v51.Earth.Color = v53.Color;
					v51.Crater.Material = v53.Material;
					v51.Earth.Material = v53.Material;
				end;
				if v53:IsA("WedgePart") then
					v51.Crater.Position = v54 * Vector3.new(0, -2, 0);
				else
					v51.Crater.Position = v54;
				end;
				v51.Earth.CFrame = v51.Crater.CFrame * CFrame.new(0, 10, 0);
				v51.Parent = game.Workspace.Thrown;
				v51.Earth.Sound:Play();
				v51.Crater.ParticleEmitter.Color = ColorSequence.new(v53.Color);
				v51.Crater.ParticleEmitter:Emit(50);
				l__TweenService__1:Create(v51.Earth, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = v51.Earth.CFrame * CFrame.new(0, -15, 0)
				}):Play();
				game:GetService("Debris"):AddItem(v51, 30);
				local l__Earth__56 = v51.Earth;
				local u15 = {};
				local u16 = false;
				v50 = l__Earth__56.Touched:Connect(function(p23)
					if p23 and p23.Name == l__Earth__56.Name then
						return;
					end;
					local v57 = p23.Parent:FindFirstChild("Humanoid") or p23.Parent.Parent:FindFirstChild("Humanoid");
					if v57 and not u15[v57.Parent.Name] and not v57.Parent:FindFirstChild("SpellParry") then
						u16 = true;
						u15[v57.Parent.Name] = true;
						l__TagHumanoid__2:Fire(p18, v57.Parent, {
							physical = true, 
							noenchant = true, 
							blockbreak = true, 
							knockback = true, 
							damage = 12, 
							smash = true,
							blacksmithm1 = true,
							fist = true,
							move = "Viribus"
						});
					end;
				end);
			end;
			wait(0.5);
			if v50 then
				v50:Disconnect();
			end;
		end);
	end;
end;
v1.alternate = v2;
return v1;
