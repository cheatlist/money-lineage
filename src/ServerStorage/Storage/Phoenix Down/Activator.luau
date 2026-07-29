local v1 = {}
local playerdata = game.ServerStorage.PlayerData
local no = false

local maxLives = {Cameo = 4}

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
	if data.CameoCD.Value == true then
		return
	end
	if data.Race.Value == "Cameo" then
		data.CameoCD.Value = true
	end
	if v2:FindFirstChild("LichSummon") then
		return
	end
	if v3:FindFirstChild("LichSummon") then
		return
	end
	no = true
	local lives = playerdata[v2.Name].Lives
	local maxlives = maxLives[playerdata[v2.Name].Race.Value] or 1
	if lives.Value<maxlives then
		lives.Value+=1
	else
		no = false
		return
	end
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(v3,script.Parent.Name)
end
return v1