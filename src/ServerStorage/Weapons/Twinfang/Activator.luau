-- Twinfang: the Faceless Blade path's dual-dagger weapon. Same shape as Weapons/Dagger's
-- Activator (same v1.Active/v1.Active2 module contract, dispatched by CharacterHandler's
-- LeftClick handler off the equipped Tool's own Activator child), but an 8-hit combo instead
-- of Dagger's 5, weaker per hit, and a shorter base swing gap so it sits just behind
-- Dagger-with-Agility speed baseline (Agility still stacks on top via AttackSpeedBoost).
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
local COMBO_LENGTH = 8;
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
	local v2 = 0.07;
	local v4 = p1.Boosts:GetChildren();
	for i = 1,#v4 do
		local v7 = v4[i]
		if v7.Name == "AttackSpeedBoost" then
			v2 = v2 / v7.Value;
		end;
	end;
	local v8 = Instance.new("Folder");
	v8.Name = "LightAttack";
	v8.Parent = p1;
	game.ServerStorage.Debris:Fire(v8, 0.15 + v2);
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
	if l__Combo__4.Value >= COMBO_LENGTH + 1 then
		l__Combo__4.Value = COMBO_LENGTH;
	end;
	local v11 = p1.Humanoid:LoadAnimation(game.ReplicatedStorage.CombatAnims["Twinfang" .. l__Combo__4.Value]);
	local v12 = 1.05;
	if game.CollectionService:HasTag(p1, "BrokenArm") and l__Combo__4.Value < COMBO_LENGTH then
		v12 = 0.8;
	end;
	v11:Play(0.1, 1, v12 * 1.6);
	local l__HumanoidRootPart__8 = p1.HumanoidRootPart;
	v11.KeyframeReached:Connect(function(p4)
		if p4 == "slash" then
			if p3:FindFirstChild("TestTrail") then
				p3.TestTrail.Enabled = true;
			end;
			if math.random(1, 2) == 1 then
				l__HumanoidRootPart__8.DaggerSlash2:Play();
			else
				l__HumanoidRootPart__8.DaggerSlash1:Play();
			end;
		end;
		if p4 == "lastframe" and p3:FindFirstChild("TestTrail") then
			p3.TestTrail.Enabled = false;
		end;
	end);
	wait(0.16);
	l__Combo__4.Value = l__Combo__4.Value + 1;
	if l__Combo__4.Value >= COMBO_LENGTH + 1 then
		u5 = true;
		l__Combo__4.Value = 1;
	end;
	if not p1:FindFirstChild("Stun") then
		local v34 = {
			physical = true,
			dagger = true,
			damage = 2.25 + v10,
			slash = true,
			poison = (p1:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
		};
		if u5 then
			v34 = {
				physical = true,
				dagger = true,
				damage = 3.25 + v10,
				knockback = true,
				slash = true,
				poison = (p1:FindFirstChild("Nature's Calling") and math.random(1,2) == 1)
			};
		end;
		u7.magnitudeCheck(p1, l__HumanoidRootPart__8.Position, 9, v34, true);
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
			damage = 4 + v38,
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
