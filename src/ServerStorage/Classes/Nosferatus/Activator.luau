

local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local v2 = require(game.ServerScriptService.Modules.EffectModule);
local v3 = require(game.ServerScriptService.Modules.HitDetection);
v1.upperbound = 100;
v1.lowerbound = 90;
v1.signs = 8;
v1.cost = 100;
function radrandom(p1, p2)
	return math.rad(math.random(p1, p2));
end;
local l__HalloweenSpells__1 = game.ServerStorage.SpellEffects.HalloweenSpells;
local l__TweenService__2 = game:GetService("TweenService");
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid;
function v1.Activate(p3, p4, p5, p6)
	local v4 = nil;
	if game.CollectionService:HasTag(p4, "Casting") then
		return;
	end;
	if p4:FindFirstChild("VampiriusCast") then
		return;
	end;
	v4 = p4.Mana;
	local v5 = game.Players:GetPlayerFromCharacter(p4);
	local l__Value__6 = game.ServerStorage.PlayerData[v5.Name].ManaColor.Value;
	local u4 = _G.MouseData(v5);
	if not u4 then
		return;
	end;
	if p5 == 0 then
		v4.Value = math.max(v4.Value - v1.cost, 0);
		p4.HumanoidRootPart.PerfectCast:Play();
		local v7 = Instance.new("IntValue", p4);
		v7.Name = "VampiriusCast";
		game.Debris:AddItem(v7, 12);
		local v8 = l__HalloweenSpells__1.Coffin:Clone();
		game.Debris:AddItem(v8, 12);
		v8.Parent = game.Workspace.Thrown;
		local l__Front__9 = v8:FindFirstChild("Front");
		local l__root__10 = v8:FindFirstChild("root");
		local l__case__11 = v8:FindFirstChild("case");
		local v12 = l__HalloweenSpells__1.Corpse:Clone();
		game.Debris:AddItem(v12, 12);
		local l__Torso__13 = v12:FindFirstChild("Torso");
		local v14 = l__HalloweenSpells__1.SmokePart:Clone();
		game.Debris:AddItem(v14, 12);
		v14.Parent = game.Workspace.Thrown;
		v14.CFrame = p4.HumanoidRootPart.CFrame * CFrame.new(0, -2.5, -15);
		v14.poof2:Play();
		wait(0.05);
		v8:PivotTo(v14.CFrame * CFrame.Angles(0, math.rad(90), math.rad(-90)));
		l__Front__9.rising:Play();
		local v15 = l__TweenService__2:Create(l__root__10.Top, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			C0 = l__root__10.Top.C0 * CFrame.new(-7.9, 0, 0)
		}):Play();
		wait(1.5);
		v14.smokep.Enabled = false;
		wait(0.2);
		v12:PivotTo(v14.CFrame * CFrame.new(0, 3.75, 0) * CFrame.Angles(0, math.rad(180), 0));
		v12.Parent = v8;
		local l__CFrame__16 = l__Front__9.CFrame;
		l__Front__9.open1_creak:Play();
		local v17 = l__TweenService__2:Create(l__case__11.Front, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			C0 = l__case__11.Front.C0 * CFrame.Angles(math.rad(90), 0, 0)
		}):Play();
		spawn(function()
			local v18 = l__HalloweenSpells__1.bats:Clone();
			game.Debris:AddItem(v18, 4);
			v18.Parent = game.Workspace.Thrown;
			v18.CFrame = v14.CFrame * CFrame.new(0, 6, 0) * CFrame.Angles(math.rad(45), 0, 0);
			wait(0.5);
			v18.batp.Enabled = true;
			v18.swarm:Play();
			wait(1);
			v18.batp.Enabled = false;
			wait(1);
			local v19 = l__TweenService__2:Create(v18.swarm, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Volume = 0
			}):Play();
		end);
		wait(1.5);
		local v20 = false;
		for v21, v22 in pairs(workspace.Live:children()) do
			if v22 ~= p4 and v22:IsA("Model") then
				local v23 = v22 and v22:FindFirstChild("Humanoid");
				local v24 = v23 and v23.RootPart;
				if v24 and not v22:FindFirstChildOfClass("ForceField") and (v24.Position - l__Torso__13.Position).magnitude < 40 then
					v20 = true;
					local v25 = l__HalloweenSpells__1.siphonbeam:Clone();
					game.Debris:AddItem(v25, 3);
					v25.Parent = l__Torso__13;
					v25.Attachment0 = l__Torso__13.BloodSiphonAttach;
					local v26 = Instance.new("Attachment");
					game.Debris:AddItem(v26, 3);
					v26.Parent = v24;
					v25.Attachment1 = v26;
					spawn(function()
						for v27 = 1, 3 do
							l__TagHumanoid__3:Fire(p4, v22, {
								mana = true, 
								damage = 6.5, 
								nostun = true, 
								noenchant = true,
								move = "Nosferatus"
							});
							wait(1);
						end;
					end);
				end;
			end;
		end;
		if v20 then
			l__Torso__13.Sound:Play();
		end;
		wait(3.5);
		local v28 = l__TweenService__2:Create(l__case__11.Front, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			C0 = l__case__11.Front.C0 * CFrame.Angles(math.rad(-90), 0, 0)
		}):Play();
		wait(0.1);
		l__Front__9.close:Play();
		l__Front__9.close.TimePosition = 1.8;
		wait(0.25);
		v12:Destroy();
		local v29 = l__HalloweenSpells__1.dirt:Clone();
		game.Debris:AddItem(v29, 5);
		v29.CFrame = v14.CFrame;
		v29.Parent = v8;
		wait(0.1);
		l__Front__9.rising:Play();
		local v30 = l__TweenService__2:Create(l__root__10.Top, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			C0 = l__root__10.Top.C0 * CFrame.new(9, 0, 0)
		}):Play();
		wait(1.5);
		v29.sink.Enabled = false;
	else
		if v4.Value - v1.cost <= 0 then
			v4.Value = 0;
		else
			v4.Value = v4.Value - v1.cost;
		end;
		spawn(function()
			l__TagHumanoid__3:Fire(p4, p4, {
				mana = true, 
				damage = 45, 
				manaknockupself = 90, 
				curse = true,
				move = "Nosferatus"
			});
--[[

			local v31 = l__HalloweenSpells__1.IceCase:Clone();
			v31.CFrame = p4.HumanoidRootPart.CFrame;
			v31.Parent = p4;
			local v32 = Instance.new("Motor6D");
			v32.Part0 = v31;
			v32.Part1 = p4.Torso;
			v32.Parent = v31;
			game.Debris:AddItem(v31, 1.5);

]]
			wait(1.5);
			l__TagHumanoid__3:Fire(p4, p4, {
				mana = true, 
				damage = 30, 
				manaknockupself = true, 
				curse = true, 
				downbypass = true,
				move = "Nosferatus"
			});
		end);
	end;
end;
return v1;
