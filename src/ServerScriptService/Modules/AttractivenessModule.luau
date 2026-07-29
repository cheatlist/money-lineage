--[[
	Attractiveness = PlayerData.AttractivenessBase (a weighted 10-30 roll, rolled once ever - see
	the lazy "0 sentinel means not yet rolled" check in CharacterHandler/init.server.luau, same
	convention already used there for FacialMark) multiplied by a class multiplier, a race
	multiplier, and a height factor (see below), then flat bonuses (workout, Black Pill, Vampire -
	see below) are added on top. Recomputed at every spawn into PlayerData.Attractiveness (a
	cached/display value, not the source of truth - call module.compute again any time a fresh
	read is needed, e.g. after a class change mid-life, since nothing currently hooks
	Attractiveness recomputation into every possible class/race-changing event).

	Workout bonus (added 2026-07-29): +1 flat Attractiveness point per 10 total points invested
	across all 5 WorkoutModule categories (Chest/Legs/Core/Shoulders/Back), capped at 15 (the
	natural max given 5 categories * 30-point cap each / 10). Added after all the multipliers,
	not before, per the request's literal "give 1 attractiveness" - a flat point, not something
	meant to be re-scaled by class/race/height too.

	Black Pill / Vampire bonuses (added 2026-07-29): +5 flat Attractiveness each, independently
	stacking with each other and with the workout bonus - same "flat, added after the multipliers"
	shape, per the request's literal "flat 5 attractiveness". Black Pill checks
	PlayerData.Artifact.Value, same as every other Black Pill check in this codebase. Vampire
	checks PlayerData.Vampire.Value directly (the real, non-replicated source of truth behind the
	"Vampirism" CollectionService Character tag - see CharacterHandler/Modules/Vampirism.luau) -
	not the tag itself, matching this codebase's established "check PlayerData, not a replicated
	Character/Backpack marker" convention from the spoofable-passives security fix elsewhere in
	this doc.

	Height factor (added 2026-07-29): PlayerData.HeightMultiplier (the 0.8x-1.1x roll from
	character creation, see CharacterCreationGui/Script.server.luau) is used directly as a
	multiplier here, per the request's literal "height multiplier = attractiveness multiplier" -
	below 1x reads as a negative contribution (shrinks the result), above 1x as positive (grows
	it). Two extra bands stack a further multiplier on top of the raw HeightMultiplier: below
	0.95x gets an additional 0.925x penalty (short characters lose out by more than their height
	multiplier alone would suggest); above 1.05x gets an additional 1.02x bonus. Between 0.95x and
	1.05x inclusive (and at/above 1x per the request's "doesn't apply to 1x+" carve-out for the
	penalty band), the raw HeightMultiplier applies with no further adjustment. Deliberately reads
	PlayerData.HeightMultiplier directly, not the Black-Pill-inclusive "total scale factor"
	CharacterHandler/init.server.luau computes for the actual body-scale visual - Black Pill's own
	1.2x wasn't mentioned as an Attractiveness input, so it's excluded here; flag if that should
	also count.

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
	DragonSage = 1.2,
	Oni = 1.25,
	["Master Illusionist"] = 1.1, -- "Illusionist" in the request - real ultra tier (see correction note above). Deliberately below neutral, not a bug like the other four corrections.
	Florist = 1.05, -- "Druid" in the request - the Botanist line's actual ultra tier (class = "Florist")
	["Master Necromancer"] = 1.2, -- "Necro" in the request - real ultra tier (was wrongly "Necromancer", the super tier)
	Whisper = 1.1, -- "Spy" in the request - real ultra tier (was wrongly "Spy", the super tier)
	Wanderer = 1.2, -- Spy's OTHER ultra branch - same value, the request only gave one number for the whole Spy line
	Candence = 1, -- "Bard" in the request - Candence is this codebase's real performance/bard-flavored ultra class. "Victim of fighting power based hypergamy"
	Faceless = 1.25,
	Shinobi = 1.25,
	DragonSlayer = 1.25,
	DeepKnight = 1.2,
	SigilKnightCommander = 1.25, -- "Sigil" in the request - real ultra tier (was wrongly "SigilKnight", the super tier). 1.95 if Solan's Will - handled in getClassMultiplier, not this table
	DarkSigilKnight = 1.2, -- "DSK" in the request - SigilKnight's OTHER ultra branch, already correctly keyed from the start
	Lapidarist = 1.2, -- "Blacksmith" in the request - SuperBlacksmith's actual ultra tier (class = "Lapidarist")
	Ronin = 1.15, -- "Samurai" in the request - real ultra tier (was wrongly "Samurai", the super tier)
	Abysswalker = 1, -- "dependent on race and height" - height isn't a tracked stat; race multiplier still applies normally on top
}

module.RACE_MULTIPLIERS = {
	Dzin = 1.15,
	Vind = 1.2,
	Fischeran = 1,
	-- Morvid is alignment-dependent, handled in getRaceMultiplier, not this table
	Dinakeri = 1.1,
	Madrasian = 1, -- overridden by whatever race you're currently Shifted into, see compute()
	Navaran = 0.9,
	Scroom = 0.8,
	Gaian = 1,
	Kasparan = 0.9,
	Castellan = 1.2,
	Ashiin = 1.1,
	Rigan = 1,
	Haseldan = 1,
	Dullahan = 1.5
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
		return data.Alignment.Value < 0 and 0.9 or 1.1
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
	-- Instance doesn't exist yet, not just the spawn path. Falls back to a neutral base (20, the
	-- midpoint of the 10-30 roll's dominant 75%-weighted 16-24 band) rather than erroring; doesn't
	-- try to persist anything back if the field doesn't exist, since there'd be nowhere to write it.
	local baseField = data:FindFirstChild("AttractivenessBase")
	local base = baseField and baseField.Value or 20
	if baseField and base == 0 then
		base = 20
	end

	-- Height factor (see header comment for the full band breakdown).
	local heightField = data:FindFirstChild("HeightMultiplier")
	local heightMultiplier = (heightField and heightField.Value > 0) and heightField.Value or 1
	local heightFactor = heightMultiplier
	if heightMultiplier < 0.95 then
		heightFactor = heightMultiplier * 0.925
	elseif heightMultiplier > 1.05 then
		heightFactor = heightMultiplier * 1.02
	end

	-- Workout bonus (added 2026-07-29): +1 Attractiveness per 10 total points invested across all
	-- 5 WorkoutModule categories (Chest/Legs/Core/Shoulders/Back), added as a flat point AFTER the
	-- base*class*race*height multiplication rather than folded into `base` - "give 1 attractiveness"
	-- reads as a flat point, not something meant to be re-scaled by the other multipliers too.
	-- Capped at 15 to match the request's own stated ceiling - already the natural max given 5
	-- categories * WorkoutModule's 30-point-per-category cap / 10 = 15, but an explicit clamp is
	-- kept anyway rather than relying on that arithmetic never changing elsewhere.
	local workoutStatNames = {"WorkoutChestPoints","WorkoutLegsPoints","WorkoutCorePoints","WorkoutShouldersPoints","WorkoutBackPoints"}
	local totalWorkoutPoints = 0
	for _, statName in ipairs(workoutStatNames) do
		local stat = data:FindFirstChild(statName)
		if stat then
			totalWorkoutPoints += stat.Value
		end
	end
	local workoutBonus = math.min(math.floor(totalWorkoutPoints / 10), 15)

	-- Black Pill / Vampire flat bonuses (added 2026-07-29): +5 Attractiveness each, stacking with
	-- each other and with the workout bonus above - same "flat, added after the multipliers"
	-- shape, per the request's literal "flat 5 attractiveness". Vampire is checked via
	-- PlayerData.Vampire.Value - the real server-truth backing the replicated "Vampirism"
	-- CollectionService Character tag (see CharacterHandler/Modules/Vampirism.luau), not the tag
	-- itself, matching this session's own "check PlayerData, not a replicated Character/Backpack
	-- marker" convention from the earlier spoofable-passives security fix.
	local blackPillBonus = data.Artifact.Value == "Black Pill" and 5 or 0
	local vampireBonus = data.Vampire.Value == true and 5 or 0

	local raceMult
	if data.Race.Value == "Madrasian" then
		raceMult = madrasianRaceMultiplier(player, data)
	else
		raceMult = module.getRaceMultiplier(data)
	end
	local classMult = module.getClassMultiplier(data)
	local result = base * classMult * raceMult * heightFactor + workoutBonus + blackPillBonus + vampireBonus
	local resultField = data:FindFirstChild("Attractiveness")
	if resultField then
		resultField.Value = result
	end

	-- Pushes the fresh value to the StarterGui/CurrencyGui Attractiveness label (see
	-- CurrencyClient.client.luau) every time it's recomputed - spawn, Mogging, low-Attractiveness
	-- self-trigger, the NPC gates, SolanBall, etc. all call compute(), so centralizing the push
	-- here means every one of those already keeps the display live for free.
	-- No longer Studio-asset-debt (2026-07-29): AttractivenessChanged used to be assumed as a
	-- Studio-placed RemoteEvent and just skipped if missing - but compute() runs unconditionally
	-- on EVERY spawn from deep inside CharacterHandler/init.server.luau, so plain dot-notation on
	-- a missing one (which throws) would have hard-errored that entire script every single spawn,
	-- silently skipping everything after this call for the rest of that script's run. Creating it
	-- at runtime if missing (a server script creating a RemoteEvent under ReplicatedStorage
	-- replicates to clients exactly like a Studio-placed one) removes the dependency on manual
	-- Studio placement entirely, not just the crash risk.
	if player then
		local requestsFolder = game.ReplicatedStorage.Requests
		local attractivenessChanged = requestsFolder:FindFirstChild("AttractivenessChanged")
		if not attractivenessChanged then
			attractivenessChanged = Instance.new("RemoteEvent")
			attractivenessChanged.Name = "AttractivenessChanged"
			attractivenessChanged.Parent = requestsFolder
		end
		attractivenessChanged:FireClient(player, result)
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

-- Real-time recompute on Race change (added 2026-07-29, by request): PlayerData.Race.Value is
-- reassigned from roughly two dozen call sites across this codebase (race-change items like
-- Seraph Essence/Phoenix Feather/Azael Horn/Scroom Key, dialogue race-change branches, RaceReroll,
-- ProductHandler's Robux race reroll, admin commands, etc.) - adding a compute() call at every one
-- of those sites individually would be both invasive and easy to miss one of. A single
-- Race.Changed listener here covers every current and future race-change site for free.
--
-- Fixed 2026-07-29 - REAL BUG, caused player data to stop saving entirely: the "already watching"
-- guard used to be an Instance.new("Folder") parented directly to `data` (PlayerData). PlayerData
-- doubles as the literal save source elsewhere in this codebase - the generic save loop reads
-- `settable[v.Name] = v.Value` for every child of PlayerData with no type check - and a Folder has
-- no .Value property, so hitting it there threw and aborted the ENTIRE save, every time, for every
-- player who'd ever had this marker created. "Join loads fine, leaving never saves" was the exact
-- symptom: loading only reads known NumberValue/StringValue fields, so the stray Folder never
-- broke that half, but saving iterated every child indiscriminately and errored out on it.
-- Fixed by moving the guard entirely out of the PlayerData Instance tree, into an in-memory table
-- keyed by Player - nothing under PlayerData should ever be a non-value-holding Instance.
local watchingRaceChanges = {}
game.Players.PlayerRemoving:Connect(function(player)
	watchingRaceChanges[player] = nil
end)

function module.watchForRaceChanges(player, data)
	if watchingRaceChanges[player] then
		return
	end
	watchingRaceChanges[player] = true
	data.Race.Changed:Connect(function()
		module.compute(player, data)
	end)
end

return module
