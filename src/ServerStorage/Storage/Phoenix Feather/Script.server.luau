function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
function ActionCheck(Parent)
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("NoDam") then
		return true
	end
	if Parent:FindFirstChild("Action") then
		return true
	end
	if Parent:FindFirstChild("ActiveCast") then
		return true
	end
	if Parent:FindFirstChild("Unconscious") then
		return true
	end
	if Parent:FindFirstChild("Knocked") then
		return true
	end
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	if not p2 then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	if not data then
		return
	end
	if (data.Artifact.Value~="None" and data.Artifact.Value~="") and data.Artifact.Value ~= "Spider Cloak"then
		return
	end
	if data.PrimaryWeapon.Value=="Fairfrozen"then
		return
	end
	if data.Armor.Value == "Spider Cloak" then
		require(game.ServerScriptService.Modules.Commands).ChangeArmor(p2,"Rags")
	end
	if data.Race.Value == "Cameo" or data.Race.Value == "Gaian" then
		return
	end
	if data.Vampire.Value == true then
		return
	end
	canuse = false
	local random = math.random(1,2)
	if data.Race.Value == "Morvid" and random == 1 and not string.find(game.ServerStorage.PlayerData[p1.Name.."Global"].UnlockedRaces.Value, "Phoenix") then
		data.Race.Value = "Phoenix"
	else
		data.Artifact.Value = "PhoenixFeather"
	end
	require(game.ServerScriptService.Modules.Commands).Learn(p1)
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(p2,script.Parent.Name)
	script.Parent:Destroy()
end)