--!strict
task.wait(2.5)
local DataStoreService = game:GetService("DataStoreService")
local RankDataStore = DataStoreService:GetOrderedDataStore("GripRank") --Ranks6
local RankDataFolder = game:GetService("ServerStorage").RankData
local currentSorted:Pages = RankDataStore:GetSortedAsync(false,100)
local lastSort = tick()

local PlayerData = game.ServerStorage.PlayerData
local Players = game:GetService("Players")
local Requests = game.ServerStorage:WaitForChild("Requests")
local embedOverrides = {
	footer = {
		icon_url = "https://media.discordapp.net/attachments/844644040939143170/924055429082939422/caption-21.gif",
		text =  "Server: ".. game.JobId.. " | Version: | "..game.PlaceVersion.." ",
	}
}

local ServerHandlesGlobals = game.ServerStorage:WaitForChild("ServerHandlesGlobals")
local LastPlayedDataStore = DataStoreService:GetDataStore("LastPlayed")
local lastAfkCheck = 0

local tim = os.time() - (86400 * 3)
local totalDaysAfk = (os.time() - tim)/86400

local subtract = 10
for num = 1,totalDaysAfk do
	subtract *= num
end

local function getSorted()
	if tick() - lastSort >= ((4 + #Players:GetPlayers() * 2)/60) then
		lastSort = tick()
		return RankDataStore:GetSortedAsync(false,100) 
	end
	return currentSorted
end

local working = false
local function AfkCheck()
	if working then return end
	task.spawn(function()
		working = true
		if ServerHandlesGlobals.Value == true then
			if tick() - lastAfkCheck >= 1000 then
				currentSorted = getSorted()
				local checkTime = os.time()
				for rank,data in currentSorted:GetCurrentPage() do
					local userId = tonumber(data.key)
					local grips:any = tonumber(data.value)
					local pData = LastPlayedDataStore:GetAsync(userId)
					if pData == nil then
						LastPlayedDataStore:SetAsync(userId,{lastPlayed = os.time(),currentStreak = 0})
						task.wait(1)
						continue
					elseif typeof(pData) == "table" then
						local lastPlayed = pData.lastPlayed
						local currentStreak = pData.currentStreak
						local totalDaysAfk = (checkTime - lastPlayed)/86400
						local subtract = 15
						local n = 0
						for num = 1,totalDaysAfk do
							n = num
							subtract *= num
						end
						if n > currentStreak then
							currentStreak = n
							LastPlayedDataStore:SetAsync(userId,{lastPlayed = lastPlayed,currentStreak = currentStreak})
							local after = math.round(math.max(grips-subtract,0))
							RankDataStore:SetAsync(userId,after)
							Requests.SendWebhook:Fire("Player lost some rank due to inactivity",
								"Player: "..Players:GetNameFromUserIdAsync(userId).."|"..tostring(userId).."\n Before: "..tostring(grips).."\n After: "..tostring(after).."\n Streak: "..tostring(currentStreak).. " days",
								"red",
								"RankUpdates",embedOverrides)
							task.wait(2)
							continue
						end
						task.wait(0.85)
					end
				end
				lastAfkCheck = tick()
			end
		end
		working = false
	end)
end

local Updating = false

local function UpdateRankData()
	--AfkCheck()
	if Updating == true then
		return
	end
	Updating = true
	currentSorted = getSorted()
	local Top100 = currentSorted:GetCurrentPage()
	for Rank,Data in pairs(Top100)do
		for _,Player in pairs(Players:GetPlayers())do
			if Data.key == Player.UserId then
				local success,fail:any = pcall(function()
					local RankFolder = game.ServerStorage.RankData:FindFirstChild(Player.Name)
					if not RankFolder then
						return
					end
					if RankFolder.Grips.Value<50 then
						PlayerData[Player.Name].Prestige.Value = 0
						return
					end
					PlayerData[Player.Name].Prestige.Value = Rank
				end)
				if not success then
					warn(fail)
					continue
				end
			end
		end
		task.wait()
	end
	Updating = false
end

local function UpdatePlayer(Player,NoRemove)
	--AfkCheck()
	local PlayerFolder = RankDataFolder:FindFirstChild(Player.Name)
	if (not PlayerFolder) then return end
	if Player:IsDescendantOf(workspace.Live) then
		Player = game.Players:GetPlayerFromCharacter(Player)
	end
	local Grips = PlayerFolder.Grips.Value
	if not NoRemove then
		PlayerFolder:Destroy()
		if not Player:FindFirstChild("recentJoin") then
			LastPlayedDataStore:SetAsync(Player.UserId,{lastPlayed = os.time(),currentStreak = 0})
		end
		if task.wait(0.1)and game.ServerStorage:FindFirstChild("ServerShutdown") then
			return
		end
		if Player:FindFirstChild("Danger") then
			Grips = math.max(Grips * 0.85,0)
		end
	end
	local Success, Error = pcall(function()
		RankDataStore:SetAsync(Player.UserId,math.round(Grips))
	end)
	if not Success then
		error("failed to set rank data:\n"..Error)
	end
end

script.UpdateGrips.Event:Connect(function(Player)
	local Grips = RankDataFolder:FindFirstChild(Player.Name).Grips
	local PlayerData = game.ServerStorage.PlayerData
	local playerData = PlayerData:FindFirstChild(Player.Name)
	--if Player.Backpack:FindFirstChild("NoKill")then
	--	return
	--end
	--game.ServerScriptService.Modules.Commands.ChangeInsight(Player, playerData, 1)
	Grips.Value += 1
	UpdatePlayer(Player,true)
	UpdateRankData()
end)

local function PlayerAdded(Player)
	--AfkCheck()
	local Grips = RankDataStore:GetAsync(Player.UserId)
	currentSorted = getSorted()
	local Top100 = currentSorted:GetCurrentPage()

	local PlayerFolder = Instance.new("Accessory")
	PlayerFolder.Name = Player.Name
	PlayerFolder.Parent = RankDataFolder

	if not Grips then
		Grips = 0
		RankDataStore:SetAsync(Player.UserId, 0)
	end

	local GripVal = Instance.new("NumberValue")
	GripVal.Name = "Grips"
	GripVal.Value = Grips
	GripVal.Parent = PlayerFolder

	for rank,data in pairs(Top100)do
		local PlayerKey = tonumber(data.key)
		if PlayerKey == Player.UserId and GripVal.Value > 50 then
			game.ServerStorage.PlayerData:WaitForChild(Player.Name,500).Prestige.Value = rank
			break
		end
	end
	task.spawn(function()
		task.wait(500)
		if Player and Player.Parent then
			LastPlayedDataStore:SetAsync(Player.UserId,{lastPlayed = os.time(),currentStreak = 0})
		end
	end)
	task.spawn(function()
		UpdatePlayer(Player, true)
	end)
	UpdateRankData()
end

for _,v in game.Players:GetPlayers() do
	PlayerAdded(v)
end
Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(UpdatePlayer)