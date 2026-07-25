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
local u3 = require(game.ServerScriptService.Modules.TransparencyModule);
function v1.Active(p1, p2, p3, p4)
	if ActionCheck() then
		return;
	end;
	if p1.Cooldowns:FindFirstChild("Stealth") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Stealth"
	CD.Value = 10
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 10)
	local l__Value__3 = game.ServerStorage.PlayerData:FindFirstChild(p2.Name).Class.Value;
	local v9 = 10;
	local v11 = 1.1;
	local v8 = 3;
	local v10 = -3;
	local v7 = 0.5;
	if l__Value__3 == "Shinobi" or l__Value__3 == "Faceless" or l__Value__3 == "Whisper"  then
		v9 = 14;
		v11 = 1.2;
		v8 = 1.5;
		v10 = -5;
		v7 = 0.9;
	end;
	if p1:FindFirstChild("Danger") then
		v8 = v8 + 1;
	end;
	p1.HumanoidRootPart.Stealth:Play();
	u3.gradualTransparency(p1, 0, v7, v8);
	task.wait(v8);
	local v12 = Instance.new("NumberValue");
	v12.Name = "Transparency";
	v12.Value = v7;
	v12.Parent = p1.Boosts;
	local v13 = Instance.new("NumberValue");
	v13.Name = "SpeedBoost";
	v13.Value = v10;
	v13.Parent = p1.Boosts;
	local v14 = tick();
	while true do
		task.wait(1/30);
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
	p1.HumanoidRootPart.ShadowEmitter:Emit(20);
	local v16 = Instance.new("NumberValue");
	v16.Name = "DamageMultiplier";
	v16.Value = v11;
	v16.Parent = p1.Boosts;
	game.Debris:AddItem(v16, 3);
	task.wait(10);
	u2 = true;
end;
return v1;
