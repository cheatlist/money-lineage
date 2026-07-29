local v1 = {}
local playerdata = game.ServerStorage.PlayerData
local no = false
function v1.Active(v1,v2)
	if no == true or playerdata[v2.Name].Armor.Value == "Spider Cloak"then
		return
	end
	if playerdata[v2.Name].Artifact.Value~="None" and playerdata[v2.Name].Artifact.Value~="" then
		require(game.ServerScriptService.Modules.AlertModule).send(game.Players:GetPlayerFromCharacter(v2), "You already have an artifact - "..playerdata[v2.Name].Artifact.Value..". Reset your current artifact by talking to Isaiah at desert 3.")
		return
	end
	playerdata[v2.Name].Artifact.Value = "Spider Cloak"
	require(game.ServerScriptService.Modules.Commands).ChangeArmor(v2,"Spider Cloak")
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(v2,script.Parent.Name)
end
return v1