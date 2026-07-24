local FindFirstChild,WaitForChild = game.FindFirstChild,game.WaitForChild
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
local Player = nil
local p1 = nil
script.Parent.Equipped:Connect(function()
	p1 = script.Parent.Parent
	Player = game.Players:GetPlayerFromCharacter(p1)
end)
local canuse = true
script.Parent.Activated:Connect(function()
	
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	
	local deadplayers = {}
	
	local data = game.ServerStorage.PlayerData:FindFirstChild(p1.Name)
	local dead_children = game.Workspace.Dead:GetChildren()
	for index = 1,#dead_children do
		local object = dead_children[index]
		if object:FindFirstChild("HumanoidRootPart") and object:FindFirstChild("Humanoid") and not object:FindFirstChild("LichSummon") and object ~= p1 then
			local objectdata = game.ServerStorage.PlayerData:FindFirstChild(object.Name)
			if objectdata and (objectdata.Lives.Value == 0) and object.Race.Value ~= "Lich" then
				table.insert(deadplayers,object)
			end
		end
	end
	
	if #deadplayers == 0 then return end
	canuse = false
	local summonplr = deadplayers[math.random(1,#deadplayers)] 
	p1.HumanoidRootPart.ChargeUpCast:Play();
	p1.Humanoid:LoadAnimation(script.Animation):Play()
	local check = Instance.new("Accessory");
	check.Name = "LichSummon";
	check.Parent = summonplr;
	local objectdata = game.ServerStorage.PlayerData:FindFirstChild(summonplr.Name)
	
	local check = Instance.new("Accessory");
	check.Name = "LichSummon";
	check.Parent = game.Players:GetPlayerFromCharacter(summonplr);
	
	objectdata.LastPosition.Value = tostring(p1.HumanoidRootPart.Position)
	
	game.Players:GetPlayerFromCharacter(summonplr):LoadCharacter()
	local v12 = Instance.new("NumberValue");
	v12.Name = "Transparency";
	v12.Value = 0;
	v12.Parent = summonplr.Boosts;
	
	objectdata.LastPosition.Value = tostring(p1.HumanoidRootPart.Position)
	
	task.wait(1.25)
	
	local TPSafe = Instance.new("Folder")
	TPSafe.Name = 'TPSafe'
	TPSafe.Parent = summonplr
	game.Debris:AddItem(TPSafe,4)
	
	summonplr.HumanoidRootPart.Position = p1.HumanoidRootPart.Position
	
	local sphere = game.ServerStorage.Assets.Dark:Clone();
	sphere.CFrame = summonplr.Torso.CFrame;
	sphere.Parent = workspace.Thrown;
	game:GetService("Debris"):AddItem(sphere, 2);
	sphere.Sound:Play();
	sphere.Attachment.OrbParticle:Emit(100);
	
	
	game:GetService("TweenService"):Create(sphere, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false), {
		Size = Vector3.new(10.05, 10.05, 10.05)
	}):Play();
	local check = Instance.new("Accessory");
	check.Name = "LichSummon";
	check.Parent = summonplr;
	
	task.wait(15)
	canuse = true
end)