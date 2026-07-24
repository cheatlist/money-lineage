-- Decompiled with the Synapse X Luau decompiler.

local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;
local l__Parent__1 = script.Parent.Parent;
function ActionCheck()
	if not l__Parent__1:FindFirstChild("Humanoid") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("NoAttack") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("Charge") and not l__Parent__1.Artifacts:FindFirstChild("Unwavering Focus") then
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
local u3 = false;
local l__ComboTimer__4 = l__Parent__1:WaitForChild("ComboTimer");
local l__Combo__5 = l__Parent__1:WaitForChild("Combo");
local u6 = false;
local u7 = false;
local u8 = require(game.ServerScriptService.Modules.HitDetection);
function v1.Active(p1, p2, p3, p4)
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
	if p1:FindFirstChild("Rolling") then
		return;
	end;
	if not u2 then
		return;
	end;
	if p1:FindFirstChild("Stun") then
		return;
	end;
	u3 = false;
	if p4:FindFirstChild("Poison") then
		u3 = true;
	end;
	local isvang = false
	if p2.Backpack:FindFirstChild("VanguardT") then
		isvang = true
	end
	local l__Value__3 = p4.Stats.Speed.Value;
	local v4 = p4.Stats.Length.Value;
	local l__Value__5 = p4.Stats.Damage.Value;
	--game.ReplicatedStorage.Requests.ClientSprint:FireClient(p2);
	local l__HumanoidRootPart__6 = p1.HumanoidRootPart;
	local l__Humanoid__7 = p1.Humanoid;
	u2 = false;
	if tick() - l__ComboTimer__4.Value > 1.5 then
		l__Combo__5.Value = 1;
	end;
	l__ComboTimer__4.Value = tick();
	if l__Combo__5.Value >= 4 then
		l__Combo__5.Value = 3;
	end;
	local v8 = l__Humanoid__7:LoadAnimation(p3["Greatsword" .. l__Combo__5.Value]);
	if p2.Backpack:FindFirstChild("TemplarTraining") then
		v8 = l__Humanoid__7:LoadAnimation(p3["Templar" .. l__Combo__5.Value]);
	elseif p2.Backpack:FindFirstChild("OffhandDagger") then
		v8 = l__Humanoid__7:LoadAnimation(p3["Farron" .. l__Combo__5.Value]);
	elseif p2.Backpack:FindFirstChild("Abysswalker") then
		v8 = l__Humanoid__7:LoadAnimation(p3["Abyss" .. l__Combo__5.Value]);
	elseif isvang then
		v8 = l__Humanoid__7:LoadAnimation(p3["Vanguard" .. l__Combo__5.Value])
	end
	--[[
	if not p2.Backpack:FindFirstChild("Abysswalker") then
		local v8 = l__Humanoid__7:LoadAnimation(p3["Greatsword" .. l__Combo__5.Value]);
	elseif not p2.Backpack:FindFirstChild("OffhandDagger") then
		v8 = l__Humanoid__7:LoadAnimation(p3["Abyss" .. l__Combo__5.Value]);
	else
		v8 = l__Humanoid__7:LoadAnimation(p3["Farron" .. l__Combo__5.Value]);
	end;
	--]]
	if p2.Backpack:FindFirstChild("OffhandDagger") and not p1.Boosts:FindFirstChild("SuperStrength") then
		local v9 = Instance.new("Accessory");
		v9.Name = "SuperStrength";
		v9.Parent = p1.Boosts;
	end;
	local firsthit = false
	if l__Combo__5.Value == 1 then
		firsthit = true
	end
	local v10 = 1 + l__Value__3;
	if game.CollectionService:HasTag(p1, "BrokenArm") and l__Combo__5.Value < 6 then
		v10 = 0.5 + l__Value__3;
	end;
	if p2.Backpack:FindFirstChild("Abysswalker") then
		local v11 = Instance.new("Accessory");
		v11.Name = "SuperStrength";
		v11.Parent = p1.Boosts;
		game:GetService("Debris"):AddItem(v11, 1);
	end;
	if p2.Backpack:FindFirstChild("OffhandDagger") then
		game.ReplicatedStorage.Requests.ClearDodgeVels:FireClient(p2);
		v10 = 1;
		local v12 = Instance.new("BodyVelocity");
		game.CollectionService:AddTag(v12, "AllowedBM");
		v12.Name = "ForwardVelocity";
		v12.MaxForce = Vector3.new(0, 0, 0);
		v12.Velocity = l__HumanoidRootPart__6.CFrame.lookVector.unit * 40;
		v12.Parent = l__HumanoidRootPart__6;
		game.Debris:AddItem(v12, 0.5);
		game.TweenService:Create(v12, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			MaxForce = Vector3.new(80000, 0, 80000)
		}):Play();
	end;
	v8:Play(0.1, 1, v10 * 1.45);
	v8.KeyframeReached:Connect(function(p5)
		if p5 == "slash" then
			if p4 and p4:FindFirstChild("TestTrail") then
				if p1:FindFirstChild("VanguardBuff") then
					p4.TestTrail.Color = ColorSequence.new(Color3.new(0.227451, 0.627451, 1))
				else
					p4.TestTrail.Color = ColorSequence.new(Color3.new(1, 1, 1))
				end;
				p4.TestTrail.Enabled = true;
			end;
			local v13 = math.random(1, 2);
			--[[
			if p4.Name == "Lunar Greatsword" then

			else
				l__HumanoidRootPart__6.Greatswordswing:Play();
			end
			]]
		end;
		if p5 == "lastframe" and p4 and p4:FindFirstChild("TestTrail") then
			p4.TestTrail.Enabled = false;
		end;
	end);
	u6 = true;
	local v14 = true;
	local v15 = 0.3 / v10;
	if not p2.Backpack:FindFirstChild("Abysswalker") then
		if l__Combo__5.Value < 3 then
			v15 = 0.125 / v10;
		end;
	elseif p2.Backpack:FindFirstChild("OffhandDagger") and not u7 then
		v15 = 0;
	end;
	if l__Combo__5.Value < 3 and not p2.Backpack:FindFirstChild("Abysswalker") then
		local v16 = Instance.new("Folder");
		v16.Name = "LightAttack";
		v16.Parent = p1;
		game:GetService("Debris"):AddItem(v16, 0.25 + v15);
		local v17 = Instance.new("Folder");
		v17.Name = "NoJump";
		v17.Parent = p1;
		game:GetService("Debris"):AddItem(v17, 1);
		wait(0.25);
		p1.HumanoidRootPart.Swing:Play();
		if isvang then
			p1.HumanoidRootPart.Greatswordswing:Play();
		end;
	else
		local v18 = Instance.new("Folder");
		v18.Name = "HeavyAttack";
		v18.Parent = p1;
		game:GetService("Debris"):AddItem(v18, 0.4 + v15);
		local v19 = Instance.new("Folder");
		v19.Name = "NoJump";
		v19.Parent = p1;
		game:GetService("Debris"):AddItem(v19, 1);
		if p1:FindFirstChild("Stun") then
			u2 = true;
			return;
		end;
		if not p2.Backpack:FindFirstChild("OffhandDagger") then
			if l__Combo__5.Value ~= 3 then
				if not isvang then
					wait(0.55 / v10);
				else
					wait(0.2);
				end
				if p1:FindFirstChild("Stun") then
					u2 = true;
					return;
				end;
				if l__Combo__5.Value == 1 then
					v14 = false;
				end;
				if p4 or isvang then
					p1.HumanoidRootPart.Greatswordswing:Play();
				end;
			else
				if not isvang then
					wait(0.55 / v10);
				else
					wait(0.2);
				end
				if p1:FindFirstChild("Stun") then
					u2 = true;
					return;
				end;
				if p4 or isvang  then
					p1.HumanoidRootPart.Greatswordswing:Play();
				end;
				sub(function()
					if p4:FindFirstChild("Attachmentz") and not isvang then
						p4.Attachmentz.DUST:Emit(30);
					end;
					if not isvang then
						wait(0.2 / v10);
					end
					if p1:FindFirstChild("Stun") then
						u2 = true;
						return;
					end;
					if p4  and not isvang  then
						p1.HumanoidRootPart.Greatswordhit:Play();
					end;
				end);
			end;
		else
			local v20 = tick();
			local v21 = 0.4 / v10;
			if p1:FindFirstChild("Stun") then
				u2 = true;
				return;
			end;
			local v22 = {};
			local v23 = {
				physical = true, 
				sword = true, 
				damage = l__Value__5 / 4, 
				slash = true
			};
			local v24 = {
				physical = true, 
				sword = true, 
				damage = l__Value__5 / 2, 
				slash = true
			};
			while true do
				u8.magnitudeCheck(p1, (l__HumanoidRootPart__6.CFrame * CFrame.new(0, 0, -1)).p, v4, v23, true, false, nil, v22);
				wait();
				if v21 < tick() - v20 then
					break;
				end;			
			end;
			if l__Combo__5.Value == 3 then
				v24.knockback = true;
			end;
			if not p1:FindFirstChild("Stun") and not p1:FindFirstChild("NoDam") then
				u8.magnitudeCheck(p1, l__HumanoidRootPart__6.Position, v4, v24, true);
			end;
			if p4 and not isvang then
				p1.HumanoidRootPart.Greatswordhit:Play();
			end;
		end;
	end;
	if p1:FindFirstChild("Stun") then
		u2 = true;
		return;
	end;
	u6 = false;
	if not p2.Backpack:FindFirstChild("Abysswalker") and l__Combo__5.Value < 3 then
		v4 = 8.5;
	end;
	l__Combo__5.Value = l__Combo__5.Value + 1;
	if l__Combo__5.Value >= 4 then
		u7 = true;
		l__Combo__5.Value = 1;
		local v25 = Instance.new("Folder");
		v25.Name = "Action";
		v25.Parent = p1;
		game:GetService("Debris"):AddItem(v25, 0.75 / v10);
	end;
	if not p2.Backpack:FindFirstChild("OffhandDagger") then
		local v26 = {
			physical = true, 
			sword = true, 
			damage = l__Value__5, 
			knockback = true, 
			slash = true
		};
		if u7 or p2.Backpack:FindFirstChild("Abysswalker") then
			v26 = {
				physical = true, 
				sword = true, 
				damage = l__Value__5 * 1.2, 
				knockback = true, 
				slash = true
			};
		else
			v26 = {
				physical = true, 
				slash = isvang,
				sword = isvang,
				fist = true,
				damage = 9
			};
		end;
		if p1:FindFirstChild("VanguardBuff") then
			v26.vanguardflame = true
		end
		if isvang then 
			v26.fist = false
			v26.damage = 11.5
			v26.move = "Azure Ignition"
		end
		if firsthit then
			v26.aoe = true
		end
		if not p1:FindFirstChild("Stun") and not p1:FindFirstChild("NoDam") then
			u8.magnitudeCheck(p1, l__HumanoidRootPart__6.Position, v4, v26, v14);
		end;
	end;
	if u7 then
		local v27 = Instance.new("Folder");
		v27.Name = "Action";
		v27.Parent = p1;
		game:GetService("Debris"):AddItem(v27, 0.75 / v10);
		u7 = false;
		wait(0.1);
	end;
	wait(v15);
	u2 = true;
end;
local u9 = false;
local u10 = 1;
function v1.Active2(p6, p7, p8, p9)
	if p6:FindFirstChild("Grabbing") then
		return;
	end;
	if ActionCheck() then
		return;
	end;
	if p6:FindFirstChild("NoAttack") then
		return;
	end;
	if u9 == true then
		return;
	end;
	if game.CollectionService:HasTag(p6, "Knocked") then
		return;
	end;
	if not u2 then
		return;
	end;
	--game.ReplicatedStorage.Requests.ClientSprint:FireClient(p7);
	if p9:FindFirstChild("Poison") then
		u3 = true;
	end;
	local v28 = 1 + p9.Stats.Speed.Value;
	local l__HumanoidRootPart__29 = p6.HumanoidRootPart;
	local l__Humanoid__30 = p6.Humanoid;
	local v31 = Instance.new("Folder");
	u9 = true;
	v31.Name = "HeavyAttack";
	v31.Parent = p6;
	game:GetService("Debris"):AddItem(v31, 1.2);
	local v32 = Instance.new("Folder");
	v32.Name = "NoJump";
	v32.Parent = p6;
	game:GetService("Debris"):AddItem(v32, 1);
	u2 = false;
	if tick() - l__ComboTimer__4.Value > 5 then
		u10 = 1;
	end;
	l__ComboTimer__4.Value = tick();
	local v33 = l__HumanoidRootPart__29.ChargePart:Clone();
	local v34 = not p7.Backpack:FindFirstChild("Abysswalker");
	local v35 = false;
	local v36 = l__Humanoid__30:LoadAnimation(p8.GreatswordHeavy);
	if v34 then
		if p6:FindFirstChild("RecentDash") then
			v28 = v28 * 0.75;
			v35 = true;
		end;
		v36 = l__Humanoid__30:LoadAnimation(p8.GreatswordHeavy);
		v36:Play(0.1, 1, 1.25 * v28);
	else
		v36 = l__Humanoid__30:LoadAnimation(p8.AbyssHeavy);
		v36:Play();
		v36:AdjustSpeed(2);
	end;
	v36.KeyframeReached:Connect(function(p10)
		if p10 == "slash" and p9 and p9:FindFirstChild("TestTrail") then
			p9.TestTrail.Enabled = true;
		end;
		if p10 == "lastframe" then
			if p9 and p9:FindFirstChild("TestTrail") then
				p9.TestTrail.Enabled = false;
			end;
			if not v34 then
				p6.HumanoidRootPart.Greatswordhit:Play();
				if p9:FindFirstChild("Attachmentz") then
					p9.Attachmentz.DUST:Emit(30);
				end;
			end;
		end;
	end);
	if u10 == 1 then
		v33.Parent = p6["Right Arm"];
		v33.Enabled = true;
	end;
	u6 = true;
	l__HumanoidRootPart__29.Greatswordcharge:Play();
	game:GetService("Debris"):AddItem(v33, 0.5);
	wait(0.125);
	v36:AdjustSpeed(0);
	if v34 and not v35 and p6:FindFirstChild("RecentDash") then
		v28 = v28 * 0.75;
	end;
	if v34 then
		wait(0.35 / v28);
	else
		wait(0.25 / v28);
		local v37 = Instance.new("BodyVelocity");
		game.CollectionService:AddTag(v37, "AllowedBM");
		v37.Name = "ForwardVelocity";
		v37.MaxForce = Vector3.new(80000, 0, 80000);
		v37.Velocity = l__HumanoidRootPart__29.CFrame.lookVector.unit * 40;
		v37.Parent = l__HumanoidRootPart__29;
		game.Debris:AddItem(v37, 0.6);
		wait(0.1 / v28);
	end;
	if p9 and p9:FindFirstChild("TestTrail") then
		p9.TestTrail.Enabled = true;
	end;
	l__HumanoidRootPart__29.Greatswordswing:Play();
	if v34 then
		if u10 == 2 then
			v36:AdjustSpeed(1 * v28);
		else
			v36:AdjustSpeed(1.5 * v28);
		end;
	else
		v36:AdjustSpeed(2 * v28);
	end;
	u6 = false;
	u10 = u10 + 1;
	if u10 >= 1 then
		u10 = 1;
	end;
	local v38 = Instance.new("Folder");
	v38.Name = "Action";
	v38.Parent = p6;
	game:GetService("Debris"):AddItem(v38, 0.8 / v28);
	local v39 = {
		physical = true, 
		damage = p9.Stats.Damage.Value + 3, 
		knockback = true, 
		sword = true, 
		blockbreak = true, 
		slash = true
	};
	if not v34 then
		v39.noparry = true;
		wait(0.5 / v28);
	end;
	if not p6:FindFirstChild("Stun") and not p6:FindFirstChild("NoDam") then
		u8.magnitudeCheck(p6, l__HumanoidRootPart__29.Position, p9.Stats.Length.Value, v39, not v34);
	end;
	wait(0.35);
	l__Combo__5.Value = 1;
	u7 = false;
	u2 = true;
	wait(1.5);
	u9 = false;
	if p9:FindFirstChild("TestTrail") then
		p9.TestTrail.Enabled = false;
	end;
end;
return v1;