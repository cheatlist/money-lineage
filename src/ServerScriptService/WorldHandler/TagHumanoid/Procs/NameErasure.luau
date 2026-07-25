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

local function refreshDisplayName(ehumanoid, enemyData, state)
	if not ehumanoid then
		return
	end
	local firstRedacted = buildRedacted(enemyData.FirstName.Value, state.first)
	local lastRedacted = buildRedacted(enemyData.LastName.Value, state.last)
	if lastRedacted ~= "" then
		ehumanoid.DisplayName = firstRedacted.." "..lastRedacted
	else
		ehumanoid.DisplayName = firstRedacted
	end
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

	refreshDisplayName(ehumanoid, enemyData, state)
end

return ApplyNameErasure
