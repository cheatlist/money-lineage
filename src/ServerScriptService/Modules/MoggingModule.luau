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

local EATING_INJURIES = {"VomitForcer", "LackEater", "AnythingEater"}
local DEBUFF_DURATION = 900 -- 1 in-game day, matches Health.server.luau's day length (15 min)
local TERMINATION_CHANCE = 0.15
local ATTRACTIVENESS_THRESHOLD = 8
local TERMINATION_THRESHOLD = 10
local QTE_SCALE = 0.03

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

-- Takes already-computed Attractiveness numbers (the Mogging Tool script owns calling
-- AttractivenessModule.compute for both sides - this module doesn't require that one itself, to
-- keep AttractivenessModule -> MoggingModule a one-directional dependency, since
-- AttractivenessModule.compute also calls into this module for its own self-trigger).
function module.resolve(casterCharacter, casterData, casterAttr, targetCharacter, targetData, targetAttr)
	local diff = casterAttr - targetAttr

	if diff >= ATTRACTIVENESS_THRESHOLD then
		module.applyMogDebuffs(targetCharacter, targetData)
		if diff >= TERMINATION_THRESHOLD then
			if math.random() < TERMINATION_CHANCE then
				TerminationModule.trigger(targetCharacter)
			end
			return "won"
		elseif diff <= -ATTRACTIVENESS_THRESHOLD then
			-- Not explicitly described in the request (which only covers "clearly ahead" and
			-- "comparable") - mogging someone clearly more attractive than you leaving no downside
			-- read as an unintended gap rather than an intended asymmetry, so this mirrors the
			-- outright-win branch back onto the caster instead of no-op'ing.
			if diff <= -TERMINATION_THRESHOLD then
				if math.random() < TERMINATION_CHANCE then
					TerminationModule.trigger(casterCharacter)
				end
				module.applyMogDebuffs(casterCharacter, casterData)
				return "outclassed"
			else
				-- The "QTE": no QTE/minigame system exists anywhere in this codebase, and building one
				-- (client GUI, RemoteEvent round-trip, timing window, its own exploit surface) is a
				-- separate undertaking - resolved as a weighted instant coin-flip instead, per the user's
				-- own confirmed direction.
				local casterWinChance = math.clamp(0.5 + diff * QTE_SCALE, 0.1, 0.9)
				if math.random() < casterWinChance then
					module.applyMogDebuffs(targetCharacter, targetData)
					return "qte_won"
				else
					module.applyMogDebuffs(casterCharacter, casterData)
					return "qte_lost"
				end
			end
		end
	end
end

return module
