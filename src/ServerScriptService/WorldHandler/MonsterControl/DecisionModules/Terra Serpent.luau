local module = {}

local tagHumanoid = game.ServerStorage.Requests.TagHumanoid
local hitDetection = require(game.ServerScriptService.Modules.HitDetection)
local dangerHandler = require(game.ServerScriptService.Modules.DangerHandler)
local TweenService = game:GetService("TweenService")

local SLOW_RANGE = 40 
local NO_CLOSER = 25
local AGGRO_DISTANCE = 150
local CHASE_DISTANCE = 200
local BREATH_RANGE = 60
local BREATH_MIN = 10
local SPIN_RANGE = 25
local STRIKE_RANGE = 40
local HEATING_DIST = 60
local COLUBRAS = 9144458
local COLUBRAS_ALLIES = {
	["151239872"]=true
}

module.setup = function(char,tracks)
	local hum = char.Humanoid

	hum.StateChanged:connect(function(old,new)
		if new == Enum.HumanoidStateType.FallingDown or new == Enum.HumanoidStateType.Ragdoll then
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end)

	local root = char:FindFirstChild("HumanoidRootPart")
	local bodyGyro = root and root:FindFirstChild("BodyGyro")

	if bodyGyro then
		bodyGyro.CFrame = root.CFrame
	end

	local ray = Ray.new(char.Torso.Position,Vector3.new(0,-50,0))
	local rPart,rPos,rNorm = workspace:FindPartOnRayWithIgnoreList(ray,{workspace.Live,workspace.Thrown,workspace.MonsterSpawns})
	if rPart then
		char.HumanoidRootPart.CFrame = CFrame.new(rPos)
		char.HumanoidRootPart.Anchored = true
		tracks["InGround"]:Play()
		Instance.new("Folder",char).Name = "Immortal"
	end	
end



module.die = function(char)
	if not char.MonsterInfo.Master.Value and not char:FindFirstChild("NoDrops") and not char:FindFirstChild("Summoned") then
		_G.DropBag("MonsterDrop", char.Variables.Drop.Value, char)
	end
	local castleRock = char.Variables.CastleRockSnake.Value

	local dustpart = game.ServerStorage.Assets.MonsterDeath:Clone()
	dustpart.Parent = workspace.Thrown
	dustpart.CFrame = char.Torso.CFrame
	dustpart.DeadCast:Play()
	dustpart.DUST1.EmissionDirection = "Front"
	dustpart.DUST2.EmissionDirection = "Front"
	dustpart.DUST3.EmissionDirection = "Front"
	game:GetService("Debris"):AddItem(dustpart,3)
	dustpart.DUST1:Emit(70)
	wait(.2)
	dustpart.DUST2:Emit(50)
	wait(.2)
	dustpart.DUST3:Emit(25)
	if castleRock then
		--game.ServerStorage.Requests.CROpen:Fire()
		local TweenService = game:GetService("TweenService")
		local tweenInfo01 = TweenInfo.new(6,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
		local tween02 = TweenService:Create(game.Workspace.ROCKGATE,tweenInfo01,{CFrame=game.Workspace.ROCKGATE.CFrame*CFrame.new(95,0,0)})
		tween02:Play()

		spawn(function()
			wait(16)
			game.Workspace.ROCKGATE.Open:Play()
			local tweenInfo01 = TweenInfo.new(6,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
			local tween02 = TweenService:Create(game.Workspace.ROCKGATE,tweenInfo01,{CFrame=game.Workspace.ROCKGATE.CFrame*CFrame.new(-95,0,0)})
			tween02:Play()
		end)
	end
	char:Destroy()	
end

module.colubrasKilled = function(char)
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


	for _,part in next,char:GetChildren() do
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

module.heat = function(char,live)
	for _,ochar in next, live do
		if ochar ~= char and ochar:FindFirstChild("HumanoidRootPart") and ochar:FindFirstChild("Humanoid") and ochar.Humanoid.Health > 0 then
			local dist = (char.HumanoidRootPart.Position - ochar.HumanoidRootPart.Position).Magnitude
			if dist < HEATING_DIST and not ochar:FindFirstChild("NearLava") then
				local tag = Instance.new("Folder")
				tag.Name = "NearLava"
				tag.Parent = ochar
				game.Debris:AddItem(tag,2)

				local enemyDanger = dangerHandler:getEntity(ochar)
				if enemyDanger then
					enemyDanger:createTag(char.Name,{lifespan=20})
				end
			end
		end
	end
end

module.isAnAlly = function(char,ochar,masterFolder)
	local hum = char.Humanoid
	local variables = char.Variables
	local monsterInfo = char.MonsterInfo
	local master = char.MonsterInfo.Master.Value

	if ochar == master then return true end

	if ochar:FindFirstChild("MonsterInfo") then
		if not (master and ochar:FindFirstChild("MonsterInfo") and ochar.MonsterInfo.Master.Value ~= master) then
			return true
		end		
	else
		if master and masterFolder and game.Players:GetPlayerFromCharacter(master).UserId == COLUBRAS then
			local cFolder = game.ServerStorage.PlayerData:FindFirstChild(ochar.Name)
			if cFolder then
				if masterFolder.Data.LastName.Value ~= "" and masterFolder.Data.LastName.Value == cFolder.Data.LastName.Value then
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

	local torso = char:FindFirstChild("Torso")
	local root = char:FindFirstChild("HumanoidRootPart")
	local bodyGyro = root and root:FindFirstChild("BodyGyro")

	local masterFolder = nil
	if master then
		masterFolder = game.ServerStorage.PlayerData:FindFirstChild(master.Name)
	end


	module.heat(char,live)

	if char:FindFirstChild("Action") then return end

	if variables.State.Value == "SLEEPING" then
		monsterInfo.Aggrod.Value = false
		module.FindTarget(char,true,live,tracks)
	elseif variables.State.Value == "AGGROD" then
		local target = variables.Target.Value
		local lastHitBy = variables.LastHitBy.Value

		monsterInfo.Aggrod.Value = true
		monsterInfo.LastAggrod.Value = tick()
		game.ServerStorage.Requests.ResetMonsterExpiration:Invoke(char)

		if target and target.Parent == workspace.Live and target ~= char and target.Parent and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and not target:FindFirstChild("Unconscious") and not module.isAnAlly(char,target,masterFolder) then
			local distanceToTarget = (target.Torso.Position - char.Torso.Position).Magnitude

			if not char:FindFirstChild("NoRotate") then
				if bodyGyro then
					local targetGyro = CFrame.new(Vector3.new(root.Position.X,target.Torso.Position.Y,root.Position.Z),target.Torso.Position)
					local tweenTime = 2
					if distanceToTarget > BREATH_RANGE and char:FindFirstChild("Attacking") and char.Attacking.Value == "Fireball" then
						tweenTime = 0.2
					end

					TweenService:Create(bodyGyro,TweenInfo.new(tweenTime,Enum.EasingStyle.Linear),{CFrame=targetGyro}):Play()
				else 
					--print("WHAT?????")
				end
			else 
				--print("NOROT!!!!!")
			end



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

			local rayOut = Ray.new((char.Head.CFrame - Vector3.new(0,char.Head.Size.Y * .45,0)).p,char.Head.CFrame.lookVector.unit*-6) -- THE HEAD IS ON BACKWARDS 
			local obscuring = game.Workspace:FindPartOnRayWithIgnoreList(rayOut,{game.Workspace.Live,game.Workspace.Thrown,game.Workspace.MonsterSpawns})
			if obscuring then
				hum.Jump = true
				local speedboost = Instance.new("IntValue")
				speedboost.Name = "WalkSpeedBoost"
				speedboost.Value = 15
				speedboost.Parent = char.Boosts
				game.Debris:AddItem(speedboost,0.3)
			end

			local rayOut = Ray.new((char.HumanoidRootPart.CFrame - Vector3.new(0,char.HumanoidRootPart.Size.Y * .45,0)).p,char.HumanoidRootPart.CFrame.lookVector.unit*8)
			local obscuring = game.Workspace:FindPartOnRayWithIgnoreList(rayOut,{game.Workspace.Live,game.Workspace.Thrown,game.Workspace.MonsterSpawns})
			if obscuring then
				hum.Jump = true
				local speedboost = Instance.new("IntValue")
				speedboost.Name = "WalkSpeedBoost"
				speedboost.Value = 15
				speedboost.Parent = char.Boosts
				game.Debris:AddItem(speedboost,0.3)
			end


			if distanceToTarget < CHASE_DISTANCE then
				local targDir = (target.Torso.Position - char.Torso.Position)
				if distanceToTarget < NO_CLOSER then
					module.Slither(char,false,tracks)
				else
					if distanceToTarget < SLOW_RANGE or char:FindFirstChild("Attacking") then
						module.Slither(char,true,tracks)
					else
						module.FastSlither(char,true,tracks)
					end

					if tick() - variables.LastMove.Value > 0.3 then
						variables.LastMove.Value = tick()
						targDir = targDir * Vector3.new(1,0,1)
						hum:Move(targDir)
					end
				end

				if distanceToTarget < SPIN_RANGE and not char:FindFirstChild("SpinCD") then
					module.Spin(char,tracks)
				elseif distanceToTarget < STRIKE_RANGE and not char:FindFirstChild("LungeCD") then
					module.Lunge(char,tracks)
				elseif distanceToTarget < BREATH_RANGE and distanceToTarget > BREATH_MIN and not char:FindFirstChild("BreathCD") then
					module.Firebreath(char,live,tracks)
				elseif distanceToTarget > NO_CLOSER and not char:FindFirstChild("FireballCD") then
					module.Fireball(char,tracks)
				end
			else
				module.FindTarget(char,false,live,tracks)
			end
		else
			module.FindTarget(char,false,live,tracks)
		end
	end
end

module.Spin = function(char,tracks)
	if char:FindFirstChild("Attacking") then return end
	if char:FindFirstChild("LungeCD") then return end

	local attacking = Instance.new("StringValue")
	attacking.Name = "Attacking"
	attacking.Value = "Spin"
	attacking.Parent = char

	local hum = char.Humanoid
	local variables = char.Variables
	local monsterInfo = char.MonsterInfo
	local master = char.MonsterInfo.Master.Value
	local root = char.HumanoidRootPart

	local track = tracks["Spin"]
	track:Play()

	coroutine.wrap(function()
		wait(0.75)
		local pkt = {fist=true, physical=true,damage=20,knockback=true}
		hitDetection.magnitudeCheck(char,root.Position,40,pkt,false,false,15)
		hitDetection.magnitudeCheck(char,root.Position,40,{mana=true,damage=0,burn=true},pkt,false,false,15)
		game.Debris:AddItem(attacking,.4)

		local cd = Instance.new("Folder")
		cd.Name = "SpinCD"
		cd.Parent = char
		game.Debris:AddItem(cd,8)
	end)()
end


module.Lunge = function(char,tracks)
	if char:FindFirstChild("Attacking") then return end
	if char:FindFirstChild("LungeCD") then return end

	local attacking = Instance.new("StringValue")
	attacking.Name = "Attacking"
	attacking.Value = "Lunge"
	attacking.Parent = char

	local hum = char.Humanoid
	local variables = char.Variables
	local monsterInfo = char.MonsterInfo
	local master = char.MonsterInfo.Master.Value
	local root = char.HumanoidRootPart

	local track = tracks["Lunge"]
	track:Play()

	coroutine.wrap(function()
		wait(1.2)
		if char:FindFirstChild("Head") then
		local pkt = {fist=true,physical=true,damage=20,blockbreak=true,knockback=true,noparry=true}
		hitDetection.magnitudeCheck(char,char.Head.Position,20,pkt,true)
		hitDetection.magnitudeCheck(char,char.Head.Position,20,{mana=true,damage=0,burn=true},pkt,true)
		game.Debris:AddItem(attacking,2)

		local cd = Instance.new("Folder")
		cd.Name = "LungeCD"
		cd.Parent = char
			game.Debris:AddItem(cd,8)
		end
	end)()
end

module.Fireball = function(char,tracks)
	if char:FindFirstChild("Attacking") then return end
	if char:FindFirstChild("FireballCD") then return end

	local attacking = Instance.new("StringValue")
	attacking.Name = "Attacking"
	attacking.Value = "Fireball"
	attacking.Parent = char

	local hum = char.Humanoid
	local variables = char.Variables
	local monsterInfo = char.MonsterInfo
	local master = char.MonsterInfo.Master.Value
	local root = char.HumanoidRootPart

	local track = tracks["Fireball"]
	track:Play()

	local nomove = Instance.new("Folder")
	nomove.Name = "NoMove"
	nomove.Parent = char

	coroutine.wrap(function()
		wait(2)
		local rootcf = char.HumanoidRootPart.CFrame

		local ball = script.Fireball:Clone()
		ball.CFrame = char.Head.CFrame * CFrame.new(0,0,5)
		ball.BodyVelocity.Velocity = rootcf.lookVector.unit * 150
		ball.Parent = workspace.Thrown
		ball:SetNetworkOwner(nil)
		ball.Firesound:Play()

		local cd = Instance.new("Folder")
		cd.Name = "FireballCD"
		cd.Parent = char
		game.Debris:AddItem(cd,5)

		nomove:Destroy()
		game.Debris:AddItem(attacking,1)

		local ten = nil

		ten = ball.Touched:Connect(function(hit)
			if hit and hit.Parent.Name == char.Name or hit and hit.Name == char.Name then return end
			if hit and  hit:IsDescendantOf(char) then return end
			if hit and hit.Name == ball.Name then return end

			local ehum = hit.Parent:FindFirstChild("Humanoid") or  hit.Parent.Parent:FindFirstChild("Humanoid")
			if ehum~=nil then
				if ehum.Parent.Name == char.Name then return end
			end

			ten:disconnect()

			ball.BodyVelocity:Destroy()
			ball.Anchored = true
			ball.Firesound2:Play()
			ball.Explosion:Emit(100)
			ball.Attachment:Destroy()
			ball.IllusionArm:Destroy()
			ball.IllusionArm2:Destroy()
			ball.IllusionArm3:Destroy()

			local tweenInfo02 = TweenInfo.new(.45,	Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tween02 = TweenService:Create(ball,tweenInfo02,{Size=Vector3.new(20,20,20),Transparency = 0.9})
			tween02:Play()

			local tweenInfo02 = TweenInfo.new(.45,	Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tween02 = TweenService:Create(ball.PointLight,tweenInfo02,{Range=30})
			tween02:Play()

			local pkt = {mana=true,damage=25,manaknockupself=true,burn=true}
			hitDetection.magnitudeCheck(char,ball.Position,25,pkt)

			coroutine.wrap(function()
				wait(.45)
				local tweenInfo02 = TweenInfo.new(.45,	Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				local tween02 = TweenService:Create(ball.PointLight,tweenInfo02,{Range=0})
				tween02:Play()
			end)()
			game:GetService("Debris"):AddItem(ball,2)
		end)

		wait(0.75)

		if ball and ball.Parent and ball:FindFirstChild("BodyVelocity") then
			ball.BodyVelocity:Destroy()
			ball.Anchored = true
			ball.Firesound2:Play()
			ball.Explosion:Emit(100)
			ball.Attachment:Destroy()
			ball.IllusionArm:Destroy()
			ball.IllusionArm2:Destroy()
			ball.IllusionArm3:Destroy()

			local tweenInfo02 = TweenInfo.new(.45,	Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tween02 = TweenService:Create(ball,tweenInfo02,{Size=Vector3.new(20,20,20),Transparency = 0.9})
			tween02:Play()

			local tweenInfo02 = TweenInfo.new(.45,	Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tween02 = TweenService:Create(ball.PointLight,tweenInfo02,{Range=30})
			tween02:Play()

			local pkt = {mana=true,damage=25,manaknockupself=true,burn=true}
			hitDetection.magnitudeCheck(char,ball.Position,25,pkt)

			coroutine.wrap(function()
				wait(.45)
				local tweenInfo02 = TweenInfo.new(.45,	Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				local tween02 = TweenService:Create(ball.PointLight,tweenInfo02,{Range=0})
				tween02:Play()
			end)()
			game:GetService("Debris"):AddItem(ball,2)
		end
	end)()
end

module.Firebreath = function(char,live,tracks)
	if char:FindFirstChild("Attacking") then return end
	if char:FindFirstChild("BreathCD") then return end

	local attacking = Instance.new("StringValue")
	attacking.Name = "Attacking"
	attacking.Value = "Fireball"
	attacking.Parent = char

	local hum = char.Humanoid
	local variables = char.Variables
	local monsterInfo = char.MonsterInfo
	local master = char.MonsterInfo.Master.Value
	local root = char.HumanoidRootPart

	local track = tracks["Firebreath"]
	track:Play()

	local nomove = Instance.new("Folder")
	nomove.Name = "NoMove"
	nomove.Parent = char

	task.delay(1.5, function()
		local attachPoint = char:FindFirstChild("Head")
		if not attachPoint then
			char:Destroy()
			return
		end

		local norot = Instance.new("Folder")
		norot.Name = "NoRotate"
		norot.Parent = char


		local bigLoopFire = script.BigLoopFire:clone()
		bigLoopFire.Parent = root
		bigLoopFire:Play()

		local bal = script.BurnSpell:Clone()
		bal.Parent = workspace.Thrown

		bal.Hit:Play()

		local w = Instance.new("Weld")
		w.Name = "Weld"
		w.Part0 = attachPoint
		w.Part1 = bal
		w.Parent = bal
		w.C0 = CFrame.new()	

		local start_t = tick()

		while char and char.Parent and tick() - start_t < 1.5 and char:FindFirstChild("Head") do
			wait()

			local dotAngle = math.rad(15)

			local breathDirection = char.Head.CFrame.lookVector * -1
			local breathOrigin = char.Head.Position
			local castTo = {}

			for _,ch in pairs(live) do
				if ch ~= char and ch:IsA("Model") then
					local hum = ch and ch:FindFirstChild("Humanoid")
					local hrp = hum and hum.RootPart
					if hrp and not ch:FindFirstChild("Stun") and not ch:FindFirstChild("NoDam") then
						if not ch:FindFirstChild("BurnCooldown") then
							local rootPos = hrp.Position
							local direc = rootPos - breathOrigin

							if math.acos(breathDirection:Dot(direc.unit)) <= dotAngle then
								if direc.magnitude < 60 then
									table.insert(castTo,ch)
								end
							elseif (rootPos-breathOrigin).magnitude < 2 then
								table.insert(castTo,ch)
							end
						end
					end
				end
			end

			for i,v in pairs(workspace.Destructibles:children()) do
				if (char.HumanoidRootPart.Position-v.Position).Magnitude < 13 then
					game.ServerStorage.Requests.WorldInteraction:Fire("GreaterFire",v)
				end
			end

			for _,ch in pairs(castTo) do
				--tagHumanoid:Fire(char,ch,{mana=true,damage=10,manaknockup=true,curse=true,burn=true})	
				tagHumanoid:Fire(char, ch, {
					mana = true, 
					manaknockupself = true, 
					burn = true, 
					curse = true, 
					damage = 10
				})
				local r = Instance.new("Folder")
				r.Name = "BurnCooldown"
				r.Parent = ch
				game:GetService("Debris"):AddItem(r,.5)
			end

			castTo = nil
		end

		game.Debris:AddItem(attacking,1)
		game.Debris:AddItem(nomove,1)
		game.Debris:AddItem(norot,1)

		bal.ParticleEmitter.Enabled = false
		bigLoopFire:Destroy()
		bal.SpotLight.Enabled = false
		bal.PointLight.Enabled = false
		game.Debris:AddItem(bal,1.5)

		local cd = Instance.new("Folder")
		cd.Name = "BreathCD"
		cd.Parent = char
		game.Debris:AddItem(cd,10)
	end)
end

module.FindTarget = function(char,sleeping,live,tracks)
	if char:FindFirstChild("AggroCD") then return end
	local master = char.MonsterInfo.Master.Value
	local masterFolder = nil
	if master then
		masterFolder = game.ServerStorage.PlayerData:FindFirstChild(master.Name)
	end

	local hum = char.Humanoid
	local variables = char.Variables

	local closest = nil
	local closestDistance = nil
	for _,enemy in pairs(live)do
		if enemy ~= char and enemy:FindFirstChild("Torso") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then			
			if not module.isAnAlly(char,enemy,masterFolder) then
				if enemy:FindFirstChild("HumanoidRootPart") then
				local ray = Ray.new(char.HumanoidRootPart.Position,char.HumanoidRootPart.Position-enemy.HumanoidRootPart.Position)
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
		variables.State.Value = "AGGROD"
		variables.Target.Value = closest

		if sleeping then
			for _,track in pairs(hum:GetPlayingAnimationTracks())do
				if track.Name == "InGround" then
					track:Stop()
					track:Destroy()
				end
			end

			tracks["ComeOut"]:Play()

			local f = Instance.new("Folder")
			f.Name = "Action"
			f.Parent = char
			game.Debris:AddItem(f,1)

			task.delay(.6, function()
				char.Torso.CFrame = char.Torso.CFrame + Vector3.new(0,5,0)
				char.HumanoidRootPart.Anchored = false
				if char:FindFirstChild("Immortal") then char.Immortal:Destroy() end	
			end)
		end
	else
		-- DIVE
		if not sleeping then
			local ray = Ray.new(char.Torso.Position,Vector3.new(0,-10,0))
			local rPart,rPos,rNorm = workspace:FindPartOnRayWithIgnoreList(ray,{workspace.Live,workspace.Thrown,workspace.MonsterSpawns,workspace:FindFirstChild("AreaMarkers")})
			if rPart then

				local f = Instance.new("Folder")
				f.Name = "AggroCD"
				f.Parent = char
				game.Debris:AddItem(f, 3)

				task.spawn(function()
					variables.State.Value = "SLEEPING"
					char.MonsterInfo.Aggrod.Value = false
					char.HumanoidRootPart.Anchored = true
					tracks["Dive"]:Play()
					Instance.new("Folder",char).Name = "Immortal"
					wait(2.1)
					tracks["InGround"]:Play()
				end)
			end
		end
	end
end

module.Slither = function(char,onoff,tracks)
	local hum = char.Humanoid

	if onoff then
		if char:FindFirstChild("Sprinting") then char.Sprinting:Destroy() end

		tracks["Slither"]:AdjustSpeed(1)
		if not tracks["Slither"].IsPlaying then
			tracks["Slither"]:Play()
		end
	else
		if char:FindFirstChild("Sprinting") then char.Sprinting:Destroy() end

		tracks["Slither"]:Stop()
	end
end

module.FastSlither = function(char,onoff,tracks)
	local hum = char.Humanoid

	if onoff then
		if char:FindFirstChild("Sprinting") then return end

		local sprintingTag = Instance.new("Folder")
		sprintingTag.Name = "Sprinting"
		sprintingTag.Parent = char

		tracks["Slither"]:AdjustSpeed(1.5)
		if not tracks["Slither"].IsPlaying then
			tracks["Slither"]:Play()
		end
	else
		if char:FindFirstChild("Sprinting") then char.Sprinting:Destroy() end
		tracks["Slither"]:Stop()
	end
end

return module
