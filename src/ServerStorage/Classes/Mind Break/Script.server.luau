function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local u8 = game.ServerStorage.Requests.TagHumanoid
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
		healthBelow = 5,
	})
end

local function canRoot(p7): boolean
	if p7:FindFirstChild("Knocked") or p7:FindFirstChild("Blocking") then
		return false;
	end
	return true;
end;

local l__Barrier__1 = game.ServerStorage.SpellEffects.Barrier;
local canuse = true
local canuse2 = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	local HumanoidRootPart = p1.HumanoidRootPart
	local Hum = p1:FindFirstChild("Humanoid")
	local player = game.Players:GetPlayerFromCharacter(p1)
	if p1.Boosts:FindFirstChild("VeilBuff") and not p1.Cooldowns:FindFirstChild("Veil Mind Break") then
		local CD = Instance.new("NumberValue")
		CD.Name = "Veil Mind Break"
		CD.Value = 20
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 20)
		canuse = false
		local Action = Instance.new("NumberValue")
		Action.Parent = p1
		Action.Name = "Action"
		local Anim = Hum:LoadAnimation(script.Parent.Anim1)
		Anim:Play(0.8)
		Anim:GetMarkerReachedSignal("Reached"):Connect(function()
			HumanoidRootPart.MindBreak:Play()
			HumanoidRootPart.PhantasmalCleave:Emit()
			HumanoidRootPart.PhantasmalEmit:Emit(15)
			local OrderBubble = l__Barrier__1.OrderBubble:Clone()
			OrderBubble.Size = Vector3.new(1,1,1)
			OrderBubble.CFrame = HumanoidRootPart.CFrame
			OrderBubble.Parent = workspace.Thrown
			OrderBubble.Transparency = 0
			TweenService:Create(OrderBubble, TweenInfo.new(0.5), {
				Size = Vector3.new(40, 40, 40)
			}):Play();
			OrderBubble.Touched:Connect(function(p5)
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
				if v12 == player then
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
				u8:Fire(p1, l__Parent__11, {
					mana = true, 
					manaknockupself = true, 
					damage = 30, 
					manabreaker = true,
					nododge = true,
					knockback = true,
					move = "Mind Break"
				});
			end)
			task.wait(0.5)
			Action:Destroy()
			task.wait(2)
			TweenService:Create(OrderBubble, TweenInfo.new(1), {
				Transparency = 1
			}):Play();
			task.wait(1)
			OrderBubble:Destroy()
		end)
		task.spawn(function()
			task.wait(20)
			canuse = true
		end)
	else
		if p1.Cooldowns:FindFirstChild("Mind Break") then
			return
		end
		local CD = Instance.new("NumberValue")
		CD.Name = "Mind Break"
		CD.Value = 15
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 15)
		local p2 = game.Players:GetPlayerFromCharacter(p1)
		local u4 = _G.MouseData(p2);
		if not u4 then
			return;
		end;
		local l__p__49 = u4.Hit.p;
		if (l__p__49 - HumanoidRootPart.Position).magnitude > 150 then
			return;
		end;
		if not workspace:FindPartOnRayWithIgnoreList(Ray.new(HumanoidRootPart.CFrame.p, Vector3.new(0, -10, 0)), { workspace.AreaMarkers, workspace.MonsterSpawns, workspace.Live }) then
			return;
		end;
		p1.Humanoid:LoadAnimation(script.Parent.Anim2):Play()
		HumanoidRootPart.Snap:Play()
		local v18 = game.ReplicatedStorage.Assets.HandHoldIllusion.PointLight:Clone();
		v18.Parent = p1.HumanoidRootPart;
		local v52 = nil;
		local v53 = 10;
		for v54, v55 in pairs(game.Workspace.Live:GetChildren()) do
			local l__HumanoidRootPart__56 = v55:FindFirstChild("HumanoidRootPart");
			if l__HumanoidRootPart__56 and (l__HumanoidRootPart__56.Position - l__p__49).magnitude <= 10 and (l__HumanoidRootPart__56.Position - l__p__49).magnitude < v53 and v55 ~= p1 and not v55:FindFirstChild("Immortal") and not v55:FindFirstChildOfClass("ForceField") then
				v53 = (v55.Torso.Position - l__p__49).magnitude;
				v52 = v55;
			end;
		end;
		if v52 and canRoot(v52) then
			local Action = Instance.new("NumberValue")
			Action.Parent = v52
			Action.Name = "Action"
			v52.Humanoid.AutoRotate = false
			local staggered = v52.Humanoid:LoadAnimation(game.ReplicatedStorage.CombatAnims.Staggered)
			staggered:Play()
			task.spawn(function()
				for i = 1,3 do
					task.spawn(function()
						local v44 = Instance.new("Part")
						v44.Transparency = 1
						v44.Anchored = true
						v44.CanCollide = false
						v44.CFrame = v52.HumanoidRootPart.CFrame * CFrame.new(math.random(-8, 8), math.random(3, 8), math.random(3, 4))
						v44.CFrame = CFrame.new(v44.Position, v52.HumanoidRootPart.Position);
						local PositionOriginal = v44.Position
						local v46 = game.ServerStorage.verto:FindFirstChild("Illusory Sword"):Clone()
						local rot = CFrame.Angles(math.rad(90), 0, 0)
						v46.Anchored = true;
						v46.CanCollide = false;
						v46.CFrame = v44.CFrame;
						v46.CFrame = CFrame.new(v46.Position, v52.HumanoidRootPart.Position)
						v46.Parent = game.Workspace.Thrown;
						v46.Transparency = 1
						v46.Cube.Transparency = 1
						v46["Cube.002"].Transparency = 1
						v46.Cylinder.Transparency = 1
						v46["Cylinder.001"].Transparency = 1
						
						v52.HumanoidRootPart.summon:Play()
						
						TweenService:Create(v46, TweenInfo.new(0.1), {
							Transparency = 0
						}):Play();
						TweenService:Create(v46.Cube, TweenInfo.new(0.1), {
							Transparency = 0
						}):Play();
						TweenService:Create(v46["Cube.002"], TweenInfo.new(0.1), {
							Transparency = 0
						}):Play();
						TweenService:Create(v46.Cylinder, TweenInfo.new(0.1), {
							Transparency = 0
						}):Play();
						TweenService:Create(v46["Cylinder.001"], TweenInfo.new(0.1), {
							Transparency = 0
						}):Play();
						
						task.wait(0.2)
						
						local v53 = (v46.Position - v52.HumanoidRootPart.Position).magnitude / 5;
						for v54 = 1, math.ceil(v53) do
							task.wait();
							v46.CFrame = v46.CFrame:lerp(CFrame.new(v52.HumanoidRootPart.Position, PositionOriginal) * rot, v54 / v53);
						end;
						u8:Fire(p1, v52, {
 							slash = true,
							physical = true, 
							sword = true, 
							damage = 7.5,
							blade = true,
							move = "Mind Break"
						});
						
						task.wait(0.4 - 0.1 * i)
						TweenService:Create(v46, TweenInfo.new(0.1), {
							Transparency = 1
						}):Play();
						TweenService:Create(v46.Cube, TweenInfo.new(0.1), {
							Transparency = 1
						}):Play();
						TweenService:Create(v46["Cube.002"], TweenInfo.new(0.1), {
							Transparency = 1
						}):Play();
						TweenService:Create(v46.Cylinder, TweenInfo.new(0.1), {
							Transparency = 1
						}):Play();
						TweenService:Create(v46["Cylinder.001"], TweenInfo.new(0.1), {
							Transparency = 1
						}):Play();
						task.wait(0.1)
						v44:Destroy()
						v46:Destroy()
					end)
					task.wait(0.1)
				end
			end)
			task.wait(0.25)
			v52.Humanoid.AutoRotate = true
			Action:Destroy()
			staggered:Stop()
		end
		v18:Destroy()
		task.spawn(function()
			task.wait(15)
			canuse2 = true
		end)
	end
end)