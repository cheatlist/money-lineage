local v1 = {};
local v2 = require(game.ServerScriptService.Modules.EffectModule);
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid;
function ActionCheck(Parent)
	if Parent:FindFirstChild("EquipWarmup") then
		return true
	end
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("NoDam") then
		return true
	end
	if Parent:FindFirstChild("ReturnStun") then
		return true
	end
	if Parent:FindFirstChild("Action") then
		return true
	end
	if Parent:FindFirstChild("Blocking") then
		return true
	end
	if Parent:FindFirstChild("SpellBlocking") then
		return true
	end
	if Parent:FindFirstChild("ActiveCast") then
		return true
	end
	if Parent:FindFirstChild("Unconscious") then
		return true
	end
	if Parent:FindFirstChild("Knocked") then
		return true
	end
	if Parent.Humanoid.Health<1 then
		return true
	end
	if Parent:FindFirstChild("Immortal") then
	else
		return
	end
	return true
end
v1.upperbound = 85;
v1.lowerbound = 75;
v1.signs = 5;
v1.cost = 40;
local l__VoidPull__1 = game.ServerStorage.SpellEffects.VoidPull;
local l__TweenService__2 = game:GetService("TweenService");
local u3 = require(game.ServerScriptService.Modules.HitDetection);
local cd = false
function v1.Activate(p3, p4, p5, p6)
	if game.CollectionService:HasTag(p4, "Casting") then
		return;
	end;
	if cd then 
		return
	end
	cd = true
	local l__Mana__4 = p4.Mana;
	local v5 = game.Players:GetPlayerFromCharacter(p4);
	local u4 = _G.MouseData(v5);
	task.spawn(function()
		task.wait(.8)
		cd = false
	end)
	if not u4 then
		return;
	end;
	task.spawn(function()
		if p5 == 0 then
			if (u4.Hit.Position - p4.Torso.Position).Magnitude >= 60 then
				return;
			end;
			l__Mana__4.Value = math.max(l__Mana__4.Value - v1.cost, 0);
			p4.HumanoidRootPart.PerfectCast:Play();
			local l__p__7 = u4.Hit.Position;
			local v8 = l__VoidPull__1.VoidCenter:Clone();
			v8.Position = l__p__7;
			v8.Parent = workspace.Thrown;
			game:GetService'Debris':AddItem(v8, 2.75)
			v8.Attachment.Particle.Enabled = true;
			l__TweenService__2:Create(v8, TweenInfo.new(2.5, Enum.EasingStyle.Circular), {
				Size = Vector3.new(17, 17, 17)
			}):Play();
			local v9: number = tick();
			local v13: Sound = script.LoopSound:Clone();
			v13.Parent = v8;
			v13:Play();
			local v10 = {}
			while true do
				for _: number, NPC in ipairs(workspace.Live:GetChildren())do
					local HRP = NPC:FindFirstChild'HumanoidRootPart'
					if HRP and(HRP.Position - v8.Position).Magnitude < v8.Size.X then
						local Cache = v10[NPC]
						if not Cache then
							local NV: NumberValue = Instance.new'NumberValue'
							NV.Name = 'SpeedBoost'
							NV.Value = -1
							NV.Parent = NPC.Boosts
							v10[NPC] = NV
						else
							Cache.Value = math.max(Cache.Value - .15, -10)
						end
					end
				end
				wait();
				if tick() - v9 > 2.5 then
					break;
				end;
			end;
			for v16, v17 in pairs(v10) do
				l__TweenService__2:Create(v17, TweenInfo.new(1), {
					Value = 0
				}):Play();
				game.Debris:AddItem(v17, 1);
			end;
			v8.Attachment.Particle.Enabled = false;
			local l__Particle__18 = v8.Attachment.Particle;
			local v19 = l__Particle__18:Clone();
			l__Particle__18:Destroy();
			v19.Parent = v8.Attachment;
			v8.Attachment.Particle.Size = NumberSequence.new(10, 0);
			v8.Attachment.Particle.Lifetime = NumberRange.new(0.2);
			v8.Attachment.Particle:Emit(15);
			l__TweenService__2:Create(v8, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Size = Vector3.new(0, 0, 0)
			}):Play();
			wait(0.1);
			local v20 = game.ReplicatedStorage.Assets.Explod:Clone();
			v20.CFrame = CFrame.new(l__p__7) * CFrame.Angles(math.rad(math.random(0, 360)), math.rad(math.random(0, 360)), math.rad(math.random(0, 360)));
			v20.Color = v8.Color;
			v20.Parent = workspace.Thrown;
			l__TweenService__2:Create(v20, TweenInfo.new(math.random(60, 75) / 100, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				Size = v20.Size * 15, 
				Transparency = 1, 
				CFrame = v20.CFrame * CFrame.Angles(math.rad(180), 0, 0)
			}):Play();
			game.Debris:AddItem(v20, 0.75);
			local v21 = game.ReplicatedStorage.Assets.ThinRing:Clone();
			v21.CFrame = CFrame.new(l__p__7 + Vector3.new(0, 1, 0), l__p__7 + Vector3.new(0, 2, 0));
			v21.Color = v8.Color;
			v21.Parent = workspace.Thrown;
			l__TweenService__2:Create(v21, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				Size = v21.Size * 20, 
				Transparency = 1
			}):Play();
			game.Debris:AddItem(v21, 1);
			local v22 = script.Explode:Clone();
			v22.Parent = v8;
			v22:Play();
			game.Debris:AddItem(v22, 5);
			v13:Destroy();
			u3.magnitudeCheck(p4, v8.Position, 20, {
				mana = true, 
				curse = true, 
				damage = 15, 
				pullTo = v8.Position,
				move = "Trahere"
			}, false, true);
		elseif l__Mana__4.Value - v1.cost <= 0 then
			l__Mana__4.Value = 0;
		else
			l__Mana__4.Value -= v1.cost;
		end;
	end)
end;
local v2 = {
	upperbound = 60, 
	lowerbound = 50, 
	signs = 0, 
	cost = 100,
}
local HitDetect = require(game.ServerScriptService.Modules.HitDetection)
function v2.Activate(p8, p9, p10, p11, p12)
	if game.CollectionService:HasTag(p9, "Casting") then
		return
	end
	local hit = nil
	if not p12[script.Parent.Name] then
		return
	end
	if ActionCheck(p9) then
		return
	end
	local l__Mana__4 = p9.Mana;
	local v5 = game.Players:GetPlayerFromCharacter(p9);
	task.spawn(function()
		if p10 == 0 then
			l__Mana__4.Value = math.max(l__Mana__4.Value - v1.cost, 0);
			p9.HumanoidRootPart.PerfectCast:Play();
			p9.Humanoid:LoadAnimation(script.FimbulSnap):Play()
			local l__p__7 = p9.HumanoidRootPart.Position;
			local v8 = l__VoidPull__1.VoidCenter:Clone();
			v8.Position = l__p__7;
			v8.Parent = workspace.Thrown;
			game:GetService'Debris':AddItem(v8, 2.75)
			v8.Attachment.Particle.Enabled = true;
			l__TweenService__2:Create(v8, TweenInfo.new(2.5, Enum.EasingStyle.Circular), {
				Size = Vector3.new(17, 17, 17)
			}):Play();
			local v9: number = tick();
			local v13: Sound = script.LoopSound:Clone();
			v13.Parent = v8;
			v13:Play();
			local v10 = {}
			while true do
				for _: number, NPC in ipairs(workspace.Live:GetChildren())do
					local HRP = NPC:FindFirstChild'HumanoidRootPart'
					if HRP and(HRP.Position - v8.Position).Magnitude < v8.Size.X then
						local Cache = v10[NPC]
						if not Cache then
							local NV: NumberValue = Instance.new'NumberValue'
							NV.Name = 'SpeedBoost'
							NV.Value = -1
							NV.Parent = NPC.Boosts
							v10[NPC] = NV
						else
							Cache.Value = math.max(Cache.Value - .15, -10)
						end
					end
				end
				wait();
				if tick() - v9 > 0 then
					break;
				end;
			end;
			for v16, v17 in pairs(v10) do
				l__TweenService__2:Create(v17, TweenInfo.new(1), {
					Value = 0
				}):Play();
				game.Debris:AddItem(v17, 1);
			end;
			v8.Attachment.Particle.Enabled = false;
			local l__Particle__18 = v8.Attachment.Particle;
			local v19 = l__Particle__18:Clone();
			l__Particle__18:Destroy();
			v19.Parent = v8.Attachment;
			v8.Attachment.Particle.Size = NumberSequence.new(10, 0);
			v8.Attachment.Particle.Lifetime = NumberRange.new(0.2);
			v8.Attachment.Particle:Emit(15);
			l__TweenService__2:Create(v8, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Size = Vector3.new(0, 0, 0)
			}):Play();
			wait(0.1);
			local v20 = game.ReplicatedStorage.Assets.Explod:Clone();
			v20.CFrame = CFrame.new(l__p__7) * CFrame.Angles(math.rad(math.random(0, 360)), math.rad(math.random(0, 360)), math.rad(math.random(0, 360)));
			v20.Color = v8.Color;
			v20.Parent = workspace.Thrown;
			l__TweenService__2:Create(v20, TweenInfo.new(math.random(60, 75) / 100, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				Size = v20.Size * 15, 
				Transparency = 1, 
				CFrame = v20.CFrame * CFrame.Angles(math.rad(180), 0, 0)
			}):Play();
			game.Debris:AddItem(v20, 0.75);
			local v21 = game.ReplicatedStorage.Assets.ThinRing:Clone();
			v21.CFrame = CFrame.new(l__p__7 + Vector3.new(0, 1, 0), l__p__7 + Vector3.new(0, 2, 0));
			v21.Color = v8.Color;
			v21.Parent = workspace.Thrown;
			l__TweenService__2:Create(v21, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				Size = v21.Size * 20, 
				Transparency = 1
			}):Play();
			game.Debris:AddItem(v21, 1);
			local v22 = script.Explode:Clone();
			v22.Parent = v8;
			v22:Play();
			game.Debris:AddItem(v22, 5);
			v13:Destroy();
			u3.magnitudeCheck(p9, v8.Position, 22, {
				mana = true, 
				curse = true, 
				damage = 15, 
				pullTo = v8.Position,
				move = "Trahere"
			});
		elseif l__Mana__4.Value - v1.cost <= 0 then
			l__Mana__4.Value = 0;
		else
			l__Mana__4.Value -= v1.cost;
		end;
	end)
end;
v1.alternate = v2
return v1;
