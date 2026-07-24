

local v1 = {};
local l__Parent__2 = script.Parent.Parent;
function sub(...)
	coroutine.wrap(...)();
end;
local l__TweenService__3 = game:GetService("TweenService");
en = true;
local u1 = require(game.ServerScriptService.Modules.SamuraiModule);
local l__RipplePart__2 = game.ServerStorage.Assets.Katana.RipplePartv2;
function v1.Active(p1, p2, p3, p4)
	if u1.ActionCheck(p1) then
		return;
	end;
	if game.CollectionService:HasTag(p1, "Knocked") then
		return;
	end;
	if p1.Cooldowns:FindFirstChild("Calm Mind") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Calm Mind"
	CD.Value = 30
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 30)
	en = false;
	local l__HumanoidRootPart__4 = p1.HumanoidRootPart;
	l__HumanoidRootPart__4.CalmMind:Play();
	l__HumanoidRootPart__4.CalmMindParticles:Emit(15);
	local v5 = Instance.new("NumberValue");
	v5.Name = "SpeedBoost";
	v5.Value = 4;
	v5.Parent = p1.Boosts;
	game.Debris:AddItem(v5, 15);
	local v6 = Instance.new("IntValue");
	v6.Name = "AttackSpeedBoost";
	v6.Value = 1.5;
	v6.Parent = p1.Boosts;
	game.Debris:AddItem(v6, 15);
	local v7 = Instance.new("Accessory");
	v7.Name = "CalmMind";
	v7.Parent = p1;
	game.Debris:AddItem(v7, 15);
	local v8 = Instance.new("Accessory");
	v8.Name = "MentalBlock";
	v8.Parent = p2.Backpack;
	game.Debris:AddItem(v8, 15);
	sub(function()
		local v9 = TweenInfo.new(3);
		for v10 = 1, 7 do
			sub(function()
				local v11 = l__RipplePart__2:Clone();
				v11.Size = Vector3.new(0, 0, 0);
				v11.Position = l__HumanoidRootPart__4.Position + Vector3.new(0, -3.025, 0);
				v11.Parent = workspace.Thrown;
				game.Debris:AddItem(v11, 5);
				local v12 = Instance.new("Weld", v11);
				v12.Part0 = l__HumanoidRootPart__4;
				v12.Part1 = v11;
				v12.C1 = CFrame.new(0, 3.025, 0);
				local v13 = tick();
				local l__Transparency__14 = v11.Decal.Transparency;
				while tick() - v13 < 3 do
					local v15 = (tick() - v13) / 3;
					v11.Size = Vector3.new(15, 0, 15) * v15;
					v11.Decal.Transparency = l__Transparency__14 + (1 - l__Transparency__14) * v15;
					wait();				
				end;
			end);
			wait(2);
		end;
	end);
	wait(30);
	en = true;
end;
return v1;
