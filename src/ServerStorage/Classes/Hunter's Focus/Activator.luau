

local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local l__TweenService__2 = game:GetService("TweenService");
local l__Parent__1 = script.Parent.Parent;
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Immortal"},
		presentTagBlocks = {"Unconscious","Knocked"},
	})
end;
local u2 = true;
local l__Trident__3 = game.ServerStorage.Assets.Trident;
function v1.Active(p1, p2, p3)
	if ActionCheck() then
		return;
	end;
	if p1.Cooldowns:FindFirstChild("Hunter's Focus") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Hunter's Focus"
	CD.Value = 40
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 40)
	local l__HumanoidRootPart__3 = p1.HumanoidRootPart;
	local v4 = Instance.new("NumberValue");
	v4.Name = "SpeedBoost";
	v4.Value = 2;
	v4.Parent = p1.Boosts;
	game.Debris:AddItem(v4, 20);
	local v5 = Instance.new("IntValue");
	v5.Name = "AttackSpeedBoost";
	v5.Value = 2;
	v5.Parent = p1.Boosts;
	game.Debris:AddItem(v5, 20);
	local v6 = Instance.new("Folder");
	v6.Name = "Focus";
	v6.Parent = p1;
	game.Debris:AddItem(v6, 20);
	l__HumanoidRootPart__3.WaterDroplet:Play();
	--local v7 = l__Trident__3.Ripple:Clone();
	--v7.Parent = l__HumanoidRootPart__3.RootAttachment;
	--v7:Emit(1);
	--game.Debris:AddItem(v7, 5);
	sub(function()
		local v8 = l__Trident__3.BubbleAura:Clone();
		v8.Parent = l__HumanoidRootPart__3;
		v8.Enabled = true;
		task.wait(20);
		v8.Rate = 0;
		game.Debris:AddItem(v8, 5);
	end);
	task.wait(40);
	u2 = true;
end;
return v1;
