--[[
	Shared eating logic for Turnip/Meat (and any future food), plus the AnythingEater path for
	consuming non-food items. Centralized here rather than duplicated in each food item's own
	Script.server.luau so the 3 new eating injuries (VomitForcer/LackEater/AnythingEater) only
	need to be checked in one place.
]]

local DAILY_CAPS = {
	Turnip = 3,
	Meat = 1,
}

local module = {}

-- Returns true if the food was eaten, false if blocked (caller should play its own "can't eat"
-- cue, e.g. the existing Handle.Cough sound both Turnip/Meat already have for other blocked races).
function module.eat(character, data, itemName, hungerAmount)
	if data.Injuries.Value:find("AnythingEater") then
		return false
	end

	if data.Injuries.Value:find("LackEater") then
		local capField = itemName .. "EatenToday"
		local cap = DAILY_CAPS[itemName]
		if cap and data:FindFirstChild(capField) then
			if data[capField].Value >= cap then
				return false
			end
			data[capField].Value += 1
		end
	end

	character.Stomach.Value = math.clamp(character.Stomach.Value + hungerAmount, 0, character.Humanoid.MaxHealth)

	if data.Injuries.Value:find("VomitForcer") then
		task.delay(120, function()
			if character and character.Parent and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
				local stun = Instance.new("Accessory")
				stun.Name = "Stun"
				stun.Parent = character
				game.Debris:AddItem(stun, 2)
				character.Stomach.Value = 0
				local root = character:FindFirstChild("HumanoidRootPart")
				if root and root:FindFirstChild("Vomit") then
					root.Vomit:Play()
				end
			end
		end)
	end

	return true
end

-- AnythingEater: consumes a non-food Backpack item for a flat, small hunger amount ("way less
-- than normal food"). Triggered by the "eat <item>" chat command in CharacterHandler, not a
-- per-item Tool script, since retrofitting ~239 Storage items individually is out of scope.
function module.eatAnything(player, character, data, itemName)
	if not data.Injuries.Value:find("AnythingEater") then
		return false
	end
	if itemName == "Turnip" or itemName == "Meat" then
		return false
	end
	local item = player.Backpack:FindFirstChild(itemName) or character:FindFirstChild(itemName)
	if not item or not item:IsA("Tool") then
		return false
	end

	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(player, itemName)
	item:Destroy()
	character.Stomach.Value = math.clamp(character.Stomach.Value + 10, 0, character.Humanoid.MaxHealth)
	return true
end

return module
