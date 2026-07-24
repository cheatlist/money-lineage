local v1 = {};
v1.upperbound = 95;
v1.lowerbound = 90;
v1.signs = 10;
v1.cost = 25;
function v1.Activate(p1, p2, p3, p4)
	if game.CollectionService:HasTag(p2, "Casting") then
		return;
	end;
	local l__Mana__5 = p2.Mana;
	local v6 = game.Players:GetPlayerFromCharacter(p2);

	l__Mana__5.Value = math.max(l__Mana__5.Value - v1.cost, 0);

	if game.ServerStorage.PlayerData[v6.Name].PrimaryWeapon.Value == "Dark Sword" then
		return
	end
	if p2:FindFirstChild("DarkSword") then
		p2.DarkSword:Destroy();
	end;

	if p2:FindFirstChild("EarthSword") then
		p2.EarthSword:Destroy();
	end;
	local ogweapon = nil
	if game.ServerStorage.PlayerData[v6.Name].PrimaryWeapon.Value ~= "Dark Sword" then
		ogweapon = game.ServerStorage.PlayerData[v6.Name].PrimaryWeapon.Value
		game.ServerStorage.PlayerData[v6.Name].OGWeapon.Value = ogweapon
	end
	task.delay(.3, function()
		game.ServerStorage.PlayerData[v6.Name].PrimaryWeapon.Value = "Dark Sword"
		p2.HumanoidRootPart.PerfectCast:Play();
		p2.Humanoid:LoadAnimation(script.Parent.Animation):Play();
		p2.HumanoidRootPart.SwordSummon:Play();
	end);
	if ogweapon then
		task.delay(360, function()
			game.ServerStorage.PlayerData[v6.Name].PrimaryWeapon.Value = ogweapon
		end)
	end
	p2.Humanoid:UnequipTools();
end;
return v1;
