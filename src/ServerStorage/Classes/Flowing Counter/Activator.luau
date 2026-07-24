local v1 = {}
local l__Parent__2 = script.Parent.Parent
function sub(...)
	coroutine.wrap(...)()
end
local l__TweenService__3 = game:GetService("TweenService")
local v4 = require(game.ServerScriptService.Modules.HitDetection)
en = true
local u1 = require(game.ServerScriptService.Modules.SamuraiModule)
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
function v1.Active(p1, p2, p3, p4)
	if u1.ActionCheck(p1)then
		return
	end
	if p1:FindFirstChild("Knocked")then
		return
	end
	if p1.Cooldowns:FindFirstChild("Flowing Counter") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Flowing Counter"
	CD.Value = 15
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 15)
	local v5 = u1.isCalm(p1);
	local particl = u1.hasParticles(p1);
	local evil = u1.isEvil(p1)
	local v6 = p1.Humanoid:LoadAnimation(script.Parent.Anim);
	local particles = p1.HumanoidRootPart.CalmMindParticles
	v6:Play();
	if evil then
		particles = p1.HumanoidRootPart.EvilCalmMindParticles
	end
	
	particles:emit(15)
	local v7 = 1.2
	if v5 then
		v7 = 1.2;
	else
		v7 = 0.8;
	end;
	sub(function()
		wait(v7);
		v6:Stop();
	end);
	local v8 = Instance.new("Folder");
	v8.Name = "HeavyAttack";
	v8.Parent = p1;
	game.Debris:AddItem(v8, 1.2);
	local v9 = Instance.new("Folder");
	v9.Name = "FlowingParry";
	v9.Parent = p1;
	game.Debris:AddItem(v9, v7);
	p1.HumanoidRootPart.FULLCOUNTER:Play();
	local v10 = 15;
	wait(v10);
	en = true;
end;
return v1;
