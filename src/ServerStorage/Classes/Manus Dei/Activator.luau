

local v1 = {};
function sub(...)
	coroutine.wrap(...)();
end;
v1.upperbound = 95;
v1.lowerbound = 90;
v1.signs = 10;
v1.cost = 25;
local v2 = {
	upperbound = 60, 
	lowerbound = 50, 
	signs = 0, 
	cost = 20
};

local aisarcolor = Color3.fromRGB(148, 17, 255)
local aisardamage = 45

local u1 = false;
local l__TweenService__2 = game:GetService("TweenService");
local TweenService = game:GetService("TweenService")
local u3 = require(game.ServerScriptService.Modules.HitDetection);
local u4 = require(game.ServerScriptService.Modules.EffectModule);
local l__FireWhip__5 = game.ServerStorage.SpellEffects.FireWhip;
local l__TagHumanoid__6 = game.ServerStorage.Requests.TagHumanoid;
function v1.Activate(p1, p2, p3, p4)
	if game.CollectionService:HasTag(p2, "Casting") or p2:FindFirstChild("ActiveCast") then
		return;
	end;
	if u1 == true then
		return;
	end;
	u1 = true;
	local l__Mana__3 = p2.Mana;
	local v4 = game.Players:GetPlayerFromCharacter(p2);
	local l__Value__5 = v4:FindFirstChildOfClass("Backpack").ManaColor
	local u7 = _G.MouseData(v4);
	local playerdata = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	local ascended = false
	local cursed = false
	if playerdata.Ascended.Value == true and playerdata.Race.Value == "Azael" then
		ascended = true
	end
	if playerdata.Skills.Value:find("TheCursedFlame") then
		cursed = true
	end
	task.spawn(function()
		if p3 == 0 then
			sub(function()
				if (u7.Hit.p - p2.Torso.Position).Magnitude >= 600 then
					return;
				end;
				p2.HumanoidRootPart.PerfectCast:Play();
				local v6 = game.ServerStorage.Assets.Meteor:Clone();
				if ascended == true then
					v6 = game.ServerStorage.Assets.AscendedMeteor:Clone()
				end
				if cursed == true then
					v6 = game.ServerStorage.Assets.CursedMeteor:Clone()
				end
				v6.CFrame = CFrame.new(u7.Hit.p) * CFrame.new(0, 120, 0);
				v6.CFrame = CFrame.new(v6.Position, u7.Hit.p);
				v6.Parent = workspace.Thrown;
				task.delay(10.25, v6.Destroy, v6)
				v6.Firesound:Play();
				l__TweenService__2:Create(v6, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Size = Vector3.new(7.5, 7.5, 7.5), 
					CFrame = v6.CFrame * CFrame.Angles(math.rad(270), math.rad(180), math.rad(180))
				}):Play();
				sub(function()
					wait(2);
					l__TweenService__2:Create(v6, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						CFrame = CFrame.new(u7.Hit.p)
					}):Play();
				end);
				sub(function()
					wait(3.5);
					if v6:IsDescendantOf(workspace)then
						v6.Anchored = true;
						v6.Firesound2:Play();
						v6.Explosion:Emit(100);
						v6.Attachment:Destroy();
						v6.IllusionArm:Destroy();
						v6.IllusionArm2:Destroy();
						v6.IllusionArm3:Destroy();
						l__TweenService__2:Create(v6, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
							Size = Vector3.new(12, 12, 12), 
							Transparency = 1
						}):Play();
						l__TweenService__2:Create(v6.PointLight, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
							Range = 15
						}):Play();
						local v7 = 50;
						if game.ServerStorage.PlayerData:FindFirstChild(p2.Name) and (game.ServerStorage.PlayerData[p2.Name].Race.Value == "Azael" or game.ServerStorage.PlayerData[p2.Name].Race.Value == "Kasparan") then
							v7 *= 1.25;
						end;
						u3.magnitudeCheck(p2, v6.Position, 40, {
							mana = true, 
							damage = v7, 
							manaknockupself = true, 
							curse = true, 
							burn = true,
							knockback = true,
							ignoreragdoll = true,
							ascendedburn = ascended,
							cursedflame = cursed,
							move = "Manus Dei"
						}, false, true);
						local Explosion = game.ServerStorage.Assets.ExplosionManus:Clone()
						if ascended == true then
							Explosion = game.ServerStorage.Assets.AscendedExplosionManus:Clone()
						end
						if cursed == true then
							Explosion = game.ServerStorage.Assets.CursedExplosionManus:Clone()
						end
						game.Debris:AddItem(Explosion, 3)

						local pos = v6.Position

						local Break


						Explosion:PivotTo(CFrame.new(pos, Vector3.new(0,0,0)))		
						Explosion.Parent = workspace.Thrown
						-- Explosion.Ball.Attachment.ParticleEmitter:Emit(5)

						local Sound = Instance.new('Sound')
						Sound.SoundId = 'rbxassetid://262562442'
						Sound.Volume = 0.65
						Sound.Parent = Explosion.Ball
						Sound:Play()



						local TI1 = TweenInfo.new(0.33, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
						local TI2 = TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

						TweenService:Create(Explosion.PrimaryPart.Mesh, TI1, { Scale = Vector3.new(1, 1, 1) }):Play()
						TweenService:Create(Explosion.Ring.Mesh, TI1, { Scale = Explosion.Ring.Mesh.Scale * 16 }):Play()

						TweenService:Create(Explosion.PrimaryPart, TI2, { Transparency = 1 }):Play()
						TweenService:Create(Explosion.Ring, TI2, { Transparency = 1 }):Play()
						sub(function()
							wait(0.45);
							l__TweenService__2:Create(v6.PointLight, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
								Range = 0
							}):Play();
						end);
						game:GetService("Debris"):AddItem(v6, 2);
					end;
				end);
			end);
		elseif p3 ~= 0 then
			local v8 = l__FireWhip__5.BackfireBrick:Clone();
			if ascended == true then
				v8 = l__FireWhip__5.BackfireBrickAscended:Clone()
			end
			if cursed == true then
				v8 = l__FireWhip__5.BackfireBrickCursed:Clone()
			end
			v8.CFrame = p2.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(90), math.rad(-90));
			v8.Parent = workspace.Thrown;
			v8.ParticleEmitter:Emit(30);
			v8.Hit:Play();
			game:GetService("Debris"):AddItem(v8, 1.5);
			l__TagHumanoid__6:Fire(p2, p2, {
				mana = true, 
				manaknockupself = true, 
				burn = true, 
				curse = true, 
				damage = 50,
				move = "Manus Dei",
				ascendedburn = ascended,
				cursedflame = cursed
			});
			p2.HumanoidRootPart.Backfire:Play();
		end;
		wait(3);
		u1 = false;
	end)
end;
function v1.DeactivateS(p5, p6, p7)
	local v9 = Instance.new("Accessory");
	v9.Name = "EndCast";
	v9.Parent = p6;
	game:GetService("Debris"):AddItem(v9, 2);
end;
local u8 = false;
function v2.Activate(p8, p9, p10, p11, p12)
	if game.CollectionService:HasTag(p9, "Casting") or p9:FindFirstChild("ActiveCast") then
		return;
	end;
	if not p12[script.Parent.Name] then
		return;
	end;
	if u8 == true then
		return;
	end;
	u8 = true;
	local l__Mana__10 = p9.Mana;
	local v11 = game.Players:GetPlayerFromCharacter(p9);
	local l__Value__12 = v11:FindFirstChildOfClass("Backpack").ManaColor
	local u9 = _G.MouseData(v11);
	local playerdata = game.ServerStorage.PlayerData:FindFirstChild(v11.Name)
	local ascended = false
	local cursed = false
	if playerdata.Ascended.Value == true and playerdata.Race.Value == "Azael" then
		ascended = true
	end
	if playerdata.Skills.Value:find("TheCursedFlame") then
		cursed = true
	end
	task.spawn(function()
		if p10 == 0 then
			if not u9 or (u9.Hit.p - p9.Torso.Position).Magnitude >= 600 then
				u8 = false;
				return;
			end;
			sub(function()
				p9.HumanoidRootPart.PerfectCast:Play();
				p9.Humanoid:LoadAnimation(script.Snap2):Play();
				wait(0.2);
				local v13 = game.ReplicatedStorage.Assets.HandHoldFire:Clone();
				v13.IllusionArm.Enabled = false;
				v13.Parent = game.Workspace.Thrown;
				v13.Snap:Play();
				v13.IllusionSnap:Emit(100);
				local v14 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
				if not p11 then
					v14 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180));
				end;
				local u10 = Instance.new("Weld");
				local u11 = p9["Right Arm"];
				sub(function()
					u10.Name = "Weld";
					u10.Part0 = u11;
					u10.Part1 = v13;
					u10.Parent = v13;
					u10.C1 = v14;
					wait(1);
					v13:Destroy();
				end);
				local v15 = 1 - 1;

				local howmuch = 5

				for i = 1, howmuch do
					wait(0.25);
					local u12 = v15;
					sub(function()
						local v16 = game.ServerStorage.Assets.Meteor:Clone();
						if ascended == true then
							v16 = game.ServerStorage.Assets.AscendedMeteor:Clone()
						end
						if cursed == true then
							v16 = game.ServerStorage.Assets.CursedMeteor:Clone()
						end
						v16.CFrame = CFrame.new(u9.Hit.p) * CFrame.new(0, 120, math.random(-6, 6) * u12);
						v16.CFrame = CFrame.new(v16.Position, u9.Hit.p);
						v16.Parent = game.Workspace.Thrown;

						v16.Firesound:Play();
						l__TweenService__2:Create(v16, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
							Size = Vector3.new(7.5, 7.5, 7.5), 
							CFrame = v16.CFrame * CFrame.Angles(math.rad(270), math.rad(180), math.rad(180))
						}):Play();
						sub(function()
							wait(2);
							l__TweenService__2:Create(v16, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
								CFrame = CFrame.new(u9.Hit.p) * CFrame.new(math.random(-40, 40), 0, math.random(-40, 40))
							}):Play();
						end);
						sub(function()
							wait(3.5);
							if v16 ~= nil then
								v16.Anchored = true;
								v16.Firesound2:Play();
								v16.Explosion:Emit(100);
								v16.Attachment:Destroy();
								v16.IllusionArm:Destroy();
								v16.IllusionArm2:Destroy();
								v16.IllusionArm3:Destroy();
								l__TweenService__2:Create(v16, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
									Size = Vector3.new(12, 12, 12), 
									Transparency = 1
								}):Play();
								l__TweenService__2:Create(v16.PointLight, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
									Range = 15
								}):Play();
								local v17 = 5;

								if game.ServerStorage.PlayerData:FindFirstChild(p9.Name) and (game.ServerStorage.PlayerData[p9.Name].Race.Value == "Azael" or game.ServerStorage.PlayerData[p9.Name].Race.Value == "Kasparan") then
									v17 = v17 * 1.25;
								end;


								u3.magnitudeCheck(p9, v16.Position, 40, {
									mana = true, 
									damage = v17, 
									manaknockupself = true, 
									curse = true, 
									burn = true,
									knockback = true,
									ignoreragdoll = true,
									ascendedburn = ascended,
									cursedflame = cursed,
									move = "Manus Dei"
								}, false, true);
								local Explosion = game.ServerStorage.Assets.ExplosionManus:Clone() 
								if ascended == true then
									Explosion = game.ServerStorage.Assets.AscendedExplosionManus:Clone()
								end
								if cursed == true then
									Explosion = game.ServerStorage.Assets.CursedExplosionManus:Clone()
								end

								game.Debris:AddItem(Explosion, 3)

								local pos = v16.Position

								local Break


								Explosion:SetPrimaryPartCFrame(CFrame.new(pos, Vector3.new(0,0,0)))		
								Explosion.Parent = workspace.Thrown



								-- Explosion.Ball.Attachment.ParticleEmitter:Emit(5)

								local Sound = Instance.new('Sound', Explosion.Ball)
								Sound.SoundId = 'rbxassetid://262562442'
								Sound.Volume = 0.65
								Sound:Play()



								local TI1 = TweenInfo.new(0.33, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
								local TI2 = TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

								TweenService:Create(Explosion.PrimaryPart.Mesh, TI1, { Scale = Vector3.new(1, 1, 1) }):Play()
								TweenService:Create(Explosion.Ring.Mesh, TI1, { Scale = Explosion.Ring.Mesh.Scale * 16 }):Play()

								TweenService:Create(Explosion.PrimaryPart, TI2, { Transparency = 1 }):Play()
								TweenService:Create(Explosion.Ring, TI2, { Transparency = 1 }):Play()
								sub(function()
									wait(0.45);
									l__TweenService__2:Create(v16.PointLight, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
										Range = 0
									}):Play();
								end);
								game:GetService("Debris"):AddItem(v16, 10);
							end;
						end);
					end);
					if 0 <= 1 then
						if not (u12 < 4) then
							break;
						end;
					elseif not (u12 > 4) then
						break;
					end;
					u12 = u12 + 1;			
				end;
			end);
		elseif p10 ~= 0 then
			local v18 = l__FireWhip__5.BackfireBrick:Clone();
			if ascended == true then
				v18 = l__FireWhip__5.BackfireBrickAscended:Clone()
			end
			if cursed == true then
				v18 = l__FireWhip__5.BackfireBrickCursed:Clone()
			end
			v18.CFrame = p9.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(90), math.rad(-90));
			v18.Parent = game.Workspace.Thrown;
			v18.ParticleEmitter:Emit(30);
			v18.Hit:Play();
			game:GetService("Debris"):AddItem(v18, 1.5);
			l__TagHumanoid__6:Fire(p9, p9, {
				mana = true, 
				manaknockupself = true, 
				burn = true, 
				curse = true, 
				damage = 50,
				ascendedburn = ascended,
				cursedflame = cursed,
				move = "Manus Dei"
			});
			p9.HumanoidRootPart.Backfire:Play();
		end;
		task.wait(25)
		u8 = false;
	end)
end;
v1.alternate = v2;
return v1;
