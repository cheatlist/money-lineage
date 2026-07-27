local v1 = {};
local l__Parent__2 = script.Parent.Parent;
function sub(...)
	coroutine.wrap(...)();
end;
local l__TweenService__3 = game:GetService("TweenService");
local v4 = require(game.ServerScriptService.Modules.HitDetection);
en = true;
local u1 = require(game.ServerScriptService.Modules.SamuraiModule);
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;
function v1.Active(p1, p2, p3, p4) --p1 = player, p2 = ?, p3 = ?, p4 = ?
	if p1:FindFirstChild("ShuraStealth") then
		-- "press m1 to lose invisibility and cancel the thing": unconditional, happens even if
		-- the surprise-attack itself can't fire below (e.g. Blade Flash M1 still on cooldown) -
		-- that's the risk of choosing this over "double down" on Active2
		local ref = p1.ShuraStealth:FindFirstChild("TransparencyRef")
		if ref and ref.Value then
			ref.Value:Destroy()
		end
		p1.ShuraStealth:Destroy()
	end
	if u1.ActionCheck(p1)then
		return
	end
	if p1:FindFirstChild("Knocked")then
		return
	end
	if p1.Cooldowns:FindFirstChild("Blade Flash M1") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Blade Flash M1"
	CD.Value = 11
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 11)
	en = false;
	local v5 = u1.isCalm(p1);
	local v6 = game.ServerStorage.PlayerData:FindFirstChild(p1.Name).Skills.Value:find("Sheathe Mastery")
	local playerdata = game.ServerStorage.PlayerData:FindFirstChild(p1.Name)
	local shura = playerdata and playerdata.Skills.Value:find("Shura")
	local selftaught = playerdata and playerdata.Skills.Value:find("Selftaught")
	if shura then
		-- instant: no windup animation, resolves the hit immediately instead of waiting for
		-- M1Anim's "handle" marker; reuses the existing KatanaSlash sound pitched way up instead
		-- of the vanilla SwordCharge/KatanaUnsheathe/Sheathe sound sequence (no new asset needed)
		local root = p1.HumanoidRootPart
		local slash = root.KatanaSlash:Clone()
		slash.PlaybackSpeed = root.KatanaSlash.PlaybackSpeed * 1.8
		slash.Parent = root
		slash:Play()
		game.Debris:AddItem(slash, 3)
		local target = nil
		local lastname = playerdata.LastName.Value
		for _,v in pairs(workspace.Live:GetChildren()) do
			local vname = game.ServerStorage.PlayerData:FindFirstChild(v.Name) and game.ServerStorage.PlayerData[v.Name].LastName.Value
			if (not vname or vname ~= lastname or lastname == "") and v ~= p1 then
				local rel = root.CFrame:inverse() * v.HumanoidRootPart.CFrame
				if rel.Z < 5 and -29 < rel.Z and math.abs(rel.X) < 29 and math.abs(rel.Y) < 29 then
					target = v
					break
				end
			end
		end
		if target then
			u1.slash(target, v5)
			l__TagHumanoid__2:Fire(p1, target, {
				damage = 10,
				physical = true,
				slash = true,
				katana = true,
				noparry = true,
				executes = v5,
				move = "Blade Flash",
			})
		end
		wait(10)
		en = true
		return
	end
	local v7 = 9;
	if v6 then
		v7 = 0.65;
	end;
	local l__HumanoidRootPart__8 = p1.HumanoidRootPart;
	local v9 = Instance.new("Folder");
	v9.Name = "Action";
	v9.Parent = p1;
	local v10 = 0.65
	if v6 then
		v10 = 0.2;
	end;
	game.Debris:AddItem(v9, v10);
	p1.HumanoidRootPart.SworderEmit:Emit(30);
	l__HumanoidRootPart__8.SwordCharge:Play();
	local v11 = p1.Humanoid:LoadAnimation(script.Parent.M1Anim);
	v11:Play(0.1, 1, v7);
	task.spawn(function()
		wait(0.17);
		l__HumanoidRootPart__8.KatanaUnsheathe:Play();
		u1.glint(p1);
	end);
	v11:GetMarkerReachedSignal("handle"):Connect(function()
		local v12 = script.Parent:FindFirstChild("Sheathe"):Clone();
		game.Debris:AddItem(v12, 2);
		v12.Parent = l__HumanoidRootPart__8;
		v12:Play();
		local v13 = nil;
		local l__Value__14 = game.ServerStorage.PlayerData[p1.Name].LastName.Value;
		local v15 = 20;
		if v6 then
			v15 = 35;
		end;
		local v16 = selftaught and 100 or 29;
		local v17 = selftaught and 100 or 29;
		local v18, v19, v20 = pairs(workspace.Live:GetChildren());
		for v21, v22 in pairs(v19) do
			local v23 = game.ServerStorage.PlayerData:FindFirstChild(v22.Name) and game.ServerStorage.PlayerData[v22.Name].LastName.Value;
			if not v23 or v23 ~= l__Value__14 or l__Value__14 == "" and v22 ~= p1 then
				local v24 = l__HumanoidRootPart__8.CFrame:inverse() * v22.HumanoidRootPart.CFrame;
				if v24.Z < 5 and -v16 < v24.Z and math.abs(v24.X) < v17 and math.abs(v24.Y) < v17 then
					v13 = v22;
					break;
				end;
			end;
		end
		local v25 = 0.5;
		if v6 then
			v25 = 0.1;
		end;
		wait(v25);
		if v13 then
			if selftaught then
				-- teleport-hit-slash: "sheathes like normal" (the vanilla windup/Sheathe sound
				-- above is untouched) but instead of striking wherever the caster is standing,
				-- teleports them right up to the target first - this is what lets the 100-stud
				-- range above actually connect a hit rather than just widening a whiff-range box
				l__HumanoidRootPart__8.CFrame = v13.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
			end
			u1.slash(v13, v5);
			local v26 = {};
			local v27 = 5;
			if v5 then
				v27 = 10;
			end;
			v26.damage = 10;
			v26.physical = true;
			v26.slash = true;
			v26.katana = true;
			v26.noparry = true;
			v26.executes = v5;
			v26.move = "Blade Flash"
			if selftaught then
				v26.stun = 1.3
			end
			l__TagHumanoid__2:Fire(p1, v13, v26);
		end;
	end);
	wait(10);
	en = true;
end;
local u3 = true;
local u4 = require(game.ServerScriptService.Modules.TransparencyModule);
local function runBladeFlashM2(p4, p5, p6, p7)
	u3 = false;
	local v28 = Instance.new("Folder");
	v28.Name = "Action";
	v28.Parent = p4;
	game.Debris:AddItem(v28, 1.7);
	local v29 = u1.isCalm(p4);
	local v30 = u1.hasParticles(p4);
	local l__HumanoidRootPart__30 = p4.HumanoidRootPart;
	local v31 = p4.Humanoid:LoadAnimation(script.Parent.M2Anim);
	v31:Play(0.1, 1, 1.5);
	l__HumanoidRootPart__30.KatanaUnsheathe:Play();
	task.spawn(function()
		wait(0.3);
		u1.glint(p4);
	end);
	wait(0.39999999999999997);
	v31:AdjustSpeed(0);
	l__HumanoidRootPart__30.Sonido.TimePosition = 0.5;
	l__HumanoidRootPart__30.Sonido:Play();
	if v30 == true then
		game.ReplicatedStorage.Requests.KatanaSkillFX:FireAllClients("windswirl2", false, l__HumanoidRootPart__30, p7);
	else
		game.ReplicatedStorage.Requests.KatanaSkillFX:FireAllClients("windswirl", nil, l__HumanoidRootPart__30, p7);
	end
	local v32 = Instance.new("NumberValue");
	v32.Name = "Transparency";
	v32.Value = 1;
	v32.Parent = p4.Boosts;
	game.Debris:AddItem(v32, 0.3);
	local v33 = Instance.new("Folder", p4);
	v33.Name = "Immortal";
	game.Debris:AddItem(v33, 0.3);
	local v34 = Instance.new("Folder", p4);
	v34.Name = "FallDamageBypass";
	game.Debris:AddItem(v34, 0.3);
	local v35 = nil;
	local l__Value__36 = game.ServerStorage.PlayerData[p4.Name].LastName.Value;
	local Weapon = "Katana";
	local v37 = 29;
	local v38 = 29;
	local l__CFrame__39 = l__HumanoidRootPart__30.CFrame;
	local v40 = RaycastParams.new();
	v40.IgnoreWater = true;
	v40.FilterType = Enum.RaycastFilterType.Exclude;
	v40.FilterDescendantsInstances = { workspace.Live, workspace.Thrown, workspace.Terrain, workspace.MonsterSpawns };
	local v41 = workspace:Raycast(l__CFrame__39.p, l__CFrame__39.LookVector * v37, v40);
	if v41 then
		v37 = (l__CFrame__39.p - v41.Position).Magnitude - 1;
	end;
	for v45, v46 in pairs(game.Workspace.Live:GetChildren()) do
		local v47 = game.ServerStorage.PlayerData:FindFirstChild(v46.Name) and game.ServerStorage.PlayerData[v46.Name].LastName.Value;
		if not v47 or v47 ~= l__Value__36 or l__Value__36 == "" and v46 ~= p4 then
			local v48 = l__HumanoidRootPart__30.CFrame:inverse() * v46.HumanoidRootPart.CFrame;
			if v48.Z < 5 and -(v37 + 6 - 5) < v48.Z and math.abs(v48.X) < v38 and math.abs(v48.Y) < v38 then
				v35 = v46;
				break;
			end;
		end;	
	end;
	wait(0.3);	
	v31:AdjustSpeed(1);
	local v49 = script.Parent:FindFirstChild("Sheathe"):Clone();
	game.Debris:AddItem(v49, 2);
	v49.Parent = l__HumanoidRootPart__30;
	v49:Play();
	print(v35)
	l__HumanoidRootPart__30.CFrame = l__HumanoidRootPart__30.CFrame * CFrame.new(0, 0, -v37);
	game.ReplicatedStorage.Requests.KatanaSkillFX:FireAllClients("dashline", v29, l__HumanoidRootPart__30, p7, {
		from = l__HumanoidRootPart__30.Position
	});
	if v35 then
		l__HumanoidRootPart__30.HeavySlash:Play();
		u1.slash(v35, v29);
		l__TagHumanoid__2:Fire(p4, v35, {
			damage = 11, 
			physical = true, 
			slash = true, 
			darkburn = v30,
			katana = true, 
			noparry = true, 
			executes = v29,
			move = "Blade Flash"
		});
	end;
	wait(20);
	u3 = true;
end;
function v1.Active2(p4, p5, p6, p7)
	if u1.ActionCheck(p4) then
		return;
	end;
	if game.CollectionService:HasTag(p4, "Knocked") then
		return;
	end;
	if not game.ServerStorage.PlayerData:FindFirstChild(p4.Name).Skills.Value:find("Sheathe Mastery") then
		return;
	end;
	local playerdata2 = game.ServerStorage.PlayerData:FindFirstChild(p4.Name)
	local shura = playerdata2 and playerdata2.Skills.Value:find("Shura")
	if playerdata2 and playerdata2.Skills.Value:find("Selftaught") then
		-- "no m2 variant": Selftaught's Blade Flash is M1-only, per the design brief
		return
	end
	if shura and p4:FindFirstChild("ShuraStealth") then
		-- second M2 press ("double down"): drop invisibility and run the normal dash-strike,
		-- reusing the cooldown already consumed by the first press below
		local ref = p4.ShuraStealth:FindFirstChild("TransparencyRef")
		if ref and ref.Value then
			ref.Value:Destroy()
		end
		p4.ShuraStealth:Destroy()
		runBladeFlashM2(p4, p5, p6, p7)
		return
	end
	if p4.Cooldowns:FindFirstChild("Blade Flash M2") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Blade Flash M2"
	CD.Value = 20
	CD.Parent = p4.Cooldowns
	game.Debris:AddItem(CD, 20)
	if shura then
		-- first M2 press: go invisible and wait for the player's next decision (M1 on this same
		-- Tool = surprise attack, M2 again = double down) instead of attacking immediately.
		-- The Transparency NumberValue must be literally named "Transparency" to be picked up by
		-- CharacterHandler's Boosts.ChildAdded listener (the real render trigger for invisibility
		-- everywhere in this codebase) - so a separate ObjectValue pointer is what lets the
		-- second press find and destroy this *specific* instance later without accidentally
		-- destroying some unrelated "Transparency" boost the player might also be under.
		local stealth = Instance.new("Folder")
		stealth.Name = "ShuraStealth"
		stealth.Parent = p4
		game.Debris:AddItem(stealth, 8) -- safety timeout: can never get stuck invisible forever
		local t = Instance.new("NumberValue")
		t.Name = "Transparency"
		t.Value = 1
		t.Parent = p4.Boosts
		game.Debris:AddItem(t, 8)
		local ref = Instance.new("ObjectValue")
		ref.Name = "TransparencyRef"
		ref.Value = t
		ref.Parent = stealth
		game.Debris:AddItem(ref, 8)
		return
	end
	runBladeFlashM2(p4, p5, p6, p7)
end;
return v1;
