function ActionCheck(Parent)
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("NoDam") then
		return true
	end
	if Parent:FindFirstChild("ReturnStun") then
		return true
	end
	if Parent:FindFirstChild("Action") then
		return true
	end
	if Parent:FindFirstChild("Blocking") then
		return true
	end
	if Parent:FindFirstChild("Immortal") then
		return true
	end
	if Parent:FindFirstChild("SpellBlocking") then
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
	return
end

local Tool = script.Parent
local wait = task.wait
local cool = false
local Activated = false
local NewPosition
local NewHealth
local NewHunger
local NewToxicity
local NewInjuries
Tool.Activated:Connect(function()
	local Character = Tool.Parent
	local player = game.Players:GetPlayerFromCharacter(Character)
	local playerdata = game.ServerStorage.PlayerData:FindFirstChild(player.Name)
	if ActionCheck(Character) then return end
	if playerdata.DaysSurvived.Value - playerdata.LastPocketWatch.Value < 2 then return end
	if cool == false then
		local Active = true
		local Position = Character.HumanoidRootPart.Position
		if Activated == true then
			local tpsafe = Instance.new("Vector3Value")
			tpsafe.Name = "TPSafe"
			tpsafe.Parent = Character
			local LightFall = Instance.new("Folder")
			LightFall.Name = 'NoFall'
			LightFall.Parent = Character
			Character:PivotTo(CFrame.new(NewPosition))
			game.Debris:AddItem(tpsafe, 2)
			game.Debris:AddItem(LightFall, 2)
			Character.Humanoid.Health = NewHealth
			Character.Stomach.Value = NewHunger
			Character.Toxicity.Value = NewToxicity
			playerdata.Injuries.Value = NewInjuries
			game.ReplicatedStorage.Requests.PocketWatch:FireClient(player, false)
			playerdata.LastPocketWatch.Value = playerdata.DaysSurvived.Value
			Activated = false
			Active = false
			cool = true
			task.spawn(function()
				wait(600)
				cool = false
			end)
		else
			NewPosition = Position
			NewHealth = Character.Humanoid.Health
			NewHunger = Character.Stomach.Value
			NewToxicity = Character.Toxicity.Value
			NewInjuries = playerdata.Injuries.Value
			game.ReplicatedStorage.Requests.PocketWatch:FireClient(player, true)
			cool = true
			Activated = true
			task.spawn(function()
				wait(20)
				cool = false
			end)
		end
	end
end)