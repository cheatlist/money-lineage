--[[
	Attractiveness = PlayerData.AttractivenessBase (a random 10-20, rolled once ever - see the
	lazy "0 sentinel means not yet rolled" check in CharacterHandler/init.server.luau, same
	convention already used there for FacialMark) multiplied by a class multiplier and a race
	multiplier. Recomputed at every spawn into PlayerData.Attractiveness (a cached/display value,
	not the source of truth - call module.compute again any time a fresh read is needed, e.g.
	after a class change mid-life, since nothing currently hooks Attractiveness recomputation into
	every possible class/race-changing event).

	Every multiplier below is exactly what was requested; unlisted classes/races fall back to a
	neutral 1x rather than erroring. "Druid"/"Bard"/"Blacksmith" in the request were flavor names
	for this codebase's real class keys - Florist (the Botanist line's ultra tier), Candence (the
	actual performance/bard-flavored ultra class), and Lapidarist (SuperBlacksmith's ultra tier),
	respectively - confirmed with the user and mapped accordingly. See CLAUDE.md for the one
	remaining entry that can't currently be reached in practice (Abysswalker's "height" half - no
	height stat exists yet).

	Corrected 2026-07-28 (second correction, after the request's numbers were live): "Illusionist"/
	"Necro"/"Spy"/"Samurai"/"Sigil" were originally keyed to their SUPER-tier class string
	(ClassData.luau's `supers` table: Illusionist/Necromancer/Spy/Samurai/SigilKnight), not their
	ULTRA tier - per the user, the request always meant the ultra tier. Since the super tier was
	then left unlisted (defaulting to a neutral 1x) while its ultra sat at the LOWER neutral
	default too (the ultra class strings weren't in this table at all), reaching the real ultra
	class actually *decreased* computed Attractiveness versus staying at the super tier - the root
	cause of a live "attractiveness goes down when you get your ultra class" bug report. Fixed by
	moving each entry's key to the real ultra-tier class string: Master Illusionist, Master
	Necromancer, Whisper (+ Wanderer, Spy's other ultra branch - the request gave one number for
	the whole Spy line, not two), SigilKnightCommander. Now the super tier is the one that
	defaults to neutral 1x, and the ultra tier holds the real requested value - so promoting from
	super to ultra is a net increase again for every one of these, matching how every other class
	in this table (DragonSage, Oni, Faceless, Shinobi, DragonSlayer, DeepKnight, DarkSigilKnight,
	Florist, Candence, Lapidarist) was already correctly keyed to its ultra tier from the start.
	One exception, not a bug: "Illusionist" was explicitly given `0.8` (below neutral) in the
	original request - Master Illusionist ending up LESS attractive than the neutral-default super
	tier is what the user's own number says, not an unintended side effect like the other four
	were, so it's left as-is.
]]

local module = {}

module.CLASS_MULTIPLIERS = {
	DragonSage = 1.45,
	Oni = 1.5,
	["Master Illusionist"] = 0.8, -- "Illusionist" in the request - real ultra tier (see correction note above). Deliberately below neutral, not a bug like the other four corrections.
	Florist = 1, -- "Druid" in the request - the Botanist line's actual ultra tier (class = "Florist")
	["Master Necromancer"] = 1.6, -- "Necro" in the request - real ultra tier (was wrongly "Necromancer", the super tier)
	Whisper = 1.2, -- "Spy" in the request - real ultra tier (was wrongly "Spy", the super tier)
	Wanderer = 1.2, -- Spy's OTHER ultra branch - same value, the request only gave one number for the whole Spy line
	Candence = 1.1, -- "Bard" in the request - Candence is this codebase's real performance/bard-flavored ultra class. "Victim of fighting power based hypergamy"
	Faceless = 1.55,
	Shinobi = 1.35,
	DragonSlayer = 1.65,
	DeepKnight = 1.6,
	SigilKnightCommander = 1.75, -- "Sigil" in the request - real ultra tier (was wrongly "SigilKnight", the super tier). 1.95 if Solan's Will - handled in getClassMultiplier, not this table
	DarkSigilKnight = 1.75, -- "DSK" in the request - SigilKnight's OTHER ultra branch, already correctly keyed from the start
	Lapidarist = 1.65, -- "Blacksmith" in the request - SuperBlacksmith's actual ultra tier (class = "Lapidarist")
	Ronin = 1.2, -- "Samurai" in the request - real ultra tier (was wrongly "Samurai", the super tier)
	Abysswalker = 1, -- "dependent on race and height" - height isn't a tracked stat; race multiplier still applies normally on top
}

module.RACE_MULTIPLIERS = {
	Dzin = 1.65,
	Vind = 1.7,
	Fischeran = 1.2,
	-- Morvid is alignment-dependent, handled in getRaceMultiplier, not this table
	Dinakeri = 1.5,
	Madrasian = 1.2, -- overridden by whatever race you're currently Shifted into, see compute()
	Navaran = 0.3,
	Scroom = 0.1,
	Gaian = 1,
	Kasparan = 1.1,
	Castellan = 1.65,
	Ashiin = 1.5,
	Rigan = 1.4,
	Haseldan = 1.2,
}

local DEFAULT_MULTIPLIER = 1
local LOW_ATTRACTIVENESS_THRESHOLD = 12
local LOW_ATTRACTIVENESS_CD = 300

function module.getClassMultiplier(data)
	local class = data.Class.Value
	if class == "SigilKnightCommander" then
		return data.Skills.Value:find("Solan's Will") and 1.95 or 1.75
	end
	return module.CLASS_MULTIPLIERS[class] or DEFAULT_MULTIPLIER
end

function module.getRaceMultiplier(data)
	local race = data.Race.Value
	if race == "Morvid" then
		return data.Alignment.Value < 0 and 1.3 or 0.9
	end
	return module.RACE_MULTIPLIERS[race] or DEFAULT_MULTIPLIER
end

-- Madrasian's "shift into other races for attractiveness": Shift (RacialAbilities/Shift) doesn't
-- change PlayerData.Race.Value, only cosmetic appearance, recording the shifted-to PLAYER's name
-- (not race) on a `Shifted` StringValue parented to the Player instance itself (see
-- RacialAbilities/Shift/Script.server.luau). This resolves that name back to a race multiplier at
-- read time rather than trying to track a live "currently shifted" boolean - `Shifted` isn't
-- cleared on reverting to normal appearance elsewhere in this codebase, so this inherits that same
-- imperfect semantics (a Madrasian who shifted earlier and later reverted may still read as
-- shifted here) - flagged in CLAUDE.md rather than building new state-tracking to fix it.
local function madrasianRaceMultiplier(player, data)
	if player and player:FindFirstChild("Shifted") and player.Shifted.Value ~= "" then
		local shiftedData = game.ServerStorage.PlayerData:FindFirstChild(player.Shifted.Value)
		if shiftedData then
			return module.getRaceMultiplier(shiftedData)
		end
	end
	return module.RACE_MULTIPLIERS.Madrasian
end

function module.compute(player, data)
	-- Defensive: AttractivenessBase/Attractiveness are new PlayerData fields that need adding to
	-- the Studio Setup folder - compute() is called from many places (spawn, Mogging, both NPC
	-- gates, SolanBall), so an unguarded .Value read here could break any of them the moment the
	-- Instance doesn't exist yet, not just the spawn path. Falls back to a neutral base (15, the
	-- midpoint of the normal 10-20 roll) rather than erroring; doesn't try to persist anything
	-- back if the field doesn't exist, since there'd be nowhere to write it.
	local baseField = data:FindFirstChild("AttractivenessBase")
	local base = baseField and baseField.Value or 15
	if baseField and base == 0 then
		base = 15
	end

	local raceMult
	if data.Race.Value == "Madrasian" then
		raceMult = madrasianRaceMultiplier(player, data)
	else
		raceMult = module.getRaceMultiplier(data)
	end
	local classMult = module.getClassMultiplier(data)
	local result = base * classMult * raceMult
	local resultField = data:FindFirstChild("Attractiveness")
	if resultField then
		resultField.Value = result
	end

	-- Pushes the fresh value to the StarterGui/CurrencyGui Attractiveness label (see
	-- CurrencyClient.client.luau) every time it's recomputed - spawn, Mogging, low-Attractiveness
	-- self-trigger, the NPC gates, SolanBall, etc. all call compute(), so centralizing the push
	-- here means every one of those already keeps the display live for free.
	if player then
		game.ReplicatedStorage.Requests.AttractivenessChanged:FireClient(player, result)
	end

	-- "You can get/give these injuries upon being ... attractiveness mogged" - having a low
	-- Attractiveness on its own (not just being on the receiving end of the Mogging Tool) can
	-- also trigger Rage/Squeamish, via the same MoggingModule.applyMogDebuffs the Tool uses.
	-- Debounced per-character (LowAttractivenessCD) since compute() can be called repeatedly in
	-- quick succession (every spawn, plus both sides of every Mogging Tool use).
	-- Only runs off a REAL roll (baseField must exist) - the 15 fallback above is a guess, not a
	-- real stat, and combined with a low race multiplier (Scroom 0.1x, Navaran 0.3x) could easily
	-- land under the threshold on every single spawn for those races before Setup is updated,
	-- repeatedly Knocking/killing them off of made-up data.
	if baseField and player and player.Character and result < LOW_ATTRACTIVENESS_THRESHOLD then
		local character = player.Character
		if not character:FindFirstChild("LowAttractivenessCD") then
			local cd = Instance.new("Accessory")
			cd.Name = "LowAttractivenessCD"
			cd.Parent = character
			game.Debris:AddItem(cd, LOW_ATTRACTIVENESS_CD)
			require(game.ServerScriptService.Modules.MoggingModule).applyMogDebuffs(character, data)
		end
	end

	return result
end

return module
