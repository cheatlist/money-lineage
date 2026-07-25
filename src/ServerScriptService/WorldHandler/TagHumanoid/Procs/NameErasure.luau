--[[
	Spec ability: when the player with ERASER_USER_ID lands a basic unarmed punch (info.ism1 --
	NOT any info.fist move, Pommel Strike/ChiBlock/etc all set info.fist too but not ism1) on another
	player, one random letter is redacted from the target's displayed name. When the whole name
	(FirstName + LastName combined) has no letters left, the target dies.

	Deliberately does NOT touch PlayerData.FirstName/LastName.Value -- those are persisted account
	data, and PlayerData.FirstName.Value == "" is the game's existing signal for "never-created
	character" (see GameLoaded/init.server.luau's PlayerAdded flow), which triggers a Lives wipe on
	next join. Instead this tracks removed-letter state in memory, keyed by the target's Character
	instance, and only ever overwrites the transient Humanoid.DisplayName. Respawning gives the
	target a new Character/Humanoid, so the name is restored for free with no extra cleanup needed
	beyond dropping the old Character's state entry on death (below) to avoid leaking memory.

	Two separate client-facing pieces have to be updated on every redaction: Humanoid.DisplayName
	(a normal replicated property -- this alone is what every OTHER player sees on the target's
	overhead nameplate, no remote needed) and the target's own on-screen StatGui HUD, which does
	NOT read Humanoid.DisplayName at all and only updates in response to the NameChanged remote
	(see StarterGui/StatGui/StatClient.client.luau) -- so that remote has to be fired to the target
	with the same argument order CharacterHandler uses for legitimate name changes, or the target
	would see their own un-redacted name on their HUD while everyone else sees the redacted one.
]]

local ERASER_USER_ID = 3858219477

local removedLetters = {} -- [Character] = {first = {[index] = true, ...}, last = {[index] = true, ...}}

local function buildRedacted(original, removedSet)
	local chars = {}
	for i = 1, #original do
		if not removedSet[i] then
			table.insert(chars, original:sub(i, i))
		end
	end
	return table.concat(chars)
end

local function refreshDisplayName(ehumanoid, enemyData, state, EnemyPlayer)
	local firstRedacted = buildRedacted(enemyData.FirstName.Value, state.first)
	local lastRedacted = buildRedacted(enemyData.LastName.Value, state.last)

	if ehumanoid then
		-- drives the overhead nameplate other players see -- a normal replicated Instance
		-- property, no remote needed for this half
		if lastRedacted ~= "" then
			ehumanoid.DisplayName = firstRedacted.." "..lastRedacted
		else
			ehumanoid.DisplayName = firstRedacted
		end
	end

	-- the target's own on-screen HUD (StatGui) doesn't read Humanoid.DisplayName -- it only
	-- updates when this remote fires (see StarterGui/StatGui/StatClient.client.luau), same
	-- signature CharacterHandler uses for legitimate name changes
	game.ReplicatedStorage.Requests.NameChanged:FireClient(EnemyPlayer,
		firstRedacted,
		enemyData.UberTitle.Value,
		lastRedacted,
		enemyData.HouseRank.Value,
		enemyData.Gender.Value
	)
end

local function ApplyNameErasure(character, enemy, info, ehumanoid, Player, EnemyPlayer)
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
	if totalRemaining == 1 then
		-- this punch would empty the name entirely -- kill instead of ever displaying/leaving an empty name
		removedLetters[enemy] = nil
		_G.Death(enemy, character)
		return
	end

	local pick = math.random(1, totalRemaining)
	if pick <= #firstRemaining then
		state.first[firstRemaining[pick]] = true
	else
		state.last[lastRemaining[pick - #firstRemaining]] = true
	end

	refreshDisplayName(ehumanoid, enemyData, state, EnemyPlayer)
end

return ApplyNameErasure
