local v1 = {}
local playerdata = game.ServerStorage.PlayerData
local v10 = require(game.ServerScriptService.WorldHandler.Dialogues.DialogueHandler.ModuleScript)
local remote = game.ReplicatedStorage.Requests.DialogueNoNPCClient
local no = false
local talking = {}
local commands = require(game.ServerScriptService.Modules.Commands)
function v1.Active(v2)
	if no == true then
		return
	end
	local player = game.Players:GetPlayerFromCharacter(v2)

	no = true
	
	game.ServerStorage.PlayerData:FindFirstChild(player.Name).Insight.Value += 10
	local Char = player.Character or nil
	if Char then
		Char.HumanoidRootPart.InsightEssence:Play()
		Char.HumanoidRootPart.InsightEmit:Emit(20)
		game.ReplicatedStorage.Requests.InsightChanged:FireClient(player,game.ServerStorage.PlayerData:FindFirstChild(player.Name).Insight.Value)
	end
	--playerdata[v2.Name].Skills.Value = playerdata[v2.Name].Skills.Value..",Armis"
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(v2,script.Parent.Name)
	script.Parent:Destroy()
end
return v1