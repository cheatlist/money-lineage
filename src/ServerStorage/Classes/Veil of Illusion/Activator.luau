-- Decompiled with the Synapse X Luau decompiler.

local v1 = {};
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;
local l__Parent__1 = script.Parent.Parent;
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge", "Stun", "ReturnStun", "Action", "Blocking", "SpellBlocking", "ActiveCast", "Immortal"},
		presentTagBlocks = {"Unconscious", "Knocked"},
	})
end
local u2 = true;
function v1.Active(p1, p2, p3, p4)
	if ActionCheck() then
		return;
	end;
	if p1.Cooldowns:FindFirstChild("Veil of Illusion") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Veil of Illusion"
	CD.Value = 17.5
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 17.5)
	u2 = false;
	local l__Value__3 = game.ServerStorage.PlayerData:FindFirstChild(p2.Name).Class.Value;
	local v9 = 6;
	local v8 = 0.5;
	if p1:FindFirstChild("Danger") then
		v8 = v8 + 0.25;
	end;
	local v18 = game.ReplicatedStorage.Assets.HandHoldIllusion.PointLight:Clone();
	v18.Parent = p1.HumanoidRootPart;
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play()
	p1.HumanoidRootPart.Snap:Play()
	wait(v8);
	p1.HumanoidRootPart.fe:Play();
	p1.HumanoidRootPart.MoneyEmit:Emit(5);
	v18:Destroy()
	local v12 = Instance.new("NumberValue");
	v12.Name = "Transparency";
	v12.Value = 1;
	v12.Parent = p1.Boosts;
	local v13 = Instance.new("NumberValue");
	v13.Name = "SpeedBoost";
	v13.Value = 7;
	v13.Parent = p1.Boosts;
	local v15 = Instance.new("NumberValue")
	v15.Name = "VeilBuff"
	v15.Value = 0
	v15.Parent = p1.Boosts
	local v14 = tick();
	while true do
		wait();
		local v15 = p1:FindFirstChild("Action");
		if not v15 then
			v15 = p1:FindFirstChild("LightAttack");
			if not v15 then
				v15 = p1:FindFirstChild("HeavyAttack") or (p1:FindFirstChild("Stun") or (game.CollectionService:HasTag(p1, "Knocked") or game.CollectionService:HasTag(p1, "Unconscious")));
			end;
		end;
		if v9 < tick() - v14 then
			break;
		end;
		if v15 then
			break;
		end;	
	end;
	v12:Destroy();
	v13:Destroy();
	v15:Destroy()
	p1.HumanoidRootPart.MoneyEmit:Emit(5);
	local v16 = Instance.new("NumberValue");
	v16.Name = "DamageMultiplier";
	v16.Value = 1.3;
	v16.Parent = p1.Boosts;
	game.Debris:AddItem(v16, 3);
	wait(17.5);
	u2 = true;
end;
return v1;
