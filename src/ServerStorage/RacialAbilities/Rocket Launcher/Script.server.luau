local HitDetection = require(game.ServerScriptService.Modules.HitDetection)
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end

local COOLDOWN = 20
local SPEED = 80
local EXPLOSION_RADIUS = 12
local TIMEOUT = 3

script.Parent.Activated:Connect(function()
	local char = script.Parent.Parent
	local player = game.Players:GetPlayerFromCharacter(char)
	local data = player and game.ServerStorage.PlayerData:FindFirstChild(player.Name)
	if not data or not (data.Ascended.Value == true and data.Race.Value == "Gaian") then
		return
	end

	if ActionCheck(char) then
		return
	end
	if char.Cooldowns:FindFirstChild("Rocket Launcher") then
		return
	end

	local mouse = _G.MouseData(player)
	if not mouse or not mouse.Hit then
		return
	end

	local CD = Instance.new("NumberValue")
	CD.Name = "Rocket Launcher"
	CD.Value = COOLDOWN
	CD.Parent = char.Cooldowns
	game.Debris:AddItem(CD, COOLDOWN)

	local origin = char.HumanoidRootPart.Position
	local aimPoint = mouse.Hit.p
	
	local Anim = char.Humanoid:LoadAnimation(script.Parent.BreathCharge):Play()
	script.Parent.Start:Play()

	local rocket = Instance.new("Part")
	rocket.Name = "GaianRocket"
	rocket.Shape = Enum.PartType.Cylinder
	rocket.BrickColor = BrickColor.new("Medium stone grey")
	rocket.Material = Enum.Material.Metal
	rocket.Size = Vector3.new(2, 0.8, 0.8)
	rocket.CanCollide = false
	rocket.Anchored = false
	rocket.CFrame = CFrame.new(origin, aimPoint) * CFrame.Angles(0, math.rad(90), 0)
	rocket.Parent = workspace.Thrown
	rocket:SetNetworkOwner(nil)

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bv.Velocity = CFrame.new(origin, aimPoint).LookVector * SPEED
	bv.Parent = rocket

	local exploded = false
	local function explode()
		if exploded then
			return
		end
		exploded = true
		bv:Destroy()
		rocket.Anchored = true
		HitDetection.magnitudeCheck(char, rocket.Position, EXPLOSION_RADIUS, {
			damage = 25,
			physical = true,
			blockbreak = true,
			knockback = true,
			noenchant = true,
			move = "Rocket Launcher",
		}, false, true)
		local explosion = Instance.new("Explosion")
		explosion.Position = rocket.Position
		explosion.BlastRadius = 0
		explosion.BlastPressure = 0
		explosion.Parent = workspace
		game.Debris:AddItem(rocket, 2)
	end

	rocket.Touched:Connect(function(hit)
		if hit:IsDescendantOf(char) or hit:IsDescendantOf(workspace.Terrain) then
			return
		end
		explode()
	end)
	task.delay(TIMEOUT, explode)
	game.Debris:AddItem(rocket, 5)
end)
