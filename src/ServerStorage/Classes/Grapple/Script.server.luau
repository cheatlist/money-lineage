local play = script.Parent.Parent.Parent
local char = play.Character

local TweenService = game:GetService("TweenService")
local shinobiModule = require(game.ServerScriptService.ShinobiModule)



local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
		healthBelow = 1,
	})
end

local function create(name,deletetime,parent)
	if (name == "Knocked" or name == "Unconscious") and (parent:FindFirstChild("WakingUp") or game.CollectionService:HasTag(parent, "GettingUp")) then
		return
	end
	local i = Instance.new("Accessory")
	i.Name = name
	i.Parent = parent
	if (name == "Knocked" and game.Players:FindFirstChild(parent.Name)) and game.ServerStorage.PlayerData[parent.Name].Injuries.Value:find("BrokenRib") then
		if deletetime then
			game.Debris:AddItem(i, deletetime * 1.25)
		end
		for i,v in pairs(parent:GetChildren()) do
			if v.Name == "Knocked" then
				if deletetime then
					game.Debris:AddItem(v, deletetime * 1.25)
				end
			end
		end
	elseif name == "Knocked" then
		if deletetime then
			game.Debris:AddItem(i, deletetime)
		end
		for i,v in pairs(parent:GetChildren()) do
			if v.Name == "Knocked" then
				if deletetime then
					game.Debris:AddItem(v, deletetime)
				end
			end
		end
	else
		if deletetime then
			game.Debris:AddItem(i, deletetime)
		end
	end
	return i
end

local HEIGHT = Vector3.new(0, 50, 0)
local HIGHER_RANGE = 10 --height to be considered grappling a lower player
local GRAPPLE_TIME_1 = 0.2 --cord appear time
local GRAPPLE_TIME_2 = 0.5 --velocity duration <<CAN'T REALLY CHANGE THIS B/C VELOCITIES ARE WEIRD>>
local GRAPPLE_TIME = GRAPPLE_TIME_1 + GRAPPLE_TIME_2
local DEBRIS_TIME = GRAPPLE_TIME + 0.3


local RANGE = 100
local UBER_RANGE_MULTIPLIER = 1.25
local UBER_AUTOTARGET_RANGE = 10

local UBER_COOLDOWN = 2.5 - GRAPPLE_TIME
local GRAPPLING_WALL_EXTRA_COOLDOWN = 1 --cooldown if grappling non-player (running away)
local ULTRA_COOLDOWN = 6 - GRAPPLE_TIME
local ULTRA_INJURED_COOLDOWN = 8 - GRAPPLE_TIME

local GRAPPLE_IMMUNITY = 5 --cooldown before a player can be (ground) grappled again (by any shinobi)
local AIR_GRAPPLE_EXTRA_COOLDOWN = 2 --longer cooldown for air grappling [an enemy player]


local en = true

script.Parent.Activated:Connect(function()
	local root = char:FindFirstChild("HumanoidRootPart")
	
	if en == false then return end
	if char.Cooldowns:FindFirstChild("Grapple") then
		return
	end

	if ActionCheck(char) then return end

	if char:FindFirstChild("REPAIRING") then return end

	en = false

	local mouse
	pcall(function()
		mouse = require(game.ServerStorage.Modules.RemoteLib).getMousenew(play)
	end)

	if not (mouse and mouse.Target) then en = true return end

	local range = RANGE
	local mastery = play.Backpack:FindFirstChild("Daisho")

	if mastery then
		range = range*UBER_RANGE_MULTIPLIER
	end

	if char:FindFirstChild("Grabbing") then
		range = range/3
	end

	local bestTarget

	for i, v in pairs (workspace.Live:GetChildren()) do
		if mouse.Target:IsDescendantOf(v) then
			bestTarget = v
		end
	end

	local lowest = math.huge
	if mastery and not bestTarget then --autotargets players near mouse if uber shinobi
		for i,v in pairs(game.Workspace.Live:GetChildren()) do
			local vhum = v:FindFirstChild("Humanoid")
			local vhrp = vhum and vhum.RootPart
			local canBeAttacked = vhum.Health >= 0 and not game.CollectionService:HasTag(v,"Unconscious") and not v:FindFirstChildOfClass("ForceField")
			if v ~= char and vhrp and canBeAttacked then
				local mag = (mouse.Hit.Position-vhrp.Position).magnitude
				if mag <= UBER_AUTOTARGET_RANGE then
					if not v:FindFirstChild("MonsterInfo") or (v:FindFirstChild("MonsterInfo") and v.MonsterInfo.Master.Value == nil) then
						bestTarget = v
						if mag < lowest then
							local cf = CFrame.new(root.Position,vhrp.Position)
							local ray = Ray.new(root.Position,cf.LookVector*mag)
							local hit,pos,nor = workspace:FindPartOnRayWithIgnoreList(ray,{workspace.Live,workspace.Thrown,workspace.Destructibles,workspace.MonsterSpawns})
							if not hit then
								bestTarget = v
								lowest = mag
							end
						end
					end	
				end
			end
		end
	end

	local hasTarget = mouse.Target and (
		bestTarget
			or mouse.Target:FindFirstChild("Humanoid")
			or (mouse.Target.Parent and mouse.Target.Parent:FindFirstChild("Humanoid"))
	)

	if (mouse.Hit.p-char.HumanoidRootPart.Position).magnitude >= range --out of range
		or (mouse.Hit.p.y<char.HumanoidRootPart.Position.y+HIGHER_RANGE and not hasTarget) then 
		--targeting ground that is not high enough
		en = true
		return
	end

	game.ReplicatedStorage.Requests.ClearDodgeVels:FireClient(play)

	en = false

	local higher = mastery and (char.HumanoidRootPart.Position.Y - mouse.Hit.p.Y) > HIGHER_RANGE --uber can air grapple below  

	if higher or not (bestTarget and bestTarget:FindFirstChild("GrapplePulled")) then 
		--grapple fails if target was grappled recently
		--ignores above if its an air grapple

		local anim = char.Humanoid:LoadAnimation(script.Parent.Animation)
		anim:Play()
		if not mastery then --uber slightly faster
			task.wait(0.1) --extra reaction time
		end
		char.HumanoidRootPart.Grapple:Play()
		shinobiModule.Change(play)
	else
		task.wait(0.1)
		en = true
		return	
	end

	local grapple1 = game.ServerStorage.Assets.Grapple.Attachment1:Clone()
	grapple1.Parent = char["Left Arm"]

	if bestTarget then --attempt to grapple a player
		local eroot = bestTarget.HumanoidRootPart

		local grapple2 = game.ServerStorage.Assets.Grapple.Attachment2:Clone()
		grapple2.Parent = bestTarget.Torso

		local cord = game.ServerStorage.Assets.Grapple.Cord:Clone()
		cord.Parent = char["Left Arm"]
		cord.Attachment0 = grapple1
		cord.Attachment1 = grapple2

		game.ServerStorage.Debris:Fire(cord,GRAPPLE_TIME)
		game.ServerStorage.Debris:Fire(grapple1,GRAPPLE_TIME)
		game.ServerStorage.Debris:Fire(grapple2,GRAPPLE_TIME)

		if not mastery then
			task.wait(GRAPPLE_TIME_1) 
		end

		local failure = bestTarget:FindFirstChild("Blocking") or bestTarget:FindFirstChildOfClass("ForceField")

		local bodyvel = Instance.new("BodyVelocity")
		game.ServerStorage.Debris:Fire(bodyvel,DEBRIS_TIME)--safety incase of lag
		game.CollectionService:AddTag(bodyvel,"AllowedBM")
		bodyvel.Name = "GrappleVelocity"	
		bodyvel.MaxForce = Vector3.new(1e6,1e6,1e6)

		if failure then --get flung a bit
			local dist = (eroot.Position - root.Position)
			local magnitude = dist.magnitude

			bodyvel.Velocity = HEIGHT/2+dist*(1/GRAPPLE_TIME_2-magnitude/range+0.25)
			bodyvel.Parent = root

			game.CollectionService:AddTag(char,"grappleblocked")

			if mastery then 
				create("Knocked", 1.25, char)
				spawn(function()
					task.wait(2.25)
					game.CollectionService:RemoveTag(char,"grappleblocked")
				end)
			else 
				create("Knocked", 1.75, char)
				spawn(function()
					task.wait(2.75)
					game.CollectionService:RemoveTag(char,"grappleblocked")
				end)
			end
		else --successfully grapple onto a person	
			local immunity = Instance.new("Accessory", bestTarget)
			immunity.Name = "GrapplePulled"
			game.ServerStorage.Debris:Fire(immunity, GRAPPLE_IMMUNITY)

			--pulls the enemy up if the player is higher,
			--take note of the higher and x statements

			local dist = higher and (root.Position - eroot.Position) or (eroot.Position - root.Position)		
			local magnitude = dist.magnitude

			bodyvel.Velocity = (higher and HEIGHT/2 or HEIGHT)+dist*(1/GRAPPLE_TIME_2-magnitude/range)
			bodyvel.Parent = higher and eroot or root

			if not bestTarget:FindFirstChild("Immortal") then
				local newbodyvel = Instance.new("BodyVelocity")
				game.CollectionService:AddTag(newbodyvel,"AllowedBM")
				newbodyvel.MaxForce = Vector3.new(1e6,1e6,1e6)
				newbodyvel.Velocity = HEIGHT
				newbodyvel.Parent = higher and root or bestTarget.HumanoidRootPart
				game.ServerStorage.Debris:Fire(newbodyvel,GRAPPLE_TIME_2)
			end

			local f = Instance.new("Accessory")
			f.Name = "AIRSLASH"
			f.Parent = bestTarget
			game.ServerStorage.Debris:Fire(f,DEBRIS_TIME)

			local g = Instance.new("Accessory")
			g.Name = "Grappled" 
			g.Parent = char
			game.ServerStorage.Debris:Fire(g,DEBRIS_TIME)
		end

		task.wait(GRAPPLE_TIME_2)
		bodyvel:Destroy()

		if higher then task.wait(AIR_GRAPPLE_EXTRA_COOLDOWN) end
	else --onto a wall or something

		local cordpart = Instance.new("Part")
		cordpart.Transparency = 1
		cordpart.Anchored = true
		cordpart.CanCollide = false
		cordpart.CFrame = char.HumanoidRootPart.CFrame*CFrame.new(0,0,-2)
		cordpart.Parent = game.Workspace.Thrown

		local tweenInfo02 = TweenInfo.new(GRAPPLE_TIME_1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
		local tween03 = TweenService:Create(cordpart,tweenInfo02,{CFrame=CFrame.new(mouse.Hit.p)})
		tween03:Play()

		local grapple2 = game.ServerStorage.Assets.Grapple.Attachment2:Clone()
		grapple2.Parent = cordpart

		local cord = game.ServerStorage.Assets.Grapple.Cord:Clone()
		cord.Parent = char["Left Arm"]
		cord.Attachment0 = grapple1
		cord.Attachment1 = grapple2

		game.ServerStorage.Debris:Fire(cord,GRAPPLE_TIME)
		game.ServerStorage.Debris:Fire(grapple1,GRAPPLE_TIME)
		game.ServerStorage.Debris:Fire(grapple2,GRAPPLE_TIME)
		game.ServerStorage.Debris:Fire(cordpart,GRAPPLE_TIME)

		if not mastery then
			task.wait(GRAPPLE_TIME_1)
		end

		local bodyvel = Instance.new("BodyVelocity")
		game.ServerStorage.Debris:Fire(bodyvel,DEBRIS_TIME)--safety incase of lag
		game.CollectionService:AddTag(bodyvel,"AllowedBM")
		bodyvel.Name = "GrappleVelocity"
		bodyvel.Parent = root
		bodyvel.MaxForce = Vector3.new(1e6,1e6,1e6)

		local dist = (mouse.Hit.p - char.HumanoidRootPart.Position) 
		local magnitude = dist.magnitude
		bodyvel.Velocity = HEIGHT+dist*(1/GRAPPLE_TIME_2-magnitude/range)+0.25*dist*Vector3.new(1,0,1)
		task.wait(GRAPPLE_TIME_2)
		bodyvel:Destroy()

		task.wait(GRAPPLING_WALL_EXTRA_COOLDOWN)
	end
	
	en = true

	if mastery then
		local CD = Instance.new("NumberValue")
		CD.Name = "Grapple"
		CD.Value = UBER_COOLDOWN
		CD.Parent = char.Cooldowns
		game.Debris:AddItem(CD, UBER_COOLDOWN)
	else
		if char.Humanoid.Health < char.Humanoid.MaxHealth/2 then
			local CD = Instance.new("NumberValue")
			CD.Name = "Grapple"
			CD.Value = ULTRA_INJURED_COOLDOWN
			CD.Parent = char.Cooldowns
			game.Debris:AddItem(CD, ULTRA_INJURED_COOLDOWN)
		else
			local CD = Instance.new("NumberValue")
			CD.Name = "Grapple"
			CD.Value = ULTRA_COOLDOWN
			CD.Parent = char.Cooldowns
			game.Debris:AddItem(CD, ULTRA_COOLDOWN)
		end
	end
end)