

local v1 = {};
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid;
local l__Parent__1 = script.Parent.Parent;

local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge", "Stun", "ReturnStun", "Action", "Blocking", "SpellBlocking", "ActiveCast", "Immortal"},
		presentTagBlocks = {"Unconscious", "Knocked"},
	})
end
local v3 = tick();
local l__TweenService__4 = game:GetService("TweenService");
local u2 = true;
local u3 = require(game.ServerScriptService.Modules.HitDetection);
function v1.Active(p1, p2, p3, p4)
	if ActionCheck() then
		return;
	end;
	if game.CollectionService:HasTag(p1, "Knocked") then
		return;
	end;
	if p1.Cooldowns:FindFirstChild("True Vision") then
		return
	end
	local Humanoid = p1.Humanoid
	local playerdata = game.ServerStorage:FindFirstChild("PlayerData"):FindFirstChild(p1.Name)
	if playerdata.Skills.Value:find("TheCursedFlame") then
		local CD = Instance.new("NumberValue")
		CD.Name = "True Vision"
		CD.Value = 20
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 20)
		local v5 = p1.Humanoid:LoadAnimation(script.Parent.AnimationL);
		v5:Play();
		local v6 = Instance.new("Accessory");
		v6.Name = "HeavyAttack";
		v6.Parent = p1;
		game:GetService("Debris"):AddItem(v6, 1);
		u2 = false;
		local v7 = nil;
		if not p4:FindFirstChild("LethalTrail") then
			v7 = script.Parent.LethalTrail:Clone();
			v7.Attachment0 = p4:WaitForChild("Attachment1");
			v7.Attachment1 = p4:WaitForChild("Attachment2");
			v7.Parent = p4;
		elseif p4:FindFirstChild("LethalTrail") then
			v7 = p4:FindFirstChild("LethalTrail");
		end;
		v5:GetMarkerReachedSignal("start"):Connect(function()
			local sigilbuff = p1:FindFirstChild("SigilBuff")
			if not sigilbuff or sigilbuff.Value ~= "CursedFlame" then
				local v10 = Instance.new("StringValue")
				v10.Name = "SigilBuff"
				v10.Value = "CursedFlame"
				v10.Parent = p1
				game:GetService("Debris"):AddItem(v10, 30)
				local v11 = Instance.new("NumberValue")
				v11.Name = "ColdResist"
				v11.Value = 1
				v11.Parent = p1
				game:GetService("Debris"):AddItem(v11, 30)

				local primarywep = game.ServerStorage.PlayerData[p3.Name].PrimaryWeapon.Value
				local att = nil
				local att2 = nil
				for i,v in pairs(game.ServerStorage.SpellEffects.sigilfire.CursedFlameCharge:GetChildren()) do
					local v14 = v:Clone()
					v14.Parent = p4
					
					if primarywep == "SealedSword" then
						if v14.Name == "Attachment" then
							v14.Position = Vector3.new(-0.007, -0.019, 1.226)
							v14.Orientation = Vector3.new(0, 91.423, -90)
						elseif v14.Name == "A2" then
							v14.Position = Vector3.new(-0.008, 0.003, 1.18)
							v14.Orientation = Vector3.new(-90, 91.423, 0)
							att = v14
						elseif v14.Name == "A3" then
							v14.Position = Vector3.new(-0.112, 0.016, -3.02)
							v14.Orientation = Vector3.new(-90, 91.423, 0)
							att2 = v14
						end
					elseif primarywep == "WraithSword" then
						if v14.Name == "Attachment" then
							v14.Position = Vector3.new(1.204, -0.019, 0.002)
							v14.Orientation = Vector3.new(-0, 179.766, -90)
						elseif v14.Name == "A2" then
							v14.Position = Vector3.new(1.158, 0.003, 0.002)
							v14.Orientation = Vector3.new(-90, 179.766, 0)
							print('found')
							att = v14
						elseif v14.Name == "A3" then
							v14.Position = Vector3.new(-3.779, 0.016, -0.018)
							v14.Orientation = Vector3.new(-90, 179.766, 0)
							att2 = v14
						end
					else
						if v14.Name == "A2" then
							att = v14
						elseif v14.Name == "A3" then
							att2 = v14
						end
					end

					v14.Name = "SigilPtcl"
					game.Debris:AddItem(v14, 30)
				end

				for i,v in pairs(att:GetChildren()) do
					v.Attachment1 = att2
				end

				local v15 = script.Parent:FindFirstChild("FireLoop"):Clone()
				v15.Name = "SigilSound"
				v15.Parent = p4
				v15:Play()
				game.Debris:AddItem(v15, 30)

				if not p4:FindFirstChild("FireHit") then
					script.Parent:FindFirstChild("FireHit"):Clone().Parent = p4
				end

				local v16 = script.Parent:FindFirstChild("Light"):Clone()
				v16.Name = "SigilLight"
				v16.Parent = p4
				game.Debris:AddItem(v16, 30)

				p1.HumanoidRootPart.Boom:Play()
				
				v5:AdjustSpeed(0)
				
				task.wait(0.3)
				
				v5:AdjustSpeed(1)
			end
		end)

		v5:GetMarkerReachedSignal("slash"):Connect(function()
			p1.HumanoidRootPart.LordSlash:Play();
			
			local Attach = game.ServerStorage.Assets.CursedFlameSlash.Attachment:Clone()
			Attach.Parent = p1.HumanoidRootPart
			for i,v in pairs(Attach:GetChildren()) do
				v:Emit(v:GetAttribute("EmitCount"))
			end
			
			game.Debris:AddItem(Attach, 1)
		end)
		
		v5.KeyframeReached:Connect(function(p5)
			if p5 == "ee" then
				v7.Enabled = false;
				u3.magnitudeCheck(p1, p1.HumanoidRootPart.Position, 8.5, {
					physical = true, 
					sword = true, 
					knockback = true, 
					blockbreak = true,
					cursedflame = true,
					damage = 20, 
					slash = true,
					move = "True Vision"
				}, true);
			end;
		end);
		task.wait(20);
		u2 = true;
	elseif playerdata.Skills.Value:find("TheRunemaster") and playerdata.Runes.Value >= 2 then
		local CD = Instance.new("NumberValue")
		CD.Name = "True Vision"
		CD.Value = 2
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 2)
		if playerdata.Lives.Value <= 0 then
			return
		end
		u2 = false
		playerdata.Runes.Value = playerdata.Runes.Value - 2
		local Scream = Humanoid:LoadAnimation(p3.SCREAM)
		Scream:Play()
		Scream:AdjustSpeed(2)
		
		p1.HumanoidRootPart.CrazedScream:Play()
		Humanoid:LoadAnimation(p3.CrazedIdle):Play()
		
		for i = 1,2 do
			task.spawn(function()
				local part = Instance.new("Part", p1)
				part.Name = "RuneChargeEffect"
				part.Size = Vector3.new(1,1,1)
				part.Material = Enum.Material.Neon
				part.Anchored = true
				part.CanCollide = false
				part.Transparency = 0
				part.CFrame = p1.HumanoidRootPart.CFrame
				local goal = {}
				goal.Size = Vector3.new(0,0,0)
				goal.Transparency = 1
				goal.CFrame = p1.HumanoidRootPart.CFrame + p1.HumanoidRootPart.CFrame.rightVector*math.random(5, 10)
				local tween = game:GetService("TweenService"):Create(part, TweenInfo.new(0.7), goal)
				tween:Play()
				game.Debris:AddItem(part, 1)
			end)
		end
		
		local v37 = Instance.new("NumberValue")
		v37.Name = "AttackSpeedBoost"
		v37.Value = 1.1
		v37.Parent = p1.Boosts
		game:GetService("Debris"):AddItem(v37, 60)
		
		local v35 = Instance.new("NumberValue")
		v35.Name = "SpeedBoost"
		v35.Value = 2
		v35.Parent = p1.Boosts
		game:GetService("Debris"):AddItem(v35, 60)
		
		local v30 = Instance.new("NumberValue")
		v30.Name = "DamageDivisor"
		v30.Value = 0.8
		v30.Parent = p1.Boosts
		game:GetService("Debris"):AddItem(v30, 60)
		
		local v28 = Instance.new("NumberValue")
		v28.Name = "MeleeDamageMultiplier"
		v28.Value = 1.1
		v28.Parent = p1.Boosts
		game:GetService("Debris"):AddItem(v28, 60)
		
		task.wait(1)
		
		u2 = true
	elseif playerdata.Skills.Value:find("TheCursedSwordsman") then
		if p1.Insanity.Value < 2 then return end
		local CD = Instance.new("NumberValue")
		CD.Name = "True Vision"
		CD.Value = 30
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 30)
		u2 = false
		local attacking = true
		local HyperArmor = false
		
		local InsanityMult = 1
		local Constant = 0.9425
		
		if p1.Insanity.Value == 100 then
			HyperArmor = true
		end
		
		local negative = Instance.new("NumberValue")
		negative.Name = "SpeedBoost"
		negative.Value = -100
		negative.Parent = p1.Boosts
		
		local nodash = Instance.new("BoolValue")
		nodash.Name = "NoDash"
		nodash.Parent = p1
		
		local Scream = Humanoid:LoadAnimation(p3.SCREAM)
		Scream:Play()
		Scream:AdjustSpeed(1.25)

		p1.HumanoidRootPart.CrazedScream:Play()
		
		Scream.Stopped:Wait()
		
		local bv = Instance.new("BodyVelocity")
		bv.Velocity = p1.HumanoidRootPart.CFrame.LookVector * 20
		bv.MaxForce = Vector3.new(500000,0,500000)
		bv.Parent = p1.HumanoidRootPart
		game:GetService("CollectionService"):AddTag(bv, "AllowedBM")
		
		local great = Instance.new("BoolValue")
		great.Name = "TrueVisionEnabled"
		great.Parent = p1
		
		local Active = Instance.new("Folder")
		Active.Name = "Active"
		Active.Parent = p1
		Instance.new("Folder", Active).Name = "NoDelete"
		
		local con = game:GetService("RunService").Heartbeat:Connect(function()
			task.wait(0.1)
			local facingdirection = p1.HumanoidRootPart.CFrame.LookVector
			bv.Velocity = p1.HumanoidRootPart.CFrame.LookVector * 20
			for _,live in pairs(workspace.Live:GetChildren()) do
				if live:FindFirstChild("Torso") and live:FindFirstChild("HumanoidRootPart") and live ~= p1 then
					if (live.HumanoidRootPart.Position - p1.HumanoidRootPart.Position).Magnitude <= 3 then
						bv.Velocity = p1.HumanoidRootPart.CFrame.LookVector * 4
						break
					end
				end
			end
		end)
		
		local Combo = 1
		
		while attacking and p1.Insanity.Value > 1 do
			local stuncheck = p1.ChildAdded:Connect(function(child)
				if (child.Name == "Stun" and HyperArmor == false) or child.Name == "Knocked" or child.Name == "Immortal" then
					attacking = false
				end
			end)
			
			if Combo == 5 then
				Combo = 1
			end
			
			local CombinedMult = InsanityMult * Constant
			
			local anim = p1.Humanoid:LoadAnimation(p3["Wraith" .. Combo])
			anim:Play()
			anim:AdjustSpeed(InsanityMult * Constant)
			
			anim.KeyframeReached:Connect(function(p5)
				if p5 == "slash" then
					if p4 and p4:FindFirstChild("TestTrail") then
						p4.TestTrail.Color = ColorSequence.new(Color3.new(1, 1, 1))
						p4.TestTrail.Enabled = true
					end
					p1.HumanoidRootPart.LordSlash:Play()
				end
				if p5 == "lastframe" and p4 and p4:FindFirstChild("TestTrail") then
					p4.TestTrail.Enabled = false
				end
			end)
			
			task.wait(0.375 / (CombinedMult * 1.5))
			Combo += 1
			
			local info = {
				physical = true,
				damage = p4.Stats.Damage.Value,
				sword = true,
				slash = true,
				currentprop = p4,
				blade = true,
				blockallsides = true
			}
			
			u3.magnitudeCheck(p1, p1.HumanoidRootPart.Position, p4.Stats.Length.Value, info, true)
			
			task.wait(0.8 / (CombinedMult * 1.5))
			InsanityMult += 0.15
			p1.Insanity.Value -= 1.5 * InsanityMult
		end
		
		Active:Destroy()
		
		con:Disconnect()
		attacking = false
		great:Destroy()
		bv:Destroy()
		negative:Destroy()
		nodash:Destroy()
		
		task.wait(30)
		u2 = true
	end
end;
return v1;
