return {
	-- Legacy/dead content - not worth auditing for stacking safety
	["Weak Poisonous Meat"] = true,
	["Mediocre Poisonous Meat"] = true,
	["Strong Poisonous Meat"] = true,
	["Fatal Poisonous Meat"] = true,
	["Hallucination Poisonous Meat"] = true,
	["Five Demisesous Meat"] = true,
	["Uncooked Meat"] = true,
	["Delicious Meat"] = true,
	["Mouth-Watering Meat"] = true,
	["Savory Meat"] = true,
	["Tasty Meat"] = true,
	["Vint"] = true,
	-- Frying Pan cooks Uncooked Meat by counting physical Backpack instances rather than
	-- reading Quantity - stacking Uncooked Meat would make it always see "1" regardless of
	-- how many the player actually has.
	-- Stores real per-instance state (script.Parent.DyeColor, set per-tool by the player dipping
	-- that specific packet) that a shared stack can't represent.
	["Dye Packet"] = true,
	-- Each physical Torch tracks its own Lit/PercentLit/ColdResist warm-up state independently -
	-- merging two Torches in different lit states into one shared stack would corrupt that state.
	["Torch"] = true,
	-- Placeholder/unused entry, not a real item.
	["EmptyName"] = true,
}
