function ChefSkills(chef, sigmachirps)
	for i = 1,4 do
		if table.find(chef, sigmachirps[i]) then
			local mode = sigmachirps[i]
			return mode
		end
	end
end
local cd = false
script.Parent.Activated:Connect(function(Player, Character)
	if cd then return end
	cd = true
	task.delay(0.75, function()
		cd = false
	end)
	Character = script.Parent.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	local Data = game.ServerStorage.PlayerData[Player.Name]
	local Skills = Data.Skills.Value
	local commands = require(game.ServerScriptService.Modules.Commands)
	local mode = nil
	local chef = string.split(Skills, ",")
	local sigmachirps = {"Mouth-Watering", "Delicious", "Savory", "Tasty"}
	script.Parent.Handle.Sizzle:Play(15)
	task.wait(0.75)
	script.Parent.Handle.Sizzle:Stop()
	local Amount = 0
	if ChefSkills(chef, sigmachirps) == nil and Data.Inventory.Value:find("Uncooked Meat") then
		if not Character:FindFirstChild("Uncooked Meat") then
			local Children = Player.Backpack:GetChildren()
			for i,v in pairs(Children) do
				if v.Name == "Uncooked Meat" then
					Amount += 1
					Player.Backpack["Uncooked Meat"]:Destroy()
				end
			end
		else
			Player.Character["Uncooked Meat"]:Destroy()
		end
		for i = 1, Amount do
			commands.RemoveFromInventory(Player, "Uncooked Meat")
		end
		for i = 1, Amount do
			commands.AddToInventory(Player, "Meat")
		end
	elseif ChefSkills(chef, sigmachirps) ~= nil and Data.Inventory.Value:find("Uncooked Meat") and Data.SubClass.Value == "Chef" then
		if not Character:FindFirstChild("Uncooked Meat") then
			local Children = Player.Backpack:GetChildren()
			for i,v in pairs(Children) do
				if v.Name == "Uncooked Meat" then
					Amount += 1
					Player.Backpack["Uncooked Meat"]:Destroy()
				end
			end
		else
			Player.Character["Uncooked Meat"]:Destroy()
		end
		for i = 1, Amount do
			commands.RemoveFromInventory(Player, "Uncooked Meat")
		end
		for i = 1, Amount do
			commands.AddToInventory(Player,  ChefSkills(chef, sigmachirps).." Meat")
		end
	end
	task.wait(0.1)
end)