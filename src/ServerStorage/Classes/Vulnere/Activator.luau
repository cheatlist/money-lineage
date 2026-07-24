local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local v2 = require(game.ServerScriptService.Modules.HitDetection);
v1.upperbound = 0;
v1.lowerbound = 0;
v1.signs = 0;
v1.cost = 2;
local u1 = {};
function ray(p1, p2, p3, p4)
	local v3, v4, v5 = game.Workspace:FindPartOnRayWithIgnoreList(Ray.new(p1, CFrame.new(p1, p2).lookVector * p3), u1);
	return v3, v4, v5;
end;
local l__TweenService__2 = game:GetService("TweenService");
function desummonEffect(p5, p6)
	local l__WeaponTake__6 = game.ServerStorage.SpellEffects.WeaponTake;
	local v7 = l__WeaponTake__6.summon:Clone();
	v7.Parent = p5;
	v7:play();
	local v8 = l__WeaponTake__6.Glow:Clone();
	v8.Parent = p5;
	v8.Range = 0;
	local v9 = TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
	local v10 = l__TweenService__2:Create(p5, v9, {
		Color = Color3.fromRGB(245, 205, 48), 
		Transparency = 0.4
	}):Play();
	local v11 = l__TweenService__2:Create(v8, v9, {
		Range = 6
	}):Play();
	wait(0.8);
	local v12 = l__WeaponTake__6.LightCube:Clone();
	game.Debris:AddItem(v12, 3.5);
	v12.Transparency = 1;
	v12:ClearAllChildren();
	v12.CFrame = p5.CFrame;
	v12.Parent = game.Workspace.Thrown;
	local v13 = l__WeaponTake__6.breakweapon:Clone();
	v13.Parent = v12;
	v13:Play();
	local v14 = 1 - 1;
	while true do
		local v15 = l__WeaponTake__6.LightCube:Clone();
		game.Debris:AddItem(v15, 3);
		local v16 = p5.Size.X / 2;
		local v17 = p5.Size.Y / 2;
		local v18 = p5.Size.Z / 2;
		local v19 = CFrame.new(p6.X, p6.Y, p6.Z);
		v15.CFrame = v19;
		v15.Parent = game.Workspace;
		local v20 = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
		local v21 = l__TweenService__2:Create(v15, v20, {
			CFrame = v19 * CFrame.new(math.random(-4, 4), math.random(7, 10), math.random(-4, 4)) * CFrame.Angles(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)), 
			Transparency = 1
		}):Play();
		local v22 = l__TweenService__2:Create(v15.PointLight, v20, {
			Range = 0
		}):Play();
		if 0 <= 1 then
			if v14 < 8 then

			else
				break;
			end;
		elseif 8 < v14 then

		else
			break;
		end;
		v14 = v14 + 1;	
	end;
	p5:Destroy();
end;
local l__WeaponWithdraw__3 = game.ServerStorage.SpellEffects.WeaponWithdraw;
function makePortal(p7, p8, p9)
	local v23 = l__WeaponWithdraw__3.Portal:Clone();
	v23.Name = "Portal";
	game.Debris:AddItem(v23, p8);
	v23.CFrame = p7;
	v23.Parent = p9;
	v23.summon:Play();
	spawn(function()
		wait(p8 - 0.25);
		local v24 = l__TweenService__2:Create(v23, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = v23.CFrame, 
			Size = Vector3.new(0.1, 0.1, v23.Size.Z)
		}):Play();
	end);
	local v25 = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
	local v26 = l__TweenService__2:Create(v23.bg, v25, {
		Transparency = 0.2
	}):Play();
	local v27 = l__TweenService__2:Create(v23.BACK, v25, {
		Transparency = 0.2
	}):Play();
	spawn(function()
		while true do
			if v23.Parent == p9 then

			else
				break;
			end;
			local v28 = v23.pfx:FindFirstChild("base"):Clone();
			game.Debris:AddItem(v28, 1.5);
			v28.Name = "Ring";
			v28.Parent = v23.pfx;
			local v29 = l__TweenService__2:Create(v28, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Position = UDim2.new(-0.1, 0, -0.1, 0), 
				Size = UDim2.new(1.2, 0, 1.2, 0), 
				ImageTransparency = 1
			}):Play();
			wait(0.45);		
		end;
	end);
	return v23;
end;
local u4 = 1;
local u5 = {
	["Bronze Sword"] = {
		dmg = 10, 
		weight = 3
	}, 
	["Steel Sword"] = {
		dmg = 15, 
		weight = 3.5
	}, 
	["Mythril Sword"] = {
		dmg = 19, 
		weight = 4
	}, 
	["Spirit Sword"] = {
		dmg = 12.5, 
		weight = 4.5
	}, 
	["Spirit Dagger"] = {
		dmg = 10.5, 
		weight = 1.5
	}, 
	Katana = {
		dmg = 15, 
		weight = 3.5
	}, 
	["Bronze Spear"] = {
		dmg = 12, 
		weight = 2
	}, 
	["Steel Spear"] = {
		dmg = 17, 
		weight = 2.5
	}, 
	["Mythril Spear"] = {
		dmg = 22, 
		weight = 2.5
	}, 
	["Mythril Church Spear"] = {
		dmg = 28, 
		weight = 2.5
	}, 
	["Pronged Mythril Spear"] = {
		dmg = 32, 
		weight = 3
	},
	["Fairfrozen Spear"] = {
		dmg = 36, 
		weight = 2.5
	}, 
	["SpearFairfrozen"] = {
		dmg = 50, 
		weight = 100
	}, 
	["Bronze Dagger"] = {
		dmg = 10, 
		weight = 1
	}, 
	["Steel Dagger"] = {
		dmg = 12, 
		weight = 1
	}, 
	["Mythril Dagger"] = {
		dmg = 14, 
		weight = 1
	}, 
	["Tanto Dagger"] = {
		dmg = 20, 
		weight = 1
	}, 
	["Iron Greatsword"] = {
		dmg = 30, 
		weight = 4.5
	}, 
	["Templar Greatsword"] = {
		dmg = 40, 
		weight = 5
	},
	["Abyss Greatsword"] = {
		dmg = 35, 
		weight = 5
	},
	["norpGS"] = {
		dmg = 40, 
		weight = 8
	},
	["EXTREME_GS"] = {
		dmg = 80, 
		weight = 10
	},
	["Lute"] = {
		dmg = 100,
		weight = 1
	}
};
local l__TagHumanoid__6 = game.ServerStorage.Requests.TagHumanoid;
function v1.Activate(p10, p11, p12, p13)
	if game.CollectionService:HasTag(p11, "Casting") then
		warn("tch we castin here");
		return;
	end;
	local v30 = game.Players:GetPlayerFromCharacter(p11);
	local v31 = v30 and game.ServerStorage.PlayerData:FindFirstChild(v30.Name);
	local l__SpecMeta__32 = v31.SpecMeta;
	local v33 = v31 and v30:FindFirstChildOfClass("Backpack").ManaColor and v30:FindFirstChild("GetWeaponSelection");
	if not v33 then
		warn("no remote AHHH");
		return;
	end;
	local l__HumanoidRootPart__34 = p11:FindFirstChild("HumanoidRootPart");
	if not l__HumanoidRootPart__34 then
		warn("NO HRP AHHHH");
		return;
	end;
	if p11.Mana.Value < v1.cost then
		return;
	end;
	local v35 = v33:InvokeClient(v30);
	if not v35 then
		return;
	end;
	local v36 = _G.MouseData(v30);
	if not v36 then
		return;
	end;
	task.spawn(function()
		local l__UnitRay__37 = v36.UnitRay;
		local v38, v39, v40 = workspace:FindPartOnRayWithIgnoreList(Ray.new(l__UnitRay__37.Origin, l__UnitRay__37.Direction * 2000), { p11, workspace.Thrown, workspace.AreaMarkers, workspace.MonsterSpawns });
		if not v38 then
			return;
		end;
		local v41 = CFrame.new(v39) * (v36.Hit - v36.Hit.p);
		if p11:FindFirstChild("ArguereSingleCD") then
			if p11.Name ~= "epsilo_n" then
				return;
			end
		end;
		local v42 = Instance.new("StringValue", p11);
		v42.Name = "ArguereSingleCD";
		game.Debris:AddItem(v42, 0.3);
		local v43 = game:GetService("HttpService"):JSONDecode(l__SpecMeta__32.Value);
		if v43[v35] < 1 then
			return;
		end;
		if v43[v35] == 1 then
			v43[v35] = nil
			l__SpecMeta__32.Value = game:GetService("HttpService"):JSONEncode(v43);
		elseif v43[v35] > 1 then
			v43[v35] = v43[v35] - 1;
			l__SpecMeta__32.Value = game:GetService("HttpService"):JSONEncode(v43);
		end;
		local v44 = makePortal(l__HumanoidRootPart__34.CFrame * CFrame.new(math.random(-8, 8), math.random(3, 8), math.random(3, 4)), 2, workspace.Thrown);
		v44.CFrame = CFrame.new(v44.Position, v41.p);
		local l__Position__45 = v44.Position;
		local v46 = game.ServerStorage.verto:FindFirstChild(v35):Clone();
		game.Debris:AddItem(v46, 100);
		local v92 = game.Players:GetPlayerFromCharacter(p11);
		warn(v46)
		local rot = CFrame.Angles(0, math.rad(90), 0)
		if v35 == "Spirit Sword" then
			warn(v46)
			v46.Color = v30.Backpack.ManaColor.Value;
		end;
		if v35 == "Spirit Dagger" then
			warn(v46)
			v46.Color = v30.Backpack.ManaColor.Value;
		end;
		if v35 ~= "norpGS" then
			v46:ClearAllChildren();
		else
			rot = CFrame.Angles(math.rad(-90),0,0)
		end
		v46.Anchored = true;
		v46.CanCollide = false;
		v46.CFrame = v44.CFrame;
		v46.CFrame = CFrame.new(v46.Position, v41.p) * rot
		v46.Parent = game.Workspace.Thrown;
		table.insert(u1, v44);
		table.insert(u1, p11);
		table.insert(u1, v46);
		local v47, v48, v49 = ray(v44.Position, v41.p, 2000, v44);
		print("ray hit:", v47);
		if v47 == nil or not v47 then
			v46:Destroy();
		end;
		u4 = u4 + 1;
		if u4 >= 5 then
			local v50 = Instance.new("StringValue", p11);
			v50.Name = "ArguereSingleCD";
			game.Debris:AddItem(v50, 10);
			wait();
			u4 = 0;
		end;
		local v51 = v47.Parent:FindFirstChild("Humanoid") or v47.Parent.Parent:FindFirstChild("Humanoid");
		if v51 and v51.Parent ~= p11 and not v51.Parent:FindFirstChild("SpellParry") then
			local l__Torso__52 = v51.Parent.Torso;
			local v53 = (v46.Position - l__Torso__52.Position).magnitude / 4;
			for v54 = 1, math.ceil(v53) do
				wait();
				v46.CFrame = v46.CFrame:lerp(CFrame.new(l__Torso__52.Position, l__Position__45) * rot, v54 / v53);
			end;
			local v55 = 12;
			local v56 = 2;
			if u5[v35] then
				print("ARGUERE Changed");
				v55 = u5[v35].dmg;
				v56 = u5[v35].weight;
			end;
			v46.Anchored = false;
			game:GetService("Debris"):AddItem(v46, 30);
			if not v51.Parent:FindFirstChild("Blocking") then
				local v57 = v46.CFrame:toObjectSpace(l__Torso__52.CFrame);
				local v58 = Instance.new("Weld");
				v58.Part0 = l__Torso__52;
				v58.Part1 = v46;
				v58.C0 = (v57 - v57.p) * CFrame.new(math.random(-10, 10) / 100, math.random(-10, 10) / 100, math.random(-10, 10) / 100);
				v58.Parent = v46;
				local v59 = Instance.new("NumberValue");
				v59.Value = -v56;
				v59.Name = "SpeedBoost";
				v59.Parent = v51.Parent.Boosts;
				game:GetService("Debris"):AddItem(v59, 30);
			end;
			l__TagHumanoid__6:Fire(p11, v51.Parent, {
				arguere = true, 
				physical = true, 
				sword = true, 
				damage = v55/5,
				move = "Vulnere"
			});
			return;
		end;
		if v47.Anchored == true and v47.Transparency ~= 1 then
			local v60 = (v44.Position - v48).magnitude / 280;
			local v61 = l__TweenService__2:Create(v46, TweenInfo.new(v60, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = v41 * rot
			}):Play();
			local v62 = Instance.new("ClickDetector");
			v62.MaxActivationDistance = 15;
			v62.Name = "PickUp";
			v62.Parent = v46;
			local u7 = true;
			v62.MouseClick:connect(function(p14)
				if p14 ~= v30 then
					return;
				end;
				if not u7 then
					return;
				end;
				u7 = false;
				local v63 = game:GetService("HttpService"):JSONDecode(l__SpecMeta__32.Value);
				if not v63[v46.Name] then
					v63[v46.Name] = 1;
				elseif v63[v46.Name] then
					v63[v46.Name] = v63[v46.Name] + 1;
				end;
				l__SpecMeta__32.Value = game:GetService("HttpService"):JSONEncode(v63);
				desummonEffect(v46, v48);
			end);
			game.Debris:AddItem(v46, 20);
			spawn(function()
				wait(17);
				if u7 == true then
					u7 = false;
					local v64 = game:GetService("HttpService"):JSONDecode(l__SpecMeta__32.Value);
					if not v64[v46.Name] then
						v64[v46.Name] = 1;
					elseif v64[v46.Name] then
						v64[v46.Name] = v64[v46.Name] + 1;
					end;
					l__SpecMeta__32.Value = game:GetService("HttpService"):JSONEncode(v64);
					desummonEffect(v46, v48);
				end;
			end);
			wait(v60);
			local v65 = l__WeaponWithdraw__3.soundpt:Clone();
			table.insert(u1, v65);
			game.Debris:AddItem(v65, 3);
			v65.CFrame = CFrame.new(v48.X, v48.Y, v48.Z) * CFrame.Angles(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10));
			v65.Parent = game.Workspace;
			v65.Smashing:Play();
			v65.dust.Color = ColorSequence.new(v47.Color);
			v65.dust:Emit(10);
			for v66 = 1, math.random(3, 5) do
				local v67 = Instance.new("Part");
				v67:CanSetNetworkOwnership(false);
				game.Debris:AddItem(v67, 4);
				v67.Size = Vector3.new(math.random(1, 3), math.random(1, 2), math.random(1, 2));
				v67.Material = v47.Material;
				v67.Color = v47.Color;
				v67.CFrame = v65.CFrame;
				v67.Parent = game.Workspace;
				v67:SetNetworkOwner(nil);
				v67.Velocity = Vector3.new(math.random(-65, 65), math.random(-65, 65), math.random(-65, 65));
			end;
		end;
	end)
end;
return v1;
