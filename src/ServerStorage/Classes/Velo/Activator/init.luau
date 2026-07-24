-- Decompiled with the Synapse X Luau decompiler.

local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local l__TweenService__2 = game:GetService("TweenService");
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid;
local v4 = require(game.ServerScriptService.Modules.HitDetection);
v1.upperbound = 100;
v1.lowerbound = 70;
v1.signs = 0;
v1.cost = 20;
local v5 = {
	upperbound = 60, 
	lowerbound = 40, 
	signs = 0, 
	cost = 0
};

function Weld(p5, p6, p7, p8, p9, p10)
	p6.CFrame = p7.CFrame;
	local v9 = Instance.new(p5);
	v9.Part0 = p7;
	v9.Part1 = p6;
	v9.C0 = p8 or CFrame.new();
	v9.C1 = p9 or CFrame.new();
	v9.Parent = p10 and p6;
	return v9;
end;
function v1.Activate(p11, p12, p13, p14)
	if game.CollectionService:HasTag(p12, "Casting") then
		return;
	end;
	local l__Mana__10 = p12.Mana;
	local v11 = game.Players:GetPlayerFromCharacter(p12);
	print(p13);
	if p13 == 0 then
		if p12:FindFirstChild("LightBring") then
			return;
		end;
		if p12:FindFirstChild("LightBall") then
			return;
		end;
		l__Mana__10.Value = math.max(l__Mana__10.Value - v1.cost, 0);
		
		for v13 = 1, 1 do
			wait(0.5);
			local v14 = Instance.new("Accessory");
			v14.Name = "LightBring";
			v14.Parent = p12;
			game:GetService("Debris"):AddItem(v14, 120);
			local v15 = game.ServerStorage.SpellEffects.Velo.LightBall:Clone();
			v15.Firesound2:Play();
			v15.Parent = p12;
			v15.Hit:Play();
			v15.Weld.Part0 = p12.HumanoidRootPart
		end;
	else
		if p12:FindFirstChild("LightBall") then
			p12.LightBall:Destroy();
		end;
		if p12:FindFirstChild("LightBring") then
			p12.LightBring:Destroy();
		end;
	end;
end;
--[[local l__Velo__2 = game.ServerStorage.SpellEffects.Velo;
function v5.Activate(p15, p16, p17, p18, p19)
	if game.CollectionService:HasTag(p16, "Casting") then
		return;
	end;
	if game.CollectionService:HasTag(p16, "SnapCool") then
		return;
	end;
	local l__Mana__16 = p16.Mana;
	local v17 = game.Players:GetPlayerFromCharacter(p16);
	local v18 = v17 and game.ServerStorage.PlayerData:FindFirstChild(v17.Name);
	if v18 then
		local l__Value__19 = v18.Data.ManaColor.Value;
	end;
	if not p19[script.Parent.Name] and v17.Name ~= "Melon_Sensei" then
		return;
	end;
	game.CollectionService:AddTag(p16, "SnapCool");
	spawn(function()
		wait(10);
		game.CollectionService:RemoveTag(p16, "SnapCool");
	end);
	local u3 = nil;
	pcall(function()
		u3 = _G.MouseData(v17);
	end);
	if not u3 then
		return;
	end;
	local l__HumanoidRootPart__20 = p16:FindFirstChild("HumanoidRootPart");
	if not l__HumanoidRootPart__20 then
		return;
	end;
	if p17 == 0 or v17.Name == "Melon_Sensei" then
		p16.Humanoid:LoadAnimation(script.Snap):Play();
		wait(0.2);
		local v21 = game.ReplicatedStorage.Assets.HandHoldIcey:Clone();
		v21.IllusionArm.Enabled = false;
		v21.Parent = game.Workspace.Thrown;
		v21.Snap:Play();
		v21.IllusionSnap:Emit(100);
		local v22 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
		if not p18 then
			v22 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
		end;
		local u4 = Instance.new("Weld");
		local u5 = p16["Right Arm"];
		sub(function()
			u4.Name = "Weld";
			u4.Part0 = u5;
			u4.Part1 = v21;
			u4.Parent = v21;
			u4.C1 = v22;
			wait(1);
			v21:Destroy();
		end);
		local v23 = l__Velo__2.Ball:Clone();
		v23.CFrame = l__HumanoidRootPart__20.CFrame * CFrame.new(0, 0, -5);
		v23.Parent = workspace.Thrown;
		v23.Shine:Play();
		v23.ParticleEmitter.Enabled = true;
		for v24, v25 in pairs(game.Players:GetChildren()) do
			local l__Character__26 = v25.Character;
			if l__Character__26 and l__Character__26:FindFirstChild("HumanoidRootPart") and ((l__Character__26.HumanoidRootPart.CFrame:inverse() * l__HumanoidRootPart__20.CFrame).Z < 0 and (l__Character__26.HumanoidRootPart.Position - l__HumanoidRootPart__20.Position).Magnitude < 50 and l__Character__26 ~= p16) then
				local v27 = script.Flare:Clone();
				v27.Parent = v25.PlayerGui;
				v27.Point.Value = v23.Position;
				v27.LocalScript.Disabled = false;
			end;
		end;
		wait(0.2);
		v23.ParticleEmitter.Enabled = false;
		game.Debris:AddItem(v23, 2);
	else
		p16.Humanoid:LoadAnimation(script.Snap):Play();
		wait(0.2);
		local v28 = game.ReplicatedStorage.Assets.HandHoldIcey:Clone();
		v28.IllusionArm.Enabled = false;
		v28.Parent = game.Workspace.Thrown;
		v28.Snap:Play();
		v28.IllusionSnap:Emit(100);
		local v29 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
		if not p18 then
			v29 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
		end;
		local u6 = Instance.new("Weld");
		local u7 = p16["Right Arm"];
		sub(function()
			u6.Name = "Weld";
			u6.Part0 = u7;
			u6.Part1 = v28;
			u6.Parent = v28;
			u6.C1 = v29;
			wait(1);
			v28:Destroy();
		end);
		local v30 = l__Velo__2.Ball:Clone();
		v30.CFrame = l__HumanoidRootPart__20.CFrame * CFrame.new(0, 0, -5);
		v30.Parent = workspace.Thrown;
		v30.Shine:Play();
		v30.ParticleEmitter.Enabled = true;
		for v31, v32 in pairs(game.Players:GetChildren()) do
			local l__Character__33 = v32.Character;
			if l__Character__33 and l__Character__33:FindFirstChild("HumanoidRootPart") and ((l__Character__33.HumanoidRootPart.CFrame:inverse() * l__HumanoidRootPart__20.CFrame).Z < 0 and (l__Character__33.HumanoidRootPart.Position - l__HumanoidRootPart__20.Position).Magnitude < 50 or l__Character__33 == p16) then
				local v34 = script.Flare:Clone();
				v34.Parent = v32.PlayerGui;
				v34.Point.Value = v30.Position;
				v34.LocalScript.Disabled = false;
			end;
		end;
		wait(0.2);
		v30.ParticleEmitter.Enabled = false;
		game.Debris:AddItem(v30, 2);
	end;
--end;]]
v1.alternate = v5;
return v1;
