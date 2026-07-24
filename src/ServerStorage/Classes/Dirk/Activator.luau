

local l__Parent__1 = script.Parent;
local v2 = {};
function sub(...)
	coroutine.wrap(...)();
end;
v2.upperbound = 0;
v2.lowerbound = 0;
v2.signs = 0;
v2.cost = 2;
local l__WeaponTake__1 = game.ServerStorage.SpellEffects.WeaponTake;
local l__TweenService__2 = game:GetService("TweenService");
function desummonEffect(p1)
	local v3 = l__WeaponTake__1.summon:Clone();
	v3.Parent = p1;
	v3:play();
	local v4 = l__WeaponTake__1.Glow:Clone();
	v4.Parent = p1;
	v4.Range = 0;
	local v5 = TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
	local v6 = l__TweenService__2:Create(p1, v5, {
		Color = Color3.fromRGB(245, 205, 48), 
		Transparency = 0.4
	}):Play();
	local v7 = l__TweenService__2:Create(v4, v5, {
		Range = 6
	}):Play();
	wait(0.8);
	local v8 = l__WeaponTake__1.LightCube:Clone();
	game.Debris:AddItem(v8, 3.5);
	v8.Transparency = 1;
	v8:ClearAllChildren();
	v8.CFrame = p1.CFrame;
	v8.Parent = game.Workspace;
	local v9 = l__WeaponTake__1.breakweapon:Clone();
	v9.Parent = v8;
	v9:Play();
	local v10 = 1 - 1;
	while true do
		local v11 = l__WeaponTake__1.LightCube:Clone();
		game.Debris:AddItem(v11, 3);
		local v12 = p1.Size.X / 2;
		local v13 = p1.Size.Y / 2;
		local v14 = p1.Size.Z / 2;
		v11.CFrame = p1.CFrame * CFrame.new(math.random(-v12, v12), math.random(-v13, v13), math.random(-v14, v14));
		v11.Parent = game.Workspace;
		local v15 = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
		local v16 = l__TweenService__2:Create(v11, v15, {
			CFrame = CFrame.new(p1.CFrame.X, p1.CFrame.Y, p1.CFrame.Z) * CFrame.new(math.random(-4, 4), math.random(7, 10), math.random(-4, 4)) * CFrame.Angles(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)), 
			Transparency = 1
		}):Play();
		local v17 = l__TweenService__2:Create(v11.PointLight, v15, {
			Range = 0
		}):Play();
		if 0 <= 1 then
			if v10 < 8 then

			else
				break;
			end;
		elseif 8 < v10 then

		else
			break;
		end;
		v10 = v10 + 1;	
	end;
	p1:Destroy();
end;
function v2.Activate(p2, p3, p4, p5)
	if game.CollectionService:HasTag(p3, "Casting") then
		return;
	end;
	local v18 = game.Players:GetPlayerFromCharacter(p3);
	local v19 = v18 and game.ServerStorage.PlayerData:FindFirstChild(v18.Name);
	local l__SpecMeta__20 = v19.SpecMeta;
	if not v19 or not v19.ManaColor.Value or not p3:FindFirstChild("HumanoidRootPart") then
		return;
	end;
	if p3.Mana.Value < v2.cost then
		return;
	end;
	if p3:FindFirstChild("GladiusSelfCD") then
		return;
	end;
	local v21 = Instance.new("Accessory", p3);
	v21.Name = "GladiusSelfCD";
	game.Debris:AddItem(v21, 1.5);
	if v19.Money.Value <= 10 then
		return;
	end;
	require(game.ServerScriptService.Modules.Commands).ChangeMoney(v18,v19,-10)
	local v23 = Instance.new("Accessory");
	v23.Name = "Action";
	v23.Parent = p3;
	game.Debris:AddItem(v23, 1.5);
	p3.Humanoid.AutoRotate = false;
	local v24 = p3.Humanoid:LoadAnimation(script.AptetAnim);
	v24:Play();
	wait(0.15);
	local v25 = l__WeaponTake__1.summon:Clone();
	game.Debris:AddItem(v25, 3);
	v25.Parent = p3.Torso;
	v25:Play();
	local v26 = game:GetService("HttpService"):JSONDecode(l__SpecMeta__20.Value);
	print(l__SpecMeta__20.Value)
	if v26["Spirit Dagger"] then
		v26["Spirit Dagger"] += 1
	else
		v26["Spirit Dagger"] = 1
	end
	l__SpecMeta__20.Value = game:GetService("HttpService"):JSONEncode(v26);
	local l__Spirit_Dagger__27 = game.ServerStorage.verto:FindFirstChild("Spirit Dagger");
	local v28 = l__Spirit_Dagger__27.Size.X;
	if v28 < l__Spirit_Dagger__27.Size.Y then
		v28 = l__Spirit_Dagger__27.Size.Y;
	end;
	if v28 < l__Spirit_Dagger__27.Size.Z then
		v28 = l__Spirit_Dagger__27.Size.Z;
	end;
	local l__Value__29 = v18.Backpack.ManaColor.Value;
	local v30 = {};
	local v31 = math.floor(math.floor(v28) / 0.4);
	local v32 = p3["Right Arm"].CFrame * CFrame.new(0, -1.2, 0);
	for v33 = 1, v31 do
		local v34 = l__WeaponTake__1.LightCube:Clone();
		v34.Color = l__Value__29;
		v34.PointLight.Color = l__Value__29;
		game.Debris:AddItem(v34, 2.5);
		table.insert(v30, v34);
		v34.Transparency = 1;
		local v35 = CFrame.new(p3["Right Arm"].CFrame.X, p3["Right Arm"].CFrame.Y, p3["Right Arm"].CFrame.Z);
		v34.CFrame = v35 * CFrame.new(math.random(-4, 4), math.random(7, 10), math.random(-4, 4)) * CFrame.Angles(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20));
		v34.Parent = game.Workspace;
		local v36 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
		local v37 = v32 * CFrame.new(math.random(-14, 14) / 100, -0.4 * v33 + 0.4, math.random(-2, 2) / 100);
		local v38 = l__TweenService__2:Create(v34, v36, {
			CFrame = v37, 
			Transparency = 0.6
		}):Play();
		if v33 < v31 / 3 or math.random(1, 2) == 1 and v33 < v31 / 1.2 then
			local v39 = l__WeaponTake__1.LightCube:Clone();
			v39.Color = l__Value__29;
			v39.PointLight.Color = l__Value__29;
			game.Debris:AddItem(v39, 2.5);
			table.insert(v30, v39);
			v39.Parent = game.Workspace;
			v39.CFrame = v35 * CFrame.new(math.random(-4, 4), math.random(7, 10), math.random(-4, 4)) * CFrame.Angles(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20));
			local v40 = l__TweenService__2:Create(v39, v36, {
				CFrame = v37 * CFrame.new(-0.30000000000000004, 0, math.random(-2, 2) / 100), 
				Transparency = 0.6
			}):Play();
		end;
		wait(0.015);
	end;
	wait(0.3);
	for v41 = 1, #v30 do
		local v42 = l__TweenService__2:Create(v30[v41], TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Transparency = 0
		}):Play();
	end;
	wait(0.1);
	local v43 = nil;
	local v44 = nil;
	local l__next__45 = next;
	local v46, v47 = p3.Hilt:GetChildren();
	while true do
		local v48, v49 = l__next__45(v46, v47);
		if not v48 then
			break;
		end;
		v47 = v48;
		if v49:FindFirstChild("Prop") and not game.CollectionService:HasTag(v49, "SideProp") then
			v49.Transparency = 0.4;
			v43 = v49.Color;
			v49.Color = Color3.fromRGB(255, 255, 255);
			v44 = v49;
		end;	
	end;
	for v50 = 1, #v30 do
		local v51 = l__TweenService__2:Create(v30[v50], TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play();
		wait(0.005);
	end;
	if v44 then
		local v52 = l__TweenService__2:Create(v44, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Color = v43, 
			Transparency = 0
		}):Play();
	end;
	wait(0.15);
	p3.Humanoid.AutoRotate = true;
	v24:Stop();
end;
return v2;
