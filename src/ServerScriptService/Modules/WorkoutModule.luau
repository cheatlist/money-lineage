--[[
	Shared logic for the 5 workout Tools (Pushups/Squats/Situps/Russian Twists/Bent Over Row).
	Doing an exercise for 3 continuous real-time minutes awards 1 point in its body-part
	category (Chest/Legs/Core/Shoulders/Back), capped at 30 points (= 10 Hypertrophy) per
	category. Mirrors the existing MinutesMeditated pattern (Health.server.luau's per-minute
	tick keyed off a Character flag) rather than the client-only /e emote system, which has no
	server hook and can't be trusted for a stat that grants real combat buffs.
]]

local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local CollectionService = game:GetService("CollectionService")

local HYPERTROPHY_TAG = "HypertrophyBoost"

local CATEGORY_STAT = {
	Chest = "WorkoutChestPoints",
	Legs = "WorkoutLegsPoints",
	Core = "WorkoutCorePoints",
	Shoulders = "WorkoutShouldersPoints",
	Back = "WorkoutBackPoints",
}

local EXERCISE_CATEGORIES = {
	Pushups = {"Chest", "Shoulders"},
	Squats = {"Legs"},
	Situps = {"Core"},
	["Russian Twists"] = {"Core"},
	["Bent Over Row"] = {"Back"},
}

local module = {}

-- Hypertrophy level (0-10) for a category, derived from raw points (0-30) rather than stored
-- separately, so there's only one number per category to keep in sync.
function module.hypertrophy(data, category)
	local stat = data:FindFirstChild(CATEGORY_STAT[category])
	if not stat then
		return 0
	end
	return math.floor(stat.Value / 3)
end

-- Recomputes and (re)applies the standing Legs/Core/Chest buffs. Boosts.SpeedBoost and
-- Boosts.AttackSpeedBoost are both shared, summed/stacked names other systems also create
-- instances of (Agility, TheMaster, etc.) - re-finding "mine" by name alone would risk grabbing
-- and overwriting someone else's instance, so this tags its own instances and destroys+recreates
-- only those on every recompute instead of mutating in place.
function module.applyHypertrophyBoosts(character, data)
	local boosts = character:FindFirstChild("Boosts")
	if not boosts or not data then
		return
	end

	for _, child in ipairs(boosts:GetChildren()) do
		if CollectionService:HasTag(child, HYPERTROPHY_TAG) then
			child:Destroy()
		end
	end

	local legs = module.hypertrophy(data, "Legs")
	local core = module.hypertrophy(data, "Core")
	local chest = module.hypertrophy(data, "Chest")

	if legs > 0 then
		local speed = Instance.new("NumberValue")
		speed.Name = "SpeedBoost"
		speed.Value = legs * 0.3
		speed.Parent = boosts
		CollectionService:AddTag(speed, HYPERTROPHY_TAG)
	end

	local atkSpeedMult = 1 + (core * 0.04) + (chest * 0.02)
	if atkSpeedMult > 1 then
		local atkspeed = Instance.new("NumberValue")
		atkspeed.Name = "AttackSpeedBoost"
		atkspeed.Value = atkSpeedMult
		atkspeed.Parent = boosts
		CollectionService:AddTag(atkspeed, HYPERTROPHY_TAG)
	end

	-- HypertrophyDamageMultiplier is a brand new Boosts name (unlike SpeedBoost/AttackSpeedBoost
	-- above), so it's safe to just own the one instance directly rather than tag-and-recreate.
	local dmgMult = 1 + (core * 0.02) + (chest * 0.01)
	if dmgMult > 1 then
		local dmg = boosts:FindFirstChild("HypertrophyDamageMultiplier")
		if not dmg then
			dmg = Instance.new("NumberValue")
			dmg.Name = "HypertrophyDamageMultiplier"
			dmg.Parent = boosts
		end
		dmg.Value = dmgMult
	else
		local dmg = boosts:FindFirstChild("HypertrophyDamageMultiplier")
		if dmg then
			dmg:Destroy()
		end
	end
end

function module.stopExercise(character)
	local marker = character:FindFirstChild("Exercising")
	if marker then
		marker:Destroy()
	end
	local minutes = character:FindFirstChild("ExerciseMinutes")
	if minutes then
		minutes:Destroy()
	end
end

-- Called from a Tool's Activated handler. Pressing the same exercise's Tool again cancels it;
-- pressing it while blocked by ActionCheck (or, for Bent Over Row, without WeightsOwned) no-ops.
function module.toggleExercise(tool, character, data, exerciseName, requiresWeights)
	local existing = character:FindFirstChild("Exercising")
	if existing then
		if existing.Value == exerciseName then
			module.stopExercise(character)
		end
		return
	end

	if requiresWeights and not (data and data.WeightsOwned.Value) then
		return
	end

	if ActionCheckModule(character, {
		presentBlocks = {"Stun", "NoDam", "ReturnStun", "Action", "Blocking", "SpellBlocking", "ActiveCast", "Unconscious", "Knocked", "Immortal", "Grabbed"},
	}) then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	local marker = Instance.new("StringValue")
	marker.Name = "Exercising"
	marker.Value = exerciseName
	marker.Parent = character

	local minutes = Instance.new("NumberValue")
	minutes.Name = "ExerciseMinutes"
	minutes.Parent = character

	local anim = tool:FindFirstChild("Anim")
	local track
	if anim then
		track = humanoid:LoadAnimation(anim)
		track.Looped = true
		track:Play()
	end

	task.spawn(function()
		while character.Parent and character:FindFirstChild("Exercising") do
			task.wait(0.2)
			if not character.Parent then
				break
			end
			if not character:FindFirstChild("Exercising") then
				break
			end
			if tool.Parent ~= character then
				break
			end
			if humanoid.MoveDirection.Magnitude > 0.6 then
				break
			end
			if requiresWeights and not (data and data.WeightsOwned.Value) then
				break
			end
		end
		if track then
			track:Stop()
		end
		module.stopExercise(character)
	end)
end

-- Called from Health.server.luau's existing per-real-minute tick, alongside MinutesMeditated.
function module.tickMinute(character, data)
	local exercising = character:FindFirstChild("Exercising")
	if not exercising then
		return
	end
	local categories = EXERCISE_CATEGORIES[exercising.Value]
	if not categories then
		return
	end
	local minutes = character:FindFirstChild("ExerciseMinutes")
	if not minutes then
		return
	end

	minutes.Value += 1
	if minutes.Value < 3 then
		return
	end
	minutes.Value = 0

	local changed = false
	for _, category in ipairs(categories) do
		local stat = data:FindFirstChild(CATEGORY_STAT[category])
		if stat and stat.Value < 30 then
			stat.Value = math.min(30, stat.Value + 1)
			changed = true
		end
	end
	if changed then
		module.applyHypertrophyBoosts(character, data)
	end
end

return module
