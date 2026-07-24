local TweenService = game:GetService("TweenService")
local function ActionCheck(Parent)
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
	if Parent:FindFirstChild("Immortal") then
		return true
	end
	return false
end
local canuse = true
function DetectCameo(Data, Character)
	local targets = {}
	for i,v in pairs(workspace.Live:GetChildren()) do
		if v:FindFirstChild("HumanoidRootPart") and (not v:FindFirstChild("MonsterInfo")) and v ~= Character and (v.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude <= 20 then
			table.insert(targets, v)
		end
	end
	if #targets < 4 then
		return false
	end
	local truetargs = {}
	for i = 1,#targets do
		if game.ServerStorage.PlayerData[targets[i].Name].LastName.Value == Data.LastName.Value and Data.LastName.Value ~= "" then
			table.insert(truetargs, targets[i])
		end
	end
	if #truetargs >= 4 then
		for i = 1,#truetargs do
			_G.Death(truetargs[i])
		end
		return true
	else
		return false
	end
end
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
	if game.ServerStorage.PlayerData[p2.Name].Lives.Value < 1 then
		return
	end
	if data.Race.Value == "Cameo" then
		return
	end
	canuse = false
	--if not DetectCameo(data, p1) then canuse = true return end
	-- enable the script above to make it so 4 house members is a requirement
	if p2:FindFirstChild("Danger") then
		canuse = true
		return
	end
	if data.Race.Value == "Ashiin" then
		data.Race.Value = "Cameo"
		data.Skills.Value ..= ",TrainedCombat"
	else
		data.Race.Value = "Cameo"
	end
	data.FirstName.Value = require(game.ServerScriptService.WorldHandler.GameLoaded.Randomize.NameGenerator)({Race = "Cameo"})
	local root = p1.HumanoidRootPart
	local newlastpos = root.CFrame.X..","..root.CFrame.Y..","..root.CFrame.Z
	data.LastPosition.Value = newlastpos
	data.Lives.Value = 4
	local randomnumber = math.random(1,10)
	if randomnumber == 1 then data.UberTitle.Value = "Soulless Warrior"
	end
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(p2,script.Parent.Name)
    script.Parent:Destroy()	
end)