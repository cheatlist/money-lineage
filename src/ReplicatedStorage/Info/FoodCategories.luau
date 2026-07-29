--[[
	Shared item-name categorization for the AnythingEater eat mechanic (added 2026-07-29) - lives
	in ReplicatedStorage rather than duplicated between ServerScriptService/Modules/FoodModule.luau
	(the real, authoritative eat logic) and the AnythingEaterGui client button (which only reads
	this to decide whether to even show the "Eat" button - the server remains the sole authority on
	whether an eat actually succeeds, this table is not itself a security boundary).
]]

return {
	FOOD_ITEMS = {
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
	},

	POTION_ITEMS = {
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
	},

	-- The 13 single-slot artifacts (see the "New system: Alert popups" section of CLAUDE.md).
	-- Still eatable (unlike food/potions) but only when the player already holds a different
	-- artifact - see FoodModule.eatAnything for the actual gate. Kept here (not excluded from the
	-- button) so AnythingEaterGui still offers to eat a duplicate artifact.
	ARTIFACT_ITEMS = {
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
	},
}
