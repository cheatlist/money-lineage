local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Modules = ServerScriptService:WaitForChild("Modules")
local Commands = require(Modules:WaitForChild("Commands"))
local ArtifactChoiceGui = ServerStorage:WaitForChild("ArtifactChoiceGui")

local Communicate
local AlreadyUsed = false
local Character,Player

function RemoveGui(ToRemoveFrom)
	local PlayerGui = ToRemoveFrom.PlayerGui:GetChildren()
	for Index = 1,#PlayerGui do
		if tostring(PlayerGui[Index]) == "ArtifactChoiceGui" then
			PlayerGui[Index]:Destroy()
		end
	end
end

script.Parent.Activated:Connect(function()
	if AlreadyUsed then
		return
	end
	Character = script.Parent.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	RemoveGui(Player)
	local GuiClone = ArtifactChoiceGui:Clone()
	GuiClone.Parent = Player.PlayerGui
	Communicate = Instance.new("RemoteEvent")
	Communicate.Name = "Communicate"
	Communicate.Parent = GuiClone
	Communicate.OnServerEvent:Connect(function(PlayerFired,Action,Item)
		if PlayerFired ~= Player then
			return
		end
		if AlreadyUsed then
			return
		end
		if Action == "MakeChoice" then
			if not ArtifactChoiceGui:FindFirstChild(Item, true) then
				game:GetService("DataStoreService"):GetDataStore("ArdaBans"):SetAsync(Player.Name, true)
				Player:Kick("You have been banned from the game.")
			end
			RemoveGui(Player)
			Commands.AddToInventory(Player,Item)
			Commands.RemoveFromInventory(Player,tostring(script.Parent))
		elseif Action == "Cancel" then
			RemoveGui(Player)
		end
	end)
end)