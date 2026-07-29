--[[
	Shared mog-consequence logic, called both by the Mogging Tool (ServerStorage/Classes/Mogging)
	and by AttractivenessModule.compute's own low-attractiveness self-trigger, so "got mogged" and
	"is just naturally unattractive" share one implementation rather than two copies.

	Rage/Squeamish/the 3 eating injuries are real PlayerData.Injuries.Value entries (checked
	server-side by TagHumanoid/m1.luau/SpellModule/npcclick - and, as a side effect, by last
	session's Mirror "any injury" check) - but Rage/Squeamish ALSO need a mirrored
	Character-parented Accessory marker, because the two client-side consumers
	(Sprint()/ClimbFunc() in CharacterHandler/Input/init.client.luau) run on the client and can
	never read game.ServerStorage.PlayerData at all (ServerStorage never replicates to clients).
	Both the string entry and the marker are granted/expired together here.
]]

local TerminationModule = require(game.ServerScriptService.Modules.TerminationModule)
local AlertModule = require(game.ServerScriptService.Modules.AlertModule)

local EATING_INJURIES = {"VomitForcer", "LackEater", "AnythingEater"}
local DEBUFF_DURATION = 900 -- 1 in-game day, matches Health.server.luau's day length (15 min)
local TERMINATION_CHANCE = 0.15
local ATTRACTIVENESS_THRESHOLD = 8
local TERMINATION_THRESHOLD = 10
local QTE_SCALE = 0.03

-- MogPoints / Chad rank (added 2026-07-29) - feel-based constants, not spec-derived, per this
-- codebase's own established practice of flagging tunable numbers rather than deriving them from
-- a balance spec.
local MOG_POINTS_PER_ATTRACTIVENESS = 10 -- "starts you out with a higher base mog points... scales linearly"
local MOG_POINTS_FLOOR = 1 -- never 0, so 0 stays a safe "not yet seeded" sentinel (see seedMogPoints)
local MOG_STEAL_BASE = 5
local MOG_STEAL_GAP_FACTOR = 0.1 -- "higher mog points difference losing you more points"
local MOG_STEAL_MIN = 5
local MOG_STEAL_MAX = 100

local module = {}

-- Split/rejoin rather than a naive gsub, so removing "Rage" can't accidentally eat part of some
-- other injury name - same safety reasoning `string.split` is already used for this string
-- elsewhere (ApplyInjuries.luau).
local function removeInjury(data, name)
	if not data or not data.Parent then
		return
	end
	local parts = string.split(data.Injuries.Value, ",")
	local kept = {}
	for _, part in ipairs(parts) do
		if part ~= name then
			table.insert(kept, part)
		end
	end
	data.Injuries.Value = table.concat(kept, ",")
end

local function grantTimedInjury(character, data, name, duration)
	if not data.Injuries.Value:find(name) then
		data.Injuries.Value ..= "," .. name
	end
	local marker = character:FindFirstChild(name)
	if not marker then
		marker = Instance.new("Accessory")
		marker.Name = name
		marker.Parent = character
	end
	game.Debris:AddItem(marker, duration)
	task.delay(duration, function()
		removeInjury(data, name)
	end)
end

-- The 3 independent rolls described in the request (10% eating injury / 30% Squeamish / 40%
-- Rage) - read literally as 3 separate chances, not a mutually-exclusive 100%-summing pick, so
-- 0-3 can land from a single mog.
function module.applyMogDebuffs(character, data)
	if not character or not character.Parent or not data then
		return
	end

	if math.random() < 0.10 then
		local pool = {}
		for _, name in ipairs(EATING_INJURIES) do
			if not data.Injuries.Value:find(name) then
				table.insert(pool, name)
			end
		end
		if #pool > 0 then
			grantTimedInjury(character, data, pool[math.random(1, #pool)], DEBUFF_DURATION)
		end
	end

	if math.random() < 0.30 then
		grantTimedInjury(character, data, "Squeamish", DEBUFF_DURATION)
	end

	if math.random() < 0.40 then
		grantTimedInjury(character, data, "Rage", DEBUFF_DURATION)
	end
end

-- MogPoints seed (added 2026-07-29): 0 sentinel = "not yet seeded ever" (same lazy convention as
-- AttractivenessBase/HeightMultiplier), scaled linearly off the player's first-ever computed
-- Attractiveness - "spawning in with higher attractiveness starts you out with a higher base mog
-- points but it scales linearly." Deliberately NOT re-seeded on later characters (unlike
-- Attractiveness itself, which can be re-rolled - see the height/attractiveness carry-over notes
-- elsewhere in this doc) - MogPoints is a persistent, account-level competitive stat that only
-- grows/shrinks via mogging duels from here on, so a fresh character must not reset it. Floored at
-- MOG_POINTS_FLOOR (never 0) so the 0 sentinel can never recur from natural gameplay loss.
function module.seedMogPoints(data)
	if not data then
		return
	end
	local mogPointsField = data:FindFirstChild("MogPoints")
	if not mogPointsField or mogPointsField.Value ~= 0 then
		return
	end
	local attractivenessField = data:FindFirstChild("Attractiveness")
	local attractiveness = attractivenessField and attractivenessField.Value or 0
	mogPointsField.Value = math.max(math.floor(attractiveness * MOG_POINTS_PER_ATTRACTIVENESS), MOG_POINTS_FLOOR)
end

-- Transfers MogPoints from the loser to the winner (added 2026-07-29) - "whenever you mog a
-- target you gain mog points, getting mogged loses you mog points with higher mog points
-- difference losing you more points, while being similarly ranked will not steal as many points."
-- Read literally: the stolen amount scales with the absolute MogPoints gap between the two
-- players (not a win-margin/attractiveness-diff calculation), a flat base amount for near-equal
-- ranks, clamped so a single mog can't swing an absurd amount. Zero-sum - the winner only ever
-- gains exactly what's actually removed from the loser (respecting MOG_POINTS_FLOOR), never
-- points from nowhere. Fires the "you have gained/lost X mog points" alert on both sides and pokes
-- MogRankHandler to resync that player's global Chad rank immediately, rather than waiting for the
-- next periodic resort.
local function transferMogPoints(winnerPlayer, winnerData, loserPlayer, loserData)
	if not winnerData or not loserData then
		return
	end
	local winnerPointsField = winnerData:FindFirstChild("MogPoints")
	local loserPointsField = loserData:FindFirstChild("MogPoints")
	if not winnerPointsField or not loserPointsField then
		return
	end

	local gap = math.abs(winnerPointsField.Value - loserPointsField.Value)
	local wanted = math.floor(math.clamp(MOG_STEAL_BASE + gap * MOG_STEAL_GAP_FACTOR, MOG_STEAL_MIN, MOG_STEAL_MAX))
	local stolen = math.min(wanted, math.max(loserPointsField.Value - MOG_POINTS_FLOOR, 0))
	if stolen <= 0 then
		return
	end

	loserPointsField.Value -= stolen
	winnerPointsField.Value += stolen

	if winnerPlayer then
		AlertModule.send(winnerPlayer, "You have gained "..stolen.." mog points.")
	end
	if loserPlayer then
		AlertModule.send(loserPlayer, "You have lost "..stolen.." mog points.")
	end

	-- Defensive: MogRankHandler/its UpdateMogPoints BindableEvent are Studio-placed (see that
	-- script's own asset-debt note) - skip the resync poke rather than erroring if it's not there
	-- yet. The points themselves are already transferred above regardless.
	local MogRankHandler = game.ServerScriptService.WorldHandler:FindFirstChild("MogRankHandler")
	local updateEvent = MogRankHandler and MogRankHandler:FindFirstChild("UpdateMogPoints")
	if updateEvent then
		if winnerPlayer then
			updateEvent:Fire(winnerPlayer)
		end
		if loserPlayer then
			updateEvent:Fire(loserPlayer)
		end
	end
end

-- Takes already-computed Attractiveness numbers (the Mogging Tool script owns calling
-- AttractivenessModule.compute for both sides - this module doesn't require that one itself, to
-- keep AttractivenessModule -> MoggingModule a one-directional dependency, since
-- AttractivenessModule.compute also calls into this module for its own self-trigger).
--
-- Bug fixed 2026-07-29: the "outclassed" and "QTE" branches used to be nested as the elseif/else
-- of the INNER `if diff >= TERMINATION_THRESHOLD` check, which itself only runs when the OUTER
-- `if diff >= ATTRACTIVENESS_THRESHOLD` is already true - since diff can't simultaneously be >= 8
-- and <= -8, that elseif (and the QTE else hanging off the same chain) was mathematically
-- unreachable. In practice this meant mogging only ever did anything when the caster was clearly
-- ahead (diff >= 8); the "outclassed" reversal and the whole weighted-coinflip QTE case had never
-- actually fired since this module was written. Flattened into three proper sibling branches
-- below - found while wiring in MogPoints (which needs to fire on every outcome), not
-- independently hunted for.
function module.resolve(casterPlayer, casterCharacter, casterData, casterAttr, targetPlayer, targetCharacter, targetData, targetAttr)
	local diff = casterAttr - targetAttr

	if diff >= ATTRACTIVENESS_THRESHOLD then
		module.applyMogDebuffs(targetCharacter, targetData)
		transferMogPoints(casterPlayer, casterData, targetPlayer, targetData)
		if diff >= TERMINATION_THRESHOLD then
			if math.random() < TERMINATION_CHANCE then
				TerminationModule.trigger(targetCharacter)
			end
		end
		return "won"
	elseif diff <= -ATTRACTIVENESS_THRESHOLD then
		-- Not explicitly described in the request (which only covers "clearly ahead" and
		-- "comparable") - mogging someone clearly more attractive than you leaving no downside
		-- read as an unintended gap rather than an intended asymmetry, so this mirrors the
		-- outright-win branch back onto the caster instead of no-op'ing.
		module.applyMogDebuffs(casterCharacter, casterData)
		transferMogPoints(targetPlayer, targetData, casterPlayer, casterData)
		if diff <= -TERMINATION_THRESHOLD then
			if math.random() < TERMINATION_CHANCE then
				TerminationModule.trigger(casterCharacter)
			end
		end
		return "outclassed"
	else
		-- The "QTE": no QTE/minigame system exists anywhere in this codebase, and building one
		-- (client GUI, RemoteEvent round-trip, timing window, its own exploit surface) is a
		-- separate undertaking - resolved as a weighted instant coin-flip instead, per the user's
		-- own confirmed direction.
		local casterWinChance = math.clamp(0.5 + diff * QTE_SCALE, 0.1, 0.9)
		if math.random() < casterWinChance then
			module.applyMogDebuffs(targetCharacter, targetData)
			transferMogPoints(casterPlayer, casterData, targetPlayer, targetData)
			return "qte_won"
		else
			module.applyMogDebuffs(casterCharacter, casterData)
			transferMogPoints(targetPlayer, targetData, casterPlayer, casterData)
			return "qte_lost"
		end
	end
end

return module
