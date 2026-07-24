local v1 = {};
v1.upperbound = 0;
v1.lowerbound = 0;
v1.signs = 0;
v1.cost = 2;
local l__WeaponTake__1 = game.ServerStorage.SpellEffects.WeaponTake;
local l__TweenService__2 = game:GetService("TweenService");
local function desummonEffect(p1)
	local v2 = l__WeaponTake__1.summon:Clone();
	v2.Parent = p1;
	v2:play();
	local v3 = l__WeaponTake__1.Glow:Clone();
	v3.Parent = p1;
	v3.Range = 0;
	local v4 = TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
	local v5 = l__TweenService__2:Create(p1, v4, {
		Color = Color3.fromRGB(245, 205, 48), 
		Transparency = 0.4
	}):Play();
	local v6 = l__TweenService__2:Create(v3, v4, {
		Range = 6
	}):Play();
	wait(0.8);
	local v7 = l__WeaponTake__1.LightCube:Clone();
	game.Debris:AddItem(v7, 3.5);
	v7.Transparency = 1;
	v7:ClearAllChildren();
	v7.CFrame = p1.CFrame;
	v7.Parent = game.Workspace;
	local v8 = l__WeaponTake__1.breakweapon:Clone();
	v8.Parent = v7;
	v8:Play();
	local v9 = 1 - 1;
	while true do
		local v10 = l__WeaponTake__1.LightCube:Clone();
		game.Debris:AddItem(v10, 3);
		local v11 = p1.Size.X / 2;
		local v12 = p1.Size.Y / 2;
		local v13 = p1.Size.Z / 2;
		v10.CFrame = p1.CFrame * CFrame.new(math.random(-v11, v11), math.random(-v12, v12), math.random(-v13, v13));
		v10.Parent = game.Workspace;
		local v14 = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
		local v15 = l__TweenService__2:Create(v10, v14, {
			CFrame = CFrame.new(p1.CFrame.X, p1.CFrame.Y, p1.CFrame.Z) * CFrame.new(math.random(-4, 4), math.random(7, 10), math.random(-4, 4)) * CFrame.Angles(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)), 
			Transparency = 1
		}):Play();
		local v16 = l__TweenService__2:Create(v10.PointLight, v14, {
			Range = 0
		}):Play();
		if 0 <= 1 then
			if v9 < 8 then

			else
				break;
			end;
		elseif 8 < v9 then

		else
			break;
		end;
		v9 = v9 + 1;	
	end;
	p1:Destroy();
end;
function v1.Activate(p2, p3, p4, p5)
	if game.CollectionService:HasTag(p3, "Casting") then
		return;
	end;
	local v17 = game.Players:GetPlayerFromCharacter(p3);
	local v18 = v17 and game.ServerStorage.PlayerData:FindFirstChild(v17.Name);
	local l__SpecMeta__19 = v18.SpecMeta;
	if not v18 or not v17:FindFirstChildOfClass("Backpack").ManaColor or not p3:FindFirstChild("HumanoidRootPart") then
		return;
	end;
	if p3.Mana.Value < v1.cost then
		return;
	end;
	local l__Value__20 = v18.PrimaryWeapon.Value;
	if l__Value__20 == "" then
		return;
	end;
	if l__Value__20 == "None" then
		return
	end
	if l__Value__20:match("Energy") then
		return;
	end;
	if l__Value__20:match("Abomination") then
		return;
	end;
	if l__Value__20:match("Fairfrozen") then
		return;
	end;
	if l__Value__20:match("Tome") then
		return;
	end;
	if p3:FindFirstChild("FurariSelfCD") then
		return;
	end;
	local v21 = Instance.new("StringValue", p3);
	v21.Name = "FurariSelfCD";
	game.Debris:AddItem(v21, 1.5);
	local v22 = nil;
	local l__next__23 = next;
	local v24, v25 = p3.Torso:GetChildren();

	while true do
		local v26, v27 = l__next__23(v24, v25);
		if not v26 then
			break;
		end;
		v25 = v26;
		if v27:FindFirstChild("Prop") and not game.CollectionService:HasTag(v27, "SideProp") then
			v22 = v27;
		end;	
	end;
	if v22 ~= nil then
		desummonEffect(v22);
	end;
	wait();
	if v18.PrimaryWeapon.Value ~= "" then
		local UsedVerto = Instance.new("Folder", v17)
		UsedVerto.Name = "UsedVerto"
		game.Debris:AddItem(UsedVerto, 2)
		v18.PrimaryWeapon.Value = "None";
		v18.Weapon.Value = "";
		local v28 = game:GetService("HttpService"):JSONDecode(l__SpecMeta__19.Value);
		if not v28[l__Value__20] then
			v28[l__Value__20] = 1;
		elseif v28[l__Value__20] then
			v28[l__Value__20] = v28[l__Value__20] + 1;
		end;
		l__SpecMeta__19.Value = game:GetService("HttpService"):JSONEncode(v28);
	end;
end;
local u3 = {
	upperbound = 0, 
	lowerbound = 0, 
	signs = 0, 
	cost = 2
};
local l__Parent__4 = script.Parent;
function u3.Activate(p6, p7, p8, p9)
	if game.CollectionService:HasTag(p7, "Casting") then
		return;
	end;
	local v29 = game.Players:GetPlayerFromCharacter(p7);
	local v30 = v29 and game.ServerStorage.PlayerData:FindFirstChild(v29.Name);
	local l__SpecMeta__31 = v30.SpecMeta;
	local v32 = v30 and v29:FindFirstChildOfClass("Backpack").ManaColor
	local v33 = v32 and v29:FindFirstChild("GetWeaponSelection");
	if not v33 then
		return;
	end;
	if not v32 or not p7:FindFirstChild("HumanoidRootPart") then
		return;
	end;
	if v30.PrimaryWeapon.Value ~= "" and v30.PrimaryWeapon.Value ~= "None" then
		return;
	end;
	local v34 = v33:InvokeClient(v29);
	if not v34 then
		return;
	end;
	local v35 = game:GetService("HttpService"):JSONDecode(l__SpecMeta__31.Value);
	--[[
	if v34:match("Fairfrozen") and v35[v34] then
		v35[v34] = nil;
		l__SpecMeta__31.Value = game:GetService("HttpService"):JSONEncode(v35);
		return;
	end;]]--
	if not v35[v34]or v35[v34] < 1 then
		return;
	end;
	local v36 = Instance.new("Accessory");
	v36.Name = "Action";
	v36.Parent = p7;
	Instance.new("Folder", v36).Name = "NoDelete"
	game:GetService("Debris"):AddItem(v36, 2);
	p7.Humanoid.AutoRotate = false;
	local v37 = p7.Humanoid:LoadAnimation(script.Aptet);
	v37:Play();
	wait(0.15);
	local UsedVerto = Instance.new("Folder", v29)
	UsedVerto.Name = "UsedVerto"
	game.Debris:AddItem(UsedVerto, 2)
	local v38 = l__WeaponTake__1.summon:Clone();
	game.Debris:AddItem(v38, 3);
	v38.Parent = p7.Torso;
	v38:Play();
	if v35[v34] == 1 then
		v35[v34] = nil
		l__SpecMeta__31.Value = game:GetService("HttpService"):JSONEncode(v35);
		v30.PrimaryWeapon.Value = v34;
	elseif v35[v34] > 1 then
		v35[v34] -= 1;
		l__SpecMeta__31.Value = game:GetService("HttpService"):JSONEncode(v35);
		v30.PrimaryWeapon.Value = v34;
	end
	l__Parent__4.Parent = v29.Backpack;
	wait(0.1);
	for Indx, Obj in ipairs(v29.Backpack:GetChildren())do
		if Obj:FindFirstChild'PrimaryWeapon'then
			Obj.Parent = p7
		end
	end
	wait(0.1);
	for Indx, Obj in ipairs(p7.Hilt:GetChildren())do
		if Obj:FindFirstChild'Prop'and not game:GetService'CollectionService':HasTag(Obj, 'SideProp')then
			Obj.Transparency = 1
		end
	end
	local v49 = game.ServerStorage.verto:FindFirstChild(v34);
	local v50: number = v49.Size.X;
	if v50 < v49.Size.Y then
		v50 = v49.Size.Y;
	end;
	if v50 < v49.Size.Z then
		v50 = v49.Size.Z;
	end;
	local v51 = {};
	local v52 = math.floor(math.floor(v50) / 0.4);
	local v53 = p7["Right Arm"].CFrame * CFrame.new(0, -1.2, 0);
	local v57 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
	for v54: number = 1, v52 do
		local v55 = l__WeaponTake__1.LightCube:Clone();
		game.Debris:AddItem(v55, 2.5);
		table.insert(v51, v55);
		v55.Transparency = 1;
		local v56 = CFrame.new(p7["Right Arm"].CFrame.X, p7["Right Arm"].CFrame.Y, p7["Right Arm"].CFrame.Z);
		v55.CFrame = v56 * CFrame.new(math.random(-4, 4), math.random(7, 10), math.random(-4, 4)) * CFrame.Angles(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20));
		v55.Parent = workspace;
		local v58 = v53 * CFrame.new(math.random(-14, 14) / 100, -0.4 * v54 + 0.4, math.random(-2, 2) / 100);
		l__TweenService__2:Create(v55, v57, {
			CFrame = v58, 
			Transparency = 0.6
		}):Play();
		if v54 < v52 / 3 or math.random(1, 2) == 1 and v54 < v52 / 1.2 then
			local v60 = l__WeaponTake__1.LightCube:Clone();
			game.Debris:AddItem(v60, 2.5);
			table.insert(v51, v60);
			v60.CFrame = v56 * CFrame.new(math.random(-4, 4), math.random(7, 10), math.random(-4, 4)) * CFrame.Angles(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20));
			v60.Parent = workspace;
			l__TweenService__2:Create(v60, v57, {
				CFrame = v58 * CFrame.new(-0.30000000000000004, 0, math.random(-2, 2) / 100), 
				Transparency = 0.6
			}):Play();
		end;
		wait(0.015);
	end;
	wait(0.3);
	for v62: number = 1, #v51 do
		l__TweenService__2:Create(v51[v62], TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Transparency = 0
		}):Play();
	end;
	wait(0.1);
	local v64 = nil;
	local v65 = nil;
	for Indx, Obj in ipairs(p7.Hilt:GetChildren())do
		if Obj:FindFirstChild("Prop") and not game.CollectionService:HasTag(Obj, "SideProp") then
			Obj.Transparency = 0.4;
			v64 = Obj.Color;
			Obj.BrickColor = BrickColor.new("Bright yellow");
			Obj.Color = Color3.fromRGB(245, 205, 48);
			v65 = Obj
		end;
	end
	for v71: number = 1, #v51 do
		l__TweenService__2:Create(v51[v71], TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play();
		wait(0.005);
	end;
	if v65 then
		l__TweenService__2:Create(v65, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Color = v64, 
			Transparency = 0
		}):Play();
	end;
	wait(0.15);
	p7.Humanoid.AutoRotate = true;
	v37:Stop();
end;
v1.alternate = u3;
return v1;
