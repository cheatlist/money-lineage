--[[
	Shared self-termination logic: knocks the caster out, then kills them 3 seconds later. Used
	by both the "Termination" move (ServerStorage/Classes/Termination, granted to every player at
	spawn) and the Mirror ClickDetector's self-image-death trigger
	(WorldHandler/Touched.server.luau) - a shared module rather than simulating a Tool activation
	from the Mirror script, same "one place, multiple callers" shape as WorkoutModule/
	SupplementModule elsewhere in this codebase.
]]

local module = {}

function module.trigger(character)
	if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
		return
	end
	if character:FindFirstChild("Immortal") or character:FindFirstChild("Terminating") then
		return
	end

	local player = game.Players:GetPlayerFromCharacter(character)

	local terminating = Instance.new("Accessory")
	terminating.Name = "Terminating"
	terminating.Parent = character
	game.Debris:AddItem(terminating, 3)

	local knocked = Instance.new("Accessory")
	knocked.Name = "Knocked"
	knocked.Parent = character
	game.Debris:AddItem(knocked, 3)

	local unconscious = Instance.new("Accessory")
	unconscious.Name = "Unconscious"
	unconscious.Parent = character
	game.Debris:AddItem(unconscious, 3)

	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:FindFirstChild("SCREAM1") then
		root.SCREAM1:Play()
	end

	task.delay(3, function()
		if character and character.Parent and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 and player then
			_G.Death(player)
		end
	end)
end

return module
