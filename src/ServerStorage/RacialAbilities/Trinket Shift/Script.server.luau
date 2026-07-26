local OptionPicker = require(game.ServerScriptService.Modules.OptionPicker)

function ActionCheck(Parent)
	if Parent:FindFirstChild("Stun") then
		return true;
	end;
	if Parent:FindFirstChild("ReturnStun") then
		return true;
	end;
	if Parent:FindFirstChild("Action") then
		return true;
	end;
	if Parent:FindFirstChild("Blocking") then
		return true;
	end;
	if Parent:FindFirstChild("SpellBlocking") then
		return true;
	end;
	if Parent:FindFirstChild("ActiveCast") then
		return true;
	end;
	if Parent:FindFirstChild("Unconscious") then
		return true;
	end;
	if Parent:FindFirstChild("Knocked") then
		return true;
	end;
	if Parent:FindFirstChild("Immortal") then
	else
		return;
	end;
	return true;
end;
local cd = false

local function computeTrinkets()
	local trinkets = {}
	for i,v in pairs(game.ServerStorage.Storage:GetChildren()) do
		if (v:FindFirstChild("Handle") and v:FindFirstChild("Artifact") and v:FindFirstChild("Droppable") and not v:FindFirstChild("SpellType")) or v.Name == "Old Ring" or v.Name == "Ring" or v.Name == "Old Amulet" or v.Name == "Amulet" or v:FindFirstChild("Gem") or v.Name == "Idol of the Forgotten" then
			table.insert(trinkets, v)
		end
	end
	return trinkets
end

script.Parent.Activated:Connect(function(Player, Character, Data)
	Character = script.Parent.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Data = game.ServerStorage.PlayerData[Player.Name]
	if ActionCheck(Character) then
		return
	end
	if cd then return end
	cd = true
	task.delay(0.5, function()
		cd = false
	end)

	local healthConn

	local function watchHealth()
		if healthConn then
			healthConn:Disconnect()
		end
		local currenthp = Character.Humanoid.Health
		healthConn = Character.Humanoid.HealthChanged:Connect(function()
			if Character.Humanoid.Health < currenthp then
				for i,v in pairs(Character.Boosts:GetChildren()) do
					if v.Name == "Transparency" then
						task.wait(1/30)
						v:Destroy()
					end
				end
				if Character.HumanoidRootPart:FindFirstChild("IsShifted") then
					Instance.new("Folder", Character.HumanoidRootPart.IsShifted).Name = "Removering"
					Character.HumanoidRootPart.MoneyEmit:Emit(5)
					Character.HumanoidRootPart.MoneyDischarge:Play()
					Character.HumanoidRootPart.IsShifted:Destroy()
				end
				if healthConn then
					healthConn:Disconnect()
				end
			else
				currenthp = Character.Humanoid.Health
			end
		end)
	end

	local function becomeTrinket(chosentrinket)
		Character.HumanoidRootPart.MoneyDischarge:Play()
		Character.HumanoidRootPart.MoneyEmit:Emit(50)
		local Folder = Instance.new("NumberValue")
		Folder.Name = "Transparency"
		Folder.Value = 1
		Folder.Parent = Character.Boosts
		local clone:BasePart = chosentrinket.Handle:Clone()
		clone.Name = "IsShifted"
		for i,v in pairs(clone:GetChildren()) do
			if v.Name == "MeshPart" and v:FindFirstChildOfClass("Weld") and v:FindFirstChildOfClass("Weld").Name == "MeshPart --> Handle" then
				v:FindFirstChildOfClass("Weld").Name = "MeshPart --> IsShifted"
				v:FindFirstChildOfClass("Weld").Part1 = clone
			end
		end

		clone.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, -Character.HumanoidRootPart.Size.Y/2 - Character["Left Leg"].Size.Y + 0.3, 0)
		clone.Parent = Character.HumanoidRootPart
		clone.CanCollide = false

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = Character.HumanoidRootPart
		weld.Part1 = clone
		weld.Parent = clone

		watchHealth()
	end

	local function revertTrinket()
		if healthConn then
			healthConn:Disconnect()
		end
		for i,v in pairs(Character.Boosts:GetChildren()) do
			if v.Name == "Transparency" then
				task.wait(1/30)
				v:Destroy()
			end
		end
		if Character.HumanoidRootPart:FindFirstChild("IsShifted") then
			Instance.new("Folder", Character.HumanoidRootPart.IsShifted).Name = "Removering"
			Character.HumanoidRootPart.MoneyEmit:Emit(5)
			Character.HumanoidRootPart.MoneyDischarge:Play()
			Character.HumanoidRootPart.IsShifted:Destroy()
		end
		task.wait(.2)
	end

	local alreadyShifted = Character.HumanoidRootPart:FindFirstChild("IsShifted") ~= nil
	local ascended = Data.Ascended.Value == true and Data.Race.Value == "Madrasian"

	if not ascended then
		if not alreadyShifted then
			local trinkets = computeTrinkets()
			if #trinkets > 0 then
				becomeTrinket(trinkets[math.random(1, #trinkets)])
			end
		else
			revertTrinket()
		end
		return
	end

	local options = {}
	for _,trinket in ipairs(computeTrinkets()) do
		table.insert(options, {key = trinket.Name, label = trinket.Name})
	end
	if alreadyShifted then
		table.insert(options, {key = "__revert", label = "Turn back to normal"})
	end

	local choice = OptionPicker.prompt(Player, "Trinket Shift", options, 10)
	if not choice then
		return
	end
	if choice == "__revert" then
		revertTrinket()
		return
	end

	-- re-validate server-side against a freshly computed list, never trust the raw client string
	local chosentrinket = nil
	for _,trinket in ipairs(computeTrinkets()) do
		if trinket.Name == choice then
			chosentrinket = trinket
			break
		end
	end
	if not chosentrinket then
		return
	end
	if alreadyShifted then
		revertTrinket()
	end
	becomeTrinket(chosentrinket)
end)
