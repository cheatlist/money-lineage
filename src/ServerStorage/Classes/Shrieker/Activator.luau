local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;
v1.upperbound = 50;
v1.lowerbound = 30;
v1.signs = 6;
v1.cost = 15;
local l__Killing__3 = game.ServerStorage.SpellEffects.Killing;
local u1 = false;
local l__TweenService__2 = game:GetService("TweenService");
function v1.Activate(p1, p2, p3, p4)
	if game.CollectionService:HasTag(p2, "Casting") then
		return;
	end;
	if u1 == true then
		return;
	end;
	local l__Mana__4 = p2.Mana;
	local v5 = game.Players:GetPlayerFromCharacter(p2);
	local l__Value__6 = v5.Backpack.ManaColor.Value;
	local u3 = _G.MouseData(v5);
	if not u3 then
		return;
	end;
	if p3 == 0 then
		l__Mana__4.Value = math.max(l__Mana__4.Value - v1.cost, 0);
		u1 = true;
		p2.HumanoidRootPart.PerfectCast:Play();
		local v7 = nil;
		if p3 == 0 then
			v7 = p2;
		end;
		for v8, v9 in pairs(workspace.Live:GetChildren()) do
			local l__Value__10 = v9:FindFirstChild("MonsterInfo") and v9.MonsterInfo.Master.Value
			if l__Value__10 and l__Value__10 == p2 and v9.MonsterInfo:FindFirstChild("Summoned") then
				u1 = false;
				break;
			end;
		end;
		for i,v in pairs(workspace.Live:GetChildren()) do
			if v:FindFirstChild("MonsterInfo") and v:FindFirstChild("Summoned") and v.MonsterInfo.Master.Value == p2 then
				return
			end
		end
		for v10 = 1, 2 do
			local v11 = game.ServerStorage.Requests.SpawnMonster:Invoke("Shrieker", p2.Torso.Position + Vector3.new(math.random(-15, 15), p2, math.random(-15, 15)), v7, false);
			local v12 = game.ServerStorage.Assets.Dark:Clone();
			v12.CFrame = v11.Torso.CFrame;
			v12.Parent = workspace.Thrown;
			game:GetService("Debris"):AddItem(v12, 2);
			v12.Sound:Play();
			v12.Attachment.OrbParticle:Emit(100);
			l__TweenService__2:Create(v12, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false), {
				Size = Vector3.new(10.05, 10.05, 10.05)
			}):Play();
			local v13 = Instance.new("Accessory");
			v13.Name = "Summoned";
			v13.Parent = v11;
		end;
	else
		p2.HumanoidRootPart.Diffusion:Play();
		if p4 and p4:FindFirstChild("Backfire") then
			p4.Backfire.Color = ColorSequence.new(Color3.new(l__Value__6.r, l__Value__6.g, l__Value__6.b));
			p4.Backfire:Emit(15);
		end;
	end;
	task.delay(60, function()
		u1 = false;
	end)
end;
return v1;
