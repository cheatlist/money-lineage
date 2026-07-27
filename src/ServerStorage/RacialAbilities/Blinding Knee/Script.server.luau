-- Ascended Ashiin racial ability. A knee to the face that heavily blinds the target for
-- BLIND_DURATION seconds, reusing the existing Monk unarmed-combo animation family
-- (combatanims.MonkPunch4, the same family Ronin's Hand of God/Selftaught paths already reuse
-- for MonkPunch5) and the existing injury-blindness effect (ReplicatedStorage.Requests.Blind,
-- the same RemoteEvent ApplyInjuries.luau fires for a permanent "blind" injury) rather than
-- building a new visual.
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end

local combatanims = game.ReplicatedStorage.CombatAnims
local TagHumanoidEvent = game.ServerStorage.Requests.TagHumanoid
local Players = game:GetService("Players")

local COOLDOWN = 12
local RANGE = 8
local BLIND_DURATION = 7
local DAMAGE = 10
local STUN = 0.4

local function findTarget(caster)
	local nearest, nearestDist
	for _,v in pairs(workspace.Live:GetChildren()) do
		if v ~= caster and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
			local rel = caster.HumanoidRootPart.CFrame:inverse() * v.HumanoidRootPart.CFrame
			if rel.Z < 0 and math.abs(rel.X) <= 4 and math.abs(rel.Y) <= 5 then
				local dist = (v.HumanoidRootPart.Position - caster.HumanoidRootPart.Position).Magnitude
				if dist <= RANGE and (not nearestDist or dist < nearestDist) then
					nearest = v
					nearestDist = dist
				end
			end
		end
	end
	return nearest
end

local Cooldown = false
script.Parent.Activated:Connect(function()
	local Character = script.Parent.Parent
	local Player = Players:GetPlayerFromCharacter(Character)
	if not Player then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(Player.Name)
	if not data or not (data.Ascended.Value == true and data.Race.Value == "Ashiin") then
		return
	end
	if Cooldown then
		return
	end
	if ActionCheck(Character) then
		return
	end
	if Character.Cooldowns:FindFirstChild("Blinding Knee") then
		return
	end

	Cooldown = true
	local CD = Instance.new("NumberValue")
	CD.Name = "Blinding Knee"
	CD.Value = COOLDOWN
	CD.Parent = Character.Cooldowns
	game.Debris:AddItem(CD, COOLDOWN)
	task.delay(COOLDOWN, function()
		Cooldown = false
	end)

	local action = Instance.new("Accessory")
	action.Name = "Action"
	action.Parent = Character
	game.Debris:AddItem(action, 0.5)

	local anim = Character.Humanoid:LoadAnimation(combatanims.MonkPunch4)
	anim:Play()
	task.delay(0.5, function()
		anim:Stop()
	end)
	task.wait(0.2)

	local target = findTarget(Character)
	if target then
		TagHumanoidEvent:Fire(Character, target, {
			damage = DAMAGE,
			physical = true,
			fist = true,
			blockbreak = true,
			stun = STUN,
			move = "Blinding Knee",
		})
		local targetPlayer = Players:GetPlayerFromCharacter(target)
		if targetPlayer then
			game.ReplicatedStorage.Requests.Blind:FireClient(targetPlayer, true)
			task.delay(BLIND_DURATION, function()
				local targetData = game.ServerStorage.PlayerData:FindFirstChild(targetPlayer.Name)
				-- Don't clear a permanent "blind" injury the target may have picked up separately
				-- in the meantime - only turn the effect back off if this proc is what caused it.
				if not (targetData and targetData.Injuries.Value:find("blind")) then
					game.ReplicatedStorage.Requests.Blind:FireClient(targetPlayer, false)
				end
			end)
		end
	end
end)
