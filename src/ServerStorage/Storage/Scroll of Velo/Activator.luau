local v1 = {}
local playerdata = game.ServerStorage.PlayerData
local v10 = require(game.ServerScriptService.WorldHandler.Dialogues.DialogueHandler.ModuleScript)
local remote = game.ReplicatedStorage.Requests.DialogueNoNPCClient
local no = false
local talking = {}
local commands = require(game.ServerScriptService.Modules.Commands)
function v1.Active(v2)
	if no == true or table.find(string.split(playerdata[v2.Name].Skills.Value,","),"Velo") then
		return
	end
	local player = game.Players:GetPlayerFromCharacter(v2)
	no = true
	local allski = string.split(playerdata[v2.Name].Skills.Value, ",")
	local soulsnaps = {}
	for i,v in pairs(allski) do
		if v ~= "" then
			table.insert(soulsnaps, v)
		end
	end
	local toreturn = nil
	if table.find(allski,"Velo") then return end
	playerdata[v2.Name].Skills.Value = playerdata[v2.Name].Skills.Value..",Velo"
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(v2,script.Parent.Name)
	script.Parent:Destroy()
end
return v1