local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
local l__TweenService__2 = game:GetService("TweenService");
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid;
v1.upperbound = 100;
v1.lowerbound = 75;
v1.signs = 12;
v1.cost = 100;
function ray(p1, p2, p3, p4)
	local v4, v5, v6 = workspace:FindPartOnRay(Ray.new(p1, CFrame.new(p1, p2).LookVector * p3), p4);
	return v4, v5, v6;
end;
local l__PlantGrowth__7 = game.ServerStorage.SpellEffects.PlantGrowth;
local u1 = require(l__PlantGrowth__7.GrowthEffect);
function v1.Activate(p5, p6, p7, p8)
	if p6:FindFirstChild("Casting") then
		return;
	end;
	local l__Mana__8 = p6.Mana;
	local LastUsed: number = p6:GetAttribute('LastUsedGourdus')or 0
	local Now: number = os.clock()
	if Now - LastUsed < 61 then
		return
	end
	p6:SetAttribute('LastUsedGourdus', Now)
	local v9 = game.Players:GetPlayerFromCharacter(p6);
	local l__Value__10 = game.ServerStorage.PlayerData[v9.Name].ManaColor.Value;
	local u2 = _G.MouseData(v9);
	if not u2 then
		return;
	end;
	local v11 = game.ServerStorage.PlayerData[v9.Name];
	if p7 == 0 then
		l__Mana__8.Value = math.max(l__Mana__8.Value - v1.cost, 0);
		sub(function()
			local v12 = nil;
			for v13 = -2, 2 do
				for v14 = -2.5, 2.5 do
					local v15 = l__PlantGrowth__7.FlatGround:Clone();
					v15.Parent = workspace;
					local v16 = p6.HumanoidRootPart.CFrame * CFrame.new(5 * v14, -4, -15 + 5 * v13);
					v15.CFrame = v16;
					local v17, v18, v19 = workspace:FindPartOnRayWithIgnoreList(Ray.new(v16.p + Vector3.new(0, 4, 0), Vector3.new(0, -25, 0)), { workspace.Live, workspace.Terrain, workspace.Thrown, workspace.MonsterSpawns });
					v15:Destroy();
					if v17.Name == "FlatGround" then
						p6.HumanoidRootPart.Diffusion:Play();
						return;
					end;
					if v12 == nil then
						v12 = v17;
					elseif v17 ~= v12 then
						p6.HumanoidRootPart.Diffusion:Play();
						return;
					end;
				end;
			end;
			for v20 = -2, 2 do
				for v21 = -0.4, 2.5 do
					local v22 = l__PlantGrowth__7.FlatGround:Clone();
					v22.Parent = game.Workspace;
					local v23 = p6.HumanoidRootPart.CFrame * CFrame.new(5 * v21, -3, -15 + 5 * v20);
					v22.CFrame = v23;
					local v24, v25, v26 = workspace:FindPartOnRayWithIgnoreList(Ray.new(v23.p + Vector3.new(0, 4, 0), Vector3.new(0, -25, 0)), { workspace.Live, workspace.Terrain, workspace.Thrown, workspace.MonsterSpawns });
					v22:Destroy();
					if v24.Name ~= "FlatGround" then
						p6.HumanoidRootPart.Diffusion:Play();
						return;
					end;
				end;
			end;
			local v27, v28 = workspace:FindPartOnRayWithIgnoreList(Ray.new((p6.HumanoidRootPart.CFrame * CFrame.new(0, -5, -15)).p + Vector3.new(0, 5, 0), Vector3.new(0, -25, 0)), { workspace.Live, workspace.Terrain, workspace.Thrown, workspace.MonsterSpawns });
			if not v27 then
				p6.HumanoidRootPart.Diffusion:Play();
				return;
			end;
			local v30 = l__PlantGrowth__7.GrowthEffect.Growth:Clone();
			v30.Parent = p6.Torso;
			v30:Play();
			--			game.ServerStorage.Requests.SetStoryMarker:Invoke(v9, "UsedPumpkinPatch", v11.DaysSurvived.Value);
			local v31 = l__PlantGrowth__7["Pumpkin Patch"]:Clone();
			v31:PivotTo(CFrame.new(v28,v28 + Vector3.new(math.random(-5,5),0,math.random(-5,5))) + Vector3.new(0,4,0));
			v31.Parent = workspace.Thrown;
			--u1.fadeInStart(v31);
			--u1.fadeInSuccess(v31);
			--u1.fadeOut(v31, 10);
			for _,v in pairs(v31:GetChildren()) do
				if v:IsA("BasePart") then
					local origcolor = v.Color
					local origmat = v.Material
					v.Material = Enum.Material.Neon
					v.Color = Color3.fromRGB(100, 255, 100)
					game.TweenService:Create(v,TweenInfo.new(1),{Transparency = 0}):Play()
					task.spawn(function()
						task.wait(1)
						if v:FindFirstChild("Shards") then
							v.Shards:Emit(6)
						end
						v.Color = origcolor
						v.Material = origmat
						task.wait(10)
						game.TweenService:Create(v,TweenInfo.new(1),{Transparency = 1}):Play()
					end)
				end
			end
			task.wait(1)
			game.Debris:AddItem(v31,11)
			for v32 = 0, 9 do
				for v33, v34 in ipairs(workspace.Live:GetChildren()) do
					if (v31.PrimaryPart.Position - v34.Torso.Position).Magnitude < 30 then
						local l__Stomach__35 = v34:FindFirstChild("Stomach");
						if l__Stomach__35 then
							l__Stomach__35.Value += 15;
						end;
					end;
				end;
				wait(1);
				v31.PrimaryPart.Sound:Play();
			end;
		end);
	else
		p6.HumanoidRootPart.Diffusion:Play();
	end;

end;
return v1;
