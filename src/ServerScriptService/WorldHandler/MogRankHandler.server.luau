--!strict
-- Chad rank (added 2026-07-29): replaces the old Grip-based Prestige rank (see the neutralized
-- writes in RankHandler.server.luau) - "I want the mog ranking to appear in the leaderboard and
-- to replace the current grippoints system, which doesn't work." Reuses the exact same
-- PlayerData.Prestige / leaderstats.Prestige field the LeaderboardGui already displays as "#N",
-- so no client GUI changes were needed - only what feeds Prestige changed.
--
-- Deliberately simpler than RankHandler/MoneyRankHandler: no parallel ServerStorage.RankData
-- folder (MogPoints already lives directly on PlayerData, persisted independently via DataStore2,
-- so there's no separate live counter to keep in sync) and no AFK-decay routine (not requested,
-- and one of the more failure-prone parts of the system being replaced - kept out rather than
-- risk reproducing whatever made the old one "not work").
task.wait(2.5)
local DataStoreService = game:GetService("DataStoreService")
local RankDataStore = DataStoreService:GetOrderedDataStore("MogRank")
local PlayerData = game.ServerStorage.PlayerData
local Players = game:GetService("Players")
local AlertModule = require(game.ServerScriptService.Modules.AlertModule)

-- "The mog leaderboard should go from 1 to 250" - a single GetSortedAsync page tops out well
-- under that, so pages are stitched together via AdvanceToNextPageAsync until 250 entries are
-- gathered (or the store genuinely has fewer than that many ranked players).
local MAX_RANK = 250

local currentSorted = {}
local lastSort = 0

-- Same lazy re-fetch-if-stale idiom as RankHandler/MoneyRankHandler's own getSorted(), returning
-- a flat combined array (up to MAX_RANK entries) instead of a raw Pages object, since every
-- caller here just wants an ordered {key, value} list.
local function getSorted()
	if tick() - lastSort < ((4 + #Players:GetPlayers() * 2) / 60) then
		return currentSorted
	end
	lastSort = tick()
	local success, pages = pcall(function()
		return RankDataStore:GetSortedAsync(false, 100)
	end)
	if not success then
		warn("MogRankHandler: failed to fetch sorted data - "..tostring(pages))
		return currentSorted
	end
	local combined = {}
	while true do
		for _, entry in ipairs(pages:GetCurrentPage()) do
			table.insert(combined, entry)
			if #combined >= MAX_RANK then
				break
			end
		end
		if #combined >= MAX_RANK or pages.IsFinished then
			break
		end
		local advanced = pcall(function()
			pages:AdvanceToNextPageAsync()
		end)
		if not advanced then
			break
		end
	end
	currentSorted = combined
	return currentSorted
end

-- Pushes a player's current MogPoints to the OrderedDataStore. Called both right after a mog
-- (via the UpdateMogPoints BindableEvent below, fired from MoggingModule.transferMogPoints) and
-- on leaving, mirroring RankHandler/MoneyRankHandler's own "sync on the way out" safety net.
local function UpdatePlayer(Player)
	local data = PlayerData:FindFirstChild(Player.Name)
	if not data then
		return
	end
	local mogPointsField = data:FindFirstChild("MogPoints")
	if not mogPointsField then
		return
	end
	local success, err = pcall(function()
		RankDataStore:SetAsync(Player.UserId, math.round(mogPointsField.Value))
	end)
	if not success then
		warn("MogRankHandler: failed to set rank data - "..tostring(err))
	end
end

local Updating = false
-- Unlike RankHandler/MoneyRankHandler's own UpdateRankData (which only ever sets a rank for
-- entries actually FOUND in the sorted page, leaving a player's last-known rank stale forever
-- once they drop out of the ranked set entirely) - explicitly zeroes Prestige for every online
-- player not present in the current top-250. That staleness is exactly the kind of thing "doesn't
-- work" could describe, so it isn't reproduced here.
local function UpdateRankData()
	if Updating then
		return
	end
	Updating = true
	local sorted = getSorted()
	local rankByUserId = {}
	for rank, entry in ipairs(sorted) do
		rankByUserId[tonumber(entry.key)] = rank
	end
	for _, Player in ipairs(Players:GetPlayers()) do
		local data = PlayerData:FindFirstChild(Player.Name)
		if data then
			local ok, fail: any = pcall(function()
				data.Prestige.Value = rankByUserId[Player.UserId] or 0
			end)
			if not ok then
				warn(fail)
			end
		end
		task.wait(1 / 30)
	end
	Updating = false
end

local function PlayerAdded(Player)
	local existing = RankDataStore:GetAsync(Player.UserId)
	if existing == nil then
		RankDataStore:SetAsync(Player.UserId, 0)
	end
	local sorted = getSorted()
	for rank, entry in ipairs(sorted) do
		if tonumber(entry.key) == Player.UserId then
			local data = PlayerData:WaitForChild(Player.Name, 5)
			if data then
				data.Prestige.Value = rank
				-- "#1 Ranked Chad has arrived" server-wide announcement (by request) - only fires
				-- for the player who just joined AS the current #1, not on every later resort.
				if rank == 1 then
					local firstName = data.FirstName.Value
					local lastName = data.LastName.Value
					task.spawn(function()
						AlertModule.broadcast("#1 Ranked Chad "..firstName.." "..lastName.." has arrived to Gaia")
					end)
				end
			end
			break
		end
	end
	task.spawn(UpdatePlayer, Player)
end

-- Fired from MoggingModule.transferMogPoints right after a mog changes someone's MogPoints -
-- needs adding in Studio as a BindableEvent child of this script (same asset-debt situation as
-- RankHandler/MoneyRankHandler's own script.UpdateGrips - a plain Instance under a synced Script,
-- not something a .luau file alone can create).
script.UpdateMogPoints.Event:Connect(function(Player)
	UpdatePlayer(Player)
	UpdateRankData()
end)

for _, Player in ipairs(Players:GetPlayers()) do
	PlayerAdded(Player)
end
Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(UpdatePlayer)
