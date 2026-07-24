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
	local l__Value__3 = p4.Stats.Speed.Value;
	local l__Value__4 = p4.Stats.Damage.Value;
	--game.ReplicatedStorage.Requests.ClientSprint:FireClient(p2);
	u2 = false;
	local v5 = tick() - l__ComboTimer__4.Value;
	if v5 >= 0.7 then
		l__Combo__5.Value = 1;
	end;
	if v5 >= 0.7 and v5 <= 1 then
		u2 = true;
		return;
	end;
	l__ComboTimer__4.Value = tick();
	if l__Combo__5.Value >= 3 then
		l__Combo__5.Value = 2;
	end;
	local v6 = p1.Humanoid:LoadAnimation(p3["Hammer" .. l__Combo__5.Value]);
	local v7 = 1 + l__Value__3;
	if game.CollectionService:HasTag(p1, "BrokenArm") and l__Combo__5.Value < 6 then
		v7 = 0.5 + l__Value__3;
	end;
	if game.CollectionService:HasTag(p1, "Armless") and l__Combo__5.Value < 6 then
		v7 = 0.5 + l__Value__3;
	end;
	local v8 = Instance.new("Accessory");
	v8.Name = "SuperStrength";
	v8.Parent = p1.Boosts;
	game:GetService("Debris"):AddItem(v8, 1);
	v6:Play(0.1, 1, v7 * 1.45);
	local l__HumanoidRootPart__9 = p1.HumanoidRootPart;
	v6:GetMarkerReachedSignal("swing"):Connect(function()
		p4.TestTrail.Enabled = true;
		local v9 = math.random(1, 2);
		l__HumanoidRootPart__9.HammerSwing:Play();
	end);
	v6:GetMarkerReachedSignal("lastframe"):Connect(function()
		p4.TestTrail.Enabled = false;
	end);
	u6 = true;
	local v10 = 0.2 / v7;
	local v11 = Instance.new("Accessory");
	v11.Name = "HeavyAttack";
	v11.Parent = p1;
	game:GetService("Debris"):AddItem(v11, 0.5 + v10);
	local v12 = Instance.new("Accessory");
	v12.Name = "NoJump";
	v12.Parent = p1;
	game:GetService("Debris"):AddItem(v12, 1);
	if p1:FindFirstChild("Stun") then
		u2 = true;
		return;
	end;
	if l__Combo__5.Value ~= 2 then
		wait(0.5 / v7);
		if p1:FindFirstChild("Stun") then
			u2 = true;
			return;
		end;
	else
		wait(0.55 / v7);
		if p1:FindFirstChild("Stun") then
			u2 = true;
			return;
		end;
		sub(function()
			if p4:FindFirstChild("Attachmentz") then
				p4.Attachmentz.DUST:Emit(30);
			end;
			wait(0.2 / v7);
			if not p1:FindFirstChild("Stun") then
				return;
			end;
			u2 = true;
		end);
	end;
	if p1:FindFirstChild("Stun") then
		u2 = true;
		return;
	end;
	u6 = false;
	l__Combo__5.Value = l__Combo__5.Value + 1;
	if l__Combo__5.Value >= 3 then
		u7 = true;
		l__Combo__5.Value = 1;
	end;
	local v13
	if u7 then
		 v13 = {
			physical = true, 
			damage = l__Value__4, 
			knockback = true, 
			blockbreak = true,
			fist = true,
			blacksmithm1 = true,
			poison = (p1:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
		};
	else
		v13 = {
			physical = true, 
			damage = l__Value__4,
			fist = true,
			blacksmithm1 = true,
			poison = (p1:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
		};
	end;
	if not p1:FindFirstChild("Stun") and not p1:FindFirstChild("NoDam") then
		u8.magnitudeCheck(p1, l__HumanoidRootPart__9.Position, p4.Stats.Length.Value, v13, true);
	end;
	if u7 then
		local v14 = Instance.new("Accessory");
		v14.Name = "Action";
		v14.Parent = p1;
		game:GetService("Debris"):AddItem(v14, 0.5 / v7);
		u7 = false;
		wait(0.1);
	end;
	wait(v10);
	u2 = true;
end;
local u10 = false;
local u11 = 1;
function v1.Active2(p5, p6, p7, p8)
	if p5:FindFirstChild("Grabbing") then
		return;
	end;
	if ActionCheck() then
		return;
	end;
	if p5:FindFirstChild("NoAttack") then
		return;
	end;
	if u10 == true then
		return;
	end;
	if game.CollectionService:HasTag(p5, "Knocked") then
		return;
	end;
	if not u2 then
		return;
	end;
	--game.ReplicatedStorage.Requests.ClientSprint:FireClient(p6);
	if p8:FindFirstChild("Poison") then
		u3 = true;
	end;
	local v15 = 1 + p8.Stats.Speed.Value;
	local l__HumanoidRootPart__16 = p5.HumanoidRootPart;
	local v17 = Instance.new("Accessory");
	u10 = true;
	v17.Name = "HeavyAttack";
	v17.Parent = p5;
	game:GetService("Debris"):AddItem(v17, 1.2);
	local v18 = Instance.new("Accessory");
	v18.Name = "NoJump";
	v18.Parent = p5;
	game:GetService("Debris"):AddItem(v18, 1);
	u2 = false;
	if tick() - l__ComboTimer__4.Value > 5 then
		u11 = 1;
	end;
	local v19 = l__HumanoidRootPart__16.ChargePart:Clone();
	l__ComboTimer__4.Value = tick();
	local v20 = p5.Humanoid:LoadAnimation(p7.HammerHeavy);
	v20:Play();
	v20:AdjustSpeed(2);
	v20:GetMarkerReachedSignal("swing"):Connect(function()
		p8.TestTrail.Enabled = true;
		local v21 = math.random(1, 2);
		l__HumanoidRootPart__16.HammerSwing:Play();
	end);
	v20:GetMarkerReachedSignal("lastframe"):Connect(function()
		p8.TestTrail.Enabled = false;
		if p8:FindFirstChild("Attachmentz") then
			p8.Attachmentz.DUST:Emit(30);
		end;
	end);
	if u11 == 1 then
		v19.Parent = p5["Right Arm"];
		v19.Enabled = true;
	end;
	u6 = true;
	l__HumanoidRootPart__16.Greatswordcharge:Play();
	game:GetService("Debris"):AddItem(v19, 0.5);
	wait(0.2);
	v20:AdjustSpeed(0);
	wait(0.2 / v15);
	local v22 = Instance.new("BodyVelocity");
	game.CollectionService:AddTag(v22, "AllowedBM");
	v22.Name = "ForwardVelocity";
	v22.MaxForce = Vector3.new(80000, 0, 80000);
	v22.Velocity = l__HumanoidRootPart__16.CFrame.lookVector.unit * 40;
	v22.Parent = l__HumanoidRootPart__16;
	game.Debris:AddItem(v22, 0.2);
	wait(0.1 / v15);
	if p8:FindFirstChild("TestTrail") then
		p8.TestTrail.Enabled = true;
	end;
	v20:AdjustSpeed(2 * v15);
	u6 = false;
	u11 = u11 + 1;
	if u11 >= 1 then
		u11 = 1;
	end;
	local v23 = Instance.new("Accessory");
	v23.Name = "Action";
	v23.Parent = p5;
	game:GetService("Debris"):AddItem(v23, 0.8 / v15);
	wait(0.5 / v15);
	if not p5:FindFirstChild("Stun") and not p5:FindFirstChild("NoDam") then
		u8.magnitudeCheck(p5, l__HumanoidRootPart__16.Position, p8.Stats.Length.Value, {
			physical = true, 
			damage = p8.Stats.Damage.Value + 5, 
			knockback = true, 
			blockbreak = true, 
			noparry = true,
			fist = true,
			blacksmithm1 = true,
			poison = (p5:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
		}, true);
	end;
	wait(0.35);
	l__Combo__5.Value = 1;
	u7 = false;
	u2 = true;
	wait(1.5);
	u10 = false;
	if p8:FindFirstChild("TestTrail") then
		p8.TestTrail.Enabled = false;
	end;
end;
return v1;
