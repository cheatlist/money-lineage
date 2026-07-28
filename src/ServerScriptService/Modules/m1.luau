local hitcheck = require(game.ServerScriptService.Modules.HitDetection)
local FindFirstChild,WaitForChild = game.FindFirstChild,game.WaitForChild
local create = function(name,deletetime,parent)
	if not parent then
		return
	end
	local i = Instance.new("Accessory")
	i.Name = name
	i.Parent = parent
	if deletetime then
		game.Debris:AddItem(i,deletetime)
	end
	return i
end
local StunCheck = function(c)
	if FindFirstChild(c,"NoDam")then
		return true
	end
	if FindFirstChild(c,"Stun")then
		return true
	end
	if FindFirstChild(c,"Action")then
		return true
	end
	if FindFirstChild(c,"NoWeapon")then
		return true
	end
	if FindFirstChild(c,"ActiveCast")then
		return true
	end
	if FindFirstChild(c,"LightAttack")then
		return true
	end
	if not FindFirstChild(c,"Humanoid")then
		return true
	end
	if c.Humanoid.Health == 0 then
		return true
	end
	if c.Humanoid.Sit then
		return true
	end
	if FindFirstChild(c,"Grabbed")then
		return true
	end
	if game.CollectionService:HasTag(c,"Casting")then
		return true
	end
	if game.CollectionService:HasTag(c,"BeingExecuted")or FindFirstChild(c,"Knocked")then
	else
		return
	end
	return true
end
return function(character,player,combatanims,data)
	if FindFirstChild(character,"Immortal")then
		return false
	end
	if StunCheck(character)then
		return false
	end
	if player then
		StunCheck(player)
	end
	local info = {
		physical = true,
		fist = true, 
		damage = 4,
		ism1 = true,
	}
	local humanoidrootpart = character.HumanoidRootPart
	local monk = false
	if character.Mana.Value>=5 then
		info.manastop = true
		info.mana = true
		info.manabreaker = true
		if player then
			if FindFirstChild(player.Backpack,"TrainedCombat")then
				if FindFirstChild(player.Backpack,"HolyFire")then
					if data.Weapon.Value == "None"then
						monk = true
					end
				end
			end
		end
	end
	local combo = character.Combo
	if character:FindFirstChild("MonasticStance") then
		if character.Mana.Value >= 5 and FindFirstChild(player.Backpack,"TrainedCombat") then
			local burn1 = game.ReplicatedStorage.Assets.BurningParticle2:clone()
			if data.Ascended.Value == true and data.Race.Value == "Azael" then
				burn1 = game.ReplicatedStorage.Assets.AscendedBurningParticle2:clone()
				info.ascendedburn = true
			end
			if data.Skills.Value:find("TheCursedFlame") then
				burn1 = game.ReplicatedStorage.Assets.CursedBurningParticle2:Clone()
				info.cursedflame = true
			end
			if combo.Value == 1 then
				burn1.Parent = character:WaitForChild("Right Arm")
				burn1.Enabled = true
			elseif combo.Value == 2 then
				burn1.Parent = character:WaitForChild("Right Leg")
				burn1.Enabled = true
			elseif combo.Value == 3 then
				burn1.Parent = character:WaitForChild("Left Arm")
				burn1.Enabled = true
			elseif combo.Value == 4 then
				burn1.Parent = character:WaitForChild("Right Leg")
				burn1.Enabled = true
			elseif combo.Value == 5 then
				burn1.Parent = character:WaitForChild("Left Arm")
				burn1.Enabled = true
			end
			
			game.Debris:AddItem(burn1, 3)
			
			task.spawn(function()
				task.wait(1)
				
				burn1.Enabled = false
			end)
			
			info.knockback = true
			info.specialrag = 0.45
			info.azaelcheck = true
			info.burn = true
			info.downbypass = true
			info.move = "Monastic Stance"
		elseif character.Mana.Value >= 5 and not FindFirstChild(player.Backpack,"TrainedCombat") then
			local burn1 = game.ReplicatedStorage.Assets.BurningParticle2:clone()
			if data.Ascended.Value == true and data.Race.Value == "Azael" then
				burn1 = game.ReplicatedStorage.Assets.AscendedBurningParticle2:clone()
				info.ascendedburn = true
			end
			if data.Skills.Value:find("TheCursedFlame") then
				burn1 = game.ReplicatedStorage.Assets.CursedBurningParticle2:Clone()
				info.cursedflame = true
			end
			if combo.Value == 1 then
				burn1.Parent = character:WaitForChild("Right Arm")
				burn1.Enabled = true
			elseif combo.Value == 2 then
				burn1.Parent = character:WaitForChild("Left Arm")
				burn1.Enabled = true
			elseif combo.Value == 3 then
				burn1.Parent = character:WaitForChild("Right Arm")
				burn1.Enabled = true
			elseif combo.Value == 4 then
				burn1.Parent = character:WaitForChild("Left Arm")
				burn1.Enabled = true
			elseif combo.Value == 5 then
				burn1.Parent = character:WaitForChild("Right Leg")
				burn1.Enabled = true
			end

			game.Debris:AddItem(burn1, 3)

			task.spawn(function()
				task.wait(1)

				burn1.Enabled = false
			end)

			info.knockback = true
			info.specialrag = 0.45
			info.azaelcheck = true
			info.burn = true
			info.downbypass = true
			info.move = "Monastic Stance"
		else
			info.damage = 5
			info.bell = true
			info.move = "Monastic Stance"
		end

	end
	

	combo = character.Combo
	local combotimer = character.ComboTimer
	if tick()-combotimer.Value > 1.5 then
		combo.Value = 1
	end
	combotimer.Value = tick()
	if FindFirstChild(character,"Grabbing")and combo.Value == 3 then
		combo.Value = 4
	end
	if FindFirstChild(character,"Grabbing")and combo.Value == 1 then
		combo.Value = 2
	end
	local attackspeed = 0.475
	if data and data:FindFirstChild("WorkoutCorePoints") then
		-- Core hypertrophy (up to 10, see WorkoutModule.hypertrophy) makes unarmed M1 faster -
		-- a direct divide here rather than routing through Boosts.AttackSpeedBoost, since that
		-- Boost is the "some of your moves" effect (only read by weapon Activators), not m1 itself.
		local corehypertrophy = math.floor(data.WorkoutCorePoints.Value / 3)
		attackspeed = attackspeed / (1 + corehypertrophy * 0.05)
	end
	create("NoJump",1,character)
	create("LightAttack",attackspeed,character)
	create("ManaPause",0.05,character)
	create("ChargeBlock",attackspeed,character)	
	if player then
		create("NoJump",1,character)
		create("LightAttack",attackspeed,character)
		
		create("ChargeBlock",attackspeed,character)	
	end
	local animationp = combatanims["Animation"..combo.Value]
	if player and FindFirstChild(player.Backpack,"TrainedCombat")then
		animationp = combatanims["MonkPunch"..combo.Value]
		info.damage = 7.5
	end
	if monk then
		if player.Backpack:FindFirstChild("ElectricPunch") then
			info.electric = true
			info.damage = 7
			info.manabreaker = true
			info.bypassfischdodge = true
			spawn(function()
				wait(0.15)
				if character:FindFirstChild("NoDam")then
					return
				end
				local part = nil
				if combo.Value == 1 then
					part = character["Right Arm"]
				elseif combo.Value == 2 then
					part = character["Right Leg"]
				elseif combo.Value == 3 then
					part = character["Left Arm"]
				elseif combo.Value == 4 then
					part = character["Right Leg"]
				elseif combo.Value == 5 then
					part = character["Left Arm"]
				end
				local l1 = game.ReplicatedStorage.Assets.Electric:Clone()
				l1.Parent = part
				l1.Enabled = true
				local l2 = game.ReplicatedStorage.Assets.ElectricLight:Clone()
				l2.Parent = part
				if data.Skills.Value:find("TheThunderstorm") then
					l1.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
					l2.Color = Color3.fromRGB(255, 255, 0)
				elseif data.Skills.Value:find("TheCalmbeforethestorm") then
					l1.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
					l2.Color = Color3.fromRGB(255, 255, 255)
				elseif data.Skills.Value:find("TheLightning") then
					l1.Color = ColorSequence.new(Color3.fromRGB(85, 0, 255))
					l2.Color = Color3.fromRGB(85, 0, 255)
				end
				game.Debris:AddItem(l2,0.2)
				wait(0.05)
				humanoidrootpart.LightningBurst:Play()
				wait(0.25)
				l1.Enabled = false
				game.Debris:AddItem(l1,0.2)
			end)
		end
		if combo.Value == 5 or (combo.Value == 3 and data.Injuries.Value:find("brokenarm")) or (combo.Value == 3 and data.Injuries.Value:find("armless")) then
			info.burn = true
			info.azaelcheck = true
			spawn(function()
				local fire = nil
				if monk then
					fire = humanoidrootpart.MonasticFire:Clone()
					fire.Parent = character["Left Arm"]
					fire.Enabled = true
					humanoidrootpart.MonasteryFire:Play()
					wait(0.5)
					if fire then
						fire.Enabled = false
						game.Debris:AddItem(fire,1)
						wait(0.5)
						humanoidrootpart.MonasteryFire:Stop()
					end
				end
			end)
		end
	end
	local fistdmgmp = FindFirstChild(character.Boosts,"FistDamageMP")
	if fistdmgmp then
		info.damage = info.damage*fistdmgmp.Value
	end
	local animation = character.Humanoid:LoadAnimation(animationp)
	animation:Play(0.1,1,1.5)
	wait(0.2)
	if character:FindFirstChild("Stun")then
		return false
	end
	humanoidrootpart.Swing:Play()
	combo.Value = combo.Value + 1
	if combo.Value >= 6 then
		local action = create("Action",0.75,character)
		Instance.new("Folder",action).Name = "NoDelete"
		info.knockback = true
		combo.Value = 1
	end
	if not FindFirstChild(character,"Stun")and not FindFirstChild(character,"NoDam")then
		wait(0.075)
		hitcheck.magnitudeCheck(character,humanoidrootpart.Position,8.5,info)
	else
		animation:Stop()
		return false
	end
	if info.knockback then
		wait(0.1)
	end
	return true
end