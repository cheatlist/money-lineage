local v1 = {};
local l__Parent__2 = script.Parent;
function ActionCheck(p1)
	if not p1:FindFirstChild("Humanoid") then
		return true;
	end;
	if p1:FindFirstChild("Stun") then
		return true;
	end;
	if p1:FindFirstChild("ReturnStun") then
		return true;
	end;
	if p1:FindFirstChild("ActiveCast") then
		if not p1:FindFirstChild("Dissolved") then
			return true;
		end;
	end;
	if p1:FindFirstChild("Action") then
		return true;
	end;
	if p1:FindFirstChild("Blocking") then
		return true;
	end;
	if p1:FindFirstChild("SpellBlocking") then
		return true;
	end;
	if p1.Humanoid.Health == 0 then
		return true;
	end;
	if not p1:FindFirstChild("Grabbed") then
		if p1:FindFirstChild("Grabbing") then
			return true;
		end;
	else
		return true;
	end;
	if p1:FindFirstChild("Climbing") then
		return true;
	end;
	if game.CollectionService:HasTag(p1, "Unconscious") or p1:FindFirstChild("Unconscious") then
		return true;
	end;
	if game.CollectionService:HasTag(p1, "Knocked") or p1:FindFirstChild("Knocked") then

	else
		return;
	end;
	return true;
end;
local u1 = true;
function v1.Active(p2, p3, p4, p5)
	if u1 == false then
		return;
	end;
	u1 = false;
	local l__Humanoid__3 = p2:FindFirstChild("Humanoid");
	if p2:FindFirstChild("Dissolved") then
		p2.Dissolved:Destroy();
	else
		if ActionCheck(p2) then
			return;
		end;
		game.CollectionService:AddTag(p2, "TempStop")
		p2.Mana.Value = 0
		game.CollectionService:RemoveTag(p2, "TempStop")
		task.spawn(function()
			local v4 = nil;
			local v5 = Instance.new("Accessory");
			v5.Name = "Dissolved";
			v5.Parent = p2;
			local v6 = Instance.new("Accessory");
			v6.Name = "ActiveCast";
			v6.Parent = p2;
			local v7 = Instance.new("Accessory");
			v7.Name = "Action";
			v7.Parent = p2;
			game.Debris:AddItem(v7, 2);
			local v8 = Instance.new("Accessory");
			v8.Name = "NoHeal";
			v8.Parent = p2;
			local v9 = Instance.new("Accessory");
			v9.Name = "ManaStop";
			v9.Parent = p2;
			local v10 = Instance.new("Accessory");
			v10.Name = "NoSprint";
			v10.Parent = p2;
			local v11 = Instance.new("Accessory");
			v11.Name = "NoJump";
			v11.Parent = p2;
			local v12 = Instance.new("Accessory");
			v12.Name = "NoAttack";
			v12.Parent = p2;
			local v13 = Instance.new("Accessory");
			v13.Name = "NoDash";
			v13.Parent = p2;
			local v14 = l__Humanoid__3:LoadAnimation(script.Dive);
			v14:Play();
			local v16 = 0;
			while true do
				v16 += task.wait();
				v4 = p2:FindFirstChild("Stun") or game.CollectionService:HasTag(p2, "Knocked");
				if v16 >= 2 then
					break;
				end;
				if v4 then
					break;
				end;			
			end;
			v14:Stop();
			if not v4 then
				local v17 = Instance.new("Accessory");
				v17.Name = "Immortal";
				v17.Parent = p2;
				local l__DragonCrusher__18 = p2.HumanoidRootPart:FindFirstChild("DragonCrusher");
				if l__DragonCrusher__18 then
					l__DragonCrusher__18:Emit(1);
				end;
				local v19 = Instance.new("NumberValue");
				v19.Name = "Transparency";
				v19.Value = 1;
				v19.Parent = p2.Boosts;
				local v20 = Instance.new("Part");
				v20.Name = "NoRecord";
				v20.TopSurface = 0;
				v20.BottomSurface = 0;
				
				v20.Color = p2.Head.Color;
				v20.Size = Vector3.new();
				v20.CanCollide = false;
				v20.Anchored = false;
				local v21 = v20:clone();
				Instance.new("SpecialMesh", v21).Scale = Vector3.new(1.25, 1.25, 1.25) / v21.Size;
				v21.Parent = v20;
				local v22 = Instance.new("SpecialMesh", v20);
				v22.MeshType = "Sphere";
				v22.Scale = Vector3.new(2, 4, 2) / v20.Size;
				local v23 = Instance.new("Attachment", v20);
				v23.Position = Vector3.new(-1.5, 0.01, 0);
				local v24 = Instance.new("Attachment", v20);
				v24.Position = Vector3.new(1.5, 0.01, 0);
				local v25 = script.PuddleTrail:clone();
				v25.Color = ColorSequence.new(v20.Color);
				v25.Attachment0 = v23;
				v25.Attachment1 = v24;
				v25.Parent = v20;
				local v26 = Instance.new("Weld", v20);
				v26.Part0 = p2.HumanoidRootPart;
				v26.Part1 = v20;
				v26.C0 = CFrame.new(0, p2.HumanoidRootPart.Size.y * -1.5, 0);
				--[[
				local v27 = p2.Head:FindFirstChild("RLFace"):clone();
				v27.Transparency = 0;
				v27.Parent = v21;
				]]
				
				local RLFace = (p2.Head:FindFirstChildOfClass("Decal") or nil)
				if RLFace then
					RLFace = RLFace:Clone();
					RLFace.Transparency = 0;
					RLFace.Parent = v21
				end
				
				local v28 = Instance.new("Weld", v21);
				v28.Part0 = v20;
				v28.Part1 = v21;
				v28.C0 = CFrame.new(0, 0, -0.5) * CFrame.Angles(math.rad(22), 0, 0);
				local v29 = script.Splash:Clone();
				v29.Parent = v20;
				v20.Parent = p2;
				v29:Play();
				game.TweenService:Create(v22, TweenInfo.new(0.2), {
					Scale = Vector3.new(3, 0.5, 3) / v20.Size
				}):Play();
				local v30 = false;
				local v31 = 0;
				while true do
					v31 = v31 + task.wait(0.1);
					if v31 >= 0.5 and not v30 then
						v30 = true;
						game.TweenService:Create(v23, TweenInfo.new(20), {
							Position = Vector3.new(-1.25, 0.01, 0)
						}):Play();
						game.TweenService:Create(v24, TweenInfo.new(20), {
							Position = Vector3.new(1.25, 0.01, 0)
						}):Play();
						game.TweenService:Create(v22, TweenInfo.new(20), {
							Scale = Vector3.new(2.5, 0.5, 2.5) / v20.Size
						}):Play();
					end;
					if not p2:FindFirstChild("Dissolved") then
						break;
					end;
					if game.CollectionService:HasTag(p2, "Knocked") then
						break;
					end;
					if v4 then
						break;
					end;
					if v31 >= 15 then
						break;
					end;				
				end;
				if v7 and v7.Parent then
					v7:Destroy();
				end;
				v25.Enabled = false;
				v21:Destroy();
				local v32 = Instance.new("Accessory");
				v32.Name = "Action";
				v32.Parent = p2;
				game.Debris:AddItem(v32, 0.3);
				game.TweenService:Create(v22, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
					Offset = Vector3.new(0, 1, 0), 
					Scale = Vector3.new(2, 6, 2) / v20.Size
				}):Play();
			end;
			if v5.Parent then
				v5:Destroy();
			end;
			if v7 then
				(v7):Destroy();
			end;
			task.wait(0.3);
			
			if p2:FindFirstChild("Immortal") then
				p2.Immortal:Destroy()
			end
			
			if p2:FindFirstChild("NoRecord") then
				p2.NoRecord:Destroy()
			end
			
			v6:Destroy();
			v11:Destroy();
			v8:Destroy();
			v10:Destroy();
			v12:Destroy();
			v13:Destroy();
			v9:Destroy();
			
			for i,v in p2.Boosts:GetChildren() do
				if v.Name ~= ("Transparency") then continue end
				if v.Value ~= 1 then continue end
				v:Destroy()
			end
			
			game.CollectionService:AddTag(p2, "Nullified");
			task.delay(3, function()
				game.CollectionService:RemoveTag(p2, "Nullified");
			end);
			task.wait(1);
			if v4 then
				task.wait(5);
			end;
		end);
	end;
	task.wait(1);
	u1 = true;
end;
return v1;
