local module = {}

local tagHumanoid = game.ServerStorage.Requests.TagHumanoid
local dangerHandler = require(game.ServerScriptService.Modules.DangerHandler)
local TweenService = game:GetService("TweenService")

local BITE_RANGE = 12
local POUNCE_RANGE = 30 
local NO_CLOSER = 10
local WALK_RANGE = 15
local BLINK_RANGE = 25
local GROUPING_RANGE = 20
local AGGRO_DISTANCE = 300
local CHASE_DISTANCE = 300
local CIRCLE_DISTANCE = 50
local CIRCLE_GROUPING_DIST = 5
local BLINK_CD = 4
local COLUBRAS = 9144458
local COLUBRAS_ALLIES = {
	["151239872"]=true
}

local function create(name,deletetime,parent)
	local i = Instance.new("Accessory")
	i.Name = name
	i.Parent = parent
	if (name == "Knocked" and game.Players:FindFirstChild(parent.Name)) and game.ServerStorage.PlayerData[parent.Name].Injuries.Value:find("BrokenRib") then
		game.Debris:AddItem(i,deletetime * 1.25)
	else
		game.Debris:AddItem(i,deletetime)
	end
	return i
end

module.setup = function(char)
	local hum = char.Humanoid
	hum.StateChanged:connect(function(old,new)
		if new == Enum.HumanoidStateType.FallingDown or new == Enum.HumanoidStateType.Ragdoll then
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end)
end


module.onHowlerDeath = function(char)
	local variables = char:WaitForChild("Variables",.5)
	if not variables then return end
	local monsterInfo = char.MonsterInfo
	local leader = variables.Leader.Value

	if leader and leader.Parent then
		leader.Variables.PackAlive.Value = leader.Variables.PackAlive.Value - 1
	end
end

module.die = function(char)
	if not char.MonsterInfo.Master.Value and math.random(1,100)/100 <= char.Variables.Droprate.Value and not char:FindFirstChild("NoDrops") and not char:FindFirstChild("Summoned") then
		_G.DropBag("MonsterDrop", char.Variables.Drop.Value, char)
	end
	module.onHowlerDeath(char)
	if char:FindFirstChild'Torso'then
		local dustpart = game.ServerStorage.Assets.MonsterDeath:Clone()
		dustpart.CFrame = char.Torso.CFrame
		dustpart.DeadCast:Play()
		dustpart.DUST1.EmissionDirection = "Front"
		dustpart.DUST2.EmissionDirection = "Front"
		dustpart.DUST3.EmissionDirection = "Front"
		dustpart.Parent = workspace.Thrown
		game:GetService("Debris"):AddItem(dustpart,3)
		dustpart.DUST1:Emit(70)
		wait(.2)
		dustpart.DUST2:Emit(50)
		wait(.2)
		dustpart.DUST3:Emit(25)
	end

	char:Destroy()
end

module.colubrasKilled = function(char)
	module.onHowlerDeath(char)
	local spelleffect = game.ServerStorage.SpellEffects.ColubrasRestrain

	local ray = Ray.new(char.HumanoidRootPart.Position,Vector3.new(0,50,0))
	local intersect,pos = game.Workspace:FindPartOnRayWithIgnoreList(ray,{game.Workspace.Live,game.Workspace.Thrown,game.Workspace.MonsterSpawns})

	local portalPos = char.HumanoidRootPart.Position + Vector3.new(0,50,0)

	if intersect then portalPos = pos end

	local portal = spelleffect.Portal:Clone()
	portal.Position = portalPos
	portal.Parent = game.Workspace.Thrown
	portal.Particle.Enabled = true	
	portal.Open:Play()

	local shadowParts = {}

	local charChildren = char:GetChildren()			
	for i = 1,#charChildren do
		local part = charChildren[i]
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
	for i = 1,numSP do
		local part = shadowParts[i]
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

	if ochar == master then return true end
	
	local vPlayer = game.Players:GetPlayerFromCharacter(ochar)
	
	if ochar:FindFirstChild("Carried") then return true end
	
	if ochar:FindFirstChild("MonsterInfo") then
		if not (master and ochar.MonsterInfo.Master.Value ~= master) then
			return true
		end		
	else
		if ochar:FindFirstChild("Boosts") and ochar.Boosts:FindFirstChild("PuppiesLikeHim") or (vPlayer and game.ServerStorage.PlayerData[ochar.Name].Artifact.Value == "HowlerFriend") or game.ServerStorage.PlayerData[ochar.Name].Race.Value == "Howler" then
			return true
		end

		if master and masterFolder and game.Players:GetPlayerFromCharacter(master).UserId == COLUBRAS then
			local cFolder = game.ServerStorage.PlayerData:FindFirstChild(ochar.Name)
			if cFolder then
				if masterFolder.LastName.Value ~= "" and masterFolder.LastName.Value == cFolder.LastName.Value then
					return true
				end

				if COLUBRAS_ALLIES[tostring(game.Players:GetPlayerFromCharacter(ochar).UserId)] then
					return true
				end
			end
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

	local torso = char:FindFirstChild("Torso")
	local bodyGyro = torso and torso:FindFirstChild("BodyGyro")

	if char:FindFirstChild("Action") or char:FindFirstChild("Unconscious") or char:FindFirstChild("Knocked") or char:FindFirstChild("Stun") then
		if bodyGyro then
			bodyGyro.MaxTorque = Vector3.new(0,0,0)
		end
		module.Walk(char,false,false,tracks)
		return
	end

	if not (char:FindFirstChild("Burning") and not char:FindFirstChild("SoulBurning") and not char:FindFirstChild("BlinkCD") and not char:FindFirstChild("ContrariumTag")) then
		if variables.State.Value == "ROAMING" then
			if bodyGyro then
				bodyGyro.MaxTorque = Vector3.new(0,0,0)
			end
			module.Sprint(char,false,tracks)
			module.FindTarget(char,live,tracks)
			if variables.State.Value == "ROAMING" then
				monsterInfo.Aggrod.Value = false
				local timeSinceLastRoam = tick() - variables.LastRoam.Value
				if timeSinceLastRoam >= 5 + variables.RoamCD.Value then
					variables.LastRoam.Value = tick() 
					variables.RoamCD.Value = math.random(400,600)/100
					module.Walk(char,true,false,tracks)
					hum:Move(Vector3.new(math.random(-100,100),0,math.random(-100,100)))
				elseif timeSinceLastRoam >= 3 then
					module.Walk(char,false,false,tracks)
					hum:Move(Vector3.new(0,0,0))
				end
			end
		elseif variables.State.Value == "CIRCLING" then
			local target = variables.Target.Value
			monsterInfo.Aggrod.Value = true
			monsterInfo.LastAggrod.Value = tick()
			game.ServerStorage.Requests.ResetMonsterExpiration:Invoke(char)

			if target and target.Parent == workspace.Live and target ~= char and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and not module.isAnAlly(char,target,masterFolder) then
				if bodyGyro then
					bodyGyro.MaxTorque = Vector3.new(0,8e10,0)
					bodyGyro.CFrame = CFrame.new(char.Torso.Position,target.HumanoidRootPart.Position)
				end
				--char.Torso.BodyGyro.MaxTorque = Vector3.new(0,0,0)			

				local distanceToTarget = (target.Torso.Position - char.Torso.Position).Magnitude
				if distanceToTarget > CHASE_DISTANCE then
					module.FindTarget(char,live,tracks)
				else
					if distanceToTarget < CIRCLE_DISTANCE and distanceToTarget > CIRCLE_DISTANCE * 0.5 then
						module.Sprint(char,false,tracks)
						module.Walk(char,true,true,tracks)

						if tick() - variables.LastMove.Value > 0 then
							variables.LastMove.Value = tick()
							local adjust = Vector3.new(1,0,1)
							if variables.Clockwise.Value == true then
								adjust = adjust * -1
							end
							local moveVector = CFrame.new(char.Torso.Position,target.Torso.Position).rightVector * adjust

							for i = 1,#live do
								local ochar = live[i]
								if ochar ~= char and ochar:FindFirstChild("MonsterInfo") and ochar.MonsterInfo.MonsterType.Value == monsterInfo.MonsterType.Value then
									local dist = char.Torso.Position - ochar.Torso.Position
									if dist.Magnitude < CIRCLE_GROUPING_DIST then
										moveVector = moveVector + dist.unit * 3
									end
								end
							end

							hum:Move(moveVector)
						end
					elseif distanceToTarget > CIRCLE_DISTANCE then
						module.Sprint(char,true,tracks)
						module.Walk(char,false,false,tracks)

						if tick() - variables.LastMove.Value > 0.3 then
							variables.LastMove.Value = tick()
							hum:Move((target.Torso.Position-char.Torso.Position) * Vector3.new(1,0,1))
						end
					else
						module.Sprint(char,false,tracks)
						module.Walk(char,true,false,tracks)

						if tick() - variables.LastMove.Value > 0.3 then
							variables.LastMove.Value = tick()
							hum:Move((char.Torso.Position - target.Torso.Position) * Vector3.new(1,0,1))
						end
					end
				end

				local rayOut = Ray.new(char.Torso.Position,char.Torso.CFrame.lookVector.unit*4)
				local obscuring = game.Workspace:FindPartOnRayWithIgnoreList(rayOut,{game.Workspace.Live,game.Workspace.Thrown,game.Workspace.MonsterSpawns})
				if obscuring then
					if char:FindFirstChild("ContrariumTag") or char:FindFirstChild("BlinkCD") then
						hum.Jump = true
					else
						local currcf = char.Torso.CFrame
						local tpcf = currcf + Vector3.new(0,10,0)

						local cd = Instance.new("Folder")
						cd.Name = "BlinkCD"
						cd.Parent = char
						game.Debris:AddItem(cd,BLINK_CD)

						module.BlinkEffect(char,live)
						char.Torso.CFrame = tpcf
					end
				end

				module.circleThink(char,live)
			else
				module.FindTarget(char,live,tracks)
			end
		elseif variables.State.Value == "AGGROD" then
			local target = variables.Target.Value
			local lastHitBy = variables.LastHitBy.Value

			monsterInfo.Aggrod.Value = true
			monsterInfo.LastAggrod.Value = tick()
			game.ServerStorage.Requests.ResetMonsterExpiration:Invoke(char)

			if target and target.Parent == workspace.Live and target ~= char and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
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

					if target:FindFirstChild("Unconscious") or target:FindFirstChild("Knocked") then
						local targDir = target.Torso.Position - char.Torso.Position
						if distanceToTarget < NO_CLOSER then
							module.Walk(char,false,false,tracks)
							module.Sprint(char,false,tracks)
							module.Shake(char,target,tracks)
						elseif distanceToTarget < BLINK_RANGE and not char:FindFirstChild("ContrariumTag") and not char:FindFirstChild("BlinkCD") then
							local currcf = char.Torso.CFrame
							local tpcf = CFrame.new((CFrame.new(char.Torso.Position,target.Torso.Position) * CFrame.new(0,0,-targDir.Magnitude)).Position) * (currcf-currcf.p)

							local safe = true
							for i = 1,#live do
								local ochar = live[i]
								if ochar ~= target and ochar ~= char and ochar:FindFirstChild("Torso") then
									local ocharDist = (ochar.Torso.Position-tpcf.p).Magnitude
									if ocharDist <= 5 then
										safe = false
										break
									end
								end
							end

							local safetyRay = Ray.new(char.Torso.Position,tpcf.p-char.Torso.Position)
							local rPart,rPos,rNorm = workspace:FindPartOnRayWithIgnoreList(safetyRay,{workspace.Live,workspace.Thrown,workspace.MonsterSpawns})
							if rPart then safe = false end

							if safe then
								local cd = Instance.new("Folder")
								cd.Name = "BlinkCD"
								cd.Parent = char
								game.Debris:AddItem(cd,BLINK_CD)

								module.BlinkEffect(char,live)
								char.Torso.CFrame = tpcf
							end
						else
							module.Walk(char,false,false,tracks)
							module.Sprint(char,true,tracks)

							if tick() - variables.LastMove.Value > 0.3 then
								variables.LastMove.Value = tick()
								if hum:GetState() ~= Enum.HumanoidStateType.Swimming then	
									targDir = targDir * Vector3.new(1,0,1)
								end
								hum:Move(targDir)
							end
						end
					else
						if distanceToTarget < NO_CLOSER and not char:FindFirstChild("Pouncing") and not char:FindFirstChild("BiteCD") then
							module.Walk(char,false,false,tracks)
							module.Sprint(char,false,tracks)
							hum:Move(Vector3.new(0,0,0))

							if char:FindFirstChild("RecentlyHit") then
								local targDir = target.Torso.Position - char.Torso.Position
								if not char:FindFirstChild("ContrariumTag") and not char:FindFirstChild("BlinkCD") then
									local currcf = char.Torso.CFrame
									local tpcf = CFrame.new((CFrame.new(char.Torso.Position,target.Torso.Position) * CFrame.new(0,0,10)).p) * (currcf-currcf.p)

									local safe = true
									for i = 1,#live do
										local ochar = live[i]
										if ochar ~= target and ochar ~= char and ochar:FindFirstChild("Torso") then
											local ocharDist = (ochar.Torso.Position-tpcf.p).Magnitude
											if ocharDist <= 5 then
												safe = false
												break
											end
										end
									end

									local safetyRay = Ray.new(char.Torso.Position,tpcf.p-char.Torso.Position)
									local rPart,rPos,rNorm = workspace:FindPartOnRayWithIgnoreList(safetyRay,{workspace.Live,workspace.Thrown,workspace.MonsterSpawns})
									if rPart then safe = false end

									if safe then
										local cd = Instance.new("Folder")
										cd.Name = "BlinkCD"
										cd.Parent = char
										game.Debris:AddItem(cd,BLINK_CD)

										module.BlinkEffect(char,live)
										char.Torso.CFrame = tpcf
									end
								end
							end
						else
							local targDir = target.Torso.Position - char.Torso.Position
							if (distanceToTarget < WALK_RANGE or char:FindFirstChild("BiteCD")) and not char:FindFirstChild("Pouncing") then
								module.Walk(char,true,false,tracks)
								module.Sprint(char,false,tracks)
							else
								if distanceToTarget < BLINK_RANGE and not char:FindFirstChild("ContrariumTag") and not char:FindFirstChild("BlinkCD") and not char:FindFirstChild("Attacking") then
									local currcf = char.Torso.CFrame
									local tpcf = CFrame.new((CFrame.new(char.Torso.Position,target.Torso.Position) * CFrame.new(0,0,-targDir.Magnitude * 0.85)).p) * (currcf-currcf.p)

									local safe = true
									for i = 1,#live do
										local ochar = live[i]
										if ochar ~= target and ochar ~= char and ochar:FindFirstChild("Torso") then
											local ocharDist = (ochar.Torso.Position-tpcf.p).Magnitude
											if ocharDist <= 5 then
												safe = false
												break
											end
										end
									end

									local safetyRay = Ray.new(char.Torso.Position,tpcf.p-char.Torso.Position)
									local rPart,rPos,rNorm = workspace:FindPartOnRayWithIgnoreList(safetyRay,{workspace.Live,workspace.Thrown,workspace.MonsterSpawns})
									if rPart then safe = false end

									if safe then
										local cd = Instance.new("Folder")
										cd.Name = "BlinkCD"
										cd.Parent = char
										game.Debris:AddItem(cd,BLINK_CD)

										module.BlinkEffect(char,live)
										char.Torso.CFrame = tpcf
									else
										tpcf = CFrame.new((CFrame.new(char.Torso.Position,target.Torso.Position) * CFrame.new(0,0,-targDir.Magnitude * 1.35)).p) * (currcf-currcf.p)
										safe = true
										for i = 1,#live do
											local ochar = live[i]
											if ochar ~= target and ochar ~= char and ochar:FindFirstChild("Torso") then
												local ocharDist = (ochar.Torso.Position-tpcf.p).Magnitude
												if ocharDist <= 5 then
													safe = false
													break
												end
											end
										end

										local safetyRay = Ray.new(char.Torso.Position,tpcf.p-char.Torso.Position)
										local rPart,rPos,rNorm = workspace:FindPartOnRayWithIgnoreList(safetyRay,{workspace.Live,workspace.Thrown,workspace.MonsterSpawns})
										if rPart then safe = false end

										if safe then
											local cd = Instance.new("Folder")
											cd.Name = "BlinkCD"
											cd.Parent = char
											game.Debris:AddItem(cd,BLINK_CD)

											module.BlinkEffect(char,live)
											char.Torso.CFrame = tpcf
										end
									end
								else
									module.Walk(char,false,false,tracks)
									module.Sprint(char,true,tracks)

									if distanceToTarget < POUNCE_RANGE then
										module.Pounce(char,live,tracks)
									end
								end	
							end

							local rayOut = Ray.new(char.Torso.Position,char.Torso.CFrame.lookVector.unit*4)
							local obscuring = game.Workspace:FindPartOnRayWithIgnoreList(rayOut,{game.Workspace.Live,game.Workspace.Thrown,game.Workspace.MonsterSpawns})
							if obscuring then
								if char:FindFirstChild("ContrariumTag") or char:FindFirstChild("BlinkCD") then
									hum.Jump = true
								else
									local currcf = char.Torso.CFrame
									local tpcf = currcf + Vector3.new(0,10,0)

									local cd = Instance.new("Folder")
									cd.Name = "BlinkCD"
									cd.Parent = char
									game.Debris:AddItem(cd,BLINK_CD)

									module.BlinkEffect(char,live)
									char.Torso.CFrame = tpcf
								end
							end

							if tick() - variables.LastMove.Value > 0.3 then
								variables.LastMove.Value = tick()

								if hum:GetState() ~= Enum.HumanoidStateType.Swimming then	
									targDir = targDir * Vector3.new(1,0,1)
								end

								if char:FindFirstChild("BiteCD") then
									targDir = targDir * -1
								end
								hum:Move(targDir)
							end
						end

						if distanceToTarget < BITE_RANGE and not char:FindFirstChild("Pouncing") then
							module.Bite(char,live,tracks)
						end
					end			
				else
					module.FindTarget(char,live,tracks)
				end
			else
				module.FindTarget(char,live,tracks)
			end
		end
	else
		module.BlinkEffect(char,live)
		local f = Instance.new("Folder")
		f.Name = "FireProtection"
		f.Parent = char
		game.Debris:AddItem(f,0.5)
	end
end

module.Sprint = function(char,onoff,tracks)
	if onoff then
		if char:FindFirstChild("Sprinting") then return end

		local sprintingTag = Instance.new("Folder")
		sprintingTag.Name = "Sprinting"
		sprintingTag.Parent = char

		tracks["Sprint"]:Play()		
	else
		if not char:FindFirstChild("Sprinting") then return end
		char.Sprinting:Destroy()

		tracks["Sprint"]:Stop()
	end
end

module.Walk = function(char,onoff,circling,tracks)
	local hum = char.Humanoid

	if onoff then		
		if circling then
			tracks["Walk"]:Stop()
			if char.Variables.Clockwise.Value then
				if not tracks["CircleCW"].IsPlaying then
					tracks["CircleCW"]:Play()
				end
			else
				if not tracks["CircleCCW"].IsPlaying then
					tracks["CircleCCW"]:Play()
				end
			end
		else
			if not tracks["Walk"].IsPlaying then
				tracks["Walk"]:Play()
			end
			tracks["CircleCW"]:Stop()
			tracks["CircleCCW"]:Stop()
		end		
	else
		tracks["Walk"]:Stop()
		tracks["CircleCW"]:Stop()
		tracks["CircleCCW"]:Stop()
	end
end

function partMagnitude(part,point,range)
	return (part.Position - point).Magnitude <= range
end

module.BlinkEffect = function(char,live)
	char.Torso.Blink:Play()
	char.Torso.BlinkAttach.Particle:Emit(1)

	for i = 1,#live do
		local ochar = live[i]
		if ochar and ochar ~= char and ochar:FindFirstChild("Humanoid") and ochar.Humanoid.Health > 0 and ochar:FindFirstChild("HumanoidRootPart") then
			if partMagnitude(ochar.HumanoidRootPart,char.HumanoidRootPart.Position,40) then
				local enemyDanger = dangerHandler:getEntity(ochar)
				if enemyDanger then
					enemyDanger:createTag(char.Name,{lifespan=20})
				end
			end
		end
	end
end

module.FindTarget = function(char,live,tracks)
	local hum = char.Humanoid
	local variables = char.Variables
	local monsterInfo = char.MonsterInfo
	local master = char.MonsterInfo.Master.Value
	local masterFolder = nil
	if master then
		masterFolder = game.ServerStorage.PlayerData:FindFirstChild(master.Name)
	end

	local closest = nil
	local closestDistance = nil

	task.spawn(function()
		for i = 1,#live do
			local enemy = live[i]
			if enemy and enemy ~= char and enemy:FindFirstChild("Torso") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
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

			local countOtherAggrod = 0
			for i = 1,#live do
				local ochar = live[i]
				if ochar and ochar ~= char and ochar:FindFirstChild("MonsterInfo") and ochar.MonsterInfo.MonsterType.Value == monsterInfo.MonsterType.Value and ochar.Variables.State.Value == "AGGROD" and ochar.Variables.Target.Value == closest then
					countOtherAggrod += 1
				end
			end

			local oldstate = variables.State.Value
			variables.Target.Value = closest

			if countOtherAggrod < 2 then
				variables.State.Value = "AGGROD"
			else
				variables.State.Value = "CIRCLING"
			end

			if oldstate == "ROAMING" and variables.Scout.Value then
				tracks.Howl:Play()
				char.Torso.Howl:Play()

				local action = Instance.new("Folder")
				action.Name = "Action"
				action.Parent = char
				game.Debris:AddItem(action,1)

				wait(0.5)

				for i = 1,variables.PackAlive.Value do
					local pos = (char.Torso.CFrame * CFrame.new(3*i * (-1)^i,0,2*i)).p
					local other = game.ServerStorage.Requests.SpawnMonster:Invoke("Howler",pos,nil,true)
					other.Variables.Leader.Value = char

					module.BlinkEffect(other,live)

					other.Humanoid:LoadAnimation(char.Animations.Howl):Play()
					other.Torso.Howl.PlaybackSpeed = math.random(90,140)/100
					other.Torso.Howl:Play()

					local action = Instance.new("Folder")
					action.Name = "Action"
					action.Parent = other
					game.Debris:AddItem(action,1)

					other.Variables.Target.Value = closest
					other.Variables.State.Value = "CIRCLING"

					if i % 2 == 0 then
						other.Variables.Clockwise.Value = false
					end

					wait(0.2)
				end
			end
		else
			variables.State.Value = "ROAMING"
			variables.Target.Value = nil

			if variables.Scout.Value == true then
				coroutine.wrap(function()
					for i = 1,#live do
						local ochar = live[i]
						if ochar and ochar:FindFirstChild("MonsterInfo") and ochar.MonsterInfo.MonsterType.Value == char.MonsterInfo.MonsterType.Value and ochar.Variables.Leader.Value == char then
							-- INSERT BLINK EFFECT
							module.BlinkEffect(ochar,live)
							wait(0.25)
							coroutine.wrap(function()
								wait(0.25)
								ochar:Destroy()
							end)()
						end
					end
				end)()
			end
		end
	end)
end

module.circleThink = function(char,live)
	local hum = char.Humanoid
	local variables = char.Variables
	local monsterInfo = char.MonsterInfo
	local master = char.MonsterInfo.Master.Value
	local target = variables.Target.Value
	local lastHitBy = variables.LastHitBy.Value

	if lastHitBy and lastHitBy.Parent then
		variables.Target.Value = lastHitBy
		variables.LastHitBy.Value = nil
	else
		local countOtherAggrod = 0
		for i = 1,#live do
			local ochar = live[i]
			if ochar ~= char and ochar:FindFirstChild("MonsterInfo") and ochar.MonsterInfo.MonsterType.Value == monsterInfo.MonsterType.Value and ochar.Variables.State.Value == "AGGROD" and ochar.Variables.Target.Value == target then
				countOtherAggrod = countOtherAggrod + 1
			end
		end

		if countOtherAggrod < 2 then
			variables.State.Value = "AGGROD"
		else
			for i = 1,#live do
				local enemy = live[i]
				if enemy ~= char and enemy ~= target and enemy:FindFirstChild("Torso") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
					if not (master and (enemy == master)) and not (enemy:FindFirstChild("MonsterInfo") and enemy.MonsterInfo.MonsterType.Value == char.MonsterInfo.MonsterType.Value and not (master and enemy.MonsterInfo.Master.Value ~= master)) then
						local ray = Ray.new(char.Head.Position,char.Head.Position-enemy.HumanoidRootPart.Position)
						local part,pos,norm = game.Workspace:FindPartOnRayWithIgnoreList(ray,{game.Workspace.Live,game.Workspace.Thrown,game.Workspace.MonsterSpawns})
						local dist = (char.HumanoidRootPart.Position-enemy.HumanoidRootPart.Position).Magnitude
						if not part and dist < AGGRO_DISTANCE then
							variables.Target.Value = enemy
							break
						end
					end
				end
			end
		end
	end
end

module.Bite = function(char,live,tracks)
	if char:FindFirstChild("Stun") then return end
	if char:FindFirstChild("Attacking") then return end
	if char:FindFirstChild("BiteCD") then return end

	local master = char.MonsterInfo.Master.Value
	local hum = char.Humanoid

	local attacking = Instance.new("Folder")
	attacking.Name = "Attacking"
	attacking.Parent = char

	task.spawn(function()
		local track = tracks["Bite"]
		track:Play()

		local start_t = tick()
		local stunned = false
		repeat
			if char:FindFirstChild("Stun") then
				stunned = true
			end
			wait()
		until tick() - start_t >= 0.3 or stunned

		if stunned then track:Stop() attacking:Destroy() return end
		
		for _: number, NPC in pairs(live)do
			local HRP = NPC:FindFirstChild'HumanoidRootPart'
			local Hum = NPC:FindFirstChild'Humanoid'
			if NPC ~= char and HRP and Hum and Hum.Health > 0 then
				local dist = (char.HumanoidRootPart.Position - HRP.Position).Magnitude
				local cfdiff = char.HumanoidRootPart.CFrame:Inverse() * HRP.CFrame
				local good: boolean = true
				if NPC:FindFirstChild("MonsterInfo") then
					if not (master and NPC.MonsterInfo.Master.Value ~= master) then
						good = false
					end
				end

				if dist <= 12 and cfdiff.Z <= 0 and good then
					--tagHumanoid:Fire(char,ochar,{physical=true,damage=10})
					tagHumanoid:Fire(char,NPC,{
						damage = 10,
						fist = true,
						physical = true,
					})
				end
			end
		end

		game.Debris:AddItem(attacking,0.2)

		local BiteCD = Instance.new("Folder")
		BiteCD.Name = "BiteCD"
		BiteCD.Parent = char


		local target = char.Variables.Target.Value
		if target and target.Parent == workspace.Live and not char:FindFirstChild("BlinkCD") and not char:FindFirstChild("ContrariumTag") then
			local targDir = target.Torso.Position - char.Torso.Position
			local currcf = char.Torso.CFrame

			local tpcf
			if target:FindFirstChild("Blocking") then
				tpcf = CFrame.new((CFrame.new(char.Torso.Position,target.Torso.Position) * CFrame.new(0,0,-targDir.Magnitude * 1.25)).p) * (currcf-currcf.p)
				game.Debris:AddItem(BiteCD,0.5)
			else
				tpcf = char.Torso.CFrame * CFrame.new(0,0,25)
				game.Debris:AddItem(BiteCD,1)
			end	

			local safe = true
			for i = 1,#live do
				local ochar = live[i]
				if ochar ~= target and ochar ~= char and ochar:FindFirstChild("Torso") then
					local ocharDist = (ochar.Torso.Position-tpcf.p).Magnitude
					if ocharDist <= 5 then
						safe = false
						break
					end
				end
			end

			local safetyRay = Ray.new(char.Torso.Position,tpcf.p-char.Torso.Position)
			local rPart,rPos,rNorm = workspace:FindPartOnRayWithIgnoreList(safetyRay,{workspace.Live,workspace.Thrown,workspace.MonsterSpawns})
			if rPart then safe = false end

			if safe then
				local cd = Instance.new("Folder")
				cd.Name = "BlinkCD"
				cd.Parent = char
				game.Debris:AddItem(cd,BLINK_CD)

				module.BlinkEffect(char,live)
				char.Torso.CFrame = tpcf
			end
		else
			game.Debris:AddItem(BiteCD,1.5)
		end
	end)
end

module.Pounce = function(char,live,tracks)
	if char:FindFirstChild("Stun") then return end
	if char:FindFirstChild("Attacking") then return end

	local master = char.MonsterInfo.Master.Value

	local hum = char.Humanoid

	local attacking = Instance.new("Folder")
	attacking.Name = "Attacking"
	attacking.Parent = char

	local f2 = Instance.new("Folder")
	f2.Name = "Pouncing"
	f2.Parent = char

	coroutine.wrap(function()
		local track = tracks["Pounce"]
		track:Play()

		local start_t = tick()
		local stunned = false
		repeat
			if char:FindFirstChild("Stun") then
				stunned = true
			end
			wait()
		until tick() - start_t >= 0.3 or stunned

		if stunned then track:Stop() attacking:Destroy() f2:Destroy() return end

		local boosts = char:FindFirstChild("Boosts")
		if boosts then
			local speedboost = Instance.new("IntValue")
			speedboost.Name = "WalkSpeedBoost"
			speedboost.Value = 10
			speedboost.Parent = char.Boosts
			game.Debris:AddItem(speedboost,0.2)
		end

		local tags = {}

		local active_t = tick()
		repeat
			for i = 1,#live do
				local ochar = live[i]
				if ochar ~= char and not tags[ochar] and char:FindFirstChild("HumanoidRootPart") and ochar:FindFirstChild("HumanoidRootPart") then
					local dist = (char.HumanoidRootPart.Position - ochar.HumanoidRootPart.Position).Magnitude

					local good = true
					if ochar:FindFirstChild("MonsterInfo") then
						if not (master and ochar.MonsterInfo.Master.Value ~= master) then
							good = false
						end		
					end

					if dist <= 6 and good then
						--tagHumanoid:Fire(char,ochar,{physical=true,damage=10,knockback=true,knocktime=5})
						tags[ochar] = true
						tagHumanoid:Fire(char,ochar,{
							damage = 10,
							fist = true,
							physical = true,
							knockback = true,
						})
					end
				end
			end
			wait(0.05)
		until tick() - active_t >= 0.2 or char:FindFirstChild("Stun")

		game.Debris:AddItem(attacking,0.2)
		game.Debris:AddItem(f2,0.2)
	end)()
end

module.Shake = function(char,target,tracks)
	if char:FindFirstChild("Attacking") then return end
	if char:FindFirstChild("Action") then return end
	if char:FindFirstChild("Stun") then return end
	if not target:FindFirstChild("Torso") or (target.Torso.Position - char.Torso.Position).Magnitude > NO_CLOSER then return end
	if target:FindFirstChild("ShakeCD") then return end	
	if not target:FindFirstChild("Right Leg") then return end
	local lethal = not not target:FindFirstChild("Unconscious")

	local hum = char.Humanoid

	hum:Move(Vector3.new(0,0,0))

	local f = Instance.new("Folder")
	f.Name = "Action"
	f.Parent = char

	local f2 = Instance.new("Folder")
	f2.Name = "ShakeCD"
	f2.Parent = target

	local weld = Instance.new("Weld")
	weld.Part0 = char["Upper Mouth"]
	weld.C0 = CFrame.new()
	local injury = {"brokenleg"}
	if not lethal then
		if char:FindFirstChild("BrokenLeg") then
			injury = {"brokenarm"}
			weld.Part1 = target["Right Arm"]
		else
			weld.Part1 = target["Right Leg"]
		end
	else
		weld.Part1 = target["Left Arm"]
	end
	weld.Parent = char["Upper Mouth"]

	local track = tracks["Shake"]
	track:Play()
	
	create("Knocked", 6, target)
	--game.ServerStorage.Requests.Knock:Fire(target,6)

	coroutine.wrap(function()
		local stunned = false
		local start_t = tick()
		repeat
			if char:FindFirstChild("Stun") then
				stunned = true
			end
			wait()
		until (tick() - start_t > 4.5) or stunned

		if not stunned and char and char.Parent then
			if lethal then
				local enemyDanger = dangerHandler:getEntity(target)
				local tagName = char.Name..":Execute"
				if enemyDanger then
					-- if you execute someone, the kill is always yours
					enemyDanger:createTag(tagName,{damage=math.huge,lifespan=30})
					-- we make the source "PLAYERNAME:Execute" so we don't overwrite regular combat tags by doing this
				end
				target.Humanoid.Health = 0
			else
				if game.Players:GetPlayerFromCharacter(target) then
					tagHumanoid:Fire(char,target,{downbypass = true,injury = injury[1]})

					if target.Humanoid.Health - 20 > 0 then
						target.Humanoid:TakeDamage(20)
					else
						target.Humanoid.Health = 1
					end
				end
			end
		end

		track:Stop()
		weld:Destroy()
		game.Debris:AddItem(f,0.5)
		game.Debris:AddItem(f2,3)
	end)()
end

return module