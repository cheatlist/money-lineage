-- Ascended Ashiin racial ability. If pressed while a move currently has you locked (the
-- "Action" tag every other move's ActionCheck blocks on - see ActionCheck.luau), that move is
-- cancelled and the follow-up punch guardbreaks. Pressed with no move going on, it's just the
-- fast punch, no guardbreak. Reuses the existing Monk unarmed-combo animation family
-- (combatanims.MonkPunch3).
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
-- Deliberately does NOT include "Action" in presentBlocks, unlike virtually every other move's
-- ActionCheck - Fakeout's whole point is to be usable while another move's windup/recovery has
-- you locked, so it can cancel that lock. It still blocks on genuine incapacitation.
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		absentBlocks = {"Humanoid"},
		healthAtOrBelow = 0,
		presentBlocks = {"Stun","ReturnStun","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Grabbed","Grabbing","Climbing"},
	})
end

local combatanims = game.ReplicatedStorage.CombatAnims
local TagHumanoidEvent = game.ServerStorage.Requests.TagHumanoid
local Players = game:GetService("Players")

local COOLDOWN = 6
local RANGE = 7
local DAMAGE = 6

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
	if Character.Cooldowns:FindFirstChild("Fakeout") then
		return
	end

	Cooldown = true
	local CD = Instance.new("NumberValue")
	CD.Name = "Fakeout"
	CD.Value = COOLDOWN
	CD.Parent = Character.Cooldowns
	game.Debris:AddItem(CD, COOLDOWN)
	task.delay(COOLDOWN, function()
		Cooldown = false
	end)

	local cancelling = Character:FindFirstChild("Action") ~= nil
	if cancelling then
		Character.Action:Destroy()
	end

	local anim = Character.Humanoid:LoadAnimation(combatanims.MonkPunch3)
	anim:Play()
	task.delay(0.4, function()
		anim:Stop()
	end)
	task.wait(0.12)

	local target = findTarget(Character)
	if target then
		TagHumanoidEvent:Fire(Character, target, {
			damage = DAMAGE,
			physical = true,
			fist = true,
			blockbreak = cancelling,
			move = "Fakeout",
		})
	end
end)
