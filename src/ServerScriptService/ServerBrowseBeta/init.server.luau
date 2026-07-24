--norperz #4/30/2022
--norp#7889
--game.ServerScriptService.ServerBrowseBeta.Disabled = true
wait(5)
local makeServer = true
if game.PrivateServerId ~= "" or game.ServerStorage:FindFirstChild("ReservedServer") then
	makeServer = false
	game.ReplicatedStorage.ServerName.Value = "Private Server"
end 
local ourserver = nil
if _G.ourid == nil then
	_G.ourid = game:GetService("HttpService"):GenerateGUID()
end
if game.ReplicatedStorage.ServerName.Value ~= "NOSERVERID" then
	ourserver = game.ReplicatedStorage.ServerName.Value
end
--local ouruid = game:GetService("HttpService"):GenerateGUID()
local staticwait = 8

local adjectives = {"Anxious","Brave","Awful","Dirty","Tired","Ugly","Weak","Strong","Shy","Calm","Happy","Sad","Mad","Sweet","Slow","Fast","Stinky","Busy","Young","Old","Small","Big","Norping","Hired","Dead","Disgusting","Corpse of","King"}
local random = {"Haseldan","Rigan","Ashiin","Castellan","Kasparan","Gaian","Scroom","Navaran","Madrasian","Dinakeri","Morvid","Fischeran","Vind","Dzin","Metascroom","Azael","Construct","Cameo","Lich","Dullahan","Florian","Seraph","Base","Super","Ultra","Uber","Alchemist","Chef","Bard","Monk","Dragon Sage","Akuma","Oni","Scholar","Illusionist","Botanist","Druid","Necromancer","Thief","Spy","Whisperer","Cadence","Assassin","Faceless","Shinobi","Pit Fighter","Dragon Knight","Dragon Slayer","Spearfisher","Church Knight","Deep Knight","Warrior","Sigil Knight","Sigil Knight Commander","Solans","Wraith Knight","Blacksmith","Lapidarist","Samurai","Ronin","Warlord","Abyss Walker","ignis","Gelidus","Tenebris","Trahere","Contrarium","Manus Dei","Fimbulvetr","Custos","Claritum","Hystericus","Globus","Intermissium","Dominus","Fons Vitae","Veriden","Perflora","Floresco","Inferi","Reditus","Ligans","Secare","Furantur","Beta","Hoppa","Snarvindur","Percutiens","Nosferatus","Gourdus","Mori","Pondus","Nocere","Celeritas","Trickstus","Sagitta Sol","Scruptus","Viribus","Velo","Telorum","Armis","Gate","Phoenix Down","Ice Essence","Lannis's Amulet","Spider Cloak","Philosopher's Stone","Howler Friend","Fairfrozen","Scroom Key","Night Stone","Rift Gem","Azael Horns","Opal","Sapphire","Emerald","Ruby","Diamond","Sword","Dagger","Spear","Caestus","Tome","Tomeless","Rapier","Tanto","Katana","Hammer","Greatsword","Trident","Shrieker","Zombie Scroom","Evil Eye","Lava Snake","Howler","Alpha","Ice Dragon","Money","Jester","Healer","Seer","Blademaster","Freshie","Norp","Robson","Minos"}

local ms = game:GetService("MemoryStoreService")
map = ms:GetSortedMap("ServerBrowse")

function toH(s)
	return ("%02i Hours"):format(s/3600)
end

function PrintAllKeys(map)
	local exclusiveLowerBound = nil
	local keys = {}
	local iterations = 0
	while true do
		local items = map:GetRangeAsync(Enum.SortDirection.Ascending, 100, exclusiveLowerBound)
		for i, entry in ipairs(items) do
			table.insert(keys,entry)
		end
		if #items < 100 then
			break
		end
		exclusiveLowerBound = items[#items].key
		task.wait(2)
		iterations += 1
		if iterations >= 200 then break end
	end
	return keys
end

local function giveunusedname()
	local used = {}
	local iterations = 0
	for _,v in pairs(game.ReplicatedStorage.Servers:GetChildren()) do
		used[v.ServerName.Value] = true
	end
	local possalpha = table.clone(adjectives)
	local possbeta = table.clone(random)
	local currsel = nil
	while true do
		local na = math.random(1,#possalpha)
		local nb = math.random(1,#possbeta)
		local alph = possalpha[na]
		local bet = possbeta[nb]
		if used[alph.. " "..bet] then
			local n = math.random(1,2)
			if n == 1 then
				table.remove(possalpha, na)
			else
				table.remove(possbeta, na)
			end
		else
			currsel = alph.. " "..bet
			break
		end
		local r = math.random(1,5)
		if r == 3 then task.wait() end
		iterations += 1
		if iterations >= 200 then break end
	end
	return currsel or "Server Brewing"
end

local TS: TeleportService = game:GetService'TeleportService'
game.ReplicatedStorage.toServer.OnServerEvent:Connect(function(Player, server)
	if Player:FindFirstChild("Danger") or Player:FindFirstChild("MortalDanger") then
		game.ReplicatedStorage.toServer:FireClient(Player,"In combat")
		return
	end
	if Player:FindFirstChild("recenttp") then
		game.ReplicatedStorage.toServer:FireClient(Player,"Teleport cooldown")
		return
	end
	local deb: Accessory = Instance.new("Accessory")
	deb.Name = "recenttp"
	deb.Parent = Player
	game.Debris:AddItem(deb, 1)
	local ff:ForceField = Instance.new('ForceField')
	ff.Parent = Player.Character
	if not Player.Character then
		ff:Destroy()
	end
	--if Player:FindFirstChild("Ingame")then
	--	game.ReplicatedStorage.toServer:FireClient(Player, "You can only teleport from the menu")
	--	return
	--end
	local server = game.ReplicatedStorage.Servers:FindFirstChild(server)
	if server then
		local conn: RBXScriptConnection?
		conn = TS.TeleportInitFailed:Connect(function(player,result, err)
			--print(player,result,err)
			if Player == player then
				if ff then
					ff:Destroy()
				end
				game.ReplicatedStorage.toServer:FireClient(Player, err)
				if conn then
					conn:Disconnect()
					conn = nil
				end
			end
		end)
		TS:TeleportToPlaceInstance(game.PlaceId, server.JobId.Value, Player)
		task.spawn(function()
			task.wait(20)
			if conn then
				conn:Disconnect()
				conn = nil
			end
		end)
	end
end)

local gloaded = game.ServerScriptService.WorldHandler.GameLoaded

game.ReplicatedStorage.Requests.ReturnToMenu.OnServerEvent:Connect(function(Player): ()
	local Char: Model = Player.Character
	if not Char then
		return
	end
	if not Player:FindFirstChild("Danger") and Player:FindFirstChild("Ingame") then

		local Tag: ForceField = Instance.new'ForceField'
		Tag.Name = 'Immortal'
		Tag.Parent = Char
		game.Debris:AddItem(Tag, 15)
		--game["Teleport Service"]:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)

		for _,v in pairs(Player:GetChildren()) do
			if v.Name == "LichSummon" then
				v:Destroy()
			end
		end

		local f = Instance.new("Accessory")
		f.Name = "ReturnToMenu"
		f.Parent = Player

		task.wait()
		for _,v in pairs(Char:GetDescendants()) do
			if v:IsA("Script") or v:IsA("LocalScript") then
				v.Disabled = true
			end
		end
		Char:Destroy()
		Player.Character = nil
		if Player:FindFirstChild("Ingame") then
			Player.Ingame:Destroy()
		end

		local StartMenu = gloaded.StartMenu:Clone()
		if not Player.PlayerGui:FindFirstChild("ServerBrowse") then
			local sbrow = gloaded.ServerBrowse:Clone()
			sbrow.Parent = Player.PlayerGui
			sbrow.Handler.Disabled = false
		end
		local Finish = Instance.new("RemoteEvent")
		Finish.Name = "Finish"
		Finish.Parent = StartMenu
		StartMenu.Parent = Player.PlayerGui
		--sbrow.Parent = Player.PlayerGui
		--sbrow.Handler.Disabled = false
		local FinishConnection
		FinishConnection = Finish.OnServerEvent:Connect(function(p)
			if f and f.Parent then
				f:Destroy()
			end
			if p ~= Player then
				p:Kick()
				return
			end
			local f = Instance.new("Accessory")
			f.Name = "Ingame"
			f.Parent = p
			task.wait(1)
			p:LoadCharacter()
			local v12 = Instance.new("NumberValue");
			v12.Name = "Transparency";
			v12.Value = 0;
			v12.Parent = p.Character.Boosts;
			game.ReplicatedStorage.Requests.ReturnToMenu:FireClient(p)
			if StartMenu and StartMenu.Parent then
				StartMenu:Destroy()
			end
			--sbrow.Enabled = false
			--print(changed)
			FinishConnection:Disconnect()
		end)
	end
end)

function set()
	local housemajority = {}
	local ranks = 0
	for _,v in pairs(game.Players:GetChildren()) do
		if v:FindFirstChild("leaderstats") and v.leaderstats:FindFirstChild("LastName") then
			local hous = v.leaderstats.LastName.Value
			if hous ~= "" and hous ~= " " then
				if housemajority[hous] then
					housemajority[hous] += housemajority[hous]
				else
					housemajority[hous] = 1
				end
			end
		end
		if v:FindFirstChild("leaderstats") and v.leaderstats:FindFirstChild("Prestige") then
			if v.leaderstats.Prestige.Value ~= 0 then
				ranks += 1
			end
		end
	end
	local hous = {}
	for i,v in pairs(housemajority) do
		table.insert(hous, {Name = i, Amount = v})
	end
	table.sort(hous, function(a,b)
		return a.Amount > b.Amount
	end)
	local major
	local pc,err = pcall(function()
		if hous[1] and hous[1].Amount > 1 then
			major = hous[1].Name
		else
			major = "Nobody Reigns"
		end	
	end)
	if not pc then print(err) major = "Nobody Reigns" end
	if ourserver == nil then
		ourserver = giveunusedname()
		game.ReplicatedStorage.ServerName.Value = ourserver
	end
	map:SetAsync(_G.ourid, 
		{
			ServerName = ourserver,
			Players = #game.Players:GetChildren(),
			HouseMajority = major,
			Age = toH(workspace.DistributedGameTime),
			Ranks = ranks,
			JobId = game.JobId,
		}, 
		staticwait * 1.5)

	local f = game.ServerScriptService.ServerBrowseBeta.UID:clone()
	f.Name = _G.ourid
	f.Age.Value = toH(workspace.DistributedGameTime)
	f.HouseMajority.Value = major
	f.Players.Value = #game.Players:GetChildren()
	f.ServerName.Value = ourserver
	f.Ranks.Value = ranks
	f.JobId.Value = game.JobId
	f.Parent = game.ReplicatedStorage.Servers
end

if makeServer then
	set()
end
task.wait(staticwait)


function loop()
	task.spawn(function()
		local pc,err = pcall(function()
			while true do
				if ourserver:find("‎") then
					ourserver = giveunusedname()
				end
				local currentdat = PrintAllKeys(map)
				for _,v in pairs(game.ReplicatedStorage.Servers:GetChildren()) do
					if tick() - v.LastGrabbed.Value >= 90 then
						v:Destroy()
					end
				end
				local found = {}
				for _,v in pairs(currentdat) do
					local uid = v.key
					local age = v.value.Age
					local hm = v.value.HouseMajority
					local plrs = v.value.Players
					local sn = v.value.ServerName
					local rks = v.value.Ranks
					local jd = v.value.JobId
					local function populate(f)
						f.Name = uid
						f.Age.Value = age
						f.HouseMajority.Value = hm
						f.Players.Value = plrs
						f.ServerName.Value = sn
						f.Ranks.Value = rks
						f.JobId.Value = jd
						f.LastGrabbed.Value = tick()
						table.insert(found,uid)
					end
					local existing = game.ReplicatedStorage.Servers:FindFirstChild(uid)
					if existing then
						populate(existing)
					else
						local f = game.ServerScriptService.ServerBrowseBeta.UID:clone()
						populate(f)
						f.Parent = game.ReplicatedStorage.Servers
					end
				end
				
				for _,v in pairs(game.ReplicatedStorage.Servers:GetChildren()) do
					if not table.find(found,v.Name) then
						v:Destroy()
					end
				end
				
				if makeServer then
					local housemajority = {}
					local ranks = 0
					for _,v in pairs(game.Players:GetChildren()) do
						if v:FindFirstChild("leaderstats") and v.leaderstats:FindFirstChild("LastName") then
							local hous = v.leaderstats.LastName.Value
							if hous ~= "" and hous ~= " " then
								if housemajority[hous] then
									housemajority[hous] += housemajority[hous]
								else
									housemajority[hous] = 1
								end
							end
						end
						if v:FindFirstChild("leaderstats") and v.leaderstats:FindFirstChild("Prestige") then
							if v.leaderstats.Prestige.Value ~= 0 then
								ranks += 1
							end
						end
					end
					local hous = {}
					for i,v in pairs(housemajority) do
						table.insert(hous, {Name = i, Amount = v})
					end
					table.sort(hous, function(a,b)
						return a.Amount > b.Amount
					end)
					local major
					local pc,err = pcall(function()
						if hous[1] and hous[1].Amount > 1 then
							major = hous[1].Name
						else
							major = "Nobody Reigns"
						end	
					end)
					if not pc then print(err) major = "Nobody Reigns" end
					if ourserver == nil then
						ourserver = giveunusedname()
						game.ReplicatedStorage.ServerName.Value = ourserver
					end
					local currservdata = map:GetAsync(_G.ourid)
					if not currservdata or not currservdata.ServerName or not currservdata.Players or not
						currservdata.HouseMajority or not currservdata.Age or not currservdata.Ranks or not currservdata.JobId then
						map:SetAsync(_G.ourid, 
							{
								ServerName = ourserver or "Server Name Error",
								Players = #game.Players:GetChildren(),
								HouseMajority = major,
								Age = toH(workspace.DistributedGameTime),
								Ranks = ranks,
								JobId = game.JobId,
							}, 
							staticwait * 1.5)
					else
						map:UpdateAsync(_G.ourid, function(tab)
							tab.ServerName = ourserver or "Server Name Error"
							tab.Players = #game.Players:GetChildren()
							tab.HouseMajority = major
							tab.Age = toH(workspace.DistributedGameTime)
							tab.Ranks = ranks
							tab.JobId = game.JobId
							return tab
						end, staticwait * 1.5)
					end
				end
				task.wait(staticwait)
			end
		end)
		if not pc then staticwait += .25 
			--game.ServerStorage.Requests.SendWebhook:Fire(
			--	"Error Handler: Server Browser",
			--	ourserver.. " errored: " .. err .. " " .. debug.traceback(),
			--	"red"
			--)
			task.wait(5)
			ms = game:GetService("MemoryStoreService")
			map = ms:GetSortedMap("ServerBrowse")
			loop()
		end
	end)
end

loop()