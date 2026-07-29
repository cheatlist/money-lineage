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

-- Every real "food" item, added 2026-07-29 alongside the AnythingEater fixes below - Turnip/Meat
-- already went through module.eat (and thus the AnythingEater block), but Pizza/Pork Bun/the
-- Meat-quality-tier family/the 4 crafted Cooked-mushroom foods never did, so an AnythingEater
-- player could still eat plain food as long as it wasn't specifically Turnip or Meat. Matches
-- NonStackableItems.luau's own Meat-family list (a different concern - stacking - but the same
-- real-world item set) plus Pizza/Pork Bun/the cooked mushrooms, none of which are in that list
-- since they don't have the stacking-corruption problem those exclusions exist for.
local FOOD_ITEMS = {
	Turnip = true,
	Meat = true,
	["Uncooked Meat"] = true,
	["Delicious Meat"] = true,
	["Mouth-Watering Meat"] = true,
	["Savory Meat"] = true,
	["Tasty Meat"] = true,
	Vint = true,
	["Weak Poisonous Meat"] = true,
	["Mediocre Poisonous Meat"] = true,
	["Strong Poisonous Meat"] = true,
	["Fatal Poisonous Meat"] = true,
	["Hallucination Poisonous Meat"] = true,
	["Five Demisesous Meat"] = true,
	Pizza = true,
	["Pork Bun"] = true,
	["Cooked Scroom"] = true,
	["Cooked Glowshroom"] = true,
	["Cooked Periashroom"] = true,
	["Cooked Zombie Scroom"] = true,
}

-- Every potion/brewed consumable (the 13 items under ServerStorage/Alchemy/Tools that aren't the
-- generic Ingredient template) - "non food/non potion items should be eatable" excludes these too.
local POTION_ITEMS = {
	["Bone Grow"] = true,
	Creatine = true,
	["Feather Feet"] = true,
	["Fire Protection"] = true,
	["Health Potion"] = true,
	["Ice Protection"] = true,
	Kingsbane = true,
	["Liquid Wisdom"] = true,
	Lordsbane = true,
	Preworkout = true,
	["Silver Sun"] = true,
	["Switch Witch"] = true,
	["Tespian Elixir"] = true,
}

-- The 13 single-slot artifacts (see the "New system: Alert popups" section of CLAUDE.md, which
-- already enumerates this exact set for the artifact-conflict alert wiring).
local ARTIFACT_ITEMS = {
	["Black Pill"] = true,
	["Charming Stone"] = true,
	Exoskeleton = true,
	["Playful Stone"] = true,
	["Lannis Amulet"] = true,
	["Phoenix Feather"] = true,
	Fairfrozen = true,
	Nightstone = true,
	["Philosophers Stone"] = true,
	["Pocket Watch"] = true,
	["Unwavering Focus"] = true,
	["Spider Cloak"] = true,
	["Howler Friend"] = true,
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

-- AnythingEater: consumes any non-food, non-potion Backpack/Character item for a flat, small
-- hunger amount ("way less than normal food"). Triggered by the "eat <item>" chat command in
-- CharacterHandler, not a per-item Tool script, since retrofitting ~239 Storage items individually
-- is out of scope.
--
-- Fixed 2026-07-29 (the injury "didn't work" - two real bugs found):
-- 1. Item lookup was an exact-case FindFirstChild - a chat-typed name that didn't match a Tool's
--    exact capitalization (e.g. typing "goblet"/"amulet" for a Tool actually named "Goblet"/
--    "Amulet") silently failed to match at all. Now matches case-insensitively by scanning
--    Character/Backpack children directly, and passes the item's own real .Name (not the
--    possibly-differently-cased typed string) on to RemoveFromInventory.
-- 2. Only Turnip/Meat were excluded as "food" - Pizza/Pork Bun/the Meat-quality-tier family/the 4
--    crafted Cooked-mushroom foods were never blocked, so "you cannot eat food" wasn't actually
--    true for those. Now checked against the full FOOD_ITEMS list above (POTION_ITEMS excluded
--    too, per "non food/non potion items should be eatable").
function module.eatAnything(player, character, data, itemName)
	if not data.Injuries.Value:find("AnythingEater") then
		return false
	end

	-- Resolves the real Tool (and its correctly-cased .Name) FIRST, then checks
	-- FOOD_ITEMS/POTION_ITEMS/ARTIFACT_ITEMS against that - a raw case-insensitive check against
	-- the player's own typed itemName would miss e.g. someone typing "turnip" against the
	-- exact-case "Turnip" key in FOOD_ITEMS, the same case-sensitivity bug this whole rewrite
	-- exists to fix, just for the exclusion lists instead of the item lookup.
	local lowerName = itemName:lower()
	local item = nil
	for _, container in ipairs({character, player.Backpack}) do
		for _, child in ipairs(container:GetChildren()) do
			if child:IsA("Tool") and child.Name:lower() == lowerName then
				item = child
				break
			end
		end
		if item then
			break
		end
	end
	if not item then
		return false
	end
	if FOOD_ITEMS[item.Name] or POTION_ITEMS[item.Name] then
		return false
	end

	if ARTIFACT_ITEMS[item.Name] then
		-- "You only eat them if you already have an artifact... otherwise it will give the player
		-- the artifact alert" - a real, usable artifact (the player doesn't have one yet) isn't
		-- tradeable for a trivial +10 hunger; only a redundant duplicate (player already holds a
		-- different artifact) is fair game to convert into food.
		if data.Artifact.Value == "None" or data.Artifact.Value == "" then
			require(game.ServerScriptService.Modules.AlertModule).send(player, "This is a real artifact - use it properly instead of eating it.")
			return false
		end
	end

	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(player, item.Name)
	character.Stomach.Value = math.clamp(character.Stomach.Value + 10, 0, character.Humanoid.MaxHealth)
	return true
end

return module
