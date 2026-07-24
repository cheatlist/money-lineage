local v1 = {};
v1.upperbound = 30;
v1.lowerbound = 10;
v1.signs = 5;
v1.cost = 25;
local l__Undead__1 = game:GetService("ServerStorage").SpellEffects.Undead
local l__TweenService__2 = game:GetService("TweenService");
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid;
function v1.Activate(p1, p2, p3, p4)
	if game.CollectionService:HasTag(p2, "Casting") then
		return;
	end;
	local l__Mana__2 = p2.Mana;
	local v3 = game.Players:GetPlayerFromCharacter(p2);
	local l__Value__4 = game.ServerStorage.PlayerData[v3.Name].ManaColor.Value;
	local u4 = _G.MouseData(v3);
	if not u4 then
		return;
	end;
	task.spawn(function()
		if p3 == 0 then
			l__Mana__2.Value = math.max(l__Mana__2.Value - v1.cost, 0);
			p2.HumanoidRootPart.PerfectCast:Play();
			local v5 = l__Undead__1.DisarmSpell:Clone();
			v5.CFrame = p2.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3);
			v5.CFrame = CFrame.new(v5.Position, u4.Hit.p);
			v5.Parent = workspace;
			v5:SetNetworkOwner(nil);
			local l__Motor6D__6 = v5:FindFirstChild("Motor6D");
			local v7 = Instance.new("NumberValue", l__Motor6D__6);
			game.TweenService:Create(v7, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
				Value = 360
			}):Play();
			v7:GetPropertyChangedSignal("Value"):connect(function()
				if l__Motor6D__6 and l__Motor6D__6.Parent then
					l__Motor6D__6.C0 = CFrame.Angles(0, 0, math.rad(v7.Value));
				end;
			end);
			game:GetService("Debris"):AddItem(v5, 3);
			v5.BodyVelocity.Velocity = v5.CFrame.lookVector * 300;
			local u5 = {};
			local u6 = false;
			local u7 = nil;
			local u8 = false;
			u7 = v5.Touched:Connect(function(p5)
				if p5 and p5:IsDescendantOf(p2) then
					return;
				end;
				if p5 and p5.Name == v5.Name then
					return;
				end;
				local v8 = p5.Parent:FindFirstChild("Humanoid") or p5.Parent.Parent:FindFirstChild("Humanoid");
				if v8 and not u5[v8.Parent.Name] and not u6 and not v8.Parent:FindFirstChild("SpellParry") then
					u7:disconnect();
					v5.Anchored = true;
					v5.CFrame = v8.Parent.HumanoidRootPart.CFrame;
					l__TweenService__2:Create(v5, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Size = Vector3.new(6, 6, 6), 
						Transparency = 1
					}):Play();
					if not v8.Parent:FindFirstChild("SpellBlocking") then
						v5.Hit:Play();
					end;
					u8 = true;
					u5[v8.Parent.Name] = true;
					l__TagHumanoid__3:Fire(p2, v8.Parent, {
						mana = true, 
						manablockbreak = true, 
						curse = true, 
						undead = true,
						move = "Inferi"
					});
					game:GetService("Debris"):AddItem(v5, 0.4);
				end;
			end);
			local u9 = nil;
			u9 = v5.TrailP.Touched:Connect(function(p6)
				if p6.Anchored and p6.CanCollide and not u8 then
					u9:disconnect();
					u6 = true;
					v5.Anchored = true;
					for v9, v10 in pairs(workspace.Live:GetChildren()) do
						if v10 ~= p2 then
							if (v10.HumanoidRootPart.Position - v5.Position).Magnitude < 0 then
								v5.CFrame = v10.HumanoidRootPart.CFrame;
								l__TweenService__2:Create(v5, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
									Size = Vector3.new(6, 6, 6), 
									Transparency = 1
								}):Play();
								if not v10:FindFirstChild("SpellBlocking") then
									v5.Hit:Play();
								end;
								l__TagHumanoid__3:Fire(p2, v10, {
									mana = true, 
									curse = true, 
									manablockbreak = true, 
									undead = true,
									move = "Inferi"
								});
								game:GetService("Debris"):AddItem(v5, 0.4);
							else
								l__TweenService__2:Create(v5, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
									Size = Vector3.new(8, 8, 8), 
									Transparency = 1
								}):Play();
								v5.WallHit:Play();
								game:GetService("Debris"):AddItem(v5, 0.4);
							end;
						end;
					end;
				end;
			end);
		else
			local v11 = l__Undead__1.BackfireBrick:Clone();
			l__TagHumanoid__3:Fire(p2, p2, {
				mana = true, 
				manablockbreak = true, 
				curse = true, 
				curseeffect = true, 
				damage = 5, 
				dam = 5, 
				manaknockupself = true,
				move = "Inferi"
			});
			v11.CFrame = p2.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(90), math.rad(-90));
			v11.Parent = workspace.Thrown;
			game:GetService("Debris"):AddItem(v11, 1);
			p2.HumanoidRootPart.Backfire:Play();
			l__TweenService__2:Create(v11, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Size = Vector3.new(10, 4.5, 10), 
				Transparency = 1
			}):Play();
		end;
	end)
end;
return v1;
