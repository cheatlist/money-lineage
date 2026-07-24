local disabled = true
local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
v1.upperbound = 80;
v1.lowerbound = 63;
v1.signs = 10;
v1.cost = 100;

local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;
local l__TweenService__3 = game:GetService("TweenService");
function v1.Activate(p1, p2, p3, p4)
	if disabled then return end
	if game.CollectionService:HasTag(p2, "Casting") then
		return;
	end;
	local l__Mana__2 = p2.Mana;
	local v3 = game.Players:GetPlayerFromCharacter(p2);
	local l__Value__4 = v3.Backpack.ManaColor.Value;
	local u4 = _G.MouseData(v3)
	if not u4 then
		return;
	end;
	if p3 == 0 then
		if p2:FindFirstChild("BloodTied") then
			return;
		end;
		l__Mana__2.Value = math.max(l__Mana__2.Value - v1.cost, 0);
		p2.HumanoidRootPart.PerfectCast:Play();
		local v5 = false;
		local v10
		local v9
		for i,v in pairs(game.Workspace.Live:GetChildren()) do
			if v.Name ~= "Dummy" and v ~= p2 and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - p2.HumanoidRootPart.Position).Magnitude <= 30 then
				v10 = v
				v9 = i
			end
		end
	if not v10 then return end
	
			local v11 = true;
			if v10:FindFirstChild("MonsterInfo") then
				if v10.MonsterInfo.MonsterType.Value ~= "Shrieker" or v10.MonsterInfo.Master.Value ~= p2 then
					v11 = false;
				end;
			elseif game.ServerStorage.PlayerData:FindFirstChild(v10.Name) then
				if game.ServerStorage.PlayerData[p2.Name].LastName.Value == "" or game.ServerStorage.PlayerData[v10.Name].LastName.Value ~= game.ServerStorage.PlayerData[p2.Name].LastName.Value then
					v11 = false;
				end;
			else
				v11 = false;
			end;
			
			if v11 and (v10.Torso.Position - p2.Torso.Position).Magnitude <= 30 and v10 ~= p2 and not v10:FindFirstChild("BloodTied") and v5 == false then
				local v12 = Instance.new("StringValue");
				v12.Name = "BloodTied";
				v12.Value = p2.Name;
				v12.Parent = v10;
				local v14 = Instance.new("Attachment");
				v14.Name = "BloodAttach";
				v14.Parent = p2.HumanoidRootPart;
				local v15 = Instance.new("Attachment");
				v15.Name = "BloodAttach";
				v15.Parent = v10.HumanoidRootPart;
			
				v5 = true;
				v10.HumanoidRootPart.Splat:Play();
				v10.HumanoidRootPart.BloodHex:Emit(30);
			end;		

		if v5 == true then
			local v16 = Instance.new("Accessory");
			v16.Name = "BloodTieMaster";
			v16.Parent = p2;
			p2.HumanoidRootPart.Splat:Play();
			p2.HumanoidRootPart.BloodHex:Emit(30);
		end;
	else
	
		l__TagHumanoid__2:Fire(p2, p2, {
			mana = true, 
			manablockbreak = true, 
			curse = true, 
			curseeffect = true, 
			damage = 60, 
			bloodhex = true, 
			manaknockupself = true
		});
		
	
		p2.HumanoidRootPart.Backfire:Play();
		
	end;
end;
return v1;
