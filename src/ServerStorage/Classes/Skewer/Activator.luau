local v1 = {};
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;

local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(l__Parent__1)
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Stun", "ReturnStun", "Action", "Blocking", "SpellBlocking", "Climbing", "ActiveCast", "Immortal"},
		healthAtOrBelow = 0,
		presentTagBlocks = {"Unconscious", "Knocked"},
	})
end

local v3 = tick();
local l__TweenService__4 = game:GetService("TweenService");
local u2 = { game.Workspace.Live };
function ray(p1, p2, p3, p4)
	local v5, v6, v7 = game.Workspace:FindPartOnRayWithIgnoreList(Ray.new(p1, CFrame.new(p1, p2).lookVector * p3), u2);
	return v5, v6, v7;
end;
local u3 = true;
local u4 = require(game.ServerScriptService.Modules.TridentModule);
local u5 = require(game.ServerScriptService.Modules.HitDetection);
function v1.Active(p5, p6, p7, p8)
	if ActionCheck(p5) then
		return;
	end;
	if not u4.wieldTrident(p6) then
		return
	end
	if p5.Cooldowns:FindFirstChild("Skewer") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Skewer"
	CD.Value = 12
	CD.Parent = p5.Cooldowns
	game.Debris:AddItem(CD, 12)
	local v8 = Instance.new("Accessory");
	v8.Name = "Action";
	v8.Parent = p5;
	local v9 = Instance.new("Folder");
	v9.Name = "NoDelete";
	v9.Parent = v8;
	game.Debris:AddItem(v8, 1);
	local v10 = p5.Humanoid:LoadAnimation(script.Parent.Anim);
	v10:Play();
	local l__HumanoidRootPart__6 = p5.HumanoidRootPart;
	local l__Value__7 = p8.Stats.Damage.Value;
	local l__Value__8 = p8.Stats.Length.Value;
	v10:GetMarkerReachedSignal("stab"):Connect(function()
		local v11 = Instance.new("BodyVelocity");
		game.CollectionService:AddTag(v11, "AllowedBM");
		v11.maxForce = Vector3.new(math.huge, math.huge, math.huge);
		v11.Velocity = l__HumanoidRootPart__6.CFrame.LookVector * 15;
		v11.Parent = l__HumanoidRootPart__6;
		game.Debris:AddItem(v11, 0.2);
		u5.magnitudeCheck(p5, l__HumanoidRootPart__6.Position, l__Value__8, {
			physical = true, 
			spear = true, 
			slash = true, 
			damage = l__Value__7,
			move = "Skewer"
		}, true);
	end);
	v10:GetMarkerReachedSignal("pull"):Connect(function()
		local v12
		if p5:FindFirstChild("Focus") then
			v12 = 5;
		else
			v12 = 3;
		end;
		u5.magnitudeCheck(p5, l__HumanoidRootPart__6.Position, l__Value__8, {
			physical = true, 
			spear = true, 
			slash = true, 
			damage = l__Value__7, 
			waterspikes = v12, 
			move = "Skewer",
			delay = 0.2
		}, true);
	end);
	task.wait(12);
	u3 = true;
end;
return v1;