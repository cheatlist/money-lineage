local FindFirstChild,WaitForChild = game.FindFirstChild,game.WaitForChild
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
script.Parent.Activated:Connect(function(Player, Character, Data)
	Character = script.Parent.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Data = game.ServerStorage.PlayerData[Player.Name]
	if ActionCheck(Character) then
		return
	end
	if cd then return end
	local conn
	cd = true
	task.delay(0.5, function()
		cd = false
	end)
	local trinkets = {}
	for i,v in pairs(game.ServerStorage.Storage:GetChildren()) do
		if (v:FindFirstChild("Handle") and v:FindFirstChild("Artifact") and v:FindFirstChild("Droppable") and not v:FindFirstChild("SpellType")) or v.Name == "Old Ring" or v.Name == "Ring" or v.Name == "Old Amulet" or v.Name == "Amulet" or v:FindFirstChild("Gem") or v.Name == "Idol of the Forgotten" then
			table.insert(trinkets, v)
		end
	end
	local connection
	local unequipping = false
	local currenthp = Character.Humanoid.Health
	connection = Character.Humanoid.HealthChanged:Connect(function()
		if Character.Humanoid.Health < currenthp then
			unequipping = true
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
			connection:Disconnect()
			task.wait(.2)
			unequipping = false
		else
			currenthp = Character.Humanoid.Health
		end
	end)
	if not Character.HumanoidRootPart:FindFirstChild("IsShifted") then
		Character.HumanoidRootPart.MoneyDischarge:Play()
		Character.HumanoidRootPart.MoneyEmit:Emit(50)
		local Folder = Instance.new("NumberValue")
		Folder.Name = "Transparency"
		Folder.Value = 1
		Folder.Parent = Character.Boosts
		local chosentrinket = trinkets[math.random(1, #trinkets)]
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
		
	else
		connection:Disconnect()
		
		unequipping = true
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
		unequipping = false
	end
end)