local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local l__PhysicsService__2 = game:GetService("PhysicsService");
local u6 = require(game.ServerScriptService.Modules.DangerHandler);
local v33 = u6;
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
	if l__Parent__1:FindFirstChild("ActiveCast") then
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
	if game.CollectionService:HasTag(l__Parent__1, "Unconscious") or l__Parent__1:FindFirstChild("Unconscious") then
		return true;
	end;
	if game.CollectionService:HasTag(l__Parent__1, "Knocked") or l__Parent__1:FindFirstChild("Knocked") then

	else
		return;
	end;
	return true;
end;
local v3 = tick();
local u2 = true;
local u3 = true;
local u4, grabee = nil, nil;
function v1.Active(p1, p2, p3, p4)
	if ActionCheck() then
		return;
	end;
	if p1:FindFirstChild("GrabCool") then
		return;
	end;
	if game.CollectionService:HasTag(p1, "Knocked") or p1:FindFirstChild("Knocked") then
		return;
	end;
	if not u2 then
		return;
	end;
	local v4 = Instance.new("Folder");
	v4.Name = "GrabCool";
	v4.Parent = p1;
	game:GetService("Debris"):AddItem(v4, 1);
	local v5 = Instance.new("Folder");
	v5.Name = "Action";
	v5.Parent = p1;
	game:GetService("Debris"):AddItem(v5, 1);
	p1.Humanoid:LoadAnimation(script.Pickup):Play();
	if u3 ~= true then
		local v6 = Instance.new("Folder");
		v6.Parent = p1;
		v6.Name = "Ungrab";
		game.Debris:AddItem(v6, 2);
		u3 = true;
		u4 = nil;
		return;
	end;
	local l__HumanoidRootPart__7 = p1.HumanoidRootPart;
	local v8, v9, v10 = pairs(game.Workspace.Live:GetChildren());

	for v11, v12 in pairs(workspace.Live:GetChildren()) do
		local v13 = v12:IsA("Model") and v12 or nil;
		if v13 and v13:FindFirstChild("Humanoid") and v13:FindFirstChild("HumanoidRootPart") and v13 ~= p1 and (l__HumanoidRootPart__7.Position - v13.HumanoidRootPart.Position).magnitude <= 10 and not v12:FindFirstChild("KO") and not v12:FindFirstChild("BIGKO") and v13.Humanoid.Health > 0 and not v12:FindFirstChild("LightAttack") and not p1:FindFirstChild("Stun") and not v12:FindFirstChild("Grabbing") and not v12:FindFirstChild("Carried") and not v12:FindFirstChild("Grabbed") and not v12:FindFirstChild("HeavyAttack") and not v12:FindFirstChild("Immortal") and not v12:FindFirstChildOfClass("ForceField") and not v12:FindFirstChild("Burning") and not v12:FindFirstChild("Danger") then
			if string.find(v12.Name, "Howler") or not v12:FindFirstChild("MonsterInfo") then
				if (not v12:FindFirstChild("MonsterInfo")) and game.Players[v12.Name]:FindFirstChild("Danger") then
					return
				end
				carry(p1, v12);
				u4 = v12;
				u3 = false;
				local v14 = Instance.new("Folder");
				v14.Name = "Action";
				v14.Parent = v12;
				game:GetService("Debris"):AddItem(v14, 0.5);
				task.spawn(function()
					wait(30);
					local v15 = Instance.new("Folder");
					v15.Parent = p1;
					v15.Name = "Ungrab";
					game.Debris:AddItem(v15, 2);
					u3 = true;
					u4 = nil;
				end);
			end;
		end
	end
end;
function Weld(p5, p6, p7, p8, p9, p10)
	p6.CFrame = p7.CFrame;
	local v16 = Instance.new(p5);
	v16.Part0 = p7;
	v16.Part1 = p6;
	v16.C0 = p8 or CFrame.new();
	v16.C1 = p9 or CFrame.new();
	v16.Parent = p6;
	return v16;
end;
local l__TagHumanoid__5 = game.ServerStorage.Requests.TagHumanoid;
function carry(p11, p12)
	if grabee then
		return;
	end;
	local v17 = game.Players:GetPlayerFromCharacter(p11);
	local v18 = Instance.new("Folder");
	v18.Name = "Action";
	v18.Parent = p11;
	game:GetService("Debris"):AddItem(v18, 0.5);
	local v19 = p11.Humanoid:LoadAnimation(script.Carry);
	local v20 = p12.Humanoid:LoadAnimation(script.Carried);
	if not p12.Parent then
		return;
	end;
	local v21 = Instance.new("StringValue");
	v21.Name = "Grabbed";
	v21.Parent = p12;
	v21.Value = p11.Name;
	local v22 = Instance.new("ObjectValue");
	v22.Name = "Interrogated";
	v22.Parent = p12;
	v22.Value = p11;

	game.CollectionService:AddTag(v22, "GrabEffect");
	task.wait(0.5);
	if not p12.Parent then
		return;
	end;
	v19:Play();
	local v23 = Instance.new("ObjectValue");
	v23.Name = "Grabbing";
	v23.Value = p12;
	v23.Parent = p11;
	local v233 = Instance.new("Folder");
	v233.Name = "CantCast";
	v233.Parent = p11;
	local anti = Instance.new("Folder")
	anti.Name = "AntiDrop"
	anti.Parent = v23
	local v24 = Instance.new("Folder");
	v24.Name = "Interrogating";
	v24.Parent = p11;
	local v25 = Instance.new("Folder");
	v25.Name = "Action";
	v25.Parent = p12;
	if not p12:FindFirstChild("MonsterInfo") then
		local danger = Instance.new("Folder")
		danger.Name = "Danger"
		danger.Parent = game.Players[p12.Name]
		game.Debris:AddItem(danger, 50)
	end
	game.CollectionService:AddTag(v25, "GrabEffect");
	if p12:FindFirstChild("Burning") then
		l__TagHumanoid__5:Fire(p11, p11, {
			mana = true, 
			burn = true, 
			damage = 5
		});
	end;
	game.ServerStorage.Requests.Wakeup:Fire(p12);
	for v29, v30 in pairs(p12:GetChildren()) do
		if v30:IsA("BasePart") then
			if not v30:IsGrounded() then
				v30:SetNetworkOwner(v17);
			end;
		end;
	end
	local v31 = Weld("Motor6D", p11.HumanoidRootPart, p12.HumanoidRootPart, CFrame.new(0, -0.5, 0.5));
	grabee = p12;
	v20:Play();
	local v32 = Instance.new("BodyGyro");
	game.CollectionService:AddTag(v32, "AllowedBM");
	v32.Name = "GrabBg";
	v32.Parent = p12.HumanoidRootPart;
	p12.Parent = workspace.Thrown;
	local v33 = u6:getEntity(p12);
	if v33 then
		v33:createTag(v17.Name .. ":Carry", {
			damage = math.huge
		});
	end;
	task.spawn(function()
		while task.wait() do
			if p11:FindFirstChild("Ungrab") or p12:FindFirstChild("Ungrab") then
				break;
			end;

			if not p12.Parent or p11 == nil then
				break
			end

			if not p11.Parent then
				break
			end

			if game.CollectionService:HasTag(p11, "Knocked") then
				break;
			end;
			if not game.Players:FindFirstChild(p11.Name) then
				break;
			end;
			if v31 == nil or v31.Parent == nil then
				break;
			end;		
		end;
		v31:Destroy();
		v23:Destroy();
		v24:Destroy();
		v22:Destroy();
		v233:Destroy();
		v19:Stop();
		if v33 then
			v33:createTag(v17.Name .. ":Carry", {
				damage = math.huge, 
				lifespan = 20
			});
		end;
		if p12.Parent then
			p12.Parent = workspace.Live;
			local v34 = game.Players:FindFirstChild(p12.Name);
			for v38, v39 in pairs(p12:GetChildren()) do
				if v39:IsA("BasePart") then
					if not v39:IsGrounded() then
						if v34 then
							v39:SetNetworkOwner(v34);
						else
							v39:SetNetworkOwner(nil);
						end;
					end;
				end;	
			end
			if grabee then
				if v20 then
					v20:Stop();
				end;
				if grabee:FindFirstChild("Grabbed") then
					grabee.Grabbed:Destroy();
				end;
				v25.Parent = nil;
				if grabee.HumanoidRootPart:FindFirstChild("Grab") then
					grabee.HumanoidRootPart.Grab:Destroy();
				end;
				if grabee.HumanoidRootPart:FindFirstChild("GrabBg") then
					grabee.HumanoidRootPart.GrabBg:Destroy();
				end;
				task.wait(0.1);
				if p12:FindFirstChild("CompletedChoke") then
					
					local a = Instance.new("Folder")
					a.Name = "Knocked"
					a.Parent = p12
					game.Debris:AddItem(a, 15)
					Instance.new("Folder", a).Name = "Interrogation"
				else
					game.ServerStorage.Requests.Wakeup:Fire(p12);
				end;
				grabee = nil;
			end;
		end;
	end);
end;
function v1.Active2(p13, p14, p15, p16)
	if game.CollectionService:HasTag(p13, "Knocked") or p13:FindFirstChild("Knocked") then
		return;
	end;
	if not u2 then
		return;
	end;
	if u4 ~= nil then
		u2 = false;
		local v40 = p13.Humanoid:LoadAnimation(script.Choke);
		v40:Play();
		local v41 = true;
		local v42 = false;
		local lastTime = time()
		p13.HumanoidRootPart.Choke:Play();
		local v43 = Instance.new("Folder");
		v43.Name = "Action";
		v43.Parent = p13;
		game:GetService("Debris"):AddItem(v43, 3);
		while v41 == true do
			task.wait(0.1);
			if p13:FindFirstChild("Stun") or p13:FindFirstChild("Ungrab") then
				v42 = false;
				v40:Stop();
				if p13:FindFirstChild("Action") then
					p13.Action:Destroy();
				end;
				lastTime = time()
			end;
			if time() - lastTime >= 3 then
				v42 = true;
				v41 = false;
			end;		
		end;
		if v42 == true then
			local v44 = Instance.new("Folder");
			v44.Name = "CompletedChoke";
			v44.Parent = u4;
			game:GetService("Debris"):AddItem(v44, 1);
			local v45 = Instance.new("Folder");
			v45.Parent = p13;
			v45.Name = "Ungrab";
			game.Debris:AddItem(v45, 0.6);
		else
			local v46 = Instance.new("Folder");
			v46.Parent = p13;
			v46.Name = "Ungrab";
			game.Debris:AddItem(v46, 0.6);
		end;
		u3 = true;
		u4 = nil;
		u2 = true;
	end;
end;
return v1;
