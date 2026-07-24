local v1 = {}
local playerdata = game.ServerStorage.PlayerData
local no = false
local function create(name,deletetime,parent)
	if not parent then
		return
	end
	local i = Instance.new("Accessory")
	i.Name = name
	i.Parent = parent
	game.Debris:AddItem(i,deletetime)
	return i
end
function v1.Active(v2)
	if no == true or table.find(string.split(playerdata[v2.Name].Godspell.Value,","),"Manus Dei") or playerdata[v2.Name].Artifact.Value ~= "Philo" then
		return
	end
	no = true
	if playerdata[v2.Name].Godspell.Value ~= "" then
		local soulsnap = string.split(playerdata[v2.Name].Godspell.Value,",")
		local soulsnaps = {}
		for i,v in pairs(soulsnap) do
			if v ~= "" then
				table.insert(soulsnaps, v)
			end
		end
		local abc = game.Players:GetPlayerFromCharacter(v2).Backpack:FindFirstChild(soulsnaps[1])
		create("DestroySkill",false,abc)
		playerdata[v2.Name].Godspell.Value = "Manus Dei,"
		require(game.ServerScriptService.Modules.Commands).UpdateGodSpells(game.Players:GetPlayerFromCharacter(v2))
		require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(v2,script.Parent.Name)
		require(game.ServerScriptService.Modules.Commands).Learn(v2)
		script.Parent:Destroy()
	else
		playerdata[v2.Name].Godspell.Value = "Manus Dei,"
		require(game.ServerScriptService.Modules.Commands).UpdateGodSpells(game.Players:GetPlayerFromCharacter(v2))
		require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(v2,script.Parent.Name)
		require(game.ServerScriptService.Modules.Commands).Learn(v2)
		script.Parent:Destroy()
	end
end
return v1