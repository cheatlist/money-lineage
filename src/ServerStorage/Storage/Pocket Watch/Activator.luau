local v1 = {}
local playerdata = game.ServerStorage.PlayerData
local no = false

local maxLives = {Cameo = 4}

local commands = require(game.ServerScriptService.Modules.Commands)
function v1.Active(v2,v3)
	if no == true then
		return
	end
	if not v2:FindFirstChild("Humanoid") then
		return
	end
	if v2.Humanoid.Health < 1 or v2.Humanoid.Health == 0 then
		return
	end
	if not v2:FindFirstChild("HumanoidRootPart") then
		return
	end
	local data = game.ServerStorage.PlayerData[v2.Name]
	if not data then return end
	if (data.Artifact.Value~="None" and data.Artifact.Value~="") and data.Artifact.Value ~= "Spider Cloak"then
		require(game.ServerScriptService.Modules.AlertModule).send(game.Players:GetPlayerFromCharacter(v2), "You already have an artifact - "..data.Artifact.Value..". Reset your current artifact by talking to Isaiah at desert 3.")
		return
	end
	if data.PrimaryWeapon.Value=="Fairfrozen"then
		return
	end
	if data.Armor.Value == "Spider Cloak" then
		require(game.ServerScriptService.Modules.Commands).ChangeArmor(v2,"Rags")
	end
	commands.Learn(v2)
	data.Artifact.Value = "Pocket Watch"
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(v2,script.Parent.Name)
end
return v1