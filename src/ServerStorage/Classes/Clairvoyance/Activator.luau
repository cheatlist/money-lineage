

local v1 = {};
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;
local l__Parent__1 = script.Parent.Parent;
function ActionCheck()
	if not l__Parent__1:FindFirstChild("Humanoid") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("Charge") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("Stun") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("ReturnStun") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("Action") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("Blocking") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("SpellBlocking") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("NoDamage") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("ActiveCast") then
		return true;
	end;
	if game.CollectionService:HasTag(l__Parent__1, "Unconscious") then
		return true;
	end;
	if game.CollectionService:HasTag(l__Parent__1, "Knocked") then
		return true;
	end;
	if l__Parent__1:FindFirstChild("Immortal") then
		return true
	end
	return false;
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
	wait(20);
	u2 = true;
end;
return v1;
