

local v1 = {};
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;
local l__Parent__1 = script.Parent.Parent;
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Immortal"},
		presentTagBlocks = {"Unconscious","Knocked"},
	})
end;
local v3 = tick();
local l__TweenService__4 = game:GetService("TweenService");
local u2 = true;
local u3 = require(game.ServerScriptService.Modules.HitDetection);
function v1.Active(p1, p2, p3, p4)
	if ActionCheck() then
		return;
	end;
	if game.CollectionService:HasTag(p1, "Knocked") then
		return;
	end;
	if p1.Cooldowns:FindFirstChild("Disarming Strike") then
		return
	end
	local cd = 20
	local playerdata = game.ServerStorage.PlayerData:FindFirstChild(p1.Name)
	if playerdata.Skills.Value:find("TheCursedSwordsman") then
		cd = 10
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Disarming Strike"
	CD.Value = cd
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, cd)
	local v5 = p1.Humanoid:LoadAnimation(script.Parent.AnimationL);
	v5:Play();
	local v6 = Instance.new("Accessory");
	v6.Name = "HeavyAttack";
	v6.Parent = p1;
	game:GetService("Debris"):AddItem(v6, 1);
	u2 = false;
	local v7 = nil;
	if not p4:FindFirstChild("LethalTrail") then
		v7 = script.Parent.LethalTrail:Clone();
		v7.Attachment0 = p4:WaitForChild("Attachment1");
		v7.Attachment1 = p4:WaitForChild("Attachment2");
		v7.Parent = p4;
	elseif p4:FindFirstChild("LethalTrail") then
		v7 = p4:FindFirstChild("LethalTrail");
	end;
	local greater = 5
	if playerdata.Skills.Value:find("TheCursedSwordsman") then
		greater = 15
	end
	v5.KeyframeReached:Connect(function(p5)
		if p5 == "start" then
			v7.Enabled = true;
			p1.HumanoidRootPart.LordSlash2:Play();
		end;
		if p5 == "ee" then
			v7.Enabled = false;
			if not p1:FindFirstChild("Stun") then
				u3.magnitudeCheck(p1, p1.HumanoidRootPart.Position, 8.5, {
					physical = true, 
					sword = true, 
					disarm = true, 
					knockback = true, 
					damage = greater, 
					slash = true,
					move = "Disarming Strike"
				}, true);
			end;
		end;
	end);
	wait(10);
	if not playerdata.Skills.Value:find("TheCursedSwordsman") then
		task.wait(10)
	end
	u2 = true;
end;
return v1;
