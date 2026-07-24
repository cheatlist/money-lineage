--because messaging service is for pussies
--norperz #5/28/2022
--norp#7889
--the idea here is to establish commands that will run across servers, allowing for specific data management
--current things to do: Ask servers if a player is in there server to prevent multi-box duping. Ask server to ban user, if all of the responses to the event are false then ban them urself
--[[
Example process:
	jobId abc123 sends a request to all servers with the parameters {LifeTime = {Start = tick(), Time = 5}, Origin = game.JobId, Request = "BanPlayer", MetaData = {Victim = UserId}, ReturnData = {}}
	(MetaData includes data to use with requests and ReturnData is where responses will be placed. This will be looped through over and over until the lifeTime has expired, it will be repeated in the origin server but the other servers will run it once)
]]
local ms = game:GetService("MemoryStoreService")
map = ms:GetSortedMap("CrossServerMessaging")
local PlayerData = game.ServerStorage.PlayerData
local TrelloGrabber = game.ServerScriptService:WaitForChild("TrelloGrabber")
local ServerHandlesGlobals = game.ServerStorage:WaitForChild("ServerHandlesGlobals")

--map:SetAsync("{A-0}", 
--	{LifeTime = {Start = tick(), Time = 5},
--	Origin = "{A-0}",
--	Request = "BanPlayer",
--	MetaData = {Victim = 21609523},
--	ReturnData = {},
--	AbortRequest = false}
--	,15)
--map:SetAsync("{A-0}",
--	{LifeTime = {Start = tick(), Time = 15},
--	Origin = "{A-0}",
--	Request = "BringPlayer",
--	MetaData = {Victim = 21609523, PlaceId = 0, JobId = game.JobId},
--	ReturnData = {},
--	AbortRequest = false}
--	,15)
function PrintAllKeys(map)
	local exclusiveLowerBound = nil
	local keys = {}
	while true do
		local items = map:GetRangeAsync(Enum.SortDirection.Ascending, 200, exclusiveLowerBound)
		for i, entry in ipairs(items) do
			table.insert(keys,entry)
		end
		if #items < 200 then
			break
		end
		exclusiveLowerBound = items[#items].key
		task.wait(2)
	end
	return keys
end

function getPlayers()
	local s = {}
	for _,v in pairs(game.Players:GetPlayers()) do
		table.insert(s,{Username = v.Name, UserId = v.UserId})
	end
	return s
end

task.spawn(function()
	local function inception()
		task.wait()
		local function dryhands()
			map = ms:GetSortedMap("CrossServerMessaging")
			while true do
				local currentdat = PrintAllKeys(map)
				for _,v in pairs(currentdat) do
					--{LifeTime = {Start = tick(), Time = 5}, Origin = game.JobId, Request = "BanPlayer", MetaData = {Victim = UserId}, ReturnData = {}, AbortRequest = false}
					local Key = v.key
					v = v.value
					if v.Origin ~= game.JobId and not v.ReturnData[game.JobId] and v.AbortRequest == false then
						local update = false
						if v.Request == "addAction" then
							if ServerHandlesGlobals.Value == true then
								v.AbortRequest = true
								update = true
								TrelloGrabber.PublishRequest:Fire(v.MetaData.UserId,v.MetaData.actionType)
							end
						elseif v.Request == "GotoGlobalHandler" then
							if ServerHandlesGlobals.Value == true then
								v.ReturnData[game.JobId] = true
								v.AbortRequest = true
								update = true
							else
								v.ReturnData[game.JobId] = false
								update = true
							end
						elseif v.Request == "ListPlayers" then
							v.ReturnData[game.JobId] = getPlayers()
							update = true
						elseif v.Request == "BanPlayer" then
							local p = game.Players:GetPlayerByUserId(v.MetaData.Victim)
							if p then
								local data = PlayerData:WaitForChild(p.Name,0.5)
								if data then
									if _G.GetAdminLevel(p.UserId) >= v.MetaData.SpeakerAdminLevel then
										v.AbortRequest = true
									else
										game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(p.Name, true)
										p:Kick("You have been banned.")
										v.AbortRequest = true
									end
									update = true
								end
							end
						elseif v.Request == "RestorePlayer" then
							local p = game.Players:GetPlayerByUserId(v.MetaData.Victim)
							if p then
								local data = PlayerData:WaitForChild(p.Name,0.5)
								if data then
									local Lives = 1
									if PlayerData[p.Name].Race.Value == "Cameo" then Lives = 4 end
									if PlayerData[p.Name].Lives.Value < Lives then
										PlayerData[p.Name].Lives.Value += 1
									end
									v.AbortRequest = true
									update = true
								end
							end
						elseif v.Request == "BringPlayer" then						
							local p = game.Players:GetPlayerByUserId(v.MetaData.Victim)
							if p then
								update = true
								v.AbortRequest = true
								game.ReplicatedStorage.Requests.GlobalMessage:FireClient(p,"You are being summoned to a server")
								local c = p.Character or p.CharacterAdded:wait()
								Instance.new("ForceField",c)
								Instance.new("Accessory",c).Name = "NoControl"
								Instance.new("Accessory",c).Name = "SuspendAllMovement"
								Instance.new("Accessory",c).Name = "Immortal"
								local prt = game.ServerStorage.Assets.Seraphim.AngelForm.ParticleEmitter:clone()
								prt.Parent = c.Torso
								task.spawn(function()
									while game.Players:GetPlayerByUserId(v.MetaData.Victim) ~= nil do
										pcall(function()
											for _,v in pairs(p:GetDescendants()) do
												if v.Name == "Danger" then
													v:Destroy()
												end
											end
											if v.MetaData.ReserveId then
												game["Teleport Service"]:TeleportToPrivateServer(v.MetaData.PlaceId,v.MetaData.ReserveId,{p})
											else
												game["Teleport Service"]:TeleportToPlaceInstance(v.MetaData.PlaceId,v.MetaData.JobId,p)
											end

										end)
										task.wait(5)
									end
								end)
							end
						end
						if update == true then
							map:UpdateAsync(Key, function(tab)
								tab.LifeTime = v.LifeTime
								tab.Origin = v.Origin
								tab.Request = v.Request
								tab.MetaData = v.MetaData
								tab.ReturnData = v.ReturnData
								tab.AbortRequest = v.AbortRequest
								return tab
							end, v.LifeTime.Time)
						end
					end
				end
				task.wait(5 + (math.random(1,100)/100))
			end
		end
		local pc,ret = pcall(dryhands)
		if not pc then
			task.wait(5)
			inception()
			return
		end
	end
	inception()
end)

script.PublishRequest.Event:Connect(function(Key,RequestInfo)
	return map:SetAsync(Key, 
		RequestInfo, 
		RequestInfo.LifeTime.Time)
end)