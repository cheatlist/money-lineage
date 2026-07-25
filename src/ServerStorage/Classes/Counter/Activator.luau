

local v1 = {};
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;
local l__Parent__1 = script.Parent.Parent;
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Action","Blocking","SpellBlocking","NoDamage","ActiveCast","Immortal"},
		presentTagBlocks = {"Unconscious","Knocked"},
	})
end;
local v3 = tick();
local l__TweenService__4 = game:GetService("TweenService");
local u2 = true;
function v1.Active(p1, p2, p3, p4)
	if ActionCheck() then
		return;
	end;
	if game.CollectionService:HasTag(p1, "Knocked") then
		return;
	end;
	if p1.Cooldowns:FindFirstChild("Counter") then
		return
	end
	local cd = 20
	local playerdata = game.ServerStorage.PlayerData:FindFirstChild(p1.Name)
	if playerdata.Skills.Value:find("TheCursedSwordsman") then
		cd = 10
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Counter"
	CD.Value = cd
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, cd)
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play();
	local v5 = Instance.new("Accessory");
	v5.Name = "Action";
	v5.Parent = p1;
	game:GetService("Debris"):AddItem(v5, 1.25);
	local v6 = Instance.new("Accessory");
	v6.Name = "FULLPARRY";
	v6.Parent = p1;
	game:GetService("Debris"):AddItem(v6, 0.6);
	u2 = false;
	p1.HumanoidRootPart.FULLCOUNTER:Play();
	task.wait(10);
	if not playerdata.Skills.Value:find("TheCursedSwordsman") then
		task.wait(10)
	end
	u2 = true;
end;
return v1;
