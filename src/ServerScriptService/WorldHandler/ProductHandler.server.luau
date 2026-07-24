local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerData = ServerStorage:WaitForChild("PlayerData")
local Requests = ServerStorage:WaitForChild("Requests")
local Commands = require(ServerScriptService.Modules:WaitForChild("Commands"))
local Randomize = require(script.Parent.GameLoaded.Randomize)
local purchaseHistoryStore = DataStoreService:GetDataStore("Gaia_PurchaseHistory")
local productFunctions = {}

productFunctions[1349079187] = function(Receipt,Player)
	if Player.Character and PlayerData[Player.Name] and Requests:FindFirstChild("Respawn") then
		PlayerData[Player.Name].Lives.Value += 1
		PlayerData[Player.Name].LastWinded.Value = true
		task.wait(1)
		local Spawns = game.ServerStorage.SpawnPoints[PlayerData[Player.Name].SpawnPoint.Value]:GetChildren()
		local RandomSpawn = Spawns[math.random(1,#Spawns)].CFrame
		PlayerData[Player.Name].LastPosition.Value = RandomSpawn.X..","..RandomSpawn.Y..","..RandomSpawn.Z
		Requests.Respawn:Fire(Player)
		local embedOverrides = {
			footer = {
				icon_url = "https://media.discordapp.net/attachments/508290690619277313/977884569728593960/thrown-sapari-cat-1.gif",
				text =  "Server: ".. game.JobId.. " | Version: | "..game.PlaceVersion.." ",
			}
		}
		Requests.SendWebhook:Fire("Ressurection","Player: "..Player.Name,"blue","Purchases",embedOverrides)
		return true
	end
end

local embedOverrides = {
	footer = {
		icon_url = "https://media.discordapp.net/attachments/508290690619277313/977884569728593960/thrown-sapari-cat-1.gif",
		text =  "Server: ".. game.JobId.. " | Version: | "..game.PlaceVersion.." ",
	}
}

productFunctions[1349079279] = function(Receipt,Player)
	local Rolling = true
	local oldrace = PlayerData[Player.Name].Race.Value
	local RolledRace = nil
	while Rolling do
		RolledRace = Randomize.Race()
		if RolledRace ~= PlayerData[Player.Name].Race.Value then
			PlayerData[Player.Name].Race.Value = RolledRace
			Rolling = false
		else
			RolledRace = Randomize.Race()
		end
	end
	--Requests.Wipe:Fire(Player,PlayerData[Player.Name],true)
	Requests.SendWebhook:Fire("Wipe Lineage",Player.Name.." ("..Player.UserId..") abandoned their lineage.".."\n New Race: "..RolledRace.."\n Old Race: "..oldrace.."\n Unlocked Races:" ..PlayerData[Player.Name.."Global"].UnlockedRaces.Value,"cyan","Purchases",embedOverrides)
	local rerolled = Instance.new("BoolValue")
	rerolled.Name = "Rerolled"
	rerolled.Parent = Player.Backpack
	game.Debris:AddItem(rerolled,0.5)
	return true
end

productFunctions[1287298074] = function(Receipt,Player)
	if Player.Character and PlayerData[Player.Name] then
		local oldArtifact = PlayerData[Player.Name].Artifact.Value
		if oldArtifact == "Spidercloak" then
			Commands.ChangeArmor(Player, "Rags")
		elseif oldArtifact == "Fairfrozen" then
			Commands.ChangeWeapon(Player, "None")
		end
		PlayerData[Player.Name].Artifact.Value = "None"
		Requests.SendWebhook:Fire("Artifact Reset",Player.Name.." ("..Player.UserId..") reset their artifact.".."\n Old Artifact: "..oldArtifact,"aqua","Purchases",embedOverrides)
		return true
	end
end

local function processReceipt(receiptInfo)
	local playerProductKey = receiptInfo.PlayerId .."_"..receiptInfo.PurchaseId
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	local purchased = false
	local success, errorMessage = pcall(function()
		purchased = purchaseHistoryStore:GetAsync(playerProductKey)
	end)
	if success and purchased then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif not success then
		--Requests.SendWebhook:Fire("Product datastore error","Player: "..player.Name.." Error:"..errorMessage.." ProductId: "..receiptInfo.ProductId,"blue","Purchases",embedOverrides)
	end
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local handler = productFunctions[receiptInfo.ProductId]
	local success, result = pcall(handler,receiptInfo,player)
	if not success or not result then
		--Requests.SendWebhook:Fire("Error occurred while processing a product purchase","Player: "..player.Name.." Error: "..result.." ProductId: "..receiptInfo.ProductId,"blue","Purchases",embedOverrides)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local success, errorMessage = pcall(function()
		purchaseHistoryStore:SetAsync(playerProductKey,true)
	end)
	if not success then
		--Requests.SendWebhook:Fire("Could not save purchase data","Player: "..player.Name.." Error: "..errorMessage,"blue")
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.ProcessReceipt = processReceipt