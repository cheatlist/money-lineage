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
	the transient Humanoid.DisplayName (plus the leaderstats mirror below). Respawning gives either
	side a new Character/Humanoid, so both the redaction and the stolen letters reset for free with
	no extra cleanup needed beyond dropping the old Character's state entry on death (below) to
	avoid leaking memory.

	Both sides also revert to their normal name on their own, RESET_DELAY seconds after the last
	letter stolen from that encounter, via a task.delay tracked as state.resetThread -- every new
	theft (giveStolenLetter for the attacker, ApplyNameErasure for the victim) cancels and
	re-schedules it, so the timer only fires after a full RESET_DELAY of inactivity. Dying (or, for
	the victim, taking the killing letter) cancels the pending timer since the state it would act on
	is being dropped anyway.

	The victim's removedLetters state tracks WHICH CHARACTER INDEXES have been stolen, not the
	letters themselves, so it has to stay aligned to one fixed string for the whole encounter --
	that's state.originalFirst/originalLast, snapshotted once when the encounter starts. Items like
	"Switch Witch" (ServerStorage/Storage/Switch Witch) rewrite PlayerData.FirstName/Gender live
	mid-fight (a gender-swapped alt name); reading enemyData.FirstName.Value fresh on every hit
	instead of from a snapshot would silently desync those indexes the moment the name underneath
	them changed. The final revert-to-normal (RESET_DELAY timer / death) deliberately reads
	enemyData.FirstName.Value live instead of the snapshot, since by then the encounter's over and
	it should restore whatever the player's name currently, actually is.

	The attacker's stolenLetters state doesn't have that index-alignment problem (state.first/last
	are self-contained strings, built by inserting into a snapshot, not positions into a live one) --
	but a mid-encounter rename on EITHER side still causes a display race: CharacterHandler also
	listens for PlayerData.FirstName/LastName.Changed and unconditionally stomps Humanoid.DisplayName/
	leaderstats/NameChanged back to the plain real name the instant it fires, undoing whatever
	redacted/stolen-letters look this module had just set. watchForExternalRename reconnects to that
	same signal and reasserts this module's current display on top, so an item like Switch Witch used
	mid-encounter doesn't leave (or briefly flash) the wrong name on the nameplate/HUD/leaderboard.

	Three separate client-facing pieces have to be updated on every change, for BOTH sides: Humanoid.
	DisplayName (a normal replicated property -- this alone is what every OTHER player sees on that
	character's overhead nameplate, no remote needed), that player's own on-screen StatGui HUD, which
	does NOT read Humanoid.DisplayName at all and only updates in response to the NameChanged remote
	(see StarterGui/StatGui/StatClient.client.luau) -- so that remote has to be fired to whichever
	player's name changed, with the same argument order CharacterHandler uses for legitimate name
	changes, or that player would see their own stale name on their HUD while everyone else sees the
	updated one -- and leaderstats.FirstName/LastName, which is what LeaderboardGui reads (see
	StarterGui/LeaderboardGui/LeaderboardClient.client.luau), same fields CharacterHandler keeps in
	sync for legitimate name changes.
]]

local ERASER_USER_ID = 3858219477
local RESET_DELAY = 180 -- seconds of no new theft before a name reverts to normal

local removedLetters = {} -- [Character] = {first = {[index] = true, ...}, last = {[index] = true, ...}, resetThread = thread?}
local stolenLetters = {} -- [Character] = {first = "currentDisplayedFirstName", last = "currentDisplayedLastName", resetThread = thread?}

-- cancels the pending revert-to-normal timer, if one is scheduled -- called both when a fresh
-- theft pushes the timer back out and when the character dies (state's about to be dropped anyway)
local function cancelReset(state)
	if state and state.resetThread then
		task.cancel(state.resetThread)
		state.resetThread = nil
	end
end

-- items like "Switch Witch" (ServerStorage/Storage/Switch Witch) rewrite PlayerData.FirstName/
-- LastName/Gender live, and CharacterHandler listens for that Changed signal to stomp Humanoid.
-- DisplayName/leaderstats/the NameChanged remote back to the plain real name -- registered after
-- CharacterHandler's own listener (it's only ever connected once a theft/redaction is already in
-- progress, well after character spawn), so it fires second and gets the last word, reasserting
-- whatever this module is currently showing on top of that stomp. Returns a function that
-- disconnects both listeners, to be called from every path that clears the state.
local function watchForExternalRename(data, resync)
	local firstConn = data.FirstName.Changed:Connect(resync)
	local lastConn = data.LastName.Changed:Connect(resync)
	return function()
		firstConn:Disconnect()
		lastConn:Disconnect()
	end
end

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

-- leaderstats otherwise keeps showing the redacted/stolen name for a dead character until
-- CharacterHandler's spawn code re-derives it from PlayerData on respawn -- reset it immediately
-- on death instead of leaving a stale name on the leaderboard in the meantime
local function resetLeaderstats(player, data)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		leaderstats.FirstName.Value = data.FirstName.Value
		leaderstats.LastName.Value = data.LastName.Value
	end
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

	-- LeaderboardGui reads leaderstats.FirstName/LastName (not Humanoid.DisplayName or PlayerData),
	-- same fields CharacterHandler keeps in sync for legitimate name changes
	local leaderstats = targetPlayer:FindFirstChild("leaderstats")
	if leaderstats then
		leaderstats.FirstName.Value = first
		leaderstats.LastName.Value = last
	end
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
		state.stopWatching = watchForExternalRename(attackerData, function()
			if stolenLetters[character] == state then
				syncDisplayName(humanoid, Player, attackerData, state.first, state.last)
			end
		end)
		if humanoid then
			humanoid.Died:Once(function()
				cancelReset(state)
				state.stopWatching()
				stolenLetters[character] = nil
				resetLeaderstats(Player, attackerData)
			end)
		end
	end

	if math.random(1, 2) == 1 then
		state.first = insertAtRandom(state.first, stolenLetter)
	else
		state.last = insertAtRandom(state.last, stolenLetter)
	end

	syncDisplayName(humanoid, Player, attackerData, state.first, state.last)

	cancelReset(state)
	state.resetThread = task.delay(RESET_DELAY, function()
		state.stopWatching()
		stolenLetters[character] = nil
		syncDisplayName(humanoid, Player, attackerData, attackerData.FirstName.Value, attackerData.LastName.Value)
	end)
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
		-- snapshot the name once, up front -- items like "Switch Witch" (ServerStorage/Storage/Switch
		-- Witch) rewrite PlayerData.FirstName/Gender live, and state.first/state.last below are index
		-- sets into this string; re-reading enemyData.FirstName.Value on every hit would let a
		-- mid-encounter rename desync those indices from whatever name is currently live
		state = {first = {}, last = {}, originalFirst = enemyData.FirstName.Value, originalLast = enemyData.LastName.Value}
		removedLetters[enemy] = state
		state.stopWatching = watchForExternalRename(enemyData, function()
			if removedLetters[enemy] == state then
				syncDisplayName(ehumanoid, EnemyPlayer, enemyData,
					buildRedacted(state.originalFirst, state.first),
					buildRedacted(state.originalLast, state.last))
			end
		end)
		if ehumanoid then
			ehumanoid.Died:Once(function()
				cancelReset(state)
				state.stopWatching()
				removedLetters[enemy] = nil
				resetLeaderstats(EnemyPlayer, enemyData)
			end)
		end
	end

	local firstRemaining = {}
	for i = 1, #state.originalFirst do
		if not state.first[i] then
			table.insert(firstRemaining, i)
		end
	end
	local lastRemaining = {}
	for i = 1, #state.originalLast do
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
		stolenLetter = state.originalFirst:sub(idx, idx)
	else
		local idx = lastRemaining[pick - #firstRemaining]
		state.last[idx] = true
		stolenLetter = state.originalLast:sub(idx, idx)
	end

	giveStolenLetter(character, humanoid, Player, stolenLetter)

	if totalRemaining == 1 then
		-- that was the target's last letter -- kill instead of ever displaying/leaving an empty name
		cancelReset(state)
		state.stopWatching()
		removedLetters[enemy] = nil
		_G.Death(enemy, character)
		return
	end

	local firstRedacted = buildRedacted(state.originalFirst, state.first)
	local lastRedacted = buildRedacted(state.originalLast, state.last)
	syncDisplayName(ehumanoid, EnemyPlayer, enemyData, firstRedacted, lastRedacted)

	cancelReset(state)
	state.resetThread = task.delay(RESET_DELAY, function()
		state.stopWatching()
		removedLetters[enemy] = nil
		syncDisplayName(ehumanoid, EnemyPlayer, enemyData, enemyData.FirstName.Value, enemyData.LastName.Value)
	end)
end

return ApplyNameErasure
