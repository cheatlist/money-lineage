local DataStoreService = game:GetService('DataStoreService')
--local BanStore = DataStoreService:GetDataStore('BannedPlayers3', 'Gaia')
local Players = game:GetService('Players')
local TeleportService = game:GetService('TeleportService')
local Command = game:GetService'ReplicatedStorage':WaitForChild'Requests':WaitForChild'Command'
local HttpService = game:GetService'HttpService'
local msgservice = game:GetService('MessagingService')
local PlayerData = game:GetService("ServerStorage").PlayerData
local remote = game:GetService('ReplicatedStorage'):WaitForChild'Requests':WaitForChild'GlobalMessage'
local DS2 = game:GetService("ServerScriptService").Modules.DataStore2
local clientNotify = game.ReplicatedStorage.Requests.ClientMessage
local CommandsModule = require(game:GetService("ServerScriptService").Modules.Commands)
local PlayerData = game.ServerStorage.PlayerData
local ms = game:GetService("MemoryStoreService")
local TrelloGrabber = game.ServerScriptService:WaitForChild("TrelloGrabber")
local ServerHandlesGlobals = game.ServerStorage:WaitForChild("ServerHandlesGlobals")
map = ms:GetSortedMap("CrossServerMessaging")


--boredrogue-fd625-default-rtdb
--tjQlfAwWFNYmEh7Sm1MISF5oVu2x1Skq7xebeggA

local Recent = {}
local LastReport = 0

local function GetPlayer(Name)
	Name = Name:lower()
	for Index, Player in ipairs(Players:GetPlayers()) do
		if Player.Name:lower():sub(1, #Name) == Name then
			return Player
		end
	end
	return false
end

local function Send(Title, Content, Color)
	game.ServerStorage.Requests.SendWebhook:Fire(
		Title,
		Content,
		Color
	)
end

function updateActions(UserId,actionType)
	if ServerHandlesGlobals.Value == true then
		TrelloGrabber.PublishRequest:Fire(UserId,actionType)
	else
		game.ServerScriptService.CrossServerMessaging.PublishRequest:Fire(game.HttpService:GenerateGUID().."addAction"..UserId,
			{LifeTime = {Start = tick(), Time = 5},
			Origin = game.JobId,
			Request = "addAction",
			MetaData = {UserId = UserId, actionType = actionType},
			ReturnData = {},
			AbortRequest = false}
		)
	end
end

function restore(Speaker, Message, Name)
	if not Name then return 'No name' end
	local Player = GetPlayer(Name) 

	if not Player then 
		local target = game.Players:GetUserIdFromNameAsync(Name)
		if target then
			local start = tick()
			local Key = game.HttpService:GenerateGUID().."RestorePlayer"..target
			game.ServerScriptService.CrossServerMessaging.PublishRequest:Fire(Key,
				{LifeTime = {Start = start, Time = 15},
				Origin = game.JobId,
				Request = "RestorePlayer",
				MetaData = {Victim = target, SpeakerAdminLevel = _G.GetAdminLevel(Speaker.UserId)},
				ReturnData = {},
				AbortRequest = false}
			)
			task.spawn(function()
				local success = false
				while tick() - start < 7.5 do
					local d = map:GetAsync(Key)
					if d and d.AbortRequest == true then
						success = true
						map:RemoveAsync(Key)
						break
					end
					task.wait(.75)
				end
				if success == false then
					local Success, ID = pcall(Players.GetUserIdFromNameAsync, Players, Name)

					if Success and ID then
						

					end

					return
				else
					Send("Life Given", ('%s (%d) was **restored** by %s'):format(Name, target, Speaker.Name),"cyan")

					clientNotify:FireClient(Speaker,"Successfully cross server restored ".. Name)
					updateActions(Speaker.UserId,"restore")
				end
			end)
		end
	else
		local Lives = 1
		if PlayerData[Player.Name].Race.Value == "Cameo" then Lives = 4 end
		if PlayerData[Player.Name].Lives.Value < Lives then
			PlayerData[Player.Name].Lives.Value += 1
			Send("Life Given", ('%s (%d) was **restored** by %s'):format(Player.Name, Player.UserId, Speaker.Name), "cyan")

			clientNotify:FireClient(Speaker,"Successfully restored ".. Player.Name)
			updateActions(Speaker.UserId,"restore")
		end
	end
end

local Commands = {
	['ban'] = { 
		Permission = 1,
		Function = function(Speaker, Message, Name)
			if not Name then return end

			local Player = GetPlayer(Name)

			if GetPlayer(Name) == false then
				local target = game.Players:GetUserIdFromNameAsync(Name)
				if target then
					local start = tick()
					local Key = game.JobId.."BanPlayer"..target
					game.ServerScriptService.CrossServerMessaging.PublishRequest:Fire(Key,
						{LifeTime = {Start = start, Time = 6},
						Origin = game.JobId,
						Request = "BanPlayer",
						MetaData = {Victim = target, SpeakerAdminLevel = _G.GetAdminLevel(Speaker.UserId)},
						ReturnData = {},
						AbortRequest = false}
					)
					local Success, ID = pcall(Players.GetUserIdFromNameAsync, Players, Name)
					if Success and ID then
						Send("Ban", ('Game banned %s (%d) due to mod action by %s'):format(Name, target, Speaker.Name), "cyan")
						clientNotify:FireClient(Speaker,"Successfully banned ".. Name)
						game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(Name, true)
						updateActions(Speaker.UserId,"ban")
					end
					--[[task.spawn(function()
						local success = false
						while tick() - start < 6 do
							local d = map:GetAsync(Key)
							if d and d.AbortRequest == true then
								success = true
								map:RemoveAsync(Key)
								break
							end
							task.wait(1)
						end
						if success == false then
							local Success, ID = pcall(Players.GetUserIdFromNameAsync, Players, Name)
							return
						else
							Send("Ban", ('Game banned %s (%d) due to mod action by %s'):format(Name, target, Speaker.Name), "cyan")
							clientNotify:FireClient(Speaker,"Successfully banned ".. Name)
							game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(Player.Name, true)
							updateActions(Speaker.UserId,"ban")
						end
					end)]]
				end
			else
				if Player == Speaker then return end
				Player:Kick("You have been banned from this game.")
				Send("Ban", ('Game banned'.. Name .. ":"..Player.UserId.. ' due to mod action by '.. Speaker.Name),  "cyan")
				clientNotify:FireClient(Speaker,"Successfully banned ".. Name)
				updateActions(Speaker.UserId,"ban")
				game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(Player.Name, true)
			end
		end,
	},
	['kick'] = {
		Permission = 1,
		Function = function(Speaker, Message, Name)
			if not Name then return end

			local Player = GetPlayer(Name)

			if Player == Speaker or (_G.GetAdminLevel(Player.UserId) and _G.GetAdminLevel(Player.UserId) >= _G.GetAdminLevel(Speaker.UserId)) then return end
			for i,v in pairs(Player.Character:GetChildren()) do
				if v:IsA("Folder") or v:IsA("Accessory") then
					v:Destroy()
				end
			end
			Send("Kick", ('%s (%d) was **kicked** by %s'):format(Player.Name, Player.UserId, Speaker.Name), Color3.new(1, 0.513725, 0.513725))
			clientNotify:FireClient(Speaker,"Successfully kicked ".. Player.Name, 2)
			Player:Kick'You have been kicked from this server'
			updateActions(Speaker.UserId,"kick")
		end,
	},
	['unban'] = {
		Permission = 1,
		Function = function(Speaker, Message, Name)
			if not Name then return end
			local Success, ID = pcall(Players.GetUserIdFromNameAsync, Players, Name)

			if Success and ID then
				game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(Name, false)
				Send("Unban", ('%s (%d) was **unbanned** by %s'):format(Name, ID, Speaker.Name), Color3.new(1, 0.203922, 0.937255))
				clientNotify:FireClient(Speaker,"Successfully unbanned ".. Name)
				updateActions(Speaker.UserId,"unban")
			end
		end,
	},
	['unhouseban'] = {
		Permission = 3,
		Function = function(Speaker, Message, Name)
			if not Name then return end
			local Success, ID = pcall(Players.GetUserIdFromNameAsync, Players, Name)

			if Success and ID then
				
			end
		end,
	},
	['givelife'] = {
		Permission = 1,
		Function = restore
	},
	['restore'] = {
		Permission = 1,
		Function = restore
	},
	['join'] = {
		Permission = 1,
		IgnoreErrors = true,
		Function = function(Speaker, Message, Name)
			if not Name then return 'No name' end
			local UserID = Players:GetUserIdFromNameAsync(Name) if not UserID then return 'Failed to get User ID' end
			return pcall(function()
				local InCurrentGame, _, PlaceID, JobID = TeleportService:GetPlayerPlaceInstanceAsync(UserID) print(InCurrentGame, PlaceID, JobID)

				if not InCurrentGame and PlaceID and JobID then
					TeleportService:TeleportToPlaceInstance(PlaceID, JobID, Speaker)
				end
			end)
		end,
	},
	['artifact'] = {
		Permission = 3,
		IgnoreErrors = true,
		Function = function(Speaker, Message, Name)
			if PlayerData[Speaker.Name].ArtifactAmount.Value >= _G.GetAdminLevel(Speaker.UserId) - 1 then return end
			if not Name then return 'No name' end
			for i,v in pairs(game.ServerStorage.Storage:GetChildren()) do
				if string.find(string.lower(v.Name), string.lower(Name)) then
					game.ServerStorage.Storage[v.Name]:Clone().Parent = Speaker.Backpack
					PlayerData[Speaker.Name].ArtifactAmount.Value += 1
					break
				end
			end
		end
	},
	['gotonpc'] = {
		Permission = 1,
		IgnoreErrors = true,
		Function = function(Speaker, Message, Name)
			if not Name then return 'No name' end
			local Character = workspace.NPCs:FindFirstChild(Name)
			if Character and Character:FindFirstChild("HumanoidRootPart") and Speaker.Character and Speaker.Character:FindFirstChild("HumanoidRootPart") then
				local a = Instance.new("Folder", Speaker.Character)
				a.Name = "TPSafe"
				Speaker.Character:FindFirstChild("HumanoidRootPart").CFrame = Character:FindFirstChild("HumanoidRootPart").CFrame
				task.delay(2, function()
					a:Destroy()
				end)
				clientNotify:FireClient(Speaker,"Went to ".. Character.Name)
			end
		end,
	},
	['respawn'] = {
		Permission = 1,
		IgnoreErrors = true,
		Function = function(Speaker, Message, Name)
			if not Name then return 'No name' end
			local Player = GetPlayer(Name) if not Player or not Player.Character then return 'No Player' end
			if Player.Character then
				Player:LoadCharacter()
				local v12 = Instance.new("NumberValue");
				v12.Name = "Transparency";
				v12.Value = 0;
				v12.Parent = Player.Character.Boosts;
				clientNotify:FireClient(Speaker,"Loaded ".. Player.Name)
			end
		end
	},
	['hide'] = {--dev only
		Permission = 100,
		IgnoreErrors = true,
		Function = function(Speaker)
			game.Players[Speaker.Name].leaderstats.Hidden.Value = true
			if not  PlayerData[Speaker.Name].Skills.Value:find("hidden") then
				PlayerData[Speaker.Name].Skills.Value ..= ",hidden"

				clientNotify:FireClient(Speaker,"Hid ".. Speaker.Name)
			end
		end
	},
	['forcewipe'] = {--dev only
		Permission = 100,
		IgnoreErrors = true,
		Function = function(Speaker, Message, Name)
			if not Name then return 'No name' end
			local Player = GetPlayer(Name) if not Player or not Player.Character then return 'No Player' end
			game.ServerStorage.Requests.Wipe:Fire(Player, game.ServerStorage.PlayerData:FindFirstChild(Player.Name), true, false)
			game.ServerStorage.Requests.Respawn:Fire(Player)
			
			clientNotify:FireClient(Speaker,"Forcewiped ".. Speaker.Name)
		end
	},
	['unhide'] = {--dev only
		Permission = 100,
		IgnoreErrors = true,
		Function = function(Speaker)
			game.Players[Speaker.Name].leaderstats.Hidden.Value = false
			if PlayerData[Speaker.Name].Skills.Value:find("hidden") then
				PlayerData[Speaker.Name].Skills.Value = string.gsub( PlayerData[Speaker.Name].Skills.Value, ",hidden", "")
				clientNotify:FireClient(Speaker,"Unhid ".. Speaker.Name)
			end
		end
	},
	['announce'] = { --dev only
		Permission = 100,
		Function = function(Speaker, Message, Text)
			if not Text then return end
			Send("Announce", ('%s (%d) Announced a message: `%s`'):format(Speaker.Name, Speaker.UserId, Text), Color3.new(1, 1, 1))
			game:GetService('MessagingService'):PublishAsync('adminmessage', Text)
			clientNotify:FireClient(Speaker,"Announced ".. Text)
		end,
	},
	['makereserved'] = { --dev only
		Permission = 100,
		Function = function(Speaker)
			local AccessCode = TeleportService:ReserveServer(game.PlaceId)
			clientNotify:FireClient(Speaker,"going to ".. AccessCode)
			TeleportService:TeleportToPrivateServer(
				game.PlaceId,
				AccessCode,
				{Speaker},
				nil,
				{["Code"] = AccessCode}
			)
		end
	},
	['serverbring'] = { --dev only
		Permission = 100,
		Function = function(Speaker, Message, Name)
			if not Name then return 'No name' end
			local Player = GetPlayer(Name) 

			if not Player then 
				local target = game.Players:GetUserIdFromNameAsync(Name)
				local Key = game.HttpService:GenerateGUID().."BringPlayer"..target
				local MetaData
				if game.ServerStorage:FindFirstChild("ReservedServer") then
					MetaData = {Victim = target, PlaceId = game.PlaceId, JobId = game.JobId, ReserveId = game.ServerStorage.ReservedServer.Value}
				else
					MetaData = {Victim = target, PlaceId = game.PlaceId, JobId = game.JobId}
				end
				game.ServerScriptService.CrossServerMessaging.PublishRequest:Fire(Key,
					{LifeTime = {Start = tick(), Time = 15},
					Origin = game.JobId,
					Request = "BringPlayer",
					MetaData = MetaData,
					ReturnData = {},
					AbortRequest = false}
				)
				clientNotify:FireClient(Speaker,"trying to bring ".. Name)
			else
				clientNotify:FireClient(Speaker,"they're already ingame ".. Player.Name)
			end
		end,
	},
	['giveitem'] = {
		Permission = 100,
		Function = function(Speaker, Message, Name)
			if not Name then return 'No name' end 

			CommandsModule.AddToInventory(game.Players[Speaker.Name],Name)
		end,
	},
	['bring'] = { --dev only
		Permission = 100,
		IgnoreErrors = true,
		Function = function(Speaker, Message, Name)
			if not Name then return 'No name' end
			if not Speaker.Character then return end
			local char = nil
			for _,v in next, workspace.Live:GetChildren() do
				if string.match(string.lower(v.Name),string.lower(Name)) and v:FindFirstChild('HumanoidRootPart') then
					char = v
					break
				end
			end
			if char then
				local a = Instance.new("Folder", char)
				a.Name = "TPSafe"
				game.Debris:AddItem(a,2)
				char.HumanoidRootPart.CFrame = Speaker.Character.HumanoidRootPart.CFrame

				clientNotify:FireClient(Speaker,"Brought ".. char.Name)
			end
		end,
	},
	['goto'] = { --dev only
		Permission = 100,
		IgnoreErrors = true,
		Function = function(Speaker, Message, Name)
			if not Name then return 'No name' end
			local Player = GetPlayer(Name) if not Player or not Player.Character then return 'No Player' end
			if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Speaker.Character and Speaker.Character:FindFirstChild("HumanoidRootPart") then
				local a = Instance.new("Folder", Speaker.Character)
				a.Name = "TPSafe"
				task.delay(2, function()
					a:Destroy()
				end)
				Speaker.Character:FindFirstChild("HumanoidRootPart").CFrame = Player.Character:FindFirstChild("HumanoidRootPart").CFrame
				clientNotify:FireClient(Speaker,"Went to ".. Player.Name)
			end
		end,
	},
	['globalhandlerserver'] = { --dev only
		Permission = 100,
		Function = function(Speaker, Message, Name)
			if ServerHandlesGlobals.Value == true then
				clientNotify:FireClient(Speaker,"ur literally in the server") 
				return
			end
			local start = tick()
			local Key = game.JobId.."GotoGlobalHandler"..Speaker.Name
			game.ServerScriptService.CrossServerMessaging.PublishRequest:Fire(Key,
				{LifeTime = {Start = start, Time = 6},
				Origin = game.JobId,
				Request = "GotoGlobalHandler",
				MetaData = {},
				ReturnData = {},
				AbortRequest = false}
			)

			task.spawn(function()
				local success = false
				local returnData = nil
				while tick() - start < 6 do
					local d = map:GetAsync(Key)
					if d and d.AbortRequest == true then
						returnData = d.ReturnData
						success = true
						map:RemoveAsync(Key)
						break
					end
					task.wait(1)
				end
				if success == false then
					clientNotify:FireClient(Speaker,"WHATS GOING ON OMG THE SERVER DOESNT EXIST")
				else
					local srv
					for server,succ in returnData do
						if succ == true then
							srv = server
						end
					end
					if not srv then clientNotify:FireClient(Speaker,"REQUEST ABORTED BUT SERVER DOESNT EXIST") return end
					if srv and srv == game.JobId then clientNotify:FireClient(Speaker,"ur literally in the server") return end
					clientNotify:FireClient(Speaker,"Teleporting to "..srv)
					while Speaker and Speaker.Parent do
						TeleportService:TeleportToPlaceInstance(game.PlaceId, srv, Speaker)
						task.wait(10)
					end
				end
			end)
		end,
	},
}

local function HandleMessage(Speaker, Message, Permission)
	if Message:sub(1, 3) == '/e ' then Message = Message:sub(4) else return end
	local CommandName, Arguments = Message:match('(%w+) (.+)')
	local Command = Commands[CommandName] 
	if not Command or Permission < Command.Permission then return end
	local Success, Response = pcall(Command.Function, Speaker, Message, Arguments)
	if not Success then
		clientNotify:FireClient(Speaker,"Error: "..Response)
	end
end
local function HandlePlayerChatted(Player)
	Player.Chatted:Connect(function(Message)
		local Level = _G.GetAdminLevel(Player.UserId)
		HandleMessage(Player, Message, Level)
	end)
end
Command.OnServerInvoke = function(Player, Message)
	if _G.GetAdminLevel(Player.UserId) then
		local Rank = _G.GetAdminLevel(Player.UserId)
		HandleMessage(Player, "/e "..Message, Rank)
	end
end
msgservice:SubscribeAsync('adminmessage', function(a)
	remote:FireAllClients(a.Data)
end)
local function padd(player)
	player:WaitForChild("leaderstats", math.huge)
	local Level
	Level = _G.GetAdminLevel(player.UserId)
	--if _G.GetAdminLevel(Player.UserId) > 0 then
	if game.ServerStorage.PlayerData:FindFirstChild(player.Name) then
		game.ServerStorage.PlayerData[player.Name].AdminLevel.Value = Level
	end
	if Level > 0.5 then
		local Clone = script.ModGUI:Clone()
		Clone.Parent = player:WaitForChild'PlayerGui'
		Clone.Enabled = true
		Clone:WaitForChild'ModClient'.Disabled = false
		Instance.new("Folder", player).Name = "gunga"
		HandlePlayerChatted(player)
		--else
		--	if BanStore:GetAsync('User_' .. player.UserId) == true then
		--		player:Kick'You have been banned from this game'
		--	end
	end
end
for _,v in pairs(game.Players:GetPlayers()) do
	padd(v)
end
game.Players.PlayerAdded:Connect(function(player)
	padd(player)
end)