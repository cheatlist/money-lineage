local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local alchemyFolder = ServerStorage.Alchemy
local list_ingredients = require(ServerScriptService.Alchemy.list_alchemy)

local ingredientProps = list_ingredients.ingredients
local potionRecipes = list_ingredients.recipes
local NonStackableItems = require(ServerScriptService.Modules.NonStackableItems)

local ToolHandler = {}
ToolHandler.__index = ToolHandler

function ToolHandler.GiveTool(Player, Item)
	if not ServerStorage.PlayerData:FindFirstChild(Player.Name) then
		return
	end
	
	local PlayerData = ServerStorage.PlayerData[Player.Name]
	
	local Items = ServerStorage.Items
	local NewItem = Items:FindFirstChild(Item)
	
	if not NewItem then
		return
	end
	
	
	PlayerData.Inventory.Value = PlayerData.Inventory.Value..","..NewItem.Name
	
	local newTool = NewItem:Clone()
	Instance.new("Accessory", newTool).Name = Player.Name
	newTool.Parent = Player.Backpack
	
	return true
end

function ToolHandler.RemoveTool(Player, Tool, SkillGiver)
	if not ServerStorage.PlayerData:FindFirstChild(Player.Name) then
		return
	end

	local PlayerData = ServerStorage.PlayerData[Player.Name]
	
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(Player, Tool.Name)

	if SkillGiver then
		ServerStorage.Requests.GiveSkill:Fire(Player, SkillGiver)
	end
	
	return true
end

function ToolHandler.GiveAlchemy(Player, toolName, Ingredient)
	if not ServerStorage.PlayerData:FindFirstChild(Player.Name) then
		return
	end

	local PlayerData = ServerStorage.PlayerData[Player.Name]
	
	if not ingredientProps[toolName] and not ServerStorage.Alchemy.Tools:FindFirstChild(toolName) then return print'doesnt exist' end
	
	if Ingredient then
		if not alchemyFolder.Models:FindFirstChild(toolName) then return end

		local existingIngredient = (Player.Character and Player.Character:FindFirstChild(toolName))
			or Player.Backpack:FindFirstChild(toolName)
		if existingIngredient then
			local qty = existingIngredient:FindFirstChild("Quantity")
			if not qty then
				qty = Instance.new("IntValue")
				qty.Name = "Quantity"
				qty.Value = 1
				qty.Parent = existingIngredient
			end
			qty.Value += 1
			PlayerData.Inventory.Value = PlayerData.Inventory.Value..","..toolName
			return true
		end

		local ingTool = alchemyFolder.Tools.Ingredient:Clone()
		Instance.new("Accessory", ingTool).Name = Player.Name
		ingTool.Name = toolName
		local ingHand = alchemyFolder.Models[toolName]:Clone()
		ingHand.Anchored = false
		ingHand.CanCollide = false
		ingHand.Name = "Handle"
		ingHand.Parent = ingTool

		local silver = ingredientProps[toolName].silver
		if silver and silver > 0 then
			local silverVal = Instance.new("IntValue")
			silverVal.Name = "SilverValue"
			silverVal.Value = silver
			silverVal.Parent = ingTool
		end

		local tooltip = ingredientProps[toolName].tooltip
		if tooltip then
			ingTool.ToolTip = tooltip
		end
		local qty = ingTool:FindFirstChild("Quantity")
		if not qty then
			qty = Instance.new("IntValue")
			qty.Name = "Quantity"
			qty.Parent = ingTool
		end
		qty.Value = 1
		ingTool.Parent = Player.Backpack
	else
		if not NonStackableItems[toolName] then
			local existing = (Player.Character and Player.Character:FindFirstChild(toolName))
				or Player.Backpack:FindFirstChild(toolName)
			if existing then
				local qty = existing:FindFirstChild("Quantity")
				if not qty then
					qty = Instance.new("IntValue")
					qty.Name = "Quantity"
					qty.Value = 1
					qty.Parent = existing
				end
				qty.Value += 1
				PlayerData.Inventory.Value = PlayerData.Inventory.Value..","..toolName
				return true
			end
		end
		local newTool = ServerStorage.Alchemy.Tools:FindFirstChild(toolName):Clone()
		Instance.new("Accessory", newTool).Name = Player.Name
		if not NonStackableItems[toolName] then
			local qty = newTool:FindFirstChild("Quantity")
			if not qty then
				qty = Instance.new("IntValue")
				qty.Name = "Quantity"
				qty.Parent = newTool
			end
			qty.Value = 1
		end
		newTool.Parent = Player.Backpack
	end

	PlayerData.Inventory.Value = PlayerData.Inventory.Value..","..toolName

	return true
end

function ToolHandler.HasTool(Player, Tool)
	local PlayerData = ServerStorage.PlayerData[Player.Name].Data

	return PlayerData.Inventory.Value:match(Tool)
end


return ToolHandler