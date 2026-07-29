local u3 = require(game.ServerScriptService.Modules.Commands)
local FoodModule = require(game.ServerScriptService.Modules.FoodModule)
local Tool = script.Parent
local TweenService = game:GetService("TweenService")
local function ActionCheck(Parent): boolean
	if Parent:FindFirstChild("Action") then
		return true
	end
	if Parent:FindFirstChild("ActiveCast") then
		return true
	end
	if Parent:FindFirstChild("Unconscious") then
		return true
	end
	return false
end
local canuse: boolean = true
Tool.Activated:Connect(function()
	local p1 = Tool.Parent
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	if p1:FindFirstChild("NoHunger") or game:GetService("CollectionService"):HasTag(p1,"Vampirism") or game.ServerStorage.PlayerData:FindFirstChild(p1.Name).Race.Value == "Scroom" or game.ServerStorage.PlayerData:FindFirstChild(p1.Name).Race.Value == "Dullahan" or game.ServerStorage.PlayerData:FindFirstChild(p1.Name).Race.Value == "Gaian" or game.ServerStorage.PlayerData:FindFirstChild(p1.Name).Race.Value == "Metascroom" then
		Tool.Handle.Cough:Play()
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(p1.Name)
	if not FoodModule.eat(p1, data, "Turnip", 50) then
		Tool.Handle.Cough:Play()
		return
	end
	canuse = false
	u3.RemoveFromInventory(game.Players:GetPlayerFromCharacter(p1),"Turnip",0.65)
	p1.Humanoid:LoadAnimation(Tool.Animation):Play()
	wait(0.175)
	Tool.Handle.Sound:Play()
	task.delay(1.218, function()
		Tool.Handle.Sound:Stop()
	end)
	canuse = true
end)