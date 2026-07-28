local module = {}

local tagHumanoid = game.ServerStorage.Requests.TagHumanoid
local dangerHandler = require(game.ServerScriptService.Modules.DangerHandler)
local HitDetect = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")

local WALK_RANGE = 15
local ATTACK_RANGE = 10
local NO_CLOSER = 25
local GROUPING_RANGE = 20
local AGGRO_DISTANCE = 100 
local SHRIEK_DISTANCE = 100 
local CHASE_DISTANCE = 500
local TORCH_RANGE = 1
local COLUBRAS = 9144458
local COLUBRAS_ALLIES = {
	["151239872"]=true
}

module.setup = function(char)

end

module.die = function(char)
	if (not char.MonsterInfo.Master.Value) and math.random(1,100)/100 <= char.Variables.Droprate.Value and not char:FindFirstChild("NoDrops") and not char:FindFirstChild("Summoned") then
		_G.DropBag("MonsterDrop", char.Variables.Drop.Value, char)
	end 
	
	if char:FindFirstChild'Torso'then
		local dustpart = game.ServerStorage.Assets.MonsterDeath:Clone()
		dustpart.CFrame = char.Torso.CFrame
		dustpart.DeadCast:Play()
		game:GetService("Debris"):AddItem(dustpart,3)
		dustpart.Parent = workspace.Thrown
		dustpart.DUST1:Emit(70)
		wait(.2)
		dustpart.DUST2:Emit(50)
		wait(.2)
		dustpart.DUST3:Emit(25)
		wait(.5)
	end

	char:Destroy()
end

module.colubrasKilled = function(char)
	local spelleffect = game.ServerStorage.SpellEffects.ColubrasRestrain

	local ray = Ray.new(char.HumanoidRootPart.Position,Vector3.new(0,50,0))
	local intersect,pos = workspace:FindPartOnRayWithIgnoreList(ray,{game.Workspace.Live,game.Workspace.Thrown,game.Workspace.MonsterSpawns})

	local portalPos = char.HumanoidRootPart.Position + Vector3.new(0,50,0)

	if intersect then portalPos = pos end

	local portal = spelleffect.Portal:Clone()
	portal.Position = portalPos
	portal.Particle.Enabled = true	
	portal.Parent = workspace.Thrown
	portal.Open:Play()

	local shadowParts = {}

	for _,part in ipairs(char:GetChildren())do
		if part:IsA("BasePart") and part.Transparency == 0 then
			local shadowP = Instance.new("Part")
			shadowP.Size = part.Size
			shadowP.Anchored = true
			shadowP.CanCollide = false
			shadowP.CFrame = part.CFrame
			shadowP.Material = Enum.Material.Neon
			shadowP.BrickColor = BrickColor.new("Really black")
			shadowP.Transparency = 0.5
			shadowP.Parent = game.Workspace.Thrown
			TweenService:Create(shadowP,TweenInfo.new(1,Enum.EasingStyle.Quad),{Position=shadowP.Position+Vector3.new(math.random(-5,5),2,math.random(-5,5))}):Play()
			table.insert(shadowParts,shadowP)
		end
	end
	char:Destroy()
	wait(1)
	local numSP = #shadowParts
	for i,part in next,shadowParts do
		TweenService:Create(part,TweenInfo.new(0.5,Enum.EasingStyle.Quart),{Position=portalPos}):Play()
		local sound = portal.GoesIn:Clone()
		sound.Parent = part
		sound:Play()

		game.Debris:AddItem(part,0.5)
		wait(0.5/numSP)
	end
	wait(0.5)
	portal.Particle.Enabled = false
	game.Debris:AddItem(portal,1)
end

module.isAnAlly = function(char,ochar,masterFolder)
	local hum = char.Humanoid
	local variables = char.Variables
	local monsterInfo = char.MonsterInfo
	local master = char.MonsterInfo.Master.Value

	if master == ochar then return true end
	
	if ochar:FindFirstChild("Grabbed") then return true end
	
	if ochar:FindFirstChild("MonsterInfo") or not game.Players:GetPlayerFromCharacter(ochar) then
		if not (master and ochar:FindFirstChild("MonsterInfo") and ochar.MonsterInfo.Master.Value ~= master) then
			return true
		end		
	else
		if master and variables.Command.Value == "NOHOUSE" then
			local cFolder = game.ServerStorage.PlayerData:FindFirstChild(ochar.Name)
			if cFolder and masterFolder then
				if masterFolder.LastName.Value ~= "" and masterFolder.LastName.Value == cFolder.LastName.Value then
					return true
				end
			end						
		end

		if master and game.Players:GetPlayerFromCharacter(master).UserId == COLUBRAS and COLUBRAS_ALLIES[tostring(game.Players:GetPlayerFromCharacter(ochar).UserId)] then
			return true
		end
	end

	return false
end

module.think = function(char,live,tracks)
	local hum = char:FindFirstChild("Humanoid")
	if not hum then
		return
	end
	local variables = char.Variables
	local monsterInfo = char.MonsterInfo
	local master = char.MonsterInfo.Master.Value
	local masterFolder = nil
	if master then
		masterFolder = game.ServerStorage.PlayerData:FindFirstChild(master.Name)
	end

	if char:FindFirstChild("Unconscious") or char:FindFirstChild("Knocked") then
		hum.PlatformStand = true
	else
		hum.PlatformStand = false
	end

	local torso = char:FindFirstChild("Torso")
	local bodyGyro = torso and torso:FindFirstChild("BodyGyro")

	if char:FindFirstChild("Action") or char:FindFirstChild("Unconscious") or char:FindFirstChild("Knocked") or char:FindFirstChild("Stun") or variables.Command.Value == "HALT" then
		if bodyGyro then
			bodyGyro.MaxTorque = Vector3.new()
		end
		--module.Walk(char,false,tracks)

		if variables.Command.Value == "HALT" then
			hum:Move(Vector3.new(0,0,0))
		end
		return
	end

	if variables.State.Value == "ROAMING" then
		if bodyGyro then
			bodyGyro.MaxTorque = Vector3.new()
		end
		module.Sprint(char,false,tracks)
		module.FindTarget(char,true,live,tracks)
		if variables.State.Value == "ROAMING" then
			monsterInfo.Aggrod.Value = false
			local timeSinceLastRoam = tick() - variables.LastRoam.Value
			if timeSinceLastRoam >= 5 + variables.RoamCD.Value then
				variables.LastRoam.Value = tick() 
				variables.RoamCD.Value = math.random(400,600)/100
				module.Walk(char,true,tracks)
				hum:Move(Vector3.new(math.random(-100,100),0,math.random(-100,100)))
			elseif timeSinceLastRoam >= 3 then
				module.Walk(char,false,tracks)
				hum:Move(Vector3.new(0,0,0))
			end
		end
	elseif variables.State.Value == "AGGROD" then
		local target = variables.Target.Value
		local lastHitBy = variables.LastHitBy.Value

		monsterInfo.Aggrod.Value = true
		monsterInfo.LastAggrod.Value = tick()
		game.ServerStorage.Requests.ResetMonsterExpiration:Invoke(char)

		if target and target.Parent == workspace.Live and target ~= char and target.Parent and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and not module.isAnAlly(char,target,masterFolder) then
			if bodyGyro then
				bodyGyro.MaxTorque = Vector3.new(0,8e10,0)
				bodyGyro.CFrame = CFrame.new(torso.Position,target.HumanoidRootPart.Position)
			end

			local distanceToTarget = (target.Torso.Position - char.Torso.Position).Magnitude
			if distanceToTarget < CHASE_DISTANCE then
				if lastHitBy and lastHitBy.Parent and lastHitBy ~= master and not module.isAnAlly(char,lastHitBy,masterFolder) and not (lastHitBy:FindFirstChild("MonsterInfo") and master and lastHitBy.MonsterInfo.Master.Value == master) then
					-- If hit by someone else, adjust targets if they are closer.
					variables.LastHitBy.Value = nil
					local distanceToLHB = (lastHitBy.Torso.Position - char.Torso.Position).Magnitude

					if distanceToLHB < distanceToTarget then
						variables.Target.Value = lastHitBy
						target = lastHitBy	
						distanceToTarget = distanceToLHB
					end
				end	

				for _,ochar in pairs(live) do
					if ochar ~= char and not (master and master == ochar) then
						local hrp = ochar:FindFirstChild'HumanoidRootPart'
						if hrp and not module.isAnAlly(char,ochar,masterFolder) then
							local dist = (char.HumanoidRootPart.Position - hrp.Position).Magnitude
							local ray = Ray.new(char.Head.Position,char.Head.Position-hrp.Position)
							local part,pos,norm = workspace:FindPartOnRayWithIgnoreList(ray,{workspace.Live,workspace.Thrown,workspace.MonsterSpawns})

							if not part and dist < distanceToTarget then
								variables.Target.Value = ochar
								target = ochar
							end
						end
					end
				end

				local rayOut = Ray.new(char.Torso.Position,char.Torso.CFrame.lookVector.unit*1)
				local obscuring = workspace:FindPartOnRayWithIgnoreList(rayOut,{workspace.Live,workspace.Thrown,workspace.MonsterSpawns})
				if obscuring then
					hum.Jump = true
				end

				if target:FindFirstChild("Unconscious") then
					if distanceToTarget < NO_CLOSER then
						module.Walk(char,false,tracks)
						module.Sprint(char,false,tracks)
						module.Eat(char,target,tracks)
						hum:Move(Vector3.new(0,0,0))
					else
						module.Walk(char,false,tracks)
						module.Sprint(char,true,tracks)

						if tick() - variables.LastMove.Value > 0.3 then
							variables.LastMove.Value = tick()
							local targDirection = (target.Torso.Position - char.Torso.Position)

							if hum:GetState() ~= Enum.HumanoidStateType.Swimming then	
								targDirection = targDirection * Vector3.new(1,0,1)
							end

							hum:Move(targDirection)
						end
					end
				else
					local hasFlame = (target:FindFirstChild("Torch") and target.Torch:FindFirstChild("Lit") and target.Torch:FindFirstChild("PercentLit") and target.Torch.Lit.Value and distanceToTarget < ((3 + TORCH_RANGE) * target.Torch.PercentLit.Value) and distanceToTarget > ((TORCH_RANGE - 3) * target.Torch.PercentLit.Value))
					hasFlame = hasFlame or (target:FindFirstChild("SigilBuff") and target.SigilBuff.Value == "Flame" and distanceToTarget < (TORCH_RANGE * 0.5) + 3 and distanceToTarget > (TORCH_RANGE * 0.5) - 3)
					if distanceToTarget < NO_CLOSER or hasFlame then
						module.Walk(char,false,tracks)
						module.Sprint(char,false,tracks)
						hum:Move(Vector3.new(0,0,0))
					else
						if distanceToTarget < WALK_RANGE then
							if char:FindFirstChild("Sprinting") then
								module.Sprint(char,false,tracks)
								module.Walk(char,true,tracks)
							end
						else
							module.Walk(char,false,tracks)
							module.Sprint(char,true,tracks)
						end

						if tick() - variables.LastMove.Value > 0.3 then
							variables.LastMove.Value = tick()
							local targDirection = (target.Torso.Position - char.Torso.Position)

							for _,ochar in next, live do
								if ochar ~= char and ochar:FindFirstChild("MonsterInfo") and ochar.MonsterInfo.MonsterType.Value == char.MonsterInfo.MonsterType.Value then
									local dist = (ochar.Torso.Position - char.Torso.Position).Magnitude
									if dist < GROUPING_RANGE then
										local awayVector = (char.Torso.Position - ochar.Torso.Position).unit * 2
										targDirection = targDirection + awayVector
									end
								elseif ochar ~= char and (ochar:FindFirstChild("Torch") or (ochar:FindFirstChild("SigilBuff") and ochar.SigilBuff.Value == "Flame")) then
									local dist = (ochar.Torso.Position - char.Torso.Position).Magnitude

									if ochar:FindFirstChild("Torch") and ochar.Torch:FindFirstChild("Lit") and ochar.Torch.Lit.Value and ochar.Torch:FindFirstChild("PercentLit") then
										local percentLit = ochar.Torch.PercentLit.Value
										if dist < (TORCH_RANGE) * percentLit then
											local awayVector = (char.Torso.Position - ochar.Torso.Position).unit * 30 * percentLit 
											targDirection = targDirection + awayVector
										end
									else
										if dist < (TORCH_RANGE * 0.5) then
											local awayVector = (char.Torso.Position - ochar.Torso.Position).unit * 30 * 0.5
											targDirection = targDirection + awayVector
										end
									end
								end
							end

							if hum:GetState() ~= Enum.HumanoidStateType.Swimming then	
								targDirection = targDirection * Vector3.new(1,0,1)
							end


							hum:Move(targDirection)
						end
					end
					
					if not char:FindFirstChild("SummonCD") then
						module.SummonZombie(char,live,tracks)
						local status = Instance.new("Folder")
						status.Name = "SummonCD"
						status.Parent = char
						game.Debris:AddItem(status,30)
					end

					if distanceToTarget < ATTACK_RANGE then
						module.BasicAttack(char,live,tracks)
					elseif distanceToTarget <= 40 then
						module.Fireball(char,live,tracks)
					end
				end
			else
				module.FindTarget(char,false,live,tracks)
			end
		else
			module.FindTarget(char,false,live,tracks)
		end
	end
end

module.FindTarget = function(char,shriek,live,tracks)
	local master = char.MonsterInfo.Master.Value
	local masterFolder = nil
	if master then
		masterFolder = game.ServerStorage.PlayerData:FindFirstChild(master.Name)
	end
	coroutine.wrap(function()
		local hum = char.Humanoid
		local variables = char.Variables

		local closest = nil
		local closestDistance = nil
		for _,enemy in next,live do
			if enemy ~= char and enemy:FindFirstChild("Torso") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
				if not module.isAnAlly(char,enemy,masterFolder) then
					if enemy:FindFirstChild("HumanoidRootPart") then
					local ray = Ray.new(char.Head.Position,char.Head.Position-enemy.HumanoidRootPart.Position)
					local part,pos,norm = game.Workspace:FindPartOnRayWithIgnoreList(ray,{game.Workspace.Live,game.Workspace.Thrown,game.Workspace.MonsterSpawns})
					local dist = (char.HumanoidRootPart.Position-enemy.HumanoidRootPart.Position).Magnitude
					if not part and dist < AGGRO_DISTANCE then
						if (not closest) or (closest and dist < closestDistance) then
							closest = enemy
							closestDistance = dist
						end
					end
				end
			end
		end
end
		if closest then
			local enemyDanger = dangerHandler:getEntity(closest)
			if enemyDanger then
				enemyDanger:createTag(char.Name,{lifespan=20})
			end

			variables.Target.Value = closest
			variables.State.Value = "AGGROD"

			if shriek and char:FindFirstChild("Torso") then
				local action = Instance.new("Folder")
				action.Name = "Action"
				action.Parent = char
				game.Debris:AddItem(action,1)

				tracks["Shriek"]:Play()

				wait(0.7)
				char.Torso.Shriek.PlaybackSpeed = math.random(125,160)/100
				char.Torso.Shriek:Play()

				for _,ochar in next,live do
					if ochar ~= char and ochar:FindFirstChild("MonsterInfo") and ochar.MonsterInfo:FindFirstChild("MonsterType") and ochar.MonsterInfo.MonsterType.Value == char.MonsterInfo.MonsterType.Value and not(ochar.MonsterInfo.Master.Value and ochar.MonsterInfo.Master.Value ~= master) then
						if ochar.Variables.State.Value == "ROAMING" and ochar:FindFirstChild("Torso") and ochar:FindFirstChild("Humanoid") and ochar.Humanoid.Health > 0 then
							local dist = (char.Torso.Position - ochar.Torso.Position).Magnitude
							if dist <= SHRIEK_DISTANCE then
								ochar.Variables.Target.Value = closest
								ochar.Variables.State.Value = "AGGROD"

								local action = Instance.new("Folder")
								action.Name = "Action"
								action.Parent = ochar
								game.Debris:AddItem(action,1)


								ochar.Humanoid:LoadAnimation(ochar.Animations.Shriek):Play()
								coroutine.wrap(function()				
									wait(0.7)
									ochar.Torso.Shriek.PlaybackSpeed = math.random(125,160)/100
									ochar.Torso.Shriek:Play()
								end)()
							end
						end
					end
				end
			end
		else
			variables.State.Value = "ROAMING"
			variables.Target.Value = nil
		end
	end)()
end

module.Sprint = function(char,onoff,tracks)
	local hum = char.Humanoid

	if onoff then
		if char:FindFirstChild("Sprinting") then return end

		local sprintingTag = Instance.new("Folder")
		sprintingTag.Name = "Sprinting"
		sprintingTag.Parent = char

		if not tracks["Sprint"].IsPlaying then
			tracks["Sprint"]:Play()	
		end
	else
		if not char:FindFirstChild("Sprinting") then return end
		char.Sprinting:Destroy()
		tracks["Sprint"]:Stop()
	end
end

module.Walk = function(char,onoff,tracks)
	local hum = char.Humanoid

	if onoff then		
		if not tracks["Walk"].IsPlaying then
			tracks["Walk"]:Play()
		end	
	else
		tracks["Walk"]:Stop()
	end
end


module.BasicAttack = function(char,live,tracks)
	local hum = char.Humanoid
	if char:FindFirstChild("Attacking") then return end;
	if char:FindFirstChild("Stun") then return end;
	if char:FindFirstChild("Eating") then return end;
	if char:FindFirstChild("Knocked") then return end;
	if not char:FindFirstChild("MonsterInfo") then
		return
	end
	local master = char.MonsterInfo.Master.Value

	coroutine.wrap(function()
		local attacking = Instance.new("Folder")
		attacking.Name = "Attacking"
		attacking.Parent = char

		local anim = tracks["Attack"]
		anim:Play()
		
		local cancel = char:FindFirstChild("Stun") or char:FindFirstChild("Knocked") or char:FindFirstChild("Unconscious") or char:FindFirstChild("Grabbed")

		local timeel = 0
		repeat
			cancel = char:FindFirstChild("Stun") or char:FindFirstChild("Knocked") or char:FindFirstChild("Unconscious") or char:FindFirstChild("Grabbed")
			timeel = timeel+wait()
		until timeel >= 0.4 or cancel
        if char and char:FindFirstChild("MonsterInfo") then
		local master = char.MonsterInfo.Master.Value
		local shriekerheal = false
		if master then
			local masterplr = game.Players:GetPlayerFromCharacter(master)
			-- Checked against server-only PlayerData instead of masterplr.Backpack - Backpack
			-- is replicated to the owning client, so a spoofed "ShriekerHeal" Instance there
			-- would be trusted the same way a spoofed Character Instance would.
			local masterdata = masterplr and game.ServerStorage.PlayerData:FindFirstChild(masterplr.Name)
			if masterdata and masterdata.Skills.Value:find("ShriekerHeal") then
				shriekerheal = true
			end
		end

		if not cancel then
			for _,ochar in next, live do
				if ochar ~= char and not char:FindFirstChild("Stun") and ochar:FindFirstChild("Humanoid") and ochar:FindFirstChild("HumanoidRootPart") and ochar.Humanoid.Health > 0 then
					local good = true
					if ochar:FindFirstChild("MonsterInfo") then
						if not (master and ochar.MonsterInfo.Master.Value ~= master) then
							good = false
						end		
					end

					local dist = (char.HumanoidRootPart.Position - ochar.HumanoidRootPart.Position).Magnitude
					if good and dist < 8 and (char.HumanoidRootPart.CFrame:inverse()*ochar.HumanoidRootPart.CFrame).Z < 0 then
						tagHumanoid:Fire(char,ochar,{
							damage = 15,
							fist = true,
							physical = true,
							cursestack = true,
							--shriekerhit = shriekerheal,
						})

						if shriekerheal and master and master:FindFirstChild("Humanoid") and not master:FindFirstChild("NoHeal") then
							master.Humanoid.Health = master.Humanoid.Health + 4

							local bead = game.ServerStorage.Assets.DarkBead:Clone()
							bead.Position = ochar.HumanoidRootPart.Position
							bead.Parent = workspace.Thrown
							TweenService:Create(bead,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{Position=master.Torso.Position}):Play()
							game.Debris:AddItem(bead,0.5)
						end
					end
				end
			end
		else
			anim:Stop()
		end
end
		wait(0.55)

		attacking:Destroy()
	end)()
end

module.Fireball = function(char,live,tracks)
	local hum = char.Humanoid
	if char:FindFirstChild("Attacking") then return end;
	if char:FindFirstChild("Stun") then return end;
	if char:FindFirstChild("Eating") then return end;
	if char:FindFirstChild("Knocked") then return end;
	if not char:FindFirstChild("MonsterInfo") then
		return
	end
	local master = char.MonsterInfo.Master.Value
	
	local chants = {"Phase","Twilight","Eyes of Wisdom","Pillar of Light","Paramita","Nine Ropes","Polarized Light","Scale of the Dragon","Recoil","Twin Meteors","Pair of Meteors","Open","Weave the Mind","Through Gaia to Khei","From Khei to Gaia","Kai"}
	
	local l__FireWhip__1 = game.ServerStorage.SpellEffects.FireWhip
	local attacking = Instance.new("Folder")
	attacking.Name = "Attacking"
	attacking.Parent = char
	
	local u9
	
	for _,targetfound in pairs(game.Workspace.Live:GetChildren()) do
		if targetfound ~= char and targetfound:FindFirstChild("Humanoid") and not targetfound:FindFirstChild("MonsterInfo") then
			local mag = (char.HumanoidRootPart.Position - targetfound.HumanoidRootPart.Position).Magnitude
			if mag < 60 then
				u9 = targetfound.HumanoidRootPart
				break
			end
		end
	end
	
	for count = 1,5 do
		coroutine.wrap(function()
			
			game:GetService("Chat"):Chat(char.Head,chants[math.random(1,#chants)],Enum.ChatColor.Red)

		local anim = tracks["Snap"]
		anim:Play()
		
		local p9 = char
			wait(0.2)
			local v54 = game.ReplicatedStorage.Assets.HandHoldFire:Clone()
			v54.IllusionArm.Enabled = false
			v54.Parent = workspace.Thrown
			v54.Snap:Play()
			v54.IllusionSnap:Emit(100)
			local v55 = CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(180))
			local u10 = Instance.new("Weld")
			local u11 = p9["Right Arm"]
		task.spawn(function()
				u10.Name = "Weld"
				u10.Part0 = u11
				u10.Part1 = v54
				u10.Parent = v54
				u10.C1 = v55
				wait(1)
				v54:Destroy()
			end)
			local v56 = l__FireWhip__1.Fireball:Clone()
			v56.Position = p9.HumanoidRootPart.Position + CFrame.new(p9.HumanoidRootPart.Position, u9.Position).LookVector * 15
			v56.CFrame = CFrame.new(v56.Position, u9.Position)
			v56.Parent = workspace.Thrown
			v56.Firesound:Play()
			v56:SetNetworkOwner(nil)
			v56.BodyVelocity.Velocity = v56.CFrame.LookVector * 120
			task.delay(5, v56.Destroy, v56)
		task.spawn(function()
				wait(3)
				if v56:IsDescendantOf(workspace)then
					if v56:FindFirstChild("BodyVelocity") then
						v56.BodyVelocity:Destroy()
					end
					v56.Anchored = true
					v56.Firesound2:Stop()
					v56.Explosion:Emit(100)
					local Attach = v56:FindFirstChild'Attach'
					if Attach then
						Attach:Destroy()
						v56.IllusionArm:Destroy()
						v56.IllusionArm2:Destroy()
						v56.IllusionArm3:Destroy()
					end
					TweenService:Create(v56, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Size = Vector3.new(12, 12, 12), 
						Transparency = 1
					}):Play()
					if v56:FindFirstChild("PointLight") then
						TweenService:Create(v56.PointLight, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
							Range = 15
						}):Play()
					end
					HitDetect.magnitudeCheck(p9, v56.Position, 15, {
						mana = true, 
						damage = 25, 
						manaknockupself = true, 
						canspellcounter = true,
						curse = true, 
						burn = true,
						cursestack = true,
						move = "Ignis"
					}, false, true)
				task.spawn(function()
						wait(0.45)
						if v56:FindFirstChild("PointLight") then
							TweenService:Create(v56.PointLight, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
								Range = 0
							}):Play()
						end
					end)
					game:GetService("Debris"):AddItem(v56, 2)
				end
			end)
			local v57 = {}
			local u12 = nil
			u12 = v56.Touched:Connect(function(p13)
				if not p13.Parent then
					return
				end
				if p13:IsDescendantOf(workspace.Terrain) then
					return
				end
				if p13:IsDescendantOf(p9)or p13.Name == p9.Name or p13.Parent.Name == p9.Name then
					return
				end
				if p13.Name == v56.Name then
					return
				end
				if p13.Parent.Name == "Shadow Buddy" then
					return
				end
				local v58 = p13.Parent:FindFirstChild("Humanoid") or p13.Parent.Parent:FindFirstChild("Humanoid")
				if v58 and v58.Parent.Name == p9.Name then
					return
				end
				u12:Disconnect()
				v56.BodyVelocity:Destroy()
				v56.Anchored = true
				v56.Firesound2:Stop()
				v56.Explosion:Emit(100)
				v56.Attachment:Destroy()
				v56.IllusionArm:Destroy()
				v56.IllusionArm2:Destroy()
				v56.IllusionArm3:Destroy()
				TweenService:Create(v56, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Size = Vector3.new(12, 12, 12), 
					Transparency = 1
				}):Play()
				TweenService:Create(v56.PointLight, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Range = 15
				}):Play()
				local v59 = 25
				if game.ServerStorage.PlayerData:FindFirstChild(p9.Name) and (game.ServerStorage.PlayerData[p9.Name].Race.Value == "Azael" or game.ServerStorage.PlayerData[p9.Name].Race.Value == "Kasparan") then
					v59 = v59 * 1.25
				end
				HitDetect.magnitudeCheck(p9, v56.Position, 20, {
					mana = true, 
					damage = v59, 
					manaknockupself = true, 
					canspellcounter = true,
					curse = true, 
					burn = true,
					cursestack = true,
					move = "Ignis"
				}, false, true)
			task.spawn(function()
					wait(0.45)
					TweenService:Create(v56.PointLight, TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Range = 0
					}):Play()
				end)
				game:GetService("Debris"):AddItem(v56, 2)
			end)
		end)()
		task.wait(2)
	end
	wait(5)

	attacking:Destroy()
end

module.SummonZombie = function(char,live,tracks)
	local hum = char.Humanoid
	if char:FindFirstChild("Attacking") then return end;
	if char:FindFirstChild("Stun") then return end;
	if char:FindFirstChild("Eating") then return end;
	if char:FindFirstChild("Knocked") then return end;
	if not char:FindFirstChild("MonsterInfo") then
		return
	end
	local master = char.MonsterInfo.Master.Value

	local attacking = Instance.new("Folder")
	attacking.Name = "Attacking"
	attacking.Parent = char

	for v10 = 1, 2 do
		local v11 = game.ServerStorage.Requests.SpawnMonster:Invoke("Shrieker", char.Torso.Position + Vector3.new(math.random(-15, 15), char, math.random(-15, 15)), nil, false);
		local v12 = game.ServerStorage.Assets.Dark:Clone();
		v12.CFrame = v11.Torso.CFrame;
		v12.Parent = workspace.Thrown;
		game:GetService("Debris"):AddItem(v12, 2);
		v12.Sound:Play();
		v12.Attachment.OrbParticle:Emit(100);
		TweenService:Create(v12, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false), {
			Size = Vector3.new(10.05, 10.05, 10.05)
		}):Play();
		local v13 = Instance.new("Accessory");
		v13.Name = "Summoned";
		v13.Parent = v11;
	end;
	wait(10)

	attacking:Destroy()
end

module.Eat = function(char,target,tracks)
	coroutine.wrap(function()
		local hum = char.Humanoid
		if char:FindFirstChild("Eating") then return end

		local eating = Instance.new("Folder")
		eating.Name = "Eating"
		eating.Parent = char

		local eatenTag = target:FindFirstChild("BeingEaten")
		if not eatenTag then
			eatenTag = Instance.new("IntValue")
			eatenTag.Name = "BeingEaten"
			eatenTag.Value = 0
			eatenTag.Parent = target
			game.Debris:AddItem(eatenTag,15)
		end

		local anim = tracks["Eat"]
		anim:Play()

		char.Torso.Chew:Play()

		local eplay = game.Players:GetPlayerFromCharacter(target)

		local enemyDanger = dangerHandler:getEntity(target)
		local tagName = char.Name..":Execute"
		if enemyDanger then
			-- if you execute someone, the kill is always yours
			enemyDanger:createTag(tagName,{damage=math.huge,lifespan=30})
			-- we make the source "PLAYERNAME:Execute" so we don't overwrite regular combat tags by doing this
		end

		local master = char.MonsterInfo.Master.Value
		local shriekerheal = false
		if master then
			local masterplr = game.Players:GetPlayerFromCharacter(master)
			-- Checked against server-only PlayerData instead of masterplr.Backpack - Backpack
			-- is replicated to the owning client, so a spoofed "ShriekerHeal" Instance there
			-- would be trusted the same way a spoofed Character Instance would.
			local masterdata = masterplr and game.ServerStorage.PlayerData:FindFirstChild(masterplr.Name)
			if masterdata and masterdata.Skills.Value:find("ShriekerHeal") then
				shriekerheal = true
			end
		end

		local i = 0
		repeat
			i = i + 1

			if eplay and i % 10 == 0 then
				if math.random(1,100) == 1 then
					game.ServerStorage.Requests.Injure:Invoke(eplay,"armless",true)
				else
					game.ServerStorage.Requests.Injure:Invoke(eplay,{"blackeye","burn","brokenleg","brokenarm","brokenrib","cataract","chestgash"},true)
				end
			end

			if not (eatenTag and eatenTag.Parent) then
				if not target:FindFirstChild("BeingEaten") then
					eatenTag = Instance.new("IntValue")
					eatenTag.Name = "BeingEaten"
					eatenTag.Value = 0
					eatenTag.Parent = target
					game.Debris:AddItem(eatenTag,15)
				else
					eatenTag = target.BeingEaten
				end
			end

			if shriekerheal and master and master:FindFirstChild("Humanoid") and not master:FindFirstChild("NoHeal") then
				master.Humanoid.Health = master.Humanoid.Health + 1

				if i % 5 == 0 then
					local bead = game.ServerStorage.Assets.DarkBead:Clone()
					bead.Position = target.HumanoidRootPart.Position
					bead.Parent = workspace.Thrown
					TweenService:Create(bead,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{Position=master.Torso.Position}):Play()
					game.Debris:AddItem(bead,0.5)
				end
			end

			eatenTag.Value = eatenTag.Value + 1

			wait(0.1)
		until char:FindFirstChild("Stun") or char:FindFirstChild("Knocked") or eatenTag.Value >= 70 or not target:FindFirstChild("Unconscious") or (target.Torso.Position-char.Torso.Position).Magnitude > NO_CLOSER

		anim:Stop()
		char.Torso.Chew:Stop()
		eating:Destroy()

		if eatenTag.Value >= 70 and target and target.Parent then
			target.Humanoid.Health = 0
			target.Humanoid:TakeDamage(999999999)
			game.ServerStorage.Requests.Wakeup:Fire(target,true)
		else
			if enemyDanger then
				enemyDanger:removeTag(tagName)
				-- remove the execute tag
			end
		end		
	end)()
end

return module
