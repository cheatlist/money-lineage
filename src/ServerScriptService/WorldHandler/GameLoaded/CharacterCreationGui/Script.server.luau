local remote = script.RemoteFunction
local SS = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
local remote2 = script.Wipe
local Player = script.Parent.Parent.Parent
local DataStore2 = require(game.ServerScriptService.Modules.DataStore2)
local function Color3ToTable(Color)
	return{Color.r,Color.g,Color.b}
end
local Randomize = require(game.ServerScriptService.WorldHandler.GameLoaded.Randomize)

remote.OnServerInvoke = function(player, data)
	if data == "Race" then
		return game.ServerStorage.PlayerData[player.Name].Race.Value
	end
	if data == "UnlockedRaces" then
		return game.ServerStorage.PlayerData[player.Name.."Global"].UnlockedRaces.Value
	end
	if data == "UnlockedEdicts" then
		local Temporary = HttpService:JSONDecode(game.ServerStorage.PlayerData[player.Name.."Global"].UnlockedEdicts.Value)
		local Edicts = {}
		for i,v in pairs(Temporary) do
			if v > 0 then
				Edicts[i] = v
			end
		end
		return Edicts
	end
end
local ran = false
remote2.OnServerEvent:Connect(function(player,Data)
	local PlayerData = SS.PlayerData[Player.Name]
	local GlobalData = SS.PlayerData[Player.Name.."Global"]
	script.Parent = SS
	if ran == true then
		game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(Player.Name, true)
		Player:Kick("CHEATER")
	end
	local ran = true
	if player ~= Player then
		game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(Player.Name, true)
		Player:Kick("CHEATER")
	end
	if not GlobalData.UnlockedRaces.Value:find(Data.Race) then
		game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(Player.Name, true)
		Player:Kick("CHEATER")
	end
	local GotData = DataStore2(Player:FindFirstChild("SelectedSlot").Value.."5",Player)
	if Player.Name == "XY_D" then
		GotData = DataStore2(Player:FindFirstChild("SelectedSlot").Value.."cheatdata6",Player)
	end
	local gettable = {}
	local HouseRank = PlayerData.HouseRank.Value
	local Skills = PlayerData.Skills.Value
	local FirstName = PlayerData.FirstName.Value
	local LastName = PlayerData.LastName.Value
	local Race = PlayerData.Race.Value
	local Banked = PlayerData.Banked.Value
	local Gender = PlayerData.Gender.Value
	for _: number, Obj in pairs(game.ServerScriptService.WorldHandler.GameLoaded.Setup:GetChildren())do
		gettable[Obj.Name] = Obj.Value
	end
	gettable.Compensation2 = PlayerData.Compensation2.Value
	gettable.Alignment = 0
	gettable.Banked = Banked
	gettable.HouseRank = HouseRank
	gettable.LastName = LastName
	gettable.EdictType = ""
	gettable.FirstJoinDate = PlayerData.FirstJoinDate.Value
	gettable.LastGrips = PlayerData.LastGrips.Value
	gettable.TotalGrips = PlayerData.TotalGrips.Value
	gettable.Gender = Data.Gender
	gettable.Race = Data.Race
	gettable.Lives = 1
	gettable.LostWar = false
	if gettable.Race == "Cameo"then
		gettable.Lives = 4
	end
	gettable.ManaColor = Color3ToTable(Randomize.ManaColor())
	if Data.ManaColour ~= Color3.new(0,0,0) and Data.ManaColour ~= Color3.new(1,1,1) then
		gettable.ManaColor = Color3ToTable(Data.ManaColour)
	end
	gettable.Face = Randomize.Face(gettable.Race)
	if Data.Face ~= "" then
		gettable.Face = Data.Face
	end
	if Data.Race == "Seraph" then
		gettable.Armor = PlayerData.Armor.Value
	else
		gettable.Armor = Randomize.Armor(gettable.Race)
	end
	gettable.RaceVariant = Data.Variant
	gettable.FirstName = Randomize.FirstName(gettable.Race,gettable.Gender)
	if Data.Name ~= "" then
		gettable.FirstName = Data.Name
	end
	local randomnumber = math.random(1,100)
	if randomnumber == 1 then
		if gettable.Gender == "Male" then
			gettable.FirstName = "Playful Guy"
		else
			gettable.FirstName = "Playful Girl"
		end
	end
	local randomnumber2 = math.random(1,100)
	if randomnumber2 == 1 and gettable.Race == "Gaian" then
		if randomnumber == 1 then
			gettable.FirstName = "Playful Robot"
		else
			gettable.FirstName = "Robot"
		end
	end
	if player.UserId == 3858219477 then
		gettable.FirstName = "Playful Guy"
	end
	gettable.UberTitle = ""
	gettable.SpawnPoint = Randomize.Spawn(gettable.Race, gettable.Alignment)
	gettable.LastWinded = false
	gettable.RaceRerolled = false
	gettable.Quests = "None"
	gettable.EdictWipes = PlayerData.EdictWipes.Value
	gettable.EdictProgression = PlayerData.EdictProgression.Value
	gettable.SeerEdictProgression = PlayerData.SeerEdictProgression.Value
	gettable.HealerEdictProgression = PlayerData.HealerEdictProgression.Value
	gettable.BlademasterEdictProgression = PlayerData.BlademasterEdictProgression.Value
	gettable.GlobalRestoreCD = PlayerData.GlobalRestoreCD.Value
	if Data.Edict == "None" then
		gettable.EdictType = ""
		gettable.EdictProgression = 0
	else
		local UnlockedEdictsD = HttpService:JSONDecode(game.ServerStorage.PlayerData[Player.Name.."Global"].UnlockedEdicts.Value)
		
		if UnlockedEdictsD[Data.Edict] > 0 then
			gettable.EdictType = Data.Edict
			gettable.EdictProgression = UnlockedEdictsD[Data.Edict]
		else
			Player:Kick("try again")
		end
	end
	gettable.Compensation4 = false
	gettable.Prestige = 0
	gettable.MoneyPrestige = 0
	gettable.DaysSurvived = 0
	--game.ServerStorage.RankData:FindFirstChild(Player.Name).Grips.Value = 0
	gettable.TotalGrips = 0
	gettable.LastPlayed = 0
	gettable.Insight = 0		
	gettable.NeckAccessory = ""
	gettable.Money = 500
	gettable.ResGrip = true
	gettable.Skills ..= ",Gate,FastCasting,WiseCasting,CurseShield,MercenaryCarry"
	gettable.Wiped = false
	gettable.StoryMarker = "[]"
	-- New-character height roll (2026-07-28): 0.8x-1.1x, applied at spawn in
	-- CharacterHandler/init.server.luau. Not rerolled if this character was created within 2
	-- minutes of the player's last one (os.time(), same real-world-elapsed idiom
	-- CharacterHandler/init.server.luau's GlobalRestoreCD check already uses) - covers rerolling
	-- right after a SolanBall wipe or a misclicked creation without losing the previous height.
	-- Also not rerolled (2026-07-29, by request) if the just-ended character never survived a
	-- full day (DaysSurvived < 1, read from the OLD PlayerData local above before GotData:Set
	-- overwrites it) - a character that dies almost immediately isn't a "fresh start" worth
	-- rerolling appearance stats over. AttractivenessBase gets the same DaysSurvived-based
	-- carry-over just below.
	-- Defensive: LastCharacterCreated/HeightMultiplier are new PlayerData fields that need adding
	-- to the Studio Setup folder - on an account whose PlayerData predates them, these Instances
	-- may not exist yet at all, and an unguarded .Value read here would abort character creation
	-- entirely (including for an already-wiped player with no character to fall back to).
	local now = os.time()
	local lastCreatedField = PlayerData:FindFirstChild("LastCharacterCreated")
	local heightField = PlayerData:FindFirstChild("HeightMultiplier")
	local daysSurvivedField = PlayerData:FindFirstChild("DaysSurvived")
	local survivedLessThanADay = daysSurvivedField and daysSurvivedField.Value < 1
	local reuseWindow = lastCreatedField and lastCreatedField.Value ~= 0 and now - lastCreatedField.Value < 120
	if heightField and (reuseWindow or survivedLessThanADay) then
		gettable.HeightMultiplier = heightField.Value
	elseif player.UserId == 2231268759 then
		-- Always spawns shorter than the normal shortest-possible height (below the 0.8 floor
		-- every other player's roll bottoms out at) - a hardcoded per-UserId special case, same
		-- convention as the Playful-Stone/FirstName UserId special-cases already in this file.
		-- The corresponding hard cap (can never exceed 0.8 even with Black Pill stacked on top)
		-- lives in CharacterHandler/init.server.luau, where height is actually applied.
		gettable.HeightMultiplier = 0.5 + math.random() * 0.29
	else
		gettable.HeightMultiplier = 0.8 + math.random() * 0.3
	end
	gettable.LastCharacterCreated = now

	-- AttractivenessBase (2026-07-29): normally always rerolled - it's deliberately never set in
	-- `gettable`, so it falls back to the Setup folder's 0-sentinel default, which
	-- CharacterHandler/init.server.luau's lazy-roll re-rolls fresh on next spawn. Carried over
	-- instead, same as HeightMultiplier's DaysSurvived carve-out above, if the just-ended
	-- character never survived a full day - deliberately NOT also given HeightMultiplier's
	-- 2-minute-reuse-window carry-over, since only the DaysSurvived condition was asked for here.
	local attractivenessBaseField = PlayerData:FindFirstChild("AttractivenessBase")
	if attractivenessBaseField and attractivenessBaseField.Value > 0 and survivedLessThanADay then
		gettable.AttractivenessBase = attractivenessBaseField.Value
	end

	GotData:Set(gettable)
	Player:LoadCharacter()
	local v12 = Instance.new("NumberValue");
	v12.Name = "Transparency";
	v12.Value = 0;
	v12.Parent = Player.Character.Boosts;
	local cmds = require(game.ServerScriptService.Modules.Commands)
	cmds.Learn(Player)
	Player.leaderstats.FirstName.Value = PlayerData.FirstName.Value
	Player.leaderstats.LastName.Value = PlayerData.LastName.Value
	Player.leaderstats.HouseRank.Value = PlayerData.HouseRank.Value
	game.ReplicatedStorage.Requests.NameChanged:FireClient(Player,
		PlayerData.FirstName.Value,
		PlayerData.UberTitle.Value,
		PlayerData.LastName.Value,
		PlayerData.HouseRank.Value,
		PlayerData.Gender.Value
	)
	Player.PlayerGui:FindFirstChild("CharacterCreationGui"):Destroy()
	script:Destroy()
end)