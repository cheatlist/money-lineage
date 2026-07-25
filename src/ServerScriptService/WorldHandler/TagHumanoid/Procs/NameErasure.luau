--[[
	Spec ability: when the player with ERASER_USER_ID lands a basic unarmed punch (info.ism1 --
	NOT any info.fist move, Pommel Strike/ChiBlock/etc all set info.fist too but not ism1) on another
	player, one random letter is redacted from the target's displayed name and inserted at a random
	position into the attacker's own displayed name (First or Last, picked at random). When the
	target's whole name (FirstName + LastName combined) has no letters left, they die.

	Deliberately does NOT touch PlayerData.FirstName/LastName.Value for either side -- those are
	persisted account data, and PlayerData.FirstName.Value == "" is the game's existing signal for
	"never-created character" (see GameLoaded/init.server.luau's PlayerAdded flow), which triggers a
	Lives wipe on next join. Instead this tracks state in memory, keyed by Character instance (both
	the target's redaction state and the attacker's stolen-letters state), and only ever overwrites
	the transient Humanoid.DisplayName. Respawning gives either side a new Character/Humanoid, so
	both the redaction and the stolen letters reset for free with no extra cleanup needed beyond
	dropping the old Character's state entry on death (below) to avoid leaking memory.

	Two separate client-facing pieces have to be updated on every change, for BOTH sides: Humanoid.
	DisplayName (a normal replicated property -- this alone is what every OTHER player sees on that
	character's overhead nameplate, no remote needed) and that player's own on-screen StatGui HUD,
	which does NOT read Humanoid.DisplayName at all and only updates in response to the NameChanged
	remote (see StarterGui/StatGui/StatClient.client.luau) -- so that remote has to be fired to
	whichever player's name changed, with the same argument order CharacterHandler uses for
	legitimate name changes, or that player would see their own stale name on their HUD while
	everyone else sees the updated one.
]]

local ERASER_USER_ID = 3858219477

local removedLetters = {} -- [Character] = {first = {[index] = true, ...}, last = {[index] = true, ...}}
local stolenLetters = {} -- [Character] = {first = "currentDisplayedFirstName", last = "currentDisplayedLastName"}

local function buildRedacted(original, removedSet)
	local chars = {}
	for i = 1, #original do
		if not removedSet[i] then
			table.insert(chars, original:sub(i, i))
		end
	end
	return table.concat(chars)
end

local function insertAtRandom(str, letter)
	local pos = math.random(1, #str + 1)
	return str:sub(1, pos - 1)..letter..str:sub(pos)
end

local function syncDisplayName(targetHumanoid, targetPlayer, targetData, first, last)
	if targetHumanoid then
		-- drives the overhead nameplate other players see -- a normal replicated Instance
		-- property, no remote needed for this half
		if last ~= "" then
			targetHumanoid.DisplayName = first.." "..last
		else
			targetHumanoid.DisplayName = first
		end
	end

	-- that player's own on-screen HUD (StatGui) doesn't read Humanoid.DisplayName -- it only
	-- updates when this remote fires (see StarterGui/StatGui/StatClient.client.luau), same
	-- signature CharacterHandler uses for legitimate name changes
	game.ReplicatedStorage.Requests.NameChanged:FireClient(targetPlayer,
		first,
		targetData.UberTitle.Value,
		last,
		targetData.HouseRank.Value,
		targetData.Gender.Value
	)
end

local function giveStolenLetter(character, humanoid, Player, stolenLetter)
	local attackerData = game.ServerStorage.PlayerData:FindFirstChild(Player.Name)
	if not attackerData then
		return
	end

	local state = stolenLetters[character]
	if not state then
		state = {first = attackerData.FirstName.Value, last = attackerData.LastName.Value}
		stolenLetters[character] = state
		if humanoid then
			humanoid.Died:Once(function()
				stolenLetters[character] = nil
			end)
		end
	end

	if math.random(1, 2) == 1 then
		state.first = insertAtRandom(state.first, stolenLetter)
	else
		state.last = insertAtRandom(state.last, stolenLetter)
	end

	syncDisplayName(humanoid, Player, attackerData, state.first, state.last)
end

local function ApplyNameErasure(character, enemy, info, humanoid, ehumanoid, Player, EnemyPlayer)
	if character == enemy then
		return
	end
	if not Player or Player.UserId ~= ERASER_USER_ID then
		return
	end
	if not info.fist or not info.ism1 then
		return
	end
	if not EnemyPlayer then
		return
	end

	local enemyData = game.ServerStorage.PlayerData:FindFirstChild(EnemyPlayer.Name)
	if not enemyData then
		return
	end

	local state = removedLetters[enemy]
	if not state then
		state = {first = {}, last = {}}
		removedLetters[enemy] = state
		if ehumanoid then
			ehumanoid.Died:Once(function()
				removedLetters[enemy] = nil
			end)
		end
	end

	local firstRemaining = {}
	for i = 1, #enemyData.FirstName.Value do
		if not state.first[i] then
			table.insert(firstRemaining, i)
		end
	end
	local lastRemaining = {}
	for i = 1, #enemyData.LastName.Value do
		if not state.last[i] then
			table.insert(lastRemaining, i)
		end
	end

	local totalRemaining = #firstRemaining + #lastRemaining
	if totalRemaining <= 0 then
		return
	end

	local pick = math.random(1, totalRemaining)
	local stolenLetter
	if pick <= #firstRemaining then
		local idx = firstRemaining[pick]
		state.first[idx] = true
		stolenLetter = enemyData.FirstName.Value:sub(idx, idx)
	else
		local idx = lastRemaining[pick - #firstRemaining]
		state.last[idx] = true
		stolenLetter = enemyData.LastName.Value:sub(idx, idx)
	end

	giveStolenLetter(character, humanoid, Player, stolenLetter)

	if totalRemaining == 1 then
		-- that was the target's last letter -- kill instead of ever displaying/leaving an empty name
		removedLetters[enemy] = nil
		_G.Death(enemy, character)
		return
	end

	local firstRedacted = buildRedacted(enemyData.FirstName.Value, state.first)
	local lastRedacted = buildRedacted(enemyData.LastName.Value, state.last)
	syncDisplayName(ehumanoid, EnemyPlayer, enemyData, firstRedacted, lastRedacted)
end

return ApplyNameErasure
