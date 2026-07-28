--[[
	Shared logic for the new "supplements" consumable category (Alchemy-style potions under
	ServerStorage/Storage/<Supplement>/, same Self/Pour RemoteEvent shape as Health Potion/Ice
	Protection/Liquid Wisdom). Starts with Preworkout; built as a shared module so future
	supplements reuse the same buff-application and Fischeran bonus instead of each hardcoding
	it, same shape as WorkoutModule for the workout Tools.

	Fischeran are part-liquid (this session's design) - drinking any supplement partially merges
	with their own body instead of just passing through, so the same dose hits harder and costs
	less Toxicity for them specifically. Any future supplement that calls module.applyBuff gets
	this for free.
]]

local FISCHERAN_SCALE = 1.5
local FISCHERAN_TOXICITY_SCALE = 0.5

local module = {}

function module.applyBuff(character, buffName, speedBoost, atkSpeedBoost, duration, toxicity, damageMult, healthBoost, superStrength)
	local player = game.Players:GetPlayerFromCharacter(character)
	local data = player and game.ServerStorage.PlayerData:FindFirstChild(player.Name)
	local isFischeran = data and data.Race.Value == "Fischeran"
	local scale = isFischeran and FISCHERAN_SCALE or 1

	local marker = Instance.new("BoolValue")
	marker.Name = buffName
	marker.Value = true
	marker.Parent = character
	game.ServerStorage.Debris:Fire(marker, duration)

	local boosts = character:FindFirstChild("Boosts")
	if boosts then
		if speedBoost and speedBoost > 0 then
			local speed = Instance.new("NumberValue")
			speed.Name = "SpeedBoost"
			speed.Value = speedBoost * scale
			speed.Parent = boosts
			game.ServerStorage.Debris:Fire(speed, duration)
		end
		if atkSpeedBoost and atkSpeedBoost > 1 then
			local atk = Instance.new("NumberValue")
			atk.Name = "AttackSpeedBoost"
			atk.Value = 1 + (atkSpeedBoost - 1) * scale
			atk.Parent = boosts
			game.ServerStorage.Debris:Fire(atk, duration)
		end
		if damageMult and damageMult > 1 then
			-- Distinctly-named (not MeleeDamageMultiplier) so this doesn't fight the 7 existing
			-- MeleeDamageMultiplier grantors (Rage/Overclock/etc.) for the same NumberValue -
			-- TagHumanoid only ever reads one via FindFirstChild, so a same-named second source
			-- would silently overwrite/lose whichever one isn't found first. Read/clamped at
			-- TagHumanoid/init.server.luau right next to HypertrophyDamageMultiplier.
			local dmg = Instance.new("NumberValue")
			dmg.Name = "SupplementDamageMultiplier"
			dmg.Value = 1 + (damageMult - 1) * scale
			dmg.Parent = boosts
			game.ServerStorage.Debris:Fire(dmg, duration)
		end
		if healthBoost and healthBoost > 0 then
			-- HealthBoost is already summed across every matching Boosts child by
			-- Health.server.luau's applyHealth() (not a single FindFirstChild read), so multiple
			-- simultaneous sources stack safely - no collision risk like MeleeDamageMultiplier.
			local hp = Instance.new("NumberValue")
			hp.Name = "HealthBoost"
			hp.Value = healthBoost * scale
			hp.Parent = boosts
			game.ServerStorage.Debris:Fire(hp, duration)
		end
		if superStrength then
			-- Same Boosts-parented SuperStrength convention TagHumanoid already reads for
			-- knockback doubling (init.server.luau:342) - parented to Boosts, not directly to
			-- Character, so it never collides with Haseldan's own Character-parented rage version.
			local strength = Instance.new("Accessory")
			strength.Name = "SuperStrength"
			strength.Parent = boosts
			game.ServerStorage.Debris:Fire(strength, duration)
		end
	end

	if toxicity and character:FindFirstChild("Toxicity") then
		character.Toxicity.Value += isFischeran and (toxicity * FISCHERAN_TOXICITY_SCALE) or toxicity
	end

	if isFischeran then
		-- "Become part supplement" - a visible marker other Fischeran-specific content can key
		-- off later; the amplified SpeedBoost/AttackSpeedBoost/toxicity discount above is the
		-- actual mechanical buff for now.
		local fischeranMarker = Instance.new("BoolValue")
		fischeranMarker.Name = "SupplementFischeran"
		fischeranMarker.Value = true
		fischeranMarker.Parent = character
		game.ServerStorage.Debris:Fire(fischeranMarker, duration)
	end
end

return module
