local market: MarketplaceService = game:GetService("MarketplaceService")
local gameid: number = 11513319796
local ts: TeleportService = game:GetService("TeleportService")
local datastore: DataStoreService = game:GetService("DataStoreService")
local servers: GlobalDataStore = datastore:GetDataStore(gameid.."Servers")
local Rng: Random = Random.new()

local alphabet: {[number]: string} = {
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v"
}
local numbers: {[number]: number} = {
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	0
}
local Length_Of_PS_Code: number = 8
local function generatetext(): string
	local Text: string = ''
	for Indx: number = 1, Length_Of_PS_Code do
		if Rng:NextInteger(1,2) == 1 then
			Text ..= alphabet[Rng:NextInteger(1, #alphabet)]
		else
			Text ..= numbers[Rng:NextInteger(1, #numbers)]
		end
	end
	return Text
end

local function generatecode(): string
	local code: string = ts:ReserveServer(gameid)
	local codetojoin: string = generatetext()
	if servers:GetAsync(codetojoin)then
		while servers:GetAsync(codetojoin)do
			task.wait(1/30)
			codetojoin = generatetext()
		end
	end
	local reservedcode: string = code

	local ps = {
		codetojoin,
		reservedcode
	}
	servers:SetAsync(codetojoin,reservedcode)
	return codetojoin
end

local PD: Folder = game:GetService'ServerStorage'.PlayerData
local SelfCDs: {[number]: boolean} = {}
game.ReplicatedStorage.Requests.CreatePrivateServer.OnServerEvent:Connect(function(plr: Player, action: string, key: string): ()
	if not action or typeof(action) ~= 'string'then
		plr:Kick('Stop cheating loser!')
		return
	end
	local StatF = PD:FindFirstChild(plr.Name)
	if not StatF or StatF.Lives.Value <= 0 then return end
	if SelfCDs[plr.UserId]then
		return
	end
	if action == "Create" then
		SelfCDs[plr.UserId] = true
		for Indx: number = 1, 6 do
			local Success2: boolean, Return2: boolean = pcall(market.UserOwnsGamePassAsync, market, plr.UserId, 104115129)
			if Success2 then
				if Return2 then
					local codegenerated: string = generatecode()
					local Value: StringValue =  Instance.new("StringValue") 
					Value.Name = "PrivateServerCreated"
					Value.Value = codegenerated	
					Value.Parent = plr
				end
				break
			end
			task.wait(.25 * Indx)
		end
		task.delay(3.5, function(): ()
			SelfCDs[plr.UserId] = nil
		end)
	elseif action == "Join" then
		if not key or typeof(key) ~= 'string'then
			plr:Kick('Stop cheating loser!')
			return
		end
		local message: string = string.lower(key)
		local Code: string = servers:GetAsync(message)
		if Code then
			SelfCDs[plr.UserId] = true
			while true do
				local Success: boolean = pcall(ts.TeleportToPrivateServer, ts, gameid, Code, {plr})
				if Success then
					break
				end
				task.wait(1)
			end
			task.delay(3.5, function(): ()
				SelfCDs[plr.UserId] = nil
			end)
		end
	end
end)