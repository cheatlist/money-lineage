local u3 = require(game.ServerScriptService.Modules.Commands)
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
	canuse = false
	u3.RemoveFromInventory(game.Players:GetPlayerFromCharacter(p1),"Turnip")
	p1.Humanoid:LoadAnimation(Tool.Animation):Play()
	wait(0.175)
	Tool.Handle.Sound:Play()
	task.delay(.65, Tool.Destroy, Tool)
	local stomach: number = math.clamp(p1.Stomach.Value+50,0,p1.Humanoid.MaxHealth)
	p1.Stomach.Value = stomach
end)