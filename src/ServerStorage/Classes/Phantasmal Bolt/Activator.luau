-- Decompiled with the Synapse X Luau decompiler.

local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local l__TweenService__2 = game:GetService("TweenService");
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid;
v1.upperbound = 90;
v1.lowerbound = 80;
v1.signs = 5;
v1.cost = 100;
local l__HolyArrow__5 = game.ServerStorage.SpellEffects.PhantomBolt;
local v6 = require(l__HolyArrow__5.HolyEffect);
local function u1(p1, p2, p3, p4)
	local v7, v8, v9 = game.Workspace:FindPartOnRayWithIgnoreList(Ray.new(p1, CFrame.new(p1, p2).lookVector * p3), p4);
	return v7, v8, v9;
end;
local u2 = { workspace.Live, workspace.Terrain, workspace.Thrown, workspace.MonsterSpawns, workspace.AreaMarkers };
function hitCheck(p5, p6, p7)
	local v10, v11, v12 = pairs(game.Workspace.Live:GetChildren());
	for i = 1,#v11 do
		local v13, v14 = v10(v11, v12);
		if v13 then

		else
			break;
		end;
		v12 = v13;
		if p5 ~= v14 then
			local v15 = p5.HumanoidRootPart.CFrame:inverse() * v14.HumanoidRootPart.CFrame;
			if v15.Z < 5 then
				if -p6 < v15.Z then
					if math.abs(v15.X) < p7 then
						if math.abs(v15.Y) < p7 then
							local v16, v17, v18 = u1(p5.HumanoidRootPart.Position, v14.HumanoidRootPart.Position, (p5.HumanoidRootPart.Position - v14.HumanoidRootPart.Position).Magnitude, u2);
							if not v16 then
								return v14;
							end;
						end;
					end;
				end;
			end;
		end;	
	end;
end;
local u3 = CFrame.fromOrientation(0, math.rad(275), math.rad(90)) * CFrame.new(0.4, 2.6, -1.5);
local u4 = {
	damage = 15, 
	mana = true,
	noenchant = true,
	bypassblock = true,
	canspellcounter = true,
	phantasmal = true,
	phantasmalduration = 2.5,
	move = "Phantasmal Bolt"
};
function v1.Activate(p8, p9, p10, p11)
	if game.CollectionService:HasTag(p9, "Casting") or p9:FindFirstChild("ActiveCast") then
		return;
	end;
	local l__Mana__19 = p9.Mana;
	local l__Value__20 = game.ServerStorage.PlayerData[game.Players:GetPlayerFromCharacter(p9).Name].ManaColor.Value;
	local l__HumanoidRootPart__21 = p9:FindFirstChild("HumanoidRootPart");
	if not l__HumanoidRootPart__21 then
		return;
	end;
	if p9:FindFirstChild("EndCast") then
		return;
	end;
	l__Mana__19.Value = math.max(l__Mana__19.Value - v1.cost, 0);
	if p10 ~= 0 then
		if p10 == 1 then
			v6.hitEffect(p9, p9, u4, 0);
			return;
		else
			l__HumanoidRootPart__21.Diffusion:Play();
			return;
		end;
	end;
	l__HumanoidRootPart__21.PhantasmalEmit:Emit(30)
	local v22 = Instance.new("Folder");
	v22.Name = "ActiveCast";
	v22.Parent = p9;
	game.Debris:AddItem(v22, 5);
	local v23 = l__HolyArrow__5.HolyBow:Clone();
	game.Debris:AddItem(v23, 2);
	local v24 = l__HolyArrow__5.HolyArrow:Clone();
	game.Debris:AddItem(v24, 2);
	v23.Parent = workspace.Thrown;
	v24.Parent = workspace.Thrown;
	v23.CFrame = l__HumanoidRootPart__21.CFrame;
	v24.CFrame = l__HumanoidRootPart__21.CFrame;
	local v25 = Instance.new("Weld", v23);
	v25.Part0 = l__HumanoidRootPart__21;
	v25.Part1 = v23;
	v25.C0 = u3;
	local v26 = Instance.new("Weld", v23);
	v26.Part0 = l__HumanoidRootPart__21;
	v26.Part1 = v24;
	v26.C0 = u3 * CFrame.new(0, 1.5, 0);
	p9.Humanoid:LoadAnimation(script.Pull):Play();
	v23.Size = v23.Size * 0.8;
	v23.Transparency = 1;
	local effect = l__HumanoidRootPart__21.PhantasmalCleave:Clone()
	effect.Parent = p9:FindFirstChild("Right Arm"):FindFirstChild("SpearAttach")
	effect:Emit()
	game.Debris:AddItem(effect, 2)
	v24.Transparency = 1;
	sub(function()
		wait(0.3);
		if v23:FindFirstChild("Sound") then
			v23.Sound:Play();
		end;
	end);
	wait(0.3);
	l__TweenService__2:Create(v24, TweenInfo.new(0.5), {
		Size = v24.Size * 2.5, 
		Transparency = 0
	}):Play();
	l__TweenService__2:Create(v26, TweenInfo.new(0.1), {
		C0 = v26.C0 * CFrame.new(0, -v24.Size.Y * 2.5 / 4, 0)
	}):Play();
	wait(0.3);
	l__TweenService__2:Create(v24, TweenInfo.new(0.3), {
		Transparency = 1
	}):Play();
	l__TweenService__2:Create(v26, TweenInfo.new(0.3), {
		C0 = v26.C0 * CFrame.new(0, 5, 0)
	}):Play();
	task.wait(0.1)
	local v27 = false;
	for v28 = 1, 3 do
		if v27 then
			break;
		end;
		v27 = hitCheck(p9, 25 + 25 * v28, v28 * 4);
	end;
	if v27 then
		v6.hitEffect(p9, v27, u4, 0.25, true);
	end;
	v22:Destroy();
end;
return v1;
