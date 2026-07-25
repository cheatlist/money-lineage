

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
	if p1.Cooldowns:FindFirstChild("Clairvoyance") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Clairvoyance"
	CD.Value = 20
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 20)
	p1.HumanoidRootPart.ShadowImpaling:Play()
	p1.HumanoidRootPart.PremonitionEmitter:Emit(1)
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play();
	local v6 = Instance.new("Accessory");
	v6.Name = "PREMONITIONCOUNTER";
	v6.Parent = p1;
	game:GetService("Debris"):AddItem(v6, 1);
	u2 = false;	
	task.wait(20);
	u2 = true;
end;
return v1;
