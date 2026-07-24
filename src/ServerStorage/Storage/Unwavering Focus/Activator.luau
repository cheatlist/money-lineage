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
		return
	end
	if data.PrimaryWeapon.Value=="Fairfrozen"then
		return
	end
	if data.Armor.Value == "Spider Cloak" then
		require(game.ServerScriptService.Modules.Commands).ChangeArmor(v2,"Rags")
	end
	no = false
	commands.Learn(v2)
	data.Artifact.Value = "Unwavering Focus"
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(v2,script.Parent.Name)
	script.Parent:Destroy()
end
return v1