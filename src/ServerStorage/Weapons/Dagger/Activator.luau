	-- Decompiled with the Synapse X Luau decompiler.

local v1 = {};
local l__Parent__1 = script.Parent.Parent;
function ActionCheck()
	if not l__Parent__1:FindFirstChild("Humanoid") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("Charge") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("Stun") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("ReturnStun") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("Action") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("Blocking") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("SpellBlocking") then
		return true;
	end;
	if game.CollectionService:HasTag(l__Parent__1, "Unconscious") then
		return true;
	end;
	if game.CollectionService:HasTag(l__Parent__1, "Knocked") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("HeavyAttack") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("LightAttack") then

	else
		return;
	end;
	return true;
end;
local u2 = true;
local l__ComboTimer__3 = l__Parent__1:WaitForChild("ComboTimer");
local l__Combo__4 = l__Parent__1:WaitForChild("Combo");
local u5 = false;
local l__TagHumanoid__6 = game.ServerStorage.Requests.TagHumanoid;
local u7 = require(game.ServerScriptService.Modules.HitDetection);
function v1.Active(p1, p2, p45, p3)
	if ActionCheck() then
		return;
	end;
	if p1:FindFirstChild("NoAttack") then
		return;
	end;
	if p1:FindFirstChild("Grabbing") then
		return;
	end;
	if game.CollectionService:HasTag(p1, "Knocked") then
		return;
	end;
	if not u2 then
		return;
	end;
	u2 = false;
	local v2 = 0.1;
	local l__next__3 = next;
	local v4= p1.Boosts:GetChildren();
	for i = 1,#v4 do
		local v7 = v4[i]
		if v7.Name == "AttackSpeedBoost" then
			v2 = v2 / v7.Value;
		end;	
	end;
	local v8 = Instance.new("Folder");
	v8.Name = "LightAttack";
	v8.Parent = p1;
	game.ServerStorage.Debris:Fire(v8, 0.2 + v2);
	local v9 = Instance.new("Folder");
	v9.Name = "NoJump";
	v9.Parent = p1;
	game.ServerStorage.Debris:Fire(v9, 1);
	local v10 = 0;
	if p3 ~= nil then
		v10 = p3.Stats.Damage.Value;
	end;
	if tick() - l__ComboTimer__3.Value > 1.2 then
		l__Combo__4.Value = 1;
	end;
	l__ComboTimer__3.Value = tick();
	if l__Combo__4.Value >= 6 then
		l__Combo__4.Value = 5;
	end;
	if p1:FindFirstChild("Grabbing") and l__Combo__4.Value == 3 then
		l__Combo__4.Value = 4;
	end;
	if p1:FindFirstChild("Grabbing") and l__Combo__4.Value == 1 then
		l__Combo__4.Value = 2;
	end;
	local v11 = p1.Humanoid:LoadAnimation(game.ReplicatedStorage.CombatAnims["Dagger" .. l__Combo__4.Value]);
	local v12 = 1.05;
	if game.CollectionService:HasTag(p1, "BrokenArm") and l__Combo__4.Value < 6 then
		v12 = 0.8;
	end;
	v11:Play(0.1, 1, v12 * 1.45);
	local l__HumanoidRootPart__8 = p1.HumanoidRootPart;
	v11.KeyframeReached:Connect(function(p4)
		if p4 == "slash" then
			if p3:FindFirstChild("TestTrail") then
				p3.TestTrail.Enabled = true;
			end;
			local v13 = math.random(1, 2);
			if l__Combo__4.Value == 7 then
				l__HumanoidRootPart__8.DaggerSlash2:Play();
			else
				l__HumanoidRootPart__8.DaggerSlash1:Play();
			end;
		end;
		if p4 == "lastframe" and p3:FindFirstChild("TestTrail") then
			p3.TestTrail.Enabled = false;
		end;
	end);
	wait(0.2);
	l__Combo__4.Value = l__Combo__4.Value + 1;
	if l__Combo__4.Value >= 6 then
		u5 = true;
		l__Combo__4.Value = 1;
	end;
	local l__BaneEff__14 = p1:FindFirstChild("BaneEff");
	if not p1:FindFirstChild("Stun") then
		if l__BaneEff__14 then 
			local v15 = {};
			local v16 = nil;
			local v17 = math.huge;
			for v21, v22 in pairs(workspace.Live:GetChildren()) do
				if not v21 then
					break
				end
				local l__Humanoid__23 = v22:FindFirstChild("Humanoid");
				local v24 = l__Humanoid__23 and l__Humanoid__23.RootPart;
				local v25 = false;
				if l__Humanoid__23.Health >= 0 then
					v25 = not game.CollectionService:HasTag(v22, "Unconscious");
				end;
				if v22 ~= p1 and v24 and v25 then
					local l__magnitude__26 = (l__HumanoidRootPart__8.Position - v24.Position).magnitude;
					if l__magnitude__26 <= 20 and (l__HumanoidRootPart__8.CFrame:inverse() * v24.CFrame).Z < 0 then
						v15[v22] = {
							pos = v24.Position, 
							mag = l__magnitude__26
						};
						if l__magnitude__26 < v17 then
							local v27, v28, v29 = workspace:FindPartOnRayWithIgnoreList(Ray.new(l__HumanoidRootPart__8.Position, CFrame.new(l__HumanoidRootPart__8.Position, v24.Position).LookVector * 20 * 1.5), { workspace.Live, workspace.Thrown, workspace.Destructibles, workspace.MonsterSpawns });
							if not v27 then
								v16 = v22;
								v17 = l__magnitude__26;
							end;
						end;
					end;
				end;			
			end;
			if v16 and l__BaneEff__14 and (l__Combo__4.Value == 2 or l__Combo__4.Value == 3 or l__Combo__4.Value == 4) then
				-- TheMaster path's BaneEff is permanent (granted once at spawn, never expires -
				-- see CharacterHandler/init.server.luau), so the blink itself only has a 25%
				-- chance to actually trigger there; a normally-cast (temporary) BaneEff still
				-- procs every time, same as before.
				local masterData = p2 and game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
				local baneChance = (masterData and masterData.Skills.Value:find("TheMaster")) and 25 or 100
				if math.random(1, 100) <= baneChance then
					local v30 = v15[v16];
					v30.mag = 1.5;
					l__HumanoidRootPart__8.ShadowEmitter:Emit(30);
					--l__HumanoidRootPart__8.Blink:Play();
					local l__CFrame__31 = l__HumanoidRootPart__8.CFrame;
					l__HumanoidRootPart__8.CFrame = CFrame.new(v30.pos, l__CFrame__31.p) * CFrame.new(0, 0, -4) * (l__CFrame__31 - l__CFrame__31.p);
				end;
			end;
			for v32, v33 in pairs(v15) do
				if v33.mag <= 9 then
					if u5 == false then
						l__TagHumanoid__6:Fire(p1, v32, {
							physical = true, 
							dagger = true, 
							damage = 3.5 + v10, 
							slash = true,
							poison = (p1:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
						});
					else
						l__TagHumanoid__6:Fire(p1, v32, {
							physical = true, 
							dagger = true, 
							damage = 5 + v10, 
							knockback = true, 
							slash = true,
							poison = (p1:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
						});
					end;
				end;
			end;
		else
			local v34 = {
				physical = true, 
				dagger = true, 
				damage = 3.5 + v10, 
				slash = true,
				poison = (p1:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
			};
			if u5 then
				v34 = {
					physical = true, 
					dagger = true, 
					damage = 5 + v10, 
					knockback = true, 
					slash = true,
					poison = (p1:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
				};
			end;
			u7.magnitudeCheck(p1, l__HumanoidRootPart__8.Position, 9, v34, true);
		end;
	end;
	if u5 then
		local v35 = Instance.new("Folder");
		v35.Name = "Action";
		v35.Parent = p1;
		game.ServerStorage.Debris:Fire(v35, 0.75);
		u5 = false;
		wait(0.1);
	end;
	wait(v2);
	u2 = true;
end;
local u9 = false;
local u10 = 1;
local u1 = require(game.ServerScriptService.Modules.SamuraiModule);
function v1.Active2(p5, p6, p45, p7)
	if p5:FindFirstChild("Grabbing") then
		return;
	end;
	if ActionCheck() then
		return;
	end;
	if p5:FindFirstChild("NoAttack") then
		return;
	end;
	if u9 == true then
		return;
	end;
	if game.CollectionService:HasTag(p5, "Knocked") then
		return;
	end;
	if not u2 then
		return;
	end;
	local l__HumanoidRootPart__36 = p5.HumanoidRootPart;
	if p7.Name:match("Tanto") and not p5.Cooldowns:FindFirstChild("Tanto Cooldown") then
		local CD = Instance.new("NumberValue")
		CD.Name = "Tanto Cooldown"
		CD.Value = 10
		CD.Parent = p5.Cooldowns
		game.Debris:AddItem(CD, 10)
		
		p7.Transparency = 1
		
		u9 = true
		local v39 = Instance.new("Folder");
		v39.Name = "NoJump";
		v39.Parent = p5;
		game.ServerStorage.Debris:Fire(v39, 1);
		
		if tick() - l__ComboTimer__3.Value > 5 then
			u10 = 1;
		end;
		
		local v8 = Instance.new("Folder");
		v8.Name = "Disarm";
		v8.Parent = p5
		
		local action = Instance.new("Folder");
		action.Name = "Action";
		action.Parent = p5;
		Instance.new("Folder", action).Name = "NoDelete"
		
		local katana = game.ServerScriptService.Modules.Commands.Katana:Clone()
		katana.PropWeld.Part0 = p5.Hilt
		katana.PropWeld.Part1 = katana
		katana.Parent = p5.Hilt
		
		p5.HumanoidRootPart.Death:Play()
		p5.HumanoidRootPart.DeathParticle.Particle:Emit(1)
		local anim = p5.Humanoid:LoadAnimation(script.Parent.M1Anim)
		anim:Play(0.1, 1, 0.8);
		task.spawn(function()
			wait(0.17);
			p5.HumanoidRootPart.KatanaUnsheathe:Play();
			u1.glint(p5);
		end);
		anim:GetMarkerReachedSignal("handle"):Connect(function()
			anim:Stop()
			local anim2 = p5.Humanoid:LoadAnimation(script.Parent.Crit)
			anim2:Play(0.1,1,1.13)
			
			anim2:GetMarkerReachedSignal("Slash1"):Connect(function()
				p5.HumanoidRootPart.LordSlash2:Play()
				p5.HumanoidRootPart.TantoSlash1.Particle:Emit(1)
				
				local info = {
					physical = true,
					damage = 9,
					sword = true,
					slash = true,
					blade = true,
					blockbreak = true
				}
				
				u7.magnitudeCheck(p5, p5.HumanoidRootPart.Position, 9, info, true)
			end)
			
			anim2:GetMarkerReachedSignal("Slash2"):Connect(function()
				p5.HumanoidRootPart.LordSlash:Play()
				p5.HumanoidRootPart.TantoSlash2.Particle:Emit(1)

				local info = {
					physical = true,
					damage = 12,
					sword = true,
					slash = true,
					blade = true,
					blockbreak = true,
					knockback = true
				}

				u7.magnitudeCheck(p5, p5.HumanoidRootPart.Position, 9, info, true)
				
				task.wait(0.25)
				
				p7.Transparency = 0
				v8:Destroy()
				action:Destroy()
				katana:Destroy()
				u9 = false
			end)
		end)
		return
	end
	local v37 = Instance.new("Folder");
	u9 = true;
	local v38 = 0;
	if p7 ~= nil then
		v38 = p7.Stats.Damage.Value;
	end;
	v37.Name = "HeavyAttack";
	v37.Parent = p5;
	game.ServerStorage.Debris:Fire(v37, 1.2);
	local v39 = Instance.new("Folder");
	v39.Name = "NoJump";
	v39.Parent = p5;
	game.ServerStorage.Debris:Fire(v39, 1);
	u2 = false;
	if tick() - l__ComboTimer__3.Value > 5 then
		u10 = 1;
	end;
	local v40 = l__HumanoidRootPart__36.ChargePart:Clone();
	l__ComboTimer__3.Value = tick();
	local v41 = p5.Humanoid:LoadAnimation(game.ReplicatedStorage.CombatAnims["DaggerHeavyAnim" .. u10]);
	if u10 == 1 then
		v40.Parent = p5["Right Arm"];
		v40.Enabled = true;
	end;
	v41:Play(0.1, 1, 1.25);
	l__HumanoidRootPart__36.DaggerCharge:Play();
	game.ServerStorage.Debris:Fire(v40, 0.5);
	wait(0.125);
	v41:AdjustSpeed(0);
	spawn(function()
		wait(0.7);
		v41:Stop();
	end);
	wait(0.35);
	if p7:FindFirstChild("TestTrail") then
		p7.TestTrail.Enabled = true;
	end;
	l__HumanoidRootPart__36.DaggerSlash2:Play();
	v41.KeyframeReached:Connect(function(p8)
		if p8 == "final" and p7:FindFirstChild("TestTrail") then
			p7.TestTrail.Enabled = false;
		end;
	end);
	if u10 == 2 then
		v41:AdjustSpeed(1);
	else
		v41:AdjustSpeed(1.5);
	end;
	u10 = u10 + 1;
	if u10 >= 1 then
		u10 = 1;
	end;
	spawn(function()
		wait(1);
		if p7:FindFirstChild("TestTrail") then
			p7.TestTrail.Enabled = false;
		end;
	end);
	local v42 = Instance.new("Folder");
	v42.Name = "Action";
	v42.Parent = p5;
	game.ServerStorage.Debris:Fire(v42, 1.3);
	if not p5:FindFirstChild("Stun") and not p5:FindFirstChild("NoDam") then
		u7.magnitudeCheck(p5, l__HumanoidRootPart__36.Position, 8.5, {
			physical = true, 
			damage = 5 + v38, 
			knockback = true, 
			dagger = true, 
			blockbreak = true, 
			slash = true,
			poison = (p5:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
		});
	end;
	wait(0.35);
	l__Combo__4.Value = 1;
	u5 = false;
	u2 = true;
	wait(1.5);
	u9 = false;
end;
return v1;
