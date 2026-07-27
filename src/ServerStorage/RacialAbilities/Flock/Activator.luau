local v1 = {}
local l__Parent__2 = script.Parent
function ActionCheck(p1)
	if not p1:FindFirstChild("Humanoid") then
		return true
	end
	if p1:FindFirstChild("Stun") then
		return true
	end
	if p1:FindFirstChild("ReturnStun") then
		return true
	end
	if p1:FindFirstChild("Action") then
		return true
	end
	if p1:FindFirstChild("Blocking") then
		return true
	end
	if p1:FindFirstChild("SpellBlocking") then
		return true
	end
	if p1.Humanoid.Health == 0 then
		return true
	end
	if not p1:FindFirstChild("Grabbed") then
		if p1:FindFirstChild("Grabbing") then
			return true
		end
	else
		return true
	end
	if p1:FindFirstChild("Climbing") then
		return true
	end
	if p1:FindFirstChild("ActiveCast") then
		return true
	end
	if p1:FindFirstChild("Unconscious") then
		return true
	end
	if p1:FindFirstChild("Knocked") then
	else
		return
	end
	return true
end

local TagHumanoidEvent = game.ServerStorage.Requests.TagHumanoid

local function isAscendedMorvid(data)
	return data ~= nil and data.Ascended.Value == true and data.Race.Value == "Morvid"
end

local function getPlayerData(character)
	local player = game.Players:GetPlayerFromCharacter(character)
	return player and game.ServerStorage.PlayerData:FindFirstChild(player.Name)
end

-- Clones the crow-swarm particles/sounds this move already uses in M1 onto whichever
-- HumanoidRootPart is passed in - the caster's own for vanilla Flock, or the M2 swarm
-- target's for Ascended Morvid's Flock M2 (see v1.Active2 below).
local function playFlockVfx(rootPart)
	local v4 = script.Sound1:Clone()
	v4.Parent = rootPart
	v4:Play()
	game:GetService("Debris"):AddItem(v4, 4)
	local v5 = script.Sound2:Clone()
	v5.Parent = rootPart
	v5:Play()
	game:GetService("Debris"):AddItem(v5, 4)
	for v9,v10 in pairs(game.ServerStorage.CrowParticles:GetChildren())do
		if v10.Name:match("Emit") then
			local v11 = v10:Clone()
			v11.Parent = rootPart
			v11.Enabled = true
			game:GetService("Debris"):AddItem(v11, 4)
			spawn(function()
				wait(0.5)
				v11.Enabled = false
			end)
		end
		if v10.Name:match("Return") then
			spawn(function()
				wait(2)
				local v12 = v10:Clone()
				v12.Parent = rootPart
				v12.Enabled = true
				game:GetService("Debris"):AddItem(v12, 4)
				wait(0.5)
				v12.Enabled = false
			end)
		end
	end
end

local PROXIMITY_RADIUS = 8
local PROXIMITY_STEAL_PERCENT = 0.05

-- Ascended-Morvid-only: while mid-Flock M1 dash (NOT M2's swarm - see v1.Active2 below),
-- getting within PROXIMITY_RADIUS of any other player cancels the effect early - the Morvid
-- is made visible immediately (via onCancelled), the player who got close is knocked back,
-- and 5% of their max health is stolen (they lose it, the Morvid gains it).
local function watchFlockProximity(caster, duration, onCancelled)
	local watch = {Cancelled = false}
	spawn(function()
		local elapsed = 0
		while elapsed < duration do
			if not caster or not caster.Parent or not caster:FindFirstChild("HumanoidRootPart") then
				return
			end
			for _,plr in pairs(game.Players:GetPlayers()) do
				local char = plr.Character
				if char and char ~= caster and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
					if (char.HumanoidRootPart.Position - caster.HumanoidRootPart.Position).Magnitude <= PROXIMITY_RADIUS then
						watch.Cancelled = true
						local dir = char.HumanoidRootPart.Position - caster.HumanoidRootPart.Position
						if dir.Magnitude == 0 then
							dir = Vector3.new(0, 0, 1)
						end
						local knock = Instance.new("BodyVelocity")
						knock.Name = "AllowedBM"
						knock.MaxForce = Vector3.new(100000, 100000, 100000)
						knock.Velocity = dir.Unit * 60 + Vector3.new(0, 20, 0)
						knock.Parent = char.HumanoidRootPart
						game:GetService("Debris"):AddItem(knock, 0.3)
						local stolen = char.Humanoid.MaxHealth * PROXIMITY_STEAL_PERCENT
						char.Humanoid.Health = math.max(char.Humanoid.Health - stolen, 1)
						local casterHumanoid = caster:FindFirstChild("Humanoid")
						if casterHumanoid then
							casterHumanoid.Health = math.min(casterHumanoid.Health + stolen, casterHumanoid.MaxHealth)
						end
						if onCancelled then
							onCancelled()
						end
						return
					end
				end
			end
			task.wait(0.1)
			elapsed += 0.1
		end
	end)
	return watch
end

local v3 = Instance.new("NumberValue")
v3.Name = "Transparency"
v3.Value = 1
v3.Parent = l__Parent__2
local u1 = true
local l__PhysicsService__2 = game:GetService("PhysicsService")
local l__TweenService__3 = game:GetService("TweenService")
function v1.Active(p2, p3, p4, p5)
	if ActionCheck(p2) then
		return
	end
	if u1 == false then
		return
	end
	if p2.Cooldowns:FindFirstChild("Flock") then
		return
	end
	local ascended = isAscendedMorvid(getPlayerData(p2))
	local cooldowntime = ascended and 20 or 30
	local CD = Instance.new("NumberValue")
	CD.Name = "Flock"
	CD.Value = cooldowntime
	CD.Parent = p2.Cooldowns
	game.Debris:AddItem(CD, cooldowntime)
	u1 = false
	playFlockVfx(p2.HumanoidRootPart)
	for v13, v14 in pairs(p2:GetDescendants()) do
		if v14:IsA("BasePart") and v14.Transparency ~= 1 then
			if v14:IsA("Part") then
				for v15 = 1, math.ceil(v14.Size.x * v14.Size.y * v14.Size.z) do
					local v16 = v14:Clone()
					v16.Transparency = 0
					v16:ClearAllChildren()
					v16.Size = Vector3.new(1, 1, 1)
					v16.Color = Color3.fromRGB(0, 0, 0)
					v16.CFrame = v14.CFrame
					v16.CanCollide = false
					v16.Anchored = true
					v16.Parent = game.Workspace.Thrown
					l__TweenService__3:Create(v16, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Size = Vector3.new(0, 0, 0),
						Transparency = 1,
						CFrame = p2.HumanoidRootPart.CFrame * CFrame.new(math.random(-10, 10), 10, math.random(-10, 10))
					}):Play()
					game.Debris:AddItem(v16, 0.5)
				end
			end
		end
	end
	v3.Parent = p2.Boosts
	local v173 = Instance.new("Accessory")
	v173.Name = "canmanashield"
	v173.Parent = p2
	game:GetService("Debris"):AddItem(v173, 2)
	local v17 = Instance.new("Accessory")
	v17.Name = "Immortal"
	v17.Parent = p2
	game:GetService("Debris"):AddItem(v17, 2)
	local v18 = Instance.new("Accessory")
	v18.Name = "NoAttack"
	v18.Parent = p2
	game:GetService("Debris"):AddItem(v18, 2)
	local v19 = Instance.new("IntValue")
	v19.Name = "SpeedBoost"
	v19.Value = ascended and 20 or 13
	v19.Parent = p2.Boosts
	game:GetService("Debris"):AddItem(v19, 2)
	if ascended then
		watchFlockProximity(p2, 2, function()
			v3.Parent = l__Parent__2
			v173:Destroy()
			v17:Destroy()
			v18:Destroy()
			v19:Destroy()
		end)
	end
	spawn(function()
		wait(2)
		if v3.Parent ~= l__Parent__2 then
			v3.Parent = l__Parent__2
		end
	end)
	wait(cooldowntime)
	u1 = true
end

local M2_COOLDOWN = 25
local M2_RANGE = 50
local M2_SWARM_DELAY = 1.5
local M2_DAMAGE = 15
local M2_STUN = 0.5
local M2_REAPPEAR_OFFSET = 4
local u2 = true

local function findFlockTarget(caster, range)
	local nearest, nearestDist
	for _,plr in pairs(game.Players:GetPlayers()) do
		local char = plr.Character
		if char and char ~= caster and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and not char:FindFirstChild("Dead") then
			local dist = (char.HumanoidRootPart.Position - caster.HumanoidRootPart.Position).Magnitude
			if dist <= range and (not nearestDist or dist < nearestDist) then
				nearest = char
				nearestDist = dist
			end
		end
	end
	return nearest
end

-- Ascended Morvid only. You vanish, the normal Flock crow-swarm VFX/sound plays on the
-- target instead of on you, and after a short delay you reappear right in front of them
-- (still stunned for M2_STUN) while the swarm damage lands. No Immortal/NoAttack/
-- canmanashield markers are granted at any point during this - unlike M1, this is meant to
-- carry real risk. Unlike M1, watchFlockProximity is NOT used here - the proximity
-- punish only applies to M1's dash, not M2's swarm (M2 already requires getting close to
-- its target on purpose, so the same "caught getting close" punish doesn't apply to it).
function v1.Active2(p2, p3, p4, p5)
	if ActionCheck(p2) then
		return
	end
	if not isAscendedMorvid(getPlayerData(p2)) then
		return
	end
	if u2 == false then
		return
	end
	if p2.Cooldowns:FindFirstChild("Flock Swarm") then
		return
	end
	local target = findFlockTarget(p2, M2_RANGE)
	if not target then
		return
	end
	u2 = false
	local CD2 = Instance.new("NumberValue")
	CD2.Name = "Flock Swarm"
	CD2.Value = M2_COOLDOWN
	CD2.Parent = p2.Cooldowns
	game.Debris:AddItem(CD2, M2_COOLDOWN)

	local vanish = Instance.new("NumberValue")
	vanish.Name = "Transparency"
	vanish.Value = 1
	vanish.Parent = p2.Boosts

	playFlockVfx(target.HumanoidRootPart)

	wait(M2_SWARM_DELAY)

	if vanish.Parent then
		vanish:Destroy()
	end

	if target.Parent and target:FindFirstChild("HumanoidRootPart") and p2:FindFirstChild("HumanoidRootPart") then
		local targetRoot = target.HumanoidRootPart
		p2.HumanoidRootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -M2_REAPPEAR_OFFSET) * CFrame.Angles(0, math.rad(180), 0)
		TagHumanoidEvent:Fire(p2, target, {
			damage = M2_DAMAGE,
			physical = true,
			stun = M2_STUN,
			move = "Flock",
		})
	end

	u2 = true
end

return v1
