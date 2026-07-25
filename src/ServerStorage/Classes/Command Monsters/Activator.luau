

local l__Parent__1 = script.Parent;
local l__Parent__2 = l__Parent__1.Parent;
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid;
local l__TweenService__4 = game:GetService("TweenService");
function sub(...)
	coroutine.wrap(...)();
end;
local l__TweenService__6 = game:GetService("TweenService");
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(p1)
	return ActionCheckModule(p1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Stun","ReturnStun","ActiveCast","Action","Blocking","Climbing"},
		healthAtOrBelow = 0,
	})
end;
local v7 = {};
local u1 = false;
local u2 = { {
		color = Color3.fromRGB(170, 0, 0), 
		comm = "HALT"
	}, {
		color = Color3.fromRGB(0, 170, 0), 
		comm = "NOHOUSE"
	}, {
		color = Color3.fromRGB(0, 0, 170), 
		comm = "ALL"
	} };
local u3 = 1;
function v7.Active(p2, p3, p4, p5)
	if ActionCheck(p2) then
		return;
	end;
	local l__HumanoidRootPart__8 = p2.HumanoidRootPart;
	if u1 then
		return;
	end;
	u1 = true;
	p2.Humanoid:LoadAnimation(l__Parent__1.Animation):Play();
	local v9 = Instance.new("Accessory");
	v9.Name = "Action";
	v9.Parent = p2;
	game.Debris:AddItem(v9, 1);
	task.wait(0.7);
	local v10 = l__Parent__1.Shriek:Clone();
	v10.Parent = p2.Torso;
	v10:Play();
	game.Debris:AddItem(v10, v10.TimeLength);
	l__HumanoidRootPart__8.CommandFX.Color = ColorSequence.new(u2[u3].color);
	l__HumanoidRootPart__8.CommandFX:Emit(20);
	for v11, v12 in pairs(workspace.Live:children()) do
		if v12 ~= p2 and v12:FindFirstChild("MonsterInfo") and v12.MonsterInfo.Master.Value == p2 and v12.MonsterInfo.MonsterType.Value == "Shrieker" then
			v12.Variables.Command.Value = u2[u3].comm;
		end;
	end;
	task.wait(1);
	u1 = false;
end;
function v7.Active2(p6, p7, p8, p9)
	local l__Humanoid__13 = p6.Humanoid;
	local l__HumanoidRootPart__14 = p6.HumanoidRootPart;
	l__HumanoidRootPart__14.CommandFX.Color = ColorSequence.new(u2[u3].color);
	l__HumanoidRootPart__14.CommandFX:Emit(20);
	u3 = (u3 + 1) % #u2 + 1;
end;
return v7;
