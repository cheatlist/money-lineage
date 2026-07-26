local tool = script.Parent
local play = script.Parent.Parent.Parent
local char = play.Character

local hitDetection = require(game.ServerScriptService.Modules.HitDetection)
local tagHumanoid = game.ServerStorage.Requests.TagHumanoid
local shinobiModule = require(game.ServerScriptService.ShinobiModule)

local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
		healthBelow = 1,
	})
end

local ts = game:GetService("TweenService")
local en = true
local en2 = true
local tool = script.Parent

function groundDistance()
	local ray = Ray.new(char.HumanoidRootPart.Position,Vector3.new(0,-50,0))
	local bHit,bPos,bNor = workspace:FindPartOnRayWithIgnoreList(ray,{workspace.Live,workspace.Terrain,workspace.Thrown})
	return (char.HumanoidRootPart.Position.y-bPos.y)
end

local MIN_HEIGHT = 15
local CHECKS = 5
local RUSH_SPEED = 125

local AWAKENED_COOLDOWN = 3
local UBER_COOLDOWN = 5
local ULTRA_COOLDOWN = 8

local RUSH_PKT = {physical=true,slash=true,damage=10,dagger=true,nobackstab=true,move = "Shadowrush"}

function hitCheck(forwardRange)
	for i, v in pairs(game.Workspace.Live:GetChildren()) do
		if v ~= char then
			local enemy = v
			local cfdiff = (char.HumanoidRootPart.CFrame:inverse()*enemy.HumanoidRootPart.CFrame)
			if cfdiff.Z < 14 and cfdiff.Z > -forwardRange and math.abs(cfdiff.X) < 7 and math.abs(cfdiff.Y) < 7 then
				tagHumanoid:Fire(char,v,RUSH_PKT)
				return true
			end
		end
	end
end

tool.Activated:Connect(function()
	if ActionCheck(char) then return end
	if game.CollectionService:HasTag(char,"grappleblocked") then return end
	if game.CollectionService:HasTag(char,"Knocked") then return end

	local aerial = play.Backpack:FindFirstChild("ShadowrushAerialAllow")
	if aerial then
		if char.Cooldowns:FindFirstChild("Shadowrush Aerial") or en2 == false then return end
	else
		if char.Cooldowns:FindFirstChild("Shadowrush") or en == false then return end
	end

	if char.Humanoid.Jumping == true then return end

	local mastery = play.Backpack:FindFirstChild("Daisho")

	if not aerial and groundDistance(char.HumanoidRootPart) < MIN_HEIGHT then
		local CD = Instance.new("NumberValue")
		CD.Name = "Shadowrush"
		if char:FindFirstChild("ShinobiAwakening") then
			CD.Value = AWAKENED_COOLDOWN
			CD.Parent = char.Cooldowns
			game.Debris:AddItem(CD, AWAKENED_COOLDOWN)
		else
			if mastery then
				CD.Value = UBER_COOLDOWN
				CD.Parent = char.Cooldowns
				game.Debris:AddItem(CD, UBER_COOLDOWN)
			else
				CD.Value = ULTRA_COOLDOWN
				CD.Parent = char.Cooldowns
				game.Debris:AddItem(CD, ULTRA_COOLDOWN)
			end
		end

		local f1 = Instance.new("Accessory")
		f1.Name = "Action"
		f1.Parent = char
		game.ServerStorage.Debris:Fire(f1,0.5)

		local f2 = Instance.new("Accessory")
		f2.Name = "NoJump"
		f2.Parent = char
		game.ServerStorage.Debris:Fire(f2,0.5)

		local root = char.HumanoidRootPart
		local hum = char.Humanoid

		game.ReplicatedStorage.Requests.ClearDodgeVels:FireClient(play)

		local anim = hum:LoadAnimation(script.Animation)
		anim:Play()
		root.ShadowrushCharge:Play() 
		task.wait(0.1) --very brief charging animation

		local velocity = Instance.new("BodyVelocity")
		game.CollectionService:AddTag(velocity,"AllowedBM")
		velocity.MaxForce = Vector3.new(8e4,0,8e4)
		velocity.Velocity = char.HumanoidRootPart.CFrame.lookVector.unit * RUSH_SPEED 
		velocity.Parent = char.HumanoidRootPart
		game.ServerStorage.Debris:Fire(velocity,anim.Length)

		local hit = false
		local oPos = root.Position
		local oTime = tick()

		local speed = (root.Position - oPos).Magnitude
		while (root.Position - oPos).Magnitude < 2 and tick() - oTime < 0.3 and not hit do
			oPos = root.Position
			hit = hitCheck((tick() - oTime) < 0.1 and 15 or 20)
			task.wait(1/30)
		end
		while (root.Position - oPos).Magnitude > 2 and tick() - oTime < 0.5 and not hit do
			oPos = root.Position
			hit = hitCheck(20)
			task.wait(1/30)
		end

		velocity:Destroy()

		if not hit then 
			hit = hitCheck(10)
		end

		if hit then --vault into the air
			shinobiModule.Change(play)

			local boost = Instance.new("BodyVelocity")
			game.CollectionService:AddTag(boost,"AllowedBM")
			boost.maxForce = Vector3.new(math.huge, math.huge, math.huge)

			local dir = root.CFrame.LookVector.Unit

			boost.velocity = Vector3.new(0, 100, 0) - dir * 25
			boost.Parent = root
			game.ServerStorage.Debris:Fire(boost,.20)

			local anim = hum:LoadAnimation(script.Animation2)
			anim:Play()

			local f = Instance.new("Accessory")
			f.Name = "Action"
			f.Parent = char
			game.ServerStorage.Debris:Fire(f,anim.Length)

			root.Shadowrush:Play()

			local partic = script.Feathers:Clone()
			partic.Parent = char.Torso
			game.ServerStorage.Debris:Fire(partic,5)
			partic.Rate = 0
			partic:Emit(25)
		end
		
		en = true
	elseif aerial then
		if groundDistance(char.HumanoidRootPart) > MIN_HEIGHT then
			en2 = false
			aerial:Destroy()

			local f = Instance.new("Accessory")
			f.Name = "Action"
			f.Parent = char
			game.ServerStorage.Debris:Fire(f,0.75)

			local grappleVel = char.HumanoidRootPart:FindFirstChild("GrappleVelocity")
			if grappleVel then
				grappleVel:Destroy()
			end

			game.ReplicatedStorage.Requests.ClearDodgeVels:FireClient(play)

			local velocity = Instance.new("BodyVelocity")
			game.ServerStorage.Debris:Fire(velocity, 1)
			game.CollectionService:AddTag(velocity,"AllowedBM")
			velocity.MaxForce = Vector3.new(8e4,8e4,8e4)
			velocity.Velocity = char.HumanoidRootPart.CFrame.lookVector.unit * 100 + Vector3.new(0, -125, 0)
			velocity.Parent = char.HumanoidRootPart

			local partic = script.Feathers:Clone()
			partic.Parent = char.Torso
			game.ServerStorage.Debris:Fire(partic,5)

			local pkt = {physical=true,slash=true,damage=6,dagger=true,nobackstab=true,move = "Shadowrush"}
			local anim = char.Humanoid:LoadAnimation(script.Animation3)
			local spins = 0
			while spins < 4 and groundDistance(char.HumanoidRootPart) > MIN_HEIGHT do
				anim:Play()
				char.HumanoidRootPart.FlyingAssaulter:Play()
				task.wait(0.1)
				hitDetection.magnitudeCheck(char,char.HumanoidRootPart.Position,15,pkt,false)
				spins = spins + 1
			end

			velocity:Destroy()
			partic.Rate = 0
			partic:Emit(25)

			hitDetection.magnitudeCheck(char,char.HumanoidRootPart.Position,15,pkt,false)

			en2 = true
			
			local CD = Instance.new("NumberValue")
			CD.Name = "Shadowrush Aerial"
			CD.Value = 1.5
			CD.Parent = char.Cooldowns
			game.Debris:AddItem(CD, 1.5)
		end
	end
end)

