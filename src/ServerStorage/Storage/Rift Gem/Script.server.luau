function sub(...)
	coroutine.wrap(...)();
end;
local TweenService = game:GetService("TweenService");
function ActionCheck(Parent)
	if Parent:FindFirstChild("Stun") then
		return true;
	end;
	if Parent:FindFirstChild("ReturnStun") then
		return true;
	end;
	if Parent:FindFirstChild("Action") then
		return true;
	end;
	if Parent:FindFirstChild("Blocking") then
		return true;
	end;
	if Parent:FindFirstChild("SpellBlocking") then
		return true;
	end;
	if Parent:FindFirstChild("ActiveCast") then
		return true;
	end;
	if Parent:FindFirstChild("Unconscious") then
		return true;
	end;
	if Parent:FindFirstChild("Knocked") then
		return true;
	end;
	if Parent:FindFirstChild("Immortal") then
	else
		return;
	end;
	return true;
end;
local canuse = true;
local equipped = false;
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent;
	if ActionCheck(p1)then
		return;
	end;
	if not canuse then
		return;
	end;
	canuse = false;
	local p2 = game.Players:GetPlayerFromCharacter(p1);
	local HumanoidRootPart = p1.HumanoidRootPart;
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name);
	local skills = string.split(data.Skills.Value,",");
	if table.find(skills,"Gate")then
		canuse = true;
		return;
	end;
	table.insert(skills,"Gate");
	data.Skills.Value = table.concat(skills,",");
	require(game.ServerScriptService.Modules.Commands).Learn(p2);
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(p2,"Rift Gem");
	pcall(function()
		script.Parent:Destroy();
	end)
end);