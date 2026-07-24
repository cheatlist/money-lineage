local v1 = {};
v1.upperbound = 100;
v1.lowerbound = 70;
v1.signs = 5;
v1.cost = 0;
v1.solanedict = true;
local l__Barrier__1 = game.ServerStorage.SpellEffects.Barrier;
local l__TweenService__2 = game:GetService("TweenService");
local l__TagHumanoid__4 = game.ServerStorage.Requests.TagHumanoid;
function v1.Activate(p1, p2, p3, p4)
	if game.CollectionService:HasTag(p2, "Casting") or p2:FindFirstChild("ActiveCast") then
		return;
	end;
	local l__Mana__2 = p2.Mana;
	local v3 = game.Players:GetPlayerFromCharacter(p2);
	local l__Value__4 = v3.Backpack.ManaColor.Value;
	if p3 ~= 0 then
		p2.HumanoidRootPart.Diffusion:Play();
		if p4 and p4:FindFirstChild("Backfire") then
			p4.Backfire.Color = ColorSequence.new(Color3.new(l__Value__4.r, l__Value__4.g, l__Value__4.b));
			p4.Backfire:Emit(15);
		end;
		return;
	end;
	l__Mana__2.Value = math.max(l__Mana__2.Value - v1.cost, 0);
	p2.HumanoidRootPart.PerfectCast:Play();
	local l__HumanoidRootPart__6 = p2.HumanoidRootPart;
	local v9 = l__Barrier__1.OrderBubble:Clone();
	v9.CFrame = p2.HumanoidRootPart.CFrame;
	l__TweenService__2:Create(v9, TweenInfo.new(1), {
		Transparency = 0
	}):Play();
	game.Debris:AddItem(v9, 60);
	v9.Touched:Connect(function(p5)
		local v10 = p5.Parent:FindFirstChild("Humanoid") or p5.Parent.Parent:FindFirstChild("Humanoid");
		if not v10 then
			return;
		end;
		local l__Parent__11 = v10.Parent;
		local v12 = l__Parent__11 and game.Players:FindFirstChild(l__Parent__11.Name);
		local v13 = v12 and game.ServerStorage.PlayerData:FindFirstChild(l__Parent__11.Name);
		if not v13 then
			return;
		end;
		local v14 = game.ServerStorage.PlayerData[v13.Name].Alignment.Value;
		if v12 == v3 or (game.ServerStorage.PlayerData:FindFirstChild(l__Parent__11.Name) and game.ServerStorage.PlayerData:FindFirstChild(l__Parent__11.Name).LastName.Value == game.ServerStorage.PlayerData:FindFirstChild(p2.Name).LastName.Value and game.ServerStorage.PlayerData:FindFirstChild(p2.Name).LastName.Value ~= "") then
			if l__Parent__11:FindFirstChild("NoPass") then
				return;
			else
				local v15 = Instance.new("Accessory");
				v15.Name = "NoPass";
				v15.Parent = l__Parent__11;
				game:GetService("Debris"):AddItem(v15, 1);
				v10.RootPart.Ordersound:Play();
				v10.RootPart.MoneyEmit:Emit(5);
				return;
			end;
		end;
		if l__Parent__11:FindFirstChild("NoPass") or l__Parent__11:FindFirstChild("Grabbed") then
			return;
		end;
		local v16 = Instance.new("Accessory");
		v16.Name = "NoPass";
		v16.Parent = l__Parent__11;
		game:GetService("Debris"):AddItem(v16, 1);
		v10.RootPart.SLAMJAM:Play();
		v10.RootPart.MoneyEmit:Emit(15);
		l__TagHumanoid__4:Fire(p2, l__Parent__11, {
			mana = true, 
			manaknockupself = true, 
			damage = 15, 
			manabreaker = true,
			nododge = true,
			move = "Reality Bubble"
		});
	end);
	v9.Parent = workspace.Thrown;
	v9.Sound:Play()
	task.wait(4)
	v9.Sound:Stop()
	l__TweenService__2:Create(v9, TweenInfo.new(1), {
		Size = Vector3.new(0, 0, 0)
	}):Play();
	game.Debris:AddItem(v9, 1);
end;
function v1.Deactivate(p6, p7, p8)
	local v18 = Instance.new("Accessory");
	v18.Name = "EndCast";
	v18.Parent = p7;
	game:GetService("Debris"):AddItem(v18, 0.4);
end;
return v1;
