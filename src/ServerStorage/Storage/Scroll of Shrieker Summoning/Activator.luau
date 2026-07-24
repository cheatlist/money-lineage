local v1 = {}
local playerdata = game.ServerStorage.PlayerData
local v10 = require(game.ServerScriptService.WorldHandler.Dialogues.DialogueHandler.ModuleScript)
local remote = game.ReplicatedStorage.Requests.DialogueNoNPCClient
local no = false
local talking = {}
local commands = require(game.ServerScriptService.Modules.Commands)
function v1.Active(v2)
	if no == true or table.find(string.split(playerdata[v2.Name].Spells.Value,","),"Shrieker") or playerdata[v2.Name].LastScroll.Value ~= "" then
		return
	end
	local player = game.Players:GetPlayerFromCharacter(v2)
	
	no = true
	local allski = string.split(playerdata[v2.Name].Spells.Value, ",")
	local soulsnaps = {}
	for i,v in pairs(allski) do
		if v ~= "" then
			table.insert(soulsnaps, v)
		end
	end
	local toreturn = nil
	if table.find(allski,"Shrieker") then return end
	if table.find(_G.MageClasses, playerdata[v2.Name].Class.Value) or table.find(_G.MageClasses, playerdata[v2.Name].Hybrid.Value) then
		if #soulsnaps == 4 then
			
				playerdata[v2.Name].LastScroll.Value = "Shrieker"
				remote:FireClient(player)
			
		else
			playerdata[v2.Name].Spells.Value = playerdata[v2.Name].Spells.Value.."Shrieker,"
			commands.Learn(player)
		end
	else
		if #soulsnaps == 3 then
			
				playerdata[v2.Name].LastScroll.Value = "Shrieker"
				remote:FireClient(player)
			
		else
			playerdata[v2.Name].Spells.Value = playerdata[v2.Name].Spells.Value.."Shrieker,"
			commands.Learn(player)
		end
	end
	--playerdata[v2.Name].Skills.Value = playerdata[v2.Name].Skills.Value..",Armis"
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(v2,script.Parent.Name)
	script.Parent:Destroy()
end
return v1